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

dnl m4 includes
include(`copyright.m4')dnl
include(`constants.m4')dnl
include(`macros.m4')dnl


dnl plpgsql fragment for BLAH
dnl
dnl Syntax: BLAH(ARG)
dnl
dnl ARG   description
dnl
changequote({,})
define({BLAH},{
})dnl
changequote(`,')dnl

--  
-- probability_type
--
SELECT 'probability_type' AS table;

SELECT 'probability_type_update_func' AS function;
CREATE FUNCTION probability_type_update_func ()
  RETURNS trigger
  LANGUAGE plpgsql
  plh_function_set_search_path
  AS $$
  BEGIN
  -- Function for probability_type update triggers
  --
  -- GPL_notice(`  --', `2016', `The Meme Factory, Inc., http://www.meme.com/')

  -- Simpler than checking, when symmetrical becomes TRUE, for symmetry
  -- in BIOGRAPHY BirthDate, BDMin, and BDMax.
  cannot_change(`PROBABILITY_TYPES', `Symmetrical')

  RETURN NULL;
  END;
$$;


SELECT 'probability_type_update_trigger' AS trigger;
CREATE TRIGGER probability_type_update_trigger
  AFTER UPDATE
  ON probability_type FOR EACH ROW
  EXECUTE PROCEDURE probability_type_update_func();
