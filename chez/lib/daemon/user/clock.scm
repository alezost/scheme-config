;;; clock.scm --- Display clock OSD

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

(define-osd clock-osd
  (timeout 0)
  (position 'middle)
  (align 'center)
  (font "-*-ubuntu-bold-r-normal-*-*-3800-*-*-p-*-*")
  (color "#BFBF00")
  (shadow-offset 3))

(define (format-current-time)
  ;; TODO use SRFI-19.
  (let ((date (time-utc->date (current-time))))
    (format "~2,'0d:~2,'0d"
            (date-hour date)
            (date-minute date))))

(define display-clock
  (let ((delay (make-time 'time-duration 0 1)))
    (lambda ()
      (let ((osd (clock-osd)))
        (let loop ((start #t))
          ;; Exit from the loop when OSD is hidden from the outside.
          (when (or start (osd-displayed? osd))
            (display-string-in-osd osd (format-current-time))
            (sleep delay)
            (loop #f)))))))

(define (osd-clock . args)
  (scheme->lisp
   (match args
     ((or () ("show"))
      (fork-thread display-clock)
      #t)
     (("hide")
      (hide-osd (clock-osd))
      #f)
     (("toggle")
      (if (osd-displayed? (clock-osd))
        (osd-clock "hide")
        (osd-clock "show")))
     (_
      (display-error-in-main-osd
       (format #f "Unknown arguments: ~a" args))))))

;;; clock.scm ends here
