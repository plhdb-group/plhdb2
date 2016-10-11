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
# Bugs:

SOURCE := plhdb_base.dia plhdb_data.dia key.dia plhdb_titlepage.dia
PDF_TARGETS := $(SOURCE:.dia=.pdf)

TARGETS := $(PDF_TARGETS) plhdb_er_diagrams.pdf

DEPS := Makefile

all: plhdb_er_diagrams.pdf

plhdb_er_diagrams.pdf: $(PDF_TARGETS) $(DEPS)
	pdfunite plhdb_titlepage.pdf key.pdf \
	         plhdb_base.pdf plhdb_data.pdf \
	         plhdb_er_diagrams.pdf

%.pdf: %.dia $(DEPS)
	dia --export=$@ --filter=pdf $<


.PHONY: clean
clean:
	rm -rf $(TARGETS)
