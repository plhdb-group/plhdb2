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

CREATE TABLE site (
  siteid SERIAL PRIMARY KEY
, name VARCHAR(64) NOT NULL
       empty_string_check(`Name')
       sensible_whitespace(`Name')
, latitude NUMERIC(7,3)
, longitude NUMERIC(7,3)
, geodetic_datum VARCHAR(12) DEFAULT 'WGS84'
                 empty_string_check(`Geodetic_Datum')
                 sensible_whitespace(`Geodetic_Datum'));

grant_seq_priv(`site', `siteid')
grant_demo_user_priv(`site')


COMMENT ON TABLE site IS
'One row per site where a study was or is being conducted.  For now,
geographic coordinates are designated to the entire site, not
individually to observations (though that would seem desirable over
the long term). It would also seem desirable to record the geographic
area of the site as a polygon, rather than as a single point.';

COMMENT ON COLUMN site.siteid IS
'Unique row identifier.';

COMMENT ON COLUMN site.name IS
'The name of the site, which must be unique. This may be a short or a
long name, depending on what the study uses.';

COMMENT ON COLUMN site.latitude IS
'The decimal latitude coordinate of the site, using positive and
negative sign to indicate N and S, respectively.';

COMMENT ON COLUMN site.longitude IS
'The decimal longitude coordinate of the site, using positive and
negative sign to indicate E and W, respectively.';

COMMENT ON COLUMN site.geodetic_datum IS
'The geodetic system on which the geo-coordinates are based.  For
geo-coordinates measured between 1984 and 2010 this will typically be
WGS84, which is the default value.';


CREATE UNIQUE INDEX site_name ON site (name);
