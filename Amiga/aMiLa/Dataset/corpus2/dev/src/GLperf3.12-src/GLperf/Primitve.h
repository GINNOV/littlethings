/*
 *   (C) COPYRIGHT International Business Machines Corp. 1993
 *   All Rights Reserved
 *   Licensed Materials - Property of IBM
 *   US Government Users Restricted Rights - Use, duplication or
 *   disclosure restricted by GSA ADP Schedule Contract with IBM Corp.

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
// Author:  John Spitzer, IBM AWS Graphics Systems (Austin)
//
*/

#if (defined(INC_REASON)) && (INC_REASON == INFO_ITEM_STRUCT)
#include "Drawn.h"
    int projection;     /* Perspective or Parallel                                        */
    int textureData;    /* Can be PerVertex or None                                       */
    int normalData;     /* Can be PerVertex, PerFacet, or None                            */
    int colorData;      /* Can be PerVertex, PerFacet, or None                            */
    int fogMode;        /* Can be Off, GL_LINEAR, GL_EXP, or GL_EXP2                      */
    int alphaTest;      /* Can be Off, GL_NEVER, GL_LESS, GL_EQUAL, GL_LEQUAL,            */
    GLfloat alphaRef;   /* [0.0, 1.0] */
                        /* GL_GREATER, GL_NOTEQUAL, GL_GEQUAL, or GL_ALWAYS               */
    int stencilTest;    /* Can be Off, GL_NEVER, GL_LESS, GL_EQUAL, GL_LEQUAL,            */
                        /* GL_GREATER, GL_NOTEQUAL, GL_GEQUAL, or GL_ALWAYS               */
    int depthMask;      /* On or Off                                                      */
    int depthTest;      /* Can be Off, GL_NEVER, GL_LESS, GL_EQUAL, GL_LEQUAL,            */
                        /* GL_GREATER, GL_NOTEQUAL, GL_GEQUAL, or GL_ALWAYS               */
    int blend;          /* On or Off                                                      */
#if defined(GL_EXT_blend_logic_op) || defined(GL_EXT_blend_minmax) || defined(GL_EXT_blend_subtract)
    int blendEq;        /* Blend Equation extensions                                      */
#endif
    int srcBlend;       /* Can be GL_ZERO,  GL_ONE, GL_DST_COLOR, GL_ONE_MINUS_DST_COLOR, */
                        /* GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_DST_ALPHA,            */
                        /* GL_ONE_MINUS_DST_ALPHA, GL_SRC_ALPHA_SATURATE                  */
    int dstBlend;       /* Can be GL_ZERO,  GL_ONE, GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR, */
                        /* GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_DST_ALPHA,            */
                        /* GL_ONE_MINUS_DST_ALPHA                                         */
    int logicOp;        /* Can be one of a lot of things                                  */
    int texture;        /* Can be Off, GL_TEXTURE_1D, or GL_TEXTURE_2D                    */
    int texWidth;
    int texHeight;
    int texDepth;
    int texExtent;
    int texBorder;
    int texMagFilter;
    int texMinFilter;
    int texWrapS;       /* GL_CLAMP or GL_REPEAT                                          */
    int texWrapT;       /* GL_CLAMP or GL_REPEAT                                          */
#ifdef GL_EXT_texture3D
    int texWrapR;       /* GL_CLAMP or GL_REPEAT                                          */
#endif
#ifdef GL_SGIS_texture4D
    int texWrapQ;       /* GL_CLAMP or GL_REPEAT                                          */
#endif
#ifdef GL_SGIS_detail_texture
    GLint detailLevel;
    GLenum detailMode;
    int detailWidth;
    int detailHeight;
#endif
    int texComps;       /* [1,4]                                                          */
#ifdef GL_SGIX_texture_scale_bias
    /* YOU CANNOT rearrange these next eight members! */
    GLfloat texRedScale;
    GLfloat texGreenScale;
    GLfloat texBlueScale;
    GLfloat texAlphaScale;
    GLfloat texRedBias;
    GLfloat texGreenBias;
    GLfloat texBlueBias;
    GLfloat texAlphaBias;
