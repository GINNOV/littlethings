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

#include "Linear.h"
#include <malloc.h>

void new_Linear(LinearPtr this)
{
    new_Vertex((VertexPtr)this);
    this->SetState = Linear__SetState;
    this->PixelSize = Linear__Size;
}

void delete_Linear(TestPtr thisTest)
{
    delete_Vertex(thisTest);
}

float Linear__Size(TestPtr thisTest)
{
    LinearPtr this = (LinearPtr)thisTest;
    return this->size * this->lineWidth;
}

int Linear__SetState(TestPtr thisTest)
{
    LinearPtr this = (LinearPtr)thisTest;
    GLfloat windowDim;

    /* set parent state */
    if (Vertex__SetState(thisTest) == -1) return -1;

    /* kick out if lines won't fit within window */
    windowDim = (GLfloat)(min(this->environ.windowWidth, this->environ.windowHeight));
    if (this->size >= windowDim) return -1;

    /* set own state */
    if (!this->antiAlias) {
        glDisable(GL_LINE_SMOOTH);
    } else {
	if (this->antiAlias == On) {
	    glHint(GL_LINE_SMOOTH_HINT, GL_DONT_CARE);
	} else {
	    glHint(GL_LINE_SMOOTH_HINT, this->antiAlias);
	}
        glEnable(GL_LINE_SMOOTH);
    }

    glLineWidth(this->lineWidth);

    if (!this->lineStipple) {
	glDisable(GL_LINE_STIPPLE);
    } else {
        /* In the future, we may want user defined stipple patterns */
	glLineStipple(1, 0xf0f0);
	glEnable(GL_LINE_STIPPLE);
    }
    return 0;
}
