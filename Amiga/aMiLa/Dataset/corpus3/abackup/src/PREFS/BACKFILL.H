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
#ifndef ABPREFS_BACKFILL_H
#define ABPREFS_BACKFILL_H
/*	___________________

	ABackup Prefs
	backfill.h

	© 1993-1995
	by Reza Elghazi & Denis Gounelle

	All Rights Reserved
	___________________

	Version : 38.0
	Created : 13-Oct-93
	Modified: 22-Apr-95
	___________________
*/

UWORD	Pattern[] = { 0xAAAA, 0x5555 };

typedef struct {
	struct Layer	 *Layer;
	struct Rectangle bounds;
	WORD		 xoffset,yoffset;
} BackFillInfo;

STATIC __saveds __asm VOID
BackFill (register __a0 struct Hook *,register __a2 struct RastPort *,register __a1 BackFillInfo *);

struct Hook	backFillHook = {NULL,NULL,(ULONG (*)())BackFill,NULL,NULL};

//_____________________________________________________________________________

STATIC __saveds __asm VOID
BackFill (register __a0 struct Hook *hook,register __a2 struct RastPort *rp,register __a1 BackFillInfo *info)
{
	SetAPen(rp,2);
	SetAfPt(rp,&Pattern[0],1);
	RectFill(rp,4,10,info->Layer->bounds.MaxX-info->Layer->bounds.MinX-4,
			 info->Layer->bounds.MaxY-info->Layer->bounds.MinY-2);
}

#endif	// ABPREFS_BACKFILL_H
