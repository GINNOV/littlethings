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
#ifndef ABPREFS_MACROS_H
#define ABPREFS_MACROS_H
/*	___________________

	ABackup Prefs
	macros.h

	© 1993-1995
	by Reza Elghazi & Denis Gounelle

	All Rights Reserved
	___________________

	Version : 38.0
	Created : 11-Aug-93
	Modified: 22-Apr-95
	___________________
*/

//_______________________________________________________________ binary macros:

#define AND(a,b)        ((a)&(b))
#define OR(a,b)         ((a)|=(b))
#define XOR(a,b)        ((a)^=(b))
#define DEL(a,b)        OR(a,b);XOR(a,b)

//______________________________________________ MWin's MinGadget access macros:

#define GD_LEFT(g)              MWin[NewID].mw_Gad[g].mg_LeftEdge
#define GD_TOP(g)               MWin[NewID].mw_Gad[g].mg_TopEdge
#define GD_WIDTH(g)             MWin[NewID].mw_Gad[g].mg_Width
#define GD_HEIGHT(g)    MWin[NewID].mw_Gad[g].mg_Height
#define GD_TYPE(g)              MWin[NewID].mw_Gad[g].mg_Type
#define GD_TEXT(g)              MWin[NewID].mw_Gad[g].mg_Text
#define GD_FLAGS(g)             MWin[NewID].mw_Gad[g].mg_Flags
#define GD_TAGS(g)              MWin[NewID].mw_Gad[g].mg_Tags

#define GD_COUNT(ID)    MWin[ID].mw_GadCnt

//___________________________________________________ keyboard shortcuts macros:

#define CASE_UPPER			TRUE
#define CASE_LOWER			FALSE

#define UPPER_CUT(textID)       Shortcut(code,textID,CASE_UPPER)
#define LOWER_CUT(textID)       Shortcut(code,textID,CASE_LOWER)
#define SHORT_CUT(textID)       (UPPER_CUT(textID)||LOWER_CUT(textID))

//__________________________________________________________ file access macros:

#define CHECKNONE	0
#define CHECKDIR	1
#define CHECKFILE	2

#define GETSTR(name)            CheckAccess(gadID,name,CHECKNONE)
#define ISDIRVALID(name)        CheckAccess(gadID,name,CHECKDIR)
#define ISFILEVALID(name)       CheckAccess(gadID,name,CHECKFILE)

//________________________________________________________ miscellaneous macros:

#define FLIP(n)                         ((n)=NOT(n))

#define GDST_BUF			((struct StringInfo *)Gads[gadID]->SpecialInfo)->Buffer
#define GDST_COPY(s)            strcpy(s,GDST_BUF)

#define GDIN_INT			((struct StringInfo *)Gads[gadID]->SpecialInfo)->LongInt
#define GDIN_COPY(i)            i = GDIN_INT

#define LOADDIR(name)           LoadFile(name,DIRONLY,MSG_SELECT_DIRECTORY)
#define LOADFILE(name)          LoadFile(name,FILEONLY,MSG_SELECT_FILE)
#define LOADPREFS(name)         LoadFile(name,FILEONLY,MSG_LOAD_PREFS)
#define SAVEPREFS(name)         LoadFile(name,FILEONLY,MSG_SAVE_PREFS)

#define WARNING(msg)            Notify(MSG_WARNING,GetStr(msg),MSG_RESUME,NULL)

#define GFXV39PLUS			(GfxBase->LibNode.lib_Version >= 39)
#define GTLIBV39			(GadToolsBase->lib_Version == 39)
#define GTV39PLUS			(GadToolsBase->lib_Version >= 39)
#define INTUITIONV39PLUS	(IntuitionBase->LibNode.lib_Version >= 39)

//_______________________________________________________ miscellaneous defines:

#define QUIT		-1
#define USE			 0
#define SAVE		 1
#define RESTORE 	 2
#define APPEAR		 3
#define DISAPPEAR	 4

#define DISABLE 	TRUE
#define ENABLE		FALSE

#define FORWARD 	TRUE
#define BACKWARD	FALSE

#define DIRONLY 	0
#define FILEONLY	1
#define DIRORFILE	2

#endif	// ABPREFS_MACROS_H
