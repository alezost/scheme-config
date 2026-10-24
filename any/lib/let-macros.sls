;;; let-macros.sls --- Chez library for let macros

(library (let-macros)
  (export let-                  ; alias for `when-let-'
          if-let                ; alias for `if-let+'
          if-let-
          if-let+
          if-let1
          if-letn
          when-let              ; alias for `when-let+'
          when-let-
          when-let+
          when-let1
          when-letn)
  (import (rnrs)
          (only (chezscheme) include)
          (only (aux-utils) define-syntax-rule))
  (include "let-macros.scm"))

;;; let-macros.sls ends here
