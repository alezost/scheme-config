(library (xosd)
  (export
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
   set-osd-align!
   set-osd-position!
   set-osd-bar-length!
   set-osd-timeout!
   set-osd-color!
   set-osd-font!
   set-osd-horizontal-offset!
   set-osd-vertical-offset!
   set-osd-outline-offset!
   set-osd-shadow-offset!
   set-osd-outline-color!
   set-osd-shadow-color!
   display-string-in-osd
   display-percentage-in-osd
   display-slider-in-osd)
  (import (chezscheme))
  (include "xosd.scm"))
