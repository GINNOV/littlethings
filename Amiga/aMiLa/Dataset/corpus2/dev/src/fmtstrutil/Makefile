# ============================================================================
# $Id: Makefile,v 1.1 1996/10/26 18:20:45 d93-hyo Rel d93-hyo $
# ----------------------------------------------------------------------------
# Makefile for fmtstrutil.lib (requires GNU make).
#
# Copyright © 1996 Lorens Younes (d93-hyo@nada.kth.se)
# ============================================================================

#
# make rules
#

%.o: %.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $<

%.o: %.s
	$(AS) $(ASFLAGS) $<

%.lib: %.o
	$(OML) $(OMLFLAGS) $@ r $?

%.doc: %.c
	-$(RM) -f $@
	$(AUTODOC) $(AUTODOCFLAGS) -C $< > $@

%.doc: %.s
	-$(RM) -f $@
	$(AUTODOC) $(AUTODOCFLAGS) -S $< > $@

# ----------------------------------------------------------------------------

#
# command locations
#

CC = /sc/c/sc
AS = /sc/c/asm
OML = /sc/c/oml
RM = /bin/rm
AUTODOC = /c/autodoc
LHA = /c/lha
CP = /bin/cp

# ----------------------------------------------------------------------------

#
# command flags
#

CDEFINES =
CDEBUGFLAGS = #debug=sf
COPTFLAGS = opt optsched utillib
CFLAGS = $(CDEFINES) $(CDEBUGFLAGS) $(COPTFLAGS) ansi nochkabort errrexx\
 noerrconsole noicons nover idir=:include idir="" idir=:include/ClassAct\
 nostkchk nostkext

ASFLAGS = -jc -jm

OMLFLAGS = -b -n

AUTODOCFLAGS = -I

# ----------------------------------------------------------------------------

#
# other variables
#

LIBDEST = /projects/lib
DOCDEST = /projects/doc

# ----------------------------------------------------------------------------

#
# dependencies
#

.PHONY: all
all: fmtstrutil.lib fmtstrutil.doc

.PHONY: install
install: fmtstrutil.lib fmtstrutil.doc
	$(CP) fmtstrutil.lib $(LIBDEST)
	$(CP) fmtstrutil.doc $(DOCDEST)

fmtstrutil.lha: Makefile fmtstrutil.c fmtstrutil.h putchprocs.h putchprocs.s
	$(LHA) -aemqrx r $@ $?

fmtstrutil.lib: putchprocs.o

fmtstrutil.o: fmtstrutil.h putchprocs.h

putchprocs.o: putchprocs.h

.PHONY: clean
clean:
	-$(RM) -f *.o *.lnk *.lib *.doc *.lha
