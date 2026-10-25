;;; backlight.sld --- R7RS library with backlight utilities

(define-library (al backlight)
  (export backlight-available?
          get-backlight
          set-backlight
          increase-backlight
          decrease-backlight)
  (import (guile)
          (aux-utils)
          (let-macros)
          (al files))
  (include "backlight.scm"))

;;; backlight.sld ends here
