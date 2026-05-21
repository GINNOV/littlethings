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
    userom.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 11-Dec-94
    Modified: 15-Jan-95
    _______________________________________________________________________
*/
#include "headers.h"

STATIC BPTR InitialDir = (BPTR)-1 ;

//______________________________________________________________________________

BOOL
Access (STRPTR name)
{
	BPTR	lock;

	if (name[0] && (lock = Lock(name,ACCESS_READ))) {
		UnLock(lock);
		return TRUE;
	}
	return FALSE;
}
//______________________________________________________________________________

BOOL
ChDir (STRPTR name)
{
	BPTR	lock;

	if (name[0] && (lock = Lock(name,ACCESS_READ))) {
		if (lock = CurrentDir(lock)) {
			if (InitialDir == (BPTR)-1) InitialDir = lock;
			else if (lock != InitialDir) UnLock(lock);
		}
		return TRUE;
	}
	return FALSE;
}

// Tab size: 4
