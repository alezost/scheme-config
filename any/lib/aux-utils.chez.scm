;;; aux-utils.chez.scm --- Auxiliary utilities specific to Chez

;; Copyright © 2026 Alex Kost

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

;; This file is separated from "aux-utils.scm" because Chicken cannot
;; read "#'", so putting these definitions inside cond-expand of
;; "aux-utils.scm" will make Chicken fail on reading this file.

;;; Code:

(define-syntax define-syntax-rule
  (lambda (x)
    (syntax-case x ()
      ((_ (name args ...) body ...)
       (with-syntax (((a ...) #'(args ...))
                     ((b ...) #'(body ...)))
         #'(define-syntax name
             (syntax-rules ()
               ((_ a ...)
                (begin b ...)))))))))

(define (parse-args keys args)
  ;; Helper for `parse-arg-syntax'.
  (let loop ((args (syntax->list args))
             (kv-alist '())
             (rest '()))
    (match args
      (()
       (append (map (cut assq-get <> kv-alist) keys)
               (list rest)))
      ((arg more-args …)
       (match (syntax->list arg)
         ((key value)
          (let ((key (syntax->datum key)))
            (if (memq key keys)
              (loop more-args
                    (cons (cons key value)
                          kv-alist)
                    rest)
              (loop more-args
                    kv-alist
                    (cons arg rest))))))))))

(define-syntax-rule (parse-arg-syntax keys args clause ...)
  ;; This syntax is intended to be used by `syntax-case' definitions to
  ;; extract some values from ARGS.
  ;;
  ;; KEYS is a (KEY1 KEY2 …) list of key names (symbols).
  ;; ARGS is a syntax containing alist of (KEY VALUE) elements
  ;;      (not (KEY . VALUE) elements).
  ;;
  ;; `syntax-case' CLAUSEs should match (VALUE1 VALUE2 … REST-ARGS)
  ;; pattern, where VALUE1, VALUE2, … are taken from ARGS alist using
  ;; KEY1, KEY2, … keys.  REST-ARGS are ARGS with removed KEYS
  ;; elements.
  (syntax-case (parse-args keys args) ()
    clause ...))

;;; aux-utils.chez.scm ends here
