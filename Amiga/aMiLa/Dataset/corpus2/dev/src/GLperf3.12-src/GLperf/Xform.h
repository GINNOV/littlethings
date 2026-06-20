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
#include "Test.h"
#define TransformStructItems
    int transformType;
    int pointDraw;
    int pushPop;
    /* Members below this line aren't user settable */
    GLfloat *transformData;
#elif (defined(INC_REASON)) && (INC_REASON == INFO_ITEM_ARRAY)
#include "Test.h"
    {
        TransformType,
        "Transform Type",
        offset(transformType),
        Enumerated,
        {
            { Translate,       "Translate" },
            { Rotate,          "Rotate" },
            { Scale,           "Scale" },
            { Perspective,     "Perspective" },
            { Ortho,           "Ortho" },
            { Ortho2,          "Ortho2" },
            { Frustum,         "Frustum" },
            { End }
        },
        { Rotate}
    },
    {
        PointDraw,
        "Draw Point Between Transforms",
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
        PushPop,
        "Push and Pop Around Transforms",
        offset(pushPop),
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
#ifndef _Xform_h
#define _Xform_h

#include "Test.h"
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

typedef struct _Transform {
#define INC_REASON INFO_ITEM_STRUCT
#include "Xform.h"
#undef INC_REASON
} Transform, *TransformPtr;

TransformPtr new_Transform();
void delete_Transform(TestPtr);
int Transform__SetState(TestPtr);
void Transform__Initialize(TestPtr);
void Transform__Cleanup(TestPtr);
void Transform__SetExecuteFunc(TestPtr);
TestPtr Transform__Copy(TestPtr);
float Transform__Size(TestPtr);

#endif /* file not already included */
#endif /* INC_REASON not defined */
