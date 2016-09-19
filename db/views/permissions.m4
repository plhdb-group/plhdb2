-- Copyright (C) 2016 The Meme Factory, Inc., http://www.meme.com/
--
--    This file is part of PLHDB.
--
--    PLHDB is free software; you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation; either version 3 of the License, or
--    (at your option) any later version.
--
--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.
--
--    You should have received a copy of the GNU General Public License
--    along with PLHDB.  If not, see <http://www.gnu.org/licenses/>.
--
-- Karl O. Pinc <kop@meme.com>
--

include(`permission_comments.m4')

-- In keeping with the notion of only allowing particular users to
-- see particular studies, users are only allowed to see who has
-- permission to those studies to which the user has (any) access.
CREATE OR REPLACE VIEW permissions AS
  WITH user_permissions AS (
    SELECT study
      FROM permission
      WHERE username = CURRENT_USER)
  SELECT permission.pid AS pid
       , permission.username AS username
       , permission.study    AS study
       , permission.access   AS access
    FROM permission
    WHERE
      EXISTS (SELECT 1 FROM user_permissions)
      AND (
        EXISTS (SELECT 1
                  FROM user_permissions
                  WHERE user_permissions.study = 'all')
        OR study = 'all'
        OR EXISTS (SELECT 1
                     FROM user_permissions
                     WHERE permission.study = user_permissions.study));


COMMENT ON VIEW permissions IS
  'Contains at most one row per user per study, each row defining the '
  'PLHDB permission level the study grants to the user.  '
  'Users are allowed to see only permissions to those studies to which '
  'the user has access.  '
  'HINT: The contents of the underlying PERMISSION table is available '
  'in an unfiltered form to PLHDB manager accounts.  '
  'HINT: See also the ACCOUNTS and ACCESS_GROUPS views.';

comment_permission_columns(`permissions')
