/* $Id: api2.c,v 3.6 1998/08/21 02:43:52 brianp Exp $ */

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
 * File created from api2.c ver 1.9 and gl.h ver 1.26 using GenProtos
 *
 * Version 1.1  27 Jun 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * - Changed to v3.6 of api2.c
 *
 */


#ifdef PC_HEADER
#include "all.h"
#else
#include <stdio.h>
#include <stdlib.h>
#include "api.h"
#include "context.h"
#include "image.h"
#include "macros.h"
#include "matrix.h"
#include "teximage.h"
#include "types.h"
#include "vb.h"
#endif


/*
 * Part 2 of API functions
 */


__asm __saveds void APIENTRY glOrthoA(register __a0 void *vargs)
{
	struct glOrthoArgs {
		GLdouble left;
		GLdouble right;
		GLdouble bottom;
		GLdouble top;
		GLdouble nearval;
		GLdouble farval;
	} *args;

	args = (struct glOrthoArgs *)vargs;

	glOrtho(args->left, args->right, args->bottom, args->top, args->nearval, args->farval);
}


__asm __saveds void APIENTRY glOrtho( register __fp0 GLdouble left, register __fp1 GLdouble right,
                                      register __fp2 GLdouble bottom, register __fp3 GLdouble top,
                                      register __fp4 GLdouble nearval, register __fp5 GLdouble farval )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.Ortho)(CC, left, right, bottom, top, nearval, farval);
}


__asm __saveds void APIENTRY glPassThrough( register __fp0 GLfloat token )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.PassThrough)(CC, token);
}


__asm __saveds void APIENTRY glPixelMapfv( register __d0 GLenum map, register __d1 GLint mapsize, register __a0 const GLfloat *values )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.PixelMapfv)( CC, map, mapsize, values );
}


__asm __saveds void APIENTRY glPixelMapuiv( register __d0 GLenum map, register __d1 GLint mapsize, register __a0 const GLuint *values )
{
   GLfloat fvalues[MAX_PIXEL_MAP_TABLE];
   GLint i;
   GET_CONTEXT;
   CHECK_CONTEXT;

   if (map==GL_PIXEL_MAP_I_TO_I || map==GL_PIXEL_MAP_S_TO_S) {
      for (i=0;i<mapsize;i++) {
         fvalues[i] = (GLfloat) values[i];
      }
   }
   else {
      for (i=0;i<mapsize;i++) {
         fvalues[i] = UINT_TO_FLOAT( values[i] );
      }
   }
   (*CC->API.PixelMapfv)( CC, map, mapsize, fvalues );
}



__asm __saveds void APIENTRY glPixelMapusv( register __d0 GLenum map, register __d1 GLint mapsize, register __a0 const GLushort *values )
{
   GLfloat fvalues[MAX_PIXEL_MAP_TABLE];
   GLint i;
   GET_CONTEXT;
   CHECK_CONTEXT;

   if (map==GL_PIXEL_MAP_I_TO_I || map==GL_PIXEL_MAP_S_TO_S) {
      for (i=0;i<mapsize;i++) {
         fvalues[i] = (GLfloat) values[i];
      }
   }
   else {
      for (i=0;i<mapsize;i++) {
         fvalues[i] = USHORT_TO_FLOAT( values[i] );
      }
   }
   (*CC->API.PixelMapfv)( CC, map, mapsize, fvalues );
}


__asm __saveds void APIENTRY glPixelStoref( register __d0 GLenum pname, register __fp0 GLfloat param )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.PixelStorei)( CC, pname, (GLint) param );
}


__asm __saveds void APIENTRY glPixelStorei( register __d0 GLenum pname, register __d1 GLint param )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.PixelStorei)( CC, pname, param );
}


__asm __saveds void APIENTRY glPixelTransferf( register __d0 GLenum pname, register __fp0 GLfloat param )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.PixelTransferf)(CC, pname, param);
}


__asm __saveds void APIENTRY glPixelTransferi( register __d0 GLenum pname, register __d1 GLint param )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.PixelTransferf)(CC, pname, (GLfloat) param);
}


__asm __saveds void APIENTRY glPixelZoom( register __fp0 GLfloat xfactor, register __fp1 GLfloat yfactor )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.PixelZoom)(CC, xfactor, yfactor);
}


__asm __saveds void APIENTRY glPointSize( register __fp0 GLfloat size )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.PointSize)(CC, size);
}


__asm __saveds void APIENTRY glPolygonMode( register __d0 GLenum face, register __d1 GLenum mode )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.PolygonMode)(CC, face, mode);
}


__asm __saveds void APIENTRY glPolygonOffset( register __fp0 GLfloat factor, register __fp1 GLfloat units )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.PolygonOffset)( CC, factor, units );
}


/* GL_EXT_polygon_offset */
__asm __saveds void APIENTRY glPolygonOffsetEXT( register __fp0 GLfloat factor, register __fp1 GLfloat bias )
{
   glPolygonOffset( factor, bias * DEPTH_SCALE );
}


__asm __saveds void APIENTRY glPolygonStipple( register __a0 const GLubyte *pattern )
{
   GLuint unpackedPattern[32];
   GET_CONTEXT;
   CHECK_CONTEXT;
   gl_unpack_polygon_stipple( CC, pattern, unpackedPattern );
   (*CC->API.PolygonStipple)(CC, unpackedPattern);
}


__asm __saveds void APIENTRY glPopAttrib( void )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.PopAttrib)(CC);
}


__asm __saveds void APIENTRY glPopClientAttrib( void )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.PopClientAttrib)(CC);
}


__asm __saveds void APIENTRY glPopMatrix( void )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.PopMatrix)( CC );
}


