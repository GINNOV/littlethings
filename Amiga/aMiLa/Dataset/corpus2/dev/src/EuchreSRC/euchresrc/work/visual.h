/** $Revision Header *** Header built automatically - do not edit! ***********
 **
 ** © Copyright ???
 **
 ** File             : visual.h
 ** Created on       : Thursday, 07-Aug-97
 ** Created by       : Rick Keller
 ** Current revision : V 1.03
 **
 ** Purpose
 ** -------
 **   Screen colors, menu structure, and pen array
 **
 ** Date        Author                 Comment
 ** =========   ====================   ====================
 ** 29-Aug-97   Rick Keller            changed Help on menu to Debug
 ** 29-Aug-97   Rick Keller            added #define ENDP to eliminate warning during compile
 ** 07-Aug-97   Rick Keller            textpen changed for easier readability
 ** 07-Aug-97   Rick Keller            --- Initial release ---
 **
 ** $Revision Header *********************************************************/
//visual.h

#include "gamesetup.h"

#define ENDP ((UWORD)~0)

struct ColorSpec EuchreColors[] =
{
    {0,0x11,0x77,0x00},
    {1,0x0,0x0,0x0},
    {2,0xff,0xff,0xff},     //color table for custom screen
    {3,0xff,0x0,0x0},
    {4,0xc1,0xf4,0x0},
    {5,0x0,0x0,0xb8},
    {6,0xee,0xbb,0x0},
    {7,0x0,0x88,0x0},
    {8,0x66,0xbb,0x0},
    {9,0xe0,0xe0,0xe0},
    {10,0x3e,0x2a,0xcc},
    {11,0x33,0x66,0x77},
    {12,0x0,0x77,0xbb},
    {13,0x0,0x44,0x88},
    {14,0xee,0x88,0x88},
    {15,0xbb,0x55,0x55},
    {-1,0x00,0x00,0x00}
};

#ifdef BETA_VERSION
struct NewMenu EuchreMenu[] =
{
    { NM_TITLE,     "Euchre!",      0,  0,  0,  0, },
    {   NM_ITEM,   "New Game",     "N", 0,  0,  0, },
    {   NM_ITEM,   "Settings",     "S", 0,  0,  0, },
    {   NM_ITEM,   NM_BARLABEL,     0,  0,  0,  0, },
    {   NM_ITEM,   "About...",     "A", 0,  0,  0, },
    {   NM_ITEM,   NM_BARLABEL,     0,  0,  0,  0, },
    {   NM_ITEM,    "Debug",        0,  CHECKIT,0, 0, },
    {   NM_ITEM,   NM_BARLABEL,     0,  0,  0,  0, },
    {   NM_ITEM,   "Quit",         "Q", 0,  0,  0, },
    {   NM_END,    NULL,           0,  0,  0,  0, },
};

#endif

#ifndef BETA_VERSION
struct NewMenu EuchreMenu[] =
{
    { NM_TITLE,     "Euchre!",      0,  0,  0,  0, },
    {   NM_ITEM,   "New Game",     "N", 0,  0,  0, },
    {   NM_ITEM,   "Settings",     "S", 0,  0,  0, },
    {   NM_ITEM,   NM_BARLABEL,     0,  0,  0,  0, },
    {   NM_ITEM,   "About...",     "A", 0,  0,  0, },
    {   NM_ITEM,   NM_BARLABEL,     0,  0,  0,  0, },
    {   NM_ITEM,   "Quit",         "Q", 0,  0,  0, },
    {   NM_END,    NULL,           0,  0,  0,  0, },
};

#endif

UWORD pens[] = {1,9,9,9,1,15,9,0,9,ENDP};//set own pen defs for screen

