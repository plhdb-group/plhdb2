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
# Remarks:
# Write sql code that drops all tables.  Table names supplied,
# separated by whitespace, on stdin in reverse order from that in
# which they should be dropped.
#
# Karl O. Pinc <kop@meme.com>
#

xargs -n 1 printf '%s\n' \
  | tac \
  | xargs printf 'DROP VIEW IF EXISTS %s CASCADE;\n'
