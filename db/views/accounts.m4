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

include(`grants.m4')

-- Descriptions of accounts
-- (Roles that can login.)
create or replace view accounts as
  select pg_roles.rolname as username
       , pg_shdescription.description as description
    from  pg_roles
           left outer join pg_shdescription
                on (pg_shdescription.objoid = pg_roles.oid)
    where pg_roles.rolcanlogin;

grant_priv(`accounts')


COMMENT ON VIEW accounts IS
'One row per PostgreSQL role which can login.  The purpose of this
view is to provide a description of accounts.';

COMMENT ON COLUMN accounts.username IS
'The login name.';

COMMENT ON COLUMN accounts.description IS
'The comment supplied upon account creation which purportedly
describes the account.';

