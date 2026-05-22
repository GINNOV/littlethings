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
top_srcdir = ..
prefix = /SDK/Local
exec_prefix = ${prefix}

bindir = /SDK/Local/C
sbindir = ${exec_prefix}/sbin
libexecdir = ${exec_prefix}/libexec
datadir = /PROGDIR/
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

top_builddir = ..

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

gamedir = $(prefix)

game_PROGRAMS = regcom

regcom_SOURCES =  	Button.cpp Button.h 	Console.cpp Console.h 	Cursor.cpp Cursor.h 	Desktop.cpp Desktop.h 	Font.cpp Font.h 	Fractal.cpp Fractal.h 	Game.cpp Game.h 	Hex.cpp Hex.h 	Main.cpp 	Map.cpp Map.h 	MapView.cpp MapView.h 	Point.h 	RadarView.cpp RadarView.h 	Rect.cpp Rect.h 	Screen.cpp Screen.h 	ScrollView.cpp ScrollView.h 	StringView.cpp StringView.h 	Surface.cpp Surface.h 	Tile.cpp Tile.h 	Unit.cpp Unit.h 	Window.cpp Window.h
mkinstalldirs = $(SHELL) $(top_srcdir)/mkinstalldirs
CONFIG_CLEAN_FILES = 
PROGRAMS =  $(game_PROGRAMS)


DEFS =  -DPACKAGE=\"regcom\" -DVERSION=\"0.0.4\" -DGAME_DATADIR=\"PROGDIR:\"  -I. -I$(srcdir) 
CPPFLAGS = -mcrt=newlib -DMINIGL
LDFLAGS = -mcrt=newlib -lunix
LIBS = -lunix -L/SDK/Local/newlib/lib -lGL -lGLU -lSDL -lauto -lpthread -lm -lm
regcom_OBJECTS =  Button.o Console.o Cursor.o Desktop.o Font.o Fractal.o \
Game.o Hex.o Main.o Map.o MapView.o RadarView.o Rect.o Screen.o \
ScrollView.o StringView.o Surface.o Tile.o Unit.o Window.o
regcom_LDADD = $(LDADD)
regcom_DEPENDENCIES = 
regcom_LDFLAGS = 
CXXFLAGS = -mcrt=newlib -I/SDK/Local/common/include/SDL
CXXCOMPILE = $(CXX) $(DEFS) $(INCLUDES) $(AM_CPPFLAGS) $(CPPFLAGS) $(AM_CXXFLAGS) $(CXXFLAGS)
CXXLD = $(CXX)
CXXLINK = $(CXXLD) $(AM_CXXFLAGS) $(CXXFLAGS) $(LDFLAGS) -o $@
CFLAGS = -mcrt=newlib
COMPILE = $(CC) $(DEFS) $(INCLUDES) $(AM_CPPFLAGS) $(CPPFLAGS) $(AM_CFLAGS) $(CFLAGS)
CCLD = $(CC)
LINK = $(CCLD) $(AM_CFLAGS) $(CFLAGS) $(LDFLAGS) -o $@
DIST_COMMON =  Makefile.am Makefile.in


DISTFILES = $(DIST_COMMON) $(SOURCES) $(HEADERS) $(TEXINFOS) $(EXTRA_DIST)

TAR = gtar
GZIP_ENV = --best
SOURCES = $(regcom_SOURCES)
OBJECTS = $(regcom_OBJECTS)

all: all-redirect
.SUFFIXES:
.SUFFIXES: .S .c .cpp .o .s
$(srcdir)/Makefile.in: Makefile.am $(top_srcdir)/configure.in $(ACLOCAL_M4) 
	cd $(top_srcdir) && $(AUTOMAKE) --gnu --include-deps src/Makefile

Makefile: $(srcdir)/Makefile.in  $(top_builddir)/config.status
	cd $(top_builddir) \
	  && CONFIG_FILES=$(subdir)/$@ CONFIG_HEADERS= $(SHELL) ./config.status


mostlyclean-gamePROGRAMS:

