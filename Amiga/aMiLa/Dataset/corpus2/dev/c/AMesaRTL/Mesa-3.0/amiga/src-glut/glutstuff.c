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
 * glutstuff.c
 *
 * Version 1.0  27 Jun 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * Version 1.1  02 Aug 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * - Quantizer plugin support added
 *
 * Version 2.0  19 Sep 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * - Added glutAssociateGL() to get hold of mesa bases
 * - Changed to runtime library format
 * - Changed quantizer to output handler
 * - Added handlerwindow flag
 *
 */


#include <constructor.h>

#include <proto/exec.h>

#include "glutstuff.h"


struct GlutStuff glutstuff;
struct Library *mesamainBase = NULL;
struct Library *mesadriverBase = NULL;


DEFAULT_CONSTRUCTOR(glutConstruct)
{
	glutstuff.msgport = CreateMsgPort();
	if(glutstuff.msgport == NULL)
	{
		return(1);
	}
	glutstuff.curwin = NULL;
	glutstuff.wins = NULL;
	glutstuff.nextwinid = 1;

	glutstuff.curmenu = NULL;
	glutstuff.menus = NULL;
	glutstuff.nextmenuid = 1;

	glutstuff.initposx = -1;
	glutstuff.initposy = -1;
	glutstuff.initwidth = 300;
	glutstuff.initheight = 300;

	glutstuff.numcolours = 248;
	glutstuff.colourbase = 8;
	glutstuff.pubscreenname = "Mesa";
	glutstuff.oh = NULL;
	glutstuff.ohversion = -1;

	glutstuff.handlerwindow = TRUE;

	glutstuff.rgba = GL_TRUE;
	glutstuff.alpha = GL_FALSE;
	glutstuff.db = GL_FALSE;
	glutstuff.accum = GL_FALSE;
	glutstuff.depth = GL_FALSE;
	glutstuff.stencil = GL_FALSE;
	glutstuff.multisample = GL_FALSE;
	glutstuff.stereo = GL_FALSE;
	glutstuff.luminance = GL_FALSE;

	glutstuff.idlefunc = NULL;
	glutstuff.menustatusfunc = NULL;

	glutstuff.basetime_secs = 0;
	glutstuff.basetime_micros = 0;
	glutstuff.havebasetime = FALSE;

	return(0);
}


DEFAULT_DESTRUCTOR(glutDestruct)
{
	struct GlutWindow *gw, *gwn;
	struct GlutMenu *gm, *gmn;

	gw = glutstuff.wins;
	while(gw)
	{
		gwn = gw->next;
		glutDestroyWindow(gw->winid);
		gw = gwn;
	}

	gm = glutstuff.menus;
	while(gm)
	{
		gmn = gm->next;
		glutDestroyMenu(gm->menuid);
		gm = gmn;
	}

	if(glutstuff.msgport)
		DeleteMsgPort(glutstuff.msgport);
}


int stuffGetNewWinID(void)
{
	return(glutstuff.nextwinid++);
}


struct GlutWindow *stuffGetWin(int winid)
{
	struct GlutWindow *gw;

	gw = glutstuff.wins;
	while(gw && (gw->winid != winid))
		gw = gw->next;

	return(gw);
}


void stuffLinkInWin(struct GlutWindow *gw)
{
	gw->next = glutstuff.wins;
	gw->prev = NULL;
	if(glutstuff.wins)
		glutstuff.wins->prev = gw;
	glutstuff.wins = gw;

	stuffMakeCurrent(gw);
}


void stuffLinkOutWin(struct GlutWindow *gw)
{
	if(gw->prev)
		gw->prev->next = gw->next;
	if(gw->next)
		gw->next->prev = gw->prev;

	if(glutstuff.wins == gw)
		glutstuff.wins = gw->next;

	if(glutstuff.curwin == gw)
		glutstuff.curwin = NULL;
}


void stuffMakeCurrent(struct GlutWindow *gw)
{
	if(glutstuff.curwin != gw)
	{
		glutstuff.curwin = gw;

		AmigaMesaRTLMakeCurrent(gw->context);
	}
}


int stuffGetNewMenuID(void)
{
	return(glutstuff.nextmenuid++);
}


struct GlutMenu *stuffGetMenu(int menuid)
{
	struct GlutMenu *gm;

	gm = glutstuff.menus;
	while(gm && (gm->menuid != menuid))
		gm = gm->next;

	return(gm);
}


void stuffLinkInMenu(struct GlutMenu *gm)
{
	gm->next = glutstuff.menus;
	gm->prev = NULL;
	if(glutstuff.menus)
		glutstuff.menus->prev = gm;
	glutstuff.menus = gm;

	stuffMakeCurrentMenu(gm);
}


void stuffLinkOutMenu(struct GlutMenu *gm)
{
	if(gm->prev)
		gm->prev->next = gm->next;
	if(gm->next)
		gm->next->prev = gm->prev;

	if(glutstuff.menus == gm)
		glutstuff.menus = gm->next;

	if(glutstuff.curmenu == gm)
		glutstuff.curmenu = NULL;
}


void stuffMakeCurrentMenu(struct GlutMenu *gm)
{
	if(glutstuff.curmenu != gm)
	{
		glutstuff.curmenu = gm;
	}
}


struct GlutMenuEntry *stuffGetMenuEntry(int entry,struct GlutMenu *gm)
{
	struct GlutMenuEntry *gme;

	gme = gm->entries;
	entry--;

	for(;entry > 0; entry--)
		gme = gme->next;

	return(gme);
}


void stuffLinkInMenuEntry(struct GlutMenuEntry *gme,struct GlutMenu *gm)
{
	struct GlutMenuEntry *p;

	for(p=gm->entries; p && p->next; p=p->next)
		;
	gme->next = NULL;
	gme->prev = p;
	if(p)
		p->next = gme;
	else
		gm->entries = gme;
	gm->numentries++;
	gme->menu = gm;
}


void stuffLinkOutMenuEntry(struct GlutMenuEntry *gme,struct GlutMenu *gm)
{
	if(gme->prev)
		gme->prev->next = gme->next;
	if(gme->next)
		gme->next->prev = gme->prev;

	if(gm->entries == gme)
		gm->entries = gme->next;

	gm->numentries--;

	gme->menu = NULL;
}


__asm __saveds void glutAssociateGL(register __a0 struct Library *mesamainBaseArg, register __a1 struct Library *mesadriverBaseArg)
{
	mesamainBase = mesamainBaseArg;
	mesadriverBase = mesadriverBaseArg;
}
