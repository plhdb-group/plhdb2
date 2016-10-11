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
include(`permission_comments.m4')

CREATE TABLE permission (
  pid SERIAL PRIMARY KEY
, access VARCHAR(10) NOT NULL
    CONSTRAINT
      "Access must be one of plh_search, plh_insert, plh_edit, plh_all"
      CHECK (access = 'plh_search'
             OR access = 'plh_insert'
             OR access = 'plh_edit'
             OR access = 'plh_all')
, study plh_studyid_type NOT NULL
, username NAME NOT NULL);

grant_managers_seq_priv(`permission', `pid')


COMMENT ON TABLE permission IS

'Contains at most one row per user per study, each row defining the
PLHDB permission level the study grants to the user.  PLHDB
permissions apply only to PLHDB manager and user accounts, and
managers may change any of them.  When a user has no row for a study
the user has no permissions to the study.  The combination of study
and username must be unique.  When study is ''plh_allstudies'' the
username must be unique.

Adding a row to PERMISSION can only increase a user''s access.
Permission is never taken away.  So, in case of conflict between
permission granted to all studies and permission granted to a specific
study the user has the more permissive of the two.

TIP: The contents of this table is accessible only to administrator
and PLHDB manager accounts; use the PERMISSIONS view instead.';


comment_permission_columns(`permission')


CREATE INDEX permission_username ON permission (username);
CREATE UNIQUE INDEX permission_username_study ON permission (username, study);
