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
 * glutGet.c
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


#include <proto/intuition.h>

#include "glutstuff.h"


__asm __saveds int glutGet( register __d0 GLenum state )
{
	switch(state)
	{
		case GLUT_WINDOW_X:
			return(glutstuff.curwin->wincurx);
		case GLUT_WINDOW_Y:
			return(glutstuff.curwin->wincury);
		case GLUT_WINDOW_WIDTH:
			return(glutstuff.curwin->wincurwidth);
		case GLUT_WINDOW_HEIGHT:
			return(glutstuff.curwin->wincurheight);
		case GLUT_ELAPSED_TIME:
			{
				ULONG secs,micros;

				CurrentTime(&secs,&micros);
				if(!glutstuff.havebasetime)
				{
					glutstuff.basetime_secs = secs;
					glutstuff.basetime_micros = micros;
					glutstuff.havebasetime = TRUE;
				}

				return(((int)(secs - glutstuff.basetime_secs))*1000 + ((int)(micros - glutstuff.basetime_micros))/1000);
			}
		case GLUT_WINDOW_DOUBLEBUFFER:
			{
				GLboolean db;
				glGetBooleanv(GL_DOUBLEBUFFER, &db);
				return(db ? 1 : 0);
			}
		case GLUT_WINDOW_RGBA:
			{
				GLboolean rgb;
				glGetBooleanv(GL_RGBA_MODE,&rgb);
				return(rgb ? 1 : 0);
			}
		case GLUT_WINDOW_PARENT:
			return(0);
		case GLUT_WINDOW_NUM_CHILDREN:
			return(0);
		case GLUT_WINDOW_STEREO:
			{
				GLboolean stereo;
				glGetBooleanv(GL_STEREO,&stereo);
				return(stereo ? 1 : 0);
			}
		case GLUT_SCREEN_WIDTH:
			return(glutstuff.curwin->window->WScreen->Width);
		case GLUT_SCREEN_HEIGHT:
			return(glutstuff.curwin->window->WScreen->Height);
		case GLUT_MENU_NUM_ITEMS:
			return(glutstuff.curmenu->numentries);
		case GLUT_INIT_WINDOW_X:
			return(glutstuff.initposx);
		case GLUT_INIT_WINDOW_Y:
			return(glutstuff.initposy);
		case GLUT_INIT_WINDOW_WIDTH:
			return(glutstuff.initwidth);
		case GLUT_INIT_WINDOW_HEIGHT:
			return(glutstuff.initheight);
	}

	return(-1);
}
