# $Header: /home/amb/cxref/cpp/RCS/Makefile 1.11 1997/11/20 19:55:34 amb Exp $
#
# C Cross Referencing & Documentation tool. Version 1.4a.
#
# CPP Makefile.
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

# Auto generated Makefile configuration definitions.
include ./Makefile.cpp

########

INCLUDE=
LIBRARY=

COMPILE=$(CC) -c -w $(CFLAGS) -DNEED_SVR4_STRINGS=$(SVR4_STRINGS)

LINK=$(LD) $(LDFLAGS)

########

OBJ_FILES=cccp.o cexp.o version.o

####

cxref-cpp : Makefile.cpp $(OBJ_FILES)
	[ $(CONFIG_STATUS) ] || $(LINK) $(OBJ_FILES) -o $@ $(LIBRARY)
	@touch $@

########

configure Makefile.cpp: config-cpp
	-CC='$(CC)' ./config-cpp

########

clean :
	-rm -f cxref-cpp core *.o *~ y.tab.c Makefile.cpp

########

cexp.c : cexp.y
	[ $(CONFIG_STATUS) ] || $(YACC) cexp.y
	@touch $@
	@mv y.tab.c cexp.c

####

cccp.o: cccp.c config.h tm.h pcp.h
	[ $(CONFIG_STATUS) ] || $(COMPILE) cccp.c -o $@ $(INCLUDE) \
	 '-DLOCAL_INCLUDE_DIR="$(INCLUDE_DIR1)"' \
	 '-DTOOL_INCLUDE_DIR="$(INCLUDE_DIR2)"' \
	 '-DGCC_INCLUDE_DIR="$(INCLUDE_DIR3)"' \
	 '-DGPLUSPLUS_INCLUDE_DIR="."' \
	 '-DCPP_PREDEFINES="$(PREDEFINES)"'
	@touch $@

####

%.o:%.c
	[ $(CONFIG_STATUS) ] || $(COMPILE) $< -o $@ $(INCLUDE)
	@touch $@

version.o    : version.c
cexp.o       : cexp.c config.h tm.h

########
