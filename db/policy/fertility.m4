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
dnl We use functions, here and elsewhere, because this makes it easier
dnl to write views.  The views exectute in the definer user context
dnl and it's easier to call a function than it is to re-create the
dnl function's logic in the view's SQL.
dnl
dnl Bugs:
dnl   This would likely perform a lot better if instead if we split each
dnl policy into 2, one to handle the access per BIOGRAPHY row and
dnl another to handle where access is granted to all studies and hence
dnl all BIOGRAPHY rows.  But there just aren't than may rows and the
dnl extra complication isn't worth it.

dnl m4 includes
include(`copyright.m4')dnl
include(`constants.m4')dnl

CREATE POLICY all_access ON fertility FOR ALL USING(
  fertility_all_access(bid));

CREATE POLICY search_access ON fertility FOR SELECT USING(
  fertility_search_access(bid));

CREATE POLICY insert_access ON fertility FOR INSERT WITH CHECK(
  fertility_insert_access(bid));

CREATE POLICY edit_access ON fertility FOR UPDATE USING(
  fertility_edit_access(bid));

