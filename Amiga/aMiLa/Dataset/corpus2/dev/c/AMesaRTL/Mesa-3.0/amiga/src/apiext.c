/* $Id: apiext.c,v 3.2 1998/06/07 22:18:52 brianp Exp $ */

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
 * apiext.c
 *
 * Version 1.0  04 Oct 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * File created from apiext.c ver 3.2 and gl.h ver 3.19 using GenProtos
 *
 */


#ifdef PC_HEADER
#include "all.h"
#else
#include <stdio.h>
#include <stdlib.h>
#include "api.h"
#include "context.h"
#include "types.h"
#endif



/*
 * Extension API functions
 */



/*
 * GL_EXT_blend_minmax
 */

__asm __saveds void APIENTRY glBlendEquationEXT( register __d0 GLenum mode )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.BlendEquation)(CC, mode);
}




/*
 * GL_EXT_blend_color
 */

__asm __saveds void APIENTRY glBlendColorEXT( register __fp0 GLclampf red, register __fp1 GLclampf green,
                                              register __fp2 GLclampf blue, register __fp3 GLclampf alpha )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.BlendColor)(CC, red, green, blue, alpha);
}




/*
 * GL_EXT_vertex_array
 */

__asm __saveds void APIENTRY glVertexPointerEXT( register __d0 GLint size, register __d1 GLenum type, register __d2 GLsizei stride,
                                                 register __d3 GLsizei count, register __a0 const GLvoid *ptr )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.VertexPointer)(CC, size, type, stride, ptr);
   (void) count;
}


__asm __saveds void APIENTRY glNormalPointerEXT( register __d0 GLenum type, register __d1 GLsizei stride, register __d2 GLsizei count,
                                                 register __a0 const GLvoid *ptr )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.NormalPointer)(CC, type, stride, ptr);
   (void) count;
}


__asm __saveds void APIENTRY glColorPointerEXT( register __d0 GLint size, register __d1 GLenum type, register __d2 GLsizei stride,
                                                register __d3 GLsizei count, register __a0 const GLvoid *ptr )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.ColorPointer)(CC, size, type, stride, ptr);
   (void) count;
}


__asm __saveds void APIENTRY glIndexPointerEXT( register __d0 GLenum type, register __d1 GLsizei stride,
                                                register __d2 GLsizei count, register __a0 const GLvoid *ptr )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.IndexPointer)(CC, type, stride, ptr);
   (void) count;
}


__asm __saveds void APIENTRY glTexCoordPointerEXT( register __d0 GLint size, register __d1 GLenum type, register __d2 GLsizei stride,
                                                   register __d3 GLsizei count, register __a0 const GLvoid *ptr )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.TexCoordPointer)(CC, size, type, stride, ptr);
   (void) count;
}


__asm __saveds void APIENTRY glEdgeFlagPointerEXT( register __d0 GLsizei stride, register __d1 GLsizei count,
                                                   register __a0 const GLboolean *ptr )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.EdgeFlagPointer)(CC, stride, ptr);
   (void) count;
}


__asm __saveds void APIENTRY glGetPointervEXT( register __d0 GLenum pname, register __a0 GLvoid **params )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.GetPointerv)(CC, pname, params);
}


__asm __saveds void APIENTRY glArrayElementEXT( register __d0 GLint i )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.ArrayElement)(CC, i);
}


__asm __saveds void APIENTRY glDrawArraysEXT( register __d0 GLenum mode, register __d1 GLint first, register __d2 GLsizei count )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.DrawArrays)(CC, mode, first, count);
}




/*
 * GL_EXT_texture_object
 */

__asm __saveds GLboolean APIENTRY glAreTexturesResidentEXT( register __d0 GLsizei n, register __a0 const GLuint *textures,
                                                            register __a1 GLboolean *residences )
{
   return glAreTexturesResident( n, textures, residences );
}


__asm __saveds void APIENTRY glBindTextureEXT( register __d0 GLenum target, register __d1 GLuint texture )
{
   glBindTexture( target, texture );
}


