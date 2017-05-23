-- Copyright (C) 2017 Jake Gordon <jacob.gordon@duke.edu>
-- Copyright (C) 2016 The Meme Factory, Inc.  http://www.meme.com/
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
include(`study_comments.m4')

-- STUDY table, with latest DepartDate from BIOGRAPHY
CREATE OR REPLACE VIEW studies AS
  SELECT study.sid AS sid
       , study.name AS name
       , study.owners AS owners
       , study.taxonid AS taxonid
       , study.siteid AS siteid
       , (SELECT departdate
            FROM biography
            WHERE biography.studyid = study.sid
              AND biography.departdate IS NOT NULL
            ORDER BY departdate DESC
            LIMIT 1
         ) AS latest_departdate
    FROM study;

grant_priv(`studies')


COMMENT ON VIEW studies IS
'One row per study.  This view is identical to the STUDY table, except
for the addition of the Latest_DepartDate column.

As in the STUDY table, this table is not affected by any row-level
security policies. Users with no rows PERMISSION are still able to see
this view''s data.';

comment_study_columns(`studies')

COMMENT ON COLUMN studies.latest_departdate IS
'The latest (most recent) BIOGRAPHY.DepartDate for this study, or NULL
if this study has no BIOGRAPHY rows with a non-NULL DepartDate.';
