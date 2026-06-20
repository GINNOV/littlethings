/*
 * (c) Copyright 1995, Silicon Graphics, Inc.
 * ALL RIGHTS RESERVED
 * Permission to use, copy, modify, and distribute this software for
 * any purpose and without fee is hereby granted, provided that the above
 * copyright notice appear in all copies and that both the copyright notice
 * and this permission notice appear in supporting documentation, and that
 * the name of Silicon Graphics, Inc. not be used in advertising
 * or publicity pertaining to distribution of the software without specific,
 * written prior permission.
 *
 * THE MATERIAL EMBODIED ON THIS SOFTWARE IS PROVIDED TO YOU "AS-IS"
 * AND WITHOUT WARRANTY OF ANY KIND, EXPRESS, IMPLIED OR OTHERWISE,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF MERCHANTABILITY OR
 * FITNESS FOR A PARTICULAR PURPOSE.  IN NO EVENT SHALL SILICON
 * GRAPHICS, INC.  BE LIABLE TO YOU OR ANYONE ELSE FOR ANY DIRECT,
 * SPECIAL, INCIDENTAL, INDIRECT OR CONSEQUENTIAL DAMAGES OF ANY
 * KIND, OR ANY DAMAGES WHATSOEVER, INCLUDING WITHOUT LIMITATION,
 * LOSS OF PROFIT, LOSS OF USE, SAVINGS OR REVENUE, OR THE CLAIMS OF
 * THIRD PARTIES, WHETHER OR NOT SILICON GRAPHICS, INC.  HAS BEEN
 * ADVISED OF THE POSSIBILITY OF SUCH LOSS, HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, ARISING OUT OF OR IN CONNECTION WITH THE
 * POSSESSION, USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 * US Government Users Restricted Rights
 * Use, duplication, or disclosure by the Government is subject to
 * restrictions set forth in FAR 52.227.19(c)(2) or subparagraph
 * (c)(1)(ii) of the Rights in Technical Data and Computer Software
 * clause at DFARS 252.227-7013 and/or in similar or successor
 * clauses in the FAR or the DOD or NASA FAR Supplement.
 * Unpublished-- rights reserved under the copyright laws of the
 * United States.  Contractor/manufacturer is Silicon Graphics,
 * Inc., 2011 N.  Shoreline Blvd., Mountain View, CA 94039-7311.
 *
 * Author: John Spitzer, SGI Applied Engineering
 *
 */

#if (defined(INC_REASON)) && (INC_REASON == INFO_ITEM_STRUCT)
#include "Primitve.h"
    int rasterPosDim;   /* Dimension of vertex data (i.e. 2 or 3 D) [2, 3]   */
    float clipAmount;
    int clipMode;
    int drawOrder;
    /* Variables below this line are not user settable */
    int numDrawn;
    GLint *subImageData;
    void **imageData;
    /* Member functions */
    /* void Execute(TestPtr);   */                /* virtual function */
    /* int SetState(TestPtr);  */                 /* virtual function */
    /* void (*SetExecuteFunc)(TestPtr); */        /* virtual function */
#elif (defined(INC_REASON)) && (INC_REASON == INFO_ITEM_ARRAY)
#include "Primitve.h"
    {
        RasterPosDim,
        "Dimension of RasterPos Data",
        offset(rasterPosDim),
        RangedInteger,
        {
#ifdef FULL_RASTERPOS_PATHS
            { 2 },
#else
	    { 3 },
#endif
            { 3 },
        },
        { 3 }
    },
    {
        ColorData,
        "Color/Index Data",
        offset(colorData),
        Enumerated,
        {
            { None,                     "None" },
            { PerRasterPos,             "PerRasterPos" },
            { End }
        },
        { None }
    },
    {
        TexData,
        "Texture Coordinate Data",
        offset(textureData),
        Enumerated,
        {
            { None,                     "None" },
            { PerRasterPos,             "PerRasterPos" },
            { End }
        },
        { None }
    },
    {
        ClipAmount,
        "Amount of Image/Bitmap/Text that is Clipped",
        offset(clipAmount),
        RangedFloat,
        {
	   { 0.0 },
	   { 1.0 }
        },
        { NotUsed, 0.5 }
    },
    {
        ClipMode,
        "Manner in which Image/Bitmap/Text is Clipped",
        offset(clipMode),
        Enumerated,
        {
            { Horizontal,		"Horizontal" },
            { Vertical,			"Vertical" },
            { Random,			"Random" },
            { End }
        },
        { Random }
    },
    {
        DrawOrder,
        "Order in which Images/Bitmaps/Text are Drawn",
        offset(drawOrder),
        Enumerated,
        {
            { Serial,			"Serial" },
            { Spaced,			"Spaced" },
            { End }
        },
        { Spaced }
    },

#else  /* INC_REASON not defined, treat as plain include */
#ifndef _RastrPos_h
#define _RastrPos_h

#include "Primitve.h"
#include "General.h"
#include "Print.h"
#include "TestName.h"
#include "PropName.h"
#include "Global.h"
#include "AttrName.h"
#ifdef WIN32
#include <windows.h>
#endif
#include <GL/gl.h>
#include <GL/glu.h>
#include "Random.h"
#include "FuncEnum.h"

typedef struct _RasterPos {
#define INC_REASON INFO_ITEM_STRUCT
#include "RastrPos.h"
#undef INC_REASON
} RasterPos, *RasterPosPtr;

void new_RasterPos(RasterPosPtr);
void delete_RasterPos(TestPtr);
void RasterPos__AddTraversalData(RasterPosPtr);
int RasterPos__SetState(TestPtr);

#endif /* file not already included */
#endif /* INC_REASON not defined */
