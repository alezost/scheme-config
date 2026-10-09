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

CHEZ = scheme
BOOTDIR = $(CURDIR)/boot
LIBDIR = $(CURDIR)/lib

CHEZ_WRAPPER = chez

# This is needed to make optional dependencies for $(SO_FILES) targets
# below.
.SECONDEXPANSION:
BOOT_SCM_FILES = $(shell find $(BOOTDIR) -name '*.scm')
BOOT_SO_FILES = $(BOOT_SCM_FILES:%.scm=%.so)
BOOT_FILES = $(BOOT_SCM_FILES:%.scm=%.boot)
LIB_SLS_FILES = $(shell find $(LIBDIR) -name '*.sls')
LIB_SO_FILES = $(LIB_SLS_FILES:%.sls=%.so)
SO_FILES = $(LIB_SO_FILES) $(BOOT_SO_FILES)

all: $(CHEZ_WRAPPER) boot lib

$(CHEZ_WRAPPER):
	@printf "⏺ Generating '$(CHEZ_WRAPPER)' shell script ...\n"
	@echo '#!/bin/sh' > $(CHEZ_WRAPPER)
	@echo 'exec $(CHEZ) --boot "$(BOOTDIR)/default.boot" "$$@"' >> $(CHEZ_WRAPPER)
	@chmod 755 $(CHEZ_WRAPPER)

boot: $(BOOT_FILES)

$(BOOT_FILES): %.boot: %.so
	echo '(make-boot-file "$@" (list (quote "scheme")) "$<")' | $(CHEZ) -q

lib: $(LIB_SO_FILES)

$(SO_FILES): %.so: $$(wildcard $$*.sls) $$(wildcard $$*.scm)
	@cd $(dir $<) && \
	echo '(compile-file "$<" "$@")' | $(CHEZ) -q

clean-boot:
	@printf "⏺ Cleaning boot files ...\n"
	$(RM) $(BOOT_FILES) $(BOOT_SO_FILES)

clean-lib:
	@printf "⏺ Cleaning libraries ...\n"
	$(RM) $(LIB_SO_FILES)

clean: clean-boot clean-lib
	$(RM) $(CHEZ_WRAPPER)

.PHONY: all boot lib clean clean-boot clean-lib

# Makefile ends here
