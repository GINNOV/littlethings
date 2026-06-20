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
#include "ReadPix.h"
#include "ReadPixX.h"

#undef offset
#define offset(v) offsetof(ReadPixels,v)

static InfoItem ReadPixelsInfo[] = {
#define INC_REASON INFO_ITEM_ARRAY
#include "ReadPix.h"
#undef INC_REASON
};
#include <malloc.h>

ReadPixelsPtr new_ReadPixels()
{
    ReadPixelsPtr this = (ReadPixelsPtr)malloc(sizeof(ReadPixels));

    ImagePtr thisImage = (ImagePtr)(&this->image_ReadPixels);
    TransferMapPtr thisTransferMap = (TransferMapPtr)(&this->transfermap_ReadPixels);

    CheckMalloc(this);
    new_Test((TestPtr)this);
    new_Image(thisImage);
    new_TransferMap(thisTransferMap);
    SetDefaults((TestPtr)this, ReadPixelsInfo);
    this->testType = ReadPixelsTest;
    this->clearBefore = False;
    this->subImage = False;
    this->srcData = 0;
    this->subImageData = 0;
    this->imageData = 0;
    this->usecPixelPrint = " microseconds per pixel with ReadPixels";
    this->ratePixelPrint = " pixels per second with ReadPixels";
    this->usecPrint = " microseconds per image with ReadPixels";
    this->ratePrint = " ReadPixel images per second";
    /* Set virtual functions */
    this->SetState = ReadPixels__SetState;
    this->delete = delete_ReadPixels;
    this->Copy = ReadPixels__Copy;
    this->Initialize = ReadPixels__Initialize;
    this->Cleanup = ReadPixels__Cleanup;
    this->SetExecuteFunc = ReadPixels__SetExecuteFunc;
    this->PixelSize = ReadPixels__Size;
    this->TimesRun = ReadPixels__TimesRun;
    return this;
}

void delete_ReadPixels(TestPtr thisTest)
{
    ReadPixelsPtr this = (ReadPixelsPtr)thisTest;
    ImagePtr thisImage = (ImagePtr)(&this->image_ReadPixels);
    TransferMapPtr thisTransferMap = (TransferMapPtr)(&this->transfermap_ReadPixels);

    delete_TransferMap(thisTransferMap);
    delete_Image(thisImage);
    delete_Test(thisTest);
}

TestPtr ReadPixels__Copy(TestPtr thisTest)
{
    ReadPixelsPtr this = (ReadPixelsPtr)thisTest;
    ReadPixelsPtr newReadPixels = new_ReadPixels();
    FreeStrings((TestPtr)newReadPixels);
    *newReadPixels = *this;
    CopyStrings((TestPtr)newReadPixels, (TestPtr)this);
    return (TestPtr)newReadPixels;
}

void ReadPixels__Initialize(TestPtr thisTest)
{
    ReadPixelsPtr this = (ReadPixelsPtr)thisTest;
    int windowDim = min(this->environ.windowWidth, this->environ.windowHeight);

    if (this->image_ReadPixels.imageWidth > windowDim)
	this->image_ReadPixels.imageWidth = windowDim;
    if (this->image_ReadPixels.imageHeight > windowDim)
	this->image_ReadPixels.imageHeight = windowDim;

    /* Source image is imageWidth by imageHeight,
     * The portion drawn by glReadPixels is readPixelsWidth by readPixelsHeight */
    if (this->readPixelsWidth != -1) {
	this->subImage = True;
    } else {
	this->readPixelsWidth = this->image_ReadPixels.imageWidth;
    }
    if (this->readPixelsHeight != -1) {
	this->subImage = True;
    } else {
	this->readPixelsHeight = this->image_ReadPixels.imageHeight;
    }

    /* Layout Source coordinates */
    this->numDrawn = 0;
    this->srcData = CreateSubImageData(windowDim, windowDim, 
                          (float)this->readPixelsWidth, 
                          (float)this->readPixelsHeight,
                          1., 0., 0., Random, 0., this->readOrder==Spaced, 
                          this->memAlignment, &this->numDrawn);

    ReadPixels__CreateImageData(this);

    /*
     * Layout offsets in source image for subimage reads.
     * All the subimages should lie entirely within the source image, so 100% of 
     * our offsets should be "accepted".  numDrawn taken from Source layout above.
     */
    if (this->subImage) {
	this->subImageData = CreateSubImageData(this->image_ReadPixels.imageWidth,
                                 this->image_ReadPixels.imageHeight,
				 this->readPixelsWidth,
				 this->readPixelsHeight,
                                 1., 0., 0., Random, 0., this->readOrder==Spaced,
                                 this->memAlignment, &this->numDrawn);
    }

    /*
     * Draw something to discourage any sort of cheating (e.g. using calloc instead
     * of reading the buffer)
     */
    Image__DrawSomething(this->environ.bufConfig.rgba, 
                         this->environ.bufConfig.indexSize,
                         this->environ.bufConfig.doubleBuffer);
}

