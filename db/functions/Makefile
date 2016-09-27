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
# Remarks:
#  Re-installing the policy functions is probably not desireable.
# This involves deleting and re-creating them, which destroys
# the policy.

# The order functions are listed here is the order in which the functions
# are created.  Destruction is manually specified.
POLICYINFILES := biography_all_access.m4 \
                 biography_search_access.m4 \
                 biography_insert_access.m4 \
                 biography_edit_access.m4
OTHERINFILES := 
POLICYSQLFILES := $(POLICYINFILES:.m4=.sql)
OTHERSQLFILES := $(OTHERINFILES:.m4=.sql)
SQLFILES := $(POLICYSQLFILES) $(OTHERSQLFILES)
TARGETS := $(SQLFILES) makefunctions.sql \
           makepolicyfunctions.sql destroypolicyfunctions.sql \
           makeotherfunctions.sql destroyotherfunctions.sql

INCLUDE := ../include
COPYRIGHT := $(INCLUDE)/copyright.sql
COPYRIGHTSRC := $(INCLUDE)/copyright.m4

DEPS := Makefile ../defaults.mk

include ../defaults.mk

$(COPYRIGHT): $(COPYRIGHTSRC) $(DEPS)
	make -C $(INCLUDE) $$(basename $(COPYRIGHT))

makepolicyfunctions.sql: $(SQLFILES) $(COPYRIGHT) $(DEPS)
	cat $(COPYRIGHT) $(SQLFILES) > makepolicyfunctions.sql

destroypolicyfunctions.sql: destroypolicyfunctions.m4 \
                            include/*.m4 $(INCLUDE)/*.m4 $(DEPS)
	m4 -I $(INCLUDE) -I include destroypolicyfunctions.m4 \
	  > destroypolicyfunctions.sql

makeotherfunctions.sql: $(SQLFILES) $(COPYRIGHT) $(DEPS)
	cat $(COPYRIGHT) $(SQLFILES) > makeotherfunctions.sql

destroyotherfunctions.sql: destroyotherfunctions.m4 \
                           include/*.m4 $(INCLUDE)/*.m4 $(DEPS)
	m4 -I $(INCLUDE) -I include destroyotherfunctions.m4 \
	  > destroyotherfunctions.sql

# Make any *.sql file from it's *.m4 file.
# No telling what includes will be used so depend on them all.
%.sql: %.m4 include/*.m4 $(COPYRIGHTSRC) \
            $(INCLUDE)/*.m4 $(DEPS)
	m4 -I $(INCLUDE) -I include $< > $@

.PHONY: install_policy
install_policy: makepolicyfunctions.sql $(DEPS)
	( echo set client_min_messages TO WARNING\; ; \
	  cat makepolicyfunctions.sql ) \
	| psql $(PSQL_ARGS)

.PHONY: install_other
install_other: makeotherfunctions.sql $(DEPS)
	( echo set client_min_messages TO WARNING\; ; \
	  cat makeotherfunctions.sql ) \
	| psql $(PSQL_ARGS)

.PHONY: install
install: install_policy install_other

.PHONY: reinstall_policy
reinstall_policy: destroypolicyfunctions.sql makepolicyfunctions.sql
	( echo set client_min_messages TO WARNING\; ; \
	  cat destroypolicyfunctions.sql ; \
	  cat makepolicyfunctions.sql ; \
	  echo 'VACUUM;' ; ) \
	| psql $(PSQL_ARGS)

.PHONY: reinstall_other
reinstall_other: destroyotherfunctions.sql makeotherfunctions.sql
	( echo set client_min_messages TO WARNING\; ; \
	  echo 'BEGIN;' ; \
	  cat destroyotherfunctions.sql ; \
	  cat makeotherfunctions.sql ; \
	  echo 'COMMIT;' ; \
	  echo 'VACUUM;' ; ) \
	| psql $(PSQL_ARGS)

.PHONY: reinstall_othernolock
reinstall_othernolock: destroyotherfunctions.sql makeotherfunctions.sql
	( echo set client_min_messages TO WARNING\; ; \
	  cat destroyotherfunctions.sql ; \
	  cat makeotherfunctions.sql ; \
	  echo 'VACUUM;' ; ) \
	| psql $(PSQL_ARGS)

.PHONY: destroy_policy
destroy_policy: destroypolicyfunctions.sql
	( echo set client_min_messages TO WARNING\; ; \
	  cat destroypolicyfunctions.sql ; \
	  echo 'VACUUM;' ; ) \
	| psql $(PSQL_ARGS)

.PHONY: destroy_other
destroy: destroyotherfunctions.sql
	( echo set client_min_messages TO WARNING\; ; \
	  cat destroyotherfunctions.sql ; \
	  echo 'VACUUM;' ; ) \
	| psql $(PSQL_ARGS)

.PHONY: clean
clean:
	rm -rf $(TARGETS)
