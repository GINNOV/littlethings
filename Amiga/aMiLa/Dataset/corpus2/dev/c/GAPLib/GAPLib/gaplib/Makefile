#
# GAP-Lib (C)1998-1999 Peter Bengtsson
#
# libgap.a Makefile, generic

.PHONY : all
.PHONY : clean

CC = gcc

OPTIMIZATION = -O2 -fstrength-reduce -fexpensive-optimizations

OPTIONS = -s -pedantic -Wall -I../include/

DEFINES = -DFPU

CFLAGS = $(CODEGEN) $(OPTIMIZATION) $(OPTIONS) $(DEFINES)

AR = ar

AROPTS = -rcsv

LIBRARY = ../lib/libgap.a

include Common.mk
