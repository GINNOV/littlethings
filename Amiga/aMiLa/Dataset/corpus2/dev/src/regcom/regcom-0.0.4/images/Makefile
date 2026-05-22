# Generated automatically from Makefile.in by configure.
# Makefile.in generated automatically by automake 1.4a from Makefile.am

# Copyright (C) 1994, 1995-8, 1999 Free Software Foundation, Inc.
# This Makefile.in is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY, to the extent permitted by law; without
# even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE.

#**********************************************************************
#
#  REGCOM: Regimental Command
#  Copyright (C) 1997-2001 Randi J. Relander 
#  <rjrelander@users.sourceforge.net>
#
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation; either version 2
#  of the License, or (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public
#  License along with this program; if not, write to the Free
#  Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
#  MA 02111-1307, USA.
#  
#**********************************************************************


SHELL = /bin/sh

srcdir = .
top_srcdir = ../..
prefix = /SDK/Local
exec_prefix = ${prefix}

bindir = /SDK/Local/C
sbindir = ${exec_prefix}/sbin
libexecdir = ${exec_prefix}/libexec
datadir = PROGDIR:
sysconfdir = ${prefix}/etc
sharedstatedir = ${prefix}/com
localstatedir = ${prefix}/var
libdir = /SDK/Local/newlib/lib
infodir = ${prefix}/info
mandir = ${prefix}/man
includedir = /SDK/Local/common/include
oldincludedir = /usr/include

DESTDIR =

pkgdatadir = $(datadir)/regcom
pkglibdir = $(libdir)/regcom
pkgincludedir = $(includedir)/regcom

top_builddir = ../..

ACLOCAL = /RAM Disk/regcom-0.0.4/missing aclocal
AUTOCONF = /RAM Disk/regcom-0.0.4/missing autoconf
AUTOMAKE = /RAM Disk/regcom-0.0.4/missing automake
AUTOHEADER = /RAM Disk/regcom-0.0.4/missing autoheader

INSTALL = /SDK/Local/C/ginstall -c
INSTALL_PROGRAM = ${INSTALL}
INSTALL_DATA = ${INSTALL} -m 644
INSTALL_SCRIPT = ${INSTALL_PROGRAM}
INSTALL_STRIP_FLAG =
transform = s,x,x,

NORMAL_INSTALL = :
PRE_INSTALL = :
POST_INSTALL = :
NORMAL_UNINSTALL = :
PRE_UNINSTALL = :
POST_UNINSTALL = :
host_alias = ppc-unknown-amigaos
host_triplet = powerpc-unknown-amigaos
CXX = c++
MAKEINFO = makeinfo
PACKAGE = regcom
RANLIB = ranlib
SDL_CFLAGS = -I/SDK/Local/common/include/SDL
SDL_CONFIG = /SDK/Local/newlib/bin/sdl-config
SDL_LIBS = -L/SDK/Local/newlib/lib -lGL -lGLU -lSDL -lauto -lpthread -lm -lm
VERSION = 0.0.4

EXTRA_DIST =  	Buttons.bmp Console.bmp ConsoleFont.bmp Cursor.bmp Pixels.bmp 	Tile16.bmp Tile28.bmp Tile48.bmp Unit24.bmp Unit42.bmp Unit72.bmp


imagedir = $(datadir)images

image_DATA = $(EXTRA_DIST)
mkinstalldirs = $(SHELL) $(top_srcdir)/mkinstalldirs
CONFIG_CLEAN_FILES = 
DATA =  $(image_DATA)

DIST_COMMON =  Makefile.am Makefile.in


DISTFILES = $(DIST_COMMON) $(SOURCES) $(HEADERS) $(TEXINFOS) $(EXTRA_DIST)

TAR = gtar
GZIP_ENV = --best
all: all-redirect
.SUFFIXES:
$(srcdir)/Makefile.in: Makefile.am $(top_srcdir)/configure.in $(ACLOCAL_M4) 
	cd $(top_srcdir) && $(AUTOMAKE) --gnu --include-deps data/images/Makefile

