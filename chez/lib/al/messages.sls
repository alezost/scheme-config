(library (al messages)
  (export message
          message0
          message1
          print-output
          print-error
          leave)
  (import (rnrs)
          (only (chezscheme) include format)
          (srfi :26))
  (include "messages.scm"))
