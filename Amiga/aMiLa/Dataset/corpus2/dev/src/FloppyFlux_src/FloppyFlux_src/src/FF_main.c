
/*
 * [!BGN - MACHINE GENERATED - DO NOT EDIT THIS HEADER]
 *
 * Program   : FloppyFlux (Floppy disk backup program)
 * Version   : 1.2
 * File      : Work:Source/!WIP/FloppyFlux/FF_main.c
 * Author    : Andrew Bell
 * Copyright : Copyright © 1999 Andrew Bell
 * Created   : Wednesday 05-May-99 22:42:29
 * Modified  : Sunday 27-Jun-99 19:57:22
 * Comment   : Primary module
 *
 * (Generated with StampSource 1.1 by Andrew Bell)
 *
 * [!END - MACHINE GENERATED - DO NOT EDIT THIS HEADER]
 *
 */

#define FLOPPYFLUX_MAIN_C

#include <FF_include.h>

/*
 *  TODO:
 *
 *************************************************
 *
 *  · Auto save window positions in config.
 *
 *  · Auto save currently selected drive in cycle gadget.
 *
 *  · Add custom startup code, reduce FloppyFlux executable size.
 *
 *  · Auto-detect what floppy drives are not available, then we can
 *    omit them from the cycle gadget.
 *
 *  · Rewrite the following routines, they're coded like shite.
 *
 *    DiskToFile(), FileToDisk(), DiskToPackedFile() & PackedFileToDisk().
 *
 *    [ Merge DiskToFile() with DiskToPackedFile() also merge FileToDisk()
 *      with PackedFileToDisk() ].
 *
 */

/*************************************************
 *
 * Function prototypes
 *
 */

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

/*************************************************
 *
 * Data protos
 *
 */

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

/*************************************************
 *
 * Globals (data and variables)
 *
 */

APTR MemPool = NULL;
struct Library *GTLayoutBase = NULL;
struct Library *XpkBase = NULL;
struct Library *WorkbenchBase = NULL;
struct XpkPackerList *XPKpl = NULL;
struct FileRequester *ImpExpFileReq = NULL; /* Import and Export filereq */
ULONG XpkChunkSize = DEFXPKCHUNKSIZE;
ULONG ActiveUnit = 0; /* defaults to DF0: */
struct Process *ThisProcess = NULL;

/*************************************************
 *
 * DICE stub work-arounds for #pragma tagcalls (XPK)
 *
 */

LONG XpkQueryTags( ULONG tag1, ... )
{
  return XpkQuery( (struct TagItem *) &tag1 );
}

LONG XpkPackTags( ULONG tag1, ... )
{
  return XpkPack( (struct TagItem *) &tag1 );
}

LONG XpkUnpackTags( ULONG tag1, ... )
{
  return XpkUnpack( (struct TagItem *) &tag1 );
}

LONG XpkExamineTags( struct XpkFib *XPKf, ULONG tag1, ... )
{
  return XpkExamine( XPKf, (struct TagItem *) &tag1 );
}

/*************************************************
 *
 * DICE stub work-arounds for #pragma tagcalls (GTLayout)
 *
 */

void LT_New( struct LayoutHandle *handle, ULONG tag1, ... )
{
  LT_NewA( handle, (struct TagItem *) &tag1 );
}

struct LayoutHandle *LT_CreateHandleTags( struct Screen *screen, ULONG tag1, ... )
{
  return LT_CreateHandleTagList(screen, (struct TagItem *) &tag1 );
}

struct Window *LT_Build( struct LayoutHandle *handle, ULONG tag1, ...  )
{
  return LT_BuildA( handle, (struct TagItem *) &tag1 );
}

void LT_SetAttributes( struct LayoutHandle *handle, LONG ID, ULONG tag1, ...  )
{
  LT_SetAttributesA( handle, ID, (struct TagItem *) &tag1 );
}

LONG LT_GetAttributes( struct LayoutHandle *handle, LONG ID, ULONG tag1, ...  )
{
  return LT_GetAttributesA( handle, ID, (struct TagItem *) &tag1 );
}

