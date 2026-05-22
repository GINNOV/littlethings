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
 * glutAttachDetachMenu.c
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


#include <proto/gadtools.h>
#include <proto/intuition.h>

#include <stdlib.h>

#include "glutstuff.h"


struct Menu *GetMenuPointer(int button)
{
	struct Menu *menu;

	menu = glutstuff.curwin->menu;

	switch(button)
	{
		case GLUT_RIGHT_BUTTON:
			menu = menu->NextMenu;
		case GLUT_MIDDLE_BUTTON:
			menu = menu->NextMenu;
		case GLUT_LEFT_BUTTON:
			break;
	}

	return(menu);
}


int CountMenuEntries(struct GlutMenu *gm)
{
	struct GlutMenuEntry *gme;
	int n;

	n = 1;	/* This menu item */

	gme = gm->entries;

	while(gme)
	{
		if(gme->issubmenu)
			n += CountMenuEntries(stuffGetMenu(gme->value))+2;	/* Will include (sub)menu item */
		else
			n++;	/* Just this menu entry */

		gme = gme->next;
	}

	return(n);
}


void FillEntry(struct NewMenu **nm,UBYTE nm_type, STRPTR nm_Label, APTR nm_UserData)
{
	(*nm)->nm_Type = nm_type;
	(*nm)->nm_Label = nm_Label;
	(*nm)->nm_CommKey = 0;
	(*nm)->nm_Flags = 0;
	(*nm)->nm_MutualExclude = 0;
	(*nm)->nm_UserData = nm_UserData;
	(*nm)++;
}


void FillMenu(struct GlutMenu *gm, struct NewMenu **nm,UBYTE type)
{
	struct GlutMenuEntry *gme;

	gme = gm->entries;
	while(gme)
	{
		FillEntry(nm, type, gme->name, gme);
		if(gme->issubmenu)
		{
			if(type == NM_SUB)
			{
				((*nm)-1)->nm_Flags = NM_ITEMDISABLED;
				FillEntry(nm, type, NM_BARLABEL, 0);
			}
			FillMenu(stuffGetMenu(gme->value),nm,NM_SUB);
			if(type == NM_SUB)
				FillEntry(nm, type, NM_BARLABEL, 0);
		}
		gme = gme->next;
	}
}


struct MenuItem *MakeMenu(struct GlutMenu *gm)
{
	struct NewMenu *nm,*nmp;
	int n;
	struct MenuItem *menu;

	n = CountMenuEntries(gm);
	menu = NULL;

	nm = calloc(n+1, sizeof(struct NewMenu));
	if(nm)
	{
		nmp = nm;

		FillMenu(gm,&nmp,NM_ITEM);
		FillEntry(&nmp, NM_END, NULL, 0);

		menu = (struct MenuItem *)CreateMenus(nm, TAG_END);

		free(nm);
	}

	return(menu);
}


void RedoMenu(int button, struct GlutMenu *glutmenu)
{
	struct Menu *menu;
	struct MenuItem *menuitems;

	menu = GetMenuPointer(button);
	ClearMenuStrip(glutstuff.curwin->window);
	FreeMenus(menu->FirstItem);
	if(glutmenu)
	{
		menuitems = MakeMenu(glutmenu);
		menu->FirstItem = menuitems;
		LayoutMenuItems(menuitems,glutstuff.curwin->vi,
				GTMN_Menu,		menu,
				TAG_END);
	}
	else
	{
		menu->FirstItem = NULL;
	}
	SetMenuStrip(glutstuff.curwin->window,glutstuff.curwin->menu);
}


__asm __saveds void glutAttachMenu( register __d0 int button )
{
	switch(button)
	{
		case GLUT_LEFT_BUTTON:
			glutstuff.curwin->leftmenu = glutstuff.curmenu;
			glutstuff.curwin->needleftmenu = TRUE;
			break;
		case GLUT_MIDDLE_BUTTON:
			glutstuff.curwin->middlemenu = glutstuff.curmenu;
			glutstuff.curwin->needmiddlemenu = TRUE;
			break;
		case GLUT_RIGHT_BUTTON:
			glutstuff.curwin->rightmenu = glutstuff.curmenu;
			glutstuff.curwin->needrightmenu = TRUE;
			break;
	}
}


__asm __saveds void glutDetachMenu( register __d0 int button )
{
	switch(button)
	{
		case GLUT_LEFT_BUTTON:
			glutstuff.curwin->leftmenu = NULL;
			glutstuff.curwin->needleftmenu = TRUE;
			break;
		case GLUT_MIDDLE_BUTTON:
			glutstuff.curwin->middlemenu = NULL;
			glutstuff.curwin->needmiddlemenu = TRUE;
			break;
		case GLUT_RIGHT_BUTTON:
			glutstuff.curwin->rightmenu = NULL;
			glutstuff.curwin->needrightmenu = TRUE;
			break;
	}
}
