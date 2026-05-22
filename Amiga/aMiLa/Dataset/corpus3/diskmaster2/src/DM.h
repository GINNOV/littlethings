/* DiskMaster II global definition Module
**
** 2.5.29
**
** 04-03-31 rri - Added proto for FilterStar() in DMSupport.c
**              - Modifed the proto for DMMatch().
**
** 04-10-31 rri - Modified the proto for LibOpen().
**
** 2.5.31
**
** 05-03-19 rri - Introduced 64 bit entity for DiskFree in struct Basecon for OS4 version.
**              - Removed "DiskFree" from struct DirWindow as it was not really in use anymore for some time.
**              - Changed two "#ifdef __PPC__" into the more apropriate "#ifdef __amigaos4__".
**
** 05-03-27 rri - Added CMD_clip().
**
** 2.5.32
**
** 05-06-11 rri - Added DMFLAG_DEBUG.
**
** 05-06-12 rri - Added documentation about the meanings of dirlist->dir
**
** 2.6
**
** 05-06-14 jjt - Added Reaction defines & include.
**
** 05-07-17 rri - Changed all references to "2.5.33" into "2.6".
**              - Removed comments from header older than 2.5.29.
**
** 05-07-19 jjt - StringHistory.strcache is now STRHIST_MAX + 1, so the array can be
**                null-terminated and work properly with Chooser gadgets.
**              - Removed StringHistory.lencache array.
**
** 05-07-31 rri - Made including of <clib/...> files dependant on non-OS4 compiling since these files
**                are not used by the OS4 SDK anymore.
**
** 05-08-10 rri - DMDelete() for DMDisk.c
**
** 05-08-19 rri - Modifed the prototype of DOSStart() to accept a pointer for the argument-string.
**              - Added DMFLAG_LONGCMD.
**              - Added DMFLAG_TIMEPLUS.
**
** 05-08-20 jjt - Added DMPreferences.c section, and DMPrefReq()'s prototype.
**
** 05-08-24 jjt - Added DMSetFormat()'s prototype to DMParser.c (DMPrefsReq() calls it).
**
** 05-08-27 rri - Added includes for Layers.library
**
** 05-08-31 jjt - Changed SaveConfig() prototype to return a BOOL (was void).
**
** 05-09-03 rri - Re-enabled the include for clib/alib_protos.h, necessary
**                for TimedDelay() in DMWindows.c
**
** 05-09-06 jjt - Added RemeberDMClose() and RememberDMOpen() prototypes to DMConfig.c.
**
** 05-09-10 rri - Added "struct Rectangle rectangle;" to struct DirWindow to avoid doing some
**                calculations over and over again.
**
** 05-10-05 jjt - Added "DMPPAGE_..." definitions.
**
** 05-11-07 jjt - Changed View()'s prototype (added node and line) in DMDisk.c.
**              - Added ViewAsync() prototype to DMDisk.c.
**              - Added RECURSE_SHOWA constant.
**
** 05-11-08 jjt - Added DMREQ_HELPNODE tag.
**
** 05-11-22 jjt - Added DMREQ_NOHELPBTN tag.
**
** 05-11-30 jjt - Added prototypes for makeCALabels() and freeCALabels() to DMPreferences.c.
**
** 2.7
**
** 05-12-15 jjt - Added DMPPAGE_KEYS definition.
**              - Added FreeKeyCmds() prototype to DMKey.c.
**
** 05-12-17 jjt - Removed DMKey.c's FreeKeyCmds().
**              - Added FreeStringArray() prototype to DMSupport.c.
**
** 05-12-23 jjt - FreeStringArray() - Changed prototype from "STRPTR" to "UBYTE *"
**
** 06-01-03 jjt - Renamed DMPPAGE_KEYS to DMPPAGE_CMDS.
**
** 06-01-05 rri - Added an enum for Reaction IDs in struct DirWindow.
**              - Added dwgadmain and dwgad[] to struct DirWindow,
**                these are to replace the old gadgets.
**
** 06-01-07 rri - Added * dwgadlist and * dwgadcollumn to struct DirWindow,
**                re-arranged the data in struct DirWindow slightly.
**              - Renamed GID_Space to GID_List and removed GID_HScroller.
**
** 06-01-14 rri - Changed dwgadlist from pointer to plain struct,
**                there is no need to allocated new structures all the time,
**                it only needs to get emptied and then re-initialised with NewList().
**              - New struct DirInfo - to keep track how many entries the
**                struct ColumnInfo for the dirwindows have and what they look like.
**
** 06-08-27 rri - Added an array of "struct Hook" to struct DirWindow to have each
**                column in every window use it's own struct.
**
** 06-08-28 rri - The "struct Hook" array is now of size COLLUMNS_MAX.
**
** 06-11-09 rri - Added a struct Node *node to struct DirList which avoids traversing the whole
**                list in order to find the matching listbrowser-node-pointer.
**
** 06-11-29 rri - Added update_entry(), append_entry() and remove_entry() for DMWindows.c,
**                commented-out a few obsolete functions
**
** b2
**
** 06-12-10 rri - Removed some obsolete entries from DMWindows.c
**              - Enhanced struct DirInfo with "int8 sorting[COLLUMNS_MAX];" to store the info
**                by which method the list is to be resorted when clicking on the collumn-header.
**              - Removed some obsolete entries from struct DirWindow.
**
** b3
**
** 06-12-14 rri - Made defines for the fonts an enum to be able to easier add new entries.
**              - Added DMFONTS_CMDWIN for the command-window "buttons".
**
** b4
**
** 06-12-17 rri - Made DirList->size 64 bit wide for the OS4 build.
**              - Removed GID_VScroller and added GID_HScroller as reserve.
**              - Removed obsolete GetNewPath() from DMWinContent.c
**
** b7
**
** 06-12-26 rri - Added DMFONTS_READER, removed DMFONTS_TMPFIXED, DMFONTS_TMPPROP
**                and DMFONTS_TOPAZ.
**              - Added GID_Window for window.class based lister-windows.
**
** 06-12-28 rri - Added "Object * dwwindow" to "struct DirWindow", removed a few obsolete vars.
**
** 06-12-30 rri - Removed dir_gad, dir_str and SExt from DirWindow to see what still depends on it...
**
** b8
**
** 07-01-04 rri - Made "BlocksFree" of "struct BaseConvert" a int64, setuplbtags() is using it.
**
** 07-01-05 rri - Removed the obsolete DoFileFormat()/DMWinContent.c from the OS4-build.
**              - Added examindedata2dlp()/DMWinContent.c to the OS4-build.
**              - Disabled the proto for the not used remove_entry()/DMWindows.c.
**
** 07-01-06 rri - Added global-flag DMFLAG_READONLY which indicates when the dir-listers are to be blocked.
**              - Commented-out DMFLAG_DCLICK and DMFLAG_EXALL for not beeing used.
**
** b9
**
** 07-01-21 rri - Fixed typo, examindedata2dlp() -> examinedata2dlp()...
**
** b10
**
** 07-02-04 rri - Added include for input.device needed to call PeekQualifier().
**
*/