__asm __saveds void APIENTRY glPopName( void )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.PopName)(CC);
}


__asm __saveds void APIENTRY glPrioritizeTextures( register __d0 GLsizei n, register __a0 const GLuint *textures,
                                                   register __a1 const GLclampf *priorities )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.PrioritizeTextures)(CC, n, textures, priorities);
}


__asm __saveds void APIENTRY glPushMatrix( void )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.PushMatrix)( CC );
}


__asm __saveds void APIENTRY glRasterPos2d( register __fp0 GLdouble x, register __fp1 GLdouble y )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.RasterPos4f)( CC, (GLfloat) x, (GLfloat) y, 0.0F, 1.0F );
}


__asm __saveds void APIENTRY glRasterPos2f( register __fp0 GLfloat x, register __fp1 GLfloat y )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.RasterPos4f)( CC, (GLfloat) x, (GLfloat) y, 0.0F, 1.0F );
}


__asm __saveds void APIENTRY glRasterPos2i( register __d0 GLint x, register __d1 GLint y )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.RasterPos4f)( CC, (GLfloat) x, (GLfloat) y, 0.0F, 1.0F );
}


__asm __saveds void APIENTRY glRasterPos2s( register __d0 GLshort x, register __d1 GLshort y )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.RasterPos4f)( CC, (GLfloat) x, (GLfloat) y, 0.0F, 1.0F );
}


__asm __saveds void APIENTRY glRasterPos3d( register __fp0 GLdouble x, register __fp1 GLdouble y, register __fp2 GLdouble z )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.RasterPos4f)( CC, (GLfloat) x, (GLfloat) y, (GLfloat) z, 1.0F );
}


__asm __saveds void APIENTRY glRasterPos3f( register __fp0 GLfloat x, register __fp1 GLfloat y, register __fp2 GLfloat z )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.RasterPos4f)( CC, (GLfloat) x, (GLfloat) y, (GLfloat) z, 1.0F );
}


__asm __saveds void APIENTRY glRasterPos3i( register __d0 GLint x, register __d1 GLint y, register __d2 GLint z )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.RasterPos4f)( CC, (GLfloat) x, (GLfloat) y, (GLfloat) z, 1.0F );
}


__asm __saveds void APIENTRY glRasterPos3s( register __d0 GLshort x, register __d1 GLshort y, register __d2 GLshort z )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.RasterPos4f)( CC, (GLfloat) x, (GLfloat) y, (GLfloat) z, 1.0F );
}


__asm __saveds void APIENTRY glRasterPos4d( register __fp0 GLdouble x, register __fp1 GLdouble y, register __fp2 GLdouble z, register __fp3 GLdouble w )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.RasterPos4f)( CC, (GLfloat) x, (GLfloat) y,
							   (GLfloat) z, (GLfloat) w );
}


__asm __saveds void APIENTRY glRasterPos4f( register __fp0 GLfloat x, register __fp1 GLfloat y, register __fp2 GLfloat z, register __fp3 GLfloat w )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.RasterPos4f)( CC, x, y, z, w );
}


__asm __saveds void APIENTRY glRasterPos4i( register __d0 GLint x, register __d1 GLint y, register __d2 GLint z, register __d3 GLint w )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.RasterPos4f)( CC, (GLfloat) x, (GLfloat) y,
                           (GLfloat) z, (GLfloat) w );
}


__asm __saveds void APIENTRY glRasterPos4s( register __d0 GLshort x, register __d1 GLshort y, register __d2 GLshort z, register __d3 GLshort w )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.RasterPos4f)( CC, (GLfloat) x, (GLfloat) y,
                           (GLfloat) z, (GLfloat) w );
}


__asm __saveds void APIENTRY glRasterPos2dv( register __a0 const GLdouble *v )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.RasterPos4f)( CC, (GLfloat) v[0], (GLfloat) v[1], 0.0F, 1.0F );
}


__asm __saveds void APIENTRY glRasterPos2fv( register __a0 const GLfloat *v )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.RasterPos4f)( CC, (GLfloat) v[0], (GLfloat) v[1], 0.0F, 1.0F );
}


__asm __saveds void APIENTRY glRasterPos2iv( register __a0 const GLint *v )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.RasterPos4f)( CC, (GLfloat) v[0], (GLfloat) v[1], 0.0F, 1.0F );
}


__asm __saveds void APIENTRY glRasterPos2sv( register __a0 const GLshort *v )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.RasterPos4f)( CC, (GLfloat) v[0], (GLfloat) v[1], 0.0F, 1.0F );
}


/*** 3 element vector ***/

__asm __saveds void APIENTRY glRasterPos3dv( register __a0 const GLdouble *v )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.RasterPos4f)( CC, (GLfloat) v[0], (GLfloat) v[1],
                           (GLfloat) v[2], 1.0F );
}


__asm __saveds void APIENTRY glRasterPos3fv( register __a0 const GLfloat *v )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.RasterPos4f)( CC, (GLfloat) v[0], (GLfloat) v[1],
                               (GLfloat) v[2], 1.0F );
}


__asm __saveds void APIENTRY glRasterPos3iv( register __a0 const GLint *v )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.RasterPos4f)( CC, (GLfloat) v[0], (GLfloat) v[1],
                           (GLfloat) v[2], 1.0F );
}


__asm __saveds void APIENTRY glRasterPos3sv( register __a0 const GLshort *v )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.RasterPos4f)( CC, (GLfloat) v[0], (GLfloat) v[1],
                           (GLfloat) v[2], 1.0F );
}


__asm __saveds void APIENTRY glRasterPos4dv( register __a0 const GLdouble *v )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.RasterPos4f)( CC, (GLfloat) v[0], (GLfloat) v[1],
                           (GLfloat) v[2], (GLfloat) v[3] );
}


