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
dnl SQL shared by the regular conversion program and the demo db conversion.
dnl Executed by both of these programs.
dnl
dnl  Macros expected to be replaced:
dnl   site_key  Key in from db of SITE
dnl   taxon_key Key in from db of TAXON
dnl   study_key Key in from db of STUDY, or at least what's used as key in
dnl             the target db.
dnl
dnl Karl O. Pinc <kop@meme.com>

-- Site
        SELECT FORMAT(
            'INSERT INTO site (siteid, name, latitude, longitude'
            '                , geodetic_datum) '
            'VALUES (%s, %s, %s, %s, %s);'
          , site_key, quote_literal(name)
          , CASE WHEN latitude IS NULL
                   THEN 'NULL'
                   ELSE latitude::TEXT END
          , CASE WHEN longitude IS NULL
                   THEN 'NULL'
                   ELSE longitude::TEXT END
          , CASE WHEN geodetic_datum IS NULL
                   THEN 'NULL'
                   ELSE quote_literal(geodetic_datum) END)
          FROM plhdb.site;

        -- Update sequence.
        SELECT 'DO $$ BEGIN
                  PERFORM SETVAL(''site_siteid_seq''
                              , MAX(site.siteid))
                    FROM site; END;$$;';

-- Taxon
        SELECT FORMAT(
            'INSERT INTO taxon (taxonid, scientific_name, common_name) '
            'VALUES (%s, %s, %s);'
          , taxon_key, quote_literal(scientific_name)
          , CASE WHEN common_name IS NULL
                   THEN 'NULL'
                   ELSE quote_literal(common_name) END)
          FROM plhdb.taxon;

        -- Update sequence.
        SELECT 'DO $$ BEGIN
                  PERFORM SETVAL(''taxon_taxonid_seq''
                              , MAX(taxon.taxonid))
                    FROM taxon; END;$$;';


-- Study
        SELECT FORMAT(
            'INSERT INTO study (sid, name, owners, taxonid, siteid) '
            'VALUES (%s, %s, %s, %s, %s);'
          , quote_literal(study_key)
          , CASE WHEN name IS NULL
                   THEN 'NULL'
                   ELSE quote_literal(name) END
          , quote_literal(owners), taxon_key, site_key)
          FROM plhdb.study;


-- Hardcode the probablity_types, which come from the old cvterm table.
SELECT $$
INSERT INTO probability_type (code, description, symmetrical)
  VALUES ('N'
        , 'Normal distribution.  Construct the birth date probability '
          'distribution so that BDMin and BDMax represent + 2 '
          'standard deviations of Birthdate.  Birthdate must be '
          'at the midpoint of BDMin and BDMax, or one of the 2 midpoint '
          'dates when there are an even number of days in the BDMin to '
          'BDMax interval'
        , TRUE)
       , ('U'
        , 'Uniform distribution.  The probability distribution is '
          'truncated at BDMin and BDMax with equal Birthdate '
          'probability within this range.'
        , FALSE);
$$;

-- Hardcode the start events, which come from the old cvterm table.
SELECT $$
INSERT INTO start_event (code, description, initial)
  VALUES ('B', 'birth', TRUE)
       , ('I', 'immigration into population', FALSE)
       , ('C', 'confirmed identification', FALSE)
       , ('O', 'beginning of observation', FALSE);
$$;

-- Hardcode the end events, which come from the old cvterm table.
SELECT $$
INSERT INTO end_event (code, description, final)
  VALUES ('O', 'end of observation', FALSE)
       , ('D', 'death', TRUE)
       , ('E', 'emigration from population', FALSE)
       , ('P', 'permanent disappearance', TRUE);
$$;
