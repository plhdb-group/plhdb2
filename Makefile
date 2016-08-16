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
#    along with Babase.  If not, see <http://www.gnu.org/licenses/>.
#
# Karl O. Pinc <kop@meme.com>

# The directory holding the PG database cluster's home dir
# It's a good idea for this to be an absolute path.
#CLUSTER_PARENT=/var/lib
# Duke is "different"
CLUSTER_PARENT=/srv/apps/root/var/lib/

# The directory holding the PG database cluster
CLUSTER_DIR=pgsql/data

# The user:group that the PG daemon runs as
POSTGRES=postgres:postgres

# The chown program (Duke does something "different")
#CHOWN=chown
CHOWN=~/chownish

all:

cluster_parent: ${CLUSTER_PARENT}

cluster_dir: cluster_parent
	if [ \! -d ${CLUSTER_DIR} ] ; then \
	  mkdir -p ${CLUSTER_PARENT}/${CLUSTER_DIR} ; \
	  ${CHOWN} -R ${POSTGRES} ${CLUSTER_PARENT}/${CLUSTER_DIR} ; \
	fi

cluster: cluster_dir
	printf 'initdb --locale=C ${CLUSTER_PARENT}/${CLUSTER_DIR}' \
	  | sudo su - postgres

