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
    macros.h

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 02-Nov-93
    Modified: 03-Dec-95
    NO TABS
    _______________________________________________________________________
*/
#ifndef ABACKUP_MACROS_H
#define ABACKUP_MACROS_H

#define MIN(a,b)                ((a)<(b)?(a):(b))
#define MAX(a,b)                ((a)>(b)?(a):(b))

//_______________________________________________________________ binary macros:

#define AND(a,b)                ((a)&(b))
#define OR(a,b)                 ((a)|=(b))
#define XOR(a,b)                ((a)^=(b))
#define DEL(a,b)                OR(a,b);XOR(a,b)

//__________________________________________________________ MWin access macros:

#define WIN_TITLE		MWin[NewID].mw_Title

//______________________________________________ MWin's MinGadget access macros:

#define GD_LEFT(g)              MWin[NewID].mw_Gadgets[g].mg_LeftEdge
#define GD_TOP(g)               MWin[NewID].mw_Gadgets[g].mg_TopEdge
#define GD_WIDTH(g)             MWin[NewID].mw_Gadgets[g].mg_Width
#define GD_HEIGHT(g)            MWin[NewID].mw_Gadgets[g].mg_Height
#define GD_TYPE(g)              (ULONG)MWin[NewID].mw_Gadgets[g].mg_Type
#define GD_TEXT(g)              MWin[NewID].mw_Gadgets[g].mg_Text
#define GD_FLAGS(g)             MWin[NewID].mw_Gadgets[g].mg_Flags
#define GD_TAGS(g)              MWin[NewID].mw_Gadgets[g].mg_Tags

#define GD_COUNT(ID)            MWin[ID].mw_GadgetsCount

//___________________________________________________ MWin's BBox access macros:

#define BOX_LEFT(b)             MWin[NewID].mw_Boxes[b].bb_LeftEdge
#define BOX_TOP(b)              MWin[NewID].mw_Boxes[b].bb_TopEdge
#define BOX_WIDTH(b)            MWin[NewID].mw_Boxes[b].bb_Width
#define BOX_HEIGHT(b)           MWin[NewID].mw_Boxes[b].bb_Height
#define BOX_RECESSED(b)         MWin[NewID].mw_Boxes[b].bb_Recessed

#define BOX_COUNT(ID)           MWin[ID].mw_BoxesCount

//________________________________________________________ miscellaneous macros:

#define FLIP(n)                 ((n)=NOT(n))

#define MSG_VOID		~0

#define DISABLE 		TRUE
#define ENABLE			FALSE

#define SHCUT(k)                Shortcut(GetStr(k),code)
#define SHCUTFROMSTR(k)         Shortcut(k,code)

#define BUILDMENUNUM(menu,item) FULLMENUNUM(menu,item,NOSUB)

#define GFXV39PLUS		(GfxBase->LibNode.lib_Version >= 39)
#define GTLIBV39		(GadToolsBase->lib_Version == 39)
#define GTV39PLUS		(GadToolsBase->lib_Version >= 39)

#define LOCALEPATCHED		(LocaleBase && LocaleBase->lb_SysPatches)

//______________________________________________________________________________

