(library (daemon user)
  (export show-osds
          hide-osds
          osd-sound
          osd-backlight
          osd-text
          toggle-clock-osd)
  (import (al osd)
          (daemon user sound)
          (daemon user backlight)
          (daemon user text)
          (daemon user clock)))
