;;; files.sld --- R7RS library to work with files and file names

(define-library (al files)
  (export symlink?
          executable?
          file-exists??
          build-file-name
          canonicalize-file-name
          file-name-directory
          file-name-extension
          file-name-sans-extension
          unique-filename
          mkdir-with-parents
          copy-file*
          read-number-from-file)

  (import (scheme case-lambda)
          (scheme file)
          (only (srfi 1) fold find filter-map)
          (only (srfi 13) string-tokenize)
          (only (srfi 14) char-set char-set-complement)
          (match)
          (aux-utils)
          (al strings))

  (cond-expand
    (guile
     (export which
             which-but
             program-exists?
             first-existing-program
             first-existing-file
             with-directory-excursion
             subdirs
             find-files
             find-matching-files
             delete-file-recursively
             read-file)
     (import (only (rnrs io ports) get-string-all)
             (guile)
             (ice-9 regex)
             (ice-9 rdelim)
             (ice-9 ftw)
             (srfi 26)
             (let-macros)
             (al misc))
     (include "files.guile.scm"))

    (chicken
     (export mkdir)
     (import (scheme base)
             (chicken file)
             (chicken file posix)
             (chicken pathname)
             (chicken foreign))
     (include "files.chicken.scm"))

    (else))

  (include "files.scm"))

;;; files.sld ends here
