;;; places.scm --- My files places

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

;; This file provides procedures returning file names of various files.

;;; Code:

(define (home-file . file-parts)
  (apply build-file-name (getenv "HOME") file-parts))

(define (bin-file . file-parts)
  (apply home-file "bin" file-parts))

(define (config-file . file-parts)
  (apply home-file "config" file-parts))

(define (secret-config-file . file-parts)
  (apply config-file "secret" file-parts))

(define (guix-config-file . file-parts)
  (apply config-file "guix" file-parts))

;;; places.scm ends here
