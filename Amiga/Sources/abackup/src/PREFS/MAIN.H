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
#ifndef ABPREFS_MAIN_H
#define ABPREFS_MAIN_H
/*      ___________________

	ABackup Prefs
	main.h

	© 1993-1995
	by Reza Elghazi & Denis Gounelle

	All Rights Reserved
	___________________

	Version : 38.0
	Created : 11-Aug-93
	Modified: 18-Jan-98
	___________________
*/

#define RELEASE "38.4 " __AMIGADATE__
#define PROGRAM "ABackup Preferences V"RELEASE\
				"\n\nCopyright © 1993-1998\nReza Elghazi & Denis Gounelle"

STATIC STRPTR   _VERSION_       = "\0$VER: ABackupPrefs "RELEASE;
STRPTR  		_HELPNAME_      = "abackupprefs.guide";
STRPTR  		_WBSCRNAME_     = "Workbench";

BYTE    OldID,NewID     = WIN_MAIN;
BOOL    AddIcon 	= TRUE;

//______________________________________________________________________________

AMIGAGUIDECONTEXT AGHandle = NULL;

STRPTR NAGContext[] = {
	"Intro",
	"BackupOpt",
	"RestoreOpt",
	"VerifyOpt",
	"CrunchOpt",
	"TapeOpt",
	"GUIOpt",
	"ExternalOpt",
	"MiscOpt",
	NULL
};

#define RAW_HELP	0x5f

#endif  // ABPREFS_MAIN_H
