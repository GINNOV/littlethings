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
#include "Image.h"
#ifdef WIN32 
#include <windows.h>
#include <gl\glaux.h>
#elif __amigaos__
#include <gl/glaux.h>
#else
#include "aux.h"
#endif
#include <math.h>

void new_Image(ImagePtr this)
{
}

void delete_Image(ImagePtr this)
{
}

int Image__SetState(ImagePtr this)
{
    glPixelStorei(GL_UNPACK_SWAP_BYTES, this->imageSwapBytes);
    glPixelStorei(GL_PACK_SWAP_BYTES, this->imageSwapBytes);
    glPixelStorei(GL_UNPACK_LSB_FIRST, this->imageLSBFirst);
    glPixelStorei(GL_PACK_LSB_FIRST, this->imageLSBFirst);
    glPixelStorei(GL_UNPACK_ALIGNMENT, this->imageAlignment);
    glPixelStorei(GL_PACK_ALIGNMENT, this->imageAlignment);
    return 0;
}

static GLfloat Clamp0to1(const GLfloat x)
{
    return (fabs(x) - fabs(x-1.)) * .5 + .5;
}

static GLfloat CalcComp(const GLfloat x, const GLfloat y, const int comp)
{
    switch (comp) {
        case 0: 
            return Clamp0to1((1.0 - x) * (1.0 - x) + (1.0 - y) * (1.0 - y) * 1.2);
        case 1:
            return Clamp0to1((2.0 * x * (1.0 - x) + 2.0 * y * (1.0 - y)) * 1.2);
        case 2:
            return Clamp0to1((x * x + y * y) * 1.2);
        case 3:
            return Clamp0to1((x + y)/2.);
    }
}

