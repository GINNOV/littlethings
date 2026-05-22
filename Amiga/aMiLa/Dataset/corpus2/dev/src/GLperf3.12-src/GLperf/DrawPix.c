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
#include "DrawPix.h"
#include "DrawPixX.h"

#undef offset
#define offset(v) offsetof(DrawPixels,v)

static InfoItem DrawPixelsInfo[] = {
#define INC_REASON INFO_ITEM_ARRAY
#include "DrawPix.h"
#undef INC_REASON
};
#include <malloc.h>

DrawPixelsPtr new_DrawPixels()
{
    DrawPixelsPtr this = (DrawPixelsPtr)malloc(sizeof(DrawPixels));
    ImagePtr thisImage = (ImagePtr)(&this->image_DrawPixels);
    TransferMapPtr thisTransferMap = (TransferMapPtr)( &this->transfermap_DrawPixels);
    ZoomPtr thisZoom = (ZoomPtr)( &this->zoom_DrawPixels);


    CheckMalloc(this);
    new_RasterPos((RasterPosPtr)this);
    new_Image(thisImage);
    new_TransferMap(thisTransferMap);
    new_Zoom(thisZoom);
    SetDefaults((TestPtr)this, DrawPixelsInfo);
    this->testType = DrawPixelsTest;
    this->subImage = False;
    this->traversalData = 0;
    this->subImageData = 0;
    this->imageData = 0;
    this->usecPixelPrint = " microseconds per pixel with DrawPixels";
    this->ratePixelPrint = " pixels per second with DrawPixels";
    this->usecPrint = " microseconds per image with DrawPixels";
    this->ratePrint = " DrawPixel images per second";
    /* Set virtual functions */
    this->SetState = DrawPixels__SetState;
    this->delete = delete_DrawPixels;
    this->Copy = DrawPixels__Copy;
    this->Initialize = DrawPixels__Initialize;
    this->Cleanup = DrawPixels__Cleanup;
    this->SetExecuteFunc = DrawPixels__SetExecuteFunc;
    this->PixelSize = DrawPixels__Size;
    this->TimesRun = DrawPixels__TimesRun;
    return this;
}

void delete_DrawPixels(TestPtr thisTest)
{
    DrawPixelsPtr this = (DrawPixelsPtr)thisTest;
    ImagePtr thisImage = (ImagePtr)(&this->image_DrawPixels);
    TransferMapPtr thisTransferMap = (TransferMapPtr)( &this->transfermap_DrawPixels);
    ZoomPtr thisZoom = (ZoomPtr)( &this->zoom_DrawPixels);


    delete_Zoom(thisZoom);
    delete_TransferMap(thisTransferMap);
    delete_Image(thisImage);
    delete_RasterPos(thisTest);
}

TestPtr DrawPixels__Copy(TestPtr thisTest)
{
    DrawPixelsPtr this = (DrawPixelsPtr)thisTest;
    DrawPixelsPtr newDrawPixels = new_DrawPixels();
    FreeStrings((TestPtr)newDrawPixels);
    *newDrawPixels = *this;
    CopyStrings((TestPtr)newDrawPixels, (TestPtr)this);
    return (TestPtr)newDrawPixels;
}