#endif
#ifdef GL_SGI_texture_color_table
    int texColorTable;
    int texColorTableWidth;
    int texColorTableInternalFormat;
#endif
#ifdef GL_SGIS_texture_select
    int texSelect;
#endif
    int texFunc;        /* GL_MODULATE, GL_BLEND, or GL_DECAL                             */
    int texGen;         /* Can be Off, GL_SPHERE_MAP, GL_OBJECT_LINEAR, or GL_EYE_LINEAR  */
    GLfloat texLOD;/* scales texture over coordinates                                */
                        /*          OR       numBgnEnds * facetsPerBgnEnd * vertsPerFacet */
    float acceptObjs;   /* [0.0,1.0] acceptObjs + rejectObjs + clipObjs = 1.0              */
    float rejectObjs;   /* [0.0,1.0]                                                      */
    float clipObjs;      /* [0.0,1.0]                                                      */
    int colorDim;       /* Dimension of color data (i.e. RGB or RGBA) [3, 4] */
    int zOrder;       /* Coplanar, Random, FrontToBack, BackToFront */
#ifdef GL_SGIS_multisample
    int multisample;
#endif
    int texDim;
    GLfloat* traversalData;
    /* void Execute(TestPtr);   */                /* virtual function */
    /* int SetState(TestPtr);  */                 /* virtual function */
    /* void (*SetExecuteFunc)(TestPtr); */        /* virtual function */
#elif (defined(INC_REASON)) && (INC_REASON == INFO_ITEM_ARRAY)
#include "Drawn.h"
    {
        ColorDim,
        "Dimension of Color Data",
        offset(colorDim),
        RangedInteger,
        {
            { 3 },
#ifdef FULL_COLOR_PATHS
	    { 4 },
#else
            { 3 },
#endif
        },
        { 3 }
    },
    {
        Projection,
        "Projection Matrix Type",
        offset(projection),
        Enumerated,
        {
            { Parallel,         "Parallel" },
            { Perspective,      "Perspective" },
            { End }
        },
        { Perspective }
    },
    {
        AcceptObjs,
        "Fraction of Primitives Trivially Accepted",
        offset(acceptObjs),
        RangedFloat,
        {
            { 0.0 },
            { 1.0 }
        },
        { NotUsed, 1.0 }
    },
    {
        RejectObjs,
        "Fraction of Primitives Trivially Rejected",
        offset(rejectObjs),
        RangedFloat,
        {
            { 0.0 },
            { 1.0 }
        },
        { NotUsed, 0.0 }
    },
    {
        ClipObjs,
        "Fraction of Primitives Clipped",
        offset(clipObjs),
        RangedFloat,
        {
            { 0.0 },
            { 1.0 }
        },
        { NotUsed, 0.0 }
    },
    {
        DepthOrder,
        "Vertex/RasterPos Depth Ordering",
        offset(zOrder),
        Enumerated,
        {
            { Coplanar,                 "Coplanar" },
            { Random,                   "Random" },
            { BackToFront,              "BackToFront" },
            { FrontToBack,              "FrontToBack" },
            { End }
        },
        { Coplanar }
    },
    {
        TexGen,
        "Texture Generation",
        offset(texGen),
        Enumerated,
        {
            { Off,                      "Off" },
            { GL_SPHERE_MAP,            "GL_SPHERE_MAP" },
            { GL_EYE_LINEAR,            "GL_EYE_LINEAR" },
            { GL_OBJECT_LINEAR,         "GL_OBJECT_LINEAR" },
            { End }
        },
        { Off }
    },
    {
        TexTarget,
        "Texture Target",
        offset(texture),
        Enumerated,
        {
            { Off,                      "Off" },
#ifdef FULL_TEXTURE_PATHS
            { GL_TEXTURE_1D,            "GL_TEXTURE_1D" },
#endif
            { GL_TEXTURE_2D,            "GL_TEXTURE_2D" },
#if defined(FULL_TEXTURE_PATHS) && defined(GL_EXT_texture3D)
            { GL_TEXTURE_3D_EXT,        "GL_TEXTURE_3D_EXT" },
#endif
            { End }
        },
        { Off }
    },
    {
        TexWidth,
        "Texture Width",
        offset(texWidth),
        RangedInteger,
        {
            { 1 },
            { 65536 }
        },
        { 64 }
    },
    {
        TexHeight,
        "Texture Height",
        offset(texHeight),
        RangedInteger,
        {
            { 1 },
            { 65536 }
        },
        { 64 }
    },
