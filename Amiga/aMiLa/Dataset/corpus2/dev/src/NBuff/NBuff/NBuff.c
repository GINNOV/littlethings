/*==========================================================================
NBUFF.C
Three helpful routines to allow double-buffering of views, using an
Intuition window as one of the buffers.  Triple-buffering, N-buffering
(subject to memory limitations), is also supported.  Compiler defines can be
used to make use of the layers library and also to bypass the "Intuition-
friendly" method of switching displays. 

Version:          2.2

Author:           Alex Matulich
Copyright 1992 by Unicorn Research Corporation
                  4621 N. Landmark Drive
                  Orlando, FL, 32817-1235
                  (407) 657-4974
Email:            Internet: alex@bilver.oau.org
                            alex%bilver@peora.sdc.ccur.com
                  UUCP:     alex@bilver.uucp
                  Fido:     1:363/140 username "Alex Matulich"

============================================================================

This program is not in the public domain, but it may be freely copied
and distributed for no charge providing this header is included.
Legal disclaimer:  Use this code at your own risk!

NBuff.c compiles with no warnings nor errors using SAS Amiga C 5.10b, or
SAS Amiga C 6.2.

You may pass the following optional definitions to the compiler:

   FASTNBUFF -    Directly manipulate copper to switch views.  This is very
               fast, but Intuition doesn't like it.  If the user presses
               left-Amiga-M or -N during FASTNBUFF buffering, the computer
               can crash; otherwise this mode causes absolutely no problems.
                  If FASTNBUFF is not defined, the Intuition-friendlier
               RethinkDisplay() will be used to switch views.

   NOLAYERS  -    Disable the layers library, use the basic RastPorts.  No
               clipping will be done in your views, and you have to be sure
               that anything you render will stay within the RastPort
               bounds, or the computer WILL crash.
                  If NOLAYERS is *not* defined, then each view buffer is
               associated with a simple-refresh backdrop layer.  This will
               provide your RastPorts with automatic clipping (and prevent
               crashes) when you draw outside the bitmap boundaries.  You
               must open layers.library as LayersBase before calling
               InitNBuff(), if you don't define NOLAYERS.

ACKNOWLEGEMENTS:  This code is a completely rewritten version of DBuff.c
by Andrew C. R. Martin of SciTech Software in Europe.  The separate Demo
program is only slightly modified from Mr. Martin's original version.
DBuff had some problems which prompted me to write this (see the revision
history below).

============================================================================

Description:
------------
   These routines set up, manipulate, and tidy up for N-buffered
   animation using an Intuition Screen and Window

Usage:
------
   3 simple routines are supplied:

>  RastPort = (struct RastPort *)InitNBuff(Screen,depth,Window,n)
   --------------------------------------------------------------
   Given the Screen and Window, this routine returns a pointer to RastPort n.
   n=0 indicates the window's RastPort, and the Intuition copper lists will
   be initialized, but no rastport will be allocated.  A pointer to the
   Window RastPort is returned.  The first time this function is called
   (after screen and window are created), n should be zero.  For n>0, a new
   RastPort and BitMaps (or Layers), and copper lists will be allocated and
   initialized, and a pointer to the new RastPort returned.  GfxBase must
   be initialized before calling this function.

>  ShowView(n)
   -----------
   Sets the required view ready for drawing. ShowView(0) shows the Intuition
   view, ShowView(n) sets alternate view n.  N-buffering is accomplished by
   drawing to one of your background RastPorts and then displaying it with
   ShowView().

>  FreeNBuff(screen,depth,rastport,n)
   ----------------------------------
   Frees up all memory associated with buffer n.  Iif n==0, only the
   intermediate copperlists are freed, and nothing else.  The 0 buffer
   buffer belongs to Intuition, and Intuition will free it with
   CloseWindow() and CloseScreen().

Two additional internal functions are supplied which you may find useful:

>  getBitMap(width,height,depth,clear)
   -----------------------------------
   Allocates a bitmap, optionally clears it, and returns a pointer to it,
   or NULL if the allocation failed.

>  freeBitMap(BitMap)
   ------------
   Frees a bitmap.  A NULL pointer may be passed.

Notes:
------
   1. Assumes both graphics and intuition libraries are already open.
   2. Assumes the layers library is open if NOLAYERS was not defined
      at compile time.
   3. Preferably, the window should be BORDERLESS and have a null title.
   4. Link with NBuffDemo to see the demonstration.  You can do this with
      SAS Amiga C 5.10b with the following command:
      lc -L NBuffDemo NBuff
      or with SAS Amiga C 6.2:
      sc link NBuffDemo NBuff

============================================================================

Revision history:
-----------------
   1.0 - DBuff - Original inspiration from Andrew C. R. Martin of SciTech
         Software.  It did not actually switch views unless you used the
         debugger (easy to check by clearing one RastPort to another color
         in the Demo and watching what happens).  Compiled w/many warnings
         using SAS Amiga C 5.10b, MrgCop() was being used improperly, only
         one set of copper lists were being initialized although 3 were
         declared, intermediate copperlists were not being freed, etc.
         This program was a great teacher for me.
   2.0 - Separated demo-related things from the actual buffer handling.
         Completely re-wrote DBuff handling functions (reduced necessary
         functions to 3).
   2.1 - Modified software to handle any number of buffers (I needed to do
         quadruple buffering in an application).  Renamed to NBuff.
   2.11- Fixed bug that ate up a few hundred bytes more memory each time
         the program terminated (only the hardware copper lists were being
         freed, and not the intermediate ones).
   2.12- Improved on, but not fixed, a bug that resulted in a corrupt
         memory list lockup if the user used left-Amiga-M or left-Amiga-N
         to toggle the Workbench screen in and out while the program runs.
   2.13- Fixed the bug above by using the Intuition-friendly-but-slow
         RethinkDisplay() to switch views.  Introduced the FASTNBUFF
         compiler definition to retain the old faster method of 2.12.
   2.2 - Added layers library support so that anything rendered to the
         video buffers will be clipped automatically, preventing potential
         catastrophic crashes.  Introduced the NOLAYERS compiler definition
         to do things the old way, which conserves some memory.

===========================================================================*/

