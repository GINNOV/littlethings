/*
 * Mesa 3-D graphics library
 * Version:  2.5
 * Copyright (C) 1995-1997  Brian Paul
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
 * mesa.c
 *
 * Version 1.0  27 Jun 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * File created from gl.h ver 1.26 using GenProtos
 *
 * Version 2.0  13 Sep 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * - Change to using mesamainBase
 * - STUB added to function names, and added
 *   mesamainBase pointers to interface
 *
 */


#include "gl/gl.h"


extern __asm __saveds void APIENTRY glOrthoA(register __a0 void *);
#pragma libcall mesamainBase glOrthoA 14a 801

__asm __saveds void APIENTRY STUBglOrtho(register __fp0 GLdouble left, register __fp1 GLdouble right, register __fp2 GLdouble bottom, register __fp3 GLdouble top, register __fp4 GLdouble near_val, register __fp5 GLdouble far_val, register __a0 struct Library *mesamainBase)
{
	struct glOrthoArgs {
		GLdouble left;
		GLdouble right;
		GLdouble bottom;
		GLdouble top;
		GLdouble near_val;
		GLdouble far_val;
	} args;

	args.left = left;
	args.right = right;
	args.bottom = bottom;
	args.top = top;
	args.near_val = near_val;
	args.far_val = far_val;

	glOrthoA(&args);
}


extern __asm __saveds void APIENTRY glFrustumA(register __a0 void *);
#pragma libcall mesamainBase glFrustumA 156 801

__asm __saveds void APIENTRY STUBglFrustum(register __fp0 GLdouble left, register __fp1 GLdouble right, register __fp2 GLdouble bottom, register __fp3 GLdouble top, register __fp4 GLdouble near_val, register __fp5 GLdouble far_val, register __a0 struct Library *mesamainBase)
{
	struct glFrustumArgs {
		GLdouble left;
		GLdouble right;
		GLdouble bottom;
		GLdouble top;
		GLdouble near_val;
		GLdouble far_val;
	} args;

	args.left = left;
	args.right = right;
	args.bottom = bottom;
	args.top = top;
	args.near_val = near_val;
	args.far_val = far_val;

	glFrustumA(&args);
}


extern __asm __saveds void APIENTRY glBitmapA(register __a0 void *);
#pragma libcall mesamainBase glBitmapA 62a 801

__asm __saveds void APIENTRY STUBglBitmap(register __d0 GLsizei width, register __d1 GLsizei height, register __fp0 GLfloat xorig, register __fp1 GLfloat yorig, register __fp2 GLfloat xmove, register __fp3 GLfloat ymove, register __a0 const GLubyte *bitmap, register __a1 struct Library *mesamainBase)
{
	struct glBitmapArgs {
		GLsizei width;
		GLsizei height;
		GLfloat xorig;
		GLfloat yorig;
		GLfloat xmove;
		GLfloat ymove;
		GLubyte *bitmap;
	} args;

	args.width = width;
	args.height = height;
	args.xorig = xorig;
	args.yorig = yorig;
	args.xmove = xmove;
	args.ymove = ymove;
	args.bitmap = bitmap;

	glBitmapA(&args);
}


extern __asm __saveds void APIENTRY glMap1dA(register __a0 void *);
#pragma libcall mesamainBase glMap1dA 744 801

__asm __saveds void APIENTRY STUBglMap1d(register __d0 GLenum target, register __fp0 GLdouble u1, register __fp1 GLdouble u2, register __d1 GLint stride, register __d2 GLint order, register __a0 const GLdouble *points, register __a1 struct Library *mesamainBase)
{
	struct glMap1dArgs {
		GLenum target;
		GLdouble u1;
		GLdouble u2;
		GLint stride;
		GLint order;
		GLdouble *points;
	} args;

	args.target = target;
	args.u1 = u1;
	args.u2 = u2;
	args.stride = stride;
	args.order = order;
	args.points = points;

	glMap1dA(&args);
}


extern __asm __saveds void APIENTRY glMap1fA(register __a0 void *);
#pragma libcall mesamainBase glMap1fA 750 801

