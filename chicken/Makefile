# Makefile --- GNU Makefile to build Chicken code

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

SCRIPTS = $(wildcard scripts/*.scm)
BINFILES = $(SCRIPTS:scripts/%.scm=bin/%)

LIBDIR = $(CURDIR)/lib
LIBDIRS =				\
  $(LIBDIR)  				\
  $(LIBDIR)/al				\

LIB_SCM_FILES = 				\
  $(LIBDIR)/match.scm			\
  $(LIBDIR)/al/al.fp-utils.scm

all: lib bin

lib: $(LIB_SCM_FILES)
	@for dir in $(LIBDIRS); do \
	  printf "⏵ Building $$dir ...\n" ; \
	  cd "$$dir" && \
	  chicken-install -no-install ; \
	done

bin: $(BINFILES)

bin/%: scripts/%.scm
	@printf "⏵ Compiling $< ...\n"
	@mkdir -p $(dir $@)
	csc -fixnum-arithmetic -O5 -o $@ $<

clean-bin:
	@printf "⏵ Cleaning binaries $< ...\n"
	$(RM) $(BINFILES)

clean-lib:
	@printf "⏵ Cleaning $(LIBDIR) ...\n"
	find $(LIBDIR) -type f \
	     \( -name "*.so" \
	     -o -name "*.o" \
	     -o -name "*.link" \
	     -o -name "*.build.sh" \
	     -o -name "*.install.sh" \
	     -o -name "*.import.scm" \
	     \) -delete

clean: clean-bin clean-lib

.PHONY: all bin lib clean clean-bin clean-lib

# Makefile ends here
