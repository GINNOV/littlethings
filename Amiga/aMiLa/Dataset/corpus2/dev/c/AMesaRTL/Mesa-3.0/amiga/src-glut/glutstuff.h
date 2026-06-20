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
 * glutstuff.h
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
 * - Callback functions take stdargs
 * - Changes quantizer to output handler
 * - Added handlerwindow flag
 * - Added mywindow flag
 *
 */


#include <exec/types.h>

#include "gl/glut.h"
#include "gl/mesadriver.h"


#define WIN_WIDTH(win)		((win)->Width - (win)->BorderLeft - (win)->BorderRight)
#define WIN_HEIGHT(win)		((win)->Height - (win)->BorderTop - (win)->BorderBottom)


struct GlutMenuEntry
{
	struct GlutMenuEntry *next, *prev;

	char *name;
	int value;
	BOOL issubmenu;

	struct GlutMenu *menu;
};


struct GlutMenu
{
	int menuid;
	struct GlutMenu *next, *prev;

	__stdargs void (*menufunc)(int value);

	struct GlutMenuEntry *entries;
	int numentries;

	BOOL needupdate;
};


struct GlutWindow
{
	struct Window *window;
	int winid;
	BOOL mywindow;				/* Did I open the window? */
	struct GlutWindow *next, *prev;

	AmigaMesaRTLContext context;

	APTR vi;

	struct Menu *menu;
	struct GlutMenu *leftmenu, *middlemenu, *rightmenu;

	UWORD qualifiers;
	int mousex, mousey;

	int winx, winy;				/* Shape that we want */
	int winwidth, winheight;
	int wincurx, wincury;		/* Shape that we believe it to currently be */
	int wincurwidth, wincurheight;

	__stdargs void (*displayfunc)(void);
	__stdargs void (*keyboardfunc)(unsigned char key,int x, int y);
	__stdargs void (*reshapefunc)(int width, int height);
	__stdargs void (*visibilityfunc)(int state);
	__stdargs void (*specialfunc)(int key, int x, int y);
	__stdargs void (*mousefunc)(int button, int state, int x, int y);
	__stdargs void (*motionfunc)(int x, int y);
	__stdargs void (*passivemotionfunc)(int x, int y);

	BOOL needredisplay;
	BOOL needreshape, needreshapegui;
	BOOL needposition, needpositiongui;
	BOOL needvisibility, visible;
	BOOL needleftmenu, needmiddlemenu, needrightmenu;
};


struct GlutStuff
{
	struct MsgPort *msgport;
	struct GlutWindow *curwin;
	struct GlutWindow *wins;
	int nextwinid;

	struct GlutMenu *curmenu;
	struct GlutMenu *menus;
	int nextmenuid;

	int initposx, initposy;
	int initwidth, initheight;

	int numcolours;
	int colourbase;
	char *pubscreenname;
	char *oh;
	ULONG ohversion;

	BOOL handlerwindow;

	GLboolean rgba;
	GLboolean alpha;
	GLboolean db;
	GLboolean accum;
	GLboolean depth;
	GLboolean stencil;
	GLboolean multisample;
	GLboolean stereo;
	GLboolean luminance;

	__stdargs void (*idlefunc)(void);
	__stdargs void (*menustatusfunc)(int status, int x, int y);

	ULONG basetime_secs, basetime_micros;
	BOOL havebasetime;
};


extern struct GlutStuff glutstuff;


int stuffGetNewWinID(void);
struct GlutWindow *stuffGetWin(int winid);
void stuffLinkInWin(struct GlutWindow *gw);
void stuffLinkOutWin(struct GlutWindow *gw);
void stuffMakeCurrent(struct GlutWindow *gw);

int stuffGetNewMenuID(void);
struct GlutMenu *stuffGetMenu(int menuid);
void stuffLinkInMenu(struct GlutMenu *gm);
void stuffLinkOutMenu(struct GlutMenu *gm);
void stuffMakeCurrentMenu(struct GlutMenu *gm);

struct GlutMenuEntry *stuffGetMenuEntry(int entry,struct GlutMenu *gm);
void stuffLinkInMenuEntry(struct GlutMenuEntry *gme,struct GlutMenu *gm);
void stuffLinkOutMenuEntry(struct GlutMenuEntry *gme,struct GlutMenu *gm);
