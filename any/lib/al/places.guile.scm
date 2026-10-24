;;; places.guile.scm --- Guile-specific file places

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

;;; Code:

(define* (guix-script-file #:optional name)
  "Return file name of my Guix script NAME."
  (apply guix-config-file "scripts"
         (if name
             (list name)
             '())))

(define* (guix-system-file #:optional name)
  "Return file name of my Guix system NAME."
  (apply guix-config-file "system-config"
         (if name
             (list (string-append "os-" name ".scm"))
             '())))

(define* (guix-manifest-file #:optional name)
  "Return file name of my Guix manifest file for profile NAME."
  (apply guix-config-file "user-config"
         (if name
             (list (string-append "manifest-" name ".scm"))
             '())))

(define (guix-profile name)
  "Return file name of my Guix profile NAME."
  (home-file ".guix-profiles" name name))

(define (guix-profile-file name . file-parts)
  "Return file name from my Guix NAME profile."
  (apply build-file-name (guix-profile name) file-parts))

(define (guix-user-profile-file . file-parts)
  "Return file name from my Guix user profile."
  (apply guix-profile-file "main" file-parts))

(define (guix-system-profile-file . file-parts)
  "Return file name from the Guix system packages profile."
  (apply build-file-name "/run/current-system/profile" file-parts))

;;; places.guile.scm ends here
