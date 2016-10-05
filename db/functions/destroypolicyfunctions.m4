dnl Copyright (C) 2016 The Meme Factory, Inc., http://www.meme.com/
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
include(`copyright.m4')
include(`functionmacros.m4')

DROP FUNCTION IF EXISTS biography_all_access(plh_studyid_type) CASCADE;
DROP FUNCTION IF EXISTS biography_search_access(plh_studyid_type) CASCADE;
DROP FUNCTION IF EXISTS biography_insert_access(plh_studyid_type) CASCADE;
DROP FUNCTION IF EXISTS biography_edit_access(plh_studyid_type) CASCADE;

DROP FUNCTION IF EXISTS
     fertility_all_access(INT) CASCADE;
DROP FUNCTION IF EXISTS
     fertility_search_access(INT) CASCADE;
DROP FUNCTION IF EXISTS
     fertility_insert_access(INT) CASCADE;
DROP FUNCTION IF EXISTS
     fertility_edit_access(INT) CASCADE;
