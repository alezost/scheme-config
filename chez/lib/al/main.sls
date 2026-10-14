(library (al main)
  (export define-syntax-rule
          define-lazy
          push!
          0? 1+ 1-)
  (import (rnrs)
          (rnrs r5rs)           ; for `force'/`delay'
          (only (chezscheme)
                include add1 sub1)
          (srfi :0))

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
