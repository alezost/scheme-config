(define-library (srfi 0 aux)
  (export feature-available?)
  (import (rnrs))

  (begin
    (define (feature-available? feature)
      (memq feature '(loko r6rs)))))
