# Copyright (C) 2016 The Meme Factory, Inc.

# The directory holding the PG database cluster's home dir
# It's a good idea for this to be an absolute path.
#CLUSTER_PARENT=/var/lib
# Duke is "different"
CLUSTER_PARENT=/srv/apps

# The directory holding the PG database cluster
CLUSTER_DIR=pgsql

# The user:group that the PG daemon runs as
POSTGRES=postgres:postgres

# The chown program (Duke does something "different")
#CHOWN=chown
CHOWN=~/chownish

all:

cluster_parent: ${CLUSTER_PARENT}

cluster_dir: cluster_parent
	if [ \! -d ${CLUSTER_DIR} ] ; then \
	  mkdir ${CLUSTER_PARENT}/${CLUSTER_DIR} ; \
	  ${CHOWN} ${POSTGRES} ${CLUSTER_PARENT}/${CLUSTER_DIR} ; \
	fi

cluster: cluster_dir
	printf 'initdb --locale=C ${CLUSTER_PARENT}/${CLUSTER_DIR}' \
	  | sudo su - postgres

