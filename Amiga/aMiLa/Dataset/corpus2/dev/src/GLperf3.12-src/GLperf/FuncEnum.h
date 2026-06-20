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
#ifndef _FuncEnum_h
#define _FuncEnum_h

#undef	LITTLE_ENDIAN
#if defined(DEC) || defined( __IBMC__) || defined(WIN32)
#define LITTLE_ENDIAN
#endif

typedef union _TransformFunc {
  struct _transformBits {
#ifdef LITTLE_ENDIAN
    unsigned int unrollAmount  : 3;
    unsigned int functionPtrs  : 1;
    unsigned int pointDraw     : 1;
    unsigned int pushPop       : 1;
    unsigned int transform     : 3;
    unsigned int unused        :23;
#else
    unsigned int unused        :23;
    unsigned int transform     : 3;
    unsigned int pushPop       : 1;
    unsigned int pointDraw     : 1;
    unsigned int functionPtrs  : 1;
    unsigned int unrollAmount  : 3;
#endif
  } bits;
  unsigned int word;
} TransformFunc;

typedef union _ClearFunc {
  struct _clearBits {
#ifdef LITTLE_ENDIAN
    unsigned int unrollAmount  : 3;
    unsigned int functionPtrs  : 1;
    unsigned int pointDraw     : 1;
    unsigned int unused        :27;
#else
    unsigned int unused        :27;
    unsigned int pointDraw     : 1;
    unsigned int functionPtrs  : 1;
    unsigned int unrollAmount  : 3;
#endif
  } bits;
  unsigned int word;
} ClearFunc;

#if ((defined(GL_EXT_texture3D) || defined(GL_SGIS_texture4D)) && defined (FULL_TEXTURE_PATHS))
    #define TEXTURE_DIM_BITS 2
    #define REMAINING_BITS   19
#else
    #define TEXTURE_DIM_BITS 1
    #define REMAINING_BITS   20
#endif

typedef union _VertexFunc {
  struct _vertexBits {
#ifdef LITTLE_ENDIAN
    unsigned int unrollAmount  : 3;
    unsigned int colorDim      : 1;
    unsigned int textureDim    : TEXTURE_DIM_BITS;
    unsigned int textureData   : 1;
    unsigned int vertexDim     : 1;
    unsigned int functionPtrs  : 1;
    unsigned int vertsPerFacet : 4;
    unsigned int unused        : REMAINING_BITS;
#else
    unsigned int unused        : REMAINING_BITS;
    unsigned int vertsPerFacet : 4;
    unsigned int functionPtrs  : 1;
    unsigned int vertexDim     : 1;
    unsigned int textureData   : 1;
    unsigned int textureDim    : TEXTURE_DIM_BITS;
    unsigned int colorDim      : 1;
    unsigned int unrollAmount  : 3;
#endif
  } bits;
  unsigned int word;
} VertexFunc;

typedef union _VertexFile {
  struct _vertexFileBits {
#ifdef LITTLE_ENDIAN
    unsigned int visual        : 1;
    unsigned int colorData     : 2;
    unsigned int normalData    : 2;
    unsigned int unused        : 27;
#else
    unsigned int unused        : 27;
    unsigned int normalData    : 2;
    unsigned int colorData     : 2;
    unsigned int visual        : 1;
#endif
  } bits;
  unsigned int word;
} VertexFile;

typedef union _VertexArrayFunc {
  struct _vertexArrayBits {
#ifdef LITTLE_ENDIAN
    unsigned int colorData     : 1;
    unsigned int indexData     : 1;
    unsigned int normalData    : 1;
    unsigned int textureData   : 1;
    unsigned int functionPtrs  : 1;
    unsigned int unused        : 27;
#else
    unsigned int unused        : 27;
    unsigned int functionPtrs  : 1;
    unsigned int textureData   : 1;
    unsigned int normalData    : 1;
    unsigned int indexData     : 1;
    unsigned int colorData     : 1;
#endif
  } bits;
  unsigned int word;
} VertexArrayFunc;

typedef union _VertexArray11Func {
  struct _vertexArray11Bits {
#ifdef LITTLE_ENDIAN
    unsigned int colorData     : 1;
    unsigned int indexData     : 1;
    unsigned int normalData    : 1;
    unsigned int textureData   : 1;
    unsigned int functionPtrs  : 1;
    unsigned int drawElements  : 1;
    unsigned int interleaved   : 1;
    unsigned int lockArrays    : 1;
    unsigned int unused        : 24;
#else
    unsigned int unused        : 24;
    unsigned int lockArrays    : 1;
    unsigned int interleaved   : 1;
    unsigned int drawElements  : 1;
    unsigned int functionPtrs  : 1;
    unsigned int textureData   : 1;
    unsigned int normalData    : 1;
    unsigned int indexData     : 1;
    unsigned int colorData     : 1;
#endif
  } bits;
  unsigned int word;
} VertexArray11Func;

