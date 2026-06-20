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
 * glutDestroyWindow.c
 *
 * Version 1.0  27 Jun 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * Version 2.0  19 Sep 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * - Changed to runtime library format
 * - Close window only if mywindow flag set
 *
 */


#include <proto/intuition.h>
#include <proto/exec.h>
#include <proto/gadtools.h>

#include <stdlib.h>

#include "glutstuff.h"


VOID StripIntuiMessages(struct MsgPort *mp, struct Window *win)
{
	struct IntuiMessage *msg;
	struct Node *succ;

	msg = (struct IntuiMessage *)mp->mp_MsgList.lh_Head;

	while(succ = msg->ExecMessage.mn_Node.ln_Succ)
	{
		if(msg->IDCMPWindow == win)
		{
			Remove(msg);

			ReplyMsg(msg);
		}
		msg = (struct IntuiMessage *)succ;
	}
}


VOID CloseWindowSafely(struct Window *win)
{
	Forbid();
	StripIntuiMessages(win->UserPort, win);
	win->UserPort = NULL;
	ModifyIDCMP(win, 0L);
	Permit();

	CloseWindow(win);
}


__asm __saveds void glutDestroyWindow( register __d0 int win )
{
	struct GlutWindow *gw;
	struct Menu *menu;

	gw = stuffGetWin(win);

	stuffLinkOutWin(gw);

	ClearMenuStrip(gw->window);
	menu = gw->menu;
	while(menu)
	{
		FreeMenus(menu->FirstItem);
		menu->FirstItem = NULL;
		menu = menu->NextMenu;
	}
	FreeMenus(gw->menu);

	FreeVisualInfo(gw->vi);

	if(!gw->mywindow)
	{
		gw->window->UserPort = NULL;
		ModifyIDCMP(gw->window, 0);
	}

	AmigaMesaRTLDestroyContext(gw->context);

	if(gw->mywindow)
		CloseWindowSafely(gw->window);

	free(gw);
}
