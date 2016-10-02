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
-- biography
--
SELECT 'biography' AS table;

SELECT 'biography_func' AS function;
CREATE FUNCTION biography_func ()
  RETURNS trigger
  LANGUAGE plpgsql
  plh_function_set_search_path
  AS $$
  DECLARE
    this_momid biography.animid%TYPE;
    this_sex biography.sex%TYPE;
    this_studyid biography.studyid%TYPE;

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

  IF NEW.mombid IS NOT NULL THEN
    -- Mother of this individual must be female.
    SELECT biography.animid, biography.sex
      INTO this_momid, this_sex
      FROM biography
      WHERE biography.bid = NEW.mombid
            AND biography.sex <> 'plh_female';
    IF FOUND THEN
      RAISE EXCEPTION integrity_constraint_violation USING
            MESSAGE = 'Error on ' || TG_OP || ' of BIOGRAPHY'
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
          MESSAGE = 'Error on ' || TG_OP || ' of BIOGRAPHY'
        , DETAIL = 'Key(BId) = (' || NEW.bid
                   || '): Value (StudyId) = (' || NEW.studyid
                   || '): Value (AnimId) = (' || NEW.animid
                   || '): Value (MomBId) = (' || NEW.mombid
                   || '): Value (BIOGRAPHY.AnimId of mother) = ('
                   || this_momid
                   || '): Value (BIOGRAPHY.StudyId of mother) = ('
                   || this_studyid
                   || '): The StudyId value of the offspring must be '
                   || 'that of the mother.';
  END IF;


  IF TG_OP = 'UPDATE' THEN

    -- Individuals who have rows only because they are another's mother
    -- cannot have female fertility intervals.
    IF NEW.MomOnly <> OLD.MomOnly
       AND NEW.MomOnly THEN
      PERFORM 1
        FROM femalefertilityinterval
        WHERE femalefertilityinterval.bid = NEW.bid;
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
 
     -- Individual cannot have offspring unless female.
      PERFORM 1
        FROM biography
        WHERE biography.mombid = NEW.bid;
      IF FOUND THEN
        RAISE EXCEPTION integrity_constraint_violation USING
              MESSAGE = 'Error on ' || TG_OP || ' of BIOGRAPHY'
            , DETAIL = 'Key(BId) = (' || NEW.bid
                     || '): Value (StudyId) = (' || NEW.studyid
                     || '): Value (AnimId) = (' || NEW.animid
                     || '): Value (Sex) = (' || NEW.sex
                     || '): Sex must be ''plh_female'' because this '
                     || 'individual is another''s mother';
      END IF;

      -- Individual cannot have female fertility intervals unless female.
      PERFORM 1
        FROM femalefertilityinterval
        WHERE femalefertilityinterval.bid = NEW.bid;
      IF FOUND THEN
        RAISE EXCEPTION integrity_constraint_violation USING
              MESSAGE = 'Error on ' || TG_OP || ' of BIOGRAPHY'
            , DETAIL = 'Key(BId) = (' || NEW.bid
                     || '): Value (StudyId) = (' || NEW.studyid
                     || '): Value (AnimId) = (' || NEW.animid
                     || '): Value (Sex) = (' || NEW.sex
                     || '): Sex must be ''plh_female'' because this '
                     || 'individual has related FEMALEFERTILITYINTERVAL '
                     || 'rows';
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
              MESSAGE = 'Error on ' || TG_OP || ' of BIOGRAPHY'
            , DETAIL = 'Key(BId) = (' || NEW.bid
                     || '): Value (StudyId) = (' || NEW.studyid
                     || '): Value (AnimId) = (' || NEW.animid
                     || '): StudyId cannot change because this '
                     || 'individual is another''s mother; the study '
                     || 'of the mother and offspring must match';
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
