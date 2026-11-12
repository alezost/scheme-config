;;; sound.chez.scm --- Chez-specific sound utilities

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

(define (pulse-get-sound)
  (map volume->percent
       (sink-info-channels (get-sink-info))))

(define (pulse-set-sound . percentages)
  (apply set-volume
         (map percent->volume percentages)))

(define be/pulse
  (backend*
   (name "pulse")
   (description "libpulse (Chez FFI)")
   (getter pulse-get-sound)
   (setter pulse-set-sound)))

(current-backend be/pulse)

;;; sound.chez.scm ends here
