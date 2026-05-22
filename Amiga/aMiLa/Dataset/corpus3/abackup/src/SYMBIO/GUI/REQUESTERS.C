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
    requesters.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 01-Mar-94
    Modified: 06-Feb-98
    _______________________________________________________________________
*/

#include "headers.h"
#include "requesters.h"

STATIC LONG	DrainReqIDCMP	(STRPTR,struct Gadget **);
STATIC BOOL	OpenRequester	(WORD,WORD,WORD,struct Gadget *);
STATIC VOID	CloseRequester	(VOID);

//______________________________________________________________________________

VOID
About()
{
	UBYTE *q;

	for ( q = _VERSION_ ; *q != 'A' ; q++ ) ;

	SPrintf(TmpBuf,"%s\n%s\n%s\n\n%s\n\n%s\
Denis GOUNELLE\n27, rue Jules Guesde\n45400 FLEURY-LES-AUBRAIS\nFRANCE\n\n\
EMail: denis.gounelle@wanadoo.fr\nHomepage: http://perso.wanadoo.fr/denis.gounelle",
		q,_COPYRIGHT_,GetStr(MSG_RIGHTS),GetStr(MSG_TRANSLATION));

	YesNoRequest(TmpBuf,NULL,MSG_REQ_OK,FALSE);
}
//______________________________________________________________________________

LONG
Notify (WORD titleID,STRPTR text,WORD gadgetID,ULONG IDCMP_flags,APTR args)
{
	struct EasyStruct	nes;
	LONG	ret;
	ULONG	iflags;

	nes.es_StructSize	= sizeof(struct EasyStruct);
	nes.es_Flags		= 0L;
	nes.es_Title		= GetStr((LONG)titleID);
	nes.es_TextFormat	= text;
	nes.es_GadgetFormat	= GetStr((LONG)gadgetID);

	iflags = IDCMP_flags;

	BlockWinInput();
	if (Archive) StopArc(Archive,FALSE);
	ret = EasyRequestArgs(Win,&nes,&iflags,args);
	ReleaseWinInput();

	return(ret);
}
//______________________________________________________________________________

VOID
Warning (WORD textID)
{
	Notify(MSG_WARNING,GetStr(textID),MSG_REQ_OK,NULL,NULL);
}
//______________________________________________________________________________

VOID
SetRequestSize()
{
	WORD	n,ol,gh;

	ol = 2*Aspect+1;
	gh = ScrFontY+4;

	// setup bevelboxes size and position:
	RBH(0) =
	RBT(1) = 3*gh+5*ol-6;
	RBT(2) = ol;
	RBH(1) = gh+2*ol;
	RBH(2) = 2*(ScrFontY+ol)+1;

	RBW(0) =
	RBW(1) = ComputeX(RBW(0));
	RBW(2) = RBW(0)-12;

	SRHeight = RBH(0)+RBH(1);

	// setup gadgets size and position:
	NGTE(GD_ReqString) = RBH(0)-(gh+ol+2);
	NGHI(GD_ReqString) = gh+2;

	NGTE(GD_ReqTrue)  =
	NGTE(GD_ReqFalse) = RBT(1)+ol;
	NGHI(GD_ReqTrue)  =
	NGHI(GD_ReqFalse) = gh;

	for (n = 0; n < GAD_COUNT_REQ; n++) {
		NG[n].ng_LeftEdge	= ComputeX(NG[n].ng_LeftEdge)+Off.MinX;
		NG[n].ng_TopEdge   += Off.MinY;
		NG[n].ng_Width		= ComputeX(NG[n].ng_Width);
		NG[n].ng_TextAttr	= ScrFont;
		NG[n].ng_GadgetID	= n;
		NG[n].ng_VisualInfo	= VInfo;
	}

	// setup texts attributes:
	IT[0].ITextFont =
	IT[1].ITextFont = ScrFont;
	IT[0].TopEdge	= Off.MinY+RBT(2)+ol;
	IT[1].TopEdge	= IT[0].TopEdge+ScrFontY+1;
}
//______________________________________________________________________________

LONG
StringRequest (STRPTR buffer,ULONG maxchars,STRPTR line1,STRPTR line2,WORD gadID)

/* $DOC
 * FUNCTION
 *		string requester.
 * INPUTS
 *		buffer	 = pointer to buffer to hold characters entered
 *				   and default text in string gadget
 *		maxchars = maximum number of characters that fit in buffer
 *		line1	 = 1st description line text
 *		line2	 = 2nd description line text
 *		gadID	 = gadgets ID
 *
 * OUTPUTS
 *		Results =  FALSE: negative answer
 *					TRUE: positive answer
 *					  -1: an error occured
 *					  -2: aborted by user
 * $END
 */

