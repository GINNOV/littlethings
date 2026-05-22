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
#include "Polygon.h"
#define sq(val)	((val)*(val))

#undef offset
#ifdef WIN32
#define offset(v) offsetof(PolygonStr,v)
#else
#define offset(v) offsetof(Polygon,v)
#endif

static InfoItem PolygonInfo[] = {
#define INC_REASON INFO_ITEM_ARRAY
#include "Polygon.h"
#undef INC_REASON
};
#include <malloc.h>

PolygonPtr new_Polygon()
{
#ifdef WIN32
    PolygonPtr this = (PolygonPtr)malloc(sizeof(PolygonStr)); /* Name conflict */
#else
    PolygonPtr this = (PolygonPtr)malloc(sizeof(Polygon));
#endif
    CheckMalloc(this);
    new_Polygonal((PolygonalPtr)this);
    SetDefaults((TestPtr)this, PolygonInfo);
    this->testType = PolygonTest;
    this->primitiveType = GL_POLYGON;
    this->vertsPerFacet = this->numSides;
    this->objsPerBgnEnd = 1;
    this->usecPixelPrint = " microseconds per pixel with Polygon";
    this->ratePixelPrint = " pixels per second with Polygon";
    this->usecPrint = " microseconds per Polygon";
    this->ratePrint = " Polygons per second";
    /* Set virtual functions */
    this->SetState = Polygon__SetState;
    this->delete = delete_Polygon;
    this->Layout = Polygon__Layout;
    this->Copy = Polygon__Copy;
    return this;
}

void delete_Polygon(TestPtr thisTest)
{
    PolygonPtr this = (PolygonPtr)thisTest;
    delete_Polygonal(thisTest);
}

int Polygon__SetState(TestPtr thisTest)
{
    PolygonPtr this = (PolygonPtr)thisTest;

    /* set parent state */
    if (Polygonal__SetState(thisTest) == -1) return -1;

    /* set own state */
    /* Nothing needs to be set, but we need to see if the number
       of sides of the polygon can be drawn with whatever amount
       of loop unrolling is set up in the Vertex */
    
    if (this->numSides > 8 && this->loopUnroll > 1 ||
        this->loopUnroll % this->numSides != 0 &&
        this->numSides % this->loopUnroll != 0)
        return -1;

    /* This is a bit of a hack.  When ObjsPerBeginEnd is applied to
     * a PolygonTest, it overwrites the setting in the creator above
     * which correctly sets this->objsPerBgnEnd to 1.  We must make
     * sure that it is set to 1, or the traveral routine gets confused
     * and will not draw all the polygons.  Therefore, we'll set
     * objsPerBgnEnd again here. 
     */
    this->objsPerBgnEnd = 1;

    return 0;
}

TestPtr Polygon__Copy(TestPtr thisTest)
{
    PolygonPtr this = (PolygonPtr)thisTest;
    PolygonPtr newPolygon = new_Polygon();
    FreeStrings((TestPtr)newPolygon);
    *newPolygon = *this;
    CopyStrings((TestPtr)newPolygon, (TestPtr)this);
    return (TestPtr)newPolygon;
}

