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

dnl Strings used in error messages
dnl
define(`cannot_change_msg', `This row has special meaning to PLHDB and may not 
be changed by ordinary users')dnl
define(`cannot_delete_msg', `This row has special meaning to PLHDB and may not be deleted by ordinary users')dnl
define(`restricted_hint_msg', `The change can only be made by a user who is allowed to create triggers on the table')dnl

dnl plpgsql fragment for checking that a support table value cannot
dnl be changed by regular users
dnl
dnl Syntax: restrict_change(table, column, value)
dnl
dnl table   The table
dnl column  The column
dnl value   The value that can't be changed by ordinary users.
dnl
changequote({,})
define({restrict_change},{
    IF (NEW.$2 = '$3' OR OLD.$2 = '$3')
       AND (NEW.$2 <> OLD.$2
            OR NEW.name <> OLD.name)
       AND NOT(has_table_privilege('$1', 'trigger')) THEN
      RAISE EXCEPTION insufficient_privilege USING
            MESSAGE = 'Error on ' || TG_OP || ' of $1'
          , DETAIL = 'Key($2) = ($3): cannot_change_msg'
          , HINT = 'restricted_hint_msg';
    END IF;
})dnl
changequote(`,')dnl

dnl plpgsql fragment for checking that a value cannot be deleted by regular users
dnl
dnl Syntax: restrict_delete(table, column, value)
dnl
dnl table   The table
dnl column  The column
dnl value   The value that can't be deleted by ordinary users.
dnl
changequote({,})
define({restrict_delete},{
  IF OLD.$2 = '$3'
     AND NOT(has_table_privilege('$1', 'trigger')) THEN
    RAISE EXCEPTION insufficient_privilege USING
          MESSAGE = 'Error on ' || TG_OP || ' of $1'
        , DETAIL = 'Key($2) = ($3): cannot_delete_msg'
        , HINT = 'restricted_hint_msg';
  END IF;
})dnl
changequote(`,')dnl


dnl Turn output back on
divert`'dnl
]}])dnl End of ifdef over the whole file.
