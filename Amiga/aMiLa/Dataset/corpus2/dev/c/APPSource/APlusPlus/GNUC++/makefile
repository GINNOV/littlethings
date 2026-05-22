#
# GNU Makefile for the A++ Test programs
# Copyright (C)1994 by Armin Vogt
#
# This makefile has been created automatically with 'maketst'
# $Id: maketst,v 1.2 1994/08/02 18:58:28 Armin_Vogt Exp Armin_Vogt 0
#

TESTPRGS        =      /apphome/TESTPRGS/
APPINCLUDE      =      /appinclude/

#
# if the Commodore® headers are not present in gcc:os-include
# define their path here..
CHEADERS        =      /include


CC      =  g++
CFLAGS  =  -O2

LIBNAME    =	aplusplus
LIBDIR     = /apphome/gnuc++/APPlibrary
LOADLIBES = -L$(LIBDIR) -l$(LIBNAME) -lauto

ERRORPIPE  =  pipe:gnu_errors



COMPILE = $(CC) -c -I/gcc/include -I$(APPINCLUDE) -I$(CHEADERS) $(CFLAGS) $< >$(ERRORPIPE)


# The order of include directory declarations in crucial when
# CHEADERS is used. GNU standard headers must have a higher priority
# than the ones in the CHEADERS (usually SAS standard headers!!)


all: \
 TypeInfo_test\
 MsgPort_test\
 SigResp_test\
 AutoDrawArea_test\
 Canvas_test\
 TextView_test\
 BoopsiGadget_test\
 Constraints_test\
 GroupedButtons_test\
 GT_test\
 Listview_test\
 SimpleWindow_test\
 AttrList2_test\



TypeInfo_test: TypeInfo_test.o

TypeInfo_test.o: $(TESTPRGS)environment/TypeInfo_test.cxx
	$(COMPILE)

LvObject_test: LvObject_test.o

LvObject_test.o: $(TESTPRGS)exec/LvObject_test.cxx
	$(COMPILE)

MsgPort_test: MsgPort_test.o

MsgPort_test.o: $(TESTPRGS)exec/MsgPort_test.cxx
	$(COMPILE)

SigResp_test: SigResp_test.o

SigResp_test.o: $(TESTPRGS)exec/SigResp_test.cxx
	$(COMPILE)

TimedMsgPort_test: TimedMsgPort_test.o

TimedMsgPort_test.o: $(TESTPRGS)exec/TimedMsgPort_test.cxx
	$(COMPILE)

AutoDrawArea_test: AutoDrawArea_test.o

AutoDrawArea_test.o: $(TESTPRGS)graphics/AutoDrawArea_test.cxx
	$(COMPILE)

Canvas_test: Canvas_test.o

Canvas_test.o: $(TESTPRGS)graphics/Canvas_test.cxx
	$(COMPILE)

TextView_test: TextView_test.o

TextView_test.o: $(TESTPRGS)graphics/TextView_test.cxx
	$(COMPILE)

BoopsiGadget_test: BoopsiGadget_test.o

BoopsiGadget_test.o: $(TESTPRGS)intuition/BoopsiGadget_test.cxx
	$(COMPILE)

Constraints_test: Constraints_test.o

Constraints_test.o: $(TESTPRGS)intuition/Constraints_test.cxx
	$(COMPILE)

GroupedButtons_test: GroupedButtons_test.o

GroupedButtons_test.o: $(TESTPRGS)intuition/GroupedButtons_test.cxx
	$(COMPILE)

GT_test: GT_test.o

GT_test.o: $(TESTPRGS)intuition/GT_test.cxx
	$(COMPILE)

Listview_test: Listview_test.o

Listview_test.o: $(TESTPRGS)intuition/Listview_test.cxx
	$(COMPILE)

SimpleWindow_test: SimpleWindow_test.o

SimpleWindow_test.o: $(TESTPRGS)intuition/SimpleWindow_test.cxx
	$(COMPILE)

AttrList2_test: AttrList2_test.o

AttrList2_test.o: $(TESTPRGS)utility/AttrList2_test.cxx
	$(COMPILE)
