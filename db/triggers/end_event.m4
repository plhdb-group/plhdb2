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
-- end_event
--
SELECT 'end_event' AS table;

SELECT 'end_event_update_func' AS function;
CREATE FUNCTION end_event_update_func ()
  RETURNS trigger
  LANGUAGE plpgsql
  plh_function_set_search_path
  AS $$
  BEGIN
  -- Function for end_event insert and update triggers
  --
  -- GPL_notice(`  --', `2016', `The Meme Factory, Inc., http://www.meme.com/')

  IF OLD.Final <> NEW.final
    AND NEW.Final THEN
    -- Final StopTypes mean StopDate = DepartDate.
    PERFORM 1
      FROM biography
           JOIN fertility AS ffi ON (ffi.bid = biography.bid)
      WHERE ffi.stoptype = NEW.code
            AND biography.departdate <> ffi.stopdate;
    IF FOUND THEN
      RAISE EXCEPTION integrity_constraint_violation USING
            MESSAGE = 'Error on ' || TG_OP || ' of END_EVENT'
        , DETAIL = 'Key(Code) = (' || NEW.code
                   || '): Value (Final) = (' || NEW.final
                   || '): Cannot make Final = TRUE; there is a related '
                   || 'FERTILITY row using this Code for '
                   || 'a StopType but it''s related BIOGRAPHY.DepartDate '
                   || 'is not the fertility interval StopDate';
    END IF;
  END IF;

  RETURN NULL;
  END;
$$;


SELECT 'end_event_update_trigger' AS trigger;
CREATE TRIGGER end_event_update_trigger
  AFTER UPDATE
  ON end_event FOR EACH ROW
  EXECUTE PROCEDURE end_event_update_func();