__asm __saveds void APIENTRY glRasterPos4fv( register __a0 const GLfloat *v )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.RasterPos4f)( CC, v[0], v[1], v[2], v[3] );
}


__asm __saveds void APIENTRY glRasterPos4iv( register __a0 const GLint *v )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.RasterPos4f)( CC, (GLfloat) v[0], (GLfloat) v[1],
                           (GLfloat) v[2], (GLfloat) v[3] );
}


__asm __saveds void APIENTRY glRasterPos4sv( register __a0 const GLshort *v )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.RasterPos4f)( CC, (GLfloat) v[0], (GLfloat) v[1],
                           (GLfloat) v[2], (GLfloat) v[3] );
}


__asm __saveds void APIENTRY glReadBuffer( register __d0 GLenum mode )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.ReadBuffer)( CC, mode );
}


__asm __saveds void APIENTRY glReadPixels( register __d0 GLint x, register __d1 GLint y, register __d2 GLsizei width, register __d3 GLsizei height,
                                           register __d4 GLenum format, register __d5 GLenum type, register __a0 GLvoid *pixels )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.ReadPixels)( CC, x, y, width, height, format, type, pixels );
}


__asm __saveds void APIENTRY glRectd( register __fp0 GLdouble x1, register __fp1 GLdouble y1, register __fp2 GLdouble x2, register __fp3 GLdouble y2 )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.Rectf)( CC, (GLfloat) x1, (GLfloat) y1,
                     (GLfloat) x2, (GLfloat) y2 );
}


__asm __saveds void APIENTRY glRectf( register __fp0 GLfloat x1, register __fp1 GLfloat y1, register __fp2 GLfloat x2, register __fp3 GLfloat y2 )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.Rectf)( CC, x1, y1, x2, y2 );
}


__asm __saveds void APIENTRY glRecti( register __d0 GLint x1, register __d1 GLint y1, register __d2 GLint x2, register __d3 GLint y2 )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.Rectf)( CC, (GLfloat) x1, (GLfloat) y1,
                         (GLfloat) x2, (GLfloat) y2 );
}


__asm __saveds void APIENTRY glRects( register __d0 GLshort x1, register __d1 GLshort y1, register __d2 GLshort x2, register __d3 GLshort y2 )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.Rectf)( CC, (GLfloat) x1, (GLfloat) y1,
                     (GLfloat) x2, (GLfloat) y2 );
}


__asm __saveds void APIENTRY glRectdv( register __a0 const GLdouble *v1, register __a1 const GLdouble *v2 )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.Rectf)(CC, (GLfloat) v1[0], (GLfloat) v1[1],
                    (GLfloat) v2[0], (GLfloat) v2[1]);
}


__asm __saveds void APIENTRY glRectfv( register __a0 const GLfloat *v1, register __a1 const GLfloat *v2 )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.Rectf)(CC, v1[0], v1[1], v2[0], v2[1]);
}


__asm __saveds void APIENTRY glRectiv( register __a0 const GLint *v1, register __a1 const GLint *v2 )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.Rectf)( CC, (GLfloat) v1[0], (GLfloat) v1[1],
                     (GLfloat) v2[0], (GLfloat) v2[1] );
}


__asm __saveds void APIENTRY glRectsv( register __a0 const GLshort *v1, register __a1 const GLshort *v2 )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.Rectf)(CC, (GLfloat) v1[0], (GLfloat) v1[1],
        (GLfloat) v2[0], (GLfloat) v2[1]);
}


__asm __saveds void APIENTRY glScissor( register __d0 GLint x, register __d1 GLint y, register __d2 GLsizei width, register __d3 GLsizei height )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.Scissor)(CC, x, y, width, height);
}


__asm __saveds GLboolean APIENTRY glIsEnabled( register __d0 GLenum cap )
{
   GET_CONTEXT;
   CHECK_CONTEXT_RETURN(GL_FALSE);
   return (*CC->API.IsEnabled)( CC, cap );
}



__asm __saveds void APIENTRY glPushAttrib( register __d0 GLbitfield mask )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.PushAttrib)(CC, mask);
}


__asm __saveds void APIENTRY glPushClientAttrib( register __d0 GLbitfield mask )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.PushClientAttrib)(CC, mask);
}


__asm __saveds void APIENTRY glPushName( register __d0 GLuint name )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.PushName)(CC, name);
}


__asm __saveds GLint APIENTRY glRenderMode( register __d0 GLenum mode )
{
   GET_CONTEXT;
   CHECK_CONTEXT_RETURN(0);
   return (*CC->API.RenderMode)(CC, mode);
}


__asm __saveds void APIENTRY glRotated( register __fp0 GLdouble angle, register __fp1 GLdouble x, register __fp2 GLdouble y, register __fp3 GLdouble z )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.Rotatef)( CC, (GLfloat) angle,
                       (GLfloat) x, (GLfloat) y, (GLfloat) z );
}


__asm __saveds void APIENTRY glRotatef( register __fp0 GLfloat angle, register __fp1 GLfloat x, register __fp2 GLfloat y, register __fp3 GLfloat z )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.Rotatef)( CC, angle, x, y, z );
}


__asm __saveds void APIENTRY glSelectBuffer( register __d0 GLsizei size, register __a0 GLuint *buffer )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.SelectBuffer)(CC, size, buffer);
}


__asm __saveds void APIENTRY glScaled( register __fp0 GLdouble x, register __fp1 GLdouble y, register __fp2 GLdouble z )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.Scalef)( CC, (GLfloat) x, (GLfloat) y, (GLfloat) z );
}


