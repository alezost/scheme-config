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

(define-syntax define-lazy
  ;; Define NAME thunk that will evaluate BODY once (on the first call).
  ;; NAME will return result of the first evaluation on subsequent calls
  ;; without re-evaluating BODY.
  (syntax-rules ()
    ((_ name body ...)
     (define name
       (let ((value (delay (begin body ...))))
         (lambda () (force value)))))))

(define-syntax-rule (push! elt place)
  ;; Add ELT to the list stored in variable PLACE.
  (set! place (cons elt place)))

;;; main.scm ends here
