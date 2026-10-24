;;; files.sls --- R6RS library to work with files and file names

(library (al files)
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
          copy-file
          copy-file*
          read-line
          read-file
          read-number-from-file)
  (import (rnrs)
          (rnrs io ports)
          (only (chezscheme)
                include
                path-parent path-extension path-root
                file-symbolic-link? mkdir
                foreign-procedure)
          (srfi :0)
          (only (srfi :1) fold)
          (only (srfi :13) string-tokenize)
          (only (srfi :14) char-set char-set-complement)
          (srfi :26)
          (match)
          (aux-utils)
          (al strings))
  (include "files.chez.scm")
  (include "files.scm"))

;;; files.sls ends here
