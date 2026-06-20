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
 * glutInit.c
 *
 * Version 1.0  27 Jun 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * Version 1.1  02 Aug 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * - Added quantizer plugin arguments
 *
 * Version 2.0  19 Sep 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * - Changed to runtime library format
 * - Changed quantizer to output handler
 * - Added -nohandlerwindow argument
 *
 */

#include <proto/intuition.h>

#include <string.h>

#include "glutstuff.h"


int Limit(int v, int minv,int maxv)
{
	if(v < minv)
		return(minv);
	if(v > maxv)
		return(maxv);

	return(v);
}


void RemoveArg( int n, int *argc, char **argv)
{
	int t;
	char *p;

	p = argv[n];

	for(t=n; t<((*argc)-1); t++)
	{
		argv[t] = argv[t+1];
	}
	argv[(*argc)-1] = p;
	(*argc)--;
}


__asm __saveds void glutInit( register __a0 int *argcp, register __a1 char **argv )
{
	int t;

	CurrentTime(&(glutstuff.basetime_secs),&(glutstuff.basetime_micros));
	glutstuff.havebasetime = TRUE;

	for(t=(*argcp)-1; t>=1; t--)
	{
		if((!stricmp(argv[t],"-numcolours")) || (!stricmp(argv[t],"-numcolors")))
		{
			if(t < ((*argcp)-1))
			{
				glutstuff.numcolours = Limit(atoi(argv[t+1]),2,256);
				RemoveArg(t,argcp,argv);
				RemoveArg(t,argcp,argv);
			}
		}
		else if((!stricmp(argv[t],"-colourbase")) || (!stricmp(argv[t],"-colorbase")))
		{
			if(t < ((*argcp)-1))
			{
				glutstuff.colourbase = Limit(atoi(argv[t+1]),0,254);
				RemoveArg(t,argcp,argv);
				RemoveArg(t,argcp,argv);
			}
		}
		else if(!stricmp(argv[t],"-pubscreen"))
		{
			if(t < ((*argcp)-1))
			{
				glutstuff.pubscreenname = argv[t+1];
				RemoveArg(t,argcp,argv);
				RemoveArg(t,argcp,argv);
			}
		}
		else if(!stricmp(argv[t],"-outputhandler"))
		{
			if(t < ((*argcp)-1))
			{
				glutstuff.oh = argv[t+1];
				RemoveArg(t,argcp,argv);
				RemoveArg(t,argcp,argv);
			}
		}
		else if(!stricmp(argv[t],"-outputhandlerversion"))
		{
			if(t < ((*argcp)-1))
			{
				glutstuff.ohversion = atol(argv[t+1]);
				RemoveArg(t,argcp,argv);
				RemoveArg(t,argcp,argv);
			}
		}
		else if(!stricmp(argv[t],"-nohandlerwindow"))
		{
			glutstuff.handlerwindow = FALSE;
			RemoveArg(t,argcp,argv);
		}
	}
}
