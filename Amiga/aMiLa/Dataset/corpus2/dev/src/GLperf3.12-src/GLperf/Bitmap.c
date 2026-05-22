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
#include "Bitmap.h"
#include "BitmapX.h"

#undef offset
#define offset(v) offsetof(Bitmap, v)

static InfoItem BitmapInfo[] = {
#define INC_REASON INFO_ITEM_ARRAY
#include "Bitmap.h"
#undef INC_REASON
};
#include <malloc.h>

BitmapPtr new_Bitmap()
{
    BitmapPtr this = (BitmapPtr)malloc(sizeof(Bitmap));
    ImagePtr thisImage = (ImagePtr)(&this->image_Bitmap);

    CheckMalloc(this);
    new_RasterPos((RasterPosPtr)this);
    new_Image(thisImage);
    SetDefaults((TestPtr)this, BitmapInfo);
    this->testType = BitmapTest;
    this->subImage = False;
    this->traversalData = 0;
    this->subImageData = 0;
    this->imageData = 0;
    this->usecPixelPrint = " microseconds per pixel with Bitmap";
    this->ratePixelPrint = " pixels per second with Bitmap";
    this->usecPrint = " microseconds per Bitmap image";
    this->ratePrint = " Bitmap images per second";
    /* Set virtual functions */
    this->SetState = Bitmap__SetState;
    this->delete = delete_Bitmap;
    this->Copy = Bitmap__Copy;
    this->Initialize = Bitmap__Initialize;
    this->Cleanup = Bitmap__Cleanup;
    this->SetExecuteFunc = Bitmap__SetExecuteFunc;
    this->PixelSize = Bitmap__Size;
    this->TimesRun = Bitmap__TimesRun;
    return this;
}

void delete_Bitmap(TestPtr thisTest)
{
    BitmapPtr this = (BitmapPtr)thisTest;
    ImagePtr thisImage = (ImagePtr)(&this->image_Bitmap);

    delete_Image(thisImage);
    delete_RasterPos(thisTest);
}

TestPtr Bitmap__Copy(TestPtr thisTest)
{
    BitmapPtr this = (BitmapPtr)thisTest;
    BitmapPtr newBitmap = new_Bitmap();
    FreeStrings((TestPtr)newBitmap);
    *newBitmap = *this;
    CopyStrings((TestPtr)newBitmap, (TestPtr)this);
    return (TestPtr)newBitmap;
}

void Bitmap__Initialize(TestPtr thisTest)
{
    BitmapPtr this = (BitmapPtr)thisTest;
    int windowDim = min(this->environ.windowWidth, this->environ.windowHeight);
    int windowArea = windowDim * windowDim;
    GLint *intTraversalData;
    GLint *srcPtr;
    GLfloat *dstPtr;
    int i;

    if (this->image_Bitmap.imageWidth > windowDim)
	this->image_Bitmap.imageWidth = windowDim;
    if (this->image_Bitmap.imageHeight > windowDim)
	this->image_Bitmap.imageHeight = windowDim;

    /* Source image is imageWidth by imageHeight,
     * The portion drawn by glBitmap is bitmapWidth by bitmapHeight */
    if (this->bitmapWidth != -1) {
	this->subImage = True;
    } else {
	this->bitmapWidth = this->image_Bitmap.imageWidth;
    }
    if (this->bitmapHeight != -1) {
	this->subImage = True;
    } else {
	this->bitmapHeight = this->image_Bitmap.imageHeight;

    }

    /* Layout RasterPos coordinates */
    this->numDrawn = 0;
    intTraversalData = CreateSubImageData(windowDim, windowDim, 
                          (float)this->bitmapWidth, 
                          (float)this->bitmapHeight,
                          this->acceptObjs, this->rejectObjs, this->clipObjs,
                          this->clipMode, this->clipAmount, this->drawOrder==Spaced, 
                          this->memAlignment, &this->numDrawn);

    /* Convert RasterPos coordinates to NDC */
    this->traversalData = (GLfloat*)AlignMalloc(sizeof(GLfloat) * this->rasterPosDim * this->numDrawn, this->memAlignment);
    srcPtr = intTraversalData;
    dstPtr = this->traversalData;
    for (i = 0; i < this->numDrawn; i++) {
        *dstPtr++ = ((double)(*srcPtr++) + .375) / (double)windowDim * 2. - 1.;
        *dstPtr++ = ((double)(*srcPtr++) + .375) / (double)windowDim * 2. - 1.;

    }
    AlignFree(intTraversalData);

    /* Add color and z coordinate if necessary */
    RasterPos__AddTraversalData((RasterPosPtr)this);

    Bitmap__CreateImageData(this);

    /* Layout offsets in source image for subimage draws.
     * All the subimages should lie entirely within the source image, so 100% of 
     * our offsets should be "accepted".  numDrawn taken from RasterPos layout above.
     */
    if (this->subImage) {
	this->subImageData = CreateSubImageData(this->image_Bitmap.imageWidth, 
                                 this->image_Bitmap.imageHeight,
				 this->bitmapWidth,
				 this->bitmapHeight,
                                 1., 0., 0., Random, 0., this->drawOrder==Spaced,
                                 this->memAlignment, &this->numDrawn);
    }
}

