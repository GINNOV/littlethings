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
 * glutXFunc.c
 *
 * Version 1.0  27 Jun 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * Version 2.0  16 Aug 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * - Changed to runtime library format
 * - Function pointers use __stdargs
 *
 */


#include "glutstuff.h"




__asm __saveds void glutDisplayFunc( register __a0 __stdargs void (*func)(void) )
{
	glutstuff.curwin->displayfunc = func;
}


__asm __saveds void glutIdleFunc( register __a0 __stdargs void (*func)(void) )
{
	glutstuff.idlefunc = func;
}


__asm __saveds void glutKeyboardFunc( register __a0 __stdargs void (*func)(unsigned char key,int x, int y) )
{
	glutstuff.curwin->keyboardfunc = func;
}


__asm __saveds void glutReshapeFunc( register __a0 __stdargs void (*func)(int width, int height) )
{
	glutstuff.curwin->reshapefunc = func;
}


__asm __saveds void glutVisibilityFunc( register __a0 __stdargs void (*func)(int state) )
{
	glutstuff.curwin->visibilityfunc = func;
}


__asm __saveds void glutSpecialFunc( register __a0 __stdargs void (*func)(int key, int x, int y) )
{
	glutstuff.curwin->specialfunc = func;
}


__asm __saveds void glutMenuStatusFunc( register __a0 __stdargs void (*func)(int status, int x, int y) )
{
	glutstuff.menustatusfunc = func;
}


__asm __saveds void glutMouseFunc( register __a0 void __stdargs (*func)(int buton, int state, int x,int y) )
{
	glutstuff.curwin->mousefunc = func;
}


__asm __saveds void glutMotionFunc( register __a0 __stdargs void (*func)(int x, int y) )
{
	glutstuff.curwin->motionfunc = func;
}


__asm __saveds void glutPassiveMotionFunc( register __a0 __stdargs void (*func)(int x, int y) )
{
	glutstuff.curwin->passivemotionfunc = func;
}
