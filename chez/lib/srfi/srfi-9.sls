;;; srfi-9.sls --- Defining record types

;; Copyright (c) 2010 Derick Eddington

;; Permission is hereby granted, free of charge, to any person obtaining a
;; copy of this software and associated documentation files (the "Software"),
;; to deal in the Software without restriction, including without limitation
;; the rights to use, copy, modify, merge, publish, distribute, sublicense,
;; and/or sell copies of the Software, and to permit persons to whom the
;; Software is furnished to do so, subject to the following conditions:
;;
;; The above copyright notice and this permission notice shall be included in
;; all copies or substantial portions of the Software.
;;
;; Except as contained in this notice, the name(s) of the above copyright
;; holders shall not be used in advertising or otherwise to promote the sale,
;; use or other dealings in this Software without prior written authorization.
;;
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
;; THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
;; FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
;; DEALINGS IN THE SOFTWARE.

;;; Commentary:

;; This file originates from
;; <https://github.com/arcfide/chez-srfi/blob/master/%253a9/records.sls>.

;;; Code:

(library (srfi :9)
  (export (rename (srfi-9/define-record-type
                   define-record-type)))
  (import (rnrs))

  (define-syntax srfi-9/define-record-type
    (lambda (stx)
      (syntax-case stx ()
        ((_ type (constructor constructor-tag ...)
            predicate
            (field-tag accessor setter ...) ...)
         (and (for-all identifier?
                       #'(type constructor constructor-tag ... predicate
                          field-tag ... accessor ... setter ... ...))
              (for-all (lambda (s) (<= 0 (length s) 1))
                       #'((setter ...) ...))
              (for-all (lambda (ct)
                         (memp (lambda (ft) (bound-identifier=? ct ft))
                               #'(field-tag ...)))
                       #'(constructor-tag ...)))
         (with-syntax (((field-clause ...)
                        (map (lambda (clause)
                               (if (= 2 (length clause))
                                 #`(immutable . #,clause)
                                 #`(mutable . #,clause)))
                             #'((field-tag accessor setter ...) ...)))
                       ((unspec-tag ...)
                        (remp (lambda (ft)
                                (memp (lambda (ct) (bound-identifier=? ft ct))
                                      #'(constructor-tag ...)))
                              #'(field-tag ...))))
           #'(define-record-type (type constructor predicate)
               (protocol (lambda (ctor)
                           (lambda (constructor-tag ...)
                             (define unspec-tag) ...
                             (ctor field-tag ...))))
               (fields field-clause ...))))))))

;;; srfi-9.sls ends here