#include <amiga_compiler.h>

#define INTUI_V36_NAMES_ONLY 1

#define __USE_SYSBASE /* 2.5b10 rri */

#include <string.h>
#include <stdlib.h> /* qsort...*/

#include <exec/types.h> /* 2.5RC9 rri */

#include <devices/inputevent.h>  /* 2.5b5 jjt */
#include <devices/timer.h> /* 2.5RC4 rri */
#include <dos/dostags.h>
#include <dos/rdargs.h> /* 2.5.23 rri */
#include <intuition/gadgetclass.h> /* 2.5b5 jjt */
#include <intuition/icclass.h>     /* 2.5b5 jjt */
#include <intuition/imageclass.h>  /* 2.5b5 jjt */
#include <Intuition/sghooks.h>
#include <exec/execbase.h> /* 2.5b10 rri */ /* vbcc! */
#include <utility/utility.h> /* 2.5.23 gcc rri */

#include <clib/alib_protos.h> /* 2.6 rri */

#ifdef __amigaos4__ /* 2.5.31 rri */
#include <stdio.h>
#endif

#ifndef __amigaos4__ /*2.6 rri */
#include <clib/alib_stdio_protos.h> /* 2.5RC9 rri */
#include <clib/debug_protos.h> /* 2.5RC6 rri */ /* kprintf("!\n"); */
#endif

