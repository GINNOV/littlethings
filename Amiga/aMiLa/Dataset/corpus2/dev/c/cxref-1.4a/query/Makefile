# $Header: /home/amb/cxref/query/RCS/Makefile 1.5 1996/10/29 19:52:59 amb Exp $
#
# C Cross Referencing & Documentation tool. Version 1.3.
#
# Query Program Makefile.
#
# Written by Andrew M. Bishop
#
# This file Copyright 1995,96 Andrew M. Bishop
# It may be distributed under the GNU Public License, version 2, or
# any higher version.  See section COPYING of the GNU Public license
# for conditions under which this file may be redistributed.
#

# Standard definitions, edit ../Makefile.config not this one.
include ../Makefile.config

########

INCLUDE=
LIBRARY=

COMPILE=$(CC) -c $(CFLAGS)

LINK=$(LD) $(LDFLAGS)

########

OBJ_FILES=query.o \
          input.o output.o \
          ../memory.o ../slist.o

####

cxref-query : $(OBJ_FILES)
	$(LINK) $(OBJ_FILES) -o $@ $(LIBRARY)

########

clean :
	-rm -f cxref-query core *.o *~

########

%.o:%.c
	$(COMPILE) $< -o $@ $(INCLUDE)

query.o    : query.c   query.h ../cxref.h ../datatype.h ../memory.h
input.o    : input.c   query.h ../cxref.h ../datatype.h ../memory.h
output.o   : output.c  query.h ../cxref.h ../datatype.h ../memory.h

../memory.o: ../memory.c                                ../memory.h
	$(MAKE) -C .. memory.o

../slist.o : ../slist.c        ../cxref.h ../datatype.h ../memory.h
	$(MAKE) -C .. slist.o

########
