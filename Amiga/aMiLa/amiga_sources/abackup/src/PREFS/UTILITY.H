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
#ifndef ABPREFS_UTILITY_H
#define ABPREFS_UTILITY_H
/*	___________________

	ABackup Prefs
	utility.h

	© 1993-1995
	by Reza Elghazi & Denis Gounelle

	All Rights Reserved
	___________________

	Version : 38.0
	Created : 10-Nov-93
	Modified: 22-Apr-95
	___________________
*/

#define NODEDATALEN	32
struct NameNode {
	struct Node nn_Node;				// System Node structure
	TEXT		nn_Data[NODEDATALEN+1]; // Node-specific data
};

struct TagItem	BusyTags[] = {{WA_BusyPointer,	TRUE},
							  {WA_PointerDelay,	TRUE},
							  {TAG_DONE}};
/*
__chip STATIC UWORD	BusyPtr[] = {0x0000,0x0000,
								 0x0400,0x07C0,
								 0x0000,0x07C0,
								 0x0100,0x0380,
								 0x0000,0x07E0,
								 0x07C0,0x1FF8,
								 0x1FF0,0x3FEC,
								 0x3FF8,0x7FDE,
								 0x3FF8,0x7FBE,
								 0x7FFC,0xFF7F,
								 0x7EFC,0xFFFF,
								 0x7FFC,0xFFFF,
								 0x3FF8,0x7FFE,
								 0x3FF8,0x7FFE,
								 0x1FF0,0x3FFC,
								 0x07C0,0x1FF8,
								 0x0000,0x07E0,
								 0x0000,0x0000};
*/
#endif	// ABPREFS_UTILITY_H
