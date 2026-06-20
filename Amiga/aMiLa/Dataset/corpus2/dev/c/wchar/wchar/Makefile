CC = gcc
DEFS = -DU_NULL=0
CFLAGS = $(DEFS) -O2 -fomit-frame-pointer -m68000 -msoft-float

OBJ = wcscat.o wcscmp.o wcscpy.o wcslen.o wcsncmp.o wcsncpy.o
HFILES = wchar.h
LIB = libw.a

$(LIB): $(OBJ)
	rm -f $@
	ar rcv $@ $(OBJ)
	ranlib $@

install: $(LIB)
	cp $(LIB) GG:lib
	cp $(HFILES) GG:include
