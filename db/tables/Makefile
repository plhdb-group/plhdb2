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

# The order tables are listed here is the order in which the tables
# are created and the reverse order in which they are destroyed.
INFILES := site.m4 taxon.m4 study.m4
SQLFILES := $(INFILES:.m4=.sql)
TARGETS := $(SQLFILES) maketables.sql destroytables.sql emptytables.sql

INCLUDE := ../include
COPYRIGHT := $(INCLUDE)/copyright.sql
COPYRIGHTSRC := $(INCLUDE)/copyright.m4

DEPS := Makefile ../defaults.mk

include ../defaults.mk

$(COPYRIGHT): $(COPYRIGHTSRC) $(DEPS)
	make -C $(INCLUDE) $$(basename $(COPYRIGHT))

maketables.sql: $(SQLFILES) $(COPYRIGHT) $(DEPS)
	cat $(COPYRIGHT) $(SQLFILES) > maketables.sql

destroytables.sql: destroytables.sh $(COPYRIGHT) $(DEPS)
	cat $(COPYRIGHT) > destroytables.sql
	printf "%s" "$(INFILES:.m4=)" \
	  | sh destroytables.sh >> destroytables.sql

emptytables.sql: emptytables.sh $(COPYRIGHT) $(DEPS)
	cat $(COPYRIGHT) > emptytables.sql
	printf "%s" "$(INFILES:.m4=)" \
	  | sh emptytables.sh >> emptytables.sql

# Make any *.sql file from it's *.m4 file.
%.sql: %.m4 include/grants.m4 $(COPYRIGHTSRC) \
            ../include/constants.m4 include/tablemacros.m4 $(DEPS)
	m4 -I $(INCLUDE) -I include $< > $@

.PHONY: install
install: maketables.sql $(DEPS)
	( echo set client_min_messages TO WARNING\; ; \
	  cat maketables.sql ) \
	| psql $(PSQL_ARGS)

.PHONY: reinstall
reinstall: destroytables.sql maketables.sql
	( echo set client_min_messages TO WARNING\; ; \
	  cat destroytables.sql ; \
	  cat maketables.sql ; \
	  echo 'VACUUM;' ; ) \
	| psql $(PSQL_ARGS)

.PHONY: destroy
destroy: destroytables.sql
	( echo set client_min_messages TO WARNING\; ; \
	  cat destroytables.sql ; \
	  echo 'VACUUM;' ; ) \
	| psql $(PSQL_ARGS)

.PHONY: empty
empty: emptytables.sql
	( echo set client_min_messages TO WARNING\; ; \
	  cat emptytables.sql ; \
	  echo 'VACUUM;' ; ) \
	| psql $(PSQL_ARGS)

.PHONY: clean
clean:
	rm -rf $(TARGETS)
