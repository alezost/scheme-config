;;; files.chez.scm --- Chez-specific procedures for working with files and file names

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

;;; Code:

(define symlink? file-symbolic-link?)
(define file-exists?? (cut file-exists? <> #f))
(define file-name-directory path-parent)
(define file-name-extension path-extension)
(define file-name-sans-extension path-root)

(define (directory? file)
  (with-error->false
    (file-directory? file)))

(define (directory-files directory)
  (or (with-error->false
        (directory-list directory))
      '()))

(define read-line
  (case-lambda
    (()     (get-line (current-input-port)))
    ((port) (get-line port))))

(define executable?
  (let ((proc (foreign-procedure "access" (string int) int)))
    (lambda (file)
      ;; 1 is X_OK to test for execute permission.
      ;; See "man access.3" and "/usr/include/unistd.h".
      (=0 (proc file 1)))))

(define canonicalize-file-name
  (let ((proc (foreign-procedure "realpath" (string string) string)))
    (lambda (file)
      ;; #f means pass NULL pointer to allocate a buffer.
      ;; See "man realpath.3".
      (proc file #f))))

(define (copy-file old new)
  (let* ((buf-size (expt 2 16))
         (buf (make-bytevector buf-size)))
    (call-with-port (open-file-input-port old)
      (lambda (in)
        (call-with-port (open-file-output-port new)
          (lambda (out)
            (let loop ()
              (let ((n (get-bytevector-n! in buf 0 buf-size)))
                (unless (eof-object? n)
                  (put-bytevector out buf 0 n)
                  (loop))))))))))

;;; files.chez.scm ends here
