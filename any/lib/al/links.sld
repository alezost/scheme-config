(define-library (al links)
  (export link
          link?
          set-link!
          link-filename
          link-target
          link-string
          link-exists?
          create-link)
  (import (scheme base)
          (scheme file)
          (let-macros)
          (drecords)
          (al files)
          (al messages))
  (cond-expand
    (guile (import (only (guile) readlink symlink)))
    (else))
  (include "links.scm"))
