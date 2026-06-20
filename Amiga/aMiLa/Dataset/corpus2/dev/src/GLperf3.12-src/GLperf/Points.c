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

#include "Points.h"

#undef offset
#define offset(v) offsetof(Points,v)

static InfoItem PointsInfo[] = {
#define INC_REASON INFO_ITEM_ARRAY
#include "Points.h"
#undef INC_REASON
};
#include <malloc.h>

PointsPtr new_Points()
{
    PointsPtr this = (PointsPtr)malloc(sizeof(Points));
    CheckMalloc(this);
    new_Vertex((VertexPtr)this);
    SetDefaults((TestPtr)this, PointsInfo);
    this->testType = PointsTest;
    this->primitiveType = GL_POINTS;
    this->size = 1;
    this->vertsPerFacet = 1;
    this->usecPixelPrint = " microseconds per pixel with Points";
    this->ratePixelPrint = " pixels per second with Points";
    this->usecPrint = " microseconds per Point";
    this->ratePrint = " Points per second";
    /* Set virtual functions */
    this->SetState = Points__SetState;
    this->delete = delete_Points;
    this->Layout = Points__Layout;
    this->Copy = Points__Copy;
    this->PixelSize = Points__Size;
    return this;
}

void delete_Points(TestPtr thisTest)
{
    PointsPtr this = (PointsPtr)thisTest;
    delete_Vertex(thisTest);
}

TestPtr Points__Copy(TestPtr thisTest)
{
    PointsPtr this = (PointsPtr)thisTest;
    PointsPtr newPoints = new_Points();
    FreeStrings((TestPtr)newPoints);
    *newPoints = *this;
    CopyStrings((TestPtr)newPoints, (TestPtr)this);
    return (TestPtr)newPoints;
}

float Points__Size(TestPtr thisTest)
{
    PointsPtr this = (PointsPtr)thisTest;
    return this->size * this->size;
}

int Points__SetState(TestPtr thisTest)
{
    PointsPtr this = (PointsPtr)thisTest;

    /* set parent state */
    if (Vertex__SetState(thisTest) == -1) return -1;

    /* set local state */
    if (!this->antiAlias) {
	glDisable(GL_POINT_SMOOTH);
    } else {
	if (this->antiAlias == On) {
	    glHint(GL_POINT_SMOOTH_HINT, GL_DONT_CARE);
	} else {
	    glHint(GL_POINT_SMOOTH_HINT, this->antiAlias);
	}
	glEnable(GL_POINT_SMOOTH);
    }
    glPointSize(this->size);
    return 0;
}

void Points__Layout(VertexPtr thisVertex)
{
    PointsPtr this = (PointsPtr)thisVertex;
    int windowDim = min(this->environ.windowWidth, this->environ.windowHeight);
    this->vertsPerBgnEnd = this->objsPerBgnEnd * this->vertsPerFacet;
    this->facetsPerBgnEnd = this->objsPerBgnEnd;

    this->layoutPoints = this->numObjects;
    this->layoutPadding = (2. + this->size + (this->antiAlias!=Off))/
                          (float)windowDim;
    Vertex__Layout(thisVertex);
}
