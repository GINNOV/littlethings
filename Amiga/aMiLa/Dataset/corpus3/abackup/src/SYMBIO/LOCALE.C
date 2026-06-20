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
    locale.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 30-Nov-93
    Modified: 22-Dec-94
    _______________________________________________________________________
*/
#define CATCOMP_BLOCK
#include "locale.h"
#undef CATCOMP_BLOCK
#include "headers.h"

STATIC VOID	ReformatString	(STRPTR);

STRPTR
GetStr (LONG ID)
{
	LONG	*l;
	UWORD	*w;
	STRPTR	str;

	if (Catalog && (str = GetCatalogStr(Catalog,ID,NULL)));
	else {
		l = (LONG *)CatCompBlock;
		while (*l != ID) {
			w = (UWORD *)((ULONG)l+4);
			l = (LONG *)((ULONG)l+(ULONG)*w+6);
#ifdef _DEBUG
			if (l > (LONG *)&CatCompBlock[sizeof(CatCompBlock)]) str = "Bad ID";
#endif
		}
		str = (STRPTR)((ULONG)l+6);
	}
	return str;
}
//______________________________________________________________________________

VOID
ReformatBlock()
{
	LONG	*l,size;
	UWORD	*w;

	// reformat only if locale has installed its patches:
	if (LOCALEPATCHED) {
		l = (LONG *)CatCompBlock;
		size = sizeof(CatCompBlock)-1;

		while (l < (LONG *)&CatCompBlock[size]) {
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
		if (*++s == '-')	s++;	// skip flags
		while(isdigit(*s))	s++;	// skip width
		if (*s == 'l')		s++;	// skip length

			 if (*s == 'd') *s = 'D';
		else if (*s == 'u') *s = 'U';
	}
}

// Tab size: 4