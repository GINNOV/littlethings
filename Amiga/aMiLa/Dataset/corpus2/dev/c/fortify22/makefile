#
# GCC makefile for Fortify's test applications
# Disable -DFORTIFY to compile without Fortify
#
# To build both of the testers, it should simply be
# a matter of
#
#             make all
#
#

.SUFFIXES: .cxx .cpp

CC      = gcc
CCFLAGS = -Wall -DFORTIFY -Wformat -pedantic
LN      = gcc
LNFLAGS = -lm -liostream

.c.o:
	@echo ---- $*.c ----
	@$(CC) -c $(CCFLAGS) $*.c

.cxx.o:
	@echo ---- $*.cxx ----
	@$(CC) -c $(CCFLAGS) $*.cxx

#.cpp.o:
#	@echo ---- $*.cpp ----
#	@$(CC) -c $(CCFLAGS) $*.cpp

all: test test2

OBJS= test.o fortify.o
test: $(OBJS)
	@echo Linking test
	@$(LN) -o test $(OBJS) $(CCFLAGS) $(LNFLAGS)

OBJS2 = test2.o fortify.o
test2: $(OBJS2)
	@echo Linking test2
	@$(LN) -o test2 $(OBJS2) $(CCFLAGS) $(LNFLAGS)


fortify.o: fortify.cxx fortify.h ufortify.h

test.o: test.c fortify.h ufortify.h

test2.o: test2.cxx fortify.h ufortify.h
