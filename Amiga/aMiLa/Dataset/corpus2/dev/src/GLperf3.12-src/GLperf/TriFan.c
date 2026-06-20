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
#include "TriFan.h"

#define sq(val) ((val)*(val))

#undef offset
#define offset(v) offsetof(TriangleFan,v)

static InfoItem TriangleFanInfo[] = {
#define INC_REASON INFO_ITEM_ARRAY
#include "TriFan.h"
#undef INC_REASON
};
#include <malloc.h>

TriangleFanPtr new_TriangleFan()
{
    TriangleFanPtr this = (TriangleFanPtr)malloc(sizeof(TriangleFan));
    CheckMalloc(this);
    new_Polygonal((PolygonalPtr)this);
    SetDefaults((TestPtr)this, TriangleFanInfo);
    this->testType = TriangleFanTest;
    this->primitiveType = GL_TRIANGLE_FAN;
    this->vertsPerFacet = 1;
    this->usecPixelPrint = " microseconds per pixel with Triangle Fan";
    this->ratePixelPrint = " pixels per second with Triangle Fan";
    this->usecPrint = " microseconds per Triangle in a Triangle Fan";
    this->ratePrint = " Triangles per second in a Triangle Fan";
    /* Set virtual functions */
    this->delete = delete_TriangleFan;
    this->Layout = TriangleFan__Layout;
    this->Copy = TriangleFan__Copy;
    return this;
}

void delete_TriangleFan(TestPtr thisTest)
{
    TriangleFanPtr this = (TriangleFanPtr)thisTest;
    delete_Polygonal(thisTest);
}

TestPtr TriangleFan__Copy(TestPtr thisTest)
{
    TriangleFanPtr this = (TriangleFanPtr)thisTest;
    TriangleFanPtr newTriangleFan = new_TriangleFan();
    FreeStrings((TestPtr)newTriangleFan);
    *newTriangleFan = *this;
    CopyStrings((TestPtr)newTriangleFan, (TestPtr)this);
    return (TestPtr)newTriangleFan;
}

void TriangleFan__Layout(VertexPtr thisVertex)
{
    TriangleFanPtr this = (TriangleFanPtr)thisVertex;
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
    GLfloat numObjects  = this->numObjects;
    GLfloat acceptObjs  = this->acceptObjs;
    GLfloat rejectObjs  = this->rejectObjs;
    GLfloat clipObjs     = this->clipObjs;
    int   windowDim   = min(this->environ.windowWidth, this->environ.windowHeight);
    int   orientation = this->orientation;
    GLfloat size        = this->size;
    int   objsPerBgnEnd  = this->objsPerBgnEnd;
    int   layoutPoints = this->numBgnEnds;

    /* Use Vertex__Layout() and orientation to choose layout */
    this->vertsPerBgnEnd = objsPerBgnEnd * this->vertsPerFacet + 2;
    this->facetsPerBgnEnd = this->vertsPerBgnEnd/this->vertsPerFacet;

    /* Figure front facing/back facing stuff */
    if (fabs(1.0 - facingFront - facingBack) > .01) {
        printf("FrontFacing + BackFacing not equal to 1\n");
        exit(1);
    }
    numFrontIn = floor((GLfloat)layoutPoints * acceptObjs * facingFront + 0.5);
    numFrontOut = floor((GLfloat)layoutPoints * rejectObjs * facingFront + 0.5);
    numFrontClip = floor((GLfloat)layoutPoints * clipObjs * facingFront + 0.5);
    numBackIn = floor((GLfloat)layoutPoints * acceptObjs * facingBack + 0.5);
    numBackOut = floor((GLfloat)layoutPoints * rejectObjs * facingBack + 0.5);
    numBackClip = floor((GLfloat)layoutPoints * clipObjs * facingBack + 0.5);
    numFrontIn += layoutPoints - numFrontIn - numFrontOut - numFrontClip
                             - numBackIn - numBackOut - numBackClip;
    frontIn = frontOut = frontClip = backIn = backOut = backClip = 0;

    /* Figure polygon dimensions given polygon size in pixels and number of sides */
    ndcSize = size/(double)windowDim/(double)windowDim*4.0;
    if (this->vertsPerBgnEnd<5) {
	radius = sqrt(2.0*ndcSize);
	deltaTheta = pi/2.0;
    } else {
	ndcSize *= (GLfloat)objsPerBgnEnd;
	halfWidth = sqrt(ndcSize/(double)objsPerBgnEnd/tan(pi/(double)objsPerBgnEnd));
	lengthSide = 2.0*ndcSize/halfWidth/(double)objsPerBgnEnd;
	radius = sqrt(sq(lengthSide/2.0) + sq(halfWidth));
	deltaTheta = 2.0*pi/(double)objsPerBgnEnd;
    }

    this->layoutPoints = layoutPoints;
    this->layoutPadding = radius;
    this->layoutPadding += (1. + (this->antiAlias!=Off))/
                           (float)windowDim;
    Vertex__Layout(thisVertex);

    /* Allocate necessary data */
    src = this->traversalData;
    newTraversalData = (GLfloat*)malloc(this->numBgnEnds * this->vertsPerBgnEnd * 2 * sizeof(GLfloat));
    CheckMalloc(newTraversalData);
    dst = newTraversalData;

    /* Figure initial theta position for orientation */
    switch (orientation) {
        case Horizontal:
	    if (this->vertsPerBgnEnd<5) {
        	theta0 = 0.0;
	    } else {
		theta0 = 3.0*pi/2.0 - deltaTheta/2.0;
	    }
            break;
        case Vertical:
	    if (this->vertsPerBgnEnd<5) {
        	theta0 = pi/2.0;
	    } else {
		theta0 = pi - deltaTheta/2.0;
	    }
        case Random:
            mysrand(15000);
            break;
    }

    /* Generate those vertices around the point centers */
    for (i=0; i<this->numBgnEnds; i++) {
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
        theta = face*theta0;
	*dst++ = x;
	*dst++ = y;
        for (j=1; j<this->vertsPerBgnEnd; j++) {
            *dst++ = radius * cos(theta) + x;
            *dst++ = radius * sin(theta) + y;
            theta += face*deltaTheta;
        }
    }
    free(this->traversalData);
    this->traversalData = newTraversalData;
}
