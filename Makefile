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

# Where the website document root lives
TARGET_WWW = /srv/apps/root/var/www/html

all:

www:
	mkdir www

.PHONY: build_www
build_www: www static
	rm -rf www/*
	cp -a static/* www/
	cp -a adminer/production www/adminer
	cp -a adminer/demo www/

.PHONY: install_www
install_www: build_www
	rm -rf $(TARGET_WWW)/*
	cp -a www/* $(TARGET_WWW)/

.PHONY: clean
clean:
	rm -rf www
