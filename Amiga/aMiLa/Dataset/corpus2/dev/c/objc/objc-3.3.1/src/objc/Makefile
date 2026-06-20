
#
# Portable Object Compiler (c) 1997,98.  All Rights Reserved. 
# $Id: Makefile.in,v 1.5 2015/12/25 18:26:05 stes Exp $
#

#
# This Makefile should work with UNIX make (like SysV, BSD, GNU make)
#

CD=cd
MKDIR=mkdir
STRIP=strip
CHMOD=chmod
RM=rm -f
CP=cp -p
AR=ar cr
INSTALL=/bin/install -c
FINAL_AR=echo
RANLIB=ranlib

YACC=yacc
LEX=flex
YTABH=y.tab.h
YTABC=y.tab.c
LEXYYC=lex.yy.c
DBG_MFLAGS=-DDEBUG -g
OPT_MFLAGS=-DNDEBUG -O2
OBJSUFFIX=o
LIBSUFFIX=a
BINDIR=/usr/local/bin
LIBDIR=/usr/local/lib
IFLAGS=-I. -noI -I../../include/objcrt -I../../include/objpak -I../oclib
BOOTLIBS=-noLibs ../oclib/oclib.a ../objpak/objpak.a ../objcrt/objcrt.a
DEPENDLIBS=../objcrt/objcrt.$(LIBSUFFIX) \
           ../objpak/objpak.$(LIBSUFFIX) \
           ../oclib/oclib.$(LIBSUFFIX)
MFLAGS=$(OPT_MFLAGS)

#
# Because this directory will contain a new compiler,
# make sure we configure with a full path towards the old compiler.
#

OBJC=./objc
.SUFFIXES: .m .lm .ym

OBJCSCRIPT=objc
OBJCPROGRAM=objc.exe
OBJC1PROGRAM=objc1
POSTLINK=postlink

OBJCFILES=\
	objc.$(OBJSUFFIX)

OBJC1FILES=\
	yacc.$(OBJSUFFIX)\
	lex.$(OBJSUFFIX)\
	lexfiltr.$(OBJSUFFIX)\
	objc1.$(OBJSUFFIX)

PRELINKFILE=\
	_prelink.$(OBJSUFFIX)

PREDLLFILE=\
	_predll.$(OBJSUFFIX)

POSTLINKFILES=\
	postlink.$(OBJSUFFIX)

.m.$(OBJSUFFIX):
	$(OBJC) -c $*.m $(MFLAGS) $(IFLAGS)

.lm.$(OBJSUFFIX):
	$(LEX) $*.lm
	-$(CP) $(LEXYYC) $*.m
	$(OBJC) -c $(MFLAGS) $(IFLAGS) $*.m
	-$(RM) $(LEXYYC)
	-$(RM) $*.m

.ym.$(OBJSUFFIX):
	$(YACC) $*.ym
	-$(CP) $(YTABH) $*.h
	-$(CP) $(YTABC) $*.m
	$(OBJC) -c $(MFLAGS) $(IFLAGS) $*.m
	-$(RM) $(YTABC)
	-$(RM) $*.m

default : $(OBJC1PROGRAM) $(PRELINKFILE) $(PREDLLFILE) $(POSTLINK)

$(OBJCPROGRAM) : $(OBJCFILES) $(DEPENDLIBS)
	$(OBJC) $(OBJCFILES) $(BOOTLIBS) -o $(OBJCPROGRAM)

$(OBJC1PROGRAM) : $(OBJC1FILES) $(DEPENDLIBS)
	$(OBJC) $(OBJC1FILES) $(BOOTLIBS) -o $(OBJC1PROGRAM)

$(PRELINKFILE) : _prelink.c
	$(OBJC) -c _prelink.c

$(PREDLLFILE) : _predll.c
	$(OBJC) -c _predll.c

$(POSTLINK) : $(POSTLINKFILES) $(DEPENDLIBS)
	$(OBJC) $(POSTLINKFILES) $(BOOTLIBS) -o $(POSTLINK)

install : default
	-test -d $(BINDIR) || $(MKDIR) $(BINDIR)
	-$(INSTALL) $(OBJCSCRIPT) $(BINDIR)
	-$(CHMOD) 755 $(BINDIR)/$(OBJCSCRIPT)
	-$(INSTALL) $(OBJC1PROGRAM) $(BINDIR)
	-$(STRIP) $(BINDIR)/$(OBJC1PROGRAM)
	-$(CHMOD) 755 $(BINDIR)/$(OBJC1PROGRAM)
	-$(INSTALL) $(PRELINKFILE) $(LIBDIR)
	-$(CHMOD) 644 $(LIBDIR)/$(PRELINKFILE)
	-$(INSTALL) $(PREDLLFILE) $(LIBDIR)
	-$(CHMOD) 644 $(LIBDIR)/$(PREDLLFILE)
	-$(INSTALL) $(POSTLINK) $(BINDIR)
	-$(CHMOD) 755 $(BINDIR)/$(POSTLINK)
	-$(INSTALL) cvtimport $(BINDIR)
	-$(CHMOD) 755 $(BINDIR)/cvtimport
	-$(INSTALL) objchelp.txt $(LIBDIR)
	-$(CHMOD) 644 $(LIBDIR)/objchelp.txt
	-$(INSTALL) objcdlso.ld $(LIBDIR)
	-$(CHMOD) 644 $(LIBDIR)/objcdlso.ld

cleantmp :
	-$(RM) *.P
	-$(RM) *.i
	-$(RM) y.tab.h y.output y.tab.c

clean : cleantmp
	-$(RM) *.$(OBJSUFFIX)
	-$(RM) *.$(LIBSUFFIX)
	-$(RM) objc.m yacc.m lex.m
	-$(RM) $(OBJCPROGRAM)
	-$(RM) $(OBJC1PROGRAM)
	-$(RM) $(POSTLINK)

distclean : clean
	-$(RM) $(OBJCSCRIPT) 
	-$(RM) Makefile 
	-$(RM) config.h 

