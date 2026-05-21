**
** PdaLink -- Connect Palm with Amiga
**
** Copyright (C) 1998-2010 Richard "Shred" Körber
**   http://pdalink.shredzone.org
**
** This library is free software: you can redistribute it and/or
** modify it under the terms of the GNU Lesser General Public
** License as published by the Free Software Foundation, either
** version 3 of the License, or (at your option) any later version.
**
** This library is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
** Lesser General Public License for more details.
**
** You should have received a copy of the GNU Lesser General Public
** License along with this library.  If not, see <http://www.gnu.org/licenses/>.
**
 
		IFND    LIBRARIES_PDALINK_I
LIBRARIES_PDALINK_I     SET     1

		IFND    EXEC_TYPES_I
		INCLUDE 'exec/types.i'
		ENDC

		IFND    UTILITY_TAGITEM_I
		INCLUDE utility/tagitem.i
		ENDC

**--------------------------------------------------------------**
** Generic library informations
**
PDALINKNAME     MACRO
		dc.b    "pdalink.library",0
		ENDM

PDALINKVERSION EQU     2

**--------------------------------------------------------------**
**    Tags
**
PLTAG_BASE              EQU     $8FEA0000       ; Base for all TagItems
PLTAG_ErrorPtr          EQU     PLTAG_BASE+$00  ; Pointer to LONG for error code result
PLTAG_SerialDevice      EQU     PLTAG_BASE+$01  ; Device name
PLTAG_SerialUnit        EQU     PLTAG_BASE+$02  ; Device unit nr.
PLTAG_SerialMaxRate     EQU     PLTAG_BASE+$03  ; Maximum baud rate
PLTAG_SerialTimeout     EQU     PLTAG_BASE+$04  ; Timeout (seconds)
PLTAG_AbortMask         EQU     PLTAG_BASE+$05  ; Signal mask for abortion, e.g. CTRL-C


**--------------------------------------------------------------**
**    Desktop Link Protocol
**
;--- System Time ---
    STRUCTURE DLP_SysTime,0
	UWORD   dlpst_year              ; Year
	UBYTE   dlpst_month             ; Month
	UBYTE   dlpst_day               ; Day
	UBYTE   dlpst_hour              ; Hour
	UBYTE   dlpst_minute            ; Minute
	UBYTE   dlpst_second            ; Second
	UBYTE   dlpst_pad               ; (always SET to 0)
	LABEL   dlpst_SIZEOF

;--- RAM/ROM card info ---
    STRUCTURE DLP_StorageInfo,0
	UWORD   dlpsi_cardVersion       ; Version
	STRUCT  dlpsi_creationDate,dlpst_SIZEOF ; Creation date
	ULONG   dlpsi_ROMSize           ; Size of ROM
	ULONG   dlpsi_RAMSize           ; Size of RAM
	ULONG   dlpsi_RAMFree           ; Free RAM
	STRUCT  dlpsi_name,128          ; Card name
	STRUCT  dlpsi_manuf,128         ; Card manufacturer
	UBYTE   dlpsi_cardNo            ; Card No.
	UBYTE   dlpsi_more              ; BOOL: more cards?
	LABEL   dlpsi_SIZEOF

;--- System Info ---
    STRUCTURE DLP_SysInfo,0
	ULONG   dlpsy_romVer            ; ROM Version
	ULONG   dlpsy_locale            ; Localizion code
	STRUCT  dlpsy_name,128          ; System name
	LABEL   dlpsy_SIZEOF

;--- User Info ---
    STRUCTURE DLP_UserInfo,0
	ULONG   dlpui_userID
	ULONG   dlpui_viewerID
	ULONG   dlpui_lastSyncPC
	STRUCT  dlpui_successfulSync,dlpst_SIZEOF
	STRUCT  dlpui_lastSync,dlpst_SIZEOF
	STRUCT  dlpui_userName,128
	STRUCT  dlpui_password,128
	LABEL   dlpui_SIZEOF

;--- Netsync Info ---
    STRUCTURE DLP_NetSyncInfo,0
	UWORD   dlpns_lanSync
	STRUCT  dlpns_hostName,256
	STRUCT  dlpns_hostAddress,40
	STRUCT  dlpns_hostSubnetMask,40
	LABEL   dlpns_SIZEOF

;--- Database Info ---
    STRUCTURE DLP_DBInfo,0
	UBYTE   dlpdi_more              ; BOOL: more databases?
	UBYTE   dlpdi_excludes          ; Exclude flags, see below
	UWORD   dlpdi_flags             ; Entry flags, see below
	ULONG   dlpdi_type              ; Type ID
	ULONG   dlpdi_creator           ; Creator ID
	UWORD   dlpdi_version           ; Version
	ULONG   dlpdi_modnum            ; Modification Number
	STRUCT  dlpdi_createDate,dlpst_SIZEOF   ; Creation date
	STRUCT  dlpdi_modifyDate,dlpst_SIZEOF   ; Last modification
	STRUCT  dlpdi_backupDate,dlpst_SIZEOF   ; Last backup
	UWORD   dlpdi_index             ; Index
	STRUCT  dlpdi_name,34           ; Entry name
	LABEL   dlpdi_SIZEOF

;--- GetDBInfo flags ---
DLPGDBF_RAM             EQU     $80     ; List RAM entries only
DLPGDBF_ROM             EQU     $40     ; List ROM entries only

;--- DBInfo excludes ---
DLPDBIE_EXCLUDESYNC     EQU     $80     ; Exclude from Sync

;--- DBInfo flags ---
DLPDBIF_RESOURCE        EQU     $0001   ; DB Resource (not a record)
DLPDBIF_READONLY        EQU     $0002   ; Read only
DLPDBIF_APPINFODIRTY    EQU     $0004   ; AppInfo has been modified
DLPDBIF_BACKUP          EQU     $0008   ; Generic backup
DLPDBIF_NEWER           EQU     $0010   ; Newer may replace older in open DB
DLPDBIF_RESET           EQU     $0020   ; Reset after installation
DLPDBIF_OPEN            EQU     $8000   ; Currently opened

;--- DB Attribute ---
DLPDBAT_DELETED         EQU     $80     ; Deleted
DLPDBAT_DIRTY           EQU     $40     ; Changed since last sync
DLPDBAT_BUSY            EQU     $20     ; Currently locked
DLPDBAT_SECRET          EQU     $10     ; Private entry
DLPDBAT_ARCHIVE         EQU     $08     ; To be archived on next sync

;--- DB Open flags ---
DLPDBOF_READ            EQU     $80     ; Open for reading
DLPDBOF_WRITE           EQU     $40     ; Open for writing
DLPDBOF_EXCLUSIVE       EQU     $20     ; Do not share
DLPDBOF_SECRET          EQU     $10     ; Private entry
DLPDBOF_READWRITE       EQU     $C0



**--------------------------------------------------------------**
**    Connection Management Protocol
**

;--- CMP structure ---
    STRUCTURE PL_CMP,0
	UBYTE   plcmp_type              ; CMP message type
	UBYTE   plcmp_flags             ; Some flags
	UWORD   plcmp_version           ; Version code
	WORD    plcmp_reserved          ; 0 for now
	ULONG   plcmp_baudrate          ; Wakeup: maximum rate
					; Init: connection rate
	LABEL   plcmp_SIZEOF

;--- CMP Types ---
PLCMP_WAKEUP            EQU     1       ; Wakeup
PLCMP_INIT              EQU     2       ; Init connection
PLCMP_ABORT             EQU     3       ; Abort connection

;--- CMP Flags ---
PLCMPF_CHANGEBAUD       EQU     $80     ; Init: change baud rate



**--------------------------------------------------------------**
**    Packet Assembly Disassembly Protocol
**

;--- PADP Header structure ---
    STRUCTURE PL_PADP_Header,0
	UBYTE   plpah_type              ; Type of Packet
	UBYTE   plpah_flags             ; Flags
	UWORD   plpah_size              ; Size of data
	LABEL   plpah_SIZEOF            ; Data follows here

;--- PADP Types ---
PLPADP_DATA             EQU     $01     ; Plain Data
PLPADP_WAKE             EQU     $101    ; Wakeup, used by CMP
PLPADP_ACK              EQU     $02     ; Acknowledge
PLPADP_TICKLE           EQU     $04     ; Tickle
PLPADP_ABORT            EQU     $08     ; Abort (PalmOS 2.0 only)

