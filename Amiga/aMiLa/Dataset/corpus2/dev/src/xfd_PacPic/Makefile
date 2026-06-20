CC=vc
CFLAGS=-nostdlib -sc -sd -O2
LD=PhxLnk
LDFLAGS=SC SD ND NOSHORTRELOCS

FILES = PacPic
DISTFILES = extheader.c Makefile PacPic PacPic.c SDI_compiler.h xfd_PacPic.readme

all: $(FILES)

clean:
	delete $(FILES)

dist: all
	-delete xfd_PacPic.lha
	lha -aF a xfd_PacPic.lha $(DISTFILES)

PacPic: extheader.o PacPic.o
	$(LD) $(LDFLAGS) $^ TO $@

PacPic.test: ExeHead.o PacPic.o
	$(LD) $(LDFLAGS) $^ TO $@

