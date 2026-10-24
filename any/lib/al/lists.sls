(library (al lists)
  (export replace
          split
          map-indexed
          for-each-indexed
          count-indexed)
  (import (rnrs)
          (only (chezscheme) include)
          (only (srfi :1) break)
          (srfi :26)
          (match)
          (aux-utils))
  (include "lists.scm"))
