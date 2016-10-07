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

For more information see the documentation of the BIOGRAPHY table.';

comment_biography_columns(`biographies')

COMMENT ON COLUMN biographies.momid IS
'The identifier used by the study to denote the indivdual''s mother.
This value may be NULL when the mother is unknown.';
