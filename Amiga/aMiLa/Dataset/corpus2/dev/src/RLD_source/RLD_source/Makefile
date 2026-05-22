#
# $Id: Makefile,v 1.2 1997/10/21 22:35:08 wegge Stab wegge $
#
# $Log: Makefile,v $
# Revision 1.2  1997/10/21 22:35:08  wegge
# Snapshot inden upload af 2.13 i source og binær form
#
# Revision 1.1  1997/10/21 03:49:58  wegge
# Initial revision
#
#

OBJS	= libinit.o rexx_supp.o localerexx.o debugstub.o

SRCS 	= $(OBJS:.o=.c)
DEPS 	= $(OBJS:.o=.d)

CFLAGS	= -D__AMIGADATE__=\"$(ADATE)\" -g -MMD $(DODEBUG) -O2 -ansi \
	  -Wall -Wmissing-prototypes
LDFLAGS	= -s -nostartfiles -nostdlib -lamiga

ifeq ($(OSTYPE),linux)
CC	= m68k-cbm-amigaos-gcc
LD	= m68k-cbm-amigaos-ld
AS	= m68k-cbm-amigaos-as
else
CC	= gcc
LD	= ld
AS	= as
endif

ADATE := $(shell date +%d.%m.%y | sed -e 's/\.0/\./' | sed -e 's/^0//')

.PHONY : clean veryclean checkin

all: rexxlocaldates.library 

rexxlocaldates.library:	$(OBJS)
	$(CC) -v $^ -o $@ $(LDFLAGS)

$(OBJS):  Makefile
clean:
	@echo Cleaning up...
	@-rm $(OBJS)
	@-rm *.[ch][!~]

veryclean: clean
	@-rm *.d > /dev/null

checkin:
	ci -l -m'Routine deposit' *.c *.h *.s

%.d : %.c
	$(CC) -MMD $< -E > /dev/null

include $(DEPS)