#include <proto/amigaguide.h>
#include <proto/asl.h>
#include <proto/bullet.h> /* 2.5.23 gcc rri */
#include <proto/diskfont.h>
#include <proto/dos.h>
#include <proto/exec.h>
#include <proto/gadtools.h>
#include <proto/graphics.h>
#include <proto/layers.h> /* 2.6 rri */
#include <graphics/gfxmacros.h>  /* 2.5b5 jjt */
#include <proto/icon.h>
#include <proto/iffparse.h> /* 2.5b7 jjt (24.06.00) */
#include <proto/intuition.h>
#include <proto/rexxsyslib.h>
#include <proto/timer.h>
#include <proto/utility.h>  /* 2.5b5 jjt */
#include <proto/wb.h>
#include <proto/input.h> /* 2.7b10 rri */
#include <proto/xfdmaster.h> /* 2.5b6 jjt */
#include <proto/xpkmaster.h> /* 2.5b6 jjt */

#include "DMLocale.h" /* 2.5b13 rri */

#define  ALL_REACTION_CLASSES
#define  ALL_REACTION_MACROS
#include <reaction/reaction.h>

#define max(a,b) ((a) >  (b) ? (a) : (b)) /* 2.5RC9 rri */
#define min(a,b) ((a) <= (b) ? (a) : (b)) /* 2.5RC9 rri */

#define sFIB struct FileInfoBlock

#define ACTION(rmp) (rmp->rm_Action)
#define RESULT1(rmp) (rmp->rm_Result1)
#define RESULT2(rmp) (rmp->rm_Result2)

#define DWFLAG_RESORT 1
#define DWFLAG_ADD 2
#define DW_CMD (1<<2)
#define DWFLAG_RELOAD (1<<3)
#define DW_SOURCE (1<<4)
#define DW_DEST (1<<5)

#define RECURSE_DEL   1
#define RECURSE_COPY  2
#define RECURSE_MOVE  3
#define RECURSE_PROT  (1<<2)
#define RECURSE_REN   (1<<3)
#define RECURSE_EXEC  (1<<4)
#define RECURSE_FIND  (1<<5)
#define RECURSE_NOTE  (1<<6)
#define RECURSE_SHOW  (1<<7)
#define RECURSE_READ  (1<<8)
#define RECURSE_AUTO  (1<<9)
#define RECURSE_REXX  (1<<10)
#define RECURSE_DATE  (1<<11)
/* 2.5b5 rri
#define RECURSE_PRINT (1<<12)
*/
#define RECURSE_CHECK (1<<13)
#define RECURSE_PACK  (1<<14)
/* 2.6 jjt */
#define RECURSE_SHOWA  (1<<15)

/* --- Global BOOL flags --- */ /* 2.5RC2 rri */

#define DMFLAG_ABORT      1
#define DMFLAG_AUTOFILING (1<<1)
#define DMFLAG_ATTR       (1<<2)
#define DMFLAG_BATCH      (1<<3)
#define DMFLAG_CHGCMD     (1<<4) /* change command */
#define DMFLAG_CONFIRM    (1<<5)
//#define DMFLAG_DCLICK     (1<<6) /* double-click */
#define DMFLAG_EXPAND     (1<<7)
//#define DMFLAG_EXALL      (1<<8) /* use ExAll() or not */
#define DMFLAG_FORCE      (1<<9)
#define DMFLAG_KEEPGLOBAL (1<<10) /* don't free global buffer */
#define DMFLAG_KEEPGOING  (1<<11)
#define DMFLAG_KEEPSEL    (1<<12) /* keep selected */
#define DMFLAG_LOOP       (1<<13)
#define DMFLAG_NOTIFY     (1<<14)
#define DMFLAG_PATREQ     (1<<15) /* pattern requester */
#define DMFLAG_QUIET      (1<<16)
#define DMFLAG_REC        (1<<17) /* recurse */
#define DMFLAG_RESET      (1<<18)
#define DMFLAG_RESORT     (1<<19)
#define DMFLAG_SKIP       (1<<20)
#define DMFLAG_SINGLE     (1<<21)
#define DMFLAG_TESTWARN   (1<<22)
#define DMFLAG_UNMARK     (1<<23)
#define DMFLAG_USE30      (1<<24)
#define DMFLAG_WINTITLE   (1<<25)
#define DMFLAG_DEBUG      (1<<26) /* 2.5.32 rri */
#define DMFLAG_LONGCMD    (1<<27) /* 2.6 rri */ /* if set, 'Archive' will use more than 511 chars for the command-line */
#define DMFLAG_TIMEPLUS   (1<<28) /* 2.6 rri */ /* if set, timestamps on files are displayed with seconds */
#define DMFLAG_READONLY   (1<<29) /* 2.7b8 rri */

