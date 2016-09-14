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

CREATE TABLE study (
  study_oid SERIAL PRIMARY KEY
, name VARCHAR(32) NOT NULL
  empty_string_check(`name')
  CONSTRAINT "NAME may not be 'plh_allstudies'"
             CHECK(name <> 'plh_allstudies')
, id VARCHAR(12) NOT NULL
  empty_string_check(`id')
, owners VARCHAR(128)
  empty_string_check(`owners')
, taxon_oid INT NOT NULL
  CONSTRAINT "Taxon_OId on TAXON" REFERENCES taxon
, site_oid INT NOT NULL
  CONSTRAINT "Site_OId on SITE" REFERENCES site);

grant_seq_priv(`study', `study_oid')


COMMENT ON TABLE study IS
  'One row per study.  '
  'HINT:  The STUDYINFO view references this table; '
  'use of STUDYINFO may be preferred.  '
  'The study within which the individuals have been observed.  At present, '
  'the same taxon and the same site applies to all individuals within '
  'the study.';

COMMENT ON COLUMN study.study_oid IS
  'Unique row identifier.';

COMMENT ON COLUMN study.name IS
  'The name of the study. This may be a descriptive or encoded, '
  'must be unique if not NULL, and may not be ''plh_allstudies''.';

COMMENT ON COLUMN study.id IS
  'A short identifier commonly used to refer to the study.  This need '
  'not be a number, but must be unique, and is required.';

COMMENT ON COLUMN study.owners IS
  'The owners of the observational data that this study gave rise to.  '
  'This may be a single person, an organization, or a (comma-delimited) '
  'list of such.';

COMMENT ON COLUMN study.taxon_oid IS
  'The row identifier of the taxon for the individuals that were or are '
  'being observed in this study.';

COMMENT ON COLUMN study.site_oid IS
  'The row identifer of the site where this study was or is being '
  'conducted, and hence where the individuals have been observed.';


CREATE UNIQUE INDEX study_id ON study (id);
CREATE UNIQUE INDEX study_name ON study (name);
