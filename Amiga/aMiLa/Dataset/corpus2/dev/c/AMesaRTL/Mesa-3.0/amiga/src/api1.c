/* $Id: api1.c,v 3.4 1998/03/27 03:30:36 brianp Exp $ */

/*
 * Mesa 3-D graphics library
 * Version:  3.0
 * Copyright (C) 1995-1998  Brian Paul
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the Free
 * Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */


/*
 * api1.c
 *
 * Version 1.0  27 Jun 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * File created from api1.c ver 1.3 and gl.h ver 1.26 using GenProtos
 *
 * Version 1.1  04 Oct 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * - Changed to v3.4 of api1.c
 *
 */


#ifdef PC_HEADER
#include "all.h"
#else
#include <stdio.h>
#include <stdlib.h>
#include "api.h"
#include "bitmap.h"
#include "context.h"
#include "drawpix.h"
#include "eval.h"
#include "image.h"
#include "macros.h"
#include "matrix.h"
#include "teximage.h"
#include "types.h"
#include "vb.h"
#endif


/*
 * Part 1 of API functions
 */



__asm __saveds void APIENTRY glAccum( register __d0 GLenum op, register __fp0 GLfloat value )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.Accum)(CC, op, value);
}


__asm __saveds void APIENTRY glAlphaFunc( register __d0 GLenum func, register __fp0 GLclampf ref )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.AlphaFunc)(CC, func, ref);
}


__asm __saveds GLboolean APIENTRY glAreTexturesResident( register __d0 GLsizei n, register __a0 const GLuint *textures,
                                                         register __a1 GLboolean *residences )
{
   GET_CONTEXT;
   CHECK_CONTEXT_RETURN(GL_FALSE);
   return (*CC->API.AreTexturesResident)(CC, n, textures, residences);
}


__asm __saveds void APIENTRY glArrayElement( register __d0 GLint i )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.ArrayElement)(CC, i);
}


__asm __saveds void APIENTRY glBegin( register __d0 GLenum mode )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.Begin)( CC, mode );
}


__asm __saveds void APIENTRY glBindTexture( register __d0 GLenum target, register __d1 GLuint texture )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.BindTexture)(CC, target, texture);
}


__asm __saveds void APIENTRY glBitmapA(register __a0 void *vargs)
{
	struct glBitmapArgs {
		GLsizei width;
		GLsizei height;
		GLfloat xorig;
		GLfloat yorig;
		GLfloat xmove;
		GLfloat ymove;
		GLubyte *bitmap;
	} *args;

	args = (struct glBitmapArgs *)vargs;

	glBitmap(args->width, args->height, args->xorig, args->yorig, args->xmove, args->ymove, args->bitmap);
}


__asm __saveds void APIENTRY glBitmap( register __d0 GLsizei width, register __d1 GLsizei height,
                                       register __fp0 GLfloat xorig, register __fp1 GLfloat yorig,
                                       register __fp2 GLfloat xmove, register __fp3 GLfloat ymove,
                                       register __a0 const GLubyte *bitmap )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   if (!CC->DirectContext || CC->CompileFlag
       || !gl_direct_bitmap( CC, width, height, xorig, yorig,
                             xmove, ymove, bitmap)) {
      struct gl_image *image;
      image = gl_unpack_bitmap( CC, width, height, bitmap );
      (*CC->API.Bitmap)( CC, width, height, xorig, yorig,
                         xmove, ymove, image );
      if (image && image->RefCount==0) {
         gl_free_image( image );
      }
   }
}


__asm __saveds void APIENTRY glBlendFunc( register __d0 GLenum sfactor, register __d1 GLenum dfactor )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.BlendFunc)(CC, sfactor, dfactor);
}


__asm __saveds void APIENTRY glCallList( register __d0 GLuint list )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.CallList)(CC, list);
}


__asm __saveds void APIENTRY glCallLists( register __d0 GLsizei n, register __d1 GLenum type, register __a0 const GLvoid *lists )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.CallLists)(CC, n, type, lists);
}


__asm __saveds void APIENTRY glClear( register __d0 GLbitfield mask )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.Clear)(CC, mask);
}


__asm __saveds void APIENTRY glClearAccum( register __fp0 GLfloat red, register __fp1 GLfloat green,
                                           register __fp2 GLfloat blue, register __fp3 GLfloat alpha )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.ClearAccum)(CC, red, green, blue, alpha);
}



__asm __saveds void APIENTRY glClearIndex( register __fp0 GLfloat c )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.ClearIndex)(CC, c);
}


__asm __saveds void APIENTRY glClearColor( register __fp0 GLclampf red,
                                           register __fp1 GLclampf green,
                                           register __fp2 GLclampf blue,
                                           register __fp3 GLclampf alpha )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.ClearColor)(CC, red, green, blue, alpha);
}


__asm __saveds void APIENTRY glClearDepth( register __fp0 GLclampd depth )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.ClearDepth)( CC, depth );
}


__asm __saveds void APIENTRY glClearStencil( register __d0 GLint s )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.ClearStencil)(CC, s);
}


__asm __saveds void APIENTRY glClipPlane( register __d0 GLenum plane, register __a0 const GLdouble *equation )
{
   GLfloat eq[4];
   GET_CONTEXT;
   CHECK_CONTEXT;
   eq[0] = (GLfloat) equation[0];
   eq[1] = (GLfloat) equation[1];
   eq[2] = (GLfloat) equation[2];
   eq[3] = (GLfloat) equation[3];
   (*CC->API.ClipPlane)(CC, plane, eq );
}


__asm __saveds void APIENTRY glColor3b( register __d0 GLbyte red, register __d1 GLbyte green, register __d2 GLbyte blue )
{
   GET_CONTEXT;
   (*CC->API.Color3f)( CC, BYTE_TO_FLOAT(red), BYTE_TO_FLOAT(green),
                       BYTE_TO_FLOAT(blue) );
}


__asm __saveds void APIENTRY glColor3d( register __fp0 GLdouble red, register __fp1 GLdouble green, register __fp2 GLdouble blue )
{
   GET_CONTEXT;
   (*CC->API.Color3f)( CC, (GLfloat) red, (GLfloat) green, (GLfloat) blue );
}


__asm __saveds void APIENTRY glColor3f( register __fp0 GLfloat red, register __fp1 GLfloat green, register __fp2 GLfloat blue )
{
   GET_CONTEXT;
   (*CC->API.Color3f)( CC, red, green, blue );
}


__asm __saveds void APIENTRY glColor3i( register __d0 GLint red, register __d1 GLint green, register __d2 GLint blue )
{
   GET_CONTEXT;
   (*CC->API.Color3f)( CC, INT_TO_FLOAT(red), INT_TO_FLOAT(green),
                       INT_TO_FLOAT(blue) );
}


__asm __saveds void APIENTRY glColor3s( register __d0 GLshort red, register __d1 GLshort green, register __d2 GLshort blue )
{
   GET_CONTEXT;
   (*CC->API.Color3f)( CC, SHORT_TO_FLOAT(red), SHORT_TO_FLOAT(green),
                       SHORT_TO_FLOAT(blue) );
}


__asm __saveds void APIENTRY glColor3ub( register __d0 GLubyte red, register __d1 GLubyte green, register __d2 GLubyte blue )
{
   GET_CONTEXT;
   (*CC->API.Color4ub)( CC, red, green, blue, 255 );
}


