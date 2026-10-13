(library (al fp-utils)
  (export identity const
          negate compose-left
          and=> and<=)
  (import (rnrs)
          (only (chezscheme) include))
  (include "fp-utils.scm"))
