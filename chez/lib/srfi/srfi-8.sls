(library (srfi :8)
  (export receive)
  (import (rnrs))

  ;; Taken from <https://srfi.schemers.org/srfi-8/srfi-8.html>.
  (define-syntax receive
    (syntax-rules ()
      ((receive formals expression body ...)
       (call-with-values (lambda () expression)
         (lambda formals body ...))))))
