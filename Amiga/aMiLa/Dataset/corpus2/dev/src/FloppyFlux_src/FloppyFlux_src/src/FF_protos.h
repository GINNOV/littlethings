
/* FF_main.c            */

Prototype LONG wbmain( struct WBStartup *WBS );
Prototype LONG main( void );
Prototype BOOL FF_InitPrg( void );
Prototype void FF_EndPrg( void );
Prototype void InitXPK( void );
Prototype void FreeXPK( void );
Prototype __asm __geta4 UBYTE *GTLayoutLocalHookCode( __a0 struct Hook *H, __a2 struct LayoutHandle *LH, __a1 ULONG SID );
Prototype __asm __geta4 ULONG XPKProgressHookCode( __a0 struct Hook *H, __a1 struct XpkProgress *XPKPro );
Prototype LONG XpkQueryTags( ULONG tag1, ... );
Prototype LONG XpkPackTags( ULONG tag1, ... );
Prototype LONG XpkUnpackTags( ULONG tag1, ... );
Prototype LONG XpkExamineTags( struct XpkFib *XPKf, ULONG tag1, ... );
Prototype void LT_New( struct LayoutHandle *handle, ULONG tag1, ... );
Prototype struct LayoutHandle *LT_CreateHandleTags( struct Screen *screen, ULONG tag1, ... );
Prototype struct Window *LT_Build( struct LayoutHandle *handle, ULONG tag1, ...  );
Prototype void LT_SetAttributes( struct LayoutHandle *handle, LONG ID, ULONG tag1, ...  );
Prototype LONG LT_GetAttributes( struct LayoutHandle *handle, LONG ID, ULONG tag1, ...  );
Prototype BOOL AddFFPort( void );
Prototype void RemFFPort( void );
Prototype struct FFMsgPort *FindFFPort( void );
Prototype void AddNotification( void );
Prototype void RemNotification( void );
Prototype APTR MemPool;
Prototype struct Library *GTLayoutBase;
Prototype struct Library *XpkBase;
Prototype struct Library *WorkbenchBase;
Prototype struct XpkPackerList *XPKpl;
Prototype ULONG XpkChunkSize;
Prototype ULONG ActiveUnit;
Prototype UWORD putchproc[];
Prototype struct Hook XPKProgressHook;
Prototype struct Hook GTLayoutLocalHook;
Prototype struct FileRequester *ImpExpFileReq;
Prototype struct Process *ThisProcess;
Prototype void DEBUG( void );
Prototype struct WBStartup *WBStartupMsg;
Prototype struct FFMsgPort *FFMP;
Prototype BOOL NotifyActive;
Prototype BYTE NotifySigNum;

/* FF_imagelist.c       */

Prototype void InitImageList( void );
Prototype struct ImageEntry *AllocImageEntry( void );
Prototype void FreeImageEntry( struct ImageEntry *IE );
Prototype struct ImageEntry *AddImageEntry(UBYTE *ImageName, UBYTE *ImageComment, ULONG ImageSize, ULONG PackID, BOOL NoLVUpdate);
Prototype void InsertImageEntrySorted( struct ImageEntry *IE );
Prototype void RemImageEntry(struct ImageEntry *IE, BOOL NoLVUpdate);
Prototype void SortImageEntry(struct ImageEntry *IE);
Prototype struct ImageEntry *GetImageEntry( ULONG Number );
Prototype void SetImageEntryName(struct ImageEntry *IE, UBYTE *Name);
Prototype void SetImageEntryComment(struct ImageEntry *IE, UBYTE *Comment);
Prototype ULONG UpdateImageEntrySize( struct ImageEntry *IE );
Prototype void SetImageEntryPackStat( struct ImageEntry *IE );
Prototype void LayoutImageEntryViewString(struct ImageEntry *IE);
Prototype void DeleteImageEntry(struct ImageEntry *IE);
Prototype void AttachImageList( void );
Prototype void AttachImageListFollow( struct ImageEntry *IE );
Prototype void DetachImageList ( void );
Prototype void RemoveImageList ( void );
Prototype BOOL EditImageEntryAttr( struct ImageEntry *IE, BOOL NewEntry );
Prototype BOOL CheckImageEntryName( UBYTE *NameStr, struct ImageEntry *IE );
Prototype void BuildImageList( BOOL Force );
Prototype ULONG FreeImageList( void );
Prototype ULONG CountImageList( void );
Prototype void DeleteImageList( void );
Prototype struct ImageEntry *FindImageEntryByName( UBYTE *Name, struct ImageEntry *ExcludeIE );
Prototype ULONG FindImageEntryIndex( struct ImageEntry *IEToFnd );
Prototype struct List IEList;

