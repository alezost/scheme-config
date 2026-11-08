;;; sound.sls --- R6RS library with sound utilities

(library (al sound)
  (export sound
          sound?
          sound-volume
          sound-state
          backend
          backend?
          backend-name
          backend-description
          backend-getter
          backend-setter
          current-backend
          be/amixer
          be/alsa
          get-sound
          set-sound
          increase-volume
          decrease-volume)

  (import (rnrs)
          (only (chezscheme)
                include format
                make-parameter parameterize)
          (srfi :115)
          (drecords)
          (aux-utils)
          (let-macros)
          (al processes))

  (include "sound.scm"))

;;; sound.sls ends here
