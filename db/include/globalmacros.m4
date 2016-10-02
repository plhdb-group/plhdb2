dnl Copyright (C) 2016 The Meme Factory, Inc.  http://www.meme.com/
dnl
dnl    This file is part of PLHDB.
dnl
dnl    PLHDB is free software; you can redistribute it and/or modify
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
dnl    along with PLHDB.  If not, see <http://www.gnu.org/licenses/>.
dnl
dnl Karl O. Pinc <kop@meme.com>
dnl
dnl
dnl Macros that are used by multiple subdirectories.
dnl
dnl
changequote([{[,]}])dnl m4 foolery so includes include only once.
dnl                     Once the macro is in the text, change the quotes back
ifdef([{[_globalmacros.m4]}], [{[changequote(`,')]}], [{[dnl
changequote(`,')dnl
dnl
dnl Standard test for having already included the file.
define(`_globalmacros.m4')dnl
dnl
dnl
dnl Discard any output.  Copyright and edit warning is all that's output.
divert(-1)

dnl m4 includes
include(`constants.m4')


dnl SET clause used in all function definition statements.
dnl This secures the function so that it does not operate on unexpected
dnl objects.
define(`plh_function_search_path', `plhdb, pg_temp')
define(`plh_function_set_search_path', `SET search_path = plh_function_search_path')


dnl The datatype of the study id.  We use this in too many places to
dnl want to re-type it.
define(`plh_studyid_type', `VARCHAR(12)')

dnl The expression used to calculate last_departdate().
dnl Easier to inline that to use a function in a constraint.
changequote([,])
define([plh_last_departdate_inline],[
         departdate
         + CEIL(departdateerror * 'plh_days_in_year'::DOUBLE PRECISION)::INT])
changequote(`,')dnl  See above.

dnl Turn output back on
divert`'dnl
]}])dnl End of ifdef over the whole file.
