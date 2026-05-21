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
/*      ___________________

	ABackup Prefs
	gadgets.c

	© 1993-1995
	by Reza Elghazi & Denis Gounelle

	All Rights Reserved
	___________________

	Version : 38.0
	Created : 22-Sep-93
	Modified: 18-Jan-98
	___________________
*/

#include "syms.h"
#include "headers.h"

VOID
SetGad (UBYTE gadID,ULONG tag,ULONG data)
{
	if (UpdateTagData(gadID,tag,data))
		GT_SetGadgetAttrsA(Gads[gadID],Win,NULL,GD_TAGS(gadID));
}
//______________________________________________________________________________

VOID
SetGadgets()
{
	UBYTE   gadID;

	UpdateGadgets();
	for (gadID = 0; gadID < MWin[NewID].mw_GadCnt; gadID++)
		GT_SetGadgetAttrsA(Gads[gadID],Win,NULL,GD_TAGS(gadID));
}
//______________________________________________________________________________

VOID
UpdateGadgets()
{
	ULONG   displayID;

	switch (NewID) {
		case WIN_BACKUP:	//__________________________________ Backup options:

			FreeMinList(SelDevsList,FALSE);

			// backup to:
			if (IS_BFL_TODEVICE) {
				StringToList(SelDevsList,PRF_BUPTO);
				PRF_BUPTO[0]      = '\0';
				CYDevs[1].ti_Data = 0L;
				LVDLst[0].ti_Data =
				LVDevs[0].ti_Data = ENABLE;
				STArcF[0].ti_Data = DISABLE;
			}
			else {
				LVDLst[0].ti_Data =
				LVDevs[0].ti_Data = DISABLE;

				if (IS_BFL_TOFILE) {
					CYDevs[1].ti_Data = 1L;
					STArcF[0].ti_Data = ENABLE;
				}
				else {
					CYDevs[1].ti_Data = 2L;
					STArcF[0].ti_Data = DISABLE;
				}
			}
			STArcF[1].ti_Data = (ULONG)PRF_BUPTO;

			// buffer size:
			if (PRF_BUFSIZE>SLBuff[1].ti_Data)
				SLBuff[2].ti_Data = SLBuff[1].ti_Data;
			else
				SLBuff[2].ti_Data = PRF_BUFSIZE;

			// log file:
			STLogF[0].ti_Data = (ULONG)PRF_LOGFILE;

			// default comment:
			STDCom[0].ti_Data = IS_BFL_ADDCOMMENT? ENABLE: DISABLE;
			STDCom[1].ti_Data = (ULONG)PRF_DEFCOMMENT;

			// backup report:
			CBBRep[0].ti_Data = IS_BFL_REPORT;
			CYBRTo[0].ti_Data = CYBRTp[0].ti_Data = NOT IS_BFL_REPORT;
			CYBRTo[2].ti_Data = IS_BFL_REPTOFILE;
			CYBRTp[2].ti_Data = NOT IS_BFL_REPSHORT;

			CBVeri[0].ti_Data = IS_BFL_VERIFY;
			CBTask[0].ti_Data = IS_BFL_CHILDTASK;
			CBBLnk[0].ti_Data = IS_BFL_LINKS;
			CBAddC[0].ti_Data = IS_BFL_ADDCOMMENT;
			CBAddI[0].ti_Data = IS_BFL_ADDICON;
			CBComp[0].ti_Data = IS_BFL_COMPRESS;
			CBCCat[0].ti_Data = IS_BFL_CATCOMP;
			CBCrpt[0].ti_Data = IS_BFL_ENCRYPT;
			CBABit[0].ti_Data = IS_BFL_SETABIT;
			CBDupC[0].ti_Data = IS_BFL_DUPCATALOG;
			CBIgnS[0].ti_Data = IS_BFL_IGNSKIPME;

			break;

		case WIN_RESTORE:       //_________________________________ Restore options:

			FreeMinList(SelDevsList,FALSE);

			// restore from:
			if (IS_RFL_FROMDEVICE) {
				StringToList(SelDevsList,PRF_RESFROM);
				PRF_RESFROM[0]    = '\0';
				CYDevs[1].ti_Data = 0L;
				LVDLst[0].ti_Data =
				LVDevs[0].ti_Data = ENABLE;
				STArcF[0].ti_Data = DISABLE;
			}
			else {
				LVDLst[0].ti_Data =
				LVDevs[0].ti_Data = DISABLE;

				if (IS_RFL_FROMFILE) {
					CYDevs[1].ti_Data = 1L;
					STArcF[0].ti_Data = ENABLE;
				}
				else {
					CYDevs[1].ti_Data = 2L;
					STArcF[0].ti_Data = DISABLE;
				}
			}
			STArcF[1].ti_Data = (ULONG)PRF_RESFROM;

			// restore to:
			STRtTo[0].ti_Data = (ULONG)PRF_RESTO;

			// existing files (default = ask before replacing):
				 if (IS_RFL_REPLACE)    CYExiF[1].ti_Data = 0L; // always replace
			else if (IS_RFL_ASKREPLACE)     CYExiF[1].ti_Data = 2L; // ask before replacing
			else if (IS_RFL_OLDREPLACE)     CYExiF[1].ti_Data = 3L; // replace oldest version
			else if (IS_RFL_RENAME) 	CYExiF[1].ti_Data = 4L; // rename file
			else    					CYExiF[1].ti_Data = 1L; // never replace

			// bad files (default = ask before deleting):
				 if (IS_RFL_DELBAD)     	CYBadF[1].ti_Data = 0L; // always delete
			else if (IS_RFL_ASKDELBAD)      CYBadF[1].ti_Data = 2L; // ask before deleting
			else    					CYBadF[1].ti_Data = 1L; // never dekete

			// restore report:
			CBRRep[0].ti_Data = IS_RFL_REPORT;
			CYRRTo[0].ti_Data = CYRRTp[0].ti_Data = NOT IS_RFL_REPORT;
			CYRRTo[2].ti_Data = IS_RFL_REPTOFILE;
			CYRRTp[2].ti_Data = NOT IS_RFL_REPSHORT;

			CBTree[0].ti_Data = IS_RFL_DIRTREE;
			CBDate[0].ti_Data = IS_RFL_DATE;
			CBRLnk[0].ti_Data = IS_RFL_LINKS;
			CBEmpt[0].ti_Data = IS_RFL_EMPTYDIRS;
			CBCatF[0].ti_Data = IS_RFL_USECATFILE;

			break;

		case WIN_VERIFY:	//__________________________________ Verify options:

			// verify report:
			CBVRep[0].ti_Data = IS_VFL_REPORT;
			CYVRTo[0].ti_Data = CYVRTp[0].ti_Data = NOT IS_VFL_REPORT;
			CYVRTo[2].ti_Data = IS_VFL_REPTOFILE;
			CYVRTp[2].ti_Data = NOT IS_VFL_REPSHORT;

			CBVCom[0].ti_Data = IS_VFL_COMPARE;
			CBVSel[0].ti_Data = IS_VFL_SELECTIVE;
			CBVIgD[0].ti_Data = IS_VFL_IGNOREDATE;

			break;

		case WIN_COMPRESS:      //_____________________________ Compression options:

			// compression type (default = internal):
				 if (IS_EXTERNAL)       		CYComp[1].ti_Data = 1L; // external
			else if (IS_XPKLIB && XpkBase)  CYComp[1].ti_Data = 2L; // Xpk library
			else    						CYComp[1].ti_Data = 0L; // internal

			// enable appropriate compression gadgets:

			// NOTE: GA_Disabled is a V39+ tag for ListViews.
			// so, before disabling the gadget,
			// we have to check for the gadtools.library version,
			if (GTV39PLUS) LVXpk[0].ti_Data = DISABLE;
			SLXMod[0].ti_Data = DISABLE;

			switch (CYComp[1].ti_Data) {
				case 1:
					STComp[0].ti_Data = STDcmp[0].ti_Data = ENABLE;
					break;

				case 2:
					if (GTV39PLUS) LVXpk [0].ti_Data = ENABLE;
					SLXMod[0].ti_Data = ENABLE;

				default:
					STComp[0].ti_Data = STDcmp[0].ti_Data = DISABLE;
					break;
			}

			// external (de)cruncher:
			STComp[1].ti_Data = (ULONG)PRF_COMP;
			STDcmp[1].ti_Data = (ULONG)PRF_DECOMP;

			// Xpk mode (0..100) (see SetupXpk() for other definitions):
			if (XpkBase) {
				UpdateXpkSL();
				UpdateXpkMode(PRF_XPKMODE,FALSE);
				UpdateXpkLV();
			}

			UpdateCmpFilterLV();

			break;

		case WIN_TAPE:  	//____________________________________ Tape options:

			// device driver name:
			STDevD[0].ti_Data = (ULONG)PRF_DEVICEDRIVER;

			// SCSI port:
			INScsi[0].ti_Data = (ULONG)PRF_SCSIPORT;

			// block size:
			INBloc[0].ti_Data = (ULONG)PRF_BLOCKSIZE;

			CBRwnd[0].ti_Data   = IS_TFL_REWIND;
			CBEjct[0].ti_Data   = IS_TFL_EJECT;
			CBARet[0].ti_Data   = IS_TFL_RETENTION;
			CBFMTBuf[0].ti_Data = IS_TFL_FASTBUFFER;

			BUScsi[0].ti_Data = SCSIInquiry(PRF_DEVICEDRIVER,PRF_SCSIPORT,TRUE)? ENABLE: DISABLE;

			break;

		case WIN_GUI:   	//_____________________________________ GUI options:

			// screen type (default = workbench):
			if (IS_CUSTOM) {
				CYScTp[1].ti_Data = 1L;
				displayID = PRF_DISPLAYID;
			}
			else if (IS_PUBLIC)     {
				CYScTp[1].ti_Data = 2L;
				displayID = CheckPubScreen(PRF_PUBNAME);
			}
			else {
				CYScTp[1].ti_Data = 0L;
				displayID = CheckPubScreen(_WBSCRNAME_);
			}

			// enable public screen String:
			STPbSc[0].ti_Data = IS_PUBLIC? ENABLE: DISABLE;

			// public screen name:
			STPbSc[1].ti_Data = (ULONG)PRF_PUBNAME;

			// screen mode name:
			GetScreenModeName(displayID);

			// screen font name & size:
			STSFnt[0].ti_Data = (ULONG)PRF_SCREENFONTNAME;
			INSFnt[0].ti_Data = (ULONG)PRF_SCREENFONTSIZE;

			// text font name & size:
			STTFnt[0].ti_Data = (ULONG)PRF_TEXTFONTNAME;
			INTFnt[0].ti_Data = (ULONG)PRF_TEXTFONTSIZE;

			break;

		case WIN_EXTERNAL:      //_______________________ External Programs options:

			STAsci[0].ti_Data = (ULONG)PRF_EXTERNAL[EXT_ASCII];
			STIlbm[0].ti_Data = (ULONG)PRF_EXTERNAL[EXT_ILBM];
			STOthr[0].ti_Data = (ULONG)PRF_EXTERNAL[EXT_OTHERS];

			CBAsyn[0].ti_Data = IS_VISASYNCHRO;
			CBConf[0].ti_Data = IS_VISCONFIRM;

			break;

		case WIN_MISC:  //_______________________________ Miscellaneous options:

			// alert (default = beep):
				 if (IS_BEEPANDFLASH)   CYAlrt[1].ti_Data = 2L;
			else if (IS_BEEP)       		CYAlrt[1].ti_Data = 0L;
			else if (IS_FLASH)      		CYAlrt[1].ti_Data = 1L;
			else    					CYAlrt[1].ti_Data = 3L; // none

			// files size (default = automatic)
				 if (IS_BYTES)  		CYFSze[1].ti_Data = 1L;
			else if (IS_KILOBYTES)  	CYFSze[1].ti_Data = 2L;
			else if (IS_MEGABYTES)  	CYFSze[1].ti_Data = 3L;
			else    					CYFSze[1].ti_Data = 0L; // automatic

			// temporary dir:
			STTemp[0].ti_Data = (ULONG)PRF_TEMPDIR;
			STSele[0].ti_Data = (ULONG)PRF_SELECTPATH;

			// labels:
			CBPrLb[0].ti_Data = IS_BFL_PRINTLABELS;
			INLign[0].ti_Data = IS_BFL_PRINTLABELS? ENABLE: DISABLE;
			INLign[1].ti_Data = (ULONG)PRF_LABELSLENGTH;

			break;
	}
}

// Tab size: 4