clean-gamePROGRAMS:
	-test -z "$(game_PROGRAMS)" || rm -f $(game_PROGRAMS)

distclean-gamePROGRAMS:

maintainer-clean-gamePROGRAMS:

install-gamePROGRAMS: $(game_PROGRAMS)
	@$(NORMAL_INSTALL)
	$(mkinstalldirs) $(DESTDIR)$(gamedir)
	@list='$(game_PROGRAMS)'; for p in $$list; do \
	  if test -f $$p; then \
	    echo "  $(INSTALL_PROGRAM) $(INSTALL_STRIP_FLAG) $$p $(DESTDIR)$(gamedir)/`echo $$p|sed 's/$(EXEEXT)$$//'|sed '$(transform)'|sed 's/$$/$(EXEEXT)/'`"; \
	     $(INSTALL_PROGRAM) $(INSTALL_STRIP_FLAG) $$p $(DESTDIR)$(gamedir)/`echo $$p|sed 's/$(EXEEXT)$$//'|sed '$(transform)'|sed 's/$$/$(EXEEXT)/'`; \
	  else :; fi; \
	done

uninstall-gamePROGRAMS:
	@$(NORMAL_UNINSTALL)
	list='$(game_PROGRAMS)'; for p in $$list; do \
	  rm -f $(DESTDIR)$(gamedir)/`echo $$p|sed 's/$(EXEEXT)$$//'|sed '$(transform)'|sed 's/$$/$(EXEEXT)/'`; \
	done

.c.o:
	$(COMPILE) -c $<

.s.o:
	$(COMPILE) -c $<

.S.o:
	$(COMPILE) -c $<

mostlyclean-compile:
	-rm -f *.o core *.core

clean-compile:

distclean-compile:
	-rm -f *.tab.c

maintainer-clean-compile:

regcom: $(regcom_OBJECTS) $(regcom_DEPENDENCIES)
	@rm -f regcom
	$(CXXLINK) $(regcom_LDFLAGS) $(regcom_OBJECTS) $(regcom_LDADD) $(LIBS)
.cpp.o:
	$(CXXCOMPILE) -c $<

tags: TAGS

ID: $(HEADERS) $(SOURCES) $(LISP)
	list='$(SOURCES) $(HEADERS)'; \
	unique=`for i in $$list; do echo $$i; done | \
	  awk '    { files[$$0] = 1; } \
	       END { for (i in files) print i; }'`; \
	here=`pwd` && cd $(srcdir) \
	  && mkid -f$$here/ID $$unique $(LISP)

TAGS:  $(HEADERS) $(SOURCES)  $(TAGS_DEPENDENCIES) $(LISP)
	tags=; \
	here=`pwd`; \
	list='$(SOURCES) $(HEADERS)'; \
	unique=`for i in $$list; do echo $$i; done | \
	  awk '    { files[$$0] = 1; } \
	       END { for (i in files) print i; }'`; \
	test -z "$(ETAGS_ARGS)$$unique$(LISP)$$tags" \
	  || (cd $(srcdir) && etags $(ETAGS_ARGS) $$tags  $$unique $(LISP) -o $$here/TAGS)

mostlyclean-tags:

clean-tags:

distclean-tags:
	-rm -f TAGS ID

maintainer-clean-tags:

distdir = $(top_builddir)/$(PACKAGE)-$(VERSION)/$(subdir)

subdir = src

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
Button.o: Button.cpp Button.h Window.h Rect.h Point.h Surface.h \
	Console.h RadarView.h Font.h Game.h
Console.o: Console.cpp Console.h Surface.h Window.h Rect.h Point.h \
	RadarView.h Font.h StringView.h Button.h Game.h Screen.h
Cursor.o: Cursor.cpp Cursor.h Window.h Rect.h Point.h Surface.h Screen.h
Desktop.o: Desktop.cpp Desktop.h Window.h Rect.h Point.h Surface.h \
	Screen.h
