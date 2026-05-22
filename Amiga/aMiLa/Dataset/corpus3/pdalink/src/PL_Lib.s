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

**
* Library initialization, assembler part
*
* @author Richard "Shred" Körber
*

		INCLUDE exec/libraries.i
		INCLUDE exec/initializers.i
		INCLUDE exec/resident.i
		INCLUDE exec/execbase.i
		INCLUDE utility/hooks.i
		INCLUDE lvo/exec.i
		INCLUDE PL_Lib.i

		SECTION text,CODE

		XREF    _LibInit
		XREF    _LibExit
		XREF    _RexxCmd

		XREF    _PL_RawSetRate
		XREF    _PL_RawRead
		XREF    _PL_RawWrite
		XREF    _PL_SLPWrite
		XREF    _PL_SLPRead
		XREF    _PL_PADPWrite
		XREF    _PL_PADPRead
		XREF    _PL_CMPAbort
		XREF    _PL_CMPInit
		XREF    _PL_CMPWakeUp
		XREF    _PL_CMPRead
		XREF    _PL_OpenSocket
		XREF    _PL_CloseSocket
		XREF    _PL_LastError
		XREF    _PL_Accept
		XREF    _PL_Connect
		XREF    _PL_Read
		XREF    _PL_Write
		XREF    _PL_Tickle
		XREF    _PL_DLPInit
		XREF    _PL_DLPWriteByte
		XREF    _PL_DLPWriteWord
		XREF    _PL_DLPWriteLong
		XREF    _PL_DLPWrite
		XREF    _PL_DLPSend
		XREF    _PL_DLPRead
		XREF    _DLP_OpenConduit
		XREF    _DLP_EndOfSync
		XREF    _DLP_GetSysTime
		XREF    _DLP_SetSysTime
		XREF    _DLP_GetStorageInfo
		XREF    _DLP_GetSysInfo
		XREF    _DLP_GetDBInfo
		XREF    _DLP_OpenDB
		XREF    _DLP_DeleteDB
		XREF    _DLP_CreateDB
		XREF    _DLP_CloseDB
		XREF    _DLP_CloseAllDB
		XREF    _DLP_CountDBEntries
		XREF    _DLP_MoveCategory
		XREF    _DLP_SetUserInfo
		XREF    _DLP_GetUserInfo
		XREF    _DLP_SetNetSyncInfo
		XREF    _DLP_GetNetSyncInfo
		XREF    _DLP_ResetLastSyncPC
		XREF    _DLP_ResetDBIndex
		XREF    _DLP_GetRecordIDList
		XREF    _DLP_WriteRecord
		XREF    _DLP_DeleteRecord
		XREF    _DLP_DeleteCategory
		XREF    _DLP_ReadResourceByType
		XREF    _DLP_ReadResourceByIndex
		XREF    _DLP_WriteResource
		XREF    _DLP_DeleteResource
		XREF    _DLP_ReadAppBlock
		XREF    _DLP_WriteAppBlock
		XREF    _DLP_ReadSortBlock
		XREF    _DLP_WriteSortBlock
		XREF    _DLP_CleanUpDatabase
		XREF    _DLP_ResetSyncFlags
		XREF    _DLP_ReadNextCatRecord
		XREF    _DLP_ReadAppPreference
		XREF    _DLP_WriteAppPreference
		XREF    _DLP_ReadNextModifiedCatRecord
		XREF    _DLP_ReadRecordByID
		XREF    _DLP_ReadRecordByIndex
		XREF    _DLP_ResetSystem
		XREF    _DLP_AddSyncLogEntry
		XREF    _PL_FileOpen
		XREF    _PL_FileClose
		XREF    _PL_FileGetDBInfo
		XREF    _PL_FileSetDBInfo
		XREF    _PL_FileGetAppInfo
		XREF    _PL_FileSetAppInfo
		XREF    _PL_FileGetSortInfo
		XREF    _PL_FileSetSortInfo
		XREF    _PL_FileReadResource
		XREF    _PL_FileAddResource
		XREF    _PL_FileReadRecord
		XREF    _PL_FileReadRecordID
		XREF    _PL_FileAddRecord
		XREF    _PL_FileUsedID
		XREF    _PL_FileRetrieve
		XREF    _PL_FileInstall
		XREF    _PL_FileMerge
		XREF    _PL_Explain
		XREF    _PL_AddRexxHandle
		XREF    _PL_FindRexxHandle
		XREF    _PL_DeleteRexxHandle
		XREF    _DLP_UnpackCategoryAppInfo
		XREF    _DLP_PackCategoryAppInfo
		XREF    _PL_GetBaudRate

*-------------------------------------------------------*
* Start         No start from CLI                       *
*                                                       *
Start           moveq   #0,d0
		rts