{
	struct Gadget	**gads,*g,*glist;
	struct RastPort *rp;
	LONG	rc = -1L;
	UBYTE	*p,n;

	if (gads = MyAllocMem(GAD_COUNT_REQ*sizeof(struct Gadget),NULL)) {
		glist = NULL;
		if (g = CreateContext(&glist)) {
			// set texts:
			IT[0].IText = line1;
			IT[1].IText = line2;
			IT[0].LeftEdge = (RBW(2)-IntuiTextLength(&IT[0]))/2;
			IT[1].LeftEdge = (RBW(2)-IntuiTextLength(&IT[1]))/2;

			// set gadget labels:
			strcpy(GDTrue,GetStr(gadID));
			p = strchr(GDTrue,'|');
			strcpy(GDFalse,++p);
			*--p = '\0';

			NG[GD_ReqTrue].ng_GadgetText  = GDTrue;
			NG[GD_ReqFalse].ng_GadgetText = GDFalse;

			// set the default string text and max length:
			STTags[0].ti_Data = (ULONG)buffer;
			STTags[1].ti_Data = maxchars;

			// create gadgets:
			for (n = 0; g && n < GAD_COUNT_REQ; n++)
				gads[n] = g = CreateGadgetA(NGType[n],g,&NG[n],(struct TagItem *)NG[n].ng_UserData);

			if (Archive) StopArc(Archive,FALSE);

			// open the requester and handle messages:
			if (g && OpenRequester(MSG_REQUEST,280,SRHeight,glist)) {
				rp = RWin->RPort;

				// draw bevelboxes:
				for (n = 0; n < BOX_COUNT_REQ; n++)
					DrawBevelBoxA(  rp,
									RBL(n)+Off.MinX,
									RBT(n)+Off.MinY,
									RBW(n),
									RBH(n),
									RBR(n)? RecessTags: BBoxTags);

				// draw texts:
				PrintIText(rp,IT,RBL(2),0);

				GT_RefreshWindow(RWin,NULL);

				ActivateGadget(gads[GD_ReqString],RWin,NULL);

				rc = DrainReqIDCMP(buffer,gads);

				CloseRequester();
			}
			FreeGadgets(glist);
		}
		MyFreeMem(gads);
	}
	return(rc);
}
//______________________________________________________________________________

__inline STATIC LONG
DrainReqIDCMP (STRPTR buffer,struct Gadget **gads)
{
	struct IntuiMessage	*imsg;
	struct Gadget		*g;
	LONG	rc = -2;
	UWORD	code;
	BOOL	loop = TRUE;

	do {
		Wait(1L<<RWin->UserPort->mp_SigBit);
		while (loop && (imsg = GT_GetIMsg(RWin->UserPort))) {
			GT_ReplyIMsg(imsg);

			switch(imsg->Class) {
				case IDCMP_CLOSEWINDOW:
					loop = FALSE;
					break;

				case IDCMP_GADGETUP:
					g = (struct Gadget *)imsg->IAddress;
					switch (g->GadgetID) {
						case 0:
							strcpy(buffer,((struct StringInfo *)g->SpecialInfo)->Buffer);
							break;
						case 1:
							rc = TRUE;
							loop = FALSE;
							break;
						case 2:
							rc = loop = FALSE;
							break;
					}
					break;

				case IDCMP_VANILLAKEY:
					code = imsg->Code;
					if (SHCUTFROMSTR(GDTrue) || code == 0x0D) {
						rc = TRUE;
						loop = FALSE;
					}
					else if (SHCUTFROMSTR(GDFalse)) rc = loop = FALSE;
					else if (code == 0x1B) loop = FALSE;
					break;
			}
		}
	} while(loop);
	return(rc);
}
//______________________________________________________________________________

BOOL
YesNoRequest (STRPTR text,STRPTR args,WORD gadget,BOOL disk)

/* $DOC
 * FUNCTION
 *		standard "choice" requester.
 * INPUTS
 *		text   = text format
 *		args   = text argument
 *		gadget = gadget format ID (see abackup.cd)
 *		disk   = watch disk insertions
 *
 * OUTPUTS
 *		Result = FALSE for a negative answer, TRUE for a positive answer
 *				 or if disk = TRUE and a disk is inserted (in any drive)
 * $END
 */

{
	return((BOOL)Notify(MSG_REQUEST,text,gadget,disk?IDCMP_DISKINSERTED:NULL,&args));
}
//______________________________________________________________________________

BOOL
OverwriteRequest (LONG MsgID,struct ArcUnit *pUnit,BYTE *pName,struct InfoData *pInfo)