__asm __saveds void APIENTRY glDeleteTexturesEXT( register __d0 GLsizei n, register __a0 const GLuint *textures )
{
   glDeleteTextures( n, textures );
}


__asm __saveds void APIENTRY glGenTexturesEXT( register __d0 GLsizei n, register __a0 GLuint *textures )
{
   glGenTextures( n, textures );
}


__asm __saveds GLboolean APIENTRY glIsTextureEXT( register __d0 GLuint texture )
{
   return glIsTexture( texture );
}


__asm __saveds void APIENTRY glPrioritizeTexturesEXT( register __d0 GLsizei n, register __a0 const GLuint *textures,
                                                      register __a1 const GLclampf *priorities )
{
   glPrioritizeTextures( n, textures, priorities );
}




/*
 * GL_EXT_texture3D
 */

__asm __saveds void APIENTRY glCopyTexSubImage3DEXT( register __d0 GLenum target, register __d1 GLint level, register __d2 GLint xoffset,
                                                     register __d3 GLint yoffset, register __d4 GLint zoffset,
                                                     register __d5 GLint x, register __d6 GLint y, register __d7 GLsizei width,
                                                     register __a0 GLsizei height )
{
   glCopyTexSubImage3D(target, level, xoffset, yoffset, zoffset,
                       x, y, width, height);
}



__asm __saveds void APIENTRY glTexImage3DEXT( register __d0 GLenum target, register __d1 GLint level, register __d2 GLenum internalformat,
                                              register __d3 GLsizei width, register __d4 GLsizei height, register __d5 GLsizei depth,
                                              register __d6 GLint border, register __d7 GLenum format, register __a0 GLenum type,
                                              register __a1 const GLvoid *pixels )
{
   glTexImage3D(target, level, internalformat, width, height, depth,
                border, format, type, pixels);
}


__asm __saveds void APIENTRY glTexSubImage3DEXT( register __d0 GLenum target, register __d1 GLint level, register __d2 GLint xoffset,
                                                 register __d3 GLint yoffset, register __d4 GLint zoffset, register __d5 GLsizei width,
                                                 register __d6 GLsizei height, register __d7 GLsizei depth, register __a0 GLenum format,
                                                 register __a1 GLenum type, register __a2 const GLvoid *pixels )
{
   glTexSubImage3D(target, level, xoffset, yoffset, zoffset,
                   width, height, depth, format, type, pixels);
}




/*
 * GL_EXT_point_parameters
 */

__asm __saveds void APIENTRY glPointParameterfEXT( register __d0 GLenum pname, register __fp0 GLfloat param )
{
   GLfloat params[3];
   GET_CONTEXT;
   CHECK_CONTEXT;
   params[0] = param;
   params[1] = 0.0;
   params[2] = 0.0;
   (*CC->API.PointParameterfvEXT)(CC, pname, params);
}


__asm __saveds void APIENTRY glPointParameterfvEXT( register __d0 GLenum pname, register __a0 const GLfloat *params )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.PointParameterfvEXT)(CC, pname, params);
}




#ifdef GL_MESA_window_pos
/*
 * Mesa implementation of glWindowPos*MESA()
 */
__asm __saveds void APIENTRY glWindowPos4fMESA( register __fp0 GLfloat x, register __fp1 GLfloat y, register __fp2 GLfloat z, register __fp3 GLfloat w )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.WindowPos4fMESA)( CC, x, y, z, w );
}
#else
/* Implementation in winpos.c is used */
#endif


__asm __saveds void APIENTRY glWindowPos2iMESA( register __d0 GLint x, register __d1 GLint y )
{
   glWindowPos4fMESA( (GLfloat) x, (GLfloat) y, 0.0F, 1.0F );
}

__asm __saveds void APIENTRY glWindowPos2sMESA( register __d0 GLshort x, register __d1 GLshort y )
{
   glWindowPos4fMESA( (GLfloat) x, (GLfloat) y, 0.0F, 1.0F );
}

__asm __saveds void APIENTRY glWindowPos2fMESA( register __fp0 GLfloat x, register __fp1 GLfloat y )
{
   glWindowPos4fMESA( x, y, 0.0F, 1.0F );
}

