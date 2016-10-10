dnl Copyright (C) 2016 The Meme Factory, Inc., http://www.meme.com/
dnl
dnl    This file is part of PLHDB.
dnl
dnl    PLHDB is free software; you can redistribute it and/or modify
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
dnl    along with PLHDB.  If not, see <http://www.gnu.org/licenses/>.
dnl
dnl Karl O. Pinc <kop@meme.com>
dnl
dnl
dnl m4 includes
include(`copyright.m4')
include(`constants.m4')
include(`functionmacros.m4')
dnl

CREATE OR REPLACE FUNCTION is_superuser()
  RETURNS BOOLEAN
  LANGUAGE plpgsql
  STABLE
  LEAKPROOF
  plh_function_set_search_path
  AS $$
  -- Is the SESSION_USER a superuser?
  --
  -- GPL_notice(`  --', `2016', `The Meme Factory, Inc.  http://www.meme.com/')
  --
  -- Syntax: is_superuser()
  --
  -- Remarks:
  --   Returns TRUE if the SESSION_USER is a superuser.
  --
  -- Bugs:

  DECLARE

  BEGIN

  RETURN (SELECT pg_roles.rolsuper
            FROM pg_roles
            WHERE pg_roles.rolname = SESSION_USER);
  END;
$$;
grant_func_priv(`is_superuser()')

COMMENT ON FUNCTION is_superuser() IS
'Is the SESSION_USER a superuser?  This function is used where we
would really want to use instead a row_security_active() function that
tests SESSION_USER (not CURRENT_USER as the PG 9.5
row_security_active() does).';
