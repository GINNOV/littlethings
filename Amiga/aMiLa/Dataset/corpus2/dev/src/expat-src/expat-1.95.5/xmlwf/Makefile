# Makefile for xmlwf on AmigaOS

INCDIR= ../include
CPU = -m68020-60
LDFLAGS=
CFLAGS= -g -O2 $(CPU) -Wall -Wmissing-prototypes -Wstrict-prototypes -fexceptions -I$(INCDIR) -I..
CC = gcc

FILEMAP_OBJ= unixfilemap.o
OBJS= xmlwf.o xmlfile.o codepage.o $(FILEMAP_OBJ)

xmlwf: $(OBJS)
	$(CC) -o xmlwf $(LDFLAGS) $(OBJS)

clean:
	rm -f xmlwf core *.o