#define NBUFF_C
#include "NBuff.h"


//==========================================================================
// Global Amiga system variables
// Note: The constant NBUFS is typically 2, for double buffering.
//       This constant is set in NBuff.h.  Hardly any extra memory is
//       needed if NBUFS is larger than 2 - memory is only used according
//       to the number of times you call InitNBuff().
//==========================================================================

#ifdef FASTNBUFF
struct cprlist    *NB_LOF[NBUFS],         // copperlist ptrs in View struct
                  *NB_SHF[NBUFS];
#endif

struct Screen     *NB_screen;
struct RasInfo    *NB_rinfo = NULL;       // Intuition supplied rasinfo
struct BitMap     *NB_bmap[NBUFS];        // Bitmaps (0 is Intuition-supplied)
struct View       *NB_view = NULL;        // Intuition View
struct ViewPort   *NB_vp = NULL;          // Intuition ViewPort

#ifndef NOLAYERS
struct Layer_Info *NB_layerinfo[NBUFS];   // Layer description
struct Layer      *NB_layer[NBUFS];       // layer array
#endif

extern struct GfxBase *GfxBase;


//==========================================================================
// INITNBUFF
// Initialize a new buffer, and return a pointer to the new RastPort.
// n may range from 0 to NBUFS-1.  Call this function for each buffer you
// have, including your Intuition window.  This function assumes that a
// screen of DEPTH bitplanes is already opened, and a window is on it.
// n should be 0 the first time you call this function.
//==========================================================================
struct RastPort *InitNBuff(struct Screen *screen,
          short depth, struct Window *window, short n)
{
struct RastPort *rport = NULL;  // RastPort pointer to return
short err = 0;

if (!n) {  // If Intuition buffer data is not yet initialized...
   rport = window->RPort;
   NB_bmap[0] = rport->BitMap;
   NB_screen = screen;
   NB_view = GfxBase->ActiView;
   NB_vp = &screen->ViewPort;
   NB_rinfo = NB_vp->RasInfo;
   // --> the line above also makes NB_rinfo->BitMap == rport->Bitmap <--
   MakeScreen(screen);   // Intuition-integrated MakeVPort() for copperlists
   RethinkDisplay();
#ifdef FASTNBUFF
   NB_LOF[0] = NB_view->LOFCprList;  // save Intuition lo-res copper list
   NB_SHF[0] = NB_view->SHFCprList;  // save Intuition hi-res copper list
#endif
   return rport;
   }

// ...otherwise, allocate another bitmap & memory for bitplanes

#ifndef NOLAYERS
if (!(NB_layerinfo[n] = NewLayerInfo())) return NULL;
#endif

if (!(NB_bmap[n] = getBitMap(screen->Width, screen->Height, depth, 1)))
   goto NBInit_done;

// Create a rastport or layer for this bitmap to simplify drawing

#ifdef NOLAYERS
if (!(rport = (struct RastPort *)
         AllocMem(sizeof(struct RastPort), MEMF_PUBLIC))) {
   err = 3;
   goto NBInit_done;
   }
InitRastPort(rport);
rport->BitMap = NB_bmap[n];

#else   // if we're using the Layers library...

if (!(NB_layer[n] = CreateBehindLayer(NB_layerinfo[n], NB_bmap[n],
                      0L, 0L, screen->Width-1, screen->Height-1,
                      LAYERSIMPLE | LAYERBACKDROP, NULL))) {
   err = 4;
   goto NBInit_done;
   }
rport = NB_layer[n]->rp;
#endif

SetRast(rport, 0);   // clear this view

// set up for N-buffering (initialize copperlists) - FASTNBUFF only

#ifdef FASTNBUFF  // the rest is needed if we're Intuition-UNfriendly...
NB_LOF[n] = NB_view->LOFCprList = NULL;  // reset view copperlists to NULL
NB_SHF[n] = NB_view->SHFCprList = NULL;

NB_rinfo->BitMap = NB_bmap[n];           // set new bitmap to display
MakeVPort(NB_view, NB_vp);               // build intermediate copper lists
MrgCop(NB_view);                         // build final copper lists
LoadView(NB_view);                       // execute the coppper instructions
                                         // at next VBeam blank inerval
NB_LOF[n] = NB_view->LOFCprList;   // now save new copper lists for new view
NB_SHF[n] = NB_view->SHFCprList;

// ...and that's it!  We now have all we need to switch views: a set of
// copper lists NB_LOF[] and NB_SHF[], and a bitmap pointer NB_rinfo->BitMap!

NB_rinfo->BitMap = NB_bmap[0];  // restore Intuition BitMap
ShowView(0);                    // show the Intuition RastPort
#endif

NBInit_done:
if (err) FreeNBuff(screen, depth, rport, n);
return rport;
}


