
CFLAGS= -n -I..\include -Ie:\include -L50

.c.o:
	mmcc.ttp $*.c
	mmimp.ttp $*.o

OBJS1 = aline.o backgrou.o blasthli.o
OBJS2 = clock.o color.o draw_on_.o drawpoly.o
OBJS3 = fillpoly.o init_sys.o input.o nf_ops.o
OBJS4 = jimblit.o memory.o prim.o pull.o saves.o sync.o syscalls.o

OBJS = $(OBJS1) $(OBJS2) $(OBJS3) $(OBJS4)

all ALL: libatari.a

libatari.a: $(OBJS)
	$(RM) $@
	mmlib.ttp rv $@ $(OBJS1)
	mmlib.ttp rv $@ $(OBJS2)
	mmlib.ttp rv $@ $(OBJS3)
	mmlib.ttp rv $@ $(OBJS4)

clean CLEAN::
	$(RM) *.o *.a
