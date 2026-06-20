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
#include "CopyPix.h"
#include "CopyPixX.h"

#undef offset
#define offset(v) offsetof(CopyPixels,v)

static InfoItem CopyPixelsInfo[] = {
#define INC_REASON INFO_ITEM_ARRAY
#include "CopyPix.h"
#undef INC_REASON
};
#include <malloc.h>

CopyPixelsPtr new_CopyPixels()
{
    CopyPixelsPtr this = (CopyPixelsPtr)malloc(sizeof(CopyPixels));

    ImagePtr thisImage = (ImagePtr)(&this->image_CopyPixels);
    TransferMapPtr thisTransferMap = (TransferMapPtr)(&this->transfermap_CopyPixels);
    ZoomPtr thisZoom = (ZoomPtr)( &this->zoom_CopyPixels);

    CheckMalloc(this);
    new_RasterPos((RasterPosPtr)this);
    new_Image(thisImage);
    new_TransferMap(thisTransferMap);
    new_Zoom(thisZoom);
    SetDefaults((TestPtr)this, CopyPixelsInfo);
    this->testType = CopyPixelsTest;
    this->numObjects = 1;
    this->clearBefore = False;
    this->traversalData = 0;
    this->subImageData = 0;
    this->usecPixelPrint = " microseconds per pixel with CopyPixels";
    this->ratePixelPrint = " pixels per second with CopyPixels";
    this->usecPrint = " microseconds per image with CopyPixels";
    this->ratePrint = " CopyPixel images per second";
    /* Set virtual functions */
    this->SetState = CopyPixels__SetState;
    this->delete = delete_CopyPixels;
    this->Copy = CopyPixels__Copy;
    this->Initialize = CopyPixels__Initialize;
    this->Cleanup = CopyPixels__Cleanup;
    this->SetExecuteFunc = CopyPixels__SetExecuteFunc;
    this->PixelSize = CopyPixels__Size;
    this->TimesRun = CopyPixels__TimesRun;
    return this;
}

void delete_CopyPixels(TestPtr thisTest)
{
    CopyPixelsPtr this = (CopyPixelsPtr)thisTest;

    ImagePtr thisImage = (ImagePtr)(&this->image_CopyPixels);
    TransferMapPtr thisTransferMap = (TransferMapPtr)(&this->transfermap_CopyPixels);
    ZoomPtr thisZoom = (ZoomPtr)( &this->zoom_CopyPixels);

    delete_Zoom(thisZoom);
    delete_TransferMap(thisTransferMap);
    delete_Image(thisImage);
    delete_RasterPos(thisTest);
}

TestPtr CopyPixels__Copy(TestPtr thisTest)
{
    CopyPixelsPtr this = (CopyPixelsPtr)thisTest;
    CopyPixelsPtr newCopyPixels = new_CopyPixels();
    FreeStrings((TestPtr)newCopyPixels);
    *newCopyPixels = *this;
    CopyStrings((TestPtr)newCopyPixels, (TestPtr)this);
    return (TestPtr)newCopyPixels;
}

