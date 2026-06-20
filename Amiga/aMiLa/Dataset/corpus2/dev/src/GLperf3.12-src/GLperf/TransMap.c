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
#include <malloc.h>
#include "Image.h"
#include "TransMap.h"

const int numMaps = 10;
const int numScales = 5;

void new_TransferMap(TransferMapPtr this)
{
    this->maps = 0;
}

void delete_TransferMap(TransferMapPtr this)
{
    int i;

    if (this->maps) {
    for (i = 0; i < numMaps; i++)
        if (this->maps[i]) free(this->maps[i]);
    free(this->maps);
    }
}

/*
 * NOTE:
 * This procedure should probably be augmented in the future to set all state
 * back to default which alters DrawPixels operation.  This is because the
 * convolution definition process and the color table definition process both
 * follow the pixel operations that apply to DrawPixels.
 */
void SaveAndSetPixelStore(GLint* alignment, GLint* lsbfirst, GLint* rowlength, GLint* skippixels, GLint* skiprows, GLint* swapbytes)
{
    /* save PixelStore mode */
    glGetIntegerv(GL_UNPACK_ALIGNMENT, alignment);
    glGetIntegerv(GL_UNPACK_LSB_FIRST, lsbfirst);
    glGetIntegerv(GL_UNPACK_ROW_LENGTH, rowlength);
    glGetIntegerv(GL_UNPACK_SKIP_PIXELS, skippixels);
    glGetIntegerv(GL_UNPACK_SKIP_ROWS, skiprows);
    glGetIntegerv(GL_UNPACK_SWAP_BYTES, swapbytes);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 4);
    glPixelStorei(GL_UNPACK_LSB_FIRST, GL_FALSE);
    glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
    glPixelStorei(GL_UNPACK_SKIP_PIXELS, 0);
    glPixelStorei(GL_UNPACK_SKIP_ROWS, 0);
    glPixelStorei(GL_UNPACK_SWAP_BYTES, GL_FALSE);
}

/*
 * NOTE:
 * This procedure should be similarly augmented like SaveAndSetPixelStore to pop
 * the pixel operations state that applies to DrawPixels.
 */
void RestorePixelStore(GLint alignment, GLint lsbfirst, GLint rowlength, GLint skippixels, GLint skiprows, GLint swapbytes)
{
    glPixelStorei(GL_UNPACK_ALIGNMENT, alignment);
    glPixelStorei(GL_UNPACK_LSB_FIRST, lsbfirst);
    glPixelStorei(GL_UNPACK_ROW_LENGTH, rowlength);
    glPixelStorei(GL_UNPACK_SKIP_PIXELS, skippixels);
    glPixelStorei(GL_UNPACK_SKIP_ROWS, skiprows);
    glPixelStorei(GL_UNPACK_SWAP_BYTES, swapbytes);
}