__asm __saveds void APIENTRY glColor3ui( register __d0 GLuint red, register __d1 GLuint green, register __d2 GLuint blue )
{
   GET_CONTEXT;
   (*CC->API.Color3f)( CC, UINT_TO_FLOAT(red), UINT_TO_FLOAT(green),
                       UINT_TO_FLOAT(blue) );
}


__asm __saveds void APIENTRY glColor3us( register __d0 GLushort red, register __d1 GLushort green, register __d2 GLushort blue )
{
   GET_CONTEXT;
   (*CC->API.Color3f)( CC, USHORT_TO_FLOAT(red), USHORT_TO_FLOAT(green),
                       USHORT_TO_FLOAT(blue) );
}


__asm __saveds void APIENTRY glColor4b( register __d0 GLbyte red, register __d1 GLbyte green, register __d2 GLbyte blue, register __d3 GLbyte alpha )
{
   GET_CONTEXT;
   (*CC->API.Color4f)( CC, BYTE_TO_FLOAT(red), BYTE_TO_FLOAT(green),
                       BYTE_TO_FLOAT(blue), BYTE_TO_FLOAT(alpha) );
}


__asm __saveds void APIENTRY glColor4d( register __fp0 GLdouble red, register __fp1 GLdouble green, register __fp2 GLdouble blue, register __fp3 GLdouble alpha )
{
   GET_CONTEXT;
   (*CC->API.Color4f)( CC, (GLfloat) red, (GLfloat) green,
                       (GLfloat) blue, (GLfloat) alpha );
}


__asm __saveds void APIENTRY glColor4f( register __fp0 GLfloat red, register __fp1 GLfloat green, register __fp2 GLfloat blue, register __fp3 GLfloat alpha )
{
   GET_CONTEXT;
   (*CC->API.Color4f)( CC, red, green, blue, alpha );
}

__asm __saveds void APIENTRY glColor4i( register __d0 GLint red, register __d1 GLint green, register __d2 GLint blue, register __d3 GLint alpha )
{
   GET_CONTEXT;
   (*CC->API.Color4f)( CC, INT_TO_FLOAT(red), INT_TO_FLOAT(green),
                       INT_TO_FLOAT(blue), INT_TO_FLOAT(alpha) );
}


__asm __saveds void APIENTRY glColor4s( register __d0 GLshort red, register __d1 GLshort green, register __d2 GLshort blue, register __d3 GLshort alpha )
{
   GET_CONTEXT;
   (*CC->API.Color4f)( CC, SHORT_TO_FLOAT(red), SHORT_TO_FLOAT(green),
                       SHORT_TO_FLOAT(blue), SHORT_TO_FLOAT(alpha) );
}

__asm __saveds void APIENTRY glColor4ub( register __d0 GLubyte red, register __d1 GLubyte green, register __d2 GLubyte blue, register __d3 GLubyte alpha )
{
   GET_CONTEXT;
   (*CC->API.Color4ub)( CC, red, green, blue, alpha );
}

__asm __saveds void APIENTRY glColor4ui( register __d0 GLuint red, register __d1 GLuint green, register __d2 GLuint blue, register __d3 GLuint alpha )
{
   GET_CONTEXT;
   (*CC->API.Color4f)( CC, UINT_TO_FLOAT(red), UINT_TO_FLOAT(green),
                       UINT_TO_FLOAT(blue), UINT_TO_FLOAT(alpha) );
}

__asm __saveds void APIENTRY glColor4us( register __d0 GLushort red, register __d1 GLushort green, register __d2 GLushort blue, register __d3 GLushort alpha )
{
   GET_CONTEXT;
   (*CC->API.Color4f)( CC, USHORT_TO_FLOAT(red), USHORT_TO_FLOAT(green),
                       USHORT_TO_FLOAT(blue), USHORT_TO_FLOAT(alpha) );
}


__asm __saveds void APIENTRY glColor3bv( register __a0 const GLbyte *v )
{
   GET_CONTEXT;
   (*CC->API.Color3f)( CC, BYTE_TO_FLOAT(v[0]), BYTE_TO_FLOAT(v[1]),
                       BYTE_TO_FLOAT(v[2]) );
}


__asm __saveds void APIENTRY glColor3dv( register __a0 const GLdouble *v )
{
   GET_CONTEXT;
   (*CC->API.Color3f)( CC, (GLdouble) v[0], (GLdouble) v[1], (GLdouble) v[2] );
}


__asm __saveds void APIENTRY glColor3fv( register __a0 const GLfloat *v )
{
   GET_CONTEXT;
   (*CC->API.Color3fv)( CC, v );
}


__asm __saveds void APIENTRY glColor3iv( register __a0 const GLint *v )
{
   GET_CONTEXT;
   (*CC->API.Color3f)( CC, INT_TO_FLOAT(v[0]), INT_TO_FLOAT(v[1]),
                       INT_TO_FLOAT(v[2]) );
}


__asm __saveds void APIENTRY glColor3sv( register __a0 const GLshort *v )
{
   GET_CONTEXT;
   (*CC->API.Color3f)( CC, SHORT_TO_FLOAT(v[0]), SHORT_TO_FLOAT(v[1]),
                       SHORT_TO_FLOAT(v[2]) );
}


__asm __saveds void APIENTRY glColor3ubv( register __a0 const GLubyte *v )
{
   GET_CONTEXT;
   (*CC->API.Color4ub)( CC, v[0], v[1], v[2], 255 );
}


__asm __saveds void APIENTRY glColor3uiv( register __a0 const GLuint *v )
{
   GET_CONTEXT;
   (*CC->API.Color3f)( CC, UINT_TO_FLOAT(v[0]), UINT_TO_FLOAT(v[1]),
                       UINT_TO_FLOAT(v[2]) );
}


__asm __saveds void APIENTRY glColor3usv( register __a0 const GLushort *v )
{
   GET_CONTEXT;
   (*CC->API.Color3f)( CC, USHORT_TO_FLOAT(v[0]), USHORT_TO_FLOAT(v[1]),
                       USHORT_TO_FLOAT(v[2]) );

}


__asm __saveds void APIENTRY glColor4bv( register __a0 const GLbyte *v )
{
   GET_CONTEXT;
   (*CC->API.Color4f)( CC, BYTE_TO_FLOAT(v[0]), BYTE_TO_FLOAT(v[1]),
                       BYTE_TO_FLOAT(v[2]), BYTE_TO_FLOAT(v[3]) );
}


__asm __saveds void APIENTRY glColor4dv( register __a0 const GLdouble *v )
{
   GET_CONTEXT;
   (*CC->API.Color4f)( CC, (GLdouble) v[0], (GLdouble) v[1],
                       (GLdouble) v[2], (GLdouble) v[3] );
}


__asm __saveds void APIENTRY glColor4fv( register __a0 const GLfloat *v )
{
   GET_CONTEXT;
   (*CC->API.Color4f)( CC, v[0], v[1], v[2], v[3] );
}


__asm __saveds void APIENTRY glColor4iv( register __a0 const GLint *v )
{
   GET_CONTEXT;
   (*CC->API.Color4f)( CC, INT_TO_FLOAT(v[0]), INT_TO_FLOAT(v[1]),
                       INT_TO_FLOAT(v[2]), INT_TO_FLOAT(v[3]) );
}


