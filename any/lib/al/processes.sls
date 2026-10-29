;;; processes.sls --- R6RS library to work with processes

(library (al processes)
  (export system-output
          system*-output)
  (import (rnrs)
          (only (chezscheme) include process)
          (match)
          (aux-utils)
          (only (al strings) mapconcat))
  (include "processes.chez.scm"))

;;; processes.sls ends here
