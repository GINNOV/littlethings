/*
 * PdaLink -- Connect Palm with Amiga
 *
 * Copyright (C) 1998-2010 Richard "Shred" Körber
 *   http://pdalink.shredzone.org
 *
 * This library is free software: you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation, either
 * version 3 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * Globals for pdalink.library.
 * 
 * @author Richard "Shred" Körber
 */
 
#ifndef PDALINK_GLOB_H
#define PDALINK_GLOB_H

//#define DEBUGOUT                /* Debug output? */

//#define SERDEBUG                /* Debug: Serial interface */
//#define SLPDEBUG                /* Debug: Serial Link Protocol */
//#define PADPDEBUG               /* Debug: Packet Assembly Disassembly Protocol */
//#define APIDEBUG                /* Debug: API */
//#define DLPDEBUG                /* Debug: DLP */
//#define FILEDEBUG               /* Debug: File */
//#define NETSYNCDEBUG            /* Debug: NetSync */

#include <clib/alib_protos.h>
#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/utility_protos.h>
#include <clib/rexxsyslib_protos.h>
//#include <clib/pdalink_protos.h>
#include <pragmas/exec_pragmas.h>
#include <pragmas/dos_pragmas.h>
#include <pragmas/utility_pragmas.h>
#include <pragmas/rexxsyslib_pragmas.h>
//#include <pragmas/pdalink_pragmas.h>

#include <exec/memory.h>
#include <exec/libraries.h>
#include <exec/semaphores.h>
#include <utility/tagitem.h>
#include <rexx/rxslib.h>
#include <rexx/errors.h>
#include <dos/dos.h>
#include <dos/dosasl.h>
#include <string.h>

#include "debug.h"
#include "pdalink.h"
#include "pdalink_private.h"

#define max(a,b) ((a)>(b) ? (a) : (b))
#define min(a,b) ((a)<(b) ? (a) : (b))


struct Global
{
  UBYTE *slptrash;          /* Trash buffer for SLP */
  struct SignalSemaphore rexxHandleSemaphore;
  struct List rexxHandles;
  BOOL rexxHandleOK;
};

/*
**  P R O T O T Y P E S
*/
/*-- PL_Init.c --*/
extern struct DOSBase       *DOSBase;
extern struct Library       *UtilityBase;
extern struct Library       *SysBase;
extern struct Library       *RexxSysBase;
extern struct Library       *PdalinkBase;
extern struct Global         global;

/*-- PL_Socket.c --*/
extern __saveds __asm APTR PL_OpenSocket(register __a0 struct TagItem *taglist);
extern __saveds __asm int PL_Accept(register __a0 APTR socket, register __d0 ULONG timeout);
extern __saveds __asm int PL_Connect(register __a0 APTR socket);
extern __saveds __asm LONG PL_LastError(register __a0 APTR socket);
extern __saveds __asm ULONG PL_GetBaudRate(register __a0 APTR socket);
extern __saveds __asm LONG PL_Read(register __a0 APTR socket, register __a1 APTR buffer, register __d0 LONG size);
extern __saveds __asm LONG PL_Write(register __a0 APTR socket, register __a1 APTR buffer, register __d0 LONG size);
extern __saveds __asm LONG PL_Tickle(register __a0 APTR socket);
extern __saveds __asm void PL_CloseSocket(register __a0 APTR socket);
extern __saveds __asm void PL_Explain(register __a0 LONG error, register __a1 STRPTR buffer, register __d0 ULONG length);

/*-- PL_Serial.c --*/
extern int OpenPalmSerial(struct PL_Socket *sock, STRPTR device, ULONG unit, ULONG baud);
extern void ClosePalmSerial(struct PL_Socket *sock);
extern __saveds __asm int PL_RawSetRate(register __a0 APTR socket, register __d0 ULONG baud);
extern __saveds __asm LONG PL_RawRead(register __a0 APTR socket, register __a1 APTR buffer, register __d0 LONG length);
extern __saveds __asm LONG PL_RawWrite(register __a0 APTR socket, register __a1 APTR buffer, register __d0 LONG length);
extern __saveds __asm int PL_RawFlush(register __a0 APTR socket);

/*-- PL_SLP.c --*/
extern __saveds __asm LONG PL_SLPWrite(register __a0 APTR socket, register __a1 APTR buffer, register __d0 LONG length, register __a2 struct PL_SLP_Header *header, register __a3 struct PL_PADP_Header *padp);
extern __saveds __asm LONG PL_SLPRead(register __a0 APTR socket, register __a1 APTR buffer, register __d0 LONG length, register __a2 struct PL_SLP_Header *header, register __a3 struct PL_PADP_Header *padp);

