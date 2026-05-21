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
    menus.h

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 11-Nov-93
    Modified: 20-Apr-95
    _______________________________________________________________________
*/

#ifndef ABACKUP_MENUS_H
#define ABACKUP_MENUS_H

struct Menu	*Menus = NULL;

STATIC struct NewMenu	NMenu[] = {
 {NM_TITLE,(STRPTR)MSG_PROJECT_MENU,NULL,0,NULL,NULL},
 {NM_ITEM,(STRPTR)MSG_PROJECT_ESTIMATE   ,(STRPTR)MSG_PROJECT_ESTIMATE_CK  ,0,NULL,NULL},
 {NM_ITEM,(STRPTR)MSG_PROJECT_PRINT      ,(STRPTR)MSG_PROJECT_PRINT_CK     ,0,NULL,NULL},
 {NM_ITEM,(STRPTR)MSG_PROJECT_ADDDIR,(STRPTR)MSG_PROJECT_ADDDIR_CK,0,NULL,NULL},
 {NM_ITEM,NM_BARLABEL				 ,NULL							,0,NULL,NULL},
 {NM_ITEM,(STRPTR)MSG_PROJECT_ABOUT      ,(STRPTR)MSG_PROJECT_ABOUT_CK  ,0,NULL,NULL},
 {NM_ITEM,(STRPTR)MSG_PROJECT_QUIT       ,(STRPTR)MSG_PROJECT_QUIT_CK   ,0,NULL,NULL},

 {NM_TITLE,(STRPTR)MSG_SELECT_MENU,NULL,0,NULL,NULL},
 {NM_ITEM,(STRPTR)MSG_SELECT_OPEN       ,(STRPTR)MSG_SELECT_OPEN_CK      ,0,NULL,NULL},
 {NM_ITEM,(STRPTR)MSG_SELECT_RECORD     ,(STRPTR)MSG_SELECT_RECORD_CK,0,NULL,NULL},
 {NM_ITEM,NM_BARLABEL				,NULL						 ,0,NULL,NULL},
 {NM_ITEM,(STRPTR)MSG_SELECT_SAVE       ,(STRPTR)MSG_SELECT_SAVE_CK      ,0,NULL,NULL},
 {NM_ITEM,(STRPTR)MSG_SELECT_ABORT      ,(STRPTR)MSG_SELECT_ABORT_CK ,0,NULL,NULL},

 {NM_END,NULL,NULL,0,NULL,NULL}
};

#define NM_LABEL(n)   NMenu[n].nm_Label
#define NM_COMMKEY(n) NMenu[n].nm_CommKey

//________________________________________________________________ Menu #:

#define MENUNUM_PROJECT_ESTIMATE	BUILDMENUNUM(MENU_PROJECT,MENU_PROJECT_ESTIMATE)
#define MENUNUM_PROJECT_PRINT		BUILDMENUNUM(MENU_PROJECT,MENU_PROJECT_PRINT   )
#define MENUNUM_PROJECT_ADDDIR		BUILDMENUNUM(MENU_PROJECT,MENU_PROJECT_ADDDIR  )

#define MENUNUM_SELECT			BUILDMENUNUM(MENU_SELECT,NOITEM            )
#define MENUNUM_SELECT_OPEN		BUILDMENUNUM(MENU_SELECT,MENU_SELECT_OPEN  )
#define MENUNUM_SELECT_RECORD		BUILDMENUNUM(MENU_SELECT,MENU_SELECT_RECORD)
#define MENUNUM_SELECT_SAVE		BUILDMENUNUM(MENU_SELECT,MENU_SELECT_SAVE  )
#define MENUNUM_SELECT_ABORT		BUILDMENUNUM(MENU_SELECT,MENU_SELECT_ABORT )

#endif	// ABACKUP_MENUS_H
