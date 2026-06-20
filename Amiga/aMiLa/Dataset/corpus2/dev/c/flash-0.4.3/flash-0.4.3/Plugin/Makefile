#!make
################################################################################
# Copyright (c) 1996 Netscape Communications. All rights reserved.
################################################################################
#
# The output of the make process will be npflash.so
# Install this file either in
#	/usr/lib/netscape/plugins/
#	(or)
#	~/.netscape/plugins/
#	(or) in any convenient directory and point environment variable
#	     NPX_PLUGIN_PATH to point to the directory. It is advisable
#	     that the plugins (.so) are the only files in that directory.
#
# This makefile contains some of our defines for the compiler:
#
# XP_UNIX	This needs to get defined for npapi.h on unix platforms.
# PLUGIN_TRACE	Enable this define to get debug prints whenever the plugin
#		api gets control.
#          

PLUGIN_DEFINES= -DXP_UNIX
OPTIMIZER= -O
FLASH=../Lib

# Solaris
#LIBCXX=/usr/lib/libC.so
# gcc
LIBCXX=

# Solaris (Sun compiler/linker)
#SHARED=-G
# FreeBSD
#SHARED=-Bshareable
# Linux
SHARED=-shared

CFLAGS=  $(OPTIMIZER) $(PLUGIN_DEFINES) -I$(FLASH) -I/usr/X11R6/include
LDFLAGS= $(FLASH)/libflash.o $(LIBCXX)

SRC= plugin.c npunix.c
OBJ= plugin.o npunix.o

SHAREDTARGET=npflash.so

default all: $(SHAREDTARGET)

$(SHAREDTARGET): $(OBJ) $(FLASH)/libflash.o
	$(LD) $(SHARED) -o $(SHAREDTARGET) $(OBJ) $(LDFLAGS)

plugin.o: $(FLASH)/flash.h

clean:
	$(RM) $(OBJ) $(SHAREDTARGET)
