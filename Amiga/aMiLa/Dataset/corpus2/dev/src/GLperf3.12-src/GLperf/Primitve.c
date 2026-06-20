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
// Authors:  Barry Minor, John Spitzer, IBM AWS Graphics Systems (Austin)
//
*/

#include <math.h>
#include "Primitve.h"
#include "Image.h"
#include <malloc.h>

void new_Primitive(PrimitivePtr this)
{
    new_Drawn((DrawnPtr)this);
    this->traversalData = 0;
    /* Set virtual functions */
    this->SetState = Primitive__SetState;
    this->delete = delete_Primitive;
}

void delete_Primitive(TestPtr thisTest)
{
    PrimitivePtr this = (PrimitivePtr)thisTest;

    delete_Drawn(thisTest);
}

void Primitive__SetProjection(PrimitivePtr this, int dimension)
{
    /* set projection matrix */
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    if (this->projection == Parallel) {
	glOrtho(-1.0, 1.0, -1.0, 1.0, -0.5, 1.5);
    } else { /* Perspective */
	gluPerspective(90.0, 1.0, 0.5, 2.5);
    }
    glMatrixMode(GL_TEXTURE);
    glLoadIdentity();
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

}

int Primitive__SetState(TestPtr thisTest)
{
    PrimitivePtr this = (PrimitivePtr)thisTest;
    int i;
    int size;

    /* set parent state */
    if (Drawn__SetState(thisTest) == -1) return -1;

    /* set own state */

    if (!this->fogMode) {
        glDisable(GL_FOG);
    } else {
        glFogi(GL_FOG_MODE, this->fogMode);
        glFogf(GL_FOG_START, 0.0);
        glFogf(GL_FOG_END, 1.0);
        glEnable(GL_FOG);
    }

    if (!this->alphaTest) {
        glDisable(GL_ALPHA_TEST);
    } else {
        glAlphaFunc(this->alphaTest, this->alphaRef);
        glEnable(GL_ALPHA_TEST);
    }

    if (!this->stencilTest) {
        glDisable(GL_STENCIL_TEST);
    } else {
        glStencilFunc(this->stencilTest, 0, 0xffffffff);
        glEnable(GL_STENCIL_TEST);
    }

    if (!this->depthTest) {
        glDisable(GL_DEPTH_TEST);
    } else {
        glDepthFunc(this->depthTest);
        glEnable(GL_DEPTH_TEST);
    }

    glDepthMask(this->depthMask);

    if (!this->blend) {
        glDisable(GL_BLEND);
    } else {
#ifdef GL_EXT_blend_color
	if (strstr(this->environ.glExtensions, "GL_EXT_blend_color"))
            glBlendColorEXT(.5, .5, .5, .5);
#endif
#if defined(GL_EXT_blend_logic_op) || defined(GL_EXT_blend_minmax) || defined(GL_EXT_blend_subtract)
	if (
 #ifdef GL_EXT_blend_logic_op
	    (this->blendEq == GL_LOGIC_OP &&
	    strstr(this->environ.glExtensions, "GL_EXT_blend_logic_op")) ||
 #endif
 #ifdef GL_EXT_blend_minmax
	    ((this->blendEq == GL_MIN_EXT || this->blendEq == GL_MAX_EXT) &&
	    strstr(this->environ.glExtensions, "GL_EXT_blend_minmax")) ||
 #endif
 #ifdef GL_EXT_blend_subtract
	    ((this->blendEq == GL_FUNC_SUBTRACT_EXT || this->blendEq == GL_FUNC_REVERSE_SUBTRACT_EXT) &&
	    strstr(this->environ.glExtensions, "GL_EXT_blend_subtract")) ||
 #endif
	    (this->blendEq == GL_FUNC_ADD_EXT))
		glBlendEquationEXT(this->blendEq);
	else
		return -1;
#endif
#ifdef GL_EXT_blend_logic_op
        if (this->blendEq == GL_LOGIC_OP)
            glLogicOp(this->logicOp ? this->logicOp : GL_COPY);
#endif
#ifdef GL_EXT_blend_color
	if ((this->srcBlend == GL_CONSTANT_COLOR_EXT ||
	    this->srcBlend == GL_ONE_MINUS_CONSTANT_COLOR_EXT ||
	    this->srcBlend == GL_CONSTANT_ALPHA_EXT ||
	    this->srcBlend == GL_ONE_MINUS_CONSTANT_ALPHA_EXT ||
	    this->dstBlend == GL_CONSTANT_COLOR_EXT ||
	    this->dstBlend == GL_ONE_MINUS_CONSTANT_COLOR_EXT ||
	    this->dstBlend == GL_CONSTANT_ALPHA_EXT ||
	    this->dstBlend == GL_ONE_MINUS_CONSTANT_ALPHA_EXT) &&
	    !strstr(this->environ.glExtensions, "GL_EXT_blend_color")) return -1;
#endif
        glBlendFunc(this->srcBlend, this->dstBlend);
        glEnable(GL_BLEND);
    }

    if (!this->logicOp) {
        glDisable(GL_LOGIC_OP);
    } else {
        glLogicOp(this->logicOp);
        glEnable(GL_LOGIC_OP);
    }

#ifdef GL_SGIS_MULTISAMPLE
    if (!this->multisample) {
	glDisable(GL_MULTISAMPLE_SGIS);
    } else {
	glEnable(GL_MULTISAMPLE_SGIS);
    }
#endif

    if (!this->texture) {
        glDisable(GL_TEXTURE_1D);
        glDisable(GL_TEXTURE_2D);
#ifdef GL_EXT_texture3D
	if (strstr(this->environ.glExtensions, "GL_EXT_texture3D"))
            glDisable(GL_TEXTURE_3D_EXT);
#endif
#ifdef GL_SGIS_texture4D
	if (strstr(this->environ.glExtensions, "GL_SGIS_texture4D"))
            glDisable(GL_TEXTURE_4D_SGIS);
#endif
	if (this->textureData == PerVertex) this->textureData = None;
    } else {
        int mipmap;
	int noborderW, noborderH, noborderD, noborderV;

	/* Get out of here if we're gonna use unsupported extensions! */
#ifdef GL_SGIS_sharpen_texture
        if ((this->texMagFilter == GL_LINEAR_SHARPEN_SGIS ||
            this->texMagFilter == GL_LINEAR_SHARPEN_ALPHA_SGIS ||
            this->texMagFilter == GL_LINEAR_SHARPEN_COLOR_SGIS) &&
	    !strstr(this->environ.glExtensions, "GL_SGIS_sharpen_texture"))
	    return -1;
#endif
#ifdef GL_SGIS_detail_texture
        if ((this->texMagFilter == GL_LINEAR_DETAIL_SGIS ||
            this->texMagFilter == GL_LINEAR_DETAIL_ALPHA_SGIS ||
            this->texMagFilter == GL_LINEAR_DETAIL_COLOR_SGIS) &&
	    !strstr(this->environ.glExtensions, "GL_SGIS_detail_texture"))
	    return -1;
#endif
#ifdef GL_SGIS_texture_filter4
        if ((this->texMagFilter == GL_FILTER4_SGIS ||
            this->texMinFilter == GL_FILTER4_SGIS) &&
	    !strstr(this->environ.glExtensions, "GL_SGIS_texture_filter4"))
	    return -1;
#endif
#ifdef GL_SGIS_texture_border_clamp
	if ((this->texWrapS == GL_CLAMP_TO_BORDER_SGIS ||
	    this->texWrapT == GL_CLAMP_TO_BORDER_SGIS ||
 #ifdef GL_EXT_texture3D
	    this->texWrapR == GL_CLAMP_TO_BORDER_SGIS ||
 #endif
 #ifdef GL_SGIS_texture4D
	    this->texWrapQ == GL_CLAMP_TO_BORDER_SGIS ||
 #endif
	    0) &&
	    !strstr(this->environ.glExtensions, "GL_SGIS_texture_border_clamp"))
	    return -1;
#endif
#ifdef GL_SGIS_texture_edge_clamp
	if ((this->texWrapS == GL_CLAMP_TO_EDGE_SGIS ||
	    this->texWrapT == GL_CLAMP_TO_EDGE_SGIS ||
 #ifdef GL_EXT_texture3D
	    this->texWrapR == GL_CLAMP_TO_EDGE_SGIS ||
 #endif
 #ifdef GL_SGIS_texture4D
	    this->texWrapQ == GL_CLAMP_TO_EDGE_SGIS ||
 #endif
	    0) &&
	    !strstr(this->environ.glExtensions, "GL_SGIS_texture_edge_clamp"))
	    return -1;
#endif
#ifdef GL_EXT_texture3D
	if (this->texture == GL_TEXTURE_3D_EXT &&
	    !strstr(this->environ.glExtensions, "GL_EXT_texture3D"))
	    return -1;
#endif
#ifdef GL_SGIS_texture4D
	if (this->texture == GL_TEXTURE_4D_SGIS &&
	    !strstr(this->environ.glExtensions, "GL_SGIS_texture4D"))
	    return -1;
#endif

        /* Figure if we need to create mipmaps or not */
#ifdef GL_SGIS_filter4
	if (this->texMinFilter == GL_NEAREST || 
	    this->texMinFilter == GL_LINEAR || 
	    this->texMinFilter == GL_FILTER4_SGIS)
#else
        if (this->texMinFilter == GL_NEAREST || 
	    this->texMinFilter == GL_LINEAR)
#endif
#ifdef GL_SGIS_sharpen_texture
	    if (this->texMagFilter == GL_LINEAR_SHARPEN_SGIS ||
		this->texMagFilter == GL_LINEAR_SHARPEN_ALPHA_SGIS ||
		this->texMagFilter == GL_LINEAR_SHARPEN_COLOR_SGIS)
		mipmap = 1;
	    else
#endif
		mipmap = 0;
	else
	    mipmap = 1;

        /* Fill in dimensions that aren't defined (for reporting and possible use later) */
        switch (this->texture) {
        case GL_TEXTURE_1D:
            this->texHeight = 1;
        case GL_TEXTURE_2D:
            this->texDepth = 1;
#ifdef GL_EXT_texture3D
        case GL_TEXTURE_3D_EXT:
#endif
            this->texExtent = 1;
#ifdef GL_SGIS_texture4D
	case GL_TEXTURE_4D_SGIS:
#endif
        default:
            break;
        }

        /* Figure dimensionality of our texture image */
        switch (this->texture) {
        case GL_TEXTURE_1D:
            this->texDim = 1;
            break;
        case GL_TEXTURE_2D:
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

        /* Make sure everything's a power of two with the border removed */
        noborderW = this->texWidth - this->texBorder * 2;
        if (noborderW & noborderW - 1) return -1;
        if (this->texDim > 1) {
            int noborderH = this->texHeight - this->texBorder * 2;
            if (noborderH & noborderH - 1) return -1;
        }
        if (this->texDim > 2) {
            int noborderD = this->texDepth - this->texBorder * 2;
            if (noborderD & noborderD - 1) return -1;
        }
        if (this->texDim > 3) {
            int noborderV = this->texExtent - this->texBorder * 2;
            if (noborderV & noborderV - 1) return -1;
        }

        /* Set texture parameters */
        glTexParameteri(this->texture, GL_TEXTURE_MAG_FILTER, this->texMagFilter);
        glTexParameteri(this->texture, GL_TEXTURE_MIN_FILTER, this->texMinFilter);
        glTexParameteri(this->texture, GL_TEXTURE_WRAP_S, this->texWrapS);
        glTexParameteri(this->texture, GL_TEXTURE_WRAP_T, this->texWrapT);
#ifdef GL_EXT_texture3D
	if (strstr(this->environ.glExtensions, "GL_EXT_texture3D"))
            glTexParameteri(this->texture, GL_TEXTURE_WRAP_R_EXT, this->texWrapR);
#endif
#ifdef GL_SGIS_texture4D
	if (strstr(this->environ.glExtensions, "GL_SGIS_texture4D"))
            glTexParameteri(this->texture, GL_TEXTURE_WRAP_Q_SGIS, this->texWrapQ);
#endif
        glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, this->texFunc);
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

#ifdef GL_SGIX_texture_scale_bias
	/* Define post texture filter scale and bias values */
	glTexParameterfv(this->texture, 
                         GL_POST_TEXTURE_FILTER_SCALE_SGIX, 
                         &this->texRedScale);
	glTexParameterfv(this->texture, 
                         GL_POST_TEXTURE_FILTER_BIAS_SGIX, 
                         &this->texRedBias);
#endif

#ifdef GL_SGI_texture_color_table
	/* Define texture color table if appropriate */
	if (this->texColorTable) {
	    void *texColorTable;
	    GLint texColorTableSize;

	    /* First see if color table extension is supported */
            if (!strstr(this->environ.glExtensions, "GL_SGI_texture_color_table")) return -1;

            /* Then verify that its width is a power of 2 */
            if (this->texColorTableWidth & this->texColorTableWidth - 1) return -1;

	    /* Create and define texture color table */
            texColorTable = new_ImageData(this->texColorTableWidth, 1,
                                          GL_RGBA, GL_UNSIGNED_BYTE,
                                          4, False, False, 0, &texColorTableSize);
            glColorTableSGI(GL_TEXTURE_COLOR_TABLE_SGI, this->texColorTableInternalFormat, 
                            this->texColorTableWidth,
                            GL_RGBA, GL_UNSIGNED_BYTE, texColorTable);
            AlignFree(texColorTable);

	    glEnable(GL_TEXTURE_COLOR_TABLE_SGI);
	} else {
	    glDisable(GL_TEXTURE_COLOR_TABLE_SGI);
	}
#endif

        /* Create images and define them */
        if (mipmap) {
            int imagewidth, imageheight, imagedepth, imageextent;
            int width, height, depth, extent;
            int realwidth, realheight, realdepth, realextent;
            int n = 0;
            void* mipmap;

            /* Strip borders off image dimensions so figuring the mipmaps is easier */
            imagewidth = this->texWidth - 2 * this->texBorder;
            if (this->texDim > 1)
                imageheight = this->texHeight - 2 * this->texBorder;
	    else
		imageheight = 1;
            if (this->texDim > 2)
                imagedepth = this->texDepth - 2 * this->texBorder;
	    else
		imagedepth = 1;
            if (this->texDim > 3)
                imageextent = this->texExtent - 2 * this->texBorder;
	    else
		imageextent = 1;

            for (width = imagewidth, height = imageheight, depth = imagedepth, extent = imageextent;
                width >= 1 || height >= 1 || depth >= 1 || extent >= 1;
                width /= 2, height /= 2, depth /= 2, extent /= 2, n++) {
                realwidth = max(width, 1);
                realheight = max(height, 1);
                realdepth = max(depth, 1);
                realextent = max(extent, 1);
                realwidth += 2 * this->texBorder;
                if (this->texDim > 1) realheight += 2 * this->texBorder;
                if (this->texDim > 2) realdepth += 2 * this->texBorder;
                if (this->texDim > 3) realextent += 2 * this->texBorder;
                mipmap = MakeTexImage(realwidth,
                    realheight,
                    realdepth,
                    realextent,
                    GL_RGBA,
                    GL_UNSIGNED_SHORT,
                    4,
                    GL_FALSE,
                    GL_FALSE,
                    this->memAlignment,
                    &size);
                DefineTexImage(this->texture, n, this->texComps, 
                    realwidth, realheight, realdepth, realextent,
                    this->texBorder, GL_RGBA, GL_UNSIGNED_SHORT, mipmap);
                AlignFree(mipmap);
            }
        } else {
            void* image = MakeTexImage(this->texWidth,
                this->texHeight,
                this->texDepth,
                this->texExtent,
                GL_RGBA,
                GL_UNSIGNED_SHORT,
                4,
                GL_FALSE,
                GL_FALSE,
                this->memAlignment,
                &size);
            DefineTexImage(this->texture, 0, this->texComps, 
                this->texWidth, this->texHeight, this->texDepth, this->texExtent,
                this->texBorder, GL_RGBA, GL_UNSIGNED_SHORT, image);
            AlignFree(image);

        }

#ifdef GL_SGIS_detail_texture
        /* Create detail texture image, if appropriate */
        if (this->texMagFilter == GL_LINEAR_DETAIL_SGIS ||
            this->texMagFilter == GL_LINEAR_DETAIL_ALPHA_SGIS ||
            this->texMagFilter == GL_LINEAR_DETAIL_COLOR_SGIS) {
            void *image;
            if (this->detailWidth & this->detailWidth - 1 ||
                this->detailHeight & this->detailHeight - 1 ||
		!strstr(this->environ.glExtensions, "GL_SGIS_detail_texture"))
		return -1;
            image = MakeTexImage(this->detailWidth,
                this->detailHeight,
                1,
                1,
                GL_RGBA,
                GL_UNSIGNED_SHORT,
                4,
                GL_FALSE,
                GL_FALSE,
                this->memAlignment,
                &size);
            glTexParameteri(GL_DETAIL_TEXTURE_2D_SGIS, GL_DETAIL_TEXTURE_LEVEL_SGIS, this->detailLevel);
            glTexParameteri(GL_DETAIL_TEXTURE_2D_SGIS, GL_DETAIL_TEXTURE_MODE_SGIS, this->detailMode);
            DefineTexImage(GL_DETAIL_TEXTURE_2D_SGIS, 0, this->texComps,
                this->detailWidth, this->detailHeight, 1, 1,
                0, GL_RGBA, GL_UNSIGNED_SHORT, image);
            AlignFree(image);
        }
#endif

#ifdef GL_SGIS_texture_select
	if (GL_DUAL_ALPHA4_SGIS <= this->texComps && 
            this->texComps <= GL_DUAL_LUMINANCE_ALPHA8_SGIS) {
	    glTexParameteri(this->texture, GL_DUAL_TEXTURE_SELECT_SGIS, this->texSelect);
	} else if (GL_QUAD_ALPHA4_SGIS <= this->texComps &&
                   this->texComps <= GL_QUAD_INTENSITY8_SGIS) {
	    glTexParameteri(this->texture, GL_QUAD_TEXTURE_SELECT_SGIS, this->texSelect);
	}
#endif
    }

    if (!this->texGen) {
        glDisable(GL_TEXTURE_GEN_S);
        glDisable(GL_TEXTURE_GEN_T);
    } else {
        glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, this->texGen);
        glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, this->texGen);
        glEnable(GL_TEXTURE_GEN_S);
        glEnable(GL_TEXTURE_GEN_T);
    }

    return 0;
}

