(define-library (al sources)
  (export source
          source?
          set-source!
          source-uri
          source-directory
          fetch-source)
  (import (scheme base)
          (scheme file)
          (let-macros)
          (drecords)
          (al messages))
  (cond-expand
    (guile (import (only (guile) system*)))
    (else))
  (include "sources.scm"))
