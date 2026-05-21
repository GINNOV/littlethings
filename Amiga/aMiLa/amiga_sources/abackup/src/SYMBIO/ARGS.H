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
    args.h

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 11-Dec-94
    Modified: 23-Sep-95
    _______________________________________________________________________
*/
#ifndef ABACKUP_ARGS_H
#define ABACKUP_ARGS_H

//________________________________________________________ arguments structure:

typedef struct ABackupArgs
{
	ULONG arg_Mode;
	ULONG arg_Flags;

	UBYTE arg_Source[MAXSTR];
	UBYTE arg_Destination[MAXSTR];

	UBYTE arg_PrefsFile[MAXSTR];
	UBYTE arg_SelectionFile[MAXSTR];
	UBYTE arg_ReportFile[MAXSTR];
	UBYTE arg_CatalogFile[MAXSTR];

	UBYTE arg_PrefsPath[MAXSTR];
	UBYTE arg_HelpPath[MAXSTR];

	UBYTE arg_ECSuffix[MAXSTR];

	UBYTE arg_IconPath[MAXSTR];
} ABARGS;

// flags for ABackupArgs.arg_Mode:
#define AMD_BACKUP	0x0001
#define AMD_RESTORE	0x0002
#define AMD_VERIFY	0x0004

// flags for ABackupArgs.arg_Flags:
#define AFL_QUIET	0x0001
#define AFL_IMAGE	0x0002

// default args settings:
/*
#define DEF_ARG_MODE
#define DEF_ARG_FLAGS
*/
// args shorties:
#define ARG_MODE	Args.arg_Mode
#define ARG_FLAGS	Args.arg_Flags
#define ARG_FROM	Args.arg_Source
#define ARG_TO		Args.arg_Destination
#define ARG_PREFS	Args.arg_PrefsFile
#define ARG_SELECT	Args.arg_SelectionFile
#define ARG_REPORT	Args.arg_ReportFile
#define ARG_CATALOG	Args.arg_CatalogFile
#define ARG_PPATH	Args.arg_PrefsPath
#define ARG_HPATH	Args.arg_HelpPath
#define ARG_ECSUFFIX	Args.arg_ECSuffix
#define ARG_ICONPATH	Args.arg_IconPath

// binary tests on args:
#define IS_ARG_BACKUP	AND(ARG_MODE,AMD_BACKUP)
#define IS_ARG_RESTORE	AND(ARG_MODE,AMD_RESTORE)
#define IS_ARG_VERIFY	AND(ARG_MODE,AMD_VERIFY)

#define IS_ARG_QUIET	AND(ARG_FLAGS,AFL_QUIET)
#define IS_ARG_IMAGE	AND(ARG_FLAGS,AFL_IMAGE)

#endif	// ABACKUP_ARGS_H
