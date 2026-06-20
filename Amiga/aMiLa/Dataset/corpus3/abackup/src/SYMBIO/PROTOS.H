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
    protos.h

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 05-Nov-93
    Modified: 14-Jan-98
    NO TABS
    _______________________________________________________________________
*/
#ifndef ABACKUP_PROTOS_H
#define ABACKUP_PROTOS_H

// sprintf.asm:
GLOBAL VOID __stdargs SPrintf (BYTE *,BYTE *,...);

// batch.c:
GLOBAL BOOL SetupFastMode (struct Object *);
GLOBAL LONG BatchBackup   (VOID);
GLOBAL LONG BatchRestore  (VOID);
GLOBAL LONG BatchVerify   (VOID);

// cleanup.c:
GLOBAL VOID Cleanup        (VOID);
GLOBAL VOID CleanupGadgets (VOID);

// getargs.c:
GLOBAL VOID EraseAllArgs (BOOL);
GLOBAL BOOL ReadCLIArgs  (VOID);
GLOBAL BOOL ReadWbArgs   (VOID);

// locale.c:
GLOBAL STRPTR GetStr (LONG);
GLOBAL VOID   ReformatBlock (VOID);

// icon.c:
GLOBAL VOID AddIcon (STRPTR);

// main.c:
GLOBAL VOID   PrepareWindow   (VOID);
GLOBAL BYTE   WindowAction    (VOID);
GLOBAL VOID   EnterDir        (struct Object *);
GLOBAL BOOL   ConfirmQuit     (VOID);
GLOBAL BOOL   SendMsgToPrefs  (ULONG);
GLOBAL VOID   CallPrefs       (VOID);
GLOBAL VOID   LoadSelectFile  (BYTE *);
GLOBAL VOID   AddDevsNode     (UWORD,BOOL);
GLOBAL BOOL   MakeAllDevsList (VOID);

// main2.c:
GLOBAL BYTE  HandleIDCMP (BOOL);
GLOBAL LONG  HandleWindow    (VOID);
GLOBAL BYTE  HandleMain      (UWORD);
GLOBAL BYTE  HandleLoadTree  (UWORD);
GLOBAL BYTE  HandleInfos     (UWORD);
GLOBAL BYTE  HandleSelection (UWORD,UWORD);
GLOBAL UWORD HandleClick     (WORD,WORD,UWORD);
GLOBAL BYTE  HandleMonitor   (UWORD);
GLOBAL BYTE  HandleArcReq    (UWORD,UWORD);
GLOBAL BYTE  HandleKeys      (UWORD);
GLOBAL BYTE  HandleMenus     (UWORD);
GLOBAL BYTE  HandleAppMsg    (struct AppMessage *);

// setup.c:
GLOBAL BOOL Setup     (LONG);
GLOBAL BOOL ReadPrefs (STRPTR,ABPREFS *,BOOL);

// userom.c:
GLOBAL BOOL Access (STRPTR);
GLOBAL BOOL ChDir  (STRPTR);

//______________________________________________________________________________

// bitrequest.c:
GLOBAL VOID PrepareBitRequest (VOID);
GLOBAL BOOL BitRequest        (LONG*,LONG*);

// display.c:
GLOBAL LONG GetFileType   (BYTE *,BOOL);
GLOBAL VOID DisplayObject (struct Object *);

// fonts.c:
GLOBAL VOID SetupFonts (VOID);
GLOBAL WORD ComputeX   (WORD);

// gadgets.c:
GLOBAL VOID  SetGadgetsSize (VOID);
GLOBAL VOID  SetGad         (UBYTE,ULONG,ULONG);
GLOBAL WORD  GetByteID      (LONG);
GLOBAL VOID  SetGadgets     (VOID);
GLOBAL VOID  SetNM2TX       (UBYTE,ULONG,STRPTR);
GLOBAL VOID  SetNM3TX       (UBYTE,ULONG,STRPTR);
GLOBAL BOOL  UpdateTagData  (UBYTE,ULONG,ULONG);

