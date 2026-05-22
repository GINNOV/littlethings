# Generated automatically from Makefile.in by configure.
## Makefile.in for ICU - samples/XMLConverter
## Madhu Katragadda

## Shell to use
SHELL = /bin/sh

## Install directory information
srcdir = .
top_srcdir = ../..
prefix = GG:
exec_prefix = ${prefix}

bindir = GG:bin
sbindir = GG:bin
datadir = GG:share
libdir = /GG/lib
includedir = GG:include

pkgdatadir = $(datadir)/icu
pkglibdir = $(libdir)/icu
pkgincludedir = $(includedir)/icu

## Install program information
mkinstalldirs = $(SHELL) $(top_srcdir)/mkinstalldirs

INSTALL = /bin/install -c
INSTALL_PROGRAM = ${INSTALL}
INSTALL_DATA = ${INSTALL} -m 644

## Compiler/tools information
CC = gcc
CXX = c++
PACKAGE = icu
VERSION = 1.3.1

## Platform-specific setup

## -*-makefile-*-
## AmigaOS-specific setup using gcc

## Commands to generate dependency files
GEN_DEPS.c=	$(CC) -E -MM $(DEFS) $(CPPFLAGS)
GEN_DEPS.cc=	$(CXX) -E -MM $(DEFS) $(CPPFLAGS)

## Commands to compile
COMPILE.c=	$(CC) $(DEFS) $(CPPFLAGS) $(CFLAGS) -c
COMPILE.cc=	$(CXX) $(DEFS) $(CPPFLAGS) $(CXXFLAGS) -c

## Commands to link
#LINK.c=		$(CC) $(DEFS) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS)
LINK.c=		$(CXX) $(DEFS) $(CPPFLAGS) $(CXXFLAGS) $(LDFLAGS)
LINK.cc=	$(CXX) $(DEFS) $(CPPFLAGS) $(CXXFLAGS) $(LDFLAGS)

## Commands to make a shared library
#SHLIB.c=	$(CC) $(DEFS) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) -G
#SHLIB.cc=	$(CXX) $(DEFS) $(CPPFLAGS) $(CXXFLAGS) $(LDFLAGS) -G
SHLIB.c=	${top_srcdir}/makelib
SHLIB.cc=	${top_srcdir}/makelib

## Compiler switch to embed a runtime search path
LD_RPATH=	
LD_RPATH_PRE=	$(subst =, ,=-L)

## Shared object suffix
SO=		a

## Link commands to link to ICU libs
LIBICU-UC= 	-L$(top_builddir)/common -licu-uc
LIBICU-I18N= 	-L$(top_builddir)/i18n -licu-i18n
LIBCTESTFW= 	-L$(top_builddir)/tools/ctestfw -lctestfw

## Compilation rules
%.o : $(srcdir)/%.c
	$(COMPILE.c) -o $@ $<

%.o : $(srcdir)/%.cpp
	$(COMPILE.cc) -o $@ $<

## Dependency rules
%.d : $(srcdir)/%.c
	@echo "Generating dependency information for $<"
	@$(SHELL) -ec '$(GEN_DEPS.c) $< \
		| sed '\''s/\($*\)\.o[ :]*/\1.o $@ : /g'\'' > $@; \
		[ -s $@ ] || rm -f $@'

%.d : $(srcdir)/%.cpp
	@echo "Generating dependency information for $<"
	@$(SHELL) -ec '$(GEN_DEPS.cc) $< \
		| sed '\''s/\($*\)\.o[ :]*/\1.o $@ : /g'\'' > $@; \
		[ -s $@ ] || rm -f $@'

## End AmigaOS-specific setup

## Build directory information
top_builddir = ../..
subdir = samples/XMLConverter
## Extra files to remove for 'make clean'
CLEANFILES = *~

## Target information
TARGET = XMLConverter

DEFS = -DHAVE_CONFIG_H
CPPFLAGS =  -I$(top_srcdir)/common 
CFLAGS = -O0 -fomit-frame-pointer -m68000 -msoft-float -DAPP_NO_THREADS
CXXFLAGS = -O0 -fomit-frame-pointer -m68000 -msoft-float -DAPP_NO_THREADS
LDFLAGS = -noixemul -s -m68000 -msoft-float \
$(LD_RPATH)$(LD_RPATH_PRE)$(libdir)$(LD_RPATH_PRE)$(top_builddir)/common
LIBS = $(LIBICU-UC) -lm -lw 

OBJECTS = XMLConverter.o

DEPS = $(OBJECTS:.o=.d)

##Headers files to install
HEADERS = XMLConverter.hpp

## List of phony targets
.PHONY : all all-local install install-local clean clean-local \
distclean distclean-local dist dist-local check check-local

## Clear suffix list
.SUFFIXES :

## List of standard targets
all: all-local
install: install-local
clean: clean-local
distclean : distclean-local
dist: dist-local
check: check-local

all-local: $(TARGET)

install-local: all-local

dist-local:

clean-local:
	test -z "$(CLEANFILES)" || rm -f $(CLEANFILES)
	rm -f $(OBJECTS) $(TARGET)

distclean-local: clean-local
	rm -f Makefile $(DEPS)

check-local:

Makefile: $(srcdir)/Makefile.in  $(top_builddir)/config.status
	cd $(top_builddir) \
	 && CONFIG_FILES=$(subdir)/$@ CONFIG_HEADERS= $(SHELL) ./config.status

$(TARGET) : $(OBJECTS)
	$(LINK.c) -o $@ $^ $(LIBS)

ifneq ($(MAKECMDGOALS),distclean)
-include $(DEPS)
endif
