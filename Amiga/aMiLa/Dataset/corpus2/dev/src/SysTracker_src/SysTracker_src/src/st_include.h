/***************************************************************************/
/* st_include.h - Assorted defines for each module.                        */
/*                                                                         */
/* Copyright © 1999-2000 Andrew Bell. All rights reserved.                 */
/***************************************************************************/

#ifndef SYSTRACKER_INCLUDE_H
#define SYSTRACKER_INCLUDE_H

/***************************************************************************/
/* Assorted defines */
/***************************************************************************/

#undef NULL
#define NULL ((void *)0)

/* StampSource should really be handling this year! */
#define YEAR      "1999-2000"
#define EMAILADDY "andrew.ab2000@bigfoot.com"
#define WEBADDY   "http://www.andrewb.exl.co.uk"  

/* Size of IO buffer, passed to SetVBuf(). */
#define IO_BUFFER_SIZE   (1024*32)
#define TEMP_BUFFER_SIZE (1024*4)

/* One day this will used in all areas of the source */
#define MAXPATHLEN 256

#ifndef MAKE_ID
#define MAKE_ID(a, b, c, d) \
  ((ULONG) (a)<<24 | (ULONG) (b)<<16 | (ULONG) (c)<<8 | (ULONG) (d))
#endif

/***************************************************************************/
/* System includes */
/***************************************************************************/

#ifndef EXEC_TYPES_H
#include <EXEC/types.h>
#endif /* EXEC_TYPES_H */

#ifndef EXEC_EXECBASE_H
#include <EXEC/execbase.h>
#endif /* EXEC_EXECBASE_H */

#ifndef EXEC_SEMAPHORES_H
#include <EXEC/semaphores.h>
#endif /* EXEC_SEMAPHORES_H */

#ifndef EXEC_LIBRARIES_H
#include <EXEC/libraries.h>
#endif /* EXEC_LIBRARIES_H */

#ifndef EXEC_TASKS_H
#include <EXEC/tasks.h>
#endif /* EXEC_TASKS_H */

#ifndef EXEC_DEVICES_H
#include <EXEC/devices.h>
#endif /* EXEC_DEVICES_H */

#ifndef EXEC_NODES_H
#include <EXEC/nodes.h>
#endif /* EXEC_NODES_H */

#ifndef EXEC_LISTS_H
#include <EXEC/lists.h>
#endif /* EXEC_LISTS_H */

#ifndef EXEC_IO_H
#include <EXEC/io.h>
#endif /* EXEC_IO_H */

#ifndef EXEC_PORTS_H
#include <EXEC/ports.h>
#endif /* EXEC_PORTS_H */

#ifndef EXEC_MEMORY_H
#include <EXEC/memory.h>
#endif /* EXEC_MEMORY_H */

#ifndef DOS_STDIO_H
#include <DOS/stdio.h>
#endif /* DOS_STDIO_H */

#ifndef DOS_DOS_H
#include <DOS/dos.h>
#endif /* DOS_DOS_H */

#ifndef DOS_DOSTAGS_H
#include <DOS/dostags.h>
#endif /* DOS_DOS_H */

#ifndef DOS_DOSEXTENS_H
#include <DOS/dosextens.h>
#endif /* DOS_DOSEXTENS_H */

#ifndef DOS_EXALL_H
#include <DOS/exall.h>
#endif /* DOS_EXALL_H */

#ifndef DOS_NOTIFY_H
#include <DOS/notify.h>
#endif /* DOS_NOTIFY_H */

#ifndef DOS_DATETIME_H
#include <DOS/datetime.h>
#endif /* DOS_DATETIME_H */

#ifndef LIBRARIES_ASL_H
#include <LIBRARIES/asl.h>
#endif /* LIBRARIES_ASL_H */

#ifndef UTILITY_DATE_H
#include <UTILITY/date.h>
#endif /* UTILITY_DATE_H */

#ifndef UTILITY_UTILITY_H
#include <UTILITY/utility.h>
#endif /* UTILITY_UTILITY_H */

