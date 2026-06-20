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
    int renderMode;
/* Not adequately supported yet.  Will add as enhancement, if necessary
    int feedbackType;
    GLfloat* feedbackBuffer;
*/
    int drawableType;
    int scissorTest;
    int scissorX;
    int scissorY;
    int scissorWidth;
    int scissorHeight;
    int dithering;
    int colorMask;
    int indexMask;
    int drawBuffer;
#elif (defined(INC_REASON)) && (INC_REASON == INFO_ITEM_ARRAY)
#include "Test.h"
    {
        DrawableType,
	"Drawable Type",
	offset(drawableType),
	Enumerated,
	{
	    { WindowDraw,	"WindowDraw" },
/* Not adequately supported yet.  Will add as enhancement, if necessary
	    { PixmapDraw,	"PixmapDraw" },
*/
            { End }
	},
        { WindowDraw }
    },
    {
        RenderMode,
	"Render Mode",
	offset(renderMode),
	Enumerated,
	{
	    { GL_RENDER,	"GL_RENDER" },
/* Not adequately supported yet.  Will add as enhancement, if necessary
	    { GL_FEEDBACK,	"GL_FEEDBACK" },
	    { GL_SELECT,	"GL_SELECT" },
*/
            { End }
	},
        { GL_RENDER }
    },
/* Not adequately supported yet.  Will add as enhancement, if necessary
    {
        FeedbackType,
	"Feedback Type",
	offset(feedbackType),
	Enumerated,
	{
	    { GL_2D,			"GL_2D" },
	    { GL_3D,			"GL_3D" },
	    { GL_3D_COLOR,		"GL_3D_COLOR" },
	    { GL_3D_COLOR_TEXTURE,	"GL_3D_COLOR_TEXTURE" },
	    { GL_4D_COLOR_TEXTURE,	"GL_4D_COLOR_TEXTURE" },
            { End }
	},
        { GL_3D }
    },
*/
    {
        Dither,
	"Dither Enabled",
	offset(dithering),
	Enumerated,
	{
	    { On,	"On" },
	    { Off,	"Off" },
            { End }
	},
        { On }
    },
    {
        DrawBuffer,
	"Draw Buffer",
	offset(drawBuffer),
	Enumerated,
        {
            { GL_NONE,		"GL_NONE" },
            { GL_FRONT_LEFT,	"GL_FRONT_LEFT" },
            { GL_FRONT_RIGHT,	"GL_FRONT_RIGHT" },
            { GL_BACK_LEFT,	"GL_BACK_LEFT" },
            { GL_BACK_RIGHT,	"GL_BACK_RIGHT" },
            { GL_FRONT,		"GL_FRONT" },
            { GL_BACK,		"GL_BACK" },
            { GL_FRONT_AND_BACK,"GL_FRONT_AND_BACK" },
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
        ColorMask,
	"Color Mask Enabled",
	offset(colorMask),
	Enumerated,
	{
	    { TTTT,	"TTTT" },
	    { TTTF,	"TTTF" },
	    { TTFT,	"TTFT" },
	    { TTFF,	"TTFF" },
	    { TFTT,	"TFTT" },
	    { TFTF,	"TFTF" },
	    { TFFT,	"TFFT" },
	    { TFFF,	"TFFF" },
	    { FTTT,	"FTTT" },
	    { FTTF,	"FTTF" },
	    { FTFT,	"FTFT" },
	    { FTFF,	"FTFF" },
	    { FFTT,	"FFTT" },
	    { FFTF,	"FFTF" },
	    { FFFT,	"FFFT" },
	    { FFFF,	"FFFF" },
            { End }
	},
        { TTTT }
    },
    {
        IndexMask,
	"Index Mask Enabled",
	offset(indexMask),
	RangedHexInteger,
	{
	    { 0 },
	    { 0xffff },
	},
        { 0xffff }
    },
    {
        Scissor,
	"Scissoring Enabled",
	offset(scissorTest),
	Enumerated,
	{
	    { On,	"On" },
	    { Off,	"Off" },
            { End }
	},
        { Off }
    },
    {
        ScissorX,
        "Scissor X",
        offset(scissorX),
        RangedInteger,
        {
            { 0 }, /* minimum value */
            { 2048 }, /* maximum value */
        },
        { 0 }
    },
    {
        ScissorY,
        "Scissor Y",
        offset(scissorY),
        RangedInteger,
        {
            { 0 }, /* minimum value */
            { 2048 }, /* maximum value */
        },
        { 0 }
    },
    {
        ScissorWidth,
        "Scissor Width",
        offset(scissorWidth),
        RangedInteger,
        {
            { 0 }, /* minimum value */
            { 2048 }, /* maximum value */
        },
        { -1 }
    },
    {
        ScissorHeight,
        "Scissor Height",
        offset(scissorHeight),
        RangedInteger,
        {
            { 0 }, /* minimum value */
            { 2048 }, /* maximum value */
        },
        { -1 }
    },
#else  /* INC_REASON not defined, treat as plain include */
#ifndef _Drawn_h
#define _Drawn_h

#include "Test.h"
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

typedef struct _Drawn {
#define INC_REASON INFO_ITEM_STRUCT
#include "Drawn.h"
#undef INC_REASON
} Drawn, *DrawnPtr;

void new_Drawn(DrawnPtr this);
void delete_Drawn(TestPtr thisTest);
int Drawn__SetState(TestPtr thisTest);

#endif /* file not already included */
#endif /* INC_REASON not defined */