// monitor.c:
GLOBAL VOID MonitorPrint     (LONG,BYTE *,LONG);
GLOBAL VOID MonitorStatus    (struct List *);
GLOBAL VOID MonitorDiskGauge (struct ArcUnit *,LONG);
GLOBAL VOID SetGauge         (UBYTE,LONG,STRPTR);
GLOBAL LONG GetPreferedUnit  (LONG);
GLOBAL BYTE *FormatFileName  (BYTE *,LONG);

// menus.c:
GLOBAL VOID SetupMenus   (VOID);
GLOBAL VOID PrepareMenus (BOOL);

// requesters.c:
GLOBAL VOID About            (VOID);
GLOBAL LONG Notify           (WORD,STRPTR,WORD,ULONG,APTR);
GLOBAL VOID Warning          (WORD);
GLOBAL VOID SetRequestSize   (VOID);
GLOBAL LONG StringRequest    (STRPTR,ULONG,STRPTR,STRPTR,WORD);
GLOBAL BOOL YesNoRequest     (STRPTR,STRPTR,WORD,BOOL);
GLOBAL BOOL OverwriteRequest (LONG,struct ArcUnit *,BYTE *,struct InfoData *);
GLOBAL BOOL DiskRequest      (struct ArcUnit *,LONG);
GLOBAL BOOL FileRequest      (LONG,BYTE *,LONG);

// selection.c:
GLOBAL BYTE  *BuildEntryText (struct Object *);
GLOBAL VOID  ScrollDirList   (struct Object *,ULONG);
GLOBAL VOID  RedrawDirList   (struct Object *);
GLOBAL VOID  SelectDirEntry  (struct Object *,WORD,BOOL);
GLOBAL UWORD FindDirEntry    (struct Object *,UWORD,UWORD,BOOL);

// screen.c:
GLOBAL BOOL          SetupScreen    (VOID);
GLOBAL VOID          GetScreenInfos (VOID);
GLOBAL struct Screen *GetPubScreen  (STRPTR);
GLOBAL VOID          SetupOffset    (VOID);

// utility.c:
GLOBAL VOID  BlockWinInput   (VOID);
GLOBAL VOID  ReleaseWinInput (VOID);
GLOBAL BOOL  Shortcut        (STRPTR,UWORD);

// window.c:
GLOBAL BOOL UpdateWindow       (VOID);
GLOBAL APTR SetWinPtr          (APTR);
GLOBAL VOID Render             (VOID);
GLOBAL VOID StripIntuiMessages (VOID);

//______________________________________________________________________________

// archive.c:
GLOBAL VOID          TryToAddToCatalog (struct List *,struct Object *);
GLOBAL BOOL          ReadData          (struct List *,BYTE *,LONG);
GLOBAL BOOL          IsHeader          (BYTE *);
GLOBAL BOOL          ReadNextHeader    (struct List *,struct Header *);
GLOBAL BOOL          SkipData          (struct List *,struct Header *);
GLOBAL VOID          BuildHeader       (struct Header *,struct Object *);
GLOBAL BOOL          ReadDataToFile    (struct List *,BPTR,LONG);
GLOBAL BOOL          ReadFile          (struct Header *,BYTE *);
GLOBAL BOOL          WriteFile         (struct List *,BYTE *);
GLOBAL BOOL          ReadObjectHeader  (struct Object *,BYTE *);
GLOBAL BOOL          WriteCatalog      (struct List *,struct Object *,UBYTE,LONG);
GLOBAL BOOL          FindCatalog       (BYTE *,BOOL);
GLOBAL struct Object *LoadCatalog      (BOOL);

// asm.a:
GLOBAL UBYTE __stdargs GetChkSum (UBYTE *);
GLOBAL VOID  __stdargs B2CStr    (BYTE *,BYTE *);

// audio.c:
GLOBAL BOOL SetupAudio   (VOID);
GLOBAL VOID CleanupAudio (VOID);
GLOBAL VOID PlayBeep     (VOID);

// avl.c:
GLOBAL VOID *CreateAVLTree      (LONG );
GLOBAL BOOL AddAVLNode  	(VOID *,struct Object *);
GLOBAL VOID AVLToList   	(VOID *,struct Object *);


// badcyl.c:
GLOBAL VOID ClearBadCyl (struct ArcUnit *);
GLOBAL BOOL ExamineDisk (struct ArcUnit *);
GLOBAL BOOL LoadBadCyl  (struct ArcUnit *);
GLOBAL BOOL StoreBadCyl (struct ArcUnit *);
GLOBAL VOID AddBadCyl   (struct ArcUnit *);
GLOBAL BOOL IsBadCyl    (struct ArcUnit *,LONG);

