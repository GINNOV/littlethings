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
	windows.c

	© 1993-1995
	by Reza Elghazi & Denis Gounelle

	All Rights Reserved
	___________________

	Version : 38.0
	Created : 11-Aug-93
	Modified: 18-Jan-98
	___________________
*/

#include "headers.h"
#include "gadgets.h"
#include "windows.h"

STATIC VOID     ChangeWindow    	(VOID);
STATIC BOOL     SetupWindow     		(VOID);
STATIC BOOL     SetupGadgets    	(VOID);
STATIC WORD     ComputeFromGadget       (WORD,WORD);
STATIC WORD     ComputeFromBevelBox     (WORD);

//______________________________________________________________________________

BOOL
UpdateWindow()
{
	if (Win) ChangeWindow();

	if (SetupGadgets() && SetupWindow()) {
		AddGList(Win,GList,-1,-1,NULL);
		RefreshGList(GList,Win,NULL,-1);
		Render();
		GT_RefreshWindow(Win,NULL);

		OldID = NewID;
		return TRUE;
	}
	return FALSE;
}
//______________________________________________________________________________

// remove the gadgets and size the window:

__inline STATIC VOID
ChangeWindow()
{
	WORD    left,top,width,height;
	struct  IntuiMessage *imsg;
	BOOL    wait;

	width  = MWin[NewID].mw_Width +Offset.MaxX;
	height = MWin[NewID].mw_Height+Offset.MaxY;

	if (_EXECFROMABACKUP_) {
		left = (Scr->Width -width)/2;
		top  = (Scr->Height-height-Offset.MinY)/2+Offset.MinY;
	}
	else {
		left = Win->LeftEdge;
		top  = Win->TopEdge;
	}

	SetWindowTitles(Win,GetStr(MWin[NewID].mw_Title),(UBYTE *)~0);
	CleanupGadgets();
	EraseRect(Win->RPort,Offset.MinX,Offset.MinY,MWin[OldID].mw_Width+Offset.MinX-1,MWin[OldID].mw_Height+Offset.MinY-1);
	ChangeWindowBox(Win,left,top,width,height);

	wait = TRUE;
	while (wait) {
		WaitPort(Win->UserPort);
		while (wait && (imsg = GT_GetIMsg(Win->UserPort))) {
			if (imsg->Class == IDCMP_CHANGEWINDOW) wait = FALSE;
			GT_ReplyIMsg(imsg);
		}
	}
}
//______________________________________________________________________________

__inline STATIC BOOL
SetupWindow()
{
	WORD    zoom[4],ID,tlen,len;

	if (Win) return TRUE;

	// look for the longest window title:
	for (ID = tlen = 0; ID < WIN_COUNT; ID++) {
		len  = strlen(GetStr((LONG)MWin[ID].mw_Title));
		tlen = MAX(tlen,len);
	}

	// alternate zoom position and dimensions:
	zoom[2] = FontX*(tlen+1)+80;
	zoom[3] = Offset.MinY;

	WinTags[2].ti_Data = MWin[NewID].mw_Width +Offset.MaxX;
	WinTags[3].ti_Data = MWin[NewID].mw_Height+Offset.MaxY;
	if (_EXECFROMABACKUP_) {
		WinTags[0].ti_Data = (Scr->Width -WinTags[2].ti_Data)/2;
		WinTags[1].ti_Data = (Scr->Height-WinTags[3].ti_Data-Offset.MinY)/2+Offset.MinY;
		zoom[0] = 0;
		zoom[1] = Offset.MinY;
	}
	else {
		WinTags[1].ti_Data = Offset.MinY;
		zoom[0] = zoom[1] = ~0; // size-only zooming (V39+)
	}
	WinTags[6].ti_Data = (ULONG)GetStr((LONG)MWin[NewID].mw_Title);
	WinTags[8].ti_Data = (ULONG)Scr;
	WinTags[9].ti_Data = (ULONG)zoom;

	if (Menus && LayoutMenusA(Menus,VInfo,MenuTags)) {
		if (Win = OpenWindowTagList(NULL,WinTags)) {
			Win->UserData = (BYTE *)SetWinPtr((APTR)Win);

		//      if (GFXV39PLUS) SetRPAttrsA(Win->RPort,RPTags);

			//      create a Message Port & add an AppWindow:
			if (MsgPort     = CreateMsgPort())
				AppWin = AddAppWindowA(NULL,NULL,Win,MsgPort,TAG_DONE);

			SetMenuStrip(Win,Menus);

			return TRUE;
		}
		else WARNING(MSG_WARN_OPEN_WINDOW);
	}
	else WARNING(MSG_WARN_LAYOUT_MENUS);
	return FALSE;
}
//_____________________________________________________________________________

