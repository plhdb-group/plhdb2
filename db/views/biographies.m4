-- Copyright (C) 2016 The Meme Factory, Inc., http://www.meme.com/
--
--    This file is part of PLHDB.
--
--    PLHDB is free software; you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation; either version 3 of the License, or
--    (at your option) any later version.
--
--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.
--
--    You should have received a copy of the GNU General Public License
--    along with PLHDB.  If not, see <http://www.gnu.org/licenses/>.
--
-- Karl O. Pinc <kop@meme.com>
--

include(`grants.m4')
include(`biography_comments.m4')
include(`globalmacros.m4')

CREATE OR REPLACE VIEW biographies
  WITH (security_barrier = on)
  AS
  SELECT offspring.bid             AS bid
       , offspring.studyid         AS studyid
       , offspring.animid          AS animid
       , offspring.animname        AS animname
       , offspring.momonly         AS momonly
       , offspring.birthdate       AS birthdate
       , offspring.bdmin           AS bdmin
       , offspring.bdmax           AS bdmax
       , offspring.bddist          AS bddist
       , offspring.birthgroup      AS birthgroup
       , offspring.bgqual          AS bgqual
       , offspring.firstborn       AS firstborn
       , offspring.mombid          AS mombid
       , mom.animid                AS momid
       , offspring.sex             AS sex
       , offspring.entrydate       AS entrydate
       , offspring.entrytype       AS entrytype
       , offspring.departdate      AS departdate
       , offspring.departtype      AS departtype
       , offspring.departdateerror AS departdateerror
  FROM biography AS offspring
       LEFT OUTER JOIN biography AS mom ON (mom.bid = offspring.mombid)
  WHERE biography_search_access(offspring.studyid);

grant_row_level_priv(`biographies')
grant_demo_user_priv(`biographies')


COMMENT ON VIEW biographies IS
'One row per individual studied.  This view is identical to the
BIOGRAPHY table, but for the addition of the MomId column -- which
contains the mother''s AnimId.

This view is updatable.  The underlying rows may be changed by INSERT,
UPDATE, or DELETE on the view.

The MomBId value of the underlying BIOGRAPHY row may be manipulated via
BIOGRAPHIES using either the MomBId column or the MomId column.  On
INSERT either MomBId or MomId can be omitted from the list of inserted
columns or the NULL value used in either of the columns.  The MomId of
the underlying BIOGRAPHIES row is assigned based on the supplied
non-NULL column.  To INSERT a NULL BIOGRAPHY.MomBId value either
specify a NULL value for both BIOGRAPHIES MomBId and MomId or omit both
columns from the INSERT statement.  On INSERT if both MomBId and MomId
are specified then the 2 values must refer to the same mother.  On
UPDATE if both MomBId and MomId change then the 2 values must refer to
the same mother; if only one of MomBId or MomId changes value then the
changed value is used.

For more information see the BIOGRAPHY table documentation.';

comment_biography_columns(`biographies')

COMMENT ON COLUMN biographies.momid IS
'The identifier used by the study to denote the indivdual''s mother.
This value may be NULL when the mother is unknown.';


--  
-- Triggers
--

SELECT 'biographies_insert_func' AS function;
CREATE FUNCTION biographies_insert_func ()
  RETURNS trigger
  LANGUAGE plpgsql
  plh_function_set_search_path
  AS $$
  BEGIN
  -- Function for biographies insert triggers
  --
  -- GPL_notice(`  --', `2016', `The Meme Factory, Inc., http://www.meme.com/')

  -- Check PLHDB permissions
  IF NOT(biography_insert_access(NEW.studyid)) THEN
    RAISE EXCEPTION insufficient_privilege USING
          MESSAGE = 'Error on ' || TG_OP || ' of BIOGRAPHIES'
        , DETAIL = 'Key(BId) = (' || textualize(`NEW.bid')
                   || '): Value (StudyId) = (' || textualize(`NEW.studyid')
                   || '): Value (AnimId) = (' || textualize(`NEW.animid')
                   || '): Permission denied to this row'
        , HINT = 'The ''plh_insert'' PLHDB permission level to the '
                 || 'StudyId is required to insert this row';
  END IF;

  -- Insert into the underlying table

  IF NEW.momid IS NOT NULL THEN

    IF NEW.mombid IS NOT NULL THEN
      -- Both momid and mombid must refer to the same individual.
      PERFORM 1
        FROM biography
        WHERE biography.bid = NEW.mombid
              AND biography.animid = NEW.momid
              AND biography.studyid = NEW.studyid;
      IF NOT FOUND THEN
        RAISE EXCEPTION integrity_constraint_violation USING
              MESSAGE = 'Error on ' || TG_OP || ' of BIOGRAPHIES'
            , DETAIL = 'Key(BId) = (' || textualize(`NEW.bid')
                     || '): Value (StudyId) = (' || textualize(`NEW.studyid')
                     || '): Value (AnimId) = (' || textualize(`NEW.animid')
                     || '): Value (MomBId) = (' || textualize(`NEW.mombid')
                     || '): Value (MomId) = (' || textualize(`NEW.momid')
                     || '): The supplied MomBId and MomId values do not '
                     || 'refer to the same individual, or the StudyId '
                     || 'is wrong';
      END IF;
    ELSE  -- Only momid specified
      -- Get the mombid that goes with the supplied momid
      SELECT biography.bid
        INTO NEW.mombid
        FROM biography
        WHERE biography.studyid = NEW.studyid
              AND biography.animid = NEW.animid;
      IF NOT FOUND THEN
        -- Don't blindly insert a NULL when a momid was specified.
        RAISE EXCEPTION integrity_constraint_violation USING
              MESSAGE = 'Error on ' || TG_OP || ' of BIOGRAPHIES'
            , DETAIL = 'Key(BId) = (' || textualize(`NEW.bid')
                     || '): Value (StudyId) = (' || textualize(`NEW.studyid')
                     || '): Value (AnimId) = (' || textualize(`NEW.animid')
                     || '): Value (MomBId) = (' || textualize(`NEW.mombid')
                     || '): Value (MomId) = (' || textualize(`NEW.momid')
                     || '): The supplied MomId and StudyId values do not '
                     || 'refer to an existant individual';
      END IF;
    END IF;

  ELSE -- No momid specified

    IF NEW.mombid IS NOT NULL THEN
      -- Just in case somebody uses a RETURNING, get the momid
      SELECT biography.animid
        INTO NEW.momid
        FROM biography
        WHERE biography.bid = NEW.mombid;
      -- If we don't find anything the underlying table will raise an erorr
    END IF;
  END IF;

  -- Make sure we have a bid
  IF NEW.bid IS NULL THEN
    SELECT nextval('biography_bid_seq'::REGCLASS)
      INTO NEW.bid;
  END IF;

  -- Insert the underlying biography row
  INSERT INTO biography (
                bid
              , studyid
              , animid
              , animname
              , momonly
              , birthdate
              , bdmin
              , bdmax
              , bddist
              , birthgroup
              , bgqual
              , firstborn
              , mombid
              , sex
              , entrydate
              , entrytype
              , departdate
              , departtype
              , departdateerror)
    VALUES(NEW.bid
         , NEW.studyid
         , NEW.animid
         , NEW.animname
         , NEW.momonly
         , NEW.birthdate
         , NEW.bdmin
         , NEW.bdmax
         , NEW.bddist
         , NEW.birthgroup
         , NEW.bgqual
         , NEW.firstborn
         , NEW.mombid
         , NEW.sex
         , NEW.entrydate
         , NEW.entrytype
         , NEW.departdate
         , NEW.departtype
         , NEW.departdateerror);

  RETURN NEW;
  END;
$$;



SELECT 'biographies_update_func' AS function;
CREATE FUNCTION biographies_update_func ()
  RETURNS trigger
  LANGUAGE plpgsql
  plh_function_set_search_path
  AS $$
  BEGIN
  -- Function for biographies update triggers
  --
  -- GPL_notice(`  --', `2016', `The Meme Factory, Inc., http://www.meme.com/')

  -- Check PLHDB permissions

  -- Check access to old study.
  IF NOT(biography_edit_access(OLD.studyid)) THEN
    RAISE EXCEPTION insufficient_privilege USING
          MESSAGE = 'Error on ' || TG_OP || ' of BIOGRAPHIES'
        , DETAIL = 'Key(OLD BId) = (' || OLD.bid
                   || '): Value (OLD StudyId) = (' || OLD.studyid
                   || '): Value (OLD AnimId) = (' || OLD.animid
                   || '): Key(NEW BId) = (' || textualize(`NEW.bid')
                   || '): Value (NEW StudyId) = ('
                   || textualize(`NEW.studyid')
                   || '): Value (NEW AnimId) = ('
                   || textualize(`NEW.animid')
                   || '): Permission denied to this row'
        , HINT = 'The ''plh_edit'' PLHDB permission level to the old '
                 || 'StudyId is required to update this row';
  END IF;

  -- Check access to new study.
  IF NEW.studyid IS NULL
     OR (NEW.studyid <> OLD.studyid
         AND NOT(biography_edit_access(NEW.studyid))) THEN
    RAISE EXCEPTION insufficient_privilege USING
          MESSAGE = 'Error on ' || TG_OP || ' of BIOGRAPHIES'
        , DETAIL = 'Key(OLD BId) = (' || OLD.bid
                   || '): Value (OLD StudyId) = (' || OLD.studyid
                   || '): Value (OLD AnimId) = (' || OLD.animid
                   || '): Key(NEW BId) = (' || textualize(`NEW.bid')
                   || '): Value (NEW StudyId) = ('
                   || textualize(`NEW.studyid')
                   || '): Value (NEW AnimId) = ('
                   || textualize(`NEW.animid')
                   || '): Permission denied to this row'
        , HINT = 'The ''plh_edit'' PLHDB permission level to the new '
                 || 'StudyId is required to update this row';
  END IF;

  -- Update the underlying table

  -- What is the new mombid?
  -- It is a change in mombid or momid that registers.
  IF NEW.momid IS DISTINCT FROM OLD.momid THEN
    -- momid changed
    IF NEW.mombid IS DISTINCT FROM OLD.mombid THEN
      -- mombid changed also
      -- Are the new mombid and new momid referencing the same row?
      IF NEW.momid IS NOT NULL
         AND NEW.mombid IS NOT NULL THEN
        PERFORM 1
          FROM biography
          WHERE biography.studyid = NEW.studyid
                AND biography.animid = NEW.momid
                AND biography.bid = NEW.mombid;
        IF NOT FOUND THEN
          RAISE EXCEPTION integrity_constraint_violation USING
                MESSAGE = 'Error on ' || TG_OP || ' of BIOGRAPHIES'
              , DETAIL = 'Key(OLD BId) = (' || OLD.bid
                       || '): Value (OLD StudyId) = (' || OLD.studyid
                       || '): Value (OLD AnimId) = (' || OLD.animid
                       || '): Value (OLD MomBId) = ('
                       || textualize(`OLD.mombid')
                       || '): Value (OLD MomId) = ('
                       || textualize(`OLD.momid')
                       || '): Key(NEW BId) = (' || textualize(`NEW.bid')
                       || '): Value (NEW StudyId) = ('
                       || textualize(`NEW.studyid')
                       || '): Value (NEW AnimId) = ('
                       || textualize(`NEW.animid')
                       || '): Value (NEW MomBId) = ('
                       || textualize(`NEW.mombid')
                       || '): Value (NEW MomId) = (' || textualize(`NEW.momid')
                       || '): The supplied new MomBId + new StudyId values '
                       || 'and the supplied new MomId value '
                       || 'do not refer to the same individual';
        END IF;
      END IF;
    ELSE -- mombid did not change
      -- Get the mombid to go with the changed momid
      IF NEW.momid IS NULL THEN
        NEW.mombid := NULL;
      ELSE
        SELECT biography.bid
          INTO NEW.mombid
          FROM biography
          WHERE biography.studyid = NEW.studyid
                AND biography.animid = NEW.momid;
        IF NOT FOUND THEN
          -- Don't blindly update to NULL when a momid was specified.
          RAISE EXCEPTION integrity_constraint_violation USING
                MESSAGE = 'Error on ' || TG_OP || ' of BIOGRAPHIES'
              , DETAIL = 'Key(OLD BId) = (' || OLD.bid
                       || '): Value (OLD StudyId) = (' || OLD.studyid
                       || '): Value (OLD AnimId) = (' || OLD.animid
                       || '): Value (OLD MomBId) = ('
                       || textualize(`OLD.mombid')
                       || '): Value (OLD MomId) = ('
                       || textualize(`OLD.momid')
                       || '): Key(NEW BId) = (' || textualize(`NEW.bid')
                       || '): Value (NEW StudyId) = ('
                       || textualize(`NEW.studyid')
                       || '): Value (NEW AnimId) = ('
                       || textualize(`NEW.animid')
                       || '): Value (NEW MomBId) = ('
                       || textualize(`NEW.mombid')
                       || '): Value (NEW MomId) = (' || textualize(`NEW.momid')
                       || '): The supplied new MomId and new StudyId values '
                       || 'do not refer to an existant BIOGRAPHY row';
        END IF;
      END IF;
    END IF;
  ELSE -- momid did not change
    IF NEW.mombid IS NOT NULL
       AND (NEW.mombid <> OLD.mombid
            OR OLD.mombid IS NULL) THEN
      -- Just in case somebody uses a RETURNING clause, set the momid from
      -- the mombid
      SELECT biography.animid
        INTO NEW.momid
        FROM biography
        WHERE biography.bid = NEW.mombid;
      -- If we don't find anything the underlying table will raise an error
    END IF;
  END IF;

  UPDATE biography
    SET bid             = NEW.bid
      , studyid         = NEW.studyid
      , animid          = NEW.animid
      , animname        = NEW.animname
      , momonly         = NEW.momonly
      , birthdate       = NEW.birthdate
      , bdmin           = NEW.bdmin
      , bdmax           = NEW.bdmax
      , bddist          = NEW.bddist
      , birthgroup      = NEW.birthgroup
      , bgqual          = NEW.bgqual
      , firstborn       = NEW.firstborn
      , mombid          = NEW.mombid
      , sex             = NEW.sex
      , entrydate       = NEW.entrydate
      , entrytype       = NEW.entrytype
      , departdate      = NEW.departdate
      , departtype      = NEW.departtype
      , departdateerror = NEW.departdateerror
    WHERE bid = OLD.bid;

  RETURN NEW;
  END;
$$;


SELECT 'biographies_delete_func' AS function;
CREATE FUNCTION biographies_delete_func ()
  RETURNS trigger
  LANGUAGE plpgsql
  plh_function_set_search_path
  AS $$
  -- Function for biographies delete trigger
  --
  -- GPL_notice(`  --', `2016', `The Meme Factory, Inc., http://www.meme.com/')

  DECLARE

  BEGIN

    -- Check PLHDB permissions
    IF NOT(biography_all_access(OLD.studyid)) THEN
      RAISE EXCEPTION insufficient_privilege USING
            MESSAGE = 'Error on ' || TG_OP || ' of BIOGRAPHIES'
          , DETAIL = 'Key(BId) = (' || OLD.bid
                     || '): Value (StudyId) = (' || OLD.studyid
                     || '): Value (AnimId) = (' || OLD.animid
                     || '): Permission denied to this row'
          , HINT = 'The ''plh_all'' PLHDB permission level to this study is '
                   || 'required to delete this row';
    END IF;

    -- Delete from the underlying table
    DELETE
      FROM biography
      WHERE biography.bid = OLD.bid;

  RETURN OLD;
  END;
$$;


SELECT 'biographies_insert_trigger' AS trigger;
CREATE TRIGGER biographies_insert_trigger
  INSTEAD OF INSERT
  ON biographies FOR EACH ROW
  EXECUTE PROCEDURE biographies_insert_func();

SELECT 'biographies_update_trigger' AS trigger;
CREATE TRIGGER biographies_update_trigger
  INSTEAD OF UPDATE
  ON biographies FOR EACH ROW
  EXECUTE PROCEDURE biographies_update_func();

SELECT 'biographies_delete_trigger' AS trigger;
CREATE TRIGGER biographies_delete_trigger
  INSTEAD OF DELETE
  ON biographies FOR EACH ROW
  EXECUTE PROCEDURE biographies_delete_func();
