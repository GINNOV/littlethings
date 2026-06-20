CC = gcc
CFLAGS = -Wall -O3 -fomit-frame-pointer -fbaserel -m68040 -s

LIBS =

EXE = warpcollect
OBJS = warpcollect.o

INSTALLDIR = /ade/lib/gcc-lib/ppc-amigaos/2.7.2.1

$(EXE): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $(OBJS) $(LIBS)

.c.o:
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f $(OBJS) $(EXE)

install:
	cp $(EXE) $(INSTALLDIR)/$(EXE)
