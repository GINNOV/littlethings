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
// Author:  Barry Minor, IBM AWS Graphics Systems (Austin)
//
*/

#include <math.h>
#include "QuadStrp.h"

#undef offset
#define offset(v) offsetof(QuadStrip,v)

static InfoItem QuadStripInfo[] = {
#define INC_REASON INFO_ITEM_ARRAY
#include "QuadStrp.h"
#undef INC_REASON
};
#include <malloc.h>

QuadStripPtr new_QuadStrip()
{
    QuadStripPtr this = (QuadStripPtr)malloc(sizeof(QuadStrip));
    CheckMalloc(this);
    new_Polygonal((PolygonalPtr)this);
    SetDefaults((TestPtr)this, QuadStripInfo);
    this->testType = QuadStripTest;
    this->primitiveType = GL_QUAD_STRIP;
    this->vertsPerFacet = 2;
    this->usecPixelPrint = " microseconds per pixel with Quad Strip";
    this->ratePixelPrint = " pixels per second with Quad Strip";
    this->usecPrint = " microseconds per Quad in a Quad Strip";
    this->ratePrint = " Quads per second in a Quad Strip";
    /* Set virtual functions */
    this->delete = delete_QuadStrip;
    this->Layout = QuadStrip__Layout;
    this->Copy = QuadStrip__Copy;
    return this;
}

void delete_QuadStrip(TestPtr thisTest)
{
    QuadStripPtr this = (QuadStripPtr)thisTest;
    delete_Polygonal(thisTest);
}

TestPtr QuadStrip__Copy(TestPtr thisTest)
{
    QuadStripPtr this = (QuadStripPtr)thisTest;
    QuadStripPtr newQuadStrip = new_QuadStrip();
    FreeStrings((TestPtr)newQuadStrip);
    *newQuadStrip = *this;
    CopyStrings((TestPtr)newQuadStrip, (TestPtr)this);
    return (TestPtr)newQuadStrip;
}

