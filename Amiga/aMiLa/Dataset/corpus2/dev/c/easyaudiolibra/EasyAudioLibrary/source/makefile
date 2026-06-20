# ------------------------------------------------------------------ #
# $VER: easyaudio makefile 39.01 (12.12.1999)                        #
#                                                                    #
# gnu make makefile for easyaudio.library                            #
#                                                                    #
# (C) Copyright 1999-2000 Matthew J Fletcher - All Rights Reserved.  #
# amimjf@connectfree.co.uk - www.amimjf.connectfree.co.uk            #
# ------------------------------------------------------------------ #

CC  = gcc
CFLAGS  = -fomit-frame-pointer -fbaserel -fstrength-reduce -m68020 -c
LDFLAGS = -fbaserel -noixemul -s
LDLIBS  = -lm

OBJS    = StartUp.o Init.o Func_Simple.o Func_Sound.o

easyaudio.library: $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $(OBJS) $(LDLIBS)

StartUp.o: StartUp.c
	$(CC) $(CFLAGS) -fno-force-mem StartUp.c

Init.o: Init.c
	$(CC) $(CFLAGS) Init.c

Func_Simple.o: Func_Simple.c
	$(CC) $(CFLAGS) Func_Simple.c

Func_Sound.o: Func_Sound.c
	$(CC) $(CFLAGS) Func_Sound.c