/*************************************************
 *
 * Special stuff
 *
 */

/* This is a bit of a hack, it is used my RawDoFmt()
   to write to the destination buffer.

   move.b d0,(a3)+ \n rts */

UWORD putchproc[] = { 0x16c0, 0x4e75 };
void DEBUG( void ) { } /* Used for tracing / debugging */
#define mark(str,fmt) VPrintf(str "\n",fmt); Delay(50*2);

/*************************************************
 *
 * Hooks
 *
 */

struct Hook XPKProgressHook =
{
  { NULL, NULL }, (void *) XPKProgressHookCode, NULL, NULL
};

struct Hook GTLayoutLocalHook =
{
  { NULL, NULL }, (void *) GTLayoutLocalHookCode, NULL, NULL
};

/*************************************************
 *
 * The start of all our problems :)
 *
 * Note: This code swaps the stack size to 16KB.
 *
 */

const UBYTE InternalVersionString[] = { VERSTAG };

#define PUDDLESIZE (1024*16)
#define THRESHSIZE (PUDDLESIZE/4)

Prototype struct WBStartup *WBStartupMsg;

struct WBStartup *WBStartupMsg = NULL;

LONG wbmain( struct WBStartup *WBS )
{
  /* TODO: Insert CurDir code here */

  WBStartupMsg = WBS;

  return main();
}

LONG main( void )
{
  ThisProcess = (struct Process *) FindTask(NULL);

  LONG retcode = RETURN_FAIL;

  if (!SysBase->AttnFlags & AFF_68020)
  {
    FFError("I need at least an MC68020 cpu!", NULL);
    return retcode;
  }

  if (SysBase->LibNode.lib_Version < 39)
  {
    FFError("I need Amiga OS 3.0+!", NULL);
    return retcode;
  }

  if (MemPool = (APTR) CreatePool( MEMF_CLEAR, PUDDLESIZE, THRESHSIZE ))
  {
    struct StackSwapStruct SSS;
    BOOL DoStackSwap = TRUE;
    BOOL StackOK = TRUE;

    if (GetTasksStackSize() >= FFSTACKSIZE)
    {
      DoStackSwap = FALSE;
    }

    if (DoStackSwap)
    {
      /* It's important that we use MEMF_PUBLIC for the stack memory! */

      if (SSS.stk_Lower = (APTR) AllocVec( FFSTACKSIZE, MEMF_PUBLIC | MEMF_CLEAR ))
      {
        SSS.stk_Upper = (ULONG) SSS.stk_Lower;
        ( (ULONG) SSS.stk_Upper ) += FFSTACKSIZE;
        SSS.stk_Pointer = (APTR) SSS.stk_Upper;
        StackSwap( (struct StackSwapStruct *) &SSS );
      }
      else
      {
        FFError("Cannot get any memory for stack!", NULL);
        StackOK = FALSE;
      }
    }

    if (StackOK && FF_InitPrg())
    {
      IDCMPMainWindow(); retcode = RETURN_OK;
    }
    FF_EndPrg();

    if (StackOK && DoStackSwap)
    {
      StackSwap( &SSS );
      FreeVec( SSS.stk_Lower );
    }

    DeletePool( MemPool );
  }
  else FFError("Failed to create memory pool!", NULL);

  return retcode;
}

/*************************************************
 *
 * Setup the program.
 *
 */

#define GTVERSION 45L
#define XPKVERSION 5L