static GLfloat* LayoutRandomQStrip(QuadStripPtr this, GLfloat *startingPoint)
{
    GLfloat *strip, *dst;
    GLfloat x0, y0;
    GLfloat x1, y1;
    GLfloat x2, y2;
    int i, j, k;
    int windowDim = min(this->environ.windowWidth, this->environ.windowHeight);
    GLfloat ndcSize = this->size/(GLfloat)windowDim/(GLfloat)windowDim*4.0 / 2.;
    GLfloat distThreshold = sqrt(ndcSize*3.0);
    GLfloat dist;
    GLfloat radius = sqrt(ndcSize*2.0);
    GLfloat random_angle, theta;
    GLfloat t;
    const GLfloat pi=3.141592654;
    const int maxTries = 1000;
    int objsPerBgnEnd = this->objsPerBgnEnd;

    /* Here's all the facing and winding stuff */
    int numTries;
    GLfloat initialWinding;
    GLfloat facingFront = this->facingFront;
    GLfloat facingBack  = this->facingBack;
    int numFront, numBack, tmpNum;
    int twistsPerStrip = this->twistsPerStrip;
    int frontTwists, backTwists;
    int numPerFrontTwist, numPerBackTwist;
    int front, back;
    float *winding;
    int face;

    /* These are variables for walking the strip */
    int begin, end, firsttry, tenacity;

    /* We'll be working with triangles here instead of quads as the
     * triangle strip random walk code was done first and there's no
     * sense in reinventing the wheel, especially with code this complex!
     * The ndcSize used above is divided by 2. to reflect the change into
     * triangles from quads.
     */

    /* Figure frontfacing/backfacing stuff */
    if (fabs(1.0 - facingFront - facingBack) > .01) {
        printf("GLperf: FrontFacing + BackFacing not equal to 1\n");
        exit(1);
    }
    numFront = floor((GLfloat)objsPerBgnEnd * facingFront + 0.5);
    numBack = floor((GLfloat)objsPerBgnEnd * facingBack + 0.5);
    numFront += objsPerBgnEnd - numFront - numBack;
    if (numFront >= numBack) {
	/* Start off front facing */
	initialWinding = 1.;
    } else {
	/* Start off back facing */
	initialWinding = -1.;
	/* Reverse front and back numbers (see note below) */
	tmpNum = numFront;
	numFront = numBack;
	numBack = tmpNum;
    }
    /* Note to the reader here:
     * "front" here does not necessarily mean "front-facing", but
     * merely the direction that the triangles are facing when the
     * strip starts.  Conversely, "back" does not mean "back-facing",
     * but is the opposite direction of the strip's initial facing.
     * It's confusing, but it makes the loop simpler below.
     */
    frontTwists = (twistsPerStrip + 2) / 2;
    backTwists  = (twistsPerStrip + 1) / 2;
    if (numFront < frontTwists || numBack < backTwists) {
	printf("GLperf: So many twists per strip... so few triangles.\n");
	exit(1);
    }
    numPerFrontTwist = (numFront + frontTwists - 1) / frontTwists;
    if (backTwists != 0)
        numPerBackTwist = (numBack + backTwists - 1) / backTwists;
    else
        numPerBackTwist = 0;

    /* Allocate necessary data */
    strip = (GLfloat*)malloc(this->vertsPerBgnEnd * 2 * sizeof(GLfloat));
    CheckMalloc(strip);
    dst = strip;

    /* Pull x, y, and z from startingPoint */
    x0 = *startingPoint++;
    y0 = *startingPoint++;
    *dst++ = x0;
    *dst++ = y0;

    /* Find second point within a certain radius of the startingPoint */
    do {
        random_angle = 2.0*pi*(GLfloat)myrand()/(GLfloat)MY_RAND_MAX;
        x1 = x0 + radius * cos(random_angle);
        y1 = y0 + radius * sin(random_angle);
    } while (x1 <= -1.0 || 1.0 <= x1 || y1 <= -1.0 || 1.0 <= y1);
    *dst++ = x1;
    *dst++ = y1;

    front = 0;
    back = 0;
    /* Determine the winding for all the triangles in advance and store
     * in the "winding" array (FRONT is 1) (BACK is -1).
     * This makes the loop quite a bit easier to manage.
     */
    winding = (float*)malloc((this->twistsPerStrip+1) * numFront * 2 * sizeof(float));
    face = initialWinding;
    k = 0;
    for (i=0; i<twistsPerStrip+1; i++) {
	for (j=0; j < ((i&1) ? numPerBackTwist : numPerFrontTwist); j++) {
	    winding[k] = face * ((k&1) ? -1. : 1.);
	    winding[k+1] = face * ((k&1) ? 1. : -1.);
	    k += 2;
	}
	face *= -1;
    }
    /* objsPerBgnEnd must double to reflect our working in triangles rather
     * than quads
     */
    objsPerBgnEnd *= 2;

    begin = 0;
    end = objsPerBgnEnd;
    tenacity = maxTries;
    firsttry = 1;
    do {
        for (i=begin; i<end; i++) {
	    /* Find a point to create the next triangle in the strip */
    	    numTries = 0;
    	    do {
                random_angle = pi * (GLfloat)myrand()/(GLfloat)MY_RAND_MAX;
    	        theta = random_angle - atan2(y1 - y0, x1 - x0);
    	        while (theta<0.0) theta+=2.*pi;
    	        while (theta>2.*pi) theta-=2.*pi;
    	        t = winding[i] * 2. * ndcSize / 
                    (cos(theta)*(y0 - y1) - sin(theta)*(x0 - x1));
    	        x2 = t * cos(theta) + x1;
    	        y2 = t * sin(theta) + y1;
	        numTries++;
    	        /* Measure distance between last two points; this will keep
    	           the triangles in the strip from being too long and thin */
    	        dist = sqrt((y2 - y1)*(y2 - y1) + (x2 - x1)*(x2 - x1));
    	    } while ((x2 <= -1. || 1. <= x2 || y2 <= -1. || 1. <= y2 || 
                     dist > distThreshold) && numTries < tenacity);
            /* if it couldn't find a vertex, break out */
    	    if (numTries == tenacity) break;
    	    /* Store vertex in strip and rotate vertices */
    	    *dst++ = x2;
    	    *dst++ = y2;
    	    x0 = x1;
    	    y0 = y1;
    	    x1 = x2;
    	    y1 = y2;
        }
        if (i < end) {
	    /* Didn't finish the loop above, so we must have
	     * gotten stuck.  Better back up a vertex and
	     * try to turn the strip around.
             */
	    if (firsttry == 1) {
	        firsttry = 0;
	        begin = i;
	    } 
	    if (begin < 1) {
		/* We've worked our way to the begining of the
		 * strip, good time to give up on this one.
		 */
                free(strip);
	        free(winding);
	        return 0;
	    }
	    begin -= 1;
	    end = i + 1;
	    tenacity += 1000;
	    /* Back up to the beginth vertex */
	    dst = (strip + 4) + 2 * begin;
	    x0 = *(dst-4);
	    y0 = *(dst-3);
	    x1 = *(dst-2);
	    y1 = *(dst-1);
        } else {
	    /* Success!  Turned around! Let's try to finish strip */
	    begin = i;
	    end = objsPerBgnEnd;
	    tenacity = maxTries;
        }
    } while (i < objsPerBgnEnd);
    
    free(winding);
    return strip;
}