Font.o: Font.cpp Font.h Surface.h Rect.h Point.h
Fractal.o: Fractal.cpp Fractal.h
Game.o: Game.cpp Game.h Rect.h Point.h Map.h Screen.h Surface.h Cursor.h \
	Window.h MapView.h ScrollView.h Console.h RadarView.h Font.h \
	Desktop.h
Hex.o: Hex.cpp Hex.h
Main.o: Main.cpp Game.h Rect.h Point.h
Map.o: Map.cpp Map.h Tile.h Fractal.h Point.h
MapView.o: MapView.cpp MapView.h ScrollView.h Window.h Rect.h Point.h \
	Surface.h Map.h Tile.h Console.h RadarView.h Font.h Hex.h
RadarView.o: RadarView.cpp RadarView.h Window.h Rect.h Point.h Surface.h \
	Map.h Tile.h MapView.h ScrollView.h Console.h Font.h Screen.h
Rect.o: Rect.cpp Rect.h Point.h
Screen.o: Screen.cpp Screen.h Surface.h Rect.h Point.h
ScrollView.o: ScrollView.cpp ScrollView.h Window.h Rect.h Point.h \
	Surface.h Screen.h
StringView.o: StringView.cpp StringView.h Window.h Rect.h Point.h \
	Surface.h Font.h Screen.h
Surface.o: Surface.cpp Rect.h Point.h Surface.h
Tile.o: Tile.cpp Tile.h Unit.h
Unit.o: Unit.cpp Unit.h Tile.h Map.h
Window.o: Window.cpp Window.h Rect.h Point.h Surface.h Screen.h

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

install-data-am: install-gamePROGRAMS
install-data: install-data-am

install-am: all-am
	@$(MAKE) $(AM_MAKEFLAGS) install-exec-am install-data-am
install: install-am
uninstall-am: uninstall-gamePROGRAMS
uninstall: uninstall-am
all-am: Makefile $(PROGRAMS)
all-redirect: all-am
install-strip:
	$(MAKE) $(AM_MAKEFLAGS) INSTALL_STRIP_FLAG=-s install
installdirs:
	$(mkinstalldirs)  $(DESTDIR)$(gamedir)


mostlyclean-generic:

clean-generic:

distclean-generic:
	-rm -f Makefile $(CONFIG_CLEAN_FILES)
	-rm -f config.cache config.log stamp-h stamp-h[0-9]*

maintainer-clean-generic:
mostlyclean-am:  mostlyclean-gamePROGRAMS mostlyclean-compile \
		mostlyclean-tags mostlyclean-generic

mostlyclean: mostlyclean-am

clean-am:  clean-gamePROGRAMS clean-compile clean-tags clean-generic \
		mostlyclean-am

clean: clean-am

distclean-am:  distclean-gamePROGRAMS distclean-compile distclean-tags \
		distclean-generic clean-am

distclean: distclean-am

maintainer-clean-am:  maintainer-clean-gamePROGRAMS \
		maintainer-clean-compile maintainer-clean-tags \
		maintainer-clean-generic distclean-am
	@echo "This command is intended for maintainers to use;"
	@echo "it deletes files that may require special tools to rebuild."

maintainer-clean: maintainer-clean-am

.PHONY: mostlyclean-gamePROGRAMS distclean-gamePROGRAMS \
clean-gamePROGRAMS maintainer-clean-gamePROGRAMS uninstall-gamePROGRAMS \
install-gamePROGRAMS mostlyclean-compile distclean-compile \
clean-compile maintainer-clean-compile tags mostlyclean-tags \
distclean-tags clean-tags maintainer-clean-tags distdir info-am info \
dvi-am dvi check check-am installcheck-am installcheck install-exec-am \
install-exec install-data-am install-data install-am install \
uninstall-am uninstall all-redirect all-am all installdirs \
mostlyclean-generic distclean-generic clean-generic \
maintainer-clean-generic clean mostlyclean distclean maintainer-clean


# Tell versions [3.59,3.63) of GNU make to not export all variables.
# Otherwise a system limit (for SysV at least) may be exceeded.
.NOEXPORT:
