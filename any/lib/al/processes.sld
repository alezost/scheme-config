;;; processes.sld --- R7RS library to work with processes

(define-library (al processes)
  (import (except (scheme base) read-string)
          (aux-utils))

  (cond-expand
    (guile
     (export environment-excursion
             with-environment-excursion
             system*-output
             system*-no-output
             process-exists?)
     (import (only (guile)
                   define*
                   environ system* status:exit-val)
             (ice-9 rdelim)
             (ice-9 ports)
             (ice-9 popen))
     (include "processes.guile.scm"))

    (else)))

;;; processes.sld ends here
