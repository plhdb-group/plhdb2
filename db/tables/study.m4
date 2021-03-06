dnl Copyright (C) 2016 The Meme Factory, Inc.  http://www.meme.com/
dnl
dnl    This file is part of PLHDB2.
dnl
dnl    PLHDB2 is free software; you can redistribute it and/or modify
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
dnl    along with PLHDB2.  If not, see <http://www.gnu.org/licenses/>.
dnl
dnl Karl O. Pinc <kop@meme.com>
dnl

include(`copyright.m4')
include(`tablemacros.m4')
include(`grants.m4')
include(`constants.m4')
include(`study_comments.m4')

CREATE TABLE study (
  sid plh_studyid_type PRIMARY KEY
    empty_string_check(`SId')
    sensible_whitespace(`SId')
    CONSTRAINT "SId may not be 'plh_allstudies'"
               CHECK(sid <> 'plh_allstudies')
, name VARCHAR(32)
    empty_string_check(`Name')
    sensible_whitespace(`Name')
, owners VARCHAR(128)
    empty_string_check(`Owners')
    sensible_whitespace(`Owners')
, taxonid INT NOT NULL
    CONSTRAINT "TaxonId on TAXON" REFERENCES taxon
, siteid INT NOT NULL
    CONSTRAINT "SiteId on SITE" REFERENCES site);

grant_priv(`study', `sid')
grant_demo_user_priv(`study')


COMMENT ON TABLE study IS
'One row per study.  The study within which the individuals have been
observed.  At present, the same taxon and the same site applies to all
individuals within the study.';

comment_study_columns(`study')

CREATE UNIQUE INDEX study_name ON study (name);