void Bitmap__Cleanup(TestPtr thisTest)
{
    BitmapPtr this = (BitmapPtr)thisTest;
    int i;

    if (this->traversalData) AlignFree(this->traversalData);
    if (this->subImageData) AlignFree(this->subImageData);
    if (this->imageData) {
	void **imageDataPtr = this->imageData;
        for (i = 0; i < this->numObjects; i++) AlignFree(*imageDataPtr++);
	free(this->imageData);
    }
}

int Bitmap__SetState(TestPtr thisTest)
{
    BitmapPtr this = (BitmapPtr)thisTest;
    ImagePtr thisImage = (ImagePtr)(&this->image_Bitmap);

    /* set parent state */
    if (RasterPos__SetState(thisTest) == -1) return -1;

    /* set other inherited classes' states */
    if (Image__SetState(thisImage) == -1) return -1;

    /* set own state */

    return 0;
}

void Bitmap__SetExecuteFunc(TestPtr thisTest)
{
    BitmapPtr this = (BitmapPtr)thisTest;
    BitmapFunc function;

    function.word = 0;

    function.bits.functionPtrs = this->loopFuncPtrs;
    function.bits.subimage = this->subImage;
    function.bits.multiimage = (this->numObjects > 1);
    function.bits.colorData = (this->colorData == PerRasterPos) ? PER_RASTERPOS : NONE;
    function.bits.visual = this->environ.bufConfig.rgba ? RGB : CI;

    /* Dimensions of data to be traversed */
    function.bits.rasterPosDim  = this->rasterPosDim - 2;
    function.bits.colorDim = this->colorDim - 3;

    this->Execute = BitmapExecuteTable[function.word];
}

int Bitmap__TimesRun(TestPtr thisTest)
{
    BitmapPtr this = (BitmapPtr)thisTest;
    return this->numDrawn;
}

float Bitmap__Size(TestPtr thisTest)
{
    BitmapPtr this = (BitmapPtr)thisTest;
    int accept = this->acceptObjs * (float)(this->numDrawn);
    int reject = this->rejectObjs * (float)(this->numDrawn);
    int clip = this->clipObjs * (float)(this->numDrawn);
    float size = (float)this->bitmapWidth * (float)this->bitmapHeight;
    float acceptSize, clipSize;

    accept += this->numDrawn - accept - reject - clip;

    acceptSize = (float)accept * size;
    clipSize = (float)clip * (1. - this->clipAmount) * size;

    return (acceptSize + clipSize)/(float)this->numDrawn;
}

void Bitmap__CreateImageData(BitmapPtr this)
{
    int i;
    void **imagePtr;
    int imageSize;
    void *image;

    this->imageData = (void**)malloc(sizeof(void*) * this->numObjects);
    CheckMalloc(this->imageData);
    imagePtr = this->imageData;
    if (this->numObjects)
	image = new_ImageData(
                         this->image_Bitmap.imageWidth,
			 this->image_Bitmap.imageHeight,
			 GL_COLOR_INDEX,
			 GL_BITMAP,
			 this->image_Bitmap.imageAlignment,
			 this->image_Bitmap.imageSwapBytes,
			 this->image_Bitmap.imageLSBFirst,
			 this->memAlignment,
			 &imageSize);
    *imagePtr++ = image;
    for (i = 1; i < this->numObjects; i++) {
	*imagePtr = AlignMalloc(imageSize, this->memAlignment);
	memcpy(*imagePtr, image, imageSize);
	imagePtr++;
    }
}