#ifndef UTILITY_TAGITEM_H
#include <UTILITY/tagitem.h>
#endif /* UTILITY_TAGITEM_H */

#ifndef UTILITY_HOOKS_H
#include <UTILITY/hooks.h>
#endif /* UTILITY_HOOKS_H */

#ifndef WORKBENCH_STARTUP_H
#include <WORKBENCH/startup.h>
#endif /* WORKBENCH_STARTUP_H */

#ifndef WORKBENCH_ICON_H
#include <WORKBENCH/icon.h>
#endif /* WORKBENCH_ICON_H */

#ifndef WORKBENCH_WORKBENCH_H
#include <WORKBENCH/workbench.h>
#endif /* WORKBENCH_WORKBENCH_H */

#ifndef INTUITION_INTUITION_H
#include <INTUITION/intuition.h>
#endif /* INTUITION_INTUITION_H */

#ifndef LIBRARIES_MUI_H
#include <libraries/mui.h>
#endif /* LIBRARIES_MUI_H */

extern struct ExecBase *SysBase;

#include <clib/muimaster_protos.h>
#include <clib/alib_protos.h>

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/gadtools_protos.h>
#include <clib/intuition_protos.h>
#include <clib/utility_protos.h>
#include <clib/asl_protos.h>
#include <clib/wb_protos.h>
#include <clib/icon_protos.h>

#ifdef __MAXON__
#include <pragma/exec_lib.h>
#include <pragma/dos_lib.h>
#include <pragma/gadtools_lib.h>
#include <pragma/intuition_lib.h>
#include <pragma/utility_lib.h>
#include <pragma/asl_lib.h>
#include <pragma/wb_lib.h>
#include <pragma/icon_lib.h>
#endif /* __MAXON__ */

#ifdef __VBCC__
#include <inline/exec_protos.h>
#include <inline/dos_protos.h>
#include <inline/gadtools_protos.h>
#include <inline/intuition_protos.h>
#include <inline/utility_protos.h>
#include <inline/asl_protos.h>
#include <inline/wb_protos.h>
#include <inline/icon_protos.h>
#endif

#ifdef _DCC
#include <pragmas/exec_pragmas.h>
#include <pragmas/dos_pragmas.h>
#include <pragmas/gadtools_pragmas.h>
#include <pragmas/intuition_pragmas.h>
#include <pragmas/utility_pragmas.h>
#include <pragmas/asl_pragmas.h>
#include <pragmas/wb_pragmas.h>
#include <pragmas/icon_pragmas.h>
#endif

/* ANSI */

#include <stdio.h>
#include <string.h>

#pragma header

/***************************************************************************/
/* st_main.c */
/***************************************************************************/

#define STACKSIZE        (1024*32) /* 32KB of stack space */

extern struct Process *SysTrackerProcess;
extern BOOL cfg_RemovePaths;
extern BOOL cfg_BeSystemLegal;
extern BOOL cfg_AutoUpdate;
extern BOOL cfg_DebugMode;
extern BOOL cfg_TrackUnusedResources;
extern BOOL cfg_ShowUnusedResources;

/***************************************************************************/
/* st_memory.c */
/***************************************************************************/

#define SAFETY            30L      /* Sometimes used on allocations */
#define POOL_PUDDLESIZE (8*1024)
#define POOL_THRESHSIZE (POOL_PUDDLESIZE/4) 

/***************************************************************************/
/* st_artl.c */
/***************************************************************************/

/* ARTL defines */

struct AppList
{
  struct List            al_List;
  struct SignalSemaphore al_Key;
};

#define AppList_SIZE sizeof(struct AppList)

struct AppNode
{
  struct Node       an_Node;
  UWORD             an_Status;    /* AN_STATUS_#? */
  struct Task      *an_TaskPtr;   /* Don't access the struct itself! */
    /* Set with ARTL_SetTNTaskName() ; Free with MEM_FreeVec() */  
  UBYTE            *an_TaskName;
  struct DateStamp  an_TrackDate;
  ULONG             an_TaskType;
    /* Set with ARTL_SetTNCmdName() ; Free with MEM_FreeVec() */
  UBYTE            *an_CmdName;
  ULONG             an_LaunchType;
  BPTR              an_SegList;
  struct List       an_TrackerList;
};

