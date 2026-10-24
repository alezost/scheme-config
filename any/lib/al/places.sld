(define-library (al places)
  (export home-file
          bin-file
          config-file
          secret-config-file
          guix-config-file)
  (import (scheme base)
          (only (al files) build-file-name)
          (only (al misc) getenv))

  (cond-expand
    (guile
     (import (only (guile) define*))
     (export guix-script-file
             guix-system-file
             guix-manifest-file
             guix-profile
             guix-profile-file
             guix-user-profile-file
             guix-system-profile-file)
     (include "places.guile.scm"))
    (else))

  (include "places.scm"))
