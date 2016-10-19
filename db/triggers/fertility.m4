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
-- fertility
--
SELECT 'fertility' AS table;

SELECT 'fertility_func' AS function;
CREATE FUNCTION fertility_func ()
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
    this_startdate fertility.startdate%TYPE;
    this_stopdate fertility.stopdate%TYPE;
    this_fid fertility.fid%TYPE;

  BEGIN
  -- Function for fertility insert and update triggers
  --
  -- GPL_notice(`  --', `2016', `The Meme Factory, Inc., http://www.meme.com/')

  IF TG_OP = 'UPDATE' THEN
    cannot_change(`FERTILITY', `FId')
  END IF;

  -- MomOnly rows cannot have related FERTILITY rows.
  SELECT biography.studyid, biography.animid
    INTO this_studyid,      this_animid
    FROM biography
    WHERE biography.bid = NEW.bid
          AND biography.momonly;
  IF FOUND THEN
    RAISE EXCEPTION integrity_constraint_violation USING
          MESSAGE = 'Error on ' || TG_OP || ' of FERTILITY'
        , DETAIL = 'Key(FId) = (' || NEW.fid
                   || '): Value (BId) = (' || NEW.Bid
                   || '): Value (BIOGRAPHY.StudyId) = (' || this_studyid
                   || '): Value (BIOGRAPHY.AnimId) = (' || this_animid
                   || '): Individuals with BIOGRAPHY.MomOnly = TRUE '
                   || 'cannot have related FERTILITY rows';
  END IF;

  -- Non-female individuals cannot have related FERTILITY rows.
  SELECT biography.studyid, biography.animid, biography.sex
    INTO this_studyid,      this_animid,      this_sex
    FROM biography
    WHERE biography.bid = NEW.bid
          AND biography.sex <> 'plh_female';
  IF FOUND THEN
    RAISE EXCEPTION integrity_constraint_violation USING
          MESSAGE = 'Error on ' || TG_OP || ' of FERTILITY'
        , DETAIL = 'Key(FId) = (' || NEW.fid
                   || '): Value (BId) = (' || NEW.Bid
                   || '): Value (BIOGRAPHY.StudyId) = (' || this_studyid
                   || '): Value (BIOGRAPHY.AnimId) = (' || this_animid
                   || '): Value (BIOGRAPHY.Sex) = (' || this_sex
                   || '): Only individuals with BIOGRAPHY.Sex = '
                   || '''plh_female'' can have related '
                   || 'FERTILITY rows';
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
          MESSAGE = 'Error on ' || TG_OP || ' of FERTILITY'
        , DETAIL = 'Key(FId) = (' || NEW.fid
                   || '): Value (BId) = (' || NEW.Bid
                   || '): Value(StopDate) = (' || NEW.stopdate
                   || '): Value (BIOGRAPHY.StudyId) = (' || this_studyid
                   || '): Value (BIOGRAPHY.AnimId) = (' || this_animid
                   || '): Value (BIOGRAPHY.DepartDate) = (' || this_departdate
                   || '): Value (BIOGRAPHY.DepartDateError) = ('
                   || this_departdateerror
                   || '): StopDate cannot follow the DepartDate + '
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
          MESSAGE = 'Error on ' || TG_OP || ' of FERTILITY'
        , DETAIL = 'Key(FId) = (' || NEW.fid
                   || '): Value (BId) = (' || NEW.Bid
                   || '): Value(StartDate) = (' || NEW.startdate
                   || '): Value (BIOGRAPHY.StudyId) = (' || this_studyid
                   || '): Value (BIOGRAPHY.AnimId) = (' || this_animid
                   || '): Value (BIOGRAPHY.EntryDate) = (' || this_entrydate
                   || '): StartDate cannot precede the EntryDate '
                   || 'of the related BIOGRAPHY row';
  END IF;

  -- Female fertility intervals cannot overlap.
  SELECT biography.studyid, biography.animid,
         ffi.fid,  ffi.startdate,  ffi.stopdate
    INTO this_studyid,      this_animid,
         this_fid, this_startdate, this_stopdate
    FROM fertility AS ffi
         JOIN biography ON (biography.bid = NEW.bid)
    WHERE ffi.fid <> NEW.fid
          AND ffi.bid = NEW.bid
          AND ((NEW.startdate <= ffi.startdate
                AND ffi.startdate <= NEW.stopdate)
               OR (NEW.startdate <= ffi.stopdate
                   AND ffi.stopdate <= NEW.stopdate));
  IF FOUND THEN
    RAISE EXCEPTION integrity_constraint_violation USING
          MESSAGE = 'Error on ' || TG_OP || ' of FERTILITY'
        , DETAIL = 'Key(FId) = (' || NEW.fid
                   || '): Value (BId) = (' || NEW.Bid
                   || '): Value (BIOGRAPHY.StudyId) = (' || this_studyid
                   || '): Value (BIOGRAPHY.AnimId) = (' || this_animid
                   || '): Value(StartDate) = (' || NEW.startdate
                   || '): Value(StopDate) = (' || NEW.stopdate
                   || '): Key(Other FId) = (' || this_fid
                   || '): Value(Other StartDate) = (' || this_startdate
                   || '): Value(Other StopDate) = (' || this_stopdate
                   || '): The female fertility intervals of a single '
                   || 'individual cannot overlap';
  END IF;

  RETURN NULL;
  END;
$$;

SELECT 'fertility_commit_func' AS function;
CREATE OR REPLACE FUNCTION fertility_commit_func()
  RETURNS trigger
  LANGUAGE plpgsql
  plh_function_set_search_path
  AS $$
  -- Function for fertility insert and update
  -- fired upon transaction commit.
  --
  -- GPL_notice(`  --', `2016', `The Meme Factory, Inc.  http://www.meme.com/')
  --
  DECLARE
    this_studyid biography.studyid%TYPE;
    this_animid biography.animid%TYPE;
    this_entrydate biography.entrydate%TYPE;
    this_entrytype biography.entrytype%TYPE;
    this_departdate biography.departdate%TYPE;
    this_departtype biography.departtype%TYPE;

  BEGIN

  -- Get the latest values of the row
  SELECT *
    INTO NEW
    FROM fertility
    WHERE fertility.fid = NEW.fid;
  IF NOT FOUND THEN
    -- Whatever row was inserted was subsequently deleted.
    -- Nothing to do.
    RETURN NULL;
  END IF;

  -- Initial StartTypes mean StartDate = EntryDate.
  SELECT biography.studyid, biography.animid, biography.entrydate
    INTO this_studyid,      this_animid,      this_entrydate
    FROM biography
         JOIN start_event ON (start_event.code = NEW.starttype)
    WHERE biography.bid = NEW.bid
          AND biography.entrydate <> NEW.startdate
          AND start_event.initial;
  IF FOUND THEN
    RAISE EXCEPTION integrity_constraint_violation USING
          MESSAGE = 'Error on FERTILITY ' || TG_OP || ' commit'
        , DETAIL = 'Key(FId) = (' || NEW.fid
                   || '): Value (BId) = (' || NEW.Bid
                   || '): Value(StartDate) = (' || NEW.startdate
                   || '): Value(StartType) = (' || NEW.starttype
                   || '): Value (BIOGRAPHY.StudyId) = (' || this_studyid
                   || '): Value (BIOGRAPHY.AnimId) = (' || this_animid
                   || '): Value (BIOGRAPHY.EntryDate) = (' || this_entrydate
                   || '): StartDate must be the BIOGRAPHY.EntryDate when '
                   || 'StartType is an Initial START_EVENT'
        , HINT = 'Look at the rows of the START_EVENT table to see which '
                 || 'events are Initial events; the (' || NEW.starttype
                 || ') StartType is one.';
  END IF;

  -- Final StopTypes mean StopDate = DepartDate.
  SELECT biography.studyid, biography.animid, biography.departdate
    INTO this_studyid,      this_animid,      this_departdate
    FROM biography
         JOIN end_event ON (end_event.code = NEW.stoptype)
    WHERE biography.bid = NEW.bid
          AND biography.departdate <> NEW.stopdate
          AND end_event.final;
  IF FOUND THEN
    RAISE EXCEPTION integrity_constraint_violation USING
          MESSAGE = 'Error on FERTILITY ' || TG_OP || ' commit'
        , DETAIL = 'Key(FId) = (' || NEW.fid
                   || '): Value (BId) = (' || NEW.Bid
                   || '): Value(StopDate) = (' || NEW.stopdate
                   || '): Value(StopType) = (' || NEW.stoptype
                   || '): Value (BIOGRAPHY.StudyId) = (' || this_studyid
                   || '): Value (BIOGRAPHY.AnimId) = (' || this_animid
                   || '): Value (BIOGRAPHY.DepartDate) = (' || this_departdate
                   || '): StopDate must be the BIOGRAPHY.DepartDate when '
                   || 'StopType is a Final STOP_EVENT'
        , HINT = 'Look at the rows of the STOP_EVENT table to see which '
                 || 'events are Final events; the (' || NEW.stoptype
                 || ') StopType is one.';
  END IF;
  
  -- StartDate = EntryDate requires StartType = EntryType.
  SELECT biography.studyid, biography.animid, biography.entrydate
       , biography.entrytype
    INTO this_studyid,      this_animid,      this_entrydate
       , this_entrytype
    FROM biography
    WHERE biography.bid = NEW.bid
          AND biography.entrydate = NEW.startdate
          AND biography.entrytype <> NEW.starttype;
  IF FOUND THEN
    RAISE EXCEPTION integrity_constraint_violation USING
          MESSAGE = 'Error on FERTILITY ' || TG_OP || ' commit'
        , DETAIL = 'Key(FId) = (' || NEW.fid
                   || '): Value (BId) = (' || NEW.Bid
                   || '): Value(StartDate) = (' || NEW.startdate
                   || '): Value(StartType) = (' || NEW.starttype
                   || '): Value (BIOGRAPHY.StudyId) = (' || this_studyid
                   || '): Value (BIOGRAPHY.AnimId) = (' || this_animid
                   || '): Value (BIOGRAPHY.EntryDate) = (' || this_entrydate
                   || '): Value (BIOGRAPHY.EntryType) = (' || this_entrytype
                   || '): When StartDate equals EntryDate then StartType '
                   || 'must equal EntryType';
  END IF;
  
  -- StopDate = DepartDate requires StopType = DepartType.
  SELECT biography.studyid, biography.animid, biography.departdate
       , biography.departtype
    INTO this_studyid,      this_animid,      this_departdate
       , this_departtype
    FROM biography
    WHERE biography.bid = NEW.bid
          AND biography.departdate = NEW.stopdate
          AND biography.departtype <> NEW.stoptype;
  IF FOUND THEN
    RAISE EXCEPTION integrity_constraint_violation USING
          MESSAGE = 'Error on FERTILITY ' || TG_OP || ' commit'
        , DETAIL = 'Key(FId) = (' || NEW.fid
                   || '): Value (BId) = (' || NEW.Bid
                   || '): Value(StopDate) = (' || NEW.stopdate
                   || '): Value(StopType) = (' || NEW.stoptype
                   || '): Value (BIOGRAPHY.StudyId) = (' || this_studyid
                   || '): Value (BIOGRAPHY.AnimId) = (' || this_animid
                   || '): Value (BIOGRAPHY.DepartDate) = (' || this_departdate
                   || '): Value (BIOGRAPHY.DepartType) = (' || this_departtype
                   || '): When StopDate equals DepartDate then StopType '
                   || 'must equal DepartType';
  END IF;

  RETURN NULL;
  END;
$$;


SELECT 'fertility_trigger' AS trigger;
CREATE TRIGGER fertility_trigger
  AFTER INSERT OR UPDATE
  ON fertility FOR EACH ROW
  EXECUTE PROCEDURE fertility_func();

SELECT 'fertility_commit_trigger' AS trigger;
CREATE CONSTRAINT TRIGGER fertility_commit_trigger
  AFTER INSERT OR UPDATE
  ON fertility
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW
  EXECUTE PROCEDURE fertility_commit_func();
