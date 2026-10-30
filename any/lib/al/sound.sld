;;; sound.sld --- R7RS library with sound utilities

(define-library (al sound)
  (export sound
          sound?
          sound-volume
          sound-state
          get-sound
          set-sound
          increase-volume
          decrease-volume)

  (import (scheme base)
          (srfi 115)
          (drecords)
          (aux-utils)
          (let-macros)
          (al processes))

  (cond-expand
    (guile
     (import (only (rnrs) filter)
             (ice-9 format)))
    (else))

  (include "sound.scm"))

;;; sound.sld ends here
