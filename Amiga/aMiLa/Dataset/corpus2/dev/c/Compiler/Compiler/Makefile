CC =		dh0:lattice/c/lc
LD =		dh0:lattice/c/blink

OBJ =		analyze.o expr.o init.o optimize.o register.o func.o \
		intexpr.o outcode.o searchkw.o cglbdef.o gencode.o list.o \
		peepgen.o stmt.o cmain.o genstmt.o memmgt.o preproc.o \
		symbol.o decl.o getsym.o

.c.o:
		$(CC) $(CFLAGS) -o$@ $*.c

cc68 :		$(OBJ)
		$(LD) with link.cmd
