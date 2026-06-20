CC=i386-aros-gcc
CFLAGS=-c -g -fwrapv -Wall -Wconversion -Wno-switch -Wno-parentheses -Wno-sign-conversion

all: vm32_cgen.c vm32_cgen.h ../decl.h ../parser.h ../lexer.h ../pre.h ../expr.h ../stmt.h \
../imp_lim.h ../error.h ../loc.h ../util/util.h ../util/arena.h ../util/str.h
	$(CC) $(CFLAGS) vm32_cgen.c

clean:
	rm -f *.o

.PHONY: all clean