void CalcRGBColor(GLfloat u, GLfloat* r, GLfloat* g, GLfloat* b)
{
    /* These should look familiar... (Second degree Bernstein basis) */
    *r = (1.0 - u) * (1.0 - u);
    *g = 2.0 * u * (1.0 - u);
    *b = u * u;
}

static GLfloat Clamp0to1(GLfloat x)
{
    return (fabs(x) - fabs(x-1.)) * .5 + .5;
}

void AddColorRGBData(GLfloat* data, GLfloat x, GLfloat y, GLfloat cf)
{
    GLfloat rx, gx, bx, ry, gy, by;

    CalcRGBColor((x+1.0)/2.0, &rx, &gx, &bx);
    CalcRGBColor((y+1.0)/2.0, &gy, &ry, &by);
    *data++ = Clamp0to1(cf * (rx + ry) * 3.0 / 2.0);
    *data++ = Clamp0to1(cf * (gx + gy) * 3.0 / 2.0);
    *data++ = Clamp0to1(cf * (bx + by) * 3.0 / 2.0);
}

void AddColorRGBAData(GLfloat* data, GLfloat x, GLfloat y, GLfloat cf)
{
    GLfloat rx, gx, bx, ax, ry, gy, by, ay;

    CalcRGBColor((x+1.0)/2.0, &rx, &gx, &bx);
    CalcRGBColor((y+1.0)/2.0, &gy, &ry, &by);
    *data++ = Clamp0to1(cf * (rx + ry) * 3.0 / 2.0);
    *data++ = Clamp0to1(cf * (gx + gy) * 3.0 / 2.0);
    *data++ = Clamp0to1(cf * (bx + by) * 3.0 / 2.0);
    *data++ = Clamp0to1((x + y + 2.)/4.);
}

