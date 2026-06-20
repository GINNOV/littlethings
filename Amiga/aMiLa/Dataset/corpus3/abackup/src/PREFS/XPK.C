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
	xpk.c

	© 1993-1995
	by Reza Elghazi & Denis Gounelle

	All Rights Reserved
	___________________

	Version : 38.0
	Created : 15-Sep-93
	Modified: 22-Apr-95
	___________________
*/

#include "headers.h"
#include "xpk.h"

VOID
SetupXpk()
{
	if (XpkBase = OpenLibrary(XPKNAME,NULL)) {
		XPLIST	xplist;
		XPINFO	xpinfo;

		XQLTags[0].ti_Data = (ULONG)&xplist;
		XQITags[0].ti_Data = (ULONG)&xpinfo;

		if (NOT XpkQuery(XQLTags)) {
			if ((XpkMethodList = AllocVec(sizeof(struct MinList),NULL))
			 && (XpkNameList   = AllocVec(sizeof(struct MinList),NULL)))
			{
				UBYTE	skip;

				NewList((struct List *)XpkNameList);
				NewList((struct List *)XpkMethodList);

				for (skip = 0; skip < xplist.NumPackers; skip++) {
					XQITags[1].ti_Data = (ULONG)xplist.Packer[skip];

					if (XpkQuery(XQITags))                                          continue;
					if (AND(xpinfo.Flags,XPKIF_LOSSY))                      continue;
					if (AND(xpinfo.Flags,XPKIF_NEEDPASSWD))         continue;
					if (NOT AND(xpinfo.Flags,XPKIF_PK_CHUNK))       continue;
					if (NOT AND(xpinfo.Flags,XPKIF_UP_CHUNK))       continue;

					AddName(XpkMethodList,xplist.Packer[skip]);
					AddName(XpkNameList,xpinfo.LongName);
				}

				LVXpk[3].ti_Data = (ULONG)((struct List *)XpkNameList);
			}
			else WARNING(MSG_WARN_MEMORY);
		}
	}
	else {
		CompLb[2] = NULL;	// remove the Xpk choice from the method cycle...
		TXXMod[0].ti_Data =
		TXXRat[0].ti_Data =
		TXXPSp[0].ti_Data =
		TXXUSp[0].ti_Data = (ULONG)GetStr(MSG_WARN_INEFFECTIVE);
	}
}
//______________________________________________________________________________

VOID
GetXpkName(UWORD pos)
{
	struct Node	*nn;
	UWORD	i;

	for (i = 0,nn = (struct Node *)XpkMethodList->mlh_Head;
		 i < pos && nn->ln_Succ; i++,nn = nn->ln_Succ);
	if (i == pos) strcpy(PRF_XPKMETHOD,nn->ln_Name);
}
//______________________________________________________________________________

VOID
UpdateXpkMode (ULONG mode,BOOL setgads)
{
	if (XpkBase) {
		XQMTags[0].ti_Data = (ULONG)&XMInfo;
		XQMTags[1].ti_Data = (ULONG)PRF_XPKMETHOD;
		XQMTags[2].ti_Data = mode;

		if (XpkQuery(XQMTags) == XPKERR_OK) {
			SPrintf(XRatio,"%5ld.%1lu %%",XMInfo.Ratio/10L,XMInfo.Ratio%10L);
			SPrintf(XPSpeed,GetStr(MSG_XPK_SPEED),XMInfo.PackSpeed);
			SPrintf(XUSpeed,GetStr(MSG_XPK_SPEED),XMInfo.UnpackSpeed);

			TXXMod[0].ti_Data = (ULONG)XMInfo.Description;
			TXXRat[0].ti_Data = (ULONG)XRatio;
			TXXPSp[0].ti_Data = (ULONG)XPSpeed;
			TXXUSp[0].ti_Data = (ULONG)XUSpeed;
		}
		else {
			TXXMod[0].ti_Data =
			TXXRat[0].ti_Data =
			TXXPSp[0].ti_Data =
			TXXUSp[0].ti_Data = NULL;
		}

		// to avoid flicking, gadgets are set only if their value has changed:
		if (setgads) {
			if (Stricmp(XDescription,XMInfo.Description)) {
				GT_SetGadgetAttrsA(Gads[GD_XpkDescription],Win,NULL,TXXMod);
				strcpy(XDescription,XMInfo.Description);
			}
			if (XMInfo.Ratio != (UWORD)Gads[GD_XpkRatio]->UserData) {
				GT_SetGadgetAttrsA(Gads[GD_XpkRatio],Win,NULL,TXXRat);
				Gads[GD_XpkRatio]->UserData = (APTR)XMInfo.Ratio;
			}
			if (XMInfo.PackSpeed != (ULONG)Gads[GD_XpkPackSpeed]->UserData) {
				GT_SetGadgetAttrsA(Gads[GD_XpkPackSpeed],Win,NULL,TXXPSp);
				Gads[GD_XpkPackSpeed]->UserData = (APTR)XMInfo.PackSpeed;
			}
			if (XMInfo.UnpackSpeed != (ULONG)Gads[GD_XpkUnpackSpeed]->UserData) {
				GT_SetGadgetAttrsA(Gads[GD_XpkUnpackSpeed],Win,NULL,TXXUSp);
				Gads[GD_XpkUnpackSpeed]->UserData = (APTR)XMInfo.UnpackSpeed;
			}
		}
	}
}
//______________________________________________________________________________

VOID
UpdateXpkSL()
{
	BOOL	unique;

	UpdateXpkMode(NULL,FALSE);

	unique = (XMInfo.Upto == 100L);

	// if mode is unique (0..100), disable slider and set GTSL_Max to NULL:
	if (GTV39PLUS && IS_XPKLIB) SLXMod[0].ti_Data = unique;
	SLXMod[1].ti_Data = unique? NULL: 100L;
	SLXMod[2].ti_Data = PRF_XPKMODE;
}

// Tab size: 4
