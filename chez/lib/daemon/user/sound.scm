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

(define-syntax-rule (make-channel-osd args ...)
  (make-osd
    (lines 2)
    (bar-length 30)
    (position 'bottom)
    (font "-*-dejavu sans-bold-r-normal-*-*-280-*-*-p-*-*")
    (shadow-offset 2)
    (horizontal-offset 10)
    (vertical-offset 10)
    args ...))

(define-values (left-osd
                right-osd
                hide-left-right-osds)
  (let ((left #f)
        (right #f))
    (values
      (lambda ()
        (or left
            (let ((osd (make-channel-osd (align 'left))))
              (register-osd osd)
              (set! left osd)
              osd)))

      (lambda ()
        (or right
            (let ((osd (make-channel-osd (align 'right))))
              (register-osd osd)
              (set! right osd)
              osd)))

      (lambda ()
        (when left  (hide-osd (left-osd)))
        (when right (hide-osd (right-osd)))))))

(define (show-sound-osd osd snd title)
  (let ((volume (sound-volume snd))
        (mute?  (sound-mute?  snd)))
    (show-in-osd osd
      (line0   (format #f "~a: ~d%" title volume))
      (line1   volume)
      (color   (if mute? %color-off   %color-on))
      (timeout (if mute? %timeout-off %timeout-on)))))

(define (sound->lisp snd)
  (list (sound-volume snd)
        (scheme->lisp (not (sound-mute? snd)))))

(define output-sound
  ;; (output-sound SOUND [SHOW-OSD?])
  ;;
  ;; Return SOUND value in Lisp format.  SHOW-OSD? defines if OSD
  ;; with the sound value should be displayed or not.
  (case-lambda
    ((snd)
     (output-sound snd #t))
    ((snd show-osd?)
     (match snd
       (#f (display-error-in-main-osd "Cannot obtain sound value"))
       ((? sound? snd)
        (when show-osd?
          (hide-left-right-osds)
          (show-sound-osd (main-osd) snd "Sound"))
        (sound->lisp snd))
       ((snd)
        (output-sound snd show-osd?))
       ((left-snd right-snd)
        (when show-osd?
          (hide-osd (main-osd))
          (show-sound-osd (left-osd)  left-snd "Left")
          (show-sound-osd (right-osd) right-snd "Right"))
        (list (sound->lisp left-snd)
              (sound->lisp right-snd)))
       (sounds
        (when show-osd?
          (hide-left-right-osds)
          (let ((volumes (mapconcat
                          (lambda (snd)
                            (number->string
                             (if (sound-mute? snd) 0 (sound-volume snd))))
                          sounds
                          ", ")))
            (show-in-osd (main-osd)
              (line0   (format #f "Sound: ~a%" volumes))
              (color   %color-on)
              (timeout %timeout-on))))
        (map sound->lisp sounds))))))

(define (sound* . args)
  (let-values (((snd ignore)
                (apply set-sound args)))
    snd))

(define (help-string)
  (string-append
   "sound [ARGS ...]

Update sound according to ARGS and show sound OSD.

Print the current sound value to standard output.
This value has (VOLUME ON) form, where

  VOLUME is a percentage integer (can be greater than 100).

  ON is a boolean value in Lisp format (nil or t) showing if the sound
  is on or off (muted).

ARGS have one of the following forms:

  show

    Return the current sound value and show OSD; this is the default
    action (performed if no ARGS are specified).

  get

    Return the current sound value and do not show OSD (this is the
    only form that does not show OSD).

  [set] VALUES ...

    Set sound to VALUES (\"set\" keyword is optional).

    If VALUES consists of a single value, it is used to set all
    channels.  Otherwise, VALUES are used to set per-channel volumes.

    Each value should have one of the following forms:

      on          Unmute (turn sound on).

      off         Mute (turn sound off).

      toggle      Toggle mute state.

      keep        Do nothing for this channel.

      [s]N form, where

        \"N\" is a volume percentage (can be greater than 100),

        \"s\" is an optional sign i.e., \"s\" is either:

          \"+\": to increase sound by N,
          \"-\": to decrease sound by N,
          empty string: to set sound to N.

        Examples: \"70\", \"+3\", \"-10\".

  backend NAME

    Change backend to NAME.
    Available backends: "
   (mapconcat backend-name (backends) ", ")
   ".\n"))

(define (osd-sound . args)
  (match args
    ((or () ("show"))
     (output-sound (sound*) #t))
    (("get")
     (output-sound (sound*) #f))
    (("set" args …)
     (output-sound (apply sound* args)))
    (("backend" name)
     (if-let ((b (backend-by-name name)))
       (begin
         (current-backend b)
         (show-main-osd (line0 "Sound backend:")
                        (line1 (or (backend-description b) name))
                        (color %color-on)
                        (timeout 7)))
       (display-error-in-main-osd
        (format #f "Unknown sound backend: ~a" name)))
     name)
    (("help") (help-string))
    (· (output-sound (apply sound* args)))))

;;; sound.scm ends here
