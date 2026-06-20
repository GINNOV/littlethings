#
# $Id: makefile,v 1.5 2001/12/25 00:55:26 tfrieden Exp $
#
# $Date: 2001/12/25 00:55:26 $
# $Revision: 1.5 $
#
# (C) 1999 by Hyperion
# All rights reserved
#
# This file is part of the MiniGL library project
# See the file Licence.txt for more details
#
#

VPATH = ../src/ ../demos
INCLUDE = -I../include
CFLAGS = $(INCLUDE) -m68060 -D__M68K__ $(DEBUG) $(ADDFLAG) -ffast-math -fomit-frame-pointer
DEBUG = -DNDEBUG
LIBNAME = ../lib/libmgl.a

DEMOS = GLTest varray warp mtex gears driverinfo

CC = m68k-amigaos-gcc -O3 -g -DINLINE=__inline

AR = ar
RANLIB = m68k-amigaos-ranlib

LIBOBJ = context.o vertexbuffer.o draw.o texture.o fog.o \
	hclip.o init.o glu.o \
	aclip.o vertexelements.o vertexarray.o \
	others.o matrix.o


DEBUGLIB = -ldebug

EXEOBJ = GLTest.o

all: $(LIBNAME) $(DEMOS)

install:
		cp ../include/mgl/*.h /usr/os-include/mgl
		cp ../lib/libmgl.a /usr/m68k-amigaos/lib

clean:
		-rm *.o ../lib/libmgl.a

lib: $(LIBNAME)
		@echo "Done"


GLTest: GLTest.o $(LIBNAME)
		$(CC) -o GLTest $(INCLUDE) GLTest.o -L../lib -lmgl $(DEBUGLIB)

gears: gears.o $(LIBNAME)
		$(CC) -o gears $(INCLUDE) gears.o -L../lib -lmgl $(DEBUGLIB)
#		/c/copy gears ../gears

gears_stats: gears_stats.o $(LIBNAME)
		$(CC) -o gears_stats $(INCLUDE) gears_stats.o -L../lib -lmgl $(DEBUGLIB)
#		/c/copy gears_stats ../gears_stats

driverinfo: driverinfo.o $(LIBNAME)
		$(CC) -o driverinfo $(INCLUDE) driverinfo.o -L../lib -lmgl $(DEBUGLIB)
#		/c/copy driverinfo ../driverinfo

varray_new: varray_new.o $(LIBNAME)
		$(CC) -o varray_new $(INCLUDE) varray_new.o -L../lib -lmgl $(DEBUGLIB)
#		/c/copy varray_new ../varray_new

mtex: mtex.o $(LIBNAME)
		$(CC) -o mtex $(INCLUDE) mtex.o -L../lib -lmgl $(DEBUGLIB)
#		/c/copy mtex ../mtex

bounce: bounce.o $(LIBNAME)
		$(CC) -o bounce $(INCLUDE) bounce.o -L../lib -lmgl $(DEBUGLIB)
#		/c/copy bounce ../bounce

smtest: smtest.o $(LIBNAME)
		$(CC) -o smtest $(INCLUDE) smtest.o -L../lib -lmgl $(DEBUGLIB)
#		/c/copy smtest ../smtest

texsub: texsub.o $(LIBNAME)
		$(CC) -o texsub $(INCLUDE) texsub.o -L../lib -lmgl $(DEBUGLIB)
#		/c/copy texsub ../texsub

../gears: gears.o $(LIBNAME)
		$(CC) -o gears $(INCLUDE) gears.o -L../lib -lmgl $(DEBUGLIB)
#		/c/copy gears ../gears

warp: warp.o $(LIBNAME)
		$(CC) -o warp $(INCLUDE) warp.o -L../lib -lmgl $(DEBUGLIB)
#		/c/copy warp ../warp

rasonly: rasonly.o $(LIBNAME)
		$(CC) -o rasonly $(INCLUDE) rasonly.o -L../lib -lmgl $(DEBUGLIB)
#		/c/copy rasonly ../rasonly

varray: varray.o $(LIBNAME)
		$(CC) -o varray $(INCLUDE) varray.o -L../lib -lmgl $(DEBUGLIB)
#		/c/copy varray ../varray

$(LIBNAME):  $(LIBOBJ)
		$(AR) rcs $(LIBNAME) $(LIBOBJ)



depend:
		makedepend $(INCLUDE) src/*.c