/* --- ActionArg Types, passed to GetActionArg() --- */
#define AATYPE_BOOL        1   /* 2.5b5 jjt */
#define AATYPE_STR         2   /* 2.5b5 jjt */
#define AATYPE_NUM         3   /* 2.5b5 jjt */
#define AATYPE_NEXTSTR     4   /* 2.5b6 jjt */
#define AATYPE_TRUENEXTSTR 5   /* 2.5RC3 jjt */

#define STRHIST_MAX 15   /* 2.5b10 jjt */

/* --- Requester Tags (StrReq() & EasyReq()) ---  2.5b10 jjt */
/* (Explained in DMReqTagList() in DMRequester.c )           */
#define DMREQ_TITLE      0x90000001
#define DMREQ_BUTTONS    0x90000002
#define DMREQ_ABORT      0x90000003
#define DMREQ_SCREEN     0x90000004
#define DMREQ_HISTORY    0x90000005
#define DMREQ_MINW       0x90000006  /* 2.5RC2 jjt */
#define DMREQ_DEFBTN     0x90000007  /* 2.5RC2 jjt */
#define DMREQ_PROTREQ    0x90000008  /* 2.5RC9 jjt */
#define DMREQ_FILEREQ    0x90000009  /* 2.5.26 jjt */
#define DMREQ_HELPNODE   0x9000000A  /* 2.6 jjt */
#define DMREQ_NOHELPBTN  0x9000000B  /* 2.6 jjt */

/* --- Flags to filter Device List's Display --- */  /* 2.5b12 jjt */
#define SHOWDEV_DEV  1
#define SHOWDEV_VOL  2
#define SHOWDEV_ASN  4
#define SHOWDEV_ALL  7

#define DEVHIDELIST_MAX 100  /* 2.5b12 jjt */

/* 2.5RC2 jjt */
/* - DMFONTS_MAIN up to, but not including, DMFONTS_SCREEN will be saved with the
     Font cmd. by SaveConfig.
   - Anything less than DMFONTS_TOPAZ should also have an entry in the FontKeywords
     array in DMCommands.c.
*/

enum /* 2.7 rri */
{
 DMFONTS_MAIN = 0,
 DMFONTS_DIRGAD,
 DMFONTS_REQTXT,
 DMFONTS_REQBTN,
 DMFONTS_MENU,
 DMFONTS_CMDWIN,
 DMFONTS_READER,
 DMFONTS_SCREEN,
// DMFONTS_TMPFIXED,
// DMFONTS_TMPPROP,
// DMFONTS_TOPAZ,
 DMFONTS_COUNT
};

/*
#define DMFONTS_MAIN     0
#define DMFONTS_DIRGAD   1
#define DMFONTS_REQTXT   2
#define DMFONTS_REQBTN   3
#define DMFONTS_MENU     4
#define DMFONTS_SCREEN   5
#define DMFONTS_TMPFIXED 6
#define DMFONTS_TMPPROP  7
#define DMFONTS_TOPAZ    8
#define DMFONTS_COUNT    9
*/

/* Macro:  Get TextFont name */ /* 2.5RC2 jjt */
#define GetTFName(tf) tf->tf_Message.mn_Node.ln_Name

/* 2.5.23 rri */
/* maximum amount of dir/cmd-windows */
#define DMMAXWINDOWS 255

/* 2.6 jjt */
#define DMPPAGE_MAIN     0
#define DMPPAGE_WINDOWS  1
#define DMPPAGE_FONTS    2
#define DMPPAGE_COLORS   3
#define DMPPAGE_CMDS     4 /* 2.7 jjt */
#define DMPPAGE_TOTAL    5

#define COLLUMNS_MAX 20 /* 2.7 rri */

enum /* 2.7 rri */
{
 GID_Window = 0,
 GID_String,
 GID_List,
 GID_BParent,
 GID_HScroller,
 GID_LAST
};

struct BaseConvert
 {
 #ifdef __amigaos4__ /* 2.5.31 rri */
  int64 DiskFree;
  int64 BlocksFree; /* 2.7b8 rri */
 #else
  int32 DiskFree;
  int32 BlocksFree;
 #endif
  int32 BytesPerBlock;
  char String[20]; /* 2.7b8 rri */
 };

struct DirList /* 2.5b10 rri */
 {
  struct DateStamp ds;
  #ifdef __amigaos4__ /* 2.7 rri */
  int64 size;
  uint32 attr;
  #else
  int32 size;
  int32 attr;
  #endif

  int32 dir,
        sel;   /* this only is a marker if the entry still is valid */
  UBYTE *name, /* 2.5b10 rri */
        *cmt;
  struct Node *node; /* 2.7 rri */
};

