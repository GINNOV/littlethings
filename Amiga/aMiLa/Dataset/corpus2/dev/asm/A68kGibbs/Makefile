# Simple makefile to compile and link the A68k Assembler.
# Created 23Jun87 by J.A. Lydiatt.
# Output file name corrected June 18, 1989 by Charlie Gibbs.
# protos.h added April 16, 1991 by Charlie Gibbs.

OBJ=	A68kmain.o Opcodes.o Operands.o Adirect.o A68kmisc.o\
	Symtab.o Codegen.o wb_parse.o

SHARLIB1= A68k.doc Makefile A68kdef.h A68kglb.h A68kmain.c Opcodes.c Operands.c\
	Adirect.c A68kmisc.c Symtab.c Codegen.c wb_parse.c

SRC=	A68kmain.c Opcodes.c Operands.c Adirect.c A68kmisc.c\
	Symtab.c Codegen.c wb_parse.c

SHARLIB2= A68k.uue

.c.o:
	cc -D__NOPROTO -O -c $*.c

A68k:	$(OBJ) 
	cc -o A68k $(OBJ)

$(OBJ):	A68kdef.h A68kglb.h protos.h

#
# Note: Manx's makefile seems to have a bug that forbids indirection
#	such as "shar >lib a.c  b.c c.c"
#	however "make >lib" seems to work fine if you edit out the
#	commands make echos as it proceeds through the makefile.
#
#	Try make >ram:shardcp Archive 
#

Archive:
	shar $(SHARLIB1)
	shar $(SHARLIB2)

Lint:
	lint -iAztec:include Aztec:Stdlib.c Aztec:Defaults.c $(SRC)
