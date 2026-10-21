;;; srfi-14.sls --- Char-sets library

;; This file originates from
;; <https://github.com/arcfide/chez-srfi/blob/ae05cf3eba25f35236648d7702b7aca9344aa75f/%253a14/char-sets.sls>.
;; XXX Commit
;; <https://github.com/arcfide/chez-srfi/commit/23c1e3529397e14d2d7a685ff3bd8c5c79d34010>
;; changed that library completely to introduce Unicode support.

(library (srfi :14)
  (export
   ;; Exports are taken from the included scm file.
   char-set? char-set= char-set<=
   char-set-hash
   char-set-cursor char-set-ref char-set-cursor-next end-of-char-set?
   char-set-fold char-set-unfold char-set-unfold!
   char-set-for-each char-set-map
   char-set-copy char-set

   list->char-set  string->char-set
   list->char-set! string->char-set!

   char-set-filter  ucs-range->char-set  ->char-set
   char-set-filter! ucs-range->char-set!

   char-set->list char-set->string

   char-set-size char-set-count char-set-contains?
   char-set-every char-set-any

   char-set-adjoin  char-set-delete
   char-set-adjoin! char-set-delete!

   char-set-complement  char-set-union  char-set-intersection
   char-set-complement! char-set-union! char-set-intersection!

   char-set-difference  char-set-xor  char-set-diff+intersection
   char-set-difference! char-set-xor! char-set-diff+intersection!

   char-set:lower-case  char-set:upper-case  char-set:title-case
   char-set:letter      char-set:digit       char-set:letter+digit
   char-set:graphic     char-set:printing    char-set:whitespace
   char-set:iso-control char-set:punctuation char-set:symbol
   char-set:hex-digit   char-set:blank       char-set:ascii
   char-set:empty       char-set:full)

  (import
   (except (rnrs) error define-record-type)
   (rnrs mutable-strings)
   (only (rnrs r5rs) modulo)
   (only (chezscheme) include)
   (srfi :9)
   (srfi :23)
   (lib-aux)
   (let-opt))

  (define %latin1->char integer->char)
  (define %char->latin1 char->integer)

  (include "srfi-14.scm"))

;;; srfi-14.sls ends here
