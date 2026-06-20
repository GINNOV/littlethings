CC=vc
CFLAGS=-nostdlib -O2 -sc -sd -lvcs

FILES = MMCMP
DISTFILES = extheader.c Makefile MMCMP MMCMP.c SDI_compiler.h xfd_MMCMP.readme

all: $(FILES)

clean:
	delete $(FILES)

dist: all
	-delete xfd_MMCMP.lha
	lha -aF a xfd_MMCMP.lha $(DISTFILES)

extheader.o: extheader.c
	$(CC) $(CFLAGS) -o $@ -c extheader.c

MMCMP: extheader.o MMCMP.c
	$(CC) $(CFLAGS) -o $@ extheader.o MMCMP.c
