CC=gcc
CFLAGS=-O2 -s

FILES = szddinfo szddexpand SZDD
DISTFILES = Makefile SZDD SZDD.asm SZDD.c szddinfo szddinfo.c szddexpand \
	szddexpand.c testme xfd_SZDD.readme

all: $(FILES)

clean:
	delete $(FILES)

dist: all
	-delete xfd_SZDD.lha
	lha -aF a xfd_SZDD.lha $(DISTFILES)

szddinfo: szddinfo.c
	$(CC) $(CFLAGS) -o $@ szddinfo.c

szddexpand: szddexpand.c
	$(CC) $(CFLAGS) -o $@ szddexpand.c

SZDD: SZDD.asm
	PhxAss QUIET NOEXE SZDD.asm TO SZDD.o
	PhxLnk SZDD.o TO SZDD
	$(RM) SZDD.o
