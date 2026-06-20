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
#include "Test.h"
    int imageDepth;
    int imageExtent;
    int texImageWidth;
    int texImageHeight;
    int texImageDepth;
    int texImageExtent;
    int texTarget;
    int texComps;
    int texBorder;
    int texLevel;
    int texImageSrc;
    int texMipmap;
    int drawOrder;
    int objDraw;
#ifdef GL_EXT_subtexture
    int subTexWidth;
    int subTexHeight;
    int subTexDepth;
    int subTexExtent;
#endif
#ifdef GL_EXT_copy_texture
    int copyTexWidth;
    int copyTexHeight;
#endif
#ifdef GL_EXT_texture_object
    int residentTexObjs;
#endif
#ifdef GL_SGIS_texture_lod
    int texBaseLevel;
    int texMaxLevel;
#endif
    /* Variables below this line aren't user settable */
    void **imageData;
    int numDrawn;
    int texDim;
    int subImage;
    GLint *subImageData;
    int subTexOrImage;
#ifdef GL_EXT_subtexture
    int subTexture;
    GLint *subTexData;
#endif
#ifdef GL_EXT_copy_texture
    GLint *copyTexData;
#endif
#ifdef GL_EXT_texture_object
    GLuint *texObjs;
#endif
    GLfloat *triangleData;
    int mipmapLevels;
    void*** mipmapData;
    GLint *mipmapDimData;
    GLuint dlBase;
    /* Member functions */
    /* void Initialize(TestPtr); */               /* virtual function */
    /* void Cleanup(TestPtr); */                  /* virtual function */
    /* void Execute(TestPtr);   */                /* virtual function */
    /* int SetState(TestPtr);  */                 /* virtual function */
    /* float PixelSize(TestPtr);  */              /* virtual function */
    /* int TimesRun(TestPtr);  */                 /* virtual function */
    /* void (*SetExecuteFunc)(TestPtr); */        /* virtual function */
    Image image_TexImage;
    TransferMap transfermap_TexImage;
#elif (defined(INC_REASON)) && (INC_REASON == INFO_ITEM_ARRAY)
#include "Test.h"
#undef offset
#define offset(v) offsetof(TexImage,transfermap_TexImage)+offsetof(TransferMap, v)
#include "TransMap.h"
#undef offset
#define offset(v) offsetof(TexImage, image_TexImage)+offsetof(Image, v)
#include "Image.h"
#undef offset
#define offset(v) offsetof(TexImage,v)
#ifdef GL_EXT_texture3D
    {
        ImageDepth,
        "Image Depth",
        offset(imageDepth),
        RangedInteger,
        {
            { 1 },
            { 2048 }
        },
        { 1 }
    },
#endif
#ifdef GL_SGIS_texture4D
    {
        ImageExtent,
        "Image Extent",
        offset(imageExtent),
        RangedInteger,
        {
            { 1 },
            { 2048 }
        },
        { 1 }
    },
#endif
    {
        TexImageTarget,
        "TexImage Target",
        offset(texTarget),
        Enumerated,
        {
            { GL_TEXTURE_1D,		"GL_TEXTURE_1D" },
            { GL_TEXTURE_2D,		"GL_TEXTURE_2D" },
#ifdef GL_SGIS_detail_texture
            { GL_DETAIL_TEXTURE_2D_SGIS,"GL_DETAIL_TEXTURE_2D_SGIS" },
#endif
#ifdef GL_EXT_texture3D
            { GL_TEXTURE_3D_EXT,	"GL_TEXTURE_3D_EXT" },
#endif
#ifdef GL_SGIS_texture4D
            { GL_TEXTURE_4D_SGIS,	"GL_TEXTURE_4D_SGIS" },
#endif
            { End }
        },
        { GL_TEXTURE_2D }
    },
    {
        TexImageWidth,
        "Width of TexImage",
        offset(texImageWidth),
        RangedInteger,
        {
            { 1 },
            { 2048 },
        },
        { -1 }
    },
    {
        TexImageHeight,
        "Height of TexImage",
        offset(texImageHeight),
        RangedInteger,
        {
            { 1 },
            { 2048 },
        },
        { -1 }
    },
#ifdef GL_EXT_texture3D
    {
        TexImageDepth,
        "Depth of TexImage",
        offset(texImageDepth),
        RangedInteger,
        {
            { 1 },
            { 2048 },
        },
        { -1 }
    },
#endif
#ifdef GL_SGIS_texture4D
    {
        TexImageExtent,
        "Extent of TexImage",
        offset(texImageExtent),
        RangedInteger,
        {
            { 1 },
            { 2048 },
        },
        { -1 }
    },
