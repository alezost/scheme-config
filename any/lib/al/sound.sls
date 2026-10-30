;;; sound.sls --- R6RS library with sound utilities

(library (al sound)
  (export sound
          sound?
          sound-volume
          sound-state
          get-sound
          set-sound
          increase-volume
          decrease-volume)

  (import (rnrs)
          (only (chezscheme) include format)
          (srfi :115)
          (drecords)
          (aux-utils)
          (let-macros)
          (al processes))

  (include "sound.scm"))

;;; sound.sls ends here
