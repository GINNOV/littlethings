#
# GAP-Lib (C)1998-1999 Peter Bengtsson
#
# Examples makefile
#

CFLAGS= -O2
LDFLAGS= -lm -lgap
CC= gcc

all: FuncOpt1 FuncOpt2 tutorial

clean:
	rm -f *.o

FuncOpt1: FuncOpt1.o
	$(CC) FuncOpt1.o -o FuncOpt1 $(LDFLAGS)

FuncOpt2: FuncOpt2.o
	$(CC) FuncOpt2.o -o FuncOpt2 $(LDFLAGS)

tutorial: tutorial.o
	$(CC) tutorial.o -o tutorial $(LDFLAGS)

FuncOpt1.o: FuncOpt1.c

FuncOpt2.o: FuncOpt2.c

tutorial.o: tutorial.c

