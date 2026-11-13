;;; aalists.scm --- Augmented association lists

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

;; This file provides a key/value data structure, called "augmented
;; association list", which is a simple wrapper for a usual alist
;; structure.  Use `make-aalist', `aalist-get', and `aalist-set!'
;; procedures to make/get/set key/value pairs.  No need for multiple
;; getters/setters (`assq-ref', `assv-ref', etc.) and no need to call
;; `set!' after updating alist.

;; Alists are great but updating them (setting a new key/value pair) is
;; not convenient.  You have to do something like this:
;;
;;   (set! alist (assq-set! 'foo "hello" alist))
;;
;; or this:
;;
;;   (set! alist (cons (cons 'foo "hello") alist))
;;
;; Wouldn't it be better to just call `assq-set!' without a need to
;; `set!' the alist variable?  With a usual alist, this is not possible
;; because a new key/value pair is prepended to the old alist, so old
;; alist variable will still point to the old alist (without the new
;; pair).
;;
;; A solution is to augment alist with an additional element in `car'
;; and putting alist itself in the `cdr'.  "aalist" does exactly this.
;; It uses entry-finding procedure (`assq', `assv', or `assoc') as the
;; additional element.  I.e., "aalist" has (PROC . ALIST) form.  PROC is
;; used once, on aalist creation and cannot be changed.  This allows us
;; to use only one "get" and one "set" procedure (no need for
;; `assq-set!', `assoc-set!', etc.).

;; You can use the following procedures to work with aalists:
;;
;; - `make-aalist'
;;
;;   (make-aalist PROC [ALIST])
;;
;;   Return a new aalist using entry-finding PROC (`assq' or similar).
;;   ALIST is an empty list by default.
;;
;; - `aalist-get'
;;
;;   (aalist-get AALIST KEY)
;;
;;   Return KEY value from AALIST.
;;   Return #f if AALIST does not contain KEY/value pair.
;;
;; - `aalist-set!'
;;
;;   (aalist-set! AALIST KEY VALUE)
;;
;;   Associate VALUE with KEY in AALIST (create KEY if needed).
;;
;; - `aalist-value'
;;
;;   (aalist-value AALIST KEY [VALUE])
;;
;;   This is a wrapper for `aalist-get' and `aalist-set!'.
;;   It gets or sets depending on whether the optional argument
;;   VALUE is specified or not.

;; Example:
;;
;;   (define a (make-aalist assv))
;;   (aalist-get a 1)         ; => #f
;;   (aalist-set! a 1 "one")
;;   (aalist-get a 1)         ; => "one"
;;   (aalist-value a 2 "two")
;;   (aalist-set! a "three" 3)
;;   a  ; => (#<procedure assv> ("three" . 3) (2 . "two") (1 . "one"))
;;   (aalist-get a "three")    ; => #f
;;
;; The last expression returns #f since `assv' does not handle strings.
;; If you planned to use strings as keys, you should have defined `a'
;; using `assoc' procedure.

;;; Code:

(define make-aalist
  (case-lambda
    ((proc)       (cons proc '()))
    ((proc alist) (cons proc alist))))

(define (aalist-get aalist key)
  (match aalist
    ((proc . alist)
     (and=> (proc key alist) cdr))))

(define (aalist-set! aalist key value)
  (match aalist
    ((proc . alist)
     (if-let ((pair (proc key alist)))
        (set-cdr! pair value)
        (set-cdr! aalist (cons (cons key value)
                               alist))))))

(define aalist-value
  (case-lambda
    ((aalist key)
     (aalist-get aalist key))
    ((aalist key value)
     (aalist-set! aalist key value))))

;;; aalists.scm ends here