/* values of dir:          2.5.32 rri

 0 = entry is file
 1 = directory
 2 = entry in dev/vol/asn list
 3 = entry in command-window
 4 = entry set thru doSetList() -> I wonder if this works at all...

*/


struct DirWindow /* 2.5b10 rri */
 {
  struct DateStamp PathDate;
  struct DirList **DirList;
  struct FileInfoBlock *Fib; /* fib_Date */
  struct NotifyRequest DM2NotifyReq; /* ULONG nr_UserData = notified flag ! */
  struct Window *Window; /* BYTE *UserData; */

  /* Reaction data */ /* 2.7 rri */
  Object            * dwwindow;  // pointer to window.class object
  struct Gadget     * dwgadmain, // most likely obsolete with use of window.class
                    * dwgad[GID_LAST];
  struct List       dwgadlist;
  struct ColumnInfo * dwgadcollumn;
  #ifndef __amigaos4__ // only for use with pre OS4
  struct Hook columnhook[COLLUMNS_MAX];
  #endif
  /* Reaction data */

  /* to be removed soon... */
//  struct Gadget dir_gad;     /* APTR UserData  dir_gad.UserData=PathHistory */
//                v_gad,h_gad,
//                up,dn,lf,rt,
//                parent;
//  struct Image v_img,h_img;
//  struct PropInfo v_prop,h_prop;
//  struct StringInfo dir_str;
//  struct StringExtend SExt;
//  struct Rectangle  rectangle; /* 2.6 - inner drawing area of a window, kept updated by NewSize() */
  /* to be removed soon... */

  LONG   BlocksFree,
         BytesPerBlock,

/* obsolete with Reaction windows */
         Collums, /* 2.5RC7 rri */
         ColsName,
//         Index,
//         Rows,
         ColsCmt, /* &0xFFF=cols comments- >>12=cols file-sizes - 2.5RC7 rri */
/*         DiskFree, 2.5.31 rri */
//         Edge,
/* obsolete with Reaction windows */

         FileCount,
         Flags,
         MaxFile,
         Number, /* 2.5RC10 */
         Sels,
         Sorting;
  UBYTE  *Path,*Title,Pattern[32]; /* 2.5RC6 rri */
  BPTR   DirLock;
  WORD   zoom[4]; /* 2.5b13 rri */
  WORD   norm[4]; /* 2.5b13 rri */
 };


struct XFile {  /* 2.5b6 jjt */
  /* Returned by AutoUnpack.  Use FreeXFile() to dispose. */
  UBYTE                *data;      /* Data buffer */
  ULONG                 len;       /* Amount of data in buffer */
  ULONG                 buflen;    /* Total size of buffer */
  struct xfdBufferInfo *xinfo;     /* May be NULL if XFD lib doesn't exist */
  LONG                  dataisbin; /* TRUE if there's a 0 in the 1st 512 bytes of .data */ /* 2.5b7 jjt (7.7.00) */
};


struct StringHistory {  /* 2.5b10 jjt */
/*   struct SignalSemaphore sema4; */
  APTR                   mempool;
  UBYTE                  *strcache[STRHIST_MAX + 1]; /* 2.6 jjt */
/*   UWORD                  lencache[STRHIST_MAX]; */
  ULONG                  total;
  ULONG                  cachepos;
};


struct DirInfo /* 2.7 rri */
 {
  int32 num;
  STRPTR titles[COLLUMNS_MAX];
  int8 sorting[COLLUMNS_MAX];
 };


/* DM.c */

#ifdef __amigaos4__ /* 2.5.31 rri */
BOOL LibOpen(STRPTR name, struct Library **base, ULONG ver, uint32 iface); /* 2.5.31 rri */
#else
BOOL LibOpen(STRPTR name, struct Library **base, ULONG ver); /* 2.5b6 jjt */
#endif
void MainLoop(void); /* 2.5b9 rri */


/* DMCommands.c */