__asm __saveds void APIENTRY glWindowPos2dMESA( register __fp0 GLdouble x, register __fp1 GLdouble y )
{
   glWindowPos4fMESA( (GLfloat) x, (GLfloat) y, 0.0F, 1.0F );
}

__asm __saveds void APIENTRY glWindowPos2ivMESA( register __a0 const GLint *p )
{
   glWindowPos4fMESA( (GLfloat) p[0], (GLfloat) p[1], 0.0F, 1.0F );
}

__asm __saveds void APIENTRY glWindowPos2svMESA( register __a0 const GLshort *p )
{
   glWindowPos4fMESA( (GLfloat) p[0], (GLfloat) p[1], 0.0F, 1.0F );
}

__asm __saveds void APIENTRY glWindowPos2fvMESA( register __a0 const GLfloat *p )
{
   glWindowPos4fMESA( p[0], p[1], 0.0F, 1.0F );
}

__asm __saveds void APIENTRY glWindowPos2dvMESA( register __a0 const GLdouble *p )
{
   glWindowPos4fMESA( (GLfloat) p[0], (GLfloat) p[1], 0.0F, 1.0F );
}

__asm __saveds void APIENTRY glWindowPos3iMESA( register __d0 GLint x, register __d1 GLint y, register __d2 GLint z )
{
   glWindowPos4fMESA( (GLfloat) x, (GLfloat) y, (GLfloat) z, 1.0F );
}

__asm __saveds void APIENTRY glWindowPos3sMESA( register __d0 GLshort x, register __d1 GLshort y, register __d2 GLshort z )
{
   glWindowPos4fMESA( (GLfloat) x, (GLfloat) y, (GLfloat) z, 1.0F );
}

__asm __saveds void APIENTRY glWindowPos3fMESA( register __fp0 GLfloat x, register __fp1 GLfloat y, register __fp2 GLfloat z )
{
   glWindowPos4fMESA( x, y, z, 1.0F );
}

__asm __saveds void APIENTRY glWindowPos3dMESA( register __fp0 GLdouble x, register __fp1 GLdouble y, register __fp2 GLdouble z )
{
   glWindowPos4fMESA( (GLfloat) x, (GLfloat) y, (GLfloat) z, 1.0F );
}

__asm __saveds void APIENTRY glWindowPos3ivMESA( register __a0 const GLint *p )
{
   glWindowPos4fMESA( (GLfloat) p[0], (GLfloat) p[1], (GLfloat) p[2], 1.0F );
}

__asm __saveds void APIENTRY glWindowPos3svMESA( register __a0 const GLshort *p )
{
   glWindowPos4fMESA( (GLfloat) p[0], (GLfloat) p[1], (GLfloat) p[2], 1.0F );
}

__asm __saveds void APIENTRY glWindowPos3fvMESA( register __a0 const GLfloat *p )
{
   glWindowPos4fMESA( p[0], p[1], p[2], 1.0F );
}

__asm __saveds void APIENTRY glWindowPos3dvMESA( register __a0 const GLdouble *p )
{
   glWindowPos4fMESA( (GLfloat) p[0], (GLfloat) p[1], (GLfloat) p[2], 1.0F );
}

__asm __saveds void APIENTRY glWindowPos4iMESA( register __d0 GLint x, register __d1 GLint y, register __d2 GLint z, register __d3 GLint w )
{
   glWindowPos4fMESA( (GLfloat) x, (GLfloat) y, (GLfloat) z, (GLfloat) w );
}

__asm __saveds void APIENTRY glWindowPos4sMESA( register __d0 GLshort x, register __d1 GLshort y, register __d2 GLshort z, register __d3 GLshort w )
{
   glWindowPos4fMESA( (GLfloat) x, (GLfloat) y, (GLfloat) z, (GLfloat) w );
}

__asm __saveds void APIENTRY glWindowPos4dMESA( register __fp0 GLdouble x, register __fp1 GLdouble y, register __fp2 GLdouble z, register __fp3 GLdouble w )
{
   glWindowPos4fMESA( (GLfloat) x, (GLfloat) y, (GLfloat) z, (GLfloat) w );
}