__asm __saveds void APIENTRY glColor4sv( register __a0 const GLshort *v )
{
   GET_CONTEXT;
   (*CC->API.Color4f)( CC, SHORT_TO_FLOAT(v[0]), SHORT_TO_FLOAT(v[1]),
                       SHORT_TO_FLOAT(v[2]), SHORT_TO_FLOAT(v[3]) );
}


__asm __saveds void APIENTRY glColor4ubv( register __a0 const GLubyte *v )
{
   GET_CONTEXT;
   (*CC->API.Color4ubv)( CC, v );
}


__asm __saveds void APIENTRY glColor4uiv( register __a0 const GLuint *v )
{
   GET_CONTEXT;
   (*CC->API.Color4f)( CC, UINT_TO_FLOAT(v[0]), UINT_TO_FLOAT(v[1]),
                       UINT_TO_FLOAT(v[2]), UINT_TO_FLOAT(v[3]) );
}


__asm __saveds void APIENTRY glColor4usv( register __a0 const GLushort *v )
{
   GET_CONTEXT;
   (*CC->API.Color4f)( CC, USHORT_TO_FLOAT(v[0]), USHORT_TO_FLOAT(v[1]),
                       USHORT_TO_FLOAT(v[2]), USHORT_TO_FLOAT(v[3]) );
}


__asm __saveds void APIENTRY glColorMask( register __d0 GLboolean red, register __d1 GLboolean green,
                                          register __d2 GLboolean blue, register __d3 GLboolean alpha )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.ColorMask)(CC, red, green, blue, alpha);
}


__asm __saveds void APIENTRY glColorMaterial( register __d0 GLenum face, register __d1 GLenum mode )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.ColorMaterial)(CC, face, mode);
}


__asm __saveds void APIENTRY glColorPointer( register __d0 GLint size, register __d1 GLenum type, register __d2 GLsizei stride,
                                             register __a0 const GLvoid *ptr )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.ColorPointer)(CC, size, type, stride, ptr);
}


__asm __saveds void APIENTRY glColorTableEXT( register __d0 GLenum target, register __d1 GLenum internalFormat,
                                              register __d2 GLsizei width, register __d3 GLenum format, register __d4 GLenum type,
                                              register __a0 const GLvoid *table )
{
   struct gl_image *image;
   GET_CONTEXT;
   CHECK_CONTEXT;
   image = gl_unpack_image( CC, width, 1, format, type, table );
   (*CC->API.ColorTable)( CC, target, internalFormat, image );
   if (image->RefCount == 0)
      gl_free_image(image);
}


__asm __saveds void APIENTRY glColorSubTableEXT( register __d0 GLenum target, register __d1 GLsizei start, register __d2 GLsizei count,
                                                 register __d3 GLenum format, register __d4 GLenum type,
                                                 register __a0 const GLvoid *data )
{
   struct gl_image *image;
   GET_CONTEXT;
   CHECK_CONTEXT;
   image = gl_unpack_image( CC, count, 1, format, type, data );
   (*CC->API.ColorSubTable)( CC, target, start, image );
   if (image->RefCount == 0)
      gl_free_image(image);
}



__asm __saveds void APIENTRY glCopyPixels( register __d0 GLint x, register __d1 GLint y, register __d2 GLsizei width, register __d3 GLsizei height,
                                           register __d4 GLenum type )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.CopyPixels)(CC, x, y, width, height, type);
}


__asm __saveds void APIENTRY glCopyTexImage1D( register __d0 GLenum target, register __d1 GLint level,
                                               register __d2 GLenum internalformat,
                                               register __d3 GLint x, register __d4 GLint y,
                                               register __d5 GLsizei width, register __d6 GLint border )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.CopyTexImage1D)( CC, target, level, internalformat,
								 x, y, width, border );
}


__asm __saveds void APIENTRY glCopyTexImage2D( register __d0 GLenum target, register __d1 GLint level,
                                               register __d2 GLenum internalformat,
                                               register __d3 GLint x, register __d4 GLint y,
                                               register __d5 GLsizei width, register __d6 GLsizei height, register __d7 GLint border )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.CopyTexImage2D)( CC, target, level, internalformat,
                              x, y, width, height, border );
}


__asm __saveds void APIENTRY glCopyTexSubImage1D( register __d0 GLenum target, register __d1 GLint level,
                                                  register __d2 GLint xoffset, register __d3 GLint x, register __d4 GLint y,
                                                  register __d5 GLsizei width )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.CopyTexSubImage1D)( CC, target, level, xoffset, x, y, width );
}


__asm __saveds void APIENTRY glCopyTexSubImage2D( register __d0 GLenum target, register __d1 GLint level,
                                                  register __d2 GLint xoffset, register __d3 GLint yoffset,
                                                  register __d4 GLint x, register __d5 GLint y,
                                                  register __d6 GLsizei width, register __d7 GLsizei height )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.CopyTexSubImage2D)( CC, target, level, xoffset, yoffset,
                                 x, y, width, height );
}


/* 1.2 */
__asm __saveds void APIENTRY glCopyTexSubImage3D( register __d0 GLenum target, register __d1 GLint level,
                                                  register __d2 GLint xoffset, register __d3 GLint yoffset,
                                                  register __d4 GLint zoffset, register __d5 GLint x,
                                                  register __d6 GLint y, register __d7 GLsizei width,
                                                  register __a0 GLsizei height )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.CopyTexSubImage3DEXT)( CC, target, level, xoffset, yoffset,
                                    zoffset, x, y, width, height );
}


__asm __saveds void APIENTRY glCullFace( register __d0 GLenum mode )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.CullFace)(CC, mode);
}


__asm __saveds void APIENTRY glDepthFunc( register __d0 GLenum func )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.DepthFunc)( CC, func );
}


__asm __saveds void APIENTRY glDepthMask( register __d0 GLboolean flag )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.DepthMask)( CC, flag );
}


__asm __saveds void APIENTRY glDepthRange( register __fp0 GLclampd near_val, register __fp1 GLclampd far_val )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.DepthRange)( CC, near_val, far_val );
}


__asm __saveds void APIENTRY glDeleteLists( register __d0 GLuint list, register __d1 GLsizei range )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.DeleteLists)(CC, list, range);
}


__asm __saveds void APIENTRY glDeleteTextures( register __d0 GLsizei n, register __a0 const GLuint *textures )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.DeleteTextures)(CC, n, textures);
}


__asm __saveds void APIENTRY glDisable( register __d0 GLenum cap )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.Disable)( CC, cap );
}


__asm __saveds void APIENTRY glDisableClientState( register __d0 GLenum cap )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.DisableClientState)( CC, cap );
}


__asm __saveds void APIENTRY glDrawArrays( register __d0 GLenum mode, register __d1 GLint first, register __d2 GLsizei count )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.DrawArrays)(CC, mode, first, count);
}


__asm __saveds void APIENTRY glDrawBuffer( register __d0 GLenum mode )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.DrawBuffer)(CC, mode);
}


__asm __saveds void APIENTRY glDrawElements( register __d0 GLenum mode, register __d1 GLsizei count,
                                             register __d2 GLenum type, register __a0 const GLvoid *indices )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.DrawElements)( CC, mode, count, type, indices );
}


