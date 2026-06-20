# This file is part of mCWEB.
# It is distributed WITHOUT ANY WARRANTY, express or implied.
# Version 1.0 --- June 1996

# Copyright (C) 1996 Markus Öllinger

# Permission is granted to make and distribute verbatim copies of this
# document provided that the copyright notice and this permission notice
# are preserved on all copies.

# Permission is granted to copy and distribute modified versions of this
# document under the conditions for verbatim copying, provided that the
# entire resulting derived work is given a different name and distributed
# under the terms of a permission notice identical to this one.

# 
# Read the README file, then edit this file to reflect local conditions
#

# directory for TeX inputs (mcwebmac.tex goes here)
MACROSDIR= /usr/lib/tex/macros

# directory for mCWEB inputs in @i files
CWEBINPUTS= /usr/lib/mcweb

# extension for manual pages ("l" distinguishes local from system stuff)
#MANEXT= l
MANEXT= 1

# directory for manual pages (mcweb.1 goes here)
MANDIR= /usr/man/man$(MANEXT)

# destination directory for executables; must end in /
DESTDIR= /usr/bin/

# directory for GNU EMACS Lisp code (cweb.el goes here)
EMACSDIR= /usr/share/emacs/19.30/lisp

# Set DESTPREF to null if you want to call the executables "tangle" and "weave"
# (probably NOT a good idea; I recommend leaving DESTPREF=mc)
DESTPREF=mc

# Set CCHANGES to comm-foo.ch if you need changes to mcommon.w
CCHANGES=

# Set TCHANGES to ctang-foo.ch if you need changes to mctangle.w
TCHANGES=

# Set WCHANGES to cweav-foo.ch if you need changes to mcweave.w
WCHANGES=

# We keep debugging info around, for fun, but most users don't need it
CFLAGS = -g
#CFLAGS = -O
LINKFLAGS = -g
#LINKFLAGS = -s # for smaller (stripped) executables on many UNIX systems

# What C compiler are you using?
CC = cc

# RM and CP are used below in case rm and cp are aliased
RM= /bin/rm
CP= /bin/cp

##########  You shouldn't have to change anything after this point #######

CWEAVE = ./mcweave
CTANGLE = ./mctangle
SOURCES = mcweave.w mcommon.w mctangle.w
ALMOSTALL =  mcommon.w mctangle.w Makefile README mcommon.c mcommon.h mctangle.c \
	mcwebman.tex mcwebmac.tex comm-man.ch ctang-man.ch cweav-man.ch \
	mcweb.1 cweb.el prod.w mcwebman.bbl mcwebman.mp mcwebman.1 mcwebman.2
ALL =  $(ALMOSTALL) mcweave.w bibnames.sty texnames.sty path.sty epsfig.sty

.SUFFIXES: .dvi .tex .w

.w.tex:
	$(CWEAVE) $*

.tex.dvi:	
	tex $<

.w.dvi:
	make $*.tex
	make $*.dvi

.w.c:
	$(CTANGLE) $*

.w.o:
	make $*.c
	make $*.o

all: mctangle mcweave

cautiously: mctangle
	$(CP) mcommon.c SAVEcommon.c
	./mctangle mcommon $(CCHANGES)
	diff mcommon.c SAVEcommon.c
	$(RM) SAVEcommon.c
	$(CP) mctangle.c SAVEctangle.c
	./mctangle mctangle $(TCHANGES)
	diff mctangle.c SAVEctangle.c
	$(RM) SAVEctangle.c

SAVEctangle.c:
	$(CP) mctangle.c SAVEctangle.c

SAVEcommon.c:
	$(CP) mcommon.c SAVEcommon.c

mcommon.c: mcommon.w $(CCHANGES)
	$(CTANGLE) mcommon $(CCHANGES)

mcommon.o: mcommon.c
	$(CC) $(CFLAGS) -DCWEBINPUTS=\"$(CWEBINPUTS)\" -c mcommon.c

mctangle: mctangle.o mcommon.o
	$(CC) $(LINKFLAGS) -o mctangle mctangle.o mcommon.o 

mctangle.c: mctangle.w $(TCHANGES)
	$(CTANGLE) mctangle $(TCHANGES)

mcweave: mcweave.o mcommon.o
	$(CC) $(LINKFLAGS) -o mcweave mcweave.o mcommon.o

mcweave.c: mcweave.w $(WCHANGES)
	$(CTANGLE) mcweave $(WCHANGES)

doc: $(SOURCES:.w=.dvi)

usermanual: mcwebman.tex mcwebmac.tex
	latex mcwebman

fullmanual: usermanual $(SOURCES) comm-man.ch ctang-man.ch cweav-man.ch
	make mcweave
	./mcweave mcommon.w comm-man.ch
	tex mcommon.tex
	./mcweave mctangle.w ctang-man.ch
	tex mctangle.tex
	./mcweave mcweave.w cweav-man.ch
	tex mcweave.tex

# be sure to leave mctangle.c and mcommon.c for bootstrapping
clean:
	$(RM) -f -r *~ *.o mcommon.tex mcweave.tex mcweave.c mctangle.tex \
	  *.log *.dvi *.toc *.idx *.scn core mcweave mctangle

install: all
	$(CP) mcweave $(DESTDIR)$(DESTPREF)weave
	chmod 755 $(DESTDIR)$(DESTPREF)weave
	$(CP) mctangle $(DESTDIR)$(DESTPREF)tangle
	chmod 755 $(DESTDIR)$(DESTPREF)tangle
	$(CP) mcweb.1 $(MANDIR)/mcweb.$(MANEXT)
	chmod 644 $(MANDIR)/mcweb.$(MANEXT)
	$(CP) mcwebmac.tex $(MACROSDIR)
	chmod 644 $(MACROSDIR)/mcwebmac.tex
	$(CP) cweb.el $(EMACSDIR)
	chmod 644 $(EMACSDIR)/cweb.el

tags: $(ALL)
	etags -z $(ALL)

mcweb.tar: $(ALL)
	tar cvhf mcweb.tar $(ALL)

floppy: $(ALL)
	bar cvhf /dev/rfd0 $(ALL)
	bar tvf /dev/rfd0
	eject
