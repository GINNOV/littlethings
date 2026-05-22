CC=i386-aros-gcc
CFLAGS=-c -g -fwrapv -Wall -Wconversion -Wno-switch -Wno-parentheses -Wno-sign-conversion

all: arena.o bset.o ELF_util.o str.o util.o

.c.o:
	$(CC) $(CFLAGS) $*.c

clean:
	rm -f *.o

arena.o: arena.h
bset.o: bset.h
ELF_util.o: ELF_util.h
str.o: str.h
util.o: util.h

.PHONY: all clean
