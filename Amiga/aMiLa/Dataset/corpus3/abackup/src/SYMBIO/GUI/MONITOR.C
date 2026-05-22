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
    monitor.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 30-Nov-93
    Modified: 13-Dec-95
    _______________________________________________________________________
*/

#include "headers.h"

STATIC BYTE	*FormatFileStatus	(BYTE *);

LONG	BytesDone,BytesLeft,BytesWritten,
		FilesDone,FilesLeft,FilesFailed,
		StartDate;

struct Rectangle	PBounds;
WORD				YPos;
TEXT				perDisk[7];

STATIC TEXT	valFDone[7], valFLeft[7], valBDone[7], valBLeft[7],
		perSaved[7],perLeft[7],perCrunched[7];
STATIC BYTE	TmpBuf[MAXSTR+1];

//______________________________________________________________________________

VOID
MonitorPrint (LONG XPos,BYTE *msg,LONG flag)
{
	if (FULLBATCHMODE) return;

	if (HasInterface()) {
		struct RastPort *rp;
		WORD	len,k,j;

		rp = Win->RPort;
		ObtainSemaphore(&SemGFX);

		// check if we must scroll display:
		if (YPos >= PBounds.MaxY) {
			ScrollRaster(rp,0,TxtFontY,PBounds.MinX,PBounds.MinY-TxtBLine,PBounds.MaxX,PBounds.MaxY);
			YPos-= TxtFontY;
		}

		len = strlen(msg);

		j = PBounds.MaxX-TxtFontX*15;
	//	j = PBounds.MaxX-TextLength(rp,msg,len);

		if (XPos == MP_POS1) {
			XPos = PBounds.MinX;
			k = (j-XPos)/TxtFontX;
			msg = FormatFileName(msg,MIN(len,k));
		}
		else {
			XPos = j;
			msg = FormatFileStatus(msg);
		}

		// display the new message:
		Move(rp,XPos,YPos);
		Text(rp,msg,strlen(msg));

		if (flag & MPF_LINEFEED) YPos+= TxtFontY;
		ReleaseSemaphore(&SemGFX);
	}
	else {
		if (XPos == MP_POS2) {
			msg = FormatFileStatus(msg);
			Printf("\23315D"); // cursor left by 15 columns..
		}
		else msg = FormatFileName(msg,48L);

		Printf("%s",msg);

		if (flag & MPF_LINEFEED) FPutC(Output(),'\n');
		else if (XPos == MP_POS1) Printf("\22315C");

		Flush(Output());
	}
}
//______________________________________________________________________________

// format a full path name by removing directory parts
// as long as string length is greater than 'MaxLen'
BYTE *
FormatFileName (BYTE *pSrc,LONG MaxLen)
{
	LONG	len;
	BYTE	*p;

	strcpy(TmpBuf,pSrc);
	for (len = strlen(TmpBuf); len < MaxLen; len++) TmpBuf[len] = ' ';
	TmpBuf[len] = '\0';

	while (strlen(TmpBuf) > MaxLen) {
		p = strchr(TmpBuf,':');
		if (NOT p) p = strchr(TmpBuf,'/');
		if (NOT p) break;

		SPrintf(TmpBuf,"...%s",&p[1]);
	}
	return(TmpBuf);
}
//______________________________________________________________________________

// complete the given message with spaces
STATIC BYTE *
FormatFileStatus (BYTE *msg)
{
	SPrintf(TmpBuf,"%15s",msg);
	return(TmpBuf);
}
//______________________________________________________________________________