void CopyPixels__Initialize(TestPtr thisTest)
{
    CopyPixelsPtr this = (CopyPixelsPtr)thisTest;
    int windowDim = min(this->environ.windowWidth, this->environ.windowHeight);
    int windowArea = windowDim * windowDim;
    GLint *intTraversalData;
    GLint *srcPtr;
    GLint *srcimageData;
    GLfloat *dstPtr;
    int total, index, offset;
    int i;
    float xZoomSgn = (this->zoom_CopyPixels.pixelZoomX >= 0.) ? 1. : -1.;
    float yZoomSgn = (this->zoom_CopyPixels.pixelZoomY >= 0.) ? 1. : -1.;
    float xFudge = .375;
    float yFudge = .375;

    /* Layout RasterPos coordinates */
    this->numDrawn = 0;
    intTraversalData = CreateSubImageData(windowDim, windowDim, 
                          (float)this->copyPixelsWidth*fabs(this->zoom_CopyPixels.pixelZoomX),
                          (float)this->copyPixelsHeight*fabs(this->zoom_CopyPixels.pixelZoomY),
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
            *dstPtr++ = (((double)(*srcPtr++) + xFudge) / (double)windowDim * 2. - 1.) *
                        xZoomSgn;
            *dstPtr++ = (((double)(*srcPtr++) + yFudge) / (double)windowDim * 2. - 1.) *
                        yZoomSgn;
	    if (this->rasterPosDim == 3) *dstPtr++ = -1.;
	}
    }
    AlignFree(intTraversalData);

    /* Layout offsets in window coordinates for source (from) data.
     * All the from images should lie entirely within the source image, so 100% of 
     * our offsets should be "accepted".  numDrawn taken from RasterPos layout above.
     */
    srcimageData = CreateSubImageData(windowDim, windowDim,
				 this->copyPixelsWidth,
				 this->copyPixelsHeight,
                                 1., 0., 0., Random, 0., this->drawOrder==Spaced,
                                 this->memAlignment, &this->numDrawn);

    /* Now rotate these around to make sure the src and dst aren't the same... */
    this->subImageData = (GLint*)AlignMalloc(sizeof(GLint) * 2 * this->numDrawn, this->memAlignment);
    offset = (this->numDrawn + 1) / 2;
    total = this->numDrawn;
    for (i = 0; i < total; i++) {
	index = (i + offset) % (total-1);
	this->subImageData[2 * index] = srcimageData[2 * i];
	this->subImageData[2 * index + 1] = srcimageData[2 * i + 1];
    }
    AlignFree(srcimageData);

    /* Finally, draw something interesting before we start copying.  Otherwise, we won't
     * see anything going on!  Remember that we set the clearBefore flag to False up
     * in the creator.  This prevents the test executor from clearing buffers before testing.
     */

  Image__DrawSomething(this->environ.bufConfig.rgba, this->environ.bufConfig.indexSize,
		       this->environ.bufConfig.doubleBuffer);
}

void CopyPixels__Cleanup(TestPtr thisTest)
{
    CopyPixelsPtr this = (CopyPixelsPtr)thisTest;

    if (this->traversalData) AlignFree(this->traversalData);
    if (this->subImageData) AlignFree(this->subImageData);
}

int CopyPixels__SetState(TestPtr thisTest)
{
    CopyPixelsPtr this = (CopyPixelsPtr)thisTest;

    ImagePtr thisImage = (ImagePtr)(&this->image_CopyPixels);
    TransferMapPtr thisTransferMap = (TransferMapPtr)(&this->transfermap_CopyPixels);
    ZoomPtr thisZoom = (ZoomPtr)( &this->zoom_CopyPixels);

    /* set parent state */
    if (RasterPos__SetState(thisTest) == -1) return -1;

    /* set other inherited classes' states */
    if (Image__SetState(thisImage) == -1) return -1;
    if (TransferMap__SetState(thisTransferMap) == -1) return -1;
    if (Zoom__SetState(thisZoom) == -1) return -1;

    /* set own state */
    glReadBuffer(this->readBuffer);

    return 0;
}

void CopyPixels__SetExecuteFunc(TestPtr thisTest)
{
    CopyPixelsPtr this = (CopyPixelsPtr)thisTest;
    CopyPixelsFunc function;

    function.word = 0;

    function.bits.functionPtrs = this->loopFuncPtrs;

    /* Dimensions of data to be traversed */
    function.bits.rasterPosDim  = this->rasterPosDim - 2;

    this->Execute = CopyPixelsExecuteTable[function.word];
}

int CopyPixels__TimesRun(TestPtr thisTest)
{
    CopyPixelsPtr this = (CopyPixelsPtr)thisTest;
    return this->numDrawn;
}

float CopyPixels__Size(TestPtr thisTest)
{
    CopyPixelsPtr this = (CopyPixelsPtr)thisTest;
    int accept = this->acceptObjs * (float)(this->numDrawn);
    int reject = this->rejectObjs * (float)(this->numDrawn);
    int clip = this->clipObjs * (float)(this->numDrawn);
    float size = (float)this->copyPixelsWidth * fabs(this->zoom_CopyPixels.pixelZoomX) * 
                 (float)this->copyPixelsHeight * fabs(this->zoom_CopyPixels.pixelZoomY);
    float acceptSize, clipSize;

    accept += this->numDrawn - accept - reject - clip;

    acceptSize = (float)accept * size;
    clipSize = (float)clip * (1. - this->clipAmount) * size;

    return (acceptSize + clipSize)/(float)this->numDrawn;
}
