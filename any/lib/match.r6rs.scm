;;; match.r6rs.scm --- Auxiliary R6RS code for `match' library

;; Copyright (c) 2016 Federico Beffa <beffa@fbengineering.ch>

;; Permission to use, copy, modify, and distribute this software for
;; any purpose with or without fee is hereby granted, provided that the
;; above copyright notice and this permission notice appear in all
;; copies.
;;
;; THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
;; WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
;; WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE
;; AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL
;; DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA
;; OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
;; TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
;; PERFORMANCE OF THIS SOFTWARE.

;;; Commentary:

;; This file originates from
;; <https://github.com/fedeinthemix/chez-matchable/blob/master/matchable.sls>.
;; It provides several auxiliary utils to make `match' library work with
;; R6RS records.

;;; Code:

(define-syntax is-a?
  (syntax-rules ()
    ((_ rec rtn)
     (let ((rec: rec))
       (and (record? rec:)
            (eq? (record-type-name (record-rtd rec:))
                 (quote rtn)))))))

(define-syntax slot-ref
  (syntax-rules ()
    ((_ rtn rec n)
     (let ((n: n) (rec: rec))
       (if (number? n:)
         ((record-accessor (record-rtd rec:) n:) rec:)
         ;; If it's not a number, then it should be a symbol with
         ;; the name of a field.
         (let* ((rtd (record-rtd rec:))
                (fields (record-type-field-names rtd))
                (fields-idxs (map cons
                                  (vector->list fields)
                                  (iota (vector-length fields))))
                (idx (cdr (assv n: fields-idxs))))
           ((record-accessor rtd idx) rec:)))))))

(define-syntax slot-set!
  (syntax-rules ()
    ((_ rtn rec n val)
     (let ((n: n) (rec: rec))
       (if (number? n:)
         ((record-mutator (record-rtd rec:) n) rec: val)
         ;; If it's not a number, then it should be a symbol with
         ;; the name of a field.
         (let* ((rtd (record-rtd rec:))
                (fields (record-type-field-names rtd))
                (fields-idxs (map cons
                                  (vector->list fields)
                                  (iota (vector-length fields))))
                (idx (cdr (assv n: fields-idxs))))
           ((record-mutator rtd idx) rec: val)))))))

;;; match.r6rs.scm ends here
