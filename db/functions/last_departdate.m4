dnl Copyright (C) 2012, 2016 The Meme Factory, Inc., http://www.meme.com/
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

CREATE OR REPLACE FUNCTION last_departdate(departdate DATE
                                         , departdateerror DOUBLE PRECISION)
  RETURNS DATE
  LANGUAGE plpgsql
  IMMUTABLE LEAKPROOF STRICT
  plh_function_set_search_path
  AS $$
  -- One line description
  --
  -- GPL_notice(`  --', `2016', `The Meme Factory, Inc.  http://www.meme.com/')
  --
  -- Syntax: last_departdate(departdate, departdateerror)
  --
  -- Arguments:
  --   departdate  A date
  --   departdateerror  Double precision float; number of years
  --
  -- Remarks:
  --   Compute the last departure date
  --
  -- Bugs:

  DECLARE

  BEGIN

  RETURN departdate
         + CEIL(departdateerror * 'plh_days_in_year'::DOUBLE PRECISION)::INT;
  END;
$$;
grant_func_priv(`last_departdate(DATE, DOUBLE PRECISION)')

COMMENT ON FUNCTION last_departdate(DATE, DOUBLE PRECISION) IS
'Given a departure date and a departure date error returns the latest
possible departure date.  Fractions of a day are _not_ truncated;
e.g. if the computed latest possible departure ends at 9AM that date
is returned.  Any part of a day at the end of the computed interval is
consiered to be an entire day for purposes of the computation.

This function is used whenever the system computes an individual''s
latest possible departure date.  It is also available for use in
queries.';
