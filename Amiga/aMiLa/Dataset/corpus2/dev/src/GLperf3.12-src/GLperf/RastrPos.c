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
#include "RastrPos.h"
#include <malloc.h>

void new_RasterPos(RasterPosPtr this)
{
    new_Primitive((PrimitivePtr)this);
    /* Set virtual functions */
    this->SetState = RasterPos__SetState;
    this->delete = delete_RasterPos;
}

void delete_RasterPos(TestPtr thisTest)
{
    RasterPosPtr this = (RasterPosPtr)thisTest;

    delete_Primitive(thisTest);
}

int RasterPos__SetState(TestPtr thisTest)
{
    RasterPosPtr this = (RasterPosPtr)thisTest;

    /* set parent state */
    if (Primitive__SetState(thisTest) == -1) return -1;
    Primitive__SetProjection((PrimitivePtr)this, this->rasterPosDim);

    /* set own state */

    return 0;
}

void RasterPos__AddTraversalData(RasterPosPtr this)
{
    GLfloat x, y;
    int i, j, k;
    int rasterPosDataSize, traversalDataSize, dataSize;
    int numDrawn = this->numDrawn;
    GLfloat* newTraversalData;
    GLfloat* newptr;
    GLfloat* ptr = this->traversalData;
    int rgba = this->environ.bufConfig.rgba;
    int colorData = this->colorData;
    int normalData = this->normalData;
    int textureData = this->textureData;
    const GLfloat colorFactor = 0.8;
    GLfloat texFactorX, texFactorY, texFactorZ;
    int windowDim = min(this->environ.windowWidth, this->environ.windowHeight);
    GLdouble modelMatrix[16];
    GLdouble projMatrix[16];
    GLint viewport[4];
    GLdouble xd, yd, zd;
    GLdouble depthBits, epsilon;
    GLdouble base, range, delta;

    int rampsize = rgba ? 0 : (1 << this->environ.bufConfig.indexSize);

    rasterPosDataSize = (colorData == PerRasterPos) ? ((rgba) ? this->colorDim : 1) : 0;
    rasterPosDataSize += (textureData == PerRasterPos)
                          ? ((this->texture==GL_TEXTURE_1D)
                             ? 1 
                             : ((this->texture==GL_TEXTURE_2D)
                                ? 2
                                : 3)) 
                          : 0;
    rasterPosDataSize += this->rasterPosDim;
    dataSize = numDrawn * rasterPosDataSize;
    newTraversalData = (GLfloat*)AlignMalloc(dataSize * sizeof(GLfloat), this->memAlignment);
    newptr = newTraversalData;

    if (this->rasterPosDim == 3 && this->zOrder != Coplanar) {
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
    }

    /* Figure out texture scaling factors given desired texture LOD */
    if (textureData == PerRasterPos && this->environ.bufConfig.rgba) {
        texFactorX = pow(2., this->texLOD) * 
                     (float)this->environ.windowWidth / (float)this->texWidth;
        texFactorY = pow(2., this->texLOD) * 
                     (float)this->environ.windowHeight / (float)this->texHeight;
#ifdef GL_EXT_texture3D
        /* This will need to be fixed at some point... */
        texFactorZ = pow(2., this->texLOD);
#endif
    }

    x = *ptr++;
    y = *ptr++;
    for (i=0; i<numDrawn; i++) {
        if (colorData == PerRasterPos) {
            if (rgba) {
                if (this->colorDim == 3) {
                    AddColorRGBData(newptr, x, y, colorFactor);
                    newptr += 3;
                } else {
                    AddColorRGBAData(newptr, x, y, colorFactor);
                    newptr += 4;
                }
            } else {
                AddColorCIData(newptr, x, y, windowDim, rampsize);
                newptr += 1;
            }
        }
        if (textureData == PerRasterPos && this->environ.bufConfig.rgba) {
            if (this->texture == GL_TEXTURE_1D) {
                AddTexture1DData(newptr, x, y, texFactorX);
                newptr += 1;
            } else if (this->texture == GL_TEXTURE_2D) {
                AddTexture2DData(newptr, x, y, texFactorX, texFactorY);
                newptr += 2;
            } else { /* GL_TEXTURE_3D_EXT */
                AddTexture3DData(newptr, x, y, texFactorX, texFactorY, texFactorZ);
                newptr += 3;
            }
        }
        if (this->rasterPosDim == 2) {
            *newptr++ = x;
            *newptr++ = y;
        } else { /* rasterPosDim == 3 */
            if (this->zOrder != Coplanar) {
	        GLdouble z = base + 
                             delta * (GLdouble)i +
                             range * (GLdouble)myrand()/(GLdouble)MY_RAND_MAX;
                gluUnProject((x+1.)/2.*(GLfloat)windowDim,
                    (y+1.)/2.*(GLfloat)windowDim,
                    z,
                    modelMatrix,
                    projMatrix,
                    viewport,
                    &xd, &yd, &zd);
                *newptr++ = (GLfloat)xd;
                *newptr++ = (GLfloat)yd;
                *newptr++ = (GLfloat)zd;
            } else {
                *newptr++ = x;
                *newptr++ = y;
                *newptr++ = -1.;
            }
        }
        x = *ptr++;
        y = *ptr++;
    }
    AlignFree(this->traversalData);
    this->traversalData = newTraversalData;
}
