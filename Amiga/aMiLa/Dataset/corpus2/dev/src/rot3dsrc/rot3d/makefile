# Aztec
# To make, type:
# 1.  make makewall
# 2.  makewall wallscript
# 3.  make
#
# Code documentation is left as an exercise. :)
# freund@cis.uab.edu   dalbec@cs.arizona.edu
#
#CC=CC -bs -hi includes.dmp -md -mr
CC=CC -hi includes.dmp  -f8
AS=AS -c -d -n
#AS=AS
LN=LN +q -w
#LN=LN -g
#LNFLAGS= -lml -lcl
LNFLAGS= -lm8 -lc
#
# SAS
#
#CC=SC code=f data=f math=s
#AS=SC code=f data=f math=s
#LN=SC code=f data=f math=s link
#LNFLAGS=

all: rot makewall

#rot: rot.o wallparts.o makelc.o lighttable.o walls.o megadraw.o megamap.o clear.o blit.o objects.o lists.o blitter.o
#	$(LN) rot.o tracker.o wallparts.o makelc.o lighttable.o walls.o megadraw.o megamap.o clear.o blit.o objects.o lists.o blitter.o $(LNFLAGS)

rot: rot.o wallparts.o makelc.o lighttable.o walls.o megadraw.o megamap.o clear.o objects.o lists.o
	$(LN) rot.o wallparts.o makelc.o lighttable.o walls.o megadraw.o megamap.o clear.o objects.o lists.o $(LNFLAGS)

makelc.o: makelc.a
	$(AS) makelc.a

clear.o: clear.a
 	$(AS) clear.a

lighttable.o: lighttable.c
	$(CC) lighttable.c

wallparts.o: wallparts.c
	$(CC) wallparts.c

megadraw.o: megadraw.a
 	$(AS) megadraw.a

megamap.o: megamap.a
 	$(AS) megamap.a

rot.o: rot.c
	$(CC) rot.c

walls.o: walls.c
	$(CC) walls.c

blit.o: blit.a
	$(AS) blit.a

objects.o: objects.c
	$(CC) objects.c

blitter.o: blitter.c
	$(CC) blitter.c

lists.o: lists.c
	$(CC) lists.c

makewall.o: makewall.c
	$(CC) makewall.c

makeobj.o: makeobj.c
	$(CC) makeobj.c

#tracker.o: tracker.c
#	$(CC) -wo tracker.c

makewall: makewall.o jiff.o
	$(LN) makewall.o jiff.o  $(LNFLAGS)

makeobj: makeobj.o jiff.o
	$(LN) makeobj.o jiff.o  $(LNFLAGS)