__asm __saveds void APIENTRY STUBglMap1f(register __d0 GLenum target, register __fp0 GLfloat u1, register __fp1 GLfloat u2, register __d1 GLint stride, register __d2 GLint order, register __a0 const GLfloat *points, register __a1 struct Library *mesamainBase)
{
	struct glMap1fArgs {
		GLenum target;
		GLfloat u1;
		GLfloat u2;
		GLint stride;
		GLint order;
		GLfloat *points;
	} args;

	args.target = target;
	args.u1 = u1;
	args.u2 = u2;
	args.stride = stride;
	args.order = order;
	args.points = points;

	glMap1fA(&args);
}


extern __asm __saveds void APIENTRY glMap2dA(register __a0 void *);
#pragma libcall mesamainBase glMap2dA 75c 801

__asm __saveds void APIENTRY STUBglMap2d(register __d0 GLenum target, register __fp0 GLdouble u1, register __fp1 GLdouble u2, register __d1 GLint ustride, register __d2 GLint uorder, register __fp2 GLdouble v1, register __fp3 GLdouble v2, register __d3 GLint vstride, register __d4 GLint vorder, register __a0 const GLdouble *points, register __a1 struct Library *mesamainBase)
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
	} args;

	args.target = target;
	args.u1 = u1;
	args.u2 = u2;
	args.ustride = ustride;
	args.uorder = uorder;
	args.v1 = v1;
	args.v2 = v2;
	args.vstride = vstride;
	args.vorder = vorder;
	args.points = points;

	glMap2dA(&args);
}


extern __asm __saveds void APIENTRY glMap2fA(register __a0 void *);
#pragma libcall mesamainBase glMap2fA 768 801

__asm __saveds void APIENTRY STUBglMap2f(register __d0 GLenum target, register __fp0 GLfloat u1, register __fp1 GLfloat u2, register __d1 GLint ustride, register __d2 GLint uorder, register __fp2 GLfloat v1, register __fp3 GLfloat v2, register __d3 GLint vstride, register __d4 GLint vorder, register __a0 const GLfloat *points, register __a1 struct Library *mesamainBase)
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
	} args;

	args.target = target;
	args.u1 = u1;
	args.u2 = u2;
	args.ustride = ustride;
	args.uorder = uorder;
	args.v1 = v1;
	args.v2 = v2;
	args.vstride = vstride;
	args.vorder = vorder;
	args.points = points;

	glMap2fA(&args);
}


extern __asm __saveds void APIENTRY glMapGrid2dA(register __a0 void *);
#pragma libcall mesamainBase glMapGrid2dA 7c2 801

__asm __saveds void APIENTRY STUBglMapGrid2d(register __d0 GLint un, register __fp0 GLdouble u1, register __fp1 GLdouble u2, register __d1 GLint vn, register __fp2 GLdouble v1, register __fp3 GLdouble v2, register __a0 struct Library *mesamainBase)
{
	struct glMapGrid2dArgs {
		GLint un;
		GLdouble u1;
		GLdouble u2;
		GLint vn;
		GLdouble v1;
		GLdouble v2;
	} args;

	args.un = un;
	args.u1 = u1;
	args.u2 = u2;
	args.vn = vn;
	args.v1 = v1;
	args.v2 = v2;

	glMapGrid2dA(&args);
}


extern __asm __saveds void APIENTRY glMapGrid2fA(register __a0 void *);
#pragma libcall mesamainBase glMapGrid2fA 7ce 801

__asm __saveds void APIENTRY STUBglMapGrid2f(register __d0 GLint un, register __fp0 GLfloat u1, register __fp1 GLfloat u2, register __d1 GLint vn, register __fp2 GLfloat v1, register __fp3 GLfloat v2, register __a0 struct Library *mesamainBase)
{
	struct glMapGrid2fArgs {
		GLint un;
		GLfloat u1;
		GLfloat u2;
		GLint vn;
		GLfloat v1;
		GLfloat v2;
	} args;

	args.un = un;
	args.u1 = u1;
	args.u2 = u2;
	args.vn = vn;
	args.v1 = v1;
	args.v2 = v2;

	glMapGrid2fA(&args);
}
