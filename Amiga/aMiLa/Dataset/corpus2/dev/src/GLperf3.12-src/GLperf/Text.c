/*
 * (c) Copyright 1995, Silicon Graphics, Inc.
 * ALL RIGHTS RESERVED
 * Permission to use, copy, modify, and distribute this software for
 * any purpose and without fee is hereby granted, provided that the above
 * copyright notice appear in all copies and that both the copyright notice
 * and this permission notice appear in supporting documentation, and that
 * the name of Silicon Graphics, Inc. not be used in advertising
 * or publicity pertaining to distribution of the software without specific,
 * written prior permission.
 *
 * THE MATERIAL EMBODIED ON THIS SOFTWARE IS PROVIDED TO YOU "AS-IS"
 * AND WITHOUT WARRANTY OF ANY KIND, EXPRESS, IMPLIED OR OTHERWISE,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF MERCHANTABILITY OR
 * FITNESS FOR A PARTICULAR PURPOSE.  IN NO EVENT SHALL SILICON
 * GRAPHICS, INC.  BE LIABLE TO YOU OR ANYONE ELSE FOR ANY DIRECT,
 * SPECIAL, INCIDENTAL, INDIRECT OR CONSEQUENTIAL DAMAGES OF ANY
 * KIND, OR ANY DAMAGES WHATSOEVER, INCLUDING WITHOUT LIMITATION,
 * LOSS OF PROFIT, LOSS OF USE, SAVINGS OR REVENUE, OR THE CLAIMS OF
 * THIRD PARTIES, WHETHER OR NOT SILICON GRAPHICS, INC.  HAS BEEN
 * ADVISED OF THE POSSIBILITY OF SUCH LOSS, HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, ARISING OUT OF OR IN CONNECTION WITH THE
 * POSSESSION, USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 * US Government Users Restricted Rights
 * Use, duplication, or disclosure by the Government is subject to
 * restrictions set forth in FAR 52.227.19(c)(2) or subparagraph
 * (c)(1)(ii) of the Rights in Technical Data and Computer Software
 * clause at DFARS 252.227-7013 and/or in similar or successor
 * clauses in the FAR or the DOD or NASA FAR Supplement.
 * Unpublished-- rights reserved under the copyright laws of the
 * United States.  Contractor/manufacturer is Silicon Graphics,
 * Inc., 2011 N.  Shoreline Blvd., Mountain View, CA 94039-7311.
 *
 * Author: John Spitzer, SGI Applied Engineering
 *
 */
#include <math.h>
#include "Global.h"
#include "Text.h"
#include "TextX.h"

#undef offset
#define offset(v) offsetof(Text, v)

static InfoItem TextInfo[] = {
#define INC_REASON INFO_ITEM_ARRAY
#include "Text.h"
#undef INC_REASON
};
#include <malloc.h>

TextPtr new_Text()
{
    TextPtr this = (TextPtr)malloc(sizeof(Text));

    CheckMalloc(this);
    new_RasterPos((RasterPosPtr)this);
    SetDefaults((TestPtr)this, TextInfo);
    this->testType = TextTest;
    this->traversalData = 0;
    this->subImageData = 0;
    this->imageData = 0;
    this->usecPixelPrint = " microseconds per pixel with Text";
    this->ratePixelPrint = " pixels per second with Text";
    this->usecPrint = " microseconds per Text character";
    this->ratePrint = " Text characters per second";
    /* Set virtual functions */
    this->SetState = Text__SetState;
    this->delete = delete_Text;
    this->Copy = Text__Copy;
    this->Initialize = Text__Initialize;
    this->Cleanup = Text__Cleanup;
    this->SetExecuteFunc = Text__SetExecuteFunc;
    this->PixelSize = Text__Size;
    this->TimesRun = Text__TimesRun;
    return this;
}

void delete_Text(TestPtr thisTest)
{
    TextPtr this = (TextPtr)thisTest;

    delete_RasterPos(thisTest);
}

TestPtr Text__Copy(TestPtr thisTest)
{
    TextPtr this = (TextPtr)thisTest;
    TextPtr newText = new_Text();
    FreeStrings((TestPtr)newText);
    *newText = *this;
    CopyStrings((TestPtr)newText, (TestPtr)this);
    return (TestPtr)newText;
}