/* $DOC Macros_General
 *    B2CPTR			converts a BPTR to a regular C pointer
 *
 *    FreeDirTree(p)            free a directory tree allocated by LoadDirTree()
 *    FreeDevList(p)            free a partition list allocated by LoadDevList()
 *    AddToCatalog(p,d,o)       set obj_Disk and obj_Offset fields of an Object struct
 *    ReportRDir(o,n)           add a report line about a directory (restore)
 *    ReportRLink(o,n)          add a report line about a link (restore)
 *    BeginOfDev(p)             compute base offset of a device
 *    CurrentCyl(p)             compute current cylinder, from current offset
 *    LeftOnCyl(p)              compute size left on current cylinder
 *    RoundToSector(s)          round a size up to a sector boundary
 *    MaxIoSize()               return maximal I/O size depending on archive format
 *    FreeCatalog()             free an archive catalog loaded by LoadCatalog()
 *    AddDeviceDef(o,d)         attach a DeviceDef struct to an Object struct
 *    UpdateHeader(h,t,s)       update CType and CSize fields of header
 *    SameDeviceDef(f,s)        TRUE if f and s describe the same device
 *
 *    BeforeV5(v)               TRUE if the given version "v" is anterior to v5.xx
 *    AfterV4(v)                TRUE if the given version "v" is posterior to v4.xx
 *    HasPathTable(v)           TRUE if the given version "v" supports "PathTable"
 *    OldArchiveFmt()           TRUE if archive is in the new format
 *
 *    FirstChild(p)             returns the first child of a directory
 *    NextChild(p)              returns the next object in the same directory
 *    FirstUnit(p)              returns the first unit in archive's unit list
 *    NextUnit(p)               returns the next unit after this one
 *    FirstCmd(p)               returns the first queued write command
 *    NextCmd(p)                returns the next queued write command
 * $END
 */

#define B2CPTR(p)               (VOID *)(((ULONG)p) << 2)

#define FreeDirTree(o)          WalkDirTree(o,FreeObject,(WDTF_RECURSIVE|WDTF_DIRAFTER))
#define FreeDevList(o)          FreeDirTree(o)
#define AddToCatalog(p,d,o)     { (p)->obj_Disk = (WORD)d ; (p)->obj_Offset = o ; }
#define ReportRDir(o,n)         ReportBDir(o,n)
#define ReportRLink(o,n)        ReportBLink(o,n)
#define BeginOfDev(u)           ((u)->au_DeviceDef->dd_Env.de_LowCyl * (u)->au_CylSize)
#define CurrentCyl(u)           (((u)->au_CurPos - BeginOfDev(u)) / (u)->au_CylSize)
#define LeftOnCyl(u)            ((u)->au_CylSize - ((u)->au_CurPos % (u)->au_CylSize))
#define RoundToSector(s)        (((s) & SIZEMASK) ? ((s) | SIZEMASK) + 1 : (s))
#define MaxIoSize()             (OldArchiveFmt() ? IOBUFSIZE : IOMAXDATA)
#define FreeCatalog(p)          (ProgramFlags & PF_CATALISTREE ? FreeDirTree(p) : MyFreeMem(p))
#define AddDeviceDef(o,d)       AddHead((struct List *)&((o)->obj_Children),(struct Node *)d)
#define UpdateHeader(h,t,s)     { (h)->h_CType = t ; (h)->h_CSize = s ; }
#define SameDeviceDef(f,s)      (! memcmp(&((f)->dd_Env.de_SizeBlock),&((s)->dd_Env.de_SizeBlock),10 * sizeof(ULONG)))

#define BeforeV5(v)             (v < HVER_V500)
#define AfterV4(v)              (v >= HVER_V500)
#define HasPathTable(v)         (v >= HVER_V510)
#define OldArchiveFmt()         BeforeV5(ArchiveFmt)

#define FirstChild(o)           ((struct Object *)((o)->obj_Children.mlh_Head))
#define NextChild(o)            ((struct Object *)((o)->obj_Node.mln_Succ))
#define PrevChild(o)            ((struct Object *)((o)->obj_Node.mln_Pred))
#define FirstUnit(a)            ((struct ArcUnit *)((a)->lh_Head))
#define NextUnit(a)             ((struct ArcUnit *)((a)->au_Node.ln_Succ))
#define FirstCmd(c)             ((struct InternalCmd *)((c)->lh_Head))
#define NextCmd(c)              ((struct InternalCmd *)((c)->ic_Message.mn_Node.ln_Succ))

