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
#ifndef ABPREFS_FILLCLASS_H
#define ABPREFS_FILLCLASS_H
/*	___________________

	ABackup Prefs
	fillclass.h

	© 1993-1995
	by Reza Elghazi & Denis Gounelle

	All Rights Reserved
	___________________

	Version : 38.0
	Created : 24-Nov-93
	Modified: 22-Apr-95
	___________________
*/

#define IMAGE(x)        ((struct Image *)(x))

STRPTR	frclassID = "frameiclass";

STATIC UWORD	Pat[] = {0xAAAA,0x5555};

struct TagItem	bfTags[] = {{IA_Left,		NULL		},
							{IA_Top,		NULL		},
							{IA_Width,		NULL		},
							{IA_Height,		NULL		},
							{IA_FGPen,		2			},
							{IA_Mode,		JAM2		},
							{IA_APattern,	(ULONG)Pat      },
							{IA_APatSize,	1			},
							{TAG_DONE}},
				fiTags[] = {{IA_Left,		NULL		},
							{IA_Top,		NULL		},
							{IA_Width,		NULL		},
							{IA_Height,		NULL		},
							{IA_Recessed,	TRUE		},
							{IA_EdgesOnly,	TRUE		},
							{TAG_DONE}};

#endif	// ABPREFS_FILLCLASS_H
