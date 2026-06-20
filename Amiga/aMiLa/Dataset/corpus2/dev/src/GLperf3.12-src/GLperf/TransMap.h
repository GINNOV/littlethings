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

#if (defined(INC_REASON)) && (INC_REASON == INFO_ITEM_STRUCT)
    GLfloat redScale;
    GLfloat redBias;
    GLfloat greenScale;
    GLfloat greenBias;
    GLfloat blueScale;
    GLfloat blueBias;
    GLfloat alphaScale;
    GLfloat alphaBias;
    int indexShift;
    int indexOffset;
    GLfloat depthScale;
    GLfloat depthBias;
    int mapColor;
    int mapStencil;
    /* You CANNOT REARRANGE these next ten members */
    int itoiMapSize;
    int stosMapSize;
    int itorMapSize;
    int itogMapSize;
    int itobMapSize;
    int itoaMapSize;
    int rtorMapSize;
    int gtogMapSize;
    int btobMapSize;
    int atoaMapSize;
#ifdef GL_EXT_convolution
    GLenum convTarget;
    GLenum convInternalFormat;
    GLint convWidth;
    GLint convHeight;
    GLfloat convRedScale;
    GLfloat convRedBias;
    GLfloat convGreenScale;
    GLfloat convGreenBias;
    GLfloat convBlueScale;
    GLfloat convBlueBias;
    GLfloat convAlphaScale;
    GLfloat convAlphaBias;
#endif
#ifdef GL_SGI_color_matrix
    /* You CANNOT REARRANGE these next 16 members */
    GLfloat cmatrixR0;
    GLfloat cmatrixR1;
    GLfloat cmatrixR2;
    GLfloat cmatrixR3;
    GLfloat cmatrixG0;
    GLfloat cmatrixG1;
    GLfloat cmatrixG2;
    GLfloat cmatrixG3;
    GLfloat cmatrixB0;
    GLfloat cmatrixB1;
    GLfloat cmatrixB2;
    GLfloat cmatrixB3;
    GLfloat cmatrixA0;
    GLfloat cmatrixA1;
    GLfloat cmatrixA2;
    GLfloat cmatrixA3;
    GLfloat cmatrixRedScale;
    GLfloat cmatrixRedBias;
    GLfloat cmatrixGreenScale;
    GLfloat cmatrixGreenBias;
    GLfloat cmatrixBlueScale;
    GLfloat cmatrixBlueBias;
    GLfloat cmatrixAlphaScale;
    GLfloat cmatrixAlphaBias;
#endif
#ifdef GL_SGI_color_table
    int colorTable;
    int colorTableWidth;
    int colorTableInternalFormat;
    int pcColorTable;
    int pcColorTableWidth;
    int pcColorTableInternalFormat;
    int pcmColorTable;
    int pcmColorTableWidth;
    int pcmColorTableInternalFormat;
#endif
#ifdef GL_EXT_histogram
    int histogram;
    int histogramWidth;
    int histogramInternalFormat;
    int histogramSink;
    int minmax;
    int minmaxInternalFormat;
    int minmaxSink;
#endif
    /* Members below this line aren't user settable */
    GLfloat** maps;