__asm __saveds void APIENTRY glDrawPixels( register __d0 GLsizei width, register __d1 GLsizei height,
                                           register __d2 GLenum format, register __d3 GLenum type, register __a0 const GLvoid *pixels )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   if (!CC->DirectContext || CC->CompileFlag
       || !gl_direct_DrawPixels(CC, &CC->Unpack, width, height,
                                format, type, pixels)) {
      struct gl_image *image;
      image = gl_unpack_image( CC, width, height, format, type, pixels );
      (*CC->API.DrawPixels)( CC, image );
      if (image->RefCount==0) {
         /* image not in display list */
         gl_free_image( image );
      }
   }
}


/* GL_VERSION_1_2 */
__asm __saveds void APIENTRY glDrawRangeElements( register __d0 GLenum mode, register __d1 GLuint start,
                                                  register __d2 GLuint end, register __d3 GLsizei count, register __d4 GLenum type, register __a0 const GLvoid *indices )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.DrawRangeElements)( CC, mode, start, end, count, type, indices );
}


__asm __saveds void APIENTRY glEnable( register __d0 GLenum cap )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.Enable)( CC, cap );
}


__asm __saveds void APIENTRY glEnableClientState( register __d0 GLenum cap )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.EnableClientState)( CC, cap );
}


__asm __saveds void APIENTRY glEnd( void )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.End)( CC );
}


__asm __saveds void APIENTRY glEndList( void )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.EndList)(CC);
}




__asm __saveds void APIENTRY glEvalCoord1d( register __fp0 GLdouble u )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.EvalCoord1f)( CC, (GLfloat) u );
}


__asm __saveds void APIENTRY glEvalCoord1f( register __fp0 GLfloat u )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.EvalCoord1f)( CC, u );
}


__asm __saveds void APIENTRY glEvalCoord1dv( register __a0 const GLdouble *u )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.EvalCoord1f)( CC, (GLfloat) *u );
}


__asm __saveds void APIENTRY glEvalCoord1fv( register __a0 const GLfloat *u )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.EvalCoord1f)( CC, (GLfloat) *u );
}


__asm __saveds void APIENTRY glEvalCoord2d( register __fp0 GLdouble u, register __fp1 GLdouble v )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.EvalCoord2f)( CC, (GLfloat) u, (GLfloat) v );
}


__asm __saveds void APIENTRY glEvalCoord2f( register __fp0 GLfloat u, register __fp1 GLfloat v )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.EvalCoord2f)( CC, u, v );
}


__asm __saveds void APIENTRY glEvalCoord2dv( register __a0 const GLdouble *u )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.EvalCoord2f)( CC, (GLfloat) u[0], (GLfloat) u[1] );
}


__asm __saveds void APIENTRY glEvalCoord2fv( register __a0 const GLfloat *u )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.EvalCoord2f)( CC, u[0], u[1] );
}


__asm __saveds void APIENTRY glEvalPoint1( register __d0 GLint i )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.EvalPoint1)( CC, i );
}


__asm __saveds void APIENTRY glEvalPoint2( register __d0 GLint i, register __d1 GLint j )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.EvalPoint2)( CC, i, j );
}


__asm __saveds void APIENTRY glEvalMesh1( register __d0 GLenum mode, register __d1 GLint i1, register __d2 GLint i2 )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.EvalMesh1)( CC, mode, i1, i2 );
}


__asm __saveds void APIENTRY glEdgeFlag( register __d0 GLboolean flag )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.EdgeFlag)(CC, flag);
}


__asm __saveds void APIENTRY glEdgeFlagv( register __a0 const GLboolean *flag )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.EdgeFlag)(CC, *flag);
}


__asm __saveds void APIENTRY glEdgeFlagPointer( register __d0 GLsizei stride, register __a0 const GLboolean *ptr )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.EdgeFlagPointer)(CC, stride, ptr);
}


__asm __saveds void APIENTRY glEvalMesh2( register __d0 GLenum mode, register __d1 GLint i1, register __d2 GLint i2, register __d3 GLint j1, register __d4 GLint j2 )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.EvalMesh2)( CC, mode, i1, i2, j1, j2 );
}


__asm __saveds void APIENTRY glFeedbackBuffer( register __d0 GLsizei size, register __d1 GLenum type, register __a0 GLfloat *buffer )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.FeedbackBuffer)(CC, size, type, buffer);
}


__asm __saveds void APIENTRY glFinish( void )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.Finish)(CC);
}


__asm __saveds void APIENTRY glFlush( void )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.Flush)(CC);
}


__asm __saveds void APIENTRY glFogf( register __d0 GLenum pname, register __fp0 GLfloat param )
{
   GLfloat f = param;
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.Fogfv)(CC, pname, &f);
}


__asm __saveds void APIENTRY glFogi( register __d0 GLenum pname, register __d1 GLint param )
{
   GLfloat fparam = (GLfloat) param;
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.Fogfv)(CC, pname, &fparam);
}


__asm __saveds void APIENTRY glFogfv( register __d0 GLenum pname, register __a0 const GLfloat *params )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.Fogfv)(CC, pname, params);
}


__asm __saveds void APIENTRY glFogiv( register __d0 GLenum pname, register __a0 const GLint *params )
{
   GLfloat p[4];
   GET_CONTEXT;
   CHECK_CONTEXT;

   switch (pname) {
      case GL_FOG_MODE:
      case GL_FOG_DENSITY:
      case GL_FOG_START:
      case GL_FOG_END:
      case GL_FOG_INDEX:
	 p[0] = (GLfloat) *params;
	 break;
      case GL_FOG_COLOR:
	 p[0] = INT_TO_FLOAT( params[0] );
	 p[1] = INT_TO_FLOAT( params[1] );
	 p[2] = INT_TO_FLOAT( params[2] );
	 p[3] = INT_TO_FLOAT( params[3] );
	 break;
      default:
         /* Error will be caught later in gl_Fogfv */
         ;
   }
   (*CC->API.Fogfv)( CC, pname, p );
}



__asm __saveds void APIENTRY glFrontFace( register __d0 GLenum mode )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.FrontFace)(CC, mode);
}


__asm __saveds void APIENTRY glFrustumA(register __a0 void *vargs)
{
	struct glFrustumArgs {
		GLdouble left;
		GLdouble right;
		GLdouble bottom;
		GLdouble top;
		GLdouble nearval;
		GLdouble farval;
	} *args;

	args = (struct glFrustumArgs *)vargs;

	glFrustum(args->left, args->right, args->bottom, args->top, args->nearval, args->farval);
}


__asm __saveds void APIENTRY glFrustum( register __fp0 GLdouble left, register __fp1 GLdouble right,
                                        register __fp2 GLdouble bottom, register __fp3 GLdouble top,
                                        register __fp4 GLdouble nearval, register __fp5 GLdouble farval )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.Frustum)(CC, left, right, bottom, top, nearval, farval);
}


__asm __saveds GLuint APIENTRY glGenLists( register __d0 GLsizei range )
{
   GET_CONTEXT;
   CHECK_CONTEXT_RETURN(0);
   return (*CC->API.GenLists)(CC, range);
}


__asm __saveds void APIENTRY glGenTextures( register __d0 GLsizei n, register __a0 GLuint *textures )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.GenTextures)(CC, n, textures);
}


__asm __saveds void APIENTRY glGetBooleanv( register __d0 GLenum pname, register __a0 GLboolean *params )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.GetBooleanv)(CC, pname, params);
}


