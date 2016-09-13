dnl Copyright (C) 2016 The Meme Factory, Inc.  http://www.meme.com/
dnl
dnl    This file is part of PLHDB2.
dnl
dnl    PLHDB2 is free software; you can redistribute it and/or modify
dnl    it under the terms of the GNU General Public License as published by
dnl    the Free Software Foundation; either version 3 of the License, or
dnl    (at your option) any later version.
dnl
dnl    This program is distributed in the hope that it will be useful,
dnl    but WITHOUT ANY WARRANTY; without even the implied warranty of
dnl    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
dnl    GNU General Public License for more details.
dnl
dnl    You should have received a copy of the GNU General Public License
dnl    along with PLHDB2.  If not, see <http://www.gnu.org/licenses/>.
dnl
dnl Karl O. Pinc <kop@meme.com>
dnl
dnl Macros used to create tables.
dnl
dnl
dnl Define m4 macros so we don't have to type so much.
dnl (Or at least type stuff that's more fun.)
dnl
dnl Watch out for using the single quote char as it has speical
dnl meaning to m4.
dnl
dnl Bugs:
dnl
changequote([{[,]}])dnl m4 foolery so includes include only once.
dnl                     Once the macro is in the text, change the quotes back
ifdef([{[_tablemacros.m4]}], [{[changequote(`,')]}], [{[dnl
changequote(`,')dnl
dnl
dnl Standard test for having already included the file.
define(`_tablemacros.m4')dnl
dnl
dnl Don't output anything while defining macros.
divert(-1)

--
-- Constraints
--

-- A column cannot contain the empty string or only whitespace.
--
-- Syntax: empty_string_check(col)
--
-- Input:
--   col  Name of the column to check.
--
changequote([,])
define([empty_string_check], [           CONSTRAINT "$1: Cannot be empty or only whitespace characters"
                CHECK(btrim($1, E' \r\n\t\f\v') <> '')])dnl
changequote(`,')dnl  See above.

-- Done defining macros.
divert`'dnl

]}])dnl End of ifdef over the whole file.
