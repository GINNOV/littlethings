/* Layers.c
**
** SAS/C 5.10a
** lc -b1 -cfist -v -y layers
** blink FROM LIB:c.o layers.o TO layers LIB LIB:lc.lib LIB:amiga.lib


Copyright (c) 1992 Commodore-Amiga, Inc.

This example is provided in electronic form by Commodore-Amiga, Inc. for
use with the "Amiga ROM Kernel Reference Manual: Libraries", 3rd Edition,
published by Addison-Wesley (ISBN 0-201-56774-1).

The "Amiga ROM Kernel Reference Manual: Libraries" contains additional
information on the correct usage of the techniques and operating system
functions presented in these examples.  The source and executable code
of these examples may only be distributed in free electronic form, via
bulletin board or as part of a fully non-commercial and freely
redistributable diskette.  Both the source and executable code (including
comments) must be included, without modification, in any copy.  This
example may not be published in printed form or distributed with any
commercial product.  However, the programming techniques and support
routines set forth in these examples may be used in the development
of original executable software products for Commodore Amiga computers.

All other rights reserved.

This example is provided "as-is" and is subject to change; no
warranties are made.  All use is at your own risk. No liability or
responsibility is assumed.
*/

/* Force use of new variable names to help prevent errors */
#define INTUI_V36_NAMES_ONLY

#include <exec/types.h>
#include <graphics/gfxbase.h>
#include <graphics/layers.h>
#include <graphics/displayinfo.h>

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/graphics_protos.h>
#include <clib/layers_protos.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef LATTICE
int CXBRK(void)    { return(0); }  /* Disable Lattice CTRL/C handling */
int chkabort(void) { return(0); }  /* really */
#endif

#define L_DELAY  (100)
#define S_DELAY   (50)

#define DUMMY      (0L)

#define RED_PEN    (1)
#define GREEN_PEN  (2)
#define BLUE_PEN   (3)

#define SCREEN_D   (2)
#define SCREEN_W (320)
#define SCREEN_H (200)

/* the starting size of example layers, offsets are used for placement */
#define W_H (50)
#define W_T (5)
#define W_B ((W_T+W_H)-1)
#define W_W (80)
#define W_L ((SCREEN_W/2) - (W_W/2))
#define W_R ((W_L+W_W)-1)

/* size of the superbitmap */
#define SUPER_H SCREEN_H
#define SUPER_W SCREEN_W

/* starting size of the message layer */
#define M_H (10)
#define M_T (SCREEN_H-M_H)
#define M_B ((M_T+M_H)-1)
#define M_W (SCREEN_W)
#define M_L (0)
#define M_R ((M_L+M_W)-1)

struct GfxBase *GfxBase;
struct Library *LayersBase;

/* global constant data for initializing the layers */
LONG  theLayerFlags[3] = { LAYERSUPER, LAYERSMART, LAYERSIMPLE };
UWORD colortable[]     = { 0x000, 0xf44, 0x4f4, 0x44f };


/*
** Clear the layer then draw in a text string.
*/
VOID myLabelLayer(struct Layer *layer, LONG color, UBYTE *string)
{
/* fill layer with color */
SetRast(layer->rp, color);

/* set up for writing text into layer */
SetDrMd(layer->rp,JAM1);
SetAPen(layer->rp,0);
Move(layer->rp, 5, 7);

/* write into layer */
Text(layer->rp, string, strlen(string));
}



/*
** write a message into a layer with a delay.
*/
VOID pMessage(struct Layer *layer, UBYTE *string)
{
Delay(S_DELAY);
myLabelLayer(layer, GREEN_PEN, string);
}

/*
** write an error message into a layer with a delay.
*/
VOID error(struct Layer *layer, UBYTE *string)
{
myLabelLayer(layer, RED_PEN, string);
Delay(L_DELAY);
}



