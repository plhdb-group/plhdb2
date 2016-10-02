dnl Copyright (C) 2016 The Meme Factory, Inc.   http://www.meme.com/
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
dnl Constant data values hardcoded into the system.
dnl
dnl Karl O. Pinc <kop@meme.com>
dnl
changequote([{[,]}])dnl m4 foolery so includes include only once.
dnl                     Once the macro is in the text, change the quotes back
ifdef([{[_constants.m4]}], [{[changequote(`,')]}], [{[dnl
changequote(`,')dnl
dnl
dnl Standard test for having already included the file.
define(`_constants.m4')dnl
dnl
dnl Turn output off.  This file produces no output.
divert(-1)

dnl The row-level permissions
define(`plh_search', `search')
define(`plh_insert', `insert')
define(`plh_edit',   `edit')
define(`plh_all',    `all')

dnl The study that means "all studies"
define(`plh_allstudies', `all')

dnl BIOGRAPHY.BirthDate
define(`plh_minbirth', `1910-01-01')

dnl BIOGRAPHY.EntryDate
define(`plh_minentry', `1960-01-01')

dnl BIOGRAPHY.BGQual
define(`plh_bgcertain',   `C')
define(`plh_bguncertain', `U')

dnl BIOGRAPHY.FirstBorn
define(`plh_fb_yes', `Y')
define(`plh_fb_no',  `N')
define(`plh_fb_unk', `U')

dnl BIOGRAPHY.Sex
define(`plh_male',    `M')
define(`plh_female',  `F')
define(`plh_unk_sex', `U')

dnl Turn output back on
divert`'dnl
dnl
dnl
]}])dnl End of ifdef over the whole file.