BOOL FF_InitPrg( void )
{
  InitImageList();

  if (FindFFPort())
  {
    switch (FFRequest("FloppyFlux is already running, run another copy?", NULL, "Yes|No"))
    {
      case 0: /* No */
        return FALSE;
      default:
      case 1: /* Yes */
        break;
    }
  }

  if (!AddFFPort())
  {
    return FALSE;
  }

  LoadConfig(); /* Attempt to load the config file */

  WorkbenchBase = OpenLibrary(WORKBENCH_NAME, 39L);
  if (!WorkbenchBase)
  {
    FFError("Unable to open " WORKBENCH_NAME " version 39!", NULL);
    return FALSE;
  }

  if (!InitWB())
  {
    FFError("Failed to allocate Workbench resources!", NULL);
    return FALSE;
  }

  GTLayoutBase = OpenLibrary("gtlayout.library", GTVERSION);
  if (!GTLayoutBase)
  {
    ULONG v = GTVERSION;
    FFError("Unable to open gtlayout.library version %lu!", &v);
    return FALSE;
  }

  /* Init ASL */

  ImpExpFileReq = (struct FileRequester *) AllocAslRequestTags(ASL_FileRequest,
    ASLFR_SleepWindow,   TRUE,
    ASLFR_InitialDrawer, "RAM:",
    ASLFR_DoPatterns,    TRUE,
    ASLFR_RejectIcons,   TRUE,
    ASLFR_DrawersOnly,   FALSE,
    ASLFR_InitialHeight, 256L,
    TAG_DONE );

  if (!ImpExpFileReq)
  {
    FFError("Unable to initilize ASL file requester!", NULL);
    return FALSE;
  }

  InitXPK();

  /* Lock / create the image dir */

  BPTR IDirLock;
  BOOL DskImgDwrValid = FALSE;

  IDirLock = Lock(IMAGEDIRNAME, SHARED_LOCK);

  if (!IDirLock)
  {
    if (IoErr() == ERROR_OBJECT_NOT_FOUND)
    {
      IDirLock = CreateDir(IMAGEDIRNAME);

      if (!IDirLock)
      {
        FFDOSError("Unable to create disk image dir!", NULL);
      }
      else DskImgDwrValid = TRUE;
    }
    else
    {
      FFDOSError("Unable to access disk image drawer!", NULL);
    }
  }
  else DskImgDwrValid = TRUE;

  if (IDirLock)
  {
    UnLock(IDirLock);
  }

  if (!DskImgDwrValid)
  {
    return FALSE;
  }

  AddNotification();

  if (!OpenMainWindow())
  {
    return FALSE;
  }

  BuildImageList( FALSE );
  return TRUE;
}

/*************************************************
 *
 * Shutdown the program.
 *
 */

void FF_EndPrg( void )
{
  FreeImageList();
  CloseMainWindow();
  RemNotification();

  if (ImpExpFileReq)
  {
    FreeAslRequest( ImpExpFileReq );
    ImpExpFileReq = NULL;
  }

  FreeXPK();

  if (GTLayoutBase)
  {
    CloseLibrary( GTLayoutBase );
    GTLayoutBase = NULL;
  }

  EndWB();

  if ( WorkbenchBase )
  {
    CloseLibrary( WorkbenchBase );
    WorkbenchBase = NULL;
  }

  RemFFPort();
}

/*************************************************
 *
 * Open XPK, if it's not already opened.
 *
 */

void InitXPK( void )
{
  if (XpkBase) return;

  XpkBase = OpenLibrary(XPKNAME, XPKVERSION);

  if (!XpkBase && FFC.FFC_UseXPK)
  {
    /* Note: This requester is only displayed if the config
             states that XPK should be used. */

    ULONG v = XPKVERSION;
    FFInformation("This program requires " XPKNAME " version %lu for\n"
            "compression and decompression, you will not be able\n"
            "to take advantage of these features until you install\n"
            "this library onto your system!", &v);
  }
  else if (!XpkBase)
  {
    return;
  }
  else /* Initilize XPK */
  {
    XPKpl = XpkAllocObject(XPKOBJ_PACKERLIST, NULL);

    if (XPKpl)
    {
      LONG xpkerr = XpkQueryTags(XPK_PackersQuery, XPKpl, TAG_DONE);

      if ( xpkerr != XPKERR_OK )
      {
        FreeXPK();
      }
    }
    else
    {
      FFError("Failed to initilize " XPKNAME "!", NULL);
      FreeXPK();
    }
  }
}

/*************************************************
 *
 * Close XPK, if already opened.
 *
 */

