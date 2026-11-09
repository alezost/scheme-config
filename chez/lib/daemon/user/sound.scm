;;; sound.scm --- Get/set sound and show it in OSD

;; Copyright © 2016–2026 Alex Kost <alezost@gmail.com>

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

(define %timeout-on 3)
(define %timeout-off 0)

(define output-sound
  ;; (output-sound SOUND [SHOW-OSD?])
  ;;
  ;; Return SOUND value in Lisp format.  SHOW-OSD? defines if OSD
  ;; with the sound value should be displayed or not.
  (case-lambda
    ((snd)
     (output-sound snd #t))
    ((snd show-osd?)
     (if snd
       (let* ((volume (sound-volume snd))
              (volume (if (list? volume)
                        (car volume)
                        volume))
              (muted? (eq? 'off (sound-state snd))))
         (when show-osd?
           (show-main-osd
            (line0   (format #f "Sound: ~d%" volume))
            (line1   volume)
            (color   (if muted? %color-off   %color-on))
            (timeout (if muted? %timeout-off %timeout-on))))
         (list volume (scheme->lisp (not muted?))))
       (display-error-in-main-osd "Cannot obtain sound value")))))

(define (osd-sound . args)
  ;; Update sound according to ARGS and show sound OSD.
  ;;
  ;; ARGS should be command line arguments (i.e., strings).  ARGS have
  ;; one of the following forms:
  ;;
  ;;   () or ("show")   return current sound and show OSD;
  ;;
  ;;   ("get")          return current sound and do not show OSD
  ;;                    (this is the only form that does not show OSD);
  ;;
  ;;   ("set" "VALUE")  set sound volume to the specified VALUE,
  ;;                    see `set-sound' for details;
  ;;
  ;;   ("on")           unmute (turn sound on);
  ;;
  ;;   ("off")          mute (turn sound off);
  ;;
  ;;   ("toggle")       toggle mute state.
  ;;
  ;; Example: (osd-sound "set" "+3")
  ;;
  ;; Return (VOLUME ON) list, where
  ;;
  ;;   VOLUME is an integer from 0 to 100,
  ;;
  ;;   ON is a boolean value in Lisp format showing if sound is on or
  ;;   off (muted).
  ;;
  ;; Return false value in Lisp format in case of any error.
  (match args
    ((or () ("show"))
     (output-sound (get-sound) #t))
    (("get")
     (output-sound (get-sound) #f))
    (("set" value)
     (output-sound (set-sound (sound (volume value)))))
    ((cmd)
     (match cmd
       ((or "on" "off" "toggle")
        (output-sound (set-sound (sound (state cmd)))))
       (_
        (display-error-in-main-osd
         (format #f "Unknown command: ~a" cmd)))))
    (_
     (display-error-in-main-osd
      (format #f "Unknown arguments: ~a" args)))))

;;; sound.scm ends here
