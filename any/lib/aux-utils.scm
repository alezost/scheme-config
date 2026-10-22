;;; aux-utils.scm --- Main auxiliary utilities

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

;; This file provides main auxiliary utilities used by my other Scheme
;; code.  Note to myself: it should have minimal number of dependencies,
;; ideally, nothing more than `code-expand' (SRFI-0), `match', and maybe
;; SRFI-26 (`cut').

;;; Code:

(define (identity value)
  value)

(define (const value)
  (lambda args value))

(define ignore (const #f))

(define (negate proc)
  (lambda args
    (not (apply proc args))))

(define (compose-left proc . procedures)
  ;; Compose PROC with PROCEDURES from left to right.
  ;;
  ;; For example,
  ;;
  ;; ((compose-left +
  ;;                (lambda (n) (* 2 n))
  ;;                (lambda (n) (+ 100 n)))
  ;;  1 2 3)
  ;;
  ;; returns 112.
  (if (null? procedures)
    proc
    (lambda args
      (let loop ((procs procedures)
                 (res (apply proc args)))
        (if (null? procs)
          res
          (loop (cdr procs)
                ((car procs) res)))))))

(define (and=> value . procedures)
  ;; Return result of consecutive applying PROCEDURES to VALUE.
  ;;
  ;; More precisely, for a given list of PROCEDURES,
  ;; (PROC1 PROC2 ... PROCn), return #f if:
  ;;
  ;;   VALUE is #f or
  ;;   (PROC1 VALUE) is #f or
  ;;   (PROC2 (PROC1 VALUE)) is #f or
  ;;   ...
  ;;   (PROCn ... (PROC2 (PROC1 VALUE))) is #f.
  ;;
  ;; Otherwise, return (PROCn ... (PROC2 (PROC1 VALUE))).
  (and value
       (if (null? procedures)
         value
         (apply and=> ((car procedures) value)
                (cdr procedures)))))

(define (and<= value . procedures)
  ;; Return VALUE if (PROC VALUE) is not false for all PROCEDURES.
  ;;
  ;; More precisely, for a given list of PROCEDURES,
  ;; (PROC1 PROC2 ... PROCn), return #f if:
  ;;
  ;;   (PROC1 VALUE) is #f or
  ;;   (PROC2 VALUE) is #f or
  ;;   ...
  ;;   (PROCn VALUE) is #f.
  ;;
  ;; Otherwise, return VALUE.
  (and value
       (let loop ((procs procedures))
         (or (null? procs)
             (and ((car procs) value)
                  (loop (cdr procs)))))
       value))

(define-syntax-rule (define-lazy name body ...)
  ;; Define NAME thunk that will evaluate BODY once (on the first call).
  ;; NAME will return result of the first evaluation on subsequent calls
  ;; without re-evaluating BODY.

  ;; Not using delay/force because they require (rnrs r5rs) library for
  ;; R6RS implementation.
  #;(define name
    (let ((value (delay (begin body ...))))
      (lambda () (force value))))
  (define name
    (let ((value #f)
          (called? #f))
      (lambda ()
        (if called?
          value
          (begin
            (set! called? #t)
            (set! value (begin body ...))
            value))))))

(define-syntax-rule (push! elt place)
  ;; Add ELT to the list stored in variable PLACE.
  (set! place (cons elt place)))

(define not-null? (negate null?))

(define (assq-get key alist)
  ;; Having (KEY . VALUE) pairs in ALIST, return VALUE.
  ;; Return #f if there is no such KEY in ALIST.
  (and=> (assq key alist) cdr))

(define (assv-get key alist)
  (and=> (assv key alist) cdr))

(define (assoc-get key alist)
  (and=> (assoc key alist) cdr))

(define =0 zero?)
(define >0 positive?)
(define <0 negative?)

(cond-expand
  ((or chez chicken)
   (define 1+ add1)
   (define 1- sub1))
  (else))

;;; aux-utils.scm ends here