enum
{
  AN_STATUS_UNKNOWN = 0,
  AN_STATUS_ALIVE,
  AN_STATUS_DEAD,
};

#define AppNode_SIZE sizeof(struct AppNode)

struct TrackerNode
{
  struct Node       tn_Node;           /* We're part of a chain           */
  BOOL              tn_InUse;          /* Resource currently in use?      */
  ULONG             tn_ID;             /* PMSGID_#?                       */
  struct DateStamp  tn_TrackDate;      /* For future use                  */

  /* For resources that have no from of Unique ID, like libs. */
  LONG              tn_OpenCnt;        /* Keep this signed                */
  UBYTE             tn_OpenCntTxt[12]; /* Used by the lister hook only    */

  /************************************** PMSGID_OPENLIBRARY **************/
  UBYTE            *tn_LibName;        /* Free with MEM_FreeVec()         */
  ULONG             tn_LibVer;         /* Version passed to OpenLibrary() */
  struct Library   *tn_LibBase;        /* Don't access the struct!        */

  /************************************** PMSGID_OPENDEVICE ***************/
  UBYTE            *tn_DevName;        /* Free with MEM_FreeVec()         */
  ULONG             tn_DevUnitNum;     /* UnitNum passed to OpenDevice()  */
  ULONG          tn_DevUnitNumTxt[12]; /* UnitNum passed to OpenDevice()  */
  struct IORequest *tn_DevIOReq;       /* UID - Don't access the struct!  */
  ULONG             tn_DevFlags;       /* Flags passed to OpenDevice()    */

  /************************************** PMSGID_OPENFONT *****************/
  struct TextAttr  *tn_FontTextAttr;   /* Don't access the struct!        */
  struct TextFont  *tn_FontTextFont;   /* UID - Don't access the struct!  */
  UBYTE            *tn_FontName;       /*                                 */
  UWORD             tn_FontYSize;      /* Free with MEM_FreeVec()         */
  UBYTE             tn_FontStyle;      /*                                 */
  UBYTE             tn_FontFlags;      /*                                 */

  /************************************** PMSGID_OPEN *********************/
  UBYTE            *tn_FHName;         /* Free with MEM_FreeVec()         */
  LONG              tn_FHMode;         /*                                 */
  BPTR              tn_FH;             /* UID                             */

  /************************************** PMSGID_LOCK *********************/
  UBYTE            *tn_LockName;       /* Free with MEM_FreeVec()         */
  LONG              tn_LockMode;       /*                                 */
  BPTR              tn_Lock;           /* UID                             */

  /************************************************************************/
  UBYTE            *tn_CurDirName;     /* For PMSGID_OPEN/PMSGID_LOCK IDs */
};

#define TrackerNode_SIZE sizeof( struct TrackerNode )

enum
{
  ADDMODE_APPEND,
  ADDMODE_ALPHABETICALLY,
};


/***************************************************************************/
/* st_gui.c */
/***************************************************************************/

enum /* This this in sync with the above cycle entries */
{
  TRACKMODE_LIBRARIES = 0,
  TRACKMODE_DEVICES,
  TRACKMODE_FONTS,
  TRACKMODE_LOCKS,
  TRACKMODE_FILEHANDLES,
};

#define MyKeyButton(name, key, shorthelp) \
  TextObject,\
    ButtonFrame,\
    MUIA_ShortHelp    , shorthelp,\
    MUIA_Font, MUIV_Font_Button,\
    MUIA_Text_Contents, name,\
    MUIA_Text_PreParse, "\33c",\
    MUIA_Text_HiChar  , key,\
    MUIA_ControlChar  , key,\
    MUIA_InputMode    , MUIV_InputMode_RelVerify,\
    MUIA_Background   , MUII_ButtonBack,\
    End
        
#define nmTitle(txt) \
  { NM_TITLE, txt, NULL, 0, 0, NULL },