APTR
SetWinPtr (APTR newptr)
{
	struct Process  *pr;
	APTR    oldptr;

	pr = (struct Process *)FindTask(NULL);

	oldptr = pr->pr_WindowPtr;
	pr->pr_WindowPtr = newptr;

	return(oldptr);
}
//_____________________________________________________________________________

__inline STATIC BOOL
SetupGadgets()
{
	BYTE    count = GD_COUNT(NewID);

	if(Gads = AllocVec((count+1)*sizeof(struct Gadget),MEMF_CLEAR)) {
		struct Gadget   *g;

		if (g = CreateContext(&GList)) {
			struct NewGadget	ng;
			struct _Object  	*image;
			struct TagItem  	*ti;
			BYTE    n;

			ng.ng_TextAttr   = Font;
			ng.ng_VisualInfo = VInfo;
			ng.ng_UserData   = NULL;

			for (n = 0; n < count; n++) {
				ng.ng_LeftEdge   = GD_LEFT(n);
				ng.ng_TopEdge    = GD_TOP(n) +Offset.MinY;
				ng.ng_Width     	 = GD_WIDTH(n);
				ng.ng_Height     = GD_HEIGHT(n);
				ng.ng_GadgetText = GD_TEXT(n)==MSG_VOID?NULL:GetStr(GD_TEXT(n));
				ng.ng_GadgetID   = n;
				ng.ng_Flags     	 = GD_FLAGS(n);

				if (GD_TYPE(n) == LISTVIEW_KIND) {
					ti = FindTagItem(GTLV_ShowSelected,GD_TAGS(n));
					if (ti && ti->ti_Data) ti->ti_Data = (ULONG)g;
				}

				Gads[n] = g = CreateGadgetA(GD_TYPE(n),g,&ng,GD_TAGS(n));
				if (g) {
					if (GD_TYPE(n) == GENERIC_KIND) {
						g->Flags	  |= GFLG_GADGIMAGE | GFLG_GADGHIMAGE;
						g->Activation |= GACT_RELVERIFY;

						if ((NewID == WIN_RESTORE && n == GD_RestoreToLoad)
						 || NewID == WIN_MISC)
							 image = GetDirImage;
						else if (NewID == WIN_GUI)
							 image = GetElseImage;
						else image = GetFileImage;

						g->GadgetRender = g->SelectRender = (APTR)image;
					}
				}
				else {
					WARNING(MSG_WARN_CREATE_GADGETS);
					return FALSE;
				}
			}
			// create and link backfilling:
			Gads[count] = g = CreateBackfill(g,ng,count);
			if (g) return TRUE;
			else WARNING(MSG_WARN_WINDOW_BACKFILL);
		}
		else WARNING(MSG_WARN_CREATE_CONTEXT);
	}
	else WARNING(MSG_WARN_MEMORY);
	return FALSE;
}
//_____________________________________________________________________________

#define VISIBLEDEVICES  4
#define VISIBLEXPKLIBS  5

