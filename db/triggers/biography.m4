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
-- biography
--
SELECT 'biography' AS table;

SELECT 'biography_func' AS function;
CREATE FUNCTION biography_func ()
  RETURNS trigger
  LANGUAGE plpgsql
  plh_function_set_search_path
  AS $$
  BEGIN
  -- Function for biography insert and update triggers
  --
  -- GPL_notice(`  --', `2016', `The Meme Factory, Inc., http://www.meme.com/')

  IF TG_OP = 'UPDATE' THEN
    -- Keep life simple and restrict key changes.
    cannot_change(`BIOGRAPHY', `BId')
  END IF;

  -- Birthdates with a "symmetric" (normal) distribution must have their
  -- birth date halfway between the min and max range.  Or one of the
  -- two midpoint dates if the range has an even number of days.
  IF NEW.birthdate IS NOT NULL
     AND ABS((NEW.birthdate - NEW.bdmin)
             - (NEW.bdmax - NEW.birthdate))
            > 1 THEN
    PERFORM 1
      FROM probability_type
      WHERE probability_type.code = NEW.bddist
            AND probability_type.symmetrical;
    IF FOUND THEN
      RAISE EXCEPTION integrity_constraint_violation USING
            MESSAGE = 'Error on ' || TG_OP || ' of BIOGRAPHY'
          , DETAIL = 'Key(BId) = (' || NEW.bid
                     || '): Value (StudyId) = (' || NEW.studyid
                     || '): Value (AnimId) = (' || NEW.animid
                     || '): Value (BirthDate) = (' || NEW.BirthDate
                     || '): Value (BDMin) = (' || NEW.bdmin
                     || '): Value (BDMax) = (' || NEW.bdmax
                     || '): Value (BDDist) = (' || NEW.bddist
                     || '): When a BDDist relates to a PROBABILITY_TYPE '
                     || 'row with a TRUE Symmetrical value (as is set '
                     || 'for normal distributions), the BirthDate '
                     || 'must fall midway between BDMin and BDMax';
    END IF;
  END IF;


  IF TG_OP = 'UPDATE' THEN

    -- Individuals who have rows only because they are another's mother
    -- cannot have female fertility intervals.
    IF NEW.MomOnly <> OLD.MomOnly
       AND NEW.MomOnly THEN
      PERFORM 1
        FROM fertility
        WHERE fertility.bid = NEW.bid;
      IF FOUND THEN
        RAISE EXCEPTION integrity_constraint_violation USING
              MESSAGE = 'Error on ' || TG_OP || ' of BIOGRAPHY'
            , DETAIL = 'Key(BId) = (' || NEW.bid
                     || '): Value (StudyId) = (' || NEW.studyid
                     || '): Value (AnimId) = (' || NEW.animid
                     || '): Value (MomOnly) = (' || NEW.momonly
                     || '): Rows with MomOnly = TRUE cannot '
                     || 'have a related FEMALEFERTILTIYINTERVAL row';

      END IF;
    END IF;

    IF NEW.sex <> OLD.sex
       AND NEW.sex <> 'plh_female' THEN

      -- Individual cannot have female fertility intervals unless female.
      PERFORM 1
        FROM fertility
        WHERE fertility.bid = NEW.bid;
      IF FOUND THEN
        RAISE EXCEPTION integrity_constraint_violation USING
              MESSAGE = 'Error on ' || TG_OP || ' of BIOGRAPHY'
            , DETAIL = 'Key(BId) = (' || NEW.bid
                     || '): Value (StudyId) = (' || NEW.studyid
                     || '): Value (AnimId) = (' || NEW.animid
                     || '): Value (Sex) = (' || NEW.sex
                     || '): Sex must be ''plh_female'' because this '
                     || 'individual has related FERTILITY '
                     || 'rows';
      END IF;

    END IF;

    -- Individual cannot have female fertility intervals after
    -- departure date + (departdateerror years).
    IF (NEW.departdate <> OLD.departdate
        AND NEW.departdate < OLD.departdate)
       OR (NEW.departdateerror <> OLD.departdateerror
           AND OLD.departdateerror < NEW.departdateerror) THEN
      PERFORM 1
        FROM fertility AS ffi
        WHERE ffi.bid = NEW.bid
              AND last_departdate(NEW.departdate, NEW.departdateerror)
                  < ffi.stopdate;
      IF FOUND THEN
        RAISE EXCEPTION integrity_constraint_violation USING
              MESSAGE = 'Error on ' || TG_OP || ' of BIOGRAPHY'
            , DETAIL = 'Key(BId) = (' || NEW.bid
                     || '): Value (StudyId) = (' || NEW.studyid
                     || '): Value (AnimId) = (' || NEW.animid
                     || '): Value (DepartDate) = (' || NEW.departdate
                     || '): Value (DepartDateError) = ('
                     || NEW.departdateerror
                     || '): There is a related FERTILITY row '
                     || 'which has a StopDate value after the computed '
                     || 'new last possible departure date; the computed '
                     || 'last possible departure date is: '
                     || last_departdate(NEW.departdate, NEW.departdateerror);
      END IF;
    END IF;

    -- Individual cannot have female fertility intervals before
    -- entry date.
    IF NEW.entrydate <> OLD.entrydate
       AND NEW.entrydate > OLD.entrydate THEN
      PERFORM 1
        FROM fertility AS ffi
        WHERE ffi.bid = NEW.bid
              AND ffi.startdate < NEW.entrydate;
      IF FOUND THEN
        RAISE EXCEPTION integrity_constraint_violation USING
              MESSAGE = 'Error on ' || TG_OP || ' of BIOGRAPHY'
            , DETAIL = 'Key(BId) = (' || NEW.bid
                     || '): Value (StudyId) = (' || NEW.studyid
                     || '): Value (AnimId) = (' || NEW.animid
                     || '): Value (EntryDate) = (' || NEW.entrydate
                     || '): There is a related FERTILITY row '
                     || 'which has a StartDate value preceding the new '
                     || 'EntryDate';
      END IF;
    END IF;

  END IF;  -- UPDATE
  

  RETURN NULL;
  END;
$$;

SELECT 'biography_commit_func' AS function;
CREATE OR REPLACE FUNCTION biography_commit_func()
  RETURNS trigger
  LANGUAGE plpgsql
  plh_function_set_search_path
  AS $$
  -- Function for biography insert or update fired upon transaction commit.
  --
  -- GPL_notice(`  --', `2016', `The Meme Factory, Inc.  http://www.meme.com/')
  --
  DECLARE
    this_studyid biography.studyid%TYPE;
    this_momid biography.animid%TYPE;
    this_sex biography.sex%TYPE;

    this_fid fertility.fid%TYPE;
    this_startdate fertility.startdate%TYPE;
    this_starttype fertility.starttype%TYPE;
    this_stopdate fertility.stopdate%TYPE;
    this_stoptype fertility.stoptype%TYPE;

  BEGIN

  -- Get the latest values of the row
  SELECT * INTO NEW FROM biography WHERE biography.bid = NEW.bid;
  IF NOT FOUND THEN
    -- Whatever row was updated was subsequently deleted.
    -- Nothing to do.
    RETURN NULL;
  END IF;

  IF NEW.mombid IS NOT NULL THEN
    -- Mother of this individual must be female.
    SELECT biography.animid, biography.sex
      INTO this_momid, this_sex
      FROM biography
      WHERE biography.bid = NEW.mombid
            AND biography.sex <> 'plh_female';
    IF FOUND THEN
      RAISE EXCEPTION integrity_constraint_violation USING
            MESSAGE = 'Error on BIOGRAPHY ' || TG_OP || ' commit'
          , DETAIL = 'Key(BId) = (' || NEW.bid
                     || '): Value (StudyId) = (' || NEW.studyid
                     || '): Value (AnimId) = (' || NEW.animid
                     || '): Value (MomBId) = (' || NEW.mombid
                     || '): Value (BIOGRAPHY.AnimId of mother) = ('
                     || this_momid
                     || '): Value (BIOGRAPHY.Sex of mother) = (' || this_sex
                     || '): The Sex value of a mother must be '
                     || '''plh_female''.';
    END IF;
  END IF;

  -- Mother of this individual must be in same study as offspring.
  SELECT biography.animid, biography.studyid
    INTO this_momid, this_studyid
    FROM biography
    WHERE biography.bid = NEW.mombid
          AND biography.studyid <> NEW.studyid;
  IF FOUND THEN
    RAISE EXCEPTION integrity_constraint_violation USING
          MESSAGE = 'Error on BIOGRAPHY ' || TG_OP || ' commit'
        , DETAIL = 'Key(BId) = (' || NEW.bid
                   || '): Value (StudyId) = (' || NEW.studyid
                   || '): Value (AnimId) = (' || NEW.animid
                   || '): Value (MomBId) = (' || NEW.mombid
                   || '): Value (BIOGRAPHY.AnimId of mother) = ('
                   || this_momid
                   || '): Value (BIOGRAPHY.StudyId of mother) = ('
                   || this_studyid
                   || '): The StudyId value of the offspring must match '
                   || 'that of the mother.';
  END IF;


  IF TG_OP = 'UPDATE' THEN

    IF NEW.sex <> OLD.sex
       AND NEW.sex <> 'plh_female' THEN
 
      -- Individual cannot have offspring unless female.
      -- (Check is on transaction commit because momid is not validated
      -- until then.)
      PERFORM 1
        FROM biography
        WHERE biography.mombid = NEW.bid;
      IF FOUND THEN
        RAISE EXCEPTION integrity_constraint_violation USING
              MESSAGE = 'Error on BIOGRAPHY ' || TG_OP || ' commit'
            , DETAIL = 'Key(BId) = (' || NEW.bid
                     || '): Value (StudyId) = (' || NEW.studyid
                     || '): Value (AnimId) = (' || NEW.animid
                     || '): Value (Sex) = (' || NEW.sex
                     || '): Sex must be ''plh_female'' because this '
                     || 'individual is another''s mother';
      END IF;

    END IF;

    -- Individual cannot have offspring in a different study.
    IF NEW.studyid <> OLD.studyid THEN
      PERFORM 1
        FROM biography
        WHERE biography.mombid = NEW.bid
              AND biography.studyid <> NEW.studyid;
      IF FOUND THEN
        RAISE EXCEPTION integrity_constraint_violation USING
              MESSAGE = 'Error on BIOGRAPHY ' || TG_OP || ' commit'
            , DETAIL = 'Key(BId) = (' || NEW.bid
                     || '): Value (StudyId) = (' || NEW.studyid
                     || '): Value (AnimId) = (' || NEW.animid
                     || '): StudyId cannot change because this '
                     || 'individual is another''s mother; the study '
                     || 'of the mother and offspring must match';
      END IF;
    END IF;


    -- Initial StartTypes mean StartDate = EntryDate.
    IF NEW.entrydate <> OLD.entrydate THEN
      SELECT ffi.fid,  ffi.startdate,  ffi.starttype
        INTO this_fid, this_startdate, this_starttype
        FROM fertility AS ffi
             JOIN start_event ON (start_event.code = ffi.starttype)
        WHERE ffi.bid = NEW.bid
              AND ffi.startdate <> NEW.entrydate
              AND start_event.initial;
      IF FOUND THEN
        RAISE EXCEPTION integrity_constraint_violation USING
              MESSAGE = 'Error on BIOGRAPHY ' || TG_OP || ' commit'
            , DETAIL = 'Key(BId) = (' || NEW.bid
                     || '): Value (StudyId) = (' || NEW.studyid
                     || '): Value (AnimId) = (' || NEW.animid
                     || '): Value (EntryDate) = (' || NEW.entrydate
                     || '): Key(FERTILITY.FId) = ('
                     || this_fid
                     || '): Value(FERTILITY.StartDate) = ('
                     || this_startdate
                     || '): Value(FERTILITY.StartType) = ('
                     || this_starttype
                     || '): FERTILITY.StartDate must be the '
                     || 'EntryDate when StartType is an Initial START_EVENT';
      END IF;
    END IF;


    -- Final StopTypes mean StopDate = DepartDate.
    IF NEW.departdate <> OLD.departdate THEN
      SELECT ffi.fid,  ffi.stopdate,  ffi.stoptype
        INTO this_fid, this_stopdate, this_stoptype
        FROM fertility AS ffi
             JOIN end_event ON (end_event.code = ffi.stoptype)
        WHERE ffi.bid = NEW.bid
              AND ffi.stopdate <> NEW.departdate
              AND end_event.final;
      IF FOUND THEN
        RAISE EXCEPTION integrity_constraint_violation USING
              MESSAGE = 'Error on BIOGRAPHY ' || TG_OP || ' commit'
            , DETAIL = 'Key(BId) = (' || NEW.bid
                     || '): Value (StudyId) = (' || NEW.studyid
                     || '): Value (AnimId) = (' || NEW.animid
                     || '): Value (DepartDate) = (' || NEW.departdate
                     || '): Key(FERTILITY.FId) = ('
                     || this_fid
                     || '): Value(FERTILITY.StopDate) = ('
                     || this_stopdate
                     || '): Value(FERTILITY.StopType) = ('
                     || this_stoptype
                     || '): FERTILITY.StopDate must be the '
                     || 'DepartDate when StopType is a Final STOP_EVENT';
      END IF;
    END IF;

    -- EntryDate = StartDate requires EntryType = StartType
    IF NEW.entrytype <> OLD.entrytype
       OR NEW.entrydate <> OLD.entrydate THEN
      SELECT ffi.fid,  ffi.startdate,  ffi.starttype
        INTO this_fid, this_startdate, this_starttype
        FROM fertility AS ffi
        WHERE ffi.bid = NEW.bid
              AND ffi.startdate = NEW.entrydate
              AND ffi.starttype <> NEW.entrytype;
      IF FOUND THEN
        RAISE EXCEPTION integrity_constraint_violation USING
              MESSAGE = 'Error on BIOGRAPHY ' || TG_OP || ' commit'
            , DETAIL = 'Key(BId) = (' || NEW.bid
                     || '): Value (StudyId) = (' || NEW.studyid
                     || '): Value (AnimId) = (' || NEW.animid
                     || '): Value (EntryDate) = (' || NEW.entrydate
                     || '): Value (EntryType) = (' || NEW.entrytype
                     || '): Key(FERTILITY.FId) = (' || this_fid
                     || '): Value(FERTILITY.StartDate) = (' || this_startdate
                     || '): Value(FERTILITY.StartType) = (' || this_starttype
                     || '): When FERTILITY.StartDate equals EntryDate then '
                     || 'EntryType must equal FERTILITY.StartType';
      END IF;
    END IF;

    -- DepartDate = StopDate requires DepartType = StopType
    IF NEW.departtype <> OLD.departtype
       OR NEW.departdate <> OLD.departdate THEN
      SELECT ffi.fid,  ffi.stopdate,  ffi.stoptype
        INTO this_fid, this_stopdate, this_stoptype
        FROM fertility AS ffi
        WHERE ffi.bid = NEW.bid
              AND ffi.stopdate = NEW.departdate
              AND ffi.stoptype <> NEW.departtype;
      IF FOUND THEN
        RAISE EXCEPTION integrity_constraint_violation USING
              MESSAGE = 'Error on BIOGRAPHY ' || TG_OP || ' commit'
            , DETAIL = 'Key(BId) = (' || NEW.bid
                     || '): Value (StudyId) = (' || NEW.studyid
                     || '): Value (AnimId) = (' || NEW.animid
                     || '): Value (DepartDate) = (' || NEW.departdate
                     || '): Value (DepartType) = (' || NEW.departtype
                     || '): Key(FERTILITY.FId) = (' || this_fid
                     || '): Value(FERTILITY.StopDate) = (' || this_stopdate
                     || '): Value(FERTILITY.StopType) = (' || this_stoptype
                     || '): When FERTILITY.StopDate equals DepartDate then '
                     || 'DepartType must equal FERTILITY.StopType';
      END IF;
    END IF;
  END IF;

  RETURN NULL;
  END;
$$;


SELECT 'biography_trigger' AS trigger;
CREATE TRIGGER biography_trigger
  AFTER INSERT OR UPDATE
  ON biography FOR EACH ROW
  EXECUTE PROCEDURE biography_func();

SELECT 'biography_commit_trigger' AS trigger;
CREATE CONSTRAINT TRIGGER biography_commit_trigger
  AFTER INSERT OR UPDATE
  ON biography
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW
  EXECUTE PROCEDURE biography_commit_func();