#endif
    {
        TexImageComps,
        "TexImage Ccmponents",
        offset(texComps),
        Enumerated,
        {
            { 1,		"1" },
            { 2,		"2" },
            { 3,		"3" },
            { 4,		"4" },
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
    {
        TexImageBorder,
        "Border of TexImage",
        offset(texBorder),
        RangedInteger,
        {
            { 0 },
#ifdef GL_SGIS_texture_filter4
            { 2 },
#else
            { 1 },
#endif
        },
        { 0 }
    },
#ifdef GL_EXT_subtexture
    {
        SubTexImageWidth,
        "Width of SubTexImage",
        offset(subTexWidth),
        RangedInteger,
        {
            { 1 },
            { 2048 },
        },
        { -1 }
    },
    {
        SubTexImageHeight,
        "Height of SubTexImage",
        offset(subTexHeight),
        RangedInteger,
        {
            { 1 },
            { 2048 },
        },
        { -1 }
    },
 #ifdef GL_EXT_texture3D
    {
        SubTexImageDepth,
        "Depth of SubTexImage",
        offset(subTexDepth),
        RangedInteger,
        {
            { 1 },
            { 2048 },
        },
        { -1 }
    },
 #endif
#endif
#ifdef GL_EXT_texture_object
    {
        ResidentTexObjs,
        "Number of Resident Texture Objects",
        offset(residentTexObjs),
        RangedInteger | NotSettable,
        {
            { 1 },
            { 1024 },
        },
        { -1 }
    },
#endif
    {
        TexImageSrc,
        "Source of Texture Image",
        offset(texImageSrc),
        Enumerated,
        {
            { SystemMemory,                   "SystemMemory" },
            { DisplayList,                    "DisplayList" },
#ifdef GL_EXT_texture_object
            { TexObj,                         "TexObj" },
#endif
#ifdef GL_EXT_copy_texture
            { Framebuffer,                    "Framebuffer" },
#endif
            { End }
        },
        { SystemMemory }
    },
    {
        TexImageLevel,
        "Texture Image Level",
        offset(texLevel),
        RangedInteger,
        {
            { 0 },
            { 31 },
        },
        { 0 }
    },
#ifdef GL_SGIS_texture_lod
    {
        TexImageBaseLevel,
        "Base Texture Image Level",
        offset(texBaseLevel),
        RangedInteger,
        {
            { 0 },
            { 31 },
        },
        { 0 }
    },
    {
        TexImageMaximumLevel,
        "Maximum Texture Image Level",
        offset(texMaxLevel),
        RangedInteger,
        {
            { 0 },
            { 31 },
        },
        { -1 }
    },
#endif
    {
        TexImageMipmap,
        "Method of Calculating Mipmaps",
        offset(texMipmap),
        Enumerated,
        {
            { None,                           "None" },
            { PreCalculate,                   "PreCalculate" },
            { gluBuildMipmap,                 "gluBuildMipmap" },
#ifdef GL_SGIS_generate_mipmap
            { GenerateMipmapExt,              "GenerateMipmapExt" },
#endif
            { End }
        },
        { None }
    },
    {
        ObjDraw,
        "Object Drawn Between TexImage Loads",
        offset(objDraw),
        Enumerated,
        {
            { None,                 "None" },
            { TexturedPoint,        "TexturedPoint" },
            { TexturedTriangle,     "TexturedTriangle" },
            { End }
        },
        { None }
    },
    {
        DrawOrder,
        "Order in which TexImage sections are Drawn",
        offset(drawOrder),
        Enumerated,
        {
            { Serial,			"Serial" },
            { Spaced,			"Spaced" },
            { End }
        },
        { Spaced }
    },
    {
        0
    }

#else  /* INC_REASON not defined, treat as plain include */
#ifndef _Tex_h
#define _Tex_h

#include "RastrPos.h"
#include "Image.h"
#include "TransMap.h"
#include "General.h"
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

typedef struct _TexImage {
#define INC_REASON INFO_ITEM_STRUCT
#include "Tex.h"
#undef INC_REASON
} TexImage, *TexImagePtr;

TexImagePtr new_TexImage();
void delete_TexImage(TestPtr);
void TexImage__AddTraversalData(TexImagePtr);
int TexImage__SetState(TestPtr);
void TexImage__Initialize(TestPtr);
void TexImage__Cleanup(TestPtr);
void TexImage__SetExecuteFunc(TestPtr);
TestPtr TexImage__Copy(TestPtr);
float TexImage__Size(TestPtr);
int TexImage__TimesRun(TestPtr);
void TexImage__CreateImageData(TexImagePtr);

/* These constants are used in the function enumeration scheme */
#define DISPLAY_LIST 0
#define TEXTURE_OBJ 1

#endif /* file not already included */
#endif /* INC_REASON not defined */
