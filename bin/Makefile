# Copyright (C) 2016 The Meme Factory, Inc.  http://www.meme.com/
#
#    This file is part of PLHDB2.
#
#    PLDHB2 is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with PLHDB2.  If not, see <http://www.gnu.org/licenses/>.
#
# Karl O. Pinc <kop@meme.com>
#

TARGETS := plhdb-user-add

INCLUDE := ../db/include

DEPS := Makefile

all: $(TARGETS)

plhdb-user-add: plhdb-user-add.m4 $(INCLUDE)/*.m4 include/*.m4 $(DEPS)
	m4 -I $(INCLUDE) -I include plhdb-user-add.m4 > plhdb-user-add

.PHONY: clean
clean:
	rm -rf $(TARGETS)
