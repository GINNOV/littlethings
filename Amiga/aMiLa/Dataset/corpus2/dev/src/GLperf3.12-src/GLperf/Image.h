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
    int imageWidth;
    int imageHeight;
    int imageFormat;
    int imageType;
    int imageAlignment;
    int imageSwapBytes;
    int imageLSBFirst;
#elif (defined(INC_REASON)) && (INC_REASON == INFO_ITEM_ARRAY)
    {
        ImageFormat,
        "Image Format",
        offset(imageFormat),
        Enumerated,
        {
            { GL_COLOR_INDEX,           "GL_COLOR_INDEX" },
            { GL_STENCIL_INDEX,         "GL_STENCIL_INDEX" },
            { GL_DEPTH_COMPONENT,       "GL_DEPTH_COMPONENT" },
            { GL_RED,                   "GL_RED" },
            { GL_GREEN,                 "GL_GREEN" },
            { GL_BLUE,                  "GL_BLUE" },
            { GL_ALPHA,                 "GL_ALPHA" },
            { GL_LUMINANCE,             "GL_LUMINANCE" },
            { GL_LUMINANCE_ALPHA,       "GL_LUMINANCE_ALPHA" },
            { GL_RGB,                   "GL_RGB" },
            { GL_RGBA,                  "GL_RGBA" },
#ifdef GL_EXT_abgr
            { GL_ABGR_EXT,              "GL_ABGR_EXT" },
#endif
            { End }
        },
        { GL_RGBA }
    },
    {
        ImageType,
        "Image Type",
        offset(imageType),
        Enumerated,
        {
            { GL_BITMAP,                      "GL_BITMAP" },
            { GL_UNSIGNED_BYTE,               "GL_UNSIGNED_BYTE" },
            { GL_BYTE,                        "GL_BYTE" },
            { GL_UNSIGNED_SHORT,              "GL_UNSIGNED_SHORT" },
            { GL_SHORT,                       "GL_SHORT" },
            { GL_UNSIGNED_INT,                "GL_UNSIGNED_INT" },
            { GL_INT,                         "GL_INT" },
            { GL_FLOAT,                       "GL_FLOAT" },
#ifdef GL_EXT_packed_pixels
            { GL_UNSIGNED_BYTE_3_3_2_EXT,     "GL_UNSIGNED_BYTE_3_3_2_EXT" },
            { GL_UNSIGNED_SHORT_4_4_4_4_EXT,  "GL_UNSIGNED_SHORT_4_4_4_4_EXT" },
            { GL_UNSIGNED_SHORT_5_5_5_1_EXT,  "GL_UNSIGNED_SHORT_5_5_5_1_EXT" },
            { GL_UNSIGNED_INT_8_8_8_8_EXT,    "GL_UNSIGNED_INT_8_8_8_8_EXT" },
            { GL_UNSIGNED_INT_10_10_10_2_EXT, "GL_UNSIGNED_INT_10_10_10_2_EXT" },
#endif
            { End }
        },
        { GL_UNSIGNED_BYTE }
    },
    {
        ImageAlignment,
        "Image Alignment",
        offset(imageAlignment),
        Enumerated,
        {
            { 1,                        "1" },
            { 2,                        "2" },
            { 4,                        "4" },
            { 8,                        "8" },
            { End }
        },
        { 4 }
    },
    {
        ImageSwapBytes,
        "Image Swap Bytes",
        offset(imageSwapBytes),
        Enumerated,
        {
            { True,                     "True" },
            { False,                    "False" },
            { End }
        },
        { False }
    },
    {
        ImageLSBFirst,
        "Image LSB First",
        offset(imageLSBFirst),
        Enumerated,
        {
            { True,                     "True" },
            { False,                    "False" },
            { End }
        },
        { False }
    },
    {
        ImageWidth,
        "Image Width",
        offset(imageWidth),
        RangedInteger,
        {
            { 1 },
            { 65536 }
        },
        { 64 }
    },
    {
        ImageHeight,
        "Image Height",
        offset(imageHeight),
        RangedInteger,
        {
            { 1 },
            { 65536 }
        },
        { 64 }
    },
#else  /* INC_REASON not defined, treat as plain include */
#ifndef _Image_h
#define _Image_h

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

typedef struct _Image {
#define INC_REASON INFO_ITEM_STRUCT
#include "Image.h"
#undef INC_REASON
} Image, *ImagePtr;

void new_Image(ImagePtr);
void delete_Image(ImagePtr);
int Image__SetState(ImagePtr);
void* new_ImageData(int width, int height, int format, int type, int alignment, int swapBytes, int lsbFirst, int memAlign, int* size);
GLint* CreateSubImageData(int imageWidth, int imageHeight, int subWidth, int subHeight,
                          float acceptObjs, float rejectObjs, float clipObjs,
                          int clipMode, float percentClip, 
			  int spacedDraw,
			  int memAlignment,
                          int* numDrawn);
void Image__DrawSomething(int rgba, int indexSize, int Double_Buffer);
void* MakeTexImage(int, int, int, int, int, int, int, int, int, int, int*);

#endif /* file not already included */
#endif /* INC_REASON not defined */
