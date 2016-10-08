dnl Copyright (C) 2016 The Meme Factory, Inc.  http://www.meme.com/
dnl
dnl    This file is part of PLHDB2.
dnl
dnl    PLDHB2 is free software; you can redistribute it and/or modify
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
dnl    along with Babase.  If not, see <http://www.gnu.org/licenses/>.
dnl
dnl Karl O. Pinc <kop@meme.com>
dnl

include(`copyright.m4')
include(`tablemacros.m4')
include(`grants.m4')
include(`constants.m4')

CREATE TABLE start_event (
  code CHAR(1) PRIMARY KEY
    empty_string_check(`Code')
    sensible_whitespace(`Code')
, description VARCHAR(64) NOT NULL
    empty_string_check(`Description')
    sensible_whitespace(`Description')
, initial BOOLEAN NOT NULL);

grant_priv(`start_event', `code')
grant_demo_user_priv(`start_event')


COMMENT ON TABLE start_event IS
'One row per kind of event which begins the interval of time during
which the lives of study individuals are tracked.  This table
establishes a controlled vocabulary for the events which mark the
start of observation.';

COMMENT ON COLUMN start_event.code IS
'A unique single character code for the start of observation type.
This code identifies the row within the database.';

COMMENT ON COLUMN start_event.description IS
'A unique description of the start of observation type.';

COMMENT ON COLUMN start_event.initial IS

'A boolean value.  When TRUE indicates that there may be no preceeding
events.  Birth is an example end event where Initial should be TRUE.

This flag may impose additional requirements; this is dependent upon
the table referencing the START_EVENT row.  For more information see
the documentation of each table which uses START_EVENT for vocabulary
control.

The value of this column may not be NULL.';


CREATE UNIQUE INDEX start_event_description ON start_event (description);
