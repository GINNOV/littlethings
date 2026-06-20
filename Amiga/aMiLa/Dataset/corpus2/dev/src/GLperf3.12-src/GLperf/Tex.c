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
#include "Tex.h"
#include "TexLoadX.h"
#include "TexCopyX.h"
#include "TexBindX.h"

#undef offset
#define offset(v) offsetof(TexImage,v)

static InfoItem TexImageInfo[] = {
#define INC_REASON INFO_ITEM_ARRAY
#include "Tex.h"
#undef INC_REASON
};
#include <malloc.h>

TexImagePtr new_TexImage()
{
    TexImagePtr this = (TexImagePtr)malloc(sizeof(TexImage));
    ImagePtr thisImage = (ImagePtr)(&this->image_TexImage);
    TransferMapPtr thisTransferMap = (TransferMapPtr)(&this->transfermap_TexImage);

    CheckMalloc(this);
    new_Test((TestPtr)this);
    new_Image(thisImage);
    new_TransferMap(thisTransferMap);
    SetDefaults((TestPtr)this, TexImageInfo);
    this->testType = TexImageTest;
    this->subImage = False;
    this->subImageData = 0;
#ifdef GL_EXT_subtexture
    this->subTexture = False;
    this->subTexData = 0;
#endif
#ifdef GL_EXT_copy_texture
    this->copyTexData = 0;
#endif
    this->mipmapData = 0;
    this->mipmapDimData = 0;
    this->imageData = 0;
    this->usecPixelPrint = " microseconds per texel with TexImage";
    this->ratePixelPrint = " texels per second with TexImage";
    this->usecPrint = " microseconds per texture image load";
    this->ratePrint = " texture images loaded per second";
    /* Set virtual functions */
    this->SetState = TexImage__SetState;
    this->delete = delete_TexImage;
    this->Copy = TexImage__Copy;
    this->Initialize = TexImage__Initialize;
    this->Cleanup = TexImage__Cleanup;
    this->SetExecuteFunc = TexImage__SetExecuteFunc;
    this->PixelSize = TexImage__Size;
    this->TimesRun = TexImage__TimesRun;
    return this;
}

void delete_TexImage(TestPtr thisTest)
{
    TexImagePtr this = (TexImagePtr)thisTest;
    ImagePtr thisImage = (ImagePtr)(&this->image_TexImage);
    TransferMapPtr thisTransferMap = (TransferMapPtr)(&this->transfermap_TexImage);

    delete_TransferMap(thisTransferMap);
    delete_Image(thisImage);
    delete_Test(thisTest);
}

TestPtr TexImage__Copy(TestPtr thisTest)
{
    TexImagePtr this = (TexImagePtr)thisTest;
    TexImagePtr newTexImage = new_TexImage();
    FreeStrings((TestPtr)newTexImage);
    *newTexImage = *this;
    CopyStrings((TestPtr)newTexImage, (TestPtr)this);
    return (TestPtr)newTexImage;
}

static void* CreateSubExtentData(
    int dim,
    int width, int height, int depth, int extent,
    int subwidth, int subheight, int subdepth, int subextent,
    int drawOrder, int memAlignment, int* numDrawn)
{
    int reps[4];
    int length[4];
    int sublength[4];
    float delta[4];
    GLint* vals[4];
    int stride, index;
    int i, j;
    GLint *subData, *subDataPtr;

    length[0] = width;   sublength[0] = subwidth;
    length[1] = height;  sublength[1] = subheight;
    length[2] = depth;   sublength[2] = subdepth;
    length[3] = extent; sublength[3] = subextent;

    if (*numDrawn == 0) {
	*numDrawn = 1;
	for (i = 0; i < dim; i++) {
	    reps[i] = (int)ceil((float)length[i]/(float)sublength[i]);
	    *numDrawn *= reps[i];
	}
    } else {
	int sideLen = (int)ceil(pow((float)(*numDrawn), 1./(float)dim));
	for (i = 0; i < dim; i++)
	    reps[i] = sideLen;
    }
    for (i = dim; i < 4; i++)
	reps[i] = 1;

    subData = (GLint*)AlignMalloc(sizeof(GLint) * dim * reps[0] * reps[1] * reps[2] * reps[3], memAlignment);
    subDataPtr = subData;

    for (i = 0; i < dim; i++) {
	delta[i] = (reps[i] == 1) ? 0. : (float)(length[i] - sublength[i]) / (float)(reps[i] - 1);
	if (drawOrder == Spaced) {
	    for (j = reps[i]/2; j > 1; j--)
		if (reps[i] % j) break;
	    if (j == 1)
		drawOrder = Serial;
	    else
		stride = j;
	}
	vals[i] = (GLint*)malloc(reps[i] * sizeof(GLint));
	for (j = 0; j < reps[i]; j++) {
	    index = (drawOrder == Spaced) ? (j*stride%reps[i]) : j;
	    vals[i][j] = (GLint)floor((float)index * delta[i] + .5);
	}
    }
    
    /* This loop looks pretty bizarre, but it allows us to take a Cartesian
     * product of the values in the vals array and get all combinations along
     * each dimension
     */
    for (i = 0; i < *numDrawn; i++) {
	*subDataPtr++ = vals[0][i % reps[0]];
	if (dim > 1) *subDataPtr++ = vals[1][i / reps[0] % reps[1]];
	if (dim > 2) *subDataPtr++ = vals[2][i / (reps[0] * reps[1]) % reps[2]];
	if (dim > 3) *subDataPtr++ = vals[3][i / (reps[0] * reps[1] * reps[2]) % reps[3]];
    }

    for (i = 0; i < dim; i++) free(vals[i]);

    return subData;
}

