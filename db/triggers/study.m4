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
include(`macros.m4')dnl


--  
-- study
--
SELECT 'study' AS table;

SELECT 'study_delete_func' AS function;
CREATE FUNCTION study_delete_func ()
  RETURNS trigger
  LANGUAGE plpgsql
  SECURITY DEFINER
  plh_function_set_search_path
  AS $$
  -- Function for study delete trigger
  --
  -- GPL_notice(`  --', `2016', `The Meme Factory, Inc., http://www.meme.com/')

  DECLARE

  BEGIN

  PERFORM 1
    FROM permission
    WHERE permission.study = OLD.sid;
  IF FOUND THEN
    RAISE EXCEPTION integrity_constraint_violation USING
          MESSAGE = 'Error on ' || TG_OP || ' of STUDY'
        , DETAIL = 'Key (SId) = (' || OLD.sid
                   || '): PERMISSION rows exist with Study values '
                   || 'which reference this STUDY.SId';
    RETURN NULL;
  END IF;

  RETURN NULL;
  END;
$$;

SELECT 'study_delete_trigger' AS trigger;
CREATE TRIGGER study_delete_trigger
  AFTER DELETE
  ON study FOR EACH ROW
  EXECUTE PROCEDURE study_delete_func();
