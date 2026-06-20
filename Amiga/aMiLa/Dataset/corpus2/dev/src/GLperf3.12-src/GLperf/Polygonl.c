/*
//   (C) COPYRIGHT International Business Machines Corp. 1993
//   All Rights Reserved
//   Licensed Materials - Property of IBM
//   US Government Users Restricted Rights - Use, duplication or
//   disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
//

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

#include "Polygonl.h"
#include <malloc.h>

void new_Polygonal(PolygonalPtr this)
{
    new_Vertex((VertexPtr)this);
    this->size = 10;
    /* Set virtual functions */
    this->SetState = Polygonal__SetState;
}

void delete_Polygonal(TestPtr thisTest)
{
    delete_Vertex(thisTest);
}

int Polygonal__SetState(TestPtr thisTest)
{
    PolygonalPtr this = (PolygonalPtr)thisTest;

    /* set parent state */
    if (Vertex__SetState(thisTest) == -1) return -1;

    /* set own state */
    if (!this->antiAlias) {
	glDisable(GL_POLYGON_SMOOTH);
    } else {
	if (this->antiAlias == On) {
	    glHint(GL_POLYGON_SMOOTH_HINT, GL_DONT_CARE);
	} else {
	    glHint(GL_POLYGON_SMOOTH_HINT, this->antiAlias);
	}
	glEnable(GL_POLYGON_SMOOTH);
    }

    if (!this->cullFace) {
	glDisable(GL_CULL_FACE);
    } else {
	glCullFace(this->cullFace);
	glEnable(GL_CULL_FACE);
    }

    if (this->polyModeFront == this->polyModeBack) {
        glPolygonMode(GL_FRONT_AND_BACK, this->polyModeFront);
    } else {
        glPolygonMode(GL_FRONT, this->polyModeFront);
        glPolygonMode(GL_BACK,  this->polyModeBack);
    }

    if (!this->polyStipple) {
        glDisable(GL_POLYGON_STIPPLE);
    } else {
	unsigned char pattern[16] = { 0xaa, 0xaa, 0xaa, 0xaa,
				      0x55, 0x55, 0x55, 0x55,
				      0xaa, 0xaa, 0xaa, 0xaa,
				      0x55, 0x55, 0x55, 0x55 };
	glPolygonStipple(pattern);
        glEnable(GL_POLYGON_STIPPLE);
    }

    glLightModeli(GL_LIGHT_MODEL_TWO_SIDE, this->twoSided);
    return 0;
}