#define nmItem(txt, commkey, flags, mid) \
  { NM_ITEM, txt, commkey, flags, 0, (APTR) mid },
#define nmSub(txt, commkey, flags, mid) \
  { NM_SUB, txt, commkey, flags, 0, (APTR) mid },
#define nmBar \
  { NM_ITEM, NM_BARLABEL, NULL, 0, 0, NULL },
#define nmEnd \
  { NM_END, NULL, NULL, 0, 0, NULL }


enum /* Object IDs */
{
  OID_START = 1,

  OID_APP,              /* Not used yet */
  OID_APP_DOUBLESTART,

  OID_MAIN_WINDOW,
  OID_MAIN_TRKMODE,
  OID_MAIN_SAVE,
  OID_MAIN_UPDATE,
  OID_MAIN_QUIT,
  OID_MAIN_TRACKERLIST,
  OID_MAIN_TRACKERLISTVIEW,
  OID_MAIN_TRACKERLISTVIEW_DOUBLECLICK,
  OID_MAIN_TRACKERLISTVIEW_SINGLECLICK,
  OID_MAIN_OPENCNT,
  OID_MAIN_APPLISTVIEW,
  OID_MAIN_APPLISTVIEW_SINGLECLICK,
  OID_MAIN_APPLIST,
  OID_MAIN_MENU_PROJECT_ABOUT,
  OID_MAIN_MENU_PROJECT_ABOUT_MUI,
  OID_MAIN_MENU_PROJECT_SETTINGS_MUI,
  OID_MAIN_MENU_PROJECT_HIDE,
  OID_MAIN_MENU_PROJECT_QUIT,
  OID_MAIN_MENU_CONTROL_RESET,
  OID_MAIN_MENU_CONTROL_CLEARDEADAPPS,
  OID_MAIN_MENU_CONTROL_CLEARUNUSEDRES,
  OID_MAIN_MENU_CONTROL_TRACKUNUSEDRES,
  OID_MAIN_MENU_CONTROL_SHOWUNUSEDRES,

  OID_APPUSING_WINDOW,
  OID_APPUSING_RESNAME,
  OID_APPUSING_LIST,
  OID_APPUSING_LISTVIEW,
  OID_APPUSING_EXIT,

  OID_AMOUNT
};

/***************************************************************************/
/* st_patch.c */
/***************************************************************************/

extern ULONG LVOOpenLibrary;     /* Pull the LVOs from amiga.lib */
extern ULONG LVOCloseLibrary;
extern ULONG LVOOpenDevice;
extern ULONG LVOCloseDevice;
extern ULONG LVOMakeLibrary;
extern ULONG LVOOpenFont;
extern ULONG LVOCloseFont;
extern ULONG LVOOpenDiskFont;

extern ULONG LVOOpen;
extern ULONG LVOClose;
extern ULONG LVOLock;
extern ULONG LVOUnLock;
extern ULONG LVOOpenFromLock;

/* This structure MUST remain in sync with
   the one in st_patches_asm.s!!! */

struct PatchMsg
{
  struct Message      pmsg_MsgHeader;
  LONG                pmsg_ID;
  struct Task        *pmsg_TaskPtr;
  UBYTE              *pmsg_TaskName;
  ULONG               pmsg_TaskType;
  BOOL                pmsg_TaskFrozen;
  UWORD               pmsg_Padding01;  /* Keep everything align to 32 bits. */
  UBYTE              *pmsg_CmdName;
  ULONG               pmsg_LaunchType; /* LT_#? */
  BPTR                pmsg_SegList;    /* Only valid if LaunchType == LT_CLI */

  ULONG               pmsg_LibType;    /* Not yet implemented */
  UBYTE              *pmsg_LibName;
  ULONG               pmsg_LibVer;
  struct Library     *pmsg_LibBase;

  UBYTE              *pmsg_DevName;
  ULONG               pmsg_DevUnitNum;
  struct IORequest   *pmsg_DevIOReq;
  ULONG               pmsg_DevFlags;

