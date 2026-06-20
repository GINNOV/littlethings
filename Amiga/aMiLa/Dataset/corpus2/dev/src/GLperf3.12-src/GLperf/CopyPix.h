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
    int copyPixelsWidth;
    int copyPixelsHeight;
    int copyPixelsType;
    int readBuffer;
    /* Variables below this line aren't user settable */
    /* Member functions */
    /* void Initialize(TestPtr); */               /* virtual function */
    /* void Execute(TestPtr);   */                /* virtual function */
    /* int SetState(TestPtr);  */                 /* virtual function */
    /* float PixelSize(TestPtr);  */              /* virtual function */
    /* int TimesRun(TestPtr);  */               /* virtual function */
    /* void (*SetExecuteFunc)(TestPtr); */        /* virtual function */
    Image image_CopyPixels;
    TransferMap transfermap_CopyPixels;
    Zoom zoom_CopyPixels;
#elif (defined(INC_REASON)) && (INC_REASON == INFO_ITEM_ARRAY)
#include "RastrPos.h"
#undef offset
#define offset(v) offsetof(CopyPixels, transfermap_CopyPixels)+offsetof(TransferMap, v)
#include "TransMap.h"
#undef offset
#define offset(v) offsetof(CopyPixels, zoom_CopyPixels)+offsetof(Zoom, v)
#include "Zoom.h"
#undef offset
#define offset(v) offsetof(CopyPixels, image_CopyPixels)+offsetof(Image, v)
#include "Image.h"
#undef offset
#define offset(v) offsetof(CopyPixels,v)
    {
        CopyPixelsWidth,
        "Width of CopyPixels",
        offset(copyPixelsWidth),
        RangedInteger,
        {
            { 1 },
            { 2048 },
        },
        { 64 }
    },
    {
        CopyPixelsHeight,
        "Height of CopyPixels",
        offset(copyPixelsHeight),
        RangedInteger,
        {
            { 1 },
            { 2048 },
        },
        { 64 }
    },
    {
        CopyPixelsType,
        "Type of CopyPixels",
        offset(copyPixelsType),
        Enumerated,
        {
            { GL_COLOR,    "GL_COLOR" },
            { GL_DEPTH,    "GL_DEPTH" },
            { GL_STENCIL,  "GL_STENCIL" },
            { End }
        },
        { GL_COLOR }
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
        0
    }

#else  /* INC_REASON not defined, treat as plain include */
#ifndef _CopyPix_h
#define _CopyPix_h

#include "RastrPos.h"
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

typedef struct _CopyPixels {
#define INC_REASON INFO_ITEM_STRUCT
#include "CopyPix.h"
#undef INC_REASON
} CopyPixels, *CopyPixelsPtr;

CopyPixelsPtr new_CopyPixels();
void delete_CopyPixels(TestPtr);
void CopyPixels__AddTraversalData(CopyPixelsPtr);
int CopyPixels__SetState(TestPtr);
void CopyPixels__Initialize(TestPtr);
void CopyPixels__Cleanup(TestPtr thisTest);
void CopyPixels__SetExecuteFunc(TestPtr);
TestPtr CopyPixels__Copy(TestPtr);
float CopyPixels__Size(TestPtr);
int CopyPixels__TimesRun(TestPtr);

#endif /* file not already included */
#endif /* INC_REASON not defined */
