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

dnl m4 includes
include(`copyright.m4')dnl
include(`constants.m4')dnl

CREATE POLICY all_access ON biography FOR ALL USING(
  biography_all_access(studyid));

CREATE POLICY search_access ON biography FOR SELECT USING(
  biography_search_access(studyid));

CREATE POLICY insert_access ON biography FOR INSERT WITH CHECK(
  biography_insert_access(studyid));

CREATE POLICY edit_access ON biography FOR UPDATE USING(
  biography_edit_access(studyid));