/*
** do some layers manipulations to demonstrate their abilities.
*/
VOID doLayers(struct Layer *msgLayer, struct Layer *layer_array[])
{
WORD ktr;
WORD ktr_2;

pMessage(msgLayer, "Label all Layers");
myLabelLayer(layer_array[0], RED_PEN,   "Super");
myLabelLayer(layer_array[1], GREEN_PEN, "Smart");
myLabelLayer(layer_array[2], BLUE_PEN,  "Simple");

pMessage(msgLayer, "MoveLayer 1 InFrontOf 0");
if (!MoveLayerInFrontOf(layer_array[1], layer_array[0]))
    error(msgLayer, "MoveLayerInFrontOf() failed.");

pMessage(msgLayer, "MoveLayer 2 InFrontOf 1");
if (!MoveLayerInFrontOf(layer_array[2], layer_array[1]))
    error(msgLayer, "MoveLayerInFrontOf() failed.");

pMessage(msgLayer, "Refresh Simple Refresh Layer");
myLabelLayer(layer_array[2], BLUE_PEN, "Simple");

pMessage(msgLayer, "Incrementally MoveLayers...");
for(ktr = 0; ktr < 30; ktr++)
    {
    if (!MoveLayer(DUMMY, layer_array[1], -1, 0))
        error(msgLayer, "MoveLayer() failed.");
    if (!MoveLayer(DUMMY, layer_array[2], -2, 0))
        error(msgLayer, "MoveLayer() failed.");
    }

pMessage(msgLayer, "Refresh Simple Refresh Layer");
myLabelLayer(layer_array[2], BLUE_PEN, "Simple");

pMessage(msgLayer, "make Layer 0 the UpfrontLayer");
if (!UpfrontLayer(DUMMY, layer_array[0]))
    error(msgLayer, "UpfrontLayer() failed.");

pMessage(msgLayer, "make Layer 2 the BehindLayer");
if (!BehindLayer(DUMMY, layer_array[2]))
    error(msgLayer, "BehindLayer() failed.");

pMessage(msgLayer, "Incrementally MoveLayers again...");
for(ktr = 0; ktr < 30; ktr++)
    {
    if (!MoveLayer(DUMMY, layer_array[1], 0, 1))
        error(msgLayer, "MoveLayer() failed.");
    if (!MoveLayer(DUMMY, layer_array[2], 0, 2))
        error(msgLayer, "MoveLayer() failed.");
    }

pMessage(msgLayer, "Refresh Simple Refresh Layer");
myLabelLayer(layer_array[2], BLUE_PEN, "Simple");

pMessage(msgLayer, "Big MoveLayer");
for(ktr = 0; ktr < 3; ktr++)
    {
    if (!MoveLayer(DUMMY, layer_array[ktr], -layer_array[ktr]->bounds.MinX, 0))
        error(msgLayer, "MoveLayer() failed.");
    }


pMessage(msgLayer, "Incrementally increase size");
for(ktr = 0; ktr < 5; ktr++)
    {
    for(ktr_2 = 0; ktr_2 < 3; ktr_2++)
        {
        if (!SizeLayer(DUMMY, layer_array[ktr_2], 1, 1))
            error(msgLayer, "SizeLayer() failed.");
        }
    }

pMessage(msgLayer, "Refresh Smart Refresh Layer");
myLabelLayer(layer_array[1], GREEN_PEN, "Smart");
pMessage(msgLayer, "Refresh Simple Refresh Layer");
myLabelLayer(layer_array[2], BLUE_PEN,  "Simple");

pMessage(msgLayer, "Big SizeLayer");
for(ktr = 0; ktr < 3; ktr++)
    {
    if (!SizeLayer(DUMMY,layer_array[ktr],
                SCREEN_W-(layer_array[ktr]->bounds.MaxX)-1,0))
        error(msgLayer, "SizeLayer() failed.");
    }

pMessage(msgLayer, "Refresh Smart Refresh Layer");
myLabelLayer(layer_array[1], GREEN_PEN, "Smart");
pMessage(msgLayer, "Refresh Simple Refresh Layer");
myLabelLayer(layer_array[2], BLUE_PEN,  "Simple");

pMessage(msgLayer, "ScrollLayer down");
for(ktr = 0; ktr < 30; ktr++)
    {
    for(ktr_2 = 0; ktr_2 < 3; ktr_2++)
        {
        ScrollLayer(DUMMY, layer_array[ktr_2], 0, -1);
        }
    }

pMessage(msgLayer, "Refresh Smart Refresh Layer");
myLabelLayer(layer_array[1], GREEN_PEN, "Smart");
pMessage(msgLayer, "Refresh Simple Refresh Layer");
myLabelLayer(layer_array[2], BLUE_PEN,  "Simple");

pMessage(msgLayer, "ScrollLayer up");
for(ktr = 0; ktr < 30; ktr++)
    {
    for(ktr_2 = 0; ktr_2 < 3; ktr_2++)
        {
        ScrollLayer(DUMMY, layer_array[ktr_2], 0, 1);
        }
    }

pMessage(msgLayer, "Refresh Smart Refresh Layer");
myLabelLayer(layer_array[1], GREEN_PEN, "Smart");
pMessage(msgLayer, "Refresh Simple Refresh Layer");
myLabelLayer(layer_array[2], BLUE_PEN,  "Simple");

Delay(L_DELAY);
}


