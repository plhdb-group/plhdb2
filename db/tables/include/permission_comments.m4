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

define({comment_permission_columns}, {dnl
COMMENT ON COLUMN $1.pid IS
  'Unique row identifier.';

COMMENT ON COLUMN $1.access IS
'The type of access granted.  Must be one of:

  plh_search
    - Can read study data;

  plh_insert
    - plh_search permissions + Can create new rows;

  plh_edit
    - plh_insert permissions + Can alter existing rows;

  plh_all
    - plh_edit permissions + Can delete existing rows.';

COMMENT ON COLUMN $1.study IS
'The STUDY.Name of the study to which permission is granted or
''plh_allstudies'' if permission is granted to all studies.';

COMMENT ON COLUMN $1.username IS
'The ROLE.rolname of the user to which permission is granted.  The
value of this column cannot be changed.

HINT: See the "accounts" view for information on users.';
})

changequote(`,')
