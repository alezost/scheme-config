(define-library (al fp-utils)
  (export identity const
          negate compose-left
          and=> and<=)
  (import (scheme base))
  (include "fp-utils.scm"))
