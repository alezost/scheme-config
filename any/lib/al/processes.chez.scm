;;; processes.chez.scm --- Chez-specific utilities for working with processes

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

(define (system-output command)
  ;; Run shell COMMAND and return its output.
  (match (process command)
    ((from-out to-in pid)
     (close-output-port to-in)
     (let ((output (get-string-all from-out)))
       (close-input-port from-out)
       output))))

(define (system*-output . args)
  ;; Run program indicated by ARGS and return its output.
  (system-output (mapconcat identity args " ")))

;;; processes.chez.scm ends here