void FreeXPK( void )
{
  if (XpkBase)
  {
    if (XPKpl)
    {
      XpkFreeObject(XPKOBJ_PACKERLIST, XPKpl);
      XPKpl = NULL;
    }

    CloseLibrary(XpkBase);
    XpkBase = NULL;
  }
}

/*************************************************
 *
 * Special hook code that is used to show user
 * the progress of XPK compression/decompression.
 *
 */

__asm __geta4 ULONG XPKProgressHookCode( __a0 struct Hook *H, __a1 struct XpkProgress *XPKPro )
{
  struct ProgressHandle *PH = (struct ProgressHandle *) H->h_Data;

  return (ULONG) UpdateProgress( PH, XPKPro->xp_Done );

  /* Note: To return NULL means don't abort */
}

/*************************************************
 *
 * Special hook code that is used to to lookup
 * strings for GTLayout.library. In the future,
 * I will probably build full locale support
 * into FloppyFlux.
 *
 */

/* Move to SS_stings */
__asm __geta4 UBYTE *GTLayoutLocalHookCode( __a0 struct Hook *H, __a2 struct LayoutHandle *LH, __a1 ULONG SID )
{
  return GetFFStr( SID );
}

/*************************************************
 *
 * Create and make FF's port public.
 *
 */

Prototype struct FFMsgPort *FFMP;
struct FFMsgPort *FFMP = NULL;
BOOL FFPortIsPublic = FALSE;

BOOL AddFFPort( void )
{
  if (!(FFMP = (struct FFMsgPort *) CreateMsgPort()))
  {
    return FALSE;
  }

  FFMP->ffmp_Version = VERSION;
  FFMP->ffmp_Revision = REVISION;

  if (FindFFPort())
  {
    FFPortIsPublic = FALSE;
  }
  else
  {
    FFMP->ffmp_MsgPort.mp_Node.ln_Pri = -1;
    FFMP->ffmp_MsgPort.mp_Node.ln_Name = FFPORTNAME;

    AddPort( (struct MsgPort *) FFMP);
    FFPortIsPublic = TRUE;
  }
  return TRUE;
}

/*************************************************
 *
 * Remove FF's port from the public list, and
 * delete it.
 *
 */

void RemFFPort( void )
{
  if (FFMP)
  {
    if (FFPortIsPublic)
    {
      RemPort( (struct MsgPort *) FFMP );
    }
    DeleteMsgPort( (struct MsgPort *) FFMP );
    FFMP = NULL;
  }
}

/*************************************************
 *
 * Quickly find FF's port.
 *
 */

struct FFMsgPort *FindFFPort( void )
{
  return (struct FFMsgPort *) FindPort( FFPORTNAME );
}

/*************************************************
 *
 * Add notification to the image directory.
 *
 */

struct NotifyRequest FFNR;

Prototype BOOL NotifyActive;
BOOL NotifyActive = FALSE;

Prototype BYTE NotifySigNum;
BYTE NotifySigNum = -1;

void AddNotification( void )
{
  setmem(&FFNR, sizeof(struct NotifyRequest), 0);

  NotifySigNum = AllocSignal(-1);

  if (NotifySigNum == -1)
  {
    return;
  }

  FFNR.nr_Name = IMAGEDIRNAME;
  FFNR.nr_Flags = NRF_SEND_SIGNAL;
  FFNR.nr_stuff.nr_Signal.nr_SignalNum = NotifySigNum;
  FFNR.nr_stuff.nr_Signal.nr_Task = (struct Task *) ThisProcess;

  NotifyActive = StartNotify( (struct NotifyRequest *) &FFNR );
}

/*************************************************
 *
 * Remove notification from the image directory.
 *
 */

void RemNotification( void )
{
  if ( NotifySigNum != -1 )
  {
    FreeSignal( NotifySigNum );
    NotifySigNum = -1;
  }

  if ( NotifyActive )
  {
    EndNotify( (struct NotifyRequest *) &FFNR );
    NotifyActive =  FALSE;
  }
}

/*************************************************
 *
 *
 *
 */


