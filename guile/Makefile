# Makefile --- GNU Makefile to build Guile code

# Copyright © 2017–2026 Alex Kost <alezost@gmail.com>

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

.SECONDEXPANSION:

LIBDIR = $(CURDIR)/lib
LIB_SLD_FILES = 			\
  $(LIBDIR)/match.sld			\
  $(LIBDIR)/aux-utils.sld		\
  $(LIBDIR)/let-macros.sld		\
  $(LIBDIR)/drecords.sld		\
  $(LIBDIR)/srfi/srfi-115/boundary.sld	\
  $(LIBDIR)/srfi/srfi-115.sld		\
  $(LIBDIR)/al/lists.sld		\
  $(LIBDIR)/al/strings.sld		\
  $(LIBDIR)/al/misc.sld			\
  $(LIBDIR)/al/files.sld		\
  $(LIBDIR)/al/places.sld		\
  $(LIBDIR)/al/messages.sld		\
  $(LIBDIR)/al/processes.sld		\
  $(LIBDIR)/al/backlight.sld		\
  $(LIBDIR)/al/osd.sld
LIB_GO_FILES = $(LIB_SLD_FILES:%.sld=%.go)

SCRIPTS_DIR = $(CURDIR)/scripts
SCRIPTS = $(shell find -L $(SCRIPTS_DIR) -mindepth 1)

GUILEC_ENV =					\
  GUILE_AUTO_COMPILE=0

GUILEC_OPTS =					\
  -Warity-mismatch				\
  -Wformat					\
  -Wunbound-variable

GUILEC_ENV +=								\
  GUILE_WARN_DEPRECATED=detailed					\
  GUILE_LOAD_PATH="$(LIBDIR):$$GUILE_LOAD_PATH"				\
  GUILE_LOAD_COMPILED_PATH="$(LIBDIR):$$GUILE_LOAD_COMPILED_PATH"

all: lib

lib: $(LIB_GO_FILES)

$(LIBDIR)/%.go: $(LIBDIR)/%.sld \
		$$(wildcard $(LIBDIR)/%.scm) \
		$$(wildcard $(LIBDIR)/%.guile.scm)
	@cd $(LIBDIR) && \
	$(GUILEC_ENV) guild compile $(GUILEC_OPTS) --output=$@ $<

scripts:
	@$(GUILEC_ENV) guild compile $(GUILEC_OPTS) $(SCRIPTS)

clean-lib:
	@printf "⏵ Cleaning libraries ...\n"
	$(RM) $(LIB_GO_FILES)

clean: clean-lib

.PHONY: lib scripts clean clean-lib

# Makefile ends here
