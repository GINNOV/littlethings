LNFLAGS=   +SS +Cdb
LNLIBS=    -llib:m32 -llib:c32
CFLAGS=    -s +L +Iram:c/include.pre
OBJS1=     KnightLore.o Memory.o KnightBlit.o


prog:	$(OBJS1)
	ln $(LNFLAGS) -O Ram:PROG $(OBJS1) $(LNLIBS)
	Copy Ram:Prog Source:Prog

Memory.o: Memory.c Header:Memory.h
	cc $(CFLAGS) Memory.c

KnightLore.o:	KnightLore.c Header:KnightLore.h
	cc $(CFLAGS) KnightLore.c

KnightBlit.o:	KnightBlit.c Header:KnightLore.h Header:KnightBlit.h
	cc $(CFLAGS) KnightBlit.c
