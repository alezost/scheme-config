(library (al strings)
  (export string->bool
          string-trim-left
          string-trim-right
          string-trim-both
          mapconcat
          comma-separated
          min-string)
  (import (except (rnrs) error)
          (only (chezscheme) include format)
          (only (srfi :1) fold reduce)
          (only (srfi :13)
                string<
                string-trim
                string-trim-right
                string-trim-both)
          (srfi :23)
          (match)
          (aux-utils))
  (include "strings.scm"))