/* $DOC Macros_Objects
 * OBJECT TYPE
 *
 *    ObjIsDir (o)              TRUE if is a directory
 *    ObjIsLink(o)              TRUE if is a link (either soft or hard)
 *    ObjIsHLink(o)             TRUE if is a hard link
 *    ObjIsSLink(o)             TRUE if is a soft link
 *    ObjIsDevice(o)            TRUE if is a device/partition
 *    ObjIsCatalog(o)           TRUE if is archive catalog file
 *    ObjIsFile(o)              TRUE if is a file
 *
 * OTHER FLAGS
 *
 *    ObjIsSaved(o)             TRUE if successfully backed up
 *    ObjIsClean(o)             TRUE is has been cleaned up after loading from catalog
 *    ObjPathOk(o)              TRUE if path created (for restoring)
 *    ObjIsSelected(o)          TRUE if selected for backup/restore
 *    ObjIsLinkDest(o)          TRUE if dummy object for storing links destination name
 *    ObjIsMultiVol(o)          TRUE if root of several partitions
 *    ObjIsEmptyDir(o)          TRUE if is an empty directory
 *    ObjIsMultiUser(o)         TRUE if object on a MUFS volume
 *    ObjIsNotEmptyDir(o)       TRUE if is not an empty directory
 *    ObjIsReadProtected(o)     TRUE if is read protected
 *    ObjHasComment(o)          TRUE if has a comment
 *    ObjIsSplited(o)           TRUE if splited
 * $END
 */

#define ObjIsDir(o)             ((o)->obj_Flags & OBJF_DIRECTORY)
#define ObjIsLink(o)            ((o)->obj_Flags & OBJF_LINK)
#define ObjIsHLink(o)           ((o)->obj_Flags & OBJF_HLINK)
#define ObjIsSLink(o)           ((o)->obj_Flags & OBJF_SLINK)
#define ObjIsSaved(o)           ((o)->obj_Flags & OBJF_SAVED)
#define ObjIsClean(o)           ((o)->obj_Flags & OBJF_CLEAN)
#define ObjIsDevice(o)          ((o)->obj_Flags & OBJF_DEVICE)
#define ObjPathOk(o)            ((o)->obj_Flags & OBJF_PATHOK)
#define ObjIsCatalog(o)         ((o)->obj_Flags & OBJF_CATALOG)
#define ObjIsFile(o)            (! ((o)->obj_Flags & OBJF_TYPE))
#define ObjIsLinkDest(o)        ((o)->obj_Flags & OBJF_DESTLINK)
#define ObjIsMultiVol(o)        ((o)->obj_Flags & OBJF_MULTIVOL)
#define ObjIsEmptyDir(o)        (ObjIsDir(o) && (! o->obj_Size))
#define ObjIsMultiUser(o)       ((o)->obj_Flags & OBJF_MULTIUSER)
#define ObjIsNotEmptyDir(o)     (ObjIsDir(o) && o->obj_Size)
#define ObjIsReadProtected(o)   ((o)->obj_Bits & FIBF_READ)
#define ObjIsSelected(o)        ((o)->obj_Flags & OBJF_SELECTED)
#define ObjHasComment(o)        ((o)->obj_Flags & OBJF_HASCOMMENT)
#define ObjIsSplited(o)         ((o)->obj_Flags & OBJF_SPLITED)

/* $DOC Macro_Devices
 *
 *    DevIsASync(d)             TRUE if handled by child task
 *    DevIsReady(d)             TRUE if PrepareDev() done on this device
 *    DevIsLocked(d)            TRUE if asynchronous writes are locked
 *    DevIsOpened(d)            TRUE if OpenDevice() done on this device
 *    DevIsReadOnly(d)          TRUE if writing to this device is not allowed
 *    DevIsTrackDisk(d)         TRUE if device is TrackDisk or DiskSpare
 *    DevIsInhibited(d)         TRUE if InhibitDev() done on this device
 *    DevIsToUpdate(d)          TRUE if FlushDev() is to call before seeking/closing
 *    DevIsArchive(d)           TRUE if device is the archive
 *    DevIsFormatable(d)        TRUE if we can use TD_FORMAT instead of CMD_WRITE
 *
 *    TapeIsDAC(t)              TRUE if tape is "direct access"
 * $END
 */