static void DrawTriangle(TexImagePtr this)
{
    glBegin(GL_TRIANGLE_STRIP);
    glTexCoord4f(.5, .5, 0., 1.);
    glVertex3f(0., 0., -1.);
    glTexCoord4f(.5 + 1./this->texImageWidth, .5, 0., 1.);
    glVertex3f(2./this->environ.windowWidth, 0., -1.);
    glTexCoord4f(.5, .5 + 1./this->texImageHeight, 0., 1.);
    glVertex3f(0., 2./this->environ.windowHeight, -1.);
    glEnd();
    glFinish();
}

void TexImage__Initialize(TestPtr thisTest)
{
    TexImagePtr this = (TexImagePtr)thisTest;
    GLint *intTraversalData;
    GLint *srcPtr;
    GLfloat *dstPtr;
    int i, j;
    int   windowDim   = min(this->environ.windowWidth, this->environ.windowHeight);

    switch (this->texImageSrc) {
    case SystemMemory:
        this->numDrawn = 0;
        if (this->subImage) {
#ifdef GL_EXT_subtexture
            if (this->subTexture) {
                this->subImageData = CreateSubExtentData(this->texDim,
                                     this->image_TexImage.imageWidth,
                                     this->image_TexImage.imageHeight,
                                     this->imageDepth,
                                     this->imageExtent,
                                     this->subTexWidth, this->subTexHeight,
                                     this->subTexDepth, this->subTexExtent,
                                     this->drawOrder, this->memAlignment, &this->numDrawn);                
		this->subTexData = CreateSubExtentData(this->texDim,
                                     this->texImageWidth, this->texImageHeight,
                                     this->texImageDepth, this->texImageExtent,
                                     this->subTexWidth, this->subTexHeight,
                                     this->subTexDepth, this->subTexExtent,
                                     this->drawOrder, this->memAlignment, &this->numDrawn);
		DefineTexImage(this->texTarget, this->texLevel, this->texComps,
                               this->texImageWidth, this->texImageHeight,
                               this->texImageDepth, this->texImageExtent,
                               this->texBorder, this->image_TexImage.imageFormat,
                               this->image_TexImage.imageType, (void*)0);
            } else {
#endif
                this->subImageData = CreateSubExtentData(this->texDim,
                                     this->image_TexImage.imageWidth,
                                     this->image_TexImage.imageHeight,
                                     this->imageDepth,
                                     this->imageExtent,
                                     this->texImageWidth, this->texImageHeight,
                                     this->texImageDepth, this->texImageExtent,
                                     this->drawOrder, this->memAlignment, &this->numDrawn);
#ifdef GL_EXT_subtexture
            }
#endif
        } else {
#ifdef GL_EXT_subtexture
            if (this->subTexture) {
                this->subTexData = CreateSubExtentData(this->texDim,
                                     this->texImageWidth, this->texImageHeight,
                                     this->texImageDepth, this->texImageExtent,
                                     this->subTexWidth, this->subTexHeight,
                                     this->subTexDepth, this->subTexExtent,
                                     this->drawOrder, this->memAlignment, &this->numDrawn);
		DefineTexImage(this->texTarget, this->texLevel, this->texComps,
                               this->texImageWidth, this->texImageHeight,
                               this->texImageDepth, this->texImageExtent,
                               this->texBorder, this->image_TexImage.imageFormat,
                               this->image_TexImage.imageType, (void*)0);
            } else {
#endif
                this->numDrawn = 1;
#ifdef GL_EXT_subtexture
            }
#endif
        }
        TexImage__CreateImageData(this);
	break;
    case DisplayList:
	this->numDrawn = 1;
        TexImage__CreateImageData(this);
	if (this->texMipmap == PreCalculate) {
	    void*** mipmapData = this->mipmapData;
	    this->dlBase = glGenLists(this->numObjects);
	    for (i = 0; i < this->numObjects; i++) {
		void** mipmap = *mipmapData;
		GLint* mipmapDimPtr = this->mipmapDimData;
		glNewList(this->dlBase+i, GL_COMPILE);
		for (j = 0; j < this->mipmapLevels; j++) {
		    GLint width = *mipmapDimPtr++;
		    GLint height  = (this->texDim > 1) ? *mipmapDimPtr++ : 1;
		    GLint depth   = (this->texDim > 2) ? *mipmapDimPtr++ : 1;
		    GLint extent  = (this->texDim > 3) ? *mipmapDimPtr++ : 1;
		    DefineTexImage(this->texTarget, j, this->texComps, 
                               width, height, depth, extent, 
                               this->texBorder, this->image_TexImage.imageFormat, 
                               this->image_TexImage.imageType, *mipmap++);
		}
		glEndList();
		mipmapData++;
	    }
	} else {
	    void** imageData = this->imageData;
	    this->dlBase = glGenLists(this->numObjects);
	    for (i = 0; i < this->numObjects; i++) {
		glNewList(this->dlBase+i, GL_COMPILE);
		DefineTexImage(this->texTarget, this->texLevel, this->texComps, 
                               this->texImageWidth, this->texImageHeight, 
                               this->texImageDepth, this->texImageExtent, 
                               this->texBorder, this->image_TexImage.imageFormat,
                                this->image_TexImage.imageType, *imageData++);
		glEndList();
	    }
	}
	break;
#ifdef GL_EXT_copy_texture
    case Framebuffer:
        this->clearBefore = False;
        Image__DrawSomething(this->environ.bufConfig.rgba, 
                             this->environ.bufConfig.indexSize,
                             this->environ.bufConfig.doubleBuffer);
	this->numDrawn = 0;
 #ifdef GL_EXT_subtexture
	if (this->subTexture) {
            this->copyTexData = CreateSubExtentData(2,
                                     windowDim, windowDim, 1, 1,
                                     this->subTexWidth, this->subTexHeight, 1, 1,
                                     this->drawOrder, this->memAlignment, &this->numDrawn);
            this->subTexData  = CreateSubExtentData(this->texDim,
                                     this->texImageWidth, this->texImageHeight, this->texImageDepth, 1,
                                     this->subTexWidth, this->subTexHeight, 1, 1,
                                     this->drawOrder, this->memAlignment, &this->numDrawn);
	    DefineTexImage(this->texTarget, this->texLevel, this->texComps, 
                               this->texImageWidth, this->texImageHeight, 
                               this->texImageDepth, this->texImageExtent, 
                               this->texBorder, this->image_TexImage.imageFormat, 
                               this->image_TexImage.imageType, (void*)0);
	} else {
 #endif
            this->copyTexData = CreateSubExtentData(2,
                                     windowDim, windowDim, 1, 1,
                                     this->texImageWidth, this->texImageHeight, 1, 1,
                                     this->drawOrder, this->memAlignment, &this->numDrawn);
 #ifdef GL_EXT_subtexture
	}
 #endif
/*
        TexImage__CreateImageData(this);
*/
	break;
#endif
#ifdef GL_EXT_texture_object
    case TexObj:
	this->numDrawn = 1;
        TexImage__CreateImageData(this);
	this->texObjs = (GLuint*)malloc(this->numObjects * sizeof(GLuint));
	CheckMalloc(this->texObjs);
	glGenTexturesEXT(this->numObjects, this->texObjs);
	if (this->texMipmap == PreCalculate) {
	    void*** mipmapData = this->mipmapData;
	    for (i = 0; i < this->numObjects; i++) {
		void** mipmap = *mipmapData;
		GLint* mipmapDimPtr = this->mipmapDimData;
		glBindTextureEXT(this->texTarget, this->texObjs[i]);
		glTexParameteri(this->texTarget, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
		glTexParameteri(this->texTarget, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL);
		for (j = 0; j < this->mipmapLevels; j++) {
		    GLint width = *mipmapDimPtr++;
		    GLint height  = (this->texDim > 1) ? *mipmapDimPtr++ : 1;
		    GLint depth   = (this->texDim > 2) ? *mipmapDimPtr++ : 1;
		    GLint extent  = (this->texDim > 3) ? *mipmapDimPtr++ : 1;
		    DefineTexImage(this->texTarget, j, this->texComps, 
                               width, height, depth, extent, 
                               this->texBorder, this->image_TexImage.imageFormat, this->image_TexImage.imageType, *mipmap++);
		}
		mipmapData++;
		DrawTriangle(this);
	    }
	} else {
	    void** imageData = this->imageData;
	    for (i = 0; i < this->numObjects; i++) {
		glBindTextureEXT(this->texTarget, this->texObjs[i]);
		glTexParameteri(this->texTarget, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		glTexParameteri(this->texTarget, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL);
		DefineTexImage(this->texTarget, this->texLevel, this->texComps, 
                               this->texImageWidth, this->texImageHeight, 
                               this->texImageDepth, this->texImageExtent, 
                               this->texBorder, this->image_TexImage.imageFormat, this->image_TexImage.imageType, *imageData++);
		DrawTriangle(this);
	    }
	}
	/* Check for residence of the texture objects */
	{
	    GLboolean *residence = (GLboolean*)malloc(this->numObjects * sizeof(GLboolean));
	    if (glAreTexturesResidentEXT(this->numObjects, this->texObjs, residence)) {
		this->residentTexObjs = this->numObjects;
	    } else {
		this->residentTexObjs = 0;
		for (i = 0; i < this->numObjects; i++)
		    if (residence[i]) this->residentTexObjs++;
	    }
	    free(residence);
	}
	break;
#endif
    default:
	break;
    }
    {
	/* Define "point" - which is actually a triangle */
	GLfloat *triPtr = this->triangleData = (GLfloat*)malloc(3 * (4 + 3) * sizeof(GLfloat));
        *triPtr++ = .5; *triPtr++ = .5; *triPtr++ = 0.; *triPtr++ = 1.;
        *triPtr++ = 0.; *triPtr++ = 0.; *triPtr++ = -1.;
        *triPtr++ = .5 + 1./this->texImageWidth; *triPtr++ = .5; *triPtr++ = 0.; *triPtr++ = 1.;
        *triPtr++ = 5./this->environ.windowWidth; *triPtr++ = 0.; *triPtr++ = -1.;
        *triPtr++ = .5; *triPtr++ = .5 + 1./this->texImageHeight; *triPtr++ = 0.; *triPtr++ = 1.;
        *triPtr++ = 0.; *triPtr++ = 5./this->environ.windowHeight; *triPtr++ = -1.;
    }
}

void TexImage__Cleanup(TestPtr thisTest)
{
    TexImagePtr this = (TexImagePtr)thisTest;
    int i, j;

    if (this->subImageData) AlignFree(this->subImageData);
#ifdef GL_EXT_subtexture
    if (this->subTexData) AlignFree(this->subTexData);
#endif
#ifdef GL_EXT_copy_texture
    if (this->copyTexData) AlignFree(this->copyTexData);
#endif
    if (this->mipmapData) {
	void*** mipmapData = this->mipmapData;
        for (i = 0; i < this->numObjects; i++) {
	    void** mipmap = *mipmapData;
	    for (j = 0; j < this->mipmapLevels; j++) {
		AlignFree(*mipmap++);
	    }
	    free(*mipmapData++);
	}
	free(this->mipmapData);
    }
    if (this->mipmapDimData) AlignFree(this->mipmapDimData);
    if (this->imageData) {
	void **imageDataPtr = this->imageData;
        for (i = 0; i < this->numObjects; i++) AlignFree(*imageDataPtr++);
	free(this->imageData);
    }

    switch (this->texImageSrc) {
    case DisplayList:
	if (glIsList(this->dlBase)) {
	    glDeleteLists(this->dlBase, this->numObjects);
	}
	break;
#ifdef GL_EXT_texture_object
    case TexObj:
	if (this->texObjs) {
	    if (glIsTextureEXT(*this->texObjs))
	        glDeleteTexturesEXT(this->numObjects, this->texObjs);
	    free(this->texObjs);
	}
	break;
#endif
    default:
	break;
    }
    free(this->triangleData);
}

int TexImage__SetState(TestPtr thisTest)
{
    TexImagePtr this = (TexImagePtr)thisTest;
    ImagePtr thisImage = (ImagePtr)(&this->image_TexImage);
    TransferMapPtr thisTransferMap = (TransferMapPtr)(&this->transfermap_TexImage);

    int   windowDim   = min(this->environ.windowWidth, this->environ.windowHeight);
    int noborderW;

    /* Initial parameter setting and checking */

    /* Source image is imageWidth by imageHeight,
     * Texture image is texImageWidth by texImageHeight
     * Subtexture image (if supported) is subTexWidth by subTexHeight
     */
    if (this->texImageWidth != -1) {
	this->subImage = True;
    } else {
	this->texImageWidth = this->image_TexImage.imageWidth;
    }
    if (this->texImageHeight != -1) {
	this->subImage = True;
    } else {
	this->texImageHeight = this->image_TexImage.imageHeight;
    }
#ifdef GL_EXT_texture3D
    if (this->texImageDepth != -1) {
	this->subImage = True;
    } else {
	this->texImageDepth = this->imageDepth;
    }
#else
    this->texImageDepth = 1;
#endif
#ifdef GL_SGIS_texture4D
    if (this->texImageExtent != -1) {
	this->subImage = True;
    } else {
	this->texImageExtent = this->imageExtent;
    }
#else
    this->texImageExtent = 1;
#endif
 
    /* Clamp texImage dimensions to "parent" image if not copytexture */
    if (this->texImageSrc != Framebuffer) {
        if (this->texImageWidth > this->image_TexImage.imageWidth)
	    this->texImageWidth = this->image_TexImage.imageWidth;
        if (this->texImageHeight > this->image_TexImage.imageHeight)
	    this->texImageHeight = this->image_TexImage.imageHeight;
#ifdef GL_EXT_texture3D
        if (this->texImageDepth > this->imageDepth)
	    this->texImageDepth = this->imageDepth;
#endif
#ifdef GL_SGIS_texture4D
        if (this->texImageExtent > this->imageExtent)
	    this->texImageExtent = this->imageExtent;
#endif
    } else {
    /* Clamp texImage dimensions to window if copytexture */
        if (this->texImageWidth > windowDim)
	    this->texImageWidth = windowDim;
        if (this->texImageHeight > windowDim)
	    this->texImageHeight = windowDim;
    }

    /* Fill in dimensions that aren't defined (for reporting and possible use later */
    /* when trying to generally figure the size of our images)                      */
    switch (this->texTarget) {
    case GL_TEXTURE_1D:
	this->texImageHeight = 1;
    case GL_TEXTURE_2D:
#ifdef GL_SGIS_detail_texture
    case GL_DETAIL_TEXTURE_2D_SGIS:
#endif
#ifdef GL_EXT_texture3D
	this->texImageDepth = 1;
    case GL_TEXTURE_3D_EXT:
#endif
#ifdef GL_SGIS_texture4D
	this->texImageExtent = 1;
#endif
    default:
	break;
    }
    switch (this->texTarget) {
    case GL_TEXTURE_1D:
	this->texDim = 1;
	break;
    case GL_TEXTURE_2D:
#ifdef GL_SGIS_detail_texture
    case GL_DETAIL_TEXTURE_2D_SGIS:
#endif
	this->texDim = 2;
	break;
#ifdef GL_EXT_texture3D
    case GL_TEXTURE_3D_EXT:
	this->texDim = 3;
	break;
#endif
#ifdef GL_SGIS_texture4D
    case GL_TEXTURE_4D_SGIS:
	this->texDim = 4;
	break;
#endif
    default:
	break;
    }

    /* Process subtexture if defined, else set subtexture dimensions to teximage dims */
#ifdef GL_EXT_subtexture
    if (this->subTexWidth != -1) {
	this->subTexture = True;
    } else {
	this->subTexWidth = this->texImageWidth;
    }
    if (this->subTexHeight != -1) {
	this->subTexture = True;
    } else {
	this->subTexHeight = this->texImageHeight;
    }
 #ifdef GL_EXT_texture3D
    if (this->subTexDepth != -1) {
	this->subTexture = True;
    } else {
	this->subTexDepth = this->texImageDepth;
    }
 #endif
    this->subTexExtent = 1;
    if (this->subTexWidth > this->texImageWidth)
	this->subTexWidth = this->texImageWidth;
    if (this->subTexHeight > this->texImageHeight)
	this->subTexHeight = this->texImageHeight;
 #ifdef GL_EXT_texture3D
    if (this->subTexDepth > this->texImageDepth)
	this->subTexDepth = this->texImageDepth;
 #endif
#endif

    /* Make sure everything's a power of two with the border removed */
    noborderW = this->texImageWidth - this->texBorder * 2;
    if (noborderW & noborderW - 1) return -1;
    if (this->texTarget != GL_TEXTURE_1D) {
	int noborderH = this->texImageHeight - this->texBorder * 2;
        if (noborderH & noborderH - 1) return -1;
    }
#ifdef GL_EXT_texture3D
    if (this->texTarget == GL_TEXTURE_3D_EXT) {
	int noborderD = this->texImageDepth - this->texBorder * 2;
        if (noborderD & noborderD - 1) return -1;
    }
#endif
#ifdef GL_SGIS_texture4D
    if (this->texTarget == GL_TEXTURE_4D_SGIS) {
	int noborderD = this->texImageDepth - this->texBorder * 2;
	int noborderV = this->texImageExtent - this->texBorder * 2;
        if (noborderD & noborderD - 1 || noborderV & noborderV - 1) return -1;
    }
#endif

#ifdef GL_EXT_subtexture
    this->subTexOrImage = this->subTexture || this->subImage;
#else
    this->subTexOrImage = this->subImage;
#endif

    /* Can't have mipmap generation and subTexture/subImage simultaneously unless it's auto */
    if (this->subTexOrImage && (this->texMipmap == PreCalculate || this->texMipmap == gluBuildMipmap) ||
	/* No calls in GLU for mipmapping over 2 dimensional images */
        this->texDim > 2 && this->texMipmap == gluBuildMipmap ||
#ifdef GL_EXT_subtexture
	/* No support in the SGIS_texture4d extension for subtexture */
        this->texDim == 4 && this->subTexture ||
#endif
#ifdef GL_EXT_copy_texture
	/* can't copy a 3D image from the framebuffer */
        this->texDim == 3 && !this->subTexture && this->texImageSrc == Framebuffer ||
	/* copy_texture extension doesn't support 4D textures */
        this->texDim == 4 && this->texImageSrc == Framebuffer ||
#endif
	/* Mipmapping not supported at all in the SGIS_texture4d extension */
        this->texDim == 4 && this->texMipmap != None)
	return -1;
    /* Can't support subTexture with DisplayList or TexObj because they're treated here as complete
     * images (i.e. they're preloaded and only their swapping time is recorded) */
#ifdef GL_EXT_texture_object
    if ((this->subTexOrImage || this->texMipmap == gluBuildMipmap) && 
        (this->texImageSrc == DisplayList || this->texImageSrc == TexObj))
	return -1;
#else
    if ((this->subTexOrImage || this->texMipmap == gluBuildMipmap) && 
         this->texImageSrc == DisplayList)
	return -1;
#endif

    /* set parent state */
    if (Test__SetState(thisTest) == -1) return -1;

    /* set other inherited classes' states */
    if (Image__SetState(thisImage) == -1) return -1;
    if (TransferMap__SetState(thisTransferMap) == -1) return -1;

    /* set own state */
    /* Make sure we won't be using any unsupported extensions! */
    if (
	this->texImageSrc == Framebuffer &&
        !strstr(this->environ.glExtensions, "GL_EXT_copy_texture") ||
        this->texImageSrc == TexObj &&
        !strstr(this->environ.glExtensions, "GL_EXT_texture_object") ||
#ifdef GL_SGIS_detail_texture
        this->texTarget == GL_DETAIL_TEXTURE_2D_SGIS &&
        !strstr(this->environ.glExtensions, "GL_SGIS_detail_texture") ||
#endif
#ifdef GL_EXT_texture3D
        this->texTarget == GL_TEXTURE_3D_EXT &&
        !strstr(this->environ.glExtensions, "GL_EXT_texture3D") ||
#endif
#ifdef GL_SGIS_texture4D
        this->texTarget == GL_SGIS_texture4D &&
        !strstr(this->environ.glExtensions, "GL_SGIS_texture4D") ||
#endif
#ifdef GL_EXT_subtexture
	this->subTexture && 
        !strstr(this->environ.glExtensions, "GL_EXT_subtexture") ||
#endif
	0) return -1;

    if (this->objDraw) {
	GLfloat *triPtr;
        /* set projection matrix */
	glTexParameteri(this->texTarget, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(this->texTarget, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexEnvi(this->texTarget, GL_TEXTURE_ENV_MODE, GL_DECAL);
	glDisable(GL_DEPTH_TEST);
	glDisable(GL_CULL_FACE);
	glDrawBuffer(GL_FRONT);
        glMatrixMode(GL_PROJECTION);
        glLoadIdentity();
        glOrtho(-1.0,1.0,-1.0,1.0,-0.5,1.5);
        glMatrixMode(GL_TEXTURE);
        glLoadIdentity();
        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();
	glColor4f(1., 1., 1., 1.);
	if (this->texDim == 1)
	    glEnable(GL_TEXTURE_1D);
	else
	    glDisable(GL_TEXTURE_1D);
	if (this->texDim == 2)
	    glEnable(GL_TEXTURE_2D);
	else
	    glDisable(GL_TEXTURE_2D);
#ifdef GL_EXT_texture3D
	if (this->texDim == 3)
	    glEnable(GL_TEXTURE_3D_EXT);
	else
	    glDisable(GL_TEXTURE_3D_EXT);
#endif
#ifdef GL_SGIS_texture4d
	if (this->texDim == 4)
	    glEnable(GL_TEXTURE_4D_SGIS);
	else
	    glDisable(GL_TEXTURE_4D_SGIS);
#endif
    }

#ifdef GL_SGIS_generate_mipmap
 #ifdef GL_EXT_texture3d
    if (this->texTarget == GL_TEXTURE_1D || 
        this->texTarget == GL_TEXTURE_2D ||
        this->texTarget == GL_TEXTURE_3D_EXT)
 #else
    if (this->texTarget == GL_TEXTURE_1D || this->texTarget == GL_TEXTURE_2D)
 #endif
        if (this->texMipmap == GenerateMipmapExt)
	    glTexParameteri(this->texTarget, GL_GENERATE_MIPMAP_SGIS, GL_TRUE);
        else
	    glTexParameteri(this->texTarget, GL_GENERATE_MIPMAP_SGIS, GL_FALSE);
#endif

    return 0;
}

void TexImage__SetExecuteFunc(TestPtr thisTest)
{
    TexImagePtr this = (TexImagePtr)thisTest;
    TexImageBindFunc bindfunc;
#ifdef GL_EXT_copy_texture
    TexImageCopyFunc copyfunc;
#endif
    TexImageLoadFunc loadfunc;

    switch (this->texImageSrc) {
#ifdef GL_EXT_texture_object
	case TexObj:
	    bindfunc.word = 0;
	    bindfunc.bits.texSrc = 1;
	    bindfunc.bits.objDraw = (this->objDraw == TexturedTriangle) 
                                     ? 2 
                                     : ((this->objDraw == TexturedPoint) ? 1 : 0);
	    bindfunc.bits.functionPtrs = this->loopFuncPtrs;
	    bindfunc.bits.multiimage = (this->numObjects > 1);
	    this->Execute = TexImageBindExecuteTable[bindfunc.word];
	    break;
#endif
	case DisplayList:
	    bindfunc.word = 0;
	    bindfunc.bits.texSrc = 0;
	    bindfunc.bits.objDraw = (this->objDraw == TexturedTriangle) 
                                     ? 2 
                                     : ((this->objDraw == TexturedPoint) ? 1 : 0);
	    bindfunc.bits.functionPtrs = this->loopFuncPtrs;
	    bindfunc.bits.multiimage = (this->numObjects > 1);
	    this->Execute = TexImageBindExecuteTable[bindfunc.word];
	    break;
#ifdef GL_EXT_copy_texture
	case Framebuffer:
	    copyfunc.word = 0;
	    copyfunc.bits.objDraw = (this->objDraw == TexturedTriangle) 
                                     ? 2 
                                     : ((this->objDraw == TexturedPoint) ? 1 : 0);
	    copyfunc.bits.functionPtrs = this->loopFuncPtrs;
	    copyfunc.bits.subtexture = this->subTexture;
	    copyfunc.bits.texDim = this->texDim - 1;
	    this->Execute = TexImageCopyExecuteTable[copyfunc.word];
	    break;
#endif
	case SystemMemory:
	    loadfunc.word = 0;
	    loadfunc.bits.objDraw = (this->objDraw == TexturedTriangle) 
                                     ? 2 
                                     : ((this->objDraw == TexturedPoint) ? 1 : 0);
	    loadfunc.bits.functionPtrs = this->loopFuncPtrs;
	    loadfunc.bits.subimage   = this->subImage;
#ifdef GL_EXT_subtexture
	    loadfunc.bits.subtexture = this->subTexture;
#endif
	    loadfunc.bits.texDim     = this->texDim - 1;
	    loadfunc.bits.multiimage = (this->numObjects > 1);
	    loadfunc.bits.multilevel = (this->texMipmap == PreCalculate);
	    loadfunc.bits.genMipmap  = (this->texMipmap == gluBuildMipmap);
	    this->Execute = TexImageLoadExecuteTable[loadfunc.word];
	    break;
    }
}

int TexImage__TimesRun(TestPtr thisTest)
{
    TexImagePtr this = (TexImagePtr)thisTest;
    return this->numDrawn;
}

float TexImage__Size(TestPtr thisTest)
{
    TexImagePtr this = (TexImagePtr)thisTest;
    float size;
    int texelsPerPixel = 1;

#ifdef GL_SGIS_texture_select
    if (GL_DUAL_ALPHA4_SGIS <= this->texComps &&
        this->texComps <= GL_DUAL_LUMINANCE_ALPHA8_SGIS) {
        texelsPerPixel = 2;
    } else if (GL_QUAD_ALPHA4_SGIS <= this->texComps &&
        this->texComps <= GL_QUAD_INTENSITY8_SGIS) {
        texelsPerPixel = 4;
    }
#endif

#ifdef GL_EXT_subtexture
    if (this->subTexture)
	size = this->subTexWidth * this->subTexHeight * 
               this->subTexDepth * this->subTexExtent * texelsPerPixel;
    else
#endif
	size = this->texImageWidth * this->texImageHeight * 
               this->texImageDepth * this->texImageExtent * texelsPerPixel;
    return (float)size;
}

void TexImage__CreateImageData(TexImagePtr this)
{
    int i, j;
    void **imagePtr;
    int imageSize;
    void *image;
    int imageWidth, imageHeight;
    int imageDepth = 1;
    int imageExtent = 1;
    int imageBorder;

    /* Figure out the dimensions of our base image and put them in imageWidth, etc. */
    if (this->subTexOrImage) {
	imageBorder = 0;
	if (this->subImage) {
	    imageWidth = this->image_TexImage.imageWidth;
	    imageHeight = this->image_TexImage.imageHeight;
#ifdef GL_EXT_texture3D
	    imageDepth = this->imageDepth;
#endif
#ifdef GL_SGIS_texture4D
	    imageExtent = this->imageExtent;
#endif
	} else { /* must be subTexture only */
#ifdef GL_EXT_subtexture
	    imageWidth = this->subTexWidth;
	    imageHeight = this->subTexHeight;
#ifdef GL_EXT_texture3D
	    imageDepth = this->subTexDepth;
#endif
#ifdef GL_SGIS_texture4D
	    imageExtent = 1; /* Subtexture not supported on 4D textures */
#endif
#endif
	}
    } else {
	imageBorder = this->texBorder;
	imageWidth = this->texImageWidth;
	imageHeight = this->texImageHeight;
#ifdef GL_EXT_texture3D
	imageDepth = this->texImageDepth;
#endif
#ifdef GL_SGIS_texture4D
	imageExtent = this->texImageExtent;
#endif
    }
 
    if (this->texMipmap == PreCalculate) {
	int width, height, depth, extent;
	const int maxLevels = 32; /* Be generous! */
	int* mipmapSize = (int*)malloc(maxLevels * sizeof(int));
        GLint* mipmapDimPtr;
	void** mipmap = (void**)malloc(maxLevels * sizeof(void*));
	void*** mipmapPtr;
	int n = 0;
	int realwidth, realheight, realdepth, realextent;
	this->mipmapDimData = (GLint*)AlignMalloc(maxLevels * this->texDim * sizeof(GLint),
                                                  this->memAlignment);
	mipmapDimPtr = this->mipmapDimData;
	/* Strip borders off image dimensions so figuring the mipmaps is easier */
	imageWidth -= 2 * imageBorder;
	if (this->texDim > 1)
	    imageHeight -= 2 * imageBorder;
#ifdef GL_EXT_texture3D
	if (this->texDim > 2)
	    imageDepth -= 2 * imageBorder;
#endif
#ifdef GL_SGIS_texture4D
	if (this->texDim > 3)
	    imageExtent -= 2 * imageBorder;
#endif
	for (width = imageWidth, height = imageHeight, depth = imageDepth, extent = imageExtent;
	     width >= 1 || height >= 1 || depth >= 1 || extent >= 1;
	     width /= 2, height /= 2, depth /= 2, extent /= 2, n++) {
	    realwidth = max(width, 1);
	    realheight = max(height, 1);
	    realdepth = max(depth, 1);
	    realextent = max(extent, 1);
	    *mipmapDimPtr++ = realwidth = realwidth + 2 * imageBorder;
	    if (this->texDim > 1) *mipmapDimPtr++ = realheight = realheight + 2 * imageBorder;
	    if (this->texDim > 2) *mipmapDimPtr++ = realdepth = realdepth + 2 * imageBorder;
	    if (this->texDim > 3) *mipmapDimPtr++ = realextent = realextent + 2 * imageBorder;
	    mipmap[n] = MakeTexImage(realwidth,
				     realheight,
				     realdepth,
				     realextent,
			             this->image_TexImage.imageFormat,
			             this->image_TexImage.imageType,
			             this->image_TexImage.imageAlignment,
			             this->image_TexImage.imageSwapBytes,
			             this->image_TexImage.imageLSBFirst,
			             this->memAlignment,
			             &mipmapSize[n]);
	}
	/* Make numObjects copies of mipmaps and put them in mipmapData */
	this->mipmapLevels = n;
	this->mipmapData = (void***)malloc(sizeof(void**) * this->numObjects);
	CheckMalloc(this->mipmapData);
	mipmapPtr = this->mipmapData;
	*mipmapPtr++ = mipmap;
	for (i = 1; i < this->numObjects; i++) {
	    *mipmapPtr = (void**)malloc(this->mipmapLevels * sizeof(void*));
	    for (j = 0; j < this->mipmapLevels; j++) {
		(*mipmapPtr)[j] = (void*)AlignMalloc(mipmapSize[j], this->memAlignment);
		memcpy((*mipmapPtr)[j], mipmap[j], mipmapSize[j]);
	    }
	    mipmapPtr++;
	}
	free(mipmapSize);
    } else {
        image = MakeTexImage(imageWidth,
			 imageHeight,
			 imageDepth,
			 imageExtent,
			 this->image_TexImage.imageFormat,
			 this->image_TexImage.imageType,
			 this->image_TexImage.imageAlignment,
			 this->image_TexImage.imageSwapBytes,
			 this->image_TexImage.imageLSBFirst,
			 this->memAlignment,
			 &imageSize);

	/* Make numObjects copies of image and put them in imageData */
        this->imageData = (void**)malloc(sizeof(void*) * this->numObjects);
        CheckMalloc(this->imageData);
        imagePtr = this->imageData;

        *imagePtr++ = image;
        for (i = 1; i < this->numObjects; i++) {
	    *imagePtr = AlignMalloc(imageSize, this->memAlignment);
	    memcpy(*imagePtr, image, imageSize);
	    imagePtr++;
        }
    }
}
