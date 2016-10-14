dnl Copyright (C) 2016 The Meme Factory, Inc.  http://www.meme.com/
dnl
dnl    This file is part of PLHDB2.
dnl
dnl    PLHDB2 is free software; you can redistribute it and/or modify
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
dnl    along with PLHDB2.  If not, see <http://www.gnu.org/licenses/>.
dnl
dnl Karl O. Pinc <kop@meme.com>
dnl

include(`copyright.m4')
include(`tablemacros.m4')
include(`grants.m4')
include(`constants.m4')
include(`fertility_comments.m4')

CREATE TABLE fertility (
   fid SERIAL PRIMARY KEY
 , bid INTEGER NOT NULL
     CONSTRAINT "BId must be BIOGRAPHY.BId value"
                REFERENCES biography
 , startdate DATE NOT NULL
 , starttype CHAR(1) NOT NULL
     CONSTRAINT "StartType must be a START_EVENT.Code value"
                REFERENCES start_event
 , stopdate DATE NOT NULL
     CONSTRAINT "StartDate must be <= StopDate"
                CHECK(startdate <= stopdate)
 , stoptype CHAR(1) NOT NULL
     CONSTRAINT "StopType must be a END_EVENT.Code value"
                REFERENCES end_event);

ALTER TABLE fertility ENABLE ROW LEVEL SECURITY;

grant_row_level_priv(`fertility')
grant_demo_user_priv(`fertility')


COMMENT ON TABLE fertility IS 
'One row per uninterrupted period of observation on a female; during
which no possible births would have been missed.

Access to rows in FERTILITY is controlled, on a per-study basis, by the
PERMISSION table.

Per individual, fertility intervals may not overlap.
StartDate must be on or before StopDate.

Only BIOGRAPHY rows with Sex = ''plh_female'' may have related female
fertility interval rows.

FERTILITY rows may be related only to those BIOGRAPHY
rows which have a FALSE MomOnly value.

The StartDate cannot be before the EntryDate of the related BIOGRAPHY
row.

The StopDate cannot be after the date from the related individual''s
BIOGRAPHY row given by the formula (DepartDate plus (DepartDateError
number of years)).

Rows with a StartDate which matches the related BIOGRAPHY row''s
EntryDate must have a StartType value which is that of the related
BIOGRAPHY row''s EntryType.  This condition is checked on transaction
commit.

Rows with a StopDate which matches the related BIOGRAPHY row''s
DepartDate must have a StopType value which is that of the related
BIOGRAPHY row''s DepartType.  This condition is checked on transaction
commit.

Rows with a StartType flagged as Initial on the START_EVENT table must
have a StartDate equal to the related BIOGRAPHY row''s EntryDate.  This
condition is checked on transaction commit, except in the case where
START_EVENT.Initial is altered.

Rows with a StopType flagged as Final on the END_EVENT table must have
a StopDate equal to the related BIOGRAPHY row''s DepartDate.  This
condition is checked on transaction commit, except in the case where
END_EVENT.Final is altered.

TIP: Use the FERTILITIES view to see AnimId and StudyId columns.
FERTILITIES is identical to this table but for the additional
columns.';


comment_fertility_columns(`fertility')


CREATE INDEX fertility_bid
             ON fertility (bid);
CREATE INDEX fertility_startdate
             ON fertility (startdate);
CREATE INDEX fertility_starttype
             ON fertility (starttype);
CREATE INDEX fertility_stopdate
             ON fertility (stopdate);
CREATE INDEX fertility_stoptype
             ON fertility (stoptype);
