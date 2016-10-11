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
#    along with PLHDB2.  If not, see <http://www.gnu.org/licenses/>.
#
# Karl O. Pinc <kop@meme.com>
#

INFILES := $(wildcard *.m4)
SQLFILES := $(INFILES:.m4=.sql)
TARGETS := $(SQLFILES) makepolicy.sql destroypolicy.sql

INCLUDE := ../include
COPYRIGHT := $(INCLUDE)/copyright.sql
COPYRIGHTSRC := $(INCLUDE)/copyright.m4

FUNCTIONS := ../functions
MPF := $(FUNCTIONS)/makepolicyfunctions.sql
DPF := $(FUNCTIONS)/destroypolicyfunctions.sql

DEPS := Makefile ../defaults.mk

include ../defaults.mk

$(COPYRIGHT): $(COPYRIGHTSRC) $(DEPS)
	make -C $(INCLUDE) $$(basename $(COPYRIGHT))

# Declare as phony so we don't worry about pre-requsites.
.PHONY: $(MPF)
$(MPF):
	make -C $(FUNCTIONS) makepolicyfunctions.sql

# Declare as phony so we don't worry about pre-requsites.
.PHONY: $(DPF)
$(DPF):
	make -C $(FUNCTIONS) destroypolicyfunctions.sql

makepolicy.sql: $(SQLFILES) $(MPF) $(COPYRIGHT) $(DEPS)
	cat $(COPYRIGHT) $(MPF) $(SQLFILES) > makepolicy.sql

destroypolicy.sql: destroypolicy $(DPF) $(COPYRIGHT) $(DEPS)
	cat $(COPYRIGHT) destroypolicy $(DPF) > destroypolicy.sql

# Make any *.sql file from it's *.m4 file.
%.sql: %.m4 $(COPYRIGHTSRC) $(INCLUDE)/*.m4 $(DEPS)
	m4 -I $(INCLUDE) -I include $< > $@

.PHONY: install
install: makepolicy.sql $(DEPS)
	( echo set client_min_messages TO WARNING\; ; \
	  echo 'BEGIN;' ; \
	  cat makepolicy.sql ; \
          echo 'COMMIT;' ) \
	| psql $(PSQL_ARGS)

# Install outside of a transaction
.PHONY: installnolock
installnolock: makepolicy.sql $(DEPS)
	( echo set client_min_messages TO WARNING\; ; \
	  cat makepolicy.sql ) \
	| psql $(PSQL_ARGS)

.PHONY: reinstall
reinstall: destroypolicy.sql makepolicy.sql
	( echo set client_min_messages TO WARNING\; ; \
	  echo 'BEGIN;' ; \
	  cat destroypolicy.sql ; \
	  cat makepolicy.sql ; \
	  echo 'COMMIT;' ; \
	  echo 'VACUUM;' ; ) \
	| psql $(PSQL_ARGS)

# Reinstall outside of a transaction
.PHONY: reinstallnolock
reinstallnolock: destroypolicy.sql makepolicy.sql
	( echo set client_min_messages TO WARNING\; ; \
	  cat destroypolicy.sql ; \
	  cat makepolicy.sql ; \
	  echo 'VACUUM;' ; ) \
	| psql $(PSQL_ARGS)

.PHONY: destroy
destroy: destroypolicy.sql
	( echo set client_min_messages TO WARNING\; ; \
	  cat destroypolicy.sql ; \
	  echo 'VACUUM;' ; ) \
	| psql $(PSQL_ARGS)

.PHONY: clean
clean:
	rm -rf $(TARGETS)
