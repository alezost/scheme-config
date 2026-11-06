;;; aux-utils.sls --- R6RS library with auxiliary utilities

(library (aux-utils)
  (export identity ->bool const ignore
          integer->bool
          bool->integer
          negate compose-left
          and=> and<=
          with-error->false
          define-syntax-rule
          define-lazy
          parse-arg-syntax
          push!
          not-null?
          assq-get assv-get assoc-get
          =0 >0 <0 inc dec)
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