__asm __saveds void APIENTRY glGetClipPlane( register __d0 GLenum plane, register __a0 GLdouble *equation )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.GetClipPlane)(CC, plane, equation);
}


__asm __saveds void APIENTRY glGetColorTableEXT( register __d0 GLenum target, register __d1 GLenum format,
                                                 register __d2 GLenum type, register __a0 GLvoid *table )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.GetColorTable)(CC, target, format, type, table);
}


__asm __saveds void APIENTRY glGetColorTableParameterivEXT( register __d0 GLenum target, register __d1 GLenum pname,
                                                            register __a0 GLint *params )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.GetColorTableParameteriv)(CC, target, pname, params);
}


__asm __saveds void APIENTRY glGetColorTableParameterfvEXT( register __d0 GLenum target, register __d1 GLenum pname,
                                                            register __a0 GLfloat *params )
{
   GLint iparams;
   glGetColorTableParameterivEXT( target, pname, &iparams );
   *params = (GLfloat) iparams;
}


__asm __saveds void APIENTRY glGetDoublev( register __d0 GLenum pname, register __a0 GLdouble *params )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.GetDoublev)(CC, pname, params);
}


__asm __saveds GLenum APIENTRY glGetError( void )
{
   GET_CONTEXT;
   if (!CC) {
      /* No current context */
      return (GLenum) GL_NO_ERROR;
   }
   return (*CC->API.GetError)(CC);
}


__asm __saveds void APIENTRY glGetFloatv( register __d0 GLenum pname, register __a0 GLfloat *params )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.GetFloatv)(CC, pname, params);
}


__asm __saveds void APIENTRY glGetIntegerv( register __d0 GLenum pname, register __a0 GLint *params )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.GetIntegerv)(CC, pname, params);
}


__asm __saveds void APIENTRY glGetLightfv( register __d0 GLenum light, register __d1 GLenum pname, register __a0 GLfloat *params )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.GetLightfv)(CC, light, pname, params);
}


__asm __saveds void APIENTRY glGetLightiv( register __d0 GLenum light, register __d1 GLenum pname, register __a0 GLint *params )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.GetLightiv)(CC, light, pname, params);
}


__asm __saveds void APIENTRY glGetMapdv( register __d0 GLenum target, register __d1 GLenum query, register __a0 GLdouble *v )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.GetMapdv)( CC, target, query, v );
}


__asm __saveds void APIENTRY glGetMapfv( register __d0 GLenum target, register __d1 GLenum query, register __a0 GLfloat *v )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.GetMapfv)( CC, target, query, v );
}


__asm __saveds void APIENTRY glGetMapiv( register __d0 GLenum target, register __d1 GLenum query, register __a0 GLint *v )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.GetMapiv)( CC, target, query, v );
}


__asm __saveds void APIENTRY glGetMaterialfv( register __d0 GLenum face, register __d1 GLenum pname, register __a0 GLfloat *params )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.GetMaterialfv)(CC, face, pname, params);
}


__asm __saveds void APIENTRY glGetMaterialiv( register __d0 GLenum face, register __d1 GLenum pname, register __a0 GLint *params )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.GetMaterialiv)(CC, face, pname, params);
}


__asm __saveds void APIENTRY glGetPixelMapfv( register __d0 GLenum map, register __a0 GLfloat *values )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.GetPixelMapfv)(CC, map, values);
}


__asm __saveds void APIENTRY glGetPixelMapuiv( register __d0 GLenum map, register __a0 GLuint *values )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.GetPixelMapuiv)(CC, map, values);
}


__asm __saveds void APIENTRY glGetPixelMapusv( register __d0 GLenum map, register __a0 GLushort *values )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.GetPixelMapusv)(CC, map, values);
}


__asm __saveds void APIENTRY glGetPointerv( register __d0 GLenum pname, register __a0 GLvoid **params )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.GetPointerv)(CC, pname, params);
}


__asm __saveds void APIENTRY glGetPolygonStipple( register __a0 GLubyte *mask )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.GetPolygonStipple)(CC, mask);
}


__asm __saveds const GLubyte * APIENTRY glGetString( register __d0 GLenum name )
{
   GET_CONTEXT;
   CHECK_CONTEXT_RETURN(NULL);
   return (*CC->API.GetString)(CC, name);
}



__asm __saveds void APIENTRY glGetTexEnvfv( register __d0 GLenum target, register __d1 GLenum pname, register __a0 GLfloat *params )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.GetTexEnvfv)(CC, target, pname, params);
}


__asm __saveds void APIENTRY glGetTexEnviv( register __d0 GLenum target, register __d1 GLenum pname, register __a0 GLint *params )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.GetTexEnviv)(CC, target, pname, params);
}


__asm __saveds void APIENTRY glGetTexGeniv( register __d0 GLenum coord, register __d1 GLenum pname, register __a0 GLint *params )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.GetTexGeniv)(CC, coord, pname, params);
}


__asm __saveds void APIENTRY glGetTexGendv( register __d0 GLenum coord, register __d1 GLenum pname, register __a0 GLdouble *params )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.GetTexGendv)(CC, coord, pname, params);
}


__asm __saveds void APIENTRY glGetTexGenfv( register __d0 GLenum coord, register __d1 GLenum pname, register __a0 GLfloat *params )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.GetTexGenfv)(CC, coord, pname, params);
}



__asm __saveds void APIENTRY glGetTexImage( register __d0 GLenum target, register __d1 GLint level, register __d2 GLenum format,
                                            register __d3 GLenum type, register __a0 GLvoid *pixels )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.GetTexImage)(CC, target, level, format, type, pixels);
}


__asm __saveds void APIENTRY glGetTexLevelParameterfv( register __d0 GLenum target, register __d1 GLint level,
                                                       register __d2 GLenum pname, register __a0 GLfloat *params )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.GetTexLevelParameterfv)(CC, target, level, pname, params);
}


__asm __saveds void APIENTRY glGetTexLevelParameteriv( register __d0 GLenum target, register __d1 GLint level,
                                                       register __d2 GLenum pname, register __a0 GLint *params )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.GetTexLevelParameteriv)(CC, target, level, pname, params);
}




__asm __saveds void APIENTRY glGetTexParameterfv( register __d0 GLenum target, register __d1 GLenum pname, register __a0 GLfloat *params )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.GetTexParameterfv)(CC, target, pname, params);
}


__asm __saveds void APIENTRY glGetTexParameteriv( register __d0 GLenum target, register __d1 GLenum pname, register __a0 GLint *params )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.GetTexParameteriv)(CC, target, pname, params);
}


__asm __saveds void APIENTRY glHint( register __d0 GLenum target, register __d1 GLenum mode )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.Hint)(CC, target, mode);
}


__asm __saveds void APIENTRY glIndexd( register __fp0 GLdouble c )
{
   GET_CONTEXT;
   (*CC->API.Indexf)( CC, (GLfloat) c );
}


__asm __saveds void APIENTRY glIndexf( register __fp0 GLfloat c )
{
   GET_CONTEXT;
   (*CC->API.Indexf)( CC, c );
}


__asm __saveds void APIENTRY glIndexi( register __d0 GLint c )
{
   GET_CONTEXT;
   (*CC->API.Indexi)( CC, c );
}


