;;; sound.sls --- R6RS library with sound utilities

(library (al sound)
  (export sound
          sound?
          sound-volume
          sound-mute?
          backend
          backend?
          backend*
          backends
          register-backend
          backend-by-name
          backend-name
          backend-description
          backend-getter
          backend-setter
          current-backend
          be/amixer
          be/alsa
          be/pactl
          be/pulse
          get-sound
          set-sound
          increase-volume
          decrease-volume)

  (import (rnrs)
          (only (chezscheme)
                include format reverse!
                make-list
                ;; define-values
                make-parameter parameterize)
          (srfi :26)
          (srfi :115)
          (match)
          (aalists)
          (drecords)
          (pulseaudio)
          (aux-utils)
          (let-macros)
          (al misc)
          (al lists)
          (al messages)
          (al processes))

  (include "sound.scm")
  (include "sound.chez.scm"))

;;; sound.sls ends here
