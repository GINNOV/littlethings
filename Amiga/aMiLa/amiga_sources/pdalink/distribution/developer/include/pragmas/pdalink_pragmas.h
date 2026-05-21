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
 * Pragmas.
 *
 * @author Richard "Shred" Körber
 */

/*pragma libcall PdalinkBase PL_Reserved 1e 0*/
#pragma libcall PdalinkBase PL_RawRead 24 09803
#pragma libcall PdalinkBase PL_RawWrite 2a 09803
#pragma libcall PdalinkBase PL_RawSetRate 30 0802
#pragma libcall PdalinkBase PL_SLPRead 36 BA09805
#pragma libcall PdalinkBase PL_SLPWrite 3c BA09805
#pragma libcall PdalinkBase PL_PADPRead 42 09803
#pragma libcall PdalinkBase PL_PADPWrite 48 109804
#pragma libcall PdalinkBase PL_CMPRead 4e 9802
#pragma libcall PdalinkBase PL_CMPWakeUp 54 0802
#pragma libcall PdalinkBase PL_CMPInit 5a 0802
#pragma libcall PdalinkBase PL_CMPAbort 60 0802
#pragma libcall PdalinkBase PL_OpenSocket 66 801
#pragma libcall PdalinkBase PL_CloseSocket 6c 801
#pragma libcall PdalinkBase PL_LastError 72 801
#pragma libcall PdalinkBase PL_Accept 78 0802
#pragma libcall PdalinkBase PL_Connect 7e 801
#pragma libcall PdalinkBase PL_Read 84 09803
#pragma libcall PdalinkBase PL_Write 8a 09803
#pragma libcall PdalinkBase PL_Tickle 90 801
#pragma libcall PdalinkBase PL_DLPInit 96 801
#pragma libcall PdalinkBase PL_DLPWriteByte 9c 0802
#pragma libcall PdalinkBase PL_DLPWriteWord a2 0802
#pragma libcall PdalinkBase PL_DLPWriteLong a8 0802
#pragma libcall PdalinkBase PL_DLPWrite ae 09803
#pragma libcall PdalinkBase PL_DLPSend b4 10803
#pragma libcall PdalinkBase PL_DLPRead ba 09803
#pragma libcall PdalinkBase DLP_OpenConduit c0 801
#pragma libcall PdalinkBase DLP_EndOfSync c6 0802
#pragma libcall PdalinkBase DLP_GetSysTime cc 9802
#pragma libcall PdalinkBase DLP_SetSysTime d2 9802
#pragma libcall PdalinkBase DLP_GetStorageInfo d8 90803
#pragma libcall PdalinkBase DLP_GetSysInfo de 9802
#pragma libcall PdalinkBase DLP_GetDBInfo e4 9210805
#pragma libcall PdalinkBase DLP_OpenDB ea 910804
#pragma libcall PdalinkBase DLP_DeleteDB f0 90803
#pragma libcall PdalinkBase DLP_CreateDB f6 943210807
#pragma libcall PdalinkBase DLP_CloseDB fc 0802
#pragma libcall PdalinkBase DLP_CloseAllDB 102 801
#pragma libcall PdalinkBase DLP_ReadOpenDBInfo 108 0802
#pragma libcall PdalinkBase DLP_MoveCategory 10e 210804
#pragma libcall PdalinkBase DLP_SetUserInfo 114 9802
#pragma libcall PdalinkBase DLP_GetUserInfo 11a 9802
#pragma libcall PdalinkBase DLP_SetNetSyncInfo 120 9802
#pragma libcall PdalinkBase DLP_GetNetSyncInfo 126 9802
#pragma libcall PdalinkBase DLP_ResetLastSyncPC 12c 801
#pragma libcall PdalinkBase DLP_ResetDBIndex 132 0802
#pragma libcall PdalinkBase DLP_ReadRecordIDList 138 A93210807
#pragma libcall PdalinkBase DLP_WriteRecord 13e A493210808
#pragma libcall PdalinkBase DLP_DeleteRecord 144 210804
#pragma libcall PdalinkBase DLP_DeleteCategory 14a 10803
#pragma libcall PdalinkBase DLP_ReadResourceByType 150 BA9210807
#pragma libcall PdalinkBase DLP_ReadResourceByIndex 156 2BA910807
#pragma libcall PdalinkBase DLP_WriteResource 15c 39210806
#pragma libcall PdalinkBase DLP_DeleteResource 162 3210805
#pragma libcall PdalinkBase DLP_ReadAppBlock 168 2910805
#pragma libcall PdalinkBase DLP_WriteAppBlock 16e 190804
#pragma libcall PdalinkBase DLP_ReadSortBlock 174 2910805
#pragma libcall PdalinkBase DLP_WriteSortBlock 17a 190804
#pragma libcall PdalinkBase DLP_CleanUpDatabase 180 0802
#pragma libcall PdalinkBase DLP_ResetSyncFlags 186 0802
#pragma libcall PdalinkBase DLP_ReadNextCatRecord 18c 32BA910808
#pragma libcall PdalinkBase DLP_ReadAppPreference 192 BA93210808
#pragma libcall PdalinkBase DLP_WriteAppPreference 198 493210807
#pragma libcall PdalinkBase DLP_ReadNextModifiedCatRecord 19e 32BA910808
#pragma libcall PdalinkBase DLP_ReadRecordByID 1a4 32BA910808
#pragma libcall PdalinkBase DLP_ReadRecordByIndex 1aa 32BA910808
#pragma libcall PdalinkBase DLP_ResetSystem 1b0 801
#pragma libcall PdalinkBase DLP_AddSyncLogEntry 1b6 9802
#pragma libcall PdalinkBase PL_FileOpen 1bc 9802
#pragma libcall PdalinkBase PL_FileClose 1c2 801
#pragma libcall PdalinkBase PL_FileGetDBInfo 1c8 801
#pragma libcall PdalinkBase PL_FileSetDBInfo 1ce 9802
#pragma libcall PdalinkBase PL_FileGetAppInfo 1d4 9802
#pragma libcall PdalinkBase PL_FileSetAppInfo 1da 09803
#pragma libcall PdalinkBase PL_FileGetSortInfo 1e0 9802
#pragma libcall PdalinkBase PL_FileSetSortInfo 1e6 09803
#pragma libcall PdalinkBase PL_FileReadResource 1ec BA90805
#pragma libcall PdalinkBase PL_FileAddResource 1f2 2109805
#pragma libcall PdalinkBase PL_FileReadRecord 1f8 BA90805
#pragma libcall PdalinkBase PL_FileReadRecordID 1fe BA90805
#pragma libcall PdalinkBase PL_FileAddRecord 204 2109805
#pragma libcall PdalinkBase PL_FileUsedID 20a 0802
#pragma libcall PdalinkBase PL_FileRetrieve 210 09803
#pragma libcall PdalinkBase PL_FileInstall 216 09803
#pragma libcall PdalinkBase PL_FileMerge 21c 09803
#pragma libcall PdalinkBase PL_Explain 222 09803
#pragma libcall PdalinkBase PL_AddRexxHandle 228 9802
#pragma libcall PdalinkBase PL_FindRexxHandle 22E 801
#pragma libcall PdalinkBase PL_DeleteRexxHandle 234 801
#pragma libcall PdalinkBase PL_GetBaudRate 23A 801
#pragma tagcall PdalinkBase PL_OpenSocketTags 66 801

