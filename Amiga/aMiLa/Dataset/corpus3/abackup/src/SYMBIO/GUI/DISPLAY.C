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
    display.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 06-Dec-93
    Modified: 16-Apr-95
    _______________________________________________________________________
*/

#include "headers.h"
#include "display.h"

STATIC BYTE     TmpBuf[MAXSTR+1],AuxBuf[MAXSTR+1];

// determines file type
LONG
GetFileType (BYTE *pName,BOOL FastMode)
{
	ULONG   *pLong;
	UWORD   *pShort;
	LONG    len;
	BPTR    Desc;
	UBYTE   c;

	// read the first sector of the file:
	if (Desc = Open(pName,MODE_OLDFILE)) {
		len = Read(Desc,GIOBuf,TD_SECTOR);
		Close(Desc);
	}
	else return(FTYPE_ERROR);

	if (NOT len) return FTYPE_EMPTY;

	pLong  = (ULONG *)GIOBuf;
	pShort = (UWORD *)GIOBuf;

	// examine the first two bytes:
	if (len > 2L) switch(*pShort) {
		case 0x414A : return FTYPE_OBJAZTEC;
		case 0x616A : return FTYPE_LIBAZTEC;
		case 0x0F00 : return FTYPE_FONTHEAD;
		case 0xE310 : return FTYPE_WBICON;
	}

	// examine the first four bytes:
	if (len > 4L) {
		// Lharc format : ..-lh1- or ..-lh5-
		if ((pShort[1] == 0x2D6C)
			&& (len > 8L)
			&& ((pLong[1] & 0xFFF0FF00L) == 0x68302D00L)) return FTYPE_LHARCARC;

		if ((*pLong & H_IDNT_MSK) == H_IDNT) return FTYPE_ABACKUP;

		switch(*pLong) {
			case 0x000003F3L: return FTYPE_EXECPRG;
			case 0x000003E7L: return FTYPE_OBJSASC;
			case 0x000003FAL: return FTYPE_LIBSASC;
			case ID_ZOO     	: return FTYPE_ZOOARC;
			case ID_PPCRUNCH: return FTYPE_PPCRUNCH;
			case ID_PPCRYPT : return FTYPE_PPCRYPT;
			case ID_XPKF    : return FTYPE_XPKFILE;
			case ID_FORM    :
				if (len >= 12L) switch (pLong[2]) {
					case ID_ILBM: return FTYPE_IFFILBM;
					case ID_TEXT: return FTYPE_IFFTEXT;
					case ID_8SVX: return FTYPE_IFF8SVX;
					case ID_ANIM: return FTYPE_IFFANIM;
					default:	  return FTYPE_IFFOTHER;
				}
				break;
		}
	}

	if (FastMode) return FTYPE_BINARY;

	// type not found yet, so either binary or ascii:
	for (len--; len >= 0L; len--) {
		c = (UBYTE)GIOBuf[len];
		if (c ==  9) continue;
		if (c == 10) continue;
		if (c == 27) continue;
		if (c <  32) return FTYPE_BINARY;
		if (c < 127) continue;
		if (c < 161) return FTYPE_BINARY;
	}
	return(FTYPE_ASCII);
}
//______________________________________________________________________________

// Display device informations
STATIC VOID
DisplayDev (struct Object *pObj)
{
	struct DosEnvec 	*pEnv;
	struct DeviceDef	*pDev;

	pDev = GetDeviceDef(pObj);
	if (NOT pDev) return;
	pEnv = (struct DosEnvec *)&(pDev->dd_Env);

	SPrintf(TmpBuf,GetStr(MSG_INFO_DEVICE), pObj->obj_Name,
											pDev->dd_Name,
											pDev->dd_Unit,
											pEnv->de_Surfaces,
											pEnv->de_BlocksPerTrack,
											pEnv->de_SizeBlock << 2,
											pEnv->de_LowCyl,
											pEnv->de_HighCyl);
	YesNoRequest(TmpBuf,NULL,MSG_REQ_OK,FALSE);
}
//______________________________________________________________________________

// Display link informations
STATIC VOID
DisplayLink (char *pName)
{
	if (SolveLink(pName,GIOBuf)) {
		SPrintf(TmpBuf,GetStr(MSG_INFO_LINK),pName,GIOBuf);
		YesNoRequest(TmpBuf,NULL,MSG_REQ_OK,FALSE);
	}
}
//______________________________________________________________________________

VOID
DisplayObject (struct Object *pObj)

/* $DOC
 * FUNCTION
 *      Display an object, on which name the user has double-clicked
 * INPUTS
 *      pObj = pointer to the object
 * $END
 */
{
	static  UBYTE pubname[MAXPUBSCREENNAME+1],command[512],filename[MINSTR+1];
	UBYTE   *defpub;
	LONG    type;
	UWORD   mode;
	BYTE    *p;
	BPTR    fh;

	// is object a directory?
	if (ObjIsDir(pObj)) return;

	// is object a device?
	if (ObjIsDevice(pObj)) {
		DisplayDev(pObj);
		return;
	}

	GetFullName(AuxBuf,pObj);       // build full pathname

	// is object a link?
	if (ObjIsLink(pObj)) {
		DisplayLink(AuxBuf);
		return;
	}

	// extract file from archive:
	if (PrgAction == PA_RESTORE) {
		if (NOT ReadObjectHeader(pObj,NULL)) return;
		TmpName(AuxBuf);
		if (DecompressFile(pGHdr,AuxBuf,NULL) != DFR_OK) return;
	}

	// file or directory:
	type = GetFileType(AuxBuf,FALSE);
	if (type != FTYPE_ERROR) {
		// set selected file name:
		strcpy(filename,pObj->obj_Name);
		while (p = strchr(filename,'_')) *p = ' ';

		// set file type:
		SPrintf(TmpBuf,"(%s)",GetStr(TypeToID[type]));

		// set external program name:
			 if (type == FTYPE_ASCII)       p = Prefs.ab_External[EXT_ASCII];
		else if (type == FTYPE_IFFILBM) p = Prefs.ab_External[EXT_ILBM];
		else    						p = Prefs.ab_External[EXT_OTHERS];
		strcpy(command,p);

		if (IS_VISCONFIRM && StringRequest(command,MAXSTR,filename,TmpBuf,MSG_REQ_CONTINUE_ABORT) != TRUE);
		else {
			// set command line:
			strcat(command," \"");
			strcat(command,AuxBuf);
			strcat(command,"\"");

			ExtSTLTags[0].ti_Data = (ULONG)(fh = Open("NIL:",MODE_OLDFILE));
			ExtSTLTags[2].ti_Data = (ULONG)IS_VISASYNCHRO;

				 if (IS_CUSTOM) defpub = _PROGNAME_;
			else if (IS_PUBLIC)     defpub = PRF_PUBNAME;
			else    			defpub = NULL;

			GetDefaultPubScreen(pubname);
			SetDefaultPubScreen(defpub);
			mode = SetPubScreenModes(POPPUBSCREEN);

			if (SystemTagList(command,ExtSTLTags) != RETURN_OK) {
				if (fh) Close(fh);
				if (IoErr() == ERROR_OBJECT_NOT_FOUND)
					Warning(MSG_WARN_EXTERNAL_NOT_FOUND);
			}

			Delay(TICKS_PER_SECOND);

			SetPubScreenModes(mode);
			SetDefaultPubScreen(pubname);
		}
	}

	if (PrgAction == PA_RESTORE) DeleteFile(AuxBuf);
}

// Tab size 4