/*-- PL_PADP.c --*/
extern __saveds __asm LONG PL_PADPWrite(register __a0 APTR socket, register __a1 APTR buffer, register __d0 LONG length, register __d1 UWORD type);
extern __saveds __asm LONG PL_PADPRead(register __a0 APTR socket, register __a1 APTR buffer, register __d0 LONG length);

/*-- PL_NetSync.c --*/
extern __saveds __asm LONG PL_NetSyncWrite(register __a0 APTR socket, register __a1 APTR buffer, register __d0 LONG length, register __d1 UWORD type);
extern __saveds __asm LONG PL_NetSyncRead(register __a0 APTR socket, register __a1 APTR buffer, register __d0 LONG length);
extern BOOL PL_NetSyncServerRitual(struct PL_Socket *socket);

/*-- PL_CMP.c --*/
extern __saveds __asm int PL_CMPAbort(register __a0 APTR socket, register __d0 UBYTE reason);
extern __saveds __asm int PL_CMPInit(register __a0 APTR socket, register __d0 ULONG rate);
extern __saveds __asm int PL_CMPWakeUp(register __a0 APTR socket, register __d0 ULONG maxrate);
extern __saveds __asm int PL_CMPRead(register __a0 APTR socket, register __d0 struct PL_CMP *cmp);