// childtask.c:
GLOBAL LONG           DoASyncIO        (struct ArcUnit *,LONG,BYTE *,LONG);
GLOBAL BOOL           ResetChildBuffer (VOID);
GLOBAL BOOL           SetupChildTask   (VOID);
GLOBAL VOID           CleanupChildTask (VOID);
GLOBAL struct ArcUnit *WaitChildMsg    (struct InternalCmd *);

// compress.c:
GLOBAL BYTE *CompressFile     (BYTE *,struct Header *,LONG,UBYTE);
GLOBAL LONG CompressCyl       (struct ArcUnit *,BYTE *,UBYTE);
GLOBAL LONG DecompressFile    (struct Header *,BYTE *,BYTE *);
GLOBAL BOOL DecompressCyl     (struct ArcUnit *,BYTE *,LONG);
GLOBAL VOID CleanupCompTables (VOID);

// convert.c:
GLOBAL BOOL     	ConvertHeader     (struct OldHeader *,struct Header *);
GLOBAL struct Object    *ConvertObject    (struct OldObject *,struct Object *);
GLOBAL struct Object    *OldCatalToObj    (struct OldCatalog *);
GLOBAL struct DeviceDef *ConvertDeviceDef (struct OldDeviceDef *,struct DeviceDef *);

// crypt.c:
GLOBAL LONG GetPassword      (VOID);
GLOBAL VOID UncryptData      (UBYTE *,LONG);
GLOBAL VOID EncryptData      (UBYTE *,LONG);
GLOBAL BOOL UncryptNewHeader (struct Header *);

// device.c:
GLOBAL VOID           InhibitDev (struct ArcUnit *,BOOL);
GLOBAL VOID           MyDoIO     (struct ArcUnit *,LONG);
GLOBAL VOID           DoCloseDev (struct ArcUnit *);
GLOBAL BOOL           DoOpenDev  (struct ArcUnit *,struct DeviceDef *);
GLOBAL VOID           DoFlushDev (struct ArcUnit *);
GLOBAL BOOL           PrepareDev (struct ArcUnit *,LONG);
GLOBAL VOID           StopDev    (struct ArcUnit *,BOOL);
GLOBAL BOOL           CleanupDev (struct ArcUnit *);
GLOBAL BOOL           SeekDev    (struct ArcUnit *,LONG);
GLOBAL BOOL           ReadBlockDev( struct ArcUnit * , LONG , UBYTE * ) ;
GLOBAL BOOL           ReadCylDev (struct ArcUnit *,LONG,LONG);
GLOBAL BOOL           ReadDev    (struct ArcUnit *,BYTE *,LONG);
GLOBAL BOOL           WriteDev   (struct ArcUnit *,BYTE *,LONG);
GLOBAL BOOL           CloseDev   (struct ArcUnit *);
GLOBAL struct ArcUnit *FlushDev  (struct ArcUnit *,LONG);
GLOBAL struct ArcUnit *OpenDev   (struct Object *,LONG,LONG);

// dirtree.c:
GLOBAL VOID          NoChildren        (struct Object *);
GLOBAL VOID          RemChild          (struct Object *);
GLOBAL VOID          AddChild          (struct Object *,struct Object *);
GLOBAL VOID          SortDirTree       (struct Object *);
GLOBAL BOOL __stackext WalkDirTree     (struct Object *,BOOL (*)(struct Object *),LONG);
GLOBAL struct Object *FindDevByName    (BYTE *);
GLOBAL struct Object *FindObjectByNum  (struct Object *,LONG);
GLOBAL struct Object *FindObjectByName (struct Object *,BYTE *);
GLOBAL struct Object *ObjFromFib       (BYTE *,struct FileInfoBlock *);
GLOBAL struct Object *LoadDirTree      (BYTE *);
GLOBAL struct Object *AddDirTree       (struct Object *,BYTE *);
GLOBAL struct Object *LoadDevList      (VOID);
GLOBAL VOID          UpdateDevList     (BYTE *);

