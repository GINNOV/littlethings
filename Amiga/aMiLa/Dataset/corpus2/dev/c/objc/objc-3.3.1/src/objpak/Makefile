
#
# Portable Object Compiler
# $Id: Makefile.in,v 1.5 2015/12/25 18:26:05 stes Exp $
#

#
# This Makefile should work with UNIX make's (like SysV, BSD, GNU make)
#

MKDIR=mkdir
OBJC=objc -q
RM=rm -f
CP=cp -p
INSTALL=/bin/install -c
AR=ar cr
FINAL_AR=echo
RANLIB=ranlib

DBG_MFLAGS=-DDEBUG -g
OPT_MFLAGS=-DNDEBUG -O2
OBJSUFFIX=o
LIBSUFFIX=a
LIBDIR=/usr/local/lib
IFLAGS=-noI -I../../include/objcrt
MFLAGS=$(OPT_MFLAGS)

.SUFFIXES: .m

LIBRARY=objpak.$(LIBSUFFIX)
SHLIB=libobjpak.so

OBJFILES=\
	ascfiler.$(OBJSUFFIX)\
	  notfound.$(OBJSUFFIX)\
	  outofbnd.$(OBJSUFFIX)\
	  unknownt.$(OBJSUFFIX)\
	  typeinc.$(OBJSUFFIX)\
	  badvers.$(OBJSUFFIX)\
	cltn.$(OBJSUFFIX)\
	  ordcltn.$(OBJSUFFIX)\
	  sortcltn.$(OBJSUFFIX)\
	  set.$(OBJSUFFIX)\
	  bag.$(OBJSUFFIX)\
	  stack.$(OBJSUFFIX)\
	  runarray.$(OBJSUFFIX)\
        dictnary.$(OBJSUFFIX)\
	sequence.$(OBJSUFFIX)\
	array.$(OBJSUFFIX)\
	  ocstring.$(OBJSUFFIX)\
	  idarray.$(OBJSUFFIX)\
	  intarray.$(OBJSUFFIX)\
	rectangl.$(OBJSUFFIX)\
	point.$(OBJSUFFIX)\
	assoc.$(OBJSUFFIX)\
	objgraph.$(OBJSUFFIX)\
	cltnseq.$(OBJSUFFIX)\
	keyseq.$(OBJSUFFIX)\
	valueseq.$(OBJSUFFIX)\
	setseq.$(OBJSUFFIX)\
	bagseq.$(OBJSUFFIX)\
	treeseq.$(OBJSUFFIX)\
	octext.$(OBJSUFFIX)\
	txtstyle.$(OBJSUFFIX)\
	paragrph.$(OBJSUFFIX)\
	txtattr.$(OBJSUFFIX)

.m.o:
	$(OBJC) -c $*.m $(MFLAGS) $(IFLAGS)
	$(AR) $(LIBRARY) $@ 

$(LIBRARY) : $(OBJFILES)
	$(FINAL_AR) $(LIBRARY) $(OBJFILES)
	$(RANLIB) $(LIBRARY)

shlib : $(OBJFILES)
	objc -dl $(OBJFILES) -o $(SHLIB)

install : $(LIBRARY)
	test -d $(LIBDIR) || $(MKDIR) $(LIBDIR)
	-$(INSTALL) $(LIBRARY) $(LIBDIR)

cleantmp :
	-$(RM) *.P
	-$(RM) *.c
	-$(RM) *.i

clean : cleantmp
	-$(RM) *.$(OBJSUFFIX)
	-$(RM) *.$(LIBSUFFIX)
	-$(RM) $(SHLIB)

distclean : clean
	-$(RM) Makefile 
	-$(RM) config.h 

