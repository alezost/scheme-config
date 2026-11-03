#!/usr/bin/env chicken-script
;;; cd-action.scm --- Send action to Chez Daemon

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

;;; Commentary:

;; This program makes sense only with my config for Chez Daemon (see
;; "chez/lib/daemon/user.sls" in this repository).

;;; Code:

(import
  (scheme process-context)
  (scheme file)
  (chicken format)
  (chicken io)
  (al messages))

(define (show-help)
  (display
   "Usage: cd-action COMMAND [ARGS ...].

Send (action \"COMMAND\" \"ARGS\" ...) to the default FIFO file listened
by Chez Daemon.

Available COMMANDs:

* help

  Show this help message and exit.

* exit

  Make Chez Daemon quit.

* sound

  Update sound according to ARGS and show sound OSD.
  Print the current sound value to standard output.
  This value has (VOLUME ON) form, where

    VOLUME is an integer from 0 to 100,

    ON is a boolean value in Lisp format (nil or t) showing if the sound
    is on or off (muted).

  ARGS have one of the following forms:

    show        Return the current sound value and show OSD; this is
                the default action (performed if no ARGS are specified).

    get         Return the current sound value and do not show OSD
                (this is the only form that does not show OSD).

    set VALUE   Set sound volume to VALUE.

                VALUE should have \"sN\" format, where \"N\" is an
                integer from 0 to 100 and \"s\" is an optional sign
                i.e., \"s\" is either:

                \"+\": to increase sound by N,
                \"-\": to decrease sound by N,
                empty string: to set sound to N.

    on          Unmute (turn sound on).

    off         Mute (turn sound off).

    toggle      Toggle mute state.

* backlight

  Update screen backlight according to ARGS and show backlight OSD.
  Print the current screen backlight brightness (an integer from 0 to
  100) to standard output.

  ARGS have one of the following forms:

    show
    get
    set VALUE

  They have the same meaning as ARGS for 'sound' command (see above).

* text

  Show ARGS (strings) in OSD on separate lines.

  If the first argument is an integer from 0 to 9, it is used as the
  number of seconds to pause between displaying strings (rest
  arguments).

  If strings are not specified, show OSD with the previously
  displayed strings.  If a single string is specified, it may contain
  newlines.

* clock

  Show/hide OSD with clock.
  ARGS have one of the following forms:

    show        Show clock OSD (this is the default action).
    hide        Hide clock OSD.
    toggle      Toggle clock OSD.

* show-osds

  Show all hidden OSDs.

* hide-osds

  Hide all visible OSDs.

Examples:

cd-action sound get
cd-action sound off
cd-action sound set 50
cd-action backlight set +3
cd-action text \"Hello, world!\"
cd-action clock toggle

Print () in case of any error.
"))

(define (main args)
  (if (or (null? args)
          (member (car args)
                  '("-h" "--help" "help")))
    (show-help)
    (let* ((dir (or (get-environment-variable "XDG_RUNTIME_DIR")
                    (get-environment-variable "HOME")))
           (fifo-file (string-append dir "/chez-daemon.fifo")))
      (if (file-exists? fifo-file)
        (begin
          (with-output-to-file fifo-file
            (lambda ()
              (write (cons 'action args))))
          (with-input-from-file fifo-file
            (lambda ()
              (display (read-string))
              (newline))))
        (leave "FIFO file does not exist: ~a
Chez Daemon is probably not running"
               fifo-file)))))

(main (cdr (command-line)))

;;; cd-action.scm ends here
