(define-library (aalists)
  (export make-aalist
          aalist-get
          aalist-set!
          aalist-value)
  (import (scheme base)
          (scheme case-lambda)
          (match)
          (aux-utils)
          (let-macros))
  (include "aalists.code.scm"))
