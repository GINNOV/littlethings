####################################################################
# Project Makefile for AmigaOS4 (PPC)
# 
# File:            Makefile
#
# Project:         AVD_TEMPLATE
#
# Original Author: Jamie Krueger
#
# Change Date  : 9/10/2005
#
# Copyright (c)2005 BITbyBIT Software Group LLC, All Rights Reserved.
# 
# This make file will build using either the native OR cross-compiler
# for AmigaOS4 without changes. To compile using the native SDK on an
# AmigaONE, just type "make". To compile using a cross-compiler
# define the environment variable $CROSS as "ppc-amigaos-".
#
# For example: For a bash shell on Linux you would add the following
# line to the .bashrc file in your home directory to automatically
# set this value every time you enter (or run) the shell:
# "export CROSS=ppc-amigaos-" (without the quotes)
# With this value set, you only need to type "make" as normal.
#
# The cross-compile build expects to find the AmigaOS4 SDK at
# /SDK (For example -I/SDK/Include/include_h/), so if your copy
# of the SDK is in your home directory for example, either make
# a link to it on root(/) like so, "ln -s /home/jamie/SDK /SDK",
# or change where it looks in this make file.
####################################################################

all: increv avd_template
debug: increv avd_template_debug

#-------------------------------------------------------------------
# Define the Project name and objects to be built here
#
PROJECTNAME       = avd_template
PROJECTNAME_DEBUG = $(PROJECTNAME)_debug
PROJECT_SRC       = $(CMN_PROJECTSRC)avd_template.c
PROJECT_H         = $(CMN_PROJECTSRC)avd_template.h
PROJECT_DEP       = $(MAKEFILE)

#-------------------------------------------------------------------
# Common Objects Build Definitions
#
OBJECTS=\
dispapp.o\
initapp.o\
initargs.o\
usage.o

dispapp.o: $(CMN_SRCPATH)${@:.o=.c}
	$(BUILD) -c $(CMN_SRCPATH)${@:.o=.c}
initapp.o: $(CMN_SRCPATH)${@:.o=.c}
	$(BUILD) -c $(CMN_SRCPATH)${@:.o=.c}
initargs.o: $(CMN_SRCPATH)${@:.o=.c}
	$(BUILD) -c $(CMN_SRCPATH)${@:.o=.c}
retarg.o: $(CMN_SRCPATH)${@:.o=.c}
	$(BUILD) -c $(CMN_SRCPATH)${@:.o=.c}
strcasstr.o: $(CMN_SRCPATH)${@:.o=.c}
	$(BUILD) -c $(CMN_SRCPATH)${@:.o=.c}
usage.o: $(CMN_SRCPATH)${@:.o=.c}
	$(BUILD) -c $(CMN_SRCPATH)${@:.o=.c}

#-------------------------------------------------------------------
# (DEBUG) Common Objects Build Definitions
#
OBJECTS_DEBUG=\
dispapp.debug\
initapp.debug\
initargs.debug\
usage.debug

dispapp.debug: $(CMN_SRCPATH)${@:.debug=.c}
	$(BUILD_DEBUG) -c $(CMN_SRCPATH)${@:.debug=.c}
initapp.debug: $(CMN_SRCPATH)${@:.debug=.c}
	$(BUILD_DEBUG) -c $(CMN_SRCPATH)${@:.debug=.c}
initargs.debug: $(CMN_SRCPATH)${@:.debug=.c}
	$(BUILD_DEBUG) -c $(CMN_SRCPATH)${@:.debug=.c}
retarg.debug: $(CMN_SRCPATH)${@:.debug=.c}
	$(BUILD_DEBUG) -c $(CMN_SRCPATH)${@:.debug=.c}
strcasstr.debug: $(CMN_SRCPATH)${@:.debug=.c}
	$(BUILD_DEBUG) -c $(CMN_SRCPATH)${@:.debug=.c}
usage.debug: $(CMN_SRCPATH)${@:.debug=.c}
	$(BUILD_DEBUG) -c $(CMN_SRCPATH)${@:.debug=.c}


#-------------------------------------------------------------------
# OS Specific Objects Build Definitions
#
OS_OBJECTS=\
os_dispapp.o\
os_init.o\
os_initargs.o\
os_initapp.o\
os_main.o\
os_outputstr.o\
os_returnerr.o\
os_usage.o

os_dispapp.o: $(CMN_OS_SRCPATH)${@:.o=.c}
	$(BUILD) -c $(CMN_OS_SRCPATH)${@:.o=.c}
os_init.o: $(CMN_OS_SRCPATH)${@:.o=.c}
	$(BUILD) -c $(CMN_OS_SRCPATH)${@:.o=.c}