void* new_ImageData(int width, int height, int format, int type, int alignment, int swapBytes, int lsbFirst, int memAlign, int *size)
{
    /* Intermediate variables */
    int iwidth;  /* image width, including alignment padding and borders  */
    int iheight; /* image height, including alignment padding and borders */
    void *image; /* image data                                            */
    int imageSize;
    int comps;   /* number of components in image                         */
    unsigned int order;   /* order of components in image                 */

    switch (format) {
	case GL_COLOR_INDEX:
	case GL_STENCIL_INDEX:
	case GL_DEPTH_COMPONENT:
	case GL_RED:
	case GL_LUMINANCE:
	    order = 0x0000;
	    comps = 1;
	    break;
	case GL_GREEN:
	    order = 0x1000;
	    comps = 1;
	    break;
	case GL_BLUE:
	    order = 0x2000;
	    comps = 1;
	    break;
	case GL_ALPHA:
	    order = 0x3000;
	    comps = 1;
	    break;
	case GL_LUMINANCE_ALPHA:
	    order = 0x0100;
	    comps = 2;
	    break;
	case GL_RGB:
	    order = 0x0120;
	    comps = 3;
	    break;
	case GL_RGBA:
	    order = 0x0123;
	    comps = 4;
	    break;
#ifdef GL_EXT_abgr
	case GL_ABGR_EXT:
	    order = 0x3210;
	    comps = 4;
	    break;
#endif
	    break;
    }

    if (type == GL_BITMAP) {
	/* Move from bits to bytes */
	iwidth = (width + 7)/8;
    } else {
	iwidth = width;
    }

    iheight = height;

    switch (type) {
	case GL_BITMAP:
	    #include "ImgBitmp.c"
	    break;
	case GL_UNSIGNED_BYTE:
            #define TYPE GLubyte
            #define CONVERT(x) (255. * x)
            #include "ImgSimp.c"
            #undef TYPE
            #undef CONVERT
            break;
	case GL_BYTE:
            #define TYPE GLbyte
            #define CONVERT(x) (255. * x -1.)/2.
            #include "ImgSimp.c"
            #undef TYPE
            #undef CONVERT
            break;
        case GL_UNSIGNED_SHORT:
            #define TYPE GLushort
            #define CONVERT(x) (65535. * x)
            #include "ImgSimp.c"
            #undef TYPE
            #undef CONVERT
            break;
        case GL_SHORT:
            #define TYPE GLshort
            #define CONVERT(x) (65535. * x - 1.)/2.
            #include "ImgSimp.c"
            #undef TYPE
            #undef CONVERT
            break;
        case GL_UNSIGNED_INT:
            #define TYPE GLuint
            #define CONVERT(x) (4294967295. * x)
            #include "ImgSimp.c"
            #undef TYPE
            #undef CONVERT
            break;
        case GL_INT:
            #define TYPE GLint
            #define CONVERT(x) (4294967295. * x - 1.)/2.
            #include "ImgSimp.c"
            #undef TYPE
            #undef CONVERT
            break;
        case GL_FLOAT:
            #define TYPE GLfloat
            #define CONVERT(x) (x)
            #include "ImgSimp.c"
            #undef TYPE
            #undef CONVERT
            break;
#ifdef GL_EXT_packed_pixels
	case GL_UNSIGNED_BYTE_3_3_2_EXT:
            #define TYPE GLubyte
            #define RED_MASK   0xe0
            #define GREEN_MASK 0x1c
            #define BLUE_MASK  0x03
            #define ALPHA_MASK 0x00
	    #define RED_SHIFT   24
	    #define GREEN_SHIFT 27
	    #define BLUE_SHIFT  30
	    #define ALPHA_SHIFT 0
            #include "ImgPack.c"
            #undef TYPE
            #undef RED_MASK
            #undef GREEN_MASK
            #undef BLUE_MASK
            #undef ALPHA_MASK
	    #undef RED_SHIFT
	    #undef GREEN_SHIFT
	    #undef BLUE_SHIFT
	    #undef ALPHA_SHIFT
            break;
	case GL_UNSIGNED_SHORT_4_4_4_4_EXT:
            #define TYPE GLushort
            #define RED_MASK   0xf000
            #define GREEN_MASK 0x0f00
            #define BLUE_MASK  0x00f0
            #define ALPHA_MASK 0x000f
	    #define RED_SHIFT   16
	    #define GREEN_SHIFT 20
	    #define BLUE_SHIFT  24
	    #define ALPHA_SHIFT 28
            #include "ImgPack.c"
            #undef TYPE
            #undef RED_MASK
            #undef GREEN_MASK
            #undef BLUE_MASK
            #undef ALPHA_MASK
	    #undef RED_SHIFT
	    #undef GREEN_SHIFT
	    #undef BLUE_SHIFT
	    #undef ALPHA_SHIFT
            break;
	case GL_UNSIGNED_SHORT_5_5_5_1_EXT:
            #define TYPE GLushort
            #define RED_MASK   0xf800
            #define GREEN_MASK 0x07c0
            #define BLUE_MASK  0x003e
            #define ALPHA_MASK 0x0001
	    #define RED_SHIFT   16
	    #define GREEN_SHIFT 21
	    #define BLUE_SHIFT  26
	    #define ALPHA_SHIFT 31
            #include "ImgPack.c"
            #undef TYPE
            #undef RED_MASK
            #undef GREEN_MASK
            #undef BLUE_MASK
            #undef ALPHA_MASK
	    #undef RED_SHIFT
	    #undef GREEN_SHIFT
	    #undef BLUE_SHIFT
	    #undef ALPHA_SHIFT
            break;
	case GL_UNSIGNED_INT_8_8_8_8_EXT:
            #define TYPE GLuint
            #define RED_MASK   0xff000000
            #define GREEN_MASK 0x00ff0000
            #define BLUE_MASK  0x0000ff00
            #define ALPHA_MASK 0x000000ff
	    #define RED_SHIFT   0
	    #define GREEN_SHIFT 8
	    #define BLUE_SHIFT  16
	    #define ALPHA_SHIFT 24
            #include "ImgPack.c"
            #undef TYPE
            #undef RED_MASK
            #undef GREEN_MASK
            #undef BLUE_MASK
            #undef ALPHA_MASK
	    #undef RED_SHIFT
	    #undef GREEN_SHIFT
	    #undef BLUE_SHIFT
	    #undef ALPHA_SHIFT
            break;
	case GL_UNSIGNED_INT_10_10_10_2_EXT:
            #define TYPE GLuint
            #define RED_MASK   0xffc00000
            #define GREEN_MASK 0x003ff000
            #define BLUE_MASK  0x00000ffc
            #define ALPHA_MASK 0x00000003
	    #define RED_SHIFT   0
	    #define GREEN_SHIFT 10
	    #define BLUE_SHIFT  20
	    #define ALPHA_SHIFT 30
            #include "ImgPack.c"
            #undef TYPE
            #undef RED_MASK
            #undef GREEN_MASK
            #undef BLUE_MASK
            #undef ALPHA_MASK
	    #undef RED_SHIFT
	    #undef GREEN_SHIFT
	    #undef BLUE_SHIFT
	    #undef ALPHA_SHIFT
            break;
#endif
    }
    *size = imageSize;
    return (void*)image;
}