;--- PADP Flags ---
PLPADPF_FIRST           EQU     $80     ; First packet
PLPADPF_LAST            EQU     $40     ; Last packet
PLPADPF_MEMERROR        EQU     $20     ; Receiver has not enough memory



**--------------------------------------------------------------**
**    Serial Link Protocol
**

;--- SLP Header structure ---
    STRUCTURE PL_SLP_Header,0
	STRUCT  plslp_signature,3       ; (will be SET by pdalink.library)
	UBYTE   plslp_destSocket        ; Destination Socket ID
	UBYTE   plslp_srcSocket         ; Source Socket ID
	UBYTE   plslp_pckType           ; Packet Type
	UWORD   plslp_dataSize          ; (will be SET by pdalink.library)
	UBYTE   plslp_transID           ; Current transaction ID
	UBYTE   plslp_checksum          ; (calculated by pdalink.library)
	LABEL   plslp_SIZEOF

;--- SLP Socket IDs ---
PLSLPSOCK_DEBUG         EQU     0       ; Debugger
PLSLPSOCK_CON           EQU     1       ; Console
PLSLPSOCK_RUI           EQU     2       ; Remote User Interface
PLSLPSOCK_DLP           EQU     3       ; Desktop Link Protocol

;--- SLP Packet Types ---
PLSLPTYPE_RDCP          EQU     0       ; Remote Debugger / Console
PLSLPTYPE_PADP          EQU     2       ; Packet Assembler Disassembler
PLSLPTYPE_LOOP          EQU     3       ; Loopback



**--------------------------------------------------------------**
**    Error Codes
**

;--- PdaLink errors ---
PLERR_OKAY              EQU     0       ; No error occured
PLERR_NOMEM             EQU     -1      ; Not enough memory
PLERR_NORESOURCE        EQU     -2      ; A resource is allocated
PLERR_SERIAL            EQU     -3      ; Some serial error
PLERR_TIMEOUT           EQU     -4      ; Connection timeout
PLERR_CHECKSUM          EQU     -5      ; Data checksum error
PLERR_REMOTENOMEM       EQU     -6      ; Remote has not enough memory
PLERR_BADPACKET         EQU     -7      ; Got an unexpected packet
PLERR_NOTCOMPATIBLE     EQU     -8      ; Connection not compatible
PLERR_BADBAUD           EQU     -9      ; No fitting Baud rate found
					; If you should get this one, try
					; to lower PLTAG_SerialMaxRate.
					; 9600 should work in any case,
					; except you have a very wierd
					; multi serial board.
PLERR_DOSERROR          EQU     -10     ; DOS error, see IoErr()
PLERR_OS2REQUIRED       EQU     -11     ; PalmOS2.0 or higher is required
					; to use this function
PLERR_TOOLARGE          EQU     -12     ; Data buffer is too large (>64KB)
PLERR_ABORTED           EQU     -13     ; Aborted by abortion signal

;--- DLP errors ---
PLERR_GENERAL           EQU     1       ; General system error
PLERR_ILLEGALFCT        EQU     2       ; Illegal function
PLERR_DLPNOMEM          EQU     3       ; Out of memory
PLERR_INVPARAM          EQU     4       ; Invalid parameter
PLERR_NOTFOUND          EQU     5       ; Not found
PLERR_NONEOPEN          EQU     6       ; None opened
PLERR_ALREADYOPEN       EQU     7       ; Already opened
PLERR_TOOMANYOPEN       EQU     8       ; Too many are opened
PLERR_ALREADYEXIST      EQU     9       ; Already exists
PLERR_CANTOPEN          EQU     10      ; Can't open
PLERR_RECDELETED        EQU     11      ; Record deleted
PLERR_RECBUSY           EQU     12      ; Record busy
PLERR_UNSUPPORTED       EQU     13      ; Operation not supported
PLERR_READONLY          EQU     15      ; Read only
PLERR_NOSPACE           EQU     16      ; Not enough space
PLERR_EXCEEDED          EQU     17      ; Limit exceeded
PLERR_CANCELLED         EQU     18      ; Sync cancelled
PLERR_BADARG            EQU     19      ; Bad argument wrapper
PLERR_ARGMISSING        EQU     20      ; Argument is missing
PLERR_ARGSIZE           EQU     21      ; Bad argument size


		ENDC
******************************************************************

*jEdit: :tabSize=8:indentSize=8:mode=assembly-m68k:
