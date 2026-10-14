;;; main.scm --- Main utilities

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
;; code.  It should have minimal number of dependencies, ideally,
;; nothing more than `code-expand' (SRFI-0) and `match'.

;;; Code:

(define-module (al main)
  #:export (define-lazy))

(define-syntax-rule (define-lazy1 name doc body ...)
  (define name
    (let ((value (delay (begin body ...))))
      (lambda () doc (force value)))))

(define-syntax define-lazy
  (lambda (x)
    "Define NAME thunk that will evaluate BODY once (on the first call).
NAME will return result of the first evaluation on subsequent calls
without re-evaluating BODY.

  (define-lazy NAME [DOC] BODY ...)"
    (syntax-case x ()
      ((_ name doc body ...)
       (string? (syntax->datum #'doc))
       #'(define-lazy1 name doc body ...))
      ((_ name body ...)
       #'(define-lazy1 name #f body ...)))))

;;; main.scm ends here
