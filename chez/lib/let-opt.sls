;;; let-opt.sls --- `let-optionals' family macros

(library (let-opt)
  (export
    :optional
    let-optionals
    let-optionals*)
  (import (rnrs)
          (only (chezscheme) include))

  (include "let-opt.scm")
  (define-syntax let-optionals
    (identifier-syntax let-optionals*)))

;;; let-opt.sls ends here
