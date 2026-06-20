# ============================================================================
# $Id: Makefile,v 1.1 1996/11/16 09:59:58 d93-hyo Exp d93-hyo $
# ----------------------------------------------------------------------------
# Makefile for xpmutil.lib (requires GNU make).
#
# Copyright © 1996 Lorens Younes (d93-hyo@nada.kth.se)
# ============================================================================

#
# make rules
#

%: %.o
	$(CC) link $(LDFLAGS) obj=$^ $(LOADLIBES) pname=$@

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
FD2PRAGMA = /sc/c/fd2pragma
RM = /bin/rm
AUTODOC = /c/autodoc
LHA = /c/lha
CP = /bin/cp
MKDIR = /bin/mkdir

# ----------------------------------------------------------------------------

#
# command flags
#

CDEFINES = def=AMIGA
CDEBUGFLAGS = #debug=sf
COPTFLAGS = opt optsched utillib optsize
CFLAGS = $(CDEFINES) $(CDEBUGFLAGS) $(COPTFLAGS) ansi nochkabort errrexx\
         noerrconsole noicons nover idir=:include idir="" nostkchk nostkext\
         params=reg

LDFLAGS = $(CFLAGS) stripdebug
LOADLIBES = lib xpm.lib lib xpm_ic.lib

ASFLAGS = -jc -jm

OMLFLAGS = -b -n

AUTODOCFLAGS = -I

# ----------------------------------------------------------------------------

#
# other variables
#

LIBDEST = /projects/lib
INCLUDEDEST = /projects/include
DOCDEST = /projects/docs

# ----------------------------------------------------------------------------

#
# dependencies
#

.PHONY: all
all: message xpm_ic.lib test

.PHONY: message
message:
	@echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	@echo "!!                                       !!"
	@echo "!! Make sure to   copy rgb.txt to LIBS:  !!"
	@echo "!!                                       !!"
	@echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

xpm_ic.lib: xpm_ic.o methods.o

xpm_ic.lha: Makefile test.c plaid.xpm plaid_mask.xpm xpm.lib xpm.h amigax.h\
            xpm_ic.c methods.c methods.h images/xpm.h clib/xpm_protos.h rgb.txt
	$(LHA) -aemqrx r $@ $?

xpm_ic.o:    methods.h images/xpm.h clib/xpm_protos.h
methods.o:   methods.h images/xpm.h

test: test.o
	$(CC) link $(LDFLAGS) obj=$^ $(LOADLIBES) pname=$@

.PHONY: clean
clean:
	-$(RM) -f *.o *.lnk xpm_ic.lib *.doc *.lha test