os_initargs.o: $(CMN_OS_SRCPATH)${@:.o=.c}
	$(BUILD) -c $(CMN_OS_SRCPATH)${@:.o=.c}
os_initapp.o: $(CMN_OS_SRCPATH)${@:.o=.c}
	$(BUILD) -c $(CMN_OS_SRCPATH)${@:.o=.c}
os_main.o: $(CMN_OS_SRCPATH)${@:.o=.c}
	$(BUILD) -c $(CMN_OS_SRCPATH)${@:.o=.c}
os_outputstr.o: $(CMN_OS_SRCPATH)${@:.o=.c}
	$(BUILD) -c $(CMN_OS_SRCPATH)${@:.o=.c}
os_readcfg.o: $(CMN_OS_SRCPATH)${@:.o=.c}
	$(BUILD) -c $(CMN_OS_SRCPATH)${@:.o=.c}
os_returnerr.o: $(CMN_OS_SRCPATH)${@:.o=.c}
	$(BUILD) -c $(CMN_OS_SRCPATH)${@:.o=.c}
os_savecfg.o: $(CMN_OS_SRCPATH)${@:.o=.c}
	$(BUILD) -c $(CMN_OS_SRCPATH)${@:.o=.c}
os_usage.o: $(CMN_OS_SRCPATH)${@:.o=.c}
	$(BUILD) -c $(CMN_OS_SRCPATH)${@:.o=.c}

#-------------------------------------------------------------------
# (DEBUG) OS Specific Objects Build Definitions
#
OS_OBJECTS_DEBUG=\
os_dispapp.debug\
os_init.debug\
os_initargs.debug\
os_initapp.debug\
os_main.debug\
os_outputstr.debug\
os_returnerr.debug\
os_usage.debug

os_dispapp.debug: $(CMN_OS_SRCPATH)${@:.debug=.c}
	$(BUILD_DEBUG) -c $(CMN_OS_SRCPATH)${@:.debug=.c}
os_init.debug: $(CMN_OS_SRCPATH)${@:.debug=.c}
	$(BUILD_DEBUG) -c $(CMN_OS_SRCPATH)${@:.debug=.c}
os_initargs.debug: $(CMN_OS_SRCPATH)${@:.debug=.c}
	$(BUILD_DEBUG) -c $(CMN_OS_SRCPATH)${@:.debug=.c}
os_initapp.debug: $(CMN_OS_SRCPATH)${@:.debug=.c}
	$(BUILD_DEBUG) -c $(CMN_OS_SRCPATH)${@:.debug=.c}
os_main.debug: $(CMN_OS_SRCPATH)${@:.debug=.c}
	$(BUILD_DEBUG) -c $(CMN_OS_SRCPATH)${@:.debug=.c}
os_outputstr.debug: $(CMN_OS_SRCPATH)${@:.debug=.c}
	$(BUILD_DEBUG) -c $(CMN_OS_SRCPATH)${@:.debug=.c}
os_readcfg.debug: $(CMN_OS_SRCPATH)${@:.debug=.c}
	$(BUILD_DEBUG) -c $(CMN_OS_SRCPATH)${@:.debug=.c}
os_returnerr.debug: $(CMN_OS_SRCPATH)${@:.debug=.c}
	$(BUILD_DEBUG) -c $(CMN_OS_SRCPATH)${@:.debug=.c}
os_savecfg.debug: $(CMN_OS_SRCPATH)${@:.debug=.c}
	$(BUILD_DEBUG) -c $(CMN_OS_SRCPATH)${@:.debug=.c}
os_usage.debug: $(CMN_OS_SRCPATH)${@:.debug=.c}
	$(BUILD_DEBUG) -c $(CMN_OS_SRCPATH)${@:.debug=.c}


#-------------------------------------------------------------------
# OS Specific Function Build Definitions
#
OS_FUNCTIONS=\
os_allocobjs.o\
os_closelibs.o\
os_creategui.o\
os_displaygui.o\
os_freeobjs.o\
os_hidegui.o\
os_openlibs.o\
os_processevents.o\
os_returnallsigmasks.o\
os_returnlist.o

os_allocobjs.o: $(OS_FUNCSCPATH)${@:.o=.c}
	$(BUILD) -c $(OS_FUNCSPATH)${@:.o=.c}
os_closelibs.o: $(OS_FUNCSCPATH)${@:.o=.c}
	$(BUILD) -c $(OS_FUNCSPATH)${@:.o=.c}
os_creategui.o: $(OS_FUNCSCPATH)${@:.o=.c}
	$(BUILD) -c $(OS_FUNCSPATH)${@:.o=.c}
os_displaygui.o: $(OS_FUNCSPATH)${@:.o=.c}
	$(BUILD) -c $(OS_FUNCSPATH)${@:.o=.c}
