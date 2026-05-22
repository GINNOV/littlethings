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
#ifndef ABPREFS_XPK_H
#define ABPREFS_XPK_H
/*	___________________

	ABackup Prefs
	xpk.h

	© 1993-1995
	by Reza Elghazi & Denis Gounelle

	All Rights Reserved
	___________________

	Version : 38.0
	Created : 15-Sep-93
	Modified: 22-Apr-95
	___________________
*/

struct Library	*XpkBase = NULL;

STATIC UBYTE	XDescription[10],
				XRatio[32],
				XPSpeed[32],
				XUSpeed[32];

XMINFO		XMInfo;
struct MinList	*XpkMethodList	= NULL,
				*XpkNameList	= NULL;

STATIC struct TagItem	XQLTags[] =	{{XPK_PackersQuery,	NULL},
									 {TAG_DONE}},
						XQITags[] =	{{XPK_PackerQuery,	NULL},
									 {XPK_PackMethod,	NULL},
									 {TAG_DONE}},
						XQMTags[] =	{{XPK_ModeQuery,	NULL},
									 {XPK_PackMethod,	NULL},
									 {XPK_PackMode, 	NULL},
									 {TAG_DONE}};

#endif	// ABPREFS_XPK_H
