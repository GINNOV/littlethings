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
#ifndef ABPREFS_GETCLASS_H
#define ABPREFS_GETCLASS_H
/*	___________________

	ABackup Prefs
	getclass.h

	© 1993-1995
	by Reza Elghazi & Denis Gounelle

	All Rights Reserved
	___________________

	Version : 38.0
	Created : 26-Sep-93
	Modified: 22-Apr-95
	___________________
*/

STRPTR	_IMAGECLASS_ = "imageclass";

Class	*GetFileClass	= NULL,
		*GetDirClass	= NULL,
		*GetElseClass	= NULL;

struct TagItem	GFBoxTags[] = { {GTBB_Recessed, TRUE},
								{GT_VisualInfo, NULL},
								{TAG_DONE}};

STATIC WORD	GetFilePoly[] = {
	0,-9,7,-9,11,-5,11,0,1,0,1,-9,7,-9,7,-5,10,-5,10,0
};

STATIC WORD	GetDirPoly[] = {
	0,-7,4,-7,6,-9,9,-9,11,-7,11,0,1,0,1,-6,5,-6,6,-5,11,-5
};

STATIC WORD	GetElsePoly[] = {
	1,-6,2,-5,2,-6,3,-6,3,-4,4,-3,4,-9,5,-9,5,-2,
	6,-2,6,-9,7,-9,7,-3,8,-4,8,-6,9,-6,9,-5,10,-6,
	11,0
};

#define GETFILEPOLYCOUNT	20
#define GETDIRPOLYCOUNT 	22
#define GETELSEPOLYCOUNT	38

#define IMAGE(obj)      ((struct Image *)obj)

#endif	// ABPREFS_GETCLASS_H
