###
###  MemPools:  malloc() replacement using standard Amiga pool functions.
###  Copyright  (C)  1994    Jochen Wiedmann
###
###  This program is free software; you can redistribute it and/or modify
###  it under the terms of the GNU General Public License as published by
###  the Free Software Foundation; either version 2 of the License, or
###  (at your option) any later version.
###
###  This program is distributed in the hope that it will be useful,
###  but WITHOUT ANY WARRANTY; without even the implied warranty of
###  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
###  GNU General Public License for more details.
###
###  You should have received a copy of the GNU General Public License
###  along with this program; if not, write to the Free Software
###  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
###
###
###  This is the Makefile for gmake.
###
###
###  Computer:  Amiga 1200
###
###  Compilers: Dice 3.01
###             SAS/C 6.50
###             gcc 2.6.1
###
###
###  Author:    Jochen Wiedmann
###             Am Eisteich 9
###       72555 Metzingen
###             Germany
###
###             Phone: (0049) 7123 14881
###             Internet: jochen.wiedmann@uni-tuebingen.de
###


SRCS=calloc.c free.c init.c malloc.c realloc.c strdup.c \
     MemPoolPuddleSize.c MemPoolThreshSize.c MemPoolFlags.c

OBJS=calloc.o free.o init.o malloc.o realloc.o strdup.o \
     MemPoolPuddleSize.o MemPoolThreshSize.o MemPoolFlags.o

LIBS=mempoolss.lib mempoolssr.lib mempools.lib libmempools.a

CFLAGS=-pipe -pedantic -Wall -ansi -O3
CC=gcc

############################################################################
###
###  Targets: all clean dist check time
###
############################################################################

all: libmempools.a

dist:
	smake dist

mempools.lib:
	rm -rf #?.o
	smake mempools.lib

libmempools.a:
	rm -f libmempools.a
	for file in $(OBJS); do \
	    echo gcc -c $(CFLAGS) `basename $$file .o`.c -o $$file; \
	    gcc -c $(CFLAGS) `basename $$file .o`.c -o $$file; \
	done;
	ar q libmempools.a $(OBJS)
	ranlib libmempools.a
	rm $(OBJS)

libmempoolsd.a:
	rm -f libmempoolsd.a
	for file in $(OBJS); do \
	    echo gcc -c -DDEBUG -g -gstabs $(CFLAGS) `basename $$file .o`.c -o $$file; \
	    gcc -c -DDEBUG -g -gstabs $(CFLAGS) `basename $$file .o`.c -o $$file; \
	done;
	ar q libmempoolsd.a $(OBJS)
	ranlib libmempoolsd.a
	rm $(OBJS)

clean:
	rm -rf #?.o #?.lib lib#?.a

check: TimeMem
	@avail flush
	@TimeMem VERBOSE
	@avail flush
	@rm -f TimeMem TimeMem.o

time: TimeMem TimeMem.sas TimeMem.ixemul TimeMem.libnix TimeProg
	@echo You'd better get a cup of coffee now ...
	@echo
	@echo Timing SAS/C functions
	@TimeProg "TimeMem.sas"
	@echo Timing ixemul functions
	@TimeProg "TimeMem.ixemul"
	@echo Timing libnix functions
	@TimeProg "TimeMem.libnix"
	@echo Timing MemPool functions
	@TimeProg "TimeMem"

TimeMem: TimeMem.c
	gcc -ansi -noixemul $(CFLAGS) -o TimeMem TimeMem.c -L. -lmempools

TimeMem.sas: TimeMem.c
	smake TimeMem.sas

TimeMem.ixemul: TimeMem.c
	gcc -ansi $(CFLAGS) -o TimeMem.ixemul TimeMem.c

TimeMem.libnix: TimeMem.c
	gcc -ansi -noixemul $(CFLAGS) -o TimeMem.libnix TimeMem.c

TimeProg: TimeProg.c
	gcc -ansi -noixemul $(CFLAGS)
