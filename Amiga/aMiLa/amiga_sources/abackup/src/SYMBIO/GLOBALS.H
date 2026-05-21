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
    globals.h

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 11-Nov-93
    Modified: 13-Jan-98
    NO TABS
    _______________________________________________________________________
*/
#ifndef ABACKUP_GLOBALS_H
#define ABACKUP_GLOBALS_H

struct MinWindow {
    WORD	     mw_Width, mw_Height;
    WORD	     mw_Title;
    BYTE	     mw_GadgetsCount, mw_BoxesCount;
    struct MinGadget *mw_Gadgets;
    struct BBox      *mw_Boxes;
};

struct MinGadget {
    WORD	   mg_LeftEdge, mg_TopEdge;
    WORD	   mg_Width, mg_Height;
    UWORD	   mg_Type;
    WORD	   mg_Text;
    ULONG	   mg_Flags;
    struct TagItem *mg_Tags;
};

struct BBox {
    WORD bb_LeftEdge, bb_TopEdge;
    WORD bb_Width, bb_Height;
    BOOL bb_Recessed;
};

struct DirList {
    WORD  dl_Visible;	       // number of visible objects
    WORD  dl_XMin,dl_YMin,
	  dl_XMax,dl_YMax,
	  dl_Height;	       // drawing area dimensions
};

//_____________________________________________________________________________

GLOBAL struct ExecBase *SysBase;

// getargs.c:
GLOBAL ABARGS Args;

// icon.c:
GLOBAL struct DiskObject AppIcon;

// main.c:
GLOBAL STRPTR		    _VERSION_,_PROGNAME_,_PROGVER_,_COPYRIGHT_,_PREFSFILE_,_HELPNAME_;
GLOBAL UBYTE		    CompType;
GLOBAL TEXT		    FullName[],RootName[];
GLOBAL LONG		    ProgramFlags,WBufSize;
GLOBAL struct List	    *Archive,SelDevsList;
GLOBAL struct Object	    *DevList,*pGRoot,*pCurrentDir;
GLOBAL struct Header	    *pGHdr;
GLOBAL struct FileRequester *pReq;
GLOBAL WORD		    GPathIndex;
GLOBAL BYTE		    GPathTable[],IOBuf[],GIOBuf[],StartDir[],DestDir[],
			    *WriteBuf,PrgAction;
GLOBAL ABPREFS		    Prefs;
GLOBAL struct InfoData	    GInfo;
GLOBAL struct OldHeader     OldHdr;
GLOBAL struct FileInfoBlock GFib;
GLOBAL STRPTR		    NAGContext[];
GLOBAL AMIGAGUIDECONTEXT    AGHandle;

GLOBAL TEXT   NameFilter[], DateFilter[], BitsFilter[];
GLOBAL BOOL   FirstCall, DragSelect, FirstWinAction;
GLOBAL ULONG  stSecs, stMicros, cuSecs,cuMicros;
GLOBAL struct TagItem SysTLTags[];
GLOBAL BYTE   FilterMode;
GLOBAL UWORD  stCode;

// setup.c:
GLOBAL BYTE		    OldID,NewID;
GLOBAL STRPTR		    Filter[];
GLOBAL LONG		    NotSig;
GLOBAL struct NotifyRequest *NotReq;
GLOBAL struct Catalog	    *Catalog;
GLOBAL struct LocaleBase    *LocaleBase;
GLOBAL struct muBase	    *muBase;
GLOBAL struct Library	    *XpkBase;
GLOBAL VOID		    *MemPool;
GLOBAL struct MsgPort	    *AWPort;

//_________________________________________________________________________ gui/

// fonts.c:
GLOBAL struct TextAttr *ScrFont,*TxtFont;
GLOBAL struct TextFont *ScrTFont,*TxtTFont;
GLOBAL UWORD	       ScrFontX,ScrFontY,TxtFontX,TxtFontY,TxtBLine;

// gadgets.h:
GLOBAL struct Gadget	*GList,**Gads;
GLOBAL struct MinGadget MG_LoadTree[],MG_Selection[],MG_Monitor[],MG_ArcReq[];
GLOBAL struct TagItem	GATags[],
			TXTreeStatus[],TXDirTree[],
			TXSource[],TXFiles[],TXSize[],TXDate[],TXTime[],
			TXCompress[],TXComment[],
			TXBytes[],TXDir[],
			CYFilter[],CBRecursive[],BUByDate[],BUByBits[],
			BURoot[],BUParent[],SCFileList[],BUEstimate[],
			TXSavedFiles[],TXLeftFiles[],NMDiskNumber[],
			TXDestination[],
			TXSavedSize[],TXLeftSize[],
			TXSavedBytes[],TXLeftBytes[],
			TXSavedGauge[],TXLeftGauge[],
			TXCompGauge[],TXDiskGauge[],TXReport[],
			LVDLst[],LVDevs[],CYDevs[],CBCatF[],STArcF[];
GLOBAL TEXT		TFiles[],TBytes[];
GLOBAL STRPTR		DevsLb[];
GLOBAL UWORD		Pens[];

// monitor.c:
GLOBAL struct Rectangle PBounds;
GLOBAL WORD		YPos;
GLOBAL LONG		BytesDone,   FilesDone,
			BytesLeft,   FilesLeft,
			BytesWritten,FilesFailed,
			StartDate;
GLOBAL TEXT		perDisk[];

// selection.c:
GLOBAL struct DirList DL;

// screen.c:
GLOBAL struct Screen *Scr;
GLOBAL WORD	     ScrWidth,ScrHeight;
GLOBAL STRPTR	     _WBSCRNAME_;
GLOBAL TEXT	     ScreenTitle[];
GLOBAL BYTE	     Aspect;

// windows.c:
GLOBAL APTR		VInfo;
GLOBAL struct Rectangle Off;
GLOBAL struct Window	*Win;
GLOBAL struct MinWindow MWin[];
GLOBAL struct Menu	*Menus;
GLOBAL struct TagItem	BBoxTags[],RecessTags[];
GLOBAL struct AppWindow *AWin;
GLOBAL struct AppIcon	*AIcon;
GLOBAL struct DiskObject *AIDiskObj;

//________________________________________________________________________ main/

// archive.c:
GLOBAL LONG	      DiskNum;
GLOBAL LONG	      IdntDate;
GLOBAL LONG	      ArchiveFmt;
GLOBAL struct ArcInfo GArcInfo;

// childtask.c:
GLOBAL struct SignalSemaphore SemGFX;
GLOBAL struct SignalSemaphore SemSCU;

// compress.c:
GLOBAL BYTE ToDelete[];

// crypt.c:
GLOBAL LONG CryptLen;
GLOBAL LONG CryptSum;
GLOBAL BYTE CryptKey[];

// dirtree.c:
GLOBAL WORD RecursLevel;

// report.c:
GLOBAL BYTE ReportName[];

// select.c:
GLOBAL BOOL RecursionFlag;
GLOBAL LONG BytesSelected;
GLOBAL LONG FilesSelected;
GLOBAL LONG BytesAdded;

#endif	// ABACKUP_GLOBALS_H
