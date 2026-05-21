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
 * Prototypes.
 *
 * @author Richard "Shred" Körber
 */

#ifndef  CLIB_PDALINK_PROTOS_H
#define  CLIB_PDALINK_PROTOS_H

int DLP_AddSyncLogEntry(APTR,STRPTR);
int DLP_CleanUpDatabase(APTR,LONG);
int DLP_CloseAllDB(APTR);
int DLP_CloseDB(APTR,LONG);
LONG DLP_CountDBEntries(APTR,LONG);
LONG DLP_CreateDB(APTR,UBYTE,ULONG,ULONG,UWORD,UWORD,STRPTR);
int DLP_DeleteCategory(APTR,ULONG,BOOL);
int DLP_DeleteDB(APTR,UBYTE,STRPTR);
int DLP_DeleteRecord(APTR,ULONG,BOOL,ULONG);
int DLP_DeleteResource(APTR,ULONG,BOOL,ULONG,UWORD);
int DLP_EndOfSync(APTR,UWORD);
int DLP_GetDBInfo(APTR,UBYTE,UBYTE,UWORD,struct DLP_DBInfo *);
int DLP_GetNetSyncInfo(APTR,struct DLP_NetSyncInfo *);
LONG DLP_GetRecordIDList(APTR,LONG,BOOL,UWORD,UWORD,ULONG *);
int DLP_GetStorageInfo(APTR,UBYTE,struct DLP_StorageInfo *);
int DLP_GetSysInfo(APTR,struct DLP_SysInfo *);
int DLP_GetSysTime(APTR,struct DLP_SysTime *);
int DLP_GetUserInfo(APTR,struct DLP_UserInfo *);
int DLP_MoveCategory(APTR,LONG,UBYTE,UBYTE);
int DLP_OpenConduit(APTR);
LONG DLP_OpenDB(APTR,UBYTE,UBYTE,STRPTR);
LONG DLP_ReadAppBlock(APTR,LONG,UWORD,APTR,UWORD);
LONG DLP_ReadAppPreference(APTR,ULONG,UWORD,BOOL,UWORD,APTR,UWORD *,UWORD *);
LONG DLP_ReadNextCatRecord(APTR,ULONG,UBYTE,APTR,ULONG *,UWORD *,UWORD *,UBYTE *);
LONG DLP_ReadNextModifiedCatRecord(APTR,ULONG,UBYTE,APTR,ULONG *,UWORD *,UWORD *,UBYTE *);
LONG DLP_ReadRecordByID(APTR,LONG,ULONG,APTR,UWORD *,UWORD *,UBYTE *,UBYTE *);
LONG DLP_ReadRecordByIndex(APTR,LONG,UWORD,APTR,ULONG *,UWORD *,UBYTE *,UBYTE *);
LONG DLP_ReadResourceByIndex(APTR,LONG,UWORD,APTR,ULONG *,UWORD *,UWORD *);
LONG DLP_ReadResourceByType(APTR,LONG,ULONG,UWORD,APTR,UWORD *,UWORD *);
LONG DLP_ReadSortBlock(APTR,LONG,UWORD,APTR,UWORD);
int DLP_ResetDBIndex(APTR,LONG);
int DLP_ResetLastSyncPC(APTR);
int DLP_ResetSyncFlags(APTR,LONG);
int DLP_ResetSystem(APTR);
int DLP_SetNetSyncInfo(APTR,struct DLP_NetSyncInfo *);
int DLP_SetSysTime(APTR,struct DLP_SysTime *);
int DLP_SetUserInfo(APTR,struct DLP_UserInfo *);
int DLP_WriteAppBlock(APTR,LONG,APTR,UWORD);
int DLP_WriteAppPreference(APTR,ULONG,UWORD,BOOL,UWORD,APTR,UWORD);
int DLP_WriteRecord(APTR,LONG,UBYTE,ULONG,UBYTE,APTR,UWORD,ULONG *);
int DLP_WriteResource(APTR,LONG,ULONG,UWORD,APTR,UWORD);
int DLP_WriteSortBlock(APTR,LONG,APTR,UWORD);
int PL_Accept(APTR, ULONG);
void PL_AddRexxHandle(APTR, STRPTR);
void PL_CloseSocket(APTR);
int PL_CMPAbort(APTR,UBYTE);
int PL_CMPInit(APTR,ULONG);
int PL_CMPRead(APTR,struct PL_CMP *);
int PL_CMPWakeUp(APTR,ULONG);
int PL_Connect(APTR);
void PL_DeleteRexxHandle(STRPTR);
void PL_DLPInit(APTR);
LONG PL_DLPRead(APTR,APTR,LONG);
LONG PL_DLPSend(APTR,UBYTE,UBYTE);
int PL_DLPTstWrite(APTR,LONG);
LONG PL_DLPWrite(APTR,APTR,LONG);
LONG PL_DLPWriteByte(APTR,BYTE);
LONG PL_DLPWriteLong(APTR,LONG);
LONG PL_DLPWriteWord(APTR,WORD);
void PL_Explain(LONG,STRPTR,ULONG);
int PL_FileAddRecord(APTR,APTR,ULONG,UBYTE,ULONG);
int PL_FileAddResource(APTR,APTR,ULONG,ULONG,UWORD);
int PL_FileClose(APTR);
APTR PL_FileGetAppInfo(APTR,ULONG *);
struct DLP_DBInfo *PL_FileGetDBInfo(APTR);
APTR PL_FileGetSortInfo(APTR,ULONG *);
int PL_FileInstall(APTR,APTR,UBYTE);
int PL_FileMerge(APTR,APTR,UBYTE);
APTR PL_FileOpen(STRPTR,struct DLP_DBInfo *);
APTR PL_FileReadRecord(APTR,UWORD,ULONG *,UBYTE *,ULONG *);
APTR PL_FileReadRecordID(APTR,ULONG,ULONG *,UBYTE *,UWORD *);
APTR PL_FileReadResource(APTR,UWORD,ULONG *,ULONG *,UWORD *);
int PL_FileRetrieve(APTR,APTR,UBYTE);
int PL_FileSetAppInfo(APTR,APTR,ULONG);
int PL_FileSetDBInfo(APTR,struct DLP_DBInfo *);
int PL_FileSetSortInfo(APTR,APTR,ULONG);
int PL_FileUsedID(APTR,ULONG);
APTR PL_FindRexxHandle(STRPTR);
ULONG PL_GetBaudRate(APTR);
LONG PL_LastError(APTR);
APTR PL_OpenSocket(struct TagItem *);
APTR PL_OpenSocketTags(ULONG,...);
LONG PL_PADPRead(APTR,APTR,LONG);
LONG PL_PADPWrite(APTR,APTR,LONG,UWORD);
int PL_RawRead(APTR,APTR,LONG);
int PL_RawSetRate(APTR,ULONG);
int PL_RawWrite(APTR,APTR,LONG);
LONG PL_Read(APTR,UBYTE *,LONG);
LONG PL_SLPRead(APTR,APTR,LONG,struct PL_SLP_Header *,struct PL_PADP_Header *);
LONG PL_SLPWrite(APTR,APTR,LONG,struct PL_SLP_Header *, struct PL_PADP_Header *);
int PL_Tickle(APTR);
LONG PL_Write(APTR,UBYTE *,LONG);

#endif