__asm __saveds void APIENTRY glScalef( register __fp0 GLfloat x, register __fp1 GLfloat y, register __fp2 GLfloat z )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.Scalef)( CC, x, y, z );
}


__asm __saveds void APIENTRY glShadeModel( register __d0 GLenum mode )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.ShadeModel)(CC, mode);
}


__asm __saveds void APIENTRY glStencilFunc( register __d0 GLenum func, register __d1 GLint ref, register __d2 GLuint mask )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.StencilFunc)(CC, func, ref, mask);
}


__asm __saveds void APIENTRY glStencilMask( register __d0 GLuint mask )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.StencilMask)(CC, mask);
}


__asm __saveds void APIENTRY glStencilOp( register __d0 GLenum fail, register __d1 GLenum zfail, register __d2 GLenum zpass )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.StencilOp)(CC, fail, zfail, zpass);
}


__asm __saveds void APIENTRY glTexCoord1d( register __fp0 GLdouble s )
{
   GET_CONTEXT;
   (*CC->API.TexCoord4f)( CC, (GLfloat) s, 0.0, 0.0, 1.0 );
}


__asm __saveds void APIENTRY glTexCoord1f( register __fp0 GLfloat s )
{
   GET_CONTEXT;
   (*CC->API.TexCoord4f)( CC, s, 0.0, 0.0, 1.0 );
}


__asm __saveds void APIENTRY glTexCoord1i( register __d0 GLint s )
{
   GET_CONTEXT;
   (*CC->API.TexCoord4f)( CC, (GLfloat) s, 0.0, 0.0, 1.0 );
}


__asm __saveds void APIENTRY glTexCoord1s( register __d0 GLshort s )
{
   GET_CONTEXT;
   (*CC->API.TexCoord4f)( CC, (GLfloat) s, 0.0, 0.0, 1.0 );
}


__asm __saveds void APIENTRY glTexCoord2d( register __fp0 GLdouble s, register __fp1 GLdouble t )
{
   GET_CONTEXT;
   (*CC->API.TexCoord2f)( CC, (GLfloat) s, (GLfloat) t );
}


__asm __saveds void APIENTRY glTexCoord2f( register __fp0 GLfloat s, register __fp1 GLfloat t )
{
   GET_CONTEXT;
   (*CC->API.TexCoord2f)( CC, s, t );
}


__asm __saveds void APIENTRY glTexCoord2i( register __d0 GLint s, register __d1 GLint t )
{
   GET_CONTEXT;
   (*CC->API.TexCoord2f)( CC, (GLfloat) s, (GLfloat) t );
}


__asm __saveds void APIENTRY glTexCoord2s( register __d0 GLshort s, register __d1 GLshort t )
{
   GET_CONTEXT;
   (*CC->API.TexCoord2f)( CC, (GLfloat) s, (GLfloat) t );
}


__asm __saveds void APIENTRY glTexCoord3d( register __fp0 GLdouble s, register __fp1 GLdouble t, register __fp2 GLdouble r )
{
   GET_CONTEXT;
   (*CC->API.TexCoord4f)( CC, (GLfloat) s, (GLfloat) t, (GLfloat) r, 1.0 );
}


__asm __saveds void APIENTRY glTexCoord3f( register __fp0 GLfloat s, register __fp1 GLfloat t, register __fp2 GLfloat r )
{
   GET_CONTEXT;
   (*CC->API.TexCoord4f)( CC, s, t, r, 1.0 );
}


__asm __saveds void APIENTRY glTexCoord3i( register __d0 GLint s, register __d1 GLint t, register __d2 GLint r )
{
   GET_CONTEXT;
   (*CC->API.TexCoord4f)( CC, (GLfloat) s, (GLfloat) t,
                               (GLfloat) r, 1.0 );
}


__asm __saveds void APIENTRY glTexCoord3s( register __d0 GLshort s, register __d1 GLshort t, register __d2 GLshort r )
{
   GET_CONTEXT;
   (*CC->API.TexCoord4f)( CC, (GLfloat) s, (GLfloat) t,
                               (GLfloat) r, 1.0 );
}


__asm __saveds void APIENTRY glTexCoord4d( register __fp0 GLdouble s, register __fp1 GLdouble t, register __fp2 GLdouble r, register __fp3 GLdouble q )
{
   GET_CONTEXT;
   (*CC->API.TexCoord4f)( CC, (GLfloat) s, (GLfloat) t,
                               (GLfloat) r, (GLfloat) q );
}


__asm __saveds void APIENTRY glTexCoord4f( register __fp0 GLfloat s, register __fp1 GLfloat t, register __fp2 GLfloat r, register __fp3 GLfloat q )
{
   GET_CONTEXT;
   (*CC->API.TexCoord4f)( CC, s, t, r, q );
}


__asm __saveds void APIENTRY glTexCoord4i( register __d0 GLint s, register __d1 GLint t, register __d2 GLint r, register __d3 GLint q )
{
   GET_CONTEXT;
   (*CC->API.TexCoord4f)( CC, (GLfloat) s, (GLfloat) t,
                               (GLfloat) r, (GLfloat) q );
}


__asm __saveds void APIENTRY glTexCoord4s( register __d0 GLshort s, register __d1 GLshort t, register __d2 GLshort r, register __d3 GLshort q )
{
   GET_CONTEXT;
   (*CC->API.TexCoord4f)( CC, (GLfloat) s, (GLfloat) t,
                               (GLfloat) r, (GLfloat) q );
}


__asm __saveds void APIENTRY glTexCoord1dv( register __a0 const GLdouble *v )
{
   GET_CONTEXT;
   (*CC->API.TexCoord4f)( CC, (GLfloat) *v, 0.0, 0.0, 1.0 );
}