void AddAutoCmd(UBYTE *str);
void DMArchive(UBYTE *cmd,UBYTE *name);
void DMSelect(int sel);
void AddCmd(struct DirWindow *dw,UBYTE *buf);
void DoStdio(UBYTE *str);
void GetParent(UBYTE *path,int parent); /* 2.5b6 rri */
void DMReqPat(void);
void DoSwap(void);
int  UnLockAll(void);
void ResetFlags(void);
void GetCmdFile(struct DirWindow *dw,UBYTE *name,LONG size); /* 2.5b10 rri */
void AutoFiler(struct DirWindow *dw,UBYTE *name);
void EditCmd(struct DirWindow *dw,int ni);
void ParseCmd1(struct DirList *dlp,UBYTE *buf);
void DMSet(void); /* 2.5b7 rri */
void CMD_DevList(void);  /* 2.5b12 jjt */
void CMD_Font(void);     /* 2.5RC2 jjt */
void CMD_HideDev(void);  /* 2.5b12 jjt */
void CMD_clip(void); /* 2.5.31 rri */
/* new! 2.2b14
void MultiSelect(int i);
void SingleName(int i);
*/


/* DMConfig.c */

BOOL SaveConfig(void);
void Iconify(void); /* 2.5b7 rri */
BOOL RememberDMClose(void); /* 2.6 jjt */
void RememberDMOpen(void);  /* 2.6 jjt */


/* DMDisk.c */

int  DMRelabel(UBYTE *dev,UBYTE *name,UBYTE *new);
void DMRename(UBYTE *old);
void SmartRename(UBYTE *old,UBYTE *new);
void DMComment(UBYTE *name,UBYTE *str,sFIB *fib);
void DMProtect(UBYTE *name,UBYTE *str,sFIB *fib);
void DMSetFileDate(UBYTE *dir,sFIB *fib);
void SmartRemEntry(UBYTE *name);
void SmartAddEntry(UBYTE *name);
ULONG DMCopy(UBYTE *s,UBYTE *dest,sFIB *fib, int opt); /* 2.5b13 rri */
void DMMakeDir(UBYTE *name);
void MakeIcon(UBYTE *name);
void Dupe(void);
void SwapSelect(void);
ULONG DMOpenFont(ULONG idx, STRPTR name, ULONG size); /* 2.5RC2 jjt */
void View(UBYTE *file, STRPTR node);  /* 2.6 jjt */
void InfoReq(UBYTE *file);
void DOSExecute(void);
void DOSStart(int StackSize, UBYTE *argstring);
void CheckSpace(void);
void PrintDir(void); /* 2.5b9 rri */
void DMSetDate(void);
int32 DMDelete(void); /* 2.6 rri */
void ViewAsync(STRPTR file, STRPTR node);  /* 2.6 jjt */


/* DMKey.c  - 2.4b18 */

void AddKeyCmd(UBYTE *str);
void DoKeyCmd(struct DirWindow *dw,UWORD code,UWORD qual,ULONG class);
ULONG CheckAbortKey(void); /* 2.5RC2 rri */


/* DMMenus.c */

VOID menu_on(VOID);  /* 2.5b10 rri */
VOID menu_off(VOID); /* 2.5RC2 jjt */
LONG DMLayoutMenus(VOID); /* 2.5RC10 rri */
VOID AddMenuCmd(UBYTE *);
VOID MyFreeMenus(VOID);


/* DMPack.c */

void           DMPack(UBYTE *name, sFIB *fib, int comp);  /* 2.5b6 jjt */
struct XFile * AutoUnpack(UBYTE *name);      /* 2.5b6 jjt */
struct XFile * NewXFile(void);               /* 2.5b7 jjt */
void           FreeXFile(struct XFile *xf);  /* 2.5b6 jjt */


/* DMPalette.c */

void SetColors(void);
void SetPens(void);
void AllocPens(void); /* 2.5b12 rri */


/* DMParser.c */

void DMSetFormat(UBYTE *str,UBYTE *fbuf,ULONG length);  /* 2.6 jjt */
void RefreshCmdWin(struct DirWindow *dw);
void StartRec(int type);
int  DMRecurse(int lenS,int lenD,int opt);
int  addname(UBYTE *path,UBYTE *name,int len);
void SplitLine(UBYTE *buf,struct DirWindow *dw); /* 2.5RC10 rri */
void ActionCmd(ULONG num,UBYTE *buf); /* 2.5RC10 rri */


/* DMPreferences.c */
void DMPrefReq(LONG page);  /* 2.6 jjt */
void makeCALabels(struct List *list, STRPTR *labels, BOOL isclicktab); /* 2.6 jjt */
void freeCALabels(struct List *list, BOOL isclicktab); /* 2.6 jjt */


/* DMRead.c */

void   DMRead(UBYTE *file);  /* 2.5b5 jjt */
void   CloseRead(void);


