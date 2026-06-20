# Makefile for examples

INCDIR = ../include
CPU = -m68020-60
CPPFLAGS = 
LDFLAGS = -noixemul
LIBS = -L$(LIBDIR)
CC = gcc
CFLAGS = -g -noixemul $(CPU) -O2 -Wall -Wmissing-prototypes -Wstrict-prototypes -fexceptions -I$(INCDIR)

all: elements outline

elements: elements.o
	$(CC) $(LDFLAGS) -o $@ $<

outline: outline.o
	$(CC) $(LDFLAGS) -o $@ $<

clean:
	rm -f elements outline core *.o
