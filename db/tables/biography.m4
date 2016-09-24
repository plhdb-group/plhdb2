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

CREATE TABLE biography (
   bid SERIAL PRIMARY KEY
 , studyid VARCHAR(12) NOT NULL
   CONSTRAINT "StudyId must be a STUDY.Id value"
              REFERENCES study
 , animid VARCHAR(16) NOT NULL
   empty_string_check(`AnimId')
   sensible_whitespace(`AnimId')
 , animname VARCHAR(128)
   empty_string_check(`AnimName')
   sensible_whitespace(`AnimName')
 , birthdate DATE NOT NULL
   CONSTRAINT "BirthDate <= EntryDate"
              CHECK(birthdate <= entrydate)
 , bdmin DATE NOT NULL
   CONSTRAINT "BDMin <= BirthDate"
              CHECK(bdmin <= birthdate)
 , bdmax DATE NOT NULL
   CONSTRAINT "Birthdate <= BDMax"
              CHECK(birthdate <= bdmax)
   CONSTRAINT "BDMax <= DepartDate when DepartDateError = 0"
              CHECK(departdateerror <> 0
                    OR bdmax <= departdate)
 , bddist CHAR(1) NOT NULL
   CONSTRAINT "BDDist must be a PROBABILITY_TYPE.Code value"
              REFERENCES probability_type
 , birthgroup VARCHAR(32)
   empty_string_check(`BirthGroup')
   sensible_whitespace(`BirthGroup')
 , bgqual CHAR(1)
     CONSTRAINT "BGQual is NULL or one of plh_bgcertain or plh_bguncertain"
                CHECK(bgqual IS NULL
                      OR (bgqual IS NOT NULL
                          AND (bgqual = 'plh_bgcertain'
                               OR bgqual = 'plh_bguncertain')))
 , firstborn CHAR(1)
   CONSTRAINT
     "FirstBorn is NULL or one of: plh_fb_yes, plh_fb_no, plh_fb_unk"
     CHECK(firstborn IS NULL
           OR (firstborn IS NOT NULL
               AND (firstborn = 'plh_fb_yes'
                    OR firstborn = 'plh_fb_no'
                    OR firstborn = 'plh_fb_unk')))
 , mombid INTEGER
   CONSTRAINT "MomBId must be a BIOGRAPHY.BId value"
              REFERENCES biography
 , sex CHAR(1) NOT NULL
   CONSTRAINT "Sex one of: plh_male, plh_female, plh_unk_sex"
              CHECK(sex = 'plh_male'
                    OR sex = 'plh_female'
                    OR sex = 'plh_unk_sex')
 , entrydate DATE NOT NULL
   CONSTRAINT "EntryDate <= DepartDate"
              CHECK(entrydate <= departdate)
 , entrytype VARCHAR(8) NOT NULL
   CONSTRAINT "EntryType must be a START_EVENT.Code value"
              REFERENCES start_event
 , departdate DATE NOT NULL
 , departtype VARCHAR(8) NOT NULL
   CONSTRAINT "DepartType must be a END_EVENT.Code value"
              REFERENCES end_event
 , departdateerror DOUBLE PRECISION NOT NULL
   CONSTRAINT "DepartDateError >= 0"
              CHECK(departdateerror >= 0));

grant_seq_priv(`biography', `bid')


COMMENT ON TABLE biography IS
'One row per individual studied.  These individuals are those which
are the subject of observation, such as the animals in an animal life
history study. At present, animals can be the subject of only one
study; in the future this restriction may need to be lifted. Also,
birth groups are recorded directly as an attribute, and hence are
denormalized, but at present it is unclear which attributes other than
a name a birth group would need to have.


AnimId must be unique per StudyId.
AnimName must either be NULL or unique per StudyId.
BirthDate must be on or before EntryDate.
BDMin must be NULL or on or before BirthDate.
BDMax must be NULL or on or after BirthDate.
Entrydate must be on or before DepartDate.

HINT: Use the BIOGRAPHIES view to get the mother''s AnimId.
BIOGRAPHIES is identical to this table but has a column for the
mother''s AnimId.';

COMMENT ON COLUMN biography.bid IS
'Unique row identifer, and hence the unique identifer of the
individual regardless of study.

HINT: Can be used to JOIN with FEMALEFERTILITYINTERVAL.BId.';

COMMENT ON COLUMN biography.studyid IS
'Identifier of the study for which the individual is observed.  This
value may not be NULL.

HINT: Can be used to JOIN with STUDY.Id.';

COMMENT ON COLUMN biography.animid IS
'The identifier used by the study to denote the individual.  This
value may not be NULL.';

COMMENT ON COLUMN biography.animname IS
'The (long) name of the individual.  This value may be NULL when the
individual has no long name.';

COMMENT ON COLUMN biography.birthdate IS
'Birth date. Animal''s birthdate. The birthdate is either the exactly
known date of birth or it is midpoint of the range of possible
birthdates.  This value may not be NULL.';

COMMENT ON COLUMN biography.bdmin IS
'Estimated earliest birth date. Must differ from Birthdate whenever
earliest possible birth date is >7 days before Birthdate.  This value
may not be NULL.';

COMMENT ON COLUMN biography.bdmax IS
'Estimated latest birth date.  Must differ from Birthdate whenever
latest possible birth date is >7 days after Birthdate.  This value may
not be NULL.';

COMMENT ON COLUMN biography.bddist IS
'Probability distribution of the estimated birth date given BDMin,
Birthdate, and BDMax.  The vocabularly for this column is defined by
the PROBABILITY_TYPE table, which expected to define only normal (N)
and uniform (U). If N, construct the probability distribution so that
BDMin and BDMax represent + 2 standard deviations of Birthdate.  If U,
the probability distribution is truncated at BDMin and BDMax with
equal Birthdate probability within this range. If Birthdate is not at
the midpoint of BDMin and BDMax, distribution must be U. If Birthdate
is at the midpoint of BDMin and BDMax, distribution may be N or U.';

COMMENT ON COLUMN biography.birthgroup IS
'The name or code or ID of the group within which the individual was
born.  This value may be NULL to indicate that the group at birth is
unknown or the concept is not applicable.

Caution: This value is not validated.  As with all strings, it is
case-sensitive.';

COMMENT ON COLUMN biography.bgqual IS
'Quality of the estimate of the group of birth.  The degree of
certainty about which group this animal was born into.  Must be one of
''plh_bgcertain'' or ''plh_bguncertain'' for certain or uncertain.
This value may be NULL to indicate quality estimate is unknown.';

COMMENT ON COLUMN biography.firstborn IS
'Whether the individual is the first born, meaning the first offspring
from the maternal parent. Values are ''plh_fb_yes'', ''plh_fb_no'' and
''plh_fb_unk'', for Yes, No, and Unknown, respectively.  This value
may be NULL when the study does not track first born.';

COMMENT ON COLUMN biography.mombid IS
'The row identifier of the individual''s mother.  This is a
BIOGRAPHY.BId value.  This value may be NULL when the mother is
unknown.

HINT: The study''s code for the mother may be found in the MomId
column of the BIOGRAPHIES view.';

COMMENT ON COLUMN biography.sex IS
'The gender of the individual. Allowed values are ''plh_male'',
''plh_female'', and ''plh_unk_sex'', for male, female, and unknown,
respectively.  This value may not be NULL.';

COMMENT ON COLUMN biography.entrydate IS
'Date the animal was first seen. Date on which the animal is first
sighted in the study population, either because the animal is
recognized and ID''d as of that date or because strong inference
indicates group membership from that date. Study population is the
studied population at the time of the animal''s entry into it.  This
value may not be NULL.';

COMMENT ON COLUMN biography.entrytype IS
'Type of entry into population. Birth, immigration, start of confirmed
ID, Initiation of close observation for any other reason, etc.  The
vocabularly for this column is defined by the START_EVENT table.  This
value may not be NULL.';

COMMENT ON COLUMN biography.departdate IS
'Date on which the animal was last seen alive in the population.  This
value may not be NULL.';

COMMENT ON COLUMN biography.departtype IS
'Type of departure.  Death, permanent disappearance, emigration out of
the study population, end of close observation for any other reason,
or end of currently entered data period.  Death may be assigned only
in cases where the evidence is very strong: body found, or
circumstantial evidence indicates poor health or other risks
contributing to mortality and/or violations of population-specific
behavior patterns. Otherwise assign permanent disappearance. Do not
assign mortality based solely on inferred risks associated with age.
The vocabularly for this column is defined by the END_EVENT table.
This value may not be NULL.';

COMMENT ON COLUMN biography.departdateerror IS
'Time between departdate and the first time that the animal was
confirmed missing.  Expressed as fraction of a year (number of days
divided by number of days in a year).  Assign a zero to
DepartdateError only if the number of day between departdate and the
first time that the animal was confirmed missing was < 15.  This value
may not be NULL.';

-- Unique indexes, for utility but also to enforce data integrity!
CREATE UNIQUE INDEX biography_studyid_animid
   ON biography (studyid, animid);
CREATE UNIQUE INDEX biography_studyid_animname
   ON biography (studyid, animname);

-- Other indexes
CREATE INDEX biography_studyid ON biography (studyid);
CREATE INDEX biography_animid ON biography (animid);
CREATE INDEX biography_animname ON biography (animname);
CREATE INDEX biography_birthdate ON biography (birthdate);
CREATE INDEX biography_bdmin ON biography (bdmin);
CREATE INDEX biography_bdmax ON biography (bdmax);
CREATE INDEX biography_birthgroup ON biography (birthgroup);
CREATE INDEX biography_mombid ON biography (mombid);
CREATE INDEX biography_entrydate ON biography (entrydate);
CREATE INDEX biography_departdate ON biography (departdate);