  struct TextAttr    *pmsg_FontTextAttr;
  struct TextFont    *pmsg_FontTextFont;
  UBYTE              *pmsg_FontName;
  UWORD               pmsg_FontYSize;
  UBYTE               pmsg_FontStyle;
  UBYTE               pmsg_FontFlags;
 
  UBYTE              *pmsg_FHName;
  LONG                pmsg_FHMode;
  BPTR                pmsg_FH;
  
  UBYTE              *pmsg_LockName;
  LONG                pmsg_LockMode;
  BPTR                pmsg_Lock;

  UBYTE              *pmsg_CurDirName;
};

#define LT_NA  0                 /* For pmsg_LaunchType */
#define LT_CLI 1
#define LT_WB  2

#define PMSGID_ALL              -1 /* Special values are signed */
#define PMSGID_UNKNOWN           0
#define PMSGID_OPENLIBRARY       1
#define PMSGID_OPENDEVICE        2
#define PMSGID_CLOSELIBRARY      3
#define PMSGID_CLOSEDEVICE       4
#define PMSGID_OPENFONT          5
#define PMSGID_CLOSEFONT         6
/*#define PMSGID_OPENDISKFONT      7 *** Obsolete *** */
/*#define PMSGID_MAKELIBRARY       8 *** Obsolete *** */
#define PMSGID_OPEN              9
#define PMSGID_CLOSE             10
#define PMSGID_LOCK              11
#define PMSGID_UNLOCK            12
#define PMSGID_OPENFROMLOCK      13

/* These are located in the st_patches assembly module. */

#ifdef __MAXON__
extern void PATCH_DeletePatchMsg( register __a0 struct PatchMsg *PMsg );
extern UBYTE *PATCH_StrToVec( register __a0 UBYTE *Str );
APTR PATCH_AllocVec( register __d0 ULONG ByteSize );
void PATCH_FreeVec( register __a1 APTR Vec );
#endif /* __MAXON__ */

#ifdef __VBCC__
extern void PATCH_DeletePatchMsg( __reg("a0") struct PatchMsg *PMsg );
extern UBYTE *PATCH_StrToVec( __reg("a0") UBYTE *Str );
APTR PATCH_AllocVec( __reg("d0") ULONG ByteSize );
void PATCH_FreeVec( __reg("a1") APTR Vec );
#endif /* __VBCC__ */

#ifdef _DCC
extern void PATCH_DeletePatchMsg( __a0 struct PatchMsg *PMsg );
extern UBYTE *PATCH_StrToVec( __a0 UBYTE *Str );
APTR PATCH_AllocVec( __d0 ULONG ByteSize );
void PATCH_FreeVec( __a1 APTR Vec );
#endif /* _DCC */

extern APTR PATCH_NewOpenLibrary;
extern APTR PATCH_NewCloseLibrary;
extern APTR PATCH_NewOpenDevice;
extern APTR PATCH_NewCloseDevice;
extern APTR PATCH_NewMakeLibrary;

extern APTR PATCH_NewOpenFont;
extern APTR PATCH_NewCloseFont;
extern APTR PATCH_NewOpenDiskFont;

extern APTR PATCH_NewOpen;
extern APTR PATCH_NewClose;
extern APTR PATCH_NewLock;
extern APTR PATCH_NewUnLock;
extern APTR PATCH_NewOpenFromLock;

/***************************************************************************/
/* st_libs.c */
/***************************************************************************/

struct GetLibs
{
  UBYTE           *gl_Name;
  LONG             gl_Version;
  struct Library **gl_LibBasePtr;
  ULONG            gl_Mode;       /* GL_#? */
};

#define GL_OPTIONAL 1
#define GL_ABSOLUTE 2

extern struct Library *IntuitionBase;
extern struct Library *UtilityBase;
extern struct Library *WorkbenchBase;
extern struct Library *DiskFontBase;
extern struct Library *GfxBase;

/* Pull these in from the startup code */

extern struct ExecBase *SysBase;
extern struct DosLibrary *DOSBase;

#endif /* SYSTRACKER_INCLUDE_H */