void Polygon__Layout(VertexPtr thisVertex)
{
    PolygonPtr this = (PolygonPtr)thisVertex;
    const double pi=3.141592654;
    double ndcSize, lengthSide, halfWidth, radius;
    double theta, theta0, deltaTheta;
    GLfloat x, y;
    GLfloat *src, *dst;
    GLfloat *newTraversalData;
    int numFrontIn, numFrontOut, numFrontClip;
    int numBackIn, numBackOut, numBackClip;
    int frontIn, frontOut, frontClip, backIn, backOut, backClip;
    GLfloat face=1.0;
    int i, j;
    GLfloat facingFront = this->facingFront;
    GLfloat facingBack  = this->facingBack;
    int   numObjects  = this->numObjects;
    GLfloat acceptObjs  = this->acceptObjs;
    GLfloat rejectObjs  = this->rejectObjs;
    GLfloat clipObjs     = this->clipObjs;
    int   windowDim   = min(this->environ.windowWidth, this->environ.windowHeight);
    int   orientation = this->orientation;
    GLfloat size        = this->size;
    int   objsPerBgnEnd  = this->objsPerBgnEnd;

    this->vertsPerFacet = this->numSides;

    /* These will/could be used in traversal function */
    this->vertsPerBgnEnd = this->vertsPerFacet;
    this->facetsPerBgnEnd = 1;

    /* Figure front facing/back facing stuff */
    if (fabs(1.0 - facingFront - facingBack) > .01) {
	printf("FrontFacing + BackFacing not equal to 1\n");
	exit(1);
    }
    numFrontIn = floor((GLfloat)numObjects * acceptObjs * facingFront + 0.5);
    numFrontOut = floor((GLfloat)numObjects * rejectObjs * facingFront + 0.5);
    numFrontClip = floor((GLfloat)numObjects * clipObjs * facingFront + 0.5);
    numBackIn = floor((GLfloat)numObjects * acceptObjs * facingBack + 0.5);
    numBackOut = floor((GLfloat)numObjects * rejectObjs * facingBack + 0.5);
    numBackClip = floor((GLfloat)numObjects * clipObjs * facingBack + 0.5);
    numFrontIn += numObjects - numFrontIn - numFrontOut - numFrontClip
                             - numBackIn - numBackOut - numBackClip;
    frontIn = frontOut = frontClip = backIn = backOut = backClip = 0;

    /* Figure polygon dimensions given polygon size in pixels and number of sides */
    ndcSize = size/(double)windowDim/(double)windowDim*4.0;
    halfWidth = sqrt(ndcSize/(double)this->numSides/tan(pi/(double)this->numSides));
    lengthSide = 2.0*ndcSize/halfWidth/(double)this->numSides;
    radius = sqrt(sq(lengthSide/2.0) + sq(halfWidth));
    deltaTheta = 2.0*pi/(double)this->numSides;

    /* Use Vertex__Layout() to get polygon centers */
    this->layoutPoints = numObjects;
    this->layoutPadding = radius;
    this->layoutPadding += 1./(float)windowDim;
    Vertex__Layout(thisVertex);

    /* Allocate necessary data */
    src = this->traversalData;
    newTraversalData = (GLfloat*)malloc(numObjects * this->numSides * 2 * sizeof(GLfloat));
    CheckMalloc(newTraversalData);
    dst = newTraversalData;

    /* Figure initial theta position for orientation */
    switch (orientation) {
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
    for (i=0; i<numObjects; i++) {
	x = *src++;
	y = *src++;
	if (orientation == Random)
            theta0 = 2.0*pi*(double)myrand()/(double)MY_RAND_MAX;
	if ((x==-1 || x==1) && (-1<=y && y<=1) || (y==-1 || y==1) && (-1<=x && x<=1)) {
	    /* The vertex is clipped (on the viewport boundary) */
	    if (frontClip < numFrontClip) {
		frontClip++;
		face = 1.0;
	    } else {
		backClip++;
		face = -1.0;
	    }
	} else if (-1<=x && x<=1 && -1<=y && y<=1) {
	    /* The vertex is in the viewport */
	    if (frontIn < numFrontIn) {
		frontIn++;
		face = 1.0;
	    } else {
		backIn++;
		face = -1.0;
	    }
	} else {
	    /* The vertex is outside the viewport */
	    if (frontOut < numFrontOut) {
		frontOut++;
		face = 1.0;
	    } else {
		backOut++;
		face = -1.0;
	    }
	}
	theta = theta0;
	for (j=0; j<this->numSides; j++) {
	    *dst++ = radius * cos(theta) + x;
	    *dst++ = radius * sin(theta) + y;
	    theta += face*deltaTheta;
	}
    }
    free(this->traversalData);
    this->traversalData = newTraversalData;
}
