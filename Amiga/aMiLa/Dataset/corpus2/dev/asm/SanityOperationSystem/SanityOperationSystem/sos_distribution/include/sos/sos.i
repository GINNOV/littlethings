; ===================================================================
;
;                                 S O S
;   
;                         Sanity Operating System
;
;                                 V 2.6
;
;
;                              Include-file
;
; ===================================================================

; ===================================================================
;
; Variations when assembling SOS:
;
; DEV        Development-Variation (restore Kickstart after demo)
; RUN        Runtime-Variante (kill Kickstart)
; DOSDISK    Use AmigaDos
; SOSDISK    Use hardware trackloader
; RAMDISK    Load all data into ram and use as ramdisk.
; LONGTRACK  use longtracks for trackloader
;
; Variations when assembling applications:
;
; HARDWARE   Your hardware base.
; DEBUG      Debug color-bars for timing.
; NORMBX     Right mousebutton will not stop demo. For ENV-macros.
; CHIPMEM    force all sections to chip if you use SEC-macros.
;
; ===================================================================


		IFD DEV			; set up defaults
		IFND	SOSDISK
		IFND	RAMDISK
DOSDISK		EQU	1
		ENDC
		ENDC
		ENDC

		IFD	RUN
		IFND	RAMDISK
SOSDISK		EQU	1
		ENDC
		ENDC

		IFD	DEV
		IFD	SOSDISK
HYB		equ	1
		ENDC
		ENDC

		IFND	LONGTRACK	; set up disk geometry.
DSK_Sectors	equ	11
DSK_SecMask	equ	$7ff
DSK_Lenght	equ	$3200
		ENDC
		IFD	LONGTRACK
DSK_Sectors	equ	12
DSK_SecMask	equ	$fff
DSK_Lenght	equ	$3ffe
		ENDC

; ===================================================================
;
;  Hardware-Register
;
; ===================================================================

	include	"include:sos/soshardware.i"

; ===================================================================
;
;  Konstanten
;
; ===================================================================

SOSVERSION	equ	2		; Version 
SOSREVISION	equ	6		; Revision 
SOSRELEASE	equ	13		; Release 

SOSTRUE		equ	-1		; TRUE: everything not 0
SOSFALSE	equ	0		; FALSE: 0
BTRUE		MACRO			; branch if true
		bne.s	\1
		ENDM
BFALSE		MACRO			; branch if false
		beq.s	\1
		ENDM

; ===================================================================
;
;  Equates
;
; ===================================================================

;
;  Memory aatributes
;

MAT_PUBLIC	equ	0		; Any memory
MAT_CHIP	equ	1		; ChipMem
MAT_SHORT	equ	2		; ShortMem (obsolete)
MAT_CLEAR	equ	$40		; Clear memory
MATb_CLEAR	equ	6

;
; Timer units
;

TI_MICRO	EQU	1		; microseconds
TI_MILI		EQU	2		; milliseconts


; ===================================================================
;
;  Public Info System Structure
;
; ===================================================================

; this structure holds information about SOS, the hardware and
; input from Mouse and Keyboard.

		RSRESET
PISS_TurboCPU:	RS.W	1		; CPU value(dezimal 00/10/20..)
PISS_TurboFPU:	RS.W	1		; FPU value
					; 0 = none
					; 1 = 68881 or 68882
					; 2 = 68040
PISS_TurboMMU:	RS.W	1		; MMU value
					; 0 = keine
					; 1 = PMMU
PISS_TurboVBR:	RS.L	1		; Vector-Basis-Register (VBR)
					; allways access exeption vectors
					; relative to this adresss!
PISS_Configur:	RS.W	1		; free for future extensions
PISS_Computer	RS.B	1		; Amiga, Atari (see below)
PISS_Level	RS.B	1		; OCS,ECS,AGA (see below)

; These variables can be used to read the amount of free memory.
; TopicMem and TotalMem point to "MemAgents" that hold the current
; and total memory size. Each MemAgent consists of "Chunks" chunks.
; each chunk countains the Start- and Endadress of the memory if
; controlls. the first "ChunksPublic" are of type "AnyMem", the others
; are ChipMemory.
; These information is only provided to allow the debugger to display
; the amount of free memory. Don't use it for other then diagnostic
; applications, because the way SOS handles it's memory might change 
; in future.

