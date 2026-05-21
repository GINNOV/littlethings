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
	update.c

	© 1993-1995
	by Reza Elghazi & Denis Gounelle

	All Rights Reserved
	___________________

	Version : 38.0
	Created : 22-Sep-93
	Modified: 22-Apr-95
	___________________
*/

#include "headers.h"

struct MinList	*CmpFilterList = NULL;

STATIC VOID	UpdateCycle	(STRPTR *);

//______________________________________________________________________________

STATIC VOID
UpdateCycle (STRPTR *lab)
{
	UBYTE	n;

	for (n = 0; lab[n] != NULL; n++) lab[n] = GetStr((LONG)lab[n]);
}
//______________________________________________________________________________

VOID
UpdateLabels()
{
	// cycle gadgets labels:
	UpdateCycle(DevsLb);
	UpdateCycle(RpToLb);
	UpdateCycle(RpTpLb);
	UpdateCycle(ExiFLb);
	UpdateCycle(BadFLb);
	UpdateCycle(CompLb);
	UpdateCycle(ScTpLb);
	UpdateCycle(AlrtLb);
	UpdateCycle(FSzeLb);

	// buffer size slider level format:
	SLBuff[3].ti_Data = (ULONG)GetStr(MSG_BUFFER_LEVEL_FORMAT);
}
//______________________________________________________________________________

BOOL
UpdateTagData (UBYTE id,ULONG tag,ULONG data)
{
	struct TagItem	*ti;

	if (ti = FindTagItem(tag,GD_TAGS(id))) {
		ti->ti_Data = data;
		return TRUE;
	}
	return FALSE;
}
//______________________________________________________________________________

VOID
UpdateXpkLV()
{
	if (PRF_XPKMETHOD[0] == '\0') LVXpk[5].ti_Data = ~0;
	else if (XpkMethodList) {
		struct Node	*nn;
		UBYTE	pos = 0;

		for (nn = (struct Node *)XpkMethodList->mlh_Head;
			 nn->ln_Succ; nn = nn->ln_Succ)
		{
			if (Strnicmp(nn->ln_Name,PRF_XPKMETHOD,XPKMETHODLEN)) pos++;
			else {
				LVXpk[1].ti_Data = LVXpk[2].ti_Data = LVXpk[5].ti_Data = pos;
				break;
			}
		}
	}
}
//______________________________________________________________________________

VOID
UpdateCmpFilterLV()
{
	if (CmpFilterList) FreeMinList(CmpFilterList,FALSE);
	else if (! (CmpFilterList = AllocVec(sizeof(struct MinList),NULL)))
	  WARNING(MSG_WARN_MEMORY);

	if (CmpFilterList) {
		StringToList(CmpFilterList,PRF_FILTER);
		LVCFlt[2].ti_Data = (ULONG)((struct List *)CmpFilterList);
	}
}

//______________________________________________________________________________

UWORD
UpdateCmpFilter()
{
	UWORD	pos = 0;

	if (CmpFilterList) pos = ListToString(CmpFilterList,PRF_FILTER);
	return(pos);
}

// Tab size: 4
