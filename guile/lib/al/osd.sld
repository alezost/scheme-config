(define-library (al osd)
  (export show-osds
          hide-osds
          register-osd
          define-osd)
  (import (scheme base)
          (xosd)
          (aux-utils))
  (include "osd.scm"))