void ReadPixels__Cleanup(TestPtr thisTest)
{
    ReadPixelsPtr this = (ReadPixelsPtr)thisTest;
    int i;

    if (this->srcData) AlignFree(this->srcData);
    if (this->subImageData) AlignFree(this->subImageData);
    if (this->imageData) {
	void **imageDataPtr = this->imageData;
        for (i = 0; i < this->numObjects; i++) AlignFree(*imageDataPtr++);
	free(this->imageData);
    }
}

int ReadPixels__SetState(TestPtr thisTest)
{
    ReadPixelsPtr this = (ReadPixelsPtr)thisTest;
    ImagePtr thisImage = (ImagePtr)(&this->image_ReadPixels);
    TransferMapPtr thisTransferMap = (TransferMapPtr)(&this->transfermap_ReadPixels);


    /* set parent state */
    if (Test__SetState(thisTest) == -1) return -1;
  

    /* set other inherited classes' states */
    if (Image__SetState(thisImage) == -1) return -1;
    if (TransferMap__SetState(thisTransferMap) == -1) return -1;

    /* set own state */

    return 0;
}

void ReadPixels__SetExecuteFunc(TestPtr thisTest)
{
    ReadPixelsPtr this = (ReadPixelsPtr)thisTest;
    ReadPixelsFunc function;

    function.word = 0;

    function.bits.functionPtrs = this->loopFuncPtrs;
    function.bits.subimage = this->subImage;
    function.bits.multiimage = (this->numObjects > 1);

    this->Execute = ReadPixelsExecuteTable[function.word];
}

int ReadPixels__TimesRun(TestPtr thisTest)
{
    ReadPixelsPtr this = (ReadPixelsPtr)thisTest;
    return this->numDrawn;
}

float ReadPixels__Size(TestPtr thisTest)
{
    ReadPixelsPtr this = (ReadPixelsPtr)thisTest;

    return (float)(this->readPixelsWidth * this->readPixelsHeight);
}

void ReadPixels__CreateImageData(ReadPixelsPtr this)
{
    int i;
    void **imagePtr;
    int imageSize;
    void *image;

    this->imageData = (void**)malloc(sizeof(void*) * this->numObjects);
    CheckMalloc(this->imageData);
    imagePtr = this->imageData;
    /*
     * Need to allocate the correct amount of memory for the ReadPixels
     * image.  To do this, we'll just let the image routine create an
     * image with those attributes, then use that as our read buffer.
     */
    if (this->numObjects)
	image = new_ImageData(
                         this->image_ReadPixels.imageWidth,
			 this->image_ReadPixels.imageHeight,
			 this->image_ReadPixels.imageFormat,
			 this->image_ReadPixels.imageType,
			 this->image_ReadPixels.imageAlignment,
			 this->image_ReadPixels.imageSwapBytes,
			 this->image_ReadPixels.imageLSBFirst,
			 this->memAlignment,
			 &imageSize);
    *imagePtr++ = image;
    for (i = 1; i < this->numObjects; i++)
	*imagePtr++ = AlignMalloc(imageSize, this->memAlignment);
}