PISS_TopicMem:	RS.L	1		; Zeiger auf TopicMem
PISS_TotalMem:	RS.L	1		; Zeiger auf TotalMem
PISS_Chunks:	RS.B	1		; Anzahl Chunks insgesamt
PISS_ChunksPublic: RS.B	1		; Anzahl Public Chunks

; Now hardware dependent things:

PISS_Copper:	RS.L	1		; current Copper-Liste
PISS_BPLCON0:	RS.W	1		; Genlock-Value for BLTCON0

; More memory (V1.8)

PISS_DefaultMem: RS.L	1		; current MemNode

; Dos (v2.0)

PISS_Directory:	RS.L	1		; Pointer to directory

; Environment (2.1)

PISS_Environment: RS.L	1		; Environment-Variable

; Input (2.1)

PISS_Key:	RS.B	1		; KeyCode
					; If you have read a key with
					; GetKey() that you don't
					; need, you should write it 
					; back here. This will allow
					; the character to be read again.
					; This is my hopeless try to implement
					; some kind of simple input-handler.
PISS_pad00:	RS.B	1
PISS_LMB:	RS.B	1		; 1 = left button currently pressed
PISS_RMB:	RS.B	1		; 1 = right button currently pressed
PISS_LMBFlag:	RS.B	1		; 1 = left button has been pressed 
PISS_RMBFlag:	RS.B	1		; 1 = right button has been pressed
					; the last two flags are set by SOS
					; and must be reset by you after
					; reading.
PISS_MouseX:	RS.W	1		; maus X delta
PISS_MouseY:	RS.W	1		; maus Y delta

; Parameters (v2.2, Release 10)

PISS_Parameter:	RS.L	1		; New parameter passing since v2.2
					; points to an array of pointers
					; to parameter strings. end with 0

PISS_SIZEOF	EQU	__RS

; ===================================================================

PISSC_AMIGA	equ	1		; AMIGA
PISSC_ATARI	equ	2		; ATARI

; COMMODORE Amiga

PISSLC_OCS	equ	1		; original chip set
PISSLC_ECS	equ	2		; full enhaced chip sEt
PISSLC_AGA	equ	3		; AGA- chip set
PISSLC_AAA	equ	4		; AAA chip set

PISSFC_LARGEBLT	equ	$0001		; large blits possible (ECS blitter)

; ATARI ST

PISSLA_ST	equ	1		; ST
PISSLA_STE	equ	2		; STE
PISSLA_TT	equ	3		; TT
PISSLA_FALCON30	equ	4		; Falcon 030

PISSFA_BLITTER	equ	$0001		; Blitter available


; ===================================================================
;
;  Disk
;
; ===================================================================

					; Directory entry. 
					; should be private
RB_Block	EQU	0		; offset for first byte
RB_Lock		EQU	0		; directory lock
RB_Lenght	EQU	4		; length of file
RB_Name		EQU	8		; complete pathname relative to 
					; disk/lock.
RB_SIZEOF	EQU	32

; ===================================================================
;
;  Library-Struktur
;
; ===================================================================

		rsreset
LIB_Next	rs.l	1		; Nächste library in liste or 0
LIB_Name	rs.l	1		; Name literal of Library
					; NOT pointer, ULONG!
LIB_SIZEOF	rs.w	0

LIB_Pad0	EQU	-6		; must return 0
LIB_First	EQU	-12		; first free entry

; ===================================================================
;
;  Tags
;
; ===================================================================

STAG_DONE	equ	$80000000	; end of taglist
STAG_SKIP	equ	$80000001	; empty entry
STAG_MORE	equ	$80000002	; continue at position

STAGITEM	MACRO	; Tag,Value
		dc.l	\1,\2
		ENDM

; Never use STAGITEM for STAG_DONE, STAG_SKIP or STAG_MORE

STAGDONE	MACRO
		dc.l	STAG_DONE,0
		ENDM



