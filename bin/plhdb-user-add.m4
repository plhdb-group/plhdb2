#!/bin/sh
# Copyright (C) 2014 The Meme Factory, Inc.  http://www.meme.com/
# Copyright (C) 2005, 2008, 2011 Karl O. Pinc  <kop@meme.com>
#
#    This file is part of PLHDB.
#
#    PLHDB is free software; you can redistribute it and/or modify
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
#    along with PLHDB.  If not, see <http://www.gnu.org/licenses/>.
include(`editwarning.m4')
editwarning()
#
# Add a user to the database
#
# Syntax: plhdb-user-add adminuser username group userdescr
#         plhdb-user-add -a adminuser username userdescr
#
# -a        Make the account an admin account
# adminuser The user to use to make the user
# username  The username to add.
# group     The group in which to put the user.
# userdescr Description of the user, name and email.
#
# Karl O. Pinc <kop@meme.com>
#
# Bugs: Does not check to see if the user already exists.
#

usage () {
echo 'Syntax: plhdb-user-add adminuser username group userdescr'
echo '        plhdb-user-add -a adminuser username userdescr'
echo ''
echo '  -a        Make the account an admin account'
echo '  adminuser The user to use to make the user'
echo '  username  The username to add'
echo '  group     The group in which to put the user'
echo '  userdescr Description of the user, name and email'
}

# Parse command line
export ADMIN=''
export A_ADMINUSER=$1
if [ "$A_ADMINUSER" = '-a' ] ; then
  ADMIN='-a'
  shift
  A_ADMINUSER=$1
fi
export A_USER=$2
export A_GROUP=$3
export A_DESCR=$4

if [ -z "$ADMIN" ] ; then
  if [ "$A_GROUP" != "plhdb_users" \
       -a "$A_GROUP" != "plhdb_managers" ] ; then
    echo "'$A_GROUP' not plhdb_users or plhdb_managers" >&2
    usage >&2
    exit 1;
  fi
else
  if [ -z "$A_DESCR" ] ; then
    $A_DESCR="$A_GROUP"
    unset A_GROUP
  else
    echo "Too many arguments" >&2
    usage >&2
    exit 1;
  fi
fi

# Double any single quotes
A_DESCR="${A_DESCR//\'/''}"

export A_PASSWD=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 10)

if [ -z "$ADMIN" ] ; then
  psql -U $A_ADMINUSER -d plhdb <<EOF
begin;
create user $A_USER password '$A_PASSWD';
alter group $A_GROUP add user $A_USER;
comment on role $A_USER is '$A_DESCR';
create schema $A_USER authorization $A_USER;
comment on schema $A_USER is 'Area for the exclusive use of $A_DESCR';
commit;
\c plhdb_test
begin;
create schema $A_USER authorization $A_USER;
comment on schema $A_USER is 'Area for the exclusive use of $A_DESCR';
commit;
\c plhdb_copy
begin;
create schema $A_USER authorization $A_USER;
comment on schema $A_USER is 'Area for the exclusive use of $A_DESCR';
commit;
\q
EOF
else
  psql -U $A_ADMINUSER -d plhdb <<EOF
create role $A_USER superuser login noreplication password '$A_PASSWD';
comment on role $A_USER is 'Administrative account for $A_DESCR';
\q
EOF
fi

echo "The password for $A_USER is: $A_PASSWD"
echo "Please have them change it!"
