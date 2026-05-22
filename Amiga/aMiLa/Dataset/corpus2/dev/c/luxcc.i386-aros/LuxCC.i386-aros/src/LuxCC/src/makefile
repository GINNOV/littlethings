CC=i386-aros-gcc
CFLAGS=-c -g -fwrapv -Wall -Wconversion -Wno-switch -Wno-parentheses -Wno-sign-conversion
PROG=luxcc
OBJS=luxcc.o pre.o lexer.o parser.o decl.o expr.o stmt.o ic.o error.o loc.o dflow.o opt.o ast2c.o
SRCS=luxcc.c pre.c lexer.c parser.c decl.c expr.c stmt.c ic.c error.c loc.c dflow.c opt.c ast2c.c
CGOBJS=vm32_cgen/vm32_cgen.o vm64_cgen/vm64_cgen.o
UTILOBJS=util/arena.o util/bset.o util/str.o util/util.o

all: $(PROG)

$(PROG): $(OBJS) $(UTILOBJS) $(CGOBJS)
	$(CC) -o $(PROG) $(OBJS) $(UTILOBJS) $(CGOBJS)

.c.o:
	$(CC) $(CFLAGS) $*.c

clean:
	rm -f *.o $(PROG)
	make -C vm32_cgen clean
	make -C vm64_cgen clean

$(UTILOBJS):
	make -C util

$(CGOBJS):
	make -C vm32_cgen
	make -C vm64_cgen

luxcc.o: parser.h lexer.h pre.h ic.h util/util.h vm32_cgen/vm32_cgen.h vm64_cgen/vm64_cgen.h
pre.o: pre.h imp_lim.h error.h util/util.h
lexer.o: lexer.h pre.h error.h util/util.h
parser.o: parser.h lexer.h pre.h decl.h expr.h stmt.h error.h util/util.h
decl.o: decl.h parser.h lexer.h pre.h expr.h stmt.h imp_lim.h error.h util/util.h util/arena.h
expr.o: expr.h parser.h lexer.h pre.h decl.h error.h util/util.h
stmt.o: stmt.h parser.h lexer.h pre.h decl.h expr.h error.h util/util.h
ic.o: ic.h parser.h lexer.h pre.h decl.h expr.h imp_lim.h loc.h dflow.h util/bset.h util/util.h util/arena.h
error.o: error.h
loc.o: loc.h imp_lim.h util/util.h util/arena.h
dflow.o: dflow.h ic.h parser.h lexer.h pre.h expr.h util/util.h util/bset.h
opt.o: opt.h ic.h expr.h util/util.h util/bset.h
ast2c.o: ast2c.h util/str.h

.PHONY: all clean
