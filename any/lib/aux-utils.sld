;;; aux-utils.sld --- R7RS library with auxiliary utilities

(define-library (aux-utils)
  (export identity ->bool const ignore
          integer->bool
          bool->integer
          negate compose-left
          and=> and<=
          with-error->false
          define-syntax-rule
          define-lazy
          push!
          not-null?
          assq-get assv-get assoc-get
          assq-set! assv-set! assoc-set!
          =0 >0 <0 inc dec)

  (cond-expand
    (guile
     (import (only (scheme base) guard)
             (guile)))

    (chicken
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