__asm __saveds void APIENTRY glIndexs( register __d0 GLshort c )
{
   GET_CONTEXT;
   (*CC->API.Indexi)( CC, (GLint) c );
}


/* GL_VERSION_1_1 */
__asm __saveds void APIENTRY glIndexub( register __d0 GLubyte c )
{
   GET_CONTEXT;
   (*CC->API.Indexi)( CC, (GLint) c );
}


__asm __saveds void APIENTRY glIndexdv( register __a0 const GLdouble *c )
{
   GET_CONTEXT;
   (*CC->API.Indexf)( CC, (GLfloat) *c );
}


__asm __saveds void APIENTRY glIndexfv( register __a0 const GLfloat *c )
{
   GET_CONTEXT;
   (*CC->API.Indexf)( CC, *c );
}


__asm __saveds void APIENTRY glIndexiv( register __a0 const GLint *c )
{
   GET_CONTEXT;
   (*CC->API.Indexi)( CC, *c );
}


__asm __saveds void APIENTRY glIndexsv( register __a0 const GLshort *c )
{
   GET_CONTEXT;
   (*CC->API.Indexi)( CC, (GLint) *c );
}


/* GL_VERSION_1_1 */
__asm __saveds void APIENTRY glIndexubv( register __a0 const GLubyte *c )
{
   GET_CONTEXT;
   (*CC->API.Indexi)( CC, (GLint) *c );
}


__asm __saveds void APIENTRY glIndexMask( register __d0 GLuint mask )
{
   GET_CONTEXT;
   (*CC->API.IndexMask)(CC, mask);
}


__asm __saveds void APIENTRY glIndexPointer( register __d0 GLenum type, register __d1 GLsizei stride, register __a0 const GLvoid *ptr )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.IndexPointer)(CC, type, stride, ptr);
}


__asm __saveds void APIENTRY glInterleavedArrays( register __d0 GLenum format, register __d1 GLsizei stride,
                                                  register __a0 const GLvoid *pointer )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.InterleavedArrays)( CC, format, stride, pointer );
}


__asm __saveds void APIENTRY glInitNames( void )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.InitNames)(CC);
}


__asm __saveds GLboolean APIENTRY glIsList( register __d0 GLuint list )
{
   GET_CONTEXT;
   CHECK_CONTEXT_RETURN(GL_FALSE);
   return (*CC->API.IsList)(CC, list);
}


__asm __saveds GLboolean APIENTRY glIsTexture( register __d0 GLuint texture )
{
   GET_CONTEXT;
   CHECK_CONTEXT_RETURN(GL_FALSE);
   return (*CC->API.IsTexture)(CC, texture);
}


__asm __saveds void APIENTRY glLightf( register __d0 GLenum light, register __d1 GLenum pname, register __fp0 GLfloat param )
{
   GLfloat f = param;

   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.Lightfv)( CC, light, pname, &f, 1 );
}



__asm __saveds void APIENTRY glLighti( register __d0 GLenum light, register __d1 GLenum pname, register __d2 GLint param )
{
   GLfloat fparam = (GLfloat) param;
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.Lightfv)( CC, light, pname, &fparam, 1 );
}



__asm __saveds void APIENTRY glLightfv( register __d0 GLenum light, register __d1 GLenum pname, register __a0 const GLfloat *params )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.Lightfv)( CC, light, pname, params, 4 );
}



__asm __saveds void APIENTRY glLightiv( register __d0 GLenum light, register __d1 GLenum pname, register __a0 const GLint *params )
{
   GLfloat fparam[4];
   GET_CONTEXT;
   CHECK_CONTEXT;

   switch (pname) {
      case GL_AMBIENT:
      case GL_DIFFUSE:
      case GL_SPECULAR:
         fparam[0] = INT_TO_FLOAT( params[0] );
         fparam[1] = INT_TO_FLOAT( params[1] );
         fparam[2] = INT_TO_FLOAT( params[2] );
         fparam[3] = INT_TO_FLOAT( params[3] );
         break;
      case GL_POSITION:
         fparam[0] = (GLfloat) params[0];
         fparam[1] = (GLfloat) params[1];
         fparam[2] = (GLfloat) params[2];
         fparam[3] = (GLfloat) params[3];
         break;
      case GL_SPOT_DIRECTION:
         fparam[0] = (GLfloat) params[0];
         fparam[1] = (GLfloat) params[1];
         fparam[2] = (GLfloat) params[2];
         break;
      case GL_SPOT_EXPONENT:
	  case GL_SPOT_CUTOFF:
      case GL_CONSTANT_ATTENUATION:
      case GL_LINEAR_ATTENUATION:
      case GL_QUADRATIC_ATTENUATION:
         fparam[0] = (GLfloat) params[0];
         break;
      default:
		 /* error will be caught later in gl_Lightfv */
		 ;
   }
   (*CC->API.Lightfv)( CC, light, pname, fparam, 4 );
}



__asm __saveds void APIENTRY glLightModelf( register __d0 GLenum pname, register __fp0 GLfloat param )
{
   GLfloat f = param;

   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.LightModelfv)( CC, pname, &f );
}


__asm __saveds void APIENTRY glLightModeli( register __d0 GLenum pname, register __d1 GLint param )
{
   GLfloat fparam[4];
   GET_CONTEXT;
   CHECK_CONTEXT;
   fparam[0] = (GLfloat) param;
   (*CC->API.LightModelfv)( CC, pname, fparam );
}


__asm __saveds void APIENTRY glLightModelfv( register __d0 GLenum pname, register __a0 const GLfloat *params )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.LightModelfv)( CC, pname, params );
}


__asm __saveds void APIENTRY glLightModeliv( register __d0 GLenum pname, register __a0 const GLint *params )
{
   GLfloat fparam[4];
   GET_CONTEXT;
   CHECK_CONTEXT;

   switch (pname) {
      case GL_LIGHT_MODEL_AMBIENT:
         fparam[0] = INT_TO_FLOAT( params[0] );
         fparam[1] = INT_TO_FLOAT( params[1] );
         fparam[2] = INT_TO_FLOAT( params[2] );
         fparam[3] = INT_TO_FLOAT( params[3] );
         break;
      case GL_LIGHT_MODEL_LOCAL_VIEWER:
      case GL_LIGHT_MODEL_TWO_SIDE:
         fparam[0] = (GLfloat) params[0];
         break;
      default:
         /* Error will be caught later in gl_LightModelfv */
         ;
   }
   (*CC->API.LightModelfv)( CC, pname, fparam );
}


__asm __saveds void APIENTRY glLineWidth( register __fp0 GLfloat width )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.LineWidth)(CC, width);
}


__asm __saveds void APIENTRY glLineStipple( register __d0 GLint factor, register __d1 GLushort pattern )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.LineStipple)(CC, factor, pattern);
}


__asm __saveds void APIENTRY glListBase( register __d0 GLuint base )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.ListBase)(CC, base);
}


__asm __saveds void APIENTRY glLoadIdentity( void )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.LoadIdentity)( CC );
}


__asm __saveds void APIENTRY glLoadMatrixd( register __a0 const GLdouble *m )
{
   GLfloat fm[16];
   GLuint i;
   GET_CONTEXT;
   CHECK_CONTEXT;

   for (i=0;i<16;i++) {
	  fm[i] = (GLfloat) m[i];
   }

   (*CC->API.LoadMatrixf)( CC, fm );
}


