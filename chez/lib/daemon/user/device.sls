(library (daemon user device)
  (export device)
  (import (rnrs)
          (only (chezscheme)
                include process format
                sleep make-time
                fork-thread)
          (only (srfi :1) last)
          (only (srfi :13)
                string-contains
                string-trim-right)
          (match)
          (let-macros)
          (al files)
          (only (al strings) split-string)
          (daemon user osd)
          (daemon user text))
  (include "device.scm"))
