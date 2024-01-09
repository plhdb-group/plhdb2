# Generate help summary from Makefile content
# Copyright (C) 2019 The Meme Factory, Inc.  www.karlpinc.com
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Affero General Public License as
#   published by the Free Software Foundation, either version 3 of the
#   License, or (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Affero General Public License for more details.
#
#   You should have received a copy of the GNU Affero General Public License
#   along with this program.  If not, see <https://www.gnu.org/licenses/>.

# Use this by putting the following line into your Makefile:
# include help.mk
#
# Then, any lines in the makefiles that begin with "## ", or lines
# that contain only "##", are displayed as help text.  This allows
# user-documentation to be placed next to relevant makefile targets
# and rules.

help:
	@grep -Eh '^##($$| )' $(MAKEFILE_LIST) | sed -E 's/^##($$| )//'
