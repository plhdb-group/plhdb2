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
dnl    along with PLHDB2.  If not, see <http://www.gnu.org/licenses/>.
dnl
dnl Karl O. Pinc <kop@meme.com>
dnl

include(`copyright.m4')
include(`tablemacros.m4')
include(`grants.m4')
include(`constants.m4')
include(`globalmacros.m4')
include(`biography_comments.m4')

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
     CONSTRAINT "BirthDate must be <= EntryDate"
                CHECK(birthdate <= entrydate)
     null_only_when_momonly(`BirthDate')
     CONSTRAINT "BirthDate must be >= plh_minbirth"
                CHECK('plh_minbirth' <= BirthDate)
 , bdmin DATE
     CONSTRAINT "BDMin must be <= BirthDate"
                CHECK(bdmin <= birthdate)
     null_only_when_momonly(`BDMin')
 , bdmax DATE
     CONSTRAINT "Birthdate must be <= BDMax"
                CHECK(birthdate <= bdmax)
     null_only_when_momonly(`BDMax')
     CONSTRAINT "BDMax must be <= DepartDate plus DepartDateError years"
                CHECK(bdmax <= plh_last_departdate_inline)
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
     CONSTRAINT "The MomBId value cannot be the BId value"
                CHECK(mombid <> bid)
 , sex CHAR(1) NOT NULL
     CONSTRAINT "Sex one of: plh_male, plh_female, plh_unk_sex"
                CHECK(sex = 'plh_male'
                      OR sex = 'plh_female'
                      OR sex = 'plh_unk_sex')
     CONSTRAINT "Sex must be = 'plh_female' when MomOnly = TRUE"
                CHECK(NOT(momonly)
                      OR sex = 'plh_female')
 , entrydate DATE
     CONSTRAINT "EntryDate must be <= DepartDate"
                CHECK(entrydate <= departdate)
     null_only_when_momonly(`EntryDate')
     CONSTRAINT "EntryDate must be on or after plh_minentry"
                CHECK('plh_minentry' <= entrydate)
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
     CONSTRAINT "DepartDateError must be >= 0"
                CHECK(departdateerror >= 0)
     CONSTRAINT "DepartDateError can be NULL if and only if DepartDate is NULL"
                CHECK((departdate IS NULL AND departdateerror IS NULL)
                      OR (departdate IS NOT NULL
                          AND departdateerror IS NOT NULL)));

ALTER TABLE biography ENABLE ROW LEVEL SECURITY;

grant_row_level_priv(`biography')
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
BDMax may not be after the sum DepartDate plus DepartDateError number
  of years.
BDDist may be NULL only when MomOnly is TRUE.
The MomBId value cannot be the Bid value.
Sex must be ''plh_female'' when MomOnly is TRUE.
Entrydate must be on or before DepartDate.
EntryDate may be NULL only when MomOnly is TRUE.
EntryDate may be NULL only when MomOnly is TRUE.
EntryType can be NULL only when EntryDate is also NULL.
DepartDate may be NULL only when MomOnly is TRUE.
DepartType can be NULL only when DepartDate is also NULL.
DepartDateError must be NULL if DepartDate is NULL.
DepartDateError must not be NULL if DepartDate is not NULL.

The combination of StudyId and AnimId must be unique.  Because neither
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

comment_biography_columns(`biography')


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

