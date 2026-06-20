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
 * glutDestroyMenu.c
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
 *
 */


#include <stdlib.h>

#include "glutstuff.h"


__asm __saveds void glutDestroyMenu( register __d0 int menu )
{
	struct GlutMenu *gm;
	struct GlutMenu *curmenu;

	gm = stuffGetMenu(menu);

	curmenu = glutstuff.curmenu;
	stuffMakeCurrentMenu(gm);
	while(gm->entries)
		glutRemoveMenuItem(1);
	stuffMakeCurrentMenu(curmenu);

	stuffLinkOutMenu(gm);

	free(gm);
}
