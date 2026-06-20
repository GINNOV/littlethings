# Generated automatically from Makefile.in by configure.
# This Makefile is designed to be included into projects which make use
# of the ICU.


SHELL=/bin/sh
CFLAGS=-O0 -fomit-frame-pointer -m68000 -msoft-float -DAPP_NO_THREADS 
CPPFLAGS= -I$(prefix)/include
CXXFLAGS=-O0 -fomit-frame-pointer -m68000 -msoft-float -DAPP_NO_THREADS 
FFLAGS=
DEFS=-DHAVE_CONFIG_H 
LDFLAGS=-noixemul -s -m68000 -msoft-float -L$(prefix)/lib $(LD_RPATH)$(LD_RPATH_PRE)$(libdir)
LIBS=-lm -lw 
ICULIBS=$(LIBS) -licu-i18n -licu-uc
exec_prefix=${prefix}
prefix=GG:
program_transform_name=s,x,x,
bindir=GG:bin
sbindir=GG:bin
libexecdir=GG:libexec
datadir=GG:share
sysconfdir=GG:etc
sharedstatedir=GG:com
localstatedir=GG:var
libdir=/GG/lib
includedir=GG:include
oldincludedir=/usr/include
infodir=GG:info
mandir=GG:man
PACKAGE=icu
VERSION=1.3.1
CC=gcc
CXX=c++

INSTALL = /bin/install -c
INSTALL_PROGRAM = ${INSTALL}
INSTALL_DATA = ${INSTALL} -m 644

INSTALL_PROGRAM=${INSTALL}
INSTALL_SCRIPT=${INSTALL_PROGRAM}
INSTALL_DATA=${INSTALL} -m 644
AUTOCONF=autoconf
host=m68k-cbm-amigaos
host_alias=amiga
host_cpu=m68k
host_vendor=cbm
host_os=amigaos
LIB_M=
CPP=gcc -E
HAVE_INTTYPES_H=0
U_IS_BIG_ENDIAN=1
HAVE_INT8_T=1
HAVE_UINT8_T=0
HAVE_INT16_T=1
HAVE_UINT16_T=0
HAVE_INT32_T=1
HAVE_UINT32_T=0
HAVE_BOOL_T=0
EXTRAS_TRUE=
EXTRAS_FALSE=#
TESTS_TRUE=
TESTS_FALSE=#
SAMPLES_TRUE=
SAMPLES_FALSE=#
platform=UNKNOWN


ld_rpath_suf=


# begin host fragment

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
# end host fragment



