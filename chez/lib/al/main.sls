(library (al main)
  (export define-syntax-rule
          define-lazy
          push!)
  (import (rnrs)
          (rnrs r5rs)           ; for `force'/`delay'
          (only (chezscheme) include))

  (define-syntax define-syntax-rule
    (lambda (x)
      (syntax-case x ()
        ((_ (name args ...) body ...)
         (with-syntax (((a ...) #'(args ...))
                       ((b ...) #'(body ...)))
           #'(define-syntax name
               (syntax-rules ()
                 ((_ a ...)
                  (begin b ...)))))))))
  (include "main.scm"))
