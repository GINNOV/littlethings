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
#include "Quads.h"

#define sq(val) ((val)*(val))

#undef offset
#define offset(v) offsetof(Quads,v)

static InfoItem QuadsInfo[] = {
#define INC_REASON INFO_ITEM_ARRAY
#include "Quads.h"
#undef INC_REASON
};
#include <malloc.h>

QuadsPtr new_Quads()
{
    QuadsPtr this = (QuadsPtr)malloc(sizeof(Quads));
    CheckMalloc(this);
    new_Polygonal((PolygonalPtr)this);
    SetDefaults((TestPtr)this, QuadsInfo);
    this->testType = QuadsTest;
    this->primitiveType = GL_QUADS;
    this->vertsPerFacet = 4;
    this->usecPixelPrint = " microseconds per pixel with Quads";
    this->ratePixelPrint = " pixels per second with Quads";
    this->usecPrint = " microseconds per Quad";
    this->ratePrint = " Quads per second";
    /* Set virtual functions */
    this->delete = delete_Quads;
    this->Layout = Quads__Layout;
    this->Copy = Quads__Copy;
    return this;
}

void delete_Quads(TestPtr thisTest)
{
    QuadsPtr this = (QuadsPtr)thisTest;
    delete_Polygonal(thisTest);
}

TestPtr Quads__Copy(TestPtr thisTest)
{
    QuadsPtr this = (QuadsPtr)thisTest;
    QuadsPtr newQuads = new_Quads();
    FreeStrings((TestPtr)newQuads);
    *newQuads = *this;
    CopyStrings((TestPtr)newQuads, (TestPtr)this);
    return (TestPtr)newQuads;
}

void Quads__Layout(VertexPtr thisVertex)
{
    QuadsPtr this = (QuadsPtr)thisVertex;
    const double pi=3.141592654;
    double ndcSize, width, height, radius;
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
    int numObjects  = this->numObjects;
    GLfloat acceptObjs  = this->acceptObjs;
    GLfloat rejectObjs  = this->rejectObjs;
    GLfloat clipObjs     = this->clipObjs;
    int   windowDim   = min(this->environ.windowWidth, this->environ.windowHeight);
    int   orientation = this->orientation;
    GLfloat size        = this->size;
    int   objsPerBgnEnd  = this->objsPerBgnEnd;

    /* Use Vertex__Layout() and Vertex__orientation to choose layout */
    this->vertsPerBgnEnd = objsPerBgnEnd * this->vertsPerFacet;
    this->facetsPerBgnEnd = objsPerBgnEnd;

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
    width = sqrt(ndcSize/this->aspect);
    height = ndcSize/width;
    radius = sqrt(sq(height/2.0) + sq(width/2.0));
    deltaTheta = atan(height/width);

    /* Use Vertex__Layout() to get polygon centers */
    this->layoutPoints = numObjects;
    switch (orientation) {
	case Vertical:
	case Horizontal:
            this->layoutPadding = max(width,height)/2.;
	    break;
	case Random:
            this->layoutPadding = radius;
	    break;
    }
    this->layoutPadding += (1. + (this->antiAlias!=Off))/
                           (float)windowDim;
    Vertex__Layout(thisVertex);

    /* Allocate necessary data */
    src = this->traversalData;
    newTraversalData = (GLfloat*)malloc(numObjects * 4 * 2 * sizeof(GLfloat));
    CheckMalloc(newTraversalData);
    dst = newTraversalData;

    /* Figure initial theta position for orientation */
    switch (orientation) {
	case Horizontal:
	    theta0 = deltaTheta;
	    break;
	case Vertical:
	    theta0 = deltaTheta + pi/2.0;
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
	for (j=0; j<4; j++) {
	    *dst++ = radius * cos(theta) + x;
	    *dst++ = radius * sin(theta) + y;
	    theta += face*((j&1) ? (2.0*deltaTheta) : (pi-2.0*deltaTheta));
	}
    }
    free(this->traversalData);
    this->traversalData = newTraversalData;
}
