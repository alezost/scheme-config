;;; match.sld -- R7RS library definition for (match) library

;;; Commentary:

;; Auxiliary definitions (`slot-ref', etc.) are taken from:
;;
;;  - "match.scm" from the Guile source code:
;;    <https://codeberg.org/guile/guile/src/branch/main/module/ice-9/match.scm>.
;;
;;  - "matchable.scm" from the Chicken eggs repository:
;;    <git://code.call-cc.org/eggs-6-latest>.

(define-library (match)
  (export match
          match-lambda
          match-lambda*
          match-let
          match-let*
          match-letrec)
  (import (scheme base))

  (cond-expand
    (chicken
     (import
       (chicken base)
       (chicken memory representation))
     (begin
       (import-for-syntax (chicken keyword))
       (define-syntax slot-ref
         ;; Return Nth field of the record REC.  N might be a quoted symbol
         ;; indicating a field name, we have to reject it since Chicken
         ;; doesn't carry any information about the field names.
         (syntax-rules ()
           ((_ type rec n)
            (if (fixnum? n)
              (record-instance-slot rec n)
              (error "Accessing fields by name is not supported")))))
       (define-syntax slot-set!
         ;; Set the value of Nth field of the record REC to VAL.
         (syntax-rules ()
           ((_ type rec n val)
            (record-instance-slot-set! rec n val))))
       (define-syntax is-a?
         ;; Return #t if REC is a record with TYPE name.
         ;; Return #f otherwise.
         (syntax-rules ()
           ((_ rec type)
            (record-instance? rec type))))))

    (guile
     (begin
       (define-syntax slot-ref
         (syntax-rules ()
           ((_ type rec n)
            (struct-ref rec n))))
       (define-syntax slot-set!
         (syntax-rules ()
           ((_ type rec n value)
            (struct-set! rec n value))))
       (define-syntax is-a?
         (syntax-rules ()
           ((_ rec type)
            (and (struct? rec)
                 (eq? (struct-vtable rec) type))))))))

  (include "match.code.scm"))

;;; match.sld ends here
