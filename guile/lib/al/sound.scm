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
  #:use-module (drecords)
  #:use-module (let-macros)
  #:export (sound
            sound?
            sound-volume
            sound-state
            get-sound
            set-sound
            increase-volume
            decrease-volume))

(define-drecord sound volume state)

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
  ;; (parse-amixer-output OUTPUT)
  ;;
  ;; Parse 'amixer' OUTPUT and return sound record.
  ;;
  ;; Return #f if OUTPUT cannot be parsed.  Otherwise, return sound
  ;; record for the current sound value, where `volume' field is an
  ;; integer from 0 to 100, `state' field is `on' (if sound is on) or
  ;; `off' (if sound is off) symbol.
  (let ((re (rx "Playback " (+ digit)
                " [" ($ (+ digit)) "%]"
                (+ any)
                "[" ($ (or "on" "off")) "]")))
    (lambda (output)
      (when-let ((match (regexp-search re output)))
        (sound
         (volume (string->number (regexp-match-submatch match 1)))
         (state  (string->symbol (regexp-match-submatch match 2))))))))

(define (get-sound)
  ;; Return sound record for the current sound value.
  ;; See `parse-amixer-output' for details.
  (parse-amixer-output
   (call-amixer "get" %amixer-control)))

(define (set-sound snd)
  ;; Set sound according to SND sound record.
  ;;
  ;; SND `volume' field should be either:
  ;;
  ;;  - #f if volume value should not be changed,
  ;;
  ;;  - an integer from 0 to 100,
  ;;
  ;;  - a string in "sN" format, where "N" is an integer and "s" is an
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
  ;; See `parse-amixer-output' for details.
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

(define (increase-volume percentage)
  "Increase sound volume by PERCENTAGE.
Return percentage of the current volume."
  (set-sound
   (sound (volume (string-append "+" (number->string percentage))))))

(define (decrease-volume percentage)
  "Decrease sound volume by PERCENTAGE.
Return percentage of the current volume."
  (set-sound
   (sound (volume (string-append "-" (number->string percentage))))))

;;; sound.scm ends here
