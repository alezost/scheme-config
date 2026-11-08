;;; misc.sld --- Miscellaneous utilities library

(define-library (al misc)
  (export getenv
          setenv
          call-with-locale
          with-locale
          null-port
          with-no-output
          memoize
          scheme->lisp
          digits
          format-index
          split-path)

  (import (scheme r5rs)
          (scheme process-context)
          (scheme case-lambda)
          (let-macros)
          (aux-utils)
          (al strings))

  (cond-expand
    (guile
     (export set-locale
             remove-keywords)
     (import (guile)
             (ice-9 format)
             (match)))

    (chicken
     (import (scheme base)
             (srfi 48)          ; format
             (chicken process-context)
             (chicken port)))
    (else))

  (include "misc.scm"))

;;; misc.sld ends here