/*
** delete the layer array created by allocLayers().
*/
VOID disposeLayers(struct Layer *msgLayer, struct Layer *layer_array[])
{
WORD ktr;

for (ktr = 0; ktr < 3; ktr++)
    {
    if (layer_array[ktr] != NULL)
        {
        if (!DeleteLayer(DUMMY, layer_array[ktr]))
            error(msgLayer, "Error deleting layer");
        }
    }
}


/*
** Create some hard-coded layers.  The first must be super-bitmap, with
** the bitmap passed as an argument.  The others must not be super-bitmap.
** The pointers to the created layers are returned in layer_array.
**
** Return FALSE on failure.  On a FALSE return, the layers are
** properly cleaned up.
*/
BOOL allocLayers(struct Layer *msgLayer, struct Layer *layer_array[],
    struct BitMap *super_bitmap, struct Layer_Info *theLayerInfo,
    struct BitMap *theBitMap)
{
WORD ktr;
BOOL create_layer_ok = TRUE;

for (ktr = 0;
     (ktr < 3) && (create_layer_ok);
     ktr++)
    {
    pMessage(msgLayer, "Create BehindLayer");
    if (ktr == 0)
        {
        if ((layer_array[ktr] = CreateBehindLayer(theLayerInfo, theBitMap,
                  W_L+(ktr*30), W_T+(ktr*30), W_R+(ktr*30), W_B+(ktr*30),
                  theLayerFlags[ktr], super_bitmap)) == NULL)
            create_layer_ok = FALSE;
        }
     else
        {
        if ((layer_array[ktr] = CreateBehindLayer(theLayerInfo, theBitMap,
                  W_L+(ktr*30), W_T+(ktr*30), W_R+(ktr*30), W_B+(ktr*30),
                  theLayerFlags[ktr], NULL)) == NULL)
            create_layer_ok = FALSE;
        }

    if (create_layer_ok)
        {
        pMessage(msgLayer, "Fill the RastPort");
        SetRast(layer_array[ktr]->rp, ktr + 1);
        }
    }

if (!create_layer_ok)
    disposeLayers(msgLayer, layer_array);

return(create_layer_ok);
}




/*
** Free the bitmap and all bitplanes created by allocBitMap().
*/
VOID disposeBitMap(struct BitMap *bitmap, LONG depth, LONG width, LONG height)
{
WORD ktr;

if (NULL != bitmap)
    {
    for (ktr = 0; ktr < depth; ktr++)
        {
        if (NULL != bitmap->Planes[ktr])
            FreeRaster(bitmap->Planes[ktr], width, height);
        }

    FreeMem(bitmap, sizeof(*bitmap));
    }
}







/*
** Allocate and initialize a bitmap structure.
*/
struct BitMap *allocBitMap(LONG depth, LONG width, LONG height)
{
WORD ktr;
BOOL bit_map_failed = FALSE;
struct BitMap *bitmap = NULL;

if (NULL != (bitmap = AllocMem(sizeof(*bitmap),NULL)))
    {
    InitBitMap(bitmap,depth,width,height);

    for (ktr = 0; ktr < depth; ktr++)
        {
        if (NULL == (bitmap->Planes[ktr] = (PLANEPTR)AllocRaster(width,height)))
            bit_map_failed = TRUE;
        else
            BltClear(bitmap->Planes[ktr], RASSIZE(width,height), 1);
        }
    if (bit_map_failed)
        {
        disposeBitMap(bitmap,depth,width,height);
        bitmap = NULL;
        }
    }
return(bitmap);
}

