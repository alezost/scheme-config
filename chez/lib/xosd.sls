(library (xosd)
  (export
   osd?
   make-osd
   create-osd
   kill-osd
   show-osd
   hide-osd
   toggle-osd
   scroll-osd
   osd-number-of-lines
   osd-displayed?
   wait-while-osd-displayed
   set-osd!
   osd-align
   osd-position
   osd-bar-length
   osd-timeout
   osd-color
   osd-font
   osd-horizontal-offset
   osd-vertical-offset
   osd-outline-offset
   osd-shadow-offset
   osd-outline-color
   osd-shadow-color
   display-string-in-osd
   display-percentage-in-osd
   display-slider-in-osd)
  (import (chezscheme)
          (drecords)
          (only (aux-utils) parse-arg-syntax))
  (include "xosd.scm"))
