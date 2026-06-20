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
 * glutChangeToMenuSubEntry.c
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
 */


#include "glutstuff.h"


__asm __saveds void glutChangeToMenuEntry( register __d0 int entry, register __a0 const char *name, register __d1 int value )
{
	struct GlutMenuEntry *gme;

	gme = stuffGetMenuEntry(entry,glutstuff.curmenu);
	gme->name = name;
	gme->value = value;
	gme->issubmenu = FALSE;

	glutstuff.curmenu->needupdate = TRUE;
}


__asm __saveds void glutChangeToSubMenu( register __d0 int entry, register __a0 const char *name, register __d1 int menu )
{
	struct GlutMenuEntry *gme;

	gme = stuffGetMenuEntry(entry,glutstuff.curmenu);
	gme->name = name;
	gme->value = menu;
	gme->issubmenu = TRUE;

	glutstuff.curmenu->needupdate = TRUE;
}

