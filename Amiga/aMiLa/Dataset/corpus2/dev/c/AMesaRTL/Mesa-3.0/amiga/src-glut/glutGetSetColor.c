/*
 * Amiga GLUT graphics library toolkit
 * Version:  2.0
 * Copyright (C) 1998 Jarno van der Linden
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
 * glutGetSetColor.c
 *
 * Version 1.0  28 Jun 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * Version 1.1  08 Aug 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * - Modified to work with AmigaMesaRTL(Get|Set)IndexRGB
 *
 * Version 2.0  16 Aug 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * - Changed to runtime library format
 *
 */


#include <proto/graphics.h>
#include <proto/intuition.h>

#include "glutstuff.h"


__asm __saveds GLfloat glutGetColor( register __d0 int ndx, register __d1 int component )
{
	ULONG red,green,blue;

	if((ndx < 0) || (ndx > 255))
		return(-1.0);

	AmigaMesaRTLGetIndexRGB(ndx, &red, &green, &blue);

	switch(component)
	{
		case GLUT_RED:
			return((GLfloat)(((GLfloat)red)/0xffffffff));
		case GLUT_GREEN:
			return((GLfloat)(((GLfloat)green)/0xffffffff));
		case GLUT_BLUE:
			return((GLfloat)(((GLfloat)blue)/0xffffffff));
	}

	return(-1.0);
}


__asm __saveds void glutSetColor( register __d0 int cell, register __fp0 GLfloat red, register __fp1 GLfloat green, register __fp2 GLfloat blue )
{
	ULONG r,g,b;

	if(red < 0.0)
		red = 0.0;
	else if(red > 1.0)
		red = 1.0;

	if(green < 0.0)
		green = 0.0;
	else if(green > 1.0)
		green = 1.0;

	if(blue < 0.0)
		blue = 0.0;
	else if(blue > 1.0)
		blue = 1.0;

	r = (ULONG)(red * 0xffffffff);
	g = (ULONG)(green * 0xffffffff);
	b = (ULONG)(blue * 0xffffffff);

	AmigaMesaRTLSetIndexRGB(cell, r,g,b);
}
