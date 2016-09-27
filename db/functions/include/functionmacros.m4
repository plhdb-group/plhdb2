dnl Copyright (C) 2016 The Meme Factory, Inc.  http://www.meme.com/
dnl
dnl    This file is part of PLHDB2.
dnl
dnl    PLDHB2 is free software; you can redistribute it and/or modify
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
dnl    along with Babase.  If not, see <http://www.gnu.org/licenses/>.
dnl
dnl M4 macros for making functions to support PLHDB on the server side.
dnl Karl O. Pinc <kop@meme.com>
dnl
dnl
dnl m4 includes
include(`copyright.m4')
include(`globalmacros.m4')
dnl
dnl Don't ouput while defining functions.
divert(-1)


dnl Grant privliges to a function.
dnl
dnl This also prints the name of the function.  As every function has
dnl priviliges granted on it we get to monitor progress this way.
dnl
dnl Syntax: grant_func_priv(function_declaration)
changequote([,])
define([grant_func_priv],[
GRANT EXECUTE ON FUNCTION $1
  TO GROUP plhdb_users;
GRANT EXECUTE ON FUNCTION $1
  TO GROUP plhdb_managers;
SELECT '$1' AS done_with;
])
changequote(`,')

dnl Turn output back on.
divert`'dnl
