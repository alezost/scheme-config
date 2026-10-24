;;; files.scm --- Procedures for working with files and file names

;; Copyright © 2015–2026 Alex Kost

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

;; This file provides several additional procedures to perform various
;; actions on files and their names.

;; The following procedures originate from (guix build utils) module:
;;
;; - mkdir-with-parents (from "mkdir-p");

;;; Code:

(define (build-file-name . file-parts)
  ;; Return file name by concatenating FILE-PARTS with slashes.
  (match file-parts
    (() "/")
    ((first-part . rest-parts)
     (fold (lambda (part res)
             (string-append (string-trim-right res #\/)
                            "/"
                            (string-trim-left part #\/)))
           first-part
           rest-parts))))

(define (mkdir-with-parents directory)
  ;; Create DIRECTORY and all its ancestors.
  (unless (file-exists? directory)
    (let ((not-slash (char-set-complement (char-set #\/))))
      (let loop ((components (string-tokenize directory not-slash))
                 (root ""))
        (match components
          ((head tail …)
           (let ((file (build-file-name root head)))
             (unless (file-exists? file)
               (mkdir file))
             (loop tail file)))
          (_ #t))))))

(define (copy-file* old-name new-name)
  ;; Copy OLD-NAME file to NEW-NAME.
  ;;
  ;; This is the same as `copy-file' except it also creates parent
  ;; directory for NEW-NAME if it does not exist.
  (mkdir-with-parents (file-name-directory new-name))
  (copy-file old-name new-name))

(define unique-filename
  ;; (unique-filename BASENAME [N])
  ;;
  ;; Return unique filename based on BASENAME and an integer N.
  (case-lambda
    ((basename)
     (unique-filename basename 1))
    ((basename n)
     (let ((filename (string-append basename (number->string n))))
       (if (file-exists? filename)
         (unique-filename basename (+ n 1))
         filename)))))

(cond-expand
  ((or guile chez)
   (define (read-file filename)
     ;; Return a string with the contents of FILENAME.
     (call-with-input-file filename get-string-all)))
  (else))

(define (read-number-from-file filename)
  ;; Return a number read from the first line of FILENAME.
  ;; Return #f in case of any error.
  (with-error->false
    (with-input-from-file filename
      (lambda ()
        (string->number (read-line))))))

;;; files.scm ends here
