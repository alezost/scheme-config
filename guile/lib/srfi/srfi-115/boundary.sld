(define-library (srfi 115 boundary)
  (export char-set:regional-indicator
          char-set:extend-or-spacing-mark
          char-set:hangul-l
          char-set:hangul-v
          char-set:hangul-t
          char-set:hangul-lv
          char-set:hangul-lvt)
  (import (scheme base)
          (srfi 14))
  (include "boundary.scm"))
