#
# Makefile for png2c
# (c) 2001 by David Gerber <zapek@meanmachine.ch>
#
# $Id: makefile,v 1.6 2002/11/29 10:41:11 zapek Exp $

OBJS = png2c.o	
CFLAGS = -mcrt=newlib -O2
LDFLAGS =
EXE = png2c

.c.o:
	$(CC) $(CFLAGS) -c $<

all: $(OBJS)
	$(CC) $(OBJS) $(LDFLAGS) -o $(EXE) -mcrt=newlib -lpng -lz -lauto -lpthread -lm -lunix

clean:
	-rm *.o $(EXE)

archive: clean
	-rm -rf png2c
	-rm png2c.tar.gz
	mkdir -p png2c
	cp png2c.c INSTALL README LICENSE makefile png2c
	tar -czvf png2c.tar.gz png2c
	-rm -rf png2c
