;;; srfi-115.sls --- R6RS Regexp library

(library (srfi :115)
  (export regexp regexp? valid-sre? rx regexp->sre char-set->sre
          regexp-matches regexp-matches? regexp-search
          regexp-replace regexp-replace-all
          regexp-fold regexp-extract regexp-split regexp-partition
          regexp-match? regexp-match-count
          regexp-match-submatch regexp-match-submatch/list
          regexp-match-submatch-start regexp-match-submatch-end
          regexp-match->list regexp-match->sexp)

  (import (except (rnrs)
                  error
                  define-record-type
                  string-ci-hash string-hash)
          (only (rnrs r5rs) quotient)
          (rnrs mutable-pairs)
          (only (chezscheme) include)
          (only (srfi :1) any every)
          (srfi :9)
          (srfi :14)
          (srfi :23)
          (srfi :69)
          (srfi :115 boundary))

  (include "srfi-115.scm"))

;;; srfi-115.sls ends here