#define DevIsASync(d)           ((d)->au_Flags & AUF_ASYNC)
#define DevIsReady(d)           ((d)->au_Flags & AUF_ACCESS)
#define DevIsLocked(d)          ((d)->au_Flags & AUF_LOCKED)
#define DevIsOpened(d)          ((d)->au_Flags & AUF_OPENED)
#define DevIsReadOnly(d)        ((d)->au_Flags & AUF_READONLY)
#define DevIsTrackDisk(d)       ((d)->au_Flags & AUF_TRACKDISK)
#define DevIsInhibited(d)       ((d)->au_Flags & AUF_INHIBITED)
#define DevIsToUpdate(d)        ((d)->au_Flags & AUF_BUFFLUSH)
#define DevIsFormatable(d)      ((d)->au_Flags & AUF_TRACKDISK)
#define DevIsArchive(d)         (! ((d)->au_Flags & AUF_NOTARCHIVE))

#define TapeIsDAC(t)            ((t)->au_Flags & AUF_DACTAPE)

/* $DOC Macros_Program
 *    HasInterface()            TRUE if using Intuition interface
 *
 *    BATCHMODE 		TRUE if CLI "batch" mode is on
 *    FULLBATCHMODE		TRUE if CLI "batch" mode is on and QUIET specified
 *
 *    HasAudio()                TRUE if can play sound
 *    HasChildTask()            TRUE if child task is running
 *    HasBeenPaused()           TRUE if paused
 *    HasBeenQuit()             TRUE if asked to quit
 *    HasBeenBreaked()          TRUE if asked to abort
 *    HasDiskGauge()            TRUE if the disk gauge is to update
 *    MustUncrypt()             TRUE if reading crypted archive
 *    UseMemPools()             TRUE if using V39 memory pools
 * $END
 */

#define HasInterface()          (Win)

#define BATCHMODE		(ProgramFlags & PF_BATCH)
#define FULLBATCHMODE		(BATCHMODE && IS_ARG_QUIET)

#define HasAudio()              (ProgramFlags & PF_AUDIO)
#define HasChildTask()          (ProgramFlags & PF_CHILDTASK)
#define HasBeenPaused()         (ProgramFlags & PF_PAUSED)
#define HasBeenQuit()           (ProgramFlags & PF_QUIT)
#define HasBeenBreaked()        (ProgramFlags & PF_BREAKED)
#define HasDiskGauge()          (HasInterface() && (NewID == WIN_MONITOR))
#define MustUncrypt()           (ProgramFlags & PF_UNCRYPT)
#define HasBadCyl()             (ProgramFlags & PF_BADCYL)
#define UseMemPools()           (MemPool)

/* $DOC Macros_Flags
 *    SetUnitFlag(u,f)          set a flag in an ArcUnit structure
 *    ClearUnitFlag(u,f)        clear a flag in an ArcUnit structure
 *    SetObjFlag(o,f)           set a flag in an Object structure
 *    ClearObjFlag(o,f)         clear a flag in an Object structure
 *    SetPrgFlag(f)             set a program flag
 *    ClearPrgFlag(f)           clear a program flag
 *    SetICmdFlag(c,f)          set a flag in an InternalCmd structure
 * $END
 */

#define SetUnitFlag(u,f)        (u)->au_Flags |= (f)
#define ClearUnitFlag(u,f)      (u)->au_Flags &= ~(f)
#define SetObjFlag(o,f)         (o)->obj_Flags |= (f)
#define ClearObjFlag(o,f)       (o)->obj_Flags &= ~(f)
#define SetPrgFlag(f)           ProgramFlags |= (f)
#define ClearPrgFlag(f)         ProgramFlags &= ~(f)
#define SetICmdFlag(c,f)        (c)->ic_Flags |= (f)

#endif // ABACKUP_MACROS_H
