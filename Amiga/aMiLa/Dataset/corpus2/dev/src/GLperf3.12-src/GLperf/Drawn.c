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

#include "Drawn.h"
#include <malloc.h>

void new_Drawn(DrawnPtr this)
{
    new_Test((TestPtr)this);
/* Not adequately supported yet.  Will add as enhancement, if necessary
    this->feedbackBuffer = NULL;
*/
}

void delete_Drawn(TestPtr thisTest)
{
    DrawnPtr this = (DrawnPtr)thisTest;

/* Not adequately supported yet.  Will add as enhancement, if necessary
    if (this->feedbackBuffer) free(this->feedbackBuffer);
*/
    delete_Test(thisTest);
}

int Drawn__SetState(TestPtr thisTest)
{
    DrawnPtr this = (DrawnPtr)thisTest;
    int windowDim;

    /* set parent GL state */
    if (Test__SetState(thisTest) == -1) return -1;

    /* set own state */

    windowDim = min(this->environ.windowWidth, this->environ.windowHeight);

/* Not adequately supported yet.  Will add as enhancement, if necessary
    if (this->renderMode==GL_FEEDBACK) {
	this->feedbackBuffer = (GLfloat*)malloc(100000*sizeof(GLfloat));
        CheckMalloc(this->feedbackBuffer);
	glFeedbackBuffer(100000,this->feedbackType,this->feedbackBuffer);
    }
*/
    glRenderMode(this->renderMode);

    glViewport(0, 0, windowDim, windowDim);

    /* set up scissoring */
    if (this->scissorWidth == -1) {
	this->scissorWidth = this->environ.windowWidth;
    }
    if (this->scissorHeight == -1) {
	this->scissorHeight = this->environ.windowHeight;
    }

    if (this->scissorTest) {
	glScissor(this->scissorX, this->scissorY,
                  this->scissorWidth, this->scissorHeight);
	glEnable(GL_SCISSOR_TEST);
    } else {
	glDisable(GL_SCISSOR_TEST);
    }

    if (this->dithering) {
	glEnable(GL_DITHER);
    } else {
	glDisable(GL_DITHER);
    }

    glDrawBuffer(this->drawBuffer);

    /* set up masking */
    if (this->environ.bufConfig.rgba) {
	switch (this->colorMask) {
            case TTTT:
		glColorMask(GL_TRUE , GL_TRUE , GL_TRUE , GL_TRUE );
		break;
            case TTTF:
		glColorMask(GL_TRUE , GL_TRUE , GL_TRUE , GL_FALSE);
		break;
            case TTFT:
		glColorMask(GL_TRUE , GL_TRUE , GL_FALSE, GL_TRUE );
		break;
            case TTFF:
		glColorMask(GL_TRUE , GL_TRUE , GL_FALSE, GL_FALSE);
		break;
            case TFTT:
		glColorMask(GL_TRUE , GL_FALSE, GL_TRUE , GL_TRUE );
		break;
            case TFTF:
		glColorMask(GL_TRUE , GL_FALSE, GL_TRUE , GL_FALSE);
		break;
            case TFFT:
		glColorMask(GL_TRUE , GL_FALSE, GL_FALSE, GL_TRUE );
		break;
            case TFFF:
		glColorMask(GL_TRUE , GL_FALSE, GL_FALSE, GL_FALSE);
		break;
            case FTTT:
		glColorMask(GL_FALSE, GL_TRUE , GL_TRUE , GL_TRUE );
		break;
            case FTTF:
		glColorMask(GL_FALSE, GL_TRUE , GL_TRUE , GL_FALSE);
		break;
            case FTFT:
		glColorMask(GL_FALSE, GL_TRUE , GL_FALSE, GL_TRUE );
		break;
            case FTFF:
		glColorMask(GL_FALSE, GL_TRUE , GL_FALSE, GL_FALSE);
		break;
            case FFTT:
		glColorMask(GL_FALSE, GL_FALSE, GL_TRUE , GL_TRUE );
		break;
            case FFTF:
		glColorMask(GL_FALSE, GL_FALSE, GL_TRUE , GL_FALSE);
		break;
            case FFFT:
		glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_TRUE );
		break;
            case FFFF:
		glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_FALSE);
		break;
	}
    } else {
	glIndexMask(this->indexMask);
    }
    return 0;
}
