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

#include "Clear.h"
#include "ClearX.h"

#undef offset
#define offset(v) offsetof(Clear,v)

static InfoItem ClearInfo[] = {
#define INC_REASON INFO_ITEM_ARRAY
#include "Clear.h"
#undef INC_REASON
};
#include <malloc.h>

ClearPtr new_Clear()
{
    ClearPtr this = (ClearPtr)malloc(sizeof(Clear));
    CheckMalloc(this);
    new_Drawn((DrawnPtr)this);
    SetDefaults((TestPtr)this, ClearInfo);
    this->testType = ClearTest;
    this->usecPixelPrint = " microseconds per pixel in a Clear";
    this->ratePixelPrint = " pixels per second in a Clear";
    this->usecPrint = " microseconds per Clear";
    this->ratePrint = " Clears per second";
    /* Set virtual functions */
    this->SetState = Clear__SetState;
    this->delete = delete_Clear;
    this->Initialize = Clear__Initialize;
    this->Cleanup = Clear__Cleanup;
    this->SetExecuteFunc = Clear__SetExecuteFunc;
    this->Copy = Clear__Copy;
    this->PixelSize = Clear__Size;
    return this;
}

void delete_Clear(TestPtr thisTest)
{
    ClearPtr this = (ClearPtr)thisTest;
    delete_Drawn(thisTest);
}

TestPtr Clear__Copy(TestPtr thisTest)
{
    ClearPtr this = (ClearPtr)thisTest;
    ClearPtr newClear = new_Clear();
    FreeStrings((TestPtr)newClear);
    *newClear = *this;
    CopyStrings((TestPtr)newClear, (TestPtr)this);
    return (TestPtr)newClear;
}

int Clear__SetState(TestPtr thisTest)
{
    ClearPtr this = (ClearPtr)thisTest;
    if (Drawn__SetState(thisTest) == -1) return -1;
    this->mask = (this->clearColor) ? GL_COLOR_BUFFER_BIT : 0;
    this->mask |= (this->clearDepth) ? GL_DEPTH_BUFFER_BIT : 0;
    this->mask |= (this->clearStencil) ? GL_STENCIL_BUFFER_BIT : 0;
    this->mask |= (this->clearAccum) ? GL_ACCUM_BUFFER_BIT : 0;
    if (this->environ.bufConfig.rgba) {
        glColor3ub(0xff, 0xff, 0xff);
        switch (this->colorOfClear) {
            case Red:
                glClearColor(0xff, 0x00, 0x00, 0xff);
                break;
            case Green:
                glClearColor(0x00, 0xff, 0x00, 0xff);
                break;
            case Blue:
                glClearColor(0x00, 0x00, 0xff, 0xff);
                break;
            case Magenta:
                glClearColor(0xff, 0x00, 0xff, 0xff);
                break;
            case Cyan:
                glClearColor(0x00, 0xff, 0xff, 0xff);
                break;
            case Yellow:
                glClearColor(0xff, 0xff, 0x00, 0xff);
                break;
            case Grey:
                glClearColor(0xef, 0xef, 0xef, 0xff);
                break;
            case White:
                glClearColor(0xff, 0xff, 0xff, 0xff);
                glColor3ub(0x00, 0x00, 0x00);
                break;
            case Black:
                glClearColor(0x00, 0x00, 0x00, 0xff);
                break;
        }
    } else { /* CIVisual */
        glClearIndex(this->clearIndex);
    }
    /* For clears only, set the scissor to base off of window size */
    if (this->scissorTest) {
        glScissor(10,10,this->environ.windowWidth-20,this->environ.windowHeight-20);
    }
    if (this->pointDraw) {
        /* set projection matrix */
        glMatrixMode(GL_PROJECTION);
        glLoadIdentity();
        glOrtho(-1.0,1.0,-1.0,1.0,0.5,10.0);
        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();
    }
    return 0;
}

void Clear__Initialize(TestPtr thisTest)
{
    ClearPtr this = (ClearPtr)thisTest;
    this->numObjects = 1;
}

void Clear__Cleanup(TestPtr thisTest)
{
    ClearPtr this = (ClearPtr)thisTest;
}

void Clear__SetExecuteFunc(TestPtr thisTest)
{
    ClearPtr this = (ClearPtr)thisTest;
    ClearFunc function;

    function.word = 0;

    function.bits.pointDraw = this->pointDraw;
    function.bits.functionPtrs = this->loopFuncPtrs;
    function.bits.unrollAmount  = this->loopUnroll - 1;

    this->Execute = ClearExecuteTable[function.word];
}

float Clear__Size(TestPtr thisTest)
{
    ClearPtr this = (ClearPtr)thisTest;
    return (float)(this->environ.windowWidth * this->environ.windowHeight);
}