*-------------------------------------------------------*
* InitDDescrip  Describe Library                        *
*                                                       *
InitDDescrip    dc.w    RTC_MATCHWORD
		dc.l    InitDDescrip
		dc.l    EndCode
		dc.b    RTF_AUTOINIT,VERSION,NT_LIBRARY,0
		dc.l    libname,libidstring,Init
libname         PRGNAME
		dc.b    0
libidstring     VSTRING

	;-- Information for HexReaders... -------------;

		VERS
		dc.b    "  (C) 1998-2010 Richard Körber <rkoerber@gmx.de>, (C) 2004 Chris Hodges <chrisly@platon42.de>",13,10,0
		even

*-------------------------------------------------------*
* Init          Init Table follows                      *
*                                                       *
Init            dc.l    plb_SIZEOF,FuncTab,DataTab,InitFct

*-------------------------------------------------------*
* FuncTab       Table of functions                      *
*  ALWAYS add at its end. NEVER remove or swap lines!!! *
*                                                       *
FuncTab         dc.l    LOpen,LClose,LExpunge,LNull     ;Standard
		dc.l    CallRexxCmd
		dc.l    _PL_RawRead
		dc.l    _PL_RawWrite
		dc.l    _PL_RawSetRate
		dc.l    _PL_SLPRead
		dc.l    _PL_SLPWrite
		dc.l    _PL_PADPRead
		dc.l    _PL_PADPWrite
		dc.l    _PL_CMPRead
		dc.l    _PL_CMPWakeUp
		dc.l    _PL_CMPInit
		dc.l    _PL_CMPAbort
		dc.l    _PL_OpenSocket
		dc.l    _PL_CloseSocket
		dc.l    _PL_LastError
		dc.l    _PL_Accept
		dc.l    _PL_Connect
		dc.l    _PL_Read
		dc.l    _PL_Write
		dc.l    _PL_Tickle
		dc.l    _PL_DLPInit
		dc.l    _PL_DLPWriteByte
		dc.l    _PL_DLPWriteWord
		dc.l    _PL_DLPWriteLong
		dc.l    _PL_DLPWrite
		dc.l    _PL_DLPSend
		dc.l    _PL_DLPRead
		dc.l    _DLP_OpenConduit
		dc.l    _DLP_EndOfSync
		dc.l    _DLP_GetSysTime
		dc.l    _DLP_SetSysTime
		dc.l    _DLP_GetStorageInfo
		dc.l    _DLP_GetSysInfo
		dc.l    _DLP_GetDBInfo
		dc.l    _DLP_OpenDB
		dc.l    _DLP_DeleteDB
		dc.l    _DLP_CreateDB
		dc.l    _DLP_CloseDB
		dc.l    _DLP_CloseAllDB
		dc.l    _DLP_CountDBEntries
		dc.l    _DLP_MoveCategory
		dc.l    _DLP_SetUserInfo
		dc.l    _DLP_GetUserInfo
		dc.l    _DLP_SetNetSyncInfo
		dc.l    _DLP_GetNetSyncInfo
		dc.l    _DLP_ResetLastSyncPC
		dc.l    _DLP_ResetDBIndex
		dc.l    _DLP_GetRecordIDList
		dc.l    _DLP_WriteRecord
		dc.l    _DLP_DeleteRecord
		dc.l    _DLP_DeleteCategory
		dc.l    _DLP_ReadResourceByType
		dc.l    _DLP_ReadResourceByIndex
		dc.l    _DLP_WriteResource
		dc.l    _DLP_DeleteResource
		dc.l    _DLP_ReadAppBlock
		dc.l    _DLP_WriteAppBlock
		dc.l    _DLP_ReadSortBlock
		dc.l    _DLP_WriteSortBlock
		dc.l    _DLP_CleanUpDatabase
		dc.l    _DLP_ResetSyncFlags
		dc.l    _DLP_ReadNextCatRecord
		dc.l    _DLP_ReadAppPreference
		dc.l    _DLP_WriteAppPreference
		dc.l    _DLP_ReadNextModifiedCatRecord
		dc.l    _DLP_ReadRecordByID
		dc.l    _DLP_ReadRecordByIndex
		dc.l    _DLP_ResetSystem
		dc.l    _DLP_AddSyncLogEntry
		dc.l    _PL_FileOpen
		dc.l    _PL_FileClose
		dc.l    _PL_FileGetDBInfo
		dc.l    _PL_FileSetDBInfo
		dc.l    _PL_FileGetAppInfo
		dc.l    _PL_FileSetAppInfo
		dc.l    _PL_FileGetSortInfo
		dc.l    _PL_FileSetSortInfo
		dc.l    _PL_FileReadResource
		dc.l    _PL_FileAddResource
		dc.l    _PL_FileReadRecord
		dc.l    _PL_FileReadRecordID
		dc.l    _PL_FileAddRecord
		dc.l    _PL_FileUsedID
		dc.l    _PL_FileRetrieve
		dc.l    _PL_FileInstall
		dc.l    _PL_FileMerge
		dc.l    _PL_Explain
		dc.l    _PL_AddRexxHandle
		dc.l    _PL_FindRexxHandle
		dc.l    _PL_DeleteRexxHandle
		dc.l    _PL_GetBaudRate
		dc.l    _DLP_UnpackCategoryAppInfo
		dc.l    _DLP_PackCategoryAppInfo
		dc.l    -1                              ;-- End --