#elif (defined(INC_REASON)) && (INC_REASON == INFO_ITEM_ARRAY)
    {
        MapColor,
        "PixelMap Color",
        offset(mapColor),
        Enumerated,
        {
            { True,                     "True" },
            { False,                    "False" },
            { End }
        },
        { False }
    },
    {
        MapStencil,
        "PixelMap Stencil",
        offset(mapStencil),
        Enumerated,
        {
            { True,                     "True" },
            { False,                    "False" },
            { End }
        },
        { False }
    },
    {
        RedScale,
        "PixelTransfer Red Scale Factor",
        offset(redScale),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 1. }
    },
    {
        RedBias,
        "PixelTransfer Red Bias Factor",
        offset(redBias),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 0. }
    },
    {
        GreenScale,
        "PixelTransfer Green Scale Factor",
        offset(greenScale),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 1. }
    },
    {
        GreenBias,
        "PixelTransfer Green Bias Factor",
        offset(greenBias),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 0. }
    },
    {
        BlueScale,
        "PixelTransfer Blue Scale Factor",
        offset(blueScale),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 1. }
    },
    {
        BlueBias,
        "PixelTransfer Blue Bias Factor",
        offset(blueBias),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 0. }
    },
    {
        AlphaScale,
        "PixelTransfer Alpha Scale Factor",
        offset(alphaScale),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 1. }
    },
    {
        AlphaBias,
        "PixelTransfer Alpha Bias Factor",
        offset(alphaBias),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 0. }
    },
    {
        IndexShift,
        "PixelTransfer Index Shift",
        offset(indexShift),
        UnrangedInteger,
        {
            { NotUsed },
        },
        { 0 }
    },
    {
        IndexOffset,
        "PixelTransfer Index Offset",
        offset(indexOffset),
        UnrangedInteger,
        {
            { NotUsed },
        },
        { 0 }
    },
    {
        DepthScale,
        "PixelTransfer Depth Scale Factor",
        offset(depthScale),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 1. }
    },
    {
        DepthBias,
        "PixelTransfer Depth Bias Factor",
        offset(depthBias),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 0. }
    },
    {
        RtoRMapSize,
        "PixelMap R to R Size",
        offset(rtorMapSize),
        RangedInteger,
        {
            { 1 },
            { 65536 }
        },
        { 1 }
    },
    {
        GtoGMapSize,
        "PixelMap G to G Size",
        offset(gtogMapSize),
        RangedInteger,
        {
            { 1 },
            { 65536 }
        },
        { 1 }
    },
    {
        BtoBMapSize,
        "PixelMap B to B Size",
        offset(btobMapSize),
        RangedInteger,
        {
            { 1 },
            { 65536 }
        },
        { 1 }
    },
    {
        AtoAMapSize,
        "PixelMap A to A Size",
        offset(atoaMapSize),
        RangedInteger,
        {
            { 1 },
            { 65536 }
        },
        { 1 }
    },
    {
        ItoRMapSize,
        "PixelMap I to R Size",
        offset(itorMapSize),
        RangedInteger,
        {
            { 1 },
            { 65536 }
        },
        { 1 }
    },
    {
        ItoGMapSize,
        "PixelMap I to G Size",
        offset(itogMapSize),
        RangedInteger,
        {
            { 1 },
            { 65536 }
        },
        { 1 }
    },
    {
        ItoBMapSize,
        "PixelMap I to B Size",
        offset(itobMapSize),
        RangedInteger,
        {
            { 1 },
            { 65536 }
        },
        { 1 }
    },
    {
        ItoAMapSize,
        "PixelMap I to A Size",
        offset(itoaMapSize),
        RangedInteger,
        {
            { 1 },
            { 65536 }
        },
        { 1 }
    },
    {
        ItoIMapSize,
        "PixelMap I to I Size",
        offset(itoiMapSize),
        RangedInteger,
        {
            { 1 },
            { 65536 }
        },
        { 1 }
    },
    {
        StoSMapSize,
        "PixelMap S to S Size",
        offset(stosMapSize),
        RangedInteger,
        {
            { 1 },
            { 65536 }
        },
        { 1 }
    },
 #ifdef GL_SGI_color_table
    {
        ColorTable,
        "Color Table Enabled",
        offset(colorTable),
        Enumerated,
        {
            { True,                     "True" },
            { False,                    "False" },
            { End }
        },
        { False }
    },
    {
        ColorTableWidth,
        "Color Table Width",
        offset(colorTableWidth),
        RangedInteger,
        {
            { 1 },
            { 65536 }
        },
        { 256 }
    },
    {
        ColorTableInternalFormat,
        "Color Table Internal Format",
        offset(colorTableInternalFormat),
        Enumerated,
        {
            { 1,		"1" },
            { 2,		"2" },
            { 3,		"3" },
            { 4,		"4" },
            { GL_ALPHA,			"GL_ALPHA" },
            { GL_ALPHA4_EXT,		"GL_ALPHA4_EXT" },
            { GL_ALPHA8_EXT,		"GL_ALPHA8_EXT" },
            { GL_ALPHA12_EXT,		"GL_ALPHA12_EXT" },
            { GL_ALPHA16_EXT,		"GL_ALPHA16_EXT" },
            { GL_LUMINANCE,		"GL_LUMINANCE" },
            { GL_LUMINANCE4_EXT,	"GL_LUMINANCE4_EXT" },
            { GL_LUMINANCE8_EXT,	"GL_LUMINANCE8_EXT" },
            { GL_LUMINANCE12_EXT,	"GL_LUMINANCE12_EXT" },
            { GL_LUMINANCE16_EXT,	"GL_LUMINANCE16_EXT" },
            { GL_LUMINANCE_ALPHA,	"GL_LUMINANCE_ALPHA" },
            { GL_LUMINANCE4_ALPHA4_EXT,	"GL_LUMINANCE4_ALPHA4_EXT" },
            { GL_LUMINANCE6_ALPHA2_EXT,	"GL_LUMINANCE6_ALPHA2_EXT" },
            { GL_LUMINANCE8_ALPHA8_EXT,	"GL_LUMINANCE8_ALPHA8_EXT" },
            { GL_LUMINANCE12_ALPHA4_EXT,"GL_LUMINANCE12_ALPHA4_EXT" },
            { GL_LUMINANCE12_ALPHA12_EXT,"GL_LUMINANCE12_ALPHA12_EXT" },
            { GL_LUMINANCE16_ALPHA16_EXT,"GL_LUMINANCE16_ALPHA16_EXT" },
            { GL_INTENSITY_EXT,		"GL_INTENSITY_EXT" },
            { GL_INTENSITY4_EXT,	"GL_INTENSITY4_EXT" },
            { GL_INTENSITY8_EXT,	"GL_INTENSITY8_EXT" },
            { GL_INTENSITY12_EXT,	"GL_INTENSITY12_EXT" },
            { GL_INTENSITY16_EXT,	"GL_INTENSITY16_EXT" },
            { GL_RGB,			"GL_RGB" },
            { GL_RGB2_EXT,		"GL_RGB2_EXT" },
            { GL_RGB4_EXT,		"GL_RGB4_EXT" },
            { GL_RGB5_EXT,		"GL_RGB5_EXT" },
            { GL_RGB5_A1_EXT,		"GL_RGB5_A1_EXT" },
            { GL_RGB8_EXT,		"GL_RGB8_EXT" },
            { GL_RGB10_EXT,		"GL_RGB10_EXT" },
            { GL_RGB10_A2_EXT,		"GL_RGB10_A2_EXT" },
            { GL_RGB12_EXT,		"GL_RGB12_EXT" },
            { GL_RGB16_EXT,		"GL_RGB16_EXT" },
            { GL_RGBA,			"GL_RGBA" },
            { GL_RGBA2_EXT,		"GL_RGBA2_EXT" },
            { GL_RGBA4_EXT,		"GL_RGBA4_EXT" },
            { GL_RGBA8_EXT,		"GL_RGBA8_EXT" },
            { GL_RGBA12_EXT,		"GL_RGBA12_EXT" },
            { GL_RGBA16_EXT,		"GL_RGBA16_EXT" },
            { End }
        },
        { GL_RGBA8_EXT }
    },
 #endif
 #ifdef GL_EXT_convolution
    {
        ConvolutionTarget,
        "Convolution Target",
        offset(convTarget),
        Enumerated,
        {
            { None,                     "None" },
            { GL_CONVOLUTION_1D_EXT,    "GL_CONVOLUTION_1D_EXT" },
            { GL_CONVOLUTION_2D_EXT,    "GL_CONVOLUTION_2D_EXT" },
            { GL_SEPARABLE_2D_EXT,      "GL_SEPARABLE_2D_EXT" },
            { End }
        },
        { None }
    },
    {
        ConvolutionInternalFormat,
        "Convolution Internal Format",
        offset(convInternalFormat),
        Enumerated,
        {
            { GL_LUMINANCE,             "GL_LUMINANCE" },
            { GL_LUMINANCE_ALPHA,       "GL_LUMINANCE_ALPHA" },
            { GL_INTENSITY_EXT,         "GL_INTENSITY_EXT" },
            { GL_RGB,                   "GL_RGB" },
            { GL_RGBA,                  "GL_RGBA" },
            { End }
        },
        { GL_RGBA }
    },
    {
        ConvolutionWidth,
	"Convolution Width",
        offset(convWidth),
        RangedInteger,
        {
            { 1 },
            { 1024 }
        },
        { 3 }

    },
    {
        ConvolutionHeight,
	"Convolution Height",
        offset(convHeight),
        RangedInteger,
        {
            { 1 },
            { 1024 }
        },
        { 3 }

    },
    {
        ConvolutionRedScale,
        "Convolution Red Scale Factor",
        offset(convRedScale),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 1. }
    },
    {
        ConvolutionRedBias,
        "Convolution Red Bias Factor",
        offset(convRedBias),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 0. }
    },
    {
        ConvolutionGreenScale,
        "Convolution Green Scale Factor",
        offset(convGreenScale),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 1. }
    },
    {
        ConvolutionGreenBias,
        "Convolution Green Bias Factor",
        offset(convGreenBias),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 0. }
    },
    {
        ConvolutionBlueScale,
        "Convolution Blue Scale Factor",
        offset(convBlueScale),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 1. }
    },
    {
        ConvolutionBlueBias,
        "Convolution Blue Bias Factor",
        offset(convBlueBias),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 0. }
    },
    {
        ConvolutionAlphaScale,
        "Convolution Alpha Scale Factor",
        offset(convAlphaScale),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 1. }
    },
    {
        ConvolutionAlphaBias,
        "Convolution Alpha Bias Factor",
        offset(convAlphaBias),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 0. }
    },
 #endif
 #ifdef GL_SGI_color_table
    {
        PostConvolutionColorTable,
        "Post Convolution Color Table Enabled",
        offset(pcColorTable),
        Enumerated,
        {
            { True,                     "True" },
            { False,                    "False" },
            { End }
        },
        { False }
    },
    {
        PostConvolutionColorTableWidth,
        "Post Convolution Color Table Width",
        offset(pcColorTableWidth),
        RangedInteger,
        {
            { 1 },
            { 65536 }
        },
        { 256 }
    },
    {
        PostConvolutionColorTableInternalFormat,
        "Post Convolution Color Table Internal Format",
        offset(pcColorTableInternalFormat),
        Enumerated,
        {
            { 1,		"1" },
            { 2,		"2" },
            { 3,		"3" },
            { 4,		"4" },
            { GL_ALPHA,			"GL_ALPHA" },
            { GL_ALPHA4_EXT,		"GL_ALPHA4_EXT" },
            { GL_ALPHA8_EXT,		"GL_ALPHA8_EXT" },
            { GL_ALPHA12_EXT,		"GL_ALPHA12_EXT" },
            { GL_ALPHA16_EXT,		"GL_ALPHA16_EXT" },
            { GL_LUMINANCE,		"GL_LUMINANCE" },
            { GL_LUMINANCE4_EXT,	"GL_LUMINANCE4_EXT" },
            { GL_LUMINANCE8_EXT,	"GL_LUMINANCE8_EXT" },
            { GL_LUMINANCE12_EXT,	"GL_LUMINANCE12_EXT" },
            { GL_LUMINANCE16_EXT,	"GL_LUMINANCE16_EXT" },
            { GL_LUMINANCE_ALPHA,	"GL_LUMINANCE_ALPHA" },
            { GL_LUMINANCE4_ALPHA4_EXT,	"GL_LUMINANCE4_ALPHA4_EXT" },
            { GL_LUMINANCE6_ALPHA2_EXT,	"GL_LUMINANCE6_ALPHA2_EXT" },
            { GL_LUMINANCE8_ALPHA8_EXT,	"GL_LUMINANCE8_ALPHA8_EXT" },
            { GL_LUMINANCE12_ALPHA4_EXT,"GL_LUMINANCE12_ALPHA4_EXT" },
            { GL_LUMINANCE12_ALPHA12_EXT,"GL_LUMINANCE12_ALPHA12_EXT" },
            { GL_LUMINANCE16_ALPHA16_EXT,"GL_LUMINANCE16_ALPHA16_EXT" },
            { GL_INTENSITY_EXT,		"GL_INTENSITY_EXT" },
            { GL_INTENSITY4_EXT,	"GL_INTENSITY4_EXT" },
            { GL_INTENSITY8_EXT,	"GL_INTENSITY8_EXT" },
            { GL_INTENSITY12_EXT,	"GL_INTENSITY12_EXT" },
            { GL_INTENSITY16_EXT,	"GL_INTENSITY16_EXT" },
            { GL_RGB,			"GL_RGB" },
            { GL_RGB2_EXT,		"GL_RGB2_EXT" },
            { GL_RGB4_EXT,		"GL_RGB4_EXT" },
            { GL_RGB5_EXT,		"GL_RGB5_EXT" },
            { GL_RGB5_A1_EXT,		"GL_RGB5_A1_EXT" },
            { GL_RGB8_EXT,		"GL_RGB8_EXT" },
            { GL_RGB10_EXT,		"GL_RGB10_EXT" },
            { GL_RGB10_A2_EXT,		"GL_RGB10_A2_EXT" },
            { GL_RGB12_EXT,		"GL_RGB12_EXT" },
            { GL_RGB16_EXT,		"GL_RGB16_EXT" },
            { GL_RGBA,			"GL_RGBA" },
            { GL_RGBA2_EXT,		"GL_RGBA2_EXT" },
            { GL_RGBA4_EXT,		"GL_RGBA4_EXT" },
            { GL_RGBA8_EXT,		"GL_RGBA8_EXT" },
            { GL_RGBA12_EXT,		"GL_RGBA12_EXT" },
            { GL_RGBA16_EXT,		"GL_RGBA16_EXT" },
            { End }
        },
        { GL_RGBA8_EXT }
    },
 #endif
 #ifdef GL_SGI_color_matrix
    {
        ColorMatrixRed0,
        "Color Matrix Red 0",
        offset(cmatrixR0),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 1. }
    },
    {
        ColorMatrixRed1,
        "Color Matrix Red 1",
        offset(cmatrixR1),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 0. }
    },
    {
        ColorMatrixRed2,
        "Color Matrix Red 2",
        offset(cmatrixR2),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 0. }
    },
    {
        ColorMatrixRed3,
        "Color Matrix Red 3",
        offset(cmatrixR3),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 0. }
    },
    {
        ColorMatrixGreen0,
        "Color Matrix Green 0",
        offset(cmatrixG0),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 0. }
    },
    {
        ColorMatrixGreen1,
        "Color Matrix Green 1",
        offset(cmatrixG1),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 1. }
    },
    {
        ColorMatrixGreen2,
        "Color Matrix Green 2",
        offset(cmatrixG2),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 0. }
    },
    {
        ColorMatrixGreen3,
        "Color Matrix Green 3",
        offset(cmatrixG3),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 0. }
    },
    {
        ColorMatrixBlue0,
        "Color Matrix Blue 0",
        offset(cmatrixB0),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 0. }
    },
    {
        ColorMatrixBlue1,
        "Color Matrix Blue 1",
        offset(cmatrixB1),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 0. }
    },
    {
        ColorMatrixBlue2,
        "Color Matrix Blue 2",
        offset(cmatrixB2),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 1. }
    },
    {
        ColorMatrixBlue3,
        "Color Matrix Blue 3",
        offset(cmatrixB3),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 0. }
    },
    {
        ColorMatrixAlpha0,
        "Color Matrix Alpha 0",
        offset(cmatrixA0),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 0. }
    },
    {
        ColorMatrixAlpha1,
        "Color Matrix Alpha 1",
        offset(cmatrixA1),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 0. }
    },
    {
        ColorMatrixAlpha2,
        "Color Matrix Alpha 2",
        offset(cmatrixA2),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 0. }
    },
    {
        ColorMatrixAlpha3,
        "Color Matrix Alpha 3",
        offset(cmatrixA3),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 1. }
    },
    {
        ColorMatrixRedScale,
        "Color Matrix Red Scale Factor",
        offset(cmatrixRedScale),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 1. }
    },
    {
        ColorMatrixRedBias,
        "Color Matrix Red Bias Factor",
        offset(cmatrixRedBias),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 0. }
    },
    {
        ColorMatrixGreenScale,
        "Color Matrix Green Scale Factor",
        offset(cmatrixGreenScale),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 1. }
    },
    {
        ColorMatrixGreenBias,
        "Color Matrix Green Bias Factor",
        offset(cmatrixGreenBias),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 0. }
    },
    {
        ColorMatrixBlueScale,
        "Color Matrix Blue Scale Factor",
        offset(cmatrixBlueScale),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 1. }
    },
    {
        ColorMatrixBlueBias,
        "Color Matrix Blue Bias Factor",
        offset(cmatrixBlueBias),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 0. }
    },
    {
        ColorMatrixAlphaScale,
        "Color Matrix Alpha Scale Factor",
        offset(cmatrixAlphaScale),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 1. }
    },
    {
        ColorMatrixAlphaBias,
        "Color Matrix Alpha Bias Factor",
        offset(cmatrixAlphaBias),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 0. }
    },
 #endif
 #ifdef GL_SGI_color_table
    {
        PostColorMatrixColorTable,
        "Post Color Matrix Color Table Enabled",
        offset(pcmColorTable),
        Enumerated,
        {
            { True,                     "True" },
            { False,                    "False" },
            { End }
        },
        { False }
    },
    {
        PostColorMatrixColorTableWidth,
        "Post Color Matrix Color Table Width",
        offset(pcmColorTableWidth),
        RangedInteger,
        {
            { 1 },
            { 65536 }
        },
        { 256 }
    },
    {
        PostColorMatrixColorTableInternalFormat,
        "Post Color Matrix Color Table Internal Format",
        offset(pcmColorTableInternalFormat),
        Enumerated,
        {
            { 1,		"1" },
            { 2,		"2" },
            { 3,		"3" },
            { 4,		"4" },
            { GL_ALPHA,			"GL_ALPHA" },
            { GL_ALPHA4_EXT,		"GL_ALPHA4_EXT" },
            { GL_ALPHA8_EXT,		"GL_ALPHA8_EXT" },
            { GL_ALPHA12_EXT,		"GL_ALPHA12_EXT" },
            { GL_ALPHA16_EXT,		"GL_ALPHA16_EXT" },
            { GL_LUMINANCE,		"GL_LUMINANCE" },
            { GL_LUMINANCE4_EXT,	"GL_LUMINANCE4_EXT" },
            { GL_LUMINANCE8_EXT,	"GL_LUMINANCE8_EXT" },
            { GL_LUMINANCE12_EXT,	"GL_LUMINANCE12_EXT" },
            { GL_LUMINANCE16_EXT,	"GL_LUMINANCE16_EXT" },
            { GL_LUMINANCE_ALPHA,	"GL_LUMINANCE_ALPHA" },
            { GL_LUMINANCE4_ALPHA4_EXT,	"GL_LUMINANCE4_ALPHA4_EXT" },
            { GL_LUMINANCE6_ALPHA2_EXT,	"GL_LUMINANCE6_ALPHA2_EXT" },
            { GL_LUMINANCE8_ALPHA8_EXT,	"GL_LUMINANCE8_ALPHA8_EXT" },
            { GL_LUMINANCE12_ALPHA4_EXT,"GL_LUMINANCE12_ALPHA4_EXT" },
            { GL_LUMINANCE12_ALPHA12_EXT,"GL_LUMINANCE12_ALPHA12_EXT" },
            { GL_LUMINANCE16_ALPHA16_EXT,"GL_LUMINANCE16_ALPHA16_EXT" },
            { GL_INTENSITY_EXT,		"GL_INTENSITY_EXT" },
            { GL_INTENSITY4_EXT,	"GL_INTENSITY4_EXT" },
            { GL_INTENSITY8_EXT,	"GL_INTENSITY8_EXT" },
            { GL_INTENSITY12_EXT,	"GL_INTENSITY12_EXT" },
            { GL_INTENSITY16_EXT,	"GL_INTENSITY16_EXT" },
            { GL_RGB,			"GL_RGB" },
            { GL_RGB2_EXT,		"GL_RGB2_EXT" },
            { GL_RGB4_EXT,		"GL_RGB4_EXT" },
            { GL_RGB5_EXT,		"GL_RGB5_EXT" },
            { GL_RGB5_A1_EXT,		"GL_RGB5_A1_EXT" },
            { GL_RGB8_EXT,		"GL_RGB8_EXT" },
            { GL_RGB10_EXT,		"GL_RGB10_EXT" },
            { GL_RGB10_A2_EXT,		"GL_RGB10_A2_EXT" },
            { GL_RGB12_EXT,		"GL_RGB12_EXT" },
            { GL_RGB16_EXT,		"GL_RGB16_EXT" },
            { GL_RGBA,			"GL_RGBA" },
            { GL_RGBA2_EXT,		"GL_RGBA2_EXT" },
            { GL_RGBA4_EXT,		"GL_RGBA4_EXT" },
            { GL_RGBA8_EXT,		"GL_RGBA8_EXT" },
            { GL_RGBA12_EXT,		"GL_RGBA12_EXT" },
            { GL_RGBA16_EXT,		"GL_RGBA16_EXT" },
            { End }
        },
        { GL_RGBA8_EXT }
    },
 #endif
 #ifdef GL_EXT_histogram
    {
        Histogram,
        "Histogram Enabled",
        offset(histogram),
        Enumerated,
        {
            { True,                     "True" },
            { False,                    "False" },
            { End }
        },
        { False }
    },
    {
        HistogramWidth,
        "Histogram Width",
        offset(histogramWidth),
        RangedInteger,
        {
            { 1 },
            { 65536 }
        },
        { 256 }
    },
    {
        HistogramInternalFormat,
        "Histogram Internal Format",
        offset(histogramInternalFormat),
        Enumerated,
        {
            { GL_ALPHA,			"GL_ALPHA" },
            { GL_ALPHA4_EXT,		"GL_ALPHA4_EXT" },
            { GL_ALPHA8_EXT,		"GL_ALPHA8_EXT" },
            { GL_ALPHA12_EXT,		"GL_ALPHA12_EXT" },
            { GL_ALPHA16_EXT,		"GL_ALPHA16_EXT" },
            { GL_LUMINANCE,		"GL_LUMINANCE" },
            { GL_LUMINANCE4_EXT,	"GL_LUMINANCE4_EXT" },
            { GL_LUMINANCE8_EXT,	"GL_LUMINANCE8_EXT" },
            { GL_LUMINANCE12_EXT,	"GL_LUMINANCE12_EXT" },
            { GL_LUMINANCE16_EXT,	"GL_LUMINANCE16_EXT" },
            { GL_LUMINANCE_ALPHA,	"GL_LUMINANCE_ALPHA" },
            { GL_LUMINANCE4_ALPHA4_EXT,	"GL_LUMINANCE4_ALPHA4_EXT" },
            { GL_LUMINANCE6_ALPHA2_EXT,	"GL_LUMINANCE6_ALPHA2_EXT" },
            { GL_LUMINANCE8_ALPHA8_EXT,	"GL_LUMINANCE8_ALPHA8_EXT" },
            { GL_LUMINANCE12_ALPHA4_EXT,"GL_LUMINANCE12_ALPHA4_EXT" },
            { GL_LUMINANCE12_ALPHA12_EXT,"GL_LUMINANCE12_ALPHA12_EXT" },
            { GL_LUMINANCE16_ALPHA16_EXT,"GL_LUMINANCE16_ALPHA16_EXT" },
            { GL_RGB,			"GL_RGB" },
            { GL_RGB2_EXT,		"GL_RGB2_EXT" },
            { GL_RGB4_EXT,		"GL_RGB4_EXT" },
            { GL_RGB5_EXT,		"GL_RGB5_EXT" },
            { GL_RGB5_A1_EXT,		"GL_RGB5_A1_EXT" },
            { GL_RGB8_EXT,		"GL_RGB8_EXT" },
            { GL_RGB10_EXT,		"GL_RGB10_EXT" },
            { GL_RGB10_A2_EXT,		"GL_RGB10_A2_EXT" },
            { GL_RGB12_EXT,		"GL_RGB12_EXT" },
            { GL_RGB16_EXT,		"GL_RGB16_EXT" },
            { GL_RGBA,			"GL_RGBA" },
            { GL_RGBA2_EXT,		"GL_RGBA2_EXT" },
            { GL_RGBA4_EXT,		"GL_RGBA4_EXT" },
            { GL_RGBA8_EXT,		"GL_RGBA8_EXT" },
            { GL_RGBA12_EXT,		"GL_RGBA12_EXT" },
            { GL_RGBA16_EXT,		"GL_RGBA16_EXT" },
            { End }
        },
        { GL_RGBA8_EXT }
    },
    {
        HistogramSink,
        "Histogram Sink",
        offset(histogramSink),
        Enumerated,
        {
            { True,                     "True" },
            { False,                    "False" },
            { End }
        },
        { False }
    },
    {
        Minmax,
        "Minmax Enabled",
        offset(minmax),
        Enumerated,
        {
            { True,                     "True" },
            { False,                    "False" },
            { End }
        },
        { False }
    },
    {
        MinmaxInternalFormat,
        "Minmax Internal Format",
        offset(minmaxInternalFormat),
        Enumerated,
        {
            { GL_ALPHA,			"GL_ALPHA" },
            { GL_ALPHA4_EXT,		"GL_ALPHA4_EXT" },
            { GL_ALPHA8_EXT,		"GL_ALPHA8_EXT" },
            { GL_ALPHA12_EXT,		"GL_ALPHA12_EXT" },
            { GL_ALPHA16_EXT,		"GL_ALPHA16_EXT" },
            { GL_LUMINANCE,		"GL_LUMINANCE" },
            { GL_LUMINANCE4_EXT,	"GL_LUMINANCE4_EXT" },
            { GL_LUMINANCE8_EXT,	"GL_LUMINANCE8_EXT" },
            { GL_LUMINANCE12_EXT,	"GL_LUMINANCE12_EXT" },
            { GL_LUMINANCE16_EXT,	"GL_LUMINANCE16_EXT" },
            { GL_LUMINANCE_ALPHA,	"GL_LUMINANCE_ALPHA" },
            { GL_LUMINANCE4_ALPHA4_EXT,	"GL_LUMINANCE4_ALPHA4_EXT" },
            { GL_LUMINANCE6_ALPHA2_EXT,	"GL_LUMINANCE6_ALPHA2_EXT" },
            { GL_LUMINANCE8_ALPHA8_EXT,	"GL_LUMINANCE8_ALPHA8_EXT" },
            { GL_LUMINANCE12_ALPHA4_EXT,"GL_LUMINANCE12_ALPHA4_EXT" },
            { GL_LUMINANCE12_ALPHA12_EXT,"GL_LUMINANCE12_ALPHA12_EXT" },
            { GL_LUMINANCE16_ALPHA16_EXT,"GL_LUMINANCE16_ALPHA16_EXT" },
            { GL_RGB,			"GL_RGB" },
            { GL_RGB2_EXT,		"GL_RGB2_EXT" },
            { GL_RGB4_EXT,		"GL_RGB4_EXT" },
            { GL_RGB5_EXT,		"GL_RGB5_EXT" },
            { GL_RGB5_A1_EXT,		"GL_RGB5_A1_EXT" },
            { GL_RGB8_EXT,		"GL_RGB8_EXT" },
            { GL_RGB10_EXT,		"GL_RGB10_EXT" },
            { GL_RGB10_A2_EXT,		"GL_RGB10_A2_EXT" },
            { GL_RGB12_EXT,		"GL_RGB12_EXT" },
            { GL_RGB16_EXT,		"GL_RGB16_EXT" },
            { GL_RGBA,			"GL_RGBA" },
            { GL_RGBA2_EXT,		"GL_RGBA2_EXT" },
            { GL_RGBA4_EXT,		"GL_RGBA4_EXT" },
            { GL_RGBA8_EXT,		"GL_RGBA8_EXT" },
            { GL_RGBA12_EXT,		"GL_RGBA12_EXT" },
            { GL_RGBA16_EXT,		"GL_RGBA16_EXT" },
            { End }
        },
        { GL_RGBA8_EXT }
    },
    {
        MinmaxSink,
        "Minmax Sink",
        offset(minmaxSink),
        Enumerated,
        {
            { True,                     "True" },
            { False,                    "False" },
            { End }
        },
        { False }
    },
 #endif
#else  /* INC_REASON not defined, treat as plain include */
#ifndef _TransMap_h
#define _TransMap_h

#include "General.h"
#include "Print.h"
#include "TestName.h"
#include "PropName.h"
#include "Global.h"
#include "AttrName.h"
#ifdef WIN32
#include <windows.h>
#endif
#include <GL/gl.h>
#include <GL/glu.h>
#include "Random.h"

typedef struct _TransferMap {
#define INC_REASON INFO_ITEM_STRUCT
#include "TransMap.h"
#undef INC_REASON
} TransferMap, *TransferMapPtr;

void new_TransferMap(TransferMapPtr);
void delete_TransferMap(TransferMapPtr);
int TransferMap__SetState(TransferMapPtr);

#endif /* file not already included */
#endif /* INC_REASON not defined */
