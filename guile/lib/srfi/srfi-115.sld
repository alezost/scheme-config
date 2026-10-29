;;; srfi-115.sld --- R7RS Regexp library

(define-library (srfi 115)
  (export regexp regexp? valid-sre? rx regexp->sre char-set->sre
          regexp-matches regexp-matches? regexp-search
          regexp-replace regexp-replace-all
          regexp-fold regexp-extract regexp-split regexp-partition
          regexp-match? regexp-match-count
          regexp-match-submatch regexp-match-submatch/list
          regexp-match-submatch-start regexp-match-submatch-end
          regexp-match->list regexp-match->sexp)

  (import (scheme base)
          (scheme char)
          (only (srfi 1) any every)
          (srfi 14)
          (srfi 60)
          (srfi 69)
          ;; Cannot use (srfi 115 boundary) here: compilation fails in
          ;; this case.
          (srfi srfi-115 boundary))

  (include "srfi-115.scm"))

;;; srfi-115.sld ends here
