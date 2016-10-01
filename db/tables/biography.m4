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

dnl plpgsql fragment to allow NULL column content only when MomOnly is TRUE
dnl
dnl Syntax: null_only_when_momonly(colname)
dnl
dnl colname  The name of the column dependent on MomOnly vis NULL
dnl
changequote({,})
define({null_only_when_momonly},{dnl
   CONSTRAINT "$1 cannot be NULL unless MomOnly is TRUE"
              CHECK(momonly
                    OR (NOT(momonly)
                        AND $1 IS NOT NULL))
})dnl
changequote(`,')dnl


CREATE TABLE biography (
   bid SERIAL PRIMARY KEY
 , studyid plh_studyid_type NOT NULL
     CONSTRAINT "StudyId must be a STUDY.Id value"
                REFERENCES study
 , animid VARCHAR(16) NOT NULL
     empty_string_check(`AnimId')
     sensible_whitespace(`AnimId')
 , animname VARCHAR(128)
     empty_string_check(`AnimName')
     sensible_whitespace(`AnimName')
 , momonly BOOLEAN NOT NULL
 , birthdate DATE
     CONSTRAINT "BirthDate <= EntryDate"
                CHECK(birthdate <= entrydate)
     null_only_when_momonly(`BirthDate')
     CONSTRAINT "BirthDate >= plh_minbirth"
                CHECK('plh_minbirth' <= BirthDate)
 , bdmin DATE
     CONSTRAINT "BDMin <= BirthDate"
                CHECK(bdmin <= birthdate)
     null_only_when_momonly(`BDMin')
 , bdmax DATE
     CONSTRAINT "Birthdate <= BDMax"
                CHECK(birthdate <= bdmax)
     null_only_when_momonly(`BDMax')
     CONSTRAINT "BDMax <= DepartDate when DepartDateError = 0"
                CHECK(departdateerror <> 0
                      OR bdmax <= departdate)
 , bddist CHAR(1)
     null_only_when_momonly(`BDDist')
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
     CONSTRAINT "Sex = 'plh_female' when MomOnly = TRUE"
                CHECK(NOT(momonly)
                      OR sex = 'plh_female')
 , entrydate DATE
     CONSTRAINT "EntryDate <= DepartDate"
                CHECK(entrydate <= departdate)
     null_only_when_momonly(`EntryDate')
     CONSTRAINT "EntryDate must be on or before today's date"
                CHECK(entrydate <= current_date)
 , entrytype VARCHAR(8)
     CONSTRAINT "EntryType must be a START_EVENT.Code value"
                REFERENCES start_event
     null_only_when_momonly(`EntryType')
     CONSTRAINT "EntryType can be NULL only when EntryDate is NULL"
                CHECK(entrydate IS NULL
                      OR entrytype IS NOT NULL)
 , departdate DATE
     null_only_when_momonly(`DepartDate')
     CONSTRAINT "DepartDate must be on or before today's date"
                CHECK(departdate <= current_date)
 , departtype VARCHAR(8)
     CONSTRAINT "DepartType must be a END_EVENT.Code value"
                REFERENCES end_event
     CONSTRAINT "DepartType can be NULL only when DepartDate is NULL"
                CHECK(departdate IS NULL
                      OR departtype IS NOT NULL)
 , departdateerror DOUBLE PRECISION
     CONSTRAINT "DepartDateError >= 0"
                CHECK(departdateerror >= 0)
     CONSTRAINT "DepartDateError can be NULL if and only if DepartDate is NULL"
                CHECK((departdate IS NULL AND departdateerror IS NULL)
                      OR (departdate IS NOT NULL
                          AND departdateerror IS NOT NULL)));

grant_row_level_priv(`biography', `bid')
grant_demo_user_priv(`biography')


COMMENT ON TABLE biography IS
'One row per individual studied.  These individuals are those which
are the subject of observation, such as the animals in an animal life
history study. At present, animals can be the subject of only one
study; in the future this restriction may need to be lifted. Also,
birth groups are recorded directly as an attribute, and hence are
denormalized, but at present it is unclear which attributes other than
a name a birth group would need to have.

Access to rows in BIOGRAPHY is controlled, on a per-study basis, by the
PERMISSION table.

AnimId must be unique per StudyId.
AnimName must either be NULL or unique per StudyId.
BirthDate must be on or before EntryDate.
BirthDate may be NULL only when MomOnly is TRUE.
BDMin must be NULL or on or before BirthDate.
BDMin may be NULL only when MomOnly is TRUE.
BDMax must be NULL or on or after BirthDate.
BDMax may be NULL only when MomOnly is TRUE.
BDDist may be NULL only when MomOnly is TRUE.
Sex must be ''plh_female'' when MomOnly is TRUE.
Entrydate must be on or before DepartDate.
EntryDate may be NULL only when MomOnly is TRUE.
EntryDate may be NULL only when MomOnly is TRUE.
EntryType can be NULL only when EntryDate is also NULL.
DepartDate may be NULL only when MomOnly is TRUE.
DepartType can be NULL only when DepartDate is also NULL.
DepartDateError must be NULL if DepartDate is NULL.
DepartDateError must not be NULL if DepartDate is not NULL.

The combination of StudyId and AnimId must be unique.  Because niether
of these columns may be NULL this combination can, instead of the Bid
value, be used as a unique row identifier.

The combination of StudyId and AnimName must be unique.  Because
AnimName may be NULL this combination cannot be used as a unique row
identifier.

Individuals identifed as mothers (rows that have a BId value in the
MomBId column of another BIOGRAPHY row) must have a ''plh_female''
value for Sex.  Mothers and their offspring must have the same StudyId
value.

TIP: Use the BIOGRAPHIES view to get the mother''s AnimId.
BIOGRAPHIES is identical to this table but for the additional
column.';


COMMENT ON COLUMN biography.bid IS
'Unique row identifer, and hence a unique identifer of the individual
regardless of study.  The value of this column cannot be changed.

TIP: Can be used to JOIN with FEMALEFERTILITYINTERVAL.BId.';

COMMENT ON COLUMN biography.studyid IS
'Identifier of the study for which the individual is observed.  This
value may not be NULL.

TIP: Can be used to JOIN with STUDY.Id.';

COMMENT ON COLUMN biography.animid IS
'The identifier used by the study to denote the individual.  This
value may not be NULL.';

COMMENT ON COLUMN biography.animname IS
'The (long) name of the individual.  This value may be NULL when the
individual has no long name.';

COMMENT ON COLUMN biography.momonly IS
'Whether or not the biography row records an individual who exists in
the database only because they are known to be a mother of another
individual in the database.  A boolean value.  Individuals who are
"only mothers" (MomOnly = TRUE) have different requirements from
typical study subjects as to what data must or must not be recorded in
the database.  This value may not be NULL.';

COMMENT ON COLUMN biography.birthdate IS

'Birth date. Animal''s birthdate. The birthdate is either the exactly
known date of birth or it is with a range of possible birthdates.

The BirthDate must be on or after plh_minbirth.';

COMMENT ON COLUMN biography.bdmin IS
'Estimated earliest birth date. Must differ from Birthdate whenever
earliest possible birth date is >7 days before Birthdate.';

COMMENT ON COLUMN biography.bdmax IS
'Estimated latest birth date.  Must differ from Birthdate whenever
latest possible birth date is >7 days after Birthdate.';

COMMENT ON COLUMN biography.bddist IS
'Probability distribution of the estimated birth date given BDMin,
Birthdate, and BDMax.  The vocabularly for this column is defined by
the PROBABILITY_TYPE table, which expected to define only normal (N)
and uniform (U).';

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

TIP: The study''s code for the mother may be found in the MomId
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
studied population at the time of the animal''s entry into it.

EntryDate must be on or before today''s date.';

COMMENT ON COLUMN biography.entrytype IS
'Type of entry into population. Birth, immigration, start of confirmed
ID, Initiation of close observation for any other reason, etc.  The
vocabularly for this column is defined by the START_EVENT table.';

COMMENT ON COLUMN biography.departdate IS
'Date on which the animal was last seen alive in the population.
DepartDate must be on or before today''s date.';

COMMENT ON COLUMN biography.departtype IS
'Type of departure.  Death, permanent disappearance, emigration out of
the study population, end of close observation for any other reason,
or end of currently entered data period.  Death may be assigned only
in cases where the evidence is very strong: body found, or
circumstantial evidence indicates poor health or other risks
contributing to mortality and/or violations of population-specific
behavior patterns. Otherwise assign permanent disappearance. Do not
assign mortality based solely on inferred risks associated with age.
The vocabularly for this column is defined by the END_EVENT table.';

COMMENT ON COLUMN biography.departdateerror IS
'Time between departdate and the first time that the animal was
confirmed missing.  Expressed as fraction of a year (number of days
divided by number of days in a year).  Assign a zero to
DepartdateError only if the number of day between departdate and the
first time that the animal was confirmed missing was < 15.';

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

