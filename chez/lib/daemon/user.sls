;;; user.sls --- Library with user config for Chez Daemon

(library (daemon user)
  (export action
          device
          show-osds
          hide-osds
          osd-sound
          osd-backlight
          osd-text
          osd-clock)
  (import (rnrs)
          (only (chezscheme) include format)
          (match)
          (let-macros)
          (al osd)
          (daemon user osd)
          (daemon user sound)
          (daemon user backlight)
          (daemon user text)
          (daemon user device)
          (daemon user clock))
  (include "user.scm"))

;;; user.sls ends here
