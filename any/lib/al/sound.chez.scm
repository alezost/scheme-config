;;; sound.chez.scm --- Chez-specific sound utilities

;; Copyright © 2026 Alex Kost

;; Author: Alex Kost <alezost@gmail.com>

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

;;; Code:

(define (sink-info->sound info)
  (sound
   (volume (map volume->percent
                (sink-info-channels info)))
   (state  (if (sink-info-mute? info) 'off 'on))))

(define (pulse-get-sound)
  (sink-info->sound (get-sink-info)))

(define (pulse-volume-adder value)
  (cond
   ((not value) identity)
   ((integer? value)
    (const (percent->volume value)))
   ((string? value)
    (let ((first-char (string-ref value 0))
          (vol (percent->volume (string->number value))))
      (case first-char
        ((#\+ #\-) (lambda (v) (+ v vol)))
        (else (const vol)))))))

(define (pulse-set-sound snd)
  (let ((info (get-sink-info)))

    (define (->volumes value)
      (if (list? value)
        (map (lambda (volume value)
               ((pulse-volume-adder value) volume))
             (sink-info-channels info)
             value)
        (map (pulse-volume-adder value)
             (sink-info-channels info))))

    (define (->mute state)
      (match state
        ((or 'on "on") #f)
        ((or 'off "off") #t)
        ((or 'toggle "toggle") (not (sink-info-mute? info)))))

    (when-let1 ((vol (sound-volume snd))
                (vols (->volumes vol)))
      (apply set-volume vols)
      (sink-info-channels info vols))
    (when-let1 ((state (sound-state snd))
                (mute (->mute state)))
      (set-mute mute)
      (sink-info-mute? info mute))
    (sink-info->sound info)))

(define be/pulse
  (backend*
   (name "pulse")
   (description "libpulse (Chez FFI)")
   (getter pulse-get-sound)
   (setter pulse-set-sound)))

(current-backend be/pulse)

;;; sound.chez.scm ends here
