dnl Copyright (C) 2016 The Meme Factory, Inc.  http://www.meme.com/
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
changequote([{[,]}])dnl m4 foolery so includes include only once.
dnl                     Once the macro is in the text, change the quotes back
ifdef([{[_macros.m4]}], [{[changequote(`,')]}], [{[dnl
changequote(`,')dnl
dnl
dnl Standard test for having already included the file.
define(`_macros.m4')dnl
dnl
dnl
dnl Discard any output.  Copyright and edit warning is all that's output.
divert(-1)

dnl m4 includes
include(`constants.m4')
include(`globalmacros.m4')


dnl String used in various error HINTs.
define(`plh_character_case_hint', 
       `The database is case sensitive.  Are upper and lower case characters used appropriately within the data supplied?')

dnl Plpgsql fragment for preventing a column from changing.
dnl
dnl Syntax: cannot_change(table, column)
dnl Variables required:
dnl Restrictions: Must be used in a FOR EACH ROW update trigger function.
changequote({,})
define({cannot_change}, {
  IF NEW.$2 <> OLD.$2 THEN
    -- $2 has changed
    RAISE EXCEPTION integrity_constraint_violation USING
          MESSAGE = 'Error on UPDATE of $1'
        , DETAIL =  'Value ($2) = (' || OLD.$2
                    || '): $1.$2 cannot be changed';
    RETURN NULL;
  END IF;
})
changequote(`,')


dnl Turn output back on
divert`'dnl
]}])dnl End of ifdef over the whole file.