/*-- PL_DLP.c --*/
extern __saveds __asm void PL_DLPInit(register __a0 APTR socket);
extern __saveds __asm LONG PL_DLPWriteByte(register __a0 APTR socket, register __d0 BYTE bdata);
extern __saveds __asm LONG PL_DLPWriteWord(register __a0 APTR socket, register __d0 WORD wdata);
extern __saveds __asm LONG PL_DLPWriteLong(register __a0 APTR socket, register __d0 LONG ldata);
extern __saveds __asm LONG PL_DLPWrite(register __a0 APTR socket, register __a1 APTR packet, register __d0 LONG length);
extern __saveds __asm LONG PL_DLPSend(register __a0 APTR socket, register __d0 UBYTE cmd, register __d1 UBYTE arg);
extern __saveds __asm LONG PL_DLPRead(register __a0 APTR socket, register __a1 APTR buffer, register __d0 LONG length);
extern __saveds __asm int DLP_OpenConduit(register __a0 APTR socket);
extern __saveds __asm int DLP_EndOfSync(register __a0 APTR socket, register __d0 UWORD status);
extern __saveds __asm int DLP_GetSysTime(register __a0 APTR socket, register __a1 struct DLP_SysTime *time);
extern __saveds __asm int DLP_SetSysTime(register __a0 APTR socket, register __a1 struct DLP_SysTime *time);
extern __saveds __asm int DLP_GetStorageInfo(register __a0 APTR socket, register __d0 UBYTE cardno, register __a1 struct DLP_StorageInfo *info);
extern __saveds __asm int DLP_GetSysInfo(register __a0 APTR socket, register __a1 struct DLP_SysInfo *info);
extern __saveds __asm int DLP_GetDBInfo(register __a0 APTR socket, register __d0 UBYTE cardno, register __d1 UBYTE flags, register __d2 UWORD start, register __a1 struct DLP_DBInfo *info);
extern __saveds __asm LONG DLP_OpenDB(register __a0 APTR socket, register __d0 UBYTE cardno, register __d1 UBYTE mode, register __a1 STRPTR name);
extern __saveds __asm int DLP_DeleteDB(register __a0 APTR socket, register __d0 UBYTE cardno, register __a1 STRPTR name);
extern __saveds __asm LONG DLP_CreateDB(register __a0 APTR socket, register __d0 UBYTE cardno, register __d1 ULONG creator, register __d2 ULONG type, register __d3 UWORD flags, register __d4 UWORD version, register __a1 STRPTR name);
extern __saveds __asm int DLP_CloseDB(register __a0 APTR socket, register __d0 LONG handle);
extern __saveds __asm int DLP_CloseAllDB(register __a0 APTR socket);
extern __saveds __asm int DLP_ResetSystem(register __a0 APTR socket);
extern __saveds __asm int DLP_AddSyncLogEntry(register __a0 APTR socket, register __a1 STRPTR entry);
extern __saveds __asm LONG DLP_CountDBEntries(register __a0 APTR socket, register __d0 LONG handle);
extern __saveds __asm int DLP_MoveCategory(register __a0 APTR socket, register __d0 LONG handle, register __d1 UBYTE oldcat, register __d2 UBYTE newcat);
extern __saveds __asm int DLP_SetUserInfo(register __a0 APTR socket, register __a1 struct DLP_UserInfo *user);
extern __saveds __asm int DLP_GetUserInfo(register __a0 APTR socket, register __a1 struct DLP_UserInfo *user);
extern __saveds __asm int DLP_SetNetSyncInfo(register __a0 APTR socket, register __a1 struct DLP_NetSyncInfo *netsync);
extern __saveds __asm int DLP_GetNetSyncInfo(register __a0 APTR socket, register __a1 struct DLP_NetSyncInfo *netsync);
extern __saveds __asm int DLP_ResetLastSyncPC(register __a0 APTR socket);
extern __saveds __asm int DLP_ResetDBIndex(register __a0 APTR socket, register __d0 LONG handle);
extern __saveds __asm LONG DLP_GetRecordIDList(register __a0 APTR socket, register __d0 LONG handle, register __d1 BOOL sort, register __d2 UWORD start, register __d3 UWORD max, register __a1 ULONG *ids);
extern __saveds __asm int DLP_WriteRecord(register __a0 APTR socket, register __d0 LONG handle, register __d1 UBYTE flags, register __d2 ULONG id, register __d3 UBYTE catid, register __a1 APTR buffer, register __d4 UWORD length, register __a2 ULONG *newid);
extern __saveds __asm int DLP_DeleteRecord(register __a0 APTR socket, register __d0 LONG handle, register __d1 BOOL all, register __d2 ULONG id);
extern __saveds __asm int DLP_DeleteCategory(register __a0 APTR socket, register __d0 LONG handle, register __d1 UBYTE category);
extern __saveds __asm LONG DLP_ReadResourceByType(register __a0 APTR socket, register __d0 LONG handle, register __d1 ULONG type, register __d2 UWORD id, register __a1 APTR buffer, register __a2 UWORD *index, register __a3 UWORD *size);
extern __saveds __asm LONG DLP_ReadResourceByIndex(register __a0 APTR socket, register __d0 LONG handle, register __d1 UWORD index, register __a1 APTR buffer, register __a2 ULONG *type, register __a3 UWORD *id, register __d2 UWORD *size);
extern __saveds __asm int DLP_WriteResource(register __a0 APTR socket, register __d0 LONG handle, register __d1 ULONG type, register __d2 UWORD id, register __a1 APTR buffer, register __d3 UWORD length);
extern __saveds __asm int DLP_DeleteResource(register __a0 APTR socket, register __d0 LONG handle, register __d1 BOOL all, register __d2 ULONG restype, register __d3 UWORD resid);
extern __saveds __asm LONG DLP_ReadAppBlock(register __a0 APTR socket, register __d0 LONG handle, register __d1 UWORD offset, register __a1 APTR buffer, register __d2 UWORD length);
extern __saveds __asm int DLP_WriteAppBlock(register __a0 APTR socket, register __d0 LONG handle, register __a1 APTR buffer, register __d1 UWORD length);
extern __saveds __asm LONG DLP_ReadSortBlock(register __a0 APTR socket, register __d0 LONG handle, register __d1 UWORD offset, register __a1 APTR buffer, register __d2 UWORD length);
extern __saveds __asm int DLP_WriteSortBlock(register __a0 APTR socket, register __d0 LONG handle, register __a1 APTR buffer, register __d1 UWORD length);
extern __saveds __asm int DLP_CleanUpDatabase(register __a0 APTR socket, register __d0 LONG handle);
extern __saveds __asm int DLP_ResetSyncFlags(register __a0 APTR socket, register __d0 LONG handle);
extern __saveds __asm LONG DLP_ReadNextCatRecord(register __a0 APTR socket, register __d0 LONG handle, register __d1 UBYTE cat, register __a1 APTR buffer, register __a2 ULONG *id, register __a3 UWORD *index, register __d2 UWORD *size, register __d3 UBYTE *attr);
extern __saveds __asm LONG DLP_ReadAppPreference(register __a0 APTR socket, register __d0 ULONG creator, register __d1 UWORD id, register __d2 BOOL backup, register __d3 UWORD maxsize, register __a1 APTR buffer, register __a2 UWORD *size, register __a3 UWORD *version);
extern __saveds __asm int DLP_WriteAppPreference(register __a0 APTR socket, register __d0 ULONG creator, register __d1 UWORD id, register __d2 BOOL backup, register __d3 UWORD version, register __a1 APTR buffer, register __d4 UWORD length);
extern __saveds __asm LONG DLP_ReadNextModifiedCatRecord(register __a0 APTR socket, register __d0 LONG handle, register __d1 UBYTE cat, register __a1 APTR buffer, register __a2 ULONG *id, register __a3 UWORD *index, register __d2 UWORD *size, register __d3 UBYTE *attr);
extern __saveds __asm LONG DLP_ReadRecordByID(register __a0 APTR socket, register __d0 LONG handle, register __d1 ULONG id, register __a1 APTR buffer, register __a2 UWORD *index, register __a3 UWORD *size, register __d2 UBYTE *attr, register __d3 UBYTE *cat);
extern __saveds __asm LONG DLP_ReadRecordByIndex(register __a0 APTR socket, register __d0 LONG handle, register __d1 UWORD index, register __a1 APTR buffer, register __a2 ULONG *id, register __a3 UWORD *size, register __d2 UBYTE *attr, register __d3 UBYTE *cat);
extern __saveds __asm LONG DLP_UnpackCategoryAppInfo(register __a0 struct PL_CategoryAppInfo *cai, register __a1 APTR record, register __d0 LONG length);
extern __saveds __asm LONG DLP_PackCategoryAppInfo(register __a0 struct PL_CategoryAppInfo *cai, register __a1 APTR record, register __d0 LONG length);

