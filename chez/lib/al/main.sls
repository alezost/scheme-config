(library (al main)
  (export define-lazy)
  (import (rnrs)
          (rnrs r5rs)           ; for `force'/`delay'
          (only (chezscheme) include))
  (include "main.scm"))
