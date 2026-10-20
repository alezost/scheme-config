(library (srfi :23)
  (export error)
  (import (rename (rnrs base) (error rnrs/error)))

  (define (error . args)
    (apply rnrs/error #f args)))
