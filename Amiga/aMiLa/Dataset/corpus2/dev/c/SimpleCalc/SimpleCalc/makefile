# ------------------------------------------------------------------ #
# $VER: calc makefile 1.01 (28.01.1999)                              #
#                                                                    #
# gnu make makefile for calculator project                           #
#                                                                    #
# (C) Copyright 2000 Matthew J Fletcher - All Rights Reserved.       #
# amimjf@connectfree.co.uk - www.amimjf.connectfree.co.uk            #
# ------------------------------------------------------------------ #

# debug
# -gstabs

# final build
# -O2 -s

CC  = gcc
CFLAGS  = -m68020 -c
LDFLAGS = -noixemul
LDLIBS  = -lm

OBJS    = Calc.math.o Calc.clip.o Calc.gui.o Calc.main.o Calc.supp.o

Calc: $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $(OBJS) $(LDLIBS)

Calc.math.o: Calc.math.c
	$(CC) $(CFLAGS) Calc.math.c

Calc.clip.o: Calc.clip.c
	$(CC) $(CFLAGS) Calc.clip.c

Calc.gui.o: Calc.gui.c
	$(CC) $(CFLAGS) Calc.gui.c

Calc.main.o: Calc.main.c
	$(CC) $(CFLAGS) Calc.main.c

Calc.supp.o: Calc.supp.c
	$(CC) $(CFLAGS) Calc.supp.c


