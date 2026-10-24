;;; files.guile.scm --- Guile-specific procedures for working with files and file names

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

;; The following procedures originate from (guix build utils) module:
;;
;; - symlink? (from "symbolic-link?");
;; - executable? (from "executable-file?");
;; - with-directory-excursion;
;; - which;
;; - find-files;
;; - delete-file-recursively.

;;; Code:

(define file-name-directory dirname)

(define (symlink? file)
  "Return #t if FILE is a symbolic link."
  (eq? (stat:type (lstat file)) 'symlink))

(define (executable? file)
  "Return #t if FILE exists and is executable (not a directory)."
  (let ((s (stat file #f)))
    (and s
         (not (eq? (stat:type s) 'directory))
         (not (zero? (logand (stat:mode s) #o100))))))

(define (file-exists?? filename)
  "Check if FILENAME exists in the file system.
This procedure is similar to 'file-exists?' except it returns #t on a
broken link (i.e., on a file that is a symlink pointed to a non-existing
target)."
  (or (file-exists? filename)
      (catch 'system-error
        (lambda () (->bool (readlink filename)))
        ignore)))

(define (canonicalize-file-name file-name)
  "Return the canonical name of FILE-NAME.
This procedure is similar to 'canonicalize-path' except it returns #f
instead of raising an error."
  (catch 'system-error
    (lambda () (canonicalize-path file-name))
    ignore))

(define (file-name-extension file-name)
  "Return file extension from FILE-NAME."
  (if-letn ((base    (basename file-name))
            (dot-pos (string-rindex base #\.)))
    (string-downcase (substring base
                                (+ dot-pos 1)
                                (string-length base)))
    ""))

(define (file-name-sans-extension file-name)
  "Return FILE-NAME sans extension.
I.e., remove everything from FILE-NAME after the last dot."
  (let* ((base    (basename file-name))
         (dir     (dirname file-name))
         (dot-pos (string-rindex base #\.)))
    (if (or (not dot-pos)
            ;; File name starts with ".".
            (char=? (string-ref base 0) #\.))
      file-name
      (let ((new-base (substring base 0 dot-pos)))
        (if (string=? dir ".") ; (dirname "foo") returns "."
          new-base
          (build-file-name dir new-base))))))

(define (which program)
  "Return full file name of PROGRAM found in $PATH.
Return #f if PROGRAM is not found."
  (search-path (split-path) program))

(define (which-but program . files)
  "Return full file name of the first PROGRAM found in $PATH which is
not one of FILES.
Return #f if PROGRAM is not found."
  (let ((files (filter-map canonicalize-file-name files)))
    (let loop ((dirs (split-path)))
      (match dirs
        (() #f)
        ((dir rest-dirs ...)
         (if-let ((prog (build-file-name dir program)
                        (<= executable?)
                        (=> canonicalize-file-name)
                        (<= (negate (cut member <> files)))))
           prog
           (loop rest-dirs)))))))

(define (program-exists? program)
  "Check if program exists in $PATH."
  (->bool (which program)))

(define (first-existing-program . programs)
  "Return the first program from PROGRAMS found in $PATH.
Return #f if none of the PROGRAMS is available."
  (find program-exists? programs))

(define (first-existing-file . files)
  "Return the first existing file from FILES.
Return #f if none of the FILES exists."
  (find file-exists? files))

(define-syntax-rule (with-directory-excursion dir body ...)
  "Run BODY with DIR as the process's current directory."
  (let ((init (getcwd)))
   (dynamic-wind
     (lambda ()
       (chdir dir))
     (lambda ()
       body ...)
     (lambda ()
       (chdir init)))))

(define* (subdirs dir #:optional full-names?)
  "Return list of all sub-directories of DIR.

If FULL-NAMES? is #f, return only dir names i.e., relative names without
DIR itself.  Otherwise, return full absolute names.

Return empty list if DIR does not exist."
  (define (full-name name)
    (build-file-name dir name))

  (define (subdir? name)
    (and (not (member name '("." "..")))
         (catch 'system-error
           (lambda ()
             (file-is-directory? (full-name name)))
           ignore)))

  (let ((names (or (scandir dir subdir?)
                   '())))
    (if full-names?
      (map full-name names)
      names)))

(define* (find-files dir regexp #:key enter-tree? follow-links?)
  "Return list of files in DIR whose basenames match REGEXP.
If ENTER-TREE? is #f, scan DIR only (without subdirs), otherwise
traverse the whole DIR tree.
If FOLLOW-LINKS? is #f, do not follow symbolic links."
  (define rx
    (if (regexp? regexp)
        regexp
        (make-regexp regexp)))

  (define (enter? file stat result)
    (or (string= file dir)
        enter-tree?))

  (define (leaf-or-skip file stat result)
    (if (regexp-exec rx (basename file))
        (cons file result)
        result))

  (define (up-or-down file stat result)
    result)

  (define (error file stat errno result)
    (format (current-error-port)
            "Warning: ~a: ~a~%"
            file (strerror errno))
    result)

  (let ((stat (if follow-links? stat lstat)))
    (file-system-fold enter? leaf-or-skip up-or-down
                      up-or-down leaf-or-skip error
                      '() dir stat)))

(define (find-matching-files filename-part)
  "Return list of files whose full names begin with FILENAME-PART.
For example, (find-matching-files \"/foo/bar\") finds \"/foo/bar\",
\"/foo/bar.scm\", \"/foo/barman\", etc."
  (if-let- ((dir (file-name-directory filename-part)
                 (<= file-exists?))
            (dir (if (symlink? dir)
                   (canonicalize-path dir)
                   dir))
            (rx (string-append "\\`"
                               (regexp-quote
                                (basename filename-part)))))
    (find-files dir rx)
    (begin
      (format (current-error-port)
              "Warning: No such directory: ~a~%" dir)
      '())))

(define* (delete-file-recursively dir)
  "Delete DIR recursively, like `rm -rf', without following symlinks."
  (define ok (const #t))

  (define (del-file file stat result)
    (delete-file file)
    (format #t "File '~a' has been deleted.~%" file))

  (define (del-dir dir stat result)
    (rmdir dir)
    (format #t "Directory '~a' has been deleted.~%" dir))

  (define (error file stat errno result)
    (format (current-error-port)
            "Warning: failed to delete ~a: ~a~%"
            file (strerror errno)))

  ;; Use lstat to make sure that symlinks are not followed.
  (file-system-fold ok del-file ok del-dir ok error
                    #t dir lstat))

;;; files.guile.scm ends here