int TransferMap__SetState(TransferMapPtr this)
{
    GLint maxSize;
    GLfloat *ptr;
    int *mapSizes;
    int i, j, k;

    /* Set scales and biases */
    glPixelTransferi(GL_INDEX_SHIFT, this->indexShift);
    glPixelTransferi(GL_INDEX_OFFSET, this->indexOffset);
    glPixelTransferf(GL_RED_SCALE, this->redScale);
    glPixelTransferf(GL_RED_BIAS, this->redBias);
    glPixelTransferf(GL_GREEN_SCALE, this->greenScale);
    glPixelTransferf(GL_GREEN_BIAS, this->greenBias);
    glPixelTransferf(GL_BLUE_SCALE, this->blueScale);
    glPixelTransferf(GL_BLUE_BIAS, this->blueBias);
    glPixelTransferf(GL_ALPHA_SCALE, this->alphaScale);
    glPixelTransferf(GL_ALPHA_BIAS, this->alphaBias);
    glPixelTransferf(GL_DEPTH_SCALE, this->depthScale);
    glPixelTransferf(GL_DEPTH_BIAS, this->depthBias);

    /* Our maps are enumerated in the TransferMap structure in the
     * same order as they're defined in gl.h.  This makes handling
     * the maps much easier.
     */


   mapSizes = (int*)&this->itoiMapSize;

    /* Check if our table sizes are within limits and powers of 2 */
    glGetIntegerv(GL_MAX_PIXEL_MAP_TABLE, &maxSize);
    for (i = 0; i < numMaps; i++)
      if (mapSizes[i] > maxSize ||
            mapSizes[i] & mapSizes[i] - 1)
            return -1;

    /* Define our pixel maps */
    this->maps = (GLfloat**)malloc(sizeof(GLfloat*) * numMaps);
    CheckMalloc(this->maps);
    for (i = 0; i < numMaps; i++) {
        /* Create table and fill in some inverse values */

    this->maps[i] = (GLfloat*)malloc(sizeof(GLfloat) * mapSizes[i]);
        CheckMalloc(this->maps[i]);
        ptr = this->maps[i];
	if (mapSizes[i] == 1) {
	    *ptr++ = (GLfloat)1.;
	} else {
            for (j = 0; j < mapSizes[i]; j++)
                *ptr++ = (GLfloat)(1. - (GLfloat)j/(GLfloat)(mapSizes[i]-1));
	}
        /* Define it to OpenGL */
        glPixelMapfv(GL_PIXEL_MAP_I_TO_I + i, mapSizes[i], this->maps[i]);
    }

    glPixelTransferi(GL_MAP_COLOR, this->mapColor);
    glPixelTransferi(GL_MAP_STENCIL, this->mapStencil);

#ifdef GL_EXT_convolution
    {
        GLint maxConvWidth, maxConvHeight;
        GLfloat *convFilter, *convElm;
        GLfloat *convRowFilter, *convRowElm, *convColumnFilter, *convColumnElm;
        GLint alignment, lsbfirst, rowlength, skippixels, skiprows, swapbytes;
        GLint convSize;
	GLfloat sums[4];
	GLfloat scales[4];
	GLfloat defaultscales[4] = {1., 1., 1., 1.};

	/* First see if convolution extension is supported */
/*
	if (!strstr(glGetString(GL_EXTENSIONS), "GL_EXT_convolution")) return -1;
*/

        glDisable(GL_CONVOLUTION_1D_EXT);
        glDisable(GL_CONVOLUTION_2D_EXT);
        glDisable(GL_SEPARABLE_2D_EXT);

	mysrand(15000);

        switch (this->convTarget) {
        case GL_CONVOLUTION_1D_EXT:
            glGetConvolutionParameterivEXT(this->convTarget, GL_MAX_CONVOLUTION_WIDTH_EXT, &maxConvWidth);
            if (this->convWidth > maxConvWidth) return -1;
	    for (i=0; i<4; i++)
		sums[i] = 0.;
	    convFilter = (GLfloat*)malloc(this->convWidth * 4 * sizeof(GLfloat));
	    convElm = convFilter;
	    for (i = 0; i < this->convWidth; i++) {
		for (k = 0; k < 4; k++) {
		    *convElm = (double)myrand()/(double)MY_RAND_MAX;
		    sums[k] += *convElm;
		    convElm++;
		}
	    }
            SaveAndSetPixelStore(&alignment, &lsbfirst, &rowlength, &skippixels, &skiprows, &swapbytes);
	    for (i=0; i<4; i++)
		scales[i] = 1./sums[i];
	    glConvolutionParameterfvEXT(GL_CONVOLUTION_1D_EXT, GL_CONVOLUTION_FILTER_SCALE_EXT, scales);
            glConvolutionFilter1DEXT(this->convTarget, this->convInternalFormat,
                this->convWidth,
                GL_RGBA, GL_FLOAT, convFilter);
	    glConvolutionParameterfvEXT(GL_CONVOLUTION_1D_EXT, GL_CONVOLUTION_FILTER_SCALE_EXT, defaultscales);
            RestorePixelStore(alignment, lsbfirst, rowlength, skippixels, skiprows, swapbytes);
            free(convFilter);
            glConvolutionParameteriEXT(this->convTarget, GL_CONVOLUTION_BORDER_MODE_EXT, GL_REDUCE_EXT);
            glEnable(GL_CONVOLUTION_1D_EXT);
            break;
        case GL_CONVOLUTION_2D_EXT:
            /* Query Size and make sure we're in bounds */
            glGetConvolutionParameterivEXT(this->convTarget, GL_MAX_CONVOLUTION_WIDTH_EXT, &maxConvWidth);
            glGetConvolutionParameterivEXT(this->convTarget, GL_MAX_CONVOLUTION_HEIGHT_EXT, &maxConvHeight);
            if (this->convWidth > maxConvWidth) return -1;
            if (this->convHeight > maxConvHeight) return -1;
	    for (i=0; i<4; i++)
		sums[i] = 0.;
	    convFilter = (GLfloat*)malloc(this->convHeight * this->convWidth * 4 * sizeof(GLfloat));
	    convElm = convFilter;
	    for (j = 0; j < this->convHeight; j++) {
		for (i = 0; i < this->convWidth; i++) {
		    for (k = 0; k < 4; k++) {
			*convElm = (double)myrand()/(double)MY_RAND_MAX;
			sums[k] += *convElm;
			convElm++;
		    }
		}
	    }
            SaveAndSetPixelStore(&alignment, &lsbfirst, &rowlength, &skippixels, &skiprows, &swapbytes);
	    for (i=0; i<4; i++)
		scales[i] = 1./sums[i];
	    glConvolutionParameterfvEXT(this->convTarget, GL_CONVOLUTION_FILTER_SCALE_EXT, scales);
            glConvolutionFilter2DEXT(this->convTarget, this->convInternalFormat,
                this->convWidth, this->convHeight,
                GL_RGBA, GL_FLOAT, convFilter);
	    glConvolutionParameterfvEXT(this->convTarget, GL_CONVOLUTION_FILTER_SCALE_EXT, defaultscales);
            RestorePixelStore(alignment, lsbfirst, rowlength, skippixels, skiprows, swapbytes);
            free(convFilter);
            glConvolutionParameteriEXT(this->convTarget, GL_CONVOLUTION_BORDER_MODE_EXT, GL_REDUCE_EXT);
            glEnable(GL_CONVOLUTION_2D_EXT);
            break;
        case GL_SEPARABLE_2D_EXT:
            glGetConvolutionParameterivEXT(this->convTarget, GL_MAX_CONVOLUTION_WIDTH_EXT, &maxConvWidth);
            glGetConvolutionParameterivEXT(this->convTarget, GL_MAX_CONVOLUTION_HEIGHT_EXT, &maxConvHeight);
            if (this->convWidth > maxConvWidth) return -1;
            if (this->convHeight > maxConvHeight) return -1;
            for (i=0; i<4; i++)
                sums[i] = 0.;
	    convRowElm = convRowFilter = (GLfloat*)malloc(this->convWidth * 4 * sizeof(GLfloat));
	    convColumnElm = convColumnFilter = (GLfloat*)malloc(this->convHeight * 4 * sizeof(GLfloat));
            for (i = 0; i < this->convWidth; i++)
                for (k = 0; k < 4; k++)
                    *convRowElm++ = (double)myrand()/(double)MY_RAND_MAX;
            for (i = 0; i < this->convHeight; i++)
                for (k = 0; k < 4; k++)
                    *convColumnElm++ = (double)myrand()/(double)MY_RAND_MAX;
	    for (j = 0; j < this->convHeight; j++)
		for (i = 0; i < this->convWidth; i++)
		    for (k = 0; k < 4; k++)
			sums[k] += convRowFilter[4 * i + k] * convColumnFilter[4 * j + k];
            SaveAndSetPixelStore(&alignment, &lsbfirst, &rowlength, &skippixels, &skiprows, &swapbytes);
	    for (i=0; i<4; i++)
		scales[i] = 1./sqrt(sums[i]);
	    glConvolutionParameterfvEXT(this->convTarget, GL_CONVOLUTION_FILTER_SCALE_EXT, scales);
            glSeparableFilter2DEXT(this->convTarget, this->convInternalFormat,
                this->convWidth, this->convHeight,
                GL_RGBA, GL_FLOAT,
                convRowFilter, convColumnFilter);
	    glConvolutionParameterfvEXT(this->convTarget, GL_CONVOLUTION_FILTER_SCALE_EXT, defaultscales);
            RestorePixelStore(alignment, lsbfirst, rowlength, skippixels, skiprows, swapbytes);
            free(convRowFilter);
            free(convColumnFilter);
            glConvolutionParameteriEXT(this->convTarget, GL_CONVOLUTION_BORDER_MODE_EXT, GL_REDUCE_EXT);
            glEnable(GL_SEPARABLE_2D_EXT);
            break;
	default:
	    break;
        }
    }

    glPixelTransferf(GL_POST_CONVOLUTION_RED_SCALE_EXT, this->convRedScale);
    glPixelTransferf(GL_POST_CONVOLUTION_RED_BIAS_EXT, this->convRedBias);
    glPixelTransferf(GL_POST_CONVOLUTION_GREEN_SCALE_EXT, this->convGreenScale);
    glPixelTransferf(GL_POST_CONVOLUTION_GREEN_BIAS_EXT, this->convGreenBias);
    glPixelTransferf(GL_POST_CONVOLUTION_BLUE_SCALE_EXT, this->convBlueScale);
    glPixelTransferf(GL_POST_CONVOLUTION_BLUE_BIAS_EXT, this->convBlueBias);
    glPixelTransferf(GL_POST_CONVOLUTION_ALPHA_SCALE_EXT, this->convAlphaScale);
    glPixelTransferf(GL_POST_CONVOLUTION_ALPHA_BIAS_EXT, this->convAlphaBias);
#endif

#ifdef GL_SGI_color_matrix
    {
        GLfloat *mtrx = &this->cmatrixR0;

        glMatrixMode(GL_COLOR);
        if (mtrx[0 ] == 1. && mtrx[1 ] == 0. && mtrx[2 ] == 0. && mtrx[3 ] == 0. &&
            mtrx[4 ] == 0. && mtrx[5 ] == 1. && mtrx[6 ] == 0. && mtrx[7 ] == 0. &&
            mtrx[8 ] == 0. && mtrx[9 ] == 0. && mtrx[10] == 1. && mtrx[11] == 0. &&
            mtrx[12] == 0. && mtrx[13] == 0. && mtrx[14] == 0. && mtrx[15] == 1.) {
            /* If matrix is the identity, then don't call glLoadMatrix */
            glLoadIdentity();
        } else {
            glLoadMatrixf(mtrx);
        }
        glMatrixMode(GL_MODELVIEW);

        glPixelTransferf(GL_POST_COLOR_MATRIX_RED_SCALE_SGI, this->cmatrixRedScale);
        glPixelTransferf(GL_POST_COLOR_MATRIX_RED_BIAS_SGI, this->cmatrixRedBias);
        glPixelTransferf(GL_POST_COLOR_MATRIX_GREEN_SCALE_SGI, this->cmatrixGreenScale);
        glPixelTransferf(GL_POST_COLOR_MATRIX_GREEN_BIAS_SGI, this->cmatrixGreenBias);
        glPixelTransferf(GL_POST_COLOR_MATRIX_BLUE_SCALE_SGI, this->cmatrixBlueScale);
        glPixelTransferf(GL_POST_COLOR_MATRIX_BLUE_BIAS_SGI, this->cmatrixBlueBias);
        glPixelTransferf(GL_POST_COLOR_MATRIX_ALPHA_SCALE_SGI, this->cmatrixAlphaScale);
        glPixelTransferf(GL_POST_COLOR_MATRIX_ALPHA_BIAS_SGI, this->cmatrixAlphaBias);
    }
#endif

#ifdef GL_SGI_color_table
    if (this->colorTable) {
	void *colorTable;
	GLint colorTableSize;
        GLint alignment, lsbfirst, rowlength, skippixels, skiprows, swapbytes;

	/* First see if color table extension is supported */
	if (!strstr(glGetString(GL_EXTENSIONS), "GL_SGI_color_table")) return -1;

	/* Then verify that its width is a power of 2 */
	if (this->colorTableWidth & this->colorTableWidth - 1) return -1;

	colorTable = new_ImageData(this->colorTableWidth, 1,
                GL_RGBA, GL_UNSIGNED_BYTE,
                4, False, False, 0, &colorTableSize);
        SaveAndSetPixelStore(&alignment, &lsbfirst, &rowlength, &skippixels, &skiprows, &swapbytes);
	glColorTableSGI(GL_COLOR_TABLE_SGI, this->colorTableInternalFormat, this->colorTableWidth,
			GL_RGBA, GL_UNSIGNED_BYTE, colorTable);
        RestorePixelStore(alignment, lsbfirst, rowlength, skippixels, skiprows, swapbytes);
	AlignFree(colorTable);
	glEnable(GL_COLOR_TABLE_SGI);
    } else {
	glDisable(GL_COLOR_TABLE_SGI);
    }

    if (this->pcColorTable) {
	void *pcColorTable;
	GLint pcColorTableSize;
        GLint alignment, lsbfirst, rowlength, skippixels, skiprows, swapbytes;

	/* First see if color table extension is supported */
	if (!strstr(glGetString(GL_EXTENSIONS), "GL_SGI_color_table")) return -1;

	/* Then verify that its width is a power of 2 */
	if (this->pcColorTableWidth & this->pcColorTableWidth - 1) return -1;

	pcColorTable = new_ImageData(this->pcColorTableWidth, 1,
                GL_RGBA, GL_UNSIGNED_BYTE,
                4, False, False, 0, &pcColorTableSize);
        SaveAndSetPixelStore(&alignment, &lsbfirst, &rowlength, &skippixels, &skiprows, &swapbytes);
	glColorTableSGI(GL_COLOR_TABLE_SGI, this->pcColorTableInternalFormat, this->pcColorTableWidth,
			GL_RGBA, GL_UNSIGNED_BYTE, pcColorTable);
        RestorePixelStore(alignment, lsbfirst, rowlength, skippixels, skiprows, swapbytes);
	AlignFree(pcColorTable);
	glEnable(GL_POST_CONVOLUTION_COLOR_TABLE_SGI);
    } else {
	glDisable(GL_POST_CONVOLUTION_COLOR_TABLE_SGI);
    }

    if (this->pcmColorTable) {
	void *pcmColorTable;
	GLint pcmColorTableSize;
        GLint alignment, lsbfirst, rowlength, skippixels, skiprows, swapbytes;

	/* First see if color table extension is supported */
	if (!strstr(glGetString(GL_EXTENSIONS), "GL_SGI_color_table")) return -1;

	/* Then verify that its width is a power of 2 */
	if (this->pcmColorTableWidth & this->pcmColorTableWidth - 1) return -1;

	pcmColorTable = new_ImageData(this->pcmColorTableWidth, 1,
                GL_RGBA, GL_UNSIGNED_BYTE,
                4, False, False, 0, &pcmColorTableSize);
        SaveAndSetPixelStore(&alignment, &lsbfirst, &rowlength, &skippixels, &skiprows, &swapbytes);
	glColorTableSGI(GL_COLOR_TABLE_SGI, this->pcmColorTableInternalFormat, this->pcmColorTableWidth,
			GL_RGBA, GL_UNSIGNED_BYTE, pcmColorTable);
        RestorePixelStore(alignment, lsbfirst, rowlength, skippixels, skiprows, swapbytes);
	AlignFree(pcmColorTable);
	glEnable(GL_POST_COLOR_MATRIX_COLOR_TABLE_SGI);
    } else {
	glDisable(GL_POST_COLOR_MATRIX_COLOR_TABLE_SGI);
    }
#endif

#ifdef GL_EXT_histogram
    if (this->histogram) {
        /* First see if histogram extension is supported */
        if (!strstr(glGetString(GL_EXTENSIONS), "GL_EXT_histogram")) return -1;

	/* Then verify that its table width is a power of 2 */
	if (this->histogramWidth & this->histogramWidth - 1) return -1;

	glHistogramEXT(GL_HISTOGRAM_EXT, this->histogramWidth, 
                       this->histogramInternalFormat, this->histogramSink);
	glEnable(GL_HISTOGRAM_EXT);
    } else {
	glDisable(GL_HISTOGRAM_EXT);
    }

    if (this->minmax) {
        /* First see if histogram extension is supported */
        if (!strstr(glGetString(GL_EXTENSIONS), "GL_EXT_histogram")) return -1;

	glMinmaxEXT(GL_MINMAX_EXT, this->minmaxInternalFormat, this->minmaxSink);
	glEnable(GL_MINMAX_EXT);
    } else {
	glDisable(GL_MINMAX_EXT);
    }
#endif
    return 0;
}
