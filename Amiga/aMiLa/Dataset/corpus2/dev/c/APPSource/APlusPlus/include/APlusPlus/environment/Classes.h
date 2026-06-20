#ifndef APP_Classes_H
#define APP_Classes_H
/******************************************************************************
 **
 **   C++ Class Library for the Amiga© system software.
 **
 **   Copyright (C) 1994 by Armin Vogt  **  EMail: armin@uni-paderborn.de
 **   All Rights Reserved.
 **
 **   $VER: apphome:APlusPlus/environment/Classes.h 1.10 (27.07.94) $
 **
 ******************************************************************************/

// This file will become OBSOLETE soon!

/*******************************************************************************

   
 *******************************************************************************/

#define CLASSBASE 0x00000000

// APlusPlus classes below
#define SIGRESPONDER_CLASS (CLASSBASE+0x00000300)
#define MSGRESPONDER_CLASS (CLASSBASE+0x00000400)
#define TIMER_CLASS        (CLASSBASE+0x00000600)

/** IntuiObjects have the second bit from the left set. This seperates them
 ** from other APPObjects. An IntuiObject uses the remaining bits in a special
 ** way (see IntuiObject.h) but validation checking with Ok() still works.
 **/
#define INTUIOBJECT_CLASS  (0x40000000)

#define USERCLASS (CLASSBASE+0x00008000)
// user defined classes below



#define TAGLIST struct TagItem *taglist
#define VARTAGS ULONG tag1Type,...
#define TAG1ADR (struct TagItem*)&tag1Type
#endif
