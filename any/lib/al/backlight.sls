;;; backlight.sls --- R6RS library with backlight utilities

(library (al backlight)
  (export backlight-available?
          get-backlight
          set-backlight
          increase-backlight
          decrease-backlight)
  (import (except (rnrs) with-output-to-file)
          (rnrs r5rs)
          (only (chezscheme)
                include
                with-output-to-file)
          (srfi :0)
          (aux-utils)
          (let-macros)
          (al files))
  (include "backlight.scm"))

;;; backlight.sls ends here
