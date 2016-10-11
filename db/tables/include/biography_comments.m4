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

dnl Comments on column definitions

changequote({,})

define({comment_biography_columns}, {dnl
COMMENT ON COLUMN $1.bid IS
'Unique row identifer, and hence a unique identifer of the individual
regardless of study.  The value of this column is automatically
assigned by the system; the normal practice, which results in a system
generated id, is to omit this column when inserting new rows or to
supply a NULL value.  The value of this column cannot be NULL.  The
value of this column cannot be changed.

TIP: Can be used to JOIN with FERTILITY.BId.';

COMMENT ON COLUMN $1.studyid IS
'Identifier of the study for which the individual is observed.  This
value may not be NULL.

TIP: Can be used to JOIN with STUDY.Id.';

COMMENT ON COLUMN $1.animid IS
'The identifier used by the study to denote the individual.  This
value may not be NULL.';

COMMENT ON COLUMN $1.animname IS
'The (long) name of the individual.  This value may be NULL when the
individual has no long name.';

COMMENT ON COLUMN $1.momonly IS
'Whether or not the biography row records an individual who exists in
the database only because they are known to be a mother of another
individual in the database.  A boolean value.  Individuals who are
"only mothers" (MomOnly = TRUE) have different requirements from
typical study subjects as to what data must or must not be recorded in
the database.  This value may not be NULL.';

COMMENT ON COLUMN $1.birthdate IS

'Birth date. Animal''s birthdate. The birthdate is either the exactly
known date of birth or it is with a range of possible birthdates.

The BirthDate must be on or after plh_minbirth.

Caution: The automatic data integrity check for early BirthDates does
not provide adequate per-study data integrity.';


COMMENT ON COLUMN $1.bdmin IS
'Estimated earliest birth date. Must differ from Birthdate whenever
earliest possible birth date is >7 days before Birthdate.';

COMMENT ON COLUMN $1.bdmax IS
'Estimated latest birth date.  Must differ from Birthdate whenever
latest possible birth date is >7 days after Birthdate.';

COMMENT ON COLUMN $1.bddist IS
'Probability distribution of the estimated birth date given BDMin,
Birthdate, and BDMax.  The vocabularly for this column is defined by
the PROBABILITY_TYPE table, which expected to define only normal (N)
and uniform (U).';

COMMENT ON COLUMN $1.birthgroup IS
'The name or code or ID of the group within which the individual was
born.  This value may be NULL to indicate that the group at birth is
unknown or the concept is not applicable.

Caution: This value is not validated.  As with all strings, it is
case-sensitive.';

COMMENT ON COLUMN $1.bgqual IS
'Quality of the estimate of the group of birth.  The degree of
certainty about which group this animal was born into.  Must be one of
''plh_bgcertain'' or ''plh_bguncertain'' for certain or uncertain.
This value may be NULL to indicate quality estimate is unknown.';

COMMENT ON COLUMN $1.firstborn IS
'Whether the individual is the first born, meaning the first offspring
from the maternal parent. Values are ''plh_fb_yes'', ''plh_fb_no'' and
''plh_fb_unk'', for Yes, No, and Unknown, respectively.  This value
may be NULL when the study does not track first born.';

COMMENT ON COLUMN $1.mombid IS
'The row identifier of the individual''s mother.  This is a
BIOGRAPHY.BId value.  This value may be NULL when the mother is
unknown.

TIP: The study''s code for the mother may be found in the MomId
column of the BIOGRAPHIES view.';

COMMENT ON COLUMN $1.sex IS
'The gender of the individual. Allowed values are ''plh_male'',
''plh_female'', and ''plh_unk_sex'', for male, female, and unknown,
respectively.  This value may not be NULL.';

COMMENT ON COLUMN $1.entrydate IS
'Date the animal was first seen. Date on which the animal is first
sighted in the study population, either because the animal is
recognized and ID''d as of that date or because strong inference
indicates group membership from that date. Study population is the
studied population at the time of the animal''s entry into it.

EntryDate must be on or after plh_minentry.
EntryDate must be on or before today''s date.

Caution: The automatic data integrity check for early EntryDates does
not provide adequate per-study data integrity.';

COMMENT ON COLUMN $1.entrytype IS
'Type of entry into population. Birth, immigration, start of confirmed
ID, Initiation of close observation for any other reason, etc.  The
vocabularly for this column is defined by the START_EVENT table.';

COMMENT ON COLUMN $1.departdate IS
'Date on which the animal was last seen alive in the population.
DepartDate must be on or before today''s date.';

COMMENT ON COLUMN $1.departtype IS
'Type of departure.  Death, permanent disappearance, emigration out of
the study population, end of close observation for any other reason,
or end of currently entered data period.  Death may be assigned only
in cases where the evidence is very strong: body found, or
circumstantial evidence indicates poor health or other risks
contributing to mortality and/or violations of population-specific
behavior patterns. Otherwise assign permanent disappearance. Do not
assign mortality based solely on inferred risks associated with age.
The vocabularly for this column is defined by the END_EVENT table.';

COMMENT ON COLUMN $1.departdateerror IS
'Time between departdate and the first time that the animal was
confirmed missing.  Expressed as fraction of a year (number of days
divided by plh_days_in_year).  Assign a zero to DepartdateError only if
the number of day between departdate and the first time that the animal
was confirmed missing was < 15.';
})

changequote(`,')