/* DMRequester.c */

void Busy(int i); /* 2.5b7 rri */
void CMD_Choose(void);  /* 2.5b7 jjt (3.7.00) */
LONG REQ_FileExists(sFIB *srcfib, sFIB *destfib);  /* 2.5b13 jjt */
void About(void);
/* LONG DMReq(CONST_STRPTR body, STRPTR dest, ULONG cmax, ULONG tags, ...); 2.5.26 rri */
LONG DMReqTagList(CONST_STRPTR body, STRPTR dest, ULONG cmax, struct TagItem *tags);  /* 2.5b10 jjt */
void MakeBtnString(const UBYTE yes[], const UBYTE middle[], const UBYTE no[]); /* 2.5b13 rri */
void StrHist_Init(struct StringHistory *sh);   /* 2.5b10 jjt */
/*void StrHist_Clear(struct StringHistory *sh);*/  /* 2.5b10 jjt */
void StrHist_Add(struct StringHistory *sh, STRPTR str);  /* 2.5b10 jjt */
ULONG SAVEDS ASM StringHook(REG(a0,struct Hook *hk),REG(a2,struct SGWork *swork),REG(a1, ULONG *msg)); /* test! */
/* ULONG SAVEDS StringHook(struct Hook *hk,struct SGWork *swork,ULONG *msg);*/  /* 2.5.23 rri */
STRPTR DMFileReq(STRPTR file, STRPTR path, BOOL save); /* 2.5.27 rri */


/* DMRexx.c  - 2.2b15 */

void outputRexxVar(UBYTE *cont); /* 2.5b13 rri */
int  do_rexx_cmd(struct RexxMsg *rm);
void SendRexx(void);
void doDirList(void);
void doSetList(UBYTE *var);
void RexxStatus(void);
void Filestat(void); /* 2.5b5 rri */
void WinInfo(void); /* 2.5b5 rri */
void RXCMD_GetHistory(void);  /* 2.5b11 jjt */


/* DMScreen.c - 2.2b13 */

int  CheckScreen(void);
void GetHostScreen(UBYTE *str);
void GetDRI(struct Screen *s);
void InitScreenDefaults(void);
void ParseScreenArgs(void); /* 2.5.23 rri - set to (void) */
struct Screen *NewOpenScreen(int n,UBYTE *);

/* 2.5b6 rri
struct Screen *ReadOpenScreen(int n,UBYTE *);
*/

struct Screen *DMOpenScreen(ULONG Width,ULONG Height,ULONG ID,UWORD Depth,UBYTE *name); /* 2,5b10 rri */


/* DMSort.c  - 2.2b15 */

void DMSortN(struct DirList **dl,ULONG count,LONG direction); /* 2.5b10 rri */
void DMSortS(struct DirList **dl,ULONG count,LONG direction); /* 2.5b10 rri */
void DMSortD(struct DirList **dl,ULONG count,LONG direction); /* 2.5b10 rri */
void DMSortC(struct DirList **dl,ULONG count,LONG direction); /* 2.5b10 rri */
int  cmpnameU(struct DirList **val1,struct DirList **val2); /* 25.08.97 dGN! */
int  cmpnameD(struct DirList **val1,struct DirList **val2);
int  cmpsizeU(struct DirList **val1,struct DirList **val2); /* 25.08.97 dGN! */
int  cmpsizeD(struct DirList **val1,struct DirList **val2); /* 25.08.97 dGN! */
int  cmpdateU(struct DirList **val1,struct DirList **val2); /* 25.08.97 dGN! */
int  cmpdateD(struct DirList **val1,struct DirList **val2);
int  cmpcmtU(struct DirList **val1,struct DirList **val2);
int  cmpcmtD(struct DirList **val1,struct DirList **val2);
void Sort(void);
void GlobalSort(void);
void SetSortFlag(struct DirWindow *dw, int c);
void DMSort(struct DirWindow *dw);
void ReSort(void);
void ResortAll(void);


/* DMSupport.c */

