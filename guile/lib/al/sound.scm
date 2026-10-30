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

;; This file provides code related to sound (currently: calling 'amixer'
;; and parsing its output).

;;; Code:

(define-module (al sound)
  #:use-module (ice-9 format)
  #:use-module (srfi srfi-115)
  #:use-module (al processes)
  #:use-module (al records)
  #:use-module (let-macros)
  #:export (make-sound
            sound*
            sound?
            sound-volume
            sound-muted?
            get-sound
            set-sound
            increase-volume
            decrease-volume))

(define-record-type* <sound>
  make-sound sound*
  sound?
  (volume sound-volume #f)      ; number from 0 to 100
  (muted? sound-muted? #f))     ; on or off

(define %amixer-control "Master")

(define (call-amixer . args)
  "Call 'amixer' with ARGS and return its output."
  ;; Use "-D hw:0" to avoid PulseAudio layer and connect directly to
  ;; ALSA device.  Downsides: non-logarithmic percent scale, volume step
  ;; is big (bigger than 1%), unmuting doesn't work.
  ;;
  ;; (apply system*-output "amixer" "-D" "hw:0" args)
  (apply system*-output "amixer" args))

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
  (let ((re (rx "Playback " (+ digit)
                " [" ($ (+ digit)) "%]"
                (+ any)
                "[" ($ (or "on" "off")) "]")))
    (lambda (output)
      "Parse 'amixer' OUTPUT and return <sound> record.
Return #f if OUTPUT cannot be parsed."
      (when-let ((match (regexp-search re output)))
        (sound*
         #:volume (string->number (regexp-match-submatch match 1))
         #:muted? (string=? "off" (regexp-match-submatch match 2)))))))

(define (get-sound)
  "Return <sound> structure for the current sound value."
  (parse-amixer-output
   (call-amixer "get" %amixer-control)))

(define* (set-sound #:key volume mute #:rest args)
  "Set sound according to VOLUME and MUTE arguments.

VOLUME should be either:

  - an integer from 0 to 100,

  - a string in \"sN\" format, where \"N\" is an integer and \"s\" is an
    optional sign i.e., \"s\" is either:

    \"+\": to increase volume by N,
    \"-\": to decrease volume by N,
    empty string: to set volume to N.

MUTE should be either #f, #t, or `toggle' symbol.

Return <sound> structure for the current sound value."
  (define (->volume-arg vol)
    (cond
     ((integer? vol)
      (string-append (number->string vol) "%"))
     ((string? vol)
      (let ((first-char (car (string->list vol))))
        (case first-char
          ((#\+ #\-)
           (format #f "~a%~c" (substring vol 1) first-char))
          (else
           (string-append vol "%")))))
     (else #f)))

  (define (->mute-arg mute)
    (if mute
      (if (eq? #t mute) "off" "toggle")
      "on"))

  (let* ((volume-arg (and (memq #:volume args)
                          (->volume-arg volume)))
         (mute-arg   (and (memq #:mute args)
                          (->mute-arg mute)))
         (args       (filter identity
                             (list volume-arg mute-arg))))
    (parse-amixer-output
     (apply call-amixer "set" %amixer-control args))))

(define (increase-volume percentage)
  "Increase sound volume by PERCENTAGE.
Return percentage of the current volume."
  (set-sound #:volume (string-append "+" (number->string percentage))))

(define (decrease-volume percentage)
  "Decrease sound volume by PERCENTAGE.
Return percentage of the current volume."
  (set-sound #:volume (string-append "-" (number->string percentage))))

;;; sound.scm ends here
