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
#include "Test.h"
    int readPixelsWidth;
    int readPixelsHeight;
    int readBuffer;
    int readOrder;
    /* Variables below this line aren't user settable */
    void **imageData;
    int numDrawn;
    int subImage;
    GLint *srcData;
    GLint *subImageData;
    /* Member functions */
    /* void Initialize(TestPtr); */               /* virtual function */
    /* void Execute(TestPtr);   */                /* virtual function */
    /* int SetState(TestPtr);  */                 /* virtual function */
    /* float PixelSize(TestPtr);  */              /* virtual function */
    /* int TimesRun(TestPtr);  */               /* virtual function */
    /* void (*SetExecuteFunc)(TestPtr); */        /* virtual function */
    Image image_ReadPixels;
    TransferMap transfermap_ReadPixels;
#elif (defined(INC_REASON)) && (INC_REASON == INFO_ITEM_ARRAY)
#include "Test.h"
#undef offset
#define offset(v) offsetof(ReadPixels,transfermap_ReadPixels)+offsetof(TransferMap, v)
#include "TransMap.h"
#undef offset
#define offset(v) offsetof(ReadPixels, image_ReadPixels)+offsetof(Image, v)
#include "Image.h"
#undef offset
#define offset(v) offsetof(ReadPixels,v)
    {
        ReadPixelsWidth,
        "Width of ReadPixels",
        offset(readPixelsWidth),
        RangedInteger,
        {
            { 1 },
            { 2048 },
        },
        { -1 }
    },
    {
        ReadPixelsHeight,
        "Height of ReadPixels",
        offset(readPixelsHeight),
        RangedInteger,
        {
            { 1 },
            { 2048 },
        },
        { -1 }
    },
    {
        ReadBuffer,
        "Read Buffer",
        offset(readBuffer),
        Enumerated,
        {
            { GL_FRONT_LEFT,	"GL_FRONT_LEFT" },
            { GL_FRONT_RIGHT,	"GL_FRONT_RIGHT" },
            { GL_BACK_LEFT,	"GL_BACK_LEFT" },
            { GL_BACK_RIGHT,	"GL_BACK_RIGHT" },
            { GL_FRONT,		"GL_FRONT" },
            { GL_BACK,		"GL_BACK" },
            { GL_LEFT,		"GL_LEFT" },
            { GL_RIGHT,		"GL_RIGHT" },
#ifdef GL_AUX0
            { GL_AUX0,  	"GL_AUX0" },
#endif
#ifdef GL_AUX1
            { GL_AUX1,  	"GL_AUX1" },
#endif
#ifdef GL_AUX2
            { GL_AUX2,  	"GL_AUX2" },
#endif
#ifdef GL_AUX3
            { GL_AUX3,  	"GL_AUX3" },
#endif
            { End }
        },
        { GL_FRONT }
    },
    {
        ReadOrder,
        "Order in which Images/Bitmaps/Text are Read",
        offset(readOrder),
        Enumerated,
        {
            { Serial,			"Serial" },
            { Spaced,			"Spaced" },
            { End }
        },
        { Spaced }
    },
    {
        0
    }

#else  /* INC_REASON not defined, treat as plain include */
#ifndef _ReadPix_h
#define _ReadPix_h

#include "Test.h"
#include "Image.h"
#include "TransMap.h"
#include "Zoom.h"
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

typedef struct _ReadPixels {
#define INC_REASON INFO_ITEM_STRUCT
#include "ReadPix.h"
#undef INC_REASON
} ReadPixels, *ReadPixelsPtr;

ReadPixelsPtr new_ReadPixels();
void delete_ReadPixels(TestPtr);
void ReadPixels__AddTraversalData(ReadPixelsPtr);
int ReadPixels__SetState(TestPtr);
void ReadPixels__Initialize(TestPtr);
void ReadPixels__Cleanup(TestPtr);
void ReadPixels__SetExecuteFunc(TestPtr);
TestPtr ReadPixels__Copy(TestPtr);
float ReadPixels__Size(TestPtr);
int ReadPixels__TimesRun(TestPtr);
void ReadPixels__CreateImageData(ReadPixelsPtr);

#endif /* file not already included */
#endif /* INC_REASON not defined */
