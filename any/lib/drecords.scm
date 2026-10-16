;;; drecords.scm --- Declarative records library

;; Copyright © 2026 Alex Kost <alezost@gmail.com>

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

#|

Most (all?) record libraries provide records with positional style of
specifying fields, i.e., something like this:

(define-record point (x y z))
(define p1 (make-point 1 2 3))     ; x/y/z are specified positionally

But this becomes very inconvenient when there are many fields or some of
them are optional.  Declarative style of specifying fields would look
like this:

(define p1
  (make-point (z 3) (x 1) (y 2)))  ; x/y/z are specified declaratively

This library does exactly this.  It provides `define-drecord' macro to
define declarative-style records.  Example:

(define-drecord package
  name version doc dependencies)

Here, we have defined `package' record with `name', `version', `doc',
and `dependencies' fields.   Now we can use `package' syntax to define
packages declaratively like this:

(define foo
  (package
    (name "foo")
    (version "3.14")
    (dependencies '("bar1" "bar2"))))

We can use `package-FIELD' procedures to get or set field values (all
fields are mutable).  If a field was omitted during package declaration,
its value is #f:

(package-name foo)                  ; returns "foo"
(package-name foo "real-foo")       ; returns "real-foo" (new name)
(package-name foo)                  ; returns "real-foo"
(package-doc foo)                   ; returns #f (default value)

Finally, there is `package?' predicate to check if something is a
package or not:

(package? foo)          ; #t
(package? "foo")        ; #f


This library is inspired by Guix declarative records:
<https://codeberg.org/guix/guix/src/branch/master/guix/records.scm>,
although the code of this library is completely different (Guix provides
much more sophisticated record types).

This library is based on (rnrs records syntactic) library.
An expression like this:

(define-drecord package
  name version doc dependencies)

roughly expands to the following code:

(define-record-type <package>
  (fields (mutable name)
          (mutable version)
          (mutable doc)
          (mutable dependencies)))

(define package? <package>?)

(define package-FIELD           ; for every FIELD
  (case-lambda
    ((obj)     (<package>-FIELD obj))
    ((obj val) (<package>-FIELD-set! obj val) val)))

(define-syntax package
  ;; Some wrapper that eventually calls
  (make-<package> name version doc dependencies))

|#

;;; Code:

(define-syntax define-drecord
  (lambda (x)
    (syntax-case x ()
      ((ddr name field ...)
       (let* ((d->s            (lambda (d) (datum->syntax #'ddr d)))
              (name-sym        (syntax->datum #'name))
              (name-str        (symbol->string name-sym))
              (name?-str       (string-append name-str "?"))
              (<name>-str      (string-append "<" name-str ">"))
              (<name>?-str     (string-append "<" name-str ">?"))
              (make-<name>-str (string-append "make-<" name-str ">"))
              (name?-sym       (string->symbol name?-str))
              (<name>-sym      (string->symbol <name>-str))
              (<name>?-sym     (string->symbol <name>?-str))
              (make-<name>-sym (string->symbol make-<name>-str)))
         (syntax-case
             (map (lambda (fld-stx)
                    (let* ((fld-sym (syntax->datum fld-stx))
                           (fld-str (symbol->string fld-sym))
                           (g/s-str (string-append name-str "-" fld-str))
                           (get-str (string-append <name>-str "-" fld-str))
                           (set-str (string-append get-str "-set!"))
                           (g/s-sym (string->symbol g/s-str))
                           (get-sym (string->symbol get-str))
                           (set-sym (string->symbol set-str)))
                      (list (d->s g/s-sym)
                            (d->s get-sym)
                            (d->s set-sym))))
                  (syntax->list #'(field ...)))
             ()
           (((field-get/set
              field-get
              field-set) ...)
            (with-syntax
                ((name?       (d->s name?-sym))
                 (<name>      (d->s <name>-sym))
                 (<name>?     (d->s <name>?-sym))
                 (make-<name> (d->s make-<name>-sym)))
              #'(begin
                  (define-record-type <name>
                    (fields (mutable field) ...))

                  (define name? <name>?)

                  (define field-get/set
                    (case-lambda
                      ((obj)     (field-get obj))
                      ((obj val) (field-set obj val) val)))
                  ...

                  (define-syntax name
                    (lambda (x)
                      (syntax-case x ()
                        ((name (fld val) (... ...))
                         (let ((alist (map (lambda (f v)
                                             (cons (syntax->datum f)
                                                   (syntax->datum v)))
                                           #'(fld (... ...))
                                           #'(val (... ...)))))
                           (with-syntax
                               (((args (... ...))
                                 (map (lambda (f)
                                        (datum->syntax
                                         #'name
                                         (let* ((f (syntax->datum f))
                                                (a (assq f alist)))
                                           (and a (cdr a)))))
                                      (syntax->list #'(field ...)))))
                             #'(make-<name> args (... ...)))))))))))))))))

;;; drecords.scm ends here
