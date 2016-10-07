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

For more information see the FERTILITY table documentation.';


comment_fertility_columns(`fertilities')


COMMENT ON COLUMN fertilities.studyid IS
'Identifier of the study for which the individual is observed.  This
value may not be NULL.

TIP: Can be used to JOIN with STUDY.Id.';

COMMENT ON COLUMN fertilities.animid IS
'The identifier used by the study to denote the individual.  This value
may not be NULL.';
