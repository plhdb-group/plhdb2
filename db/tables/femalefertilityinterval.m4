dnl Copyright (C) 2016 The Meme Factory, Inc.  http://www.meme.com/
dnl
dnl    This file is part of PLHDB2.
dnl
dnl    PLDHB2 is free software; you can redistribute it and/or modify
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
dnl    along with Babase.  If not, see <http://www.gnu.org/licenses/>.
dnl
dnl Karl O. Pinc <kop@meme.com>
dnl

include(`copyright.m4')
include(`tablemacros.m4')
include(`grants.m4')
include(`constants.m4')

CREATE TABLE femalefertilityinterval (
   ffiid SERIAL PRIMARY KEY
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

grant_row_level_priv(`femalefertilityinterval', `ffiid')
grant_demo_user_priv(`femalefertilityinterval')


COMMENT ON TABLE femalefertilityinterval IS
'One row per observed fertility interval of a female animal.

Access to rows in FEMALEFERTILITYINTERVALS is controlled, on a
per-study basis, by the PERMISSION table.

Per individual, fertility intervals may not overlap.
StartDate must be on or before StopDate.

Only BIOGRAPHY rows with Sex = ''plh_female'' may have related female
fertility interval rows.

FEMALEFERTILITYINTERVAL rows may only be related to those BIOGRAPHY
rows which have a FALSE MomOnly value.

The StartDate cannot be before the EntryDate of the related BIOGRAPHY
row.

The StopDate cannot be after the date from the related individual''s
BIOGRAPHY row given by the formula (DepartDate plus (DepartDateError
number of years)).

TIP: Use the FEMALEFERTILITYINTERVALS view to see AnimId and StudyId
columns.  FEMALEFERTILITYINTERVALS is identical to this table but for
the additional columns.';


COMMENT ON COLUMN femalefertilityinterval.ffiid IS
'Unique row identifer, and hence the unique identifer of the female
fertility interval.';

COMMENT ON COLUMN femalefertilityinterval.bid IS
'Unique identifer of the individual for which the row records a
fertility interval.

TIP: Can be used to JOIN with BIOGRAPHY.BId.';

COMMENT ON COLUMN femalefertilityinterval.startdate IS
'Startdate for fertility surveillance.  Date on which surveillance of
fertility began.  This date must not have error associated with
it. These dates are con servative: if you are sure that you know about
her starting on July 15 but you MIGHT know about her starting on July
1, you must choose the more conservative date, which is July 15.  This
value may not be NULL.';

COMMENT ON COLUMN femalefertilityinterval.starttype IS
'Reason for the start of surveillance. The vocabularly for this column
is defined by the START_EVENT table.  This value may not be NULL.';

COMMENT ON COLUMN femalefertilityinterval.stopdate IS
'Stopdate for fertility surveillance.  Date on which surveillance of
fertility ended.  Surveillance ends when you stop seeing the animal for
a long enough period of time that births could be missed.  This date
must not have error associated with it. These dates are conservative:
if you are sure that you know about her until July 1 but you MIGHT know
about her until July 15, you must choose the more conservative date
which is July 1.  This value may not be NULL.';

COMMENT ON COLUMN femalefertilityinterval.stoptype IS
'Cause of the end of surveillance. The vocabularly for this column is
defined by the END_EVENT table.  This value may not be NULL.';


CREATE INDEX femalefertilityinteval_bid
             ON femalefertilityinterval (bid);
CREATE INDEX femalefertilityinterval_startdate
             ON femalefertilityinterval (startdate);
CREATE INDEX femalefertilityinterval_starttype
             ON femalefertilityinterval (starttype);
CREATE INDEX femalefertilityinterval_stopdate
             ON femalefertilityinterval (stopdate);
CREATE INDEX femalefertilityinterval_stoptype
             ON femalefertilityinterval (stoptype);
