# ------------------------------------------------------------------ #
# $VER: stats makefile 1.01 (12.01.1999)                             #
#                                                                    #
# gnu make makefile for stats project                                #
#                                                                    #
# (C) Copyright 1999-2000 Matthew J Fletcher - All Rights Reserved.  #
# amimjf@connectfree.co.uk - www.amimjf.connectfree.co.uk            #
# ------------------------------------------------------------------ #

CC  = gcc
CFLAGS  = -m68020 -c
LDFLAGS = -noixemul
LDLIBS  = -lm

OBJS    = Stats.supp.o Stats.gui.o Stats.main.o

Stats: $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $(OBJS) $(LDLIBS)

Stats.supp.o: Stats.supp.c
	$(CC) $(CFLAGS) Stats.supp.c

Stats.gui.o: Stats.gui.c
	$(CC) $(CFLAGS) Stats.gui.c

Stats.main.o: Stats.main.c
	$(CC) $(CFLAGS) Stats.main.c


