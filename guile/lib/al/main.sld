(define-library (al main)
  (export define-lazy
          push!
          0?)
  (cond-expand
    ((not guile)
     (export 1+ 1-))
    (else))
  (import (guile))
  (include "main.scm"))
