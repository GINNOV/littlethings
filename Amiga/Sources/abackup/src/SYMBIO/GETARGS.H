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
    getargs.h

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 15-Dec-93
    Modified: 23-Sep-95
    _______________________________________________________________________
*/
#ifndef ABACKUP_GETARGS_H
#define ABACKUP_GETARGS_H

GLOBAL struct WBStartup *_WBenchMsg;

ABARGS	Args;

//__________________________________________________ Workbench icon tool types:

#define TT_FROM 		"FROM"
#define TT_TO			"TO"
#define TT_MODE 		"MODE"
#define TT_IMAGE		"IMAGE"
#define TT_SELECT		"SELECT"
#define TT_REPORT		"REPORT"
#define TT_CATALOG		"CATALOG"
#define TT_PREFS		"PREFS"
#define TT_PREFSPATH		"PREFSPATH"
#define TT_HELPPATH		"HELPPATH"
#define TT_ECSUFFIX		"ECSUFFIX"
#define TT_ICONPATH		"ICONPATH"

#define TTMODE_BACKUP		"BACKUP"
#define TTMODE_RESTORE		"RESTORE"
#define TTMODE_VERIFY		"VERIFY"

//_______________________________________________________________ CLI template:

#define TEMPLATE "FROM/K/A,TO/K,B=BACKUP/S,R=RESTORE/S,V=VERIFY/S,IMG=IMAGE/S,SEL=SELECT/K,REP=REPORT/K,CAT=CATALOG/K,PRF=PREFS/K,QUIET/S,SFX=ECSUFFIX/K,IP=ICONPATH/K"

#define OPT_FROM	 0
#define OPT_TO		 1
#define OPT_BACKUP	 2
#define OPT_RESTORE	 3
#define OPT_VERIFY	 4
#define OPT_IMAGE	 5
#define OPT_SELECT	 6
#define OPT_REPORT	 7
#define OPT_CATALOG	 8
#define OPT_PREFS	 9
#define OPT_QUIET	10
#define OPT_ECSUFFIX	11
#define OPT_ICONPATH	12

#define OPT_COUNT	13

#endif	// ABACKUP_GETARGS_H
