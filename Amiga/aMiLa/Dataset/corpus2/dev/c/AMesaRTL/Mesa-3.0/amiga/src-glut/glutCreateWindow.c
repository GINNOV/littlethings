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
 * glutCreateWindow.c
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
 * - Changed to v2 mesa.library and quantizer usage
 * - Changed to runtime library format
 * - Changed quantizer to output handler
 * - Bugfix: TAG_SKIP values were wrong, fixed to skip 1
 *   instead of 2
 * - Output screen/window created only when output handler
 *   doesn't make one or handerwindow==FALSE
 *
 */


#include <proto/intuition.h>
#include <proto/gadtools.h>

#include <stdlib.h>

#include "glutstuff.h"
#include "gl/outputhandler.h"

extern VOID CloseWindowSafely(struct Window *win);

struct NewMenu defmenu[] = {
	{ NM_TITLE,	"Left Menu",	0, 0, 0, 0, },
	{ NM_TITLE,	"Middle Menu",	0, 0, 0, 0, },
	{ NM_TITLE,	"Right Menu",	0, 0, 0, 0, },
	{ NM_END,	NULL,			0, 0, 0, 0, }
};


__asm __saveds int glutCreateWindow( register __a0 const char *title )
{
	struct GlutWindow *gw;
	struct Screen *screen;
	WORD zoom[4];

	gw = calloc(1,sizeof(struct GlutWindow));
	if(gw)
	{
		gw->context = NULL;

		if(glutstuff.handlerwindow)
		{
			gw->mywindow = FALSE;

			gw->context = AmigaMesaRTLCreateContext(
								OH_Output,				0,
								OH_OutputType,			"Window",
								AMRTL_RGBAMode,			glutstuff.rgba,
								TAG_SKIP,				glutstuff.oh == NULL ? 1 : 0,
								AMRTL_OutputHandler,	glutstuff.oh,
								TAG_SKIP,				glutstuff.ohversion == -1 ? 1 : 0,
								AMRTL_OutputHandlerVersion,	glutstuff.ohversion,
								TAG_END);
			if(gw->context)
			{
				/* Hijack the window */

				AmigaMesaRTLGetOutputHandlerAttr(OH_Output,gw->context,&gw->window);
				if (gw->window->Flags & WFLG_DRAGBAR)
					ChangeWindowBox(gw->window,glutstuff.initposx,glutstuff.initposy,glutstuff.initwidth,glutstuff.initheight);
				if (!(gw->window->Flags & WFLG_BORDERLESS))
					SetWindowTitles(gw->window,title,~0);
				gw->window->UserPort = glutstuff.msgport;
			}
		}

		if(!gw->context)
		{
			gw->mywindow = TRUE;

			screen = LockPubScreen(glutstuff.pubscreenname);
			zoom[0] = glutstuff.initposx;
			zoom[1] = glutstuff.initposy;
			zoom[2] = glutstuff.initwidth;
			zoom[3] = glutstuff.initheight;
			gw->window = OpenWindowTags(NULL,
					WA_Title,				title,
					WA_PubScreen,			screen,

					WA_Left,				glutstuff.initposx,
					WA_Top,					glutstuff.initposy,
					WA_Width,				glutstuff.initwidth,
					WA_Height,				glutstuff.initheight,
					WA_MinWidth,			32,
					WA_MinHeight,			32,
					WA_MaxWidth,			~0,
					WA_MaxHeight,			~0,

					WA_NoCareRefresh,		TRUE,
					WA_Activate,			TRUE,

					WA_CloseGadget,			TRUE,
					WA_DragBar,				TRUE,
					WA_SizeGadget,			TRUE,
					WA_DepthGadget,			TRUE,
					WA_Zoom,				zoom,

					TAG_END);
			UnlockPubScreen(NULL,screen);

			if(gw->window)
			{
				gw->window->UserPort = glutstuff.msgport;
				gw->context = AmigaMesaRTLCreateContext(
									OH_Output,				gw->window,
									OH_OutputType,			"Window",
									AMRTL_RGBAMode,			glutstuff.rgba,
									TAG_SKIP,				glutstuff.oh == NULL ? 1 : 0,
									AMRTL_OutputHandler,	glutstuff.oh,
									TAG_SKIP,				glutstuff.ohversion == -1 ? 1 : 0,
									AMRTL_OutputHandlerVersion,	glutstuff.ohversion,
									TAG_END);
			}
		}

		if(gw->context)
		{
			if(ModifyIDCMP(gw->window,IDCMP_CLOSEWINDOW | IDCMP_VANILLAKEY | IDCMP_RAWKEY | IDCMP_MENUPICK | IDCMP_MOUSEBUTTONS | IDCMP_INTUITICKS | IDCMP_CHANGEWINDOW))
			{
				gw->winid = stuffGetNewWinID();
				gw->window->UserData = (APTR)gw;

        		gw->vi = GetVisualInfo(gw->window->WScreen, TAG_END);

        		gw->menu = CreateMenus(defmenu, TAG_END);
				LayoutMenus(gw->menu, gw->vi, TAG_END);
				SetMenuStrip(gw->window, gw->menu);

				gw->qualifiers = 0;
				gw->mousex = -1;
				gw->mousey = -1;

				gw->winx = gw->wincurx = gw->window->LeftEdge;
				gw->winy = gw->wincury = gw->window->TopEdge;
				gw->winwidth = gw->wincurwidth = gw->window->Width;
				gw->winheight = gw->wincurheight = gw->window->Height;

				stuffLinkInWin(gw);

				if(glutstuff.depth)
					glEnable(GL_DEPTH_TEST);

				gw->displayfunc = NULL;
				gw->keyboardfunc = NULL;
				gw->reshapefunc = NULL;
				gw->visibilityfunc = NULL;
				gw->specialfunc = NULL;
				gw->mousefunc = NULL;

				gw->needreshape = FALSE;
				gw->needreshapegui = TRUE;
				gw->needposition = FALSE;
				gw->needpositiongui = TRUE;
				gw->needredisplay = TRUE;
				gw->needvisibility = TRUE;
				gw->visible = TRUE;
				gw->needleftmenu = TRUE;
				gw->needmiddlemenu = TRUE;
				gw->needrightmenu = TRUE;

				return(gw->winid);
			}

			if(!gw->mywindow)
			{
				gw->window->UserPort = NULL;
				ModifyIDCMP(gw->window, 0L);
			}
			AmigaMesaRTLDestroyContext(gw->context);
		}

		if(gw->window && gw->mywindow)
			CloseWindowSafely(gw->window);

		free(gw);
	}

	return(0);
}