__asm __saveds void APIENTRY glWindowPos4ivMESA( register __a0 const GLint *p )
{
   glWindowPos4fMESA( (GLfloat) p[0], (GLfloat) p[1],
                      (GLfloat) p[2], (GLfloat) p[3] );
}

__asm __saveds void APIENTRY glWindowPos4svMESA( register __a0 const GLshort *p )
{
   glWindowPos4fMESA( (GLfloat) p[0], (GLfloat) p[1],
                      (GLfloat) p[2], (GLfloat) p[3] );
}

__asm __saveds void APIENTRY glWindowPos4fvMESA( register __a0 const GLfloat *p )
{
   glWindowPos4fMESA( p[0], p[1], p[2], p[3] );
}

__asm __saveds void APIENTRY glWindowPos4dvMESA( register __a0 const GLdouble *p )
{
   glWindowPos4fMESA( (GLfloat) p[0], (GLfloat) p[1],
                      (GLfloat) p[2], (GLfloat) p[3] );
}




/*
 * GL_MESA_resize_buffers
 */

/*
 * Called by user application when window has been resized.
 */
__asm __saveds void APIENTRY glResizeBuffersMESA( void )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.ResizeBuffersMESA)( CC );
}



/*
 * GL_SGIS_multitexture
 */

__asm __saveds void APIENTRY glMultiTexCoord1dSGIS( register __d0 GLenum target, register __fp0 GLdouble s )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, s, 0.0, 0.0, 1.0 );
}

__asm __saveds void APIENTRY glMultiTexCoord1dvSGIS( register __d0 GLenum target, register __a0 const GLdouble *v )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, v[0], 0.0, 0.0, 1.0 );
}

__asm __saveds void APIENTRY glMultiTexCoord1fSGIS( register __d0 GLenum target, register __fp0 GLfloat s )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, s, 0.0, 0.0, 1.0 );
}

__asm __saveds void APIENTRY glMultiTexCoord1fvSGIS( register __d0 GLenum target, register __a0 const GLfloat *v )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, v[0], 0.0, 0.0, 1.0 );
}

__asm __saveds void APIENTRY glMultiTexCoord1iSGIS( register __d0 GLenum target, register __d1 GLint s )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, s, 0.0, 0.0, 1.0 );
}

__asm __saveds void APIENTRY glMultiTexCoord1ivSGIS( register __d0 GLenum target, register __a0 const GLint *v )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, v[0], 0.0, 0.0, 1.0 );
}

__asm __saveds void APIENTRY glMultiTexCoord1sSGIS( register __d0 GLenum target, register __d1 GLshort s )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, s, 0.0, 0.0, 1.0 );
}

__asm __saveds void APIENTRY glMultiTexCoord1svSGIS( register __d0 GLenum target, register __a0 const GLshort *v )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, v[0], 0.0, 0.0, 1.0 );
}

__asm __saveds void APIENTRY glMultiTexCoord2dSGIS( register __d0 GLenum target, register __fp0 GLdouble s, register __fp1 GLdouble t )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, s, t, 0.0, 1.0 );
}

__asm __saveds void APIENTRY glMultiTexCoord2dvSGIS( register __d0 GLenum target, register __a0 const GLdouble *v )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, v[0], v[1], 0.0, 1.0 );
}

__asm __saveds void APIENTRY glMultiTexCoord2fSGIS( register __d0 GLenum target, register __fp0 GLfloat s, register __fp1 GLfloat t )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, s, t, 0.0, 1.0 );
}

__asm __saveds void APIENTRY glMultiTexCoord2fvSGIS( register __d0 GLenum target, register __a0 const GLfloat *v )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, v[0], v[1], 0.0, 1.0 );
}

__asm __saveds void APIENTRY glMultiTexCoord2iSGIS( register __d0 GLenum target, register __d1 GLint s, register __d2 GLint t )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, s, t, 0.0, 1.0 );
}