__asm __saveds void APIENTRY glLoadMatrixf( register __a0 const GLfloat *m )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.LoadMatrixf)( CC, m );
}


__asm __saveds void APIENTRY glLoadName( register __d0 GLuint name )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.LoadName)(CC, name);
}


__asm __saveds void APIENTRY glLogicOp( register __d0 GLenum opcode )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.LogicOp)(CC, opcode);
}



__asm __saveds void APIENTRY glMap1dA(register __a0 void *vargs)
{
	struct glMap1dArgs {
		GLenum target;
		GLdouble u1;
		GLdouble u2;
		GLint stride;
		GLint order;
		GLdouble *points;
	} *args;

	args = (struct glMap1dArgs *)vargs;

	glMap1d(args->target, args->u1, args->u2, args->stride, args->order, args->points);
}


__asm __saveds void APIENTRY glMap1d( register __d0 GLenum target, register __fp0 GLdouble u1, register __fp1 GLdouble u2, register __d1 GLint stride,
                                      register __d2 GLint order, register __a0 const GLdouble *points )
{
   GLfloat *pnts;
   GLboolean retain;
   GET_CONTEXT;
   CHECK_CONTEXT;

   pnts = gl_copy_map_points1d( target, stride, order, points );
   retain = CC->CompileFlag;
   (*CC->API.Map1f)( CC, target, u1, u2, stride, order, pnts, retain );
}


__asm __saveds void APIENTRY glMap1fA(register __a0 void *vargs)
{
	struct glMap1fArgs {
		GLenum target;
		GLfloat u1;
		GLfloat u2;
		GLint stride;
		GLint order;
		GLfloat *points;
	} *args;

	args = (struct glMap1fArgs *)vargs;

	glMap1f(args->target, args->u1, args->u2, args->stride, args->order, args->points);
}


__asm __saveds void APIENTRY glMap1f( register __d0 GLenum target, register __fp0 GLfloat u1, register __fp1 GLfloat u2, register __d1 GLint stride,
                                      register __d2 GLint order, register __a0 const GLfloat *points )
{
   GLfloat *pnts;
   GLboolean retain;
   GET_CONTEXT;
   CHECK_CONTEXT;

   pnts = gl_copy_map_points1f( target, stride, order, points );
   retain = CC->CompileFlag;
   (*CC->API.Map1f)( CC, target, u1, u2, stride, order, pnts, retain );
}


__asm __saveds void APIENTRY glMap2dA(register __a0 void *vargs)
{
	struct glMap2dArgs {
		GLenum target;
		GLdouble u1;
		GLdouble u2;
		GLint ustride;
		GLint uorder;
		GLdouble v1;
		GLdouble v2;
		GLint vstride;
		GLint vorder;
		GLdouble *points;
	} *args;

	args = (struct glMap2dArgs *)vargs;

	glMap2d(args->target, args->u1, args->u2, args->ustride, args->uorder, args->v1, args->v2, args->vstride, args->vorder, args->points);
}


__asm __saveds void APIENTRY glMap2d( register __d0 GLenum target,
                                      register __fp0 GLdouble u1, register __fp1 GLdouble u2, register __d1 GLint ustride, register __d2 GLint uorder,
                                      register __fp2 GLdouble v1, register __fp3 GLdouble v2, register __d3 GLint vstride, register __d4 GLint vorder,
                                      register __a0 const GLdouble *points )
{
   GLfloat *pnts;
   GLboolean retain;
   GET_CONTEXT;
   CHECK_CONTEXT;

   pnts = gl_copy_map_points2d( target, ustride, uorder,
                                vstride, vorder, points );
   retain = CC->CompileFlag;
   (*CC->API.Map2f)( CC, target, u1, u2, ustride, uorder,
                     v1, v2, vstride, vorder, pnts, retain );
}


__asm __saveds void APIENTRY glMap2fA(register __a0 void *vargs)
{
	struct glMap2fArgs {
		GLenum target;
		GLfloat u1;
		GLfloat u2;
		GLint ustride;
		GLint uorder;
		GLfloat v1;
		GLfloat v2;
		GLint vstride;
		GLint vorder;
		GLfloat *points;
	} *args;

	args = (struct glMap2fArgs *)vargs;

	glMap2f(args->target, args->u1, args->u2, args->ustride, args->uorder, args->v1, args->v2, args->vstride, args->vorder, args->points);
}


__asm __saveds void APIENTRY glMap2f( register __d0 GLenum target,
                                      register __fp0 GLfloat u1, register __fp1 GLfloat u2, register __d1 GLint ustride, register __d2 GLint uorder,
                                      register __fp2 GLfloat v1, register __fp3 GLfloat v2, register __d3 GLint vstride, register __d4 GLint vorder,
                                      register __a0 const GLfloat *points )
{
   GLfloat *pnts;
   GLboolean retain;
   GET_CONTEXT;
   CHECK_CONTEXT;

   pnts = gl_copy_map_points2f( target, ustride, uorder,
                                vstride, vorder, points );
   retain = CC->CompileFlag;
   (*CC->API.Map2f)( CC, target, u1, u2, ustride, uorder,
                     v1, v2, vstride, vorder, pnts, retain );
}


__asm __saveds void APIENTRY glMapGrid1d( register __d0 GLint un, register __fp0 GLdouble u1, register __fp1 GLdouble u2 )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.MapGrid1f)( CC, un, (GLfloat) u1, (GLfloat) u2 );
}


__asm __saveds void APIENTRY glMapGrid1f( register __d0 GLint un, register __fp0 GLfloat u1, register __fp1 GLfloat u2 )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.MapGrid1f)( CC, un, u1, u2 );
}


__asm __saveds void APIENTRY glMapGrid2dA(register __a0 void *vargs)
{
	struct glMapGrid2dArgs {
		GLint un;
		GLdouble u1;
		GLdouble u2;
		GLint vn;
		GLdouble v1;
		GLdouble v2;
	} *args;

	args = (struct glMapGrid2dArgs *)vargs;

	glMapGrid2d(args->un, args->u1, args->u2, args->vn, args->v1, args->v2);
}


__asm __saveds void APIENTRY glMapGrid2d( register __d0 GLint un, register __fp0 GLdouble u1, register __fp1 GLdouble u2,
                                          register __d1 GLint vn, register __fp2 GLdouble v1, register __fp3 GLdouble v2 )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.MapGrid2f)( CC, un, (GLfloat) u1, (GLfloat) u2,
                         vn, (GLfloat) v1, (GLfloat) v2 );
}


__asm __saveds void APIENTRY glMapGrid2fA(register __a0 void *vargs)
{
	struct glMapGrid2fArgs {
		GLint un;
		GLfloat u1;
		GLfloat u2;
		GLint vn;
		GLfloat v1;
		GLfloat v2;
	} *args;

	args = (struct glMapGrid2fArgs *)vargs;

	glMapGrid2f(args->un, args->u1, args->u2, args->vn, args->v1, args->v2);
}


__asm __saveds void APIENTRY glMapGrid2f( register __d0 GLint un, register __fp0 GLfloat u1, register __fp1 GLfloat u2,
                                          register __d1 GLint vn, register __fp2 GLfloat v1, register __fp3 GLfloat v2 )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.MapGrid2f)( CC, un, u1, u2, vn, v1, v2 );
}