void AddColorCIData(GLfloat* data, GLfloat x, GLfloat y, int dim, int rampsize)
{
    GLfloat index = (GLfloat)((int)((x + 1.0)/2.0 * dim) % 128 + 63)/255.*(GLfloat)rampsize;
    *data++ = index;
}

#ifdef GL_SGI_array_formats
void AddColorCIDataUI(GLfloat* data, GLfloat x, GLfloat y, int dim, int rampsize)
{
    GLuint index = (GLuint)((int)((x + 1.0)/2.0 * dim) % 128 + 63)/255.*(GLfloat)rampsize;
    GLuint *idata = (GLuint *) data;
    *idata = index;
}
#endif

void AddTexture1DData(GLfloat* data, GLfloat x, GLfloat y, GLfloat tfx)
{
    *data++ = (tfx * x + 1.)/2.;
}

void AddTexture2DData(GLfloat* data, GLfloat x, GLfloat y, GLfloat tfx, GLfloat tfy)
{
    *data++ = (tfx * x + 1.)/2.;
    *data++ = (tfy * y + 1.)/2.;
}

void AddTexture3DData(GLfloat* data, GLfloat x, GLfloat y, GLfloat tfx, GLfloat tfy, GLfloat tfz)
{
    *data++ = (tfx * x + 1.)/2.;
    *data++ = (tfy * y + 1.)/2.;
    *data++ = (tfz * y + 1.)/2.;
}
