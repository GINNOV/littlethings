CFLAGS = -qf -ps -so -wp -wd -wu -hi ram:small.pre

PROG = showoffreq
LIB  = req.lib
OBJS = LinkStri.o LinkProp.o Format.o SimpleRe.o TwoGadRe.o TheReq.o

.asm.o:
	as $*.asm

.c.o:
	cc $(CFLAGS) $*.c

all: $(PROG) $(LIB)

$(LIB): $(OBJS)
	lb $(LIB) $(OBJS)
	Copy $(LIB) clib:

$(PROG): $(PROG).o $(LIB)
	ln $(PROG).o -lc16 -lreq