// update status informations
VOID
MonitorStatus (struct List *pArc)
{
	struct ArcUnit	*pUnit;
	LONG	ratio;

	ObtainSemaphore(&SemGFX);

	SetNM2TX(GD_SavedFiles,FilesDone,valFDone);
	SetNM2TX(GD_LeftFiles ,FilesLeft,valFLeft);

	SetNM3TX(GD_SavedSize,BytesDone,valBDone);
	SetNM3TX(GD_LeftSize ,BytesLeft,valBLeft);

	SetGad(GD_SavedBytes,GTTX_Text,(ULONG)GetStr(GetByteID(BytesDone)));
	SetGad(GD_LeftBytes     ,GTTX_Text,(ULONG)GetStr(GetByteID(BytesLeft)));

	if (pArc && (pUnit = FindCurUnit(pArc))) {
		if (pUnit->au_Type != AUT_FILE)
			SetGad(GD_DiskNumber,GTNM_Number,(ULONG)pUnit->au_CurDisk);
		SetGad(GD_Source,GTTX_Text,(ULONG)pUnit->au_Name);
	}

	SetGad(GD_Time,GTTX_Text,(ULONG)ElapsedTime());

	ratio = Ratio(BytesDone,BytesSelected);
	SetGauge(GD_SavedGauge,ratio,perSaved);
	SetGauge(GD_LeftGauge,100L-ratio,perLeft);

	if (PrgAction == PA_BACKUP && (ratio = Ratio(BytesWritten,BytesDone)))
		 SetGauge(GD_CrunchedGauge,100L-ratio,perCrunched);
	else SetGauge(GD_CrunchedGauge,0L,perCrunched);

//	Printf("BS:%8lu BD:%8lu BW:%8lu C:%3ld%%\n",BytesSelected,BytesDone,BytesWritten,ratio);

	ReleaseSemaphore(&SemGFX);
}
//______________________________________________________________________________

// Update the disk gauge
VOID
MonitorDiskGauge (struct ArcUnit *pUnit,LONG ratio)
{
	if (pUnit) {
		if (NOT DevIsArchive(pUnit)) return;
		ratio = Ratio(CurrentCyl(pUnit)+1,pUnit->au_NumCyls);
	}
	ObtainSemaphore(&SemGFX);
	SetGauge(GD_DiskGauge,ratio,perDisk);
	if (PrgAction == PA_BACKUP) SetGad(GD_Time,GTTX_Text,(ULONG)ElapsedTime());
	ReleaseSemaphore(&SemGFX);
}
//______________________________________________________________________________

VOID
SetGauge (UBYTE gadID,LONG ratio,STRPTR percent)
{
	struct RastPort *rp;
	SHORT	xmin,ymin,ymax,width;

	// render the gauge only if the new ratio is different than the old one:
	if (ratio == (LONG)Gads[gadID]->UserData) return;

	rp	  = Win->RPort;
	width = GD_WIDTH(gadID)-5;
	xmin  = GD_LEFT(gadID)+2;
	ymin  = GD_TOP(gadID) +1;
	if (Scr->UserData != ABMAINSCREEN) {
		xmin += Off.MinX ;
		ymin += Off.MinY ;
	}
	ymax  = ymin+GD_HEIGHT(gadID)-3;

	SPrintf(percent,"%3ld %%",ratio);

	EraseRect(rp,xmin,ymin,xmin+width,ymax);

	SetGad(gadID,GTTX_Text,(ULONG)percent);

	if (ratio) {
		SetDrMd(rp,COMPLEMENT);
		RectFill(rp,xmin,ymin,xmin+width*ratio/100,ymax);
		SetDrMd(rp,JAM2);
	}

	Gads[gadID]->UserData = (APTR)ratio;
}
//______________________________________________________________________________

// Get the prefered unit for the given size
LONG
GetPreferedUnit(LONG size)
{
	LONG	div;

		 if (IS_BYTES)          div = ONEBYTE;
	else if (IS_KILOBYTES)  div = ONEKILOBYTE;
	else if (IS_MEGABYTES)  div = ONEMEGABYTE;
	else {
			 if (size < ONEKILOBYTE) div = ONEBYTE;
		else if (size < ONEMEGABYTE) div = ONEKILOBYTE;
		else						 div = ONEMEGABYTE;
	}
	return(div);
}

// Tab size 4