__asm __saveds void APIENTRY glTexCoord1fv( register __a0 const GLfloat *v )
{
   GET_CONTEXT;
   (*CC->API.TexCoord4f)( CC, *v, 0.0, 0.0, 1.0 );
}


__asm __saveds void APIENTRY glTexCoord1iv( register __a0 const GLint *v )
{
   GET_CONTEXT;
   (*CC->API.TexCoord4f)( CC, *v, 0.0, 0.0, 1.0 );
}


__asm __saveds void APIENTRY glTexCoord1sv( register __a0 const GLshort *v )
{
   GET_CONTEXT;
   (*CC->API.TexCoord4f)( CC, (GLfloat) *v, 0.0, 0.0, 1.0 );
}


__asm __saveds void APIENTRY glTexCoord2dv( register __a0 const GLdouble *v )
{
   GET_CONTEXT;
   (*CC->API.TexCoord2f)( CC, (GLfloat) v[0], (GLfloat) v[1] );
}


__asm __saveds void APIENTRY glTexCoord2fv( register __a0 const GLfloat *v )
{
   GET_CONTEXT;
   (*CC->API.TexCoord2f)( CC, v[0], v[1] );
}


__asm __saveds void APIENTRY glTexCoord2iv( register __a0 const GLint *v )
{
   GET_CONTEXT;
   (*CC->API.TexCoord2f)( CC, (GLfloat) v[0], (GLfloat) v[1] );
}


__asm __saveds void APIENTRY glTexCoord2sv( register __a0 const GLshort *v )
{
   GET_CONTEXT;
   (*CC->API.TexCoord2f)( CC, (GLfloat) v[0], (GLfloat) v[1] );
}


__asm __saveds void APIENTRY glTexCoord3dv( register __a0 const GLdouble *v )
{
   GET_CONTEXT;
   (*CC->API.TexCoord4f)( CC, (GLfloat) v[0], (GLfloat) v[1],
                               (GLfloat) v[2], 1.0 );
}


__asm __saveds void APIENTRY glTexCoord3fv( register __a0 const GLfloat *v )
{
   GET_CONTEXT;
   (*CC->API.TexCoord4f)( CC, v[0], v[1], v[2], 1.0 );
}


__asm __saveds void APIENTRY glTexCoord3iv( register __a0 const GLint *v )
{
   GET_CONTEXT;
   (*CC->API.TexCoord4f)( CC, (GLfloat) v[0], (GLfloat) v[1],
                          (GLfloat) v[2], 1.0 );
}


__asm __saveds void APIENTRY glTexCoord3sv( register __a0 const GLshort *v )
{
   GET_CONTEXT;
   (*CC->API.TexCoord4f)( CC, (GLfloat) v[0], (GLfloat) v[1],
                               (GLfloat) v[2], 1.0 );
}


__asm __saveds void APIENTRY glTexCoord4dv( register __a0 const GLdouble *v )
{
   GET_CONTEXT;
   (*CC->API.TexCoord4f)( CC, (GLfloat) v[0], (GLfloat) v[1],
                               (GLfloat) v[2], (GLfloat) v[3] );
}


__asm __saveds void APIENTRY glTexCoord4fv( register __a0 const GLfloat *v )
{
   GET_CONTEXT;
   (*CC->API.TexCoord4f)( CC, v[0], v[1], v[2], v[3] );
}


__asm __saveds void APIENTRY glTexCoord4iv( register __a0 const GLint *v )
{
   GET_CONTEXT;
   (*CC->API.TexCoord4f)( CC, (GLfloat) v[0], (GLfloat) v[1],
                               (GLfloat) v[2], (GLfloat) v[3] );
}


__asm __saveds void APIENTRY glTexCoord4sv( register __a0 const GLshort *v )
{
   GET_CONTEXT;
   (*CC->API.TexCoord4f)( CC, (GLfloat) v[0], (GLfloat) v[1],
                               (GLfloat) v[2], (GLfloat) v[3] );
}


__asm __saveds void APIENTRY glTexCoordPointer( register __d0 GLint size, register __d1 GLenum type, register __d2 GLsizei stride,
                                                register __a0 const GLvoid *ptr )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.TexCoordPointer)(CC, size, type, stride, ptr);
}


__asm __saveds void APIENTRY glTexGend( register __d0 GLenum coord, register __d1 GLenum pname, register __fp0 GLdouble param )
{
   GLfloat p = (GLfloat) param;
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.TexGenfv)( CC, coord, pname, &p );
}


__asm __saveds void APIENTRY glTexGenf( register __d0 GLenum coord, register __d1 GLenum pname, register __fp0 GLfloat param )
{
   GLfloat f = param;

   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.TexGenfv)( CC, coord, pname, &f );
}


__asm __saveds void APIENTRY glTexGeni( register __d0 GLenum coord, register __d1 GLenum pname, register __d2 GLint param )
{
   GLfloat p = (GLfloat) param;
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.TexGenfv)( CC, coord, pname, &p );
}


__asm __saveds void APIENTRY glTexGendv( register __d0 GLenum coord, register __d1 GLenum pname, register __a0 const GLdouble *params )
{
   GLfloat p[4];
   GET_CONTEXT;
   CHECK_CONTEXT;
   p[0] = params[0];
   p[1] = params[1];
   p[2] = params[2];
   p[3] = params[3];
   (*CC->API.TexGenfv)( CC, coord, pname, p );
}


__asm __saveds void APIENTRY glTexGeniv( register __d0 GLenum coord, register __d1 GLenum pname, register __a0 const GLint *params )
{
   GLfloat p[4];
   GET_CONTEXT;
   CHECK_CONTEXT;
   p[0] = params[0];
   p[1] = params[1];
   p[2] = params[2];
   p[3] = params[3];
   (*CC->API.TexGenfv)( CC, coord, pname, p );
}


