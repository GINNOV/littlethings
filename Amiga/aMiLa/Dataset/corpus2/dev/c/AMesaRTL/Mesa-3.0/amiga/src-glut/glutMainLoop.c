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
 * glutMainLoop.c
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
 * - Added ^C checking
 * - ChangeWindowBox() only when window can
 * - Fixed: Mouse positions were off, added border correction
 *
 */


#include <dos/dos.h>

#include <proto/intuition.h>
#include <proto/gadtools.h>
#include <proto/exec.h>

#include "glutstuff.h"


extern void RedoMenu(int button, struct GlutMenu *glutmenu);


int ConvRaw(UWORD code,UWORD qual)
{
	switch(code)
	{
		case CURSORLEFT:
			return GLUT_KEY_LEFT;
		case CURSORUP:
			return GLUT_KEY_UP;
		case CURSORRIGHT:
			return GLUT_KEY_RIGHT;
		case CURSORDOWN:
			return GLUT_KEY_DOWN;
		case 0x50:
			return GLUT_KEY_F1;
		case 0x51:
			return GLUT_KEY_F2;
		case 0x52:
			return GLUT_KEY_F3;
		case 0x53:
			return GLUT_KEY_F4;
		case 0x54:
			return GLUT_KEY_F5;
		case 0x55:
			return GLUT_KEY_F6;
		case 0x56:
			return GLUT_KEY_F7;
		case 0x57:
			return GLUT_KEY_F8;
		case 0x58:
			return GLUT_KEY_F9;
		case 0x59:
			return GLUT_KEY_F10;
	}

	return 0;
}


int ConvToButton(UWORD code,UWORD qual)
{
	switch(code)
	{
		case SELECTUP:
		case SELECTDOWN:
			if(qual & IEQUALIFIER_RCOMMAND)
				return GLUT_MIDDLE_BUTTON;
			if(qual & IEQUALIFIER_RALT)
				return GLUT_RIGHT_BUTTON;
			return GLUT_LEFT_BUTTON;
		case MIDDLEUP:
		case MIDDLEDOWN:
			return GLUT_MIDDLE_BUTTON;
		case MENUUP:
		case MENUDOWN:
			return GLUT_RIGHT_BUTTON;
	}

	return 0;
}


int ConvToButtonState(UWORD code)
{
	switch(code)
	{
		case SELECTUP:
		case MIDDLEUP:
		case MENUUP:
			return GLUT_UP;
		case SELECTDOWN:
		case MIDDLEDOWN:
		case MENUDOWN:
			return GLUT_DOWN;
	}

	return 0;
}


