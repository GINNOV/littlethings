# Make test suite
# requires check from http://check.sourceforge.net

INCDIR = ../include
CPU = -m68020-60
CPPFLAGS = 
LDFLAGS = 
LIBS = -lcheck
CC = gcc
CFLAGS = -g -O2 $(CPU) -Wall -Wmissing-prototypes -Wstrict-prototypes -fexceptions -I$(INCDIR)

all:	runtests

runtests:	runtests.o chardata.o
	$(CC) $(LDFLAGS) -o $@ runtests.o chardata.o $(LIBS)

clean:
	rm -f runtests core *.o
