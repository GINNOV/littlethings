# Makefile for GNU superoptimizer

CC = gcc
DBG = -g
OPT = -O
CFLAGS = $(CPU) $(OPT) $(DBG)

OBJS = superopt.o
FILES = README COPYING Makefile TODO \
  superopt.c run_program.def insn.def goal.def superopt.h version.h longlong.h
VERSION = `sed 's,char \*version_string = "\([0-9.]*\)";,\1,' < version.h`

gso: $(OBJS)
	$(CC) $(CFLAGS) -o gso $(OBJS)

clean:
	rm -f $(OBJS) gso

superopt.o : superopt.c superopt.h run_program.def

dist:
	mkdir superopt-$(VERSION)
	ln $(FILES) superopt-$(VERSION)
	tar cf - superopt-$(VERSION) | gzip --best > superopt-$(VERSION).tar.gz
	rm -rf superopt-$(VERSION)
