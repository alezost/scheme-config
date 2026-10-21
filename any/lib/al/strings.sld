(define-library (al strings)
  (export string->bool
          string-trim-left
          string-trim-right
          string-trim-both
          mapconcat
          comma-separated
          min-string)
  (import (scheme base)
          (scheme case-lambda)
          (only (srfi 1) fold reduce)
          (srfi 13)
          (match)
          (aux-utils))
  (cond-expand
    (guile (import (ice-9 format)))
    (chicken (import (chicken format)))
    (else))
  (include "strings.scm"))