#ifdef GL_EXT_texture3D
    {
        TexDepth,
        "Texture Depth",
        offset(texDepth),
        RangedInteger,
        {
            { 1 },
            { 65536 }
        },
        { 64 }
    },
#endif
#ifdef GL_SGIS_texture4D
    {
        TexExtent,
        "Texture Extent",
        offset(texExtent),
        RangedInteger,
        {
            { 1 },
            { 65536 }
        },
        { 1 }
    },
#endif
    {
        TexBorder,
        "Texture Border",
        offset(texBorder),
        RangedInteger,
        {
            { 0 },
#ifdef GL_SGIS_texture_filter4
            { 2 },
#else
            { 1 }
#endif
        },
        { 0 }
    },
    {
        TexComps,
        "Internal Texture Components",
        offset(texComps),
        Enumerated,
        {
            { 1,			"1" },
            { 2,			"2" },
            { 3,			"3" },
            { 4,			"4" },
#ifdef GL_EXT_texture
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
#endif
#ifdef GL_SGIS_texture_select
            { GL_DUAL_ALPHA4_SGIS,		"GL_DUAL_ALPHA4_SGIS" },
            { GL_DUAL_ALPHA8_SGIS,		"GL_DUAL_ALPHA8_SGIS" },
            { GL_DUAL_ALPHA12_SGIS,		"GL_DUAL_ALPHA12_SGIS" },
            { GL_DUAL_ALPHA16_SGIS,		"GL_DUAL_ALPHA16_SGIS" },
            { GL_DUAL_LUMINANCE4_SGIS,		"GL_DUAL_LUMINANCE4_SGIS" },
            { GL_DUAL_LUMINANCE8_SGIS,		"GL_DUAL_LUMINANCE8_SGIS" },
            { GL_DUAL_LUMINANCE12_SGIS,		"GL_DUAL_LUMINANCE12_SGIS" },
            { GL_DUAL_LUMINANCE16_SGIS,		"GL_DUAL_LUMINANCE16_SGIS" },
            { GL_DUAL_INTENSITY4_SGIS,		"GL_DUAL_INTENSITY4_SGIS" },
            { GL_DUAL_INTENSITY8_SGIS,		"GL_DUAL_INTENSITY8_SGIS" },
            { GL_DUAL_INTENSITY12_SGIS,		"GL_DUAL_INTENSITY12_SGIS" },
            { GL_DUAL_INTENSITY16_SGIS,		"GL_DUAL_INTENSITY16_SGIS" },
            { GL_DUAL_LUMINANCE_ALPHA4_SGIS,	"GL_DUAL_LUMINANCE_ALPHA4_SGIS" },
            { GL_DUAL_LUMINANCE_ALPHA8_SGIS,	"GL_DUAL_LUMINANCE_ALPHA8_SGIS" },
            { GL_QUAD_ALPHA4_SGIS,		"GL_QUAD_ALPHA4_SGIS" },
            { GL_QUAD_ALPHA8_SGIS,		"GL_QUAD_ALPHA8_SGIS" },
            { GL_QUAD_LUMINANCE4_SGIS,		"GL_QUAD_LUMINANCE4_SGIS" },
            { GL_QUAD_LUMINANCE8_SGIS,		"GL_QUAD_LUMINANCE8_SGIS" },
            { GL_QUAD_INTENSITY4_SGIS,		"GL_QUAD_INTENSITY4_SGIS" },
            { GL_QUAD_INTENSITY8_SGIS,		"GL_QUAD_INTENSITY8_SGIS" },
#endif
            { End }
        },
        { 3 }
    },