; ===================================================================
;
;  SOS-Library
;
; ===================================================================

_LASTOFFSET	equ	-366
_AltKick	equ	-360
_ResetRand	equ	-354
_AltMemory	equ	-348
_InitAltMemory	equ	-342
_SetIntDev	equ	-336
_ModDefault	equ	-330
_CheckForFile	equ	-324
_ScanTagList	equ	-318
_OpenLibrary	equ	-312
_SetIntFast	equ	-306
_FreeMem	equ	-300
_ReLoad		equ	-294
_UnfinishedIrq	equ	-288
_GetPISS	equ	-282
_RemoveRamDisk	equ	-276
_LoadSegMem	equ	-270
_LoadDecrunch	equ	-264
_InitDiskPrefetch equ	-258
_PrefetchDisk	equ	-252
_CauseTimer	equ	-246
_WaitTimer	equ	-240
_MotorOff	equ	-234
_Save		equ	-228
_GetFilePos	equ	-222
_Seek		equ	-216
_Close		equ	-210
_Read		equ	-204
_Open		equ	-198
_GetKey		equ	-192
_CheckRelease	equ	-186
_PutScreen	equ	-180
_OpenScreen	equ	-174
_CloseScreen	equ	-168
_Fade		equ	-162
_SetCopperCol	equ	-156
_PPDecrunch	equ	-150
_DoubleBuffer	equ	-144
_LastRand	equ	-138
_FastRand	equ	-132
_FirstRand	equ	-126
_Randomize	equ	-120
_SetCopperAdr	equ	-114
_Error		equ	-108
_ClrDefault	equ	-102
_SetDefault	equ	-096
_ClrInt		equ	-090
_SetInt		equ	-084
_FileLength	equ	-078
_LoadSeg	equ	-072
_Load		equ	-066
_MemType	equ	-060
_FreeAll	equ	-054
_AllocBlock	equ	-048
_AllocMem	equ	-042
_BailOut	equ	-036
_StartIt	equ	-030

; ===================================================================
;
;  Trap13 Calls
;
; ===================================================================

T13_DataOn	equ	0		; Low Level, do not use
T13_InstOn	equ	1
T13_DataOff	equ	2
T13_InstOff	equ	3
T13_DataFlush	equ	4
T13_ModFlush	equ	5		; High Level Flushs
T13_PreDMA	equ	6
T13_PostDMA	equ	7
T13_Standard	equ	8		; High Level Setups
T13_Paranoid	equ	9
T13_BigTable	equ	10
T13_SetAll	equ	11		; INTERN !!!

; ===================================================================
;
;  Tastatur
;
; ===================================================================

; more information about these in AutoDoc GetKey()

ASC_SAE		equ	24
ASC_SOE		equ	25
ASC_SUE		equ	26
ASC_AE		equ	27
ASC_OE		equ	28
ASC_UE		equ	29
ASC_SZ		equ	30
ASC_APO		equ	96
ASC_CUP		equ	128
ASC_CDOWN	equ	129
ASC_CLEFT	equ	130
ASC_CRIGHT	equ	131
ASC_BACKSPACE	equ	132
ASC_DELETE	equ	133
ASC_INSERT	equ	134
ASC_HELP	equ	135
ASC_RETURN	equ	136
ASC_ESCAPE	equ	137
ASC_TAB		equ	138
ASC_SRETURN	equ	139
ASC_SCUP	equ	140
ASC_SCDOWN	equ	141
ASC_SCLEFT	equ	142
ASC_SCRIGHT	equ	143
ASC_F1		equ	144
ASC_F2		equ	145
ASC_F3		equ	146
ASC_F4		equ	147
ASC_F5		equ	148
ASC_F6		equ	149
ASC_F7		equ	150
ASC_F8		equ	151
ASC_F9		equ	152
ASC_F10		equ	153
ASC_SESCAPE	equ	154
ASC_SHELP	equ	155
ASC_KEYUP	equ	156

; ===================================================================
;
;  Startup-Macros
;
; ===================================================================

