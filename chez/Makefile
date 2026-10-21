# Makefile --- GNU Makefile to build Chez code

# Copyright © 2026 Alex Kost <alezost@gmail.com>

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

BOOTDIR = $(CURDIR)/boot
SRCLIBDIR = $(CURDIR)/lib

# I tried to keep ".so" files separately from source files.  But in this
# case, Chez may complain like this:
#
#   Exception: run-time information for library (foo) has not been loaded
#
# while working with Chez using Geiser.  So just compile everything in
# the source tree (as it is done with Guile and Chicken).
#
# BLDLIBDIR = $(CURDIR)/build/lib
BLDLIBDIR = $(SRCLIBDIR)

CHEZ = scheme
# CHEZ_WRAPPER is a script to build .so files and CHEZ_FULL is a user
# replacement for "scheme".
CHEZ_WRAPPER = $(CURDIR)/chez
CHEZ_FULL = $(CURDIR)/chez-libs
CHEZ_DAEMON = $(CURDIR)/daemon/chez-daemon
DAEMON_SCM = $(CURDIR)/daemon/daemon.scm
DAEMON_SO = $(DAEMON_SCM:%.scm=%.so)

# This is needed to make optional dependencies for $(LIB_SO_FILES)
# targets below.
.SECONDEXPANSION:

BOOT_SCM_FILES = $(shell find $(BOOTDIR) -name '*.scm')
BOOT_SO_FILES = $(BOOT_SCM_FILES:%.scm=%.so)
BOOT_FILES = $(BOOT_SCM_FILES:%.scm=%.boot)

LIB_SLS_FILES = 			\
  $(SRCLIBDIR)/lib-aux.sls		\
  $(SRCLIBDIR)/let-opt.sls		\
  $(SRCLIBDIR)/srfi/srfi-0.sls		\
  $(SRCLIBDIR)/srfi/srfi-26.sls		\
  $(SRCLIBDIR)/match.sls		\
  $(SRCLIBDIR)/aux-utils.sls		\
  $(SRCLIBDIR)/let-macros.sls		\
  $(SRCLIBDIR)/drecords.sls		\
  $(SRCLIBDIR)/srfi/srfi-8.sls		\
  $(SRCLIBDIR)/srfi/srfi-9.sls		\
  $(SRCLIBDIR)/srfi/srfi-23.sls		\
  $(SRCLIBDIR)/srfi/srfi-1.sls		\
  $(SRCLIBDIR)/srfi/srfi-14.sls		\
  $(SRCLIBDIR)/xosd.sls			\
  $(SRCLIBDIR)/daemon.sls		\
  $(SRCLIBDIR)/al/messages.sls		\
  $(SRCLIBDIR)/al/osd.sls

LIB_SO_FILES = $(LIB_SLS_FILES:$(SRCLIBDIR)/%.sls=$(BLDLIBDIR)/%.so)

all: $(CHEZ_WRAPPER) $(CHEZ_FULL) boot lib daemon

CHEZ_WRAPPER_EXEC_STRING = \
'exec $(CHEZ)\
 --libdirs "$(BLDLIBDIR)"\
 --boot "$(BOOTDIR)/default.boot"\
 "$$@"'

CHEZ_FULL_EXEC_STRING = \
'exec $(CHEZ)\
 --libdirs "$(BLDLIBDIR)"\
 --boot "$(BOOTDIR)/libs.boot"\
 "$$@"'

CHEZ_DAEMON_EXEC_STRING = \
'exec $(CHEZ)\
 --libdirs "$(BLDLIBDIR)"\
 --boot "$(BOOTDIR)/libs-quiet.boot"\
 --program "$(DAEMON_SO)"\
 "$$@"'

define make-shell-script
@printf "⏵ Generating '$($(1))' shell script ...\n"
@echo '#!/bin/sh' > $($(1))
@echo $($(1)_EXEC_STRING) >> $($(1))
@chmod 755 $($(1))
endef

$(CHEZ_WRAPPER):
	$(call make-shell-script,CHEZ_WRAPPER)

$(CHEZ_FULL):
	$(call make-shell-script,CHEZ_FULL)

$(CHEZ_DAEMON):
	$(call make-shell-script,CHEZ_DAEMON)

daemon: $(CHEZ_DAEMON) $(DAEMON_SO)

boot: $(BOOT_FILES)

$(BOOT_FILES): %.boot: %.so
	echo '(make-boot-file "$@" (list (quote "scheme")) "$<")' | $(CHEZ) -q

$(BOOT_SO_FILES): %.so: %.scm
	@cd $(dir $<) && \
	echo '(compile-file "$<" "$@")' | $(CHEZ) -q

$(BOOTDIR)/libs.scm: $(BOOTDIR)/default.scm
$(BOOTDIR)/libs-quiet.scm: $(BOOTDIR)/libs.scm
$(BOOT_SCM_FILES):
	@touch "$@"

$(BLDLIBDIR)/%.so: $(SRCLIBDIR)/%.sls \
		   $$(wildcard $(SRCLIBDIR)/%.scm) \
		   $$(wildcard $(SRCLIBDIR)/%.chez.scm) \
		   $(CHEZ_WRAPPER)
	@mkdir -p $(dir $@)
	@cd $(dir $<) && \
	echo '(compile-file "$<" "$@")' | $(CHEZ_WRAPPER) -q

$(DAEMON_SO): $(DAEMON_SCM) $(CHEZ_WRAPPER)
	@cd $(dir $<) && \
	echo '(compile-program "$<" "$@")' | $(CHEZ_WRAPPER) -q

lib: $(LIB_SO_FILES)

clean-boot:
	@printf "⏵ Cleaning boot files ...\n"
	$(RM) $(BOOT_FILES) $(BOOT_SO_FILES)

clean-daemon:
	@printf "⏵ Cleaning daemon files ...\n"
	$(RM) $(CHEZ_DAEMON) $(DAEMON_SO) $(DAEMON_SO:%.so=%.wpo)

clean-lib:
	@printf "⏵ Cleaning libraries ...\n"
	$(RM) $(LIB_SO_FILES) $(LIB_SO_FILES:%.so=%.wpo)

clean: clean-boot clean-lib
	$(RM) $(CHEZ_WRAPPER) $(CHEZ_FULL)

.PHONY: all boot daemon lib clean clean-boot clean-daemon clean-lib

# Makefile ends here
