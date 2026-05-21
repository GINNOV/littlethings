/*
* This file is part of ABackup.
* Copyright (C) 1999 Denis Gounelle
* 
* ABackup is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* ABackup is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with ABackup.  If not, see <http://www.gnu.org/licenses/>.
*
*/
/*  _______________________________________________________________________

    ABackup 5.0
    menus.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 11-Nov-93
    Modified: 14-Apr-95
    _______________________________________________________________________
*/
#include "headers.h"
#include "menus.h"

//______________________________________________________________________________

VOID
SetupMenus()
{
	UBYTE	n;

	for (n = 0; n < NM_COUNT-1; n++) {
		if (NM_LABEL(n) == NM_BARLABEL) continue;

		NM_LABEL(n) = GetStr((LONG)NM_LABEL(n));
		if (NM_COMMKEY(n)) NM_COMMKEY(n) = GetStr((LONG)NM_COMMKEY(n));
	}

//	NMenu[NMID_ITEM_ICONIFY].nm_CommKey = NM_MENUDISABLED;

	Menus = CreateMenusA(NMenu,TAG_DONE);
	if (NOT Menus) Warning(MSG_WARN_CREATE_MENUS);
}
//______________________________________________________________________________

VOID
PrepareMenus(BOOL recording)
{
	if (! Menus) return;

	if (NewID == WIN_SELECTION) {
		OnMenu(Win,MENUNUM_PROJECT_PRINT);
		OnMenu(Win,MENUNUM_SELECT);

		if (PrgAction == PA_BACKUP)
		  OnMenu(Win,MENUNUM_PROJECT_ESTIMATE);
		else
		  OffMenu(Win,MENUNUM_PROJECT_ESTIMATE);

		if ( (PrgAction == PA_BACKUP) && (pGRoot != DevList) )
		  OnMenu(Win,MENUNUM_PROJECT_ADDDIR);
		else
		  OffMenu(Win,MENUNUM_PROJECT_ADDDIR);

		if (recording) {
			OffMenu(Win,MENUNUM_SELECT_OPEN);
			OffMenu(Win,MENUNUM_SELECT_RECORD);

			OnMenu(Win,MENUNUM_SELECT_SAVE);
			OnMenu(Win,MENUNUM_SELECT_ABORT);
		}
		else {
			OnMenu(Win,MENUNUM_SELECT_OPEN);
			OnMenu(Win,MENUNUM_SELECT_RECORD);

			OffMenu(Win,MENUNUM_SELECT_SAVE);
			OffMenu(Win,MENUNUM_SELECT_ABORT);
		}
	}
	else {
		OffMenu(Win,MENUNUM_PROJECT_ESTIMATE);
		OffMenu(Win,MENUNUM_PROJECT_PRINT);
		OffMenu(Win,MENUNUM_PROJECT_ADDDIR);
		OffMenu(Win,MENUNUM_SELECT);
		AbortSelect();
	}
}

// Tab size: 4
