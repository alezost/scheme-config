(define-library (al configs)
  (export config
          config?
          set-config!
          config-name
          config-source
          config-links
          show-config
          fetch-config
          deploy-config)
  (import (scheme base)
          (scheme case-lambda)
          (scheme file)
          (srfi 26)
          (let-macros)
          (aux-utils)
          (drecords)
          (al files)
          (al links)
          (al sources)
          (al messages))
  (cond-expand
    (guile (import (only (guile) rename-file)))
    (else))
  (include "configs.scm"))