static int IsPrime(int n)
{
    int i;
    for (i = n/2; i > 1; i--) 
        if (n % i == 0) return 0;
    return 1;
}

/* As the data created by this routine may be traversed, it will be allocated
 * by the AlignMalloc routine and must be freed by the caller using AlignFree.
 *
 * If *numDrawn is 0 at calling time, this routine will figure a new value
 * for that variable and set it, otherwise it will use that value.
 */
GLint* CreateSubImageData(int imageWidth, int imageHeight, int subWidth, int subHeight,
                          float acceptObjs, float rejectObjs, float clipObjs,
                          int clipMode, float percentClip, 
			  int spacedDraw,
			  int memAlignment,
                          int* numDrawn)
{
    int m, n;
    GLint *dataPtr;
    int accept, reject, clip;
    int x, y;
    int i;
    float dx, dy;
    GLint *ptr;
    int clipx, clipy;
    int rejectx, rejecty;
    int stride;
    int index;

    if (*numDrawn == 0) {
	m = (int)ceil( (float)imageWidth/(float)subWidth);
	n = (int)ceil((float)imageHeight/(float)subHeight);
	*numDrawn = m * n;
    } else {
	m = n = (int)ceil(sqrt(*numDrawn));
    }

    dataPtr = (GLint*)AlignMalloc(sizeof(GLint) * 2 * *numDrawn, memAlignment);
    ptr = dataPtr;

    accept = acceptObjs * (float)(*numDrawn);
    reject = rejectObjs * (float)(*numDrawn);
    clip = clipObjs * (float)(*numDrawn);
    accept += *numDrawn - accept - reject - clip;

    /* Do clipped ones first, if any */
    switch (clipMode) {
	case Horizontal:
	    dx = (clip == 1) ? 0. : (float)(imageWidth - subWidth) / (float)(clip - 1);
	    /* figure y position of subimages for accurate percentClip */
	    y = imageHeight - (int)floor((1. - percentClip) * (float)subHeight + .5);
	    for (i = 0; i < clip; i++) {
		*ptr++ = (GLint)floor((float)i * dx + .5);
		*ptr++ = y;
	    }
	    break;
	case Vertical:
	    dy = (clip == 1) ? 0. : (float)(imageHeight - subHeight) / (float)(clip - 1);
	    /* figure x position of subimages for accurate percentClip */
	    x = imageWidth - (int)floor((1. - percentClip) * (float)subWidth + .5);
	    for (i = 0; i < clip; i++) {
		*ptr++ = x;
		*ptr++ = (GLint)floor((float)i * dy + .5);
	    }
	    break;
	case Random:
	    clipx = clip/2;
	    clipy = clip - clipx;
	    dx = (clipx == 1) ? 0. : (float)(imageWidth - subWidth) / (float)(clipx - 1);
	    dy = (clipy == 1) ? 0. : (float)(imageHeight - subHeight) / (float)(clipy - 1);
	    /* figure x,y positions of subimages for accurate percentClip */
	    x = imageWidth - (int)floor((1. - percentClip) * (float)subWidth + .5);
	    y = imageHeight - (int)floor((1. - percentClip) * (float)subHeight + .5);
	    for (i = 0; i < clipx; i++) {
		*ptr++ = x;
		*ptr++ = (GLint)floor((float)i * dy + .5);
	    }
	    for (i = 0; i < clipy; i++) {
		*ptr++ = (GLint)floor((float)i * dx + .5);
		*ptr++ = y;
	    }
	    break;
    }

    /* Then do rejected ones */
    rejectx = reject/2;
    rejecty = reject - rejectx;
    dx = (rejectx == 1) ? 0. : (float)(imageWidth - subWidth) / (float)(rejectx - 1);
    dy = (rejecty == 1) ? 0. : (float)(imageHeight - subHeight) / (float)(rejecty - 1);
    /* figure x,y positions of subimages to make sure they're rejected */
    x = -5;
    y = -5;
    for (i = 0; i < rejectx; i++) {
	*ptr++ = x;
	*ptr++ = (GLint)floor((float)i * dy + .5);
    }
    for (i = 0; i < rejecty; i++) {
	*ptr++ = (GLint)floor((float)i * dx + .5);
	*ptr++ = y;
    }

    /* Finally, do the accepted ones */
    dx = (m == 1) ? 0. : (float)(imageWidth - subWidth) / (float)(m - 1);
    dy = (n == 1) ? 0. : (float)(imageHeight - subHeight) / (float)(n - 1);
    if (spacedDraw) {
	/* Look for a prime number which is not a factor of "accept" */
	/* This will become our "stride" to screw up the cache       */
	for (i = accept/2; i > 1; i--) 
	    if (accept % i && IsPrime(i)) break;
	/* Turn off stride if couldn't find a non-factor (e.g. accept = 2) */
	if (i == 1) 
	    spacedDraw = 0;
	else
	    stride = i;
    }
    for (i = 0; i < accept; i++) {
	index = spacedDraw ? (i*stride%accept) : i;
	*ptr++ = (GLint)floor((float)(index%m) * dx + .5);
	*ptr++ = (GLint)floor((float)(index/m) * dy + .5);
    }

    return dataPtr;
}