typedef union _DrawPixelsFunc {
  struct _drawPixelsBits {
#ifdef LITTLE_ENDIAN
    unsigned int rasterPosDim  : 1;
    unsigned int functionPtrs  : 1;
    unsigned int subimage      : 1;
    unsigned int multiimage    : 1;
    unsigned int unused        :28;
#else
    unsigned int unused        :28;
    unsigned int multiimage    : 1;
    unsigned int subimage      : 1;
    unsigned int functionPtrs  : 1;
    unsigned int rasterPosDim  : 1;
#endif
  } bits;
  unsigned int word;
} DrawPixelsFunc;

typedef union _ReadPixelsFunc {
  struct _readPixelsBits {
#ifdef LITTLE_ENDIAN
    unsigned int functionPtrs  : 1;
    unsigned int subimage      : 1;
    unsigned int multiimage    : 1;
    unsigned int unused        :29;
#else
    unsigned int unused        :29;
    unsigned int multiimage    : 1;
    unsigned int subimage      : 1;
    unsigned int functionPtrs  : 1;
#endif
  } bits;
  unsigned int word;
} ReadPixelsFunc;

typedef union _CopyPixelsFunc {
  struct _copyPixelsBits {
#ifdef LITTLE_ENDIAN
    unsigned int rasterPosDim  : 1;
    unsigned int functionPtrs  : 1;
    unsigned int unused        :30;
#else
    unsigned int unused        :30;
    unsigned int functionPtrs  : 1;
    unsigned int rasterPosDim  : 1;
#endif
  } bits;
  unsigned int word;
} CopyPixelsFunc;

typedef union _BitmapFunc {
  struct _bitmapBits {
#ifdef LITTLE_ENDIAN
    unsigned int rasterPosDim  : 1;
    unsigned int functionPtrs  : 1;
    unsigned int subimage      : 1;
    unsigned int multiimage    : 1;
    unsigned int colorDim      : 1;
    unsigned int colorData     : 1;
    unsigned int visual        : 1;
    unsigned int unused        :25;
#else
    unsigned int unused        :25;
    unsigned int visual        : 1;
    unsigned int colorData     : 1;
    unsigned int colorDim      : 1;
    unsigned int multiimage    : 1;
    unsigned int subimage      : 1;
    unsigned int functionPtrs  : 1;
    unsigned int rasterPosDim  : 1;
#endif
  } bits;
  unsigned int word;
} BitmapFunc;

typedef union _TextFunc {
  struct _textBits {
#ifdef LITTLE_ENDIAN
    unsigned int rasterPosDim  : 1;
    unsigned int functionPtrs  : 1;
    unsigned int multiimage    : 1;
    unsigned int colorDim      : 1;
    unsigned int colorData     : 1;
    unsigned int visual        : 1;
    unsigned int unused        :26;
#else
    unsigned int unused        :26;
    unsigned int visual        : 1;
    unsigned int colorData     : 1;
    unsigned int colorDim      : 1;
    unsigned int multiimage    : 1;
    unsigned int functionPtrs  : 1;
    unsigned int rasterPosDim  : 1;
#endif
  } bits;
  unsigned int word;
} TextFunc;

typedef union _TexImageBindFunc {
  struct _texImageBindBits {
#ifdef LITTLE_ENDIAN
    unsigned int multiimage    : 1;
    unsigned int objDraw       : 2;
    unsigned int functionPtrs  : 1;
    unsigned int texSrc        : 1;
    unsigned int unused        :27;
#else
    unsigned int unused        :27;
    unsigned int texSrc        : 1;
    unsigned int functionPtrs  : 1;
    unsigned int objDraw       : 2;
    unsigned int multiimage    : 1;
#endif
  } bits;
  unsigned int word;
} TexImageBindFunc;

typedef union _TexImageCopyFunc {
  struct _texImageCopyBits {
#ifdef LITTLE_ENDIAN
    unsigned int subtexture    : 1;
    unsigned int objDraw       : 2;
    unsigned int functionPtrs  : 1;
    unsigned int texDim        : 2;
    unsigned int unused        :26;
#else
    unsigned int unused        :26;
    unsigned int texDim        : 2;
    unsigned int functionPtrs  : 1;
    unsigned int objDraw       : 2;
    unsigned int subtexture    : 1;
#endif
  } bits;
  unsigned int word;
} TexImageCopyFunc;

typedef union _TexImageLoadFunc {
  struct _texImageLoadBits {
#ifdef LITTLE_ENDIAN
    unsigned int subtexture    : 1;
    unsigned int subimage      : 1;
    unsigned int multilevel    : 1;
    unsigned int multiimage    : 1;
    unsigned int genMipmap     : 1;
    unsigned int objDraw       : 2;
    unsigned int functionPtrs  : 1;
    unsigned int texDim        : 2;
    unsigned int unused        :22;
#else
    unsigned int unused        :22;
    unsigned int texDim        : 2;
    unsigned int functionPtrs  : 1;
    unsigned int objDraw       : 2;
    unsigned int genMipmap     : 1;
    unsigned int multiimage    : 1;
    unsigned int multilevel    : 1;
    unsigned int subimage      : 1;
    unsigned int subtexture    : 1;
#endif
  } bits;
  unsigned int word;
} TexImageLoadFunc;

#endif /* file not already included */
