/*
 * Mesa 3-D graphics library
 * Version:  2.6
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
 * glu.c
 *
 * Version 1.0  27 Jun 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * File created from glu.h ver 1.9 using GenProtos
 *
 * Version 1.1  09 Aug 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * - Added __stdargs to gluLookAt
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
#include "gl/glu.h"

extern struct Library *mesamainBase;


extern __asm __saveds void APIENTRY gluLookAtA(register __a0 void *);
#pragma libcall mesamainBase gluLookAtA 972 801

__stdargs __saveds void APIENTRY STUBgluLookAt(GLdouble eyex, GLdouble eyey, GLdouble eyez, GLdouble centerx, GLdouble centery, GLdouble centerz, GLdouble upx, GLdouble upy, GLdouble upz, struct Library *mesamainBase)
{
	struct gluLookAtArgs {
		GLdouble eyex;
		GLdouble eyey;
		GLdouble eyez;
		GLdouble centerx;
		GLdouble centery;
		GLdouble centerz;
		GLdouble upx;
		GLdouble upy;
		GLdouble upz;
	} args;

	args.eyex = eyex;
	args.eyey = eyey;
	args.eyez = eyez;
	args.centerx = centerx;
	args.centery = centery;
	args.centerz = centerz;
	args.upx = upx;
	args.upy = upy;
	args.upz = upz;

	gluLookAtA(&args);
}


extern __asm __saveds GLint APIENTRY gluProjectA(register __a0 void *);
#pragma libcall mesamainBase gluProjectA 98a 801

__asm __saveds GLint APIENTRY STUBgluProject(register __fp0 GLdouble objx, register __fp1 GLdouble objy, register __fp2 GLdouble objz, register __a0 const GLdouble modelMatrix[16], register __a1 const GLdouble projMatrix[16], register __a2 const GLint viewport[4], register __a3 GLdouble *winx, register __a4 GLdouble *winy, register __a5 GLdouble *winz, register __a6 struct Library *mesamainBase)
{
	struct gluProjectArgs {
		GLdouble objx;
		GLdouble objy;
		GLdouble objz;
		GLdouble *modelMatrix;
		GLdouble *projMatrix;
		GLint *viewport;
		GLdouble *winx;
		GLdouble *winy;
		GLdouble *winz;
	} args;

	args.objx = objx;
	args.objy = objy;
	args.objz = objz;
	args.modelMatrix = modelMatrix;
	args.projMatrix = projMatrix;
	args.viewport = viewport;
	args.winx = winx;
	args.winy = winy;
	args.winz = winz;

	return(gluProjectA(&args));
}


extern __asm __saveds GLint APIENTRY gluUnProjectA(register __a0 void *);
#pragma libcall mesamainBase gluUnProjectA 996 801

__asm __saveds GLint APIENTRY STUBgluUnProject(register __fp0 GLdouble winx, register __fp1 GLdouble winy, register __fp2 GLdouble winz, register __a0 const GLdouble modelMatrix[16], register __a1 const GLdouble projMatrix[16], register __a2 const GLint viewport[4], register __a3 GLdouble *objx, register __a4 GLdouble *objy, register __a5 GLdouble *objz, register __a6 struct Library *mesamainBase)
{
	struct gluUnProjectArgs {
		GLdouble winx;
		GLdouble winy;
		GLdouble winz;
		GLdouble *modelMatrix;
		GLdouble *projMatrix;
		GLint *viewport;
		GLdouble *objx;
		GLdouble *objy;
		GLdouble *objz;
	} args;

	args.winx = winx;
	args.winy = winy;
	args.winz = winz;
	args.modelMatrix = modelMatrix;
	args.projMatrix = projMatrix;
	args.viewport = viewport;
	args.objx = objx;
	args.objy = objy;
	args.objz = objz;

	return(gluUnProjectA(&args));
}


extern __asm __saveds void APIENTRY gluCylinderA(register __a0 void *);
#pragma libcall mesamainBase gluCylinderA 9e4 801

__asm __saveds void APIENTRY STUBgluCylinder(register __a0 GLUquadricObj *qobj, register __fp0 GLdouble baseRadius, register __fp1 GLdouble topRadius, register __fp2 GLdouble height, register __d0 GLint slices, register __d1 GLint stacks, register __a1 struct Library *mesamainBase)
{
	struct gluCylinderArgs {
		GLUquadricObj *qobj;
		GLdouble baseRadius;
		GLdouble topRadius;
		GLdouble height;
		GLint slices;
		GLint stacks;
	} args;

	args.qobj = qobj;
	args.baseRadius = baseRadius;
	args.topRadius = topRadius;
	args.height = height;
	args.slices = slices;
	args.stacks = stacks;

	gluCylinderA(&args);
}


extern __asm __saveds void APIENTRY gluPartialDiskA(register __a0 void *);
#pragma libcall mesamainBase gluPartialDiskA 9fc 801

__asm __saveds void APIENTRY STUBgluPartialDisk(register __a0 GLUquadricObj *qobj, register __fp0 GLdouble innerRadius, register __fp1 GLdouble outerRadius, register __d0 GLint slices, register __d1 GLint loops, register __fp2 GLdouble startAngle, register __fp3 GLdouble sweepAngle, register __a1 struct Library *mesamainBase)
{
	struct gluPartialDiskArgs {
		GLUquadricObj *qobj;
		GLdouble innerRadius;
		GLdouble outerRadius;
		GLint slices;
		GLint loops;
		GLdouble startAngle;
		GLdouble sweepAngle;
	} args;

	args.qobj = qobj;
	args.innerRadius = innerRadius;
	args.outerRadius = outerRadius;
	args.slices = slices;
	args.loops = loops;
	args.startAngle = startAngle;
	args.sweepAngle = sweepAngle;

	gluPartialDiskA(&args);
}
