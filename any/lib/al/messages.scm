;;; messages.scm --- Procedures for displaying messages

;; Copyright © 2015–2026 Alex Kost

;; Author: Alex Kost <alezost@gmail.com>
;; Created:  6 Mar 2015

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

(define (message indent-level destination format-string . args)
  ;; Print message to DESTINATION port indented to INDENT-LEVEL.
  ;; The message always ends with newline.
  (let* ((indent-str (make-string (* 3 indent-level) #\space))
         (str        (string-append indent-str format-string)))
    (apply format destination str args)
    (newline)))

(define message0 (cut message 0 #t <> <...>))
(define message1 (cut message 1 #t <> <...>))

(define (print-output format-string . args)
  (apply message 0 (current-output-port) format-string args))

(define (print-error format-string . args)
  (apply message 0 (current-error-port) format-string args))

(define (leave format-string . args)
  ;; Print message to STDERR and exit.
  (apply print-error format-string args)
  (exit 1))

;;; messages.scm ends here