/*-- PL_File.c --*/
extern __saveds __asm APTR PL_FileOpen(register __a0 STRPTR name, register __a1 struct DLP_DBInfo *ndbinfo);
extern __saveds __asm int PL_FileClose(register __a0 APTR fh);
extern __saveds __asm struct DLP_DBInfo *PL_FileGetDBInfo(register __a0 APTR fh);
extern __saveds __asm int PL_FileSetDBInfo(register __a0 APTR fh, register __a1 struct DLP_DBInfo *dbinfo);
extern __saveds __asm APTR PL_FileGetAppInfo(register __a0 APTR fh, register __a1 ULONG *size);
extern __saveds __asm int PL_FileSetAppInfo(register __a0 APTR fh, register __a1 APTR appinfo, register __d0 ULONG size);
extern __saveds __asm APTR PL_FileGetSortInfo(register __a0 APTR fh, register __a1 ULONG *size);
extern __saveds __asm int PL_FileSetSortInfo(register __a0 APTR fh, register __a1 APTR sortinfo, register __d0 ULONG size);
extern __saveds __asm APTR PL_FileReadResource(register __a0 APTR fh, register __d0 UWORD ix, register __a1 ULONG *size, register __a2 ULONG *type, register __a3 UWORD *id);
extern __saveds __asm int PL_FileAddResource(register __a0 APTR fh, register __a1 APTR buffer, register __d0 ULONG size, register __d1 ULONG type, register __d2 UWORD id);
extern __saveds __asm APTR PL_FileReadRecord(register __a0 APTR fh, register __d0 UWORD ix, register __a1 ULONG *size, register __a2 UBYTE *attr, register __a3 ULONG *uid);
extern __saveds __asm APTR PL_FileReadRecordID(register __a0 APTR fh, register __d0 ULONG uid, register __a1 ULONG *size, register __a2 UBYTE *attr, register __a3 UWORD *ix);
extern __saveds __asm int PL_FileAddRecord(register __a0 APTR fh, register __a1 APTR buffer, register __d0 ULONG size, register __d1 UBYTE attr, register __d2 ULONG uid);
extern __saveds __asm int PL_FileUsedID(register __a0 APTR fh, register __d0 ULONG uid);
extern __saveds __asm int PL_FileRetrieve(register __a0 APTR fh, register __a1 APTR socket, register __d0 UBYTE cardno);
extern __saveds __asm int PL_FileInstall(register __a0 APTR fh, register __a1 APTR socket, register __d0 UBYTE cardno);
extern __saveds __asm int PL_FileMerge(register __a0 APTR fh, register __a1 APTR socket, register __d0 UBYTE cardno);

/*-- PL_ARexx.c --*/
extern __saveds __asm LONG RexxCmd(register __a0 struct RexxMsg *rxmsg, register __a1 struct RexxArg **rxarg);
extern __saveds __asm void PL_AddRexxHandle(register __a0 STRPTR name, register __a1 APTR handle);
extern __saveds __asm APTR PL_FindRexxHandle(register __a0 STRPTR name);
extern __saveds __asm void PL_DeleteRexxHandle(register __a0 STRPTR name);

#endif