__asm __saveds void APIENTRY glMaterialf( register __d0 GLenum face, register __d1 GLenum pname, register __fp0 GLfloat param )
{
   GLfloat f = param;

   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.Materialfv)( CC, face, pname, &f );
}



__asm __saveds void APIENTRY glMateriali( register __d0 GLenum face, register __d1 GLenum pname, register __d2 GLint param )
{
   GLfloat fparam[4];
   GET_CONTEXT;
   CHECK_CONTEXT;
   fparam[0] = (GLfloat) param;
   (*CC->API.Materialfv)( CC, face, pname, fparam );
}


__asm __saveds void APIENTRY glMaterialfv( register __d0 GLenum face, register __d1 GLenum pname, register __a0 const GLfloat *params )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.Materialfv)( CC, face, pname, params );
}


__asm __saveds void APIENTRY glMaterialiv( register __d0 GLenum face, register __d1 GLenum pname, register __a0 const GLint *params )
{
   GLfloat fparam[4];
   GET_CONTEXT;
   CHECK_CONTEXT;
   switch (pname) {
      case GL_AMBIENT:
      case GL_DIFFUSE:
      case GL_SPECULAR:
      case GL_EMISSION:
      case GL_AMBIENT_AND_DIFFUSE:
         fparam[0] = INT_TO_FLOAT( params[0] );
         fparam[1] = INT_TO_FLOAT( params[1] );
         fparam[2] = INT_TO_FLOAT( params[2] );
         fparam[3] = INT_TO_FLOAT( params[3] );
         break;
      case GL_SHININESS:
         fparam[0] = (GLfloat) params[0];
         break;
      case GL_COLOR_INDEXES:
         fparam[0] = (GLfloat) params[0];
         fparam[1] = (GLfloat) params[1];
         fparam[2] = (GLfloat) params[2];
         break;
      default:
         /* Error will be caught later in gl_Materialfv */
         ;
   }
   (*CC->API.Materialfv)( CC, face, pname, fparam );
}


__asm __saveds void APIENTRY glMatrixMode( register __d0 GLenum mode )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.MatrixMode)( CC, mode );
}


__asm __saveds void APIENTRY glMultMatrixd( register __a0 const GLdouble *m )
{
   GLfloat fm[16];
   GLuint i;
   GET_CONTEXT;
   CHECK_CONTEXT;

   for (i=0;i<16;i++) {
	  fm[i] = (GLfloat) m[i];
   }

   (*CC->API.MultMatrixf)( CC, fm );
}


__asm __saveds void APIENTRY glMultMatrixf( register __a0 const GLfloat *m )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.MultMatrixf)( CC, m );
}


__asm __saveds void APIENTRY glNewList( register __d0 GLuint list, register __d1 GLenum mode )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.NewList)(CC, list, mode);
}

__asm __saveds void APIENTRY glNormal3b( register __d0 GLbyte nx, register __d1 GLbyte ny, register __d2 GLbyte nz )
{
   GET_CONTEXT;
   (*CC->API.Normal3f)( CC, BYTE_TO_FLOAT(nx),
                        BYTE_TO_FLOAT(ny), BYTE_TO_FLOAT(nz) );
}


__asm __saveds void APIENTRY glNormal3d( register __fp0 GLdouble nx, register __fp1 GLdouble ny, register __fp2 GLdouble nz )
{
   GLfloat fx, fy, fz;
   GET_CONTEXT;
   if (ABSD(nx)<0.00001)   fx = 0.0F;   else  fx = nx;
   if (ABSD(ny)<0.00001)   fy = 0.0F;   else  fy = ny;
   if (ABSD(nz)<0.00001)   fz = 0.0F;   else  fz = nz;
   (*CC->API.Normal3f)( CC, fx, fy, fz );
}


__asm __saveds void APIENTRY glNormal3f( register __fp0 GLfloat nx, register __fp1 GLfloat ny, register __fp2 GLfloat nz )
{
   GET_CONTEXT;
#ifdef SHORTCUT
   if (CC->CompileFlag) {
      (*CC->Save.Normal3f)( CC, nx, ny, nz );
   }
   else {
      /* Execute */
      CC->Current.Normal[0] = nx;
      CC->Current.Normal[1] = ny;
      CC->Current.Normal[2] = nz;
      CC->VB->MonoNormal = GL_FALSE;
   }
#else
   (*CC->API.Normal3f)( CC, nx, ny, nz );
#endif
}


__asm __saveds void APIENTRY glNormal3i( register __d0 GLint nx, register __d1 GLint ny, register __d2 GLint nz )
{
   GET_CONTEXT;
   (*CC->API.Normal3f)( CC, INT_TO_FLOAT(nx),
                        INT_TO_FLOAT(ny), INT_TO_FLOAT(nz) );
}


__asm __saveds void APIENTRY glNormal3s( register __d0 GLshort nx, register __d1 GLshort ny, register __d2 GLshort nz )
{
   GET_CONTEXT;
   (*CC->API.Normal3f)( CC, SHORT_TO_FLOAT(nx),
                        SHORT_TO_FLOAT(ny), SHORT_TO_FLOAT(nz) );
}


__asm __saveds void APIENTRY glNormal3bv( register __a0 const GLbyte *v )
{
   GET_CONTEXT;
   (*CC->API.Normal3f)( CC, BYTE_TO_FLOAT(v[0]),
                        BYTE_TO_FLOAT(v[1]), BYTE_TO_FLOAT(v[2]) );
}


__asm __saveds void APIENTRY glNormal3dv( register __a0 const GLdouble *v )
{
   GLfloat fx, fy, fz;
   GET_CONTEXT;
   if (ABSD(v[0])<0.00001)   fx = 0.0F;   else  fx = v[0];
   if (ABSD(v[1])<0.00001)   fy = 0.0F;   else  fy = v[1];
   if (ABSD(v[2])<0.00001)   fz = 0.0F;   else  fz = v[2];
   (*CC->API.Normal3f)( CC, fx, fy, fz );
}


__asm __saveds void APIENTRY glNormal3fv( register __a0 const GLfloat *v )
{
   GET_CONTEXT;
#ifdef SHORTCUT
   if (CC->CompileFlag) {
      (*CC->Save.Normal3fv)( CC, v );
   }
   else {
      /* Execute */
      GLfloat *n = CC->Current.Normal;
      n[0] = v[0];
      n[1] = v[1];
      n[2] = v[2];
      CC->VB->MonoNormal = GL_FALSE;
   }
#else
   (*CC->API.Normal3fv)( CC, v );
#endif
}


__asm __saveds void APIENTRY glNormal3iv( register __a0 const GLint *v )
{
   GET_CONTEXT;
   (*CC->API.Normal3f)( CC, INT_TO_FLOAT(v[0]),
                        INT_TO_FLOAT(v[1]), INT_TO_FLOAT(v[2]) );
}


__asm __saveds void APIENTRY glNormal3sv( register __a0 const GLshort *v )
{
   GET_CONTEXT;
   (*CC->API.Normal3f)( CC, SHORT_TO_FLOAT(v[0]),
                        SHORT_TO_FLOAT(v[1]), SHORT_TO_FLOAT(v[2]) );
}


__asm __saveds void APIENTRY glNormalPointer( register __d0 GLenum type, register __d1 GLsizei stride, register __a0 const GLvoid *ptr )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.NormalPointer)(CC, type, stride, ptr);
}

