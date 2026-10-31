;;; misc.sls --- Miscellaneous utilities library

(library (al misc)
  (export getenv
          null-port
          with-no-output
          memoize
          scheme->lisp
          digits
          format-index
          split-path)
  (import (except (rnrs)
                  ;; These procedures are not parameters so
                  ;; `with-no-output' will fail if they are used.
                  current-output-port
                  current-error-port)
          (rnrs r5rs)
          (only (chezscheme)
                include getenv format
                parameterize
                current-output-port
                current-error-port
                make-output-port)
          (srfi :0)
          (let-macros)
          (aux-utils)
          (al strings))
  (include "misc.scm"))

;;; misc.sls ends here