void Text__Initialize(TestPtr thisTest)
{
    TextPtr this = (TextPtr)thisTest;
    int windowDim = min(this->environ.windowWidth, this->environ.windowHeight);
    int windowArea = windowDim * windowDim;
    GLint *intTraversalData;
    GLint *srcPtr;
    GLfloat *dstPtr;
    char* textPtr;
    int i;
    char* sampleString = "aAbBcCdDeEfFgGhHiIjJkKlLmMnNoOpPqQrRsStTuUvVwWxXyYzZ0123456789";
    int sizeSample = strlen(sampleString);

    /* Create String */
    this->textString = (char*)malloc(this->charsPerString + 1);
    textPtr = this->textString;
    for (i = 0; i < this->charsPerString / sizeSample; i++) {
	memcpy(textPtr, sampleString, sizeSample);
	textPtr += sizeSample;
    }
    memcpy(textPtr, sampleString, this->charsPerString % sizeSample);
    textPtr += this->charsPerString % sizeSample;
    *textPtr = (char)0;

    TextFont__StringSize(this->textFont, this->textString,
                         &this->textWidth, &this->textWidthPadding,
                         &this->textHeight, &this->textHeightPadding);
    /* Layout RasterPos coordinates */
    this->numDrawn = 0;
    intTraversalData = CreateSubImageData(windowDim, windowDim, 
                          (float)this->textWidth, 
                          (float)this->textHeight,
                          this->acceptObjs, this->rejectObjs, this->clipObjs,
                          this->clipMode, this->clipAmount, this->drawOrder==Spaced, 
                          this->memAlignment, &this->numDrawn);

    /* Convert RasterPos coordinates to NDC */
    this->traversalData = (GLfloat*)AlignMalloc(sizeof(GLfloat) * this->rasterPosDim * this->numDrawn, this->memAlignment);
    srcPtr = intTraversalData;
    dstPtr = this->traversalData;
    for (i = 0; i < this->numDrawn; i++) {
        *dstPtr++ = ((double)(*srcPtr++ + this->textWidthPadding) + .375) / (double)windowDim * 2. - 1.;
        *dstPtr++ = ((double)(*srcPtr++ + this->textHeightPadding) + .375) / (double)windowDim * 2. - 1.;
    }
    AlignFree(intTraversalData);

    /* Add color and z coordinate if necessary */
    RasterPos__AddTraversalData((RasterPosPtr)this);

    Text__CreateTextData(this);
}

void Text__Cleanup(TestPtr thisTest)
{
    int i;

    TextPtr this = (TextPtr)thisTest;
    void **imagePtr = this->imageData;
    for ( i = 0; i < this->numObjects; i++) {
      if(*imagePtr)
	AlignFree(*imagePtr);
      imagePtr++;
    }
    if(this->imageData)
      free(this->imageData);

    if (this->traversalData) AlignFree(this->traversalData);
    if (this->textString) free(this->textString);

    if (this->textFont) delete_TextFont(this->textFont);
}

int Text__SetState(TestPtr thisTest)
{
    TextPtr this = (TextPtr)thisTest;

    /* set parent state */
    if (RasterPos__SetState(thisTest) == -1) return -1;

    /* set own state */
    if ((this->textFont = new_TextFont(this->charFont)) == 0) return -1;

    /* This routine doesn't support more than one level of unrolling */
    if (this->loopUnroll > 1)
        return -1;

    this->base = TextFont__GetBase(this->textFont);

    return 0;
}

void Text__SetExecuteFunc(TestPtr thisTest)
{
    TextPtr this = (TextPtr)thisTest;
    TextFunc function;

    function.word = 0;

    function.bits.functionPtrs = this->loopFuncPtrs;
    function.bits.multiimage = (this->numObjects > 1);
    function.bits.colorData = (this->colorData == PerRasterPos) ? PER_RASTERPOS : NONE;
    function.bits.visual = this->environ.bufConfig.rgba ? RGB : CI;

    /* Dimensions of data to be traversed */
    function.bits.rasterPosDim  = this->rasterPosDim - 2;
    function.bits.colorDim = this->colorDim - 3;

    this->Execute = TextExecuteTable[function.word];
}

int Text__TimesRun(TestPtr thisTest)
{
    TextPtr this = (TextPtr)thisTest;
    return this->numDrawn*this->charsPerString;
}

float Text__Size(TestPtr thisTest)
{
    TextPtr this = (TextPtr)thisTest;
    int accept = this->acceptObjs * (float)(this->numDrawn);
    int reject = this->rejectObjs * (float)(this->numDrawn);
    int clip = this->clipObjs * (float)(this->numDrawn);
    float size = (float)this->textWidth * (float)this->textHeight;
    float acceptSize, clipSize;

    accept += this->numDrawn - accept - reject - clip;

    acceptSize = (float)accept * size;
    clipSize = (float)clip * (1. - this->clipAmount) * size;

    return (acceptSize + clipSize)/(float)this->numDrawn;
}

void Text__CreateTextData(TextPtr this)
{
    int i;
    void **imagePtr;
    int imageSize;

    this->imageData = (void**)malloc(sizeof(void*) * this->numObjects);
    CheckMalloc(this->imageData);
    imagePtr = this->imageData;

    for (i = 0; i < this->numObjects; i++) {
	*imagePtr = AlignMalloc(this->charsPerString + 1, this->memAlignment);
	strcpy(*imagePtr, this->textString);
	imagePtr++;
    }
}
