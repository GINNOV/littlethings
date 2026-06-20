#
# GNU Makefile for the A++ Library
# Copyright (C) by Armin Vogt
#
# This makefile has been created automatically with 'makegnu'
# $Id: makegnu,v 1.2 1994/08/02 18:58:47 Armin_Vogt Exp Armin_Vogt 0
#

VPATH           =      /apphome/libsource
INCDIR          =      /appinclude
APPHEADER       =      /appinclude/APlusPlus

#
# if the Commodore® headers are not present in gcc:os-include
# define their path here..
CHEADERS        =      /include


CC      =  gcc
CFLAGS  =  -O2
AR      =  ar
RANLIB  =  ranlib

LIBRARYFILE =	libaplusplus.a

ERRORPIPE   =  pipe:gnu_errors


OBJS =  \
 APPObject.o\
 AttrList.o\
 AutoDrawArea.o\
 BoopsiGadget.o\
 Canvas.o\
 DrawArea.o\
 FontC.o\
 GadgetCV.o\
 GBorder.o\
 GraphicObject.o\
 GT_Boolean.o\
 GT_Gadget.o\
 GT_Listview.o\
 GT_Scroller.o\
 GT_String.o\
 GWindow.o\
 IntuiMessageC.o\
 IntuiObject.o\
 IntuiRoot.o\
 Intui_TypeInfo.o\
 ITransponder.o\
 List.o\
 LvObject.o\
 MapArray.o\
 MessageC.o\
 ObjectList.o\
 PriorityList.o\
 RawKeyDecoder.o\
 RectObject.o\
 RowColumnGroup.o\
 ScreenC.o\
 SignalResponder.o\
 StdGadget.o\
 TextView.o\
 TimedMsgPort.o\
 TimerC.o\
 TypeInfo.o\
 WindowCV.o\



.SUFFIXES: .o .c .cxx

.cxx.o:
	$(CC) -c -I/gcc/include -I$(INCDIR) -I$(CHEADERS) $(CFLAGS) $< >$(ERRORPIPE)


# The order of include directory declarations in crucial when
# CHEADERS is used. GNU standard headers must have a higher priority
# than the ones in the CHEADERS (usually SAS standard headers!!)

all : $(LIBRARYFILE)

$(LIBRARYFILE): $(OBJS)
	$(AR) crv $(LIBRARYFILE) $?
	$(RANLIB) $(LIBRARYFILE)



#
# A++ dependencies
#

ARexxObject.o: ARexxObject.cxx $(APPHEADER)/comm/ARexxObject.h

TimerC.o: TimerC.cxx $(APPHEADER)/devices/TimerC.h

APPObject.o: APPObject.cxx $(APPHEADER)/environment/APPObject.h

Classes.o: Classes.cxx $(APPHEADER)/environment/Classes.h

Dependencies.o: Dependencies.cxx $(APPHEADER)/environment/Dependencies.h

MapArray.o: MapArray.cxx $(APPHEADER)/environment/MapArray.h

TypeInfo.o: TypeInfo.cxx $(APPHEADER)/environment/TypeInfo.h

List.o: List.cxx $(APPHEADER)/exec/List.h

LvObject.o: LvObject.cxx $(APPHEADER)/exec/LvObject.h

MessageC.o: MessageC.cxx $(APPHEADER)/exec/MessageC.h

ObjectList.o: ObjectList.cxx $(APPHEADER)/exec/ObjectList.h

PriorityList.o: PriorityList.cxx $(APPHEADER)/exec/PriorityList.h

SignalResponder.o: SignalResponder.cxx $(APPHEADER)/exec/SignalResponder.h

TimedMsgPort.o: TimedMsgPort.cxx $(APPHEADER)/exec/TimedMsgPort.h

GT_Boolean.o: GT_Boolean.cxx $(APPHEADER)/gadtools/GT_Boolean.h

GT_Listview.o: GT_Listview.cxx $(APPHEADER)/gadtools/GT_Listview.h

GT_Scroller.o: GT_Scroller.cxx $(APPHEADER)/gadtools/GT_Scroller.h

GT_String.o: GT_String.cxx $(APPHEADER)/gadtools/GT_String.h

AutoDrawArea.o: AutoDrawArea.cxx $(APPHEADER)/graphics/AutoDrawArea.h

Canvas.o: Canvas.cxx $(APPHEADER)/graphics/Canvas.h

DrawArea.o: DrawArea.cxx $(APPHEADER)/graphics/DrawArea.h

FontC.o: FontC.cxx $(APPHEADER)/graphics/FontC.h

GBorder.o: GBorder.cxx $(APPHEADER)/graphics/GBorder.h

GraphicObject.o: GraphicObject.cxx $(APPHEADER)/graphics/GraphicObject.h

RectObject.o: RectObject.cxx $(APPHEADER)/graphics/RectObject.h

RowColumnGroup.o: RowColumnGroup.cxx $(APPHEADER)/graphics/RowColumnGroup.h

TextView.o: TextView.cxx $(APPHEADER)/graphics/TextView.h

BoopsiGadget.o: BoopsiGadget.cxx $(APPHEADER)/intuition/BoopsiGadget.h

GadgetCV.o: GadgetCV.cxx $(APPHEADER)/intuition/GadgetCV.h

GT_Gadget.o: GT_Gadget.cxx $(APPHEADER)/intuition/GT_Gadget.h

GWindow.o: GWindow.cxx $(APPHEADER)/intuition/GWindow.h

IntuiMessageC.o: IntuiMessageC.cxx $(APPHEADER)/intuition/IntuiMessageC.h

IntuiObject.o: IntuiObject.cxx $(APPHEADER)/intuition/IntuiObject.h

IntuiRoot.o: IntuiRoot.cxx $(APPHEADER)/intuition/IntuiRoot.h

Intui_TypeInfo.o: Intui_TypeInfo.cxx $(APPHEADER)/intuition/Intui_TypeInfo.h

ITransponder.o: ITransponder.cxx $(APPHEADER)/intuition/ITransponder.h

RawKeyDecoder.o: RawKeyDecoder.cxx $(APPHEADER)/intuition/RawKeyDecoder.h

ScreenC.o: ScreenC.cxx $(APPHEADER)/intuition/ScreenC.h

StdGadget.o: StdGadget.cxx $(APPHEADER)/intuition/StdGadget.h

WindowCV.o: WindowCV.cxx $(APPHEADER)/intuition/WindowCV.h

AttrList.o: AttrList.cxx $(APPHEADER)/utility/AttrList.h