__asm __saveds void APIENTRY glMultiTexCoord2ivSGIS( register __d0 GLenum target, register __a0 const GLint *v )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, v[0], v[1], 0.0, 1.0 );
}

__asm __saveds void APIENTRY glMultiTexCoord2sSGIS( register __d0 GLenum target, register __d1 GLshort s, register __d2 GLshort t )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, s, t, 0.0, 1.0 );
}

__asm __saveds void APIENTRY glMultiTexCoord2svSGIS( register __d0 GLenum target, register __a0 const GLshort *v )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, v[0], v[1], 0.0, 1.0 );
}

__asm __saveds void APIENTRY glMultiTexCoord3dSGIS( register __d0 GLenum target, register __fp0 GLdouble s, register __fp1 GLdouble t, register __fp2 GLdouble r )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, s, t, r, 1.0 );
}

__asm __saveds void APIENTRY glMultiTexCoord3dvSGIS( register __d0 GLenum target, register __a0 const GLdouble *v )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, v[0], v[1], v[2], 1.0 );
}

__asm __saveds void APIENTRY glMultiTexCoord3fSGIS( register __d0 GLenum target, register __fp0 GLfloat s, register __fp1 GLfloat t, register __fp2 GLfloat r )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, s, t, r, 1.0 );
}

__asm __saveds void APIENTRY glMultiTexCoord3fvSGIS( register __d0 GLenum target, register __a0 const GLfloat *v )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, v[0], v[1], v[2], 1.0 );
}

__asm __saveds void APIENTRY glMultiTexCoord3iSGIS( register __d0 GLenum target, register __d1 GLint s, register __d2 GLint t, register __d3 GLint r )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, s, t, r, 1.0 );
}

__asm __saveds void APIENTRY glMultiTexCoord3ivSGIS( register __d0 GLenum target, register __a0 const GLint *v )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, v[0], v[1], v[2], 1.0 );
}

__asm __saveds void APIENTRY glMultiTexCoord3sSGIS( register __d0 GLenum target, register __d1 GLshort s, register __d2 GLshort t, register __d3 GLshort r )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, s, t, r, 1.0 );
}

__asm __saveds void APIENTRY glMultiTexCoord3svSGIS( register __d0 GLenum target, register __a0 const GLshort *v )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, v[0], v[1], v[2], 1.0 );
}

__asm __saveds void APIENTRY glMultiTexCoord4dSGIS( register __d0 GLenum target, register __fp0 GLdouble s, register __fp1 GLdouble t, register __fp2 GLdouble r, register __fp3 GLdouble q )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, s, t, r, q );
}

__asm __saveds void APIENTRY glMultiTexCoord4dvSGIS( register __d0 GLenum target, register __a0 const GLdouble *v )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, v[0], v[1], v[2], v[3] );
}

__asm __saveds void APIENTRY glMultiTexCoord4fSGIS( register __d0 GLenum target, register __fp0 GLfloat s, register __fp1 GLfloat t, register __fp2 GLfloat r, register __fp3 GLfloat q )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, s, t, r, q );
}

__asm __saveds void APIENTRY glMultiTexCoord4fvSGIS( register __d0 GLenum target, register __a0 const GLfloat *v )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, v[0], v[1], v[2], v[3] );
}

__asm __saveds void APIENTRY glMultiTexCoord4iSGIS( register __d0 GLenum target, register __d1 GLint s, register __d2 GLint t, register __d3 GLint r, register __d4 GLint q )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, s, t, r, q );
}

__asm __saveds void APIENTRY glMultiTexCoord4ivSGIS( register __d0 GLenum target, register __a0 const GLint *v )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, v[0], v[1], v[2], v[3] );
}

__asm __saveds void APIENTRY glMultiTexCoord4sSGIS( register __d0 GLenum target, register __d1 GLshort s, register __d2 GLshort t, register __d3 GLshort r, register __d4 GLshort q )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, s, t, r, q );
}

__asm __saveds void APIENTRY glMultiTexCoord4svSGIS( register __d0 GLenum target, register __a0 const GLshort *v )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, v[0], v[1], v[2], v[3] );
}