/*
** Set up to run the layers example, doLayers(). Clean up when done.
*/
VOID startLayers(struct Layer_Info *theLayerInfo, struct BitMap *theBitMap)
{
struct Layer  *msgLayer;
struct BitMap *theSuperBitMap;
struct Layer  *theLayers[3] = { NULL, NULL, NULL, };

if (NULL != (msgLayer = CreateUpfrontLayer(theLayerInfo, theBitMap,
                     M_L, M_T, M_R, M_B, LAYERSMART, NULL)))
    {
    pMessage(msgLayer, "Setting up Layers");

    if (NULL != (theSuperBitMap = allocBitMap(SCREEN_D, SUPER_W, SUPER_H)))
        {
        if (allocLayers(msgLayer, theLayers, theSuperBitMap, theLayerInfo, theBitMap))
            {
            doLayers(msgLayer, theLayers);

            disposeLayers(msgLayer, theLayers);
            }
        disposeBitMap(theSuperBitMap, SCREEN_D, SUPER_W, SUPER_H);
        }
    if (!DeleteLayer(DUMMY, msgLayer))
        error(msgLayer, "Error deleting layer");
    }
}

/*
** Set up a low-level graphics display for layers to work on.  Layers
** should not be built directly on Intuition screens, use a low-level
** graphics view.  If you need mouse or other events for the layers
** display, you have to get them directly from the input device.  The
** only supported method of using layers library calls with Intuition
** (other than the InstallClipRegion() call) is through Intuition windows.
**
** See graphics primitives chapter for details on creating and using the
** low-level graphics calls.
*/
VOID runNewView(VOID)
{
struct View        theView;
struct View       *oldview;
struct ViewPort    theViewPort;
struct RasInfo     theRasInfo;
struct ColorMap   *theColorMap;
struct Layer_Info *theLayerInfo;
struct BitMap     *theBitMap;
UWORD             *colorpalette;
WORD               ktr;

/* save current view, to be restored when done */
if (NULL != (oldview = GfxBase->ActiView))
    {
    /* get a LayerInfo structure */
    if (NULL != (theLayerInfo = NewLayerInfo()))
        {
        if (NULL != (theColorMap = GetColorMap(4)))
            {
            colorpalette = (UWORD *)theColorMap->ColorTable;
            for(ktr = 0; ktr < 4; ktr++)
                *colorpalette++ = colortable[ktr];

            if (NULL != (theBitMap = allocBitMap(SCREEN_D, SCREEN_W, SCREEN_H)))
                {
                InitView(&theView);
                InitVPort(&theViewPort);

                theView.ViewPort = &theViewPort;

                theViewPort.DWidth   = SCREEN_W;
                theViewPort.DHeight  = SCREEN_H;
                theViewPort.RasInfo  = &theRasInfo;
                theViewPort.ColorMap = theColorMap;

                theRasInfo.BitMap   = theBitMap;
                theRasInfo.RxOffset = 0;
                theRasInfo.RyOffset = 0;
                theRasInfo.Next     = NULL;

                MakeVPort(&theView, &theViewPort);
                MrgCop(&theView);
                LoadView(&theView);
                WaitTOF();

                startLayers(theLayerInfo, theBitMap);

                /* put back the old view, wait for it to become
                ** active before freeing any of our display
                */
                LoadView(oldview);
                WaitTOF();

                /* free dynamically created structures */
                FreeVPortCopLists(&theViewPort);
                FreeCprList(theView.LOFCprList);

                disposeBitMap(theBitMap, SCREEN_D, SCREEN_W, SCREEN_H);
                }
            FreeColorMap(theColorMap);       /* free the color map */
            }
        DisposeLayerInfo(theLayerInfo);
        }
    }
}

/*
** Open the libraries used by the example.  Clean up when done.
*/
VOID main(int argc, char **argv)
{
if (NULL != (GfxBase = (struct GfxBase *)OpenLibrary("graphics.library",33L)))
    {
    if (NULL != (LayersBase = OpenLibrary("layers.library",33L)))
        {
        runNewView();

        CloseLibrary((struct Library *)LayersBase);
        }
    CloseLibrary((struct Library *)GfxBase);
    }
}