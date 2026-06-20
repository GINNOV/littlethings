
CFLAGS= +BCDL +Ivd0:include/symbols.m
OBJS= device.o bset.o

.c.o:
    cc $(CFLAGS) $*.c

all: $(OBJS)
    ln +Q $(OBJS) -lcl32 -O ram:device

flush:
    cc +L +Ivd0:include/symbols.m flush.c -o ram:flush.o
    ln +Q ram:flush.o -lc32