__asm __saveds void APIENTRY glMultiTexCoordPointerSGIS( register __d0 GLenum target, register __d1 GLint size, register __d2 GLenum type,
                                                         register __d3 GLsizei stride, register __a0 const GLvoid *ptr )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.MultiTexCoordPointer)(CC, target, size, type, stride, ptr);
}



__asm __saveds void APIENTRY glSelectTextureSGIS( register __d0 GLenum target )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.SelectTextureSGIS)(CC, target);
}



__asm __saveds void APIENTRY glSelectTextureCoordSetSGIS( register __d0 GLenum target )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.SelectTextureCoordSet)(CC, target);
}




/*
 * GL_EXT_multitexture
 */

__asm __saveds void APIENTRY glMultiTexCoord1dEXT( register __d0 GLenum target, register __fp0 GLdouble s )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, s, 0.0, 0.0, 1.0 );
}

__asm __saveds void APIENTRY glMultiTexCoord1dvEXT( register __d0 GLenum target, register __a0 const GLdouble *v )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, v[0], 0.0, 0.0, 1.0 );
}

__asm __saveds void APIENTRY glMultiTexCoord1fEXT( register __d0 GLenum target, register __fp0 GLfloat s )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, s, 0.0, 0.0, 1.0 );
}

__asm __saveds void APIENTRY glMultiTexCoord1fvEXT( register __d0 GLenum target, register __a0 const GLfloat *v )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, v[0], 0.0, 0.0, 1.0 );
}

__asm __saveds void APIENTRY glMultiTexCoord1iEXT( register __d0 GLenum target, register __d1 GLint s )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, s, 0.0, 0.0, 1.0 );
}

__asm __saveds void APIENTRY glMultiTexCoord1ivEXT( register __d0 GLenum target, register __a0 const GLint *v )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, v[0], 0.0, 0.0, 1.0 );
}

__asm __saveds void APIENTRY glMultiTexCoord1sEXT( register __d0 GLenum target, register __d1 GLshort s )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, s, 0.0, 0.0, 1.0 );
}

__asm __saveds void APIENTRY glMultiTexCoord1svEXT( register __d0 GLenum target, register __a0 const GLshort *v )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, v[0], 0.0, 0.0, 1.0 );
}

__asm __saveds void APIENTRY glMultiTexCoord2dEXT( register __d0 GLenum target, register __fp0 GLdouble s, register __fp1 GLdouble t )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, s, t, 0.0, 1.0 );
}

__asm __saveds void APIENTRY glMultiTexCoord2dvEXT( register __d0 GLenum target, register __a0 const GLdouble *v )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, v[0], v[1], 0.0, 1.0 );
}

__asm __saveds void APIENTRY glMultiTexCoord2fEXT( register __d0 GLenum target, register __fp0 GLfloat s, register __fp1 GLfloat t )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, s, t, 0.0, 1.0 );
}

__asm __saveds void APIENTRY glMultiTexCoord2fvEXT( register __d0 GLenum target, register __a0 const GLfloat *v )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, v[0], v[1], 0.0, 1.0 );
}

__asm __saveds void APIENTRY glMultiTexCoord2iEXT( register __d0 GLenum target, register __d1 GLint s, register __d2 GLint t )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, s, t, 0.0, 1.0 );
}

__asm __saveds void APIENTRY glMultiTexCoord2ivEXT( register __d0 GLenum target, register __a0 const GLint *v )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, v[0], v[1], 0.0, 1.0 );
}

__asm __saveds void APIENTRY glMultiTexCoord2sEXT( register __d0 GLenum target, register __d1 GLshort s, register __d2 GLshort t )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, s, t, 0.0, 1.0 );
}

__asm __saveds void APIENTRY glMultiTexCoord2svEXT( register __d0 GLenum target, register __a0 const GLshort *v )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, v[0], v[1], 0.0, 1.0 );
}

__asm __saveds void APIENTRY glMultiTexCoord3dEXT( register __d0 GLenum target, register __fp0 GLdouble s, register __fp1 GLdouble t, register __fp2 GLdouble r )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, s, t, r, 1.0 );
}