/* $DOC
 * FUNCTION
 *		asks for device overwrite permission
 * INPUTS
 *		MsgID = message format string
 *		pUnit = pointer to the unit (may be NULL)
 *		pName = name of the volume (used only if pUnit is NULL)
 *		pInfo = pointer to volume info (may be NULL)
 * OUTPUTS
 *		Result = TRUE if can overwrite
 * $END
 */

{
	LONG		k;
	STATIC BYTE	aux[MINSTR+2];
	STRPTR		msg	  = GetStr(MsgID),
				ovmsg = GetStr(MSG_REQ_OVERWRITE);

	if (MsgID == MSG_REQ_MISC_DISK) {
		if (pUnit) {
			if (MyInfo(pUnit->au_Name,aux)) {
				pName = aux;
				pInfo = &GInfo;
			}
			else pName = pUnit->au_Name;
		}
		k = pInfo? Ratio(pInfo->id_NumBlocksUsed,pInfo->id_NumBlocks): 99L;
		SPrintf(TmpBuf,msg,pName,k,ovmsg);
	}
	else if (pUnit && (pUnit->au_BadCyls->bcm_Type & HT_CRYPT))
		 SPrintf(TmpBuf,GetStr(MSG_REQ_CRYPT_DISK),pUnit->au_Name,ovmsg);
	else SPrintf(TmpBuf,msg,pUnit->au_Name,pUnit->au_BadCyls->bcm_DiskNum,PackedDateToStr(pUnit->au_BadCyls->bcm_BDate),ovmsg);

	WakeUpUser();
	return(YesNoRequest(TmpBuf,NULL,MSG_REQ_YES_NO,FALSE));
}
//______________________________________________________________________________

BOOL
DiskRequest (struct ArcUnit *pUnit,LONG DiskNum)

/* $DOC
 * FUNCTION
 *		asks for a certain disk number in an unit
 * INPUTS
 *		pUnit	= pointer to the unit
 *		DiskNum = disk number, or:
 *			DR_LASTDISK for the last disk
 *			DR_NEXTDISK for a disk after the one in pUnit
 *			DR_NEWDISK for a new disk (for catalog)
 * OUTPUTS
 *		Result = TRUE if the user clicked "Continue" and inserted the right
 *				 disk in the unit, FALSE if the user clicked "Abort"
 * NOTES
 *		sets the PF_BREAKED flag if the user select "abort"
 * $END
 */

{
	struct Header	*pHdr;
	LONG		PrevDisk,MsgID;
	STATIC BYTE	aux[MAXSTR+2];

	if (FULLBATCHMODE) return FALSE;

	if (pUnit->au_Type != AUT_DEVICE) /* || (NOT DevIsTrackDisk(pUnit))) */
		return TRUE;

	// choose a message:
	switch (DiskNum) {
		case DR_NEXTDISK:
			MsgID = MSG_REQ_INSERT_NEXT_DISK;
			PrevDisk = pUnit->au_CurDisk;
			break;
		case DR_LASTDISK:
			MsgID = MSG_REQ_INSERT_LAST_DISK;
			break;
		case DR_NEWDISK:
			MsgID = MSG_REQ_INSERT_NEW_DISK;
			break;
		default:
			MsgID = MSG_REQ_INSERT_DISK;
			break;
	}

	// ask for a disk:
	FOREVER {
		if (DevIsReady(pUnit) && (NOT CleanupDev(pUnit))) return FALSE;

		if (MsgID == MSG_REQ_INSERT_DISK)
			SPrintf(TmpBuf,GetStr(MsgID),DiskNum,pUnit->au_Name);
		else
			SPrintf(TmpBuf,GetStr(MsgID),pUnit->au_Name);

		WakeUpUser();
		if (NOT YesNoRequest(TmpBuf,NULL,MSG_REQ_CONTINUE_ABORT,TRUE)) {
			SetPrgFlag(PF_BREAKED);
			return FALSE;
		}

		ClearUnitFlag(pUnit,AUF_NOTARCHIVE);
		if (NOT FloppyPresent(pUnit)) continue;
		if (NOT PrepareDev(pUnit,PDF_DONTINHIBIT)) continue;
		SetUnitFlag(pUnit,AUF_NOTARCHIVE);

		// write: check if the disk can be overwriten
		if (NOT DevIsReadOnly(pUnit)) {
			if (ExamineDisk(pUnit)) {                               // test for ABackup disk
				if (pUnit->au_BadCyls->bcm_BDate == IdntDate) {
					YesNoRequest(GetStr(MSG_WARN_SAME_BACKUP_SET),(STRPTR)pUnit->au_BadCyls->bcm_DiskNum,MSG_REQ_OK,FALSE);
					continue;
				}
				if (DiskNum == 1 && NOT OverwriteRequest(MSG_REQ_OLD_BACKUP_DISK,pUnit,NULL,NULL))
					continue;
			}
			else if (MyInfo(pUnit->au_Name,aux)) {  // test for DOS disk
				if (((GInfo.id_DiskType & ~0x0f) == ID_DOS_DISK)
					&& (NOT OverwriteRequest(MSG_REQ_MISC_DISK,NULL,aux,&GInfo)))
					continue;
			}
			else if (DiskNum == 1 && NOT OverwriteRequest(MSG_REQ_MISC_DISK,NULL,pUnit->au_Name,NULL))
				continue;

			pUnit->au_CurDisk = DiskNum;
			break;
		}

		// read: check disk number
		if (DiskNum == DR_LASTDISK) {
			pHdr = (struct Header *)pUnit->au_BadCyls;
			if (pHdr->h_CatalOfs != -1) break;
		}
		else if (DiskNum == DR_NEXTDISK) {
			if (pUnit->au_CurDisk >= PrevDisk) break;
		}
		else if (pUnit->au_CurDisk == DiskNum) break;

		SPrintf(TmpBuf,GetStr(MSG_REQ_WRONG_DISK),pUnit->au_CurDisk);
		YesNoRequest(TmpBuf,NULL,MSG_REQ_OK,FALSE);
	}

	if (NOT DevIsReadOnly(pUnit)) InhibitDev(pUnit,TRUE);
	ClearUnitFlag(pUnit,AUF_NOTARCHIVE);
	return TRUE;
}
//______________________________________________________________________________

