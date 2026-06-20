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
#include "Vertex.h"
    GLfloat lineWidth;
    int lineStipple;
#elif (defined(INC_REASON)) && (INC_REASON == INFO_ITEM_ARRAY)
#include "Vertex.h"
    {
        LineWidth,
        "Line Width",
        offset(lineWidth),
        RangedFloatOrInt,
        {
            { 0.0 },
            { 1000.0 }
        },
        { NotUsed, 1.0 }
    },
    {
        LineStipple,
        "Line Stippling Enabled",
        offset(lineStipple),
        Enumerated,
        {
            { On,       "On" },
            { Off,      "Off" },
            { End }
        },
        { Off }
    },
#else  /* INC_REASON not defined, treat as plain include */
#ifndef _Linear_h
#define _Linear_h

#include "Vertex.h"

typedef struct _Linear {
#define INC_REASON INFO_ITEM_STRUCT
#include "Linear.h"
#undef INC_REASON
} Linear, *LinearPtr;

void new_Linear(LinearPtr);
void delete_Linear(TestPtr);
int Linear__SetState(TestPtr);
float Linear__Size(TestPtr);

#endif /* file not already included */
#endif /* INC_REASON not defined */
