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
#include "RastrPos.h"
    int bitmapWidth;
    int bitmapHeight;
    /* Variables below this line aren't user settable */
    int subImage;
    /* Member functions */
    /* void Initialize(TestPtr); */               /* virtual function */
    /* void Execute(TestPtr);   */                /* virtual function */
    /* int SetState(TestPtr);  */                 /* virtual function */
    /* float PixelSize(TestPtr);  */              /* virtual function */
    /* int TimesRun(TestPtr);  */               /* virtual function */
    /* void (*SetExecuteFunc)(TestPtr); */        /* virtual function */
    Image image_Bitmap;
#elif (defined(INC_REASON)) && (INC_REASON == INFO_ITEM_ARRAY)
#include "RastrPos.h"
#undef offset
#define offset(v) offsetof(Bitmap, image_Bitmap)+offsetof(Image, v)
#include "Image.h"
#undef offset
#define offset(v) offsetof(Bitmap,v)
    {
        BitmapWidth,
        "Width of Bitmap",
        offset(bitmapWidth),
        RangedInteger,
        {
            { 1 },
            { 2048 },
        },
        { -1 }
    },
    {
        BitmapHeight,
        "Height of Bitmap",
        offset(bitmapHeight),
        RangedInteger,
        {
            { 1 },
            { 2048 },
        },
        { -1 }
    },
    {
        0
    }

#else  /* INC_REASON not defined, treat as plain include */
#ifndef _Bitmap_h
#define _Bitmap_h

#include "RastrPos.h"
#include "Image.h"
#include "General.h"
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

typedef struct _Bitmap {
#define INC_REASON INFO_ITEM_STRUCT
#include "Bitmap.h"
#undef INC_REASON
} Bitmap, *BitmapPtr;

BitmapPtr new_Bitmap();
void delete_Bitmap(TestPtr);
void Bitmap__AddTraversalData(BitmapPtr);
int Bitmap__SetState(TestPtr);
void Bitmap__Initialize(TestPtr);
void Bitmap__Cleanup(TestPtr);
void Bitmap__SetExecuteFunc(TestPtr);
TestPtr Bitmap__Copy(TestPtr);
float Bitmap__Size(TestPtr);
int Bitmap__TimesRun(TestPtr);
void Bitmap__CreateImageData(BitmapPtr);

/* These constants are used in the function enumeration scheme */
#define NONE 0
#define PER_RASTERPOS 1
#define CI 0
#define RGB 1

#endif /* file not already included */
#endif /* INC_REASON not defined */
