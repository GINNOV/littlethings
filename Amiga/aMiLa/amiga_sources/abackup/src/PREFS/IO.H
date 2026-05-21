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
#ifndef ABPREFS_IO_H
#define ABPREFS_IO_H
/*	___________________

	ABackup Prefs
	io.h

	© 1993-1995
	by Reza Elghazi & Denis Gounelle

	All Rights Reserved
	___________________

	Version : 38.0
	Created : 15-Sep-93
	Modified: 22-Apr-94
	___________________
*/

#define PREFSVERSION	5
#define PREFSNAME		"ABackup.prefs"

#define PRESETPATH		"SYS:Prefs/Presets"
#define PRESETNAME		"ABackup.pre"

#define READPREFS(n)    ParsePrefs(n,TRUE,FALSE)
#define WRITEPREFS(n)   ParsePrefs(n,FALSE,AddIcon)

#define WRITE_ENV		ParsePrefs(_ENVNAME_,FALSE,FALSE)
#define WRITE_ENVARC	ParsePrefs(_ARCNAME_,FALSE,FALSE)

#endif	// ABPREFS_IO_H