__asm __saveds void APIENTRY glMultiTexCoord3dvEXT( register __d0 GLenum target, register __a0 const GLdouble *v )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, v[0], v[1], v[2], 1.0 );
}

__asm __saveds void APIENTRY glMultiTexCoord3fEXT( register __d0 GLenum target, register __fp0 GLfloat s, register __fp1 GLfloat t, register __fp2 GLfloat r )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, s, t, r, 1.0 );
}

__asm __saveds void APIENTRY glMultiTexCoord3fvEXT( register __d0 GLenum target, register __a0 const GLfloat *v )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, v[0], v[1], v[2], 1.0 );
}

__asm __saveds void APIENTRY glMultiTexCoord3iEXT( register __d0 GLenum target, register __d1 GLint s, register __d2 GLint t, register __d3 GLint r )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, s, t, r, 1.0 );
}

__asm __saveds void APIENTRY glMultiTexCoord3ivEXT( register __d0 GLenum target, register __a0 const GLint *v )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, v[0], v[1], v[2], 1.0 );
}

__asm __saveds void APIENTRY glMultiTexCoord3sEXT( register __d0 GLenum target, register __d1 GLshort s, register __d2 GLshort t, register __d3 GLshort r )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, s, t, r, 1.0 );
}

__asm __saveds void APIENTRY glMultiTexCoord3svEXT( register __d0 GLenum target, register __a0 const GLshort *v )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, v[0], v[1], v[2], 1.0 );
}

__asm __saveds void APIENTRY glMultiTexCoord4dEXT( register __d0 GLenum target, register __fp0 GLdouble s, register __fp1 GLdouble t, register __fp2 GLdouble r, register __fp3 GLdouble q )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, s, t, r, q );
}

__asm __saveds void APIENTRY glMultiTexCoord4dvEXT( register __d0 GLenum target, register __a0 const GLdouble *v )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, v[0], v[1], v[2], v[3] );
}

__asm __saveds void APIENTRY glMultiTexCoord4fEXT( register __d0 GLenum target, register __fp0 GLfloat s, register __fp1 GLfloat t, register __fp2 GLfloat r, register __fp3 GLfloat q )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, s, t, r, q );
}

__asm __saveds void APIENTRY glMultiTexCoord4fvEXT( register __d0 GLenum target, register __a0 const GLfloat *v )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, v[0], v[1], v[2], v[3] );
}

__asm __saveds void APIENTRY glMultiTexCoord4iEXT( register __d0 GLenum target, register __d1 GLint s, register __d2 GLint t, register __d3 GLint r, register __d4 GLint q )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, s, t, r, q );
}

__asm __saveds void APIENTRY glMultiTexCoord4ivEXT( register __d0 GLenum target, register __a0 const GLint *v )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, v[0], v[1], v[2], v[3] );
}

__asm __saveds void APIENTRY glMultiTexCoord4sEXT( register __d0 GLenum target, register __d1 GLshort s, register __d2 GLshort t, register __d3 GLshort r, register __d4 GLshort q )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, s, t, r, q );
}

__asm __saveds void APIENTRY glMultiTexCoord4svEXT( register __d0 GLenum target, register __a0 const GLshort *v )
{
   GET_CONTEXT;
   (*CC->API.MultiTexCoord4f)( CC, target, v[0], v[1], v[2], v[3] );
}



__asm __saveds void APIENTRY glInterleavedTextureCoordSetsEXT( register __d0 GLint factor )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.InterleavedTextureCoordSets)( CC, factor );
}



__asm __saveds void APIENTRY glSelectTextureTransformEXT( register __d0 GLenum target )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.SelectTextureTransform)( CC, target );
}



__asm __saveds void APIENTRY glSelectTextureEXT( register __d0 GLenum target )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.SelectTexture)( CC, target );
}



__asm __saveds void APIENTRY glSelectTextureCoordSetEXT( register __d0 GLenum target )
{
   GET_CONTEXT;
   CHECK_CONTEXT;
   (*CC->API.SelectTextureCoordSet)( CC, target );
}