*-------------------------------------------------------*
* DataTab       Initializes the lib node                *
*                                                       *
DataTab         INITBYTE        LN_TYPE,NT_LIBRARY
		INITLONG        LN_NAME,libname
		INITBYTE        LIB_FLAGS,LIBF_SUMUSED|LIBF_CHANGED
		INITWORD        LIB_VERSION,VERSION
		INITWORD        LIB_REVISION,REVISION
		INITLONG        LIB_IDSTRING,libidstring
		dc.l    0

*-------------------------------------------------------*
* InitFct       Initialize Library                      *
*       -» D0.l ^LibBase                                *
*       -» A0.l ^SegList                                *
*       -» A6.l ^SysLibBase                             *
*       «- D0.l ^Libbase                                *
*                                                       *
InitFct         movem.l d1-d7/a0-a6,-(sp)
		move.l  d0,a1                   ;LibBase->a1
		move.l  a6,(plb_SysLib,a1)      ;remember execbase
		move.l  a0,(plb_SegList,a1)     ;remember SegList
		move.l  a6,a0                   ;exec in a0
		jsr     _LibInit                ;own Inits
		movem.l (SP)+,d1-d7/a0-a6
		rts

*-------------------------------------------------------*
* LOpen         Open lib                                *
*       -» D0.l Version                                 *
*       -» A6.l ^LibBase                                *
*       «- D0.l ^LibBase, if successful                 *
*                                                       *
LOpen           addq    #1,(LIB_OPENCNT,a6)     ;Increment lib counter
		bclr    #PLLB_DELEXP,(plb_Flags+1,a6) ;Do not close
		move.l  a6,d0
		rts

*-------------------------------------------------------*
* LClose        Close Lib                               *
*       -» A6.l ^LibBase                                *
*       «- D0.l ^SegList oder 0                         *
*                                                       *
LClose          moveq   #0,d0
		subq    #1,(LIB_OPENCNT,a6)     ;Decrement lib counter
		bne     .notlast
		btst    #PLLB_DELEXP,(plb_Flags+1,a6) ;Close?
		beq     .notlast
		bsr     LExpunge                ;Yes: expunge
.notlast        rts

*-------------------------------------------------------*
* LExpunge      Expunge Lib                             *
*       -» A6.l ^LibBase                                *
*                                                       *
LExpunge        movem.l d7/a5-a6,-(SP)
	;-- Check state ------------------------;
		move.l  a6,a5
		move.l  (plb_SysLib,a5),a6
		tst     (LIB_OPENCNT,a5)        ;Are we still opened?
		beq     .expimmed
.abort          bset    #PLLB_DELEXP,(plb_Flags+1,a5)  ;Remember to expunge
		moveq   #0,d0                   ;But don't expunge yet
		bra     .exit
	;-- Lib will be expunged ---------------;
.expimmed       move.l  (plb_SegList,a5),d7     ;Get segment list
		move.l  a5,a1                   ;Remove from list
		exec    Remove
	;-- Perform own exit method ------------;
		jsr     _LibExit
	;-- Release memory ---------------------;
		moveq   #0,d0
		move.l  a5,a1
		move    (LIB_NEGSIZE,a5),d0
		sub.l   d0,a1
		add     (LIB_POSSIZE,a5),d0
		exec    FreeMem
	;-- Done -------------------------------;
		move.l  d7,d0
.exit           movem.l (SP)+,d7/a5-a6
		rts

*-------------------------------------------------------*       
* LNull         NOP                                     *
*                                                       *
LNull           moveq   #0,d0
		rts

*-------------------------------------------------------*
* Name:         CallRexxCmd                             *
*                                                       *
* Funktion:     ARexx call                              *
*                                                       *
* Parameter:    -» A0.l struct RexxMsg *                *
*               «- A0.l struct RexxArg *RESULT oder NUL *
*               «- D0.l RC                              *
* Register:     Not changed                             *
*                                                       *
* Bemerkungen:                                          *
*>                                                      *
* Revision:     1.0 (26. Oktober 1998, 00:38:04)        *
*                                                       *
CallRexxCmd     movem.l d1-d7/a1-a5,-(SP)
		pea     0.w                     ; Clear one long word on the stack
		move.l  SP,a1                   ; A1 points to this long
		jsr     _RexxCmd                ; Call RexxCmd
		move.l  (SP)+,a0                ; Put result into A0
		movem.l (SP)+,d1-d7/a1-a5
		rts
*<

EndCode:

		END OF SOURCE

*jEdit: :tabSize=8:indentSize=8:mode=assembly-m68k:
