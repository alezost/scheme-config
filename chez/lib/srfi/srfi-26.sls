(library (srfi :26)
  (export cut cute <> <...>)
  (import (rnrs)
          (only (chezscheme) include)
          (lib-aux))

  (define-aux-symbols <> <...>)
  (include "srfi-26.scm"))
