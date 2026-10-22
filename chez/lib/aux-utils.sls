;;; aux-utils.sls --- Chez library for auxiliary utilities

;; Without this (#!r6rs is used by default), Chez complains on `1+' and
;; `1-' names.
#!chezscheme

(library (aux-utils)
  (export identity const ignore
          negate compose-left
          and=> and<=
          define-syntax-rule
          define-lazy
          parse-arg-syntax
          push!
          not-null?
          assq-get assv-get assoc-get
          =0 >0 <0 1+ 1-)
  (import (rnrs)
          (only (chezscheme)
                include
                syntax->list
                add1 sub1)
          (match)
          (srfi :0)
          (srfi :26))
  (include "aux-utils.chez.scm")
  (include "aux-utils.scm"))

;;; aux-utils.sls ends here
