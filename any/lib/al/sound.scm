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

;; `sound-volume' is a percentage integer (can be greater than 100 for
;; some backends).
;;
;; `sound-mute?' is #t (if sound is off) or #f (if sound is on)
(define-drecord sound volume mute?)

(define (sound-equal? snd1 snd2)
  (and (eq? (sound-mute? snd1)
            (sound-mute? snd2))
       (fx=? (sound-volume snd1)
             (sound-volume snd2))))

;; `backend-getter' should accept zero arguments and should return
;; either #f (if sound info cannot be obtained) or list of integers
;; (per-channel volume percentages).
;;
;; `backend-setter' should accept VOLUMES as the rest argument.  VOLUMES
;; list consists either of a single volume percentage (to set it for all
;; channels) or volume percentages for all channels.  `backend-setter'
;; should return #f if sound info cannot be changed.
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
  ;; Parse 'amixer' OUTPUT and return list of channel volumes.
  (let ((re (rx "Playback " (+ digit)
                " [" ($ (+ digit)) "%]")))
    (lambda (output)
      (let loop ((start 0)
                 (volumes '()))
        (if-let ((match (regexp-search re output start)))
          (loop (regexp-match-submatch-end match 0)
                (cons (string->number (regexp-match-submatch match 1))
                      volumes))
          (and (not-null? volumes)
               (reverse! volumes)))))))

(define (amixer-get-sound)
  (parse-amixer-output
   (call-amixer "get" %amixer-control)))

(define (amixer-set-sound volume . rest-volumes)
  ;; Set all channels to VOLUME (percentage integer).
  ;;
  ;; XXX REST-VOLUMES are ignored i.e., per-channel volumes is not
  ;; currently supported.
  (parse-amixer-output
   (call-amixer "set" %amixer-control
                (string-append (number->string volume) "%"))))

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


;;; pactl interface

(define (call-pactl . args)
  ;; Call 'pactl' with ARGS and return its output.
  (apply system*-output "pactl" args))

;; We can also use one of the following:
;;
;; "@DEFAULT_SINK@"
;; (string-trim-right (call-pactl "get-default-sink"))
(define %pactl-sink "0")

(define pactl-get-sound
  ;; Return list with per-channel volume percentages.
  ;; Return #f if sound volume cannot be received for any reason.

  ;; get-sink-volume output:
  ;; Volume: front-left: 37355 /  57% / -14.65 dB,   front-right: 37355 /  57% / -14.65 dB
  (let ((re (rx ($ (+ digit)) "%")))
    (lambda ()
      (when-let1 ((output (with-locale "C"
                            (call-pactl "get-sink-volume" %pactl-sink)))
                  (chn-strings (regexp-split "," output)))
        (map (lambda (str)
               (when-let ((match (regexp-search re str)))
                 (string->number
                  (regexp-match-submatch match 1))))
             chn-strings)))))

(define (pactl-set-sound . volumes)
  (apply call-pactl "set-sink-volume" %pactl-sink
         (map (lambda (vol)
                (string-append (number->string vol) "%"))
              volumes))
  ;; XXX Should return #f if pactl failed to set sound.
  #t)

(define be/pactl
  (backend*
   (name "pactl")
   (getter pactl-get-sound)
   (setter pactl-set-sound)))


;;; High-level interface

(define (same-sound-checker)
  ;; Return PROCEDURE to check if all sound records are equal.
  ;;
  ;; PROCEDURE takes a single argument, sound record.  It returns #t or
  ;; #f depending on whether all sound records that it was previously
  ;; called with (including the current one) are equal or not.
  ;;
  ;; PROCEDURE can be also called without arguments to return the
  ;; current state of previously called sound records.
  (let ((same? #t)
        (prev-snd #f))
    (case-lambda
      (() same?)
      ((snd)
       (when same?
         (if prev-snd
           (unless (sound-equal? snd prev-snd)
             (set! same? #f))
           (set! prev-snd snd)))
       same?))))

(define channel-volume-cache
  (let ((cache (make-aalist assv)))
    (cut aalist-value cache <...>)))

(define (channel-volume->sound channel volume)
  (let-values (((vol mute)
                (if (=0 volume)
                  (let ((cvol (channel-volume-cache channel)))
                    (values (or cvol 0)
                            (and cvol #t)))
                  (values volume #f))))
    (sound (volume vol)
           (mute? mute))))

(define (channel-sound->volume channel snd)
  (let ((vol (sound-volume snd)))
    (if (sound-mute? snd)
      (begin (channel-volume-cache channel vol)
             0)
      vol)))

(define (get-sound)
  ;; Return 2 values: sound record(s) and the number of channels.
  ;;
  ;; If all channels have the same volume/mute, the first returned value
  ;; is a single sound record.  Otherwise, it is a list of sound records
  ;; for all the channels.
  ;;
  ;; Return (#f #f) values if sound info cannot be obtained using
  ;; `current-backend'.
  (if-let1 ((volumes ((backend-getter (current-backend))))
            (same-sound-check (same-sound-checker)))
    (let loop ((channel 0)
               (volumes volumes)
               (sounds '()))
      (match volumes
        (()
         (values (if (same-sound-check)
                   (car sounds)
                   (reverse! sounds))
                 channel))
        ((vol . rest-vols)
         (let ((snd (channel-volume->sound channel vol)))
           (same-sound-check snd)
           (loop (inc channel)
                 rest-vols
                 (cons snd sounds))))))
    (values #f #f)))

(define (update-sound! snd value)
  ;; Update and return sound record SND according to VALUE.
  (match value
    ((? string? str)
     (let ((first-char (string-ref str 0))
           (vol (string->number str)))
       (cond
        ((memv first-char '(#\+ #\-))
         (sound-volume snd (+ (sound-volume snd) vol)))
        (vol (sound-volume snd vol))
        (else
         (match str
           ("on"     (sound-mute? snd #f))
           ("off"    (sound-mute? snd #t))
           ("toggle" (sound-mute? snd (not (sound-mute? snd))))
           ("keep"   #f)
           (unknown
            (print-error "Unknown sound setting command: ~a" unknown)))))))
    ((? integer? vol)
     (sound-volume snd vol)))
  snd)

(define (update-sound snd value)
  ;; Return a new sound record updating SND according to VALUE.
  (let ((new-snd (sound (volume (sound-volume snd))
                        (mute?  (sound-mute? snd)))))
    (update-sound! new-snd value)))

(define (set-backend-sound snd chn-count)
  ;; Exit point for `set-sound'.
  (if (apply (backend-setter (current-backend))
             (map-indexed channel-sound->volume
                          (if (list? snd)
                            snd
                            (make-list chn-count snd))))
    (values snd chn-count)
    (values #f #f)))

(define (set-sound . args)
  ;; Set sound according to ARGS.
  ;;
  ;; Return the same values as `get-sound'.  If ARGS are not specified,
  ;; this procedure does the same as `get-sound'.
  ;;
  ;; If ARGS list consists of a single value, it is used to set all
  ;; channels.  Otherwise, ARGS should specify values for all channels.
  ;;
  ;; Each argument from ARGS should have one of the following forms:
  ;;
  ;;  - #f or "keep" if sound should not be changed for this channel.
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
  ;;  - "on" to unmute (turn sound on).
  ;;
  ;;  - "off" to mute (turn sound off).
  ;;
  ;;  - "toggle" to toggle mute state.
  (let-values (((snd chn-count) (get-sound)))
    (match args
      (() (values snd chn-count))
      ((first-arg . rest-args)
       (let ((single-arg?    (null? rest-args))
             (same-channels? (not (list? snd))))
         (if (and single-arg? same-channels?)
           (set-backend-sound (update-sound! snd first-arg)
                              chn-count)
           (let ((same-sound-check (same-sound-checker))
                 (sounds (if same-channels?
                           (make-list chn-count snd)
                           snd))
                 (args   (if single-arg?
                           (make-list chn-count first-arg)
                           args)))
             (let loop ((channel 0)
                        (args args)
                        (old-sounds sounds)
                        (new-sounds '()))
               (match old-sounds
                 (()
                  (set-backend-sound (if (same-sound-check)
                                       (car new-sounds)
                                       (reverse! new-sounds))
                                     chn-count))
                 ((cur . rest)
                  (let ((snd (update-sound cur (car args))))
                    (same-sound-check snd)
                    (loop (inc channel)
                          (cdr args)
                          rest
                          (cons snd new-sounds)))))))))))))

(define (increase-volume percentage)
  ;; Increase sound volume by PERCENTAGE.
  ;; Return sound record for the current sound value.
  (set-sound (string-append "+" (number->string percentage))))

(define (decrease-volume percentage)
  ;; Decrease sound volume by PERCENTAGE.
  ;; Return sound record for the current sound value.
  (set-sound (string-append "-" (number->string percentage))))

(define current-backend (make-parameter be/amixer))

;;; sound.scm ends here