__asm __saveds void APIENTRY glTexGenfv( register __d0 GLenum coord, register __d1 GLenum pname, register __a0 const GLfloat *params )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.TexGenfv)( CC, coord, pname, params );
}




__asm __saveds void APIENTRY glTexEnvf( register __d0 GLenum target, register __d1 GLenum pname, register __fp0 GLfloat param )
{
   GLfloat f = param;

   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.TexEnvfv)( CC, target, pname, &f );
}



__asm __saveds void APIENTRY glTexEnvi( register __d0 GLenum target, register __d1 GLenum pname, register __d2 GLint param )
{
   GLfloat p[4];
   GET_CONTEXT;
   p[0] = (GLfloat) param;
   p[1] = p[2] = p[3] = 0.0;
   CHECK_CONTEXT;
   (*CC->API.TexEnvfv)( CC, target, pname, p );
}



__asm __saveds void APIENTRY glTexEnvfv( register __d0 GLenum target, register __d1 GLenum pname, register __a0 const GLfloat *param )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.TexEnvfv)( CC, target, pname, param );
}



__asm __saveds void APIENTRY glTexEnviv( register __d0 GLenum target, register __d1 GLenum pname, register __a0 const GLint *param )
{
   GLfloat p[4];
   GET_CONTEXT;
   p[0] = INT_TO_FLOAT( param[0] );
   p[1] = INT_TO_FLOAT( param[1] );
   p[2] = INT_TO_FLOAT( param[2] );
   p[3] = INT_TO_FLOAT( param[3] );
   CHECK_CONTEXT;
   (*CC->API.TexEnvfv)( CC, target, pname, p );
}


__asm __saveds void APIENTRY glTexImage1D( register __d0 GLenum target, register __d1 GLint level, register __d2 GLint internalformat,
                                           register __d3 GLsizei width, register __d4 GLint border,
                                           register __d5 GLenum format, register __d6 GLenum type, register __a0 const GLvoid *pixels )
{
   struct gl_image *teximage;
   GET_CONTEXT;
   CHECK_CONTEXT;
   teximage = gl_unpack_image( CC, width, 1, format, type, pixels );
   (*CC->API.TexImage1D)( CC, target, level, internalformat,
                          width, border, format, type, teximage );
}



__asm __saveds void APIENTRY glTexImage2D( register __d0 GLenum target, register __d1 GLint level, register __d2 GLint internalformat,
                                           register __d3 GLsizei width, register __d4 GLsizei height, register __d5 GLint border,
                                           register __d6 GLenum format, register __d7 GLenum type, register __a0 const GLvoid *pixels )
{
  struct gl_image *teximage;
#if defined(FX) && defined(__WIN32__)
  GLvoid *newpixels=NULL;
  GLsizei newwidth,newheight;
  GLint x,y;
  static GLint leveldif=0;
  static GLuint lasttexobj=0;
#endif
  GET_CONTEXT;
  CHECK_CONTEXT;

#if defined(FX) && defined(__WIN32__)
  newpixels=NULL;

  /* AN HACK for WinGLQuake*/

  if (CC->Texture.Set[0].Current2D->Name!=lasttexobj) {
    lasttexobj=CC->Texture.Set[0].Current2D->Name;
    leveldif=0;
  }

  if ((format==GL_COLOR_INDEX) && (internalformat==1))
    internalformat=GL_COLOR_INDEX8_EXT;

  if (width>256 || height>256) {
    newpixels=malloc((width+4)*height*4);

    while (width>256 || height>256) {
      newwidth=width/2;
      newheight=height/2;
      leveldif++;

      fprintf(stderr,"Scaling: (%d) %dx%d -> %dx%d\n",internalformat,width,height,newwidth,newheight);
      fflush(stderr);

      for(y=0;y<newheight;y++)
	for(x=0;x<newwidth;x++) {
	  ((GLubyte *)newpixels)[(x+y*newwidth)*4+0]=((GLubyte *)pixels)[(x*2+y*width*2)*4+0];
	  ((GLubyte *)newpixels)[(x+y*newwidth)*4+1]=((GLubyte *)pixels)[(x*2+y*width*2)*4+1];
	  ((GLubyte *)newpixels)[(x+y*newwidth)*4+2]=((GLubyte *)pixels)[(x*2+y*width*2)*4+2];
	  ((GLubyte *)newpixels)[(x+y*newwidth)*4+3]=((GLubyte *)pixels)[(x*2+y*width*2)*4+3];
	}

      pixels=newpixels;
      width=newwidth;
      height=newheight;
    }

    level=0;
  } else
    level-=leveldif;
#endif
  teximage = gl_unpack_image( CC, width, height, format, type, pixels );
  (*CC->API.TexImage2D)( CC, target, level, internalformat,
			 width, height, border, format, type, teximage );
#if defined(FX) && defined(__WIN32__)
  if(newpixels)
    free(newpixels);
#endif
}


__asm __saveds void APIENTRY glTexImage3D( register __d0 GLenum target, register __d1 GLint level,
                                           register __d2 GLenum internalformat,
                                           register __d3 GLsizei width, register __d4 GLsizei height,
                                           register __d5 GLsizei depth, register __d6 GLint border,
                                           register __d7 GLenum format, register __a0 GLenum type,
                                           register __a1 const GLvoid *pixels )
{
   struct gl_image *teximage;
   GET_CONTEXT;
   CHECK_CONTEXT;
   teximage = gl_unpack_image3D( CC, width, height, depth, format, type, pixels);
   (*CC->API.TexImage3DEXT)( CC, target, level, internalformat,
                             width, height, depth, border, format, type,
                             teximage );
}


