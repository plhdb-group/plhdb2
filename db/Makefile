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
#
# Bugs:
#   Can't test if the cluster exists before making the db.
#   Can't test if plhdb_postgres_backup is installed.
#   Grody defaults due to Duke's non-standard setup.
#   Shouldn't install plhdb_postgres_backup in this file.

# initdb to run.
INITDB=/usr/pgsql-9.5/bin/initdb

# Where binaries go
BIN=/srv/apps/root/usr/local/bin

# The directory holding the PG database cluster's home dir
# It's a good idea for this to be an absolute path.
#CLUSTER_PARENT=/var/lib
# Duke is "different"
CLUSTER_PARENT=/srv/apps/root/var/lib

# The directory holding the PG database cluster
#CLUSTER_DIR=pgsql/data
CLUSTER_DIR=pgsql/9.5/data

# The directory where database dumps are kept
BACKUP_DIR=pgsql/backups

# The user:group that the PG daemon runs as
POSTGRES=postgres:postgres

# The chown program (Duke does something "different")
#CHOWN=chown
CHOWN=~/chownish

all:

cluster_parent: ${CLUSTER_PARENT}

.PHONY: cluster_dir
cluster_dir: cluster_parent
	if [ \! -d ${CLUSTER_DIR} ] ; then \
	  mkdir -p ${CLUSTER_PARENT}/${CLUSTER_DIR} ; \
	  chmod g=,o= ${CLUSTER_PARENT}/${CLUSTER_DIR} ; \
	  ${CHOWN} -R ${POSTGRES} ${CLUSTER_PARENT}/${CLUSTER_DIR} ; \
	fi

.PHONY: cluster
cluster: cluster_dir
	printf '${INITDB} --locale=C ${CLUSTER_PARENT}/${CLUSTER_DIR}' \
	  | sudo su - postgres


.PHONY: databases
databases: makedatabases
	sh makedatabases

.PHONY: backup_dir
backup_dir: cluster_parent
	if [ \! -d ${BACKUP_DIR} ] ; then \
	  mkdir -p ${CLUSTER_PARENT}/${BACKUP_DIR} ; \
	  chmod g=,o= ${CLUSTER_PARENT}/${BACKUP_DIR} ; \
	  ${CHOWN} -R ${POSTGRES} ${CLUSTER_PARENT}/${BACKUP_DIR} ; \
	fi

.PHONY: bin_dir
bin_dir:
	mkdir -p ${BIN}

.PHONY: install_plhdb_postgres_backup
install_plhdb_postgres_backup: backup_dir bin_dir
	cp ../bin/plhdb_postgres_backup ${BIN}
	chmod a+x ${BIN}/plhdb_postgres_backup

.PHONY: install
install:
	make -C tables install
	make -C triggers install
	make -C views install

.PHONY: reinstall
reinstall:
	make -C tables reinstall
	make -C triggers reinstall
	make -C views reinstall

.PHONY: reinstallnolock
reinstallnolock:
	make -C tables reinstall
	make -C triggers reinstallnolock
	make -C views reinstallnolock

.PHONY: destroy
destroy:
	make -C triggers destroy
	make -C tables destroy
	make -C views destroy

.PHONY: clean
clean:
	make -C tables clean
	make -C include clean
	make -C tables clean
	make -C views clean
