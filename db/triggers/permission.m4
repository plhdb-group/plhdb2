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
-- permission
--
SELECT 'permission' AS table;

SELECT 'permission_func' AS function;
CREATE FUNCTION permission_func ()
  RETURNS trigger
  LANGUAGE plpgsql
  plh_function_set_search_path
  AS $$
  DECLARE
    this_username permission.username%TYPE;
    this_oid permission.pid%TYPE;
    this_count INT;

  BEGIN
  -- Function for permission insert and update triggers
  --
  -- GPL_notice(`  --', `2016', `The Meme Factory, Inc., http://www.meme.com/')

  -- Username must be a role.
  -- Because this is not a constraint roles can go away.  So we
  -- check every row on PERMISSIONS on every insert or update to
  -- the table.  We are sure to report which Username value is the problem.
  SELECT permission.username, permission.pid
    INTO this_username,       this_oid
    FROM permission
    WHERE NOT EXISTS (
      SELECT 1
        FROM pg_roles
        WHERE pg_roles.rolname = permission.username
              AND pg_roles.rolcanlogin);
  IF FOUND THEN
    RAISE EXCEPTION integrity_constraint_violation USING
          MESSAGE = 'Error on ' || TG_OP || ' of PERMISSION'
        , DETAIL = 'Key (Pid) = (' || this_oid
                   || '): Value (Username) = (' || this_username
                   || '): PERMISSION.Username must be a PG_ROLES.Rolname '
                   || 'value of a role with login priviliges'
        , HINT = 'Problem discovered on ' || TG_OP
                  || ' of PERMISSION with Key (Pid) = ('
                  || NEW.pid
                  || '), Value (Username) = (' || NEW.username || ')';
    RETURN NULL;
  END IF;

  IF NEW.study <> 'plh_allstudies' THEN
    -- Study must be a study.sid.
    PERFORM 1
      FROM study
      WHERE study.sid = NEW.study;
    IF NOT FOUND THEN
      RAISE EXCEPTION integrity_constraint_violation USING
            MESSAGE = 'Error on ' || TG_OP || ' of PERMISSION'
          , DETAIL = 'Key (Pid) = (' || NEW.pid
                   || '): Value (Username) = (' || NEW.username
                   || '): Value (Study) = (' || NEW.study
                   || '): PERMISSION.Study must be ''plh_allstudies'' '
                   || 'or a STUDY.SId value';
      RETURN NULL;
    END IF;
  END IF;

  RETURN NULL;
  END;
$$;


SELECT 'permission_trigger' AS trigger;
CREATE TRIGGER permission_trigger
  AFTER INSERT OR UPDATE
  ON permission FOR EACH ROW
  EXECUTE PROCEDURE permission_func();