__asm __saveds void glutMainLoop( void )
{
	struct IntuiMessage *msg, cmsg;
	struct GlutWindow *gw;
	struct GlutMenu *gm;
	struct GlutMenuEntry *gme;
	struct MenuItem *item;
	UWORD menuNumber;
	BOOL idleing, wanttoquit;
	ULONG signals;

	wanttoquit = FALSE;
	while(1)
	{
		// Apply changes
		//
		for(gw = glutstuff.wins; gw; gw = gw->next)
		{
			stuffMakeCurrent(gw);

			if(gw->needposition)
			{
				gw->needposition = FALSE;
				gw->needpositiongui = FALSE;
				// Let the change be made through the gui
				if(gw->window->Flags & WFLG_DRAGBAR)
					ChangeWindowBox(gw->window,gw->winx,gw->winy,gw->winwidth,gw->winheight);
			}

			if(gw->needpositiongui)
			{
				gw->needpositiongui = FALSE;
			}

			if(gw->needreshape)
			{
				gw->needreshape = FALSE;
				gw->needreshapegui = FALSE;		/* Reshaping and redisplaying is useless */
				gw->needredisplay = FALSE;		/* this round. Change is inevitable */
				// Let the change be made through the gui
				if(gw->window->Flags & WFLG_DRAGBAR)
					ChangeWindowBox(gw->window,gw->winx,gw->winy,gw->winwidth,gw->winheight);
			}

			if(gw->needreshapegui)
			{
				gw->needreshapegui = FALSE;
				if(gw->reshapefunc)
					gw->reshapefunc(WIN_WIDTH(gw->window), WIN_HEIGHT(gw->window));
			}

			if(gw->needredisplay)
			{
				gw->needredisplay = FALSE;
				if(gw->displayfunc)
					gw->displayfunc();
			}
			if(gw->needvisibility)
			{
				gw->needvisibility = FALSE;
				if(gw->visibilityfunc)
					gw->visibilityfunc(gw->visible ? GLUT_VISIBLE : GLUT_NOT_VISIBLE);
			}
			if((gw->leftmenu && gw->leftmenu->needupdate) || gw->needleftmenu)
			{
				gw->needleftmenu = FALSE;
				RedoMenu(GLUT_LEFT_BUTTON, gw->leftmenu);
			}
			if((gw->middlemenu && gw->middlemenu->needupdate) || gw->needmiddlemenu)
			{
				gw->needmiddlemenu = FALSE;
				RedoMenu(GLUT_MIDDLE_BUTTON, gw->middlemenu);
			}
			if((gw->rightmenu && gw->rightmenu->needupdate) || gw->needrightmenu)
			{
				gw->needrightmenu = FALSE;
				RedoMenu(GLUT_RIGHT_BUTTON, gw->rightmenu);
			}
		}

		for(gm = glutstuff.menus; gm; gm = gm->next)
		{
			stuffMakeCurrentMenu(gm);
			gm->needupdate = FALSE;
		}

		// Wait for something to happen
		//
		if(glutstuff.idlefunc == NULL)
			Wait(1L<<glutstuff.msgport->mp_SigBit);

		// Handle all messages (if any)
		//
		idleing = TRUE;
		while(msg = (struct IntuiMessage *)GetMsg(glutstuff.msgport))
		{
			cmsg = *msg;
			cmsg.MouseX -= cmsg.IDCMPWindow->BorderLeft;
			cmsg.MouseY -= cmsg.IDCMPWindow->BorderTop;

			ReplyMsg((struct Message *)msg);

			stuffMakeCurrent((struct GlutWindow *)(cmsg.IDCMPWindow->UserData));

			glutstuff.curwin->qualifiers = cmsg.Qualifier;

			switch(cmsg.Class)
			{
				case IDCMP_CHANGEWINDOW:
					idleing = FALSE;
					glutstuff.curwin->winx = glutstuff.curwin->window->LeftEdge;
					glutstuff.curwin->winy = glutstuff.curwin->window->TopEdge;
					glutstuff.curwin->winwidth = glutstuff.curwin->window->Width;
					glutstuff.curwin->winheight = glutstuff.curwin->window->Height;
					if((glutstuff.curwin->window->Width != glutstuff.curwin->wincurwidth) ||
					   (glutstuff.curwin->window->Height != glutstuff.curwin->wincurheight))
					{
						glutstuff.curwin->wincurwidth = glutstuff.curwin->window->Width;
						glutstuff.curwin->wincurheight = glutstuff.curwin->window->Height;
						glutstuff.curwin->needreshapegui = TRUE;
						glutstuff.curwin->needredisplay = TRUE;
					}
					if((glutstuff.curwin->window->LeftEdge != glutstuff.curwin->wincurx) ||
					   (glutstuff.curwin->window->TopEdge != glutstuff.curwin->wincury))
					{
						glutstuff.curwin->wincurx = glutstuff.curwin->window->LeftEdge;
						glutstuff.curwin->wincury = glutstuff.curwin->window->TopEdge;
						glutstuff.curwin->needpositiongui = TRUE;
					}
					break;
				case IDCMP_VANILLAKEY:
					if(glutstuff.curwin->keyboardfunc)
					{
						idleing = FALSE;
						glutstuff.curwin->keyboardfunc(cmsg.Code,cmsg.MouseX,cmsg.MouseY);
					}
					break;
				case IDCMP_RAWKEY:
					if(glutstuff.curwin->specialfunc)
					{
						idleing = FALSE;
						glutstuff.curwin->specialfunc(ConvRaw(cmsg.Code,cmsg.Qualifier),cmsg.MouseX,cmsg.MouseY);
					}
					break;
				case IDCMP_MENUPICK:
					menuNumber = cmsg.Code;
					while(menuNumber != MENUNULL)
					{
						item = ItemAddress(glutstuff.curwin->menu, menuNumber);
						gme = (struct GlutMenuEntry *)GTMENUITEM_USERDATA(item);
						stuffMakeCurrentMenu(gme->menu);
						if(glutstuff.curmenu->menufunc)
						{
							idleing = FALSE;
							glutstuff.curmenu->menufunc(gme->value);
						}
						menuNumber = item->NextSelect;
					}
					break;
				case IDCMP_CLOSEWINDOW:
					if(wanttoquit)
					{
						// User wants to quit, but ESC doesn't do anything
						// Panic, and return in the hope that it will drop
						// through to an end-of-program call.
						// (Note that we don't use exit(), as we may want
						// to put all this in a run-time library).
						return;
					}
					if(glutstuff.curwin->keyboardfunc)
					{
						idleing = FALSE;
						glutstuff.curwin->keyboardfunc(27,0,0);
					}
					wanttoquit = TRUE;
					break;
				case IDCMP_MOUSEBUTTONS:
					if(glutstuff.curwin->mousefunc)
					{
						idleing = FALSE;
						glutstuff.curwin->mousefunc(ConvToButton(cmsg.Code,cmsg.Qualifier),ConvToButtonState(cmsg.Code),cmsg.MouseX,cmsg.MouseY);
					}
					break;
				case IDCMP_INTUITICKS:
					if((glutstuff.curwin->mousex != cmsg.MouseX) ||
					   (glutstuff.curwin->mousey != cmsg.MouseY))
					{
						glutstuff.curwin->mousex = cmsg.MouseX;
						glutstuff.curwin->mousey = cmsg.MouseY;
						if((cmsg.Qualifier & IEQUALIFIER_LEFTBUTTON) &&
						   (glutstuff.curwin->motionfunc))
						{
							idleing = FALSE;
							glutstuff.curwin->motionfunc(cmsg.MouseX,cmsg.MouseY);
						}
						else if(glutstuff.curwin->passivemotionfunc)
						{
							idleing = FALSE;
							glutstuff.curwin->passivemotionfunc(cmsg.MouseX,cmsg.MouseY);
						}
					}
					break;
			}
		}

		// Check to see if ^C was pressed
		//
		signals = SetSignal(0L,0L);
		if(signals & SIGBREAKF_CTRL_C)
		{
			SetSignal(0L,SIGBREAKF_CTRL_C);

			// Panic exit
			return;
		}

		// If nothing is happening, call the idle function
		//
		if(idleing && glutstuff.idlefunc)
			glutstuff.idlefunc();
	}
}
