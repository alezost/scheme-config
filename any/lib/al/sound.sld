;;; sound.sld --- R7RS library with sound utilities

(define-library (al sound)
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
          get-sound
          set-sound
          increase-volume
          decrease-volume)

  (import (scheme base)
          (scheme case-lambda)
          (only (srfi 1) find)
          (srfi 11)
          (srfi 26)
          (srfi 115)
          (match)
          (aalists)
          (drecords)
          (aux-utils)
          (let-macros)
          (al misc)
          (al lists)
          (al messages)
          (al processes))

  (cond-expand
    (guile
     (import (only (rnrs) filter)
             (rnrs arithmetic fixnums)
             (only (guile) reverse!)
             (ice-9 format)))
    (else))

  (include "sound.scm"))

;;; sound.sld ends here
