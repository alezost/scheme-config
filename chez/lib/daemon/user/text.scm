;;; text.scm --- Display text in OSD

;; Copyright © 2016–2026 Alex Kost <alezost@gmail.com>

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

(define-values (text-osd
                hide-text-osds)
  (let ((osds '()))
    (values
      (memoize
       (lambda (number-of-lines)
         (let ((osd (make-osd
                      (lines number-of-lines)
                      (timeout 5)
                      (align 'right)
                      (position 'top)
                      (font "-*-dejavu sans-bold-r-normal-*-*-300-*-*-p-*-*")
                      (color "yellow")
                      (outline-offset 1)
                      (vertical-offset 30))))
           (register-osd osd)
           (push! osd osds)
           osd)))
      (lambda line-numbers
        (for-each (lambda (osd)
                    (unless (memv (osd-number-of-lines osd)
                                  line-numbers)
                      (hide-osd osd)))
                  osds)))))

(define display-pause-in-osd
  (let ((delay (make-time 'time-duration 0 1)))
    (lambda (osd line-number pause)
      (let loop ((seconds pause))
        (when (> seconds 0)
          (display-string-in-osd osd (make-string seconds #\.) line-number)
          (sleep delay)
          (loop (dec seconds)))))))

(define (display-strings-in-osd strings pause)
  (let* ((lines (length strings))
         (osd   (text-osd lines)))
    (hide-text-osds lines)
    (let loop ((strings strings)
               (line 0))
      (match strings
        (() #f)
        ((string)
         (display-string-in-osd osd string line))
        ((first rest …)
         (display-string-in-osd osd first line)
         (let ((next-line (inc line)))
           (display-pause-in-osd osd next-line pause)
           (loop rest next-line)))))))

(define (osd-text-pause strings pause)
  (match strings
    (()
     (show-osd (text-osd 1)))
    ((string)
     (display-strings-in-osd (split-string string #\newline) pause))
    (strings
     (display-strings-in-osd strings pause))))

(define (osd-text . args)
  ;; Show ARGS (strings) in OSD on separate lines.
  ;;
  ;; The first argument can be a number.  In this case, it is used as
  ;; the number of seconds to pause between displaying strings (rest
  ;; arguments).
  ;;
  ;; If ARGS are not specified, show OSD with the previously displayed
  ;; strings.  If a single string is specified, it may contain newlines.
  (match args
    (((? number? pause) strings …)
     (osd-text-pause strings pause))
    (strings
     (osd-text-pause strings 0))))

;;; text.scm ends here
