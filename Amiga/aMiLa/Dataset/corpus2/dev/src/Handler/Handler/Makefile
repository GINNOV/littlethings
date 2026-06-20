# MY-HANDLER - Phillip Lindsay - (C) Commodore 1986
#
#

#DEBUG  = -dDEBUG

#DFILE  =  df0:lib/myprintf.o
#DFILE  =  df0:lib/debug.o

# Special hacks for my C environment.  (fnf)
CC =	df0:lib/ccom
AS =	df0:c/as
INCLUDES = -idf0:include/


CFLAGS = $(INCLUDES) +lcd -dMANX $(DEBUG)

LIBS   =  $(DFILE) -lc32 

OFILES = my-handler.o misc.o
HFILES = my-handler.h

all :		allhand ihand

allhand :	$(OFILES)
		ln -w $(OFILES) $(LIBS)

my-handler.o :	my-handler.c $(HFILES)
		$(CC) $(CFLAGS) my-handler.c

misc.o :	misc.c $(HFILES)
		$(CC) $(CFLAGS) misc.c

# here is the install program

ihand :		ihand.o adddosnode.o
		ln -w ihand.o adddosnode.o -lc32

ihand.o :	ihand.c  
		$(CC) $(CFLAGS) ihand.c

adddosnode.o :	adddosnode.asm
		$(AS) adddosnode.asm
