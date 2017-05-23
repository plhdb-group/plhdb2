dnl Copyright (C) 2017 Jake Gordon <jacob.gordon@duke.edu>
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

dnl Comments on column definitions

changequote({,})

define({comment_study_columns}, {dnl
COMMENT ON COLUMN $1.sid IS
'Unique row identifier.  May not be ''plh_allstudies'' or NULL.';

COMMENT ON COLUMN $1.name IS
'The name of the study. This may be a descriptive or encoded, must be
unique if not NULL.';

COMMENT ON COLUMN $1.owners IS
'The owners of the observational data that this study gave rise to.
This may be a single person, an organization, or a (comma-delimited)
list of such.';

COMMENT ON COLUMN $1.taxonid IS
'The row identifier of the taxon for the individuals that were or are
being observed in this study.';

COMMENT ON COLUMN $1.siteid IS
'The row identifer of the site where this study was or is being
conducted, and hence where the individuals have been observed.';
})

changequote(`,')
