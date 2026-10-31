;;; backlight.scm --- Get/set display backlight brightness and show it in OSD

;; Copyright © 2018–2026 Alex Kost <alezost@gmail.com>

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

(define %backlight-color "#2890e8")

(define output-backlight
  ;; (output-backlight BACKLIGHT [SHOW-OSD?])
  ;;
  ;; Return BACKLIGHT value in Lisp format.  SHOW-OSD? defines if OSD
  ;; with the backlight value should be displayed or not.
  (case-lambda
    ((bl)
     (output-backlight bl #t))
    ((bl show-osd?)
     (when show-osd?
       (show-main-osd
        (line0 (format #f "Backlight: ~d%" bl))
        (line1 bl)
        (color %backlight-color)))
     (scheme->lisp bl))))

(define (osd-backlight . args)
  ;; Update screen backlight according to ARGS and show backlight OSD.
  ;;
  ;; ARGS should be command line arguments (i.e., strings).  ARGS have
  ;; one of the following forms:
  ;;
  ;;   () or ("show")   return current backlight and show OSD;
  ;;
  ;;   ("get")          return current backlight and do not show OSD;
  ;;                    (this is the only form that does not show OSD);
  ;;
  ;;   ("set" "VALUE")  set backlight to the specified VALUE,
  ;;                    see `set-backlight' for details.
  ;;
  ;; Example: (osd-backlight "set" "+3")
  ;;
  ;; Return the current backlight percentage (an integer from 0 to 100).
  ;; Return false value in Lisp format if backlight is not available.
  (if (backlight-available?)
    (match args
      ((or () ("show"))
       (output-backlight (get-backlight) #t))
      (("get")
       (output-backlight (get-backlight) #f))
      (("set" value)
       (output-backlight (set-backlight value)))
      (_
       (display-error-in-main-osd
        (format #f "Unknown arguments: ~a" args))))
    (display-error-in-main-osd
     "Backlight is not available")))

;;; backlight.scm ends here
