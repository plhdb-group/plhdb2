# Copyright (C) 2013, 2016 The Meme Factory, Inc.  http://www.meme.com/
# Copyright (C) 2004, 2005, 2008, 2011 Karl O. Pinc, <kop@meme.com>
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

# You probably want to override the database with PLHDB_DB=plhdb
#  on the make command line.
ifeq ($(strip $(PLHDB_DB)),)
  export PLHDB_DB := plhdb_copy
endif
export ADMINUSER := plhdb_admin

# For invoking psql everywhere.
PSQL_ARGS = --tuples-only -q \
            -U $(ADMINUSER) -d $(PLHDB_DB)
