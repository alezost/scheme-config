(define-library (al messages)
  (export message
          message0
          message1
          print-output
          print-error
          leave)
  (import (scheme base)
          (scheme process-context)
          (srfi 26))
  (cond-expand
    (guile (import (ice-9 format)))
    (chicken (import (chicken format)))
    (else))
  (include "messages.scm"))
