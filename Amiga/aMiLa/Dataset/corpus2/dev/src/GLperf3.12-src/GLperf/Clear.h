/*
 *   (C) COPYRIGHT International Business Machines Corp. 1993
 *   All Rights Reserved
 *   Licensed Materials - Property of IBM
 *   US Government Users Restricted Rights - Use, duplication or
 *   disclosure restricted by GSA ADP Schedule Contract with IBM Corp.

//
// Permission to use, copy, modify, and distribute this software and its
// documentation for any purpose and without fee is hereby granted, provided
// that the above copyright notice appear in all copies and that both that
// copyright notice and this permission notice appear in supporting
// documentation, and that the name of I.B.M. not be used in advertising
// or publicity pertaining to distribution of the software without specific,
// written prior permission. I.B.M. makes no representations about the
// suitability of this software for any purpose.  It is provided "as is"
// without express or implied warranty.
//
// I.B.M. DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, INCLUDING ALL
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO EVENT SHALL I.B.M.
// BE LIABLE FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
// WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION
// OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
// CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
//
// Author:  John Spitzer, IBM AWS Graphics Systems (Austin)
//
*/

#if (defined(INC_REASON)) && (INC_REASON == INFO_ITEM_STRUCT)
#include "Drawn.h"
    unsigned mask;
    int clearColor;
    int clearDepth;
    int clearStencil;
    int clearAccum;
    int colorOfClear;
    GLfloat clearIndex;
    int pointDraw;
#elif (defined(INC_REASON)) && (INC_REASON == INFO_ITEM_ARRAY)
#include "Drawn.h"
    {
        ClearColorBuffer,
        "Clear Color Buffer",
        offset(clearColor),
        Enumerated,
        {
            { True,     "True" },
            { False,    "False" },
            { End }
        },
        { True }
    },
    {
        ClearDepthBuffer,
        "Clear Depth Buffer",
        offset(clearDepth),
        Enumerated,
        {
            { True,     "True" },
            { False,    "False" },
            { End }
        },
        { False }
    },
    {
        ClearStencilBuffer,
        "Clear Stencil Buffer",
        offset(clearStencil),
        Enumerated,
        {
            { True,     "True" },
            { False,    "False" },
            { End }
        },
        { False }
    },
    {
        ClearAccumBuffer,
        "Clear Accumulation Buffer",
        offset(clearAccum),
        Enumerated,
        {
            { True,     "True" },
            { False,    "False" },
            { End }
        },
        { False }
    },
    {
        ClearIndex,
        "Clear Index",
        offset(clearIndex),
        RangedFloatOrInt,
        {
            { 0.0 },
            { 4096.0 }
        },
        { NotUsed, 0.0 }
    },
    {
        ClearColor,
        "Clear Color",
        offset(colorOfClear),
        Enumerated,
        {
            { Red,	"Red" },
            { Green,	"Green" },
            { Blue,	"Blue" },
            { Cyan,	"Cyan" },
            { Magenta,	"Magenta" },
            { Yellow,	"Yellow" },
            { White,	"White" },
            { Grey,	"Grey" },
            { Black,	"Black" },
            { End }
        },
        { Black }
    },
    {
        PointDraw,
        "Draw Point Between Clears",
        offset(pointDraw),
        Enumerated,
        {
            { On,       "On" },
            { Off,      "Off" },
            { End }
        },
        { Off }
    },
    {
        0
    }
#else  /* INC_REASON not defined, treat as plain include */
#ifndef _Clear_h
#define _Clear_h

#include "Drawn.h"
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

typedef struct _Clear {
#define INC_REASON INFO_ITEM_STRUCT
#include "Clear.h"
#undef INC_REASON
} Clear, *ClearPtr;

ClearPtr new_Clear();
void delete_Clear(TestPtr);
int Clear__SetState(TestPtr);
void Clear__Initialize(TestPtr);
void Clear__Cleanup(TestPtr);
void Clear__Execute(TestPtr);
void Clear__SetExecuteFunc(TestPtr);
TestPtr Clear__Copy(TestPtr);
float Clear__Size(TestPtr);

#endif /* file not already included */
#endif /* INC_REASON not defined */
