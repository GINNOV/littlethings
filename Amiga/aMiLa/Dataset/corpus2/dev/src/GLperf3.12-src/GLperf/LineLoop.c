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

#include <math.h>
#include "LineLoop.h"

#undef offset
#define offset(v) offsetof(LineLoop,v)

static InfoItem LineLoopInfo[] = {
#define INC_REASON INFO_ITEM_ARRAY
#include "LineLoop.h"
#undef INC_REASON
};
#include <malloc.h>

LineLoopPtr new_LineLoop()
{
    LineLoopPtr this = (LineLoopPtr)malloc(sizeof(LineLoop));
    CheckMalloc(this);
    new_Linear((LinearPtr)this);
    SetDefaults((TestPtr)this, LineLoopInfo);
    this->testType = LineLoopTest;
    this->primitiveType = GL_LINE_LOOP;
    this->vertsPerFacet = 1;
    this->usecPixelPrint = " microseconds per pixel with Line Loop";
    this->ratePixelPrint = " pixels per second with Line Loop";
    this->usecPrint = " microseconds per Line in a Line Loop";
    this->ratePrint = "Lines per second in a Line Loop";
    /* Set virtual functions */
    this->delete = delete_LineLoop;
    this->Layout = LineLoop__Layout;
    this->Copy = LineLoop__Copy;
    return this;
}

void delete_LineLoop(TestPtr thisTest)
{
    LineLoopPtr this = (LineLoopPtr)thisTest;
    delete_Linear(thisTest);
}

TestPtr LineLoop__Copy(TestPtr thisTest)
{
    LineLoopPtr this = (LineLoopPtr)thisTest;
    LineLoopPtr newLineLoop = new_LineLoop();
    FreeStrings((TestPtr)newLineLoop);
    *newLineLoop = *this;
    CopyStrings((TestPtr)newLineLoop, (TestPtr)this);
    return (TestPtr)newLineLoop;
}

void LineLoop__Layout(VertexPtr thisVertex)
{
    LineLoopPtr this = (LineLoopPtr)thisVertex;
    int windowDim = min(this->environ.windowWidth, this->environ.windowHeight);
    const double pi=3.141592654;
    double ndcSize, radius;
    double theta, theta0, deltaTheta;
    GLfloat x, y;
    GLfloat *src, *dst;
    GLfloat *newTraversalData;
    int i, j;

    /* These will/could be used in traversal function */
    this->vertsPerBgnEnd = this->facetsPerBgnEnd = this->objsPerBgnEnd;

    /* Figure lineloop dimensions given line length in pixels and number of lines */
    ndcSize = this->size/(double)windowDim*2.0;
    radius = ndcSize/(2.0*sin(pi/(double)this->vertsPerBgnEnd));
    deltaTheta = 2.0*pi/(double)this->vertsPerBgnEnd;

    /* Use Vertex__Layout to get line loop centers */
    this->layoutPoints = this->numBgnEnds;
    this->layoutPadding = radius;
    this->layoutPadding += (1. + this->lineWidth/2. + (this->antiAlias!=Off))/
                           (float)windowDim;
    Vertex__Layout(thisVertex);

    /* Allocate necessary data */
    src = this->traversalData;
    newTraversalData = (GLfloat*)malloc(this->numObjects * 2 * sizeof(GLfloat));
    CheckMalloc(newTraversalData);
    dst = newTraversalData;

    /* Figure initial theta position for orientation */
    switch (this->orientation) {
        case Horizontal:
            theta0 = 3.0*pi/2.0 - deltaTheta/2.0;
            break;
        case Vertical:
            theta0 = pi - deltaTheta/2.0;
            break;
        case Random:
	    mysrand(15000);
            break;
    }

    /* Generate those vertices around the point centers */
    for (i=0; i<this->numBgnEnds; i++) {
        x = *src++;
        y = *src++;
        if (this->orientation == Random)
            theta0 = 2.0*pi*(double)myrand()/(double)MY_RAND_MAX;
        theta = theta0;
        for (j=0; j<this->vertsPerBgnEnd; j++) {
            *dst++ = radius * cos(theta) + x;
            *dst++ = radius * sin(theta) + y;
            theta += deltaTheta;
        }
    }
    free(this->traversalData);
    this->traversalData = newTraversalData;
}