/* FF_configio.c        */

Prototype void SetConfigDefaults( void );
Prototype void LoadConfig( void );
Prototype void SaveConfig( void );
Prototype struct FFConfig FFC;

/* FF_routines.c        */

Prototype ULONG IsFileXPKPacked( UBYTE *FileName );
Prototype APTR MyAllocVec( ULONG Size );
Prototype void MyFreeVec( APTR Vec );
Prototype ULONG GetFileSize( UBYTE *FileName );
Prototype ULONG RawDoFmtSize( UBYTE *FmtString, APTR Fmt );
Prototype BOOL RemDelProtection( UBYTE *FileName, BOOL Force );
Prototype BOOL IsFileNameValid( UBYTE *FileName );
Prototype void PrintComment( void );
Prototype void PrintStatus( UBYTE *String, APTR Fmt );
Prototype void FFXPKError( LONG xpkerrcode, UBYTE *Body, void *BodyFmt );
Prototype void FFDOSError( UBYTE *Body, void *BodyFmt );
Prototype void FFError( UBYTE *Body, void *BodyFmt );
Prototype ULONG FFInformation(UBYTE *Body, void *BodyFmt);
Prototype ULONG FFRequest(UBYTE *Body, void *BodyFmt, UBYTE *Gads);
Prototype ULONG FFPopup(UBYTE *Title, UBYTE *Body, void *BodyFmt, UBYTE *Gads);
Prototype BOOL PackMemory(APTR Mem, ULONG MemSize, ULONG *PackedMem, ULONG *PackedSize, struct ProgressHandle *PH );
Prototype BOOL UnpackMemory(APTR Mem, ULONG MemSize, ULONG *UnpackedMem, ULONG *UnpackedSize, struct ProgressHandle *PH );
Prototype BOOL AslAddPart( struct FileRequester *FR, struct WBArg *WA, UBYTE *Buf, ULONG BufLen );
Prototype BOOL PackFile( UBYTE *FileName, BOOL ShowProgress );
Prototype BOOL UnpackFile( UBYTE *FileName, BOOL ShowProgress );
Prototype BOOL CopyFileAndUnpack( UBYTE *SrcName, UBYTE *DestName, struct FileInfoBlock *GFIB );
Prototype BOOL CopyFileAndPack( UBYTE *SrcName, UBYTE *DestName, struct FileInfoBlock *GFIB );
Prototype BOOL CopyFile( UBYTE *SrcName, UBYTE *DestName, struct FileInfoBlock *GFIB  );
Prototype BOOL MoveFile( UBYTE *SrcName, UBYTE *DestName, struct FileInfoBlock *GFIB  );
Prototype BOOL GetFIB( UBYTE *FileName, struct FileInfoBlock *FIB );
Prototype APTR LoadFileToVec( UBYTE *Filename, ULONG *Length );
Prototype BOOL SaveFile( UBYTE *FileName, APTR Mem, ULONG MemLen );
Prototype UBYTE *FindTempFile( UBYTE *PathString );
Prototype void FreeTempFile( UBYTE *TempNameBuf );
Prototype void FlushMsgPort( struct MsgPort *MP );
Prototype ULONG GetTasksStackSize( void );

/* FF_diskio.c          */

