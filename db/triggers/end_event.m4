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


dnl plpgsql fragment for BLAH
dnl
dnl Syntax: BLAH(ARG)
dnl
dnl ARG   description
dnl
changequote({,})
define({BLAH},{
})dnl
changequote(`,')dnl

--  
-- end_event
--
SELECT 'end_event' AS table;

SELECT 'end_event_func' AS function;
CREATE FUNCTION end_event_func ()
  RETURNS trigger
  LANGUAGE plpgsql
  plh_function_set_search_path
  AS $$
  BEGIN
  -- Function for end_event insert and update triggers
  --
  -- GPL_notice(`  --', `2016', `The Meme Factory, Inc., http://www.meme.com/')

  IF TG_OP = 'UPDATE' THEN
    -- Death is a hardcoded constant.
    restrict_change(`END_EVENT', `Code', `plh_death')
  END IF;

  RETURN NULL;
  END;
$$;


SELECT 'end_event_delete_func' AS function;
CREATE FUNCTION end_event_delete_func ()
  RETURNS trigger
  LANGUAGE plpgsql
  plh_function_set_search_path
  AS $$
  -- Function for end_event delete trigger
  --
  -- GPL_notice(`  --', `2016', `The Meme Factory, Inc., http://www.meme.com/')

  DECLARE

  BEGIN

  -- Death is an hardcoded constant.
  restrict_delete(`END_EVENT', `Code', `plh_death')  

  RETURN NULL;
  END;
$$;


SELECT 'end_event_trigger' AS trigger;
CREATE TRIGGER end_event_trigger
  AFTER INSERT OR UPDATE
  ON end_event FOR EACH ROW
  EXECUTE PROCEDURE end_event_func();

SELECT 'end_event_delete_trigger' AS trigger;
CREATE TRIGGER end_event_delete_trigger
  AFTER DELETE
  ON end_event FOR EACH ROW
  EXECUTE PROCEDURE end_event_delete_func();