VOID
SetupSizes()
{
	WORD    ID,ol,fo,ho,gh,g;

	ol = 5*Aspect+2;
	fo = 4*Aspect+1;	// full outline
	ho = 2*Aspect+1;	// half outline
	gh = FontY+4;   	// average gadget height

	for (ID = 0; ID < WIN_COUNT; ID++) {
		MWin[ID].mw_Width  = ComputeX(MWin[ID].mw_Width);
		for (g = 0; g < GD_COUNT(ID); g++) {
			GL(g) = ComputeX(GL(g))+Offset.MinX;
			GW(g) = ComputeX(GW(g));
			switch (MWin[ID].mw_Gad[g].mg_Type) {
				case BUTTON_KIND:
				case NUMBER_KIND:
				case TEXT_KIND:
				case SLIDER_KIND:       GH(g) = gh;
									break;
				case CHECKBOX_KIND: GH(g) = gh-1;
									break;
				case CYCLE_KIND:	GH(g) = gh+1;
									break;
				default:			GH(g) = gh+2;
									break;
			}
		}
		for (g = 0; g < BOXCOUNT; g++) {
			BL(g) = ComputeX(BL(g))+Offset.MinX;
			BW(g) = ComputeX(BW(g));
		}
	}

	//_____________________________________________________________ Main window:

	ID = WIN_MAIN;

	GT(GD_Backup)   =
	GT(GD_Tape)     	= fo;
	GT(GD_Restore)  =
	GT(GD_GUI)      	= FROMGAD(GD_Backup);
	GT(GD_Verify)   =
	GT(GD_External) = FROMGAD(GD_Restore);
	GT(GD_Compress) =
	GT(GD_Misc)     	= FROMGAD(GD_Verify);

	GT(GD_Save)     	=
	GT(GD_Use)      	=
	GT(GD_Quit)     	= FROMGAD(GD_Compress)+fo-Aspect;

	//__________________________________________________________ Backup options:

	ID = WIN_BACKUP;

	GH(GD_BackupDeviceList) =
	GH(GD_BackupDevices)    = VISIBLEDEVICES*(FontY+1)+(GTV39PLUS?4:7);

	BT(0) =
	BT(2) = fo;

	BH(0) = GH(GD_BackupDeviceList)+2*gh+5*Aspect+5;
	BH(2) = 11*gh+14*Aspect;

	BH(1) = 4*gh+7*Aspect+7;
	BT(1) = BT(2)+BH(2)-BH(1);

	GT(GD_BackupTo) 		 = BT(0)+ho;
	GT(GD_BackupDeviceList)  =
	GT(GD_BackupDevices)     = FROMGAD(GD_BackupTo)-Aspect;
	GT(GD_BackupArcFile)     =
	GT(GD_BackupArcFileLoad) = FROMGAD(GD_BackupDeviceList);

	GT(GD_BufferSize)       	 = BT(1)+ho;
	GT(GD_LogFile)  		 =
	GT(GD_LogFileLoad)      	 = FROMGAD(GD_BufferSize);
	GT(GD_DefaultComment)    = FROMGAD(GD_LogFile);
	GT(GD_BackupReport)     	 =
	GT(GD_BackupReportTo)    =
	GT(GD_BackupReportType)  = FROMGAD(GD_DefaultComment);
	GT(GD_BackupReport)     	+= 2;

	GT(GD_BackupVerify)     	 = BT(2)+ho;
	GT(GD_UseChildTask)     	 = FROMGAD(GD_BackupVerify);
	GT(GD_BackupLinks)      	 = FROMGAD(GD_UseChildTask);
	GT(GD_AddComment)       	 = FROMGAD(GD_BackupLinks);
	GT(GD_AddIcon)  		 = FROMGAD(GD_AddComment);
	GT(GD_CompressData)     	 = FROMGAD(GD_AddIcon);
	GT(GD_CompressCatalog)   = FROMGAD(GD_CompressData);
	GT(GD_Encrypt)  		 = FROMGAD(GD_CompressCatalog);
	GT(GD_SetArchiveBit)     = FROMGAD(GD_Encrypt);
	GT(GD_DuplicateCatalog)  = FROMGAD(GD_SetArchiveBit);
	GT(GD_IgnoreSkipme)      = FROMGAD(GD_DuplicateCatalog);
/*
	GT(GD_BackupVerify)     	 = BT(2)+ho;
	for (g = GD_CompressData; g <= GD_DuplicateCatalog; g++) {
		GT(g) = FROMGAD(g-1);
	}
*/
	GT(GD_Ok)       			 =
	GT(GD_Cancel)   		 = FROMGAD(GD_BackupReport)+ol;

	//_________________________________________________________ Restore options:

	ID = WIN_RESTORE;

	GH(GD_RestoreDeviceList) =
	GH(GD_RestoreDevices)    = VISIBLEDEVICES*(FontY+1)+(GTV39PLUS?4:7);

	BT(0) =
	BT(3) = fo;

	BH(0) = GH(GD_RestoreDeviceList)+2*gh+5*Aspect+5;

	BT(1) = FROMBOX;
	BH(1) = gh+4*Aspect+4;

	BT(2) = BT(1)+BH(1)+2*Aspect;
	BH(2) = 3*gh+6*Aspect+5;

	BH(3) = BH(0)+BH(1)+BH(2)+4*Aspect;

	GT(GD_RestoreFrom)      	  = BT(0)+ho;
	GT(GD_RestoreDeviceList)  =
	GT(GD_RestoreDevices)     = FROMGAD(GD_RestoreFrom)-Aspect;
	GT(GD_RestoreArcFile)     =
	GT(GD_RestoreArcFileLoad) = FROMGAD(GD_RestoreDeviceList);

	GT(GD_RestoreTo)		  =
	GT(GD_RestoreToLoad)      = BT(1)+ho;

	GT(GD_ExistingFiles)      = BT(2)+ho;
	GT(GD_BadFiles) 		  = FROMGAD(GD_ExistingFiles);
	GT(GD_RestoreReport)      =
	GT(GD_RestoreReportTo)    =
	GT(GD_RestoreReportType)  = FROMGAD(GD_BadFiles);
	GT(GD_RestoreReport)     += 2;

	GT(GD_RestoreTree)      	  = BT(3)+ho;
	GT(GD_RestoreDate)      	  = FROMGAD(GD_RestoreTree);
	GT(GD_RestoreLinks)     	  = FROMGAD(GD_RestoreDate);
	GT(GD_RestoreEmptyDirs)   = FROMGAD(GD_RestoreLinks);
	GT(GD_UseCatalogFile)     = FROMGAD(GD_RestoreEmptyDirs);

	GT(GD_Ok)       			  =
	GT(GD_Cancel)   		  = FROMGAD(GD_RestoreReport)+ol;

	//__________________________________________________________ Verify options:

	ID = WIN_VERIFY;

	BT(0) = fo;
	BH(0) = gh+4*Aspect+3;

	BT(1) = FROMBOX;
	BH(1) = 2*gh+5*Aspect;

	GT(GD_VerifyReport)     	=
	GT(GD_VerifyReportTo)   =
	GT(GD_VerifyReportType) = BT(0)+ho;
	GT(GD_VerifyReport)        += 2;

	GT(GD_CompareData)      	=
	GT(GD_IgnoreFilesDate)  = BT(1)+ho;
	GT(GD_SelectFiles)      	= FROMGAD(GD_CompareData);

	GT(GD_Ok)       			=
	GT(GD_Cancel)   		= FROMGAD(GD_SelectFiles)+ol;

	//_____________________________________________________ Compression options:

	ID = WIN_COMPRESS;

	GH(GD_XpkLibs)  	  = VISIBLEXPKLIBS*(FontY+1)+(GTV39PLUS?4:7);
	GT(GD_CompressMethod) = fo;

	BT(0) = FROMGAD(GD_CompressMethod)+Aspect;
	BH(0) = GH(GD_XpkLibs)+4*gh+6*Aspect+2;

	BH(1) = 3*gh;

	BT(2) = FROMBOX;
	BH(2) = 2*gh+5*Aspect+6;

	BT(3) = fo;
	BH(3) = BH(0)+BH(2)+4*Aspect+gh+1;

	GT(GD_XpkLibs)  		  = BT(0)+ho;
	GT(GD_XpkMode)  		  =
	GT(GD_XpkDescription)     = FROMGAD(GD_XpkLibs);
	BT(1)   				  =
	GT(GD_XpkRatio) 		  = FROMGAD(GD_XpkDescription);
	GT(GD_XpkPackSpeed)     	  = FROMGAD(GD_XpkRatio)-Aspect;
	GT(GD_XpkUnpackSpeed)     = FROMGAD(GD_XpkPackSpeed)-Aspect;

	GT(GD_ExternalComp)     	  =
	GT(GD_ExternalCompLoad)   = BT(2)+ho;
	GT(GD_ExternalDecomp)     =
	GT(GD_ExternalDecompLoad) = FROMGAD(GD_ExternalComp);

	GH(GD_FilterList)       	  = BH(0)+gh+3*Aspect+(GTV39PLUS?7:4);
	GT(GD_FilterList)       	  = BT(0);
	GT(GD_FilterDelete)     	  = GT(GD_ExternalDecomp)+2;

	GT(GD_Ok)       			  =
	GT(GD_Cancel)   		  = FROMGAD(GD_ExternalDecomp)+ol;

	//____________________________________________________________ Tape options:

	ID = WIN_TAPE;

	BT(0) = fo;
	BH(0) = 2*gh+5*Aspect+6;

	BT(1) = FROMBOX;
	BH(1) = 2*gh+5*Aspect;

	GT(GD_DeviceDriver)     	= BT(0)+ho;
	GT(GD_SCSIPort) 		=
	GT(GD_BlockSize)		= FROMGAD(GD_DeviceDriver);

	GT(GD_Rewind)   		=
	GT(GD_AutoRetention)    	= BT(1)+ho;
	GT(GD_Eject)    		=
	GT(GD_FastMemBuffer)    	= FROMGAD(GD_Rewind);


	GT(GD_Ok)       		=
	GT(GD_SCSIInquiry)      	=
	GT(GD_Cancel)   		= FROMGAD(GD_Eject)+ol;

	//_____________________________________________________________ GUI options:

	ID = WIN_GUI;

	BT(0) = fo;
	BH(0) = 3*gh+6*Aspect+7;

	BT(1) = FROMBOX;
	BH(1) = 2*gh+5*Aspect+6;

	GT(GD_ScreenType)         = BT(0)+ho;
	GT(GD_PubScreenName)  = FROMGAD(GD_ScreenType);
	GH(GD_ScreenMode)        += 2;
	GT(GD_ScreenMode)         =
	GT(GD_ScreenModeLoad) = FROMGAD(GD_PubScreenName);

	GT(GD_ScrFontName)        =
	GT(GD_ScrFontSize)        =
	GT(GD_ScrFontLoad)        = BT(1)+ho;
	GT(GD_TxtFontName)        =
	GT(GD_TxtFontSize)        =
	GT(GD_TxtFontLoad)        = FROMGAD(GD_ScrFontName);

	GT(GD_Ok)       		  =
	GT(GD_Palette)  	  =
	GT(GD_Cancel)   	  = FROMGAD(GD_TxtFontName)+ol;

	//_______________________________________________ External programs options:

	ID = WIN_EXTERNAL;

	BT(0) = fo;
	BH(0) = 3*gh+6*Aspect+8;

	BT(1) = FROMBOX;
	BH(1) = 2*gh+5*Aspect;

	GT(GD_ExternalASCII)      =
	GT(GD_ExternalASCIILoad)  = BT(0)+ho;
	GT(GD_ExternalILBM)     	  =
	GT(GD_ExternalILBMLoad)   = FROMGAD(GD_ExternalASCII);
	GT(GD_ExternalOthers)     =
	GT(GD_ExternalOthersLoad) = FROMGAD(GD_ExternalILBM);

	GT(GD_ExternalAsynchro)   = BT(1)+ho;
	GT(GD_ExternalConfirm)    = FROMGAD(GD_ExternalAsynchro);

	GT(GD_Ok)       			  =
	GT(GD_Cancel)   		  = FROMGAD(GD_ExternalConfirm)+ol;

	//___________________________________________________ Miscellaneous options:

	ID = WIN_MISC;

	BT(0) = fo;
	BH(0) = 4*gh+7*Aspect+8;

	BT(1) = FROMBOX;
	BH(1) = 2*gh+5*Aspect+3;

	GT(GD_Alert)    		 = BT(0)+ho;
	GT(GD_FilesSize)		 = FROMGAD(GD_Alert);
	GT(GD_TempDirectory)     =
	GT(GD_TempDirectoryLoad) = FROMGAD(GD_FilesSize);
	GT(GD_SelectionPath)     =
	GT(GD_SelectionPathLoad) = FROMGAD(GD_TempDirectory);

	GT(GD_PrintLabels)      	 = BT(1)+ho;
	GT(GD_LabelsLength)     	 = FROMGAD(GD_PrintLabels);

	GT(GD_Ok)       			 =
	GT(GD_Cancel)   		 = FROMGAD(GD_LabelsLength)+ol;

	// compute all windows height:
	for (ID = 0; ID < WIN_COUNT; ID++) MWin[ID].mw_Height = FROMGAD(0)+Aspect;
}
//_____________________________________________________________________________

STATIC WORD
ComputeFromGadget (WORD ID,WORD y)
{
	return((WORD)(GT(y)+GH(y)+Aspect));
}

STATIC WORD
ComputeFromBevelBox (WORD ID)
{
	return((WORD)(BT(0)+BH(0)+2*Aspect));
}
//_____________________________________________________________________________

UWORD
ComputeX (UWORD value)
{
	return((UWORD)(FontX*value/8));
}

UWORD
ComputeY (UWORD value)
{
	return((UWORD)(FontY*value/8));
}
//_____________________________________________________________________________

VOID
Render()
{
	WORD    box,ID;

	for (box = 0,ID = NewID; box < BOXCOUNT; box++)
		DrawBevelBoxA(Win->RPort,
					  BL(box),BT(box)+Offset.MinY,
					  BW(box),BH(box),
					  BR(box)? RecessTags: BBoxTags);
}

// Tab size 4
