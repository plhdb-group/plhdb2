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
    this_entrydate biography.entrydate%TYPE;
    this_departdate biography.departdate%TYPE;
    this_departdateerror biography.departdateerror%TYPE;
    this_startdate femalefertilityinterval.startdate%TYPE;
    this_stopdate femalefertilityinterval.stopdate%TYPE;
    this_ffiid femalefertilityinterval.ffiid%TYPE;

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
                   || '): Value (BIOGRAPHY.StudyId) = (' || this_studyid
                   || '): Value (BIOGRAPHY.AnimId) = (' || this_animid
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
                   || '): Value (BIOGRAPHY.StudyId) = (' || this_studyid
                   || '): Value (BIOGRAPHY.AnimId) = (' || this_animid
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
                   || '): Value (BIOGRAPHY.StudyId) = (' || this_studyid
                   || '): Value (BIOGRAPHY.AnimId) = (' || this_animid
                   || '): Value (BIOGRAPHY.DepartDate) = (' || this_departdate
                   || '): Value (BIOGRAPHY.DepartDateError) = ('
                   || this_departdateerror
                   || '): StopDate cannot be after the DepartDate + '
                   || '(DepartDateError years) of the related BIOGRAPHY '
                   || 'row; the computed last departure date is: '
                   || last_departdate(this_departdate, this_departdateerror);
  END IF;

  -- StartDate cannot be before EntryDate.
  SELECT biography.studyid, biography.animid, biography.entrydate
    INTO this_studyid,      this_animid,      this_entrydate
    FROM biography
    WHERE biography.bid = NEW.bid
          AND NEW.startdate < biography.entrydate;
  IF FOUND THEN
    RAISE EXCEPTION integrity_constraint_violation USING
          MESSAGE = 'Error on ' || TG_OP || ' of FEMALEFERTILITYINTERVAL'
        , DETAIL = 'Key(FFIId) = (' || NEW.ffiid
                   || '): Value (BId) = (' || NEW.Bid
                   || '): Value(StartDate) = (' || NEW.startdate
                   || '): Value (BIOGRAPHY.StudyId) = (' || this_studyid
                   || '): Value (BIOGRAPHY.AnimId) = (' || this_animid
                   || '): Value (BIOGRAPHY.EntryDate) = (' || this_entrydate
                   || '): StartDate cannot be before the EntryDate '
                   || 'of the related BIOGRAPHY row';
  END IF;

  -- Female fertility intervals cannot overlap.
  SELECT biography.studyid, biography.animid,
         ffi.ffiid,  ffi.startdate,  ffi.stopdate
    INTO this_studyid,      this_animid,
         this_ffiid, this_startdate, this_stopdate
    FROM femalefertilityinterval AS ffi
         JOIN biography ON (biography.bid = NEW.bid)
    WHERE ffi.ffiid <> NEW.ffiid
          AND ffi.bid = NEW.bid
          AND ((NEW.startdate <= ffi.startdate
                AND ffi.startdate <= NEW.stopdate)
               OR (NEW.startdate <= ffi.stopdate
                   AND ffi.stopdate <= NEW.stopdate));
  IF FOUND THEN
    RAISE EXCEPTION integrity_constraint_violation USING
          MESSAGE = 'Error on ' || TG_OP || ' of FEMALEFERTILITYINTERVAL'
        , DETAIL = 'Key(FFIId) = (' || NEW.ffiid
                   || '): Value (BId) = (' || NEW.Bid
                   || '): Value (BIOGRAPHY.StudyId) = (' || this_studyid
                   || '): Value (BIOGRAPHY.AnimId) = (' || this_animid
                   || '): Value(StartDate) = (' || NEW.startdate
                   || '): Value(StopDate) = (' || NEW.stopdate
                   || '): Key(Other FFIId) = (' || this_ffiid
                   || '): Value(Other StartDate) = (' || this_startdate
                   || '): Value(Other StopDate) = (' || this_stopdate
                   || '): The female fertility intervals of a single '
                   || 'individual cannot overlap';
  END IF;

  RETURN NULL;
  END;
$$;


SELECT 'femalefertilityinterval_trigger' AS trigger;
CREATE TRIGGER femalefertilityinterval_trigger
  AFTER INSERT OR UPDATE
  ON femalefertilityinterval FOR EACH ROW
  EXECUTE PROCEDURE femalefertilityinterval_func();
