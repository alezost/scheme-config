(library (aalists)
  (export make-aalist
          aalist-get
          aalist-set!
          aalist-value)
  (import (rnrs)
          (rnrs mutable-pairs)
          (only (chezscheme) include)
          (aux-utils)
          (let-macros)
          (match))
  (include "aalists.scm"))
