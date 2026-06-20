CC=i386-aros-gcc
CFLAGS=-c -g -fwrapv -Wall -Wconversion -Wno-switch -Wno-parentheses -Wno-sign-conversion

all: vm64_cgen.c vm64_cgen.c ../decl.h ../parser.h ../lexer.h ../pre.h ../expr.h ../stmt.h \
../imp_lim.h ../error.h ../loc.h ../util/util.h ../util/arena.h ../util/str.h
	$(CC) $(CFLAGS) vm64_cgen.c

clean:
	rm -f *.o

.PHONY: all clean
