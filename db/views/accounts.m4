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

-- Descriptions of accounts
-- (Roles that can login and have schemas with their name which have
-- a comment.  Note that the schema must be in the connected database.)
create or replace view accounts as
  select pg_roles.rolname as username
       , pg_shdescription.description as description
    from  pg_roles
           left outer join pg_shdescription
                on (pg_shdescription.objoid = pg_roles.oid)
    where pg_roles.rolcanlogin;