__asm __saveds void APIENTRY glTexParameterf( register __d0 GLenum target, register __d1 GLenum pname, register __fp0 GLfloat param )
{
   GLfloat f = param;

   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.TexParameterfv)( CC, target, pname, &f );
}


__asm __saveds void APIENTRY glTexParameteri( register __d0 GLenum target, register __d1 GLenum pname, register __d2 GLint param )
{
   GLfloat fparam[4];
   GET_CONTEXT;
   fparam[0] = (GLfloat) param;
   fparam[1] = fparam[2] = fparam[3] = 0.0;
   CHECK_CONTEXT;
   (*CC->API.TexParameterfv)( CC, target, pname, fparam );
}


__asm __saveds void APIENTRY glTexParameterfv( register __d0 GLenum target, register __d1 GLenum pname, register __a0 const GLfloat *params )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.TexParameterfv)( CC, target, pname, params );
}


__asm __saveds void APIENTRY glTexParameteriv( register __d0 GLenum target, register __d1 GLenum pname, register __a0 const GLint *params )
{
   GLfloat p[4];
   GET_CONTEXT;
   CHECK_CONTEXT;
   if (pname==GL_TEXTURE_BORDER_COLOR) {
      p[0] = INT_TO_FLOAT( params[0] );
      p[1] = INT_TO_FLOAT( params[1] );
      p[2] = INT_TO_FLOAT( params[2] );
      p[3] = INT_TO_FLOAT( params[3] );
   }
   else {
      p[0] = (GLfloat) params[0];
      p[1] = (GLfloat) params[1];
      p[2] = (GLfloat) params[2];
      p[3] = (GLfloat) params[3];
   }
   (*CC->API.TexParameterfv)( CC, target, pname, p );
}


__asm __saveds void APIENTRY glTexSubImage1D( register __d0 GLenum target, register __d1 GLint level, register __d2 GLint xoffset,
                                              register __d3 GLsizei width, register __d4 GLenum format,
                                              register __d5 GLenum type, register __a0 const GLvoid *pixels )
{
   struct gl_image *image;
   GET_CONTEXT;
   CHECK_CONTEXT;
   image = gl_unpack_texsubimage( CC, width, 1, format, type, pixels );
   (*CC->API.TexSubImage1D)( CC, target, level, xoffset, width,
                             format, type, image );
}


__asm __saveds void APIENTRY glTexSubImage2D( register __d0 GLenum target, register __d1 GLint level,
                                              register __d2 GLint xoffset, register __d3 GLint yoffset,
                                              register __d4 GLsizei width, register __d5 GLsizei height,
                                              register __d6 GLenum format, register __d7 GLenum type,
                                              register __a0 const GLvoid *pixels )
{
   struct gl_image *image;
   GET_CONTEXT;
   CHECK_CONTEXT;
   image = gl_unpack_texsubimage( CC, width, height, format, type, pixels );
   (*CC->API.TexSubImage2D)( CC, target, level, xoffset, yoffset,
                             width, height, format, type, image );
}


__asm __saveds void APIENTRY glTexSubImage3D( register __d0 GLenum target, register __d1 GLint level,
                                              register __d2 GLint xoffset, register __d3 GLint yoffset,
                                              register __d4 GLint zoffset, register __d5 GLsizei width,
                                              register __d6 GLsizei height, register __d7 GLsizei depth,
                                              register __a0 GLenum format,
                                              register __a1 GLenum type, register __a2 const GLvoid *pixels )
{
   struct gl_image *image;
   GET_CONTEXT;
   CHECK_CONTEXT;
   image = gl_unpack_texsubimage3D( CC, width, height, depth, format, type,
                                    pixels );
   (*CC->API.TexSubImage3DEXT)( CC, target, level, xoffset, yoffset, zoffset,
                                width, height, depth, format, type, image );
}


__asm __saveds void APIENTRY glTranslated( register __fp0 GLdouble x, register __fp1 GLdouble y, register __fp2 GLdouble z )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.Translatef)( CC, (GLfloat) x, (GLfloat) y, (GLfloat) z );
}


__asm __saveds void APIENTRY glTranslatef( register __fp0 GLfloat x, register __fp1 GLfloat y, register __fp2 GLfloat z )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.Translatef)( CC, x, y, z );
}


__asm __saveds void APIENTRY glVertex2d( register __fp0 GLdouble x, register __fp1 GLdouble y )
{
   GET_CONTEXT;
   (*CC->API.Vertex2f)( CC, (GLfloat) x, (GLfloat) y );
}


__asm __saveds void APIENTRY glVertex2f( register __fp0 GLfloat x, register __fp1 GLfloat y )
{
   GET_CONTEXT;
   (*CC->API.Vertex2f)( CC, x, y );
}


__asm __saveds void APIENTRY glVertex2i( register __d0 GLint x, register __d1 GLint y )
{
   GET_CONTEXT;
   (*CC->API.Vertex2f)( CC, (GLfloat) x, (GLfloat) y );
}


__asm __saveds void APIENTRY glVertex2s( register __d0 GLshort x, register __d1 GLshort y )
{
   GET_CONTEXT;
   (*CC->API.Vertex2f)( CC, (GLfloat) x, (GLfloat) y );
}


__asm __saveds void APIENTRY glVertex3d( register __fp0 GLdouble x, register __fp1 GLdouble y, register __fp2 GLdouble z )
{
   GET_CONTEXT;
   (*CC->API.Vertex3f)( CC, (GLfloat) x, (GLfloat) y, (GLfloat) z );
}


