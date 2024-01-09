# Copyright (C) 2016, 2024 The Meme Factory, Inc.  http://www.karlpinc.com/
#
#    This file is part of PLHDB2.
#
#    PLHDB2 is free software; you can redistribute it and/or modify
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

include ../help.mk
## ############################################################################
##                         Utility Script Installation
##
## Variables:
##

##    INSTALL_DIR        The directory into which the scripts are installed.
##                       Defaults to: /usr/local/bin
INSTALL_DIR := /usr/local/bin

##
## The following targets may be used:
##

TARGETS := plhdb-user-add

INCLUDE := ../db/include

DEPS := Makefile

all: $(TARGETS)

##   plhdb-user-add      Construct the plhdb-user-add script
plhdb-user-add: plhdb-user-add.m4 $(INCLUDE)/*.m4 include/*.m4 $(DEPS)
	m4 -I $(INCLUDE) -I include plhdb-user-add.m4 > plhdb-user-add

##   clean               Cleanup generated files, etc., in the checked out git
##                       repo that are not under revsion control.
.PHONY: clean
clean:
	rm -rf $(TARGETS)
