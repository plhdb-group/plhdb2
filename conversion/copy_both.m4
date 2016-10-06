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
dnl
dnl Remarks:
dnl   M4 helper macro for demo database copy process.

dnl plpgsql fragment dumping a single biography row and it's related
dnl femalefertiltiyinterval rows as SQL.
dnl
dnl Syntax: copy_both(studyid, animid, momid)
dnl
dnl  studyid  The BIOGRAPHY.StudyId of individual to copy
dnl  animid   The BIOGRAPHY.AnimId of individual to copy
dnl  momid    The BIOGRAPHY.AnimId of the individual's mother
dnl           This is only tested to see if it's the empty string.
dnl
dnl Remarks:
dnl   Uses studyid and animid instead of anim_oid (aka, bid) because
dnl we want to copy individuals based on the data each study uses to
dnl identify them.
dnl
changequote({,})
define({copy_both},{
    -- "Dump" data
-- Biography
        SELECT FORMAT(
            'INSERT INTO biography (bid'
                                 ', studyid'
                                 ', animid'
                                 ', animname'
                                 ', momonly'
                                 ', birthdate'
                                 ', bdmin'
                                 ', bdmax'
                                 ', bddist'
                                 ', birthgroup'
                                 ', bgqual'
                                 ', firstborn'
                                 ', mombid'
                                 ', sex'
                                 ', entrydate'
                                 ', entrytype'
                                 ', departdate'
                                 ', departtype'
                                 ', departdateerror) '
            'VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s'
                  ', %s, %s'
                  ', CASE WHEN EXISTS('
                              'SELECT 1 '
                                'FROM biography '
                                'WHERE biography.bid = %s) '
                           'THEN %s::INT ELSE NULL END'
                  ', %s, %s, %s, %s, %s, %s);'
          , b.bid
          , quote_literal(b.studyid)
          , quote_literal(b.animid)
          , CASE WHEN b.animname IS NULL
                   THEN 'NULL'
                   ELSE quote_literal(b.animname) END
          , quote_literal(b.momonly::TEXT)
          , CASE WHEN b.birthdate IS NULL
                   THEN NULL
                   ELSE quote_literal(b.birthdate::TEXT) END
          , CASE WHEN b.bdmin IS NULL
                   THEN 'NULL'
                   ELSE quote_literal(b.bdmin::TEXT) END
          , CASE WHEN b.bdmax IS NULL
                   THEN 'NULL'
                   ELSE quote_literal(b.bdmax::TEXT) END
          , quote_literal(b.bddist)
          , CASE WHEN b.birthgroup IS NULL
                   THEN 'NULL'
                   ELSE quote_literal(b.birthgroup) END
          , CASE WHEN b.bgqual IS NULL
                   THEN 'NULL'
                   ELSE quote_literal(b.bgqual) END
          , CASE WHEN b.firstborn IS NULL
                   THEN 'NULL'
                   ELSE quote_literal(b.firstborn) END
          -- Repeat mombid, since the format calls for the value twice
          , CASE WHEN b.mombid IS NULL
                      OR '$3' = ''
                   THEN 'NULL'
                   ELSE b.mombid::TEXT END
          , CASE WHEN b.mombid IS NULL
                      OR '$3' = ''
                   THEN 'NULL'
                   ELSE b.mombid::TEXT END

          , quote_literal(b.sex)
          , CASE WHEN b.entrydate IS NULL
                   THEN 'NULL'
                   ELSE quote_literal(b.entrydate::TEXT) END
          , CASE WHEN b.entrytype IS NULL
                   THEN 'NULL'
                   ELSE quote_literal(b.entrytype) END
          , CASE WHEN b.departdate IS NULL
                   THEN 'NULL'
                   ELSE quote_literal(b.departdate::TEXT) END
          , CASE WHEN b.departtype IS NULL
                   THEN NULL
                   ELSE quote_literal(b.departtype) END
          , b.departdateerror)
          FROM biography AS b
          WHERE b.studyid = '$1'
                AND b.animid = '$2';

-- Femalefertilityinterval
        SELECT FORMAT(
            'INSERT INTO fertility '
            '  (fid, bid, startdate, starttype, stopdate, stoptype) '
            'VALUES (%s, %s, %s, %s, %s, %s);'
          , ffi.fid
          , ffi.bid
          , quote_literal(ffi.startdate)
          , quote_literal(ffi.starttype)
          , quote_literal(ffi.stopdate)
          , quote_literal(ffi.stoptype))
          FROM fertility AS ffi
               JOIN biography AS b ON (b.bid = ffi.bid)
          WHERE b.studyid = '$1'
                AND b.animid = '$2';
          
})dnl
changequote(`,')dnl
