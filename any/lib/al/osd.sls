(library (al osd)
  (export show-osds
          hide-osds
          register-osd
          define-osd)
  (import (rnrs)
          (only (chezscheme) include)
          (xosd)
          (aux-utils))
  (include "osd.scm"))
