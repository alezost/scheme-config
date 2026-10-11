# Makefile --- GNU Makefile to build Scheme code

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

LIBDIR = $(CURDIR)/any/lib
LIB_SLD_FILES = $(shell find $(LIBDIR) -name '*.sld')

IMPLS = guile chez chicken

all: lib $(IMPLS)

lib: $(LIB_SLD_FILES)

$(LIB_SLD_FILES): %.sld: %.scm
	@touch "$@"

$(IMPLS): lib
	@printf "⏺ Building '$@' sub-directory ...\n"
	cd "$@" && $(MAKE)

.PHONY: lib $(IMPLS)

# Makefile ends here
