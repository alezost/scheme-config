;;; user.scm --- User config for Chez Daemon

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

(define (action cmd . args)
  (match cmd
    ("sound"     (apply osd-sound args))
    ("backlight" (apply osd-backlight args))
    ;; TODO Add support for PAUSE argument.
    ("text"      (osd-text args 0))
    ("clock"     (apply osd-clock args))
    ("show-osds" (show-osds))
    ("hide-osds" (hide-osds))
    ("exit"      (exit))
    (_
     (display-error-in-main-osd
      (format #f "Unknown command: ~a" cmd)))))

;;; user.scm ends here
