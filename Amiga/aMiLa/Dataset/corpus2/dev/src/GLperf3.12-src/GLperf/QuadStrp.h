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
#include "Polygonl.h"
    int twistsPerStrip;
#elif (defined(INC_REASON)) && (INC_REASON == INFO_ITEM_ARRAY)
#include "Polygonl.h"
    {
        TwistsPerStrip,
        "Twists Per Quad Strip",
        offset(twistsPerStrip),
        RangedInteger,
        {
            { 0 },
            { 100000 },
        },
        { 0 }
    },
    {
        0
    }
#else  /* INC_REASON not defined, treat as plain include */
#ifndef _QuadStrp_h
#define _QuadStrp_h

#include "Polygonl.h"
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

typedef struct _QuadStrip {
#define INC_REASON INFO_ITEM_STRUCT
#include "QuadStrp.h"
#undef INC_REASON
} QuadStrip, *QuadStripPtr;

QuadStripPtr new_QuadStrip();
void delete_QuadStrip(TestPtr);
TestPtr QuadStrip__Copy(TestPtr);
void QuadStrip__Layout(VertexPtr);

#endif /* file not already included */
#endif /* INC_REASON not defined */
