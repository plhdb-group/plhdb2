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
dnl  Macros to set privliges.
dnl
dnl Remarks:
dnl
dnl m4 includes
include(`copyright.m4')dnl
include(`constants.m4')dnl
dnl
changequote([{[,]}])dnl m4 foolery so includes include only once.
dnl                     Once the macro is in the text, change the quotes back
ifdef([{[_grants.m4]}], [{[changequote(`,')]}], [{[dnl
changequote(`,')dnl
dnl
dnl Standard test for having already included the file.
define(`_grants.m4')dnl
dnl
dnl Don't output anything while defining macros.
divert(-1)

dnl Define m4 macros so we don't have to type so much.
dnl (Or at least type stuff that's more fun.)
dnl
dnl Watch out for using the single quote char as it has speical
dnl meaning to m4.
dnl 


dnl Grant privliges to a table.
dnl
dnl This also prints the name of the table.  As every table has
dnl priviliges granted on it we get to monitor progress this way.
dnl
dnl Syntax: grant_priv(tablename)
changequote([,])
define([grant_priv],[
GRANT SELECT ON $1 TO GROUP plhdb_users;
GRANT SELECT ON $1 TO GROUP plhdb_managers;
GRANT REFERENCES ON $1 TO GROUP plhdb_users;
GRANT REFERENCES ON $1 TO GROUP plhdb_managers;
GRANT INSERT ON $1 TO GROUP plhdb_managers;
GRANT UPDATE ON $1 TO GROUP plhdb_managers;
GRANT DELETE ON $1 TO GROUP plhdb_managers;
SELECT '$1' AS done_with;
])
changequote(`,')


dnl Grant privliges to a table's sequence
dnl
dnl This also prints the name of the sequence.
dnl
dnl Syntax: grant_seq_priv(tablename, idname)
changequote([,])
define([grant_seq_priv],[
grant_priv($1)

GRANT SELECT ON $1_$2_seq TO GROUP plhdb_users;
GRANT SELECT ON $1_$2_seq TO GROUP plhdb_managers;
GRANT UPDATE ON $1_$2_seq TO GROUP plhdb_managers;
SELECT '$1_$2_seq' AS done_with;
])
changequote(`,')


dnl Grant privliges to a table which uses row-level security.
dnl
dnl This also prints the name of the table.  As every table has
dnl priviliges granted on it we get to monitor progress this way.
dnl
dnl Syntax: grant_row_level_priv(tablename)
changequote([,])
define([grant_row_level_priv],[
ALTER TABLE $1 ENABLE ROW LEVEL SECURITY;

GRANT SELECT ON $1 TO GROUP plhdb_users, plhdb_managers;
GRANT REFERENCES ON $1 TO GROUP plhdb_users, plhdb_managers;
GRANT INSERT ON $1 TO GROUP plhdb_users, plhdb_managers;
GRANT UPDATE ON $1 TO GROUP plhdb_users, plhdb_managers;
GRANT DELETE ON $1 TO GROUP plhdb_users, plhdb_managers;
SELECT '$1' AS done_with;

GRANT SELECT ON $1_$2_seq TO GROUP plhdb_users, plhdb_managers;
GRANT UPDATE ON $1_$2_seq TO GROUP plhdb_users, plhdb_managers;
SELECT '$1_$2_seq' AS done_with;

-- Sequence priviliges on tables protected with row level security
-- are granted by trigger.
])
changequote(`,')


-- Done defining macros.
divert`'dnl
dnl
dnl
]}])dnl End of ifdef over the whole file.
