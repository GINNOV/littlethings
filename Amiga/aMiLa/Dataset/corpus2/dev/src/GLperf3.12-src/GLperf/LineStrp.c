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
#include "LineStrp.h"

#undef offset
#define offset(v) offsetof(LineStrip,v)

static InfoItem LineStripInfo[] = {
#define INC_REASON INFO_ITEM_ARRAY
#include "LineStrp.h"
#undef INC_REASON
};
#include <malloc.h>

LineStripPtr new_LineStrip()
{
    LineStripPtr this = (LineStripPtr)malloc(sizeof(LineStrip));
    CheckMalloc(this);
    new_Linear((LinearPtr)this);
    SetDefaults((TestPtr)this, LineStripInfo);
    this->testType = LineStripTest;
    this->primitiveType = GL_LINE_STRIP;
    this->vertsPerFacet = 1;
    this->usecPixelPrint = " microseconds per pixel with Line Strip";
    this->ratePixelPrint = " pixels per second with Line Strip";
    this->usecPrint = " microseconds per Line in a Line Strip";
    this->ratePrint = " Lines per second in a Line Strip";
    /* Set virtual functions */
    this->delete = delete_LineStrip;
    this->Layout = LineStrip__Layout;
    this->Copy = LineStrip__Copy;
    return this;
}

void delete_LineStrip(TestPtr thisTest)
{
    LineStripPtr this = (LineStripPtr)thisTest;
    delete_Linear(thisTest);
}

TestPtr LineStrip__Copy(TestPtr thisTest)
{
    LineStripPtr this = (LineStripPtr)thisTest;
    LineStripPtr newLineStrip = new_LineStrip();
    FreeStrings((TestPtr)newLineStrip);
    *newLineStrip = *this;
    CopyStrings((TestPtr)newLineStrip, (TestPtr)this);
    return (TestPtr)newLineStrip;
}

void LineStrip__Layout(VertexPtr thisVertex)
{
    LineStripPtr this = (LineStripPtr)thisVertex;
    int windowDim = min(this->environ.windowWidth, this->environ.windowHeight);
    GLfloat *newTraversalData;
    GLfloat *dst, *src;
    GLfloat ndcLength;
    int i, j;
    GLfloat x, y;

    /* Use orientation to choose layout */
    this->vertsPerBgnEnd = this->objsPerBgnEnd * this->vertsPerFacet + 1;
    this->facetsPerBgnEnd = this->vertsPerBgnEnd/this->vertsPerFacet;

    /* Allocate necessary data */
    newTraversalData = (GLfloat*)malloc(this->numBgnEnds * this->vertsPerBgnEnd * 2 * sizeof(GLfloat));
    CheckMalloc(newTraversalData);
    dst = newTraversalData;

    ndcLength = this->size/(GLfloat)windowDim*2.0;
    
    if (this->orientation == Random) {
        GLfloat random_angle;
        const double pi=3.141592654;
        GLfloat new_x, new_y;
	GLfloat edgePad = (1. + this->lineWidth/2. + (this->antiAlias!=Off))/ 
                          (float)windowDim;
	mysrand(15000);

        /* Use Vertex__Layout to get line starts */
        this->layoutPoints = this->numBgnEnds;
        this->layoutPadding = ndcLength;
        this->layoutPadding += edgePad;
	if (this->size > (float)windowDim/2.) {
	    /* If lines are long, position begining points at edge */
	    this->acceptObjs = 0.0;
	    this->rejectObjs = 0.0;
	    this->clipObjs = 1.0;
	} else {
	    this->acceptObjs = 1.0;
	    this->rejectObjs = 0.0;
	    this->clipObjs = 0.0;
	}
        Vertex__Layout(thisVertex);
	/* Restore state */
	this->acceptObjs = 1.0;
	this->rejectObjs = 0.0;
	this->clipObjs = 0.0;

        src = this->traversalData;
        dst = newTraversalData;

        for (i=0; i<this->numBgnEnds; i++) {
            x = *src++;
            y = *src++;
            for (j=0; j<this->vertsPerBgnEnd; j++) {
                *dst++ = x;
                *dst++ = y;
                do {
		    random_angle = 2.0*pi*(double)myrand()/(double)MY_RAND_MAX;
		    new_x = x + ndcLength * cos(random_angle);
		    new_y = y + ndcLength * sin(random_angle);
                } while (new_x <= -1.0 + edgePad || 1.0 - edgePad <= new_x || 
                         new_y <= -1.0 + edgePad || 1.0 - edgePad <= new_y);
		x = new_x;
		y = new_y;
            }
        }
        free(this->traversalData);
    } else {
        enum {Horz, Vert} direction;
        GLfloat horz, vert;
        int bounced = True;
        int row = 0;
        for (i=0; i<this->numBgnEnds; i++) {
            if (bounced) {
                x = -1.0;
                y = fmod(row * ndcLength, 2.0) - 1.0;
                horz = ndcLength;
                vert = -ndcLength;
                direction = Horz;
                bounced = False;
                row+=2;
            }
            for (j=0; j<this->vertsPerBgnEnd; j++) {
                if (direction == Horz) {
                    if (x+horz <= -1.0 || 1.0 <= x+horz) {
                        horz *= -1.0;
                        bounced = True;
                    }
                    x += horz;
                    direction = Vert;
                } else {
                    y += vert;
                    vert *= -1.0;
                    direction = Horz;
                }
                *dst++ = x;
                *dst++ = y;
            }
        }
    }
    this->traversalData = newTraversalData;
}