void StrToUpper(UBYTE *str); /* 2.5b7 rri */
LONG GetActionArg(STRPTR keyword, UBYTE type, LONG def); /* 2.5b5 jjt */
BOOL IsDir(STRPTR name); /* 2.5b6 jjt */
UBYTE *SkipWhite(UBYTE *ptr);
BOOL AArg2Str(STRPTR keyword, STRPTR dest, ULONG length, BOOL upper, STRPTR def); /* 2.5b6 jjt */ /* 2.5RC9 rri */
void display(const UBYTE format[],UBYTE *arg1); /* 2.5b13 rri */
void QuoteCat(UBYTE *ptr,UBYTE *name);
int  NeedQuote(UBYTE *ptr);
UBYTE * FilterStar(UBYTE *pattern); /* 2.5.29 rri */
ULONG DMMatch(UBYTE *string,UBYTE *pattern); /* 2.5.29 rri */
void RefreshWindows(void); /* 2.5b7 rri */
void StampProt(UBYTE *str,LONG prot);
int  GetGlobuff(void); /* 2.5b7 rri */
void FreeGlobuff(void);
void FindCmdWin(void); /* 2.5b7 rri */
int  DOSParse(UBYTE *str,const UBYTE *hail,int i);
APTR   PoolAllocVec(APTR mempool, ULONG size); /* 2.5b10 jjt */
void   PoolFreeVec(APTR memptr);               /* 2.5b10 jjt */
STRPTR CloneStr(CONST_STRPTR str, APTR mempool);     /* 2.5b10 jjt */
void CloneBuffer(struct DirWindow *dw,UBYTE *str); /* 2.5RC6 rri */
void FreeUserData(void); /* 2.5RC10 rri */
void SetTitles(void); /* 2.5b10 rri */
struct DirWindow *FindDMWin(struct Window *win); /* 2.5b10 rri */
int BootBatch(UBYTE *ptr); /* 2.5b10 rri */
ULONG Char2Nibble(ULONG c);  /* 2.5b11 jjt */
void RefreshDevLists(void);  /* 2.5b12 jjt */
int  FindPattern(UBYTE *str);
void Separate(struct DirWindow *dw);
void CheckMonth(void); /* 2.5b13 rri */
void FontToAttr(struct TextFont *font, struct TextAttr *attr);  /* 2.5RC2 jjt */
LONG CharPos(UBYTE c, STRPTR str);  /* 2.5RC9 jjt */
void DMstrcat(UBYTE *dest,const UBYTE *source); /* 2.5RC9 rri */
void DMstrncpy(UBYTE *dest, const UBYTE *source, ULONG size); /* 2.5RC10 rri */
void FreeStringArray(UBYTE *strarray[], uint32 arraylen);  /* 2.7 jjt */


/* DMWinContent.c */ /* 2.5b13 rri */

void ConvertBase(struct BaseConvert *basecon);
void ReSize(struct DirWindow *dw);
void MainTitle(void);
void WinTitle(struct DirWindow *dw);
#ifndef __amigaos4__
void DoFileFormat(struct DirList *dlp,struct DirWindow *dw); /* 2.5RC7 rri */
#endif
void GetDevList(struct DirWindow *dw);
void InitDir(struct DirWindow *dw,int set);
void GetDirEntry(struct DirWindow *dw);
void Fib2Dlp(struct DirList *dlp,sFIB *fib);
#ifdef __amigaos4
void examinedata2dlp(struct DirList *dlp,struct ExamineData *dat); /* 2.7b9 rri */
#endif
int  AllocDlp(struct DirWindow *dw);
//int  GetNewPath(struct DirWindow *dw);
int  DiskShadow(struct DirWindow *dw,sFIB *fib);
void FreeDirTable(struct DirWindow *dw);


/* DMWindows.c */

void DoWindow(void);
void attach_list(struct DirWindow *dw, uint32 autofit); /* 2.7b8 rri */
void detach_list(struct DirWindow *dw); /* 2.7b8 rri */
void update_entry(struct DirWindow *dw, struct DirList *dlp); /* 2.7 rri */
void append_entry(struct DirWindow *dw, struct DirList *dlp); /* 2.7 rri */
//void remove_entry(struct DirWindow *dw, struct DirList *dlp); /* 2.7b8 rri */
 void dis_name(struct DirWindow *dw,LONG file,LONG pos);
 void dis_files(struct DirWindow *dw);
void ShowDirection(struct DirWindow *dw,int n);
void NewSize(struct DirWindow *dw);
void FindNewDirection(struct DirWindow *dw);
void CloseDirWindow(ULONG num);
int  OpenDirWindow(UBYTE *path,int Left,int Top,int Wid,int Hi);
struct Window *OpenSharedWindow(struct NewWindow *nw);
void CloseSharedWindow(struct Window *w);
void RefreshGadget(struct Gadget *,struct Window *);
