# This makefile was generated with mklib
# copyright 1988 Edwin Hoogerbeets
#
# This software is freely redistributable as long as there is no charge
# beyond resonable copy fees and as long as this notice stays intact.
#
# Thanks to Jimm Mackraz for Elib on Fish 87, from which much of this
# program is lifted. Also thanks to Neil Katin for his mylib.asm upon
# which elib is based.

CFLAGS=-T

OBJS=startup.o rtag.o interface.o lib.o ed.o 

mylib.library: $(OBJS)
        ln $(OBJS) -lc -o $@

#yourprog: yourprog.o link.o
#       ln yourprog.o link.o -lc -o $@
