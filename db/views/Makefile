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

# The order views are listed here is the order in which the views
# are created and the reverse order in which they are destroyed.
INFILES := permissions.m4
SQLFILES := $(INFILES:.m4=.sql)
TARGETS := $(SQLFILES) makeviews.sql destroyviews.sql

INCLUDE := ../include
COPYRIGHT := $(INCLUDE)/copyright.sql
COPYRIGHTSRC := $(INCLUDE)/copyright.m4

DEPS := Makefile ../defaults.mk

include ../defaults.mk

$(COPYRIGHT): $(COPYRIGHTSRC) $(DEPS)
	make -C $(INCLUDE) $$(basename $(COPYRIGHT))

makeviews.sql: $(SQLFILES) $(COPYRIGHT) $(DEPS)
	cat $(COPYRIGHT) $(SQLFILES) > makeviews.sql

destroyviews.sql: destroyviews.sh $(COPYRIGHT) $(DEPS)
	cat $(COPYRIGHT) > destroyviews.sql
	printf "%s" "$(INFILES:.m4=)" \
	  | sh destroyviews.sh >> destroyviews.sql

# Make any *.sql file from it's *.m4 file.
%.sql: %.m4 $(COPYRIGHTSRC) ../include/constants.m4 $(DEPS)
	m4 -I $(INCLUDE) -I include $< > $@

.PHONY: install
install: makeviews.sql $(DEPS)
	( echo set client_min_messages TO WARNING\; ; \
	  echo 'BEGIN;' ; \
	  cat makeviews.sql ; \
          echo 'COMMIT;' ) \
	| psql $(PSQL_ARGS)

# Install outside of a transaction
.PHONY: installnolock
installnolock: makeviews.sql $(DEPS)
	( echo set client_min_messages TO WARNING\; ; \
	  cat makeviews.sql ) \
	| psql $(PSQL_ARGS)

.PHONY: reinstall
reinstall: destroyviews.sql makeviews.sql
	( echo set client_min_messages TO WARNING\; ; \
	  echo 'BEGIN;' ; \
	  cat destroyviews.sql ; \
	  cat makeviews.sql ; \
	  echo 'COMMIT;' ; \
	  echo 'VACUUM;' ; ) \
	| psql $(PSQL_ARGS)

# Reinstall outside of a transaction
.PHONY: reinstallnolock
reinstallnolock: destroyviews.sql makeviews.sql
	( echo set client_min_messages TO WARNING\; ; \
	  cat destroyviews.sql ; \
	  cat makeviews.sql ; \
	  echo 'VACUUM;' ; ) \
	| psql $(PSQL_ARGS)

.PHONY: destroy
destroy: destroyviews.sql
	( echo set client_min_messages TO WARNING\; ; \
	  cat destroyviews.sql ; \
	  echo 'VACUUM;' ; ) \
	| psql $(PSQL_ARGS)

.PHONY: clean
clean:
	rm -rf $(TARGETS)
