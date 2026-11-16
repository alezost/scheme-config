#!/usr/bin/env chicken-script
;;; cd-action.scm --- Send action to Chez Daemon

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

;; This program makes sense only with my config for Chez Daemon (see
;; "chez/lib/daemon/user.sls" in this repository).

;;; Code:

(import
  (scheme process-context)
  (scheme file)
  (chicken format)
  (chicken io)
  (al messages))

(define (action . args)
  (let* ((dir (or (get-environment-variable "XDG_RUNTIME_DIR")
                  (get-environment-variable "HOME")))
         (fifo-file (string-append dir "/chez-daemon.fifo")))
    (if (file-exists? fifo-file)
      (let ((reader (if (member "help" args)
                      read
                      read-string)))
        (with-output-to-file fifo-file
          (lambda ()
            (write (cons 'action args))))
        (with-input-from-file fifo-file
          (lambda ()
            (display (reader))
            (newline))))
      (leave "FIFO file does not exist: ~a
Chez Daemon is probably not running"
             fifo-file))))

(define (main args)
  (cond
   ((null? args) (action "help"))
   ((member (car args)
            '("-h" "--help"))
    (apply action "help" (cdr args)))
   (else (apply action args))))

(main (cdr (command-line)))

;;; cd-action.scm ends here
