;;; aux-utils.sls --- Chez library for auxiliary utilities

(library (aux-utils)
  (export identity const
          negate compose-left
          and=> and<=
          define-syntax-rule
          define-lazy
          push!
          assq-get assv-get assoc-get
          =0 1+ 1-)
  (import (rnrs)
          (only (chezscheme)
                include
                add1 sub1)
          (srfi :0))
  (include "aux-utils.chez.scm")
  (include "aux-utils.scm"))

;;; aux-utils.sls ends here
