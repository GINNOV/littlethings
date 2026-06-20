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
    screen.h

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 12-Feb-94
    Modified: 17-May-94
    _______________________________________________________________________
*/
#ifndef ABACKUP_SCREEN_H
#define ABACKUP_SCREEN_H

struct Screen	*Scr = NULL;

WORD	ScrWidth  = 640,
		ScrHeight = 200;

STRPTR	_WBSCRNAME_ = "Workbench";

TEXT	ScreenTitle[81];

BYTE	Aspect = 1;

// static definitions:
STATIC UWORD	DriPens[] = {(UWORD)~0};
STATIC struct TagItem  ScrTags[] = {{SA_Width,			NULL			},
									{SA_Height,			NULL			},
									{SA_Depth,			2L				},
									{SA_Title,			NULL			},
									{SA_Font,			NULL			},
									{SA_SysFont,		1L				},
									{SA_Type,			PUBLICSCREEN	},
									{SA_PubName,		NULL			},
									{SA_DisplayID,		NULL			},
									{SA_AutoScroll,		TRUE			},
									{SA_Pens,			(ULONG)DriPens	},
									{SA_SharePens,		TRUE			},
									{SA_LikeWorkbench,	TRUE			},
									{SA_MinimizeISG,	TRUE			},
									{TAG_DONE}};
#endif	// ABACKUP_SCREEN_H