os_freeobjs.o: $(OS_FUNCSCPATH)${@:.o=.c}
	$(BUILD) -c $(OS_FUNCSPATH)${@:.o=.c}
os_hidegui.o: $(OS_FUNCSPATH)${@:.o=.c}
	$(BUILD) -c $(OS_FUNCSPATH)${@:.o=.c}
os_openlibs.o: $(OS_FUNCSPATH)${@:.o=.c}
	$(BUILD) -c $(OS_FUNCSPATH)${@:.o=.c}
os_processevents.o: $(OS_FUNCSPATH)${@:.o=.c}
	$(BUILD) -c $(OS_FUNCSPATH)${@:.o=.c}
os_returnallsigmasks.o: $(OS_FUNCSPATH)${@:.o=.c}
	$(BUILD) -c $(OS_FUNCSPATH)${@:.o=.c}
os_returnlist.o: $(OS_FUNCSPATH)${@:.o=.c}
	$(BUILD) -c $(OS_FUNCSPATH)${@:.o=.c}

#-------------------------------------------------------------------
# (DEBUG) OS Specific Function Build Definitions
#
OS_FUNCTIONS_DEBUG=\
os_allocobjs.debug\
os_closelibs.debug\
os_creategui.debug\
os_displaygui.debug\
os_freeobjs.debug\
os_hidegui.debug\
os_openlibs.debug\
os_processevents.debug\
os_returnallsigmasks.debug\
os_returnlist.debug

os_allocobjs.debug: $(OS_FUNCSCPATH)${@:.debug=.c}
	$(BUILD_DEBUG) -c $(OS_FUNCSPATH)${@:.debug=.c}
os_closelibs.debug: $(OS_FUNCSCPATH)${@:.debug=.c}
	$(BUILD_DEBUG) -c $(OS_FUNCSPATH)${@:.debug=.c}
os_creategui.debug: $(OS_FUNCSCPATH)${@:.debug=.c}
	$(BUILD_DEBUG) -c $(OS_FUNCSPATH)${@:.debug=.c}
os_displaygui.debug: $(OS_FUNCSPATH)${@:.debug=.c}
	$(BUILD_DEBUG) -c $(OS_FUNCSPATH)${@:.debug=.c}
os_freeobjs.debug: $(OS_FUNCSCPATH)${@:.debug=.c}
	$(BUILD_DEBUG) -c $(OS_FUNCSPATH)${@:.debug=.c}
os_hidegui.debug: $(OS_FUNCSPATH)${@:.debug=.c}
	$(BUILD_DEBUG) -c $(OS_FUNCSPATH)${@:.debug=.c}
os_openlibs.debug: $(OS_FUNCSPATH)${@:.debug=.c}
	$(BUILD_DEBUG) -c $(OS_FUNCSPATH)${@:.debug=.c}
os_processevents.debug: $(OS_FUNCSPATH)${@:.debug=.c}
	$(BUILD_DEBUG) -c $(OS_FUNCSPATH)${@:.debug=.c}
os_returnallsigmasks.debug: $(OS_FUNCSPATH)${@:.debug=.c}
	$(BUILD_DEBUG) -c $(OS_FUNCSPATH)${@:.debug=.c}
os_returnlist.debug: $(OS_FUNCSPATH)${@:.debug=.c}
	$(BUILD_DEBUG) -c $(OS_FUNCSPATH)${@:.debug=.c}


#-------------------------------------------------------------------
# OS Specific Make Definitions
#
ifeq ($(CROSS),ppc-amigaos-)
OS_CC        =$(CROSS)gcc
OS_STRIP     =$(CROSS)strip
OS_INCLUDES  = 
OS_LINKLIBS  =-L/SDK/newlib/lib -L/SDK/clib2/lib -lamiga -lraauto
OS_LINKFLAGS = 
OS_DEFINES   =-DHAVE_UINT_TYPES -DALL_REACTION_CLASSES
OS_CFLAGS    =-newlib -Os
OS_CFLAGS_D  =-newlib
OS_DEBUG     = 
OS_LIBPATH   = 
OS_LIBPATH_D = 
OS_TARGETLIB = 
OS_LIBNAME   = 
OS_LIBNAME_D = 
OS_PROJECTSRC=../../common/
OS_FUNCSPATH =../source/functions/
COPY         =cp
REMOVE       =rm -f
INCREV       =increment_version
else
OS_CC        =gcc
#OS_CC        =distcc gcc
OS_STRIP     =strip
OS_INCLUDES  = 
OS_LINKLIBS  =-LSDK:newlib/lib -LSDK:clib2/lib -lamiga -lraauto
OS_LINKFLAGS = 
OS_DEFINES   =-DHAVE_UINT_TYPES -DALL_REACTION_CLASSES
OS_CFLAGS    =-newlib -Os
OS_CFLAGS_D  =-newlib
OS_DEBUG     = 
OS_LIBPATH   = 
OS_LIBPATH_D = 
OS_TARGETLIB = 
OS_LIBNAME   = 
OS_LIBNAME_D = 
OS_PROJECTSRC=../../common/
OS_FUNCSPATH =../source/functions/
COPY         =copy
REMOVE       =delete FORCE
INCREV       =increment_version
endif

