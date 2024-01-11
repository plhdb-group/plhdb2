# Copyright (C) 2016, 2024 The Meme Factory, Inc.  http://www.karlpinc.com/
#
#    This file is part of PLHDB2.
#
#    PLHDB2 is free software; you can redistribute it and/or modify
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
#    along with PLHDB2.  If not, see <http://www.gnu.org/licenses/>.
#
# Karl O. Pinc <kop@meme.com>
#
# Bugs:
#   Can't test if the cluster exists before making the db.

include ../help.mk
## ############################################################################
##                              Cluster Installation
##
## Caution: Cluster installation steps must be done as the root user.
##
## Variables:

##     PG_MAJOR_VERSION  The major version number of the PostgreSQL in use.
##                       Defaults to major version of the psql in use.
PG_MAJOR_VERSION := $(shell psql --version | cut -d ' ' -f 3 | cut -d . -f 1)

##     INIDB             Path to initdb to use.  Defaults to:
##                       /usr/share/postgresql/$(PG_MAJOR_VERSION)/bin/initdb
# Why use initdb?  Because pg_createcluster is a Debian thing.
INITDB := /usr/lib/postgresql/$(PG_MAJOR_VERSION)/bin/initdb

##     CLUSTER_PARENT    The directory holding the PG database cluster's
##                       home dir.  It's a good idea for this to be an
##                       absolute path.  The default is:
##                       /var/lib/postgresql/$(PG_MAJOR_VERSION)
##                       (This is the debian default, RHEL uses
##                       /var/lib/pgsql/...)
CLUSTER_PARENT := /var/lib/postgresql/$(PG_MAJOR_VERSION)

##     TARGET_CLUSTER    The name of the cluster.  Defaults to: plhdb
TARGET_CLUSTER := plhdb

CLUSTER_PATH := $(CLUSTER_PARENT)/$(TARGET_CLUSTER)

##     BACKUP_DIR        The directory where database dumps are kept
BACKUP_DIR=/srv/pg_backups

# The user:group that the PG daemon runs as
POSTGRES=postgres:postgres

# The chown program (Duke does something "different")
CHOWN=chown

##
## The following targets may be used:
##

all:

cluster_parent: $(dir $(CLUSTER_PARENT))
# This deliberately does nothing, so that if the pg server is not installed
# or varaiables are wrong then nothing happens.

##   cluster       Initialize the TARGET_CLUSTER
cluster: $(CLUSTER_PATH) debianize_cluster

$(CLUSTER_PATH): cluster_parent
	printf '${INITDB} --data-checksums --locale=C %s %s\n' \
	       '--no-instructions' \
               '${CLUSTER_PARENT}/${TARGET_CLUSTER}' \
	  | su - postgres

.PHONY: debianize_cluster
debianize_cluster:
	[ -x /usr/bin/pg_createcluster ] \
	  && pg_createcluster $(PG_MAJOR_VERSION) $(TARGET_CLUSTER)

##   backup_dir    Create the directory structure where backups are stored
backup_dir:
	if [ \! -d ${BACKUP_DIR} ] ; then \
	  mkdir -p ${BACKUP_DIR} ; \
	  chmod g=,o= ${BACKUP_DIR} ; \
	  ${CHOWN} -R ${POSTGRES} ${BACKUP_DIR} ; \
	fi
##
## ############################################################################
##                              Database Installation
##
## Variables:
##
##   PLHDB_DB           Name of the database in which to work.  Defaults
##                      to: plhdb_copy
##   ADMINUSER          Name of the administrative user to use to connect
##                      to the database.  Defaults to: plhdb_admin
##                      Because this is the user that will own all db objects
##                      it is best to _not_ change the default.

##
## The following targets may be used:
##

##   roles         Make the initial roles PLHDB requires
.PHONY: roles
roles: makeroles
	sh makeroles

##   databases     Make the PLHDB databases
.PHONY: databases
databases: makedatabases
	sh makedatabases

##   install       Install tables and other objects into the PLHDB_DB database
.PHONY: install
install:
	make -C tables install
	make -C policy install
	make -C functions install_other
	make -C views install
	make -C triggers install

##   reinstall     Re-install the tables and other db objects in PLHDB_DB
.PHONY: reinstall
reinstall:
	make -C tables reinstall
	make -C policy install
	make -C functions reinstall_other
	make -C views reinstall
	make -C triggers reinstall

##   reinstallnolock
##                 Re-install, outside of a transaction, the tables and
##                 other db objects, in the PLHDB_DB database
.PHONY: reinstallnolock
reinstallnolock:
	make -C tables reinstall
	make -C policy reinstallnolock
	make -C functions reinstall_othernolock
	make -C views reinstallnolock
	make -C triggers reinstallnolock

##   destroy       Drop all tables and other database objects in the PLHDB_DB
##                 database
.PHONY: destroy
destroy:
	make -C triggers destroy
	make -C views destroy
	make -C policy destroy
	make -C tables destroy
	make -C functions destroy_other

##   clean         Cleanup generated files
.PHONY: clean
clean:
	make -C tables clean
	make -C policy clean
	make -C include clean
	make -C triggers clean
	make -C tables clean
	make -C views clean
	make -C functions clean
