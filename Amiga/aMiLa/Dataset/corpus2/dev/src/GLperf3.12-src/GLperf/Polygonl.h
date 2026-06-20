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
    int cullFace;	/* Off, GL_FRONT, GL_BACK */
    int polyStipple;	/* Off or On */
    int twoSided;	/* Off or On */
    int polyModeFront;	/* GL_POINT, GL_LINE, GL_FILL */
    int polyModeBack;	/* GL_POINT, GL_LINE, GL_FILL */
    float facingFront;	/* Percentage of polygons facing frontwards [0.0,1.0] */
    float facingBack;	/* Percentage of polygons facing backwards [0.0,1.0] */
    float aspect;	/* Aspect ratio of object (1.0 is equilateral) */
#elif (defined(INC_REASON)) && (INC_REASON == INFO_ITEM_ARRAY)
#include "Vertex.h"
    {
        Aspect,
	"Aspect",
	offset(aspect),
	RangedFloatOrInt,
	{
	    { 0.01 },
	    { 100.0 }
	},
        { NotUsed, 1.0 }
    },
    {
        PolygonModeFront,
	"Polygon Rasterization Mode/Front Side",
	offset(polyModeFront),
	Enumerated,
	{
	    { GL_POINT,	"GL_POINT" },
	    { GL_LINE,	"GL_LINE" },
	    { GL_FILL,	"GL_FILL" },
            { End }
	},
        { GL_FILL }
    },
    {
        PolygonModeBack,
	"Polygon Rasterization Mode/Back Side",
	offset(polyModeBack),
	Enumerated,
	{
	    { GL_POINT,	"GL_POINT" },
	    { GL_LINE,	"GL_LINE" },
	    { GL_FILL,	"GL_FILL" },
            { End }
	},
        { GL_FILL }
    },
    {
        PolygonStipple,
	"Polygon Stippling Enabled",
	offset(polyStipple),
	Enumerated,
	{
	    { On,	"On" },
	    { Off,	"Off" },
            { End }
	},
        { Off }
    },
    {
        TwoSided,
	"Two Sided Lighting",
	offset(twoSided),
	Enumerated,
	{
	    { On,	"On" },
	    { Off,	"Off" },
            { End }
	},
        { Off }
    },
    {
        CullFace,
	"Cull Face Mode",
	offset(cullFace),
	Enumerated,
	{
	    { Off,	"Off" },
	    { GL_FRONT,	"GL_FRONT" },
	    { GL_BACK,	"GL_BACK" },
	    { GL_FRONT_AND_BACK, "FRONT_AND_BACK" },
            { End }
	},
        { Off }
    },
    {
        FacingFront,
	"Fraction of Polygons Facing Front",
	offset(facingFront),
	RangedFloat,
	{
	    { 0.0 },
	    { 1.0 }
	},
        { NotUsed, 1.0 }
    },
    {
        FacingBack,
	"Fraction of Polygons Facing Back",
	offset(facingBack),
	RangedFloat,
	{
	    { 0.0 },
	    { 1.0 }
	},
        { NotUsed, 0.0 }
    },
#else  /* INC_REASON not defined, treat as plain include */
#ifndef _Polygonl_h
#define _Polygonl_h

#include "Vertex.h"


typedef struct _Polygonal {
#define INC_REASON INFO_ITEM_STRUCT
#include "Polygonl.h"
#undef INC_REASON
} Polygonal, *PolygonalPtr;

void new_Polygonal(PolygonalPtr);
void delete_Polygonal(TestPtr);
int Polygonal__SetState(TestPtr);

#endif /* file not already included */
#endif /* INC_REASON not defined */
