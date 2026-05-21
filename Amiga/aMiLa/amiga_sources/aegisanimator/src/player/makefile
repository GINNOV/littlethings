.c.o:
	mmcc.ttp $*.c
	mmimp.ttp $*.o

OBJS1 = checks.o clip.o convert.o deadpoin.o function.o generic.o geometry.o
OBJS2 = jimlib.o lotsofli.o lprintf.o
OBJS3 = moveclon.o names.o opmatrix.o predrawp.o raster.o
OBJS4 = readscri.o replay.o rfont.o scanedge.o softtwee.o symbols.o tubes.o

OBJS = $(OBJS1) $(OBJS2) $(OBJS3) $(OBJS4)

LIBS = \
	..\asm\libasm.a \
	..\libm\libmath.a \
	..\c\libcomm.a \
	..\libatari\libatari.a \
	libplay.a

PROGRAMS = anist.prg

all ALL: $(PROGRAMS)

anist.prg: $(OBJS) $(LIBS) anist.lnk
	mmlink.ttp anist.lnk -o $@ -M anist.map

libplay.a: $(OBJS)
	$(RM) $@
	mmlib.ttp rv $@ $(OBJS1)
	mmlib.ttp rv $@ $(OBJS2)
	mmlib.ttp rv $@ $(OBJS3)
	mmlib.ttp rv $@ $(OBJS4)

clean CLEAN::
	$(RM) *.o *.a *.prg
