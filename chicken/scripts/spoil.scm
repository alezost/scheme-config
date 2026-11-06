#!/usr/bin/env chicken-script
;;; spoil.scm --- Spoil file by mixing bytes

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

(import
  (srfi 1)
  (srfi 26)
  (srfi 37)
  (chicken string)
  (chicken format)
  (chicken process-context)
  (chicken file)
  (chicken file posix)
  (chicken io)
  (chicken bytevector)
  (chicken random)
  (aux-utils)
  (al lists)
  (al strings)
  (al messages))

(define %chunk-size (expt 2 16))


;;; General utils

(define (random-integer from to)
  "Return random integer between FROM and TO-1 inclusively."
  (+ from (pseudo-random-integer (- to from))))

(define (random-integers n from to)
  "Return list of N random integers.
Integers are ranged between FROM and TO-1 inclusively."
  (let loop ((i 1)
             (res '()))
    (if (< n i)
      res
      (loop (inc i)
            (cons (random-integer from to)
                  res)))))


;;; Byte utils

(define (write-random-bytes out-port count)
  (when (>0 count)
    (write-byte (pseudo-random-integer 256) out-port)
    (write-random-bytes out-port (dec count))))

(define (shift-byte byte shift)
  (modulo (+ byte shift) 256))

(define (shift-bytes in-port out-port numbers
                     #!key from to)
  ;; Take bytes from IN-PORT and output shifted bytes to OUT-PORT.
  ;; Bytes are shifted with NUMBERS (list of integers).
  ;; IN-PORT is read from byte FROM to byte TO-1 inclusively.
  (define numbers*              ; circular list of NUMBERS
    (let ((ns (list-copy numbers)))
      (set-cdr! (last-pair ns) ns)
      ns))

  (define bv (make-bytevector %chunk-size))

  (define (shift-bv! size)
    (let loop ((i 0)
               (numbers numbers*))
      (if (< i size)
        (begin
          ;; (print-output "Shifting byte ~a (~a) with number ~a"
          ;;               i (bytevector-u8-ref bv i) (car numbers))
          (bytevector-u8-set! bv i
                              (shift-byte (bytevector-u8-ref bv i)
                                          (car numbers)))
          (loop (inc i) (cdr numbers)))
        (set! numbers* numbers))))

  (when from
    (read-bytevector from in-port))
  (let* ((size (and to (- to (or from 0))))
         (chunk-count (and size (inc (quotient size %chunk-size))))
         (last-chunk-size (and size (modulo size %chunk-size))))
    (when (or (not chunk-count)
              (< 0 chunk-count))
      (let loop ((i 1))
        (let ((size (read-bytevector!
                     bv in-port 0
                     (and chunk-count
                          (= i chunk-count)
                          last-chunk-size))))
          (shift-bv! size)
          (write-bytevector bv out-port 0 size)
          (when (= size %chunk-size)
            (loop (inc i))))))))


;;; File utils and "spoilers"

(define (call-with-files in-file out-file proc
                         #!optional (mode #:binary))
  "Open IN-FILE for reading, OUT-FILE for output, and call PROC.
PROC is called with 2 arguments: IN-PORT and OUT-PORT."
  (call-with-output-file out-file
    (lambda (out-port)
      (call-with-input-file in-file
        (lambda (in-port)
          (proc in-port out-port))
        mode))
    mode))

(define (spoil-file in-file out-file numbers)
  (call-with-files
   in-file out-file
   (lambda (in-port out-port)
     (let ((write-bytes (cut write-random-bytes out-port <>)))
       (and=> (nth numbers 0) write-bytes)
       (shift-bytes in-port out-port numbers)
       (and=> (nth numbers 1) write-bytes)))))

(define (unspoil-file in-file out-file numbers)
  (call-with-files
   in-file out-file
   (lambda (in-port out-port)
     (shift-bytes in-port out-port (map - numbers)
                  #:from (nth numbers 0)
                  #:to (and=> (nth numbers 1)
                              (cut - (file-size in-file) <>))))))


;;; Command-line args

(define (show-help)
  (display "Usage: spoil [OPTIONS ...]

\"Spoil\" file by mixing its bytes using \"magic\" numbers.  Actually,
the input file itself is not spoiled, its \"spoiled\" contents will be
written to the specified output file (see options below).")
  (display "\n
Options:
  -h, --help
        display this help and exit

  -i FILE, --input=FILE
        name of the input FILE

  -o FILE, --output=FILE
        name of the output FILE

  -f, --force
        overwrite output file if it already exists

  -n NUMBERS, --numbers=NUMBERS
        comma-separated NUMBERS used for spoiling

  -r, --random
        use random numbers for spoiling
        (how are you going to unspoil this?)

  -u, --unspoil
        revert spoil made by the same numbers

  -v, --verbose
        print some messages during spoiling

\"--input\" and \"--output\" options are mandatory, the rest are
optional.")
  (newline))

(define %options
  (list (option '(#\h "help") #f #f
                (lambda _
                  (show-help)
                  (exit 0)))
        (option '(#\i "input") #t #f
                (lambda (opt name arg seed)
                  (alist-cons 'input arg seed)))
        (option '(#\o "output") #t #f
                (lambda (opt name arg seed)
                  (alist-cons 'output arg seed)))
        (option '(#\f "force") #f #f
                (lambda (opt name arg seed)
                  (alist-cons 'force #t seed)))
        (option '(#\n "numbers") #t #f
                (lambda (opt name arg seed)
                  (alist-update! 'numbers
                                 (map string->number
                                      (string-split arg ","))
                                 seed)))
        (option '(#\r "random") #f #f
                (lambda (opt name arg seed)
                  (alist-update! 'numbers
                                 (random-integers 8 0 255)
                                 seed)))
        (option '(#\u "unspoil") #f #f
                (lambda (opt name arg seed)
                  (alist-update! 'spoiler unspoil-file seed)))
        (option '(#\v "verbose") #f #f
                (lambda (opt name arg seed)
                  (alist-cons 'verbose #t seed)))))

(define (parse-args args)
  (args-fold args %options
             (lambda (opt name arg seed)
               (leave "Unrecognized option: \"~a\"" name))
             (lambda (arg seed)
               (leave "Unknown argument: \"~a\"
Did you forget to specify an option?"
                      arg))
             (list (cons 'numbers '(1 2))
                   (cons 'spoiler spoil-file))))

(define (check-input-file file)
  (cond
   ((not file)
    (leave "\"--input\" file should be specified"))
   ((not (file-exists? file))
    (leave "File does not exist: ~a" file))
   ((not (file-readable? file))
    (leave "File is not readable: ~a" file))))

(define (check-output-file file force?)
  (cond
   ((not file)
    (leave "\"--output\" file should be specified"))
   ((file-exists? file)
    (unless force?
      (leave "File already exists: ~a
Use \"--force\" to overwrite it"
             file))
    (unless (file-writable? file)
      (leave "File is not writable: ~a"
             file)))))

(define (main args)
  (if (null? args)
    (show-help)
    (let* ((opts    (parse-args args))
           (input   (alist-ref 'input   opts))
           (output  (alist-ref 'output  opts))
           (force?  (alist-ref 'force   opts))
           (numbers (alist-ref 'numbers opts))
           (verbose (alist-ref 'verbose opts))
           (spoiler (alist-ref 'spoiler opts)))
      (check-input-file input)
      (check-output-file output force?)
      (when (equal? input output)
        (leave "Input and output should not be the same file"))
      (when verbose
        (print-output "Using magic numbers: ~a"
                      (apply comma-separated
                             (map number->string numbers)))
        (format #t "Writing to file \"~a\"..." output))
      (spoiler input output numbers)
      (when verbose
        (print-output " done.")))))

(cond-expand
  ((or compiling chicken-script)
   (main (command-line-arguments)))
  (else))

;;; spoil.scm ends here
