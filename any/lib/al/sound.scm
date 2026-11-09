;;; sound.scm --- Sound utilities

;; Copyright © 2016–2026 Alex Kost

;; Author: Alex Kost <alezost@gmail.com>
;; Created: 14 Jul 2016

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This file provides code related to sound.  The main procedures to
;; control and check sound values are `set-sound' and `get-sound'.  See
;; their description in the according procedure commentaries.  They use
;; `current-backend' parameter to set/get sound info.  It can be changed
;; like this:
;;
;;   (current-backend be/alsa)
;;   (current-backend (backend-by-name "pactl"))
;;
;; Call `backends' to get a list of all available backends.

;;; Code:

(define-drecord sound volume state)
(define-drecord backend name description getter setter)

;; For some reason, Guile cannot handle the following `define-values'
;; clause.  Compilation gives the an error like this one:
;;
;;   Unbound variable: t-158ed5752046006f-6b
;;
;; (define-values (backends
;;                 register-backend)
;;   (let ((bs '()))
;;     (values
;;       (lambda () bs)
;;       (lambda (b) (push! b bs)))))
;;
;; So we define a global variable `%backends':

(define %backends '())
(define (backends) %backends)
(define (register-backend backend)
  (push! backend %backends))

(define-syntax-rule (backend* args ...)
  (let ((b (backend args ...)))
    (register-backend b)
    b))

(define (backend-by-name name)
  (find (lambda (b)
          (string=? name (backend-name b)))
        (backends)))


;;; amixer interface

(define %amixer-control "Master")

;; "default" device is PulseAudio (on a system with PulseAudio).
;; "hw:0" device makes amixer connect directly to ALSA avoiding
;; PulseAudio layer.  Downsides: non-logarithmic percent scale,
;; volume step is big (bigger than 1%), unmuting does not work.
(define amixer-device (make-parameter "default"))

(define (call-amixer . args)
  ;; Call 'amixer' with ARGS and return its output.
  (apply system*-output
         "amixer" "-D" (amixer-device) args))

#|
Typical amixer output without Pulseaudio:

Simple mixer control 'Master',0
  Playback channels: Mono
  Limits: Playback 0 - 87
  Mono: Playback 73 [84%] [-10.50dB] [on]

Typical amixer output with Pulseaudio:

Simple mixer control 'Master',0
  Playback channels: Front Left - Front Right
  Limits: Playback 0 - 65536
  Mono:
  Front Left: Playback 43908 [67%] [on]
  Front Right: Playback 43908 [67%] [on]
|#

(define parse-amixer-output
  ;; (parse-amixer-output OUTPUT)
  ;;
  ;; Parse 'amixer' OUTPUT and return sound record.
  (let ((re (rx "Playback " (+ digit)
                " [" ($ (+ digit)) "%]"
                (+ any)
                "[" ($ (or "on" "off")) "]")))
    (lambda (output)
      (when-let ((match (regexp-search re output)))
        (sound
         (volume (string->number (regexp-match-submatch match 1)))
         (state  (string->symbol (regexp-match-submatch match 2))))))))

(define (amixer-get-sound)
  (parse-amixer-output
   (call-amixer "get" %amixer-control)))

(define (amixer-set-sound snd)
  (define (->volume-arg vol)
    (cond
     ((integer? vol)
      (string-append (number->string vol) "%"))
     ((string? vol)
      (let ((first-char (string-ref vol 0)))
        (case first-char
          ((#\+ #\-)
           (format #f "~a%~c"
                   (substring vol 1 (string-length vol))
                   first-char))
          (else
           (string-append vol "%")))))
     (else #f)))

  (define (->mute-arg mute)
    (if (symbol? mute)
      (symbol->string mute)
      mute))

  (let* ((volume-arg (->volume-arg (sound-volume snd)))
         (mute-arg   (->mute-arg   (sound-state snd)))
         (args       (filter identity
                             (list volume-arg mute-arg))))
    (parse-amixer-output
     (apply call-amixer "set" %amixer-control args))))

(define (alsa-get-sound)
  (parameterize ((amixer-device "hw:0"))
    (amixer-get-sound)))

(define (alsa-set-sound snd)
  (parameterize ((amixer-device "hw:0"))
    (amixer-set-sound snd)))

(define be/amixer
  (backend*
   (name "amixer")
   (description "amixer (default device)")
   (getter amixer-get-sound)
   (setter amixer-set-sound)))

(define be/alsa
  (backend*
   (name "alsa")
   (description "amixer (ALSA device)")
   (getter alsa-get-sound)
   (setter alsa-set-sound)))


;;; High-level interface

(define (get-sound)
  ;; Return sound record for the current sound value.
  ;;
  ;; `volume' field of the sound record is a percentage integer (can be
  ;; greater than 100 for some backends), `state' field is `on' (if
  ;; sound is on) or `off' (if sound is off) symbol.
  ((backend-getter (current-backend))))

(define (set-sound snd)
  ;; Set sound according to SND sound record.
  ;;
  ;; SND `volume' field should be either:
  ;;
  ;;  - #f if volume value should not be changed.
  ;;
  ;;  - Percentage integer (can be greater than 100 for some backends).
  ;;
  ;;  - String in "sN" format, where "N" is an integer and "s" is an
  ;;    optional sign i.e., "s" is either:
  ;;
  ;;    "+": to increase volume by N,
  ;;    "-": to decrease volume by N,
  ;;    empty string: to set volume to N.
  ;;
  ;; SND `state' field should be either #f (if state value should not be
  ;; changed), `on' (to turn sound on), `off' (to turn sound off), or
  ;; `toggle' string or symbol.
  ;;
  ;; Return sound record for the current sound value.
  ;; See `get-sound' for details.
  ((backend-setter (current-backend)) snd))

(define (increase-volume percentage)
  ;; Increase sound volume by PERCENTAGE.
  ;; Return sound record for the current sound value.
  (set-sound
   (sound (volume (string-append "+" (number->string percentage))))))

(define (decrease-volume percentage)
  ;; Decrease sound volume by PERCENTAGE.
  ;; Return sound record for the current sound value.
  (set-sound
   (sound (volume (string-append "-" (number->string percentage))))))

(define current-backend (make-parameter be/amixer))

;;; sound.scm ends here