__asm __saveds void APIENTRY glVertex3f( register __fp0 GLfloat x, register __fp1 GLfloat y, register __fp2 GLfloat z )
{
   GET_CONTEXT;
   (*CC->API.Vertex3f)( CC, x, y, z );
}


__asm __saveds void APIENTRY glVertex3i( register __d0 GLint x, register __d1 GLint y, register __d2 GLint z )
{
   GET_CONTEXT;
   (*CC->API.Vertex3f)( CC, (GLfloat) x, (GLfloat) y, (GLfloat) z );
}


__asm __saveds void APIENTRY glVertex3s( register __d0 GLshort x, register __d1 GLshort y, register __d2 GLshort z )
{
   GET_CONTEXT;
   (*CC->API.Vertex3f)( CC, (GLfloat) x, (GLfloat) y, (GLfloat) z );
}


__asm __saveds void APIENTRY glVertex4d( register __fp0 GLdouble x, register __fp1 GLdouble y, register __fp2 GLdouble z, register __fp3 GLdouble w )
{
   GET_CONTEXT;
   (*CC->API.Vertex4f)( CC, (GLfloat) x, (GLfloat) y,
                            (GLfloat) z, (GLfloat) w );
}


__asm __saveds void APIENTRY glVertex4f( register __fp0 GLfloat x, register __fp1 GLfloat y, register __fp2 GLfloat z, register __fp3 GLfloat w )
{
   GET_CONTEXT;
   (*CC->API.Vertex4f)( CC, x, y, z, w );
}


__asm __saveds void APIENTRY glVertex4i( register __d0 GLint x, register __d1 GLint y, register __d2 GLint z, register __d3 GLint w )
{
   GET_CONTEXT;
   (*CC->API.Vertex4f)( CC, (GLfloat) x, (GLfloat) y,
                            (GLfloat) z, (GLfloat) w );
}


__asm __saveds void APIENTRY glVertex4s( register __d0 GLshort x, register __d1 GLshort y, register __d2 GLshort z, register __d3 GLshort w )
{
   GET_CONTEXT;
   (*CC->API.Vertex4f)( CC, (GLfloat) x, (GLfloat) y,
                            (GLfloat) z, (GLfloat) w );
}


__asm __saveds void APIENTRY glVertex2dv( register __a0 const GLdouble *v )
{
   GET_CONTEXT;
   (*CC->API.Vertex2f)( CC, (GLfloat) v[0], (GLfloat) v[1] );
}


__asm __saveds void APIENTRY glVertex2fv( register __a0 const GLfloat *v )
{
   GET_CONTEXT;
   (*CC->API.Vertex2f)( CC, v[0], v[1] );
}


__asm __saveds void APIENTRY glVertex2iv( register __a0 const GLint *v )
{
   GET_CONTEXT;
   (*CC->API.Vertex2f)( CC, (GLfloat) v[0], (GLfloat) v[1] );
}


__asm __saveds void APIENTRY glVertex2sv( register __a0 const GLshort *v )
{
   GET_CONTEXT;
   (*CC->API.Vertex2f)( CC, (GLfloat) v[0], (GLfloat) v[1] );
}


__asm __saveds void APIENTRY glVertex3dv( register __a0 const GLdouble *v )
{
   GET_CONTEXT;
   (*CC->API.Vertex3f)( CC, (GLfloat) v[0], (GLfloat) v[1], (GLfloat) v[2] );
}


__asm __saveds void APIENTRY glVertex3fv( register __a0 const GLfloat *v )
{
   GET_CONTEXT;
   (*CC->API.Vertex3fv)( CC, v );
}


__asm __saveds void APIENTRY glVertex3iv( register __a0 const GLint *v )
{
   GET_CONTEXT;
   (*CC->API.Vertex3f)( CC, (GLfloat) v[0], (GLfloat) v[1], (GLfloat) v[2] );
}


__asm __saveds void APIENTRY glVertex3sv( register __a0 const GLshort *v )
{
   GET_CONTEXT;
   (*CC->API.Vertex3f)( CC, (GLfloat) v[0], (GLfloat) v[1], (GLfloat) v[2] );
}


__asm __saveds void APIENTRY glVertex4dv( register __a0 const GLdouble *v )
{
   GET_CONTEXT;
   (*CC->API.Vertex4f)( CC, (GLfloat) v[0], (GLfloat) v[1],
                            (GLfloat) v[2], (GLfloat) v[3] );
}


__asm __saveds void APIENTRY glVertex4fv( register __a0 const GLfloat *v )
{
   GET_CONTEXT;
   (*CC->API.Vertex4f)( CC, v[0], v[1], v[2], v[3] );
}


__asm __saveds void APIENTRY glVertex4iv( register __a0 const GLint *v )
{
   GET_CONTEXT;
   (*CC->API.Vertex4f)( CC, (GLfloat) v[0], (GLfloat) v[1],
                            (GLfloat) v[2], (GLfloat) v[3] );
}


__asm __saveds void APIENTRY glVertex4sv( register __a0 const GLshort *v )
{
   GET_CONTEXT;
   (*CC->API.Vertex4f)( CC, (GLfloat) v[0], (GLfloat) v[1],
                            (GLfloat) v[2], (GLfloat) v[3] );
}


__asm __saveds void APIENTRY glVertexPointer( register __d0 GLint size, register __d1 GLenum type, register __d2 GLsizei stride,
                                              register __a0 const GLvoid *ptr )
{
   GET_CONTEXT;
   (*CC->API.VertexPointer)(CC, size, type, stride, ptr);
}


__asm __saveds void APIENTRY glViewport( register __d0 GLint x, register __d1 GLint y, register __d2 GLsizei width, register __d3 GLsizei height )
{
   GET_CONTEXT;
   (*CC->API.Viewport)( CC, x, y, width, height );
}



