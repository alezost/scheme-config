;;; daemon.scm --- Functionality to read FIFO file in a loop

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

;; This file originates from
;; <https://codeberg.org/alezost/guile-daemon/src/branch/master/modules/daemon.scm>.

;;; Code:

(define make-fifo-file
  (let ((proc (foreign-procedure "mkfifo" (string unsigned-32) int)))
    (lambda (file-name)
      (or (zero? (proc file-name #o600))
          (error 'make-fifo "Failed to create FIFO file" file-name)))))

(define (fifo-repl file-name)
  ;; Run REPL process on FIFO file FILE-NAME.  I.e., read Scheme
  ;; expressions from this file, evaluate them, print result of the last
  ;; evaluation back to the file, and repeat the whole process.

  (define (print expr)
    (with-output-to-file file-name
      (lambda () (write expr))
      'append))

  (define (read-eval)
    (call-with-input-file file-name
      (lambda (port)
        (let loop ((res (void)))
          (let ((expr (read port)))
            (if (eof-object? expr)
              res
              (loop (eval expr))))))))

  (let loop ()
    (guard (condition
            (else
             (parameterize ((current-output-port (current-error-port)))
               (display "Failed to load code from the FIFO file:\n")
               (display-condition condition)
               (newline))))
      (print (read-eval)))
    (loop)))

(define (default-fifo-file)
  (let ((dir (or (getenv "XDG_RUNTIME_DIR")
                 (getenv "HOME"))))
    (string-append dir "/chez-daemon.fifo")))

(define (start-daemon)
  ;; Ideally, an optional `fifo-file-name' argument should be added to
  ;; `start-daemon' but since I am the only user of chez-daemon, I don't
  ;; bother about it (the main problem with the specified file name would
  ;; be to create this file with all its parent directory tree).
  (let ((file-name (default-fifo-file)))
    (when (file-exists? file-name)
      (delete-file file-name))
    (make-fifo-file file-name)
    (format #t "Reading Scheme expressions from ~a ...~%"
            file-name)
    (fifo-repl file-name)))

;;; daemon.scm ends here
