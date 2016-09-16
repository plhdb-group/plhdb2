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

INFILES := $(wildcard *.m4)
SQLFILES := $(INFILES:.m4=.sql)
TARGETS := $(SQLFILES) maketriggers.sql

INCLUDE := ../include
COPYRIGHT := $(INCLUDE)/copyright.sql
COPYRIGHTSRC := $(INCLUDE)/copyright.m4

DEPS := Makefile ../defaults.mk

include ../defaults.mk

$(COPYRIGHT): $(COPYRIGHTSRC) $(DEPS)
	make -C $(INCLUDE) $$(basename $(COPYRIGHT))

maketriggers.sql: $(SQLFILES) $(COPYRIGHT) $(DEPS)
	cat $(COPYRIGHT) $(SQLFILES) > maketriggers.sql

# Make any *.sql file from it's *.m4 file.
%.sql: %.m4 $(COPYRIGHTSRC) $(INCLUDE)/constants.m4 include/macros.m4 $(DEPS)
	m4 -I $(INCLUDE) -I include $< > $@

.PHONY: install
install: maketriggers.sql $(DEPS)
	( echo set client_min_messages TO WARNING\; ; \
	  echo 'BEGIN;' ; \
	  cat maketriggers.sql ; \
          echo 'COMMIT;' ) \
	| psql $(PSQL_ARGS)

# Install outside of a transaction
.PHONY: installnolock
installnolock: maketriggers.sql $(DEPS)
	( echo set client_min_messages TO WARNING\; ; \
	  cat maketriggers.sql ) \
	| psql $(PSQL_ARGS)

.PHONY: reinstall
reinstall: destroytriggers maketriggers.sql
	( echo set client_min_messages TO WARNING\; ; \
	  echo 'BEGIN;' ; \
	  cat destroytriggers ; \
	  cat maketriggers.sql ; \
	  echo 'COMMIT;' ; \
	  echo 'VACUUM;' ; ) \
	| psql $(PSQL_ARGS)

# Reinstall outside of a transaction
.PHONY: reinstallnolock
reinstallnolock: destroytriggers maketriggers.sql
	( echo set client_min_messages TO WARNING\; ; \
	  cat destroytriggers ; \
	  cat maketriggers.sql ; \
	  echo 'VACUUM;' ; ) \
	| psql $(PSQL_ARGS)

.PHONY: destroy
destroy: destroytriggers
	( echo set client_min_messages TO WARNING\; ; \
	  cat destroytriggers ; \
	  echo 'VACUUM;' ; ) \
	| psql $(PSQL_ARGS)

.PHONY: clean
clean:
	rm -rf $(TARGETS)
