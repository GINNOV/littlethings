# Makefile for IFF2C for GCC-PPC
# created 25-Feb-2004 by Alfred Faust

CFLAGS = -mcpu=603e -O2 -mstrict-align
LDFLAGS = -mcpu=603e -O2 -mstrict-align

CC = gcc
OBJECTS = unpacker.o ilbmr.o iffr.o iffw.o iff2c.o readpict.o remalloc.o main.o
CCFLAGS = -I. -I$(srcdir)
all: $(OBJECTS)
	gcc  $(LDFLAGS) -o IFF2C  $(OBJECTS)

main.o:     main.c
iff2c.o:    iff2c.c
readpict.o: readpict.c
remalloc.o: remalloc.c
iffw.o:     iffw.c
iffr.o:     iffr.c
ilbmr.o:    ilbmr.c
unpacker.o: unpacker.c