******* sos.library/INITSOS ************************************************
*
*   NAME
*	INITSOS -- Header for SOS-Programme
*
*   SYNOPSIS
*	INITSOS  Start         (Macro)
*	INITSOS2 Start         (Macro)
*
*   FUNCTION
*	Createa an SOS-Header as needed for SLOAD, SLOADHYB, 
*	the trackdisk loader and the executable driver.
*
*	One of these macros must be used at the beginning
*	of each SOS-program.
*
*	The INITSOS macro is much smaller then the INITSOS2 macro.
*
*	INITSOS will be sufficient for starting demos with SLOAD and
*	similar utilities.
*
*	INITSOS2 has the additional feature of a Shell/Workbench start.
*	When started from Shell or Workbench the sos.library will be 
*	loaded automatically and the functionality of SLOAD is
*	build in.
*
*   INPUTS
*	Start  - Startadress of your code.
*
*   BUGS
*
****************************************************************************

	IFND	ATARI

INITSOS	MACRO
	moveq	#-1,d0
	rts
	nop
	jmp	\1
	dc.b	'sos',0
	ENDM

INITSOS2	MACRO
	jmp	\@1			; Standart Start
	jmp	\1
	dc.b	'sos',0

\@1	move.l	4.w,a6
	move.l	a0,a3

	move.l	$114(a6),a4		; save TaskPtr
	tst.l	$AC(a4)			; CLI start?
	bne.s	\@CLI			; yes->

	lea	$5c(a4),a0		; Wait for workbench message
	JSR	-384(a6)		; WaitPort
	lea	$5c(a4),a0		; and reply it...
	JSR	-372(a6)		; GetMsg
	move.l	d0,\@WBMsg
	bra.s	\@WBend

\@CLI	lea	\@Args(pc),a2		; a2 = Ziel
	moveq	#9,d0			; d0 = MaxArgCnt
.loop	cmp.b	#32,(a3)+		; überlese Spaces
	beq.s	.loop			; <32 = ende
	blo.s	.end
	subq.l	#1,a3			; schreibe
	move.l	a3,(a2)+
.loop2	cmp.b	#32,(a3)+		; lese bis nächstes Space
	blo.s	.end
	bne.s	.loop2
	clr.b	-1(a3)			; schreibe Endemarkierun
	dbf	d0,.loop		; nächsten eintrag
.end	clr.b	-1(a3)

\@WBend	lea	\@lib(pc),a1		; Open sos.library
	moveq	#0,d0
	move.l	4.w,a6
	jsr	-552(a6)
	tst.l	d0
	beq.s	\@end
	move.l	d0,a6			; KillSystem
	move.l	a6,-(a7)
	lea	\@Code,a0
	jsr	_StartIt(a6)
	move.l	(a7)+,a1		; Close sos.library
	move.l	4.w,a6
	jsr	-414(a6)

\@end	move.l	\@WBMsg(pc),d2		; Was it a CLI/Shell start?
	beq.s	\@cli2			; yes->

	move.l	4.w,a6			; WB cleanup
	JSR	-132(a6)		; Forbid
	move.l	d2,a1			; reply workbench message
	JSR	-378(a6)		; ReplyMsg

\@cli2	moveq	#0,d0			; Dos-Ende
	rts

\@Code	jsr	_GetPISS(a6)		; Setze Args
	lea	\@Args(pc),a1
	move.l	a1,PISS_Parameter(a0)
	jmp	\1

\@WBMsg	dc.l	0
\@Args	dcb.l	11,0			; 10 Argumente und 0
\@lib	dc.b	'sos.library',0
	even

	ENDM

	ENDC


; ===================================================================
; ===================================================================
;
;  Atari-Stuff
;
; ===================================================================
; ===================================================================


	IFD	ATARI

; ===================================================================
;
;  Interrupt-Struktur
;
; ===================================================================


		rsreset
INT_VBL		rs.l	1	; VBL muß initialisiert sein!
INT_HBL		rs.l	1	; wer will, kann.
INT_TimerB	rs.l	1	; mal sehn was dies mal wird.
INT_SIZEOF	rs.w	0


	ENDC
