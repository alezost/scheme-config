(define-library (al osd)
  (export show-osds
          hide-osds
          register-osd
          define-osd)
  (import (scheme base)
          (xosd)
          (al main))
  (include "osd.scm"))