Prototype BOOL InitTD( ULONG UnitNumber );
Prototype void EndTD( void );
Prototype void MotorOn( void );
Prototype void MotorOff( void );
Prototype BOOL DiskToFile( ULONG UnitNumber, UBYTE *FileName );
Prototype BOOL FileToDisk( ULONG UnitNumber, UBYTE *FileName );
Prototype BOOL DiskToPackedFile( ULONG UnitNumber, UBYTE *FileName );
Prototype BOOL PackedFileToDisk( ULONG UnitNumber, UBYTE *FileName );
Prototype BOOL PromptForDisk( struct IOExtTD *MyIOReq , ULONG UnitID, ULONG PromptMode );
Prototype BOOL GetDiskDetails(UBYTE *DeviceName, UBYTE *Buf, ULONG BufLen, struct InfoData *DestID );

/* FF_wininfo.c         */

Prototype void DisplayInfo( void );
Prototype BOOL OpenInfoWindow( UBYTE *Text, APTR TextFmt );
Prototype void CloseInfoWindow( void );
Prototype void IDCMPInfoWindow( void );

/* FF_winprogress.c     */

Prototype struct ProgressHandle *OpenProgressWindow( ULONG TotalUnits, UBYTE *TitleText );
Prototype BOOL UpdateProgress( struct ProgressHandle *PH, ULONG UnitsDoneSoFar );
Prototype void CloseProgressWindow( struct ProgressHandle *PH );
Prototype void ChangeProgressTotal( struct ProgressHandle *PH, ULONG NewTotal );

/* FF_winsettings.c     */

Prototype void DisplaySettingsWindow( void );
Prototype BOOL OpenSettingsWindow( void );
Prototype void CloseSettingsWindow( void );
Prototype void IDCMPSettingsWindow( void );
Prototype BOOL BuildXPKMethodList( void );
Prototype void FreeXPKMethodList( void );
Prototype struct PackerListNode *GetXPKMethodEntry( ULONG Number );
Prototype void AttachXPKMethodList( void );
Prototype void RemoveXPKMethodList( void );
Prototype void PrintSettingsStatus( UBYTE *String, APTR Fmt );
Prototype ULONG GetXPKMethodListNumber( UBYTE *MethodName );

/* FF_winmain.c         */

Prototype void IDCMPMainWindow( void );
Prototype BOOL OpenMainWindow( void );
Prototype void CloseMainWindow( void );
Prototype void ActM_AboutFF( void );
Prototype void ActM_ImportDiskImage( void );
Prototype void ActM_ExportDiskImage( void );
Prototype void ActM_PackSelected( void );
Prototype void ActM_UnpackSelected( void );
Prototype void ActM_PackAll( void );
Prototype void ActM_UnpackAll( void );
Prototype struct Window *MainWindow;
Prototype struct LayoutHandle *MainWindowHandle;

/* FF_strings.c         */

Prototype UBYTE *GetFFStr( ULONG SID );
Prototype UBYTE *Strings[];

/* FF_wingetstr.c       */

Prototype UBYTE *GetString( UBYTE *StartStr );
Prototype BOOL OpenGetStrWindow( UBYTE *StartStr );
Prototype void CloseGetStrWindow( void );
Prototype UBYTE *IDCMPGetStrWindow( void );
Prototype struct LayoutHandle *GetStrWindowHandle;
Prototype struct Window *GetStrWindow;

/* FF_imagecache.c      */

Prototype BOOL CheckCacheFile( UBYTE *CacheFileName );
Prototype BOOL CreateILFromCF( UBYTE *CacheFileName );
Prototype BOOL CreateCFFromIL( UBYTE *CacheFileName );

/* FF_iconify.c         */

Prototype BOOL HideGUI( void );
Prototype Prototype BOOL ShowGUI( void );
Prototype struct DiskObject *AI_GetDiskObject( void );
Prototype void AI_FreeDiskObject( void );
Prototype BOOL AI_Show( void );
Prototype void AI_Hide( void );
Prototype BOOL Iconified;

/* FF_wb.c              */

Prototype BOOL InitWB( void );
Prototype void EndWB( void );
Prototype void ProcessWBMsgs( void );
Prototype BOOL ImportImageViaWB( UBYTE *SrcPath, UBYTE *DestName );
Prototype struct MsgPort *WBMP;
Prototype BOOL FromWB;

/* MACHINE GENERATED */

