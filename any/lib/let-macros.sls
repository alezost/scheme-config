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
          when-letn
          <= =>)
  ;; These ↑ `<=' and `=>' are exported from (rnrs) so any code that
  ;; imports both, (let-macros) and (chezscheme) libraries, will have
  ;; "multiple definitions" exception on compilation.  This is much
  ;; better than a confusing "invalid syntax (if-let+ …)" error at
  ;; expansion time.  See
  ;; <https://stackoverflow.com/questions/54173992/chez-scheme-macro-import-at-top-level>
  ;; for details on a similar problem.

  (import (rnrs)
          (only (chezscheme) include)
          (only (aux-utils) define-syntax-rule))

  (include "let-macros.scm"))

;;; let-macros.sls ends here
