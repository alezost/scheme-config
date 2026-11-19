(library (srfi :0 aux)
  (export feature-available?)
  (import (rnrs))

  (define (feature-available? feature)
    (memq feature '(chez r6rs))))
