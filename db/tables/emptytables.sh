# Copyright (C) 2016 The Meme Factory, Inc.  http://www.meme.com/
#
#    This file is part of PLHDB2.
#
#    PLDHB2 is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with PLHDB2.  If not, see <http://www.gnu.org/licenses/>.
#
# Remarks:
# Write sql code that empties all tables.  Table names supplied,
# separated by whitespace, on stdin in reverse order from that in
# which they should be emptied.
#
# Uses DELETE rather than truncate just to see what triggers, etc. do.
#
# Karl O. Pinc <kop@meme.com>
#

xargs -n 1 printf '%s\n' \
  | tac \
  | xargs printf 'DELETE FROM %s;\n'

cat - <<\EOF
  DO $$
    DECLARE
      this_name VARCHAR;
    BEGIN
      FOR this_name IN
        SELECT sequence_name
          FROM information_schema.sequences
          WHERE sequence_schema = 'plhdb'
      LOOP
        EXECUTE FORMAT('SELECT SETVAL(''%I'', 1, false);', this_name);
      END LOOP;
    END;
    $$;
EOF
