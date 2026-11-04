;;; device.scm --- Perform some actions for connected/disconnected device

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

;; `device' procedure is intended to be called when a device is
;; connected or disconnected.  So you should make a file in
;; "/etc/udev/rules.d/" with lines like this:
;;
;; ACTION=="<action>", SUBSYSTEM=="<type>", RUN+="/bin/runuser -u <user> -- <script> <action> <state> \"%k\""
;;
;; where
;;
;;   <type> is "usb" or "input",
;;
;;   <action> is "add" or "remove",
;;
;;   <state> is "connected" or "disconnected" (depending on <action>),
;;
;;   <script> is an executable that should eventually call `device'
;;   procedure with the specified arguments.

;;; Code:

(define (play-sound file)
  (process (string-append "play -q " file)))

(define (device-model name)
  (let- ((prod-file (build-file-name "/sys/bus/usb/devices"
                                     name "product")
                    (<= file-exists?)))
    ;; Maybe parse "udevadm info -q all /sys/bus/usb/devices/NAME"
    ;; if PROD-FILE does not exist?
    (string-trim-right         ; some product names have trailing spaces
     (with-input-from-file prod-file read-line))))

(define keyboard?
  ;; (keyboard? DEVICE)
  ;;
  ;; Return #t if DEVICE is a keyboard.
  ;; DEVICE should be an input device name.

  ;; <https://stackoverflow.com/questions/69308047/finding-available-keyboards-on-linux>
  ;; explains how bits are organized in
  ;; "/sys/class/input/inputN/capabilities/key" file.
  ;;
  ;; Here, we check if input device provides "qwertyui" keys (bits
  ;; 16-23, see "/usr/include/linux/input-event-codes.h"):
  ;;
  ;;   iuytrewq
  ;;   111111110000000000000000
  ;;          ^ bit 16        ^ bit 0
  ;;
  ;; If it does, then it is a keyboard for sure.
  (let ((mask #b111111110000000000000000))
    (lambda (name)
      (let- ((key-file  (build-file-name "/sys/class/input"
                                         name "capabilities/key")
                        (<= file-exists?))
             (key-str   (with-input-from-file key-file read-line))
             (last-word (last (split-string key-str)))
             (num       (string->number last-word 16)))
        (= mask (bitwise-and num mask))))))

(define (device type state name)
  ;; Perform some action for device state change.
  ;;
  ;; All arguments should be strings:
  ;;
  ;; TYPE is a device type ("usb" or "input").
  ;; STATE is a device state ("connected" or "disconnected").
  ;; NAME is a device name.
  (let ((input? (string=? type "input"))
        ;; When a device is (dis)connected, "udev" rule is triggered
        ;; several times because along with "parent" device (e.g.,
        ;; "1-4") there are "child" devices (e.g., "1-4:1.1").  Not sure
        ;; if this is a correct terminology.  Anyway, we ignore "child"
        ;; connections to avoid multiple sounds/OSDs.
        (child? (and (string=? type "usb")
                     (string-contains name ":"))))
    (match state
      ("connected"
       (unless child?
         (if input?
           (when (keyboard? name)
             (fork-thread
              (lambda ()
                ;; Wait for a couple of seconds to make sure X server
                ;; has initialized the new input device.  Is there a
                ;; better way?
                (sleep (make-time 'time-duration 0 2))
                (process "herd start xkb:0")
                (osd-text "XKB restarted"))))
           (begin
             (play-sound "/usr/share/sounds/freedesktop/stereo/device-added.oga")
             (if-letn ((title (string-append "New " type " device: " name))
                       (model (device-model name)))
               (osd-text title model)
               (osd-text title))))))
      ("disconnected"
       (unless (or input? child?)
         (play-sound "/usr/share/sounds/freedesktop/stereo/device-removed.oga")
         (osd-text (string-append "Disconnected device: " name)))))))

;;; device.scm ends here
