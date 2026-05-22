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

/* It's crucial that we keep the vertex based primitives ahead of the image
 * based primitives as it makes texture image setting simplified (that is,
 * we can assume that the pixel storage, map, etc. state is the default,
 * whereas if the image based primitives went first, we'd have to create
 * a concept of resetting the default pixel state).
 */
#define ClearTest		0
#define TransformTest		1
#define PointsTest		2
#define LinesTest		3
#define LineLoopTest		4
#define LineStripTest		5
#define TrianglesTest		6
#define TriangleStripTest	7
#define TriangleFanTest		8
#define QuadsTest		9
#define QuadStripTest		10
#define PolygonTest		11
#define ReadPixelsTest		12
#define DrawPixelsTest		13
#define CopyPixelsTest		14
#define BitmapTest		15
#define TextTest		16
#define TexImageTest		17
