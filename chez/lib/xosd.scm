;;; xosd.scm --- Chez Scheme interface for libxosd C library

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

This file originates from Guile-XOSD:
<https://github.com/alezost/guile-xosd/blob/master/modules/xosd.scm>.

It provides the same functionality as Guile-XOSD except `osd-color'
procedure is not implemented (it is useless anyway).  Also, since Chez
does not support procedures with keyword arguments, there is a
difference in the procedure calls: `make-osd' and `set-osd!' are macros
with declarative-style arguments instead of keyword-style procedures in
Guile-XOSD.  Example:

(define osd
  (make-osd
    ;; (timeout 3)
    (position 'middle)
    (align 'center)
    (font "-*-dejavu sans-bold-r-normal-*-*-600-*-*-p-*-*-1")
    (color "yellow")
    (shadow-color "red")
    (shadow-offset 3)))
(display-string-in-osd osd "Hello, world!")

To use this library, Chez should load "libxosd.so" at first.
Interactively (using REPL), this can be done by evaluating this:

  (load-shared-object "libxosd.so")

In the compiled code, Chez "scheme" command should be started with
"--boot" option.  See
<https://cisco.github.io/ChezScheme/csug/use.html#./use:h8> to learn how
you can create a boot file with `scheme-start' modified to load a shared
library.

|#

;;; Code:


;;; Auxiliary code

(define (print-error format-string . args)
  (apply format (current-error-port) format-string args)
  (newline))

(define (integer->bool integer)
  (not (zero? integer)))


;; Enum definitions

(define %XOSD_percentage 0)
(define %XOSD_string 1)
;; (define %XOSD_printf 2)      ; not used
(define %XOSD_slider 3)

(define %XOSD_top 0)
(define %XOSD_bottom 1)
(define %XOSD_middle 2)

(define %XOSD_left 0)
(define %XOSD_center 1)
(define %XOSD_right 2)


;;; Wrappers for libxosd procedures

(define (foreign-set-result result name)
  (or (zero? result)
      (begin (print-error "Failed to set ~a" name)
             #f)))

(define create-osd
  ;; (create-osd [NUMBER-OF-LINES])
  ;;
  ;; Create and return a new OSD object with the specified maximum
  ;; NUMBER-OF-LINES that this object can display (this value cannot be
  ;; changed after OSD creation).
  (let ((proc (foreign-procedure "xosd_create" (int) uptr)))
    (case-lambda
      (() (proc 1))
      ((n) (proc n)))))

(define kill-osd
  ;; (kill-osd OSD)
  ;;
  ;; Destroy OSD object (free up the used memory).
  (foreign-procedure "xosd_destroy" (uptr) int))

(define display-string-in-osd
  ;; (display-string-in-osd OSD STRING [LINE-NUMBER])
  ;;
  ;; Display STRING in LINE-NUMBER of OSD object.
  ;;
  ;; LINE-NUMBER must be less than the number of lines set during OSD
  ;; creation.
  ;;
  ;; This procedure returns immediately but STRING is displayed until
  ;; timeout set by `set-osd-timeout!' is expired.  If blocking is
  ;; required, `wait-while-osd-displayed' should be called after this
  ;; procedure.
  (let ((proc (foreign-procedure "xosd_display"
                                 (uptr int int string)
                                 int)))
    (case-lambda
      ((osd string)
       (proc osd 0 %XOSD_string string))
      ((osd string line-number)
       (proc osd line-number %XOSD_string string)))))

(define-values (display-percentage-in-osd
                display-slider-in-osd)
  (let ((proc (foreign-procedure "xosd_display"
                                 (uptr int int int)
                                 int)))
    (values
     (case-lambda
       ;; (display-percentage-in-osd OSD PERCENTAGE [LINE-NUMBER])
       ;;
       ;; Display PERCENTAGE in LINE-NUMBER of OSD object.
       ;; PERCENTAGE is a number between 0 and 100.
       ;; See also `display-string-in-osd'.
       ((osd percentage)
        (proc osd 0 %XOSD_percentage percentage))
       ((osd percentage line-number)
        (proc osd line-number %XOSD_percentage percentage)))

     (case-lambda
       ;; (display-slider-in-osd OSD SLIDER [LINE-NUMBER])
       ;;
       ;; Display SLIDER in LINE-NUMBER of OSD object.
       ;; SLIDER is a number between 0 and 100.
       ;; See also `display-string-in-osd'.
       ((osd slider)
        (proc osd 0 %XOSD_slider slider))
       ((osd slider line-number)
        (proc osd line-number %XOSD_slider slider))))))

(define hide-osd
  ;; (hide-osd OSD)
  ;;
  ;; Hide OSD object.
  (foreign-procedure "xosd_hide" (uptr) int))

(define show-osd
  ;; (show-osd OSD)
  ;;
  ;; Show (redisplay) hidden OSD object.
  (foreign-procedure "xosd_show" (uptr) int))

(define osd-displayed?
  ;; (osd-displayed? OSD)
  ;;
  ;; Return #t if OSD object is displayed.  Return #f otherwise.
  (let ((proc (foreign-procedure "xosd_is_onscreen" (uptr) int)))
    (lambda (osd)
      ;; TODO 'xosd_is_onscreen' can also return -1 (on failure).
      (integer->bool (proc osd)))))

(define wait-while-osd-displayed
  ;; (wait-while-osd-displayed OSD)
  ;;
  ;; Wait until OSD object will be hidden.
  ;; See also `display-string-in-osd'.
  (foreign-procedure "xosd_wait_until_no_display" (uptr) int))

(define set-osd-bar-length!
  ;; (set-osd-bar-length! OSD LENGTH)
  ;;
  ;; Change LENGTH of a slider or percentage bar of OSD object.
  ;; Setting LENGTH to -1 reverts to the default behavior.
  ;;
  ;; Return #t on success, #f on failure.
  (let ((proc (foreign-procedure "xosd_set_bar_length"
                                 (uptr int) int)))
    (lambda (osd length)
      (foreign-set-result (proc osd length) "bar length"))))

(define set-osd-position!
  ;; (set-osd-position! OSD POSITION)
  ;;
  ;; Change vertical POSITION of OSD object.
  ;; POSITION should be one of the following symbols: `top', `middle',
  ;; or `bottom'.
  ;;
  ;; Return #t on success, #f on failure.
  (let ((proc (foreign-procedure "xosd_set_pos" (uptr int) int)))
    (lambda (osd position)
      (let ((pos (case position
                   ((top)    %XOSD_top)
                   ((middle) %XOSD_middle)
                   ((bottom) %XOSD_bottom)
                   (else (begin
                           (print-error "Unknown position: ~a" position)
                           #f)))))
        (and pos
             (foreign-set-result (proc osd pos) "position"))))))

(define set-osd-align!
  ;; (set-osd-align! OSD ALIGN)
  ;;
  ;; Change horizontal alignment of OSD object.
  ;; ALIGN should be one of the following symbols: `left', `center',
  ;; or `right'.
  ;;
  ;; Return #t on success, #f on failure.
  (let ((proc (foreign-procedure "xosd_set_align" (uptr int) int)))
    (lambda (osd align)
      (let ((pos (case align
                   ((left)   %XOSD_left)
                   ((center) %XOSD_center)
                   ((right)  %XOSD_right)
                   (else (begin
                           (print-error "Unknown align: ~a" align)
                           #f)))))
        (and pos
             (foreign-set-result (proc osd pos) "align"))))))

(define set-osd-timeout!
  ;; (set-osd-timeout! OSD SECONDS)
  ;;
  ;; Change the number of SECONDS before OSD object is hidden.
  ;; If SECONDS is -1 or 0 (not documented by libxosd), OSD does not
  ;; hide automatically.
  ;;
  ;; Return #t on success, #f on failure.
  (let ((proc (foreign-procedure "xosd_set_timeout" (uptr int) int)))
    (lambda (osd seconds)
      (foreign-set-result (proc osd seconds) "timeout"))))

(define set-osd-font!
  ;; (set-osd-font! OSD FONT)
  ;;
  ;; Change FONT of OSD object.
  ;; FONT is a string with the XLFD full name of the new font (see
  ;; `xfontsel' program for details).
  ;;
  ;; Return #t on success, #f on failure.
  (let ((proc (foreign-procedure "xosd_set_font" (uptr string) int)))
    (lambda (osd font)
      (foreign-set-result (proc osd font) "font"))))

(define set-osd-color!
  ;; (set-osd-color! OSD COLOR)
  ;;
  ;; Change COLOR of OSD object.
  ;; COLOR is a string with the color value (e.g., `#2e8b57') or the
  ;; color name (e.g., `DeepSkyBlue').
  ;;
  ;; Return #t on success, #f on failure.
  (let ((proc (foreign-procedure "xosd_set_colour" (uptr string) int)))
    (lambda (osd color)
      (foreign-set-result (proc osd color) "color"))))

(define set-osd-shadow-color!
  ;; (set-osd-shadow-color! OSD COLOR)
  ;;
  ;; Change COLOR of the text shadow of OSD object.
  ;; See `set-osd-color!' for the meaning of COLOR.
  ;;
  ;; Return #t on success, #f on failure.
  (let ((proc (foreign-procedure "xosd_set_shadow_colour"
                                 (uptr string) int)))
    (lambda (osd color)
      (foreign-set-result (proc osd color) "shadow color"))))

(define set-osd-outline-color!
  ;; (set-osd-outline-color! OSD COLOR)
  ;;
  ;; Change COLOR of the text outline of OSD object.
  ;; See `set-osd-color!' for the meaning of COLOR.
  ;;
  ;; Return #t on success, #f on failure.
  (let ((proc (foreign-procedure "xosd_set_outline_colour"
                                 (uptr string) int)))
    (lambda (osd color)
      (foreign-set-result (proc osd color) "outline color"))))

(define set-osd-vertical-offset!
  ;; (set-osd-vertical-offset! OSD OFFSET)
  ;;
  ;; Change vertical OFFSET of OSD object.
  ;; OFFSET is a number of pixels to offset OSD from its default vertical
  ;; position (specified by `set-osd-position!').
  ;;
  ;; Return #t on success, #f on failure.
  (let ((proc (foreign-procedure "xosd_set_vertical_offset"
                                 (uptr int) int)))
    (lambda (osd offset)
      (foreign-set-result (proc osd offset) "vertical offset"))))

(define set-osd-horizontal-offset!
  ;; (set-osd-horizontal-offset! OSD OFFSET)
  ;;
  ;; Change horizontal OFFSET of OSD object.
  ;; OFFSET is a number of pixels to offset OSD from its default
  ;; horizontal position (specified by `set-osd-align!').
  ;;
  ;; Return #t on success, #f on failure.
  (let ((proc (foreign-procedure "xosd_set_horizontal_offset"
                                 (uptr int) int)))
    (lambda (osd offset)
      (foreign-set-result (proc osd offset) "horizontal offset"))))

(define set-osd-shadow-offset!
  ;; (set-osd-shadow-offset! OSD OFFSET)
  ;;
  ;; Change OFFSET (number of pixels) of the text shadow of OSD object.
  ;;
  ;; Return #t on success, #f on failure.
  (let ((proc (foreign-procedure "xosd_set_shadow_offset"
                                 (uptr int) int)))
    (lambda (osd offset)
      (foreign-set-result (proc osd offset) "shadow offset"))))

(define set-osd-outline-offset!
  ;; (set-osd-outline-offset! OSD OFFSET)
  ;;
  ;; Change OFFSET (number of pixels) of the text outline of OSD object.
  ;;
  ;; Return #t on success, #f on failure.
  (let ((proc (foreign-procedure "xosd_set_outline_offset"
                                 (uptr int) int)))
    (lambda (osd offset)
      (foreign-set-result (proc osd offset) "outline offset"))))

(define osd-number-of-lines
  ;; (osd-number-of-lines OSD)
  ;;
  ;; Return the maximum number of lines allowed for OSD object.
  (foreign-procedure "xosd_get_number_lines" (uptr) int))

(define scroll-osd
  ;; (scroll-osd OSD NUMBER-OF-LINES)
  ;;
  ;; Scroll OSD object by NUMBER-OF-LINES.
  (foreign-procedure "xosd_scroll" (uptr int) int))


;;; Higher level interface

(define-syntax set-osd!
  ;; (set-osd! OSD [(PROP VALUE) ...])
  ;;
  ;; Update OSD object with the specified arguments.  Each PROP should
  ;; be one of the OSD properties for which `set-osd-PROP!' procedure is
  ;; defined e.g., `position', `shadow-color', etc.
  (lambda (x)
    (define (prop->proc prop-syntax)
      (syntax-case prop-syntax ()
        (prop
         (let* ((prop-symbol (syntax->datum #'prop))
                (prop-string (symbol->string prop-symbol))
                (proc-string (string-append "set-osd-" prop-string "!"))
                (proc-symbol (string->symbol proc-string)))
           (datum->syntax #'prop proc-symbol)))))
    (syntax-case x ()
      ((_ osd (prop value) ...)
       (with-syntax (((proc ...)
                      (map prop->proc (syntax->list #'(prop ...)))))
         #'(begin (proc osd value) ...))))))

(define-syntax make-osd
  ;; (make-osd [(PROP VALUE) ...])
  ;;
  ;; Create and return a new OSD object with the specified arguments.
  ;; PROP can be either `lines' or any symbol supported by `set-osd!'.
  ;; `lines' VALUE is the number of lines that OSD object can display.
  (lambda (x)
    (syntax-case x ()
      ((_ args ...)
       (syntax-case
           (let loop ((rest (syntax->list #'(args ...)))
                      (res  '()))
             (if (null? rest)
               (list 1 res)
               (let* ((arg  (syntax->list (car rest)))
                      (prop (syntax->datum (car arg))))
                 (if (symbol=? prop 'lines)
                   (list (cadr arg) ; prop value
                         (append res (cdr rest)))
                   (loop (cdr rest)
                         (cons arg res))))))
           ()
         ((lines (args ...))
          #'(let ((osd (create-osd lines)))
              (set-osd! osd args ...)
              osd)))))))

(define (toggle-osd osd)
  "Hide/show OSD."
  (if (osd-displayed? osd)
    (hide-osd osd)
    (show-osd osd)))

;;; xosd.scm ends here
