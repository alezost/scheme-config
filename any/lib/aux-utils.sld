;;; aux-utils.sld -- Important auxiliary utilities

(define-library (aux-utils)
  (export identity const
          negate compose-left
          and=> and<=
          define-lazy
          push!
          not-null?
          assq-get assv-get assoc-get
          =0)

  (cond-expand
    (guile
     (import (guile))
     (begin (re-export define-syntax-rule
                       1+ 1-)))

    (chicken
     (export define-syntax-rule
             1+ 1-)
     (import (scheme base)
             (only (chicken base) add1 sub1)
             (chicken syntax))
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
                   (,(rename 'begin) ,@body))))))))))))
  (include "aux-utils.code.scm"))

;;; aux-utils.sld ends here