//=========================================================================
// GETBITMAP
// Allocate a bitmap according to the dimensions provided, clear it if
// clear is nonzero, and return a pointer to the bitmap.  NULL is returned
// if the bitmap couldn't be created.
//=========================================================================
struct BitMap *getBitMap(int wide, int high, int deep, short clear)
{
register short i;
struct BitMap *bitmap;
if (!(bitmap = (struct BitMap *)
               AllocMem(sizeof(struct BitMap), MEMF_PUBLIC|MEMF_CLEAR)))
   goto bitmaperr;
InitBitMap(bitmap, deep, wide, high);
for (i = 0; i < deep; i++) {
   if (!(bitmap->Planes[i] = (PLANEPTR)AllocRaster(wide, high)))
      goto bitmaperr;
   if (clear) BltClear(bitmap->Planes[i], RASSIZE(wide, high), 0);
   }
return bitmap;

bitmaperr:
freeBitMap(bitmap);
return NULL;
}


//==========================================================================
// FREEBITMAP
// Deallocate a bitmap structure, with all its bitplanes.
//==========================================================================
void freeBitMap(struct BitMap *bm)
{
short j;
if (bm) {
   for (j = 0; j < bm->Depth; j++)
      if (bm->Planes[j])
         FreeRaster(bm->Planes[j], bm->BytesPerRow << 3, bm->Rows);
   FreeMem(bm, sizeof(struct BitMap));
   }
}


//==========================================================================
// ShowView
// Program the copper with the appropriate lists, set the bitmap pointer to
// buffer n, and display the new view.  The new view will be displayed
// during the next CRT vertical blanking interval.
// NOTE:  When debugging, the view will switch when the new bitmap is set,
// and not when LoadView() is called.  Don't be fooled into thinking that
// this means you don't need LoadView()!  If you remove the LoadView() call,
// the view will NOT switch when run without the debugger.
//==========================================================================
void ShowView(register short n)
{
#ifdef FASTNBUFF

NB_view->LOFCprList = NB_LOF[n];  // set lo-res copper list
NB_view->SHFCprList = NB_SHF[n];  // set hi-res copper list
// you may want to call to WaitTOF() here to sync with the CRT vblank.
LoadView(NB_view);                // cause copper to show new view

#else   // if not using FASTNBUFF, then be slow but Intuition-friendly

NB_screen->RastPort.BitMap = NB_rinfo->BitMap = NB_bmap[n];
MakeScreen(NB_screen);
RethinkDisplay();  // automatically calls WaitTOF()

#endif
}


//==========================================================================
// FREENBUFF
// Free everything associated with a display buffer.
// This function will ignore a call to free buffer 0, because buffer 0 and
// its associated structures all belong to Intuition, which will take care
// of everything when the screen and window are finally closed.  You SHOULD
// call this routine to free buffer 0 so that the intermediate copperlists
// will be freed, escpecially if you defined FASTNBUFF!
// The value n MUST be associated with the correct RastPort rp!!
//==========================================================================
void FreeNBuff(struct Screen *screen, short depth, struct RastPort *rp, short n)
{
if (!n) {
   // Deallocate all intermediate copper lists for this viewport.
   // This may not be necessary if FASTNBUFF was not specified, but it
   // doesn't hurt to do it anyway.
   // NOT calling FreeVPortCopLists() may result in a few hundred bytes of
   // memory loss each time your program is run.
   FreeVPortCopLists(NB_vp);
   return;
   }

// Ensure we're on the Intuition-supplied bitmap before exiting
ShowView(0);
WaitTOF();

// Free up the nth rastport or layer
#ifdef NOLAYERS
if (rp) FreeMem(rp, sizeof(struct RastPort));
#else
if (NB_layer[n]) DeleteLayer(0L, NB_layer[n]);
if (NB_layerinfo[n]) DisposeLayerInfo(NB_layerinfo[n]);
#endif

freeBitMap(NB_bmap[n]);  // Free up the nth bitmap

// Free up the copper lists - FASTNBUFF only

#ifdef FASTNBUFF
FreeCprList(NB_LOF[n]);
FreeCprList(NB_SHF[n]);
#endif
}
