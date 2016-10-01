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

CREATE TABLE probability_type (
  code CHAR(1) PRIMARY KEY
  empty_string_check(`Code')
  sensible_whitespace(`Code')
, description TEXT NOT NULL
  empty_string_check(`Description')
  sensible_whitespace(`Description')
, symmetrical BOOLEAN NOT NULL);

grant_priv(`probability_type', `code')
grant_demo_user_priv(`probability_type')


COMMENT ON TABLE probability_type IS
'One row per kind of probability distribution.  This table establishes
a controlled vocabularly for probability distributions.';

COMMENT ON COLUMN probability_type.code IS
'A unique single character code for the probability type.  This code
identifies the row within the database.';

COMMENT ON COLUMN probability_type.description IS
'A unique description of the kind of probability distribution.';

COMMENT ON COLUMN probability_type.symmetrical IS 
'TRUE when the related data-endpoints must be "symmetrical" about the
distribution''s most likely value, in the same way that the endpoints of
a normal distribution are equidistant from the mean, median, and mode.
FALSE when the related data need not be.  In effect, denotes whether
the probability distribution is a normal distribution.  When a
PROBABILITY_TYPE row is related to data consisting of a value, a
minimum, and a maximum (as it is with BIOGRAPHY''s BirthDate, BDMin, and
BDMax columns) symmetry requires that the value be midway between the
minimum and the maximum.  Because some intervals are measured in
discrete time units (days) the midpoint is defined to be either one of
the 2 midpoint dates when there are an even number of days in the
min-to-max interval.';


CREATE UNIQUE INDEX probability_type_description
  ON probability_type (description);

