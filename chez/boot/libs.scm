;;; libs.scm --- Initialization file to load shared libraries

(include "default.scm")

(scheme-start
 (lambda file-names
   (load-shared-object "libc.so.6")
   (load-shared-object "libxosd.so")
   (for-each load file-names)
   (new-cafe)))

;;; libs.scm ends here
