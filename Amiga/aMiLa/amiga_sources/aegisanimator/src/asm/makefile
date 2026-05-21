.c.o:
	mmcc.ttp $*.c
	mmimp.ttp $*.o

OBJS = dez.o drawcolr.o lxclip.o lyclip.o scanedge.o xclip.o yclip.o yxorline.o

all ALL: libasm.a

libasm.a: $(OBJS)
	$(RM) $@
	mmlib.ttp rv $@ $(OBJS)

clean CLEAN::
	$(RM) *.o *.a
