.c.o:
	mmcc.ttp $*.c

OBJS = arctan.o sine.o sqrroot.o tmult.o

improve:
	mmimp.ttp arctan.o sine.o sqrroot.o tmult.o

all ALL: libmath.a

libmath.a: $(OBJS)
	$(RM) $@
	mmlib.ttp rv $@ $(OBJS)

clean CLEAN::
	$(RM) *.o *.a