// floppy.c:
GLOBAL BOOL           FloppyPresent    (struct ArcUnit *);
GLOBAL BOOL           FloppyWasChanged (struct ArcUnit *);
GLOBAL BOOL           PrepareFloppy    (struct ArcUnit *);
GLOBAL BOOL           AskGoodDisk      (struct List *,LONG);
GLOBAL struct ArcUnit *NextFloppy      (struct List *);

// io.c:
GLOBAL BOOL           FlushArc     (struct List *,LONG);
GLOBAL BOOL           FitArc       (struct List *,LONG);
GLOBAL BOOL           ReadArc      (struct List *,BYTE *,LONG);
GLOBAL BOOL           WriteArc     (struct List *,BYTE *,LONG);
GLOBAL BOOL           SeekArc      (struct List *,LONG,LONG);
GLOBAL BOOL           CloseUnit    (struct ArcUnit *);
GLOBAL BOOL           CloseArc     (struct List *);
GLOBAL struct ArcUnit *FindCurUnit (struct List *);
GLOBAL struct ArcUnit *SetCurUnit  (struct List *,LONG);
GLOBAL VOID           StopArc      (struct List *,BOOL);
GLOBAL struct List    *OpenArc     (BYTE *,LONG);

// newfmt.c:
GLOBAL BOOL          VerifyChkSum   (UBYTE *);
GLOBAL VOID          BuildChkSum    (UBYTE *);
GLOBAL BOOL          IsNewHeader    (struct Header *);
GLOBAL BOOL          WriteData      (struct List *,BYTE *,LONG);
GLOBAL BOOL          ReadNewData    (struct List *,BYTE *,LONG);
GLOBAL VOID          PrepareData    (LONG,BYTE *,LONG);
GLOBAL BOOL          WriteHeader    (struct List *,struct Header *);
GLOBAL struct Object *BuildNewCatal (struct Object *,struct Object *,LONG *);

// objects.c:
GLOBAL BOOL FreeObject   (VOID *);
GLOBAL VOID *AllocObject (LONG,VOID *);

// oldfmt.c:
GLOBAL BOOL          IsOldHeader    (struct OldHeader *,BYTE *);
GLOBAL BOOL          ReadOldData    (struct List *,BYTE *,LONG);
GLOBAL struct Object *BuildOldCatal (struct Object *,struct OldCatalog **,LONG *);

// rdb.c:
GLOBAL BOOL UpdateDevFromRDB( struct ArcUnit * ) ;

// rebuild.c:
GLOBAL BOOL DoRebuild (BYTE *);

// report.c:
GLOBAL VOID PrintLabels        (LONG);
GLOBAL VOID PrintCurrentList   (struct Object *);
GLOBAL VOID OpenReport         (LONG,LONG);
GLOBAL VOID CloseReport        (VOID);
GLOBAL VOID ReportBreaked      (VOID);
GLOBAL VOID ReportError        (BYTE *,BYTE *);
GLOBAL VOID ReportBadCyl       (struct ArcUnit *,LONG);
GLOBAL VOID ReportBFile        (struct Object *,BYTE *,LONG);
GLOBAL VOID ReportBCatal       (struct Object *,LONG);
GLOBAL VOID ReportBDir         (struct Object *,BYTE *);
GLOBAL VOID ReportBLink        (struct Object *,BYTE *);
GLOBAL VOID ReportBCyl         (BYTE *,LONG,LONG);
GLOBAL VOID ReportBFRemoved    (BYTE *);
GLOBAL VOID ReportNotReplaced  (BYTE *);
GLOBAL VOID ReportRenamed      (BYTE *,BYTE *);
GLOBAL VOID ReportNotFound     (BYTE *);
GLOBAL VOID ReportRFile        (struct Object *,BYTE *);
GLOBAL VOID ReportRCyl         (BYTE *,LONG);
GLOBAL VOID ReportVDifferent   (BYTE *);
GLOBAL VOID ReportVChanged     (BYTE *);
GLOBAL VOID ReportVFile        (struct Object *,BYTE *);
GLOBAL VOID ReportAccessDenied (BYTE *);

