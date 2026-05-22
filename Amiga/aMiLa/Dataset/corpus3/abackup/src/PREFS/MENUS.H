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
#ifndef ABPREFS_MENUS_H
#define ABPREFS_MENUS_H
/*	___________________

	ABackup Prefs
	menus.h

	© 1993-1995
	by Reza Elghazi & Denis Gounelle

	All Rights Reserved
	___________________

	Version : 38.0
	Created : 22-Sep-93
	Modified: 22-Apr-95
	___________________
*/

struct Menu	*Menus = NULL;

STATIC struct NewMenu	NMenu[] = {
 {NM_TITLE,(STRPTR)MSG_PROJECT                  ,NULL                                   ,0,NULL,NULL},
 {NM_ITEM, (STRPTR)MSG_PROJECT_OPEN             ,(STRPTR)MSG_CK_OPEN    ,0,NULL,NULL},
 {NM_ITEM, (STRPTR)MSG_PROJECT_SAVEAS   ,(STRPTR)MSG_CK_SAVEAS  ,0,NULL,NULL},
 {NM_ITEM, NM_BARLABEL					,NULL					,0,NULL,NULL},
 {NM_ITEM, (STRPTR)MSG_PROJECT_ABOUT    ,(STRPTR)MSG_CK_ABOUT   ,0,NULL,NULL},
 {NM_ITEM, NM_BARLABEL					,NULL					,0,NULL,NULL},
 {NM_ITEM, (STRPTR)MSG_PROJECT_HIDE             ,(STRPTR)MSG_CK_HIDE    ,0,NULL,NULL},
 {NM_ITEM, (STRPTR)MSG_PROJECT_QUIT             ,(STRPTR)MSG_CK_QUIT    ,0,NULL,NULL},

 {NM_TITLE,(STRPTR)MSG_EDIT                             ,NULL                                    ,0,NULL,NULL},
 {NM_ITEM, (STRPTR)MSG_EDIT_DEFAULT             ,(STRPTR)MSG_CK_DEFAULT  ,0,NULL,NULL},
 {NM_ITEM, (STRPTR)MSG_EDIT_LASTSAVED   ,(STRPTR)MSG_CK_LASTSAVED,0,NULL,NULL},
 {NM_ITEM, (STRPTR)MSG_EDIT_RESTORE             ,(STRPTR)MSG_CK_RESTORE  ,0,NULL,NULL},

 {NM_TITLE,(STRPTR)MSG_SETTINGS                  ,NULL                                    ,0,NULL,NULL},
 {NM_ITEM, (STRPTR)MSG_SETTINGS_ICONS    ,(STRPTR)MSG_CK_ICONS    ,0,NULL,NULL},

 {NM_END,NULL,NULL,0,NULL,NULL}
};

#define MNUM(m,i)               ((i&0x3F)<<5)|(m&0x1F)

#define NM_LABEL(n)             NMenu[n].nm_Label
#define NM_COMMKEY(n)   NMenu[n].nm_CommKey

#endif	// ABPREFS_MENUS_H
