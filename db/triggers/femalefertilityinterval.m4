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
-- femalefertilityinterval
--
SELECT 'femalefertilityinterval' AS table;

SELECT 'femalefertilityinterval_func' AS function;
CREATE FUNCTION femalefertilityinterval_func ()
  RETURNS trigger
  LANGUAGE plpgsql
  plh_function_set_search_path
  AS $$
  DECLARE
    this_studyid biography.studyid%TYPE;
    this_animid biography.animid%TYPE;
    this_sex biography.sex%TYPE;
    this_departdate biography.departdate%TYPE;
    this_departdateerror biography.departdateerror%TYPE;

  BEGIN
  -- Function for femalefertilityinterval insert and update triggers
  --
  -- GPL_notice(`  --', `2016', `The Meme Factory, Inc., http://www.meme.com/')

  -- MomOnly rows cannot have related FEMALEFERTILITYINTERVAL rows.
  SELECT biography.studyid, biography.animid
    INTO this_studyid,      this_animid
    FROM biography
    WHERE biography.bid = NEW.bid
          AND biography.momonly;
  IF FOUND THEN
    RAISE EXCEPTION integrity_constraint_violation USING
          MESSAGE = 'Error on ' || TG_OP || ' of FEMALEFERTILITYINTERVAL'
        , DETAIL = 'Key(FFIId) = (' || NEW.ffiid
                   || '): Value (BId) = (' || NEW.Bid
                   || '): Value (BIOGRAPHY.AnimId) = (' || this_animid
                   || '): Value (BIOGRAPHY.StudyId) = (' || this_studyid
                   || '): Individuals with BIOGRAPHY.MomOnly = TRUE '
                   || 'cannot have related FEMALEFERTILITYINTERVAL rows';
  END IF;

  -- Non-female individuals cannot have related FEMALEFERTILITYINTERVAL rows.
  SELECT biography.studyid, biography.animid, biography.sex
    INTO this_studyid,      this_animid,      this_sex
    FROM biography
    WHERE biography.bid = NEW.bid
          AND biography.sex <> 'plh_female';
  IF FOUND THEN
    RAISE EXCEPTION integrity_constraint_violation USING
          MESSAGE = 'Error on ' || TG_OP || ' of FEMALEFERTILITYINTERVAL'
        , DETAIL = 'Key(FFIId) = (' || NEW.ffiid
                   || '): Value (BId) = (' || NEW.Bid
                   || '): Value (BIOGRAPHY.AnimId) = (' || this_animid
                   || '): Value (BIOGRAPHY.StudyId) = (' || this_studyid
                   || '): Value (BIOGRAPHY.Sex) = (' || this_sex
                   || '): Only individuals with BIOGRAPHY.Sex = '
                   || '''plh_female'' can have related '
                   || 'FEMALEFERTILITYINTERVAL rows';
  END IF;

  -- StopDate cannot be after DepartDate + (DepartDateError years)
  SELECT biography.studyid, biography.animid, biography.departdate
       , biography.departdateerror
    INTO this_studyid,      this_animid,      this_departdate
       , this_departdateerror
    FROM biography
    WHERE biography.bid = NEW.bid
          AND last_departdate(biography.departdate, biography.departdateerror)
              < NEW.stopdate;
  IF FOUND THEN
    RAISE EXCEPTION integrity_constraint_violation USING
          MESSAGE = 'Error on ' || TG_OP || ' of FEMALEFERTILITYINTERVAL'
        , DETAIL = 'Key(FFIId) = (' || NEW.ffiid
                   || '): Value (BId) = (' || NEW.Bid
                   || '): Value(StopDate) = (' || NEW.stopdate
                   || '): Value (BIOGRAPHY.AnimId) = (' || this_animid
                   || '): Value (BIOGRAPHY.StudyId) = (' || this_studyid
                   || '): Value (BIOGRAPHY.DepartDate) = (' || this_departdate
                   || '): Value (BIOGRAPHY.DepartDateError) = ('
                   || this_departdateerror
                   || '): StopDate cannot be after the DepartDate + '
                   || '(DepartDateError years) of the related BIOGRAPHY '
                   || 'row; the computed last departure date is: '
                   || last_departdate(this_departdate, this_departdateerror);
  END IF;

  RETURN NULL;
  END;
$$;


SELECT 'femalefertilityinterval_trigger' AS trigger;
CREATE TRIGGER femalefertilityinterval_trigger
  AFTER INSERT OR UPDATE
  ON femalefertilityinterval FOR EACH ROW
  EXECUTE PROCEDURE femalefertilityinterval_func();
