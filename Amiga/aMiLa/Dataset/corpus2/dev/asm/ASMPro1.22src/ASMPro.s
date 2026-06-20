******************************************************
*
* Project	: Asm-Pro (OpenSource Edition)
* Start Date	: 30-Dec-1996
* Author	: Solo/GeNeTiC
*
* Binary Version: 1.22
* Source Version: 1.22 (opensource release)
* Project	: Asm-Pro (OpenSource Edition)
*
* Updates/People contributing to the opensource release:
*
* 24-Dec-2025 : v1.22
* 21-Dec-2024 : v1.21
* 22-Dec-2023 : v1.20b
* 27-Dec-2022 : v1.19
* - amigo/binary
*
* 05-april-2012 : v1.18 (Apollo edition)
* - Rune Stensland (SP)
*
* 02-May-2005	: v1.17
* - Franck "Flasher Jack" Charlet
*
* 24-Feb-2001	: v1.16i0
* - Aske Simon Christensen aka Blueberry
* - Franck "Flasher Jack" Charlet
*
* 04-Feb-2001	: v1.16h
* - Boussh/TFA
* - Franck "Flasher Jack" Charlet
* - Solo
*
* 08-Aug-2000	: v1.16g
* - Aske Simon Christensen aka Blueberry
* - Solo
*
* 04-Mar-2000	: v1.16f (Initial Source release date)
* - Solo
*
* Check the Asm-Pro_History.txt for changes..
*
* JOIN OUR ASM-PRO DEV MAILING LIST NOW! 
* Coordinate the efforts on the development of Asm-Pro.
*
* Subscribe: Asmpro_dev-subscribe@yahoogroups.com 
* URL to discussion page: http://groups.yahoo.com/group/Asmpro_dev
*
******************************************************

*****************
*** Constants ***
*****************
FALSE	= 0
TRUE	= 1

SPEC_ED		= TRUE		; special edition without extra graphics
Debugstuff	= FALSE		; Use this option to activate debug window
				; insert a
				;	jsr	test_debug
				; statement where you like in de source and
				; it will pop up a requester with all address
				; and data regs when you assemble and run the
				; new exe file..
				;
				; the executable will also use a different asmpro
				; prefs file when activated.

PPC			= FALSE		; (not finished)
MC020			= FALSE
useplugins		= FALSE		; (not finished)
SLIDER			= FALSE		; (not finished)
MEMSEARCH		= TRUE
CLIPBOARD		= FALSE		; (not finished)
INCLINK			= TRUE

MAX_REPT_LEVEL		=	50	; 10
MAX_INCLUDE_LEVEL 	=	20	; 10
MAX_CONDITION_LEVEL 	=	100	; 20
MAX_MACRO_LEVEL		=	100	; 25

MAX_STACK_SIZE		=	16*1024	; asm-pro's stack size

	TTL	"Asm-Pro by Genetic"
	IDNT 	"Asm_Pro by Genetic"

	PRINTT	"Asm-Pro OpenSource Edition (c)1996/2005 brought to you by Solo/Genetic.."


**************************
*** Externals includes ***
**************************
	incdir	"include:"
	include	"exec/execbase.i"
	include	"exec/tasks.i"
	include	"exec/memory.i"
	include	"workbench/startup.i"
	include	"intuition/screens.i"
	include	"libraries/gadtools.i"
	include	"libraries/asl.i"
	include	"libraries/reqtools.i"
	include	"devices/keymap.i"
	include	"lvo/reqtools_lib.i"
	include	"lvo/exec_lib.i"
	include	"lvo/dos_lib.i"
	include	"lvo/intuition_lib.i"
	include	"lvo/graphics_lib.i"
	include	"lvo/gadtools_lib.i"
	include	"lvo/asl_lib.i"
	include "lvo/mathffp_lib.i"
	include "lvo/mathtrans_lib.i"
	include "lvo/keymap_lib.i"
	include "lvo/console_lib.i"
	include "lvo/diskfont_lib.i"
	include "lvo/amigaguide_lib.i"
	include "lvo/timer_lib.i"
	include	"devices/clipboard.i"

VERSION_MAJOR	EQU	1
VERSION_MINOR	EQU	22
SUBVERSION	EQU	''		; empty string if none

VERSION_STR	MACRO
	DC.B	'V','0'+VERSION_MAJOR,'.'
	IFGE	VERSION_MINOR-10
	DC.B	'0'+VERSION_MINOR/10
	ENDIF
	DC.B	'0'+VERSION_MINOR-(VERSION_MINOR/10)*10
	IFNE	SUBVERSION
	DC.B	SUBVERSION
	ENDIF
	IFNE	SPEC_ED
	DC.B	' SE'
	ENDIF
	ENDM

INSERT_DEBUG	MACRO		; trashes d0/d1/a0
	btst	#AF_DEBUG,d7
	beq.b	.NO_DEBUG\@
	tst.w	d7		; pass1?
	bmi.b	.NO_DEBUG\@
	move.l	(LabelEnd-DT,a4),a0
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),d0
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),d0
	move.l	(DATA_CURRENTLINE-DT,a4),d1
	IF	MC020
	move.l	d0,(-4,a0,d1.l*4)
	ELSE
	lsl.l	#2,d1
	move.l	d0,(-4,a0,d1.l)
	ENDIF
.NO_DEBUG\@
	ENDM

DSIZE			=	128	; directory buffer
FCHARS			=	30	; filename
MAX_BRK_PTRS		=	16

COMMANDLINECACHESIZE	EQU	128	; how many cmds to store, 2^n!
COMMANDLINEBUFFERCACHE	EQU	COMMANDLINECACHESIZE*64	; in bytes

USERPRG_STACK_SIZE	EQU	4096	; user program's user/sv stack

;menu_type
MT_COMMAND		=	0
MT_EDITOR		=	1
MT_MONITOR		=	2
MT_DEBUGGER		=	3

SRCMARK_BEGIN		EQU	$19
SRCMARK_END		EQU	$1a

;SomeBits
SB1_SOURCE_CHANGED	EQU	0
SB1_WINTITLESHOW	EQU	1
SB1_CLOSE_FILE		EQU	2
SB1_MOUSE_KLIK		EQU	3
SB1_SEARCHBUF_NE	EQU	4
SB1_REPLACE_GLOB	EQU	5
SB1_REPLACE_ONE		EQU	6
SB1_CHANGE_MODE		EQU	7

;SomeBits2
;SB2_ONEPLANE		EQU	0
SB2_REVERSEMODE		EQU	1
SB2_OUTPUTACTIVE	EQU	2
SB2_INSERTINSOURCE	EQU	3
SB2_INDEBUGMODE		EQU	4
SB2_MATH_XN_OK 		EQU	5
SB2_A_XN_USED		EQU	6
SB2_MAKEMACRO		EQU	7

;SomeBits3
;SB3_CHGCONFIG		EQU	0	; obsolete toggles in the prefs menu
SB3_REPORT_ERROR	EQU	1
SB3_COMMANDMODE		EQU	2	; in commandline
SB3_SPEC_KEYS		EQU	3

;MyBits
MB1_LINE_NOT_IN_SOURCE		EQU	0
MB1_DRUK_IN_MENUBAR		EQU	1
MB1_BACKWARD_SELECT		EQU	2
MB1_EDITCMDLINE			EQU	3
;MB1_COMMENTAAR			EQU	4
MB1_BLOCKSELECT			EQU	5
MB1_PPC_ASM			EQU	6
MB1_INCOMMANDLINE		EQU	7

;Syntax colors bits (ScBits)
SC1_NOTBEGINLINE		EQU	0
SC1_COMMENTAAR			EQU	1
SC1_LABEL			EQU	2
SC1_OPCODE			EQU	3
SC1_WHITESP			EQU	4

;ScWord - color of the text
SC2_NORMAAL			EQU	0*4
SC2_COMMENTAAR			EQU	1*4
SC2_LABEL			EQU	2*4
SC2_OPCODE			EQU	3*4


;D7 Assembler FLAG's

AF_OPTIMIZE	=  0	;$00000001
AF_BRATOLONG	=  1	;$00000002
AF_UNDEFVALUE	=  2	;$00000004
AF_BSS_AREA	=  3	;$00000008
AF_BYTE_STRING	=  4	;$00000010

AF_MACRO_END	=  6	;$00000040
AF_FINISHED	=  7	;$00000080
AF_LOCALFOUND	=  8	;$00000100
AF_LABELCOL	=  9	;$00000200
AF_MACROS_OFF	= 10	;$00000400
AF_GETLOCAL	= 11	;$00000800
AF_EXTERN_ASM	= 12	;$00001000
AF_INC_ASSIGN	= 13	;$00002000	; include path fallback

AF_PASSONE	= 15	;$00008000

AF_QREPT	= 22	;$00400000	; qrept if set, rept otherwise
AF_MODULO	= 23	;$00800000	; operator modulo //
AF_PROCESRWARN	= 24	;$01000000
AF_SEMICOMMENT	= 25	;$02000000
AF_OFFSET	= 26	;$04000000
AF_OFFSET_A4	= 27	;$08000000	; basereg
AF_ALLERRORS	= 28	;$10000000
AF_LISTFILE	= 29	;$20000000
AF_DEBUG	= 30	;$40000000
AF_IF_FALSE	= 31	;$80000000

NS_AVALUE	= $61
NS_ALABEL	= $62
;NS_ROLLEFT	= $63
;NS_ROLRIGHT	= $64

LB_CONSTANT	= $0000
LB_MACRO	= $8000
LB_SET		= $8100
LB_XREF		= $8200
LB_EQUR		= $8300
LB_REG		= $8400
LB_PASS2BIT	= 14

PB_000		= $0000
PB_010		= $0001
PB_020		= $0002
PB_030		= $0003
PB_040		= $0004
PB_060		= $0005
PB_APOLLO	= $0006

PB_NOT		= 1<<6
PB_ONLY		= 1<<7
PB_851		= 1<<14
PB_MMU		= 1<<15
PB_FPU		= -1


;**  Parser stuff  **

; Return format:

; d1 contains addressing mode.
; Standard format:
;   ssmmmrrr
;   size, mode, register

;  Syntax     Mode  Reg     D5
;-------------------------------
;   Dn         000   Dn      0
;   An         001   An      1
;  (An)        010   An      2
;  (An)+       011   An      3
; -(An)        100   An      4
; xxxx(An)     101   An      5
; xx(An,Xn)    110   An      6
;  xxxx.W      111   000     7
; xxxxxxxx.L   111   001     8
;   #data      111   100     9
; xxxx(PC)     111   010     11
; xx(PC,Xn)    111   011     12
; SR  CCR                    13
; USP                        14
; D0/D1                      15

M_Dx		= $0000		; 0
M_Ax		= $0001		; 1
M_AxInd		= $0002		; 2
M_AxInc		= $0004		; 3
M_AxDec		= $0008		; 4
M_AxDisp	= $0010		; 5
M_AxIdx		= $0020		; 6
M_AbsW		= $0040		; 7
M_AbsL		= $0080		; 8
M_Imm		= $0100		; 9
M_PcDisp	= $0400		;11
M_PcIdx		= $0800		;12
M_SrCcr		= $1000		;13
M_Usp		= $2000		;14
M_Movem		= $4000		;15
M_unused	= $8200

; int operand sizes: .B $00, .W $40, .L $80, none/default $8040

; Levels:
; 1:  Compare >,<,>=,<=,=
; 2:  Add,Sub (+  -)
; 3:  Mult,Divi  * /
; 4:  Logical AND/OR/EOR  & ! ~
; 5:  L/R Shift  << >> ^
; 6:  Monadic - Logical ~
		RSSET	1
MATH_COMPARE	RS.B	1	; 1
MATH_ADDSUB	RS.B	1	; 2
MATH_MULDIV	RS.B	1	; 3
MATH_ANDOREOR	RS.B	1	; 4
MATH_SHIFTPOT	RS.B	1	; 5
MATH_MONADIC	RS.B	1	; 6

****************************************************************************

	SECTION	AsmPro_Startup,CODE

ProgStart:
	move.l	(4).w,a6

	move.l	a0,a2				; cmdline ptr
	move.l	(ThisTask,a6),a3
	lea	(Variable_base),a4

	moveq	#0,d5				; wbmsg
	tst.l	(pr_CLI,a3)
	bne.b	.FromCLI
.FromWB
	lea	(pr_MsgPort,a3),a0
	jsr	(_LVOWaitPort,a6)
	lea	(pr_MsgPort,a3),a0
	jsr	(_LVOGetMsg,a6)
	move.l	d0,d5
.FromCLI
	lea	(DosLibName,pc),a1
	jsr	(_LVOOldOpenLibrary,a6)
	move.l	d0,a5

	exg	a5,a6				; to doslib
	cmp.w	#37,(LIB_VERSION,a6)		; KS2.04+
	bhs.b	HaveKS2

	jsr	(_LVOOutput,a6)
	move.l	d0,d1
	beq.b	.NoOutput			; if started from wb
	lea	(NeedKS2Msg,pc),a0
	move.l	a0,d2
	moveq	#NeedKS2Msg\.End-NeedKS2Msg,d3
	jsr	(_LVOWrite,a6)
.NoOutput
	bra.b	LoaderExit

HaveKS2:
	move.w	(AttnFlags,a5),d0		; cpu/fpu flags
	bsr.b	OneTimeInit

	tst.l	d5
	bne.b	.FromWB
.FromCLI
	clr.l	(KeyboardInOutBuffs-DT,a4)
	move.l	a2,a0				; parse cmdline
	jsr	(DATAFROMSTART)

;.GetCurrDir
	moveq	#0,d1
	jsr	(_LVOCurrentDir,a6)
	move.l	d0,-(sp)
	move.l	d0,d1
	jsr	(_LVOCurrentDir,a6)
	move.l	(sp)+,d1
	bra.b	.LockCurrDir

.FromWB
	move.l	d5,a0				; startup wbmsg
	move.l	(sm_ArgList,a0),a0
	move.l	(a0),d1				; ArgList[0].wa_Lock (currdir)

.LockCurrDir
	jsr	(_LVODupLock,a6)
	move.l	d0,(CurrentDir-DT,a4)

	lea	(AsmPro.MSG-DT,a4),a0
	move.l	a0,d1
	moveq	#0,d2				; normal priority
	lea	(ProgStart-4,pc),a0
	move.l	(a0),d3				; seglist
	clr.l	(a0)				; unlink us from seglist

	move.l	#MAX_STACK_SIZE,d4
	cmp.l	(pr_StackSize,a3),d4
	bhs.s	.StackSizeOK
	move.l	(pr_StackSize,a3),d4
.StackSizeOK
	move.l	d4,(_StackSize-DT,a4)

	jsr	(_LVOCreateProc,a6)

LoaderExit:
	exg	a5,a6				; to execlib
	move.l	a5,a1
	jsr	(_LVOCloseLibrary,a6)

	tst.l	d5
	beq.b	.NoWbMsg
	jsr	(_LVOForbid,a6)
	move.l	d5,a1
	jsr	(_LVOReplyMsg,a6)
.NoWbMsg
	moveq	#0,d0
	rts

OneTimeInit:	; d0 = attn flags
	lea	(ConvTabel3,pc),a0
	move.l	a4,a1
	moveq	#128/4-1,d1
.Copy	move.l	(a0)+,(a1)+
	dbf	d1,.Copy
	moveq	#128/4-1,d1
.Clr	clr.l	(a1)+
	dbf	d1,.Clr

	IF	Debugstuff
	move.w	#(EndVarBase-Variable_base-256)/4-1,d1
.ClrBss	clr.l	(a1)+
	dbf	d1,.ClrBss
	ENDIF

	lea	(ProcessIOPtrs-DT,a4),a0
	move.l	(pr_CIS,a3),(a0)+		; store i/o info while we are
	move.l	(pr_COS,a3),(a0)+		;  still running (child process
	move.l	(pr_CLI,a3),(a0)		;  will inherit this)

	; *** Retrieve processor infos
	moveq	#PB_060,d1
	btst	#7,d0
	bne.b	.cputype
	moveq	#PB_040,d1
	btst	#3,d0
	bne.b	.cputype
	moveq	#PB_030,d1
	btst	#2,d0
	bne.b	.cputype
	moveq	#PB_020,d1
	btst	#1,d0
	bne.b	.cputype
	moveq	#PB_010,d1
	btst	#0,d0
	bne.b	.cputype
	moveq	#PB_000,d1
.cputype:
	move	d1,(ProcessorType-DT,a4)
	; *** The system doesn't report
	; the presence of the builtin FPU when it finds a 040 or 060.
	; So force it as a 68882.
;	cmp.b	#PB_040,d1
;	beq.b	Force_FPU
;	cmp.b	#PB_060,d1
;	bne.b	No_68040
;Force_FPU:
;	bset	#4,d0
;	bset	#5,d0
;No_68040:
	moveq	#0,d1
	btst	#4,d0
	beq.b	.fputype
	moveq	#1,d1
	btst	#5,d0
	beq.b	.fputype
	moveq	#2,d1
.fputype:
	move	d1,(FPU_Type-DT,a4)

	rts

versionstring:
	dc.b	"$VER: Asm-Pro "
	VERSION_STR
	dc.b	' ('
	%getdate 3
	dc.b	") by Solo/Genetic.",0

DosLibName:
	DC.B	"dos.library",0
NeedKS2Msg:
	DC.B	'Sorry, Asm-Pro requires Kickstart 2.04 or higher!',10,0
.End

	EVEN
ConvTabel3:	;0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
	DC.B	00,00,00,00,00,00,00,00,00,-1,00,00,00,00,00,00
	DC.B	00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
	DC.B	-1,00,00,00,00,'[',00,00,00,00,00,00,00,00,'A'-1,00
	DC.B	'0123456789',0,0,0,0,0,0
	DC.B	'@','ABCDEFGHIJKLMNOPQRSTUVWXYZ',0,0,0,0,'Z'+1
	DC.B	0,'ABCDEFGHIJKLMNOPQRSTUVWXYZ',0,0,0,0,0
	DC.B	-1

	CNOP	0,4
realend1:

;***********************************************
;**            MAIN CODE SECTION              **
;***********************************************

	SECTION	AsmPro288,CODE
REAL:
	lea	(Variable_base),a4
	move.l	(4).w,a6
	move.l	(ThisTask,a6),a5
	move.l	a5,(DATA_TASKPTR-DT,a4)
	move.l	(pr_WindowPtr,a5),(DATA_WINDOWPTR-DT,a4)

	moveq	#126,d0			; leave some stack space for safety
	add.l	(TC_SPLOWER,a5),d0
	move.l	d0,(StackBottom-DT,a4)	; stack is full when we hit the bottom

	lea	(ProcessIOPtrs-DT,a4),a0
	move.l	(a0)+,(pr_CIS,a5)	; inherit i/o from parent process
	move.l	(a0)+,(pr_COS,a5)
	move.l	(a0),(pr_CLI,a5)

	bsr.w	MakeItAllHappen

	move.l	(DATA_TASKPTR-DT,a4),a5
	move.l	(DATA_WINDOWPTR-DT,a4),(pr_WindowPtr,a5)
	lea	(REAL-4,pc),a0
	move.l	a0,d1
	lsr.l	#2,d1
	move.l	(DosBase-DT,a4),a6
	jmp	(_LVOUnLoadSeg,a6)		; PROCESS EXIT

;***************************************************************

DATAFROMSTART:
	move.b	(a0)+,d0
	cmp.b	#10,d0
	beq.b	DFS.END
	cmp.b	#'-',d0
	beq.b	CmdlineOpties
	cmp.b	#'\',d0
	bne.b	DATAFROMSTART
DATAFROMAUTO2:
	move.b	(a0)+,d0
	beq.b	DFS.END
	cmp.b	#10,d0
	beq.b	DFS.END

	cmp.b	#'\',d0
	bne.b	.NOTKEY1
	moveq	#13,d0
.NOTKEY1:
	cmp.b	#'^',d0		;ESC
	bne.b	.NOTKEY2
	moveq	#$1B,d0
.NOTKEY2:
	cmp.b	#';',d0
	beq.b	DFS.END

	move.l	a0,-(sp)
	jsr	(KEYBUFFERPUTCHAR).l
	move.l	(sp)+,a0
	bra.b	DATAFROMAUTO2
DFS.END:
	rts

DATAFROMAUTO:
	cmp.b	#'-',(a0)
	bne.s	.noNewOptions

	addq.l	#1,a0
	cmp.b	#'f',(a0)+
	bne.s	.noforce

	st	(Safety-DT,a4)

	addq.l	#1,a0
.noforce:

.noNewOptions:
	bra.b	DATAFROMAUTO2

CmdlineOpties:
	movem.l	d0/a1,-(sp)
	lea	(ENVARCAsmProPref.MSG-DT,a4),a1
	moveq	#63-1,d0
.copyname:
	tst.b	(a0)
	beq.b	.nomoreopties
	cmp.b	#' ',(a0)
	beq.b	.nomoreopties
	cmp.b	#10,(a0)
	beq.b	.nomoreopties
	move.b	(a0)+,(a1)+
	dbra	d0,.copyname
.nomoreopties:
	clr.b	(a1)
	movem.l	(sp)+,d0/a1
	bra.b	DATAFROMSTART

	IFEQ	SPEC_ED
imagestr:
	dc.w	0		;0	offset x
	dc.w	0		;2	offset y
	dc.w	480		;4	breedte 
	dc.w	120		;6	hoogte plaatje
	dc.w	2		;8	nr planes
	dc.l	asmprologo	;10	bitmap ptr
	dc.b	3		;14
	dc.b	0		;15
	dc.l	0		;16
	ENDIF

;***************************************************************

MakeItAllHappen:
	move.l	sp,(DATA_USERSTACKPTR-DT,a4)

	move.b	#IECLASS_RAWKEY,(MY_EVENT+ie_Class-DT,a4)
	st	(AsmErrorTable-DT,a4)
	st	(mon_StartSize-DT,a4)
	clr.b	(MyBits-DT,a4)
	clr.b	(ScBits-DT,a4)
	clr.w	(ScColor-DT,a4)
	move.w	#'#?',(req_file_extentie-DT,a4)	; pattern base for sources
	move	#68,(breedte_editor_in_chars-DT,a4)

	jsr	(OpenLibsAndInitUI)

MainRestartLoop:
	jsr	clear_screen

	clr.l	(Cursor_pos-DT,a4)		; col, row

	IFEQ	SPEC_ED
	moveq	#0,d7
	move.w	(Scr_hoogte-DT,a4),d7
	lsr.w	#4,d7
	move.w	d7,d6
	add.w	(imagestr+ig_Height,pc),d7
	divu.w	(EFontSize_y-DT,a4),d7
.lopje	jsr	(Druk_af_eol)
	dbf	d7,.lopje
	ENDIF

	tst.b	(HomeDirectory-DT,a4)
	beq.b	.C4C2
	tst.b	(HomeDirSet-DT,a4)
	beq.b	.C4C2
	sf	(HomeDirSet-DT,a4)
	lea	(HomeDirectory-DT,a4),a0
	move.l	a0,_dirstringTags+4
.C4C2
	jsr	(LoadRecentFiles)

	IFEQ	SPEC_ED
	move.l	(Rastport-DT,a4),a0
	move.l	(IntBase-DT,a4),a6
	lea	imagestr(pc),a1
	movem.w	(ig_Width,a1),d2/d3	; width, height

	move.w	(Scr_breedte-DT,a4),d0	; center the picture
	sub.w	d2,d0
	lsr.w	#1,d0
	move.w	d0,d5
	move.w	d6,d1
	jsr	(_LVODrawImage,a6)
	ENDIF

	move.l	(GadToolsBase-DT,a4),a6

	move.l	(Rastport-DT,a4),a0
	lea	(PW_NR),a1
	move.l	(MainVisualInfo-DT,a4),(PW_NR+4-PW_NR,a1)
	move.l	(MainVisualInfo-DT,a4),(PW_IR+4-PW_NR,a1)

	IFEQ	SPEC_ED
	move.w	d5,d0
	move.w	d6,d1
	subq.w	#3,d0		;x
	subq.w	#3,d1		;y
	addq.w	#3*2,d2
	addq.w	#3*2,d3
	jsr	_LVODrawBevelBoxA(a6)
	ENDIF

	jmp	(AllocMainWorkspace)

PRIVILIGE_VIOL1:
	movem.l	d0-d7/a0-a6,-(sp)
	lea	(SupervisorRoutine,pc),a5
	move.l	(4).w,a6
	jsr	(_LVOSupervisor,a6)

CriticalError:
	movem.l	(sp)+,d0-d7/a0-a6
	move.l	(DATA_USERSTACKPTR-DT,a4),sp
	jsr	(DEBUG_CLEAR_BP_BUFFER).l
	lea	(SuperStackEnd-DT,a4),a1
	move.l	a1,(SSP_base-DT,a4)
	lea	(UserStackEnd-DT,a4),a1
	move.l	a1,(USP_base-DT,a4)
	clr	(statusreg_base-DT,a4)
	move.l	#eop_irq_routine,(pcounter_base-DT,a4)
	jsr	(debug_regs2old).l
	jmp	(CommandlineInputHandler).l

SupervisorRoutine:
	move.l	sp,(DATA_SUPERSTACKPTR-DT,a4)
	tst	(ProcessorType-DT,a4)
	beq.b	.mc68000
	movec	vbr,a5
	move.l	a5,(VBR_base_ofzo-DT,a4)
.mc68000
	rte

;;***********************************************
;*	      EDITOR HANDLE ROUTINES		*
;************************************************

; ----
InsertText:
	movem.l	d0-d6/a0-a3/a5/a6,-(sp)
	move.l	(FirstLinePtr-DT,a4),a2
	move.l	a2,a3
	tst.l	d3
	beq.b	.InEnd
	move.l	d3,a1
	movem.l	d2/d3,-(sp)
	bsr.w	EDITOR_MAKEHOLE_A1LONG
	movem.l	(sp)+,d2/d3
	move.l	d3,d1
	bsr.w	MOVEMARKS
	move.l	d2,a0
	subq.w	#1,d3
	moveq	#$20,d1
.lopje:
	move.b	(a0)+,d0
	cmp.b	d1,d0
	bcc.b	.tab
	cmp.b	#9,d0
	beq.b	.tab
	moveq	#0,d0
.tab:
	move.b	d0,(a2)+
	dbra	d3,.lopje
	move.l	a2,(FirstLinePtr-DT,a4)
.InEnd:
	movem.l	(sp)+,d0-d6/a0-a3/a5/a6
	rts

; ----
GoBack1Line:
	moveq	#1,d1

; ----
MoveupNLines:
	move.l	(FirstLinePtr-DT,a4),a0
	cmp.l	a3,a0
	bne.b	.lopje
	move.l	a2,a0
.lopje:
	move.b	-(a0),d0
	cmp.b	#SRCMARK_BEGIN,d0
	beq.b	.ReachedStart
	cmp.l	a3,a0
	bne.b	.skip
	move.l	a2,a0
.skip:
	tst.b	d0
	bne.b	.lopje
	subq.l	#1,(FirstLineNr-DT,a4)
	dbra	d1,.lopje
	sub.l	#$10000,d1
	bcc.b	.lopje

	addq.l	#1,(FirstLineNr-DT,a4)
.ReachedStart:
	addq.l	#1,a0
	move.l	a0,(FirstLinePtr-DT,a4)
	rts

; ----
MoveDownNLines:
	move.l	(FirstLinePtr-DT,a4),a0
.lopje:
	cmp.l	a2,a0
	bne.b	.skip
	move.l	a3,a0
.skip:
	move.b	(a0)+,d0
	cmp.b	#SRCMARK_END,d0
	beq.b	.end
	tst.b	d0
	bne.b	.lopje
	addq.l	#1,(FirstLineNr-DT,a4)
	move.l	a0,(FirstLinePtr-DT,a4)
	dbra	d1,.lopje
	sub.l	#$10000,d1
	bcc.b	.lopje
.end:
	rts

; ----
BeginNextLine:
	move.l	(FirstLinePtr-DT,a4),a0
.lopje:
	cmp.l	a2,a0
	bne.b	.skip
	move.l	a3,a0
.skip:
	move.b	(a0)+,d0
	cmp.b	#SRCMARK_END,d0
	beq.b	.end
	tst.b	d0
	bne.b	.lopje
	addq.l	#1,(FirstLineNr-DT,a4)
	move.l	a0,(FirstLinePtr-DT,a4)
.end:
	rts

;******************************
;***     ESCAPE PRESSED     ***
;*** ACTIVATE EDITOR WINDOW ***
;******************************

; A0 BLOCK START
; A1 BLOCK START
; A2 BLOCK START
; A6 BLOCK START

ACTIVATEEDITORWINDOW:
	bclr	#SB3_COMMANDMODE,(SomeBits3-DT,a4)	;uit commandmode
	sf	(BlokBackwards-DT,a4)
	moveq	#'0',d1
	add.b	(CurrentSource-DT,a4),d1
	move.b	d1,(SourceNrInBalk).l

	jsr	(Change2Editmenu).l

	and.b	#~((1<<SB1_MOUSE_KLIK)|(1<<SB1_SEARCHBUF_NE)),(SomeBits-DT,a4)
	and.b	#~((1<<SB2_MAKEMACRO)|(1<<SB2_INDEBUGMODE)),(SomeBits2-DT,a4)
	bset	#SB3_SPEC_KEYS,(SomeBits3-DT,a4)	;in editor
	bclr	#MB1_INCOMMANDLINE,(MyBits-DT,a4)	;uit commandline

	jsr	(PRINT_CLEARSCREEN).l
	st	(BreakKey-DT,a4)	; disabled
	bsr.w	E_RemoveCutMarking
	move.l	(FirstLinePtr-DT,a4),a2
	move.l	a2,a3
	move.l	(NrOfLinesInEditor-DT,a4),d1
	lsr.w	#1,d1
	bsr.w	MoveupNLines
	jsr	(Druk_Clearbuffer)
	jsr	(PrintStatusBalk).l
	bsr.w	Show_Cursor
	movem.l	d0-d7/a0-a6,(EditorRegs-DT,a4)

.EventLoopje:
	moveq	#1,d0
	cmp.l	(FirstLineNr-DT,a4),d0
	bne.b	.noFirst
	tst.l	(LineFromTop-DT,a4)
	bne.b	.noFirst
	bsr.w	ParseCustomTabs
	tst.b	(HaveCustomTab-DT,a4)
	beq.b	.noFirst
	bsr.w	RegTab_SETALLNOTUPD
.noFirst:
	bsr.w	EDITSCRPRINT
	jsr	(messages_get).l
	jsr	(GETKEYNOPRINT).l
	bsr.w	EDITOR_PUTMACRO
	cmp.b	#27,d0		;ESC
	beq.w	EDITOR_ESCPRESSED
	pea	(.EventLoopje,pc)	;set return

	cmp.b	#$80,d0		;esc flag
	beq.b	ESC_KEYCODE
	jsr	RESETMENUTEXT
	cmp.b	#$7F,d0		;DEL
	beq.w	Delete
	cmp.b	#$1F,d0		;normal text
	bhi.w	EDITOR_INSERTCHAR_SETNS
	cmp.b	#9,d0		;TAB
	beq.w	EDITOR_INSERTCHAR_SETNS
	cmp.b	#13,d0		;CR
	beq.w	EDITOR_ReturnPressed
	cmp.b	#8,d0		;BS
	beq.w	EDITOR_Backspace
	cmp.b	#10,d0		;LF
	beq.w	EDITOR_UPRETURNPRESSED
	rts

ESC_KEYCODE:
	moveq	#0,d0
	move.b	(edit_EscCode-DT,a4),d0
	bsr.w	EDITOR_PUTMACRO
	jsr	(RESETMENUTEXT).l
	add	d0,d0
	add	(Editor_commands_table,pc,d0.w),d0
	jmp	(Editor_commands_table,pc,d0.w)

Editor_commands_table:
	dr.w	E_not_used		;not used
	dr.w	E_Scroll1LineUp		;UP
	dr.w	E_ArrowLeft		;LEFT
	dr.w	E_ArrowRight		;RIGHT
	dr.w	E_ScrollDown1Line	;DOWN
	dr.w	E_PageUp		;SHIFT UP
	dr.w	E_Move2BegLine		;SHIFT LEFT
	dr.w	E_Move2EndLine		;SHIFT RIGHT
	dr.w	E_PageDown		;SHIFT DOWN
	dr.w	E_Environment_prefs	;ALT UP
	dr.w	E_Jump1WordBack		;ALT LEFT
	dr.w	E_Jump1WordForth	;ALT RIGHT
	dr.w	E_Assembler_prefs	;ALT DOWN
	dr.w	E_MoveCursor2Top	;NUMPAD_5
	dr.w	EDITOR_ESCPRESSED	;AMIGA ESC
	dr.w	E_Delete2eol		;Amiga DEL
	dr.w	E_Delete2bol		;Amiga BACK

	dr.w	E_Comment		;Amiga+;
	dr.w	E_UnComment		;Amiga+:
	dr.w	E_100LinesUp		;Amiga+a
	dr.w	E_Mark_blok		;Amiga+b	20
	dr.w	E_Copy_blok		;Amiga+c
	dr.w	E_Delete_blok		;Amiga+d
	dr.w	E_Jump2Error		;Amiga+e
	dr.w	E_ClipPast		;Amiga+f	24 fill
	dr.w	E_Grab_word		;Amiga+g
	dr.w	E_Hex2Ascii		;Amiga+h
	dr.w	E_Fill			;Amiga+i	27 fill
	dr.w	E_Jump2Line		;Amiga+j
	dr.w	E_UsedRegisters		;Amiga+k
	dr.w	E_LowercaseBlock	;Amiga+l	30
	dr.w	E_DoMacro		;Amiga+m
	dr.w	E_SmartPast		;Amiga+n

	dr.w	EDITOR_UPRETURNPRESSED	;Amiga+o
	dr.w	E_Tabulate		;Amiga+p
	dr.w	E_SelectAll		;Amiga+q
	dr.w	E_RepeatReplace		;Amiga+r
	dr.w	E_Search		;Amiga+s
	dr.w	E_GotoTop		;Amiga+t
	dr.w	E_RemoveCutMarking	;Amiga+u
	dr.w	E_Fill			;Amiga+v	40 past
	dr.w	E_UpdateSource		;Amiga+w	41 was block write
	dr.w	E_Cut_Block		;Amiga+x	***
	dr.w	E_Rotate_Block		;Amiga+y	***
	dr.w	E_100LinesDown		;Amiga+z

	dr.w	E_ExitEditor		;Amiga+A	45
	dr.w	E_not_used		;Amiga+B
	dr.w	E_not_used		;Amiga+C
	dr.w	E_ExitEditor		;Amiga+D
	dr.w	E_not_used		;Amiga+E
	dr.w	E_not_used		;Amiga+F	50
	dr.w	E_not_used		;Amiga+G
	dr.w	E_not_used		;Amiga+H
	dr.w	E_not_used		;Amiga+I
	dr.w	E_Jump2Marking		;Amiga+J	jump2 2x';'
	dr.w	E_SpaceToTabBlock	;Amiga+K
	dr.w	E_UppercaseBlock	;Amiga+L	56
	dr.w	E_ExitEditor		;Amiga+M	57
	dr.w	E_not_used		;Amiga+N
	dr.w	E_ExitEditor		;Amiga+O
	dr.w	E_not_used		;E_Showplugs	;Amiga+P	60
	dr.w	E_not_used		;Amiga+Q
	dr.w	E_Replace		;Amiga+R
	dr.w	E_Search2		;Amiga+S
	dr.w	E_GotoBottom		;Amiga+T
	dr.w	E_not_used		;Amiga+U
	dr.w	E_not_used		;Amiga+V
	dr.w	E_WriteBlock		;Amiga+W	67
	dr.w	E_not_used		;Amiga+X
	dr.w	E_not_used		;Amiga+Y
	dr.w	E_SyntCols_prefs	;Amiga+Z	70

	dr.w	E_Jump1			;Amiga+1
	dr.w	E_Jump2			;Amiga+2
	dr.w	E_Jump3			;Amiga+3
	dr.w	E_not_used		;Amiga+4 ?
	dr.w	E_not_used		;Amiga+5 ?
	dr.w	E_not_used		;Amiga+6 ?
	dr.w	E_not_used		;Amiga+7 ?
	dr.w	E_not_used		;Amiga+8 ?

	dr.w	E_Mark1			;Amiga+!
	dr.w	E_Mark2			;Amiga+@	80
	dr.w	E_Mark3			;Amiga+#

	dr.w	E_MouseMovement		;mouse movement
	dr.w	E_CreateMacro		;Amiga ,

	dr.w	RegTab_SETALLNOTUPD	;
	dr.w	E_not_used		;

	dr.w	E_Mark4			;Amiga $
	dr.w	E_Mark5			;Amiga %
	dr.w	E_Mark6			;		88 ; used to be prefs->closewb
	dr.w	E_Mark7			;Amiga &
	dr.w	E_Mark8			;Amiga *	90
	dr.w	E_Mark9			;Amiga (
	dr.w	E_Mark10		;Amiga )
	dr.w	E_Jump4			;Amiga 4
	dr.w	E_Jump5			;Amiga 5
	dr.w	E_Jump6			;Amiga 6
	dr.w	E_Jump7			;Amiga 7
	dr.w	E_Jump8			;Amiga 8
	dr.w	E_Jump9			;Amiga 9
	dr.w	E_Jump10		;Amiga 0
	dr.w	E_not_used		;Amiga ^	100

	dr.w	E_OpenAmiGuide		;Amiga =

	dr.w	E_ChangeSource		;source change (102 obsolete)

; these 10 must all be one after another:
	dr.w	E_Go2Source0		;F1 change to source 0
	dr.w	E_Go2Source1		;F2
	dr.w	E_Go2Source2		;F3
	dr.w	E_Go2Source3		;F4
	dr.w	E_Go2Source4		;F5
	dr.w	E_Go2Source5		;F6
	dr.w	E_Go2Source6		;F7
	dr.w	E_Go2Source7		;F8		110
	dr.w	E_Go2Source8		;F9
	dr.w	E_Go2Source9		;F10

E_UpdateSource:
	moveq	#'U',d0
	jsr	(KEYBUFFERPUTCHAR).l
	moveq	#13,d0
	jsr	(KEYBUFFERPUTCHAR).l
;	moveq	#$1b,d0			;hmm loop :(
;	jsr	(KEYBUFFERPUTCHAR).l
	bra.w	E_ExitEditor

E_Go2Source0:
	bra.b	Go2SourceNow
E_Go2Source1:
	bra.b	Go2SourceNow
E_Go2Source2:
	bra.b	Go2SourceNow
E_Go2Source3:
	bra.b	Go2SourceNow
E_Go2Source4:
	bra.b	Go2SourceNow
E_Go2Source5:
	bra.b	Go2SourceNow
E_Go2Source6:
	bra.b	Go2SourceNow
E_Go2Source7:
	bra.b	Go2SourceNow
E_Go2Source8:
	bra.b	Go2SourceNow
E_Go2Source9:
	bra.b	Go2SourceNow

Go2Sourcenow_SetCtx:
	movem.l	d0-d7/a0-a6,-(sp)
	movem.l	(EditorRegs-DT,a4),d0-d7/a0-a6
	move.b	(Change2Source-DT,a4),d0
	bsr.b	Go2SourceNow2
	movem.l	(sp)+,d0-d7/a0-a6
	rts

Go2SourceNow:
	sub.w	#E_Go2Source0-Editor_commands_table,d0
	lsr.w	#1,d0
	move.b	d0,(Change2Source-DT,a4)
Go2SourceNow2:
	cmp.b	(CurrentSource-DT,a4),d0
	bne.b	E_ChangeSource
	rts

			RSRESET
CS_start		RS.L	1
CS_length		RS.L	1
CS_FirstLinePtr		RS.L	1
CS_FirstlineNr		RS.L	1
CS_FirstLineOffset	RS.L	1
CS_SomeBits		RS.W	1
CS_marks		RS.L	10
CS_filename		RS.B	31
CS_update		RS.B	129
CS_AsmStatus		RS.B	34
CS_size			RS.W	0	; = 256


E_ChangeSource:
	clr.l	(TempBuffer-DT,a4)
	move.l	(Cut_Blok_End-DT,a4),d0
	sub.l	(sourceend-DT,a4),d0
	ble.b	.dontcopy
	addq.w	#1,d0
	move.l	d0,(TempBufferSize-DT,a4)
	movem.l	d1-a6,-(sp)
	move.l	#$10001,d1
	move.l	(4).w,a6
	jsr	(_LVOAllocMem,a6)
	movem.l	(sp)+,d1-a6
	tst.l	d0
	beq.b	.dontcopy
	move.l	d0,(TempBuffer-DT,a4)
	movem.l	d0-a6,-(sp)
	move.l	(sourceend-DT,a4),a0
	move.l	(TempBuffer-DT,a4),a1
	move.l	(TempBufferSize-DT,a4),d0
	addq.w	#1,a0
	subq.w	#1,d0
	move.l	(4).w,a6
	jsr	(_LVOCopyMem,a6)
	movem.l	(sp)+,d0-a6
.dontcopy:
	bsr	C1634
	bsr	PUTENDMARKDOWN
	movem.l	d0-a6,-(sp)
	lea	(SourcePtrs-DT,a4),a0
	moveq	#0,d0
	moveq	#0,d2
	move.b	(CurrentSource-DT,a4),d0
	move.b	(Change2Source-DT,a4),d2
	lsl.w	#8,d0		; *CS_size
	lsl.w	#8,d2
	lea	(a0,d0.w),a1
	add.w	d2,a0
	move.l	(sourceend-DT,a4),d0
	sub.l	(sourcestart-DT,a4),d0
	bls.w	C9C0
	move.l	d0,(CS_length,a1)
	movem.l	d1-a6,-(sp)
	move.l	#$10001,d1
	move.l	(4).w,a6
	jsr	(_LVOAllocMem,a6)
	movem.l	(sp)+,d1-a6
	tst.l	d0
	beq.w	CBAE
	move.l	d0,(a1)		; CS_start
	move.l	(FirstLinePtr-DT,a4),(CS_FirstLinePtr,a1)
	move.l	(FirstLineNr-DT,a4),(CS_FirstlineNr,a1)
	move.l	(LineFromTop-DT,a4),(CS_FirstLineOffset,a1)
	move	(SomeBits-DT,a4),(CS_SomeBits,a1)
	move	(AssmblrStatus-DT,a4),(CS_AsmStatus,a1)
	movem.l	d7/a1/a2,-(sp)
	lea	(EditMarks10-DT,a4),a2
	lea	(CS_marks,a1),a1
	moveq	#10-1,d7	;copy marks
.C956	move.l	(a2)+,(a1)+
	dbra	d7,.C956
	movem.l	(sp)+,d7/a1/a2
	movem.l	d0-a6,-(sp)
	move.l	(sourcestart-DT,a4),a0
	move.l	(CS_length,a1),d0
	move.l	(a1),a1		; CS_start
	move.l	(4).w,a6
	jsr	(_LVOCopyMem,a6)
	movem.l	(sp)+,d0-a6
	movem.l	a2/a3,-(sp)
	lea	(MenuFileName),a2
	lea	(CS_filename,a1),a3
	moveq	#30-1,d7	; copy filename
	bsr.w	CopySrcPath
	lea	(LastFileNaam-DT,a4),a2
	lea	(CS_update,a1),a3
	moveq	#128-1,d7
	bsr.w	CopySrcPath
	movem.l	(sp)+,a2/a3
C9C0:
	tst.l	(a0)		; CS_start
	beq.w	CA9A
	move.l	(sourcestart-DT,a4),d0
	add.l	(CS_length,a0),d0
	move.l	d0,(sourceend-DT,a4)
	addq.l	#1,d0
	move.l	d0,(Cut_Blok_End-DT,a4)
	move.l	(CS_FirstLinePtr,a0),(FirstLinePtr-DT,a4)
	move.l	(CS_FirstlineNr,a0),(FirstLineNr-DT,a4)
	move.l	(CS_FirstLineOffset,a0),(LineFromTop-DT,a4)
	move	(CS_SomeBits,a0),(SomeBits-DT,a4)
	move	(CS_AsmStatus,a1),(AssmblrStatus-DT,a4)
	movem.l	d0-a6,-(sp)
	move.l	(sourcestart-DT,a4),a1	;dest
	move.l	(CS_length,a0),d0	;size
	movem.l	d0/a1,-(sp)
	move.l	(a0),a0			; CS_start
	move.l	(4).w,a6
	jsr	(_LVOCopyMem,a6)

	movem.l	(sp)+,d0/a1
	add.l	d0,a1
	move.b	#SRCMARK_END,(a1)+

	movem.l	(sp),d0-a5

	move.l	(a0),a1			; CS_start
	move.l	(CS_length,a0),d0
	jsr	(_LVOFreeMem,a6)
	movem.l	(sp)+,d0-a6
	lea	(CS_marks,a0),a1
	lea	(EditMarks10-DT,a4),a2
	moveq	#10-1,d7
.CA3C	move.l	(a1)+,(a2)+		; copy marks
	dbra	d7,.CA3C
	movem.l	a2/a3,-(sp)
	lea	(CS_update,a0),a2
	lea	(LastFileNaam-DT,a4),a3
	moveq	#128-1,d7
	bsr.b	CopySrcPath
.C964	lea	(CS_filename,a0),a2
	lea	(MenuFileName),a3
	moveq	#30-1,d7
	bsr.b	CopySrcPath
	movem.l	(sp)+,a2/a3
	moveq	#CS_size/4-1,d7
.CA8E	clr.l	(a0)+
	dbra	d7,.CA8E
	bra.b	CAE4

CopySrcPath:
.CA70	move.b	(a2)+,(a3)+
	tst.b	(a2)
	dbeq	d7,.CA70
	bne.b	.CA84
.CA7C	clr.b	(a3)+
	dbf	d7,.CA7C
.CA84	rts

CA9A:
	move.l	(sourcestart-DT,a4),a0
	move.l	a0,(FirstLinePtr-DT,a4)
	clr.b	(a0)+
	moveq	#SRCMARK_END,d0
	move.b	d0,(a0)
	move.l	a0,(sourceend-DT,a4)
	move.b	d0,(a0)+
	move.l	a0,(Cut_Blok_End-DT,a4)
	moveq	#1,d0
	move.l	d0,(FirstLineNr-DT,a4)
	clr.l	(LineFromTop-DT,a4)
	and.b	#~((1<<SB1_SOURCE_CHANGED)|(1<<SB1_MOUSE_KLIK)),(SomeBits-DT,a4)
	bclr	#SB2_MAKEMACRO,(SomeBits2-DT,a4)
	clr.b	(LastFileNaam-DT,a4)
	clr.b	(MenuFileName).l
	clr	(AssmblrStatus-DT,a4)
CAE4:
	bclr	#SB1_MOUSE_KLIK,(SomeBits-DT,a4)
	move.b	(Change2Source-DT,a4),d0
	move.b	d0,(CurrentSource-DT,a4)
	add.b	#'0',d0
	move.b	d0,(SourceNrInBalk).l
	movem.l	(sp)+,d0-d7/a0-a6
	bsr	RegTab_SETALLNOTUPD
	clr	(NewCursorpos-DT,a4)
	st	(BreakKey-DT,a4)	; disabled
	bsr	E_RemoveCutMarking
	move.l	(FirstLinePtr-DT,a4),a2
	move.l	a2,a3
	move.l	(NrOfLinesInEditor-DT,a4),d1
	lsr.w	#1,d1
	bsr	MoveupNLines
	tst.l	(TempBuffer-DT,a4)
	beq.b	CB8E
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	(sourceend-DT,a4),d0
	add.l	(TempBufferSize-DT,a4),d0
	cmp.l	(WORK_END-DT,a4),d0
	bge.b	CB6A
	move.l	(sourceend-DT,a4),a1
	addq.l	#1,a1
	subq.w	#1,d0
	move.l	(TempBuffer-DT,a4),a0
	move.l	(TempBufferSize-DT,a4),d0
	move.l	(4).w,a6
	jsr	(_LVOCopyMem,a6)
	move.l	(sourceend-DT,a4),a1
	add.l	(TempBufferSize-DT,a4),a1
	subq.l	#1,a1
	move.b	#SRCMARK_END,(a1)
	move.l	a1,(Cut_Blok_End-DT,a4)
CB6A:
	movem.l	(sp),d0-a6
	move.l	(TempBuffer-DT,a4),a1
	move.l	(TempBufferSize-DT,a4),d0
	move.l	(4).w,a6
	jsr	(_LVOFreeMem,a6)
	clr.l	(TempBuffer-DT,a4)
	clr.l	(TempBufferSize-DT,a4)
	movem.l	(sp)+,d0-a6
CB8E:
	tst.b	(FromCmdLine-DT,a4)
	beq.b	CB96
	rts
CB96:
	bsr.w	ParseCustomTabs
	jsr	(Druk_Clearbuffer)
	jsr	(RESETMENUTEXT2).l
	jmp	(PrintStatusBalk).l

CBAE:
	movem.l	(sp)+,d0-a6
	lea	(Insuficientme.MSG-DT,a4),a0
	jmp	(printTextInMenuStrip)

;********** EINDE CHANGE SOURCE ***************

E_OpenAmiGuide:
	jmp	(AmigaGuideGedoe)

; block comment
E_Comment:
	cmp.w	#-1,a6
	beq.b	CC52
	cmp.l	a2,a6
	bge.b	CC52			;lame not backwards..
;	cmp.l	a6,a2
;	bge.b	.ok
;	exg	a6,a2
;.ok:
	move.l	a2,(HelpBufPtrTop-DT,a4)
	move.l	a6,(HelpBufPtrBot-DT,a4)
	move.l	(FirstLinePtr-DT,a4),a6
	bsr.w	E_Move2BegLine
CBEC:
	bsr.w	EDITOR_MOVEUP1LINE_NOSCROLL
	cmp.l	(HelpBufPtrBot-DT,a4),a2
	bgt.b	CBEC
	bsr.w	E_Move2BegLine
CBFA:
	moveq	#';',d0
	bsr.w	EDITOR_INSERTCHAR_SETNS
	addq.l	#1,(HelpBufPtrTop-DT,a4)
	cmp.l	a2,a6
	bge.b	CC0A
	addq.l	#1,a6
CC0A:
	bsr.w	EDITOR_MOVEDOWN1LINE_NOSCROLL
	cmp.b	#SRCMARK_END,(a3)
	beq.b	CC46
	bsr.w	E_Move2BegLine
	cmp.l	(HelpBufPtrTop-DT,a4),a2
	blt.b	CBFA
CC1E:
	move.l	a2,(FirstLinePtr-DT,a4)
	move.l	a2,-(sp)
	move.l	(LineFromTop-DT,a4),-(sp)
	move.l	(FirstLineNr-DT,a4),-(sp)
	move.l	a6,a2
	move.l	(LineFromTop-DT,a4),d1
	bsr.w	MoveupNLines
	move.l	(sp)+,(FirstLineNr-DT,a4)
	move.l	(sp)+,(LineFromTop-DT,a4)
	move.l	(sp)+,a2
	bra.w	E_RemoveCutMarking

CC46:
	bsr.w	E_Move2BegLine
	moveq	#';',d0
	bsr.w	EDITOR_INSERTCHAR_SETNS
	bra.b	CC1E

CC52:
	rts

E_UnComment:
	cmp.l	a6,a2
	bls.w	E_RemoveCutMarking
	move.l	a2,d0
	sub.l	a6,d0
	move.l	d0,-(sp)
	move.l	a6,-(sp)
	bsr.w	E_RemoveCutMarking
	move.l	(sp)+,a1
	bsr.w	CF5A_HaveA1
	bra.b	CC74
CC6E:
	move.l	d0,-(sp)
	bsr.w	E_NextCharacter
CC74:
	tst.b	(-1,a2)
	bne.b	CC8C
	cmp.b	#';',(a3)
	bne.b	CC8C
	bsr.w	Delete
	move.l	(sp)+,d0
	subq.l	#1,d0
	beq.b	CC92
	bra.b	CC8E
CC8C:
	move.l	(sp)+,d0
CC8E:
	subq.l	#1,d0
	bne.b	CC6E
CC92:
	lea	(UncommentDone.MSG),a0
	jsr	(printTextInMenuStrip-UncommentDone.MSG,a0)
	bra.w	E_NextCharacter


; block tabulate
E_Tabulate:	cmp.w	#-1,a6
		beq.b	CC52
		cmp.l	a2,a6
		bge.b	CC52
		move.l	a2,(HelpBufPtrTop-DT,a4)
		move.l	a6,(HelpBufPtrBot-DT,a4)
		move.l	(FirstLinePtr-DT,a4),a6
		bsr.w	E_Move2BegLine
CBECTab:	bsr.w	EDITOR_MOVEUP1LINE_NOSCROLL
		cmp.l	(HelpBufPtrBot-DT,a4),a2
		bgt.b	CBECTab
		bsr.w	E_Move2BegLine
CBFATab:	cmp.b	#9,(a3)
		beq.b	DoTab
		cmp.b	#" ",(a3)
		beq.b	DoTab
		cmp.b	#SRCMARK_BEGIN,(a3)
		beq.b	NoTab
		cmp.b	#SRCMARK_END,(a3)
		beq.b	NoTab
		tst.b	(a3)
		beq.b	NoTab
		cmp.b	#";",(a3)		; comments?
		beq.b	NoTab
		cmp.b	#"*",(a3)
		beq.b	NoTab
		bsr.w	E_Jump1WordForth	; label?
		cmp.b	#SRCMARK_BEGIN,-1(a3)	; empty line
		beq.b	NoTab
		cmp.b	#SRCMARK_END,-1(a3)
		beq.b	NoTab
		tst.b	-1(a3)
		beq.b	NoTab
DoTab:		moveq	#9,d0
		bsr.w	EDITOR_INSERTCHAR_SETNS
		addq.l	#1,(HelpBufPtrTop-DT,a4)
		cmp.l	a2,a6
		bge.b	CC0ATab
		addq.l	#1,a6
CC0ATab:
NoTab:		bsr.w	EDITOR_MOVEDOWN1LINE_NOSCROLL
		cmp.b	#SRCMARK_END,(a3)
		beq.b	CC46Tab
		bsr.w	E_Move2BegLine
		cmp.l	(HelpBufPtrTop-DT,a4),a2
		blt.b	CBFATab
CC1ETab:	move.l	a2,(FirstLinePtr-DT,a4)
		pea.l	(a2)
		move.l	(LineFromTop-DT,a4),-(a7)
		move.l	(FirstLineNr-DT,a4),-(a7)
		lea	(a6),a2
		move.l	(LineFromTop-DT,a4),d1
		bsr.w	MoveupNLines
		move.l	(a7)+,(FirstLineNr-DT,a4)
		move.l	(a7)+,(LineFromTop-DT,a4)
		move.l	(a7)+,a2
		bra.w	E_RemoveCutMarking
CC46Tab:	bsr.w	E_Move2BegLine
		cmp.b	#9,(a3)			; tab ?
		beq.b	DoTabE
		cmp.b	#" ",(a3)		; space ?
		beq.b	DoTabE
		cmp.b	#SRCMARK_BEGIN,(a3)
		beq.b	NoDoTabE
		cmp.b	#SRCMARK_END,(a3)
		beq.b	NoDoTabE
		tst.b	(a3)
		beq.b	NoDoTabE
		cmp.b	#";",(a3)		; comments ?
		beq.b	NoDoTabE
		cmp.b	#"*",(a3)
		beq.b	NoDoTabE
		bsr.w	E_Jump1WordForth	; label ?
		cmp.b	#SRCMARK_BEGIN,-1(a3)
		beq.b	NoDoTabE
		cmp.b	#SRCMARK_END,-1(a3)
		beq.b	NoDoTabE
		tst.b	-1(a3)
		beq.b	NoDoTabE
DoTabE:		moveq	#9,d0
		bsr.w	EDITOR_INSERTCHAR_SETNS
NoDoTabE:	bra.b	CC1ETab

; ----
E_SyntCols_prefs:
	move.b	#2,(Prefs_tiepe-DT,a4)
	bra.b	E_XPrefs

E_Assembler_prefs:
	move.b	#1,(Prefs_tiepe-DT,a4)
	bra.b	E_XPrefs

E_Environment_prefs:
	clr.b	(Prefs_tiepe-DT,a4)
E_XPrefs:
	movem.l	d0-a6,-(sp)
	jsr	(Handle_prefs_windows)
	movem.l	(sp)+,d0-a6

	move.w	(Scr_br_chars-DT,a4),(breedte_editor_in_chars-DT,a4)
	move.w	(NumLines_Editor-DT,a4),d0
	jsr	(OPED_SETNBOFFLINES)
	jsr	(PrintStatusBalk)
	bra.w	RegTab_SETALLNOTUPD

; ----
	IF useplugins
E_Showplugs:
	jsr	_E_Showplugs
	rts
	ENDIF

E_Grab_word:
	move.l	a3,a1
	bsr.b	.checkit
	beq.b	.goright
	move.l	a2,a1
.lopje:
	subq.w	#1,a1
	bsr.b	.checkit
	bne.b	.lopje
	addq.w	#1,a1
	bra.b	.trans

.goright:
	addq.w	#1,a1
	move.b	(a1),d0
	beq.b	.exit
	cmp.b	#SRCMARK_END,d0
	beq.b	.exit
	bsr.b	.checkit
	beq.b	.goright
.trans:
	lea	(CurrentAsmLine-DT,a4),a0
.lopje2:
	cmp.l	a2,a1
	bne.b	.okay
	move.l	a3,a1
.okay:
	bsr.b	.checkit
	beq.b	.klaar
	move.b	(a1)+,(a0)+
	bra.b	.lopje2

.klaar:
	clr.b	(a0)+
	jmp	(INPUT_FILLINDAIRY).l

.checkit:
	move.b	(a1),d0
	cmp.b	#".",d0
	beq.b	.okay2
;	cmp.b	#"$",d0
;	beq.b	.okay1
	cmp.b	#"_",d0
	beq.b	.okay2
	cmp.b	#"0",d0
	bcs.b	.foutje
	cmp.b	#"9",d0
	bls.b	.okay2
	cmp.b	#"A",d0
	bcs.b	.foutje
	cmp.b	#"Z",d0
	bls.b	.okay2
	cmp.b	#"a",d0
	bcs.b	.foutje
	cmp.b	#"z",d0
	bls.b	.okay2
.foutje:
	moveq	#0,d0
.exit:
	rts

.okay2:
	moveq	#-1,d0
	rts

; ----
E_CreateMacro:
	bchg	#SB2_MAKEMACRO,(SomeBits2-DT,a4)
	bne.b	.CD94
	clr	(EDMACRO_BUFPTR-DT,a4)
	lea	(Createmacro.MSG),a0
	jmp	(printTextInMenuStrip-Createmacro.MSG,a0)
.CD94	subq.b	#2,(EDMACRO_BUFPTR+1-DT,a4)
E_PutMacroDone:
	rts

EDITOR_PUTMACRO:
	btst	#SB2_MAKEMACRO,(SomeBits2-DT,a4)
	beq.b	E_PutMacroDone
	lea	(EDMACRO_BUFFER-DT,a4),a1
	add	(EDMACRO_BUFPTR-DT,a4),a1
	move.b	d0,(a1)+
	addq.b	#1,(EDMACRO_BUFPTR+1-DT,a4)
	bne.b	E_PutMacroDone
	bclr	#SB2_MAKEMACRO,(SomeBits2-DT,a4)
	subq.b	#1,(EDMACRO_BUFPTR+1-DT,a4)
	lea	(Macrobufferfu.MSG),a0
	jmp	(printTextInMenuStrip-Macrobufferfu.MSG,a0)

; ----
E_DoMacro:
	bclr	#SB2_MAKEMACRO,(SomeBits2-DT,a4)
	beq.b	.CDD6
	subq.b	#2,(EDMACRO_BUFPTR+1-DT,a4)
.CDD6:
	lea	(EDMACRO_BUFFER-DT,a4),a1
	move	(EDMACRO_BUFPTR-DT,a4),d1
	beq.b	.CDF6
	add	d1,a1
.CDE2:
	move.b	-(a1),d0
	lea	(OwnKeyBuffer-DT,a4),a0
	subq.b	#1,(KeyboardInBuf+1-DT,a4)
	add	(KeyboardInBuf-DT,a4),a0
	move.b	d0,(a0)
	subq.w	#1,d1
	bne.b	.CDE2
.CDF6:
	rts

; ----
E_Jump2Error:
	movem.l	a0/a1/a5/a6,-(sp)
	move.l	(FirstLineNr-DT,a4),d0
	add.l	(LineFromTop-DT,a4),d0
	lea	(AsmErrorTable-8-DT,a4),a0
.CE08:
	addq.l	#8,a0
	tst.l	(a0)
	bmi.b	.CE3C
	cmp.l	(a0),d0		;error linenr
	bge.b	.CE08
	move.l	(a0)+,d0	; line
	move.l	(a0),-(sp)	; error msg
	bsr.w	JUMPTOLINE
	lea	(Error.MSG),a0
	jsr	(printTextInMenuStrip-Error.MSG,a0)
	move.l	(sp)+,a0
	jsr	(druk_menu_txt_verder)
	movem.l	(sp)+,a0/a1/a5/a6
	rts
.CE3C:
	lea	(Nomoreerrorsf.MSG),a0
	jsr	(printTextInMenuStrip-Nomoreerrorsf.MSG,a0)
	movem.l	(sp)+,a0/a1/a5/a6
	rts

; ----
E_Jump2Line:
	movem.l	a0/a5/a6,-(sp)
	btst	#0,(PR_ReqLib).l
	beq.b	.noreqt
	btst	#0,(PR_ExtReq).l
	beq.b	.noreqt
	movem.l	a0-a3/a6,-(sp)
	lea	(JumpToLineTags),a0
	lea	(JumpLineNr-DT,a4),a1
	lea	(Jumptowhichli.MSG-JumpToLineTags,a0),a2
	sub.l	a3,a3
	move.l	(ReqToolsbase-DT,a4),a6
	jsr	(_LVOrtGetLongA,a6)
	movem.l	(sp)+,a0-a3/a6
	move.l	(JumpLineNr-DT,a4),d0
	bra.b	.CEA2
.noreqt:
	lea	(Jumptoline.MSG),a0
	jsr	(GetNrFromTitle-Jumptoline.MSG,a0)
	beq.b	.novalue
.CEA2:
	move.l	d0,-(sp)
	lea	(Jumping.MSG),a0
	jsr	(printTextInMenuStrip-Jumping.MSG,a0)
	move.l	(sp)+,d0

	bsr.w	JUMPTOLINE
	lea	(Done.MSG),a0
	jsr	(druk_menu_txt_verder-Done.MSG,a0)
	movem.l	(sp)+,a0/a5/a6
	rts
.novalue:
	jsr	(RESETMENUTEXT).l
	movem.l	(sp)+,a0/a5/a6
	rts

; ----
E_Mark1:
	move.l	a2,(EditMarks10+4*0-DT,a4)
	rts

E_Mark2:
	move.l	a2,(EditMarks10+4*1-DT,a4)
	rts

E_Mark3:
	move.l	a2,(EditMarks10+4*2-DT,a4)
	rts

E_Mark4:
	move.l	a2,(EditMarks10+4*3-DT,a4)
	rts

E_Mark5:
	move.l	a2,(EditMarks10+4*4-DT,a4)
	rts

E_Mark6:
	move.l	a2,(EditMarks10+4*5-DT,a4)
	rts

E_Mark7:
	move.l	a2,(EditMarks10+4*6-DT,a4)
	rts

E_Mark8:
	move.l	a2,(EditMarks10+4*7-DT,a4)
	rts

E_Mark9:
	move.l	a2,(EditMarks10+4*8-DT,a4)
	rts

E_Mark10:
	move.l	a2,(EditMarks10+4*9-DT,a4)
	rts

; ----
E_Jump1:
	moveq	#4*0,d0
	bra.b	CF5A

E_Jump2:
	moveq	#4*1,d0
	bra.b	CF5A

E_Jump3:
	moveq	#4*2,d0
	bra.b	CF5A

E_Jump4:
	moveq	#4*3,d0
	bra.b	CF5A

E_Jump5:
	moveq	#4*4,d0
	bra.b	CF5A

E_Jump6:
	moveq	#4*5,d0
	bra.b	CF5A

E_Jump7:
	moveq	#4*6,d0
	bra.b	CF5A

E_Jump8:
	moveq	#4*7,d0
	bra.b	CF5A

E_Jump9:
	moveq	#4*8,d0
	bra.b	CF5A

E_Jump10:
	moveq	#4*9,d0

CF5A:
	lea	(EditMarks10-DT,a4),a1
	move.l	(a1,d0.w),a1
CF5A_HaveA1:
	move.l	a1,d0
	beq.b	CFA8
	move.l	(FirstLineNr-DT,a4),d4
	add.l	(LineFromTop-DT,a4),d4
	clr.l	(LineFromTop-DT,a4)
	move.l	(sourceend-DT,a4),a0
	sub.l	a3,a0
	add.l	a2,a0
	cmp.l	a0,a1
	bls.b	CF78
	move.l	a0,a1
CF78:
	move.l	(sourcestart-DT,a4),a0
	cmp.l	a0,a1
	bcc.b	CF82
	move.l	a0,a1
CF82:
	lea	(Jumping.MSG),a0
	jsr	(printTextInMenuStrip-Jumping.MSG,a0)
	cmp.l	a2,a1
	bhi.b	CFAA
	bcs.b	CFBC
CF94:
	move.l	d4,(FirstLineNr-DT,a4)
	move.l	a2,(FirstLinePtr-DT,a4)
	lea	(Done.MSG),a0
	jsr	(druk_menu_txt_verder-Done.MSG,a0)
CFA8:
E_not_used:
	rts

CFAA:
	move.b	(a3)+,(a2)+
	beq.b	CFB4
	cmp.l	a2,a1
	bne.b	CFAA
	bra.b	CF94
CFB4:
	addq.w	#1,d4
	cmp.l	a2,a1
	bne.b	CFAA
	bra.b	CF94
CFBC:
	move.b	-(a2),-(a3)
	beq.b	CFC6
	cmp.l	a2,a1
	bne.b	CFBC
	bra.b	CF94
CFC6:
	subq.w	#1,d4
	cmp.l	a2,a1
	bne.b	CFBC
	bra.b	CF94

; ----
E_Jump1WordForth:
	move.w	#-1,(Oldcursorcol-DT,a4)
	move.b	(a3),d0
	cmp.b	#SRCMARK_END,d0
	beq.b	C1006
	cmp.b	#" ",d0
	bls.b	CFEE
	cmp.b	#",",d0
	beq.b	CFEE
	bsr.w	E_NextCharacter
	bra.b	E_Jump1WordForth

CFEE:
	bsr.w	E_NextCharacter
	move.b	(a3),d0
	cmp.b	#SRCMARK_END,d0
	beq.b	C1006
	cmp.b	#" ",d0
	bls.b	CFEE
	cmp.b	#",",d0
	beq.b	CFEE
C1006:
	rts

; ----
E_Jump1WordBack:
	move.w	#-1,(Oldcursorcol-DT,a4)
	move.b	(-1,a2),d0
	beq.b	C102C
	cmp.b	#SRCMARK_BEGIN,d0
	beq.b	C1062
	cmp.b	#" ",d0
	bls.b	C1030
	cmp.b	#",",d0
	beq.b	C1030
	bsr.w	EDITOR_ARROWLEFT
	bra.b	E_Jump1WordBack

C102C:
	bsr.w	C154A
C1030:
	bsr.w	EDITOR_ARROWLEFT
	move.b	(-1,a2),d0
	beq.b	C102C
	cmp.b	#SRCMARK_BEGIN,d0
	beq.b	C1062
	cmp.b	#" ",d0
	bls.b	C1030
	cmp.b	#",",d0
	beq.b	C1030
C104C:
	move.b	(-1,a2),d0
	cmp.b	#" ",d0
	bls.b	C1062
	cmp.b	#",",d0
	beq.b	C1062
	bsr.w	EDITOR_ARROWLEFT
	bra.b	C104C

C1062:
	rts

; ----
E_Move2BegLine:
	clr.w	(Oldcursorcol-DT,a4)
	move.b	(-1,a2),d0
	beq.b	C107C
	cmp.b	#SRCMARK_BEGIN,d0
	beq.b	C107C
	bsr.w	EDITOR_ARROWLEFT
	bra.b	E_Move2BegLine

C107C:
	bsr.w	RegTab_SETALLNOTUPD
	clr	(YposScreen-DT,a4)

C109C:
	rts

; ----
E_Move2EndLine:
	move.w	#-1,(Oldcursorcol-DT,a4)
	move.b	(a3),d0
	beq.b	C109C
	cmp.b	#SRCMARK_END,d0
	beq.b	C109C
	bsr.w	E_NextCharacter
	bra.b	E_Move2EndLine

; ----
E_PageUp:
	bsr.w	E_clear_input_buffer
	move.l	(NrOfLinesInEditor-DT,a4),d1
	subq.w	#1,d1
C10AA:
	bsr.w	MoveupNLines
	bsr.b	C110E
C10B0:
	moveq	#1,d0
	cmp.l	(FirstLineNr-DT,a4),d0
	bne.b	C10D8
	clr.l	(LineFromTop-DT,a4)
E_PageUpDown_Finish:
	tst.b	(PR_Keepxy).l
	beq.b	C10D6
	move.w	(Oldcursorcol-DT,a4),d0
	add.w	(YposScreen-DT,a4),d0
	move.w	d0,(NewCursorpos-DT,a4)
	bra.w	EDITOR_MOVEUP1LINE_NOSCROLL

C10D8:
	move.b	(a3)+,d0
	cmp.b	#SRCMARK_END,d0
	beq.b	C1106
	move.b	d0,(a2)+
	bne.b	C10D8
	moveq	#1,d0
	move.l	d0,(LineFromTop-DT,a4)
	bra.b	E_PageUpDown_Finish

C1106:
	clr.l	(LineFromTop-DT,a4)
	subq.w	#1,a3
C10D6:
	rts

C110E:
	move.l	(FirstLinePtr-DT,a4),a0
	cmp.l	a2,a3
	beq.b	C1140
	cmp.l	a2,a0
	beq.b	C113E
	move.l	a2,d1
	sub.l	a0,d1
	bra.b	C1130

C1120:	REPT	8
	move.b	-(a2),-(a3)
	ENDR
C1130:
	subq.l	#8,d1
	bpl.b	C1120
	addq.w	#7,d1
	bmi.b	C113E
C1138:
	move.b	-(a2),-(a3)
	dbra	d1,C1138
C113E:
	rts

C1140:
	move.l	a0,a2
	move.l	a0,a3
	rts

C1146:
	move.l	(FirstLinePtr-DT,a4),a0
	cmp.l	a2,a3
	beq.b	C1180
	cmp.l	a0,a2
	bcc.b	C110E
	cmp.l	a3,a0
	beq.b	C117A
	move.l	a0,d1
	sub.l	a3,d1
	bra.b	C116C

C115C:	REPT	8
	move.b	(a3)+,(a2)+
	ENDR
C116C:
	subq.l	#8,d1
	bpl.b	C115C
	addq.w	#7,d1
	bmi.b	C117A
C1174:
	move.b	(a3)+,(a2)+
	dbra	d1,C1174
C117A:
	move.l	a2,(FirstLinePtr-DT,a4)
	rts

C1180:
	move.l	a0,a2
	move.l	a0,a3
	rts

; ----
E_MoveCursor2Top:
	move.l	(LineFromTop-DT,a4),d1
	subq.l	#1,d1
	bpl.w	MoveDownNLines
	rts

; ----
E_PageDown:
	bsr.w	E_clear_input_buffer
	move.l	(NrOfLinesInEditor-DT,a4),d1
	subq.w	#2,d1
	move.l	d1,-(sp)
	bsr.w	MoveDownNLines
	bsr.b	C1146
	move.l	(sp)+,d1
	clr.l	(LineFromTop-DT,a4)
	subq.w	#1,d1
C11AE:
	move.b	(a3)+,d0
	cmp.b	#SRCMARK_END,d0
	beq.b	C11DE
	move.b	d0,(a2)+
	bne.b	C11AE
	addq.l	#1,(LineFromTop-DT,a4)
	dbra	d1,C11AE

	bra.w	E_PageUpDown_Finish

C11DE:
	subq.w	#1,a3
	rts

EDITOR_ReturnPressed:
	move.l	a2,a0
	move.l	a0,-(sp)
	moveq	#0,d0
	bsr.b	EDITOR_INSERTCHAR_SETNS
	move.l	(sp)+,a0
	btst	#0,(PR_AutoIndent).l
	beq.b	C122C
C11F6:
	move.b	-(a0),d0
	beq.b	C1200
	cmp.b	#SRCMARK_BEGIN,d0
	bne.b	C11F6
C1200:
	addq.w	#1,a0
	move.l	a0,a1
C1204:
	move.b	(a0)+,d0
	cmp.b	#9,d0
	beq.b	C1204
	cmp.b	#" ",d0
	beq.b	C1204
	subq.l	#1,a0
	cmp.l	a0,a1
	beq.b	C122C
	tst.b	d0
	beq.b	C122E
C121C:
	move.b	(a1)+,d0
	movem.l	a0/a1,-(sp)
	bsr.b	EDITOR_INSERTCHAR
	movem.l	(sp)+,a0/a1
	cmp.l	a0,a1
	bne.b	C121C
C122C:
	rts

C122E:
	bsr.w	EDITOR_ARROWLEFT
	bsr.w	E_Delete2bol
	bra.w	E_NextCharacter

EDITOR_INSERTCHAR_SETNS:
	bset	#SB1_SOURCE_CHANGED,(SomeBits-DT,a4)
	clr.w	(AssmblrStatus-DT,a4)
	move.w	#-1,(Oldcursorcol-DT,a4)
EDITOR_INSERTCHAR:
	moveq	#1,d1
	bsr.w	MOVEMARKS
EDITOR_INSERTCHAR_NOMARKS:
	bsr.w	EDITOR_MABYMAKEHOLE
	move.b	d0,(a2)+
	rts

C125A:
	bsr.w	EDITOR_ARROWLEFT
EDITOR_UPRETURNPRESSED:
	moveq	#0,d0
	cmp.b	#SRCMARK_BEGIN,(-1,a2)
	beq.b	EDITOR_REINSERTCHAR
	tst.b	(-1,a2)
	bne.b	C125A
EDITOR_REINSERTCHAR:
	moveq	#1,d1
	bsr.w	MOVEMARKS
EDITOR_REINSERTCHAR_NOMARKS:
	bsr.w	EDITOR_MABYMAKEHOLE
	move.b	d0,-(a3)
	rts

EDITOR_Backspace:
	bset	#SB1_SOURCE_CHANGED,(SomeBits-DT,a4)
	moveq	#-1,d1
	bsr.w	MOVEMARKS
	move.w	#-1,(Oldcursorcol-DT,a4)
	move.b	-(a2),d0
	beq.w	C154A
	cmp.b	#SRCMARK_BEGIN,d0
	beq.b	EDITOR_INSERTCHAR
	rts

Delete:
	bset	#SB1_SOURCE_CHANGED,(SomeBits-DT,a4)
	moveq	#-1,d1
	bsr.w	MOVEMARKS
	move.w	#-1,(Oldcursorcol-DT,a4)
	move.b	(a3)+,d0
	cmp.b	#SRCMARK_END,d0
	beq.b	EDITOR_REINSERTCHAR
	rts

; ----
E_MouseMovement:
	jsr	(GetKey).l
	ext.w	d0
	move	d0,-(sp)
	bsr.w	E_Move2BegLine
	clr	(NewCursorpos-DT,a4)
	jsr	(GetKey).l
	ext.w	d0
	move	(cursor_row_pos-DT,a4),d1
	asr.w	#1,d1
	sub	d1,d0
	bmi.b	.C12F4
	beq.b	.C130A

.C12DE	move	d0,-(sp)
	bsr.w	E_ScrollDown1Line
	bsr.w	C16D8
	addq.l	#1,(LineFromTop-DT,a4)
	move	(sp)+,d0
	subq.w	#1,d0
	bne.b	.C12DE
	bra.b	.C130A

.C12F4	neg.w	d0
.C12F6	move	d0,-(sp)
	bsr.w	E_Scroll1LineUp
	bsr.w	C16D8
	subq.l	#1,(LineFromTop-DT,a4)
	move	(sp)+,d0
	subq.w	#1,d0
	bne.b	.C12F6
.C130A
	move	(sp)+,d0
	btst	#0,(PR_LineNrs)
	beq.b	.C1318
	subq.w	#6,d0
.C1318
	moveq	#0,d2
.C131A	move.b	(a3),d1
	beq.b	C1358
	cmp.b	#SRCMARK_END,d1
	beq.b	C1358
	cmp.b	#9,d1			; TAB
	bne.b	.C1344
	move.l	d0,-(sp)
	moveq	#-1,d0
	bsr.b	AdjustColForTab
	beq.b	.C133E
	move	d0,d2
	move.l	(sp)+,d0
	bra.b	.C1344

.C133E	or.w	#7,d2
	move.l	(sp)+,d0
.C1344	cmp	d0,d2
	bge.b	C1358
	addq.w	#1,d2
	movem.w	d0/d2/d3,-(sp)
	bsr.b	E_NextCharacter
	movem.w	(sp)+,d0/d2/d3
	bra.b	.C131A

AdjustColForTab:
	movem.l	d1/a0,-(sp)
	move	d0,d1
	sf	(HaveCustomTab-DT,a4)
	lea	(CustomTabs-DT,a4),a0
.C1368	move	(a0)+,d0
	beq.b	.C1378
	add	d1,d0
	cmp	d2,d0
	bmi.b	.C1368
	st	(HaveCustomTab-DT,a4)
.C1378
	movem.l	(sp)+,d1/a0
	tst.b	(HaveCustomTab-DT,a4)
C1358:
	rts

ParseCustomTabs:
	movem.l	d0/d1/a0-a2,-(sp)
	lea	(CustomTabs-DT,a4),a1
	move.l	(sourcestart-DT,a4),d0
	beq.b	.C13C8
	move.l	d0,a0
	cmp.b	#';',(a0)+
	bne.b	.C13C8
	lea	(39*2,a1),a2
	moveq	#0,d0
.C139E
	addq.w	#1,d0
	move.b	(a0)+,d1
	beq.b	.C13C8
	cmp.b	#'-',d1
	beq.b	.C139E
	cmp.b	#' ',d1
	beq.b	.C139E
	cmp.b	#'T',d1
	bne.b	.C13C8
	sf	(HaveCustomTab-DT,a4)
	move	d0,(a1)+
	cmp.l	a2,a1
	bne.b	.C139E
.C13C8	clr	(a1)
	movem.l	(sp)+,d0/d1/a0-a2
	rts

; ----
E_ArrowRight:
	move.w	#-1,(Oldcursorcol-DT,a4)
E_NextCharacter:
	move.b	(a3)+,d0
	cmp.b	#SRCMARK_END,d0
	beq.w	EDITOR_REINSERTCHAR_NOMARKS
	bra.w	EDITOR_INSERTCHAR_NOMARKS

; ----
E_ArrowLeft:
	move.w	#-1,(Oldcursorcol-DT,a4)
EDITOR_ARROWLEFT:
	move.b	-(a2),d0
	cmp.b	#SRCMARK_BEGIN,d0
	beq.w	EDITOR_INSERTCHAR_NOMARKS
	bra.w	EDITOR_REINSERTCHAR_NOMARKS

EDITOR_MABYMAKEHOLE:
	cmp.l	a3,a2
	beq.b	.MAKEHOLE
	rts
.MAKEHOLE
	move.w	#250,a1
EDITOR_MAKEHOLE_A1LONG:
	bset	#SB1_SOURCE_CHANGED,(SomeBits-DT,a4)
	clr	(AssmblrStatus-DT,a4)
	move.l	(Cut_Blok_End-DT,a4),a0
	move.l	a1,d1
	add.l	a0,a1
	cmp.l	(WORK_END-DT,a4),a1
	bge.b	.ERROR_MEMFULL
	add.l	d1,(sourceend-DT,a4)
	move.l	a1,(Cut_Blok_End-DT,a4)
	move.b	#SRCMARK_END,(a1)
	bra.b	C14A4
.ERROR_MEMFULL
	bsr.w	MakeReady2Exit
	jsr	(RESETMENUTEXT2).l
	bsr.w	PUTENDMARKDOWN
	bra.w	_ERROR_WorkspaceMemoryFull

MOVEMARKS:
	movem.l	d0/a0,-(sp)
	lea	(EditMarks10-DT,a4),a0
	moveq	#10-1,d0
.Loop	cmp.l	(a0)+,a2
	bgt.b	.Next
	add.l	d1,(-4,a0)
.Next	dbf	d0,.Loop
	movem.l	(sp)+,d0/a0
	rts

C14A4:
	move.l	a0,d1
	sub.l	a3,d1
	bra.b	C14BA

C14AA:	REPT	8
	move.b	-(a0),-(a1)
	ENDR
C14BA:
	subq.l	#8,d1
	bpl.b	C14AA
	addq.w	#7,d1
	bmi.b	C14C8
C14C2:
	move.b	-(a0),-(a1)
	dbra	d1,C14C2
C14C8:
	move.l	a1,a3
C14EA:
	rts

EDITOR_MOVEUP1LINE_NOSCROLL:
	bsr.b	.FINDLINESTART
	bsr.w	EDITOR_ARROWLEFT
	bsr.b	.FINDLINESTART
	bra.b	PLACECURSORRIGHT
.FINDLINESTART
	tst.b	(-1,a2)
	beq.b	C14EA
	cmp.b	#SRCMARK_BEGIN,(-1,a2)
	beq.b	C14EA
	bsr.w	EDITOR_ARROWLEFT
	bra.b	.FINDLINESTART

EDITOR_MOVEDOWN1LINE_NOSCROLL:
	cmp.b	#SRCMARK_END,(a3)
	beq.b	PLACECURSORRIGHT
	bsr.w	E_NextCharacter
	tst.b	d0			; *** Loop to the end of the line
	bne.b	EDITOR_MOVEDOWN1LINE_NOSCROLL
PLACECURSORRIGHT:
	move	(NewCursorpos-DT,a4),d3
	moveq	#0,d2
	bra.b	C1532
C1502:
	tst.b	(a3)
	beq.b	C1536
	cmp.b	#SRCMARK_END,(a3)
	beq.b	C1536
	bsr.w	E_NextCharacter
	cmp.b	#9,d0
	bne.b	C1530
	move.l	d0,-(sp)
	moveq	#-1,d0
	bsr.w	AdjustColForTab
	beq.b	C152A
	move	d0,d2
	move.l	(sp)+,d0
	bra.b	C1530

C152A:
	or.w	#7,d2
	move.l	(sp)+,d0
C1530:
	addq.w	#1,d2
C1532:
	cmp	d2,d3
	bhi.b	C1502
C1536:
	rts

; ----
E_Scroll1LineUp:	;editor scroll down
	tst.b	(PR_Keepxy).l
	beq.b	C1546
	move	(Oldcursorcol-DT,a4),(NewCursorpos-DT,a4)
C1546:
	bsr.b	EDITOR_MOVEUP1LINE_NOSCROLL
C154A:
	bsr.w	C16D8
	cmp.b	#SRCMARK_BEGIN,(-1,a2)
	beq.b	E_Scroll1Line_Done
	moveq	#1,d0
	cmp.l	(FirstLineNr-DT,a4),d0
	beq.b	E_Scroll1Line_Done
	cmp.l	(LineFromTop-DT,a4),d0
	bne.b	E_Scroll1Line_Done
	bsr.w	Show_Cursor
	bset	#SB3_COMMANDMODE,(SomeBits3-DT,a4)
	jsr	(ScrollEditorDown).l
	bsr.w	GoBack1Line
	bsr.b	Regeltab_scrolldown

E_Scoll1Line_Finish:
	move.b	#1,(SCROLLOKFLAG-DT,a4)		; >0
E_clear_input_buffer:	; KILLBUFFER
	move.w	(KEYB_KILLPTR-DT,a4),(KeyboardOutBuf-DT,a4)
E_Scroll1Line_Done:
	rts

; ----
E_ScrollDown1Line:	; editor scroll up
	tst.b	(PR_Keepxy).l
	beq.b	C159C
	move	(Oldcursorcol-DT,a4),(NewCursorpos-DT,a4)
C159C:
	bsr.w	EDITOR_MOVEDOWN1LINE_NOSCROLL
	cmp.b	#SRCMARK_END,(a3)
	beq.b	E_Scroll1Line_Done
	move.l	(NrOfLinesInEditor-DT,a4),d0
	subq.w	#3,d0
	cmp.l	(LineFromTop-DT,a4),d0
	bhs.b	E_Scroll1Line_Done
	bsr.w	Show_Cursor
	bset	#SB3_COMMANDMODE,(SomeBits3-DT,a4)
	jsr	(ScrollEditorUp).l
	bsr.w	BeginNextLine
	bsr.b	Regeltab_scrollup
	bra.b	E_Scoll1Line_Finish

;** regel tabel bijwerken **

Regeltab_scrollup:
	lea	(RegelPtrsIn-DT,a4),a0
	move.l	(NrOfLinesInEditor-DT,a4),d0
	subq.w	#2,d0
	lea	(4,a0),a1
.lopje	move.l	(a1)+,(a0)+
	dbra	d0,.lopje
.Done	moveq	#-1,d0
	move.l	d0,(a0)
	rts

Regeltab_scrolldown:
	lea	(RegelPtrsIn-DT,a4),a0
	move.l	(NrOfLinesInEditor-DT,a4),d0
	subq.w	#2,d0

	move	d0,d1
	addq.w	#1,d1

	IF MC020
	lea	(a0,d1.w*4),a0
	ELSE
	lsl	#2,d1
	add	d1,a0
	ENDC
	lea	(4,a0),a1

.lopje:
	move.l	-(a0),-(a1)
	dbra	d0,.lopje
	bra.b	Regeltab_scrollup\.Done

; ----
E_ExitEditor:
	jsr	(KEY_RETURN_LAST_KEY)

; ----
EDITOR_ESCPRESSED:
	bsr.b	MakeReady2Exit
	jsr	(RESETMENUTEXT2)
	bsr.b	PUTENDMARKDOWN
	jsr	scroll_up_cmd_fix
	jmp	(CommandlineInputHandler)

MakeReady2Exit:
	lea	(End_msg).l,a0
	jsr	(druk_status_en_end_af)
C1634:
	move.l	(FirstLinePtr-DT,a4),a0
	move.l	(LineFromTop-DT,a4),d0
	jsr	(DOWN_D0_LINES_NOHOLE)
	move.l	a0,(FirstLinePtr-DT,a4)
	move.l	(Cut_Blok_End-DT,a4),a0
	bra.b	cut_block

PUTENDMARKDOWN:
	move.l	(sourceend-DT,a4),a0
	tst.b	(-1,a0)
	beq.b	.C167C
	move.l	(Cut_Blok_End-DT,a4),a1
	move.l	a1,a2
	addq.w	#1,a2
	move.l	a1,d0
	sub.l	a0,d0
	subq.l	#1,d0
.C1664	move.b	-(a1),-(a2)
	dbra	d0,.C1664
	swap	d0
	subq.w	#1,d0
	swap	d0
	bpl.b	.C1664
	clr.b	(a0)
	addq.l	#1,(Cut_Blok_End-DT,a4)
	addq.l	#1,(sourceend-DT,a4)
.C167C	rts

KillCopybuffer:
	move.l	(sourceend-DT,a4),d0
	addq.l	#1,d0
	move.l	d0,(Cut_Blok_End-DT,a4)
	rts

; ----
cut_block:
	cmp.l	a2,a3
	beq.b	C16D0
	bset	#SB1_SOURCE_CHANGED,(SomeBits-DT,a4)	;source was changed
	clr	(AssmblrStatus-DT,a4)
	move.l	a0,d1
	sub.l	a3,d1
	bra.b	Copy_blok_in_source

C16A0:	REPT	8
	move.b	(a3)+,(a2)+
	ENDR
Copy_blok_in_source:
	subq.l	#8,d1
	bpl.b	C16A0
	addq.w	#8-1,d1
	bmi.b	C16BE
C16B8:
	move.b	(a3)+,(a2)+
	dbra	d1,C16B8
C16BE:
	move.b	#SRCMARK_END,(a2)
	move.l	(Cut_Blok_End-DT,a4),d0
	move.l	a2,(Cut_Blok_End-DT,a4)
	sub.l	a2,d0
	sub.l	d0,(sourceend-DT,a4)
C16D0:
	moveq	#13,d0
	jmp	(Druk_char_af2).l

C16D8:
	move.l	(LineFromTop-DT,a4),d0
	bra.b	C16E6

C16DE:
	move.l	(LineFromTop-DT,a4),d0
	beq.b	C16E6
	subq.w	#1,d0
C16E6:
	lea	(RegelPtrsIn-DT,a4),a0
	IF	MC020
	lea	(a0,d0.w*4),a0
	ELSE
	asl.w	#2,d0
	add	d0,a0
	ENDIF
	moveq	#-1,d0
	move.l	d0,(a0)
	rts

RegTab_SETALLNOTUPD:
	move.l	(NrOfLinesInEditor-DT,a4),d1
	lea	(RegelPtrsIn-DT,a4),a0
	moveq	#-1,d0
.lopje	move.l	d0,(a0)+
	dbra	d1,.lopje
	rts

EDITSCRPRINT:
	cmp.l	(FirstLinePtr-DT,a4),a2
	blo.b	C1718
	bsr.w	UpdateAllLines
	tst.l	(LineFromTop-DT,a4)
	bne.b	C1728
C1718:
	moveq	#1,d1
	cmp.l	(FirstLineNr-DT,a4),d1
	bhs.b	C1738
	bsr.w	MoveupNLines		; 1 line (d1)
	bra.b	EDITSCRPRINT

;************* REGEL IN EDITOR **********

C1728:
	move.l	(LineFromTop-DT,a4),d0
	cmp	(NrOfLinesInEditor_min1-DT,a4),d0
	blo.b	C1738
	bsr.w	BeginNextLine
	bra.b	EDITSCRPRINT

C1738:
	bsr.b	C16DE
	tst.b	(SCROLLOKFLAG-DT,a4)
	bmi.w	PrintStatusInfo
	bne.b	.C1750
	jsr	(messages_get)
	bne.w	PrintStatusInfo
.C1750	sf	(SCROLLOKFLAG-DT,a4)		; =0
	movem.l	d0-d7/a0-a3/a5/a6,-(sp)
C1764:
	move.l	(MainWindowHandle-DT,a4),a1
	tst.b	($1A,a1)		;bit7 menustate
	bmi.b	C1764
	move.l	(LineFromTop-DT,a4),d4
	move	d4,d1
	asl.w	#2,d1		;y in regel tab
	move.l	a6,d5
	lea	(RegelPtrsIn-DT,a4),a6
	lea	(RegelPtrsOut-DT,a4),a5
	add	d1,a6
	add	d1,a5
	move.l	a2,d6
	move.l	a3,d7

	bsr.w	get_font1

	move	(breedte_editor_in_chars-DT,a4),d1

	move	d1,d0
	swap	d1
	move	d0,d1
	btst	#0,(PR_LineNrs).l
	beq.b	C17BE
	subq.w	#6,d1
C17BE:
	move.l	(a5)+,a0
	cmp.l	(a6)+,a0
;	beq.s	.noprint

	cmp.b	#MT_DEBUGGER,(menu_tiepe-DT,a4)
	beq.b	C1804
	bclr	#SB3_COMMANDMODE,(SomeBits3-DT,a4)	;uit commandmode
	bne.b	.C17D6
	bsr.w	Show_Cursor
.C17D6:
	bsr.w	druk_wat_in_editor
;.noprint:
	move.l	(LineFromTop-DT,a4),d0
	add	d0,d0
	move	d0,(cursor_row_pos-DT,a4)
	move	(NewCursorpos-DT,a4),d0
	cmp	d1,d0
	bcs.b	C17F0
	move	d1,d0
	subq.w	#1,d0
C17F0:
	btst	#0,(PR_LineNrs).l
	beq.b	.C17FC
	addq.w	#6,d0
.C17FC:
	move	d0,(Cursor_col_pos-DT,a4)
	bsr.w	Show_Cursor
C1804:
	lea	(RegelPtrsIn-DT,a4),a6
	lea	(RegelPtrsOut-DT,a4),a5
	moveq	#0,d4

	bsr.w	get_font1
C181A:
	move.l	(a5)+,a0
	cmp.l	(a6)+,a0
	beq.b	C1824
	bsr.w	druk_wat_in_editor
C1824:
	addq.w	#1,d4
	cmp	(NrOfLinesInEditor+2-DT,a4),d4
	bne.b	C181A
	movem.l	(sp)+,d0-d7/a0-a3/a5/a6

;*************** STATUS LINE ****************
PrintStatusInfo:
	movem.l	d0-d7/a0-a3/a5/a6,-(sp)
	move.l	a2,d6
	sub.l	a3,d6

	bsr.w	get_font1	;invul stuff

	bclr	#MB1_LINE_NOT_IN_SOURCE,(MyBits-DT,a4)

	lea	(regel_buffer-DT,a4),a2		;status
	lea	(7,a2),a1	; skip 'Line'
	move.l	(FirstLineNr-DT,a4),d0
	add.l	(LineFromTop-DT,a4),d0
	bsr.w	TURBOPRLINENB_7DIGIT_Ext

	addq.l	#6,a1		; skip 'Col'
	moveq	#0,d0
	cmp.b	#MT_DEBUGGER,(menu_tiepe-DT,a4)
	beq.b	.InDbg
	move.w	(NewCursorpos-DT,a4),d0
	addq.w	#1,d0
	add.w	(YposScreen-DT,a4),d0
.InDbg	bsr.w	TURBOPRLINENB_3DIGIT

	addq.l	#8,a1		; skip 'Bytes'
	move.l	(sourceend-DT,a4),d0
	sub.l	(sourcestart-DT,a4),d0
	add.l	d6,d0
	bsr.w	TURBOPRLINENB_7DIGIT_Ext

	addq.l	#8,a1		; skip 'Free'
	movem.l	d1/a0-a1/a6,-(sp)
	move.l	(4).w,a6
	move.l	#MEMF_LARGEST|MEMF_CHIP,d1
	jsr	(_LVOAvailMem,a6)
	move.l	d0,d2
	moveq	#MEMF_ANY,d1
	jsr	(_LVOAvailMem,a6)
	movem.l	(sp)+,d1/a0-a1/a6
	moveq	#10,d1
	lsr.l	d1,d0
	lsr.l	d1,d2
	move.l	#99999,d1		; only 5 digits available
	cmp.l	d1,d0
	bls.b	.Capped
	move.l	d1,d0
.Capped	move.l	d2,-(sp)
	bsr.w	TURBOPRLINENB
	move.l	(sp)+,d0
	addq.l	#1,a1
	bsr.w	TURBOPRLINENB

	addq.l	#4,a1		; skip to flags
	moveq	#'-',d0
	tst	(AssmblrStatus-DT,a4)
	beq.b	.C1908
	moveq	#'a',d0
	cmp	#1,(AssmblrStatus-DT,a4)
	beq.b	.C1908
	moveq	#'A',d0
.C1908	bsr.w	FASTSENDONECHAR
	moveq	#'-',d0
	btst	#SB1_SOURCE_CHANGED,(SomeBits-DT,a4)
	beq.b	.C1918
	moveq	#'*',d0
.C1918	bsr.w	FASTSENDONECHAR
	moveq	#'-',d0
	btst	#SB2_MAKEMACRO,(SomeBits2-DT,a4)
	beq.b	.C1928
	moveq	#'M',d0
.C1928	bsr.w	FASTSENDONECHAR

	; *** Block marking or not
	moveq	#'-',d0
	cmp.w	#-1,a6
	beq.b	.C1938
	moveq	#'B',d0
.C1938	bsr.w	FASTSENDONECHAR

	jsr	(GetTheTime)		; returns buffer in a0
	lea	(regel_buffer-10-DT,a4),a1
	add.w	(Scr_br_chars-DT,a4),a1
	moveq	#8-1,d7
.CpTime	move.b	(a0)+,d0
	bsr.w	FASTSENDONECHAR
	dbra	d7,.CpTime

	cmp	#-1,(Oldcursorcol-DT,a4)
	bne.b	.C197E
	move.w	(Cursor_col_pos-DT,a4),d0
	add.w	(YposScreen-DT,a4),d0
	btst	#0,(PR_LineNrs).l
	beq.b	.NoLineNrs
	subq.w	#6,d0
.NoLineNrs
	move.w	d0,(Oldcursorcol-DT,a4)
.C197E
	movem.l	(sp)+,d0-d7/a0-a3/a5/a6
	rts

Show_Cursor:
	movem.l	d7/a5/a6,-(sp)
	st	(reset_pos-DT,a4)
	jsr	(Place_cursor_blokje).l
	movem.l	(sp)+,d7/a5/a6
	rts

;**********************************************************
;print text in the editor..

druk_wat_in_editor:
	move.l	a0,(-4,a6)
	beq.w	clear_2_eol_edit

	lea	(regel_buffer-DT,a4),a1
	move.l	a1,a2
	clr.l	(Edit_begin-DT,a4)

	move	(YposScreen-DT,a4),-(sp)

	btst	#0,(PR_LineNrs).l		;line numbers printen..
	beq.b	Print_LineNbrs

;	bset	#MB1_LINE_NOT_IN_SOURCE,(MyBits-DT,a4)

	movem.l	d0-a6,-(sp)

	move.l	(FirstLineNr-DT,a4),d0
	add.l	d4,d0

	lea	(regel_buffer-DT,a4),a1
	move.l	a1,a2

	moveq	#5-1,d7
.lopje:
	divu.w	#10,d0
	swap	d0
	bne.b	.nietmaskeren
	move.b	#' '-'0',d0
.nietmaskeren
	add.b	#'0',d0
	move.b	d0,(a1,d7.w)
	clr.w	d0
	swap	d0
	dbf	d7,.lopje

	addq.l	#5,a1

	move.b	#' ',(a1)+

	bsr.w	print_regel_in_editor
	lea	(regel_buffer-DT,a4),a1
	move.l	a1,a2

	movem.l	(sp)+,d0-a6
Print_LineNbrs:
	moveq	#0,d2
	add	(YposScreen-DT,a4),d1

	bclr	#MB1_BACKWARD_SELECT,(MyBits-DT,a4)
; *** Handles empty block
;	cmp.l	d5,d6
;	beq.b	.noprobsb
;	bhi.s	.noprobsb
;	cmp.l	#-1,d5
;	beq.s	.noprobsb
;	cmp.l	#-1,d6
;	beq.s	.noprobsb

;	exg	d5,d6
;	moveq	#-1,d5
;	moveq	#-1,d6
;	bset	#MB1_BACKWARD_SELECT,(MyBits-DT,a4)

.noprobsb:
	bclr	#MB1_BLOCKSELECT,(MyBits-DT,a4)
rrr:
	cmp.l	a0,d5		;top ->|
	bhs.b	Edit_txt1
	cmp.l	a0,d6		;|->bot
	bls.b	Edit_txt1

	bsr.w	get_font2		;rest regels markblok

	bset	#MB1_BLOCKSELECT,(MyBits-DT,a4)

Edit_txt1:
	cmp.l	a0,d5
	bne.b	.Edit_txt2

	btst	#MB1_BACKWARD_SELECT,(MyBits-DT,a4)
;	bra.b	Verderbackwards
	bne.s	.noprint

;	cmp.l	d5,d6
;	beq.w	.noprint

	bsr.w	print_regel_in_editor
.noprint:

	lea	(regel_buffer-DT,a4),a1
	move.l	a1,a2

	bsr.w	get_font2		;eerste regel markblok
	bset	#MB1_BLOCKSELECT,(MyBits-DT,a4)
.Edit_txt2:
	cmp.l	a0,d6
	bne.b	.Edit_txt3
	move.l	d7,a0

	btst	#MB1_BACKWARD_SELECT,(MyBits-DT,a4)
	bne.b	.noprint2
	bsr.w	print_regel_in_editor
.noprint2:
	lea	(regel_buffer-DT,a4),a1
	move.l	a1,a2

	bclr	#MB1_BLOCKSELECT,(MyBits-DT,a4)
	bsr.w	get_font1
.Edit_txt3:

Verderbackwards:
	moveq	#0,d0
	move.b	-1(a0),d3
	move.b	(a0)+,d0
	beq.w	einde_regel_ed		;klaar exit

	tst.b	PR_SyntaxColor
	beq.w	.verder
	cmp.w	#1,(Scr_NrPlanes-DT,a4)
	beq.w	.verder

	btst	#SC1_WHITESP,(ScBits-DT,a4)
	bne.w	.endwhitespace

	btst	#SC1_OPCODE,(ScBits-DT,a4)
	bne.w	.endopcode

	btst	#SC1_LABEL,(ScBits-DT,a4)
	bne.s	.label

	btst	#SC1_COMMENTAAR,(ScBits-DT,a4)
	bne.w	.verder

;	btst	#SC1_NOTBEGINLINE,(ScBits-DT,a4)
;	bne.s	.nietbegin
;	bset	#SC1_NOTBEGINLINE,(ScBits-DT,a4)

	btst	#SC1_NOTBEGINLINE,(ScBits-DT,a4)
	bne.b	.noopcode
	cmp.b	#9,d0
	beq.w	.opcode
	cmp.b	#' ',d0
	beq.w	.opcode
.noopcode:

	cmp.b	#';',d0
	beq.w	.commentaar
	cmp.b	#'*',d0
	bne.s	.checklabel
	cmp.b	#'-',(a0)
	beq.w	.verder
	cmp.b	#9,-2(a0)
	beq.s	.commentaar
	cmp.b	#' ',-2(a0)
	beq.s	.commentaar
	btst	#SC1_NOTBEGINLINE,(ScBits-DT,a4)
	beq.b	.commentaar

;.nocommentaar:
;	btst	#SC1_NOTBEGINLINE,(ScBits-DT,a4)
;	beq.w	.verder

;label gedoe
.checklabel
	btst	#SC1_NOTBEGINLINE,(ScBits-DT,a4)
	bne.w	.verder

;	cmp.b	#' ',d0
;	beq.w	.verder
;	cmp.b	#9,d0
;	beq.w	.verder
	cmp.b	#SRCMARK_END,d0
	beq.w	.verder

	move.w	#SC2_LABEL,(ScColor-DT,a4)
	bset	#SC1_LABEL,(ScBits-DT,a4)
	bra.w	.verder

.label:
	cmp.b	#':',-2(a0)	;d0
	beq.s	.oklabel
	cmp.b	#9,d0
	beq.s	.oklabel
	cmp.b	#' ',d0
	beq.s	.oklabel
	cmp.b	#'=',d0		;een= 20
	bne.w	.verder

.oklabel:
	bsr.w	print_regel_in_editor
	bclr	#SC1_LABEL,(ScBits-DT,a4)
	lea	(regel_buffer-DT,a4),a1
	move.l	a1,a2

	bset	#SC1_WHITESP,(ScBits-DT,a4)
	move.w	#SC2_OPCODE,(ScColor-DT,a4)
	bra.w	.verder

.commentaar:
	cmp.b	#"'",d3		;moet nog check voor 2x" of ' komen
	beq.w	.verder
	cmp.b	#'"',d3
	beq.s	.verder

	bsr.w	print_regel_in_editor

	move.w	#SC2_COMMENTAAR,(ScColor-DT,a4)
	bset	#SC1_COMMENTAAR,(ScBits-DT,a4)
	lea	(regel_buffer-DT,a4),a1
	move.l	a1,a2
.noprobs2:
	bra.b	.verder

.opcode:
	bset	#SC1_WHITESP,(ScBits-DT,a4)
	bra.b	.verder

.endwhitespace:
	cmp.b	#9,d0
	beq.s	.verder
	cmp.b	#' ',d0
	beq.s	.verder

	bclr	#SC1_WHITESP,(ScBits-DT,a4)

	cmp.b	#';',d0
	beq.s	.commentaar
	cmp.b	#'*',d0
	beq.s	.commentaar

	bsr.w	print_regel_in_editor
	lea	(regel_buffer-DT,a4),a1
	move.l	a1,a2

	move.w	#SC2_OPCODE,(ScColor-DT,a4)
	bset	#SC1_OPCODE,(ScBits-DT,a4)
	bra.b	.verder

;.opcode:
;	move.w	#SC2_OPCODE,(ScColor-DT,a4)
;	bset	#SC1_OPCODE,(ScBits-DT,a4)
;	bra.b	.verder

.endopcode:
	cmp.b	#9,d0
	beq.s	.okop
	cmp.b	#' ',d0
	bne.s	.verder
.okop:
	bsr.w	print_regel_in_editor
	bclr	#SC1_OPCODE,(ScBits-DT,a4)
	lea	(regel_buffer-DT,a4),a1
	move.l	a1,a2

	move.w	#SC2_NORMAAL,(ScColor-DT,a4)

;.anders:
;	movem.l	a0/d1,-(sp)
;	moveq	#0,d1
;	lea	syntabje,a0
;	move.b	d0,d1
;	sub.w	#'A',d1
;	bmi.s	.ok
;	cmp.b	#"A"-"G",d1
;	bhi.s	.ok
;
;	move.w	#SC2_LABEL,(ScColor-DT,a4)
;	bset	#SC1_LABEL,(ScBits-DT,a4)
;.ok:
;	movem.l	a0/d1,-(sp)

.verder:
	bset	#SC1_NOTBEGINLINE,(ScBits-DT,a4)

	cmp.b	#9,d0
	beq.b	Tab_in_source
	cmp.b	#SRCMARK_END,d0
	beq.w	Edit_eindesource
	addq.w	#1,d2
	cmp	d1,d2
	bcc.b	.Edit_txt6
.Edit_txt4:
	subq.w	#1,(sp)
	bpl.b	.Edit_txt5
	move.b	d0,(a1)+
;	bsr	print_char_editor
.Edit_txt5:
	bra.w	Edit_txt1

.Edit_txt6:
	bne.w	Edit_txt1
	move	#$00BB,d0
	bra.b	.Edit_txt4


;syntabje:
;	dc.b	0	;A
;	dc.b	1	;B
;	dc.b	0	;C
;	dc.b	0	;D
;	dc.b	0	;E
;	dc.b	0	;F
;	dc.b	0	;G
;
;	cnop	0,4

;UnFolded:
;Folded:


Tab_in_source:
	subq.w	#1,(sp)
	bmi.b	C1A88
	addq.w	#1,(sp)
.lopje:
	addq.w	#1,d2
	moveq	#0,d0
	bsr.w	AdjustColForTab
	beq.b	C1A48
	subq.w	#1,(sp)
	bmi.b	C1A58
	cmp	d2,d0
	bne.b	.lopje
	bra.w	Edit_txt1

C1A48:
	subq.w	#1,(sp)
	bmi.b	C1A58
	moveq	#7,d0
	and.w	d2,d0
	bne.b	Tab_in_source
	bra.w	Edit_txt1

C1A58:
	subq.w	#1,d2
C1A5A:
	addq.w	#1,d2
	moveq	#' ',d0
	cmp	d1,d2
	bcs.b	C1A64
	bne.b	C1A68
C1A64:
	move.b	d0,(a1)+
C1A68:
	moveq	#0,d0
	bsr.w	AdjustColForTab
	beq.b	C1A7C
	cmp	d2,d0
	bne.b	C1A5A
	bra.w	Edit_txt1

C1A7C:
	moveq	#7,d0
	and.w	d2,d0
	bne.b	C1A5A
	bra.w	Edit_txt1

C1A88:
	addq.w	#1,d2
	moveq	#' ',d0
	cmp	d1,d2
	bcs.b	C1A96
	bne.b	C1A9A
	move	#$00BB,d0
C1A96:
	move.b	d0,(a1)+
C1A9A:
	moveq	#0,d0
	bsr.w	AdjustColForTab
	beq.b	C1AB0
	cmp	d2,d0
	bne.b	Tab_in_source
	bra.w	Edit_txt1

C1AB0:
	moveq	#7,d0
	and.w	d2,d0
	bne.b	Tab_in_source
	bra.w	Edit_txt1

Edit_eindesource:
	lea	(END.MSG).l,a0
	bra.w	Edit_txt1

einde_regel_ed:
	bsr.b	print_regel_in_editor

	clr.b	(ScBits-DT,a4)
	clr.w	(ScColor-DT,a4)

	btst	#MB1_BACKWARD_SELECT,(MyBits-DT,a4)
	beq.s	.noprobs
	bclr	#MB1_BACKWARD_SELECT,(MyBits-DT,a4)
	exg	d5,d6
.noprobs:

	bsr.w	get_font1
	sub	(YposScreen-DT,a4),d1

	btst	#0,(PR_LineNrs).l
	beq.b	C1AF2
	move.l	d0,-(sp)
	moveq	#0,d0
	move	(Scr_br_chars-DT,a4),d0
	subq.w	#6,d0
	cmp	d0,d2
	blt.b	C1AEE
	move.l	(sp)+,d0
	bra.b	C1AF8

C1AEE:
	move.l	(sp)+,d0
	bra.b	C1AFC


C1AF2:
	cmp	(Scr_br_chars-DT,a4),d2
	blt.b	C1AFC
C1AF8:
	sub	(YposScreen-DT,a4),d2
C1AFC:
	addq.l	#2,sp
	cmp	d1,d2
	bmi.w	clear_2_eol_edit
	rts

;********* Druk regel in editor + syntax highlighting **********
print_regel_in_editor:
	movem.l	d0-a6,-(sp)

;	move.l	a2,d0
	move.l	(Edit_begin-DT,a4),d0	;x-offset
;	move.l	a3,d0			;x-offset

	move.l	a1,d6
	sub.l	a2,d6		;lengte string
	beq.b	.klaar

	add.l	d6,(Edit_begin-DT,a4)
;	add.l	d6,a3

	mulu.w	(EFontSize_x-DT,a4),d0

	move.w	d4,d1		;y
	mulu.w	(EFontSize_y-DT,a4),d1
	add.w	(Scr_Title_sizeTxt-DT,a4),d1	;!2

	move.l	(GfxBase-DT,a4),a6

	move.l	(Rastport-DT,a4),a1
	jsr	(_LVOMove,a6)

	lea	(fontcolortab,pc),a2		; select text/bg color
	btst	#MB1_BLOCKSELECT,(MyBits-DT,a4)
	beq.b	.nomarkblok
	lea	(fontcolortab_block,pc),a2
.nomarkblok
	add.w	(ScColor-DT,a4),a2
	move.l	(Rastport-DT,a4),a1
	move.w	(a2)+,d0
	jsr	(_LVOSetBPen,a6)
	move.w	(a2)+,d0
	jsr	(_LVOSetAPen,a6)

	lea	(regel_buffer-DT,a4),a0		;edit
	move.w	d6,d0				;count
	jsr	(_LVOText,a6)

.klaar:
	movem.l	(sp)+,d0-a6
	rts

;get_fontcolor:
;	movem.l	d0-d1/a0-a2/a6,-(sp)
;
;	btst	#MB1_BLOCKSELECT,(MyBits-DT,a4)
;	beq.b	.nomarkblok
;	add.w	#16,d0		;offset block mark
;
;.nomarkblok:
;	move.l	(GfxBase-DT,a4),a6
;	move.l	(Rastport-DT,a4),a1
;
;	lea	(fontcolortab,pc,d0.w),a2
;	move.w	(a2)+,d0
;	jsr	(_LVOSetBPen,a6)
;	move.w	(a2)+,d0
;	jsr	(_LVOSetAPen,a6)
;	movem.l	(sp)+,d0-d1/a0-a2/a6
;	rts


; 0=grijs 1=zwart 2=wit 3=rood
fontcolortab:
	dc.w	0,1	;SC2_NORMAAL
	dc.w	0,3	;SC2_COMMENTAAR
	dc.w	0,2	;SC2_LABEL
	dc.w	4,2	;SC2_OPCODE
fontcolortab_block:
	dc.w	1,2	;INV SC2_NORMAAL
	dc.w	1,3	;INV SC2_COMMENTAAR
	dc.w	1,2	;INV SC2_LABEL
	dc.w	1,3	;INV SC2_OPCODE

;**************************************************

clear_2_eol_edit:
	movem.l	d0-a6,-(sp)

;	sub.l	a2,a1
	move.l	(Edit_begin-DT,a4),d6
	clr.l	(Edit_begin-DT,a4)
;	move.l	a3,d6

;	move.l	a1,d6		;x-offset
	move.w	d4,d7		;y-offset

	move.l	(GfxBase-DT,a4),a6
	move.l	(Rastport-DT,a4),a1

	move.w	d6,d0		;x
	mulu.w	(EFontSize_x-DT,a4),d0

;	move.l	(LineFromTop-DT,a4),d1	;y
	move.w	d7,d1
	mulu.w	(EFontSize_y-DT,a4),d1
	add.w	(Scr_Title_sizeTxt-DT,a4),d1	;!2
	jsr	(_LVOMove,a6)

	jsr	(_LVOClearEOL,a6)
	movem.l	(sp)+,d0-a6

	rts

;***********************************************************
;info balk gedoe...

UpdateAllLines:
	move.l	(FirstLinePtr-DT,a4),a0
	lea	(RegelPtrsOut-DT,a4),a5
	move.l	a0,(a5)+

	move.l	(NrOfLinesInEditor-DT,a4),d1
	subq.l	#1,d1
;	st	(LineFromTop-DT,a4)
	move.l	d1,d3

	moveq	#9,d5
	move.b	(a2),d4
	clr.b	(a2)+
.loopje:
	rept	5
	tst.b	(a0)+
	beq.b	.EndLine
	endr
	tst.b	(a0)+
	bne.b	.loopje
.EndLine:
	cmp.l	a0,a2
	beq.b	CursorLineFound

;	cmp.b	#';',(a0)
;	bne.s	.normal
;	cmp.b	#'-',1(a0)
;	bne.s	.normal
;	bsr	Folding
;	beq.w	C1CEA		;einde source ?
;	bra.b	.Reenter

.normal:
	move.l	a0,(a5)+
;.Reenter:
	dbra	d1,.loopje
	move.b	d4,-(a2)
	rts

CursorLineFound:
	move.b	d4,-(a2)
	move.l	(-4,a5),a0
	moveq	#-1,d2
C1BBE:
	addq.w	#1,d2
	cmp.l	a0,a2
	beq.b	C1BE2
	move.b	(a0)+,d0
	cmp.b	d5,d0
	bne.b	C1BBE
	moveq	#-1,d0
	bsr.w	AdjustColForTab
	beq.b	C1BDC
	move	d0,d2
	bra.b	C1BBE

C1BDC:
	or.w	#7,d2
	bra.b	C1BBE

C1BE2:
	btst	#0,(PR_LineNrs).l
	beq.b	C1C08
	movem.l	d0/d2,-(sp)
	moveq	#0,d0
	move	(Scr_br_chars-DT,a4),d0
	subq.w	#6,d0
	cmp	d0,d2
	bge.b	C1C02
	movem.l	(sp)+,d0/d2
	bra.b	C1C08

C1C02:
	movem.l	(sp)+,d0/d2
	bra.b	C1C24
C1C08:
	cmp	(Scr_br_chars-DT,a4),d2
	bge.b	C1C24
	tst	(YposScreen-DT,a4)
	beq.b	C1C24
	movem.l	d0-a6,-(sp)
	clr	(YposScreen-DT,a4)
	bsr.w	RegTab_SETALLNOTUPD
	movem.l	(sp)+,d0-a6
C1C24:
	sub	(YposScreen-DT,a4),d2
	bsr.b	C1C60
	move	d2,(NewCursorpos-DT,a4)
	sub.l	d1,d3
	move.l	d3,(LineFromTop-DT,a4)
	move.l	a3,a0
	move.l	(sourceend-DT,a4),a1
	move.b	(a1),d4
	clr.b	(a1)+
.loopje:
	rept	5
	tst.b	(a0)+
	beq.b	.EndLine
	endr
	tst.b	(a0)+
	bne.b	.loopje
.EndLine:
	cmp.l	a0,a1
	beq.b	C1CEA

;	cmp.b	#';',(a0)
;	bne.s	.normal
;	cmp.b	#'-',1(a0)
;	bne.s	.normal
;	bsr.s	Folding
;	beq.b	C1CEA		;einde source
;	bra.b	.Reenter
;.normal:
	move.l	a0,(a5)+
.Reenter:
	dbra	d1,.loopje
	move.b	d4,-(a1)
	rts

C1CEA:	clr.l	(a5)+
	dbra	d1,C1CEA
	move.b	d4,-(a1)
	rts

;Folding:
;	move.l	a0,(a5)+	;eerste regel wel in buffer zetten
;	addq.w	#2,a0		;";-"
;.loopje2:
;	tst.b	(a0)+
;	bne.b	.loopje2
;
;	cmp.l	a0,a1
;	beq.s	.druut
;		
;	cmp.b	#';',(a0)+
;	bne.s	.loopje2
;	cmp.b	#'%',(a0)+	;end folding
;	bne.s	.loopje2
;.druut:
;	rts

C1C60:
	movem.l	d0/d1/d3-d7/a0-a6,-(sp)
C1C64:
	move.l	d2,-(sp)

	btst	#0,(PR_LineNrs).l
	beq.b	.C1C8E

	cmp	#14,d2
	blt.b	C1CC8
	move.w	d0,-(sp)
	move	(Scr_br_chars-DT,a4),d0
	subq	#7,d0
	cmp	d0,d2
	blt.b	.C1C8A
	move.w	(sp)+,d0
	bra.b	.C1CA4

.C1C8E
	cmp	#8,d2
	blt.b	C1CC8
	move.w	d0,-(sp)
	move	(Scr_br_chars-DT,a4),d0
	subq.w	#1,d0
	cmp	d0,d2
	blt.b	.C1C8A
	move.w	(sp)+,d0
.C1CA4
	cmp	#$00F8,(YposScreen-DT,a4)
	bge.b	C1CC0
	add	#12,(YposScreen-DT,a4)
	sub	#12,d2
	move.l	d2,(sp)
	bsr.w	RegTab_SETALLNOTUPD
	move.l	(sp)+,d2
	bra.b	C1C64

.C1C8A
	move.w	(sp)+,d0
C1CC0:
	move.l	(sp)+,d2
	movem.l	(sp)+,d0/d1/d3-d7/a0-a6
	rts

C1CC8:
	tst	(YposScreen-DT,a4)
	beq.b	C1CE2
	sub	#12,(YposScreen-DT,a4)
	add	#12,d2
	move.l	d2,(sp)
	bsr.w	RegTab_SETALLNOTUPD
	move.l	(sp)+,d2
	bra.b	C1C64

C1CE2:
	move.l	(sp)+,d2
	movem.l	(sp)+,d0/d1/d3-d7/a0-a6
	rts

;******** gewoon of inverse font ************

get_font:
	btst	#SB2_REVERSEMODE,(SomeBits2-DT,a4)
	bne.b	get_font2

get_font1:
	movem.l	d0-d1/a0-a1/a6,-(sp)
	move.l	(GfxBase-DT,a4),a6
	move.l	(Rastport-DT,a4),a1

	moveq	#1,d0		;black
	jsr	(_LVOSetAPen,a6)
	moveq	#0,d0		;grey
	jsr	(_LVOSetBPen,a6)
	movem.l	(sp)+,d0-d1/a0-a1/a6
	rts

get_font2:
	movem.l	d0-d1/a0-a1/a6,-(sp)
	move.l	(GfxBase-DT,a4),a6
	move.l	(Rastport-DT,a4),a1

	moveq	#2,d0		;white
	jsr	(_LVOSetAPen,a6)
	moveq	#1,d0		;black
	jsr	(_LVOSetBPen,a6)
	movem.l	(sp)+,d0-d1/a0-a1/a6
	rts

get_font3:
	movem.l	d0-d1/a0-a1/a6,-(sp)
	move.l	(GfxBase-DT,a4),a6
	move.l	(Rastport-DT,a4),a1

	moveq	#0,d0		;grey
	jsr	(_LVOSetAPen,a6)
	moveq	#1,d0		;black
	jsr	(_LVOSetBPen,a6)
	movem.l	(sp)+,d0-d1/a0-a1/a6
	rts

get_font4:
	movem.l	d0-d1/a0-a1/a6,-(sp)
	move.l	(GfxBase-DT,a4),a6
	move.l	(Rastport-DT,a4),a1

	moveq	#3,d0		;red
	jsr	(_LVOSetAPen,a6)
	moveq	#0,d0		;grey
	jsr	(_LVOSetBPen,a6)
	movem.l	(sp)+,d0-d1/a0-a1/a6
	rts

get_font5:
	movem.l	d0-d1/a0-a1/a6,-(sp)
	move.l	(GfxBase-DT,a4),a6
	move.l	(Rastport-DT,a4),a1

	moveq	#3,d0		;red
	jsr	(_LVOSetAPen,a6)
	moveq	#1,d0		;black
	jsr	(_LVOSetBPen,a6)
	movem.l	(sp)+,d0-d1/a0-a1/a6
	rts

;********** print de chars in status bar (+linenrs)  **********

FASTSENDONECHAR:		; must preserve all regs!
	movem.l	d0-d1/a0-a1/a6,-(sp)	; d0 must be last on stack!

	move.l	a1,d0
	sub.l	a2,d0		;x

	move.l	(GfxBase-DT,a4),a6
	move.l	(Rastport-DT,a4),a1

	mulu.w	(EFontSize_x-DT,a4),d0

	btst	#MB1_LINE_NOT_IN_SOURCE,(MyBits-DT,a4)
	bne.s	.okay
	move.w	(NrOfLinesInEditor+2-DT,a4),d1	;y
	mulu.w	(EFontSize_y-DT,a4),d1
	addq.w	#2,d1
	bra.b	.okay2
.okay:
	move.w	d4,d1		;y
	mulu.w	(EFontSize_y-DT,a4),d1
.okay2:
	add.w	(Scr_Title_sizeTxt-DT,a4),d1	;!2
	jsr	(_LVOMove,a6)

	lea	(3,sp),a0	; d0 bottom byte has the char
	moveq	#1,d0		;count
	jsr	(_LVOText,a6)

	movem.l	(sp)+,d0-d1/a0-a1/a6
	addq.l	#1,a1
	rts

;****** PRINT LINE NUMBERS en REST GETALLEN STATUS BAR ********

TURBOPRLINENB_4DIGIT:
	and.l	#$0000FFFF,d0
	bra.b	TURBOPRLINENB_4DIG_GO

TURBOPRLINENB_3DIGIT:
	and.l	#$0000FFFF,d0
	moveq	#" ",d2
	bra.b	TURBOPRLINENB_3DIG_GO

TURBOPRLINENB:
;	and.l	#$0000FFFF,d0
	moveq	#' ',d2

	divu	#10000,d0
	beq.b	.Z1
	moveq	#'0',d2
.Z1:
	add.b	d2,d0
	bsr.b	FASTSENDONECHAR
	clr	d0
	swap	d0
TURBOPRLINENB_4DIG_GO:
	divu	#1000,d0
	beq.b	.Z2
	moveq	#'0',d2
.Z2:
	add.b	d2,d0
	bsr.b	FASTSENDONECHAR
	clr	d0
	swap	d0
TURBOPRLINENB_3DIG_GO:
	divu	#100,d0
	beq.b	.Z3
	moveq	#'0',d2
.Z3:
	add.b	d2,d0
	bsr.w	FASTSENDONECHAR
	clr	d0
	swap	d0
	divu	#10,d0
	beq.b	.Z4
	moveq	#'0',d2
.Z4:
	add.b	d2,d0
	bsr.w	FASTSENDONECHAR
	swap	d0
	moveq	#'0',d2
	add.b	d2,d0
	bra.w	FASTSENDONECHAR

TURBOPRLINENB_7DIGIT_Ext:
	divu	#10000,d0
	move.l	d0,-(sp)
	bsr.b	TURBOPRLINENB_7DIGIT
	move.l	(sp)+,d0
	swap	d0
	bra.b	TURBOPRLINENB_4DIGIT

TURBOPRLINENB_7DIGIT:
	and.l	#$0000FFFF,d0
	moveq	#' ',d2
	divu	#100,d0
	beq.b	.Z3
	moveq	#'0',d2
.Z3:
	add.b	d2,d0
	bsr.w	FASTSENDONECHAR
	clr	d0
	swap	d0
	divu	#10,d0
	beq.b	.Z4
	moveq	#"0",d2
.Z4:
	add.b	d2,d0
	bsr.w	FASTSENDONECHAR
	clr	d0
	swap	d0
	beq.b	.Z5
	moveq	#'0',d2
.Z5:
	add.b	d2,d0
	bra.w	FASTSENDONECHAR


;;*******************************************************
;*							*
;*	    EDITOR CONTROL CODES AND COMMANDS		*
;*							*
;********************************************************

;******************************
;*    REGISTRATE REGISTERS    *
;******************************

E_UsedRegisters:
	movem.l	d0-d6/a0-a3/a5/a6,-(sp)
	cmp.l	a6,a2
	bls.w	C1F0E
	move.l	a2,a0
	bsr.w	C1F6C
	lea	(1,a0),a2
	move.l	a6,a0
	bsr.w	C1F6C
	moveq	#0,d5
C1DEE:
	bsr.w	C1F78
C1DF2:
	cmp.b	#"!",d0
	beq.w	C1F64
	cmp.b	#";",d0
	beq.w	C1F64
	cmp.b	#'"',d0
	beq.w	C1F54
	cmp.b	#"`",d0
	beq.w	C1F54
	cmp.b	#"'",d0
	beq.w	C1F54
	cmp.b	#9,d0
	beq.b	C1E3A
	cmp.b	#",",d0
	beq.b	C1E3A
	cmp.b	#"/",d0
	beq.b	C1E3A
	cmp.b	#"(",d0
	beq.b	C1E3A
	cmp.b	#" ",d0
	beq.b	C1E3A
	bra.b	C1DEE

C1E3A:
	moveq	#0,d6
	bsr.w	C1F78
	cmp.b	#"D",d0
	beq.b	C1E50
	cmp.b	#"A",d0
	beq.b	C1E4E
	bra.b	C1DF2

C1E4E:
	addq.w	#8,d6
C1E50:
	bsr.w	C1F78
	cmp.b	#"0",d0
	bcs.b	C1DF2
	cmp.b	#"7",d0
	bhi.b	C1DF2
	sub.b	#"0",d0
	add.b	d0,d6
	bsr.w	C1F78
	beq.b	C1E98
	cmp.b	#9,d0
	beq.b	C1E98
	cmp.b	#")",d0
	beq.b	C1E98
	cmp.b	#" ",d0
	beq.b	C1E98
	cmp.b	#".",d0
	beq.b	C1E98
	cmp.b	#"/",d0
	beq.b	C1E98
	cmp.b	#"-",d0
	beq.b	C1E9E
	cmp.b	#",",d0
	bne.w	C1DF2
C1E98:
	bset	d6,d5
	bra.w	C1DF2

C1E9E:
	moveq	#0,d1
	bset	d6,d1
	subq.w	#1,d1
	not.w	d1
	bset	d6,d5
	moveq	#0,d6
C1EAA:
	bsr.w	C1F78
	cmp.b	#" ",d0
	beq.b	C1EAA
	cmp.b	#9,d0
	beq.b	C1EAA
	cmp.b	#"D",d0
	beq.b	C1ECA
	cmp.b	#"A",d0
	bne.w	C1DF2
	addq.w	#8,d6
C1ECA:
	bsr.w	C1F78
	cmp.b	#"0",d0
	bcs.w	C1DF2
	cmp.b	#"7",d0
	bhi.w	C1DF2
	sub.b	#"0",d0
	add.b	d0,d6
	moveq	#0,d2
	bset	d6,d2
	subq.w	#1,d2
	bset	d6,d2
	bset	d6,d5
	and	d2,d1
	or.w	d1,d5
	bra.w	C1DF2

C1EF6:
	lea	(Registersused.MSG),a0
	jsr	(printTextInMenuStrip-Registersused.MSG,a0)
	tst	d5
	beq.b	C1F1E
	moveq	#"D",d2
	bsr.b	C1F2C
	moveq	#"A",d2
	bsr.b	C1F2C
C1F0E:
	movem.l	(sp)+,d0-d6/a0-a3/a5/a6
	bsr.w	E_RemoveCutMarking
	bclr	#SB1_WINTITLESHOW,(SomeBits-DT,a4)
	rts

C1F1E:
	lea	(NONE.MSG),a0
	jsr	(druk_menu_txt_verder-NONE.MSG,a0)
	bra.b	C1F0E

C149F0:
	lea	(MENUCHAR_TEXTBUFFER-DT,a4),a0
	move.b	d0,(a0)
	jmp	(druk_menu_txt_verder)

C1F2C:
	moveq	#'0',d1
C1F2E:
	lsr.w	#1,d5
	bcc.b	C1F4A
	move	d2,d0
	bsr.b	C149F0
	move	d1,d0
	bsr.b	C149F0
	moveq	#" ",d0
	bsr.b	C149F0
C1F4A:
	addq.b	#1,d1
	cmp.b	#"8",d1
	bne.b	C1F2E
	rts

C1F54:
	move.b	d0,d1
C1F56:
	bsr.b	C1F78
	beq.w	C1DEE
	cmp.b	d1,d0
	bne.b	C1F56
	bra.w	C1DEE

C1F64:
	bsr.b	C1F78
	bne.b	C1F64
	bra.w	C1DEE

C1F6C:
	move.b	-(a0),d0
	beq.b	C1F76
	cmp.b	#SRCMARK_BEGIN,d0
	bne.b	C1F6C
C1F76:
	rts

C1F78:
	cmp.l	a0,a2
	beq.b	C1F92
	move.b	(a0)+,d0
	cmp.b	#SRCMARK_END,d0
	beq.b	C1F92
	cmp.b	#"a",d0
	bcs.b	C1F8E
	sub.b	#" ",d0
C1F8E:
	tst.b	d0
	rts

C1F92:
	addq.l	#4,sp
	bra.w	C1EF6

; ----
E_Mark_blok:
	cmp.w	#-1,a6
	bne.w	E_RemoveCutMarking
	move.l	a2,a6			; *** Start address
;	bsr	EDITOR_MOVEDOWN1LINE_NOSCROLL
;	bsr	EDITOR_MOVEUP1LINE_NOSCROLL
;	bsr	C16D8
	bra.w	RegTab_SETALLNOTUPD

; ----
E_Cut_Block:
	moveq	#0,d1
	cmp.w	#-1,a6
	beq.b	.NOBEGIN

	cmp.l	a6,a2			; *** Empty block ?
	beq.b	.NOBEGIN
	bgt.b	.wrongway
	exg	a2,a6
	st	(BlokBackwards-DT,a4)
.wrongway:
	bset	#SB1_SOURCE_CHANGED,(SomeBits-DT,a4)
	move.l	(sourceend-DT,a4),a0
	addq.w	#1,a0
	move.l	a6,d1
	sub.l	a2,d1
	move.l	a0,a1
	sub.l	d1,a1
	cmp.l	(WORK_ENDTOP-DT,a4),a1
	bge.b	.NOBEGIN
	move.l	a6,a1
.lopje:
	move.b	(a1)+,(a0)+
	cmp.l	a2,a1
	bne.b	.lopje
	bsr.w	MOVEMARKS
	tst.b	(BlokBackwards-DT,a4)
	beq.b	.notwrongway2
	exg	a2,a6
.notwrongway2:
	move.l	a6,a2
	move.b	#SRCMARK_END,(a0)
	move.l	a0,(Cut_Blok_End-DT,a4)
.NOBEGIN:
	sf	(BlokBackwards-DT,a4)
	bra.w	E_RemoveCutMarking

; ----
E_Copy_blok:
	lea	(EditMarks10-DT,a4),a0
	moveq	#10-1,d1
.Save	move.l	(a0)+,-(sp)
	dbf	d1,.Save
	move.l	a2,-(sp)
	bsr.b	E_Cut_Block
	bclr	#SB1_SOURCE_CHANGED,(SomeBits-DT,a4)
	move.l	(sp)+,a2
	lea	(EditMarks10+10*4-DT,a4),a0
	moveq	#10-1,d1
.Restore
	move.l	(sp)+,-(a0)
	dbf	d1,.Restore
	rts

; ----
E_SmartPast:
	move	(NewCursorpos-DT,a4),-(sp)
	bsr.b	E_Fill
	bsr.w	E_Move2BegLine
	move	(sp)+,(NewCursorpos-DT,a4)
	bra.w	EDITOR_MOVEDOWN1LINE_NOSCROLL

; ----
E_ClipPast:
	IF	CLIPBOARD

	move.l	(sourceend-DT,a4),a0
;	move.l	(Cut_Blok_End-DT,a4),a1
	addq.w	#1,a0
;	sub.l	a0,a1

	movem.l	a0/a2-a6,-(sp)
	bsr	SetupClipboard
	bsr.b	ClipGetLength	;a1 is lengte (a1=0 -> error)
	movem.l	(sp)+,a0/a2-a6

	move.l	a1,d4
	move.l	a3,d0
	sub.l	a2,d0
	cmp.l	d4,d0
	bcc.b	.DontOpen
	cmp.l	#256,d0
	bcc.b	.NotExtra
	add	#256,a1
.NotExtra:
	bsr	EDITOR_MAKEHOLE_A1LONG
	move.l	(sourceend-DT,a4),a0
	addq.w	#1,a0
.DontOpen:
;	move.l	(Cut_Blok_End-DT,a4),a1
	cmp.l	a2,a3
	beq.b	.End
	move.l	a3,d0
	sub.l	a2,d0
	cmp.l	d4,d0
	bcs.b	.End

	move.l	d4,d0	;lengte?
	move.l	d0,d1
	bsr	MOVEMARKS

	bsr.b	ClipRead2Buf
	add.l	d4,a0
	add.l	d4,a2

	bset	#SB1_SOURCE_CHANGED,(SomeBits-DT,a4)
.End:
	br	RegTab_SETALLNOTUPD

ClipRead2Buf:
	movem.l	a0/a2-a6,-(sp)
	move.l	4.w,a6
	move.l	(ClipIoReq-DT,a4),a1
	move.l	a2,io_Data(a1)
	move.l	(dataheader+16-DT,a4),io_Length(a1)
	jsr	_LVODoIO(a6)
	movem.l	(sp)+,a0/a2-a6
	rts

ClipGetLength:
	move.l	4.w,a6
	move.l	(ClipIoReq-DT,a4),a1
	clr.l	io_Offset(a1)
	clr.b	io_Error(a1)
	clr.l	io_ClipID(a1)

	move.w	#CMD_READ,io_Command(a1)
	lea	(dataheader-DT,a4),a2
	move.l	a2,io_Data(a1)
	moveq	#20,d0
	move.l	d0,io_Length(a1)
	jsr	_LVODoIO(a6)

	;"FORMxxxxFTXTCHRSxxxx"
	cmp.l	#'FTXT',(8,a2)
	bne.s	.errorNoTxt
	cmp.l	#'CHRS',(12,a2)
	bne.s	.errorNoTxt
	move.l	(16,a2),a1
	rts

.errorNoTxt:
	sub.l	a1,a1	;noclip
	rts

FinishClipboard:
	move.l	4.w,a6
	;read with offset past the end of the clip to signify the end..
	move.l	(ClipIoReq-DT,a4),a1
	move.w	#CMD_READ,io_Command(a1)
	clr.l	io_Data(a1)
	moveq	#1,d0
	move.l	d0,io_Length(a1)
	jmp	_LVODoIO(a6)

CloseClipboard:
	move.l	4.w,a6
;	move.l	(ClipIoReq-DT,a4),a1
;	jsr	_LVOAbortIO(a6)
	move.l	(ClipIoReq-DT,a4),a1
	jsr	_LVOCloseDevice(a6)

	move.l	(ClipIoReq-DT,a4),a0
	jsr	_LVODeleteIORequest(a6)

	move.l	(ClipMsgport-DT,a4),a0
	jmp	_LVODeleteMsgPort(a6)


SetupClipboard:
	move.l	4.w,a6
	jsr	_LVOCreateMsgPort(a6)
	move.l	d0,(ClipMsgport-DT,a4)

	move.l	d0,a0		;msg port
	moveq	#iocr_SIZEOF,d0		;size
	jsr	_LVOCreateIORequest(a6)
	move.l	d0,(ClipIoReq-DT,a4)

	moveq	#0,d0		;unit
	lea	clipname(pc),a0
	moveq	#0,d1		;flags
	move.l	(ClipIoReq-DT,a4),a1	;ioRequest
	jmp	_LVOOpenDevice(a6)


clipname:
	dc.b	"clipboard.device",0
	EVEN

;***************************************************
	ENDIF

; ----
E_Fill:
	move.l	(sourceend-DT,a4),a0
	move.l	(Cut_Blok_End-DT,a4),d0
	addq.l	#1,a0
	sub.l	a0,d0
	bgt.b	.ok				;Fixed pointer bug when pasting
	rts
.ok	move.l	d0,a1

	move.l	a1,d4
	move.l	a3,d0
	sub.l	a2,d0
	cmp.l	d4,d0
	bhs.b	.DontOpen
	cmp.l	#256,d0
	bhs.b	.NotExtra
	lea	256(a1),a1			; *** Was add.w
.NotExtra:
	bsr.w	EDITOR_MAKEHOLE_A1LONG
	move.l	(sourceend-DT,a4),a0
	addq.l	#1,a0				; *** Was addq.w
.DontOpen:
	move.l	(Cut_Blok_End-DT,a4),a1
	cmp.l	a2,a3
	beq.b	.End
	move.l	a3,d0
	sub.l	a2,d0
	cmp.l	d4,d0
	blo.b	.End
	sub.l	a0,a1
	move.l	a1,d0
	move.l	d0,d1
	move.l	d1,-(a7)
	bsr.w	MOVEMARKS
	subq.l	#1,d0
	bmi.b	.End
	move.l	d0,d1
	swap	d1
.Loopje:
	move.b	(a0)+,(a2)+
	dbra	d0,.Loopje
	dbra	d1,.Loopje
	bset	#SB1_SOURCE_CHANGED,(SomeBits-DT,a4)

	; *** All this block has been added
	; Number of chars in copy block
	move.l	(a7),d1
	; Check if the editor should scroll down
	; by counting the number of line(s) we have
	; in the copy block and checking it with the caret position
	move.l	d2,-(a7)
	; (At least one line without EOL)
	moveq	#0,d2
	bsr.b	MoveDownNChars
	; d1=number of lines added
	move.l	d2,d1
	move.l	(a7)+,d2
	; Restore the values
	move.l	(NrOfLinesInEditor-DT,a4),d0
	subq.w	#1,d0
	sub.l	d1,d0
	cmp.l	(LineFromTop-DT,a4),d0
	bge.b	.NoScrollFill
	move.l	(LineFromTop-DT,a4),d1
	sub.l	d0,d1
	bsr.w	MoveDownNLines
.NoScrollFill:
	addq.l	#4,a7				; *** Discard the value
.End:	bra.w	RegTab_SETALLNOTUPD

; *** Move down N chars
; (The copy block is placed right after the
; current sourcecode in the workspace)
MoveDownNChars:
	move.l	(sourceend-DT,a4),a0
	addq.l	#1,a0
.newln	addq.l	#1,d2
.lopje	subq.l	#1,d1
	beq.b	.end
	move.b	(a0)+,d0
	beq.b	.newln
	cmp.b	#SRCMARK_END,d0
	bne.b	.lopje
.end	rts

E_WriteBlock:
	cmp.l	a6,a2
	bls.w	E_RemoveCutMarking
	movem.l	a2/a6,-(sp)
	lea	(End_msg).l,a0
	jsr	(druk_status_en_end_af).l
	moveq	#13,d0
	jsr	(Druk_char_af2).l
	bsr.w	MakeReady2Exit
	clr.l	(FileLength-DT,a4)
	bclr	#SB3_SPEC_KEYS,(SomeBits3-DT,a4)	;uit editor
	moveq	#7,d0
	jsr	scroll_up_cmd_fix
	jsr	(FileReqStuff).l
	jsr	(IO_OpenFile).l
	movem.l	(sp)+,a2/a6
	move.l	a6,d2
.nextline:
	move.l	a6,a0
.notzero:
	cmp.l	a0,a2
	beq.b	.save
	move.b	(a0)+,d0
	bne.b	.notzero
	move.l	a6,d2
	move.l	a0,a6
	movem.l	a2/a6,-(sp)
	move.l	a0,d3
	sub.l	d2,d3
	subq.l	#1,d3
	beq.b	.nosave
	jsr	(IO_WriteFile).l
.nosave:
	moveq	#1,d3
	lea	(.returnmark,pc),a0
	move.l	a0,d2
	jsr	(IO_WriteFile).l
	movem.l	(sp)+,a2/a6
	bra.b	.nextline
.save:
	move.l	a6,d2
	move.l	a0,d3
	sub.l	d2,d3
	beq.b	.nosave2
	jsr	IO_WriteFile
.nosave2:
	jsr	close_bestand		;klaar met writen
	jmp	CommandlineInputHandler

.returnmark:
	dc.w	$0A0A

E_LowercaseBlock:
	moveq	#"A",d1
	moveq	#"Z",d2
	moveq	#'a'-'A',d3
	bra.b	C216E

E_UppercaseBlock:
	moveq	#"a",d1
	moveq	#"z",d2
	moveq	#'A'-'a',d3

C216E:
	cmp.l	a6,a2
	bls.b	E_RemoveCutMarking
	bset	#SB1_SOURCE_CHANGED,(SomeBits-DT,a4)
	move.l	a6,-(sp)
C217A:
	move.b	(a6)+,d0
	cmp.b	d1,d0
	bcs.b	C218A
	cmp.b	d2,d0
	bhi.b	C218A
	add.b	d3,d0
	move.b	d0,(-1,a6)
C218A:
	cmp.l	a6,a2
	bne.b	C217A
	move.l	(sp)+,a6
; ----
E_RemoveCutMarking:
	lea	(-1).w,a6
	bra.w	RegTab_SETALLNOTUPD

; ----
; spaces to tab option
E_SpaceToTabBlock:
	moveq	#" ",d1
	cmp.l	a6,a2
	bls.b	E_RemoveCutMarking
	bset	#SB1_SOURCE_CHANGED,(SomeBits-DT,a4)
	pea.l	(a6)
DoSTT:
	cmp.b	(a6)+,d1
	bne.b	CheckSTT
	move.b	#9,(-1,a6)
CheckSTT:
	cmp.l	a6,a2
	bne.b	DoSTT
	move.l	(sp)+,a6
	bra.b	E_RemoveCutMarking

; ----
E_Rotate_Block:
	cmp.l	a6,a2
	bls.b	E_RemoveCutMarking
	bset	#SB1_SOURCE_CHANGED,(SomeBits-DT,a4)
	movem.l	a2/a6,-(sp)
C21A8:
	move.b	(a6),d0
	move.b	-(a2),(a6)+
	move.b	d0,(a2)
	cmp.l	a6,a2
	bhi.b	C21A8
	movem.l	(sp),a2/a6
	move.l	a6,a0
	addq.l	#1,a6
	move.l	a6,-(sp)
C21BC:
	tst.b	(a6)+
	bne.b	C21DA
	move.l	a6,a0
	move.l	(sp)+,a6
	move.l	a0,-(sp)
	subq.l	#1,a6
	subq.l	#1,a0
	cmp.l	a0,a6
	beq.b	C21DA
C21CE:
	move.b	(a6),d0
	move.b	-(a0),(a6)+
	move.b	d0,(a0)
	cmp.l	a6,a0
	bhi.b	C21CE
	move.l	(sp),a6
C21DA:
	cmp.l	a6,a2
	bne.b	C21BC
	move.l	(sp)+,a6
	subq.l	#1,a6
	cmp.l	a6,a2
	beq.b	C21F0
C21E6:
	move.b	(a6),d0
	move.b	-(a2),(a6)+
	move.b	d0,(a2)
	cmp.l	a6,a2
	bhi.b	C21E6
C21F0:
	movem.l	(sp),a2/a6
	move.l	a2,(FirstLinePtr-DT,a4)
	move.l	(LineFromTop-DT,a4),d1
	add.l	d1,(FirstLineNr-DT,a4)
	beq.b	C2206
	bsr.w	MoveupNLines
C2206:
	movem.l	(sp)+,a2/a6
	bra.w	E_RemoveCutMarking

; ----
E_Delete_blok:
	bset	#SB1_SOURCE_CHANGED,(SomeBits-DT,a4)
	bsr.w	E_Move2BegLine
	move.l	a6,-(sp)
	move.l	a2,a6
	bsr.w	E_Move2EndLine
	bsr.w	E_NextCharacter
	bsr.w	E_Cut_Block
	move.l	(sp)+,a6

E_Delete_Done:
	rts

E_Delete2bol:
	move.b	(-1,a2),d0
	beq.b	E_Delete_Done
	cmp.b	#SRCMARK_BEGIN,d0
	beq.b	E_Delete_Done
	bsr.w	EDITOR_Backspace
	bra.b	E_Delete2bol

E_Delete2eol:
	move.b	(a3),d0
	beq.b	E_Delete_Done
	cmp.b	#SRCMARK_END,d0
	beq.b	E_Delete_Done
	bsr.w	Delete
	bra.b	E_Delete2eol

;**********************
;*   SEARCH REPLACE   *
;**********************

E_SearchReplace_Init:
	move	#-1,(Oldcursorcol-DT,a4)
	sf	(LastFoundLine-DT,a4)
	move.l	(FirstLineNr-DT,a4),d0
	add.l	(LineFromTop-DT,a4),d0
	move.l	d0,(OldLinePos-DT,a4)
	clr.l	(OldCursorpos-DT,a4)
	rts

E_Search:
	bsr.b	E_SearchReplace_Init
	bsr.w	EDITOR_SEARCH
	bra.b	Show_lastline

E_Search2:
	bsr.b	E_SearchReplace_Init
	bsr.w	editor_gosearch2
	bra.b	Show_lastline


E_RepeatReplace:
	bsr.b	E_SearchReplace_Init
	bsr.w	RepeatReplace
	bra.b	Show_lastline

E_Replace:
	bsr.b	E_SearchReplace_Init
	bsr.w	E_SearchAndReplace

Show_lastline:
	tst.b	(LastFoundLine-DT,a4)
	bne.b	.noJump
	tst.l	(OldCursorpos-DT,a4)
	bne.b	.Jump2LastPos
	move.l	(OldLinePos-DT,a4),d0
	bra.b	.Jump2LastLine

.Jump2LastPos:
	move.l	(OldCursorpos-DT,a4),d0
.Jump2LastLine:
	bra.w	JUMPTOLINE
.noJump:
	rts


;****************************************************************
;; Changes stuff like move.l #$534F4C4F,d0 -> move.l #"SOLO",d0

E_Hex2Ascii:
Nr2Ascii:
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d3

	move.l	a3,a0
	move.b	(a0)+,d0
	cmp.b	#"$",d0
	bne.s	.dec

	addq.l	#1,d3		;gab length

.hex:
	move.b	(a0)+,d0
	cmp.b	#"0",d0
	blo.s	.klaar

	cmp.b	#"F",d0
	bls.s	.ok
	bclr	#5,d0
.ok:
	cmp.b	#"F",d0
	bhi.s	.klaar

	addq.l	#1,d3		;gab length

	sub.b	#"0",d0
	cmp.b	#9,d0
	bls.s	.hok
	subq.b	#7,d0
.hok:
	lsl.l	#4,d1
	add.l	d0,d1

	bra.b	.hex

.dec:
.moreThan4BytesError:
	rts

.klaar:
	move.l	d3,-(sp)

	moveq	#0,d0
	moveq	#0,d2
	moveq	#0,d3		;non ascii shift value :)
	moveq	#2,d4		;str length '""'

	move.l	(sourceend-DT,a4),a1
	addq.l	#1,a1
	move.b	#'"',(a1)+
	moveq	#4-1,d7
.hloop:
	rol.l	#8,d0
	rol.l	#8,d1

	tst.w	d3
	bne.s	.nomoreascii

	tst.b	d1		; bit7 set?
	bpl.b	.low

	bset	#7,d0
	bclr	#7,d1
.low:
	cmp.b	#" ",d1
	bhs.s	.printeable

.nomoreascii:
	tst.l	d2		;remove trailing zeros
	bpl.b	.noshiftt
	addq.l	#1,d3
.noshiftt:

	add.b	d1,d0
	clr.b	d1
.printeable:
	tst.b	d1
	beq.s	.nextnr

	bset	#31,d2
.zero:
	move.b	d1,(a1)+
	clr.b	d1
	addq.w	#1,d2		;size countr
	addq.w	#1,d4		;str len
.nextnr:
	dbf	d7,.hloop

.exit:
	cmp.w	#4,d2		;check the size
	bhi.b	.moreThan4BytesError	;error if more than 4 bytes

	move.b	#'"',(a1)+
	bclr	#31,d2		;reset 
nr2AsciiFinish:

	tst.w	d3
	beq.s	.noshift

	move.b	#'<',(a1)+
	move.b	#'<',(a1)+

	move.b	#'(',(a1)+
	add.b	#"0",d3
	move.b	d3,(a1)+

	move.b	#'*',(a1)+
	move.b	#'8',(a1)+
	move.b	#')',(a1)+
	addq.w	#7,d4		;str len

.noshift
	tst.l	d0
	beq.s	.exit2

	move.b	#'+',(a1)+	;add ascii nr 128+ mask if apropriate
	move.b	#'$',(a1)+
	addq.w	#2,d4		;str len

	moveq	#8-1,d7
.lopje:	
	rol.l	#4,d0
	moveq	#$0f,d1
	and.b	d0,d1
	bne.s	.notZero

	tst.l	d2	; bit31 set?
	bpl.b	.nextnr
	bra.b	.zero	
.notZero:
	bset	#31,d2
.zero:
	add.b	#"0",d1
	move.b	d1,(a1)+
	addq.w	#1,d4		;str len

.nextnr:
	dbf	d7,.lopje

.exit2:
	clr.b	(a1)		;end of string

	move.l	(sourceend-DT,a4),a0
	lea	(1,a0,d4.l),a0
	move.l	a0,(Cut_Blok_End-DT,a4)


	bsr.w	E_Fill
	bsr.w	KillCopybuffer

	move.l	(sp)+,d3
	subq.w	#1,d3
.lopje2
	bsr.w	Delete
	dbf	d3,.lopje2

	bset	#SB1_SOURCE_CHANGED,(SomeBits-DT,a4)
	bra.w	RegTab_SETALLNOTUPD

;************************************************************8

E_SearchAndReplace:
	movem.l	d1/a0/a5/a6,-(sp)
	sf	(CaseSenceSearch-DT,a4)
	btst	#0,(PR_ReqLib).l
	beq.b	Druk_Searchfor
	btst	#0,(PR_ExtReq).l
	beq.b	Druk_Searchfor

	movem.l	d0/a0-a3/a6,-(sp)
	lea	(CurrentAsmLine-DT,a4),a1
	clr.b	(a1)
	moveq	#" ",d0
	lea	(Searchandrepl.MSG).l,a2
	sub.l	a3,a3
	lea	(L1E84E).l,a0
	move.l	(ReqToolsbase-DT,a4),a6
	jsr	(_LVOrtGetStringA,a6)
	cmp	#1,d0				; 1 = search
	beq.b	C235E
	st	(CaseSenceSearch-DT,a4)
	cmp	#2,d0				; 2 = case sensitive search
	beq.b	C235E
	movem.l	(sp)+,d0/a0-a3/a6		; 0 = abort
	bra.w	LeaveSearchAndReplace

Druk_Searchfor:
	lea	(Searchfor.MSG).l,a0
	jsr	(putThetextInMenubar).l
	bne.w	LeaveSearchAndReplace
C235E:
	lea	(CurrentAsmLine-DT,a4),a5
	lea	(SourceCode-DT,a4),a6
	move.l	a6,-(sp)
	jsr	(Filter_inputtext).l
	move.l	(sp)+,a6
	tst.b	(a6)
	beq.w	LeaveSearchAndReplace
	lea	(SourceCode-DT,a4),a0
	lea	(Searchfor_text.MSG).l,a1
.C2380
	move.b	(a0)+,(a1)+
	bne.b	.C2380
	subq.l	#1,a1

	lea	(andreplaceitw.MSG).l,a0
.lopje:
	move.b	(a0)+,(a1)+
	bne.b	.lopje
	btst	#0,(PR_ReqLib).l
	beq.b	Druk_replacewith
	btst	#0,(PR_ExtReq).l
	beq.b	Druk_replacewith
	lea	(CurrentAsmLine-DT,a4),a1
	clr.b	(a1)
	moveq	#" ",d0
	lea	(Searchandrepl.MSG).l,a2
	sub.l	a3,a3
	lea	(SearchReqTags).l,a0
	move.l	(ReqToolsbase-DT,a4),a6
	jsr	(_LVOrtGetStringA,a6)
	move.l	d0,d1
	movem.l	(sp)+,d0/a0-a3/a6
	tst.l	d1
	beq.w	LeaveSearchAndReplace
	bra.b	C23E8

Druk_replacewith:
	lea	(Replacewith.MSG).l,a0
	jsr	(putThetextInMenubar).l
	bne.w	LeaveSearchAndReplace
C23E8:
	bset	#SB1_SEARCHBUF_NE,(SomeBits-DT,a4)
	movem.l	(sp)+,d1/a0/a5/a6
RepeatReplace:
	btst	#SB1_SEARCHBUF_NE,(SomeBits-DT,a4)
	beq.w	E_Replace
	and.b	#~((1<<SB1_REPLACE_GLOB)|(1<<SB1_REPLACE_ONE)),(SomeBits-DT,a4)
ReplaceNoQuestionsAsked:
C2408:
	tst.b	(-1,a2)
	bne.b	C2416
	subq.l	#1,(FirstLineNr-DT,a4)
C2416:
	bsr.w	EDITOR_ARROWLEFT
C241A:
	bsr.w	EDITOR_SEARCH
	movem.l	d1/a0/a5/a6,-(sp)
	cmp.b	#SRCMARK_END,(a2)
	beq.w	C2530
	bsr.w	EDITSCRPRINT
	jsr	(messages_get).l
	btst	#SB1_REPLACE_GLOB,(SomeBits-DT,a4)
	bne.w	C24F8
	btst	#0,(PR_ReqLib).l
	beq.b	C24A8
	btst	#0,(PR_ExtReq).l
	beq.b	C24A8

	movem.l	a0-a6,-(sp)
	lea	(Founditshould.MSG).l,a1
	lea	(_Yes_No_Last_.MSG).l,a2
	move.l	(ReqToolsbase-DT,a4),a6
	sub.l	a4,a4				; ** A4 TMP UNAVAIL **
	sub.l	a3,a3
	lea	(L1E83A).l,a0
	jsr	(_LVOrtEZRequestA,a6)
	movem.l	(sp)+,a0-a6

	move.b	#"Y",d1
	cmp	#1,d0
	beq.b	C24A4
	move.b	#"N",d1
	cmp	#2,d0
	beq.b	C24A4
	move.b	#"L",d1
	cmp	#3,d0
	beq.b	C24A4
	move.b	#"G",d1
	cmp	#4,d0
	beq.b	C24A4
	move.b	#"X",d1
C24A4:
	move.b	d1,d0
	bra.b	C24BE

C24A8:
	lea	(ReplaceYNLG.MSG),a0
	jsr	(printTextInMenuStrip-ReplaceYNLG.MSG,a0)
	jsr	(GETKEYNOPRINT).l
	and.b	#$DF,d0
C24BE:
	cmp.b	#"Y",d0
	beq.b	C24F8
	cmp.b	#"L",d0
	beq.b	ReplaceOne
	cmp.b	#"G",d0
	beq.b	C24DE
	cmp.b	#"N",d0
	bne.b	LeaveSearchAndReplace
	movem.l	(sp)+,d1/a0/a5/a6
	bra.w	C241A

C24DE:
	or.b	#(1<<SB1_SOURCE_CHANGED)|(1<<SB1_REPLACE_GLOB),(SomeBits-DT,a4)
	st	(SCROLLOKFLAG-DT,a4)		; <0
	bra.b	C24F8

ReplaceOne:
	bset	#SB1_REPLACE_ONE,(SomeBits-DT,a4)
C24F8:
	bset	#SB1_SOURCE_CHANGED,(SomeBits-DT,a4)
	lea	(SourceCode-DT,a4),a6	;find string
	bra.b	C2508


C2504:
	bsr.w	Delete
C2508:
	tst.b	(a6)+
	bne.b	C2504
	lea	(CurrentAsmLine-DT,a4),a6	;replace string
	bra.b	ReplaceGedoe


ReplaceIt:
	movem.l	d1/a0/a5/a6,-(sp)
	or.b	#(1<<SB1_REPLACE_ONE)|(1<<SB1_SOURCE_CHANGED),(SomeBits-DT,a4)
	bra.b	ReplaceGedoe

C2512:
	bsr.w	EDITOR_INSERTCHAR
ReplaceGedoe:
	move.b	(a6)+,d0
	bne.b	C2512
	btst	#SB1_REPLACE_ONE,(SomeBits-DT,a4)
	bne.b	LeaveSearchAndReplace
	movem.l	(sp)+,d1/a0/a5/a6
	bra.w	C2408

LeaveSearchAndReplace:
	jsr	(RESETMENUTEXT).l
C2530:
	and.b	#~((1<<SB1_REPLACE_GLOB)|(1<<SB1_REPLACE_ONE)),(SomeBits-DT,a4)
	sf	(SCROLLOKFLAG-DT,a4)		; =0
	movem.l	(sp)+,d1/a0/a5/a6
	rts

editor_gosearch2:
	movem.l	a0/a5/a6,-(sp)
	sf	(CaseSenceSearch-DT,a4)
	btst	#0,(PR_ReqLib).l
	beq.b	C25A2
	btst	#0,(PR_ExtReq).l
	beq.b	C25A2
	movem.l	d0/a0-a3/a6,-(sp)
	lea	(CurrentAsmLine-DT,a4),a1
	clr.b	(a1)
	moveq	#" ",d0
	lea	(Search.MSG).l,a2
	sub.l	a3,a3
	lea	(L1E84E).l,a0
	move.l	(ReqToolsbase-DT,a4),a6
	jsr	(_LVOrtGetStringA,a6)
	cmp	#1,d0				; 1 = sarch
	beq.b	SEARCHFOR
	st	(CaseSenceSearch-DT,a4)
	cmp	#2,d0				; 2 = case sensitive search
	beq.b	SEARCHFOR
	movem.l	(sp)+,d0/a0-a3/a6		; 0 = abort
	bra.b	SCRF_END

C25A2:
	lea	(Searchfor.MSG).l,a0
	jsr	(putThetextInMenubar).l
	bne.b	SCRF_END
	bra.b	C25B6

;******************
;*   SEARCH FOR   *
;******************

SEARCHFOR:
	movem.l	(sp)+,d0/a0-a3/a6
C25B6:
	lea	(CurrentAsmLine-DT,a4),a5
	lea	(SourceCode-DT,a4),a6
	jsr	(Filter_inputtext).l
	movem.l	(sp)+,a0/a5/a6
	bra.b	EDITOR_SEARCH

SCRF_END:
	jsr	(RESETMENUTEXT).l
	movem.l	(sp)+,a0/a5/a6
	rts

;**********************
;*    JUMP TO LINE    *
;**********************

; D0 = Line

JUMPTOLINE:
	tst.l	d0
	beq.b	C2600
	move.l	(FirstLineNr-DT,a4),d1

	sub.l	d0,d1
	beq.b	C2600
	bpl.b	C25F8
	not.l	d1
	bsr.w	MoveDownNLines
	bra.w	C1146

C25F8:
	bsr.w	MoveupNLines
	bra.w	C110E

C2600:
	rts

;*********************
;*   MAIN ROT JUMP   *
;*********************

E_Jump2Marking:
	movem.l	d1-d6/a0/a5/a6,-(sp)
	lea	DoubleSemicol,a6	;search for ";;"
	bra.b	EDITOR_SEARCH_A6

;*******************
;*  EDITOR SEARCH  *
;*******************

EDITOR_SEARCH:
	movem.l	d1-d6/a0/a5/a6,-(sp)
	lea	(SourceCode-DT,a4),a6	;search string
EDITOR_SEARCH_A6:
	lea	(Searching.MSG),a0
	jsr	(printTextInMenuStrip-Searching.MSG,a0)
	move.l	(LineFromTop-DT,a4),d0
	add.l	d0,(FirstLineNr-DT,a4)
	moveq	#SRCMARK_END,d5
	cmp.b	(a3),d5
	beq.b	.THEEND2
	move.b	(a3)+,(a2)+
	bne.b	.NOTNEW
	addq.l	#1,(FirstLineNr-DT,a4)
.NOTNEW
	move.b	(a6)+,d2			; 1st char to match (u-case)
	beq.b	.THEEND
	move.b	d2,d3
	cmp.b	#"A",d2
	blo.b	.SET
	add.b	#'a'-'A',d3			; 1st char to match (l-case)
.SET
	moveq	#~('a'-'A'),d4
	or.b	(CaseSenceSearch-DT,a4),d4	; coverter (case $ff, no case $df)
	moveq	#'a',d6
	move.l	a6,a5
	bra.b	.LOOP0
.LineEnd
	addq.l	#1,(FirstLineNr-DT,a4)
.LOOP0:
	move.b	(a3)+,d0
	move.b	d0,(a2)+
	beq.b	.LineEnd

	cmp.b	d5,d0				; end of source?
	beq.b	.THEENDB
	cmp.b	d3,d0
	beq.b	.SKIPA
	cmp.b	d2,d0
	bne.b	.LOOP0
.SKIPA:
	move.l	a5,a6
	move.l	a3,a0
	move.b	(a6)+,d0			; single char search string?
	beq.b	.THEEND
.LOOP3:
	move.b	(a0)+,d1
	cmp.b	d6,d1				; lower-case char?
	blo.b	.NotLCase
	and.b	d4,d1
.NotLCase:
	cmp.b	d0,d1
	bne.b	.LOOP0
	move.b	(a6)+,d0			; all chars match?
	bne.b	.LOOP3

.THEEND:
	pea	(Found.MSG).l
	move	#-1,(Oldcursorcol-DT,a4)
	st	(LastFoundLine-DT,a4)
	move.l	(FirstLineNr-DT,a4),(OldCursorpos-DT,a4)
	bra.b	.THEENDB2

.THEENDB:
	pea	(Not.MSG).l
	sf	(LastFoundLine-DT,a4)
.THEENDB2:
	move.b	-(a2),-(a3)
	bne.b	.THEEND2B
	subq.l	#1,(FirstLineNr-DT,a4)
	bra.b	.THEEND2B

.THEEND2:
	pea	(Not.MSG).l
	sf	(LastFoundLine-DT,a4)
.THEEND2B:
	move.l	(sp)+,a0
	jsr	(druk_menu_txt_verder)
	movem.l	(sp)+,d1-d6/a0/a5/a6
	move.l	a2,a0
.LOOP4:
	move.b	-(a0),d0
	beq.b	.FOUND
	cmp.b	#SRCMARK_BEGIN,d0
	bne.b	.LOOP4
.FOUND:
	addq.l	#1,a0
	move.l	a0,(FirstLinePtr-DT,a4)
	rts

E_SelectAll:
	bsr.w	E_GotoTop
	bsr.w	E_Mark_blok

;************************
;*    BUTTOM OF TEXT    *
;************************

E_GotoBottom:
	clr	(Oldcursorcol-DT,a4)
	lea	(Bottomoftext.MSG),a0
	jsr	(printTextInMenuStrip-Bottomoftext.MSG,a0)
	movem.l	d1/d2,-(sp)
	move.l	(sourceend-DT,a4),a0
	move.l	a0,d0
	moveq	#0,d2
	sub.l	a3,d0
	subq.l	#1,d0
	bmi.b	C2734
	move.l	d0,d1
	swap	d1
C2712:
	move.b	(a3)+,(a2)+
	bne.b	C2718
	addq.l	#1,d2
C2718:
	dbra	d0,C2712
	dbra	d1,C2712
	move.l	a2,(FirstLinePtr-DT,a4)
	add.l	(LineFromTop-DT,a4),d2
	add.l	d2,(FirstLineNr-DT,a4)
	clr.l	(LineFromTop-DT,a4)
	bsr.w	GoBack1Line
C2734:
	movem.l	(sp)+,d1/d2
	bra.b	C276E

E_GotoTop:
	clr	(Oldcursorcol-DT,a4)
	lea	(Topoftext.MSG),a0
	jsr	(printTextInMenuStrip-Topoftext.MSG,a0)
	moveq	#1,d0
	move.l	d0,(FirstLineNr-DT,a4)
	move.l	(sourcestart-DT,a4),a0
	move.l	a0,(FirstLinePtr-DT,a4)
	cmp.l	a2,a0
	beq.b	C276E
.C2768
	move.b	-(a2),-(a3)
	cmp.l	a2,a0
	bne.b	.C2768
C276E:
	lea	(Done.MSG),a0
	jmp	(druk_menu_txt_verder-Done.MSG,a0)

E_100LinesUp:
	moveq	#100,d1
	bsr.w	C10AA
	bra.w	E_clear_input_buffer

E_100LinesDown:
	moveq	#100-1,d1
	bsr.w	MoveDownNLines
	bsr.w	C1146
	bsr.w	C10B0
	bra.w	E_clear_input_buffer

;;******  ASSEMBLER ROUTINE BOTH TEXT AND LINE  *********

LINE_MEMASSEM:
	moveq	#~1,d0
	jsr	(LINE_PARSE_AT_ARGS)
	bset	#SB3_REPORT_ERROR,(SomeBits3-DT,a4)
	lea	(ErrorInLine,pc),a0
	move.l	a0,(Error_Jumpback-DT,a4)
	lea	(Asm_Table,pc),a0
	move.l	a0,(Asm_Table_Base-DT,a4)
	clr.l	(CURRENT_ABS_ADDRESS-DT,a4)
	move.l	d0,(INSTRUCTION_ORG_PTR-DT,a4)
asmLoopje:
	move.l	(DATA_USERSTACKPTR-DT,a4),sp
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),d0

	move.l	d0,(MEM_DIS_DUMP_PTR-DT,a4)
	clr	(CurrentSection-DT,a4)
	jsr	(druk_af_d0_space)
	jsr	INPUTTEXT_NOTEXT
	cmp.b	#27,d0			; esc?
	beq.b	.Einde_Source
	bsr.b	Assemble_cur_line
	tst.b	d7			;AF_FINISHED
	bpl.b	asmLoopje
.Einde_Source:
	jmp	CommandlineInputHandler

ErrorInLine:
	jsr	(Print_ErrorTxt).l
	bra.b	asmLoopje

;********************
;*   Assem 1 line   *
;********************

Assemble_cur_line:
	lea	(CurrentAsmLine-DT,a4),a6
	moveq	#0,d7		;pass 2
	bset	#AF_MACROS_OFF,d7
	bsr.w	NEXTSYMBOL_SPACE
	cmp.b	#NS_ALABEL,d1
	bne.b	einderegel

;---  Remove spaces  ---
	move.l	a6,a5
.checklopje:
	move.b	(a6)+,d0
	tst.b	(Variable_base-DT,a4,d0.w)
	bmi.b	.checklopje

	subq.w	#1,a6
	btst	#AF_LOCALFOUND,d7
	bne.w	HandleMacroos
	lea	(SourceCode-DT,a4),a3
	move.l	(Asm_Table_Base-DT,a4),a0
	move	#$DFDF,d4
	moveq	#$1F,d1
	and.b	(a3),d1

	move	(a3)+,d0	;eerste 2 letters instructie
	and	d4,d0

	add.b	d1,d1
	add	(a0,d1.w),a0
	jsr	(a0)

	moveq	#0,d1
	move.b	(a6)+,d1
	beq.b	einderegel	;eol
	cmp.b	#';',d1
	beq.b	einderegel
	tst.b	(Variable_base-DT,a4,d1.w)
	bpl.b	Errorreg
einderegel:
	rts

Errorreg:
	move.l	(MEM_DIS_DUMP_PTR-DT,a4),(INSTRUCTION_ORG_PTR-DT,a4)
	bra.w	_ERROR_IllegalOperand

InitLabelArea:
	clr.l	(LocalBufPtr-DT,a4)
	clr.l	(CurrentLocalPtr-DT,a4)
	clr.l	(XDefTreePtr-DT,a4)
	bsr.w	KillCopybuffer
	bset	#0,d0
	move.l	d0,a0
	lea	(512,a0),a0
	move.b	#$7E,(a0)+
	move.l	a0,(LabelStart-DT,a4)
	btst	#0,(PR_Upper_LowerCase).l
	bne.b	.upper

	move	#64*80*4,d2
	moveq	#'a',d0
	move	#64,(Label1Entry-DT,a4)
	move	#80,(Label2Entry-DT,a4)
	move	#2,(LabelRollValue-DT,a4)
	bra.b	.C2902

.upper:
	move	#28*48*4,d2
	moveq	#'A',d0
	move	#28,(Label1Entry-DT,a4)
	move	#48,(Label2Entry-DT,a4)
	move	#1,(LabelRollValue-DT,a4)
.C2902
	lea	(ALPHA_ONE-DT,a4),a1
	lea	(ALPHA_Two,pc),a2
	moveq	#'Z'-'A',d1
.C290C	move.b	d0,(a1)+
	move.b	d0,(a2)+
	addq.b	#1,d0
	dbra	d1,.C290C

	move.l	a0,a1
	add	d2,a0
	move.l	a0,(LPtrsEnd-DT,a4)
	move.l	a0,(LabelEnd-DT,a4)
	cmp.l	(WORK_ENDTOP-DT,a4),a0
	bge.w	_ERROR_WorkspaceMemoryFull
	move.l	a1,a0
	moveq	#0,d1
	lsr.w	#2,d2
	subq.w	#1,d2
.C2932	move.l	d1,(a0)+
	dbra	d2,.C2932

	lea	(Asm_PredefSymbols,pc),a2
.AddPredef
	move.l	a4,a0
	add.w	(a2)+,a0
	moveq	#0,d0
	move.b	(a2)+,d0
	mulu.w	(Label2Entry-DT,a4),d0
	move.b	(a2)+,d1
	add.l	d1,d0
	IF MC020
	move.l	a0,(a1,d0.l*4)
	ELSE
	lsl.w	#2,d0
	move.l	a0,(a1,d0.l)
	ENDIF
	clr.l	(a0)+			; prev
	clr.l	(a0)+			; next
.CopyName
	move.w	(a2)+,(a0)+		; name
	bpl.b	.CopyName
	clr.l	(a0)+			; flags/section, value top word
	move.w	(a2)+,(a0)+		; value bottom word
	tst.w	(a2)
	bne.b	.AddPredef

	moveq	#-1,d0
	move.l	d0,(REPTN_VALUE-DT,a4)

	move.l	(LabelStart-DT,a4),a0
	move.b	#$7F,-(a0)
	move	#80,(PageWidth-DT,a4)
	move	(ScreenHight-DT,a4),(PageHeight-DT,a4)
	rts

Asm_PredefSymbols:
	DC.W	SPECIAL_SYMBOL_NARG-DT,'NA'-$4030,'RG'|$8000,0		; NARG
	DC.W	SPECIAL_SYMBOL_REPTN-DT,'RE'-$4030,'PT',('N'<<8)|$8000,0; REPTN
	DC.W	SPECIAL_SYMBOL_ASMPRO-DT,'AS'-$4030,'MP','RO'|$8000	; ASMPRO (version)
	DC.W	256*VERSION_MAJOR+VERSION_MINOR
	DC.W	0

ASSEM_RESET_SECTIONS:
	bsr.b	ASSEM_FREE_SECTION_MEM

	lea	(SECTION_START_DEFINITION-DT,a4),a0
	move.l	a0,(SectionTreePtr-DT,a4)
; We are using symtab routines to handle section list, and we need
; a fake root entry, so we add a terminated name and flags/section
; after these two ptrs (prev/next subtree).
	clr.l	(a0)+
	clr.l	(a0)+
	move.l	#($8000<<16)+1,(a0)

	clr	(CurrentSection-DT,a4)
	clr	(NrOfSections-DT,a4)
	moveq	#0,d6
	bra.b	ASSEM_MAKE_NEW_SECTION

ASSEM_FREE_SECTION_MEM:
	lea	SECTION_ABS_LOCATION-DT+4(a4),a0
	lea	SECTION_ORG_ADDRESS-DT+4(a4),a1
	lea	SECTION_TYPE_TABLE-DT+1(a4),a2
	lea	SECTION_OLD_ORG_ADDRESS-DT+4(a4),a3
	moveq	#0,d3
	move	#$00FE,d4
.Loop
	btst	#6,(a2)		; allocated?
	beq.b	.NotAlloc
	movem.l	a0/a1,-(sp)
	move.l	(a3),d0
	move.l	(a0),a1
	move.l	(4).w,a6
	jsr	(_LVOFreeMem,a6)
	movem.l	(sp)+,a0/a1
.NotAlloc
	move.l	d3,(a0)+
	move.l	d3,(a1)+
	move.b	d3,(a2)+
	move.l	d3,(a3)+
	dbra	d4,.Loop
	rts

ASSEM_MAKE_NEW_SECTION:
	move.w	(NrOfSections-DT,a4),d0
	addq.b	#1,d0			; max. 256 sections
	beq.w	_ERROR_Sectionoverflow
	move.w	d0,(NrOfSections-DT,a4)

	lea	(SECTION_TYPE_TABLE-DT,a4),a0
	move.b	d6,(a0,d0.w)
ASSEM_GET_OLD_SECTION:
	move	d0,(LastSection-DT,a4)
ASSEM_GET_OLD_SECTION_FROM_ABS:
	move	d0,(CurrentSection-DT,a4)
	lea	(SECTION_TYPE_TABLE-DT,a4),a0
	move.b	(a0,d0.w),(CURRENT_SECTION_TYPE-DT,a4)
	bpl.b	.NotBss
	bset	#AF_BSS_AREA,d7
	lea	(ConditionAssembl).l,a0
	bra.b	.Cont
.NotBss	bclr	#AF_BSS_AREA,d7
	lea	(Asm_Table,pc),a0
.Cont	move.l	a0,(Asm_Table_Base-DT,a4)
	lea	(SECTION_ORG_ADDRESS-DT,a4),a0
	IF MC020
	lea	(a0,d0.w*4),a0	
	ELSE
	lsl.w	#2,d0
	add	d0,a0
	ENDC
	move.l	(a0),(INSTRUCTION_ORG_PTR-DT,a4)
	move.l	(SECTION_ABS_LOCATION-SECTION_ORG_ADDRESS,a0),(CURRENT_ABS_ADDRESS-DT,a4)
	rts

ASSEM_RESTORE_OLD_SECTION:
	move	(CurrentSection-DT,a4),d0
	beq.b	.C2A46
	lea	(SECTION_ORG_ADDRESS-DT,a4),a0
	IF MC020
	lea	(a0,d0.w*4),a0	
	ELSE
	lsl.w	#2,d0
	add	d0,a0
	ENDC
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),(a0)
.C2A46	rts

ASSEM_INIT_SECTION_AREAS:	; done at the start of pass2
	moveq	#3,d0
	add.l	(DEBUG_END-DT,a4),d0
	moveq	#-4,d3
	and.l	d3,d0
	move.l	d0,a3
	move.l	a3,(CodeStart-DT,a4)
	lea	SECTION_ABS_LOCATION-DT+4(a4),a0
	lea	SECTION_ORG_ADDRESS-DT+4(a4),a1
	lea	SECTION_TYPE_TABLE-DT+1(a4),a2
	lea	SECTION_OLD_ORG_ADDRESS-DT+4(a4),a5
	move	(NrOfSections-DT,a4),d2
	subq.w	#1,d2
	bmi.b	C2ABA
C2A70:
	moveq	#3,d0
	add.l	(a1),d0
	clr.l	(a1)+
	and.l	d3,d0
	move.l	d0,(a5)+
	moveq	#3,d4
	and.b	(a2)+,d4
	beq.b	C2AB2
	btst	#0,(PR_AutoAlloc).l
	beq.b	C2AB2
	tst.l	d0
	beq.b	C2AB2
	movem.l	a0/a1,-(sp)
	moveq	#0,d1
	bset	d4,d1
	move.l	(4).w,a6
	jsr	(_LVOAllocMem,a6)
	movem.l	(sp)+,a0/a1
	move.l	d0,(a0)+
	beq.w	_ERROR_WorkspaceMemoryFull
	bset	#6,(-1,a2)		; mark as allocated
	bra.b	C2AB6

C2AB2:
	move.l	a3,(a0)+
	add.l	d0,a3
C2AB6:
	dbra	d2,C2A70
C2ABA:
	addq.w	#4,a3
	move.l	a3,(RelocStart-DT,a4)
	move.l	a3,(RelocEnd-DT,a4)
	cmp.l	(WORK_END-DT,a4),a3
	bcc.w	_ERROR_WorkspaceMemoryFull
	clr.l	-(a3)
	moveq	#1,d0
	bra.w	ASSEM_GET_OLD_SECTION

Asmbl_OptMode:
	moveq	#0,d7
	bset	#AF_OPTIMIZE,d7
	lea	(OptionOOptimi.MSG).l,a0
	jsr	(printthetext).l
	move.l	(sourcestart-DT,a4),(FirstLinePtr-DT,a4)
	moveq	#1,d0
	move.l	d0,(FirstLineNr-DT,a4)
	bra.w	Asmbl_Optimize

Asmbl_DebugMode:
	moveq	#0,d7
	bset	#AF_DEBUG,d7
	bra.w	Asmbl_Optimize

ASSEM_SET_PREFS:
	moveq	#0,d0
	lea	(PR_begin),a0
	btst	d0,(PR_ListFile-PR_begin,a0)
	beq.b	.C2B0E
	bset	#AF_LISTFILE,d7
.C2B0E
	btst	d0,(PR_AllErrors-PR_begin,a0)
	beq.b	.C2B1C
	bset	#AF_ALLERRORS,d7
.C2B1C
	btst	d0,(PR_Debug-PR_begin,a0)
	beq.b	.C2B2A
	bset	#AF_DEBUG,d7
.C2B2A
	btst	d0,(PR_Label-PR_begin,a0)
	beq.b	.C2B38
	bset	#AF_LABELCOL,d7
.C2B38
	btst	d0,(PR_Comment-PR_begin,a0)
	beq.b	.C2B46
	bset	#AF_SEMICOMMENT,d7
.C2B46
	btst	d0,(PR_Warning-PR_begin,a0)
	beq.b	.C2B54
	bset	#AF_PROCESRWARN,d7
.C2B54
	rts

Asm_GetTime:
	movem.l	d0-d1/a0-a1/a6,-(sp)
	move.l	(DosBase-DT,a4),a1
	move.l	(dl_TimeReq,a1),a1
	move.l	(IO_DEVICE,a1),a1
	move.l	a1,a6
	lea	(AsmStartTime-DT,a4),a0
	jsr	(_LVOGetSysTime,a6)
	movem.l	(sp)+,d0-d1/a0-a1/a6
	rts

Asm_PrintTime:
	movem.l	d0-a6,-(sp)
	move.l	(AsmStartTime-DT,a4),-(sp)
	move.l	(AsmStartTime+4-DT,a4),-(sp)
	bsr.b	Asm_GetTime
	movem.l	(AsmStartTime-DT,a4),d4/d5
	sub.l	(sp)+,d5
	bge.b	.MicrosecOK
	add.l	#1000000,d5
	subq.l	#1,d4
.MicrosecOK
	sub.l	(sp)+,d4

	lea	(.ElapsedTimeStr,pc),a0
	jsr	(printthetext)

	lea	(TABEL_HEXTODEC3),a0
	moveq	#0,d3
	move.l	d4,d0				; sec
	jsr	(PRINTDECIMAL)

	moveq	#'.',d0
	jsr	(SENDONECHARNORMAL)

	lea	(TABEL_HEXTODEC3+4*2),a0
	moveq	#'0',d3
	move.l	d5,d0				; microsec
	divu.w	#1000,d0			; to millisec
	ext.l	d0
	jsr	(PRINTDECIMAL)

	jsr	(Druk_af_eol)
	movem.l	(sp)+,d0-a6
	rts

.ElapsedTimeStr
	DC.B	"Elapsed time: ",0
	EVEN

com_assemble:
	moveq	#~32,d0
	and.b	(a6)+,d0
	cmp.b	#"S",d0		;'S' activate source <nr>
	beq.b	SetActiveSourcebuf
	lea	(AsmErrorTable-DT,a4),a1
	move.l	a1,(AsmErrorPos-DT,a4)
	st	(a1)
	sf	(AsmCheckCnly-DT,a4)
	cmp.b	#"O",d0		;'O' optimize
	beq.w	Asmbl_OptMode
	cmp.b	#"C",d0		;'C' assemble check
	beq.b	.C2B8E
	cmp.b	#"D",d0		;'D' debug
	bne.b	ReAssemble
	jmp	(Enter_debugger).l	;go debugging

.C2B8E	st	(AsmCheckCnly-DT,a4)
	bra.b	ReAssemble

SetActiveSourcebuf:
	moveq	#-"0",d0
	add.b	(a6)+,d0
	cmp.b	#9,d0
	bhi.w	_ERROR_Illegalsource
	tst.l	(EditorRegs+(8+2)*4-DT,a4)	; reg a2
	beq.b	C2BD8

SetActiveSourcebuf_D0:
	st	(FromCmdLine-DT,a4)
	move.b	d0,(Change2Source-DT,a4)
	bsr.w	Go2Sourcenow_SetCtx
	sf	(FromCmdLine-DT,a4)
	jmp	(RESETMENUTEXT2).l
C2BD8:
	rts


Start_ReAssemble:	;MESSG_REASSEM
	lea	(HReAssembling.MSG),a0
	jsr	(printthetext)
	bsr.w	E_clear_input_buffer

ReAssemble:
	moveq	#0,d7
Asmbl_Optimize:
	bsr.w	Asm_GetTime
	bsr.w	ASSEM_SET_PREFS
	move.l	#eop_irq_routine,(pcounter_base-DT,a4)
	and.b	#~((1<<SB2_INDEBUGMODE)|(1<<SB2_MATH_XN_OK)),(SomeBits2-DT,a4)
	jsr	(DEBUG_CLEAR_BP_BUFFER).l

	clr.b	(IDNT_STRING-DT,a4)
	sf	(Asm_HaveWatches-DT,a4)
	asr	(IncludeAssignStatus-DT,a4)	; check again if no assign
	move.b	(CurrentSource-DT,a4),d0
	cmp.b	(Asm_ActiveSrcNr-DT,a4),d0
	beq.b	.SameSrc
	jsr	(ZapAllCondBPsAndWatches)
	move.b	d0,(Asm_ActiveSrcNr-DT,a4)
.SameSrc
	sf	(MMUAsmBits-DT,a4)
	clr.l	(L2F118-DT,a4)

	clr.l	(JUMPPTR-DT,a4)
	clr	(NrOfErrors-DT,a4)
	clr.l	(Asm_LastErrorPos-DT,a4)
	moveq	#100,d0
	move	d0,(ProgressSpeed-DT,a4)
	move	d0,(ProgressCntr-DT,a4)
	btst	#0,(PR_Multiscroll)
	sne	(Asm_Multiscroll-DT,a4)

	lea	(HPass1.MSG).l,a0
	jsr	(beeldtextaf).l
	bsr.w	InitLabelArea
	bset	#AF_PASSONE,d7
	bsr.w	ASSEM_RESET_SECTIONS
	bsr.w	ASSEMBLERAWFILE
	btst	#AF_BRATOLONG,d7
	bne	Start_ReAssemble

	tst	(NrOfErrors-DT,a4)
	bne.b	Asm_ErrorsEncountered
	tst.b	(AsmCheckCnly-DT,a4)
	bne.b	Asm_CheckOnlyDone
	bsr.w	ASSEM_RESTORE_OLD_SECTION
	move.l	(LabelEnd-DT,a4),(DEBUG_END-DT,a4)
	and.l	#1<<AF_DEBUG,d7
	beq.b	.NoDebug
	move.l	(DATA_CURRENTLINE-DT,a4),d0
	lsl.l	#2,d0
	add.l	d0,(DEBUG_END-DT,a4)		; line debug info is 4 bytes per line (text ptr)
.NoDebug
	bsr.w	ASSEM_SET_PREFS
	bsr.w	ASSEM_INIT_SECTION_AREAS
	clr.l	(CurrentLocalPtr-DT,a4)
	bra.b	Asm_Pass2

Asm_ErrorsEncountered:
	moveq	#0,d7
	move	(NrOfErrors-DT,a4),d0
	jsr	(DrukAf_LineNrPrint).l
	jsr	Druk_Clearbuffer
	lea	(HErrorsOccure.MSG).l,a0
	jmp	(printthetext).l

Asm_CheckOnlyDone:
	moveq	#0,d7
	move	(NrOfErrors-DT,a4),d0
	jsr	(DrukAf_LineNrPrint).l
	jsr	Druk_Clearbuffer
	lea	(HSourcechecke.MSG).l,a0
	jmp	(printthetext).l

Asm_Pass2:
	lea	(HPass2.MSG).l,a0
	jsr	(beeldtextaf).l
	bsr.w	ASSEMBLERAWFILE
	btst	#AF_BRATOLONG,d7
	bne.w	Start_ReAssemble

	tst	(NrOfErrors-DT,a4)
	bne.b	Asm_ErrorsEncountered
	moveq	#0,d3
	bsr.w	ASSEM_RESTORE_OLD_SECTION
	bsr.b	.SetCodeStart
	move.l	(RelocStart-DT,a4),a0
	move.l	#$12345678,-(a0)
	sf	(Asm_Multiscroll-DT,a4)
	bsr.w	Asm_PrintTime
	lea	(HNoErrors.MSG).l,a0
	jsr	(printthetext).l
	jsr	(PRINT_SYMBOLTABELMAYBE).l
	move	#2,(AssmblrStatus-DT,a4)
	moveq	#0,d7
	rts

.SetCodeStart:
	move.l	(JUMPPTR-DT,a4),d0
	bne.b	.SetPtr
	lea	SECTION_ABS_LOCATION-DT+4(a4),a0
	lea	SECTION_ORG_ADDRESS-DT+4(a4),a1
	lea	SECTION_TYPE_TABLE-DT+1(a4),a2
	move	(NrOfSections-DT,a4),d1
	subq.w	#1,d1
.SetLop:
	move.l	(a0)+,d0
	tst.l	(a1)+		; length
	beq.b	.NotCodeSect
	moveq	#%00111100,d2
	and.b	(a2),d2
	beq.b	.SetPtr
.NotCodeSect:
	addq.l	#1,a2
	dbra	d1,.SetLop
	move.l	#eop_irq_routine,d0
.SetPtr:
	move.l	d0,(pcounter_base-DT,a4)
	move.l	d0,(MEM_DIS_DUMP_PTR-DT,a4)
	rts

ASSEM_CONTINUE:
	clr	(MACRO_LEVEL-DT,a4)
	clr	(INCLUDE_LEVEL-DT,a4)
	move.l	(TEMP_CONT_PTR-DT,a4),a0
	move.l	(TEMP_STACKPTR-DT,a4),sp
	jmp	(a0)

Asm_ResetMacroIDs:
	lea	(MACRO_LOCALNR-DT,a4),a0
	move.l	a0,(MACRO_ActiveID-DT,a4)
	clr.l	(a0)
	lea	(FIRST_INCLUDE_PTR-DT,a4),a0
.Loop	move.l	(a0),d0
	beq.b	.Done
	move.l	d0,a0
	clr.w	(10,a0)		; clear macro_id ctr
	bra.b	.Loop
.Done	rts

ASSEMBLERAWFILE:
	moveq	#0,d0
	move.b	d0,(BASEREG_BYTE-DT,a4)
	move.l	d0,(DATA_CURRENTLINE-DT,a4)
	move.b	d0,(INCLUDE_DIRECTORY-DT,a4)	; the same initial path for each pass
	move.l	(sourcestart-DT,a4),a6
	move.l	sp,(TEMP_STACKPTR-DT,a4)
	lea	(.loopje,pc),a0
	move.l	a0,(TEMP_CONT_PTR-DT,a4)
	move.w	d0,(INCLUDE_LEVEL-DT,a4)
	move.w	d0,(MACRO_LEVEL-DT,a4)
	move.w	d0,(REPT_LEVEL-DT,a4)
	lea	(ParameterBlok-DT,a4),a0
	move.l	a0,(CURRENT_MACRO_ARG_PTR-DT,a4)
	move.w	d0,(ConditionLevel-DT,a4)
	move.w	d0,(PageLinesLeft-DT,a4)
	move.w	d0,(PageNumber-DT,a4)
	move.l	d0,(RS_BASE_OFFSET-DT,a4)
	bsr.b	Asm_ResetMacroIDs
.loopje:
	addq.l	#1,(DATA_CURRENTLINE-DT,a4)
	tst.b	(DATA_CURRENTLINE+3-DT,a4)	;low byte
	bne.b	.dont_check_ctrlc
	jsr	(messages_get)
.dont_check_ctrlc
	move.l	a6,(DATA_LINE_START_PTR-DT,a4)
	INSERT_DEBUG		; trashes d0/d1/a0
	cmp.b	#SRCMARK_END,(a6)
	beq.b	.ENDOFPASS
	bsr.w	FAST_TRANSLATE_LINE
	btst	#AF_LISTFILE,d7
	beq.b	.no_print
	tst	d7		;AF_PASSONE
	bmi.b	.no_print
	jsr	(PRINT_ASSEMBLING).l
.no_print
	tst.b	d7		;AF_FINISHED
	bpl.b	.loopje
.ENDOFPASS:
	tst.w	(REPT_LEVEL-DT,a4)
	bne.w	_ERROR_UnexpectedEOF
	rts


;*   Macro found   *
; D6 = LEVEL

ASSEM_MACROFOUND:
	addq.w	#1,(MACRO_LEVEL-DT,a4)
	cmp	#MAX_MACRO_LEVEL,(MACRO_LEVEL-DT,a4)
	bhi.w	_ERROR_Macrooverflow
	move	(NARG_VALUE-DT,a4),-(sp)
	bsr.w	ASSEM_GET_MACRO_STATEMENTS	; sets a2 = args multi-string
	move.l	a6,-(sp)
	move.l	d3,a5
	move.l	(MACRO_ActiveID-DT,a4),a3
	move.l	(a3),d5
	addq.w	#1,d5
	move.l	d5,(a3)
	move.w	(ConditionLevel-DT,a4),-(sp)

.Loopje:
	bsr.w	ASSEM_CONVERTONEMACROLINE
	movem.l	d5/a2/a5,-(sp)
	bsr.w	FAST_TRANSLATE_LINE
	movem.l	(sp)+,d5/a2/a5
	bclr	#AF_MACRO_END,d7
	beq.b	.Loopje

	move.w	(sp)+,(ConditionLevel-DT,a4)
	move.l	(sp)+,a6
	clr.b	(a6)
	move	(sp)+,(NARG_VALUE-DT,a4)
	move.l	a2,(CURRENT_MACRO_ARG_PTR-DT,a4)
	subq.w	#1,(MACRO_LEVEL-DT,a4)
	move.l	(MACRO_ActiveID-DT,a4),a3
	cmp.w	(2,a3),d5		; used by a nested macro?
	bne.b	.End
	tst.l	d5			; used by this macro?
	bmi.b	.End
	subq.w	#1,(2,a3)		; unused, revert the ctr
.End:
	rts

ProgressPercentage.MSG:
	dc.b	' 000'
Complete.MSG:
	dc.b	'% Complete',13,0
Line.MSG:
	dc.b	'Line       ',13,0
TxtClearProgress:
	DCB.B	14,' '
	DC.B	13,0
	EVEN

ShowAsmProgress:
	btst	#0,(PR_Progress).l
	beq.b	No_Processindicator

	btst	#0,(PR_ProgressLine).l
	beq.b	Process_indicatorByPerc

	tst.b	(DATA_CURRENTLINE+3-DT,a4)
	bne.b	No_Processindicator

	movem.l	d0-d7/a0-a6,-(sp)
	move.l	(DATA_CURRENTLINE-DT,a4),d0

	lea	(Line.MSG,pc),a0
	jsr	(beeldtextaf).l

	lea	(Line.MSG+10,pc),a0
	moveq	#5-1,d7
.lopje:
	divu.w	#10,d0
	swap	d0
	bne.s	.nomask
	moveq	#' '-'0',d0
.nomask:
	add.b	#'0',d0
	move.b	d0,-(a0)
	clr.w	d0
	swap	d0
	dbf	d7,.lopje

C2ED0:
	movem.l	(sp)+,d0-d7/a0-a6
No_Processindicator:
	rts

Process_indicatorByPerc:
	subq.w	#1,(ProgressCntr-DT,a4)
	bne.b	No_Processindicator
	move	(ProgressSpeed-DT,a4),(ProgressCntr-DT,a4)

	movem.l	d0/d1/d2/a0,-(sp)
	move.l	a6,d0
	cmp.l	(sourceend-DT,a4),d0
	bhi.b	C2F6E
	cmp.l	(sourcestart-DT,a4),d0
	bcs.b	C2F6E
	sub.l	(sourcestart-DT,a4),d0
	move.l	(sourceend-DT,a4),d1
	sub.l	(sourcestart-DT,a4),d1

.C2F02	swap	d1
	tst	d1
	beq.b	.C2F10
	swap	d1
	lsr.l	#4,d0
	lsr.l	#4,d1
	bra.b	.C2F02

.C2F10	swap	d1
	addq.w	#1,d1

	IF	MC020
	moveq	#100,d2
	mulu.l	d2,d0		; 32 x 32 -> 32
	ELSE
	lsl.l	#2,d0
	move.l	d0,d2
	lsl.l	#3,d2
	add.l	d0,d2
	lsl.l	#4,d0
	add.l	d2,d0
	ENDIF

	tst	d1
	bne.b	C2F1E
	addq.w	#1,d1
C2F1E:
	divu	d1,d0
	moveq	#$7f,d2
	and.l	d2,d0
	cmp	(ProgressPerc-DT,a4),d0
	beq.b	C2F6E
	lea	(Complete.MSG,pc),a0
	move	d0,(ProgressPerc-DT,a4)
	moveq	#'0',d1
	moveq	#10,d2
	divu.w	d2,d0
	swap	d0
	add.b	d1,d0
	move.b	d0,-(a0)
	clr	d0
	swap	d0
	divu.w	d2,d0
	swap	d0
	add.b	d1,d0
	move.b	d0,-(a0)
	clr	d0
	swap	d0
	divu.w	d2,d0
	swap	d0
	add.b	d1,d0
	move.b	d0,-(a0)
	moveq	#0,d0
	lea	(ProgressPercentage.MSG,pc),a0
	jsr	(beeldtextaf).l
C2F6E:
	movem.l	(sp)+,d0/d1/d2/a0
	rts

FAST_TRANSLATE_LINE:
	bsr.w	ShowAsmProgress
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),(ResponsePtr-DT,a4)
	move	(CurrentSection-DT,a4),(ResponseType-DT,a4)
	moveq	#0,d0
	move.l	d0,(LAST_LABEL_ADDRESS-DT,a4)
	move.b	(a6)+,d0
	move	d0,d1
	add.b	d1,d1
	add	(.W02F98,pc,d1.w),d1
	jmp	(.W02F98,pc,d1.w)

.W02F98
	dr.w	asm_einderegel
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_WS		;9 TAB
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_WS		;32 SPACE
	dr.w	TR_EmptyChar	;!
	dr.w	TR_EmptyChar	;"
	dr.w	TR_EmptyChar	;#
	dr.w	TR_EmptyChar	;$
	dr.w	.TR_Global3	;%
	dr.w	TR_EmptyChar	;&
	dr.w	TR_EmptyChar	;'
	dr.w	TR_EmptyChar	;(
	dr.w	TR_EmptyChar	;)
	dr.w	TR_2EOL		;*
	dr.w	TR_EmptyChar	;+
	dr.w	TR_EmptyChar	;,
	dr.w	TR_EmptyChar	;-
	dr.w	.TR_Local3	;.
	dr.w	TR_EmptyChar	;/
	dr.w	TR_EmptyChar	;0
	dr.w	TR_EmptyChar	;1
	dr.w	TR_EmptyChar	;2
	dr.w	TR_EmptyChar	;3
	dr.w	TR_EmptyChar	;4
	dr.w	TR_EmptyChar	;5
	dr.w	TR_EmptyChar	;6
	dr.w	TR_EmptyChar	;7
	dr.w	TR_EmptyChar	;8
	dr.w	TR_EmptyChar	;9
	dr.w	TR_EmptyChar	;:
	dr.w	TR_2EOL		; ;
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_2EOL
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	.TR_Global3
	dr.w	TR_EmptyChar
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	.TR_Global3
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar

.TR_Local3:
	bset	#AF_LOCALFOUND,d7
	lea	(SourceCode-DT,a4),a1
	move.b	(a6)+,d0
	move.b	(Variable_base-DT,a4,d0.w),(a1)+
	bgt.b	C30B8
	bra.w	_ERROR_IllegalOperatorInBSS

.TR_Global3:
	and.w	#~((1<<AF_LOCALFOUND)|(1<<AF_GETLOCAL)),d7
	lea	(SourceCode-DT,a4),a1
	move.b	(Variable_base-DT,a4,d0.w),(a1)+
C30B8:
	move.b	(a6)+,d0
	move.b	(Variable_base-DT,a4,d0.w),(a1)+
	ble.b	C30D0
	move.b	(a6)+,d0
	move.b	(Variable_base-DT,a4,d0.w),(a1)+
	bgt.b	C30B8
	subq.w	#3,a1
	or.w	#$8000,(a1)
	bra.b	C30DA

C30D0:
	move	#$8000,d1
	add	-(a1),d1
	clr.b	d1
	move	d1,(a1)
C30DA:
	cmp.b	#":",d0
	beq.b	C311A
	cmp.b	#"$",d0
	bne.b	C30FE
	bset	#AF_LOCALFOUND,d7
	move.b	(a6)+,d0
	cmp.b	#":",d0
	beq.b	C311A
	tst.b	(Variable_base-DT,a4,d0.w)
	ble.b	C30FE
	bra.w	_ERROR_IllegalOperatorInBSS

C30FE:
	subq.l	#1,a6
	move.l	a6,a5
C3102:
	move.b	(a6)+,d0
	tst.b	(Variable_base-DT,a4,d0.w)
	bmi.b	C3102
	cmp.b	#"=",d0
	beq.b	C3138
	btst	#AF_LABELCOL,d7
	beq.b	C3122
	bra.w	C32A4

C311A:
	move.b	(a6)+,d0
	tst.b	(Variable_base-DT,a4,d0.w)
	bmi.b	C311A
C3122:
	subq.l	#1,a6
	bsr.w	MAKELABEL
	moveq	#0,d0
	move.b	(a6)+,d0
	move	d0,d1
	add.b	d1,d1
	add	(TransLableTab,pc,d1.w),d1
	jmp	(TransLableTab,pc,d1.w)

C3138:
	tst.l	d7		;AF_IF_FALSE
	bmi.w	TR_2EOL
C313E:
	move.b	(a6)+,d0
	tst.b	(Variable_base-DT,a4,d0.w)
	bmi.b	C313E
	subq.w	#1,a6
	bsr.w	MAKELABEL_NOTSET
	jsr	(Asm_EQU).l
	bra.w	FindEndOfLine

TransLableTab:
	dr.w	asm_einderegel		;0
	dr.w	TR_EmptyChar	;1
	dr.w	TR_EmptyChar	;2
	dr.w	TR_EmptyChar	;3
	dr.w	TR_EmptyChar	;4
	dr.w	TR_EmptyChar	;5
	dr.w	TR_EmptyChar	;6
	dr.w	TR_EmptyChar	;7
	dr.w	TR_EmptyChar	;8
	dr.w	TR_EmptyChar	;TAB
	dr.w	TR_EmptyChar	;LF
	dr.w	TR_EmptyChar	;11
	dr.w	TR_EmptyChar	;FF
	dr.w	TR_EmptyChar	;CR
	dr.w	TR_EmptyChar	;14
	dr.w	TR_EmptyChar	;15
	dr.w	TR_EmptyChar	;16
	dr.w	TR_EmptyChar	;17
	dr.w	TR_EmptyChar	;18
	dr.w	TR_EmptyChar	;19
	dr.w	TR_EmptyChar	;20
	dr.w	TR_EmptyChar	;21
	dr.w	TR_EmptyChar	;22
	dr.w	TR_EmptyChar	;23
	dr.w	TR_EmptyChar	;24
	dr.w	TR_EmptyChar	;25
	dr.w	TR_EmptyChar	;26
	dr.w	TR_EmptyChar	;27
	dr.w	TR_EmptyChar	;28
	dr.w	TR_EmptyChar	;29
	dr.w	TR_EmptyChar	;30
	dr.w	TR_EmptyChar	;31
	dr.w	TR_EmptyChar	;SPACE
	dr.w	TR_EmptyChar	;!
	dr.w	TR_EmptyChar	;"
	dr.w	TR_EmptyChar	;#
	dr.w	TR_EmptyChar	;$
	dr.w	.TR_Global2	;%
	dr.w	TR_EmptyChar	;&
	dr.w	TR_EmptyChar	;'
	dr.w	TR_EmptyChar	;(
	dr.w	TR_EmptyChar	;)
	dr.w	TR_2EOL		;*
	dr.w	TR_EmptyChar	;+
	dr.w	TR_EmptyChar	;,
	dr.w	TR_EmptyChar	;-
	dr.w	.TR_Local2	;.
	dr.w	TR_EmptyChar	;/
	dr.w	TR_EmptyChar	;0
	dr.w	TR_EmptyChar	;1
	dr.w	TR_EmptyChar	;2
	dr.w	TR_EmptyChar	;3
	dr.w	TR_EmptyChar	;4
	dr.w	TR_EmptyChar	;5
	dr.w	TR_EmptyChar	;6
	dr.w	TR_EmptyChar	;7
	dr.w	TR_EmptyChar	;8
	dr.w	TR_EmptyChar	;9
	dr.w	TR_EmptyChar	;:
	dr.w	TR_2EOL		; ;
	dr.w	TR_EmptyChar	;<
	dr.w	TR_EmptyChar	;=
	dr.w	TR_2EOL		;>
	dr.w	TR_EmptyChar	;?
	dr.w	TR_EmptyChar	;@
	dr.w	.TR_Global2	;A
	dr.w	.TR_Global2
	dr.w	.TR_Global2
	dr.w	.TR_Global2
	dr.w	.TR_Global2
	dr.w	.TR_Global2
	dr.w	.TR_Global2
	dr.w	.TR_Global2
	dr.w	.TR_Global2
	dr.w	.TR_Global2
	dr.w	.TR_Global2
	dr.w	.TR_Global2
	dr.w	.TR_Global2
	dr.w	.TR_Global2
	dr.w	.TR_Global2
	dr.w	.TR_Global2
	dr.w	.TR_Global2
	dr.w	.TR_Global2
	dr.w	.TR_Global2
	dr.w	.TR_Global2
	dr.w	.TR_Global2
	dr.w	.TR_Global2
	dr.w	.TR_Global2
	dr.w	.TR_Global2
	dr.w	.TR_Global2
	dr.w	.TR_Global2	;Z
	dr.w	TR_EmptyChar	;[
	dr.w	TR_EmptyChar	;\
	dr.w	TR_EmptyChar	;]
	dr.w	TR_EmptyChar	;^
	dr.w	.TR_Global2	;_
	dr.w	TR_EmptyChar	;`
	dr.w	.TR_Global2	;a
	dr.w	.TR_Global2
	dr.w	.TR_Global2
	dr.w	.TR_Global2
	dr.w	.TR_Global2
	dr.w	.TR_Global2
	dr.w	.TR_Global2
	dr.w	.TR_Global2
	dr.w	.TR_Global2
	dr.w	.TR_Global2
	dr.w	.TR_Global2
	dr.w	.TR_Global2
	dr.w	.TR_Global2
	dr.w	.TR_Global2
	dr.w	.TR_Global2
	dr.w	.TR_Global2
	dr.w	.TR_Global2
	dr.w	.TR_Global2
	dr.w	.TR_Global2
	dr.w	.TR_Global2
	dr.w	.TR_Global2
	dr.w	.TR_Global2
	dr.w	.TR_Global2
	dr.w	.TR_Global2
	dr.w	.TR_Global2
	dr.w	.TR_Global2	;z
	dr.w	TR_EmptyChar	;{
	dr.w	TR_EmptyChar	;|
	dr.w	TR_EmptyChar	;}
	dr.w	TR_EmptyChar	;~
	dr.w	TR_EmptyChar	;DEL


.TR_Local2:
	bset	#AF_LOCALFOUND,d7
	lea	(SourceCode-DT,a4),a1

	move.b	(a6)+,d0
	move.b	(Variable_base-DT,a4,d0.w),(a1)+
	bgt.b	.txtloop2
	bra.w	_ERROR_IllegalOperatorInBSS

.TR_Global2:
	and.w	#~((1<<AF_LOCALFOUND)|(1<<AF_GETLOCAL)),d7
	lea	(SourceCode-DT,a4),a1
	move.b	(Variable_base-DT,a4,d0.w),(a1)+
.txtloop2:
	move.b	(a6)+,d0
	move.b	(Variable_base-DT,a4,d0.w),(a1)+
	ble.b	.EndEven
	move.b	(a6)+,d0
	move.b	(Variable_base-DT,a4,d0.w),(a1)+
	bgt.b	.txtloop2

	subq.w	#3,a1
	or.w	#$8000,(a1)
	bra.b	FastACommand

.EndEven:
	move	#$8000,d1
	add	-(a1),d1
	clr.b	d1
	move	d1,(a1)

FastACommand:
	subq.l	#1,a6
	move.l	a6,a5
.RemoveWS:
	move.b	(a6)+,d0
	tst.b	(Variable_base-DT,a4,d0.w)
	bmi.b	.RemoveWS
C32A4:
	subq.l	#1,a6
	btst	#AF_LOCALFOUND,d7
	bne.w	HandleMacroos
	lea	(SourceCode-DT,a4),a3

	IF PPC

	btst	#MB1_PPC_ASM,(MyBits-DT,a4)
	beq.s	.asm68k

	bsr	PPC_Asmblr

	bra.b	.continue
.asm68k
	ENDIF

	move.l	(Asm_Table_Base-DT,a4),a0
	move	#$DFDF,d4
	moveq	#$1F,d1
	and.b	(a3),d1
	move	(a3)+,d0
	and	d4,d0
	add.b	d1,d1
	add	(a0,d1.w),a0
	jsr	(a0)

.continue:
FindEndOfLine:
	moveq	#0,d1
	move.b	(a6)+,d1
	beq.b	asm_einderegel
	cmp.b	#';',d1
	beq.b	TR_2EOL
	cmp.b	#'*',d1
	beq.b	TR_2EOL
	tst.b	(Variable_base-DT,a4,d1.w)
	bmi.b	C32E8

	bra	_ERROR_IllegalOperand

C32E8:
	btst	#AF_SEMICOMMENT,d7
	beq.b	TR_2EOL
C32EE:
	move.b	(a6)+,d1
	tst.b	(Variable_base-DT,a4,d1.w)
	bmi.b	C32EE
	tst.b	d1
	beq.b	asm_einderegel
	cmp.b	#';',d1
	beq.b	TR_2EOL
	cmp.b	#'*',d1
	beq.b	TR_2EOL
	bra.w	_ERROR_NOoperandspac

TR_2EOL:
	tst.b	(a6)+
	bne.b	TR_2EOL
asm_einderegel:
	tst	d7		;AF_PASSONE
	bmi.b	.pass1
	move.l	(LAST_LABEL_ADDRESS-DT,a4),d0
	beq.b	.pass1
	move.l	d0,a1
	move.l	(ResponsePtr-DT,a4),d0
	cmp.l	-(a1),d0
	bne.b	.moved
	move	-(a1),d0
	bclr	#LB_PASS2BIT,d0
	cmp	(ResponseType-DT,a4),d0
	bne.b	.moved
.pass1	rts

.moved	bra.w	_ERROR_Codemovedduring

;************** PPC TEST STUFF ***************

	IF PPC

PPC_CHANGECPU	= 0
PPC_D_A_SIMM	= 1
PPC_D_A_B	= 2


;ppc_code:
;	dc.l	'addi'
;	dc.w	'c.'+$8000
;	CNOP	0,4
;testppc:
;	lea	ppc_code,a3

PPC_Asmblr:
	lea	PPC_Asm_Table,a0
	move.l	#$DFDFDFDF,d4
	moveq	#$1F,d1
	and.b	(a3),d1
	add.b	d1,d1
	add	(a0,d1.w),a0

	move.l	(a3)+,d0	;eerste 4 letters ppc instructie
	and.l	d4,d0

	moveq	#0,d1
	tst.w	d0
	bmi.b	.maarvierchars	; bit 15 set?
	move.l	(a3)+,d1	;laatste 4 letters ppc instructie
	and.l	d4,d1
	bpl.b	.achtchars	; bit 31 set?
	clr.w	d1
	subq.l	#2,a3		;dus 2 bytes terug
.maarvierchars:
.achtchars:

.ppc_asm_lopje:
	cmp.l	(a0),d0
	beq.s	.ppc_check
	lea	16(a0),a0
	tst.b	(a0)
	bpl.s	.ppc_asm_lopje

;	jsr	test1
	bra.w	HandleMacroos	;syntax error

.ppc_check:
	tst.l	d1
	beq.s	.ppc_checknextpart

	cmp.l	4(a0),d1
	beq.s	.ppc_checknextpart
	lea	16(a0),a0
	bra.b	.ppc_asm_lopje

.ppc_checknextpart:
	move.l	8(a0),d6	;opcode
	move.l	12(a0),d5	;extra info

	lea	ppc_argdisolve(pc),a0
	moveq	#0,d0
	move.b	12(a0),d0

;	jsr	test_debug

	lsl.w	#2,d0
	jsr	(a0,d0.w)

;	bsr	PPC_d_a_simm

	or.l	d0,d6

	move.l	(INSTRUCTION_ORG_PTR-DT,a4),d0
	btst	#0,d0
	beq.s	.nooddadrs
	jmp	ERROR_WordatOddAddress
.nooddadrs:
	tst	d7		;AF_PASSONE
	bmi.b	.pass1
	move.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
	add.l	d0,a0
	move.l	d6,(a0)
.pass1:
	addq.l	#4,(INSTRUCTION_ORG_PTR-DT,a4)
	rts


ppc_argdisolve:
	dc.l	PPC_ChangeCpuType
	dc.l	PPC_d_a_simm
	dc.l	PPC_d_a_b

PPC_d_a_simm:

PPC_d_a_b:
	moveq	#0,d0
	bsr	PPC_resolveDReg
	bsr	PPC_resolveAReg
;	bsr	PPC_resolveBReg
	bsr	PPC_resolveSIMM
	rts

PPC_getregnr:
	moveq	#$5F,d1
	and.b	(a6)+,d1
	cmp.b	#'R',d1
	beq.s	.ok1
	jmp	ERROR_GeneralPurpose
.ok1:
	move.b	(a6)+,d1
	sub.b	#'0',d1
	bpl.s	.ok2
	jmp	ERROR_GeneralPurpose
.ok2:
	cmp.b	#9,d1
	bls.s	.ok3
	jmp	ERROR_GeneralPurpose
.ok3:
	cmp.b	#'0',(a6)
	blo.w	.ok6
	cmp.b	#'9',(a6)
	bhi.w	.ok6
	move.l	d2,-(sp)
	moveq	#0,d2
	move.b	(a6)+,d2
	sub.b	#'0',d2
	bpl.s	.ok4
	jmp	ERROR_GeneralPurpose
.ok4:
	cmp.b	#9,d2
	bls.s	.ok5
	jmp	ERROR_GeneralPurpose
.ok5:
	mulu.w	#10,d1
	add.b	d2,d1
	move.l	(sp)+,d2

	cmp.w	#32,d1
	blo.s	.noprobs
	jmp	ERROR_GeneralPurpose	;(R1..R31)
.noprobs:
.ok6:
	rts


PPC_CheckKomma:
	cmp.b	#',',(a6)+
	beq.s	.ok
	jmp	ERROR_Commaexpected
.ok:
	rts

PPC_resolveDReg:
	bsr	PPC_getregnr
	swap	d1
	lsl.l	#5,d1
	or.l	d1,d0	;first rD
	rts

PPC_resolveAReg:
	bsr.s	PPC_CheckKomma
	bsr	PPC_getregnr
	swap	d1
	or.l	d1,d0	;rA
	rts

PPC_resolveBReg:
	bsr.s	PPC_CheckKomma
	bsr	PPC_getregnr
	lsl.l	#8,d1
	lsl.l	#3,d1
	or.l	d1,d0	;rB
	rts

PPC_resolveSIMM:
	bsr.s	PPC_CheckKomma

	bsr	PPC_GetNumber
	cmp.l	#$ffff,d1
	bhi.w	_ERROR_out_of_range16bit
	swap	d0
	move.w	d1,d0
	rts

PPC_GetNumber:
	jsr	Parse_GetExprValueInD3Voor
	btst	#AF_UNDEFVALUE,d7
	bne.b	.eind
	tst	d2
	bne	_ERROR_RelativeModeEr
.eind:
	move.l	d3,d1
	rts

;************** PPC ASSEMBLER TABLE ************

PPC_Asm_Table:
	dc.w	HandleMacroos-PPC_Asm_Table	;@
	dc.w	PPC_AsmA-PPC_Asm_Table		;A
	dc.w	HandleMacroos-PPC_Asm_Table	;B
	dc.w	PPC_AsmC-PPC_Asm_Table		;C
	dc.w	HandleMacroos-PPC_Asm_Table	;D
	dc.w	HandleMacroos-PPC_Asm_Table	;E
	dc.w	HandleMacroos-PPC_Asm_Table	;F
	dc.w	HandleMacroos-PPC_Asm_Table	;G
	dc.w	HandleMacroos-PPC_Asm_Table	;H
	dc.w	HandleMacroos-PPC_Asm_Table	;I
	dc.w	HandleMacroos-PPC_Asm_Table	;J
	dc.w	HandleMacroos-PPC_Asm_Table	;K
	dc.w	HandleMacroos-PPC_Asm_Table	;L
	dc.w	HandleMacroos-PPC_Asm_Table	;M
	dc.w	HandleMacroos-PPC_Asm_Table	;N
	dc.w	HandleMacroos-PPC_Asm_Table	;O
	dc.w	HandleMacroos-PPC_Asm_Table	;P
	dc.w	HandleMacroos-PPC_Asm_Table	;Q
	dc.w	HandleMacroos-PPC_Asm_Table	;R
	dc.w	HandleMacroos-PPC_Asm_Table	;S
	dc.w	HandleMacroos-PPC_Asm_Table	;T
	dc.w	HandleMacroos-PPC_Asm_Table	;U
	dc.w	HandleMacroos-PPC_Asm_Table	;V
	dc.w	HandleMacroos-PPC_Asm_Table	;W
	dc.w	HandleMacroos-PPC_Asm_Table	;X
	dc.w	HandleMacroos-PPC_Asm_Table	;Y
	dc.w	HandleMacroos-PPC_Asm_Table	;Z
	dc.w	HandleMacroos-PPC_Asm_Table	;[



PPC_AsmA:
	dc.l	'ADDI'!$8000
	dc.l	0
	dc.l	14<<26
	dc.b	PPC_D_A_SIMM
	dc.b	0,0,0

	dc.l	'ADDI'
	dc.l	'C'<<24!$80000000
	dc.l	12<<26
	dc.b	PPC_D_A_SIMM
	dc.b	0,0,0

	dc.l	'ADDI'
	dc.l	'C@'<<16!$80000000
	dc.l	13<<26
	dc.b	PPC_D_A_SIMM
	dc.b	0,0,0

	dc.l	'ADDI'
	dc.l	'S'<<24!$80000000
	dc.l	15<<26
	dc.b	PPC_D_A_SIMM
	dc.b	0,0,0

	dc.l	'ANDI'
	dc.l	'@'<<24!$80000000
	dc.l	28<<26
	dc.b	PPC_D_A_SIMM
	dc.b	0,0,0

	dc.l	'ANDI'
	dc.l	'S@'<<16!$80000000
	dc.l	29<<26
	dc.b	PPC_D_A_SIMM
	dc.b	0,0,0

	dc.l	-1


PPC_AsmC:
	dc.l	'SETC'
	dc.l	'PU'<<16!$80000000
	dc.l	0
	dc.b	PPC_CHANGECPU
	dc.b	0,0,0
	dc.l	-1

	ENDIF	; PPC


m68_ChangeCpuType:
	IF	MC020
	move.l	(a6),d1
	addq.l	#3,a6
	ELSE
	move.b	(a6)+,d1
	lsl.w	#8,d1
	move.b	(a6)+,d1
	swap	d1
	move.b	(a6)+,d1
	lsl.w	#8,d1
	ENDIF
	and.l	#$dfdfdf00,d1

	IF	PPC
PPC_ChangeCpuType:
	clr.b	d1
	ENDC

	lea	.cpus(pc),a0

	move.l	d7,-(sp)
	moveq	#(.cpus_end-.cpus)/4-1,d7
.lopje:
	cmp.l	(a0)+,d1
	dbeq	d7,.lopje
	beq.b	.gevonden

	move.l	(sp)+,d7
	br	_ERROR_UnknowCPU

.gevonden:
;	jsr	test_debug

	IF	PPC
	subq.w	#3,d7
	blo.s	.ppc
	bclr	#MB1_PPC_ASM,(MyBits-DT,a4)
.ppc:
	ENDIF
	move.l	(sp)+,d7
	rts

.cpus:
	IF	PPC
	dc.l	('M68'&$dfdfdf)<<8
	ENDIF
	dc.l	('000'&$dfdfdf)<<8
	dc.l	('010'&$dfdfdf)<<8
	dc.l	('020'&$dfdfdf)<<8
	dc.l	('030'&$dfdfdf)<<8
	dc.l	('040'&$dfdfdf)<<8
	dc.l	('060'&$dfdfdf)<<8
	IF	PPC
	dc.l	('PPC'&$dfdfdf)<<8
	dc.l	('603'&$dfdfdf)<<8
	dc.l	('604'&$dfdfdf)<<8
	ENDIF
.cpus_end

;************** END PPC TEST STUFF ***********

HandleMacroos:
	IFNE	useplugins
	jmp	PlugIns
HandleMacroos2:
	ENDC

	addq.l	#4,sp
	btst	#AF_MACROS_OFF,d7
	bne.b	.Disabled
	tst.l	d7		;AF_IF_FALSE
	bmi.b	TR_2EOL
	bsr.w	Parse_FindMacroExtAndLabel
	beq.b	.Illegal
	tst	d2
	bmi.b	.Special
.Illegal
	btst	#AF_BSS_AREA,d7
	bne.w	_ERROR_IllegalOperator
.Disabled
	bra.w	_ERROR_IllegalOperatorInBSS
.Special
	swap	d2
	and.b	#$3f,d2
	bne.b	.Illegal	; LB_MACRO?
	bsr.w	ASSEM_MACROFOUND
	bra.w	TR_2EOL

TR_WS:
	move.b	(a6)+,d0
	move	d0,d1
	add.b	d1,d1
	add	(.W3376,pc,d1.w),d1
	jmp	(.W3376,pc,d1.w)

.W3376
	dr.w	asm_einderegel	;0
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_WS		;9 TAB
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_WS		;32 SPACE
	dr.w	TR_EmptyChar	;!
	dr.w	TR_EmptyChar	;"
	dr.w	TR_EmptyChar	;#
	dr.w	TR_EmptyChar	;$
	dr.w	.TR_Global	;%
	dr.w	TR_EmptyChar	;&
	dr.w	TR_EmptyChar	;'
	dr.w	TR_EmptyChar	;(
	dr.w	TR_EmptyChar	;)
	dr.w	TR_2EOL		;*
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	.TR_LocalLable
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_2EOL
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_2EOL
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	.TR_Global
	dr.w	TR_EmptyChar
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	.TR_Global
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar
	dr.w	TR_EmptyChar

.TR_LocalLable:
	bset	#AF_LOCALFOUND,d7
	lea	(SourceCode-DT,a4),a1
	move.b	(a6)+,d0
	move.b	(Variable_base-DT,a4,d0.w),(a1)+
	bgt.b	C3496
	bra.w	_ERROR_IllegalOperatorInBSS

.TR_Global:
	and.w	#~((1<<AF_LOCALFOUND)|(1<<AF_GETLOCAL)),d7
	lea	(SourceCode-DT,a4),a1
	move.b	(Variable_base-DT,a4,d0.w),(a1)+
C3496:
	move.b	(a6)+,d0
	move.b	(Variable_base-DT,a4,d0.w),(a1)+
	ble.b	C34AE
	move.b	(a6)+,d0
	move.b	(Variable_base-DT,a4,d0.w),(a1)+
	bgt.b	C3496
	subq.w	#3,a1
	or.w	#$8000,(a1)
	bra.b	C34B8

C34AE:
	move	#$8000,d1
	add	-(a1),d1
	clr.b	d1
	move	d1,(a1)
C34B8:
	cmp.b	#":",d0
	beq.w	C311A
	cmp.b	#"=",d0
	bne.w	FastACommand
	bra.w	C3138

TR_EmptyChar:
	bra.w	_ERROR_IllegalOperatorInBSS

ASSEM_GET_MACRO_STATEMENTS:
	move.l	(CURRENT_MACRO_ARG_PTR-DT,a4),a0
	move.l	a0,a2
	lea	(FilterTable,pc),a1
	moveq	#19,d1			; max_macro_args
	moveq	#0,d0
.NEXT_ARG
	subq.w	#1,d1
	bmi.b	.NO_ARG2
.RM_SPACES
	move.b	(a6)+,d0
	tst.b	(Variable_base-DT,a4,d0.w)
	bmi.b	.RM_SPACES
	move.b	(a1,d0.w),(a0)+		;---  First char  ---
	bne.b	.LOOP
	cmp.b	#",",d0
	beq.b	.NEXT_ARG
	tst.b	d0
	beq.b	.NO_ARG
	cmp.b	#"'",d0
	beq.b	.TEXT
	cmp.b	#'"',d0
	beq.b	.TEXT
	cmp.b	#"`",d0
	beq.b	.TEXT
	bra.b	.NO_ARG
.LOOP
	move.b	(a6)+,d0		;--- Not a special char ---
	move.b	(a1,d0.w),(a0)+
	bne.b	.LOOP
	cmp.b	#",",d0
	beq.b	.NEXT_ARG
	tst.b	d0
	beq.b	.ARG_END
	cmp.b	#"'",d0
	beq.b	.TEXT
	cmp.b	#'"',d0
	beq.b	.TEXT
	cmp.b	#"`",d0
	bne.b	.ARG_END

.TEXT	move.b	d0,d2			;---  Get text  ---
	subq.w	#1,a0
.TEXT_LOOP
	move.b	d0,(a0)+
	move.b	(a6)+,d0
	beq.w	_ERROR_MissingQuote
	cmp.b	d0,d2
	bne.b	.TEXT_LOOP
	move.b	d2,(a0)+
	bra.b	.LOOP
.NO_ARG
	subq.w	#1,a0			;---  Zero all arguments  ---
.NO_ARG2
	addq.w	#1,d1
.ARG_END
	moveq	#19,d0			; max_macro_args
	sub.w	d1,d0
	move.w	d0,(NARG_VALUE-DT,a4)
	bra.b	.REM_BEGIN
.REM_LOOP
	clr.b	(a0)+
.REM_BEGIN
	dbf	d1,.REM_LOOP

	subq.w	#1,a6
.LOOP_END
	tst.b	(a6)+
	bne.b	.LOOP_END
	subq.w	#1,a6
	move.l	a0,(CURRENT_MACRO_ARG_PTR-DT,a4)
	rts

FilterTable:	; CONVERT_ARRAY
	DCB.B	32,0
	DC.B	0,$21,0,$23,$24,$25,$26,0		; space " ' is 0
	DC.B	$28,$29,$2A,$2B,0,$2D,$2E,$2F		; , = 0
	DC.B	$30,$31,$32,$33,$34,$35,$36,$37
	DC.B	$38,$39,$3A,0,$3C,$3D,$3E,$3F		; ; is 0
	DC.B	$40,$41,$42,$43,$44,$45,$46,$47
	DC.B	$48,$49,$4A,$4B,$4C,$4D,$4E,$4F
	DC.B	$50,$51,$52,$53,$54,$55,$56,$57
	DC.B	$58,$59,$5A,$5B,$5C,$5D,$5E,$5F
	DC.B	0,$61,$62,$63,$64,$65,$66,$67		; ` is 0
	DC.B	$68,$69,$6A,$6B,$6C,$6D,$6E,$6F
	DC.B	$70,$71,$72,$73,$74,$75,$76,$77
	DC.B	$78,$79,$7A,$7B,$7C,$7D,$7E,$7F
	DC.B	$80,$81,$82,$83,$84,$85,$86,$87
	DC.B	$88,$89,$8A,$8B,$8C,$8D,$8E,$8F
	DC.B	$90,$91,$92,$93,$94,$95,$96,$97
	DC.B	$98,$99,$9A,$9B,$9C,$9D,$9E,$9F
	DC.B	$A0,$A1,$A2,$A3,$A4,$A5,$A6,$A7
	DC.B	$A8,$A9,$AA,$AB,$AC,$AD,$AE,$AF
	DC.B	$B0,$B1,$B2,$B3,$B4,$B5,$B6,$B7
	DC.B	$B8,$B9,$BA,$BB,$BC,$BD,$BE,$BF
	DC.B	$C0,$C1,$C2,$C3,$C4,$C5,$C6,$C7
	DC.B	$C8,$C9,$CA,$CB,$CC,$CD,$CE,$CF
	DC.B	$D0,$D1,$D2,$D3,$D4,$D5,$D6,$D7
	DC.B	$D8,$D9,$DA,$DB,$DC,$DD,$DE,$DF
	DC.B	$E0,$E1,$E2,$E3,$E4,$E5,$E6,$E7
	DC.B	$E8,$E9,$EA,$EB,$EC,$ED,$EE,$EF
	DC.B	$F0,$F1,$F2,$F3,$F4,$F5,$F6,$F7
	DC.B	$F8,$F9,$FA,$FB,$FC,$FD,$FE,$FF

ASSEM_CONVERTONEMACROLINE:
	lea	(MACRO_LINEBUFFER-DT,a4),a3
	move.l	a3,a6
	moveq	#'\',d1
.EmptyLine
	move.b	(a5)+,d0
	beq.b	.EmptyLine
	cmp.b	#';',d0
	beq.b	.Comment
	cmp.b	#'*',d0
	beq.b	.Comment
	cmp.b	#SRCMARK_END,d0
	beq.w	_ERROR_UnexpectedEOF
	cmp.b	d1,d0
	beq.b	.HaveParam
.CopyChar
	move.b	d0,(a3)+
.Loop
	move.b	(a5)+,d0
	beq.b	.EndOfLine
	cmp.b	d1,d0
	bne.b	.CopyChar
.HaveParam
	moveq	#0,d0
	move.b	(a5)+,d0
	cmp.b	#"0",d0
	beq.b	.MacroSize
	cmp.b	#"@",d0
	beq.b	.RandomNum
	cmp.b	#".",d0
	beq.b	.EscDot
	cmp.b	d1,d0		; '\\'
	beq.b	.CopyChar
	cmp.b	#'<',d0
	beq.w	Asm_MacroParamSymbol

	sub.b	#"1",d0
	cmp.b	#9,d0
	bhs.w	_ERROR_IllegalOperand
	tst.b	d0
	bne.b	.SingleDigitArg
	move.b	(a5),d3
	sub.b	#"0",d3
	cmp.b	#9,d3
	bhi.b	.SingleDigitArg
	moveq	#10-1,d0	; arg 10-19 (mapped to 9-18)
	add.b	d3,d0
	addq.w	#1,a5
.SingleDigitArg
	move.l	a2,a0
	subq.b	#1,d0
	bmi.b	.CopyArgValue
.SeekArgValue
	tst.b	(a0)+
	bne.b	.SeekArgValue
	dbra	d0,.SeekArgValue
.CopyArgValue
	move.b	(a0)+,(a3)+
	bne.b	.CopyArgValue
	subq.w	#1,a3
	bra.b	.Loop

.Comment
	move.b	(a5)+,d0
	bne.b	.Comment
.EndOfLine
	move.b	d0,(a3)+
	rts

.EscDot
	move.b	d1,(a3)+
	move.b	#".",(a3)+
	bra.b	.Loop

.MacroSize
	move.b	(Asm_MacroSize-DT,a4),d0
	bpl.b	.MacroSizeUsed
	clr.b	-(a3)
	bra.b	.Loop
.MacroSizeUsed
	move.b	(.Extensions,pc,d0.w),(a3)+
	bra.w	.Loop

.Extensions
	dc.b	"SBWLDXP",0

.RandomNum
	bset	#31,d5
	move.b	#'_',(a3)+		; _DCBA (reverse order, low first)
	move.l	d5,d0
	lea	(HexToAscii,pc),a0
	moveq	#15,d2
	and.b	d0,d2
	move.b	(a0,d2.w),(a3)+
	lsr.w	#4,d0
	moveq	#15,d2
	and.b	d0,d2
	move.b	(a0,d2.w),(a3)+
	lsr.w	#4,d0
	moveq	#15,d2
	and.b	d0,d2
	move.b	(a0,d2.w),(a3)+
	lsr.w	#4,d0
	move.b	(a0,d0.w),(a3)+

	swap	d0		; append inc_idx (variable length)
	bclr	#15,d0
.IncIdx
	moveq	#15,d2
	and.b	d0,d2
	move.b	(a0,d2.w),(a3)+
	lsr.w	#4,d0
	bne.b	.IncIdx
	bra.w	.Loop

Asm_MacroParamSymbol:
	lea	(MACRO_LINEBUFFER_SYM-DT,a4),a0
	cmp.b	#'$',(a5)
	beq.b	.Hex

.Dec	bsr.b	.GetParamSymbolValue
	lea	(TABEL_HEXTODEC),a0
	moveq	#0,d4		; leading char
.DecLoop
	moveq	#0,d2		; digit
	move.l	(a0)+,d0
	beq.b	.Done
	cmp.l	d0,d3
	blo.b	.DigitDone
	moveq	#'0',d4
.Digit	sub.l	d0,d3
	addq.b	#1,d2
	cmp.l	d0,d3
	bhs.b	.Digit
.DigitDone
	tst.b	d4
	beq.b	.NoLead
	add.b	d4,d2
	move.b	d2,(a3)+
.NoLead	tst.l	d3
	bne.b	.DecLoop
.Done	add.b	#'0',d3
	move.b	d3,(a3)+
	bra.w	ASSEM_CONVERTONEMACROLINE\.Loop

.Hex	addq.l	#1,a5
	bsr.b	.GetParamSymbolValue
	lea	(HexToAscii,pc),a0
	moveq	#8-1,d0
.HexLoop
	rol.l	#4,d3
	moveq	#$f,d2
	and.b	d3,d2
	move.b	(a0,d2.w),(a3)+
	dbf	d0,.HexLoop
	bra.w	ASSEM_CONVERTONEMACROLINE\.Loop

.CopyParamSymbol
	move.b	d0,(a0)+
.GetParamSymbolValue
	move.b	(a5)+,d0
	beq.w	_ERROR_IllegalOperand
	cmp.b	#'>',d0
	bne.b	.CopyParamSymbol
	clr.b	(a0)

	movem.l	d1/d5/a2-a6,-(sp)
	lea	(MACRO_LINEBUFFER_SYM-DT,a4),a6
	bsr.w	NEXTSYMBOL		; in = a6, out = SourceCode
	cmp.b	#NS_ALABEL,d1
	bne.w	_ERROR_IllegalOperand
	bclr	#AF_UNDEFVALUE,d7
	jsr	(Parse_FirstALabel)	; in = SourceCode, out = d2/d3
	btst	#AF_UNDEFVALUE,d7
	bne.w	_ERROR_UndefSymbol
	tst.w	d2
	bne.w	_ERROR_RelativeModeEr
	movem.l	(sp)+,d1/d5/a2-a6
	rts

HexToAscii:
	dc.b	'0123456789ABCDEF'

PARSE_GET_LABEL:
	jsr	(Parse_GetExprValueInD3Voor)
	btst	#AF_UNDEFVALUE,d7
	bne.b	.C3798
	cmp	(CurrentSection-DT,a4),d2
	beq.b	.C3792
	tst	d2
	bmi.b	.C3798
	bra.w	_ERROR_RelativeModeEr
.C3792	moveq	#0,d2
	sub.l	(Binary_Offset-DT,a4),d3
.C3798	rts

PARSE_GET_LABEL_32BIT:
	jsr	(Parse_GetExprValueInD3Voor)
	btst	#AF_UNDEFVALUE,d7
	bne.b	C380E
	moveq	#0,d2
	sub.l	(Binary_Offset-DT,a4),d3
	bra.w	Store_DataLongReloc

PARSE_GET_LABEL_16BIT:
	jsr	(Parse_GetExprValueInD3Voor)
	btst	#AF_UNDEFVALUE,d7
	bne.b	C380E
	cmp	(CurrentSection-DT,a4),d2
	beq.b	C3808
	tst	d2
	bmi.b	C380E
	bra.w	_ERROR_RelativeModeEr
C3808:
	moveq	#0,d2
	sub.l	(Binary_Offset-DT,a4),d3
C380E:
	bra.w	C755A

PARSE_GET_LABEL_8BIT:
	jsr	(Parse_GetExprValueInD3Voor).l
	btst	#AF_UNDEFVALUE,d7
	bne.b	.C3850
	cmp	(CurrentSection-DT,a4),d2
	beq.b	.C382E
	tst	d2
	bmi.b	.C3852
	bra.w	_ERROR_RelativeModeEr

.C382E
	moveq	#0,d2
	sub.l	(Binary_Offset-DT,a4),d3
	beq.b	.C3852	; 0 requires 16-bit bra
	move.b	d3,d0
	IF	MC020
	extb.l	d0
	ELSE
	ext.w	d0
	ext.l	d0
	ENDIF
	cmp.l	d0,d3
	bne.b	.C3852
	or.b	d3,d6
.C3850	rts

.C3852	jmp	(FORCE_BRAW).l

Parse_GetDefinedValue:
	jsr	(Parse_GetExprValueInD3Voor).l
	btst	#AF_UNDEFVALUE,d7
	bne.w	_ERROR_UndefSymbol
	tst	d2
	bne.w	_ERROR_RelativeModeEr
	sf	(Asm_OffsetCheck-DT,a4)
	rts

Parse_ImmediateValue:
	cmp.b	#'#',(a6)+
	bne.w	_ERROR_Immediateoper
	jsr	Parse_GetExprValueInD3Voor
	btst	#AF_UNDEFVALUE,d7
	bne.b	.eind
	tst	d2
	bne.w	_ERROR_RelativeModeEr
.eind	rts

Parse_GetEASpecial:
	bsr.w	NEXTSYMBOL
	cmp.b	#'#',d1
	bne.w	Get_OtherEA
	jsr	Parse_GetExprValueInD3Voor
	move	#M_Imm,d5
	btst	#AF_UNDEFVALUE,d7
	bne.b	.eind
	tst	d2
	bne.w	_ERROR_RelativeModeEr
	subq.l	#1,d3
	move.l	d3,d1
	moveq	#7,d0
	and.l	d0,d1
	cmp.l	d1,d3
	bne.w	_ERROR_out_of_range3bit
	addq.w	#1,d1
	and	d0,d1
	rts
.eind	moveq	#0,d1
	rts

C391C:
S_Value:
	jsr	(PARSE_START_VALUE_IN_D3)
Parse_ItsAValue:
	move.b	(a6)+,d0
	cmp.b	#'(',d0
	beq.w	C39AA
	cmp.b	#'.',d0
	beq.w	Parse_SizeDetected
	subq.w	#1,a6
	bra.w	C398E

PARSE_GET_EA_MOVEM_NOSIZE:
	bsr.w	NEXTSYMBOL
	cmp.b	#'#',d1
	beq.w	_ERROR_InvalidAddrMode
	cmp.b	#'(',d1
	beq.w	Parse_HaakjeOpenVoor
	cmp.b	#'-',d1
	beq.b	Parse_MinVoor
	cmp.b	#NS_ALABEL,d1
	bne.b	C391C
	bsr.w	Parse_CheckIfReservedWord
	bne.b	PARSE_MOVEM_REGISTERS
	jsr	(PARSE_START_LABEL_VALUE_IN_D3_MOVEM)
	bra.b	Parse_ItsAValue

PARSE_MOVEM_REGISTERS:
	moveq	#0,d2			; rev_mask.w, mask.w
.LoopSingle
	moveq	#'-',d3
.Loop
	move.b	(a6)+,d0
	cmp.b	d3,d0
	beq.b	.AddRange
	bset	d1,d2			; update mask
	not.w	d1
	bset	d1,d2			; update rev_mask
	cmp.b	#"/",d0
	bne.b	.Finish
.AddSingle
	bsr.w	AddrOrDataReg
	bra.b	.LoopSingle
.AddRange
	move.w	d1,d3
	bsr.w	AddrOrDataReg
	cmp.w	d1,d3
	bls.b	.RangeLoop
	exg	d1,d3
.RangeLoop
	bset	d3,d2			; update mask
	not.w	d3
	bset	d3,d2			; update rev_mask
	not.w	d3
	addq.w	#1,d3
	cmp	d1,d3
	blo.b	.RangeLoop
	st	d3			; in case next char is TAB (=9) and reg is a1 (8+1=9)
	bra.b	.Loop			; add last reg and loop
.Finish
	subq.w	#1,a6
	move.l	d2,d1
	move	#M_Movem,d5
	rts

Parse_MinVoor:
	cmp.b	#'(',(a6)+
	beq.w	C3A98
	subq.w	#2,a6
	jsr	(Parse_GetExprValueInD3Voor).l
	bra.w	Parse_ItsAValue

Parse_SizeDetected:
	moveq	#~32,d0
	and.b	(a6)+,d0
	cmp.b	#'W',d0
	beq.b	C399C
	cmp.b	#'L',d0
	bne.w	_ERROR_IllegalAddres
C398E:
	moveq	#$0039,d1
	move	#M_AbsL,d5
	bra.w	Store_DataLongReloc

C399C:
	moveq	#$0038,d1
	moveq	#M_AbsW,d5
	bra.w	Store_DataWordUnsigned

C39AA:
	sf	(S_MemIndActEnc-DT,a4)
	bsr.w	Parse_GetDofAReg
	beq.w	_ERROR_InvalidAddrMode
	bmi.b	C3A3A
	cmp	#$003A,d1
	bne.b	.C39C8
	subq.l	#2,d3
	bra.b	.C39D0
.C39C8	btst	#3,d1
	bne.w	_ERROR_AddressRegExp
.C39D0:	btst	#AF_OFFSET_A4,d7
	beq.b	.NO_SPECIAL_A4
	btst	d1,(BASEREG_BYTE-DT,a4)
	beq.b	.NO_SPECIAL_A4
	tst.w	d7		; pass1?
	bpl.b	.OK_PASS2
	moveq	#0,d3
	bra.b	.END_PASS1
.OK_PASS2
	move	d1,d0		; d0 = 6*d1
	add	d0,d0
	add	d1,d0
	add	d0,d0
	lea	(BASEREG_BASE-DT,a4),a0
	add	d0,a0
	tst	d2
	bpl.b	.NO_XREF
	addq.w	#2,a0
	moveq	#0,d3
	sub.l	(a0)+,d3
	bra.b	.XREF
.NO_XREF
	cmp	(a0)+,d2
	bne.w	_ERROR_RelativeModeEr
	sub.l	(a0)+,d3
.END_PASS1
	moveq	#0,d2
.XREF
.NO_SPECIAL_A4
	clr.w	(Parse_AdrValueSize-DT,a4)
	clr.l	(Parse_AdrValue-DT,a4)
	move.b	(a6)+,d0
	cmp.b	#')',d0
	beq.b	C3A2E
	cmp.b	#',',d0
	beq.w	C3DC8
	bra.w	_ERROR_RightParentesExpected

C3A2E:
	or.w	#$0028,d1
	moveq	#M_AxDisp,d5
	bra.w	C755A

C3A3A:
	btst	#AF_UNDEFVALUE,d7
	bne.b	C3A5C
	cmp	(CurrentSection-DT,a4),d2
	beq.b	C3A56
	tst	d2
	bmi.b	C3A5C
	tst.b	(S_MemIndActEnc-DT,a4)
	bne.w	_ERROR_RelativeModeEr
	subq.l	#2,d3
	bra.b	C3A5C

C3A56:
	sub.l	(Binary_Offset-DT,a4),d3
	moveq	#0,d2
C3A5C:
	move.b	(a6)+,d0
	cmp.b	#')',d0
	beq.b	C3A6E
	cmp.b	#',',d0
	bne.w	_ERROR_RightParentesExpected
	bra.b	C3A7C

C3A6E:
	moveq	#$003A,d1
	move	#M_PcDisp,d5
	bra.w	C755A

C3A7C:
	clr.w	(Parse_AdrValueSize-DT,a4)
	clr.l	(Parse_AdrValue-DT,a4)
	moveq	#$003B,d1
	move	#M_PcIdx,d5
	bra.w	C3DE0

C3A98:
	bsr.w	Parse_GetDofAReg
	beq.b	C3AAE
	cmp.b	#')',(a6)+
	bne.w	_ERROR_RightParentesExpected
	or.w	#$0020,d1
	moveq	#M_AxDec,d5
	rts

C3AAE:
	cmp.b	#')',(a6)+
	bne.w	_ERROR_RightParentesExpected
	pea	(Parse_ItsAValue,pc)
	pea	(Parse_GetAnyMathOpp).l
	jmp	(C10D1A).l

C3AC6:
	cmp.b	#'.',(a6)
	beq.b	C3AE4
	cmp.b	#',',(a6)
	beq.b	C3AEE
	cmp.b	#')',(a6)+
	bne.w	_ERROR_RightParentesExpected
	pea	(Parse_ItsAValue,pc)
	jmp	(Parse_GetAnyMathOpp).l

C3AE4:
	move.l	d1,-(sp)
	bsr.w	Parse_GetTheSize
	move.l	(sp)+,d1
	bra.b	C3AC6

C3AEE:
	sf	(S_MemIndActEnc-DT,a4)
	addq.w	#1,a6
	bra.w	C39AA

Asm_ImmediateOpp:
	move.b	(OpperantSize-DT,a4),d0
	cmp.b	#$44,d0
	beq.b	.size_BWL
	cmp.b	#$10,d0		; signed cmp, includes $80 (fp .L) as negative
	ble.b	.size_BWL
	cmp.w	#$f000,d6	; top 4 bits = $f?
	bhs.b	.fp
	cmp.b	#$70,d0
	blt.b	.size_BWL
.fp	movem.l	d0-d7/a0-a6,-(sp)
	jsr	Parse_GetExprValueInD3Voor	;Check for constants.
	btst	#AF_UNDEFVALUE,d7
	bne.b	.parse
	cmp.b	#'.',(a6)
	beq.b	.parse
	tst	(FPU_Type-DT,a4)
	beq.b	.NoFpu
	fmove.l	d3,fp0
	lea	(15*4,sp),sp
	bra.b	.label

.NoFpu	bra.w	_ERROR_FPUneededforopp

.parse	movem.l	(sp)+,d0-d7/a0-a6
	jsr	Asm_ImmediateOppFloat
.label
	move	#M_Imm,d5
	moveq	#$003C,d1
	moveq	#7,d0
	and.b	(OpperantSize-DT,a4),d0
	subq.b	#1,d0
	beq.w	Asm_FloatsizeS
	subq.b	#1,d0
	beq.w	Asm_FloatsizeX
	subq.b	#1,d0
	beq.w	Asm_FloatsizeP
	bra.w	Asm_FloatsizeD

;#xxxxx

.size_BWL:
	jsr	Parse_GetExprValueInD3Voor
	move	#M_Imm,d5
	moveq	#$003C,d1
	tst.b	(OpperantSize-DT,a4)
	bmi.w	Store_DataLongReloc
	bne.w	Store_DataWordUnsigned
	bra.w	Store_Data2BytesUnsigned

; (ax)Asm_FloatsizeX:
; (ax)+
; (ax,rx[.w|.l])
; (sp)			; is (a7)

Parse_HaakjeVoor:
	moveq	#PB_020,d0
	jsr	Processor_warning

	bclr	#3,d1
	move.b	(a6)+,d0
	cmp.b	#')',d0
	beq.w	C3C96
	lsl.w	#4,d1
	move	d1,d3
	subq.w	#1,a6
	bsr.w	Parse_GetTheSize
	lsr.w	#2,d1
	lsl.w	#3,d1
	or.w	d1,d3
	move	d3,d1

	move.b	(a6)+,d0
	cmp.b	#')',d0
	beq.w	C3C70
	cmp.b	#'*',d0
	beq.w	Parse_Indexing020

	tst	(Parse_AdrValueSize-DT,a4)
	beq.b	C3BC2
	cmp.b	#']',d0
	bne.w	_ERROR_MissingBracket
C3BA8:
	moveq	#~3,d0
	and.w	(Parse_AdrValueSize-DT,a4),d0
	lsl.b	#2,d0
	move	#$00A1,d1
	or.b	d0,d1
	move	d3,-(sp)
	move.l	(Parse_AdrValue-DT,a4),d3

	tst.b	d0
	beq.b	C3BF0
	bra.b	C3C0C

C3BC2:
	cmp.b	#',',d0
	bne.w	_ERROR_RightParentesExpected
	move	d1,-(sp)
	jsr	(Parse_GetExprValueInD3Voor).l
	tst.l	d3
	beq	_ERROR_IllegalOperand
	bsr	Parse_GetTheSize

	cmp	#4,d1
	beq.b	C3C08
	swap	d3
	tst	d3
	bne	_ERROR_out_of_range16bit
	swap	d3
	move	#$00A0,d1
C3BF0:
	tst	d7	;passone
	bmi.b	.C3C00
	move.l	(Binary_Offset-DT,a4),a0
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
	move	d3,(2,a0)
.C3C00	move	#2,(Parse_AdrValueSize-DT,a4)
	bra.b	C3C22

C3C08:
	move	#$00B0,d1
C3C0C:
	tst	d7		;passone
	bmi.b	C3C1C
	move.l	(Binary_Offset-DT,a4),a0
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
	move.l	d3,(2,a0)
C3C1C:
	move	#4,(Parse_AdrValueSize-DT,a4)
C3C22:
	move	(sp)+,d3
	move.b	(a6)+,d0
	cmp.b	#')',d0
	bne	_ERROR_RightParentesExpected
	tst	d7	;passone
	bmi.b	C3C5C
	or.b	#1,d3
	lsl.w	#8,d3
	or.w	d1,d3
	move.l	(Binary_Offset-DT,a4),a0
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
	move	d3,(a0)
	addq.l	#2,(Binary_Offset-DT,a4)
	moveq	#0,d0
	move	(Parse_AdrValueSize-DT,a4),d0
	add.l	d0,(Binary_Offset-DT,a4)
	moveq	#$30,d1
	moveq	#M_AxIdx,d5
	rts

C3C5C:
	addq.l	#2,(Binary_Offset-DT,a4)
	moveq	#0,d0
	move	(Parse_AdrValueSize-DT,a4),d0
	add.l	d0,(Binary_Offset-DT,a4)
	rts

C3C70:
	tst	(Parse_AdrValueSize-DT,a4)
	bne	_ERROR_MissingBracket
	tst	d7	;passone
	bmi.b	C3C5C
	or.b	#1,d1
	move.l	(Binary_Offset-DT,a4),a0
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
	move.b	d1,(a0)
	move.b	#$90,(1,a0)
	moveq	#$30,d1
	moveq	#M_AxIdx,d5
	bra.b	C3C5C

C3C96:
	tst	(Parse_AdrValueSize-DT,a4)
	bne	_ERROR_MissingBracket
	tst	d7	;passone
	bmi.b	C3CB4
	move.b	d1,d0
	ror.w	#4,d1
	or.w	#$0190,d1
	move.l	(Binary_Offset-DT,a4),a0
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
	move	d1,(a0)
C3CB4:
	addq.l	#2,(Binary_Offset-DT,a4)
	moveq	#$30,d1
	moveq	#M_AxInd,d5
	rts

Parse_Indexing020:
	movem.l	d0/d3,-(sp)
	moveq	#PB_020,d0
	jsr	(Processor_warning).l
.lopje:
	move.b	(a6)+,d0
	cmp.b	#'$',d0
	beq.b	.lopje
	cmp.b	#'@',d0
	beq.b	.lopje
	moveq	#3,d3
	cmp.b	#'8',d0
	beq.b	.IndexOK
	subq.w	#1,d3
	cmp.b	#'4',d0
	beq.b	.IndexOK
	subq.w	#1,d3
	cmp.b	#'2',d0
	beq.b	.IndexOK
	subq.w	#1,d3
	cmp.b	#'1',d0
	bne	_ERROR_Illegalscales

.IndexOK:
	lsl.w	#1,d3
	or.b	d3,d1
	movem.l	(sp)+,d0/d3
	move.b	(a6)+,d0
	tst	(Parse_AdrValueSize-DT,a4)
	bne.b	Parse_CheckCloseHaakje
	cmp.b	#')',d0
	beq	C3C70
	br	C3BC2

Parse_CheckCloseHaakje:
	cmp.b	#']',d0
	bne	_ERROR_MissingBracket
	move	d1,d3
	br	C3BA8

;; new syntax

SB_INDIRECT	=	0
SB_AREGFIRST	=	1
;SB_BRCLOSED	=	2
;SB_NOIREG	=	3

Parse_HaakjeOpenVoor:
	clr.w	(Parse_CPUType-DT,a4)
	clr.w	(huidigesectie-DT,a4)
	clr.b	(NewSyntaxbits-DT,a4)
	clr.w	(Parse_AdrValueSize-DT,a4)
	clr.l	(Parse_AdrValue-DT,a4)
	clr.l	(Parse_NewAdrvalue-DT,a4)
	st	(S_MemIndActEnc-DT,a4)
	cmp.b	#'[',(a6)
	bne.b	Parse_OldSyntax

	bset	#SB_INDIRECT,(NewSyntaxbits-DT,a4)

	addq.w	#1,a6
	moveq	#PB_020,d0
	jsr	Processor_warning
	bsr	Parse_GetDofAReg	;was wat anders
;	beq	C3AC6
;	bmi.w	_ERROR_RelativeModeEr
	beq.s	.noReg
;	btst	#3,d1
;	bne	_ERROR_AddressRegExp

	bset	#SB_AREGFIRST,(NewSyntaxbits-DT,a4)
	moveq	#0,d3

	move.w	d2,(huidigesectie-DT,a4)
	clr.l	(Parse_AdrValue-DT,a4)
	clr.w	(Parse_AdrValueSize-DT,a4)
	st	(S_MemIndActEnc-DT,a4)	;indirect pre/post-indexed

	bra.b	Parse_OldSyntax\.noOffset

.noReg:
	st	(S_MemIndActEnc-DT,a4)	;indirect pre/post-indexed
	move.l	d3,(Parse_AdrValue-DT,a4)

	bsr	Parse_GetTheSize
	move	d1,(Parse_AdrValueSize-DT,a4)

	move.w	d2,(huidigesectie-DT,a4)

	tst.w	d7
	bmi.b	.pass1

	TST.W	D2
	BEQ.S	.END
	LEA	(SECTION_ABS_LOCATION-DT,A4),A0
	ADD.W	D2,D2
	ADD.W	D2,D2
	beq.b	.pass1
	add.l	(A0,D2.W),D3
.END:
	move.l	d3,(Parse_NewAdrvalue-DT,a4)
.pass1:
	moveq	#0,d3
	moveq	#0,d1

	cmp.b	#']',(a6)		; ([xxx]
	bne.b	.verder

;	jsr	test_debug
;	clr.w	(Parse_AdrValueSize-DT,a4)

	move	#$00f0,d3		;wierd stuff!!
	bra.b	noDxDirect

.verder:
	cmp.b	#',',(a6)+	;([xxx, or ([xxx],
	bne	_ERROR_Commaexpected

Parse_OldSyntax:
	moveq	#0,d3
	bsr	Parse_GetDofAReg
	beq	C3AC6
	bmi.w	_ERROR_RelativeModeEr

.noOffset:				;([xxx,a0 or ([a0

	cmp.b	#$3a,d1			;pc relative?
	beq.b	noDxDirect

	move.l	(Parse_NewAdrvalue-DT,a4),(Parse_AdrValue-DT,a4)

	btst	#3,d1
	bne	Parse_HaakjeVoor	;([xxx,dx of ([dx

noDxDirect:

	move.b	(a6)+,d0
	cmp.b	#']',d0		;([xxx] , ([xxx,a0] ,([xxx,pc] or ([a0]
	bne.b	.not020

	cmp.b	#$3a,d1		;PC relative?
	bne.s	.verder
	tst.w	d7
	bmi.s	.passone
	move.w	(huidigesectie-DT,a4),d2
	cmp.w	(CurrentSection-DT,a4),d2
	bne.w	_ERROR_RelativeModeEr
.passone
	bra.b	.nochange

.verder:
	tst	d2
	beq.b	.nochange
	move.l	(Parse_NewAdrvalue-DT,a4),(Parse_AdrValue-DT,a4)

.nochange:

	move	#PB_020,(Parse_CPUType-DT,a4)
	move.b	(a6)+,d0
.not020:

	cmp.b	#')',d0		;(xx) (a0) (d0) ($7fff) ([xx,xx]) ([xxx])
	bne.b	GoonOldSyntax

	tst	(Parse_AdrValueSize-DT,a4)
	beq	Parse_AdrValueLong
	tst	(Parse_CPUType-DT,a4)
	beq	_ERROR_MissingBracket
	br	Parse_AdrValueLong

GoonOldSyntax:
	cmp.b	#',',d0		;([xxx,a0, ([a0, of ([xx],
	bne	_ERROR_RightParentesExpected
	moveq	#0,d2
C3DC8:
	tst.b	(S_MemIndActEnc-DT,a4)	;BS suppressed?
	ble.b	.BS_Suppressed

	move.l	(Binary_Offset-DT,a4),d5
	sub.l	d5,(Parse_AdrValue-DT,a4)
	or.w	#1,d1
.BS_Suppressed:
	or.w	#$0030,d1	;020+
	moveq	#M_AxIdx,d5

C3DE0:
	move	d1,-(sp)
	move.l	d3,-(sp)
	move	d5,-(sp)

;	tst.w	(Parse_CPUType-DT,a4)
	btst	#SB_INDIRECT,(NewSyntaxbits-DT,a4)
	beq.s	.noExtentionStuff

	moveq	#0,d3
	move.l	a6,(help-DT,a4)
	bsr	Parse_GetDofAReg	;([xxx,a0],d0 or ([xxx,a0],$ffff

	bchg	#3,d1
	tst.w	d0
	bne.b	.huplakee_welIndexReg

	moveq	#0,d3
	move.l	(help-DT,a4),a6
	subq.l	#1,a6		; de komma !! (,)
	bset	#6,2+3(SP)	; SP= d5.w/d3.l/d1.w
	bra.b	.oepsGeenIndexReg

.noExtentionStuff:
	bsr	AddrOrDataReg
	lsl.w	#4,d1
	moveq	#0,d3
	or.b	d1,d3
;	tst.w	(Parse_AdrValueSize-DT,a4)
;	beq.s	.noDisplacement
	bra.b	.noDisplacement2

.huplakee_welIndexReg:	;([xxx,A6,D1 or ([A1],A3
	lsl.w	#4,d1
	moveq	#0,d3
	or.b	d1,d3

.oepsGeenIndexReg:
;.noDisplacement:
	or.w	#1,d3		; bit8 of extention word is always 1

.noDisplacement2:
	move.b	(a6)+,d0	; ([xxx,pc],d0,
	cmp.b	#')',d0
	beq	Asm_HaakjeSluiten		;([xxx,a0,d0]) of ([xxx,a0],d0)
	cmp.b	#'.',d0
	beq.b	.getSize
	cmp.b	#'*',d0
	beq	Parse_SyntaxAfronden020
	cmp.b	#']',d0
	beq.b	.verder		;([xxx,a0,d0]
	cmp.b	#',',d0
	bne	_ERROR_IllegalOperand

	bra.b	Parse_NogEenKomma

.verder:
	move	#PB_010,(Parse_CPUType-DT,a4)
	bra.b	.noDisplacement2

.getSize:
	moveq	#~32,d0
	and.b	(a6)+,d0
	cmp.b	#'W',d0
	beq.b	.wordsize
	cmp.b	#'L',d0
	bne	_ERROR_Illegalregsiz
	bset	#3,d3		; W/L extention word
.wordsize:
	move.b	(a6)+,d0
	cmp.b	#'[',d0
	beq.b	.verder
	cmp.b	#'*',d0
	beq	Parse_SyntaxAfronden020
	cmp.b	#']',d0
	bne.b	.oldsynt
	move.b	(a6)+,d0
	move.w	#PB_010,(Parse_CPUType-DT,a4)
.oldsynt:
	cmp.b	#')',d0
	beq	Asm_HaakjeSluiten
	cmp.b	#',',d0
	bne	_ERROR_RightParentesExpected

Parse_NogEenKomma:
	or.b	#1,d3
	movem.l	d0-d7/a0-a5,-(sp)
	moveq	#PB_020,d0
	jsr	(Processor_warning).l
	jsr	(Parse_GetExprValueInD3Voor).l

	move.l	d3,d6
	bsr	Parse_GetTheSize
	cmp.b	#')',(a6)+
	bne	_ERROR_RightParentesExpected

	cmp.b	#4,d1
	beq	Parse_LongDisplacement

	tst	d7		;passone
	bmi.w	C3F48
	move.l	(Binary_Offset-DT,a4),a0
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
	tst.b	(S_MemIndActEnc-DT,a4)	;BS suppressed?
	ble.b	C3EB6
	tst	(Parse_AdrValueSize-DT,a4)
	bne.b	C3EB6
	subq	#2,d6
C3EB6:
	cmp.l	#$0000FFFF,d6
	bgt.w	_ERROR_out_of_range16bit
	move	(Parse_AdrValueSize-DT,a4),d0
	move	d6,(2,a0,d0.w)
	movem.l	(sp)+,d0-d7/a0-a5

	bsr	asmbl_send_Byte
	move	(sp)+,d5
	move.l	(sp)+,d3
	move	(sp)+,d1

	tst	(Parse_AdrValueSize-DT,a4)
	bne.b	C3F00
	moveq	#$20,d0
	btst	#5,d3
	beq.b	C3EE6
	lsr.w	#4,d0
C3EE6:
	or.b	d0,d3

	bsr	Parse_IetsMetExtentionWord
	addq.l	#2,(Binary_Offset-DT,a4)
	moveq	#0,d0
	move	(Parse_AdrValueSize-DT,a4),d0
	add.l	d0,(Binary_Offset-DT,a4)
	rts

C3F00:
	bset	#5,d3
	move.l	(Binary_Offset-DT,a4),a0
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
	move	(Parse_AdrValueSize-DT,a4),d0
	lsr.b	#2,d0
	beq.b	C3F1E
	move.l	(Parse_AdrValue-DT,a4),(1,a0)
	bra.b	C3F30

C3F1E:
	cmp.l	#$0000FFFF,(Parse_AdrValue-DT,a4)
	bgt.w	_ERROR_out_of_range16bit
	move	(Parse_AdrValue+2-DT,a4),(1,a0)
C3F30:
	lsl.b	#4,d0
	addq.b	#(1<<2)|2,d0
	cmp	#PB_010,(Parse_CPUType-DT,a4)
	bne.b	C3EE6
	subq.b	#1<<2,d0
	bra.b	C3EE6

C3F48:
	movem.l	(sp)+,d0-d7/a0-a5
	move	(sp)+,d5
	move.l	(sp)+,d3
	move	(sp)+,d1

	addq.l	#4,(Binary_Offset-DT,a4)
	moveq	#0,d0
	move	(Parse_AdrValueSize-DT,a4),d0
	add.l	d0,(Binary_Offset-DT,a4)
	rts

Parse_LongDisplacement:
	tst	d7	;passone
	bmi.w	C4006

	move.l	(Binary_Offset-DT,a4),a0
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
	tst.b	(S_MemIndActEnc-DT,a4)	;BS suppressed?
	ble.b	C3F86

	tst	(Parse_AdrValueSize-DT,a4)
	bne.b	C3F86
	subq.l	#2,d6
C3F86:
	move	(Parse_AdrValueSize-DT,a4),d0

	move.l	d6,(2,a0,d0.w)
	movem.l	(sp)+,d0-d7/a0-a5
	bsr	asmbl_send_Byte
	move	(sp)+,d5
	move.l	(sp)+,d3
	move	(sp)+,d1

	move.w	(Parse_AdrValueSize-DT,a4),d0
	bne.b	C3FBE

	moveq	#$30,d0
C3FA4:
	or.w	d0,d3
	bsr	Parse_MakeExtentionLongword
	addq.l	#4,(Binary_Offset-DT,a4)
	moveq	#0,d0
	move	(Parse_AdrValueSize-DT,a4),d0
	add.l	d0,(Binary_Offset-DT,a4)
	rts

C3FBE:
	bset	#5,d3
	move.l	(Binary_Offset-DT,a4),a0	
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
	move	(Parse_AdrValueSize-DT,a4),d0
	lsr.b	#2,d0
	beq.b	C3FDC
	move.l	(Parse_AdrValue-DT,a4),(1,a0)

	bra.b	C3FEE

C3FDC:
	cmp.l	#$0000FFFF,(Parse_AdrValue-DT,a4)
	bgt.w	_ERROR_out_of_range16bit
	move	(Parse_AdrValue+2-DT,a4),(1,a0)
C3FEE:
	lsl.b	#4,d0
	or.b	#3|(1<<2),d0
	cmp	#PB_010,(Parse_CPUType-DT,a4)
	bne.b	C3FA4
	subq.b	#1<<2,d0
	bra.b	C3FA4

C4006:
	movem.l	(sp)+,d0-d7/a0-a5
	move	(sp)+,d5
	move.l	(sp)+,d3
	move	(sp)+,d1
	addq.l	#6,(Binary_Offset-DT,a4)
	moveq	#0,d0
	move	(Parse_AdrValueSize-DT,a4),d0
	add.l	d0,(Binary_Offset-DT,a4)
	rts

Parse_SyntaxAfronden020:
	move.l	d0,-(sp)
	moveq	#PB_020,d0
	jsr	(Processor_warning).l
	move.b	(a6)+,d0
	cmp.b	#'@',d0		; $@ are rarely (never?) used, so order
	beq.b	.Octal		; doesn't matter but still have to check
	cmp.b	#'$',d0
	bne.b	.NotHex

.NextCh	move.b	(a6)+,d0
.NotHex	sub.b	#'0',d0
	beq.b	.NextCh
	cmp.b	#8,d0
	bhi.b	.BadScale

.MapIt	move.b	(.ScaleMap,pc,d0.w),d0
	bmi.b	.BadScale
	or.b	d0,d3

	move.l	(sp)+,d0
	bra.w	C3DE0\.wordsize

.Octal	move.b	(a6)+,d0
	sub.b	#'0',d0
	beq.b	.Octal
	cmp.b	#1,d0		; extra: 8 = @10
	bne.b	.NotOctal8
	cmp.b	#'0',(a6)
	bne.b	.NotOctal8
	addq.l	#1,a6
	moveq	#8,d0
	bra.b	.MapIt
.NotOctal8
	cmp.b	#7,d0
	bls.b	.MapIt
.BadScale
	bra.w	_ERROR_Illegalscales

.ScaleMap	;  1   2   -  4   -  -  -  8
	DC.B	-1,0*2,1*2,-1,2*2,-1,-1,-1,3*2
	EVEN

Asm_HaakjeSluiten:
	tst	(Parse_AdrValueSize-DT,a4)	;([xxx,a0,d0])
	beq.b	C408C
	tst.l	(Parse_AdrValue-DT,a4)
	beq.b	C408C
	tst	(Parse_CPUType-DT,a4)
	beq	_ERROR_MissingBracket
C408C:
	bsr	asmbl_send_Byte		;d3=upper byte of extention word
	move	(sp)+,d5
	move.l	(sp)+,d3
	move	(sp)+,d1

	tst	(Parse_AdrValueSize-DT,a4)
	bne.b	.sizeWL

	tst.w	(Parse_CPUType-DT,a4)
	beq.s	.noExtentions
	or.w	#(1<<4)|(1<<0),d3	; null base/outer displacement in ext. word
.noExtentions:
	tst.b	(S_MemIndActEnc-DT,a4)
	ble.w	Parse_IetsMetExtentionWord

.noextention:
	tst.b	d3
	bne	asmbl_send_Byte
	moveq	#$fe-256,d3
	br	asmbl_send_Byte

.size0andIndirect:
.sizeWL:
	or.b	#1,d3
	moveq	#~1,d0
	and.w	(Parse_CPUType-DT,a4),d0
	add.b	d0,d0
	or.b	d0,d3

	move	(Parse_AdrValueSize-DT,a4),d0
	bne.b	.noNullDisplacement

	or.b	#$80,d3		;Base reg suppressed!?!
;	bset	#4,d3		;null displacement
;	bsr	Parse_IetsMetExtentionWord
;	rts

.noNullDisplacement:
	bset	#5,d3
	lsr.b	#2,d0
	lsl.b	#4,d0		;word/long displacement
	or.b	d0,d3

	move.l	(Binary_Offset-DT,a4),a0
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a0

	tst.b	d0
	bne.b	C4106	;word size?
	tst	d7	;passone
	bmi.b	.pass1
	cmp.l	#$0000FFFF,(Parse_AdrValue-DT,a4)
	bgt.w	_ERROR_out_of_range16bit
	move	(Parse_AdrValue+2-DT,a4),(1,a0)
.pass1:
	bsr	Parse_IetsMetExtentionWord
	addq.l	#2,(Binary_Offset-DT,a4)
	rts

C4106:			;long size
	tst	d7	;passone
	bmi.b	.pass1
	move.l	(Parse_AdrValue-DT,a4),(1,a0)
.pass1:
	bsr	Parse_IetsMetExtentionWord
	addq.l	#4,(Binary_Offset-DT,a4)
	rts

;Parse_JustExtWord:
;	bclr	#5,d3	;size = 0
;	bsr	Parse_IetsMetExtentionWord
;	rts


Parse_AdrValueLong:
	cmp.b	#'+',(a6)
	bne.b	.NoParse_PostIncr

	tst	(Parse_AdrValueSize-DT,a4)
	bne	_ERROR_InvalidAddrMode

	tst.b	(S_MemIndActEnc-DT,a4)
	bgt.w	_ERROR_IllegalOperand
	btst	#3,d1
	bne	_ERROR_IllegalOperand
	addq.w	#1,a6
	or.w	#$0018,d1
	moveq	#M_AxInc,d5
	rts

.NoParse_PostIncr:
	tst	(Parse_AdrValueSize-DT,a4)
	bne.b	Parse_DisplacementAdrOrAreg
	btst	#SB_AREGFIRST,(NewSyntaxbits-DT,a4)
	bne.b	Parse_DisplacementAdrOrAreg

	tst.b	(S_MemIndActEnc-DT,a4)
	ble.b	C416E
	move.l	a0,-(sp)
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),a0
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
	move	#$FFFE,(2,a0)
	addq.l	#2,(Binary_Offset-DT,a4)
	move.l	(sp)+,a0
C416E:
	or.w	#$0010,d1
	moveq	#M_AxInd,d5
	rts

Parse_DisplacementAdrOrAreg:

	or.w	#$0151,d3	;was $161
	move.l	(Binary_Offset-DT,a4),a0
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a0

	btst	#SB_AREGFIRST,(NewSyntaxbits-DT,a4)
	bne.b	Parse_StoreExtentionWord

	bclr	#4,d3
	bset	#5,d3
	tst.b	(S_MemIndActEnc-DT,a4)
	ble.b	.itsPc
	or.w	#1,d1
	move.l	(Binary_Offset-DT,a4),d5
	sub.l	d5,(Parse_AdrValue-DT,a4)
.itsPc:

;	move.l	(Binary_Offset-DT,a4),a0
;	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a0

	cmp	#2,(Parse_AdrValueSize-DT,a4)	;word?
	beq.b	Parse_InitExtentionWord
	bset	#4,d3
	addq.l	#4,(Binary_Offset-DT,a4)
	tst	d7	;passone
	bmi.b	Parse_StoreExtentionWord

;	btst	#SB_INDIRECT,(NewSyntaxbits-DT,a4)
;	beq.b	.nochange
;	cmp.b	#$3b,d1		;PC relative?
;	beq.b	.nochange
;	tst	d2
;	beq.b	.nochange

;	tst.b	d3		;([label,Ax]) : ([label]) ?
;	bmi.b	.nochange
;	cmp.w	#$171,d3
;	bne.b	.nochange
;	jsr	test_debug
;	subq.l	#8,(Parse_AdrValue-DT,a4)
;.nochange:

	move.l	(Parse_AdrValue-DT,a4),(2,a0)
	bra.b	Parse_StoreExtentionWord

Parse_InitExtentionWord:
	addq.l	#2,(Binary_Offset-DT,a4)
	tst	d7	;passone
	bmi.b	Parse_StoreExtentionWord
	cmp.l	#$0000FFFF,(Parse_AdrValue-DT,a4)
	bgt.w	_ERROR_out_of_range16bit
	move	(Parse_AdrValue+2-DT,a4),(2,a0)

Parse_StoreExtentionWord:
	tst	d7	;passone
	bmi.b	.pass1
	move	d3,(a0)
.pass1:
	addq.l	#2,(Binary_Offset-DT,a4)
	or.w	#$0030,d1
	moveq	#M_AxInd,d5
	rts

Parse_GetTheSize:
	cmp.b	#'.',(a6)
	bne.b	.defaultSize
	addq.w	#1,a6
	moveq	#~32,d0
	and.b	(a6)+,d0
	cmp.b	#'W',d0
	beq.b	C4266
	cmp.b	#'L',d0
	bne	_ERROR_IllegalSize
.defaultSize:
	moveq	#4,d1
	rts

Parse_GetFloatSize:
	moveq	#"r",d1
	cmp.b	#".",(a6)
	bne.b	.found
	addq.w	#1,a6
	moveq	#~32,d0
	and.b	(a6)+,d0
	moveq	#"q",d1
	cmp.b	#"S",d0
	beq.b	.found
	moveq	#"u",d1
	cmp.b	#"D",d0
	beq.b	.found
	moveq	#"r",d1
	cmp.b	#"X",d0
	beq.b	.found
	moveq	#"s",d1
	cmp.b	#"P",d0
	beq.b	.found
	br	_ERROR_IllegalSize
.found:
	rts

PARSE_GET_SIZE_BWL_DEF_BYTE_NOSPACE:
	cmp.b	#".",(a6)
	bne.b	C426A
	addq.w	#1,a6
	moveq	#~32,d0
	and.b	(a6)+,d0
	cmp.b	#"B",d0
	beq.b	C426A
	cmp.b	#"W",d0
	beq.b	C4266
	cmp.b	#"L",d0
	bne	_ERROR_IllegalSize
	moveq	#4,d1
	rts
C4266:	moveq	#2,d1
	rts
C426A:	moveq	#1,d1
	rts

Parse_GetDofAReg:	; RETURN_NUMBER_FOR_ADDRESS_REGISTER
	bsr	NEXTSYMBOL
	cmp.b	#NS_ALABEL,d1
	bne.b	C42F6
	btst	#AF_LOCALFOUND,d7
	bne.b	C42D2
	lea	(SourceCode-DT,a4),a3
	move	(a3)+,d1
	bpl.b	C42D2			; check equr
	and	#$DFDF,d1
	moveq	#~7,d0
	and	d1,d0
	sub	d0,d1
	cmp	#('D0'&$DFDF)+$8000,d0	; Dx?
	beq.b	.datareg
	cmp	#('A0'&$DFDF)+$8000,d0	; Ax?
	bne.b	Parse_PCorSP
	moveq	#1,d0
	rts

.datareg:
	addq.w	#8,d1
	moveq	#1,d0
	rts

C42F6:
	sf	(S_MemIndActEnc-DT,a4)
	jsr	(PARSE_START_VALUE_IN_D3)
	moveq	#0,d0
	rts

Parse_PCorSP:
	add	d1,d0
	cmp	#"PC"+$8000,d0	;PC
	beq.b	C42BC
	cmp	#"SP"+$8000,d0	;SP
	bne.b	C42D2
	moveq	#7,d1
	rts

C42BC:
	tst.b	(S_MemIndActEnc-DT,a4)
	beq.b	C42CE
	moveq	#$3A,d1
	move.b	d1,(S_MemIndActEnc-DT,a4)	; set to any positive value
	rts

C42CE:
	moveq	#-1,d0
	rts

C42D2:
	move	d2,-(sp)
	move.l	d3,-(sp)
	bsr	Parse_FindLabel
	beq.b	C4304
	cmp	#LB_EQUR,d2
	bne.b	C4310
	cmp.w	#PB_APOLLO,(CPU_type-DT,a4)	;APOLLO support PC writes.
	beq.b	.ok
	tst	d3
	beq	_ERROR_AddressRegExp
.ok
	swap	d3
	move	d3,d1
	subq.w	#8,d1
	move.l	(sp)+,d3
	move	(sp)+,d2
	moveq	#1,d0
	rts

C4304:
	addq.l	#6,sp
	jsr	(PARSE_START_VALUE_IN_D3_UNKNOWN)
	moveq	#0,d0
	rts

C4310:
	addq.l	#6,sp
	jsr	(PARSE_START_VALUE_IN_D3_KNOWN)
	moveq	#0,d0
	rts

Parse_CheckIfReservedWord:
	lea	(SourceCode-DT,a4),a3
	move	(a3)+,d1
	and	#$DFDF,d1
	bpl.b	Parse_CheckIfReservedWord3	; 3 or more chars?
	moveq	#~7,d0
	and	d1,d0
	sub	d0,d1
	cmp	#$C410,d0	;Dx
	beq.b	C4350
	cmp	#$C110,d0	;Ax
	bne.b	C4356
	moveq	#M_Ax,d5
	addq.w	#8,d1
	rts

C4350:
	moveq	#M_Dx,d5
	moveq	#1,d0
	rts

C4356:
	add	d1,d0
	cmp	#"SP"+$8000,d0
	beq.b	C4366
	cmp	#"SR"+$8000,d0
	beq.b	C436C
	cmp	#"TC"+$8000,d0
	beq.b	C45BE
	cmp	#"AC"+$8000,d0
	beq.b	C4666
	moveq	#0,d0		; not found
	rts

C4366:
	moveq	#M_Ax,d5	; sp = a7
	moveq	#15,d1
	rts

C436C:
	move	#M_SrCcr,d5
	moveq	#$007C,d1
	rts

C45BE:
	tst.b	(MMUAsmBits-DT,a4)
	bne.b	C4658
	move.l	#$0003FFFF,d5
	rts
C4658:
	move.b	#$80,(OpperantSize-DT,a4)
	move.l	#$8000FFFF,d5
	rts

C4666:
	move.l	#$8007FFFF,d5
	rts

Parse_CheckIfReservedWord3:	; words with 3 or more chars
	swap	d1
	move	(a3),d1
	and	#$DFDF,d1
	bpl.w	Parse_CheckIfReservedWord5	; 5 or more chars?
	cmp.l	#"USP"<<(1*8)+$8000,d1	;'USP'
	beq	C4580
	cmp.l	#"CCR"<<(1*8)+$8000,d1	;'CCR'
	beq	C4576
	cmp.l	#"SFC"<<(1*8)+$8000,d1	;'SFC'
	beq	C4586
	cmp.l	#"DFC"<<(1*8)+$8000,d1	;DFC
	beq	C458E
	cmp.l	#"CACR"+$8000,d1	;CACR
	beq	C4596
	cmp.l	#"VBR"<<(1*8)+$8000,d1	;VBR
	beq	C459E
	cmp.l	#"CAAR"+$8000,d1	;CAAR
	beq	C45A6
	cmp.l	#"MSP"<<(1*8)+$8000,d1	;MSP
	beq	C45AE
	cmp.l	#"ISP"<<(1*8)+$8000,d1	;ISP
	beq	C45B6
	cmp.l	#"URP"<<(1*8)+$8000,d1	;URP
	beq	C4622
	cmp.l	#"SRP"<<(1*8)+$8000,d1	;SRP
	beq	C462A

	cmp.l	#"PCR"<<(1*8)+$8000,d1	;PCR
	beq	asm_movec_PCR

	cmp.l	#"ITT"<<(1*8)+$8010,d1	;ITT0
	beq	C45DE
	cmp.l	#"ITT"<<(1*8)+$8011,d1	;ITT1
	beq	C45E6
	cmp.l	#"DTT"<<(1*8)+$8010,d1	;DTT0
	beq	C45EE
	cmp.l	#"DTT"<<(1*8)+$8011,d1	;DTT1
	beq	C45F6
	cmp.l	#"FPSR"+$8000,d1	;FPSR
	beq	C46A2
	cmp.l	#"FPCR"+$8000,d1	;FPCR
	beq	C46AC
	cmp.l	#"CRP"<<(1*8)+$8000,d1	;CRP
	beq	C466E
	cmp.l	#"DRP"<<(1*8)+$8000,d1	;DRP
	beq	C4676
	cmp.l	#"CAL"<<(1*8)+$8000,d1	;CAL
	beq	C4686
	cmp.l	#"VAL"<<(1*8)+$8000,d1	;VAL
	beq	C4690
	cmp.l	#"SCC"<<(1*8)+$8000,d1	;SCC
	beq	C469A
	cmp.l	#"PSR"<<(1*8)+$8000,d1	;PSR
	beq	C460C
	cmp.l	#"PCSR"+$8000,d1	;PCSR
	beq	C461A
	cmp.l	#"TT"<<(2*8)+$9000,d1	;TT0
	beq	C45CE
	cmp.l	#"TT"<<(2*8)+$9100,d1	;TT1
	beq	C45D6
	cmp.l	#"AC"<<(2*8)+$9000,d1	;AC0
	beq	C45CE
	cmp.l	#"AC"<<(2*8)+$9100,d1	;AC1
	beq	C45D6

	moveq	#~7,d0
	and.l	d1,d0
	sub.l	d0,d1
	cmp.l	#"BAD"<<(1*8)+$8010,d0	;BAD
	beq.b	C44F2
	cmp.l	#"BAC"<<(1*8)+$8010,d0	;BAC
	beq.b	C44FA
	move.l	d0,d1
	and	#$F000,d1
	cmp.l	#"FP"<<(2*8)+$9000,d1	;FP
	beq	C46C0
	bra.b	C44EE

Parse_CheckIfReservedWord5:	; words with 5 or more chars
	cmp.l	#"ACUS",d1	;'ACUS'
	beq.b	C4502
	cmp.l	#"FPIA",d1	;'FPIA'r
	beq	C4562
	cmp.l	#"MMUS",d1	;'MMUS'r
	beq	C454E
	cmp.l	#"IACR",d1	;'IACR'
	beq.b	C4532
	cmp.l	#"DACR",d1	;'DACR'
	beq.b	C4516
	cmp.l	#'BUSC',d1	;'BUSC'r
	beq.b	asm_movec_busc
C44EE:
	moveq	#0,d0		; not found
	rts

C44F2:
	move.l	#$C004FFFF,d5
	rts

C44FA:
	move.l	#$C005FFFF,d5
	rts

asm_movec_busc:
	move	(2,a3),d1
	and	#$DFDF,d1
	cmp	#$D200,d1
	beq	asm_movec_BUSCR
	bra.b	C44EE

C4502:
	move	(2,a3),d1
	and	#$DFDF,d1
	cmp	#$D200,d1
	beq	C460C
	bra.b	C44EE

C4516:
	move	(2,a3),d1
	and	#$DFDF,d1
	cmp	#$9000,d1
	beq	C4648
	cmp	#$9100,d1
	beq	C4650
	moveq	#0,d0
	rts

C4532:
	move	(2,a3),d1
	and	#$DFDF,d1
	cmp	#$9000,d1
	beq	C4638
	cmp	#$9100,d1
	beq	C4640
	moveq	#0,d0
	rts

C454E:
	move	(2,a3),d1
	and	#$DFDF,d1
	cmp	#$D200,d1
	beq	C45FE
	moveq	#0,d0
	rts

C4562:	; fpia
	move	(2,a3),d1
	and	#$DFDF,d1
	cmp	#$D200,d1
	beq	C46B6
	moveq	#0,d0
	rts

C4576:
	move	#M_SrCcr,d5
	moveq	#$003C,d1
	rts

C4580:
	move	#M_Usp,d5
	rts

C4586:
	move.l	#$0000FFFF,d5
	rts

C458E:
	move.l	#$0001FFFF,d5
	rts

C4596:
	move.l	#$0002FFFF,d5
	rts

C459E:
	move.l	#$0801FFFF,d5
	rts

C45A6:
	move.l	#$0802FFFF,d5
	rts

C45AE:
	move.l	#$0803FFFF,d5
	rts

C45B6:
	move.l	#$0804FFFF,d5
	rts

asm_movec_PCR:
	move.l	#$0808FFFF,d5
	rts

C45CE:
	move.l	#$8002FFFF,d5
	rts

C45D6:
	move.l	#$8003FFFF,d5
	rts

C45DE:
	move.l	#$0004FFFF,d5
	rts

C45E6:
	move.l	#$0005FFFF,d5
	rts

C45EE:
	move.l	#$0006FFFF,d5
	rts

C45F6:
	move.l	#$0007FFFF,d5
	rts

asm_movec_BUSCR:
	move.l	#$0008FFFF,d5
	rts

C45FE:
	tst.b	(MMUAsmBits-DT,a4)
	bne.b	C460C
	move.l	#$0805FFFF,d5
	rts

C460C:
	move.b	#$40,(OpperantSize-DT,a4)
	move.l	#$8000FFFF,d5
	rts

C461A:
	move.l	#$8001FFFF,d5
	rts

C4622:
	move.l	#$0806FFFF,d5
	rts

C462A:
	tst.b	(MMUAsmBits-DT,a4)
	bne.b	C467E
	move.l	#$0807FFFF,d5
	rts

C4638:
	move.l	#$0004FFFF,d5
	rts

C4640:
	move.l	#$0005FFFF,d5
	rts

C4648:
	move.l	#$0006FFFF,d5
	rts

C4650:
	move.l	#$0007FFFF,d5
	rts

C466E:
	move.l	#$8003FFFF,d5
	rts

C4676:
	move.l	#$8001FFFF,d5
	rts

C467E:
	move.l	#$8002FFFF,d5
	rts

C4686:
	moveq	#-1,d1
	move.l	#$8004FFFF,d5
	rts

C4690:
	moveq	#-1,d1
	move.l	#$8005FFFF,d5
	rts

C469A:
	move.l	#$8006FFFF,d5
	rts

C46A2:	; FPSR
	moveq	#0,d0
	move.l	#$0040FFFF,d5
	rts

C46AC:	; FPCR
	moveq	#0,d0
	move.l	#$0080FFFF,d5
	rts

C46B6:	; FPIAR
	moveq	#0,d0
	move.l	#$0020FFFF,d5
	rts

C46C0:	; FPx
	move.b	(a3),d1		; preserve upper byte
	and.b	#$DF,d1
	cmp.b	#$90,d1		; '0'
	blt.b	C46E0
	cmp.b	#$97,d1		; '7'
	bgt.b	C46E0
	moveq	#~7,d0
	and	d1,d0
	sub	d0,d1
	move.l	#$0010FFFF,d5
	rts
C46E0:
	moveq	#0,d0
Parse_OneRegFound:
	rts

asm_noimmediateopp:	; PARSE_GET_EA_NOSIZE
	bsr	NEXTSYMBOL
	cmp.b	#'#',d1
	bne.b	Get_OtherEA
	br	_ERROR_InvalidAddrMode

asm_get_any_opp:	; PARSE_GET_EA
	bsr	NEXTSYMBOL
	cmp.b	#'#',d1
	beq	Asm_ImmediateOpp
Get_OtherEA:		; PARSE_GET_EA_NoImm
	cmp.b	#'(',d1
	beq	Parse_HaakjeOpenVoor
	cmp.b	#'-',d1
	beq	Parse_MinVoor

	cmp.b	#NS_ALABEL,d1
	bne	S_Value
	bsr	Parse_CheckIfReservedWord	;ook An, Dn
	bne.b	Parse_OneRegFound
	sf	(S_MemIndActEnc-DT,a4)
	jsr	(PARSE_START_LABEL_VALUE_IN_D3_AN_DN)
	br	Parse_ItsAValue

C472C:
	lea	(SourceCode-DT,a4),a1
	lea	(L047E4,pc),a0
	moveq	#0,d0
	move.b	(a6)+,d0
	move.b	(Variable_base-DT,a4,d0.w),d0
	cmp.b	#'@',d0
	bgt.b	C4756
	bne.b	.Error
	bset	#AF_LOCALFOUND,d7
	move.b	(a6)+,d0
	move.b	(Variable_base-DT,a4,d0.w),d0
	bgt.b	C475A
.Error	br	_ERROR_IllegalOperand

C4756:
	bclr	#AF_LOCALFOUND,d7
C475A:
	move.b	d0,(a1)+
C475C:
	move.b	(a6)+,d0
	move.b	(a0,d0.w),(a1)+
	ble.b	C47D6
	move.b	(a6)+,d0
	move.b	(a0,d0.w),(a1)+
	bgt.b	C475C
	subq.w	#3,a1
	or.w	#$8000,(a1)
	subq.l	#1,a6
	rts

AddrOrDataReg:
	bsr.b	C472C
	btst	#AF_LOCALFOUND,d7
	bne.b	C47B6
	lea	(SourceCode-DT,a4),a3
	move	(a3)+,d1
	bpl.b	C47B6
	and	#$DFDF,d1
	moveq	#~7,d0
	and	d1,d0
	sub	d0,d1
	cmp	#$C410,d0	; dx?
	beq.b	C47A4
	cmp	#$C110,d0	; ax?
	bne.b	C47A8
	moveq	#M_Ax,d5
	addq.w	#8,d1
	rts
C47A4:
	moveq	#M_Dx,d5
	rts

C47A8:
	add	d1,d0
	cmp	#$D350,d0	; sp?
	bne.b	C47B6
	moveq	#M_Ax,d5
	moveq	#15,d1
	rts

C47B6:
	move.l	d2,-(sp)
	move.l	d3,-(sp)
	bsr	Parse_FindLabel
	beq	_ERROR_UndefSymbol
	cmp	#LB_EQUR,d2
	bne	_ERROR_Registerexpected
	move	d3,d5
	swap	d3
	move	d3,d1
	move.l	(sp)+,d3
	move.l	(sp)+,d2
	rts

C47D6:
	move	#$8000,d1
	add	-(a1),d1
	clr.b	d1
	move	d1,(a1)
	subq.l	#1,a6
	rts


L047E4:
	DCB.B	46,0
	DC.B	-1			; .
	DC.B	0,'0123456789',0,0,0,0,0,0
	DC.B	0,"ABCDEFGHIJKLMNOPQRSTUVWXYZ",0,0,0,0
	DC.B	'['			; _
	DC.B	0
ALPHA_Two:
	DC.B	'ABCDEFGHIJKLMNOPQRSTUVWXYZ',0,0,0,0,0
	DCB.B	128,0			; 128-255

AsciiToHexTab:	; 128 bytes only
	DCB.B	48,-1
	DC.B	0,1,2,3,4,5,6,7,8,9	; 0-9
	DCB.B	7,-1
	DC.B	10,11,12,13,14,15	; A-F
	DCB.B	26,-1
	DC.B	10,11,12,13,14,15	; a-f
	DCB.B	25,-1

NEXTSYMBOL_SPACE:
	moveq	#0,d0
.Space	move.b	(a6)+,d0
	tst.b	(Variable_base-DT,a4,d0.w)
	bmi.b	.Space
	move	d0,d1
	add.b	d1,d1
	add	(W0498A,pc,d1.w),d1
	jmp	(W0498A,pc,d1.w)

NEXTSYMBOL:
	moveq	#0,d0
	move.b	(a6)+,d0
	move	d0,d1
	add.b	d1,d1
	add	(W0498A,pc,d1.w),d1
	jmp	(W0498A,pc,d1.w)

W0498A:
	dr.w	C4D0E
	dr.w	C4A8A
	dr.w	C4A8A
	dr.w	C4A8A
	dr.w	C4A8A
	dr.w	C4A8A
	dr.w	C4A8A
	dr.w	C4A8A
	dr.w	C4A8A
	dr.w	C4A8A
	dr.w	C4A8A
	dr.w	C4A8A
	dr.w	C4A8A
	dr.w	C4A8A
	dr.w	C4A8A
	dr.w	C4A8A
	dr.w	C4A8A
	dr.w	C4A8A
	dr.w	C4A8A
	dr.w	C4A8A
	dr.w	C4A8A
	dr.w	C4A8A
	dr.w	C4A8A
	dr.w	C4A8A
	dr.w	C4A8A
	dr.w	C4A8A
	dr.w	C4A8A
	dr.w	C4A8A
	dr.w	C4A8A
	dr.w	C4A8A
	dr.w	C4A8A
	dr.w	C4A8A
	dr.w	_ERROR_NOoperandspac	; ' '
	dr.w	C4A8A
	dr.w	C4D12
	dr.w	C4A8A
	dr.w	C4B60			; $
	dr.w	C4B8A
	dr.w	C4A8A
	dr.w	C4D12
	dr.w	C4A8A
	dr.w	C4A8A
	dr.w	C4A8A
	dr.w	C4A8A
	dr.w	C4A8A
	dr.w	C4A8A
	dr.w	C4BCC
	dr.w	C4A8A
	dr.w	C4A8E
	dr.w	C4A8E
	dr.w	C4A8E
	dr.w	C4A8E
	dr.w	C4A8E
	dr.w	C4A8E
	dr.w	C4A8E
	dr.w	C4A8E
	dr.w	C4A8E
	dr.w	C4A8E
	dr.w	C4A8A
	dr.w	C4CFA			; ; (comment)
	dr.w	C4A8A
	dr.w	C4A8A
	dr.w	C4A8A
	dr.w	C4A8A
	dr.w	C4BA8
	dr.w	C4BE4
	dr.w	C4BE4
	dr.w	C4BE4
	dr.w	C4BE4
	dr.w	C4BE4
	dr.w	Symbol_Filesize		; F
	dr.w	C4BE4
	dr.w	C4BE4
	dr.w	C4BE4
	dr.w	C4BE4
	dr.w	C4BE4
	dr.w	C4BE4
	dr.w	C4BE4
	dr.w	C4BE4
	dr.w	C4BE4
	dr.w	C4BE4
	dr.w	C4BE4
	dr.w	C4BE4
	dr.w	C4BE4
	dr.w	C4BE4
	dr.w	C4BE4
	dr.w	C4BE4
	dr.w	C4BE4
	dr.w	C4BE4
	dr.w	C4BE4
	dr.w	C4BE4
	dr.w	C4A8A
	dr.w	C4A8A
	dr.w	C4A8A
	dr.w	C4A8A
	dr.w	C4BE4
	dr.w	C4D12
	dr.w	C4BE4
	dr.w	C4BE4
	dr.w	C4BE4
	dr.w	C4BE4
	dr.w	C4BE4
	dr.w	Symbol_Filesize		; f
	dr.w	C4BE4
	dr.w	C4BE4
	dr.w	C4BE4
	dr.w	C4BE4
	dr.w	C4BE4
	dr.w	C4BE4
	dr.w	C4BE4
	dr.w	C4BE4
	dr.w	C4BE4
	dr.w	C4BE4
	dr.w	C4BE4
	dr.w	C4BE4
	dr.w	C4BE4
	dr.w	C4BE4
	dr.w	C4BE4
	dr.w	C4BE4
	dr.w	C4BE4
	dr.w	C4BE4
	dr.w	C4BE4
	dr.w	C4BE4
	dr.w	C4A8A
	dr.w	C4A8A
	dr.w	C4A8A
	dr.w	C4A8A
	dr.w	C4A8A

C4A8A:	move	d0,d1		; error
	rts

C4A8E:		; handles decimal
	moveq	#9,d1
	moveq	#'0',d2
	sub.b	d2,d0
	move.l	d0,d3
	move.b	(a6)+,d0
	sub.b	d2,d0
	cmp.b	d1,d0
	bhi.b	C4AB0
C4A9E:
	add.l	d3,d3
	add.l	d3,d0
	lsl.l	#2,d3
	add.l	d0,d3
	moveq	#0,d0
	move.b	(a6)+,d0
	sub.b	d2,d0
	cmp.b	d1,d0
	bls.b	C4A9E
C4AB0:
	subq.w	#1,a6
	moveq	#0,d2
	moveq	#NS_AVALUE,d1
	rts


not_filesize2:
	move.l	(sp)+,a0
not_filesize:
	move.l	(sp)+,a6
	br	C4BE4

Symbol_Filesize:
	move.l	a6,-(sp)
	IF	MC020
	move.l	(a6)+,d3
	and.l	#$DFDFDFDF,d3
	cmp.l	#'ILES',d3
	bne.b	not_filesize
	move.l	(a6)+,d3
	and.l	#$DFDFDFFF,d3
	cmp.l	#'IZE(',d3
	bne.b	not_filesize
	ELSE
	move.b	(a6)+,d3
	swap	d3
	move.b	(a6)+,d3
	lsl.w	#8,d3
	move.b	(a6)+,d3
	and.l	#$00DFDFDF,d3
	cmp.l	#'ILE',d3
	bne.b	not_filesize
	move.b	(a6)+,d3
	lsl.w	#8,d3
	move.b	(a6)+,d3
	swap	d3
	move.b	(a6)+,d3
	lsl.w	#8,d3
	move.b	(a6)+,d3
	and.l	#$DFDFDFDF,d3
	cmp.l	#'SIZE',d3
	bne.b	not_filesize
	cmp.b	#'(',(a6)+
	bne.b	not_filesize
	ENDIF
	move.l	a0,-(sp)
	lea	(Filesize_TmpPath-DT,a4),a0
.copy_path
	move.b	(a6)+,d3
	beq.b	not_filesize2
	move.b	d3,(a0)+
	cmp.b	#')',d3
	bne.b	.copy_path
	clr.b	-(a0)
	move.l	(sp)+,a0
	move.l	a6,(sp)

	movem.l	d0/d4-d7/a0-a5,-(sp)
	lea	(Filesize_TmpPath-DT,a4),a6
	lea	(SourceCode-DT,a4),a1
	jsr	(ASSEM_RETURN_STRING_UCASE)	; this call can cause an error
	lea	(CurrentAsmLine-DT,a4),a0
	lea	(INCLUDE_DIRECTORY-DT,a4),a1
	lea	(SourceCode-DT,a4),a3
.C4B2E	move.b	(a1)+,(a0)+
	bne.b	.C4B2E
	subq.w	#1,a0
.C4B34	move.b	(a3)+,(a0)+
	bne.b	.C4B34
	jsr	(GetDiskFileLengte).l
	move.l	d0,d3
	movem.l	(sp)+,d0/d4-d7/a0-a5

	moveq	#0,d2
	moveq	#NS_AVALUE,d1
	moveq	#0,d0
	move.l	(sp)+,a6
	rts

C4B60:		; handles hexadecimal
	moveq	#0,d3
	lea	(AsciiToHexTab,pc),a0
	move.b	(a6)+,d0
	bmi.b	C4Bxx_IllegalOperand
	move.b	(a0,d0.w),d0
	bmi.b	C4Bxx_IllegalOperand
C4B74:
	lsl.l	#4,d3
	or.b	d0,d3
	move.b	(a6)+,d0
	bmi.b	C4B82
	move.b	(a0,d0.w),d0
	bpl.b	C4B74
C4B82:
	subq.w	#1,a6
	moveq	#0,d2
	moveq	#NS_AVALUE,d1
	rts

C4Bxx_IllegalOperand:
	bra	_ERROR_IllegalOperand

C4B8A:		; handles binary
	moveq	#0,d3
	moveq	#-'0',d0
	add.b	(a6)+,d0
	lsr.b	#1,d0
	bne.b	C4Bxx_IllegalOperand
C4B96:
	addx.l	d3,d3
	moveq	#-'0',d0
	add.b	(a6)+,d0
	lsr.b	#1,d0
	beq.b	C4B96
	subq.w	#1,a6
	moveq	#0,d2
	moveq	#NS_AVALUE,d1
	rts

C4BA8:		; handles octal
	moveq	#0,d3
	moveq	#'0',d2
	moveq	#7,d1
	move.b	(a6)+,d0
	sub.b	d2,d0
	cmp.b	d1,d0
	bhi.b	C4Bxx_IllegalOperand
C4BB8:
	lsl.l	#3,d3
	or.b	d0,d3
	move.b	(a6)+,d0
	sub.b	d2,d0
	cmp.b	d1,d0
	bls.b	C4BB8
	subq.w	#1,a6
	moveq	#0,d2
	moveq	#NS_AVALUE,d1
	rts

C4BCC:		; handles local var
	bset	#AF_LOCALFOUND,d7
	bclr	#AF_GETLOCAL,d7
	lea	(SourceCode-DT,a4),a1
	move.b	(a6)+,d0
	move.b	(Variable_base-DT,a4,d0.w),(a1)+
	bgt.b	C4BF4
	br	ERROR_IllegalOperatorInBSS

C4BE4:		; handles A-Z a-z _
	and.w	#~((1<<AF_LOCALFOUND)|(1<<AF_GETLOCAL)),d7
	lea	(SourceCode-DT,a4),a1
	move.b	(Variable_base-DT,a4,d0.w),(a1)+
C4BF4:
	move.b	(a6)+,d0
	move.b	(Variable_base-DT,a4,d0.w),(a1)+
	ble.b	C4C74
	move.b	(a6)+,d0
	cmp.b	#'*',d0
	bne.b	C4C14
	cmp.b	#',',(1,a6)
	beq.b	C4C68
	cmp.b	#']',(1,a6)
	beq.b	C4C68
C4C14:
	cmp.b	#'.',d0
	bne.b	C4C3A
	cmp.b	#',',(1,a6)
	beq.b	C4C68
	cmp.b	#'*',(1,a6)
	beq.b	C4C68
	cmp.b	#')',(1,a6)
	beq.b	C4C68
	cmp.b	#']',(1,a6)
	beq.b	C4C68
C4C3A:
	move.b	(Variable_base-DT,a4,d0.w),(a1)+
	bgt.b	C4BF4
	cmp.b	#'\',d0
	beq.b	C4CA0
	cmp.b	#'$',d0
	bne.b	C4C5C
	bset	#AF_LOCALFOUND,d7
	move.b	(a6)+,d0
	tst.b	(Variable_base-DT,a4,d0.w)
	ble.b	C4C5C
	br	ERROR_IllegalOperatorInBSS

C4C5C:
	subq.w	#3,a1
	or.w	#$8000,(a1)
	subq.l	#1,a6
	moveq	#NS_ALABEL,d1
	rts

C4C68:
	or.w	#$8000,-(a1)
	subq.l	#1,a6
	moveq	#NS_ALABEL,d1
	rts

C4C74:
	cmp.b	#'\',d0
	beq.b	C4CA8
	cmp.b	#'$',d0
	bne.b	C4C90
	bset	#AF_LOCALFOUND,d7
	move.b	(a6)+,d0
	tst.b	(Variable_base-DT,a4,d0.w)
	ble.b	C4C90
	br	ERROR_IllegalOperatorInBSS

C4C90:
	move	#$8000,d1
	add	-(a1),d1
	clr.b	d1
	move	d1,(a1)
	subq.l	#1,a6
	moveq	#NS_ALABEL,d1
	rts

C4CA0:
	subq.w	#3,a1
	or.w	#$8000,(a1)
	bra.b	C4CB2

C4CA8:		; handles backslash
	move	#$8000,d1
	add	-(a1),d1
	clr.b	d1
	move	d1,(a1)
C4CB2:
	cmp.b	#'.',(a6)+
	bne.b	C4CCC
	bset	#AF_GETLOCAL,d7
	move.l	a1,-(sp)
	lea	(CurrentAsmLine-DT,a4),a1
	bsr.b	C4CCE
	move.l	a1,(LocalBufPtr-DT,a4)
	move.l	(sp)+,a1
C4CCC:
	rts

C4CCE:
	move.b	(a6)+,d0
	move.b	(Variable_base-DT,a4,d0.w),(a1)+
	ble.b	C4CEE
	move.b	(a6)+,d0
	move.b	(Variable_base-DT,a4,d0.w),(a1)+
	bgt.b	C4CCE
	move	#$8000,d1
	add	-(a1),d1
	clr.b	d1
	move	d1,(a1)
	subq.w	#1,a6
	moveq	#NS_ALABEL,d1
	rts

C4CEE:
	subq.w	#3,a1
	or.w	#$8000,(a1)
	subq.w	#1,a6
	moveq	#NS_ALABEL,d1
	rts

C4CFA:	REPT	4
		tst.b	(a6)+
		beq.b	C4D0E
	ENDR
	tst.b	(a6)+
	bne.b	C4CFA
C4D0E:
	moveq	#0,d1
	rts

C4D12:		; handles quoted string
	move.b	d0,d2
	moveq	#0,d3
	btst	#AF_BYTE_STRING,d7
	bne.b	C4D42
	move.b	(a6)+,d1
	beq	ERROR_MissingQuote
	cmp.b	d2,d1
	bne.b	C4D2A
	bra.b	C4D36

C4D28:
	lsl.l	#8,d3
C4D2A:
	move.b	d1,d3
	move.b	(a6)+,d1
	beq	ERROR_MissingQuote
	cmp.b	d2,d1
	bne.b	C4D28
C4D36:
	cmp.b	(a6)+,d2
	beq.b	C4D28
	subq.w	#1,a6
	moveq	#NS_AVALUE,d1
	moveq	#0,d2
	rts

C4D42:
	move.b	(a6)+,d1
	beq	ERROR_MissingQuote
	cmp.b	d2,d1
	bne.b	C4D56
	cmp.b	(a6)+,d2
	beq.b	C4D56
	bra.b	C4D66

C4D52:
	bsr	asmbl_send_Byte
C4D56:
	move.b	d1,d3
	move.b	(a6)+,d1
	beq	ERROR_MissingQuote
	cmp.b	d2,d1
	bne.b	C4D52
	cmp.b	(a6)+,d2
	beq.b	C4D52
C4D66:
	subq.w	#1,a6
	moveq	#NS_AVALUE,d1
	moveq	#0,d2
	rts

MAKELABEL_NOTSET:	; constant (label:, equ, =), not variable (set)
	tst.l	d7	;AF_IF_FALSE
	bmi.b	.end
	btst	#AF_LOCALFOUND,d7
	bne	MAKELABEL_LOCAL_NOTSET
	tst	d7	;passone
	bpl.b	.pass2

.pass1	bsr	Parse_CheckIfReservedWord
	bne.b	.res
	bsr	FINDLABEL_GLOBAL
	beq.b	LABEL_CONTINUE_GLOBAL

.double	bra	ERROR_DoubleSymbol
.res	bra	ERROR_ReservedWord

.pass2	bsr	FINDLABEL_GLOBAL
	beq	ERROR_UndefSymbol
	move.l	a0,(CurrentLocalPtr-DT,a4)
	move.l	a0,(LAST_LABEL_ADDRESS-DT,a4)
	bchg	#LB_PASS2BIT,(-6,a0)
	bne.b	.double
.end	rts

MAKELABEL:		; constant *or* variable
	tst.l	d7	;AF_IF_FALSE
	bmi.b	LABEL_THEEND
	btst	#AF_LOCALFOUND,d7
	bne	MAKELABEL_LOCAL
	tst	d7	;passone
	bpl.b	LABEL_PASSTWO
	bsr	Parse_CheckIfReservedWord
	bne.b	MAKELABEL_NOTSET\.res
	bsr	FINDLABEL_GLOBAL
	bne.b	LABEL_CHECK_IF_SET

LABEL_CONTINUE_GLOBAL:		; label doesn't exist, add a new one
	lea	(SourceCode+2-DT,a4),a1
	addq.w	#1,(DATA_NUMOFGLABELS-DT,a4)
	move.l	(LabelEnd-DT,a4),a0
	cmp.l	(WORK_ENDTOP-DT,a4),a0
	bge.w	ERROR_WorkspaceMemoryFull
	move.l	a0,(a2)
	moveq	#0,d0
	move.l	d0,(a0)+
	move.l	d0,(a0)+
.LOOP1:
	move	(a1)+,(a0)+
	bpl.b	.LOOP1
	move	(CurrentSection-DT,a4),(a0)+
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),(a0)+
	move.l	a0,(LAST_LABEL_ADDRESS-DT,a4)
	move.l	a0,(CurrentLocalPtr-DT,a4)
	move.l	d0,(a0)+
	move.l	a0,(LabelEnd-DT,a4)
	btst	#AF_OFFSET,d7
	bne.w	OFFSET_EQULABEL

LABEL_THEEND:
	rts

LABEL_PASSTWO:
	bsr	FINDLABEL_GLOBAL
	beq	ERROR_UndefSymbol
	bchg	#LB_PASS2BIT,(-6,a0)
	bne.b	LABEL_CHECK_IF_SET
	move.l	a0,(CurrentLocalPtr-DT,a4)
	move.l	a0,(LAST_LABEL_ADDRESS-DT,a4)
	btst	#AF_OFFSET,d7
	bne.w	OFFSET_EQULABEL
	rts

LABEL_CHECK_IF_SET:	; label already exists
	move.l	a0,(LAST_LABEL_ADDRESS-DT,a4)
	swap	d2		; to flags|section|*|flags

	and.b	#$3F,d2
	subq.b	#(LB_SET>>8)&$3F,d2
	bne	ERROR_DoubleSymbol
.is_set
	bsr	NEXTSYMBOL
	cmp.b	#NS_ALABEL,d1
	bne	ERROR_DoubleSymbol
	move.l	a6,a5
C4E50:
	move.b	(a6)+,d0
	tst.b	(Variable_base-DT,a4,d0.w)
	bmi.b	C4E50
	subq.w	#1,a6

;ASSEM_RECOGNIZE_SET
	btst	#AF_LOCALFOUND,d7
	bne	ERROR_DoubleSymbol
	lea	(SourceCode-DT,a4),a3
	move	#$DFDF,d4
	move	(a3)+,d0
	and	d4,d0
	cmp	#"SE",d0
	bne	ERROR_DoubleSymbol
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D400,d0	;SET
	bne	ERROR_DoubleSymbol
	moveq	#0,d6
	moveq	#0,d5
	jsr	(ASSEM_CMDLABELSET).l

	moveq	#0,d1
	move.b	(a6)+,d1
	beq.b	.THEEND
	cmp.b	#';',d1
	beq.b	.FINDEND
	cmp.b	#'*',d1
	beq	TR_2EOL
	tst.b	(Variable_base-DT,a4,d1.w)
	bpl.w	ERROR_IllegalOperand
.FINDEND:
	tst.b	(a6)+
	bne.b	.FINDEND
.THEEND:
	subq.w	#1,a6
	rts

;*************************
;*   LOCAL LABEL MAKER   *
;*************************

MAKELABEL_LOCAL_NOTSET:
	tst	d7	;passone
	bpl.b	C4EBE
	bsr	Parse_FindlabelLocal
	beq.b	LABEL_CONTINUE_LOCAL
	br	ERROR_DoubleSymbol

C4EBE:
	bsr	Parse_FindlabelLocal
	beq	ERROR_UndefSymbol
	move.l	a0,(LAST_LABEL_ADDRESS-DT,a4)
	bchg	#LB_PASS2BIT,(-6,a0)
	bne	ERROR_DoubleSymbol
	rts

MAKELABEL_LOCAL:
	tst	d7	;passone
	bpl.b	LOCAL_PASSTWO
	bsr	Parse_FindlabelLocal
	bne	LABEL_CHECK_IF_SET
LABEL_CONTINUE_LOCAL:
	lea	(SourceCode-DT,a4),a1
	move.l	(LabelEnd-DT,a4),a0
	cmp.l	(WORK_ENDTOP-DT,a4),a0
	bge.w	ERROR_WorkspaceMemoryFull
	move.l	a0,(a2)
	moveq	#0,d0
	move.l	d0,(a0)+
	move.l	d0,(a0)+
.C4EFA	move	(a1)+,(a0)+
	bpl.b	.C4EFA
	move	(CurrentSection-DT,a4),(a0)+
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),(a0)+
	move.l	a0,(LAST_LABEL_ADDRESS-DT,a4)
	move.l	a0,(LabelEnd-DT,a4)
	btst	#AF_OFFSET,d7
	bne.b	OFFSET_EQULABEL
	rts

LOCAL_PASSTWO:
	bsr	Parse_FindlabelLocal
	beq	ERROR_UndefSymbol
	bchg	#LB_PASS2BIT,(-6,a0)
	bne	LABEL_CHECK_IF_SET
	move.l	a0,(LAST_LABEL_ADDRESS-DT,a4)
	btst	#AF_OFFSET,d7
	beq.b	C4F60

OFFSET_EQULABEL:
	moveq	#0,d2
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),d3
	sub.l	(OFFSET_BASE_ADDRESS-DT,a4),d3
	move.l	(LAST_LABEL_ADDRESS-DT,a4),d0
	beq	ERROR_IllegalOperatorInBSS
	move.l	d0,a1
	tst	d7	;passone
	bpl.b	.p2
	move.l	d3,-(a1)
	move	d2,-(a1)
.p2	move.l	d3,(ResponsePtr-DT,a4)
	move	d2,(ResponseType-DT,a4)
	rts

MAKELABEL_SPECIAL:
	tst	d7	;passone
	bpl.b	C4F60
	lea	(SourceCode-DT,a4),a1
	move.l	(LabelEnd-DT,a4),a0
	cmp.l	(WORK_ENDTOP-DT,a4),a0
	bge.w	ERROR_WorkspaceMemoryFull
	move.l	a0,(a2)
	moveq	#0,d0
	move.l	d0,(a0)+
	move.l	d0,(a0)+
.CopyName
	move	(a1)+,(a0)+
	bpl.b	.CopyName
	move.l	a0,(LabelEnd-DT,a4)
C4F60:
	rts

C4F62:	;MAKELABEL_XREF
	tst	d7	;passone
	bpl.b	C4FAC
	bsr	Parse_CheckIfReservedWord
	bne	ERROR_ReservedWord
	bsr	FINDLABEL_GLOBAL
	bne	ERROR_DoubleSymbol
	lea	(SourceCode-DT,a4),a1
	addq.w	#1,(DATA_NUMOFGLABELS-DT,a4)
	moveq	#3,d0
	add.l	(LabelEnd-DT,a4),d0
	moveq	#-4,d1
	and.l	d1,d0
	move.l	d0,a0
	cmp.l	(WORK_ENDTOP-DT,a4),a0
	bge.w	ERROR_WorkspaceMemoryFull
	move	(a1)+,(a0)+
	move.l	a0,(a2)
	moveq	#0,d0
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	a0,d1
C4F9E:
	move	(a1)+,(a0)+
	bpl.b	C4F9E
	move	#LB_XREF|(1<<LB_PASS2BIT),(a0)+	; flags/section = $C200
	move.l	d0,(a0)+
	move.l	a0,(LabelEnd-DT,a4)
C4FAC:
	rts

SET_LAST_LABEL_TO_ORG_PTR:
	move.l	(LAST_LABEL_ADDRESS-DT,a4),d0
	beq.b	.nolabel
	clr.l	(LAST_LABEL_ADDRESS-DT,a4)
	move.l	d0,a1
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),d1
	move	(CurrentSection-DT,a4),d2
	btst	#AF_OFFSET,d7
	beq.b	.cont
	sub.l	(OFFSET_BASE_ADDRESS-DT,a4),d1
	moveq	#0,d2
.cont	tst	d7	;passone
	bpl.b	.p2
	move.l	d1,-(a1)
	move	d2,-(a1)
.nolabel
	move.l	d1,(ResponsePtr-DT,a4)
	move	d2,(ResponseType-DT,a4)
	rts

.p2	cmp.l	-(a1),d1
	bne.b	.Moved
	move	-(a1),d0
	bclr	#LB_PASS2BIT,d0
	cmp	d2,d0
	beq.b	.nolabel
.Moved	br	ERROR_Codemovedduring

Parse_FindlabelLocal:
	lea	(SourceCode-DT,a4),a3
	move.l	(CurrentLocalPtr-DT,a4),d0
	beq	ERROR_Notlocalarea
	move.l	d0,a2
	br	Parse_FindlabelNoSupertree

Parse_FindMacroExtAndLabel:
	movem.l	d0/a3,-(sp)
	lea	(SourceCode-DT,a4),a3
.ToLastWord
	move	(a3)+,d0
	bpl.b	.ToLastWord
	tst.b	d0
	bne.b	.LenEven
	move.b	(-3,a3),d0
	ror.w	#8,d0
.LenEven
	and	#$7F7F-32,d0	; strip end flag, to uppercase
	cmp	#$4042,d0	;.B
	beq.b	C5068
	cmp	#$4057,d0	;.W
	beq.b	C5070
	cmp	#$404C,d0	;.L
	beq.b	C5078
	cmp	#$4053,d0	;.S
	beq.b	C5060
	cmp	#$4044,d0	;.D
	beq.b	C5080
	cmp	#$4058,d0	;.X
	beq.b	C5088
	cmp	#$4050,d0	;.P
	beq.b	C5090
	movem.l	(sp)+,d0/a3
	st	(Asm_MacroSize-DT,a4)
	bra.b	Parse_FindLabel

C5060:	moveq	#0,d0
	bra.b	C5096

C5068:	moveq	#1,d0
	bra.b	C5096

C5070:	moveq	#2,d0
	bra.b	C5096

C5078:	moveq	#3,d0
	bra.b	C5096

C5080:	moveq	#4,d0
	bra.b	C5096

C5088:	moveq	#5,d0
	bra.b	C5096

C5090:	moveq	#6,d0
C5096:	move.b	d0,(Asm_MacroSize-DT,a4)
	movem.l	a1/a3,-(sp)
	bsr.b	Parse_FindLabel		; full name (ext included)
	movem.l	(sp)+,a1/a3
	bne.b	.C50BC			; if found, ignore ext
	or.w	#$8000,(-4,a3)		; not found, use ext and re-adjust
	subq.w	#2,a1
	tst.b	(-1,a3)
	bne.b	.C50C6
	clr	-(a3)
	clr.b	-(a3)
	movem.l	(sp)+,d0/a3
	bra.b	Parse_FindLabel		; with ext stripped

.C50BC	st	(Asm_MacroSize-DT,a4)
	movem.l	(sp)+,d0/a3
	rts

.C50C6	clr	-(a3)
	movem.l	(sp)+,d0/a3

;*****************************
;*   SUPER FAST VAR FINDER   *
;*****************************

; z-flag set found
; ----- cleared not found

; D3 - Value
; D2 - Label type

Parse_FindLabel:
	btst	#AF_LOCALFOUND,d7
	bne	Parse_FindlabelLocal
FINDLABEL_GLOBAL:
	lea	(SourceCode-DT,a4),a3
	move	(a3)+,d0
	bpl.b	.CHAROK
	move	#$8000,d1
	sub	d1,d0
	tst.b	d0
	bne.b	.NOT_ZERO
	move.b	#':',d0
.NOT_ZERO
	move	d0,(-2,a3)
	move	d1,(a3)
	addq.w	#2,a1
.CHAROK
	move.l	(LabelStart-DT,a4),a2
	sub.w	#'@'<<8+'0',d0		; 1st char is @-based, 2nd is 0-based
	moveq	#0,d3
	move.b	d0,d3
	sub.b	d3,d0
	lsr.w	#4,d0
	move	d0,d1
	move	(LabelRollValue-DT,a4),d2	; d2 = 1|2
	lsl.w	d2,d1
	add	d1,d0
	add	d3,d0
	add	d0,d0
	add	d0,d0
	add	d0,a2
Parse_FindlabelNoSupertree:
	sub.l	a3,a1
	lea	(C521E,pc),a0
	sub.l	a1,a0
	sub.l	a1,a0
	move.l	a0,a1
	move.l	a3,d2
	move.l	(a2),d0
	beq	C526E
	move.l	d0,a2
	lea	(8,a2),a0
	jmp	(a1)

C5136:
	move.l	(a2),d0
	beq	C526E
	move.l	d0,a2
	lea	(8,a2),a0
	move.l	d2,a3
	jmp	(a1)

C5146:
	bcs.b	C5136
	move.l	(4,a2),d0
	beq	C526C
	move.l	d0,a2
	lea	(8,a2),a0
	move.l	d2,a3
	jmp	(a1)

	REPT	24
	cmpm.w	(a0)+,(a3)+
	bne.b	C5146
	ENDR
	REPT	25
	cmpm.w	(a0)+,(a3)+
	bne.b	C522C
	ENDR
C521E:
	cmpm.w	(a0)+,(a3)+
	beq.b	C5244
	bcs.b	C523E
	move.l	(4,a2),d0
	beq.b	C526C
	bra.b	C5278

C522C:
	bcs.b	C5274
	move.l	(4,a2),d0
	beq.b	C5282
	move.l	d0,a2
	lea	(8,a2),a0
	move.l	d2,a3
	jmp	(a1)

C523E:
	move.l	(a2),d0
	beq.b	C526E
	bra.b	C5278

C5244:	; symbol found
	move.b	(a0),d2
	swap	d2
	move	(a0)+,d2		; *|flags|flags|section
	move.l	(a0)+,d3		; value
	bclr	#AF_GETLOCAL,d7
	beq.b	.Global
	move.l	(LocalBufPtr-DT,a4),a1
	move.l	a0,a2
	lea	(CurrentAsmLine-DT,a4),a3
	bra.w	Parse_FindlabelNoSupertree

.Global	moveq	#NS_AVALUE,d1		; set d1 last
	rts

C526C:
	addq.w	#4,a2
C526E:
	bclr	#AF_GETLOCAL,d7
	bra.b	C5284

C5274:
	move.l	(a2),d0
	beq.b	C5284
C5278:
	move.l	d0,a2
	lea	(8,a2),a0
	move.l	d2,a3
	jmp	(a1)

C5282:
	addq.w	#4,a2
C5284:
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d1			; set d1 last
	rts

;*******************************************************

ASSEM_RECON_SECTION_TYPE:
	bsr	Parse_GetKomma
	bsr	NEXTSYMBOL
	cmp.b	#NS_ALABEL,d1
	bne	ERROR_IllegalSectio
	lea	(SECTION_TYPE,pc),a0
	lea	(SourceCode-DT,a4),a3
	bsr	ASSEM_RECOGNIZE_ANY_CMD
	beq	ERROR_IllegalSectio
	rts

SECTION_TYPE:
	DR.W	.TYPE-4,.TYPE_LAST
.TYPE_LAST
.TYPE	DC.W	'DA'
	DR.W	.DA-4,.DA_END
	DC.W	'CO'
	DR.W	.CO-4,.CO_END
	DC.W	'BS'
	DR.W	.BS-4,.BS_END
	DC.W	0

;---  Code  ---
.CO_END	DC.W	'DE'+$8000
	DR.W	.CODE_P
.CO	DC.W	'DE'
	DR.W	.CODE-4,.CODE_END
	DC.W	0

.CODE_END
	DC.W	'[P'+$8000
	DR.W	.CODE_P
	DC.W	'[F'+$8000
	DR.W	.CODE_F
	DC.W	'[C'+$8000
	DR.W	.CODE_C
.CODE	DC.W	0

.CODE_P	DC.W	0
.CODE_C	DC.W	1
.CODE_F	DC.W	2

;---  Data  ---
.DA_END	DC.W	'TA'+$8000
	DR.W	.DATA_P
.DA	DC.W	'TA'
	DR.W	.DATA-4,.DATA_END
	DC.W	0

.DATA_END
	DC.W	'[P'+$8000
	DR.W	.DATA_P
	DC.W	'[F'+$8000
	DR.W	.DATA_F
	DC.W	'[C'+$8000
	DR.W	.DATA_C
.DATA	DC.W	0

.DATA_P	DC.W	4+0
.DATA_C	DC.W	4+1
.DATA_F	DC.W	4+2

;---  BSS  ---
.BS_END	DC.W	'S'<<8+$8000
	DR.W	.BSS_P
.BS	DC.W	'S['
	DR.W	.BSS-4,.BSS_END
	DC.W	0

.BSS_END
	DC.W	'P'<<8+$8000
	DR.W	.BSS_P
	DC.W	'F'<<8+$8000
	DR.W	.BSS_F
	DC.W	'C'<<8+$8000
	DR.W	.BSS_C
.BSS	DC.W	0

.BSS_P	DC.W	$88+0
.BSS_C	DC.W	$88+1
.BSS_F	DC.W	$88+2


ASSEM_RECOGNIZE_ANY_CMD:
	move	#$dfdf,d4
.Loop
	move	(a3)+,d0
	and	d4,d0
	bmi.b	.LastWord
	add	(a0),a0
.Loop1	addq.w	#4,a0
	cmp	(a0)+,d0
	blo.b	.Loop1
	beq.b	.Loop
.NotFound
	moveq	#0,d0
	rts
.LastWord
	add	(2,a0),a0
.Loop2	addq.w	#2,a0
	cmp	(a0)+,d0
	blo.b	.Loop2
	bne.b	.NotFound
	add	(a0),a0
	move	(a0)+,d6
	moveq	#0,d5
	moveq	#1,d0
	rts

;************** ASSEMBLER TABLE ********

Asm_Table:
	dc.w	HandleMacroos-Asm_Table	;@
	dc.w	AsmA-Asm_Table
	dc.w	AsmB-Asm_Table
	dc.w	AsmC-Asm_Table
	dc.w	AsmD-Asm_Table
	dc.w	AsmE-Asm_Table
	dc.w	AsmF-Asm_Table
	dc.w	AsmG-Asm_Table
	dc.w	AsmH-Asm_Table	;HandleMacroos-Asm_Table
	dc.w	AsmI-Asm_Table
	dc.w	AsmJ-Asm_Table
	dc.w	HandleMacroos-Asm_Table ;K
	dc.w	AsmL-Asm_Table
	dc.w	AsmM-Asm_Table
	dc.w	AsmN-Asm_Table
	dc.w	AsmO-Asm_Table
	dc.w	AsmP-Asm_Table
	DC.W	AsmQ-Asm_Table
	dc.w	AsmR-Asm_Table
	dc.w	AsmS-Asm_Table
	dc.w	AsmT-Asm_Table
	dc.w	AsmU-Asm_Table
	dc.w	HandleMacroos-Asm_Table ;V
	dc.w	HandleMacroos-Asm_Table ;W
	dc.w	AsmX-Asm_Table
	dc.w	HandleMacroos-Asm_Table	;Y
	dc.w	HandleMacroos-Asm_Table	;Z
	dc.w	Asm_at-Asm_Table	;[

Asm_at:
	cmp.w	#'[G',d0	;lees %gettime
	bne	HandleMacroos
	move.w	(a3)+,d0
	and.w	d4,d0
	cmp.l	#"ET",d0
	bne	HandleMacroos
	move.w	(a3)+,d0
	and.w	d4,d0

	cmp	#"TI",d0
	bne.b	.asm_date

	move.w	(a3)+,d0
	and.w	d4,d0
	cmp	#"ME"!$8000,d0
	bne	HandleMacroos

	moveq	#8-1,d6
	lea	TimeString,a1
	bra.b	.useit

.asm_date:
	cmp.l	#"DA",d0
	bne	HandleMacroos
	move.w	(a3)+,d0
	and.w	d4,d0
	cmp.l	#"TE"!$8000,d0
	bne	HandleMacroos

	moveq	#0,d3
	tst.b	(a6)
	beq.s	.noarg
	jsr	Parse_GetExprValueInD3Voor
.noarg:
	move.b	d3,dateformat

	jsr	(GetTheTime)		; returns buffer in a0

	moveq	#-2,d6
	lea	DateString,a0	
	move.l	a0,a1
.length:
	addq.l	#1,d6
	tst.b	(a0)+
	bne.s	.length

	cmp.b	#3,d3		;FORMAT_CND dd-mm-yy -> dd.mm.yy
	bne.s	.useit
	move.b	#'.',2(a1)
	move.b	#'.',5(a1)
.useit:
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),d0
	add.l	d6,(INSTRUCTION_ORG_PTR-DT,a4)
	addq.l	#1,(INSTRUCTION_ORG_PTR-DT,a4)
	tst	d7		;AF_PASSONE
	bmi.b	.pass1
	move.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
	add.l	d0,a0
.lopje:
	move.b	(a1)+,(a0)+
	dbf	d6,.lopje
.pass1:
	rts

AsmA:
	cmp	#'AD',d0
	beq.b	C53FA
	cmp	#'AN',d0
	beq	C57C4
	cmp	#'AS',d0
	beq	C5828
	cmp	#'AB',d0
	beq	C578E
	cmp	#'AU',d0
	beq	Asm_AU
	cmp	#'AL',d0
	beq.b	C53EA
	br	HandleMacroos

C53EA:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"IG",d0
	beq	C7210
	br	HandleMacroos

C53FA:	;ad
	move	(a3)+,d0
	and	d4,d0
	cmp	#'DQ',d0
	beq	C566C
	cmp	#'D@',d0
	beq	C56E6
	cmp	#"DQ"+$8000,d0
	beq	C574E
	cmp	#"D"<<(1*8)+$8000,d0
	beq	C570C
	cmp	#'DX',d0
	beq	C56AC
	cmp	#'DI',d0
	beq	C56CC
	cmp	#'DA',d0
	beq	C568C
	cmp	#"DX"+$8000,d0
	beq	C5774
	cmp	#"DI"+$8000,d0
	beq	C570C
	cmp	#"DA"+$8000,d0
	beq	C5726
	cmp	#'DW',d0
	beq.b	C545A
	cmp.w	#'DB',d0
	beq.b	.AddB
	br	HandleMacroos

;*** add breakpoint ********************************************

.AddB	move.w	(a3)+,d0
	and.w	d4,d0
	cmp.w	#('P'<<8)|$8000,d0
	bne.w	HandleMacroos

Asm_CmdAddBP:
	btst	#AF_DEBUG,d7
	beq.b	.Done
	tst.w	d7		; pass1?
	bmi.b	.Done

.P2	movem.l	d2-d7/a2-a6,-(sp)
	bclr	#SB2_A_XN_USED,(SomeBits2-DT,a4)
	bset	#SB2_MATH_XN_OK,(SomeBits2-DT,a4)
	bsr	CD6E0		; evaluate expr for debug
	move.l	d3,a1
	jsr	(DEBUG_ADD_BRKPT)
	movem.l	(sp)+,d2-d7/a2-a6

.Done	tst.b	(a6)+
	bne.b	.Done
	subq.w	#1,a6
	rts

;*** add watchpoint ********************************************

C545A:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"AT",d0
	bne	HandleMacroos
	move	(a3)+,d0
	and	d4,d0
	cmp	#"CH"+$8000,d0
	bne	HandleMacroos

	tst	d7	;passone
	bmi.b	.P1
	tst.b	(Asm_HaveWatches-DT,a4)
	bne.b	.NoInit
	jsr	(ZapAllCondBPsAndWatches)
	st	(Asm_HaveWatches-DT,a4)
.NoInit
	movem.l	d0-d7/a0-a5,-(sp)
	cmp.w	#8,(DEBUG_NUMOFADDS-DT,a4)
	beq	ERROR_Tomanywatchpoints
	bclr	#SB2_A_XN_USED,(SomeBits2-DT,a4)
	bset	#SB2_MATH_XN_OK,(SomeBits2-DT,a4)
	move.l	a6,-(sp)
	bsr	CD6E0		; evaluate expr for debug
	move.l	(sp)+,a6
	bsr.b	Asm_CmdAddWatchpoint
	addq.w	#1,(DEBUG_NUMOFADDS-DT,a4)
	movem.l	(sp)+,d0-d7/a0-a5

.P1	tst.b	(a6)+
	bne.b	.P1
	subq.w	#1,a6
	rts

Asm_CmdAddWatchpoint:
	lea	(watch_table_name-DT,a4),a0
	lea	(watch_table_addr-DT,a4),a1
	lea	(watch_table_type-DT,a4),a2
	move.l	(MainWindowHandle-DT,a4),a3
	bra.b	.C54D8

.C54D0
	lea	(16,a0),a0
	addq.w	#4,a1
	addq.w	#1,a2
.C54D8	tst.b	(a0)
	bne.b	.C54D0
	moveq	#14,d0
.C54DE	move.b	(a6)+,(a0)+
	cmp.b	#',',(a6)
	beq.b	.C54F4
	dbra	d0,.C54DE
	clr.b	(a0)+

.C54EC	tst.b	(a6)
	beq.w	ERROR_IllegalOperand
	cmp.b	#',',(a6)+
	bne.b	.C54EC
	bra.b	.C54F8

.C54F4	clr.b	(a0)
	addq.w	#1,a6
.C54F8	move.l	d3,(a1)
	bset	#0,(wd_Flags+1,a3)	; set rmbtrap
	moveq	#0,d3
.Loop
	moveq	#~32,d0
	and.b	(a6)+,d0
	moveq	#0,d1
	cmp.b	#'A',d0
	beq	.C55D2
	moveq	#1,d1
	cmp.b	#'S',d0
	beq	.C55D2
	moveq	#2,d1
	cmp.b	#'H',d0
	beq	.C55D2
	moveq	#3,d1
	cmp.b	#'D',d0
	beq	.C55D2
	moveq	#4,d1
	cmp.b	#'B',d0
	beq	.C55D2
	moveq	#5,d1
	tst.b	d3
	bne.b	.BadOperand
	cmp.b	#'P',d0
	bne.b	.BadOperand
	cmp.b	#',',(a6)+
	bne.b	.BadOperand
	moveq	#~32,d0
	and.b	(a6)+,d0
	cmp.b	#'D',d0
	bne.b	.BadOperand
	moveq	#~32,d0
	and.b	(a6)+,d0
	cmp.b	#'C',d0
	beq.b	.C559E
	cmp.b	#'R',d0
	bne.b	.BadOperand
	cmp.b	#'.',(a6)+
	bne.b	.BadOperand
	moveq	#~32,d0
	and.b	(a6)+,d0
	cmp.b	#'L',d0
	beq.b	.C55C2
	cmp.b	#'W',d0
	bne.b	.BadOperand
	moveq	#$40,d0
	bra.b	.C55C4

.BadOperand
	subq.l	#1,a6			; in case we passed eol
	bclr	#0,(wd_Flags+1,a3)		; clear rmbtrap
	bra.w	ERROR_IllegalOperand

.C559E	cmp.b	#',',(a6)+
	bne.b	.BadOperand
	moveq	#~32,d0
	and.b	(a6)+,d0
	cmp.b	#'L',d0
	beq.b	.C55BE
	cmp.b	#'W',d0
	bne.b	.BadOperand
	moveq	#$20,d0
	bra.b	.C55C4
.C55BE	moveq	#$10,d0
	bra.b	.C55C4
.C55C2	moveq	#$30,d0

.C55C4	or.b	d0,d3
	cmp.b	#',',(a6)+
	bne.b	.BadOperand
	bra.w	.Loop

.C55D2	cmp	#5,d1
	bne.b	.C55F8
	cmp.b	#',',(a6)+
	bne.b	.BadOperand
	movem.l	d0-d7/a0-a6,-(sp)
	bsr.w	CD6E0
	move.l	(9*4,sp),a1
	move.l	d3,(4,a1)
	movem.l	(sp)+,d0-d7/a0-a6

.C55F8	bclr	#0,(wd_Flags+1,a3)		; clear rmbtrap
	or.b	d1,d3
	bclr	#SB2_A_XN_USED,(SomeBits2-DT,a4)
	beq.b	.C5610
	or.b	#$80,d3
.C5610	move.b	d3,(a2)
	rts

;***************************************************************

C566C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq	C574E
	cmp	#$C04C,d0
	beq	C575A
	cmp	#$C042,d0
	beq	C5742
	br	HandleMacroos

C568C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq	C5726
	cmp	#$C04C,d0
	beq	C5734
	cmp	#$C042,d0
	beq	ERROR_IllegalSize
	br	HandleMacroos

C56AC:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq	C5774
	cmp	#$C04C,d0
	beq	C5780
	cmp	#$C042,d0
	beq	C5768
	br	HandleMacroos

C56CC:	; addi
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C570C
	cmp	#$C04C,d0
	beq.b	C5718
	cmp	#$C042,d0
	beq.b	C5700
	br	HandleMacroos

C56E6:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C570C
	cmp	#$CC00,d0
	beq.b	C5718
	cmp	#$C200,d0
	beq.b	C5700
	br	HandleMacroos

C5700:	move	#$D600,d6	; add.b
	moveq	#0,d5
	jmp	(Asmbl_AddSubCmp).l

C570C:	move	#$D600,d6	; add.w
	moveq	#$40,d5
	jmp	(Asmbl_AddSubCmp).l

C5718:	move	#$D600,d6	; add.l
	move	#$0080,d5
	jmp	(Asmbl_AddSubCmp).l

C5726:	move	#$D0C0,d6	; adda.w
	move	#$8040,d5
	jmp	(Asmbl_AddSubCmp).l

C5734:	move	#$D0C0,d6	; adda.l
	move	#$0080,d5
	jmp	(Asmbl_AddSubCmp).l

C5742:	move	#$5000,d6
	moveq	#0,d5
	jmp	(ASSEM_CMDADDQSUBQ).l

C574E:	move	#$5040,d6
	moveq	#$40,d5
	jmp	(ASSEM_CMDADDQSUBQ).l

C575A:	move	#$5080,d6
	move	#$0080,d5
	jmp	(ASSEM_CMDADDQSUBQ).l

C5768:	move	#$D100,d6
	moveq	#0,d5
	jmp	(CEB92).l

C5774:	move	#$D140,d6
	moveq	#$40,d5
	jmp	(CEB92).l

C5780:	move	#$D180,d6
	move	#$0080,d5
	jmp	(CEB92).l

C578E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C344,d0
	beq	C7230
	cmp	#$4344,d0
	beq.b	C57A4
	br	HandleMacroos

C57A4:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq	ERROR_IllegalSize
	cmp	#$C04C,d0
	beq	ERROR_IllegalSize
	cmp	#$C042,d0
	beq	C7230
	br	HandleMacroos

C57C4:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$4440,d0
	beq.b	C5808
	cmp	#$C400,d0
	beq	C7244
	cmp	#$4449,d0
	beq.b	C57E8
	cmp	#$C449,d0
	beq	C7244
	br	HandleMacroos

C57E8:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq	C7244
	cmp	#$C04C,d0
	beq	C724E
	cmp	#$C042,d0
	beq	C723A
	br	HandleMacroos

C5808:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq	C7244
	cmp	#$CC00,d0
	beq	C724E
	cmp	#$C200,d0
	beq	C723A
	br	HandleMacroos

C5828:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$5240,d0
	beq.b	C5862
	cmp	#$4C40,d0
	beq.b	C5848
	cmp	#$D200,d0
	beq.b	C58AE
	cmp	#$CC00,d0
	beq.b	C5888
	br	HandleMacroos

C5848:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C5888
	cmp	#$CC00,d0
	beq.b	C5894
	cmp	#$C200,d0
	beq.b	C587C
	br	HandleMacroos

C5862:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C58AE
	cmp	#$CC00,d0
	beq.b	C58BA
	cmp	#$C200,d0
	beq.b	C58A2
	br	HandleMacroos

C587C:	move	#$E1C0,d6
	moveq	#0,d5
	jmp	(Asm_ShiftRoll).l

C5888:	move	#$E1C0,d6
	moveq	#$40,d5
	jmp	(Asm_ShiftRoll).l

C5894:	move	#$E1C0,d6
	move	#$0080,d5
	jmp	(Asm_ShiftRoll).l

C58A2:	move	#$E0C0,d6
	moveq	#0,d5
	jmp	(Asm_ShiftRoll).l

C58AE:	move	#$E0C0,d6
	moveq	#$40,d5
	jmp	(Asm_ShiftRoll).l

C58BA:	move	#$E0C0,d6
	move	#$0080,d5
	jmp	(Asm_ShiftRoll).l

AsmB:
	cmp	#'BE',d0
	beq	C5B2A
	cmp	#"BN",d0
	beq	C5B9C
	cmp	#"BS",d0
	beq	C5A6E
	cmp	#'BL',d0
	beq	C5E6A
	cmp	#'BH',d0
	beq	C6070
	cmp	#'BC',d0
	beq	C5C0E
	cmp	#'BR',d0
	beq	asm_BR
	cmp	#"BR"+$8000,d0
	beq	asm_BRA
	cmp	#"BM",d0
	beq	C6240
	cmp	#"BG",d0
	beq	C614E
	cmp	#"BT",d0
	beq	C5D90
	cmp	#"BV",d0
	beq	C6326
	cmp	#"BP",d0
	beq	C62B4
	cmp	#"BA",d0
	beq	C5A42
	cmp	#"BF",d0
	beq.b	Asm_BF
	cmp	#"BK",d0
	beq.b	C5948
	br	HandleMacroos

C5948:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"PT"+$8000,d0
	bne	HandleMacroos
	move	#$4848,d6
	jmp	(asm_BKPT_opp).l

Asm_BF:
	moveq	#0,d6		; d6 upper word is set here for all bfxxx!
	move	(a3)+,d0
	and	d4,d0
	cmp	#"CH",d0
	beq	C5A2C
	cmp	#"CL",d0
	beq	C5A16
	cmp	#"SE",d0
	beq	C5A00
	cmp	#"EX",d0
	beq.b	Asm_BFEX
	cmp	#"FF",d0
	beq.b	C59C4
	cmp	#"IN",d0
	beq.b	C59AE
	cmp	#"TS",d0
	beq.b	C5998
	br	HandleMacroos

C5998:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"T"<<(1*8)+$8000,d0
	bne	HandleMacroos
	move	#$E8C0,d6
	jmp	(Asm_Bitfieldopp_OneOper).l

C59AE:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"S"<<(1*8)+$8000,d0
	bne	HandleMacroos
	move	#$EFC0,d6
	jmp	(Asm_Bitfieldopp_DstOper).l

C59C4:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"O"<<(1*8)+$8000,d0
	bne	HandleMacroos
	move	#$EDC0,d6
	jmp	(Asm_Bitfieldopp_SrcOper).l

Asm_BFEX:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"TS"+$8000,d0
	beq.b	C59F6
	cmp	#"TU"+$8000,d0
	bne	HandleMacroos
	move	#$E9C0,d6
	jmp	(Asm_Bitfieldopp_SrcOper).l

C59F6:	move	#$EBC0,d6
	jmp	(Asm_Bitfieldopp_SrcOper).l

C5A00:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"T"<<(1*8)+$8000,d0
	bne	HandleMacroos
	move	#$EEC0,d6
	jmp	(Asm_Bitfieldopp_OneOper).l

C5A16:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D200,d0
	bne	HandleMacroos
	move	#$ECC0,d6
	jmp	(Asm_Bitfieldopp_OneOper).l

C5A2C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C700,d0
	bne	HandleMacroos
	move	#$EAC0,d6
	jmp	(Asm_Bitfieldopp_OneOper).l

C5A42:	; BA
	move	(a3)+,d0
	and	d4,d0
	cmp	#"SE",d0
	beq.b	C5A50
	br	HandleMacroos

C5A50:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"RE",d0
	beq.b	C5A5E
	br	HandleMacroos

C5A5E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C700,d0
	beq	Asm_BASEREG
	br	HandleMacroos

C5A6E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"R@",d0
	beq.b	C5A90
	cmp	#"R"<<(1*8)+$8000,d0
	beq.b	C5AF4
	cmp	#"ET"+$8000,d0
	beq	C5B1C
	cmp	#"ET",d0
	beq.b	C5AB0
	br	HandleMacroos

C5A90:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C5AD8
	cmp	#$D300,d0
	beq.b	C5ACC
	cmp	#$CC00,d0
	beq.b	C5AE6
	cmp	#$C200,d0
	beq.b	C5ACC
	br	HandleMacroos

C5AB0:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq	ERROR_IllegalSize
	cmp	#$C04C,d0
	beq.b	C5B0E
	cmp	#$C042,d0
	beq.b	C5B02
	br	HandleMacroos

C5ACC:	move	#$6100,d6
	moveq	#0,d5
	jmp	(asmbl_BraB).l

C5AD8:	move	#$6100,d6
	move	#$0080,d5
	jmp	(asmbl_BraW).l

C5AE6:	move	#$61FF,d6
	move	#$0080,d5
	jmp	(asmbl_BraL).l

C5AF4:	move	#$6100,d6
	move	#$0080,d5
	jmp	(asmbl_BraNorm).l

C5B02:	move	#$08C0,d6
	moveq	#0,d5
	jmp	(ASSEM_CMDBIT).l

C5B0E:	move	#$08C0,d6
	move	#$0080,d5
	jmp	(ASSEM_CMDBIT).l

C5B1C:	move	#$08C0,d6
	move	#$8040,d5
	jmp	(ASSEM_CMDBIT).l

C5B2A:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$5140,d0
	beq.b	C5B3E
	cmp	#$D100,d0
	beq.b	C5B8E
	br	HandleMacroos

C5B3E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C5B6A
	cmp	#$D300,d0
	beq.b	C5B5E
	cmp	#$CC00,d0
	beq.b	C5B78
	cmp	#$C200,d0
	beq.b	C5B5E
	br	HandleMacroos

C5B5E:	move	#$6700,d6
	moveq	#0,d5
	jmp	(asmbl_BraB).l

C5B6A:	move	#$6700,d6
	move	#$0080,d5
	jmp	(asmbl_BraW).l

C5B78:	cmp	#2,(CPU_type-DT,a4)
	blt.b	C5B6A
	move	#$67FF,d6
	move	#$0080,d5
	jmp	(asmbl_BraL).l

C5B8E:	move	#$6700,d6
	move	#$0080,d5
	jmp	(asmbl_BraNorm).l

C5B9C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$4540,d0
	beq.b	C5BB0
	cmp	#$C500,d0
	beq.b	C5C00
	br	HandleMacroos

C5BB0:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C5BDC
	cmp	#$D300,d0
	beq.b	C5BD0
	cmp	#$CC00,d0
	beq.b	C5BEA
	cmp	#$C200,d0
	beq.b	C5BD0
	br	HandleMacroos

C5BD0:	move	#$6600,d6
	moveq	#0,d5
	jmp	(asmbl_BraB).l

C5BDC:	move	#$6600,d6
	move	#$0080,d5
	jmp	(asmbl_BraW).l

C5BEA:	cmp	#2,(CPU_type-DT,a4)
	blt.b	C5BDC
	move	#$66FF,d6
	move	#$0080,d5
	jmp	(asmbl_BraL).l

C5C00:	move	#$6600,d6
	move	#$0080,d5
	jmp	(asmbl_BraNorm).l

C5C0E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CC52,d0
	beq.b	C5C5A
	cmp	#$C847,d0
	beq.b	C5C68
	cmp	#$D300,d0
	beq.b	C5C4C
	cmp	#$C300,d0
	beq.b	C5C76
	cmp	#$5340,d0
	beq.b	C5C84
	cmp	#$4340,d0
	beq	C5CD4
	cmp	#$4C52,d0
	beq	C5D24
	cmp	#$4847,d0
	beq	C5D5A
	br	HandleMacroos

C5C4C:	move	#$6500,d6
	move	#$0080,d5
	jmp	(asmbl_BraNorm).l

C5C5A:	move	#$0880,d6
	move	#$8040,d5
	jmp	(ASSEM_CMDBIT).l

C5C68:	move	#$0840,d6
	move	#$8040,d5
	jmp	(ASSEM_CMDBIT).l

C5C76:	move	#$6400,d6
	move	#$0080,d5
	jmp	(asmbl_BraNorm).l

C5C84:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C5CB0
	cmp	#$D300,d0
	beq.b	C5CA4
	cmp	#$CC00,d0
	beq.b	C5CBE
	cmp	#$C200,d0
	beq.b	C5CA4
	br	HandleMacroos

C5CA4:	move	#$6500,d6
	moveq	#0,d5
	jmp	(asmbl_BraB).l

C5CB0:	move	#$6500,d6
	move	#$0080,d5
	jmp	(asmbl_BraW).l

C5CBE:	cmp	#2,(CPU_type-DT,a4)
	blt.b	C5CB0
	move	#$65FF,d6
	move	#$0080,d5
	jmp	(asmbl_BraL).l

C5CD4:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C5D00
	cmp	#$D300,d0
	beq.b	C5CF4
	cmp	#$CC00,d0
	beq.b	C5D0E
	cmp	#$C200,d0
	beq.b	C5CF4
	br	HandleMacroos

C5CF4:	move	#$6400,d6
	moveq	#0,d5
	jmp	(asmbl_BraB).l

C5D00:	move	#$6400,d6
	move	#$0080,d5
	jmp	(asmbl_BraW).l

C5D0E:	cmp	#2,(CPU_type-DT,a4)
	blt.b	C5D00
	move	#$64FF,d6
	move	#$0080,d5
	jmp	(asmbl_BraL).l

C5D24:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq	ERROR_IllegalSize
	cmp	#$C04C,d0
	beq.b	C5D4C
	cmp	#$C042,d0
	beq.b	C5D40
	br	HandleMacroos

C5D40:	move	#$0880,d6
	moveq	#0,d5
	jmp	(ASSEM_CMDBIT).l

C5D4C:	move	#$0880,d6
	move	#$0080,d5
	jmp	(ASSEM_CMDBIT).l

C5D5A:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq	ERROR_IllegalSize
	cmp	#$C04C,d0
	beq.b	C5D82
	cmp	#$C042,d0
	beq.b	C5D76
	br	HandleMacroos

C5D76:	move	#$0840,d6
	moveq	#0,d5
	jmp	(ASSEM_CMDBIT).l

C5D82:	move	#$0840,d6
	move	#$0080,d5
	jmp	(ASSEM_CMDBIT).l

C5D90:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D354,d0
	beq.b	C5DDA
	cmp	#$5354,d0
	beq.b	C5DA4
	br	HandleMacroos

C5DA4:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq	ERROR_IllegalSize
	cmp	#$C04C,d0
	beq.b	C5DCC
	cmp	#$C042,d0
	beq.b	C5DC0
	br	HandleMacroos

C5DC0:	move	#$8800,d6
	moveq	#0,d5
	jmp	(ASSEM_CMDBIT).l

C5DCC:	move	#$0800,d6
	move	#$0080,d5
	jmp	(ASSEM_CMDBIT).l

C5DDA:	move	#$8800,d6
	move	#$8040,d5
	jmp	(ASSEM_CMDBIT).l

asm_BR:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C100,d0	;BRA
	beq.b	asm_BRA
	cmp	#$4140,d0	;BRA.
	beq.b	.asm_BRAcont
	cmp	#$C057,d0	;br.w
	beq.b	.asm_BRAw
	cmp	#$C053,d0	;br.s
	beq.b	.asm_BRAb
	cmp	#$C042,d0	;br.b
	beq.b	.asm_BRAb
	cmp	#$C04C,d0	;BR.L
	beq.b	.asm_BRAl
	br	HandleMacroos

.asm_BRAcont:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	.asm_BRAw
	cmp	#$D300,d0
	beq.b	.asm_BRAb
	cmp	#$C200,d0
	beq.b	.asm_BRAb
	cmp	#$CC00,d0
	beq.b	.asm_BRAl
	br	HandleMacroos

.asm_BRAb:
	move	#$6000,d6
	moveq	#0,d5
	jmp	(asmbl_BraB).l


.asm_BRAw:
	move	#$6000,d6
	move	#$0080,d5
	jmp	(asmbl_BraW).l

.asm_BRAl:
	move	#$60FF,d6
	move	#$0080,d5
	jmp	(asmbl_BraL).l

asm_BRA:
	move	#$6000,d6
	move	#$0080,d5
	jmp	(asmbl_BraNorm).l

C5E6A:	; BL
	move	(a3)+,d0
	and	d4,d0
	cmp	#$5440,d0
	beq.b	C5EF0
	cmp	#$4F40,d0
	beq	C5F90
	cmp	#$5340,d0
	beq	C5F40
	cmp	#$4540,d0
	beq	C5FE0
	cmp	#$4B40,d0
	beq	C6030
	cmp	#$D400,d0
	beq.b	C5EB8
	cmp	#$D300,d0
	beq.b	C5EE2
	cmp	#$CF00,d0
	beq.b	C5ED4
	cmp	#$CB00,d0
	beq	CDB76
	cmp	#$C500,d0
	beq.b	C5EC6
	br	HandleMacroos

C5EB8:	move	#$6D00,d6
	move	#$0080,d5
	jmp	(asmbl_BraNorm).l

C5EC6:	move	#$6F00,d6
	move	#$0080,d5
	jmp	(asmbl_BraNorm).l

C5ED4:	move	#$6500,d6
	move	#$0080,d5
	jmp	(asmbl_BraNorm).l

C5EE2:	move	#$6300,d6
	move	#$0080,d5
	jmp	(asmbl_BraNorm).l

C5EF0:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C5F1C
	cmp	#$D300,d0
	beq.b	C5F10
	cmp	#$CC00,d0
	beq.b	C5F2A
	cmp	#$C200,d0
	beq.b	C5F10
	br	HandleMacroos

C5F10:	move	#$6D00,d6
	moveq	#0,d5
	jmp	(asmbl_BraB).l

C5F1C:	move	#$6D00,d6
	move	#$0080,d5
	jmp	(asmbl_BraW).l

C5F2A:	cmp	#2,(CPU_type-DT,a4)
	blt.b	C5F1C
	move	#$6DFF,d6
	move	#$0080,d5
	jmp	(asmbl_BraL).l

C5F40:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C5F6C
	cmp	#$D300,d0
	beq.b	C5F60
	cmp	#$CC00,d0
	beq.b	C5F7A
	cmp	#$C200,d0
	beq.b	C5F60
	br	HandleMacroos

C5F60:	move	#$6300,d6
	moveq	#0,d5
	jmp	(asmbl_BraB).l

C5F6C:	move	#$6300,d6
	move	#$0080,d5
	jmp	(asmbl_BraW).l

C5F7A:	cmp	#2,(CPU_type-DT,a4)
	blt.b	C5F6C
	move	#$63FF,d6
	move	#$0080,d5
	jmp	(asmbl_BraL).l

C5F90:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C5FBC
	cmp	#$D300,d0
	beq.b	C5FB0
	cmp	#$CC00,d0
	beq.b	C5FCA
	cmp	#$C200,d0
	beq.b	C5FB0
	br	HandleMacroos

C5FB0:	move	#$6500,d6
	moveq	#0,d5
	jmp	(asmbl_BraB).l

C5FBC:	move	#$6500,d6
	move	#$0080,d5
	jmp	(asmbl_BraW).l

C5FCA:	cmp	#2,(CPU_type-DT,a4)
	blt.b	C5FBC
	move	#$65FF,d6
	move	#$0080,d5
	jmp	(asmbl_BraL).l

C5FE0:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C600C
	cmp	#$D300,d0
	beq.b	C6000
	cmp	#$CC00,d0
	beq.b	C601A
	cmp	#$C200,d0
	beq.b	C6000
	br	HandleMacroos

C6000:	move	#$6F00,d6
	moveq	#0,d5
	jmp	(asmbl_BraB).l

C600C:	move	#$6F00,d6
	move	#$0080,d5
	jmp	(asmbl_BraW).l

C601A:
	cmp	#2,(CPU_type-DT,a4)
	blt.b	C600C
	move	#$6FFF,d6
	move	#$0080,d5
	jmp	(asmbl_BraL).l

C6030:	; BLK.
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq	CDB76
	cmp	#$CC00,d0
	beq	CDF24
	cmp	#$C200,d0
	beq	CDB8E
	cmp	#$D300,d0
	beq	CDC24
	cmp	#$C400,d0
	beq	CDCB4
	cmp	#$D800,d0
	beq	CDD44
	cmp	#$D000,d0
	beq	CDDDA
	br	HandleMacroos

C6070:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$5340,d0
	beq.b	C60B2
	cmp	#$4940,d0
	beq.b	C6092
	cmp	#$D300,d0
	beq	C6140
	cmp	#$C900,d0
	beq.b	C6102
	br	HandleMacroos

C6092:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C60DE
	cmp	#$D300,d0
	beq.b	C60D2
	cmp	#$CC00,d0
	beq.b	C60EC
	cmp	#$C200,d0
	beq.b	C60D2
	br	HandleMacroos

C60B2:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C611C
	cmp	#$D300,d0
	beq.b	C6110
	cmp	#$CC00,d0
	beq.b	C612A
	cmp	#$C200,d0
	beq.b	C6110
	br	HandleMacroos

C60D2:	move	#$6200,d6
	moveq	#0,d5
	jmp	(asmbl_BraB).l

C60DE:	move	#$6200,d6
	move	#$0080,d5
	jmp	(asmbl_BraW).l

C60EC:	cmp	#2,(CPU_type-DT,a4)
	blt.b	C60DE
	move	#$62FF,d6
	move	#$0080,d5
	jmp	(asmbl_BraL).l

C6102:	move	#$6200,d6
	move	#$0080,d5
	jmp	(asmbl_BraNorm).l

C6110:	move	#$6400,d6
	moveq	#0,d5
	jmp	(asmbl_BraB).l

C611C:	move	#$6400,d6
	move	#$0080,d5
	jmp	(asmbl_BraW).l

C612A:	cmp	#2,(CPU_type-DT,a4)
	blt.b	C611C
	move	#$64FF,d6
	move	#$0080,d5
	jmp	(asmbl_BraL).l

C6140:	move	#$6400,d6
	move	#$0080,d5
	jmp	(asmbl_BraNorm).l

C614E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$5440,d0
	beq.b	C6198
	cmp	#$4540,d0
	beq.b	C6178
	cmp	#$D400,d0
	beq	C6232
	cmp	#$C500,d0
	beq	C61F4
	cmp	#$CE44,d0
	beq.b	C61B8
	br	HandleMacroos

C6178:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C61D0
	cmp	#$D300,d0
	beq.b	C61C4
	cmp	#$CC00,d0
	beq.b	C61DE
	cmp	#$C200,d0
	beq.b	C61C4
	br	HandleMacroos

C6198:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C620E
	cmp	#$D300,d0
	beq.b	C6202
	cmp	#$CC00,d0
	beq.b	C621C
	cmp	#$C200,d0
	beq.b	C6202
	br	HandleMacroos

C61B8:	move	#$4AFA,d6
	moveq	#0,d5
	bra	Asm_InsertinstrA5

C61C4:	move	#$6C00,d6
	moveq	#0,d5
	jmp	(asmbl_BraB).l

C61D0:	move	#$6C00,d6
	move	#$0080,d5
	jmp	(asmbl_BraW).l

C61DE:
	cmp	#2,(CPU_type-DT,a4)
	blt.b	C61D0
	move	#$6CFF,d6
	move	#$0080,d5
	jmp	(asmbl_BraL).l

C61F4:	move	#$6C00,d6
	move	#$0080,d5
	jmp	(asmbl_BraNorm).l

C6202:	move	#$6E00,d6
	moveq	#0,d5
	jmp	(asmbl_BraB).l

C620E:	move	#$6E00,d6
	move	#$0080,d5
	jmp	(asmbl_BraW).l

C621C:	cmp	#2,(CPU_type-DT,a4)
	blt.b	C620E
	move	#$6EFF,d6
	move	#$0080,d5
	jmp	(asmbl_BraL).l

C6232:	move	#$6E00,d6
	move	#$0080,d5
	jmp	(asmbl_BraNorm).l

C6240:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$4940,d0
	beq.b	C6254
	cmp	#$C900,d0
	beq.b	C62A6
	br	HandleMacroos

C6254:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C6280
	cmp	#$D300,d0
	beq.b	C6274
	cmp	#$CC00,d0
	beq.b	C628E
	cmp	#$C200,d0
	beq.b	C6274
	br	HandleMacroos

C6274:	move	#$6B00,d6
	moveq	#0,d5
	jmp	(asmbl_BraB).l

C6280:	move	#$6B00,d6
	move	#$0080,d5
	jmp	(asmbl_BraW).l

C628E:	cmp	#2,(CPU_type-DT,a4)
	blt.w	C60DE
	move	#$6BFF,d6
	move	#$0080,d5
	jmp	(asmbl_BraL).l

C62A6:	move	#$6B00,d6
	move	#$0080,d5
	jmp	(asmbl_BraNorm).l

C62B4:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$4C40,d0
	beq.b	C62C8
	cmp	#$CC00,d0
	beq.b	C6318
	br	HandleMacroos

C62C8:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C62F4
	cmp	#$D300,d0
	beq.b	C62E8
	cmp	#$CC00,d0
	beq.b	C6302
	cmp	#$C200,d0
	beq.b	C62E8
	br	HandleMacroos

C62E8:
	move	#$6A00,d6
	moveq	#0,d5
	jmp	(asmbl_BraB).l

C62F4:
	move	#$6A00,d6
	move	#$0080,d5
	jmp	(asmbl_BraW).l

C6302:
	cmp	#2,(CPU_type-DT,a4)
	blt.b	C62F4
	move	#$6AFF,d6
	move	#$0080,d5
	jmp	(asmbl_BraL).l

C6318:
	move	#$6A00,d6
	move	#$0080,d5
	jmp	(asmbl_BraNorm).l

C6326:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$5340,d0
	beq.b	C6348
	cmp	#$4340,d0
	beq.b	C6368
	cmp	#$D300,d0
	beq.b	C63B8
	cmp	#$C300,d0
	beq	C63F6
	br	HandleMacroos

C6348:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C6394
	cmp	#$D300,d0
	beq.b	C6388
	cmp	#$CC00,d0
	beq.b	C63A2
	cmp	#$C200,d0
	beq.b	C6388
	br	HandleMacroos

C6368:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C63E8
	cmp	#$D300,d0
	beq.b	C63C6
	cmp	#$CC00,d0
	beq.b	C63D2
	cmp	#$C200,d0
	beq.b	C63C6
	br	HandleMacroos

C6388:
	move	#$6900,d6
	moveq	#0,d5
	jmp	(asmbl_BraB).l

C6394:
	move	#$6900,d6
	move	#$0080,d5
	jmp	(asmbl_BraW).l

C63A2:
	cmp	#2,(CPU_type-DT,a4)
	blt.b	C6394
	move	#$69FF,d6
	move	#$0080,d5
	jmp	(asmbl_BraL).l

C63B8:
	move	#$6900,d6
	move	#$0080,d5
	jmp	(asmbl_BraNorm).l

C63C6:
	move	#$6800,d6
	moveq	#0,d5
	jmp	(asmbl_BraB).l

C63D2:
	cmp	#2,(CPU_type-DT,a4)
	blt.b	C6394
	move	#$68FF,d6
	move	#$0080,d5
	jmp	(asmbl_BraL).l

C63E8:
	move	#$6800,d6
	move	#$0080,d5
	jmp	(asmbl_BraW).l

C63F6:
	move	#$6800,d6
	move	#$0080,d5
	jmp	(asmbl_BraNorm).l

AsmC:
	cmp	#'CM',d0
	beq	Asm_CM
	cmp	#'CL',d0
	beq	C66F0
	cmp	#'CN',d0
	beq	Asm_CN
	cmp	#'CH',d0
	beq	Asm_CH
	cmp	#'CA',d0
	beq	C64C2
	cmp	#'CI',d0
	beq.b	C647E
	cmp	#'CP',d0
	beq.b	Asm_CP
	br	HandleMacroos

Asm_CP:
	move	(a3)+,d0
	and	d4,d0
;	cmp	#"U=",d0	;CPU=
;	beq.w	m68_ChangeCpuType
	cmp	#"US",d0	;CPUS
	bne	HandleMacroos
	move	(a3)+,d0
	and	d4,d0
	cmp	#"HA"+$8000,d0	;CPUSHA
	beq.b	C6474
	cmp	#"HL"+$8000,d0	;CPUSHL
	beq.b	C646A
	cmp	#"HP"+$8000,d0	;CPUSHP
	bne	HandleMacroos
	move	#$F430,d6
	jmp	(C100D8).l

C646A:
	move	#$F428,d6
	jmp	(C100D8).l

C6474:
	move	#$F438,d6
	jmp	(C100B8).l

C647E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"NV",d0
	bne	HandleMacroos
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CC00,d0
	beq.b	C64B8
	cmp	#$D000,d0
	beq.b	C64AE
	cmp	#$C100,d0
	beq.b	C64A4
	br	HandleMacroos

C64A4:
	move	#$F418,d6
	jmp	(C100B8).l

C64AE:
	move	#$F410,d6
	jmp	(C100D8).l

C64B8:
	move	#$F408,d6
	jmp	(C100D8).l

C64C2:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"S@",d0
	beq.b	C6532
	cmp	#"S"<<(1*8)+$8000,d0
	beq	C6558
	cmp	#"S"<<(1*8)+$12,d0
	beq.b	C6500
	cmp	#"S"<<(1*8)+$8012,d0
	beq.b	C651E
	cmp	#"LL",d0
	beq.b	C64EA
	br	HandleMacroos

C64EA:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CD00,d0
	bne	HandleMacroos
	move	#$06C0,d6
	jmp	(Asm_Callm).l

C6500:
	moveq	#0,d6
	move	(a3)+,d0
	and	d4,d0
	cmp	#"@W"+$8000,d0
	beq.b	C651E
	cmp	#"@L"+$8000,d0
	beq.b	C6528
	cmp	#"@B"+$8000,d0
	beq	ERROR_IllegalSize
	br	HandleMacroos

C651E:
	move	#$0CFC,d6
	jmp	(C10192).l

C6528:
	move	#$0EFC,d6
	jmp	(C10192).l

C6532:
	moveq	#0,d6
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C6558
	cmp	#$CC00,d0
	beq.b	C6562
	cmp	#$C200,d0
	beq.b	C654E
	br	HandleMacroos

C654E:
	move	#$0AC0,d6
	jmp	(C1028E).l

C6558:
	move	#$0CC0,d6
	jmp	(C1028E).l

C6562:
	move	#$0EC0,d6
	jmp	(C1028E).l

Asm_CN:
	move	(a3)+,d0
	and	d4,d0
	cmp	#'OP'|$8000,d0
	bne.w	HandleMacroos

Asm_CNOP:	; also Asm_ALIGN
	bsr	Parse_GetDefinedValue		; offset
	move.l	d3,-(sp)
	bmi.w	ERROR_WorkspaceMemoryFull
	bsr	Parse_GetKomma
	bsr	Parse_GetDefinedValue	; alignment (2^N only)
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),d5
	subq.l	#1,d3
	neg.l	d5
	and.l	d3,d5
	add.l	(sp)+,d5		; pad+offset
	tst.b	(PR_DsClear)		; WX support (clear skipped bytes)
	beq.b	.NoClear
	moveq	#0,d3
	moveq	#0,d2
	bsr.w	CDBAC
	bra.w	SET_LAST_LABEL_TO_ORG_PTR
.NoClear
	add.l	d5,(INSTRUCTION_ORG_PTR-DT,a4)
	bra.w	SET_LAST_LABEL_TO_ORG_PTR

Asm_CM:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$5040,d0	;cmp.+
	beq	C663A
	cmp	#$504D,d0	;cmpm+
	beq	C668A
	cmp	#$D000,d0	;cmp
	beq	Asm_Cmp
	cmp	#$5049,d0	;cmpi+
	beq	C6670
	cmp	#$5041,d0	;cmpa+
	beq.b	C6654
	cmp	#$D04D,d0	;cmpm
	beq	Asm_Cmpm
	cmp	#$D049,d0	;cmpi
	beq	Asm_Cmp
	cmp	#$D041,d0	;cmpa
	beq	Asm_Cmp
	cmp	#$D012,d0	;CMP2
	beq	cmp2_stuff_w
	cmp	#$5012,d0	;CMP2+
	beq.b	cmp2_stuff
	cmp	#$4558,d0	;CMEX
	beq.b	C660A
	br	HandleMacroos

C660A:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"IT"+$8000,d0
	beq	Asm_CMEXIT
	br	HandleMacroos

cmp2_stuff:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0	;cmp2.w
	beq	cmp2_stuff_w
	cmp	#$C04C,d0	;cmp2.l
	beq	cmp2_stuff_l
	cmp	#$C042,d0	;cmp2.b
	beq	cmp2_stuff_b
	br	HandleMacroos

C663A:	; cmp.
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	Asm_Cmp
	cmp	#$CC00,d0
	beq.b	C66BC
	cmp	#$C200,d0
	beq.b	C66A4
	br	HandleMacroos

C6654:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	Asm_Cmp
	cmp	#$C04C,d0
	beq.b	C66BC
	cmp	#$C042,d0
	beq	ERROR_IllegalSize
	br	HandleMacroos

C6670:	; cmpi
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	Asm_Cmp
	cmp	#$C04C,d0
	beq.b	C66BC
	cmp	#$C042,d0
	beq.b	C66A4
	br	HandleMacroos

C668A:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	Asm_Cmpm
	cmp	#$C04C,d0
	beq.b	C66E2
	cmp	#$C042,d0
	beq.b	C66CA
	br	HandleMacroos

C66A4:	; cmp.b
	move	#$BC01,d6
	moveq	#0,d5
	bra	Asmbl_AddSubCmp

Asm_Cmp: ; cmp.w
	move	#$BC01,d6
	moveq	#$40,d5
	bra	Asmbl_AddSubCmp

C66BC:	; cmp.l
	move	#$BC01,d6
	move	#$0080,d5
	bra	Asmbl_AddSubCmp

C66CA:
	move	#$B108,d6
	moveq	#0,d5
	bra	Asmbl_Cmpm

Asm_Cmpm:
	move	#$B148,d6
	moveq	#$40,d5
	bra	Asmbl_Cmpm

C66E2:
	move	#$B188,d6
	move	#$0080,d5
	bra	Asmbl_Cmpm

C66F0:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$5240,d0
	beq.b	C6704
	cmp	#$D200,d0
	beq.b	C672A
	br	HandleMacroos

C6704:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C672A
	cmp	#$CC00,d0
	beq.b	C6736
	cmp	#$C200,d0
	beq.b	C671E
	br	HandleMacroos

C671E:
	move	#$4200,d6
	moveq	#0,d5
	jmp	(ASSEM_CMDCLRNOTTST).l

C672A:
	move	#$4240,d6
	moveq	#$40,d5
	jmp	(ASSEM_CMDCLRNOTTST).l

C6736:
	move	#$4280,d6
	move	#$0080,d5
	jmp	(ASSEM_CMDCLRNOTTST).l

Asm_CH:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$4B40,d0
	beq.b	C6768
	cmp	#$CB00,d0
	beq	C727E
	cmp	#$CB12,d0
	beq	C7298
	cmp	#$4B12,d0
	beq.b	Asm_CHK2
	br	HandleMacroos

C6768:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq	C727E
	cmp	#$CC00,d0
	beq	C728A
	cmp	#$C200,d0
	beq	ERROR_IllegalSize
	br	HandleMacroos

Asm_CHK2:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq	C7298
	cmp	#$C04C,d0
	beq	C72A6
	cmp	#$C042,d0
	beq	C72B4
	br	HandleMacroos

AsmD:
	cmp	#'DS',d0
	beq	C6896
	cmp	#'DR',d0
	beq.b	C67E8
	cmp	#'DC',d0
	beq.b	C6808
	cmp	#'DB',d0
	beq	Asm_DBCC
	cmp	#'DI',d0
	beq	Asm_DI
	cmp	#"DS"+$8000,d0
	beq	CE190
	cmp	#"DR"+$8000,d0
	beq	ASSEM_CMDDR_W
	cmp	#"DC"+$8000,d0
	beq	CDAE6
	br	HandleMacroos

C67E8:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"@W"+$8000,d0
	beq	ASSEM_CMDDR_W
	cmp	#"@L"+$8000,d0
	beq	CD9A0
	cmp	#"@B"+$8000,d0
	beq	CD9D8
	br	HandleMacroos

C6808:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"@W"+$8000,d0
	beq	CDAE6
	cmp	#"@L"+$8000,d0
	beq	CDB1C
	cmp	#"@B"+$8000,d0
	beq	CDB52
	cmp	#"@S"+$8000,d0
	beq	CD9F6
	cmp	#"@D"+$8000,d0
	beq	CDA32
	cmp	#"@X"+$8000,d0
	beq	CDA6E
	cmp	#"@P"+$8000,d0
	beq	CDAAA
	cmp	#"B@",d0
	beq.b	C6856
	cmp	#"B"<<(1*8)+$8000,d0
	beq	CDB76
	br	HandleMacroos

C6856:	; DCB.
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq	CDB76
	cmp	#$CC00,d0
	beq	CDF24
	cmp	#$C200,d0
	beq	CDB8E
	cmp	#$D300,d0
	beq	CDC24
	cmp	#$C400,d0
	beq	CDCB4
	cmp	#$D800,d0
	beq	CDD44
	cmp	#$D000,d0
	beq	CDDDA
	br	HandleMacroos

C6896:	; DS
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq	CE190
	cmp	#$C04C,d0
	beq	CE1B6
	cmp	#$C042,d0
	beq	CE16A
	cmp	#$C053,d0
	beq	CE1B6
	cmp	#$C044,d0	; .D
	beq	CE1DC
	cmp	#$C058,d0	; .X
	beq	CE202
	cmp	#$C050,d0	; .P
	beq	CE202
	br	HandleMacroos

Asm_DI:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D655,d0
	beq	Asm_DIVUW
	cmp	#$D653,d0
	beq	Asm_DIVSW
	cmp	#$5655,d0	;divu
	beq.b	Asm_DIVU
	cmp	#$5653,d0	;divs
	beq.b	C691C
	br	HandleMacroos

Asm_DIVU:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq	Asm_DIVUW
	cmp	#$C04C,d0
	beq.b	C697E
	cmp	#$4C40,d0
	beq.b	C6964
	cmp	#$CC00,d0
	beq.b	C6970
	br	HandleMacroos

C691C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0	;.w
	beq.b	Asm_DIVSW
	cmp	#$C04C,d0	;.l
	beq.b	Asm_DIVSL
	cmp	#$4C40,d0	;DIVSL.L
	beq.b	C693C
	cmp	#$CC00,d0	;DIVSL
	beq.b	C6948
	br	HandleMacroos

C693C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CC00,d0
	bne	ERROR_IllegalSize
C6948:
	move	#$0088,d5
	move	#$4C40,d6
	jmp	(Asm_ImmOpperantLong).l

Asm_DIVSL:
	move	#$4C40,d6
	move	#$008C,d5
	jmp	(Asm_ImmOpperantLong).l

C6964:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CC00,d0
	bne	ERROR_IllegalSize
C6970:
	move	#$0080,d5
	move	#$4C40,d6
	jmp	(Asm_ImmOpperantLong).l

C697E:
	move	#$4C40,d6
	move	#$0084,d5
	jmp	(Asm_ImmOpperantLong).l

Asm_DIVUW:
	move	#$80C0,d6
	moveq	#$40,d5
	jmp	(Asm_ImmOpperantWord).l

Asm_DIVSW:
	move	#$81C0,d6
	moveq	#$40,d5
	jmp	(Asm_ImmOpperantWord).l

Asm_DBCC:
	move	(a3)+,d0
	or.w	#$8000,d0
	and	d4,d0

	cmp	#$C600,d0
	beq	C6A52		;dbf
	cmp	#$C640,d0
	beq	C6A52		;dbf.
	cmp	#$D241,d0	
	beq	C6A52		;dbra
	cmp	#$D200,d0	
	beq	C6A52		;dbr
	cmp	#$D240,d0	
	beq	C6A52		;dbr.
	cmp	#$C551,d0
	beq	C6AB4
	cmp	#$CE45,d0
	beq	C6A98
	cmp	#$CD49,d0
	beq	C6AC2
	cmp	#$CC4F,d0
	beq	C6AA6
	cmp	#$D04C,d0
	beq	C6AEC
	cmp	#$CC54,d0
	beq	C6B16
	cmp	#$C849,d0
	beq.b	C6A7C
	cmp	#$CC45,d0
	beq	C6AFA
	cmp	#$C353,d0
	beq.b	C6A6E
	cmp	#$C343,d0
	beq.b	C6A44
	cmp	#$D400,d0	;dbt
	beq.b	C6A60
	cmp	#$D440,d0	;dbt.
	beq.b	C6A60
	cmp	#$C754,d0
	beq	C6ADE
	cmp	#$C745,d0
	beq	C6AD0
	cmp	#$C853,d0
	beq.b	C6A8A
	cmp	#$D653,d0
	beq	C6B32
	cmp	#$D643,d0
	beq	C6B24
	cmp	#$CC53,d0
	beq	C6B08
	br	HandleMacroos

C6A44:	move	#$54C8,d6
	jmp	(asmbl_dbcc).l

C6A52:	move	#$51C8,d6
	jmp	(asmbl_dbcc).l

C6A60:	move	#$50C8,d6
	jmp	(asmbl_dbcc).l

C6A6E:	move	#$55C8,d6
	jmp	(asmbl_dbcc).l

C6A7C:	move	#$52C8,d6
	jmp	(asmbl_dbcc).l

C6A8A:	move	#$54C8,d6
	jmp	(asmbl_dbcc).l

C6A98:	move	#$56C8,d6
	jmp	(asmbl_dbcc).l

C6AA6:	move	#$55C8,d6
	jmp	(asmbl_dbcc).l

C6AB4:	move	#$57C8,d6
	jmp	(asmbl_dbcc).l

C6AC2:	move	#$5BC8,d6
	jmp	(asmbl_dbcc).l

C6AD0:	move	#$5CC8,d6
	jmp	(asmbl_dbcc).l

C6ADE:	move	#$5EC8,d6
	jmp	(asmbl_dbcc).l

C6AEC:	move	#$5AC8,d6
	jmp	(asmbl_dbcc).l

C6AFA:	move	#$5FC8,d6
	jmp	(asmbl_dbcc).l

C6B08:	move	#$53C8,d6
	jmp	(asmbl_dbcc).l

C6B16:	move	#$5DC8,d6
	jmp	(asmbl_dbcc).l

C6B24:	move	#$58C8,d6
	jmp	(asmbl_dbcc).l

C6B32:	move	#$59C8,d6
	jmp	(asmbl_dbcc).l

AsmE:
	cmp	#'EN',d0
	beq.b	C6B72
	cmp	#"EX",d0
	beq	C6C0E
	cmp	#"EQ",d0
	beq	C6D56
	cmp	#"EV",d0
	beq	C6D46
	cmp	#"EO",d0
	beq	C6CD2
	cmp	#"EL",d0
	beq	C6BFE
	br	HandleMacroos

C6B72:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"DR"+$8000,d0
	beq	Asm_ENDR
	cmp	#"DM"+$8000,d0
	beq	Asm_ENDM
	cmp	#"DC"+$8000,d0
	beq	ASSEM_CMDENDC
	cmp	#"DC",d0
	beq.b	C6BCC
	cmp	#"D"<<(1*8)+$8000,d0
	beq	ASSEM_CMDEND
	cmp	#"DB"+$8000,d0
	beq	Asm_ENDB
	cmp	#"DI",d0
	beq.b	C6BEE
	cmp	#"TR",d0
	beq.b	C6BDE
	cmp	#"DO",d0
	beq.b	C6BBA
	br	HandleMacroos

C6BBA:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"FF"+$8000,d0
	bne	HandleMacroos
	bclr	#AF_OFFSET,d7
	rts

C6BCC:
	move.b	(a3),d0
	and.b	#$7F,d0
	cmp.b	#$21,d0
	beq	ASSEM_CMDENDC
	br	HandleMacroos

C6BDE:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D900,d0
	beq	CD778
	br	HandleMacroos

C6BEE:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C600,d0
	beq	ASSEM_CMDENDC
	br	HandleMacroos

C6BFE:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D345,d0
	beq	ASSEM_CMDELSE
	br	HandleMacroos

C6C0E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$5440,d0
	beq.b	C6C72
	cmp	#$C700,d0
	beq	C6CAC
	cmp	#$D400,d0
	beq	C6CB8
	cmp	#$4740,d0
	beq.b	C6C54
	cmp	#$5452,d0
	beq.b	C6C44
	cmp	#$D442,d0
	beq.b	C6C9A
	cmp	#$5442,d0
	beq.b	C6C8E
	br	HandleMacroos

C6C44:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CE00,d0
	beq	CD75C
	br	HandleMacroos

C6C54:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq	ERROR_IllegalSize
	cmp	#$CC00,d0
	beq.b	C6CAC
	cmp	#$C200,d0
	beq	ERROR_IllegalSize
	br	HandleMacroos

C6C72:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C6CB8
	cmp	#$CC00,d0
	beq.b	C6CC4
	cmp	#$C200,d0
	beq	ERROR_IllegalSize
	br	HandleMacroos

C6C8E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C04C,d0
	bne	ERROR_IllegalSize
C6C9A:
	move	#$49C0,d6
	moveq	#0,d5
	jmp	(Asm_EXTB)

C6CAC:
	move	#$C140,d6
	move	#$0080,d5
	br	Asm_EXG

C6CB8:
	move	#$4880,d6
	moveq	#$40,d5
	jmp	(Asm_EXT)

C6CC4:
	move	#$48C0,d6
	move	#$0080,d5
	jmp	(Asm_EXT)

C6CD2:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$5240,d0
	beq.b	C6CF2
	cmp	#$D200,d0
	beq.b	C6D30
	cmp	#$5249,d0
	beq.b	C6D0C
	cmp	#$D249,d0
	beq.b	C6D30
	br	HandleMacroos

C6CF2:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C6D30
	cmp	#$CC00,d0
	beq.b	C6D3A
	cmp	#$C200,d0
	beq.b	C6D26
	br	HandleMacroos

C6D0C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C6D30
	cmp	#$C04C,d0
	beq.b	C6D3A
	cmp	#$C042,d0
	beq.b	C6D26
	br	HandleMacroos

C6D26:
	move	#$BA00,d6
	moveq	#0,d5
	br	CEAB8

C6D30:
	move	#$BA00,d6
	moveq	#$40,d5
	br	CEAB8

C6D3A:
	move	#$BA00,d6
	move	#$0080,d5
	br	CEAB8

C6D46:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C54E,d0
	beq	ASSEM_CMDEVEN
	br	HandleMacroos

C6D56:
	move	(a3)+,d0
	and	d4,d0
	cmp	#('U'<<8)+$8000,d0
	beq	Asm_EQU
	cmp	#'UR'+$8000,d0
	beq	Asm_EQUR
	cmp	#'UA'+$8000,d0
	beq	Asm_EQUA
	br	HandleMacroos

AsmF:
	cmp	#'FA',d0
	beq	C9B64
	cmp	#'FB',d0
	beq	C9492
	cmp	#'FC',d0
	beq	C92CA
	cmp	#'FD',d0
	beq	AsmFD
	cmp	#'FE',d0
	beq	C8E5E
	cmp	#'FG',d0
	beq	C8D06
	cmp	#'FI',d0
	beq	C8BD4
	cmp	#'FL',d0
	beq	C895C
	cmp	#'FM',d0
	beq	Asm_FM
	cmp	#'FN',d0
	beq	C8682
	cmp	#'FR',d0
	beq	C85BC
	cmp	#'FS',d0
	beq	AsmFS
	cmp	#'FT',d0
	beq.b	C6DD8
	br	HandleMacroos

C6DD8:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"AN",d0
	beq	C7CBE
	cmp	#"AN"+$8000,d0
	beq	C7D3E
	cmp	#"EN",d0
	beq	C7C14
	cmp	#"RA",d0
	beq	C6F62
	cmp	#"ST"+$8000,d0
	beq	C6F46
	cmp	#"ST",d0
	beq	C6ECE
	cmp	#"WO",d0
	beq.b	C6E16
	br	HandleMacroos

C6E16:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"TO",d0
	beq.b	C6E24
	br	HandleMacroos

C6E24:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"X@",d0
	beq.b	C6E38
	cmp	#$D800,d0
	beq.b	C6EB2
	br	HandleMacroos

C6E38:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C200,d0
	beq.b	C6E6C
	cmp	#$D700,d0
	beq.b	C6E7A
	cmp	#$CC00,d0
	beq.b	C6E88
	cmp	#$D300,d0
	beq.b	C6E96
	cmp	#$C400,d0
	beq.b	C6EA4
	cmp	#$D800,d0
	beq.b	C6EB2
	cmp	#$D000,d0
	beq.b	C6EC0
	br	ERROR_Illegalfloating

C6E6C:	moveq	#6,d5
	bra.b	_Asm_FTWOTOX

C6E7A:	moveq	#4,d5
	bra.b	_Asm_FTWOTOX

C6E88:	moveq	#0,d5
	bra.b	_Asm_FTWOTOX

C6E96:	moveq	#$71,d5
	bra.b	_Asm_FTWOTOX

C6EA4:	moveq	#$75,d5
	bra.b	_Asm_FTWOTOX

C6EB2:	moveq	#$72,d5
	bra.b	_Asm_FTWOTOX

C6EC0:	moveq	#$73,d5
_Asm_FTWOTOX:
	move.l	#$0011F200,d6
	bra	_CFB00

C6ECE:	; FTST
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C042,d0
	beq.b	C6F00
	cmp	#$C057,d0
	beq.b	C6F0E
	cmp	#$C04C,d0
	beq.b	C6F1C
	cmp	#$C053,d0
	beq.b	C6F2A
	cmp	#$C044,d0
	beq.b	C6F38
	cmp	#$C058,d0
	beq.b	C6F46
	cmp	#$C050,d0
	beq.b	C6F54
	br	HandleMacroos

C6F00:	moveq	#6,d5
	bra.b	_Asm_FTST

C6F0E:	moveq	#4,d5
	bra.b	_Asm_FTST

C6F1C:	moveq	#0,d5
	bra.b	_Asm_FTST

C6F2A:	moveq	#$71,d5
	bra.b	_Asm_FTST

C6F38:	moveq	#$75,d5
	bra.b	_Asm_FTST

C6F46:	moveq	#$72,d5
	bra.b	_Asm_FTST

C6F54:	moveq	#$73,d5
_Asm_FTST:
	move.l	#$003AF200,d6
	bra	Asm_FTST

C6F62:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D046,d0
	beq.b	C6FD6
	cmp	#$5046,d0
	beq.b	C6FC2
	cmp	#$5045,d0
	beq	C7032
	cmp	#$504F,d0
	beq	C707E
	cmp	#$5055,d0
	beq	C75BE
	cmp	#$504E,d0
	beq	C7770
	cmp	#$D054,d0
	beq.b	C700E
	cmp	#$5054,d0
	beq.b	C6FFA
	cmp	#$5053,d0
	beq	C796A
	cmp	#$5047,d0
	beq	C7A8A
	cmp	#$504C,d0
	beq	C7B90
	br	HandleMacroos

C6FC2:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C6FE2
	cmp	#$C04C,d0
	beq.b	C6FEE
	br	ERROR_IllegalSize

C6FD6:	move.l	#$F27C0000,d6
	bra	_Asm_FtrapCC

C6FE2:	move.l	#$F27A0000,d6
	bra	_Asm_FtrapCC

C6FEE:	move.l	#$F27B0000,d6
	bra	_Asm_FtrapCC

C6FFA:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C701A
	cmp	#$C04C,d0
	beq.b	C7026
	br	ERROR_IllegalSize

C700E:	move.l	#$F27C000F,d6
	bra	_Asm_FtrapCC

C701A:	move.l	#$F27A000F,d6
	bra	_Asm_FtrapCC

C7026:	move.l	#$F27B000F,d6
	bra	_Asm_FtrapCC

C7032:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D100,d0
	beq.b	C705A
	cmp	#$5140,d0
	beq.b	C7046
	br	HandleMacroos

C7046:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C7066
	cmp	#$CC00,d0
	beq.b	C7072
	br	ERROR_IllegalSize

C705A:	move.l	#$F27C0001,d6
	bra	_Asm_FtrapCC

C7066:	move.l	#$F27A0001,d6
	bra	_Asm_FtrapCC

C7072:	move.l	#$F27B0001,d6
	bra	_Asm_FtrapCC

C707E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C754,d0
	beq.b	C70F4
	cmp	#'GT',d0
	beq.b	C70E0
	cmp	#$C745,d0
	beq	C712C
	cmp	#'GE',d0
	beq.b	C7118
	cmp	#$CC54,d0
	beq	C7164
	cmp	#'LT',d0
	beq	C7150
	cmp	#$CC45,d0
	beq	C719C
	cmp	#'LE',d0
	beq	C7188
	cmp	#$C74C,d0
	beq	C71D4
	cmp	#'GL',d0
	beq	C71C0
	cmp	#$D200,d0
	beq	C759A
	cmp	#'R@',d0
	beq	C71F8
	br	HandleMacroos

C70E0:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C7100
	cmp	#$C04C,d0
	beq.b	C710C
	br	ERROR_IllegalSize

C70F4:	move.l	#$F27C0002,d6
	bra	_Asm_FtrapCC

C7100:	move.l	#$F27A0002,d6
	bra	_Asm_FtrapCC

C710C:	move.l	#$F27B0002,d6
	bra	_Asm_FtrapCC

C7118:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C7138
	cmp	#$C04C,d0
	beq.b	C7144
	br	ERROR_IllegalSize

C712C:	move.l	#$F27C0003,d6
	bra	_Asm_FtrapCC

C7138:	move.l	#$F27A0003,d6
	bra	_Asm_FtrapCC

C7144:	move.l	#$F27B0003,d6
	bra	_Asm_FtrapCC

C7150:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C7170
	cmp	#$C04C,d0
	beq.b	C717C
	br	ERROR_IllegalSize

C7164:	move.l	#$F27C0004,d6
	bra	_Asm_FtrapCC

C7170:	move.l	#$F27A0004,d6
	bra	_Asm_FtrapCC

C717C:	move.l	#$F27B0004,d6
	bra	_Asm_FtrapCC

C7188:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C71A8
	cmp	#$C04C,d0
	beq.b	C71B4
	br	ERROR_IllegalSize

C719C:	move.l	#$F27C0005,d6
	bra	_Asm_FtrapCC

C71A8:	move.l	#$F27A0005,d6
	bra	_Asm_FtrapCC

C71B4:	move.l	#$F27B0005,d6
	bra	_Asm_FtrapCC

C71C0:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C71E0
	cmp	#$C04C,d0
	beq.b	C71EC
	br	ERROR_IllegalSize

C71D4:	move.l	#$F27C0006,d6
	bra	_Asm_FtrapCC

C71E0:	move.l	#$F27A0006,d6
	bra	_Asm_FtrapCC

C71EC:	move.l	#$F27B0006,d6
	bra	_Asm_FtrapCC

C71F8:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq	C75A6
	cmp	#$CC00,d0
	beq	C75B2
	br	ERROR_IllegalSize

C7210:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CE00,d0
	beq	Asm_CNOP
	br	HandleMacroos

Asm_AU:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D44F,d0
	beq	Asm_AUTO
	br	HandleMacroos

C7230:
	move	#$C100,d6
	moveq	#0,d5
	br	CEB92

C723A:
	move	#$C201,d6
	moveq	#$000,d5
	br	CEAB8

C7244:
	move	#$C201,d6
	moveq	#$040,d5
	br	CEAB8

C724E:
	move	#$C201,d6
	move	#$0080,d5
	br	CEAB8

cmp2_stuff_b:
	sf	-(a7)
	move	#$00C0,d6
	moveq	#$0000,d5
	jmp	(asm_chk2cmp2_long_stuff).l

cmp2_stuff_w:
	sf	-(a7)
	move	#$02C0,d6
	moveq	#$040,d5
	jmp	(asm_chk2cmp2_long_stuff).l

cmp2_stuff_l:
	sf	-(a7)
	move	#$04C0,d6
	move	#$080,d5
	jmp	(asm_chk2cmp2_long_stuff).l


C727E:
	move	#$4180,d6
	moveq	#$40,d5
	jmp	(C1006E).l

C728A:
	move	#$4100,d6
	move	#$0080,d5
	jmp	(C1006E).l

C7298:
	st	-(a7)
	move	#$02C0,d6
	moveq	#$0040,d5
	jmp	(asm_chk2cmp2_long_stuff).l

C72A6:
	st	-(a7)
	move	#$04C0,d6
	move	#$0080,d5
	jmp	(asm_chk2cmp2_long_stuff).l

C72B4:
	st	-(a7)
	move	#$00C0,d6
	moveq	#$0000,d5
	jmp	(asm_chk2cmp2_long_stuff).l


;*********** copy table error msgs *************

;			br	ERROR_AddressRegByte
_ERROR_AddressRegExp:	br	ERROR_AddressRegExp
;_ERROR_Dataregexpect:	br	ERROR_Dataregexpect
;			br	ERROR_DoubleSymbol
;_ERROR_EndofFile:	br	ERROR_EndofFile
;			br	ERROR_UsermadeFAIL
;			br	ERROR_FileError
_ERROR_InvalidAddrMode:	br	ERROR_InvalidAddrMode
;			br	ERROR_IllegalDevice
;			br	ERROR_IllegalMacrod
_ERROR_IllegalOperator:	br	ERROR_IllegalOperator
_ERROR_IllegalOperatorInBSS:br	ERROR_IllegalOperatorInBSS
_ERROR_IllegalOperand:	br	ERROR_IllegalOperand
;			br	ERROR_IllegalOrder
;			br	ERROR_IllegalSectio
_ERROR_IllegalAddres:	br	ERROR_IllegalAddres
_ERROR_Illegalregsiz:	br	ERROR_Illegalregsiz
;			br	ERROR_IllegalPath
_ERROR_IllegalSize:	br	ERROR_IllegalSize
;_ERROR_IllegalComman:	br	ERROR_IllegalComman
_ERROR_Immediateoper:	br	ERROR_Immediateoper
;			br	ERROR_IncludeJam
_ERROR_Commaexpected:	br	ERROR_Commaexpected
;			br	ERROR_LOADwithoutOR
_ERROR_Macrooverflow:	br	ERROR_Macrooverflow
;			br	ERROR_Conditionalov
_ERROR_WorkspaceMemoryFull:br	ERROR_WorkspaceMemoryFull
_ERROR_MissingQuote:	br	ERROR_MissingQuote
;			br	ERROR_Notinmacro
;			br	ERROR_Notdone
;			br	ERROR_NoFileSpace
;			br	ERROR_NoFiles
;			br	ERROR_Nodiskindrive
_ERROR_NOoperandspac:	br	ERROR_NOoperandspac
;			br	ERROR_NOTaconstantl
;			br	ERROR_NoObject
;;			br	ERROR_out_of_range0bit
_ERROR_out_of_range3bit:br	ERROR_out_of_range3bit
;			br	ERROR_out_of_range4bit
;			br	ERROR_out_of_range8bit
_ERROR_out_of_range16bit:br	ERROR_out_of_range16bit
_ERROR_RelativeModeEr:	br	ERROR_RelativeModeEr
;			br	ERROR_ReservedWord
_ERROR_RightParentesExpected:br	ERROR_Rightparenthe
;			br	ERROR_Stringexpected
_ERROR_Sectionoverflow:	br	ERROR_Sectionoverflow
_ERROR_Registerexpected:br	ERROR_Registerexpected
_ERROR_UndefSymbol:	br	ERROR_UndefSymbol
_ERROR_UnexpectedEOF:	br	ERROR_UnexpectedEOF
;			br	ERROR_WordatOddAddress
;			br	ERROR_WriteProtected
;			br	ERROR_Notlocalarea
_ERROR_Codemovedduring:	br	ERROR_Codemovedduring
;			br	ERROR_BccBoutofrange
;			br	ERROR_Outofrange20t
;			br	ERROR_Outofrange60t
;			br	ERROR_Includeoverflow
;			br	ERROR_Linkerlimitation
;			br	ERROR_Repeatoverflow
;			br	ERROR_NotinRepeatar
;			br	ERROR_Doubledefinition
;			br	ERROR_Relocationmade
;			br	ERROR_Illegaloption
;			br	ERROR_REMwithoutEREM
;			br	ERROR_TEXTwithoutETEXT
_ERROR_Illegalscales:	br	ERROR_Illegalscales
;			br	ERROR_Offsetwidthex
;			br	ERROR_OutofRange5bit
;			br	ERROR_Missingbrace
;			br	ERROR_Colonexpected
_ERROR_MissingBracket:	br	ERROR_MissingBracket
;			br	ERROR_Illegalfloating
;			br	ERROR_Illegalsizeform
;			br	ERROR_BccWoutofrange
;			br	ERROR_Floatingpoint
;			br	ERROR_OutofRange6bit
;			br	ERROR_OutofRange7bit
_ERROR_FPUneededforopp:	br	ERROR_FPUneededforopp
;			br	ERROR_Tomanywatchpoints
_ERROR_Illegalsource:	br	ERROR_Illegalsource
;			br	ERROR_Novalidmemory
;			br	ERROR_Autocommandoverflow
;			br	ERROR_Endshouldbehind
;			br	ERROR_Warningvalues
;			br	ERROR_IllegalsourceNr
;			br	ERROR_Includingempty
;			br	ERROR_IncludeSource
;			br	ERROR_UnknownconversionMode
;			br	ERROR_Unknowncmapplace
;			br	ERROR_Unknowncmapmode
;			br	ERROR_TryingtoincludenonILBM
;			br	ERROR_IFFfileisnotaILBM
;			br	ERROR_CanthandleBODYbBMHD
;_ERROR_ThisisnotaAsmProj:br	ERROR_ThisisnotaAsmProj
;			br	ERROR_Bitfieldoutofrange32bit
	IF	PPC
;			br	ERROR_GeneralPurpose
	ENDIF
;_ERROR_AdrOrPCExpected:	br	ERROR_AdrOrPCExpected
_ERROR_UnknowCPU:	br	ERROR_UnknowCPU
;			br	ERROR_StackFull

;***************************************************

Store_DataWordUnsigned:
	btst	#AF_UNDEFVALUE,d7
	bne.b	asmbl_send_Word\.pass1		;C7470
	tst	d2
	bne	Asmbl_send_XREF_dataW
	move.l	d3,d0
	bpl.b	C745A
	not.l	d0
	cmp.l	#$00007FFF,d0
	bgt.w	ERROR_out_of_range16bit
C745A:
	clr	d0
	tst.l	d0
	bne	ERROR_out_of_range16bit

asmbl_send_Word:
	tst	d7	;passone
	bmi.b	.pass1
	move.l	(Binary_Offset-DT,a4),a0
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
	move	d3,(a0)
.pass1:
	addq.l	#2,(Binary_Offset-DT,a4)
	rts

Asm_FloatsizeS:
	btst	#AF_UNDEFVALUE,d7
	bne.b	C748C
	tst	d7	;passone
	bmi.b	C748C
	move.l	(Binary_Offset-DT,a4),a0
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
	fmove.s	fp0,(a0)
C748C:
	addq.l	#4,(Binary_Offset-DT,a4)
	rts

Asm_FloatsizeD:
	btst	#AF_UNDEFVALUE,d7
	bne.b	C74A8
	tst	d7	;passone
	bmi.b	C74A8
	move.l	(Binary_Offset-DT,a4),a0
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
	fmove.d	fp0,(a0)
C74A8:
	addq.l	#8,(Binary_Offset-DT,a4)
	rts

Asm_FloatsizeX:
	btst	#AF_UNDEFVALUE,d7
	bne.b	C74C4
	tst	d7	;passone
	bmi.b	C74C4
	move.l	(Binary_Offset-DT,a4),a0
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
	fmove.x	fp0,(a0)
C74C4:
	add.l	#12,(Binary_Offset-DT,a4)
	rts

Asm_FloatsizeP:
	btst	#AF_UNDEFVALUE,d7
	bne.b	C74C4
	tst	d7	;passone
	bmi.b	C74C4
	move.l	(Binary_Offset-DT,a4),a0
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
	fmove.p	fp0,(a0){#0}
	bra.b	C74C4

Store_DataLongReloc:
	tst	d7	;passone
	bmi.b	.passone
	tst	d2
	bne	Asm_StoreL_Reloc
	move.l	(Binary_Offset-DT,a4),a0
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
	move.l	d3,(a0)
.passone:
	addq.l	#4,(Binary_Offset-DT,a4)
	rts

Store_Data2BytesUnsigned:
	tst	d7	;passone
	bmi.b	C750E
	move.l	(Binary_Offset-DT,a4),a0
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
	clr.b	(a0)
C750E:
	addq.l	#1,(Binary_Offset-DT,a4)
C7512:
	btst	#AF_UNDEFVALUE,d7
	bne.b	C753A
	tst	d2
	bne	Asmbl_send_XREF_dataB
	move.l	d3,d0
	bpl.b	C7524
	not.l	d0
C7524:
	clr.b	d0
	tst.l	d0
	bne	ERROR_out_of_range8bit
asmbl_send_Byte:
	tst	d7	;passone
	bmi.b	C753A
	move.l	(Binary_Offset-DT,a4),a0
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
	move.b	d3,(a0)
C753A:
	addq.l	#1,(Binary_Offset-DT,a4)
	rts

Parse_IetsMetExtentionWord:
	btst	#AF_UNDEFVALUE,d7
	bne.b	C753A
	tst	d2
	bne	Asmbl_send_XREF_dataB
	move.b	d3,d0
	IF	MC020
	extb.l	d0
	ELSE
	ext.w	d0
	ext.l	d0
	ENDIF
	cmp.l	d0,d3
	beq.b	asmbl_send_Byte
	bra	ERROR_out_of_range8bit

Parse_MakeExtentionLongword:	;move.l	([kake],100.l),d2
	btst	#AF_UNDEFVALUE,d7
	bne.b	C753A
	tst	d2
	bne	Asmbl_send_XREF_dataB
	bra.b	asmbl_send_Byte

C755A:
	btst	#AF_UNDEFVALUE,d7
	bne	asmbl_send_Word\.pass1
	tst	d2
	bne	Asmbl_send_XREF_dataW

	move	d3,d0
	ext.l	d0
	cmp.l	d0,d3
	bne	ERROR_out_of_range16bit

	br	asmbl_send_Word

C7576:
	bclr	#AF_OFFSET,d7
	move	(LastSection-DT,a4),d0
	bsr	ASSEM_GET_OLD_SECTION
	bsr	Parse_GetDefinedValue
	cmp.l	(INSTRUCTION_ORG_PTR-DT,a4),d3
	blt.w	ERROR_RelativeModeEr
	move.l	d3,(INSTRUCTION_ORG_PTR-DT,a4)
	br	SET_LAST_LABEL_TO_ORG_PTR

C759A:	move.l	#$F27C0007,d6
	bra	_Asm_FtrapCC

C75A6:	move.l	#$F27A0007,d6
	bra	_Asm_FtrapCC

C75B2:	move.l	#$F27B0007,d6
	bra	_Asm_FtrapCC

C75BE:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CE00,d0
	beq.b	C7634
	cmp	#$4E40,d0
	beq.b	C7620
	cmp	#$C551,d0
	beq	C766C
	cmp	#$4551,d0
	beq.b	C7658
	cmp	#$C754,d0
	beq	C76A4
	cmp	#$4754,d0
	beq	C7690
	cmp	#$C745,d0
	beq	C76DC
	cmp	#$4745,d0
	beq	C76C8
	cmp	#$CC54,d0
	beq	C7714
	cmp	#$4C54,d0
	beq	C7700
	cmp	#$CC45,d0
	beq	C774C
	cmp	#$4C45,d0
	beq	C7738
	br	HandleMacroos

C7620:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C7640
	cmp	#$CC00,d0
	beq.b	C764C
	br	ERROR_IllegalSize

C7634:	move.l	#$F27C0008,d6
	bra	_Asm_FtrapCC

C7640:	move.l	#$F27A0008,d6
	bra	_Asm_FtrapCC

C764C:	move.l	#$F27B0008,d6
	bra	_Asm_FtrapCC

C7658:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C7678
	cmp	#$C04C,d0
	beq.b	C7684
	br	ERROR_IllegalSize

C766C:	move.l	#$F27C0009,d6
	bra	_Asm_FtrapCC

C7678:	move.l	#$F27A0009,d6
	bra	_Asm_FtrapCC

C7684:	move.l	#$F27B0009,d6
	bra	_Asm_FtrapCC

C7690:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C76B0
	cmp	#$C04C,d0
	beq.b	C76BC
	br	ERROR_IllegalSize

C76A4:	move.l	#$F27C000A,d6
	bra	_Asm_FtrapCC

C76B0:	move.l	#$F27A000A,d6
	bra	_Asm_FtrapCC

C76BC:	move.l	#$F27B000A,d6
	bra	_Asm_FtrapCC

C76C8:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C76E8
	cmp	#$C04C,d0
	beq.b	C76F4
	br	ERROR_IllegalSize

C76DC:	move.l	#$F27C000B,d6
	bra	_Asm_FtrapCC

C76E8:	move.l	#$F27A000B,d6
	bra	_Asm_FtrapCC

C76F4:	move.l	#$F27B000B,d6
	bra	_Asm_FtrapCC

C7700:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C7720
	cmp	#$C04C,d0
	beq.b	C772C
	br	ERROR_IllegalSize

C7714:	move.l	#$F27C000C,d6
	bra	_Asm_FtrapCC

C7720:	move.l	#$F27A000C,d6
	bra	_Asm_FtrapCC

C772C:	move.l	#$F27B000C,d6
	bra	_Asm_FtrapCC

C7738:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C7758
	cmp	#$C04C,d0
	beq.b	C7764
	br	ERROR_IllegalSize

C774C:	move.l	#$F27C000D,d6
	bra	_Asm_FtrapCC

C7758:	move.l	#$F27A000D,d6
	bra	_Asm_FtrapCC

C7764:	move.l	#$F27B000D,d6
	bra	_Asm_FtrapCC

C7770:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C500,d0
	beq	C7946
	cmp	#$4540,d0
	beq	C7932
	cmp	#$474C,d0
	beq.b	C77D6
	cmp	#$C74C,d0
	beq	C782E
	cmp	#$CC45,d0
	beq	C7866
	cmp	#$4C45,d0
	beq	C7852
	cmp	#$CC54,d0
	beq	C789E
	cmp	#$4C54,d0
	beq	C788A
	cmp	#$C745,d0
	beq	C78D6
	cmp	#$4745,d0
	beq	C78C2
	cmp	#$C754,d0
	beq	C790E
	cmp	#$4754,d0
	beq	C78FA
	br	HandleMacroos

C77D6:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C500,d0
	beq.b	C780A
	cmp	#$4540,d0
	beq.b	C77F6
	cmp	#$C057,d0
	beq.b	C7816
	cmp	#$C04C,d0
	beq.b	C7822
	br	HandleMacroos

C77F6:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C7816
	cmp	#$CC00,d0
	beq.b	C7822
	br	ERROR_IllegalSize

C780A:	move.l	#$F27C0018,d6
_Asm_FtrapCC:
	bra	Asm_FtrapCC

C7816:	move.l	#$F27A0018,d6
	bra	Asm_FtrapCC

C7822:	move.l	#$F27B0018,d6
	bra	Asm_FtrapCC

C782E:	move.l	#$F27C0019,d6
	bra	Asm_FtrapCC

C7852:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C7872
	cmp	#$C04C,d0
	beq.b	C787E
	br	ERROR_IllegalSize

C7866:	move.l	#$F27C001A,d6
	bra	Asm_FtrapCC

C7872:	move.l	#$F27A001A,d6
	bra	Asm_FtrapCC

C787E:	move.l	#$F27B001A,d6
	bra	Asm_FtrapCC

C788A:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C78AA
	cmp	#$C04C,d0
	beq.b	C78B6
	br	ERROR_IllegalSize

C789E:	move.l	#$F27C001B,d6
	bra	Asm_FtrapCC

C78AA:	move.l	#$F27A001B,d6
	bra	Asm_FtrapCC

C78B6:	move.l	#$F27B001B,d6
	bra	Asm_FtrapCC

C78C2:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C78E2
	cmp	#$C04C,d0
	beq.b	C78EE
	br	ERROR_IllegalSize

C78D6:	move.l	#$F27C001C,d6
	bra	Asm_FtrapCC

C78E2:	move.l	#$F27A001C,d6
	bra	Asm_FtrapCC

C78EE:	move.l	#$F27B001C,d6
	bra	Asm_FtrapCC

C78FA:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C791A
	cmp	#$C04C,d0
	beq.b	C7926
	br	ERROR_IllegalSize

C790E:	move.l	#$F27C001D,d6
	bra	Asm_FtrapCC

C791A:	move.l	#$F27A001D,d6
	bra	Asm_FtrapCC

C7926:	move.l	#$F27B001D,d6
	bra	Asm_FtrapCC

C7932:	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C7952
	cmp	#$CC00,d0
	beq.b	C795E
	br	ERROR_IllegalSize

C7946:	move.l	#$F27C000E,d6
	bra	Asm_FtrapCC

C7952:	move.l	#$F27A000E,d6
	bra	Asm_FtrapCC

C795E:	move.l	#$F27B000E,d6
	bra	Asm_FtrapCC

C796A:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C600,d0
	beq.b	C79BE
	cmp	#$4640,d0
	beq.b	C79AA
	cmp	#$D400,d0
	beq.b	C79F6
	cmp	#$5440,d0
	beq.b	C79E2
	cmp	#$C551,d0
	beq	C7A2E
	cmp	#$4551,d0
	beq.b	C7A1A
	cmp	#$CE45,d0
	beq	C7A66
	cmp	#$4E45,d0
	beq	C7A52
	br	HandleMacroos

C79AA:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C79CA
	cmp	#$CC00,d0
	beq.b	C79D6
	br	ERROR_IllegalSize

C79BE:	move.l	#$F27C0010,d6
	bra.w	Asm_FtrapCC

C79CA:	move.l	#$F27A0010,d6
	bra.w	Asm_FtrapCC

C79D6:	move.l	#$F27B0010,d6
	bra.w	Asm_FtrapCC

C79E2:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C7A02
	cmp	#$CC00,d0
	beq.b	C7A0E
	br	ERROR_IllegalSize

C79F6:	move.l	#$F27C001F,d6
	bra.w	Asm_FtrapCC

C7A02:	move.l	#$F27A001F,d6
	bra.w	Asm_FtrapCC

C7A0E:	move.l	#$F27B001F,d6
	bra.w	Asm_FtrapCC

C7A1A:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C7A3A
	cmp	#$C04C,d0
	beq.b	C7A46
	br	ERROR_IllegalSize

C7A2E:	move.l	#$F27C0011,d6
	bra.w	Asm_FtrapCC

C7A3A:	move.l	#$F27A0011,d6
	bra.w	Asm_FtrapCC

C7A46:	move.l	#$F27B0011,d6
	bra.w	Asm_FtrapCC

C7A52:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C7A72
	cmp	#$C04C,d0
	beq.b	C7A7E
	br	ERROR_IllegalSize

C7A66:	move.l	#$F27C001E,d6
	bra.w	Asm_FtrapCC

C7A72:	move.l	#$F27A001E,d6
	bra.w	Asm_FtrapCC

C7A7E:	move.l	#$F27B001E,d6
	bra.w	Asm_FtrapCC

C7A8A:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D400,d0
	beq.b	C7ADC
	cmp	#$5440,d0
	beq.b	C7AC8
	cmp	#$C500,d0
	beq.b	C7B0E
	cmp	#$4540,d0
	beq.b	C7AFA
	cmp	#$CC00,d0
	beq	C7B40
	cmp	#$4C40,d0
	beq.b	C7B2C
	cmp	#$CC45,d0
	beq	C7B72
	cmp	#$4C45,d0
	beq	C7B5E
	br	HandleMacroos

C7AC8:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C7AE6
	cmp	#$CC00,d0
	beq.b	C7AF0
	br	ERROR_IllegalSize

C7ADC:	move.l	#$F27C0012,d6
	br	Asm_FtrapCC

C7AE6:	move.l	#$F27A0012,d6
	br	Asm_FtrapCC

C7AF0:	move.l	#$F27B0012,d6
	br	Asm_FtrapCC

C7AFA:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C7B18
	cmp	#$CC00,d0
	beq.b	C7B22
	br	ERROR_IllegalSize

C7B0E:	move.l	#$F27C0013,d6
	br	Asm_FtrapCC

C7B18:	move.l	#$F27A0013,d6
	br	Asm_FtrapCC

C7B22:	move.l	#$F27B0013,d6
	br	Asm_FtrapCC

C7B2C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C7B4A
	cmp	#$CC00,d0
	beq.b	C7B54
	br	ERROR_IllegalSize

C7B40:	move.l	#$F27C0016,d6
	br	Asm_FtrapCC

C7B4A:	move.l	#$F27A0016,d6
	br	Asm_FtrapCC

C7B54:	move.l	#$F27B0016,d6
	br	Asm_FtrapCC

C7B5E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C7B7C
	cmp	#$C04C,d0
	beq.b	C7B86
	br	ERROR_IllegalSize

C7B72:	move.l	#$F27C0017,d6
	br	Asm_FtrapCC

C7B7C:	move.l	#$F27A0017,d6
	br	Asm_FtrapCC

C7B86:	move.l	#$F27B0017,d6
	br	Asm_FtrapCC

C7B90:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D400,d0
	beq.b	C7BC4
	cmp	#$5440,d0
	beq.b	C7BB0
	cmp	#$C500,d0
	beq.b	C7BF6
	cmp	#$4540,d0
	beq.b	C7BE2
	br	HandleMacroos

C7BB0:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C7BCE
	cmp	#$CC00,d0
	beq.b	C7BD8
	br	ERROR_IllegalSize

C7BC4:	move.l	#$F27C0014,d6
	br	Asm_FtrapCC

C7BCE:	move.l	#$F27A0014,d6
	br	Asm_FtrapCC

C7BD8:	move.l	#$F27B0014,d6
	br	Asm_FtrapCC

C7BE2:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C7C00
	cmp	#$CC00,d0
	beq.b	C7C0A
	br	ERROR_IllegalSize

C7BF6:	move.l	#$F27C0015,d6
	br	Asm_FtrapCC

C7C00:	move.l	#$F27A0015,d6
	br	Asm_FtrapCC

C7C0A:	move.l	#$F27B0015,d6
	br	Asm_FtrapCC

C7C14:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$544F,d0
	beq.b	C7C22
	br	HandleMacroos

C7C22:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$5840,d0
	beq.b	C7C36
	cmp	#$D800,d0
	beq.b	C7CA6
	br	HandleMacroos

C7C36:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C200,d0
	beq.b	C7C6A
	cmp	#$D700,d0
	beq.b	C7C76
	cmp	#$CC00,d0
	beq.b	C7C82
	cmp	#$D300,d0
	beq.b	C7C8E
	cmp	#$C400,d0
	beq.b	C7C9A
	cmp	#$D800,d0
	beq.b	C7CA6
	cmp	#$D000,d0
	beq.b	C7CB2
	br	HandleMacroos

C7C6A:	moveq	#6,d5
	bra.b	_Asm_FTENTOX

C7C76:	moveq	#4,d5
	bra.b	_Asm_FTENTOX

C7C82:	moveq	#0,d5
	bra.b	_Asm_FTENTOX

C7C8E:	moveq	#$71,d5
	bra.b	_Asm_FTENTOX

C7C9A:	moveq	#$75,d5
	bra.b	_Asm_FTENTOX

C7CA6:	moveq	#$72,d5
	bra.b	_Asm_FTENTOX

C7CB2:	moveq	#$73,d5
_Asm_FTENTOX:
	move.l	#$0012F200,d6
	br	CFB00

C7CBE:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$4840,d0
	beq.b	C7D56
	cmp	#$C800,d0
	beq	C7DC6
	cmp	#$C042,d0
	beq.b	C7D02
	cmp	#$C057,d0
	beq.b	C7D0E
	cmp	#$C04C,d0
	beq.b	C7D1A
	cmp	#$C053,d0
	beq.b	C7D26
	cmp	#$C044,d0
	beq.b	C7D32
	cmp	#$C058,d0
	beq.b	C7D3E
	cmp	#$C050,d0
	beq.b	C7D4A
	br	HandleMacroos

C7D02:	moveq	#6,d5
	bra.b	_Asm_FTAN

C7D0E:	moveq	#4,d5
	bra.b	_Asm_FTAN

C7D1A:	moveq	#0,d5
	bra.b	_Asm_FTAN

C7D26:	moveq	#$71,d5
	bra.b	_Asm_FTAN

C7D32:	moveq	#5,d5
	bra.b	_Asm_FTAN

C7D3E:	moveq	#$72,d5
	bra.b	_Asm_FTAN

C7D4A:	moveq	#$73,d5
_Asm_FTAN:
	move.l	#$000FF200,d6
	br	CFB00

C7D56:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C200,d0
	beq.b	C7D8A
	cmp	#$D700,d0
	beq.b	C7D96
	cmp	#$CC00,d0
	beq.b	C7DA2
	cmp	#$D300,d0
	beq.b	C7DAE
	cmp	#$C400,d0
	beq.b	C7DBA
	cmp	#$D800,d0
	beq.b	C7DC6
	cmp	#$D000,d0
	beq.b	C7DD2
	br	ERROR_Illegalfloating

C7D8A:	moveq	#6,d5
	bra.b	_Asm_FTANH

C7D96:	moveq	#4,d5
	bra.b	_Asm_FTANH

C7DA2:	moveq	#0,d5
	bra.b	_Asm_FTANH

C7DAE:	moveq	#$71,d5
	bra.b	_Asm_FTANH

C7DBA:	moveq	#$75,d5
	bra.b	_Asm_FTANH

C7DC6:	moveq	#$72,d5
	bra.b	_Asm_FTANH

C7DD2:	moveq	#$73,d5
_Asm_FTANH:
	move.l	#$0009F200,d6
	br	CFB00

AsmFS:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"AV",d0	;fsAV
	beq	C85A6
	cmp	#"CA",d0	;fsCA
	beq	C850C
	cmp	#$C94E,d0	;fsIN
	beq	C8080
	cmp	#"IN",d0	;fsIN
	beq	C7FFA
	cmp	#$5152,d0	;fsQR
	beq	C7F5E
	cmp	#$D542,d0
	beq	C7F46
	cmp	#$5542,d0	;fsUB
	beq	C7ED6
	cmp	#$C551,d0
	beq	C84EE
	cmp	#$CE45,d0
	beq	C84E4
	cmp	#$4F47,d0
	beq	C84A8
	cmp	#$4F4C,d0
	beq	C8480
	cmp	#$CF52,d0
	beq	C8476
	cmp	#$C600,d0
	beq	C84F8
	cmp	#$D400,d0
	beq	C8502
	cmp	#$D54E,d0
	beq	C846C
	cmp	#$5545,d0
	beq	C8454
	cmp	#$5547,d0
	beq	C842C
	cmp	#$554C,d0
	beq	C8404
	cmp	#$D346,d0
	beq	C83FA
	cmp	#$5345,d0
	beq	C81E2
	cmp	#$C754,d0
	beq	C81D8
	cmp	#$C745,d0
	beq	C81CE
	cmp	#$CC54,d0
	beq	C81C4
	cmp	#$CC45,d0
	beq	C81BA
	cmp	#$C74C,d0
	beq	C8350
	cmp	#$474C,d0	; fsGL
	beq	C81FA
	cmp	#$4E47,d0
	beq	C8364
	cmp	#$4E4C,d0
	beq	C83B0
	cmp	#$534E,d0
	beq	C83D8
	cmp	#$D354,d0
	beq	C83F0
	br	HandleMacroos

C7ED6:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C042,d0
	beq.b	C7F0A
	cmp	#$C057,d0
	beq.b	C7F16
	cmp	#$C04C,d0
	beq.b	C7F22
	cmp	#$C053,d0
	beq.b	C7F2E
	cmp	#$C044,d0
	beq.b	C7F3A
	cmp	#$C058,d0
	beq.b	C7F46
	cmp	#$C050,d0
	beq.b	C7F52
	br	HandleMacroos

C7F0A:	moveq	#6,d5
	bra.b	_Asm_FSUB

C7F16:	moveq	#4,d5
	bra.b	_Asm_FSUB

C7F22:	moveq	#0,d5
	bra.b	_Asm_FSUB

C7F2E:	moveq	#$71,d5
	bra.b	_Asm_FSUB

C7F3A:	moveq	#$75,d5
	bra.b	_Asm_FSUB

C7F46:	moveq	#$72,d5
	bra.b	_Asm_FSUB

C7F52:	moveq	#$73,d5
_Asm_FSUB:
	move.l	#$0028F200,d6
	br	Asm_FPopperant

C7F5E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$5440,d0
	beq.b	C7F72
	cmp	#$D400,d0
	beq.b	C7FE2
	br	HandleMacroos

C7F72:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C200,d0
	beq.b	C7FA6
	cmp	#$D700,d0
	beq.b	C7FB2
	cmp	#$CC00,d0
	beq.b	C7FBE
	cmp	#$D300,d0
	beq.b	C7FCA
	cmp	#$C400,d0
	beq.b	C7FD6
	cmp	#$D800,d0
	beq.b	C7FE2
	cmp	#$D000,d0
	beq.b	C7FEE
	br	ERROR_Illegalfloating

C7FA6:	moveq	#6,d5
	bra.b	_Asm_FSQRT

C7FB2:	moveq	#4,d5
	bra.b	_Asm_FSQRT

C7FBE:	moveq	#0,d5
	bra.b	_Asm_FSQRT

C7FCA:	moveq	#$71,d5
	bra.b	_Asm_FSQRT

C7FD6:	moveq	#$75,d5
	bra.b	_Asm_FSQRT

C7FE2:	moveq	#$72,d5
	bra.b	_Asm_FSQRT

C7FEE:	moveq	#$73,d5
_Asm_FSQRT:
	move.l	#$0004F200,d6
	br	CFB00

C7FFA:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$4840,d0
	beq	C8134
	cmp	#$C800,d0
	beq	C81A2
	cmp	#$434F,d0
	beq.b	C8098
	cmp	#$C042,d0
	beq.b	C8044
	cmp	#$C057,d0
	beq.b	C8050
	cmp	#$C04C,d0
	beq.b	C805C
	cmp	#$C053,d0
	beq.b	C8068
	cmp	#$C044,d0
	beq.b	C8074
	cmp	#$C058,d0
	beq.b	C8080
	cmp	#$C050,d0
	beq.b	C808C
	br	HandleMacroos

C8044:	moveq	#6,d5
	bra.b	_Asm_FSIN

C8050:	moveq	#4,d5
	bra.b	_Asm_FSIN

C805C:	moveq	#0,d5
	bra.b	_Asm_FSIN

C8068:	moveq	#$71,d5
	bra.b	_Asm_FSIN

C8074:	moveq	#$75,d5
	bra.b	_Asm_FSIN

C8080:	moveq	#$72,d5
	bra.b	_Asm_FSIN

C808C:	moveq	#$73,d5
_Asm_FSIN:
	move.l	#$000EF200,d6
	br	CFB00

C8098:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D300,d0
	beq.b	C811C
	cmp	#$5340,d0
	beq.b	C80AC
	br	HandleMacroos

C80AC:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C200,d0
	beq.b	C80E0
	cmp	#$D700,d0
	beq.b	C80EC
	cmp	#$CC00,d0
	beq.b	C80F8
	cmp	#$D300,d0
	beq.b	C8104
	cmp	#$C400,d0
	beq.b	C8110
	cmp	#$D800,d0
	beq.b	C811C
	cmp	#$D000,d0
	beq.b	C8128
	br	ERROR_Illegalfloating

C80E0:	moveq	#6,d5
	bra.b	_Asm_FSINCOS

C80EC:	moveq	#4,d5
	bra.b	_Asm_FSINCOS

C80F8:	moveq	#0,d5
	bra.b	_Asm_FSINCOS

C8104:	moveq	#$71,d5
	bra.b	_Asm_FSINCOS

C8110:	moveq	#$75,d5
	bra.b	_Asm_FSINCOS

C811C:	moveq	#$72,d5
	bra.b	_Asm_FSINCOS

C8128:	moveq	#$73,d5
_Asm_FSINCOS:
	move.l	#$0030F200,d6
	br	CFC6A

C8134:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C200,d0
	beq.b	C8166
	cmp	#$D700,d0
	beq.b	C8172
	cmp	#$CC00,d0
	beq.b	C817E
	cmp	#$D300,d0
	beq.b	C818A
	cmp	#$C400,d0
	beq.b	C8196
	cmp	#$D800,d0
	beq.b	C81A2
	cmp	#$D000,d0
	beq.b	C81AE
	br	ERROR_Illegalfloating

C8166:	moveq	#6,d5
	bra.b	_Asm_FSINH

C8172:	moveq	#4,d5
	bra.b	_Asm_FSINH

C817E:	moveq	#0,d5
	bra.b	_Asm_FSINH

C818A:	moveq	#$71,d5
	bra.b	_Asm_FSINH

C8196:	moveq	#$75,d5
	bra.b	_Asm_FSINH

C81A2:	moveq	#$72,d5
	bra.b	_Asm_FSINH

C81AE:	moveq	#$73,d5
_Asm_FSINH:
	move.l	#$0002F200,d6
	br	CFB00

C81BA:	move.l	#$0015F240,d6
	br	CF48C

C81C4:	move.l	#$0014F240,d6
	br	CF48C

C81CE:	move.l	#$0013F240,d6
	br	CF48C

C81D8:	move.l	#$0012F240,d6
	br	CF48C

C81E2:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D100,d0
	beq.b	C81F0
	br	HandleMacroos

C81F0:
	move.l	#$0011F240,d6
	br	CF48C

C81FA:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C500,d0
	beq	C835A
	cmp	#$4449,d0
	beq.b	C822C
	cmp	#$4D55,d0
	beq.b	C8216
	br	HandleMacroos

C8216:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CC00,d0
	beq.b	C82B2
	cmp	#$4C40,d0
	beq.b	C8244
	br	HandleMacroos

C822C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D600,d0
	beq	C8338
	cmp	#$5640,d0
	beq.b	C82CA
	br	HandleMacroos

C8244:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C200,d0
	beq.b	C8276
	cmp	#$D700,d0
	beq.b	C8282
	cmp	#$CC00,d0
	beq.b	C828E
	cmp	#$D300,d0
	beq.b	C829A
	cmp	#$C400,d0
	beq.b	C82A6
	cmp	#$D800,d0
	beq.b	C82B2
	cmp	#$D000,d0
	beq.b	C82BE
	br	ERROR_Illegalfloating

C8276:	moveq	#6,d5
	bra.b	_Asm_FSGLMUL

C8282:	moveq	#4,d5
	bra.b	_Asm_FSGLMUL

C828E:	moveq	#0,d5
	bra.b	_Asm_FSGLMUL

C829A:	moveq	#$71,d5
	bra.b	_Asm_FSGLMUL

C82A6:	moveq	#$75,d5
	bra.b	_Asm_FSGLMUL

C82B2:	moveq	#$72,d5
	bra.b	_Asm_FSGLMUL

C82BE:	moveq	#$73,d5
_Asm_FSGLMUL:
	move.l	#$0027F200,d6
	br	Asm_FPopperant

C82CA:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C200,d0
	beq.b	C82FC
	cmp	#$D700,d0
	beq.b	C8308
	cmp	#$CC00,d0
	beq.b	C8314
	cmp	#$D300,d0
	beq.b	C8320
	cmp	#$C400,d0
	beq.b	C832C
	cmp	#$D800,d0
	beq.b	C8338
	cmp	#$D000,d0
	beq.b	C8344
	br	ERROR_Illegalfloating

C82FC:	moveq	#6,d5
	bra.b	_Asm_FSGLDIV

C8308:	moveq	#4,d5
	bra.b	_Asm_FSGLDIV

C8314:	moveq	#0,d5
	bra.b	_Asm_FSGLDIV

C8320:	moveq	#$71,d5
	bra.b	_Asm_FSGLDIV

C832C:	moveq	#$75,d5
	bra.b	_Asm_FSGLDIV

C8338:	moveq	#$72,d5
	bra.b	_Asm_FSGLDIV

C8344:	moveq	#$73,d5
_Asm_FSGLDIV:
	move.l	#$0024F200,d6
	br	Asm_FPopperant

C8350:	move.l	#$0016F240,d6
	br	CF48C

C835A:	move.l	#$0017F240,d6
	br	CF48C

C8364:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CC45,d0
	beq.b	C839C
	cmp	#$CC00,d0
	beq.b	C83A6
	cmp	#$D400,d0
	beq.b	C8388
	cmp	#$C500,d0
	beq.b	C8392
	br	HandleMacroos

C8388:	move.l	#$001DF240,d6
	br	CF48C

C8392:	move.l	#$001CF240,d6
	br	CF48C

C839C:	move.l	#$0018F240,d6
	br	CF48C

C83A6:	move.l	#$0019F240,d6
	br	CF48C

C83B0:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C500,d0
	beq.b	C83C4
	cmp	#$D400,d0
	beq.b	C83CE
	br	HandleMacroos

C83C4:	move.l	#$001AF240,d6
	br	CF48C

C83CE:	move.l	#$001BF240,d6
	br	CF48C

C83D8:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C500,d0
	beq.b	C83E6
	br	HandleMacroos

C83E6:	move.l	#$001EF240,d6
	br	CF48C

C83F0:	move.l	#$001FF240,d6
	br	CF48C

C83FA:	move.l	#$0010F240,d6
	br	CF48C

C8404:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D400,d0
	beq.b	C8422
	cmp	#$C500,d0
	beq.b	C8418
	br	HandleMacroos

C8418:	move.l	#$000DF240,d6
	br	CF48C

C8422:	move.l	#$000CF240,d6
	br	CF48C

C842C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D400,d0
	beq.b	C844A
	cmp	#$C500,d0
	beq.b	C8440
	br	HandleMacroos

C8440:	move.l	#$000BF240,d6
	br	CF48C

C844A:	move.l	#$000AF240,d6
	br	CF48C

C8454:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D100,d0
	beq.b	C8462
	br	HandleMacroos

C8462:	move.l	#$0009F240,d6
	br	CF48C

C846C:	move.l	#$0008F240,d6
	br	CF48C

C8476:
	move.l	#$0007F240,d6
	br	CF48C

C8480:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D400,d0
	beq.b	C8494
	cmp	#$C500,d0
	beq.b	C849E
	br	HandleMacroos

C8494:	move.l	#$0004F240,d6
	br	CF48C

C849E:	move.l	#$0005F240,d6
	br	CF48C

C84A8:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D400,d0
	beq.b	C84C6
	cmp	#$C500,d0
	beq.b	C84D0
	cmp	#$CC00,d0
	beq.b	C84DA
	br	HandleMacroos

C84C6:	move.l	#$0002F240,d6
	br	CF48C

C84D0:	move.l	#$0003F240,d6
	br	CF48C

C84DA:	move.l	#$0006F240,d6
	br	CF48C

C84E4:	move.l	#$000EF240,d6
	br	CF48C

C84EE:	move.l	#$0001F240,d6
	br	CF48C

C84F8:	move.l	#$0000F240,d6
	br	CF48C

C8502:	move.l	#$000FF240,d6
	br	CF48C

C850C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CC45,d0
	beq.b	C858E
	cmp	#$4C45,d0
	beq.b	C8520
	br	HandleMacroos

C8520:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C042,d0
	beq.b	C8552
	cmp	#$C057,d0
	beq.b	C855E
	cmp	#$C04C,d0
	beq.b	C856A
	cmp	#$C053,d0
	beq.b	C8576
	cmp	#$C044,d0
	beq.b	C8582
	cmp	#$C058,d0
	beq.b	C858E
	cmp	#$C050,d0
	beq.b	C859A
	br	ERROR_Illegalfloating

C8552:	moveq	#6,d5
	bra.b	_Asm_FSCALE

C855E:	moveq	#4,d5
	bra.b	_Asm_FSCALE

C856A:	moveq	#0,d5
	bra.b	_Asm_FSCALE

C8576:	moveq	#$71,d5
	bra.b	_Asm_FSCALE

C8582:	moveq	#$75,d5
	bra.b	_Asm_FSCALE

C858E:	moveq	#$72,d5
	bra.b	_Asm_FSCALE

C859A:	moveq	#$73,d5
_Asm_FSCALE:
	move.l	#$0026F200,d6
	br	Asm_FPopperant

C85A6:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C500,d0
	beq.b	C85B4
	br	HandleMacroos

C85B4:	move	#$F300,d6
	br	Asm_FsaveFrestore

C85BC:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C54D,d0
	beq.b	C866A
	cmp	#$454D,d0
	beq.b	C85FC
	cmp	#$4553,d0
	beq.b	C85D8
	br	HandleMacroos

C85D8:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$544F,d0
	beq.b	C85E6
	br	HandleMacroos

C85E6:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D245,d0
	beq.b	C85F4
	br	HandleMacroos

C85F4:
	move	#$F340,d6
	br	Asm_FsaveFrestore

C85FC:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C042,d0
	beq.b	C862E
	cmp	#$C057,d0
	beq.b	C863A
	cmp	#$C04C,d0
	beq.b	C8646
	cmp	#$C053,d0
	beq.b	C8652
	cmp	#$C044,d0
	beq.b	C865E
	cmp	#$C058,d0
	beq.b	C866A
	cmp	#$C050,d0
	beq.b	C8676
	br	ERROR_Illegalfloating

C862E:	moveq	#6,d5
	bra.b	_Asm_FREM

C863A:	moveq	#4,d5
	bra.b	_Asm_FREM

C8646:	moveq	#0,d5
	bra.b	_Asm_FREM

C8652:	moveq	#$71,d5
	bra.b	_Asm_FREM

C865E:	moveq	#$75,d5
	bra.b	_Asm_FREM

C866A:	moveq	#$72,d5
	bra.b	_Asm_FREM

C8676:	moveq	#$73,d5
_Asm_FREM:
	move.l	#$0025F200,d6
	br	Asm_FPopperant

C8682:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C547,d0
	beq.b	C871A
	cmp	#$4547,d0
	beq.b	C86AC
	cmp	#$CF50,d0
	beq.b	C869E
	br	HandleMacroos

C869E:	move.l	#$F2800000,d6
	move	#$8040,d5
	br	CE9AC

C86AC:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C042,d0
	beq.b	C86DE
	cmp	#$C057,d0
	beq.b	C86EA
	cmp	#$C04C,d0
	beq.b	C86F6
	cmp	#$C053,d0
	beq.b	C8702
	cmp	#$C044,d0
	beq.b	C870E
	cmp	#$C058,d0
	beq.b	C871A
	cmp	#$C050,d0
	beq.b	C8726
	br	ERROR_Illegalfloating

C86DE:	moveq	#6,d5
	bra.b	_Asm_FNEG

C86EA:	moveq	#4,d5
	bra.b	_Asm_FNEG

C86F6:	moveq	#0,d5
	bra.b	_Asm_FNEG

C8702:	moveq	#$71,d5
	bra.b	_Asm_FNEG

C870E:	moveq	#$75,d5
	bra.b	_Asm_FNEG

C871A:	moveq	#$72,d5
	bra.b	_Asm_FNEG

C8726:	moveq	#$73,d5
_Asm_FNEG:
	move.l	#$001AF200,d6
	br	CFB00

Asm_FM:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$4F56,d0	;fmOV
	beq.b	Asm_FMOV
	cmp	#$D54C,d0	;fmUL
	beq.b	C87CC
	cmp	#$554C,d0	;fmUL
	beq.b	C875E
	cmp	#$CF44,d0	;fmOD
	beq	C8944
	cmp	#$4F44,d0	;fmOD
	beq	C88D6
	br	HandleMacroos

C875E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C042,d0
	beq.b	C8790
	cmp	#$C057,d0
	beq.b	C879C
	cmp	#$C04C,d0
	beq.b	C87A8
	cmp	#$C053,d0
	beq.b	C87B4
	cmp	#$C044,d0
	beq.b	C87C0
	cmp	#$C058,d0
	beq.b	C87CC
	cmp	#$C050,d0
	beq.b	C87D8
	br	ERROR_Illegalfloating

C8790:	moveq	#6,d5
	bra.b	_Asm_FMUL

C879C:	moveq	#4,d5
	bra.b	_Asm_FMUL

C87A8:	moveq	#0,d5
	bra.b	_Asm_FMUL

C87B4:	moveq	#$71,d5
	bra.b	_Asm_FMUL

C87C0:	moveq	#$75,d5
	bra.b	_Asm_FMUL

C87CC:	moveq	#$72,d5
	bra.b	_Asm_FMUL

C87D8:	moveq	#$73,d5
_Asm_FMUL:
	move.l	#$0023F200,d6
	br	Asm_FPopperant

Asm_FMOV:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C500,d0	;fmove
	beq	asm_fmovex
	cmp	#$4540,d0	;fmove.
	beq.b	asm_fmove_
	cmp	#$4543,d0	;fmovec
	beq.b	C8822
	cmp	#$454D,d0	;fmovem
	beq.b	.C880C
	cmp	#$C54D,d0	;fmoveM
	bne.w	HandleMacroos
	moveq	#0,d5
.C8818
	move.l	#$8000F200,d6
	br	Asm_FMOVEM
.C880C
	moveq	#$72,d5
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C058,d0	; fmovem.X
	beq.b	.C8818
	move.w	#$80,d5
	cmp	#$c04c,d0	; fmovem.L
	beq.b	.C8818
	bra.w	ERROR_IllegalSize

C8822:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D200,d0
	beq.b	C8842
	cmp	#$5240,d0
	beq.b	C8836
	br	HandleMacroos

C8836:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D800,d0
	bne	ERROR_IllegalSize
C8842:
	move.l	#$5C00F200,d6
	br	Asm_FMOVECR

asm_fmove_:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C200,d0
	beq.b	asm_fmoveb
	cmp	#$D700,d0
	beq.b	asm_fmovew
	cmp	#$CC00,d0
	beq.b	asm_fmovel
	cmp	#$D300,d0
	beq.b	asm_fmoves
	cmp	#$C400,d0
	beq.b	asm_fmoved
	cmp	#$D800,d0
	beq.b	asm_fmovex
	cmp	#$D000,d0
	beq.b	asm_fmovep
	br	ERROR_Illegalfloating

asm_fmoveb:
	moveq	#6,d5
	br	Asmbl_FinishFmove

asm_fmovew:
	moveq	#$44,d5
	br	Asmbl_FinishFmove

asm_fmovel:
	moveq	#$80-256,d5
	br	Asmbl_FinishFmove

asm_fmoves:
	moveq	#$71,d5
	br	Asmbl_FinishFmove

asm_fmoved:
	moveq	#$75,d5
	br	Asmbl_FinishFmove

asm_fmovex:
	moveq	#$72,d5
	br	Asmbl_FinishFmove

asm_fmovep:
	moveq	#$73,d5
	br	Asmbl_FinishFmove

C88D6:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C042,d0
	beq.b	C8908
	cmp	#$C057,d0
	beq.b	C8914
	cmp	#$C04C,d0
	beq.b	C8920
	cmp	#$C053,d0
	beq.b	C892C
	cmp	#$C044,d0
	beq.b	C8938
	cmp	#$C058,d0
	beq.b	C8944
	cmp	#$C050,d0
	beq.b	C8950
	br	ERROR_Illegalfloating

C8908:	moveq	#6,d5
	bra.b	_Asm_FMOD

C8914:	moveq	#4,d5
	bra.b	_Asm_FMOD

C8920:	moveq	#0,d5
	bra.b	_Asm_FMOD

C892C:	moveq	#$71,d5
	bra.b	_Asm_FMOD

C8938:	moveq	#$75,d5
	bra.b	_Asm_FMOD

C8944:	moveq	#$72,d5
	bra.b	_Asm_FMOD

C8950:	moveq	#$73,d5
_Asm_FMOD:
	move.l	#$0021F200,d6
	br	Asm_FPopperant

C895C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$4F47,d0
	beq.b	C896A
	br	HandleMacroos

C896A:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$9110,d0
	beq	C8BBC
	cmp	#$1110,d0
	beq	C8B4E
	cmp	#$9200,d0
	beq	C8B36
	cmp	#$1240,d0
	beq	C8AC8
	cmp	#$CE00,d0
	beq	C8AB0
	cmp	#$4E40,d0
	beq.b	C8A42
	cmp	#$4E50,d0
	beq.b	C89A8
	br	HandleMacroos

C89A8:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$9100,d0
	beq.b	C8A2A
	cmp	#$1140,d0
	beq.b	C89BC
	br	HandleMacroos

C89BC:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C200,d0
	beq.b	C89EE
	cmp	#$D700,d0
	beq.b	C89FA
	cmp	#$CC00,d0
	beq.b	C8A06
	cmp	#$D300,d0
	beq.b	C8A12
	cmp	#$C400,d0
	beq.b	C8A1E
	cmp	#$D800,d0
	beq.b	C8A2A
	cmp	#$D000,d0
	beq.b	C8A36
	br	ERROR_Illegalfloating

C89EE:	moveq	#6,d5
	bra.b	_Asm_FLOGNP1

C89FA:	moveq	#4,d5
	bra.b	_Asm_FLOGNP1

C8A06:	moveq	#0,d5
	bra.b	_Asm_FLOGNP1

C8A12:	moveq	#$71,d5
	bra.b	_Asm_FLOGNP1

C8A1E:	moveq	#$75,d5
	bra.b	_Asm_FLOGNP1

C8A2A:	moveq	#$72,d5
	bra.b	_Asm_FLOGNP1

C8A36:	moveq	#$73,d5
_Asm_FLOGNP1:
	move.l	#$0006F200,d6
	br	CFB00

C8A42:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C200,d0
	beq.b	C8A74
	cmp	#$D700,d0
	beq.b	C8A80
	cmp	#$CC00,d0
	beq.b	C8A8C
	cmp	#$D300,d0
	beq.b	C8A98
	cmp	#$C400,d0
	beq.b	C8AA4
	cmp	#$D800,d0
	beq.b	C8AB0
	cmp	#$D000,d0
	beq.b	C8ABC
	br	ERROR_Illegalfloating

C8A74:	moveq	#6,d5
	bra.b	_Asm_FLOGN

C8A80:	moveq	#4,d5
	bra.b	_Asm_FLOGN

C8A8C:	moveq	#0,d5
	bra.b	_Asm_FLOGN

C8A98:	moveq	#$71,d5
	bra.b	_Asm_FLOGN

C8AA4:	moveq	#$75,d5
	bra.b	_Asm_FLOGN

C8AB0:	moveq	#$72,d5
	bra.b	_Asm_FLOGN

C8ABC:	moveq	#$73,d5
_Asm_FLOGN:
	move.l	#$0014F200,d6
	br	CFB00

C8AC8:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C200,d0
	beq.b	C8AFA
	cmp	#$D700,d0
	beq.b	C8B06
	cmp	#$CC00,d0
	beq.b	C8B12
	cmp	#$D300,d0
	beq.b	C8B1E
	cmp	#$C400,d0
	beq.b	C8B2A
	cmp	#$D800,d0
	beq.b	C8B36
	cmp	#$D000,d0
	beq.b	C8B42
	br	ERROR_Illegalfloating

C8AFA:	moveq	#6,d5
	bra.b	_Asm_FLOG2

C8B06:	moveq	#4,d5
	bra.b	_Asm_FLOG2

C8B12:	moveq	#0,d5
	bra.b	_Asm_FLOG2

C8B1E:	moveq	#$71,d5
	bra.b	_Asm_FLOG2

C8B2A:	moveq	#$75,d5
	bra.b	_Asm_FLOG2

C8B36:	moveq	#$72,d5
	bra.b	_Asm_FLOG2

C8B42:	moveq	#$73,d5
_Asm_FLOG2:
	move.l	#$0016F200,d6
	br	CFB00

C8B4E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C042,d0
	beq.b	C8B80
	cmp	#$C057,d0
	beq.b	C8B8C
	cmp	#$C04C,d0
	beq.b	C8B98
	cmp	#$C053,d0
	beq.b	C8BA4
	cmp	#$C044,d0
	beq.b	C8BB0
	cmp	#$C058,d0
	beq.b	C8BBC
	cmp	#$C050,d0
	beq.b	C8BC8
	br	HandleMacroos

C8B80:	moveq	#6,d5
	bra.b	_Asm_FLOG10

C8B8C:	moveq	#4,d5
	bra.b	_Asm_FLOG10

C8B98:	moveq	#0,d5
	bra.b	_Asm_FLOG10

C8BA4:	moveq	#$71,d5
	bra.b	_Asm_FLOG10

C8BB0:	moveq	#$75,d5
	bra.b	_Asm_FLOG10

C8BBC:	moveq	#$72,d5
	bra.b	_Asm_FLOG10

C8BC8:	moveq	#$73,d5
_Asm_FLOG10:
	move.l	#$0015F200,d6
	br	CFB00

C8BD4:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CE54,d0
	beq.b	C8C68
	cmp	#$4E54,d0
	beq.b	C8BEA
	br	HandleMacroos

C8BEA:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D25A,d0
	beq	C8CEE
	cmp	#$525A,d0
	beq.b	C8C80
	cmp	#$C042,d0
	beq.b	C8C2C
	cmp	#$C057,d0
	beq.b	C8C38
	cmp	#$C04C,d0
	beq.b	C8C44
	cmp	#$C053,d0
	beq.b	C8C50
	cmp	#$C044,d0
	beq.b	C8C5C
	cmp	#$C058,d0
	beq.b	C8C68
	cmp	#$C050,d0
	beq.b	C8C74
	br	HandleMacroos

C8C2C:	moveq	#6,d5
	bra.b	_Asm_FINT

C8C38:	moveq	#4,d5
	bra.b	_Asm_FINT

C8C44:	moveq	#0,d5
	bra.b	_Asm_FINT

C8C50:	moveq	#$71,d5
	bra.b	_Asm_FINT

C8C5C:	moveq	#$75,d5
	bra.b	_Asm_FINT

C8C68:	moveq	#$72,d5
	bra.b	_Asm_FINT

C8C74:	moveq	#$73,d5
_Asm_FINT:
	move.l	#$0001F200,d6
	br	CFB00

C8C80:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C042,d0
	beq.b	C8CB2
	cmp	#$C057,d0
	beq.b	C8CBE
	cmp	#$C04C,d0
	beq.b	C8CCA
	cmp	#$C053,d0
	beq.b	C8CD6
	cmp	#$C044,d0
	beq.b	C8CE2
	cmp	#$C058,d0
	beq.b	C8CEE
	cmp	#$C050,d0
	beq.b	C8CFA
	br	HandleMacroos

C8CB2:	moveq	#6,d5
	bra.b	_Asm_FINTRZ

C8CBE:	moveq	#4,d5
	bra.b	_Asm_FINTRZ

C8CCA:	moveq	#0,d5
	bra.b	_Asm_FINTRZ

C8CD6:	moveq	#$71,d5
	bra.b	_Asm_FINTRZ

C8CE2:	moveq	#$75,d5
	bra.b	_Asm_FINTRZ

C8CEE:	moveq	#$72,d5
	bra.b	_Asm_FINTRZ

C8CFA:	moveq	#$73,d5
_Asm_FINTRZ:
	move.l	#$0003F200,d6
	br	CFB00

C8D06:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$4554,d0
	beq.b	C8D14
	br	HandleMacroos

C8D14:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$4558,d0
	beq.b	C8DC4
	cmp	#$4D41,d0
	beq.b	C8D2A
	br	HandleMacroos

C8D2A:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CE00,d0
	beq.b	C8DAC
	cmp	#$4E40,d0
	beq.b	C8D3E
	br	HandleMacroos

C8D3E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C200,d0
	beq.b	C8D70
	cmp	#$D700,d0
	beq.b	C8D7C
	cmp	#$CC00,d0
	beq.b	C8D88
	cmp	#$D300,d0
	beq.b	C8D94
	cmp	#$C400,d0
	beq.b	C8DA0
	cmp	#$D800,d0
	beq.b	C8DAC
	cmp	#$D000,d0
	beq.b	C8DB8
	br	ERROR_Illegalfloating

C8D70:	moveq	#6,d5
	bra.b	_Asm_FGETMAN

C8D7C:	moveq	#4,d5
	bra.b	_Asm_FGETMAN

C8D88:	moveq	#0,d5
	bra.b	_Asm_FGETMAN

C8D94:	moveq	#$71,d5
	bra.b	_Asm_FGETMAN

C8DA0:	moveq	#$75,d5
	bra.b	_Asm_FGETMAN

C8DAC:	moveq	#$72,d5
	bra.b	_Asm_FGETMAN

C8DB8:	moveq	#$73,d5
_Asm_FGETMAN:
	move.l	#$001FF200,d6
	br	Asm_FPopperant

C8DC4:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D000,d0
	beq.b	C8E46
	cmp	#$5040,d0
	beq.b	C8DD8
	br	HandleMacroos

C8DD8:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C200,d0
	beq.b	C8E0A
	cmp	#$D700,d0
	beq.b	C8E16
	cmp	#$CC00,d0
	beq.b	C8E22
	cmp	#$D300,d0
	beq.b	C8E2E
	cmp	#$C400,d0
	beq.b	C8E3A
	cmp	#$D800,d0
	beq.b	C8E46
	cmp	#$D000,d0
	beq.b	C8E52
	br	ERROR_Illegalfloating

C8E0A:	moveq	#6,d5
	bra.b	_Asm_FGETEXP

C8E16:	moveq	#4,d5
	bra.b	_Asm_FGETEXP

C8E22:	moveq	#0,d5
	bra.b	_Asm_FGETEXP

C8E2E:	moveq	#$71,d5
	bra.b	_Asm_FGETEXP

C8E3A:	moveq	#$75,d5
	bra.b	_Asm_FGETEXP

C8E46:	moveq	#$72,d5
	bra.b	_Asm_FGETEXP

C8E52:	moveq	#$73,d5
_Asm_FGETEXP:
	move.l	#$001EF200,d6
	br	Asm_FPopperant

C8E5E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$544F,d0
	beq.b	C8E6C
	br	HandleMacroos

C8E6C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D800,d0
	beq	C8F92
	cmp	#$5840,d0
	beq.b	C8F24
	cmp	#$584D,d0
	beq.b	C8E8A
	br	HandleMacroos

C8E8A:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$9100,d0
	beq.b	C8F0C
	cmp	#$1140,d0
	beq.b	C8E9E
	br	HandleMacroos

C8E9E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C200,d0
	beq.b	C8ED0
	cmp	#$D700,d0
	beq.b	C8EDC
	cmp	#$CC00,d0
	beq.b	C8EE8
	cmp	#$D300,d0
	beq.b	C8EF4
	cmp	#$C400,d0
	beq.b	C8F00
	cmp	#$D800,d0
	beq.b	C8F0C
	cmp	#$D000,d0
	beq.b	C8F18
	br	ERROR_Illegalfloating

C8ED0:	moveq	#6,d5
	bra.b	_Asm_FETOXM1

C8EDC:	moveq	#4,d5
	bra.b	_Asm_FETOXM1

C8EE8:	moveq	#0,d5
	bra.b	_Asm_FETOXM1

C8EF4:	moveq	#$71,d5
	bra.b	_Asm_FETOXM1

C8F00:	moveq	#$75,d5
	bra.b	_Asm_FETOXM1

C8F0C:	moveq	#$72,d5
	bra.b	_Asm_FETOXM1

C8F18:	moveq	#$73,d5
_Asm_FETOXM1:
	move.l	#$0008F200,d6
	br	CFB00

C8F24:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C200,d0
	beq.b	C8F56
	cmp	#$D700,d0
	beq.b	C8F62
	cmp	#$CC00,d0
	beq.b	C8F6E
	cmp	#$D300,d0
	beq.b	C8F7A
	cmp	#$C400,d0
	beq.b	C8F86
	cmp	#$D800,d0
	beq.b	C8F92
	cmp	#$D000,d0
	beq.b	C8F9E
	br	ERROR_Illegalfloating

C8F56:	moveq	#6,d5
	bra.b	_Asm_FETOX

C8F62:	moveq	#4,d5
	bra.b	_Asm_FETOX

C8F6E:	moveq	#0,d5
	bra.b	_Asm_FETOX

C8F7A:	moveq	#$71,d5
	bra.b	_Asm_FETOX

C8F86:	moveq	#$75,d5
	bra.b	_Asm_FETOX

C8F92:	moveq	#$72,d5
	bra.b	_Asm_FETOX

C8F9E:	moveq	#$73,d5
_Asm_FETOX:
	move.l	#$0010F200,d6
	br	CFB00

AsmFD:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C956,d0
	beq	C9076
	cmp	#'IV',d0
	beq.b	AsmFDIV
	cmp	#$C246,d0
	beq	C908E
	cmp	#$4245,d0
	beq	C90A2
	cmp	#$424F,d0
	beq	C90BA
	cmp	#$4255,d0
	beq	C9122
	cmp	#$424E,d0
	beq	C918A
	cmp	#$C254,d0
	beq.b	C9098
	cmp	#$4253,d0
	beq	C9210
	cmp	#$4247,d0
	beq	C9258
	cmp	#$424C,d0
	beq	C92A2
	br	HandleMacroos

AsmFDIV:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C042,d0
	beq.b	Asm_FDIVB
	cmp	#$C057,d0
	beq.b	Asm_FDIVW
	cmp	#$C04C,d0
	beq.b	Asm_FDIVL
	cmp	#$C053,d0
	beq.b	C905E
	cmp	#$C044,d0
	beq.b	C906A
	cmp	#$C058,d0
	beq.b	C9076
	cmp	#$C050,d0
	beq.b	C9082
	br	ERROR_Illegalfloating

Asm_FDIVB:
	moveq	#6,d5
	bra.b	_Asm_FDIV

Asm_FDIVW:
	moveq	#4,d5
	bra.b	_Asm_FDIV

Asm_FDIVL:
	moveq	#0,d5
	bra.b	_Asm_FDIV

C905E:	moveq	#$71,d5
	bra.b	_Asm_FDIV

C906A:	moveq	#$75,d5
	bra.b	_Asm_FDIV

C9076:	moveq	#$72,d5
	bra.b	_Asm_FDIV

C9082:	moveq	#$73,d5
_Asm_FDIV:
	move.l	#$0020F200,d6
	br	Asm_FPopperant

C908E:	move.l	#$0000F248,d6
	br	CFAD8

C9098:	move.l	#$000FF248,d6
	br	CFAD8

C90A2:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D100,d0
	beq.b	C90B0
	br	HandleMacroos

C90B0:	move.l	#$0001F248,d6
	br	CFAD8

C90BA:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C754,d0
	beq.b	C90E6
	cmp	#$C745,d0
	beq.b	C90F0
	cmp	#$CC54,d0
	beq.b	C90FA
	cmp	#$CC45,d0
	beq.b	C9104
	cmp	#$C74C,d0
	beq.b	C910E
	cmp	#$D200,d0
	beq.b	C9118
	br	HandleMacroos

C90E6:	move.l	#$0002F248,d6
	br	CFAD8

C90F0:	move.l	#$0003F248,d6
	br	CFAD8

C90FA:	move.l	#$0004F248,d6
	br	CFAD8

C9104:	move.l	#$0005F248,d6
	br	CFAD8

C910E:	move.l	#$0006F248,d6
	br	CFAD8

C9118:	move.l	#$0007F248,d6
	br	CFAD8

C9122:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CE00,d0
	beq.b	C914E
	cmp	#$C551,d0
	beq.b	C9158
	cmp	#$C754,d0
	beq.b	C9162
	cmp	#$C745,d0
	beq.b	C916C
	cmp	#$CC54,d0
	beq.b	C9176
	cmp	#$CC45,d0
	beq.b	C9180
	br	HandleMacroos

C914E:	move.l	#$0008F248,d6
	br	CFAD8

C9158:	move.l	#$0009F248,d6
	br	CFAD8

C9162:	move.l	#$000AF248,d6
	br	CFAD8

C916C:	move.l	#$000BF248,d6
	br	CFAD8

C9176:	move.l	#$000CF248,d6
	br	CFAD8

C9180:	move.l	#$000DF248,d6
	br	CFAD8

C918A:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C500,d0
	beq.b	C9206
	cmp	#$474C,d0
	beq.b	C91EE
	cmp	#$C74C,d0
	beq.b	C91BC
	cmp	#$CC45,d0
	beq.b	C91C6
	cmp	#$CC54,d0
	beq.b	C91D0
	cmp	#$C745,d0
	beq.b	C91DA
	cmp	#$C754,d0
	beq.b	C91E4
	br	HandleMacroos

C91BC:	move.l	#$0019F248,d6
	br	CFAD8

C91C6:	move.l	#$001AF248,d6
	br	CFAD8

C91D0:	move.l	#$001BF248,d6
	br	CFAD8

C91DA:	move.l	#$001CF248,d6
	br	CFAD8

C91E4:	move.l	#$001DF248,d6
	br	CFAD8

C91EE:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C500,d0
	beq.b	C91FC
	br	HandleMacroos

C91FC:	move.l	#$0018F248,d6
	br	CFAD8

C9206:	move.l	#$000EF248,d6
	br	CFAD8

C9210:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C600,d0
	beq.b	C9230
	cmp	#$D400,d0
	beq.b	C923A
	cmp	#$C551,d0
	beq.b	C9244
	cmp	#$CE45,d0
	beq.b	C924E
	br	HandleMacroos

C9230:	move.l	#$0010F248,d6
	br	CFAD8

C923A:	move.l	#$001FF248,d6
	br	CFAD8

C9244:	move.l	#$0011F248,d6
	br	CFAD8

C924E:	move.l	#$001EF248,d6
	br	CFAD8

C9258:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D400,d0
	beq.b	C927A
	cmp	#$C500,d0
	beq.b	C9284
	cmp	#$CC00,d0
	beq.b	C928E
	cmp	#$CC45,d0
	beq.b	C9298
	br	HandleMacroos

C927A:	move.l	#$0012F248,d6
	br	CFAD8

C9284:	move.l	#$0013F248,d6
	br	CFAD8

C928E:	move.l	#$0016F248,d6
	br	CFAD8

C9298:	move.l	#$0017F248,d6
	br	CFAD8

C92A2:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D400,d0
	beq.b	C92B6
	cmp	#$C500,d0
	beq.b	C92C0
	br	HandleMacroos

C92B6:	move.l	#$0014F248,d6
	br	CFAD8

C92C0:	move.l	#$0015F248,d6
	br	CFAD8

C92CA:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CD50,d0
	beq	C947A
	cmp	#$4D50,d0
	beq	C940C
	cmp	#$CF53,d0
	beq.b	C936E
	cmp	#$4F53,d0
	beq.b	C92F0
	br	HandleMacroos

C92F0:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$4840,d0
	beq.b	C9386
	cmp	#$C800,d0
	beq	C93F4
	cmp	#$C042,d0
	beq.b	C9332
	cmp	#$C057,d0
	beq.b	C933E
	cmp	#$C04C,d0
	beq.b	C934A
	cmp	#$C053,d0
	beq.b	C9356
	cmp	#$C044,d0
	beq.b	C9362
	cmp	#$C058,d0
	beq.b	C936E
	cmp	#$C050,d0
	beq.b	C937A
	br	ERROR_Illegalfloating

C9332:	moveq	#6,d5
	bra.b	_Asm_FCOS

C933E:	moveq	#4,d5
	bra.b	_Asm_FCOS

C934A:	moveq	#0,d5
	bra.b	_Asm_FCOS

C9356:	moveq	#$71,d5
	bra.b	_Asm_FCOS

C9362:	moveq	#$75,d5
	bra.b	_Asm_FCOS

C936E:	moveq	#$72,d5
	bra.b	_Asm_FCOS

C937A:	moveq	#$73,d5
_Asm_FCOS:
	move.l	#$001DF200,d6
	br	CFB00

C9386:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C200,d0
	beq.b	C93B8
	cmp	#$D700,d0
	beq.b	C93C4
	cmp	#$CC00,d0
	beq.b	C93D0
	cmp	#$D300,d0
	beq.b	C93DC
	cmp	#$C400,d0
	beq.b	C93E8
	cmp	#$D800,d0
	beq.b	C93F4
	cmp	#$D000,d0
	beq.b	C9400
	br	ERROR_Illegalfloating

C93B8:	moveq	#6,d5
	bra.b	_Asm_FCOSH

C93C4:	moveq	#4,d5
	bra.b	_Asm_FCOSH

C93D0:	moveq	#0,d5
	bra.b	_Asm_FCOSH

C93DC:	moveq	#$71,d5
	bra.b	_Asm_FCOSH

C93E8:	moveq	#$75,d5
	bra.b	_Asm_FCOSH

C93F4:	moveq	#$72,d5
	bra.b	_Asm_FCOSH

C9400:	moveq	#$73,d5
_Asm_FCOSH:
	move.l	#$0019F200,d6
	br	CFB00

C940C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C042,d0
	beq.b	C943E
	cmp	#$C057,d0
	beq.b	C944A
	cmp	#$C04C,d0
	beq.b	C9456
	cmp	#$C053,d0
	beq.b	C9462
	cmp	#$C044,d0
	beq.b	C946E
	cmp	#$C058,d0
	beq.b	C947A
	cmp	#$C050,d0
	beq.b	C9486
	br	ERROR_Illegalfloating

C943E:	moveq	#6,d5
	bra.b	_Asm_FCMP

C944A:	moveq	#4,d5
	bra.b	_Asm_FCMP

C9456:	moveq	#0,d5
	bra.b	_Asm_FCMP

C9462:	moveq	#$71,d5
	bra.b	_Asm_FCMP

C946E:	moveq	#$75,d5
	bra.b	_Asm_FCMP

C947A:	moveq	#$72,d5
	bra.b	_Asm_FCMP

C9486:	moveq	#$73,d5
_Asm_FCMP:
	move.l	#$0038F200,d6
	br	Asm_FPopperant

C9492:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C551,d0
	beq	C9B0C
	cmp	#$4551,d0
	beq	C9AF8
	cmp	#$CE45,d0
	beq	C9AE8
	cmp	#$4E45,d0
	beq	C9AD4
	cmp	#$4F47,d0
	beq	C9A36
	cmp	#$4F4C,d0
	beq	C99CE
	cmp	#$4F52,d0
	beq	C99AA
	cmp	#$CF52,d0
	beq	C99BE
	cmp	#$C600,d0
	beq	C9B30
	cmp	#$4640,d0
	beq	C9B1C
	cmp	#$D400,d0
	beq	C9B54
	cmp	#$5440,d0
	beq	C9B40
	cmp	#$554E,d0
	beq	C9986
	cmp	#$D54E,d0
	beq	C999A
	cmp	#$5545,d0
	beq	C994E
	cmp	#$5547,d0
	beq	C98E6
	cmp	#$554C,d0
	beq	C987E
	cmp	#$D346,d0
	beq	C986E
	cmp	#$5346,d0
	beq	C985A
	cmp	#$5345,d0
	beq	C963C
	cmp	#$C754,d0
	beq	C962C
	cmp	#$4754,d0
	beq	C9618
	cmp	#$C745,d0
	beq	C9608
	cmp	#$4745,d0
	beq	C95F4
	cmp	#$CC54,d0
	beq	C95E4
	cmp	#$4C54,d0
	beq.b	C95D0
	cmp	#$CC45,d0
	beq.b	C95C0
	cmp	#$4C45,d0
	beq.b	C95AC
	cmp	#$C74C,d0
	beq	C9694
	cmp	#$474C,d0
	beq	C9674
	cmp	#$4E47,d0
	beq	C96C8
	cmp	#$4E4C,d0
	beq	C9796
	cmp	#$534E,d0
	beq	C97FE
	cmp	#$D354,d0
	beq	C984A
	cmp	#$5354,d0
	beq	C9836
	br	HandleMacroos

C95AC:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C95C0
	cmp	#$C04C,d0
	beq.b	C95C8
	br	ERROR_IllegalSize

C95C0:	move	#$F295,d6
	br	C10682

C95C8:	move	#$F2D5,d6
	br	asmbl_BraL

C95D0:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C95E4
	cmp	#$C04C,d0
	beq.b	C95EC
	br	ERROR_IllegalSize

C95E4:	move	#$F294,d6
	br	C10682

C95EC:	move	#$F2D4,d6
	br	asmbl_BraL

C95F4:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C9608
	cmp	#$C04C,d0
	beq.b	C9610
	br	ERROR_IllegalSize

C9608:	move	#$F293,d6
	br	C10682

C9610:	move	#$F2D3,d6
	br	asmbl_BraL

C9618:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C962C
	cmp	#$C04C,d0
	beq.b	C9634
	br	ERROR_IllegalSize

C962C:	move	#$F292,d6
	br	C10682

C9634:	move	#$F2D2,d6
	br	asmbl_BraL

C963C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D100,d0
	beq.b	C9664
	cmp	#$5140,d0
	beq.b	C9650
	br	HandleMacroos

C9650:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C9664
	cmp	#$CC00,d0
	beq.b	C966C
	br	ERROR_IllegalSize

C9664:	move	#$F291,d6
	br	C10682

C966C:	move	#$F2D1,d6
	br	asmbl_BraL

C9674:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C9694
	cmp	#$C04C,d0
	beq.b	C969C
	cmp	#$C500,d0
	beq.b	C96B8
	cmp	#$4540,d0
	beq.b	C96A4
	br	HandleMacroos

C9694:	move	#$F296,d6
	br	C10682

C969C:	move	#$F2D6,d6
	br	asmbl_BraL

C96A4:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C96B8
	cmp	#$CC00,d0
	beq.b	C96C0
	br	ERROR_IllegalSize

C96B8:	move	#$F297,d6
	br	C10682

C96C0:	move	#$F2D7,d6
	br	asmbl_BraL

C96C8:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CC45,d0
	beq	C9762
	cmp	#$4C45,d0
	beq.b	C974E
	cmp	#$CC00,d0
	beq	C9786
	cmp	#$4C40,d0
	beq	C9772
	cmp	#$5440,d0
	beq.b	C9706
	cmp	#$D400,d0
	beq.b	C971A
	cmp	#$4540,d0
	beq.b	C972A
	cmp	#$C500,d0
	beq.b	C973E
	br	HandleMacroos

C9706:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C971A
	cmp	#$CC00,d0
	beq.b	C9722
	br	ERROR_IllegalSize

C971A:	move	#$F29D,d6
	br	C10682

C9722:	move	#$F2DD,d6
	br	asmbl_BraL

C972A:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C973E
	cmp	#$CC00,d0
	beq.b	C9746
	br	ERROR_IllegalSize

C973E:	move	#$F29C,d6
	br	C10682

C9746:	move	#$F2DC,d6
	br	asmbl_BraL

C974E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C9762
	cmp	#$C04C,d0
	beq.b	C976A
	br	ERROR_IllegalSize

C9762:	move	#$F298,d6
	br	C10682

C976A:	move	#$F2D8,d6
	br	asmbl_BraL

C9772:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C9786
	cmp	#$CC00,d0
	beq.b	C978E
	br	ERROR_IllegalSize

C9786:	move	#$F299,d6
	br	C10682

C978E:	move	#$F2D9,d6
	br	asmbl_BraL

C9796:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C500,d0
	beq.b	C97CA
	cmp	#$4540,d0
	beq.b	C97B6
	cmp	#$D400,d0
	beq.b	C97EE
	cmp	#$5440,d0
	beq.b	C97DA
	br	HandleMacroos

C97B6:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C97CA
	cmp	#$CC00,d0
	beq.b	C97D2
	br	ERROR_IllegalSize

C97CA:	move	#$F29A,d6
	br	C10682

C97D2:	move	#$F2DA,d6
	br	asmbl_BraL

C97DA:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C97EE
	cmp	#$CC00,d0
	beq.b	C97F6
	br	ERROR_IllegalSize

C97EE:	move	#$F29B,d6
	br	C10682

C97F6:	move	#$F2DB,d6
	br	asmbl_BraL

C97FE:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C500,d0
	beq.b	C9826
	cmp	#$4540,d0
	beq.b	C9812
	br	HandleMacroos

C9812:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C9826
	cmp	#$CC00,d0
	beq.b	C982E
	br	ERROR_IllegalSize

C9826:	move	#$F29E,d6
	br	C10682

C982E:	move	#$F2DE,d6
	br	asmbl_BraL

C9836:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C984A
	cmp	#$C04C,d0
	beq.b	C9852
	br	ERROR_IllegalSize

C984A:	move	#$F29F,d6
	br	C10682

C9852:	move	#$F2DF,d6
	br	asmbl_BraL

C985A:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C986E
	cmp	#$C04C,d0
	beq.b	C9876
	br	HandleMacroos

C986E:	move	#$F290,d6
	br	C10682

C9876:	move	#$F2D0,d6
	br	asmbl_BraL

C987E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$5440,d0
	beq.b	C98C2
	cmp	#$D400,d0
	beq.b	C98D6
	cmp	#$4540,d0
	beq.b	C989E
	cmp	#$C500,d0
	beq.b	C98B2
	br	HandleMacroos

C989E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C98B2
	cmp	#$CC00,d0
	beq.b	C98BA
	br	HandleMacroos

C98B2:	move	#$F28D,d6
	br	C10682

C98BA:	move	#$F2CD,d6
	br	asmbl_BraL

C98C2:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C98D6
	cmp	#$CC00,d0
	beq.b	C98DE
	br	HandleMacroos

C98D6:	move	#$F28C,d6
	br	C10682

C98DE:	move	#$F2CC,d6
	br	asmbl_BraL

C98E6:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$5440,d0
	beq.b	C992A
	cmp	#$D400,d0
	beq.b	C993E
	cmp	#$4540,d0
	beq.b	C9906
	cmp	#$C500,d0
	beq.b	C991A
	br	HandleMacroos

C9906:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C991A
	cmp	#$CC00,d0
	beq.b	C9922
	br	HandleMacroos

C991A:	move	#$F28B,d6
	br	C10682

C9922:	move	#$F2CB,d6
	br	asmbl_BraL

C992A:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C993E
	cmp	#$CC00,d0
	beq.b	C9946
	br	HandleMacroos

C993E:	move	#$F28A,d6
	br	C10682

C9946:	move	#$F2CA,d6
	br	asmbl_BraL

C994E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$5140,d0
	beq.b	C9962
	cmp	#$D100,d0
	beq.b	C9976
	br	HandleMacroos

C9962:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C9976
	cmp	#$CC00,d0
	beq.b	C997E
	br	HandleMacroos

C9976:	move	#$F289,d6
	br	C10682

C997E:	move	#$F2C9,d6
	br	asmbl_BraL

C9986:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C999A
	cmp	#$C04C,d0
	beq.b	C99A2
	br	HandleMacroos

C999A:	move	#$F288,d6
	br	C10682

C99A2:	move	#$F2C8,d6
	br	asmbl_BraL

C99AA:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C99BE
	cmp	#$C04C,d0
	beq.b	C99C6
	br	HandleMacroos

C99BE:	move	#$F287,d6
	br	C10682

C99C6:	move	#$F2C7,d6
	br	asmbl_BraL

C99CE:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D400,d0
	beq.b	C9A02
	cmp	#$5440,d0
	beq.b	C99EE
	cmp	#$C500,d0
	beq.b	C9A26
	cmp	#$4540,d0
	beq.b	C9A12
	br	HandleMacroos

C99EE:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C9A02
	cmp	#$CC00,d0
	beq.b	C9A0A
	br	HandleMacroos

C9A02:	move	#$F284,d6
	br	C10682

C9A0A:	move	#$F2C4,d6
	br	asmbl_BraL

C9A12:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C9A26
	cmp	#$CC00,d0
	beq.b	C9A2E
	br	HandleMacroos

C9A26:	move	#$F285,d6
	br	C10682

C9A2E:	move	#$F2C5,d6
	br	asmbl_BraL

C9A36:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D400,d0
	beq.b	C9A7C
	cmp	#$C500,d0
	beq.b	C9AA0
	cmp	#$CC00,d0
	beq.b	C9AC4
	cmp	#$5440,d0
	beq.b	C9A68
	cmp	#$4540,d0
	beq.b	C9A8C
	cmp	#$4C40,d0
	beq.b	C9AB0
	br	HandleMacroos

C9A68:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C9A7C
	cmp	#$CC00,d0
	beq.b	C9A84
	br	HandleMacroos

C9A7C:	move	#$F282,d6
	br	C10682

C9A84:	move	#$F2C2,d6
	br	asmbl_BraL

C9A8C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C9AA0
	cmp	#$CC00,d0
	beq.b	C9AA8
	br	HandleMacroos

C9AA0:	move	#$F283,d6
	br	C10682

C9AA8:	move	#$F2C3,d6
	br	asmbl_BraL

C9AB0:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C9AC4
	cmp	#$CC00,d0
	beq.b	C9ACC
	br	HandleMacroos

C9AC4:	move	#$F286,d6
	br	C10682

C9ACC:	move	#$F2C6,d6
	br	asmbl_BraL

C9AD4:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C9AE8
	cmp	#$C04C,d0
	beq.b	C9AF0
	br	HandleMacroos

C9AE8:	move	#$F28E,d6
	br	C10682

C9AF0:	move	#$F2CE,d6
	br	asmbl_BraL

C9AF8:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C9B0C
	cmp	#$C04C,d0
	beq.b	C9B14
	br	HandleMacroos

C9B0C:	move	#$F281,d6
	br	C10682

C9B14:	move	#$F2C1,d6
	br	asmbl_BraL

C9B1C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C9B30
	cmp	#$CC00,d0
	beq.b	C9B38
	br	HandleMacroos

C9B30:	move	#$F280,d6
	br	C10682

C9B38:	move	#$F2C0,d6
	br	asmbl_BraL

C9B40:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C9B54
	cmp	#$CC00,d0
	beq.b	C9B5C
	br	HandleMacroos

C9B54:	move	#$F28F,d6
	br	C10682

C9B5C:	move	#$F2CF,d6
	br	asmbl_BraL

C9B64:	; FA
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C94C,d0
	beq	ERROR_UsermadeFAIL
	cmp	#$C253,d0
	beq	C9F0C
	cmp	#$4253,d0
	beq	C9E9E
	cmp	#$434F,d0
	beq	C9E04
	cmp	#$C444,d0
	beq	C9DEC
	cmp	#$4444,d0
	beq	C9D7E
	cmp	#$5349,d0
	beq	C9CE0
	cmp	#$5441,d0
	beq.b	C9BAA
	br	HandleMacroos

C9BAA:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CE00,d0
	beq	C9CC8
	cmp	#$4E40,d0
	beq.b	C9C58
	cmp	#$CE48,d0
	beq.b	C9C40
	cmp	#$4E48,d0
	beq.b	C9BD0
	br	HandleMacroos

C9BD0:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C042,d0
	beq.b	C9C04
	cmp	#$C057,d0
	beq.b	C9C10
	cmp	#$C04C,d0
	beq.b	C9C1C
	cmp	#$C053,d0
	beq.b	C9C28
	cmp	#$C044,d0
	beq.b	C9C34
	cmp	#$C058,d0
	beq.b	C9C40
	cmp	#$C050,d0
	beq.b	C9C4C
	br	HandleMacroos

C9C04:	moveq	#6,d5
	bra.b	_Asm_ATANH

C9C10:	moveq	#4,d5
	bra.b	_Asm_ATANH

C9C1C:	moveq	#0,d5
	bra.b	_Asm_ATANH

C9C28:	moveq	#$71,d5
	bra.b	_Asm_ATANH

C9C34:	moveq	#$75,d5
	bra.b	_Asm_ATANH

C9C40:	moveq	#$72,d5
	bra.b	_Asm_ATANH

C9C4C:	moveq	#$73,d5
_Asm_ATANH:
	move.l	#$000DF200,d6
	br	CFB00

C9C58:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C200,d0
	beq.b	C9C8C
	cmp	#$D700,d0
	beq.b	C9C98
	cmp	#$CC00,d0
	beq.b	C9CA4
	cmp	#$D300,d0
	beq.b	C9CB0
	cmp	#$C400,d0
	beq.b	C9CBC
	cmp	#$D800,d0
	beq.b	C9CC8
	cmp	#$D000,d0
	beq.b	C9CD4
	br	ERROR_Illegalfloating

C9C8C:	moveq	#6,d5
	bra.b	_Asm_ATAN

C9C98:	moveq	#4,d5
	bra.b	_Asm_ATAN

C9CA4:	moveq	#0,d5
	bra.b	_Asm_ATAN

C9CB0:	moveq	#$71,d5
	bra.b	_Asm_ATAN

C9CBC:	moveq	#$75,d5
	bra.b	_Asm_ATAN

C9CC8:	moveq	#$72,d5
	bra.b	_Asm_ATAN

C9CD4:	moveq	#$73,d5
_Asm_ATAN:
	move.l	#$000AF200,d6
	br	CFB00

C9CE0:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CE00,d0
	beq.b	C9D66
	cmp	#$4E40,d0
	beq.b	C9CF6
	br	HandleMacroos

C9CF6:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C200,d0
	beq.b	C9D2A
	cmp	#$D700,d0
	beq.b	C9D36
	cmp	#$CC00,d0
	beq.b	C9D42
	cmp	#$D300,d0
	beq.b	C9D4E
	cmp	#$C400,d0
	beq.b	C9D5A
	cmp	#$D800,d0
	beq.b	C9D66
	cmp	#$D000,d0
	beq.b	C9D72
	br	ERROR_Illegalfloating

C9D2A:	moveq	#6,d5
	bra.b	_Asm_ASIN

C9D36:	moveq	#4,d5
	bra.b	_Asm_ASIN

C9D42:	moveq	#0,d5
	bra.b	_Asm_ASIN

C9D4E:	moveq	#$71,d5
	bra.b	_Asm_ASIN

C9D5A:	moveq	#$75,d5
	bra.b	_Asm_ASIN

C9D66:	moveq	#$72,d5
	bra.b	_Asm_ASIN

C9D72:	moveq	#$73,d5
_Asm_ASIN:
	move.l	#$000CF200,d6
	br	CFB00

C9D7E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C042,d0
	beq.b	C9DB0
	cmp	#$C057,d0
	beq.b	C9DBC
	cmp	#$C04C,d0
	beq.b	C9DC8
	cmp	#$C053,d0
	beq.b	C9DD4
	cmp	#$C044,d0
	beq.b	C9DE0
	cmp	#$C058,d0
	beq.b	C9DEC
	cmp	#$C050,d0
	beq.b	C9DF8
	br	HandleMacroos

C9DB0:	moveq	#6,d5
	bra.b	_Asm_FADD

C9DBC:	moveq	#4,d5
	bra.b	_Asm_FADD

C9DC8:	moveq	#0,d5
	bra.b	_Asm_FADD

C9DD4:
	moveq	#$71,d5
	bra.b	_Asm_FADD

C9DE0:	moveq	#$75,d5
	bra.b	_Asm_FADD

C9DEC:	moveq	#$72,d5
	bra.b	_Asm_FADD

C9DF8:	moveq	#$73,d5
_Asm_FADD:
	move.l	#$0022F200,d6
	br	Asm_FPopperant

C9E04:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D300,d0
	beq.b	C9E86
	cmp	#$5340,d0
	beq.b	C9E18
	br	HandleMacroos

C9E18:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C200,d0
	beq.b	C9E4A
	cmp	#$D700,d0
	beq.b	C9E56
	cmp	#$CC00,d0
	beq.b	C9E62
	cmp	#$D300,d0
	beq.b	C9E6E
	cmp	#$C400,d0
	beq.b	C9E7A
	cmp	#$D800,d0
	beq.b	C9E86
	cmp	#$D000,d0
	beq.b	C9E92
	br	ERROR_Illegalfloating

C9E4A:	moveq	#6,d5
	bra.b	_Asm_ACOS

C9E56:	moveq	#4,d5
	bra.b	_Asm_ACOS

C9E62:	moveq	#0,d5
	bra.b	_Asm_ACOS

C9E6E:	moveq	#$71,d5
	bra.b	_Asm_ACOS

C9E7A:	moveq	#$75,d5
	bra.b	_Asm_ACOS

C9E86:	moveq	#$72,d5
	bra.b	_Asm_ACOS

C9E92:	moveq	#$73,d5
_Asm_ACOS:
	move.l	#$001CF200,d6
	br	CFB00

C9E9E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C042,d0
	beq.b	C9ED0
	cmp	#$C057,d0
	beq.b	C9EDC
	cmp	#$C04C,d0
	beq.b	C9EE8
	cmp	#$C053,d0
	beq.b	C9EF4
	cmp	#$C044,d0
	beq.b	C9F00
	cmp	#$C058,d0
	beq.b	C9F0C
	cmp	#$C050,d0
	beq.b	C9F18
	br	ERROR_Illegalfloating

C9ED0:	moveq	#6,d5
	bra.b	_Asm_FABS

C9EDC:	moveq	#4,d5
	bra.b	_Asm_FABS

C9EE8:	moveq	#0,d5
	bra.b	_Asm_FABS

C9EF4:	moveq	#$71,d5
	bra.b	_Asm_FABS

C9F00:	moveq	#$75,d5
	bra.b	_Asm_FABS

C9F0C:	moveq	#$72,d5
	bra.b	_Asm_FABS

C9F18:	moveq	#$73,d5
_Asm_FABS:
	move.l	#$0018F200,d6
_CFB00:
	br	CFB00

AsmG:
	cmp	#'GL',d0
	beq.b	C9F3C
	br	HandleMacroos

C9F3C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"OB",d0
	beq.b	C9F4A
	br	HandleMacroos

C9F4A:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CC00,d0
	beq	CD778
	cmp	#"AL"+$8000,d0
	beq	CD778
	br	HandleMacroos

;************* H *************************

AsmH:
	cmp.w	#'HA',d0
	bne.w	HandleMacroos

	move.w	(a3)+,d0
	and	d4,d0
	cmp.w	#"LT"!$8000,d0
	bne.w	HandleMacroos

	move.w	#$4AC8,d6	;HALT
	move	#$8040,d5	;no size
	bra	Asm_HaltPulse

;************* I *************************

AsmI:
	cmp	#"IF"+$8000,d0
	beq	ASSEM_CMDIFNE
	cmp	#'IF',d0
	beq	CA078
	cmp	#"IN",d0	;IN clude iff bin 
	beq.b	AsmINstuff
	cmp	#"IL",d0	;IL 
	beq	CA042
	cmp	#"IM",d0	;IM 
	beq.b	C9F90
	cmp	#"ID",d0	;ID 
	beq.b	C9FAE
	br	HandleMacroos

C9F90:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"AG",d0
	beq.b	C9F9E
	br	HandleMacroos

C9F9E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C500,d0
	beq	IncBinStuff
	br	HandleMacroos

C9FAE:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"NT"+$8000,d0
	beq	ASSEM_CMDIDNT
	br	HandleMacroos

AsmINstuff:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"CL",d0	;inCL[ude|link]
	beq.b	CA014
	cmp	#"CD",d0	;inCDir
	beq.w	CA032
	cmp	#"CB",d0	;inCBin
	beq.b	CA004
	cmp	#"CS",d0	;inCSource
	beq.b	C9FF4
	cmp	#"CI",d0	;inCIff
	beq.b	AsmIncIFF
	br	HandleMacroos

;*********** INC IFF STUFF *************

AsmIncIFF:
	move	(a3)+,d0
	AND	d4,d0
	cmp	#"FF"+$8000,d0	;inciFF
	beq	AsmIncIFFOK
	cmp	#"FF",d0	;inciFFp
	BEQ.S	checkINCIFFP
	br	HandleMacroos

checkINCIFFP:
	move	(A3)+,D0
	AND	D4,D0
	cmp	#$5000!$8000,D0	;INCIFFP
	bne.s	.no2
	jmp	IncIFFPal
.no2:
	cmp	#$5300!$8000,D0	;INCIFFS alleen body van iff picture
	bne.s	.no
	jmp	IncIFFStrip
.no:
	bra	HandleMacroos

;***************************************

C9FF4:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D243,d0
	bne	HandleMacroos
	br	Asm_INCSRC

CA004:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C94E,d0
	beq	IncBinStuff
	br	HandleMacroos

CA014:
	move	(a3)+,d0
	and	d4,d0
	cmp	#'UD',d0
	beq.b	check_INCLUD
	IF	INCLINK
	cmp	#'IN',d0
	beq.b	check_INCLIN
	ENDIF
	br	HandleMacroos

check_INCLUD:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C500,d0	;includE
	beq	Asm_Include
	br	HandleMacroos

	IF	INCLINK
check_INCLIN:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CB00,d0	;inclinK
	beq	Asm_IncLink
	br	HandleMacroos
	ENDIF

CA032:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C952,d0
	beq	Asm_INCDIR
	br	HandleMacroos

CA042:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$4C45,d0
	beq.b	CA050
	br	HandleMacroos

CA050:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$4741,d0
	beq.b	CA05E
	br	HandleMacroos

CA05E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CC00,d0
	beq.b	CA06C
	br	HandleMacroos

CA06C:
	move	#$4AFC,d6
	move	#$8040,d5
	br	Asm_InsertinstrA5

CA078:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CE45,d0	;IFNE
	beq	ASSEM_CMDIFNE
	cmp	#$CE44,d0	;IFND
	beq	ASSEM_CMDIFND
	cmp	#$CE43,d0	;IFNC
	beq	ASSEM_CMDIFNC
	cmp	#$CE42,d0	;IFNB
	beq	ASSEM_CMDIFNB
	cmp	#$CC54,d0	;IFLT
	beq	ASSEM_CMDIFLT
	cmp	#$CC45,d0	;IFLE
	beq	ASSEM_CMDIFLE
	cmp	#$C754,d0	;IFGT
	beq	ASSEM_CMDIFGT
	cmp	#$C745,d0	;IFGE
	beq	ASSEM_CMDIFGE
	cmp	#$C551,d0	;IFEQ
	beq	ASSEM_CMDIFEQ
	cmp	#$C400,d0	;IFD
	beq	ASSEM_CMDIFD
	cmp	#$C300,d0	;IFC
	beq	ASSEM_CMDIFC
	cmp	#$C200,d0	;IFB
	beq	ASSEM_CMDIFB
	cmp	#$9200,d0	;IF2
	beq	ASSEM_CMDIF2
	cmp	#$9100,d0	;IF1
	beq	ASSEM_CMDIF1
	br	HandleMacroos

AsmJ:
	cmp	#'JS',d0
	beq.b	Asm_JS
	cmp	#'JM',d0
	beq.b	Asm_JM
	cmp	#'JU',d0
	beq.b	CA106
	br	HandleMacroos

CA106:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"MP",d0
	beq.b	CA114
	br	HandleMacroos

CA114:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"PT",d0
	beq.b	CA138
	cmp	#"ER",d0
	beq.b	CA128
	br	HandleMacroos

CA128:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D200,d0
	beq	CD6D8
	br	HandleMacroos

CA138:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D200,d0
	beq	CD6D0
	br	HandleMacroos

Asm_JS:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D200,d0
	beq.b	Asm_JSR
	br	HandleMacroos

Asm_JM:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D000,d0
	beq.b	Asm_JMP
	br	HandleMacroos

Asm_JSR:
	move	#$4E80,d6
	move	#$8040,d5
	br	Asm_CmdJmpJsrPea

Asm_JMP:
	move	#$4EC0,d6
	move	#$8040,d5
	br	Asm_CmdJmpJsrPea


;************* L *************************

AsmL:
	cmp	#'LE',d0
	beq.b	Asm_LE
	cmp	#'LS',d0
	beq.w	CA1F0
	cmp	#'LI',d0
	beq	CA29C
	cmp	#'LO',d0
	beq	CA330
	cmp	#'LL',d0
	beq.b	CA1A2
	cmp.w	#'LP',d0
	beq.s	asm_lpstop1
	br	HandleMacroos

asm_lpstop1:
	move	(a3)+,d0
	and	d4,d0
	cmp	#'ST',d0
	bne	HandleMacroos
	move	(a3)+,d0
	and	d4,d0
	cmp	#'OP'!$8000,d0
	beq.b	asm_lpstop2
	br	HandleMacroos

asm_lpstop2:
	move.l	#$F80001C0,d6
	move	#$0080,d5
	bra	asm_LPSTOP_opp

CA1A2:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C54E,d0
	beq	ASSEM_CMDLLEN
	br	HandleMacroos

Asm_LE:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C100,d0
	beq.b	asm_LEA
	cmp	#$4140,d0
	beq.b	CA1C6
	br	HandleMacroos

CA1C6:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq	ERROR_IllegalSize
	cmp	#$CC00,d0
	beq.b	asm_LEA
	cmp	#$C200,d0
	beq	ERROR_IllegalSize
	br	HandleMacroos

asm_LEA:
	move	#$41C0,d6
	move	#$0080,d5
	br	Asmbl_CMDLEA

CA1F0:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D200,d0
	beq.b	CA270
	cmp	#$CC00,d0
	beq.b	CA244
	cmp	#$5240,d0
	beq.b	CA210
	cmp	#$4C40,d0
	beq.b	CA22A
	br	HandleMacroos

CA210:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	CA286
	cmp	#$CC00,d0
	beq.b	CA290
	cmp	#$C200,d0
	beq.b	CA27C
	br	HandleMacroos

CA22A:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	CA25A
	cmp	#$CC00,d0
	beq.b	CA264
	cmp	#$C200,d0
	beq.b	CA250
	br	HandleMacroos

CA244:
	move	#$E3C8,d6
	move	#$8040,d5
	br	Asm_ShiftRoll

CA250:
	move	#$E3C8,d6
	moveq	#0,d5
	br	Asm_ShiftRoll

CA25A:
	move	#$E3C8,d6
	moveq	#$40,d5
	br	Asm_ShiftRoll

CA264:
	move	#$E3C8,d6
	move	#$0080,d5
	br	Asm_ShiftRoll

CA270:
	move	#$E2C8,d6
	move	#$8040,d5
	br	Asm_ShiftRoll

CA27C:
	move	#$E2C8,d6
	moveq	#0,d5
	br	Asm_ShiftRoll

CA286:
	move	#$E2C8,d6
	moveq	#$40,d5
	br	Asm_ShiftRoll

CA290:
	move	#$E2C8,d6
	move	#$0080,d5
	br	Asm_ShiftRoll

CA29C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CE4B,d0
	beq.b	CA2FC
	cmp	#$4E45,d0
	beq.b	CA2DC
	cmp	#$4E4B,d0
	beq.b	CA2BE
	cmp	#$D354,d0
	beq	ASSEM_CMDLIST
	br	HandleMacroos

CA2BE:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	CA2FC
	cmp	#$C04C,d0
	beq.b	CA306
	cmp	#$C042,d0
	beq	ERROR_IllegalSize
	br	HandleMacroos

CA2DC:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$DB46,d0
	beq.b	Asm_LineF
	cmp	#$DB41,d0
	beq.b	Asm_LineA
	cmp	#$C600,d0
	beq.b	Asm_LineF
	cmp	#$C100,d0
	beq.b	Asm_LineA
	br	HandleMacroos

CA2FC:
	move	#$4E50,d6
	moveq	#$40,d5
	br	Asm_LINK

CA306:
	moveq	#PB_020,d0
	bsr	Processor_warning
	move	#$4808,d6
	move	#$0080,d5
	br	Asm_LINK

Asm_LineA:
	move	#$A000,d6
	move	#$8040,d5
	br	Asmbl_LineAF

Asm_LineF:
	move	#$F000,d6
	move	#$8040,d5
	br	Asmbl_LineAF

CA330:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C144,d0
	beq	Asm_LOAD
	br	HandleMacroos

AsmM:
;******* TRYOUT SPEED IMPROVEMENT *******
	swap	d0
	move.w	(a3)+,d0
	and	d4,d0
	cmp.l	#"MOVE",d0
	beq.b	Asm_its_MOVE_somthing
	cmp.l	#"MOVE"|$8000,d0
	beq	Asm_its_MOVE

	subq.l	#2,a3
	swap	d0

;	cmp	#'MO',d0
;	beq.b	asm_IsIt_Move

	cmp	#'MU',d0
	beq	CA576
	cmp	#'MA',d0
	beq	CA542
	cmp	#'ME',d0
CA35A:
	beq.b	CA360
	br	HandleMacroos

CA360:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"XI",d0
	beq.b	CA36E
	br	HandleMacroos

CA36E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"T"<<(1*8)+$8000,d0
	beq	Asm_MEXIT
	br	HandleMacroos

;asm_IsIt_Move:
;	move	(a3)+,d0
;	and	d4,d0
;	cmp	#"VE",d0
;	beq.b	Asm_its_MOVE_somthing
;	cmp	#"VE"+$8000,d0
;	beq	Asm_its_MOVE
;	br	HandleMacroos

Asm_its_MOVE_somthing:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"@W"+$8000,d0
	beq	Asm_its_MOVE
	cmp	#"@B"+$8000,d0	;move.B
	beq	CA504
	cmp	#"Q"<<(1*8)+$8000,d0
	beq	CA474
	cmp	#"@L"+$8000,d0	;move.L
	beq	Asm_MoveL
	cmp	#"M@",d0
	beq	CA4B6
	cmp	#"P@",d0
	beq	CA480
	cmp	#"M"<<(1*8)+$8000,d0
	beq	CA4D2
	cmp	#"A@",d0
	beq	Asm_Movea
	cmp	#"Q@",d0
	beq.b	CA456
	cmp	#"P"<<(1*8)+$8000,d0
	beq	CA4A0
	cmp	#"A"<<(1*8)+$8000,d0
	beq	Asm_its_MOVE
	cmp	#"C"<<(1*8)+$8000,d0	;moveC
	beq.b	asm_movec2
	cmp	#"S"<<(1*8)+$8000,d0
	beq.b	CA430
	cmp	#"S@",d0
	beq.b	CA416
	cmp	#$9116,d0
	beq.b	Asm_Move16
	br	HandleMacroos

Asm_Move16:
	move.l	#$8000F600,d6
	moveq	#0,d5
	br	Asm_Move16Afronden

CA416:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"L"<<8+$8000,d0
	beq.b	CA444
	cmp	#"W"<<8+$8000,d0
	beq.b	CA430
	cmp	#"B"<<8+$8000,d0
	beq.b	CA43A
	br	HandleMacroos

CA430:	move	#$0E40,d6
	br	Asm_Moves

CA43A:	move	#$0E00,d6
	br	Asm_Moves

CA444:	move	#$0E80,d6
	br	Asm_Moves

asm_movec2:
	move	#$4E7A,d6
	br	asm_movec_crs

CA456:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq	ERROR_IllegalSize
	cmp	#$CC00,d0
	beq.b	CA474
	cmp	#$C200,d0
	beq	ERROR_IllegalSize
	br	HandleMacroos

CA474:
	move	#$7000,d6
	move	#$0080,d5
	br	Asm_MOVEQ

CA480:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	CA4A0
	cmp	#$CC00,d0
	beq.b	CA4AA
	cmp	#$C200,d0
	beq	ERROR_IllegalSize
	br	HandleMacroos

CA4A0:
	move	#$0108,d6
	moveq	#$40,d5
	br	Asm_Movep

CA4AA:
	move	#$0148,d6
	move	#$0080,d5
	br	Asm_Movep

CA4B6:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"W"<<8+$8000,d0
	beq.b	CA4D2
	cmp	#"L"<<8+$8000,d0
	beq.b	CA4DC
	cmp	#"B"<<8+$8000,d0
	beq	ERROR_IllegalSize
	br	HandleMacroos

CA4D2:
	move	#$4880,d6
	moveq	#$40,d5
	br	Asm_MOVEM

CA4DC:
	move	#$48C0,d6
	move	#$0080,d5
	br	Asm_MOVEM

Asm_Movea:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"W"<<8+$8000,d0
	beq.b	Asm_MoveaW
	cmp	#"L"<<8+$8000,d0
	beq.b	Asm_MoveaL
	cmp	#"B"<<8+$8000,d0
	beq	ERROR_IllegalSize
	br	HandleMacroos

CA504:
	moveq	#0,d6
	moveq	#0,d5
	br	Asmbl_CmdMove

Asm_its_MOVE:
	moveq	#0,d6
	moveq	#$40,d5
	br	Asmbl_CmdMove

Asm_MoveL:
	moveq	#0,d6
	move	#$0080,d5
	br	Asmbl_CmdMove

Asm_MoveaW:
	moveq	#$40,d6
	move	#$0028,d5
	br	Asmbl_CmdMovea

Asm_MoveaL:
	moveq	#$40,d6
	move	#$0080,d5
	br	Asmbl_CmdMovea

CA542:
	move	(a3)+,d0
	and	d4,d0
	cmp	#'CR',d0
	beq.b	CA566
	cmp	#$534B,d0
	beq.b	CA556
	br	HandleMacroos

CA556:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$9200,d0
	beq	ASSEM_MASK2
	br	HandleMacroos

CA566:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CF00,d0
	beq	GoGoMacro
	br	HandleMacroos

CA576:	;asm_MU
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CC55,d0
	beq.b	CA5BE
	cmp	#$CC53,d0
	beq.b	CA5D4
	cmp	#'LU',d0	;muLU
	beq.b	CA596
	cmp	#'LS',d0	;muLS
	beq.b	CA5AA
	br	HandleMacroos

CA596:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"@W"+$8000,d0	;mulu.W
	beq.b	CA5BE
	cmp	#"@L"+$8000,d0	;mulu.L
	beq.b	CA5C8
	br	HandleMacroos

CA5AA:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"@W"+$8000,d0
	beq.b	CA5D4
	cmp	#"@L"+$8000,d0
	beq.b	CA5DE
	br	HandleMacroos

CA5BE:
	move	#$C0C0,d6
	moveq	#$40,d5
	br	Asm_ImmOpperantWord

CA5C8:	move	#$4C00,d6
	move	#$0084,d5
	br	Asm_ImmOpperantLong

CA5D4:	move	#$C1C0,d6
	moveq	#$40,d5
	br	Asm_ImmOpperantWord

CA5DE:	move	#$4C00,d6
	move	#$008C,d5
	br	Asm_ImmOpperantLong

AsmN:
	cmp	#'NO',d0
	beq.b	CA604
	cmp	#'NE',d0
	beq	CA698
	cmp	#'NB',d0
	beq	CA72C
	br	HandleMacroos

CA604:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"P"<<(1*8)+$8000,d0	;noP
	beq.b	CA632
	cmp	#"T@",d0
	beq.b	CA63E
	cmp	#"T"<<(1*8)+$8000,d0
	beq.b	CA682
	cmp	#"LI",d0
	beq.b	CA668
	cmp	#"PA",d0
	beq.b	CA658
	cmp	#"L"<<(1*8)+$8000,d0
	beq	ASSEM_CMDNOLIST
	br	HandleMacroos

CA632:	move	#$4E71,d6
	move	#$8040,d5
	br	Asm_InsertinstrA5

CA63E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	CA682
	cmp	#$CC00,d0
	beq.b	CA68C
	cmp	#$C200,d0
	beq.b	CA678
	br	HandleMacroos

CA658:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"GE"+$8000,d0
	beq	ASSEM_CMDNOPAGE
	br	HandleMacroos

CA668:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"ST"+$8000,d0
	beq	ASSEM_CMDNOLIST
	br	HandleMacroos

CA678:	move	#$4600,d6
	moveq	#0,d5
	br	ASSEM_CMDCLRNOTTST

CA682:	move	#$4640,d6
	moveq	#$40,d5
	br	ASSEM_CMDCLRNOTTST

CA68C:	move	#$4680,d6
	move	#$0080,d5
	br	ASSEM_CMDCLRNOTTST

CA698:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$4740,d0
	beq.b	CA6B8
	cmp	#$4758,d0
	beq.b	CA6D2
	cmp	#$C700,d0
	beq.b	CA6F6
	cmp	#$C758,d0
	beq.b	CA716
	br	HandleMacroos

CA6B8:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	CA6F6
	cmp	#$C200,d0
	beq.b	CA6EC
	cmp	#$CC00,d0
	beq.b	CA700
	br	HandleMacroos

CA6D2:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	CA716
	cmp	#$C042,d0
	beq.b	CA70C
	cmp	#$C04C,d0
	beq.b	CA720
	br	HandleMacroos

CA6EC:	move	#$4400,d6
	moveq	#0,d5
	br	ASSEM_CMDCLRNOTTST

CA6F6:	move	#$4440,d6
	moveq	#$40,d5
	br	ASSEM_CMDCLRNOTTST

CA700:	move	#$4480,d6
	move	#$0080,d5
	br	ASSEM_CMDCLRNOTTST

CA70C:	move	#$4000,d6
	moveq	#0,d5
	br	ASSEM_CMDCLRNOTTST

CA716:	move	#$4040,d6
	moveq	#$40,d5
	br	ASSEM_CMDCLRNOTTST

CA720:	move	#$4080,d6
	move	#$0080,d5
	br	ASSEM_CMDCLRNOTTST

CA72C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C344,d0
	beq.b	CA75E
	cmp	#$4344,d0
	beq.b	CA740
	br	HandleMacroos

CA740:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq	ERROR_IllegalSize
	cmp	#$C04C,d0
	beq	ERROR_IllegalSize
	cmp	#$C042,d0
	beq.b	CA75E
	br	HandleMacroos

CA75E:	move	#$4800,d6
	moveq	#0,d5
	br	C108B6

CondAsmTab2:
	dc.w	HandleMacroos-CondAsmTab2	;@
	dc.w	HandleMacroos-CondAsmTab2	;A
	dc.w	HandleMacroos-CondAsmTab2	;B
	dc.w	HandleMacroos-CondAsmTab2	;C
	dc.w	HandleMacroos-CondAsmTab2	;D
	dc.w	CondAsmE-CondAsmTab2		;E
	dc.w	HandleMacroos-CondAsmTab2	;F
	dc.w	HandleMacroos-CondAsmTab2	;G
	dc.w	HandleMacroos-CondAsmTab2	;H
	dc.w	CondAsmI-CondAsmTab2		;I
	dc.w	HandleMacroos-CondAsmTab2	;J
	dc.w	HandleMacroos-CondAsmTab2	;K
	dc.w	HandleMacroos-CondAsmTab2	;L
	dc.w	CondAsmM-CondAsmTab2		;M
	dc.w	HandleMacroos-CondAsmTab2	;N
	dc.w	HandleMacroos-CondAsmTab2	;O
	dc.w	HandleMacroos-CondAsmTab2	;P
	dc.w	HandleMacroos-CondAsmTab2	;Q
	dc.w	HandleMacroos-CondAsmTab2	;R
	dc.w	HandleMacroos-CondAsmTab2	;S
	dc.w	HandleMacroos-CondAsmTab2	;T
	dc.w	HandleMacroos-CondAsmTab2	;U
	dc.w	HandleMacroos-CondAsmTab2	;V
	dc.w	HandleMacroos-CondAsmTab2	;W
	dc.w	HandleMacroos-CondAsmTab2	;X
	dc.w	HandleMacroos-CondAsmTab2	;Y
	dc.w	HandleMacroos-CondAsmTab2	;Z
	dc.w	HandleMacroos-CondAsmTab2	;[

AsmO:
	cmp	#'OR',d0
	beq.b	CA7F4
	cmp	#"OR"+$8000,d0
	beq	CA846
	cmp	#'OD',d0
	beq.b	CA7BE
	cmp	#'OF',d0
	beq.b	CA7CE
	br	HandleMacroos

CA7BE:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"D"<<(1*8)+$8000,d0
	beq	ASSEM_CMDODD
	br	HandleMacroos

CA7CE:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"FS",d0
	beq.b	CA7E4
	cmp	#"S"<<(1*8)+$8000,d0
	beq	ASSEM_CMDOFFSET
	br	HandleMacroos

CA7E4:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"ET"+$8000,d0
	beq	ASSEM_CMDOFFSET
	br	HandleMacroos

CA7F4:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"@W"+$8000,d0
	beq.b	CA846
	cmp	#"@B"+$8000,d0
	beq.b	CA83C
	cmp	#"@L"+$8000,d0
	beq.b	CA850
	cmp	#"G"<<(1*8)+$8000,d0
	beq	Asm_ORG
	cmp	#"I@",d0
	beq.b	CA822
	cmp	#"I"<<(1*8)+$8000,d0
	beq.b	CA846
	br	HandleMacroos

CA822:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	CA846
	cmp	#$C200,d0
	beq.b	CA83C
	cmp	#$CC00,d0
	beq.b	CA850
	br	HandleMacroos

CA83C:	move	#$8001,d6
	moveq	#0,d5
	br	CEAB8

CA846:	move	#$8001,d6
	moveq	#$40,d5
	br	CEAB8

CA850:	move	#$8001,d6
	move	#$0080,d5
	br	CEAB8

AsmP:
	cmp	#'PE',d0
	beq	CB784
	cmp	#'PM',d0
	beq.b	AsmP_PM
	cmp	#'PB',d0
	beq	CB1F2
	cmp	#'PD',d0
	beq	CB054
	cmp	#'PF',d0
	beq	Asm_PF
	cmp	#'PS',d0
	beq	CB642
	cmp	#'PT',d0
	beq	CA994
	cmp	#'PV',d0
	beq	CA96E
	cmp	#'PR',d0
	beq	Asm_PR
	cmp	#'PL',d0
	beq	Asm_PL
	cmp	#'PA',d0
	beq	CB7F6
	cmp	#'PU',d0
	bne.w	HandleMacroos

	move	(a3)+,d0
	and	d4,d0
	cmp	#'LS',d0
	bne.w	HandleMacroos
	move	(a3)+,d0
	and	d4,d0
	cmp	#"E"<<(1*8)+$8000,d0
	bne.w	HandleMacroos

	move.w	#$4ACC,d6	;PULSE
	move	#$8040,d5
	bra	Asm_HaltPulse


AsmP_PM:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"OV",d0	;PMOV
	beq.b	AsmP_PMOV
	br	HandleMacroos

;SYNOPSIS
;	PMOVE	MMU-reg,<ea>
;	PMOVE	<ea>,MMU-reg
;	PMOVEFD	<ea>,MMU-reg
;
;	Size = (Word, Long, Quad).

AsmP_PMOV:
	move	(a3)+,d0
	and	d4,d0
	cmp	#'E@',d0	;PMOVE.
	beq.b	AsmP_PMOVE_
	cmp	#$C500,d0	;PMOVE
	beq.b	AsmP_PMOVE
	cmp	#"EF",d0	;PMOVEF
	beq.b	AsmP_PMOVEF
	br	HandleMacroos

AsmP_PMOVE_:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C200,d0	;PMOVE.B
	beq.b	AsmP_PMOVEB
	cmp	#$D700,d0	;PMOVE.W
	beq.b	AsmP_PMOVE
	cmp	#$CC00,d0	;PMOVE.L
	beq.b	AsmP_PMOVEL
	cmp	#$C400,d0	;PMOVE.D
	beq.b	AsmP_PMOVED
	cmp	#$D100,d0	;PMOVE.Q
	beq.b	AsmP_PMOVED
	br	HandleMacroos

AsmP_PMOVEF:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"D@",d0	;PMOVEFD.
	beq.b	AsmP_PMOVEFD_
	cmp	#$C400,d0	;PMOVEFD
	beq.b	AsmP_PMOVEFD
	br	HandleMacroos

AsmP_PMOVEFD_:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CC00,d0	;PMOVEFD.L
	beq.b	AsmP_PMOVEFD
	cmp	#$C400,d0	;PMOVEFD.D
	beq.b	AsmP_PMOVEFDQ
	cmp	#$D100,d0	;PMOVEFD.Q
	beq.b	AsmP_PMOVEFDQ
	br	HandleMacroos

AsmP_PMOVEB:
	move.l	#$F0004000,d6	;For CRP, SRP, TC registers
	br	Pmove_CrpSrpTc

AsmP_PMOVE:
	move.l	#$F0006000,d6	;For MMUSR register
	br	Pmove_MMUSR

AsmP_PMOVEL:
	move.l	#$F0000000,d6	;For TT0, TT1, registers
	br	Pmove_TT0TT1

AsmP_PMOVED:
	move.l	#$F0004000,d6	;For CRP, SRP, TC registers
	br	Pmove_CrpSrpTcDouble

AsmP_PMOVEFD:
	move.l	#$F0000100,d6	;For TT0, TT1, registers + FD
	br	Pmove_TT0TT1

AsmP_PMOVEFDQ:
	move.l	#$F0004100,d6	;For CRP, SRP, TC registers + FD
	br	Pmove_CrpSrpTcDouble

CA96E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$414C,d0
	beq.b	CA97C
	br	HandleMacroos

CA97C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C944,d0
	beq.b	CA98A
	br	HandleMacroos

CA98A:
	move.l	#$F0002800,d6
	br	Asm_Pvalid

CA994:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$4553,d0	;ptES
	beq	Asm_PTES
	cmp	#$5241,d0	;ptRA
	beq.b	CA9AA
	br	HandleMacroos

CA9AA:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$5042,d0
	beq.b	CA9F0
	cmp	#$504C,d0
	beq	CAA44
	cmp	#$5053,d0
	beq	CAA98
	cmp	#$5041,d0
	beq	CAAEC
	cmp	#$5057,d0
	beq	CAB40
	cmp	#$5049,d0
	beq	CAB94
	cmp	#$5047,d0
	beq	CABE8
	cmp	#$5043,d0
	beq	CAC3C
	br	HandleMacroos

CA9F0:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D300,d0
	beq	CAC90
	cmp	#$C300,d0
	beq	CACC0
	cmp	#$5340,d0
	beq.b	CAA14
	cmp	#$4340,d0
	beq.b	CAA2C
	br	HandleMacroos

CAA14:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq	CACA0
	cmp	#$CC00,d0
	beq	CACB0
	br	ERROR_IllegalSize

CAA2C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq	CACD0
	cmp	#$CC00,d0
	beq	CACE0
	br	ERROR_IllegalSize

CAA44:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D300,d0
	beq	CACF0
	cmp	#$C300,d0
	beq	CAD20
	cmp	#$5340,d0
	beq.b	CAA68
	cmp	#$4340,d0
	beq.b	CAA80
	br	HandleMacroos

CAA68:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq	CAD00
	cmp	#$CC00,d0
	beq	CAD10
	br	ERROR_IllegalSize

CAA80:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq	CAD30
	cmp	#$CC00,d0
	beq	CAD40
	br	ERROR_IllegalSize

CAA98:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D300,d0
	beq	CAD50
	cmp	#$C300,d0
	beq	CAD80
	cmp	#$5340,d0
	beq.b	CAABC
	cmp	#$4340,d0
	beq.b	CAAD4
	br	HandleMacroos

CAABC:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq	CAD60
	cmp	#$CC00,d0
	beq	CAD70
	br	ERROR_IllegalSize

CAAD4:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq	CAD90
	cmp	#$CC00,d0
	beq	CADA0
	br	ERROR_IllegalSize

CAAEC:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D300,d0
	beq	CADB0
	cmp	#$C300,d0
	beq	CADE0
	cmp	#$5340,d0
	beq.b	CAB10
	cmp	#$4340,d0
	beq.b	CAB28
	br	HandleMacroos

CAB10:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq	CADC0
	cmp	#$CC00,d0
	beq	CADD0
	br	ERROR_IllegalSize

CAB28:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq	CADF0
	cmp	#$CC00,d0
	beq	CAE00
	br	ERROR_IllegalSize

CAB40:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D300,d0
	beq	CAE10
	cmp	#$C300,d0
	beq	CAE40
	cmp	#$5340,d0
	beq.b	CAB64
	cmp	#$4340,d0
	beq.b	CAB7C
	br	HandleMacroos

CAB64:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq	CAE20
	cmp	#$CC00,d0
	beq	CAE30
	br	ERROR_IllegalSize

CAB7C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq	CAE50
	cmp	#$CC00,d0
	beq	CAE60
	br	ERROR_IllegalSize

CAB94:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D300,d0
	beq	CAE70
	cmp	#$C300,d0
	beq	CAEA0
	cmp	#$5340,d0
	beq.b	CABB8
	cmp	#$4340,d0
	beq.b	CABD0
	br	HandleMacroos

CABB8:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq	CAE80
	cmp	#$CC00,d0
	beq	CAE90
	br	ERROR_IllegalSize

CABD0:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq	CAEB0
	cmp	#$CC00,d0
	beq	CAEC0
	br	ERROR_IllegalSize

CABE8:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D300,d0
	beq	CAED0
	cmp	#$C300,d0
	beq	CAF00
	cmp	#$5340,d0
	beq.b	CAC0C
	cmp	#$4340,d0
	beq.b	CAC24
	br	HandleMacroos

CAC0C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq	CAEE0
	cmp	#$CC00,d0
	beq	CAEF0
	br	ERROR_IllegalSize

CAC24:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq	CAF10
	cmp	#$CC00,d0
	beq	CAF20
	br	ERROR_IllegalSize

CAC3C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D300,d0
	beq	CAF30
	cmp	#$C300,d0
	beq	CAF60
	cmp	#$5340,d0
	beq.b	CAC60
	cmp	#$4340,d0
	beq.b	CAC78
	br	HandleMacroos

CAC60:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq	CAF40
	cmp	#$CC00,d0
	beq	CAF50
	br	ERROR_IllegalSize

CAC78:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq	CAF70
	cmp	#$CC00,d0
	beq	CAF80
	br	ERROR_IllegalSize

CAC90:	move.l	#$F07C0000,d6
	moveq	#0,d5
	br	Asm_PtrapCC

CACA0:	move.l	#$F07A0000,d6
	moveq	#$40,d5
	br	Asm_PtrapCC

CACB0:	move.l	#$F07B0000,d6
	moveq	#$80-256,d5
	br	Asm_PtrapCC

CACC0:	move.l	#$F07C0001,d6
	moveq	#0,d5
	br	Asm_PtrapCC

CACD0:	move.l	#$F07A0001,d6
	moveq	#$40,d5
	br	Asm_PtrapCC

CACE0:	move.l	#$F07B0001,d6
	moveq	#$80-256,d5
	br	Asm_PtrapCC

CACF0:	move.l	#$F07C0002,d6
	moveq	#0,d5
	br	Asm_PtrapCC

CAD00:	move.l	#$F07A0002,d6
	moveq	#$40,d5
	br	Asm_PtrapCC

CAD10:	move.l	#$F07B0002,d6
	moveq	#$80-256,d5
	br	Asm_PtrapCC

CAD20:	move.l	#$F07C0003,d6
	moveq	#0,d5
	br	Asm_PtrapCC

CAD30:	move.l	#$F07A0003,d6
	moveq	#$40,d5
	br	Asm_PtrapCC

CAD40:	move.l	#$F07B0003,d6
	moveq	#$80-256,d5
	br	Asm_PtrapCC

CAD50:	move.l	#$F07C0004,d6
	moveq	#0,d5
	br	Asm_PtrapCC

CAD60:	move.l	#$F07A0004,d6
	moveq	#$40,d5
	br	Asm_PtrapCC

CAD70:	move.l	#$F07B0004,d6
	moveq	#$80-256,d5
	br	Asm_PtrapCC

CAD80:	move.l	#$F07C0005,d6
	moveq	#0,d5
	br	Asm_PtrapCC

CAD90:	move.l	#$F07A0005,d6
	moveq	#$40,d5
	br	Asm_PtrapCC

CADA0:	move.l	#$F07B0005,d6
	moveq	#$80-256,d5
	br	Asm_PtrapCC

CADB0:	move.l	#$F07C0006,d6
	moveq	#0,d5
	br	Asm_PtrapCC

CADC0:	move.l	#$F07A0006,d6
	moveq	#$40,d5
	br	Asm_PtrapCC

CADD0:	move.l	#$F07B0006,d6
	moveq	#$80-256,d5
	br	Asm_PtrapCC

CADE0:	move.l	#$F07C0007,d6
	moveq	#0,d5
	br	Asm_PtrapCC

CADF0:	move.l	#$F07A0007,d6
	moveq	#$40,d5
	br	Asm_PtrapCC

CAE00:	move.l	#$F07B0007,d6
	moveq	#$80-256,d5
	br	Asm_PtrapCC

CAE10:	move.l	#$F07C0008,d6
	moveq	#0,d5
	br	Asm_PtrapCC

CAE20:	move.l	#$F07A0008,d6
	moveq	#$40,d5
	br	Asm_PtrapCC

CAE30:	move.l	#$F07B0008,d6
	moveq	#$80-256,d5
	br	Asm_PtrapCC

CAE40:	move.l	#$F07C0009,d6
	moveq	#0,d5
	br	Asm_PtrapCC

CAE50:	move.l	#$F07A0009,d6
	moveq	#$40,d5
	br	Asm_PtrapCC

CAE60:	move.l	#$F07B0009,d6
	moveq	#$80-256,d5
	br	Asm_PtrapCC

CAE70:	move.l	#$F07C000A,d6
	moveq	#0,d5
	br	Asm_PtrapCC

CAE80:	move.l	#$F07A000A,d6
	moveq	#$40,d5
	br	Asm_PtrapCC

CAE90:	move.l	#$F07B000A,d6
	moveq	#$80-256,d5
	br	Asm_PtrapCC

CAEA0:	move.l	#$F07C000B,d6
	moveq	#0,d5
	br	Asm_PtrapCC

CAEB0:	move.l	#$F07A000B,d6
	moveq	#$40,d5
	br	Asm_PtrapCC

CAEC0:	move.l	#$F07B000B,d6
	moveq	#$80-256,d5
	br	Asm_PtrapCC

CAED0:	move.l	#$F07C000C,d6
	moveq	#0,d5
	br	Asm_PtrapCC

CAEE0:	move.l	#$F07A000C,d6
	moveq	#$40,d5
	br	Asm_PtrapCC

CAEF0:	move.l	#$F07B000C,d6
	moveq	#$80-256,d5
	br	Asm_PtrapCC

CAF00:	move.l	#$F07C000D,d6
	moveq	#0,d5
	br	Asm_PtrapCC

CAF10:	move.l	#$F07A000D,d6
	moveq	#$40,d5
	br	Asm_PtrapCC

CAF20:	move.l	#$F07B000D,d6
	moveq	#$80-256,d5
	br	Asm_PtrapCC

CAF30:	move.l	#$F07C000E,d6
	moveq	#0,d5
	br	Asm_PtrapCC

CAF40:	move.l	#$F07A000E,d6
	moveq	#$40,d5
	br	Asm_PtrapCC

CAF50:	move.l	#$F07B000E,d6
	moveq	#$80-256,d5
	br	Asm_PtrapCC

CAF60:	move.l	#$F07C000F,d6
	moveq	#0,d5
	br	Asm_PtrapCC

CAF70:	move.l	#$F07A000F,d6
	moveq	#$40,d5
	br	Asm_PtrapCC

CAF80:	move.l	#$F07B000F,d6
	moveq	#$80-256,d5
	br	Asm_PtrapCC

Asm_PTES:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D452,d0	;TR
	beq.b	CAFA4
	cmp	#$D457,d0	;TW
	beq.b	CAFAE
	br	HandleMacroos

CAFA4:	move.l	#$F0008200,d6
	br	Asm_Ptest

CAFAE:	move.l	#$F0008000,d6
	br	Asm_Ptest

Asm_PF:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"LU",d0
	beq.b	Asm_PFLU
	br	HandleMacroos

Asm_PFLU:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"SH"!$8000,d0
	beq.b	Asm_PFLUSH_
	cmp	#"SH",d0
	beq.b	Asm_PFLUSH
	br	HandleMacroos

Asm_PFLUSH:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C100,d0
	beq.b	Asm_PFLUSHA
	cmp	#$D300,d0
	beq.b	Asm_PFLUSHS
	cmp	#$CE00,d0
	beq.b	Asm_PFLUSHN
	cmp	#$D200,d0
	beq.b	Asm_PFLUSHR
	cmp	#$C14E,d0
	beq.b	Asm_PFLUSHAN
	br	HandleMacroos

Asm_PFLUSH_:
	move.l	#$F0003000,d6
	br	Asm_HandlePflush

Asm_PFLUSHN:
	move.l	#$0000F500,d6
	br	Asm_Get040Pflushopp

Asm_PFLUSHA:
	move.w	#PB_851|PB_030,d0
	bsr	Processor_warning

	tst.b	PR_MMU
	bne.s	Asm_PFLUSH_851
	cmp.w	#PB_040,(CPU_type-DT,a4)
	blo.s	Asm_PFLUSH_851

	move.l	#$0000F518,d6
	bsr	Asm_SkipInstructionHead
	br	ASM_STORE_INSTRUCTION_HEAD

Asm_PFLUSH_851:
	move.l	#$F0002400,d6
	bsr	asm_4bytes_OpperantSize
	br	ASM_STORE_LONG

Asm_PFLUSHAN:
	move.w	#PB_040|PB_ONLY,d0
	bsr	Processor_warning
	move.l	#$0000F510,d6
	bsr	Asm_SkipInstructionHead
	br	ASM_STORE_INSTRUCTION_HEAD

Asm_PFLUSHS:
	move	#PB_851|PB_MMU,d0
	bsr	Processor_warning
	move.l	#$F0003400,d6
	br	Asm_HandlePflush

Asm_PFLUSHR:
	move	#PB_851|PB_MMU,d0
	bsr	Processor_warning
	move.l	#$F000A000,d6
	br	Asm_HandlePflushr

CB054:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$4242,d0
	beq.b	CB092
	cmp	#$424C,d0
	beq.b	CB0AA
	cmp	#$4253,d0
	beq.b	CB0DA
	cmp	#$4241,d0
	beq.b	CB0C2
	cmp	#$4257,d0
	beq.b	CB0F2
	cmp	#$4249,d0
	beq	CB10A
	cmp	#$4247,d0
	beq	CB122
	cmp	#$4243,d0
	beq	CB13A
	bra	HandleMacroos

CB092:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D300,d0
	beq	CB152
	cmp	#$C300,d0
	beq	CB15C
	bra	HandleMacroos

CB0AA:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D300,d0
	beq	CB166
	cmp	#$C300,d0
	beq	CB170
	bra	HandleMacroos

CB0C2:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D300,d0
	beq	CB18E
	cmp	#$C300,d0
	beq	CB198
	bra	HandleMacroos

CB0DA:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D300,d0
	beq	CB17A
	cmp	#$C300,d0
	beq	CB184
	bra	HandleMacroos

CB0F2:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D300,d0
	beq	CB1A2
	cmp	#$C300,d0
	beq	CB1AC
	bra	HandleMacroos

CB10A:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D300,d0
	beq	CB1B6
	cmp	#$C300,d0
	beq	CB1C0
	bra	HandleMacroos

CB122:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D300,d0
	beq	CB1CA
	cmp	#$C300,d0
	beq	CB1D4
	bra	HandleMacroos

CB13A:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D300,d0
	beq	CB1DE
	cmp	#$C300,d0
	beq	CB1E8
	bra	HandleMacroos

CB152:	move.l	#$0000F048,d6
	br	CF43C

CB15C:	move.l	#$0001F048,d6
	br	CF43C

CB166:	move.l	#$0002F048,d6
	br	CF43C

CB170:	move.l	#$0003F048,d6
	br	CF43C

CB17A:	move.l	#$0004F048,d6
	br	CF43C

CB184:	move.l	#$0005F048,d6
	br	CF43C

CB18E:	move.l	#$0006F048,d6
	br	CF43C

CB198:	move.l	#$0007F048,d6
	br	CF43C

CB1A2:	move.l	#$0008F048,d6
	br	CF43C

CB1AC:	move.l	#$0009F048,d6
	br	CF43C

CB1B6:	move.l	#$000AF048,d6
	br	CF43C

CB1C0:	move.l	#$000BF048,d6
	br	CF43C

CB1CA:	move.l	#$000CF048,d6
	br	CF43C

CB1D4:	move.l	#$000DF048,d6
	br	CF43C

CB1DE:	move.l	#$000EF048,d6
	br	CF43C

CB1E8:	move.l	#$000FF048,d6
	br	CF43C

CB1F2:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C253,d0
	beq	CB492
	cmp	#$C243,d0
	beq	CB4A8
	cmp	#$CC53,d0
	beq	CB4BE
	cmp	#$CC43,d0
	beq	CB4D4
	cmp	#$D353,d0
	beq	CB4EA
	cmp	#$D343,d0
	beq	CB500
	cmp	#$C153,d0
	beq	CB52C
	cmp	#$C143,d0
	beq	CB52C
	cmp	#$D753,d0
	beq	CB542
	cmp	#$D743,d0
	beq	CB558
	cmp	#$C953,d0
	beq	CB56E
	cmp	#$C943,d0
	beq	CB584
	cmp	#$C753,d0
	beq	CB59A
	cmp	#$C743,d0
	beq	CB5B0
	cmp	#$C353,d0
	beq	CB5C6
	cmp	#$C343,d0
	beq	CB5DC
	cmp	#$4253,d0
	beq.b	CB2F8
	cmp	#$4243,d0
	beq	CB310
	cmp	#$4C53,d0
	beq	CB328
	cmp	#$4C43,d0
	beq	CB340
	cmp	#$5353,d0
	beq	CB35A
	cmp	#$5343,d0
	beq	CB374
	cmp	#$4153,d0
	beq	CB38E
	cmp	#$4143,d0
	beq	CB3A8
	cmp	#$5753,d0
	beq	CB3C2
	cmp	#$5743,d0
	beq	CB3DC
	cmp	#$4953,d0
	beq	CB3F6
	cmp	#$4943,d0
	beq	CB410
	cmp	#$4753,d0
	beq	CB42A
	cmp	#$4743,d0
	beq	CB444
	cmp	#$4353,d0
	beq	CB45E
	cmp	#$4343,d0
	beq	CB478
	br	HandleMacroos

CB2F8:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq	CB492
	cmp	#$C04C,d0
	beq	CB49C
	br	_HandleMacroos

CB310:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq	CB4A8
	cmp	#$C04C,d0
	beq	CB4B2
	br	_HandleMacroos

CB328:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq	CB4BE
	cmp	#$C04C,d0
	beq	CB4C8
	br	_HandleMacroos

CB340:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq	CB4D4
	cmp	#$C04C,d0
	beq	CB4DE
	bra	_HandleMacroos

CB35A:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq	CB4EA
	cmp	#$C04C,d0
	beq	CB4F4
	bra	_HandleMacroos

CB374:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq	CB500
	cmp	#$C04C,d0
	beq	CB50A
	bra	_HandleMacroos

CB38E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq	CB516
	cmp	#$C04C,d0
	beq	CB520
	bra	_HandleMacroos

CB3A8:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq	CB52C
	cmp	#$C04C,d0
	beq	CB536
	bra	_HandleMacroos

CB3C2:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq	CB542
	cmp	#$C04C,d0
	beq	CB54C
	bra	_HandleMacroos

CB3DC:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq	CB558
	cmp	#$C04C,d0
	beq	CB562
	bra	_HandleMacroos

CB3F6:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq	CB56E
	cmp	#$C04C,d0
	beq	CB578
	bra	_HandleMacroos

CB410:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq	CB584
	cmp	#$C04C,d0
	beq	CB58E
	bra	_HandleMacroos

CB42A:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq	CB59A
	cmp	#$C04C,d0
	beq	CB5A4
	bra	_HandleMacroos

CB444:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq	CB5B0
	cmp	#$C04C,d0
	beq	CB5BA
	bra	_HandleMacroos

CB45E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq	CB5C6
	cmp	#$C04C,d0
	beq	CB5D0
	bra	_HandleMacroos

CB478:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq	CB5DC
	cmp	#$C04C,d0
	beq	CB5E6
	bra	_HandleMacroos

CB492:	move	#$F080,d6
	moveq	#$40,d5
	br	CF466

CB49C:	move	#$F0C0,d6
	move	#$0080,d5
	br	CF466

CB4A8:	move	#$F081,d6
	moveq	#$40,d5
	br	CF466

CB4B2:	move	#$F0C1,d6
	move	#$0080,d5
	br	CF466

CB4BE:	move	#$F082,d6
	moveq	#$40,d5
	br	CF466

CB4C8:	move	#$F0C2,d6
	move	#$0080,d5
	br	CF466

CB4D4:	move	#$F083,d6
	moveq	#$40,d5
	br	CF466

CB4DE:	move	#$F0C3,d6
	move	#$0080,d5
	br	CF466

CB4EA:	move	#$F084,d6
	moveq	#$40,d5
	br	CF466

CB4F4:	move	#$F0C4,d6
	move	#$0080,d5
	br	CF466

CB500:	move	#$F085,d6
	moveq	#$40,d5
	br	CF466

CB50A:	move	#$F0C5,d6
	move	#$0080,d5
	br	CF466

CB516:	move	#$F086,d6
	moveq	#$40,d5
	br	CF466

CB520:	move	#$F0C6,d6
	move	#$0080,d5
	br	CF466

CB52C:	move	#$F087,d6
	moveq	#$40,d5
	br	CF466

CB536:	move	#$F0C7,d6
	move	#$0080,d5
	br	CF466

CB542:	move	#$F088,d6
	moveq	#$40,d5
	br	CF466

CB54C:	move	#$F0C8,d6
	move	#$0080,d5
	br	CF466

CB558:	move	#$F089,d6
	moveq	#$40,d5
	br	CF466

CB562:	move	#$F0C9,d6
	move	#$0080,d5
	br	CF466

CB56E:	move	#$F08A,d6
	moveq	#$40,d5
	br	CF466

CB578:	move	#$F0CA,d6
	move	#$0080,d5
	br	CF466

CB584:	move	#$F08B,d6
	moveq	#$40,d5
	br	CF466

CB58E:	move	#$F0CB,d6
	move	#$0080,d5
	br	CF466

CB59A:	move	#$F08C,d6
	moveq	#$40,d5
	br	CF466

CB5A4:	move	#$F0CC,d6
	move	#$0080,d5
	br	CF466

CB5B0:	move	#$F08D,d6
	moveq	#$40,d5
	br	CF466

CB5BA:	move	#$F0CD,d6
	move	#$0080,d5
	br	CF466

CB5C6:	move	#$F08E,d6
	moveq	#$40,d5
	br	CF466

CB5D0:	move	#$F0CE,d6
	move	#$0080,d5
	br	CF466

CB5DC:	move	#$F08F,d6
	moveq	#$40,d5
	br	CF466

CB5E6:	move	#$F0CF,d6
	move	#$0080,d5
	br	CF466

Asm_PR:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"IN",d0
	beq.b	Asm_PRIN
	cmp	#"ES",d0
	beq.b	CB606
	br	_HandleMacroos

CB606:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$544F,d0
	beq.b	CB614
	br	_HandleMacroos

CB614:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D245,d0
	beq.b	CB622
	br	_HandleMacroos

CB622:	move	#$F140,d6
	br	Asm_Psave_Prestore

Asm_PRIN:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D456,d0	;prinTV
	beq	Asm_PRINTV
	cmp	#$D454,d0	;prinTT
	beq	Asm_PRINTT
	br	_HandleMacroos

CB642:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$4156,d0
	beq	CB76E
	cmp	#$C253,d0
	beq.b	CB6CE
	cmp	#$C243,d0
	beq.b	CB6D8
	cmp	#$CC53,d0
	beq.b	CB6E2
	cmp	#$CC43,d0
	beq.b	CB6EC
	cmp	#$D353,d0
	beq.b	CB6F6
	cmp	#$D343,d0
	beq.b	CB700
	cmp	#$C153,d0
	beq.b	CB70A
	cmp	#$C143,d0
	beq.b	CB714
	cmp	#$D753,d0
	beq.b	CB71E
	cmp	#$D743,d0
	beq.b	CB728
	cmp	#$C953,d0
	beq.b	CB732
	cmp	#$C943,d0
	beq.b	CB73C
	cmp	#$C753,d0
	beq.b	CB746
	cmp	#$C743,d0
	beq.b	CB750
	cmp	#$C353,d0
	beq.b	CB75A
	cmp	#$C343,d0
	beq.b	CB764
	br	_HandleMacroos

CB6CE:	moveq	#0,d6
	br	Asm_PsCC

CB6D8:	moveq	#1,d6
	br	Asm_PsCC

CB6E2:	moveq	#2,d6
	br	Asm_PsCC

CB6EC:	moveq	#3,d6
	br	Asm_PsCC

CB6F6:	moveq	#4,d6
	br	Asm_PsCC

CB700:	moveq	#5,d6
	br	Asm_PsCC

CB70A:	moveq	#6,d6
	br	Asm_PsCC

CB714:	moveq	#7,d6
	br	Asm_PsCC

CB71E:	moveq	#8,d6
	br	Asm_PsCC

CB728:	moveq	#9,d6
	br	Asm_PsCC

CB732:	moveq	#10,d6
	br	Asm_PsCC

CB73C:	moveq	#11,d6
	br	Asm_PsCC

CB746:	moveq	#12,d6
	br	Asm_PsCC

CB750:	moveq	#13,d6
	br	Asm_PsCC

CB75A:	moveq	#14,d6
	br	Asm_PsCC

CB764:	moveq	#15,d6
	br	Asm_PsCC

CB76E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C500,d0
	beq.b	CB77C
	br	_HandleMacroos

CB77C:	move	#$F100,d6
	br	Asm_Psave_Prestore

CB784:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C100,d0
	beq	CB816
	cmp	#$4140,d0
	beq.b	CB79A
	br	_HandleMacroos

CB79A:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq	ERROR_IllegalSize
	cmp	#$CC00,d0
	beq	CB816
	cmp	#$C200,d0
	beq	ERROR_IllegalSize
	br	_HandleMacroos

Asm_PL:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C54E,d0
	beq	ASSEM_CMDPLEN
	cmp	#$4F41,d0
	beq.b	Asm_plOA
	cmp.w	#'PA',d0
	beq.b	Asm_PLPA
	br	_HandleMacroos

Asm_PLPA:
	move.w	(a3)+,d0
	and.w	d4,d0
	cmp.w	#'R'<<8+$8000,d0
	beq.b	.PLPAR
	cmp.w	#'W'<<8+$8000,d0
	beq.b	.PLPAW
	bra	_HandleMacroos

.PLPAR	move.w	#$f5c8,d6
	bra	Asm_HandlePlpa
.PLPAW	move.w	#$f588,d6
	bra	Asm_HandlePlpa

Asm_plOA:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C452,d0
	beq.b	Asm_ploadr
	cmp	#$C457,d0
	beq.b	Asm_ploadw
	br	_HandleMacroos

Asm_ploadr:
	move.l	#$F0002200,d6
	br	Asm_HandlePload

Asm_ploadw:
	move.l	#$F0002000,d6
	br	Asm_HandlePload

CB7F6:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C745,d0
	beq	ASSEM_CMDPAGE
	cmp	#$C34B,d0
	beq.b	CB80C
	br	_HandleMacroos

CB80C:	move	#$8140,d6
	moveq	#0,d5
	br	Asm_PackUnpk

CB816:	move	#$4840,d6
	move	#$0080,d5
	br	Asm_CmdJmpJsrPea

AsmQ:
	cmp.w	#'QR',d0
	bne.b	.NotFound
	move.w	(a3)+,d0
	and.w	d4,d0
	cmp.w	#'EP',d0
	bne.b	.NotFound
	move.w	(a3)+,d0
	and.w	d4,d0
	cmp.w	#('T'<<8)+$8000,d0
	beq.w	Asm_QREPT
.NotFound
	bra.w	_HandleMacroos

AsmR:
	cmp	#'RT',d0
	beq.b	CB8A6
	cmp	#'RS',d0
	beq.b	CB84C
	cmp	#'RO',d0
	beq	CB91A
	cmp	#"RS"+$8000,d0
	beq	ASSEM_CMDRS_W
	cmp	#'RE',d0
	beq	CBA78
	br	_HandleMacroos

CB84C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"@W"+$8000,d0
	beq	ASSEM_CMDRS_W
	cmp	#"@L"+$8000,d0
	beq	ASSEM_CMDRS_L
	cmp	#"@B"+$8000,d0
	beq	ASSEM_CMDRS_B
	cmp	#"SE",d0
	beq.b	CB896
	cmp	#"RE",d0
	beq.b	CB878
	br	_HandleMacroos

CB878:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"SE",d0
	beq.b	CB886
	br	_HandleMacroos

CB886:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D400,d0
	beq	ASSEM_CMDRSRESET
	br	_HandleMacroos

CB896:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D400,d0
	beq	ASSEM_CMDRSSET
	br	_HandleMacroos

CB8A6:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D300,d0
	beq.b	CB8F6
	cmp	#$D200,d0
	beq.b	CB90E
	cmp	#$C500,d0
	beq.b	CB902
	cmp	#$C400,d0
	beq.b	CB8CC
	cmp	#$CD00,d0
	beq.b	CB8DE
	br	_HandleMacroos

CB8CC:	move	#$4E74,d6
	moveq	#$40,d5
	moveq	#PB_010,d0
	bsr	Processor_warning
	br	C1009E

CB8DE:	move	#$06C0,d6
	moveq	#$40,d5
	move	#PB_ONLY|PB_020,d0
	bsr	Processor_warning
	bsr	AddrOrDataReg
	or.w	d1,d6
	br	Asm_InsertInstruction

CB8F6:	move	#$4E75,d6
	move	#$8040,d5
	br	Asm_InsertinstrA5

CB902:	move	#$4E73,d6
	move	#$8040,d5
	br	Asm_InsertinstrA5

CB90E:	move	#$4E77,d6
	move	#$8040,d5
	br	Asm_InsertinstrA5

CB91A:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$5240,d0
	beq	CB9CA
	cmp	#$4C40,d0
	beq.b	CB990
	cmp	#$5852,d0
	beq	CBA3E
	cmp	#$584C,d0
	beq	CBA04
	cmp	#$D200,d0
	beq.b	CB96C
	cmp	#$CC00,d0
	beq.b	CB960
	cmp	#$D852,d0
	beq.b	CB984
	cmp	#$D84C,d0
	beq.b	CB978
	cmp	#$D247,d0
	beq	C7576
	br	_HandleMacroos

CB960:	move	#$E7D8,d6
	move	#$8040,d5
	br	Asm_ShiftRoll

CB96C:	move	#$E6D8,d6
	move	#$8040,d5
	br	Asm_ShiftRoll

CB978:	move	#$E5D0,d6
	move	#$8040,d5
	br	Asm_ShiftRoll

CB984:	move	#$E4D0,d6
	move	#$8040,d5
	br	Asm_ShiftRoll

CB990:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	CB9B4
	cmp	#$CC00,d0
	beq.b	CB9BE
	cmp	#$C200,d0
	beq.b	CB9AA
	br	_HandleMacroos

CB9AA:	move	#$E7D8,d6
	moveq	#0,d5
	br	Asm_ShiftRoll

CB9B4:	move	#$E7D8,d6
	moveq	#$40,d5
	br	Asm_ShiftRoll

CB9BE:	move	#$E7D8,d6
	move	#$0080,d5
	br	Asm_ShiftRoll

CB9CA:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	CB9EE
	cmp	#$CC00,d0
	beq.b	CB9F8
	cmp	#$C200,d0
	beq.b	CB9E4
	br	_HandleMacroos

CB9E4:	move	#$E6D8,d6
	moveq	#0,d5
	br	Asm_ShiftRoll

CB9EE:	move	#$E6D8,d6
	moveq	#$40,d5
	br	Asm_ShiftRoll

CB9F8:	move	#$E6D8,d6
	move	#$0080,d5
	br	Asm_ShiftRoll

CBA04:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	CBA28
	cmp	#$C04C,d0
	beq.b	CBA32
	cmp	#$C042,d0
	beq.b	CBA1E
	br	_HandleMacroos

CBA1E:	move	#$E5D0,d6
	moveq	#0,d5
	br	Asm_ShiftRoll

CBA28:	move	#$E5D0,d6
	moveq	#$40,d5
	br	Asm_ShiftRoll

CBA32:	move	#$E5D0,d6
	move	#$0080,d5
	br	Asm_ShiftRoll

CBA3E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	CBA62
	cmp	#$C04C,d0
	beq.b	CBA6C
	cmp	#$C042,d0
	beq.b	CBA58
	br	_HandleMacroos

CBA58:	move	#$E4D0,d6
	moveq	#0,d5
	br	Asm_ShiftRoll

CBA62:	move	#$E4D0,d6
	moveq	#$40,d5
	br	Asm_ShiftRoll

CBA6C:	move	#$E4D0,d6
	move	#$0080,d5
	br	Asm_ShiftRoll

CBA78:
	move	(a3)+,d0
	and	d4,d0
	cmp	#'PT'+$8000,d0
	beq	Asm_REPT
	cmp	#('G'<<8)+$8000,d0
	beq	Asm_REG
	cmp	#'SE',d0
	beq.b	CBA9C
	cmp	#('M'<<8)+$8000,d0
	beq.b	Asm_CmdREM
	br	_HandleMacroos

CBA9C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#('T'<<8)+$8000,d0
	beq.b	Asm_CmdRESET
	br	_HandleMacroos

Asm_CmdRESET:
	move	#$4E70,d6
	move	#$8040,d5
	br	Asm_InsertinstrA5

Asm_CmdREM:
	tst	(MACRO_LEVEL-DT,a4)
	bne.b	.CBB14
.Loop	move.b	(a6)+,d2
	bne.b	.CBACC
	bsr.w	SkippedToNewLine		; trashes d0/d1/a0
.CBACC	cmp.b	#SRCMARK_END,d2
	beq.b	.CBB08
	moveq	#~32,d0
	and.b	d2,d0
	cmp.b	#'E',d0
	bne.b	.Loop
	move.l	a6,a0
	moveq	#~32,d0
	and.b	(a0)+,d0
	cmp.b	#'R',d0
	bne.b	.Loop
	moveq	#~32,d0
	and.b	(a0)+,d0
	cmp.b	#'E',d0
	bne.b	.Loop
	moveq	#~32,d0
	and.b	(a0)+,d0
	cmp.b	#'M',d0
	bne.b	.Loop

.CBB04	tst.b	(a6)+
	bne.b	.CBB04
.CBB08	subq.w	#1,a6
	cmp.b	#SRCMARK_END,(a6)
	beq.b	.NoEnd
.CBB14	rts

.NoEnd	bclr	#AF_ALLERRORS,d7
	bra	ERROR_REMwithoutEREM

AsmS:
	cmp	#'SU',d0
	beq	CBCD0
	cmp	#'SW',d0
	beq	CBCA4
	cmp	#'SE',d0
	beq	Asm_SE
	cmp	#'SB',d0
	beq.b	CBB98
	cmp	#'SV',d0
	beq	CBF28
	cmp	#'SN',d0
	beq	CC07A
	cmp	#'ST',d0
	beq	CBBD4
	cmp	#'SP',d0
	beq	CBEE4
	cmp	#'SC',d0
	beq	CBC34
	cmp	#'SM',d0
	beq	CC0B6
	cmp	#'SL',d0
	beq	CBF98
	cmp	#'SH',d0
	beq	CBE74
	cmp	#'SG',d0
	beq	CC0F2
	cmp	#'SF',d0
	beq	CBC0C
	cmp	#"ST"+$8000,d0
	beq.b	CBBF8
	cmp	#"SF"+$8000,d0
	beq	CBC2A
	br	_HandleMacroos

CBB98:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"CD"+$8000,d0
	beq.b	CBBCA
	cmp	#"CD",d0
	beq.b	CBBAC
	br	_HandleMacroos

CBBAC:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"@W"+$8000,d0
	beq	ERROR_IllegalSize
	cmp	#"@L"+$8000,d0
	beq	ERROR_IllegalSize
	cmp	#"@B"+$8000,d0
	beq.b	CBBCA
	br	_HandleMacroos

CBBCA:	move	#$8100,d6
	moveq	#0,d5
	br	CEB92

CBBD4:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CF50,d0
	beq.b	CBC02
	cmp	#$C057,d0
	beq	ERROR_IllegalSize
	cmp	#$C04C,d0
	beq	ERROR_IllegalSize
	cmp	#$C042,d0
	beq.b	CBBF8
	br	_HandleMacroos

CBBF8:	move	#$50C0,d6
	moveq	#0,d5
	br	C108B6

CBC02:	move	#$4E72,d6
	moveq	#$40,d5
	br	C1009E

CBC0C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"@W"+$8000,d0
	beq	ERROR_IllegalSize
	cmp	#"@L"+$8000,d0
	beq	ERROR_IllegalSize
	cmp	#"@B"+$8000,d0
	beq.b	CBC2A
	br	_HandleMacroos

CBC2A:	move	#$51C0,d6
	moveq	#0,d5
	br	C108B6

CBC34:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D300,d0
	beq.b	CBC9A
	cmp	#$C300,d0
	beq.b	CBC90
	cmp	#$5340,d0
	beq.b	CBC72
	cmp	#$4340,d0
	beq.b	CBC54
	br	_HandleMacroos

CBC54:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq	ERROR_IllegalSize
	cmp	#$CC00,d0
	beq	ERROR_IllegalSize
	cmp	#$C200,d0
	beq.b	CBC90
	br	_HandleMacroos

CBC72:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq	ERROR_IllegalSize
	cmp	#$CC00,d0
	beq	ERROR_IllegalSize
	cmp	#$C200,d0
	beq.b	CBC9A
	br	_HandleMacroos

CBC90:	move	#$54C0,d6
	moveq	#0,d5
	br	C108B6

CBC9A:	move	#$55C0,d6
	moveq	#0,d5
	br	C108B6

CBCA4:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C150,d0
	beq.b	CBCC6
	cmp	#$4150,d0
	beq.b	CBCB8
	br	_HandleMacroos

CBCB8:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	CBCC6
	br	_HandleMacroos

CBCC6:	move	#$4840,d6
	moveq	#$40,d5
	br	Asm_SWAP

CBCD0:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C251,d0
	beq.b	CBD48
	cmp	#'B@',d0
	beq	CBDD2
	cmp	#'BX',d0
	beq	CBD7E
	cmp	#'BQ',d0
	beq.b	CBD24
	cmp	#'BI',d0
	beq	CBDB8
	cmp	#'BA',d0
	beq.b	CBD5E
	cmp	#$C200,d0
	beq	CBDF6
	cmp	#$C258,d0
	beq	CBDA2
	cmp	#$C249,d0
	beq	CBDF6
	cmp	#$C241,d0
	beq	CBDF6
	br	_HandleMacroos

CBD24:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	CBD48
	cmp	#$C04C,d0
	beq.b	CBD52
	cmp	#$C042,d0
	beq.b	CBD3E
	br	_HandleMacroos

CBD3E:	move	#$5100,d6
	moveq	#0,d5
	br	ASSEM_CMDADDQSUBQ

CBD48:	move	#$5140,d6
	moveq	#$40,d5
	br	ASSEM_CMDADDQSUBQ

CBD52:	move	#$5180,d6
	move	#$0080,d5
	br	ASSEM_CMDADDQSUBQ

CBD5E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq	CBDF6
	cmp	#$C04C,d0
	beq	CBE00
	cmp	#$C042,d0
	beq	ERROR_IllegalSize
	br	_HandleMacroos

CBD7E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	CBDA2
	cmp	#$C04C,d0
	beq.b	CBDAC
	cmp	#$C042,d0
	beq.b	CBD98
	br	_HandleMacroos

CBD98:	move	#$9100,d6
	moveq	#0,d5
	br	CEB92

CBDA2:	move	#$9140,d6
	moveq	#$40,d5
	br	CEB92

CBDAC:	move	#$9180,d6
	move	#$0080,d5
	br	CEB92

CBDB8:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	CBDF6
	cmp	#$C04C,d0
	beq.b	CBE00
	cmp	#$C042,d0
	beq.b	CBDEC
	br	_HandleMacroos

CBDD2:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	CBDF6
	cmp	#$CC00,d0
	beq.b	CBE00
	cmp	#$C200,d0
	beq.b	CBDEC
	br	_HandleMacroos

CBDEC:	move	#$9400,d6	; sub.b
	moveq	#0,d5
	br	Asmbl_AddSubCmp

CBDF6:	move	#$9400,d6	; sub.w
	moveq	#$40,d5
	br	Asmbl_AddSubCmp

CBE00:	move	#$9400,d6	; sub.l
	move	#$0080,d5
	br	Asmbl_AddSubCmp

Asm_SE:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"CT",d0	;SECTion
	beq.b	CBE4C
	cmp	#$D400,d0	;SET
	beq	ASSEM_CMDLABELSET
	cmp	#$D100,d0	;SEQ
	beq.b	CBE6A
	cmp	#"Q@",d0	;SEQ.
	beq.b	CBE2E
	cmp.w	#"TC",d0	;SETCpu
	beq.s	Asm_Setcp
	br	_HandleMacroos

Asm_Setcp:
	move	(a3)+,d0
	and	d4,d0
	cmp.w	#"PU"+$8000,d0
	bne	_HandleMacroos
	jmp	m68_ChangeCpuType

CBE2E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq	ERROR_IllegalSize
	cmp	#$CC00,d0
	beq	ERROR_IllegalSize
	cmp	#$C200,d0
	beq.b	CBE6A
	br	_HandleMacroos

CBE4C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$494F,d0
	beq.b	CBE5A
	br	_HandleMacroos

CBE5A:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CE00,d0
	beq	Asm_SECTION
	br	_HandleMacroos

CBE6A:	move	#$57C0,d6
	moveq	#0,d5
	br	C108B6

CBE74:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D300,d0
	beq.b	CBED0
	cmp	#$C900,d0
	beq.b	CBEDA
	cmp	#$5340,d0
	beq.b	CBEB2
	cmp	#$4940,d0
	beq.b	CBE94
	br	_HandleMacroos

CBE94:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq	ERROR_IllegalSize
	cmp	#$CC00,d0
	beq	ERROR_IllegalSize
	cmp	#$C200,d0
	beq.b	CBEDA
	br	_HandleMacroos

CBEB2:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq	ERROR_IllegalSize
	cmp	#$CC00,d0
	beq	ERROR_IllegalSize
	cmp	#$C200,d0
	beq.b	CBED0
	br	_HandleMacroos

CBED0:	move	#$54C0,d6
	moveq	#0,d5
	br	C108B6

CBEDA:	move	#$52C0,d6
	moveq	#0,d5
	br	C108B6

CBEE4:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CC00,d0
	beq.b	CBF1E
	cmp	#$C300,d0
	beq	ASSEM_CMDSPC
	cmp	#$4C40,d0
	beq.b	CBF00
	br	_HandleMacroos

CBF00:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq	ERROR_IllegalSize
	cmp	#$CC00,d0
	beq	ERROR_IllegalSize
	cmp	#$C200,d0
	beq.b	CBF1E
	br	_HandleMacroos

CBF1E:	move	#$5AC0,d6
	moveq	#0,d5
	br	C108B6

CBF28:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D300,d0
	beq.b	CBF8E
	cmp	#$C300,d0
	beq.b	CBF84
	cmp	#$5340,d0
	beq.b	CBF48
	cmp	#$4340,d0
	beq.b	CBF66
	br	_HandleMacroos

CBF48:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq	ERROR_IllegalSize
	cmp	#$CC00,d0
	beq	ERROR_IllegalSize
	cmp	#$C200,d0
	beq.b	CBF8E
	br	_HandleMacroos

CBF66:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq	ERROR_IllegalSize
	cmp	#$CC00,d0
	beq	ERROR_IllegalSize
	cmp	#$C200,d0
	beq.b	CBF84
	br	_HandleMacroos

CBF84:	move	#$58C0,d6
	moveq	#0,d5
	br	C108B6

CBF8E:	move	#$59C0,d6
	moveq	#0,d5
	br	C108B6

CBF98:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D400,d0
	beq	CC070
	cmp	#$D300,d0
	beq	CC066
	cmp	#$CF00,d0
	beq	CC052
	cmp	#$C500,d0
	beq	CC05C
	cmp	#$5440,d0
	beq.b	CBFD8
	cmp	#$5340,d0
	beq.b	CBFF8
	cmp	#$4F40,d0
	beq.b	CC016
	cmp	#$4540,d0
	beq.b	CC034
	br	_HandleMacroos

CBFD8:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq	ERROR_IllegalSize
	cmp	#$CC00,d0
	beq	ERROR_IllegalSize
	cmp	#$C200,d0
	beq.b	CC070
	br	_HandleMacroos

CBFF8:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq	ERROR_IllegalSize
	cmp	#$CC00,d0
	beq	ERROR_IllegalSize
	cmp	#$C200,d0
	beq.b	CC066
	br	_HandleMacroos

CC016:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq	ERROR_IllegalSize
	cmp	#$CC00,d0
	beq	ERROR_IllegalSize
	cmp	#$C200,d0
	beq.b	CC052
	br	_HandleMacroos

CC034:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq	ERROR_IllegalSize
	cmp	#$CC00,d0
	beq	ERROR_IllegalSize
	cmp	#$C200,d0
	beq.b	CC05C
	br	_HandleMacroos

CC052:	move	#$55C0,d6
	moveq	#0,d5
	br	C108B6

CC05C:	move	#$5FC0,d6
	moveq	#0,d5
	br	C108B6

CC066:	move	#$53C0,d6
	moveq	#0,d5
	br	C108B6

CC070:	move	#$5DC0,d6
	moveq	#0,d5
	br	C108B6

CC07A:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C500,d0
	beq.b	CC0AC
	cmp	#$4540,d0
	beq.b	CC08E
	br	_HandleMacroos

CC08E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq	ERROR_IllegalSize
	cmp	#$CC00,d0
	beq	ERROR_IllegalSize
	cmp	#$C200,d0
	beq.b	CC0AC
	br	_HandleMacroos

CC0AC:	move	#$56C0,d6
	moveq	#0,d5
	br	C108B6

CC0B6:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C900,d0
	beq.b	CC0E8
	cmp	#$4940,d0
	beq.b	CC0CA
	br	_HandleMacroos

CC0CA:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq	ERROR_IllegalSize
	cmp	#$CC00,d0
	beq	ERROR_IllegalSize
	cmp	#$C200,d0
	beq.b	CC0E8
	br	_HandleMacroos

CC0E8:	move	#$5BC0,d6
	moveq	#0,d5
	br	C108B6

CC0F2:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D400,d0
	beq.b	CC158
	cmp	#$C500,d0
	beq.b	CC14E
	cmp	#$5440,d0
	beq.b	CC130
	cmp	#$4540,d0
	beq.b	CC112
	br	_HandleMacroos

CC112:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq	ERROR_IllegalSize
	cmp	#$CC00,d0
	beq	ERROR_IllegalSize
	cmp	#$C200,d0
	beq.b	CC14E
	br	_HandleMacroos

CC130:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq	ERROR_IllegalSize
	cmp	#$CC00,d0
	beq	ERROR_IllegalSize
	cmp	#$C200,d0
	beq.b	CC158
	br	_HandleMacroos

CC14E:	move	#$5CC0,d6
	moveq	#0,d5
	br	C108B6

CC158:	move	#$5EC0,d6
	moveq	#0,d5
	br	C108B6

AsmT:
	cmp	#'TS',d0
	beq.b	Asm_TS
	cmp	#'TA',d0
	beq	CC51E
	cmp	#'TR',d0
	beq	CC2BC
	cmp	#'TT',d0
	beq.b	CC188
	cmp	#'TE',d0
	beq.b	Asm_TE
	br	_HandleMacroos

CC188:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"L"<<(1*8)+$8000,d0
	beq	ASSEM_CMDTTL
	br	_HandleMacroos

Asm_TS:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"T@",d0
	beq	CC282
	cmp	#"T"<<(1*8)+$8000,d0
	beq	Asm_tsT
	br	_HandleMacroos

SkippedToNewLine:
	move.l	a6,(DATA_LINE_START_PTR-DT,a4)
	addq.l	#1,(DATA_CURRENTLINE-DT,a4)
	INSERT_DEBUG		; trashes d0/d1/a0
	rts

Asm_TE:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"XT"+$8000,d0
	bne	_HandleMacroos

Asm_CmdTEXT:
	tst	(MACRO_LEVEL-DT,a4)
	bne.b	.CC24A
	sf	(Asm_TextHexMode-DT,a4)
.CC1CA	tst.b	(a6)+
	bne.b	.CC1CA
	bsr.b	SkippedToNewLine	; trashes d0/d1/a0
.Loop	move.b	(a6)+,d2
	bne.b	.SameLine
	bsr.b	SkippedToNewLine	; trashes d0/d1/a0
.SameLine
	cmp.b	#SRCMARK_END,d2
	beq.b	.CC23C
	moveq	#~32,d0
	and.b	d2,d0
	cmp.b	#'E',d0
	bne.b	.NextChar
	move.l	a6,a0
	lea	(TEXTwithoutET.MSG-DT,a4),a1
	moveq	#4-1,d2			; look for 4 chars 'TEXT'
.CheckIfEnd
	moveq	#~32,d0
	and.b	(a0)+,d0
	cmp.b	(a1)+,d0
	bne.b	.NextChar
	dbf	d2,.CheckIfEnd

.CC22A	subq.l	#1,(INSTRUCTION_ORG_PTR-DT,a4)
	tst.b	-(a6)
	bne.b	.CC22A
	addq.l	#2,(INSTRUCTION_ORG_PTR-DT,a4)
	addq.w	#2,a6
.CC238	tst.b	(a6)+
	bne.b	.CC238
.CC23C	subq.w	#1,a6
	cmp.b	#SRCMARK_END,(a6)
	beq.b	.EndMissing
.CC24A	rts

.EndMissing
	bclr	#AF_ALLERRORS,d7
	bra	ERROR_TEXTwithoutETEXT

.NextChar
	tst	d7	;passone
	bmi.b	.p1
.p2	move.l	(INSTRUCTION_ORG_PTR-DT,a4),a0
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
	cmp.b	#'|',d2		; toggle hex mode?
	bne.b	.CC268
	not.b	(Asm_TextHexMode-DT,a4)
	bra.w	.Loop
.p1	cmp.b	#'|',d2
	bne.b	.Next
	bra.w	.Loop
.CC268	tst.b	(Asm_TextHexMode-DT,a4)
	beq.b	.Txt
	sub.b	#'0',d2
.Txt	move.b	d2,(a0)
.Next	addq.l	#1,(INSTRUCTION_ORG_PTR-DT,a4)
	bra.w	.Loop

CC282:	; tst.
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0	; tst.w
	beq.b	Asm_tsT
	cmp	#$C200,d0	; tst.b
	beq.b	CC29C
	cmp	#$CC00,d0	; tst.l
	beq.b	CC2B0
	br	_HandleMacroos

CC29C:	move	#$4A00,d6
	moveq	#0,d5
	br	ASSEM_CMDCLRNOTTST

Asm_tsT:
	move	#$4A40,d6
	moveq	#$40,d5
	br	ASSEM_CMDCLRNOTTST

CC2B0:	move	#$4A80,d6
	move	#$0080,d5
	br	ASSEM_CMDCLRNOTTST

CC2BC:	;tr
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C150,d0
	beq	CC512
	cmp	#$4150,d0
	beq.b	CC2D2
	br	_HandleMacroos

CC2D2:	;trap
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D600,d0
	beq	CC506
	cmp	#$CE45,d0
	beq	CC45A
	cmp	#$C551,d0
	beq	CC452
	cmp	#$C745,d0
	beq	CC44A
	cmp	#$CC45,d0
	beq	CC442
	cmp	#$C754,d0
	beq	CC43A
	cmp	#$CC54,d0
	beq	CC432
	cmp	#$C849,d0
	beq	CC42A
	cmp	#$CC53,d0
	beq	CC422
	cmp	#$C343,d0
	beq	CC41A
	cmp	#$C353,d0
	beq	CC412
	cmp	#$D643,d0
	beq	CC40A
	cmp	#$D653,d0
	beq	CC402
	cmp	#$D04C,d0
	beq	CC3FA
	cmp	#$CD49,d0
	beq	CC3F2
	cmp	#$D400,d0
	beq	CC3E2
	cmp	#$C600,d0
	beq	CC3EA
	cmp	#'T@',d0
	beq	CC462
	cmp	#'F@',d0
	beq	CC476
	cmp	#'HI',d0
	beq	CC4B4
	cmp	#'LS',d0
	beq	CC4AE
	cmp	#'CC',d0
	beq	CC4A8
	cmp	#'CS',d0
	beq	CC4A2
	cmp	#'NE',d0
	beq	CC4D8
	cmp	#'EQ',d0
	beq	CC4D2
	cmp	#'VC',d0
	beq	CC49C
	cmp	#'VS',d0
	beq	CC496
	cmp	#'PL',d0
	beq	CC490
	cmp	#'MI',d0
	beq	CC48A
	cmp	#'GE',d0
	beq	CC4CC
	cmp	#'LE',d0
	beq	CC4C6
	cmp	#'GT',d0
	beq	CC4C0
	cmp	#'LT',d0
	beq	CC4BA
	br	_HandleMacroos

CC3E2:	move	#$50FA,d6
	bra.w	Asm_TrapccNoOperand

CC3EA:	move	#$51FA,d6
	bra.w	Asm_TrapccNoOperand

CC3F2:	move	#$5BFA,d6
	bra.w	Asm_TrapccNoOperand

CC3FA:	move	#$5AFA,d6
	bra.w	Asm_TrapccNoOperand

CC402:	move	#$59FA,d6
	bra.w	Asm_TrapccNoOperand

CC40A:	move	#$58FA,d6
	bra.w	Asm_TrapccNoOperand

CC412:	move	#$55FA,d6
	bra.w	Asm_TrapccNoOperand

CC41A:	move	#$54FA,d6
	bra.w	Asm_TrapccNoOperand

CC422:	move	#$53FA,d6
	bra.w	Asm_TrapccNoOperand

CC42A:	move	#$52FA,d6
	bra.w	Asm_TrapccNoOperand

CC432:	move	#$5DFA,d6
	bra.w	Asm_TrapccNoOperand

CC43A:	move	#$5EFA,d6
	bra.w	Asm_TrapccNoOperand

CC442:	move	#$5FFA,d6
	bra.w	Asm_TrapccNoOperand

CC44A:	move	#$5CFA,d6
	bra.w	Asm_TrapccNoOperand

CC452:	move	#$57FA,d6
	bra.w	Asm_TrapccNoOperand

CC45A:	move	#$56FA,d6
	bra.w	Asm_TrapccNoOperand

CC462:
	move.w	#$c05f,d0
	and.b	(a3),d0
	move.w	d0,(a3)
	move	#$50FA,d6
	bra.b	CC4E0

CC476:
	move.w	#$c05f,d0
	and.b	(a3),d0
	move.w	d0,(a3)
	move	#$51FA,d6
	bra.b	CC4E0

CC48A:	move	#$5BFA,d6
	bra.b	CC4E0

CC490:	move	#$5AFA,d6
	bra.b	CC4E0

CC496:	move	#$59FA,d6
	bra.b	CC4E0

CC49C:	move	#$58FA,d6
	bra.b	CC4E0

CC4A2:	move	#$55FA,d6
	bra.b	CC4E0

CC4A8:	move	#$54FA,d6
	bra.b	CC4E0

CC4AE:	move	#$53FA,d6
	bra.b	CC4E0

CC4B4:	move	#$52FA,d6
	bra.b	CC4E0

CC4BA:	move	#$5DFA,d6
	bra.b	CC4E0

CC4C0:	move	#$5EFA,d6
	bra.b	CC4E0

CC4C6:	move	#$5FFA,d6
	bra.b	CC4E0

CC4CC:	move	#$5CFA,d6
	bra.b	CC4E0

CC4D2:	move	#$57FA,d6
	bra.b	CC4E0

CC4D8:	move	#$56FA,d6

CC4E0:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	CC4FE
	cmp	#$C04C,d0
	bne	ERROR_IllegalSize
	move	#$0080,d5
	bset	#0,d6
	br	CFEE2

CC4FE:	moveq	#$0040,d5
	br	CFEE2

CC506:	move	#$4E76,d6
	move	#$8040,d5
	br	Asm_InsertinstrA5

CC512:	move	#$4E40,d6
	move	#$8040,d5
	br	C10830

CC51E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D300,d0
	beq.b	CC550
	cmp	#$5340,d0
	beq.b	CC532
	br	_HandleMacroos

CC532:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq	ERROR_IllegalSize
	cmp	#$CC00,d0
	beq	ERROR_IllegalSize
	cmp	#$C200,d0
	beq.b	CC550
	br	_HandleMacroos

CC550:	move	#$4AC0,d6
	moveq	#0,d5
	br	C108B6

AsmU:
	cmp	#'UN',d0
	beq.b	CC564
	br	_HandleMacroos

CC564:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"LK"+$8000,d0
	beq.b	CC578
	cmp	#"PK"+$8000,d0
	beq.b	CC582
	bra.b	_HandleMacroos

CC578:	move	#$4E58,d6
	moveq	#$40,d5
	br	Asm_UNLK

CC582:	move	#$8180,d6
	moveq	#0,d5
	br	Asm_PackUnpk

AsmX:
	cmp	#'XR',d0
	beq.b	CC59C
	cmp	#'XD',d0
	beq.b	CC5AC
	bra.b	_HandleMacroos

CC59C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"EF"+$8000,d0
	beq	CD75C
	bra.b	_HandleMacroos

CC5AC:
	move	(a3)+,d0
	and	d4,d0

	cmp	#"EF"+$8000,d0
	beq	CD778
	bra.b	_HandleMacroos

;***********************************************

ConditionAssembl:
	dc.w	_HandleMacroos-ConditionAssembl
	dc.w	CC5FA-ConditionAssembl
	dc.w	CC614-ConditionAssembl
	dc.w	CC64A-ConditionAssembl
	dc.w	CC688-ConditionAssembl
	dc.w	CC6DA-ConditionAssembl		; E
	dc.w	CC7B8-ConditionAssembl
	dc.w	CC7D2-ConditionAssembl
	dc.w	_HandleMacroos-ConditionAssembl
	dc.w	CC802-ConditionAssembl
	dc.w	CC926-ConditionAssembl
	dc.w	_HandleMacroos-ConditionAssembl
	dc.w	CC95C-ConditionAssembl
	dc.w	CC9A2-ConditionAssembl
	dc.w	CCA04-ConditionAssembl
	dc.w	CCA4A-ConditionAssembl
	dc.w	CCA9E-ConditionAssembl
	dc.w	_HandleMacroos-ConditionAssembl
	dc.w	CCAFA-ConditionAssembl
	dc.w	CCB9C-ConditionAssembl		; S
	dc.w	CCBF0-ConditionAssembl
	dc.w	_HandleMacroos-ConditionAssembl
	dc.w	_HandleMacroos-ConditionAssembl
	dc.w	_HandleMacroos-ConditionAssembl
	dc.w	CCC0A-ConditionAssembl
	dc.w	_HandleMacroos-ConditionAssembl
	dc.w	_HandleMacroos-ConditionAssembl
	dc.w	_HandleMacroos-ConditionAssembl

_HandleMacroos:
	jmp	HandleMacroos

CC5FA:
	cmp	#'AU',d0
	beq.b	CC604
	bra.b	_HandleMacroos

CC604:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D44F,d0
	beq	Asm_AUTO
	bra.b	_HandleMacroos

CC614:
	cmp	#'BA',d0
	beq.b	CC61E
	bra.b	_HandleMacroos

CC61E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#'SE',d0
	beq.b	CC62C
	bra.b	_HandleMacroos

CC62C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$5245,d0
	beq.b	CC63A
	bra.b	_HandleMacroos

CC63A:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C700,d0
	beq	Asm_BASEREG
	bra.b	_HandleMacroos

CC64A:
	cmp	#$434E,d0
	beq.b	CC678
	cmp	#$434D,d0
	beq.b	CC65A
	bra.b	_HandleMacroos

CC65A:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$4558,d0
	beq.b	CC668
	bra.b	_HandleMacroos

CC668:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"IT"+$8000,d0
	beq	Asm_CMEXIT
	bra.b	_HandleMacroos

CC678:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CF50,d0
	beq	Asm_CNOP
	bra.b	_HandleMacroos

CC688:
	cmp	#$4453,d0
	beq.b	CC69A
	cmp	#$C453,d0
	beq	CE190
	br	_HandleMacroos

CC69A:	; DS
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C042,d0
	beq	CE16A
	cmp	#$C057,d0
	beq	CE190
	cmp	#$C04C,d0
	beq	CE1B6
	cmp	#$C053,d0
	beq	CE1B6
	cmp	#$C044,d0
	beq	CE1DC
	cmp	#$C058,d0
	beq	CE202
	cmp	#$C050,d0
	beq	CE202
	br	_HandleMacroos

CC6DA:
	cmp	#'EN',d0
	beq.b	CC744
	cmp	#'EQ',d0
	beq.b	CC71C
	cmp	#'EV',d0
	beq.b	CC734
	cmp	#'EL',d0
	beq	CC7A8
	cmp	#'EX',d0
	beq.b	CC6FE
	br	_HandleMacroos

CC6FE:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$5452,d0
	beq.b	CC70C
	br	_HandleMacroos

CC70C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CE00,d0
	beq	CD75C
	br	_HandleMacroos

CC71C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D500,d0
	beq	Asm_EQU
	cmp	#$D552,d0
	beq	Asm_EQUR
	br	_HandleMacroos

CC734:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C54E,d0
	beq	ASSEM_CMDEVEN
	br	_HandleMacroos

CC744:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C452,d0
	beq	Asm_ENDR
	cmp	#"DM"+$8000,d0
	beq	Asm_ENDM
	cmp	#$C443,d0
	beq	ASSEM_CMDENDC
	cmp	#'DC',d0
	beq	C6BCC
	cmp	#'DI',d0
	beq.b	CC798
	cmp	#$5452,d0
	beq.b	CC788
	cmp	#$C400,d0
	beq	ASSEM_CMDEND
	cmp	#$C442,d0
	beq	Asm_ENDB
	br	_HandleMacroos

CC788:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D900,d0
	beq	CD778
	br	_HandleMacroos

CC798:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C600,d0
	beq	ASSEM_CMDENDC
	br	_HandleMacroos

CC7A8:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D345,d0
	beq	ASSEM_CMDELSE
	br	_HandleMacroos

CC7B8:
	cmp	#$4641,d0
	beq.b	CC7C2
	br	_HandleMacroos

CC7C2:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C94C,d0
	beq	ERROR_UsermadeFAIL
	br	_HandleMacroos

CC7D2:
	cmp	#$474C,d0
	beq.b	CC7DC
	br	_HandleMacroos

CC7DC:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$4F42,d0
	beq.b	CC7EA
	br	_HandleMacroos

CC7EA:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CC00,d0
	beq	CD778
	cmp	#$C14C,d0
	beq	CD778
	br	_HandleMacroos

CC802:
	cmp	#$C946,d0
	beq	ASSEM_CMDIFNE
	cmp	#'IF',d0
	beq	CC8AE
	cmp	#'IN',d0
	beq.b	CC856
	cmp	#'IM',d0
	beq.b	CC828
	cmp	#'ID',d0
	beq.b	CC846
	br	_HandleMacroos

CC828:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$4147,d0
	beq.b	CC836
	br	_HandleMacroos

CC836:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C500,d0
	beq	IncBinStuff
	br	_HandleMacroos

CC846:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CE54,d0
	beq	ASSEM_CMDIDNT
	br	_HandleMacroos

CC856:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$434C,d0
	beq.b	CC880
	cmp	#$4342,d0
	beq.b	CC870
	cmp	#$4344,d0
	beq.b	CC89E
	br	_HandleMacroos

CC870:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C94E,d0
	beq	IncBinStuff
	br	_HandleMacroos

CC880:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$5544,d0
	beq.b	CC88E
	br	_HandleMacroos

CC88E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C500,d0
	beq	Asm_Include
	br	_HandleMacroos

CC89E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C952,d0
	beq	Asm_INCDIR
	br	_HandleMacroos

CC8AE:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CE45,d0
	beq	ASSEM_CMDIFNE
	cmp	#$CE44,d0
	beq	ASSEM_CMDIFND
	cmp	#$CE43,d0
	beq	ASSEM_CMDIFNC
	cmp	#$CE42,d0
	beq	ASSEM_CMDIFNB
	cmp	#$CC54,d0
	beq	ASSEM_CMDIFLT
	cmp	#$CC45,d0
	beq	ASSEM_CMDIFLE
	cmp	#$C754,d0
	beq	ASSEM_CMDIFGT
	cmp	#$C745,d0
	beq	ASSEM_CMDIFGE
	cmp	#$C551,d0
	beq	ASSEM_CMDIFEQ
	cmp	#$C400,d0
	beq	ASSEM_CMDIFD
	cmp	#$C300,d0
	beq	ASSEM_CMDIFC
	cmp	#$C200,d0
	beq	ASSEM_CMDIFB
	cmp	#$9200,d0
	beq	ASSEM_CMDIF2
	cmp	#$9100,d0
	beq	ASSEM_CMDIF1
	br	_HandleMacroos

CC926:
	cmp	#'JU',d0
	beq.b	CC930
	br	_HandleMacroos

CC930:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$4D50,d0
	beq.b	CC93E
	br	_HandleMacroos

CC93E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$5054,d0
	beq.b	CC94C
	br	_HandleMacroos

CC94C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D200,d0
	beq	CD6D0
	br	_HandleMacroos

CC95C:
	cmp	#$4C4F,d0
	beq.b	CC972
	cmp	#$4C4C,d0
	beq.b	CC992
	cmp	#$4C49,d0
	beq.b	CC982
	br	_HandleMacroos

CC972:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C144,d0
	beq	Asm_LOAD
	br	_HandleMacroos

CC982:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D354,d0
	beq	ASSEM_CMDLIST
	br	_HandleMacroos

CC992:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C54E,d0
	beq	ASSEM_CMDLLEN
	br	_HandleMacroos

CC9A2:
	cmp	#'ME',d0
	beq.b	CC9E6
	cmp	#'MA',d0
	beq.b	CC9B2
	br	_HandleMacroos

CC9B2:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$4352,d0
	beq.b	CC9D6
	cmp	#$534B,d0
	beq.b	CC9C6
	br	_HandleMacroos

CC9C6:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$9200,d0
	beq	ASSEM_MASK2
	br	_HandleMacroos

CC9D6:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CF00,d0
	beq	GoGoMacro
	br	_HandleMacroos

CC9E6:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$5849,d0
	beq.b	CC9F4
	br	_HandleMacroos

CC9F4:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D400,d0
	beq	Asm_MEXIT
	br	_HandleMacroos

CCA04:
	cmp	#$4E4F,d0
	beq.b	CCA0E
	br	_HandleMacroos

CCA0E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CC00,d0
	beq	ASSEM_CMDNOLIST
	cmp	#'PA',d0
	beq.b	CCA2A
	cmp	#'LI',d0
	beq.b	CCA3A
	br	_HandleMacroos

CCA2A:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C745,d0
	beq	ASSEM_CMDNOPAGE
	br	_HandleMacroos

CCA3A:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D354,d0
	beq	ASSEM_CMDNOLIST
	br	_HandleMacroos

CCA4A:
	cmp	#'OF',d0
	beq.b	CCA80
	cmp	#'OD',d0
	beq.b	CCA70
	cmp	#'OR',d0
	beq.b	CCA60
	br	_HandleMacroos

CCA60:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C700,d0
	beq	Asm_ORG
	br	_HandleMacroos

CCA70:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C400,d0
	beq	ASSEM_CMDODD
	br	_HandleMacroos

CCA80:
	move	(a3)+,d0
	and	d4,d0
	cmp	#'FS',d0
	beq.b	CCA8E
	br	_HandleMacroos

CCA8E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C554,d0
	beq	ASSEM_CMDOFFSET
	br	_HandleMacroos

CCA9E:
	cmp	#'PR',d0
	beq.b	CCAB4
	cmp	#'PL',d0
	beq.b	CCAEA
	cmp	#'PA',d0
	beq.b	CCADA
	br	_HandleMacroos

CCAB4:
	move	(a3)+,d0
	and	d4,d0
	cmp	#'IN',d0
	beq.b	CCAC2
	br	_HandleMacroos

CCAC2:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D456,d0
	beq	Asm_PRINTV
	cmp	#$D454,d0
	beq	Asm_PRINTT
	br	_HandleMacroos

CCADA:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C745,d0
	beq	ASSEM_CMDPAGE
	br	_HandleMacroos

CCAEA:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C54E,d0
	beq	ASSEM_CMDPLEN
	br	_HandleMacroos

CCAFA:
	cmp	#'RS',d0
	beq.b	CCB32
	cmp	#'RE',d0
	beq.b	CCB1A
	cmp	#'RO',d0
	beq	CCB8C
	cmp	#'RS'+$8000,d0
	beq	ASSEM_CMDRS_W
	br	_HandleMacroos

CCB1A:
	move	(a3)+,d0
	and	d4,d0
	cmp	#'PT'+$8000,d0
	beq	Asm_REPT
	cmp	#('G'<<8)+$8000,d0
	beq	Asm_REG
	cmp	#('M'<<8)+$8000,d0
	beq	Asm_CmdREM
	br	_HandleMacroos

CCB32:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq	ASSEM_CMDRS_W
	cmp	#$C04C,d0
	beq	ASSEM_CMDRS_L
	cmp	#$C042,d0
	beq	ASSEM_CMDRS_B
	cmp	#$5345,d0
	beq.b	CCB7C
	cmp	#$5245,d0
	beq.b	CCB5E
	br	_HandleMacroos

CCB5E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$5345,d0
	beq.b	CCB6C
	br	_HandleMacroos

CCB6C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D400,d0
	beq	ASSEM_CMDRSRESET
	br	_HandleMacroos

CCB7C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D400,d0
	beq	ASSEM_CMDRSSET
	br	_HandleMacroos

CCB8C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D247,d0
	beq	C7576
	br	_HandleMacroos

CCB9C:
	cmp	#'SE',d0
	beq.b	CCBBC
	cmp	#'SP',d0
	beq.b	CCBAC
	br	_HandleMacroos

CCBAC:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C300,d0
	beq	ASSEM_CMDSPC
	br	_HandleMacroos

CCBBC:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D400,d0
	beq	ASSEM_CMDLABELSET_COND
	cmp	#'CT',d0
	beq.b	CCBD2
	br	_HandleMacroos

CCBD2:
	move	(a3)+,d0
	and	d4,d0
	cmp	#'IO',d0
	beq.b	CCBE0
	br	_HandleMacroos

CCBE0:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CE00,d0
	beq	Asm_SECTION
	br	_HandleMacroos

CCBF0:
	cmp	#'TT',d0
	beq.b	CCBFA
	br	_HandleMacroos

CCBFA:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CC00,d0
	beq	ASSEM_CMDTTL
	br	_HandleMacroos

CCC0A:
	cmp	#'XR',d0
	beq.b	CCC1A
	cmp	#'XD',d0
	beq.b	CCC2A
	br	_HandleMacroos

CCC1A:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C546,d0
	beq	CD75C
	br	_HandleMacroos

CCC2A:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C546,d0
	beq	CD778
	br	_HandleMacroos

;************ ERROR MSGS *************

ERROR_AddressRegByte:	bsr	ShowErrorMsg
ERROR_AddressRegExp:	bsr	ShowErrorMsg
ERROR_Dataregexpect:	bsr	ShowErrorMsg
ERROR_DoubleSymbol:	bsr	ShowErrorMsg
ERROR_EndofFile:	bsr	ShowErrorMsg
ERROR_UsermadeFAIL:	bsr	ShowErrorMsg
ERROR_FileError:	bsr	ShowErrorMsg
ERROR_InvalidAddrMode:	bsr	ShowErrorMsg
ERROR_IllegalDevice:	bsr	ShowErrorMsg
ERROR_IllegalMacrod:	bsr	ShowErrorMsg
ERROR_IllegalOperator:	bsr	ShowErrorMsg
ERROR_IllegalOperatorInBSS:	bsr	ShowErrorMsg
ERROR_IllegalOperand:	bsr	ShowErrorMsg
ERROR_IllegalOrder:	bsr	ShowErrorMsg
ERROR_IllegalSectio:	bsr	ShowErrorMsg
ERROR_IllegalAddres:	bsr	ShowErrorMsg
ERROR_Illegalregsiz:	bsr	ShowErrorMsg
ERROR_IllegalPath:	bsr	ShowErrorMsg
ERROR_IllegalSize:	bsr	ShowErrorMsg
ERROR_IllegalComman:	bsr	ShowErrorMsg
ERROR_Immediateoper:	bsr	ShowErrorMsg
ERROR_IncludeJam:	bsr	ShowErrorMsg
ERROR_Commaexpected:	bsr	ShowErrorMsg
ERROR_LOADwithoutOR:	bsr	ShowErrorMsg
ERROR_Macrooverflow:	bsr	ShowErrorMsg
ERROR_Conditionalov:	bsr	ShowErrorMsg
ERROR_WorkspaceMemoryFull:	bsr	ShowErrorMsg
ERROR_MissingQuote:	bsr	ShowErrorMsg
ERROR_Notinmacro:	bsr	ShowErrorMsg
ERROR_Notdone:		bsr	ShowErrorMsg
ERROR_NoFileSpace:	bsr	ShowErrorMsg
ERROR_NoFiles:		bsr	ShowErrorMsg
ERROR_Nodiskindrive:	bsr	ShowErrorMsg
ERROR_NOoperandspac:	bsr	ShowErrorMsg
ERROR_NOTaconstantl:	bsr	ShowErrorMsg
ERROR_NoObject:		bsr	ShowErrorMsg
;ERROR_out_of_range0bit:	bsr	ShowErrorMsg
ERROR_out_of_range3bit:	bsr	ShowErrorMsg
ERROR_out_of_range4bit:	bsr	ShowErrorMsg
ERROR_out_of_range8bit:	bsr	ShowErrorMsg
ERROR_out_of_range16bit:	bsr	ShowErrorMsg
ERROR_RelativeModeEr:	bsr	ShowErrorMsg
ERROR_ReservedWord:	bsr	ShowErrorMsg
ERROR_Rightparenthe:	bsr	ShowErrorMsg
ERROR_Stringexpected:	bsr	ShowErrorMsg
ERROR_Sectionoverflow:	bsr	ShowErrorMsg
ERROR_Registerexpected:	bsr	ShowErrorMsg
ERROR_UndefSymbol:	bsr	ShowErrorMsg
ERROR_UnexpectedEOF:	bsr	ShowErrorMsg
ERROR_WordatOddAddress:	bsr	ShowErrorMsg
ERROR_WriteProtected:	bsr	ShowErrorMsg
ERROR_Notlocalarea:	bsr	ShowErrorMsg
ERROR_Codemovedduring:	bsr	ShowErrorMsg
ERROR_BccBoutofrange:	bsr	ShowErrorMsg
ERROR_Outofrange20t:	bsr	ShowErrorMsg
ERROR_Outofrange60t:	bsr	ShowErrorMsg
ERROR_Includeoverflow:	bsr	ShowErrorMsg
ERROR_Linkerlimitation:	bsr	ShowErrorMsg
ERROR_Repeatoverflow:	bsr	ShowErrorMsg
ERROR_NotinRepeatar:	bsr	ShowErrorMsg
ERROR_Doubledefinition:	bsr	ShowErrorMsg
ERROR_Relocationmade:	bsr	ShowErrorMsg
;ERROR_Illegaloption:	bsr	ShowErrorMsg
ERROR_REMwithoutEREM:	bsr	ShowErrorMsg
ERROR_TEXTwithoutETEXT:	bsr	ShowErrorMsg
ERROR_Illegalscales:	bsr	ShowErrorMsg
ERROR_Offsetwidthex:	bsr	ShowErrorMsg
ERROR_OutofRange5bit:	bsr	ShowErrorMsg
ERROR_Missingbrace:	bsr	ShowErrorMsg
ERROR_Colonexpected:	bsr	ShowErrorMsg
ERROR_MissingBracket:	bsr	ShowErrorMsg
ERROR_Illegalfloating:	bsr	ShowErrorMsg
ERROR_Illegalsizeform:	bsr	ShowErrorMsg
;ERROR_BccWoutofrange:	bsr	ShowErrorMsg
ERROR_Floatingpoint:	bsr	ShowErrorMsg
;ERROR_OutofRange6bit:	bsr	ShowErrorMsg
ERROR_OutofRange7bit:	bsr	ShowErrorMsg
ERROR_FPUneededforopp:	bsr	ShowErrorMsg
ERROR_Tomanywatchpoints:	bsr	ShowErrorMsg
ERROR_Illegalsource:	bsr	ShowErrorMsg
ERROR_Novalidmemory:	bsr	ShowErrorMsg
;ERROR_Autocommandoverflow:	bsr	ShowErrorMsg
ERROR_Endshouldbehind:	bsr	ShowErrorMsg
;ERROR_Warningvalues:	bsr	ShowErrorMsg
ERROR_IllegalsourceNr:	bsr	ShowErrorMsg
ERROR_Includingempty:	bsr	ShowErrorMsg
ERROR_IncludeSource:	bsr	ShowErrorMsg
ERROR_UnknownconversionMode:	bsr	ShowErrorMsg
ERROR_Unknowncmapplace:	bsr	ShowErrorMsg
ERROR_Unknowncmapmode:	bsr	ShowErrorMsg
ERROR_TryingtoincludenonILBM:	bsr	ShowErrorMsg
ERROR_IFFfileisnotaILBM:	bsr	ShowErrorMsg
ERROR_CanthandleBODYbBMHD:	bsr	ShowErrorMsg
ERROR_ThisisnotaAsmProj:	bsr	ShowErrorMsg
;ERROR_Bitfieldoutofrange32bit:	bsr	ShowErrorMsg
	IF	PPC
ERROR_GeneralPurpose:	bsr	ShowErrorMsg
	ENDIF
;ERROR_AdrOrPCExpected:	bsr	ShowErrorMsg
ERROR_UnknowCPU:	bsr	ShowErrorMsg
ERROR_StackFull:	bsr	ShowErrorMsg

CondAsmE:
	cmp	#'EN',d0
	beq.b	CCDC6
	cmp	#'EL',d0
	beq.b	CCDFC
	br	_HandleMacroos

CCDC6:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C443,d0
	beq	ASSEM_CMDENDC
	cmp	#'DC',d0
	beq	C6BCC
	cmp	#$4449,d0
	beq.b	CCDEC
	cmp	#"DM"+$8000,d0
	beq	Asm_ENDM
	br	_HandleMacroos

CCDEC:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C600,d0
	beq	ASSEM_CMDENDC
	br	_HandleMacroos

CCDFC:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D345,d0
	beq	ASSEM_CMDELSE
	br	_HandleMacroos

CondAsmI:
	cmp	#$C946,d0
	beq	ASSEM_CMD_ALWAYS_FALSE
	cmp	#'IF',d0
	beq.b	CCE1E
	br	_HandleMacroos

CCE1E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CE45,d0
	beq	ASSEM_CMD_ALWAYS_FALSE
	cmp	#$CE44,d0
	beq	ASSEM_CMD_ALWAYS_FALSE
	cmp	#$CE43,d0
	beq	ASSEM_CMD_ALWAYS_FALSE
	cmp	#$CE42,d0
	beq	ASSEM_CMD_ALWAYS_FALSE
	cmp	#$CC54,d0
	beq	ASSEM_CMD_ALWAYS_FALSE
	cmp	#$CC45,d0
	beq	ASSEM_CMD_ALWAYS_FALSE
	cmp	#$C754,d0
	beq	ASSEM_CMD_ALWAYS_FALSE
	cmp	#$C745,d0
	beq	ASSEM_CMD_ALWAYS_FALSE
	cmp	#$C551,d0
	beq	ASSEM_CMD_ALWAYS_FALSE
	cmp	#$C400,d0
	beq	ASSEM_CMD_ALWAYS_FALSE
	cmp	#$C300,d0
	beq	ASSEM_CMD_ALWAYS_FALSE
	cmp	#$C200,d0
	beq	ASSEM_CMD_ALWAYS_FALSE
	cmp	#$9200,d0
	beq	ASSEM_CMD_ALWAYS_FALSE
	cmp	#$9100,d0
	beq	ASSEM_CMD_ALWAYS_FALSE
	br	_HandleMacroos

CondAsmM:
	cmp	#'MA',d0
	beq.b	CCEA0
	br	_HandleMacroos

CCEA0:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$4352,d0
	beq.b	CCEAE
	br	_HandleMacroos

CCEAE:
	move	(a3)+,d0
CCEB0:
	and	d4,d0
	cmp	#$CF00,d0
	beq	GoGoMacro
	br	_HandleMacroos

;********** INCIFF STUFF *************

AsmIncIFFOK:
	movem.l	d0-d7/a0-a5,-(sp)
	bclr	#AF_INC_ASSIGN,d7
	jsr	(HandleIncFileFromSrc)
	clr.b	(IncIff_tiepe-DT,a4)
	clr.b	(IncIff_colmap_pos-DT,a4)
	cmp.b	#',',(a6)
	bne	.ECScols
	addq.w	#1,a6
	IF	MC020
	move.w	(a6)+,d0
	ELSE
	move.b	(a6)+,d0
	lsl.w	#8,d0
	move.b	(a6)+,d0
	ENDIF
	and	#$DFDF,d0
	cmp	#'RB',d0
	beq.b	.rawblit
	cmp	#'RN',d0
	bne.w	ERROR_UnknownconversionMode
.rawnormal
	st	(IncIff_tiepe-DT,a4)
.rawblit
	cmp.b	#',',(a6)
	bne.b	.ECScols
	addq.w	#1,a6
	moveq	#~32,d0
	and.b	(a6)+,d0
	cmp.b	#'B',d0
	beq.b	.before
	cmp.b	#'A',d0
	beq.b	.after
	cmp.b	#'N',d0
	beq.b	.none
	br	ERROR_Unknowncmapplace

.after	addq.b	#1,(IncIff_colmap_pos-DT,a4)
.before	addq.b	#1,(IncIff_colmap_pos-DT,a4)
.none	cmp.b	#',',(a6)
	bne.b	.ECScols
	IF	MC020
	move.l	(a6)+,d0
	ELSE
	addq.w	#1,a6
	move.b	(a6)+,d0
	swap	d0
	move.b	(a6)+,d0
	lsl.w	#8,d0
	move.b	(a6)+,d0
	ENDIF
	and.l	#$00DFDFDF,d0
	cmp.l	#"ECS",d0
	beq.b	.ECScols
	cmp.l	#"AGA",d0
	bne.w	ERROR_Unknowncmapmode
.AGAcols
	or.b	#$80,(IncIff_colmap_pos-DT,a4)
.ECScols
	move.l	a6,(IffA6Backup-DT,a4)
	move.l	#4096,d0
	move.l	#$00010001,d1
	move.l	a6,-(sp)
	move.l	(4).w,a6
	jsr	(_LVOAllocMem,a6)
	move.l	(sp)+,a6
	move.l	d0,(buffer_ptr-DT,a4)
	beq	ERROR_WorkspaceMemoryFull
	jsr	(OpenOldFile)
	move.l	(Bestand-DT,a4),d1
	move.l	(buffer_ptr-DT,a4),d2
	moveq	#12,d3
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVORead,a6)
	move.l	d3,(IncIff_filepos-DT,a4)
	move.l	d2,a0
	cmp.l	#"FORM",(a0)+
	bne	IncIff_noFORM
	move.l	(a0)+,(IncIff_sizeFORM-DT,a4)
	cmp.l	#"ILBM",(a0)
	bne	IncIff_noILBM

IncIff_Opnieuwzoeken:			; get next hunk
	move.l	(Bestand-DT,a4),d1
	move.l	(buffer_ptr-DT,a4),d2
	moveq	#8,d3
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVORead,a6)
	add.l	d3,(IncIff_filepos-DT,a4)
	tst.l	d0
	beq	IncIff_readerror
	move.l	d2,a0
	move.l	(4,a0),(IncIff_hunksize-DT,a4)
	cmp.l	#"BMHD",(a0)
	beq.b	IncIff_BMHD
	cmp.l	#"CMAP",(a0)
	beq.b	IncIff_CMAP
	cmp.l	#"BODY",(a0)
	beq	IncIff_BODY

IncIff_skip2nexthunk:
	move.l	(Bestand-DT,a4),d1
	move.l	(IncIff_hunksize-DT,a4),d2
	add.l	d2,(IncIff_filepos-DT,a4)
	moveq	#OFFSET_CURRENT,d3
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOSeek,a6)
	bra.b	IncIff_Opnieuwzoeken

IncIff_BMHD:
	move.l	(Bestand-DT,a4),d1
	move.l	(buffer_ptr-DT,a4),d2
	move.l	(IncIff_hunksize-DT,a4),d3
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVORead,a6)
	add.l	d3,(IncIff_filepos-DT,a4)

	move.l	d2,a0
	move	(a0)+,(IFFbreed-DT,a4)
	move	(a0)+,(IFFhoog-DT,a4)
	move	(a0)+,(IFFlinks-DT,a4)
	move	(a0)+,(IFFboven-DT,a4)
	move.b	(a0)+,(IFFnrplanes-DT,a4)
	move.b	(a0)+,(IFFmask-DT,a4)
	move.b	(a0)+,(IFFcompressed-DT,a4)
	addq.l	#16-11,a0
	move	(a0)+,(IFFpbreed-DT,a4)
	move	(a0),(IFFphoog-DT,a4)
	br	IncIff_Opnieuwzoeken

IncIff_CMAP:
	tst	d7	;passone
	bmi.b	CD100
	move.l	(Bestand-DT,a4),d1
	move.l	(buffer_ptr-DT,a4),d2
	move.l	(IncIff_hunksize-DT,a4),d3
	add.l	d3,(IncIff_filepos-DT,a4)
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVORead,a6)
	moveq	#1,d6
	move.b	(IFFnrplanes-DT,a4),d5
	lsl.w	d5,d6
	move	d6,d5
	add	d6,d6
	add	d5,d6		; 3 bytes per color (rgb)
	subq.w	#1,d6
	move.l	d2,a0
	lea	(IffPalette-DT,a4),a1
.lopje:
	move.b	(a0)+,(a1)+
	dbra	d6,.lopje
	br	IncIff_Opnieuwzoeken

CD100:
	bsr.b	IncIff_palettesize
	moveq	#15,d1
	and.b	(IncIff_colmap_pos-DT,a4),d1
	beq	IncIff_skip2nexthunk
	add.l	d0,(INSTRUCTION_ORG_PTR-DT,a4)
	br	IncIff_skip2nexthunk

IncIff_palettesize:
	move.b	(IFFnrplanes-DT,a4),d1
	moveq	#1<<1,d0	; ecs: 2 bytes per color
	lsl.l	d1,d0
	tst.b	(IncIff_colmap_pos-DT,a4)
	bpl.b	.ecs
	add.l	d0,d0		; aga: 4 bytes per color
.ecs	rts

CD12E:
	bsr.b	IncIff_calcBODYsize
	add.l	d0,(INSTRUCTION_ORG_PTR-DT,a4)
	br	IncIff_skip2nexthunk

IncIff_getBODYinfo:
	moveq	#0,d0
	move.b	(IFFnrplanes-DT,a4),d0
	cmp.b	#1,(IFFmask-DT,a4)
	bne.b	.CD148
	addq.w	#1,d0
.CD148	move	(IFFbreed-DT,a4),d1
	addq	#8,d1
	lsr.w	#4,d1
	add.w	d1,d1
	rts

IncIff_calcBODYsize:
	bsr.b	IncIff_getBODYinfo
	mulu	d1,d0
	mulu.w	(IFFhoog-DT,a4),d0
	rts

IncIff_BODY:
	tst	(IFFhoog-DT,a4)
	beq	IncIff_geenBMHD
	tst	d7	;passone
	bmi.b	CD12E

;	bsr	IncIff_calcBODYsize
;	cmp.l	(IncIff_hunksize-DT,a4),d0
;	bge.b	.check
	move.l	(IncIff_hunksize-DT,a4),d0
;	jsr	test1
;.check:
	move.l	d0,(IncIffBuf2Size-DT,a4)
	move.l	#$00010001,d1
	move.l	(4).w,a6
	jsr	(_LVOAllocMem,a6)
	move.l	d0,(IncIFF_BODYbuffer2-DT,a4)
	beq	ERROR_WorkspaceMemoryFull

	bsr.b	IncIff_calcBODYsize

;	cmp.l	(IncIff_hunksize-DT,a4),d0
;	bge.b	.check2
;	move.l	(IncIff_hunksize-DT,a4),d0
;	jsr	test2
;.check2:
	move.l	d0,(IncIffBuf1Size-DT,a4)
	move.l	#$00010001,d1
	jsr	(_LVOAllocMem,a6)
	move.l	d0,(IncIFF_BODYbuffer-DT,a4)
	beq	ERROR_WorkspaceMemoryFull

	move.l	(Bestand-DT,a4),d1
	move.l	(IncIFF_BODYbuffer2-DT,a4),d2	;buffer
	move.l	(IncIff_hunksize-DT,a4),d3	;size
	add.l	d3,(IncIff_filepos-DT,a4)
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVORead,a6)

	movem.l	d0-d7/a0-a6,-(sp)
;	moveq	#15,d0
;	add.w	(IFFbreed-DT,a4),d0
;	lsr.w	#4,d0
;	add.w	d0,d0
;	move.l	d0,(L2FD24-DT,a4)		; bytes per row
;	mulu.w	(IFFhoog-DT,a4),d0
;	move.l	d0,(L2FD28-DT,a4)		; bytes per plane

	move.l	(IncIFF_BODYbuffer2-DT,a4),a0	; input (body)
	move.l	(IncIFF_BODYbuffer-DT,a4),a1	; output
	bsr	IncIff_calcBODYsize
	lea	(a1,d0.l),a2			; output end
	tst.b	(IFFcompressed-DT,a4)
	bne.b	.Decr_lop

.copylopje:
	move.b	(a0)+,(a1)+
	cmp.l	a1,a2
	bgt.b	.copylopje

	bra.b	.done

.Decr_lop:
	moveq	#0,d6
	move.b	(a0)+,d6
	bpl.b	.Copy
.Same:
	neg.b	d6
	move.b	(a0)+,d0
.copylopje2:
	move.b	d0,(a1)+
	cmp.l	a1,a2
	dbls	d6,.copylopje2
	bhi.b	.Decr_lop

.done:
	movem.l	(sp)+,d0-d7/a0-a6
	br	IncIff_Opnieuwzoeken

.Copy:
	move.b	(a0)+,(a1)+
	cmp.l	a1,a2
	dbls	d6,.Copy
	bhi.b	.Decr_lop
	bra.b	.done


IncIff_readerror:
	jsr	(CLOSE_FILE_NO_PRINT)
	tst	d7	;passone
	bmi.b	.p1
	bsr.b	.CD28A
.p1	bsr	IncIff_FreeBuffers
	move.l	(IffA6Backup-DT,a4),a6
	movem.l	(sp)+,d0-d7/a0-a5
	rts

.CD28A
	moveq	#15,d0
	and.b	(IncIff_colmap_pos-DT,a4),d0
	cmp.b	#1,d0
	bne.b	CD29C
	bsr.b	IncIff_addcmap		; cmap before
CD29C:
	move.l	(IncIFF_BODYbuffer-DT,a4),a0
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),a1
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a1
	bsr	IncIff_calcBODYsize
	move.l	d0,-(sp)

	tst.b	(IncIff_tiepe-DT,a4)	; $ff normal, $00 blitter
	beq.b	.CD2C6
	bsr	IncIff_copy_nonil	; copy non-interleaved
	bra.b	.CD2CE

.CD2C6	move.b	(a0)+,(a1)+		; copy interleaved
	subq.l	#1,d0
	bne.b	.CD2C6
.CD2CE
	move.l	(sp),d0
	add.l	d0,(INSTRUCTION_ORG_PTR-DT,a4)
	moveq	#15,d0
	and.b	(IncIff_colmap_pos-DT,a4),d0
	cmp.b	#2,d0
	bne.b	.CD2E8
	bsr.b	IncIff_addcmap		; cmap after
.CD2E8
	move.l	(sp)+,d3
	tst.b	(IncIff_colmap_pos-DT,a4)
	beq.b	.CD2FA
	bsr	IncIff_palettesize
	add.l	d0,d3
.CD2FA
	move.l	d3,(FileLength-DT,a4)
	lea	(HInciff.MSG).l,a0
	bsr	PRINTINCLUDENAME
	jmp	(PrintFileLengthEOL)

IncIff_addcmap:
	lea	(IffPalette-DT,a4),a0
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),a1
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a1
	move.l	a1,d6
	lsr.w	#1,d6
	bcs	ERROR_WordatOddAddress
	move.b	(IFFnrplanes-DT,a4),d5
	moveq	#1,d6
	lsl.w	d5,d6
	subq.w	#1,d6
	tst.b	(IncIff_colmap_pos-DT,a4)
	bmi.b	.CD36E
.CD340
	moveq	#0,d0		; ECS: Rr Gg Bb -> 0RGB
	move.b	(a0)+,d0
	lsl.w	#4,d0
	move.b	(a0)+,d0
	lsl.w	#4,d0
	move.b	(a0)+,d0
	lsr.w	#4,d0
	move	d0,(a1)+
	dbra	d6,.CD340
.done
	bsr	IncIff_palettesize
	add.l	d0,(INSTRUCTION_ORG_PTR-DT,a4)
	rts

.CD36E
	move.b	(a0)+,d0	; AGA: Rr Gg Bb -> 0RGB 0rgb
	moveq	#0,d1
	lsl.w	#4,d0
	move.b	d0,d1
	lsl.w	#4,d1
	move.b	(a0)+,d0
	move.b	d0,d1
	lsl.w	#4,d0
	lsl.b	#4,d1
	move.b	(a0)+,d0
	moveq	#$f,d2
	and.b	d0,d2
	lsr.w	#4,d0
	or.b	d2,d1
	move	d0,(a1)+
	move	d1,(a1)+
	dbra	d6,.CD36E
	bra.b	.done

IncIff_noFORM:
	jsr	(CLOSE_FILE_NO_PRINT)
	bsr.b	IncIff_FreeBuffers
	br	ERROR_TryingtoincludenonILBM

IncIff_noILBM:
	jsr	(CLOSE_FILE_NO_PRINT)
	bsr.b	IncIff_FreeBuffers
	br	ERROR_IFFfileisnotaILBM

IncIff_geenBMHD:
	jsr	(CLOSE_FILE_NO_PRINT)
	bsr.b	IncIff_FreeBuffers
	br	ERROR_CanthandleBODYbBMHD

IncIff_FreeBuffers:
	move.l	a6,-(sp)
	move.l	(4).w,a6
	move.l	(buffer_ptr-DT,a4),d0
	beq.b	.CD414
	move.l	d0,a1
	move.l	#4096,d0
	jsr	(_LVOFreeMem,a6)
	clr.l	(buffer_ptr-DT,a4)
.CD414:
	move.l	(IncIFF_BODYbuffer2-DT,a4),d0
	beq.b	.CD440
	move.l	d0,a1
	move.l	(IncIffBuf2Size-DT,a4),d0
	jsr	(_LVOFreeMem,a6)
	clr.l	(IncIFF_BODYbuffer2-DT,a4)
	clr.l	(IncIffBuf2Size-DT,a4)
.CD440:
	move.l	(IncIFF_BODYbuffer-DT,a4),d0
	beq.b	.CD46C
	move.l	d0,a1
	move.l	(IncIffBuf1Size-DT,a4),d0
	jsr	(_LVOFreeMem,a6)
	clr.l	(IncIFF_BODYbuffer-DT,a4)
	clr.l	(IncIffBuf1Size-DT,a4)
.CD46C:
	move.l	(sp)+,a6
	rts

IncIff_copy_nonil:	; copy + deinterleave
	bsr	IncIff_getBODYinfo
	move.w	(IFFhoog-DT,a4),d2
	move.w	d0,d3
	subq.w	#1,d3
	mulu.w	d1,d3
	move.w	d0,d7
	mulu.w	d1,d7
	mulu.w	d2,d7
	ext.l	d1
	sub.l	d1,d7
	move.w	d0,d6		; bitplanes
	subq.w	#1,d6
.CD496
	move.w	d2,d5		; height
	subq.w	#1,d5
.CD49A
	move.w	d1,d4		; bytes per row
	subq.w	#1,d4
.CD49E
	move.b	(a0)+,(a1)+
	dbra	d4,.CD49E
	add.l	d3,a0
	dbra	d5,.CD49A
	sub.l	d7,a0
	dbra	d6,.CD496
	rts


Asm_PRINTT:
	lea	(SourceCode-DT,a4),a1
	bsr	ASSEM_RETURN_STRING_MIXCASE
	tst	d7	;passone
	bmi.b	.CD4E8

	btst	#0,(PR_Progress)
	beq.b	.NoProgress
	lea	(TxtClearProgress),a0
	bsr	beeldtextaf
.NoProgress

	lea	(SourceCode-DT,a4),a0
	bsr	printthetext
	bsr	druk_cr_nl
	bsr	Druk_Clearbuffer
.CD4E8
	bsr	PARSE_GET_KOMMA_IF_ANY
	bpl.b	Asm_PRINTT
	rts

Asm_PRINTV:
	bsr	Parse_GetExprValueInD3Voor
	tst	d7	;passone
	bmi.b	.CD4FE
	move.l	d3,d0
	bsr	com_calculator
	bsr	Druk_Clearbuffer
.CD4FE
	bsr	PARSE_GET_KOMMA_IF_ANY
	bpl.b	Asm_PRINTV
	rts

Parse_GetKomma:
	cmp.b	#',',(a6)+
	bne.b	.Error
	moveq	#0,d0
.CD510	move.b	(a6)+,d0		; skip whitespace
	tst.b	(Variable_base-DT,a4,d0.w)
	bmi.b	.CD510
	subq.w	#1,a6
	rts
.Error	bra	ERROR_Commaexpected

Asm_BASEREG:
	bsr	Parse_GetExprValueInD3Voor
	move.l	d3,-(sp)
	move	d2,-(sp)
	bmi.w	ERROR_Linkerlimitation
	bsr.b	Parse_GetKomma
	jsr	(AddrOrDataReg)
	tst	d5	; M_Dx?
	beq	ERROR_AddressRegExp
	bset	d1,(BASEREG_BYTE-DT,a4)
	bne	ERROR_Doubledefinition
	bset	#AF_OFFSET_A4,d7
	lea	(BASEREG_BASE-DT,a4),a0
	subq.w	#8,d1			; Ax = 8 to 15
	add	d1,d1
	add.w	d1,a0
	add	d1,d1
	add	d1,a0
	move	(sp)+,(a0)+
	move.l	(sp)+,(a0)+
	rts

Asm_ENDB:
	jsr	(AddrOrDataReg)
	tst	d5	; M_Dx?
	beq	ERROR_AddressRegExp
	bclr	d1,(BASEREG_BYTE-DT,a4)
	tst.b	(BASEREG_BYTE-DT,a4)
	bne.b	.HaveBase
	bclr	#AF_OFFSET_A4,d7
.HaveBase
	rts

Asm_QREPT:
	bset	#AF_QREPT,d7
	bra.b	Asm_REPT_or_QREPT

Asm_REPT:
	bclr	#AF_QREPT,d7
Asm_REPT_or_QREPT:
	jsr	(Parse_GetDefinedValue).l
	tst.l	d3
	bmi.w	ERROR_Repeatoverflow
	move.w	(REPT_LEVEL-DT,a4),d0
	cmp.w	#MAX_REPT_LEVEL*22,d0
	bhs.w	ERROR_Repeatoverflow
	add.w	#22,(REPT_LEVEL-DT,a4)
	lea	(REPT_STACK-DT,a4),a0
	add	d0,a0
	move	(CurrentSection-DT,a4),d1
	move.l	a6,a3
	tst	(MACRO_LEVEL-DT,a4)
	beq.b	.not_in_macro
	or.w	#$8000,d1
	move.l	(16,sp),a3			; **** DANGER **** (macro src line)
.not_in_macro
	move.l	a3,(a0)+			;  +0 src ptr
	tst	(INCLUDE_LEVEL-DT,a4)
	beq.b	.not_in_include
	or.w	#$0100,d1
.not_in_include
	move.l	(DATA_CURRENTLINE-DT,a4),(a0)+	;  +4 line num
	move	d1,(a0)+			;  +8 flags/section
	move.l	d3,(a0)+			; +10 ctr
	bne.b	.not_rept0
	move.l	(Asm_Table_Base-DT,a4),-14(a0)	; make REPT 0 skip its contents, use
	lea	(ConditionAssembl,pc),a1	;  src ptr as backup for curr asm jmptab
	move.l	a1,(Asm_Table_Base-DT,a4)
	bset	#AF_IF_FALSE,d7
	bclr	#AF_QREPT,d7
.not_rept0
	move.l	(REPTN_VALUE-DT,a4),(a0)+	; +14 outside ctr
	clr.l	(REPTN_VALUE-DT,a4)
	moveq	#-1,d0
	btst	#AF_QREPT,d7
	beq.b	.NotQRept
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),d0
.NotQRept
	move.l	d0,(a0)+			; +18 block_addr
	rts

Asm_ENDR:
	move.w	(REPT_LEVEL-DT,a4),d0
	beq	ERROR_NotinRepeatar
	lea	(REPT_STACK-22-DT,a4),a0
	add	d0,a0
	addq.l	#1,(REPTN_VALUE-DT,a4)
	subq.l	#1,(10,a0)			; --ctr
	ble.b	.rept0_or_done
	move	(CurrentSection-DT,a4),d1
	tst	(MACRO_LEVEL-DT,a4)
	beq.b	.not_in_macro
	or.w	#$8000,d1
.not_in_macro
	tst	(INCLUDE_LEVEL-DT,a4)
	beq.b	.not_in_include
	or.w	#$0100,d1
.not_in_include
	move	(8,a0),d0			; flags/section
	cmp	d1,d0
	bne	ERROR_NotinRepeatar
	move.l	(18,a0),d1			; qrept?
	bpl.b	.QRept
	and.w	#$ff00,d0
	bne.b	.no_line
	move.l	(4,a0),(DATA_CURRENTLINE-DT,a4)
	tst.w	d0
.no_line
	bmi.b	.in_macro
	move.l	(a0),a6
	rts
.in_macro
	move.l	(a0),(16,sp)			; **** DANGER **** (reset src ptr)
	rts
.rept0_or_done
	beq.b	.all_done
	move.l	(a0),(Asm_Table_Base-DT,a4)	; make REPT 0 skip its contents
	bclr	#AF_IF_FALSE,d7
.all_done
	move.l	(14,a0),(REPTN_VALUE-DT,a4)	; restore outside ctr
	sub.w	#22,(REPT_LEVEL-DT,a4)
	rts

.QRept	move.l	(INSTRUCTION_ORG_PTR-DT,a4),d0
	move.l	d0,a3
	sub.l	d1,d0				; empty block?
	beq.b	.all_done
	move.l	d0,d3
	mulu.w	(10,a0),d0			; ctr, upper word
	swap	d0
	mulu.w	(12,a0),d3			; ctr, lower word
	add.l	d3,d0
	add.l	d0,(INSTRUCTION_ORG_PTR-DT,a4)
	tst.w	d7				; pass1?
	bmi.b	.all_done
	move.l	(CURRENT_ABS_ADDRESS-DT,a4),a1
	add.l	a1,a3
	add.l	d1,a1				; block ptr
.CopyBlock
	move.b	(a1)+,(a3)+
	subq.l	#1,d0
	bne.b	.CopyBlock
	bra.b	.all_done

;*********** INCBIN ********************

IncBinStuff:
	bclr	#AF_INC_ASSIGN,d7
	jsr	(HandleIncFileFromSrc)
	bsr	PARSE_GET_KOMMA_IF_ANY
	bne.b	.CD670
	jsr	(Parse_GetDefinedValue).l
	move.l	d3,d0
	bra.b	.CD67A
.CD670
	jsr	(GetDiskFileLengte).l
.CD67A
	btst	#AF_BRATOLONG,d7
	bne.b	.CD6CA
	tst	d7	;passone
	bmi.b	.CD6CA
	lea	(HIncbin.MSG).l,a0
	bsr	PRINTINCLUDENAME
	movem.l	d0/a6,-(sp)
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),d2
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),d2
	move.l	d0,d3
	movem.l	d2/d3,-(sp)
	clr.l	(FileLength-DT,a4)
	jsr	(OpenOldFile).l
	movem.l	(sp)+,d2/d3
	jsr	(read_nr_d3_bytes).l
	move.l	d7,-(sp)
	moveq	#-1,d7
	jsr	(close_bestand).l
	move.l	(sp)+,d7
	movem.l	(sp)+,d0/a6
.CD6CA
	add.l	d0,(INSTRUCTION_ORG_PTR-DT,a4)
	rts

CD6D0:
	bsr.b	CD6E0
	move.l	d3,(JUMPPTR-DT,a4)
	rts

CD6D8:
	bsr.b	CD6E0
	move.l	d3,(L2F118-DT,a4)
	rts

CD6E0:
	tst	d7	;passone
	bmi.b	CD6FE
	bsr	Parse_GetExprValueInD3Voor
	tst	d2
	beq.b	CD6FC
	lea	(SECTION_ABS_LOCATION-DT,a4),a0
	add	d2,d2
	add	d2,d2
	beq	ERROR_UndefSymbol
	add.l	(a0,d2.w),d3
CD6FC:
	rts

CD6FE:
	tst.b	(a6)+
	bne.b	CD6FE
	subq.w	#1,a6
	rts

Asm_EQUR:
	jsr	(AddrOrDataReg).l
	swap	d1
	move	d5,d1
	move.l	(LAST_LABEL_ADDRESS-DT,a4),d0
	beq	ERROR_IllegalOperatorInBSS
	move.l	d0,a1
	move.l	d1,-(a1)
	move	#LB_EQUR,-(a1)
	clr.l	(LAST_LABEL_ADDRESS-DT,a4)
	move.l	d1,(ResponsePtr-DT,a4)
	move	#LB_SET,(ResponseType-DT,a4)
	rts

Asm_REG:
	jsr	(AddrOrDataReg).l
	jsr	(PARSE_MOVEM_REGISTERS).l
	move.l	(LAST_LABEL_ADDRESS-DT,a4),d0
	beq	ERROR_IllegalOperatorInBSS
	move.l	d0,a1
	move.l	d1,-(a1)
	move	#LB_REG,-(a1)
	clr.l	(LAST_LABEL_ADDRESS-DT,a4)
	move.l	d1,(ResponsePtr-DT,a4)
	move	#LB_SET,(ResponseType-DT,a4)
	rts

CD75C:
	jsr	(NEXTSYMBOL)
	cmp.b	#NS_ALABEL,d1
	bne	ERROR_IllegalOperand
	bsr	C4F62
	bsr	PARSE_GET_KOMMA_IF_ANY
	beq.b	CD75C
	rts

CD778:
	tst	d7	;passone
	bmi.b	CD7C4
CD77C:
	jsr	(NEXTSYMBOL)
	cmp.b	#NS_ALABEL,d1
	bne	ERROR_IllegalOperand
	move.l	a1,-(sp)
	lea	(XDefTreePtr-DT,a4),a2
	lea	(SourceCode-DT,a4),a3
	bsr	Parse_FindlabelNoSupertree
	beq	ERROR_UndefSymbol
	move.l	(sp)+,a1
	move.l	a0,-(sp)
	bsr	Parse_FindLabel
	beq	ERROR_UndefSymbol
	tst	d2
	bmi.w	ERROR_Linkerlimitation
	move.l	(sp)+,a0
	move.l	d3,-(a0)
	bclr	#LB_PASS2BIT,d2
	move	d2,-(a0)
	bsr	PARSE_GET_KOMMA_IF_ANY
	beq.b	CD77C
	rts

CD7C4:
	jsr	(NEXTSYMBOL)
	cmp.b	#NS_ALABEL,d1
	bne	ERROR_IllegalOperand
	lea	(XDefTreePtr-DT,a4),a2
	lea	(SourceCode-DT,a4),a3
	bsr	Parse_FindlabelNoSupertree
	bne	ERROR_DoubleSymbol
	bsr	MAKELABEL_SPECIAL
	move	d0,(a0)+
	move.l	d0,(a0)+
	move.l	a0,(LabelEnd-DT,a4)
	bsr	PARSE_GET_KOMMA_IF_ANY
	beq.b	CD7C4
	rts

ASSEM_CMDPAGE:
	clr	(PageLinesLeft-DT,a4)
	bset	#0,(PR_Paging)
	rts

ASSEM_CMDNOPAGE:
	bclr	#0,(PR_Paging)
	rts

ASSEM_CMDLIST:
	bset	#AF_LISTFILE,d7
	rts

ASSEM_CMDNOLIST:
	bclr	#AF_LISTFILE,d7
	rts

ASSEM_CMDLLEN:
	jsr	(Parse_GetDefinedValue)
	cmp	#60,d3
	blt.w	ERROR_Outofrange60t
	cmp	#132,d3
	bgt.w	ERROR_Outofrange60t
	move	d3,(PageWidth-DT,a4)
	rts

ASSEM_CMDPLEN:
	jsr	(Parse_GetDefinedValue)
	cmp	#20,d3
	blt.w	ERROR_Outofrange20t
	cmp	#100,d3
	bgt.w	ERROR_Outofrange20t
	move	(PageHeight-DT,a4),d0
	sub	d3,d0
	move	d3,(PageHeight-DT,a4)
	sub	d0,(PageLinesLeft-DT,a4)
	rts

ASSEM_CMDSPC:
	jsr	(Parse_GetDefinedValue)
	tst.l	d3
	beq.b	.Done
	tst	d7	;passone
	bmi.b	.Done
.Loop	bsr	druk_cr_nl
	subq.l	#1,d3
	bne.b	.Loop
.Done	rts

ASSEM_CMDTTL:
	lea	(TITLE_STRING-DT,a4),a1
	br	ASSEM_RETURN_STRING_MIXCASE

ASSEM_CMDIDNT:
	lea	(IDNT_STRING-DT,a4),a1
	br	ASSEM_RETURN_STRING_MIXCASE

ASSEM_MASK2:
	move.l	a5,a6
	rts

Asm_SECTION:
	jsr	(ASSEM_RESTORE_OLD_SECTION)
	bclr	#AF_OFFSET,d7
	bsr	ASSEM_RETURN_LABEL_STRING
	lea	(SectionTreePtr-DT,a4),a2
	lea	(SourceCode-DT,a4),a3
	bsr	Parse_FindlabelNoSupertree
	bne.b	.Found

	tst	d7	;passone
	bpl.w	ERROR_IllegalOperand
	bsr	MAKELABEL_SPECIAL
	move.l	a0,-(sp)
	bsr	ASSEM_RECON_SECTION_TYPE
	jsr	(ASSEM_MAKE_NEW_SECTION)
	move.l	(sp)+,a0
	move	(CurrentSection-DT,a4),(a0)+
	move.l	a0,(LabelEnd-DT,a4)
	bra.b	AsmSetLastLabel

.Found	move	d2,d0
	jsr	(ASSEM_GET_OLD_SECTION)
	bsr.b	AsmSetLastLabel
	bsr	ASSEM_RECON_SECTION_TYPE
	move.b	(CURRENT_SECTION_TYPE-DT,a4),d0
	bclr	#6,d0		; exclude allocated flag
	cmp.b	d0,d6
	bne	ERROR_DoubleSymbol
	rts

Asm_ORG:
	jsr	(ASSEM_RESTORE_OLD_SECTION)
	bclr	#AF_OFFSET,d7
	moveq	#0,d0
	jsr	(ASSEM_GET_OLD_SECTION_FROM_ABS)
	jsr	(Parse_GetDefinedValue)
	clr.l	(CURRENT_ABS_ADDRESS-DT,a4)
	move.l	d3,(INSTRUCTION_ORG_PTR-DT,a4)
AsmSetLastLabel:
	bra	SET_LAST_LABEL_TO_ORG_PTR

Asm_LOAD:
	tst	(CurrentSection-DT,a4)
	bne	ERROR_LOADwithoutOR
	jsr	(Parse_GetDefinedValue)
	tst	d7	;passone
	bmi.b	.CD93A
	sub.l	(INSTRUCTION_ORG_PTR-DT,a4),d3
	move.l	d3,(CURRENT_ABS_ADDRESS-DT,a4)
.CD93A	rts

ASSEM_CMDEVEN:
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),d0
	btst	#0,d0
	beq.b	CD950
CD93C_EvenOdd:
	moveq	#1,d5
	moveq	#0,d3
	moveq	#0,d2
	bra.w	CDBAC

ASSEM_CMDODD:
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),d0
	btst	#0,d0
	beq.b	CD93C_EvenOdd
CD950:
	rts

ASSEM_CMDDR_W:
	tst.b	(PR_OddData)
	beq.b	.CD978
	cmp	#PB_020,(ProcessorType-DT,a4)
	bge.b	.CD982
.CD978	btst	#0,(INSTRUCTION_ORG_PTR+3-DT,a4)
	bne	ERROR_WordatOddAddress
.CD982	move.l	(INSTRUCTION_ORG_PTR-DT,a4),(Binary_Offset-DT,a4)

.Loop	jsr	(PARSE_GET_LABEL)
	bsr	C755A
	move.l	(Binary_Offset-DT,a4),(INSTRUCTION_ORG_PTR-DT,a4)
	bsr	PARSE_GET_KOMMA_IF_ANY
	bpl.b	.Loop
	rts

CD9A0:
	tst.b	(PR_OddData).l
	beq.b	CD9B0
	cmp	#PB_020,(ProcessorType-DT,a4)
	bge.b	CD9BA
CD9B0:
	btst	#0,(INSTRUCTION_ORG_PTR+3-DT,a4)
	bne	ERROR_WordatOddAddress
CD9BA:
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),(Binary_Offset-DT,a4)
CD9C0:
	jsr	(PARSE_GET_LABEL)
	bsr	Store_DataLongReloc
	move.l	(Binary_Offset-DT,a4),(INSTRUCTION_ORG_PTR-DT,a4)
	bsr	PARSE_GET_KOMMA_IF_ANY
	bpl.b	CD9C0
	rts

CD9D8:
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),(Binary_Offset-DT,a4)
CD9DE:
	jsr	(PARSE_GET_LABEL)
	bsr	Parse_IetsMetExtentionWord
	move.l	(Binary_Offset-DT,a4),(INSTRUCTION_ORG_PTR-DT,a4)
	bsr	PARSE_GET_KOMMA_IF_ANY
	bpl.b	CD9DE
	rts

CD9F6:
	tst.b	(PR_OddData).l
	beq.b	CDA06
	cmp	#PB_020,(ProcessorType-DT,a4)
	bge.b	CDA10
CDA06:
	btst	#0,(INSTRUCTION_ORG_PTR+3-DT,a4)
	bne	ERROR_WordatOddAddress
CDA10:
	move.b	#$71,(OpperantSize-DT,a4)
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),(Binary_Offset-DT,a4)
CDA1C:
	bsr	Asm_ImmediateOppFloat
	bsr	Asm_FloatsizeS
	move.l	(Binary_Offset-DT,a4),(INSTRUCTION_ORG_PTR-DT,a4)
	bsr	PARSE_GET_KOMMA_IF_ANY
	bpl.b	CDA1C
	rts

CDA32:
	tst.b	(PR_OddData).l
	beq.b	CDA42
	cmp	#PB_020,(ProcessorType-DT,a4)
	bge.b	CDA4C
CDA42:
	btst	#0,(INSTRUCTION_ORG_PTR+3-DT,a4)
	bne	ERROR_WordatOddAddress
CDA4C:
	move.b	#$75,(OpperantSize-DT,a4)
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),(Binary_Offset-DT,a4)
CDA58:
	bsr	Asm_ImmediateOppFloat
	bsr	Asm_FloatsizeD
	move.l	(Binary_Offset-DT,a4),(INSTRUCTION_ORG_PTR-DT,a4)
	bsr	PARSE_GET_KOMMA_IF_ANY
	bpl.b	CDA58
	rts

CDA6E:
	tst.b	(PR_OddData).l
	beq.b	CDA7E
	cmp	#PB_020,(ProcessorType-DT,a4)
	bge.b	CDA88
CDA7E:
	btst	#0,(INSTRUCTION_ORG_PTR+3-DT,a4)
	bne	ERROR_WordatOddAddress
CDA88:
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),(Binary_Offset-DT,a4)
	move.b	#$72,(OpperantSize-DT,a4)
CDA94:
	bsr	Asm_ImmediateOppFloat
	bsr	Asm_FloatsizeX
	move.l	(Binary_Offset-DT,a4),(INSTRUCTION_ORG_PTR-DT,a4)
	bsr	PARSE_GET_KOMMA_IF_ANY
	bpl.b	CDA94
	rts

CDAAA:
	tst.b	(PR_OddData).l
	beq.b	CDABA
	cmp	#PB_020,(ProcessorType-DT,a4)
	bge.b	CDAC4
CDABA:
	btst	#0,(INSTRUCTION_ORG_PTR+3-DT,a4)
	bne	ERROR_WordatOddAddress
CDAC4:
	move.b	#$73,(OpperantSize-DT,a4)
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),(Binary_Offset-DT,a4)
CDAD0:
	bsr	Asm_ImmediateOppFloat
	bsr	Asm_FloatsizeP
	move.l	(Binary_Offset-DT,a4),(INSTRUCTION_ORG_PTR-DT,a4)
	bsr	PARSE_GET_KOMMA_IF_ANY
	bpl.b	CDAD0
	rts

CDAE6:
	tst.b	(PR_OddData).l
	beq.b	CDAF6
	cmp	#PB_020,(ProcessorType-DT,a4)
	bge.b	CDB00
CDAF6:
	btst	#0,(INSTRUCTION_ORG_PTR+3-DT,a4)
	bne	ERROR_WordatOddAddress
CDB00:
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),(Binary_Offset-DT,a4)
CDB06:
	bsr	Parse_GetExprValueInD3Voor
	bsr	Store_DataWordUnsigned
	move.l	(Binary_Offset-DT,a4),(INSTRUCTION_ORG_PTR-DT,a4)
	bsr	PARSE_GET_KOMMA_IF_ANY
	bpl.b	CDB06
	rts

CDB1C:
	tst.b	(PR_OddData).l
	beq.b	CDB2C
	cmp	#PB_020,(ProcessorType-DT,a4)
	bge.b	CDB36
CDB2C:
	btst	#0,(INSTRUCTION_ORG_PTR+3-DT,a4)
	bne	ERROR_WordatOddAddress
CDB36:
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),(Binary_Offset-DT,a4)
CDB3C:
	bsr	Parse_GetExprValueInD3Voor
	bsr	Store_DataLongReloc
	move.l	(Binary_Offset-DT,a4),(INSTRUCTION_ORG_PTR-DT,a4)
	bsr	PARSE_GET_KOMMA_IF_ANY
	bpl.b	CDB3C
	rts

CDB52:	; DC.B
	bset	#AF_BYTE_STRING,d7
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),(Binary_Offset-DT,a4)
CDB5C:
	bsr	Parse_GetExprValueInD3Voor
	bsr	C7512
	move.l	(Binary_Offset-DT,a4),(INSTRUCTION_ORG_PTR-DT,a4)
	bsr	PARSE_GET_KOMMA_IF_ANY
	bpl.b	CDB5C
	bclr	#AF_BYTE_STRING,d7
	rts

CDB76:
	jsr	(Parse_GetDefinedValue).l
	move.l	d3,-(sp)
	bsr	PARSE_GET_KOMMA_IF_ANY
	beq	CDE70
	moveq	#0,d2
	moveq	#0,d3
	br	CDE74

CDB8E:
	jsr	(Parse_GetDefinedValue).l
	move.l	d3,-(sp)
	bsr	PARSE_GET_KOMMA_IF_ANY
	beq.b	CDBA2
	moveq	#0,d2
	moveq	#0,d3
	bra.b	CDBA6

CDBA2:
	bsr	Parse_GetExprValueInD3Voor
CDBA6:
	move.l	(sp)+,d5
	bmi.w	ERROR_WorkspaceMemoryFull
CDBAC:
	tst	d7	;passone
	bpl.b	.p2
	add.l	d5,(INSTRUCTION_ORG_PTR-DT,a4)
	rts

.p2	subq.l	#1,d5
	bmi.b	CDBF8
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),a0
	move.l	d3,d0
	bpl.b	CDBC4
	not.l	d0
CDBC4:
	clr.b	d0
	tst.l	d0
	bne	ERROR_out_of_range8bit
	tst	d2
	bne.b	CDC00
	tst.b	(Asm_OffsetCheck-DT,a4)
	bne.b	CDBFA

	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
.CDBE2	move.b	d3,(a0)+
	dbra	d5,.CDBE2
	sub.l	#$00010000,d5
	bpl.b	.CDBE2
	sub.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
CDBF0:
	move.l	a0,(INSTRUCTION_ORG_PTR-DT,a4)
CDBF8:
	rts

CDBFA:
	lea	(1,a0,d5.l),a0
	bra.b	CDBF0

CDC00:
	move.l	a0,(Binary_Offset-DT,a4)
	move.l	d3,d4
	move	d2,d1
CDC08:
	move.l	d4,d3
	move	d1,d2
	bsr	Asmbl_send_XREF_dataB
	dbra	d5,CDC08
	sub.l	#$00010000,d5
	bpl.b	CDC08
	move.l	(Binary_Offset-DT,a4),(INSTRUCTION_ORG_PTR-DT,a4)
	rts

CDC24:
	move.b	#$71,(OpperantSize-DT,a4)
	jsr	(Parse_GetDefinedValue).l
	move.l	d3,-(sp)
	bsr	PARSE_GET_KOMMA_IF_ANY
	beq.b	CDC44
	moveq	#0,d2
	fmove.l	d2,fp0
	bra.b	CDC48

CDC44:
	bsr	Asm_ImmediateOppFloat
CDC48:
	move.l	(sp)+,d5
	bmi.w	ERROR_WorkspaceMemoryFull
	tst	d7	;passone
	bpl.b	CDC74
	asl.l	#2,d5
	tst.b	(PR_OddData).l
	beq.b	CDC64
	cmp	#PB_020,(ProcessorType-DT,a4)
	bge.b	CDC6E
CDC64:
	btst	#0,(INSTRUCTION_ORG_PTR+3-DT,a4)
	bne	ERROR_WordatOddAddress
CDC6E:
	add.l	d5,(INSTRUCTION_ORG_PTR-DT,a4)
	rts

CDC74:
	tst.b	(PR_OddData).l
	beq.b	CDC84
	cmp	#PB_020,(ProcessorType-DT,a4)
	bge.b	CDC8E
CDC84:
	btst	#0,(INSTRUCTION_ORG_PTR+3-DT,a4)
	bne	ERROR_WordatOddAddress
CDC8E:
	subq.l	#1,d5
	bmi.b	CDCB2
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),a0
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
CDC9A:
	fmove.s	fp0,(a0)+
	dbra	d5,CDC9A
	sub.l	#$00010000,d5
	bpl.b	CDC9A
	sub.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
	move.l	a0,(INSTRUCTION_ORG_PTR-DT,a4)
CDCB2:
	rts

CDCB4:
	move.b	#$75,(OpperantSize-DT,a4)
	jsr	(Parse_GetDefinedValue).l
	move.l	d3,-(sp)
	bsr	PARSE_GET_KOMMA_IF_ANY
	beq.b	CDCD4
	moveq	#0,d2
	fmove.l	d2,fp0
	bra.b	CDCD8

CDCD4:
	bsr	Asm_ImmediateOppFloat
CDCD8:
	move.l	(sp)+,d5
	bmi.w	ERROR_WorkspaceMemoryFull
	tst	d7	;passone
	bpl.b	CDD04
	asl.l	#3,d5
	tst.b	(PR_OddData).l
	beq.b	CDCF4
	cmp	#PB_020,(ProcessorType-DT,a4)
	bge.b	CDCFE
CDCF4:
	btst	#0,(INSTRUCTION_ORG_PTR+3-DT,a4)
	bne	ERROR_WordatOddAddress
CDCFE:
	add.l	d5,(INSTRUCTION_ORG_PTR-DT,a4)
	rts

CDD04:
	tst.b	(PR_OddData).l
	beq.b	CDD14
	cmp	#PB_020,(ProcessorType-DT,a4)
	bge.b	CDD1E
CDD14:
	btst	#0,(INSTRUCTION_ORG_PTR+3-DT,a4)
	bne	ERROR_WordatOddAddress
CDD1E:
	subq.l	#1,d5
	bmi.b	CDD42
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),a0
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
CDD2A:
	fmove.d	fp0,(a0)+
	dbra	d5,CDD2A
	sub.l	#$00010000,d5
	bpl.b	CDD2A
	sub.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
	move.l	a0,(INSTRUCTION_ORG_PTR-DT,a4)
CDD42:
	rts

CDD44:
	move.b	#$72,(OpperantSize-DT,a4)
	jsr	(Parse_GetDefinedValue).l
	move.l	d3,-(sp)
	bsr	PARSE_GET_KOMMA_IF_ANY
	beq.b	CDD64
	moveq	#0,d2
	fmove.l	d2,fp0
	bra.b	CDD68

CDD64:
	bsr	Asm_ImmediateOppFloat
CDD68:
	move.l	(sp)+,d5
	bmi.w	ERROR_WorkspaceMemoryFull
	tst	d7	;passone
	bpl.b	CDD9A
	move.l	d5,d0
	asl.l	#2,d0
	asl.l	#3,d5
	add.l	d0,d5
	tst.b	(PR_OddData).l
	beq.b	CDD8A
	cmp	#PB_020,(ProcessorType-DT,a4)
	bge.b	CDD94
CDD8A:
	btst	#0,(INSTRUCTION_ORG_PTR+3-DT,a4)
	bne	ERROR_WordatOddAddress
CDD94:
	add.l	d5,(INSTRUCTION_ORG_PTR-DT,a4)
	rts

CDD9A:
	tst.b	(PR_OddData).l
	beq.b	CDDAA
	cmp	#PB_020,(ProcessorType-DT,a4)
	bge.b	CDDB4
CDDAA:
	btst	#0,(INSTRUCTION_ORG_PTR+3-DT,a4)
	bne	ERROR_WordatOddAddress
CDDB4:
	subq.l	#1,d5
	bmi.b	CDDD8
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),a0
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
CDDC0:
	fmove.x	fp0,(a0)+
	dbra	d5,CDDC0
	sub.l	#$00010000,d5
	bpl.b	CDDC0
	sub.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
	move.l	a0,(INSTRUCTION_ORG_PTR-DT,a4)
CDDD8:
	rts

CDDDA:
	move.b	#$73,(OpperantSize-DT,a4)
	jsr	(Parse_GetDefinedValue).l
	move.l	d3,-(sp)
	bsr	PARSE_GET_KOMMA_IF_ANY
	beq.b	CDDFA
	moveq	#0,d2
	fmove.l	d2,fp0
	bra.b	CDDFE

CDDFA:
	bsr	Asm_ImmediateOppFloat
CDDFE:
	move.l	(sp)+,d5
	bmi.w	ERROR_WorkspaceMemoryFull
	tst	d7	;passone
	bpl.b	CDE30
	move.l	d5,d0
	asl.l	#2,d0
	asl.l	#3,d5
	add.l	d0,d5
	tst.b	(PR_OddData).l
	beq.b	CDE20
	cmp	#PB_020,(ProcessorType-DT,a4)
	bge.b	CDE2A
CDE20:
	btst	#0,(INSTRUCTION_ORG_PTR+3-DT,a4)
	bne	ERROR_WordatOddAddress
CDE2A:
	add.l	d5,(INSTRUCTION_ORG_PTR-DT,a4)
	rts

CDE30:
	tst.b	(PR_OddData).l
	beq.b	CDE40
	cmp	#PB_020,(ProcessorType-DT,a4)
	bge.b	CDE4A
CDE40:
	btst	#0,(INSTRUCTION_ORG_PTR+3-DT,a4)
	bne	ERROR_WordatOddAddress
CDE4A:
	subq.l	#1,d5
	bmi.b	CDE6E
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),a0
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
CDE56:
	fmove.p	fp0,(a0)+{#0}
	dbra	d5,CDE56
	sub.l	#$00010000,d5
	bpl.b	CDE56
	sub.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
	move.l	a0,(INSTRUCTION_ORG_PTR-DT,a4)
CDE6E:
	rts

CDE70:
	bsr	Parse_GetExprValueInD3Voor
CDE74:
	move.l	(sp)+,d5
	bmi.w	ERROR_WorkspaceMemoryFull
CDE7A:
	tst	d7	;passone
	bpl.b	CDEA0
	add.l	d5,d5
	tst.b	(PR_OddData).l
	beq.b	CDE90
	cmp	#PB_020,(ProcessorType-DT,a4)
	bge.b	CDE9A
CDE90:
	btst	#0,(INSTRUCTION_ORG_PTR+3-DT,a4)
	bne	ERROR_WordatOddAddress
CDE9A:
	add.l	d5,(INSTRUCTION_ORG_PTR-DT,a4)
	rts

CDEA0:
	tst.b	(PR_OddData).l
	beq.b	CDEB0
	cmp	#PB_020,(ProcessorType-DT,a4)
	bge.b	CDEBA
CDEB0:
	btst	#0,(INSTRUCTION_ORG_PTR+3-DT,a4)
	bne	ERROR_WordatOddAddress
CDEBA:
	subq.l	#1,d5
	bmi.b	CDEF6
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),a0
	move.l	d3,d0
	bpl.b	CDEC8
	not.l	d0
CDEC8:
	clr	d0
	tst.l	d0
	bne	ERROR_out_of_range16bit
	tst	d2
	bne.b	CDF00
	tst.b	(Asm_OffsetCheck-DT,a4)
	bne.b	CDEF8

	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
.CDEE0	move	d3,(a0)+
	dbra	d5,.CDEE0
	sub.l	#$00010000,d5
	bpl.b	.CDEE0
	sub.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
CDEEE:
	move.l	a0,(INSTRUCTION_ORG_PTR-DT,a4)
CDEF6:
	rts

CDEF8:
	IF	MC020
	lea	(2,a0,d5.l*2),a0
	ELSE
	addq.l	#1,d5		; a0 += 2*(d5+1)
	add.l	d5,d5
	add.l	d5,a0
	ENDIF
	bra.b	CDEEE

CDF00:
	move.l	a0,(Binary_Offset-DT,a4)
	move.l	d3,d4
	move	d2,d1
CDF08:
	move.l	d4,d3
	move	d1,d2
	bsr	Asmbl_send_XREF_dataW
	dbra	d5,CDF08
	sub.l	#$00010000,d5
	bpl.b	CDF08
	move.l	(Binary_Offset-DT,a4),(INSTRUCTION_ORG_PTR-DT,a4)
	rts

CDF24:	; DCB.L
	jsr	(Parse_GetDefinedValue).l
	move.l	d3,-(sp)
	bsr	PARSE_GET_KOMMA_IF_ANY
	beq.b	CDF38
	moveq	#0,d2
	moveq	#0,d3
	bra.b	CDF3C

CDF38:
	bsr	Parse_GetExprValueInD3Voor
CDF3C:
	move.l	(sp)+,d5
	bmi.w	ERROR_WorkspaceMemoryFull
CDF42:
	tst	d7	;passone
	bpl.w	CE0F0
	asl.l	#2,d5
	tst.b	(PR_OddData).l
	beq.b	CDF5A
	cmp	#PB_020,(ProcessorType-DT,a4)
	bge.b	CDF64
CDF5A:
	btst	#0,(INSTRUCTION_ORG_PTR+3-DT,a4)
	bne	ERROR_WordatOddAddress
CDF64:
	add.l	d5,(INSTRUCTION_ORG_PTR-DT,a4)
	rts

CDF6A:
	tst	d7	;passone
	bpl.b	CDFC4
	asl.l	#3,d5
	tst.b	(PR_OddData).l
	beq.b	CDF82
	cmp	#PB_020,(ProcessorType-DT,a4)
	bge.b	CDF8C
CDF82:
	btst	#0,(INSTRUCTION_ORG_PTR+3-DT,a4)
	bne	ERROR_WordatOddAddress
CDF8C:
	add.l	d5,(INSTRUCTION_ORG_PTR-DT,a4)
	rts

CDF92:
	tst	d7	;passone
	bpl.w	CE050
	move.l	d0,-(sp)
	asl.l	#2,d5
	move.l	d5,d0
	asl.l	#1,d5
	add.l	d0,d5
	move.l	(sp)+,d0
	tst.b	(PR_OddData).l
	beq.b	CDFB4
	cmp	#PB_020,(ProcessorType-DT,a4)
	bge.b	CDFBE
CDFB4:
	btst	#0,(INSTRUCTION_ORG_PTR+3-DT,a4)
	bne	ERROR_WordatOddAddress
CDFBE:
	add.l	d5,(INSTRUCTION_ORG_PTR-DT,a4)
	rts

CDFC4:
	tst.b	(PR_OddData).l
	beq.b	CDFD4
	cmp	#PB_020,(ProcessorType-DT,a4)
	bge.b	CDFDE
CDFD4:
	btst	#0,(INSTRUCTION_ORG_PTR+3-DT,a4)
	bne	ERROR_WordatOddAddress
CDFDE:
	subq.l	#1,d5
	bmi.b	CE00E
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),a0
	tst	d2
	bne.b	CE024
	tst.b	(Asm_OffsetCheck-DT,a4)
	bne.b	CE010

	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
.CDFF6:
	move.l	d3,(a0)+
	move.l	d3,(a0)+
	dbra	d5,.CDFF6
	sub.l	#$00010000,d5
	bpl.b	.CDFF6
	sub.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
CE006:
	move.l	a0,(INSTRUCTION_ORG_PTR-DT,a4)
CE00E:
	rts

CE010:
	IF	MC020
	lea	(8,a0,d5.l*8),a0
	ELSE
	addq.l	#1,d5		; a0 += 8*(d5+1)	
	lsl.l	#3,d5
	add.l	d5,a0
	ENDIF
	bra.b	CE006

CE024:
	move.l	a0,(Binary_Offset-DT,a4)
	move.l	d3,d4
	move	d2,d1
CE02C:
	move.l	d4,d3
	move	d1,d2
	bsr	Asm_StoreL_Reloc
	move.l	d4,d3
	move	d1,d2
	bsr	Asm_StoreL_Reloc
	dbra	d5,CE02C
	sub.l	#$00010000,d5
	bpl.b	CE02C
	move.l	(Binary_Offset-DT,a4),(INSTRUCTION_ORG_PTR-DT,a4)
	rts

CE050:
	tst.b	(PR_OddData).l
	beq.b	CE060
	cmp	#PB_020,(ProcessorType-DT,a4)
	bge.b	CE06A
CE060:
	btst	#0,(INSTRUCTION_ORG_PTR+3-DT,a4)
	bne	ERROR_WordatOddAddress
CE06A:
	subq.l	#1,d5
	bmi.b	CE09C
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),a0
	tst	d2
	bne.b	CE0BC
	tst.b	(Asm_OffsetCheck-DT,a4)
	bne.b	CE09E

	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
.CE082	move.l	d3,(a0)+
	move.l	d3,(a0)+
	move.l	d3,(a0)+
	dbra	d5,.CE082
	sub.l	#$00010000,d5
	bpl.b	.CE082
	sub.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
CE094:
	move.l	a0,(INSTRUCTION_ORG_PTR-DT,a4)
CE09C:
	rts

CE09E:
	addq.l	#1,d5		; a0 += 12*(d5+1)
	lsl.l	#2,d5
	add.l	d5,a0
	add.l	d5,d5
	add.l	d5,a0
	bra.b	CE094

CE0BC:
	move.l	a0,(Binary_Offset-DT,a4)
	move.l	d3,d4
	move	d2,d1
CE0C4:
	move.l	d4,d3
	move	d1,d2
	bsr	Asm_StoreL_Reloc
	move.l	d4,d3
	move	d1,d2
	bsr	Asm_StoreL_Reloc
	move.l	d4,d3
	move	d1,d2
	bsr	Asm_StoreL_Reloc
	dbra	d5,CE0C4
	sub.l	#$00010000,d5
	bpl.b	CE0C4
	move.l	(Binary_Offset-DT,a4),(INSTRUCTION_ORG_PTR-DT,a4)
	rts

CE0F0:
	tst.b	(PR_OddData).l
	beq.b	CE100
	cmp	#PB_020,(ProcessorType-DT,a4)
	bge.b	CE10A
CE100:
	btst	#0,(INSTRUCTION_ORG_PTR+3-DT,a4)
	bne	ERROR_WordatOddAddress
CE10A:
	subq.l	#1,d5
	bmi.b	CE138
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),a0
	tst	d2
	bne.b	CE146
	tst.b	(Asm_OffsetCheck-DT,a4)
	bne.b	CE13A

	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
.CE122	move.l	d3,(a0)+
	dbra	d5,.CE122
	sub.l	#$00010000,d5
	bpl.b	.CE122
	sub.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
CE130:
	move.l	a0,(INSTRUCTION_ORG_PTR-DT,a4)
CE138:
	rts

CE13A:
	IF	MC020
	lea	(4,a0,d5.l*4),a0
	ELSE
	addq.l	#1,d5		; a0 += 4*(d5+1)
	lsl.l	#2,d5
	add.l	d5,a0
	ENDIF
	bra.b	CE130

CE146:
	move.l	a0,(Binary_Offset-DT,a4)
	move.l	d3,d4
	move	d2,d1
CE14E:
	move.l	d4,d3
	move	d1,d2
	bsr	Asm_StoreL_Reloc
	dbra	d5,CE14E
	sub.l	#$00010000,d5
	bpl.b	CE14E
	move.l	(Binary_Offset-DT,a4),(INSTRUCTION_ORG_PTR-DT,a4)
	rts

CE16A:	; DS.B
	jsr	(Parse_GetDefinedValue).l
	tst.l	d3
	bmi.w	ERROR_WorkspaceMemoryFull
	move.l	d3,d5
	moveq	#0,d2
	moveq	#0,d3
	tst.b	(PR_DsClear).l
	bne	CDBAC
	st	(Asm_OffsetCheck-DT,a4)
	br	CDBAC

CE190:	; DS.W
	jsr	(Parse_GetDefinedValue).l
	tst.l	d3
	bmi.w	ERROR_WorkspaceMemoryFull
	move.l	d3,d5
	moveq	#0,d2
	moveq	#0,d3
	tst.b	(PR_DsClear).l
	bne	CDE7A
	st	(Asm_OffsetCheck-DT,a4)
	br	CDE7A

CE1B6:	; DS.L|S
	jsr	(Parse_GetDefinedValue).l
	tst.l	d3
	bmi.w	ERROR_WorkspaceMemoryFull
	move.l	d3,d5
	moveq	#0,d2
	moveq	#0,d3
	tst.b	(PR_DsClear).l
	bne	CDF42
	st	(Asm_OffsetCheck-DT,a4)
	br	CDF42

CE1DC:	; DS.D
	jsr	(Parse_GetDefinedValue).l
	tst.l	d3
	bmi.w	ERROR_WorkspaceMemoryFull
	move.l	d3,d5
	moveq	#0,d2
	moveq	#0,d3
	tst.b	(PR_DsClear).l
	bne	CDF6A
	st	(Asm_OffsetCheck-DT,a4)
	br	CDF6A

CE202:	; DS.X, DS.P
	jsr	(Parse_GetDefinedValue)
	tst.l	d3
	bmi.w	ERROR_WorkspaceMemoryFull
	move.l	d3,d5
	moveq	#0,d2
	moveq	#0,d3
	tst.b	(PR_DsClear).l
	bne	CDF92
	st	(Asm_OffsetCheck-DT,a4)
	br	CDF92

Asm_EQUA:
	bsr.w	Parse_GetExprValueInD3Voor
	move.l	(LAST_LABEL_ADDRESS-DT,a4),d0
	beq	ERROR_IllegalOperatorInBSS
	tst.w	d7	; pass1?
	bmi.b	CE246
.P2	move.l	d0,a1
	move.w	d2,-(sp)
	bsr.w	Convert_A2I_MkAbs
	move.w	(sp)+,d2
	clr.b	d2		; LB_CONSTANT
	bra.b	CE242

Asm_EQU:
	bsr	Parse_GetExprValueInD3Voor
	btst	#AF_UNDEFVALUE,d7
	bne	ERROR_UndefSymbol
	move.l	(LAST_LABEL_ADDRESS-DT,a4),d0
	beq	ERROR_IllegalOperatorInBSS
	move.l	d0,a1
	tst	d7	;passone
	bpl.b	CE246
CE242:
	move.l	d3,-(a1)
	move	d2,-(a1)
CE246:
	clr.l	(LAST_LABEL_ADDRESS-DT,a4)
	move.l	d3,(ResponsePtr-DT,a4)
	or.w	#LB_SET,d2
	move	d2,(ResponseType-DT,a4)
	rts

ASSEM_CMDEND:
	tst	(MACRO_LEVEL-DT,a4)
	bne	ERROR_UnexpectedEOF
	bclr	#AF_OFFSET,d7
	bset	#AF_FINISHED,d7
	rts

GoGoMacro:	; ASSEM_CMDMACRO
	tst	(INCLUDE_LEVEL-DT,a4)
	bne	ASSEM_CMDMACRO_NOPRINT
	move	#LB_MACRO,(ResponseType-DT,a4)
	btst	#AF_LISTFILE,d7
	beq.b	.CE2AE
	tst	d7	;passone
	bmi.b	.CE2AE
	bsr.w	PRINT_ASSEMBLING
.CE2AE	tst.b	(a6)+
	bne.b	.CE2AE

	tst	(MACRO_LEVEL-DT,a4)
	bne	ERROR_IllegalMacrod
	tst	d7	;passone
	bpl.b	.CE2D4
	tst.l	d7	;AF_IF_FALSE
	bmi.b	.CE2D4
	move.l	(LAST_LABEL_ADDRESS-DT,a4),d0
	beq	ERROR_IllegalOperatorInBSS
	move.l	d0,a1
	move.l	a6,-(a1)
	move	#LB_MACRO,-(a1)
.CE2D4	clr.l	(LAST_LABEL_ADDRESS-DT,a4)

.Loop	addq.l	#1,(DATA_CURRENTLINE-DT,a4)
	tst.b	(DATA_CURRENTLINE+3-DT,a4)
	bne.b	.CE2E8
	jsr	(messages_get)
.CE2E8
	move.l	a6,(DATA_LINE_START_PTR-DT,a4)
	INSERT_DEBUG		; trashes d0/d1/a0

	moveq	#0,d0
	move.b	(a6)+,d0
	tst.b	(Variable_base-DT,a4,d0.w)
	bmi.b	.Space
	cmp.b	#SRCMARK_END,d0
	beq	ERROR_UnexpectedEOF
.NoSpace
	subq.w	#1,a6
	btst	#AF_LABELCOL,d7
	beq.b	.ToEol
	jsr	(NEXTSYMBOL)
	tst.b	d1		; eol/comment?
	beq.b	.LineDone
	cmp.b	#NS_ALABEL,d1
	bne.b	.ToEol
	cmp.b	#':',d0
	beq.b	.ToEol
.CE33C	move.b	(a6)+,d0
	tst.b	(Variable_base-DT,a4,d0.w)
	bmi.b	.CE33C
	subq.w	#1,a6
	cmp.b	#'=',d0
	beq.b	.ToEol
	bra.b	.CE366

.Space	jsr	(NEXTSYMBOL_SPACE)
	tst.b	d1		; eol/comment?
	bne.b	.LineNotDone
	tst.b	(-1,a6)		; was last char really an eol?
	beq.b	.LineDone
	bra.b	.ToEol
.LineNotDone
	cmp.b	#NS_ALABEL,d1
	bne.b	.ToEol
	cmp.b	#':',d0
	beq.b	.ToEol
	cmp.b	#'=',d0
	beq.b	.ToEol

.CE366	btst	#AF_LOCALFOUND,d7
	bne.b	.ToEol
	lea	(SourceCode-DT,a4),a3
	move	#$DFDF,d4
	move	(a3)+,d0
	and	d4,d0
	cmp	#'EN',d0
	bne.b	.ToEol
	move	(a3)+,d0
	and	d4,d0
	cmp	#'DM'+$8000,d0
	beq.b	.CE3A0

.ToEol	tst.b	(a6)+
	bne.b	.ToEol
.LineDone
	btst	#AF_LISTFILE,d7
	beq.b	.CE39C
	tst	d7	;passone
	bmi.b	.CE39C
	bsr.w	PRINT_ASSEMBLING
.CE39C	br	.Loop

.CE3A0	rts

ASSEM_CMDMACRO_NOPRINT:
	tst.b	(a6)+
	bne.b	ASSEM_CMDMACRO_NOPRINT
	tst	(MACRO_LEVEL-DT,a4)
	bne	ERROR_IllegalMacrod
	tst	d7	;passone
	bpl.b	.CE3C8
	tst.l	d7	;AF_IF_FALSE
	bmi.b	.CE3C8
	move.l	(LAST_LABEL_ADDRESS-DT,a4),d0
	beq	ERROR_IllegalOperatorInBSS
	move.l	d0,a1
	move.l	a6,-(a1)
	move	#$8000,-(a1)
.CE3C8
	clr.l	(LAST_LABEL_ADDRESS-DT,a4)

.Loop	moveq	#0,d0
	move.b	(a6)+,d0
	tst.b	(Variable_base-DT,a4,d0.w)
	bmi.b	.CE40A
	cmp.b	#SRCMARK_END,d0
	beq	ERROR_UnexpectedEOF
	subq.w	#1,a6
	btst	#AF_LABELCOL,d7
	beq.b	.ToEol
	jsr	(NEXTSYMBOL)
	cmp.b	#NS_ALABEL,d1
	bne.b	.ToEol
	cmp.b	#':',d0
	beq.b	.ToEol

.CE3F8	move.b	(a6)+,d0
	tst.b	(Variable_base-DT,a4,d0.w)
	bmi.b	.CE3F8
	subq.w	#1,a6
	cmp.b	#'=',d0
	beq.b	.ToEol
	bra.b	.CE422

.CE40A	jsr	(NEXTSYMBOL_SPACE)
	cmp.b	#NS_ALABEL,d1
	bne.b	.ToEol
	cmp.b	#':',d0
	beq.b	.ToEol
	cmp.b	#'=',d0
	beq.b	.ToEol

.CE422	btst	#AF_LOCALFOUND,d7
	bne.b	.ToEol
	lea	(SourceCode-DT,a4),a3
	move	#$DFDF,d4
	move	(a3)+,d0
	and	d4,d0
	cmp	#'EN',d0
	bne.b	.ToEol
	move	(a3)+,d0
	and	d4,d0
	cmp	#'DM'+$8000,d0
	beq.b	CE44A

.ToEol	tst.b	(a6)+
	bne.b	.ToEol
	bra.b	.Loop


Asm_MEXIT:
Asm_ENDM:
	tst	(MACRO_LEVEL-DT,a4)
	beq	ERROR_Notinmacro
	bset	#AF_MACRO_END,d7
CE44A:
	rts

Asm_CMEXIT:
	jsr	(Parse_GetDefinedValue).l
	moveq	#0,d1
	move	(MACRO_LEVEL-DT,a4),d1
	beq	ERROR_Notinmacro
	cmp.l	d3,d1
	blo.b	.CE47E
	bset	#AF_MACRO_END,d7
.CE47E	rts

ASSEM_CMDIFEQ:
	jsr	(Parse_GetDefinedValue)
	tst.l	d3
	bne	CONDITION_FALSE
	br	CONDITION_TRUE

ASSEM_CMDIF1:
	tst	d7	;passone
	bpl.w	CONDITION_FALSE
	br	CONDITION_TRUE

ASSEM_CMDIF2:
	tst	d7	;passone
	bmi.w	CONDITION_FALSE
	br	CONDITION_TRUE

ASSEM_CMDIFNE:
	jsr	(Parse_GetDefinedValue)
	tst.l	d3
	beq	CONDITION_FALSE
	br	CONDITION_TRUE

ASSEM_CMDIFGT:
	jsr	(Parse_GetDefinedValue)
	tst.l	d3
	ble.w	CONDITION_FALSE
	br	CONDITION_TRUE

ASSEM_CMDIFGE:
	jsr	(Parse_GetDefinedValue)
	tst.l	d3
	blt.w	CONDITION_FALSE
	br	CONDITION_TRUE

ASSEM_CMDIFLT:
	jsr	(Parse_GetDefinedValue)
	tst.l	d3
	bge.w	CONDITION_FALSE
	br	CONDITION_TRUE

ASSEM_CMDIFLE:
	jsr	(Parse_GetDefinedValue)
	tst.l	d3
	bgt.w	CONDITION_FALSE
	bra.b	CONDITION_TRUE

ASSEM_COMPARE_STRINGS:
	lea	(SourceCode-DT,a4),a1
	move.l	a1,-(sp)
	bsr	ASSEM_RETURN_STRING
	bsr	Parse_GetKomma
	lea	(CurrentAsmLine-DT,a4),a1
	move.l	a1,-(sp)
	bsr	ASSEM_RETURN_STRING
	movem.l	(sp)+,a0/a1

.CE50E	move.b	(a0)+,d0
	beq.b	.CE51A
	cmp.b	(a1)+,d0
	beq.b	.CE50E
	sne	d0
	rts
.CE51A	tst.b	(a1)+
	sne	d0
	rts

ASSEM_CMDIFC:
	bsr.b	ASSEM_COMPARE_STRINGS
	tst.b	d0
	bne.b	CONDITION_FALSE
	bra.b	CONDITION_TRUE

ASSEM_CMDIFNC:
	bsr.b	ASSEM_COMPARE_STRINGS
	tst.b	d0
	beq.b	CONDITION_FALSE
	bra.b	CONDITION_TRUE

ASSEM_GET_SYMBOL:
	jsr	(NEXTSYMBOL)
	cmp.b	#NS_ALABEL,d1
	bne	ERROR_IllegalOperand
	jmp	(Parse_FindLabel)

ASSEM_CMDIFD:
	bsr.b	ASSEM_GET_SYMBOL
	bne.b	CONDITION_TRUE
	bra.b	CONDITION_FALSE

ASSEM_CMDIFND:
	bsr.b	ASSEM_GET_SYMBOL
	beq.b	CONDITION_TRUE
	bra.b	CONDITION_FALSE

ASSEM_CMDIFB:
	tst.b	(a6)
	beq.b	CONDITION_TRUE
.CE554	tst.b	(a6)+
	bne.b	.CE554
	subq.w	#1,a6
	bra.b	CONDITION_FALSE

ASSEM_CMDIFNB:
	tst.b	(a6)
	beq.b	CONDITION_FALSE
.CE560	tst.b	(a6)+
	bne.b	.CE560
	subq.w	#1,a6

CONDITION_TRUE:
CONDITION_STORE_OLD:
	move	(ConditionLevel-DT,a4),d0
	lea	(ConditionBuffer-DT,a4),a0
	tst.l	d7
	smi	(a0,d0.w)
	addq.w	#1,d0
	cmp	#MAX_CONDITION_LEVEL,d0
	beq	ERROR_Conditionalov	;erflow
	move	d0,(ConditionLevel-DT,a4)
	subq.w	#1,d0

	lea	(ConditionBufPtr-DT,a4),a0

	IF MC020
	move.l	(Asm_Table_Base-DT,a4),(a0,d0.w*4)
	ELSE
	lsl.w	#2,d0
	move.l	(Asm_Table_Base-DT,a4),(a0,d0.w)
	ENDC
	rts

ASSEM_CMD_ALWAYS_FALSE:
	tst.b	(a6)+
	bne.b	ASSEM_CMD_ALWAYS_FALSE
	subq.l	#1,a6
CONDITION_FALSE:
	bsr.b	CONDITION_STORE_OLD
CONDITION_SET_FALSE:
	lea	(CondAsmTab2,pc),a0
	move.l	a0,(Asm_Table_Base-DT,a4)
	bset	#AF_IF_FALSE,d7
	rts

ASSEM_CMDELSE:
	move	(ConditionLevel-DT,a4),d0
	beq	ERROR_IllegalOperatorInBSS
	subq.w	#1,d0
	tst.l	d7
	bpl.b	CONDITION_SET_FALSE
	bra.b	CONDITION_DO_ENDC

ASSEM_CMDENDC:
	move	(ConditionLevel-DT,a4),d0
	beq	ERROR_IllegalOperatorInBSS
.CE5C4
	move.b	(a6)+,d1
	beq.b	.CE5D2
	cmp.b	#SRCMARK_END,d1
	bne.b	.CE5C4
.CE5D2	subq.l	#1,a6
	subq.w	#1,d0
	move	d0,(ConditionLevel-DT,a4)
CONDITION_DO_ENDC:
	lea	(ConditionBuffer-DT,a4),a0
	move.b	(a0,d0.w),d1
	lea	(ConditionBufPtr-DT,a4),a0

	IF MC020
	move.l	(a0,d0.w*4),(Asm_Table_Base-DT,a4)
	ELSE
	lsl.w	#2,d0
	move.l	(a0,d0.w),(Asm_Table_Base-DT,a4)
	ENDC

	tst.b	d1
	beq.b	.CE5F6
	bset	#AF_IF_FALSE,d7
	rts
.CE5F6	bclr	#AF_IF_FALSE,d7
	rts

Asm_AUTO:
	tst	d7	;passone
	bpl.b	.pass2
	move.l	a6,a0
	jsr	(DATAFROMAUTO)
	lea	(-1,a0),a6
	rts
.pass2	tst.b	(a6)+
	bne.b	.pass2
	subq.w	#1,a6
	rts

Asm_Include:
	addq.w	#1,(INCLUDE_LEVEL-DT,a4)
	cmp	#MAX_INCLUDE_LEVEL,(INCLUDE_LEVEL-DT,a4)
	bhi.w	ERROR_Includeoverflow
	lea	(SourceCode-DT,a4),a1
	bsr	ASSEM_RETURN_STRING
	move.l	a6,-(sp)
	jsr	(INCLUDE_POINTER).l
	move.l	a1,a6
	addq.l	#8,a2
	move.l	(MACRO_ActiveID-DT,a4),-(sp)
	move.l	a2,(MACRO_ActiveID-DT,a4)
	moveq	#1,d0
	move.l	d0,(ErrorLijnInCode-DT,a4)
.Loop
	cmp.b	#SRCMARK_END,(a6)
	beq.b	.End
	jsr	(FAST_TRANSLATE_LINE).l
	addq.l	#1,(ErrorLijnInCode-DT,a4)
	tst.b	d7	; AF_FINISHED
	bpl.b	.Loop
.End
	move.l	(sp)+,(MACRO_ActiveID-DT,a4)
	move.l	(sp)+,a6
	subq.w	#1,(INCLUDE_LEVEL-DT,a4)
	rts

RemoveWS:
	move.b	(a6)+,d0
	cmp.b	#' ',d0
	beq.b	RemoveWS
	cmp.b	#9,d0
	beq.b	RemoveWS
	tst.b	d0
	rts

Asm_INCSRC:
	moveq	#0,d0
	bsr.b	RemoveWS
	sub	#'0',d0
	cmp	#9,d0
	bhi.w	ERROR_IllegalsourceNr
	cmp.b	(CurrentSource-DT,a4),d0
	beq	ERROR_IncludeSource
	lsl.w	#8,d0		; *CS_size
	lea	(SourcePtrs-DT,a4),a0
	add.w	d0,a0
	tst.l	(a0)		; CS_start
	beq	ERROR_Includingempty

	move.l	a6,-(sp)
	move.l	(a0),a6		; CS_start
	move.l	(CS_length,a0),d0
	move.b	#SRCMARK_END,(a6,d0.l)
	moveq	#1,d0
	move.l	d0,(ErrorLijnInCode-DT,a4)

.Loop	cmp.b	#SRCMARK_END,(a6)
	beq.b	.Done
	jsr	(FAST_TRANSLATE_LINE)
	addq.l	#1,(ErrorLijnInCode-DT,a4)
	tst.b	d7
	bpl.b	.Loop
.Done
	move.l	(sp)+,a6
	rts

ASSEM_CMDRSRESET:
	clr.l	(RS_BASE_OFFSET-DT,a4)
	rts

ASSEM_CMDRSSET:
	jsr	(Parse_GetDefinedValue)
	move.l	d3,(RS_BASE_OFFSET-DT,a4)
	rts

ASSEM_CMDRS_B:
	jsr	(Parse_GetDefinedValue)
	bra.b	ASSEM_CMDRS_END

ASSEM_CMDRS_W:
	jsr	(Parse_GetDefinedValue)
	add.l	d3,d3
	bra.b	ASSEM_CMDRS_END

ASSEM_CMDRS_L:
	jsr	(Parse_GetDefinedValue)
	add.l	d3,d3
	add.l	d3,d3

ASSEM_CMDRS_END:
	move.l	(RS_BASE_OFFSET-DT,a4),d1
	add.l	d3,(RS_BASE_OFFSET-DT,a4)
	move.l	(LAST_LABEL_ADDRESS-DT,a4),d0
	beq.b	.NoLabel
	move.l	d0,a1
	tst	d7	;passone
	bpl.b	.P2
	move.l	d1,-(a1)
	clr	-(a1)
.P2	clr.l	(LAST_LABEL_ADDRESS-DT,a4)
	move.l	d1,(ResponsePtr-DT,a4)
	move	#LB_SET,(ResponseType-DT,a4)
.NoLabel
	rts

ASSEM_CMDOFFSET:
	jsr	(Parse_GetDefinedValue)
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),d1
	sub.l	d3,d1
	move.l	d1,(OFFSET_BASE_ADDRESS-DT,a4)
	bset	#AF_OFFSET,d7
	rts

ASSEM_CMDLABELSET_COND:
	tst.l	d7		; AF_IF_FALSE
	bpl.b	ASSEM_CMDLABELSET
.ToEol	tst.b	(a6)+
	bne.b	.ToEol
	subq.l	#1,a6
	rts

ASSEM_CMDLABELSET:
	bsr	Parse_GetExprValueInD3Voor
	btst	#AF_UNDEFVALUE,d7
	bne	ERROR_UndefSymbol
	move.l	(LAST_LABEL_ADDRESS-DT,a4),d0
	beq	ERROR_IllegalOperatorInBSS
	move.l	d0,a1
	move.l	d3,-(a1)
	or.w	#LB_SET,d2
	move	d2,-(a1)
	clr.l	(LAST_LABEL_ADDRESS-DT,a4)
	move.l	d3,(ResponsePtr-DT,a4)
	move	d2,(ResponseType-DT,a4)

Processor_warning_Rts:
	rts

;;************** PROCESSOR WARNING **************

Processor_warning:
	tst	d7		;passone
	bpl.b	Processor_warning_Rts

	btst	#AF_PROCESRWARN,d7
	beq.b	Processor_warning_Rts

	movem.l	d0-d7/a0-a6,-(sp)
	move.l	(DATA_CURRENTLINE-DT,a4),d1
	cmp.l	(Asm_LastErrorPos-DT,a4),d1
	beq	Test_NoProblems

	cmp	#PB_FPU,d0
	beq	PB_FPUWarning
	tst.w	d0		; bit15 PB_MMU
	bmi.w	Test_MMU
	btst	#14,d0		;PB_851
	beq.s	.goon

	tst.w	PR_MMU		;mc68851
	bne.w	Test_NoProblems

	tst.b	d0		; bit7 PB_ONLY
	bpl.b	.cpu_plus
	and.w	#%111,d0
	cmp.w	(CPU_type-DT,a4),d0	;or 0x0
	beq	Test_NoProblems
	moveq	#0,d0
	bra.b	.in

.cpu_plus
	and.w	#%111,d0
	cmp.w	#PB_030,d0	;or 030+
	bhs.w	Test_NoProblems
	subq.w	#2,d0
.in:
	lea	(Warning68851_Mmu.MSG-DT,a4),a2
	moveq	#Warning68851_Mmu.MSG\.StrLen-Warning68851_Mmu.MSG,d2
	bra.b	UpdateShowError

.goon	btst	#6,d0		;PB_NOT
	bne.b	Test_NotThisCPU
	tst.b	d0		; bit7 PB_ONLY
	bmi.b	Test_ThisCPUOnly

	and.w	#%111,d0
	btst	#AF_ALLERRORS,d7
	bne.b	.ShowWarning
	cmp	(CPU_type-DT,a4),d0
	ble.w	Test_NoProblems
.ShowWarning:
	subq.w	#1,d0
	lea	(WarningCpuLow.MSG-DT,a4),a2
	moveq	#WarningCpuLow.MSG\.StrLen-WarningCpuLow.MSG,d2
	bra.b	UpdateShowError

; command is not available for this cpu
Test_NotThisCPU:
	btst	#AF_ALLERRORS,d7
	bne.b	.PB_ShowCPUWarning
	and	#%111,d0
	cmp	(CPU_type-DT,a4),d0
	bne.b	Test_NoProblems
.PB_ShowCPUWarning:
	bclr	#7,d0
	subq.w	#1,d0
	lea	(WarningNotAvail.MSG-DT,a4),a2
	moveq	#WarningNotAvail.MSG\.StrLen-WarningNotAvail.MSG,d2
	bra.b	UpdateShowError

; command is available only for this cpu
Test_ThisCPUOnly:
	btst	#AF_ALLERRORS,d7
	bne.b	.PB_ShowCPUWarning
	and	#%111,d0
	cmp	(CPU_type-DT,a4),d0
	beq.b	Test_NoProblems
.PB_ShowCPUWarning:
	bclr	#7,d0
	subq.w	#1,d0
	lea	(WarningSpecific.MSG-DT,a4),a2
	moveq	#WarningSpecific.MSG\.StrLen-WarningSpecific.MSG,d2

UpdateShowError:
	mulu.w	d0,d2
	add.l	d2,a2
UpdateShowError_HaveMsg:
	move.l	d1,(Asm_LastErrorPos-DT,a4)
	move.l	(AsmErrorPos-DT,a4),a1
	cmp.l	#AsmEindeErrorTable,a1
	bhs.s	Test_NoProblems

	move.l	d1,(a1)+	;linenr
	move.l	a2,(a1)+	;warning msg
	st	(a1)		;end of table
	move.l	a1,(AsmErrorPos-DT,a4)
	lea	(WarningPrefix.MSG-DT,a4),a0
	bsr	printthetext
	move.l	a2,a0
	bsr	printthetext
	bsr	Druk_af_eol
	move.l	(DATA_CURRENTLINE-DT,a4),d0
	beq.b	Test_NoProblems
	move.l	d0,(FirstLineNr-DT,a4)
	move.l	(DATA_LINE_START_PTR-DT,a4),(FirstLinePtr-DT,a4)
	bsr	Drukaf_CurrentLine
Test_NoProblems:
	movem.l	(sp)+,d0-d7/a0-a6
	rts

PB_FPUWarning:
	btst	#AF_ALLERRORS,d7
	bne.b	.ShowWarning
	tst.b	(PR_FPU_Present).l
	bne.b	Test_NoProblems
.ShowWarning
	lea	(Warning68881_2.MSG-DT,a4),a2
	bra.b	UpdateShowError_HaveMsg

Test_MMU:
	btst	#AF_ALLERRORS,d7
	bne.b	.ShowWarning
	tst.b	(PR_MMU).l
	bne.b	Test_NoProblems
	btst	#14,d0			;PB_MC68851 only
	bne.b	.ShowWarning
	and	#%111,d0
	cmp	(CPU_type-DT,a4),d0
	beq.b	Test_NoProblems
.ShowWarning
	lea	(Warning68851.MSG-DT,a4),a2
	bra.b	UpdateShowError_HaveMsg

;*******************************************************

Asm_SkipInstructionHead:
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),d0
	btst	#0,d0
	bne	ERROR_WordatOddAddress
	addq.l	#2,d0
	move.l	d0,(Binary_Offset-DT,a4)
	rts

asm_4bytes_OpperantSize:
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),d0
	btst	#0,d0
	bne	ERROR_WordatOddAddress
	addq.l	#4,d0
	move.l	d0,(Binary_Offset-DT,a4)
	rts

ASM_STORE_INSTRUCTION_HEAD:
	tst	d7	;passone
	bmi.b	.passone
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),a0
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
	move	d6,(a0)
.passone:
	move.l	(Binary_Offset-DT,a4),(INSTRUCTION_ORG_PTR-DT,a4)
	rts

ASM_STORE_LONG:
	tst	d7	;passone
	bmi.b	.passone
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),a0
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
	move.l	d6,(a0)
.passone:
	move.l	(Binary_Offset-DT,a4),(INSTRUCTION_ORG_PTR-DT,a4)
	rts

Asm_StoreL_Reloc:
	move.l	(RelocEnd-DT,a4),a1
	cmp.l	(WORK_ENDTOP-DT,a4),a1
	bcc.w	ERROR_WorkspaceMemoryFull

	move.b	(CurrentSection+1-DT,a4),(a1)+
	beq	ERROR_RelativeModeEr
	move.b	d2,(a1)+
	add	d2,d2
	add	d2,d2
	beq.b	.Xref
	lea	(SECTION_ABS_LOCATION-DT,a4),a0
	add.l	(a0,d2.w),d3
	move.l	(Binary_Offset-DT,a4),a0
	move.l	a0,(a1)+
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
	move.l	d3,(a0)
	addq.l	#4,(Binary_Offset-DT,a4)
	move.l	a1,(RelocEnd-DT,a4)
	rts

.Xref:
	moveq	#2,d0
	add.l	(LabelXrefName-DT,a4),d0
	move.l	d0,(a1)+
	move.l	(Binary_Offset-DT,a4),a0
	move.l	a0,(a1)+
	move.l	a1,(RelocEnd-DT,a4)
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
	move.l	d3,(a0)
	addq.l	#4,(Binary_Offset-DT,a4)
	rts

Asmbl_send_XREF_dataB:
	moveq	#0,d0
	bsr.b	Asmbl_send_XREF_data
	br	asmbl_send_Byte

Asmbl_send_XREF_dataW:
	moveq	#1,d0
	bsr.b	Asmbl_send_XREF_data
	br	asmbl_send_Word

Asmbl_send_XREF_data:
	add	d2,d2
	add	d2,d2
	bne	ERROR_RelativeModeEr
	tst	d7	;passone
	bmi.b	.passone
	move.l	(RelocEnd-DT,a4),a1
	cmp.l	(WORK_ENDTOP-DT,a4),a1
	bcc.w	ERROR_WorkspaceMemoryFull
	move.b	(CurrentSection+1-DT,a4),(a1)+
	beq	ERROR_RelativeModeEr
	clr.b	(a1)+
	or.l	(LabelXrefName-DT,a4),d0
	move.l	d0,(a1)+
	move.l	(Binary_Offset-DT,a4),(a1)+
	move.l	a1,(RelocEnd-DT,a4)
.passone:
	rts

Asm_HaltPulse:
	moveq	#PB_060,d0
	bsr	Processor_warning

Asm_InsertinstrA5:
	move.l	a5,a6
Asm_InsertInstruction:
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),d0
	btst	#0,d0
	bne	ERROR_WordatOddAddress
	tst	d7	;passone
	bmi.b	.passone
	move.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
	add.l	d0,a0
	move	d6,(a0)
.passone:
	addq.l	#2,(INSTRUCTION_ORG_PTR-DT,a4)
	rts

CE9AC:
	move.l	a5,a6
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),d0
	btst	#0,d0
	bne	ERROR_WordatOddAddress
	tst	d7	;passone
	bmi.b	.passone
	move.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
	add.l	d0,a0
	move.l	d6,(a0)
.passone:
	addq.l	#4,(INSTRUCTION_ORG_PTR-DT,a4)
	rts

Asmbl_LineAF:
	jsr	(Parse_ImmediateValue).l
	and	#$0FFF,d3
	or.w	d3,d6
	bra.b	Asm_InsertInstruction

Asmbl_AddSubCmp:
	bsr	Asm_SkipInstructionHead
	move.b	d5,(OpperantSize-DT,a4)
	jsr	(asm_get_any_opp).l

	move	d1,(UsedRegs-DT,a4)
	bsr	Parse_GetKomma
	cmp	#M_PcIdx,d5
	bhi.w	ERROR_InvalidAddrMode

	cmp	#M_Imm,d5
	beq.w	Asmbl_AddSubCmpImm
	cmp	#M_Ax,d5
	bne.b	CEA0C
	cmp.w	#PB_APOLLO,(CPU_type-DT,a4)	;Apollo support byte writes to Ax.
	beq.b	.ok

	tst.b	(OpperantSize-DT,a4)
	beq	ERROR_AddressRegByte
.ok
CEA0C:
	or.b	d6,d5
	tst	d5
	beq.w	CEA84
	cmp.w	#M_AxInc|1,d5	; src (ax)+ (best filter first)?
	bne.b	.NotCmpm
	cmp.w	#$bc01,d6	; cmp?
	bne.s	.NotCmpm
	moveq	#~32,d0		; skip explicit cmpa/cmpi
	and.b	(SourceCode+3-DT,a4),d0
	sub.b	#'A',d0
	beq.b	.NotCmpm
	subq.b	#'I'-'A',d0
	beq.b	.NotCmpm

	jsr	(asm_noimmediateopp)
	cmp.w	#M_Ax,d5
	bls.b	.NotCmpmHaveReg
	move.w	#$b108,d6
	or.b	(OpperantSize-DT,a4),d6
	moveq	#7,d0
	and.w	(UsedRegs-DT,a4),d0
	or.w	d0,d6
	bra.w	Asmbl_CmpmViaCmp
.NotCmpm
	jsr	(AddrOrDataReg).l
.NotCmpmHaveReg
	and	#7,d1
	add.b	d1,d1
	or.b	d1,(UsedRegs-DT,a4)
	tst	d5	; M_Dx?
	beq.b	CEA74
CEA26:
	moveq	#0,d0
	move.b	(OpperantSize-DT,a4),d0
	cmp.w	#PB_APOLLO,(CPU_type-DT,a4)	;Apollo support byte writes to Ax.
	beq.b	.ok
	tst.b	d0
	beq	ERROR_AddressRegByte
.ok
	add.w	d0,d0
	move.b	#$c0,d0
	and	#$F000,d6
	or.w	(UsedRegs-DT,a4),d6
	or.w	d0,d6
	br	ASM_STORE_INSTRUCTION_HEAD

CEA46:
	and.b	#7,d1
	add.b	d1,d1
	or.b	d1,(UsedRegs-DT,a4)
	bra.b	CEA26

Asmbl_AddSubCmpImm:
	jsr	(asm_noimmediateopp).l
	cmp	#M_Ax,d5
	beq.b	CEA46

	move.w	#M_PcIdx|M_PcDisp,d0
	and.w	d5,d0
	bne.b	.cmp_pc
	cmp	#M_Imm,d5
	bhs.w	ERROR_InvalidAddrMode
.enter:
	and	#$0F00,d6
	or.b	(OpperantSize-DT,a4),d6
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

.cmp_pc:
	cmp.w	#$BC01,d6	;cmpi
	bne.w	ERROR_InvalidAddrMode
	moveq	#PB_020,d0
	bsr	Processor_warning
	bra.b	.enter

CEA74:
	and	#$F000,d6
	or.b	(OpperantSize-DT,a4),d6
	or.w	(UsedRegs-DT,a4),d6
	br	ASM_STORE_INSTRUCTION_HEAD

CEA84:
	jsr	(asm_noimmediateopp).l
	cmp	#M_Ax,d5
	beq.b	CEA46
	cmp	#M_Imm,d5
	bhs.w	ERROR_InvalidAddrMode
	and	#$F000,d6
	or.b	(OpperantSize-DT,a4),d6
	move	(UsedRegs-DT,a4),d0
	tst	d5	; M_Dx?
	beq.b	CEAAE
	bset	#8,d6
	exg	d0,d1
CEAAE:
	ror.w	#7,d1
	or.w	d0,d6
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

CEAB8:
	move.b	d5,(OpperantSize-DT,a4)
	bsr	Asm_SkipInstructionHead
	jsr	(asm_get_any_opp).l
	move	d1,(UsedRegs-DT,a4)
	bsr	Parse_GetKomma
	tst	d5	; M_Dx?
	beq	CEB56
	cmp.w	#PB_APOLLO,(CPU_type-DT,a4)	;Apollo support byte writes to Ax.
	beq.b	.ok
	cmp	#M_Ax,d5
	beq	ERROR_AddressRegByte
.ok
	cmp	#M_PcIdx,d5
	bhi.w	ERROR_InvalidAddrMode
	cmp	#M_Imm,d5
	beq.b	CEB14
	btst	#0,d6
	beq	ERROR_InvalidAddrMode
	jsr	(AddrOrDataReg).l
	cmp.w	#PB_APOLLO,(CPU_type-DT,a4)	;APOLLO support byte writes to Ax.
	beq.b	.ok2
	tst	d5	; M_Dx?
	bne	ERROR_AddressRegByte
.ok2
	add.b	d1,d1
	or.b	d1,(UsedRegs-DT,a4)
	and	#$F000,d6
	or.b	(OpperantSize-DT,a4),d6
	or.w	(UsedRegs-DT,a4),d6
	br	ASM_STORE_INSTRUCTION_HEAD

CEB14:
	jsr	(asm_noimmediateopp).l
	cmp.w	#PB_APOLLO,(CPU_type-DT,a4)	;APOLLO support byte writes to Ax.
	beq.b	.ok
	cmp	#M_Ax,d5
	beq	ERROR_AddressRegByte
.ok
	cmp	#M_Imm,d5
	bhs.b	CEB36
	and	#$0F00,d6
	or.b	(OpperantSize-DT,a4),d6
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

CEB36:
	cmp	#M_SrCcr,d5
	bne	ERROR_InvalidAddrMode
	move.b	(OpperantSize-DT,a4),d0
	and.b	d1,d0
	cmp.b	(OpperantSize-DT,a4),d0
	bne	ERROR_IllegalSize
	and	#$0F00,d6
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

CEB56:
	jsr	(asm_noimmediateopp).l
	cmp.w	#PB_APOLLO,(CPU_type-DT,a4)	;APOLLO support byte writes to Ax.
	beq.b	.ok
	cmp	#M_Ax,d5
	beq	ERROR_AddressRegByte
.ok
	cmp	#M_Imm,d5
	bhs.w	ERROR_InvalidAddrMode
	move	(UsedRegs-DT,a4),d0
	and	#$F001,d6
	bclr	#0,d6
	beq.b	CEB7E
	tst	d5	; M_Dx?
	beq.b	CEB84
CEB7E:
	bset	#8,d6
	exg	d0,d1
CEB84:
	ror.w	#7,d1
	or.b	(OpperantSize-DT,a4),d6
	or.w	d0,d6
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

CEB92:
	bsr	Asm_SkipInstructionHead
	jsr	(asm_noimmediateopp).l
	bsr	Parse_GetKomma
	tst	d5	; M_Dx?
	beq.b	CEBAE
	cmp	#M_AxDec,d5
	bne	ERROR_InvalidAddrMode
	addq.w	#8,d6
CEBAE:
	and	#7,d1
	or.w	d1,d6
	move	d5,-(sp)
	jsr	(asm_noimmediateopp).l
	cmp	(sp)+,d5
	bne	ERROR_InvalidAddrMode
	and	#7,d1
	ror.w	#7,d1
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

Asm_EXG:
	jsr	(AddrOrDataReg).l
	bsr	Parse_GetKomma
	and	#7,d1
	ror.w	#7,d1
	or.w	d1,d6
	move	d5,-(sp)
	jsr	(AddrOrDataReg).l
	or.w	d1,d6
	cmp	(sp)+,d5
	beq	Asm_InsertInstruction
	add	#$0040,d6
	tst	d5	; M_Dx?
	bne.b	CEC0A
	move	d6,d5
	and	#$0E07,d5
	sub	d5,d6
	add.b	d5,d5
	add.b	d5,d5
	rol.w	#7,d5
	add	d5,d6
	addq.w	#8,d6
CEC0A:
	br	Asm_InsertInstruction

Asm_Movep:
	bsr	Asm_SkipInstructionHead
	jsr	(asm_noimmediateopp).l
	bsr	Parse_GetKomma
	tst	d5	; M_Dx?
	beq.b	CEC42
	cmp	#M_AxDisp,d5
	bne	ERROR_InvalidAddrMode
	and	#15,d1
	or.w	d1,d6
	jsr	(AddrOrDataReg).l
	tst	d5	; M_Dx?
	bne	ERROR_Dataregexpect
	ror.w	#7,d1
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

CEC42:
	bset	#7,d6
	ror.w	#7,d1
	or.w	d1,d6
	jsr	(asm_noimmediateopp).l
	cmp	#M_AxDisp,d5
	bne	ERROR_InvalidAddrMode
	and	#15,d1
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

Asm_MOVEQ:
	jsr	(Parse_ImmediateValue).l
	bsr	Parse_GetKomma
	btst	#AF_UNDEFVALUE,d7
	bne.b	CECBC
	tst.b	d3	; bit7 set?
	bpl.b	CECA2
	tst.l	d3	; bit31 set?
	bmi.b	CECA2
	tst	d7	;passone
	bpl.b	CECA2
	lea	(WarningValues.MSG-DT,a4),a0
	bsr	printthetext
	move.l	(DATA_CURRENTLINE-DT,a4),d0
	beq.b	CECA2
	move.l	d0,(FirstLineNr-DT,a4)
	move.l	(DATA_LINE_START_PTR-DT,a4),(FirstLinePtr-DT,a4)
	bsr	Drukaf_CurrentLine
CECA2:
	move.b	d3,d0
	IF	MC020
	extb.l	d0
	ELSE
	ext.w	d0
	ext.l	d0
	ENDIF
	cmp.l	d0,d3
	beq.b	CECBA
	moveq	#0,d0
	move.b	d3,d0
	cmp.l	d3,d0
	bne	ERROR_out_of_range8bit
CECBA:
	or.b	d3,d6
CECBC:
	jsr	(AddrOrDataReg).l
	tst	d5	; M_Dx?
	bne	ERROR_Dataregexpect
	ror.w	#7,d1
	or.w	d1,d6
	br	Asm_InsertInstruction

MOVEM_BASE_MODES = M_AbsL|M_AbsW|M_AxIdx|M_AxDisp|M_AxInd

Asm_MOVEM:
	bsr	asm_4bytes_OpperantSize
	jsr	(PARSE_GET_EA_MOVEM_NOSIZE)
	bsr	Parse_GetKomma
	cmp	#M_Movem,d5
	beq.b	.FromRegs
.ToRegs
	and	#M_PcIdx|M_PcDisp|MOVEM_BASE_MODES|M_AxInc,d5
	beq	ERROR_InvalidAddrMode
	or.w	d1,d6
	bset	#10,d6
	jsr	(PARSE_GET_EA_MOVEM_NOSIZE)
	cmp	#M_Movem,d5
	bne	ERROR_InvalidAddrMode
	swap	d6
	move	d1,d6
	br	ASM_STORE_LONG
.FromRegs
	move.l	d1,-(sp)
	jsr	(PARSE_GET_EA_MOVEM_NOSIZE)
	and	#MOVEM_BASE_MODES|M_AxDec,d5
	beq	ERROR_InvalidAddrMode
	cmp	#$003A,d1
	bge.w	ERROR_InvalidAddrMode
	move.l	(sp)+,d3
	cmp	#M_AxDec,d5
	bne.b	.CED2A
	swap	d3
.CED2A	or.w	d1,d6
	swap	d6
	move	d3,d6
	br	ASM_STORE_LONG

Asmbl_CMDLEA:
	bsr	Asm_SkipInstructionHead
	jsr	(asm_noimmediateopp).l
	or.w	d1,d6
	bsr	Parse_GetKomma
	and	#M_AxInd|M_AxDisp|M_AxIdx|M_AbsW|M_AbsL|M_PcDisp|M_PcIdx,d5
	beq	ERROR_InvalidAddrMode
	jsr	(AddrOrDataReg).l
	tst	d5	; M_Dx?
	beq	ERROR_AddressRegExp
	subq.w	#8,d1
	ror.w	#7,d1
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

ASSEM_CMDADDQSUBQ:
	bsr	Asm_SkipInstructionHead
	jsr	Parse_ImmediateValue
	btst	#AF_UNDEFVALUE,d7
	bne.b	CED84
	subq.l	#1,d3
	moveq	#7,d1
	cmp.l	d1,d3
	bhi.w	ERROR_out_of_range3bit
	addq.w	#1,d3
	and	d1,d3
	ror.w	d1,d3
	or.w	d3,d6
CED84:
	bsr	Parse_GetKomma
	jsr	(asm_noimmediateopp).l
	cmp	#M_AbsL,d5
	bhi.w	ERROR_InvalidAddrMode
	cmp	#M_Ax,d5
	bne.b	CEDA2
	cmp.w	#PB_APOLLO,(CPU_type-DT,a4)	;APOLLO support byte writes to Ax.
	beq.b	.ok
	tst.b	d6
	beq	ERROR_AddressRegByte
.ok
CEDA2:
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

; Bset,Btst,bchng,bclr
ASSEM_CMDBIT:
	bsr	Asm_SkipInstructionHead
	clr.b	(OpperantSize-DT,a4)
	move	d5,-(sp)
	jsr	(asm_get_any_opp).l
	tst	d5	; M_Dx?
	bne.b	CEDCC
	moveq	#7,d2
	and	d2,d1
	ror.w	d2,d1
	and	#$F0FF,d6
	or.w	d1,d6
	bset	#8,d6
CEDCC:
	and	#~M_Imm,d5
	bne	ERROR_InvalidAddrMode
	bsr	Parse_GetKomma
	jsr	(asm_get_any_opp).l
	move	(sp)+,d0
	tst	d5	; M_Dx?
	beq.b	CEDE8
	bchg	#7,d0
CEDE8:
	cmp.w	#PB_APOLLO,(CPU_type-DT,a4)	;APOLLO support bit ax access
	beq.b	.ok
	tst.b	d0
	beq	ERROR_IllegalSize
.ok
	bclr	#15,d6
	beq.b	CEE02
	btst	#8,d6
	beq.b	CEDFE
	and	#~M_Imm,d5
CEDFE:
	and	#~(M_PcIdx|M_PcDisp),d5
CEE02:
	cmp.w	#PB_APOLLO,(CPU_type-DT,a4)	;APOLLO support bit ax access
	beq.b	.APOLLO
	and	#~(M_AbsL|M_AbsW|M_AxIdx|M_AxDisp|M_AxDec|M_AxInc|M_AxInd),d5
	bne	ERROR_InvalidAddrMode
	bra.b	.next
.APOLLO	
	btst	#11,d6
	bne.b	.next
	cmp.w	#M_Ax,d5
	beq	ERROR_InvalidAddrMode
.next	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

Asmbl_Cmpm:
	bsr	Asm_SkipInstructionHead
	jsr	(asm_noimmediateopp).l
	bsr	Parse_GetKomma
	cmp	#M_AxInc,d5
	bne	ERROR_InvalidAddrMode
	and	#7,d1
	or.w	d1,d6
	jsr	(asm_noimmediateopp).l
Asmbl_CmpmViaCmp:
	cmp	#M_AxInc,d5
	bne	ERROR_InvalidAddrMode
	and	#7,d1
	ror.w	#7,d1
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

Asm_Pvalid:
	bsr	asm_4bytes_OpperantSize
	jsr	(asm_get_any_opp).l
	cmp	#$FFFF,d5
	beq.b	CEE66
	cmp	#M_Ax,d5
	bne	ERROR_AddressRegExp
	bset	#10,d6
	or.w	d1,d6
	bra.b	CEE74

CEE66:
	swap	d5
	bclr	#15,d5
	cmp	#5,d5
	bne	ERROR_InvalidAddrMode
CEE74:
	bsr	Parse_GetKomma
	jsr	(asm_get_any_opp).l
	and	#~(M_AxInd|M_AxDisp|M_AxIdx|M_AbsW|M_AbsL),d5
	bne	ERROR_InvalidAddrMode
	swap	d6
	or.w	d1,d6
	swap	d6
	br	ASM_STORE_LONG

Asm_PtrapCC:
	move.b	d5,(OpperantSize-DT,a4)
	bsr	asm_4bytes_OpperantSize
	tst.b	d5
	beq	ASM_STORE_LONG
	jsr	(asm_get_any_opp).l
	cmp	#M_Imm,d5
	bne	ERROR_Immediateoper
	br	ASM_STORE_LONG

Asm_Ptest:
	jsr	(asm_get_any_opp).l
	cmp	#M_AxInd,d5
	beq	CEF68
	tst	d5	; M_Dx?
	beq.b	CEEEC
	cmp	#M_Imm,d5
	beq.b	CEEDC
	cmp	#$FFFF,d5
	bne	ERROR_InvalidAddrMode
	swap	d5
	cmp	#M_Ax,d5
	bgt.w	ERROR_InvalidAddrMode
	or.w	d5,d6
	bra.b	CEEF2
CEEDC:
	cmp	#7,d3
	bgt.w	ERROR_out_of_range3bit
	or.w	#$0010,d3
	or.w	d3,d6
	bra.b	CEEF2
CEEEC:
	or.w	#8,d1
	or.w	d1,d6
CEEF2:
	bsr	Parse_GetKomma
	bsr	asm_4bytes_OpperantSize
	jsr	(asm_get_any_opp).l
	tst	d5	; M_Dx?
	beq	ERROR_InvalidAddrMode
	and	#~(M_AxInd|M_AxDisp|M_AxIdx|M_AbsW|M_AbsL),d5
	bne	ERROR_InvalidAddrMode
	swap	d6
	or.w	d1,d6
	swap	d6
	cmp.b	#',',(a6)
	bne	ASM_STORE_LONG
	bsr	Parse_GetKomma
	jsr	(asm_get_any_opp).l
	cmp	#M_Imm,d5
	bne	ERROR_Immediateoper
	cmp	#7,d3
	bgt.w	ERROR_out_of_range3bit
	subq.l	#4,(Binary_Offset-DT,a4)
	ror.w	#6,d3
	or.w	d3,d6
	cmp.b	#',',(a6)
	bne	ASM_STORE_LONG
	bset	#8,d6
	bsr	Parse_GetKomma
	jsr	(asm_get_any_opp).l
	cmp	#M_Ax,d5
	bne	ERROR_AddressRegExp
	lsl.w	#5,d1
	or.w	d1,d6
	br	ASM_STORE_LONG

CEF68:
	move	#PB_ONLY|PB_040,d0
	bsr	Processor_warning
	bsr	Asm_SkipInstructionHead
	and.w	#7,d1
	btst	#9,d6
	beq.b	.CEF88
	move	#$F568,d6
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD
.CEF88	move	#$F548,d6
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

Asm_PsCC:
	or.l	#$F0400000,d6
	bsr	asm_4bytes_OpperantSize
	jsr	(asm_get_any_opp)
	cmp.w	#PB_APOLLO,(CPU_type-DT,a4)	;APOLLO support byte writes to Ax.
	beq.b	.ok
	cmp	#M_Ax,d5
	beq	ERROR_AddressRegByte
.ok	cmp	#M_Imm,d5
	bhs.w	ERROR_InvalidAddrMode
	swap	d6
	or.w	d1,d6
	swap	d6
	br	ASM_STORE_LONG

Asm_Psave_Prestore:
	move	#PB_MMU,d0
	bsr	Processor_warning
	bsr	Asm_SkipInstructionHead
	jsr	(asm_get_any_opp)
	cmp	#M_Ax,d5
	bls.b	.Error
	btst	#6,d6
	beq.b	.Save
.Rest	cmp	#M_AxDec,d5
	bne.b	.OK
.Error	bra	ERROR_InvalidAddrMode
.Save	cmp	#M_AxInc,d5
	beq.b	.Error
.OK	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

Asm_GetSpecOperandNoImm:
	jsr	(asm_noimmediateopp)
	bra.b	Asm_CheckSpecOperand

Asm_GetSpecOperand:
	jsr	(asm_get_any_opp)
Asm_CheckSpecOperand:
	cmp	#$FFFF,d5
	bne	ERROR_IllegalOperand
	swap	d5
	bclr	#31-16,d5
	rts

Pmove_CrpSrpTc:
	move	#PB_MMU|PB_ONLY,d0	;$0083
	bsr	Processor_warning
	bsr	asm_4bytes_OpperantSize
	jsr	(asm_get_any_opp).l
	cmp	#$FFFF,d5
	bne.b	.read
	swap	d5
	bclr	#15,d5			;PMOVE	<ea>,MMU-reg
	beq	ERROR_IllegalOperand
	cmp	#7,d5
	beq	ERROR_InvalidAddrMode
	cmp	#4,d5
	blt.w	ERROR_InvalidAddrMode

	ror.w	#6,d5
	or.w	d5,d6
	bset	#9,d6			;r/w bit

	bsr	Parse_GetKomma
	jsr	(asm_get_any_opp).l
	cmp	#M_Imm,d5
	bhi.w	ERROR_InvalidAddrMode
	swap	d6
	or.w	d1,d6
	swap	d6
	br	ASM_STORE_LONG

.read:					;PMOVE	MMU-reg,<ea>
	swap	d6
	or.w	d1,d6
	swap	d6
	bsr	Parse_GetKomma
	bsr.b	Asm_GetSpecOperand
	beq	ERROR_IllegalOperand
	cmp	#7,d5
	beq	ERROR_InvalidAddrMode
	cmp	#4,d5
	blt.w	ERROR_InvalidAddrMode

	ror.w	#6,d5
	or.w	d5,d6

	br	ASM_STORE_LONG

Pmove_MMUSR:
	st	(MMUAsmBits-DT,a4)
	move	#PB_851|PB_030|PB_ONLY,d0
	bsr	Processor_warning
	bsr	asm_4bytes_OpperantSize
	jsr	(asm_get_any_opp).l
	cmp	#$FFFF,d5
	bne.b	CF110
	swap	d5
	bclr	#15,d5
	beq	ERROR_IllegalOperand
	cmp	#1,d5
	ble.b	CF0E6
	cmp	#7,d5
	beq.b	CF0E6
	bclr	#14,d5
	beq	ERROR_IllegalOperand
	cmp	#4,d5
	beq.b	CF0E2
	cmp	#5,d5
	bne	ERROR_IllegalOperand
CF0E2:
	lsl.w	#2,d1
	or.w	d1,d6
CF0E6:
	ror.w	#6,d5
	or.w	d5,d6
	bset	#9,d6
	bsr	Parse_GetKomma
	jsr	(asm_get_any_opp).l
	cmp	#M_Imm,d5
	bhi.w	ERROR_InvalidAddrMode
	swap	d6
	or.w	d1,d6
	swap	d6
	sf	(MMUAsmBits-DT,a4)
	br	ASM_STORE_LONG

CF110:
	swap	d6
	or.w	d1,d6
	swap	d6
	bsr	Parse_GetKomma
	bsr	Asm_GetSpecOperand
	beq	ERROR_IllegalOperand
	cmp	#1,d5
	ble.b	CF162
	cmp	#7,d5
	beq.b	CF162
	bclr	#14,d5
	beq	ERROR_IllegalOperand
	cmp	#4,d5
	beq.b	CF15E
	cmp	#5,d5
	bne	ERROR_IllegalOperand
CF15E:
	lsl.w	#2,d1
	or.w	d1,d6
CF162:
	ror.w	#6,d5
	or.w	d5,d6
	sf	(MMUAsmBits-DT,a4)
	br	ASM_STORE_LONG

Pmove_TT0TT1:
	st	(MMUAsmBits-DT,a4)
	move	#PB_851|PB_030|PB_ONLY,d0	;$8083
	bsr	Processor_warning
	bsr	asm_4bytes_OpperantSize
	jsr	(asm_get_any_opp).l
	bsr	Parse_GetKomma
	cmp	#$FFFF,d5
	bne.b	.ToReg
.FromReg
	swap	d5
	bclr	#15,d5
	beq	ERROR_IllegalOperand
	tst	d5
	beq.b	.CF1B4
	cmp	#2,d5
	beq.b	.CF1C2
	cmp	#3,d5
	bne	ERROR_IllegalOperand
	bra.b	.CF1C2
.CF1B4
	cmp.b	#$40,(OpperantSize-DT,a4)
	beq	ERROR_IllegalOperand
	bset	#14,d6
.CF1C2
	ror.w	#6,d5
	or.w	d5,d6
	bset	#9,d6
	jsr	(asm_get_any_opp).l
	cmp	#M_Imm,d5
	bhi.w	ERROR_InvalidAddrMode
	swap	d6
	or.w	d1,d6
	swap	d6
	sf	(MMUAsmBits-DT,a4)
	br	ASM_STORE_LONG
.ToReg
	swap	d6
	or.w	d1,d6
	swap	d6
	bsr	Asm_GetSpecOperand
	beq	ERROR_IllegalOperand
	tst	d5
	beq.b	CF21C
	cmp	#2,d5
	beq.b	CF22A
	cmp	#3,d5
	bne	ERROR_IllegalOperand
	bra.b	CF22A

CF21C:
	cmp.b	#$40,(OpperantSize-DT,a4)
	beq	ERROR_IllegalOperand
	bset	#14,d6
CF22A:
	ror.w	#6,d5
	or.w	d5,d6
	sf	(MMUAsmBits-DT,a4)
	br	ASM_STORE_LONG

Pmove_CrpSrpTcDouble:
	st	(MMUAsmBits-DT,a4)
	move	#PB_ONLY|PB_MMU|PB_030,d0
	bsr	Processor_warning
	bsr	asm_4bytes_OpperantSize
	jsr	(asm_get_any_opp).l
	bsr	Parse_GetKomma
	cmp	#$FFFF,d5
	bne.b	CF29E
	swap	d5
	bclr	#15,d5
	beq	ERROR_IllegalOperand
	tst	d5
	beq	ERROR_IllegalOperand
	cmp	#3,d5
	bgt.w	ERROR_IllegalOperand
	ror.w	#6,d5
	or.w	d5,d6
	bset	#9,d6
	jsr	(asm_get_any_opp).l
	cmp	#M_Imm,d5
	bgt.w	ERROR_InvalidAddrMode
	swap	d6
	or.w	d1,d6
	swap	d6
	sf	(MMUAsmBits-DT,a4)
	br	ASM_STORE_LONG

CF29E:
	cmp	#M_Ax,d5
	bls.w	ERROR_InvalidAddrMode
	swap	d6
	or.w	d1,d6
	swap	d6
	bsr	Asm_GetSpecOperand
	beq	ERROR_IllegalOperand
	tst	d5
	beq	ERROR_IllegalOperand
	cmp	#3,d5
	bgt.w	ERROR_IllegalOperand
	ror.w	#6,d5
	or.w	d5,d6
	br	ASM_STORE_LONG

Asm_HandlePload:
	move	#PB_851|PB_030|PB_ONLY,d0
	bsr	Processor_warning
	jsr	(asm_get_any_opp).l
	cmp	#M_Imm,d5
	beq.b	CF304
	tst	d5	; M_Dx?
	beq.b	CF32C
	cmp	#$FFFF,d5
	bne	ERROR_InvalidAddrMode
	swap	d5
	cmp.w	#1,d5
	bhi.w	ERROR_IllegalOperand
	or.w	d5,d6
	bra.b	CF334

CF304:
	tst.b	(PR_MMU).l
	beq.b	CF31C
	cmp	#15,d3
	bgt.w	ERROR_out_of_range4bit
	or.w	#$0010,d3
	or.w	d3,d6
	bra.b	CF334

CF31C:
	cmp	#7,d3
	bgt.w	ERROR_out_of_range3bit
	or.w	#$0010,d3
	or.w	d3,d6
	bra.b	CF334

CF32C:
	or.w	#8,d1
	or.w	d1,d6
CF334:
	bsr	Parse_GetKomma
	bsr	asm_4bytes_OpperantSize
	swap	d6
	jsr	(asm_get_any_opp).l
	tst	d5	; M_Dx?
	beq	ERROR_InvalidAddrMode
	and	#M_Ax|M_AxInc|M_AxDec|M_Imm,d5
	bne	ERROR_InvalidAddrMode
	or.w	d1,d6
	swap	d6
	br	ASM_STORE_LONG

Asm_HandlePflushr:
	move	#PB_MMU|PB_851,d0
	bsr	Processor_warning
	bsr	asm_4bytes_OpperantSize
	jsr	(asm_get_any_opp).l
	cmp	#M_AxInd,d5
	blt.w	ERROR_InvalidAddrMode
	or.w	d1,d6
	swap	d6
	br	ASM_STORE_LONG

;------------

Asm_HandlePflush:
	jsr	(asm_get_any_opp).l
	cmp	#M_AxInd,d5
	beq	Asm_PFLUSH040
	cmp	#M_Imm,d5
	beq.b	.gotimm
	tst	d5	; M_Dx?
	beq.b	.datareg
	cmp	#$FFFF,d5	;DFC/SFC
	bne	ERROR_InvalidAddrMode
	clr.w	d5
;	eor.w	#$ffff,d5
	swap	d5
;	and.w	#$fffe,d5	;DFC
	cmp.w	#1,d5
	bhi.w	ERROR_IllegalOperand
	or.w	d5,d6
	bra.b	.goon_pflush

.gotimm:
	tst.w	PR_MMU
	beq.s	.mc68030

	cmp	#15,d3
	bgt.w	ERROR_out_of_range4bit
	or.w	#$0010,d3
	or.w	d3,d6
	bra.b	.goon_pflush

.mc68030:
	cmp	#7,d3
	bgt.w	ERROR_out_of_range3bit
	or.w	#$0010,d3
	or.w	d3,d6
	bra.b	.goon_pflush

.datareg:
	or.w	#8,d1
	or.w	d1,d6
.goon_pflush:
	bsr	Parse_GetKomma
	jsr	(asm_get_any_opp).l
	cmp	#M_Imm,d5
	bne	ERROR_InvalidAddrMode

	tst.w	PR_MMU
	bne.s	.mc68851
	cmp	#7,d3
	bgt.w	ERROR_out_of_range3bit
.mc68851:
	cmp	#15,d3
	bgt.w	ERROR_out_of_range4bit

	lsl.w	#5,d3
	or.w	d3,d6
	bsr	asm_4bytes_OpperantSize
	cmp.b	#',',(a6)	;$2c
	bne.b	.noaddress

	bsr	Parse_GetKomma
	jsr	(asm_get_any_opp).l
	cmp.w	#M_Ax,d5
	bls	ERROR_InvalidAddrMode
	and	#M_AxInd|M_AxDisp|M_AbsW|M_AbsL,d5
	bne	ERROR_InvalidAddrMode
	swap	d6
	or.w	d1,d6
	swap	d6
	bset	#11,d6
.noaddress:
	move.w	#PB_851|PB_030|PB_ONLY,d0
	bsr	Processor_warning
	br	ASM_STORE_LONG

;--------

Asm_Get040Pflushopp:
;	move	#PB_ONLY|PB_040,d0
;	bsr	Processor_warning
	bsr	Asm_SkipInstructionHead
	jsr	(asm_noimmediateopp).l
	cmp	#M_AxInd,d5
	bne	ERROR_InvalidAddrMode
	bra.b	CF432

;----------

Asm_PFLUSH040:
	bsr	Asm_SkipInstructionHead
	move	#$F508,d6
CF432:
	and	#7,d1
	or.w	d1,d6
	moveq	#PB_040,d0
	bsr	Processor_warning
	br	ASM_STORE_INSTRUCTION_HEAD

CF43C:
	bsr	asm_4bytes_OpperantSize
	jsr	(AddrOrDataReg).l
	tst	d5	; M_Dx?
	bne	ERROR_Dataregexpect
	or.w	d1,d6
	swap	d6
	bsr	Parse_GetKomma
	jsr	(PARSE_GET_LABEL_16BIT)
	move	#PB_MMU|PB_851|PB_010,d0
	bsr	Processor_warning
	br	ASM_STORE_LONG

CF466:
	bsr	Asm_SkipInstructionHead
	cmp	#$40,d5
	beq.b	CF482
	jsr	(PARSE_GET_LABEL_32BIT)
	move	#PB_MMU|PB_851|PB_010,d0
	bsr	Processor_warning
	br	ASM_STORE_INSTRUCTION_HEAD

CF482:
	jsr	(PARSE_GET_LABEL_16BIT)
	br	ASM_STORE_INSTRUCTION_HEAD

CF48C:
	bsr	asm_4bytes_OpperantSize
	move.b	#$80,(OpperantSize-DT,a4)
	jsr	(asm_get_any_opp).l
	cmp	#$FFFF,d5
	beq	ERROR_InvalidAddrMode
	cmp	#M_Ax,d5
	beq	ERROR_InvalidAddrMode
	cmp	#M_Imm,d5
	bhs.w	ERROR_InvalidAddrMode
	or.w	d1,d6
	swap	d6
	moveq	#PB_FPU,d0
	bsr	Processor_warning
	br	ASM_STORE_LONG

Asm_FsaveFrestore:
	bsr	Asm_SkipInstructionHead
	move.b	#$80,(OpperantSize-DT,a4)
	jsr	(asm_get_any_opp).l
	tst	d5	; M_Dx?
	beq	ERROR_InvalidAddrMode
	tst.b	d6
	bne.b	.Restore
.Save
	cmp	#M_Imm,d5
	bhs.w	ERROR_InvalidAddrMode
	and	#M_Ax|M_AxInc,d5
	bra.b	.CF4FE
.Restore
	and	#M_Ax|M_AxDec|M_Imm,d5
.CF4FE
	bne	ERROR_InvalidAddrMode
	or.w	d1,d6
	moveq	#PB_FPU,d0
	bsr	Processor_warning
	br	ASM_STORE_INSTRUCTION_HEAD

Asm_FMOVEM:
	moveq	#PB_FPU,d0
	bsr	Processor_warning
	move.b	d5,(OpperantSize-DT,a4)
	bsr	asm_4bytes_OpperantSize
	jsr	(asm_noimmediateopp).l
	clr.l	(WorkBuffer-DT,a4)	; clears: mask.w or last_reg.w, mask.b, ~mask.b
	cmp	#$FFFF,d5
	bne	Asm_FMOVEM_ToRegList
	tst.l	d5	; bit31 set?
	bmi.w	ERROR_InvalidAddrMode
	swap	d5
	cmp	#$0010,d5	; FPx?
	beq	Asm_FMOVEM_FromRegList

	move.b	(OpperantSize-DT,a4),d0	; no size or .L?
	beq.b	.CF53C
	cmp.b	#$80,d0
	bne.w	ERROR_IllegalSize
.CF53C	lsl.w	#10-5,d5	; FPIAR 1<<5, FPSR 1<<6, or FPCR 1<<7, to opcode bits 10-12
	or.w	d5,(WorkBuffer-DT,a4)
	cmp.b	#'/',(a6)
	bne.b	.CF56C
	addq.w	#1,a6
	bsr	Asm_GetSpecOperandNoImm
	bne	ERROR_InvalidAddrMode
	cmp	#$0010,d5	; FPx?
	bne.b	.CF53C
	bra.w	ERROR_IllegalOperand

.CF56C	cmp.b	#',',(a6)+
	bne	ERROR_Commaexpected
	swap	d6
	or.w	#$A000,d6	; ctrl regs to mem
	or.w	(WorkBuffer-DT,a4),d6
	swap	d6
	jsr	(asm_get_any_opp).l
	tst	d5	; M_Dx (fmovem.l <ctrl_reg>,dx)?
	bne.b	CF5A8
	cmp	#$0400,(WorkBuffer-DT,a4)	; FPIAR?
	beq.b	CF5B8
	cmp	#$0800,(WorkBuffer-DT,a4)	; FPSR?
	beq.b	CF5B8
	cmp	#$1000,(WorkBuffer-DT,a4)	; FPCR?
	beq.b	CF5B8
	br	ERROR_InvalidAddrMode

CF5A8:
	cmp	#M_Ax,d5
	bne.b	CF5B8
	cmp	#$0400,(WorkBuffer-DT,a4)	; FPIAR to Ax?
	bne	ERROR_InvalidAddrMode
CF5B8:
	cmp	#$0039,d1
	bgt.w	ERROR_InvalidAddrMode
	or.w	d1,d6
	swap	d6
	br	ASM_STORE_LONG

Asm_FMOVEM_ToRegList:
	tst	d5	; M_Dx?
	beq	ERROR_InvalidAddrMode
	and	#M_Ax|M_AxDec,d5
	bne	ERROR_InvalidAddrMode
	or.w	d1,d6
	swap	d6
	bsr	Parse_GetKomma
	bsr	Asm_GetSpecOperandNoImm
	bne	ERROR_InvalidAddrMode
	cmp	#$0010,d5	; FPx?
	beq.b	.HandleFp

	move.b	(OpperantSize-DT,a4),d0		; no size or .L?
	beq.b	.LoopCtrl
	cmp.b	#$80,d0
	bne.w	ERROR_IllegalSize
.LoopCtrl
	lsl.w	#10-5,d5	; FPIAR 1<<5, FPSR 1<<6, or FPCR 1<<7, to opcode bits 10-12
	or.w	d5,(WorkBuffer-DT,a4)
	cmp.b	#'/',(a6)+
	bne.b	.LastCtrl
	bsr	Asm_GetSpecOperandNoImm
	bne	ERROR_InvalidAddrMode
	cmp	#$0010,d5	; FPx?
	bne.b	.LoopCtrl
	bra.w	ERROR_IllegalOperand
.LastCtrl
	subq.w	#1,a6
	or.w	#$8000,d6
	or.w	(WorkBuffer-DT,a4),d6
	br	ASM_STORE_LONG

.HandleFp
	move.b	(OpperantSize-DT,a4),d0		; no size or .X?
	beq.b	.SizeOK
	cmp.b	#$72,d0
	bne.w	ERROR_IllegalSize
.SizeOK
	bsr.b	Asm_ParseFmovemRegs
	or.w	#$5000,d6		; fp regs, always reverse mask (can't be predec)
	or.b	(WorkBuffer+3-DT,a4),d6
	br	ASM_STORE_LONG

Asm_ParseFmovemRegs:
.LoopSingle
	moveq	#'-',d3
.Loop
	move.b	(a6)+,d0
	cmp.b	d3,d0
	beq.b	.AddRange
	bset	d1,(WorkBuffer+2-DT,a4)
	not.w	d1
	bset	d1,(WorkBuffer+3-DT,a4)
	cmp.b	#"/",d0
	bne.b	.Finish
.AddSingle
	bsr	Asm_GetSpecOperandNoImm
	bne.b	Asm_FMOVEM_InvMode
	cmp	#$0010,d5	; FPx?
	beq.b	.LoopSingle
.BadOperand
	bra.w	ERROR_IllegalOperand
.AddRange
	move.w	d1,-(a7)
	bsr	Asm_GetSpecOperandNoImm
	bne.b	Asm_FMOVEM_InvMode
	cmp	#$0010,d5	; FPx?
	bne.b	.BadOperand
	move.w	(a7)+,d3
	cmp.w	d1,d3
	bls.b	.RangeLoop
	exg	d1,d3
.RangeLoop
	bset	d3,(WorkBuffer+2-DT,a4)
	not.w	d3
	bset	d3,(WorkBuffer+3-DT,a4)
	not.w	d3
	addq.w	#1,d3
	cmp.w	d1,d3
	blo.b	.RangeLoop
	bra.b	.Loop			; add last reg and loop
.Finish
	subq.w	#1,a6
	rts

Asm_FMOVEM_InvMode:
	bra.w	ERROR_InvalidAddrMode

Asm_FMOVEM_FromRegList:
	bsr.b	Asm_ParseFmovemRegs
	cmp.b	#',',(a6)+
	bne	ERROR_Commaexpected
	jsr	(asm_noimmediateopp).l
	cmp	#$FFFF,d5
	beq.b	Asm_FMOVEM_InvMode
	tst	d5	; M_Dx?
	beq.b	Asm_FMOVEM_InvMode
	or.w	d1,d6
	swap	d6
	or.w	#$e000,d6		; fp regs to mem
	move.b	(WorkBuffer+2-DT,a4),d1
	cmp	#M_AxDec,d5
	beq.b	.PreDec
	and.w	#M_PcIdx|M_PcDisp|M_AxInc|M_Ax,d5
	bne.b	Asm_FMOVEM_InvMode
	move.b	(WorkBuffer+3-DT,a4),d1
	or.w	#$1000,d6		; reverse mask
.PreDec	or.b	d1,d6
	br	ASM_STORE_LONG

Asmbl_FinishFmove:
	move.l	#$0000F200,d6
	moveq	#PB_FPU,d0
	bsr	Processor_warning
	bsr	asm_4bytes_OpperantSize
	move.b	d5,(OpperantSize-DT,a4)
	jsr	asm_get_any_opp
	bsr	Parse_GetKomma
	and.b	#15,(OpperantSize-DT,a4)
	cmp	#$FFFF,d5
	bne	Asmbl_fmovenormal
	tst.l	d5	; bit31 set?
	bmi.w	ERROR_InvalidAddrMode
	swap	d5
	cmp	#$0010,d5
	beq.b	Asmbl_fmovefloat
	lsl.w	#5,d5	;/32
	swap	d6
	or.w	d5,d6
	or.w	#$A000,d6
	swap	d6
	jsr	(asm_noimmediateopp).l
	cmp	#$0800,d5
	beq	ERROR_InvalidAddrMode
	or.w	d1,d6
	swap	d6
	br	ASM_STORE_LONG

Asmbl_fmovefloat:
	move	d1,(WorkBuffer-DT,a4)
	cmp.b	#3,(OpperantSize-DT,a4)
	bne	CF8EE
	jsr	(asm_noimmediateopp).l
	cmp	#M_Ax,d5
	beq	ERROR_InvalidAddrMode
	cmp.w	#M_Imm,d5
	bhs	ERROR_InvalidAddrMode
	cmp.b	#'{',(a6)+
	beq.b	CF88A
	or.w	d1,d6
	swap	d6
	move	#$6C00,d3
	subq.w	#1,a6
	bra.b	CF8BA

CF88A:		; parse k-factor: {Dx} or {#<7-bit signed>} (# is optional)
	or.w	d1,d6
	swap	d6
	moveq	#~32,d0
	and.b	(a6),d0
	cmp.b	#'D',d0
	beq.b	CF8CC
	cmp.b	#'#'&(~32),d0		; optional
	bne.b	.NoHash
	addq.w	#1,a6
.NoHash	bsr	Parse_GetExprValueInD3Voor
	cmp.b	#'}',(a6)+
	bne	ERROR_Missingbrace
	moveq	#64,d0			; 7-bit signed (-64..63)
	add.l	d0,d3
	moveq	#127,d0
	cmp.l	d0,d3
	bhi.w	ERROR_OutofRange7bit
	eor.w	#$6c00+64,d3		; also subtracts 64
CF8BA:
	or.w	d3,d6
	or.w	#$6000,d6
	move	(WorkBuffer-DT,a4),d5
	lsl.w	#7,d5
	or.w	d5,d6
	br	ASM_STORE_LONG

CF8CC:
	addq.w	#1,a6
	move.w	#$7c00+(256-'0'),d3
	add.b	(a6)+,d3
	cmp.b	#7,d3			; dreg
	bhi.w	ERROR_IllegalOperand
	cmp.b	#'}',(a6)+
	bne	ERROR_Missingbrace
	lsl.b	#4,d3
	bra.b	CF8BA

CF8EE:
	swap	d6
	jsr	(asm_noimmediateopp).l
	cmp	#$FFFF,d5
	bne.b	CF92E
	tst.l	d5	; bit31 set?
	bmi.w	ERROR_InvalidAddrMode
	swap	d5
	cmp	#$0010,d5	; FPx?
	bne	ERROR_InvalidAddrMode
	cmp.b	#2,(OpperantSize-DT,a4)
	bne	ERROR_Illegalfloating
	and.l	#$FFC0FFFF,d6
	lsl.w	#7,d1
	or.w	d1,d6
	move	(WorkBuffer-DT,a4),d5
	ror.w	#6,d5
	or.w	d5,d6
	br	ASM_STORE_LONG

CF92E:
	cmp.w	#M_Imm,d5
	bhs	ERROR_InvalidAddrMode
	tst	d5	; M_Dx?
	bne.b	CF956
	move.b	(OpperantSize-DT,a4),d0
	subq.b	#1,d0
	ble.b	CF956
	subq.b	#4-1,d0
	beq.b	CF956
	subq.b	#6-4,d0
	bne	ERROR_Illegalsizeform

CF956:
	swap	d6
	or.w	d1,d6
	swap	d6
	moveq	#7,d5
	and.b	(OpperantSize-DT,a4),d5
	ror.w	#6,d5
	or.w	d5,d6
	or.w	#$6000,d6
	move	(WorkBuffer-DT,a4),d5
	lsl.w	#7,d5
	or.w	d5,d6
	br	ASM_STORE_LONG

Asmbl_fmovenormal:
	cmp	#M_Ax,d5
	beq	ERROR_InvalidAddrMode
	tst	d5	; M_Dx?
	bne.b	Asmbl_fmoveNormal2fpr
	move.b	(OpperantSize-DT,a4),d0
	subq.b	#1,d0
	ble.b	Asmbl_fmoveNormal2fpr
	subq.b	#4-1,d0
	beq.b	Asmbl_fmoveNormal2fpr
	subq.b	#6-4,d0
	bne	ERROR_Illegalsizeform

Asmbl_fmoveNormal2fpr:
	or.w	d1,d6
	swap	d6
	bsr	Asm_GetSpecOperand
	bne	ERROR_InvalidAddrMode
	cmp	#$0010,d5	; FPx?
	bne.b	Asmbl_fmove2ctrlreg
	and	#7,d1
	lsl.w	#7,d1
	or.w	d1,d6
	moveq	#7,d5		; safe to wipe out d5
	and.b	(OpperantSize-DT,a4),d5
	ror.w	#6,d5
	or.w	d5,d6
	bset	#14,d6
	br	ASM_STORE_LONG

Asmbl_fmove2ctrlreg:
	tst.b	(OpperantSize-DT,a4)
	bne	ERROR_IllegalSize
	bset	#15,d6
	lsl.w	#5,d5
	and	#$1C00,d5
	or.w	d5,d6
	br	ASM_STORE_LONG

Asm_FMOVECR:
	moveq	#PB_FPU,d0
	bsr	Processor_warning
	bsr	asm_4bytes_OpperantSize
	cmp.b	#'#',(a6)+
	bne	ERROR_InvalidAddrMode
	bsr	Parse_GetExprValueInD3Voor
	bsr	Parse_GetKomma
	cmp	#$007F,d3
	bgt.w	ERROR_OutofRange7bit
	swap	d6
	or.w	d3,d6
	bsr	Asm_GetSpecOperandNoImm
	bne	ERROR_InvalidAddrMode
	cmp	#$0010,d5
	bne	ERROR_InvalidAddrMode
	lsl.w	#7,d1
	or.w	d1,d6
	br	ASM_STORE_LONG

Asm_FtrapCC:
	moveq	#PB_FPU,d0
	bsr	Processor_warning
	bsr	asm_4bytes_OpperantSize
	btst	#$11,d6
	beq.b	CFA74
	move.b	#$80,(OpperantSize-DT,a4)
	btst	#$10,d6
	bne.b	CFA66
	move.b	#$40,(OpperantSize-DT,a4)
CFA66:
	jsr	(asm_get_any_opp).l
	cmp	#M_Imm,d5
	bne	ERROR_InvalidAddrMode
CFA74:
	br	ASM_STORE_LONG

Asm_FTST:
	moveq	#PB_FPU,d0
	bsr	Processor_warning
	move.b	d5,(OpperantSize-DT,a4)
	bsr	asm_4bytes_OpperantSize
	jsr	(asm_get_any_opp).l
	cmp	#M_Ax,d5
	beq	ERROR_InvalidAddrMode
	cmp	#$FFFF,d5
	beq.b	CFACE
	tst	d5	; M_Dx?
	bne.b	CFABE
	tst.b	(OpperantSize-DT,a4)
	beq.b	CFABE
	cmp.b	#4,(OpperantSize-DT,a4)
	beq.b	CFABE
	cmp.b	#6,(OpperantSize-DT,a4)
	beq.b	CFABE
	cmp.b	#$71,(OpperantSize-DT,a4)
	bne	ERROR_Illegalsizeform
CFABE:
	or.w	d1,d6
	moveq	#7,d1
	and.b	(OpperantSize-DT,a4),d1
	bset	#$1E,d6
CFACE:
	swap	d6
	ror.w	#6,d1
	or.w	d1,d6
	br	ASM_STORE_LONG

CFAD8:
	moveq	#PB_FPU,d0
	bsr	Processor_warning
	bsr	asm_4bytes_OpperantSize
	jsr	(AddrOrDataReg).l
	tst	d5	; M_Dx?
	bne	ERROR_Dataregexpect
	or.w	d1,d6
	swap	d6
	bsr	Parse_GetKomma
	jsr	(PARSE_GET_LABEL_16BIT)
	br	ASM_STORE_LONG

CFB00:
	moveq	#PB_FPU,d0
	bsr	Processor_warning
	move.b	d5,(OpperantSize-DT,a4)
	bne.b	.NotLong
	move.b	#$80,(OpperantSize-DT,a4)	; fpu .L ($00) to generic .L ($80)
.NotLong
	bsr	asm_4bytes_OpperantSize
	jsr	(asm_get_any_opp).l
	cmp	#M_Ax,d5
	beq	ERROR_InvalidAddrMode
	cmp	#$FFFF,d5
	beq.b	CFB5E
	or.w	d1,d6
	swap	d6
	move.b	(OpperantSize-DT,a4),d0
	tst	d5	; M_Dx?
	bne.b	.CFB50
	cmp.b	#4,d0	; .W?
	beq.b	.CFB50
	cmp.b	#6,d0	; .B?
	beq.b	.CFB50
	cmp.b	#$80,d0	; .L?
	beq.b	.CFB50
	cmp.b	#$71,d0	; .S?
	bne	ERROR_Illegalsizeform
.CFB50
	and.w	#7,d0
	ror.w	#6,d0
	or.w	d0,d6
	bset	#14,d6
	bra.b	CFB86

CFB5E:
	cmp.b	#$72,(OpperantSize-DT,a4)
	bne	ERROR_IllegalSize
	tst.l	d5		; bit31 set?
	bmi.w	ERROR_InvalidAddrMode
	swap	d5
	swap	d6
	cmp	#$0010,d5	; FPx?
	bne	ERROR_InvalidAddrMode
	ror.w	#6,d1
	or.w	d1,d6
	cmp.b	#$2C,(a6)
	bne.b	CFBB2
CFB86:
	bsr	Parse_GetKomma
	bsr	Asm_GetSpecOperand
	bne	ERROR_InvalidAddrMode
	cmp	#$0010,d5	; FPx?
	bne	ERROR_InvalidAddrMode
	lsl.w	#7,d1
CFBAC:
	or.w	d1,d6
	br	ASM_STORE_LONG
CFBB2:
	lsr.w	#3,d1
	bra.b	CFBAC

Asm_FPopperant:
	moveq	#PB_FPU,d0
	bsr	Processor_warning
	move.b	d5,(OpperantSize-DT,a4)
	bne.b	.NotLong
	move.b	#$80,(OpperantSize-DT,a4)	; fpu .L ($00) to generic .L ($80)
.NotLong
	bsr	asm_4bytes_OpperantSize
	jsr	(asm_get_any_opp).l
	cmp	#M_Ax,d5
	beq	ERROR_InvalidAddrMode
	cmp	#$FFFF,d5
	beq.b	CFC14
	or.w	d1,d6
	swap	d6
	move.b	(OpperantSize-DT,a4),d0
	tst	d5	; M_Dx
	bne.b	.FPIntOpperant
	cmp.b	#4,d0	; .W?
	beq.b	.FPIntOpperant
	cmp.b	#6,d0	; .B?
	beq.b	.FPIntOpperant
	cmp.b	#$80,d0		; .L?
	beq.b	.FPIntOpperant
	cmp.b	#$71,d0	; .S?
	bne	ERROR_Illegalsizeform

.FPIntOpperant
	and.w	#7,d0
	ror.w	#6,d0
	or.w	d0,d6
	bset	#14,d6
	bra.b	CFC3E

CFC14:
	cmp.b	#$72,(OpperantSize-DT,a4)
	bne	ERROR_IllegalSize
	swap	d6
	tst.l	d5	; bit31 set?
	bmi.w	ERROR_InvalidAddrMode
	swap	d5
	cmp	#$0010,d5
	bne	ERROR_InvalidAddrMode
	ror.w	#6,d1
	or.w	d1,d6
	cmp.b	#',',(a6)
	bne	ERROR_Commaexpected
CFC3E:
	bsr	Parse_GetKomma
	bsr	Asm_GetSpecOperand
	bne	ERROR_InvalidAddrMode
	cmp	#$0010,d5
	bne	ERROR_InvalidAddrMode
	lsl.w	#7,d1
	or.w	d1,d6
	br	ASM_STORE_LONG

CFD20:	swap	d6
	ror.w	#6,d1
	or.w	d1,d6
	bra.b	CFCCE

CFC6A:	; FPc:FPs (fsincos)
	moveq	#PB_FPU,d0
	bsr	Processor_warning
	bsr	asm_4bytes_OpperantSize
	move.b	d5,(OpperantSize-DT,a4)
	bne.b	.NotLong
	move.b	#$80,(OpperantSize-DT,a4)	; fpu .L ($00) to generic .L ($80)
.NotLong
	jsr	(asm_get_any_opp).l
	bsr	Parse_GetKomma
	cmp	#$FFFF,d5
	beq.b	CFD20
	cmp	#M_Ax,d5
	beq	ERROR_InvalidAddrMode
	move.b	(OpperantSize-DT,a4),d0
	tst	d5	; M_Dx
	bne.b	CFCB8
	cmp.b	#4,d0	; .W?
	beq.b	CFCB8
	cmp.b	#6,d0	; .B?
	beq.b	CFCB8
	cmp.b	#$80,d0	; .L?
	beq.b	CFCB8
	cmp.b	#$71,d0	; .S?
	bne	ERROR_Illegalsizeform
CFCB8:
	or.w	d1,d6		; first reg to bits 0-2 (cos)
	swap	d6
	bset	#14,d6
	and.w	#7,d0
	ror.w	#6,d0
	or.w	d0,d6
CFCCE:
	bsr	Asm_GetSpecOperandNoImm
	bne	ERROR_InvalidAddrMode
	cmp	#$0010,d5	; FPx?
	bne	ERROR_InvalidAddrMode
	or.w	d1,d6
	cmp.b	#':',(a6)+
	bne	ERROR_Colonexpected
	bsr	Asm_GetSpecOperandNoImm
	bne	ERROR_InvalidAddrMode
	cmp	#$0010,d5	; FPx?
	bne	ERROR_InvalidAddrMode
	lsl.w	#7,d1		; second reg to bits 7-9 (sin)
	or.w	d1,d6
	br	ASM_STORE_LONG

Asm_Move16Afronden:
	moveq	#PB_040,d0
	bsr	Processor_warning
	bsr	Asm_SkipInstructionHead
	jsr	(asm_noimmediateopp).l
	and.w	#7,d1
	bsr	Parse_GetKomma
	cmp	#M_AxInd,d5
	beq.b	.CFD80
	cmp	#M_AxInc,d5
	beq.b	.CFDA0
	cmp	#M_AbsL,d5
	bne	ERROR_InvalidAddrMode
	bset	#3,d6
	jsr	(asm_noimmediateopp).l
	and.w	#7,d1
	cmp	#M_AxInd,d5
	beq.b	.CFD72
	cmp	#M_AxInc,d5
	bne	ERROR_InvalidAddrMode
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

.CFD72	bset	#4,d6
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

.CFD80	move	d1,-(sp)
	jsr	(asm_get_any_opp).l
	move	(sp)+,d1
	cmp	#M_AbsL,d5
	bne	ERROR_InvalidAddrMode
	bset	#4,d6
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

.CFDA0	or.w	d1,d6
	jsr	(asm_get_any_opp).l
	cmp	#M_AbsL,d5
	beq.b	CFDD2
	cmp	#M_AxInc,d5
	bne	ERROR_InvalidAddrMode
	and	#7,d1
	ror.w	#4,d1
	bset	#5,d6
	swap	d6
	or.w	d1,d6
	bsr	asm_4bytes_OpperantSize
	br	ASM_STORE_LONG
CFDD2:
	br	ASM_STORE_INSTRUCTION_HEAD

Asm_Moves:
	moveq	#PB_010,d0
	bsr	Processor_warning
	bsr	asm_4bytes_OpperantSize
	jsr	(asm_noimmediateopp).l
	bsr	Parse_GetKomma
	cmp	#M_Ax,d5	; ax/dx?
	bls.b	.FromReg
.ToReg
	or.b	d1,d6
	swap	d6
	clr.w	d6
	jsr	(asm_noimmediateopp).l
	cmp	#M_Ax,d5	; ax/dx?
	bhi	ERROR_InvalidAddrMode
	ror.w	#4,d1
	or.w	d1,d6
	br	ASM_STORE_LONG
.FromReg
	swap	d6
	clr.w	d6
	ror.w	#4,d1
	or.w	d1,d6
	bset	#11,d6		; dir: reg to ea
	swap	d6
	jsr	(asm_noimmediateopp).l
	cmp	#M_Ax,d5	; ax/dx?
	bls.w	ERROR_InvalidAddrMode
	or.b	d1,d6
	swap	d6
	br	ASM_STORE_LONG

asm_movec_crs:
	moveq	#PB_010,d0
	bsr	Processor_warning

	bsr	asm_4bytes_OpperantSize
	jsr	(asm_noimmediateopp).l
	bsr	Parse_GetKomma
	cmp	#M_Usp,d5
	beq.b	CFEAE
	cmp	#$FFFF,d5
	beq.b	CFEB4
	bset	#0,d6
	cmp	#M_Ax,d5
	bhi.w	ERROR_InvalidAddrMode
	move	d1,-(sp)
	jsr	(asm_noimmediateopp).l
	cmp	#M_Usp,d5
	bne.b	CFE7E
	move.l	#$0800FFFF,d5
CFE7E:
	cmp	#$FFFF,d5
	bne	ERROR_InvalidAddrMode
	tst.l	d5	; bit31 set?
	bmi.w	ERROR_InvalidAddrMode
	swap	d5
	move	d5,d0
	and	#$00F0,d0
	bne	ERROR_InvalidAddrMode
	move	(sp)+,d1
	ror.w	#4,d1
	or.w	d1,d5
CFEA2:
	swap	d6
	clr.w	d6
	or.w	d5,d6
	br	ASM_STORE_LONG

CFEAE:
	move.l	#$0800FFFF,d5
CFEB4:
	tst.l	d5	; bit31 set?
	bmi.w	ERROR_InvalidAddrMode
	swap	d5
	move	d5,d0
	and	#$00F0,d0
	bne	ERROR_InvalidAddrMode
	move	d5,-(sp)
	jsr	(asm_noimmediateopp).l
	subq.w	#M_Ax,d5
	bhi.w	ERROR_InvalidAddrMode
	move	(sp)+,d5
	ror.w	#4,d1
	or.w	d1,d5
	bra.b	CFEA2

Asm_TrapccNoOperand:
	move.w	#$8040,d5	; no size
CFEE2:
	bsr	Asm_SkipInstructionHead
	move.b	d5,(OpperantSize-DT,a4)
	cmp.w	#$8040,d5
	beq.b	.NoOper
	jsr	(asm_get_any_opp).l
	cmp	#M_Imm,d5
	bne	ERROR_InvalidAddrMode
	br	ASM_STORE_INSTRUCTION_HEAD
.NoOper	and	#$FFFC,d6
	bset	#2,d6
	br	ASM_STORE_INSTRUCTION_HEAD

Asm_PackUnpk:
	moveq	#PB_020,d0
	bsr	Processor_warning
	move.b	#$40,(OpperantSize-DT,a4)	; .w
	bsr	Asm_SkipInstructionHead
	jsr	(asm_get_any_opp).l
	bsr	Parse_GetKomma
	and	#7,d1
	or.w	d1,d6
	cmp	#M_AxDec,d5
	beq.b	.CFF62
	tst	d5	; M_Dx
	bne	ERROR_InvalidAddrMode
	jsr	(asm_get_any_opp).l
	bsr	Parse_GetKomma
	tst	d5	; M_Dx
	bne	ERROR_InvalidAddrMode
.CFF48
	and	#7,d1
	ror.w	#7,d1
	or.w	d1,d6
	jsr	(asm_get_any_opp).l
	cmp	#M_Imm,d5
	bne	ERROR_InvalidAddrMode
	br	ASM_STORE_INSTRUCTION_HEAD
.CFF62
	bset	#3,d6
	jsr	(asm_get_any_opp).l
	bsr	Parse_GetKomma
	cmp	#M_AxDec,d5
	bne	ERROR_InvalidAddrMode
	bra.b	.CFF48

Asm_ImmOpperantLong:
	moveq	#PB_020,d0
	bsr	Processor_warning
	move.b	d5,(OpperantSize-DT,a4)
	bsr	asm_4bytes_OpperantSize
	jsr	(asm_get_any_opp).l
	bsr	Parse_GetKomma
	and.b	#15,(OpperantSize-DT,a4)
	cmp	#M_Ax,d5
	beq	ERROR_InvalidAddrMode
	or.w	d1,d6
	jsr	(AddrOrDataReg).l
	tst	d5	; M_Dx
	bne	ERROR_Dataregexpect
	swap	d6
	clr.w	d6
	cmp.b	#$3A,(a6)
	bne.b	CFFE4
	addq.w	#1,a6
	move	d1,-(sp)
	jsr	(asm_get_any_opp).l
	tst	d5	; M_Dx
	bne	ERROR_Dataregexpect
	ror.w	#4,d1
	or.w	d1,d6
	move	(sp)+,d1
	or.w	d1,d6
CFFD2:
	moveq	#$7F,d5
	and.b	(OpperantSize-DT,a4),d5
	ror.w	#8,d5
	or.w	d5,d6
	br	ASM_STORE_LONG

CFFE4:
	and.b	#$FB,(OpperantSize-DT,a4)
	or.w	d1,d6
	ror.w	#4,d1
	or.w	d1,d6
	bra.b	CFFD2

Asm_ImmOpperantWord:
	move.b	d5,(OpperantSize-DT,a4)
	bsr	Asm_SkipInstructionHead
	jsr	(asm_get_any_opp).l
	bsr	Parse_GetKomma
	cmp	#M_Ax,d5
	beq	ERROR_InvalidAddrMode
	or.w	d1,d6
	jsr	(AddrOrDataReg).l
	tst	d5	; M_Dx
	bne	ERROR_Dataregexpect
	ror.w	#7,d1
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

asm_chk2cmp2_long_stuff:
	moveq	#PB_020,d0
	bsr	Processor_warning
	move.b	d5,(OpperantSize-DT,a4)
	bsr	asm_4bytes_OpperantSize
	jsr	(asm_get_any_opp).l
	tst	d5		; M_Dx?
	beq	ERROR_InvalidAddrMode
	and	#M_Ax|M_AxInc|M_AxDec|M_Imm,d5
	bne	ERROR_InvalidAddrMode
	or.w	d1,d6		; merge src mode/reg

	bsr	Parse_GetKomma

	jsr	AddrOrDataReg
	subq.w	#M_Ax,d5
	bhi	ERROR_Registerexpected
	swap	d6
	lsl.w	(sp)+		; chk2/cmp2 bit
	roxr.w	#4+1,d1		; merge dst reg and chk2/cmp2 bit11
	move	d1,d6
	br	ASM_STORE_LONG

C1006E:
	move.b	d5,(OpperantSize-DT,a4)
	bsr	Asm_SkipInstructionHead
	jsr	(asm_get_any_opp).l
	cmp	#M_Ax,d5
	beq	ERROR_InvalidAddrMode
	or.w	d1,d6
	bsr	Parse_GetKomma
	jsr	(AddrOrDataReg).l
	tst	d5	; M_Dx?
	bne	ERROR_Dataregexpect
	ror.w	#7,d1
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

C1009E:
	move.b	d5,(OpperantSize-DT,a4)
	bsr	Asm_SkipInstructionHead
	jsr	(asm_get_any_opp).l
	cmp	#M_Imm,d5
	bne	ERROR_InvalidAddrMode
	br	ASM_STORE_INSTRUCTION_HEAD

C100B8:	; cpusha/cinva
	moveq	#PB_040,d0
	bsr	Processor_warning
	bsr	Asm_SkipInstructionHead
	moveq	#0,d1
	IF	MC020
	move.w	(a6)+,d0
	ELSE
	move.b	(a6)+,d0
	lsl.w	#8,d0
	move.b	(a6)+,d0
	ENDIF
	and.w	d4,d0
	bsr.b	C1010E
	br	ASM_STORE_INSTRUCTION_HEAD

C100D8:	; cpushp|l/cinvp|l
	moveq	#PB_040,d0
	bsr	Processor_warning
	bsr	Asm_SkipInstructionHead
	moveq	#0,d1
	IF	MC020
	move.w	(a6)+,d0
	ELSE
	move.b	(a6)+,d0
	lsl.w	#8,d0
	move.b	(a6)+,d0
	ENDIF
	and.w	d4,d0
	bsr.b	C1010E
	bsr	Parse_GetKomma
	jsr	(asm_noimmediateopp).l
	cmp	#M_AxInd,d5
	bne	ERROR_InvalidAddrMode
	and.b	#7,d1
	or.b	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

C1010E:
	cmp	#'BC',d0
	beq.b	.C1012E
	cmp	#'DC',d0
	beq.b	.C10128
	cmp	#'IC',d0
	beq.b	.C10122
	cmp.w	#'NC',d0
	bne	ERROR_IllegalOperand
	rts
.C10122	or.w	#$0080,d6
	rts
.C10128	or.w	#$0040,d6
	rts
.C1012E	or.w	#$00C0,d6
	rts

Asm_Callm:
	move.w	#PB_020|PB_ONLY,d0
	bsr	Processor_warning
	bsr	Asm_SkipInstructionHead
	jsr	(asm_get_any_opp).l
	bsr	Parse_GetKomma
	cmp	#M_Imm,d5
	bne	ERROR_InvalidAddrMode
	bsr	asm_4bytes_OpperantSize
	jsr	(asm_get_any_opp).l
	tst	d5	; M_Dx?
	beq	ERROR_InvalidAddrMode
	and	#M_Ax|M_AxInc|M_AxDec|M_Imm,d5
	bne	ERROR_InvalidAddrMode
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

asm_BKPT_opp:
	move.b	d5,(OpperantSize-DT,a4)
	jsr	(asm_get_any_opp).l
	bsr	Asm_SkipInstructionHead
	cmp	#M_Imm,d5
	bne	ERROR_InvalidAddrMode
	cmp	#7,d3
	bgt.w	ERROR_out_of_range3bit
	or.w	d3,d6
	br	ASM_STORE_INSTRUCTION_HEAD

asm_LPSTOP_opp:
	moveq	#PB_060,d0
	bsr	Processor_warning
	move.b	d5,(OpperantSize-DT,a4)
	jsr	(asm_get_any_opp).l
	bsr	asm_4bytes_OpperantSize
	cmp	#M_Imm,d5
	bne	ERROR_InvalidAddrMode
	bsr	ASM_STORE_LONG
	cmp.l	#$ffff,d3
	bhi	ERROR_out_of_range16bit
	move.w	d3,d6
	bsr	Asm_SkipInstructionHead
	br	ASM_STORE_INSTRUCTION_HEAD

Asm_HandlePlpa:
	moveq	#PB_060,d0
	bsr	Processor_warning
	jsr	(asm_noimmediateopp).l
	bsr	Asm_SkipInstructionHead
	cmp.w	#M_AxInd,d5
	bne	ERROR_InvalidAddrMode
	subq.w	#8,d1
	or.w	d1,d6
	bra	ASM_STORE_INSTRUCTION_HEAD

;****************************************************

C10192:
	moveq	#PB_020,d0
	bsr	Processor_warning
	jsr	(asm_noimmediateopp).l
	tst	d5	; M_Dx?
	bne	ERROR_Dataregexpect
	move	d1,-(sp)
	move.b	(a6)+,d0
	cmp.b	#$3A,d0
	bne	ERROR_Colonexpected
	jsr	(asm_noimmediateopp).l
	tst	d5	; M_Dx?
	bne	ERROR_Dataregexpect
	move	d1,d3
	move	d3,-(sp)
	move.b	(a6)+,d0
	cmp.b	#$2C,d0
	bne	ERROR_Commaexpected
	jsr	(asm_noimmediateopp).l
	tst	d5	; M_Dx?
	bne	ERROR_Dataregexpect
	lsl.w	#6,d1
	move	(sp)+,d3
	or.w	(sp)+,d1
	move	d1,-(sp)
	move	d3,-(sp)
	move.b	(a6)+,d0
	cmp.b	#$3A,d0
	bne	ERROR_Colonexpected
	jsr	(asm_noimmediateopp).l
	tst	d5	; M_Dx?
	bne	ERROR_Dataregexpect
	lsl.w	#6,d1
	or.w	(sp)+,d1
	move	d1,-(sp)
	move.b	(a6)+,d0
	cmp.b	#$2C,d0
	bne	ERROR_Commaexpected
	jsr	(asm_noimmediateopp).l
	tst	d5	; M_Dx?
	beq	ERROR_InvalidAddrMode
	cmp	#M_AxInd,d5
	bne	ERROR_InvalidAddrMode
	cmp.b	#$30,d1
	bne.b	C10226
	move.b	d0,d1
	bset	#3,d1
C10226:
	and	#15,d1
	bchg	#3,d1
	ror.w	#4,d1
	move	(sp)+,d3
	or.w	(sp)+,d1
	move	d1,-(sp)
	move	d3,-(sp)
	move.b	(a6)+,d0
	cmp.b	#$3A,d0
	bne	ERROR_Colonexpected
	jsr	(asm_noimmediateopp).l
	tst	d5	; M_Dx?
	beq	ERROR_InvalidAddrMode
	cmp	#M_AxInd,d5
	bne	ERROR_InvalidAddrMode
	cmp.b	#$30,d1
	bne.b	C10262
	move.b	d0,d1
	bset	#3,d1
C10262:
	and	#15,d1
	bchg	#3,d1
	ror.w	#4,d1
	move	(sp)+,d3
	or.w	d1,d3
	move	(sp)+,d1
	bsr	Asm_SkipInstructionHead
	bsr	ASM_STORE_INSTRUCTION_HEAD
	bsr	Asm_SkipInstructionHead
	move	d1,d6
	bsr	ASM_STORE_INSTRUCTION_HEAD
	bsr	Asm_SkipInstructionHead
	move	d3,d6
	br	ASM_STORE_INSTRUCTION_HEAD

C1028E:
	moveq	#PB_020,d0
	bsr	Processor_warning
	bsr	asm_4bytes_OpperantSize
	jsr	(asm_noimmediateopp).l
	tst	d5	; M_Dx?
	bne	ERROR_Dataregexpect
	move	d1,-(sp)
	move.b	(a6)+,d0
	cmp.b	#$2C,d0
	bne	ERROR_Commaexpected
	jsr	(asm_noimmediateopp).l
	tst	d5	; M_Dx?
	bne	ERROR_Dataregexpect
	move	d1,d3
	move	(sp)+,d1
	lsl.w	#6,d3
	or.w	d3,d1
	move	d1,-(sp)
	move.b	(a6)+,d0
	cmp.b	#$2C,d0
	bne	ERROR_Commaexpected
	jsr	(asm_noimmediateopp).l
	tst	d5	; M_Dx?
	beq	ERROR_InvalidAddrMode
	and	#M_Ax|M_unused,d5
	bne	ERROR_InvalidAddrMode
	or.w	d1,d6
	swap	d6
	move	(sp)+,d1
	move.w	d1,d6
	br	ASM_STORE_LONG


Asm_Bitfieldopp_SrcOper:
	bsr.b	C10346
	cmp.b	#',',(a6)+
	bne	ERROR_Commaexpected
	jsr	(asm_noimmediateopp).l
	tst	d5		; M_Dx?
	bne	ERROR_Dataregexpect
	ror.w	#16-12,d1
	or.w	d1,d6		; set dst data reg
	br	ASM_STORE_LONG

Asm_Bitfieldopp_DstOper:
	jsr	(asm_noimmediateopp).l
	tst	d5		; M_Dx?
	bne	ERROR_Dataregexpect
	ror.w	#16-12,d1
	swap	d6
	or.w	d1,d6		; set src data reg (bfins)
	swap	d6
	cmp.b	#',',(a6)+
	bne	ERROR_Commaexpected

Asm_Bitfieldopp_OneOper:
	pea	(ASM_STORE_LONG,pc)

C10346:
	moveq	#PB_020,d0
	bsr	Processor_warning
	bsr	asm_4bytes_OpperantSize
	move.b	d5,(OpperantSize-DT,a4)
	jsr	(asm_noimmediateopp).l
	and	#M_Ax|M_AxInc|M_AxDec|M_unused,d5
	bne	ERROR_IllegalOperand
	or.w	d1,d6		; set addr. mode
	swap	d6		; switch to ext. word (bf specific)
	cmp.b	#'{',(a6)+
	bne	ERROR_Offsetwidthex
	moveq	#~32,d0
	and.b	(a6),d0
	cmp.b	#'D',d0
	beq.b	.C1038A
	bsr	Parse_GetExprValueInD3Voor
	cmp	#31,d3
	bls.b	.C10396
	bra.w	ERROR_OutofRange5bit

.C1038A
	addq.w	#1,a6
	moveq	#0,d3
	move.b	(a6)+,d3
	sub.b	#'0',d3
	cmp.b	#7,d3
	bhi.w	ERROR_IllegalOperand
	bset	#11-6,d3	; offset is in data reg
.C10396
	lsl.w	#6,d3
	or.w	d3,d6
	cmp.b	#':',(a6)+
	bne	ERROR_Offsetwidthex
	moveq	#~32,d0
	and.b	(a6),d0
	cmp.b	#'D',d0
	beq.b	.C103E0
	bsr	Parse_GetExprValueInD3Voor
	cmp	#32,d3
	bhi.w	ERROR_OutofRange5bit
	and.w	#31,d3		; allow both 0 and 32 as width 32
	bra.b	.C103EC

.C103E0	addq.w	#1,a6
	move.b	(a6)+,d3
	sub.b	#'0',d3
	cmp.b	#7,d3
	bhi.w	ERROR_IllegalOperand
	bset	#5,d3		; width is in data reg
.C103EC	cmp.b	#'}',(a6)+
	bne	ERROR_Missingbrace
	or.w	d3,d6
	rts


Asmbl_CmdMovea:
	bsr	Asm_SkipInstructionHead
	move.b	d5,(OpperantSize-DT,a4)
	st	(S_MemIndActEnc-DT,a4)
	jsr	(asm_get_any_opp).l
	tst.b	(S_MemIndActEnc-DT,a4)
	ble.b	C10418
	or.w	#1,d1
C10418:
	sf	(S_MemIndActEnc-DT,a4)
	move	d1,d6
	bsr	Parse_GetKomma
	cmp	#M_SrCcr,d5
	bhs.w	MAY_BE_FROM_SR_USP
	cmp	#M_Ax,d5
	bne.b	C10438
	cmp.w	#PB_APOLLO,(CPU_type-DT,a4)	;APOLLO support byte writes to Ax.
	beq.b	.ok
	tst.b	(OpperantSize-DT,a4)
	beq	ERROR_AddressRegByte
.ok
C10438:
	jsr	(asm_noimmediateopp).l
	cmp	#M_Ax,d5
	bne	ERROR_AddressRegExp
	cmp.w	#PB_APOLLO,(CPU_type-DT,a4)	;APOLLO support byte writes to Ax.
	beq.b	.ok
	tst.b	(OpperantSize-DT,a4)
	beq	ERROR_AddressRegByte
.ok
	ror.b	#3,d1
	lsl.w	#3,d1
	lsl.b	#2,d1
	add	d1,d1
	or.w	d1,d6
	move	#$1000,d1
	move.b	(OpperantSize-DT,a4),d0
	beq.b	C1046E
	add	d1,d1
	cmp.b	#$80,d0
	beq.b	C1046E
	move	#$3000,d1
C1046E:
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

Asmbl_CmdMove:
	bsr	Asm_SkipInstructionHead
	move.b	d5,(OpperantSize-DT,a4)
	st	(S_MemIndActEnc-DT,a4)
	jsr	(asm_get_any_opp).l
	sf	(S_MemIndActEnc-DT,a4)
	move	d1,d6
	bsr	Parse_GetKomma
	cmp	#M_SrCcr,d5
	bhs.b	MAY_BE_FROM_SR_USP
	cmp	#M_Ax,d5
	bne.b	.NotFromAn
	cmp.w	#PB_APOLLO,(CPU_type-DT,a4)	;APOLLO support byte writes to Ax.
	beq.b	.ok
	tst.b	(OpperantSize-DT,a4)
	beq	ERROR_AddressRegByte
.ok
.NotFromAn:
	jsr	(asm_noimmediateopp).l
	cmp	#M_Imm,d5
	bhs.w	MAY_BE_TO_SR_USP
	cmp	#M_Ax,d5
	bne.b	.NOT_TO_AN
	cmp.w	#PB_APOLLO,(CPU_type-DT,a4)	;APOLLO support byte writes to Ax.
	beq.b	.ok2
	tst.b	(OpperantSize-DT,a4)
	beq	ERROR_AddressRegByte
.ok2
.NOT_TO_AN:
	ror.b	#3,d1
	lsl.w	#3,d1
	lsl.b	#2,d1
	add	d1,d1
	or.w	d1,d6

	move	#$1000,d1
	move.b	(OpperantSize-DT,a4),d0
	beq.b	.SET_SIZE
	add	d1,d1
	cmp.b	#$80,d0
	beq.b	.SET_SIZE
	move	#$3000,d1
.SET_SIZE:
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

C1051C:
	or.w	d3,d6
	ror.w	#7,d1
	or.w	d1,d6
	br	Asm_InsertInstruction

MAY_BE_FROM_SR_USP:
	beq.b	.FromSR
	cmp	#M_Usp,d5
	bne	ERROR_InvalidAddrMode
	jsr	(AddrOrDataReg).l
	tst	d5	; M_Dx?
	beq	ERROR_AddressRegExp
	subq.w	#8,d1
	move	#$4E68,d6
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

.C10550	moveq	#PB_010,d0
	bsr	Processor_warning
	move	#$42C0,d6
	bra.b	.C10574

.FromSR	tst.b	(OpperantSize-DT,a4)
	ble.w	ERROR_IllegalSize
	cmp	#$003C,d1
	beq.b	.C10550
	move	#$40C0,d6
	add.b	d1,d1
	bpl.w	ERROR_InvalidAddrMode
.C10574
	jsr	(asm_noimmediateopp).l
	and	#M_Ax|M_Imm|M_PcDisp|M_PcIdx|M_SrCcr|M_Usp|M_Movem,d5
	bne	ERROR_InvalidAddrMode
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

MAY_BE_TO_SR_USP:
	moveq	#$38,d0
	and	d6,d0
	cmp.b	#8,d0
	bne.b	C105A4
	cmp	#M_Usp,d5
	bne	ERROR_InvalidAddrMode
	sub	d0,d6
	or.w	#$4E60,d6
	br	ASM_STORE_INSTRUCTION_HEAD

C105A4:
	cmp	#M_SrCcr,d5
	bne	ERROR_InvalidAddrMode
	tst.b	(OpperantSize-DT,a4)
	ble.w	ERROR_IllegalSize
	add.b	d1,d1
	bpl.b	C105C0
	or.w	#$46C0,d6
	br	ASM_STORE_INSTRUCTION_HEAD

C105C0:
	or.w	#$44C0,d6
	br	ASM_STORE_INSTRUCTION_HEAD

;************** handle error msg's ***************

ShowErrorMsg:
	move.l	a6,(ParsePos-DT,a4)

;	jsr	test_debug

	lea	(ERROR_AddressRegExp,pc),a0
	move.l	(sp)+,d0

	sub.l	a0,d0
	lsr.l	#1,d0
	lea	(Error_Msg_Table-DT,a4),a0
	add.l	d0,a0
	add	(a0),a0
C105DE:
	bclr	#SB2_INSERTINSOURCE,(SomeBits2-DT,a4)
	btst	#SB3_REPORT_ERROR,(SomeBits3-DT,a4)
	beq	ErrMsgNoDebug
	move.l	(Error_Jumpback-DT,a4),a1
	jmp	(a1)

asmbl_dbcc:
	move.w	#$0080,d5
	clr.w	-(sp)
; variants (a3 += 4, d0 = 3rd/4th char): DB?, DB??, DB?.S, DB??.S
	tst.b	d0		; variants 1
	beq.b	.nosize
	tst.w	-(a3)		; variants 2 (must re-read d0 bit15)
	bmi.b	.nosize
	cmp.b	#$40,d0		; variants 3
	beq.b	.even
	addq.l	#3,a3		; variants 4
.even	moveq	#$7f&$df,d0
	and.b	(a3),d0

	cmp.b	#'W',d0
	beq.b	.nosize
	cmp.w	#PB_APOLLO,(CPU_type-DT,a4)	;Only APOLLO supports dbcc.l
	bne.w	ERROR_IllegalAddres
	cmp.b	#'L',d0
	bne.w	ERROR_IllegalAddres
	addq.w	#1,(sp)

.nosize
	bsr	Asm_SkipInstructionHead
	jsr	(AddrOrDataReg).l
	tst	d5	; M_Dx?
	bne	ERROR_Dataregexpect
	or.w	d1,d6
	bsr	Parse_GetKomma
	jsr	(PARSE_GET_LABEL_16BIT)

	move.w	(sp)+,d0
	tst.w	d7
	bmi.b	.passone
	or.w	d0,(a0)
.passone
	br	ASM_STORE_INSTRUCTION_HEAD

asmbl_BraL:
	cmp.w	#$f000,d6	; top 4 bits = $f?
	bhs.b	C10664
	cmp	#PB_020,(CPU_type-DT,a4)
	bge.b	C1066A
	and	#$FF00,d6
	bset	#AF_BRATOLONG,d7
	moveq	#$20,d0
	and.b	-(a5),d0
	or.b	#'W',d0
	move.b	d0,(a5)+
	bset	#SB1_SOURCE_CHANGED,(SomeBits-DT,a4)
	lea	(BranchForcedt.MSG,pc),a0
	br	Druk_Af_Regel1

C10664:
	moveq	#PB_FPU,d0
	bsr	Processor_warning
C1066A:
	bsr	Asm_SkipInstructionHead
	bsr	Parse_GetExprValueInD3Voor

	tst.w	d7
	bmi.s	.passone
	cmp.w	(CurrentSection-DT,a4),d2	;label in andere section?
	bne	ERROR_RelativeModeEr
.passone:
	moveq	#0,d2
	sub.l	(Binary_Offset-DT,a4),d3
	jsr	(Store_DataLongReloc).l
	br	ASM_STORE_INSTRUCTION_HEAD

C10682:
	moveq	#PB_FPU,d0
	bsr	Processor_warning
	bra.b	C10690

asmbl_BraW:
	btst	#AF_OPTIMIZE,d7
	bne.b	C1069E
C10690:
	bsr	Asm_SkipInstructionHead
	jsr	(PARSE_GET_LABEL_16BIT)
	br	ASM_STORE_INSTRUCTION_HEAD

C1069E:
	tst	(MACRO_LEVEL-DT,a4)
	bne.b	C10690
	moveq	#$20,d0
	and.b	-(a5),d0
	or.b	#'B',d0
	move.b	d0,(a5)+

asmbl_BraB:
	bsr	Asm_SkipInstructionHead
	jsr	(PARSE_GET_LABEL_8BIT).l
	br	ASM_STORE_INSTRUCTION_HEAD

FORCE_BRAW:
	tst	(MACRO_LEVEL-DT,a4)
	bne	ERROR_BccBoutofrange
	bsr	ASM_STORE_INSTRUCTION_HEAD
	bset	#AF_BRATOLONG,d7
	moveq	#$20,d0
	and.b	-(a5),d0
	or.b	#'W',d0
	move.b	d0,(a5)+
	bset	#SB1_SOURCE_CHANGED,(SomeBits-DT,a4)
	lea	(BranchForcedt.MSG,pc),a0
	br	Druk_Af_Regel1

asmbl_BraNorm:	; bra/bsr/bcc without .size
	bsr	Asm_SkipInstructionHead
	btst	#AF_OPTIMIZE,d7
	bne.b	.C10718
	jsr	(PARSE_GET_LABEL_16BIT)
	br	ASM_STORE_INSTRUCTION_HEAD
.C10718
	move	(MACRO_LEVEL-DT,a4),d0
	add	(INCLUDE_LEVEL-DT,a4),d0
	bne.b	C10690
	move.l	(Cut_Blok_End-DT,a4),a3
	lea	(1,a3),a2
	addq.l	#3,a3
	addq.l	#2,(Cut_Blok_End-DT,a4)
	addq.l	#2,(sourceend-DT,a4)
	move.l	(LabelStart-DT,a4),d0
	cmp.l	(Cut_Blok_End-DT,a4),d0
	bls.b	.OutOfWorkspace
	move.l	a2,d0
	sub.l	a5,d0
	subq.l	#1,d0
.CopySource
	move.b	-(a2),-(a3)
	dbra	d0,.CopySource
	sub.l	#$00010000,d0
	bpl.b	.CopySource
	moveq	#$20,d1
	and.b	(-1,a5),d1
	move.b	#'.',(a5)+
	or.b	#'B',d1
	move.b	d1,(a5)+
	addq.w	#2,a6
	bsr	messages_get
	br	asmbl_BraB

.OutOfWorkspace
	subq.l	#2,(Cut_Blok_End-DT,a4)
	subq.l	#2,(sourceend-DT,a4)
	or.w	#(1<<AF_BRATOLONG)|(1<<AF_FINISHED),d7
	rts

Asm_CmdJmpJsrPea:
	bsr	Asm_SkipInstructionHead
	jsr	(asm_noimmediateopp).l
	and	#M_AxInd|M_AxDisp|M_AxIdx|M_AbsW|M_AbsL|M_PcDisp|M_PcIdx,d5
	beq	ERROR_InvalidAddrMode
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

Asm_ShiftRoll:
	bsr	Asm_SkipInstructionHead
	move.b	d5,(OpperantSize-DT,a4)
	jsr	(Parse_GetEASpecial).l
	tst	d5	; M_Dx?
	beq.b	C107CE
	cmp	#M_Imm,d5
	beq.b	C107E4
	bhi.w	ERROR_InvalidAddrMode
	cmp.w	#PB_APOLLO,(CPU_type-DT,a4)	;APOLLO support byte writes to Ax.
	beq.b	.ok
	cmp	#M_Ax,d5
	beq	ERROR_AddressRegByte
.ok
C107BC:
	tst.b	(OpperantSize-DT,a4)	; memory operand, must be .w
	ble.w	ERROR_IllegalSize
	and	#$FFC0,d6
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

C107CE:
	move	d1,-(sp)
	bsr	PARSE_GET_KOMMA_IF_ANY
	bne.b	C107DC
	or.w	#$0020,d6
	bra.b	C107EA

C107DC:
	move	(sp)+,d1
	move	#1,-(sp)
	bra.b	C107F4

C107E4:
	move	d1,-(sp)
	bsr	Parse_GetKomma
C107EA:
	jsr	(asm_noimmediateopp).l
	tst	d5	; M_Dx?
	bne.b	C1080E
C107F4:
	and	#$F138,d6
	or.w	d1,d6
	move	(sp)+,d1
	btst	#AF_UNDEFVALUE,d7
	bne.b	C10806
	ror.w	#7,d1
	or.w	d1,d6
C10806:
	or.b	(OpperantSize-DT,a4),d6
	br	ASM_STORE_INSTRUCTION_HEAD

C1080E:
	and	#M_AxInd|M_AxInc|M_AxDec|M_AxDisp|M_AxIdx|M_AbsW|M_AbsL,d5
	beq	ERROR_InvalidAddrMode
	btst	#5,d6
	bne	ERROR_InvalidAddrMode
	move	(sp)+,d0
	btst	#AF_UNDEFVALUE,d7
	bne.b	C107BC
	subq.w	#1,d0
	beq.b	C107BC
	bra	ERROR_IllegalOperand

C10830:
	jsr	(Parse_ImmediateValue).l
	btst	#AF_UNDEFVALUE,d7
	bne.b	C10846
	moveq	#15,d0
	cmp.l	d0,d3
	bhi.w	ERROR_out_of_range4bit
	or.w	d3,d6
C10846:
	br	Asm_InsertInstruction

Asm_LINK:
	move.b	d5,(OpperantSize-DT,a4)
	bsr	Asm_SkipInstructionHead
	jsr	(AddrOrDataReg).l
	tst	d5	; M_Dx?
	beq	ERROR_AddressRegExp
	subq.w	#8,d1
	or.w	d1,d6
	bsr	Parse_GetKomma
	jsr	(asm_get_any_opp).l
	cmp	#M_Imm,d5
	bne	ERROR_Immediateoper
	br	ASM_STORE_INSTRUCTION_HEAD

Asm_UNLK:
	jsr	(AddrOrDataReg).l
	tst	d5	; M_Dx?
	beq	ERROR_AddressRegExp
	subq.w	#8,d1
	or.w	d1,d6
	br	Asm_InsertInstruction

Asm_EXTB:
	moveq	#PB_020,d0
	bsr	Processor_warning
Asm_EXT:
	jsr	(AddrOrDataReg).l
	tst	d5	; M_Dx?
	bne	ERROR_Dataregexpect
	or.w	d1,d6
	br	Asm_InsertInstruction

Asm_SWAP:
	tst.b	d5	; only .w allowed
	ble.w	ERROR_IllegalSize
	jsr	(AddrOrDataReg).l
	tst	d5	; M_Dx?
	bne	ERROR_Dataregexpect
	or.w	d1,d6
	br	Asm_InsertInstruction

C108B6:
	clr.b	(OpperantSize-DT,a4)
	bsr	Asm_SkipInstructionHead
	jsr	(asm_get_any_opp).l
	cmp.w	#PB_APOLLO,(CPU_type-DT,a4)	;APOLLO support byte writes to Ax.
	beq.b	.ok
	cmp	#M_Ax,d5
	beq	ERROR_AddressRegByte
.ok
	cmp	#M_Imm,d5
	bcc.w	ERROR_InvalidAddrMode
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

ASSEM_CMDCLRNOTTST:
	bsr	Asm_SkipInstructionHead
	jsr	asm_noimmediateopp

	cmp.w	#PB_APOLLO,(CPU_type-DT,a4)	;APOLLO support a1 byte access
	beq.b	C1091E

	cmp	#M_Ax,d5
	bne.b	C10904
	move	d6,d0
	ror.w	#8,d0


	cmp.b	#$4A,d0
	bne	ERROR_InvalidAddrMode
	tst.b	d6
	beq	ERROR_IllegalAddres
	moveq	#PB_020,d0
	bsr	Processor_warning
	bra.b	C10926

C10904:
	cmp	#M_PcDisp,d5
	bne.b	C1091E
	move	d6,d0
	ror.w	#8,d0
	cmp.b	#$4A,d0
	bne	ERROR_InvalidAddrMode
	moveq	#PB_020,d0
	bsr	Processor_warning
	bra.b	C10926

C1091E:
	and	#M_Imm|M_SrCcr|M_Usp|M_Movem,d5
	bne	ERROR_InvalidAddrMode
C10926:
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD


	IF	INCLINK

;********************************
;*********** INCLINK ************ (code by deftronic)
;********************************
Asm_IncLink:
	lea	(SourceCode-DT,a4),a1
	bsr	ASSEM_RETURN_STRING_UCASE
	bclr	#AF_INC_ASSIGN,d7
	bsr.w	HandleIncFile
	bsr	GetDiskFileLengte
	movem.l	d0-d7/a0-a6,-(sp)
	moveq	#0,d1
	move.l	(4).w,a6
	jsr	(_LVOAllocMem,a6)
	move.l	d0,(buffer_ptr-DT,a4)
	bne.b	.memOk
	lea	(Notenoughmemo.MSG,pc),a0
	bra.w	Druk_Af_Regel1
.memOk
	movem.l	(sp)+,d0-d7/a0-a6
	tst.w	d7
	bmi.b	.pass1
	lea	(HInclink.MSG,pc),a0
	bsr.w	PRINTINCLUDENAME
.pass1:
	movem.l	d0/a6,-(sp)
	move.l	(buffer_ptr-DT,a4),d2
	move.l	d0,d3
	movem.l	d2/d3,-(sp)
	clr.l	(FileLength-DT,a4)
	bsr.w	OpenOldFile
	movem.l	(sp)+,d2/d3
	bsr.w	read_nr_d3_bytes
	bclr	#SB1_CLOSE_FILE,(SomeBits-DT,a4)
	move.l	(Bestand-DT,a4),d1
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOClose,a6)
	tst.w	d7
	bmi.b	.passs1
	lea	(FilelengthEOL.MSG,pc),a0
	bsr	Writefile_afwerken
.passs1:
	movem.l	(sp)+,d0/a6
	movem.l	d0-d7/a0-a6,-(sp)
	clr.l	(IncIFF_BODYbuffer2-DT,a4)
	move.l	(buffer_ptr-DT,a4),a0
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),d0
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),d0
	btst	#0,d0
	bne.w	ERROR_WordatOddAddress
	move.l	d0,a1
	move.l	d0,a2
	cmp.l	#$000003F3,(a0)		; header
	beq.b	.linkerError
	cmp.l	#$000003E7,(a0)+	; unit
	bne.b	.linkerError
	move.l	(a0)+,d0
	lsl.l	#2,d0
	add.l	d0,a0
.inclink1:
	cmp.l	#$000003E8,(a0)		; name
	bne.b	.inclink2
	addq.w	#4,a0
	move.l	(a0)+,d0
	lsl.l	#2,d0
	add.l	d0,a0
.inclink2:
	cmp.l	#$000003E9,(a0)		; code
	bne.b	.inclink4
	addq.w	#4,a0
	move.l	(a0)+,d0
	beq.b	.inclink4
	move.l	d0,(IncIFF_BODYbuffer2-DT,a4)
	tst.w	d7
	bpl.b	.inclink3
	lsl.l	#2,d0
	add.l	d0,a0
	bra.b	.inclink4

.inclink3:
	move.l	(a0)+,(a1)+
	subq.l	#1,d0
	bne.b	.inclink3
.inclink4:
	cmp.l	#$000003EC,(a0)		; reloc32
	bne.b	.inclink8
	addq.w	#4,a0
	move.l	(a0)+,d0
	beq.b	.linkerError
	tst.l	(a0)+
	bne.b	.linkerError
	tst.w	d7
	bpl.b	.inclink5
	lsl.l	#2,d0
	add.l	d0,a0
	bra.b	.inclink7

.linkerError:
	lea	(.LinkerError.MSG,pc),a0
	bra.w	Druk_Af_Regel1

.inclink5:
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),d2
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),d2
.inclink6:
	move.l	(a0)+,d1
	add.l	d2,(a2,d1.l)
	move.l	(RelocStart-DT,a4),a3
	cmp.l	(CodeStart-DT,a4),a3
	bcc.w	ERROR_WorkspaceMemoryFull
	move.b	(CurrentSection+1-DT,a4),(a3)+
	beq.w	ERROR_ReservedWord
	move.b	(CurrentSection+1-DT,a4),(a3)+
	add.l	(INSTRUCTION_ORG_PTR-DT,a4),d1
	move.l	d1,(a3)+
	move.l	a3,(RelocStart-DT,a4)
	subq.l	#1,d0
	bne.b	.inclink6
.inclink7:
	tst.l	(a0)+
	bne.b	.linkerError
.inclink8:
	cmp.l	#$000003EF,(a0)		; ext
	bne.w	.inclink27
	addq.w	#4,a0
.inclink9:
	move.l	(a0)+,d0
	beq.w	.inclink28
	move.l	d0,d1
	rol.l	#8,d1
	and.l	#$00FFFFFF,d0
	lea	(CurrentAsmLine-DT,a4),a3
.inclink10:
	move.l	(a0)+,(a3)+
	subq.l	#1,d0
	bne.b	.inclink10
	clr.b	(a3)
	lea	(CurrentAsmLine-DT,a4),a3
	IF Debugstuff
	movem.l	d0-d4,-(sp)
	movem.l	(a3),d0-d4
	movem.l	d0-d4,(.inclinkData)
	movem.l	(sp)+,d0-d4
	ENDIF
	cmp.b	#$84,d1			; ext_ref8
	beq.w	.inclink18
	cmp.b	#$83,d1			; ext_ref16
	beq.b	.inclink15
	cmp.b	#$81,d1			; ext_ref32
	bne.w	.inclink22
	tst.w	d7
	bmi.b	.inclink14
	bsr.b	.evalexpr
	move.l	(a0)+,d0
	beq.w	.linkerError
	lsl.w	#2,d2
	lea	(SECTION_ABS_LOCATION-DT,a4),a3
	add.l	(a3,d2.w),d3
	lsr.w	#2,d2
.inclink12:
	move.l	(a0)+,d1
	add.l	d3,(a2,d1.l)
	tst.w	d2
	beq.b	.inclink13
	move.l	(RelocStart-DT,a4),a3
	cmp.l	(CodeStart-DT,a4),a3
	bcc.w	ERROR_WorkspaceMemoryFull
	move.b	(CurrentSection+1-DT,a4),(a3)+
	beq.w	ERROR_ReservedWord
	move.b	d2,(a3)+
	add.l	(INSTRUCTION_ORG_PTR-DT,a4),d1
	move.l	d1,(a3)+
	move.l	a3,(RelocStart-DT,a4)
.inclink13:
	subq.l	#1,d0
	bne.b	.inclink12
	bra.b	.inclink9

.inclink14:
	move.l	(a0)+,d0
	lsl.l	#2,d0
	add.l	d0,a0
	bra.w	.inclink9

.evalexpr:
	moveq	#(CurrentAsmLine-SourceCode)/4-1,d1
.copy	move.l	(a3)+,(SourceCode-CurrentAsmLine-4,a3)	; -4 counters postinc
	dbf	d1,.copy
	movem.l	a0-a3/a6,-(sp)
	lea	(SourceCode-DT,a4),a6
	bsr.w	Parse_GetExprValueInD3Voor
	movem.l	(sp)+,a0-a3/a6
	tst.w	d2
	rts

.inclink15:
	tst.w	d7
	bmi.b	.inclink14
	bsr.b	.evalexpr
	bne.w	ERROR_ReservedWord
	move.l	(a0)+,d0
	beq.w	.linkerError
.inclink17:
	move.l	(a0)+,d1
	add.w	d3,(a2,d1.l)
	subq.l	#1,d0
	bne.b	.inclink17
	bra.w	.inclink9

.inclink18:
	tst.w	d7
	bmi.b	.inclink14
	bsr.b	.evalexpr
	bne.w	ERROR_ReservedWord
	move.l	(a0)+,d0
	beq.w	.linkerError
.inclink20:
	move.l	(a0)+,d1
	add.b	d3,(a2,d1.l)
	subq.l	#1,d0
	bne.b	.inclink20
	bra.w	.inclink9

.inclink22:
	tst.b	(a3)+
	bne.b	.inclink22
	cmp.b	#2,d1
	bne.b	.inclink23
	move.b	#'=',(-1,a3)
	bra.b	.inclink24

.inclink23:
	cmp.b	#1,d1
	bne.w	.linkerError
	move.b	#'=',(-1,a3)
	move.b	#'*',(a3)+
	move.b	#'+',(a3)+
.inclink24:
	move.b	#'$',(a3)+
	move.l	(a0)+,d0
	moveq	#7,d2
.inclink25:
	rol.l	#4,d0
	moveq	#15,d1
	and.b	d0,d1
	cmp.b	#10,d1
	bcs.b	.inclink26
	addq.b	#7,d1
.inclink26:
	add.b	#'0',d1
	move.b	d1,(a3)+
	dbra	d2,.inclink25
	clr.b	(a3)+
	moveq	#SRCMARK_END,d0
	move.b	d0,(a3)+
	move.b	d0,(a3)
	movem.l	d0-d7/a0-a6,(BASEREG_BASE-DT,a4)
	movem.l	(sp),d0-d7/a0-a6
	lea	(CurrentAsmLine-DT,a4),a6
	jsr	(FAST_TRANSLATE_LINE).l
	movem.l	(BASEREG_BASE-DT,a4),d0-d7/a0-a6
	bra.w	.inclink9

.inclink27:
	cmp.l	#$000003F2,(a0)		; end
	beq.w	.inclink1
.inclink28:
	move.l	(IncIFF_BODYbuffer2-DT,a4),d0
	lsl.l	#2,d0
	add.l	d0,(INSTRUCTION_ORG_PTR-DT,a4)

	move.l	(buffer_ptr-DT,a4),d0
	beq.b	.nofileptr
	move.l	d0,a1
	move.l	(ParameterBlok+fib_Size-DT,a4),d0
	move.l	(4).w,a6
	jsr	(_LVOFreeMem,a6)
	clr.l	(buffer_ptr-DT,a4)
.nofileptr
	movem.l	(sp)+,d0-d7/a0-a6
.inclink29:
	tst.b	(a6)+
	bne.b	.inclink29
	subq.w	#1,a6
	rts

.LinkerError.MSG:	dc.b	'Linker Error, only 1 section allowed!',0
.UndefLabel.MSG:	dc.b	' Undefined Label: '
	EVEN
	IF Debugstuff
.inclinkData:	DCB.L	5,0
	ENDIF

	ENDIF	; inclink

;************************
;*   Get komma if any   *
;************************

; -1 no comma
; 0 a comma

PARSE_GET_KOMMA_IF_ANY:
	moveq	#0,d0
	move.b	(a6)+,d0
	cmp.b	#',',d0
	bne.b	C10944
C10936:
	move.b	(a6)+,d0
	tst.b	(Variable_base-DT,a4,d0.w)
	bmi.b	C10936
	subq.w	#1,a6
	moveq	#0,d1
	rts

C10944:
	tst.b	(Variable_base-DT,a4,d0.w)
	bmi.b	C10950
	subq.w	#1,a6
	moveq	#-1,d1
	rts

C10950:
	move.b	(a6)+,d0
	tst.b	(Variable_base-DT,a4,d0.w)
	bmi.b	C10950
	cmp.b	#',',d0
	bne.b	C10962
	br	ERROR_NOoperandspac

C10962:
	subq.w	#2,a6
	moveq	#-1,d1
	rts

ASSEM_RETURN_LABEL_STRING:
	lea	(SourceCode-DT,a4),a1
	bsr.b	ASSEM_RETURN_STRING
	beq	ERROR_Stringexpected
	move.l	a1,d1
	bclr	#0,d1
	move.l	d1,a1
	or.w	#$8000,-(a1)
	rts

; These check&remove quotes, and convert case if needed.
ASSEM_RETURN_STRING:
	btst	#0,(PR_Upper_LowerCase)
	bne.b	ASSEM_RETURN_STRING_UCASE
ASSEM_RETURN_STRING_MIXCASE:
	moveq	#0,d3
	bra.b	C10990

Asm_INCDIR:
	lea	(INCLUDE_DIRECTORY-DT,a4),a1

ASSEM_RETURN_STRING_UCASE:
	moveq	#'a'-'A',d3
C10990:
	move.l	a1,-(sp)
	move.b	(a6)+,d0
	cmp.b	#$22,d0		;'"'
	beq.b	.C109AE
	cmp.b	#$60,d0		;'`'
	beq.b	.C109AE
	cmp.b	#$27,d0		;"'"
	beq.b	.C109AE
	subq.w	#1,a6
	moveq	#$2C,d1		;','
	moveq	#$20,d2		;' '
	bra.b	.C109B6

.C109AE
	moveq	#0,d2
	move.b	d0,d1		; remember quote char
	bra.b	.C109B6

.C109B4
	move.b	d0,(a1)+
.C109B6
	move.b	(a6)+,d0
	cmp.b	#'a',d0
	blo.b	.C109C6
	cmp.b	#'z',d0
	bhi.b	.C109C6
	sub.b	d3,d0
.C109C6
	cmp.b	d1,d0		; end quote or separator?
	beq.b	.C109D4
	cmp.b	d2,d0
	bhi.b	.C109B4
	tst.b	d2
	beq	ERROR_MissingQuote
.C109D4
	tst.b	d2
	beq.b	.C109DA
	subq.w	#1,a6
.C109DA
	cmp.l	(sp)+,a1
	beq.b	.C109E4
	clr.b	(a1)+
	moveq	#NS_ALABEL,d1
	rts
.C109E4
	clr.b	(a1)+
	moveq	#0,d1
	rts

Convert_A2I_sub:	; CONVERTSTRINGTONUMBER_ANYINV
	bsr.w	RemoveWS
	beq.b	C10A3A		;einde string
	subq.w	#1,a6
	bsr	Parse_GetExprValueInD3Voor
Convert_A2I_MkAbs:
	btst	#AF_UNDEFVALUE,d7
	bne	ERROR_UndefSymbol
	tst	d2
	beq.b	C10A0E
	lea	(SECTION_ABS_LOCATION-DT,a4),a0
	IF MC020
	add.l	(a0,d2.w*4),d3
	ELSE
	lsl.w	#2,d2
	add.l	(a0,d2.w),d3
	ENDC
C10A0E:
	moveq	#NS_AVALUE,d1
	rts

C10A12:
	bsr.w	RemoveWS
	beq.b	C10A3A
	subq.w	#1,a6
	bsr	Asm_ImmediateOppFloat
	btst	#AF_UNDEFVALUE,d7
	bne	ERROR_UndefSymbol
	tst	d2
	beq.b	C10A36
	lea	(SECTION_ABS_LOCATION-DT,a4),a0

	IF MC020
	add.l	(a0,d2.w*4),d3
	ELSE
	lsl.w	#2,d2
	add.l	(a0,d2.w),d3
	ENDC
C10A36:
	moveq	#NS_AVALUE,d1
	rts
C10A3A:
	moveq	#1,d3
	moveq	#0,d1
	rts

Convert_A2I:	; CONVERTSTRINGTONUMBER
	movem.l	d2-d7/a0-a3/a5/a6,-(sp)
	bsr.b	Convert_A2I_sub
	tst.b	d0
	bne	ERROR_IllegalOperand
	move.l	d3,d0
	movem.l	(sp)+,d2-d7/a0-a3/a5/a6
	tst.b	d1
	rts

Convert_A2F:
	movem.l	d2-d7/a0-a3/a5/a6,-(sp)
	fmovem.x	fp1-fp7,-(sp)
	bsr.b	C10A12
	fmovem.x	(sp)+,fp1-fp7
	movem.l	(sp)+,d2-d7/a0-a3/a5/a6
	tst.b	d1
	rts

PARSE_START_VALUE_IN_D3_UNKNOWN:
	bclr	#AF_UNDEFVALUE,d7
	clr	(Math_Level-DT,a4)
	pea	(Parse_GetAnyMathOpp,pc)
	br	Parse_VauleStillUnknown

PARSE_START_VALUE_IN_D3_KNOWN:
	bclr	#AF_UNDEFVALUE,d7
	clr	(Math_Level-DT,a4)
	pea	(Parse_GetAnyMathOpp,pc)
	br	PARSE_FIRST_A_LABEL_KNOWN

PARSE_START_VALUE_IN_D3:
	bclr	#AF_UNDEFVALUE,d7
	clr	(Math_Level-DT,a4)
	pea	(Parse_GetAnyMathOpp,pc)
	bra.b	C10AAC

;*************************


Parse_GetExprValueInD3Voor:
	bclr	#AF_UNDEFVALUE,d7
C10A9E:	clr	(Math_Level-DT,a4)
C10AA2:	pea	(Parse_GetAnyMathOpp,pc)
C10AA6:	jsr	(NEXTSYMBOL)
C10AAC:	add.b	d1,d1
	and.w	#$00ff,d1
	add	(.Fast,pc,d1.w),d1
	jmp	(.Fast,pc,d1.w)

.Fast:
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	C10D48		;'('
	dr.w	GetExpr_Error
	dr.w	C10D0A		;'*'
	dr.w	C10AA6		;'+'
	dr.w	GetExpr_Error
	dr.w	C10D16		;'-'
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	C10D32		;'['
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	Parse_FirstAValue	; a value
	dr.w	Parse_FirstALabel	; a label
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	GetExpr_Error
	dr.w	Parse_NotExpr		;'~'
	dr.w	GetExpr_Error

GetExpr_Error:
	br	ERROR_IllegalOperand

PARSE_START_LABEL_VALUE_IN_D3_MOVEM:
	move.l	(LabelStart-DT,a4),a0
	cmp.b	#$7F,-(a0)
	bne	ERROR_UndefSymbol
	bclr	#AF_UNDEFVALUE,d7
	clr	(Math_Level-DT,a4)
	pea	(Parse_GetAnyMathOpp,pc)
	jsr	(Parse_FindLabel).l
	beq	Parse_VauleStillUnknown
	tst	d2
	bpl.b	Parse_FirstAValue
	cmp	#LB_REG,d2
	bne.b	.MayBeMovem
	move.l	d3,d1
	move	#M_Movem,d5
	addq.w	#8,sp
	rts

.MayBeMovem:
	cmp	#LB_EQUR,d2
	bne.b	Parse_VoorLabelSpecial
	move	d3,d5
	swap	d3
	move	d3,d1
	addq.w	#8,sp
	jmp	(PARSE_MOVEM_REGISTERS).l

PARSE_START_LABEL_VALUE_IN_D3_AN_DN:
	move.l	(LabelStart-DT,a4),a0
	cmp.b	#$7F,-(a0)
	bne	ERROR_UndefSymbol
	bclr	#AF_UNDEFVALUE,d7
	clr	(Math_Level-DT,a4)
	pea	(Parse_GetAnyMathOpp,pc)
	jsr	(Parse_FindLabel).l
	beq	Parse_VauleStillUnknown
	tst	d2
	bpl.b	Parse_FirstAValue
	cmp	#LB_EQUR,d2
	bne.b	Parse_VoorLabelSpecial
	move	d3,d5
	swap	d3
	move	d3,d1
	addq.w	#8,sp
	rts

Parse_FirstALabel:
	move.l	(LabelStart-DT,a4),a0
	cmp.b	#$7F,-(a0)
	bne.b	Parse_VauleStillUnknown
	jsr	(Parse_FindLabel).l
	beq.b	Parse_VauleStillUnknown
PARSE_FIRST_A_LABEL_KNOWN:
	tst	d2		; LB_CONSTANT?
	bmi.b	Parse_VoorLabelSpecial

Parse_FirstAValue:
	bclr	#LB_PASS2BIT,d2
	rts

Parse_VoorLabelSpecial:
	swap	d2
	and.b	#$3F,d2
	subq.b	#1,d2		; LB_SET?
	beq.b	C10CB4
	subq.b	#1,d2		; LB_XREF?
	beq.b	C10CA4
	subq.b	#1,d2		; LB_EQUR?
	bne	ERROR_NOTaconstantl
	btst	#SB2_MATH_XN_OK,(SomeBits2-DT,a4)
	beq	ERROR_NOTaconstantl
	bset	#SB2_A_XN_USED,(SomeBits2-DT,a4)
	swap	d3
	cmp	#15,d3
	bne.b	C10C8E
	btst	#13-8,(statusreg_base-DT,a4)	; sv flag
	bne.b	C10C8E
	addq.w	#1,d3
C10C8E:
	add	d3,d3
	add	d3,d3
	lea	(DataRegsStore-DT,a4),a1
	add	d3,a1
	move.l	(a1),d3
	move.b	#1,(OpperantSize-DT,a4)
	moveq	#0,d2
	rts

C10CA4:
	move.l	a2,d0
	moveq	#-4,d1
	and.l	d1,d0
	move.l	d0,(LabelXrefName-DT,a4)
	move	#$8000,d2
	bra.b	Parse_FirstAValue

C10CB4:
	swap	d2
	and	#$00FF,d2
	rts

Parse_VauleStillUnknown:
	tst	d7	;passone
	bpl.b	.p2
	bset	#AF_UNDEFVALUE,d7
	moveq	#0,d3
	moveq	#0,d2
	rts

.p2	btst	#SB2_MATH_XN_OK,(SomeBits2-DT,a4)
	beq	ERROR_UndefSymbol
	lea	(SourceCode+2-DT,a4),a3
	move	#$8000,d0
	cmp	(a3),d0
	bne.b	C10CE8
	or.w	d0,-(a3)
C10CE8:
	bsr	LINE_TEXT_FINDREG_NAME
	bset	#SB2_A_XN_USED,(SomeBits2-DT,a4)
	moveq	#0,d3
	subq.b	#2,(OpperantSize-DT,a4)
	beq.b	C10CFE
	move	(a1)+,d3
	swap	d3
C10CFE:
	move	(a1),d3
	move.b	#1,(OpperantSize-DT,a4)
	moveq	#0,d2
	rts

C10D0A:
	move	(CurrentSection-DT,a4),d2
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),d3
	rts

C10D16:
	bsr	C10AA6
C10D1A:
	tst	d2
	bne	ERROR_RelativeModeEr
	neg.l	d3
	rts

Parse_NotExpr:
	bsr	C10AA6
	tst	d2
	bne	ERROR_RelativeModeEr
	not.l	d3
	rts

C10D32:
	move	(Math_Level-DT,a4),-(sp)
	bsr	C10A9E
	cmp.b	#']',(a6)+
	bne	ERROR_Rightparenthe
	move	(sp)+,(Math_Level-DT,a4)
	rts

C10D48:
	move	(Math_Level-DT,a4),-(sp)
	bsr	C10A9E
	cmp.b	#')',(a6)+
	bne	ERROR_Rightparenthe
	move	(sp)+,(Math_Level-DT,a4)
	rts

Parse_GetAnyMathOpp:
	moveq	#0,d0
	move.b	(a6)+,d0
	move	d0,d1
	add.b	d1,d1
	add	(W10D6E,pc,d1.w),d1
	jmp	(W10D6E,pc,d1.w)

W10D6E:
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10FFA		; ! or
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10FD0		; & and
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10F3E		; * mul
	dr.w	C10EA8		; + add
	dr.w	C10E6E
	dr.w	C10E7A		; - sub
	dr.w	C10E6E
	dr.w	C10F7C		; / div/mod
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C11102		; < lesser/lshift/...
	dr.w	C11062		; = equal
	dr.w	C1113E		; > greater/rshift/...
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10ED6		; ^ power
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10FFA
	dr.w	C10E6E
	dr.w	C11024		; ~ eor
	dr.w	C10E6E

C10E6E:
	subq.w	#1,a6
	lea	(C10E76,pc),a3
	rts

C10E76:
	move.b	(a6),d0
	rts

C10E7A:
	cmp	#MATH_ADDSUB,(Math_Level-DT,a4)
	bhs.b	C10EA2
	move	(Math_Level-DT,a4),-(sp)
	move	#MATH_ADDSUB,(Math_Level-DT,a4)
	bsr	PARSE_GET_NEXT_VALUE
	sub.l	d5,d3
	lsr.w	#1,d0
	bcc.b	C10E9C
	beq	ERROR_RelativeModeEr
	moveq	#0,d2
C10E9C:
	move	(sp)+,(Math_Level-DT,a4)
	jmp	(a3)

C10EA2:
	lea	(C10E7A,pc),a3
	rts

C10EA8:
	cmp	#MATH_ADDSUB,(Math_Level-DT,a4)
	bhs.b	C10ED0
	move	(Math_Level-DT,a4),-(sp)
	move	#MATH_ADDSUB,(Math_Level-DT,a4)
	bsr	PARSE_GET_NEXT_VALUE
	add.l	d5,d3
	lsr.w	#1,d0
	bcc.b	C10ECA
	bne	ERROR_RelativeModeEr
	move	d4,d2
C10ECA:
	move	(sp)+,(Math_Level-DT,a4)
	jmp	(a3)

C10ED0:
	lea	(C10EA8,pc),a3
	rts

C10ED6:
	cmp	#MATH_SHIFTPOT,(Math_Level-DT,a4)
	bhs.b	C10EFA
	move	(Math_Level-DT,a4),-(sp)
	move	#MATH_SHIFTPOT,(Math_Level-DT,a4)
	bsr	PARSE_GET_NEXT_VALUE
	tst	d0
	bne	ERROR_RelativeModeEr
	bsr.b	C10F00
	move	(sp)+,(Math_Level-DT,a4)
	jmp	(a3)

C10EFA:
	lea	(C10ED6,pc),a3
	rts

C10F00:
	tst.l	d5
	bne.b	C10F08
	moveq	#1,d3
	rts

C10F08:
	lsr.l	#1,d5
	bcc.b	C10F2A
	move.l	d3,-(sp)
	bsr.b	C10F2A
	move.l	(sp)+,d5
	move	d5,d4
	mulu	d3,d4
	move	d5,d0
	swap	d5
	muls	d3,d5
	swap	d3
	muls	d0,d3
	add.l	d5,d3
	swap	d3
	clr	d3
	add.l	d4,d3
	rts

C10F2A:
	bsr.b	C10F00
	move	d3,d0
	swap	d3
	muls	d0,d3
	add.l	d3,d3
	swap	d3
	clr	d3
	mulu	d0,d0
	add.l	d0,d3
	rts

C10F3E:
	cmp	#MATH_MULDIV,(Math_Level-DT,a4)
	bhs.b	C10F76
	move	(Math_Level-DT,a4),-(sp)
	move	#MATH_MULDIV,(Math_Level-DT,a4)
	bsr	PARSE_GET_NEXT_VALUE
	tst	d0
	bne	ERROR_RelativeModeEr
	move	d5,d4
	mulu	d3,d4
	move	d5,d0
	swap	d5
	muls	d3,d5
	swap	d3
	muls	d0,d3
	add.l	d5,d3
	swap	d3
	clr	d3
	add.l	d4,d3
	move	(sp)+,(Math_Level-DT,a4)
	jmp	(a3)

C10F76:
	lea	(C10F3E,pc),a3
	rts

Parse_Modulo:
	addq.l	#1,a6
.DoIt	cmp.w	#MATH_MULDIV,(Math_Level-DT,a4)
	bhs.b	.NotYet
	bset	#AF_MODULO,d7
	bra.b	Parse_Division\.ModEntry
.NotYet	lea	(.DoIt,pc),a3
	rts

C10F7C:
	cmp.b	(a6),d0		; //
	beq.b	Parse_Modulo
Parse_Division:
	cmp	#MATH_MULDIV,(Math_Level-DT,a4)
	bhs.b	.NotYet
	bclr	#AF_MODULO,d7
.ModEntry
	move	(Math_Level-DT,a4),-(sp)
	move	#MATH_MULDIV,(Math_Level-DT,a4)
	bsr	PARSE_GET_NEXT_VALUE
	tst	d0
	bne	ERROR_RelativeModeEr
	moveq	#0,d4
	tst.l	d3
	bpl.b	.Pos1
	neg.l	d3
	addq.b	#1,d4
.Pos1	tst.l	d5
	bpl.b	.Pos2
	neg.l	d5
	addq.b	#1,d4
.Pos2
	moveq	#32,d1		; long division algorithm, binary version
	moveq	#0,d0
.Loop	sub.l	d5,d0
	bcc.b	.Skip
	add.l	d5,d0
.Skip	addx.l	d3,d3
	addx.l	d0,d0
	dbra	d1,.Loop
	not.l	d3
	btst	#AF_MODULO,d7
	beq.b	.Div
	move.l	d0,d3
	lsr.l	#1,d3
.Div	lsr.w	#1,d4
	bcc.b	.IsPos
	neg.l	d3
.IsPos	move	(sp)+,(Math_Level-DT,a4)
	jmp	(a3)

.NotYet	lea	(Parse_Division,pc),a3
	rts

C10FD0:
	cmp	#MATH_ANDOREOR,(Math_Level-DT,a4)
	bhs.b	C10FF4
	move	(Math_Level-DT,a4),-(sp)
	move	#MATH_ANDOREOR,(Math_Level-DT,a4)
	bsr	PARSE_GET_NEXT_VALUE
	tst	d0
	bne	ERROR_RelativeModeEr
	and.l	d5,d3
	move	(sp)+,(Math_Level-DT,a4)
	jmp	(a3)

C10FF4:
	lea	(C10FD0,pc),a3
	rts

C10FFA:
	cmp	#MATH_ANDOREOR,(Math_Level-DT,a4)
	bhs.b	C1101E
	move	(Math_Level-DT,a4),-(sp)
	move	#MATH_ANDOREOR,(Math_Level-DT,a4)
	bsr	PARSE_GET_NEXT_VALUE
	tst	d0
	bne	ERROR_RelativeModeEr
	or.l	d5,d3
	move	(sp)+,(Math_Level-DT,a4)
	jmp	(a3)

C1101E:
	lea	(C10FFA,pc),a3
	rts

C11024:
	cmp	#MATH_ANDOREOR,(Math_Level-DT,a4)
	bhs.b	C11048
	move	(Math_Level-DT,a4),-(sp)
	move	#MATH_ANDOREOR,(Math_Level-DT,a4)
	bsr	PARSE_GET_NEXT_VALUE
	tst	d0
	bne	ERROR_RelativeModeEr
	eor.l	d5,d3
	move	(sp)+,(Math_Level-DT,a4)
	jmp	(a3)

C11048:
	lea	(C11024,pc),a3
	rts

C1104E:
	bsr	PARSE_GET_NEXT_VALUE
	tst	d0
	beq.b	C1105E
	subq.w	#3,d0
	bne	ERROR_RelativeModeEr
	moveq	#0,d2
C1105E:
	cmp.l	d5,d3
	rts

C11062:
	cmp	#MATH_COMPARE,(Math_Level-DT,a4)
	bhs.b	C11082
	move	(Math_Level-DT,a4),-(sp)
	move	#MATH_COMPARE,(Math_Level-DT,a4)
	bsr.b	C1104E
	seq	d3
	ext.w	d3
	ext.l	d3
	move	(sp)+,(Math_Level-DT,a4)
	jmp	(a3)

C11082:
	lea	(C11062,pc),a3
	rts

C11088:
	addq.w	#1,a6
C1108A:
	cmp	#MATH_COMPARE,(Math_Level-DT,a4)
	bhs.b	C110AA
	move	(Math_Level-DT,a4),-(sp)
	move	#MATH_COMPARE,(Math_Level-DT,a4)
	bsr.b	C1104E
	sne	d3
	ext.w	d3
	ext.l	d3
	move	(sp)+,(Math_Level-DT,a4)
	jmp	(a3)

C110AA:
	lea	(C1108A,pc),a3
	rts

C110B0:
	addq.w	#1,a6
C110B2:
	cmp	#MATH_COMPARE,(Math_Level-DT,a4)
	bhs.b	C110D2
	move	(Math_Level-DT,a4),-(sp)
	move	#MATH_COMPARE,(Math_Level-DT,a4)
	bsr.b	C1104E
	sle	d3
	ext.w	d3
	ext.l	d3
	move	(sp)+,(Math_Level-DT,a4)
	jmp	(a3)

C110D2:
	lea	(C110B2,pc),a3
	rts

C110D8:
	addq.w	#1,a6
C110DA:
	cmp	#MATH_COMPARE,(Math_Level-DT,a4)
	bhs.b	C110FC
	move	(Math_Level-DT,a4),-(sp)
	move	#MATH_COMPARE,(Math_Level-DT,a4)
	bsr	C1104E
	sge	d3
	ext.w	d3
	ext.l	d3
	move	(sp)+,(Math_Level-DT,a4)
	jmp	(a3)

C110FC:
	lea	(C110DA,pc),a3
	rts

C11102:
	cmp.b	(a6),d0		; <<
	beq.b	C11170
	move.b	(a6),d0
	cmp.b	#'>',d0		; <>
	beq	C11088
	cmp.b	#'=',d0		; <=
	beq.b	C110B0
C11116:
	cmp	#MATH_COMPARE,(Math_Level-DT,a4)
	bhs.b	C11138
	move	(Math_Level-DT,a4),-(sp)
	move	#MATH_COMPARE,(Math_Level-DT,a4)
	bsr	C1104E
	slt	d3
	ext.w	d3
	ext.l	d3
	move	(sp)+,(Math_Level-DT,a4)
	jmp	(a3)

C11138:
	lea	(C11116,pc),a3
	rts

C1113E:
	cmp.b	(a6),d0		; >>
	beq.b	C1119A
	cmp.b	#'=',(a6)	; >=
	beq.b	C110D8
C11148:
	cmp	#MATH_COMPARE,(Math_Level-DT,a4)
	bhs.b	C1116A
	move	(Math_Level-DT,a4),-(sp)
	move	#MATH_COMPARE,(Math_Level-DT,a4)
	bsr	C1104E
	sgt	d3
	ext.w	d3
	ext.l	d3
	move	(sp)+,(Math_Level-DT,a4)
	jmp	(a3)

C1116A:
	lea	(C11148,pc),a3
	rts

C11170:
	addq.w	#1,a6
C11172:
	cmp	#MATH_SHIFTPOT,(Math_Level-DT,a4)
	bhs.b	C11194
	move	(Math_Level-DT,a4),-(sp)
	move	#MATH_SHIFTPOT,(Math_Level-DT,a4)
	bsr.b	PARSE_GET_NEXT_VALUE
	tst	d0
	bne	ERROR_RelativeModeEr
	asl.l	d5,d3
	move	(sp)+,(Math_Level-DT,a4)
	jmp	(a3)

C11194:
	lea	(C11172,pc),a3
	rts

C1119A:
	addq.w	#1,a6
C1119C:
	cmp	#MATH_SHIFTPOT,(Math_Level-DT,a4)
	bhs.b	C111BE
	move	(Math_Level-DT,a4),-(sp)
	move	#MATH_SHIFTPOT,(Math_Level-DT,a4)
	bsr.b	PARSE_GET_NEXT_VALUE
	tst	d0
	bne	ERROR_RelativeModeEr
	asr.l	d5,d3
	move	(sp)+,(Math_Level-DT,a4)
	jmp	(a3)

C111BE:
	lea	(C1119C,pc),a3
	rts

PARSE_GET_NEXT_VALUE:
	move	d2,-(sp)
	move.l	d3,-(sp)
	bsr	C10AA2
	btst	#AF_UNDEFVALUE,d7
	bne.b	C111FC
	move.l	d3,d5
	move	d2,d4
	beq.b	C111F2
	move.l	(sp)+,d3
	move	(sp)+,d2
	beq.b	C111EE
	cmp	d2,d4
	bne	ERROR_RelativeModeEr
	tst	d2
	bmi.w	ERROR_Linkerlimitation
	moveq	#3,d0
	rts

C111EE:
	moveq	#1,d0
	rts

C111F2:
	move.l	(sp)+,d3
	move	(sp)+,d2
	beq.b	C11206
	moveq	#2,d0
	rts

C111FC:
	addq.l	#6,sp
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
C11206:
	moveq	#0,d0
	rts

C1120A:
	moveq	#0,d0
	move.b	(a6)+,d0
	move	d0,d1
	add.b	d1,d1
	add	(W1121E,pc,d1.w),d1
	jmp	(W1121E,pc,d1.w)

C1121A:
	moveq	#0,d1
	rts

W1121E:
	dr.w	C1121A
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C11322
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C113FA		; '0'
	dr.w	C113FA
	dr.w	C113FA
	dr.w	C113FA
	dr.w	C113FA
	dr.w	C113FA
	dr.w	C113FA
	dr.w	C113FA
	dr.w	C113FA
	dr.w	C113FA		; '9'
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E
	dr.w	C1131E

C1131E:
	move	d0,d1
	rts

C11322:
	movem.l	d2/d7/a1,-(sp)
	cmp.b	#6,(OpperantSize-DT,a4)
	beq.b	C11384
	cmp.b	#4,(OpperantSize-DT,a4)
	beq.b	C1137C
	tst.b	(OpperantSize-DT,a4)
	beq.b	C11374
	cmp.b	#$71,(OpperantSize-DT,a4)
	beq.b	C1136C
	cmp.b	#$75,(OpperantSize-DT,a4)
	beq.b	C11364
	cmp.b	#$72,(OpperantSize-DT,a4)
	beq.b	C1135C
	moveq	#11,d7
	pea	(C113B8,pc)
	bra.b	C1138A

C1135C:
	moveq	#11,d7
	pea	(C113C0,pc)
	bra.b	C1138A

C11364:
	moveq	#7,d7
	pea	(C113C8,pc)
	bra.b	C1138A

C1136C:
	moveq	#3,d7
	pea	(C113D0,pc)
	bra.b	C1138A

C11374:
	moveq	#3,d7
	pea	(C113D8,pc)
	bra.b	C1138A

C1137C:
	moveq	#1,d7
	pea	(C113E0,pc)
	bra.b	C1138A

C11384:
	pea	(C113E8,pc)
	moveq	#0,d7
C1138A:
	lea	(D02F260-DT,a4),a1
C1138E:
	moveq	#1,d1
	moveq	#0,d2
C11392:
	move.b	(a6)+,d0
	sub.b	#$30,d0
	bmi.b	C113B4
	cmp.b	#$11,d0
	blt.b	C113A4
	subq.b	#7,d0
C113A4:
	lsl.w	#4,d2
	add.b	d0,d2
	dbra	d1,C11392
	move.b	d2,(a1)+
	dbra	d7,C1138E
	rts

C113B4:
	subq.w	#1,a6
	rts

C113B8:
	fmove.p	(D02F260-DT,a4),fp0
	bra.b	C113EE

C113C0:
	fmove.x	(D02F260-DT,a4),fp0
	bra.b	C113EE

C113C8:
	fmove.d	(D02F260-DT,a4),fp0
	bra.b	C113EE

C113D0:
	fmove.s	(D02F260-DT,a4),fp0
	bra.b	C113EE

C113D8:
	fmove.l	(D02F260-DT,a4),fp0
	bra.b	C113EE

C113E0:
	fmove.w	(D02F260-DT,a4),fp0
	bra.b	C113EE

C113E8:
	fmove.b	(D02F260-DT,a4),fp0
C113EE:
	moveq	#0,d0
	moveq	#NS_AVALUE,d1
	movem.l	(sp)+,d2/d7/a1
	rts

C113FA:
	movem.l	d3/d4/a2,-(sp)
	subq.l	#1,a6
	bsr.b	C11486
	bvs.b	C1147A
	fmove.x	fp0,fp2
	cmp.b	#'.',(a6)
	bne.b	C11462
	addq.w	#1,a6
	bsr.b	C11486
	tst	d2
	beq.b	C11474
	fmove.d	fp0,-(sp)
	move.l	a6,a2
	move.l	d2,d0
	ext.l	d0
	neg.l	d0
	fmove.l	d0,fp1
	ftentox.x	fp1
	bvs.b	C1147A
	fmove.x	fp1,fp0
	fmove.d	(sp)+,fp1
	fmul.x	fp1,fp0
	bvs.b	C1147A
	fmove.x	fp2,fp1
	fadd.x	fp1,fp0
	move.l	a2,a6
	bra.b	C11468

C11462:
	tst	d2
	beq.b	C11480
C11468:
	moveq	#0,d0
	moveq	#NS_AVALUE,d1
C11474:
C1147A:
C11480:
	movem.l	(sp)+,d3/d4/a2
	rts

C11486:
	movem.l	d3/d4/a2,-(sp)
	move.l	a6,a2
	fmove.w	#10,fp0
	fmove.d	fp0,-(sp)
	moveq	#0,d3
	fmove.l	d3,fp0
C114A2:
	move.b	(a2)+,d4
	cmp.b	#$30,d4
	bcs.b	C114D6
	cmp.b	#$3A,d4
	bcc.b	C114D6
	fmove.d	(sp),fp1
	fmul.x	fp1,fp0
	bvs.b	C114E4
	fmove.d	fp0,-(sp)
	movem.l	(sp),d0/d1
	moveq	#15,d0
	and	d4,d0
	fmove.l	d0,fp0
	fmove.d	(sp)+,fp1
	fadd.x	fp1,fp0
	addq.w	#1,d3
	bra.b	C114A2

C114D6:
	addq.w	#8,sp
	move.l	d3,d2
	lea	(-1,a2),a6
	movem.l	(sp)+,d3/d4/a2
	rts

C114E4:
	addq.w	#8,sp
	lea	(-1,a2),a6
	ori.b	#2,ccr		; set v
	movem.l	(sp)+,d3/d4/a2
	rts

Asm_ImmediateOppFloat:
	tst	(FPU_Type-DT,a4)
	beq	ERROR_FPUneededforopp
	bclr	#AF_UNDEFVALUE,d7
C11500:	clr	(Math_Level-DT,a4)
C11504:	pea	(C11666,pc)
C11508:	bsr	C1120A
	add.b	d1,d1
	and.w	#$00ff,d1
	add	(W11518,pc,d1.w),d1
	jmp	(W11518,pc,d1.w)

W11518:	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11650
	dr.w	C11618
	dr.w	C1161C
	dr.w	C11508
	dr.w	C11618
	dr.w	C11630
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C1163A
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C1162A
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618
	dr.w	C11618

C11618:
	br	ERROR_IllegalOperand

C1161C:
	move	(CurrentSection-DT,a4),d2
	fmove.l	(INSTRUCTION_ORG_PTR-DT,a4),fp0
	rts

C1162A:
	bclr	#LB_PASS2BIT,d2
	rts

C11630:
	bsr	C11508
	fneg.x	fp0
	rts

C1163A:
	move	(Math_Level-DT,a4),-(sp)
	bsr	C11500
	cmp.b	#']',(a6)+
	bne	ERROR_Rightparenthe
	move	(sp)+,(Math_Level-DT,a4)
	rts

C11650:
	move	(Math_Level-DT,a4),-(sp)
	bsr	C11500
	cmp.b	#')',(a6)+
	bne	ERROR_Rightparenthe
	move	(sp)+,(Math_Level-DT,a4)
	rts

C11666:
	moveq	#0,d0
	move.b	(a6)+,d0
	move	d0,d1
	add.b	d1,d1
	add	(W11676,pc,d1.w),d1
	jmp	(W11676,pc,d1.w)

W11676:
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C1182A
	dr.w	C117B4
	dr.w	C11776
	dr.w	C11782
	dr.w	C11776
	dr.w	C11856
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C117E6
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776
	dr.w	C11776

C11776:
	subq.w	#1,a6
	lea	(C1177E,pc),a3
	rts

C1177E:
	move.b	(a6),d0
	rts

C11782:
	cmp	#MATH_ADDSUB,(Math_Level-DT,a4)
	bhs.b	C117AE
	move	(Math_Level-DT,a4),-(sp)
	move	#MATH_ADDSUB,(Math_Level-DT,a4)
	bsr	C118C8
	fsub.x	fp3,fp0
	fmove.l	fpsr,(LastCalcFpsr-DT,a4)
	lsr.w	#1,d0
	bcc.b	C117A8
	moveq	#0,d2
C117A8:
	move	(sp)+,(Math_Level-DT,a4)
	jmp	(a3)

C117AE:
	lea	(C11782,pc),a3
	rts

C117B4:
	cmp	#MATH_ADDSUB,(Math_Level-DT,a4)
	bhs.b	C117E0
	move	(Math_Level-DT,a4),-(sp)
	move	#MATH_ADDSUB,(Math_Level-DT,a4)
	bsr	C118C8
	fadd.x	fp3,fp0
	fmove.l	fpsr,(LastCalcFpsr-DT,a4)
	lsr.w	#1,d0
	bcc.b	C117DA
	move	d4,d2
C117DA:
	move	(sp)+,(Math_Level-DT,a4)
	jmp	(a3)

C117E0:
	lea	(C117B4,pc),a3
	rts

C117E6:
	cmp	#MATH_SHIFTPOT,(Math_Level-DT,a4)
	bhs.b	C11824
	move	(Math_Level-DT,a4),-(sp)
	move	#MATH_SHIFTPOT,(Math_Level-DT,a4)
	bsr	C118C8
	move.l	d0,-(sp)
	fmove.l	fp3,d0
	fmove.x	fp0,fp3
	subq.l	#1,d0

	beq.b	.ExpFin
	bpl.b	.ExpLoop
	fmove.w	#1,fp3		; x^(-y) = (1/x)^y
	fdiv.x	fp0,fp3
	neg.l	d0		; loop 2 extra times to compensate
.ExpLoop
	fmul.x	fp3,fp0
	fmove.l	fpsr,(LastCalcFpsr-DT,a4)
	subq.l	#1,d0
	bne.b	.ExpLoop

.ExpFin	move.l	(sp)+,d0
	move	(sp)+,(Math_Level-DT,a4)
	jmp	(a3)

C11824:
	lea	(C117E6,pc),a3
	rts

C1182A:
	cmp	#MATH_MULDIV,(Math_Level-DT,a4)
	bhs.b	C11850
	move	(Math_Level-DT,a4),-(sp)
	move	#MATH_MULDIV,(Math_Level-DT,a4)
	bsr.b	C118C8
	fmul.x	fp3,fp0
	fmove.l	fpsr,(LastCalcFpsr-DT,a4)
	move	(sp)+,(Math_Level-DT,a4)
	jmp	(a3)

C11850:
	lea	(C1182A,pc),a3
	rts

C11856:
	cmp	#MATH_MULDIV,(Math_Level-DT,a4)
	bhs.b	C118C2
	move	(Math_Level-DT,a4),-(sp)
	move	#MATH_MULDIV,(Math_Level-DT,a4)
	bsr.b	C118C8
	ftst.x	fp3
	fbeq	ERROR_IllegalOperand	; division by zero?
	fdiv.x	fp3,fp0
	fmove.l	fpsr,(LastCalcFpsr-DT,a4)
	move	(sp)+,(Math_Level-DT,a4)
	jmp	(a3)

C118C2:
	lea	(C11856,pc),a3
	rts

C118C8:
	move	d2,-(sp)
	fmove.x	fp0,-(sp)
	bsr	C11504
	btst	#AF_UNDEFVALUE,d7
	bne.b	C118FC
	fmove.x	fp0,fp3
	move	d2,d4
	beq.b	C118F0
	fmove.x	(sp)+,fp0
	move	(sp)+,d2
	beq.b	C118EC
	moveq	#3,d0
	rts

C118EC:
	moveq	#1,d0
	rts

C118F0:
	fmove.x	(sp)+,fp0
	move	(sp)+,d2
	beq.b	C11908
	moveq	#2,d0
	rts

C118FC:
	lea	(14,sp),sp
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
C11908:
	moveq	#0,d0
	rts


CommandlineInputHandler:
	bclr	#SB2_INSERTINSOURCE,(SomeBits2-DT,a4)
	and.b	#~((1<<SB3_REPORT_ERROR)|(1<<SB3_SPEC_KEYS)),(SomeBits3-DT,a4)
	bset	#MB1_INCOMMANDLINE,(MyBits-DT,a4)	;in commandline mode

	jsr	(Change2Commmenu)

	bset	#SB2_MATH_XN_OK,(SomeBits2-DT,a4)
	btst	#SB1_CLOSE_FILE,(SomeBits-DT,a4)
	beq.b	.FileClosed
	bsr	close_bestand
.FileClosed:
	move.l	(DATA_USERSTACKPTR-DT,a4),sp
	clr	(SST_STEPS-DT,a4)
	st	(BreakKey-DT,a4)	; disabled
	clr.l	(DATA_CURRENTLINE-DT,a4)
	moveq	#0,d7

	sf	(Asm_Multiscroll-DT,a4)
	clr.w	(Cursor_col_pos-DT,a4)	;x reset col pos
	bsr.w	Place_cursor_blokje

	lea	(Prompt_Char,pc),a0
	bsr	Druk_CmdMenuText
	move.b	#21,(BreakKey-DT,a4)	;AMIGA_C
MAINLOOPAGAIN:
	lea	(CurrentAsmLine-DT,a4),a6
	move.l	a6,a1
	moveq	#0,d1
.Handle_WS:
	move.b	(a6)+,d1
	tst.b	(Variable_base-DT,a4,d1.w)
	bmi.b	.Handle_WS
	subq.w	#1,a6
.lopje:
	move.b	(a6)+,(a1)+
	bne.b	.lopje

	lea	(CurrentAsmLine-DT,a4),a6
	tst.b	(a6)
	beq	SPECIALKEY_HANDLER
	bsr.w	Druk_af_eol
	bsr.w	Druk_Clearbuffer
	move.b	(a6)+,d0
	cmp.b	#'!',d0
	beq.b	exit_or_extentie
	cmp.b	#'#',d0
	beq	About_req
	cmp.b	#'a',d0
	bcs.b	.uppercase
	sub.b	#$20,d0
.uppercase:
	moveq	#0,d1
	move.b	d0,(Comm_Char-DT,a4)
	lea	(Command_Line_Table,pc),a5
	sub.b	#$3D,d0		;'='
	bmi.w	ERROR_IllegalComman
	cmp.b	#$1E,d0		;'Z'-'='
	bhi.w	ERROR_IllegalComman
	add.b	d0,d0
	ext.w	d0
	add	d0,d0
	add	d0,a5
	btst	#0,(3,a5)
	beq.b	C11A64
	bsr	GETNUMBERAFTEROK
C11A64:
	moveq	#-2,d2
	and.l	(a5),d2
	move.l	d2,a5
	jsr	(Change2Commmenu)
	cmp.b	#NS_AVALUE,d1
	jsr	(a5)
	br	CommandlineInputHandler

exit_or_extentie:
	cmp.b	#"!",(a6)
	beq.b	exit_now		;"!!"
	moveq	#~32,d0
	and.b	(a6),d0
	cmp.b	#"R",d0
	beq.b	exit_restart		;"!R"
	tst.b	(a6)
	bne.b	com_change_src_ext

exit_check:
	move.b	(CurrentSource-DT,a4),d1
	move.b	d1,(ActiveSrcNr-DT,a4)
	add.b	#'0',d1
	move.b	d1,(SourceNrInBalk).l
	jmp	(Restart)

exit_now:
	moveq	#"Y",d0
exit_restart:
	jmp	(Restart)


com_change_src_ext:	; !<pattern>
	clr.b	(16,a6)			; not longer than 16 chars
	bsr	change_extention
	br	CommandlineInputHandler


About_req:
	movem.l	d0-d7/a0-a6,-(sp)
	moveq	#1,d0
	lea	(_Ok_Ok.MSG),a2
	lea	(AsmPro_abouttxt.MSG-_Ok_Ok.MSG,a2),a1
	jsr	(ShowReqtoolsRequester_HaveType-_Ok_Ok.MSG,a2)
	movem.l	(sp)+,d0-d7/a0-a6
	br	CommandlineInputHandler

Error_req:
	movem.l	d0-d7/a0-a6,-(sp)
	moveq	#1,d0
	lea	(_Ok_Ok.MSG),a2
	jsr	(ShowReqtoolsRequester_HaveType-_Ok_Ok.MSG,a2)
	movem.l	(sp)+,d0-d7/a0-a6
	rts

C11ABE:
	jsr	(PARSE_GET_SIZE_BWL_DEF_BYTE_NOSPACE)
	move.b	d1,(OpperantSize-DT,a4)
	rts

GETNUMBERAFTEROK:
	move.l	a5,-(sp)
	bsr.b	C11ABE
	move.b	(OpperantSize-DT,a4),-(sp)
	bsr	Convert_A2I
	move.b	(sp)+,(OpperantSize-DT,a4)
	cmp.b	#1,(OpperantSize-DT,a4)
	beq.b	.C11B2E

.Entry	btst	#0,d0
	beq.b	.C11B2E
	cmp	#PB_020,(ProcessorType-DT,a4)
	bge.b	.C11B2E
	cmp.b	#NS_AVALUE,d1
	beq	ERROR_WordatOddAddress

.C11B2E	move.l	(sp)+,a5
	cmp.b	#NS_AVALUE,d1
	rts

C11B36:
	move.l	a5,-(sp)
	jsr	(Parse_GetFloatSize)
	move.b	d1,(OpperantSize-DT,a4)
	move.b	d1,-(sp)
	bsr	Convert_A2F
	move.b	(sp)+,(OpperantSize-DT,a4)
	bra.b	GETNUMBERAFTEROK\.Entry

SPECIALKEY_HANDLER:
	cmp.b	#$80,d0		;ESCFLAG
	beq.b	keys_ESC
	cmp.b	#13,d0
	bne.b	keys_NotReturn
	move.b	(Comm_Char-DT,a4),d0
	cmp.b	#'@',d0
	bne.b	C11B9E
	move.b	d0,(a6)+
	addq.w	#1,a6
	cmp.b	#$2E,(a6)
	bne.b	C11B88
	addq.w	#2,a6
C11B88:
	clr.b	(a6)
	br	MAINLOOPAGAIN

keys_NotReturn:
	cmp.b	#$20,d0		;ctrl + ESC halve editor
	beq	Enter_Editor2
	cmp.b	#$1B,d0		;ESC !!
	beq	Enter_Editor1
C11B9E:
	bsr	SENDCHARDELSCR
	br	CommandlineInputHandler

keys_ESC:
	move.b	(edit_EscCode-DT,a4),d0

;	cmp.b	#$66,d0
;	bne.s	.nosourcechange
;	jsr	E_ChangeSource
;	br	CommandlineInputHandler
;.nosourcechange:

	cmp.b	#$22,d0
	bne.b	C11BBC
	bchg	#0,(PR_PrintDump).l
	br	CommandlineInputHandler

C11BBC:
	pea	(CommandlineInputHandler,pc)
	cmp.b	#$31,d0
	beq.w	Enter_Editor1
	cmp.b	#$39,d0
	bne.b	.C11BD2
	jmp	(EnterMonitorMode)
.C11BD2	cmp.b	#9,d0		;TAB
	beq.b	C_AsmPrefs
	cmp.b	#12,d0		;FF
	beq.b	C_EnvPrefs
	cmp.b	#70,d0		;Amiga-Z
	beq.b	C_SyntPrefs
	cmp.b	#$65,d0		;'e'
	beq.b	C_AmigaGuide
	cmp.b	#$2D,d0		;'-'
	bne.b	.C11BF0
	jmp	(com_assemble)
.C11BF0	cmp.b	#$3B,d0		;';'
	bne.b	.C11BFC
	jmp	(Asmbl_OptMode)
.C11BFC	cmp.b	#'0',d0
	beq.w	Enter_debugger
	addq.w	#4,sp
	bra.w	CommandlineInputHandler

C_SyntPrefs:
	move.b	#2,(Prefs_tiepe-DT,a4)
	bra.b	C_doprefs

C_EnvPrefs:
	move.b	#1,(Prefs_tiepe-DT,a4)
	bra.b	C_doprefs

C_AsmPrefs:
	clr.b	(Prefs_tiepe-DT,a4)
C_doprefs:
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(Handle_prefs_windows).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

C_AmigaGuide:
	jmp	(AmigaGuideGedoe)


Enter_Editor1:
	move	(NumLines_Editor-DT,a4),d0
	move	(Scr_br_chars-DT,a4),(breedte_editor_in_chars-DT,a4)
	bsr.b	OPED_SETNBOFFLINES
	jmp	(ACTIVATEEDITORWINDOW).l

Enter_Editor2:
	bsr.w	_Show_Cursor
	move	(NumLines_HalfEditor-DT,a4),d0
	move	(Scr_br_chars-DT,a4),(breedte_editor_in_chars-DT,a4)
	bsr.b	OPED_SETNBOFFLINES
	jmp	(ACTIVATEEDITORWINDOW).l

OPED_SETNBOFFLINES:
	move	d1,-(sp)

	move.w	d0,d1
	subq.w	#1,d1
	mulu.w	(Scr_NrPlanes-DT,a4),d1
.eenplane:
	mulu.w	(EFontSize_y-DT,a4),d1
	subq.w	#1,d1
	move.w	d1,(Edit_nrlines-DT,a4)	;aantal editorbeeldlijntjes -1

	moveq	#0,d1
	move	d0,d1

	btst	#SB2_INDEBUGMODE,(SomeBits2-DT,A4)
	beq.s	.nodebug
	subq.w	#1,d0
.nodebug:
	move	d0,(NrOfLinesInEditor+2-DT,a4)
	subq.w	#1,d0
	move	d0,(NrOfLinesInEditor_min1-DT,a4)

	addq.w	#1,d1
	divu	#100,d1
	add	#'0',d1
	move.b	d1,(status_line_txt+1)
	swap	d1
	ext.l	d1
	divu	#10,d1
	add	#'0',d1
	move.b	d1,(status_line_txt+2)
	swap	d1
	add	#'0',d1
	move.b	d1,(status_line_txt+3)
	move	(sp)+,d1
	rts

ErrMsgNoDebug:
	btst	#AF_LISTFILE,d7
	bne	Druk_Af_Regel1
	btst	#AF_ALLERRORS,d7
	bne	Druk_Af_Regel1
	clr	d7
	bsr	Print_ErrorTxt
	move.l	(DATA_CURRENTLINE-DT,a4),d0
	beq.b	ErrLijnNul
	move.l	d0,(FirstLineNr-DT,a4)
	clr.l	(DATA_CURRENTLINE-DT,a4)
	move.l	(DATA_LINE_START_PTR-DT,a4),(FirstLinePtr-DT,a4)

	bra.b	Print_DrukErrorRegel

ErrMsgNoDeal:
	bsr	Drukaf_CurrentLine

ErrLijnNul:
	bsr	clear_input_buffer
	bra	CommandlineInputHandler

C11CF0:
	lea	(Not.MSG,pc),a0
	br	C105DE

;*********** show error pos in string **************

Print_DrukErrorRegel:
	move.l	(ParsePos-DT,a4),d0
	move.l	(FirstLinePtr-DT,a4),a0

	sub.l	a0,d0
	subq.l	#1,d0
	bmi.s	ErrMsgNoDeal
	cmp.l	#128,d0
	bhi.s	ErrMsgNoDeal

	lea	(regel_buffer-DT,a4),a1
	move.l	a1,-(sp)
.lopje:
	move.b	(a0)+,(a1)+
	dbf	d0,.lopje
	clr.b	(a1)

	move.l	(FirstLineNr-DT,a4),d0
	bsr	DrukAf_LineNrPrint

	move.l	(sp)+,a0
	bsr	printthetext
	bsr	Druk_Clearbuffer

	bset	#SB2_REVERSEMODE,(SomeBits2-DT,a4)
	move.l	(ParsePos-DT,a4),a0
	bsr	printthetext
	bsr	Druk_Clearbuffer
	bclr	#SB2_REVERSEMODE,(SomeBits2-DT,a4)

	bsr	druk_cr_nl
	bra.b	ErrLijnNul


Print_ErrorTxt:
	moveq	#$9B-256,d0
	bsr	SENDONECHARNORMAL
	moveq	#$31,d0		;'1'
	bsr	SENDONECHARNORMAL
	move.b	#$48,d0		;'H'
	bsr	SENDONECHARNORMAL
	moveq	#$2A,d0		;'*'
	bsr	SENDONECHARNORMAL
	moveq	#$2A,d0		;'*'
	bsr	SENDONECHARNORMAL
	bsr	druk_af_space
	move.l	a0,-(sp)
	bsr	printthetext
	move.l	(sp)+,a0
	tst	(INCLUDE_LEVEL-DT,a4)
	beq	druk_cr_nl
	cmp.b	#$46,(a0)	;'F'
	bne.b	C11D52
	cmp.b	#$69,(1,a0)	;'i'
	beq	druk_cr_nl
C11D52:
	bsr	druk_cr_nl
	moveq	#$49,d0		;'I' In file
	bsr	SENDONECHARNORMAL
	moveq	#$6E,d0		;'n'
	bsr	SENDONECHARNORMAL
	bsr	druk_af_space
	moveq	#$66,d0		;'f'
	bsr	SENDONECHARNORMAL
	moveq	#$69,d0		;'i'
	bsr	SENDONECHARNORMAL
	moveq	#$6C,d0		;'l'
	bsr	SENDONECHARNORMAL
	moveq	#$65,d0		;'e'
	bsr	SENDONECHARNORMAL
	bsr	druk_af_space

	move.l	(SOLO_CurrentIncPtr-DT,a4),a0

	lea	(12,a0),a0
	move.l	a1,-(sp)
	move.l	a0,a1
C11D98:
	tst.b	(a0)+
	bne.b	C11D98
C11D9C:
	cmp.b	#$3A,(a0)	;':'
	beq.b	C11DAA
	cmp.l	a0,a1
	beq.b	C11DBC
	subq.w	#1,a0
	bra.b	C11D9C

C11DAA:
	subq.w	#1,a0
C11DAC:
	cmp.l	a0,a1
	beq.b	C11DBC
	cmp.b	#$3A,(a0)
	beq.b	C11DBA
	subq.w	#1,a0
	bra.b	C11DAC

C11DBA:
	addq.w	#1,a0
C11DBC:
	move.l	(sp)+,a1
	bsr	printthetext
	clr	(INCLUDE_LEVEL-DT,a4)
	bsr	druk_cr_nl

	move.l	a6,a0
	move.l	a0,-(sp)	;set pointer op stack

	move.l	(ErrorLijnInCode-DT,a4),d0
	subq.l	#1,d0
	beq.s	.megaJump

.lopje	tst.b	-(a0)
	bne.s	.lopje
	move.l	a0,(sp)		;re-set pointer

	bsr	druk_af_space
	move.l	(ErrorLijnInCode-DT,a4),d0
	subq.l	#1,d0
	bsr	PRINTDECIMALSIGN
	bsr	druk_af_space

	move.l	(sp)+,a0
	bsr.b	.drukerrorregels
	move.l	a0,-(sp)

.megaJump:
	moveq	#$BB-256,d0
	bsr	SENDONECHARNORMAL

	move.l	(ErrorLijnInCode-DT,a4),d0
	bsr	PRINTDECIMALSIGN
	bsr	druk_af_space
	bsr	Druk_Clearbuffer

	bset	#SB2_REVERSEMODE,(SomeBits2-DT,a4)
	move.l	(sp)+,a0
	bsr.b	.drukerrorregels
	move.l	a0,-(sp)

	bsr	druk_af_space
	move.l	(ErrorLijnInCode-DT,a4),d0
	addq.l	#1,d0
	bsr	PRINTDECIMALSIGN
	bsr	druk_af_space

	move.l	(sp)+,a0
	bsr.b	.drukerrorregels
	br	druk_cr_nl

.drukerrorregels:
.C11E1C:
	cmp.b	#SRCMARK_BEGIN,-(a0)
	beq.b	.C11E2A
	tst.b	(a0)
	bne.b	.C11E1C

.C11E2A:
	addq.w	#1,a0
	bsr	printthetext
	bsr	Druk_Clearbuffer
	bclr	#SB2_REVERSEMODE,(SomeBits2-DT,a4)
	bra	druk_cr_nl

Druk_Af_Regel1:
	move.l	a1,-(sp)
	move.l	(AsmErrorPos-DT,a4),a1
	cmp.l	#AsmEindeErrorTable,a1
	beq.b	C11E54
	move.l	(DATA_CURRENTLINE-DT,a4),(a1)+
	move.l	a0,(a1)+
	st	(a1)
	move.l	a1,(AsmErrorPos-DT,a4)
C11E54:
	move.l	(sp)+,a1
	btst	#SB3_REPORT_ERROR,(SomeBits3-DT,a4)
	beq.b	C11E64
	move.l	(Error_Jumpback-DT,a4),a1
	jmp	(a1)

C11E64:
	addq.w	#1,(NrOfErrors-DT,a4)
	move.l	a0,-(sp)
	bsr	PRINT_PAGED
	move.l	(sp)+,a0
	bsr	Print_ErrorTxt
	move.l	(TEMP_STACKPTR-DT,a4),sp
	move.l	(DATA_LINE_START_PTR-DT,a4),a6
.C11E7C	cmp.b	#SRCMARK_END,(a6)
	beq.b	.end
	tst.b	(a6)+
	bne.b	.C11E7C
.end	move.l	a6,-(sp)
	bsr	PRINT_ASSEMBLING_NOW
	move.l	(sp)+,a6
	jmp	(ASSEM_CONTINUE).l

Command_Line_Table:
	dc.l	com_workspace		;=	61
	dc.l	com_RedirectCMD		;>	62
	dc.l	com_calculator+1	;?	
	dc.l	com_apestaartje		;@	
	dc.l	com_assemble		;A	65
	dc.l	com_bottom		;B	
	dc.l	com_copy		;C	
	dc.l	com_dissasemble+1	;D	
	dc.l	com_extern		;E	
	dc.l	com_fill+1		;F
	dc.l	com_Go+1		;G
	dc.l	com_hexdump+1		;H
	dc.l	com_insert		;I
	dc.l	com_jump+1		;J
	dc.l	com_singlestep+1	;K
	dc.l	com_search		;L
	dc.l	com_monitor+1		;M
	dc.l	com_ascii_dump+1	;N
	dc.l	com_terughalen		;O
	dc.l	com_printen		;P
	dc.l	com_compare		;Q
	dc.l	com_read		;R
	dc.l	com_search_in_mem 	;S
	dc.l	com_top+1		;T
	dc.l	com_update		;U
	dc.l	com_show_dir		;V
	dc.l	com_write		;W
	dc.l	com_show_regs		;X
	dc.l	com_execute_dos		;Y
	dc.l	com_zap			;Z
	dc.l	com_calc_float		;[

EXHA_BUSADDRERROR:
	lea	(At.MSG,pc),a0
	bsr	printthetext
	move.l	(pcounter_base-DT,a4),d0
	bsr	druk_af_d0
	lea	(Accessing.MSG,pc),a0
	bsr	printthetext
	move.l	(DATA_BUSPTRHI-DT,a4),d0
	bsr	druk_af_d0
	bsr	printthetext
	move	(DATA_BUSACCESS-DT,a4),d1
	moveq	#$52,d0
	btst	#4,d1
	bne.b	C11F42
	moveq	#$57,d0
C11F42:
	bsr	SENDONECHARNORMAL
	moveq	#$49,d0
	btst	#3,d1
	beq.b	C11F50
	moveq	#$4E,d0
C11F50:
	bsr	SENDONECHARNORMAL
	moveq	#7,d0
	and.b	d1,d0
	add.b	#'0',d0
	bsr	SENDONECHARNORMAL
	bsr	printthetext
	move	(DATA_BUSFAILINST-DT,a4),d0
	bsr	C15900
	jmp	(EXHA_JUSTRETURN).l

com_apestaartje:	; @
	moveq	#~32,d0
	and.b	(a6)+,d0
	cmp.b	#'D',d0
	beq	LINE_DISLINE
	cmp.b	#'H',d0
	beq	LINE_HEXLINE
	cmp.b	#'N',d0
	beq	LINE_ASCIILINE
	cmp.b	#'B',d0
	beq.b	LINE_BINLINE
	cmp.b	#'A',d0
	bne	ERROR_IllegalComman
	jmp	(LINE_MEMASSEM)

LINE_PARSE_AT_ARGS:
	move.w	d0,-(sp)
	cmp.b	#'{',(a6)
	seq	-(sp)
	bne.b	.NoRedir1
	addq.w	#1,a6
.NoRedir1
	bsr	GETNUMBERAFTEROK
	beq.b	.HaveAddr
	move.l	(MEM_DIS_DUMP_PTR-DT,a4),d0
.HaveAddr
	tst.b	(sp)+
	beq.b	.NoRedir2
	cmp	#PB_020,(ProcessorType-DT,a4)
	bge.b	.NoPtrAdjust
	bclr	#0,d0		; make ptr address even
.NoPtrAdjust
	move.l	d0,a0
	move.l	(a0),d0
.NoRedir2
	cmp	#PB_020,(ProcessorType-DT,a4)
	bge.b	.NoAdjust
	and.w	(sp),d0		; external override (for asm/disasm)
	cmp.b	#1,(OpperantSize-DT,a4)
	beq.b	.NoAdjust
	bclr	#0,d0
.NoAdjust
	addq.l	#2,sp
	rts

LINE_BINLINE:
	moveq	#~0,d0
	bsr.b	LINE_PARSE_AT_ARGS
	move.l	d0,d5
	move.l	d0,a5
	move.l	d0,a3
	moveq	#7,d6
	cmp.b	#1,(OpperantSize-DT,a4)
	beq.b	C12002
	moveq	#15,d6
C12002:
	move.b	(OpperantSize-DT,a4),d3
	ext.w	d3
	ext.l	d3
	add.l	d3,d5
	move.l	a5,d0
	bsr	druk_af_d0_space
	moveq	#$25,d0
	bsr	SENDONECHARNORMAL
C12018:
	bsr.b	C1202E
	cmp.l	d5,a5
	bne.b	C12018
	bsr	druk_cr_nl
	dbra	d6,C12002
	move.l	d5,(MEM_DIS_DUMP_PTR-DT,a4)
	rts

C1202E:
	move.b	(OpperantSize-DT,a4),d3
	ext.w	d3
	subq.w	#1,d3
C12036:
	move.b	(a5)+,d0
	bsr.b	C120AE
	dbra	d3,C12036
	br	druk_af_space

C12044:
	bsr	C11ABE
	bsr	INPUTBEGINEND
	move.l	d2,a3
	move.l	d0,a2
	bclr	#SB2_INDEBUGMODE,(SomeBits2-DT,a4)
	bset	#SB2_INSERTINSOURCE,(SomeBits2-DT,a4)
	move.l	(FirstLinePtr-DT,a4),-(sp)
C12062:
	cmp.l	a3,a2
	bls.b	C1209E
	move.b	(OpperantSize-DT,a4),d4
	ext.w	d4
	lsr.w	#1,d4
	mulu	#7,d4
	lea	(DCB.MSG,pc),a0
	add	d4,a0
	bsr	printthetext
	moveq	#$25,d0
	bsr	SENDONECHARNORMAL
	move.b	(OpperantSize-DT,a4),d4
	ext.w	d4
	subq.w	#1,d4
C1208A:
	move.b	(a3)+,d0
	bsr.b	C120AE
	dbra	d4,C1208A
	cmp.l	a3,a2
	bls.b	C1209E
	bsr	Druk_af_eol
	bra.b	C12062

C1209E:
	bsr	Druk_af_eol
	bsr.w	Druk_Clearbuffer
	move.l	(sp)+,(FirstLinePtr-DT,a4)
	rts

C120AE:
	movem.l	d0-d7/a0-a6,-(sp)
	move.b	d0,d1
	moveq	#7,d7
.C120B6	moveq	#'0'/2,d0
	add.b	d1,d1
	addx.b	d0,d0
	bsr	SENDONECHARNORMAL
	dbra	d7,.C120B6
	movem.l	(sp)+,d0-d7/a0-a6
	rts

com_printen:
	moveq	#~32,d0
	and.b	(a6),d0

	IF useplugins
	cmp.b	#'W',d0		;plugin's windowtje
	bne.s	.noplugs
	jmp	E_Showplugs
.noplugs:
	ENDIF
	cmp.b	#'S',d0
	bne.b	C1210E

	lea	(Startupparame.MSG,pc),a0
	bsr	INPUTTEXT
	lea	(CurrentAsmLine-DT,a4),a1
	tst.b	(a1)
	beq.b	.C1210C
	lea	(Parameters-DT,a4),a0
	move.l	a1,d1
	move.w	#256-1-1,d0		; lf at the end
.C120F2
	move.b	(a1)+,(a0)+
	dbeq	d0,.C120F2
	clr.b	(a0)
	move.b	#10,-(a0)
	sub.l	d1,a1
	move.l	a1,(ParametersLengte-DT,a4)
.C1210C
	rts

C1210E:
	bsr	Convert_A2I
	tst.b	d1
	beq.b	C12146
	move.l	d0,d5
	beq.b	C12146
	move.l	(FirstLinePtr-DT,a4),a0
	move.l	(FirstLineNr-DT,a4),d1
C12122:
	move.l	d1,d0
	addq.l	#1,d1
	movem.l	d1/a0,-(sp)
	bsr	DrukAf_LineNrPrint
	movem.l	(sp)+,d1/a0
	cmp.b	#SRCMARK_END,(a0)
	beq	ERROR_EndofFile
	bsr	printthetext
	bsr	druk_cr_nl
	subq.l	#1,d5
	bne.b	C12122
C12146:
	rts

com_execute_dos:
	tst.b	(a6)
	beq.b	.NoCmd
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	a6,-(sp)
	move.l	(ScreenBase),a2
	move.w	#SHOWTITLE|WBENCHSCREEN,(sc_Flags,a2)	; $10|$01
	move.l	(DosBase-DT,a4),a6
	lea	(.OutputCON,pc),a0
	move.l	a0,d1
	move.l	#MODE_OLDFILE,d2	; 1005
	jsr	(_LVOOpen,a6)
	move.l	(sp)+,d1
	move.l	d0,d4
	beq.b	.OpenFailed
	moveq	#0,d2
	move.l	d4,d3
	jsr	(_LVOExecute,a6)
	move.l	d4,d1
	lea	(.ExecDone,pc),a0
	move.l	a0,d2
	moveq	#.ExecDoneEnd-.ExecDone,d3
	jsr	(_LVOWrite,a6)
	move.l	d4,d1
	lea	(ExecCmd_AnyKeyBuffer-DT,a4),a0
	move.l	a0,d2
	moveq	#1,d3
	jsr	(_LVORead,a6)
	move.l	d4,d1
	jsr	(_LVOClose,a6)
.OpenFailed
	move.w	#SHOWTITLE|CUSTOMSCREEN,(sc_Flags,a2)	; $10|$0f
	movem.l	(sp)+,d0-d7/a0-a6
.NoCmd	rts

.OutputCON
	DC.B	'CON:0/0/635/200/Dos command output window',0
.ExecDone
	DC.B	'Execution complete. Press return...'
.ExecDoneEnd
	EVEN

LINE_HEXLINE:
	moveq	#~0,d0
	bsr	LINE_PARSE_AT_ARGS
	move.l	d0,d5
	move.l	d0,a5
	move.l	d0,a3
	moveq	#7,d6
C122C0:
	addq.l	#8,d5
	addq.l	#8,d5
	move.l	a5,d0
	bsr	druk_af_d0_space
C122CA:
	bsr	C1381C
	cmp.l	d5,a5
	bne.b	C122CA
	moveq	#$22,d0
	bsr	SENDONECHARNORMAL
C122D8:
	moveq	#$7f,d0
	and.b	(a3)+,d0
	cmp.b	#$7F,d0
	beq.b	C122EA
	cmp.b	#$20,d0
	bcc.b	C122EC
C122EA:
	moveq	#$2E,d0
C122EC:
	bsr	SENDONECHARNORMAL
	cmp.l	d5,a3
	bne.b	C122D8
	moveq	#$22,d0
	bsr	SENDONECHARNORMAL
	bsr	druk_cr_nl
	dbra	d6,C122C0
	move.l	d5,(MEM_DIS_DUMP_PTR-DT,a4)
	rts

com_extern:
	moveq	#~32,d0
	and.b	(a6),d0
	cmp.b	#'L',d0
	bne	C12566

com_extend_labels:
	move.b	(SomeBits2-DT,a4),(SomeBits2Backup-DT,a4)
	moveq	#1,d0
	move.w	d0,(ProgressCntr-DT,a4)
	move.w	d0,(ProgressSpeed-DT,a4)
	lea	(Extendlabelsw.MSG,pc),a0
	bsr	INPUTTEXT
	sf	(B30172-DT,a4)
	lea	(PrefixYN.MSG,pc),a0
	bsr	beeldtextaf

	bsr	GetHotKey
	bclr	#5,d0
	cmp.b	#$59,d0
	bne.b	C12356
	st	(B30172-DT,a4)
C12356:
	lea	(HPass1.MSG,pc),a0
	bsr	beeldtextaf
	move.l	(sourcestart-DT,a4),a0
	move.l	(WORK_END-DT,a4),a1
	subq.w	#1,a1
	lea	(a1),a2
	moveq	#0,d0
C12370:
	exg	a0,a6
	jsr	(ShowAsmProgress).l
	exg	a0,a6
	move.b	(a0)+,d1
	tst	d0
	bne.b	C12386
	cmp.b	#$2E,d1		;'.'
	beq.b	C123BA
C12386:
	cmp.b	#$3D,d1		;'='
	beq.b	C123BA
	cmp.b	#$3B,d1		;';'
	beq.b	C123BA
	cmp.b	#$2A,d1		;'*'
	beq.b	C123BA
	cmp.b	#$20,d1		;' '
	beq.b	C123BA
	cmp.b	#$3A,d1		;':'
	beq.b	C123BA
	cmp.b	#9,d1		;tab
	beq.b	C123BA
	cmp.b	#SRCMARK_END,d1
	beq.b	C123D6
	tst.b	d1
	beq.b	C123BA
	move.b	d1,-(a2)
	addq.w	#1,d0
	bra.b	C12370

C123BA:
	subq.w	#1,a0
	tst	d0
	beq.b	C123CA
	clr.b	-(a2)
	move.b	d0,(a1)
	subq.w	#1,a2
	lea	(a2),a1
	moveq	#0,d0
C123CA:
	cmp.b	#SRCMARK_END,(a0)
	beq.b	C123D6
	tst.b	(a0)+
	bne.b	C123CA
	bra.b	C12370

C123D6:
	movem.l	d0/a0,-(sp)
	lea	(CurrentAsmLine-DT,a4),a0
	move.l	a0,d0
.C123E0
	tst.b	(a0)+
	bne.b	.C123E0
	sub.l	a0,d0
	not.l	d0		; d0 = -d0-1
	move.l	d0,(L2FCEA-DT,a4)
	movem.l	(sp)+,d0/a0
	st	(a2)
	lea	(HPass2.MSG,pc),a0
	bsr	beeldtextaf
	bclr	#SB2_INDEBUGMODE,(SomeBits2-DT,a4)
	bset	#SB2_INSERTINSOURCE,(SomeBits2-DT,a4)
	move.l	(sourcestart-DT,a4),a0
C12410:
	move.l	(WORK_END-DT,a4),a2
	subq.w	#1,a2
	lea	(a2),a1
	cmp.b	#$FF,(a1)
	beq	C1252E
C12420:
	move.b	(SomeBits2Backup-DT,a4),(SomeBits2-DT,a4)
	exg	a0,a6
	jsr	(ShowAsmProgress).l
	exg	a0,a6
	bclr	#SB2_INDEBUGMODE,(SomeBits2-DT,a4)
	bset	#SB2_INSERTINSOURCE,(SomeBits2-DT,a4)
	move.b	(a0)+,d0
	beq.b	C12420
	cmp.b	#$2E,d0
	beq.b	C12420
	cmp.b	#$3D,d0
	beq.b	C12420
	cmp.b	#$3B,d0
	beq.b	C12420
	cmp.b	#$2A,d0
	beq.b	C12420
	cmp.b	#9,d0
	beq.b	C12420
	cmp.b	#SRCMARK_END,d0
	beq	C1252E
	subq.w	#1,a0
	move.l	a0,a3
C1246A:
	move.b	(a0)+,d0
	and.b	#$DF,d0
	move.b	-(a1),d1
	and.b	#$DF,d1
	cmp.b	d0,d1
	bne	C12516
	tst.b	(-1,a1)
	beq.b	C12484
	bra.b	C1246A

C12484:
	cmp.b	#$7C,(a0)
	beq.b	C1249E
	cmp.b	#$40,(a0)
	bcc.b	C12516
	cmp.b	#$30,(a0)
	bcs.b	C1249E
	cmp.b	#$39,(a0)
	bls.b	C12516
C1249E:
	tst.b	(B30172-DT,a4)
	beq.b	C124E2
	move.l	a0,-(sp)
	move.l	a1,-(sp)
C124A8:
	move.b	-(a0),d0
	beq.b	C124DE
	cmp.b	#9,d0
	beq.b	C124DE
	cmp.b	#SRCMARK_BEGIN,d0
	beq.b	C124DE
	lea	(B124CE,pc),a1
.C124C0
	tst.b	(a1)
	bmi.b	C124A8
	cmp.b	(a1)+,d0
	bne.b	.C124C0
C124DE:	move.l	(sp)+,a1
	addq.w	#1,a0
C124E2:
	move.l	a0,(FirstLinePtr-DT,a4)
	movem.l	d0-d7/a0-a6,-(sp)
	moveq	#0,d0
	lea	(CurrentAsmLine-DT,a4),a0
	bsr	printthetext
	bsr.w	Druk_Clearbuffer
	movem.l	(sp)+,d0-d7/a0-a6
	move.l	(FirstLinePtr-DT,a4),a0
	tst.b	(B30172-DT,a4)
	beq	C12410
	move.l	(sp)+,a0
	add.l	(L2FCEA-DT,a4),a0
	addq.l	#1,a0
	br	C12410

B124CE:	DC.B	' #+-=[,.*/<>(!',-1
	EVEN

C12516:
	moveq	#0,d0
	move.b	(a2),d0
	addq.w	#1,d0
	sub	d0,a2
	lea	(a2),a1
	cmp.b	#$FF,(a1)
	beq	C12410
	move.l	a3,a0
	br	C1246A

C1252E:
	bsr.w	Druk_Clearbuffer
	bclr	#SB2_INSERTINSOURCE,(SomeBits2-DT,a4)
	and.b	#~((1<<SB3_REPORT_ERROR)|(1<<SB3_SPEC_KEYS)),(SomeBits3-DT,a4)
	jsr	(Change2Commmenu)
	bset	#SB2_MATH_XN_OK,(SomeBits2-DT,a4)
	moveq	#0,d0
	br	com_top

C12566:	; com_extern
	bsr	GETNUMBERAFTEROK
	cmp.b	#NS_AVALUE,d1
	beq.b	C12572
	moveq	#0,d0
C12572:
	move.l	d0,-(sp)
	moveq	#0,d4
	move.l	(sourcestart-DT,a4),a6
	bra.b	C1259E

C1257C:
	addq.l	#4,sp
	lea	(HNoErrors.MSG,pc),a0
	br	printthetext

C12586:
	move.l	(DATA_CURRENTLINE-DT,a4),d4
	move.l	(DATA_LINE_START_PTR-DT,a4),a6
C1258E:
	REPT	3
	tst.b	(a6)+
	beq.b	C1259E
	ENDR
	tst.b	(a6)+
	bne.b	C1258E
C1259E:
	cmp.b	#SRCMARK_END,(a6)
	beq.b	C1257C
	addq.l	#1,d4
	move.l	a6,(DATA_LINE_START_PTR-DT,a4)
	move.l	d4,(DATA_CURRENTLINE-DT,a4)
	moveq	#0,d0
C125B0:
	move.b	(a6)+,d0
	tst.b	(Variable_base-DT,a4,d0.w)
	bmi.b	C125B0
	subq.w	#1,a6
	cmp.b	#'>',d0
	bne.b	C1258E
	addq.l	#1,a6
	jsr	NEXTSYMBOL_SPACE
	cmp.b	#NS_ALABEL,d1
	bne.b	C12586
	lea	(SourceCode-DT,a4),a0
	move.l	(a0)+,d0
	and.l	#$DFDFDFDF,d0
	cmp.l	#"EXTE",d0
	bne.b	C12586
	move	(a0)+,d0
	and	#$DFDF,d0
	cmp	#$D24E,d0	;RN
	bne.b	C12586
	bsr.w	RemoveWS
	subq.w	#1,a6
	cmp.b	#$22,d0
	beq.b	C1261E
	cmp.b	#$27,d0
	beq.b	C1261E
	cmp.b	#$60,d0
	beq.b	C1261E
	bsr	Convert_A2I_sub
	beq	ERROR_IllegalOperand
	move.l	(sp),d6
	beq.b	C1261A
	cmp.l	d3,d6
	bne	C12586
C1261A:
	bsr	Parse_GetKomma
C1261E:
	lea	(CurrentAsmLine-DT,a4),a1
	bsr	ASSEM_RETURN_STRING_UCASE
	beq	ERROR_IllegalOperand
	move.l	a6,-(sp)
	clr.l	(FileLength-DT,a4)
	bsr	OpenOldFile
	move.l	(sp)+,a6
	bsr	Parse_GetKomma
	bsr	Convert_A2I_sub
	beq.b	C12664
	move.l	d3,-(sp)
	moveq	#-1,d3
	bsr	PARSE_GET_KOMMA_IF_ANY
	bne.b	C12650
	bsr	Convert_A2I_sub
	beq.b	C12664
C12650:
	move.l	(sp)+,d2
	move.l	a6,-(sp)
	bsr	read_nr_d3_bytes
	bsr	close_bestand
	move.l	(sp)+,a6
	subq.w	#1,a6
	br	C12586

C12664:
	br	ERROR_IllegalOperand

com_terughalen:		; O (old source)
	moveq	#~32,d0
	and.b	(a6)+,d0
	cmp.b	#'S',d0
	bne.b	C12676
	move.b	(a6)+,d0
C12676:
	move.l	(sourcestart-DT,a4),a0
	cmp.b	#SRCMARK_END,(a0)
	bne.b	C12684
	move.b	#$3B,(a0)+
C12684:
	pea	(com_object_info,pc)
C12688:
	bclr	#SB2_INDEBUGMODE,(SomeBits2-DT,a4)
	move.l	(sourcestart-DT,a4),a0
	move.l	a0,a2
	move.l	(WORK_END-DT,a4),a1
	cmp.l	a0,a1
	beq.b	C126EA
	move.b	-(a1),d2
	move.b	#SRCMARK_END,(a1)+
	moveq	#$20,d1
	bra.b	C126AA

C126A6:
	moveq	#0,d0
C126A8:
	move.b	d0,(a2)+
C126AA:
	move.b	(a0)+,d0
	cmp.b	d1,d0
	bcc.b	C126A8
	cmp.b	#9,d0
	beq.b	C126A8
	tst.b	d0
	beq.b	C126A8
	cmp.b	#10,d0
	beq.b	C126A6
	cmp.b	#SRCMARK_END,d0
	bne.b	C126AA
	move.b	d2,-(a1)
	cmp.b	-(a0),d0
	bne.b	C126EA
	tst.b	(-1,a2)
	beq.b	C126DC
	cmp.b	#SRCMARK_BEGIN,(-1,a2)
	beq.b	C126DC
	clr.b	(a2)+
C126DC:
	move.l	a2,(sourceend-DT,a4)
	move.b	d0,(a2)+
	move.l	a2,(Cut_Blok_End-DT,a4)
	move.b	d0,(a2)
	rts

C126EA:
	move.l	(sourceend-DT,a4),a2
	pea	(ERROR_WorkspaceMemoryFull,pc)
	moveq	#SRCMARK_END,d0
	bra.b	C126DC

LINE_ASCIILINE:
	moveq	#~0,d0
	bsr	LINE_PARSE_AT_ARGS
	move.l	d0,a3
	moveq	#7,d6
C12744:
	move.l	a3,d0
	bsr	druk_af_d0_space
	moveq	#$22,d0
	bsr	SENDONECHARNORMAL
	move.l	a3,d5
	moveq	#$3F,d5
C12754:
	move.b	(a3)+,d0
	moveq	#$7f,d1
	and.b	d0,d1
	cmp.b	#$7F,d1
	beq.b	C12768
	cmp.b	#$20,d1
	bcc.b	C1276A
C12768:
	moveq	#$2E,d0
C1276A:
	bsr	SENDONECHARNORMAL
	dbra	d5,C12754
	moveq	#$22,d0
	bsr	SENDONECHARNORMAL
	bsr	druk_cr_nl
	dbra	d6,C12744
	move.l	a3,(MEM_DIS_DUMP_PTR-DT,a4)
	rts

C127AC:
	bsr	C11ABE
	bsr	INPUTBEGINEND
	move.l	d2,a3
	move.l	d0,a2
	bclr	#SB2_INDEBUGMODE,(SomeBits2-DT,a4)
	bset	#SB2_INSERTINSOURCE,(SomeBits2-DT,a4)
	move.l	(FirstLinePtr-DT,a4),-(sp)
C127CA:
	cmp.l	a3,a2
	bls.b	C12822
	move.b	(OpperantSize-DT,a4),d4
	ext.w	d4
	lsr.w	#1,d4
	mulu	#7,d4
	lea	(DCB.MSG,pc),a0
	add	d4,a0
	bsr	printthetext
	moveq	#0,d3
	moveq	#$10,d5
	tst	d4
	bne.b	C127EE
	lsr.w	#1,d5
C127EE:
	tst.b	d3
	beq.b	C127F8
	moveq	#$2C,d0
	bsr	SENDONECHARNORMAL
C127F8:
	moveq	#$24,d0
	bsr	SENDONECHARNORMAL
	move.b	(OpperantSize-DT,a4),d4
	ext.w	d4
	sub	d4,d5
	subq.w	#1,d4
C12808:
	move.b	(a3)+,d0
	bsr	C15908
	dbra	d4,C12808
	cmp.l	a3,a2
	bls.b	C12822
	moveq	#1,d3
	tst	d5
	bne.b	C127EE
	bsr	Druk_af_eol
	bra.b	C127CA

C12822:
	bsr	Druk_af_eol
	br	C128D4

C1282A:
	bsr	INPUTBEGINEND
	move.l	d2,a3
	move.l	d0,a2
	moveq	#0,d3
	bclr	#SB2_INDEBUGMODE,(SomeBits2-DT,a4)
	bset	#SB2_INSERTINSOURCE,(SomeBits2-DT,a4)
	move.l	(FirstLinePtr-DT,a4),-(sp)
C12846:
	cmp.l	a3,a2
	bls.w	C128CE
	lea	(DCB.MSG,pc),a0
	bsr	printthetext
	moveq	#$2F,d5
	moveq	#0,d3
C12858:
	cmp.l	a3,a2
	bls.b	C128CE
	move.b	(a3)+,d0
	move.b	d0,d2
	cmp.b	#$1F,d0
	bls.b	C1286C
	cmp.b	#$7F,d0
	bcs.b	C1289E
C1286C:
	tst.b	d3
	beq.b	C1287E
	cmp.b	#2,d3
	beq.b	C1287A
	moveq	#$27,d0
	bsr.b	C1289A
C1287A:
	moveq	#$2C,d0
	bsr.b	C1289A
C1287E:
	moveq	#$24,d0
	bsr.b	C1289A
	move.b	d2,d0
	bsr	C15908
	moveq	#2,d3
	tst.b	d2
	beq.b	C128BC
	cmp.b	#10,d2
	beq.b	C128BC
	subq.w	#5,d5
	bpl.b	C12858
	bra.b	C128BC

C1289A:
	br	SENDONECHARNORMAL

C1289E:
	move	d0,-(sp)
	cmp.b	#1,d3
	beq.b	C128B2
	tst.b	d3
	beq.b	C128AE
	moveq	#$2C,d0
	bsr.b	C1289A
C128AE:
	moveq	#$27,d0
	bsr.b	C1289A
C128B2:
	move	(sp)+,d0
	bsr.b	C1289A
	moveq	#1,d3
	dbra	d5,C12858
C128BC:
	bsr.b	C128C0
	bra.b	C12846

C128C0:
	cmp.b	#1,d3
	bne.b	C128CA
	moveq	#$27,d0
	bsr.b	C1289A
C128CA:
	br	Druk_af_eol

C128CE:
	bsr.b	C128C0
	move.l	a3,(MEM_DIS_DUMP_PTR-DT,a4)
C128D4:
	bsr.w	Druk_Clearbuffer
	move.l	(sp)+,(FirstLinePtr-DT,a4)
	rts

com_insert:
	move.b	(a6)+,d0
	move.b	d0,d3
	bclr	#5,d0
	cmp.b	#$48,d0
	beq	C127AC
	cmp.b	#$4E,d0
	beq	C1282A
	cmp.b	#$44,d0
	beq	Insert_Disassembly
	cmp.b	#$42,d0
	beq	C12044
	cmp.b	#'S',d0
	beq.b	com_insert_sin
	cmp.b	#$20,d3
	beq	C1823E
	tst.b	d0
	bne	ERROR_IllegalComman
	br	C181DA

com_insert_sin:
	moveq	#0,d0
	bra.b	com_create_sin\.Cont

com_create_sin:
	lea	(DEST.MSG,pc),a0
	bsr	Druk_MsgAf_GetNumbr
	bne.b	.Error
.Cont
	move.l	d0,(SinAddr-DT,a4)
	lea	(BEG.MSG,pc),a0
	bsr	Druk_MsgAf_GetNumbr
	bne.b	.Error
	move.l	d0,(SinBegin-DT,a4)
	lea	(END.MSG0,pc),a0
	bsr	Druk_MsgAf_GetNumbr
	bne.b	.Error
	move.l	d0,(SinEnd-DT,a4)
	lea	(AMOUNT.MSG,pc),a0
	bsr	Druk_MsgAf_GetNumbr
	bne.b	.Error
	move.l	d0,(SinAmount-DT,a4)
	beq.b	.Error
	lea	(AMPLITUDE.MSG,pc),a0
	bsr	Druk_MsgAf_GetNumbr
	bne.b	.Error
	move.l	d0,(SinAmp-DT,a4)
	lea	(YOFFSET.MSG,pc),a0
	bsr	Druk_MsgAf_GetNumbr
	bne.b	.Error
	move.l	d0,(SinYOff-DT,a4)
	lea	(SIZEBWL.MSG,pc),a0
	bsr	beeldtextaf
	bsr	GetHotKey
	bclr	#5,d0
	clr.b	(SinSize-DT,a4)		; b/w/l -> 0/1/2
	cmp.b	#'B',d0
	beq.b	.C129E2
	addq.b	#1,(SinSize-DT,a4)
	cmp.b	#'W',d0
	beq.b	.C129E2
	addq.b	#1,(SinSize-DT,a4)
	cmp.b	#'L',d0
	beq.b	.C129E2
.Error
	br	ERROR_Notdone

.C129E2
	lea	(MULTIPLIER.MSG,pc),a0
	bsr	Druk_MsgAf_GetNumbr
	bne.b	.Error
	move.l	d0,(SinMult-DT,a4)
	lea	(HALFCORRECTIO.MSG,pc),a0
	lea	(SinCorr-DT,a4),a2	; both correction flags
	bsr.b	.GetYesNo
	lea	(ROUNDCORRECTI.MSG,pc),a0
	bsr.b	.GetYesNo

	movem.l	d0-d7/a1-a6,-(sp)
	bsr.b	.C12A54
	movem.l	(sp)+,d0-d7/a1-a6
	br	beeldtextaf

.GetYesNo
	bsr	beeldtextaf
	bsr	GetHotKey
	bclr	#5,d0
	cmp.b	#'Y',d0
	seq	(a2)+
	beq.b	.YesNoOK
	cmp.b	#'N',d0
	bne.b	.Error
.YesNoOK
	rts

.C12A54	move.l	(4).w,a6
	lea	(MathffpName,pc),a1
	jsr	(_LVOOldOpenLibrary,a6)
	move.l	d0,(MathFfpBase-DT,a4)
	bne.b	.C12A6C
	lea	(Couldntopenma.MSG,pc),a0
	rts
.C12A6C	lea	(MathtransName,pc),a1
	jsr	(_LVOOldOpenLibrary,a6)
	move.l	d0,(MathTransBase-DT,a4)
	bne.b	.C12A88
	move.l	(MathFfpBase-DT,a4),a1
	jsr	(_LVOCloseLibrary,a6)
	lea	(Couldntopenma.MSG0,pc),a0
	rts

.C12A88
	move.b	(SomeBits2-DT,a4),-(sp)
	bclr	#SB2_INDEBUGMODE,(SomeBits2-DT,a4)
	bset	#SB2_INSERTINSOURCE,(SomeBits2-DT,a4)
	move.l	(FirstLinePtr-DT,a4),-(sp)
	moveq	#0,d3
	move.l	(MathFfpBase-DT,a4),a6
	move.l	(MathTransBase-DT,a4),a5
	move.l	(SinEnd-DT,a4),d0
	sub.l	(SinBegin-DT,a4),d0
	jsr	(_LVOSPFlt,a6)
	move.l	#$8EFA353B,d1
	jsr	(_LVOSPMul,a6)
	move.l	d0,-(sp)
	move.l	(SinAmount-DT,a4),d0
	jsr	(_LVOSPFlt,a6)
	move.l	d0,d1
	move.l	(sp)+,d0
	jsr	(_LVOSPDiv,a6)
	move.l	d0,(L2DF7C-DT,a4)
	move.l	(SinBegin-DT,a4),d0
	jsr	(_LVOSPFlt,a6)
	move.l	#$8EFA353B,d1
	jsr	(_LVOSPMul,a6)
	tst.b	(SinCorrHalf-DT,a4)
	beq.b	C12AF8
	move.l	(L2DF7C-DT,a4),d1
	subq.b	#1,d1
	jsr	(_LVOSPAdd,a6)
C12AF8:
	move.l	d0,(L2DF78-DT,a4)
	move.l	(SinAmp-DT,a4),d0
	jsr	(_LVOSPFlt,a6)
	move.l	d0,(L2DF80-DT,a4)
	move.l	(SinAmount-DT,a4),d7
	move.l	(SinAddr-DT,a4),a3
C12B10:
	move.l	(L2DF78-DT,a4),d0
	exg	a5,a6
	jsr	(_LVOSPSin,a6)
	exg	a5,a6
	move.l	(L2DF80-DT,a4),d1
	jsr	(_LVOSPMul,a6)
	tst.b	(SinCorrRound-DT,a4)
	beq.b	C12B42
	move.l	#$80000040,d1
	tst.b	d0	; bit7 set?
	bpl.b	C12B3E
	move.l	#$800000C0,d1
C12B3E:
	jsr	(_LVOSPAdd,a6)
C12B42:
	jsr	(_LVOSPFix,a6)
	add.l	(SinYOff-DT,a4),d0
	move.l	(SinMult-DT,a4),d2
	beq.b	C12B52
	muls	d2,d0
C12B52:
	cmp.l	a3,d3
	bne	C12C46
	tst.b	(SinSize-DT,a4)		; byte?
	bne.b	C12B9C
	move	d0,-(sp)
	tst	(SinAddr+2-DT,a4)
	bne.b	C12B72
	lea	(DCB.MSG,pc),a0
	bsr	printthetext
	bra.b	C12B78

C12B72:
	moveq	#$2C,d0
	bsr	SENDONECHARNORMAL
C12B78:
	moveq	#$24,d0
	bsr	SENDONECHARNORMAL
	move	(sp)+,d0
	bsr	C15908
	move	(SinAddr+2-DT,a4),d0
	addq.w	#1,d0
	and	#15,d0
	move	d0,(SinAddr+2-DT,a4)
	bne.b	C12B9C
	moveq	#1,d3
	bsr	Druk_af_eol
	moveq	#0,d3
C12B9C:
	cmp.b	#1,(SinSize-DT,a4)	; word?
	bne.b	C12BEA
	move	d0,-(sp)
	tst	(SinAddr+2-DT,a4)
	bne.b	C12BB6
	lea	(DCW.MSG,pc),a0
	bsr	printthetext
	bra.b	C12BBC

C12BB6:
	moveq	#$2C,d0
	bsr	SENDONECHARNORMAL
C12BBC:
	moveq	#$24,d0
	bsr	SENDONECHARNORMAL
	move.b	(sp),d0
	bsr	C15908
	move	(sp)+,d0
	bsr	C15908
	move	(SinAddr+2-DT,a4),d0
	addq.w	#1,d0
	move	d0,(SinAddr+2-DT,a4)
	cmp	#10,d0
	bne.b	C12BEA
	clr	(SinAddr+2-DT,a4)
	moveq	#1,d3
	bsr	Druk_af_eol
	moveq	#0,d3
C12BEA:
	cmp.b	#2,(SinSize-DT,a4)	; lword?
	bne.b	C12C64
	move.l	d0,-(sp)
	tst	(SinAddr+2-DT,a4)
	bne.b	C12C04
	lea	(DCL.MSG,pc),a0
	bsr	printthetext
	bra.b	C12C0A

C12C04:
	moveq	#$2C,d0
	bsr	SENDONECHARNORMAL
C12C0A:
	moveq	#$24,d0
	bsr	SENDONECHARNORMAL
	move.b	(sp),d0
	bsr	C15908
	move	(sp)+,d0
	bsr	C15908
	move.b	(sp),d0
	bsr	C15908
	move	(sp)+,d0
	bsr	C15908
	move	(SinAddr+2-DT,a4),d0
	addq.w	#1,d0
	move	d0,(SinAddr+2-DT,a4)
	cmp	#6,d0
	bne.b	C12C64
	clr	(SinAddr+2-DT,a4)
	moveq	#1,d3
	bsr	Druk_af_eol
	moveq	#0,d3
	bra.b	C12C64

C12C46:
	tst.b	(SinSize-DT,a4)		; byte?
	bne.b	C12C50
	move.b	d0,(a3)+
C12C50:
	cmp.b	#1,(SinSize-DT,a4)	; word?
	bne.b	C12C5A
	move	d0,(a3)+
C12C5A:
	cmp.b	#2,(SinSize-DT,a4)	; lword?
	bne.b	C12C64
	move.l	d0,(a3)+
C12C64:
	move.l	(L2DF78-DT,a4),d0
	move.l	(L2DF7C-DT,a4),d1
	jsr	(_LVOSPAdd,a6)
	move.l	d0,(L2DF78-DT,a4)
	subq.l	#1,d7
	bne	C12B10
	move.l	(4).w,a6
	move.l	(MathFfpBase-DT,a4),a1
	jsr	(_LVOCloseLibrary,a6)
	move.l	(MathTransBase-DT,a4),a1
	jsr	(_LVOCloseLibrary,a6)
	cmp.l	a3,d3
	bne.b	C12C9E
	moveq	#1,d3
	bsr	Druk_af_eol
	bsr	Druk_Clearbuffer
	bsr	Druk_af_eol

C12C9E:
	move.l	(sp)+,(FirstLinePtr-DT,a4)
	lea	(Sinuscreated.MSG,pc),a0
	move.b	(sp)+,(SomeBits2-DT,a4)
	rts

; ID command
Insert_Disassembly:
	bsr	INPUTBEGINEND
	bclr	#SB2_INDEBUGMODE,(SomeBits2-DT,a4)
	cmp	#PB_020,(ProcessorType-DT,a4)
	bge.b	C12CC6
	bclr	#0,d2
C12CC6:
	move.l	d2,a5
	move.l	d0,a3
	move.l	a5,(INSERT_START-DT,a4)
	move.l	a3,(INSERT_END-DT,a4)
	bset	#SB2_INSERTINSOURCE,(SomeBits2-DT,a4)
	move.l	(FirstLinePtr-DT,a4),-(sp)
C12CDC:
	move.l	a5,d0
	bsr	C158E4
	moveq	#9,d0
	bsr	SENDONECHARNORMAL
	moveq	#9,d0					; 2 tabs
	bsr	SENDONECHARNORMAL
	pea.l	(a3)
	jsr	(Disasm_OneLine).l
	bsr	printthetext
	bsr	Druk_af_eol
	move.l	(sp)+,a3
	cmp.l	a3,a5
	bcs.b	C12CDC

	move.l	a5,(MEM_DIS_DUMP_PTR-DT,a4)
	bsr.w	Druk_Clearbuffer
	bclr	#SB2_INSERTINSOURCE,(SomeBits2-DT,a4)
	lea	(Removeunusedl.MSG,pc),a0
	bsr	beeldtextaf
	bsr	GetHotKey
	move.l	(FirstLinePtr-DT,a4),a3
	move.l	(sp)+,a2
	lea	(a2),a5
	move.l	a2,(FirstLinePtr-DT,a4)
	cmp.b	#"Y",d0
	bne.b	NoRemoveLabels
C12D2C:
	moveq	#"L",d0
	moveq	#"B",d1
	moveq	#"_",d2
C12D32:
	cmp.l	a2,a3
	beq.w	C12D9A
	addq.w	#1,a2
C12D38:
	move.b	(a2)+,d3
	beq.b	C12D32
	cmp.b	d3,d0
	bne.b	C12D38
	cmp.b	(a2),d1
	bne.b	C12D38
	cmp.b	(1,a2),d2
	bne.b	C12D38
	addq.w	#2,a2

	move.b	(a2)+,d0			; search for address label
	move.b	(a2)+,d1			;
	move.b	(a2)+,d2			
	move.b	(a2)+,d3
	move.b	(a2)+,d4
	move.b	(a2)+,d5
	move.b	(a2)+,d6
	move.b	(a2),d7
	lea	(a5),a0				; first line
C12D56:
	cmp.l	a3,a0
	beq.b	C12D2C
	addq.w	#3,a0
	cmp.b	(a0),d0
	bne.b	C12D7A
	cmp.b	(1,a0),d1
	bne.b	C12D7A
	cmp.b	(2,a0),d2
	bne.b	C12D7A
	cmp.b	(3,a0),d3
	bne.b	C12D7A
	cmp.b	(4,a0),d4				;;
	bne.b	C12D7A					;;
	cmp.b	(5,a0),d5				;;
	bne.b	C12D7A					;;
	cmp.b	(6,a0),d6				;;
	bne.b	C12D7A					;;
	cmp.b	(7,a0),d7				;;
	bne.b	C12D7A					;;
	bset	#5,(-3,a0)
	bra.b	C12D2C

C12D7A:
	bcs.b	C12D2C
C12D7C:
	tst.b	(a0)+
	bne.b	C12D7C
	bra.b	C12D56

NoRemoveLabels:
	movem.l	a2/a3/a5,-(sp)
	lea	(a5),a2
C12D88:
	cmp.l	a3,a5
	beq.b	C12D96
	bset	#5,(a5)
C12D90:
	tst.b	(a5)+
	bne.b	C12D90
	bra.b	C12D88

C12D96:
	movem.l	(sp)+,a2/a3/a5
C12D9A:
	moveq	#" ",d1
	lea	(a5),a2
	cmp.l	a3,a5
	beq.b	C12DCA
	bset	#5,(a5)
C12DA6:
	cmp.l	a3,a5
	beq.b	C12DCA
	bclr	#5,(a5)
	bne.b	C12DB2
	lea	10(a5),a5			; pass label and replace
	move.b	#9,(a5)				; last char with tab
C12DB2:
	move.b	(a5)+,d0
	cmp.b	d1,d0				; replace space with tab
	beq.b	C12DBE
C12DB8:
	move.b	d0,(a2)+
	bne.b	C12DB2
	bra.b	C12DA6

C12DBE:
	move.b	#9,(a2)+
C12DC2:
	move.b	(a5)+,d0
	cmp.b	d1,d0
	beq.b	C12DC2
	bra.b	C12DB8

C12DCA:
	move.l	(Cut_Blok_End-DT,a4),a0
	move.l	a3,d1
	sub.l	a2,d1
	jsr	(MOVEMARKS).l
	jmp	(cut_block).l

com_show_regs:
	tst.b	(a6)
	bne	LINE_REG_SPECIFIC
LINE_REGPRINT:
	lea	(D0.MSG,pc),a0
	lea	(DataRegsStore-DT,a4),a1
	lea	(DataRegsStore_Old-DT,a4),a2
	bsr	printthetext

	moveq	#8-1,d3
.datalopje:
	bsr	convert_getal
	bsr	druk_af_space
	dbra	d3,.datalopje

	bsr	printthetext
	moveq	#7-1,d3
.adrlopje:
	bsr	convert_getal
	bsr	druk_af_space
	dbra	d3,.adrlopje

	move.l	(a1),d0			; a7, get ssp first
	move.l	(a2),d1
	btst	#13-8,(statusreg_base-DT,a4)	; sv flag
	bne.b	.in_sv
	move.l	(4,a1),d0		; user mode, get usp instead
	move.l	(4,a2),d1
.in_sv	bsr	REGP_PRINTFORMATTED3	; a7
	bsr	druk_af_space
	bsr	printthetext		; ssp
	bsr	convert_getal
	bsr	druk_af_space
	bsr	printthetext		; usp
	bsr	convert_getal
	bsr	druk_af_space
	bsr	printthetext		; sr
	bsr	REGP_PRINT_SR_HEX
	bsr	druk_af_space
	bsr	REGP_PRINT_SR_T1
	bsr	REGP_PRINT_SR_PL
	bsr	druk_af_space
	bsr	REGP_PRINT_SR_FLAGS
	bsr	printthetext		; pc
	move.l	(a1),a5
	bsr	debug_regs2old
	move.l	a5,d0
	cmp.l	#eop_irq_routine,d0
	beq	C1315E

	bsr	druk_af_d0
	tst	(ProcessorType-DT,a4)
	beq.b	C12ED8
	move.l	a0,-(sp)
	bsr.w	druk_af_space
	lea	(VBR.MSG,pc),a0
	bsr	printthetext
	move.l	(VBR_base_ofzo-DT,a4),d0
	move.l	(VBR_Base2-DT,a4),d1
	bsr	REGP_PRINTFORMATTED3
	bsr	druk_af_space

	tst	(FPU_Type-DT,a4)
	beq.b	.NoFPU
	tst.b	(PR_FPU_Present)
	beq.b	.NoFPU
	bsr.b	C12EFC
	bsr	C12F70
	bsr	C1307E
	bsr	C12FB4
	bsr	C12F9E
	bsr	C130D6
	bsr	C13012
	bsr	C130F6
.NoFPU
	move.l	(sp)+,a0
C12ED8:
	bsr	druk_cr_nl
	bsr	printthetext
	move.l	a5,d0
	bsr	druk_af_d0
	bsr	druk_af_space
	bsr	C1588E
	jsr	(DISASSEMBLE_A5_PRINT)
	bsr	printthetext
	br	druk_cr_nl

C12EFC:
	bsr	druk_cr_nl
	lea	(FPCR.MSG,pc),a0
	bsr	printthetext

	move.l	(fpu_1-DT,a4),d0
	move.l	(fpu_1_old-DT,a4),d1
	cmp.l	d0,d1
	beq.b	C12F48
	bsr	get_inverse_font
	bsr	C15900
	bsr	get_normal_font
	moveq	#4,d7
C12F2A:
	bsr	druk_af_space
	dbra	d7,C12F2A
	lea	(BSUN.MSG,pc),a0
	move.l	(fpu_1-DT,a4),d2
	move.l	(fpu_1_old-DT,a4),d3
	moveq	#15,d1
	moveq	#7,d7
	br	C13096

C12F48:
	bsr	C15900
	move.l	d7,-(sp)
	moveq	#4,d7
C12F50:
	bsr	druk_af_space
	dbra	d7,C12F50
	move.l	(sp)+,d7
	lea	(BSUN.MSG,pc),a0
	move.l	(fpu_1-DT,a4),d2
	move.l	(fpu_1_old-DT,a4),d3
	moveq	#15,d1
	moveq	#7,d7
	br	C13096

C12F70:
	bsr	Druk_Clearbuffer
	bsr	druk_cr_nl
	lea	(FPSR.MSG,pc),a0
	bsr	printthetext
	move.l	(fpu_2-DT,a4),d0
	move.l	(fpu_2_old-DT,a4),d1
	bsr	REGP_PRINTFORMATTED3
	bsr	druk_af_space
	move.l	(fpu_2-DT,a4),d2
	move.l	(fpu_2_old-DT,a4),d3
	moveq	#15,d1
	moveq	#7,d7
	br	C13096

C12F9E:
	lea	(IOP.MSG,pc),a0
	move.l	(fpu_2-DT,a4),d2
	move.l	(fpu_2_old-DT,a4),d3
	moveq	#7,d1
	moveq	#4,d7
	br	C13096

C12FB4:
	bsr	printthetext
	move	(fpu_2-DT,a4),d1
	move	(fpu_2_old-DT,a4),d2
	cmp	d1,d2
	beq.b	.C12FD0
	pea	(C12FE2,pc)
	bsr	get_inverse_font
.C12FD0
	moveq	#'0',d0
	tst.w	d1
	bpl.b	.pos
	addq.b	#1,d0
.pos	bsr	SENDONECHARNORMAL
	bra.b	C12FE6

C12FE2:
	bsr	get_normal_font
C12FE6:
	bsr	printthetext
	moveq	#$7f,d0
	and.w	(fpu_2-DT,a4),d0
	moveq	#$7f,d1
	and.w	(fpu_2_old-DT,a4),d1
	cmp.b	d0,d1
	beq.b	.C1300A
	pea	(.C1300E,pc)
	bsr	get_inverse_font
.C1300A	br	C15908
.C1300E	br	get_normal_font

C13012:	; print rounding mode and precision
	lea	(PRECISION.MSG,pc),a0
	bsr	printthetext
	move.l	(fpu_1-DT,a4),d1	; fpsr
	lsr.w	#4,d1
	moveq	#3,d2
	and.b	d1,d2		; mode
	lsr.w	#2,d1
	and.w	#3,d1		; precision
	move.b	(.map_m,pc,d1.w),d0
	bsr	SENDONECHARNORMAL
	bsr	printthetext
	moveq	#'R',d0
	bsr	SENDONECHARNORMAL
	move.b	(.map_p,pc,d2.w),d0
	bra	SENDONECHARNORMAL

.map_m	DC.B	'XSDU'		; extended, single, double, undefined
.map_p	DC.B	'NZMP'		; nearest, zero, -inf, +inf

C1307E:
	lea	(N.MSG,pc),a0
	move.l	(fpu_2-DT,a4),d2
	move.l	(fpu_2_old-DT,a4),d3
	moveq	#$1B,d1
	moveq	#3,d7
C13096:
	movem.l	d0-d3/d7,-(sp)
C1309A:
	bsr	printthetext
	moveq	#$31,d0
	btst	d1,d2
	beq.b	C130C0
	btst	d1,d3
	bne.b	C130C6
C130A8:
	bsr	get_inverse_font
	bsr	SENDONECHARNORMAL
	bsr	get_normal_font
	subq.w	#1,d1
	dbra	d7,C1309A
	bra.b	C130D0

C130C0:
	moveq	#$30,d0
	btst	d1,d3
	bne.b	C130A8
C130C6:
	bsr	SENDONECHARNORMAL
	subq.w	#1,d1
	dbra	d7,C1309A
C130D0:
	movem.l	(sp)+,d0-d3/d7
	rts

C130D6:
	bsr	druk_cr_nl
	lea	(FPIAR.MSG,pc),a0
	bsr	printthetext
	move.l	(fpu_3-DT,a4),d0
	move.l	(fpu_3_old-DT,a4),d1
	bsr	REGP_PRINTFORMATTED3
	bra	druk_af_space

C130F6:
	fmovem.x	fp0/fp1,-(sp)
	movem.l	d6/d7/a0-a2,-(sp)
	lea	(FP0.MSG,pc),a0
	lea	(FpuRegsStore-DT,a4),a1
	lea	(FpuRegsStore_Old-DT,a4),a2
	moveq	#1,d6
C1310E:
	bsr	printthetext
	moveq	#3,d7
C13114:
	fmove.x	(a1)+,fp0
	fmove.x	(a2)+,fp1
	fcmp.x	fp0,fp1
	fbeq	C13132
	bsr	get_inverse_font
	bsr	C15B0A
	bsr	get_normal_font
	bra.b	C13136

C13132:
	bsr	C15B0A
C13136:
	move.l	a0,-(sp)
	lea	(B30053-DT,a4),a0
	bsr	printthetext
	bsr	druk_af_space
	bsr	druk_af_space
	move.l	(sp)+,a0
	dbra	d7,C13114
	dbra	d6,C1310E
	movem.l	(sp)+,d6/d7/a0-a2
	fmovem.x	(sp)+,fp0/fp1
	rts

C1315E:
	lea	(EOP.MSG,pc),a0
	bsr	printthetext
	tst	(ProcessorType-DT,a4)
	beq.b	C1318C
	bsr.w	druk_af_space
	lea	(VBR.MSG,pc),a0
	bsr	printthetext
	move.l	(VBR_base_ofzo-DT,a4),d0
	move.l	(VBR_Base2-DT,a4),d1
	bsr	REGP_PRINTFORMATTED3
	bsr	druk_af_space
C1318C:
	tst	(FPU_Type-DT,a4)
	beq.b	C131BA
	tst.b	(PR_FPU_Present).l
	beq.b	C131BA
	bsr	C12EFC
	bsr	C12F70
	bsr	C1307E
	bsr	C12FB4
	bsr	C12F9E
	bsr	C130D6
	bsr	C13012
	bsr	C130F6
C131BA:
	br	druk_cr_nl

REGP_PRINT_SR_HEX:
	move	(a1)+,d1	;new
	move	(a2)+,d2	;old
	move	d1,d0
	eor.w	d1,d2
	beq.b	C131D6
	bsr	get_inverse_font
	bsr.b	C131D6
	br	get_normal_font
C131D6:
	br	C15900

REGP_PRINT_SR_T1:
	bsr.b	REGP_PRINTFORMATTED2
	lsl.w	#1,d1
	lsl.w	#1,d2
	bra.b	REGP_PRINTFORMATTED2

REGP_PRINT_SR_PL:
	rol.w	#5,d1
	and.b	#7,d1
	rol.w	#5,d2
	and.b	#7,d2
	beq.b	.C131F4
	bsr	get_inverse_font
.C131F4	bsr	printthetext
	moveq	#'0',d0
	add.b	d1,d0
	bsr	SENDONECHARNORMAL
	tst.b	d2
	beq.b	.C1320A
	bsr	get_normal_font
.C1320A	rts

REGP_PRINT_SR_FLAGS:
	lsl.w	#3,d1		;???
	lsl.w	#3,d2
	moveq	#4,d3
C13212:
	move.b	(a0)+,d0
	add	d1,d1
	bcs.b	.geenmin
	moveq	#'-',d0
.geenmin:
	lsl.w	#1,d2
	bcc.b	C13230
	bsr	get_inverse_font
	bsr	SENDONECHARNORMAL
	bsr	get_normal_font
	bra.b	C13234
C13230:
	bsr	SENDONECHARNORMAL
C13234:
	dbra	d3,C13212
	rts

REGP_PRINTFORMATTED2:
	move.l	a0,-(sp)
	lsl.w	#1,d1
	bcs.b	.C13242
	addq.w	#3,a0
.C13242	lsl.w	#1,d2
	bcs.b	.C13254
	bsr	printthetext
	bsr	druk_af_space
	move.l	(sp)+,a0
	addq.w	#6,a0
	rts
.C13254	bsr	get_inverse_font
	bsr	printthetext
	bsr	get_normal_font
	bsr	druk_af_space
	move.l	(sp)+,a0
	addq.w	#6,a0
	rts

;************ conv FP regs voor debug win ************

convert_fpgetal_debug:
	fmovem.x	fp0/fp1,-(sp)
	movem.l	d0-a6,-(sp)
	fmovem	fpcr/fpsr/fpiar,-(sp)

	pea	(.en_weer_terug,pc)
	fmove.x	(a1),fp0
	fmove.x	(a2),fp1
	fcmp.x	fp0,fp1
	fbgl.w	debug_changefp
	bra.b	debug_drukfp

.en_weer_terug:
	fmovem	(sp)+,fpcr/fpsr/fpiar

	movem.l	(sp)+,d0-a6
	lea	(12,a1),a1
	lea	(12,a2),a2
	fmovem.x	(sp)+,fp0/fp1
	rts

debug_changefp:
	bsr	get_inverse_font
	bsr.b	debug_drukfp
	bra.w	get_normal_font

debug_drukfp:
	lea	(adrtxtbuf,pc),a5

	bsr	C15B0A
	lea	(B30053-DT,a4),a1
	moveq	#16,d1
	moveq	#0,d0
.fp_loopje:
	move.b	(a1)+,d0
	beq.b	.is_nul
	move.b	d0,(a5)+

	dbra	d1,.fp_loopje
.is_nul:
	cmp.l	#L30062,a1
	bne.b	.nog_niet
	moveq	#' ',d0
	move.b	d0,(a5)+

.nog_niet:
	clr.b	(a5)+
	bra	druk_af_now

;******** converteer getal voor de debugger ********

convert_getal_debug2:
	bsr	get_font_debug1
	moveq	#0,d0
	move.w	(a1)+,d0	;nieuwe waarde
	cmp.w	(a2)+,d0	;oudewaarde
	beq.s	.noinverse
	bsr	get_font_debug2
.noinverse:
	movem.l	d0-a6,-(sp)
	lea	(adrtxtbuf,pc),a5
	moveq	#4-1,d7
.lopje:
	divu.w	#16,d0
	swap	d0
	add.b	#'0',d0
	cmp.b	#'9',d0
	bls.s	.nosweat
	addq.b	#7,d0
.nosweat:
	move.b	d0,(a5,d7.w)
	clr.w	d0
	swap	d0
	dbf	d7,.lopje
	clr.b	4(a5)

	movem.l	(sp)+,d0-a6
	bra.b	druk_af_now


convert_getal_debug:
	bsr	get_font_debug1
	move.l	(a1)+,d0	;nieuwe waarde
	cmp.l	(a2)+,d0	;oudewaarde
	beq.s	.noinverse
	bsr	get_font_debug2
.noinverse:

convert_getal_debug_d0:
	movem.l	d0-a6,-(sp)
	lea	(adrtxtbuf,pc),a5
	moveq	#0,d1
	move.w	d0,d1
	clr.w	d0
	swap	d0
	moveq	#4-1,d7
.lopje:
	divu.w	#16,d0
	swap	d0
	add.b	#'0',d0
	cmp.b	#'9',d0
	bls.s	.nosweat
	addq.b	#7,d0
.nosweat:
	move.b	d0,(a5,d7.w)
	clr.w	d0
	swap	d0

	divu.w	#16,d1
	swap	d1
	add.b	#'0',d1
	cmp.b	#'9',d1
	bls.s	.nosweat2
	addq.b	#7,d1
.nosweat2:
	move.b	d1,4(a5,d7.w)
	clr.w	d1
	swap	d1
	dbf	d7,.lopje

	clr.b	8(a5)
	movem.l	(sp)+,d0-a6

druk_af_now:
	movem.l	d0-a6,-(sp)
	move.l	(IntBase-DT,a4),a6

	moveq	#5,d0
	mulu.w	(EFontSize_x-DT,a4),d0

	clr.w	d1		;top
	move.l	(debug_rp-DT,a4),a0	;rp
	lea	Debug_adrtxt(pc),a1	;itext
	jsr	_LVOPrintIText(a6)	;printitext

	move.w	(EFontSize_y-DT,a4),d0
	add.w	d0,adryoff

	movem.l	(sp)+,d0-a6
	rts

debug_print_xy:
	move.l	a0,srtxtptr
	move.l	(IntBase-DT,a4),a6
	move.l	(debug_rp-DT,a4),a0	;rp
	lea	sr_Text(pc),a1		;itext
	jmp	_LVOPrintIText(a6)	;printitext

strt1:	dc.b	"--",0
	dc.b	"T1",0
	dc.b	"--",0
	dc.b	"S1",0

bitslet:
	dc.b	"XNZVC"
srtxtbuf:
	dc.b	"!!!!!!",0

	EVEN
sr_Text:
srpens:	DC.B	1,0
	DC.B	1
	DC.B	0
sr_x:	DC.W	3,3
	DC.L	Editor_Font
srtxtptr:
	DC.L	srtxtbuf
	DC.L	0

debug_sr_stuff:
	movem.l	d0-a6,-(sp)

	move.w	d1,d0
	eor.w	d2,d0
	movem.w	d0-d2,-(sp)

	lsl.w	#3,d1
	lsl.w	#3,d2

	lea	(adrtxtbuf,pc),a0
	rol.w	#5,d1
	and.b	#7,d1
	rol.w	#5,d2
	and.b	#7,d2
	beq.b	.nif
	move.w	#2<<8+1,(srpens-adrtxtbuf,a0)
.nif	add.b	#'0',d1
	lsl.w	#8,d1

	move.w	d1,(a0)

	moveq	#12,d0
	mulu.w	(EFontSize_x-DT,a4),d0
	moveq	#19,d1
	mulu.w	(EFontSize_y-DT,a4),d1

	bsr	debug_print_xy	;PL=0	interupt priority mask (priority level?)

	movem.w	(sp)+,d0-d2

	moveq	#3,d5
	mulu.w	(EFontSize_x-DT,a4),d5

	lea	(strt1,pc),a0
	move.w	#1<<8+0,(srpens-strt1,a0)
	tst.w	d0
	bpl.s	.not2
	move.w	#2<<8+1,(srpens-strt1,a0)
.not2	move.w	#3,(sr_x-strt1,a0)	;marge

;	lea	(strt1,pc),a0
	bsr	.gop

	add.w	d0,d0
	add.w	d1,d1
	add.w	d2,d2

	lea	(strt1+6,pc),a0
	move.w	#1<<8+0,(srpens-(strt1+6),a0)
	tst.w	d0
	bpl.s	.not3
	move.w	#2<<8+1,(srpens-(strt1+6),a0)
.not3	add.w	d5,(sr_x-(strt1+6),a0)
	bsr.b	.gop

	add.w	d0,d0
	add.w	d1,d1
	add.w	d2,d2

	bsr.b	.stbits		; status bits -> charakter

	movem.l	(sp)+,d0-a6
	rts

.stbits:
	add.w	d5,sr_x
	lea	(srtxtbuf,pc),a2
	lea	(bitslet,pc),a3
	clr.b	1(a2)
	moveq	#5-1,d7
.bitlopje:
	add.w	d0,d0
	add.w	d1,d1
	add.w	d2,d2

	addq.l	#1,a3
	move.b	#'-',(a2)
	tst.b	d1
	bpl.b	.notset
	move.b	-1(a3),(a2)
.notset:
	move.w	#1<<8+0,(srpens)
	tst.b	d0
	bpl.s	.not4
	move.w	#2<<8+1,(srpens)
.not4:
	move.l	a2,a0
	bsr.b	.not1

	move.w	(EFontSize_x-DT,a4),d5
	add.w	d5,sr_x
	dbf	d7,.bitlopje
	rts

.gop:
	tst.w	d1
	bpl.s	.not1
	addq.l	#3,a0
.not1:
	movem.l	d0-d2,-(sp)

	move.w	(EFontSize_x-DT,a4),d0
	add.w	d0,d0

	moveq	#19,d1
	mulu.w	(EFontSize_y-DT,a4),d1

	bsr	debug_print_xy		;T1 S1
	movem.l	(sp)+,d0-d2
	rts


get_font_debug1:
	move.w	#1<<8+0,(db_pens)
	rts

get_font_debug2:
	move.w	#2<<8+1,(db_pens)
	rts

;********************************************************

convert_getal:
	move.l	(a1)+,d0	;new value
	cmp.l	(a2)+,d0	;old value
	bne.b	C132F8		;print inverse
C132F4:
	br	druk_af_d0	;print normal

REGP_PRINTFORMATTED3:
	cmp.l	d0,d1
	beq.b	C132F4

C132F8:
	bsr.b	get_inverse_font
	bsr	druk_af_d0

get_normal_font:
	moveq	#$9B-256,d0
	bsr	SENDONECHARNORMAL
	moveq	#$30,d0
	bsr	SENDONECHARNORMAL
	moveq	#$6D,d0
	br	SENDONECHARNORMAL

get_inverse_font:
	move.l	d0,-(sp)
	moveq	#$9B-256,d0
	bsr	SENDONECHARNORMAL
	moveq	#$34,d0
	bsr	SENDONECHARNORMAL
	moveq	#$6D,d0
	bsr	SENDONECHARNORMAL
	move.l	(sp)+,d0
	rts

debug_regs2old:
	lea	(DataRegsStore-DT,a4),a1
	lea	(DataRegsStore_Old-DT,a4),a2
	moveq	#18*2+1-1,d0
C13332:
	move	(a1)+,(a2)+
	dbra	d0,C13332
	tst	(FPU_Type-DT,a4)
	beq.b	C13360
	lea	(FpuRegsStore-DT,a4),a1
	lea	(FpuRegsStore_Old-DT,a4),a2
	moveq	#8*3-1,d0
C13348:
	move.l	(a1)+,(a2)+
	dbra	d0,C13348
	move.l	(fpu_1-DT,a4),(fpu_1_old-DT,a4)
	move.l	(fpu_2-DT,a4),(fpu_2_old-DT,a4)
	move.l	(fpu_3-DT,a4),(fpu_3_old-DT,a4)
C13360:
	move.l	(VBR_base_ofzo-DT,a4),(VBR_Base2-DT,a4)

no_dbg_window:
	rts

druk_af_debug_regs:
	tst.l	(debug_winbase-DT,a4)
	beq.b	no_dbg_window
; 	bsr.w	Print_Flush
	tst.b	(debug_FPregs-DT,a4)
	beq.b	.debug_regs_normal

	lea	(HFP0.MSG,pc),a0
	lea	(FpuRegsStore-DT,a4),a1
	lea	(FpuRegsStore_Old-DT,a4),a2
	moveq	#8-1,d3
.debug_FpuRegs:
;	bsr	printthetext
	bsr	convert_fpgetal_debug		;zet om fpu-regs en display...
	dbra	d3,.debug_FpuRegs

	lea	(HA0.MSG,pc),a0
	lea	(AdresRegsStore-DT,a4),a1
	lea	(AdrRegsStore_Old-DT,a4),a2
	moveq	#7-1,d3
	bra.b	.skip_dataregs

.debug_regs_normal:
	lea	(HD0.MSG,pc),a0
	lea	(DataRegsStore-DT,a4),a1
	lea	(DataRegsStore_Old-DT,a4),a2
	moveq	#8+7-1,d3
.skip_dataregs:
	bsr	convert_getal_debug
	dbra	d3,.skip_dataregs
	movem.l	a1/a2,-(sp)
	btst	#13-8,(statusreg_base-DT,a4)
	bne.b	.in_sv
	addq.l	#4,a1		; user mode, get usp instead of ssp
	addq.l	#4,a2
.in_sv
	bsr	convert_getal_debug	; a7
	movem.l	(sp)+,a1/a2

	bsr	convert_getal_debug	; ssp
	bsr	convert_getal_debug	; usp
	bsr	convert_getal_debug2	; sr

	add.w	d5,adryoff
	move.w	-2(a1),d1
	move.w	-2(a2),d2
	bsr	debug_sr_stuff		; sr flags

	bsr	get_font_debug1

	move.l	(a1),a5
	bsr	debug_regs2old
	move.l	a5,d0

	cmp.l	#eop_irq_routine,d0
	beq.b	deb_eop
	bsr	convert_getal_debug_d0	;PC
;	bsr	druk_af_d0		;PC
	bra.b	deb_no_eop

deb_eop:
	move.l	a0,-(sp)
	lea	(EOP.MSG,pc),a0
	move.l	a0,(adrtxtptr-EOP.MSG,a0)
	bsr	druk_af_now
	lea	(adrtxtbuf,pc),a0
	move.l	a0,(adrtxtptr-adrtxtbuf,a0)
	move.l	(sp)+,a0

deb_no_eop:
	tst	(ProcessorType-DT,a4)
	beq.b	.iseen68000
;	bsr	printthetext
	move.l	(VBR_base_ofzo-DT,a4),d0	;VBR
;	bsr	druk_af_d0
	bsr	convert_getal_debug_d0
.iseen68000:
;	bsr	printthetext
	move.l	(fpu_2-DT,a4),d0
;	move.l	(fpu_2_old-DT,a4),d1
;	bsr	REGP_PRINTFORMATTED3
	bsr	convert_getal_debug_d0

;print PCR register van de 68060 af
	cmp.w	#PB_060,(ProcessorType-DT,a4)
	blo.s	.geen060Plus
	bsr.b	Get_PCR
	bsr	convert_getal_debug_d0
.geen060Plus:
	rts

Get_PCR:
	movem.l	a5/a6,-(sp)
	lea	(.super,pc),a5
	move.l	4.w,a6
	jsr	(_LVOSupervisor,a6)
	movem.l	(sp)+,a5/a6
	rts
.super	movec	PCR,d0
	rte

;	dc.b	'Smiths kwaliteitsgarantie hamka''s rulzz !!!',0

LINE_TEXT_FINDREG_NAME:
	lea	(SourceCode-DT,a4),a3
	move	(a3),d1
	bpl.b	.GetAny
	and	#$DFDF,d1
	moveq	#~7,d0
	and	d1,d0
	sub	d0,d1
	cmp	#'D0'&$DFDF+$8000,d0
	beq.b	.Found
	addq.b	#8,d1
	cmp	#'A0'&$DFDF+$8000,d0
	bne.b	.GetAny
.Found	lsl.w	#2,d1
	move	#$0400,d6
	or.w	d1,d6
	bra.b	.Found2

.GetAny	lea	(REGS_REGISTER_NAMES,pc),a0
	jsr	(ASSEM_RECOGNIZE_ANY_CMD)
	beq	ERROR_UndefSymbol
.Found2	cmp	#$043C,d6			; sp?
	bne.b	.SvMode
	btst	#13-8,(statusreg_base-DT,a4)	; sv flag
	bne.b	.SvMode
	addq.w	#$0440-$043c,d6			; make it usp
.SvMode	move	d6,d0
	lsr.w	#8,d0
	and	#7,d0
	move.b	d0,(OpperantSize-DT,a4)
	lea	(DataRegsStore-DT,a4),a1
	ext.w	d6
	add	d6,a1
	moveq	#0,d6
	rts

LINE_REG_SPECIFIC:
	move.l	a6,-(sp)
	jsr	(NEXTSYMBOL)
	clr.b	(a6)
	bsr.b	LINE_TEXT_FINDREG_NAME
	move.l	(sp)+,a0
	bsr	printthetext
	bsr	druk_af_space
	move.l	a1,a5
	bsr	C137CC
	br	druk_cr_nl

REGS_REGISTER_NAMES:
	DR.W	.NAMES-4,.NAMES_LAST
.NAMES_LAST
	DC.W	'SR'+$8000
	DR.W	.SR
	DC.W	'SP'+$8000
	DR.W	.SP
	DC.W	'PC'+$8000
	DR.W	.PC
.NAMES	DC.W	'US'
	DR.W	.US-4,.US_END
	DC.W	'SS'
	DR.W	.SS-4,.SS_END
	DC.W	0

.SS_END	DC.W	'P'<<8+$8000
	DR.W	.SSP
.SS	DC.W	0

.US_END	DC.W	'P'<<8+$8000
	DR.W	.USP
.US	DC.W	0

.PC	DC.W	$0446
.SR	DC.W	$0244
.SSP	DC.W	$143C
.USP	DC.W	$0440
.SP	DC.W	$043C

com_calc_float:
	movem.l	d0-d2/a0,-(sp)
	tst	(FPU_Type-DT,a4)
	beq	ERROR_FPUneededforopp
	clr.l	(LastCalcFpsr-DT,a4)
	fmove.x	fp0,-(sp)
	bsr	C11B36
	bsr	C15B0A
	lea	(B30053-DT,a4),a0
	bsr	printthetext
	bsr	druk_af_space
	bsr	druk_af_space
	moveq	#$24,d0		;$
	bsr	SENDONECHARNORMAL
	fmove.d	(D02F260-DT,a4),fp0
	fmove.s	fp0,(D02F260-DT,a4)
	moveq	#$53,d0		;S
	moveq	#0,d1
	cmp.b	#$71,(OpperantSize-DT,a4)
	beq.b	C135DA
	fmove.d	fp0,(D02F260-DT,a4)
	moveq	#$44,d0		;D
	moveq	#1,d1
	cmp.b	#$75,(OpperantSize-DT,a4)
	beq.b	C135DA
	fmove.x	fp0,(D02F260-DT,a4)
	moveq	#$58,d0		;X
	moveq	#2,d1
	cmp.b	#$72,(OpperantSize-DT,a4)
	beq.b	C135DA
	fmove.p	fp0,(D02F260-DT,a4){#0}
	moveq	#$50,d0		;P
	moveq	#2,d1
C135DA:
	move.l	d0,-(sp)
	lea	(D02F260-DT,a4),a0
C135E0:
	move.l	(a0)+,d0
	bsr	druk_af_d0
	dbra	d1,C135E0
	moveq	#'.',d0
	bsr	SENDONECHARNORMAL
	move.l	(sp)+,d0
	bsr	SENDONECHARNORMAL
	fmove.x	(sp)+,fp0
	movem.l	(sp)+,d0-d2/a0
	br	druk_cr_nl

com_calculator:
	move.l	d0,d1
	moveq	#'$',d0
	bsr	SENDONECHARNORMAL
	move.l	d1,d0
	bsr	druk_af_d0
	bsr	druk_af_space
	move.l	d1,d0
	move.l	d1,-(sp)
	bsr	PRINTDECIMALSIGN
	move.l	(sp)+,d1
	bsr	druk_af_space
	moveq	#'"',d0
	bsr	SENDONECHARNORMAL
	movem.l	d1/d2,-(sp)
	moveq	#3,d2
C1362E:
	rol.l	#8,d1
	moveq	#$7f,d0
	and.b	d1,d0
	cmp.b	#' ',d0
	bcc.b	C13640
	move.b	#'.',d1
C13640:
	move.b	d1,d0
	bsr	SENDONECHARNORMAL
	dbra	d2,C1362E
	movem.l	(sp)+,d1/d2
	moveq	#'"',d0
	bsr	SENDONECHARNORMAL
	bsr	druk_af_space
	moveq	#'%',d0
	bsr	SENDONECHARNORMAL
	bsr.b	Print_D0_Binary
	br	druk_cr_nl

Print_D0_Binary:
	movem.l	d1/d2,-(sp)
	bsr.b	.FirstByte
	bsr.b	.NextByte
	bsr.b	.NextByte
	bsr.b	.NextByte
	movem.l	(sp)+,d1/d2
	rts

.NextByte
	moveq	#'.',d0
	bsr.w	SENDONECHARNORMAL
.FirstByte
	moveq	#8-1,d2
.PrintBit
	moveq	#'0'/2,d0
	add.l	d1,d1
	addx.b	d0,d0
	bsr.w	SENDONECHARNORMAL
	dbf	d2,.PrintBit
	rts

com_copy:
	bclr	#5,(a6)
	cmp.b	#'C',(a6)
	beq	com_bb_checksum
	cmp.b	#'D',(a6)
	beq.b	com_create_dir
	cmp.b	#'S',(a6)
	beq	com_create_sin

	bsr	INPUTBEGINEND
	lea	(DEST.MSG,pc),a0
	bsr	Druk_MsgAf_GetNumbr
	bne	ERROR_Notdone
	tst.l	d3
	beq.b	C136F4
	move.l	d2,a0
	move.l	d0,a1
	cmp.l	d0,d2
	bls.b	C136EA
C136E2:
	move.b	(a0)+,(a1)+
	subq.l	#1,d3
	bne.b	C136E2
	rts

C136EA:
	add.l	d3,a0
	add.l	d3,a1
C136EE:
	move.b	-(a0),-(a1)
	subq.l	#1,d3
	bne.b	C136EE
C136F4:
	rts

com_create_dir:
	addq.l	#1,a6
	tst.b	(a6)
	beq.b	C1373E
	cmp.b	#' ',(a6)
	beq.b	com_create_dir
	cmp.b	#9,(a6)
	beq.b	com_create_dir
	tst.b	(a6)
	beq.b	C13734
	lea	(FileNaam-DT,a4),a0
	bsr	C180CA
C13714:
	lea	(FileNaam-DT,a4),a0
	move.l	a0,d1
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOCreateDir,a6)
	move.l	d0,d1
	beq.b	C13734
	jsr	(_LVOUnLock,a6)
	lea	(Directorycrea.MSG,pc),a0
	br	beeldtextaf

C13734:
	lea	(Errorcreating.MSG,pc),a0
	br	beeldtextaf

C1373E:
	lea	(DIRECTORYNAME.MSG,pc),a0
	bsr	INPUTTEXT
	tst.b	(CurrentAsmLine-DT,a4)
	beq.b	C13734
	lea	(FileNaam-DT,a4),a1

	lea	(CurrentAsmLine-DT,a4),a0
C13754:
	move.b	(a0)+,(a1)+
	tst.b	(a0)
	bne.b	C13754
	clr.b	(a1)
	bra.b	C13714

com_fill:
	bsr	INPUTBEGINEND
	lea	(DATA.MSG,pc),a0
	bsr	Druk_MsgAf_GetNumbr
	bne	ERROR_Notdone
	tst.l	d3
	bne.b	C13778
	addq.l	#1,d3
C13778:
	move.l	d2,a0
	subq.b	#2,(OpperantSize-DT,a4)
	beq.b	C1378E
	subq.b	#2,(OpperantSize-DT,a4)
	beq.b	C13798
C13786:
	move.b	d0,(a0)+
	subq.l	#1,d3
	bne.b	C13786
	rts

C1378E:
	asr.l	#1,d3
C13790:
	move	d0,(a0)+
	subq.l	#1,d3
	bne.b	C13790
	rts

C13798:
	asr.l	#2,d3
C1379A:
	move.l	d0,(a0)+
	subq.l	#1,d3
	bne.b	C1379A
	rts

com_monitor:
	beq.b	C137A8
	move.l	(MEM_DIS_DUMP_PTR-DT,a4),d0
C137A8:
	move.l	d0,d5
	move.l	d0,a5
C137AC:
	moveq	#16,d0
	add.l	d0,d5
	move.l	a5,d0
	bsr	druk_af_d0_space
C137B6:
	move.l	a5,(MEM_DIS_DUMP_PTR-DT,a4)
	bsr.b	C137CC
	tst	d0
	bne	druk_cr_nl
	cmp.l	d5,a5
	bne.b	C137B6
	bsr	druk_cr_nl
	bra.b	C137AC

C137CC:
	bsr.b	C1381C
	move.l	a5,-(sp)
	bsr	get_text_invoer_menuCmd
	bsr	C146A6
	move.l	a6,d2
	sub.l	a5,d2
	move.l	(sp)+,a5
	cmp.b	#$1B,d0
	beq.b	C1381A
	bsr	INPUTWORKSPACE_NOTEXT
	bne.b	C13818
	move.l	d0,d1
	moveq	#0,d3
	move.b	(OpperantSize-DT,a4),d3
	add	d3,d2
	add	d3,d2
C137F6:
	moveq	#8,d0
	bsr	Druk_char_af2
	moveq	#' ',d0
	bsr	Druk_char_af2
	moveq	#8,d0
	bsr	Druk_char_af2
	dbra	d2,C137F6
	subq.l	#1,d3
C1380E:
	move.b	d1,-(a5)
	asr.l	#8,d1
	dbra	d3,C1380E
	bsr.b	C1381C
C13818:
	clr	d0
C1381A:
	rts

C1381C:
	move.b	(OpperantSize-DT,a4),d3
	ext.w	d3
	subq.w	#1,d3
C13824:
	move.b	(a5)+,d0
	bsr	C15908
	dbra	d3,C13824
	br	druk_af_space

LINE_DISLINE:
	moveq	#~1,d0
	bsr	LINE_PARSE_AT_ARGS
	move.l	d0,a5
	moveq	#11,d5
C13882:
	move.l	a5,d0
	bsr	druk_af_d0_space
	move	d5,-(sp)
	jsr	(DISASSEMBLE_A5_PRINT)
	bsr	printthetext
	bsr	druk_cr_nl
	move	(sp)+,d5
	dbra	d5,C13882
	move.l	a5,(MEM_DIS_DUMP_PTR-DT,a4)
	rts

com_search_in_mem:
	bsr	INPUTBEGINEND
	lea	(DATA.MSG,pc),a0
	bsr	INPUTTEXT
	tst.l	d3
	bne.b	C138B8
	addq.l	#1,d3
C138B8:
	movem.l	d0-d5/a0-a3/a5/a6,-(sp)
	move.l	d3,a1
	move.l	d2,a0
	lea	(CurrentAsmLine-DT,a4),a6
	lea	(SourceCode-DT,a4),a5
C138C8:
	move.b	(a6)+,d0
	beq	C139A0
	cmp.b	#9,d0
	beq.b	C138C8
	cmp.b	#$20,d0	;sp
	beq.b	C138C8
	cmp.b	#$22,d0	;"
	beq.b	C1395C
	cmp.b	#$27,d0	;'
	beq.b	C1395C
	cmp.b	#$60,d0	;`
	beq.b	C1395C
	subq.l	#1,a6
	move.l	a6,d5
C138F0:
	move.b	(a6)+,d0
	beq.b	C1393C
	cmp.b	#$2E,d0
	beq.b	C13908
	cmp.b	#$20,d0
	beq.b	C13940
	cmp.b	#$2C,d0
	beq.b	C13940
	bra.b	C138F0

C13908:
	clr.b	(-1,a6)
	movem.l	d5/a0/a1/a5/a6,-(sp)
	move.l	d5,a6
	bsr	Convert_A2I
	movem.l	(sp)+,d5/a0/a1/a5/a6
	move.l	d0,d1
	moveq	#~32,d0
	and.b	(a6)+,d0
	moveq	#4-1,d2
	cmp.b	#'L',d0
	beq.b	C13956
	moveq	#2-1,d2
	cmp.b	#'W',d0
	beq.b	C13956
	moveq	#1-1,d2
	cmp.b	#'B',d0
	beq.b	C13956
	bra.b	asm_druk_illegalopperant

C1393C:
	subq.l	#1,a6
	bra.b	C13944

C13940:
	clr.b	(-1,a6)
C13944:
	movem.l	d5/a0/a1/a5/a6,-(sp)
	move.l	d5,a6
	bsr	Convert_A2I
	movem.l	(sp)+,d5/a0/a1/a5/a6
	move.l	d0,d1
	moveq	#0,d2
C13956:
	bsr.b	rollDataIn
	bra	C138C8

C1395C:
	move.b	d0,d3
rollLoopje:
	move.b	(a6)+,d0
	beq.b	C139A0
	cmp.b	d3,d0
	beq	C138C8
	move.b	d0,d1
	moveq	#0,d2
	bsr.b	rollDataIn
	bra.b	rollLoopje

rollDataIn:
	moveq	#4,d0
C13972:
	rol.l	#8,d1
	subq.w	#1,d0
	cmp.b	d0,d2
	bne.b	C13972
C1397A:
	cmp.l	#CurrentAsmLine,a5
	beq.b	C139A0
	move.b	d1,(a5)+
	rol.l	#8,d1
	dbra	d2,C1397A
	rts

asm_druk_illegalopperant:
	lea	(IllegalOperan.MSG).l,a0
	bsr	printthetext
	bsr	druk_cr_nl
	movem.l	(sp)+,d0-d5/a0-a3/a5/a6
	rts

C139A0:
	move.l	a1,d3
	add.l	a0,a1
	lea	(SourceCode-DT,a4),a2
	moveq	#0,d4
	cmp.l	a5,a2
	beq.b	C139CC
	move.b	(a2)+,d0
	move.l	a0,d2
C139B2:
	move.l	a2,a3
	move.l	d2,a0
C139B6:
	cmp.l	a1,a0
	beq.b	C139CC
	cmp.b	(a0)+,d0
	bne.b	C139B6
	move.l	a0,d2
C139C0:
	cmp.l	a5,a3
	beq.b	C139E6
	move.b	(a3)+,d1
	cmp.b	(a0)+,d1
	bne.b	C139B2
	bra.b	C139C0

C139CC:
	tst.l	d4
	beq.b	C139D4
	bsr	druk_cr_nl
C139D4:
	lea	(Not.MSG,pc),a0
	bsr	printthetext
	bsr	druk_cr_nl
	movem.l	(sp)+,d0-d5/a0-a3/a5/a6
	rts

C139E6:
	movem.l	d0-d5/a0-a3/a5,-(sp)
	move.l	d2,d0
	subq.l	#1,d0
	tst.l	d4
	beq.b	C13A00
	and	#7,d4
	bne.b	C13A00
	bsr	druk_cr_nl
C13A00:
	bsr	druk_af_d0
	bsr	druk_af_space
	bsr.w	Druk_Clearbuffer
	movem.l	(sp)+,d0-d5/a0-a3/a5
	addq.l	#1,d4
	bra.b	C139B2

com_compare:
	bsr	INPUTBEGINEND
	cmp.b	#NS_AVALUE,d1
	bne	ERROR_Notdone
	lea	(DEST.MSG,pc),a0
	bsr	Druk_MsgAf_GetNumbr
	bne	ERROR_Notdone
	lea	(NOT.MSG,pc),a0
	move.l	d2,a1
	move.l	d0,a2
	subq.l	#1,d3
	bmi.b	C13A4E
C13A3E:
	cmpm.b	(a1)+,(a2)+
	bne.b	C13A4E
	subq.l	#1,d3
	bpl.b	C13A3E
	lea	(EqualAreas.MSG,pc),a0
	br	C105DE

C13A4E:
	subq.l	#1,a1
	move.l	a1,d0
	bsr	druk_af_d0_space
	subq.l	#1,a2
	move.l	a2,d0
	bsr	druk_af_d0
	bsr	druk_cr_nl
	br	C105DE

com_workspace:			;'=?'
	bclr	#5,(a6)
	cmp.b	#'S',(a6)
	beq	com_PRINT_SYMBOLTABEL
	cmp.b	#'R',(a6)
	beq	com_custom_regs
	cmp.b	#'C',(a6)
	beq	com_palette
	cmp.b	#'A',(a6)
	beq	com_asmone_meminfo
	cmp.b	#'P',(a6)
	beq.b	com_project_info
	cmp.b	#'M',(a6)
	bne	com_object_info
	jmp	(com_add_workspace)


com_project_info:
	movem.l	d0-d7/a0-a6,-(sp)
	lea	(Source0.MSG).l,a0
	lea	(ProjectName-DT,a4),a2
	tst.b	(a2)
	bne.b	.C13AB6
	lea	(Noprojectstar.MSG),a2
.C13AB6
	moveq	#32-1,d6		; project name, 32 chars max.
	bsr.b	.CopyName

	lea	(SizeSource1Si.MSG).l,a0
	lea	(SourcePtrs-DT,a4),a1
	moveq	#9,d7
.SrcLoop
	moveq	#9,d6
	sub	d7,d6
	cmp.b	(CurrentSource-DT,a4),d6
	bne.b	.C13AE4
	lea	(MenuFileName,pc),a2
	bra.b	.C13AE8
.C13AE4	lea	(CS_filename,a1),a2
.C13AE8	tst.b	(a2)
	bne.b	.C13AF2
	lea	(Nosource.MSG),a2
.C13AF2
	moveq	#30-1,d6		; filename, 30 chars max.
	bsr.b	.CopyName

	lea	(13,a0),a0
	moveq	#9,d6
	sub	d7,d6
	cmp.b	(CurrentSource-DT,a4),d6
	bne.b	.C13B1A
	move.l	(sourceend-DT,a4),d0
	sub.l	(sourcestart-DT,a4),d0
	bra.b	.C13B1E

.CopyName
	move.b	(a2)+,(a0)+
	dbeq	d6,.CopyName
	bne.b	.Copied
	subq.l	#1,a0
.PadName
	move.b	#' ',(a0)+
	dbf	d6,.PadName
.Copied
	rts

.C13B1A	move.l	(CS_length,a1),d0
.C13B1E	lea	(HexToAscii).l,a3
	moveq	#7,d6
.C13B26	rol.l	#4,d0
	moveq	#15,d1
	and.b	d0,d1
	move.b	(a3,d1.w),(a0)+
	dbra	d6,.C13B26

	lea	(13,a0),a0
	lea	(CS_size,a1),a1
	dbra	d7,.SrcLoop

	lea	(_Ok_Ok.MSG).l,a2
	lea	(AsmProProject.MSG-_Ok_Ok.MSG,a2),a1
	jsr	(ShowReqtoolsRequester-_Ok_Ok.MSG,a2)
	movem.l	(sp)+,d0-d7/a0-a6
	rts

com_asmone_meminfo:
	lea	(AsmProLOCATIO.MSG,pc),a0
	move.l	#REAL,d1		; code1 (main)
	move.l	#realend2,d2
	bsr	C13C0C

	move.l	#setup_int_stuff,d1	; code2 (ui)
	move.l	#IntuiStuff_END,d2
	bsr	C13C0C

	move.l	#Disasm_START,d1	; code3 (disasm)
	move.l	#Disasm_END,d2
	bsr.b	C13C0C

	move.l	#DATA_START,d1		; data+bss
	move.l	#EndVarBase,d2
	bsr.b	C13C0C

C13BA8:
	tst.b	(a0)+
	bne.b	C13BA8
	rts

com_object_info:
	move.l	(WORK_START-DT,a4),d1
	move.l	(WORK_END-DT,a4),d2
	lea	(StartEndTotal.MSG,pc),a0
	bsr.b	C13C0C
	move.l	(sourcestart-DT,a4),d1
	move.l	(sourceend-DT,a4),d2
	bsr.b	C13C08
	move.l	(LabelStart-DT,a4),d1
	move.l	(LPtrsEnd-DT,a4),d2
	bsr.b	C13C08
	move.l	(LPtrsEnd-DT,a4),d1
	move.l	(LabelEnd-DT,a4),d2
	bsr.b	C13C08
	move.l	(LabelEnd-DT,a4),d1
	move.l	(DEBUG_END-DT,a4),d2
	bsr.b	C13C08
	move.l	(CodeStart-DT,a4),d1
	move.l	(RelocStart-DT,a4),d2
	subq.l	#4,d2
	bsr.b	C13C08
	move.l	(RelocStart-DT,a4),d1
	move.l	(RelocEnd-DT,a4),d2
	bsr.b	C13C08
	move.l	(INCLUDE_CONSUMPTION-DT,a4),d2
	beq.b	C13BA8
	bsr	printthetext
	move.l	d2,d0
	bra.b	C13C24

C13C08:
	cmp.l	d1,d2
	bls.b	C13BA8
C13C0C:
	bsr	printthetext
	move.l	d1,d0
	bsr	druk_af_d0_space
	move.l	d2,d0
	bsr	druk_af_d0_space
	move.l	d2,d0
	sub.l	d1,d0
C13C24:
	move.l	a0,a1
	bsr	PRINTDECIMALLONG
	move.l	a1,a0
	br	druk_cr_nl


RegsDataPrintChar:
	cmp.b	#10,d0
	bne	SENDONECHARNORMAL
RegsDataPrintEOL:
	bsr	Druk_af_eol
	subq.w	#1,(ShowDir_NrLines-DT,a4)
	bne.b	C13C60
	bsr	Get_me_a_char
	move	(ScreenHight-DT,a4),(ShowDir_NrLines-DT,a4)
	subq.w	#2,(ShowDir_NrLines-DT,a4)	
C13C60:
	rts

C13C62:
	tst.b	(B140AA-DT,a4)
	beq.b	C13C60
	moveq	#'0',d0
	move.b	d0,(-2,a6)
	move.b	d0,(-1,a6)
C13C78:
	tst.b	(a6)+
	bne.b	C13C78
	IF	MC020
	subq.l	#4+1,a6
	move.l	(a6)+,d0
	ELSE
	subq	#4,a6
	move.b	(a6)+,d0
	swap	d0
	move.b	(a6)+,d0
	lsl.w	#8,d0
	move.b	(a6)+,d0
	ENDIF
	and.l	#$00DFDFDF,d0
	bsr.b	C13C98
	bra.b	RegsDataPrintEOL

C13C98:
	or.l	#$09000000,d0
	move.l	(RegsDataIdx+4*4-DT,a4),a0
C13CA4:
	IF	MC020
	move.l	(a0)+,d1
	ELSE
	move.b	(a0)+,d1
	lsl.w	#8,d1
	move.b	(a0)+,d1
	swap	d1
	move.b	(a0)+,d1
	lsl.w	#8,d1
	move.b	(a0)+,d1
	ENDIF
	and.l	#$DFDFDFDF,d1
	tst.b	(a0)
	bmi.w	E_NextCharacter8
	subq.w	#3,a0
	cmp.l	d0,d1
	bne.b	C13CA4
	and.l	#$00DFDFDF,d0
	move.l	d0,-(sp)
	moveq	#2,d2
	moveq	#' ',d0
.C13CD8
	bsr	RegsDataPrintChar
	move.b	(a0)+,d0
	bmi.b	C13CF2
	cmp.b	#'#',d0
	beq.b	C13CF2
	cmp.b	#10,d0
	bne.b	.C13CD8
	lea	(15,a0),a0
	bra.b	.C13CD8

C13CF2:
	moveq	#':',d0
	bsr	RegsDataPrintChar
	bsr	RegsDataPrintEOL
	bsr	RegsDataPrintEOL
	move.l	(sp)+,d0
	move.l	(RegsDataIdx+6*4-DT,a4),a0
	moveq	#0,d2
C13D10:
	bsr	C13DCA
	cmp.l	d0,d1
	beq.b	C13D56
	cmp.b	#'-',(a0)
	bne.b	.C13D2C
	addq.w	#1,a0
	cmp.l	d0,d1
	bhi.b	.C13D2C
	bsr	C13DCA
	cmp.l	d0,d1
	bcc.b	C13D56
.C13D2C
	cmp.b	#'/',(a0)
	bne.b	.C13D36
	addq.w	#1,a0
	bra.b	C13D10

.C13D36	cmp.b	#'~',(a0)+
	bne.b	.C13D36
	addq.w	#1,a0
	cmp.b	#$FF,(a0)
	bne.b	C13D10
	move.l	(RegsDataIdx+2*4-DT,a4),a0
C13D4A:
	move.b	(a0)+,d0
	beq.b	C13D54
	bsr	RegsDataPrintChar
	bra.b	C13D4A
C13D54:
	rts

C13D56:
	cmp.b	#10,(a0)+
	bne.b	C13D56

C13D5E:
	moveq	#0,d0
	move.b	(a0)+,d0
	cmp.b	#'~',d0
	bne.b	E_NextCharacterA
E_NextCharacter8:
	rts

E_NextCharacterA:
	cmp.b	#';',d0
	bne.b	C13D80
	move.l	a0,-(sp)
	move.l	(RegsDataIdx+0*4-DT,a4),a0
	bsr.b	C13D5E
	move.l	(sp)+,a0
	bra.b	C13D5E

C13D80:
	cmp.b	#10,d0
	bne.b	.C13DA0
	moveq	#-1,d2
.C13DA0	cmp.b	#9,d0
	bne.b	.C13DC2
	moveq	#~7,d3
	and.l	d2,d3
	addq.l	#8,d3
	sub.l	d2,d3
	subq.l	#1,d3
.C13DB4	moveq	#' ',d0
	bsr	RegsDataPrintChar
	addq.w	#1,d2
	dbra	d3,.C13DB4
	bra.b	C13D5E

.C13DC2	bsr	RegsDataPrintChar
	addq.w	#1,d2
	bra.b	C13D5E

C13DCA:
	IF	MC020
	subq.l	#1,a0
	move.l	(a0)+,d1
	ELSE
	move.b	(a0)+,d1
	swap	d1
	move.b	(a0)+,d1
	lsl.w	#8,d1
	move.b	(a0)+,d1
	ENDIF
	and.l	#$00DFDFDF,d1
	rts

OpenRegsDataFile:
	move.l	a0,d1
	move.l	d1,(PtrRegsData-DT,a4)
	moveq	#ACCESS_READ,d2
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOLock,a6)
	move.l	d0,(RegsDataFH-DT,a4)
	rts

com_custom_regs:
	movem.l	d0-a6,-(sp)
	btst	#0,(PR_RegsRes).l
	beq.b	.C13DF2
	tst.l	(RegsDataMemBuffer-DT,a4)
	bne	RegsDataFileLoaded
.C13DF2
	lea	(SREGSDATA.MSG-DT,a4),a0
	bsr.b	OpenRegsDataFile
	bne.b	.open

	lea	(RegsDataSDir-DT,a4),a0
	bsr.b	OpenRegsDataFile
	beq.w	RegsDataFileNotFound

.open	move.l	(RegsDataFH-DT,a4),d1
	lea	(ParameterBlok-DT,a4),a0
	move.l	a0,d2
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOExamine,a6)
	tst.l	d0
	beq	RegsDataFileNotFound
	move.l	(ParameterBlok+fib_Size-DT,a4),(RegsDataSize-DT,a4)
	move.l	(RegsDataFH-DT,a4),d1
	jsr	(_LVOUnLock,a6)
	clr.l	(RegsDataFH-DT,a4)
	move.l	(RegsDataSize-DT,a4),d0
	moveq	#1,d1
	move.l	(4).w,a6
	jsr	(_LVOAllocMem,a6)
	lea	(RegsDataMemBuffer-DT,a4),a2
	move.l	d0,(a2)
	beq	C13F78
	move.l	(PtrRegsData-DT,a4),d1
	move.l	#MODE_OLDFILE,d2
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOOpen,a6)
	move.l	d0,(RegsDataFHandle-DT,a4)
	beq.b	RegsDataFileNotFound
	move.l	d0,d1
	move.l	(a2),d2
	move.l	(RegsDataSize-DT,a4),d3
	jsr	(_LVORead,a6)
	move.l	(RegsDataFHandle-DT,a4),d1
	jsr	(_LVOClose,a6)
	clr.l	(RegsDataFHandle-DT,a4)
	lea	(RegsOffsets+7*2,pc),a0
	moveq	#7-1,d1
.InitRegs
	moveq	#0,d0
	move.w	-(a0),d0
	add.l	d2,d0
	move.l	d0,-(a2)
	dbf	d1,.InitRegs

RegsDataFileLoaded:
	move.l	(Error_Jumpback-DT,a4),(Error_Jumpback_Old-DT,a4)
	lea	(.C13F16,pc),a0
	move.l	a0,(Error_Jumpback-DT,a4)
	movem.l	(sp)+,d0-d7/a0-a6
	bsr.b	HandleRegsDataQuery

.C13F16	bsr.b	ZapRegsData
	move.l	(Error_Jumpback_Old-DT,a4),(Error_Jumpback-DT,a4)
	rts

RegsDataFileNotFound:
	move.l	(RegsDataMemBuffer-DT,a4),a1
	move.l	(RegsDataSize-DT,a4),d0
	beq.b	.C13F36
	move.l	(4).w,a6
	jsr	(_LVOFreeMem,a6)
.C13F36	clr.l	(RegsDataMemBuffer-DT,a4)
	clr.l	(RegsDataSize-DT,a4)
	lea	(SREGSDATAfile.MSG,pc),a0
	bsr	printthetext
	movem.l	(sp)+,d0-a6
	rts

RegsOffsets:
	DC.W	$0000,$0045,$008F,$0098,$0880,$087F,$4922

;	dc.b	"Groatis zoep'n en vret'n !!             "

C13F78:
	lea	(Notenoughmemo.MSG,pc),a0
	bsr	printthetext
	movem.l	(sp)+,d0-d7/a0-a6
	rts

ZapRegsData:
	tst.l	(RegsDataMemBuffer-DT,a4)
	beq.b	.C13FB6
	btst	#0,(PR_RegsRes).l
	bne.b	.C13FB6
	move.l	(RegsDataMemBuffer-DT,a4),a1
	move.l	(RegsDataSize-DT,a4),d0
	beq.b	.C13FB6
	move.l	(4).w,a6
	jsr	(_LVOFreeMem,a6)
	clr.l	(RegsDataSize-DT,a4)
	clr.l	(RegsDataMemBuffer-DT,a4)
.C13FB6	rts

HandleRegsDataQuery:
	move	(ScreenHight-DT,a4),(ShowDir_NrLines-DT,a4)
	subq.w	#2,(ShowDir_NrLines-DT,a4)
	st	(B140AA-DT,a4)
.C13FCE
	addq.w	#1,a6
	cmp.b	#' ',(a6)
	beq.b	.C13FCE
	cmp.b	#9,(a6)
	beq.b	.C13FCE
	tst.b	(a6)
	beq	RegsDataPrintIndex
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	(RegsDataIdx+5*4-DT,a4),a0
	lea	(a6),a1
.C13FEE
	move.b	(a1)+,d0
	cmp.b	#' ',d0
	beq.b	.C13FEE
	cmp.b	#9,d0
	beq.b	.C13FEE
	subq.w	#1,a1
	sf	d3
	cmp.b	#'0',d0
	beq.b	C14064
	cmp.b	#'1',d0
	beq.b	C14064
	lea	(-15,a0),a0
C14010:
	cmp.b	#'#',(a0)
	beq.b	C14020
	cmp.b	#$FF,(a0)
	beq.b	C14064
	addq.w	#1,a0
	bra.b	C14010

C14020:
	addq.w	#2,a0
C14022:
	lea	(a0),a2
	lea	(a1),a3
C14026:
	move.b	(a2)+,d0
	move.b	(a3)+,d1
	beq.b	C1405E
	cmp.b	#'?',d0
	beq.b	C14064
	and.b	#$DF,d0
	and.b	#$DF,d1
	cmp.b	d0,d1
	bne.b	.C14044
	bra.b	C14026

.C14044	cmp.b	#'#',(a0)
	beq.b	.C14054
	cmp.b	#$FF,(a0)+
	bne.b	.C14044
	bra.b	C14064

.C14054	addq.w	#2,a0
	cmp.b	#$FF,(a0)
	bne.b	C14022

C14064:
	movem.l	(sp)+,d0-d7/a0-a6
	br	C13C62

C1405E:	lea	(13,a0),a0

C1406C:
	movem.l	d0-d7/a0-a6,-(sp)
C14070:
	move.b	(a0)+,d0
	cmp.b	#'0',d0
	blo.b	C14070
	cmp.b	#'9',d0
	bhi.b	C14070
	IF	MC020
	subq.l	#1+1,a0
	move.l	(a0)+,d0
	ELSE
	subq.w	#1,a0
	move.b	(a0)+,d0
	swap	d0
	move.b	(a0)+,d0
	lsl.w	#8,d0
	move.b	(a0)+,d0
	ENDIF
	and.l	#$00DFDFDF,d0
	sf	(B140AA-DT,a4)
	bsr	C13C98
	bsr	RegsDataPrintEOL
	movem.l	(sp)+,d0-d7/a0-a6
	st	d3
	bra	C14010

RegsDataPrintIndex:
	movem.l	d0-d7/a0-a6,-(sp)
	move	(ScreenHight-DT,a4),(ShowDir_NrLines-DT,a4)
	subq.w	#2,(ShowDir_NrLines-DT,a4)
	move.l	(RegsDataIdx+3*4-DT,a4),a0
	moveq	#0,d0
C140C6:
	cmp.b	#$FF,(a0)
	beq	C14164
	cmp.b	#'#',(a0)
	bne.b	C140D8
	addq.w	#1,a0
	bra.b	C140C6

C140D8:
	tst.b	(a0)
	beq.b	C14118
	cmp.b	#10,(a0)
	beq.b	C14118
	cmp.b	#9,(a0)
	beq.b	C140F8
	move.l	d0,-(sp)
	move.b	(a0)+,d0
	bsr	SENDONECHARNORMAL
	move.l	(sp)+,d0
	addq.l	#1,d0
	bra.b	C140C6

C140F8:
	moveq	#~7,d1
	and.l	d0,d1
	addq.l	#8,d1
	move.l	d1,-(sp)
	sub.l	d0,d1
	subq.l	#1,d1
C14108:
	bsr.w	druk_af_space
	dbra	d1,C14108
	move.l	(sp)+,d0
	addq.w	#1,a0
	bra.b	C140C6

C14118:
	bsr	druk_cr_nl
	bset	#SB1_CHANGE_MODE,(SomeBits-DT,a4)
	moveq	#13,d0
	bsr	SENDONECHARNORMAL
	bclr	#SB1_CHANGE_MODE,(SomeBits-DT,a4)
	addq.w	#1,a0
	moveq	#0,d0
	subq.w	#1,(ShowDir_NrLines-DT,a4)
	bne.b	C140C6
	bsr	GETKEYNOPRINT
	cmp.b	#$1B,d0
	beq.b	.C1415A
	move	(ScreenHight-DT,a4),(ShowDir_NrLines-DT,a4)
	subq.w	#2,(ShowDir_NrLines-DT,a4)
	moveq	#0,d0
	br	C140C6
.C1415A
	lea	(Break.MSG,pc),a0
	bsr	printthetext
C14164:
	movem.l	(sp)+,d0-d7/a0-a6
	rts

com_zap:
	moveq	#~32,d0
	and.b	(a6)+,d0
	cmp.b	#'F',d0
	beq	com_zapfile
	cmp.b	#'L',d0
	beq	com_zaplines
	cmp.b	#'A',d0
	beq.b	com_zapautoalloc
	cmp.b	#'I',d0
	beq	ZapIncludes
	cmp.b	#'B',d0
	beq	DEBUG_CLEAR_BP_BUFFER
	cmp.b	#'S',d0
	bne	ERROR_IllegalComman

com_zapsource:
	bsr.b	CopyCurrSrcNameToReq
	bsr	ASK_CHECK_IF_SAVED
	bsr.b	KILL_SOURCE
	clr.b	(MenuFileName).l
	bsr	RESETMENUTEXT2
	bra	ASK_CHECK_IF_SAVED

com_zapautoalloc:
	jmp	(ASSEM_FREE_SECTION_MEM).l

CopyCurrSrcNameToReqAsActive:
	move.b	(CurrentSource-DT,a4),(ActiveSrcNr-DT,a4)

CopyCurrSrcNameToReq:
	move.b	(CurrentSource-DT,a4),d0

CopySrcNameToReq:
	movem.l	d0/d1/d7/a0/a1,-(sp)
	moveq	#'0',d1
	add.b	d0,d1
	move.b	d1,(SourceNr).l
	cmp.b	(CurrentSource-DT,a4),d0
	bne.b	.C141F2
	lea	(MenuFileName,pc),a0
	bra.b	C14200
.C141F2
	lea	(SourcePtrs+CS_filename-DT,a4),a0
	lsl.w	#8,d0			; *CS_size
	add.w	d0,a0
C14200:
	lea	(ReqSourceName),a1
	moveq	#30-1,d7
	tst.b	(a0)
	beq.b	C1422A
C1420C:
	tst.b	(a0)
	beq.b	C14218
	move.b	(a0)+,(a1)+
	dbra	d7,C1420C
	bra.b	C14220

C14218:
	move.b	#' ',(a1)+
	dbra	d7,C14218
C14220:
	move.b	#' ',(a1)+
	movem.l	(sp)+,d0/d1/d7/a0/a1
	rts

C1422A:
	lea	(Newsourcenona.MSG).l,a0
	bra.b	C14200

KILL_SOURCE:
	bsr	ZapAllCondBPsAndWatches
	lea	(EditMarks10-DT,a4),a0
	moveq	#10-1,d0
.ClrMarks
	clr.l	(a0)+
	dbf	d0,.ClrMarks
	bclr	#SB2_INDEBUGMODE,(SomeBits2-DT,a4)
	move.l	(WORK_START-DT,a4),a0
	addq.l	#1,a0
	move.l	a0,(sourcestart-DT,a4)
	move.l	a0,(sourceend-DT,a4)
	move.l	a0,(FirstLinePtr-DT,a4)
	addq.w	#1,a0
	move.l	a0,(Cut_Blok_End-DT,a4)
	move.b	#SRCMARK_END,-(a0)
	move.b	#SRCMARK_BEGIN,-(a0)
	moveq	#1,d0
	move.l	d0,(FirstLineNr-DT,a4)
	clr.b	(LastFileNaam-DT,a4)
	move.l	a1,-(sp)
	lea	(INCLUDE_DIRECTORY-DT,a4),a1
	moveq	#32-1,d0
.C14296	clr.b	(a1)+
	dbf	d0,.C14296
	move.l	(sp)+,a1
	rts

ASK_CHECK_IF_SAVED:
	btst	#SB1_SOURCE_CHANGED,(SomeBits-DT,a4)
	beq.b	.IS_SAVED
	bsr.b	ASK_NOTSAVED
	bclr	#SB1_SOURCE_CHANGED,(SomeBits-DT,a4)
.IS_SAVED
	rts

ASK_AREYOUSURE:
	btst	#0,(PR_ReqLib).l
	beq.b	.NO_REQ
	jmp	(ShowReqtoolsCheckRequester).l
.NO_REQ
	lea	(Sure.MSG,pc),a0
	bsr	beeldtextaf
	bsr	GetHotKey
	bra.b	ASK_CHECKANSWER_Y_N

ASK_IF_OVERWRITE_OK:
	btst	#0,(PR_ReqLib).l
	beq.b	.NO_REQ
	jmp	(C1F030).l
.NO_REQ
	btst	#SB3_SPEC_KEYS,(SomeBits3-DT,a4)	;are we in editor?
	beq.b	C14302
	lea	(Filealreadyex.MSG,pc),a0
	bsr	printTextInMenuStrip
	bsr	GETKEYNOPRINT
	and.b	#$DF,d0
	bra.b	ASK_CHECKANSWER_Y_N

C14302:
	lea	(Filealreadyex.MSG,pc),a0
	bsr	beeldtextaf
	bsr.b	GetHotKey
	bra.b	ASK_CHECKANSWER_Y_N

ASK_NOTSAVED:
	btst	#0,(PR_ReqLib).l
	beq.b	.NO_REQ
	jmp	(C1F048).l
.NO_REQ
	lea	(Sourcenotsave.MSG,pc),a0
	bsr	beeldtextaf
	bsr.b	GetHotKey
	bra.b	ASK_CHECKANSWER_Y_N

EXTENDEDANSWER:
	btst	#0,(PR_ReqLib).l
	beq.b	.NO_REQ
	jmp	(ANSWER_YES_NO_RESTART).l
.NO_REQ
	lea	(ExitorRestart.MSG,pc),a0
	bsr	beeldtextaf
	bsr.b	GetHotKey
	cmp.b	#'R',d0
	beq.b	C1437C
ASK_CHECKANSWER_Y_N:
	cmp.b	#'Y',d0
	beq.b	C14370
	bra	ERROR_Notdone

GetHotKey:
	bsr	GETKEYNOPRINT
	bsr	SENDONECHARNORMAL
	and.b	#$DF,d0
	move	d0,-(sp)
	bsr	Druk_Clearbuffer
	move	(sp)+,d0
	bsr	druk_cr_nl
C14370:
	move.b	#1,PR_RegsRes
	bsr	ZapRegsData
C1437C:
	rts

Filter_inputtext:
	tst.b	(a5)
	beq.b	Filter_einderegel
	moveq	#48,d0
Filter_loopje:
	move.b	(a5)+,d1
	beq.b	Filter_eindereg2
	tst.b	(CaseSenceSearch-DT,a4)
	bne.b	Filter_UpisLow
	cmp.b	#'a',d1
	blo.b	Filter_UpisLow
	sub.b	#'a'-'A',d1	;small letters get big
Filter_UpisLow:
	move.b	d1,(a6)+
	dbra	d0,Filter_loopje
Filter_eindereg2:
	clr.b	(a6)
Filter_einderegel:
	rts

com_search:	; L (LOOKFORTEXT)
	IF	Debugstuff
	cmp.b	#'@',(a6)	; undocumented, for debugging apparently
	beq	Debug_base
	ENDIF
	move.l	a6,a5
	lea	(SourceCode-DT,a4),a6
	bsr.b	Filter_inputtext
	lea	(SourceCode-DT,a4),a5
	move.l	(FirstLinePtr-DT,a4),a0
C143C2:
	cmp.b	#SRCMARK_END,(a0)
	beq	C11CF0
	tst.b	(a0)+
	bne.b	C143C2
	subq.l	#1,a0
	move.b	(a5)+,d2
	beq	Drukaf_CurrentLine
C143D6:
	move.l	a5,a6
C143D8:
	move.b	(a0)+,d1
	bne.b	MOVEMARKS6
	addq.l	#1,(FirstLineNr-DT,a4)
	move.l	a0,(FirstLinePtr-DT,a4)
	bra.b	C143D8

MOVEMARKS6:
	cmp.b	#SRCMARK_END,d1
	beq	C11CF0
	cmp.b	#$61,d1
	bcs.b	C143F8
	sub.b	#$20,d1
C143F8:
	cmp.b	d2,d1
	bne.b	C143D8
	move.l	a0,a1
C143FE:
	move.b	(a6)+,d0
	beq	Drukaf_CurrentLine
	move.b	(a1)+,d1
	cmp.b	#$61,d1
	bcs.b	C14410
	sub.b	#$20,d1
C14410:
	cmp.b	d0,d1
	bne.b	C143D6
	bra.b	C143FE

com_top:
	moveq	#1,d1
	move.l	d1,(FirstLineNr-DT,a4)
	move.l	(sourcestart-DT,a4),a0
	subq.l	#1,d0
	bsr	DOWN_D0_LINES_NOHOLE
	move.l	a0,(FirstLinePtr-DT,a4)
	br	C144EA

com_bottom:
	moveq	#~32,d0
	and.b	(a6)+,d0
	cmp.b	#'M',d0		;BM binary memorydump
	beq	com_BinDump
	cmp.b	#'S',d0		;BS bootblock simulator
	beq.b	Bootblock_simulator

	move.l	(FirstLinePtr-DT,a4),a0
.JumpBottom
	moveq	#-1,d0
	bsr.b	C144D6
	cmp.b	#SRCMARK_END,(a0)	; loop in case >64K lines
	bne.b	.JumpBottom
	br	C144EA

Bootblock_simulator:
	lea	(BEG.MSG,pc),a0
	bsr	Druk_MsgAf_GetNumbr
	tst.l	d0
	beq	ERROR_Notdone
	move.l	d0,a2
	lea	(12,a2),a2		; skip DOS header
	moveq	#0,d0
	bsr	Open_trackdiskdev
	tst.l	d0
	bne	ERROR_IllegalDevice
	lea	($dff000),a3
	move.w	#$7fff,d2
	move.w	($002,a3),d3
	move.w	($01c,a3),d4
	move.w	d2,($096,a3)
	move.w	d2,($09a,a3)
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	(4).w,a6
	lea	(DATA_WRITEREQUEST2-DT,a4),a1

	move.w	#$83d0,($096,a3)
	move.w	#$e02c,($09a,a3)

	jsr	(a2)
	movem.l	(sp)+,d0-d7/a0-a6
	not.w	d2
	or.w	d2,d3
	move.w	d3,($096,a3)
	or.w	d2,d4
	move.w	d4,($09a,a3)
	br	C17186

C144D6:
	cmp.b	#SRCMARK_END,(a0)
	beq.b	C144E8
C144DC:
	tst.b	(a0)+
	bne.b	C144DC
	addq.l	#1,(FirstLineNr-DT,a4)
DOWN_D0_LINES_NOHOLE:
	dbra	d0,C144D6
C144E8:
	rts

C144EA:
	move.l	a0,(FirstLinePtr-DT,a4)
Drukaf_CurrentLine:
	move.l	(FirstLineNr-DT,a4),d0
	bsr	DrukAf_LineNrPrint
	move.l	(FirstLinePtr-DT,a4),a0
	cmp.b	#SRCMARK_END,(a0)
	beq	ERROR_EndofFile
	bsr	printthetext
	br	druk_cr_nl

com_zaplines:
	bclr	#SB2_INDEBUGMODE,(SomeBits2-DT,a4)
	bsr	GETNUMBERAFTEROK
	move	d0,d5
	beq.b	C14528
	bsr	ASK_AREYOUSURE
	subq.w	#1,d5
	moveq	#1,d4
	cmp	#$0014,d5
	bcs.b	C14528
	subq.w	#1,d4
C14528:
	move.l	(FirstLinePtr-DT,a4),a0
C1452C:
	tst	d4
	beq.b	C1454C
	move.l	a0,-(sp)
	lea	(Zap.MSG,pc),a0
	bsr	printthetext
	move.l	(sp),a0
	cmp.b	#SRCMARK_END,(a0)
	beq.b	C14546
	bsr	printthetext
C14546:
	bsr	druk_cr_nl
	move.l	(sp)+,a0
C1454C:
	cmp.b	#' ',(a0)+
	bcc.b	C1454C
	cmp.b	#9,(-1,a0)
	beq.b	C1454C
	cmp.b	#SRCMARK_END,(-1,a0)
	beq.b	C1456A
	dbra	d5,C1452C
	bsr.b	C14572
	bra.b	Drukaf_CurrentLine

C1456A:
	subq.l	#1,a0
	bsr.b	C14572
	br	Drukaf_CurrentLine

C14572:
	move.l	a0,a1
	move.l	(FirstLinePtr-DT,a4),a0
	move.l	(sourceend-DT,a4),d0
	sub.l	a1,d0
	bmi.w	ERROR_EndofFile
C14582:
	move.b	(a1)+,(a0)+
	subq.l	#1,d0
	bpl.b	C14582
	move.l	a0,(Cut_Blok_End-DT,a4)
	subq.l	#1,a0
	move.l	a0,(sourceend-DT,a4)
	rts


REQ_TYPES:
	dc.b	00	; READ FILE
	dc.b	00	; WRITE FILE
	dc.b	01	; READ Binary
	dc.b	01	; WRITE Binary
	dc.b	01	; READ OBJECT
	dc.b	01	; WRITE OBJECT
	dc.b	01	; WRITE LINK
	dc.b	02	; WRITE BLOCK
	dc.b	01	; DIRECT OUTPUT
	dc.b	01	; ZAP FILE
	dc.b	02	; INSERT FILE
	dc.b	00

FileReqStuff:
	btst	#0,(PR_ReqLib).l
	beq.b	.NoReqLib
	jmp	(YesReqLib).l
.NoReqLib:
	move.b	(REQ_TYPES,pc,d0.w),d0
	beq.b	.NORMAL_NAME
	subq.b	#1,d0
	beq.b	.NORMAL_NAME_2
	lea	(DIR_ARRAY3-DT,a4),a1
	lea	(FILE_ARRAY3-DT,a4),a0
	bra.b	C145CE
.NORMAL_NAME_2:
	lea	(DIR_ARRAY2-DT,a4),a1
	lea	(FILE_ARRAY2-DT,a4),a0
	bra.b	C145F8
.NORMAL_NAME:
	lea	(DIR_ARRAY-DT,a4),a1
	move.l	d0,-(sp)
	moveq	#0,d0
	move.b	(CurrentSource-DT,a4),d0
	lsl.l	#7,d0			;DSIZE = 128
	add.l	d0,a1
	move.l	(sp)+,d0

	lea	(MenuFileName,pc),a0
C145CE:
	btst	#0,(PR_SourceExt).l
	beq.b	C145F8
	move.l	a0,-(sp)
C145DA:
	move.b	(a0)+,d0
	beq.b	C145E6
	cmp.b	#'.',d0
	bne.b	C145DA
	bra.b	C145F6

C145E6:
	subq.l	#1,a0
	move.l	a1,-(sp)
	lea	(UserSrcExt.MSG).l,a1
C145F0:
	move.b	(a1)+,(a0)+
	bne.b	C145F0
	move.l	(sp)+,a1
C145F6:
	move.l	(sp)+,a0
C145F8:
	movem.l	a0/a1,-(sp)
	move.l	a0,-(sp)
	tst.b	(a1)
	beq.b	C14618
	bsr.b	C14678
	cmp.b	#':',(-1,a1)
	beq.b	C14618
	moveq	#'/',d0
	cmp.b	(-1,a1),d0
	beq.b	C14618
	bsr	KEYBUFFERPUTCHAR
C14618:
	move.l	(sp),a1
	bsr.b	C14678
	move.l	(sp)+,a0
	move.l	a1,d1
C14620:
	cmp.l	a0,a1
	beq.b	C14636
	cmp.b	#'.',-(a1)
	bne.b	C14620
	sub.l	a1,d1
C1462C:
	moveq	#2,d0
	bsr	C17412
	subq.w	#1,d1
	bne.b	C1462C
C14636:
	lea	(FILENAME.MSG,pc),a0
	bsr.b	INPUTTEXT
	lea	(CurrentAsmLine-DT,a4),a0
	tst.b	(a0)
	beq	ERROR_Notdone
	movem.l	(sp)+,d1/a2
C1464A:
	move.l	d1,a1
	move.l	a2,d2
C1464E:
	move.b	(a0)+,d0
	beq.b	C14664
	move.b	d0,(a1)+
	move.b	d0,(a2)+
	cmp.b	#'/',d0
	beq.b	C1464A
	cmp.b	#':',d0
	beq.b	C1464A
	bra.b	C1464E
C14664:
	clr.b	(a1)+
	move.l	d2,a2
	clr.b	(a2)
	rts


C14678:
	move.b	(a1)+,d0
	beq.b	C14682
	bsr	KEYBUFFERPUTCHAR
	bra.b	C14678
C14682:
	subq.w	#1,a1
	rts

INPUTTEXT:
	bsr	printthetext
INPUTTEXT_NOTEXT:
	movem.l	a0/a3/a5/a6,-(sp)
	bsr.b	get_text_invoer_menuCmd
	movem.l	(sp)+,a0/a3/a5/a6
	bsr.b	C146A6
	move.l	d0,-(sp)
	bsr	druk_cr_nl
	bsr.w	Print_Flush
	move.l	(sp)+,d0
	rts

C146A6:
	movem.l	d0/a0,-(sp)
	lea	(CurrentAsmLine-DT,a4),a0
	bsr	C156E8
	movem.l	(sp)+,d0/a0
	rts

;********** DRUK TEXT IN MENU BALK en commandstuff**********

Druk_CmdMenuText:
	bsr	printthetext
	movem.l	a0/a3/a5/a6,-(sp)
	bsr.b	get_text_invoer_menuCmd
	movem.l	(sp)+,a0/a3/a5/a6
	bra.b	C146A6

get_text_invoer_menuCmd:
	lea	(CurrentAsmLine-DT,a4),a6
	move.l	a6,a5
	move.l	a6,a3
get_tiv_menuCmd:
	bsr	Get_me_a_char
	pea	(get_tiv_menuCmd,pc)

	cmp.b	#$80,d0
	bne.w	CL_NotEscCode

	move.b	(edit_EscCode-DT,a4),d0
	cmp.b	#14,d0
	beq	CL_SmallEscFound

	cmp.b	#1,d0		
	beq	CL_Hist_up
	cmp.b	#4,d0
	beq	CL_Hist_down
	cmp.b	#5,d0		; shift-up
	beq	CL_Hist_up10
	cmp.b	#8,d0		; shift-down
	beq	CL_Hist_down10

	cmp.b	#3,d0
	beq	CL_pijl_rechts
	cmp.b	#2,d0
	beq	CL_pijl_links
	cmp.b	#6,d0
	beq	CL_Shift_pijl_links
	cmp.b	#7,d0
	beq	CL_Shift_pijl_rechts

	cmp.b	#15,d0
	beq.w	CL_Delete2EOL
	cmp.b	#$10,d0
	beq.w	CL_DeleteBol
	cmp.b	#$16,d0
	beq	CL_Clear_the_line
	moveq	#$80-256,d0
	br	CL_NormalChar

CL_ClearCommandline:
	move.l	a0,-(sp)
	lea	(CurrentAsmLine-DT,a4),a0
	cmp.l	a0,a6
	beq.b	.DontClear
	move.l	(sp)+,a0
	bsr	CL_Clear_the_line	;clear line?
	bra.b	CL_DeleteBol

.DontClear:
	move.l	(sp)+,a0
	br	CL_NormalChar		;comm <-> editor

CL_NotEscCode:
	cmp.b	#8,d0
	beq.w	CL_BSCommandline	;BS?
	cmp.b	#$7F,d0			;127
	beq.b	CL_Delete
	cmp.b	#9,d0			;Tab
	beq.b	CL_normalchar
	cmp.b	#$1B,d0			;Esc key
	beq.b	CL_ClearCommandline

	cmp.b	#' ',d0			;Space
	bcs.w	CL_NormalChar

CL_normalchar:
	move.l	a6,a0
	addq.l	#1,a6	;insertpos
	addq.l	#1,a3	;lengte
.copylopje:
	move.b	(a0),d1
	move.b	d0,(a0)+

	btst	#MB1_DRUK_IN_MENUBAR,(MyBits-DT,a4)
	beq.s	.norm
	bsr	show_char_in_balk	;in balk dus
	bra.b	.klaar
.norm:
	bsr	Druk_char_af2
.klaar:
	move.b	d1,d0
	cmp.l	a3,a0
	bne.b	.copylopje

	bsr.w	Print_Flush

cl_lastpart:
	cmp.l	a6,a0
	beq.b	KlaarCommandline
	btst	#MB1_DRUK_IN_MENUBAR,(MyBits-DT,a4)
	bne.s	.klaar4

	moveq	#8,d0
	bsr	Druk_char_af2
.klaar4:
	subq.l	#1,a0
	bra.b	cl_lastpart


CL_Delete2EOL:
	move.l	a6,a3
	br	C1529A

CL_Delete:
	cmp.l	a3,a6
	beq.b	KlaarCommandline
	move.l	a6,a0
	addq.l	#1,a0
	bra.b	GoOnCommandline

CL_DeleteBol:
.clearback:
	bsr.b	CL_BSCommandline
	cmp.l	a5,a6
	bne.b	.clearback
KlaarCommandline:
	rts

back_menub:
	subq.w	#1,(menu_char_pos-DT,a4)
	moveq	#0,d0
	bsr	show_char_in_balk
	subq.w	#1,(menu_char_pos-DT,a4)
	bra.b	GoOnCommandline

CL_BSCommandline:
	cmp.l	a5,a6
	beq.b	KlaarCommandline
	move.l	a6,a0
	subq.l	#1,a6

	btst	#MB1_DRUK_IN_MENUBAR,(MyBits-DT,a4)
	bne.s	back_menub

	moveq	#8,d0
	bsr	Druk_char_af2

GoOnCommandline:
	cmp.l	a0,a3
	beq.b	C147DA
	move.b	(a0)+,d0
	move.b	d0,(-2,a0)

	btst	#MB1_DRUK_IN_MENUBAR,(MyBits-DT,a4)
	beq.s	.nomenub
	bsr	show_char_in_balk
	bra.b	.klaar5
.nomenub:
	bsr	Druk_char_af2
.klaar5:
	bra.b	GoOnCommandline

C147DA:
	btst	#MB1_DRUK_IN_MENUBAR,(MyBits-DT,a4)
	bne.s	.klaar6
	moveq	#' ',d0
	bsr	Druk_char_af2
.klaar6:
	subq.l	#1,a3
	bra.w	cl_lastpart

CL_SmallEscFound:
	moveq	#' ',d0
CL_NormalChar:
	move.l	a3,a6
	clr.b	(a6)
	addq.w	#4,sp
	br	INPUT_FILLINDAIRY
;;
CL_Clear_the_line:	;bij ESC in de Cmdline
	btst	#MB1_DRUK_IN_MENUBAR,(MyBits-DT,a4)
	bne.b	CL_DeleteBol

.clearforw:
	cmp.l	a3,a6
	beq.s	.clearback2

	moveq	#' ',d0
	bsr	Druk_char_af2
	addq.l	#1,a6
	bra.b	.clearforw

.clearback2:
	cmp.l	a6,a5
	beq.w	CL_Delete2EOL

	moveq	#8,d0
	bsr	Druk_char_af2
	moveq	#' ',d0
	bsr	Druk_char_af2
	moveq	#8,d0
	bsr	Druk_char_af2

	subq.l	#1,a6
	bra.b	.clearback2

CL_Shift_pijl_rechts:	;shift ->
	cmp.l	a6,a3
	beq.b	KlaarCommandline2

	move.b	(a6)+,d0

	btst	#MB1_DRUK_IN_MENUBAR,(MyBits-DT,a4)
	beq.s	.nomenu
	bsr	show_char_in_balk
	bra.b	CL_Shift_pijl_rechts
.nomenu:
	bsr	Druk_char_af2
	bra.b	CL_Shift_pijl_rechts

CL_pijl_rechts:	;->
	cmp.l	a6,a3
	beq.b	KlaarCommandline2

	move.b	(a6)+,d0
	btst	#MB1_DRUK_IN_MENUBAR,(MyBits-DT,a4)
	bne.w	show_char_in_balk
	br	Druk_char_af2

CL_Shift_pijl_links:	;shift '<-'
	cmp.l	a6,a5
	beq.b	KlaarCommandline2

	btst	#MB1_DRUK_IN_MENUBAR,(MyBits-DT,a4)
	bne.w	CL_DeleteBol

	moveq	#8,d0
	bsr	Druk_char_af2
	subq.l	#1,a6
	bra.b	CL_Shift_pijl_links

CL_pijl_links: ;<-
	cmp.l	a6,a5
	beq.b	KlaarCommandline2

	btst	#MB1_DRUK_IN_MENUBAR,(MyBits-DT,a4)
	bne.w	CL_BSCommandline

	moveq	#8,d0		;BS
	bsr	Druk_char_af2

	subq.l	#1,a6
KlaarCommandline2:
	rts


CL_Hist_down10:
	moveq	#9-1,d0
.Loop	bsr.b	CL_Hist_down
	dbf	d0,.Loop

CL_Hist_down:
	movem.l	d0-d2/a0/a1,-(sp)
	move.w	(DAIRYIN-DT,a4),d1	; next/newest entry
	moveq	#64,d2
	bra.b	History_stuff

CL_Hist_up10:
	moveq	#9-1,d0
.Loop	bsr.b	CL_Hist_up
	dbf	d0,.Loop

CL_Hist_up:
	movem.l	d0-d2/a0/a1,-(sp)
	move.w	(DAIRYIN+2-DT,a4),d1	; first/oldest entry
	moveq	#-64,d2

History_stuff:
	bsr.w	CL_Shift_pijl_rechts	; move to the end of cmdline
	bsr.w	Print_Flush

	lea	(CmdLineHistoryCache-DT,a4),a0
	move.w	(DAIRYOUT-DT,a4),d0
	cmp.w	d1,d0
	beq.b	CL_Hist_Exit		; stop if oldest/newest
	add.w	d2,d0
	and.w	#(COMMANDLINECACHESIZE-1)*64,d0
	add.w	d0,a0
	move.w	d0,(DAIRYOUT-DT,a4)

	move.l	a0,-(sp)

	move.l	a6,d1
	sub.l	a5,d1
	beq.b	C14872
	subq.w	#1,d1

	btst	#MB1_DRUK_IN_MENUBAR,(MyBits-DT,a4)
	beq.s	.gewoon
.menub:
	bsr	CL_BSCommandline
	dbra	d1,.menub

	bra.b	C14872

.gewoon
	moveq	#8,d0
	bsr	Druk_char_af2
	moveq	#' ',d0
	bsr	Druk_char_af2
	moveq	#8,d0
	bsr	Druk_char_af2
	dbra	d1,.gewoon

	bsr	Print_Flush

C14872:
	bsr	C1529A
	move.l	(sp)+,a0

	moveq	#64-1,d1
	move.l	a5,a1
.CopyCmd
	move.b	(a0),d0

	btst	#MB1_DRUK_IN_MENUBAR,(MyBits-DT,a4)
	beq.s	.nomenub
	bsr	show_char_in_balk
	bra.b	.klaar
.nomenub:
	bsr	Druk_char_af2
.klaar:
	move.b	(a0)+,d0
	beq.b	.CopyDone		; don't inc a1 if zero
	move.b	d0,(a1)+
	dbra	d1,.CopyCmd
.CopyDone
	btst	#MB1_DRUK_IN_MENUBAR,(MyBits-DT,a4)
	beq.s	.nomenub2
	subq.w	#1,(menu_char_pos-DT,a4)
.nomenub2:

	move.l	a1,a3
	move.l	a3,a6
CL_Hist_Exit:
	movem.l	(sp)+,d0-d2/a0/a1
	rts

INPUT_FILLINDAIRY:
	movem.l	d0-d3/a0-a3,-(sp)
	lea	(CurrentAsmLine-DT,a4),a1
	tst.b	(a1)
	beq.b	.Done
	move.w	#(COMMANDLINECACHESIZE-1)*64,d3
	lea	(CmdLineHistoryCache-DT,a4),a0

	moveq	#-64,d0
	add.w	(DAIRYIN-DT,a4),d0
	and.w	d3,d0
	lea	(a0,d0.w),a2
	move.l	a1,a3
	moveq	#64-1,d2
.CmpPrev
	cmpm.b	(a2)+,(a3)+
	bne.b	.NotSame
	tst.b	(-1,a3)
	dbeq	d2,.CmpPrev
	bra.b	.Done
.NotSame
	movem.w	(DAIRYIN-DT,a4),d0/d1	; next/first entry
	lea	(a0,d0.w),a2
	moveq	#64-1,d2
.CopyCmd
	move.b	(a1)+,(a2)+
	dbeq	d2,.CopyCmd

	moveq	#64,d2
	add.w	d2,d0			; advance next entry
	and.w	d3,d0
	sf	(a0,d0.w)		; clear next entry
	cmp.w	d1,d0
	bne.b	.NotFull
	add.w	d2,d1			; advance first entry
	and.w	d3,d0
.NotFull
	movem.w	d0/d1,(DAIRYIN-DT,a4)	; next/first entry
	move	d0,(DAIRYOUT-DT,a4)
.Done
	movem.l	(sp)+,d0-d3/a0-a3
	rts

Druk_MsgAf_GetNumbr:
	bsr	INPUTTEXT		;drukaf text ? en vraag adres..
INPUTWORKSPACE_NOTEXT:
	lea	(CurrentAsmLine-DT,a4),a6
	bsr	Convert_A2I
	cmp.b	#NS_AVALUE,d1
	rts

INPUTBEGINEND:
	bsr.b	INPUTBEGIN_MAYBEEND
	blo.w	ERROR_Endshouldbehind		; end < start?
	rts

INPUTBEGIN_MAYBEEND:
	moveq	#0,d7		; clear flags for error handling
	lea	(BEG.MSG,pc),a0
	bsr.b	Druk_MsgAf_GetNumbr
	beq.s	.noprobs
	moveq	#-1,d2
	moveq	#0,d3
	rts
.noprobs
	move.l	d0,d2
	lea	(END.MSG0,pc),a0
	bsr.b	Druk_MsgAf_GetNumbr
	move.l	d0,d3
	sub.l	d2,d3		; must set ccr on exit
	rts

putThetextInMenubar:
	movem.l	d1-d6/a0-a3/a5/a6,-(sp)
	move.l	(MainWindowHandle-DT,a4),a1
	bset	#0,(wd_Flags+1,a1)		; set rmbtrap

	clr.w	(menu_char_pos-DT,a4)

	bsr	show_txt_in_balk

	move.l	(Cursor_pos-DT,a4),-(sp)	; col, row
	bset	#SB2_REVERSEMODE,(SomeBits2-DT,a4)
	bset	#MB1_DRUK_IN_MENUBAR,(MyBits-DT,a4)
	bsr	get_text_invoer_menuCmd
	bclr	#MB1_DRUK_IN_MENUBAR,(MyBits-DT,a4)

	bset	#SB1_WINTITLESHOW,(SomeBits-DT,a4)	;get old title back
	move	(Cursor_col_pos-DT,a4),(menu_char_pos-DT,a4)
	move.l	(sp)+,(Cursor_pos-DT,a4)	; col, row
	bclr	#SB2_REVERSEMODE,(SomeBits2-DT,a4)

	move.l	(MainWindowHandle-DT,a4),a1
	bclr	#0,(wd_Flags+1,a1)		; clear rmbtrap
	movem.l	(sp)+,d1-d6/a0-a3/a5/a6
	cmp.b	#13,d0
	rts

GetNrFromTitle:
	bsr.b	putThetextInMenubar
	bne.b	.C149EC
	lea	(CurrentAsmLine-DT,a4),a0
	moveq	#0,d0
	moveq	#10,d2
	moveq	#0,d3
.C149DA	move.b	(a0)+,d3
	sub.b	#'0',d3
	cmp.b	d2,d3
	bhs.b	.C149E8
	mulu.w	d2,d0			; potential 16-bit overflow
	add.l	d3,d0
	bra.b	.C149DA
.C149E8	moveq	#NS_AVALUE,d1
	rts
.C149EC	moveq	#0,d1
	rts

printTextInMenuStrip:
	clr.w	(menu_char_pos-DT,a4)
	clr.b	(titletxt-DT,a4)
druk_menu_txt_verder:
	movem.l	d0-d6/a0-a3/a5/a6,-(sp)
	bsr.b	show_txt_in_balk
	bset	#SB1_WINTITLESHOW,(SomeBits-DT,a4)	;get old title back
	movem.l	(sp)+,d0-d6/a0-a3/a5/a6
	rts


show_char_in_balk:
	movem.l	d0/d1/a0-a3/a6,-(sp)
	lea	(titletxt-DT,a4),a1
	move.l	a1,-(sp)
	add.w	(menu_char_pos-DT,a4),a1	;col pos

	cmp.b	#9,d0
	bne.s	.noprobs
	moveq	#' ',d0

.noprobs:
	move.b	d0,(a1)+
	addq.w	#1,(menu_char_pos-DT,a4)
	clr.b	(a1)
	bra.b	show_title_ding


show_txt_in_balk:
	movem.l	d0/d1/a0-a3/a6,-(sp)

	lea	(titletxt-DT,a4),a1
	move.l	a1,-(sp)

	add.w	(menu_char_pos-DT,a4),a1	;col pos
	moveq	#-1,d0
.lopje:
	addq.w	#1,d0
	move.b	(a0)+,(a1)+
	bne.s	.lopje

	add.w	d0,(menu_char_pos-DT,a4)

show_title_ding:
	move.l	(sp)+,a2
	move.l	(MainWindowHandle-DT,a4),a0
	lea	(-1).w,a1
	move.l	(IntBase-DT,a4),a6
	jsr	(_LVOSetWindowTitles,a6)
	bclr	#SB1_WINTITLESHOW,(SomeBits-DT,a4)
	movem.l	(sp)+,d0/d1/a0-a3/a6
C14A84:
	rts

RESETMENUTEXT:
	btst	#SB1_WINTITLESHOW,(SomeBits-DT,a4)
	beq.b	C14A84
RESETMENUTEXT2:
	movem.l	d0/d1/a0-a3/a6,-(sp)
	pea	(AsmPro_titletxt.MSG,pc)
	bra.b	show_title_ding

;**************** DRUK TEXT IN COMMAND SHELL *******************

Druk_regel_in_commandshell:
	movem.l	d0-d7/a0-a3/a5/a6,-(sp)
	tst.l	d3
	beq.b	C14B54
.menustate:
	move.l	(MainWindowHandle-DT,a4),a1
	tst.b	($1A,a1)	;bit7 (menustate) set?
	bmi.b	.menustate

	move.l	d2,a0
	bsr.b	_Show_Cursor
	bsr.b	Print_d3_chars
	bsr.b	_Show_Cursor
C14B54:
	movem.l	(sp)+,d0-d7/a0-a3/a5/a6
	rts

_Show_Cursor:
	jmp	(Show_Cursor)

MoveCursorToPos:
	movem.l	d0-d1/a0-a1/a6,-(sp)
	move.w	d6,d0
	mulu.w	(EFontSize_x-DT,a4),d0
	move.w	d7,d1
	lsr.w	#1,d1
	mulu.w	(EFontSize_y-DT,a4),d1
	add.w	(Scr_Title_sizeTxt-DT,a4),d1

	move.l	(GfxBase-DT,a4),a6
	move.l	(Rastport-DT,a4),a1
	jsr	(_LVOMove,a6)
	movem.l	(sp)+,d0-d1/a0-a1/a6
	rts

Print_d3_chars:
	subq.w	#1,d3
	jsr	(get_font)
	movem.w	(Cursor_pos-DT,a4),d6/d7 	;col, row
	bsr.b	MoveCursorToPos
	lea	(regel_buffer-DT,a4),a1		;command
print_char_CL:
	moveq	#0,d0
	move.b	(a0)+,d0
	cmp.b	#$9B,d0
	beq	text_offset_stuff
	cmp.b	#' ',d0
	bcs.b	text_white_space

	move.b	d0,(a1)+			;stop char in buffer

	addq.w	#1,d6
	cmp	(Scr_br_chars-DT,a4),d6	;buffer is ook maar 256 bytes..
	bne.b	PRINT_SKIP1
CR_DUS_NEXT_REGEL:
	bsr.b	CL_PrintLimitedText

	moveq	#0,d6
	addq.w	#2,d7
	cmp	(Max_Hoogte-DT,a4),d7
	bne.b	alleen_CL_movecurs
	move	(aantal_regels_min3_div2-DT,a4),d7	;buiten het scherm dus scrollen
	bsr	scroll_up_cmdmode

;2de kolom..
alleen_CL_movecurs:
	bsr	MoveCursorToPos
PRINT_SKIP1:
	dbf	d3,print_char_CL

	bsr.b	CL_PrintLimitedText

CL_cursorstuff:
	movem.w	d6/d7,(Cursor_pos-DT,a4)	; col, row
	rts

CL_PrintLimitedText:
	movem.l	d0-d1/a0/a6,-(sp)
	lea	(regel_buffer-DT,a4),a0		;command
	move.l	a1,d0
	sub.l	a0,d0		; count
	cmp.w	#255,d0		; gfxlib takes 16-bit length
	bhi.b	.TooLong
	move.l	(GfxBase-DT,a4),a6
	move.l	(Rastport-DT,a4),a1
	jsr	(_LVOText,a6)
.TooLong
	movem.l	(sp)+,d0-d1/a0/a6
	lea	(regel_buffer-DT,a4),a1		;command
	rts

text_white_space:
	cmp.b	#10,d0	;LF
	beq.b	CR_DUS_NEXT_REGEL
	cmp.b	#13,d0	;CR
	beq.b	CL_CReturn
	cmp.b	#8,d0	;BS
	beq.b	CL_BackSpace
	cmp.b	#9,d0	;TAB
	beq.b	.tabulator
	cmp.b	#12,d0	;FF
	beq	clear_plane1_en2
	bra.b	PRINT_SKIP1

.tabulator:
	move.b	#" ",(a1)+
	addq.w	#1,d6

	bra.b	PRINT_SKIP1


CL_BackSpace:	;BS
	subq.w	#1,d6
	bpl.b	alleen_CL_movecurs
	moveq	#0,d6
	move	(Scr_br_chars-DT,a4),d6
	subq.w	#1,d6
	subq.w	#2,d7
	bpl.b	alleen_CL_movecurs
	moveq	#0,d7
	bra.b	alleen_CL_movecurs

CL_CReturn:	;CR
	moveq	#0,d6
	bra.b	alleen_CL_movecurs

;***************************************

text_offset_stuff:
;	addq.l	#1,a0
	subq.w	#1,d3
	bmi.b	CL_cursorstuff
C14EC0:
	moveq	#0,d1
.C14EC2
	moveq	#0,d0
	move.b	(a0)+,d0
	cmp.b	#$3A,d0		;':'  0..9
	bcc.b	C14EE4
	cmp.b	#$2F,d0		;'/'
	bls.w	PRINT_SKIP1
	sub	#$30,d0
	mulu	#10,d1
	add	d0,d1
	dbra	d3,.C14EC2
	bra.w	CL_cursorstuff

C14EE4:
	cmp.b	#$3B,d0		;';'
	beq.b	PRINT_SETCORDY
	cmp.b	#$48,d0		;'H' ->
	beq.b	PRINT_SETCORDX
	cmp.b	#$4B,d0		;'K'
	beq.b	PRINT_DELETEEOL
	cmp.b	#$44,d0		;'D' <-
	beq.b	PRINT_CURSORNLEFT
	cmp.b	#$6D,d0		;'m' inverse
	beq.b	PRINT_SET_BOLD
	br	PRINT_SKIP1

C14F06:
	dbra	d3,C14EC0
	br	CL_cursorstuff

PRINT_SET_BOLD:
	bchg	#SB2_REVERSEMODE,(SomeBits2-DT,a4)	;toggle inverse font
	jsr	(get_font)
	br	PRINT_SKIP1

PRINT_CURSORNLEFT:
	sub	d1,d6
C14F1E:
	tst	d6
	bpl.w	alleen_CL_movecurs	;niet begin regel
	add.w	(Scr_br_chars-DT,a4),d6	;!3
	subq.w	#2,d7			;niet begin y
	bpl.b	C14F1E
	moveq	#0,d7
	br	alleen_CL_movecurs

PRINT_SETCORDX:
	subq.w	#1,d1
	bmi	PRINT_SKIP1
	cmp	(Scr_br_chars-DT,a4),d1
	blo.b	C14F46
	move	(Scr_br_chars-DT,a4),d1
	subq.w	#1,d1
C14F46:
	move	d1,d6
	br	alleen_CL_movecurs

PRINT_SETCORDY:
	subq.w	#1,d1
	bmi.b	C14F06
	cmp	(aantal_regels_min2-DT,a4),d1
	blo.b	.C14F60
	move	(aantal_regels_min3-DT,a4),d1
	bsr	scroll_up_cmdmode
.C14F60
	add.w	d1,d1		;!!! there is an enforcer hit somewhere around here..
	move	d1,d7
	move.l	a6,a1
	IF	MC020
	add.l	(a5,d1.w*2),a1
	ELSE
	add.w	d1,d1
	add.l	(a5,d1.w),a1
	ENDIF
	bra.b	C14F06

PRINT_DELETEEOL:
	btst	#SB2_REVERSEMODE,(SomeBits2-DT,a4)	;is inverse?
	beq.b	clear_2_eol
	move	d6,(Cursor_col_pos-DT,a4)
;	bsr	clear_menu_balk
	br	alleen_CL_movecurs

clear_2_eol:
	movem.l	d0-a6,-(sp)

	move.l	(GfxBase-DT,a4),a6
	move.l	(Rastport-DT,a4),a1

	move.w	d6,d0		;x
	mulu.w	(EFontSize_x-DT,a4),d0
	move.w	d7,d1		;y
	lsr.w	#1,d1
	mulu.w	(EFontSize_y-DT,a4),d1

	add.w	(Scr_Title_sizeTxt-DT,a4),d1	;!2
	jsr	(_LVOMove,a6)

	jsr	(_LVOClearEOL,a6)
	movem.l	(sp)+,d0-a6

	br	alleen_CL_movecurs

;*********** CURSOR STUFF ***********

Place_cursor_blokje:
	move	(cursor_row_pos-DT,a4),d7	; y
	bne.b	.algoed
	jsr	(ParseCustomTabs)
.algoed:
	movem.l	d0-a6,-(sp)

	move.l	(GfxBase-DT,a4),a6
	move.l	(Rastport-DT,a4),a1

	moveq	#3,d0
	jsr	(_LVOSetAPen,a6)
	moveq	#2,d0			; inverse
	jsr	(_LVOSetDrMd,a6)

	move.w	(Cursor_col_pos-DT,a4),d0	; x
	mulu.w	(EFontSize_x-DT,a4),d0

	move.w	d7,d1
	lsr.w	#1,d1
	mulu.w	(EFontSize_y-DT,a4),d1

	add.w	(Scr_Title_size-DT,a4),d1

	movem.w	d0/d1,-(sp)
	move.w	(reset_pos-DT,a4),d0	; cursor x
	bmi.b	.ok			; Reset caret
	move.w	(reset_pos+2-DT,a4),d1	; cursor y
	cmp.w	(sp),d1			; Old values are differents ?
	bne.b	.print
	cmp.w	2(sp),d0
	bne.b	.print
	movem.w	(sp)+,d0/d1
	bra.b	.klaarhoor		; Same position: leave it as is
.print
	bsr.b	.blokje			; Clear it at old position
	move.l	(Rastport-DT,a4),a1
.ok:
	movem.w	(sp)+,d0/d1
	movem.w	d0/d1,(reset_pos-DT,a4)	; Save old values
	bsr.b	.blokje			; Display it at new position
.klaarhoor:
	move.l	(GfxBase-DT,a4),a6
	move.l	(Rastport-DT,a4),a1

	moveq	#1,d0
	jsr	(_LVOSetAPen,a6)
	moveq	#0,d0
	jsr	(_LVOSetBPen,a6)
	moveq	#1,d0			;jam2
	jsr	(_LVOSetDrMd,a6)

	movem.l	(sp)+,d0-a6
	rts

.blokje:
	movem.w	(EFontSize_xy-DT,a4),d2/d3
	add.w	d0,d2
	add.w	d1,d3
	subq.w	#1,d2
	subq.w	#1,d3
	jsr	(_LVORectFill,a6)
	jmp	_LVOWaitBlit(a6)


;********* NEW SCROLL ROUTINES ***************
;They should work on a gfx board now..

scroll_up_cmdmode:
	movem.l	d0-d5/a0-a6,-(sp)

	move.l	(GfxBase-DT,a4),a6
;	jsr	_LVOWaitBlit(a6)
;	jsr	_LVOWaitTOF(a6)

	move.l	(Rastport-DT,a4),a1

	moveq	#0,d0				; dx
	move.w	(EFontSize_y-DT,a4),d1		; dy
	tst.b	(Asm_Multiscroll-DT,a4)
	beq.b	.SingleLine
	lsl.w	#3,d1				; scroll by 8 lines
	sub.w	#(8-1)*2,d7
	bsr	MoveCursorToPos
.SingleLine
	moveq	#0,d2				; xmin
	move.w	(Scr_Title_size-DT,a4),d3	; ymin
	move.w	(Scr_breedte-DT,a4),d4		; xmax
	move.w	(ScreenHight-DT,a4),d5		; ymax
	mulu.w	(EFontSize_y-DT,a4),d5
	addq.w	#2,d5		;correctie
	jsr	_LVOScrollRaster(a6)	;-396

	movem.l	(sp)+,d0-d5/a0-a6
	rts

scroll_up_cmd_fix:
	movem.l	d0-a6,-(sp)
	bsr.w	_Show_Cursor

	move.l	(GfxBase-DT,a4),a6
;	jsr	_LVOWaitBlit(a6)
;	jsr	_LVOWaitTOF(a6)
	move.l	(Rastport-DT,a4),a1

	moveq	#0,d0		;dx
	moveq	#5,d1		;dy
	moveq	#0,d2		;x1
	move.w	(Scr_Title_size-DT,a4),d3 ;y1
	move.w	(Scr_breedte-DT,a4),d4
	move.w	(ScreenHight-DT,a4),d5
	mulu.w	(EFontSize_y-DT,a4),d5
	addq.w	#2+4,d5		;correctie?

	jsr	_LVOScrollRaster(a6)	;-396

	bsr.w	_Show_Cursor
	movem.l	(sp)+,d0-a6
	rts

;**********************************************

clear_screen:
	movem.l	d0-d1/a0-a1/a6,-(sp)

	move.l	(GfxBase-DT,a4),a6
	move.l	(Rastport-DT,a4),a1

	moveq	#0,d0		;x
	move.w	(Scr_Title_sizeTxt-DT,a4),d1	;y
	jsr	(_LVOMove,a6)

	move.l	(Rastport-DT,a4),a1
	jsr	(_LVOClearScreen,a6)
	movem.l	(sp)+,d0-d1/a0-a1/a6
	rts

clear_plane1_en2:
	bsr.b	clear_screen

	moveq	#0,d6
	moveq	#0,d7
	br	alleen_CL_movecurs

;********* NEW SCROLL ROUTINES ***************
;They should work on a gfx board now..

ScrollEditorUp:
	movem.l	d0-a6,-(sp)

	move.l	(GfxBase-DT,a4),a6

;	tst.w	PR_WaitTOF
;	beq.s	.nowaitof
;	jsr	_LVOWaitBlit(a6)
;	jsr	_LVOWaitTOF(a6)
;.nowaitof:

	tst.w	PR_CustomScroll
	bne.s	ScrollEditorUpHard

	move.l	(Rastport-DT,a4),a1
	moveq	#0,d0		;dx
	move.w	(EFontSize_y-DT,a4),d1	; dy

	moveq	#0,d2		;xmin
	move.w	(Scr_Title_size-DT,a4),d3	;ymin

	move.w	(Scr_breedte-DT,a4),d4		;xmax

	move.w	(NrOfLinesInEditor+2-DT,a4),d5
	addq.w	#1,d5
;	sub.w	d6,d5
	mulu.w	(EFontSize_y-DT,a4),d5		;ymax

	jsr	_LVOScrollRaster(a6)

	movem.l	(sp)+,d0-a6
	rts

;faster custom scroll routine not system friendly

ScrollEditorUpHard:
	move.l	(Rastport-DT,a4),a5
	move.l	4(a5),a5	;str bitmap
	move.l	8(a5),a5	;eerste bitmapptr

	move.l	(EditScrollSizeTitleUp-DT,a4),d2	;2624	;by 656b
	move.w	(EditScrollRegelSize-DT,a4),d3		;2132	;2*82*13

	add.l	d2,a5
	move.l	a5,a6
	add.w	d3,a5		;2*82*13

	move.w	(Edit_nrlines-DT,a4),d7	;aantal editorbeeldlijntjes -1

;	cmp.w	#PB_040,(ProcessorType-DT,a4)
;	bhs.s	Scrollcpu040up

;Scrollcpu030up:
;	move.w	#$0f0,$dff180
.lopje:
	rept	2
	movem.l	(a5)+,d0-d4/a0-a4
	movem.l	d0-d4/a0-a4,(a6)
	lea	40(a6),a6
	endr
	dbf	d7,.lopje
	movem.l	(sp)+,d0-a6
	rts

;Scrollcpu040up:
;	jsr	test_debug
;.lopje:
;	rept	5
;	move16	(a5)+,(a6)+
;	endr
;	dbf	d7,.lopje
;	movem.l	(sp)+,a0-a6
;	rts


;********* NEW SCROLL ROUTINES ***************
;They should work on a gfx board now..

ScrollEditorDown:
	movem.l	a0-a6,-(sp)

	move.l	(GfxBase-DT,a4),a6

;	tst.w	PR_WaitTOF
;	beq.s	.nowaitof
;	jsr	_LVOWaitBlit(a6)
;	jsr	_LVOWaitTOF(a6)
;.nowaitof:

	tst.w	PR_CustomScroll
	bne.s	ScrollEditorDownHard

;ScrollEditorDownSoft:

	move.l	(Rastport-DT,a4),a1

	moveq	#0,d0		;dx
	moveq	#0,d1		;dy
	sub.w	(EFontSize_y-DT,a4),d1
	moveq	#0,d2		;x1
	move.w	(Scr_Title_size-DT,a4),d3

	move.w	(Scr_breedte-DT,a4),d4

;	move.w	(Edit_nrlines-DT,a4),d5
	move.w	(NrOfLinesInEditor+2-DT,a4),d5
	addq.w	#1,d5
	mulu.w	(EFontSize_y-DT,a4),d5
	addq.w	#2,d5

	jsr	_LVOScrollRaster(a6)	;scrollraster ;-396

	movem.l	(sp)+,a0-a6
	rts


;faster custom scroll routine not system friendly

ScrollEditorDownHard:
	move.l	(Rastport-DT,a4),a5
	move.l	4(a5),a5	;str bitmap
	move.l	8(a5),a5	;eerste bitmapptr

	move.l	(EditScrollSizeTitleDown-DT,a4),d2
	moveq	#0,d3
	move.w	(EditScrollRegelSize-DT,a4),d3

	move.l	(NrOfLinesInEditor-DT,a4),d5
	cmp.w	(NumLines_HalfEditor-DT,a4),d5
	bne.b	.nodiv
	sub.l	d3,d2
	lsr.l	#1,d2
.nodiv
	add.l	d2,a5
	lea	(a5,d3.w),a6

	move.w	(Edit_nrlines-DT,a4),d7	;aantal editorbeeldlijntjes -1
.lopje:
	rept	2
	lea	-40(a5),a5
	movem.l	(a5),d0-d4/a0-a4
	movem.l	d0-d4/a0-a4,-(a6)
	endr
	dbf	d7,.lopje
	movem.l	(sp)+,a0-a6
	rts


;**********************************************


C1529A:
	moveq	#$9B-256,d0
	bsr	Druk_char_af2
	moveq	#'H',d0
	br	Druk_char_af2

Debug_PrintStatusBalk2:
	sub.l	a0,a0
	bra.b	vulin_infobar

StatusBar_monitor:
	moveq	#1,d7
	lea	(MoniStatusBar.MSG,pc),a0
	bra.b	vulin_infobar

PrintStatusBalk:
	moveq	#2,d7
	lea	(DbgStatusBar.MSG,pc),a0
vulin_infobar:
	movem.l	d0-d7/a0-a3/a5/a6,-(sp)
;	bsr	Place_cursor_blokje

;	jsr	get_font1
	jsr	get_font4

	move.l	a0,-(sp)

	move.l	(GfxBase-DT,a4),a6
	move.l	(Rastport-DT,a4),a1
	moveq	#0,d0	;x

	move.l	(NrOfLinesInEditor-DT,a4),d1
	mulu.w	(EFontSize_y-DT,a4),d1
	add.w	(Scr_Title_size-DT,a4),d1
	addq.w	#1,d1

	move.w	(Scr_breedte-DT,a4),d2	;x-max
	move.w	d1,d3
;	add.w	#FontSize_y+4,d3	;y-max
	add.w	(EFontSize_y-DT,a4),d3
	addq.w	#4,d3
	jsr	_LVOEraseRect(a6)

	move.l	(Rastport-DT,a4),a1
	moveq	#0,d0		;x
	move.l	(NrOfLinesInEditor-DT,a4),d1
	mulu.w	(EFontSize_y-DT,a4),d1
	add.w	(Scr_Title_sizeTxt-DT,a4),d1	;!2
	addq.w	#2,d1		;title size
	jsr	(_LVOMove,a6)

	move.l	(sp)+,d0
	beq.w	.klaar
	move.l	d0,a0

	moveq	#78-13,d0
	jsr	(_LVOText,a6)

	moveq	#-10,d2
	add.w	(Scr_br_chars-DT,a4),d2
	lea	(time1,pc),a1
	move.w	d2,(a1)
	move.w	d2,(time2-time1,a1)

	move.l	(GadToolsBase-DT,a4),a6
	lea	(PW_NR,pc),a1
	move.l	(MainVisualInfo-DT,a4),4(a1)

	move.l	(Rastport-DT,a4),a0

	moveq	#1,d0		;x
	move.l	(NrOfLinesInEditor-DT,a4),d1
	mulu.w	(EFontSize_y-DT,a4),d1
	add.w	(Scr_Title_size-DT,a4),d1
	move.w	d1,d6
	addq.w	#1,d6

	move.w	(Scr_breedte-DT,a4),d2	;br
	subq.w	#3,d2
	move.w	(EFontSize_y-DT,a4),d3
	addq.w	#4,d3
	jsr	_LVODrawBevelBoxA(a6)

;	move.l	(Rastport-DT,a4),d5
;	move.l	#PW_IR,d4
	move.w	(EFontSize_y-DT,a4),d3	;hoog
	addq.w	#2,d3

	lea	bevc(pc),a5
	IF	MC020
	add.w	(a5,d7.w*2),a5
	ELSE
	add.w	d7,d7
	add.w	(a5,d7.w),a5
	ENDIF

	move.w	(a5)+,d7
	bra.b	.go

.lopje:
	move.l	(Rastport-DT,a4),a0
	lea	(PW_IR,pc),a1

	move.w	(a5)+,d0	;x
	mulu.w	(EFontSize_x-DT,a4),d0
	subq.w	#3,d0
	move.w	d6,d1		;y
	move.w	(a5)+,d2	;br
	mulu.w	(EFontSize_x-DT,a4),d2
	addq.w	#5,d2
	jsr	_LVODrawBevelBoxA(a6)
.go
	dbf	d7,.lopje

.klaar:
;	bsr	Place_cursor_blokje
	movem.l	(sp)+,d0-d7/a0-a3/a5/a6
	rts

bevc:
	DC.W	bevcoords1-bevc
	DC.W	bevcoords2-bevc
	DC.W	bevcoords3-bevc

;editor
bevcoords3:
	dc.w	7
	dc.w	7	;x
	dc.w	7	;br

	dc.w	20	;x
	dc.w	3	;br

	dc.w	31	;x
	dc.w	7	;br

	dc.w	46	;x
	dc.w	5	;br

	dc.w	52	;x
	dc.w	5	;br

	dc.w	61	;x
	dc.w	4	;br
time1:
	dc.w	70	;x
	dc.w	8	;br

;monitor
bevcoords2:
	dc.w	5

	dc.w	8	;x
	dc.w	9	;br

	dc.w	23	;x
	dc.w	9	;br

	dc.w	39	;x
	dc.w	9	;br

	dc.w	54	;x
	dc.w	9	;br
time2:
	dc.w	70	;x
	dc.w	8	;br

bevcoords1:
	dc.w	0

; A0 = LENGTH TEXT [ LOCATION TEXT ]

Writefile_afwerken:
	bsr	printthetext
	move.l	(FileLength-DT,a4),d0
	bsr	PRINTDECIMALLONG
	lea	(Filelength2.MSG,pc),a0
	bsr	printthetext
	move.l	(FileLength-DT,a4),d0
	bsr	druk_af_d0
	bsr	druk_af_space
	moveq	#')',d0
	bsr	SENDONECHARNORMAL
	bsr	druk_cr_nl
	bra.w	Druk_Clearbuffer

;****************************
;*    PRINT SYMBOL TABLE    *
;****************************

com_PRINT_SYMBOLTABEL:
	st	(B30048-DT,a4)
	clr	(PageNumber-DT,a4)
	move	(aantal_regels_min2-DT,a4),(PageHeight-DT,a4)
	move	(Scr_br_chars-DT,a4),(PageWidth-DT,a4)
	clr	(PageLinesLeft-DT,a4)
	bset	#AF_LISTFILE,d7
	bset	#0,(PR_Paging).l
	bset	#0,(PR_HaltPage).l
PRINT_SYMBOLTABELMAYBE:
	btst	#AF_LISTFILE,d7
	beq	.end
	tst	(DATA_NUMOFGLABELS-DT,a4)
	beq	.end
	move.l	(LabelStart-DT,a4),a0
	cmp.b	#$7F,-(a0)
	bne	.end

	bsr	PRINT_PAGED
	move.l	(LabelStart-DT,a4),a2
	moveq	#1,d4
	cmp.b	#$FF,(B30048-DT,a4)
	bne.b	.C15410

	move.b	#'@',(B30048-DT,a4)
	move.b	#'0',(B30049-DT,a4)
	addq.w	#1,a6
	tst.b	(a6)
	beq.b	.C15410
	move.b	(a6)+,d0
	cmp.b	#'@',d0
	blt.b	.C15410
	move.b	d0,(B30048-DT,a4)
	tst.b	(a6)
	beq.b	.C153BC
	move.b	(a6)+,d0
	cmp.b	#'0',d0
	blt.b	.C153BC
	move.b	d0,(B30049-DT,a4)
.C153BC:
	moveq	#5,d0
	btst	#0,(PR_Upper_LowerCase).l
	beq.b	.C153D4
	bclr	d0,(B30048-DT,a4)
	bclr	d0,(B30049-DT,a4)
.C153D4:
	move.b	(B30048-DT,a4),d0
	sub	#'@',d0
	bcs.b	.C15410
	lsl.w	#2,d0
	mulu	(Label2Entry-DT,a4),d0
	add.l	d0,a2
	move.b	(B30048-DT,a4),d5
	moveq	#0,d0
	move.b	(B30049-DT,a4),d0
	moveq	#'@',d6
	add.w	(Label1Entry-DT,a4),d6
	cmp	d6,d0
	bgt.b	.loop2
	sub	#'0',d0
	bcs.b	.loop2

	IF MC020
	lea	(a2,d0.w*4),a2
	ELSE
	lsl.w	#2,d0
	add.l	d0,a2
	ENDC

	move.b	(B30049-DT,a4),d6
	bra.b	.loop1

.C15410:
	moveq	#'@',d5
.loop2:
	moveq	#'0',d6
.loop1:
	move.l	(a2)+,a3
	bsr.b	.printTree
	addq.b	#1,d6
	moveq	#'0',d0
	add	(Label2Entry-DT,a4),d0
	cmp.b	d0,d6
	bne.b	.loop1
	addq.b	#1,d5
	moveq	#'@',d0
	add	(Label1Entry-DT,a4),d0
	cmp.b	d0,d5
	bne.b	.loop2
	br	druk_cr_nl

.printTree:
	move.l	a3,-(sp)
	beq.b	.theend
	move.l	(a3),a3
	bsr.b	.printTree
	move.l	(sp),a0
	addq.w	#8,a0
	bsr.b	.PRINTONENAME
	move.l	(sp),a3
	move.l	(4,a3),a3
	bsr.b	.printTree
.theend:
	move.l	(sp)+,a3
.end:
	bra.w	Druk_Clearbuffer

.PRINTONENAME:
	bchg	#0,d4
	beq.b	.C1545C
	bsr	druk_cr_nl
	bsr	PRINT_PAGED
.C1545C:
	move.b	d5,d0
	bsr	.SPECIAL_PRINT
	move.b	d6,d0
	bsr	.SPECIAL_PRINT
	move	(PageWidth-DT,a4),d1
	lsr.w	#1,d1
	sub	#16,d1
.C15472:
	move.b	(a0)+,d0
	bmi.b	.C1548E
	bsr.b	.SPECIAL_PRINT
	move.b	(a0)+,d0
	subq.w	#1,d1
	bmi.b	.C15488
	bsr.b	.SPECIAL_PRINT
	subq.w	#1,d1
	bpl.b	.C15472
.C15488:
	tst	(a0)+
	bpl.b	.C15488
	bra.b	.C1549E

.C1548E:
	bclr	#7,d0
	bsr.b	.SPECIAL_PRINT
	move.b	(a0)+,d0
	subq.w	#1,d1
	bmi.b	.C1549E
	bsr.b	.SPECIAL_PRINT
	subq.w	#1,d1
.C1549E:
	addq.w	#1,d1
.puntlopje:
	moveq	#'.',d0
	bsr	SENDONECHARNORMAL
	dbra	d1,.puntlopje

	addq.w	#1,a0
	move.l	a0,d0
	bclr	#0,d0
	move.l	d0,a0
	move	(a0),d0
	bmi.b	.ItsAMacro
.C154B8:
	move	(a0)+,d0
	bsr	C15908
	moveq	#'.',d0
	bsr	SENDONECHARNORMAL
	move.l	(a0)+,d0
	bsr	druk_af_d0
.C154CA:
	btst	#0,d4
	bne	.end
	bra.w	druk_af_space

.ItsAMacro:
	lsr.w	#7,d0
	and	#$007E,d0
	cmp	#2,d0
	beq.b	.C154B8

	lea	(.symboltabje,pc,d0.w),a0
	add	(a0),a0
	bsr	printthetext
	bra.b	.C154CA

.symboltabje:
	dr.w	st_macro
	dc.w	0
	dr.w	st_xref
	dr.w	st_equr
	dr.w	st_reg

.SPECIAL_PRINT:
	tst.b	d0
	beq.b	.NEXT1
	cmp.b	#'@',d0
	beq.b	.NEXT1
	cmp.b	#':',d0
	beq.b	.NEXT1
	cmp.b	#'[',d0
	bne.b	.NEXT2
	moveq	#'_',d0
.NEXT2:
	cmp.b	#'?',d0
	bne.b	.NEXT0
.NEXT1:
	moveq	#'.',d0
.NEXT0:
	br	SENDONECHARNORMAL


;*   Print assembling now   *

PRINT_ASSEMBLING_NOW:
	bsr.b	PRINT_ASSEMBLING
	bra.w	Druk_Clearbuffer

;*   Print assembling   *

PRINT_ASSEMBLING:
	bsr	PRINT_PAGED
	move.l	(DATA_CURRENTLINE-DT,a4),d0
	bsr	DrukAf_LineNrPrint
	move	(ResponseType-DT,a4),d2
	bpl.b	C1557C
	lsr.w	#8,d2
	and.b	#$3F,d2
	beq.b	C1554C
	subq.b	#1,d2		; LB_SET?
	beq.b	C15550
	jmp	(ERROR_NOTaconstantl).l

C1554C:
	moveq	#$10,d5
	bra.b	C155C2

C15550:
	moveq	#11,d1
C15552:
	bsr	druk_af_space
	dbra	d1,C15552
	moveq	#'=',d0
	bsr	SENDONECHARNORMAL
	move	(ResponseType-DT,a4),d0
	bsr	C15908
	moveq	#'.',d0
	bsr	SENDONECHARNORMAL
	move.l	(ResponsePtr-DT,a4),a0
	move.l	a0,d0
	bsr	druk_af_d0
	moveq	#4,d5
	bra.b	C155C2

C1557C:
	move.l	(ResponsePtr-DT,a4),a0
	cmp.l	(INSTRUCTION_ORG_PTR-DT,a4),a0
	beq.b	C1554C
	move	(ResponseType-DT,a4),d0
	bsr	C15908
	moveq	#'.',d0
	bsr	SENDONECHARNORMAL
	move.l	a0,d0
	bsr	druk_af_d0_space
	tst	d7	;passone
	bmi.b	C155EE
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),d4
	moveq	#10,d5
	sub.l	a0,d4
	beq.b	C155C2
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
	moveq	#10,d0
	cmp.l	d0,d4
	bls.b	C155B4
	moveq	#10,d4
C155B4:
	sub	d4,d5
	subq.w	#1,d4
C155B8:
	move.b	(a0)+,d0
	bsr	C15908
	dbra	d4,C155B8
C155C2:
	add.w	d5,d5
C155C4:
	bsr	druk_af_space
	dbra	d5,C155C4
C155CC:
	move.l	(DATA_LINE_START_PTR-DT,a4),a0
	moveq	#-$0029,d2
	add.w	(PageWidth-DT,a4),d2
	move	d2,d1
C155DA:
	move.b	(a0)+,d0
	beq.b	C15614
	cmp.b	#9,d0
	beq.b	C155FC
	bsr	SENDONECHARNORMAL
	dbra	d1,C155DA
	bra.b	C15614

C155EE:
	moveq	#$14,d2
C155F0:
	bsr.w	druk_af_space
	dbra	d2,C155F0
	bra.b	C155CC

C155FC:
	bsr	druk_af_space
	dbra	d1,C15606
	bra.b	C15614

C15606:
	move.w	d2,d0
	sub.w	d1,d0
	and	#7,d0
	bne.b	C155FC
	bra.b	C155DA

C15614:
	br	druk_cr_nl

PRINT_PAGED:
	btst	#AF_LISTFILE,d7
	beq.b	C15682
	btst	#0,(PR_Paging).l
	beq.b	C15682
	subq.w	#1,(PageLinesLeft-DT,a4)
	bpl.b	C15682
	move.l	a0,-(sp)
	tst	(PageNumber-DT,a4)
	beq.b	C15644
	btst	#0,(PR_HaltPage).l
	beq.b	C15644
	bsr	Get_me_a_char
C15644:
	lea	(Page.MSG,pc),a0
	bsr	printthetext
	addq.w	#1,(PageNumber-DT,a4)
	move	(PageHeight-DT,a4),d0
	subq.w	#2,d0
	move	d0,(PageLinesLeft-DT,a4)
	move	(PageNumber-DT,a4),d0
	bsr	PRINTDECIMALWORD
	tst.b	(TITLE_STRING-DT,a4)
	beq.b	C15676
	lea	(Of.MSG,pc),a0
	bsr.b	printthetext
	lea	(TITLE_STRING-DT,a4),a0
	bsr.b	printthetext
C15676:
	bsr	druk_cr_nl
	bsr	druk_cr_nl
	move.l	(sp)+,a0
C15682:
	rts

PRINTINCLUDENAME:
	movem.l	d0-d7/a0-a6,-(sp)
	bsr.b	printthetext		;Incbin  : "
	move.l	a0,-(sp)
	lea	(CurrentAsmLine-DT,a4),a0
	movem.l	d1/a6,-(sp)
	move.l	a0,a6
	moveq	#0,d1
.C1569A
	move.b	(a6)+,d0
	beq.b	.DA_EndFilename
	cmp.b	#':',d0
	bne.b	.C1569A
	addq.w	#1,d1
	bra.b	.C1569A

.DA_EndFilename
	subq.w	#1,d1
	bgt.b	C156B8
	tst.b	(FilenameBuffSelect-DT,a4)
	beq.b	C156BC
C156B8:
	lea	(SourceCode-DT,a4),a0
C156BC:
	bsr.b	.strcount
	movem.l	(sp)+,d1/a6
	bsr.b	PrintMsgText	; dh1:asmpro_os/pics/asm-pro48x74.iff
	move.l	(sp)+,a0
	bsr.b	printthetext
	movem.l	(sp)+,d0-d7/a0-a6
	rts

.strcount:
	move.l	a0,a6
	moveq	#-(27-2+13)+1,d1
	add.w	(Scr_br_chars-DT,a4),d1
.lopje	subq.w	#1,d1
	tst.b	(a6)+
	bne.b	.lopje
	tst.w	d1
	bpl.s	.nothin
	sub.w	d1,a0
.nothin
	rts

drukke2:
	bsr	SENDONECHARNORMAL
printthetext:
	move.b	(a0)+,d0
	bne.b	drukke2
	rts

drukke:
	bsr	SENDONECHARNORMAL
PrintMsgText:
	move.l	(text_buf_ptr-DT,a4),d0
	sub.l	#TextPrintBuffer,d0

	moveq	#-(27-2),d7
	add.w	(Scr_br_chars-DT,a4),d7
	cmp.w	d7,d0
	bhi.s	.klaar

	move.b	(a0)+,d0
	bne.b	drukke

	move.l	(text_buf_ptr-DT,a4),d0
	sub.l	#TextPrintBuffer,d0

	sub.w	d0,d7
.lopje	bsr	druk_af_space
	dbf	d7,.lopje
.klaar
	rts


C156DA:
	bsr	SENDONECHARNORMAL
	moveq	#0,d0
	sub.b	(a0)+,d0
	bne.b	C156DA
	br	SENDONECHARNORMAL

C156E8:
	bsr.b	Druk_Clearbuffer
C156EE:
	move.b	(a0)+,d0
	bsr.b	cmd_put_char_in_buffer
	tst.b	d0
	bne.b	C156EE
	rts

C156F8:
	bsr	Druk_char_af2
druk_status_en_end_af:
	move.b	(a0)+,d0
	bne.b	C156F8
	rts

beeldtextaf:
	bsr.b	printthetext
	bra.b	SENDONECHARNORMAL


update_status_bar:
	bsr.b	druk_status_en_end_af
	bra.b	SENDONECHARNORMAL

C1570A:
	bsr.b	SENDONECHARNORMAL
	move.b	(a0)+,d0
	bpl.b	C1570A
	and	#$007F,d0
	bra.b	SENDONECHARNORMAL

Druk_Clearbuffer:
	moveq	#0,d0
	bra.b	SENDONECHARNORMAL

druk_cr_nl:
	move.l	d0,-(sp)
	moveq	#13,d0
	bsr.b	SENDONECHARNORMAL
	bsr.b	Druk_af_eol
	move.l	(sp)+,d0
	rts

Druk_af_eol:
	moveq	#10,d0
	bra.b	SENDONECHARNORMAL

cmd_put_char_in_buffer:
	move.l	a0,-(sp)
	move.l	(text_buf_ptr-DT,a4),a0
	tst.b	d0
	beq.b	.eol_afdrukken
	move.b	d0,(a0)+
	cmp.l	#text_buf_ptr-1,a0	;buffer vol? dan ook afdrukken
	bne	C15858
.eol_afdrukken:
	movem.l	d0-d3,-(sp)
	move.l	a0,d3
	move.l	#TextPrintBuffer,d2
	sub.l	d2,d3			;strlen
	beq	C15854
	move.l	d2,(text_buf_ptr-DT,a4)	;reset ptr
	btst	#0,(PR_PrintDump).l
	beq.b	.C15768
	bsr	druk_af_op_printer
.C15768	movem.l	(sp)+,d0-d3/a0
	rts

druk_eol:
	movem.l	d0-a6,-(sp)
	bclr	#SB1_CHANGE_MODE,(SomeBits-DT,a4)
	bsr.b	Druk_Clearbuffer
	movem.l	(sp)+,d0-a6
	rts

druk_af_space:
	moveq	#" ",d0

SENDONECHARNORMAL:
	tst.b	(SomeBits-DT,a4)	;speciaal?
	bpl.b	Stop_Char_in_buffer	;neuj
	bclr	#SB1_CHANGE_MODE,(SomeBits-DT,a4)
	pea	(Stop_Char_in_buffer,pc)
	move.l	a0,-(sp)			;string ptr
	move.l	(text_buf_ptr-DT,a4),a0
	br	C15820

Stop_Char_in_buffer:
	move.l	a0,-(sp)
	move.l	(text_buf_ptr-DT,a4),a0
	tst.b	d0
	beq.b	druk_the_string			;einde regel afdrukken dus
	move.b	d0,(a0)+
	cmp.l	#text_buf_ptr,a0
	blo	C15858
druk_the_string:
	movem.l	d0-d3,-(sp)
	move.l	a0,d3
	move.l	#TextPrintBuffer,d2
	sub.l	d2,d3			;strlen
	beq	C15854
	move.l	d2,(text_buf_ptr-DT,a4)	;reset text_buf_ptr
	btst	#SB2_INSERTINSOURCE,(SomeBits2-DT,a4)
	beq.b	.text_printer_dump
	jsr	(InsertText).l
	bra.b	C157EC

.text_printer_dump:
	btst	#0,(PR_PrintDump).l
	beq.b	.C157D8
	bsr	druk_af_op_printer
.C157D8:
	btst	#SB2_OUTPUTACTIVE,(SomeBits2-DT,a4)	; redirected output?
	beq.b	.C157E4
	bsr	SEND_DIRECTOUT
.C157E4:
	bsr	Druk_regel_in_commandshell
	bsr	messages_get
C157EC:
	movem.l	(sp)+,d0-d3/a0
	rts

Print_Flush:
	moveq	#0,d0
Druk_char_af2:
	tst.b	(SomeBits-DT,a4)	;bit 7 SB1_CHANGE_MODE
	bmi.b	keyboard_invoer_en_zo
	bset	#SB1_CHANGE_MODE,(SomeBits-DT,a4)
	pea	(keyboard_invoer_en_zo,pc)
	move.l	a0,-(sp)
	move.l	(text_buf_ptr-DT,a4),a0
	bra.b	druk_the_string

keyboard_invoer_en_zo:
	move.l	a0,-(sp)
	move.l	(text_buf_ptr-DT,a4),a0
	tst.b	d0
	beq.b	C15820
	move.b	d0,(a0)+
	cmp.l	#text_buf_ptr,a0
	blo.b	C15858
C15820:
	movem.l	d0-d3,-(sp)
	move.l	a0,d3
	move.l	#TextPrintBuffer,d2
	sub.l	d2,d3
	beq.b	C15854
	move.l	d2,(text_buf_ptr-DT,a4)
	btst	#SB2_INSERTINSOURCE,(SomeBits2-DT,a4)
	beq.b	.C15844

	jsr	(InsertText).l		;stop ook in source
	bra.b	C1584C

.C15844:
;	btst	#MB1_DRUK_IN_MENUBAR,(MyBits-DT,a4)
;	beq.s	.gewoon
;	
;;	bsr	show_txt_in_balk2
;	bra.b	.inbalk
;.gewoon:
	bsr	Druk_regel_in_commandshell
;.inbalk
	bsr	messages_get
C1584C:
	movem.l	(sp)+,d0-d3/a0
	rts

C15854:
	movem.l	(sp)+,d0-d3
C15858:
	move.l	a0,(text_buf_ptr-DT,a4)
	move.l	(sp)+,a0
	rts

druk_af_op_printer:
	movem.l	d0-d6/a0-a3/a5/a6,-(sp)
	move.l	(PrinterBase-DT,a4),d1
	bne.b	.C15876
	jsr	(OpenPrinterForOutput).l			;open file
	move.l	(PrinterBase-DT,a4),d1	;file
	beq.b	.C15882
.C15876	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOWrite,a6)
	bsr	messages_get
.C15882	movem.l	(sp)+,d0-d6/a0-a3/a5/a6
	rts

SENDCHARDELSCR:
	moveq	#12,d0
	br	Druk_char_af2

C1588E:
	moveq	#$9B-256,d0
	bsr	Druk_char_af2
	moveq	#$4B,d0
	br	Druk_char_af2

PRINT_CLEARSCREEN:
	moveq	#$9B-256,d0
	bsr	Druk_char_af2
	moveq	#$48,d0
	br	Druk_char_af2

druk_af_d0_space:
	bsr.b	druk_af_d0
	br	druk_af_space


C158CA:
	move.l	(sp),d0
	cmp.l	(INSERT_START-DT,a4),d0
	blo.b	C158EE
	cmp.l	(INSERT_END-DT,a4),d0
	bhi.b	C158EE
	lea	(LB_.MSG,pc),a0
	bsr	printthetext
	move.l	(sp)+,d0
	bra.b	druk_af_d0			; draw 32 bits

C158E4:
	move.l	d0,-(sp)
	btst	#SB2_INSERTINSOURCE,(SomeBits2-DT,a4)
	bne.b	C158CA
C158EE:
	moveq	#'$',d0
	bsr	SENDONECHARNORMAL
	move.l	(sp)+,d0
	sub.l	(INSERT_START-DT,a4),d0
druk_af_d0:
	swap	d0
	bsr.b	C15900
	swap	d0
C15900:
	move	d0,-(sp)
	lsr.w	#8,d0
	bsr.b	C15908
	move	(sp)+,d0
C15908:
	move.b	d0,-(sp)
	lsr.b	#4,d0
	bsr.b	C15910
	move.b	(sp)+,d0
C15910:
	and.b	#15,d0
	add.b	#'0',d0
	cmp.b	#'9',d0
	ble.b	.Send
	addq.b	#'A'-('9'+1),d0
.Send	br	SENDONECHARNORMAL

DrukAf_LineNrPrint:
	bsr.b	PRINTDECIMALWORD_ext
	br	druk_af_space

PRINTDECIMALSIGN:
	tst.l	d0
	bpl.b	PRINTDECIMALLONG
	move.l	d0,-(sp)
	moveq	#'-',d0
	bsr	SENDONECHARNORMAL
	move.l	(sp)+,d0
	neg.l	d0
	moveq	#0,d3
	bra.b	PRINTDECIMALL

PRINTDECIMALWORD:
	and.l	#$0000FFFF,d0
PRINTDECIMALWORD_ext:
	moveq	#' ',d3
	lea	(TABEL_HEXTODEC3,pc),a0
	bra.b	PRINTDECIMAL

PRINTDECIMALLONG:
	moveq	#' ',d3
PRINTDECIMALL:
	lea	(TABEL_HEXTODEC,pc),a0
PRINTDECIMAL:
	move.l	d0,d2
.Loop
	move.l	(a0)+,d1
	beq.b	.C159B4
	cmp.l	d1,d2
	blo.b	.C15994
	moveq	#'0',d3
.C1598C	sub.l	d1,d2
	addq.b	#1,d3
	cmp.l	d1,d2
	bhs.b	.C1598C
.C15994	tst.b	d3
	beq.b	.Loop
	move.b	d3,d0
	tst.b	(Dis_DecLibCall-DT,a4)
	beq.b	.C159AA
	cmp.b	#' ',d0
	beq.b	.C159AE
	move.b	d0,(a3)+
	bra.b	.C159AE

.C159AA	bsr	SENDONECHARNORMAL
.C159AE	and.b	#$F0,d3
	bra.b	.Loop

.C159B4	move.l	d2,d0
	add.b	#'0',d0
	tst.b	(Dis_DecLibCall-DT,a4)
	beq.b	.C159CA
	cmp.b	#' ',d0
	beq.b	.C159C8
	move.b	d0,(a3)+
.C159C8	rts
.C159CA	br	SENDONECHARNORMAL

	CNOP	0,4
TABEL_HEXTODEC:
	dc.l	1000000000
TABEL_FPU:
	dc.l	100000000
TABEL_HEXTODECFILE:
	dc.l	10000000
	dc.l	1000000
	DC.L	100000
TABEL_HEXTODEC3:
	dc.l	10000
	dc.l	1000
	dc.l	100
	dc.l	10
	dc.l	0


C15B0A:
	movem.l	d0-d7/a0-a6,-(sp)
	fmove.d	fp0,(D02F260-DT,a4)
	move	#8,(FpuRegExp-DT,a4)
	sf	(B3004A-DT,a4)
	sf	(FpuResultInf-DT,a4)
	sf	(FpuResultInexact-DT,a4)
	move.b	#' ',(FCalcOutput\.Inexact).l

	fmove.w #10,fp0
	fmove.d	fp0,(D02F258-DT,a4)
	move.l	(LastCalcFpsr-DT,a4),d0
	btst	#24,d0			; NaN?
	bne	C15C1C
	btst	#26,d0			; zero?
	bne	C15C00
	btst	#25,d0			; infinity?
	beq.b	C15B60
	st	(FpuResultInf-DT,a4)
C15B60:
	btst	#9,d0			; inexact operation?
	beq.b	C15B6C
	st	(FpuResultInexact-DT,a4)
C15B6C:
	fmove.d	(D02F260-DT,a4),fp0
	fbeq	C15C00
	fbun.w	C15C1C
	fboge.w	C15B8E
	st	(B3004A-DT,a4)
	fneg.x	fp0
	fmove.d	fp0,(D02F260-DT,a4)
C15B8E:
	fmove.l	#999999999,fp0
	fmove.d	(D02F260-DT,a4),fp1
	fcmp.x	fp0,fp1
	fbogt.w	C15BBE
	fmove.l	#99999999,fp0
	fcmp.x	fp0,fp1
	fbolt.w	C15BDC
	bra.b	C15BF4

C15BBE:
	fmove.w	#10,fp0
	fdiv.x	fp0,fp1
	fmove.d	fp1,(D02F260-DT,a4)
	addq	#1,(FpuRegExp-DT,a4)
	bra.b	C15B8E

C15BDC:
	fmove.d	(D02F258-DT,a4),fp0
	fmul.x	fp0,fp1
	fmove.d	fp1,(D02F260-DT,a4)
	subq	#1,(FpuRegExp-DT,a4)
	bra.b	C15B8E

C15BF4:
	fmove.l	fp1,d0
	bsr.b	C15C38
	movem.l	(sp)+,d0-d7/a0-a6
	rts

C15C00:
	lea	(FCalcOutput,pc),a1
	bra.b	C15C1C_HaveA1

C15C1C:
	lea	(NotANumber.MSG,pc),a1
C15C1C_HaveA1:
	lea	(B30053-DT,a4),a0
	moveq	#17-1,d0
C15C2A:
	move.b	(a1)+,(a0)+
	dbra	d0,C15C2A
	clr.b	(a0)
	movem.l	(sp)+,d0-d7/a0-a6
	rts

C15C38:
	lea	(TABEL_FPU,pc),a0
	lea	(B30053-DT,a4),a1
	moveq	#' ',d3
	move.b	d3,(15,a1)
	tst.b	(B3004A-DT,a4)
	beq.b	.C15C52
	moveq	#'-',d3
.C15C52
	move.b	d3,(a1)+
	moveq	#0,d3
.Loop
	move.l	(a0)+,d1
	beq.b	.C15C7E
	moveq	#0,d2
.C15C62
	sub.l	d1,d0
	bmi.b	.C15C6A
	addq.w	#1,d2
	bra.b	.C15C62
.C15C6A
	add.l	d1,d0
	move.b	d2,(a1)
	add.b	#'0',(a1)+
	tst	d3
	bne.b	.C15C7C
	move.b	#'.',(a1)+
	moveq	#1,d3
.C15C7C
	bra.b	.Loop
.C15C7E
	move.b	d0,(a1)
	add.b	#'0',(a1)+
	moveq	#' ',d1
	tst.b	(FpuResultInf-DT,a4)
	beq.b	.C15C90
	move.b	#$BB,d1
.C15C90
	tst.b	(FpuResultInexact-DT,a4)
	beq.b	.C15CA0
	cmp.b	#' ',d1
	bne.b	.C15CA0
	move.b	#$B1,d1
.C15CA0
	move.b	d1,(a1)+
	move.b	#'E',(a1)+
	moveq	#$20,d1
	tst	(FpuRegExp-DT,a4)
	bpl.b	.C15CB4
	moveq	#'-',d1
	neg.w	(FpuRegExp-DT,a4)
.C15CB4
	move.b	d1,(a1)+
	moveq	#0,d0
	move	(FpuRegExp-DT,a4),d0
	move.l	d0,d1
	divu	#100,d1
	tst.b	d1
	beq.b	.C15CD4
	move.b	d1,(a1)
	add.b	#'0',(a1)+
	mulu	#100,d1
	sub	d1,d0
.C15CD4
	move.l	d0,d1
	divu	#10,d1
	tst.b	d1
	beq.b	.C15CEC
	move.b	d1,(a1)
	add.b	#'0',(a1)+
	mulu	#10,d1
	sub	d1,d0
.C15CEC
	move.b	d0,(a1)
	add.b	#'0',(a1)+
	lea	(FCalcOutput\.Inexact,pc),a0
	cmp	#99,(FpuRegExp-DT,a4)
	ble.b	.Exact
.Inexact
	move.b	#$B1,(a0)		; +-
.Exact
	cmp	#10,(FpuRegExp-DT,a4)
	bge.b	.C15D12
	move.b	#' ',(FCalcOutput\.Exp2-FCalcOutput\.Inexact,a0)
.C15D12
	clr.b	(FCalcOutput\.End-FCalcOutput\.Inexact,a0)
	rts

FCalcOutput:		; 17 chars
	dc.b	' 0.00000000'
.Inexact
	dc.b	' E 0'
.Exp2
	dc.b	' '
.End
	dc.b	0

NotANumber.MSG:		; 17 chars
	dc.b	'- Not a Number -',0

AsmPro_titletxt.MSG:
	dc.b	'Asm-Pro OS '
	VERSION_STR
	dc.b	' by Genetic. Source '
SourceNrInBalk:
	dc.b	'0 »'
MenuFileName:	dcb.b	31,0

HInclude.MSG:	dc.b	$9B,'1H','Include : "',0,'"',0
HIncbin.MSG:	dc.b	$9B,'1H','Incbin  : "',0,'"',0
HInciff.MSG:	dc.b	$9B,'1H','Inciff  : "',0,'"',0
	IF	INCLINK
HInclink.MSG:	dc.b	$9B,'1H','Inclink : "',0,'"',0
	ENDIF

FilelengthEOL.MSG:	dc.b	$9B,'52H =',0
Filelength.MSG:		dc.b	'File length = ',0
Filelength2.MSG:	dc.b	' (=$',0
Filelocation.MSG:	dc.b	'File location = ',0
Name.MSG:		dc.b	'Name : ',0
BytesFree.MSG:		dc.b	' Bytes Free',0
BytesUsed.MSG:		dc.b	' Bytes Used',10,0
dir.MSG:		dc.b	'   (dir) ',0
FILENAME.MSG:		dc.b	'FILENAME>',0
Extendlabelsw.MSG:	dc.b	'Extend labels with>',0
PrefixYN.MSG:		dc.b	'Prefix (Y/N)>',0
DIRECTORYNAME.MSG:	dc.b	'DIRECTORYNAME>',0
Startupparame.MSG:	dc.b	'Startup parameters>',0
Prompt_Char:		dc.b	'>',0
BEG.MSG:		dc.b	'BEG>',0
END.MSG0:		dc.b	'END>',0
DEST.MSG:		dc.b	'DEST>',0
DATA.MSG:		dc.b	'DATA>',0
AMPLITUDE.MSG:		dc.b	'AMPLITUDE>',0
MULTIPLIER.MSG:		dc.b	'MULTIPLIER>',0
HALFCORRECTIO.MSG:	dc.b	'HALF CORRECTION (Y/N)>',0
ROUNDCORRECTI.MSG:	dc.b	'ROUND CORRECTION (Y/N)>',0
YOFFSET.MSG:		dc.b	'YOFFSET>',0
SIZEBWL.MSG:		dc.b	'SIZE (B/W/L)>',0
AMOUNT.MSG:		dc.b	'AMOUNT>',0
BREAKPOINT.MSG:		dc.b	'BREAKPOINT>',0
RAMPTR.MSG:		dc.b	'RAM PTR>',0
DISKPTR.MSG:		dc.b	'DISK PTR>',0
LENGTH.MSG:		dc.b	'LENGTH>',0
Sure.MSG:		dc.b	'Sure? ',0
SREGSDATAfile.MSG:	dc.b	'REGSDATA file not found',10,0
Notenoughmemo.MSG:	dc.b	'Not enough memory to load REGSDATA',10,0
Errorcreating.MSG:	dc.b	'Error creating directory',10,0
Directorycrea.MSG:	dc.b	'Directory created',10,0
Sinuscreated.MSG:	dc.b	'Sinus created.',10,0
Couldntopenma.MSG:	dc.b	'Couldn''t open mathffp.library',10,0
Couldntopenma.MSG0:	dc.b	'Couldn''t open mathtrans.library',10,0
MathffpName:		dc.b	'mathffp.library',0
MathtransName:		dc.b	'mathtrans.library',0
Sourcenotsave.MSG:	dc.b	'Source not saved! Continue?',0
Filealreadyex.MSG:	dc.b	'File already exists! Continue?',0
ExitorRestart.MSG:	dc.b	'Exit or Restart (Y/N or R)?',0
EOP.MSG:		dc.b	'EOP     ',0
Removeunusedl.MSG:	dc.b	'Remove unused labels (Y/N)?',0
Updating.MSG:		dc.b	'Updating.. ',0
Sourcenotchan.MSG:	dc.b	'Source not changed. No update needed!',10,0
Sortingreloar.MSG:	dc.b	'Sorting relo-area..',10,0
Writinghunkda.MSG:	dc.b	'Writing hunk data..',10,0
Writinghunkle.MSG:	dc.b	'Writing hunk length..',10,0
NoReqToolslibrary.MSG:	dc.b	'Reqtools.library v38+ not found!',10,0
Reqtoolslibra.MSG:	dc.b	'Reqtools.library disabled due to no free chipmem!',10,0
Notenoughwork.MSG:	dc.b	'Not enough workmem for source!',10,0
Break.MSG:		dc.b	10,'** Break    ',10,0
HPass1.MSG:		dc.b	$9B,'1HPass 1..      ',10,0
HPass2.MSG:		dc.b	$9B,'1HPass 2..      ',10,0
Page.MSG:		dc.b	'Page',0
Of.MSG:			dc.b	'  Of ',0
HNoErrors.MSG:		dc.b	$9B,'1HNo errors     ',10,0
HErrorsOccure.MSG:	dc.b	$9B,'1HErrors occurred!',10,0
HSourcechecke.MSG:	dc.b	$9B,'1HSource checked',10,0
Zap.MSG:		dc.b	'<Zap> ',0
HReAssembling.MSG:	dc.b	$9B,'1HReAssembling.. ',10,0
OptionOOptimi.MSG:	dc.b	'Option O:  Optimizing..',10,0
NOT.MSG:		dc.b	'NOT '
EqualAreas.MSG:		dc.b	'Equal areas',0
Not.MSG:		dc.b	'Not '
Found.MSG:		dc.b	'Found',0
BranchForcedt.MSG:	dc.b	'Branch forced to word size',0
FPCR.MSG:		dc.b	'FPCR= ',0
FPIAR.MSG:		dc.b	'FPIAR=',0
FPSR.MSG:		dc.b	'FPSR= ',0
BSUN.MSG:		dc.b	' BSUN=',0
			dc.b	' SNAN=',0
			dc.b	' OPERR=',0
			dc.b	' OVFL=',0
			dc.b	' UNFL=',0
			dc.b	' DZ=',0
			dc.b	' INEX2=',0
			dc.b	' INEX1=',0
PRECISION.MSG:		dc.b	' PRECISION=',0
			dc.b	' ROUNDING=',0
N.MSG:			dc.b	10
			dc.b	'                N=',0
			dc.b	' Z=',0
			dc.b	' I=',0
			dc.b	' NAN=',0
			dc.b	' S=',0
			dc.b	' QU=',0
IOP.MSG:		dc.b	' IOP=',0
			dc.b	' OVFL=',0
			dc.b	' UNFL=',0
			dc.b	' DZ=',0
			dc.b	' INEX=',0
VBR.MSG:		dc.b	'VBR=',0
FP0.MSG:		dc.b	10
			dc.b	'FP0: ',0,10
			dc.b	'FP4: ',0
D0.MSG:			dc.b	'D0: ',0,10
			dc.b	'A0: ',0,10
			dc.b	'SSP=',0
			dc.b	'USP=',0
			dc.b	'SR=',0
			dc.b	'T1',0
			dc.b	'--',0
			dc.b	'SI',0
			dc.b	'--',0
			dc.b	'PL=',0
			dc.b	'XNZVC PC=',0
			dc.b	'PC=',0
HFP0.MSG:		dc.b	$9B,'1;61HFP0:',0
			dc.b	$9B,'2;61HFP1:',0
			dc.b	$9B,'3;61HFP2:',0
			dc.b	$9B,'4;61HFP3:',0
			dc.b	$9B,'5;61HFP4:',0
			dc.b	$9B,'6;61HFP5:',0
			dc.b	$9B,'7;61HFP6:',0
			dc.b	$9B,'8;61HFP7:',0
HD0.MSG:		dc.b	$9B,'1;69HD0: ',0
			dc.b	$9B,'2;69HD1: ',0
			dc.b	$9B,'3;69HD2: ',0
			dc.b	$9B,'4;69HD3: ',0
			dc.b	$9B,'5;69HD4: ',0
			dc.b	$9B,'6;69HD5: ',0
			dc.b	$9B,'7;69HD6: ',0
			dc.b	$9B,'8;69HD7: ',0
HA0.MSG:		dc.b	$9B,'9;69HA0: ',0
			dc.b	$9B,'10;69HA1: ',0
			dc.b	$9B,'11;69HA2: ',0
			dc.b	$9B,'12;69HA3: ',0
			dc.b	$9B,'13;69HA4: ',0
			dc.b	$9B,'14;69HA5: ',0
			dc.b	$9B,'15;69HA6: ',0
			dc.b	$9B,'16;69HA7: ',0
			dc.b	$9B,'17;69HSSP=',0
			dc.b	$9B,'18;69HUSP=',0
			dc.b	$9B,'19;69HSR=',0
			dc.b	'PL=',0
			dc.b	$9B,'20;69H',0
			dc.b	'T1',0
			dc.b	'--',0
			dc.b	'SI',0
			dc.b	'--',0
			dc.b	'XNZVC'
			dc.b	$9B,'21;69HPC =',0
			dc.b	$9B,'22;69HVBR=',0
			dc.b	$9B,'23;68HFPSR=',0
StartEndTotal.MSG:	dc.b	'                  Start    End           Total',10
			dc.b	'                  -------- --------   --------',10
			dc.b	'Workspace       : ',0
			dc.b	'Source          : ',0
			dc.b	'Label pointers  : ',0
			dc.b	'Label           : ',0
			dc.b	'Debug           : ',0
			dc.b	'Code            : ',0
			dc.b	'Reloc           : ',0
			dc.b	'IncMem          : -------- -------- ',0
AsmProLOCATIO.MSG:	dc.b	'Asm-Pro LOCATION  Start    End           Total',10
			dc.b	'                  -------- --------   --------',10
			dc.b	'1st Code section: ',0
			dc.b	'2nd Code section: ',0
			DC.B	'3rd Code section: ',0
			DC.B	'Data+BSS section: ',0
Memorydirecto.MSG:	dc.b	'--- Memory directory ---',10,0
			dc.b	'-- Symbol table --',10,0
st_macro:		dc.b	'-- Macro --',0
st_xref:		dc.b	'-- X-Ref --',0
st_equr:		dc.b	'-- Equ-R --',0
st_reg:			dc.b	'--  Reg  --',0

status_line_txt:	dc.b	$9B,'023;1H',0

DbgStatusBar.MSG:
	dc.b	'  Line          Col      Bytes           Free                ----',0

TimeString:
	dc.b	'  :  :  ',0,0,0,0,0,0,0,0	;16 bytes for date2str

BytesWordsLon.MSG:
	dc.b	'Bytes     Words     Longwords '

MoniStatusBar.MSG:
	dc.b	' Start: '
xxxxxxxxEnd.MSG:
	dc.b	'          End: '
xxxxxxxxSize.MSG:
	dc.b	'          Size: '
LongwordsTime.MSG:
	dc.b	'Bytes     Pos: '
Monitor_Pos:
	dc.b	'$xxxxxxxx'
	dc.b	'        ',0,0,0,0,0,0

End_msg:
	dc.b	$9B,'030;1H',0
END.MSG:
	dc.b	'<END>',0

DCB.MSG:
	dc.b	9,'DC.B',9,0
DCW.MSG:
	dc.b	9,'DC.W',9,0
DCL.MSG:
	dc.b	9,'DC.L',9,0
LB_.MSG:
	dc.b	'LB_',0
Searchfor.MSG:
	dc.b	' Search for: ',0
Replacewith.MSG:
	dc.b	' Replace with: ',0
Jumptoline.MSG:
	dc.b	' Jump to line: ',0
Nomoreerrorsf.MSG:
	dc.b	' No more errors found ',0
Error.MSG:
	dc.b	' Error: ',0
Steps.MSG:
	dc.b	' Steps: ',0
Address.MSG:
	dc.b	' Address: ',0
Watch.MSG:
	dc.b	' Watch: ',0
AddConditiona.MSG:
	dc.b	' Add conditional breakpoint on: ',0
Comparisonval.MSG:
	dc.b	' Comparison value/register: ',0
Conditiontype.MSG:
	dc.b	' Condition type: (0) <  (1) <=  (2) =  (3) >  (4) >=  (5) <>: ',0
Conditionbrea.MSG:
	dc.b	' Condition breakpoint reached',0
	dc.b	' Mode NOT allowed in conditional breakpoint ',0
Addressnotfou.MSG:
	dc.b	' Address not found!',0
Endofprogramr.MSG:
	dc.b	' End of program reached!',0
WatchtypeAsci.MSG:
	dc.b	' Watch type (A)scii (S)tring (H)ex (D)ecimal (B)inary (P)ointer: ',0
PointertoAsci.MSG:
	dc.b	' Pointer to (A)scii (S)tring (H)ex (D)ecimal (B)inary: ',0
Pointertype1D.MSG:
	dc.b	' Pointer type (1) DC.L (2) DC.W (3) DR.L (4) DR.W: '
	dc.b	0
Register.MSG0:
	dc.b	' Register: ',0
ReplaceYNLG.MSG:
	dc.b	' Replace (Y/N/L/G)?',0
Jumping.MSG:
	dc.b	' Jumping.. ',0
BufferFull.MSG:
	dc.b	' Buffer full!',0
Done.MSG:
	dc.b	'Done',0
UncommentDone.MSG:
	dc.b	' Uncomment done',0
Registersused.MSG:
	dc.b	' Registers used: ',0
NONE.MSG:
	dc.b	'NONE',0
Searching.MSG:
	dc.b	' Searching.. ',0
Topoftext.MSG:
	dc.b	' Top of text.. ',0
Bottomoftext.MSG:
	dc.b	' Bottom of text.. ',0
Createmacro.MSG:
	dc.b	' Create macro.. ',0
Marklocationa.MSG:
	dc.b	' Mark location and press <return>',0
Macrobufferfu.MSG:
	dc.b	' Macro buffer full!',0
DoubleSemicol:
	dc.b	';;',0
trackdiskdevi.MSG:
	dc.b	'trackdisk.device',0
;TimerName:
;	dc.b	'timer.device',0
ExternalLevel.MSG:
	dc.b	10
	dc.b	'** External level 7 break **',0
BusError.MSG:
	dc.b	10
	dc.b	'** Bus error **',0
AddressError.MSG:
	dc.b	10
	dc.b	'** Address error **',0
IllegalInstru.MSG:
	dc.b	10
	dc.b	'** Illegal instruction **',0
DivisionByZer.MSG:
	dc.b	10
	dc.b	'** Division by zero **',0
CHKexception.MSG:
	dc.b	10
	dc.b	'** CHK exception **',0
TRAPV.MSG:
	dc.b	10
	dc.b	'** TRAPV **',0
PrivilegeViol.MSG:
	dc.b	10
	dc.b	'** Privilege violation **',0
TraceTrap.MSG:
	dc.b	10
	dc.b	'** Trace trap **',0
LineAEmulator.MSG:
	dc.b	10
	dc.b	'** LineA emulator **',0
LineFEmulator.MSG:
	dc.b	10
	dc.b	'** LineF emulator **',0
Exception.MSG:
	dc.b	10
	dc.b	'** Exception $',0
Raised.MSG:
	dc.b	' Raised'
At.MSG:
	dc.b	' At $',0
Accessing.MSG:
	dc.b	' Accessing $',0
	dc.b	' Type ',0
	dc.b	' Instruction $',0

	EVEN
AllocMem1Kb:
	move.l	(Bootblock-DT,a4),d0
	bne.b	C16EC2
	move.l	#1024,d0
	moveq	#2,d1
	move.l	(4).w,a6
	jsr	(_LVOAllocMem,a6)
	move.l	d0,(Bootblock-DT,a4)
	bne.b	C16EC2
	jmp	(ERROR_WorkspaceMemoryFull).l
C16EC2:	rts

com_bb_checksum:
	bsr.b	C16F26
	bsr.b	AllocMem1Kb
	move.l	d0,(TRACK_BUFFER-DT,a4)
	move.l	#1024,(TRACK_LENGTH-DT,a4)
	clr.l	(TRACK_POINTER-DT,a4)
	move	#2,(TRACK_COMMAND-DT,a4)
	bsr	C17114
	move.l	(TRACK_BUFFER-DT,a4),a0
	move.l	a0,a1
	clr.l	(4,a0)
	moveq	#-1,d0
	move	#$00FF,d1
	moveq	#0,d2
.C16F0A	sub.l	(a0)+,d0
	subx.l	d2,d0
	dbra	d1,.C16F0A
	move.l	d0,(4,a1)
	move	#3,(TRACK_COMMAND-DT,a4)
	bsr	C17114
	bsr	C17186

FreeMem1Kb:
	move.l	(Bootblock-DT,a4),d0
	beq.b	C16EC2
	move.l	d0,a1
	clr.l	(Bootblock-DT,a4)
	move.l	#1024,d0
	move.l	(4).w,a6
	jmp	(_LVOFreeMem,a6)

C16F26:
	addq.l	#1,a6
	bsr	Convert_A2I
	cmp.b	#NS_AVALUE,d1
	beq.b	Open_trackdiskdev
	move.l	(TrackdiskUnit-DT,a4),d0

Open_trackdiskdev:
	move.l	d0,(TrackdiskUnit-DT,a4)
	moveq	#0,d1
	lea	(DATA_WRITEREQUEST2-DT,a4),a1
	lea	(DATA_REPLYPORT-DT,a4),a0
	move.l	a0,(MN_REPLYPORT,a1)
	lea	(trackdiskdevi.MSG,pc),a0
	move.l	(4).w,a6
	jsr	(_LVOOpenDevice,a6)
	tst.l	d0
	beq.b	C16F62
	jmp	(ERROR_IllegalDevice).l

C16F62:
	rts

;Open_timerdev:
;	movem.l	d0-d7/a0-a6,-(sp)
;	lea	(TimerName,pc),a0
;	moveq	#1,d0
;	moveq	#0,d1
;	lea	(TimerDevStruct).l,a1
;	move.l	#DATA_REPLYPORT,(14,a1)
;	move.l	(4).w,a6
;	jsr	(_LVOOpenDevice,a6)
;	movem.l	(sp)+,d0-d7/a0-a6
;	rts

GetTheTime:
	movem.l	d0-d7/a1-a6,-(sp)

	move.l	(DosBase-DT,a4),a6
	lea	(datetime,pc),a2
	move.l	a2,d1
	jsr	(_LVODateStamp,a6)

	lea	(TimeString,pc),a0
	move.l	a0,(timestr-datetime,a2)
	move.l	a2,d1
	jsr	(_LVODateToStr,a6)

	movem.l	(sp)+,d0-d7/a1-a6
	lea	(TimeString,pc),a0
	rts


datetime:	; struct DateStamp
	dc.l	0
	dc.l	0
	dc.l	0
dateformat:
	dc.b	0	;format
	dc.b	0	;flags
	dc.l	0	;day
	dc.l	DateString	;date
timestr:
	dc.l	TimeString	;time

DateString:
	dc.b	"--/---/--",0
	dcb.b	6,0
	EVEN

;CloseTimerDev:
;	movem.l	d0-d7/a0-a6,-(sp)
;	move.l	(4).w,a6
;	lea	(TimerDevStruct).l,a1
;	jsr	(_LVOCloseDevice,a6)
;	movem.l	(sp)+,d0-d7/a0-a6
;	rts

Com_ReadSector:
	bsr	C16F26
	move	#2,(TRACK_COMMAND-DT,a4)
	bsr.b	C170CA
	bsr	C17114
	br	C17186

C17048:
	bsr	C16F26
	move	#3,(TRACK_COMMAND-DT,a4)
	bsr.b	C170CA
	bsr	C17114
	br	C17186

C1705C:
	bsr	C16F26
	move	#3,(TRACK_COMMAND-DT,a4)
	bsr.b	C170CA
	move.l	(TRACK_POINTER-DT,a4),d0
	bsr.b	MulD0By11
	move.l	d0,(TRACK_POINTER-DT,a4)
	move.l	(TRACK_LENGTH-DT,a4),d0
	bsr.b	MulD0By11
	move.l	d0,(TRACK_LENGTH-DT,a4)
	bsr.b	C17114
	br	C17186

MulD0By11:
	move.l	d0,d1
	lsl.l	#2,d0
	add.l	d1,d0
	add.l	d0,d0
	add.l	d1,d0
	rts

Com_ReadTrack:
	bsr	C16F26
	move	#2,(TRACK_COMMAND-DT,a4)
	bsr.b	C170CA
	move.l	(TRACK_POINTER-DT,a4),d0
	bsr.b	MulD0By11
	move.l	d0,(TRACK_POINTER-DT,a4)
	move.l	(TRACK_LENGTH-DT,a4),d0
	bsr.b	MulD0By11
	move.l	d0,(TRACK_LENGTH-DT,a4)
	bsr.b	C17114
	br	C17186

C170CA:
	lea	(RAMPTR.MSG,pc),a0
	bsr	Druk_MsgAf_GetNumbr
	bne.b	.Error
	move.l	d0,(TRACK_BUFFER-DT,a4)
	move.l	d0,(MEM_DIS_DUMP_PTR-DT,a4)
	lea	(DISKPTR.MSG,pc),a0
	bsr	Druk_MsgAf_GetNumbr
	bne.b	.Error
	lsl.l	#8,d0
	lsl.l	#1,d0
	move.l	d0,(TRACK_POINTER-DT,a4)
	lea	(LENGTH.MSG,pc),a0
	bsr	Druk_MsgAf_GetNumbr
	bne.b	.Error
	lsl.l	#8,d0
	lsl.l	#1,d0
	move.l	d0,(TRACK_LENGTH-DT,a4)
	rts

.Error	jmp	(ERROR_Notdone)

C17114:
	move.l	(4).w,a6
	lea	(DATA_WRITEREQUEST2-DT,a4),a1
	move	#14,($001C,a1)
	jsr	(_LVODoIO,a6)
	tst.l	($0020,a1)
	beq.b	C17134
	jmp	(ERROR_Nodiskindrive).l

C17134:
	cmp	#3,(TRACK_COMMAND-DT,a4)
	bne.b	C17152
	move	#15,($001C,a1)
	jsr	(_LVODoIO,a6)
	tst.l	($0020,a1)
	beq.b	C17152
	jmp	(ERROR_WriteProtected).l

C17152:
	move	(TRACK_COMMAND-DT,a4),($001C,a1)
	move.l	(TRACK_LENGTH-DT,a4),($0024,a1)
	move.l	(TRACK_BUFFER-DT,a4),($0028,a1)
	move.l	(TRACK_POINTER-DT,a4),($002C,a1)
	jsr	(_LVODoIO,a6)
	move	#4,($001C,a1)
	jsr	(_LVODoIO,a6)
	move	#9,($001C,a1)
	clr.l	($0024,a1)
	jmp	(_LVODoIO,a6)

C17186:
	lea	(DATA_WRITEREQUEST2-DT,a4),a1
	jmp	(_LVOCloseDevice,a6)

;****************************************************************
;*	  THIS AREA CONTAINS ALL INCLUDE FILES ROUTINES		*
;****************************************************************

CheckIncludeAssign:
	move.w	(IncludeAssignStatus-DT,a4),d4
	bne.b	IncFileDone	;  0 = unknown, 1 = not found, -1 = found
	addq.w	#1,d4
	move.l	(DosBase-DT,a4),a6
	moveq	#LDF_ASSIGNS|LDF_READ,d1
	jsr	(_LVOLockDosList,a6)
	move.l	d0,d1
	lea	(IncludeAssignName-DT,a4),a0
	move.l	a0,d2
	moveq	#LDF_ASSIGNS,d3
	jsr	(_LVOFindDosEntry,a6)
	tst.l	d0
	beq.b	.NotFound
	subq.w	#2,d4
.NotFound
	moveq	#LDF_ASSIGNS|LDF_READ,d1
	jsr	(_LVOUnLockDosList,a6)
	move.w	d4,(IncludeAssignStatus-DT,a4)

IncFileDone:
	rts

HandleIncFileFromSrc:
	lea	(SourceCode-DT,a4),a1
	bsr.w	ASSEM_RETURN_STRING

; scan order: INCDIR (if not set: DFLTDIR), SRCDIR, INCLUDES assign
HandleIncFile:
	bsr.b	JOIN_INCDIR_INCNAME_TO_INPUTBUFFER
	bsr.w	CheckIfFileExists
	bne.b	IncFileDone

	bsr.b	JOIN_SRCDIR_INCNAME_TO_INPUTBUFFER
	bsr.w	CheckIfFileExists
	bne.b	IncFileDone

	btst	#AF_INC_ASSIGN,d7
	beq.b	_ERROR_FileError
	bsr.b	CheckIncludeAssign
	bge.b	_ERROR_FileError
	bsr.b	JOIN_INCLUDE_INCNAME_TO_INPUTBUFFER
	bsr.w	CheckIfFileExists
	bne.b	IncFileDone

_ERROR_FileError:
	jmp	(ERROR_FileError)

JOIN_SRCDIR_INCNAME_TO_INPUTBUFFER:
	lea	(LastFileNaam-DT,a4),a0	; current source (full path)
	move.l	a0,a2
	lea	(TempDirName-DT,a4),a1
	move.l	a1,a3
.ToPathEnd
	tst.b	(a2)+
	bne.b	.ToPathEnd
.ToLastSep
	move.b	-(a2),d0
	cmp.b	#':',d0
	beq.b	.CopyDir
	cmp.b	#'/',d0
	beq.b	.CopyDir
	cmp.l	a0,a2
	bne.b	.ToLastSep
	bra.b	.NoDir
.CopyDir
	move.b	(a0)+,(a3)+
	cmp.l	a2,a0
	bls.b	.CopyDir
.NoDir
	clr.b	(a3)
	bra.b	JOIN_A1_INCNAME_TO_INPUTBUFFER

JOIN_INCLUDE_INCNAME_TO_INPUTBUFFER:
	lea	(IncludeAssign-DT,a4),a1
	bra.b	JOIN_A1_INCNAME_TO_INPUTBUFFER

JOIN_INCDIR_INCNAME_TO_INPUTBUFFER:
	lea	(INCLUDE_DIRECTORY-DT,a4),a1

JOIN_A1_INCNAME_TO_INPUTBUFFER:
	lea	(CurrentAsmLine-DT,a4),a0
	tst.b	(a1)		; a1 path empty?
	beq.b	.AppendIncPath
	lea	(SourceCode-DT,a4),a3
.CheckIfAbs
	move.b	(a3)+,d0	; is include path absolute?
	beq.b	.CopyIncDir
	cmp.b	#':',d0
	beq.b	.AppendIncPath
	bra.b	.CheckIfAbs
.CopyIncDir
	move.b	(a1)+,(a0)+
	bne.b	.CopyIncDir
	subq.w	#2,a0
	move.b	(a0)+,d0	; last incdir char
	cmp.b	#':',d0		; check for trailing : or /
	beq.b	.AppendIncPath
	cmp.b	#'/',d0
	beq.b	.AppendIncPath
	move.b	#'/',(a0)+	; append / to incdir path
.AppendIncPath
	lea	(SourceCode-DT,a4),a3
.CopyIncPath
	move.b	(a3)+,(a0)+
	bne.b	.CopyIncPath
	rts

IsIncFileCached:
	lea	(FIRST_INCLUDE_PTR-DT,a4),a2
.FileLoop
	move.l	(a2),d0
	beq.b	.Done
	move.l	d0,a2
	lea	(12,a2),a1
	lea	(CurrentAsmLine-DT,a4),a0
.NameLoop
	cmpm.b	(a0)+,(a1)+
	bne.b	.FileLoop
	tst.b	(-1,a0)
	bne.b	.NameLoop
.Done
	tst.l	d0
	rts

INCLUDE_POINTER:
	bsr.b	JOIN_INCDIR_INCNAME_TO_INPUTBUFFER
	bsr.b	IsIncFileCached
	bne.b	.IsCached
	bsr.w	JOIN_SRCDIR_INCNAME_TO_INPUTBUFFER
	bsr.b	IsIncFileCached
	bne.b	.IsCached
	bsr.b	JOIN_INCLUDE_INCNAME_TO_INPUTBUFFER
	bsr.b	IsIncFileCached
	bne.b	.IsCached
.NotCached
	tst.w	d7
	bpl.b	.Pass2
	move.l	a2,-(sp)		; next include cache entry
	bset	#AF_INC_ASSIGN,d7
	bsr.w	HandleIncFile
	move.l	(sp)+,a2
	bra.b	.ReadIncFile

.IsCached
	move.l	a2,(SOLO_CurrentIncPtr-DT,a4)
	rts
.Pass2
	jmp	(ERROR_IncludeJam)

; Include : "DH1:ASMPRO/INCLUDE/devices/keymap.i       " =     14926 (=$00003A4E )
.ReadIncFile
	lea	(HInclude.MSG,pc),a0
	bsr	PRINTINCLUDENAME
	bsr	GetDiskFileLengte
	bsr	IncludeAllocMem

	move.l	a1,-(sp)
	movem.l	d0/a2,-(sp)
	clr.l	(FileLength-DT,a4)
	bsr	OpenOldFile
	clr	(Marksinsource-DT,a4)
	bsr	SaveMarksOpnieuwIstalleren
	lea	(ParameterBlok-DT,a4),a2
	cmp.l	#$F9FAF9FA,(a2)
	bne.b	.nosavemarks
	moveq	#44,d0
	sub.l	d0,(sp)
.nosavemarks:
	cmp.l	#";APS",(a2)
	bne.b	.nosavemarksnew
	moveq	#85,d0
	sub.l	d0,(sp)
.nosavemarksnew:
	movem.l	(sp),d3/a2
	move.l	a2,d2
	bsr	read_nr_d3_bytes
	clr.b	(a2,d3.l)
	move.b	#SRCMARK_END,(1,a2,d3.l)
	cmp.l	(FileLength-DT,a4),d3
	bne.w	_ERROR_FileError
	moveq	#10,d1
	moveq	#SRCMARK_END-13,d2
	bra.b	.loop2

.store:
	move.b	d0,(-1,a2)
.loop2:
	move.b	(a2)+,d0
	sub.b	d1,d0		; lf?
	beq.b	.store
	subq.b	#13-10,d0	; cr?
	beq.b	.store
	sub.b	d2,d0
	bne.b	.loop2
	move.l	d7,-(sp)
	moveq	#-1,d7
	bsr	close_bestand
	move.l	(sp)+,d7
	movem.l	(sp)+,d0/a1/a2
	rts

CheckIfFileExists:
	bsr.b	GetFileSize
	addq.l	#1,d0			; error to 0, size to >0
	rts

GetDiskFileLengte:
	bsr.b	GetFileSize
	bmi.w	_ERROR_FileError
	rts

GetFileSize:
	move.l	a6,-(sp)
	lea	(CurrentAsmLine-DT,a4),a0
	sf	(FilenameBuffSelect-DT,a4)
	move.l	a0,a6
	moveq	#0,d1
.C17270
	move.b	(a6)+,d0
	beq.b	.C17282
	cmp.b	#':',d0
	bne.b	.C17270
	addq.w	#1,d1
	bra.b	.C17270
.C17282
	move.l	(DosBase-DT,a4),a6
	subq.w	#1,d1		; was path already absolute (2x volume)?
	bgt.b	.C17298
	move.l	a0,d1
	moveq	#ACCESS_READ,d2
	jsr	(_LVOLock,a6)
	tst.l	d0
	bne.b	.C172AE
.C17298	st	(FilenameBuffSelect-DT,a4)
	lea	(SourceCode-DT,a4),a0
	move.l	a0,d1
	moveq	#ACCESS_READ,d2
	jsr	(_LVOLock,a6)
.C172AE
	move.l	d0,-(sp)
	beq.b	.FileError
	move.l	d0,d1
	lea	(ParameterBlok-DT,a4),a0
	clr.l	(ParameterBlok+fib_EntryType-DT,a4)
	move.l	a0,d2
	jsr	(_LVOExamine,a6)
	move.l	(sp)+,d1
	jsr	(_LVOUnLock,a6)
	tst.l	(ParameterBlok+fib_EntryType-DT,a4)
	bpl.b	.NotFile
	move.l	(ParameterBlok+fib_Size-DT,a4),d0
.Done
	move.l	(sp)+,a6
	rts

.FileError
	addq.l	#4,sp
.NotFile
	moveq	#-1,d0
	bra.b	.Done

;*   INCLUDE_ALLOCATE_MEM   *

; D0 = Length
; A5 = Pointer
; Struct Include:
;	NextPtr
;	Length
; 	macro_id (inc_idx/ctr)
;	Name (zero terminated)
;	Include_File

IncludeAllocMem:
	move.l	d0,-(sp)
	lea	(CurrentAsmLine-DT,a4),a0
	moveq	#12+4,d1
.lopje:
	addq.l	#1,d1
	tst.b	(a0)+
	bne.b	.lopje
	add.l	d1,d0
	move.l	d0,-(sp)
	moveq	#0,d1
	move.l	(4).w,a6
	jsr	(_LVOAllocMem,a6)
	move.l	(sp)+,d1
	move.l	d0,(a2)
	bne.b	.memok
	jmp	(ERROR_WorkspaceMemoryFull).l

.memok:
	add.l	d1,(INCLUDE_CONSUMPTION-DT,a4)
	move.l	d0,a1
	move.l	d0,a2
	clr.l	(a2)+			; next
	move.l	d1,(a2)+		; length
	addq.w	#1,(NUM_INCLUDES-DT,a4)
	move.w	(NUM_INCLUDES-DT,a4),(a2)+	; macro_id (inc_idx/ctr)
	clr.w	(a2)+

	lea	(CurrentAsmLine-DT,a4),a0
.lopje3:
	move.b	(a0)+,(a2)+	; name
	bne.b	.lopje3
	move.l	(sp)+,d0
	rts

;*   Deallocate all includes   *

ZapIncludes:
	clr.l	(INCLUDE_CONSUMPTION-DT,a4)
	lea	(FIRST_INCLUDE_PTR-DT,a4),a2
	move.l	(a2),d2
	clr.l	(a2)
	clr.w	(NUM_INCLUDES-DT,a4)
.lopje:
	tst.l	d2
	beq.b	.klaar
	move.l	d2,a2
	move.l	a2,a1
	move.l	(a2)+,d2	; next
	move.l	(a2),d0		; length
	move.l	(4).w,a6
	jsr	(_LVOFreeMem,a6)
	bra.b	.lopje
.klaar:
	rts


;;********** IN THIS AREA ALL KEYBOARD ROUTINES ARE PLACED ************

Get_me_a_char:
	bsr.w	Print_Flush
GETKEYNOPRINT:
	move.l	a0,-(sp)
	bsr.b	GetKey
	cmp.b	#$80,d0
	bne.b	.noEsc
	bsr.b	GetKey
	move.b	d0,(edit_EscCode-DT,a4)
	move	#$0080,d0
.noEsc:
	move.l	(sp)+,a0
	rts

;*   GET KEYPRESSION FROM BUFFER   *

GetKey:
	move	(KeyboardInBuf-DT,a4),d0
	cmp	(KeyboardOutBuf-DT,a4),d0
	bne.b	GetKey_StillKeysInBuf

	sf	(Safety-DT,a4)		;voor auto stuff

	movem.l	d1-d7/a0-a3/a5/a6,-(sp)
	bsr	GetAnyChar
	movem.l	(sp)+,d1-d7/a0-a3/a5/a6
	tst.b	(markblockset-DT,a4)
	beq.b	.NextKeyPlease
	sf	(markblockset-DT,a4)

	moveq	#-1,d0
	cmp.l	d0,a6
	bne.b	.unmarkblock
	move.l	a2,a6
	bra.b	.NextKeyPlease
.unmarkblock:
	move.l	d0,a6
	jsr	(RegTab_SETALLNOTUPD)
.NextKeyPlease:

	tst.w	(PR_WaitTOF)
	beq.b	.nowaitof
	move.l	a6,-(sp)
;	move.l	(DosBase-DT,a4),a6
;	moveq	#1,d1
;	jsr	_LVODelay(a6)
	move.l	(GfxBase-DT,a4),a6
	jsr	_LVOWaitBlit(a6)
	jsr	_LVOWaitTOF(a6)		;delay befor getting next key..
	move.l	(sp)+,a6
.nowaitof:
	bra.b	GetKey

GetKey_StillKeysInBuf:
	cmp	(KEYB_KILLPTR-DT,a4),d0
	bne.b	.cont
	addq.b	#1,(KEYB_KILLPTR+1-DT,a4)
.cont:
	addq.b	#1,(KeyboardInBuf+1-DT,a4)
	lea	(OwnKeyBuffer-DT,a4),a0
	move.b	(a0,d0.w),d0
	rts

clear_input_buffer:	; KILLBUFFER
	move	(KEYB_KILLPTR-DT,a4),(KeyboardOutBuf-DT,a4)
	rts

messages_get:		; CHECKIFCHAR
	movem.l	d1/a0/a1/a6,-(sp)
.MainMsgGet:
	move.l	(KEY_PORT-DT,a4),a0
	move.l	(4).w,a6
	jsr	(_LVOGetMsg,a6)
	move.l	d0,(KEY_MSG-DT,a4)
	beq.b	.NoMoreMsg
	movem.l	d1-d7/a1-a3/a5,-(sp)
	bsr	handle_main_msgs
	movem.l	(sp)+,d1-d7/a1-a3/a5
	bra.b	.MainMsgGet

.NoMoreMsg:
	movem.l	(sp)+,d1/a0/a1/a6
	move	(KeyboardInBuf-DT,a4),d0
	sub	(KeyboardOutBuf-DT,a4),d0	; must set flags on exit!
	rts

KEY_RETURN_LAST_KEY:
	move.b	(edit_EscCode-DT,a4),d0

C17412:
	move.l	d0,-(sp)
	moveq	#$80-256,d0
	bsr.b	KEYBUFFERPUTCHAR
	move.l	(sp)+,d0

KEYBUFFERPUTCHAR:
	lea	(OwnKeyBuffer-DT,a4),a0
	add	(KeyboardOutBuf-DT,a4),a0
	move.b	d0,(a0)
	addq.b	#1,(KeyboardOutBuf+1-DT,a4)
	rts

PlaceCursorByMouseclick:
	move.l	(MainWindowHandle-DT,a4),a5
	moveq	#0,d2
	move	(12,a5),d2		;mouse Y
	sub	(Scr_Title_size-DT,a4),d2	; - 11 voor de menubalk
	bpl.b	C17442
	moveq	#0,d2
C17442:
	divu.w	(EFontSize_y-DT,a4),d2

	move.l	(NrOfLinesInEditor-DT,a4),d1
	subq.w	#1,d1
	cmp	d1,d2
	bls.b	C1744E
	move	d1,d2
C1744E:
	moveq	#0,d0
	move	(14,a5),d0		;mouse X
	divu.w	(EFontSize_x-DT,a4),d0
	lea	(OwnKeyBuffer-DT,a4),a0
	move	(KeyboardOutBuf-DT,a4),d1
	move.b	#128,(a0,d1.w)		;$80 /R
	addq.b	#1,d1
	move.b	#82,(a0,d1.w)		;$52
	addq.b	#1,d1
	move.b	d0,(a0,d1.w)
	addq.b	#1,d1
	move.b	d2,(a0,d1.w)
	addq.b	#1,d1
	move	d1,(KeyboardOutBuf-DT,a4)
	rts

GetAnyChar:
	move	(KeyboardInBuf-DT,a4),(KEYB_KILLPTR-DT,a4)
	btst	#SB1_MOUSE_KLIK,(SomeBits-DT,a4)
	beq.b	NoMsgInBase
	move.l	(4).w,a6
	move.l	(KEY_PORT-DT,a4),a0
	jsr	(_LVOGetMsg,a6)
	move.l	d0,(KEY_MSG-DT,a4)
	bne.b	handle_main_msgs
	br	C17A44

NoMsgInBase:
	move.l	(KEY_PORT-DT,a4),a5
	move.l	a5,a0
	move.l	(4).w,a6
	jsr	(_LVOWaitPort,a6)
	move.l	a5,a0
	jsr	(_LVOGetMsg,a6)
	move.l	d0,(KEY_MSG-DT,a4)
	beq.b	NoMsgInBase

;handle_plugs_msgs:
	IF useplugins
	tst.l	Plugs_winbase		;handle plugs win msg's
	beq.b	.handle_debug_msgs

	move.l	d0,a3
	move.l	(im_IDCMPWindow,a3),a3
	cmp.l	Plugs_winbase,a3
	bne.b	.handle_debug_msgs

	jsr	Plugs_check_plugsmsg

	bra.b	NoMsgInBase
	ENDIF

.handle_debug_msgs:
	tst.l	(debug_winbase-DT,a4)	;handle debug win msg's
	beq.b	handle_main_msgs

	move.l	d0,a3
	move.l	(im_IDCMPWindow,a3),a3
	cmp.l	(debug_winbase-DT,a4),a3
	bne.s	handle_main_msgs

	bsr.w	Debug_check_msg
	tst.l	(debug_winbase-DT,a4)	;handle debug win msg's
	bne.w	nomore_mgs

handle_main_msgs:			;handle normal msg's
	move.l	d0,a3
	move.l	(im_Class,a3),d3
	moveq	#IDCMP_MOUSEBUTTONS,d1
	and.l	d3,d1
	bne	check_mouse

	move.l	d3,d1
	and.w	#IDCMP_MENUPICK,d1
	bne	check_menus

	move.l	d3,d1
	and.w	#IDCMP_RAWKEY,d1
	beq	nomore_mgs

check_keys:
	move	(im_Code,a3),d4
	btst	#IECODEB_UP_PREFIX,d4	;key released?
	bne	nomore_mgs
	move	(im_Qualifier,a3),d5
	move.l	(im_IAddress,a3),a0
	move	d4,(MY_EVENT+ie_Code-DT,a4)
	move	d5,(MY_EVENT+ie_Qualifier-DT,a4)
	move.l	(a0),(MY_EVENT+ie_EventAddress-DT,a4)

	moveq	#IEQUALIFIER_CONTROL,d1
	and.w	d5,d1
	bne	CtrlKeyDecode
C17516:
	cmp	#$0040,d4	; regular keys or spacebar?
	bls.b	C17524
	cmp	#$004A,d4	; - numpad
	bne	RawKeyDecode
C17524:
	btst	#0,(PR_NumLock).l
	beq.b	key_CONV
	btst	#SB3_SPEC_KEYS,(SomeBits3-DT,a4)	;editor
	beq.b	key_CONV
	cmp	#$003D,d4		; 7/home numpad
	beq	key_HOME
	cmp	#$003E,d4		; 8 numpad
	beq	key_UP
	cmp	#$003F,d4		; 9/pgup numpad
	beq	key_SHIFT_UP
	cmp	#$002D,d4		; 4 numpad
	beq	key_RIGHT
	cmp	#$002E,d4		; 5 numpad
	beq	key_NUM5
	cmp	#$002F,d4		; 6 numpad
	beq	key_LEFT
	cmp	#$001D,d4		; 1/end numpad
	beq	key_END
	cmp	#$001E,d4		; 2 numpad
	beq	key_DOWN
	cmp	#$001F,d4		; 3/pgdown numpad
	beq	key_SHIFT_DOWN
key_CONV:
	lea	(MY_EVENT-DT,a4),a0
	lea	(KEY_BUFFER-DT,a4),a1
	moveq	#16,d1
	sub.l	a2,a2		; default keymap
	move.l	(ConIOReq+io_Device-DT,a4),a6
	jsr	(_LVORawKeyConvert,a6)
	subq.l	#1,d0
	bmi	nomore_mgs

	lea	(KEY_BUFFER-DT,a4),a1
	cmp.b	#$9B,(a1)
	beq	nomore_mgs
key_GoAnyway:
	lea	(OwnKeyBuffer-DT,a4),a0
	move	(KeyboardOutBuf-DT,a4),d1
.Copy:
	move.b	(a1)+,(a0,d1.w)
	addq.b	#1,d1
	dbra	d0,.Copy
	move	d1,(KeyboardOutBuf-DT,a4)
	br	nomore_mgs

check_mouse:
	btst	#SB3_SPEC_KEYS,(SomeBits3-DT,a4)	;editor
	beq	nomore_mgs
	move	(im_Code,a3),d1
	cmp.b	#$68,d1
	beq.b	OokIetsMetXY
	cmp.b	#$E8,d1
	bne.b	.C175E2
	bclr	#SB1_MOUSE_KLIK,(SomeBits-DT,a4)
.C175E2	br	nomore_mgs

OokIetsMetXY:
	bset	#SB1_MOUSE_KLIK,(SomeBits-DT,a4)
	cmp.b	#MT_EDITOR,(menu_tiepe-DT,a4)
	bne.b	.NotEditor
	move.l	(MainWindowHandle-DT,a4),a0
	move.w	(wd_MouseY,a0),d0
	asr.w	#3,d0			;nr rows Y
	move.w	(wd_MouseX,a0),d1
	asr.w	#3,d1			;nr cols X
	cmp.w	(NieuwMouseX-DT,a4),d0
	bne.b	.NewXY
	cmp.w	(NieuwMouseY-DT,a4),d1
	bne.b	.NewXY
	st	(markblockset-DT,a4)
.NewXY	movem.w	d0/d1,(NieuwMouse-DT,a4)
.NotEditor
	br	nomore_mgs

CtrlKeyDecode:
	cmp.b	#64,d4
	bhs.w	C17516
	lea	(CTRL_CONVERT_LC,pc),a0
	ext.w	d4
	and	#IEQUALIFIER_LSHIFT|IEQUALIFIER_RSHIFT,d5
	beq.b	.NO_SHIFT
	lea	(CTRL_CONVERT_UC,pc),a0
.NO_SHIFT
	move.b	(a0,d4.w),d0
	cmp.b	(BreakKey-DT,a4),d0
	beq	CTRL_BREAK

SentEscKey:
	lea	(KEY_BUFFER-DT,a4),a0
	move.l	a0,a1
	move.b	#$80,(a0)+
	move.b	d0,(a0)+
	moveq	#1,d0
	br	key_GoAnyway

CTRL_CONVERT_LC:
	dc.l	$00474849	; $00 lowercase
	dcb.l	3,0
	dc.l	$23291724	; $10
	dc.l	$262B271B
	dc.l	$21220000
	dc.l	0
	dc.l	$13251618	; $20
	dc.l	$191A1C1D
	dc.l	$1E000000
	dc.l	0
	dc.l	$002C2A15	; $30
	dc.l	$2814201F
	dc.l	$53000000
	dc.l	0
CTRL_CONVERT_UC:
	dc.l	$004F5051	; $40 uppercase
	dcb.l	3,0
	dc.l	$3D43313E	; $50
	dc.l	$40454135
	dc.l	$3B3C0000
	dc.l	0
	dc.l	$2D3F3032	; $60
	dc.l	$33343637
	dc.l	$38000000
	dc.l	0
	dc.l	$0046442F	; $70
	dc.l	$422E3A39
	dcb.l	2,0

RawKeyDecode:
	cmp	#$005F,d4	;help key
	beq	TheHelpKey
	and	#$00FB,d5	;any qualifer (shift/ctrl/alt/amiga)?
	beq.b	key_NORMAL
	moveq	#IEQUALIFIER_CONTROL,d1
	and.w	d5,d1
	bne	key_CTRL
key_NOCTRL:
	moveq	#IEQUALIFIER_LSHIFT|IEQUALIFIER_RSHIFT,d1
	and.w	d5,d1
	bne.b	key_SHIFT
	moveq	#IEQUALIFIER_LALT|IEQUALIFIER_RALT,d1
	and.w	d5,d1
	bne	key_ALT
key_NORMAL:
	cmp	#$004C,d4
	beq	key_UP
	cmp	#$004F,d4
	beq	key_RIGHT
	cmp	#$004E,d4
	beq	key_LEFT
	cmp	#$004D,d4
	beq	key_DOWN

	cmp	#$0050,d4
	beq	key_F1
	cmp	#$0051,d4
	beq	key_F2
	cmp	#$0052,d4
	beq	key_F3
	cmp	#$0053,d4
	beq	key_F4
	cmp	#$0054,d4
	beq	key_F5
	cmp	#$0055,d4
	beq	key_F6
	cmp	#$0056,d4
	beq	key_F7
	cmp	#$0057,d4
	beq	key_F8
	cmp	#$0058,d4
	beq	key_F9
	cmp	#$0059,d4
	beq	key_F10
	br	key_CONV

key_SHIFT:
	cmp	#$004C,d4
	beq	key_SHIFT_UP
	cmp	#$004F,d4
	beq	key_SHIFT_LEFT
	cmp	#$004E,d4
	beq	key_SHIFT_RIGHT
	cmp	#$004D,d4
	beq	key_SHIFT_DOWN
	br	key_CONV

key_CTRL:
;	jsr	test_debug
	cmp	#$0045,d4
	beq	key_AMIGA_ESC
	cmp	#$0046,d4
	beq	key_AMIGA_DEL
	cmp	#$0041,d4
	beq	key_AMIGA_BACK
;	cmp.w	#$0023,d4		;F
;	beq.w	AmigaPlusF

	tst.b	(PR_CtrlUp_Down).l
	beq	key_NOCTRL
	cmp	#$004C,d4
	beq	key_HOME
	cmp	#$004D,d4
	beq	C17888
	br	key_NOCTRL

key_ALT:
	cmp	#$004C,d4
	beq.b	key_ALT_UP
	cmp	#$004F,d4
	beq.b	key_ALT_LEFT
	cmp	#$004E,d4
	beq.b	key_ALT_RIGHT
	cmp	#$004D,d4
	beq.b	key_ALT_DOWN
	cmp	#$0046,d4
	beq.b	key_ALT_DEL
	cmp	#$0041,d4
	beq.b	key_ALT_BACK
	br	key_CONV

key_UP:
	moveq	#1,d0
	br	SentEscKey

key_RIGHT:
	moveq	#2,d0
	br	SentEscKey

key_LEFT:
	moveq	#3,d0
	br	SentEscKey

key_DOWN:
	moveq	#4,d0
	br	SentEscKey

key_SHIFT_UP:
	moveq	#5,d0
	br	SentEscKey

key_SHIFT_LEFT:
	moveq	#6,d0
	br	SentEscKey

key_SHIFT_RIGHT:
	moveq	#7,d0
	br	SentEscKey

key_SHIFT_DOWN:
	moveq	#8,d0
	br	SentEscKey

key_ALT_UP:
	moveq	#9,d0
	br	SentEscKey

key_ALT_LEFT:
	moveq	#10,d0
	br	SentEscKey

key_ALT_RIGHT:
	moveq	#11,d0
	br	SentEscKey

key_ALT_DOWN:
	moveq	#12,d0
	br	SentEscKey

key_AMIGA_ESC:
	moveq	#14,d0
	br	SentEscKey

key_AMIGA_DEL:
	moveq	#15,d0
	br	SentEscKey

key_AMIGA_BACK:
	moveq	#$10,d0
	br	SentEscKey

key_ALT_DEL:
	moveq	#$11,d0
	br	SentEscKey

key_ALT_BACK:
	moveq	#$12,d0
	br	SentEscKey

key_HOME:
	moveq	#$26,d0
	br	SentEscKey

key_END:
	moveq	#$40,d0
	br	SentEscKey

key_NUM5:
	moveq	#13,d0
	br	SentEscKey

C17888:
	moveq	#$40,d0
	br	SentEscKey

TheHelpKey:
	moveq	#$65,d0		;amiguide
	br	SentEscKey

key_F1:	moveq	#0,d0
	bra.b	key_Change2Source

key_F2:	moveq	#1,d0
	bra.b	key_Change2Source

key_F3:	moveq	#2,d0
	bra.b	key_Change2Source

key_F4:	moveq	#3,d0
	bra.b	key_Change2Source

key_F5:	moveq	#4,d0
	bra.b	key_Change2Source

key_F6:	moveq	#5,d0
	bra.b	key_Change2Source

key_F7:	moveq	#6,d0
	bra.b	key_Change2Source

key_F8:	moveq	#7,d0
	bra.b	key_Change2Source

key_F9:	moveq	#8,d0
	bra.b	key_Change2Source

key_F10:
	moveq	#9,d0

key_Change2Source:
	cmp.b	(CurrentSource-DT,a4),d0
	beq.b	key_NoSourceChange
	move.b	d0,(Change2Source-DT,a4)
	btst	#MB1_INCOMMANDLINE,(MyBits-DT,a4)
	beq.s	.ineditor

	cmp.l	(EditorRegs+(8+4)*4-DT,a4),a4
	bne.s	.ineditor

	st	(FromCmdLine-DT,a4)
	jsr	(Go2Sourcenow_SetCtx)
	sf	(FromCmdLine-DT,a4)
	bsr	RESETMENUTEXT2

.ineditor
	moveq	#$66,d0
	br	SentEscKey

key_NoSourceChange:
	moveq	#0,d0
	br	SentEscKey

check_menus:
	move	(im_Qualifier,a3),(MY_EVENT+ie_Qualifier-DT,a4)
	tst.b	(MenuStripChanged-DT,a4)	; discard if the menu strip has changed
	bne.w	nomore_mgs
	move	(im_Code,a3),d0			;menunr
	cmp	#MENUNULL,d0
	beq.b	nomore_mgs
	lea	(KEY_BUFFER-DT,a4),a2

find_menu_item:
	move.l	(MenuStrip-DT,a4),a0
	move.l	(IntBase-DT,a4),a6
	jsr	(_LVOItemAddress,a6)
	move.l	d0,a3
	lea	(mi_SIZEOF,a3),a0	; see GTMENUITEM_USERDATA in gadtools.i
	move.b	(a0)+,d0		; parse 2-byte code
	beq.b	menu_hotkey
	move.b	d0,(a2)+
	cmp.b	#27,d0			; ESC?
	beq.b	.Done
	move.b	(a0)+,d0
	beq.b	.Send
	move.b	d0,(a2)+
.Send	move.b	#13,(a2)+		; enter
.Done

check_menu_next:
	move	(mi_NextSelect,a3),d0	; drag-select support
	cmp	#MENUNULL,d0
	bne.b	find_menu_item
	move.l	a2,d0
	lea	(KEY_BUFFER-DT,a4),a1
	sub.l	a1,d0
	subq.l	#1,d0
	bmi.b	nomore_mgs
	br	key_GoAnyway

menu_hotkey:
	move.b	(a0)+,d0
	beq.b	check_menu_next
	move.w	#IEQUALIFIER_LCOMMAND|IEQUALIFIER_RCOMMAND,d1	; amiga keys
	and.w	(MY_EVENT+ie_Qualifier-DT,a4),d1
	beq.b	.Send
	cmp.b	#19,d0		; amiga-a
	blo.b	.Send
	cmp.b	#44,d0		; amiga-z
	bls.b	.IsLCase
	cmp.b	#70,d0		; amiga-Z
	bhi.b	.Send
	sub.b	#45-19,d0	; amiga-A - amiga-a
.IsLCase
	moveq	#IEQUALIFIER_LSHIFT|IEQUALIFIER_RSHIFT,d1
	and.w	(MY_EVENT+ie_Qualifier-DT,a4),d1
	beq.b	.Send
	add.b	#45-19,d0
.Send	move.b	#$80,(a2)+
	move.b	d0,(a2)+
	bra.b	check_menu_next

nomore_mgs:
	move.l	(KEY_MSG-DT,a4),a1
	move.l	(4).w,a6
	jsr	(_LVOReplyMsg,a6)
	clr.l	(KEY_MSG-DT,a4)
C17A44:
	btst	#SB1_MOUSE_KLIK,(SomeBits-DT,a4)
	beq.b	.C17A60
	btst	#SB3_SPEC_KEYS,(SomeBits3-DT,a4)	;editor
	beq.b	.C17A60
	btst	#SB2_MAKEMACRO,(SomeBits2-DT,a4)
	bne.b	.C17A60
	bsr	PlaceCursorByMouseclick
.C17A60	rts

CTRL_BREAK:
	move	(KeyboardOutBuf-DT,a4),(KeyboardInBuf-DT,a4)
	clr	d7
	bsr.w	Druk_Clearbuffer
	lea	(Break.MSG,pc),a0
	bsr	printthetext
	bra	CommandlineInputHandler

com_RedirectCMD:
	bsr.b	CloseRedirectedOutput
	clr.l	(FileLength-DT,a4)
	moveq	#8,d0
	bsr	FileReqStuff
	bsr	IO_OpenFile
	bclr	#SB1_CLOSE_FILE,(SomeBits-DT,a4)
	move.l	(Bestand-DT,a4),(RedirectHandle-DT,a4)
	bset	#SB2_OUTPUTACTIVE,(SomeBits2-DT,a4)
	rts

SEND_DIRECTOUT:
	movem.l	d0-d7/a1-a3/a5/a6,-(sp)
	move.l	(RedirectHandle-DT,a4),d1
	bsr	IO_WriteFile_D1
	movem.l	(sp)+,d0-d7/a1-a3/a5/a6
C17B06:
	rts

CloseRedirectedOutput:
	bclr	#SB2_OUTPUTACTIVE,(SomeBits2-DT,a4)
	move.l	(RedirectHandle-DT,a4),d1
	beq.b	C17B06
	clr.l	(RedirectHandle-DT,a4)
	bra	CLOSE_FILE_D1

com_read:
	clr.l	(FileLength-DT,a4)
	move.b	(a6),d0
	move.b	d0,d3
	cmp.b	#'0',d0				; Check commands R0 to R9
	blt.b	NoReadRecentSource		; 
	cmp.b	#'9',d0				; 
	bgt.b	NoReadRecentSource		; 
	bra	ReadRecentSource		; 
NoReadRecentSource:
	bclr	#5,d0
	cmp.b	#'T',d0
	beq	Com_ReadTrack
	cmp.b	#'S',d0
	beq	Com_ReadSector
	cmp.b	#'B',d0
	beq	Com_ReadBin
	cmp.b	#'O',d0
	beq	Com_ReadObject
	cmp.b	#'E',d0
	beq	COM_ReadProject
	cmp.b	#'N',d0
	beq.b	COM_ReadNormal
	cmp.b	#' ',d3
	beq	com_readFileNoReq
	tst.b	(a6)
	beq.b	Com_ReadSourceReq
	jmp	(ERROR_IllegalComman).l

COM_ReadNormal:
	bsr	CopyCurrSrcNameToReqAsActive
	bsr	ASK_CHECK_IF_SAVED
	moveq	#16,d0		;#?
	bsr	FileReqStuff
	bra.b	C17B66

Com_ReadSourceReq:
	bsr	CopyCurrSrcNameToReqAsActive
	bsr	ASK_CHECK_IF_SAVED
	moveq	#0,d0		;source extention like .asm|.s etc..
	bsr	FileReqStuff
C17B66:
	bsr	CheckIfSourceFitsInWS
	bsr	KILL_SOURCE
	bsr	C17C04
	bsr	OpenOldFile
	st	(Marksinsource-DT,a4)
	bsr	SaveMarksOpnieuwIstalleren
	lea	(CurrentAsmLine-DT,a4),a3
	bsr.b	AddRecentFile
	bsr	RESETMENUTEXT2
	bsr	C181F4
	bclr	#SB1_SOURCE_CHANGED,(SomeBits-DT,a4)
	bsr	C17B9E
	jmp	(ParseCustomTabs)

; -*-
; --- Load a Recent file ---
; In: d0.b: Number of file in ASCII
; Out: -
ReadRecentSource:
	moveq	#$f,d1
	and.l	d1,d0				; Source number
	move.b	(RecentFilesNbr-DT,a4),d1
	subq.l	#1,d1
	cmp.l	d1,d0
	ble.b	SourceAlreadyLoaded
	rts
SourceAlreadyLoaded:
	bsr.b	GetRecentfile
	bsr	CopyCurrSrcNameToReqAsActive
	bsr	ASK_CHECK_IF_SAVED
	bsr	C180E8				; Set name to title
	bra.b	C17B66

; -*-
; --- Pop a recent file from the list ---
; In: d0.l: Number of recent file
; Out: -
GetRecentfile:
	movem.l	d0/d7/a0/a1,-(a7)
	lea	(RecentCache-DT,a4),a0
	lea	(CurrentAsmLine-DT,a4),a1
	mulu.w	#146,d0				; Get menu entry
	add.w	d0,a0
	move.w	#144-1,d7
PutRecentFile:
	move.b	(a0)+,(a1)+
	dbeq	d7,PutRecentFile
	sf	(a1)
	movem.l	(a7)+,d0/d7/a0/a1
	rts

; -*-
; --- Scrolldown the list and store a filename in first position ---
; In: a3.l: Filename to add
; Out -
AddRecentFile:
	movem.l	d0-a6,-(a7)
	lea	(a3),a0				; FileName
	lea	(RecentCache-DT,a4),a1		; Search for same file in the list
	moveq	#0,d2
	moveq	#9-1,d7
	moveq	#0,d3				; Find flag
CheckEntries:
	bsr.w	CheckRecentFile
	tst.l	d1
	beq.b	FoundSameRecent
	addq.l	#1,d2				; Mark entry
	lea	146(a1),a1			; Next entry
	dbf	d7,CheckEntries
	moveq	#-1,d3
FoundSameRecent:
	tst.l	d2				; Already first file ?
	beq.w	DontMoveList
	move.w	d2,d6
	mulu.w	#146,d2
	lea	(RecentCache-DT,a4),a1
	add.w	d2,a1
	lea	-146(a1),a0
	subq.w	#1,d6
DownAllRecents:
	movem.l	a0/a1,-(a7)
	move.w	#146-1,d7
DownRecent:
	move.b	(a0)+,(a1)+
	dbf	d7,DownRecent
	movem.l	(a7)+,a0/a1
	lea	-146(a0),a0
	lea	-146(a1),a1
	dbf	d6,DownAllRecents
	lea	(a3),a0				; Insert new entry
	lea	(RecentCache-DT,a4),a1		; Beg of list
	move.w	#144-1,d7
CopyRecentFile:
	move.b	(a0)+,(a1)+
	dbeq	d7,CopyRecentFile
	sf	(a1)
	lea	MenuRecent,a0
	lea	(RecentFilesNbr-DT,a4),a2
	moveq	#0,d0
	cmp.b	#10,(a2)
	beq.b	UpDateRecentList
	tst.l	d3				; File just replaced: no add
	beq.b	UpDateRecentList
	addq.b	#1,(a2)				; Next file
UpDateRecentList:
	move.b	(a2),d0
	subq.w	#1,d0
SetRecentvisible:
	move.b	#NM_SUB,(a0)			; Make it visible
	lea	(gnm_SIZEOF,a0),a0		; Next menu struct
	dbf	d0,SetRecentvisible
	move.l	(Comm_menubase-DT,a4),d0	; Refresh menu strip
	jsr	(Breakdown_menu).l
	lea	(command_menus),a0
	jsr	(Init_menustructure-command_menus,a0)
	move.l	d0,(Comm_menubase-DT,a4)
	bsr.b	SaveRecentFiles
DontMoveList:
	movem.l	(a7)+,d0-a6
	rts

; -*-
; --- Check for same entry in the list ---
; In: a0.l: String to compare
;     a1.l: String from list
; Out:d0.l: 0: Same
;	    -1: Different
CheckRecentFile:
	movem.l	d0/d2/a0/a1,-(a7)
	moveq	#0,d1
SameLt:	move.b	(a0)+,d0
	move.b	(a1)+,d2
	bsr.b	ToUpper
	exg	d0,d2
	bsr.b	ToUpper
	cmp.b	d2,d0
	bne.b	DifferentLt
	tst.b	d2				; End of string
	beq.b	EndCheckLt
	bra.b	SameLt
DifferentLt:
	moveq	#-1,d1
EndCheckLt:
	movem.l	(a7)+,d0/d2/a0/a1
	rts

; -*-
; --- Convert a char to upper case ---
; In: d0.b: char
; Out: d0.b: converted char
ToUpper:
	cmp.b	#"a",d0
	blt.b	NoUpper
	cmp.b	#"z",d0
	bgt.b	NoUpper
	sub.b	#'a'-'A',d0
NoUpper:
	rts

; -*-
; Structure of ENVARC:Asm-Pro.Rcnt
; 1.l: Number of entries
; Entries:
; 	1.l: filename length
; 	x.b: filename string
;
; --- Save Recent files list (ENVARC:Asm-Pro.Rcnt) ---
; In: -
; Out: -
SaveRecentFiles:
	movem.l	d0-a6,-(a7)
	move.l	(DosBase-DT,a4),a6
	lea	(RecentName-DT,a4),a2
	move.l	a2,d1
	jsr	(_LVODeleteFile,a6)			; Delete file first
	move.l	a2,d1
	move.l	#MODE_NEWFILE,d2
	jsr	(_LVOOpen,a6)
	move.l	d0,d1
	beq.b	.NoSaveRecent
	lea	(RecentCache-DT,a4),a1
	moveq	#0,d0
	moveq	#10-1,d7
.CheckRecentNbr
	tst.b	(a1)
	beq.b	.NoRFileInLit
	addq.l	#1,d0
.NoRFileInLit
	lea	146(a1),a1
	dbf	d7,.CheckRecentNbr
	move.l	d1,-(a7)
	move.l	d0,-(a7)
	move.l	a7,d2
;	move.l	(DosBase-DT,a4),a6		; Save number of filenames
	moveq	#4,d3				; 4 bytes
	jsr	(_LVOWrite,a6)
	addq.l	#4,a7
	move.l	(a7)+,d1
	lea	(RecentCache+(9*146)-DT,a4),a1
	moveq	#10-1,d7
.SaveAllRecFiles
	movem.l	d1/d7/a1,-(a7)
	lea	(a1),a2				; Check for name's length
	move.l	a1,d2
	moveq	#-1,d3
.CheckRFEnd
	addq.l	#1,d3
	tst.b	(a2)+
	bne.b	.CheckRFEnd
	tst.l	d3				; Skip empty files
	beq.b	.NoSaveRecFile
	movem.l	d1-d3,-(a7)
	move.l	a7,d2				; Length in stack
	addq.l	#8,d2
	moveq	#4,d3
	jsr	(_LVOWrite,a6)
	movem.l	(a7)+,d1-d3			; (I can't remember if dos saves this) so
	move.l	d1,-(a7)
	jsr	(_LVOWrite,a6)
	move.l	(a7)+,d1
.NoSaveRecFile
	movem.l	(a7)+,d1/d7/a1
	lea	-146(a1),a1			; Save all names
	dbf	d7,.SaveAllRecFiles
	jsr	(_LVOClose,a6)
.NoSaveRecent
	movem.l	(a7)+,d0-a6
	rts

; -*-
; --- Load Recent files list (ENVARC:Asm-Pro.Rcnt) ---
; In: -
; Out: -
LoadRecentFiles:
	movem.l	d0-a6,-(a7)
	lea	(RecentCache-DT,a4),a0
	moveq	#10-1,d0
.InitCache
	clr.b	(a0)
	lea	(146,a0),a0
	dbf	d0,.InitCache

	lea	(RecentName-DT,a4),a0
	move.l	a0,d1
	move.l	#MODE_OLDFILE,d2
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOOpen,a6)
	move.l	d0,d1
	beq.b	.NoLoadRecent
	move.l	d1,-(a7)
	clr.l	-(a7)
	move.l	a7,d2
	moveq	#4,d3
	jsr	(_LVORead,a6)			; Read nbr
	move.l	(a7)+,d7
	move.l	(a7)+,d1
	lea	(RecentTmp-DT,a4),a1
	subq.w	#1,d7
	blt.b	.NoLoadRecent
.LoadAllRecFiles
	move.w	d7,-(a7)
	pea.l	(a1)
	move.l	d1,-(a7)
	clr.l	-(a7)				; Make room for length in stack
	move.l	a7,d2
	moveq	#4,d3				; Read 4 bytes
	jsr	(_LVORead,a6)			; Read length
	move.l	(a7)+,d3			; Get length
	move.l	(a7)+,d1
	move.l	(a7),d2
	move.l	d1,-(a7)
	jsr	(_LVORead,a6)			; Store filename in buffer
	move.l	(a7)+,d1
	move.l	(a7),a1
	sf.b	(a1,d0.w)			; NULL at end of buffer
	lea	(a1),a3
	bsr.w	AddRecentFile			; Add it to list !
	move.l	(a7)+,a1
	move.w	(a7)+,d7
	dbf	d7,.LoadAllRecFiles
	jsr	(_LVOClose,a6)
.NoLoadRecent
	movem.l	(a7)+,d0-a6
	rts

; -*- end here

C17B98:
	movem.l	d0-d7/a0-a6,-(sp)
	bra.b	C17BAE

C17B9E:
	movem.l	d0-d7/a0-a6,-(sp)
	lea	(MenuFileName,pc),a1
	moveq	#0,d0
	move.b	(CurrentSource-DT,a4),d0
C17BAE:
	move.l	(Edit_Menubase-DT,a4),a0
	move.l	(a0),a0
	move.l	(a0),a0
	move.l	($0012,a0),a0
	tst	d0
	beq.b	C17BC6
	subq.w	#1,d0
C17BC0:
	move.l	(a0),a0
	dbra	d0,C17BC0
C17BC6:
	move.l	($0012,a0),a0
	move.l	(12,a0),a0
	addq.w	#5,a0
	moveq	#30-1,d7
C17BD2:
	move.b	(a1)+,d0
	beq.b	C17BDE
	move.b	d0,(a0)+
	dbra	d7,C17BD2
C17BDE:
	tst	d7	;passone
	bmi.b	C17BEA
C17BE2:
	move.b	#' ',(a0)+
	dbra	d7,C17BE2
C17BEA:
	clr.b	(a0)
	move.l	(MainWindowHandle-DT,a4),a0
	move.l	(Edit_Menubase-DT,a4),a1
	move.l	(IntBase-DT,a4),a6
	jsr	(_LVOResetMenuStrip,a6)
	movem.l	(sp)+,d0-d7/a0-a6
	rts

C17C04:
	movem.l	a0/a1,-(sp)
	lea	(PrevDirnames-DT,a4),a0
	lea	(LastFileNaam-DT,a4),a1
C17C10:
	tst.b	(a0)
	beq.b	C17C18
	move.b	(a0)+,(a1)+
	bra.b	C17C10

C17C18:
	cmp.b	#':',(-1,a1)
	beq.b	C17C34
	cmp.b	#'/',(-1,a1)
	beq.b	C17C34
	cmp.l	#LastFileNaam,a1
	beq.b	C17C34
	move.b	#'/',(a1)+
C17C34:
	lea	(CurrentAsmLine-DT,a4),a0
C17C3A:
	cmp.b	#':',(a0)
	beq.b	C17C46
	tst.b	(a0)+
	bne.b	C17C3A
	bra.b	C17C4A

C17C46:
	lea	(LastFileNaam-DT,a4),a1
C17C4A:
	lea	(CurrentAsmLine-DT,a4),a0
C17C50:
	move.b	(a0)+,(a1)+
	tst.b	(a0)
	bne.b	C17C50
	clr.b	(a1)
	movem.l	(sp)+,a0/a1
	rts

SaveMarksOpnieuwIstalleren:
	movem.l	d0-d7/a0-a6,-(sp)
	lea	(ParameterBlok-DT,a4),a1
	clr.l	(a1)
	move.l	a1,d2
	move.l	(Bestand-DT,a4),d1
	movem.l	a1/a2,-(sp)

	moveq	#85,d3
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVORead,a6)

.nomoreread:
	movem.l	(sp)+,a1/a2
	cmp.l	#$F9FAF9FA,(a1)+
	bne.s	checknewsavemarks

	movem.l	a1/a2,-(sp)
	move.l	(Bestand-DT,a4),d1
	moveq	#44,d2
	moveq	#OFFSET_BEGINING,d3
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOSeek,a6)
	movem.l	(sp)+,a1/a2

	tst	(Marksinsource-DT,a4)
	beq.b	.nomarks
	move.l	(sourcestart-DT,a4),d0
	lea	(EditMarks10-DT,a4),a2
	moveq	#10-1,d7
.lopje:
	move.l	(a1)+,d1
	add.l	d0,d1
	move.l	d1,(a2)+
	dbra	d7,.lopje
.nomarks:
	movem.l	(sp)+,d0-d7/a0-a6
	rts

checknewsavemarks:
	cmp.l	#";APS",-4(a1)
	bne.s	GeenSaveMarks
	tst	(Marksinsource-DT,a4)
	beq.b	.nomarks
	move.l	(sourcestart-DT,a4),d0
	lea	(EditMarks10-DT,a4),a2
	moveq	#10-1,d7
.lopje:
	moveq	#0,d1
	moveq	#8-1,d4
.marklop
	move.b	(a1)+,d2
	sub.b	#'0',d2
	cmp.b	#9,d2
	bls.s	.ok
	subq.b	#7,d2
.ok:
	lsl.l	#4,d1
	or.b	d2,d1
	dbf	d4,.marklop

	add.l	d0,d1			; relocate save marks
	move.l	d1,(a2)+
	dbra	d7,.lopje
.nomarks:
	movem.l	(sp)+,d0-d7/a0-a6
	rts

GeenSaveMarks:
	move.l	(Bestand-DT,a4),d1
	moveq	#0,d2
	moveq	#OFFSET_BEGINING,d3
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOSeek,a6)
	movem.l	(sp)+,d0-d7/a0-a6
	rts

CheckIfSourceFitsInWS:
	movem.l	d0-d4/a0/a6,-(sp)
	move.l	(DosBase-DT,a4),a6
	lea	(CurrentAsmLine-DT,a4),a0
	move.l	a0,d1
	moveq	#ACCESS_READ,d2
	jsr	(_LVOLock,a6)
	tst.l	d0
	bne.b	C17CEE
	lea	(SourceCode-DT,a4),a0
	move.l	a0,d1
	jsr	(_LVOLock,a6)
	tst.l	d0
	beq.b	C17D16
C17CEE:
	move.l	d0,-(sp)
	move.l	d0,d1
	lea	(ParameterBlok-DT,a4),a0
	move.l	a0,d2
	jsr	(_LVOExamine,a6)
	move.l	(sp)+,d1
	jsr	(_LVOUnLock,a6)
	move.l	(WORK_END-DT,a4),d1
	sub.l	(WORK_START-DT,a4),d1
	sub.l	(ParameterBlok+fib_Size-DT,a4),d1
	ble.b	C17D1C
C17D16:
	movem.l	(sp)+,d0-d4/a0/a6
	rts

C17D1C:
	movem.l	(sp)+,d0-d4/a0/a6
	moveq	#0,d7
	addq.l	#4,sp
	lea	(Notenoughwork.MSG,pc),a0
	bra.w	beeldtextaf

COM_ReadProject:
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(ASK_CHECK_ALL_IF_SAVED)
	movem.l	(sp)+,d0-d7/a0-a6
	addq.l	#1,a6
	cmp.b	#" ",(a6)
	beq	C1806A
	moveq	#14,d0		;readproject
	bsr	FileReqStuff
C17D50:
	clr.l	(FileLength-DT,a4)
	bsr	OpenOldFile
	move.l	(Bestand-DT,a4),d1
	moveq	#-4,d2
	moveq	#OFFSET_END,d3
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOSeek,a6)
	lea	(TempDirName-DT,a4),a0
	move.l	a0,d2
	moveq	#4,d3
	bsr	read_nr_d3_bytes
	lea	(TempDirName-DT,a4),a0
	cmp.l	#"APRJ",(a0)
	beq.b	C17D8E
	moveq	#0,d7
	bsr	close_bestand
	jmp	(ERROR_ThisisnotaAsmProj)

C17D8E:
	movem.l	a0/a1,-(sp)
	lea	(ProjectName-DT,a4),a0
	lea	(CurrentAsmLine-DT,a4),a1
C17D9A:
	move.b	(a1)+,(a0)+
	bne.b	C17D9A
	movem.l	(sp)+,a0/a1
	move.l	(Bestand-DT,a4),d1
	moveq	#0,d2
	moveq	#OFFSET_BEGINNING,d3
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOSeek,a6)
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(FreeSources).l
	movem.l	(sp)+,d0-d7/a0-a6
	lea	(PrevDirnames-DT,a4),a0
	move.l	a0,d2
	move.l	#128,d3
	bsr	read_nr_d3_bytes
	lea	(CurrentSource-DT,a4),a0
	move.l	a0,d2
	moveq	#2,d3
	bsr	read_nr_d3_bytes
	bsr	KILL_SOURCE
	lea	(LastFileNaam-DT,a4),a0
	move.l	a0,d2
	move.l	#CS_size,d3
	bsr	read_nr_d3_bytes
	moveq	#10-1,d7
	lea	(SourcePtrs-DT,a4),a0
C17DFC:
	move.l	d7,-(sp)
	move.l	a0,-(sp)
	moveq	#CS_filename,d2
	add.l	(sp),d2
	moveq	#31,d3
	bsr	read_nr_d3_bytes

	moveq	#CS_FirstLinePtr,d2
	add.l	(sp),d2
	moveq	#4,d3
	bsr	read_nr_d3_bytes

	move.w	#CS_FirstlineNr,a0 ;fake save mark stuff so project files still work.
	add.l	(sp),a0
	clr.w	(a0)+
	move.l	a0,d2
	moveq	#2,d3
	bsr	read_nr_d3_bytes

	move.w	#CS_FirstLineOffset,a0 ;fake also
	add.l	(sp),a0
	clr.w	(a0)+
	move.l	a0,d2
	moveq	#2,d3
	bsr	read_nr_d3_bytes

	moveq	#CS_SomeBits,d2
	add.l	(sp),d2
	moveq	#2,d3
	bsr	read_nr_d3_bytes

	moveq	#CS_marks,d2
	add.l	(sp),d2
	move.l	d2,-(sp)
	moveq	#$28,d3
	bsr	read_nr_d3_bytes
	move.l	(sp)+,a0
	move.l	(sourcestart-DT,a4),d0
	moveq	#10-1,d1
.RelocMarks
	tst.l	(a0)+
	beq.b	.NextMark
	add.l	d0,(-4,a0)		; rel to abs
.NextMark
	dbf	d1,.RelocMarks

	moveq	#CS_update,d2
	add.l	(sp),d2
	move.l	#128,d3
	bsr	read_nr_d3_bytes

	move.l	#CS_AsmStatus,d2
	add.l	(sp),d2
	moveq	#2,d3
	bsr	read_nr_d3_bytes
	move.l	(sp)+,a0
	move.l	(sp)+,d7
	lea	(CS_size,a0),a0
	dbra	d7,C17DFC

	bsr	close_bestand
	lea	(LastFileNaam-DT,a4),a0
	lea	(CurrentAsmLine-DT,a4),a1
C17EA2:
	move.b	(a0)+,(a1)+
	bne.b	C17EA2
	clr.l	(FileLength-DT,a4)
	bsr	C17B66			; read source w/o file requester
	lea	(SourcePtrs-DT,a4),a0
	moveq	#9,d7
C17EB8:
	clr.l	(FileLength-DT,a4)
	lea	(TempDirName-DT,a4),a1
	lea	(CS_update,a0),a2
	lea	(CurrentAsmLine-DT,a4),a3
	tst.b	(a2)
	beq	C17FEC
C17ECE:
	move.b	(a2),(a1)+
	move.b	(a2)+,(a3)+
	bne.b	C17ECE
	moveq	#9,d0
	sub	d7,d0
	lea	(CurrentAsmLine-DT,a4),a1
C17EE0:
	tst.b	(a1)+
	bne.b	C17EE0
	subq.l	#1,a1

C17EE8:
	cmp.b	#':',-(a1)
	beq.b	C17EFC
	cmp.b	#'/',(a1)
	bne.b	C17EE8
C17EFC:
	addq.l	#1,a1

	bsr	C17B98
	movem.l	d7/a0,-(sp)
	bsr	CheckIfSourceFitsInWS
	movem.l	(sp),d7/a0
	lea	(ParameterBlok-DT,a4),a3
	move.l	(fib_Size,a3),(CS_length,a0)
	bsr	OpenOldFile
	movem.l	(sp),d7/a0
	move.l	(Bestand-DT,a4),d1
	move.l	(a0),d2		; CS_start
	moveq	#4,d3
	move.l	d2,-(sp)
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVORead,a6)
	move.l	(sp)+,a1
	moveq	#44,d2
	cmp.l	#$F9FAF9FA,(a1)
	beq.b	.marksfound
	moveq	#85,d2
	cmp.l	#";APS",(a1)
	beq.b	.marksfound
	moveq	#0,d2
.marksfound:
	move.l	d2,-(sp)
	move.l	(Bestand-DT,a4),d1
	moveq	#OFFSET_BEGINNING,d3
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOSeek,a6)
	move.l	(sp)+,d2
	movem.l	(sp),d7/a0
	sub.l	d2,(CS_length,a0)
	move.l	(CS_length,a0),d0
	move.l	#$00010001,d1
	move.l	(4).w,a6
	jsr	(_LVOAllocMem,a6)
	movem.l	(sp)+,d7/a0
	move.l	d0,(a0)		; CS_start
	bne.b	C17F9C
	jmp	ERROR_WorkspaceMemoryFull

C17F9C:
	move.l	(sourcestart-DT,a4),d2
	add.l	d2,(CS_FirstLinePtr,a0)
	move.l	(a0),d2		; CS_start
	move.l	(CS_length,a0),d3
	movem.l	d7/a0,-(sp)
	bsr	read_nr_d3_bytes
	movem.l	(sp)+,d7/a0
	move.l	(a0),a1		; CS_start
	move.l	a1,a2
	add.l	(CS_length,a0),a2
	moveq	#10,d0
C17FCC:
	cmp.b	(a1)+,d0
	bne.b	C17FD6
	clr.b	(-1,a1)
C17FD6:
	cmp.l	a1,a2
	bne.b	C17FCC
	move.b	#SRCMARK_END,(a1)
	move.l	a0,-(sp)
	bsr	close_bestand
	move.l	(sp)+,a0
C17FEC:
	lea	(CS_size,a0),a0
	dbra	d7,C17EB8
	lea	(LastFileNaam-DT,a4),a1
C17FF8:
	tst.b	(a1)+
	bne.b	C17FF8
	subq.l	#1,a1

C18000:
	cmp.b	#':',-(a1)
	beq.b	C18014
	cmp.b	#'/',(a1)
	bne.b	C18000
C18014:
	addq.l	#1,a1

	lea	(MenuFileName,pc),a2
	moveq	#30-1,d7
C1801C:
	move.b	(a1)+,d0
	beq.b	C1802A
	move.b	d0,(a2)+
	dbra	d7,C1801C
	bra.b	C18030

C1802A:
	move.b	d0,(a2)+
	dbra	d7,C1802A
C18030:
	clr.b	(a2)
	lea	(MenuFileName,pc),a1
	moveq	#0,d0
	bsr	C17B98
	moveq	#$56,d0
	bsr	KEYBUFFERPUTCHAR
	moveq	#$20,d0
	bsr	KEYBUFFERPUTCHAR
	lea	(PrevDirnames-DT,a4),a0
	jsr	(DATAFROMAUTO).l
	moveq	#10,d0
	bsr	KEYBUFFERPUTCHAR
	br	RESETMENUTEXT2

C1806A:
	bsr.b	C180C4
	br	C17D50

com_readFileNoReq:
	bsr	CopyCurrSrcNameToReqAsActive
	move.l	a6,a5
	bsr	ASK_CHECK_IF_SAVED
	move.l	a5,a6
	bsr.b	C180C4
	bsr.b	C180E8
	br	C17B66

C1809A:
	lea	(UserSrcExt.MSG).l,a1
	moveq	#16-1,d7
C180A2:
	move.b	(-16,a0,d7.w),d0
	move.b	(a1,d7.w),d1
	cmp.b	d0,d1
	bne.b	C180B8
	dbra	d7,C180A2

	clr.b	(a0)
	rts

C180B8:
	moveq	#16-1,d7
C180BA:
	move.b	(a1)+,(a0)+
	dbra	d7,C180BA
	clr.b	(a0)
	rts

C180C4:
	lea	(CurrentAsmLine-DT,a4),a0
	bra.b	C180CA
C180D8:
	addq.l	#1,a6
C180CA:
	cmp.b	#' ',(a6)
	beq.b	C180D8
	cmp.b	#9,(a6)
	beq.b	C180D8
C180DC:
	move.b	(a6)+,(a0)+
	bne.b	C180DC
	subq.l	#1,a6
	subq.l	#1,a0
	rts

C180E8:	; SET_EDITOR_FILENAME
	lea	(CurrentAsmLine-DT,a4),a1
	move.l	a1,a0
.C180F4	tst.b	(a1)+
	bne.b	.C180F4

.C180FC	cmp.l	a0,a1
	beq.b	.NoDir
	cmp.b	#':',-(a1)
	beq.b	.Found
	cmp.b	#'/',(a1)
	bne.b	.C180FC
.Found	addq.l	#1,a1
.NoDir	lea	(MenuFileName,pc),a0
.C18118
	move.b	(a1)+,(a0)+
	bne.b	.C18118
	rts

com_palette:
	move.l	(ReqToolsbase-DT,a4),d0
	bne.b	.OpenColorReq
	jsr	(openreqtoolslib).l
	move.l	(ReqToolsbase-DT,a4),d0
	beq.b	C18154

.OpenColorReq
	move.l	d0,a6
	lea	(Selectcolours.MSG).l,a2
	sub.l	a3,a3
	sub.l	a0,a0
	jsr	(_LVOrtPaletteRequestA,a6)
	tst.l	d0
	bmi.b	C18154
	bsr.b	GetPaletteRGB
	move.b	#1,(PaletteStatus-DT,a4)	; have active palette
C18154:
	rts

GetPaletteRGB:
	lea	(ScrColors-DT,a4),a5
	move.l	(GfxBase-DT,a4),a6
	moveq	#16-1,d7
.C1816C
	move.l	(ViewPortBase-DT,a4),a0
	move.l	(4,a0),a0
	moveq	#15,d0
	eor.w	d7,d0
	jsr	(_LVOGetRGB4,a6)
	moveq	#15,d2
	and.w	d0,d2
	lsr.w	#4,d0
	moveq	#15,d1
	and.w	d0,d1
	lsr.w	#4,d0
	movem.w	d0-d2,(a5)
	addq.l	#6,a5
	dbra	d7,.C1816C
	rts

SetPaletteRGB:
	move.l	(GfxBase-DT,a4),a6
	lea	(ScrColors-DT,a4),a2
	moveq	#16-1,d7
.C181B4
	moveq	#15,d0
	eor.w	d7,d0
	movem.w	(a2)+,d1-d3
	move.l	(ViewPortBase-DT,a4),a0
	jsr	(_LVOSetRGB4,a6)
	dbra	d7,.C181B4
	rts

C181DA:
	clr.l	(FileLength-DT,a4)
	moveq	#10,d0
	bsr	FileReqStuff
C181E4:
	bsr	CheckIfSourceFitsInWS
	bsr	OpenOldFile
	clr	(Marksinsource-DT,a4)
	bsr	SaveMarksOpnieuwIstalleren
C181F4:
	move.l	(FirstLinePtr-DT,a4),a2
	jsr	(KillCopybuffer).l
C181FE:
	lea	(ParameterBlok-DT,a4),a5
	move.l	a5,d2
	move.l	#USERPRG_STACK_SIZE*2,d3
	movem.l	a2/a5,-(sp)
	bsr	read_nr_d3_bytes
	movem.l	(sp)+,a2/a5
	sub.l	a5,d0
	beq.b	C18260
	cmp.b	#SRCMARK_END,(-1,a5,d0.l)
	bne.b	C18224
	subq.l	#1,d0
C18224:
	move.l	d0,a1
	move.l	a2,a3
	jsr	(EDITOR_MAKEHOLE_A1LONG).l
	move.l	d0,d1
	tst	(Marksinsource-DT,a4)
	bne.b	C18256
	jsr	(MOVEMARKS).l
	bra.b	C18256

C1823E:
	clr.l	(FileLength-DT,a4)
	bsr	C180C4
	tst.b	(PR_SourceExt).l
	beq.b	C181E4
	bsr	C1809A
	bra.b	C181E4

C18254:
	move.b	(a5)+,(a2)+
C18256:
	dbra	d0,C18254
	cmp	#$2000,d1
	beq.b	C181FE
C18260:
	bsr	close_bestand
	bra	C12688

Com_ReadObject:
	addq.w	#1,a6
	move.l	a6,-(sp)
	bsr.b	UnloadCurrObject
	move.l	(sp)+,a6
	cmp.b	#' ',(a6)
	beq.b	C182B8
	moveq	#4,d0
	bsr	FileReqStuff
C1827E:
	lea	(CurrentAsmLine-DT,a4),a0
	move.l	a0,d1
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOLoadSeg,a6)
	move.l	d0,(SEGMENTADDRESS-DT,a4)
	beq.w	_ERROR_FileError
	lsl.l	#2,d0
	move.l	d0,a0
	move.l	(a0)+,(SEGMENTLENGTH-DT,a4)
	move.l	a0,(FileLength-DT,a4)
	move.l	a0,(MEM_DIS_DUMP_PTR-DT,a4)
	move.l	a0,(pcounter_base-DT,a4)
	lea	(Filelocation.MSG,pc),a0
	br	Writefile_afwerken

C182B8:
	bsr	C180C4
	bra.b	C1827E

UnloadCurrObject:
	move.l	(SEGMENTADDRESS-DT,a4),d1
	beq.b	.C182DA
	clr.l	(SEGMENTADDRESS-DT,a4)
	lsl.l	#2,d1
	move.l	d1,a0
	move.l	(SEGMENTLENGTH-DT,a4),(a0)
	lsr.l	#2,d1
	move.l	(DosBase-DT,a4),a6
	jmp	(_LVOUnLoadSeg,a6)
.C182DA
	rts

Com_ReadBin:
	addq.l	#1,a6
	cmp.b	#" ",(a6)
	beq.b	.nofilereq
	moveq	#2,d0
	bsr	FileReqStuff
.resume
	bsr.b	OpenOldFile

	bsr	INPUTBEGIN_MAYBEEND
	tst.l	d2
	bmi.b	.notdone
	move.l	d2,(MEM_DIS_DUMP_PTR-DT,a4)

	moveq	#0,d7			; clear flags
	bsr.b	read_nr_d3_bytes
	br	close_bestand

.notdone:
	bset	#SB3_SPEC_KEYS,(SomeBits3-DT,a4)	;editor
	bsr	close_bestand
	bclr	#SB3_SPEC_KEYS,(SomeBits3-DT,a4)	;editor
	rts

.nofilereq:
	bsr	C180C4
	bra.b	.resume

read_nr_d3_bytes:
	move.l	d2,-(sp)
	bclr	#31,d3
	move.l	(Bestand-DT,a4),d1
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVORead,a6)
	add.l	d0,(FileLength-DT,a4)
	add.l	(sp)+,d0
	rts

IO_WriteFile:
	move.l	(Bestand-DT,a4),d1
IO_WriteFile_D1:
	move.l	(DosBase-DT,a4),a6
	add.l	d3,(FileLength-DT,a4)
	jsr	(_LVOWrite,a6)
	sub.l	d3,d0
	bne.b	C183B8
	rts

OpenOldFile:
	move.l	#MODE_OLDFILE,d2
C18342:
	lea	(CurrentAsmLine-DT,a4),a0
	move.l	a0,d1
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOOpen,a6)
	tst.l	d0
	bne.b	.C18368
	move.l	#MODE_OLDFILE,d2
	lea	(SourceCode-DT,a4),a0
	tst.b	(a0)			; ensure we have a filename
	beq.w	_ERROR_FileError
	move.l	a0,d1
	jsr	(_LVOOpen,a6)
.C18368
	move.l	d0,(Bestand-DT,a4)
	beq.w	_ERROR_FileError
	bset	#SB1_CLOSE_FILE,(SomeBits-DT,a4)
	rts

C183B8:
	bsr.b	close_bestand
	jmp	(ERROR_NoFileSpace).l

IO_OpenFile:
	move.l	(DosBase-DT,a4),a6
	lea	(CurrentAsmLine-DT,a4),a0
	move.l	a0,d1
	moveq	#ACCESS_READ,d2
	jsr	(_LVOLock,a6)
	move.l	d0,d1
	beq.b	OPENFILE_NOASK
	jsr	(_LVOUnLock,a6)
	tst.b	(Safety-DT,a4)
	bne.b	OPENFILE_NOASK
	bsr	ASK_IF_OVERWRITE_OK
OPENFILE_NOASK:
	jsr	DeactivateMsgs
	move.l	(DosBase-DT,a4),a6
	lea	(CurrentAsmLine-DT,a4),a0
	move.l	a0,d1
	jsr	(_LVODeleteFile,a6)
	move.l	#MODE_NEWFILE,d2
	bra.b	C18342

CLOSE_FILE_NO_PRINT:
	move.l	d7,-(sp)
	moveq	#-2,d7
	bsr.b	close_bestand
	move.l	(sp)+,d7
	rts

close_bestand:
	bclr	#SB1_CLOSE_FILE,(SomeBits-DT,a4)
	move.l	(Bestand-DT,a4),d1
CLOSE_FILE_D1:
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOClose,a6)

	jsr	ActivateMsgs

	btst	#SB3_SPEC_KEYS,(SomeBits3-DT,a4)	;editor
	bne.b	C183F4
	moveq	#-1,d0
	cmp.l	d0,d7
	bne.b	C183EC
PrintFileLengthEOL:
	lea	(FilelengthEOL.MSG,pc),a0
	br	Writefile_afwerken

C183EC:
	moveq	#-2,d0
	cmp.l	d0,d7
	bne.b	DrukFilelength
C183F4:
	rts

DrukFilelength:
	lea	(Filelength.MSG,pc),a0
	br	Writefile_afwerken

DIROUT_PRINTLINE:
	moveq	#79-1,d1
.LOOP	moveq	#'-',d0
	bsr	SENDONECHARNORMAL
	dbra	d1,.LOOP
	br	druk_cr_nl

DIROUT_PRINTFHALV:
	bsr.b	DIROUT_PRINTLINE
	lea	(Name.MSG,pc),a0
	br	printthetext

DIROUT_PRINTSHALV:
	move.l	(4,sp),d0
	lsl.l	#8,d0
	lsl.l	#1,d0
	bsr	PRINTDECIMALLONG
	lea	(BytesFree.MSG,pc),a0
	bsr	printthetext
	move.l	(8,sp),d0
	lsl.l	#8,d0
	lsl.l	#1,d0
	bsr	PRINTDECIMALLONG
	lea	(BytesUsed.MSG,pc),a0
	bsr	printthetext
	bsr.b	DIROUT_PRINTLINE
	bsr.w	Druk_Clearbuffer
	move.l	(sp)+,a3
	addq.w	#8,sp
	jmp	(a3)

SORTDIRECTORY:
	move.l	a5,-(sp)
	move	(MEMDIR_ANTAL-DT,a4),d6
	beq.b	C184AA
	lea	(L2C06A-DT,a4),a1
	move	#$DFDF,d2
	lea	(-34,a1),a0
	moveq	#0,d5
C18466:
	addq.w	#1,d5
	cmp	d5,d6
	beq.b	C184AA
	move.l	a1,a0
	add	#34,a1
C18472:
	move.l	a0,a2
	move.l	a1,a3
	moveq	#30/2-1,d3
C18478:
	move	(a2)+,d0
	move	(a3)+,d1
	and	d2,d0
	and	d2,d1
	cmp	d0,d1
	bne.b	C18488
	dbra	d3,C18478
C18488:
	bcc.b	C18466
	move.l	a0,a2
	move.l	a1,a3
	subq.w	#4,a2
	subq.w	#4,a3
	moveq	#34/2-1,d1
C18494:
	move	(a2),d0
	move	(a3),(a2)+
	move	d0,(a3)+
	dbra	d1,C18494
	move.l	a0,a1
	sub	#34,a0
	subq.w	#1,d5
	beq.b	C18466
	bra.b	C18472

C184AA:
	move.l	(sp)+,a5
	rts

ViewMemDirectory:
	lea	(Memorydirecto.MSG,pc),a0
	bsr	printthetext
	bsr	DIROUT_PRINTFHALV
	addq.w	#4,a5			 	; pass header
	moveq	#30-1-1,d1			; keep the addresses even 
C184BE:
	move.b	(a5)+,d0			; print path
	bsr	SENDONECHARNORMAL
	dbra	d1,C184BE
	tst.b	(a5)+				; and back to even address
	bne.b	C184D4
	bsr.b	SORTDIRECTORY
	st.b	(-1,a5)
C184D4:
	move.l	(a5)+,-(sp)			; print used/free bytes
	move.l	(a5)+,-(sp)
	bsr	DIROUT_PRINTSHALV
	move	(MEMDIR_ANTAL-DT,a4),d6
	moveq	#2,d5				; 2 cols
PrintFilesMemLoop:
	subq.w	#1,d6
	bmi.w	druk_cr_nl
	move.l	(a5)+,d0			; file length
	bmi.b	PrintMemDir			; it is a directory ?
	moveq	#$20,d3
	lea	(TABEL_HEXTODECFILE,pc),a0
	bsr	PRINTDECIMAL
	bsr	druk_af_space
	bra.b	C18504

PrintMemDir:
	lea	(dir.MSG,pc),a0
	bsr	printthetext
C18504:
	moveq	#30-1,d1
C18506:
	move.b	(a5)+,d0			; print filename
	bsr	SENDONECHARNORMAL
	dbra	d1,C18506
	bsr.w	Druk_Clearbuffer
	subq.w	#1,(ShowDir_NrLines-DT,a4)
	bne.b	C18540
	bsr	GETKEYNOPRINT
	cmp.b	#27,d0			; esc?
	bne.b	C18532
	br	druk_cr_nl

C18532:
	move	(ScreenHight-DT,a4),d0
	add.w	d0,d0
	subq.w	#2,d0
	move	d0,(ShowDir_NrLines-DT,a4)
C18540:
	subq.w	#1,d5
	bne.b	PrintFilesMemLoop
	bsr	druk_cr_nl			; next row
	moveq	#2,d5				; getting started for 2 cols
	bra.b	PrintFilesMemLoop

SetViewCurrentDir:
	clr.l	(a5)+
	addq.w	#1,a0
	move.l	a0,d1
	moveq	#ACCESS_READ,d2
	jsr	(_LVOLock,a6)
	tst.l	d0
	beq.w	com_show_dir\.BadPath
	lea	(ParameterBlok-DT,a4),a0
	move.l	a0,d2
	st	(ParameterBlok+fib_DirEntryType-DT,a4)
	move.l	d0,d1
	move.l	d1,-(sp)
	jsr	(_LVOExamine,a6)
	move.l	(sp)+,d0
	tst.l	(ParameterBlok+fib_DirEntryType-DT,a4)
	bmi.w	com_show_dir\.UnlockBadPath
	lea	(CurrentAsmLine+2-DT,a4),a0
	bsr.b	C185E2
	tst.b	(a0)
	beq.b	C185D2
	move.l	d0,d1
	jmp	(_LVOCurrentDir,a6)

C185D2:
	move.l	#$12131415,(a5)+
	clr	(MEMDIR_ANTAL-DT,a4)
	move.l	d0,-(sp)
	br	C18734

C185E2:
	movem.l	d0-a6,-(sp)
	move.l	a0,-(sp)
C185E8:
	move.b	(a0)+,d0
	cmp.b	#':',d0
	beq.b	C1865C
	tst.b	d0
	bne.b	C185E8
	move.l	(sp)+,a0
	lea	(PrevDirnames-DT,a4),a1
	move.l	a1,a2
C185FA:
	cmp.b	#'/',(a0)
	bne.b	C1862C
	addq.w	#1,a0
C18602:
	tst.b	(a1)+
	bne.b	C18602
	subq.w	#1,a1
	cmp.l	a2,a1
	beq.b	C1864E
C18610:
	clr.b	-(a1)
	cmp.b	#':',(-1,a1)
	beq.b	C185FA
	cmp.b	#'/',(-1,a1)
	beq.b	C185FA
	cmp.l	a2,a1
	beq.b	C1864E
	bra.b	C18610

C1862C:
	tst.b	(a1)+
	bne.b	C1862C
	subq.w	#1,a1
	cmp.b	#':',(-1,a1)
	beq.b	C1864E
	cmp.b	#'/',(-1,a1)
	beq.b	C1864E
	cmp.l	a2,a1
	beq.b	C1864E
	move.b	#'/',(a1)+
C1864E:
	move.b	(a0)+,(a1)+
	bne.b	C1864E
	movem.l	(sp)+,d0-a6
	rts

C1865C:
	move.l	(sp)+,a0
	lea	(PrevDirnames-DT,a4),a1
	bra.b	C1864E

; V - view dir command
com_show_dir:
	move	(ScreenHight-DT,a4),d0
	subq.w	#4,d0
	add.w	d0,d0
	move	d0,(ShowDir_NrLines-DT,a4)
	move.l	(DosBase-DT,a4),a6
	lea	(CurrentAsmLine+1-DT,a4),a0
	lea	(MEMDIR_BUFFER-DT,a4),a5
	tst.b	(a0)
	bne.b	.C1869A
	cmp.l	#$12131415,(a5)			; go to mem directory
	beq	ViewMemDirectory
	cmp.l	#$51413121,(a5)
	bne.b	.C1869A
	jmp	(ERROR_Novalidmemory).l

.C1869A:
	cmp.b	#' ',(a0)			; V xxx = just set current dir
	beq	SetViewCurrentDir
	move.l	#$12131415,(a5)+
	clr	(MEMDIR_ANTAL-DT,a4)
	move.l	a0,d1
	moveq	#ACCESS_READ,d2
	jsr	(_LVOLock,a6)
	tst.l	d0
	beq.b	.BadPath
	lea	(ParameterBlok-DT,a4),a0
	move.l	a0,d2
	st	(ParameterBlok+fib_DirEntryType-DT,a4)
	move.l	d0,d1
	move.l	d1,-(sp)
	jsr	(_LVOExamine,a6)
	move.l	(sp)+,d0
	tst.l	(ParameterBlok+fib_DirEntryType-DT,a4)
	bpl.b	.ItsDir
.UnlockBadPath
	move.l	d0,d1
	jsr	(_LVOUnLock,a6)
.BadPath
	clr.l	(L2C05E-DT,a4)
	clr.l	(L2C062-DT,a4)
	move.l	#$51413121,(MEMDIR_BUFFER-DT,a4)
	jmp	(ERROR_IllegalPath).l

.ItsDir
	lea	(CurrentAsmLine+1-DT,a4),a0
	bsr	C185E2
	move.l	d0,-(sp)
	tst.b	(a0)
	beq.b	C18734
	move.l	d0,d1
	jsr	(_LVOCurrentDir,a6)
C18734:
	move.l	(sp),d1
	lea	(ParameterBlok-DT,a4),a0
	move.l	a0,d2
	jsr	(_LVOInfo,a6)
	move.l	(sp),d1
	movem.l	(ParameterBlok+id_NumBlocks-DT,a4),d0/d2 ; total/used
	sub.l	d2,d0			; free = total-used
	movem.l	d0/d2,-(sp)		; free/used
	lea	(ParameterBlok-DT,a4),a0
	move.l	a0,d2
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOExamine,a6)
	bsr	DIROUT_PRINTFHALV
	tst.l	(ParameterBlok+fib_EntryType-DT,a4)
	bmi.b	com_show_dir\.BadPath
	lea	(ParameterBlok+fib_FileName-DT,a4),a0
	moveq	#30-1-1,d1		; keep the addresses even 
.C18790	move.b	(a0)+,d0		; store path
	beq.b	.C187A0
	move.b	d0,(a5)+
	bsr	SENDONECHARNORMAL
	dbra	d1,.C18790
	bra.b	.C187AC
.C187A0
	moveq	#' ',d0
	move.b	d0,(a5)+
	bsr	SENDONECHARNORMAL
	dbra	d1,.C187A0
.C187AC
	clr.b	(a5)+			; and back to even address
	move.l	(4,sp),(a5)+
	move.l	(sp),(a5)+
	bsr	DIROUT_PRINTSHALV
	move.l	(sp),d1
	lea	(ParameterBlok-DT,a4),a0
	move.l	a0,d2
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOExNext,a6)
	tst	d0
	bne.b	C187D2
	jmp	(ERROR_NoFiles).l

C187D2:
	move	#2,-(sp)
C187D6:
	move.l	(ParameterBlok+fib_EntryType-DT,a4),d0
	bpl.b	.ItsDir
	move.l	(ParameterBlok+fib_Size-DT,a4),d0
	move.l	d0,(a5)+
	moveq	#' ',d3
	lea	(TABEL_HEXTODECFILE,pc),a0
	bsr	PRINTDECIMAL
	bsr	druk_af_space
	bra.b	C18800

.ItsDir
	moveq	#~0,d0
	move.l	d0,(a5)+		; dir flag
	lea	(dir.MSG,pc),a0
	bsr	printthetext
C18800:
	lea	(ParameterBlok+fib_FileName-DT,a4),a0
	moveq	#30-1,d1
C18806:
	move.b	(a0)+,d0
	beq.b	C18816
	move.b	d0,(a5)+
	bsr	SENDONECHARNORMAL
	dbra	d1,C18806
	bra.b	C18822

C18816:
	moveq	#' ',d0
	move.b	d0,(a5)+
	bsr	SENDONECHARNORMAL
	dbra	d1,C18816
C18822:
	addq.w	#1,(MEMDIR_ANTAL-DT,a4)
	bsr.w	Druk_Clearbuffer
	move.l	(DosBase-DT,a4),a6
	move.l	(2,sp),d1
	lea	(ParameterBlok-DT,a4),a0
	move.l	a0,d2
	jsr	(_LVOExNext,a6)
	tst	d0
	bne.b	C1884E
C18848:
	addq.l	#6,sp
	br	druk_cr_nl

C1884E:
	subq.w	#1,(ShowDir_NrLines-DT,a4)
	bne.b	C18874
	bsr	GETKEYNOPRINT
	cmp.b	#$1B,d0
	beq.b	C18848
	move	(ScreenHight-DT,a4),d0
	subq.w	#1,d0
	add.w	d0,d0
	move	d0,(ShowDir_NrLines-DT,a4)
C18874:
	subq.w	#1,(sp)
	bne	C187D6
	bsr	druk_cr_nl
	move	#2,(sp)			; 2cols
	br	C187D6

com_update:
	moveq	#~32,d0
	and.b	(a6),d0
	cmp.b	#'A',d0
	beq	C18904
	tst.b	(a6)
	beq.b	UpdateCurrBuffer
	jmp	(ERROR_IllegalComman)

UpdateCurrBuffer:
	btst	#0,(PR_UpdateAlways).l
	beq.b	C188B2
C188AA:
	btst	#SB1_SOURCE_CHANGED,(SomeBits-DT,a4)
	beq.b	C188FA
C188B2:
	clr.l	(FileLength-DT,a4)
	tst.b	(LastFileNaam-DT,a4)
	beq	Com_WriteSource
	lea	(CurrentAsmLine-DT,a4),a0
	lea	(LastFileNaam-DT,a4),a1
	movem.l	a0/a1,-(sp)
.lopje:
	move.b	(a1)+,(a0)+
	tst.b	(a1)
	bne.b	.lopje

	lea	 (.Backup,pc),a1
.Append	move.b	(a1)+,(a0)+	;filename.s.BACKUP
	bne.b	.Append
	subq.l	#.BackupEnd-.Backup,a0

	movem.l	(sp)+,d1/d2	;oldfilename/newfilename

	tst.b	(PR_AutoBackup).l
	beq.s	.noBackup
	move.l	a0,-(sp)

	move.l	(DosBase-DT,a4),a6

	movem.l	d1/d2,-(sp)
	jsr	_LVODeleteFile(a6)
	movem.l	(sp)+,d1/d2
	exg	d1,d2
	jsr	_LVORename(a6)
	move.l	(sp)+,a0
.noBackup:
	clr.b	(a0)		;filename without .BACKUP

	lea	(Updating.MSG,pc),a0
	bsr	printthetext
	lea	(CurrentAsmLine-DT,a4),a0
	bsr	printthetext
	bsr	druk_cr_nl
	bsr.w	Druk_Clearbuffer

	bsr	OPENFILE_NOASK
	br	WRITE_DOIT

.Backup	DC.B	".BACKUP",0
.BackupEnd
	EVEN

C188FA:
	lea	(Sourcenotchan.MSG,pc),a0
	bra	printthetext

C18904:		; com_update_project
	tst.l	(EditorRegs+(8+2)*4-DT,a4)	; reg a2
	beq.b	C18988
	st	(FromCmdLine-DT,a4)
	moveq	#0,d0
	move.b	(CurrentSource-DT,a4),-(sp)
	moveq	#9,d7
C1891C:
	move.b	#9,(Change2Source-DT,a4)
	sub.b	d7,(Change2Source-DT,a4)
	move	d7,-(sp)
	jsr	(Go2Sourcenow_SetCtx)
	bsr	C188AA		; UpdateCurrBuffer if changed
	move	(sp)+,d7
	dbra	d7,C1891C
	lea	(ProjectName-DT,a4),a0
	lea	(CurrentAsmLine-DT,a4),a1
C1894E:
	move.b	(a0)+,(a1)+
	bne.b	C1894E
	tst.b	(CurrentAsmLine-DT,a4)
	beq.b	C18976
	clr.l	(FileLength-DT,a4)
	move.b	(Safety-DT,a4),-(sp)
	st	(Safety-DT,a4)
	bsr	com_write_env_noreq
	move.b	(sp)+,(Safety-DT,a4)
C18976:
	move.b	(sp)+,(Change2Source-DT,a4)
	jsr	(Go2Sourcenow_SetCtx)
	sf	(FromCmdLine-DT,a4)
C18988:
	rts

com_write:
	clr.l	(FileLength-DT,a4)
	move.b	(a6),d0
	move.b	d0,d3
	bclr	#5,d0
	cmp.b	#'T',d0
	beq	C1705C
	cmp.b	#'X',d0
	beq	Com_WriteObjectExt
	cmp.b	#'O',d0
	beq	Com_WriteObject
	cmp.b	#'S',d0
	beq	C17048
	cmp.b	#'B',d0
	beq	Com_WriteBin
	cmp.b	#'P',d0
	beq	Write_Prefs
	cmp.b	#'L',d0
	beq	Write_Link
	cmp.b	#'E',d0
	beq	com_write_env
	cmp.b	#'N',d0
	beq.b	Com_WriteNormal
	cmp.b	#' ',d3
	beq	C18A68
	tst.b	(a6)
	beq.b	Com_WriteSource
	jmp	(ERROR_IllegalComman).l

Com_WriteNormal:
	moveq	#15,d0
	bsr	FileReqStuff
	move.w	PR_SaveMarks,-(sp)
	bclr	#0,(PR_SaveMarks).l
	bsr.b	C189E6
	move.w	(sp)+,PR_SaveMarks
	rts

Com_WriteSource:
	moveq	#1,d0
	bsr	FileReqStuff
C189E6:
	bsr	IO_OpenFile
WRITE_DOIT:
	bsr	RESETMENUTEXT2
	bsr	C17B9E
	bsr	C17C04
	bsr.b	C18A2A
	move.l	(sourcestart-DT,a4),a0
C189FC:
	lea	(ParameterBlok-DT,a4),a1
	move.l	a1,d2
	move.w	#USERPRG_STACK_SIZE*2-1,d1
	moveq	#0,d3
C18A0A:
	move.b	(a0)+,d0
	bne.b	C18A12
	moveq	#10,d0
C18A12:
	cmp.b	#SRCMARK_END,d0
	beq.b	C18A84
	addq.l	#1,d3
	move.b	d0,(a1)+
	dbra	d1,C18A0A
	move.l	a0,-(sp)
	bsr	IO_WriteFile
	move.l	(sp)+,a0
	bra.b	C189FC

C18A2A:
	btst	#0,(PR_SaveMarks).l
	beq.b	.DontSaveMarks
;XXX
	lea	(ParameterBlok-DT,a4),a1
	move.l	a1,d2
	moveq	#85,d3
;	move.l	#$F9FAF9FA,(a1)+
	move.l	#";APS",(a1)+		;) Asm-Pro savemarks
	move.l	(sourcestart-DT,a4),d1
	movem.l	d0-d7/a0,-(sp)
	lea	(EditMarks10-DT,a4),a0
	moveq	#10-1,d7
.lopje:
	move.l	(a0)+,d0
	beq.b	.zero
	sub.l	d1,d0		;offset
.zero:
	movem.l	d1/d7,-(sp)
	bsr	van_d0_2_string
	movem.l	(sp)+,d1/d7
	dbra	d7,.lopje

	move.b	#10,(a1)+

	movem.l	(sp)+,d0-d7/a0
	bsr	IO_WriteFile
.DontSaveMarks:
	rts

C18A68:
	bsr	C180C4
	tst.b	(PR_SourceExt).l
	beq.b	.noextention
	move.b	#'.',(a0)+
	move.b	#'s',(a0)+
	clr.b	(a0)+
.noextention:
	bsr	C180E8
	br	C189E6

C18A84:
	bsr	IO_WriteFile
	bsr	close_bestand
	lea	(CurrentAsmLine-DT,a4),a3
	bsr.w	AddRecentFile
	bclr	#SB1_SOURCE_CHANGED,(SomeBits-DT,a4)
	rts

com_write_env:
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(ASK_CHECK_ALL_IF_SAVED)
	movem.l	(sp)+,d0-d7/a0-a6
	cmp.b	#' ',(1,a6)
	beq	C18C3E
	moveq	#13,d0
	bsr	FileReqStuff
com_write_env_noreq:
	movem.l	d0-d7/a0-a6,-(sp)
	movem.l	a0-a2,-(sp)
	lea	(TempDirName-DT,a4),a0
	lea	(ProjectName-DT,a4),a2
	lea	(CurrentAsmLine-DT,a4),a1
C18AC6:
	move.b	(a1),(a0)+
	move.b	(a1)+,(a2)+
	tst.b	(a1)
	bne.b	C18AC6
	lea	(Aprj.MSG,pc),a1
	moveq	#-4,d1
C18AD4:
	moveq	#~32,d0
	and.b	(a0,d1.w),d0
	moveq	#~32,d2
	and.b	(a1)+,d2
	cmp.b	d2,d0
	bne.b	C18AEE
	addq.w	#1,d1
	bne.b	C18AD4
	bra.b	C18B16

C18AEE:
	lea	(DotAprj.MSG,pc),a1
.CopyExt
	move.b	(a1),(a0)+
	move.b	(a1)+,(a2)+
	bne.b	.CopyExt
C18B16:
	clr.b	(a0)
	clr.b	(a2)
	movem.l	(sp)+,a0-a2

	movem.l	a0/a1,-(sp)
	lea	(TempDirName-DT,a4),a1
	lea	(CurrentAsmLine-DT,a4),a0
C18B2A:
	move.b	(a1)+,(a0)+
	bne.b	C18B2A
	movem.l	(sp)+,a0/a1
	clr.l	(FileLength-DT,a4)
	bsr	IO_OpenFile
	lea	(PrevDirnames-DT,a4),a0
	move.l	a0,d2
	move.l	#128,d3
	bsr	IO_WriteFile
	lea	(CurrentSource-DT,a4),a0
	move.l	a0,d2
	moveq	#2,d3
	bsr	IO_WriteFile
	lea	(LastFileNaam-DT,a4),a0
	move.l	a0,d2
	move.l	#CS_size,d3
	bsr	IO_WriteFile

	moveq	#10-1,d7
	lea	(SourcePtrs-DT,a4),a0

C18B76:
	move.l	d7,-(sp)
	move.l	a0,-(sp)
	moveq	#CS_filename,d2
	add.l	a0,d2
	moveq	#31,d3		; max. filename length
	bsr	IO_WriteFile
	move.l	(sp),a0
	move.l	(CS_FirstLinePtr,a0),d2
	beq.b	.C18B9C
	sub.l	(sourcestart-DT,a4),d2
.C18B9C:
	move.l	d2,-(sp)
	move.l	sp,d2
	moveq	#4,d3
	bsr	IO_WriteFile
	addq.l	#4,sp

	moveq	#CS_FirstlineNr+2,d2	;fake for project file
	add.l	(sp),d2
	moveq	#2,d3
	bsr	IO_WriteFile

	moveq	#CS_FirstLineOffset+2,d2	;fake also
	add.l	(sp),d2
	moveq	#2,d3
	bsr	IO_WriteFile

	moveq	#CS_SomeBits,d2
	add.l	(sp),d2
	moveq	#2,d3
	bsr	IO_WriteFile

	move.w	#CS_marks,a0
	add.l	(sp),a0
	lea	(TempDirName-DT,a4),a1
	move.l	a1,d2
	move.l	(sourcestart-DT,a4),d0
	moveq	#10-1,d1
.RelocMarks
	move.l	(a0)+,(a1)+
	beq.b	.NextMark
	sub.l	d0,(-4,a1)		; abs to rel
.NextMark
	dbf	d1,.RelocMarks
	moveq	#10*4,d3
	bsr	IO_WriteFile

	moveq	#CS_update,d2
	add.l	(sp),d2
	move.l	#128,d3
	bsr	IO_WriteFile

	move.l	#CS_AsmStatus,d2
	add.l	(sp),d2
	moveq	#2,d3
	bsr	IO_WriteFile

	move.l	(sp)+,a0
	move.l	(sp)+,d7
	lea	(CS_size,a0),a0
	dbra	d7,C18B76
	move.l	#"APRJ",-(sp)
	move.l	sp,d2
	moveq	#4,d3
	bsr	IO_WriteFile
	addq.l	#4,sp
	bsr	close_bestand
	movem.l	(sp)+,d0-d7/a0-a6
	rts

C18C3E:
	addq.l	#1,a6
	bsr	C180C4
	br	com_write_env_noreq

DotAprj.MSG:
	dc.b	'.'
Aprj.MSG:
	dc.b	'Aprj',0
	EVEN

Com_WriteBin:
	cmp.b	#' ',(1,a6)
	beq.b	C18CB6
	moveq	#3,d0
	bsr	FileReqStuff
C18C5C:
	movem.l	a0/a1,-(sp)
	lea	(TempDirName-DT,a4),a0
	lea	(CurrentAsmLine-DT,a4),a1
C18C68:
	move.b	(a1)+,(a0)+
	tst.b	(a1)
	bne.b	C18C68
	clr.b	(a0)
	movem.l	(sp)+,a0/a1
	bsr	INPUTBEGINEND
	movem.l	d2/d3,-(sp)
	movem.l	a0/a1,-(sp)
	lea	(TempDirName-DT,a4),a1
	lea	(CurrentAsmLine-DT,a4),a0
C18C8A:
	move.b	(a1)+,(a0)+
	tst.b	(a1)
	bne.b	C18C8A
	clr.b	(a0)
	movem.l	(sp)+,a0/a1
	movem.l	(sp)+,d2/d3
C18C9A:
	movem.l	d2/d3,(TempDirName-DT,a4)
	bsr	IO_OpenFile
	movem.l	(TempDirName-DT,a4),d2/d3
	bsr	IO_WriteFile
	br	close_bestand

C18CB6:
	addq.l	#1,a6
	bsr	C180C4
	bra.b	C18C5C

Write_Prefs:
	moveq	#10,d2
	moveq	#'|',d3
	lea	(Gave_prefs_table).l,a0
	lea	(ParameterBlok-DT,a4),a1
.lopje
	move.w	(a0)+,d1
	beq.b	WP_Next
	moveq	#'-',d0
	btst	#0,(-2,a0,d1.w)
	beq.b	.wp_minus
	moveq	#'+',d0
.wp_minus
	move.b	d0,(a1)+	;bv. "+RD"
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	d2,(a1)+	;volgende regel
	bra.b	.lopje

WP_Next:
	move.b	#'!',(a1)+
	lea	(UserSrcExt.MSG).l,a0
.lopje:
	move.b	(a0)+,(a1)+
	bne.b	.lopje

	move.b	d2,(-1,a1)
	lea	(HomeDirectory-DT,a4),a0
	tst.b	(a0)
	beq.b	C18D10
	move.b	#'*',(a1)+
C18D06:
	move.b	(a0)+,(a1)+
	tst.b	(a0)
	bne.b	C18D06
	move.b	d2,(a1)+
C18D10:
	lea	(ScrColors-DT,a4),a0
	moveq	#16-1,d7
C18D16:
	move.b	d3,(a1)+
	moveq	#3-1,d6
C18D1C:
	move	(a0)+,d0
	cmp.b	d2,d0
	blt.b	C18D2A
	addq.b	#7,d0
C18D2A:
	add.b	#'0',d0
	move.b	d0,(a1)+
	dbra	d6,C18D1C
	dbra	d7,C18D16

	move.b	d3,(a1)+
	move.b	d2,(a1)+

	lea	(.CpuMmu,pc),a0
	move	(CPU_type-DT,a4),d0
	bsr.b	.StoreCpuMmu
	move	(MMU_type-DT,a4),d0
	bsr.b	.StoreCpuMmu
	bra.b	.ScreenStuff

.StoreCpuMmu
	move.b	#'[',(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	add.b	#'0',d0
	move.b	d0,(a1)+
	move.b	d2,(a1)+
	rts

.CpuMmu	DC.B	'CPUMMU'
	EVEN

.ScreenStuff
	move.b	#'^',(a1)+
	lea	(SchermMode),a0
	move.l	(a0),d0
	bsr	van_d0_2_string
	move.b	d3,(a1)+
	move.l	(HoogteScherm-SchermMode,a0),d0
	bsr	van_d0_2_string
	move.b	d3,(a1)+
	move.l	(BreedteScherm-SchermMode,a0),d0
	bsr	van_d0_2_string
	move.b	d3,(a1)+
	move.w	(Scr_NrPlanes-DT,a4),d0
	bsr	addword2pf
	move.b	d2,(a1)+

;Memtype en size..
	move.b	#'@',(a1)+
	move.l	(_memtype-DT,a4),d0
	lea	memstuff2(pc),a0
	move.b	(a0,d0.w),(a1)+
	move.l	(_memamount-DT,a4),d0
	bsr.b	van_d0_2_string
	move.b	d2,(a1)+

;Editor font
	move.b	#'(',(a1)+
	lea	editfont_name,a0
	move.w	(EditorFontSize-editfont_name,a0),d0
.lopje:
	move.b	(a0)+,(a1)+
	bne.b	.lopje
	move.b	d3,(-1,a1)

	bsr	addword2pf
	move.b	d2,(a1)+

;Syntax Colors...
	move.b	#')',(a1)+
	lea	fontcolortab,a0
	moveq	#8-1,d6
.lopje2:
	move.l	(a0)+,d0
	bsr.b	van_d0_2_string
	move.b	d3,(a1)+
	dbf	d6,.lopje2

	move.b	d2,(a1)+

;Window font
	lea	(BootUpString-DT,a4),a0
	tst.b	(a0)
	beq.b	C18DC2
	cmp.b	#'\',(a0)
	beq.b	C18DB8
	move.b	#'\',(a1)+
C18DB8:
	tst.b	(a0)
	beq.b	C18DC0
	move.b	(a0)+,(a1)+
	bra.b	C18DB8

C18DC0:
	move.b	d2,(a1)+
C18DC2:
	lea	(ParameterBlok-DT,a4),a0
	move.l	a1,d3
	sub.l	a0,d3
	move.l	a0,d2
	tst.b	(HavePrefsFilename-DT,a4)
	bne.b	.C18DD6
	bsr	GetPrefsFilename
.C18DD6	movem.l	d2/d3,-(sp)
	bsr	IO_OpenFile
	movem.l	(sp)+,d2/d3
	bsr	IO_WriteFile
	br	close_bestand

van_d0_2_string:
	moveq	#8-1,d7
.C18DEC	rol.l	#4,d0
	moveq	#15,d1
	and.b	d0,d1
	cmp.b	#10,d1
	blt.b	.C18E00
	addq.b	#7,d1
.C18E00	add.b	#'0',d1
	move.b	d1,(a1)+
	dbra	d7,.C18DEC

van_string_2_d1_done:
	rts

van_string_2_d1:
	moveq	#0,d0
.lopje	move.b	(a6)+,d0
	beq.b	van_string_2_d1_done
	cmp.b	#10,d0
	beq.b	van_string_2_d1_done
	cmp.b	#'|',d0
	beq.b	van_string_2_d1_done
	sub.b	#'0',d0
	cmp.b	#10,d0
	blt.b	.dec
	subq.b	#'A'-'9'-1,d0
.dec	lsl.l	#4,d1
	add.l	d0,d1
	bra.b	.lopje

addword2pf:
	swap	d0
	clr.w	d0
	moveq	#4-1,d7
.Clopje:
	rol.l	#4,d0
	cmp.w	#10,d0
	blo.s	.nohex
	addq.w	#7,d0
.nohex:
	add.w	#'0',d0
	move.b	d0,(a1)+
	clr.w	d0
	dbf	d7,.Clopje
	rts

getwordfrompf:
	moveq	#0,d0
	moveq	#4-1,d7
.lopje:
	moveq	#0,d1
	move.b	(a6)+,d1
	sub.b	#'0',d1
	cmp.b	#10,d1
	blo.s	.klaar
	subq.b	#7,d1
.klaar:
	lsl.w	#4,d0
	add.b	d1,d0
	dbf	d7,.lopje
	rts

;************* PREFS INLADEN **************

Read_Prefs:
	bsr	GetPrefsFilename
Read_Prefs2:
	move.w	#2,(Scr_NrPlanes-DT,a4)		;default= 2 planes

	lea	(CurrentAsmLine-DT,a4),a0
	move.l	a0,d1
	move.l	#MODE_OLDFILE,d2
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOOpen,a6)
	move.l	d0,(Bestand-DT,a4)
	beq.b	C18E68
	lea	(ParameterBlok-DT,a4),a0
	move.l	a0,d2
	move.l	#USERPRG_STACK_SIZE*2,d3
	move.l	(Bestand-DT,a4),d1
	jsr	(_LVORead,a6)
	lea	(ParameterBlok-DT,a4),a0
	clr.b	(a0,d0.l)
	move.l	(Bestand-DT,a4),d1
	jsr	(_LVOClose,a6)
	lea	(ParameterBlok-DT,a4),a6
	cmp.b	#$2D,(a6)	;-
	beq.b	C18E6E
	cmp.b	#$2B,(a6)	;+
	beq.b	C18E6E
C18E68:
	lea	(Prefs_File_Stuff).l,a6
C18E6E:
	lea	(Gave_prefs_table).l,a5
	bsr	C190D2
	tst.b	(Safety-DT,a4)
	beq.b	C18E86
C18E7E:
	cmp.b	#10,(a6)+
	bne.b	C18E7E
	bra.b	CheckForColors

C18E86:
	move.l	#"SYS:",(PrevDirnames-DT,a4)
	cmp.b	#"*",(a6)
	bne.b	CheckForColors
	addq.l	#1,a6
	lea	(HomeDirectory-DT,a4),a0
	lea	(PrevDirnames-DT,a4),a1
C18E9E:
	move.b	(a6),(a0)+
	move.b	(a6)+,(a1)+
	cmp.b	#10,(a6)
	beq.b	C18EAE
	tst.b	(a6)
	beq.b	C18EAE
	bra.b	C18E9E


initmydirs:
	movem.l	d0/d1/a0/a1,-(sp)
	lea	(DIR_ARRAY-DT,a4),a1
	moveq	#11-1,d1
.lopje:
	lea	(HomeDirectory-DT,a4),a0
	moveq	#DSIZE-1,d0
.lopje2:
	move.b	(a0)+,(a1)+
	dbf	d0,.lopje2
	dbf	d1,.lopje
	movem.l	(sp)+,d0/d1/a0/a1
	rts

C18EAE:
	clr.b	(a0)
	clr.b	(a1)
	bsr.b	initmydirs
	addq.w	#1,a6
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	a0,d7
	move.l	(DosBase-DT,a4),a6
	lea	(HomeDirectory-DT,a4),a0
	move.l	a0,d1
	moveq	#ACCESS_READ,d2
	jsr	(_LVOLock,a6)
	move.l	d0,d1
	beq.b	C18EE6
	jsr	(_LVOCurrentDir,a6)
	st	(HomeDirSet-DT,a4)
	move.l	d7,a0
	sf	(a0)+
	st	(a0)
C18EE6:
	movem.l	(sp)+,d0-d7/a0-a6

;|8AB|002|FFF|B40|000|000|000|000|000|000|000|000|000|000|000|F06|
CheckForColors:
	cmp.b	#"|",(a6)	;load colors
	bne.b	C18F4A

	lea	(ScrColors-DT,a4),a0
	addq.w	#1,a6
	moveq	#0,d0
	moveq	#16-1,d7	;16 kleurtjes..
C18EF8:
	moveq	#2,d6
C18EFA:
	move.b	(a6)+,d0
	cmp.b	#'\',d0
	bne.b	.C18F06
	subq.w	#1,a6
	bra.b	C18F4A

.C18F06	cmp.b	#'0',d0
	blt.b	C18F4A
	cmp.b	#'9',d0
	ble.b	.C18F2A
	bclr	#5,d0
	cmp.b	#'A',d0
	blt.b	C18F4A
	cmp.b	#'F',d0
	bgt.b	C18F4A

	subq.b	#'A'-10-'0',d0
.C18F2A	sub.b	#'0',d0
	move.w	d0,(a0)+
	dbra	d6,C18EFA
	cmp.b	#'|',(a6)
	bne.b	C18F4A
	addq.w	#1,a6
	dbra	d7,C18EF8
	move.b	#2,(PaletteStatus-DT,a4)	; have loaded palette (prefs file)
C18F4A:
	cmp.b	#10,(a6)
	bne.b	.C18F52
	addq.w	#1,a6

.C18F52	cmp.b	#'[',(a6)
	bne.b	CheckForScreenmode
	moveq	#0,d0
	addq.w	#1,a6
	cmp.b	#'C',(a6)
	bne.b	.C18F72
	addq.w	#3,a6
	move.b	(a6)+,d0
	sub.b	#'0',d0
	move	d0,(CPU_type-DT,a4)
	addq.w	#1,a6
	bra.b	C18F4A

.C18F72	cmp.b	#'M',(a6)
	bne.b	CheckForScreenmode
	addq.w	#3,a6
	move.b	(a6)+,d0
	sub.b	#'0',d0
	move	d0,(MMU_type-DT,a4)
	addq.w	#1,a6
	bra.b	C18F4A

;^40C20032|00000200|00000280|0002
CheckForScreenmode:
;	move.l	#-1,SchermMode
	cmp.b	#'^',(a6)
	bne.b	checkformem

	addq.w	#1,a6
	moveq	#0,d1

	bsr	RP_Ascii2Long

	ror.l	#4,d1
	move.l	d1,(SchermMode).l
	cmp.b	#'|',d0		;'|'
	bne.b	checkformem
	moveq	#0,d1

	bsr	RP_Ascii2Long
C19014:
	ror.l	#4,d1
	move.l	d1,Scrhoog_1
	move.l	d1,(HoogteScherm).l
	cmp.b	#'|',d0
	bne.b	checkformem
	moveq	#0,d1

	bsr	RP_Ascii2Long

	ror.l	#4,d1
	move.l	d1,(BreedteScherm).l
	move.l	d1,ScrBr_1

	cmp.b	#'|',d0
	bne.b	checkformem
	moveq	#0,d1

	bsr	getwordfrompf
	cmp.w	#4,d0		; max screen depth
	bhi.b	.DfltDepth
	move.w	d0,(Scr_NrPlanes-DT,a4)
.DfltDepth
	addq.l	#1,a6

checkformem:
;.lopje:
;	btst	#6,$bfe001		; :))
;	beq.s	.leave
;	cmp.w	#4,(Scr_NrPlanes-DT,a4)
;	bhi.s	.lopje
;.leave:
;	jsr	test_debug

memtypeensize:
	moveq	#MEMB_CHIP+1,d0		;250 kb chipmem
	move.l	#250,(_memamount-DT,a4)
	move.l	#$60000,(_absmemadr-DT,a4)

	cmp.b	#'@',(a6)
	bne.b	.geenmem
	move.b	(1,a6),d1
	cmp.b	#'C',d1
	bne.s	.geenchip
	moveq	#MEMB_CHIP+1,d0
.geenchip:
	cmp.b	#'F',d1
	bne.s	.geenfast
	moveq	#MEMB_FAST+1,d0
.geenfast:
	cmp.b	#'P',d1
	bne.s	.geenpub
	moveq	#MEMB_PUBLIC+1,d0
.geenpub:
	cmp.b	#'A',d1
	bne.s	.geenabs
	moveq	#0,d0
.geenabs:
	move.l	d0,(_memtype-DT,a4)

	addq.l	#2,a6
	moveq	#0,d1
	bsr	van_string_2_d1
	move.l	d1,(_memamount-DT,a4)

.geenmem:
	cmp.b	#'(',(a6)
	bne.s	geeneditfont

	addq.l	#1,a6
	lea	editfont_name,a0
.lopje2:
	cmp.b	#'|',(a6)
	beq.s	.klaar
	move.b	(a6)+,(a0)+
	bra.b	.lopje2
.klaar:
	clr.b	(a0)+
	addq.l	#1,a6
	bsr	getwordfrompf
	move.w	d0,EditorFontSize
	addq.l	#1,a6

geeneditfont:

	cmp.b	#')',(a6)
	bne.s	.geensyntcols

	addq.l	#1,a6
	lea	fontcolortab,a0
	moveq	#8-1,d6
.lopje3:
	bsr	van_string_2_d1
	move.l	d1,(a0)+
	dbf	d6,.lopje3
	addq.l	#1,a6

.geensyntcols:


checkforbootup:
	cmp.b	#'\',(a6)+
	bne.b	C190AA
	move.l	a6,-(sp)
	lea	(BootUpString-DT,a4),a0
	move.b	#'\',(a0)+
C19092:
	cmp.b	#10,(a6)
	beq.b	C190A0
	tst.b	(a6)
	beq.b	C190A0
	move.b	(a6)+,(a0)+
	bra.b	C19092

C190A0:
	move.l	(sp)+,a6
	move.l	a6,a0
	jsr	(DATAFROMAUTO).l

C190AA:
	tst.b	(Safety-DT,a4)
	bne.b	C190C4
	tst.b	(HomeDirSet-DT,a4)
	bne.b	C190C4
	move.l	(DosBase-DT,a4),a6
	move.l	(CurrentDir-DT,a4),d1
	jmp	(_LVOCurrentDir,a6)

C190C4:
C1905C:
	rts

RP_Ascii2Long:
	moveq	#0,d0
	move.b	(a6)+,d0
	beq.b	C1905C
	cmp.b	#10,d0
	beq.b	C1905C
	cmp.b	#'|',d0
	beq.b	C1905C
	sub.b	#'0',d0
	cmp.b	#9,d0
	ble.b	.C19052
	subq.b	#7,d0
.C19052:
	and.b	#15,d0
	add.l	d0,d1
	rol.l	#4,d1
	bra.b	RP_Ascii2Long

;************* EINDE PREFS INLADEN **************

C190D2:
	move.b	(a6)+,d0
	cmp.b	#$20,d0
	beq.b	C190D2
	cmp.b	#9,d0
	beq.b	C190D2
	pea	(C190D2,pc)
	cmp.b	#$2B,d0
	beq.b	C19126
	cmp.b	#$2D,d0
	beq.b	C1912E
	cmp.b	#'!',d0
	beq.b	change_extention
	cmp.b	#10,d0
	beq.b	C190D2
	cmp.b	#13,d0
	beq.b	C190D2
	subq.w	#1,a6
	addq.l	#4,sp
	rts

change_extention:
	lea	(UserSrcExt.MSG).l,a0
	moveq	#16-1,d1
C19110:
	move.b	(a6)+,d0
	cmp.b	#' ',d0
	bls.b	C19120
	move.b	d0,(a0)+
	dbra	d1,C19110

	addq.w	#1,a6
C19120:
	clr.b	(a0)+
	subq.w	#1,a6
	rts

C19126:
	bsr.b	C19136
	bset	#0,(a1)
	rts

C1912E:
	bsr.b	C19136
	bclr	#0,(a1)
	rts

C19136:
	bsr.b	C1914C
	lsl.w	#8,d0
	bsr.b	C1914C
	move.l	a5,a1
C1913E:
	tst	(a1)+
	beq.b	C19160
	cmp	(a1)+,d0
	bne.b	C1913E
	subq.w	#4,a1
	add	(a1),a1
	rts

C1914C:
	move.b	(a6)+,d0
	beq.b	C1915C
	cmp.b	#$61,d0
	bcs.b	C1915A
	bclr	#5,d0
C1915A:
	rts

C1915C:
	subq.l	#1,a6
	addq.l	#8,sp
C19160:
	addq.l	#4,sp
	rts

GetPrefsFilename:
	lea	(CurrentAsmLine-DT,a4),a0
	lea	(ENVARCAsmProPref.MSG-DT,a4),a1
.C1916E	move.b	(a1)+,(a0)+
	bne.b	.C1916E
	clr.b	(a0)
	rts

Write_Link:
	move.l	a6,-(sp)
	bsr	OBJ_REMOVE_UNUSED_SECTIONS
	move.l	(sp)+,a6
	cmp.b	#' ',(1,a6)
	beq.b	C191D2
	moveq	#6,d0
	bsr	FileReqStuff
C1918C:
	bsr	IO_OpenFile
	move.l	(RelocStart-DT,a4),a0
	cmp.l	#$12345678,-(a0)
	beq.b	C191A2

_ERROR_NoObject:
	jmp	(ERROR_NoObject).l

C191A2:
	clr.l	(a0)
	bsr	LINK_SORT_RELO_AREA
	bsr	OBJ_RELOC_ALL_HUNKS
	moveq	#0,d0
	move	(NrOfSections-DT,a4),d0
	beq.b	_ERROR_NoObject
	bsr.b	LINK_WRITE_HUNK_UNIT
	bsr.b	LINK_WRITE_ALL_HUNKS
	bsr	close_bestand
	bsr	OBJ_DERELOC_ALL_HUNKS
	move.l	(RelocStart-DT,a4),a0
	move.l	#$12345678,-(a0)
	rts

C191D2:
	addq.l	#1,a6
	bsr	C180C4
	bra.b	C1918C

LINK_WRITE_HUNK_UNIT:
	lea	(IDNT_STRING-DT,a4),a0
	move.l	a0,d2
C191E0:
	tst.b	(a0)+
	bne.b	C191E0
	clr.b	(a0)+
	clr.b	(a0)+
	move.l	a0,d3
	sub.l	d2,d3
	lsr.l	#2,d3
	movem.l	d2/d3,-(sp)
	move.l	d3,-(sp)
	move.l	#$000003e7,-(sp)	; unit
	move.l	sp,d2
	moveq	#8,d3
	bsr	IO_WriteFile
	addq.l	#8,sp
	movem.l	(sp)+,d2/d3
	lsl.l	#2,d3
	br	IO_WriteFile

LINK_WRITE_ALL_HUNKS:
	sf	(StripTrailingZeroes-DT,a4)
	lea	(Writinghunkda.MSG,pc),a0
	bsr	beeldtextaf
	lea	SECTION_ABS_LOCATION-DT+4(a4),a0
	lea	SECTION_ORG_ADDRESS-DT+4(a4),a1
	lea	SECTION_TYPE_TABLE-DT+1(a4),a2
	move.l	(RelocStart-DT,a4),a3
	move.l	(RelocEnd-DT,a4),a5
	moveq	#0,d6
.Loop
	addq.w	#1,d6
	bsr	C19428
	bsr	OBJ_WRITE_HUNK_TYPE_HEADER
	move.l	a3,-(sp)
	tst.b	(a2)
	bmi.b	.IsBss
	bsr	OBJ_WRITE_BODY_DATA
	bsr	OBJ_WRITE_RELOCATION
.IsBss
	moveq	#HUNK_EXTERN-HUNK_LIST,d2
	bsr.b	LINK_WRITE_4B
	cmp	#1,d6
	bne.b	.C1926E
	moveq	#0,d6
	bsr	LINK_WRITE_XDEFS
	moveq	#1,d6
.C1926E
	bsr	LINK_WRITE_XDEFS
	move.l	(sp)+,a6
	bsr.b	LINK_WRITE_XREFS
	moveq	#HUNK_EXTERN_END-HUNK_LIST,d2
	bsr.b	LINK_WRITE_4B
	moveq	#HUNK_END-HUNK_LIST,d2
	bsr.b	LINK_WRITE_4B
	addq.l	#4,a0
	addq.l	#4,a1
	addq.l	#1,a2
	cmp	(NrOfSections-DT,a4),d6
	bne.b	.Loop
	rts

LINK_WRITE_4B:
	add.l	#HUNK_LIST,d2
	movem.l	a0/a1,-(sp)
	moveq	#4,d3
	bsr	IO_WriteFile
	movem.l	(sp)+,a0/a1
	rts

LINK_WRITE_XREFS:
	movem.l	a0/a1/a3,-(sp)
	move.l	a6,a3
C192B2:
	cmp.l	a3,a5
	beq.b	C1936C
	cmp.b	(a3),d6
	bne.b	C1936C
	tst.b	(1,a3)
	bne.b	C1936C
	moveq	#~3,d0
	and.l	(2,a3),d0
	move.l	d0,a1
	lea	(SourceCode-DT,a4),a0
	move	(a1)+,(a0)+
	addq.w	#8,a1
C192D6:
	move	(a1)+,(a0)+
	bpl.b	C192D6
	lea	(SourceCode-DT,a4),a0
	bsr	C193EA
	moveq	#3,d0
	and.l	(2,a3),d0
	move.b	(B19372,pc,d0.w),d0
	ror.l	#8,d0
	or.l	d3,d0
	movem.l	d2/d3,-(sp)
	bsr.b	LINK_WRITE_D0
	movem.l	(sp)+,d2/d3
	lsl.l	#2,d3
	bsr	IO_WriteFile
	move.l	a3,-(sp)
	moveq	#1,d0
	move.l	(2,a3),d1
	add	#10,a3
C1931C:
	cmp.l	a3,a5
	beq.b	C19338
	cmp.b	(a3),d6
	bne.b	C19338
	tst.b	(1,a3)
	bne.b	C19338
	cmp.l	(2,a3),d1
	bne.b	C19338
	add	#10,a3
	addq.w	#1,d0
	bra.b	C1931C

C1936C:
	movem.l	(sp)+,a0/a1/a3
	rts

C19338:
	bsr.b	LINK_WRITE_D0
	move.l	(sp)+,a6
C1934C:
	addq.w	#6,a6
	move.l	d0,-(sp)
	move.l	(a6)+,d0
	move.l	a6,-(sp)
	bsr.b	LINK_WRITE_D0
	move.l	(sp)+,a6
	move.l	(sp)+,d0
	subq.l	#1,d0
	bne.b	C1934C
	br	C192B2

B19372:	dc.b	$84,$83,$81,0

LINK_WRITE_D0:
	move.l	d0,-(sp)
	move.l	sp,d2
	moveq	#4,d3
	bsr	IO_WriteFile
	move.l	(sp)+,d0
	rts

LINK_WRITE_XDEFS:	; RECURSIVE (C19386)!
	movem.l	d6/a0-a3/a5,-(sp)
	lea	(XDefTreePtr-DT,a4),a2
	bsr.b	C19386
	movem.l	(sp)+,d6/a0-a3/a5
	rts

C19386:
	move.l	(a2),d0
	beq.b	C193E4
	move.l	a2,-(sp)
	move.l	d0,a2
	bsr.b	C19386
	addq.w	#4,a2
	move.l	a2,a3
	addq.w	#4,a2
	move.l	a2,a0
C19398:
	tst	(a2)+
	bpl.b	C19398
	cmp	(a2)+,d6
	bne.b	C193DE
	bsr.b	C193EA
	movem.l	d2/d3,-(sp)
	move.l	#$01000000,d0
	tst	d6
	bne.b	.C193B6
	add.l	d0,d0		; $02000000
.C193B6
	or.l	d3,d0
	bsr.b	LINK_WRITE_D0
	movem.l	(sp)+,d2/d3
	lsl.l	#2,d3
	bsr	IO_WriteFile
	move.l	(a2),d0
	bsr.b	LINK_WRITE_D0
C193DE:
	move.l	a3,a2
	bsr.b	C19386
	move.l	(sp)+,a2
C193E4:
	rts

C193EA:
	lea	(CurrentAsmLine-DT,a4),a1
	move.l	a1,d2
C193F0:
	move.b	(a0)+,d0
	bmi.b	C193F8
	bsr.b	C19414
	bra.b	C193F0

C193F8:
	and.b	#$7F,d0
	beq.b	C19406
	bsr.b	C19414
	move.b	(a0)+,d0
	beq.b	C19406
	bsr.b	C19414
C19406:
	clr.b	(a1)+
	clr.b	(a1)+
	clr.b	(a1)+
	move.l	a1,d3
	sub.l	d2,d3
	lsr.l	#2,d3
	rts

C19414:
	cmp.b	#$40,d0
	bne.b	C1941C
	moveq	#$2E,d0
C1941C:
	cmp.b	#$5B,d0
	bne.b	C19424
	moveq	#$5F,d0
C19424:
	move.b	d0,(a1)+
	rts

C19428:
	movem.l	d6/a0-a3/a5,-(sp)
	lea	(SectionTreePtr-DT,a4),a2
	bsr.b	C19438
	movem.l	(sp)+,d6/a0-a3/a5
	rts

C19438:
	move.l	(a2),d0
	beq.b	C19478
	move.l	a2,-(sp)
	move.l	d0,a2
	bsr.b	C19438
	addq.w	#4,a2
	move.l	a2,a3
	addq.w	#4,a2
	move.l	a2,a0
C1944A:
	tst	(a2)+
	bpl.b	C1944A
	cmp	(a2)+,d6
	bne.b	C19472
	bsr.b	C193EA
	movem.l	d2/d3,-(sp)
	move.l	d3,-(sp)
	move.l	#$000003e8,-(sp)	; name
	move.l	sp,d2
	moveq	#8,d3
	bsr	IO_WriteFile
	addq.l	#8,sp
	movem.l	(sp)+,d2/d3
	lsl.l	#2,d3
	bsr	IO_WriteFile
C19472:
	move.l	a3,a2
	bsr.b	C19438
	move.l	(sp)+,a2
C19478:
	rts

OBJ_WRITE_ALL_HUNKS:
	lea	(Writinghunkda.MSG,pc),a0
	bsr	beeldtextaf
	lea	SECTION_ABS_LOCATION-DT+4(a4),a0
	lea	SECTION_ORG_ADDRESS-DT+4(a4),a1
	lea	SECTION_TYPE_TABLE-DT+1(a4),a2
	move.l	(RelocStart-DT,a4),a3
	move.l	(RelocEnd-DT,a4),a5
	moveq	#0,d6
.Loop
	addq.w	#1,d6
	bsr.b	OBJ_WRITE_HUNK_TYPE_HEADER
	tst.b	(a2)
	bmi.b	.IsBss
	bsr.b	OBJ_WRITE_BODY_DATA
	bsr.w	OBJ_WRITE_RELOCATION
.IsBss
	moveq	#HUNK_END-HUNK_LIST,d2
	bsr	LINK_WRITE_4B
	addq.l	#4,a0
	addq.l	#4,a1
	addq.l	#1,a2
	cmp	(NrOfSections-DT,a4),d6
	bne.b	.Loop
	rts

OBJ_WRITE_HUNK_TYPE_HEADER:
	movem.l	a0/a1,-(sp)
	lea	(HUNK_CODE,pc),a0
	moveq	#$3c,d1
	and.b	(a2),d1
	add	d1,d1
	add	d1,a0

	move.l	(a1),d3				; length
	tst.b	(StripTrailingZeroes-DT,a4)
	beq.b	.NoStrip
	st	(StrippedHunkLength-DT,a4)	; mark as not stripped (negative length)
	cmp.w	#4*2,d1				; only want code and data hunks
	bhi.b	.NoStrip
	movem.l	a0/a1,-(sp)
	move.l	(8,sp),a0
	move.l	(a0),a0				; ptr
	move.l	(a1),a1				; length
	add.l	a0,a1				; end
.Strip
	cmp.l	a0,a1
	beq.b	.Stripped
	tst.b	-(a1)
	beq.b	.Strip
	addq.l	#1,a1
.Stripped
	move.l	a1,d3
	sub.l	a0,d3
	movem.l	(sp)+,a0/a1
	move.l	d3,(StrippedHunkLength-DT,a4)
.NoStrip
	addq.l	#3,d3

	lsr.l	#2,d3
	move.l	d3,(4,a0)
	move.l	a0,d2
	moveq	#8,d3
	bsr	IO_WriteFile
	movem.l	(sp)+,a0/a1
	rts

OBJ_WRITE_BODY_DATA:
	movem.l	a0/a1,-(sp)
	move.l	(a0),d2

	move.l	(a1),d3
	tst.b	(StripTrailingZeroes-DT,a4)
	beq.b	.NoStrip
	move.l	(StrippedHunkLength-DT,a4),d1	; stripped?
	bmi.b	.NoStrip
	move.l	d1,d3
.NoStrip
	addq.l	#3,d3

	moveq	#-4,d1
	and.l	d1,d3
	bsr	IO_WriteFile
	movem.l	(sp)+,a0/a1
	rts

; A3 - Reloptr
; A5 - Reloend
; D6 - Hunk Nb
OBJ_WRITE_RELOCATION:
	movem.l	a0/a1,-(sp)

;---  Any relocation at all  ---

.NEXT_XREF
	cmp.l	a3,a5
	beq.b	.REL_THEEND
	cmp.b	(a3),d6
	bne.b	.REL_THEEND

;---  Skip all XREFS  ---

	tst.b	(1,a3)
	bne.b	.NO_XREF
	lea	(6+4,a3),a3
	bra.b	.NEXT_XREF
.NO_XREF

;---  Write relo head  ---

	lea	(HUNK_RELOC32,pc),a0
	move.l	a0,d2
	moveq	#4,d3
	bsr	IO_WriteFile

;---  Check number of relos and write ---

.LOOP	move.l	a3,-(sp)
	moveq	#0,d5
	move	(a3),d1
.LOOP2	addq.l	#1,d5
	addq.w	#6,a3
	cmp.l	a5,a3
	beq.b	.REL_END2
	cmp	(a3),d1
	beq.b	.LOOP2
.REL_END2

	moveq	#0,d0
	move.b	d1,d0
	subq.l	#1,d0
	move.l	d0,-(sp)		; to what hunk
	move.l	d5,-(sp)		; how many relocs
	move.l	sp,d2
	moveq	#8,d3
	bsr	IO_WriteFile
	addq.l	#8,sp
	move.l	(sp)+,a3

;---  Write all offsets  ---

.LOOP3
	addq.w	#2,a3
	move.l	(a3)+,d0
	bsr	LINK_WRITE_D0
	subq.w	#1,d5
	bne.b	.LOOP3

;---  Check if end reached  ---

	cmp.l	a5,a3
	beq.b	.REL_END
	cmp.b	(a3),d6
	beq.b	.LOOP

;---  Write end mark  ---

.REL_END
	moveq	#0,d0
	bsr	LINK_WRITE_D0
.REL_THEEND
	movem.l	(sp)+,a0/a1
	rts

OBJ_REMOVE_UNUSED_SECTIONS:
	move.l	(RelocStart-DT,a4),a0
	cmp.l	#$12345678,-(a0)
	bne	_ERROR_NoObject

;---  Copy used ptrs to beginning  ---

	clr.l	(a0)
	lea	SECTION_ABS_LOCATION-DT+4(a4),a0
	lea	SECTION_ORG_ADDRESS-DT+4(a4),a1
	lea	SECTION_TYPE_TABLE-DT+1(a4),a2
	lea	SECTION_OLD_ORG_ADDRESS-DT+4(a4),a5
	lea	(SECTION_CONV_AREA-DT,a4),a3
	clr.b	(a3)+
	move	(NrOfSections-DT,a4),d0
	beq	_ERROR_NoObject

	subq.w	#1,d0
	moveq	#0,d6
	moveq	#0,d5
.C195CE
	move.l	(a1,d5.w),d2
	beq.b	.C19616

	clr.l	(a1,d5.w)
	move.l	d2,(a1,d6.w)
	move.l	(a0,d5.w),d1
	clr.l	(a0,d5.w)
	move.l	d1,(a0,d6.w)
	move.l	(a5,d5.w),d1
	clr.l	(a5,d5.w)
	move.l	d1,(a5,d6.w)
	move	d5,d1
	lsr.w	#2,d1
	move	d6,d2
	lsr.w	#2,d2
	move.b	(a2,d1.w),d3		; don't optimize these 3, it won't
	clr.b	(a2,d1.w)		;  work when d1 = d2
	move.b	d3,(a2,d2.w)
	addq.w	#1,d2
	addq.w	#4,d6
.C19616
	addq.w	#4,d5
	move.b	d2,(a3)+
	dbra	d0,.C195CE
	lsr.w	#2,d6
	move	d6,(NrOfSections-DT,a4)

;---  Re-arrange relocation area  ---

	move.l	(RelocStart-DT,a4),a0
	move.l	(RelocEnd-DT,a4),a1
	lea	(SECTION_CONV_AREA-DT,a4),a2
	moveq	#0,d0
.LOOP2	cmp.l	a0,a1
	beq.b	.THEEND1
	move.b	(a0),d0
	move.b	(a2,d0.w),(a0)+
	beq.b	.ERROR
	move.b	(a0),d0
	beq.b	.NO_ADD
	move.b	(a2,d0.w),(a0)+
	beq.b	.ERROR
	addq.l	#4,a0
	bra.b	.LOOP2
.NO_ADD	lea	(9,a0),a0
	bra.b	.LOOP2

.ERROR	jmp	(ERROR_Relocationmade)

.THEEND1
	bsr.b	OBJ_RENUMBER_HUNKS
	bsr.b	OBJ_RENUMBER_VARS
	move.l	(RelocStart-DT,a4),a0
	move.l	#$12345678,-(a0)
	rts

;---  Re-number hunk names

OBJ_RENUMBER_HUNKS:
	lea	(SECTION_CONV_AREA-DT,a4),a1
	lea	(SectionTreePtr-DT,a4),a2
.CHECK_IF_OK
	move.l	(a2),d0
	beq.b	.THEEND2
	move.l	a2,-(sp)
	move.l	d0,a2
	bsr.b	.CHECK_IF_OK
	addq.w	#4,a2
	bsr.b	.CHECK_IF_OK
	addq.w	#4,a2
.LOOP3	tst.w	(a2)+
	bpl.b	.LOOP3
	move.w	(a2),d0
	move.b	(a1,d0.w),d0
	move.w	d0,(a2)+
	move.l	(sp)+,a2
.THEEND2
	rts

;---  Re-number variables  ---

OBJ_RENUMBER_VARS:
	lea	(SECTION_CONV_AREA-DT,a4),a1
	move.l	(LabelStart-DT,a4),a2
	moveq	#'@',d5
.XLOOP2
	moveq	#'0',d6
.XLOOP1
	move.l	(a2)+,a3
	bsr.b	.RENUM_TREE
	addq.b	#1,d6
	moveq	#'0',d0
	add.w	(Label2Entry-DT,a4),d0
	cmp.b	d0,d6
	bne.b	.XLOOP1
	addq.b	#1,d5
	moveq	#'@',d0
	add.w	(Label1Entry-DT,a4),d0
	cmp.b	d0,d5
	bne.b	.XLOOP2
	rts

;---  Print tree  ---

.StackFull
	jmp	(ERROR_StackFull)

.RENUM_TREE
	cmp.l	(StackBottom-DT,a4),a7
	bls.b	.StackFull
	move.l	a3,-(sp)
	beq.b	.XTHEEND
	move.l	(a3),a3
	bsr.b	.RENUM_TREE
	move.l	(sp),a0
	addq.l	#8,a0
	bsr.b	C196AE
	move.l	(sp),a3
	move.l	(4,a3),a3
	bsr.b	.RENUM_TREE
.XTHEEND
	move.l	(sp)+,a3
	rts

;---  Renum name  ---

C196AE:
	tst	(a0)+
	bpl.b	C196AE
	move	(a0),d0
	bmi.b	C196C2
C196B6:
	and	#$00FF,d0
	move.b	(a1,d0.w),(1,a0)
	rts

C196C2:
	move	d0,d1
	and	#$3F00,d1
	cmp	#$0100,d1
	beq.b	C196B6
	rts

Com_WriteObjectExt:
	st	(StripTrailingZeroes-DT,a4)
	bra.b	C196F8
Com_WriteObject:
	sf	(StripTrailingZeroes-DT,a4)
C196F8:
	move.l	a6,-(sp)
	bsr	OBJ_REMOVE_UNUSED_SECTIONS
	move.l	(sp)+,a6
	cmp.b	#' ',(1,a6)
	beq.b	.C19772
	moveq	#5,d0
	bsr	FileReqStuff

.C1970E	bsr	IO_OpenFile
	move.l	(RelocStart-DT,a4),a0
	cmp.l	#$12345678,-(a0)
	bne	_ERROR_NoObject
	clr.l	(a0)
	bsr	OBJ_SORT_RELO_AREA
	bsr	OBJ_RELOC_ALL_HUNKS
	moveq	#0,d0
	move	(NrOfSections-DT,a4),d0
	beq	_ERROR_NoObject
	lea	(HUNK_HEADER,pc),a0
	move.l	d0,(MAX_HUNK_NUMBER-HUNK_HEADER,a0)
	subq.l	#1,d0
	move.l	d0,(LAST_HUNK_NR-HUNK_HEADER,a0)
	moveq	#HUNK_HEADER_END-HUNK_HEADER,d3
	move.l	a0,d2
	bsr	IO_WriteFile
	bsr	OBJ_WRITE_HUNK_LENGTHS
	bsr	OBJ_WRITE_ALL_HUNKS
	bsr	close_bestand
	bsr	OBJ_DERELOC_ALL_HUNKS
	move.l	(RelocStart-DT,a4),a0
	move.l	#$12345678,-(a0)
	rts

.C19772	addq.l	#1,a6
	bsr	C180C4
	bra.b	.C1970E

HUNK_LIST:
HUNK_HEADER:
	dc.l	$000003F3
	dc.l	0			; no name
MAX_HUNK_NUMBER:
	dc.l	0
	dc.l	0			; no libs
LAST_HUNK_NR:
	dc.l	0
HUNK_HEADER_END:

HUNK_EXTERN:
	dc.l	$000003EF
HUNK_EXTERN_END:
	dc.l	0
HUNK_CODE:
	dc.l	$000003E9,0		; code
	dc.l	$000003EA,0		; data
	dc.l	$000003EB,0		; bss
HUNK_RELOC32:
	dc.l	$000003EC
HUNK_END:
	dc.l	$000003F2

OBJ_SORT_RELO_AREA:
	lea	(Sortingreloar.MSG,pc),a0
	bsr	beeldtextaf
	move.l	(RelocEnd-DT,a4),a2
	move.l	(RelocStart-DT,a4),a0
	subq.w	#5,a0
C197D0:
	addq.w	#6,a0
	cmp.l	a0,a2
	bls.b	C197E0
	tst.b	(a0)
	bne.b	C197D0
	bra	_ERROR_NoObject

C197E0:
	move.l	(RelocStart-DT,a4),a0
	move.l	a0,a3
	addq.w	#2,a0
	move.l	a0,a1
	subq.w	#6,a0
C197EC:
	addq.w	#4,a0
	addq.w	#4,a1
	cmp.l	a1,a2
	bls.b	C19812
C197F4:
	cmpm.w	(a0)+,(a1)+
	bcc.b	C197EC
	move.l	(a0),d0
	move.l	(a1),(a0)
	move.l	d0,(a1)
	move	-(a0),d0
	move	-(a1),(a0)
	move	d0,(a1)
	cmp.l	a0,a3
	beq.b	C197F4
	subq	#6,a0
	subq	#6,a1
	bra.b	C197F4

C19812:
	rts

LINK_SORT_RELO_AREA:
	lea	(Sortingreloar.MSG,pc),a0
	bsr	beeldtextaf
	move.l	(RelocEnd-DT,a4),a2
	move.l	(RelocStart-DT,a4),a3
C19824:
	move.l	a3,a1
	moveq	#0,d6
	cmp.l	a1,a2
	bls.w	C198FA
	move	(a1),d1
	tst.b	d1
	beq.b	C1988A
C19834:
	move	d1,d0
	move.l	a1,a0
	addq.w	#6,a1
	cmp.l	a1,a2
	bls.w	C198FA
	move	(a1),d1
	tst.b	d1
	beq.b	C19862
	cmp	d0,d1
	bcc.b	C19834
	moveq	#1,d6
	move	d1,(a0)
	move	d0,(a1)
	move	d0,d1
	move.l	(2,a0),d0
	move.l	(2,a1),(2,a0)
	move.l	d0,(2,a1)
	bra.b	C19834

C19862:
	cmp	d0,d1
	bcc.b	C1988A
	moveq	#1,d6
	move.l	(2,a0),d2
	movem.l	(2,a1),d3/d4
	addq.w	#4,a1
	move	d1,(a0)
	move	d0,(a1)
	move	d0,d1
C1987C:
	move.l	d2,(2,a1)
	movem.l	d3/d4,(2,a0)
	bra.b	C19834

C1988A:
	move	d1,d0
	move.l	a1,a0
	addq.w	#6,a1
	addq.w	#4,a1
	cmp.l	a1,a2
	bls.b	C198FA
	move	(a1),d1
	tst.b	d1
	beq.b	C198C4
	cmp	d0,d1
	bcc.b	C19834
	moveq	#1,d6
	move.l	(2,a1),d2
	movem.l	(2,a0),d3/d4
	subq.w	#4,a1
	move	d1,(a0)
	move	d0,(a1)
	move	d0,d1
	move.l	d2,(2,a0)
	movem.l	d3/d4,(2,a1)
	bra.b	C1988A

C198C4:
	cmp	d0,d1
	bhi.b	C1988A
	bne.b	C198D4
	move.l	(2,a1),d2
	cmp.l	(2,a0),d2
	bcc.b	C1988A
C198D4:
	moveq	#1,d6
	move	d1,(a0)
	move	d0,(a1)
	move	d0,d1
	move.l	(2,a0),d0
	move.l	(2,a1),(2,a0)
	move.l	d0,(2,a1)
	move.l	(6,a0),d0
	move.l	(6,a1),(6,a0)
	move.l	d0,(6,a1)
	bra.b	C1988A

C198FA:
	tst.b	d6
	bne	C19824
C19932:
	rts

OBJ_RELOC_ALL_HUNKS:
	move.l	(RelocStart-DT,a4),a0
	move.l	(RelocEnd-DT,a4),a1
	lea	(SECTION_ABS_LOCATION-DT,a4),a2
C1990E:
	cmp.l	a0,a1
	beq.b	C19932
	moveq	#0,d0
	move.b	(a0)+,d0

	IF MC020
	move.l	(a2,d0.w*4),a3
	ELSE
	lsl.w	#2,d0
	move.l	(a2,d0.w),a3
	moveq	#0,d0
	ENDC

	move.b	(a0)+,d0
	beq.b	C1992E

	IF MC020
	move.l	(a2,d0.w*4),d1
	ELSE
	lsl.w	#2,d0
	move.l	(a2,d0.w),d1
	ENDC

	add.l	(a0)+,a3
	sub.l	d1,(a3)
	bra.b	C1990E

C1992E:
	addq.w	#8,a0
	bra.b	C1990E

OBJ_DERELOC_ALL_HUNKS:
	move.l	(RelocStart-DT,a4),a0
	move.l	(RelocEnd-DT,a4),a1
	lea	(SECTION_ABS_LOCATION-DT,a4),a2
C19940:
	cmp.l	a0,a1
	beq.b	C19964
	moveq	#0,d0
	move.b	(a0)+,d0

	IF MC020
	move.l	(a2,d0.w*4),a3
	ELSE
	lsl.w	#2,d0
	move.l	(a2,d0.w),a3
	ENDC

	moveq	#0,d0
	move.b	(a0)+,d0
	beq.b	C19960

	IF MC020
	move.l	(a2,d0.w*4),d1
	ELSE
	lsl.w	#2,d0
	move.l	(a2,d0.w),d1
	ENDC

	add.l	(a0)+,a3
	add.l	d1,(a3)
	bra.b	C19940
C19960:
	addq.w	#8,a0
	bra.b	C19940
C19964:
	rts

OBJ_WRITE_HUNK_LENGTHS:
	lea	(Writinghunkle.MSG,pc),a0
	bsr	beeldtextaf
	move	(NrOfSections-DT,a4),d0
	subq.w	#1,d0
	lea	SECTION_ORG_ADDRESS-DT+4(a4),a1
	lea	SECTION_TYPE_TABLE-DT+1(a4),a2
	lea	(ParameterBlok-DT,a4),a3
	move.l	a3,d2
.Loop
	move.b	(a2)+,d3
	move.l	(a1)+,d1
	addq.l	#3,d1
	lsr.b	#1,d3
	roxr.l	#1,d1
	lsr.b	#1,d3
	roxr.l	#1,d1
	move.l	d1,(a3)+
	dbra	d0,.Loop
	move.l	a3,d3
	sub.l	d2,d3
	br	IO_WriteFile

com_zapfile:
	cmp.b	#' ',(a6)
	beq.b	C199C4
	moveq	#9,d0
	bsr	FileReqStuff
C199AA:
	move.l	(DosBase-DT,a4),a6
	lea	(CurrentAsmLine-DT,a4),a0
	move.l	a0,d1
	jsr	(_LVODeleteFile,a6)
	tst	d0
	beq.w	_ERROR_FileError
	rts

C199C4:
	bsr	C180C4
	bra.b	C199AA

;************ DEBUG MODE ROUTINES *************

;Show_Cursor2:
;	movem.l	d7/a5/a6,-(sp)
;	bsr	Place_cursor_blokje
;	movem.l	(sp)+,d7/a5/a6
;	rts

DBTypeSource:
	dc.w	PrintStatusBalk-DBTypeSource	; assemble, debug offsets
	dc.w	Debug_SourcePrint-DBTypeSource
	dc.w	Debug_InputMark-DBTypeSource

DBTypeMem:
	dc.w	Debug_PrintStatusBalk2-DBTypeMem
	dc.w	Debug_DissPrint-DBTypeMem
	dc.w	Debug_InputMarkMon-DBTypeMem

InitProgramStacks:
	lea	(eop_irq_routine,pc),a1
	lea	(SuperStackEnd-DT,a4),a0
	move.l	a1,-(a0)
	move.l	a0,(SSP_base-DT,a4)
	lea	(UserStackEnd-DT,a4),a0
	move.l	a1,-(a0)
	move.l	a0,(USP_base-DT,a4)
	rts

Enter_debugger:
	lea	(Dbg_Param-DT,a4),a0
.C199E8	move.b	(a6)+,(a0)+
	bne.b	.C199E8
	tst	(AssmblrStatus-DT,a4)
	bne.b	.C19A00
	bsr	ZapAllCondBPsAndWatches
.C19A00	bsr.b	InitProgramStacks
	move.l	(sourcestart-DT,a4),(TraceLinePtr-DT,a4)
	moveq	#1,d0
	move.l	d0,(TraceLineNr-DT,a4)
	clr	(MON_EDIT_POSITION-DT,a4)
	bsr	MON_CLEARCACH
	lea	(MON_DIS_TYPES,pc),a0
	move.l	a0,(MON_TYPE_PTR-DT,a4)

DEBUG_TYPECHANGE:
	lea	(DBTypeSource,pc),a0
	btst	#0,(PR_ShowSource).l
	bne.b	.IS_SOURCE
	lea	(DBTypeMem,pc),a0
.IS_SOURCE
	move.l	a0,(DBTypePtr-DT,a4)

	btst	#0,(PR_ShowSource).l
	beq.b	.NO_SOURCE1
	btst	#SB2_INDEBUGMODE,(SomeBits2-DT,a4)
	bne.b	.NO_SOURCE2
	jsr	(Asmbl_DebugMode).l
	sf	(Asm_Multiscroll-DT,a4)
	bset	#SB2_INDEBUGMODE,(SomeBits2-DT,a4)
	moveq	#$30,d0		; send ESC+'0' to cmdline to enter dbg
	bsr	C17412
	movem.l	d0-d7/a0-a6,-(sp)
	lea	(Dbg_Param-DT,a4),a6
	tst.b	(a6)
	beq.b	.C19A86
	bsr	GETNUMBERAFTEROK
	move.l	d0,(pcounter_base-DT,a4)
.C19A86:
	movem.l	(sp)+,d0-d7/a0-a6
	bra	CommandlineInputHandler

.NO_SOURCE1:
	move.l	(MEM_DIS_DUMP_PTR-DT,a4),(pcounter_base-DT,a4)
.NO_SOURCE2:
	bset	#SB3_REPORT_ERROR,(SomeBits3-DT,a4)
	lea	(DEBUG_NEXTLINE,pc),a0
	move.l	a0,(Error_Jumpback-DT,a4)
	jsr	(Change2Debugmenu).l
	st	(BreakKey-DT,a4)	;disabled
DEBUG_REDRAW:
	bset	#SB3_COMMANDMODE,(SomeBits3-DT,a4)	;in commandmode
	move	(ScreenHight-DT,a4),d0
	subq.w	#2,d0
	sub	(DEBUG_NUMOFADDS-DT,a4),d0
	sub	(Dbg_NumCondBPs-DT,a4),d0
	btst	#0,(PR_NoDisasm).l
	beq.b	.noDis
	subq.w	#1,d0
.noDis:
	bsr	OPED_SETNBOFFLINES
	bsr	SENDCHARDELSCR
	bsr.w	Druk_Clearbuffer

	move.l	(DBTypePtr-DT,a4),a0
	add	(a0),a0		;DBType_Border
	jsr	(a0)

	bsr.w	_Show_Cursor
	bsr	open_debug_win
;	bsr	open_output_win

;	bsr	INVERTCURSOR3

DEBUG_NEXTLINE:
	move.l	(LoopPtr-DT,a4),d0
	beq.b	.noLoop
	move.l	d0,a1
	clr.l	(LoopPtr-DT,a4)
	bsr	DEBUG_ADD_BRKPT
	br	DEBUG_NO_BREAK_PT

.noLoop:
	tst.b	(Animate-DT,a4)
	beq.b	noAnimate
	bsr	C1A5FE
	tst.b	d0
	beq.b	.run
	sf	(Animate-DT,a4)
	lea	(Conditionbrea.MSG,pc),a0
	bsr	printTextInMenuStrip
	bclr	#SB1_WINTITLESHOW,(SomeBits-DT,a4)
	bra.b	noAnimate
.run:
	bsr	messages_get
	beq.b	Debug_Animate
	sf	(Animate-DT,a4)
	bsr	GETKEYNOPRINT
	bra.b	noAnimate

Debug_Animate:
	movem.l	d0-d7/a0-a6,-(sp)
	moveq	#5,d1
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVODelay,a6)
	movem.l	(sp)+,d0-d7/a0-a6

	bsr	show_breaks_watches

	move.l	(DBTypePtr-DT,a4),a0
	add	(2,a0),a0		;DBType_Print
	jsr	(a0)

;	move.l	(Cursor_pos-DT,a4),-(sp) ; col, row
;	clr	(cursor_row_pos-DT,a4)
;	move	(Scr_br_chars-DT,a4),(Cursor_col_pos-DT,a4)
;	subq	#1,(Cursor_col_pos-DT,a4)
;	bsr.w	_Show_Cursor

	move.w	#3,adryoff	;reset y offset voor regs
	bsr	_druk_af_debug_regs

;	bsr.w	_Show_Cursor
;	move.l	(sp)+,(Cursor_pos-DT,a4) ; col, row

	move.l	(pcounter_base-DT,a4),a0
	move	(a0),d0
	cmp	#$4EAE,d0
	beq	DEBUG_SINGLE_STEP
	cmp	#$4EEE,d0
	beq	DEBUG_SINGLE_STEP
	br	DEBUG_ENTER_SINGLE_STEP

noAnimate:
	move.l	(DATA_USERSTACKPTR-DT,a4),sp
	moveq	#0,d7
	bsr	RESETMENUTEXT
	tst.b	(PR_RealtimeDebug).l
	bne.b	.C19BD8
	bsr	messages_get
	bne.b	.GET_ANOTHER
	bra.b	.C19BE6

.C19BD8:
	bsr	messages_get
	beq.b	.C19BE6
	bsr	GETKEYNOPRINT
	bra.b	.C19BD8

.C19BE6:
	bsr	show_breaks_watches

;	jsr	get_font2		;eerste regel markblok
;	bset	#MB1_BLOCKSELECT,(MyBits-DT,a4)

	move.l	(DBTypePtr-DT,a4),a0
	add	(2,a0),a0		;DBType_Print
	jsr	(a0)

;	bclr	#MB1_BLOCKSELECT,(MyBits1-DT,a4)
;	jsr	test_debug

;	move.l	(Cursor_pos-DT,a4),-(sp) ; col, row
;	clr	(cursor_row_pos-DT,a4)
;	move	(Scr_br_chars-DT,a4),(Cursor_col_pos-DT,a4)
;	subq	#1,(Cursor_col_pos-DT,a4)
;	bsr.w	_Show_Cursor

	move.w	#3,adryoff	;reset y offset voor regs
	bsr	_druk_af_debug_regs

;	bsr.w	_Show_Cursor
;	move.l	(sp)+,(Cursor_pos-DT,a4) ; col, row

.GET_ANOTHER:
	bsr	GETKEYNOPRINT
	cmp.b	#$1B,d0
	bne.s	.ccc

;	bsr	close_debug_win
;	bsr	close_output_win

	br	Debug_QuitTrace
.ccc:
	pea	(DEBUG_NEXTLINE,pc)
	cmp.b	#$80,d0
	beq.b	.KEYCODE
	bra.b	.GET_ANOTHER

.KEYCODE:
	moveq	#0,d0
	move.b	(edit_EscCode-DT,a4),d0
	cmp.b	#$13,d0		;AMIGA_A
	beq	DEBUG_ADDWATCH
	cmp.b	#$47,d0		;AMIGA_1
	bcs.b	.NO_DELWATCH
	cmp.b	#$4E,d0		;AMIGA_8
	bls.w	DEBUG_DELWATCH
.NO_DELWATCH:
	cmp.b	#$72,d0
	bcs.b	.C19C62
	cmp.b	#$79,d0
	bls.w	DEBUG_DELCONDBP
.C19C62:
	cmp	#$001C,d0	;AMIGA_J
	beq	DEBUG_JUMP_TO_MARK
	cmp	#$002C,d0	;AMIGA_Z
	beq	DEBUG_CLEAR_BP_BUFFER
	cmp	#$0024,d0	;AMIGA_R
	beq	DEBUG_NO_BREAK_PT
	cmp	#$0025,d0	;AMIGA_S
	beq	DEBUG_STEP_N
	cmp	#$0046,d0	;AMIGA_SHIFT_Z
	beq	DEBUG_ZAPWATCHES
	cmp	#$002A,d0	;AMIGA_X
	beq	DEBUG_EDIT_XN
	cmp	#$0036,d0	;AMIGA_SHIFT_J
	beq	DEBUG_JUMP_ADDR
	cmp	#$002E,d0	;AMIGA_SHIFT_B
	beq	DEBUG_BP_ADDR
	cmp	#$0014,d0	;AMIGA_B
	beq	DEBUG_BP_MARK
	cmp	#$0056,d0	;DISASSEM
	beq	DEBUG_REDRAW
	cmp	#$002F,d0	;AMIGA_SHIFT_A
	beq	DEBUG_ChangefromDx2FPx
	cmp	#$002D,d0	;AMIGA_SHIFT_C
	beq	DEBUG_KEYP_EXIT_AGAIN
	cmp	#$003B,d0	;AMIGA_SHIFT_O
	beq	DEBUG_KEYP_EXIT_AGAIN
	cmp	#$0031,d0	;AMIGA_SHIFT_E
	beq	DEBUG_KEYP_EXIT_AGAIN
	cmp	#$0030,d0	;AMIGA_SHIFT_D
	beq	DEBUG_KEYP_EXIT_AGAIN
	cmp	#$0039,d0	;AMIGA_SHIFT_M
	beq	DEBUG_KEYP_EXIT_AGAIN
	cmp	#4,d0		;DOWN
	beq	DEBUG_SINGLE_STEP
	cmp	#3,d0		;RIGHT
	beq	DEBUG_ENTER_SINGLE_STEP
	cmp	#$0055,d0	;SHOWSOURCE
	beq	DEBUG_TYPECHANGE_MAIN
	cmp	#$0054,d0	;LINENUMBERS
	beq	DEBUG_REDRAW

	cmp.w	#31,d0		;AMIGA_M
	beq.b	.DEBUG_EditMem
	cmp	#$0057,d0
	beq.b	DEBUG_SetBreakpointhere
	cmp	#$0064,d0
	beq.b	DEBUG_ANIMATE
	cmp	#$0065,d0
	beq.b	DEBUG_SkipInstruction
	cmp	#$0071,d0
	beq	DEBUG_AddCondition
	cmp	#$007A,d0
	beq	DEBUG_ZapAllCondBPs
	br	.GET_ANOTHER

.DEBUG_EditMem:
	movem.l	d0-a6,-(sp)
	bsr	mon_enterhexmon
	movem.l	(sp)+,d0-a6
	br	.GET_ANOTHER

DEBUG_SkipInstruction:
	move.l	(TraceLineNr-DT,a4),d0
	lsl.l	#2,d0
	bpl.b	C19D38
	moveq	#0,d0
C19D38:
	move.l	(LabelEnd-DT,a4),a0
	add.l	d0,a0
	move.l	(DEBUG_END-DT,a4),a1
	cmp.l	a1,a0
	bcs.b	C19D52
	bsr	C1A9AE
	bclr	#SB1_WINTITLESHOW,(SomeBits-DT,a4)
	rts

C19D52:
	tst.l	d0
	beq.b	C19D62
	move.l	(a0),d1
	cmp.l	(pcounter_base-DT,a4),d1
	bne.b	C19D62
	subq.l	#4,d0
	bra.b	C19D38

C19D62:
	move.l	(a0),(pcounter_base-DT,a4)
	rts

DEBUG_ANIMATE:
	st	(Animate-DT,a4)
	br	DEBUG_SINGLE_STEP

DEBUG_SetBreakpointhere:
	move.l	(pcounter_base-DT,a4),(LoopPtr-DT,a4)
	moveq	#1,d0
	br	com_singlestep

DEBUG_ChangefromDx2FPx:
	not.b	(debug_FPregs-DT,a4)
	bra	resize_db_win

DEBUG_TYPECHANGE_MAIN:
	move.b	#21,(BreakKey-DT,a4)	;AMIGA_C
	jsr	(Change2Commmenu)
	bclr	#SB3_REPORT_ERROR,(SomeBits3-DT,a4)
	bsr	DEBUG_OFF_2
	br	DEBUG_TYPECHANGE

;********  Debug Dis Print  ********

Debug_DissPrint:
	jsr	(RegTab_SETALLNOTUPD).l
	clr.l	(LineFromTop-DT,a4)
	move.l	(pcounter_base-DT,a4),(RegelPtrsIn-DT,a4)
	bsr	iets_met_monitor_output
	move.l	(MON_TYPE_PTR-DT,a4),a0
	add	(6,a0),a0
	jmp	(a0)

;********  Debug Src Print  ********

Debug_SourcePrint:
	bsr	DEBUG_FIND_ADDRESS
	bsr	DEBUG_JUMPTOLINE
	move.l	(FirstLinePtr-DT,a4),(TraceLinePtr-DT,a4)
	move.l	(FirstLineNr-DT,a4),(TraceLineNr-DT,a4)
	move.l	(NrOfLinesInEditor-DT,a4),d1
	lsr.w	#1,d1
	jsr	(MoveupNLines).l
	move.l	a2,a6
	jsr	E_Move2EndLine
	jsr	EDITSCRPRINT
	move.l	(TraceLinePtr-DT,a4),(FirstLinePtr-DT,a4)
	move.l	(TraceLineNr-DT,a4),(FirstLineNr-DT,a4)
	rts

;*******   Jump to mark   ********

DEBUG_JUMP_TO_MARK:
	st	(Dbg_KeepMark-DT,a4)
	bra.b	DEBUG_SetTmpMark
C19E64:
	lea	(12,sp),sp
	br	DEBUG_REDRAW

DEBUG_BP_MARK:
	sf	(Dbg_KeepMark-DT,a4)

DEBUG_SetTmpMark:
	move.l	(pcounter_base-DT,a4),-(sp)
	move.l	(TraceLinePtr-DT,a4),-(sp)
	move.l	(TraceLineNr-DT,a4),-(sp)
	move.l	(DBTypePtr-DT,a4),a0
	add	(4,a0),a0
	jsr	(a0)
	cmp.b	#27,d0		; ESC
	beq.b	C19E90
	tst.b	(Dbg_KeepMark-DT,a4)
	bne.b	C19E64
	move.l	(pcounter_base-DT,a4),a1
	bsr	DEBUG_ADD_BRKPT
C19E90:
	move.l	(sp)+,(TraceLineNr-DT,a4)
	move.l	(sp)+,(TraceLinePtr-DT,a4)
	move.l	(sp)+,(pcounter_base-DT,a4)
	br	DEBUG_REDRAW

Debug_InputMarkMon:
	lea	(Marklocationa.MSG,pc),a0
	bsr	printTextInMenuStrip
	lea	(MON_DIS_TYPES,pc),a0
	move.l	a0,(MON_TYPE_PTR-DT,a4)
	clr.l	(LineFromTop-DT,a4)
	jsr	(RegTab_SETALLNOTUPD).l
	move.l	(pcounter_base-DT,a4),(RegelPtrsIn-DT,a4)
C19EC0:
	moveq	#0,d7
	move	(Scr_br_chars-DT,a4),(breedte_editor_in_chars-DT,a4)
	bsr	iets_met_monitor_output
	move.l	(MON_TYPE_PTR-DT,a4),a0
	add	(6,a0),a0
	jsr	(a0)
	bsr	messages_get
	bsr	GETKEYNOPRINT
	cmp.b	#$1B,d0		;ESC
	beq.b	C19F20
	cmp.b	#13,d0		;CR
	beq.b	C19F20
	pea	(C19EC0,pc)
	cmp.b	#$80,d0
	bne.b	C19F1E
	moveq	#0,d0
	move.b	(edit_EscCode-DT,a4),d0
	cmp.b	#1,d0
	beq	Mon_scrolldown
	cmp.b	#4,d0
	beq	Mon_scrollup
	cmp.b	#5,d0
	beq	Mon_pageup
	cmp.b	#8,d0
	beq	Mon_pagedown
C19F1E:
	rts

C19F20:
	move	d0,-(sp)
	bsr	mon_getCurrAdr
	move.l	d0,(pcounter_base-DT,a4)
	move	(sp)+,d0
	rts

Debug_InputMark:
	lea	(Marklocationa.MSG,pc),a0
	bsr	printTextInMenuStrip
	jsr	(RegTab_SETALLNOTUPD).l
	bra.b	C19F70

C19F40:
	subq.l	#1,d0
	lsl.l	#2,d0
	bpl.b	C19F48
	moveq	#0,d0
C19F48:
	move.l	(LabelEnd-DT,a4),a0
	add.l	d0,a0
	move.l	(DEBUG_END-DT,a4),a1
	cmp.l	a1,a0
	bcs.b	C19F5C
	move.l	a1,a0
	subq.l	#4,a0
	bra.b	C19F6C

C19F5C:
	tst.l	d0
	beq.b	C19F6C
	move.l	(a0),d1
	cmp.l	(pcounter_base-DT,a4),d1
	bne.b	C19F6C
	subq.l	#4,d0
	bra.b	C19F48

C19F6C:
	move.l	(a0),(pcounter_base-DT,a4)
C19F70:
	bsr	DEBUG_FIND_ADDRESS
	bsr	DEBUG_JUMPTOLINE
	move.l	(FirstLinePtr-DT,a4),(TraceLinePtr-DT,a4)
	move.l	(FirstLineNr-DT,a4),(TraceLineNr-DT,a4)
	move.l	(NrOfLinesInEditor-DT,a4),d1
	lsr.w	#1,d1
	jsr	(MoveupNLines).l
	move.l	a2,a6
	jsr	E_Move2EndLine
	move	(Scr_br_chars-DT,a4),(breedte_editor_in_chars-DT,a4)
	jsr	EDITSCRPRINT
	bsr	messages_get
C19FA8:
	bsr	GETKEYNOPRINT
	cmp.b	#$1B,d0
	beq.b	C19FC0
	cmp.b	#13,d0
	beq.b	C19FC0
	cmp.b	#$80,d0
	beq.b	C19FC2
	bra.b	C19FA8

C19FC0:
	rts

C19FC2:
	move.b	(edit_EscCode-DT,a4),d0
	cmp.b	#4,d0
	beq.b	C19FE2
	cmp.b	#1,d0
	beq.b	C19FEE
	cmp.b	#8,d0
	beq.b	C19FFA
	cmp.b	#5,d0
	beq.b	C1A00C
	bra.b	C19FA8

C19FE2:
	move.l	(TraceLineNr-DT,a4),d0
	addq.l	#1,d0
	br	C19F40

C19FEE:
	move.l	(TraceLineNr-DT,a4),d0
	subq.l	#1,d0
	br	C19F40

C19FFA:
	move.l	(TraceLineNr-DT,a4),d0
	add.l	(NrOfLinesInEditor-DT,a4),d0
	br	C19F40

C1A00C:
	move.l	(TraceLineNr-DT,a4),d0
	sub.l	(NrOfLinesInEditor-DT,a4),d0
	br	C19F40

GetAdrFromTitle:
	bsr	putThetextInMenubar
	bne.b	C1A036
	lea	(CurrentAsmLine-DT,a4),a6
	tst.b	(a6)
	beq.b	C1A036
	jsr	(Convert_A2I).l
	beq.b	C1A036
	rts

C1A036:
	move.l	(Error_Jumpback-DT,a4),a0
	jmp	(a0)

DEBUG_BP_ADDR:
	lea	(Address.MSG,pc),a0
	bsr.b	GetAdrFromTitle
	bclr	#0,d0
	move.l	d0,a1
	br	DEBUG_ADD_BRKPT

DEBUG_JUMP_ADDR:
	lea	(Address.MSG,pc),a0
	bsr.b	GetAdrFromTitle
	bclr	#0,d0
	move.l	d0,(pcounter_base-DT,a4)
	rts

DEBUG_STEP_N:
	lea	(Steps.MSG,pc),a0
	bsr.b	GetAdrFromTitle
	br	com_singlestep

DEBUG_EDIT_XN:
	lea	(Register.MSG0,pc),a0
	bsr	putThetextInMenubar
	lea	(CurrentAsmLine-DT,a4),a6
	move.l	a6,-(sp)
	jsr	(NEXTSYMBOL)
	move.b	#$3D,(a6)+
	move.b	#$20,(a6)+
	clr.b	(a6)
	bsr	LINE_TEXT_FINDREG_NAME
	move.l	(sp)+,a0
	move.l	a1,a5
	bsr.b	GetAdrFromTitle
	swap	d0
	cmp.b	#2,(OpperantSize-DT,a4)
	beq.b	C1A09E
	move	d0,(a5)+
C1A09E:
	swap	d0
	move	d0,(a5)+
	rts

DEBUG_ZapAllCondBPs:
	bsr.b	ZapAllCondBPs
	bra.b	DEBUG_CURSOR_OFF_REDRAW

DEBUG_ZAPWATCHES:
	bsr.b	ZallAllWatches
	bra.b	DEBUG_CURSOR_OFF_REDRAW

ZapAllCondBPsAndWatches:
	bsr.b	ZapAllCondBPs

ZallAllWatches:
	lea	(watch_table_name-DT,a4),a0
	moveq	#7,d0
.C1A0BE	clr.b	(a0)
	lea	(16,a0),a0
	dbra	d0,.C1A0BE
	clr	(DEBUG_NUMOFADDS-DT,a4)
	rts

DEBUG_DELWATCH:
	sub.b	#$47,d0
	ext.w	d0
	lsl.w	#4,d0
	lea	(watch_table_name-DT,a4),a0
	tst.b	(a0,d0.w)
	beq.b	C1A0E8
	clr.b	(a0,d0.w)
	subq.w	#1,(DEBUG_NUMOFADDS-DT,a4)
C1A0E8:
	bra.b	DEBUG_CURSOR_OFF_REDRAW

DEBUG_DELCONDBP:
	sub.b	#$72,d0
	ext.w	d0
	lsl.w	#4,d0
	lea	(L1A3F4-DT,a4),a0
	lea	(L1A474-DT,a4),a1
	tst.b	(a0,d0.w)
	beq.b	C1A112
	clr.b	(a0,d0.w)
	clr.b	(a1,d0.w)
	subq.w	#1,(Dbg_NumCondBPs-DT,a4)
C1A112:
DEBUG_CURSOR_OFF_REDRAW:
	bsr.w	_Show_Cursor
	br	DEBUG_REDRAW

ZapAllCondBPs:
	lea	(L1A3F4-DT,a4),a0
	moveq	#7,d0
C1A120:
	clr.b	(a0)
	clr.b	($0080,a0)
	lea	(16,a0),a0
	dbra	d0,C1A120
	clr	(Dbg_NumCondBPs-DT,a4)
	rts

DEBUG_AddCondition:
	cmp.w	#8,(Dbg_NumCondBPs-DT,a4)
	beq	C1A282
	bclr	#SB2_A_XN_USED,(SomeBits2-DT,a4)
	bset	#SB2_MATH_XN_OK,(SomeBits2-DT,a4)
	lea	(AddConditiona.MSG,pc),a0
	bsr	printTextInMenuStrip
	bsr	GetAdrFromTitle
	move.l	d0,d3
	lea	(CurrentAsmLine-DT,a4),a6
	bsr.b	C1A19C
	bsr.b	C1A1C2
	cmp.b	#$1B,d0
	beq.b	C1A192
	lea	(Comparisonval.MSG,pc),a0
	bclr	#SB2_A_XN_USED,(SomeBits2-DT,a4)
	bset	#SB2_MATH_XN_OK,(SomeBits2-DT,a4)
	bsr	GetAdrFromTitle
	move.l	d0,d3
	lea	(CurrentAsmLine-DT,a4),a6
	bsr.b	C1A1AC
	addq	#1,(Dbg_NumCondBPs-DT,a4)
	bra.b	DEBUG_CURSOR_OFF_REDRAW

C1A192:
	move.l	(L2F154-DT,a4),a0
	clr.b	(a0)
	rts

C1A19C:
	lea	(L1A3F4-DT,a4),a0
	lea	(L1A4F4-DT,a4),a1
	lea	(L1A534-DT,a4),a2
	bra.b	C1A228

C1A1AC:
	lea	(L1A474-DT,a4),a0
	lea	(L1A514-DT,a4),a1
	lea	(L1A53C-DT,a4),a2
	bsr.b	C1A228
	moveq	#0,d1
	bra.b	C1A240

C1A1C2:
	move.l	(MainWindowHandle-DT,a4),a1
	bset	#0,(wd_Flags+1,a1)		; set rmbtrap
	lea	(Conditiontype.MSG,pc),a0
	bsr	printTextInMenuStrip
	bsr	GETKEYNOPRINT
	and.b	#$DF,d0
	cmp.b	#$1B,d0
	beq.b	C1A214
	moveq	#0,d1
	cmp.b	#$10,d0
	beq.b	C1A240
	moveq	#1,d1
	cmp.b	#$11,d0
	beq.b	C1A240
	moveq	#2,d1
	cmp.b	#$12,d0
	beq.b	C1A240
	moveq	#3,d1
	cmp.b	#$13,d0
	beq.b	C1A240
	moveq	#4,d1
	cmp.b	#$14,d0
	beq.b	C1A240
	moveq	#5,d1
	cmp.b	#$15,d0
	beq.b	C1A240
	bra.b	C1A1C2

C1A214:
	move.l	(MainWindowHandle-DT,a4),a1
	bclr	#0,(wd_Flags+1,a1)		; clear rmbtrap
	rts

C1A220:
	lea	(16,a0),a0
	addq.w	#4,a1
	addq.w	#1,a2
C1A228:
	tst.b	(a0)
	bne.b	C1A220
	move.l	a0,(L2F154-DT,a4)
	moveq	#14,d0
C1A232:
	move.b	(a6)+,(a0)+
	beq.b	C1A23C
	dbra	d0,C1A232
	clr.b	(a0)+
C1A23C:
	move.l	d3,(a1)
	rts

C1A240:
	bclr	#SB2_A_XN_USED,(SomeBits2-DT,a4)
	beq.b	C1A24C
	or.b	#$80,d1
C1A24C:
	move.b	d1,(a2)
	rts

DEBUG_ADDWATCH:
	move	(DEBUG_NUMOFADDS-DT,a4),d0
	cmp	#8,d0
	beq.b	C1A282
	lea	(Watch.MSG,pc),a0
	bclr	#SB2_A_XN_USED,(SomeBits2-DT,a4)
	bset	#SB2_MATH_XN_OK,(SomeBits2-DT,a4)
	bsr	GetAdrFromTitle
	move.l	d0,d3
	lea	(CurrentAsmLine-DT,a4),a6
	bsr.b	C1A28C
	addq.w	#1,(DEBUG_NUMOFADDS-DT,a4)
	bra.w	DEBUG_CURSOR_OFF_REDRAW

C1A282:
	lea	(BufferFull.MSG,pc),a0
	bra	printTextInMenuStrip

C1A28C:
	lea	(watch_table_name-DT,a4),a0
	lea	(watch_table_addr-DT,a4),a1
	lea	(watch_table_type-DT,a4),a2
	bra.b	C1A2A2

C1A29A:
	lea	(16,a0),a0
	addq.w	#4,a1
	addq.w	#1,a2
C1A2A2:
	tst.b	(a0)
	bne.b	C1A29A
	moveq	#14,d0
C1A2A8:
	move.b	(a6)+,(a0)+
	beq.b	C1A2B2
	dbra	d0,C1A2A8
	clr.b	(a0)+
C1A2B2:
	move.l	d3,(a1)
C1A2B4:
	move.l	(MainWindowHandle-DT,a4),a1
	bset	#0,(wd_Flags+1,a1)		; set rmbtrap
	lea	(WatchtypeAsci.MSG,pc),a0
	bsr	printTextInMenuStrip
	moveq	#0,d3
C1A2C8:
	bsr	GETKEYNOPRINT
	and.b	#$DF,d0
	moveq	#0,d1
	cmp.b	#$41,d0
	beq.b	C1A32C
	moveq	#1,d1
	cmp.b	#$53,d0
	beq.b	C1A32C
	moveq	#2,d1
	cmp.b	#$48,d0
	beq.b	C1A32C
	moveq	#3,d1
	cmp.b	#$44,d0
	beq.b	C1A32C
	moveq	#4,d1
	cmp.b	#$42,d0
	beq.b	C1A32C
	tst.b	d3
	bne.b	C1A2B4
	cmp.b	#$50,d0
	bne.b	C1A2B4
	lea	(Pointertype1D.MSG,pc),a0
	bsr	printTextInMenuStrip
	bsr	GETKEYNOPRINT
	cmp.b	#$31,d0
	bcs.b	C1A2B4
	cmp.b	#$34,d0
	bhi.b	C1A2B4
	sub.b	#$30,d0
	lsl.b	#4,d0
	or.b	d0,d3
	lea	(PointertoAsci.MSG,pc),a0
	bsr	printTextInMenuStrip
	bra.b	C1A2C8

C1A32C:
	move.l	(MainWindowHandle-DT,a4),a1
	bclr	#0,(wd_Flags+1,a1)		; clear rmbtrap
	or.b	d1,d3
	bclr	#SB2_A_XN_USED,(SomeBits2-DT,a4)
	beq.b	C1A344
	or.b	#$80,d3
C1A344:
	move.b	d3,(a2)
	rts

;************* DEBUG WINDOOWTJE ****************

Debug_WindowTags:
dw_x:
	DC.L	WA_Left,0		;x
dw_y:
	DC.L	WA_Top,32	;y
dw_br:
	DC.L	WA_Width,32	;br
dw_hg:
	DC.L	WA_Height,32	;hg
	DC.L	WA_IDCMP,IDCMP_NEWSIZE|IDCMP_MOUSEBUTTONS|IDCMP_ACTIVEWINDOW;|IDCMP_CLOSEWINDOW
	DC.L	WA_Flags,WFLG_DEPTHGADGET|WFLG_DRAGBAR|WFLG_GIMMEZEROZERO	;|WFLG_CLOSEGADGET
	DC.L	WA_Title,Debug_WTitle
Debug_SC:
	DC.L	WA_PubScreen,0
	DC.L	TAG_DONE

Debug_adrtxt:
db_pens:
	DC.B	1,0
	DC.B	1
	DC.B	0
	DC.W	3		;x
adryoff:
	dc.w	3		;y
	DC.L	Editor_Font
adrtxtptr:
	DC.L	adrtxtbuf
	DC.L	0

Debug_Text:
	DC.B	1,0
	DC.B	1
	DC.B	0
	DC.W	3,3
	DC.L	Editor_Font
debtxt:
	DC.L	Debug_IText
	DC.L	0

adrtxtbuf:
	dc.b	"00000000",0
	dc.b	"++++++++",0

Debug_WTitle:
	DC.B	'Debugging.',0

Debug_IText:
	DC.B	' A0: --------',0
	DC.B	' A1: --------',0
	DC.B	' A2: --------',0
	DC.B	' A3: --------',0
	DC.B	' A4: --------',0
	DC.B	' A5: --------',0
	DC.B	' A6: --------',0
	DC.B	' A7: --------',0
	dc.b	'SSP= --------',0
	dc.b	'USP= --------',0
	dc.b	' SR= xxxxPL=0',0
	dc.b	'  xx xx XNZVC',0	;T1 S1 XNZVC
	dc.b	'  PC=--------',0
	dc.b	' VBR=--------',0
	dc.b	'FPSR=--------',0
	dc.b	' PCR=xxxxxxxx',0

DebugDx_IText
	DC.B	' D0: 00000000',0
	DC.B	' D1: 00000000',0
	DC.B	' D2: 00000000',0
	DC.B	' D3: 00000000',0
	DC.B	' D4: 00000000',0
	DC.B	' D5: 00000000',0
	DC.B	' D6: 00000000',0
	DC.B	' D7: 00000000',0

DebugFP_IText:
	dc.b	'FP0: 1.00000000 E 1',0
	dc.b	'FP1: 0.00000000 E 0',0
	dc.b	'FP2: 0.00000000 E 0',0
	dc.b	'FP3: 0.00000000 E 0',0
	dc.b	'FP4: 0.00000000 E 0',0
	dc.b	'FP5: 0.00000000 E 0',0
	dc.b	'FP6: 0.00000000 E 0',0
	dc.b	'FP7: 0.00000000 E 0',0

; D0: 00000000
; D1: 00000000
; D2: 00000000
; D3: 00000000
; D4: 00000000
; D5: 00000000
; D6: 00000000
; D7: 00000000
; A0: 00000000
; A1: 00000000
; A2: 00000000
; A3: 00000000
; A4: 00000000
; A5: 00000000
; A6: 00000000
; A7: 68314308
; SSP=68315308
; USP=68314308
; SR=0000 PL=0
; -- --  -----
; PC =EOP
; VBR=680CCE1C
;FPSR=00000000

	EVEN
	IFEQ	SPEC_ED
db_imagestr:
	dc.w	0		;0	offset x
	dc.w	0		;2	offset y
	dc.w	40		;4	breedte 
	dc.w	100		;6	hoogte plaatje
	dc.w	2		;8	nr planes
	dc.l	smallasmprologo	;10	bitmap ptr
	dc.b	3		;14
	dc.b	0		;15
	dc.l	0		;16
	ENDIF

resize_db_win:
	movem.l	d0-a6,-(sp)
	move.l	(IntBase-DT,a4),a6
	move.l	(debug_winbase-DT,a4),d0
	beq.w	.isdicht
	move.l	d0,a0

	move.l	(debug_msg_port-DT,a4),(wd_UserPort,a0)

	move.b	(debug_FPregs-DT,a4),d0
	cmp.b	(db_type-DT,a4),d0
	beq.b	.klaar

	move.l	(debug_winbase-DT,a4),a0
	movem.w	(wd_LeftEdge,a0),d0/d1		;x,y

	moveq	#13,d2
	mulu.w	(EFontSize_x-DT,a4),d2
	add.w	(Win_BorHor-DT,a4),d2
	addq.w	#6,d2	;marge

;	move.w	#6+13*FontSize_x+8,d2		;w

	moveq	#23,d3
	cmp.w	#PB_060,(ProcessorType-DT,a4)
	blo.s	.geen060Plus
	addq.w	#1,d3
.geen060Plus:
	mulu.w	(EFontSize_y-DT,a4),d3
	add.w	(Win_BorVerT-DT,a4),d3
	addq.w	#6,d3	;marge

;	move.w	#6+22*FontSize_y+titlesize,d3	;h

	move.w	(EFontSize_x-DT,a4),d4
	lsl.w	#3,d4		; 8 letters

	move.b	(debug_FPregs-DT,a4),(db_type-DT,a4)
	beq.s	.sizeit

	sub.w	d4,d0
	add.w	d4,d2
	bra.b	.si2
.sizeit:
	add.w	d4,d0
.si2:
	jsr	_LVOChangeWindowBox(a6)

;ff wachten tot resize is gedaan...

	move.l	4.w,a6
.niet_klaar:
	move.l	(debug_msg_port-DT,a4),a0
	jsr	_LVOGetMsg(a6)
	tst.l	d0
	bne.s	.teste

	move.l	(debug_msg_port-DT,a4),a0
	jsr	_LVOWaitPort(a6)
	bra.b	.niet_klaar

;nog testen op newsize
.teste:
	move.l	d0,a5
	move.l	d0,a1
	jsr	_LVOReplyMsg(a6)

	moveq	#NEWSIZE,d0
	and.l	(im_Class,a5),d0
	beq.s	.niet_klaar	;wachten tot newsize..	

	bsr	drukdata_regs

	bsr.b	teken_logootje_enzo

.klaar:
	move.l	(debug_winbase-DT,a4),a0
	move.l	(KEY_PORT-DT,a4),(wd_UserPort,a0)

.isdicht:
	movem.l	(sp)+,d0-a6
	rts


teken_logootje_enzo:
;	jsr	test2
	move.l	(debug_winbase-DT,a4),a0

	moveq	#0,d2
	move.b	(wd_BorderLeft,a0),d2
	add.b	(wd_BorderRight,a0),d2

	moveq	#0,d3
	move.b	(wd_BorderTop,a0),d3
	add.b	(wd_BorderBottom,a0),d3

	movem.w	(wd_Width,a0),d4/d5	; width, height
	sub.w	d2,d4
	sub.w	d3,d5

;	move.w	(Win_BorVer-DT,a4),d4

	move.l	(GfxBase-DT,a4),a6
	move.l	(debug_rp-DT,a4),a1

	move.w	d4,d0		;xmin

	tst.b	(db_type-DT,a4)
	beq.s	.xxx

	move.w	(EFontSize_x-DT,a4),d6
	lsl.w	#3,d6		; 8 letters

	sub.w	d6,d0
.xxx:
	subq.w	#2,d0
	clr.w	d1		;ymin
	move.w	d0,d2		;xmax
	addq.w	#2,d2
	move.w	d5,d3		;ymax

	jsr	_LVOEraseRect(a6)


	move.l	(GadToolsBase-DT,a4),a6

	move.l	(debug_rp-DT,a4),a0
	lea	(PW_NR,pc),a1
	move.l	(MainVisualInfo-DT,a4),PW_NR+4-PW_NR(a1)
	move.l	(MainVisualInfo-DT,a4),PW_IR+4-PW_NR(a1)
	clr.w	d0		;x
	clr.w	d1		;y
	move.w	d4,d2
	move.w	d5,d3
	jsr	_LVODrawBevelBoxA(a6)

	tst.b	(db_type-DT,a4)
	IFEQ	SPEC_ED
	beq.w	.nomore
	ELSE
	beq.b	.nomore
	ENDIF

	moveq	#14,d4
	mulu.w	(EFontSize_x-DT,a4),d4
	move.w	(EFontSize_y-DT,a4),d5
	lsl.w	#3,d5		; 8 letters
	addq.w	#6,d5		;marge

	move.l	(debug_rp-DT,a4),a0
	lea	(PW_NR,pc),a1
	move.w	d4,d0		;x
	move.w	d5,d1		;y
	jsr	_LVODrawBevelBoxA(a6)

	subq.w	#1,d4
	subq.w	#1,d5

	move.l	(debug_rp-DT,a4),a0
	lea	(PW_IR,pc),a1
	move.w	d4,d0		;x
	move.w	d5,d1		;y
	jsr	_LVODrawBevelBoxA(a6)

	move.l	(GfxBase-DT,A4),a6
	move.l	(debug_rp-DT,a4),a1

	moveq	#2,d0
	jsr	_LVOSetAPen(a6)

	addq.w	#3,d4
	addq.w	#3,d5

	move.w	d4,d0		;x
	move.w	d5,d1		;y
	subq.w	#3,d2
	subq.w	#3,d3
	jsr	_LVORectFill(a6)

	IFEQ	SPEC_ED
	move.w	(EFontSize_x-DT,a4),d0
	lsl.w	#3,d0	;8 letters
	moveq	#15,d1
	mulu.w	(EFontSize_y-DT,a4),d1

	sub.w	(db_imagestr+ig_Width,pc),d0
	bpl.s	.nix1
	moveq	#0,d0
.nix1
	sub.w	(db_imagestr+ig_Height,pc),d1
	bpl.s	.nix2
	moveq	#0,d1
.nix2:
	lsr.w	#1,d0
	lsr.w	#1,d1

	add.w	d4,d0		; x
	add.w	d5,d1		; y

	move.l	(debug_rp-DT,a4),a0
	move.l	(IntBase-DT,a4),a6
	lea	db_imagestr(pc),a1
;	move.w	d4,d0	;x-offset
;	move.w	d5,d1	;y-offset
	jsr	(_LVODrawImage,a6)
	ENDIF
.nomore:
	rts


open_debug_win:
	bsr	close_debug_win		;voor de zekerheid..

	movem.l	d0-a6,-(sp)
	lea	(dw_x+4,pc),a2

	move.l	(a2),d0
	bne.s	.algoed
	move.l	(BreedteScherm).l,d0

	moveq	#13,d1
	mulu.w	(EFontSize_x-DT,a4),d1
	add.w	(Win_BorHor-DT,a4),d1
	addq.w	#6,d1		;marge

	sub.l	d1,d0
	moveq	#16,d4		;16 puntjes van de linker kant
	sub.l	d4,d0
	move.l	d0,(a2)

	move.l	d1,(dw_br-dw_x,a2)

	moveq	#23,d1
	cmp.w	#PB_060,(ProcessorType-DT,a4)
	blo.s	.geen060Plus
	addq.w	#1,d1		; extra line for pcr
.geen060Plus:
	mulu.w	(EFontSize_y-DT,a4),d1
	add.w	(Win_BorVerT-DT,a4),d1
	addq.w	#6,d1		;marge
	move.l	d1,(dw_hg-dw_x,a2)

	tst.b	(debug_FPregs-DT,a4)
	beq.s	.nono

	moveq	#6,d1
	mulu.w	(EFontSize_x-DT,a4),d1

	sub.l	d1,d0
	move.l	d0,(a2)
	add.l	d0,(dw_br-dw_x,a2)

.algoed:
.nono:
	move.l	ScreenBase,(Debug_SC-dw_x,a2)
	move.l	(IntBase-DT,a4),a6
	sub.l	a0,a0
	lea	(Debug_WindowTags,pc),a1
	jsr	_LVOOpenWindowTagList(a6)
	move.l	d0,(debug_winbase-DT,a4)

	move.l	d0,a0
	move.l	(wd_RPort,a0),(debug_rp-DT,a4)
	move.l	(wd_UserPort,a0),(debug_msg_port-DT,a4)

	bsr	teken_logootje_enzo


	move.l	(debug_winbase-DT,a4),a0
	move.l	(KEY_PORT-DT,a4),(wd_UserPort,a0)

	move.l	(IntBase-DT,a4),a6
	move.l	(MainWindowHandle-DT,a4),a0
	jsr	(_LVOActivateWindow,a6)

;	canvaswin->UserPort = userport

	bsr.b	drukdata_regs
	bsr.b	druk_regs

	movem.l	(sp)+,d0-a6
	rts


Debug_check_msg:
	movem.l	d0-a6,-(sp)

	move.l	d0,a0		;Msg
	movem.l	(im_Class,a0),d0/d1	;class, code+qualifer

	and.l	#IDCMP_MOUSEBUTTONS|IDCMP_ACTIVEWINDOW,d0 ;40208 |IDCMP_CLOSEWINDOW
	beq.s	.NoMsgInBase

;	move.l	d0,d3
;	and.l	#IDCMP_CLOSEWINDOW,d3
;	beq.s	.noclose
;	bsr	close_debug_win
;	bra.b	.NoMsgInBase
;.noclose:

	cmp.l	#IEQUALIFIER_RELATIVEMOUSE,d1	; $8000, mouse up?
	beq.s	.NoMsgInBase

	move.l	(IntBase-DT,a4),a6
	move.l	(MainWindowHandle-DT,a4),a0
	jsr	(_LVOActivateWindow,a6)
.NoMsgInBase:
	movem.l	(sp)+,d0-a6

drukdata_regs_end:
	rts


drukdata_regs:
	move.l	(debug_winbase-DT,a4),d0
	beq.b	drukdata_regs_end
	tst.b	(debug_FPregs-DT,a4)
	beq.b	drukDx_regs
	bra.b	drukFP_regs

druk_regs:
	move.l	(IntBase-DT,a4),a6
	lea	Debug_IText(pc),a5
	moveq	#23-1-8,d7

	cmp.w	#PB_060,(ProcessorType-DT,a4)
	blo.s	.geen060Plus
	addq	#1,d7		;voor PCR reg
.geen060Plus:

	move.w	(EFontSize_y-DT,a4),d6
	lsl.w	#3,d6		; skip 8 rows
.lopje:
	moveq	#0,d0		;left
	move.w	d6,d1		;top
	move.l	(debug_rp-DT,a4),a0	;rp
	lea	(Debug_Text,pc),a1	;itext
	move.l	a5,(debtxt-Debug_Text,a1)
	jsr	_LVOPrintIText(a6)

	lea	14(a5),a5
	add.w	(EFontSize_y-DT,a4),d6

	dbf	d7,.lopje
	rts


drukDx_regs:
	move.l	(IntBase-DT,a4),a6
	lea	DebugDx_IText(pc),a5

	moveq	#8-1,d7
	moveq	#0,d6
.lopje:
	moveq	#0,d0		;left
	move.w	d6,d1		;top
	move.l	(debug_rp-DT,a4),a0	;rp
	lea	(Debug_Text,pc),a1	;itext
	move.l	a5,(debtxt-Debug_Text,a1)
	jsr	_LVOPrintIText(a6)

	lea	14(a5),a5
	add.w	(EFontSize_y-DT,a4),d6

	dbf	d7,.lopje
	rts

drukFP_regs:
	move.l	(IntBase-DT,a4),a6
	lea	DebugFP_IText(pc),a5

	moveq	#8-1,d7
	moveq	#0,d6
.lopje:
	moveq	#0,d0		;left
	move.w	d6,d1		;top
	move.l	(debug_rp-DT,a4),a0	;rp
	lea	(Debug_Text,pc),a1	;itext
	move.l	a5,(debtxt-Debug_Text,a1)
	jsr	_LVOPrintIText(a6)

	lea	20(a5),a5
	add.w	(EFontSize_y-DT,a4),d6

	dbf	d7,.lopje
	rts


close_debug_win:
	movem.l	d0-a6,-(sp)

;	jsr	test1

	move.l	(debug_winbase-DT,a4),d0
	beq.s	.aldicht
	move.l	d0,a0

	lea	(dw_x+6,pc),a1
	move.w	(wd_LeftEdge,a0),(a1)
	move.w	(wd_TopEdge,a0),(dw_y-dw_x,a1)
	move.w	(wd_Width,a0),(dw_br-dw_x,a1)
;	move.w	(wd_Height,a0),(dw_hg-dw_x,a1)

	move.l	(debug_msg_port-DT,a4),(wd_UserPort,a0)

	move.l	(IntBase-DT,a4),a6
	jsr	_LVOCloseWindow(a6)
	clr.l	(debug_winbase-DT,a4)
.aldicht:
	movem.l	(sp)+,d0-a6
	rts

;*********** output windowtje *****************
;
;Output_WindowTags:
;	DC.L	WA_Left,0		;x
;	DC.L	WA_Top,480-80	;y
;	DC.L	WA_Width,640	;br
;	DC.L	WA_Height,50	;hg
;	DC.L	WA_IDCMP,$00200074		;idcmp
;	DC.L	WA_Flags,$00000004|2	;flags
;	DC.L	WA_Title,Output_WTitle
;Output_SC:
;	DC.L	$80000079,0
;	DC.L	$00000000
;
;Output_WTitle:
;	DC.B	'Debug output windowtje..',0
;	CNOP	0,2
;
;
;	cnop	0,4
;output_winbase:	dc.l	0
;output_rp:	dc.l	0
;
;open_output_win:
;	movem.l	d0-a6,-(sp)
;	move.l	ScreenBase,Output_SC+4
;	move.l	(IntBase-DT,a4),a6
;	sub.l	a0,a0
;	lea	(Output_WindowTags,pc),a1
;	jsr	_LVOOpenWindowTagList(a6)
;	move.l	d0,output_winbase
;
;	move.l	d0,a0
;	move.l	(wd_RPort,a0),output_rp
;
;	move.l	(MainWindowHandle-DT,a4),a0
;	jsr	-450(a6)	;activate window
;
;	movem.l	(sp)+,d0-a6
;	rts
;
;close_output_win:
;	movem.l	d0-a6,-(sp)
;	move.l	(IntBase-DT,a4),a6
; 	lea	(output_winbase,pc),a2
; 	move.l	(a2),d0
;	beq.s	.aldicht
; 	move.l	d0,a0
;	jsr	_LVOCloseWindow(a6)
;	clr.l	(a2)
;.aldicht:
;	movem.l	(sp)+,d0-a6
;	rts
;
;*********** druk breaks en watches ***********

show_breaks_watches:
	movem.l	a0-a3,-(sp)
	move.l	(Cursor_pos-DT,a4),-(sp) ; col, row
	clr	(Cursor_col_pos-DT,a4)
	bsr.w	_Show_Cursor
	lea	(status_line_txt,pc),a0
	bsr	druk_status_en_end_af

	btst	#0,(PR_NoDisasm).l
	beq.b	skip_disassembl

	movem.l	d0/a0-a3,-(sp)

	bsr	druk_cr_nl

	move.l	(pcounter_base-DT,a4),d0
	move.l	d0,a5
	cmp.l	#eop_irq_routine,d0
	beq.b	.eop_hier
	bsr	druk_af_d0		;print pc
	bsr	druk_af_space
	bsr	C1588E
	jsr	(DISASSEMBLE_A5_PRINT)
	bsr	printthetext

;	movem.l	(sp)+,d0/a0-a3
;	movem.l	(sp)+,a0-a3
;	rts

	bra.b	C1A59C

.eop_hier:
	bsr	C1588E
C1A59C:
	movem.l	(sp)+,d0/a0-a3
skip_disassembl:
	lea	(watch_table_name-DT,a4),a0
	lea	(watch_table_addr-DT,a4),a1
	lea	(watch_table_type-DT,a4),a2
	moveq	#7,d0
C1A5AE:
	tst.b	(a0)
	beq.b	no_watchps
	bsr	show_wps
no_watchps:
	lea	(16,a0),a0
	addq.w	#4,a1
	addq.w	#1,a2
	dbra	d0,C1A5AE
	lea	(L1A3F4-DT,a4),a0
	lea	(L1A4F4-DT,a4),a1
	lea	(L1A534-DT,a4),a2
	moveq	#7,d0
C1A5D0:
	tst.b	($0080,a0)
	beq.b	C1A5DA
	bsr	C1A6A4
C1A5DA:
	lea	(16,a0),a0
	addq.w	#4,a1
	addq.w	#1,a2
	dbra	d0,C1A5D0
	bsr.w	Druk_Clearbuffer
	bsr.w	_Show_Cursor
	move.l	(sp)+,(Cursor_pos-DT,a4) ; col, row
	movem.l	(sp)+,a0-a3
	rts

C1A5FE:
	movem.l	d1-d7/a0-a6,-(sp)
	lea	(L1A3F4-DT,a4),a0
	lea	(L1A4F4-DT,a4),a1
	lea	(L1A534-DT,a4),a2
	moveq	#7,d7
.C1A610
	tst.b	($0080,a0)
	beq.b	.C1A61C
	bsr.b	C1A630
	tst.b	d0
	bne.b	.C1A62A
.C1A61C
	lea	(16,a0),a0
	addq.w	#4,a1
	addq.w	#1,a2
	dbra	d7,.C1A610
	moveq	#0,d0
.C1A62A
	movem.l	(sp)+,d1-d7/a0-a6
	rts

C1A630:
	move.l	a0,a6
	tst.b	(a2)
	bpl.b	C1A63E
	jsr	(Convert_A2I).l
	move.l	d0,(a1)
C1A63E:
	move.l	(a1),d3
	lea	($0080,a0),a6
	tst.b	(8,a2)
	bpl.b	C1A654
	jsr	(Convert_A2I).l
	move.l	d0,($0020,a1)
C1A654:
	move.l	($0020,a1),d1
	moveq	#7,d0
	and.b	(a2),d0
	lsl.w	#2,d0
	cmp.l	d1,d3
	jmp	(C1A676,pc,d0.w)

C1A676:
	slt	d0
	rts

	sle	d0
	rts

	seq	d0
	rts

	sge	d0
	rts

	sgt	d0
	rts

	sne	d0
	rts

C1A6A4:
	movem.l	d0/a0-a3,-(sp)
	bsr	druk_cr_nl
	moveq	#$43,d0
	bsr	SENDONECHARNORMAL
	moveq	#$42,d0
	bsr	SENDONECHARNORMAL
	moveq	#$50,d0
	bsr	SENDONECHARNORMAL
	moveq	#$BB-256,d0
	bsr	SENDONECHARNORMAL
	move.l	a0,a6
	moveq	#11,d1
C1A6D0:
	move.b	(a0)+,d0
	beq.b	C1A6DE
	bsr	SENDONECHARNORMAL
	dbra	d1,C1A6D0
	moveq	#0,d1
C1A6DE:
	bsr.w	druk_af_space
	dbra	d1,C1A6DE
	tst.b	(a2)
	bpl.b	C1A6F8
	jsr	(Convert_A2I).l
	beq.b	C1A790
	move.l	d0,(a1)
C1A6F8:
	bsr.b	Dbg_HandleCondOption
	moveq	#7,d0		; only 6 options
	and.b	(a2),d0
	add	d0,d0
	lea	(DbgConditions.MSG,pc),a0
	add.w	d0,a0
	move.b	(a0)+,d0
	bsr	SENDONECHARNORMAL
	move.b	(a0)+,d0
	bsr	SENDONECHARNORMAL
	bsr.w	druk_af_space
	bsr.w	druk_af_space
	movem.l	(sp),d0/a0-a3
	lea	($0080,a0),a0
	lea	($0020,a1),a1
	addq.l	#8,a2
	move.l	a0,a6
	moveq	#11,d1
C1A750:
	move.b	(a0)+,d0
	beq.b	C1A75E
	bsr	SENDONECHARNORMAL
	dbra	d1,C1A750
	moveq	#0,d1
C1A75E:
	bsr.w	druk_af_space
	dbra	d1,C1A75E
	tst.b	(a2)
	bpl.b	C1A776
	jsr	(Convert_A2I).l
	beq.b	C1A790
	move.l	d0,(a1)
C1A776:
	bsr.b	Dbg_HandleCondOption
C1A790:
	bsr	C1529A
	movem.l	(sp)+,d0/a0-a3
	rts

Dbg_HandleCondOption:
	move.l	(a1),a1
	moveq	#$70,d0
	and.b	(a2),d0
	lsr.w	#4,d0
	add	d0,d0
	lea	(W1A80E,pc,d0.w),a0
	add	(a0),a0
	jsr	(a0)
	move.l	a1,d0
	bra	druk_af_d0_space

DbgConditions.MSG:
	DC.W	' <','<=',' =','>=',' >','<>'

show_wps:	;watchpoints afdrukken
	movem.l	d0/a0-a3,-(sp)
	bsr	druk_cr_nl
	move.l	a0,a6
	moveq	#15,d1
C1A7B4:
	move.b	(a0)+,d0
	beq.b	C1A7C2
	bsr	SENDONECHARNORMAL
	dbra	d1,C1A7B4
	moveq	#0,d1
C1A7C2:
	bsr.w	druk_af_space
	dbra	d1,C1A7C2
	tst.b	(a2)
	bpl.b	C1A7DA
	jsr	(Convert_A2I).l
	beq.b	C1A804
	move.l	d0,(a1)
C1A7DA:
	bsr.b	Dbg_HandleCondOption
	moveq	#15,d0
	and.b	(a2),d0
	add	d0,d0
	lea	(W1A82E,pc,d0.w),a0
	add	(a0),a0
	jsr	(a0)
C1A804:
	bsr	C1529A
	movem.l	(sp)+,d0/a0-a3
	rts

W1A80E:
	dc.w	C1A820-*
	dc.w	C1A81E-*
	dc.w	C1A822-*
	dc.w	C1A826-*
	dc.w	C1A82A-*
	dc.w	C1A820-*
	dc.w	C1A820-*
	dc.w	C1A820-*

C1A81E:
	move.l	(a1),a1
C1A820:
	rts

C1A822:
	move	(a1),a1
	rts

C1A826:
	add.l	(a1),a1
	rts

C1A82A:
	add	(a1),a1
	rts

W1A82E:
	dc.w	C1A8A0-*
	dc.w	C1A878-*
	dc.w	C1A860-*
	dc.w	C1A84C-*
	dc.w	C1A838-*

C1A838:
	IF	MC020
	move.l	(a1)+,d1
	ELSE
	move.b	(a1)+,d1
	lsl.w	#8,d1
	move.b	(a1)+,d1
	swap	d1
	move.b	(a1)+,d1
	lsl.w	#8,d1
	move.b	(a1)+,d1
	ENDIF
	bra	Print_D0_Binary

C1A84C:
	moveq	#3,d5
C1A84E:
	moveq	#0,d0
	IF	MC020
	move.w	(a1)+,d0
	ELSE
	move.b	(a1)+,d0
	lsl.w	#8,d0
	move.b	(a1)+,d0
	ENDIF
	bsr	PRINTDECIMALSIGN
	dbra	d5,C1A84E
	rts

C1A860:
	moveq	#7,d2
C1A862:
	move.b	(a1)+,d0
	bsr	C15908
	move.b	(a1)+,d0
	bsr	C15908
	bsr	druk_af_space
	dbra	d2,C1A862
	rts

C1A878:
	moveq	#'"',d0
	bsr	SENDONECHARNORMAL
	moveq	#$27,d2
.C1A880
	move.b	(a1)+,d0
	beq.b	.C1A89A
	moveq	#$7f,d1
	and.b	d0,d1
	cmp.b	#' ',d1
	bcc.b	.C1A892
	moveq	#'.',d0
.C1A892	bsr	SENDONECHARNORMAL
	dbra	d2,.C1A880
.C1A89A:
	moveq	#'"',d0
	br	SENDONECHARNORMAL

C1A8A0:
	moveq	#'"',d0
	bsr	SENDONECHARNORMAL
	moveq	#$27,d2
.C1A8A8
	move.b	(a1)+,d0
	moveq	#$7f,d1
	and.b	d0,d1
	cmp.b	#' ',d1
	bcc.b	.ok
	moveq	#'.',d0
.ok	bsr	SENDONECHARNORMAL
	dbra	d2,.C1A8A8
	moveq	#'"',d0
	br	SENDONECHARNORMAL

;********************************
;*	  Single Step		*
;********************************

DEBUG_SINGLE_STEP:
	move.l	(pcounter_base-DT,a4),a5
	jsr	(DISLENGTH_A5).l
	tst.b	d2		; DF_xxx flags
	beq.b	.C1A8D4
	lsr.b	#1,d2		; DF_Stack?
	bcs.b	DEBUG_STACK_BREAKPOINT
	lsr.b	#1,d2		; DF_Single?
	bcs.b	DEBUG_ENTER_SINGLE_STEP
.C1A8D4
	move.l	a5,a1
	br	DEBUG_ADD_AND_JUMP

DEBUG_ENTER_SINGLE_STEP:
	moveq	#1,d0
	br	com_singlestep

DEBUG_STACK_BREAKPOINT:
	move.l	(SSP_base-DT,a4),a1
	btst	#13-8,(statusreg_base-DT,a4)
	bne.b	.in_sv
	move.l	(USP_base-DT,a4),a1
.in_sv	move.l	(a1),a1
	br	DEBUG_ADD_AND_JUMP

;********************************
;*	  Exit debugger		*
;********************************

DEBUG_KEYP_EXIT_AGAIN:
	bsr	KEY_RETURN_LAST_KEY
Debug_QuitTrace:
	bsr	close_debug_win

	btst	#0,(PR_ShowSource).l
	bne.b	C1A912
	bsr.w	_Show_Cursor
C1A912:
	bsr.b	C1A91A
	jmp	(CommandlineInputHandler).l

C1A91A:
	bclr	#SB2_INDEBUGMODE,(SomeBits2-DT,a4)
DEBUG_OFF_2:
	jsr	(Change2Commmenu)
	bsr.w	Druk_Clearbuffer
	bsr.w	_Show_Cursor
	lea	(End_msg,pc),a0
	bra	druk_status_en_end_af

_druk_af_debug_regs:
	bra	druk_af_debug_regs

DEBUG_FIND_ADDRESS:
	move.l	(pcounter_base-DT,a4),d0
	move.l	(DEBUG_END-DT,a4),a1
	move.l	(LabelEnd-DT,a4),a0
	move.l	a1,d1
	sub.l	a0,d1
	lsr.l	#2,d1
C1A960:
	subq.l	#8,d1
	bmi.b	C1A98E
	cmp.l	-(a1),d0
	beq.b	C1A984
	cmp.l	-(a1),d0
	beq.b	C1A984
	cmp.l	-(a1),d0
	beq.b	C1A984
	cmp.l	-(a1),d0
	beq.b	C1A984
	cmp.l	-(a1),d0
	beq.b	C1A984
	cmp.l	-(a1),d0
	beq.b	C1A984
	cmp.l	-(a1),d0
	beq.b	C1A984
	cmp.l	-(a1),d0
	bne.b	C1A960
C1A984:
	sub.l	a0,a1
	move.l	a1,d0
	lsr.l	#2,d0
	addq.l	#1,d0
	rts

C1A98E:
	addq.w	#7,d1
	bmi.b	C1A99A
C1A992:
	cmp.l	-(a1),d0
	beq.b	C1A984
	dbra	d1,C1A992
C1A99A:
	cmp.l	#eop_irq_routine,d0
	beq.b	C1A9AE
	lea	(Addressnotfou.MSG,pc),a0
	bsr	printTextInMenuStrip
	moveq	#0,d0
	rts

C1A9AE:
	lea	(Endofprogramr.MSG,pc),a0
	bsr	printTextInMenuStrip
	sf	(Animate-DT,a4)
	moveq	#0,d0
	rts

DEBUG_JUMPTOLINE:
	move.l	(TraceLinePtr-DT,a4),a2
	move.l	a2,(FirstLinePtr-DT,a4)
	move.l	a2,a3
	move.l	(TraceLineNr-DT,a4),(FirstLineNr-DT,a4)
	move.l	d0,-(sp)
	jsr	(RegTab_SETALLNOTUPD).l
	move.l	(sp)+,d0
	jmp	JUMPTOLINE

;d0 steps to go

com_singlestep:
	move	d0,(SST_STEPS-DT,a4)
	move.l	(pcounter_base-DT,a4),a1
	move	(a1)+,d0
	and	#$FFF0,d0
	cmp	#$4E40,d0
	beq.b	DEBUG_ADD_AND_JUMP
	tst	(FPU_Type-DT,a4)
	beq.b	.C1AA04
	cmp	#$F200,d0
	bge.b	.C1AA0A
	and	#$F000,d0
.C1AA04:
	cmp	#$F000,d0
	beq.b	DEBUG_ADD_AND_JUMP
.C1AA0A:
	cmp	#$A000,d0
	beq.b	DEBUG_ADD_AND_JUMP
	bset	#15-8,(statusreg_base-DT,a4)	; trace flag
	move.l	(USP_base-DT,a4),a0
	br	DEBUG_JUMP_TO_PROGCOUNT

;*******************************
;*   Set BP and jump to addr   *
;*******************************

DEBUG_ADD_AND_JUMP:
	bsr.b	DEBUG_ADD_BRKPT
	br	DEBUG_NO_BREAK_PT

;*************************
;*    Set Break Point    *
;*************************

; A1 = Break point to set

DEBUG_ADD_BRKPT:
	lea	(BREAKPTBUFFER-DT,a4),a5
	moveq	#16-1,d5
.lopje:
	tst.l	(a5)
	beq.b	.empty
	addq.l	#6,a5
	dbra	d5,.lopje
	subq.l	#6,a5
.empty:
	move.l	a1,(a5)+
	move	(a1),(a5)+
	rts

DEBUG_CLEAR_BP_BUFFER:
	lea	(BREAKPTBUFFER-DT,a4),a5
	moveq	#MAX_BRK_PTRS-1,d5
.lopje:
	clr.l	(a5)+
	clr	(a5)+
	dbra	d5,.lopje
	rts

DEBUG_REMOVE_CURRENT_BPS:
	lea	(BREAKPTBUFFER-DT,a4),a5
	moveq	#MAX_BRK_PTRS-1,d5
.NEXT_POINT:
	move.l	(a5)+,d6
	beq.b	.NO_REMOVE
	cmp.l	d0,d6
	bne.b	.NOTTHISBREAK
	clr.l	(-4,a5)
	bset	#7,(DATA_EXCEPTIONNUMBER-DT,a4)
.NOTTHISBREAK:
	move.l	d6,a6
	cmp	#$4AFC,(a6)
	bne.b	.NO_REMOVE
	move	(a5),(a6)
.NO_REMOVE:
	addq.w	#2,a5
	dbra	d5,.NEXT_POINT
	rts

DEBUG_SET_ALL_CURRENT_BPS:
	lea	(BREAKPTBUFFER-DT,a4),a5
	moveq	#MAX_BRK_PTRS-1,d5
.NEXT_POINT:
	move.l	(a5)+,d6
	beq.b	.NO_SET
	move.l	d6,a6
	move	(a6),(a5)
	move	#$4AFC,(a6)	;illegal
.NO_SET:
	addq.w	#2,a5
	dbra	d5,.NEXT_POINT
	rts

; Go command
com_Go:
	movem.l	d0-a6,-(a7)				; auto update
	tst.b	(PR_AutoUpdate).l
	beq.s	.noForceUpdate
	bsr.w	com_update
.noForceUpdate:
	movem.l	(a7)+,d0-a6
	cmp.b	#NS_AVALUE,d1
	bne.b	.NO_ADDR
	move.l	d0,(pcounter_base-DT,a4)
.NO_ADDR:
	bsr.b	DEBUG_CLEAR_BP_BUFFER
.LOOP1:
	lea	(BREAKPOINT.MSG,pc),a0
	bsr	INPUTTEXT
	bsr	INPUTWORKSPACE_NOTEXT
	bne.b	DEBUG_NO_BREAK_PT2
	move.l	d0,a1
	bsr	DEBUG_ADD_BRKPT
	bra.b	.LOOP1

DEBUG_NO_BREAK_PT2:
	bsr	SetProgramParams
DEBUG_NO_BREAK_PT:
	move.l	(USP_base-DT,a4),a0
DEBUG_JUMP_TO_PROGCOUNT_NO_TRACE:
	bclr	#15-8,(statusreg_base-DT,a4)	; trace flag
DEBUG_JUMP_TO_PROGCOUNT:
	bsr.b	DEBUG_SET_ALL_CURRENT_BPS
	bsr	INITRESCUE
	clr.l	(MEMDIR_BUFFER-DT,a4)
PRIVILIGE_VIOL2:
	move.l	(4).w,a6
	move.w	(IDNestCnt,a6),(IntDisableCnt-DT,a4) ; IDNestCnt and TDNestCnt!
	lea	(C1AAE2,pc),a5
	jsr	(_LVOSupervisor,a6)	; keep as jsr (return address must be on stack)!
C1AAE0:
	rts

C1AAE2:
	move.l	a0,usp
	move.l	(4).w,a6
	jsr	(_LVOCacheClearU,a6)
	move.l	(GfxBase-DT,a4),a6
	move.l	(34,a6),(SysActiveView-DT,a4)	; gb_ActiView
	btst	#SB2_INDEBUGMODE,(SomeBits2-DT,a4)
	bne.b	.noWB2Front
	tst.b	(PR_WBFront).l
	beq.b	.noWB2Front

;	lea	(Workbench.MSG).l,a0
	move.l	(IntBase-DT,a4),a6
;	jsr	(_LVOLockPubScreen,a6)
;	move.l	d0,(WBScreen-DT,a4)
;	tst.l	d0
;	beq.b	.noWB2Front
;	move.l	d0,a0
;	move.l	(IntBase-DT,a4),a6
;	jsr	(_LVOScreenToFront,a6)

	jsr	_LVOWBenchToFront(a6)

.noWB2Front:
	lea	(.C1AB40,pc),a5
	move.l	(4).w,a6
	jsr	(_LVOSupervisor,a6)
	movem.l	d0-d7/a0-a6,(DataRegsStore)
	lea	(Variable_base),a4
	rts

.C1AB40	tst	(FPU_Type-DT,a4)
	beq.b	.NoFpu
	fmovem.x	(FpuRegsStore-DT,a4),fp0-fp7
	fmovem	(fpu_1-DT,a4),fpcr/fpsr/fpiar
.NoFpu:
	move.l	(pcounter_base-DT,a4),-(sp)
	move	(statusreg_base-DT,a4),-(sp)
	movem.l	(DataRegsStore-DT,a4),d0-d7/a0-a6
	rte					; resume debugged program

SetProgramParams:
	btst	#0,(PR_params).l
	beq.b	.C1AB86
	tst.b	(Parameters-DT,a4)
	beq.b	.C1AB86
	pea	(Parameters-DT,a4)
	move.l	(sp)+,(AdresRegsStore-DT,a4)			; set initial a0
	move.l	(ParametersLengte-DT,a4),(DataRegsStore-DT,a4)	; set initial d0
.C1AB86
	rts

; Jump command
com_jump:
	movem.l	d0-a6,-(a7)			; auto update stuff
	tst.b	(PR_AutoUpdate).l
	beq.s	.noForceUpdate
	bsr.w	com_update			
.noForceUpdate:
	movem.l	(a7)+,d0-a6			
	cmp.b	#NS_AVALUE,d1				
	bne.b	.NO_ADDR
	move.l	d0,(pcounter_base-DT,a4)
.NO_ADDR:
	move	#1,(AssmblrStatus-DT,a4)
	bsr.w	InitProgramStacks
	bsr.b	SetProgramParams
	br	DEBUG_JUMP_TO_PROGCOUNT_NO_TRACE

INITRESCUE:
	movem.l	d0/a0/a1/a6,-(sp)
	btst	#0,(PR_Rescue).l
	beq	C1AC60

;---  Get copper list  ---

	move.l	(GfxBase-DT,a4),a1
	move.l	($0026,a1),(Copperlist1-DT,a4)
	move.l	($0032,a1),(Copperlist2-DT,a4)

;---  Get DMA settings  ---

	lea	$DFF000,a6
	move	($001C,a6),(GEMINT-DT,a4)
	move	(2,a6),(GEMDMA-DT,a4)
	move	($0010,a6),(GEMDISK-DT,a4)

	bsr	SYS_GetVBR
	lea	(RESCUEPTRS-DT,a4),a0
	exg	a0,a1
	addq.w	#8,a0
	moveq	#30-1,d0
.ptrlopje:
	move.l	(a0)+,(a1)+
	dbra	d0,.ptrlopje

	move.l	#$2000,d0
	move.l	#$2B00,d1
	move.l	(4).w,a6
	jsr	(_LVOCacheControl,a6)
	move.l	d0,-(sp)
	bsr	SYS_GetVBR
	addq.w	#8,a1
	lea	(EXCEPTIONOFFSETS,pc),a0
	move.l	(a1),(8,a0)
	move.l	a0,(a1)+
	lea	(12,a0),a0
	move.l	(a1),(8,a0)
	move.l	a0,(a1)+
	lea	(12,a0),a0
	moveq	#7,d0
C1AC42:
	move.l	(a1),(6,a0)
	move.l	a0,(a1)+
	lea	(10,a0),a0
	dbra	d0,C1AC42
	move.l	(sp)+,d0
	move.l	#$00002B00,d1
	move.l	(4).w,a6
	jsr	(_LVOCacheControl,a6)
C1AC60:
	btst	#0,(PR_Level7).l
	beq.b	C1AC7E
	bsr	SYS_GetVBR
	lea	(RESCUEPTRS_Last-DT,a4),a0
	move.l	($007C,a1),(a0)
	lea	(LEVEL7RESCUE,pc),a0
	move.l	a0,($007C,a1)
C1AC7E:
	movem.l	(sp)+,d0/a0/a1/a6
	rts

; DO NOT RELY ON A4 BASEREG IN THIS ROUTINE
LEVEL7RESCUE:
	link	a6,#4-6			; same frame size as int7 (6b), atomic!
	sub.l	a6,a6			; a6 less likely to have a "bad" value
	tst.w	(ProcessorType)		;  since we are generating a fake frame
	beq.b	.NoVBR
	movec	vbr,a6
.NoVBR	move.l	#.Exit,($7C,a6)		; set vector to rte
	move.l	(2,sp),a6		; vector changed, restore a6
	addq.l	#6,sp			; atomic increment
.Restored

.Rewind
	cmp.l	#LEVEL7RESCUE,(2,sp)
	blo.b	.AllOK			; not us
	beq.b	.NextFrame		; we haven't started, a6 still intact
	cmp.l	#.Restored,(2,sp)
	bhs.b	.FrameOK		; not relevant
	move.l	(2,sp),a6		; restore a6 since we were interrupted
.NextFrame
	addq.l	#6,sp
	bra.b	.Rewind
.FrameOK
	cmp.l	#.Danger1,(2,sp)	; in case a fresh NMI occurred while we
	beq.b	.FixStack		;  were restoring the vector and before
	cmp.l	#.Danger2,(2,sp)	;  unstacking a1
	bne.b	.AllOK
.FixStack
	move.l	(6,sp),a1		; restore a1 since we were interrupted,
	move.l	(2,sp),(6,sp)		;  and fix the stack (not doing any
	move.w	(sp),(4,sp)		;  predec/postinc black magic with sp)
	addq.l	#4,sp
.AllOK
	movem.l	d0-d7/a0-a6,(DataRegsStore)
	move.l	a1,-(sp)
	move.l	(4).w,a1
	move.l	(276,a1),a1		; ThisTask
	cmp.l	(DATA_TASKPTR),a1
	beq.b	.OurTask
	bsr.b	SYS_GetVBR
	move.l	#LEVEL7RESCUE,($7C,a1)
.Danger1
	move.l	(sp)+,a1
.Exit
	rte
.OurTask
	move.b	#$7F,(DATA_EXCEPTIONNUMBER).l
	bsr.b	SYS_GetVBR
	move.l	(RESCUEPTRS_Last),($7C,a1)
.Danger2
	move.l	(sp)+,a1
	bra.w	EXHA_GOINFROM7LEVEL


; DO NOT RELY ON A4 BASEREG IN THIS ROUTINE
SYS_GetVBR:
	sub.l	a1,a1
	tst	(ProcessorType).l
	beq.b	.mc68000
	movem.l	a5/a6,-(sp)
	lea	(.GetVBR,pc),a5
	move.l	(4).w,a6
	jsr	(_LVOSupervisor,a6)
	movem.l	(sp)+,a5/a6
.mc68000
	rts
.GetVBR
	movec	vbr,a1
	rte


; DO NOT RELY ON A4 BASEREG IN THIS ROUTINE
GORESCUE:
	move	#$7FFF,$DFF09A

.C1ACE6	btst	#0,($DFF005).l
	beq.b	.C1ACE6
.C1ACF0	btst	#0,($DFF005).l
	bne.b	.C1ACF0

	tst.l	(L2F118).l
	beq.b	.C1AD3C
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	a1,-(sp)
	bsr.b	SYS_GetVBR
	move.l	#LEVEL7RESCUE,($007C,a1)
	lea	(L2F118),a1
	move.l	(a1),a0
	clr.l	(a1)+
	move.l	a0,(a1)
	move.l	(sp)+,a1
	jsr	(a0)
	move.l	a1,-(sp)
	bsr.b	SYS_GetVBR
	move.l	(RESCUEPTRS_Last).l,($007C,a1)
	move.l	(sp)+,a1
	movem.l	(sp)+,d0-d7/a0-a6
.C1AD3C
	move.l	(L2F118+4),(L2F118)
	movem.l	d0/a0/a1/a6,(RESCUE_4REGS).l

	lea	($DFF000).l,a6
	move	(GEMDMA).l,d0
	or.w	#$8000,d0
	not.w	d0
	move	d0,($0096,a6)
	move	#$7FFF,($009E,a6)
	move.l	(Copperlist1),($0080,a6)
	move.l	(Copperlist2),($0084,a6)

	sub.l	a1,a1
	tst	(ProcessorType).l
	beq.b	.mc68000
	movec	vbr,a1
.mc68000:
	addq.w	#8,a1
	lea	(RESCUEPTRS).l,a0
	moveq	#30-1,d0
.C1AD98	move.l	(a0)+,(a1)+
	dbra	d0,.C1AD98

	move	(GEMDMA).l,d0
	or.w	#$8000,d0
	move	d0,($0096,a6)
	move	(GEMDISK).l,d0
	or.w	#$8000,d0
	move	d0,($009E,a6)
	move	(GEMINT).l,d0
	or.w	#$C000,d0
	move	#$7FFF,($009C,a6)
	move	d0,($009A,a6)
	movem.l	(RESCUE_4REGS).l,d0/a0/a1/a6
	rts


eop_irq_routine:
	illegal
	nop
RETURNINSUPERSTATE:
	move	#$2000,(sp)
	rte

EXCEPTIONOFFSETS:
	bclr	#5,(8,sp)
	jmp	(0).l

	bclr	#5,(8,sp)
	jmp	(0).l

	bclr	#5,(sp)
	jmp	(0).l

	bclr	#5,(sp)
	jmp	(0).l

	bclr	#5,(sp)
	jmp	(0).l

	bclr	#5,(sp)
	jmp	(0).l

	bclr	#5,(sp)
	jmp	(0).l

	bclr	#5,(sp)
	jmp	(0).l

	bclr	#5,(sp)
	jmp	(0).l

	bclr	#5,(sp)
	jmp	(0).l


; DO NOT RELY ON A4 BASEREG IN THIS ROUTINE
EXCEPTIONHANDLER_010:
	movem.l	d0/d1/a0,(EXHA_3Regs).l
	move	(8,sp),d0
	moveq	#7,d1
	and.w	d0,d1
	btst	#8,d0
	bne.b	.C1AEAE
	bset	#4,d1
.C1AEAE
	btst	#13,d0
	bne.b	.C1AEB8
	bset	#3,d1
.C1AEB8
	move	d1,(DATA_BUSACCESS).l
	move.l	($0036,sp),a0
	move.l	(a0),(DATA_BUSPTRHI).l
	move.l	(10,sp),a0
	move	(a0),(DATA_BUSFAILINST).l
	movem.l	(EXHA_3Regs).l,d0/d1/a0
	cmp.l	#C1AAE0,(10,sp)
	beq	RETURNINSUPERSTATE
	cmp.l	#CriticalError,(10,sp)
	beq	RETURNINSUPERSTATE
	btst	#0,(PR_Level7).l
	beq.b	.C1AF0C
	move.l	a1,-(sp)
	bsr	SYS_GetVBR
	move.l	(RESCUEPTRS_Last).l,($007C,a1)
	move.l	(sp)+,a1
.C1AF0C
	btst	#0,(PR_Rescue).l
	beq.b	.C1AF1A
	bsr	GORESCUE
.C1AF1A
	move.w	(sp)+,(statusreg_base)
	move.l	(sp)+,(pcounter_base)
	lea	($3A-6,sp),sp
	br	EXHA_COMMON_PART

; DO NOT RELY ON A4 BASEREG IN THIS ROUTINE
EXCEPTIONHANDLER_020:
	movem.l	d0/d1/a0,(EXHA_3Regs).l
	move	(10,sp),d0
	moveq	#7,d1
	and.w	d0,d1
	btst	#8,d0
	bne.b	.C1AF4E
	bset	#4,d1
.C1AF4E
	btst	#13,d0
	bne.b	.C1AF58
	bset	#3,d1
.C1AF58
	move	d1,(DATA_BUSACCESS).l
	move.l	($0010,sp),a0
	move	(a0),(DATA_BUSFAILINST).l
	move.b	(6,sp),d0
	and.b	#$F0,d0
	cmp.b	#$A0,d0
	beq.b	.C1AFDE
	move.l	($0010,sp),(DATA_BUSPTRHI).l
	movem.l	(EXHA_3Regs).l,d0/d1/a0
	cmp.l	#C1AAE0,(2,sp)
	beq	RETURNINSUPERSTATE
	cmp.l	#CriticalError,(2,sp)
	beq	RETURNINSUPERSTATE
	btst	#0,(PR_Level7).l
	beq.b	.C1AFB8
	move.l	a1,-(sp)
	bsr	SYS_GetVBR
	move.l	(RESCUEPTRS_Last).l,($007C,a1)
	move.l	(sp)+,a1
.C1AFB8
	btst	#0,(PR_Rescue).l
	beq.b	.C1AFC6
	bsr	GORESCUE
.C1AFC6
	move.w	(sp)+,(statusreg_base)
	move.l	(sp)+,(pcounter_base)
	lea	($5C-6,sp),sp
	br	EXHA_COMMON_PART
.C1AFDE
	move.l	($0010,sp),(DATA_BUSPTRHI).l
	movem.l	(EXHA_3Regs).l,d0/d1/a0
	cmp.l	#C1AAE0,($0010,sp)
	beq	RETURNINSUPERSTATE
	cmp.l	#CriticalError,($0010,sp)
	beq	RETURNINSUPERSTATE
	btst	#0,(PR_Level7).l
	beq.b	.C1B020
	move.l	a1,-(sp)
	bsr	SYS_GetVBR
	move.l	(RESCUEPTRS_Last).l,($007C,a1)
	move.l	(sp)+,a1
.C1B020
	btst	#0,(PR_Rescue).l
	beq.b	.C1B02E
	bsr	GORESCUE
.C1B02E
	move.w	(sp)+,(statusreg_base)
	move.l	(sp)+,(pcounter_base)
	lea	($20-6,sp),sp
	br	EXHA_COMMON_PART

; DO NOT RELY ON A4 BASEREG IN THIS ROUTINE UNTIL IT'S SET AGAIN
EXCEPTIONHANDLER:
	move.b	(3,sp),DATA_EXCEPTIONNUMBER
	cmp.l	#4,(sp)+
	bcc.b	.NOTBUSORADDR
	cmp	#PB_020,(ProcessorType).l
	bge.w	EXCEPTIONHANDLER_020
	tst.w	(ProcessorType)
	bne.w	EXCEPTIONHANDLER_010
	move.l	(sp)+,(DATA_BUSACCESS).l
	move.l	(sp)+,(DATA_BUSPTRLO).l
.NOTBUSORADDR:
	cmp.l	#PRIVILIGE_VIOL2,(2,sp)
	beq	RETURNINSUPERSTATE
	cmp.l	#PRIVILIGE_VIOL1,(2,sp)
	beq	RETURNINSUPERSTATE
	btst	#0,(PR_Level7).l
	beq.b	EXHA_GOINFROM7LEVEL
	move.l	a1,-(sp)
	bsr	SYS_GetVBR
	move.l	(RESCUEPTRS_Last).l,($007C,a1)
	move.l	(sp)+,a1
EXHA_GOINFROM7LEVEL:
	btst	#0,(PR_Rescue).l
	beq.b	EXHA_GOINFROMRESCUE
	bsr	GORESCUE
EXHA_GOINFROMRESCUE:
	move	(sp)+,(statusreg_base).l
	move.l	(sp)+,(pcounter_base).l

EXHA_COMMON_PART:
	movem.l	d0-d7/a0-a6,(DataRegsStore).l	;-A7
	lea	(Variable_base),a4		; *** SET A4 BASEREG ***
	tst	(FPU_Type-DT,a4)
	beq.b	.C1B0F0
	fmovem.x	fp0-fp7,(FpuRegsStore-DT,a4)
	fmovem	fpcr/fpsr/fpiar,(fpu_1-DT,a4)

	clr.l	(LastCalcFpsr-DT,a4)
.C1B0F0
	move.l	usp,a0
	move.l	a0,(USP_base-DT,a4)
	move.l	a1,-(sp)
	bsr	SYS_GetVBR
	move.l	a1,(VBR_base_ofzo-DT,a4)
	move.l	(sp)+,a1
	move.l	(DATA_SUPERSTACKPTR-DT,a4),sp
	move	#0,sr
	move.l	(DATA_USERSTACKPTR-DT,A4),sp

	tst.b	(PR_Enable_Permit).l
	beq.b	.C1B144
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	(4).w,a6
	move.b	(IntDisableCnt-DT,a4),d0
	move.b	(TaskDisableCnt-DT,a4),d1
.C1B128
	cmp.b	(IDNestCnt,a6),d0
	beq.b	.C1B134
	jsr	(_LVOEnable,a6)
	bra.b	.C1B128
.C1B134
	cmp.b	(TDNestCnt,a6),d1
	beq.b	.C1B140
	jsr	(_LVOPermit,a6)
	bra.b	.C1B134
.C1B140
	movem.l	(sp)+,d0-d7/a0-a6
.C1B144

	movem.l	d0-d7/a0-a6,-(sp)
	move.l	(SysActiveView-DT,a4),a1
	move.l	(GfxBase-DT,a4),a6
	jsr	(_LVOLoadView,a6)
	jsr	(_LVOWaitTOF,a6)
	jsr	(_LVOWaitTOF,a6)
	tst.b	(PR_WBFront).l
	beq.b	.C1B18E
;	move.l	(WBScreen-DT,a4),a1
;	move.l	(IntBase-DT,a4),a6
;	jsr	(_LVOUnlockPubScreen,a6)
;	clr.l	(WBScreen-DT,a4)
	move.l	ScreenBase,a0
	move.l	(IntBase-DT,a4),a6
	jsr	(_LVOScreenToFront,a6)
.C1B18E
	movem.l	(sp)+,d0-d7/a0-a6

	moveq	#0,d7
	move.l	(pcounter_base-DT,a4),d0
	move.l	d0,(MEM_DIS_DUMP_PTR-DT,a4)
	cmp.l	#eop_irq_routine,d0
	bne.b	.C1B1AE
	bset	#7,(DATA_EXCEPTIONNUMBER-DT,a4)
.C1B1AE
	bsr	DEBUG_REMOVE_CURRENT_BPS
	move.b	(DATA_EXCEPTIONNUMBER-DT,a4),d0
	cmp.b	#$84,d0
	beq	C1B240

	and	#$007F,d0

;	cmp.w	#9,d0		;tracetrap
;	beq.s	.noclose
;	jsr	close_debug_win		;?!?!
;	jsr	test_debug
;.noclose:

	lea	(Error_msg_tab2,pc),a0
	move	d0,d1
	cmp	#9,d1
	beq.b	C1B246
	bsr.w	close_debug_win

	and	#$D8FF,(statusreg_base-DT,a4)
	cmp	#11,d1
	bhi.b	C1B1E4
	cmp	#2,d1
	bcc.b	C1B200

C1B1E4:
	cmp	#$007F,d0
	bne.b	C1B1EE
	moveq	#1,d1
	bra.b	C1B1FE

C1B1EE:
	bsr.b	C1B22A
	add	(a0),a0
	bsr	printthetext
	move	d1,d0
	bsr	C15908
	bra.b	C1B218

C1B1FE:
	move	d1,d0
C1B200:
	add	d0,d0
	add	(a0,d0.w),a0
	bsr.b	C1B22A
	bsr	printthetext
	cmp.b	#2,d1
	beq.b	C1B272
	cmp.b	#3,d1
	beq.b	C1B272
C1B218:
	lea	(Raised.MSG,pc),a0
	bsr	printthetext
	move.l	(pcounter_base-DT,a4),d0
	bsr	druk_af_d0
	bra.b	EXHA_JUSTRETURN

C1B22A:
	cmp.b	#MT_DEBUGGER,(menu_tiepe-DT,a4)
	bne.b	C1B23E
	movem.l	d1/a0,-(sp)
	bsr	C1A91A
	movem.l	(sp)+,d1/a0
C1B23E:
	rts

C1B240:
	tst	(SST_STEPS-DT,a4)
	beq.b	EXHA_JUSTRETURN
C1B246:
	bsr	C1A5FE
	tst.b	d0
	beq.b	C1B264
	lea	(Conditionbrea.MSG,pc),a0
	bsr	printTextInMenuStrip
	bclr	#SB1_WINTITLESHOW,(SomeBits-DT,a4)
	move	#1,(SST_STEPS-DT,a4)
C1B264:
	move	(SST_STEPS-DT,a4),d0
	beq.b	C1B1FE
	subq.w	#1,d0
	beq.b	EXHA_JUSTRETURN
	br	com_singlestep

C1B272:
	jmp	(EXHA_BUSADDRERROR).l

EXHA_JUSTRETURN:
	cmp.b	#MT_DEBUGGER,(menu_tiepe-DT,a4)
	beq	DEBUG_NEXTLINE
	bsr	druk_cr_nl
	jsr	(LINE_REGPRINT).l
	jmp	(CommandlineInputHandler).l

Error_msg_tab2:
	dc.w	Exception.MSG-Error_msg_tab2		;0
	dc.w	ExternalLevel.MSG-Error_msg_tab2	;1
	dc.w	BusError.MSG-Error_msg_tab2		;2
	dc.w	AddressError.MSG-Error_msg_tab2		;3
	dc.w	IllegalInstru.MSG-Error_msg_tab2	;4
	dc.w	DivisionByZer.MSG-Error_msg_tab2	;5
	dc.w	CHKexception.MSG-Error_msg_tab2		;6
	dc.w	TRAPV.MSG-Error_msg_tab2		;7
	dc.w	PrivilegeViol.MSG-Error_msg_tab2	;8
	dc.w	TraceTrap.MSG-Error_msg_tab2		;9
	dc.w	LineAEmulator.MSG-Error_msg_tab2	;10
	dc.w	LineFEmulator.MSG-Error_msg_tab2	;11

;***************************************************************

MON_DIS_TYPES:
	dc.w	DissKeys-MON_DIS_TYPES
	dc.w	DissDrukline-MON_DIS_TYPES
	dc.w	DissBack1line-MON_DIS_TYPES
	dc.w	DissCursor-MON_DIS_TYPES
	dc.w	com_dissasemble-MON_DIS_TYPES
	dc.w	DissJump2-MON_DIS_TYPES
Asciidump_stuff:
	dc.w	AsciiKeys-Asciidump_stuff
	dc.w	AsciiDrukline-Asciidump_stuff
	dc.w	AsciiBack1line-Asciidump_stuff
	dc.w	AsciiCursor-Asciidump_stuff
	dc.w	com_ascii_dump-Asciidump_stuff
	dc.w	MonJump2-Asciidump_stuff
Hexdump_stuff:
	dc.w	HexKeys-Hexdump_stuff
	dc.w	HexDrukline-Hexdump_stuff
	dc.w	HexBack1line-Hexdump_stuff
	dc.w	HexCursor-Hexdump_stuff
	dc.w	com_hexdump-Hexdump_stuff
	dc.w	MonJump2-Hexdump_stuff
BinDump_stuff:
	dc.w	BinKeys-BinDump_stuff
	dc.w	BinDrukline-BinDump_stuff
	dc.w	BinBack1line-BinDump_stuff
	dc.w	BinCursor-BinDump_stuff
	dc.w	com_BinMoni-BinDump_stuff
	dc.w	MonJump2-BinDump_stuff


EnterMonitorMode:
	move.b	(MemDumpSize-DT,a4),(OpperantSize-DT,a4)
	move.l	(MON_TYPE_PTR-DT,a4),a0
	move.l	a0,d0
	bne.b	.C1B2EC
	lea	(MON_DIS_TYPES,pc),a0
.C1B2EC	add	(8,a0),a0
	moveq	#-1,d0
	jmp	(a0)


enter_hex_mode:
	bclr	#MB1_INCOMMANDLINE,(MyBits-DT,a4)
	bset	#SB3_SPEC_KEYS,(SomeBits3-DT,a4)	;in editor
	move.l	a0,(MON_TYPE_PTR-DT,a4)
	move	(NumLines_Editor-DT,a4),d0
	jsr	(OPED_SETNBOFFLINES).l
	jsr	(Change2Monitormenu).l
	bclr	#SB3_COMMANDMODE,(SomeBits3-DT,a4)	;uit command
	bset	#SB3_REPORT_ERROR,(SomeBits3-DT,a4)
	lea	(monitor_loopje,pc),a0
	move.l	a0,(Error_Jumpback-DT,a4)
C1B324:
	clr.l	(LineFromTop-DT,a4)
	jsr	(RegTab_SETALLNOTUPD).l
	tst.b	(MemDumpSize-DT,a4)
	bne.b	C1B338
	addq.b	#1,(MemDumpSize-DT,a4)
C1B338:
	move.l	(MEM_DIS_DUMP_PTR-DT,a4),d0

	move.l	d0,(RegelPtrsIn-DT,a4)
	bsr	SENDCHARDELSCR
	bsr.w	Druk_Clearbuffer
	st	(BreakKey-DT,a4)	;disabled
	bsr.w	Druk_Clearbuffer

	bsr	StatusBar_monitor
	st	(reset_pos-DT,a4)
	jsr	get_font1
	bsr.w	mon_setpos

monitor_loopje:
	move.l	(DATA_USERSTACKPTR-DT,a4),sp
	moveq	#0,d7
	move	(Scr_br_chars-DT,a4),(breedte_editor_in_chars-DT,a4)
	bsr	iets_met_monitor_output

	; *** This one is triggered after page up/down
	tst.b	(Mon_Notif_Addr-DT,a4)
	beq.b	.Refresh_Address
	bsr.w	mon_setpos
	; *** Only one time
	sf	(Mon_Notif_Addr-DT,a4)
.Refresh_Address:

	; *** Set caret coords
	move.l	(MON_TYPE_PTR-DT,a4),a0
	add	(6,a0),a0
	jsr	(a0)
	bsr	Place_cursor_blokje

	bsr	GetTheTime		; returns buffer in a0
	moveq	#-10,d7
	add.w	(Scr_br_chars-DT,a4),d7
	bsr	drukit

;	jsr	(StatusBar_monitor)

	bsr	RESETMENUTEXT
	bsr	messages_get
	bsr	GETKEYNOPRINT
	cmp.b	#$1B,d0
	beq	LeaveMonitor
	bsr	RESETMENUTEXT
	pea	(monitor_loopje,pc)
	cmp.b	#$80,d0
	bne	.NotSpecKey
	moveq	#0,d0
	move.b	(edit_EscCode-DT,a4),d0
	cmp.b	#$1E,d0
	beq	mon_jump2LastAddr
	cmp.b	#9,d0		; amiga-[ or alt+up
	beq	mon_EnvPrefs
	cmp.b	#12,d0		; amiga-] or alt+down
	beq	mon_AsmPrefs
	cmp.b	#70,d0		; amiga-Z
	beq	mon_SyntPrefs

	cmp.b	#$65,d0		; help
	beq	mon_amiguide
	cmp.b	#$2E,d0		;.
	beq	C1B584
	cmp.b	#$43,d0		;C
	beq	C1B588
	cmp.b	#$38,d0		;8
	beq	C1B58C
	cmp.b	#$1C,d0		;jump2Address
	beq	mon_jump2Addr
	cmp.b	#$1A,d0		;h
	beq	mon_enterhexmon
	cmp.b	#$20,d0
	beq	C1B8D6
	cmp.b	#$21,d0
	beq	C1B8E4		; bin mon
	cmp.b	#$23,d0
	beq	C1B5D2
	cmp.b	#$16,d0
	beq	C1B8CA
	cmp.b	#1,d0
	beq	Mon_scrolldown
	cmp.b	#4,d0
	beq	Mon_scrollup
	cmp.b	#5,d0
	beq	Mon_pageup
	cmp.b	#8,d0
	beq	Mon_pagedown
	cmp.b	#$4F,d0
	beq	C1B678
	cmp.b	#$50,d0
	beq	C1B680
	cmp.b	#$51,d0
	beq	C1B688
	cmp.b	#$47,d0
	beq	C1B690
	cmp.b	#$48,d0
	beq	C1B696
	cmp.b	#$49,d0
	beq	C1B69C
	cmp.b	#$39,d0
	beq	C1B618
	cmp.b	#$3B,d0
	beq	C1B618
	cmp.b	#$2D,d0
	beq	C1B618
	cmp.b	#$30,d0
	beq	C1B618
	cmp.b	#$31,d0
	beq	C1B618
	cmp.b	#$52,d0
	beq	C1B57A
	cmp.b	#$53,d0
	beq.b	mon_setbegin
	cmp.b	#$54,d0
	beq.w	mon_setend
	cmp.b	#$55,d0
	beq.w	mon_SaveBin

	IF MEMSEARCH
	cmp.b	#$56,d0
	beq.w	mon_SearchMem
	cmp.b	#$57,d0
	beq.w	mon_SearchMemForward
	ENDIF

	moveq	#$80-256,d0
.NotSpecKey
	move.l	(MON_TYPE_PTR-DT,a4),a0
	add	(a0),a0
	jsr	(a0)
	bra.w	mon_setpos

mon_SyntPrefs:
	move.b	#2,(Prefs_tiepe-DT,a4)
	bra.b	C1B4C0

mon_EnvPrefs:
	clr.b	(Prefs_tiepe-DT,a4)
	bra.b	C1B4C0

mon_AsmPrefs:
	move.b	#1,(Prefs_tiepe-DT,a4)
C1B4C0:
	movem.l	d0-a6,-(sp)
	jsr	(Handle_prefs_windows).l
	movem.l	(sp)+,d0-a6
	move.b	(MemDumpSize-DT,a4),(OpperantSize-DT,a4)
	bsr	mon_getCurrAdr
	move.l	(MON_TYPE_PTR-DT,a4),a0
	add	(8,a0),a0
	jmp	(a0)

; ----
mon_amiguide:
	jmp	(AmigaGuideGedoe)

; ----
mon_setbegin:
	bsr	mon_getCurrAdr
	move.l	d0,(SaveBin_Start-DT,a4)
	st	(SaveBin_StartEndSet+0-DT,a4)
	lea	(xxxxxxxxEnd.MSG,pc),a3
	jsr	(ZetHex_D0_Om5_inA3).l
	lea	(xxxxxxxxEnd.MSG,pc),a0
	moveq	#8,d7
	bra.b	drukit

; ----
mon_setend:
	bsr	mon_getCurrAdr
	move.l	d0,(SaveBin_End-DT,a4)
	st	(SaveBin_StartEndSet+1-DT,a4)
	lea	(xxxxxxxxSize.MSG,pc),a3
	jsr	(ZetHex_D0_Om5_inA3).l
	moveq	#8+15,d7
	lea	(xxxxxxxxSize.MSG,pc),a0
	bra.b	drukit

; ---- ***
mon_setpos:
	bsr	mon_getCurrAdr
	lea	(Monitor_Pos,pc),a3
	jsr	(ZetHex_D0_Om5_inA3).l
	lea	(Monitor_Pos,pc),a0
	moveq	#54,d7

drukit:
	bclr	#MB1_LINE_NOT_IN_SOURCE,(MyBits-DT,a4)

	lea	(regel_buffer-DT,a4),a2		;status
	lea	(a2,d7.w),a1

	moveq	#8-1,d7
	cmp.l	#TimeString,a0
	beq.s	.lopje
	moveq	#9-1,d7
.lopje	move.b	(a0)+,d0
	jsr	FASTSENDONECHAR
	dbra	d7,.lopje
	rts

	IF MEMSEARCH

mon_SearchMemForward:
	move.w	(mon_StartSize-DT,a4),d1
	bmi.s	mon_SearchMem
	move.l	(mon_StartValue-DT,a4),-(sp)	;d0
	bra.b	mon_SearchMem\.inspringen

mon_SearchMem:
	lea	(Searchfor.MSG,pc),a0
	bsr	GetAdrFromTitle
	beq.w	RESETMENUTEXT

	move.l	d0,(mon_StartValue-DT,a4)
	move.l	d0,-(sp)
	lea	(SIZEBWL.MSG,pc),a0
	bsr	printTextInMenuStrip

	bsr	GETKEYNOPRINT
	and.b	#$DF,d0
	moveq	#0,d1
	cmp.b	#'B',d0
	beq.s	.klaar
	moveq	#4,d1
	cmp.b	#'W',d0
	beq.s	.klaar
	moveq	#8,d1
	cmp.b	#'L',d0
	bne.w	.errIllSize
.klaar:
	move.w	d1,(mon_StartSize-DT,a4)
.inspringen:
	move.l	d1,-(sp)
	lea	(Searching.MSG,pc),a0
	bsr	printTextInMenuStrip

	bsr	mon_getCurrAdr
	move.l	d0,a6
	addq.l	#1,a6		;niet steeds dezelfde finden
	move.l	d0,(mon_StartAdr-DT,a4)

	move.l	(sp)+,d1
	move.l	(sp)+,d0

	move.b	(a6)+,d6
	tst.w	d1
	beq.s	.go
	lsl.l	#8,d6
	move.b	(a6)+,d6
	cmp.w	#4,d1
	beq.s	.go
	swap	d6
	move.b	(a6)+,d6
	lsl.w	#8,d6
	move.b	(a6)+,d6
.go	lea	(.jumper,pc,d1.w),a5
	jmp	(a5)
.jumper:
	cmp.b	d0,d6
	bra.b	.check
	cmp.w	d0,d6
	bra.b	.check
	cmp.l	d0,d6
.check:
	beq.s	.foundL
	lsl.l	#8,d6	

;	cmp.l	#$0007FE30,a6
;	beq.s	.errNotFound
	cmp.l	#$001ffe30,a6
	beq.s	.errNotFound
	cmp.l	#$00bffe30,a6
	beq.s	.errNotFound
	cmp.l	#$00D7FE30,a6
	beq.s	.errNotFound

	move.b	(a6)+,d6

	cmp.l	(mon_StartAdr-DT,a4),a6
	beq.b	.errNotFound
	jmp	(a5)

.foundL:
	subq.l	#1,a6
	tst.w	d1
	beq.s	.go2
	subq.l	#1,a6
	cmp.w	#4,d1
	beq.s	.go2
	subq.l	#2,a6
.go2:
	move.l	a6,d0
	bra	mon_Jump2AdrNow

.errIllSize:
	move.l	(sp)+,d0
	lea	(.illsize.MSG,pc),a0
	bra	druk_menu_txt_verder

.errNotFound:
	lea	(Not.MSG,pc),a0
	bra	druk_menu_txt_verder

.illsize.MSG:	dc.b	"Illegal size, should be one of B/W/L",0
	EVEN

	ENDIF

mon_SaveBin:
	cmp.w	#~0,(SaveBin_StartEndSet-DT,a4)	; both set?
	bne.b	C1B574
	btst	#0,(PR_ReqLib).l
	bne.b	C1B556
	lea	(FILENAME.MSG,pc),a0
	bsr	putThetextInMenubar
	bne.b	C1B574
	bra.b	C1B55E

C1B556:
	moveq	#3,d0
	jsr	(YesReqLib).l
C1B55E:
	move.l	(SaveBin_Start-DT,a4),d2
	move.l	(SaveBin_End-DT,a4),d3
	cmp.l	d2,d3
	bgt.b	C1B56C
	exg	d2,d3
C1B56C:
	sub.l	d2,d3
	moveq	#-2,d7
	br	C18C9A

C1B574:
	bra	RESETMENUTEXT

C1B57A:
	bsr	C1B57E
C1B57E:
	bra	GetKey

C1B584:
	moveq	#1,d0
	bra.b	C1B59A

C1B588:
	moveq	#2,d0
	bra.b	C1B59A

C1B58C:
	moveq	#4,d0
	cmp.l	#BinDump_stuff,(MON_TYPE_PTR-DT,a4)
	bne.b	C1B59A
	moveq	#2,d0
C1B59A:
	bsr.b	hex_2_ascii
	move.b	d0,(MemDumpSize-DT,a4)
	bsr	mon_getCurrAdr
	addq.l	#4,sp
	br	C1B324

hex_2_ascii:
	movem.l	d0/a1,-(sp)
	lsr.w	#1,d0
	lea	(BytesWordsLon.MSG,pc),a0
	mulu	#10,d0
	add.w	d0,a0
	lea	(LongwordsTime.MSG,pc),a1
	moveq	#9,d0
C1B5C6:
	move.b	(a0)+,(a1)+
	dbra	d0,C1B5C6
	movem.l	(sp)+,d0/a1
	rts

C1B5D2:
	move.l	(MON_TYPE_PTR-DT,a4),a0
	add	(10,a0),a0
	jmp	(a0)

DissJump2:
	moveq	#-1,d0
	move.l	d0,(MON_LAST_LONG_ADDR-DT,a4)
	bsr	C1B9A2
	moveq	#-1,d1
C1B5E8:
	move.l	(MON_LAST_LONG_ADDR-DT,a4),d0
	cmp.l	d1,d0
	bne	mon_Jump2AdrNow
	rts

MonJump2:
	bsr.b	mon_getCurrAdr
	bclr	#0,d0
	move.l	d0,a0
	move.l	(a0),d0
	lea	(DIS_PRINT_BUFFER\.Instr-DT,a4),a3
	jsr	(ZetHex_D0_Om5_inA3).l
	clr.b	(a3)
	lea	(DIS_PRINT_BUFFER\.Instr-DT,a4),a1
	bsr	C14678
	br	mon_jump2Addr

C1B618:
	bsr	KEY_RETURN_LAST_KEY
LeaveMonitor:
	bsr.b	mon_getCurrAdr
	bsr.w	Druk_Clearbuffer
	bclr	#SB1_MOUSE_KLIK,(SomeBits-DT,a4)
	move.l	#ErrorInLine,(Error_Jumpback-DT,a4)
	lea	(End_msg,pc),a0
	bsr	druk_status_en_end_af
	bsr	scroll_up_cmd_fix
	jmp	(CommandlineInputHandler).l

mon_getCurrAdr:
	lea	(RegelPtrsIn-DT,a4),a0
	move.l	(LineFromTop-DT,a4),d0

	IF MC020
	move.l	(a0,d0.w*4),a0
	ELSE	
	lsl.w	#2,d0
	move.l	(a0,d0.w),a0
	ENDC

	move.w	(MON_EDIT_POSITION-DT,a4),d0
	cmp.l	#Hexdump_stuff,(MON_TYPE_PTR-DT,a4)
	bne.b	C1B66E
	cmp.w	#32,d0
	bcs.b	MaxHex_Addr
	sub.w	#32,d0
	add.w	d0,d0
MaxHex_Addr:
	lsr.w	#1,d0
C1B66E:
	; *** Fix the current address in binary dump
	cmp.l	#BinDump_stuff,(MON_TYPE_PTR-DT,a4)
	bne.b	BinDump_Address
	cmp.w	#32,d0
	bcs.b	MaxBin_Addr
	sub.w	#32,d0
	lsl.w	#3,d0
MaxBin_Addr:
	lsr.w	#3,d0
BinDump_Address:
	add	d0,a0
	move.l	a0,(MEM_DIS_DUMP_PTR-DT,a4)
	move.l	a0,d0
	rts

C1B678:
	bsr.b	mon_getCurrAdr
	move.l	d0,(MON_DATA_MARK1-DT,a4)
	rts

C1B680:
	bsr.b	mon_getCurrAdr
	move.l	d0,(MON_DATA_MARK2-DT,a4)
	rts

C1B688:
	bsr.b	mon_getCurrAdr
	move.l	d0,(MON_DATA_MARK3-DT,a4)
	rts

C1B690:
	move.l	(MON_DATA_MARK1-DT,a4),d0
	bra.b	C1B6B2

C1B696:
	move.l	(MON_DATA_MARK2-DT,a4),d0
	bra.b	C1B6B2

C1B69C:
	move.l	(MON_DATA_MARK3-DT,a4),d0
	bra.b	C1B6B2

C1B6A2:
	move.l	(RegelPtrsIn-DT,a4),-(sp)
	jsr	(RegTab_SETALLNOTUPD).l
	move.l	(sp)+,(RegelPtrsIn-DT,a4)
	rts

C1B6B2:
	move.l	d0,-(sp)
	jsr	(RegTab_SETALLNOTUPD).l
	move.l	(sp)+,d0
	cmp.l	#MON_DIS_TYPES,(MON_TYPE_PTR-DT,a4)
	bne.b	C1B6CA
	bclr	#0,d0
C1B6CA:
	move.l	d0,(RegelPtrsIn-DT,a4)
	clr.l	(LineFromTop-DT,a4)
	clr	(MON_EDIT_POSITION-DT,a4)
	rts

mon_jump2Addr:
	lea	(Address.MSG,pc),a0
	bsr	GetAdrFromTitle
mon_Jump2AdrNow:
	move.l	d0,-(sp)
	bsr	mon_getCurrAdr
	moveq	#15,d1
	and	(MON_LAST_NUM-DT,a4),d1
	addq.w	#1,(MON_LAST_NUM-DT,a4)
	lsl.w	#2,d1
	lea	(MON_LAST_BUFFER-DT,a4),a0
	add	d1,a0
	move.l	d0,(a0)
	move.l	(sp)+,d0
	bra.b	C1B6B2

mon_jump2LastAddr:
	subq.w	#1,(MON_LAST_NUM-DT,a4)
	moveq	#15,d1
	and	(MON_LAST_NUM-DT,a4),d1
	lsl.w	#2,d1
	lea	(MON_LAST_BUFFER-DT,a4),a0
	add	d1,a0
	move.l	(a0),d0
	beq.b	C1B718
	clr.l	(a0)
	bra.b	C1B6B2

C1B718:
	rts

;********** MON OUTPUT ***********

iets_met_monitor_output:
;	bsr	WaitBlit
.waitmenustate:
	move.l	(MainWindowHandle-DT,a4),a1
	tst.b	($1A,a1)		;bit7 menustate
	bmi.b	.waitmenustate

;	bclr	#SB3_COMMANDMODE,(SomeBits3-DT,a4)	;uit command
;	bne.w	druk_lines_monitor
;	bsr.w	_Show_Cursor
;druk_lines_monitor:

	jsr	get_font1

	lea	(RegelPtrsIn-DT,a4),a6
	move.l	(NrOfLinesInEditor-DT,a4),d1

	bset	#MB1_LINE_NOT_IN_SOURCE,(MyBits-DT,a4)

;	sub.l	a1,a1			;reset y-pos
	moveq	#0,d7			;y-pos

.regel_loopje_mon:
	subq.w	#1,d1
	beq.b	KlaarMetMonOutput		;klaar

	movem.l	d7/a1/a6,-(sp)

	moveq	#-1,d0
	cmp.l	(a6)+,d0
	bne.b	HexRegel_algoed

;	addq.l	#1,a1			;y pos
	addq.l	#1,d7

	bsr.b	.regel_loopje_mon	;nr regels diepe recursie

;*scroll up
	movem.l	(sp)+,d7/a1/a6

	move.l	(4,a6),a5

	movem.l	d1/d3/a1/a6,-(sp)
	move.l	(MON_TYPE_PTR-DT,a4),a0
	add	(4,a0),a0	;prev regel
	jsr	(a0)
	movem.l	(sp)+,d1/d3/a1/a6

	move.l	a5,(a6)+

	movem.l	d1/d3/a1/a6,-(sp)
	move.l	(MON_TYPE_PTR-DT,a4),a0
	add	(2,a0),a0	;druk line

	jsr	(a0)
	movem.l	(sp)+,d1/d3/a1/a6

	rts

HexRegel_algoed:
	moveq	#-1,d0
	cmp.l	(a6),d0
	beq.b	HexRegelNietIngevuld
HexDump_down_b:
	addq.w	#4,a6		;regel tabel

;	addq.l	#1,a1			;y pos
	addq.l	#1,d7

	subq.w	#1,d1			;nr regels
	bne.b	HexRegel_algoed

regel_down_einde:
	movem.l	(sp)+,d7/a1/a6
	rts

KlaarMetMonOutput:
	move.l	(a6),a5
	movem.l	d1/d3/a1/a6,-(sp)
	move.l	(MON_TYPE_PTR-DT,a4),a0
	add	(2,a0),a0		;druk line
	jsr	(a0)
	movem.l	(sp)+,d1/d3/a1/a6
	rts

HexRegelNietIngevuld:
	move.l	(-4,a6),a5
.lopje:
	cmp.w	#-1,a5
	beq.b	.moveit_up

;	jsr	test2

	movem.l	d1/d3/a1/a6,-(sp)
	move.l	(MON_TYPE_PTR-DT,a4),a0
	add	(2,a0),a0		;druk line
	jsr	(a0)
	movem.l	(sp)+,d1/d3/a1/a6

.moveit_up:
	cmp.l	(a6),a5
	beq.b	HexDump_down_b
	move.l	a5,(a6)+

;	addq.l	#1,a1			;y pos
	addq.l	#1,d7

	subq.w	#1,d1
	bne.b	.lopje

	movem.l	d1/d3/a1/a6,-(sp)
	move.l	(MON_TYPE_PTR-DT,a4),a0
	add	(2,a0),a0		;druk line
	jsr	(a0)
	movem.l	(sp)+,d1/d3/a1/a6

	bra.b	regel_down_einde

;************** HEX EDITOR *****************

Mon_scrolldown:
	move.l	(NrOfLinesInEditor-DT,a4),d0
	lsr.w	#1,d0
	cmp.l	(LineFromTop-DT,a4),d0
	blo.b	.nogniet_ophelft

	bsr.w	_Show_Cursor
	bset	#SB3_COMMANDMODE,(SomeBits3-DT,a4)	;in commandline
	bsr	ScrollEditorDown
	bsr.w	_Show_Cursor

	tst.l	(LineFromTop-DT,a4)			; *** Fix the sticky
	bne.b	.No_Caret2				; caret bug
	move.w	(cursor_row_pos-DT,a4),-(a7)		; when at the top
	move.w	#2,(cursor_row_pos-DT,a4)		; of the area
	bsr	Place_cursor_blokje
	move.w	(a7)+,(cursor_row_pos-DT,a4)
.No_Caret2:

	jsr	(Regeltab_scrolldown).l

	bsr	clear_input_buffer
	bra.w	mon_setpos

.nogniet_ophelft:
	subq.l	#1,(LineFromTop-DT,a4)
	bra.w	mon_setpos

Mon_scrollup:
	move.l	(NrOfLinesInEditor-DT,a4),d0
	lsr.w	#1,d0
	cmp.l	(LineFromTop-DT,a4),d0	;op de helft?
	bhi.b	.nogniet_ophelft

	bsr.w	_Show_Cursor

	bset	#SB3_COMMANDMODE,(SomeBits3-DT,a4)	;in commandmode
	bsr	ScrollEditorUp

	bsr.w	_Show_Cursor

	jsr	(Regeltab_scrollup).l
	bsr	clear_input_buffer
	bsr.w	mon_setpos
	moveq	#1,d0				; returns 1 if scrolled
	rts
.nogniet_ophelft:
	addq.l	#1,(LineFromTop-DT,a4)
	bsr.w	mon_setpos
	moveq	#0,d0				; return 0 if nothing
	rts

Mon_pageup:
	st	(reset_pos-DT,a4)
	move.l	(RegelPtrsIn-DT,a4),-(sp)
	jsr	(RegTab_SETALLNOTUPD).l

	lea	(RegelPtrsIn-DT,a4),a0
	move.l	(NrOfLinesInEditor-DT,a4),d0
	subq.w	#1,d0
	add	d0,d0
	add	d0,d0
	add	d0,a0
	move.l	(sp)+,(a0)
	bra.b	Mon_pageupdown_finish

Mon_pagedown:
	st	(reset_pos-DT,a4)
	lea	(RegelPtrsIn-DT,a4),a0
	move.l	(NrOfLinesInEditor-DT,a4),d0
	subq.w	#1,d0
	add	d0,d0
	add	d0,d0
	add	d0,a0
	move.l	(a0),-(sp)
	jsr	(RegTab_SETALLNOTUPD).l
	move.l	(sp)+,(RegelPtrsIn-DT,a4)
Mon_pageupdown_finish:
	st	(Mon_Notif_Addr-DT,a4)
	bra	clear_input_buffer

mon_enterhexmon:
	move.b	(MemDumpSize-DT,a4),(OpperantSize-DT,a4)
	bsr	mon_getCurrAdr
	br	com_hexdump

C1B8CA:
	move.b	(MemDumpSize-DT,a4),(OpperantSize-DT,a4)
	bsr	mon_getCurrAdr
	bra.b	com_dissasemble

C1B8D6:
	move.b	(MemDumpSize-DT,a4),(OpperantSize-DT,a4)
	bsr	mon_getCurrAdr
	br	com_ascii_dump

C1B8E4:
	move.b	(MemDumpSize-DT,a4),(OpperantSize-DT,a4)
	bsr	mon_getCurrAdr
	br	com_BinMoni

;************** DISSASAMBLER OUTPUT ****************

com_dissasemble:
	bne.b	.C1B8F8
	move.l	d0,(MEM_DIS_DUMP_PTR-DT,a4)	;user defined..
.C1B8F8
	bclr	#0,(MEM_DIS_DUMP_PTR+3-DT,a4)

	clr	(MON_EDIT_POSITION-DT,a4)
	bsr	MON_CLEARCACH
	lea	(MON_DIS_TYPES,pc),a0	;afdruk functies
	br	enter_hex_mode

	IF	Debugstuff
Debug_base:
	lea	(A4Debug.MSG-DT,a4),a0
	bsr	beeldtextaf
	move.l	a4,d0
	bsr	druk_af_d0_space
	lea	(A4Debug2.MSG-DT,a4),a0
	bsr	beeldtextaf
	lea	(UserStackEnd-DT,a4),a0
	move.l	a0,d0
	bsr	druk_af_d0_space
	lea	(A4DebugEol.MSG-DT,a4),a0
	bra	beeldtextaf
	ENDIF

DissCursor:
;	st	(reset_pos-DT,a4)
;	bsr.w	_Show_Cursor
	move.l	(LineFromTop-DT,a4),d0
	add	d0,d0
	move	d0,(cursor_row_pos-DT,a4)
	move.w	#30,(Cursor_col_pos-DT,a4)
C1B9A0:
	rts

DissKeys:
	cmp.b	#$80,d0
	beq.b	.C1B97C
	cmp.b	#$7F,d0			; (DEL) Insert NOP
	beq.b	DissInsertNOP
	bsr	KEYBUFFERPUTCHAR
	bra.b	C1B9D0

.C1B97C	move.b	(edit_EscCode-DT,a4),d0
	cmp.b	#$57,d0
	beq.b	C1B9A0
	bsr.b	C1B9A2
	lea	(DIS_PRINT_BUFFER\.Instr-DT,a4),a1
	bsr	C14678
	moveq	#6,d0
	bsr	C17412
	bsr	KEY_RETURN_LAST_KEY
	bra.b	C1B9D0

C1B9A2:
	lea	(RegelPtrsIn-DT,a4),a0
	move.l	(LineFromTop-DT,a4),d0

	IF MC020
	lea	(a0,d0.w*4),a0
	ELSE
	lsl.w	#2,d0
	add	d0,a0
	ENDC

	move.l	(a0)+,a5
	jmp	(Disasm_OneLine).l

; ----
DissInsertNOP:
	lea	(RegelPtrsIn-DT,a4),a0
	move.l	(LineFromTop-DT,a4),d0

	IF MC020
	lea	(a0,d0.w*4),a0
	ELSE
	lsl.w	#2,d0
	add	d0,a0
	ENDC

	move.l	(a0)+,a1
	moveq	#-1,d1
	move.l	d1,(a0)
	move	#$4E71,(a1)
	bsr	Mon_scrollup
Fix_DissScroll:
	tst.b	d0					; Scrolled?
	beq.b	NoDiss_Scroll_Done

NoDiss_Scroll:
	move.w	(cursor_row_pos-DT,a4),-(a7)		; Correct caret
	addq.w	#1,(cursor_row_pos-DT,a4)
	bsr	Place_cursor_blokje
	move.w	(a7)+,(cursor_row_pos-DT,a4)
NoDiss_Scroll_Done:
	st	(reset_pos-DT,a4)
	rts
C1B9D0:
	bsr	C1529A
	bsr.w	Druk_Clearbuffer
	lea	(RegelPtrsIn-DT,a4),a0
	move.l	(LineFromTop-DT,a4),d0

	IF MC020
	lea	(a0,d0.w*4),a0
	ELSE
	lsl.w	#2,d0
	add	d0,a0
	ENDC
	move.l	(a0)+,d0

	moveq	#-1,d1
	move.l	d1,(a0)
	move.l	#Asm_Table,(Asm_Table_Base-DT,a4)
	clr.l	(CURRENT_ABS_ADDRESS-DT,a4)
	move.l	d0,(INSTRUCTION_ORG_PTR-DT,a4)
	clr	(CurrentSection-DT,a4)
	bsr.w	INPUTTEXT_NOTEXT
	cmp.b	#27,d0		; esc
	beq.b	.C1BA16
	jsr	(Assemble_cur_line).l
	bsr	Mon_scrollup
	tst.b	d0					; Scrolled?
	beq.b	NoDiss_Scroll_Done
	bsr.b	NoDiss_Scroll
.C1BA16	bra.b	NoDiss_Scroll

;******** Diss druk line ********

DissPrintCurrAddress:
	move.l	a5,d0
	lea	(regel_buffer-DT,a4),a3
	move.l	a3,a1
	jsr	(Zet_D0_Om_inA3)
	move.b	#" ",(a3)+
	rts

DissDrukline:
	bsr.b	DissPrintCurrAddress

	movem.l	d3/d6/d7/a1/a3,-(sp)
	jsr	(DISASSEMBLE_A5_PRINT)
	movem.l	(sp)+,d3/d6/d7/a1/a3

	moveq	#-10,d1
	add.w	(Scr_br_chars-DT,a4),d1
.druk_lopje:
	move.b	(a0)+,d0
	beq.b	DissDump_cl2eol
	move.b	d0,(a3)+
	dbf	d1,.druk_lopje

	move.b	#$BB,(a3)+		; >>
	bra.b	Dissklaar

DissDump_cl2eol:
	move.b	#' ',(a3)+
	dbra	d1,DissDump_cl2eol

Dissklaar:
	clr.b	(a3)+
	move.w	(Scr_br_chars-DT,a4),d6
	bra	Sol_druk_line	;aantal=d6 buff=a1

;************

CACH_LEN = 25*2		; 25 words

MON_CLEARCACH:
	lea	(MON_CACH_AREA-DT,a4),a0
	moveq	#CACH_LEN/2-1,d0
	moveq	#-1,d1
.C1BA86	move	d1,(a0)+
	dbra	d0,.C1BA86
	clr.l	(MON_CACH_ADDRESS-DT,a4)
	rts

MON_CACH_ADJUST:
	move.l	a5,-(sp)
	sub	#CACH_LEN,a5
	move.l	(MON_CACH_ADDRESS-DT,a4),d2
	move.l	a5,(MON_CACH_ADDRESS-DT,a4)
	lea	(MON_CACH_AREA-DT,a4),a0
	sub.l	a5,d2
	beq.b	C1BAE4
	bmi.b	C1BAC6
	move.l	a0,a1
	add	#CACH_LEN,a0
	move.l	a0,a2
	sub.l	d2,a2
C1BAB4:
	cmp.l	a1,a0
	beq.b	C1BAE4
	cmp.l	a1,a2
	bls.b	C1BAC0
	move	-(a2),-(a0)
	bra.b	C1BAB4

C1BAC0:
	move	#-1,-(a0)
	bra.b	C1BAB4

C1BAC6:
	neg.l	d2
	lea	(CACH_LEN,a0),a1
	move.l	a0,a2
	add.l	d2,a2
.C1BAD2	cmp.l	a1,a0
	beq.b	C1BAE4
	cmp.l	a1,a2
	bhs.b	.C1BADE
	move	(a2)+,(a0)+
	bra.b	.C1BAD2
.C1BADE	move	#-1,(a0)+
	bra.b	.C1BAD2
C1BAE4:
	move.l	(sp)+,a5
	rts

MON_DISLENGTH_A5_CACH:
	move.l	(MON_CACH_ADDRESS-DT,a4),a0
	move.l	a0,a1
	cmp.l	a1,a5
	blo.b	.NOT_IN_CACH
	add	#CACH_LEN,a1
	cmp.l	a1,a5
	bhs.b	.NOT_IN_CACH
	lea	(MON_CACH_AREA-DT,a4),a1
	move.l	a5,d0
	sub.l	a0,d0
	add	d0,a1
	move	(a1),d1
	bpl.b	.FOUND
	move.l	a1,-(sp)
	bsr.b	.NOT_IN_CACH
	move.l	(sp)+,a1
	move	d1,(a1)
.FOUND	rts
.NOT_IN_CACH
	jmp	(DISLENGTH_A5)


DissBack1line:
	bsr	MON_CACH_ADJUST
	moveq	#10,d2
C1BB22:
	moveq	#10,d3
	movem.l	d2-d6/a5,-(sp)
	sub.l	d2,a5
	bsr.b	MON_DISLENGTH_A5_CACH
	movem.l	(sp)+,d2-d6/a5
	cmp	d2,d1
	bne.b	C1BBA6
C1BB34:
	moveq	#10,d4
	movem.l	d2-d6/a5,-(sp)
	sub.l	d2,a5
	sub.l	d3,a5
	bsr.b	MON_DISLENGTH_A5_CACH
	movem.l	(sp)+,d2-d6/a5
	cmp	d3,d1
	bne.b	C1BBA2
C1BB48:
	moveq	#10,d5
	movem.l	d2-d6/a5,-(sp)
	sub.l	d2,a5
	sub.l	d3,a5
	sub.l	d4,a5
	bsr.b	MON_DISLENGTH_A5_CACH
	movem.l	(sp)+,d2-d6/a5
	cmp	d4,d1
	bne.b	C1BB9E
C1BB5E:
	moveq	#10,d6
	movem.l	d2-d6/a5,-(sp)
	sub.l	d2,a5
	sub.l	d3,a5
	sub.l	d4,a5
	sub.l	d5,a5
	bsr	MON_DISLENGTH_A5_CACH
	movem.l	(sp)+,d2-d6/a5
	cmp	d5,d1
	bne.b	C1BB9A
C1BB78:
	movem.l	d2-d6/a5,-(sp)
	sub.l	d2,a5
	sub.l	d3,a5
	sub.l	d4,a5
	sub.l	d5,a5
	sub.l	d6,a5
	bsr	MON_DISLENGTH_A5_CACH
	movem.l	(sp)+,d2-d6/a5
	cmp	d6,d1
	bne.b	C1BB96
	sub.l	d2,a5
	bra.b	C1BBAE

C1BB96:
	subq.w	#2,d6
	bne.b	C1BB78
C1BB9A:
	subq.w	#2,d5
	bne.b	C1BB5E
C1BB9E:
	subq.w	#2,d4
	bne.b	C1BB48
C1BBA2:
	subq.w	#2,d3
C1BBA4:
	bne.b	C1BB34
C1BBA6:
	subq.w	#2,d2
	bne	C1BB22
	subq.w	#2,a5
C1BBAE:
	rts

;*************** ASCII DUMP *****************

com_ascii_dump:
	bne.b	.nocare
	move.l	d0,(MEM_DIS_DUMP_PTR-DT,a4)
.nocare
	clr	(MON_EDIT_POSITION-DT,a4)
	lea	(Asciidump_stuff,pc),a0
	br	enter_hex_mode

AsciiCursor:
	move.l	(LineFromTop-DT,a4),d0
	add	d0,d0
	move	d0,(cursor_row_pos-DT,a4)
	moveq	#10,d0
	add.w	(MON_EDIT_POSITION-DT,a4),d0
	move	d0,(Cursor_col_pos-DT,a4)
	rts

AsciiKeys:
	cmp.b	#$80,d0
	beq.b	C1BBF6
	st	(reset_pos-DT,a4)
	cmp.b	#8,d0
	beq.b	C1BBF0
	bsr.b	C1BC56
	br	Monascii_move_right

C1BBF0:
	bsr.b	Monascii_move_left
	moveq	#$20,d0
	bra.b	C1BC56

C1BBF6:
	moveq	#0,d0
	move.b	(edit_EscCode-DT,a4),d0
	cmp.b	#2,d0
	beq.b	Monascii_move_left
	cmp.b	#3,d0
	beq.b	Monascii_move_right
	cmp.b	#10,d0
	beq.b	Mon_scroll_right
	cmp.b	#11,d0
	beq.b	Mon_scroll_left
	cmp.b	#6,d0
	beq.b	Monascii_move_to_line_start
	cmp.b	#7,d0
	beq.b	Monascii_move_to_line_end
	cmp.b	#$57,d0
	beq	C1B6A2
	rts

Mon_scroll_right:
	moveq	#-1,d0
	bra.b	Mon_scroll_leftright

Mon_scroll_left:
	moveq	#1,d0
Mon_scroll_leftright:
	add.l	(RegelPtrsIn-DT,a4),d0
	move.l	d0,-(sp)
	jsr	(RegTab_SETALLNOTUPD).l
	move.l	(sp)+,(RegelPtrsIn-DT,a4)
	st	(reset_pos-DT,a4)
	br	clear_input_buffer

C1BC56:
	lea	(RegelPtrsIn-DT,a4),a0
	move.l	(LineFromTop-DT,a4),d1

	IF MC020
	lea	(a0,d1.w*4),a0
	ELSE
	lsl.w	#2,d1
	add	d1,a0
	ENDC

	move.l	(a0),a1
	add	(MON_EDIT_POSITION-DT,a4),a1
	move.b	d0,(a1)
	moveq	#-1,d0
	move.l	d0,(a0)
	rts

Monascii_move_left:
	subq.w	#1,(MON_EDIT_POSITION-DT,a4)
	bpl.b	C1BC82
	bsr	Mon_scrolldown
Monascii_move_to_line_end:
	move	#63,(MON_EDIT_POSITION-DT,a4)
C1BC82:
	rts

Monascii_move_right:
	addq.w	#1,(MON_EDIT_POSITION-DT,a4)
	cmp	#64,(MON_EDIT_POSITION-DT,a4)
	bne.b	C1BC9A
	bsr	Mon_scrollup
Monascii_move_to_line_start:
	clr	(MON_EDIT_POSITION-DT,a4)
C1BC9A:
	rts

;******* ASCII druk line *********

AsciiDrukline:
	bsr	DissPrintCurrAddress
	moveq	#64-1,d1
	bsr.b	MoniAsciiLine_LenD1
	moveq	#75,d6
	bra	Sol_druk_line	;aantal=d6 buff=a1

MoniAsciiLine_LenD1:
	move.b	#'"',(a3)+

	btst	#0,(PR_OnlyAscii).l
	bne.b	.ascii_only
.print_chars:
	move.b	(a5)+,(a3)+
	dbra	d1,.print_chars

	bra.b	.Asciiklaar

.ascii_only:
	move.b	(a5)+,d0
	cmp.b	#' ',d0
	bge.b	.wel_ascii
	moveq	#'.',d0
.wel_ascii:
	move.b	d0,(a3)+
	dbra	d1,.ascii_only

.Asciiklaar:
	move.b	#'"',(a3)+
	rts

AsciiBack1line:
	sub	#64,a5
	rts

;************ BIN DUMP **************

com_BinDump:
	jsr	(GETNUMBERAFTEROK).l
com_BinMoni:
	bne.b	.custom
	move.l	d0,(MEM_DIS_DUMP_PTR-DT,a4)
.custom:
	moveq	#0,d0
	move.b	(OpperantSize-DT,a4),d0
	move.b	d0,(MemDumpSize-DT,a4)
	bsr	hex_2_ascii
	clr	(MON_EDIT_POSITION-DT,a4)
	lea	(BinDump_stuff,pc),a0
	bra	enter_hex_mode

;************ HEX DUMP **************

com_hexdump:
	bne.b	.custom
	move.l	d0,(MEM_DIS_DUMP_PTR-DT,a4)
.custom:
	moveq	#0,d0
	move.b	(OpperantSize-DT,a4),d0
	move.b	d0,(MemDumpSize-DT,a4)
	bsr	hex_2_ascii		;adres i guess
	clr	(MON_EDIT_POSITION-DT,a4)
	lea	(Hexdump_stuff,pc),a0
	br	enter_hex_mode

HexCursor:
	move.l	(LineFromTop-DT,a4),d0
	add	d0,d0
	move	d0,(cursor_row_pos-DT,a4)

	move	(MON_EDIT_POSITION-DT,a4),d0
	cmp	#32,d0
	bcc.b	C1BD7C
C1BD66:
	moveq	#0,d1
	move.b	(MemDumpSize-DT,a4),d1
	add	d1,d1
	divu	d1,d0
	move.l	d0,d2
	swap	d2
	addq.w	#1,d1
	mulu	d1,d0
	add	d2,d0
	bra.b	C1BD94

C1BD7C:
	moveq	#$10,d2
	moveq	#0,d1
	move.b	(MemDumpSize-DT,a4),d1
	divu	d1,d2
	add	d1,d1
	addq.w	#1,d1
	mulu	d1,d2
	addq.w	#1,d2
	sub	#$0020,d2
	add	d2,d0
C1BD94:
	add	#9,d0
	move	d0,(Cursor_col_pos-DT,a4)
	rts

;*** bin cursor ***

BinCursor:
	move.l	(LineFromTop-DT,a4),d0
	add	d0,d0
	move	d0,(cursor_row_pos-DT,a4)
	moveq	#0,d1
	move	(MON_EDIT_POSITION-DT,a4),d0
	cmp	#32,d0
	bcc.b	C1BDDE
	move.b	(MemDumpSize-DT,a4),d1
C1BDBE:
	lsl.w	#3,d1
	divu	d1,d0
	swap	d0
C1BDC4:
	move	d0,d1
	clr	d0
	swap	d0
	moveq	#10,d2
	cmp.b	#1,(MemDumpSize-DT,a4)
	beq.b	C1BDD8
	moveq	#18,d2
C1BDD8:
	mulu	d2,d0
	add	d1,d0
	bra.b	C1BDEC

C1BDDE:
	moveq	#8,d2
	cmp.b	#1,(MemDumpSize-DT,a4)
	beq.b	C1BDEA
	moveq	#4,d2
	cmp.b	#4,(MemDumpSize-DT,a4)
	bne.b	C1BDEA
	moveq	#2,d2
C1BDEA:
	add	d2,d0
C1BDEC:
	add	#10,d0
	move	d0,(Cursor_col_pos-DT,a4)
	rts

;*** bin keys ***

BinKeys:
	cmp.b	#$80,d0
	beq	C1BE94
	st	(reset_pos-DT,a4)
	lea	(RegelPtrsIn-DT,a4),a0
	move.l	(LineFromTop-DT,a4),d1

	IF MC020
	lea	(a0,d1.w*4),a0
	ELSE
	lsl.w	#2,d1
	add	d1,a0
	ENDC

	move.l	(a0),a1
	moveq	#-1,d1
	move.l	d1,(a0)
	cmp	#32,(MON_EDIT_POSITION-DT,a4)
	bcc.b	C1BE3C
	cmp.b	#8,d0
	beq	C1C008
	cmp.b	#"0",d0
	bcs.b	C1BE3A
	cmp.b	#"1",d0
	bls.b	C1BE66
C1BE3A:
	rts

C1BE3C:
	cmp.b	#8,d0
	beq	C1C030
	add	(MON_EDIT_POSITION-DT,a4),a1
	sub	#32,a1
	move.b	d0,(a1)
	addq.w	#1,(MON_EDIT_POSITION-DT,a4)
	cmp	#36,(MON_EDIT_POSITION-DT,a4)
	bcc.b	C1BE5C
	rts

C1BE5C:
	move	#32,(MON_EDIT_POSITION-DT,a4)
	br	Mon_scrollup

C1BE66:
	sub.b	#"0",d0
	moveq	#0,d1
	move	(MON_EDIT_POSITION-DT,a4),d1
	moveq	#8,d2
	divu	d2,d1
	swap	d1
	move	d1,d4
	clr	d1
	swap	d1
	subq.w	#1,d2
	sub	d4,d2
	tst.b	d0
	beq.b	C1BE8C
	bset	d2,(a1,d1.w)
	br	C1C01A

C1BE8C:
	bclr	d2,(a1,d1.w)
	br	C1C01A

C1BE94:
	moveq	#0,d0
	move.b	(edit_EscCode-DT,a4),d0
	cmp.b	#2,d0
	beq.b	C1BECC
	cmp.b	#3,d0
	beq.b	C1BEE2
	cmp.b	#10,d0
	beq	Mon_scroll_right
	cmp.b	#11,d0
	beq	Mon_scroll_left
	cmp.b	#6,d0
	beq.b	C1BEF4
	cmp.b	#7,d0
	beq.b	C1BEDA
	cmp.b	#$57,d0
	beq	C1B6A2
	rts

C1BECC:
	subq.w	#1,(MON_EDIT_POSITION-DT,a4)
	bpl.b	C1BEE0
	bsr	Mon_scrolldown
C1BEDA:
	move.w	#35,(MON_EDIT_POSITION-DT,a4)
C1BEE0:
	rts

C1BEE2:
	addq.w	#1,(MON_EDIT_POSITION-DT,a4)
	cmp.w	#36,(MON_EDIT_POSITION-DT,a4)
	bne.b	C1BEF8
	bsr	Mon_scrollup
C1BEF4:
	clr	(MON_EDIT_POSITION-DT,a4)
C1BEF8:
	rts

HexKeys:
	cmp.b	#$80,d0
	beq.b	C1BFA4
	st	(reset_pos-DT,a4)
	lea	(RegelPtrsIn-DT,a4),a0
	move.l	(LineFromTop-DT,a4),d1

	IF MC020
	lea	(a0,d1.w*4),a0
	ELSE
	lsl.w	#2,d1
	add	d1,a0
	ENDC

	move.l	(a0),a1
	moveq	#-1,d1
	move.l	d1,(a0)
	cmp	#' ',(MON_EDIT_POSITION-DT,a4)
	bcc.b	C1BF8E
	cmp.b	#8,d0
	beq	C1C008
	cmp.b	#'0',d0
	bcs.b	.klaar
	cmp.b	#'9',d0
	bls.b	.dec
	bclr	#5,d0
	cmp.b	#'A',d0
	bcs.b	.klaar
	cmp.b	#'F',d0
	bls.b	.hex
.klaar:
	rts

.hex:
	subq.b	#7,d0
.dec:
	sub.b	#'0',d0
	moveq	#15,d2
	move	(MON_EDIT_POSITION-DT,a4),d1
	lsr.w	#1,d1
	bcs.b	.oneven
	lsl.b	#4,d0
	lsl.b	#4,d2
.oneven:
	not.b	d2
	add	d1,a1
	and.b	(a1),d2
	or.b	d0,d2
	move.b	d2,(a1)
	br	C1C01A

C1BF8E:
	cmp.b	#8,d0
	beq	C1C030
	add	(MON_EDIT_POSITION-DT,a4),a1
	sub	#$0020,a1
	move.b	d0,(a1)
	br	C1C048

C1BFA4:
	moveq	#0,d0
	move.b	(edit_EscCode-DT,a4),d0
	cmp.b	#2,d0
	beq.b	Monhex_move_left
	cmp.b	#3,d0
	beq.b	Monhex_move_right
	cmp.b	#10,d0
	beq	Mon_scroll_right
	cmp.b	#11,d0
	beq	Mon_scroll_left
	cmp.b	#6,d0
	beq.b	Monhex_move_to_line_start
	cmp.b	#7,d0
	beq.b	Monhex_move_to_line_end
	cmp.b	#$57,d0
	beq	C1B6A2
	rts


Monhex_move_left:
	subq.w	#1,(MON_EDIT_POSITION-DT,a4)
	bpl.b	C1BFEE
	bsr	Mon_scrolldown
Monhex_move_to_line_end:
	move	#47,(MON_EDIT_POSITION-DT,a4)
C1BFEE:
	rts

Monhex_move_right:
	addq.w	#1,(MON_EDIT_POSITION-DT,a4)
	cmp	#48,(MON_EDIT_POSITION-DT,a4)
	bne.b	C1BFEE
	bsr	Mon_scrollup
Monhex_move_to_line_start:
	clr	(MON_EDIT_POSITION-DT,a4)
C1C026:
	rts


C1C008:
	subq.w	#1,(MON_EDIT_POSITION-DT,a4)
	bpl.b	C1C026
	move	#31,(MON_EDIT_POSITION-DT,a4)
	br	Mon_scrolldown

C1C01A:
	addq.w	#1,(MON_EDIT_POSITION-DT,a4)
	cmp	#32,(MON_EDIT_POSITION-DT,a4)
	blo.b	C1C026
	clr	(MON_EDIT_POSITION-DT,a4)
	br	Mon_scrollup


C1C030:
	subq.w	#1,(MON_EDIT_POSITION-DT,a4)
	cmp	#32,(MON_EDIT_POSITION-DT,a4)
	bhs.b	C1C026
	move	#47,(MON_EDIT_POSITION-DT,a4)
	br	Mon_scrolldown

C1C048:
	addq.w	#1,(MON_EDIT_POSITION-DT,a4)
	cmp	#48,(MON_EDIT_POSITION-DT,a4)
	blo.b	C1C026
	move	#32,(MON_EDIT_POSITION-DT,a4)
	br	Mon_scrollup

;********* Bin druk line ***********

BinDrukline:
	bsr	DissPrintCurrAddress
	moveq	#0,d1
	move.b	(MemDumpSize-DT,a4),d1
	move.b	(.NumBinParts-1,pc,d1.w),d1
.binlopje1:
	move.b	(MemDumpSize-DT,a4),d4
	move.b	#'%',(a3)+
.binlopje2:
	move.b	(a5)+,d0
	moveq	#8-1,d2
.binlopje3:
	moveq	#'0'/2,d3
	add.b	d0,d0
	addx.b	d3,d3
	move.b	d3,(a3)+
	dbra	d2,.binlopje3

	subq.b	#1,d4
	bgt.b	.binlopje2
	move.b	#" ",(a3)+
	dbra	d1,.binlopje1

	subq	#4,a5
	moveq	#4-1,d1
	bsr	MoniAsciiLine_LenD1

	moveq	#55,d6
	move.b	(MemDumpSize-DT,a4),d0
	subq.b	#1,d0
	beq.s	.bytesize
	subq.w	#4,d6
.bytesize:
	subq.b	#4-1,d0
	bne.s	.longwsize
	subq.w	#2,d6
.longwsize:
	bra.b	Sol_druk_line	;aantal=d6 buff=a1

.NumBinParts
	DC.B	4-1,2-1,0,1-1		; b, w, -, l

BinBack1line:
	subq	#4,a5
	rts


;****** hex druk line ******

HexDrukline:
	bsr	DissPrintCurrAddress

	lea	(HexToAscii).l,a2
	moveq	#16-1,d1
	move.b	(MemDumpSize-DT,a4),d4
	moveq	#0,d0
.lopje:
	move.b	(a5)+,d0
	moveq	#15,d2
	and	d0,d2
	lsr.w	#4,d0
	move.b	(a2,d0.w),(a3)+
	move.b	(a2,d2.w),(a3)+

	subq.b	#1,d4
	bne.b	.skip
	move.b	#' ',(a3)+
	move.b	(MemDumpSize-DT,a4),d4
.skip:
	dbra	d1,.lopje

	sub	#16,a5
	moveq	#16-1,d1
	bsr	MoniAsciiLine_LenD1

	moveq	#0,d0
	move.b	(MemDumpSize-DT,a4),d0
	moveq	#75,d6
	IF	MC020
	sub.w	(.MemOffsets-2,pc,d0.w*2),d6
	ELSE
	add.w	d0,d0
	sub.w	(.MemOffsets-2,pc,d0.w),d6
	ENDIF
	bra.b	Sol_druk_line	;aantal=d6 buff=a1

.MemOffsets:
	DC.W	0,8,0,12		; 1, 2, -, 4

HexBack1line:
	sub	#16,a5
	rts

;*********** afdruk test version ************

Sol_druk_line:
	movem.l	d0-a6,-(sp)

	move.l	a1,a5		;textbuffer

	move.l	(GfxBase-DT,a4),a6
	move.l	(Rastport-DT,a4),a1

	moveq	#0,d0		;x
	move.w	d7,d1		;y

	mulu.w	(EFontSize_y-DT,a4),d1

	add.w	(Scr_Title_sizeTxt-DT,a4),d1	;!2
	jsr	(_LVOMove,a6)

	move.l	a5,a0
;	lea	(regel_buffer-DT,a4),a0
	move.w	d6,d0		;count
	jsr	(_LVOText,a6)

	movem.l	(sp)+,d0-a6
	rts

;*********** INC IFF STUFF *************
;
;IncIFFstuff:
;	move	(a3)+,d0
;	and	d4,d0
;	cmp	#"FF"+$8000,d0	;inciFF
;	bne	s1
;	jmp	AsmIncIFFOK
;s1:
;	cmp	#"FF",d0	;inciFFp
;	BEQ.S	checkINCIFFP
;	jmp	HandleMacroos
;
;checkINCIFFP:
;	move	(A3)+,D0
;	and	D4,D0
;	cmp	#$5000!$8000,D0	;INCIFFP
;	BEQ.S	IncIFFPal
;	cmp	#$5300!$8000,D0	;INCIFFS
;	BEQ.W	IncIFFStrip
;	jmp	HandleMacroos

;********* INCIFF palet **********

IncIFFPal:
	bclr	#AF_INC_ASSIGN,d7
	bsr.w	HandleIncFileFromSrc

	sf	(palet12bit-DT,a4)
	clr	(ColorOffset-DT,a4)
	clr	(StartBank-DT,a4)

	cmp.b	#',',(a6)
	bne.b	ColorList12bit	;dus gewoon 12 bits colorlist
	addq.w	#1,a6
	IF	MC020
	move.w	(a6)+,d0
	ELSE
	move.b	(a6)+,d0
	lsl.w	#8,d0
	move.b	(a6)+,d0
	ENDIF
	cmp	#'12',d0	;12 bits colorlist
	beq.b	ColorList12bit
	cmp	#'24',d0	;24 bits colorlist
	beq.b	ColorList24bit

	and	#$DFDF,d0	;uppercase
	cmp	#'CE',d0	;CE copper ECS
	beq.b	coppercols12bit

	cmp	#'CA',d0	;CA copper AGA
	beq.b	coppercols24bit

errorinsyntax:
	jmp	HandleMacroos

ColorList12bit:
	sf	(palet12bit-DT,a4)
	bra.b	ColorList

ColorList24bit:
	st	(palet12bit-DT,a4)
	bra.b	ColorList

coppercols24bit:
	st	(palet12bit-DT,a4)
	cmp.b	#',',(a6)
	bne.s	coppercols12bit		;geen bank offset
	addq.w	#1,a6
	moveq	#-'0',d0
	add.b	(a6)+,d0
	cmp.b	#7,d0
	bhi.b	nogood
	move.b	d0,(StartBank+1-DT,a4)	;wel bank offset
	bra.b	coppercols12bit
nogood:
	subq.w	#2,a6			;mischien alleen color offset ?
coppercols12bit:
	move	#$180,(ColorOffset-DT,a4) ;default
	jsr	PARSE_GET_KOMMA_IF_ANY
	bne.s	ColorList
	JSR	Parse_GetDefinedValue
	cmp	#$180,d3
	blo.s	errorinsyntax
	cmp	#$180+32*2,d3
	bhs.s	errorinsyntax

	move	D3,(ColorOffset-DT,a4)
ColorList:

	MOVEM.L	d0-a6,(IFFRegsBase-DT,a4)
	MOVEM.L	D0/A6,-(SP)
	bsr	OpenOldFile
	MOVE.L	Bestand-DT(a4),D1
	LEA	ParameterBlok-DT(a4),A1
	MOVE.L	A1,D2
	MOVE.L	#2*USERPRG_STACK_SIZE,D3 ; 8kb
	MOVE.L	DosBase-DT(a4),A6
	JSR	(_LVORead,A6)
	MOVEM.L	(SP)+,D0/A6
	LEA	ParameterBlok-DT(a4),A1
	move	#(2*USERPRG_STACK_SIZE/2-1)-2,D6
SearchColMap:
	cmp.l	#"CMAP",(a1)+
	BEQ.S	OntravelKleuren
	subq.l	#2,a1
	DBRA	D6,SearchColMap

	BRA	ErrorOpenIFF

;************ INCIFF PALET **********

OntravelKleuren:
;	ADDQ.W	#4,A1
	MOVE.L	(A1)+,D6		;CMAP size

	tst.b	(palet12bit-DT,a4)
	bne.b	OntravelAGAkleuren

	DIVU	#3,D6
	EXT.L	D6
	cmp	#32,d6			;added this for EHB
	bls.s	.nrcolsOK
	tst	(ColorOffset-DT,a4)
	BEQ.S	.nrcolsOK
	moveq	#32,d6
.nrcolsOK
	move.l	d6,d0
	add.l	d0,d0
	tst	(ColorOffset-DT,a4)
	BEQ.S	.GenereerColorlist
	add.l	d0,d0
.GenereerColorlist
	move.l	d0,FileLength-DT(a4)

	BTST	#AF_BRATOLONG,d7
	BNE	CloseIFFBestand
	tst	d7	;passone
	BMI	CloseIFFBestand

	SUBQ.L	#1,D6			;nr cols
	MOVE.L	INSTRUCTION_ORG_PTR-DT(A4),A0
	ADD.L	CURRENT_ABS_ADDRESS-DT(A4),A0
NextColor:
	tst	(ColorOffset-DT,a4)
	BEQ.S	ColorLijst
	move	(ColorOffset-DT,a4),(A0)+
	ADDQ.W	#2,(ColorOffset-DT,a4)	;hmm moet eigenlijk niet hoger worden
ColorLijst:				;dan $180+32*2-2 = $1be
	move.b	(a1)+,d0		; Rr Gg Bb -> 0RGB
	lsl.w	#4,d0
	move.b	(a1)+,d0
	lsl.w	#4,d0
	move.b	(a1)+,d0
	lsr.w	#4,d0
	move	D0,(A0)+
	DBRA	D6,NextColor

	BRA	CloseIFFBestand

;*********** INCIFF AGA PALET ************

OntravelAGAkleuren:
	movem.l	d4-d5,-(sp)

	move	(StartBank-DT,a4),d5
	or.w	(ColorOffset-DT,a4),d5
	beq	MakeColorList24bit

	tst	(ColorOffset-DT,a4)
	bne.s	nodefaultoffset
	move	#$180,(ColorOffset-DT,a4)
nodefaultoffset:
	move	(ColorOffset-DT,a4),(coloffset2-DT,a4)

	divu	#3,D6
	ext.l	D6
	moveq	#31,d5				;minstens 1 bank
	add.l	d6,d5
	lsr.l	#5,d5				;hoeveel banken
	lsl.l	#3,d5				;4*2

	moveq	#31,d4
	and.w	d6,d4
	subq.w	#1,d4
	move	d4,(nrcols-DT,a4)

	lsl.l	#3,d6	;24bit
	MOVE.L	D6,FileLength-DT(a4)
	add.l	d5,FileLength-DT(a4)		;bank switching ook meetellen

	LSR.L	#2,D6

	move	(StartBank-DT,a4),d5		;bij bank 0 beginnen
	ror.w	#3,d5

	BTST	#AF_BRATOLONG,d7		;??????
	BNE	EindeAGAError
	tst	d7	;passone
	BMI	EindeAGAError

	SUBQ.L	#1,D6
	MOVE.L	INSTRUCTION_ORG_PTR-DT(A4),A0	;source bin ptr
	ADD.L	CURRENT_ABS_ADDRESS-DT(A4),A0	;offset pointer

	move	#$0106,(a0)+
	move	d5,(a0)
	or.w	#$0c40,(a0)+

	move.l	a1,(helpptrAGA-DT,a4)

	moveq	#4,d4
AGAkleurloopje:
	cmp	(nrcols-DT,a4),d6
	beq.s	nextbank
	cmp	#$1be,(ColorOffset-DT,a4)
	bls.s	Bovenste4Bits
nextbank:
	move	(coloffset2-DT,a4),(ColorOffset-DT,a4)

	tst	d4
	beq.s	AGAonderste

	moveq	#0,d4

	move.l	(helpptrAGA-DT,a4),a1	;pointer weer terug zetten begin bank
	move	#$0106,(a0)+
	move	d5,(a0)
	or.w	#$0e40,(a0)+		;bovenste bits

	move	#$180,(coloffset2-DT,a4);reset voor de rest vand e colrbanks

	bra.b	Bovenste4Bits
AGAonderste:
	moveq	#4,d4

	move.l	a1,(helpptrAGA-DT,a4)

	add	#$2000,d5		;select next bank
	move	#$0106,(a0)+
	move	d5,(a0)
	or.w	#$0c40,(a0)+		;onderste bits eerst


Bovenste4Bits:
	move	(ColorOffset-DT,a4),(A0)+
	ADDQ.W	#2,(ColorOffset-DT,a4)

	moveq	#$f,d2

	MOVE.B	(A1)+,D0	;red
	lsr.b	d4,d0
	and.w	d2,d0
	lsl.w	#4,d0
	MOVE.B	(A1)+,D1	;green
	lsr.b	d4,d1
	and.b	d2,d1
	or.b	d1,d0
	lsl.w	#4,d0
	move.b	(a1)+,d1	;blue
	lsr.b	d4,d1
	and.b	d2,d1
	or.b	d1,d0

	move	D0,(A0)+
	DBRA	D6,AGAkleurloopje

	bra.b	EindeAGAError

;************ 24 bit color list *************

MakeColorList24bit:
	divu	#3,D6
	ext.l	D6
	lsl.l	#2,d6		;nrcols*4
	move.l	D6,FileLength-DT(a4)

	lsr.l	#2,D6			;aantal woorden (nr colors)

	BTST	#AF_BRATOLONG,d7
	bne.b	EindeAGAError
	tst	d7	;passone
	bmi.b	EindeAGAError

	subq.l	#1,D6			;nr cols
	move.l	INSTRUCTION_ORG_PTR-DT(A4),A0
	add.l	CURRENT_ABS_ADDRESS-DT(A4),A0
NextColorAGA:
	clr.b	(a0)+
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+

	dbra	D6,NextColorAGA

;	bra	EindeAGAError

EindeAGAError:
	movem.l	(sp)+,d4-d5
;	BRA	CloseIFFBestand

CloseIFFBestand:
	BCLR	#2,SomeBits-DT(a4)
	MOVE.L	Bestand-DT(a4),D1
	MOVE.L	DosBase-DT(a4),A6
	JSR	(_LVOClose,A6)

;	jsr	close_bestand

	MOVE.L	FileLength-DT(a4),D0
	ADD.L	D0,INSTRUCTION_ORG_PTR-DT(A4)
	MOVEM.L	(IFFRegsBase-DT,a4),d0-a6
	RTS

ErrorOpenIFF:
	MOVEM.L	(IFFRegsBase-DT,a4),D0-A6
	JMP	ERROR_EndofFile

;********** STRIP IFF STUFF ***********

IncIFFStrip:
	bclr	#AF_INC_ASSIGN,d7
	bsr.w	HandleIncFileFromSrc

	MOVEM.L	d0-a6,(IFFRegsBase-DT,a4)

	bsr	OpenOldFile
	MOVE.L	Bestand-DT(a4),D1
	beq.s	striperror_openfile

	MOVE.L	DosBase-DT(a4),A6
	move	#$2000/4,d7
.striploop:
	MOVE.L	Bestand-DT(a4),D1
	lea	(strip_buffer-DT,a4),a5
	move.l	a5,d2
	moveq	#4,D3			;4 bytes
	JSR	(_LVORead,A6)
	cmp.l	d3,d0			;# bytes gelezen
	bne.s	striperror_openfile

	CMP.L	#"BODY",(A5)
	BEQ.S	stripfoundbody
	dbf	d7,.striploop

	bsr.b	CloseIFFBestand
	JMP	ERROR_EndofFile

striperror_openfile:
	MOVEM.L	(IFFRegsBase-DT,a4),D0-A6
	JMP	ERROR_EndofFile

stripfoundbody:
	MOVE.L	Bestand-DT(a4),D1
	lea	(strip_buffer-DT,a4),a0
	move.l	a0,d2
	moveq	#4,D3			;4 bytes
	MOVE.L	DosBase-DT(a4),A6
	JSR	(_LVORead,A6)
	cmp.l	d3,d0			;# bytes gelezen
	bne.s	striperror

	move.l	(strip_buffer-DT,a4),d7

	clr.l	FileLength-DT(A4)

	MOVEM.L	D0-A6,-(SP)

	MOVE.L	Bestand-DT(a4),D1	;bestand
	move.l	INSTRUCTION_ORG_PTR-DT(A4),d2	;buffer
	add.l	CURRENT_ABS_ADDRESS-DT(A4),d2
	MOVE.L	d7,D3			;size
	MOVE.L	d7,D0			;size

;	jsr	read_nr_d3_bytes
;	moveq	#4,D3			;size

	MOVE.L	DosBase-DT(a4),A6
;	JSR	-$002A(A6)		;read
;	cmp.l	d7,d0
;	bne.s	striperror
	move.l	d0,FileLength-DT(A4)

	MOVEM.L	(SP)+,D0-A6

	BRA	CloseIFFBestand

striperror:
	MOVEM.L	(SP)+,D0-A6
	bsr	CloseIFFBestand
	JMP	ERROR_EndofFile

;********** END IFF STUFF *************

;********** PLUG-IN STUFF *************

	IF useplugins
_E_Showplugs:
	bsr	open_plugs_win

;	jsr	test1
;	bsr	close_plugs_win

	rts

Plugs_check_plugsmsg:
	movem.l	d0-a6,-(sp)

	move.l	d0,a0
	move.l	20(a0),d0
	and.l	#$200,d0	;closebox?
	beq.s	.arggg
	bsr	close_plugs_win
.arggg:
	move.l	(DosBase-DT,A4),A6	;ffwachte
	moveq	#2,d1
	jsr	_LVODelay(a6)

	move.l	(IntBase-DT,a4),a6
	move.l	(MainWindowHandle-DT,a4),a0
	jsr	(_LVOActivateWindow,a6)
.NoMsgInBase:
	movem.l	(sp)+,d0-a6
	rts


Plugs_update_info:
	move.l	(IntBase-DT,a4),a6
	move.b	#'1',PW_IText0
	moveq	#6-1,d7
	moveq	#0,d5
	moveq	#6,d4
	add.w	(EFontSize_y-DT,a4),d4
.lopje:
	move.l	(Plugs_rp,pc),a0
	lea	(Plugs_Itext,pc),a1
	moveq	#0,d0
	move.l	d5,d1
	jsr	_LVOPrintIText(a6)
	add.l	d4,d5

	addq.b	#1,PW_IText0
	dbf	d7,.lopje
	rts

Plugs_WindowTags:
pw_x:
	DC.L	WA_Left,0	;x
pw_y:
	DC.L	WA_Top,32+202+11	;y
pw_br:
	DC.L	WA_Width,22*8+6	;br
pw_hg:
	DC.L	WA_Height,6*(8+6)+11-1	;hg
	DC.L	WA_IDCMP,IDCMP_ACTIVEWINDOW|IDCMP_CLOSEWINDOW
	DC.L	WA_Flags,WFLG_CLOSEGADGET|WFLG_DEPTHGADGET|WFLG_DRAGBAR|WFLG_GIMMEZEROZERO
	DC.L	WA_Title,Plugs_WTitle
Plugs_SC:
	DC.L	$80000079,0
	DC.L	TAG_DONE

Plugs_WTitle:
	DC.B	'Active Plugin''s.',0


	cnop	0,4
Plugs_winbase:	dc.l	0
Plugs_rp:	dc.l	0
Plugs_msg_port:	dc.l	0


Plugs_Itext:
	DC.B	1,0
	DC.B	$00
	DC.B	0
	DC.W	4,6
	DC.L	Editor_Font
	DC.L	PW_IText0
	DC.L	0

PW_IText0:
	DC.B	'1 < No plugin loaded >',0

	cnop	0,4

open_plugs_win:
	tst.l	Plugs_winbase
	bne	close_plugs_win		;voor de zekerheid..
	movem.l	d0-a6,-(sp)

	moveq	#6,d2
	mulu.w	(EFontSize_y-DT,a4),d2
	add.w	#6*6+8,d2	;marge
	add.w	(Win_BorBottom-DT,a4),d2
	add.w	(Scr_Title_size-DT,a4),d2

	moveq	#0,d0
	move.w	(Scr_breedte-DT,a4),d0	;center the picture

	moveq	#22,d1
	mulu.w	(EFontSize_x-DT,a4),d1
	add.w	(Win_BorHor-DT,a4),d1
	add.w	#10,d1	;marge

	moveq	#16,d3			;16 puntjes van de linker kant
	sub.l	d3,d0
	sub.l	d1,d0

	lea	(pw_x+4,pc),a0
	move.l	d0,(a0)
	move.l	d1,(pw_br-pw_x,a0)
	move.l	d2,(pw_hg-pw_x,a0)

	move.l	(ScreenBase),Plugs_SC+4
	move.l	(IntBase-DT,a4),a6
	sub.l	a0,a0
	lea	Plugs_WindowTags(pc),a1
	jsr	_LVOOpenWindowTagList(a6)
	move.l	d0,Plugs_winbase

	move.l	d0,a0
	move.l	(wd_RPort,a0),Plugs_rp

	move.l	86(a0),Plugs_msg_port

	move.l	(KEY_PORT-DT,a4),86(a0)

	move.l	(GadToolsBase-DT,a4),a6

	move.l	50(a0),a0
	lea	(PW_NR,pc),a1
	move.l	(MainVisualInfo-DT,a4),(PW_NR+4-PW_NR,a1)
	move.l	(MainVisualInfo-DT,a4),(PW_IR+4-PW_NR,a1)
	clr.w	d0		;x
	clr.w	d1		;y
	moveq	#22,d2
	mulu.w	(EFontSize_x-DT,a4),d2
	add.w	#8+2,d2		;marge

	moveq	#6,d3
	mulu.w	(EFontSize_y-DT,a4),d3
	add.w	#6*6+7,d3	;marge
	jsr	_LVODrawBevelBoxA(a6)

	moveq	#6-1,d7

	moveq	#0,d6
	move.w	(EFontSize_y-DT,a4),d6
	addq.w	#6,d6

	move.w	(EFontSize_x-DT,a4),d0
	add.w	d0,d0
	add.w	(Win_BorLeft-DT,a4),d0
	move.w	d0,d4
	subq.w	#2,d4

	moveq	#4,d5			;y

	moveq	#20,d2
	mulu.w	(EFontSize_x-DT,a4),d2
	addq.w	#4,d2

	move.w	d6,d3			;hg
	subq.w	#2,d3
.lopje:
	move.l	(Plugs_rp,pc),a0
	lea	(PW_IR,pc),a1

	move.w	d4,d0		;x
	move.w	d5,d1		;y

	jsr	_LVODrawBevelBoxA(a6)
	add.w	d6,d5

	dbf	d7,.lopje

	bsr	Plugs_update_info

	move.l	(IntBase-DT,a4),a6
	move.l	(MainWindowHandle-DT,a4),a0
	jsr	(_LVOActivateWindow,a6)

	movem.l	(sp)+,d0-a6
	rts


close_plugs_win:
	movem.l	d0-a6,-(sp)

	move.l	Plugs_winbase(pc),d0
	beq.s	.aldicht
	move.l	d0,a0

	move.l	Plugs_msg_port(pc),86(a0)

	move.l	(IntBase-DT,a4),a6
	jsr	_LVOCloseWindow(a6)
	clr.l	Plugs_winbase
	clr.l	Plugs_rp

.aldicht:
	movem.l	(sp)+,d0-a6
	rts

;	ENDIF

;***************** PLUGS STUFF ********************

PlugIns:
	movem.l	d0-a6,-(sp)

	bsr.b	check_for_plugin
	tst.w	d0
	beq.b	gevonden
	movem.l	(sp)+,d0-a6
	jmp	HandleMacroos2

gevonden:
;	ADD.L	D1,INSTRUCTION_ORG_PTR-DT(A4)

	movem.l	(sp)+,d0-a6
	rts

errorstring:
	dc.b	10,"Plugin not found!",10,0
pluginstring:
	dc.b	10,"Plugin gevonden!",10,0
	cnop	0,4


check_for_plugin:
	lea	(SourceCode-DT,a4),a0
	lea	(pluginfilename,pc),a1
	move.w	#$5f5f,d4
.lopje:
	move.w	(a0)+,d0
	bmi.s	.exitlopje
	and.w	d4,d0
	move.w	d0,(a1)+
	bra.b	.lopje

.exitlopje:
	and.w	d4,d0
	move.w	d0,(a1)+
	clr.b	(a1)

	lea	(pluginlist,pc),a2
.check_next:
	cmp.l	#-1,(a2)
	beq.s	.plugin_not_in_buf

	move.l	(a2),a1
	addq.l	#8,a1
	add.w	(a1),a1			;name
	addq.l	#4,a2			;next item

	lea	(pluginfilename,pc),a0
.checkloopje:
	move.b	(a1)+,d0
	and.b	#$5f,d0
	beq.s	.gevonden
	cmp.b	(a0)+,d0
	bne.s	.check_next
	bra.b	.checkloopje

.gevonden:
	tst.b	(a0)
	bne.s	.check_next

;	lea	(SourceCode-DT,a4),a0
;.fdd
;	move.b	(a0)+,d0
;	bne.s	.fdd

	move.l	a6,a0
	bsr	printthetext

	lea	pluginstring(pc),a0
	bsr	printthetext

	moveq	#0,d0
	rts

.plugin_not_in_buf:
	lea	(pluginfilename,pc),a0
	bsr	printthetext
	lea	errorstring(pc),a0
	bsr	printthetext

	moveq	#1,d0
	rts

pluginpath:
	dc.b	"dh1:asmpro_os/plugins/"
pluginfilename:
;	dc.b	"SOLO",0
	blk.b	80,0

	cnop	0,4

pluginlist:
	dc.l	pi_incspace
	dcb.l	10,-1


pi_incspace:
	dc.w	0100		;version of pluginsystem
	dr.w	constructor
	dr.w	destructor
	dr.w	incspace
	dr.w	name
	dr.w	syntax
	dr.w	about

name:
	dc.b	"solo",0
syntax:
	dc.b	"syntax: incspace {number bytes}",0
about:
	dc.b	"$VER: Incspace v1.0 by Solo/gnt (8-Dec-1996) "
	dc.b	"A part of the asm-pro plugin system.",0
	cnop	0,4

constructor:
	moveq	#0,d0	;error code
	rts

destructor:
	moveq	#0,d0	;error code
	rts

incspace:
	moveq	#0,d0	;error code
	rts


	ENDC	; useplugins

;******** END PLUG-IN STUFF ***********

PW_NR:	DC.L	GT_VisualInfo,0,TAG_DONE
PW_IR:	DC.L	GT_VisualInfo,0,GTBB_Recessed,1,TAG_DONE

;**************** LOGIN WINDOWTJE *****************

GetAvailMem:
	or.l	#MEMF_LARGEST,d1
	jsr	(_LVOAvailMem,a6)
	lsr.l	d3,d0
	cmp.l	d2,d0
	blo.b	.Capped
	move.l	d2,d0
.Capped	rts

OpenLoginWindow:
	move.l	4.w,a6
	lea	(LoginGTags,pc),a2
	move.l	#$7fff,d2	; 32mb is max due to UI
	moveq	#10,d3		; bytes to kb

	moveq	#MEMF_PUBLIC,d1
	bsr.b	GetAvailMem
	move.l	d0,(_pubmax-DT,a4)

	moveq	#MEMF_ANY,d1
	bsr.b	GetAvailMem
	move.l	d0,(_absmax-DT,a4)

	moveq	#MEMF_CHIP,d1
	bsr.b	GetAvailMem
	move.l	d0,(_chipmax-DT,a4)
	move.l	d0,(_chipmemTags+4-LoginGTags,a2)

	moveq	#MEMF_FAST,d1
	bsr.b	GetAvailMem

	lea	(_memorytypeLabels,pc),a0
	move.l	d0,(_fastmax-DT,a4)
	move.l	d0,(_fastmemTags+4-LoginGTags,a2)
	bne.b	.HaveFastMem			; Check for fast mem
	moveq	#MEMB_CHIP+1,d2
	move.l	d2,(_memtype-DT,a4)
	move.l	(_chipmax-DT,a4),(_memamount-DT,a4)
	lea	(_memorytypeLabelsNoFast,pc),a0
.HaveFastMem
	move.l	a0,(LoginGTags+4-LoginGTags,a2)

	move.l	(_StackSize-DT,a4),d0
	lsr.l	d3,d0
	move.l	d0,(_stack_sizeTags+4-LoginGTags,a2)

	move.l	(_memtype-DT,a4),d0
	lsl.w	#2,d0
	lea	(_absmax-DT,a4),a0
	move.l	(a0,d0.w),(_maxamountTags+4-LoginGTags,a2)

	move.l	(_memamount-DT,a4),(_curamountTags+4-LoginGTags,a2)

	lsr.w	#2,d0
	lea	(memstuff,pc),a0
	move.b	(a0,d0.w),d0
	move.l	d0,(_acticmx+4-LoginGTags,a2)

	moveq	#1,d2
	subq.w	#3,d0
	bne.b	.notabs
	moveq	#0,d2
.notabs
	move.l	d2,(_absolute_adrTags+4-LoginGTags,a2)

	lea	(_absolute_adrString,pc),a1
	move.b	#'$',(a1)+
	move.l	(_absmemadr-DT,a4),d0
	bsr	van_d0_2_string
	clr.b	(a1)

	moveq	#40,d0
	mulu.w	(EFontSize_x-DT,a4),d0
	move.w	d0,(LoginWidth-LoginGTags,a2)
	move.w	(Scr_breedte-DT,a4),d1
	sub.w	d0,d1
	lsr.w	#1,d1
	move.w	d1,(LoginLeft-LoginGTags,a2)

	moveq	#14,d0
	mulu.w	(EFontSize_y-DT,a4),d0
	add.w	#14*3+4,d0
	move.w	d0,(LoginHeight-LoginGTags,a2)
	move.w	(Scr_hoogte-DT,a4),d1
	sub.w	d0,d1
	lsr.w	#1,d1
	move.w	d1,(LoginTop-LoginGTags,a2)

	bsr	position_gadgets

	bsr	OpenTheLoginWindow
	tst.w	d0
	bne.b	li_erroropenwin
li_waitbeforclose:
	move.l	(DosBase-DT,a4),a6
	moveq	#4,d1		;delay
	jsr	(_LVODelay,a6)

	move.l 	(GadToolsBase-DT,a4),a6
	move.l	(LoginWnd-DT,a4),a0
	move.l	(wd_UserPort,a0),a0
	jsr	_LVOGT_GetIMsg(a6)
	tst.l	d0
	beq.b	li_nointuiactivity
	bsr.b	li_processmsg

	tst.w	d0		;leave now !!!
	bne.b	li_exit

li_nointuiactivity:
	IF Debugstuff
	btst	#7,$bfe001			; WHAT'S THAT !!!
	bne.b	li_waitbeforclose
	ELSE
	bra.b	li_waitbeforclose
	ENDIF

li_exit:
	move.l	(LoginGadgets+5*4-DT,a4),a0
	move.l	(gg_SpecialInfo,a0),a0	; gadget's StringInfo
	move.l	(a0),a6			; si_Buffer
	jsr	Convert_A2I_sub
;	jsr	Convert_A2I
	move.l	d3,(_absmemadr-DT,a4)

	move.l	(_memtype-DT,a4),d0
	lsl.l	#2,d0
	lea	(_absmax-DT,a4),a0
	move.l	(_memamount-DT,a4),d1
	cmp.l	(a0,d0.w),d1
	bls.b	.nixmis
	move.l	(a0,d0.w),(_memamount-DT,a4)
.nixmis:	

	bsr	CloseLoginWindow
li_erroropenwin
	moveq	#0,d0
	rts

memstuff:
	dc.b	3,2,0,1
memstuff2:
	dc.b	'APCF'

;************ check the messies ***********

li_processmsg:
	move.l	d0,a1
	move.l	(im_Class,a1),d2
	moveq	#0,d3
	move.w	(im_Code,a1),d3
	move.l	(im_IAddress,a1),a2		; gadget

	move.l	(GadToolsBase-DT,a4),a6
	jsr	_LVOGT_ReplyIMsg(a6)

	moveq	#IDCMP_GADGETDOWN!IDCMP_GADGETUP,d1
	and.l	d2,d1
	beq.b	.CheckKeys
	move.w	(gg_GadgetID,a2),d4

	cmp.w	#GD__memorytype,d4
	bne.b	.nextbutton1
	lea	(_maxamountTags,pc),a3
	moveq	#1,d0
	move.l	d0,(_absolute_adrTags_change+4-_maxamountTags,a3)
	lea	SelectMemTable(pc),a0
	cmp.l	#_memorytypeLabelsNoFast,(LoginGTags+4-_maxamountTags,a3)
	bne.b	.HaveFast
	lea	SelectMemTableNoFast(pc),a0
.HaveFast
	IF	MC020
	add.w	(a0,d3.w*2),a0
	ELSE
	add.w	d3,d3
	add.w	(a0,d3.w),a0
	ENDIF
	move.l	(_memamount-DT,a4),d0
	jsr	(a0)
	move.l	d0,(4,a3)
	move.l	d1,(_memtype-DT,a4)

	move.l 	(GadToolsBase-DT,a4),a6
	move.l	(LoginGadgets+1*4-DT,a4),a0
	move.l	(LoginWnd-DT,a4),a1
	sub.l	a2,a2
	jsr	_LVOGT_SetGadgetAttrsA(a6)	; slider max

	move.l	(LoginGadgets+5*4-DT,a4),a0
	move.l	(LoginWnd-DT,a4),a1
	sub.l	a2,a2
	lea	_absolute_adrTags_change(pc),a3
	jsr	_LVOGT_SetGadgetAttrsA(a6)	; abs. address on/off

.nextbutton1
	cmp.w	#GD__Workspace,d4	; slider?
	bne.b	.nextbutton2
	move.l	d3,(_memamount-DT,a4)
.nextbutton2
	cmp.w	#GD__okay,d4
	beq.b	.Exit

.CheckKeys
	and.l	#IDCMP_VANILLAKEY,d2
	beq.b	.NoExit
	cmp.b	#13,d3			; enter?
	beq.b	.Exit
	and.b	#~32,d3
	cmp.b	#'O',d3			; o(k)?
	beq.b	.Exit
.NoExit	moveq	#0,d0
	rts
.Exit	moveq	#1,d0			; signal exit
	rts


SelectMemTable:
	dc.w	SelectMemChip-SelectMemTable
	dc.w	SelectMemFast-SelectMemTable
	dc.w	SelectMemPub-SelectMemTable
	dc.w	SelectMemAbs-SelectMemTable

SelectMemTableNoFast:
	dc.w	SelectMemChip-SelectMemTableNoFast
	dc.w	SelectMemPub-SelectMemTableNoFast
	dc.w	SelectMemAbs-SelectMemTableNoFast

SelectMemAbs:
	clr.l	(_absolute_adrTags_change+4-_maxamountTags,a3)
	move.l	(_absmax-DT,a4),d0
	moveq	#0,d1
	rts

SelectMemChip:
	move.l	d0,(_curamountTags+4-_maxamountTags,a3)
	move.l	(_chipmax-DT,a4),d0
	moveq	#MEMB_CHIP+1,d1
	rts

SelectMemFast:
	move.l	d0,(_curamountTags+4-_maxamountTags,a3)
	move.l	(_fastmax-DT,a4),d0
	moveq	#MEMB_FAST+1,d1
	rts

SelectMemPub:
	move.l	d0,(_curamountTags+4-_maxamountTags,a3)
	move.l	(_pubmax-DT,a4),d0
	moveq	#MEMB_PUBLIC+1,d1
	rts

;************ INTUI STUFF **************************

GD__memorytype			EQU	0
GD__Workspace			EQU	1
GD__stack_size			EQU	2
GD__fastmem			EQU	3
GD__chipmem			EQU	4
GD__absolute_adr		EQU	5
GD__standard_dir		EQU	6
GD__okay			EQU	7
GD__border			EQU	8

Login_CNT			EQU	8

;TD:	DC.L	TAG_DONE
NR:	DC.L	GT_VisualInfo,0,TAG_DONE
IR:	DC.L	GT_VisualInfo,0,GTBB_Recessed,1,TAG_DONE

LoginLeft:
	DC.W	163
LoginTop:
	DC.W	142
LoginWidth:
	DC.W	320-6
LoginHeight:
	DC.W	180-9-2

LoginGTypes:
	DC.W	MX_KIND		;1
	DC.W	SLIDER_KIND	;2
	DC.W	NUMBER_KIND	;3
	DC.W	NUMBER_KIND	;4
	DC.W	NUMBER_KIND	;5
	DC.W	STRING_KIND	;6
	DC.W	TEXT_KIND	;7
	DC.W	BUTTON_KIND	;8
;	dc.w	TEXT_KIND	;9

LoginNGads:	; struct NewGadget
	DC.W	010+1,046+1,017,009
	DC.L	_memorytypeText,0
	DC.W	GD__memorytype
	DC.L	PLACETEXT_RIGHT,0,0

	DC.W	004+1,025+1,109,013
	DC.L	_WorkspaceText,0
	DC.W	GD__Workspace
	DC.L	PLACETEXT_ABOVE,0,0

	DC.W	264+1,025+1,035,018
	DC.L	_stack_sizeText,0
	DC.W	GD__stack_size
	DC.L	PLACETEXT_LEFT,0,0

	DC.W	198+1,065+1,101,014
	DC.L	_fastmemText,0
	DC.W	GD__fastmem
	DC.L	PLACETEXT_LEFT,0,0

	DC.W	198+1,045+1,101,017
	DC.L	_chipmemText,0
	DC.W	GD__chipmem
	DC.L	PLACETEXT_LEFT,0,0

	DC.W	198+1,081+1,101,017
	DC.L	_absolute_adrText,0
	DC.W	GD__absolute_adr
	DC.L	PLACETEXT_LEFT,0,0

	DC.W	004+1,142+1,295,017
	DC.L	_standard_dirText,0
	DC.W	GD__standard_dir
	DC.L	PLACETEXT_ABOVE,0,0

	DC.W	004+1,104+1,049,021
	DC.L	_okayText,0
	DC.W	GD__okay
	DC.L	PLACETEXT_IN,0,0

;	dc.w	6,13+2,$018D,$005A-2
;	dc.l	0,0
;	dc.w	GD__border
;	dc.l	PLACETEXT_ABOVE,0,0

LoginGTags:
	DC.L	GTMX_Labels,_memorytypeLabels
_acticmx:
	DC.L	GTMX_Active,1
	DC.L	GT_Underscore,'_'
	DC.L	GTMX_Spacing,3
	DC.L	TAG_DONE
_maxamountTags:
	DC.L	GTSL_Max,1024
_curamountTags:
	DC.L	GTSL_Level,512
	DC.L	GTSL_MaxLevelLen,10		; update format below if changed
	DC.L	GTSL_LevelFormat,_WorkspaceFormat
	DC.L	GTSL_LevelPlace,PLACETEXT_RIGHT
	DC.L	PGA_Freedom,AUTOKNOB
	DC.L	GA_RelVerify,1
	DC.L	TAG_DONE
_stack_sizeTags:
	DC.L	GTNM_Number,0
	DC.L	GTNM_Border,1
	DC.L	TAG_DONE
_fastmemTags:
	DC.L	GTNM_Number,0
	DC.L	GTNM_Border,1
	DC.L	TAG_DONE
_chipmemTags:
	DC.L	GTNM_Number,0
	DC.L	GTNM_Border,1
	DC.L	TAG_DONE
_absolute_adrTags:
	DC.L	GA_Disabled,1
	DC.L	GTST_String,_absolute_adrString
	DC.L	GTST_MaxChars,12
	DC.L	GT_Underscore,'_'
	DC.L	TAG_DONE
_dirstringTags:
	DC.L	GTTX_Text,_standard_dirString
	DC.L	GTTX_Border,1
	DC.L	TAG_DONE

	DC.L	GT_Underscore,'_'	; ok button
	DC.L	TAG_DONE

_absolute_adrTags_change:
	DC.L	GA_Disabled,1
	DC.L	GTST_String,_absolute_adrString
	dc.l	TAG_DONE

;	dc.l	GTTX_Border,1,0,-1	 2

_WorkspaceFormat:
	DC.B	'%-10lu',0		; update length above if changed

_absolute_adrString:
	DC.B	'$00060000',0,0,0,0	; 12 chars max

_standard_dirString:
	DC.B	'> not changed <',0

_memorytypeText:
	DC.B	0

_WorkspaceText:
	DC.B	'Workspace (KB)',0

_stack_sizeText:
	DC.B	'Stack (KB)',0

_fastmemText:
	DC.B	'Fast',0

_chipmemText:
	DC.B	'Chip',0

_absolute_adrText:
	DC.B	'Address',0

_standard_dirText:
	DC.B	'Changed standard directory to',0

_okayText:
	DC.B	'_OK',0

_memorytypeLab0:	dc.b	'_Chipmem',0
_memorytypeLab1:	dc.b	'_Fastmem',0
_memorytypeLab2:	dc.b	'_Publicmem',0
_memorytypeLab3:	dc.b	'_Absolute',0
	EVEN

_memorytypeLabels:	dc.l	_memorytypeLab0
			dc.l	_memorytypeLab1
			dc.l	_memorytypeLab2
			dc.l	_memorytypeLab3
			dc.l	0

_memorytypeLabelsNoFast:
			dc.l	_memorytypeLab0
			dc.l	_memorytypeLab2
			dc.l	_memorytypeLab3
			dc.l	0

LoginWindowTags:
LoginL:	DC.L	WA_Left,0
LoginT:	DC.L	WA_Top,0
LoginW:	DC.L	WA_Width,0
LoginH:	DC.L	WA_Height,0
	DC.L	WA_IDCMP,$00200074
	DC.L	WA_Flags,WFLG_ACTIVATE|WFLG_BORDERLESS|WFLG_NOCAREREFRESH
LoginWG:
	DC.L	WA_Gadgets,0
	DC.L	WA_Title,0
LoginSC:
	DC.L	WA_PubScreen,0
	DC.L	TAG_DONE

gadspos:
	dc.w	02,03,02,0	;memtype
	dc.w	02,01,14,1	;workspace
	dc.w	33,00,04,1	;stacksize
	dc.w	29,02,08,1	;fastmem
	dc.w	29,04,08,1	;chip
	dc.w	25,06,12,1	;public
	dc.w	01,09,36,1	;dir
	dc.w	02,11,34,1	;okay


position_gadgets:
	lea	gadspos(pc),a0
	lea	LoginNGads(pc),a1
	moveq	#Login_CNT-1,d7
pos_gadgets:
	movem.w	(EFontSize_xy-DT,a4),d1/d2
	addq.w	#3,d2
.Loop
	move.w	(a0)+,d0
	mulu.w	d1,d0
	move.w	d0,(a1)+	; left
	move.w	(a0)+,d0
	muls.w	d2,d0
	bpl.b	.NoAdjust
	neg.w	d0
	addq.w	#2,d0		; move down by 2 lines
.NoAdjust
	addq.w	#4,d0
	move.w	d0,(a1)+	; top
	move.w	(a0)+,d0
	mulu.w	d1,d0
	move.w	d0,(a1)+	; width
	move.w	(a0)+,d0
	mulu.w	d2,d0
	addq.w	#4,d0
	move.w	d0,(a1)+	; height
	lea	(gng_SIZEOF-4*2,a1),a1
	dbf	d7,.Loop
	rts


LoginRender:
	movem.l	d0-d5/a0-a2/a6,-(sp)

	move.l	(GadToolsBase-DT,a4),a6
	move.l	(LoginWnd-DT,a4),a0
	move.l	(wd_RPort,a0),a2

;rond gadgets
	move.l	a2,a0
	lea	(IR,pc),a1
	move.l	(MainVisualInfo-DT,a4),(4,a1)
	movem.w	(EFontSize_xy-DT,a4),d0/d1
	moveq	#14,d2
	mulu.w	d0,d2
	move.w	d1,d3
	lsl.w	#1,d0
	addq.w	#3,d1
	lsl.w	#2,d1
	addq.w	#6,d2
	lsl.w	#2,d3
	add.w	#3<<2+6,d3
	jsr	_LVODrawBevelBoxA(a6)

	move.l	a2,a0
	lea	(NR,pc),a1
	move.l	(MainVisualInfo-DT,a4),(4,a1)
	moveq	#2,d0
	moveq	#2,d1
	move.w	LoginWidth(pc),d2
	subq.w	#4,d2
	move.w	LoginHeight(pc),d3
	subq.w	#4,d3
	jsr	_LVODrawBevelBoxA(a6)

	move.l	a2,a0
	lea	(NR,pc),a1
	moveq	#1,d0	;x
	moveq	#1,d1	;y
	move.w	LoginWidth(pc),d2
	subq.w	#2,d2
	move.w	LoginHeight(pc),d3
	subq.w	#2,d3
	jsr	_LVODrawBevelBoxA(a6)

	movem.l	(sp)+,d0-d5/a0-a2/a6
	rts

OpenTheLoginWindow:
	movem.l	d1-d4/a0-a3/a5/a6,-(sp)

	move.l	(ScreenBase),a0
	move.l	a0,(LoginSC+4)

;	move.w	12(a0),d3	;center the login win
;	sub.w	#320,d3
;	lsr.w	#1,d3
;	move.w	d3,LoginLeft
;
;	move.w	14(a0),d3	;center the login win
;	sub.w	#170,d3
;	lsr.w	#1,d3
;	move.w	d3,LoginTop

	moveq	#0,d2
	move.b	(sc_WBorLeft,a0),d2
	move.l	(sc_Font,a0),a1
	move.w	(ta_YSize,a1),d3
	add.b	(sc_WBorTop,a0),d3
	addq.w	#1,d3
;	add.b	(sc_WBorTop,a0),d0
;	ext.w	d0
;	add.w	d0,d3
	move.l	(GadToolsBase-DT,a4),a6
	lea	(LoginGList-DT,a4),a0
	jsr	_LVOCreateContext(a6)
	move.l	d0,a3
	tst.l	d0
	beq	LoginCError
	movem.w	d2-d3,-(sp)
	moveq	#0,d3
	lea	(LoginGTags,pc),a5	;mag eigenlijk niet he..
LoginGL:
	lea	(LoginNGads,pc),a0
	lea	(BufNewGad-DT,a4),a1
	jsr	(Prefs_CopyGadget_A0_A1)

	lea	(BufNewGad-DT,a4),a0
	move.l	(MainVisualInfo-DT,a4),(gng_VisualInfo,a0)
	move.l	#Editor_Font,(gng_TextAttr,a0)
	move.l	(sp),d0
	add.l	d0,(a0)		; gng_LeftEdge/gng_TopEdge
	lea	(LoginGTypes,pc),a0
	moveq	#0,d0
	IF	MC020
	move.w	(a0,d3.l*2),d0
	ELSE
	add.l	d3,a0
	add.l	d3,a0
	move.w	(a0),d0
	ENDIF
	move.l	a3,a0
	lea	(BufNewGad-DT,a4),a1
	move.l	a5,a2
	jsr	_LVOCreateGadgetA(a6)
	tst.l	d0
	bne.s	LoginCOK
	movem.w	(sp)+,d2-d3
	bra	LoginGError
LoginCOK:
	move.l	d0,a3
	lea	(LoginGadgets-DT,a4),a0
	IF	MC020
	move.l	a3,(a0,d3.l*4)
	ELSE
	move.l	d3,d0
	asl.l	#2,d0
	move.l	a3,(a0,d0.l)
	ENDIF
LoginTL:
	tst.l	(a5)
	beq.s	LoginDN
	addq.l	#8,a5
	bra.b	LoginTL
LoginDN:
	addq.l	#4,a5
	addq.w	#1,d3
	cmp.w	#Login_CNT,d3
	bmi.b	LoginGL

	movem.w	(sp)+,d2-d3
	move.l	(LoginGList-DT,a4),LoginWG+4

	lea	(LoginL+4,pc),a0
	moveq	#0,d0
	move.w	(LoginLeft,pc),d0
	move.l	d0,(a0)
	move.w	(LoginTop,pc),d0
	move.l	d0,(LoginT-LoginL,a0)
	move.w	(LoginWidth,pc),d0
	move.l	d0,(LoginW-LoginL,a0)
	move.w	(LoginHeight,pc),d0
	add.w	d3,d0
	move.l	d0,(LoginH-LoginL,a0)
	move.l	(IntBase-DT,a4),a6
	suba.l	a0,a0
	lea	(LoginWindowTags,pc),a1
	jsr	_LVOOpenWindowTagList(a6)
	move.l	d0,(LoginWnd-DT,a4)
	beq.b	LoginWError
	move.l	(GadToolsBase-DT,a4),a6
	move.l	d0,a0
	suba.l	a1,a1
	jsr	_LVOGT_RefreshWindow(a6)
	bsr.w	LoginRender
	moveq	#0,d0
LoginDone:
	movem.l	(sp)+,d1-d4/a0-a3/a5/a6
	rts
LoginCError:
	moveq	#1,d0
	bra.b	LoginDone
LoginGError:
	moveq	#2,d0
	bra.b	LoginDone
LoginWError:
	moveq	#4,d0
	bra.b	LoginDone


CloseLoginWindow:
	movem.l	d0-d1/a0-a2/a6,-(sp)
	move.l	(LoginWnd-DT,a4),d0
	beq.s	LoginNGad
	move.l  d0,a0
	move.l	(IntBase-DT,a4),a6
	jsr	_LVOCloseWindow(a6)
	clr.l	(LoginWnd-DT,a4)
	move.l	(LoginGList-DT,a4),d0
	beq.b	LoginNGad
	move.l	d0,a0
	move.l	(GadToolsBase-DT,a4),a6
	jsr	_LVOFreeGadgets(a6)
	clr.l	(LoginGList-DT,a4)
LoginNGad:
	movem.l	(sp)+,d0-d1/a0-a2/a6
	rts

;************** Einde LOGIN WINDOWTJE **************

	CNOP	0,4
realend2:

;***********************************************
;**         INTUITION STUFF SECTION           **
;***********************************************

	SECTION	Intuition_stuff,CODE

;****************************************************
;*             OPZETTEN VAN HET SYSTEEM             *
;****************************************************
setup_int_stuff:
	bsr	SetCorrectMarkKeys
	bsr	init_edit_font
	bsr.b	closewb
	bsr	openreqtoolslib

	moveq	#'0',d0
	add.b	(CurrentSource-DT,a4),d0
	move.b	d0,(SourceNrInBalk)

	bsr	openscreen
	bsr	openwindow
	jsr	(GetTheTime)	;init tijd en datumstring's
	bsr	InitAllMenus
	bsr	Change2Commmenu
	bra	OpenConDevice

closewb:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	(IntBase-DT,a4),a6
	move.w	#_LVOOpenWorkBench,d0
	btst	#0,(PR_CloseWB).l
	beq.b	.C1DE6E
	moveq	#_LVOCloseWorkBench,d0
.C1DE6E	jsr	(a6,d0.w)
	movem.l	(sp)+,d0-d7/a0-a6
	rts

ChangeSource:
	jsr	(Druk_Clearbuffer)
	clr.l	(Cursor_pos-DT,a4)	; col, row
	jsr	(Druk_Clearbuffer)

ReinitStuff:
	bsr	CloseConDevice
	bsr	FreeAllMenus
	bsr	closewindow
	bsr	closescreen

	moveq	#'0',d0
	add.b	(CurrentSource-DT,a4),d0
	move.b	d0,(SourceNrInBalk).l

	bsr.b	openscreen
	bsr	openwindow
	movem.l	d0-d7/a0-a6,-(sp)
	bsr.w	InitAllMenus
	moveq	#0,d0
	move.b	(menu_tiepe-DT,a4),d0
	lea	(Comm_menubase-DT,a4),a0

	IF MC020
	move.l	(a0,d0.w*4),d0
	ELSE
	lsl.w	#2,d0
	move.l	(a0,d0.w),d0
	ENDC

	bsr	Change_2menu_d0
	movem.l	(sp)+,d0-d7/a0-a6
	bra	OpenConDevice

OpenScreenOnePlane:
	move.w	#1,(Scr_NrPlanes-DT,a4)
;	bset	#0,(PR_OnePlane).l

openscreen:
	lea	(DiepteScherm+2,pc),a0
	move.w	(Scr_NrPlanes-DT,a4),(a0)

;	moveq	#0,d0
;	move.l	DiepteScherm(pc),d0
;	move.l	(SchermMode,pc),d1
;	jsr	test_debug

	moveq	#-1,d0
	cmp.l	(SchermMode,pc),d0
	beq.s	.openscrreq

	sub.l	a0,a0
	lea	(NewScreenTagList,pc),a1
	move.l	(IntBase-DT,a4),a6
	jsr	(_LVOOpenScreenTagList,a6)

	tst.l	d0
	bne.b	.gelukt
.openscrreq:
	bsr	OpenScreenReq
	sub.l	a0,a0
	lea	(NewScreenTagList,pc),a1
	move.l	(scrmode_new-DT,a4),(SchermMode-NewScreenTagList,a1)

	move.l	(IntBase-DT,a4),a6
	jsr	(_LVOOpenScreenTagList,a6)

;	tst.l	d0
;	bne.w	.gelukt
	;exit(-1)

.gelukt:
	lea	(ScreenBase,pc),a0
	move.l	d0,(a0)
	move.l	d0,(ScreenBase2-ScreenBase,a0)
	bne.b	.ok
	rts
.ok:
	move.l	d0,a0
	move.b	(sc_BarHeight,a0),d0
	addq.b	#1,d0
	move.b	d0,(Scr_Title_size+1-DT,a4)
	move.b	d0,(Win_BorVerT+1-DT,a4)

	move.l	(Fontbase_edit-DT,a4),a1
	add.b	(tf_Baseline+1,a1),d0	;distance from top to baseline 
	move.b	d0,(Scr_Title_sizeTxt+1-DT,a4)

	move.w	(sc_Width,a0),(Scr_breedte-DT,a4)
	move.w	(sc_Height,a0),(Scr_hoogte-DT,a4)

	move.b	(sc_WBorTop,a0),d0
	move.b	d0,(Win_BorTop+1-DT,a4)
	move.b	(sc_WBorBottom,a0),d1
	move.b	d1,(Win_BorBottom+1-DT,a4)
	add.b	d1,(Win_BorVerT+1-DT,a4)
	add.b	d1,d0
	move.b	d0,(Win_BorVer+1-DT,a4)

	move.b	(sc_WBorLeft,a0),d0
	move.b	d0,(Win_BorLeft+1-DT,a4)
	move.b	(sc_WBorRight,a0),d1
	move.b	d1,(Win_BorRight+1-DT,a4)
	add.b	d1,d0
	move.b	d0,(Win_BorHor+1-DT,a4)

	moveq	#0,d0
	move.w	(sc_Width,a0),d0
	divu.w	(EFontSize_x-DT,a4),d0
	move.w	d0,(Scr_br_chars-DT,a4)

	lea	(sc_ViewPort,a0),a0
	move.l	a0,(ViewPortBase-DT,a4)

	cmp.b	#2,(PaletteStatus-DT,a4)	; have loaded palette (prefs file)?
	bne.b	.C1E100
	jsr	(SetPaletteRGB).l		; yes, apply it
	bra.b	.C1E112
.C1E100	cmp.b	#1,(PaletteStatus-DT,a4)	; have active palette?
	beq.b	.C1E114
.C1E112	jsr	(GetPaletteRGB).l		; no, get active palette
	move.b	#1,(PaletteStatus-DT,a4)
.C1E114	jsr	(SetPaletteRGB).l

	move.l	(ScreenBase,pc),a0
	lea	(EmptyScreenTagList,pc),a1
	move.l	(GadToolsBase-DT,a4),a6
	jsr	(_LVOGetVisualInfoA,a6)
	move.l	d0,(MainVisualInfo-DT,a4)
	bsr	IetsMetScreenHight

noscreen2close:
	rts

closescreen:
	move.l	(MainVisualInfo-DT,a4),a0
	move.l	(GadToolsBase-DT,a4),a6
	jsr	(_LVOFreeVisualInfo,a6)
	lea	(ScreenBase,pc),a0
	move.l	(a0),d0
	beq.s	noscreen2close
	clr.l	(a0)
	move.l	d0,a0
	move.l	(IntBase-DT,a4),a6
	jmp	(_LVOCloseScreen,a6)

ReopenScreenOnePlane:
	bsr.b	closescreen
	bsr	OpenScreenOnePlane

openwindow:
	IF 	SLIDER
	bsr	Add_Slider
	ENDIF

	lea	(windowtaglist,pc),a1
	or.w	#(WFLG_BORDERLESS|WFLG_BACKDROP),(winflags+6-windowtaglist,a1)
	move.l	(ScreenBase,pc),d0
	bne.b	.nietopwb
	and.w	#~(WFLG_BORDERLESS|WFLG_BACKDROP),(winflags+6-windowtaglist,a1)
.nietopwb:
	sub.l	a0,a0
	moveq	#0,d0
	move.l	(IntBase-DT,a4),a6
	jsr	(_LVOOpenWindowTagList,a6)
	move.l	d0,(MainWindowHandle-DT,a4)
	beq.b	ReopenScreenOnePlane

	move.l	(DATA_TASKPTR-DT,a4),a0
	move.l	d0,(pr_WindowPtr,a0)
	move.l	d0,a0
	move.l	(wd_RPort,a0),(Rastport-DT,a4)

	move.l	(GadToolsBase-DT,a4),a6
	move.l	(MainWindowHandle-DT,a4),a0
	suba.l	a1,a1
	jmp	_LVOGT_RefreshWindow(a6)

DeactivateMsgs:
	movem.l	d0-a6,-(sp)
	move.l	(IntBase-DT,a4),a6
	move.l	(MainWindowHandle-DT,a4),a0
	move.l	#IDCMP_MOUSEBUTTONS|IDCMP_RAWKEY,d0
	jsr	_LVOModifyIDCMP(a6)
	movem.l	(sp)+,d0-a6
	rts

ActivateMsgs:
	movem.l	d0-a6,-(sp)
	move.l	(IntBase-DT,a4),a6
	move.l	(MainWindowHandle-DT,a4),a0
	move.l	#IDCMP_MENUPICK|IDCMP_MOUSEBUTTONS|IDCMP_RAWKEY,d0
	jsr	_LVOModifyIDCMP(a6)
	movem.l	(sp)+,d0-a6
	rts

closewindow:
	jsr	close_debug_win

	IF	useplugins
	jsr	close_plugs_win
	ENDIF

	IF	SLIDER
	bsr	Remove_Slider
	ENDIF

	move.l	(IntBase-DT,a4),a6
	move.l	(MainWindowHandle-DT,a4),a0
	clr.l	(MainWindowHandle-DT,a4)
	clr.l	(KEY_PORT-DT,a4)
	jmp	(_LVOCloseWindow,a6)


InitAllMenus:
	movem.l	d0-d7/a0-a6,-(sp)
	tst.b	(HaveKS3-DT,a4)
	bne.b	.KS3
	lea	(MenuRecent+gnm_Type,pc),a0
	moveq	#10-1,d0
.FixRecent
	move.b	#NM_SUB,(a0)			; NM_IGNORE is not supported
	lea	(gnm_SIZEOF,a0),a0
	dbf	d0,.FixRecent
.KS3
	lea	(command_menus,pc),a0
	bsr	Init_menustructure
	move.l	d0,(Comm_menubase-DT,a4)
	lea	(Editor_menus,pc),a0
	bsr	Init_menustructure
	move.l	d0,(Edit_Menubase-DT,a4)
	lea	(monitor_menus,pc),a0
	bsr	Init_menustructure
	move.l	d0,(Moni_MenuBase-DT,a4)
	tst	(FPU_Type-DT,a4)
	bne.b	.C1194E
	move	#NM_ITEMDISABLED,(debug_menus_reg_change+gnm_Flags).l
.C1194E
	lea	(debug_menus,pc),a0
	bsr	Init_menustructure
	move.l	d0,(Debug_MenuBase-DT,a4)
	movem.l	(sp)+,d0-d7/a0-a6
	rts

FreeAllMenus:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	(Comm_menubase-DT,a4),d0
	bsr	Breakdown_menu
	move.l	(Edit_Menubase-DT,a4),d0
	bsr	Breakdown_menu
	move.l	(Moni_MenuBase-DT,a4),d0
	bsr	Breakdown_menu
	move.l	(Debug_MenuBase-DT,a4),d0
	bsr	Breakdown_menu
	movem.l	(sp)+,d0-d7/a0-a6
	rts


	IF SLIDER

Add_Slider:
	movem.l	d0-a6,-(sp)

	move.l	(GadToolsBase-DT,a4),d0
	beq.b	MainWindowCError
	move.l	d0,a6

	lea	(MainWindowGList,pc),a3
	move.l	a3,a0
	jsr	_LVOCreateContext(a6)
	move.l	d0,(a3)
	beq.b	MainWindowCError

;	move.l	d0,MainWindowGList

	move.l	(MainVisualInfo-DT,a4),(MainWindowNGads+22-MainWindowGList,a3)

	move.l	d0,a0			;gad prev.
	moveq	#SLIDER_KIND,d0		;kind
	lea	(MainWindowNGads-MainWindowGList,a3),a1	;newgad
;	lea	(MainWindowGTags,pc),a2	;taglist
	sub.l	a2,a2
	jsr	_LVOCreateGadgetA(a6)
	move.l	d0,(MainWindowGadgets-MainWindowGList,a3)

;	jsr	test_debug

	move.l	(a3),(MainWindowWG+4-MainWindowGList,a3)

MainWindowCError:
	movem.l	(sp)+,d0-a6

Slider_nogadget:
	rts

Remove_Slider:
	move.l	(MainWindowGadgets,pc),d0
	beq.b	Slider_nogadget
	move.l	d0,a0
	move.l	(GadToolsBase-DT,a4),a6
	jmp	_LVOFreeGadgets(a6)

	ENDIF	; SLIDER

init_edit_font:
	move.l	(DiskfontBase-DT,a4),d0
	beq.b	.dflt_font

	move.l	d0,a6
	lea	(Editor_Font,pc),a0
	jsr	(_LVOOpenDiskFont,a6)

	tst.l	d0
	bne.s	.allesgoed
.dflt_font
	lea	topazfont.MSG(pc),a0		; switch back to
	lea	editfont_name(pc),a1		; topaz 8 if wrong
.lopje:
	move.b	(a0)+,(a1)+
	bne.s	.lopje

	move.l	(GfxBase-DT,a4),a6
	lea	(Editor_Font,pc),a0
	move.w	#8,(4,a0)			; ysize
	clr.w	(6,a0)				; style and flags
	jsr	(_LVOOpenFont,a6)
.allesgoed:
	move.l	d0,(Fontbase_edit-DT,a4)

	move.l	d0,a0
	move.w	20(a0),(EFontSize_y-DT,a4)
	move.w	24(a0),(EFontSize_x-DT,a4)

edit_no_font:
	rts

close_edit_font:
	move.l	(GfxBase-DT,a4),a6
	move.l	(Fontbase_edit-DT,a4),d0
	beq.b	edit_no_font
	move.l	d0,a1
	jmp	(_LVOCloseFont,a6)


OldEditor_Font:				
	dc.l	Oldeditfont_name
OldEditorFontSize:
	dc.w	8
	dc.b	0
	dc.b	0

Editor_Font:
	dc.l	editfont_name
EditorFontSize:
	dc.w	8
	dc.b	0
	dc.b	0

Topaz_Font9:
	dc.l	topazfont.MSG
	dc.w	9
	dc.b	2	;1=line 2=bold 4=italic
	dc.b	1	;1=romfont

Topaz_Fontt:
	dc.l	topazfont.MSG
	dc.w	9
	dc.b	2	;1=line 2=bold 4=italic
	dc.b	1	;1=romfont

topazfont.MSG:
	dc.b	'topaz.font',0
Oldeditfont_name:
	dc.b	'topaz.font',0
	dcb.b	20,0
editfont_name:
	dc.b	'topaz.font',0
	dcb.b	20,0
	even

;********* Set Menu 2 correct Mark keys ***********

SetCorrectMarkKeys:
	move.l	4.w,a6
	lea	(KeymapName,pc),a1
	jsr	_LVOOldOpenLibrary(a6)
	move.l	d0,a6

	jsr	(_LVOAskKeyMapDefault,a6)
	move.l	d0,a0

	move.l	km_LoKeyMap(a0),a0

	lea	(markkeys+10-DT,a4),a2
	moveq	#10*4,d7
.lopje	move.b	2(a0,d7.w),-(a2)
	subq.w	#4,d7
	bgt.b	.lopje

	move.l	a6,a1
	move.l	4.w,a6
	jsr	_LVOCloseLibrary(a6)

	lea	(RemapMarkKeys,pc),a1
	moveq	#(RemapMarkKeysEnd-RemapMarkKeys)/2-1,d7
.lopje2	move.b	(a2)+,(a1)
	addq.l	#2,a1
	dbf	d7,.lopje2
	rts

;************* OPEN & CLOSE LIBS ****************

OpenConDevice:
	move.l	(4).w,a6
	lea	(ConDeviceName,pc),a0
	lea	(ConIOReq-DT,a4),a1
	moveq	#-1,d0		; unit (CONU_LIBRARY)
	moveq	#0,d1		; flags
	jsr	(_LVOOpenDevice,a6)
	tst.l	d0
	bne.b	.Error
	move.l	(MainWindowHandle-DT,a4),a0
	move.l	(wd_UserPort,a0),(KEY_PORT-DT,a4)
.Error	rts

CloseConDevice:
	move.l	(4).w,a6
	lea	(ConIOReq-DT,a4),a1
	jmp	(_LVOCloseDevice,a6)


OpenLibsAndInitUI:
	move.l	(4).w,a6

	lea	(_LVOOldOpenLibrary,a6),a2
	lea	(DosName,pc),a1
	jsr	(a2)
	move.l	d0,(DosBase-DT,a4)

	lea	(GfxName,pc),a1
	jsr	(a2)
	move.l	d0,(GfxBase-DT,a4)

	lea	(IntuitionName,pc),a1
	jsr	(a2)
	move.l	d0,(IntBase-DT,a4)

	lea	(GadtoolsName,pc),a1
	jsr	(a2)
	move.l	d0,(GadToolsBase-DT,a4)
	move.l	d0,a0
	cmp.w	#39,(LIB_VERSION,a0)
	shs	(HaveKS3-DT,a4)

	lea	(AslName2,pc),a1
	jsr	(a2)
	move.l	d0,(AslBase-DT,a4)

	lea	(DiskFontName,pc),a1
	jsr	(a2)
	move.l	d0,(DiskfontBase-DT,a4)

	jsr	(Read_Prefs)
	bsr	setup_int_stuff

	lea	(TextPrintBuffer-DT,a4),a1
	move.l	a1,(text_buf_ptr-DT,a4)
	lea	(DATA_REPLYPORT-DT,a4),a1
	move.l	(DATA_TASKPTR-DT,a4),(MP_SIGTASK,a1)
	lea	(AsmPro.MSG-DT,a4),a0
	move.l	a0,(LN_NAME,a1)
	move.b	#NT_MSGPORT,(LN_TYPE,a1)
	move.l	(4).w,a6
	jmp	(_LVOAddPort,a6)


CloseUIAndLibs:
	move.l	(DosBase-DT,a4),a6
	move.l	(PrinterBase-DT,a4),d1
	beq.b	.NoPrinter
	jsr	(_LVOClose,a6)
.NoPrinter
	lea	(DIR_ARRAY+DSIZE*10-DT,a4),a0
	move.l	a0,d1
	moveq	#ACCESS_READ,d2
	jsr	(_LVOLock,a6)
	move.l	d0,d1
	beq.b	.NoLock
	jsr	(_LVOCurrentDir,a6)
.NoLock
	bsr	CloseConDevice
	bsr	FreeAllMenus
	bsr	closewindow
	bsr	closescreen
	bsr	close_edit_font

	move.l	(4).w,a6
	lea	(DATA_REPLYPORT-DT,a4),a1
	jsr	(_LVORemPort,a6)

	lea	(_LVOCloseLibrary,a6),a2
	move.l	(DiskfontBase-DT,a4),d0
	beq.b	.NoDiskFont
	move.l	d0,a1
	jsr	(a2)
.NoDiskFont
	move.l	(ReqToolsbase-DT,a4),d0
	beq.b	.NoReqT
	move.l	d0,a1
	jsr	(a2)
.NoReqT
	move.l	(GadToolsBase-DT,a4),d0
	beq.b	.NoGadT
	move.l	d0,a1
	jsr	(a2)
.NoGadT
	move.l	(AslBase-DT,a4),d0
	beq.b	.NoAsl
	move.l	d0,a1
	jsr	(a2)
.NoAsl
	move.l	(IntBase-DT,a4),a1
	jsr	(a2)
	move.l	(GfxBase-DT,a4),a1
	jsr	(a2)
	move.l	(DosBase-DT,a4),a1
	jmp	(a2)


OpenPrinterForOutput:
	movem.l	d1/d2/a0/a1,-(sp)
	move.l	(DosBase-DT,a4),a6
	lea	(PRT.MSG,pc),a0
	move.l	a0,d1
	move.l	#MODE_OLDFILE,d2
	jsr	(_LVOOpen,a6)
	move.l	d0,(PrinterBase-DT,a4)
	bne.b	.noprinter
	bclr	#0,(PR_PrintDump).l
	lea	(PrinterDevice.MSG-DT,a4),a0
	jsr	(beeldtextaf).l
.noprinter:
	movem.l	(sp)+,d1/d2/a0/a1
	rts

ASK_CHECK_ALL_IF_SAVED:
	jsr	(CopyCurrSrcNameToReq)
	jsr	(ASK_CHECK_IF_SAVED)
	movem.l	d0-d7/a0-a6,-(sp)
	lea	(SourcePtrs-DT,a4),a0
	moveq	#10-1,d7
.Loop
	btst	#0,(CS_SomeBits,a0)	;Source Changed?
	beq.b	.NextSrc
	move.l	a0,d0
	lea	(SourcePtrs-DT,a4),a1
	sub.l	a1,d0
	lsr.l	#8,d0			; /CS_Size
	move.b	d0,(ActiveSrcNr-DT,a4)
	jsr	(CopySrcNameToReq)
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(ASK_NOTSAVED)
	movem.l	(sp)+,d0-d7/a0-a6
.NextSrc
	lea	(CS_size,a0),a0
	dbra	d7,.Loop
	movem.l	(sp)+,d0-d7/a0-a6
;C1E34E:
	rts

FreeSources:
	lea	(SourcePtrs-DT,a4),a0
	moveq	#9,d7
C1E356:
	tst.l	(a0)		; CS_start
	beq.b	C1E388
	move.l	(a0),a1		; CS_start
	move.l	(CS_length,a0),d0
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	(4).w,a6
	jsr	(_LVOFreeMem,a6)
	movem.l	(sp)+,d0-d7/a0-a6
	movem.l	d7/a0/a1,-(sp)
	moveq	#CS_size/4-1,d7
C1E37A:
	clr.l	(a0)+
	dbra	d7,C1E37A
	movem.l	(sp)+,d7/a0/a1
C1E388:
	lea	(CS_size,a0),a0
	dbra	d7,C1E356
	rts

Restart:
	move.b	d0,-(sp)
	cmp.b	#'Y',d0			; quick quit?
	beq.b	.Shutdown
	bsr	ASK_CHECK_ALL_IF_SAVED
	cmp.b	#'R',(sp)		; quit (need confirmation) or restart?
	beq.b	.Shutdown
	jsr	(EXTENDEDANSWER)	; yes/no/restart
	move.b	d0,(sp)
.Shutdown
	jsr	(CloseRedirectedOutput)
	jsr	(UnloadCurrObject)
	bsr.b	FreeSources
	jsr	(FreeMem1Kb)		; bootblock (in case of an error)
	moveq	#'0',d0
	move.b	d0,(SourceNr)
	lea	(SourceNrInBalk),a0
	move.b	d0,(a0)
	clr.b	(MenuFileName-SourceNrInBalk,a0)
	clr.b	(CurrentSource-DT,a4)
	clr.b	(LastFileNaam-DT,a4)
	jsr	(RESETMENUTEXT2).l
	move.l	(WORK_START-DT,a4),a1
	move.l	(WORK_END-DT,a4),d0
	sub.l	a1,d0
	move.l	(4).w,a6
	jsr	(_LVOFreeMem,a6)
	jsr	(ZapIncludes).l
	jsr	(ASSEM_FREE_SECTION_MEM).l

	cmp.b	#'R',(sp)+
	bne	CloseUIAndLibs
	move.l	(DATA_USERSTACKPTR-DT,a4),sp
	jmp	(MainRestartLoop)

AllocMainWorkspace:
	tst.b	(ShowLogin-DT,a4)
	bne.s	AllocMainWorkspace2
	tst.w	PR_Startup
	beq.s	nologinwindow

AllocMainWorkspace2:
	movem.l	d0-a6,-(sp)
	bsr	DeactivateMsgs
	jsr	OpenLoginWindow
	bsr	ActivateMsgs
	movem.l	(sp)+,d0-a6

nologinwindow:
	st	(ShowLogin-DT,a4)
	jsr	Show_Cursor

	bset	#SB3_REPORT_ERROR,(SomeBits3-DT,a4)
	lea	(AllocMainWorkspace2,pc),a0
	move.l	a0,(Error_Jumpback-DT,a4)

	move.l	(_memtype-DT,a4),d0
	subq.b	#1,d0
	bmi.b	Absolute_mem_stuff

	moveq	#1,d1
	lsl.l	d0,d1
	or.l	#MEMF_LARGEST,d1

C1E492:
	move.l	(_memamount-DT,a4),d0
	asl.l	#8,d0
	asl.l	#2,d0
	move.l	d0,(WORK_END-DT,a4)
	move.l	(4).w,a6
	jsr	(_LVOAllocMem,a6)
	tst.l	d0
	beq.b	AllocMainWorkspace2
	move.l	d0,-(sp)
	move.l	#MEMF_LARGEST|MEMF_CHIP,d1
	jsr	(_LVOAvailMem,a6)
	cmp.l	#6*1024,d0
	ble.b	.C1E508
	tst.l	(ReqToolsbase-DT,a4)
	beq.b	.C1E508
	or.w	#$005B,(PR_ReqLib).l
	move.l	(sp)+,d0
	bra.b	C1E574

.C1E508	and	#$FEEF,(PR_ReqLib).l
	lea	(Reqtoolslibra.MSG).l,a0
	tst.l	(ReqToolsbase-DT,a4)
	bne.b	.C1E522
	lea	(NoReqToolslibrary.MSG-Reqtoolslibra.MSG,a0),a0
.C1E522	moveq	#0,d7
	jsr	(beeldtextaf).l
	move.l	(sp)+,d0
	bra.b	C1E574

Absolute_mem_stuff:
	move.l	(_absmemadr-DT,a4),a1
	move.l	(_memamount-DT,a4),d0
	asl.l	#8,d0
	asl.l	#2,d0
	move.l	d0,(WORK_END-DT,a4)
;	move.l	(sp)+,a1
	move.l	(4).w,a6
	jsr	(_LVOAllocAbs,a6)
	tst.l	d0
	beq	AllocMainWorkspace2
C1E574:
	move.l	d0,(WORK_START-DT,a4)
	add.l	d0,(WORK_END-DT,a4)
	move.l	(WORK_END-DT,a4),a0
	lea	(-100,a0),a0
	move.l	a0,(WORK_ENDTOP-DT,a4)
	move.l	d0,a0
	move.l	a0,(CodeStart-DT,a4)
	move.l	a0,(RelocStart-DT,a4)
	move.l	a0,(RelocEnd-DT,a4)
	move.l	a0,(LabelStart-DT,a4)
	move.l	a0,(LPtrsEnd-DT,a4)
	move.l	a0,(LabelEnd-DT,a4)

	jsr	(ASK_CHECK_IF_SAVED)
	jsr	(KILL_SOURCE)
	bsr.b	TASKRESCUE
	jmp	(PRIVILIGE_VIOL1)

com_add_workspace:
	lea	(ADD.MSG,pc),a0
	jsr	(printthetext).l
	moveq	#$3F,d0
	jsr	(SENDONECHARNORMAL).l
	jsr	(Druk_MsgAf_GetNumbr).l
	bne.b	.C1E5F4
	asl.l	#8,d0
	asl.l	#2,d0
	beq.b	.C1E5F4
	move.l	(WORK_END-DT,a4),a1
	move.l	(4).w,a6
	move.l	d0,d2
	jsr	(_LVOAllocAbs,a6)
	tst.l	d0
	beq.b	.C1E5F4
	add.l	d2,(WORK_END-DT,a4)
	add.l	d2,(WORK_ENDTOP-DT,a4)
.C1E5F4	jmp	(com_workspace)

TASKRESCUE:
	move.l	(DATA_TASKPTR-DT,a4),a0
	move.l	#EXCEPTIONHANDLER,(TC_TRAPCODE,a0)
	rts

IetsMetScreenHight:
	move.l	(ScreenBase,pc),a0
	movem.w	(sc_Width,a0),d2/d3	; width, height
	lsr.w	#3,d2
	mulu.w	(Scr_NrPlanes-DT,a4),d2
	moveq	#1,d4
	add.b	(sc_BarHeight,a0),d4

	lea	(Scrhoog_4+2,pc),a0
	move.w	d3,(Scrhoog_1-Scrhoog_4,a0)
	move.w	d3,(Scrhoog_2-Scrhoog_4,a0)
	move.w	d3,(a0)

	divu.w	(EFontSize_y-DT,a4),d3
	subq.w	#1,d3			; height/font_height-1

	move.w	d3,(ScreenHight-DT,a4)
	move.w	d3,d0
	lea	(End_msg+1),a0
	moveq	#100,d1
.Loop	ext.l	d0
	divu.w	d1,d0
	add.b	#'0',d0
	move.b	d0,(a0)+
	swap	d0
	divu.w	#10,d1
	bne.b	.Loop

	subq.w	#1,d3			; height/font_height-2

	move.w	d3,(aantal_regels_min2-DT,a4)
	move.w	d3,d0
	add.w	d0,d0
	move.w	d0,(Max_Hoogte-DT,a4)

	subq.w	#1,d3			; height/font_height-3

	move.w	d3,(aantal_regels_min3-DT,a4)
	move.w	d3,(NumLines_Editor-DT,a4)
	move.w	d3,d0
	lsl.w	#1,d0
	move.w	d0,(aantal_regels_min3_div2-DT,a4) ; misleading (div2)
	lsr.w	#2,d0
	move.w	d0,(NumLines_HalfEditor-DT,a4)

	subq.w	#1,d3			; height/font_height-4

	mulu.w	d2,d4
	move.l	d4,(EditScrollSizeTitleUp-DT,a4)
	mulu.w	(EFontSize_y-DT,a4),d2
	move.w	d2,(EditScrollRegelSize-DT,a4)
	mulu.w	d2,d3
	move.l	d3,(EditScrollSize-DT,a4)
	add.l	d3,d4
	move.l	d4,(EditScrollSizeTitleDown-DT,a4)
	rts

ADD.MSG:
	dc.b	'ADD WORKSPACE (Max.',0
	dc.b	') KB>',0
PRT.MSG:
	dc.b	'PRT:',0
GfxName:
	dc.b	'graphics.library',0
IntuitionName:
	dc.b	'intuition.library',0
DosName:
	dc.b	'dos.library',0
GadtoolsName:
	dc.b	'gadtools.library',0
AslName2:
	dc.b	'asl.library',0
KeymapName:
	dc.b	'keymap.library',0
DiskFontName:
	dc.b	"diskfont.library",0
ConDeviceName:
	dc.b	'console.device',0
	EVEN

NewScreenTagList:
	dc.l	SA_Left,0
	dc.l	SA_Top,0
	dc.l	SA_Width
BreedteScherm:
	dc.l	640
	dc.l	SA_Height
HoogteScherm:
	dc.l	256
	dc.l	SA_Depth
DiepteScherm:
	dc.l	2
	dc.l	SA_Font,Editor_Font
	dc.l	SA_Type,CUSTOMSCREEN
	dc.l	SA_Interleaved,TRUE
	dc.l	SA_DisplayID
SchermMode:
	dc.l	-1	;$00008000 ;hires screen
	dc.l	SA_Title,AsmPro_titletxt.MSG
	dc.l	SA_Pens,DfltPens
	dc.l	SA_AutoScroll,TRUE
	dc.l	SA_Overscan,OSCAN_STANDARD
EmptyScreenTagList:
	dc.l	TAG_DONE

JumpToLineTags:
L1E83A:
	dc.l	RT_Underscore,'_'
	dc.l	RT_ReqPos,REQPOS_CENTERSCR
	dc.l	TAG_DONE

L1E84E:
	dc.l	RT_Underscore,'_'
	dc.l	RTGS_TextFmt,Searchfromcur.MSG
	dc.l	RTGS_GadFmt,_Search_Cased.MSG
	dc.l	RT_ReqPos,REQPOS_CENTERSCR
	dc.l	TAG_DONE
SearchReqTags:
	dc.l	RT_Underscore,'_'
	dc.l	RTGS_TextFmt,Searchfor.MSG0
	dc.l	RTGS_GadFmt,_Replace_Abor.MSG
	dc.l	RT_ReqPos,REQPOS_CENTERSCR
	dc.l	TAG_DONE

DfltPens:
	DC.W	~0

Searchfromcur.MSG:
	dc.b	'Search from cursor position for what',0
_Search_Cased.MSG:
	dc.b	'_Search|_Case dependant search|_Abort',0
Searchandrepl.MSG:
	dc.b	'Search and replace',0
Search.MSG:
	dc.b	'Search',0
Searchfor.MSG0:
	dc.b	'Search for '''
Searchfor_text.MSG:
	dcb.b	128,0
andreplaceitw.MSG:
	dc.b	''' and replace it with ',0
_Replace_Abor.MSG:
	dc.b	'_Replace|_Abort',0
Founditshould.MSG:
	dc.b	'Found it, should it be replaced?',0
_Yes_No_Last_.MSG:
	dc.b	'_Yes|_No|_Last|_Global|_Abort',0
Jumptowhichli.MSG:
	dc.b	'Jump to which line number',0
	dc.b	'_Jump|_Abort',0
Selectcolours.MSG:
	dc.b	'Select colours',0
amigaguidelib.MSG:
	dc.b	'amigaguide.library',0
AsmProGuide.MSG:
	DC.B	'AsmPro:AsmPro.guide',0

AsmProV128cus.MSG:
	dc.b	'Asm-Pro '
	VERSION_STR
	dc.b	' Asm-Pro help guide.',0
Unabletoopena.MSG:
	dc.b	'Unable to open amigaguide.library',0
Unabletoopent.MSG:
	dc.b	'Unable to open AsmPro.guide',0

	EVEN		; must be even (move.l copy)
UserSrcExt.MSG:
	DC.B	'(.s|.asm|.i)'
	DCB.B	16-(*-UserSrcExt.MSG),0

windowtaglist:
		DC.L	WA_Left,0
		DC.L	WA_Top,0
		DC.L	WA_Width
ScrBr_1:	dc.l	640
		DC.L	WA_Height
Scrhoog_1:	dc.l	200
		dc.l	WA_IDCMP,IDCMP_MENUPICK|IDCMP_MOUSEBUTTONS|IDCMP_RAWKEY
winflags:	dc.l	WA_Flags,WFLG_ACTIVATE|WFLG_BORDERLESS|WFLG_BACKDROP
		dc.l	WA_Title,AsmPro_titletxt.MSG
;		dc.l	WA_CustomScreen,TRUE
		dc.l	WA_PubScreen
ScreenBase:	dc.l	0
		dc.l	WA_MinWidth,640
		dc.l	WA_MinHeight
Scrhoog_2:	dc.l	200
;		dc.l	WA_Type,$f	;CUSTOMSCREEN

		dc.l	WA_NewLookMenus,1
MainWindowWG:
		dc.l	WA_Gadgets,0	;MainWindowGList
		dc.l	TAG_DONE

;windowtaglist_SL:
;;	dc.l	WA_NewLookMenus,1
;	dc.l	WA_Gadgets,0
;	dc.l	TAG_DONE

	IF SLIDER

MainWindowGTags:
	DC.L	PGA_Freedom,LORIENT_VERT
	DC.L	GA_RelVerify,1
	DC.L	$80080027,12345
	DC.L	$80080029,6
	DC.L	$8008002A,SliderFormat
	DC.L	$8008002B,4
	DC.L	$80030015,1
	DC.L	TAG_DONE

GD_Slider		EQU	0
;MainWindow_CNT		EQU	1

MainWindowGList:	DC.L	0
MainWindowGadgets:	DC.L	0

MainWindowNGads:
	DC.W	316,20,21,229
	DC.L	labelText	;08 gadtext
	dc.l	Editor_Font	;12 font
	DC.W	GD_Slider	;14 GadID
	DC.L	PLACETEXT_LEFT	;18 Flags
	dc.l	0		;22 VisualInfo
	dc.l	0		;26 USER

labelText:
	DC.B	'tekst',0
SliderFormat:
	DC.B	'%ld',0
	CNOP	 0,2

	ENDIF	; SLIDER

;aga window
NewAmiGuide:	dc.l	0			; lock
		dc.l	AsmProGuide.MSG		; name
ScreenBase2:	dcb.l	4,0			; screen, pubscreen, host, client
		dc.l	AsmProV128cus.MSG	; app base name
		dc.l	3			; flags (load all, cache node)
		dcb.l	5,0			; ctx, node, line, tag ext, client


Gave_prefs_table:
	dc.w	PR_ReqLib-*,"RL"		; 6
	dc.w	PR_SaveMarks-*,"SM"		; 6
	dc.w	PR_SourceExt-*,".S"		; 6
	dc.w	PR_UpdateAlways-*,"AU"		;12
	dc.w	PR_PrintDump-*,"PD"		; 4
	dc.w	PR_WBFront-*,"WF"		; 4
	dc.w	PR_RegsRes-*,"RR"		; 8
	dc.w	PR_Safety-*,"SO"		; 6
	dc.w	PR_CloseWB-*,"CW"		;60
	dc.w	PR_params-*,"PS"		; 4
	dc.w	PR_OnlyAscii-*,"OA"		; 4
	dc.w	PR_NoDisasm-*,"DA"		; 6
	dc.w	PR_ShowSource-*,"SS"		;80
	dc.w	PR_Enable_Permit-*,"EP"		;40
	dc.w	PR_LibCalDec-*,"LD"		; 4
	dc.w	PR_RealtimeDebug-*,"RD"		;60
	dc.w	PR_CtrlUp_Down-*,"UD"		; 6
	dc.w	PR_Keepxy-*,"KX"		; 8
	dc.w	PR_AutoIndent-*,"AI"		; 8
	dc.w	PR_ExtReq-*,"XR"		;20
	dc.w	PR_Startup-*,"SW"		;20
	dc.w	PR_SyntaxColor-*,"SC"		;20
	dc.w	PR_CustomScroll-*,"CS"		;??
	dc.w	PR_WaitTOF-*,"WT"		;??
	IF SLIDER
	dc.w	PR_Slider-*,"SL"		;??
	ENDIF
	dc.w	PR_LineNrs-*,"LN"		;??
	dc.w	PR_AutoBackup-*,"AB"		;??
	dc.w	PR_AutoUpdate-*,"AS"

	dc.w	PR_Rescue-*,"RS"		; 0
	dc.w	PR_Level7-*,"L7"		; 4
	dc.w	PR_NumLock-*,"NL"		; 8
	dc.w	PR_AutoAlloc-*,"AA"		;12 
	dc.w	PR_Debug-*,"DB"			; 4
	DC.W	PR_Multiscroll-*,"S8"
	dc.w	PR_ListFile-*,"LF"		; 8
	dc.w	PR_Paging-*,"PG"		;32
	dc.w	PR_HaltPage-*,"HP"		; 6
	dc.w	PR_AllErrors-*,"AE"		;40
	dc.w	PR_Progress-*,"PI"		; 6
	dc.w	PR_ProgressLine-*,"PL"		;00
	dc.w	PR_DsClear-*,"DC"		;32
	dc.w	PR_Label-*,"L:"			;72
	dc.w	PR_Upper_LowerCase-*,"UL"	; 8
	dc.w	PR_Comment-*,";C"		;92
	dc.w	PR_Warning-*,"FW"		;20
	dc.w	PR_FPU_Present-*,"FP"		; 4
	dc.w	PR_OddData-*,"OD"		; 8
	dc.w	PR_MMU-*,"MP"			;52

	dc.w	0

checkopenreqtoolslib:
	btst	#0,(PR_ReqLib).l
	beq.b	C1EC7A
openreqtoolslib:
	move.l	(4).w,a6
	lea	(ReqToolsName-DT,a4),a1
	moveq	#38,d0
	jsr	(_LVOOpenLibrary,a6)
	move.l	d0,(ReqToolsbase-DT,a4)
	bne.b	C1EC7A
	and	#$FEEF,(PR_ReqLib).l
	tst.l	(MainWindowHandle-DT,a4)
	beq.b	C1EC7A
	lea	(NoReqToolslibrary.MSG).l,a0
	jmp	(printthetext).l
C1EC7A:
	rts

;*********** Font requesters *************

fontreq_edit:
	movem.l	d0-a6,-(sp)

;	move.l	#RTFO_FilterFunc,fonttags
;	move.l	#0,fonttags

	bsr.b	fontrequester
	bne.s	.error_in_req		; choose cancel

	bsr	close_edit_font
	bsr	init_edit_font

	move	#2,(PrefsGedoe-DT,a4)	;refresh display...
.error_in_req:
	movem.l	(sp)+,d0-a6
	rts

fontrequester:
	move.l	(AslBase-DT,a4),d0
	beq.b	.noasl
	move.l	d0,a6

;	lea	(editfont_name,pc),a0
;	move.w	EditorFontSize,d0
;	jsr	test_debug

	lea	fonttags(pc),a0
	move.l	(ScreenBase,pc),0+4(a0)
	move.w	(EditorFontSize,pc),8+6(a0)
;	move.l	(editfont_name,pc),16+4(a0)

	moveq	#0,d1
	move.w	(Scr_hoogte-DT,a4),d1
	divu.w	#22,d1
	move.w	d1,24+6(a0)

	moveq	#ASL_FontRequest,d0
	jsr	_LVOAllocAslRequest(a6)
	move.l	d0,(fontreq-DT,a4)
	beq.b	.noasl

	lea	(editfont_name,pc),a0
	lea	(Oldeditfont_name,pc),a1
.FontBack:
	move.b	(a0)+,(a1)+
	bne.s	.FontBack
	lea	(EditorFontSize,pc),a0
	move.l	(a0),(OldEditorFontSize-EditorFontSize,a0) ; w/b/b

	move.l	d0,a0
	sub.l	a1,a1
	jsr	_LVOAslRequest(a6)

	move.l	(fontreq-DT,a4),a0
	tst.l	d0
	sne	(FontChanged-DT,a4)
	beq.s	.nietgoed

	move.l	fo_Attr+ta_Name(a0),a5
	move.l	(fo_Attr+ta_YSize,a0),(EditorFontSize) ; ysize, style, flags (w/b/b)

	lea	(editfont_name,pc),a1
.lopje	move.b	(a5)+,(a1)+
	bne.s	.lopje

	jsr	_LVOFreeAslRequest(a6)
	moveq	#0,d0
	rts

.nietgoed:
	jsr	_LVOFreeAslRequest(a6)
.noasl	moveq	#1,d0	;error
	rts

fonttags:
	dc.l	ASLFO_Screen,0		;0
	dc.l	ASLFO_InitialSize,8	;8
	dc.l	ASLFO_InitialName,editfont_name	;16
	dc.l	ASLFO_MaxHeight,0	;24
	dc.l	ASL_FuncFlags,FONF_FIXEDWIDTH
	dc.l	TAG_DONE

	REM
fontrequester:
	move.l	(ReqToolsbase-DT,a4),d0
	beq.s	.fontreq_foutje
	move.l	d0,a6

	moveq	#RT_FONTREQ,d0
	sub.l	a0,a0
	jsr	_LVOrtAllocRequestA(a6)
	move.l	d0,(fontreq-DT,a4)
	beq.s	.fontreq_foutje

	move.l	d0,a1

	moveq	#FREQF_FIXEDWIDTH,d0
	move.l	d0,(rtfo_Flags,a1)
	lea	.Fonttext(pc),a3
	lea	(fonttags,pc),a0
	jsr	_LVOrtFontRequestA(a6)

	move.l	(fontreq-DT,a4),a1
	tst.l	d0
	beq.b	.nietgoed

	move.l	rtfo_Attr+ta_Name(a1),a5
	move.w	rtfo_Attr+ta_YSize(a1),(EditorFontSize)

	lea	(editfont_name,pc),a0
.lopje	move.b	(a5)+,(a0)+
	bne.s	.lopje

;	move.w	d7,EditorFontSize

	jsr	_LVOrtFreeRequest(a6)

	moveq	#0,d0
	rts

.nietgoed:
	jsr	_LVOrtFreeRequest(a6)
.fontreq_foutje:
	moveq	#1,d0
	rts

.Fonttext
	dc.b	"Select a font!",0
	even

fonttags:
	dc.l	RTFO_FilterFunc,fonthook
	dc.l	TAG_DONE

filterfunc:
	;A0 - (struct Hook *) your hook
	;A2 - (struct rtFontRequester *) your filereq
	;A1 - (struct TextAttr *) textattr of font

	move.l	d1,-(sp)
	moveq	#TRUE,d0
	moveq	#0,d1
	move.w	(Scr_breedte-DT,a4),d1
	divu.w	4(a1),d1
;	cmp.w	#76,d1
	cmp.w	#45,d1
	bhs.s	.true
	moveq	#FALSE,d0
.true:
	move.l	(sp)+,d1
	tst.w	d0
	rts

;struct TextAttr {
;	STRPTR  ta_Name;            /* name of the font */
;	UWORD   ta_YSize;           /* height of the font */
;	UBYTE   ta_Style;           /* intrinsic font style */
;	UBYTE   ta_Flags;           /* font preferences and flags */
;};

fonthook:		;struct hook
	dc.l	0	;prev	struct minnode
	dc.l	0	;next

	dc.l	filterfunc	;h_entry
	dc.l	0		;h_sybentry
	dc.l	0		;h_data

	EREM

;**********************

Readsource.MSG:		dc.b	'Read source',0
Writesource.MSG:	dc.b	'Write source',0
Readbinary.MSG:		dc.b	'Read binary',0
Writebinary.MSG:	dc.b	'Write binary',0
Readobject.MSG:		dc.b	'Read object',0
Writeobject.MSG:	dc.b	'Write object',0
Writelink.MSG:		dc.b	'Write link',0
Writeblock.MSG:		dc.b	'Write block',0
Directoutput.MSG:	dc.b	'Direct output',0
Zapfile.MSG:		dc.b	'Zap file',0
Insertsource.MSG:	dc.b	'Insert source',0
;Selectprefere.MSG:	dc.b	'Select preference file to load',0
;Selectprefere.MSG0:	dc.b	'Select preference file to save',0
Selectprefere.MSG:	dc.b	'Read preferences',0
Selectprefere.MSG0:	dc.b	'Write preferences',0
WriteProject.MSG:	dc.b	'Write project',0
ReadProject.MSG:	dc.b	'Read project',0
	EVEN

IO_msgptrs:
	dc.w	1,Readsource.MSG-*	;0
	dc.w	1,Writesource.MSG-*	;1
	dc.w	2,Readbinary.MSG-*	;2
	dc.w	2,Writebinary.MSG-*	;3
	dc.w	2,Readobject.MSG-*	;4
	dc.w	2,Writeobject.MSG-*	;5
	dc.w	2,Writelink.MSG-*	;6
	dc.w	3,Writeblock.MSG-*	;7
	dc.w	2,Directoutput.MSG-*	;8
	dc.w	2,Zapfile.MSG-*		;9
	dc.w	3,Insertsource.MSG-*	;10
	dc.w	4,Selectprefere.MSG-*	;11
	dc.w	5,Selectprefere.MSG0-*	;12
	dc.w	6,WriteProject.MSG-*	;13
	dc.w	6,ReadProject.MSG-*	;14
	dc.w	2,Writesource.MSG-*	;15
	dc.w	2,Readsource.MSG-*	;16

	REM
AslLibIsOpen:
	lsl.w	#2,d0
	pea	(IO_msgptrs,pc,d0.w)

	move.l	(AslBase-DT,a4),d0
	beq.b	.noreq
	move.l	d0,a6

	lea	.filetags(pc),a0
	move.l	(ScreenBase,pc),0+4(a0)

	moveq	#ASL_FileRequest,d0
	jsr	_LVOAllocAslRequest(a6)
	move.l	d0,(FileReqBase-DT,a4)
	beq.s	.noreq

	move.l	(sp),a0
	move.w	(a0),d0
	cmp.w	#6,d0
	beq.w	GetProjExt
	cmp.w	#4,d0
	beq.w	GetPrefsExt
	cmp.w	#5,d0
	beq.w	GetPrefsExt
	btst	#0,(PR_SourceExt).l
	beq.w	GetNoExt
	subq.w	#1,d0
	beq.b	.C1EE2C
	subq.w	#3-1,d0
	bne.b	GetNoExt
.C1EE2C:
	lea	(UserSrcExt.MSG,pc),a1
	lea	(req_file_extentie+2-DT,a4),a2	; skip #?
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+

	move.l	(FileReqBase-DT,a4),a0
	sub.l	a1,a1
	jsr	_LVOAslRequest(a6)
	tst.l	d0
	beq.b	.noreq		;Error showing FReq

;	lea	(ReqSourceExt,pc),a0
;	move.l	(FileReqBase-DT,a4),a1
;	jsr	(-$0030,a6)
	bra.b	GetTheFile

.noreq:	addq.l	#4,sp
	jmp	FileReqStuff


.filetags:
	dc.l	ASLFO_Screen,0
	dc.l	ASLFR_TitleText,0
	dc.l	ASLFR_InitialPattern,0
	dc.l	ASLFR_DoPatterns,TRUE
	dc.l	ASLFR_RejectIcons,TRUE
	dc.l	TAG_DONE
	EREM


*********************************
**   old reqtools filereq...   **
*********************************

YesReqLib:
	move.l	(ReqToolsbase-DT,a4),d1
	bne.b	.IsOpen
	move.l	d0,-(sp)
	bsr	checkopenreqtoolslib
	move.l	(sp)+,d0
	move.l	(ReqToolsbase-DT,a4),d1
	bne.b	.IsOpen
	bclr	#0,(PR_ReqLib).l
	jmp	(FileReqStuff).l

.IsOpen:
	move.l	d1,a6
	lsl.w	#2,d0
	pea	(IO_msgptrs,pc,d0.w)

	moveq	#RT_FILEREQ,d0
	sub.l	a0,a0
	jsr	(_LVOrtAllocRequestA,a6)
	move.l	d0,(FileReqBase-DT,a4)
	beq	C1EFD0

	move.l	(sp),a0

	move.w	(a0),d0
	cmp.w	#6,d0
	beq.b	GetProjExt
	cmp.w	#4,d0
	beq.b	GetPrefsExt
	cmp.w	#5,d0
	beq.b	GetPrefsExt

GetSrcExt:
	btst	#0,(PR_SourceExt).l
	beq.b	GetNoExt
	subq.w	#1,d0
	beq.b	.C1EE2C
	subq.w	#3-1,d0
	bne.b	GetNoExt
.C1EE2C:
	lea	(UserSrcExt.MSG,pc),a1
	lea	(req_file_extentie+2-DT,a4),a2	; skip #?
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+

	lea	(ReqSourceExt,pc),a0
	bra.b	SetFileExt

GetProjExt:
	lea	(ReqProjExt,pc),a0
	bra.b	SetFileExt

GetPrefsExt:
	lea	(ReqPrefsExt,pc),a0
	bra.b	SetFileExt

GetNoExt:
	lea	(ReqNoExt,pc),a0
SetFileExt:
	move.l	(FileReqBase-DT,a4),a1
	jsr	(_LVOrtChangeReqAttrA,a6)

	move.l	(sp),a1
	move.w	(a1),d1
	cmp	#4,d1
	blt.b	.C1EE84
	moveq	#3,d1
.C1EE84
	lea	(PrevDirnames-DT,a4),a1
	subq.w	#1,d1
	bne.s	.noreplace

	lea	(DIR_ARRAY-DT,a4),a0
	moveq	#0,d0
	move.b	(CurrentSource-DT,a4),d0
	lsl.w	#7,d0		;*DSIZE
	add.w	d0,a0

	move.l	a1,a2
.copy	move.b	(a0)+,(a2)+
	bne.s	.copy

.noreplace:
	lsl.w	#7,d1		;*DSIZE
	add.w	d1,a1
	tst.b	(a1)
	beq.b	.C1EEAC
	move.l	(FileReqBase-DT,a4),a2
	move.l	(rtfi_Dir,a2),a2
	moveq	#128-1,d7
.C1EE9E	move.b	(a1)+,(a2)+
	dbeq	d7,.C1EE9E
.C1EEAC
	move.l	(sp),a1
	move.w	(a1)+,d1
	add.w	(a1),a1
	move.l	a1,a3
	lea	(FileNaam-DT,a4),a2

	move.l	a2,a0
	cmp	#4,d1
	bge.b	.C1EEE4
	lea	(MenuFileName).l,a1
	moveq	#30-1,d0
.C1EECC
;	cmp	#4,d1
;	bge.b	.C1EEE4
	cmp	#2,d1
	bne.b	.C1EEDE
	cmp.b	#'.',(a1)
	beq.b	.C1EEE4
.C1EEDE	move.b	(a1)+,(a0)+
	dbra	d0,.C1EECC
.C1EEE4
	clr.b	(a0)

	move.l	(FileReqBase-DT,a4),a1
;	lea	(FileNaam-DT,a4),a2
	lea	(ReqTaglist,pc),a0
	jsr	(_LVOrtFileRequestA,a6)
	tst	d0
	beq	C1EFD0
	move.l	(sp),a1
	move	(a1),d1
	cmp	#3,d1
	ble.b	C1EF14
	moveq	#3,d1
C1EF14:
	subq.w	#1,d1
	lea	(PrevDirnames-DT,a4),a1
	lsl.w	#7,d1		;*DSIZE
	add.w	d1,a1
	move.l	(FileReqBase-DT,a4),a2
	move.l	(rtfi_Dir,a2),a2
	moveq	#128-1,d7
.C1EF2A	move.b	(a2)+,(a1)+
	dbeq	d7,.C1EF2A

	move.l	(sp)+,a0
	cmp.w	#1,(a0)
	beq.b	C1EF6E
	cmp.w	#2,(a0)
	beq.b	C1EF60
	lea	(DIR_ARRAY3-DT,a4),a0
	lea	(FILE_ARRAY3-DT,a4),a2
	bra.b	C1EF7A

C1EF60:
	lea	(DIR_ARRAY2-DT,a4),a0
	lea	(FILE_ARRAY2-DT,a4),a2
	bra.b	C1EF7A

C1EF6E:
	lea	(DIR_ARRAY-DT,a4),a0

	moveq	#0,d7
	move.b	(CurrentSource-DT,a4),d7
	lsl.l	#7,d7		;*DSIZE
	add.l	d7,a0

	lea	(MenuFileName),a2
C1EF7A:
	move.l	(FileReqBase-DT,a4),a1
	move.l	(rtfi_Dir,a1),a1
	lea	(CurrentAsmLine-DT,a4),a3
C1EF88:
	tst.b	(a1)
	beq.b	C1EF8E
	move.b	(a1),(a3)+
C1EF8E:
	move.b	(a1)+,(a0)+
	bne.b	C1EF88
	cmp.l	#CurrentAsmLine,a3
	beq.b	C1EFA8
	cmp.b	#':',(-1,a3)
	beq.b	C1EFA8
	move.b	#'/',(a3)+
C1EFA8:
	lea	(FileNaam-DT,a4),a1
	moveq	#31-1,d0
.C1EFAC	move.b	(a1),(a2)+	; UI text, 31 chars max
	move.b	(a1)+,(a3)+	; full filename
	dbeq	d0,.C1EFAC
	beq.b	C1EFBC
	clr.b	-(a2)
.FullCopy
	move.b	(a1)+,(a3)+
	bne.b	.FullCopy
C1EFBC:
	move.l	(FileReqBase-DT,a4),d0
	beq.b	.C1EFCE
	move.l	d0,a1
	jsr	(_LVOrtFreeRequest,a6)
	clr.l	(FileReqBase-DT,a4)
.C1EFCE
	rts

C1EFD0:
	bsr.b	C1EFBC
	addq.l	#4,sp

_ERROR_NotDone:
	jmp	(ERROR_Notdone)

ReqTaglist:
	dc.l	RTFI_Flags,FREQF_PATGAD
	dc.l	RTFI_Height
Scrhoog_4:
	dc.l	0
	dc.l	TAG_DONE

ReqSourceExt:
	dc.l	RTFI_MatchPat,req_file_extentie
	dc.l	TAG_DONE

ReqPrefsExt:
	dc.l	RTFI_MatchPat,PrefExt.MSG
	dc.l	TAG_DONE

ReqProjExt:
	dc.l	RTFI_MatchPat,ProjExt.MSG
	dc.l	TAG_DONE

ReqNoExt:
	dc.l	RTFI_MatchPat,NoExt.MSG
	dc.l	TAG_DONE

PrefExt.MSG:	dc.b	'#?.Pref',0
ProjExt.MSG:	dc.b	'#?.Aprj'
NoExt.MSG:	DC.B	0		; empty string
	EVEN

C1F030:
	lea	(Fileallreadye.MSG,pc),a1
	lea	(_Overwrite_Le.MSG,pc),a2
	moveq	#0,d0
	bra.b	ShowReqtoolsRequester_HaveType

C1F048:
	lea	(Source.MSG,pc),a1
	lea	(_Save_Continu.MSG,pc),a2
	bra.b	ShowReqtoolsRequester_Type2

ShowReqtoolsCheckRequester:
	lea	(Areyousure.MSG,pc),a1
	lea	(_ok_no.MSG,pc),a2
ShowReqtoolsRequester_Type2:
	moveq	#2,d0
ShowReqtoolsRequester_HaveType:
	move.l	d0,(RequesterType)

ShowReqtoolsRequester:
	move.l	(ReqToolsbase-DT,a4),a6

	movem.l	a0-a4,-(sp)
	sub.l	a4,a4			; ** A4 TMP UNAVAIL **
	sub.l	a3,a3
	lea	(L1F188,pc),a0
	tst.b	(PR_Safety).l
	bne.b	.C1F090
	lea	(L1F1A4,pc),a0
.C1F090	jsr	(_LVOrtEZRequestA,a6)
	movem.l	(sp)+,a0-a4

	cmp.l	#AsmPro_abouttxt.MSG,a1
	beq.b	NotInCommandline

	cmp.l	#cs_txt,a1
	beq.b	NotInCommandline

	cmp.l	#wt_txt,a1
	beq.b	NotInCommandline

	IF	Debugstuff
	cmp.l	#regstxt,a1
	beq.b	NotInCommandline
	ENDIF

	cmp.l	#_Save_Continu.MSG,a2
	beq.b	.C1F0BA
	subq.l	#1,d0
	beq.b	NotInCommandline
	bra.w	_ERROR_NotDone

.C1F0BA	subq.l	#1,d0
	beq.b	.C1F0D2
	subq.l	#1,d0
	beq.b	NotInCommandline
	bra.w	_ERROR_NotDone

.C1F0D2	movem.l	d0-d7/a0-a6,-(sp)
	move.b	(ActiveSrcNr-DT,a4),d0
	jsr	(SetActiveSourcebuf_D0).l
	jsr	(C188B2).l
	movem.l	(sp)+,d0-d7/a0-a6

NotInCommandline:
C1F99E:
	moveq	#"Y",d0
	rts
C1F9A2:
	moveq	#'R',d0
	rts

ANSWER_YES_NO_RESTART:
	move.l	(ReqToolsbase-DT,a4),a6

	movem.l	a0-a4,-(sp)
	lea	(AbouttoexitAS.MSG,pc),a1
	lea	(_Yes_Restart_.MSG,pc),a2
	sub.l	a4,a4				; ** A4 TMP UNAVAIL **
	sub.l	a3,a3
	lea	(L1F188,pc),a0
	tst.b	(PR_Safety).l
	bne.b	.C1F166
	lea	(L1F1A4,pc),a0
.C1F166	jsr	(_LVOrtEZRequestA,a6)
	movem.l	(sp)+,a0-a4

	subq.l	#1,d0
	beq.b	C1F99E
	subq.l	#1,d0
	beq.b	C1F9A2
	bra.w	_ERROR_NotDone

L1F188:
	dc.l	$8000000B,$0000005F
	dc.l	$80000014,AsmProV128req.MSG
	dc.l	$80000016,1
	dc.l	TAG_DONE
L1F1A4:
	dc.l	$8000000B,$0000005F
	dc.l	$80000014,AsmProV128req.MSG
	dc.l	$80000017
RequesterType:
	dc.l	2
	dc.l	TAG_DONE

AsmProV128req.MSG:
	dc.b	'Asm-Pro '
	VERSION_STR
	dc.b	' request',0
AbouttoexitAS.MSG:
	dc.b	'About to exit Asm-Pro!',10
Areyousure.MSG:
	dc.b	'    Are you sure?',0
Fileallreadye.MSG:
	dc.b	'File already exists!',10
	dc.b	'    Are you sure?',0
Source.MSG:
	dc.b	'Source '
SourceNr: dc.b	'0 » '
ReqSourceName:
	dcb.b	31,0
	dc.b	10
	dc.b	'not saved yet!',10
	dc.b	'All changes will be lost, are you sure?',0
_Yes_Restart_.MSG:	dc.b	'_Yes|_Restart|_No',0
_Save_Continu.MSG:	dc.b	'_Save|_Continue|_Abort',0
_Overwrite_Le.MSG:	dc.b	'_Overwrite|_Leave',0
_Ok_Ok.MSG:		dc.b	'_Ok|_Ok',0
_ok_no.MSG:		dc.b	'_Yes|_No',0

AsmPro_abouttxt.MSG:
	dc.b	'     Asm-Pro OpenSource Edition '
	VERSION_STR
	dc.b	' ('
	%getdate
	dc.b	')',10,10
	dc.b	' MC680x0/MC6888x/MC68851 Macro Assembler (KS 2.x/3.x)',10,10
	dc.b	'          Coding by Solo/Genetic (1995-2000)',10
	dc.b	'          Original code by Rune Gram-Madsen.',10
	dc.b	'     Check the history file for some more credits!',10,10
	dc.b	'              Asm-Pro is now OpenSource.',10
	dc.b	'     try: "http://surf.to/asmpro" for more info.',10
	dc.b	'For questions send a message to Asmpro_dev@yahoogroups.com',10,10
	dc.b	'   Dutch coders drink Grolsch beer! YOU should TOO!',10,0

Newsourcenona.MSG:
	dc.b	'New source (specify a name)',0
Noprojectstar.MSG:
	dc.b	'No project started',0
Nosource.MSG:
	dc.b	'No source',0
AsmProProject.MSG:
	dc.b	'Asm-Pro Project : '
Source0.MSG:
	dc.b	'                                ',10,10
	dc.b	'Source #0 : '
SizeSource1Si.MSG:
	dc.b	'                               Size      :         ',10
	dc.b	'Source #1 :                                Size      :         ',10
	dc.b	'Source #2 :                                Size      :         ',10
	dc.b	'Source #3 :                                Size      :         ',10
	dc.b	'Source #4 :                                Size      :         ',10
	dc.b	'Source #5 :                                Size      :         ',10
	dc.b	'Source #6 :                                Size      :         ',10
	dc.b	'Source #7 :                                Size      :         ',10
	dc.b	'Source #8 :                                Size      :         ',10
	dc.b	'Source #9 :                                Size      :         ',10,0

	EVEN
Change2Commmenu:
	move.l	d0,-(sp)
	move.l	(Comm_menubase-DT,a4),d0
	move.b	#MT_COMMAND,(menu_tiepe-DT,a4)
	bsr.w	Change_2menu_d0
	move.l	(sp)+,d0
	rts

Change2Editmenu:
	move.l	d0,-(sp)
	move.l	(Edit_Menubase-DT,a4),d0
	move.b	#MT_EDITOR,(menu_tiepe-DT,a4)
	bsr.b	Change_2menu_d0
	move.l	(sp)+,d0
	rts

Change2Debugmenu:
	move.l	d0,-(sp)
	move.l	(Debug_MenuBase-DT,a4),d0
	move.b	#MT_DEBUGGER,(menu_tiepe-DT,a4)
	bsr.b	Change_2menu_d0
	move.l	(sp)+,d0
	jmp	(SetProgramParams)

Change2Monitormenu:
	move.l	d0,-(sp)
	move.l	(Moni_MenuBase-DT,a4),d0
	move.b	#MT_MONITOR,(menu_tiepe-DT,a4)
	bsr.b	Change_2menu_d0
	move.l	(sp)+,d0
	rts

Init_menustructure:
	movem.l	d1-a6,-(sp)
	sub.l	a1,a1				; no tags
	move.l	(GadToolsBase-DT,a4),a6
	jsr	(_LVOCreateMenusA,a6)
	move.l	d0,-(sp)
	beq.b	.nomenu
	move.l	d0,a0
	move.l	(MainVisualInfo-DT,a4),a1
	lea	(firstmenu_taglist-DT,a4),a2

	cmp.w	#1,(Scr_NrPlanes-DT,a4)
	bne.b	.NotMono
	sub.l	a2,a2
.NotMono
	jsr	(_LVOLayoutMenusA,a6)
.nomenu:
	movem.l	(sp)+,d0-a6			; also pops ret value in d0
	rts

Breakdown_menu:
	move.l	d0,-(sp)
	move.l	(MainWindowHandle-DT,a4),a0
	move.l	(IntBase-DT,a4),a6
	jsr	(_LVOClearMenuStrip,a6)
	clr.l	(MenuStrip-DT,a4)
	move.l	(sp)+,a0
	move.l	(GadToolsBase-DT,a4),a6
	jmp	(_LVOFreeMenus,a6)

Change_2menu_d0:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	d0,-(sp)
	move.l	(MainWindowHandle-DT,a4),a0
	move.l	(IntBase-DT,a4),a6
	jsr	(_LVOClearMenuStrip,a6)
	move.l	(MainWindowHandle-DT,a4),a0
	move.l	(sp)+,a1
	move.l	a1,(MenuStrip-DT,a4)
	jsr	(_LVOSetMenuStrip,a6)
	tst.l	(KEY_PORT-DT,a4)
	beq.b	.NoPort
	st	(MenuStripChanged-DT,a4)
	jsr	(messages_get)			; discard old menu msgs
	sf	(MenuStripChanged-DT,a4)
.NoPort
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;********** COMMAND MENU **************

MKMENU	MACRO
	DC.B	\1,0		; type, pad
	DC.L	\2		; label
	IFNB	\3
	DC.L	\3		; comm key
	ELSE
	DC.L	0
	ENDIF
	IFNB	\5
	DC.W	\5		; flags
	ELSE
	DC.W	0
	ENDIF
	DC.L	0		; mutual exclude
	IFNB	\4
	DC.W	\4,-1		; user data
	ELSE
	DC.L	0
	ENDIF
	ENDM

MKMENUEND	MACRO
	DC.B	NM_END		; type = 0
	EVEN
	ENDM

command_menus:
	MKMENU	NM_TITLE,Project.MSG
		MKMENU	NM_ITEM,ProjectinfoP.MSG,,'=P'
		MKMENU	NM_ITEM,ZapSourceZS.MSG,,'ZS'
		MKMENU	NM_ITEM,OldO.MSG,,'O'<<8
		MKMENU	NM_ITEM,Read.MSG
			MKMENU	NM_SUB,EnviornmentRE.MSG,,'RE'
			MKMENU	NM_SUB,SourceR.MSG,,'R'<<8
			MKMENU	NM_SUB,SourceRN.MSG,,'RN'
			MKMENU	NM_SUB,BinaryRB.MSG,,'RB'
			MKMENU	NM_SUB,ObjectRO.MSG,,'RO'
		MKMENU	NM_ITEM,Write.MSG
			MKMENU	NM_SUB,EnviornmentWE.MSG,,'WE'
			MKMENU	NM_SUB,SourceW.MSG,,'W'<<8
			MKMENU	NM_SUB,SourceWN.MSG,,'WN'
			MKMENU	NM_SUB,BinaryWB.MSG,,'WB'
			MKMENU	NM_SUB,ObjectWO.MSG,,'WO'
			MKMENU	NM_SUB,LinkWL.MSG,,'WL'
			MKMENU	NM_SUB,PreferencesWP.MSG,,'WP'
		MKMENU	NM_ITEM,InsertI.MSG,,'I'<<8
		MKMENU	NM_ITEM,Update.MSG
			MKMENU	NM_SUB,UpdateSourceU.MSG,,'U'<<8
			MKMENU	NM_SUB,UpdateProject.MSG,,'UA'
		MKMENU	NM_ITEM,ZapFileZF.MSG,,'ZF'
		MKMENU	NM_ITEM,ZapIncMemZI.MSG,,'ZI'
		MKMENU	NM_ITEM,NM_BARLABEL
		MKMENU	NM_ITEM,RecentFiles.MSG
MenuRecent:
.Ctr	SET	0
	REPT	10
			MKMENU	NM_IGNORE,RecentCache+.Ctr*146,,'R0'+.Ctr ; v39+ (KS3)!
.Ctr	SET	.Ctr+1
	ENDR
		MKMENU	NM_ITEM,NM_BARLABEL
		MKMENU	NM_ITEM,AddWorkMemM.MSG,,'=M'
		MKMENU	NM_ITEM,NM_BARLABEL
		MKMENU	NM_ITEM,About.MSG,,'#'<<8
		MKMENU	NM_ITEM,NM_BARLABEL
		MKMENU	NM_ITEM,Quit.MSG,,'!'<<8
		MKMENU	NM_ITEM,Restarting.MSG,,'!R'
		MKMENU	NM_ITEM,QuickQuit.MSG,,'!!'

	MKMENU	NM_TITLE,Assembler.MSG
		MKMENU	NM_ITEM,Assemble.MSG
			MKMENU	NM_SUB,Assemble.MSG,A.MSG,45
			MKMENU	NM_SUB,Optimize.MSG,O.MSG,59
			MKMENU	NM_SUB,Checkonly.MSG,,'AC'
			MKMENU	NM_SUB,Objectinfo.MSG,,'='<<8
		MKMENU	NM_ITEM,NM_BARLABEL
		MKMENU	NM_ITEM,Editor.MSG,E.MSG,49
		MKMENU	NM_ITEM,Debugger.MSG,D.MSG,48
		MKMENU	NM_ITEM,Monitor.MSG,M.MSG,57
	IF	useplugins
		MKMENU	NM_ITEM,PluginWin.MSG,,'PW'
	ENDIF
		MKMENU	NM_ITEM,Preferences.MSG
			MKMENU	NM_SUB,Environment.MSG,BracketOpen.MSG,9
			MKMENU	NM_SUB,Assembler_.MSG,BracketClose.MSG,12
			MKMENU	NM_SUB,Syntaxpr.MSG,Z.MSG,70
			MKMENU	NM_SUB,colors_.MSG,,'=C'
		MKMENU	NM_ITEM,NM_BARLABEL
		MKMENU	NM_ITEM,Agaguide.MSG,,101

	MKMENU	NM_TITLE,Commands.MSG
		MKMENU	NM_ITEM,Editor.MSG
			MKMENU	NM_SUB,JumpTopT.MSG,,'T'<<8
			MKMENU	NM_SUB,JumpBottomB.MSG,,'B'<<8
			MKMENU	NM_SUB,SearchL.MSG,,'L'<<8
			MKMENU	NM_SUB,ZapLinesZL.MSG,,'ZL'
			MKMENU	NM_SUB,PrintLinesP.MSG,,'P'<<8
			MKMENU	NM_SUB,ExtendLabelsE.MSG,,'EL'
		MKMENU	NM_ITEM,Memory.MSG
			MKMENU	NM_SUB,EditM.MSG,,'M'<<8
			MKMENU	NM_SUB,DisassembleD.MSG,,'D'<<8
			MKMENU	NM_SUB,HexDumpH.MSG,,'H'<<8
			MKMENU	NM_SUB,ASCIIN.MSG,,'N'<<8
			MKMENU	NM_SUB,BINDUMP.MSG,,'BM'
			MKMENU	NM_SUB,NM_BARLABEL
			MKMENU	NM_SUB,DisLineD.MSG,,'@D'
			MKMENU	NM_SUB,AssembleAtA.MSG,,'@A'
			MKMENU	NM_SUB,HexLineH.MSG,,'@H'
			MKMENU	NM_SUB,ASCIILineN.MSG,,'@N'
			MKMENU	NM_SUB,BinLineB.MSG,,'@B'
			MKMENU	NM_SUB,NM_BARLABEL
			MKMENU	NM_SUB,SearchMemoryS.MSG,,'S'<<8
			MKMENU	NM_SUB,FillMemoryF.MSG,,'F'<<8
			MKMENU	NM_SUB,CopyMemoryC.MSG,,'C'<<8
			MKMENU	NM_SUB,CompareMemory.MSG,,'Q'<<8
			MKMENU	NM_SUB,CreateSinusCS.MSG,,'CS'
		MKMENU	NM_ITEM,Insert.MSG
			MKMENU	NM_SUB,DisAssemblyID.MSG,,'ID'
			MKMENU	NM_SUB,HEXDumpIH.MSG,,'IH'
			MKMENU	NM_SUB,ASCIIDumpIN.MSG,,'IN'
			MKMENU	NM_SUB,BinaryDumpIB.MSG,,'IB'
			MKMENU	NM_SUB,CreateSinusIS.MSG,,'IS'
		MKMENU	NM_ITEM,Assemble.MSG
			MKMENU	NM_SUB,AssembleA.MSG,,'A'<<8
			MKMENU	NM_SUB,MemoryA.MSG,,'@A'
			MKMENU	NM_SUB,OptimizeAO.MSG,,'A0'
			MKMENU	NM_SUB,DebugAD.MSG,,'AD'
			MKMENU	NM_SUB,SymbolsS.MSG,,'=S'
			MKMENU	NM_SUB,ParametersSet.MSG,,'PS'
		MKMENU	NM_ITEM,Monitor.MSG
			MKMENU	NM_SUB,JumpJ.MSG,,'J'<<8
			MKMENU	NM_SUB,GoG.MSG,,'G'<<8
			MKMENU	NM_SUB,StepK.MSG,,'K'<<8
			MKMENU	NM_SUB,StatusX.MSG,,'X'<<8
			MKMENU	NM_SUB,ZapBPSZB.MSG,,'ZB'
		MKMENU	NM_ITEM,Disk.MSG
			MKMENU	NM_SUB,ReadSectorRS.MSG,,'RS'
			MKMENU	NM_SUB,ReadTrackRT.MSG,,'RT'
			MKMENU	NM_SUB,NM_BARLABEL
			MKMENU	NM_SUB,WriteSectorWS.MSG,,'WS'
			MKMENU	NM_SUB,WriteTrackWT.MSG,,'WT'
			MKMENU	NM_SUB,NM_BARLABEL
			MKMENU	NM_SUB,CalcCheckCC.MSG,,'CC'
			MKMENU	NM_SUB,BBSimul.MSG,,'BB'
		MKMENU	NM_ITEM,NM_BARLABEL
		MKMENU	NM_ITEM,ExternE.MSG,,'E'<<8
		MKMENU	NM_ITEM,Output.MSG,,'>'<<8
		MKMENU	NM_ITEM,Calculate.MSG,,'?'<<8
		MKMENU	NM_ITEM,Calculatefloa.MSG,,'['<<8
		MKMENU	NM_ITEM,CustomRegiste.MSG,,'=R'
	MKMENUEND

;********* editor menu's *************

Editor_menus:
	MKMENU	NM_TITLE,Assembler.MSG
		MKMENU	NM_ITEM,Assemble.MSG
			MKMENU	NM_SUB,Assemble.MSG,A.MSG,45
			MKMENU	NM_SUB,Optimize.MSG,O.MSG,59
		MKMENU	NM_ITEM,NM_BARLABEL
		MKMENU	NM_ITEM,Editor.MSG,,49
		MKMENU	NM_ITEM,Debugger.MSG,D.MSG,48
		MKMENU	NM_ITEM,Monitor.MSG,M.MSG,57
	IF	useplugins
		MKMENU	NM_ITEM,PluginWin.MSG,,60		; amiga-P
	ENDIF
		MKMENU	NM_ITEM,Preferences.MSG
			MKMENU	NM_SUB,Environment.MSG,BracketOpen.MSG,9
			MKMENU	NM_SUB,Assembler_.MSG,BracketClose.MSG,12
			MKMENU	NM_SUB,Syntaxpr.MSG,Z.MSG,70
;			MKMENU	NM_SUB,colors_.MSG,,'=C'
		MKMENU	NM_ITEM,NM_BARLABEL
		MKMENU	NM_ITEM,Agaguide.MSG,,101
	MKMENU	NM_TITLE,Edit.MSG
		MKMENU	NM_ITEM,UpdateSourceU.MSG,,41	; amiga-w
		MKMENU	NM_ITEM,Block.MSG
			MKMENU	NM_SUB,Mark.MSG,b.MSG,20
			MKMENU	NM_SUB,Copy.MSG,c.MSG,21
			MKMENU	NM_SUB,Cut.MSG,x.MSG,42
			MKMENU	NM_SUB,Insert.MSG,v.MSG,40	; amiga-v
			MKMENU	NM_SUB,Insert.MSG,i.MSG,40	; amiga-i
			MKMENU	NM_SUB,Fill.MSG,f.MSG,27
			MKMENU	NM_SUB,UnMark.MSG,u.MSG,39
			MKMENU	NM_SUB,Lowercase.MSG,l.MSG,30
			MKMENU	NM_SUB,Uppercase.MSG,L.MSG,56
			MKMENU	NM_SUB,Rotate.MSG,y.MSG,43
			MKMENU	NM_SUB,Register.MSG,k.MSG,29
			MKMENU	NM_SUB,Write.MSG,W.MSG,67	; was 41
			MKMENU	NM_SUB,VerticalFill.MSG,n.MSG,32
			MKMENU	NM_SUB,Comment.MSG,semicolon.MSG,17
			MKMENU	NM_SUB,Uncomment.MSG,colon.MSG,18
			MKMENU	NM_SUB,Tabulate.MSG,p.MSG,34
			MKMENU	NM_SUB,SelectAll.MSG,q.MSG,35
			MKMENU	NM_SUB,SpaceToTab.MSG,K.MSG,55
		MKMENU	NM_ITEM,Search.MSG
			MKMENU	NM_SUB,Search.MSG,S.MSG,63
			MKMENU	NM_SUB,Forward.MSG,s.MSG,37
		MKMENU	NM_ITEM,Replace.MSG
			MKMENU	NM_SUB,Replace.MSG,R.MSG,62
			MKMENU	NM_SUB,Forward.MSG,r.MSG,36
		MKMENU	NM_ITEM,DeleteLine.MSG,d.MSG,22
		MKMENU	NM_ITEM,SetMarks.MSG
			MKMENU	NM_SUB,Mark1.MSG,SetMark1.MSG,79
			MKMENU	NM_SUB,Mark2.MSG,SetMark2.MSG,80
			MKMENU	NM_SUB,Mark3.MSG,SetMark3.MSG,81
			MKMENU	NM_SUB,Mark4.MSG,SetMark4.MSG,86
			MKMENU	NM_SUB,Mark5.MSG,SetMark5.MSG,87
			MKMENU	NM_SUB,Mark6.MSG,SetMark6.MSG,88
			MKMENU	NM_SUB,Mark7.MSG,SetMark7.MSG,89
			MKMENU	NM_SUB,Mark8.MSG,SetMark8.MSG,90
			MKMENU	NM_SUB,Mark9.MSG,SetMark9.MSG,91
			MKMENU	NM_SUB,Mark10.MSG,SetMark10.MSG,92
		MKMENU	NM_ITEM,JumpMarks.MSG
			MKMENU	NM_SUB,Jump1.MSG,one.MSG,71
			MKMENU	NM_SUB,Jump2.MSG,two.MSG,72
			MKMENU	NM_SUB,Jump3.MSG,three.MSG,73
			MKMENU	NM_SUB,Jump4.MSG,four.MSG,93
			MKMENU	NM_SUB,Jump5.MSG,five.MSG,94
			MKMENU	NM_SUB,Jump6.MSG,six.MSG,95
			MKMENU	NM_SUB,Jump7.MSG,seven.MSG,96
			MKMENU	NM_SUB,Jump8.MSG,eight.MSG,97
			MKMENU	NM_SUB,Jump9.MSG,nine.MSG,98
			MKMENU	NM_SUB,Jump10.MSG,zero.MSG,99
		MKMENU	NM_ITEM,Jump.MSG,J.MSG,54
		MKMENU	NM_ITEM,JumpLine.MSG,j.MSG,28
		MKMENU	NM_ITEM,JumpError.MSG,e.MSG,23
		MKMENU	NM_ITEM,Move.MSG
			MKMENU	NM_SUB,BeginofLinesh.MSG,,6
			MKMENU	NM_SUB,EndofLinerigh.MSG,,7
			MKMENU	NM_SUB,PageUpup.MSG,,5
			MKMENU	NM_SUB,PageDowndown.MSG,,8
			MKMENU	NM_SUB,Up100.MSG,a.MSG,19
			MKMENU	NM_SUB,Down100.MSG,z.MSG,44
			MKMENU	NM_SUB,Top.MSG,t.MSG,38
			MKMENU	NM_SUB,Bottom.MSG,T.MSG,64
			MKMENU	NM_SUB,LeftWordaltle.MSG,,10
			MKMENU	NM_SUB,RightWordaltr.MSG,,11
			MKMENU	NM_SUB,BeginofLinesh.MSG,,6
			MKMENU	NM_SUB,BeginofLinesh.MSG,,6
			MKMENU	NM_SUB,BeginofLinesh.MSG,,6
			MKMENU	NM_SUB,BeginofLinesh.MSG,,6
			MKMENU	NM_SUB,BeginofLinesh.MSG,,6
		MKMENU	NM_ITEM,MakeMacro.MSG,comma.MSG,83
		MKMENU	NM_ITEM,DoMacro.MSG,m.MSG,31
		MKMENU	NM_ITEM,GrabWord.MSG,g.MSG,25
		MKMENU	NM_ITEM,Nr2Ascii.MSG,h.MSG,26
		MKMENU	NM_ITEM,Exit3.MSG,E.MSG,27<<8
	MKMENU	NM_TITLE,Sources.MSG
		MKMENU	NM_ITEM,F1.MSG,,103
		MKMENU	NM_ITEM,F2.MSG,,104
		MKMENU	NM_ITEM,F3.MSG,,105
		MKMENU	NM_ITEM,F4.MSG,,106
		MKMENU	NM_ITEM,F5.MSG,,107
		MKMENU	NM_ITEM,F6.MSG,,108
		MKMENU	NM_ITEM,F7.MSG,,109
		MKMENU	NM_ITEM,F8.MSG,,110
		MKMENU	NM_ITEM,F9.MSG,,111
		MKMENU	NM_ITEM,F10.MSG,,112
	MKMENUEND

;********** monitor menus ************

monitor_menus:
	MKMENU	NM_TITLE,Assembler.MSG
		MKMENU	NM_ITEM,Assemble.MSG
			MKMENU	NM_SUB,Assemble.MSG,A.MSG,45
			MKMENU	NM_SUB,Optimize.MSG,O.MSG,59
		MKMENU	NM_ITEM,NM_BARLABEL
		MKMENU	NM_ITEM,Editor.MSG,E.MSG,49
		MKMENU	NM_ITEM,Debugger.MSG,D.MSG,48
		MKMENU	NM_ITEM,Monitor.MSG,M.MSG,57
	IF	useplugins
		MKMENU	NM_ITEM,PluginWin.MSG,,60		; amiga-P
	ENDIF
		MKMENU	NM_ITEM,Preferences.MSG
			MKMENU	NM_SUB,Environment.MSG,BracketOpen.MSG,9
			MKMENU	NM_SUB,Assembler_.MSG,BracketClose.MSG,12
			MKMENU	NM_SUB,Syntaxpr.MSG,Z.MSG,70
;			MKMENU	NM_SUB,colors_.MSG,,'=C'
		MKMENU	NM_ITEM,NM_BARLABEL
		MKMENU	NM_ITEM,Agaguide.MSG,,101
	MKMENU	NM_TITLE,Monitor.MSG	
		MKMENU	NM_ITEM,Disassemble.MSG,d.MSG,22
		MKMENU	NM_ITEM,HexDump.MSG,h.MSG,26
		MKMENU	NM_ITEM,ASCIIDump.MSG,n.MSG,32
		MKMENU	NM_ITEM,BinDump.MSG,b.MSG,33
		MKMENU	NM_ITEM,NM_BARLABEL
		MKMENU	NM_ITEM,JumpAddress.MSG,j.MSG,28
		MKMENU	NM_ITEM,LastAddress.MSG,l.MSG,30
		MKMENU	NM_ITEM,QuickJump.MSG,q.MSG,35
		MKMENU	NM_ITEM,NM_BARLABEL
		MKMENU	NM_ITEM,SetMarks.MSG
			MKMENU	NM_SUB,Mark1.MSG,SetMark1.MSG,79
			MKMENU	NM_SUB,Mark2.MSG,SetMark2.MSG,80
			MKMENU	NM_SUB,Mark3.MSG,SetMark3.MSG,81
		MKMENU	NM_ITEM,JumpMarks.MSG
			MKMENU	NM_SUB,Jump1.MSG,one.MSG,71
			MKMENU	NM_SUB,Jump2.MSG,two.MSG,72
			MKMENU	NM_SUB,Jump3.MSG,three.MSG,73
		MKMENU	NM_ITEM,NM_BARLABEL
		MKMENU	NM_ITEM,SetStart.MSG,comma.MSG,83
		MKMENU	NM_ITEM,SetEnd.MSG,period.MSG,84
		MKMENU	NM_ITEM,SaveBin.MSG,w.MSG,85
		MKMENU	NM_ITEM,NM_BARLABEL
	IF	MEMSEARCH
		MKMENU	NM_ITEM,Search.MSG,s.MSG,86
		MKMENU	NM_ITEM,Forward.MSG,f.MSG,87
	ENDIF
		MKMENU	NM_ITEM,NM_BARLABEL
		MKMENU	NM_ITEM,Exit2.MSG,,27<<8
	MKMENUEND

;************ debugger menus **************

debug_menus:
	MKMENU	NM_TITLE,Assembler.MSG
		MKMENU	NM_ITEM,Assemble.MSG
			MKMENU	NM_SUB,Assemble.MSG,A.MSG,45
			MKMENU	NM_SUB,Optimize.MSG,O.MSG,59
		MKMENU	NM_ITEM,NM_BARLABEL
		MKMENU	NM_ITEM,Editor.MSG,E.MSG,49
		MKMENU	NM_ITEM,Debugger.MSG,D.MSG,48
		MKMENU	NM_ITEM,Monitor.MSG,M.MSG,57
	IF	useplugins
		MKMENU	NM_ITEM,PluginWin.MSG,,60		; amiga-P
	ENDIF
		MKMENU	NM_ITEM,Preferences.MSG,,,NM_ITEMDISABLED
			MKMENU	NM_SUB,Environment.MSG,BracketOpen.MSG,9
			MKMENU	NM_SUB,Assembler_.MSG,BracketClose.MSG,12
	MKMENU	NM_TITLE,Debug.MSG
		MKMENU	NM_ITEM,StepOneDown.MSG,,4
		MKMENU	NM_ITEM,EnterRight.MSG,,3
		MKMENU	NM_ITEM,Run.MSG,r.MSG,36
		MKMENU	NM_ITEM,StepN.MSG,s.MSG,37
		MKMENU	NM_ITEM,Skipinstructi.MSG,k.MSG,101
		MKMENU	NM_ITEM,Rununtilhere.MSG,u.MSG,87
		MKMENU	NM_ITEM,Animate.MSG,i.MSG,100
		MKMENU	NM_ITEM,NM_BARLABEL
		MKMENU	NM_ITEM,EditRegs.MSG,x.MSG,42
		MKMENU	NM_ITEM,AddWatch.MSG,a.MSG,19
		MKMENU	NM_ITEM,DelWatch.MSG
			MKMENU	NM_SUB,blank.MSG,one.MSG,71
			MKMENU	NM_SUB,blank.MSG,two.MSG,72
			MKMENU	NM_SUB,blank.MSG,three.MSG,73
			MKMENU	NM_SUB,blank.MSG,four.MSG,74
			MKMENU	NM_SUB,blank.MSG,five.MSG,75
			MKMENU	NM_SUB,blank.MSG,six.MSG,76
			MKMENU	NM_SUB,blank.MSG,seven.MSG,77
			MKMENU	NM_SUB,blank.MSG,eight.MSG,78
		MKMENU	NM_ITEM,ZapWatchs.MSG,Z.MSG,70
		MKMENU	NM_ITEM,ZapConBPs.MSG,G.MSG,122
		MKMENU	NM_ITEM,NM_BARLABEL
		MKMENU	NM_ITEM,JumpAddress.MSG,J.MSG,54
		MKMENU	NM_ITEM,JumpMark.MSG,j.MSG,28
		MKMENU	NM_ITEM,BPCondition.MSG,f.MSG,113
		MKMENU	NM_ITEM,DelCondition.MSG
			MKMENU	NM_SUB,blank.MSG,SetMark1.MSG,114
			MKMENU	NM_SUB,blank.MSG,SetMark2.MSG,115
			MKMENU	NM_SUB,blank.MSG,SetMark3.MSG,116
			MKMENU	NM_SUB,blank.MSG,SetMark4.MSG,117
			MKMENU	NM_SUB,blank.MSG,SetMark5.MSG,118
			MKMENU	NM_SUB,blank.MSG,SetMark6.MSG,119
			MKMENU	NM_SUB,blank.MSG,SetMark7.MSG,120
			MKMENU	NM_SUB,blank.MSG,SetMark8.MSG,121
		MKMENU	NM_ITEM,BPAddress.MSG,B.MSG,46
		MKMENU	NM_ITEM,BPMark.MSG,b.MSG,20
		MKMENU	NM_ITEM,ZapAllBP.MSG,z.MSG,44
debug_menus_reg_change:
		MKMENU	NM_ITEM,ChangeDxFPx.MSG,C.MSG,47
		MKMENU	NM_ITEM,NM_BARLABEL
		MKMENU	NM_ITEM,Exit1.MSG,,27<<8
	MKMENUEND

****************************************************************

Project.MSG:		dc.b	'Project',0
ProjectinfoP.MSG:	dc.b	'Project info   =P',0
ZapSourceZS.MSG:	dc.b	'Zap Source     ZS',0
OldO.MSG:		dc.b	'Old             O',0
Read.MSG:		dc.b	'Read',0
EnviornmentRE.MSG:	dc.b	'Environment RE',0
SourceR.MSG:		dc.b	'Source      R',0
SourceRN.MSG:		dc.b	'Text        RN',0
BinaryRB.MSG:		dc.b	'Binary      RB',0
ObjectRO.MSG:		dc.b	'Object      RO',0
Write.MSG:		dc.b	'Write',0
EnviornmentWE.MSG:	dc.b	'Environment WE',0
SourceW.MSG:		dc.b	'Source      W',0
SourceWN.MSG:		dc.b	'Text        WN',0
BinaryWB.MSG:		dc.b	'Binary      WB',0
ObjectWO.MSG:		dc.b	'Object      WO',0
LinkWL.MSG:		dc.b	'Link        WL',0
PreferencesWP.MSG:	dc.b	'Preferences WP',0
InsertI.MSG:		dc.b	'Insert          I',0
Update.MSG:		dc.b	'Update           ',0
UpdateSourceU.MSG:	dc.b	'Update Source  U ',0
w.MSG:			dc.b	"w",0
UpdateProject.MSG:	dc.b	'Update Project UA',0
ZapFileZF.MSG:		dc.b	'Zap File       ZF',0
ZapIncMemZI.MSG:	dc.b	'Zap IncMem     ZI',0
RecentFiles.MSG:	dc.b	'Recent files',0
AddWorkMemM.MSG:	dc.b	'Add WorkMem    =M',0
About.MSG:		dc.b	'About           #',0
Quit.MSG:		dc.b	'Quit           ! ',0
QuickQuit.MSG:		dc.b	'Quick Quit     !!',0
Restarting.MSG:		dc.b	'Quick Restart  !R',0
Assemble.MSG:		dc.b	'Assemble',0
A.MSG:			dc.b	'A',0
Optimize.MSG:		dc.b	'Optimize   ',0
Checkonly.MSG:		dc.b	'Check only ',0
Objectinfo.MSG:		dc.b	'Object info   =',0
E.MSG:			dc.b	'E',0
Debugger.MSG:		dc.b	'Debugger',0
Monitor.MSG:		dc.b	'Monitor',0
M.MSG:			dc.b	'M',0
PluginWin.MSG:		dc.b	'Show Plugin''s',0
Preferences.MSG:	dc.b	'Preferences   ',0
Environment.MSG:	dc.b	'Environment',0
BracketOpen.MSG:	dc.b	'[',0
Assembler_.MSG:		dc.b	'Assembler  ',0
BracketClose.MSG:	dc.b	']',0
Syntaxpr.MSG:		dc.b	'Syntax Colors',0
colors_.MSG:		dc.b	'Colors   =C',0
Agaguide.MSG:		dc.b	'Asm-Pro Help HELP',0
Block.MSG:		dc.b	'Block',0
Mark.MSG:		dc.b	'Mark',0
b.MSG:			dc.b	'b',0
Comment.MSG:		dc.b	'Comment',0
semicolon.MSG:		dc.b	';',0
Uncomment.MSG:		dc.b	'Uncomment',0
colon.MSG:		dc.b	':',0
Tabulate.MSG:		dc.b	'Tabulate',0
p.MSG:			dc.b	'p',0
SelectAll.MSG:		dc.b	'Select all',0
SpaceToTab.MSG:		dc.b	'Spaces to tabs',0
K.MSG:			dc.b	'K',0
Copy.MSG:		dc.b	'Copy',0
c.MSG:			dc.b	'c',0
Cut.MSG:		dc.b	'Cut',0
x.MSG:			dc.b	'x',0
i.MSG:			dc.b	'i',0
v.MSG:			dc.b	'v',0
Fill.MSG:		dc.b	'Fill',0
f.MSG:			dc.b	'f',0
UnMark.MSG:		dc.b	'UnMark',0
Lowercase.MSG:		dc.b	'Lowercase',0
l.MSG:			dc.b	'l',0
Uppercase.MSG:		dc.b	'Uppercase',0
Rotate.MSG:		dc.b	'Rotate',0
y.MSG:			dc.b	'y',0
Register.MSG:		dc.b	'Register',0
k.MSG:			dc.b	'k',0
W.MSG:			dc.b	"W",00		;was w
VerticalFill.MSG:	dc.b	'Vertical Fill',0
n.MSG:			dc.b	'n',0
S.MSG:			dc.b	'S',0
Forward.MSG:		dc.b	'Forward',0
Replace.MSG:		dc.b	'Replace',0
R.MSG:			dc.b	'R',0
r.MSG:			dc.b	'r',0
DeleteLine.MSG:		dc.b	'Delete Line',0
d.MSG:			dc.b	'd',0
SetMarks.MSG:		dc.b	'Set Marks',0
Mark1.MSG:		dc.b	'Mark 1  ',0
Mark2.MSG:		dc.b	'Mark 2',0
Mark3.MSG:		dc.b	'Mark 3',0
Mark4.MSG:		dc.b	'Mark 4',0
Mark5.MSG:		dc.b	'Mark 5',0
Mark6.MSG:		dc.b	'Mark 6',0
Mark7.MSG:		dc.b	'Mark 7',0
Mark8.MSG:		dc.b	'Mark 8',0
Mark9.MSG:		dc.b	'Mark 9',0
Mark10.MSG:		dc.b	'Mark 10',0
RemapMarkKeys:	; these will be adjusted in run-time based on locale
SetMark1.MSG:	dc.b	'!',0
SetMark2.MSG:	dc.b	'@',0
SetMark3.MSG:	dc.b	'#',0
SetMark4.MSG:	dc.b	'$',0
SetMark5.MSG:	dc.b	'%',0
SetMark6.MSG:	dc.b	'^',0
SetMark7.MSG:	dc.b	'&',0
SetMark8.MSG:	dc.b	'*',0
SetMark9.MSG:	dc.b	'(',0
SetMark10.MSG:	dc.b	')',0
RemapMarkKeysEnd:
JumpMarks.MSG:	dc.b	'Jump Marks',0
Jump1.MSG:	dc.b	'Jump 1  ',0
one.MSG		DC.B	'1',0
Jump2.MSG:	dc.b	'Jump '
two.MSG		DC.B	'2',0
Jump3.MSG:	dc.b	'Jump '
three.MSG	DC.B	'3',0
Jump4.MSG:	dc.b	'Jump '
four.MSG	DC.B	'4',0
Jump5.MSG:	dc.b	'Jump '
five.MSG	DC.B	'5',0
Jump6.MSG:	dc.b	'Jump '
six.MSG		DC.B	'6',0
Jump7.MSG:	dc.b	'Jump '
seven.MSG	DC.B	'7',0
Jump8.MSG:	dc.b	'Jump '
eight.MSG	DC.B	'8',0
Jump9.MSG:	dc.b	'Jump '
nine.MSG	DC.B	'9',0
Jump10.MSG:	dc.b	'Jump 1'
zero.MSG	DC.B	'0',0

Jump.MSG:	dc.b	'Jump ;;',0
J.MSG:		dc.b	'J',0
JumpLine.MSG:	dc.b	'Jump Line',0
j.MSG:		dc.b	'j',0
JumpError.MSG	DC.B	'Jump Error',0
e.MSG:		DC.B	'e',0
Move.MSG:	dc.b	'Move',0
BeginofLinesh.MSG:
		dc.b	'Begin of Line  shift left',0
EndofLinerigh.MSG:
		dc.b	'End of Line      -  right',0
PageUpup.MSG:
		dc.b	'Page Up          -     up',0
PageDowndown.MSG:
		dc.b	'Page Down        -   down',0

Up100.MSG:	dc.b	'Up 100',0
a.MSG:		dc.b	'a',0
Down100.MSG:	dc.b	'Down 100',0
z.MSG:		dc.b	'z',0
Top.MSG:	dc.b	'Top',0
t.MSG:		dc.b	't',0
Bottom.MSG:	dc.b	'Bottom',0
T.MSG:		dc.b	'T',0
LeftWordaltle.MSG:
		dc.b	'Left Word       alt  left',0
RightWordaltr.MSG:
		dc.b	'Right Word      alt right',0
MakeMacro.MSG:	dc.b	'Make Macro',0
comma.MSG:	dc.b	',',0
DoMacro.MSG:	dc.b	'Do Macro',0
m.MSG:		dc.b	'm',0
GrabWord.MSG:	dc.b	'Grab Word',0
g.MSG:		dc.b	'g',0
Nr2Ascii.MSG:	dc.b	"Nr 2 Ascii",0
Exit3.MSG:	dc.b	'Exit         esc',0
StepOneDown.MSG:dc.b	'Step One (Down)',0
EnterRight.MSG:	dc.b	'Enter (Right)',0
Run.MSG:	dc.b	'Run',0
StepN.MSG:	dc.b	'Step N',0
Rununtilhere.MSG:
		dc.b	'Run until here',0
u.MSG:		dc.b	'u',0
Animate.MSG:	dc.b	'Animate',0
Skipinstructi.MSG:
		dc.b	'Skip instruction',0
EditRegs.MSG:	dc.b	'Edit Regs',0
AddWatch.MSG:	dc.b	'Add Watch',0
DelWatch.MSG:	dc.b	'Del Watch',0

ZapWatchs.MSG:	dc.b	'Zap Watch''s',0
Z.MSG:		dc.b	'Z',0
ZapConBPs.MSG:	dc.b	'Zap Con B.P''s',0
G.MSG:		dc.b	'G',0
JumpMark.MSG:	dc.b	'Jump Mark',0
BPCondition.MSG:dc.b	'B.P. Condition',0
DelCondition.MSG:
		dc.b	'Del Condition',0

blank.MSG:	dc.b	' ',0

BPAddress.MSG:	dc.b	'B.P. Address',0
B.MSG:		dc.b	'B',0
BPMark.MSG:	dc.b	'B.P. Mark',0
ZapAllBP.MSG:	dc.b	'Zap All B.P.',0
ChangeDxFPx.MSG:
		dc.b	'Change Dx/FPx',0
C.MSG:		dc.b	'C',0
Exit1.MSG:	dc.b	'Exit       esc',0
Commands.MSG:	dc.b	'Commands',0
JumpTopT.MSG:	dc.b	'Jump Top       T',0
JumpBottomB.MSG:dc.b	'Jump Bottom    B',0
SearchL.MSG:	dc.b	'Search         L',0
ZapLinesZL.MSG:	dc.b	'Zap Line(s)    ZL',0
PrintLinesP.MSG:
		dc.b	'Print Line(s)  P',0
ExtendLabelsE.MSG:
		dc.b	'Extend Labels  EL',0
Memory.MSG:	dc.b	'Memory',0
EditM.MSG:	dc.b	'Edit            M',0
DisassembleD.MSG:
		dc.b	'Disassemble     D',0
HexDumpH.MSG:	dc.b	'HexDump         H',0
ASCIIN.MSG:	dc.b	'ASCII           N',0
BINDUMP.MSG:	dc.b	'BinDump         BM',0
DisLineD.MSG:	dc.b	'DisLine         @D',0
AssembleAtA.MSG:
		dc.b	'Assemble        @A',0
HexLineH.MSG:	dc.b	'HexLine         @H',0
ASCIILineN.MSG:	dc.b	'ASCII Line      @N',0
BinLineB.MSG:	dc.b	'Bin Line        @B',0
SearchMemoryS.MSG:
		dc.b	'Search Memory   S',0
FillMemoryF.MSG:dc.b	'Fill Memory     F',0
CopyMemoryC.MSG:dc.b	'Copy Memory     C',0
CompareMemory.MSG:
		dc.b	'Compare Memory  Q',0
CreateSinusCS.MSG:
		dc.b	'Create Sinus    CS',0
Insert.MSG:	dc.b	'Insert',0
DisAssemblyID.MSG:
		dc.b	'DisAssembly    ID',0
HEXDumpIH.MSG:	dc.b	'HEX Dump       IH',0
ASCIIDumpIN.MSG:dc.b	'ASCII Dump     IN',0
BinaryDumpIB.MSG:
		dc.b	'Binary Dump    IB',0
CreateSinusIS.MSG:
		dc.b	'Create Sinus   IS',0
AssembleA.MSG:	dc.b	'Assemble        A',0
MemoryA.MSG:	dc.b	'Memory          @A',0
OptimizeAO.MSG:	dc.b	'Optimize        AO',0
DebugAD.MSG:	dc.b	'Debug           AD',0
SymbolsS.MSG:	dc.b	'Symbols         =S',0
ParametersSet.MSG:
		dc.b	'Parameters Set  PS',0
JumpJ.MSG:	dc.b	'Jump       J',0
GoG.MSG:	dc.b	'Go         G',0
StepK.MSG:	dc.b	'Step       K',0
StatusX.MSG:	dc.b	'Status     X',0
ZapBPSZB.MSG:	dc.b	'Zap BPS    ZB',0
Disk.MSG:	dc.b	'Disk',0
ReadSectorRS.MSG:
		dc.b	'Read Sector    RS',0
ReadTrackRT.MSG:dc.b	'Read Track     RT',0
WriteSectorWS.MSG:
		dc.b	'Write Sector   WS',0
WriteTrackWT.MSG:
		dc.b	'Write Track    WT',0
CalcCheckCC.MSG:dc.b	'Calc Check     CC',0
BBSimul.MSG:	dc.b	'BB Simulator   BS',0			
ExternE.MSG:	dc.b	'Extern            E',0
Output.MSG:	dc.b	'Output            >',0
Calculate.MSG:	dc.b	'Calculate         ?',0
Calculatefloa.MSG:
		dc.b	'Calculate float   [',0
CustomRegiste.MSG:
		dc.b	'Custom Registers  =R',0
Disassemble.MSG:dc.b	'Disassemble',0
HexDump.MSG:	dc.b	'Hex Dump',0
h.MSG:		dc.b	'h',0
ASCIIDump.MSG:	dc.b	'ASCII Dump',0
BinDump.MSG:	dc.b	'Bin Dump',0
JumpAddress.MSG:dc.b	'Jump Address',0
LastAddress.MSG:dc.b	'Last Address',0
SaveBin.MSG:	dc.b	'Save Bin',0
s.MSG:		dc.b	's',0
SetStart.MSG:	dc.b	'Set Start',0
SetEnd.MSG:	dc.b	'Set End',0
period.MSG:	dc.b	'.',0
QuickJump.MSG:	dc.b	'Quick Jump',0
q.MSG:		dc.b	'q',0
Exit2.MSG:	dc.b	'Exit      esc',0
Sources.MSG:	dc.b	'Sources',0

F1.MSG:		dc.b	'F1 :                                    ',0
F2.MSG:		dc.b	'F2 :                                    ',0
F3.MSG:		dc.b	'F3 :                                    ',0
F4.MSG:		dc.b	'F4 :                                    ',0
F5.MSG:		dc.b	'F5 :                                    ',0
F6.MSG:		dc.b	'F6 :                                    ',0
F7.MSG:		dc.b	'F7 :                                    ',0
F8.MSG:		dc.b	'F8 :                                    ',0
F9.MSG:		dc.b	'F9 :                                    ',0
F10.MSG:	dc.b	'F10:                                    ',0


	EVEN
AmigaGuideGedoe:
	movem.l	d0-a6,-(sp)
	lea	(amigaguidelib.MSG,pc),a1
	move.l	(4).w,a6
	jsr	(_LVOOldOpenLibrary,a6)
	move.l	d0,-(sp)
	beq.b	.erroropenlib

	move.l	(DosBase-DT,a4),a6
	jsr	_LVOGetProgramDir(a6)
	move.l	d0,d1
	jsr	_LVOSetProgramDir(a6)
	move.l	d0,(AG_dirlock-DT,a4)

	lea	(AsmProGuide.MSG,pc),a0
	move.l	a0,d1
	moveq	#ACCESS_READ,d2
	jsr	_LVOLock(a6)
	move.l	d0,d1
	beq.b	.erroropenfile
	jsr	_LVOUnLock(a6)

	move.l	(sp),a6
	lea	(NewAmiGuide,pc),a0
	sub.l	a1,a1			;tagitems
	jsr	(_LVOOpenAmigaGuideA,a6)
	move.l	d0,(NewAmiGuideBase-DT,a4)
	beq.s	.erroropenfile

	move.l	(NewAmiGuideBase-DT,a4),a0
	jsr	(_LVOCloseAmigaGuide,a6)
	bra.b	.closelib

.erroropenlib
	lea	(Unabletoopena.MSG,pc),a0
	bra.b	.printerror
.erroropenfile
	lea	(Unabletoopent.MSG,pc),a0
.printerror
	jsr	(printTextInMenuStrip)

.closelib
	move.l	(sp)+,d0
	beq.b	.aldicht
	move.l	d0,a1
	move.l	(4).w,a6
	jsr	(_LVOCloseLibrary,a6)
.aldicht
	clr.w	(Cursor_col_pos-DT,a4)	;x
	jsr	Place_cursor_blokje
	movem.l	(sp)+,d0-a6
	rts

;	CNOP	0,4
;realend4:

;*************************************************
;**              PREFS WINDOWTJES               **
;*************************************************

;	SECTION	prefs,code

Handle_prefs_windows:
	sf	(FontChanged-DT,a4)
	move.l	(MainWindowHandle-DT,a4),a0
	bsr	Copy_prefs2buffer

	moveq	#76,d0
	mulu.w	(EFontSize_x-DT,a4),d0
	move.w	d0,(Prefs_win_br-DT,a4)
	move.w	d0,(Prefs_win_br2-DT,a4)
	move.w	(EFontSize_y-DT,a4),d0
	addq.w	#3,d0
	moveq	#15,d1
	mulu.w	d0,d1
	mulu.w	#22,d0
	move.w	d0,(Prefs_win_hg-DT,a4)
	move.w	d1,(Prefs_win_hg2-DT,a4)

	clr	(PrefsGedoe-DT,a4)

	tst.b	(Prefs_tiepe-DT,a4)
	bne.b	.asmprefs
	bsr	Prefs_initenvGads
	bsr.b	Prefs_CopyScreenInfo
	move.w	(Scr_NrPlanes-DT,a4),(old_screendepth-DT,a4)
	bsr	Open_Prefswindow
	bra.b	.envprefs

.asmprefs:
	cmp.b	#1,(Prefs_tiepe-DT,a4)
	bne.b	.syntcolsprefs
	bsr	Prefs_initasmGads
	bsr	Open_Prefswindow2
	bra.b	.envprefs

.syntcolsprefs:
	bsr	Prefs_initSyntGads
	bsr	OpenSyntColsWin

.envprefs:
	tst.l	d0
	bne.b	ErrorPrefsWin

	bsr	CreatePrefsMsgport
	bne.b	ErrorPrefsWin

	sf	(PR_CloseWin-DT,a4)
	bsr.b	PrefsEventloopje

	bsr	Close_Prefswindow
	bsr	RemovePrefsmsgPort
;	bsr	Prefs_endrequest

	cmp	#2,(PrefsGedoe-DT,a4)
	beq	ReinitStuff
	jmp	(RESETMENUTEXT)

Prefs_CopyScreenInfo:
	move.l	(SchermMode,pc),(scrmode_oud-DT,a4)
	move.l	(SchermMode,pc),(scrmode_new-DT,a4)
	move.l	(HoogteScherm,pc),(old_sizeY-DT,a4)
	move.l	(BreedteScherm,pc),(old_sizeX-DT,a4)
C23D9C:
	rts

ErrorPrefsWin:
;	bsr	Prefs_endrequest
	lea	(Notenoughmemo.MSG0-DT,a4),a0
	jmp	(printTextInMenuStrip)

PrefsEventloopje:
	move.l	(Prefs_msgport-DT,a4),a0
	move.b	(MP_SIGBIT,a0),d1
	moveq	#0,d0
	bset	d1,d0
	move.l	d0,(Prefs_Signal-DT,a4)
.Wait
	tst.b	(PR_CloseWin-DT,a4)
	bne.b	C23D9C
	move.l	(Prefs_Signal-DT,a4),d0
	move.l	(4).w,a6
	jsr	(_LVOWait,a6)
	move.l	d0,d1
	and.l	(Prefs_Signal-DT,a4),d1
	beq.b	.Wait
	bsr.b	PrefsProcesMsg
	bra.b	.Wait

PrefsProcesMsg:
	move.l	(Prefs_msgport-DT,a4),a0
	move.l	(GadToolsBase-DT,a4),a6
	jsr	(_LVOGT_GetIMsg,a6)
	move.l	d0,(PR_GTIMsg-DT,a4)
	beq.b	.C23DFE
	move.l	d0,a0
	move.l	(PrefsAsmWinBase-DT,a4),d1
	cmp.l	(im_IDCMPWindow,a0),d1		; $2c
	bne.b	.anderwindow

	bsr.b	Prefs_CheckoutMsg
	tst.b	(PrefsEndLoading-DT,a4)
	bne.b	.C23DFE
	move.l	(PR_GTIMsg-DT,a4),a1
	move.l	(GadToolsBase-DT,a4),a6
	jsr	(_LVOGT_ReplyIMsg,a6)
.anderwindow:
	bra.b	PrefsProcesMsg

.C23DFE	sf	(PrefsEndLoading-DT,a4)
	moveq	#0,d0
	rts

Prefs_CheckoutMsg:
	cmp.l	#IDCMP_REFRESHWINDOW,(im_Class,a0)
	bne.b	.C23E5A
	move.l	(PrefsAsmWinBase-DT,a4),a0
	move.l	(GadToolsBase-DT,a4),a6
	jsr	(_LVOGT_BeginRefresh,a6)
	move.l	(PrefsAsmWinBase-DT,a4),a0
	moveq	#1,d0
	jmp	(_LVOGT_EndRefresh,a6)

.C23E5A
	cmp.l	#IDCMP_MENUPICK,(im_Class,a0)
	beq.w	PR_menuCheck
	cmp.l	#IDCMP_GADGETUP,(im_Class,a0)
	bne.b	.C23E88
	tst.b	(Prefs_tiepe-DT,a4)
	beq.w	Prefs_checkbuttons_Env
	cmp.b	#1,(Prefs_tiepe-DT,a4)
	beq.w	Prefs_checkbuttons_Asm
	bra.w	Prefs_checkbuttons_Synt
.C23E88	cmp.l	#IDCMP_CLOSEWINDOW,(im_Class,a0)
	bne.b	.closeIt
	bsr	Copy_prefsFromBuffer
	st	(PR_CloseWin-DT,a4)
.closeIt:
	rts

C23EBA:
	lea	(Prefs_Gadgets-DT,a4),a0
	move.l	(4*EPG_ext,a0),a1
	move.l	($0022,a1),a1
	move.l	(a1),a1
	lea	(UserSrcExt.MSG,pc),a0
C23ED0:
	move.b	(a1)+,(a0)+
	tst.b	(a1)
	bne.b	C23ED0
	clr.b	(a0)
	lea	(Prefs_Gadgets-DT,a4),a0
	move.l	(4*EPG_dir,a0),a1
	move.l	($0022,a1),a1
	move.l	(a1),a1
	lea	(HomeDirectory-DT,a4),a0
C23EEC:
	move.b	(a1)+,(a0)+
	tst.b	(a1)
	bne.b	C23EEC
	clr.b	(a0)
	lea	(Prefs_Gadgets-DT,a4),a0
	move.l	(4*EPG_boot,a0),a1
	move.l	($0022,a1),a1
	move.l	(a1),a1
	lea	(BootUpString-DT,a4),a0
C23F08:
	move.b	(a1)+,(a0)+
	tst.b	(a1)
	bne.b	C23F08
	clr.b	(a0)
	rts

Prefs_initSyntGads:
	clr.w	(SyntItemIndex-DT,a4)	;eerste item eerst
	lea	fontcolortab,a0
	lea	TheColors(pc),a1
	moveq	#4-1,d7
.lopje	move.l	(a0)+,d0
	move.b	d0,(a1)+
	swap	d0
	move.b	d0,(a1)+
	addq.l	#2,a1	;skip 2 dummy bytes
	dbf	d7,.lopje
	rts

Prefs_initenvGads:
	lea	(Env_begin,pc),a1
	lea	(Prefs_EnvGadgets2+7-DT,a4),a3
	moveq	#(Env_end-Env_begin)/2-1,d7
.lopje	move.b	(a1),(a3)
	addq.w	#2,a1
	lea	(16,a3),a3
	dbra	d7,.lopje
	rts

Prefs_initasmGads:
	move	(CPU_type-DT,a4),(Prefs_AsmCpuType-DT,a4)
	lea	(Asm_begin,pc),a1
	lea	(Prefs_AsmGadgets2+7-DT,a4),a3
	moveq	#(Asm_end-Asm_begin)/2-1,d7
.lopje	move.b	(a1),(a3)
	addq.w	#2,a1
	lea	(16,a3),a3
	dbra	d7,.lopje
	rts

PR_menuCheck:
	move.l	d0,a1
	move.w	(im_Code,a1),d1		; sssssiiiiiimmmmm
	moveq	#$001f,d0
	and.w	d1,d0			; menu number
	lsr.w	#5,d1
	and.w	#$003f,d1		; item number
.Menu1
	tst.w	d0
	bne.b	.Menu2
	tst.w	d1
	beq.b	PR_loadPrefsFile
	subq.w	#1,d1
	beq.b	PR_savePrefs
	subq.w	#2,d1			; skip a separator
	beq	PR_ExitPrefsWin
	bra.b	.NotFound
.Menu2
	subq.w	#1,d0
	bne.b	.NotFound
	tst.w	d1
	beq	PR_Reset2Default
	subq.w	#1,d1
	beq	PR_LastSaved
.NotFound
	rts

PR_loadPrefsFile:
	move.l	(Error_Jumpback-DT,a4),(Error_Jumpback_Old-DT,a4)
	move.b	(SomeBits3-DT,a4),(SomeBits3_backup-DT,a4)
	bset	#SB3_REPORT_ERROR,(SomeBits3-DT,a4)
	lea	(PR_LoadSavePrefsErrHandler,pc),a0
	move.l	a0,(Error_Jumpback-DT,a4)
	moveq	#11,d0
	bsr	YesReqLib
	tst.b	(CurrentAsmLine-DT,a4)
	beq.b	PR_LoadSavePrefsErrHandler
	move.b	(Safety-DT,a4),-(sp)
	st	(Safety-DT,a4)
	jsr	(Read_Prefs2).l
	move.b	(sp)+,(Safety-DT,a4)
	bsr.b	PR_LoadSavePrefsErrHandler
	bsr	RemovePrefsmsgPort
	bsr	Close_Prefswindow
;	bsr	Close_Prefsscreen
	bra	C24134

PR_savePrefs:
	move.l	(Error_Jumpback-DT,a4),(Error_Jumpback_Old-DT,a4)
	move.b	(SomeBits3-DT,a4),(SomeBits3_backup-DT,a4)
	bset	#SB3_REPORT_ERROR,(SomeBits3-DT,a4)
	lea	(PR_LoadSavePrefsErrHandler,pc),a0
	move.l	a0,(Error_Jumpback-DT,a4)
	moveq	#12,d0
	bsr	YesReqLib
	tst.b	(CurrentAsmLine-DT,a4)
	beq.b	PR_LoadSavePrefsErrHandler
	bsr	Copy_prefsFromBuffer
	tst.b	(Prefs_tiepe-DT,a4)
	bne.b	C2407A
	bsr	C23EBA
C2407A:
	st	(HavePrefsFilename-DT,a4)
	move.b	(Safety-DT,a4),-(sp)
	st	(Safety-DT,a4)
	move.b	(SomeBits3-DT,a4),-(sp)
	bset	#SB3_SPEC_KEYS,(SomeBits3-DT,a4)		;in editor
	jsr	(Write_Prefs).l
	move.b	(sp)+,(SomeBits3-DT,a4)
	move.b	(sp)+,(Safety-DT,a4)
	sf	(HavePrefsFilename-DT,a4)

PR_LoadSavePrefsErrHandler:
	move.l	(Error_Jumpback_Old-DT,a4),(Error_Jumpback-DT,a4)
	move.b	(SomeBits3_backup-DT,a4),(SomeBits3-DT,a4)
	rts

PR_ExitPrefsWin:
	st	(PR_CloseWin-DT,a4)
	rts

PR_Reset2Default:
	lea	(DefaultPrefs-DT,a4),a0
	lea	(PR_ReqLib,pc),a1
	moveq	#(PR_end-Env_begin)/2-1,d7
.lopje	move	(a0)+,(a1)+
	dbra	d7,.lopje

	bsr.w	Prefs_CopyScreenInfo
	bsr	RemovePrefsmsgPort
	bsr	Close_Prefswindow
	bra.b	C24134

PR_LastSaved:
	move.b	(Safety-DT,a4),-(sp)
	st	(Safety-DT,a4)
	jsr	(Read_Prefs).l
	move.b	(sp)+,(Safety-DT,a4)
	bsr	RemovePrefsmsgPort
	bsr	Close_Prefswindow
	lea	(PrefsLoaded.MSG-DT,a4),a0
	jsr	(printTextInMenuStrip)
C24134:
	bsr	Prefs_initenvGads
	tst.b	(Prefs_tiepe-DT,a4)
	beq.b	C2414E
	bsr	Open_Prefswindow2
	bra.b	C24152

C2414E:
	bsr	Open_Prefswindow
C24152:
	tst.l	d0
	bne.b	.Fail
	bsr	CreatePrefsMsgport
	bne.b	.Fail
	move.l	(Prefs_msgport-DT,a4),a0
	move.b	(MP_SIGBIT,a0),d1
	moveq	#0,d0
	bset	d1,d0
	move.l	d0,(Prefs_Signal-DT,a4)
	st	(PrefsEndLoading-DT,a4)
	sf	(PR_CloseWin-DT,a4)
	bsr	Copy_prefs2buffer
.Fail	rts


Prefs_SaveMsg:
	move.l	d0,(PR_Msg-DT,a4)
	move.l	d0,a1
	move.l	(im_Class,a1),(PR_GadClass-DT,a4)
	move.l	(im_Code,a1),(PR_GadCode-DT,a4)
	move.l	(im_MouseX,a1),(PR_GadMouseX-DT,a4)	; mouse x,y
	move.l	(im_IAddress,a1),a0
	move.l	a0,(PR_GadgetAdr-DT,a4)
	moveq	#0,d1
	move.w	(gg_GadgetID,a0),d1
	move.w	d1,(PR_GadgetID-DT,a4)
	rts

Prefs_checkbuttons_Synt:
	bsr.b	Prefs_SaveMsg
	cmp	#SPG_save,d1
	beq	PW_envB_Save
	cmp	#SPG_use,d1
	beq	PW_envB_Use
	cmp	#SPG_cancel,d1
	beq	PW_envB_Cancel

	move	(PR_GadCode-DT,a4),d0
	lea	TheColors(pc),a0

	cmp	#SPG_ATTR,d1		;item
	bne.b	.PR_Front

	lsl.w	#2,d0
	move.w	d0,(SyntItemIndex-DT,a4)

	lea	.PalChange(pc),a3
	move.b	(a0,d0.w),(7,a3)
	move.l	(Prefs_Gadgets+SPG_FRONT*4-DT,a4),a0
	bsr	ChangeGadgetState

	move.w	(SyntItemIndex-DT,a4),d0
	lea	TheColors(pc),a0
	lea	.PalChange(pc),a3
	move.b	(1,a0,d0.w),(7,a3)
	move.l	(Prefs_Gadgets+SPG_BACK*4-DT,a4),a0
	bsr	ChangeGadgetState
	bra.b	.PR_nomore

.PR_Front:
	cmp	#SPG_FRONT,d1		;item
	bne.b	.PR_Back

	move.w	(SyntItemIndex-DT,a4),d1
	move.b	d0,(a0,d1.w)		;front pen

	bra.b	.rewrite

.PR_Back:
	cmp	#SPG_BACK,d1		;item
	bne.b	.PR_nomore

	move.w	(SyntItemIndex-DT,a4),d1
	move.b	d0,1(a0,d1.w)		;back pen

.rewrite
	bsr	ShowPrevSource

.PR_nomore:
	rts

.PalChange:
	dc.l	GTPA_Color,0	;false !!
	DC.L	TAG_DONE


Prefs_checkbuttons_Asm:
	bsr.w	Prefs_SaveMsg
	cmp	#APG_save,d1
	beq	PW_envB_Save
	cmp	#APG_use,d1
	beq	PW_envB_Use
	cmp	#APG_cancel,d1
	beq	PW_envB_Cancel

	cmp	#APG_CPU,d1
	bne.b	.PR_Checkboxes_Asm
	move	(PR_GadCode-DT,a4),(Prefs_AsmCpuType-DT,a4)
	bra.b	.PR_nomore_Asm

.PR_Checkboxes_Asm:
	move.l	(gg_UserData,a0),d0
	beq.b	.doit
	cmp	(PrefsGedoe-DT,a4),d0
	ble.b	.doit
	move	d0,(PrefsGedoe-DT,a4)
.doit:
	lea	(asm_prefsptr-DT,a4),a0
	IF	MC020
	move.l	(-APG_Rescue*4,a0,d1.w*4),a1
	ELSE
	lsl.w	#2,d1
	move.l	(-APG_Rescue*4,a0,d1.w),a1
	ENDIF
	eor.b	#1,(a1)
.PR_nomore_Asm:
	rts


Prefs_checkbuttons_Env:
	bsr.w	Prefs_SaveMsg
	cmp	#EPG_dir,d1		;dir
	beq.b	PW_envB_Dir
	cmp	#EPG_boot,d1		;boot
	beq.b	PW_envB_Dir
	cmp	#EPG_ext,d1		;ext.
	beq.b	PW_envB_Dir

	cmp	#EPG_save,d1		;save
	beq	PW_envB_Save
	cmp	#EPG_use,d1		;use
	beq	PW_envB_Use
	cmp	#EPG_cancel,d1		;cancel
	beq	PW_envB_Cancel

	cmp	#EPG_screen,d1
	beq.w	OpenScreenReq
	cmp	#EPG_font,d1
	beq.w	fontreq_edit

	cmp	#EPG_cs,d1
	beq.b	Customscrollknop

	cmp	#EPG_wt,d1
	bne.s	.noWaitTOF
	move.w	(PR_GadCode-DT,a4),d0
	btst	#0,d0
	beq.s	.noWaitTOF
	lea	wt_txt(pc),a1
	jsr	Error_req
.noWaitTOF:

CustomscrollToggle:
	move.l	(gg_UserData,a0),d0
	beq.b	.doit
	cmp	(PrefsGedoe-DT,a4),d0
	ble.b	.doit
	move	d0,(PrefsGedoe-DT,a4)
.doit:
	lea	(env_prefsptrs-DT,a4),a0
	IF	MC020
	move.l	(-EPG_rt*4,a0,d1.w*4),a1
	ELSE
	lsl.w	#2,d1
	move.l	(-EPG_rt*4,a0,d1.w),a1
	ENDIF
	eor.b	#1,(a1)
PW_envB_Dir:
	rts

Customscrollknop:
	cmp.l	#640,BreedteScherm
	beq.b	CustomscrollToggle

	lea	cs_txt(pc),a1
	jsr	Error_req

	move.l	(PR_GadgetAdr-DT,a4),a0	;gadget
	lea	(gadarr,pc),a3		;taglist

ChangeGadgetState:
	move.l	(GadToolsBase-DT,a4),a6
	move.l	(PrefsAsmWinBase-DT,a4),a1	;win
	sub.l	a2,a2			;req
	jmp	_LVOGT_SetGadgetAttrsA(a6)

gadarr:
	dc.l	GTCB_Checked,0	;false !!
	DC.L	TAG_DONE


OpenScreenReq:
	tst.l	(ReqToolsbase-DT,a4)
	bne.b	Screenmoderequester
	bsr.w	openreqtoolslib
	tst.l	(ReqToolsbase-DT,a4)
	bne.b	Screenmoderequester
C242CA:
	sf	(PR_CloseWin-DT,a4)
	rts

Screenmoderequester:
	moveq	#RT_SCREENMODEREQ,d0		; reqtools v38+
	sub.l	a0,a0
	move.l	(ReqToolsbase-DT,a4),a6
	jsr	(_LVOrtAllocRequestA,a6)
	move.l	d0,(screen_req-DT,a4)
	beq.b	C242CA

	lea	(Pleaseselectp.MSG-DT,a4),a3
	lea	(ScreenmodeTags-DT,a4),a0
	sub.l	a2,a2
	move.l	d0,a1
	jsr	(_LVOrtScreenModeRequestA,a6)
	tst.l	d0
	beq	.noChange

	move.l	(screen_req-DT,a4),a1
	move.l	(rtsc_DisplayID,a1),d0
	cmp.l	(scrmode_new-DT,a4),d0
	bne.b	.yesChange
	moveq	#0,d0
	move	(rtsc_DisplayWidth,a1),d0
	cmp.l	(old_sizeX-DT,a4),d0
	bne.b	.yesChange
	move	(rtsc_DisplayHeight,a1),d0
	cmp.l	(old_sizeY-DT,a4),d0
	bne.b	.yesChange

	move.w	(rtsc_DisplayDepth,a1),d0
	move.w	d0,(Scr_NrPlanes-DT,a4)
	cmp.w	(old_screendepth-DT,a4),d0
	bne.s	.yesChange
	bra.b	.noChange

.yesChange:
	moveq	#0,d0
	move	rtsc_DisplayWidth(a1),d0
	cmp.w	#640,d0
	bge.b	.CheckWidth
	move.w	#640,d0
.CheckWidth:
	and.w	#$FFF8,d0	;!!! mag wel hoor... byte alligned
	cmp.w	#640,d0
	beq.b	.verder
	clr.w	PR_CustomScroll
	clr.w	epp_customscroll
.verder:
	move.l	d0,ScrBr_1
	move.l	d0,BreedteScherm
	move	rtsc_DisplayHeight(a1),d0
	move.l	d0,Scrhoog_1
	move.l	d0,HoogteScherm

	move.w	rtsc_DisplayDepth(a1),(Scr_NrPlanes-DT,a4)

.noOnePlane:
	move.l	rtsc_DisplayID(a1),(scrmode_new-DT,a4)
	move	#2,(PrefsGedoe-DT,a4)	;refresh display...

.noChange:
	move.l	(screen_req-DT,a4),a1
	jmp	(_LVOrtFreeRequest,a6)

PW_envB_Cancel:
	movem.l	d0-a6,-(sp)			
	tst.b	(FontChanged-DT,a4)
	beq.b	NoFntChange
	movem.l	a0/a1,-(a7)			; restore font attributes
	lea	(Oldeditfont_name,pc),a0
	lea	(editfont_name,pc),a1
.FontRestore:
	move.b	(a0)+,(a1)+
	bne.s	.FontRestore
	lea	(EditorFontSize,pc),a0
	move.l	(OldEditorFontSize-EditorFontSize,a0),(a0) ; w/b/b
	movem.l	(a7)+,a0/a1

	bsr	close_edit_font
	bsr	init_edit_font
	move	#2,(PrefsGedoe-DT,a4)	;refresh display...
	st	(PR_CloseWin-DT,a4)
	movem.l	(sp)+,d0-a6
	rts
NoFntChange:
	movem.l	(sp)+,d0-a6

	clr	(PrefsGedoe-DT,a4)
	st	(PR_CloseWin-DT,a4)
	rts

PW_envB_Use:
	bsr	Copy_prefsFromBuffer
	tst.b	(Prefs_tiepe-DT,a4)
	bne.b	.asmprefs
	bsr	C23EBA
	move.l	(old_sizeX-DT,a4),d0
	cmp.l	(BreedteScherm,pc),d0
	bne.b	.C243F4
	move.l	(old_sizeY-DT,a4),d0
	cmp.l	(HoogteScherm,pc),d0
	bne.b	.C243F4
	move.l	(scrmode_oud-DT,a4),d0
	cmp.l	(scrmode_new-DT,a4),d0
	beq.b	.klaar
	tst.l	(scrmode_new-DT,a4)
	beq.b	.klaar
.C243F4:
	move.l	(scrmode_new-DT,a4),(SchermMode).l
	move	#2,(PrefsGedoe-DT,a4)
	bra.b	.klaar

.asmprefs:
	cmp.b	#1,(Prefs_tiepe-DT,a4)
	bne.b	.syntprefs

	move	(Prefs_AsmCpuType-DT,a4),(CPU_type-DT,a4)
	bra.b	.klaar

.syntprefs:
	bsr.b	SyntUseGedoe
.klaar:
	st	(PR_CloseWin-DT,a4)
	rts

SyntUseGedoe:
	lea	TheColors(pc),a0
	lea	fontcolortab,a1
	moveq	#4-1,d7
	moveq	#0,d0
.lopje:
	move.b	(a0)+,d0
	swap	d0
	move.b	(a0)+,d0
	move.l	d0,4*4(a1)
	swap	d0
	move.l	d0,(a1)+
	addq.l	#2,a0
	dbf	d7,.lopje
	rts

PW_envB_Save:
	bsr	Copy_prefsFromBuffer
	tst.b	(Prefs_tiepe-DT,a4)
	bne.b	.asmprefs
	bsr	C23EBA
	move.l	(old_sizeX-DT,a4),d0
	cmp.l	(BreedteScherm,pc),d0
	bne.b	.changed
	move.l	(old_sizeY-DT,a4),d0
	cmp.l	(HoogteScherm,pc),d0
	bne.b	.changed
	move.l	(scrmode_oud-DT,a4),d0
	cmp.l	(scrmode_new-DT,a4),d0
	beq.b	.notChanged
	tst.l	(scrmode_new-DT,a4)
	beq.b	.notChanged
.changed:
	move.l	(scrmode_new-DT,a4),(SchermMode).l
	move	#2,(PrefsGedoe-DT,a4)
	bra.b	.notChanged

.asmprefs:
	cmp.b	#1,(Prefs_tiepe-DT,a4)
	bne.b	.syntprefs
	move	(Prefs_AsmCpuType-DT,a4),(CPU_type-DT,a4)
	bra.b	.notChanged

.syntprefs:
	bsr.b	SyntUseGedoe

.notChanged:
	move.b	(Safety-DT,a4),-(sp)
	move.b	(SomeBits3-DT,a4),-(sp)
	st	(Safety-DT,a4)
	or.b	#(1<<SB3_SPEC_KEYS)|(1<<SB3_REPORT_ERROR),(SomeBits3-DT,a4)
	move.l	sp,(TEMP_STACKPTR-DT,a4)
	move.l	(Error_Jumpback-DT,a4),(Error_Jumpback_Old-DT,a4)
	lea	(Prefs_ErrorCB,pc),a0
	move.l	a0,(Error_Jumpback-DT,a4)
	jsr	(Write_Prefs).l
	move.b	(sp)+,(SomeBits3-DT,a4)
	move.b	(sp)+,(Safety-DT,a4)
	lea	(PrefsSaved.MSG-DT,a4),a0
	jsr	(printTextInMenuStrip)
	st	(PR_CloseWin-DT,a4)
	rts

Prefs_ErrorCB:
	move.l	(Error_Jumpback_Old-DT,a4),(Error_Jumpback-DT,a4)
	move.l	(TEMP_STACKPTR-DT,a4),sp
	move.b	(sp)+,(SomeBits3-DT,a4)
	move.b	(sp)+,(Safety-DT,a4)
	rts

Copy_prefs2buffer:
	lea	(PR_ReqLib,pc),a0
	lea	(epp_reqtools-DT,a4),a1
	moveq	#(PR_end-Env_begin)/2-1,d0
.lopje	move	(a0)+,(a1)+
	dbra	d0,.lopje
	move.l	(SchermMode,pc),(scrmode_oud-DT,a4)
	rts

Copy_prefsFromBuffer:
	lea	(PR_ReqLib,pc),a1
	lea	(epp_reqtools-DT,a4),a0
	moveq	#(PR_end-Env_begin)/2-1,d0
.lopje	move	(a0)+,(a1)+
	dbra	d0,.lopje
	rts

Prefs_LinkGadget:
	move.l	d0,a3
	lea	(Prefs_Gadgets-DT,a4),a0
	IF	MC020
	lea	(a0,d3.l*4),a0
	ELSE
	move.l	d3,d0
	asl.l	#2,d0
	add.l	d0,a0
	ENDIF
	move.l	a3,(a0)
	moveq	#-1,d0
.C246AE	cmp.l	(a5)+,d0
	bne.b	.C246AE
	addq.w	#1,d3
	rts

Prefs_MkGadget_A2:
	lea	(GadgetBuffer-DT,a4),a0
	move.l	(MainVisualInfo-DT,a4),(22,a0)
	lea	(Editor_Font,pc),a1
	move.l	a1,(12,a0)
	move.l	(4,sp),d0
	add.l	d0,(a0)			; adjust both x and y
	IF	MC020
	lea	(a2,d3.l*2),a2
	ELSE
	add.l	d3,a2
	add.l	d3,a2
	ENDIF
	moveq	#0,d0
	move.w	(a2),d0
	move.l	a3,a0
	lea	(GadgetBuffer-DT,a4),a1
	move.l	a5,a2
	jsr	(_LVOCreateGadgetA,a6)
	tst.l	d0
	rts

Prefs_CommonInit:
	jsr	(pos_gadgets)

	move.l	(ScreenBase,pc),a0
	moveq	#0,d2
	move.b	(sc_WBorLeft,a0),d2
	move.l	(sc_Font,a0),a1
	move.w	(ta_YSize,a1),d3
	addq.w	#1,d3
	add.b	(sc_WBorTop,a0),d3

	lea	(Prefs_GList-DT,a4),a0
	move.l	(GadToolsBase-DT,a4),a6
	jsr	_LVOCreateContext(a6)
	move.l	d0,a3
	tst.l	d0
	rts

Open_Prefswindow:
	movem.l	d1-d4/a0-a3/a5/a6,-(sp)

	lea	(env_gadspos-DT,a4),a0
	lea	(Env_prefs_gadstr-DT,a4),a1
	moveq	#env_gadcount-1,d7
	bsr.b	Prefs_CommonInit
	beq	Error_createcontext

	movem.w	d2/d3,-(sp)
	moveq	#0,d3
	lea	(Prefs_EnvGadTags-DT,a4),a5
.C2462C	lea	(Env_prefs_gadstr-DT,a4),a0
	bsr.w	Prefs_CopyGadget_A0
	lea	(Pref_EnvGadgetTypes-DT,a4),a2
	bsr.w	Prefs_MkGadget_A2
	beq	C24794
	bsr.w	Prefs_LinkGadget
	cmp	#env_gadcount,d3
	bmi.b	.C2462C
	movem.w	(sp)+,d2/d3

	move.l	(Prefs_GList-DT,a4),(Prefs_wingadgets-DT,a4)
	move.l	(ScreenBase,pc),(ScreenBaseTemp1-DT,a4)
	move.w	(W1D006-DT,a4),(Prefs_winleft+2-DT,a4)
	move.w	(W1D008-DT,a4),(Prefs_wintop+2-DT,a4)
	move.w	(Prefs_win_br-DT,a4),(Prefs_winbreedt+2-DT,a4)
	move	(Prefs_win_hg-DT,a4),d0
	add	d3,d0
	move.w	d0,(Prefs_winhoog+2-DT,a4)
	lea	(Prefs_newmenustr-DT,a4),a0
	sub.l	a1,a1
	jsr	(_LVOCreateMenusA,a6)
	move.l	d0,(PrefsMenuStrip-DT,a4)
	beq.b	.C24742
	move.l	d0,a0
	move.l	(MainVisualInfo-DT,a4),a1
	lea	(prefs_menutags-DT,a4),a2
	jsr	(_LVOLayoutMenusA,a6)
.C24742
	lea	(AsmProEnviron.MSG-DT,a4),a0
	move.l	a0,(Prefs_wintitle-DT,a4)
	sub.l	a0,a0
	lea	(Prefswin_taglist-DT,a4),a1
	move.l	(IntBase-DT,a4),a6
	jsr	(_LVOOpenWindowTagList,a6)
	move.l	d0,(PrefsAsmWinBase-DT,a4)
	beq.b	C24790
	move.l	(PrefsAsmWinBase-DT,a4),a0
	move.l	(PrefsMenuStrip-DT,a4),a1
	jsr	(_LVOSetMenuStrip,a6)
	move.l	(PrefsAsmWinBase-DT,a4),a0
	sub.l	a1,a1
	move.l	(GadToolsBase-DT,a4),a6
	jsr	(_LVOGT_RefreshWindow,a6)

	bsr	ProjectPrefswinRender

	moveq	#0,d0
C24782:
	movem.l	(sp)+,d1-d4/a0-a3/a5/a6
	rts

Error_createcontext:
	moveq	#1,d0
	bra.b	C24782

C24790:
	moveq	#4,d0
	bra.b	C24782

C24794:
	movem.w	(sp)+,d2/d3
	moveq	#1,d0
	bra.b	C24782

Close_Prefswindow:
	movem.l	d0/d1/a0-a2/a6,-(sp)
	move.l	(PrefsAsmWinBase-DT,a4),d0
	beq.b	.C247D6
	move.l	d0,a0
	move.l	(L2F148-DT,a4),(wd_UserPort,a0)
	moveq	#0,d0
	move.l	(PrefsAsmWinBase-DT,a4),a0
	move.l	(IntBase-DT,a4),a6
	jsr	(_LVOModifyIDCMP,a6)
	move.l	(PrefsAsmWinBase-DT,a4),a0
	jsr	(_LVOClearMenuStrip,a6)
.C247D6	move.l	(PrefsMenuStrip-DT,a4),d0
	beq.b	.C247EC
	move.l	d0,a0
	move.l	(GadToolsBase-DT,a4),a6
	jsr	(_LVOFreeMenus,a6)
.C247EC	move.l	(PrefsAsmWinBase-DT,a4),d0
	beq.b	.C24802
	move.l	d0,a0
	move.l	(IntBase-DT,a4),a6
	jsr	(_LVOCloseWindow,a6)
.C24802	move.l	(Prefs_GList-DT,a4),d0
	beq.b	.C24818
	move.l	d0,a0
	move.l	(GadToolsBase-DT,a4),a6
	jsr	(_LVOFreeGadgets,a6)
.C24818	movem.l	(sp)+,d0/d1/a0-a2/a6
	rts


Open_Prefswindow2:
	movem.l	d1-d4/a0-a3/a5/a6,-(sp)

	lea	(asm_gadspos-DT,a4),a0
	lea	(Asm_prefs_gadstr-DT,a4),a1
	moveq	#asm_gadcount-1,d7
	bsr.w	Prefs_CommonInit
	beq	.ProjectPrefsCError

	movem.w	d2/d3,-(sp)
	moveq	#0,d3
	lea	(Prefs_AsmGadTags-DT,a4),a5
.C24860	lea	(Asm_prefs_gadstr-DT,a4),a0
	bsr.w	Prefs_CopyGadget_A0
	lea	(Pref_AsmGadgetTypes-DT,a4),a2
	bsr.w	Prefs_MkGadget_A2
	beq	.C249C8
	bsr.w	Prefs_LinkGadget
	cmp	#asm_gadcount,d3
	bmi.b	.C24860
	movem.w	(sp)+,d2/d3

	move.l	(Prefs_GList-DT,a4),(Prefs_wingadgets-DT,a4)
	move.l	(ScreenBase,pc),(ScreenBaseTemp1-DT,a4)
	move.w	(W1D00E-DT,a4),(Prefs_winleft+2-DT,a4)
	move.w	(W1D010-DT,a4),(Prefs_wintop+2-DT,a4)
	move.w	(Prefs_win_br2-DT,a4),(Prefs_winbreedt+2-DT,a4)
	move	(Prefs_win_hg2-DT,a4),d0
	add	d3,d0
	move.w	d0,(Prefs_winhoog+2-DT,a4)
	lea	(Prefs_newmenustr-DT,a4),a0
	sub.l	a1,a1
	jsr	(_LVOCreateMenusA,a6)
	move.l	d0,(PrefsMenuStrip-DT,a4)
	beq.b	.C24976
	move.l	d0,a0
	move.l	(MainVisualInfo-DT,a4),a1
	lea	(prefs_menutags-DT,a4),a2
	jsr	_LVOLayoutMenusA(a6)
.C24976
	lea	(AsmProAsmPrefs-DT,a4),a0
	move.l	a0,(Prefs_wintitle-DT,a4)
	sub.l	a0,a0
	lea	(Prefswin_taglist-DT,a4),a1
	move.l	(IntBase-DT,a4),a6
	jsr	(_LVOOpenWindowTagList,a6)
	move.l	d0,(PrefsAsmWinBase-DT,a4)
	beq.b	.ProjectPrefsWError
	move.l	(PrefsAsmWinBase-DT,a4),a0
	move.l	(PrefsMenuStrip-DT,a4),a1
	jsr	(_LVOSetMenuStrip,a6)
	move.l	(PrefsAsmWinBase-DT,a4),a0
	sub.l	a1,a1
	move.l	(GadToolsBase-DT,a4),a6
	jsr	_LVOGT_RefreshWindow(a6)

	bsr.b	ProjectPrefswinRender

	moveq	#0,d0
.ProjectPrefswinDone:
	movem.l	(sp)+,d1-d4/a0-a3/a5/a6
	rts

.ProjectPrefsCError:
	moveq	#1,d0
	bra.b	.ProjectPrefswinDone

.ProjectPrefsWError:
	moveq	#4,d0
	bra.b	.ProjectPrefswinDone

.C249C8:
	movem.w	(sp)+,d2/d3
	moveq	#1,d0
	bra.b	.ProjectPrefswinDone

ProjectPrefswinRender:
	movem.l	d0-d5/a0-a2/a6,-(sp)

	move.l	(MainVisualInfo-DT,a4),NR+4
	move.l	(GadToolsBase-DT,a4),a6

	move.l	(PrefsAsmWinBase-DT,a4),a0
	movem.w	(wd_Width,a0),d2/d3	; width, height
	moveq	#0,d0
	move.b	(wd_BorderRight,a0),d0
	sub.w	d0,d2
	move.b	(wd_BorderLeft,a0),d0
	sub.w	d0,d2
	moveq	#0,d1
	move.b	(wd_BorderBottom,a0),d1
	sub.w	d1,d3
	move.b	(wd_BorderTop,a0),d1
	sub.w	d1,d3

	move.l	(wd_RPort,a0),a0
	lea	NR,a1		;taglist
	jsr	_LVODrawBevelBoxA(a6)

	movem.l	(sp)+,d0-d5/a0-a2/a6
	rts


CreatePrefsMsgport:	; must set ccr on exit (0=ok, ~0=fail)
	move.l	(4).w,a6
	jsr	(_LVOCreateMsgPort,a6)
	move.l	d0,(Prefs_msgport-DT,a4)
	beq.b	.fail
	move.l	(PrefsAsmWinBase-DT,a4),a0
	move.l	(wd_UserPort,a0),(L2F148-DT,a4)
	move.l	d0,(wd_UserPort,a0)
	move.l	#$00000344,d0
	move.l	(IntBase-DT,a4),a6
	jsr	(_LVOModifyIDCMP,a6)
	sub.l	a1,a1
	move.l	(PrefsAsmWinBase-DT,a4),a0
	move.l	(GadToolsBase-DT,a4),a6
	jsr	(_LVOGT_RefreshWindow,a6)
	moveq	#0,d0
	rts
.fail	moveq	#1,d0
	rts

RemovePrefsmsgPort:
	move.l	(Prefs_msgport-DT,a4),d0
	beq.b	.nomsgport
	move.l	d0,a0
	move.l	(4).w,a6
	jsr	(_LVODeleteMsgPort,a6)
	move.l	(PrefsAsmWinBase-DT,a4),a0
	move.l	(L2F148-DT,a4),(wd_UserPort,a0)
.nomsgport
	rts


;*********** OPEN SYNTAX COLOR PREFS WIN ************

Prefs_CopyGadget_A0:
	lea	(GadgetBuffer-DT,a4),a1
Prefs_CopyGadget_A0_A1:
	moveq	#gng_SIZEOF,d0
	mulu.w	d3,d0
	add.l	d0,a0
	moveq	#gng_SIZEOF/2-1,d0
.Copy	move.w	(a0)+,(a1)+
	dbf	d0,.Copy
	rts

OpenSyntColsWin:
	movem.l	d1-d4/a0-a3/a5/a6,-(sp)

	move.w	(Scr_NrPlanes-DT,a4),(SyntNrCols1-DT,a4)
	move.w	(Scr_NrPlanes-DT,a4),(SyntNrCols2-DT,a4)
	lea	(synt_gadspos-DT,a4),a0
	lea	(Synt_prefs_gadstr-DT,a4),a1
	moveq	#synt_gadcount-1,d7
	bsr.w	Prefs_CommonInit
	beq	.ProjectPrefsCError
	tst.b	(HaveKS3-DT,a4)
	bne.b	.KS3
	moveq	#TAG_DONE,d0
	move.l	d0,(Prefs_SyntFront\.Indicator-DT,a4)	; turn off ext. indicator
	move.l	d0,(Prefs_SyntBack\.Indicator-DT,a4)
.KS3
	movem.w	d2/d3,-(sp)
	moveq	#0,d3
	lea	(Prefs_SyntGadTags-DT,a4),a5
.C24860	lea	(Synt_prefs_gadstr-DT,a4),a0
	bsr.b	Prefs_CopyGadget_A0
	lea	(Pref_SyntGadgetTypes-DT,a4),a2
	bsr.w	Prefs_MkGadget_A2
	beq	.C249C8
	bsr.w	Prefs_LinkGadget
	cmp	#synt_gadcount,d3
	bmi.b	.C24860
	movem.w	(sp)+,d2/d3

	move.l	(Prefs_GList-DT,a4),(Prefs_wingadgets-DT,a4)
	move.l	(ScreenBase,pc),(ScreenBaseTemp1-DT,a4)
	move.w	(W1D00E-DT,a4),(Prefs_winleft+2-DT,a4)
	move.w	(W1D010-DT,a4),(Prefs_wintop+2-DT,a4)
	move.w	(Prefs_win_br2-DT,a4),(Prefs_winbreedt+2-DT,a4)
	move	(Prefs_win_hg2-DT,a4),d0
	add	d3,d0
	move.w	d0,(Prefs_winhoog+2-DT,a4)
	lea	(Prefs_newmenustr-DT,a4),a0
	sub.l	a1,a1
	jsr	(_LVOCreateMenusA,a6)
	move.l	d0,(PrefsMenuStrip-DT,a4)
	beq.b	.C24976
	move.l	d0,a0
	move.l	(MainVisualInfo-DT,a4),a1
	lea	(prefs_menutags-DT,a4),a2
	jsr	_LVOLayoutMenusA(a6)
.C24976
	lea	(AsmProSyntPrefs-DT,a4),a0
	move.l	a0,(Prefs_wintitle-DT,a4)
	sub.l	a0,a0
	lea	(Prefswin_taglist-DT,a4),a1
	move.l	(IntBase-DT,a4),a6
	jsr	(_LVOOpenWindowTagList,a6)
	move.l	d0,(PrefsAsmWinBase-DT,a4)
	beq.b	.ProjectPrefsWError

	move.l	d0,a0
	move.l	(wd_RPort,a0),(PrefsRastport-DT,a4)

	move.l	(PrefsMenuStrip-DT,a4),a1
	jsr	(_LVOSetMenuStrip,a6)
	move.l	(PrefsAsmWinBase-DT,a4),a0
	sub.l	a1,a1
	move.l	(GadToolsBase-DT,a4),a6
	jsr	_LVOGT_RefreshWindow(a6)

	bsr	ProjectPrefswinRender
	bsr.b	ShowPrevSource

	moveq	#0,d0
.ProjectPrefswinDone:
	movem.l	(sp)+,d1-d4/a0-a3/a5/a6
	rts

.ProjectPrefsCError:
	moveq	#1,d0
	bra.b	.ProjectPrefswinDone

.ProjectPrefsWError:
	moveq	#4,d0
	bra.b	.ProjectPrefswinDone

.C249C8:
	movem.w	(sp)+,d2/d3
	moveq	#1,d0
	bra.b	.ProjectPrefswinDone

NORMAALSRC	= 0
COMMENTAAR	= 4
LABELCOLOR	= 8
OPCODECOLR	= 12

ShowPrevSource:
	movem.w	(EFontSize_xy-DT,a4),d5/d6
	addq.w	#3,d6

	move.l	(IntBase-DT,a4),a6

;	lea	TheColors(pc),a4
	lea	TestSource(pc),a5
	lea	.TestISource(pc),a3

	moveq	#19-1,d7
.lopje:
	moveq	#0,d0
	move.b	(a5)+,d0
	move.b	(TheColors+0,pc,d0.w),(a3)	;front
	move.b	(TheColors+1,pc,d0.w),1(a3)	;back
;	move.b	(a5)+,2(a3)			;drawmode

	move.b	(a5)+,d0
	mulu.w	d5,d0		;x
	moveq	#0,d1
	move.b	(a5)+,d1
	mulu.w	d6,d1		;y
	add.w	(Scr_Title_sizeTxt-DT,a4),d1

	move.l	a5,12(a3)	;drawmode

	move.l	(PrefsRastport-DT,a4),a0
	lea	(a3),a1
	jsr	_LVOPrintIText(a6)
.next:
	tst.b	(a5)+
	bne.s	.next

	dbf	d7,.lopje

	rts


.TestISource:
	dc.b	1,0	;front/back pen
	dc.b	1	;drawmode
	dc.b	0	;nix
	dc.w	0,0	;left/top
	dc.l	0	;font
	dc.l	0	;text
	dc.l	0	;next

; colors frontpen,backpen,bold,italic

TheColors:
	dc.b	1,0,0,0		;normal source
	dc.b	1,0,0,0		;commentaar
	dc.b	1,0,0,0		;labels
	dc.b	1,3,0,0
	;block select
	dc.b	0,1,0,0		;normal source
	dc.b	3,1,0,0		;commentaar
	dc.b	2,1,0,0		;labels
	dc.b	3,1,0,0

TestSource:
	dc.b	COMMENTAAR,21,01,'******** START OF BINARY FILE **************',0
	dc.b	LABELCOLOR,21,02,'P61_motuuli',0
	dc.b	OPCODECOLR,29,03,'bsr',0
	dc.b	NORMAALSRC,40,03,'P61_Init',0
	dc.b	OPCODECOLR,29,04,'ifeq',0
	dc.b	NORMAALSRC,40,04,'CIA',0
	dc.b	OPCODECOLR,29,05,'bsr.w',0
	dc.b	NORMAALSRC,40,05,'P61_Music',0
;	dc.b	NORMAALSRC,29,09,'else',0
;	dc.b	NORMAALSRC,29,05,'rts',0
	dc.b	OPCODECOLR,29,06,'endc',0
	dc.b	OPCODECOLR,29,07,'bsr.w',0
	dc.b	NORMAALSRC,40,07,'P61_End',0
	dc.b	OPCODECOLR,29,08,'rts',0
	dc.b	COMMENTAAR,53,08,';no P61_SetRepeat',0
	dc.b	OPCODECOLR,29,09,'bra.w',0
	dc.b	NORMAALSRC,40,09,'P61_SetPosition',0
	dc.b	LABELCOLOR,21,10,'P61_Master',0
	dc.b	OPCODECOLR,37,10,'dc',0
	dc.b	NORMAALSRC,46,10,'64',0
	dc.b	COMMENTAAR,53,10,';Master volume (0-64)',0
;	dc.b	LABELCOLOR,21,11,'P61_Tempo',0
;	dc.b	OPCODECOLR,37,11,'dc',0
;	dc.b	NORMAALSRC,46,11,'1',0
;	dc.b	COMMENTAAR,53,11,';Use tempo?',0

;**************** EINDE SYNTCOLS WIN ****************

PR_begin:

;env prefs gadgets

Env_begin:
PR_ReqLib:		dc.w	$0100
PR_SaveMarks:		dc.w	$0100
PR_SourceExt:		dc.w	$0100
PR_UpdateAlways:	dc.w	$0000
PR_PrintDump:		dc.w	$0000
PR_WBFront:		dc.w	$0000
PR_RegsRes:		dc.w	$0100
PR_Safety:		dc.w	$0100
PR_CloseWB:		dc.w	$0000
PR_params:		dc.w	$0100
PR_OnlyAscii:		dc.w	$0100
PR_NoDisasm:		dc.w	$0100
PR_ShowSource:		dc.w	$0100
PR_Enable_Permit:	dc.w	$0100
PR_LibCalDec:		dc.w	$0100
PR_RealtimeDebug:	dc.w	$0000
PR_CtrlUp_Down:		dc.w	$0100
PR_Keepxy:		dc.w	$0100
PR_AutoIndent:		dc.w	$0100
PR_ExtReq:		dc.w	$0100
PR_Startup:		dc.w	$0100
PR_SyntaxColor:		dc.w	$0100
PR_CustomScroll:	dc.w	$0000
PR_WaitTOF:		dc.w	$0000
	IF SLIDER
PR_Slider:		dc.w	$0000
	ENDIF
PR_LineNrs:		dc.w	$0000
PR_AutoBackup:		dc.w	$0100
PR_AutoUpdate:		dc.w	$0000			
Env_end:

;asm prefs gadgets

Asm_begin:
PR_Rescue:		dc.w	$0100
PR_Level7:		dc.w	$0100
PR_NumLock:		dc.w	$0100
PR_AutoAlloc:		dc.w	$0100
PR_Debug:		dc.w	$0100
PR_Multiscroll:		DC.W	$0000
PR_ListFile:		dc.w	$0100
PR_Paging:		dc.w	$0100
PR_HaltPage:		dc.w	$0100
PR_AllErrors:		dc.w	$0100
PR_Progress:		dc.w	$0100
PR_ProgressLine:	dc.w	$0100
PR_DsClear:		dc.w	$0100
PR_Label:		dc.w	$0100
PR_Upper_LowerCase:	dc.w	$0100
PR_Comment:		dc.w	$0100
PR_Warning:		dc.w	$0100
PR_FPU_Present:		dc.w	$0100
PR_OddData:		dc.w	$0100
PR_MMU:			dc.w	$0100
Asm_end:

;overige prefs

;PR_Interlace_hmmm:	dc.w	$0100
;PR_OnePlane:		dc.w	$0100
PR_end:

**
* Default prefs settings..
**

Prefs_File_Stuff:
	dc.b	'+RL',10
	dc.b	'+SM',10
	dc.b	'+.S',10
	dc.b	'+AU',10
	dc.b	'-PD',10
	dc.b	'-WF',10
	dc.b	'+RR',10
	dc.b	'+SO',10
	dc.b	'-CW',10
	dc.b	'-PS',10
	dc.b	'-OA',10
	dc.b	'+DA',10
	dc.b	'+SS',10
	dc.b	'-EP',10
	dc.b	'+LD',10
	dc.b	'+RD',10
	dc.b	'+UD',10
	dc.b	'+KX',10
	dc.b	'+AI',10
	dc.b	'+XR',10
	dc.b	'+SW',10
	dc.b	'+SC',10
	dc.b	'-CS',10	;CustomScroll
	dc.b	'-WT',10	;WaitTOF
	IF SLIDER
	dc.b	'+SL',10	;Slider
	ENDIF
	dc.b	'-LN',10	;LineNrs
	dc.b	'+AB',10	;AutoBackup
	dc.b	'-AS',10	;Autoupdate		

	dc.b	'+RS',10
	dc.b	'+L7',10
	dc.b	'-NL',10
	dc.b	'+AA',10
	dc.b	'+DB',10
	DC.B	'-S8',10	; Multiscroll
	dc.b	'-LF',10
	dc.b	'+PG',10
	dc.b	'+HP',10
	dc.b	'-AE',10
	dc.b	'+PI',10
	dc.b	'-PL',10
	dc.b	'+DC',10
	dc.b	'-L:',10
	dc.b	'-UL',10
	dc.b	'-;C',10
	dc.b	'-FW',10
	dc.b	'+FP',10
	dc.b	'-OD',10
	dc.b	'+MP',10

	dc.b	'-IL',10
;	dc.b	'-1B',10

	dc.b	'!(.s|.asm|.i)',10
	dc.b	'*AsmPro:sources/',10
	dc.b	'|9AB|111|FFF|C06|',10
	dc.b	'[CPU2',10
	dc.b	'[MMU0',10
	dc.b	'^FFFFFFFF|00000100|00000280',10
	dc.b	'@F2000',10
	dc.b	0

cs_txt:	dc.b	"Please set the screen width to 640 first,",10
	dc.b	"this routine will NOT work without it.",0

wt_txt:	dc.b	"Only set this option if scrolling",10
	dc.b	"doesn't work right as it slows down",10
	dc.b	"editor speed.",0


;****************************************************
;**              MY DEBUG SUBROUTINES              **
;****************************************************

	IF	Debugstuff
	EVEN
test_num:
	movem.l	d0-a6,-(sp)
	jsr	druk_af_d0
	jsr	Druk_af_eol
	movem.l	(sp)+,d0-a6
	move	#$00F0,($00DFF180).l
	btst	#6,($00BFE001).l
	bne.w	test1
	rts

test_debug:
	movem.l	d0-a6,-(sp)

	tst.l	(ReqToolsbase-DT,a4)
	bne.b	.reqopen
	bsr.w	openreqtoolslib
.reqopen:
	tst.l	(ReqToolsbase-DT,a4)
	beq.b	.reqerror


	move.l	a0,-(sp)
	lea	.regsbase+4*16(pc),a0
	movem.l	d0-a7,-(a0)
	move.l	(sp)+,d0
	move.l	d0,.regsbase+4*8

	lea	regstxt+4(pc),a0
	lea	(.regsbase,pc),a1
	moveq	#16-1,d7
.lopje:
	move.l	(a1)+,d0
	bsr	decode
	addq.l	#5,a0
	dbf	d7,.lopje

	addq.l	#1,a0
	lea	(.regsbase+8*4,pc),a1
	moveq	#8-1,d7
.lopje2:
	move.l	(a1)+,a2
	bsr.b	decode2
	addq.l	#6,a0
	dbf	d7,.lopje2

	lea	(_Ok_Ok.MSG,pc),a2
	lea	(regstxt,pc),a1
	moveq		#1,d0
	jsr	(ShowReqtoolsRequester_HaveType-_Ok_Ok.MSG,a2)
.reqerror
	movem.l	(sp)+,d0-a6
	rts


.regsbase:
	dcb.l	16,0


decode2:
	moveq	#20-1,d6
.lopje
	move.b	(a2)+,d0
	cmp.b	#' ',d0		; $20
	blo.s	.nietleesbaar
	cmp.b	#'~',d0		; $7e
	bhi.s	.nietleesbaar
	move.b	d0,(a0)+
	bra.b	.verder
.nietleesbaar:
	move.b	#'.',(a0)+
.verder
	dbf	d6,.lopje
	rts

decode:
	swap	d0
	bsr.b	.een
	swap	d0
.een:
	move	d0,-(sp)
	lsr.w	#8,d0
	bsr.b	.twee
	move	(sp)+,d0
.twee:
	move.b	d0,-(sp)
	lsr.b	#4,d0
	bsr.b	.drie
	move.b	(sp)+,d0
.drie:
	and.b	#15,d0
	add.b	#'0',d0
	cmp.b	#'9',d0
	bls.s	.dec
	addq.b	#7,d0
.dec
	move.b	d0,(a0)+
	rts

regstxt:
	dc.b	"D0: xxxxxxxx D1: xxxxxxxx",10
	dc.b	"D2: xxxxxxxx D3: xxxxxxxx",10
	dc.b	"D4: xxxxxxxx D5: xxxxxxxx",10
	dc.b	"D6: xxxxxxxx D7: xxxxxxxx",10
	dc.b	"A0: xxxxxxxx A1: xxxxxxxx",10
	dc.b	"A2: xxxxxxxx A3: xxxxxxxx",10
	dc.b	"A4: xxxxxxxx A5: xxxxxxxx",10
	dc.b	"A6: xxxxxxxx sp: xxxxxxxx",10

	dc.b	"(A0):....................",10
	dc.b	"(A1):....................",10
	dc.b	"(A2):....................",10
	dc.b	"(A3):....................",10
	dc.b	"(A4):....................",10
	dc.b	"(A5):....................",10
	dc.b	"(A6):....................",10
	dc.b	"(sp):....................",10

	dc.b	0
	EVEN

test1:
	move	#$00F0,($00DFF180).l
	btst	#6,($00BFE001).l
	bne.b	test1
	rts

test2:
	move	#$000F,($00DFF180).l
	btst	#10,($00DFF016).l
	bne.b	test2
	rts

test3:
	move	#$0F0F,($00DFF180).l
	btst	#7,($00BFE001).l
	bne.b	test3
	rts

test4:
	move	#$0F00,($00DFF180).l
	btst	#6,($00BFE001).l
	bne.b	test4
	rts

	endif

	CNOP	0,4
IntuiStuff_END:		; section end

;;*******************************************************
;**               DISASSEMBLER SECTION                 **
;********************************************************

	Section	disassembler,code

Disasm_START:

;gedoe:	dc.l	$F6209000
;teste:	lea	gedoe,a5

DISLENGTH_A5:
	lea	(OpcodeDissolve-DT,a4),a0 ; DISSOLVE AREA

	move	(a5)+,d0
	moveq	#7,d1
	and	d0,d1
	add	d1,d1		; source reg
	move	d1,(a0)+	;  0 - 0000000000000xxx << 1

	lsr.w	#3-1,d0
	moveq	#7<<1,d1
	and	d0,d1		; source mode
	move	d1,(a0)+	;  2 - 0000000000xxx000 << 1

	lsr.w	#3,d0
	moveq	#7<<1,d1
	and	d0,d1		; dest mode
	move	d1,(a0)+	;  4 - 0000000xxx000000 << 1

	moveq	#3<<1,d1
	and	d0,d1		
	move	d1,(a0)+	;  6 - 00000000xx000000 << 1

	lsr.w	#2,d0
	moveq	#1<<1,d1
	and	d0,d1
	move	d1,(a0)+	;  8 - 0000000x00000000 << 1

	moveq	#15<<1,d1
	and	d0,d1
	move	d1,(a0)+	; 10 - 0000xxxx00000000 << 1

	lsr.w	#1,d0
	moveq	#7<<1,d1
	and	d0,d1
	move	d1,(a0)+	; 12 - 0000xxx000000000 << 1

	lsr.w	#3,d0
	moveq	#15<<1,d1
	and	d0,d1
	move	d1,(a0)+	; 14 - xxxx000000000000 << 1

	move	(a5),d0		; 2nd word:
	move	d0,(a0)+	; 16 - xxxxxxxxxxxxxxxx

	lsr.w	#8,d0
	and.w	#7<<1,d0
	move	d0,(a0)+	; 18 - 0000xxx000000000 << 1

	move	(a5),d0
	move	d0,d1
	rol.w	#3,d1
	and	#3<<1,d1
	move	d1,(a0)+	; 20 - xx00000000000000 << 1

	move	d0,d1
	lsr.w	#6,d1
	and	#7<<1,d1
	move	d1,(a0)+	; 22 - 0000001110000000 << 1

	move.b	d0,d1
	add.w	d1,d1
	move.w	d1,(a0)+	; 24 - 00000000xxxxxxxx << 1

	rol.w	#7,d0
	moveq	#7<<1,d1
	and.w	d0,d1
	move	d1,(a0)+	; 26 - 000xxx0000000000 << 1

	lsr.w	#4-1,d0
	and	#1<<1,d0
	move.w	d0,(a0)+	; 28 - 001000000000000 << 1
	move.b	(BIT_7_0+1-BIT_6_0,a0),d0
	move.w	d0,(a0)		; 30 - 000000000xxxxxxx << 1

	lea	(OpcodeDissolve-DT,a4),a0
	lea	(DisAsmblBigTable,pc),a1
.Traverse
	move	(a1)+,d0
	add	(a0,d0.w),a1
	add	(a1),a1
	tst.b	(a1)			; table (zero) or instr. name (non-zero)?
	beq.b	.Traverse

	cmp.l	#DC.DIS_MSG,a1
	beq.b	.UNKNOWN

	add	#11,a1			; skip instr. name
	moveq	#2,d1			; instr. length
	move.b	(a1)+,d2		; flags
	move.b	(a1)+,d0		; first operand
	beq.b	.NO_OPERANDS
	bsr.b	.CALC_OPERAND
	moveq	#0,d0
	move.b	(a1)+,d0		; second operand
	beq.b	.NO_OPERANDS
	bsr.b	.CALC_OPERAND
.NO_OPERANDS:
	tst	d1
	rts

.UNKNOWN:
	moveq	#0,d1
	rts

.CALC_OPERAND:
	bmi.b	.NEGATIVE
	move	(a0),d5			;source register, BIT_0_2
	move	(BIT_3_5,a0),d6		;source mode
	bra.b	.GO_PRINT

.NEGATIVE:
	move	(BIT_9_B,a0),d5		;dest reg
	move	(BIT_6_8,a0),d6		;dest mode
.GO_PRINT:
	and.w	#$f,d5
	lsr.w	#1,d5
	add.b	d0,d0
	and	#$00FF,d0
	add	(.JUMP_TABEL,pc,d0.w),d0
	jmp	(.JUMP_TABEL,pc,d0.w)

.JUMP_TABEL:
	dc.w	LEN_NONE-*
	dc.w	LEN_MODE_REG_W-*
	dc.w	LEN_MODE_REG_W-*
	dc.w	LEN_MODE_REG_L-*
	dc.w	LEN_NUM_B-*
	dc.w	LEN_NUM_W-*
	dc.w	LEN_NUM_L-*
	dc.w	LEN_DATA-*
	dc.w	LEN_ADDR-*
	dc.w	LEN_VALUE_W_ADDR-*
	dc.w	LEN_BRANCH_B-*
	dc.w	LEN_BRANCH_W-*
	dc.w	LEN_SR-*
	dc.w	LEN_CCR-*
	dc.w	LEN_USP-*
	dc.w	LEN_MINUS_ADDR-*
	dc.w	LEN_ADDR_PLUS-*
	dc.w	LEN_3BIT-*
	dc.w	LEN_MOVEQ-*
	dc.w	LEN_VECTOR-*
	dc.w	LEN_MOVEM-*
	dc.w	LEN_LINE-*
	dc.w	LEN_MODE_REG_MOVEM-*
	dc.w	LEN_DCW-*	;23

	dc.w	LEN_NUM_B-*	;24
	dc.w	LEN_NONE-*
	dc.w	LEN_NONE-*
	dc.w	LEN_Callm-*
	dc.w	LEN_CasMoves-*	;28 cas
	dc.w	LEN_NUM_L-*	;29 cas2
	dc.w	LEN_Chk2Cmp2-*	;30
	dc.w	LEN_LongDivMul-*	;31 long div
	dc.w	LEN_NUM_B-*
	dc.w	LEN_CasMoves-*	;33 moves
	dc.w	LEN_LongDivMul-*	;34 long mul
	dc.w	LEN_NUM_B-*	;35
	dc.w	LEN_NUM_B-*
	dc.w	C1FD38-*	;37 unused?
	dc.w	LEN_NormFloatOpp-*
	dc.w	LEN_NormFloatOpp-*
	dc.w	LEN_NormFloatEA-*	;40
	dc.w	LEN_FloatOpp-*
	dc.w	LEN_NUM_L-*
	dc.w	LEN_FloatOpp-*
	dc.w	LEN_NUM_L-*
	dc.w	LEN_NUM_3W-*	;45
	dc.w	LEN_NUM_B-*
	dc.w	LEN_NUM_L-*
	dc.w	LEN_FloatOpp-*	;48
	dc.w	LEN_FloatOpp-*
	dc.w	LEN_NUM_B-*	;50
	dc.w	LEN_FloatOpp-*
	dc.w	LEN_FloatOpp-*
	dc.w	LEN_FloatOpp-*
	dc.w	LEN_FloatOpp-*
	dc.w	LEN_FloatOpp-*	;55
	dc.w	LEN_NUM_B-*
	dc.w	LEN_FloatOpp-*
	dc.w	LEN_Fmovem-*
	dc.w	LEN_MOVE16-*
	dc.w	LEN_NONE-*	;60
	dc.w	LEN_NONE-*
	dc.w	LEN_NONE-*
	dc.w	LEN_MODE_REG_W-*
	dc.w	LEN_MODE_REG_W-*
	dc.w	LEN_MODE_REG_MOVEM-*	;65
	dc.w	LEN_MODE_REG_MOVEM-*
	dc.w	LEN_MODE_REG_MOVEM-*
	dc.w	LEN_MODE_REG_MOVEM-*
	dc.w	LEN_MODE_REG_MOVEM-*
	dc.w	LEN_MODE_REG_MOVEM-*	;70
	dc.w	LEN_MODE_REG_MOVEM-*
	dc.w	LEN_MODE_REG_MOVEM-*	;72
	dc.w	LEN_NUM_W-*	;73 lpstop
	dc.w	LEN_NONE-*	;74 plpa


LEN_MOVE16:
	addq.w	#2,a5
	addq.w	#2,d1
	btst	#3,(BIT_3_5+1,a0)
	bne	LEN_finish		;beq
	addq.w	#2,d1
	addq.w	#2,a5
	rts

LEN_Fmovem:
	addq.w	#2,d1
	addq.w	#2,a5
	move	(a5),(BIT_F_0,a0)
	cmp	#7<<1,(BIT_3_5,a0)
	bne.b	LEN_NormFloatEA
	cmp	#4<<1,(a0)		; BIT_0_2
	bne.b	LEN_NormFloatEA
	clr.w	(BIT_C_A,a0)
	bra.b	LEN_NormFloatEA

LEN_FloatOpp:
	addq.w	#2,d1
	addq.w	#2,a5
	move	(a5),(BIT_F_0,a0)
	bra.b	LEN_NormFloatEA

LEN_NormFloatOpp:
	addq.w	#2,d1
	addq.w	#2,a5
	move	(a5),(BIT_F_0,a0)
	btst	#1,(BIT_F_E+1,a0)
	beq.b	LEN_finish
LEN_NormFloatEA:
	tst	d6
	beq	LEN_NONE
	subq.w	#2,d6
	beq	LEN_NONE
	subq.w	#2,d6
	beq	LEN_NONE
	subq.w	#2,d6
	beq	LEN_NONE
	subq.w	#2,d6
	beq	LEN_NONE
	subq.w	#2,d6
	beq	LEN_NUM_B
	subq.w	#2,d6
	beq	LEN_VALUE_B_ADDR_XREG2

	tst	d5
	beq	LEN_NUM_B
	subq.w	#1,d5
	beq	LEN_NUM_L
	subq.w	#1,d5
	beq	LEN_NUM_B
	subq.w	#1,d5
	beq	LEN_VALUE_B_ADDR_XREG2
	subq.w	#1,d5
	beq.b	C1FBC4
	br	LEN_NONE

LEN_finish:
	rts

C1FBC4:
	move	(BIT_C_A,a0),d0
	lsr.w	#1,d0
	beq	LEN_NUM_L	;LONG
	subq.w	#1,d0
	beq	LEN_NUM_L	;SINGLE
	subq.w	#1,d0
	beq.b	C1FBF0		;EXT
	subq.w	#1,d0
	beq.b	C1FBF0		;PACKED
	subq.w	#1,d0
	beq	LEN_NUM_B	;WORD
	subq.w	#1,d0
	beq.b	C1FBEA		;DOUBLE

	bra	LEN_NUM_B	;WORD
;	addq.w	#2,a5		;BYTE?
;	addq.w	#2,d1
;	jsr	test_debug
;	rts

C1FBEA:
	addq.w	#8,a5
	addq.w	#8,d1
	rts

C1FBF0:
	add	#12,a5
	add	#12,d1
	rts

LEN_Callm:
	addq.w	#2,a5
	addq.w	#2,d1
	move	(a5),d0
	ror.w	#8,d0
	and	#7<<1,d0
	move	d0,(BIT_B_9,a0)
	move	(a5),(BIT_F_0,a0)
	cmp	#4<<1,d6
	ble.w	LEN_NONE
	cmp	#6<<1,d6
	blt.w	LEN_NUM_B
	br	C1FD4E

LEN_CasMoves:
	addq.w	#2,a5
	addq.w	#2,d1
	cmp	#4<<1,d6
	ble.w	LEN_NONE
	cmp	#6<<1,d6
	blt.w	LEN_NUM_B
LEN_Common1:
	move	(a5),d0
LEN_Common2:
	btst	#8,d0
	beq	LEN_NUM_B
	move	d0,(BIT_F_0,a0)
	ror.w	#8,d0
	and	#7<<1,d0
	move	d0,(BIT_B_9,a0)
	bra.b	C1FD4E

LEN_Chk2Cmp2:
	addq.w	#2,a5
	addq.w	#2,d1
	cmp	#4<<1,d6
	ble.w	LEN_NONE
	cmp	#6<<1,d6
	blt.w	LEN_NUM_B
	cmp	#7<<1,d6
	blt.w	LEN_NUM_L
	cmp	#2<<1,d5
	beq	LEN_NUM_B
	cmp	#3<<1,d5
	beq	LEN_VALUE_B_ADDR_XREG2
	bra.b	LEN_Common1

LEN_LongDivMul:
	addq.w	#2,a5
	addq.w	#2,d1
	cmp	#4<<1,d6
	ble.w	LEN_NONE
	cmp	#6<<1,d6
	blt.w	LEN_NUM_B
	move	(a5),d0
	cmp	#2<<1,d5
	beq	LEN_NUM_L
	bra.b	LEN_Common2

C1FD38:
	cmp	#4<<1,d6
	beq	LEN_NONE
	cmp	#2<<1,d6
	beq	LEN_NUM_B
	br	LEN_NUM_L

C1FD4E:
	addq.w	#2,d1
	addq.w	#2,a5
	move	(BIT_F_0,a0),d5
	btst	#8,d5
	beq	LEN_NONE
	lsr.w	#4,d5
	and	#3,d5
	cmp	#1,d5
	beq.b	C1FD7A
	cmp	#2,d5
	bne.b	C1FD76
	addq.w	#2,a5
	addq.w	#2,d1
	bra.b	C1FD7A

C1FD76:
	addq.w	#4,a5
	addq.w	#4,d1
C1FD7A:
	moveq	#3,d5
	and.w	(BIT_F_0,a0),d5
	beq.b	C1FD9A
	cmp	#1,d5
	beq.b	C1FD9A
	cmp	#2,d5
	bne.b	C1FD96
	addq.w	#2,a5
	addq.w	#2,d1
	bra.b	C1FD9A

C1FD96:
	addq.w	#4,a5
	addq.w	#4,d1
C1FD9A:
	rts

LEN_MODE_REG_W:
	tst	d6
	beq.b	LEN_NONE
	subq.w	#2,d6
	beq.b	LEN_NONE
	subq.w	#2,d6
	beq.b	LEN_NONE
	subq.w	#2,d6
	beq.b	LEN_NONE
	subq.w	#2,d6
	beq.b	LEN_NONE
	subq.w	#2,d6
	beq.b	LEN_NUM_B
	subq.w	#2,d6
	beq.b	LEN_VALUE_B_ADDR_XREG2
	tst	d5
	beq.b	LEN_NUM_B
	subq.w	#1,d5
	beq.b	LEN_NUM_L
	subq.w	#1,d5
	beq.b	LEN_NUM_B
	subq.w	#1,d5
	beq.b	LEN_VALUE_B_ADDR_XREG2
	subq.w	#1,d5
	beq.b	LEN_NUM_B
	bra.b	LEN_NONE

LEN_MODE_REG_MOVEM:
	addq.w	#2,d1
	addq.w	#2,a5
LEN_MODE_REG_L:
	tst	d6		;000
	beq.b	LEN_NONE
	subq.w	#2,d6		;001
	beq.b	LEN_NONE
	subq.w	#2,d6		;010
	beq.b	LEN_NONE
	subq.w	#2,d6		;011
	beq.b	LEN_NONE
	subq.w	#2,d6		;100
	beq.b	LEN_NONE
	subq.w	#2,d6		;101
	beq.b	LEN_NUM_B
	subq.w	#2,d6		;110
	beq.b	LEN_VALUE_B_ADDR_XREG2
;	subq.w	#2,d6		;111
;	beq.b	LEN_NUM_L

	tst	d5		;111 000
	beq.b	LEN_NUM_B
	subq.w	#1,d5		;111 001
	beq.b	LEN_NUM_L
	subq.w	#1,d5		;111 010
	beq.b	LEN_NUM_B
	subq.w	#1,d5		;111 011
	beq.b	LEN_VALUE_B_ADDR_XREG2
	subq.w	#1,d5		;111 100
	beq.b	LEN_NUM_L

LEN_MOVEM:
LEN_NONE:
LEN_DATA:
LEN_ADDR:
LEN_SR:
LEN_USP:
LEN_CCR:
LEN_MINUS_ADDR:
LEN_ADDR_PLUS:
LEN_3BIT:
LEN_MOVEQ:
LEN_VECTOR:
LEN_LINE:
LEN_BRACKET_ADDR:
LEN_DCW:
	rts

LEN_VALUE_B_ADDR_XREG2:
	cmp.w	#6<<1,(BIT_6_8,a0)
	beq.b	LEN_VALUE_B_ADDR_XREG
	btst	#8-8,(BIT_F_0,a0)
	bne.w	C1FD4E

LEN_VALUE_B_ADDR_XREG:
LEN_NUM_B:
LEN_NUM_W:
LEN_VALUE_W_ADDR:
LEN_BRANCH_W:
LEN_VALUE_W:
LEN_VALUE_W_PC:
LEN_VALUE_B_PC_XREG:
	addq.w	#2,d1
	addq.w	#2,a5
	rts

LEN_NUM_L:
	addq.w	#4,d1
	addq.w	#4,a5
	rts

LEN_NUM_3W:	; 3 words (ftrap, ptrap)
	addq.w	#6,d1
	addq.w	#6,a5
	rts

LEN_BRANCH_B:
	tst.b	(-1,a5)
	beq.b	LEN_NUM_B
	cmp	#PB_020,(ProcessorType-DT,a4)
	blt.b	.geen020plus
	cmp.b	#$FF,(-1,a5)	;32 bits displacement
	bne.b	.geen020plus
	addq.w	#4,a5	;was 6
	addq.w	#4,d1	;was 6
.geen020plus:
	rts

DISASSEMBLE_A5_PRINT:
	bsr.b	Disasm_OneLine
	clr.b	(DIS_PRINT_BUFFER\.HexEnd-DT,a4)
	cmp	#10,d1
	ble.b	.C1FE58
	moveq	#10,d1
	move.b	#$BB,(DIS_PRINT_BUFFER\.HexEnd-DT,a4)
.C1FE58	moveq	#10,d3
	sub	d1,d3
	lea	(DIS_PRINT_BUFFER\.Hex-DT,a4),a3
	move.l	a3,a0
.C1FE62	move	(a1)+,d0
	bsr	Zet_D0_Om2_inA3
	subq.w	#2,d1
	bne.b	.C1FE62
	add	d3,d3
.aanvullen:
	cmp.b	#$BB,(a3)
	beq.b	.klaar
	move.b	#' ',(a3)+
	dbra	d3,.aanvullen
.klaar:
	rts

Disasm_OneLine:	; DISASSEMBLE_A5
	lea	(DIS_PRINT_BUFFER\.Instr-DT,a4),a3
	lea	(OpcodeDissolve-DT,a4),a0
	move.l	a5,-(sp)

	move	(a5)+,d0	; 1st word:
	moveq	#7,d1
	and	d0,d1
	add	d1,d1
	move	d1,(a0)+	;  0 - 0000000000000xxx << 1

	lsr.w	#3-1,d0
	moveq	#7<<1,d1
	and	d0,d1
	move	d1,(a0)+	;  2 - 0000000000xxx000 << 1

	lsr.w	#3,d0
	moveq	#7<<1,d1
	and	d0,d1
	move	d1,(a0)+	;  4 - 0000000xxx000000 << 1

	moveq	#3<<1,d1
	and	d0,d1
	move	d1,(a0)+	;  6 - 00000000xx000000 << 1

	lsr.w	#2,d0
	moveq	#1<<1,d1
	and	d0,d1
	move	d1,(a0)+	;  8 - 0000000x00000000 << 1

	moveq	#15<<1,d1
	and	d0,d1
	move	d1,(a0)+	; 10 - 0000xxxx00000000 << 1

	lsr.w	#1,d0
	moveq	#7<<1,d1
	and	d0,d1
	move	d1,(a0)+	; 12 - 0000xxx000000000 << 1

	lsr.w	#3,d0
	moveq	#15<<1,d1
	and	d0,d1
	move	d1,(a0)+	; 14 - xxxx000000000000 << 1

	move	(a5),d0		; 2nd word:
	move	d0,(a0)+	; 16 - xxxxxxxxxxxxxxxx

	lsr.w	#8,d0
	and.w	#7<<1,d0
	move	d0,(a0)+	; 18 - 0000xxx000000000 << 1

	move	(a5),d0
	move	d0,d1
	rol.w	#3,d1
	and	#3<<1,d1
	move	d1,(a0)+	; 20 - xx00000000000000 << 1

	move	d0,d1
	lsr.w	#6,d1
	and	#7<<1,d1
	move	d1,(a0)+	; 22 - 0000001110000000 << 1

	move.b	d0,d1
	add.w	d1,d1
	move.w	d1,(a0)+	; 24 - 00000000xxxxxxxx << 1

	rol.w	#7,d0
	moveq	#7<<1,d1
	and.w	d0,d1
	move	d1,(a0)+	; 26 - 000xxx0000000000 << 1

	lsr.w	#4-1,d0
	and	#1<<1,d0
	move.w	d0,(a0)+	; 28 - 001000000000000 << 1
	move.b	(BIT_7_0+1-BIT_6_0,a0),d0
	move.w	d0,(a0)		; 30 - 000000000xxxxxxx << 1

	lea	(OpcodeDissolve-DT,a4),a0
	lea	(DisAsmblBigTable,pc),a1
.Traverse
	move	(a1)+,d0
	add	(a0,d0.w),a1
	add	(a1),a1
	tst.b	(a1)			; table (zero) or instr. name (non-zero)?
	beq.b	.Traverse

Disasm_InstrFound:
	moveq	#11-1,d1		; max. instr. name length (dbf)
	moveq	#'c',d2			; for Bcc/DBcc/Scc/TRAPcc
	moveq	#'z',d3			; for BRA.z/BSR.z/Bcc.z
	moveq	#'q',d4			; for FBq/FDBq/FSq/FTRAPq
	moveq	#'x',d5			; for PBx/PDBx/PSx/PTRAPx

;Support for dbf.l (encoded in the bottom bit of the offset)
	cmp.l	#'DBcc',(a1)
	seq	(Have_DBCC-DT,a4)

;Start disassembling
Disasm_CopyInstr:
	move.b	(a1)+,d0
	cmp.b	d3,d0
	bne.b	.C1FF50

	moveq	#'W',d0
	tst.b	(-1,a5)
	beq.b	.C1FF50
	moveq	#'B',d0
	cmp	#PB_020,(ProcessorType-DT,a4)
	blt.b	.C1FF50
	cmp.b	#$FF,(-1,a5)
	bne.b	.C1FF50
	moveq	#'L',d0
.C1FF50
	cmp.b	d2,d0
	bne.b	C1FF66

	lea	(CpuCCs.MSG,pc),a2
	add	(BIT_8_B,a0),a2
	move.b	(a2)+,(a3)+
	move.b	(a2)+,d0
	addq.w	#1,a1
	subq.w	#1,d1
C1FF66:
	cmp.b	d5,d0
	bne.b	C1FF72

	lea	(MmuCCs.MSG,pc),a2
	moveq	#15<<1,d6
;	jsr	test_debug
	bra.b	C1FF7E
C1FF72:
	cmp.b	d4,d0
	bne	C20008

	lea	(FpuCCs.MSG,pc),a2
	moveq	#63<<1,d6
;	jsr	test_debug
C1FF7E:
	cmp.b	#'B',(DIS_PRINT_BUFFER\.Instr+1-DT,a4)
	bne.b	.C1FF94
	move.l	#$f1ffffff,d0
	and.l	(-2,a5),d0
	cmp.l	#$f0800000,d0
	bne.b	.NotFnop
	lea	(FNOP.DIS_MSG,pc),a1
	subq.l	#2,a3		; move back 2 chars 'FB'
	bra.w	Disasm_InstrFound
.NotFnop
	move	(BIT_3_5,a0),d0
	lsl.w	#3,d0
	or	(a0),d0		; BIT_0_2
	and	d6,d0
	bra.b	C1FF9A

.C1FF94
	move	(BIT_7_0,a0),d0
	and	d6,d0
C1FF9A:
	cmp.b	#'.',(a1)
	bne.b	C1FFA2
	moveq	#'C',d2
C1FFA2:
	add	d0,d0
	add	d0,a2
	move.b	(a2)+,(a3)+
	move.b	(a2)+,d0
	cmp.b	#' ',d0
	beq.b	C1FFD4
	move.b	d0,(a3)+
	subq.w	#1,d1
	addq.w	#1,a1
	move.b	(a2)+,d0
	cmp.b	#' ',d0
	beq.b	C1FFD4
	move.b	d0,(a3)+
	subq.w	#1,d1
	addq.w	#1,a1
	move.b	(a2)+,d0
	cmp.b	#' ',d0
	beq.b	C1FFD4
	move.b	d0,(a3)+
	subq.w	#1,d1
	addq.w	#1,a1
C1FFD4:
	cmp.b	#'C',d2
	bne.b	C2000A
	moveq	#'c',d2
	subq.w	#2,d1
	addq.w	#2,a1
	move.b	#'.',(a3)+
	moveq	#'W',d0
	cmp.b	#'T',(DIS_PRINT_BUFFER\.Instr+1-DT,a4)
	bne.b	C1FFFE
	cmp	#3<<1,(a0)	; BIT_0_2
	bne.b	C20008
	bra.b	C20006
C1FFFE:
	btst	#1,(BIT_6_7+1,a0)
	beq.b	C20008
C20006:
	moveq	#'L',d0

C20008:
	move.b	d0,(a3)+
C2000A:
	dbra	d1,Disasm_CopyInstr

	move.b	#' ',(a3)+
	move.b	(a1)+,-(sp)			; flags
	move.b	(a1)+,d0			; first operand
	beq.b	Disasm_Finalize
	move.b	(a1),-(sp)			; second operand
	bsr	ParseWriteOperand		; first operand (dbf "d0",address)
	move.b	(sp)+,d0
	beq.b	Disasm_Finalize
	move.b	#',',(a3)+	
	bsr	ParseWriteOperand		; second operand (dbf d0,"address")
	tst.b	(Have_DBCC-DT,a4)
	beq.b	.done
	move.b	(-1,a3),d0			; dst address last hex char

	cmp.b	#'9',d0
	bls.b	.digit
	lsr.b	#1,d0				; ascii A/C/E are odd, B/D/F are even
	bcs.b	.done
	bra.b	.adjust
.digit	lsr.b	#1,d0
	bcc.b	.done

.adjust	subq.b	#1,(-1,a3)
	;Here we have dbcc.l
	cmp.b	#' ',-21(a3)
	bne.b	.four
	move.w	#'.L',-21(a3)		;correct Size (dbf.l)
	bra.b	.done
.four	IF	MC020
	move.w	#'.L',-20(a3)		;correct Size (dbcs.l)
	ELSE
	move.b	#'.',-20(a3)		; this one is at odd address
	move.b	#'L',-19(a3)
	ENDIF
.done

Disasm_Finalize:
	clr.b	(a3)
	btst	#SB2_INSERTINSOURCE,(SomeBits2-DT,a4)
	bne.b	.DontClip
	tst.b	(DIS_PRINT_BUFFER\.End-DT,a4)
	beq.b	.DontClip
	move.b	#$BB,(DIS_PRINT_BUFFER\.InstrEnd-DT,a4)
	clr.b	(DIS_PRINT_BUFFER\.End-DT,a4)
.DontClip
	lea	(DIS_PRINT_BUFFER\.Instr-DT,a4),a0
	move.l	a5,d1
	move.b	(sp)+,d2	; flags
Disasm_Exit:
	move.l	(sp)+,a1
	sub.l	a1,d1		; return a1 = instr. address, d1 = instr. length
	rts

CpuCCs.MSG:
	dc.b	'T F HILSCCCSNEEQVCVSPLMIGELTGTLE'
FpuCCs.MSG:
	dc.b	'F   EQ  OGT OGE OLT OLE OGL OR  UN  UEQ UGT UGE ULT '
	dc.b	'ULE NE  T   SF  SEQ GT  GE  LT  LE  GL  GLE NGLENGL '
	dc.b	'NLE NLT NGE NGT SNE ST  '
MmuCCs.MSG:
	dc.b	'BS  BC  LS  LC  SS  SC  AS  AC  WS  WC  IS  IC  GS  '
	dc.b	'GC  CS  CC  '

ParseWriteOperand:
	movem.w	(a0),d5/d6	; BIT_0_2/BIT_3_5
	tst.b	d0
	bpl.b	.C20156
	move	(BIT_9_B,a0),d5
	move	(BIT_6_8,a0),d6
.C20156	lsr.w	#1,d5
	add.b	d0,d0
	and	#$00FF,d0
	add	(DisJumpTab,pc,d0.w),d0
	jmp	(DisJumpTab,pc,d0.w)

DisJumpTab:
	dc.w	DisNoOp-*	;0000000 0
	dc.w	C21342-*	;0000001
	dc.w	C21390-*	;0000010
	dc.w	C213DC-*	;0000011
	dc.w	DisValueB_Imm-*	;0000100
	dc.w	C217E4-*	;0000101
	dc.w	C2173E-*	;0000110
	dc.w	DisDataReg-*	;0000111		dx
	dc.w	DisAdresReg-*	;0001000		ax
	dc.w	DisValueWAdrReg-*;0001001	d(ax)
	dc.w	C21826-*	;0001010 10
	dc.w	C2184A-*	;0001011
	dc.w	C21800-*	;0001100
	dc.w	C2180A-*	;0001101
	dc.w	C21818-*	;0001110
	dc.w	DisMinAdrInd-*	;0001111
	dc.w	DisAdrIndPlus-*	;0010000 16
	dc.w	C21868-*	;0010001
	dc.w	DisMoveq-*	;0010010
	dc.w	C2187A-*	;0010011
	dc.w	DisMovem-*	;0010100
	dc.w	DisLineAF-*	;0010101
	dc.w	C2138E-*	;0010110
	dc.w	DisDcw-*	;0010111
	dc.w	DisBFieldEA-*	;0011000 24
	dc.w	DisBFieldDx-*	;0011001 25
	dc.w	DisBkpt-*	;0011010
	dc.w	DisCallm-*	;0011011
	dc.w	DisCas-*	;0011100
	dc.w	DisCas2-*	;0011101
	dc.w	DisCmp2Chk2-*	;0011110
	dc.w	DisLongDiv-*	;0011111
	dc.w	DisMovec-*	;0100000 32
	dc.w	DisMoves-*	;0100111
	dc.w	DisLongMul-*	;0101000
	dc.w	C20D6E-*	;0101001
	dc.w	C20D56-*	;0101010
	dc.w	C20D06-*	;0101011
	dc.w	C20C74-*	;0101110
	dc.w	C20C52-*	;0110001
	dc.w	DisFsaveFrestore-*	;0110000 40
	dc.w	C20BFA-*	;0110011
	dc.w	DisFbcc-*	;0110010
	dc.w	C20BF6-*	;0110101
	dc.w	C20BE4-*	;0110100
	dc.w	C20BD2-*	;0110001
	dc.w	C20BCE-*	;0110110
	dc.w	C20BD8-*	;0111001
	dc.w	C20B7A-*	;0110000 48
	dc.w	C20B24-*	;0111011
	dc.w	C20B24-*	;0111010 50
	dc.w	C20AF8-*	;0111111
	dc.w	C20AD6-*	;0000000
	dc.w	DisFloatMovekFacDestD-*	;0000001
	dc.w	C20A78-*	;0000010
	dc.w	C20A1E-*	;0000011
	dc.w	C207D2-*	;0000100
	dc.w	DisFmovem-*	;0000101
	dc.w	DisFmovemCR-*	;0000110
	dc.w	DisMove16-*	;0000111
	dc.w	C20504-*	;0001000 60
	dc.w	C20508-*	;1000001
	dc.w	C2050A-*	;1000000
	dc.w	C2047A-*	;1000011
	dc.w	C2043E-*	;64
	dc.w	C203E6-*	;
	dc.w	C203E2-*	;
	dc.w	C20360-*	;
	dc.w	DisPmovew-*	;
	dc.w	DisPmovel-*	;
	dc.w	DisPmoveb-*	;
	dc.w	DisPmoveq-*	;
	dc.w	DisCinvCpush-*	;72
	dc.w	DisLpstop-*	;73
	dc.w	DisPlpa-*	;74

DisNoOp:
	rts

; This is ugly, but I don't want to make a disasm table with 127 empty entries.
; Since lpstop opcode has all 32 bits fixed, we simply check that and bail to
; LINE-F if the opcode doesn't match.
DisLpstop:
	cmp.l	#$f80001c0,(-2,a5)
	bne.b	.NotLpstop
	addq.l	#2,a5
	bra	C217E4
.NotLpstop
	lea	(LINE.DIS_MSG,pc),a1

DisChangedMyMind:
	lea	(-11-1,a3),a3	; instr. name + space
	addq.l	#4+2+2,sp	; return addr. + 2nd operand + flags
	bra.w	Disasm_InstrFound

DisCinvCpush:
	move.w	(BIT_6_7,a0),d0
	lsr.w	#1,d0
	move.b	(DisCacheTypes,pc,d0.w),(a3)+
	move.b	#'C',(a3)+
	moveq	#7,d0
	and.w	(BIT_3_5,a0),d0
	subq.w	#4,d0
	bgt.b	DisNoOp
	move.b	#',',(a3)+

DisPlpa:
	move	(a0),d5		; BIT_0_2
	lsr.w	#1,d5
	br	DisAdrIndirect

DisCacheTypes:	DC.B	'N','D','I','B'

DisPmoveq:
	addq.w	#2,a5
	btst	#3,(BIT_9_7+1,a0)
	bne.b	C2026E
	bsr	C213DC
	move.b	#',',(a3)+
C20256:
	move	(BIT_C_A,a0),d0
	cmp	#1<<1,d0
	beq	C21014
	cmp	#2<<1,d0
	beq	DisSRP
	br	C2101A

C2026E:
	pea	(C20274,pc)
	bra.b	C20256

C20274:
	move.b	#',',(a3)+
	br	C213DC

DisPmoveb:
	addq.w	#2,a5
	btst	#3,(BIT_9_7+1,a0)
	bne.b	C202A6
	bsr	C213DC
	move.b	#',',(a3)+
C2028E:
	move	(BIT_C_A,a0),d0
	cmp	#4<<1,d0
	beq	C20FA4
	cmp	#5<<1,d0
	beq	C20FAA
	br	C20FB8

C202A6:
	pea	(C202AC,pc)
	bra.b	C2028E

C202AC:
	move.b	#',',(a3)+
	br	C213DC

DisPmovel:
	addq.w	#2,a5
	btst	#3,(BIT_9_7+1,a0)
	bne.b	C202E4
	bsr	C213DC
	move.b	#',',(a3)+
C202C6:
	move	(BIT_C_A,a0),d0
	bne.b	C202D8
	move.b	#'T',(a3)+
	move.b	#'C',(a3)+
	rts

C202D8:
	cmp.w	#3<<1,d0
	beq	C20F8A
	br	C20F78

C202E4:
	bsr.b	C202C6
	move.b	#',',(a3)+
	br	C213DC

DisPmovew:
	addq.w	#2,a5
	btst	#3,(BIT_9_7+1,a0)
	bne.b	C20328
	bsr	C213DC
	move.b	#',',(a3)+
	move	(BIT_C_A,a0),d0
	beq.b	C2031A
DisPmovew2:
	cmp	#4<<1,d0
	beq	C20FC6
	cmp	#5<<1,d0
	beq	C20FD4
	br	C20FEE

C2031A:
	tst.b	(PR_MMU).l
	beq	DisMMUSR
	br	C20FF8

C20328:
	move	(BIT_C_A,a0),d0
	beq.b	C20346
	pea	(C20358,pc)
	bra.b	DisPmovew2

C20346:
	tst.b	(PR_MMU).l
	beq.b	C20354
	bsr	C20FF8
	bra.b	C20358

C20354:
	bsr	DisMMUSR
C20358:
	move.b	#',',(a3)+
	br	C213DC

C20360:
	addq.w	#2,a5
	moveq	#31<<1,d0
	and.w	(BIT_6_0,a0),d0
	lsr.w	#1,d0
	bne.b	C20376
	bsr	C2105C
	bra.b	C2039E

C20376:
	cmp	#1,d0
	bne.b	C20382
	bsr	C21062
	bra.b	C2039E

C20382:
	cmp	#15,d0
	bgt.b	C2039A
	moveq	#7,d5
	and.w	d0,d5
	bsr	DisDataReg
	move	(a0),d5			; BIT_0_2
	lsr.w	#1,d5
	bra.b	C2039E

C2039A:
	bsr	Disasm_ImmedBin3bit
C2039E:
	move.b	#',',(a3)+
	bsr	C213DC
	tst	(BIT_C_A,a0)
	beq.b	C203D8
C203AC:
	move.b	#',',(a3)+
	move.b	#'#',(a3)+
	move	(BIT_C_A,a0),d0
	lsr.w	#1,d0
	bsr	Zet_D0_Om3_inA3
	move	(BIT_7_0,a0),d5
	lsr.w	#6,d5
	btst	#2,(BIT_9_7+1,a0)
	beq.b	C203D6
	move.b	#',',(a3)+
	br	DisAdresReg

C203D8:
	btst	#2,(BIT_9_7+1,a0)
	bne.b	C203AC
C203D6:
	rts

C203E2:
	addq.w	#2,a5
	rts

C203E6:
	addq.w	#2,a5
	pea	(C213DC,pc)
	move	(BIT_6_0,a0),d0
	lsr.w	#1,d0
	bne.b	C20400
	bsr	C2105C
	move.b	#',',(a3)+
	rts

C20400:
	subq.w	#1,d0
	bne.b	C2040E
	bsr	C21062
	move.b	#',',(a3)+
	rts

C2040E:
	btst	#4,d0
	bne.b	C2042E
	moveq	#7<<1,d5
	and.w	(BIT_6_0,a0),d5
	lsr.w	#1,d5
	bsr	DisDataReg
	move	(a0),d5		; BIT_0_2
	lsr.w	#1,d5
	move.b	#',',(a3)+
	rts

C2042E:
	move	(BIT_6_0,a0),d0
	lsr.w	#1,d0
	bsr	Disasm_ImmedBin4bit
	move.b	#',',(a3)+
	rts

C2043E:
	addq.w	#2,a5
	pea	(C213DC,pc)
	move	(BIT_C_A,a0),d0
	btst	#1,d0
	beq.b	C20468
	moveq	#7<<1,d5
	and.w	(BIT_6_0,a0),d5
	lsr.w	#1,d5
	bsr	DisAdresReg
	move.b	#',',(a3)+
	move	(a0),d5		; BIT_0_2
	lsr.w	#1,d5
	rts

C20468:
	move.b	#'V',(a3)+
	move.b	#'A',(a3)+
	move.b	#'L',(a3)+
	move.b	#',',(a3)+
	rts

C2047A:
	addq.w	#2,a5
	move	(BIT_7_0,a0),d0
	lsr.w	#1,d0
	moveq	#31,d1
	and.w	d0,d1
	beq.b	C204A6
	subq.w	#1,d1
	beq.b	C204AC
	cmp	#15,d1
	bgt.b	C204A2
	moveq	#7,d5
	and.w	d0,d5
	bsr	DisDataReg
	bra.b	C204B0

C204A2:
	bsr.b	Disasm_ImmedBin3bit
	bra.b	C204B0

C204A6:
	bsr	C2105C
	bra.b	C204B0

C204AC:
	bsr	C21062
C204B0:
	move.b	#',',(a3)+
	move	(BIT_7_0,a0),d0
	lsr.w	#6,d0
	bsr.b	Disasm_ImmedBin3bit
	move	(BIT_C_A,a0),d0
	cmp	#6<<1,d0
	blt.b	C20502
	move.b	#',',(a3)+
	move	(a0),d5		; BIT_0_2
	lsr.w	#1,d5
	br	C213DC

Disasm_ImmedBin4bit:
	moveq	#4,d7
	bra.b	C204E6

Disasm_ImmedBin3bit:
	moveq	#3,d7
C204E6:
	move.b	#'#',(a3)+
	move.b	#'%',(a3)+
	ror.l	d7,d0
	clr.w	d0
	subq.w	#1,d7
.C204EE
	rol.l	#1,d0
	moveq	#1,d2
	and.b	d0,d2
	add.b	#'0',d2
	move.b	d2,(a3)+
	dbra	d7,.C204EE
C20502:
C20508:
	rts
C20504:
C2050A:
	br	DisAdrIndirect

DisMove16:
	move	(BIT_3_5,a0),d0
	lsr.w	#1,d0
	beq.b	.AxPost_Long
	subq.w	#1,d0
	beq.b	.Long_AxPost
	subq.w	#1,d0
	beq.b	.Ax_Long
	subq.w	#1,d0
	beq.b	.Long_Ax
	addq.w	#2,a5
	move	(a0),d5		; BIT_0_2
	lsr.w	#1,d5
	bsr	DisAdrIndPlus
	move.b	#',',(a3)+
	move	(BIT_F_0,a0),d5
	rol.w	#4,d5
	and	#7,d5
	br	DisAdrIndPlus

.Long_Ax:
	bsr	DisValueL
	move.b	#',',(a3)+
	br	DisAdrIndirect

.Ax_Long:
	bsr	DisAdrIndirect
	move.b	#',',(a3)+
	br	DisValueL

.Long_AxPost:
	bsr	DisValueL
	move.b	#',',(a3)+
	br	DisAdrIndPlus

.AxPost_Long:
	bsr	DisAdrIndPlus
	move.b	#',',(a3)+
	br	DisValueL

DisFmovemCR:
	addq.w	#2,a5
	btst	#1,(BIT_D+1,a0)
	beq.b	.C20586
	bsr.b	.C2059C
	move.b	#',',(a3)+
	br	DisEA

.C20586	move	(BIT_C_A,a0),-(sp)
	clr.w	(BIT_C_A,a0)
	bsr	DisEA
	move	(sp)+,(BIT_C_A,a0)
	move.b	#',',(a3)+
.C2059C	move	(BIT_C_A,a0),d1
	moveq	#0,d2
	lsl.b	#5,d1
	bcc.b	.C205BA
	moveq	#'C',d0
	bsr.b	.PrintReg
.C205BA	add.b	d1,d1
	bcc.b	.C205DA
	moveq	#'S',d0
	bsr.b	.PrintReg
.C205DA	add.b	d1,d1
	bcc.b	.AllDone
	move.w	#'AI',d0

.PrintReg
	tst.b	d2
	beq.b	.FirstReg
	move.b	d2,(a3)+
.FirstReg
	move.b	#'F',(a3)+
	move.b	#'P',(a3)+
	move.b	d0,(a3)+
	lsr.w	#8,d0
	beq.b	.OneChar
	move.b	d0,(a3)+
.OneChar
	move.b	#'R',(a3)+
	moveq	#'/',d2
.AllDone
	rts

DisFmovem:
	addq.w	#2,a5
	btst	#1,(BIT_D+1,a0)
	beq.b	C20624
	move	(BIT_C_A,a0),d0
	lsr.w	#2,d0
	beq	C2071A
	subq.w	#1,d0
	beq.b	C206AA
	subq.w	#1,d0
	beq	C206C8
	br	C206FC

C20624:
	move	(BIT_C_A,a0),d0
	lsr.w	#2,d0
	beq.b	C20690
	subq.w	#1,d0
	beq.b	C20674
	subq.w	#1,d0
	beq.b	C20642
	bsr	DisEA
	move.b	#',',(a3)+
	br	DisDataReg

C20642:
	move	(a0),d5		; BIT_0_2
	lsr.w	#1,d5
	bsr	DisEA
	move.b	#',',(a3)+
	move	(BIT_F_0,a0),d5
	moveq	#0,d1
	moveq	#8-1,d2
.C2065C	lsr.w	#1,d5		; bit reverse
	addx.w	d1,d1
	dbra	d2,.C2065C
	bra.b	Disasm_FpuRegList

C20674:
	move	(a0),d5		; BIT_0_2
	lsr.w	#1,d5
	bsr	DisMinAdrInd
	move.b	#',',(a3)+
	moveq	#7<<3,d5
	and.w	(BIT_F_0,a0),d5
	lsr.w	#3,d5
	br	DisDataReg

C20690:
	move	(a0),d5		; BIT_0_2
	lsr.w	#1,d5
	bsr	DisMinAdrInd
	move.b	#',',(a3)+
	moveq	#0,d1
	move.b	(BIT_F_0+1,a0),d1
	bra.b	Disasm_FpuRegList

C206AA:
	pea	(DisEA,pc)
DisFmovem_Finish2:
	moveq	#7<<3,d5
	and.w	(BIT_F_0,a0),d5
	lsr.w	#3,d5
	bsr	DisDataReg
DisFmovem_Finish:
	move.b	#',',(a3)+
	move	(a0),d5		; BIT_0_2
	lsr.w	#1,d5
	rts

C206C8:
	pea	(DisEA,pc)
	move	(BIT_F_0,a0),d5
	moveq	#0,d1
	moveq	#8-1,d2
.C206D8	lsr.w	#1,d5		; bit reverse
	addx.w	d1,d1
	dbra	d2,.C206D8
	bsr.b	Disasm_FpuRegList
	bra.b	DisFmovem_Finish

C206FC:
	pea	(DisMinAdrInd,pc)
	bra.b	DisFmovem_Finish2

C2071A:
	pea	(DisMinAdrInd,pc)
	moveq	#0,d1
	move.b	(BIT_F_0+1,a0),d1
	bsr.b	Disasm_FpuRegList
	bra.b	DisFmovem_Finish

Disasm_FpuRegList:
	move	#$FFFF,(W207D0-DT,a4)
	moveq	#0,d2
	moveq	#8-1,d5
C20742:
	btst	#0,d1
	beq.b	C2075A
	cmp	#$FFFF,(W207D0-DT,a4)
	beq.b	C207A8
	bgt.b	C20772
	move.b	#'/',(a3)+
	bra.b	C207A8

C2075A:
	cmp	#$FFFF,(W207D0-DT,a4)
	ble.b	C207C6
	move.b	#'/',(a3)+
	move	#$FFFF,(W207D0-DT,a4)
	bra.b	C207C6

C20772:
	btst	#1,d1
	bne.b	C207C6
	subq.w	#1,d2
	cmp	(W207D0-DT,a4),d2
	beq.b	C20788
	move.b	#'-',(a3)+
	bra.b	C2078C

C20788:
	move.b	#'/',(a3)+
C2078C:
	addq.w	#1,d2
	bsr.b	Disasm_FpuReg
	move	#$FFFE,(W207D0-DT,a4)
	bra.b	C207C6

C207A8:
	bsr.b	Disasm_FpuReg
	cmp	(W207D0-DT,a4),d2
	beq.b	C207C6
	move	d2,(W207D0-DT,a4)
C207C6:
	addq.w	#1,d2
	lsr.w	#1,d1
	dbeq	d5,C20742
	rts

Disasm_FpuReg:
	move.b	#'F',(a3)+
	move.b	#'P',(a3)+
	moveq	#'0',d0
	add.b	d2,d0
	move.b	d0,(a3)+
	rts

C207D2:
	addq.w	#2,a5
	moveq	#$7f,d5
	and.w	(BIT_F_0,a0),d5
	move.b	#'#',(a3)+
	move.b	#'$',(a3)+
	move.b	d5,d0
	bsr	Zet_D0_Om3_inA3
	move.b	#',',(a3)+
	move.w	(BIT_9_7,a0),d2
	lsr.w	#1,d2
	bsr.b	Disasm_FpuReg
	moveq	#9,d0		; tab
	btst	#0,(PR_PrintDump)
	bne.b	.HavePrinter
	moveq	#' ',d0
.HavePrinter
	move.b	d0,(a3)+
	move.b	#';',(a3)+
	move.b	(.FpuConstants,pc,d5.w),d0
	lea	(.FpuConstNames,pc,d0.w),a1
.C20816	move.b	(a1)+,(a3)+
	bpl.b	.C20816
	not.b	(-1,a3)
	rts

.FpuConstants
	DC.B	.Pi-.FpuConstNames	; 00
	DCB.B	10,.None-.FpuConstNames	; 01-0a
	DC.B	.Log102-.FpuConstNames	; 0b
	DC.B	.E-.FpuConstNames	; 0c
	DC.B	.Log2E-.FpuConstNames	; 0d
	DC.B	.Log10E-.FpuConstNames	; 0e
	DC.B	.Zero-.FpuConstNames	; 0f
	DCB.B	32,.None-.FpuConstNames	; 10-2f
	DC.B	.LogN2-.FpuConstNames	; 30
	DC.B	.LogN10-.FpuConstNames	; 31
	DC.B	.Ten0-.FpuConstNames	; 32
	DC.B	.Ten1-.FpuConstNames	; 33
	DC.B	.Ten2-.FpuConstNames	; 34
	DC.B	.Ten3-.FpuConstNames	; 35
	DC.B	.Ten4-.FpuConstNames	; 36
	DC.B	.Ten5-.FpuConstNames	; 37
	DC.B	.Ten6-.FpuConstNames	; 38
	DC.B	.Ten7-.FpuConstNames	; 39
	DC.B	.Ten8-.FpuConstNames	; 3a
	DC.B	.Ten9-.FpuConstNames	; 3b
	DC.B	.Ten10-.FpuConstNames	; 3c
	DC.B	.Ten11-.FpuConstNames	; 3d
	DC.B	.Ten12-.FpuConstNames	; 3e
	DC.B	.Ten13-.FpuConstNames	; 3f

.FpuConstNames
.None	DC.B	'??'~$ff
.Pi	DC.B	'pi'~$ff
.Log102	DC.B	'log10(2)'~$ff
.E	DC.B	'e'~$ff
.Log2E	DC.B	'log2(e)'~$ff
.Log10E	DC.B	'log10(e)'~$ff
.Zero	DC.B	'0.0'~$ff
.LogN2	DC.B	'logn(2)'~$ff
.LogN10	DC.B	'logn(10)'~$ff
.Ten0	DC.B	'10^0'~$ff
.Ten1	DC.B	'10^1'~$ff
.Ten2	DC.B	'10^2'~$ff
.Ten3	DC.B	'10^4'~$ff
.Ten4	DC.B	'10^8'~$ff
.Ten5	DC.B	'10^16'~$ff
.Ten6	DC.B	'10^32'~$ff
.Ten7	DC.B	'10^64'~$ff
.Ten8	DC.B	'10^128'~$ff
.Ten9	DC.B	'10^256'~$ff
.Ten10	DC.B	'10^512'~$ff
.Ten11	DC.B	'10^1024'~$ff
.Ten12	DC.B	'10^2048'~$ff
.Ten13	DC.B	'10^4096'~$ff
	EVEN

C20A1E:
	addq.w	#2,a5
	move	(BIT_C_A,a0),-(sp)
	btst	#1,(BIT_D+1,a0)
	beq.b	C20A38
	addq.w	#2,sp
	bsr.b	C20A48
	move.b	#',',(a3)+
	br	C20B82

C20A38:
	bsr	C20B82
	move.b	#',',(a3)+
	addq.w	#2,sp
	clr.w	(BIT_C_A,a0)
C20A48:
	move.b	#'F',(a3)+
	move.b	#'P',(a3)+
	move	(BIT_C_A,a0),d0
	lsr.w	#1,d0
	subq.w	#1,d0
	beq.b	C20A6A
	subq.w	#1,d0
	beq.b	C20A64
	move.b	#'C',(a3)+
	bra.b	C20A72
C20A64:
	move.b	#'S',(a3)+
	bra.b	C20A72

C20A6A:
	move.b	#'I',(a3)+
	move.b	#'A',(a3)+
C20A72:
	move.b	#'R',(a3)+
	rts

C20A78:
	addq.w	#2,a5
	bsr	C20CF0
	move.b	#',',(a3)+
	bsr	C20B82
	move.b	#'{',(a3)+
	moveq	#7<<4,d5
	and.w	(BIT_F_0,a0),d5
	lsr.w	#4,d5
	bsr	DisDataReg
	move.b	#'}',(a3)+
	rts

DisFloatMovekFacDestD:
	addq.w	#2,a5
	moveq	#-1,d1
	bsr	C20CF0
	move.b	#',',(a3)+

DisFloatMoveHandleKFactor:
	bsr	C20B82
	moveq	#$7f,d0
	and.w	(BIT_F_0,a0),d0
	beq.b	.C20AD4
	move.b	#'{',(a3)+
	move.b	#'#',(a3)+
	add.b	d0,d0			; 7-bit signed
	bpl.b	.Pos
	move.b	#'-',(a3)+
	neg.b	d0
.Pos	lsr.b	#1,d0
	move.b	#'$',(a3)+
	bsr	Zet_D0_Om3_inA3
	move.b	#'}',(a3)+
	moveq	#-1,d1
.C20AD4	rts

C20AD6:		; k-factor as dreg
	addq.w	#2,a5
	bsr	C20B82
	move.b	#'{',(a3)+
	moveq	#7<<4,d5
	and.w	(BIT_F_0,a0),d5
	lsr.w	#4,d5
	bsr	DisDataReg
	move.b	#'}',(a3)+
	moveq	#-1,d1
	br	C20CEC

C20AF8:		; k-factor as 7-bit signed
	addq.w	#2,a5
	moveq	#0,d1
	bsr.b	DisFloatMoveHandleKFactor
	br	C20CEC

C20B24:
	addq.w	#2,a5
	bsr	C20CF0
	moveq	#',',d0
	move.b	d0,(a3)+

	tst	d6
	beq	DisDataReg
	subq.w	#2,d6
	beq	DisAdresReg
	subq.w	#2,d6
	beq	DisAdrIndirect
	subq.w	#2,d6
	beq	DisAdrIndPlus
	subq.w	#2,d6
	beq	DisMinAdrInd
	subq.w	#2,d6
	beq	DisValueWAdrReg
	subq.w	#2,d6
	beq	DisValueBAdrReg_XReg
	tst	d5
	beq	DisValueW
	subq.w	#1,d5
	beq	DisValueL
	subq.w	#1,d5
	beq	DisValueW_PC
	subq.w	#1,d5
	beq	DisValueB_PC_XReg
	subq.w	#1,d5
	beq	DisNumberW
	br	DisNoOp

C20B7A:
	addq.w	#2,a5
	pea	(C20CEC,pc)
C20B82:
	tst	d6
	beq	DisDataReg
	subq.w	#2,d6
	beq	DisAdresReg
	subq.w	#2,d6
	beq	DisAdrIndirect
	subq.w	#2,d6
	beq	DisAdrIndPlus
	subq.w	#2,d6
	beq	DisMinAdrInd
	subq.w	#2,d6
	beq	DisValueWAdrReg
	subq.w	#2,d6
	beq	DisValueBAdrReg_XReg
	tst	d5
	beq	DisValueW
	subq.w	#1,d5
	beq	DisValueL
	subq.w	#1,d5
	beq	DisValueW_PC
	subq.w	#1,d5
	beq	DisValueB_PC_XReg
	subq.w	#1,d5
	beq	DisNumberW
	br	DisNoOp

C20BCE:
	addq.w	#2,a5
	rts

C20BD2:
	addq.w	#2,a5
	br	C2173E

C20BD8:
	bclr	#1,(BIT_6_7+1,a0)
	addq.w	#2,a5
	br	C217E4

C20BE4:
	addq.w	#2,a5
	move	(a0),d5		; BIT_0_2
	lsr.w	#1,d5
	bsr	DisDataReg
	move.b	#',',(a3)+
	br	C2184A

C20BF6:
	addq.w	#2,a5
	bra.b	DisEA

C20BFA:
	addq.w	#2,a5
	btst	#1,(BIT_F_E+1,a0)
	bne.b	DisEA
	cmp.w	#%0111010<<1,(BIT_6_0,a0)	; ftst ($3a)?
	bne	C20CF0
	move.w	(BIT_C_A,a0),(BIT_9_7,a0)	; set dst_reg = src_reg to not print dst_reg
	bra	C20CD0

DisFsaveFrestore:
DisEA:
	tst	d6
	beq	DisDataReg
	subq.w	#2,d6
	beq	DisAdresReg
	subq.w	#2,d6
	beq	DisAdrIndirect
	subq.w	#2,d6
	beq	DisAdrIndPlus
	subq.w	#2,d6
	beq	DisMinAdrInd
	subq.w	#2,d6
	beq	DisValueWAdrReg
	subq.w	#2,d6
	beq	DisValueBAdrReg_XReg
	tst	d5
	beq	DisValueW
	subq.w	#1,d5
	beq	DisValueL
	subq.w	#1,d5
	beq	DisValueW_PC
	subq.w	#1,d5
	beq	DisValueB_PC_XReg
	subq.w	#1,d5
	beq	DisNumberW
	br	DisNoOp

C20C52:
	addq.w	#2,a5
	btst	#1,(BIT_F_E+1,a0)
	bne.b	C20C7E
	move.w	(BIT_C_A,a0),d2
	lsr.w	#1,d2
	bsr.w	Disasm_FpuReg
	bra.b	C20CEC

C20C74:
	addq.w	#2,a5
	btst	#1,(BIT_F_E+1,a0)
	beq.b	C20CD0
C20C7E:
	pea	(C20CEC,pc)
	tst	d6
	beq	DisDataReg
	subq.w	#2,d6
	beq	DisAdresReg
	subq.w	#2,d6
	beq	DisAdrIndirect
	subq.w	#2,d6
	beq	DisAdrIndPlus
	subq.w	#2,d6
	beq	DisMinAdrInd
	subq.w	#2,d6
	beq	DisValueWAdrReg
	subq.w	#2,d6
	beq	DisValueBAdrReg_XReg
	tst	d5
	beq	DisValueW
	subq.w	#1,d5
	beq	DisValueL
	subq.w	#1,d5
	beq	DisValueW_PC
	subq.w	#1,d5
	beq	DisValueB_PC_XReg
	subq.w	#1,d5
	beq	DisNumberW
	br	DisNoOp

C20CD0:
	move.w	(BIT_C_A,a0),d1
	move.w	d1,d2
	lsr.w	#1,d2
	bsr.w	Disasm_FpuReg
	cmp	(BIT_9_7,a0),d1
	beq.b	C20D04
C20CEC:
	move.b	#',',(a3)+
C20CF0:
	move.w	(BIT_6_0,a0),d2
	lsr.w	#4,d2
	subq.w	#%0110,d2		; fsincos: (sss)0110ccc
	bne.b	.NotFsincos
	moveq	#7<<1,d2
	and.w	(BIT_6_0,a0),d2
	lsr.w	#1,d2
	bsr.w	Disasm_FpuReg
	move.b	#':',(a3)+
.NotFsincos
	move	(BIT_9_7,a0),d2
	lsr.w	#1,d2
	bra.w	Disasm_FpuReg
C20D04:
	rts

C20D06:
	move	(a0),d5		; BIT_0_2
	lsr.w	#1,d5
	and	#3,d5
	btst	#2,d5
	bne	DisNoOp
	moveq	#-5,d1
	cmp.b	#' ',(a3,d1.w)
	beq.b	.C20D24
	addq.w	#1,d1
.C20D24
	move.b	#'.',(a3,d1.w)
	btst	#0,d5
	beq.b	.C20D48
	move.b	#'L',(1,a3,d1.w)
	move.b	#'#',(a3)+
	move.b	#'$',(a3)+
	move.l	(a5)+,d0
	br	Zet_D0_Om_inA3

.C20D48
	move.b	#'W',(1,a3,d1.w)
	move	(a5)+,d0
	sf	(Disasm_NewSyntax-DT,a4)
	br	Zet_D0_Om2_inA3

C20D56:
	move	(a0),d5		; BIT_0_2
	lsr.w	#1,d5
	move	(BIT_3_5,a0),d4
	sf	(Disasm_NewSyntax-DT,a4)
	btst	#1,d4
	beq	DisDataReg
	br	DisAdresReg

C20D6E:
	move	(BIT_3_5,a0),d4
	btst	#1,d4
	beq.b	C20DB0
	move.b	#'-',(a3)+
	move.b	#'(',(a3)+
	moveq	#7<<1,d5
	and.w	(a0),d5		; BIT_0_2
	lsr.w	#1,d5
	bsr	DisAdresReg
	move.b	#')',(a3)+
	move.b	#',',(a3)+
	move.b	#'-',(a3)+
	move.b	#'(',(a3)+
	moveq	#7<<1,d5
	and.w	(BIT_9_B,a0),d5
	lsr.w	#1,d5
	bsr	DisAdresReg
	move.b	#')',(a3)+
	bra.b	C20DCE

C20DB0:
	moveq	#7<<1,d5
	and.w	(a0),d5		; BIT_0_2
	lsr.w	#1,d5
	bsr	DisDataReg
	move.b	#',',(a3)+
	moveq	#7<<1,d5
	and.w	(BIT_9_B,a0),d5
	lsr.w	#1,d5
	bsr	DisDataReg
C20DCE:
	move.b	#',',(a3)+
	move.b	#'#',(a3)+
	move.b	#'$',(a3)+
	move	(a5)+,d0
	sf	(Disasm_NewSyntax-DT,a4)
	br	Zet_D0_Om2_inA3

DisLongMul:
	pea	(C20E32,pc)
	addq.w	#2,a5
	tst	d6
	beq	DisDataReg
	subq.w	#4,d6
	beq	DisAdrIndirect
	subq.w	#2,d6
	beq	DisAdrIndPlus
	subq.w	#2,d6
	beq	DisMinAdrInd
	subq.w	#2,d6
	beq	DisValueWAdrReg
	subq.w	#2,d6
	beq	DisValueBAdrReg_XReg
	tst	d5
	beq	DisValueW
	subq.w	#1,d5
	beq	DisValueL
	subq.w	#1,d5
	beq	DisValueW_PC
	subq.w	#1,d5
	beq	DisValueB_PC_XReg
	subq.w	#1,d5
	beq	C217F2
	br	DisNoOp

C20E32:
	move.b	#',',(a3)+
	move	(BIT_F_0,a0),d4
	btst	#10,d4
	beq.b	C20E4E
	moveq	#7,d5
	and.w	d4,d5
	bsr	DisDataReg
	move.b	#':',(a3)+
C20E4E:
	move	d4,d5
	rol.w	#4,d5
	and	#7,d5
	sf	(Disasm_NewSyntax-DT,a4)
	bra	DisDataReg

DisMoves:
	move.w	(a5)+,d4
	btst	#11,d4		; dir
	beq.b	.ToReg
.FromReg
	bsr	DisAddrOrDataReg3
	move.w	(a0),d5		; BIT_0_2
	lsr.w	#1,d5
	move.b	#',',(a3)+
.HandleEA
	subq.w	#4,d6
	beq	DisAdrIndirect
	subq.w	#2,d6
	beq	DisAdrIndPlus
	subq.w	#2,d6
	beq	DisMinAdrInd
	subq.w	#2,d6
	beq	DisValueWAdrReg
	subq.w	#2,d6
	beq	DisValueBAdrReg_XReg
	tst	d5
	beq	DisValueW
	subq.w	#1,d5
	beq	DisValueL
	br	DisNoOp

.ToReg
	bsr.b	.HandleEA
	move.b	#',',(a3)+
	move.w	($0010,a0),d4
	bra	DisAddrOrDataReg3

DisMovec:
	sf	(Disasm_NewSyntax-DT,a4)
	addq.w	#2,a5
	move	(a0),d4		; BIT_0_2
	btst	#1,d4
	bne.b	C20EE0
	bsr.b	C20EFC
	move.b	#',',(a3)+
C20EE0:
	move	($0010,a0),d4
	bsr	DisAddrOrDataReg3
	move	(a0),d4		; BIT_0_2
	btst	#1,d4
	beq	DisNoOp
	move.b	#',',(a3)+
C20EFC:
	move	(BIT_F_0,a0),d4
	and	#$0FFF,d4
	beq	C2105C
	subq.w	#1,d4	;$001
	beq	C21062
	subq.w	#1,d4	;$002
	beq	DisCACR
	subq.w	#1,d4	;$003
	beq.b	C20F6A
	subq.w	#1,d4	;$004
	beq.b	C20F74
	subq.w	#1,d4	;$005
	beq.b	C20F86
	subq.w	#1,d4	;$006
	beq.b	C20F98
	subq.w	#1,d4	;$007
	beq.b	C20F9E
	subq.w	#1,d4	;$008
	beq	DissBUSCR

	move	(BIT_F_0,a0),d4
	and	#$0FFF,d4
	sub	#$0800,d4
	beq	DisUSP
	subq.w	#1,d4	;$801
	beq	DisVBR
	subq.w	#1,d4	;$802
	beq	DisCAAR
	subq.w	#1,d4	;$803
	beq	DisMSP
	subq.w	#1,d4	;$804
	beq	DisISP
	subq.w	#1,d4	;$805
	beq	DisMMUSR
	subq.w	#1,d4	;$806
	beq	DisURP
	subq.w	#1,d4	;$807
	beq	DisSRP
	subq.w	#1,d4	;$808
	beq	DisPCR

	move.b	#'?',(a3)+
	rts

C20F6A:
	move.b	#'T',(a3)+
	move.b	#'C',(a3)+
	rts

C20F74:
	move.b	#'I',(a3)+
C20F78:
	moveq	#'T',d0
	move.b	d0,(a3)+
	move.b	d0,(a3)+
	move.b	#'0',(a3)+
	rts

C20F86:
	move.b	#'I',(a3)+
C20F8A:
	moveq	#'T',d0
	move.b	d0,(a3)+
	move.b	d0,(a3)+
	move.b	#'1',(a3)+
	rts

C20F98:
	move.b	#'D',(a3)+
	bra.b	C20F78

C20F9E:
	move.b	#'D',(a3)+
	bra.b	C20F8A

C20FA4:
	move.b	#'C',(a3)+
	bra.b	C20FAE

C20FAA:
	move.b	#'V',(a3)+
C20FAE:
	move.b	#'A',(a3)+
	move.b	#'L',(a3)+
	rts

C20FB8:
	move.b	#'S',(a3)+
	moveq	#'C',d0
	move.b	d0,(a3)+
	move.b	d0,(a3)+
	rts

C20FC6:
	moveq	#'D',d0
	bra.b	C20FE0

C20FD4:
	moveq	#'C',d0
C20FE0:
	move.b	#'B',(a3)+
	move.b	#'A',(a3)+
	move.b	d0,(a3)+
	move	(BIT_6_0,a0),d0
	lsr.w	#3,d0
	add.b	#'0',d0
	move.b	d0,(a3)+
	rts

C20FEE:
	move.b	#'P',(a3)+
	move.b	#'C',(a3)+
	bra.b	C21000

C20FF8:
	move.b	#'P',(a3)+
C21000:
	move.b	#'S',(a3)+
	move.b	#'R',(a3)+
	rts

DisMMUSR:
	moveq	#'M',d0
	move.b	d0,(a3)+
;	moveq	#'M',d0
	move.b	d0,(a3)+
	move.b	#'U',(a3)+
	bra.b	C21000

C21014:
	move.b	#'D',(a3)+
	bra.b	C2102A

C2101A:
	move.b	#'C',(a3)+
	bra.b	C2102A

DisURP:
	move.b	#'U',(a3)+
	bra.b	C2102A

DisSRP:
	move.b	#'S',(a3)+
C2102A:
	move.b	#'R',(a3)+
	move.b	#'P',(a3)+
	rts

DisISP:
	move.b	#'I',(a3)+
	bra.b	C21044

DisMSP:
	move.b	#'M',(a3)+
	bra.b	C21044

DisUSP:
	move.b	#'U',(a3)+
C21044:
	move.b	#'S',(a3)+
	move.b	#'P',(a3)+
	rts

DisVBR:
	move.b	#'V',(a3)+
	move.b	#'B',(a3)+
	move.b	#'R',(a3)+
	rts

DisPCR:
	move.b	#'P',(a3)+
	bra.b	DissCR
	rts

DissBUSCR:
	move.b	#'B',(a3)+
	move.b	#'U',(a3)+
	move.b	#'S',(a3)+
DissCR:
	move.b	#'C',(a3)+
	move.b	#'R',(a3)+
	rts

C2105C:
	move.b	#'S',(a3)+
	bra.b	C21066

C21062:
	move.b	#'D',(a3)+
C21066:
	move.b	#'F',(a3)+
	move.b	#'C',(a3)+
	rts

DisCAAR:
	move.b	#'C',(a3)+
	moveq	#'A',d0
	move.b	d0,(a3)+
	move.b	d0,(a3)+
	move.b	#'R',(a3)+
	rts

DisCACR:
	moveq	#'C',d0
	move.b	d0,(a3)+
	move.b	#'A',(a3)+
	move.b	d0,(a3)+
	move.b	#'R',(a3)+
	rts

DisLongDiv:
	pea	(C210E2,pc)
	addq.w	#2,a5
	tst	d6
	beq	DisDataReg
	subq.w	#4,d6
	beq	DisAdrIndirect
	subq.w	#2,d6
	beq	DisAdrIndPlus
	subq.w	#2,d6
	beq	DisMinAdrInd
	subq.w	#2,d6
	beq	DisValueWAdrReg
	subq.w	#2,d6
	beq	DisValueBAdrReg_XReg
	tst	d5
	beq	DisValueW
	subq.w	#1,d5
	beq	DisValueL
	subq.w	#1,d5
	beq	DisValueW_PC
	subq.w	#1,d5
	beq	DisValueB_PC_XReg
	subq.w	#1,d5
	beq	C217F2
	br	DisNoOp

C210E2:
	move.b	#',',(a3)+
	move	(BIT_F_0,a0),d4
	moveq	#15,d5
	and.w	d4,d5
	bsr	DisDataReg
	move.b	#':',(a3)+
	move	d4,d5
	rol.w	#4,d5
	and	#7,d5
	sf	(Disasm_NewSyntax-DT,a4)
	bra	DisDataReg

DisCmp2Chk2:
	pea	(.VerdernaKomma,pc)
	addq.w	#2,a5
	subq.w	#4,d6
	beq	DisAdrIndirect
	subq.w	#6,d6
	beq	DisValueWAdrReg
	subq.w	#2,d6
	beq	DisValueBAdrReg_XReg
	tst	d5
	beq	DisValueW
	subq.w	#1,d5
	beq	DisValueL
	subq.w	#1,d5
	beq	DisValueW_PC
	bra	DisValueB_PC_XReg

.VerdernaKomma:
	move.b	#',',(a3)+
	move	(BIT_F_0,a0),d4
	sf	(Disasm_NewSyntax-DT,a4)
	bra	DisAddrOrDataReg3

DisCas2:
	moveq	#7,d5
	and.w	(BIT_F_0,a0),d5
	bsr	DisDataReg
	move.b	#':',(a3)+
	moveq	#7,d5
	and.w	(2,a5),d5
	bsr	DisDataReg
	move.b	#',',(a3)+
	move	(BIT_F_0,a0),d5
	lsr.w	#6,d5
	and	#7,d5
	bsr	DisDataReg
	move.b	#':',(a3)+
	move	(2,a5),d5
	lsr.w	#6,d5
	and	#7,d5
	bsr	DisDataReg
	move.b	#',',(a3)+
	move.b	#'(',(a3)+
	move	(BIT_F_0,a0),d4
	bsr	DisAddrOrDataReg3
	move.b	#')',(a3)+
	move.b	#':',(a3)+
	move.b	#'(',(a3)+
	move	(2,a5),d4
	bsr	DisAddrOrDataReg3
	move.b	#')',(a3)+
	addq.w	#4,a5
	sf	(Disasm_NewSyntax-DT,a4)
	rts

DisCas:
	moveq	#7,d5
	and.w	(BIT_F_0,a0),d5
	bsr	DisDataReg
	move.b	#',',(a3)+
	move.w	(BIT_F_0,a0),d5
	lsr.w	#6,d5
	and	#7,d5
	bsr	DisDataReg
	move.b	#',',(a3)+
	addq.w	#2,a5
	pea	(.C21218,pc)
	movem.w	(a0),d5/d6	; BIT_0_2/BIT_3_5
	lsr.w	#1,d5
	subq.w	#4,d6
	beq	DisAdrIndirect
	subq.w	#2,d6
	beq	DisAdrIndPlus
	subq.w	#2,d6
	beq	DisMinAdrInd
	subq.w	#2,d6
	beq	DisValueWAdrReg
	subq.w	#2,d6
	beq	DisValueBAdrReg_XReg
	tst.w	d5
	beq	DisValueW
	bra	DisValueL
.C21218	sf	(Disasm_NewSyntax-DT,a4)
	rts

DisCallm:
	bsr DisValueB_Imm		; advances a5 by 2
	move.b	#',',(a3)+
	subq.w	#4,d6
	beq	DisAdrIndirect
	subq.w	#6,d6
	beq	DisNextA5WordAsOffset
	subq.w	#2,d6
	beq	DisValueBAdrReg_XReg
	tst.w	d5
	beq	DisValueW
	subq.w	#1,d5
	beq	DisValueL
	subq.w	#1,d5
	beq	DisValueW_PC
	subq.w	#1,d5
	beq	DisValueB_PC_XReg
	br	DisNoOp

DisBkpt:
	move.b	#'#',(a3)+
	move	d5,d0
	sf	(Disasm_NewSyntax-DT,a4)
	br	Zet_D0_Om3_inA3

DisBFieldDx:
	move	(BIT_F_0,a0),d5
	rol.w	#4,d5
	and	#7,d5
	bra.w	DisDataReg

DisBFieldEA:
	tst	d6
	beq.b	C212E4
	subq.w	#2,d6
	beq.b	.None
	subq.w	#2,d6
	beq.b	C212D2
	subq.w	#2,d6
	beq.b	.None
	subq.w	#2,d6
	beq.b	.None
	move.w	(a5)+,-(sp)
	pea	(DisBFRestore,pc)
	subq.w	#2,d6
	beq.w	DisValueWAdrReg
	subq.w	#2,d6
	beq.w	DisValueBAdrReg_XReg
	tst.w	d5
	beq	DisValueW
	subq.w	#1,d5
	beq	DisValueL
	subq.w	#1,d5
	beq	DisValueW_PC
	subq.w	#1,d5
	beq	DisValueB_PC_XReg
	subq.l	#2,a5
	addq.l	#4+2,sp
.None	br	DisDcw

DisBFRestore:
	move	(sp)+,d4
	bra.b	C212EE

C212D2:
	move.b	#'(',(a3)+
	and	#7,d5
	bsr	DisAdresReg
	move.b	#')',(a3)+
	bra.b	C212EC

C212E4:
	and	#7,d5
	bsr	DisDataReg
C212EC:
	move	(a5)+,d4
C212EE:
	move.b	#'{',(a3)+
	move	d4,d5
	ror.w	#6,d5
	btst	#5,d5
	beq.b	C21306
	and.b	#7,d5
	bsr	DisDataReg
	bra.b	C21314

C21306:
	bsr.b	Disasm_BfImmed
C21314:
	move.b	#':',(a3)+
	move	d4,d5
	btst	#5,d5
	beq.b	C2132A
	and.b	#7,d5
	bsr	DisDataReg
	bra.b	C21338

C2132A:
	bsr.b	Disasm_BfImmed
C21338:
	move.b	#'}',(a3)+
	sf	(Disasm_NewSyntax-DT,a4)
	rts

Disasm_BfImmed:
	move.b	#'$',(a3)+
	moveq	#$1f,d0
	and.b	d5,d0
	bra	Zet_D0_Om3_inA3

C21342:
	tst	d6
	beq	DisDataReg
	subq.w	#2,d6
	beq	DisAdresReg
	subq.w	#2,d6
	beq	DisAdrIndirect
	subq.w	#2,d6
	beq	DisAdrIndPlus
	subq.w	#2,d6
	beq	DisMinAdrInd
	subq.w	#2,d6
	beq	DisValueWAdrReg
	subq.w	#2,d6
	beq	DisValueBAdrReg_XReg
	tst	d5
	beq	DisValueW
	subq.w	#1,d5
	beq	DisValueL
	subq.w	#1,d5
	beq	DisValueW_PC
	subq.w	#1,d5
	beq	DisValueB_PC_XReg
	subq.w	#1,d5
	beq	DisValueB_Imm
	br	DisNoOp

C2138E:
	addq.w	#2,a5
C21390:
	tst	d6
	beq	DisDataReg
	subq.w	#2,d6
	beq	DisAdresReg
	subq.w	#2,d6
	beq	DisAdrIndirect
	subq.w	#2,d6
	beq	DisAdrIndPlus
	subq.w	#2,d6
	beq	DisMinAdrInd
	subq.w	#2,d6
	beq	DisValueWAdrReg
	subq.w	#2,d6
	beq	DisValueBAdrReg_XReg
	tst	d5
	beq	DisValueW
	subq.w	#1,d5
	beq	DisValueL
	subq.w	#1,d5
	beq	DisValueW_PC
	subq.w	#1,d5
	beq	DisValueB_PC_XReg
	subq.w	#1,d5
	beq	C217E4
	br	DisNoOp

C213DC:
	tst	d6
	beq.b	DisDataReg
	subq.w	#2,d6
	beq.b	DisAdresReg
	subq.w	#2,d6
	beq.b	DisAdrIndirect
	subq.w	#2,d6
	beq.b	DisAdrIndPlus
	subq.w	#2,d6
	beq.b	DisMinAdrInd
	subq.w	#2,d6
	beq.b	DisValueWAdrReg
	subq.w	#2,d6
	beq	DisValueBAdrReg_XReg
	tst	d5
	beq	DisValueW
	subq.w	#1,d5
	beq	DisValueL
	subq.w	#1,d5
	beq	DisValueW_PC
	subq.w	#1,d5
	beq	DisValueB_PC_XReg
	subq.w	#1,d5
	beq	C2173E
	br	DisNoOp

DisAddrOrDataReg3:
	rol.w	#4,d4
DisAddrOrDataReg2:
	and.w	#15,d4
DisAddrOrDataReg:
	moveq	#7,d5
	and	d4,d5
	cmp	d4,d5
	bne.b	DisAdresReg
DisDataReg:
	moveq	#'D',d0
	bra.b	C2142A

DisAdresReg:
	moveq	#'A',d0
C2142A:
	move.b	d0,(a3)+
	moveq	#'0',d0
	add.b	d5,d0
	move.b	d0,(a3)+
	rts

DisValueWAdrReg:
	bsr.b	DisNextA5WordAsOffset
	bra.b	DisAdrIndirect

DisMinAdrInd:
	move.b	#'-',(a3)+
DisAdrIndirect:
	move.b	#'(',(a3)+
	bsr.b	DisAdresReg
	move.b	#')',(a3)+
	rts

DisAdrIndPlus:
	bsr.b	DisAdrIndirect
	move.b	#'+',(a3)+
	rts

DisNextA5WordAsOffset:
	move	(a5)+,d1
	bpl.b	DisAbsAdressing
	neg.w	d1
	move.b	#'-',(a3)+
	tst.b	(PR_LibCalDec).l
	beq.b	DisAbsAdressing
	cmp.b	#'J',(-13,a3)
	bne.b	DisAbsAdressing
	st	(Dis_DecLibCall-DT,a4)
	move	d1,d0
	movem.l	d0-d7/a0-a2/a4-a6,-(sp)
	jsr	(PRINTDECIMALWORD)
	movem.l	(sp)+,d0-d7/a0-a2/a4-a6
	sf	(Dis_DecLibCall-DT,a4)
	rts

DisAbsAdressing:
	move.b	#'$',(a3)+
	move	d1,d0
	br	Zet_D0_Om2_inA3

Dis_ExtensionWord:
	move	(a5)+,d1
	btst	#8,d1		; brief or 020+ full?
	bne.b	Dis_NewSyntax
	tst.b	d1
	bpl.b	.C214A8
	neg.b	d1
	move.b	#'-',(a3)+
.C214A8	move.b	#'$',(a3)+
	move	d1,d0
	br	Zet_D0_Om3_inA3

C21782:
	move	(a5)+,d1

Dis_NewSyntax:
	moveq	#15,d4
	and.b	d1,d4
	beq	Dis_nullOuterDisplacement
	move.b	#'(',(a3)+
	move.b	#'[',(a3)+
	move	d1,d4
	ror.w	#4,d4
	and	#3,d4
	move.b	#'$',(a3)+
	cmp	#2,d4
	bne.b	C214E8
	move	(a5)+,d0
	bsr	Zet_D0_Om2_inA3
	move.b	#'.',(a3)+
	move.b	#'W',(a3)+
	bra.b	C2150C

C214E8:
	move	(BIT_3_5,a0),d0	;source mode?
	and	#%111<<1,d0
	cmp.b	#%111<<1,d0
	beq.b	.pc
	move.l	(a5)+,d0
	bra.b	C21500

.pc:
	move.l	a5,d0
	add.l	(a5)+,d0
	subq.l	#2,d0
C21500:
	bsr	Zet_D0_Om_inA3
	move.b	#'.',(a3)+
	move.b	#'L',(a3)+
C2150C:
	tst.b	d1	; bit7 set?
	bmi.b	C21530

	move.b	#',',(a3)+
	and	#7,d5
	cmp	#7<<1,(BIT_3_5,a0)
	bne.b	C2152C
	move.b	#'P',(a3)+
	move.b	#'C',(a3)+
	bra.b	C21530

C2152C:
	bsr	DisAdresReg
C21530:
	btst	#2,d1
	beq.b	C2153A
	move.b	#']',(a3)+
C2153A:
	btst	#6,d1
	beq.b	C21544
	rol.w	#4,d1
	bra.b	C21572

C21544:
	move.b	#',',(a3)+
	rol.w	#4,d1
	moveq	#7,d5
	and.w	d1,d5
	bsr	DisDataReg
	move.b	#'.',(a3)+
	moveq	#'W',d0
	tst.w	d1	; test bit 15
	bpl.b	.C21562
	moveq	#'L',d0
.C21562	move.b	d0,(a3)+
	move	d1,d4
	rol.w	#3,d4
	and	#3,d4
	beq.b	C21572
	bsr	C2171A
C21572:
	ror.w	#4,d1
	btst	#2,d1
	bne.b	C2157E
	move.b	#']',(a3)+
C2157E:
	and	#3,d1
	cmp	#1,d1
	ble.b	C215B4
	move.b	#',',(a3)+
	move.b	#'$',(a3)+
	cmp	#2,d1
	bne.b	C215A6
	move	(a5)+,d0
	bsr	Zet_D0_Om2_inA3
	move.b	#'.',(a3)+
	move.b	#'W',(a3)+
	bra.b	C215B4

C215A6:
	move.l	(a5)+,d0
	bsr	Zet_D0_Om_inA3
	move.b	#'.',(a3)+
	move.b	#'L',(a3)+
C215B4:
	move.b	#')',(a3)+
	sf	(Disasm_NewSyntax-DT,a4)
	rts

Dis_nullOuterDisplacement:
	move.b	#'(',(a3)+
	move	d1,d4
	tst.b	d4	; bit7 set?
	bmi.w	C2165C

	moveq	#7<<1,d5
	and.w	(a0),d5		; BIT_0_2
	lsr.w	#1,d5
	cmp	#7<<1,(BIT_3_5,a0)
	bne.b	C215E6
	move.b	#'P',(a3)+
	move.b	#'C',(a3)+
	bra.b	C215EA

C215E6:
	bsr	DisAdresReg
C215EA:
	move.b	#',',(a3)+
	rol.w	#4,d1
	moveq	#7,d5
	and.w	d1,d5
	bsr	DisDataReg
	move.b	#'.',(a3)+
	moveq	#'W',d0
	btst	#15,d1
	beq.b	C21608
	moveq	#'L',d0
C21608:
	move.b	d0,(a3)+
	rol.w	#3,d1
	moveq	#3,d4
	and.w	d1,d4
	beq.b	C21618
	bsr	C2171A
C21618:
	move.b	#',',(a3)+
	rol.w	#5,d1
	and	#3,d1
	move.b	#'$',(a3)+
	cmp.b	#2,d1
	bne.b	C21644
	move	(a5)+,d0
	bsr	Zet_D0_Om2_inA3
	move.b	#'.',(a3)+
	move.b	#'W',(a3)+
	move.b	#')',(a3)+
	sf	(Disasm_NewSyntax-DT,a4)
	rts

C21644:
	move.l	(a5)+,d0
	bsr	Zet_D0_Om_inA3
	move.b	#'.',(a3)+
	move.b	#'L',(a3)+
	move.b	#')',(a3)+
	sf	(Disasm_NewSyntax-DT,a4)
	rts

C2165C:
	rol.w	#4,d4
	move	d4,-(sp)
	bsr	DisAddrOrDataReg2
	move.b	#'.',(a3)+
	moveq	#'W',d0
	move	(sp),d4
	rol.w	#3,d4
	btst	#2,d4
	beq.b	C2167A
	moveq	#'L',d0
C2167A:
	move.b	d0,(a3)+
	and	#3,d4
	beq.b	C21686
	bsr	C2171A
C21686:
	move	(sp)+,d4
	rol.w	#8,d4
	and	#3,d4
	beq.b	C216BE
	subq.w	#1,d4
	beq.b	C216BE
	move.b	#',',(a3)+
	move.b	#'$',(a3)+
	subq.w	#1,d4
	beq.b	C216B0
	move.l	(a5)+,d0
	bsr	Zet_D0_Om_inA3
	move.b	#'.',(a3)+
	move.b	#'L',(a3)+
	bra.b	C216BE

C216B0:
	move	(a5)+,d0
	bsr	Zet_D0_Om2_inA3
	move.b	#'.',(a3)+
	move.b	#'W',(a3)+
C216BE:
	move.b	#')',(a3)+
	sf	(Disasm_NewSyntax-DT,a4)
	rts

DisValueBAdrReg_XReg:
	st	(Disasm_NewSyntax-DT,a4)
	bsr	Dis_ExtensionWord
	tst.b	(Disasm_NewSyntax-DT,a4)
	beq	DisNoOp
	move.b	#'(',(a3)+
	bsr	DisAdresReg
C216E2:
	move.b	#',',(a3)+
	move	(-2,a5),d1
	rol.w	#4,d1
	move.w	d1,d4
	bsr	DisAddrOrDataReg2
	move.b	#'.',(a3)+
	moveq	#'W',d0
	tst	d1
	bpl.b	C21700
	moveq	#'L',d0
C21700:
	move.b	d0,(a3)+
	rol.w	#3,d1
	moveq	#3,d4
	and.w	d1,d4
	beq.b	C21714
	bsr.b	C2171A
	sf	(Disasm_NewSyntax-DT,a4)
C21714:
	move.b	#')',(a3)+
	rts

C2171A:
	move.b	#'*',(a3)+
	move.b	(.Scale,pc,d4.w),(a3)+
	rts

.Scale	DC.B	'1248'

DisValueW:
	bsr	DisNextA5WordAsOffset
	move.b	#'.',(a3)+
	move.b	#'W',(a3)+
	rts

C2173E:
	move.b	#'#',(a3)+
DisValueL:
	move.l	(a5)+,d0
	br	ZetHex_D0_Om_insource

DisValueW_PC:
	bsr	C2184A
	move.b	#'(',(a3)+
	move.b	#'P',(a3)+
	move.b	#'C',(a3)+
	move.b	#')',(a3)+
	rts

DisValueB_PC_XReg:
	move	(a5),d0
	btst	#8,d0		; brief or 020+ full?
	bne	C21782
	IF	MC020
	extb.l	d0
	ELSE
	ext.w	d0
	ext.l	d0
	ENDIF
	add.l	a5,d0
	bsr	C21850
	addq.w	#2,a5
	move.b	#'(',(a3)+
	move.b	#'P',(a3)+
	move.b	#'C',(a3)+
	br	C216E2

DisNumberW:
	move	(BIT_C_A,a0),d0
	beq.b	C217F2
	cmp	#12,d0
	beq.b	DisValueB_Imm
	cmp	#8,d0
	beq.b	C217E4
	cmp	#2,d0
	beq.b	C217F2
	cmp	#10,d0
	beq.b	C217C2
	move.b	#'#',(a3)+
	move.b	#'$',(a3)+
	move.l	(a5)+,d0
	bsr	Zet_D0_Om_inA3
	move.l	(a5)+,d0
	bsr	Zet_D0_Om_inA3
	move.l	(a5)+,d0
	br	Zet_D0_Om_inA3

C217C2:
	move.b	#'#',(a3)+
	move.b	#'$',(a3)+
	move.l	(a5)+,d0
	bsr	Zet_D0_Om_inA3
	move.l	(a5)+,d0
	br	Zet_D0_Om_inA3

DisValueB_Imm:
	move.b	#'#',(a3)+
	move.b	#'$',(a3)+
	move	(a5)+,d0
	br	Zet_D0_Om3_inA3

C217E4:
	move.b	#'#',(a3)+
	move.b	#'$',(a3)+
	move	(a5)+,d0
	br	Zet_D0_Om2_inA3

C217F2:
	move.b	#'#',(a3)+
	move.b	#'$',(a3)+
	move.l	(a5)+,d0
	br	Zet_D0_Om_inA3

C21800:
	move.b	#'S',(a3)+
	move.b	#'R',(a3)+
	rts

C2180A:
	moveq	#'C',d0
	move.b	d0,(a3)+
	move.b	d0,(a3)+
	move.b	#'R',(a3)+
	rts

C21818:
	move.b	#'U',(a3)+
	move.b	#'S',(a3)+
	move.b	#'P',(a3)+
	rts

C21826:
	move.b	(-1,a5),d0
	beq.b	C2184A
	cmp	#PB_020,(ProcessorType-DT,a4)
	blt.b	C21842
	cmp.b	#$FF,d0
	bne.b	C21842
	move.l	(a5),d0
	add.l	a5,d0
	addq.w	#4,a5
	bra.b	C21850

C21842:
	IF	MC020
	extb.l	d0
	ELSE
	ext.w	d0
	ext.l	d0
	ENDIF
	add.l	a5,d0
	bra.b	C21850

C2184A:
	move.l	a5,a2
	add	(a5)+,a2
	move.l	a2,d0
C21850:
	br	ZetHex_D0_Om_insource

DisFbcc:
	move.l	a5,a2
	add.l	(a5)+,a2
	move.l	a2,d0
	br	ZetHex_D0_Om_insource

DisMoveq:
	move.b	#'#',(a3)+
	subq.w	#2,a5
	br	Dis_ExtensionWord

C21868:
	move.b	#'#',(a3)+
	move	d5,d0
	subq.w	#1,d0
	and	#7,d0
	addq.w	#1,d0
	br	Zet_D0_Om4_inA3

C2187A:
	move.b	#'#',(a3)+
	move.b	#'$',(a3)+
	move.b	(-1,a5),d0
	br	Zet_D0_Om4_inA3

DisLineAF:
	move.b	#'#',(a3)+
	move.b	#'$',(a3)+
	move	(-2,a5),d0
	and	#$0FFF,d0
	br	Zet_D0_Om2_inA3

DisDcw:
	move.b	#'$',(a3)+
	move	(-2,a5),d0
	br	Zet_D0_Om2_inA3

DisMovem:
	move	(BIT_F_0,a0),d1
	cmp	#4<<1,(BIT_3_5,a0)
	bne.b	C218C2
	moveq	#16-1,d2
.C218B8	lsr.w	#1,d1		; bit reverse
	addx.w	d0,d0
	dbra	d2,.C218B8
	move	d0,d1
C218C2:
	moveq	#$11,d6
	moveq	#-1,d4
C218C6:
	addq.w	#1,d4
	cmp	d6,d4
	beq.b	C2191E
	lsr.w	#1,d1
	bcc.b	C218C6
C218D2:
	bsr	DisAddrOrDataReg
	addq.w	#1,d4
	cmp	d6,d4
	beq.b	C2191E
	lsr.w	#1,d1
	bcc.b	C2190C
	addq.w	#1,d4
	cmp	d6,d4
	beq.b	C2191E
	lsr.w	#1,d1
	bcc.b	C21900
C218EE:
	addq.w	#1,d4
	cmp	d6,d4
	beq.b	C2191E
	lsr.w	#1,d1
	bcs.b	C218EE
	move.b	#'-',(a3)+
	bra.b	C21904

C21900:
	move.b	#'/',(a3)+
C21904:
	subq.b	#1,d4
	bsr	DisAddrOrDataReg
	addq.b	#1,d4
C2190C:
	addq.w	#1,d4
	cmp	d6,d4
	beq.b	C2191E
	lsr.w	#1,d1
	bcc.b	C2190C
	move.b	#'/',(a3)+
	bra.b	C218D2
C2191E:
	rts

C21920:
	cmp.l	(INSERT_START-DT,a4),d0
	bcs.b	ZetHex_D0_Om5_inA3
	cmp.l	(INSERT_END-DT,a4),d0
	bhi.b	ZetHex_D0_Om5_inA3
	lea	(LB_.MSG).l,a2
C21932:
	move.b	(a2)+,(a3)+
	bne.b	C21932
	subq.w	#1,a3
	bra.b	Zet_D0_Om_inA3				; draw 32 bits

ZetHex_D0_Om_insource:
	btst	#SB2_INSERTINSOURCE,(SomeBits2-DT,a4)
	bne.b	C21920
ZetHex_D0_Om5_inA3:
	move.l	d0,(MON_LAST_LONG_ADDR-DT,a4)
	move.b	#'$',(a3)+
Zet_D0_Om_inA3:
	swap	d0
	bsr.b	Zet_D0_Om2_inA3
	swap	d0
Zet_D0_Om2_inA3:
	move	d0,-(sp)
	lsr.w	#8,d0
	bsr.b	Zet_D0_Om3_inA3
	move	(sp)+,d0
Zet_D0_Om3_inA3:
	move.b	d0,-(sp)
	lsr.b	#4,d0
	bsr.b	Zet_D0_Om4_inA3
	move.b	(sp)+,d0
Zet_D0_Om4_inA3:
	and.b	#15,d0
	add.b	#'0',d0
	cmp.b	#'9',d0
	ble.b	Zet_D0_Om5_inA3
	addq.b	#7,d0
Zet_D0_Om5_inA3:
	move.b	d0,(a3)+
	rts

DisAsmblBigTable:
	include	include:Disasm.data2.s

	CNOP	0,4
Disasm_END:		; section end

;***********************************************
;**            ERROR MSGS SECTION             **
;***********************************************

	SECTION	AsmPrors01C188,DATA	; data+bss

DATA_START:

Error_Msg_Table:
	dr.w	AddressRegByt.MSG
	dr.w	AddressRegExp.MSG
	dr.w	Dataregexpect.MSG
	dr.w	DoubleSymbol.MSG
	dr.w	EndofFile.MSG
	dr.w	UsermadeFAIL.MSG
	dr.w	FileError.MSG
	dr.w	InvalidAddrMode.MSG
	dr.w	IllegalDevice.MSG
	dr.w	Illegalmacrod.MSG
	dr.w	IllegalOperat.MSG0
	dr.w	IllegalOperat.MSG
	dr.w	IllegalOperan.MSG
	dr.w	IllegalOrder.MSG
	dr.w	IllegalSectio.MSG
	dr.w	IllegalAddres.MSG
	dr.w	Illegalregsiz.MSG
	dr.w	IllegalPath.MSG
	dr.w	IllegalSize.MSG
	dr.w	IllegalComman.MSG
	dr.w	Immediateoper.MSG
	dr.w	IncludeJam.MSG
	dr.w	Commaexpected.MSG
	dr.w	LOADwithoutOR.MSG
	dr.w	Macrooverflow.MSG
	dr.w	Conditionalov.MSG
	dr.w	WorkspaceMemo.MSG
	dr.w	MissingQuote.MSG
	dr.w	Notinmacro.MSG
	dr.w	Notdone.MSG
	dr.w	NoFileSpace.MSG
	dr.w	NoFiles.MSG
	dr.w	Nodiskindrive.MSG
	dr.w	NOoperandspac.MSG
	dr.w	NOTaconstantl.MSG
	dr.w	NoObject.MSG
;	dr.w	OutofRange0bi.MSG	; unused
	dr.w	OutofRange3bi.MSG
	dr.w	OutofRange4bi.MSG
	dr.w	OutofRange8bi.MSG
	dr.w	OutofRange16b.MSG
	dr.w	RelativeModeE.MSG
	dr.w	ReservedWord.MSG
	dr.w	Rightparenthe.MSG
	dr.w	Stringexpecte.MSG
	dr.w	Sectionoverfl.MSG
	dr.w	Registerexpec.MSG
	dr.w	UndefinedSymb.MSG
	dr.w	Unexpected.MSG
	dr.w	WordatOddAddr.MSG
	dr.w	WriteProtecte.MSG
	dr.w	Notlocalarea.MSG
	dr.w	Codemovedduri.MSG
	dr.w	BccBoutofrang.MSG
	dr.w	Outofrange20t.MSG
	dr.w	Outofrange60t.MSG
	dr.w	Includeoverfl.MSG
	dr.w	Linkerlimitat.MSG
	dr.w	Repeatoverflo.MSG
	dr.w	NotinRepeatar.MSG
	dr.w	Doubledefinit.MSG
	dr.w	Relocationmad.MSG
;	dr.w	Illegaloption.MSG	; unused
	dr.w	REMwithoutERE.MSG
	dr.w	TEXTwithoutET.MSG
	dr.w	Illegalscales.MSG
	dr.w	Offsetwidthex.MSG
	dr.w	OutofRange5bi.MSG
	dr.w	Missingbrace.MSG
	dr.w	Colonexpected.MSG
	dr.w	Missingbracke.MSG
	dr.w	Illegalfloati.MSG
	dr.w	Illegalsizefo.MSG
;	dr.w	BccWoutofrang.MSG	; unused
	dr.w	Floatingpoint.MSG
;	dr.w	OutofRange6bi.MSG	; unused
	dr.w	OutofRange7bi.MSG
	dr.w	FPUneededforo.MSG
	dr.w	Tomanywatchpo.MSG
	dr.w	Illegalsource.MSG
	dr.w	Novalidmemory.MSG
;	dr.w	Autocommandov.MSG	; unused
	dr.w	Endshouldbehi.MSG
;	dr.w	Warningvalues.MSG	; unused
	dr.w	Illegalsource.MSG0
	dr.w	Includingempt.MSG
	dr.w	IncludeSource.MSG
	dr.w	Unknownconver.MSG
	dr.w	Unknowncmappl.MSG
	dr.w	Unknowncmapmo.MSG
	dr.w	Tryingtoinclu.MSG
	dr.w	IFFfileisnota.MSG
	dr.w	CanthandleaBO.MSG
	dr.w	ThisisnotaAsm.MSG
;	dr.w	Bitfieldcantb.MSG	; unused
	IF	PPC
	dr.w	GeneralPurposeReg.MSG
	ENDIF
;	dr.w	AdrOrPCExpected.MSG	; unused
	dr.w	UnknowCPU.MSG
	DR.W	StackFull.MSG

WorkspaceMemo.MSG:	dc.b	'Workspace memory full',0
AddressRegByt.MSG:	dc.b	'Address reg. byte/logic',0
AddressRegExp.MSG:	dc.b	'Address reg. expected',0
;AdrOrPCExpected.MSG:	dc.b	'Address Reg. or PC Expected',0		; unused
Commaexpected.MSG:	dc.b	'Comma expected ',0
Dataregexpect.MSG:	dc.b	'Data reg. expected',0
DoubleSymbol.MSG:	dc.b	'Double symbol',0
Unexpected.MSG:		dc.b	'Unexpected '
EndofFile.MSG:		dc.b	'End of file',0
UsermadeFAIL.MSG:	dc.b	'User made FAIL',0
IllegalComman.MSG:	dc.b	'Illegal command',0
IllegalAddres.MSG:	dc.b	'Illegal address size',0
IllegalOperan.MSG:	dc.b	'Illegal operand',0
IllegalOperat.MSG:	dc.b	'Illegal operator',0
IllegalOperat.MSG0:	dc.b	'Illegal operator in BSS area',0
IllegalOrder.MSG:	dc.b	'Illegal order',0
Illegalregsiz.MSG:	dc.b	'Illegal reg. size',0
IllegalSectio.MSG:	dc.b	'Illegal section type',0
IllegalSize.MSG:	dc.b	'Illegal size',0
Illegalmacrod.MSG:	dc.b	'Illegal macro definition',0
Immediateoper.MSG:	dc.b	'Immediate operand expected',0
IncludeJam.MSG:		dc.b	'Include jam',0
Macrooverflow.MSG:	dc.b	'Macro overflow',0
InvalidAddrMode.MSG:	dc.b	'Invalid addressing mode',0
LOADwithoutOR.MSG:	dc.b	'LOAD without ORG',0
MissingQuote.MSG:	dc.b	'Missing quote',0
Conditionalov.MSG:	dc.b	'Conditional overflow',0
NOoperandspac.MSG:	dc.b	'No operand space allowed',0
NOTaconstantl.MSG:	dc.b	'Not a constant/label',0
Notinmacro.MSG:		dc.b	'Not in macro ',0
;OutofRange0bi.MSG:	dc.b	'Out of range 0 bit',0	; unused
OutofRange3bi.MSG:	dc.b	'Out of range 3 bit',0
OutofRange4bi.MSG:	dc.b	'Out of range 4 bit',0
OutofRange5bi.MSG:	dc.b	'Out of range 5 bit',0
;OutofRange6bi.MSG:	dc.b	'Out of range 6 bit',0	; unused
OutofRange7bi.MSG:	dc.b	'Out of range 7 bit',0
OutofRange8bi.MSG:	dc.b	'Out of range 8 bit',0
OutofRange16b.MSG:	dc.b	'Out of range 16 bit',0
RelativeModeE.MSG:	dc.b	'Relative mode error',0
ReservedWord.MSG:	dc.b	'Reserved word',0
Rightparenthe.MSG:	dc.b	'Right parenthesis expected',0
Sectionoverfl.MSG:	dc.b	'Section overflow',0
Stringexpecte.MSG:	dc.b	'String expected',0
UndefinedSymb.MSG:	dc.b	'Undefined symbol',0
Registerexpec.MSG:	dc.b	'Register expected',0
WordatOddAddr.MSG:	dc.b	'Word at ODD address',0
Notlocalarea.MSG:	dc.b	'Not local area',0
Codemovedduri.MSG:	dc.b	'Code moved during pass 2',0
BccBoutofrang.MSG:	dc.b	'Bcc.B out of range in macro',0
Outofrange20t.MSG:	dc.b	'Out of range (20 to 100)',0
Outofrange60t.MSG:	dc.b	'Out of range (60 to 132)',0
Includeoverfl.MSG:	dc.b	'Include overflow',0
Linkerlimitat.MSG:	dc.b	'Linker limitation',0
Repeatoverflo.MSG:	dc.b	'REPT overflow',0
NotinRepeatar.MSG:	dc.b	'Not in REPT area',0
Doubledefinit.MSG:	dc.b	'Double definition',0
Relocationmad.MSG:	dc.b	'Relocation made to EMPTY section',0
FileError.MSG:		dc.b	'File error ',0
NoFiles.MSG:		dc.b	'No files   ',0
NoObject.MSG:		dc.b	'No object  ',0
NoFileSpace.MSG:	dc.b	'No file space',0
PrinterDevice.MSG:	dc.b	'Printer device missing',10,0
Notdone.MSG:		dc.b	'Not done   ',0
IllegalPath.MSG:	dc.b	'Illegal path ',0
IllegalDevice.MSG:	dc.b	'Illegal device',0
WriteProtecte.MSG:	dc.b	'Write protected',0
Nodiskindrive.MSG:	dc.b	'No disk in drive',0
;Illegaloption.MSG:	dc.b	'Illegal option!',0	; unused
REMwithoutERE.MSG:	dc.b	'REM without EREM',0
TEXTwithoutET.MSG:	dc.b	'TEXT without ETEXT',0	; first 4 chars must be 'TEXT'
Illegalscales.MSG:	dc.b	'Illegal scale size',0
Offsetwidthex.MSG:	dc.b	'{Offset/width} expected',0
Missingbrace.MSG:	dc.b	'Missing brace',0
Colonexpected.MSG:	dc.b	'Colon expected',0
Missingbracke.MSG:	dc.b	'Missing bracket',0
FPUneededforo.MSG:	dc.b	'FPU needed for operation!',0
Tomanywatchpo.MSG:	dc.b	'Too many watchpoints (max. 8)',0
Illegalsource.MSG:	dc.b	'Illegal source, not activated!',0
Novalidmemory.MSG:	dc.b	'No valid memory directory present',0
;Autocommandov.MSG:	dc.b	'Auto command overflow (256 chars)',0	; unused
Endshouldbehi.MSG:	dc.b	'End should be higher than start!',0
;Warningvalues.MSG:	dc.b	'Warning, value signed extended to longword',0	; unused
Illegalsource.MSG0:	dc.b	'Illegal source number',0
Includingempt.MSG:	dc.b	'Including empty source?',0
IncludeSource.MSG:	dc.b	'Include source jam',0
Unknownconver.MSG:	dc.b	'Unknown conversion mode, should be RB or RN',0
Unknowncmappl.MSG:	dc.b	'Unknown cmap place, should be (B)EFORE,(A)FTER or (N)ONE',0
Unknowncmapmo.MSG:	dc.b	'Unknown cmap mode, should be AGA or ECS',0
Tryingtoinclu.MSG:	dc.b	'Trying to include NON IFF file',0
IFFfileisnota.MSG:	dc.b	'IFF file is not an ILBM file',0
CanthandleaBO.MSG:	dc.b	'Can''t handle a BODY before BMHD chunk',0
WarningValues.MSG:	dc.b	'>> Warning << Value sign extended, resulting in negative',10,0
	IF	PPC
GeneralPurposeReg.MSG:	dc.b	'PPC General Purpose Register expected (R0..R31)',0
UnknowCPU.MSG:		dc.b	'Unknown CPU type, should be 000..060, PPC, or 603..604',0
	ELSE
UnknowCPU.MSG:		dc.b	'Unknown CPU type, should be 000..060',0
	ENDIF
StackFull.MSG:		DC.B	'Stack full, increase stack size',0

; NOTE: Only the last entry in these tables can have a different length.
WarningPrefix.MSG:
	DC.B	'>> Warning << ',0
WarningCpuLow.MSG:
	dc.b	'68010+ command used',0
.StrLen	dc.b	'68020+ command used',0
	dc.b	'68030+ command used',0
	dc.b	'68040+ command used',0
	dc.b	'68060+ command used',0
	dc.b	'Apollo command used',0
WarningSpecific.MSG:
	dc.b	'68010 specific command used',0
.StrLen	dc.b	'68020 specific command used',0
	dc.b	'68030 specific command used',0
	dc.b	'68040 specific command used',0
	dc.b	'68060 specific command used',0
	dc.b	'Apollo specific command used',0
WarningNotAvail.MSG:
	dc.b	'Command NOT available on 68010',0
.StrLen	dc.b	'Command NOT available on 68020',0
	dc.b	'Command NOT available on 68030',0
	dc.b	'Command NOT available on 68040',0
	dc.b	'Command NOT available on 68060',0
	dc.b	'Command NOT available on Apollo',0
Warning68851_Mmu.MSG:
	dc.b	'68851/68030 command used ',0
.StrLen	dc.b	'68851/68030+ command used',0
	dc.b	'68851/68040+ command used',0
	dc.b	'68851/68060+ command used',0
	dc.b	'68851/Apollo command used',0
Warning68881_2.MSG:
	dc.b	'68881/68882 command used',0
Warning68851.MSG:
	dc.b	'68851 command used',0


Illegalfloati.MSG:	dc.b	'Illegal floating point size, should be B,W,L,S,D,Q or P',0
Illegalsizefo.MSG:	dc.b	'Illegal size for data register, should be B,W,L or S',0
;BccWoutofrang.MSG:	dc.b	'Bcc.W out of range in macro',0		; unused
Floatingpoint.MSG:	dc.b	'Floating point register expected',0
ThisisnotaAsm.MSG:	dc.b	'Not an Asm-Pro project file',0
;Bitfieldcantb.MSG:	dc.b	'Bitfield can''t be out of 32 bit range',0	; unused

Insuficientme.MSG:	dc.b	'Insufficient memory to change source',0
	IF	Debugstuff
A4Debug.MSG:		dc.b	'A4 Debug: $',0
A4Debug2.MSG:		dc.b	'- $',0
A4DebugEol.MSG:		dc.b	10,0
	ENDIF

Open.MSG:		dc.b	'Open..',0
O.MSG:			dc.b	'O',0
SaveAs.MSG:		dc.b	'Save As..',0
ExitPreferenc.MSG:	dc.b	'Exit Preferences  ',0
Q.MSG:			dc.b	'Q',0
Edit.MSG:		dc.b	'Edit',0
ResettoDefaul.MSG:	dc.b	'Reset to Defaults',0
D.MSG:			dc.b	'D',0
LastNormalSav.MSG:	dc.b	'Last Normal Saved',0
L.MSG:			dc.b	'L',0
Workbench.MSG:		dc.b	'Workbench',0
ReqToolsLibra.MSG:	dc.b	'ReqTools Library',0
SaveMarks.MSG:		dc.b	'Save Marks',0
SourceASM.MSG:		dc.b	'Source .ASM',0
UpdateCheck.MSG:	dc.b	'Update Check',0
PrinterDump.MSG:	dc.b	'Printer Dump',0
WBtofront.MSG:		dc.b	'WB to front',0
ResidentRegis.MSG:	dc.b	'Resident Registers',0

;OneBitplane.MSG:	dc.b	'One Bitplane',0

Safety.MSG:		dc.b	'Safety',0
CloseWorkbenc.MSG:	dc.b	'Close Workbench',0
Parameters.MSG:		dc.b	'Parameters',0
ASCIIOnly.MSG:		dc.b	'ASCII Only',0
Disassembly.MSG:	dc.b	'Disassembly',0
ShowSource.MSG:		dc.b	'Show Source',0
EnablePermit.MSG:	dc.b	'Enable/Permit',0
Libcallsdec.MSG:	dc.b	'Libcalls dec',0
Realtimedeb.MSG:	dc.b	'Realtime debug',0
LineNumbers.MSG:	dc.b	'Line Numbers',0
AutoBackup.MSG:		dc.b	'Auto Backup',0
AutoUpdate.MSG:		dc.b	'Auto Update',0			
AutoIndent.MSG:		dc.b	'Auto Indent',0
ExtendedReqTo.MSG:	dc.b	'Ext. ReqTools',0
StartupWindow.MSG:	dc.b	'Show Startup win.',0
SyntaxColor.MSG:	dc.b	'Syntax Colors',0
CustomScroll.MSG:	dc.b	'Custom Scroll',0
WaitTof.MSG:		dc.b	'Scroll Sync',0
	IF SLIDER
Slider.MSG:		dc.b	'Slider',0
	ENDC
CTRLupdown.MSG:		dc.b	'CTRL up/down',0
Keepx.MSG:		dc.b	'Keep x',0
			dc.b	'Prefs:',0
GeneralParame.MSG:	dc.b	'General Parameters',0
MonitorDebugg.MSG:	dc.b	'Monitor / Debugger',0

nulstring:		dcb.b	2,0

Editor.MSG:		dc.b	'Editor',0
Save.MSG:		dc.b	'Save',0
Use.MSG:		dc.b	'Use',0
Cancel.MSG:		dc.b	'Cancel',0
DefaultDir.MSG:		dc.b	'Default Dir:',0
BootUp.MSG:		dc.b	'BootUp',0
SourceExtensi.MSG:	dc.b	'Source Extension',0
Selectnewscre.MSG:	dc.b	'Select screen mode',0
Selecteditorfont.MSG:	dc.b	'Select editor font',0
Assembler.MSG:		dc.b	'Assembler',0
Rescue.MSG:		dc.b	'Rescue',0
Level7.MSG:		dc.b	'Level 7',0
NumLock.MSG:		dc.b	'NumLock',0
PR_AutoAlloc.MSG:	dc.b	'Auto Alloc',0
Debug.MSG:		dc.b	'Debug',0
Multiscroll.MSG:	DC.B	'Multiscroll',0

;PlugIns.MSG:
;	dc.b	'Use Plugins',0

ListFile.MSG:		dc.b	'List File',0
Paging.MSG:		dc.b	'Paging',0
HaltFile.MSG:		dc.b	'Halt File',0
AllErrors.MSG:		dc.b	'All Errors',0
ProgressIndic.MSG:	dc.b	'Progress Indicator',0
ProgressbyLin.MSG:	dc.b	'Progress by Line',0
Label.MSG:		dc.b	'Label :',0
UCaseLCase.MSG:		dc.b	'UCase = LCase',0
CommentSemi.MSG:	dc.b	'; Comment',0
ProcessorWarn.MSG:	dc.b	'Processor Warn',0
CPU.MSG:		dc.b	'CPU',0
FPUPresent.MSG:		dc.b	'FPU Present',0
Odddata.MSG:		dc.b	'68020+ Odd data',0
DSClear.MSG:		dc.b	'DS Clear',0
Present.MSG:		dc.b	'68851 Present',0
Notenoughmemo.MSG0:	dc.b	'Not enough memory to open preferences window',0
PrefsSaved.MSG:		dc.b	' ENVARC:Asm-Pro.pref saved',0
PrefsLoaded.MSG:	dc.b	' ENVARC:Asm-Pro.pref (re)loaded',0

SREGSDATA.MSG:		dc.b	'AsmPro:REGSDATA',0
RegsDataSDir:		dc.b	'S:REGSDATA',0
ENVARCAsmProPref.MSG:	IF	Debugstuff
			dc.b	'ENVARC:Asm-Pro_beta.Pref',0
			ELSE
			dc.b	'ENVARC:Asm-Pro.Pref',0
			ENDIF
RecentName:		dc.b	"ENVARC:Asm-Pro.Rcnt",0
IncludeAssignName:	DC.B	'INCLUDE',0
IncludeAssign:		DC.B	'INCLUDE:',0

ReqToolsName:		dc.b	'reqtools.library',0

SyntColors.MSG:		dc.b	'Syntax Colors',0
SYNTLEV.MSG		dc.b	'Level',0
AsmPro.MSG:		DC.B	'Asm-Pro',0

	cnop	0,4
W1D006:
	dc.w	16
W1D008:
	dc.w	10
Prefs_win_br:
	dc.w	640-32
Prefs_win_hg:
	dc.w	220+14
W1D00E:
	dc.w	8
W1D010:
	dc.w	14
Prefs_win_br2:
	dc.w	640-16
Prefs_win_hg2:
	dc.w	168

;*************************************************
;************* Environment Preferences ***********

INITGDT	MACRO
_GDT_CTR	SET	0
	ENDM

MKGDT	MACRO	; struct NewGadget
\2		EQU 	_GDT_CTR
_GDT_CTR	SET	_GDT_CTR+1

	DC.W	0,0,0,0		; left, top, width, height
	DC.L	\1,0		; text, font
	DC.W	\2		; id
	DC.L	\3		; flags
	DC.L	0		; visual info
	IFNB	\4
	DC.L	\4		; user data
	ELSE
	DC.L	0		; user data
	ENDIF
	ENDM

;************* type gadgets env ************
Pref_EnvGadgetTypes:
	dc.w	BUTTON_KIND	 ;0
	dc.w	BUTTON_KIND	 ;1
	dc.w	BUTTON_KIND	 ;2
	dc.w	CHECKBOX_KIND	;03
	dc.w	CHECKBOX_KIND	; 4
	dc.w	CHECKBOX_KIND	; 5
	dc.w	CHECKBOX_KIND	; 6
	dc.w	CHECKBOX_KIND	; 7
	dc.w	CHECKBOX_KIND	; 8
	dc.w	CHECKBOX_KIND	; 9
	dc.w	CHECKBOX_KIND	;10
	dc.w	CHECKBOX_KIND	; 1
	dc.w	CHECKBOX_KIND	; 2
	dc.w	CHECKBOX_KIND	; 3
	dc.w	CHECKBOX_KIND	; 4
	dc.w	CHECKBOX_KIND	; 5
	dc.w	CHECKBOX_KIND	; 6
	dc.w	CHECKBOX_KIND	; 7
	dc.w	CHECKBOX_KIND	; 8
	dc.w	CHECKBOX_KIND	; 9
	dc.w	CHECKBOX_KIND	;20
	dc.w	CHECKBOX_KIND	; 1
	dc.w	CHECKBOX_KIND	; 2
	dc.w	CHECKBOX_KIND	; 3
	dc.w	CHECKBOX_KIND	; 4
	dc.w	CHECKBOX_KIND	; 5	;CustomScroll
	dc.w	CHECKBOX_KIND	; 6	;WaitTOF
	IF SLIDER
	dc.w	CHECKBOX_KIND	; 7	;Slider
	ENDIF
	dc.w	CHECKBOX_KIND	; 8	;LineNrs
	dc.w	CHECKBOX_KIND	; 9	;AutoBackup
	dc.w	CHECKBOX_KIND	 	;auto update

	dc.w	STRING_KIND	;30
	dc.w	STRING_KIND	;31
	dc.w	STRING_KIND	; 2
	dc.w	BUTTON_KIND	;33	;screen mode
	dc.w	BUTTON_KIND	;34	;wind font
	dc.w	TEXT_KIND	; 5	;bevel box
	dc.w	TEXT_KIND	; 6
	dc.w	TEXT_KIND	; 7
	dc.w	TEXT_KIND	; 8


env_gadspos:
	dc.w	03,19,8,1	;save
	dc.w	34,19,8,1	;use
	dc.w	64,19,8,1	;cancel

; negative y -> adjust y (+2px) to avoid overlap with bevel box
	dc.w	03,-01,1,0	;reqtools
	dc.w	03,-02,1,0	;savemarks
	dc.w	03,-03,1,0	;.asm
	dc.w	03,-04,1,0	;update
	dc.w	03,-05,1,0	;printdump

	dc.w	26,-01,1,0	;wb2front
	dc.w	26,-02,1,0	;res registers
	dc.w	26,-03,1,0	;safety
	dc.w	26,-04,1,0	;close wb
	dc.w	26,-05,1,0	;parameters

	dc.w	52,-01,1,0	;ascii only
	dc.w	52,-02,1,0	;disassembly
	dc.w	52,-03,1,0	;show source
	dc.w	52,-04,1,0	;enable/permit
	dc.w	52,-05,1,0	;libcalls dec
	dc.w	52,-06,1,0	;realtime deb

	dc.w	52,11,1,0	;ctrl up/down
	dc.w	52,12,1,0	;keep x
	dc.w	52,13,1,0	;auto indent.
	dc.w	52,14,1,0	;ext. reqtools

	dc.w	26,-06,1,0	;show startupwin

	dc.w	52,15,1,0	;syntax color
	dc.w	52,16,1,0	;custom scroll
	dc.w	52,17,1,0	;scroll sync
	IF SLIDER
	dc.w	52,09,1,0	;Slider
	ENDIF
	dc.w	52,10,1,0	;LineNrs

	dc.w	03,-06,1,0	;AutoBackup
	dc.w	03,-07,1,0	;auto update		

	dc.w	25,10,22,1	;default dir
	dc.w	25,12,22,1	;bootup
	dc.w	25,14,22,1	;source ext

	dc.w	25,16,22,1	;screenmode
	dc.w	03,16,21,1	;font select

	dc.w	01,01,48,7	;border params
	dc.w	50,01,23,6	;border mon/debug
	dc.w	50,09,23,9	;border editor
	dc.w	01,09,48,9	;border nix


	INITGDT
Env_prefs_gadstr:
	MKGDT	Save.MSG,EPG_save,PLACETEXT_IN
	MKGDT	Use.MSG,EPG_use,PLACETEXT_IN
	MKGDT	Cancel.MSG,EPG_cancel,PLACETEXT_IN
	MKGDT	ReqToolsLibra.MSG,EPG_rt,PLACETEXT_RIGHT
	MKGDT	SaveMarks.MSG,EPG_sm,PLACETEXT_RIGHT
	MKGDT	SourceASM.MSG,EPG_sa,PLACETEXT_RIGHT
	MKGDT	UpdateCheck.MSG,EPG_uc,PLACETEXT_RIGHT
	MKGDT	PrinterDump.MSG,EPG_pd,PLACETEXT_RIGHT
	MKGDT	WBtofront.MSG,EPG_wf,PLACETEXT_RIGHT
	MKGDT	ResidentRegis.MSG,EPG_rr,PLACETEXT_RIGHT
	MKGDT	Safety.MSG,EPG_st,PLACETEXT_RIGHT
	MKGDT	CloseWorkbenc.MSG,EPG_cw,PLACETEXT_RIGHT
	MKGDT	Parameters.MSG,EPG_pm,PLACETEXT_RIGHT
	MKGDT	ASCIIOnly.MSG,EPG_ao,PLACETEXT_RIGHT,1
	MKGDT	Disassembly.MSG,EPG_da,PLACETEXT_RIGHT,1
	MKGDT	ShowSource.MSG,EPG_ss,PLACETEXT_RIGHT,1
	MKGDT	EnablePermit.MSG,EPG_ep,PLACETEXT_RIGHT,1
	MKGDT	Libcallsdec.MSG,EPG_lc,PLACETEXT_RIGHT,1
	MKGDT	Realtimedeb.MSG,EPG_rd,PLACETEXT_RIGHT,1
	MKGDT	CTRLupdown.MSG,EPG_cud,PLACETEXT_RIGHT,1
	MKGDT	Keepx.MSG,EPG_kx,PLACETEXT_RIGHT,1
	MKGDT	AutoIndent.MSG,EPG_ai,PLACETEXT_RIGHT
	MKGDT	ExtendedReqTo.MSG,EPG_xr,PLACETEXT_RIGHT
	MKGDT	StartupWindow.MSG,EPG_sw,PLACETEXT_RIGHT
	MKGDT	SyntaxColor.MSG,EPG_sc,PLACETEXT_RIGHT
	MKGDT	CustomScroll.MSG,EPG_cs,PLACETEXT_RIGHT
	MKGDT	WaitTof.MSG,EPG_wt,PLACETEXT_RIGHT
	IF SLIDER
	MKGDT	Slider.MSG,EPG_sl,PLACETEXT_RIGHT
	ENDIF
	MKGDT	LineNumbers.MSG,EPG_ln,PLACETEXT_RIGHT
	MKGDT	AutoBackup.MSG,EPG_ab,PLACETEXT_RIGHT
	MKGDT	AutoUpdate.MSG,EPG_au,PLACETEXT_RIGHT
	MKGDT	DefaultDir.MSG,EPG_dir,PLACETEXT_LEFT
	MKGDT	BootUp.MSG,EPG_boot,PLACETEXT_LEFT
	MKGDT	SourceExtensi.MSG,EPG_ext,PLACETEXT_LEFT
	MKGDT	Selectnewscre.MSG,EPG_screen,PLACETEXT_IN
	MKGDT	Selecteditorfont.MSG,EPG_font,PLACETEXT_IN
	MKGDT	GeneralParame.MSG,EPG_bor1,PLACETEXT_ABOVE
	MKGDT	MonitorDebugg.MSG,EPG_bor2,PLACETEXT_ABOVE
	MKGDT	Editor.MSG,EPG_bor3,PLACETEXT_ABOVE
	MKGDT	nulstring,EPG_bor4,0

env_gadcount	=	(*-Env_prefs_gadstr)/gng_SIZEOF

;********* ENV PREFS GADS **************

Prefs_EnvGadTags:
	dc.l	0,-1			; 0
	dc.l	0,-1			; 1
	dc.l	0,-1			; 2
Prefs_EnvGadgets2:
	dc.l	GTCB_Checked,0,0,-1	;03
	dc.l	GTCB_Checked,0,0,-1	; 4
	dc.l	GTCB_Checked,0,0,-1	; 5
	dc.l	GTCB_Checked,0,0,-1	; 6
	dc.l	GTCB_Checked,0,0,-1	; 7
	dc.l	GTCB_Checked,0,0,-1	; 8
	dc.l	GTCB_Checked,0,0,-1	; 9
	dc.l	GTCB_Checked,0,0,-1	;10
	dc.l	GTCB_Checked,0,0,-1	; 1
	dc.l	GTCB_Checked,0,0,-1	; 2
	dc.l	GTCB_Checked,0,0,-1	; 3
	dc.l	GTCB_Checked,0,0,-1	; 4
	dc.l	GTCB_Checked,0,0,-1	; 5
	dc.l	GTCB_Checked,0,0,-1	; 6
	dc.l	GTCB_Checked,0,0,-1	; 7
	dc.l	GTCB_Checked,0,0,-1	; 8
	dc.l	GTCB_Checked,0,0,-1	; 9
	dc.l	GTCB_Checked,0,0,-1	;20
	dc.l	GTCB_Checked,0,0,-1	; 1
	dc.l	GTCB_Checked,0,0,-1	; 2
	dc.l	GTCB_Checked,0,0,-1	; 3	;Startup
	dc.l	GTCB_Checked,0,0,-1	; 4	;Syntaxcolor
	dc.l	GTCB_Checked,0,0,-1	; 5	;CustomScroll
	dc.l	GTCB_Checked,0,0,-1	; 6	;WaitTOF
	IF SLIDER
	dc.l	GTCB_Checked,0
;	dc.l	GA_Disabled,1
	dc.l	0,-1	; 7	Slider
	ENDIF
	dc.l	GTCB_Checked,0,0,-1	; 8	;Linenrs
	dc.l	GTCB_Checked,0,0,-1	; 9	;AutoBackup
	dc.l	GTCB_Checked,0,0,-1	; 9	;AutoUpDate 

	dc.l	GTST_MaxChars,127,GTST_String,HomeDirectory,0,-1	;30
	dc.l	GTST_MaxChars,253,GTST_String,BootUpString,0,-1		;31
	dc.l	GTST_MaxChars, 16,GTST_String,UserSrcExt.MSG,0,-1	; 2
	dc.l	0,-1			; 3	;screenmode
	dc.l	0,-1			;34	;window font
	dc.l	GTTX_Border,1,0,-1	; 5
	dc.l	GTTX_Border,1,0,-1	; 6
	dc.l	GTTX_Border,1,0,-1	; 7
	dc.l	GTTX_Border,1,0,-1	; 8


;************************************
;********** ASM PREFS ****************

;************* type gadgets ASM *********
Pref_AsmGadgetTypes:
	dc.w	BUTTON_KIND	;00 button
	dc.w	BUTTON_KIND	; 1
	dc.w	BUTTON_KIND	; 2

	dc.w	CHECKBOX_KIND	; 3 checkbox
	dc.w	CHECKBOX_KIND 	; 4
	dc.w	CHECKBOX_KIND	; 5
	dc.w	CHECKBOX_KIND	; 6
	dc.w	CHECKBOX_KIND	; 7
	dc.w	CHECKBOX_KIND	; 8
	dc.w	CHECKBOX_KIND	; 9
	dc.w	CHECKBOX_KIND	;10
	dc.w	CHECKBOX_KIND	; 1
	dc.w	CHECKBOX_KIND	; 2
	dc.w	CHECKBOX_KIND	; 3
	dc.w	CHECKBOX_KIND	; 4
	dc.w	CHECKBOX_KIND	; 5
	dc.w	CHECKBOX_KIND	; 6
	dc.w	CHECKBOX_KIND	; 7
	dc.w	CHECKBOX_KIND	; 8
	dc.w	CHECKBOX_KIND	; 9
	dc.w	CHECKBOX_KIND	;20
	dc.w	CHECKBOX_KIND	; 1
	DC.W	CHECKBOX_KIND	; 2
	dc.w	CYCLE_KIND	; 3 cycle
	dc.w	TEXT_KIND	; 4 box


asm_gadspos:
	dc.w	03,12,08,1	;save
	dc.w	34,12,08,1	;use
	dc.w	64,12,08,1	;cancel

	dc.w	4,02,1,1	;rescue
	dc.w	4,03,1,1	;level7
	dc.w	4,04,1,1	;numlock
	dc.w	4,05,1,1	;autoalloc
	dc.w	4,06,1,1	;debug
	DC.W	4,07,1,1	;multiscroll

	dc.w	25,02,1,1	;listfile
	dc.w	25,03,1,1	;paging
	dc.w	25,04,1,1	;haltfile
	dc.w	25,05,1,1	;allerrors
	dc.w	25,06,1,1	;procind
	dc.w	25,07,1,1	;byline
	dc.w	25,08,1,1	;dsclear

	dc.w	50,02,1,1	;label
	dc.w	50,03,1,1	;u=l
	dc.w	50,04,1,1	;comment
	dc.w	50,05,1,1	;proc warn
	dc.w	50,06,1,1	;fpu
	dc.w	50,07,1,1	;odd data
	dc.w	50,08,1,1	;mmu

	dc.w	06,09,14,1	;cpu type?

	dc.w	01,01,73,10	;border


	INITGDT
Asm_prefs_gadstr:
	MKGDT	Save.MSG,APG_save,PLACETEXT_IN
	MKGDT	Use.MSG,APG_use,PLACETEXT_IN
	MKGDT	Cancel.MSG,APG_cancel,PLACETEXT_IN

	MKGDT	Rescue.MSG,APG_Rescue,PLACETEXT_RIGHT
	MKGDT	Level7.MSG,APG_Level7,PLACETEXT_RIGHT
	MKGDT	NumLock.MSG,APG_NumLock,PLACETEXT_RIGHT
	MKGDT	PR_AutoAlloc.MSG,APG_AutoAlloc,PLACETEXT_RIGHT
	MKGDT	Debug.MSG,APG_Debug,PLACETEXT_RIGHT,1
	MKGDT	Multiscroll.MSG,APG_Multiscroll,PLACETEXT_RIGHT

	MKGDT	ListFile.MSG,APG_ListFile,PLACETEXT_RIGHT,1
	MKGDT	Paging.MSG,APG_Paging,PLACETEXT_RIGHT
	MKGDT	HaltFile.MSG,APG_HaltPage,PLACETEXT_RIGHT
	MKGDT	AllErrors.MSG,APG_AllErrors,PLACETEXT_RIGHT
	MKGDT	ProgressIndic.MSG,APG_Progress,PLACETEXT_RIGHT
	MKGDT	ProgressbyLin.MSG,APG_ProgByLine,PLACETEXT_RIGHT
	MKGDT	DSClear.MSG,APG_DsClear,PLACETEXT_RIGHT

	MKGDT	Label.MSG,APG_Label,PLACETEXT_RIGHT
	MKGDT	UCaseLCase.MSG,APG_Up_LowCase,PLACETEXT_RIGHT
	MKGDT	CommentSemi.MSG,APG_Comment,PLACETEXT_RIGHT
	MKGDT	ProcessorWarn.MSG,APG_Warning,PLACETEXT_RIGHT
	MKGDT	FPUPresent.MSG,APG_FPU_Present,PLACETEXT_RIGHT
	MKGDT	Odddata.MSG,APG_OddData,PLACETEXT_RIGHT
	MKGDT	Present.MSG,APG_MMU,PLACETEXT_RIGHT

	MKGDT	CPU.MSG,APG_CPU,PLACETEXT_LEFT

	MKGDT	Assembler.MSG,APG_WIN,PLACETEXT_ABOVE

asm_gadcount	=	(*-Asm_prefs_gadstr)/gng_SIZEOF

;************* ASM Gad tags **************

Prefs_AsmGadTags:
	dc.l	0,-1			;00 save
	dc.l	0,-1			; 1 use
	dc.l	0,-1			; 2 cancel
Prefs_AsmGadgets2:
	dc.l	GTCB_Checked,0,0,-1	; 3
	dc.l	GTCB_Checked,0,0,-1	; 4
	dc.l	GTCB_Checked,0,0,-1	; 5
	dc.l	GTCB_Checked,0,0,-1	; 6
	dc.l	GTCB_Checked,0,0,-1	; 7
	dc.l	GTCB_Checked,0,0,-1	; 8
	dc.l	GTCB_Checked,0,0,-1	; 9
	dc.l	GTCB_Checked,0,0,-1	;10
	dc.l	GTCB_Checked,0,0,-1	; 1
	dc.l	GTCB_Checked,0,0,-1	; 2
	dc.l	GTCB_Checked,0,0,-1	; 3
	dc.l	GTCB_Checked,0,0,-1	; 4
	dc.l	GTCB_Checked,0,0,-1	; 5
	dc.l	GTCB_Checked,0,0,-1	; 6
	dc.l	GTCB_Checked,0,0,-1	; 7
	dc.l	GTCB_Checked,0,0,-1	; 8
	dc.l	GTCB_Checked,0,0,-1	; 9
	dc.l	GTCB_Checked,0,0,-1	;20
	dc.l	GTCB_Checked,0,0,-1	; 1
	DC.L	GTCB_Checked,0,0,-1	; 2

	dc.l	GTCY_Labels,Prefs_CpuTable
	dc.l	GTCY_Active
	dc.w	0
Prefs_AsmCpuType:
	dc.w	0
	dc.l	0,-1

	dc.l	GTTX_Border,1,0,-1	; 3

;************************************
;********** SYNTCOL PREFS ***********

Pref_SyntGadgetTypes:
	DC.W	BUTTON_KIND
	DC.W	BUTTON_KIND
	DC.W	BUTTON_KIND
	dc.w	TEXT_KIND	 	;box
	DC.W	CYCLE_KIND
	DC.W	PALETTE_KIND
	DC.W	PALETTE_KIND
	DC.W	LISTVIEW_KIND

synt_gadspos:
	dc.w	03,12,08,1	;0 save
	dc.w	34,12,08,1	;1 use
	dc.w	64,12,08,1	;2 cancel

	dc.w	19,01,55,10	;3 border

	dc.w	01,01,17,01	;4 synt color level?

	dc.w	01,09,08,02	;5 front palet
	dc.w	10,09,08,02	;6 back palet

	dc.w	01,03,17,04	;7 list view


	INITGDT
Synt_prefs_gadstr:
	MKGDT	Save.MSG,SPG_save,PLACETEXT_IN
	MKGDT	Use.MSG,SPG_use,PLACETEXT_IN
	MKGDT	Cancel.MSG,SPG_cancel,PLACETEXT_IN

	MKGDT	SyntColors.MSG,SPG_WIN,PLACETEXT_ABOVE
	MKGDT	SYNTLEV.MSG,SPG_SYNT,PLACETEXT_ABOVE
	MKGDT	syntFrontText,SPG_FRONT,PLACETEXT_ABOVE
	MKGDT	syntBackText,SPG_BACK,PLACETEXT_ABOVE
	MKGDT	syntAttrText,SPG_ATTR,0

synt_gadcount	=	(*-Synt_prefs_gadstr)/gng_SIZEOF

;************* SYNT prefs *************

Prefs_SyntGadTags:
	dc.l	TAG_DONE,-1		; 0 save
	dc.l	TAG_DONE,-1		; 1 use
	dc.l	TAG_DONE,-1		; 2 cancel

	dc.l	GTTX_Border,1	 	; 3 brder
	DC.L	TAG_DONE,-1

;Prefs_SyntGadgets2:			; 4 listbox
	dc.l	GTCY_Labels,Prefs_SyntTable
	dc.l	GA_Disabled,1
	dc.l	GTCY_Active
	dc.w	0
Prefs_SyntType:
	dc.w	2
	dc.l	TAG_DONE,-1

	DC.L	GTPA_Depth
	dc.w	0
SyntNrCols1:
	dc.w	2
	dc.l	GTPA_Color
	dc.w	0
Prefs_SyntFront:
	dc.w	1
	dc.l	GTPA_ColorOffset,0
.Indicator
	dc.l	GTPA_IndicatorWidth,8	; must be last tag!
	dc.l	TAG_DONE,-1		; 5 Front palette

	DC.L	GTPA_Depth
	dc.w	0
SyntNrCols2:
	dc.w	2
	dc.l	GTPA_Color
	dc.w	0
Prefs_SyntBack:
	dc.w	0
	dc.l	GTPA_ColorOffset,0
.Indicator
	dc.l	GTPA_IndicatorWidth,8	; must be last tag!
	dc.l	TAG_DONE,-1		; 6 Back palette

	DC.L	GTLV_Labels,syntAttrList
	dc.l	GTLV_ShowSelected,0
	dc.l	GTLV_Selected,0
	dc.l	TAG_DONE,-1		; 7 example text


syntAttrNodes0:
	DC.L	syntAttrNodes1
	DC.L	syntAttrList
	DC.B	0,0
	DC.L	syntAttrName0

syntAttrNodes1:
	DC.L	syntAttrNodes2
	DC.L	syntAttrNodes0
	DC.B	0,0
	DC.L	syntAttrName1

syntAttrNodes2:
	DC.L	syntAttrNodes3
	DC.L	syntAttrNodes1
	DC.B	0,0
	DC.L	syntAttrName2

syntAttrNodes3:
	DC.L	syntAttrList+4
	DC.L	syntAttrNodes2
	DC.B	0,0
	DC.L	syntAttrName3

syntAttrList:	; struct MinList (no type/pad)
	DC.L	syntAttrNodes0,0,syntAttrNodes3

syntFrontText:
	DC.B	'Front',0
syntBackText:
	DC.B	'Back',0
syntAttrName3:
	DC.B	'Opcodes',0
syntAttrName0:
	DC.B	'Rest o/t Source',0
syntAttrName1:
	DC.B	'Comments',0
syntAttrName2:
	DC.B	'Labels',0
syntAttrText:
	DC.B	0

sc0_txt:	dc.b	'Comments',0
sc1_txt:	dc.b	'Comm/Labels',0
sc2_txt:	dc.b	'Full',0
;sc3_txt:	dc.b	'Extended',0
	EVEN

Prefs_SyntTable:
	dc.l	sc0_txt
	dc.l	sc1_txt
	dc.l	sc2_txt
;	dc.l	sc3_txt
	dc.l	0

;**************************************

Prefswin_taglist:
	dc.l	WA_Left
Prefs_winleft:
	dc.l	0
	dc.l	WA_Top
Prefs_wintop:
	dc.l	0
	dc.l	WA_Width
Prefs_winbreedt:
	dc.l	0
	dc.l	WA_Height
Prefs_winhoog:
	dc.l	0
	dc.l	WA_IDCMP,IDCMP_CLOSEWINDOW|IDCMP_MENUPICK|IDCMP_GADGETUP|IDCMP_REFRESHWINDOW
	dc.l	WA_Flags,WFLG_DRAGBAR|WFLG_DEPTHGADGET|WFLG_CLOSEGADGET|WFLG_ACTIVATE|WFLG_NEWLOOKMENUS
	dc.l	WA_Gadgets
Prefs_wingadgets:
	dc.l	0
	dc.l	WA_Title
Prefs_wintitle:
	dc.l	AsmProEnviron.MSG
	dc.l	WA_CustomScreen
ScreenBaseTemp1:
	dc.l	0
	dc.l	WA_MinWidth,$00000043
	dc.l	WA_MinHeight,$00000015
	dc.l	WA_MaxWidth,$00000280
	dc.l	WA_MaxHeight,$00000100
	dc.l	WA_Activate,TRUE
	dc.l	TAG_DONE

ScreenmodeTags:
	dc.l	RTSC_Flags,SCREQF_DEPTHGAD|SCREQF_OVERSCANGAD|SCREQF_GUIMODES|SCREQF_SIZEGADS
;	dc.l	RTSC_ModeFromScreen
;.screen:
;	dc.l	0
	dc.l	RTSC_MaxDepth,4
	dc.l	RTSC_MinWidth,640
	dc.l	RTSC_MinHeight,200
;.depth:
	dc.l	RTSC_DisplayDepth,2
	dc.l	TAG_DONE

Pleaseselectp.MSG:
	dc.b	'Please select preferred screenmode',0
AsmProEnviron.MSG:
	dc.b	'Asm-Pro - Environment Preferences',0
AsmProAsmPrefs:
	dc.b	'Asm-Pro - Assembler Preferences',0
AsmProSyntPrefs:
	dc.b	'Asm-Pro - Syntax Color Preferences',0
	EVEN

Prefs_newmenustr:
	MKMENU	NM_TITLE,Project.MSG
		MKMENU	NM_ITEM,Open.MSG,O.MSG
		MKMENU	NM_ITEM,SaveAs.MSG,A.MSG
		MKMENU	NM_ITEM,NM_BARLABEL
		MKMENU	NM_ITEM,ExitPreferenc.MSG,Q.MSG
	MKMENU	NM_TITLE,Edit.MSG
		MKMENU	NM_ITEM,ResettoDefaul.MSG,D.MSG
		MKMENU	NM_ITEM,LastNormalSav.MSG,L.MSG
	MKMENUEND

Prefs_CpuTable:
	dc.l	mc00_txt
	dc.l	mc10_txt
	dc.l	mc20_txt
	dc.l	mc30_txt
	dc.l	mc40_txt
	dc.l	mc60_txt
	dc.l	N50_txt
	dc.l	0

mc00_txt:
	dc.b	'68000',0
mc10_txt:
	dc.b	'68010',0
mc20_txt:
	dc.b	'68020',0
mc30_txt:
	dc.b	'68030',0
mc40_txt:
	dc.b	'68040',0
mc60_txt:
	dc.b	'68060',0
N50_txt:
	dc.b	'Apollo',0

	even
firstmenu_taglist:
prefs_menutags:
	dc.l	GTMN_NewLookMenus,1,TAG_DONE

;******** ENV **********

env_prefsptrs:
	dc.l	epp_reqtools		;03
	dc.l	epp_savemarks		; 4
	dc.l	epp_sourcext		; 5
	dc.l	epp_updatecheck		; 6
	dc.l	epp_printdump		; 7
	dc.l	epp_wb2front		; 8
	dc.l	epp_resregs		; 9
	dc.l	epp_safety		;10
	dc.l	epp_closewb		; 1
	dc.l	epp_parameters		; 2
	dc.l	epp_asciionly		; 3
	dc.l	epp_disassembly		; 4
	dc.l	epp_showsource		; 5
	dc.l	epp_enablepermit	; 6
	dc.l	epp_libcallsdec		; 7
	dc.l	epp_debugrealt		; 8
	dc.l	epp_ctrlupdown		; 9
	dc.l	epp_keepx		;20
	dc.l	epp_autoindent		; 1
	dc.l	epp_extreqtools		; 2
	dc.l	epp_startup		; 3
	dc.l	epp_syntaxcolor		; 4
	dc.l	epp_customscroll	; 5
	dc.l	epp_waittof		; 6
	IF SLIDER
	dc.l	epp_slider		; 7
	ENDIF
	dc.l	epp_linenrs		; 8
	dc.l	epp_autobackup		; 9
	dc.l	epp_autoupdate				

;******** ASM **********

asm_prefsptr:
	dc.l	app_rescue		;03
	dc.l	app_level7		; 4
	dc.l	app_numlock		; 5
	dc.l	app_autoalloc		; 6
	dc.l	app_debug		; 7
	DC.L	app_multiscroll		; 8
	dc.l	app_listfile		; 9
	dc.l	app_paging		;10
	dc.l	app_haltpage		; 1
	dc.l	app_allerrors		; 2
	dc.l	app_procindic		; 3
	dc.l	app_procline		; 4 
	dc.l	app_dsclear		; 5
	dc.l	app_labelcolon		; 6
	dc.l	app_upislow		; 7
	dc.l	app_comment		; 8
	dc.l	app_warning		; 9
	dc.l	app_fpu		 	;20
	dc.l	app_oddadrs		; 1
	dc.l	app_mmu			; 2

epp_reqtools:		dc.w	$0100
epp_savemarks:		dc.w	$0100
epp_sourcext:		dc.w	$0100
epp_updatecheck:	dc.w	$0100
epp_printdump:		dc.w	$0100
epp_wb2front:		dc.w	$0100
epp_resregs:		dc.w	$0100
epp_safety:		dc.w	$0100
epp_closewb:		dc.w	$0100
epp_parameters:		dc.w	$0100
epp_asciionly:		dc.w	$0100
epp_disassembly:	dc.w	$0100
epp_showsource:		dc.w	$0100
epp_enablepermit:	dc.w	$0100
epp_libcallsdec:	dc.w	$0100
epp_debugrealt:		dc.w	$0100
epp_ctrlupdown:		dc.w	$0100
epp_keepx:		dc.w	$0100
epp_autoindent:		dc.w	$0100
epp_extreqtools:	dc.w	$0100
epp_startup:		dc.w	$0100
epp_syntaxcolor:	dc.w	$0100
epp_customscroll:	dc.w	$0100
epp_waittof:		dc.w	$0100
	IF SLIDER
epp_slider:		dc.w	$0100
	ENDIF
epp_linenrs:		dc.w	$0100
epp_autobackup:		dc.w	$0100
epp_autoupdate:		dc.w	$0100		

app_rescue:		dc.w	$0100
app_level7:		dc.w	$0100
app_numlock:		dc.w	$0100
app_autoalloc:		dc.w	$0100
app_debug:		dc.w	$0100
app_multiscroll:	DC.W	$0100
app_listfile:		dc.w	$0100
app_paging:		dc.w	$0100
app_haltpage:		dc.w	$0100
app_allerrors:		dc.w	$0100
app_procindic:		dc.w	$0100
app_procline:		dc.w	$0100
app_dsclear:		dc.w	$0100
app_labelcolon:		dc.w	$0100
app_upislow:		dc.w	$0100
app_comment:		dc.w	$0100
app_warning:		dc.w	$0100
app_fpu:		dc.w	$0100
app_oddadrs:		dc.w	$0100
app_mmu:		dc.w	$0100
;app_1bpl:		dc.w	$0000	; unused


DefaultPrefs:
	dc.w	$0100	;PR_ReqLib
	dc.w	$0100	;PR_SaveMarks:
	dc.w	$0100	;PR_SourceExt:
	dc.w	$0100	;PR_UpdateAlways:
	dc.w	$0000	;PR_PrintDump:
	dc.w	$0000	;PR_WBFront:
	dc.w	$0100	;PR_RegsRes:
	dc.w	$0100	;PR_Safety:
	dc.w	$0000	;PR_CloseWB:
	dc.w	$0000	;PR_params:
	dc.w	$0100	;PR_OnlyAscii:
	dc.w	$0000	;PR_NoDisasm:
	dc.w	$0100	;PR_ShowSource:
	dc.w	$0100	;PR_Enable_Permit
	dc.w	$0000	;PR_LibCalDec:
	dc.w	$0000	;PR_RealtimeDebug
	dc.w	$0100	;PR_CtrlUp_Down:
	dc.w	$0100	;PR_Keepxy:
	dc.w	$0100	;PR_AutoIndent:
	dc.w	$0000	;PR_ExtReq:
	dc.w	$0100	;PR_Startup:
	dc.w	$0100	;PR_SyntaxColor:
	dc.w	$0000	;PR_CustomScroll:
	dc.w	$0000	;PR_WAITTOF:
	IF SLIDER
	dc.w	$0000	;PR_SLIDER:
	ENDIF
	dc.w	$0000	;PR_LINENRS:
	dc.w	$0100	;PR_AutoBackup:
	dc.w	$0000	;PR_AutoUpdate			

	dc.w	$0100	;PR_Rescue:
	dc.w	$0000	;PR_Level7:
	dc.w	$0000	;PR_NumLock:
	dc.w	$0100	;PR_AutoAlloc:
	dc.w	$0100	;PR_Debug:
	DC.W	$0000	;PR_Multiscroll
	dc.w	$0000	;PR_ListFile:
	dc.w	$0100	;PR_Paging:
	dc.w	$0100	;PR_HaltPage:
	dc.w	$0000	;PR_AllErrors:
	dc.w	$0100	;PR_Progress:
	dc.w	$0000	;PR_ProgressLine
	dc.w	$0000	;PR_DsClear:
	dc.w	$0000	;PR_Label:
	dc.w	$0000	;PR_Upper_LowerCase
	dc.w	$0000	;PR_Comment:
	dc.w	$0000	;PR_Warning:
	dc.w	$0100	;PR_FPU_Present:
	dc.w	$0000	;PR_OddData:
	dc.w	$0000	;PR_MMU

;	dc.w	$0000	;1bitplane	; unused

	CNOP	0,4
realend3:

;***********************************************
;**             VARIABLES SECTION             **
;***********************************************

;	SECTION	variabelen_stuff,BSS

DT:
Variable_base:
		DS.B	'a'
ALPHA_ONE:	DS.B	256-'a'

XDefTreePtr:	ds.l	1

NrOfErrors:	ds.w	1

;---  Response struct  ---
ResponseType:	ds.w	1
ResponsePtr:	ds.l	1

WorkBuffer:	DS.L	1	; for fmove and fmovem
help:		DS.L	1

TraceLinePtr:	ds.l	1
TraceLineNr:	ds.l	1

ConditionBuffer:ds.b	MAX_CONDITION_LEVEL
	CNOP	0,4
ConditionBufPtr:ds.l	MAX_CONDITION_LEVEL
ConditionLevel:	ds.w	1

Asm_HaveWatches:	DS.B	1
Asm_OffsetCheck:	DS.B	1

Asm_Table_Base:	ds.l	1

;***  Local label area  ***

StackBottom:	DS.L	1
CurrentLocalPtr:ds.l	1

StrippedHunkLength:	DS.L	1
StripTrailingZeroes:	DS.B	1

FilenameBuffSelect:	DS.B	1

;*********************************
;*    SECTION structure layout   *
;*********************************

LastSection:	ds.w	1
CurrentSection:	ds.w	1
NrOfSections:	ds.w	1

	CNOP	0,4
SectionTreePtr:		ds.l	1
INSTRUCTION_ORG_PTR:	DS.L	1

SECTION_CONV_AREA:	DS.B	256

;***  Section Block  ***

	CNOP	0,4
SECTION_START_DEFINITION:DS.L	2+1	; fake symbol table root
SECTION_ABS_LOCATION:	ds.l	256
SECTION_ORG_ADDRESS:	ds.l	256
SECTION_TYPE_TABLE:	ds.b	256
SECTION_OLD_ORG_ADDRESS:ds.l	256

; Add +1 for _C(HIP), +2 for _F(AST), +$40 if allocated:
; CODE = 0
; DATA = 4
; BSS  = 8+$80

CURRENT_ABS_ADDRESS:	ds.l	1
LabelXrefName:	ds.l	1

Binary_Offset:	ds.l	1

UsedRegs:	ds.w	1
OpperantSize:	ds.b	1
CURRENT_SECTION_TYPE:	ds.b	1

DATA_WINDOWPTR:	ds.l	1
DATA_TASKPTR:	ds.l	1

DAIRYIN:	ds.w	2	; next/newest
DAIRYOUT:	ds.w	1

MEMDIR_ANTAL:	ds.w	1

ExecCmd_AnyKeyBuffer:		; 1 byte, read buffer
AsmStartTime:	DS.B	TV_SIZE	; 2 lwords

;***  Memory Area Pointers  ***

	CNOP	0,4
LAST_LABEL_ADDRESS:	ds.l	1
WORK_START:	ds.l	1
sourcestart:	ds.l	1
sourceend:	ds.l	1
LabelStart:	ds.l	1
LPtrsEnd:	ds.l	1
LabelEnd:	ds.l	1
DEBUG_END:	ds.l	1
RelocStart:	ds.l	1
RelocEnd:	ds.l	1
CodeStart:	ds.l	1
Cut_Blok_End:	ds.l	1
WORK_ENDTOP:	ds.l	1
WORK_END:	ds.l	1

DATA_CURRENTLINE:	ds.l	1
DATA_LINE_START_PTR:	ds.l	1

Bootblock:	DS.L	1

;***  Editor & Screen constants  ***

JumpLineNr:	DS.L	1

Edit_begin:	ds.l	1
NrOfLinesInEditor_min1:	ds.w	1
Max_Hoogte:	ds.w	1
aantal_regels_min3_div2:
		ds.w	1
aantal_regels_min2:
		ds.w	1
aantal_regels_min3:
		ds.w	1
breedte_editor_in_chars:
		ds.w	1
NumLines_Editor:
		ds.w	1
NumLines_HalfEditor:
		ds.w	1
NrOfLinesInEditor:
		ds.l	1
SCROLLOKFLAG:	DS.B	1	; 3-state: <0 always print, >0 never, =0 check
Asm_Multiscroll:	DS.B	1

	EVEN
Cursor_pos:
Cursor_col_pos:	ds.w	1	; these 2 are a pair
cursor_row_pos:	ds.w	1

menu_char_pos:	ds.w	1

FirstLinePtr:	ds.l	1
FirstLineNr:	ds.l	1	;was w
LineFromTop:	ds.l	1	;was w
ScreenHight:	ds.w	1
PageNumber:	ds.w	1
PageHeight:	ds.w	1
PageWidth:	ds.w	1
PageLinesLeft:	ds.w	1

NewCursorpos:	ds.w	1

reset_pos:	DS.W	2

Comm_menubase:	ds.l	1	; these 4 must be together
Edit_Menubase:	ds.l	1
Moni_MenuBase:	ds.l	1
Debug_MenuBase:	ds.l	1

MenuStrip:	DS.L	1

Fontbase_edit:	ds.l	1
fontreq:	DS.L	1
FileReqBase:	ds.l	1

ViewPortBase:	ds.l	1
Rastport:	ds.l	1
MainVisualInfo:	ds.l	1

; login window values
_absmax:	ds.l	1
_pubmax:	ds.l	1
_chipmax:	ds.l	1
_fastmax:	ds.l	1
_StackSize:	ds.l	1
_memtype:	ds.l	1
_memamount:	ds.l	1
_absmemadr:	ds.l	1

;***  Short Access Data Area  ***

SomeBits:	ds.b	1
SomeBits2:	ds.b	1
SomeBits3:	ds.b	1
SomeBits2Backup:ds.b	1

;***  Libs and devices  ***

	CNOP	0,4
DosBase:	ds.l	1
PrinterBase:	ds.l	1
GfxBase:	ds.l	1
IntBase:	ds.l	1
MathFfpBase:	ds.l	1
MathTransBase:	ds.l	1
GadToolsBase:	ds.l	1
AslBase:	ds.l	1
ReqToolsbase:	ds.l	1
DiskfontBase:	ds.l	1
TrackdiskUnit:	DS.L	1

;***  DisAssemble data area  ***

MON_DATA_MARK1:		ds.l	1
MON_DATA_MARK2:		ds.l	1
MON_DATA_MARK3:		ds.l	1
MON_LAST_LONG_ADDR:	ds.l	1
MON_LAST_BUFFER:	ds.l	16
MON_TYPE_PTR:		ds.l	1
MON_LAST_NUM:		ds.w	1
MON_EDIT_POSITION:	ds.w	1

DIS_PRINT_BUFFER:	; addr/8 " " hex/20 " " opcode/12 operands/36 " " 0
.Hex		DS.B	20
.HexEnd		DS.B	1
.Instr		DS.B	48
.InstrEnd	DS.B	1
.End		DS.B	1+30

MemDumpSize:	ds.b	1
MON_CACH_ADDRESS:	ds.l	1
MON_CACH_AREA:		ds.w	CACH_LEN/2

;***  Debugger area  ***

SST_STEPS:	ds.w	1
RESCUE_4REGS:	ds.l	4

MEM_DIS_DUMP_PTR:ds.l	1

SaveBin_Start:	ds.l	1
SaveBin_End:	ds.l	1
SaveBin_StartEndSet: DS.W	1
	IF	MEMSEARCH
mon_StartSize:	DS.W	1
mon_StartAdr:	DS.L	1
mon_StartValue:	DS.L	1
	ENDIF
	CNOP	0,4
debug_winbase:	DS.L	1
debug_rp:	DS.L	1
debug_msg_port:	DS.L	1

DATA_BUSACCESS:	ds.w	1
DATA_BUSPTRHI:	ds.w	1
DATA_BUSPTRLO:	ds.w	1
DATA_BUSFAILINST:ds.w	1

DataRegsStore:	ds.l	8		; regs must be in this order
AdresRegsStore:	ds.l	7
SSP_base:	ds.l	1
USP_base:	ds.l	1
statusreg_base:	ds.w	1
pcounter_base:	ds.l	1

DataRegsStore_Old:
		ds.l	8
AdrRegsStore_Old:
		ds.l	7
		ds.l	1
		ds.l	1
		ds.w	1
		ds.l	1

BREAKPTBUFFER:	DS.W	16*(2+1)	; ptr/opcode pairs

EXHA_3Regs:	ds.l	3
DBTypePtr:	ds.l	1
Dbg_Param:	ds.b	256

DATA_SUPERSTACKPTR:	ds.l	1
DATA_USERSTACKPTR:	ds.l	1
DATA_EXCEPTIONNUMBER:	ds.b	1

db_type:	DS.B	1	; 0=norm ~0=fp

	EVEN
IntDisableCnt:	ds.b	1	; these 2 must be together as a word
TaskDisableCnt:	ds.b	1

Animate:	ds.b	1
debug_FPregs:	ds.b	1

DEBUG_NUMOFADDS:ds.w	1
Dbg_NumCondBPs:	ds.w	1

watch_table_name:	ds.b	8*16
watch_table_addr:	ds.l	8
watch_table_type:	ds.b	8
L1A3F4:		ds.b	8*16
L1A474:		ds.b	8*16
L1A4F4:		ds.l	8
L1A514:		ds.l	8
L1A534:		ds.b	8
L1A53C:		ds.b	8

;****  LABEL DATA PTRS  ****

LabelRollValue:	ds.w	1
Label1Entry:	ds.w	1
Label2Entry:	ds.w	1
DATA_NUMOFGLABELS:	ds.w	1

;***  Macro data area  ***

SPECIAL_SYMBOL_NARG:
		DS.L	2		; prev/next
		DS.W	2		; name (4 chars), flags/section
		DS.W	1		; value, high word
NARG_VALUE:	DS.W	1		;  low word
SPECIAL_SYMBOL_REPTN:
		DS.L	2		; prev/next
		DS.W	(5+1)/2		; name (5 chars), flags/section
REPTN_VALUE:	DS.L	1		; value
SPECIAL_SYMBOL_ASMPRO:
		DS.W	4+6/2+2		; name 6 chars

MACRO_LEVEL:		ds.w	1
MACRO_ActiveID:		DS.L	1
MACRO_LOCALNR:		ds.w	2
MACRO_LINEBUFFER:	ds.b	200

	EVEN
ProcessIOPtrs:			; 3 longs
Filesize_TmpPath:
MACRO_LINEBUFFER_SYM:	ds.b	100
CURRENT_MACRO_ARG_PTR:	ds.l	1

EDMACRO_BUFFER:	ds.b	256
EDMACRO_BUFPTR:	DS.W	1

;***  Rescue Data Area  ***
GEMINT:		ds.w	1
GEMDMA:		ds.w	1
GEMDISK:	ds.w	1

	CNOP	0,4
JUMPPTR:	ds.l	1

Copperlist1:	ds.l	1
Copperlist2:	ds.l	1

RESCUEPTRS:	ds.l	29
RESCUEPTRS_Last:ds.l	1

;***  Input buffer area  ***

SourceCode:	DS.B	100
CurrentAsmLine:	DS.B	DSIZE+1+FCHARS+1	; = 162

	CNOP	0,4
DIR_ARRAY:	ds.b	DSIZE*(10+1)
		cnop	1,1
DIR_ARRAY2:	ds.b	$0083
FILE_ARRAY2:	ds.l	7
		ds.w	1
		ds.b	1
DIR_ARRAY3:	ds.b	$0083
FILE_ARRAY3:	ds.l	8

	CNOP	0,4
TITLE_STRING:		ds.l	60/4
IDNT_STRING:		ds.l	60/4
TextPrintBuffer:	ds.l	1000/4
text_buf_ptr:		ds.l	1	; must be at the end of TextPrintBuffer

RecentFilesNbr:		DS.B	1

Comm_Char:	ds.b	1

;***  Include data  ***

IncludeAssignStatus:	DS.W	1
NUM_INCLUDES:		DS.W	1
INCLUDE_LEVEL:		ds.w	1
FIRST_INCLUDE_PTR:	ds.l	1
INCLUDE_CONSUMPTION:	ds.l	1
INCLUDE_DIRECTORY:	ds.l	100/4

INSERT_START:		ds.l	1
INSERT_END:		ds.l	1

Math_Level:		ds.w	1
Have_DBCC:		DS.B	1
BASEREG_BYTE:		ds.b	1
	EVEN
BASEREG_BASE:		DS.B	8*(2+4)
OFFSET_BASE_ADDRESS:	ds.l	1
TEMP_CONT_PTR:		ds.l	1
TEMP_STACKPTR:		ds.l	1
RS_BASE_OFFSET:		ds.l	1

REPT_LEVEL:	ds.w	1
REPT_STACK:	ds.b	MAX_REPT_LEVEL*22	; src_ptr, ln_num, flags/sect, ctr, out_ctr, block_addr

Asm_ActiveSrcNr:	DS.B	1

;***  I/O areas ^ ptrs  ***
	CNOP	0,4
Error_Jumpback:		ds.l	1
Error_Jumpback_Old:	ds.l	1

FileLength:	ds.l	1

CurrentDir:	DS.L	1
Bestand:	ds.l	1
RedirectHandle:	ds.l	1

PtrRegsData:	DS.L	1

ProgressPerc:	ds.w	1
ProgressCntr:	ds.w	1
ProgressSpeed:	ds.w	1

TRACK_COMMAND:	ds.w	1
TRACK_LENGTH:	ds.l	1
TRACK_BUFFER:	ds.l	1
TRACK_POINTER:	ds.l	1

SEGMENTLENGTH:	ds.l	1
SEGMENTADDRESS:	ds.l	1

AG_dirlock:	DS.L	1

DATA_WRITEREQUEST2:	ds.l	20
DATA_REPLYPORT:		ds.l	8

	IF	CLIPBOARD
ClipMsgport:	ds.l	1
ClipIoReq:	ds.l	1
dataheader:	ds.b	20
	ENDIF

;***  Keyboard data area  ***

	CNOP	0,4
MainWindowHandle:ds.l	1

KeyboardInOutBuffs:		; in/out pair
KeyboardInBuf:	ds.w	1	; these 3 have the upper byte 0
KeyboardOutBuf:	ds.w	1
KEYB_KILLPTR:	ds.w	1

edit_EscCode:	ds.b	1
BreakKey:	ds.b	1
OwnKeyBuffer:	ds.b	256

ConIOReq:	DS.B	IOSTD_SIZE
KEY_BUFFER:	ds.b	16
KEY_PORT:	ds.l	1
KEY_MSG:	ds.l	1

MY_EVENT:	ds.b	ie_SIZEOF

PaletteStatus:	DS.B	1
FontChanged:	DS.B	1

;***  DIR DATA AREA  ***

; from ParameterBlok to UserStackEnd, must be kept together (read buffer)
	CNOP	0,4
ParameterBlok:	DS.B	fib_SIZEOF
MEMDIR_BUFFER:	ds.b	4+30		; header+filename
L2C05E:		ds.l	1
L2C062:		ds.l	2
L2C06A:		ds.b	USERPRG_STACK_SIZE-(*-ParameterBlok)
SuperStackEnd:	DS.B	USERPRG_STACK_SIZE
UserStackEnd:

; create/insert sine parameters
SinAddr:	ds.l	1
SinBegin:	ds.l	1
SinEnd:		ds.l	1
SinAmount:	ds.l	1
SinAmp:		ds.l	1
SinYOff:	ds.l	1
SinMult:	ds.l	1
L2DF78:		ds.l	1
L2DF7C:		ds.l	1
L2DF80:		ds.l	1
SinSize:	ds.b	1

SinCorr:			; keep these 2 together
SinCorrHalf:	ds.b	1

SinCorrRound:	ds.b	1

MenuStripChanged:	DS.B	1

	EVEN
FileNaam:	ds.b	254
HomeDirectory:	ds.b	253
HomeDirSet:	ds.b	1
TempDirName:	ds.b	254
BootUpString:	ds.b	254

	CNOP	0,4
EditMarks10:	DS.L	10

ScrColors:	ds.l	3*16/2

Parameters:	ds.b	256
ParametersLengte:ds.l	1

RegsDataIdx:		DS.L	7	; must be before RegsDataMemBuffer
RegsDataMemBuffer:	ds.l	1
RegsDataFHandle:	ds.l	1

OldCursorpos:	ds.l	1	;was ds.w 1
OldLinePos: 	ds.l	1	;was ds.w 2 ?!
LocalBufPtr:	ds.l	1
Marksinsource:	ds.w	1
CPU_type:	ds.w	1
MMU_type:	ds.w	1
PrefsGedoe:	ds.w	1

huidigesectie:	DS.W	1
NewSyntaxbits:	DS.B	1

HaveKS3:	DS.B	1

Parse_NewAdrvalue:	DS.L	1
Parse_AdrValue:	DS.L	1
Parse_AdrValueSize:
		ds.w	1
Parse_CPUType:	ds.w	1

AsmErrorPos:	ds.l	1
AsmErrorTable:	ds.l	2*100		; line/errmsg pairs
AsmEindeErrorTable:
		ds.l	1
Asm_LastErrorPos:
		ds.l	1
PrevDirnames:
		ds.b	128	;normal read/write
		ds.b	128	;object/binary etc..
		ds.b	128	;insert

LastFileNaam:	ds.b	CS_size
ProjectName:	ds.b	CS_size

OpcodeDissolve:	ds.w	30
CustomTabs:	ds.w	40
RegelPtrsIn:	ds.l	128
RegelPtrsOut:	ds.l	128
VBR_base_ofzo:	ds.l	1
VBR_Base2:	ds.l	1
LoopPtr:	ds.l	10

Safety:		DS.B	1
CaseSenceSearch:DS.B	1

PR_GadgetID:	ds.w	1
PR_Msg:		ds.l	1
PR_GadClass:	ds.l	1
PR_GadCode:	ds.l	1
PR_GadMouseX:	ds.l	1
PR_GadgetAdr:	ds.l	1

PR_GTIMsg:	DS.L	1
PrefsEndLoading:DS.B	1
PR_CloseWin:	DS.B	1

GadgetBuffer:	DS.B	gng_SIZEOF
PrefsMenuStrip:	ds.l	1
PrefsAsmWinBase:ds.l	1
Prefs_GList:	ds.l	1
Prefs_Gadgets:	ds.l	env_gadcount	;39
Prefs_msgport:	ds.l	1
Prefs_Signal:	ds.l	1
ErrorLijnInCode:ds.l	1
L2F118:		ds.l	2
RegsDataFH:	ds.l	1
RegsDataSize:	ds.l	1

L2F148:		ds.l	1
L2F154:		ds.l	1
HelpBufPtrBot:	ds.l	1
HelpBufPtrTop:	ds.l	1

fpu_1:		ds.l	1
fpu_2:		ds.l	1
fpu_3:		ds.l	1
fpu_1_old:	ds.l	1
fpu_2_old:	ds.l	1
fpu_3_old:	ds.l	1

FpuRegsStore:	ds.l	8*3	; 8x extended fp
FpuRegsStore_Old:
		ds.l	8*3

screen_req:	ds.l	1
old_sizeY:	ds.l	1
old_sizeX:	ds.l	1
scrmode_oud:	ds.l	1
scrmode_new:	ds.l	1
old_screendepth:	ds.w	1
NieuwMouse:		; pair x,y
NieuwMouseX:	ds.w	1
NieuwMouseY:	ds.w	1
ShowDir_NrLines:	ds.w	1
FpuRegExp:		ds.w	1
AssmblrStatus:		ds.w	1
D02F258:	ds.l	2	; fp double (8b)
D02F260:	ds.l	3	; max fp size (extended 12b)
LastCalcFpsr:	ds.l	1
NewAmiGuideBase:ds.l	1
SysActiveView:	ds.l	1
YposScreen:	ds.w	1
SourcePtrs:	DS.B	10*CS_size	; 10*256 bytes
TempBuffer:	ds.l	1
TempBufferSize:	ds.l	1

EditorRegs:	DS.L	15	; d0-d7/a0-a6

Disasm_NewSyntax:	ds.b	1
S_MemIndActEnc:	ds.b	1
ProcessorType:	ds.w	1
FPU_Type:	ds.w	1
Oldcursorcol:	ds.w	1
L2FCEA:		ds.l	1

buffer_ptr:	ds.l	1
IncIFF_BODYbuffer2:
		ds.l	1
IncIffBuf2Size:	ds.l	1
IncIFF_BODYbuffer:
		ds.l	1
IncIffBuf1Size:	ds.l	1
IncIff_hunksize:
		ds.l	1
IncIff_sizeFORM:
		ds.l	1
IncIff_filepos:
		ds.l	1
IFFbreed:	ds.w	1
IFFhoog:	ds.w	1
IFFlinks:	ds.w	1
IFFboven:	ds.w	1
IFFpbreed:	ds.w	1
IFFphoog:	ds.w	1
;L2FD24:		ds.l	1
;L2FD28:		ds.l	1
IFFnrplanes:	ds.b	1
IFFmask:	ds.b	1
IFFcompressed:	ds.b	1
IncIff_tiepe:	ds.b	1
IncIff_colmap_pos:	ds.b	1

B140AA:		DS.B	1

SyntItemIndex:	DS.W	1
PrefsRastport:	DS.L	1

IffA6Backup:	DS.L	1

IffPalette:	ds.b	3*256		; r,g,b

titletxt:	ds.b	80+1

LastFoundLine:	ds.b	1
BlokBackwards:	ds.b	1
HavePrefsFilename:	ds.b	1
SomeBits3_backup:
		ds.b	1
Prefs_tiepe:	ds.b	1
menu_tiepe:	ds.b	1
markblockset:	ds.b	1
HaveCustomTab:	ds.b	1
B30048:		ds.b	1
B30049:		ds.b	1
B3004A:		ds.b	1
FpuResultInf:	ds.b	1
FpuResultInexact:ds.b	1
Dis_DecLibCall:	ds.b	1
CurrentSource:	ds.b	1
Change2Source:	ds.b	1
FromCmdLine:	ds.b	1

B30053:		ds.b	15
L30062:		ds.b	15

B30172:		ds.b	1
ActiveSrcNr:	ds.b	1
AsmCheckCnly:		ds.b	1
Asm_MacroSize:		ds.b	1
Asm_TextHexMode:	DS.B	1
MMUAsmBits:		ds.b	1
	CNOP	0,4
Scr_NrPlanes:	ds.w	1
Scr_Title_size:		ds.w	1	;11
Scr_Title_sizeTxt:	ds.w	1	;11+baseline
Scr_breedte:	ds.w	1
Scr_hoogte:	ds.w	1
Scr_br_chars:	ds.w	1

Win_BorTop:	ds.w	1	;2
Win_BorLeft:	ds.w	1	;4
Win_BorRight:	ds.w	1	;4
Win_BorBottom:	ds.w	1	;2
Win_BorHor:	ds.w	1	;8
Win_BorVer:	ds.w	1	;4
Win_BorVerT:	ds.w	1	;10+2=12

EFontSize_xy:
EFontSize_x:	ds.w	1
EFontSize_y:	ds.w	1

ParsePos:	ds.l	1

EditScrollSize:	ds.l	1	;br*hg edit window *depth
EditScrollSizeTitleDown:	ds.l	1	;br*hg edit window +titlesize *depth
EditScrollSizeTitleUp:		ds.l	1	;br*hg edit window +titlesize *depth
EditScrollRegelSize:		ds.w	1	;br*hgfont * depth
Edit_nrlines:	ds.w	1	;aantal beeldlijntjes -1

SOLO_CurrentIncPtr:ds.l	1
MyBits:		ds.b	1
ScBits:		ds.b	1
ShowLogin:	DS.B	1
palet12bit:	ds.b	1
	EVEN
strip_buffer:	ds.l	1
IFFRegsBase:	ds.l	15
StartBank:	ds.w	1	;0-7
ColorOffset:	ds.w	1	;$180-$1be
coloffset2:	ds.w	1
nrcols:		ds.w	1
helpptrAGA:	ds.l	1

ScColor:	ds.w	1
markkeys:	ds.b	10
regel_buffer:	ds.b	256

W207D0:		DS.W	1
MENUCHAR_TEXTBUFFER:	ds.b	2	; 2-byte string (char+zero)
BufNewGad:	DS.B	gng_SIZEOF
LoginWnd:	DS.L	1
LoginGList:	DS.L	1
LoginGadgets:	DS.L	Login_CNT

req_file_extentie:	DS.B	2+16+1	; '#?' + pattern + 0
Mon_Notif_Addr:	ds.b	1		; Must refresh the address later
Dbg_KeepMark:	DS.B	1

	EVEN
RecentTmp:		DS.B	146
RecentCache:		DS.B	146*10

	EVEN
CmdLineHistoryCache:	DS.B	COMMANDLINEBUFFERCACHE

	CNOP	0,4
EndVarBase:

******************************************************
	IFEQ	SPEC_ED

	SECTION	AsmProLogo,DATA_C

asmprologo:		;480*60 2 planes
	inciff	include:pics/asm-pro480x120_new.iff,RN
endlogo:

smallasmprologo:	;48*74 2 planes
	inciff	include:pics/asm-pro40x100.iff,RN

	ENDIF	; SPEC_ED
******************************************************
