(define-library (drecords)
  (export define-drecord)
  (import (rnrs)
          (rnrs syntax-case)
          (rnrs records syntactic)
          (match)
          (only (scheme base) include))

  (begin
    ;; Taken from Chez manual.
    (define syntax->list
      (lambda (ls)
        (syntax-case ls ()
          (() '())
          ((x . r) (cons #'x (syntax->list #'r)))))))

  (include "drecords.scm"))
