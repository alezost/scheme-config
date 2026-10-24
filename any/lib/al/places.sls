(library (al places)
  (export home-file
          bin-file
          config-file
          secret-config-file
          guix-config-file)
  (import (rnrs)
          (only (chezscheme) include)
          (al files)
          (al misc))
  (include "places.scm"))