void DrawPixels__Initialize(TestPtr thisTest)
{
    DrawPixelsPtr this = (DrawPixelsPtr)thisTest;
    int windowDim = min(this->environ.windowWidth, this->environ.windowHeight);
    int windowArea = windowDim * windowDim;
    GLint *intTraversalData;
    GLint *srcPtr;
    GLfloat *dstPtr;
    int i;
    const float xFudge = .375;
    const float yFudge = .375;
    float xZoomSgn = (this->zoom_DrawPixels.pixelZoomX >= 0.) ? 1. : -1.;
    float yZoomSgn = (this->zoom_DrawPixels.pixelZoomY >= 0.) ? 1. : -1.;

    if ((float)this->image_DrawPixels.imageWidth * fabs(this->zoom_DrawPixels.pixelZoomX) > windowDim)
	this->image_DrawPixels.imageWidth = (float)windowDim/fabs(this->zoom_DrawPixels.pixelZoomX);
    if ((float)this->image_DrawPixels.imageHeight * fabs(this->zoom_DrawPixels.pixelZoomY) > windowDim)
	this->image_DrawPixels.imageHeight = (float)windowDim/fabs(this->zoom_DrawPixels.pixelZoomY);

    /* Source image is imageWidth by imageHeight,
     * The portion drawn by glDrawPixels is drawPixelsWidth by drawPixelsHeight */
    if (this->drawPixelsWidth != -1) {
	this->subImage = True;
    } else {
	this->drawPixelsWidth = this->image_DrawPixels.imageWidth;
    }
    if (this->drawPixelsHeight != -1) {
	this->subImage = True;
    } else {
	this->drawPixelsHeight = this->image_DrawPixels.imageHeight;
    }

    /* Layout RasterPos coordinates */
    this->numDrawn = 0;
    intTraversalData = CreateSubImageData(windowDim, windowDim, 
                          (float)this->drawPixelsWidth*fabs(this->zoom_DrawPixels.pixelZoomX),
                          (float)this->drawPixelsHeight*fabs(this->zoom_DrawPixels.pixelZoomY),
                          this->acceptObjs, this->rejectObjs, this->clipObjs,
                          this->clipMode, this->clipAmount, this->drawOrder==Spaced, 
                          this->memAlignment, &this->numDrawn);

    /* Convert RasterPos coordinates to NDC */
    this->traversalData = (GLfloat*)AlignMalloc(sizeof(GLfloat) * this->rasterPosDim * this->numDrawn, this->memAlignment);
    srcPtr = intTraversalData;
    dstPtr = this->traversalData;
    if (this->zOrder != Coplanar && this->rasterPosDim == 3) {
        GLdouble modelMatrix[16];
        GLdouble projMatrix[16];
        GLint viewport[4];
        GLdouble xd, yd, zd;
	GLdouble depthBits, epsilon;
	GLdouble base, range, delta;

        glGetDoublev(GL_MODELVIEW_MATRIX, modelMatrix);
        glGetDoublev(GL_PROJECTION_MATRIX, projMatrix);
        glGetIntegerv(GL_VIEWPORT, viewport);
        glGetDoublev(GL_DEPTH_BITS, &depthBits);
	epsilon = pow(2.0, -depthBits);
        mysrand(15000);

	switch (this->zOrder) {
	case Random:
	    range = 1. - epsilon;
	    base = epsilon;
	    delta = 0.;
	    break;
	case BackToFront:
	    range = (1. - epsilon) / (GLdouble)this->numDrawn;
	    base = 1. - range - epsilon;
	    delta = -range;
	    break;
	case FrontToBack:
	    range = (1. - epsilon) / (GLdouble)this->numDrawn;
	    base = epsilon;
	    delta = range;
	    break;
	}

	for (i = 0; i < this->numDrawn; i++) {
	    /* Perturb the Z value to shake things up */
	    GLdouble x = (GLdouble)*srcPtr++ + xFudge;
	    GLdouble y = (GLdouble)*srcPtr++ + yFudge;
	    GLdouble z = base + 
                         delta * (GLdouble)i +
                         range * (GLdouble)myrand()/(GLdouble)MY_RAND_MAX;
	    
	    gluUnProject(x, y, z,
                         modelMatrix, projMatrix, viewport,
                         &xd, &yd, &zd);
            *dstPtr++ = (GLfloat)xd * xZoomSgn;
            *dstPtr++ = (GLfloat)yd * yZoomSgn;
            *dstPtr++ = (GLfloat)zd;
        }
    } else {
        for (i = 0; i < this->numDrawn; i++) {
            *dstPtr++ = (((double)(*srcPtr++) + xFudge) / (double)windowDim * 2. - 1.)
                        * xZoomSgn;
            *dstPtr++ = (((double)(*srcPtr++) + yFudge) / (double)windowDim * 2. - 1.)
                        * yZoomSgn;
            if (this->rasterPosDim == 3) *dstPtr++ = -1.;
        }
    }

    AlignFree(intTraversalData);

    DrawPixels__CreateImageData(this);

    /* Layout offsets in source image for subimage draws.
     * All the subimages should lie entirely within the source image, so 100% of 
     * our offsets should be "accepted".  numDrawn taken from RasterPos layout above.
     */
    if (this->subImage) {
	this->subImageData = CreateSubImageData(this->image_DrawPixels.imageWidth, 
				 this->image_DrawPixels.imageHeight,
				 this->drawPixelsWidth,
				 this->drawPixelsHeight,
                                 1., 0., 0., Random, 0., this->drawOrder==Spaced,
                                 this->memAlignment, &this->numDrawn);
    }
}

