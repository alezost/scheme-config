;;; srfi-13.sls --- String processing library

(library (srfi :13)
  (export
   ;; Exports are taken from the included scm file.
   string-map string-map!
   string-fold       string-unfold
   string-fold-right string-unfold-right
   string-tabulate string-for-each string-for-each-index
   string-every string-any
   string-hash string-hash-ci
   string-compare string-compare-ci
   string=    string<    string>    string<=    string>=    string<>
   string-ci= string-ci< string-ci> string-ci<= string-ci>= string-ci<>
   string-downcase  string-upcase  string-titlecase
   string-downcase! string-upcase! string-titlecase!
   string-take string-take-right
   string-drop string-drop-right
   string-pad string-pad-right
   string-trim string-trim-right string-trim-both
   string-filter string-delete
   string-index string-index-right
   string-skip  string-skip-right
   string-count
   string-prefix-length string-prefix-length-ci
   string-suffix-length string-suffix-length-ci
   string-prefix? string-prefix-ci?
   string-suffix? string-suffix-ci?
   string-contains string-contains-ci
   string-copy! substring/shared
   string-reverse string-reverse! reverse-list->string
   string-concatenate string-concatenate/shared string-concatenate-reverse
   string-append/shared
   xsubstring string-xcopy!
   string-null?
   string-join
   string-tokenize
   string-replace)

  (import
    (except (rnrs)
            error
            string-upcase string-downcase string-titlecase
            string->list string-for-each
            string-copy string-hash)
    (except (rnrs mutable-strings)
            string-fill!)
    (only (rnrs r5rs) modulo quotient)
    (only (chezscheme) include)
    (srfi :8)
    (srfi :14)
    (srfi :23)
    (lib-aux)
    (let-opt))

  (define (char-cased? c)
    (char-upper-case? (char-upcase c)))

  (include "srfi-13.scm"))

;;; srfi-13.sls ends here
