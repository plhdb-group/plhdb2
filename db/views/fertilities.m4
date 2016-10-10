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

include(`globalmacros.m4')
include(`grants.m4')
include(`fertility_comments.m4')


CREATE OR REPLACE VIEW fertilities
  WITH (security_barrier = on)
  AS
  SELECT fertility.fid       AS fid
       , fertility.bid       AS bid
       , biography.studyid   AS studyid
       , biography.animid    AS animid
       , fertility.startdate AS startdate
       , fertility.starttype AS starttype
       , fertility.stopdate  AS stopdate
       , fertility.stoptype  AS stoptype
  FROM fertility
       JOIN biography ON (biography.bid = fertility.bid)
  WHERE biography_search_access(biography.studyid);

grant_row_level_priv(`fertilities')
grant_demo_user_priv(`fertilities')


COMMENT ON VIEW fertilities IS
'One row per uninterrupted period of observation on a female; during
which no possible births would have been missed.  This view is
identical to the FERTILITY table, but for the addition of the StudyId
and AnimId columns.

This view is updatable.  The underlying rows may be changed by INSERT,
UPDATE, or DELETE on the view.

The BId value of the underlying FERTILITY row may be manipulated via
FERTILITIES using either the BId column or the AnimId and StudyId
column combination.  On INSERT either BId or the AnimId/StudyId pair
can be omitted from the list of inserted columns or the NULL value used
in either Bid or the AnimId/StudyId pair.  The BId of the underlying
FERTILITIES row is assigned based on the supplied non-NULL value(s).
On INSERT if both the BId and AnimId/StudyId pair are specified then
the 2 values must refer to the same mother.  On UPDATE if both the BId
and the AnimId/StudyId pair change then the values must refer to the
same mother; if only one of the BId or the AnimId/StudyId pair changes
then the changed value(s) is(are) used.

For more information see the FERTILITY table documentation.';


comment_fertility_columns(`fertilities')


COMMENT ON COLUMN fertilities.studyid IS
'Identifier of the study for which the individual is observed.  This
value may not be NULL.

TIP: Can be used to JOIN with STUDY.Id.';

COMMENT ON COLUMN fertilities.animid IS
'The identifier used by the study to denote the individual.  This value
may not be NULL.';


--  
-- Triggers
--

dnl plpgsql fragment to raise an error when the supplied bid does not exist
dnl
dnl Syntax: raise_bad_bid()
dnl
dnl For use in insert or update trigger
dnl
changequote({,})
define({raise_bad_bid},{
        RAISE EXCEPTION integrity_constraint_violation USING
              MESSAGE = 'Error on ' || TG_OP || ' of FERTILITIES'
            , DETAIL = 'Key(FId) = (' || textualize(`NEW.fid')
                     || '): Value (BId) = (' || textualize(`NEW.bid')
                     || '): Value (StudyId) = (' || textualize(`NEW.studyid')
                     || '): Value (AnimId) = (' || textualize(`NEW.animid')
                     || '): The supplied BId value does not '
                     || 'refer to an existing BIOGRAPHY row';
})dnl
changequote(`,')dnl


SELECT 'fertilities_insert_func' AS function;
CREATE FUNCTION fertilities_insert_func ()
  RETURNS trigger
  LANGUAGE plpgsql
  plh_function_set_search_path
  AS $$
  DECLARE
    this_animid  biography.animid%TYPE;
    this_studyid biography.studyid%TYPE;

  BEGIN
  -- Function for fertilities insert triggers
  --
  -- GPL_notice(`  --', `2016', `The Meme Factory, Inc., http://www.meme.com/')

  -- Check data validity/lookup unspecified data

  IF NEW.animid IS NOT NULL
     OR NEW.studyid IS NOT NULL THEN

    IF NEW.bid IS NULL THEN

      IF NEW.studyid IS NULL
         OR NEW.animid IS NULL THEN
        RAISE EXCEPTION integrity_constraint_violation USING
              MESSAGE = 'Error on ' || TG_OP || ' of FERTILITIES'
            , DETAIL = 'Key(FId) = (' || textualize(`NEW.fid')
                     || '): Value (BId) = (' || textualize(`NEW.bid')
                     || '): Value (StudyId) = (' || textualize(`NEW.studyid')
                     || '): Value (AnimId) = (' || textualize(`NEW.animid')
                     || '): Not enough information supplied to identify '
                     || 'a BIOGRAPHY row'
            , HINT = 'Either BId or both StudyId and AnimId are required';
      END IF;

      -- Get the bid that goes with the given animid and studyid
      SELECT biography.bid
        INTO NEW.bid
        FROM biography
        WHERE biography.studyid = NEW.studyid
              AND biography.animid = NEW.animid;
      IF NOT FOUND THEN
        RAISE EXCEPTION integrity_constraint_violation USING
              MESSAGE = 'Error on ' || TG_OP || ' of FERTILITIES'
            , DETAIL = 'Key(FId) = (' || textualize(`NEW.fid')
                       || '): Value (BId) = (NULL'
                       || '): Value (StudyId) = (' || NEW.studyid
                       || '): Value (AnimId) = (' || NEW.animid
                       || '): The supplied StudyId and AnimId values do not '
                       || 'identify an existing BIOGRAPHY row';
      END IF;

    ELSE -- Bid is not NULL

      -- Both animid+studyid and bid must refer to the same individual.
      SELECT biography.studyid, biography.animid
        INTO this_studyid, this_animid
        FROM biography
        WHERE biography.bid = NEW.bid;
      IF NOT FOUND THEN
        raise_bad_bid()
      END IF;

      IF (NEW.animid <> this_animid
          AND NEW.animid IS NOT NULL)
         OR (NEW.studyid <> this_studyid
             AND NEW.studyid IS NOT NULL) THEN
        RAISE EXCEPTION integrity_constraint_violation USING
              MESSAGE = 'Error on ' || TG_OP || ' of FERTILITIES'
            , DETAIL = 'Key(FId) = (' || textualize(`NEW.fid')
                     || '): Value (FERTILITIES.BId) = (' || NEW.bid
                     || '): Value (FERTILITIES.StudyId) = ('
                     || textualize(`NEW.studyid')
                     || '): Value (FERTILITIES.AnimId) = ('
                     || textualize(`NEW.animid')
                     || '): Value (BIOGRAPHY.BId) = (' || NEW.bid
                     || '): Value (BIOGRAPHY.StudyId) = (' || this_studyid
                     || '): Value (BIOGRAPHY.AnimId) = (' || this_animid
                     || '): The supplied FERTILITIES AnimId StudyId '
                     || 'combination do not refer to the BIOGRAPHY row '
                     || 'identified by the supplied BId';
      END IF;

      -- Set the values in case one is NULL and a RETURNING clause is used
      NEW.animid := this_animid;
      NEW.studyid := this_studyid;
    END IF;

  ELSE  -- Neither animid nor studyid was supplied (non-NULL)

    IF NEW.bid IS NULL THEN
      raise_bad_bid()
    END IF;

    -- Get the animd and studyid in case RETURNING is used and to
    -- check PLHDB permissions.
    SELECT biography.studyid, biography.animid
        INTO this_studyid,    this_animid
        FROM biography
        WHERE biography.bid = NEW.bid;
    IF NOT FOUND THEN
      raise_bad_bid()
    END IF;

    NEW.studyid := this_studyid;
    NEW.animid  := this_animid;
  END IF;

  -- Check PLHDB permissions (now we have a studyid)

  IF NOT(biography_insert_access(NEW.studyid)) THEN
    RAISE EXCEPTION insufficient_privilege USING
          MESSAGE = 'Error on ' || TG_OP || ' of FERTILITIES'
        , DETAIL = 'Key(FId) = (' || textualize(`NEW.fid')
                   || '): Value (BId) = (' || NEW.bid
                   || '): Value (StudyId) = (' || NEW.studyid
                   || '): Value (AnimId) = (' || NEW.animid
                   || '): Permission denied to this row'
        , HINT = 'To insert this row ''plh_insert'' level PLHDB permission '
                 || 'to the StudyId is required ';
  END IF;

  -- Make sure we have a fid
  IF NEW.fid IS NULL THEN
    SELECT nextval('fertility_fid_seq'::REGCLASS)
      INTO NEW.fid;
  END IF;

  -- Insert the underlying fertility row
  INSERT INTO fertility (
        fid
      , bid
      , startdate
      , starttype
      , stopdate
      , stoptype)
    VALUES(NEW.fid
         , NEW.bid
         , NEW.startdate
         , NEW.starttype
         , NEW.stopdate
         , NEW.stoptype);

  RETURN NEW;
  END;
$$;



SELECT 'fertilities_update_func' AS function;
CREATE FUNCTION fertilities_update_func ()
  RETURNS trigger
  LANGUAGE plpgsql
  plh_function_set_search_path
  AS $$
  DECLARE
    this_animid  biography.animid%TYPE;
    this_studyid biography.studyid%TYPE;

  BEGIN
  -- Function for fertilities update triggers
  --
  -- GPL_notice(`  --', `2016', `The Meme Factory, Inc., http://www.meme.com/')

  -- Check PLHDB permissions

  -- Check access to the old study.
  IF NOT(biography_edit_access(OLD.studyid)) THEN
    RAISE EXCEPTION insufficient_privilege USING
          MESSAGE = 'Error on ' || TG_OP || ' of FERTILITIES'
        , DETAIL = 'Key(OLD FId) = (' || OLD.fid
                   || '): Value (OLD BId) = (' || OLD.bid
                   || '): Value (OLD StudyId) = (' || OLD.studyid
                   || '): Value (OLD AnimId) = (' || OLD.animid
                   || '): Key(NEW FId) = (' || textualize(`NEW.fid')
                   || '): Value (NEW BId) = ('
                   || textualize(`NEW.bid')
                   || '): Value (NEW StudyId) = ('
                   || textualize(`NEW.studyid')
                   || '): Value (NEW AnimId) = ('
                   || textualize(`NEW.animid')
                   || '): Permission denied to this row'
        , HINT = 'To update this row ''plh_edit'' level PLHDB permission '
                 || 'to the old StudyId is required ';
  END IF;


  -- Update the underlying table

  -- What is the new studyid or animid?
  -- It is a change in studyid or animid that registers.
  IF NEW.studyid IS DISTINCT FROM OLD.studyid
     OR NEW.animid IS DISTINCT FROM OLD.animid THEN

    IF NEW.bid IS DISTINCT FROM OLD.bid THEN
      -- bid changed also
      -- Are the new bid and new animid+studyid referencing the same row?
      SELECT biography.studyid, biography.animid
        INTO this_studyid,      this_animid
        FROM biography
        WHERE biography.bid = NEW.bid;
      IF NOT FOUND THEN
        raise_bad_bid()
      END IF;

      IF NEW.studyid IS DISTINCT FROM this_studyid
         OR NEW.animid IS DISTINCT FROM this_animid THEN
        RAISE EXCEPTION integrity_constraint_violation USING
              MESSAGE = 'Error on ' || TG_OP || ' of FERTILITIES'
            , DETAIL = 'Key(OLD FId) = (' || OLD.fid
                     || '): Value (OLD BId) = (' || OLD.bid
                     || '): Value (OLD StudyId) = (' || OLD.studyid
                     || '): Value (OLD AnimId) = (' || OLD.animid
                     || '): Key(NEW BId) = (' || textualize(`NEW.bid')
                     || '): Value (NEW StudyId) = ('
                     || textualize(`NEW.studyid')
                     || '): Value (NEW AnimId) = ('
                     || textualize(`NEW.animid')
                     || '): Key (BIOGRAPHY.BId) = (' || NEW.bid
                     || '): Value (BIOGRAPHY.StudyId) = (' || this_studyid
                     || '): Value (BIOGRAPHY.AnimId) = (' || this_animid
                     || '): The supplied new StudyId/AnimId combination '
                     || 'do not refer to the same BIOGRAPHY row as the '
                     || 'new Bid';
      END IF;
    ELSE -- bid did not change
      -- Get the bid to go with the changed studyid/animid
      SELECT biography.bid
        INTO NEW.bid
        FROM biography
        WHERE biography.studyid = NEW.studyid
              AND biography.animid = NEW.animid;
      IF NOT FOUND THEN
        RAISE EXCEPTION integrity_constraint_violation USING
              MESSAGE = 'Error on ' || TG_OP || ' of FERTILITIES'
            , DETAIL = 'Key(OLD FId) = (' || OLD.fid
                       || '): Value (OLD BId) = (' || OLD.bid
                       || '): Value (OLD StudyId) = (' || OLD.studyid
                       || '): Value (OLD AnimId) = (' || OLD.animid
                       || '): Key(NEW BId) = (' || OLD.bid -- deliberate OLD,
                                                           -- NEW is lost
                       || '): Value (NEW StudyId) = ('
                       || textualize(`NEW.studyid')
                       || '): Value (NEW AnimId) = ('
                       || textualize(`NEW.animid')
                       || '): The supplied new StudyId and new AnimId values '
                       || 'do not refer to an existant BIOGRAPHY row';
      END IF;
    END IF;
  ELSE  -- Neither studyid nor animid changed

    IF NEW.bid IS NULL THEN
      raise_bad_bid()
    END IF;

    IF NEW.bid <> OLD.bid THEN
      -- Set the new studyid and animid, for a RETURNING clause and for
      -- PLHDB permission checking.
      SELECT biography.studyid, biography.animid
        INTO NEW.studyid,       NEW.animid
        FROM biography
        WHERE biography.bid = NEW.bid;
      IF NOT FOUND THEN
        raise_bad_bid()
      END IF;
    END IF;
  END IF;

  -- Check PLHDB permissions

  -- Check access to new study.  (Now that we have the studyid.)

  IF NEW.studyid <> OLD.studyid
     AND NOT(biography_edit_access(NEW.studyid)) THEN
    RAISE EXCEPTION insufficient_privilege USING
          MESSAGE = 'Error on ' || TG_OP || ' of FERTILITIES'
        , DETAIL = 'Key(OLD FId) = (' || OLD.fid
                   || '): Value (OLD BId) = (' || OLD.bid
                   || '): Value (OLD StudyId) = (' || OLD.studyid
                   || '): Value (OLD AnimId) = (' || OLD.animid
                   || '): Key(NEW BId) = (' || NEW.bid
                   || '): Value (NEW StudyId) = (' || NEW.studyid
                   || '): Value (NEW AnimId) = (' || NEW.animid
                   || '): Permission denied to this row'
        , HINT = 'To update this row ''plh_edit'' level PLHDB permission '
                 || 'to the new StudyId is required ';
  END IF;

  UPDATE fertility
    SET fid        = NEW.fid
      , bid        = NEW.bid
      , startdate  = NEW.startdate
      , starttype  = NEW.starttype
      , stopdate   = NEW.stopdate
      , stoptype   = NEW.stoptype
    WHERE fid = OLD.fid;

  RETURN NEW;
  END;
$$;


SELECT 'fertilities_delete_func' AS function;
CREATE FUNCTION fertilities_delete_func ()
  RETURNS trigger
  LANGUAGE plpgsql
  plh_function_set_search_path
  AS $$
  -- Function for fertilities delete trigger
  --
  -- GPL_notice(`  --', `2016', `The Meme Factory, Inc., http://www.meme.com/')

  DECLARE

  BEGIN

    -- Check PLHDB permissions
    IF NOT(fertility_all_access(OLD.bid)) THEN
      RAISE EXCEPTION insufficient_privilege USING
            MESSAGE = 'Error on ' || TG_OP || ' of FERTILITIES'
          , DETAIL = 'Key(FId) = (' || OLD.fid
                     || '): Value (BId) = (' || OLD.Bid
                     || '): Value (StudyId) = (' || OLD.studyid
                     || '): Value (AnimId) = (' || OLD.animid
                     || '): Permission denied to this row'
          , HINT = 'To delete this row ''plh_all'' level PLHDB permission '
                   || 'to the StudyId is required ';
    END IF;

    -- Delete from the underlying table
    DELETE
      FROM fertility
      WHERE fertility.fid = OLD.fid;

  RETURN OLD;
  END;
$$;


SELECT 'fertilities_insert_trigger' AS trigger;
CREATE TRIGGER fertilities_insert_trigger
  INSTEAD OF INSERT
  ON fertilities FOR EACH ROW
  EXECUTE PROCEDURE fertilities_insert_func();

SELECT 'fertilities_update_trigger' AS trigger;
CREATE TRIGGER fertilities_update_trigger
  INSTEAD OF UPDATE
  ON fertilities FOR EACH ROW
  EXECUTE PROCEDURE fertilities_update_func();

SELECT 'fertilities_delete_trigger' AS trigger;
CREATE TRIGGER fertilities_delete_trigger
  INSTEAD OF DELETE
  ON fertilities FOR EACH ROW
  EXECUTE PROCEDURE fertilities_delete_func();
