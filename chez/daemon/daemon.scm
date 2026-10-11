;;; daemon.scm --- Entry point to start Chez Daemon

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

;;; Code:

(import
 (chezscheme)
 (match)
 (daemon))

(define (show-help)
  (display "Chez Daemon is a server evaluating Scheme code.

This program reads Scheme expressions sent to FIFO file, evaluates them,
and writes the result of the last evaluation back to the FIFO file.

Normally, Chez Daemon does not quit: it just sits on the FIFO file
waiting for commands.  You can send (exit) to finish the program.

Default FIFO file: ")
  (display (default-fifo-file))
  (newline))

(define (main args)
  (match args
    ((or () (""))
     (guard (condition
             (else
              (parameterize ((current-output-port
                              (current-error-port)))
                (display "Failed to start daemon:\n")
                (display-condition condition)
                (newline))
              (exit 1)))
       (start-daemon)))
    (((or "-h" "--help"))
     (show-help))
    (args
     (format (current-error-port)
             "Unknown arguments: ~a~%Try --help~%"
             args)
     (exit 1))))

(main (command-line-arguments))

;;; daemon.scm ends here