void DrawPixels__Cleanup(TestPtr thisTest)
{
    DrawPixelsPtr this = (DrawPixelsPtr)thisTest;
    int i;

    if (this->traversalData) AlignFree(this->traversalData);
    if (this->subImageData) AlignFree(this->subImageData);
    if (this->imageData) {
	void **imageDataPtr = this->imageData;
        for (i = 0; i < this->numObjects; i++) AlignFree(*imageDataPtr++);
	free(this->imageData);
    }

}

int DrawPixels__SetState(TestPtr thisTest)
{
    DrawPixelsPtr this = (DrawPixelsPtr)thisTest;

    ImagePtr thisImage = (ImagePtr)(&this->image_DrawPixels);
    TransferMapPtr thisTransferMap = (TransferMapPtr)( &this->transfermap_DrawPixels);
    ZoomPtr thisZoom = (ZoomPtr)( &this->zoom_DrawPixels);

    /* set parent state */
    if (RasterPos__SetState(thisTest) == -1) return -1;
    /* set other inherited classes' states */
    if (Image__SetState(thisImage) == -1) return -1;
    if (TransferMap__SetState(thisTransferMap) == -1) return -1;
    if (Zoom__SetState(thisZoom) == -1) return -1;

    /* set own state */

    return 0;
}

void DrawPixels__SetExecuteFunc(TestPtr thisTest)
{
    DrawPixelsPtr this = (DrawPixelsPtr)thisTest;
    DrawPixelsFunc function;

    function.word = 0;

    function.bits.functionPtrs = this->loopFuncPtrs;
    function.bits.subimage = this->subImage;
    function.bits.multiimage = (this->numObjects > 1);

    /* Dimensions of data to be traversed */
    function.bits.rasterPosDim  = this->rasterPosDim - 2;

    this->Execute = DrawPixelsExecuteTable[function.word];
}

int DrawPixels__TimesRun(TestPtr thisTest)
{
    DrawPixelsPtr this = (DrawPixelsPtr)thisTest;

    return this->numDrawn;
}

float DrawPixels__Size(TestPtr thisTest)
{
    DrawPixelsPtr this = (DrawPixelsPtr)thisTest;
    int accept = this->acceptObjs * (float)(this->numDrawn);
    int reject = this->rejectObjs * (float)(this->numDrawn);
    int clip = this->clipObjs * (float)(this->numDrawn);
    float size = (float)this->drawPixelsWidth * fabs(this->zoom_DrawPixels.pixelZoomX) * 
                 (float)this->drawPixelsHeight * fabs(this->zoom_DrawPixels.pixelZoomY);
    float acceptSize, clipSize;

    accept += this->numDrawn - accept - reject - clip;

    acceptSize = (float)accept * size;
    clipSize = (float)clip * (1. - this->clipAmount) * size;

    return (acceptSize + clipSize)/(float)this->numDrawn;
}

void DrawPixels__CreateImageData(DrawPixelsPtr this)
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
                         this->image_DrawPixels.imageWidth,
			 this->image_DrawPixels.imageHeight,
			 this->image_DrawPixels.imageFormat,
			 this->image_DrawPixels.imageType,
			 this->image_DrawPixels.imageAlignment,
			 this->image_DrawPixels.imageSwapBytes,
			 this->image_DrawPixels.imageLSBFirst,
			 this->memAlignment,
			 &imageSize);
    *imagePtr++ = image;
    for (i = 1; i < this->numObjects; i++) {
	*imagePtr = AlignMalloc(imageSize, this->memAlignment);
	memcpy(*imagePtr, image, imageSize);
	imagePtr++;
    }
}
