(define-library (al lists)
  (export replace
          split
          nth
          map-indexed
          for-each-indexed
          count-indexed)
  (import (scheme base)
          (scheme case-lambda)
          (only (srfi 1)
                remove break)
          (srfi 26)
          (match)
          (aux-utils))
  (include "lists.scm"))
