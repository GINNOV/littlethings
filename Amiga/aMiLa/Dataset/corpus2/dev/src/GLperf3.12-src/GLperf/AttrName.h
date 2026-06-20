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

#ifndef _AttrName_h
#define _AttrName_h

#include "Global.h"

#define Off		0
#define On		1
#define False		0
#define True		1
#define End             -1

#if ((Off != 0) || (On != 1) || (False!=0) || (True!=1))
%%% Constants have been changed!  Change them back!
#endif


#define Immediate	1
#define Compile		2
#define CallList	3
#define CompileExecute	4
#define DestroyList	5

#define NoVisual		0

#define WindowDraw		0
#define PixmapDraw		1

#define Translate	0
#define Rotate		1
#define Scale		2
#define Perspective	3
#define Ortho		4
#define Ortho2		5
#define Frustum		6

#undef None
#define None 		0
#define PerVertex	1
#define PerRasterPos	1
#if (PerVertex != PerRasterPos)
%%%  PerVertex and PerRasterPos MUST be the same value!
#endif
#define PerFacet	2

#define Parallel	1

#define Random		0
#define Vertical	1
#define Horizontal	2

#define Red            300
#define Green          301
#define Blue           302
#define Magenta        303
#define Cyan           304
#define Yellow         305
#define Black          306
#define White          307
#define Grey           308

#define TTTT	309
#define TTTF	310
#define TTFT	311
#define TTFF	312
#define TFTT	313
#define TFTF	314
#define TFFT	315
#define TFFF	316
#define FTTT	317
#define FTTF	318
#define FTFT	319
#define FTFF	320
#define FFTT	321
#define FFTF	322
#define FFFT	323
#define FFFF	324

#define Serial  325
#define Spaced  326

#define SystemMemory	327
#define DisplayList	328
#define TexObj		329
#define Framebuffer	330

#define PreCalculate		331
#define gluBuildMipmap		332
#define GenerateMipmapExt	333

#define Coplanar		334
#define BackToFront		335
#define FrontToBack		336

#define TexturedPoint		337
#define TexturedTriangle	338

#define f8x13			339
#define f9x15			340
#define timR10			341
#define timR24			342
#define helvR10			343
#define helvR12			344
#define helvR18			345

#endif