void QuadStrip__Layout(VertexPtr thisVertex)
{
    QuadStripPtr this = (QuadStripPtr)thisVertex;
    int windowDim = min(this->environ.windowWidth, this->environ.windowHeight);

    GLfloat ndcSize = this->size/(double)windowDim/(double)windowDim*4.0;
    GLfloat width = sqrt(ndcSize/this->aspect);
    GLfloat height = ndcSize/width;

    GLfloat *newTraversalData, *dst;

    int i, j;
    GLfloat x, y;
    GLfloat horz, vert;
    int bounced = True;
    int row = 0;
    int step = 0;

    this->vertsPerBgnEnd = this->objsPerBgnEnd * this->vertsPerFacet + 2;
    this->facetsPerBgnEnd = this->vertsPerBgnEnd/this->vertsPerFacet;
    /* Allocate necessary data */
    newTraversalData = (GLfloat*)malloc(this->numBgnEnds * this->vertsPerBgnEnd * 2 * sizeof(GLfloat));
    CheckMalloc(newTraversalData);
    dst = newTraversalData;

    if (this->orientation == Random) {
	/* Choosing random orientation necessitates blowing off aspect ratios */
	GLfloat *newStrip, *src;
        /* Use Vertex__Layout() to get strip starting points*/
        this->layoutPoints = this->numBgnEnds;
        this->layoutPadding = sqrt(2.0*ndcSize);
        this->layoutPadding += (1. + (this->antiAlias!=Off))/
                           (float)windowDim;
        Vertex__Layout(thisVertex);
	src = this->traversalData;
	mysrand(15000);
        for (i=0; i<this->numBgnEnds; i++) {
	    /* Repeat strip walking until a legitimate one comes up */
	    const int maxTries = 10;
	    int numTries;
	    for (numTries = 0; 
                 numTries < maxTries && 
                 ((newStrip = LayoutRandomQStrip(this, src)) == 0);
		 numTries++);
	    if (numTries == maxTries) {
		 printf("GLperf: Error in Quad Strip creation\n");
		 exit(1);
	    }
	    /* Copy newStrip to traversalData */
	    memcpy(dst, newStrip, this->vertsPerBgnEnd * sizeof(GLfloat) * 2);
	    dst += this->vertsPerBgnEnd * 2;
	    free(newStrip);
	    src += 2;
	}
	free(this->traversalData);
    } else {
        for (i=0; i<this->numBgnEnds; i++) {
            if (bounced) {
                x = -1.0;
                y = fmod(row * height, 2.0) - 1.0;
                horz = width;
                vert = height;
                bounced = False;
                if(y+vert > 1.0) {
                    row+=2;
                    y = fmod(row * height, 2.0) - 1.0;
                }
                row+=2;
                step = 0;
            }
            for (j=0; j<this->vertsPerBgnEnd; j++) {
                if (x+horz <= -1.0 || 1.0 <= x+horz) {
                    horz *= -1.0;
                    bounced = True;
                }
                if(step++ < 2) {
                    y += vert;
                    vert *= -1.0;
                } else {
                    x += horz;
                    y += vert;
                    vert *= -1.0;
                    step = 1;
                }
                if(this->orientation == Vertical) {
                    *dst++ = y;
                    *dst++ = x;
                } else {
                    *dst++ = x;
                    *dst++ = y;
                }
            }
        }
    }
    this->traversalData = newTraversalData;
}
