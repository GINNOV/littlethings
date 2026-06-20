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
    utility.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 02-Nov-93
    Modified: 17-Dec-94
    _______________________________________________________________________
*/
#include "headers.h"

struct TagItem	BusyTags[] = {
	{WA_BusyPointer,	TRUE},
	{WA_PointerDelay,	TRUE},
	{TAG_DONE}
};

STATIC LONG	LockCount = 0L;
STATIC struct Requester	Req;

VOID
BlockWinInput()
{
	// using a requester to block window input:
	if (Win) {
		if (NOT LockCount) {
			if (IntuitionBase->LibNode.lib_Version >= 39)
				SetWindowPointerA(Win,BusyTags);

			InitRequester(&Req);
			Request(&Req,Win);
		}
		LockCount++;
	}
}
//______________________________________________________________________________

VOID
ReleaseWinInput()
{
	if (Win) {
		LockCount--;
		if (NOT LockCount) {
			if (&Req) EndRequest(&Req,Win);
			ClearPointer(Win);
		}
	}
}
//______________________________________________________________________________

// test if 'code' is a shortcut for the given string..
BOOL
Shortcut (STRPTR text,UWORD code)
{
	UBYTE	*p;

	p = strchr(text,'_');

	return(BOOL)(p && (ToUpper(code) == ToUpper(p[1])));
}

// Tab size: 4