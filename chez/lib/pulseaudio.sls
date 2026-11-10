(library (pulseaudio)
  (export sink-info
          sink-info?
          sink-info-channels
          sink-info-mute?
          current-sink
          get-sink-info
          number-of-channels
          set-volume
          set-mute
          disconnect
          volume->percent
          percent->volume)
  (import (chezscheme)
          (drecords)
          (match)
          (aux-utils)
          (al messages)
          (only (al misc) memoize))
  (include "pulseaudio.scm"))
