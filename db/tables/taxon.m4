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

CREATE TABLE taxon (
  taxonid SERIAL PRIMARY KEY
, scientific_name VARCHAR(128) NOT NULL
  empty_string_check(`Scientific_Name')
  no_whitespace_on_ends(`Scientific_Name')
, common_name VARCHAR(64)
  empty_string_check(`Common_Name')
  no_whitespace_on_ends(`Common_Name'));

grant_seq_priv(`taxon', `taxonid')


COMMENT ON TABLE taxon IS
'One row per taxon studied.  For now, this is a very simplified taxon
model with no identification of the taxonomy being used, and there can
be only two names, one scientific and one common.';

COMMENT ON COLUMN taxon.taxonid IS
'Unique row identifier.';

COMMENT ON COLUMN taxon.scientific_name IS
'The scientific name for the taxon, using for example the NCBI or the
ITIS taxonomies.';

COMMENT ON COLUMN taxon.common_name IS
'The common name for the taxon. This need not be the most common or
generally accepted name, but the common name used within the study.';


CREATE UNIQUE INDEX taxon_common_name ON taxon (common_name);
CREATE UNIQUE INDEX taxon_scientific_name ON taxon (scientific_name);
