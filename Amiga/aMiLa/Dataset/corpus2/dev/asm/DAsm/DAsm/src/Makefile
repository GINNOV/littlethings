
#   DASM    -small systems cross assembler.  The source is compilable on
#	     Amiga's, UNIX systems, and IBM-PCs with the appropriate
#	     #define in asm.h (no #define == Amiga).  some functions from
#	     my amiga support library are needed (or write your own)
#
#   (C)Copyright 1988-1989 Matthew Dillon, All Rights Reserved.
#
#   This Makefile is for AZTEC C on an Amiga.
#

DASM   = srcc:dasm
FTOHEX = srcc:ftohex
OD     = T:

CFLAGS= +L

SRC1= main.c
SRC2= ops.c
SRC3= globals.c
SRC4= exp.c
SRC5= symbols.c
SRC6= mne6303.c
SRC7= mne6502.c
SRC8= mne68705.c
SRC9= mne6811.c

OBJ1= $(OD)main.o
OBJ2= $(OD)ops.o
OBJ3= $(OD)globals.o
OBJ4= $(OD)exp.o
OBJ5= $(OD)symbols.o
OBJ6= $(OD)mne6303.o
OBJ7= $(OD)mne6502.o
OBJ8= $(OD)mne68705.o
OBJ9= $(OD)mne6811.o

OBJS= $(OBJ1) $(OBJ2) $(OBJ3) $(OBJ4) $(OBJ5) $(OBJ6) $(OBJ7) $(OBJ8) $(OBJ9)
SRCS= $(SRC1) $(SRC2) $(SRC3) $(SRC4) $(SRC5) $(SRC6) $(SRC7) $(SRC8) $(SRC9)

all: $(DASM) $(FTOHEX)

$(DASM): $(OBJS)
    ln -W +Q $(OBJS) -lsup32 -lc32 -O $(DASM)

$(FTOHEX): ftohex.c
    cc $(CFLAGS) ftohex.c -o T:ftohex.o
    ln +Q T:ftohex.o -lsup32 -lc32 -O $(FTOHEX)
    delete T:ftohex.o

example:
    dasm example.asm -oram:example.out -lram:example.list -f2
    ftohex 2 ram:example.out ram:example.hex

$(OBJ1):    $(SRC1)
    cc $(CFLAGS) $(SRC1) -o $(OBJ1)
$(OBJ2):    $(SRC2)
    cc $(CFLAGS) $(SRC2) -o $(OBJ2)
$(OBJ3):    $(SRC3)
    cc $(CFLAGS) $(SRC3) -o $(OBJ3)
$(OBJ4):    $(SRC4)
    cc $(CFLAGS) $(SRC4) -o $(OBJ4)
$(OBJ5):    $(SRC5)
    cc $(CFLAGS) $(SRC5) -o $(OBJ5)
$(OBJ6):    $(SRC6)
    cc $(CFLAGS) $(SRC6) -o $(OBJ6)
$(OBJ7):    $(SRC7)
    cc $(CFLAGS) $(SRC7) -o $(OBJ7)
$(OBJ8):    $(SRC8)
    cc $(CFLAGS) $(SRC8) -o $(OBJ8)
$(OBJ9):    $(SRC9)
    cc $(CFLAGS) $(SRC9) -o $(OBJ9)