#ifdef GL_SGIS_texture_select
    {
        TexCompSelect,
        "Texture Component Selected",
        offset(texSelect),
        RangedInteger,
        {
            { 0 },
            { 3 }
        },
        { 0 }
    },
#endif
    {
        TexLOD,
        "Texture Level Of Detail",
        offset(texLOD),
        RangedFloatOrInt,
        {
            { -32. },
            {  32. }
        },
        { NotUsed, 0. }
    },
    {
        TexMagFilter,
        "Texture Magnification Filter",
        offset(texMagFilter),
        Enumerated,
        {
            { GL_NEAREST,                "GL_NEAREST" },
            { GL_LINEAR,                 "GL_LINEAR" },
#ifdef GL_SGIS_texture_filter4
            { GL_FILTER4_SGIS,           "GL_FILTER4_SGIS" },
#endif
#ifdef GL_SGIS_detail_texture
            { GL_LINEAR_DETAIL_SGIS,     "GL_LINEAR_DETAIL_SGIS" },
            { GL_LINEAR_DETAIL_ALPHA_SGIS, "GL_LINEAR_DETAIL_ALPHA_SGIS" },
            { GL_LINEAR_DETAIL_COLOR_SGIS, "GL_LINEAR_DETAIL_COLOR_SGIS" },
#endif
#ifdef GL_SGIS_sharpen_texture
            { GL_LINEAR_SHARPEN_SGIS,    "GL_LINEAR_SHARPEN_SGIS" },
            { GL_LINEAR_SHARPEN_ALPHA_SGIS, "GL_LINEAR_SHARPEN_ALPHA_SGIS" },
            { GL_LINEAR_SHARPEN_COLOR_SGIS, "GL_LINEAR_SHARPEN_COLOR_SGIS" },
#endif
            { End }
        },
        { GL_NEAREST }
    },
    {
        TexMinFilter,
        "Texture Minification Filter",
        offset(texMinFilter),
        Enumerated,
        {
            { GL_NEAREST,                "GL_NEAREST" },
            { GL_LINEAR,                 "GL_LINEAR" },
#ifdef GL_SGIS_texture_filter4
            { GL_FILTER4_SGIS,           "GL_FILTER4_SGIS" },
#endif
            { GL_NEAREST_MIPMAP_NEAREST, "GL_NEAREST_MIPMAP_NEAREST" },
            { GL_NEAREST_MIPMAP_LINEAR,  "GL_NEAREST_MIPMAP_LINEAR" },
            { GL_LINEAR_MIPMAP_NEAREST,  "GL_LINEAR_MIPMAP_NEAREST" },
            { GL_LINEAR_MIPMAP_LINEAR,   "GL_LINEAR_MIPMAP_LINEAR" },
            { End }
        },
        { GL_NEAREST }
    },
    {
        TexWrapS,
        "Texture Wrap S",
        offset(texWrapS),
        Enumerated,
        {
            { GL_CLAMP,                  "GL_CLAMP" },
            { GL_REPEAT,                 "GL_REPEAT" },
#ifdef GL_SGIS_texture_border_clamp
            { GL_CLAMP_TO_BORDER_SGIS,   "GL_CLAMP_TO_BORDER_SGIS" },
#endif
#ifdef GL_SGIS_texture_edge_clamp
            { GL_CLAMP_TO_EDGE_SGIS,     "GL_CLAMP_TO_EDGE_SGIS" },
#endif
            { End }
        },
        { GL_REPEAT }
    },
    {
        TexWrapT,
        "Texture Wrap T",
        offset(texWrapT),
        Enumerated,
        {
            { GL_CLAMP,                  "GL_CLAMP" },
            { GL_REPEAT,                 "GL_REPEAT" },
#ifdef GL_SGIS_texture_border_clamp
            { GL_CLAMP_TO_BORDER_SGIS,   "GL_CLAMP_TO_BORDER_SGIS" },
#endif
#ifdef GL_SGIS_texture_edge_clamp
            { GL_CLAMP_TO_EDGE_SGIS,     "GL_CLAMP_TO_EDGE_SGIS" },
#endif
            { End }
        },
        { GL_REPEAT }
    },
