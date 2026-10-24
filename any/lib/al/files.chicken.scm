;;; files.chicken.scm --- Chicken-specific procedures for working with files and file names

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

(define symlink? symbolic-link?)
(define executable? file-executable?)
(define file-name-directory pathname-directory)
(define file-name-extension pathname-extension)
(define mkdir create-directory)

(define (file-exists?? filename)
  (with-error->false
    (and (file-stat filename #t)
         #t)))

(define canonicalize-file-name
  (foreign-lambda*
   c-string ((c-string path))
   "char *res = realpath(path, NULL);"
   "C_return(res);"))

(define (file-name-sans-extension file-name)
  (build-file-name (pathname-directory file-name)
                   (pathname-file file-name)))

;;; files.chicken.scm ends here
