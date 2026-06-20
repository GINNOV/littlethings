
#ifndef FILEIO_H
#define FILEIO_H

/* *** fileio.h *************************************************************
 *
 * Amiga Programmers' Suite  --  File IO Include File
 *     from Book 1 of the Amiga Programmers' Suite by RJ Mical
 *
 * Copyright (C) 1986, =Robert J. Mical=
 * All Rights Reserved.
 *
 * Created for Amiga developers.
 * Any or all of this code can be used in any program as long as this
 * entire notice is retained, ok?  Thanks.
 *
 * The Amiga Programmer's Suite Book 1 is copyrighted but freely distributable.
 * All copyright notices and all file headers must be retained intact.
 * The Amiga Programmer's Suite Book 1 may be compiled and assembled, and the 
 * resultant object code may be included in any software product.  However, no 
 * portion of the source listings or documentation of the Amiga Programmer's 
 * Suite Book 1 may be distributed or sold for profit or in a for-profit 
 * product without the written authorization of the author, RJ Mical.
 * 
 * HISTORY      NAME            DESCRIPTION
 * -----------  --------------  --------------------------------------------
 * 20 Oct 87    - RJ            Added RENAME_RAMDISK to fix what seems to 
 *                              be a bug in AmigaDOS.
 * 27 Sep 87    RJ              Removed reference to alerts.h, brought 
 *                              declarations into this file
 * 12 Aug 86    RJ              Prepare (clean house) for release
 * 14 Feb 86    =RJ Mical=      Created this file.
 * 26 Sept 87   Jeff Glatt      Converted C code to optimized assembly and
 *                              created a library.
 * *********************************************************************** */


#define MAX_NAME_LENGTH 30
#define MAX_DRAWER_LENGTH 132
#define SetFlag(v,f)      ((v)|=(f))
#define ClearFlag(v,f)    ((v)&=~(f))
#define ToggleFlag(v,f)   ((v)^=(f))
#define FlagIsSet(v,f)    ((BOOL)(((v)&(f))!=0))

struct HandlerBlock {
   APTR  StartUpCode;
   APTR  DiskInsertedCode;
   APTR  GadgetCode;
   APTR  KeyCode;
   APTR  MouseMoveCode;
   };

/* === FileIO Structure ========================================== */

struct FileIO {
   USHORT Flags;
   /* After a successful call to DoFileIO(), these fields will have
    * the names selected by the user.  You should never have to initialize
    * these fields, only read from them, though initializing them won't hurt.
    */
   UBYTE FileName[MAX_NAME_LENGTH];
   UBYTE Drawer[MAX_DRAWER_LENGTH];
   UBYTE Disk[MAX_NAME_LENGTH];

   /* If a Lock on a disk/dir was obtained, it can be found here. */
   struct DOSLock *Lock;

   USHORT NameCount;
   USHORT NameStart;
   SHORT  CurrPick;
   struct Remember *FileList;

   USHORT VolIndex;
   USHORT VolCount;
   struct Remember *VolList;

   SHORT MatchType;  /* DiskObject Type */
   UBYTE *ToolTypes;

   UBYTE *Extension;
   USHORT ExtSize; /* Don't count the terminating NULL */

   struct HandlerBlock *Custom;

   USHORT X;
   USHORT Y;

   ULONG  FreeBytes;
   ULONG  FileSize;

   UBYTE  *Title;
   UBYTE  *Buffer;

   APTR   RawCode;
   struct DOSLock  *OriginalLock;
   BYTE   Errno;
   UBYTE  DrawMode;
   UBYTE  PenA;
   UBYTE  PenB;
   };

/* === User FileIO Flag Definitions === */
#define NO_CARE_REDRAW     0x0001  /* Clear if reconstructing display */
#define USE_DEVICE_NAMES   0x0002  /* Set for device instead of volume names */
#define EXTENSION_MATCH    0x0004  /* Only display those that end with
                                      a specified string */
#define DOUBLECLICK_OFF    0x0008  /* Inhibit double-clicking if set */
#define WBENCH_MATCH       0x0010  /* If set check .info files only */
#define MATCH_OBJECTTYPE   0x0020  /* If set with .info also check ObjectType */
#define MATCH_TOOLTYPE     0x0040  /* If set with .info also check ToolType */
#define INFO_SUPPRESS      0x0080  /* No info files listed */
#define CUSTOM_HANDLERS    0x0200  /* Implement custom handlers */