#ifdef GL_EXT_texture3D
    {
        TexWrapR,
        "Texture Wrap R",
        offset(texWrapR),
        Enumerated,
        {
            { GL_CLAMP,                  "GL_CLAMP" },
            { GL_REPEAT,                 "GL_REPEAT" },
 #ifdef GL_SGIS_texture_border_clamp
            { GL_CLAMP_TO_BORDER_SGIS,   "GL_CLAMP_TO_BORDER_SGIS" },
 #endif
 #ifdef GL_SGIS_texture_edge_clamp
            { GL_CLAMP_TO_EDGE_SGIS,     "GL_CLAMP_TO_EDGE_SGIS" },
 #endif
            { End }
        },
        { GL_REPEAT }
    },
#endif
#ifdef GL_SGIS_texture4D
    {
        TexWrapQ,
        "Texture Wrap Q",
        offset(texWrapQ),
        Enumerated,
        {
            { GL_CLAMP,                  "GL_CLAMP" },
            { GL_REPEAT,                 "GL_REPEAT" },
 #ifdef GL_SGIS_texture_border_clamp
            { GL_CLAMP_TO_BORDER_SGIS,   "GL_CLAMP_TO_BORDER_SGIS" },
 #endif
 #ifdef GL_SGIS_texture_edge_clamp
            { GL_CLAMP_TO_EDGE_SGIS,     "GL_CLAMP_TO_EDGE_SGIS" },
 #endif
            { End }
        },
        { GL_REPEAT }
    },
#endif
#ifdef GL_SGIX_texture_scale_bias
    {
        PostTexFilterRedScale,
        "Post Texture Filter Red Scale Factor",
        offset(texRedScale),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 1. }
    },
    {
        PostTexFilterRedBias,
        "Post Texture Filter Red Bias Factor",
        offset(texRedBias),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 0. }
    },
    {
        PostTexFilterGreenScale,
        "Post Texture Filter Green Scale Factor",
        offset(texGreenScale),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 1. }
    },
    {
        PostTexFilterGreenBias,
        "Post Texture Filter Green Bias Factor",
        offset(texGreenBias),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 0. }
    },
    {
        PostTexFilterBlueScale,
        "Post Texture Filter Blue Scale Factor",
        offset(texBlueScale),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 1. }
    },
    {
        PostTexFilterBlueBias,
        "Post Texture Filter Blue Bias Factor",
        offset(texBlueBias),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 0. }
    },
    {
        PostTexFilterAlphaScale,
        "Post Texture Filter Alpha Scale Factor",
        offset(texAlphaScale),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 1. }
    },
    {
        PostTexFilterAlphaBias,
        "Post Texture Filter Alpha Bias Factor",
        offset(texAlphaBias),
        UnrangedFloatOrInt,
        {
            { NotUsed }
        },
        { NotUsed, 0. }
    },