#-------------------------------------------------------------------
# Common Project Make Definitions
#
LIB_BASENAME     = 
CMN_LINKPATH     =../lib/
CMN_TARGETBIN    =../bin/
CMN_INCDIR       =-I/SDK/Include/include_h/ -I/SDK/Include/netinclude/ -I../../../include -I../../common/include -I../include
CMN_PROJECTSRC   =../../common/
CMN_SRCPATH      =../../common/source/
CMN_OS_SRCPATH   =../source/
CMN_DEBUG        =-DDEBUG -D_DEBUG
CMN_LINKFLAGS    = 
CMN_LINKFLAGSD   = 
CMN_LINKLIBS     =#-L$(CMN_LINKPATH) -l$(LIB_BASENAME)
CMN_LINKLIBSD    =#-L$(CMN_LINKPATH) -l$(LIB_BASENAME)d

#-------------------------------------------------------------------
# Combine Common and OS Specific Make Definitions
#
OBJFLAGS   =$(OS_DEFINES) $(OS_INCLUDES) $(CMN_INCDIR)
LINKFLAGS  =$(OS_LINKFLAGS) $(CMN_LINKFLAGS)
LINKFLAGSD =$(OS_LINKFLAGS) $(CMN_LINKFLAGSD)
LINKLIBS   =$(OS_LINKLIBS) $(CMN_LINKLIBS)
LINKLIBSD  =$(OS_LINKLIBS) $(CMN_LINKLIBSD)
CC         =$(OS_CC)
STRIP      =$(OS_STRIP)
COPTIONS   =$(OS_CFLAGS) $(OBJFLAGS) $(LINKFLAGS)
COPTIONSD  =$(OS_CFLAGS_D) $(OBJFLAGS) $(LINKFLAGSD) $(CMN_DEBUG) $(OS_DEBUG)

#-------------------------------------------------------------------
# Define Project's Make Targets
#
BUILD       =$(CC) $(COPTIONS)
BUILD_DEBUG =$(CC) $(COPTIONSD)

#-------------------------------------------------------------------
# Default Target
#
$(PROJECTNAME): $(OBJECTS) $(OS_OBJECTS) $(OS_FUNCTIONS) $(PROJECT_DEP)
	$(BUILD) -o $@ $(OBJECTS) $(OS_OBJECTS) $(OS_FUNCTIONS) $(PROJECT_SRC) $(LINKLIBS)
	$(STRIP) --remove-section=".comment" $@

install: $(PROJECTNAME)
	$(COPY) $(PROJECTNAME) $(CMN_TARGETBIN)
	$(REMOVE) $(OBJECTS) $(OS_OBJECTS) $(OS_FUNCTIONS)
	$(REMOVE) $(PROJECTNAME)

#-------------------------------------------------------------------
# Debug Target
#
$(PROJECTNAME_DEBUG): $(OBJECTS_DEBUG) $(OS_OBJECTS_DEBUG) $(OS_FUNCTIONS_DEBUG) $(PROJECT_DEP)
	$(BUILD_DEBUG) -o $@ $(OBJECTS) $(OS_OBJECTS) $(OS_FUNCTIONS) $(PROJECT_SRC) $(LINKLIBSD)

install_debug: debug
	$(COPY) $(PROJECTNAME_DEBUG) $(CMN_TARGETBIN)
	$(REMOVE) $(OBJECTS) $(OS_OBJECTS) $(OS_FUNCTIONS)
	$(REMOVE) $(PROJECTNAME_DEBUG)

#-------------------------------------------------------------------
# Increment Project Version Numbers
#
increv:
	$(INCREV) -i $(OS_PROJECTSRC)include/avd_ver.h --quiet

#-------------------------------------------------------------------
# Clean Make Definitions
#
cleanall: clean

cleanobjs:
	$(REMOVE) $(OBJECTS) $(OS_OBJECTS) $(OS_FUNCTIONS)

clean: cleanobjs
	$(REMOVE) $(PROJECTNAME)
	$(REMOVE) $(CMN_TARGETBIN)$(PROJECTNAME)
	$(REMOVE) $(PROJECTNAME_DEBUG)
	$(REMOVE) $(CMN_TARGETBIN)$(PROJECTNAME_DEBUG)

neat: cleanobjs
	$(REMOVE) $(PROJECTNAME)
	$(REMOVE) $(PROJECTNAME_DEBUG)