/* === System FileIO Flag Definitions === */
#define ALLOCATED_FILEIO   0x0100  /* Not a pre-initialized FileIO struct */
#define WINDOW_OPENED      0x0400  /* DoFileIOWindow() was called */
#define TITLE_CHANGED      0x0800  /* SetTitle() called without ResetTitle()
                                   */
#define DISK_HAS_CHANGED   0x2000  /* Disk changed during DoFileIO() */

/*  FileRequester GadgetIDs - Do not use these IDs for your own gadgets */
#define FILEIO_CANCEL      0x7FA0
#define FILEIO_OK          0x7FA1
#define FILEIO_NAMETEXT    0x7FA2
#define FILEIO_DRAWERTEXT  0x7FA3
#define FILEIO_DISKTEXT    0x7FA4
#define FILEIO_SELECTNAME  0x7FA5
#define FILEIO_UPGADGET    0x7FA6
#define FILEIO_DOWNGADGET  0x7FA7
#define FILEIO_PROPGADGET  0x7FA8
#define FILEIO_NEXTDISK    0x7FA9
#define FILEIO_BACKDROP    0x7FAA

#define NAME_ENTRY_COUNT   7   /* These many names in the SelectName box */

#define REQTITLE_HEIGHT    8

#define REQ_LEFT          8
#define REQ_TOP           15
#define REQ_WIDTH         286
#define REQ_HEIGHT        (110 + REQTITLE_HEIGHT)
#define REQ_LINEHEIGHT    8

#define SELECTNAMES_LEFT    8
#define SELECTNAMES_TOP     (15 + REQTITLE_HEIGHT)
#define SELECTNAMES_WIDTH   122
#define SELECTNAMES_HEIGHT  60


 /* ======= ERRNO numbers returned in FileIO error field ========= */

#define ERR_MANUAL  1   /* the path was entered manually via the title bar
                           with no errors or cancellation. */
#define ERR_SUCCESS 0   /* everything went OK */
#define ERR_CANCEL  -1  /* the filename procedure was CANCELED by the user */
#define ERR_WINDOW  -2  /* the window couldn't open (in DoFileIOWindow()) */
#define ERR_APPGADG -3  /* the requester was CANCELED by an application gadget
                           (via an installed CUSTOM gadget handler returning TRUE) */

/* === AutoFileMessage() Numbers ================================= */
#define ALERT_OUTOFMEM            0
#define ALERT_BAD_DIRECTORY       1
#define READ_WRITE_ERROR          2 /* Error in reading or writing file */
 /* The next 3 display "YES" and "NO" prompts,
    returning d0=1 for yes, 0 for no */
#define FILE_EXISTS               3 /* File already exists. Overwrite? */
#define SAVE_CHANGES              4 /* Changes have been made. Save them? */
#define REALLY_QUIT               5 /* Do you really want to quit? */

/* === Requester Library Function Declarations ===================== */

extern struct FileIO *GetFileIO();
extern UBYTE  *DoFileIO();
extern UBYTE  *DoFileIOWindow();  /* address = DoFileIOWindow(myFileIO, myScreen);
                                  If myScreen is NULL, then use WB screen */
extern BOOL   AutoFileMessage(); /* result = AutoFileMessage(3L, myWindow); */
extern BOOL   AutoMessage(), AutoMessageLen(), AutoPrompt3();
extern void   ReleaseFileIO();
extern void   SetWaitPointer();  /* SetWaitPointer( myWindow ); */
extern void   ResetBuffer();     /* ResetBuffer( StringInfo, nullFlag ); resets the
                             cursor back to the first char in the stringinfo's
                             buffer. If nullFlag is TRUE, then NULLS the buffer
                             as well. */
extern UBYTE  *ParseString();
extern UBYTE  *TypeFileName();
extern UBYTE  *PromptUserEntry(), *UserEntry();
extern void   SetTitle(), ResetTitle();
extern UWORD  GetRawkey(), DecodeRawkey();

#endif /* of FILEIO_H */
