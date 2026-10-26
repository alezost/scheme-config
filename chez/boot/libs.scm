;;; libs.scm --- Initialization file to load shared libraries

(include "default.scm")

(define (load-libs)
  (load-shared-object "libc.so.6")
  (load-shared-object "libpulse.so")
  (load-shared-object "libxosd.so"))

(scheme-start
 (lambda file-names
   (load-libs)
   (for-each load file-names)
   (new-cafe)))

(scheme-script
 (lambda (file-name . args)
   (load-libs)
   (command-line (cons file-name args))
   (command-line-arguments args)
   (load file-name)))

(scheme-program
 (lambda (file-name . args)
   (load-libs)
   (command-line (cons file-name args))
   (command-line-arguments args)
   (load-program file-name)))

;;; libs.scm ends here
