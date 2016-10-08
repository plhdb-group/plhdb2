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

dnl Comments on column definitions

changequote({,})

define({comment_fertility_columns}, {dnl
COMMENT ON COLUMN $1.fid IS
'Unique row identifer, and hence the unique identifer of the female
fertility interval.  The value of this column is automatically
assigned by the system; the normal practice, which results in a system
generated id, is to omit this column when inserting new rows or to
supply a NULL value.  The value of this column cannot be NULL.  The
value of this column cannot be changed.';

COMMENT ON COLUMN $1.bid IS
'Unique identifer of the individual for which the row records a
fertility interval.

TIP: Can be used to JOIN with BIOGRAPHY.BId.';

COMMENT ON COLUMN $1.startdate IS
'Startdate for fertility surveillance.  Date on which surveillance of
fertility began.  This date must not have error associated with
it. These dates are con servative: if you are sure that you know about
her starting on July 15 but you MIGHT know about her starting on July
1, you must choose the more conservative date, which is July 15.  This
value may not be NULL.';

COMMENT ON COLUMN $1.starttype IS
'Reason for the start of surveillance. The vocabularly for this column
is defined by the START_EVENT table.  This value may not be NULL.';

COMMENT ON COLUMN $1.stopdate IS
'Stopdate for fertility surveillance.  Date on which surveillance of
fertility ended.  Surveillance ends when you stop seeing the animal for
a long enough period of time that births could be missed.  This date
must not have error associated with it. These dates are conservative:
if you are sure that you know about her until July 1 but you MIGHT know
about her until July 15, you must choose the more conservative date
which is July 1.  This value may not be NULL.';

COMMENT ON COLUMN $1.stoptype IS
'Cause of the end of surveillance. The vocabularly for this column is
defined by the END_EVENT table.  This value may not be NULL.';
})

changequote(`,')
