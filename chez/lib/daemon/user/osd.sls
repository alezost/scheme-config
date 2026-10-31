(library (daemon user osd)
  (export %color-on
          %color-off
          %color-error
          main-osd
          show-main-osd
          display-in-main-osd
          display-error-in-main-osd)
  (import (rnrs)
          (only (chezscheme) include format)
          (match)
          (aux-utils)
          (xosd)
          (al osd)
          (al misc))
  (include "osd.scm"))
