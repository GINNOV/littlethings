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
#include "Tris.h"

#define sq(val) ((val)*(val))

#if !defined(max)
 #define max(a,b) ((a)>(b)?(a):(b))
#endif

#undef offset
#define offset(v) offsetof(Triangles,v)

static InfoItem TrianglesInfo[] = {
#define INC_REASON INFO_ITEM_ARRAY
#include "Tris.h"
#undef INC_REASON
};
#include <malloc.h>

TrianglesPtr new_Triangles()
{
    TrianglesPtr this = (TrianglesPtr)malloc(sizeof(Triangles));
    CheckMalloc(this);
    new_Polygonal((PolygonalPtr)this);
    SetDefaults((TestPtr)this, TrianglesInfo);
    this->testType = TrianglesTest;
    this->primitiveType = GL_TRIANGLES;
    this->vertsPerFacet = 3;
    this->usecPixelPrint = " microseconds per pixel with disjoint Triangles";
    this->ratePixelPrint = " pixels per second with disjoint Triangles";
    this->usecPrint = " microseconds per Triangle in a disjoint Triangles call";
    this->ratePrint = " Triangles per second in a disjoint Triangles call";
    /* Set virtual functions */
    this->delete = delete_Triangles;
    this->Layout = Triangles__Layout;
    this->Copy = Triangles__Copy;
    return this;
}

void delete_Triangles(TestPtr thisTest)
{
    TrianglesPtr this = (TrianglesPtr)thisTest;
    delete_Polygonal(thisTest);
}

TestPtr Triangles__Copy(TestPtr thisTest)
{
    TrianglesPtr this = (TrianglesPtr)thisTest;
    TrianglesPtr newTriangles = new_Triangles();
    FreeStrings((TestPtr)newTriangles);
    *newTriangles = *this;
    CopyStrings((TestPtr)newTriangles, (TestPtr)this);
    return (TestPtr)newTriangles;
}

void Triangles__Layout(VertexPtr thisVertex)
{
    TrianglesPtr this = (TrianglesPtr)thisVertex;
    const double pi=3.141592654;
    double ndcSize, width, height, radius0, radius1;
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
    int windowDim = min(this->environ.windowWidth, this->environ.windowHeight);

    /* Use Vertex__Layout() and Vertex__orientation to choose layout */
    this->vertsPerBgnEnd = this->objsPerBgnEnd * this->vertsPerFacet;
    this->facetsPerBgnEnd = this->objsPerBgnEnd;

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
    ndcSize = this->size/(double)windowDim/(double)windowDim*4.0;
    width = sqrt(2.0*ndcSize/this->aspect);
    height = 2.0*ndcSize/width;
    radius0 = sqrt(sq(height/3.0) + sq(width/2.0));
    radius1 = 2.0*height/3.0;
    deltaTheta = pi - atan(3.0*width/2.0/height);

    /* Use Vertex__Layout() to get polygon centers */
    this->layoutPoints = numObjects;
    this->layoutPadding = max(radius0,radius1);
    this->layoutPadding += (1. + (this->antiAlias!=Off))/
                           (float)windowDim;
    Vertex__Layout(thisVertex);

    /* Allocate necessary data */
    src = this->traversalData;
    newTraversalData = (GLfloat*)malloc(numObjects * 2 * 3 * sizeof(GLfloat));
    CheckMalloc(newTraversalData);
    dst = newTraversalData;

    /* Figure initial theta position for orientation */
    switch (this->orientation) {
	case Horizontal:
	    theta0 = -deltaTheta + pi/2.0;
	    break;
	case Vertical:
	    theta0 = -deltaTheta;
	    break;
	case Random:
            mysrand(15000);
	    break;
    }

    /* Generate those vertices around the point centers */
    for (i=0; i<numObjects; i++) {
	x = *src++;
	y = *src++;
	if (this->orientation == Random)
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
	for (j=0; j<3; j++) {
	    *dst++ = ((j&1) ? radius1 : radius0) * cos(theta) + x;
	    *dst++ = ((j&1) ? radius1 : radius0) * sin(theta) + y;
	    theta += face*deltaTheta;
	}
    }
    free(this->traversalData);
    this->traversalData = newTraversalData;
}