void Image__DrawSomething(int rgba, int indexSize, int Double_Buffer)
{
    /*
     * We don't know what the OpenGL state is at this point, so we're gonna have to 
     * "start from scratch" to make sure that all the state is set so we actually 
     * see something.
     */
    glPushAttrib(GL_COLOR_BUFFER_BIT | GL_ENABLE_BIT | GL_POLYGON_BIT);
    glDisable(GL_LIGHTING);
    glDisable(GL_CULL_FACE);
    glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
    glDisable(GL_POLYGON_STIPPLE);
    glDisable(GL_TEXTURE_1D);
    glDisable(GL_TEXTURE_2D);
    glDisable(GL_FOG);
    glDisable(GL_ALPHA_TEST);
    glDisable(GL_STENCIL_TEST);
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_BLEND);
    glDisable(GL_SCISSOR_TEST);
    glEnable(GL_DITHER);
    if(Double_Buffer)
      glDrawBuffer(GL_FRONT_AND_BACK);
    else
      glDrawBuffer(GL_FRONT);
    glColorMask(GL_TRUE , GL_TRUE , GL_TRUE , GL_TRUE );
    glIndexMask(0xffff);

    glBegin(GL_QUADS);
    if (!rgba) {
        int maxIndex = (1 << indexSize) - 1;
        glIndexf(maxIndex);
        glVertex3f(-1., -1., -1.);
        glIndexf(0);
        glVertex3f( 1., -1., -1.);
        glIndexf(maxIndex);
        glVertex3f( 1.,  1., -1.);
        glIndexf(0);
        glVertex3f(-1.,  1., -1.);
    } else {
        glColor4f(1., 0., 0., 0.);
        glVertex3f(-1., -1., -1.);
        glColor4f(0., 0., 1., 1.);
        glVertex3f( 1., -1., -1.);
        glColor4f(1., 1., 1., 0.);
        glVertex3f( 1.,  1., -1.);
        glColor4f(0., 1., 0., 1.);
        glVertex3f(-1.,  1., -1.);
    }
    glEnd();

    if(Double_Buffer)
      auxSwapBuffers();

    glPopAttrib();
}

void* MakeTexImage(int imageWidth, int imageHeight, int imageDepth, int imageExtent,
                    int imageFormat, int imageType, 
		    int imageAlignment, int imageSwapBytes, int imageLSBFirst,
                    int memAlignment, int *imageSize)
{
    /* Since I haven't written a 3d or 4d image generator, we'll take the 2D image
     * we get and replicate it numCopies times to get our multi-dimensional image */ 
    int numCopies = 1;
    int i;
    void* image;

    numCopies *= imageDepth;
    numCopies *= imageExtent;

    /* Figure our 2D texture image */
    image = new_ImageData(
                         imageWidth,
			 imageHeight,
			 imageFormat,
			 imageType,
			 imageAlignment,
			 imageSwapBytes,
			 imageLSBFirst,
			 memAlignment,
			 imageSize);

    /* Replicate to create multidimensional image, if needed */
    if (numCopies > 1) {
	char* multiImage = (char*)AlignMalloc(*imageSize * numCopies, memAlignment);
	char* copy = multiImage;
	for (i = 0; i < numCopies; i++) {
	    memcpy(copy, image, *imageSize);
	    copy += *imageSize;
	}
	AlignFree(image);
	image = multiImage;
	*imageSize *= numCopies;
    }
    return image;
}
