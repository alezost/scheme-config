;;; osd.scm --- Common utils and settings used by the other OSD modules

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

;;; Code:

(define %color-on "#23B13E")
(define %color-off "#E74F35")
(define %color-error "orange")

(define-osd main-osd
  (lines 2)
  (timeout 3)
  (bar-length 50)
  (align 'center)
  (position 'bottom)
  (font "-*-dejavu sans-bold-r-normal-*-*-320-*-*-p-*-*")
  (shadow-offset 2)
  (vertical-offset 10))

(define display-in-main-osd
  ;; (display-in-main-osd LINE0 LINE1)
  ;;
  ;; Display LINE0 and LINE1 in main OSD.
  ;;
  ;; LINE0 / LINE1 can be a string (for `display-string-in-osd') or
  ;; a number (for `display-percentage-in-osd').
  (let ((show (lambda (osd str-or-num line)
                (match str-or-num
                  ((? string? str)
                   (display-string-in-osd osd str line))
                  ((? number? num)
                   (display-percentage-in-osd osd num line))
                  (else
                   (display-string-in-osd
                    osd
                    (format #f "'~a' must be a number/string"
                            str-or-num)
                    line))))))
    (lambda (line0 line1)
      (let ((osd (main-osd)))
        (show osd (or line0 "") 0)
        (show osd (or line1 "") 1)))))

(define-syntax show-main-osd
  ;; (show-main-osd [(FIELD VALUE) ...])
  ;;
  ;; Show main OSD.
  ;;
  ;; If FIELDs are specified, they can be either `line0', `line1' (see
  ;; `display-in-main-osd' for details), or any symbol supported by
  ;; `set-osd!'.
  (lambda (x)
    (syntax-case x ()
      ((_)
       #'(show-osd (main-osd)))
      ((_ args ...)
       (parse-arg-syntax '(line0 line1) #'(args ...)
         ((l0 l1 ())
          #'(display-in-main-osd l0 l1))
         ((l0 l1 (args ...))
          #'(begin
              (set-osd! (main-osd) args ...)
              (display-in-main-osd l0 l1))))))))

(define (display-error-in-main-osd string)
  ;; Show STRING in osd using `%color-error' color.
  ;; Return false value in Lisp format.
  (show-main-osd (line1 string)
                 (color %color-error))
  ;; Use Lisp format because this output is used by StumpWM.
  (scheme->lisp #f))

;;; osd.scm ends here
