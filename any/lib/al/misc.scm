;;; misc.scm --- Miscellaneous utilities

;; Copyright © 2016–2026 Alex Kost

;; Author: Alex Kost <alezost@gmail.com>

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This file provides various procedures that do not suit any other
;; module.

;; The following procedures originate from Guix source code:
;;
;; - split-path: `search-path-as-string->list' from (guix build utils)
;; - memoize: from (guix combinators)
;; - remove-keywords: `strip-keyword-arguments' from (guix utils).

;;; Code:

(cond-expand
  (guile
   (define-lazy null-port
     (%make-void-port "w"))

   (define* (set-locale #:optional (locale ""))
     "Call (setlocale LC_ALL LOCALE) and ignore errors."
     (catch #t
       (lambda _ (setlocale LC_ALL locale))
       (lambda (_ . args)
         (apply display-error #f (current-error-port) args))))

   (define (remove-keywords args . keywords)
     "Remove keyword/value pairs from ARGS.

If KEYWORDS are specified, remove only these keywords.  Otherwise,
remove all KEYWORDS.

This function exists because when a procedure is defined using both
#:key and #:rest keywords, then the rest argument also contains all the
key/value pairs.  See `(guile) lambda* and define*' node in the Guile
info manual."
     (let loop ((args args)
                (result '()))
       (match args
         (() (reverse result))
         (((? keyword? keyword) value . rest)
          (loop rest
                (if (or (null? keywords)
                        (memq keyword keywords))
                  result
                  (cons* value keyword result))))
         ((arg rest …)
          (loop rest (cons arg result)))))))

  (chicken
   (define-lazy null-port
     (make-output-port ignore ignore))

   (define getenv get-environment-variable)

   (define (log10 n)
     (/ (log n) (log 10))))

  (chez
   (define-lazy null-port
     (make-output-port ignore ""))

   (define (log10 n)
     (log n 10)))

  (else))

(cond-expand
  (chicken
   (define (fixed-width-format-string width)
     ;; `format' from (chicken format) does not support fixed-width
     ;; format strings, so use SRFI-48 `format' (which uses "~5F"
     ;; instead of "~5d").
     (string-append "~" (number->string width) "F")))
  (else
   (define (fixed-width-format-string width)
     (string-append "~" (number->string width) "d"))))

(define (memoize proc)
  ;; Return a memoizing version of PROC.
  (let ((alist '()))
    (lambda args
      (if-let ((results (assoc-get args alist)))
        (apply values results)
        (let ((results (call-with-values
                           (lambda () (apply proc args))
                         list)))
          (set! alist
                (cons (cons args results)
                      alist))
          (apply values results))))))

(define-syntax-rule (with-no-output body ...)
  ;; Do not display any output while running BODY.
  (let ((null (null-port)))
    (parameterize ((current-output-port null)
                   (current-error-port  null))
      body ...)))

(define split-path
  ;; (split-path [PATH] [SEPARATOR])
  ;;
  ;; Split PATH string into a list of substrings with SEPARATOR.

  ;; XXX (split-path "a::b") returns ("a" "b") instead of ("a" "" "b").
  (case-lambda
    (()
     (split-path (getenv "PATH")))
    ((path)
     (split-path path #\:))
    ((path separator)
     (split-string path separator))))

(define (scheme->lisp value)
  ;; Convert Scheme value to Lisp value.
  (case value
    ((#t) 't)
    ((#f) '())
    (else value)))

(define (digits integer)
  ;; Return the number of digits in INTEGER.
  (cond
   ((>0 integer)
    (inc (inexact->exact (floor (log10 integer)))))
   ((=0 integer) 1)
   (else (digits (- integer)))))

(define (format-index index total)
  ;; Return string showing INDEX of TOTAL values.
  ;; INDEX and TOTAL should be positive integers.
  (let ((fmt (string-append "["
                            (fixed-width-format-string (digits total))
                            " of ~d]")))
    (format #f fmt index total)))

;;; misc.scm ends here