Makefile: $(srcdir)/Makefile.in  $(top_builddir)/config.status
	cd $(top_builddir) \
	  && CONFIG_FILES=$(subdir)/$@ CONFIG_HEADERS= $(SHELL) ./config.status


install-imageDATA: $(image_DATA)
	@$(NORMAL_INSTALL)
	$(mkinstalldirs) $(DESTDIR)$(imagedir)
	@list='$(image_DATA)'; for p in $$list; do \
	  if test -f $(srcdir)/$$p; then \
	    echo " $(INSTALL_DATA) $(srcdir)/$$p $(DESTDIR)$(imagedir)/$$p"; \
	    $(INSTALL_DATA) $(srcdir)/$$p $(DESTDIR)$(imagedir)/$$p; \
	  else if test -f $$p; then \
	    echo " $(INSTALL_DATA) $$p $(DESTDIR)$(imagedir)/$$p"; \
	    $(INSTALL_DATA) $$p $(DESTDIR)$(imagedir)/$$p; \
	  fi; fi; \
	done

uninstall-imageDATA:
	@$(NORMAL_UNINSTALL)
	list='$(image_DATA)'; for p in $$list; do \
	  rm -f $(DESTDIR)$(imagedir)/$$p; \
	done
tags: TAGS
TAGS:


distdir = $(top_builddir)/$(PACKAGE)-$(VERSION)/$(subdir)

subdir = data/images

distdir: $(DISTFILES)
	@for file in $(DISTFILES); do \
	  d=$(srcdir); \
	  if test -d $$d/$$file; then \
	    cp -pr $$d/$$file $(distdir)/$$file; \
	  else \
	    test -f $(distdir)/$$file \
	    || ln $$d/$$file $(distdir)/$$file 2> /dev/null \
	    || cp -p $$d/$$file $(distdir)/$$file || :; \
	  fi; \
	done
info-am:
info: info-am
dvi-am:
dvi: dvi-am
check-am: all-am
check: check-am
installcheck-am:
installcheck: installcheck-am
install-exec-am:
install-exec: install-exec-am

install-data-am: install-imageDATA
install-data: install-data-am

install-am: all-am
	@$(MAKE) $(AM_MAKEFLAGS) install-exec-am install-data-am
install: install-am
uninstall-am: uninstall-imageDATA
uninstall: uninstall-am
all-am: Makefile $(DATA)
all-redirect: all-am
install-strip:
	$(MAKE) $(AM_MAKEFLAGS) INSTALL_STRIP_FLAG=-s install
installdirs:
	$(mkinstalldirs)  $(DESTDIR)$(imagedir)


mostlyclean-generic:

clean-generic:

distclean-generic:
	-rm -f Makefile $(CONFIG_CLEAN_FILES)
	-rm -f config.cache config.log stamp-h stamp-h[0-9]*

maintainer-clean-generic:
mostlyclean-am:  mostlyclean-generic

mostlyclean: mostlyclean-am

clean-am:  clean-generic mostlyclean-am

clean: clean-am

distclean-am:  distclean-generic clean-am

distclean: distclean-am

maintainer-clean-am:  maintainer-clean-generic distclean-am
	@echo "This command is intended for maintainers to use;"
	@echo "it deletes files that may require special tools to rebuild."

maintainer-clean: maintainer-clean-am

.PHONY: uninstall-imageDATA install-imageDATA tags distdir info-am info \
dvi-am dvi check check-am installcheck-am installcheck install-exec-am \
install-exec install-data-am install-data install-am install \
uninstall-am uninstall all-redirect all-am all installdirs \
mostlyclean-generic distclean-generic clean-generic \
maintainer-clean-generic clean mostlyclean distclean maintainer-clean


# Tell versions [3.59,3.63) of GNU make to not export all variables.
# Otherwise a system limit (for SysV at least) may be exceeded.
.NOEXPORT:
