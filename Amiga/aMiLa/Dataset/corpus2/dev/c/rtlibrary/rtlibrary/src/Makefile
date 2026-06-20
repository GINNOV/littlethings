#
# GNUmakefile
#
# Author: Tomi Ollila <too@cs.hut.fi>
#
#	Copyright (c) 1993 Tomi Ollila
#	    All rights reserved
#
# Created: Tue Sep 14 14:11:54 1993 too
# Last modified: Wed Feb  1 00:41:58 1995 too
#
# $Id: Makefile,v 3.4 1994/04/05 16:53:22 too Exp $
#

# This is for cross-compiler environment. Set your PATH environment variable
# to have amiga cross compiler bin directory as first entry. in my case:
# bash $ export PATH=/export/too/agcc/bin:$PATH

GCCPATH=	/export/too/agcc


LIB=	../lib/librt.a

TMP=	/tmp
#TMP=	ram:t

RM=	rm -f
CP=	cp

CC=	gcc
#CFLAGS= -O3 -Wall  -I.
CFLAGS= -O2 -Wall -I$(GCCPATH)/include -I$(GCCPATH)/os-include -I../include -Wno-uninitialized
#CFLAGS=  -O3 -Wall -DDEBUG -I.

LFLAGS= -nostdlib -s

AR=	ar
AFLAGS= urv

RTOBJ=	rt/rt.o rt/rt_remnode.o rt/rt_remdata.o rt/rt_remsome.o

RTEXECOBJ=	rt_exec/rt_allocmem.o rt_exec/rt_openlib.o

RTDOSOBJ=	rt_dos/rt_open.o

OBJ=	$(RTOBJ) $(RTEXECOBJ) $(RTDOSOBJ)

SRC=	$(OBJ:.o=.c)

all:	$(LIB) $(PRG)

.c.o:
	$(CC) $(CFLAGS) -o $@ -c $<
#	$(CC) $(CFLAGS) $<

.s.o:
	$(CP) $*.s $(TMP)/x.c
	$(CC) -traditional -E -o $(TMP)/x.s $(TMP)/x.c -I./rtlib
	$(CC) -o $@ -c $(TMP)/x.s


$(LIB):	$(OBJ)
	$(AR) $(AFLAGS) $@ $(OBJ)

clean:
	$(RM) $(OBJ)

FRC:

# 

