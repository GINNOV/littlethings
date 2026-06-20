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
	locale.c

	© 1993-1995
	by Reza Elghazi & Denis Gounelle

	All Rights Reserved
	___________________

	Version : 38.0
	Created : 11-Aug-93
	Modified: 22-Apr-95
	___________________
*/

#include <ctype.h>

#define CATCOMP_BLOCK
#include "locale.h"
#undef CATCOMP_BLOCK
#include "headers.h"

STATIC VOID	ReformatString	(STRPTR);

STRPTR
GetStr (LONG ID)
{
	LONG	*l = (LONG *)ABPrefsBlock;
	UWORD	*w;
	STRPTR	builtIn;

	while (*l != ID) {
		w = (UWORD *)((ULONG)l+4);
		l = (LONG *)((ULONG)l+(ULONG)*w+6);
	}
	builtIn = (STRPTR)((ULONG)l+6);

	if (Catalog) return(GetCatalogStr(Catalog,ID,builtIn));
	else		 return(builtIn);
}
//______________________________________________________________________________

VOID
ReformatBlock()
{
	LONG	*l,size;
	UWORD	*w;

	// reformat only if locale has installed its patches:
	if (LocaleBase && LocaleBase->lb_SysPatches) {
		l = (LONG *)ABPrefsBlock;
		size = sizeof(ABPrefsBlock)-1;

		while (l < (LONG *)&ABPrefsBlock[size]) {
			ReformatString((STRPTR)((ULONG)l+6));
			w = (UWORD *)((ULONG)l+4);
			l = (LONG *)((ULONG)l+(ULONG)*w+6);
		}
	}
}
//______________________________________________________________________________

__inline STATIC VOID
ReformatString (STRPTR s)
{
	while (s = strchr(s,'%')) {
		if (*++s == '-')        s++;    // skip flags
		while(isdigit(*s))      s++;    // skip width
		if (*s == 'l')          s++;    // skip length

			 if (*s == 'd') *s = 'D';
		else if (*s == 'u') *s = 'U';
	}
}
//______________________________________________________________________________

// searches a localized string for "_" and compares code with next character..
BOOL
Shortcut (UWORD code,WORD ID,BOOL keycase)
{
	UBYTE	*p,c;

	p = strchr(GetStr(ID),'_');
	c = keycase? ToUpper(p[1]): ToLower(p[1]);

	return(BOOL)(p && code == c);
}

// Tab size 4