// restore.c:
GLOBAL BOOL RestoreFile (struct Header *,BYTE *,BOOL);
GLOBAL BOOL RestoreDev  (struct Header *,BYTE *,LONG);
GLOBAL BOOL DoRestore   (struct Object *,UBYTE *);

// save.c:
GLOBAL BOOL SaveFile  (BYTE *,struct Object *,UBYTE);
GLOBAL BOOL DoBackup  (struct Object *,UBYTE *);
GLOBAL BYTE *Estimate (struct Object *,LONG *);

// select.c:
GLOBAL VOID          DoSelect     (struct Object *,LONG,BYTE *);
GLOBAL VOID          AbortSelect  (VOID);
GLOBAL BOOL          RecordSelect (BYTE *);
GLOBAL VOID          SaveSelect   (VOID);
GLOBAL struct Object *PlaySelect  (struct Object *,BYTE *);

// tape.c:
GLOBAL BOOL           ReadTape   (struct ArcUnit *,BYTE *,LONG);
GLOBAL BOOL           WriteTape  (struct ArcUnit *,BYTE *,LONG);
GLOBAL BOOL           FlushTape  (struct ArcUnit *);
GLOBAL BOOL           CloseTape  (struct ArcUnit *);
GLOBAL VOID           RewindTape (struct ArcUnit *);
GLOBAL struct ArcUnit *OpenTape  (LONG);

// utils.c:
GLOBAL VOID     	WakeUpUser        (VOID);
GLOBAL VOID     	ABackupAlert      (BYTE *,BYTE *);
GLOBAL VOID     	UnitError         (struct ArcUnit *);
GLOBAL VOID     	HandleError       (BYTE *,LONG);
GLOBAL VOID     	*MyAllocMem       (ULONG,LONG);
GLOBAL VOID     	MyFreeMem         (VOID *);
GLOBAL VOID __stackext  GetFullName       (BYTE *,struct Object *);
GLOBAL VOID     	BuildDestName     (BYTE *,struct Object *);
GLOBAL BOOL     	MyExamine         (BYTE *);
GLOBAL BOOL     	MyInfo  	  (BYTE *,BYTE *);
GLOBAL VOID     	SwapNodes         (struct List *,struct Node *,struct Node *);
GLOBAL VOID     	*LoadFileInMem    (BYTE *,LONG,LONG);
GLOBAL LONG     	PackDate	  (struct DateStamp *);
GLOBAL BYTE     	*PackedDateToStr  (LONG);
GLOBAL LONG     	PackedDateFromStr (BYTE *,LONG);
GLOBAL LONG     	Ratio   	  (LONG,LONG);
GLOBAL BOOL     	SolveLink         (BYTE *,BYTE *);
GLOBAL BOOL     	SameObj 	  (struct Object *,struct Object *);
GLOBAL BOOL __stackext  CheckPath         (struct Object *,BYTE *);
GLOBAL VOID     	CleanObj	  (struct Object *);
GLOBAL BYTE     	*NextComponant    (VOID);
GLOBAL BYTE     	*FirstComponant   (BYTE *);
GLOBAL VOID     	TmpName 	  (BYTE *);
GLOBAL VOID     	InitOperation     (VOID);
GLOBAL BYTE     	*ElapsedTime      (VOID);
GLOBAL BOOL     	StopMe  	  (VOID);
GLOBAL struct DeviceDef *GetDeviceDef     (struct Object *);
GLOBAL struct DateStamp *UnPackDate       (LONG);
GLOBAL BOOL     	IsOnMUFSVolume    (BYTE *);
GLOBAL BOOL     	CopyFile	  (BYTE *,BYTE *,LONG);
GLOBAL BOOL     	MatchNoCompExt    (BYTE *);
GLOBAL VOID     	StringToList      (struct List *,STRPTR);
GLOBAL UWORD    	ListToString      (struct List *,STRPTR);
GLOBAL BOOL     	AddName 	  (struct List *,STRPTR);
GLOBAL VOID     	FreeNameList      (struct List *);
GLOBAL struct Node      *FindDevNode      (struct List *,UWORD);
GLOBAL BOOL     	CheckAccess       (struct Header *);
GLOBAL LONG     	AutoSplitLimit    (VOID);

// verify.c:
GLOBAL BOOL DoVerify (struct Object *);

#endif    // ABACKUP_PROTOS_H
