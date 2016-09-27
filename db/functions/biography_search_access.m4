dnl Copyright (C) 2012, 2016 The Meme Factory, Inc., http://www.meme.com/
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
dnl m4 includes
include(`copyright.m4')
include(`constants.m4')
include(`functionmacros.m4')
dnl

CREATE OR REPLACE FUNCTION
       biography_search_access(studyid plh_studyid_type)
  RETURNS BOOLEAN
  LANGUAGE plpgsql
  STABLE
  LEAKPROOF
  SECURITY DEFINER
  plh_function_set_search_path
  AS $$
  -- 
  --
  -- GPL_notice(`  --', `2016', `The Meme Factory, Inc.  http://www.meme.com/')
  --
  -- Syntax: biography_search_access(studyid, uname)
  --
  -- Arguments:
  --   studyid  STUDY.SId of the biography row
  --
  -- Remarks:
  --   Defines the search_access policy for the BIOGRAPHY table.
  --
  -- Bugs:

  DECLARE

  BEGIN

  RETURN EXISTS(
    SELECT 1
      FROM permission
      WHERE (permission.study = studyid
             OR permission.study = 'plh_allstudies')
            AND permission.username = SESSION_USER
            AND (permission.access = 'plh_search'
                 OR permission.access = 'plh_insert'
                 OR permission.access = 'plh_edit'));
  END;
$$;
grant_func_priv(`biography_search_access(plh_studyid_type)')
