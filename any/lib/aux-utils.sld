;;; aux-utils.sld --- R7RS library with auxiliary utilities

(define-library (aux-utils)
  (export identity ->bool const ignore
          negate compose-left
          and=> and<=
          with-error->false
          define-lazy
          push!
          not-null?
          assq-get assv-get assoc-get
          =0 >0 <0)

  (cond-expand
    (guile
     (import (only (scheme base) guard)
             (guile))
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
