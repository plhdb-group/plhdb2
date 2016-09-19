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

-- Roles used as groups in PLHDB.
create or replace view access_groups as
  select pg_roles.rolname as groupname
       , pg_shdescription.description as description
    from  pg_roles
           left outer join pg_shdescription
                on (pg_shdescription.objoid = pg_roles.oid)
    where not pg_roles.rolcanlogin;

COMMENT ON VIEW access_groups IS
'One row per PostgreSQL role which cannot login.  These roles are used
to grant PostgreSQL level permissions.';

COMMENT ON COLUMN access_groups.groupname IS
'The name of the group.';

COMMENT ON COLUMN access_groups.description IS
'A description of the purpose of the group.';