#endif
#ifdef GL_SGI_texture_color_table
    {
        TexColorTable,
        "Texture Color Table Enabled",
        offset(texColorTable),
        Enumerated,
        {
            { True,                     "True" },
            { False,                    "False" },
            { End }
        },
        { False }
    },
    {
        TexColorTableWidth,
        "Texture Color Table Width",
        offset(texColorTableWidth),
        RangedInteger,
        {
            { 1 },
            { 65536 }
        },
        { 256 }
    },
    {
        TexColorTableInternalFormat,
        "Texture Color Table Internal Format",
        offset(texColorTableInternalFormat),
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
    {
        TexFunc,
        "Texture Function",
        offset(texFunc),
        Enumerated,
        {
            { GL_MODULATE,              "GL_MODULATE" },
            { GL_BLEND,                 "GL_BLEND" },
            { GL_DECAL,                 "GL_DECAL" },
#ifdef GL_EXT_texture
            { GL_REPLACE_EXT,           "GL_REPLACE_EXT" },
#endif
            { End }
        },
        { GL_DECAL }
    },
#ifdef GL_SGIS_detail_texture
    {
        TexDetailWidth,
        "Detail Texture Width",
        offset(detailWidth),
        RangedInteger,
        {
            { 1 },
            { 1024 }
        },
        { 256 }
    },
    {
        TexDetailHeight,
        "Detail Texture Height",
        offset(detailHeight),
        RangedInteger,
        {
            { 1 },
            { 1024 }
        },
        { 256 }
    },
    {
        TexDetailLevel,
        "Detail Texture Level",
        offset(detailLevel),
        RangedInteger,
        {
            { 0 },
            { 1024 }
        },
        { 4 }
    },
    {
        TexDetailMode,
        "Detail Texture Mode",
        offset(detailMode),
        Enumerated,
        {
            { GL_MODULATE,               "GL_MODULATE" },
            { GL_ADD,                    "GL_ADD" },
            { End }
        },
        { GL_ADD }
    },
#endif
    {
        Fog,
        "Fogging Mode",
        offset(fogMode),
        Enumerated,
        {
            { Off,              "Off" },
            { GL_LINEAR,        "GL_LINEAR" },
            { GL_EXP,           "GL_EXP" },
            { GL_EXP2,          "GL_EXP2" },
            { End }
        },
        { Off }
    },
    {
        AlphaTest,
        "Alpha Test Function",
        offset(alphaTest),
        Enumerated,
        {
            { Off,                      "Off" },
            { GL_NEVER,                 "GL_NEVER" },
            { GL_LESS,                  "GL_LESS" },
            { GL_EQUAL,                 "GL_EQUAL" },
            { GL_LEQUAL,                "GL_LEQUAL" },
            { GL_GREATER,               "GL_GREATER" },
            { GL_NOTEQUAL,              "GL_NOTEQUAL" },
            { GL_GEQUAL,                "GL_GEQUAL" },
            { GL_ALWAYS,                "GL_ALWAYS" },
            { End }
        },
        { Off }
    },
    {
        AlphaRef,
        "Alpha Reference Value",
        offset(alphaRef),
        RangedFloat,
        {
	   { 0.0 },
	   { 1.0 }
        },
        { NotUsed, 0.0 }
    },
    {
        StencilTest,
        "Stencil Test Function",
        offset(stencilTest),
        Enumerated,
        {
            { Off,                      "Off" },
            { GL_NEVER,                 "GL_NEVER" },
            { GL_LESS,                  "GL_LESS" },
            { GL_EQUAL,                 "GL_EQUAL" },
            { GL_LEQUAL,                "GL_LEQUAL" },
            { GL_GREATER,               "GL_GREATER" },
            { GL_NOTEQUAL,              "GL_NOTEQUAL" },
            { GL_GEQUAL,                "GL_GEQUAL" },
            { GL_ALWAYS,                "GL_ALWAYS" },
            { End }
        },
        { Off }
    },
    {
        DepthTest,
        "Depth Test Function",
        offset(depthTest),
        Enumerated,
        {
            { Off,                      "Off" },
            { GL_NEVER,                 "GL_NEVER" },
            { GL_LESS,                  "GL_LESS" },
            { GL_EQUAL,                 "GL_EQUAL" },
            { GL_LEQUAL,                "GL_LEQUAL" },
            { GL_GREATER,               "GL_GREATER" },
            { GL_NOTEQUAL,              "GL_NOTEQUAL" },
            { GL_GEQUAL,                "GL_GEQUAL" },
            { GL_ALWAYS,                "GL_ALWAYS" },
            { End }
        },
        { Off }
    },
    {
        DepthMask,
        "Depth Mask",
        offset(depthMask),
        Enumerated,
        {
            { Off,                      "Off" },
            { On,                       "On" },
            { End }
        },
        { On }
    },
    {
        Blend,
        "Blend Enabled",
        offset(blend),
        Enumerated,
        {
            { Off,                      "Off" },
            { On,                       "On" },
            { End }
        },
        { Off }
    },
#if defined(GL_EXT_blend_logic_op) || defined(GL_EXT_blend_minmax) || defined(GL_EXT_blend_subtract)
    {
        BlendEquation,
        "Blend Equation",
        offset(blendEq),
        Enumerated,
        {
            { GL_FUNC_ADD_EXT,          "GL_FUNC_ADD_EXT" },
 #ifdef GL_EXT_blend_logic_op
            { GL_LOGIC_OP,              "GL_LOGIC_OP" },
 #endif
 #ifdef GL_EXT_blend_minmax
            { GL_MIN_EXT,               "GL_MIN_EXT" },
            { GL_MAX_EXT,               "GL_MAX_EXT" },
 #endif
 #ifdef GL_EXT_blend_subtract
            { GL_FUNC_SUBTRACT_EXT,     "GL_FUNC_SUBTRACT_EXT" },
            { GL_FUNC_REVERSE_SUBTRACT_EXT, "GL_FUNC_REVERSE_SUBTRACT_EXT" },
 #endif
            { End }
        },
        { GL_FUNC_ADD_EXT }
    },
#endif
    {
        SrcBlendFunc,
        "Source Blend Function",
        offset(srcBlend),
        Enumerated,
        {
            { GL_ZERO,                  "GL_ZERO" },
            { GL_ONE,                   "GL_ONE" },
            { GL_DST_COLOR,             "GL_DST_COLOR" },
            { GL_ONE_MINUS_DST_COLOR,   "GL_ONE_MINUS_DST_COLOR" },
            { GL_SRC_ALPHA,             "GL_SRC_ALPHA" },
            { GL_ONE_MINUS_SRC_ALPHA,   "GL_ONE_MINUS_SRC_ALPHA" },
            { GL_DST_ALPHA,             "GL_DST_ALPHA" },
            { GL_ONE_MINUS_DST_ALPHA,   "GL_ONE_MINUS_DST_ALPHA" },
            { GL_SRC_ALPHA_SATURATE,    "GL_SRC_ALPHA_SATURATE" },
#ifdef GL_EXT_blend_color
            { GL_CONSTANT_COLOR_EXT,    "GL_CONSTANT_COLOR_EXT" },
            { GL_ONE_MINUS_CONSTANT_COLOR_EXT, "GL_ONE_MINUS_CONSTANT_COLOR_EXT" },
            { GL_CONSTANT_ALPHA_EXT,    "GL_CONSTANT_ALPHA_EXT" },
            { GL_ONE_MINUS_CONSTANT_ALPHA_EXT, "GL_ONE_MINUS_CONSTANT_ALPHA_EXT" },
#endif
            { End }
        },
        { GL_ONE }
    },
    {
        DstBlendFunc,
        "Destination Blend Function",
        offset(dstBlend),
        Enumerated,
        {
            { GL_ZERO,                  "GL_ZERO" },
            { GL_ONE,                   "GL_ONE" },
            { GL_SRC_COLOR,             "GL_SRC_COLOR" },
            { GL_ONE_MINUS_SRC_COLOR,   "GL_ONE_MINUS_SRC_COLOR" },
            { GL_SRC_ALPHA,             "GL_SRC_ALPHA" },
            { GL_ONE_MINUS_SRC_ALPHA,   "GL_ONE_MINUS_SRC_ALPHA" },
            { GL_DST_ALPHA,             "GL_DST_ALPHA" },
            { GL_ONE_MINUS_DST_ALPHA,   "GL_ONE_MINUS_DST_ALPHA" },
#ifdef GL_EXT_blend_color
            { GL_CONSTANT_COLOR_EXT,    "GL_CONSTANT_COLOR_EXT" },
            { GL_ONE_MINUS_CONSTANT_COLOR_EXT, "GL_ONE_MINUS_CONSTANT_COLOR_EXT" },
            { GL_CONSTANT_ALPHA_EXT,    "GL_CONSTANT_ALPHA_EXT" },
            { GL_ONE_MINUS_CONSTANT_ALPHA_EXT, "GL_ONE_MINUS_CONSTANT_ALPHA_EXT" },
#endif
            { End }
        },
        { GL_ONE }
    },
    {
        LogicOp,
        "Logical Operation",
        offset(logicOp),
        Enumerated,
        {
            { Off,              "Off" },
            { GL_AND,           "GL_AND" },
            { GL_AND_INVERTED,  "GL_AND_INVERTED" },
            { GL_AND_REVERSE,   "GL_AND_REVERSE" },
            { GL_CLEAR,         "GL_CLEAR" },
            { GL_COPY,          "GL_COPY" },
            { GL_COPY_INVERTED, "GL_COPY_INVERTED" },
            { GL_EQUIV,         "GL_EQUIV" },
            { GL_INVERT,        "GL_INVERT" },
            { GL_NAND,          "GL_NAND" },
            { GL_NOOP,          "GL_NOOP" },
            { GL_NOR,           "GL_NOR" },
            { GL_OR,            "GL_OR" },
            { GL_OR_INVERTED,   "GL_OR_INVERTED" },
            { GL_OR_REVERSE,    "GL_OR_REVERSE" },
            { GL_SET,           "GL_SET" },
            { GL_XOR,           "GL_XOR" },
            { End }
        },
        { Off }
    },
#ifdef GL_SGIS_multisample
    {
        Multisample,
        "Multisample Antialiasing",
        offset(multisample),
        Enumerated,
        {
            { Off,              "Off" },
            { On,           	"On" },
            { End }
        },
        { Off }
    },
#endif

#else  /* INC_REASON not defined, treat as plain include */
#ifndef _Primitve_h
#define _Primitve_h

#include "Drawn.h"
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
#include "FuncEnum.h"

typedef struct _Primitive {
#define INC_REASON INFO_ITEM_STRUCT
#include "Primitve.h"
#undef INC_REASON
} Primitive, *PrimitivePtr;

void new_Primitive(PrimitivePtr);
void delete_Primitive(TestPtr);
void Primitive__SetProjection(PrimitivePtr, int);
int Primitive__SetState(TestPtr);
void CalcRGBColor(GLfloat, GLfloat*, GLfloat*, GLfloat*);
void AddColorRGBData(GLfloat*, GLfloat, GLfloat, GLfloat);
void AddColorRGBAData(GLfloat*, GLfloat, GLfloat, GLfloat);
void AddColorCIData(GLfloat*, GLfloat, GLfloat, int, int);
#ifdef GL_SGI_array_formats
void AddColorCIDataUI(GLfloat*, GLfloat, GLfloat, int, int);
#endif
void AddTexture1DData(GLfloat*, GLfloat, GLfloat, GLfloat);
void AddTexture2DData(GLfloat*, GLfloat, GLfloat, GLfloat, GLfloat);
void AddTexture3DData(GLfloat*, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat);

/* These constants are used in the function enumeration scheme */
#define NONE 0
#define PER_VERTEX 1
#define PER_FACET 2
#define CI 0
#define RGB 1

#endif /* file not already included */
#endif /* INC_REASON not defined */
