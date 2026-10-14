(define-library (al main)
  (export define-syntax-rule
          define-lazy)
  (import (scheme base))

  (begin
    (import-for-syntax (match))
    (define-syntax define-syntax-rule
      (er-macro-transformer
       (lambda (expr rename compare)
         (match expr
           ((· (name args …) body …)
            `(,(rename 'define-syntax) ,name
              (,(rename 'syntax-rules) ()
               ((,(rename '_) ,@args)
                (,(rename 'begin) ,@body))))))))))
  (include "main.scm"))
