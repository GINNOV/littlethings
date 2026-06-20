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
#include "Lines.h"

#undef offset
#define offset(v) offsetof(Lines,v)

static InfoItem LinesInfo[] = {
#define INC_REASON INFO_ITEM_ARRAY
#include "Lines.h"
#undef INC_REASON
};
#include <malloc.h>

LinesPtr new_Lines()
{
    LinesPtr this = (LinesPtr)malloc(sizeof(Lines));
    CheckMalloc(this);
    new_Linear((LinearPtr)this);
    SetDefaults((TestPtr)this, LinesInfo);
    this->testType = LinesTest;
    this->primitiveType = GL_LINES;
    this->vertsPerFacet = 2;
    this->usecPixelPrint = " microseconds per pixel with disjoint Lines";
    this->ratePixelPrint = " pixels per second with disjoint Lines";
    this->usecPrint = " microseconds per Line in a disjoint Lines call";
    this->ratePrint = " Lines per second in a disjoint Lines call";
    /* Set virtual functions */
    this->delete = delete_Lines;
    this->Layout = Lines__Layout;
    this->Copy = Lines__Copy;
    return this;
}

void delete_Lines(TestPtr thisTest)
{
    LinesPtr this = (LinesPtr)thisTest;
    delete_Linear(thisTest);
}

TestPtr Lines__Copy(TestPtr thisTest)
{
    LinesPtr this = (LinesPtr)thisTest;
    LinesPtr newLines = new_Lines();
    FreeStrings((TestPtr)newLines);
    *newLines = *this;
    CopyStrings((TestPtr)newLines, (TestPtr)this);
    return (TestPtr)newLines;
}

void Lines__Layout(VertexPtr thisVertex)
{
    LinesPtr this = (LinesPtr)thisVertex;
    int windowDim = min(this->environ.windowWidth, this->environ.windowHeight);
    const double pi=3.141592654;
    double ndcSize, lengthSide, halfWidth, radius;
    double theta, theta0, deltaTheta;
    GLfloat x, y;
    GLfloat *src, *dst;
    GLfloat *newTraversalData;
    int i, j;

    /* Set traversal variables */
    this->vertsPerBgnEnd = this->objsPerBgnEnd * this->vertsPerFacet;
    this->facetsPerBgnEnd = this->objsPerBgnEnd;

    /* Figure polygon dimensions given polygon size in pixels and number of sides */
    ndcSize = this->size/(double)windowDim*2.0;
    radius = ndcSize/2.0;
    deltaTheta = pi;

    /* Use Vertex__Layout to get line centers */
    this->layoutPoints = this->numObjects;
    this->layoutPadding = radius;
    this->layoutPadding += (1. + this->lineWidth/2. + (this->antiAlias!=Off))/
                               (float)windowDim;
    Vertex__Layout(thisVertex);

    /* Allocate space for new stuff */
    src = this->traversalData;
    newTraversalData = (GLfloat*)malloc(this->numObjects * 2 * 2 * sizeof(GLfloat));
    CheckMalloc(newTraversalData);
    dst = newTraversalData;

    /* Figure initial theta position for orientation */
    switch (this->orientation) {
        case Horizontal:
            theta0 = 0.0;
            break;
        case Vertical:
            theta0 = pi/2.0;
            break;
	case Random:
	    mysrand(15000);
            break;
    }

    /* Generate those vertices around the point centers */
    for (i=0; i<this->numObjects; i++) {
        x = *src++;
        y = *src++;
        if (this->orientation == Random)
            theta0 = 2.0*pi*(double)myrand()/(double)MY_RAND_MAX;
        theta = theta0;
        for (j=0; j<2; j++) {
            *dst++ = radius * cos(theta) + x;
            *dst++ = radius * sin(theta) + y;
            theta += deltaTheta;
        }
    }
    free(this->traversalData);
    this->traversalData = newTraversalData;
}
