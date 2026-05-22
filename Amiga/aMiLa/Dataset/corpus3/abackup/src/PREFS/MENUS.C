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
/*	___________________

	ABackup Prefs
	menus.c

	© 1993-1995
	by Reza Elghazi & Denis Gounelle

	All Rights Reserved
	___________________

	Version : 38.0
	Created : 22-Sep-93
	Modified: 22-Apr-95
	___________________
*/

#include "headers.h"
#include "menus.h"

VOID
SetupMenus()
{
	ULONG	flags = MENUTOGGLE|CHECKIT;
	UBYTE	n;

	for (n = 0; n < MENU_COUNT-1; n++) {
		if (NM_LABEL(n) == NM_BARLABEL) continue;

		NM_LABEL(n) = GetStr((LONG)NM_LABEL(n));
		if (NM_COMMKEY(n)) NM_COMMKEY(n) = GetStr((LONG)NM_COMMKEY(n));
	}

	NMenu[13].nm_Flags = flags|(AddIcon? CHECKED: 0);

	Menus = CreateMenusA(NMenu,TAG_DONE);
	if (NOT Menus) WARNING(MSG_WARN_CREATE_MENUS);
}

// Tab size: 4