BOOL
FileRequest (LONG titleID,BYTE *name,LONG flags)

/* $DOC
 * FUNCTION
 *		Standard file request.
 * INPUTS
 *		titleID = requester's title (or -1)
 *		name	= initial file name
 *		flags	= combination of:
 *			FRF_DIRSONLY	directory request
 * OUTPUTS
 *		Result = FALSE if the user canceled the request, TRUE otherwise
 *				 (the selected dir/file name is copied into pFile)
 * $END
 */

{
	BYTE	*p;

	/*
	 * split input name:
	 * - if no name is provided, default to RAM:
	 * - if name is a directory, file part set to empty string
	 * - if name is a file, file part set to last componant, and
	 *   last componant removed from name
	 */

	TmpBuf[0] = '\0' ;
	if ( name[0] )
	{
	  if ( ! MyExamine( name ) ) GFib.fib_DirEntryType = 0 ;
	  if ( GFib.fib_DirEntryType <= 0 )
	  {
	    p = FilePart( name ) ;
	    strcpy( TmpBuf , p ) ;
	    *p = '\0' ;
	  }
	}
	else strcpy( name, "Ram:" ) ;

	// set tags and do the request:
	AFRTags[0].ti_Data = (ULONG)Win;
	AFRTags[1].ti_Data = (ULONG)(titleID == -1? _PROGNAME_: GetStr(titleID));
	AFRTags[2].ti_Data = (ULONG)TmpBuf;
	AFRTags[3].ti_Data = (ULONG)name;

	if (NOT AslRequest(pReq,AFRTags)) return FALSE;

	// get selected value:
	strcpy(name,pReq->fr_Drawer);
	if (NOT(flags & FRF_DIRSONLY)) AddPart(name,pReq->fr_File,MAXSTR);

	return TRUE;
}
//______________________________________________________________________________

STATIC BOOL
OpenRequester (WORD titleID,WORD width,WORD height,struct Gadget *glist)
{
	WORD x;

	width = ComputeX(width);

	RWinTags[2].ti_Data = width +Off.MaxX;
	RWinTags[3].ti_Data = height+Off.MaxY;
	x		    = Win->LeftEdge + (Win->Width  - RWinTags[2].ti_Data) / 2;
	RWinTags[0].ti_Data = x < 0 ? 0 : x ;
	x		    = Win->TopEdge  + (Win->Height - RWinTags[3].ti_Data) / 2;
	RWinTags[1].ti_Data = x < 0 ? 0 : x ;
	RWinTags[6].ti_Data = (ULONG)GetStr(titleID);
	RWinTags[7].ti_Data = (ULONG)Scr;
	RWinTags[8].ti_Data = (ULONG)glist;

	if (RWin = OpenWindowTagList(NULL,RWinTags)) {
		BlockWinInput();
		return TRUE;
	}
	return FALSE;
}
//______________________________________________________________________________

STATIC VOID
CloseRequester()
{
	CloseWindow(RWin);
	ReleaseWinInput();
}

// Tab size: 4
