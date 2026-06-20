;APS000597E2000206C500068D710001537C0000A120000154990000040C00066E3A00014AF80005B817
******************************************************
*
* Project	: Asm-Pro (OpenSource Edition)
* Start Date	: 30-Dec-1996
* Author	: Solo/GeNeTiC
*
* Binary Version: 1.18
* Source Version: 1.18 (opensource release)
* Project	: Asm-Pro (OpenSource Edition)
*
* Updates/People contributing to the opensource release:
*
* 05-april-2012 ; v1.18 (Apollo edition)
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
* - Aske Simon Christensen azka Blueberry
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

Debugstuff	= TRUE	; Use this option to activate debug window
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
MC020			= FALSE		; (no speedup.. so disabled)
useplugins		= FALSE		; (not finished)
SLIDER			= FALSE	;TRUE	; (not finished)
MEMSEARCH		= TRUE
CLIPBOARD		= FALSE		; (not finished)
INCLINK			= TRUE

MAX_REPT_LEVEL		=	50	; 10
MAX_INCLUDE_LEVEL 	=	20	; 10
MAX_CONDITION_LEVEL 	=	100	; 20
MAX_MACRO_LEVEL		=	100	; 25

	TTL	"Asm-Pro by Genetic"
	IDNT 	"Asm_Pro by Genetic"

	PRINTT	"Asm-Pro OpenSource Edition (c)1996/2005 brought to you by Solo/Genetic.."


**************************
*** Externals includes ***
**************************
	incdir	"include:"
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
	include "lvo/mathffp_lib.i"			; ***
	include "lvo/mathtrans_lib.i"			; ***
	include "lvo/keymap_lib.i"			; ***
	include "lvo/console_lib.i"			; ***
	include "lvo/diskfont_lib.i"			; ***
	include "lvo/amigaguide_lib.i"			; ***
	include	"devices/clipboard.i"
	include	"exec/tasks.i"

version: macro
	dc.b	'V1.18'
	endm

subversion	= ' '

TDNestCnt		=	$127
IDNestCnt		=	$126
gb_ActiView		=	$022
gb_SIZE			=	$1F1

DSIZE			=	128
MAX_BRK_PTRS		=	16

COMMANDLINECACHESIZE=256
COMMANDLINEBUFFERCACHE=COMMANDLINECACHESIZE*16

;menu_type
MT_COMMAND		=	0
MT_EDITOR		=	1
MT_MONITOR		=	2
MT_DEBUGGER		=	3

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
SB3_CHGCONFIG		EQU	0
SB3_REPORT_ERROR	EQU	1
SB3_COMMANDMODE		EQU	2 ;in commandline
SB3_EDITORMODE		EQU	3 ;in editor

;MyBits
MB1_REGEL_NIET_IN_SOURCE	EQU	0
MB1_DRUK_IN_MENUBALK		EQU	1
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

AF_PASSONE	= 15	;$00008000

AF_PROCESRWARN	= 24	;$01000000
AF_SEMICOMMENT	= 25	;$02000000
AF_OFFSET	= 26	;$04000000
AF_OFFSET_A4	= 27	;$08000000
AF_ALLERRORS	= 28	;$10000000
AF_LISTFILE	= 29	;$20000000
AF_DEBUG1	= 30	;$40000000
AF_IF_FALSE	= 31	;$80000000

NS_AVALUE	= $61
NS_ALABEL	= $62
NS_ROLLEFT	= $63
NS_ROLRIGHT	= $64

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

MODE_0=	%0			;$0000
MODE_1=	%1			;$0001
MODE_2=	%10			;$0002
MODE_3=	%100			;$0004
MODE_4=	%1000			;$0008
MODE_5=	%10000			;$0010
MODE_6=	%100000			;$0020
MODE_7=	%1000000		;$0040
MODE_8=	%10000000		;$0080
MODE_9=	%100000000		;$0100
MODE_10=%1000000000		;$0200
MODE_11=%10000000000		;$0400
MODE_12=%100000000000		;$0800
MODE_13=%1000000000000		;$1000
MODE_14=%10000000000000		;$2000
MODE_15=%100000000000000	;$4000

****************************************************************************


	SECTION	AsmPro_Startup,CODE
ProgStart:
	movem.l	d0-a6,-(sp)				; ***
	bsr.w	Init_Filtertable
	movem.l	(sp)+,d0-a6				; ***

	move.l	a0,-(sp)
	lea	(Variable_base).l,a4
	lea	ConvTabel3+256(pc),A0
	move	#256-1,d0
.lopje:
	move.b	-(a0),(Variable_base-DT,a4,d0.w)
	dbra	d0,.lopje

	clr.l	(DATA_RETURNMSG-DT,a4)
	sub.l	a1,a1
	move.l	(4).w,a6
	jsr	(_LVOFindTask,a6)
	move.l	d0,a5
	move.l	d0,(TaskBase).l
	move.b	($0129,a6),d0

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
	; ***
	moveq	#0,d1
	btst	#4,d0
	beq.b	.fputype
	moveq	#1,d1
	btst	#5,d0
	beq.b	.fputype
	moveq	#2,d1
.fputype:
	move	d1,(FPU_Type-DT,a4)

	lea	.DosName,a1
	jsr	(_LVOOldOpenLibrary,a6)		; ***

	move.l	(sp)+,a0
	move.l	d0,-(sp)
	movem.l	d0-a6,-(sp)			; ***
	moveq.l	#36,d0
	lea	.DosName,a1
	jsr	(_LVOOpenLibrary,a6)
	tst.l	d0
	beq.b	doslib_error
	move.l	d0,a1
	jsr	(_LVOSplitName,a6)
	movem.l	(sp)+,d0-a6			; ***
	tst.l	($00AC,a5)		;test of opgestart van CLI
	beq.b	JepWBstartup

	clr	(KeyboardOutBuf-DT,a4)
	clr	(KeyboardInBuf-DT,a4)
	jsr	(DATAFROMSTART).l
	move.l	(sp)+,a6		;doslib
	moveq	#0,d1
	jsr	(_LVOCurrentDir,a6)		; ***
	move.l	d0,(CurrentDir).l
	move.l	d0,d1
	jsr	(_LVOCurrentDir,a6)		; ***

	move.l	4(sp),d0
	MOVE.L	D0,StackSize

	bra.b	DuplockDir

.DosName:	dc.b	"dos.library",0

Init_Filtertable:
	lea	(Variable_base).l,a0
	lea	(EndVarBase).l,a1
.lopje:
	clr.b	(a0)+
	cmp.l	a0,a1
	bne.b	.lopje
	rts

doslib_error:
	movem.l	(sp)+,d0-a6			; ***
	move.l	(sp)+,(DosBase-DT,a4)
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOOutput,a6)
	move.l	d0,d1
	move.l	#Sorrythisvers.MSG,d2
	moveq.l	#$45,d3
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOWrite,a6)
	moveq	#0,d0
	rts

JepWBstartup:
	MOVE.L	$0084(A5),StackSize	;stacksize van icoontje
	lea	($005C,a5),a0
	move.l	(4).w,a6
	jsr	(_LVOWaitPort,a6)
	lea	($005C,a5),a0
	jsr	(_LVOGetMsg,a6)			; ***
	move.l	d0,(DATA_RETURNMSG-DT,a4)
	move.l	d0,a0
	move.l	($0024,a0),d0
	beq.b	DuplockDir
	move.l	d0,a0
	move.l	(a0),(CurrentDir).l
	move.l	(sp)+,a6
DuplockDir:
	move.l	(CurrentDir).l,d1
	jsr	(_LVODupLock,a6)		; ***
	move.l	d0,(CurrentDir).l
	move.l	#AsmPro.MSG,d1
	moveq	#0,d2
	lea	(ProgStart-4).l,a0
	move.l	(a0),d3
	clr.l	(a0)

	MOVE.L	StackSize,D4
	CMP.L	#20*1024,D4		;just for people who need more
	bhs.s	CreateProc		;(like me)..
	move.l	#32*1024,D4		;32k should do..
CreateProc:

	MOVE.L	D4,_StackSize

	jsr	(_LVOCreateProc,a6)	;(naam-d1,pri-d2,seglist-d3,stacksize-d4) ; ***
;	jsr	REAL

	move.l	a6,a1
	move.l	(4).w,a6
	jsr	(_LVOCloseLibrary,a6)
	tst.l	(DATA_RETURNMSG-DT,a4)
	beq.b	.nomsg
	jsr	(_LVOForbid,a6)		; ***
	move.l	(DATA_RETURNMSG-DT,a4),a1
	jsr	(_LVOReplyMsg,a6)	; ***
.nomsg:
	moveq	#0,d0
	rts

versionstring:
	dc.b	"$VER: Asm-Pro "
	version
	dc.b	subversion
	dc.b	" ("
	%getdate 3
	dc.b	") By Solo/Genetic.",0
	cnop	0,4

StackSize:	dc.l	0
;	dc.l	"SOLO"
	
ConvTabel3:	;0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
	DC.B	00,00,00,00,00,00,00,00,00,-1,00,00,00,00,00,00
	DC.B	00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00

	DC.B	-1,00,00,00,00,'[',00,00,00,00,00,00,00,00,'A'-1,00
	DC.B	'0123456789',0,0,0,0,0,0

	DC.B	'@','ABCDEFGHIJKLMNO'
	DC.B	'PQRSTUVWXYZ',0,0,0,0,'Z'+1
	DC.B	00
	DC.B	'ABCDEFGHIJKLMNO'
	DC.B	'PQRSTUVWXYZ',0,0,0,0,0
	BLK.B	128,0

realend1:

;***********************************************
;**            MAIN CODE SECTION              **
;***********************************************

	SECTION	AsmPro288,CODE
REAL:
	clr.b	(MyBits-DT,a4)
	clr.b	(ScBits-DT,a4)
	clr.w	(ScColor-DT,a4)
	
	lea	(Variable_base).l,a4
	sub.l	a1,a1
	move.l	(4).w,a6
	jsr	(_LVOFindTask,a6)
	move.l	d0,(DATA_TASKPTR-DT,a4)
	move.l	d0,a5
	move.l	($00B8,a5),(DATA_OLDREQPTR-DT,a4)
	move.b	#1,(B2FCDE-DT,a4)
	move.l	(TaskBase).l,a1
	move.l	($009C,a1),($009C,a5)		;set i/o over to current task
	move.l	($00A0,a1),($00A0,a5)
	move.l	($00AC,a1),($00AC,a5)
	bsr.w	MakeItAllHappen
	move.l	(DATA_TASKPTR-DT,a4),a5
	move.l	(DATA_OLDREQPTR-DT,a4),($00B8,a5)
	move.l	#REAL-4,d1
	lsr.l	#2,d1
	move.l	(DosBase-DT,a4),a6
	jmp	(_LVOUnLoadSeg,a6)

AsmPro.MSG:		dc.b	'Asm-Pro',0
ENVARCAsmProP.MSG:
			IF	Debugstuff
			dc.b	'ENVARC:Asm-Pro_beta.Pref',0
			ELSE
			dc.b	'ENVARC:Asm-Pro.Pref',0
			ENDIF
RecentName:		dc.b	"ENVARC:Asm-Pro.Rcnt",0
RecentFilesNbr:		dc.b	0
			cnop 0,4
SREGSDATA.MSG:		dc.b	'Asmpro:REGSDATA',0
RegsDataSDir:		dc.b	'S:REGSDATA',0
Sorrythisvers.MSG:	dc.b	'Sorry, Asm-Pro requires kickstart 2.04 or higher !!',$A,$D,0
			cnop	0,4
CurrentDir:		dc.l	0

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
	move.b	(a0),d0
	cmp.b	#'-',d0
	bne.s	.noNewOptions

	addq.l	#1,a0
	move.b	(a0)+,d0
	cmp.b	#'f',d0
	bne.s	.noforce

	move.b	#1,(Safety-DT,a4)

	addq.l	#1,a0
.noforce:

.noNewOptions:
	bra.b	DATAFROMAUTO2

CmdlineOpties:
	movem.l	d0/a1,-(sp)
	lea	(ENVARCAsmProP.MSG).l,a1
	moveq	#'>',d0
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
	move.b	#0,(a1)
	movem.l	(sp)+,d0/a1
	bra.w	DATAFROMSTART


imagestr:
	dc.w    0		0	;offset x
	dc.w    0		2	;offset y
	dc.w    480		4	;breedte 
	dc.w    120		6	;hoogte plaatje
	dc.w    2		8	;nr planes
	dc.l    asmprologo	10	;bitmap ptr
	dc.b    3		14
	dc.b    0		15
	dc.l    0		16


MakeItAllHappen:
	move.b	#1,(EVENT_IECLASS-DT,a4)
	move.l	sp,(DATA_USERSTACKPTR-DT,a4)
	move.l	#$FFFFFFFF,(AsmErrorTable-DT,a4)

;	move.w	(Scr_breedte-DT,a4),d0
;	lsr.w	#3,d0
	move	#68,(breedte_editor_in_chars-DT,a4)
	clr.b	(debug_FPregs-DT,a4)
	jsr	resize_db_win

	jsr	opendoslib
	jsr	opengadtlib
	jsr	openasllib
	
C40E:
	jsr	clear_all

	move.w	#0,(Cursor_col_pos-DT,a4)
	move.w	#0,(cursor_row_pos-DT,a4)

	moveq.l	#0,d7
	move.w	(Scr_hoogte-DT,a4),d7
	lsr.w	#4,d7
	add.w	#120,d7
	divu.w	(EFontSize_y-DT,a4),d7

.lopje:
	moveq.l	#10,d0
	jsr	SENDONECHARNORMAL
	dbf	d7,.lopje

	tst.b	(HomeDirectory-DT,a4)
	beq.b	C4C2
	tst.b	(B2E17E-DT,a4)
	beq.b	C4C2
	clr.b	(B2E17E-DT,a4)
	lea	(HomeDirectory-DT,a4),a0
	move.l	a0,_dirstringTags+4
C4C2:
	tst.b	(B30175-DT,a4)
	beq.b	C4DA
	lea	(Erroropeningr.MSG).l,a0
	jsr	(beeldtextaf).l
C4DA:
	jsr	LoadRecentFiles
	move.l	(Rastport-DT,a4),a0
	
	MOVE.L  (IntBase-DT,A4),A6
	lea     imagestr(pc),a1
	move.w	(Scr_breedte-DT,a4),d0	;center the picture
	sub.w	#480,d0
	lsr.w	#1,d0
	move.w	d0,d6

	move.w	(Scr_hoogte-DT,a4),d1
	lsr.w	#4,d1
	move.w	d1,d5
	jsr     (_LVODrawImage,a6)        ; ***

	move.l	(GadToolsBase-DT,a4),a6

	move.l	(Rastport-DT,a4),a0
	move.l	(MainVisualInfo-DT,a4),PW_NR+4
	move.l  (MainVisualInfo-DT,a4),PW_IR+4

	lea.l   PW_NR,a1
	move.w	d6,d0
	move.w	d5,d1
	subq.w  #3,d0		;x
	subq.w  #3,d1		;y
	move.w  #486,d2		;br
	move.w  #126,d3		;hg
	jsr     _LVODrawBevelBoxA(a6)

	jmp	(AllocMainWorkspace).l

PRIVILIGE_VIOL1:
	movem.l	d0-d7/a0-a6,-(sp)
	lea	(SupervisorRoutine).l,a5
	move.l	(4).w,a6
	jsr	(_LVOSupervisor,a6)

CriticalError:
	movem.l	(sp)+,d0-d7/a0-a6
	move.l	(DATA_USERSTACKPTR-DT,a4),sp
	jsr	(DEBUG_CLEAR_BP_BUFFER).l
	move.l	#L2DF4C,(USP_base-DT,a4)
	move.l	#L2CF4C,(SSP_base-DT,a4)
	clr	(statusreg_base-DT,a4)
	move.l	#eop_irq_routine,(pcounter_base-DT,a4)
	jsr	(debug_regs2old).l
	jmp	(CommandlineInputHandler).l

SupervisorRoutine:
	move.l	sp,(DATA_SUPERSTACKPTR-DT,a4)
	tst	(ProcessorType-DT,a4)
	beq.b	.mc68000
	move.l	a0,-(sp)
	movec	vbr,a0
	move.l	a0,(VBR_base_ofzo-DT,a4)
	move.l	(sp)+,a0
.mc68000:
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
	bra.w	MoveupNLines

; ----
MoveupNLines:
	move.l	(FirstLinePtr-DT,a4),a0
	cmp.l	a3,a0
	bne.b	.lopje
	move.l	a2,a0
.lopje:
	move.b	-(a0),d0
	cmp.b	#$19,d0
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
	cmp.b	#$1A,d0
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
	cmp.b	#$1A,d0
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
	clr.b	(BlokBackwards-DT,a4)
	move.b	(CurrentSource-DT,a4),d1
	add.b	#'0',d1
	move.b	d1,(SourceNrInBalk).l

	jsr	(Change2Editmenu).l

	bclr	#SB2_MAKEMACRO,(SomeBits2-DT,a4)
	bclr	#SB1_MOUSE_KLIK,(SomeBits-DT,a4)
	bclr	#SB1_SEARCHBUF_NE,(SomeBits-DT,a4)
	bclr	#SB2_INDEBUGMODE,(SomeBits2-DT,a4)
	bset	#SB3_EDITORMODE,(SomeBits3-DT,a4)	;in editor
	bclr	#MB1_INCOMMANDLINE,(MyBits-DT,a4)	;uit commandline

	jsr	(PRINT_CLEARSCREEN).l
	move.b	#$FF,(B2BEB8-DT,a4)
	bsr.w	E_RemoveCutMarking
	move.l	(FirstLinePtr-DT,a4),a2
	move.l	a2,a3
	moveq.l	#0,d1
	move	(NrOfLinesInEditor-DT,a4),d1
	lsr.w	#1,d1
	bsr.w	MoveupNLines
	moveq	#0,d0
	jsr	(SENDONECHARNORMAL).l
	jsr	(PrintStatusBalk).l
	jsr	Show_Cursor
	movem.l	d0-d7/a0-a6,(EditorRegs-DT,a4)

.EventLoopje:
	cmp.l	#1,(FirstLineNr-DT,a4)
	bne.b	.noFirst
	tst.l	(LineFromTop-DT,a4)
	bne.b	.noFirst
	bsr.w	C1382
	tst.b	(B30047-DT,a4)
	beq.b	.noFirst
	bsr.w	RegTab_SETALLNOTUPD
.noFirst:
	bsr.w	EDITSCRPRINT
	jsr	(messages_get).l
	jsr	(GETKEYNOPRINT).l

	bsr.w	EDITOR_PUTMACRO
	cmp.b	#$1B,d0		;ESC
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
	bclr	#0,d0
	jmp	(Editor_commands_table,pc,d0.w)

TaskBase:
	dc.l	'AsmP'			;TaSk

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
	dr.w	E_not_used		;
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
	dr.w	E_Mark6			;Amiga ^	100

	dr.w	E_OpenAmiGuide		;Amiga =

	dr.w	E_ChangeSource		;source change
;???
	dr.w	E_Go2Source0		;F1 change 2 source 0
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

E_Go2Source0:	move.b	#0,(Change2Source-DT,a4)
		bra.b	Go2Sourcenow
E_Go2Source1:	move.b	#1,(Change2Source-DT,a4)
		bra.b	Go2Sourcenow
E_Go2Source2:	move.b	#2,(Change2Source-DT,a4)
		bra.b	Go2Sourcenow
E_Go2Source3:	move.b	#3,(Change2Source-DT,a4)
		bra.b	Go2Sourcenow
E_Go2Source4:	move.b	#4,(Change2Source-DT,a4)
		bra.b	Go2Sourcenow
E_Go2Source5:	move.b	#5,(Change2Source-DT,a4)
		bra.b	Go2Sourcenow
E_Go2Source6:	move.b	#6,(Change2Source-DT,a4)
		bra.b	Go2Sourcenow
E_Go2Source7:	move.b	#7,(Change2Source-DT,a4)
		bra.b	Go2Sourcenow
E_Go2Source8:	move.b	#8,(Change2Source-DT,a4)
		bra.b	Go2Sourcenow
E_Go2Source9:	move.b	#9,(Change2Source-DT,a4)
Go2Sourcenow:
	move.b	(CurrentSource-DT,a4),d0
	cmp.b	(Change2Source-DT,a4),d0
	bne.b	E_ChangeSource
	rts

CS_start		equ	0
CS_length		equ	CS_start+4
CS_FirstLinePtr		equ	CS_length+4
CS_FirstlineNr		equ	CS_FirstLinePtr+4
CS_FirstLineOffset	equ	CS_FirstlineNr+4	;used to be 2
CS_SomeBits		equ	CS_FirstLineOffset+4	;used to be 2
CS_marks		equ	CS_SomeBits+2
CS_filename		equ	CS_marks+[4*10]
CS_update		equ	CS_filename+31
CS_AsmStatus		equ	CS_update+129
CS_size			equ	256


E_ChangeSource:
	clr.l	(TempBuffer-DT,a4)
	move.l	(Cut_Blok_End-DT,a4),d0
	sub.l	(sourceend-DT,a4),d0
	ble.b	.dontcopy
	addq.w	#1,d0
	move.l	d0,(TempBufferSize-DT,a4)
	movem.l	d1-a6,-(sp)			; ***
	move.l	#$10001,d1
	move.l	(4).w,a6
	jsr	(_LVOAllocMem,a6)
	movem.l	(sp)+,d1-a6			; ***
	tst.l	d0
	beq.b	.dontcopy
	move.l	d0,(TempBuffer-DT,a4)
	movem.l	d0-a6,-(sp)			; ***
	move.l	(sourceend-DT,a4),a0
	move.l	(TempBuffer-DT,a4),a1
	move.l	(TempBufferSize-DT,a4),d0
	addq.w	#1,a0
	subq.w	#1,d0
	move.l	(4).w,a6
	jsr	(_LVOCopyMem,a6)
	movem.l	(sp)+,d0-a6			; ***
.dontcopy:
	jsr	(C1634).l
	jsr	(C164C).l
	movem.l	d0-a6,-(sp)			; ***
	lea	(SourcePtrs-DT,a4),a0
	moveq	#0,d0
	moveq	#0,d2
	move.b	(CurrentSource-DT,a4),d0
	move.b	(Change2Source-DT,a4),d2
	lsl.l	#8,d0
	lsl.l	#8,d2
	lea	(a0,d0.w),a1
	lea	(a0,d2.w),a0
	move.l	(sourceend-DT,a4),d0
	sub.l	(sourcestart-DT,a4),d0
	bls.w	C9C0
	move.l	d0,(CS_length,a1)
	movem.l	d1-a6,-(sp)			; ***
	move.l	#$10001,d1
	move.l	(4).w,a6
	jsr	(_LVOAllocMem,a6)
	movem.l	(sp)+,d1-a6			; ***
	tst.l	d0
	beq.w	CBAE
	move.l	d0,(CS_start,a1)
	move.l	(FirstLinePtr-DT,a4),(CS_FirstLinePtr,a1)
	move.l	(FirstLineNr-DT,a4),(CS_FirstlineNr,a1)
	move.l	(LineFromTop-DT,a4),(CS_FirstLineOffset,a1)
	move	(SomeBits-DT,a4),(CS_SomeBits,a1)
	move	(AssmblrStatus).l,(CS_AsmStatus,a1)
	movem.l	d7/a1/a2,-(sp)
	lea	(Mark1set-DT,a4),a2
	lea	(CS_marks,a1),a1
	moveq	#10-1,d7	;copy marks
C956:
	move.l	(a2)+,(a1)+
	dbra	d7,C956
	movem.l	(sp)+,d7/a1/a2
	movem.l	d0-a6,-(sp)				; ***
	move.l	(sourcestart-DT,a4),a0
	move.l	(CS_length,a1),d0
	move.l	(CS_start,a1),a1
	move.l	(4).w,a6
	jsr	(_LVOCopyMem,a6)
	movem.l	(sp)+,d0-a6				; ***
	movem.l	a2/a3,-(sp)
	lea	(MenuFileName).l,a2
	lea	(CS_filename,a1),a3
	moveq	#30-1,d7	;copy filename
C98C:
	move.b	(a2)+,(a3)+
	tst.b	(a2)
	beq.b	C996
	dbra	d7,C98C
C996:
	move.b	#0,(a3)+
	dbra	d7,C996
	lea	(LastFileNaam-DT,a4),a2
	lea	(CS_update,a1),a3
	moveq	#$7F,d7
C9A8:
	move.b	(a2)+,(a3)+
	tst.b	(a2)
	beq.b	C9B4
	dbra	d7,C9A8
	bra.b	C9BC

C9B4:
	move.b	#0,(a2)+
	dbra	d7,C9B4
C9BC:
	movem.l	(sp)+,a2/a3
C9C0:
	tst.l	(CS_start,a0)
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
	move	(CS_AsmStatus,a1),(AssmblrStatus).l
	movem.l	d0-a6,-(sp)		; ***
	move.l	(sourcestart-DT,a4),a1	;dest
	move.l	(CS_length,a0),d0	;size
	movem.l	d0/a1,-(sp)
	move.l	(CS_start,a0),a0	;source
	move.l	(4).w,a6
	jsr	(_LVOCopyMem,a6)

	movem.l	(sp)+,d0/a1
	add.l	d0,a1
	move.b	#$1A,(a1)+		;?!?
	
	movem.l	(sp),d0-a6		; ***
	;movem.l	d0-a6,-(sp)	; ***

	move.l	(CS_start,a0),a1
	move.l	(CS_length,a0),d0
	move.l	(4).w,a6
	jsr	(_LVOFreeMem,a6)
	movem.l	(sp)+,d0-a6		; ***
	lea	(CS_marks,a0),a1
	lea	(Mark1set-DT,a4),a2
	moveq	#10-1,d7
CA3C:
	move.l	(a1)+,(a2)+
	dbra	d7,CA3C
	movem.l	a2/a3,-(sp)
	lea	(CS_update,a0),a2
	lea	(LastFileNaam-DT,a4),a3
	moveq	#$7F,d7
CA50:
	move.b	(a2)+,(a3)+
	tst.b	(a2)
	beq.b	CA5C
	dbra	d7,CA50
	bra.b	CA64

CA5C:
	move.b	#0,(a3)+
	dbra	d7,CA5C
CA64:
	lea	(CS_filename,a0),a2
	lea	(MenuFileName).l,a3
	moveq	#$1D,d7
CA70:
	move.b	(a2)+,(a3)+
	tst.b	(a2)
	beq.b	CA7C
	dbra	d7,CA70
	bra.b	CA84

CA7C:
	move.b	#0,(a3)+
	dbra	d7,CA7C
CA84:
	movem.l	(sp)+,a2/a3
	lea	(CS_start,a0),a0
	moveq	#$3F,d7
CA8E:
	move.l	#0,(a0)+
	dbra	d7,CA8E
	bra.b	CAE4

CA9A:
	move.l	(sourcestart-DT,a4),a0
	move.l	a0,(FirstLinePtr-DT,a4)
	move.b	#0,(a0)+
	move.b	#$1A,(a0)
	move.l	a0,(sourceend-DT,a4)
	move.b	#$1A,(a0)+
	move.l	a0,(Cut_Blok_End-DT,a4)
	move.l	#1,(FirstLineNr-DT,a4)
	move.l	#0,(LineFromTop-DT,a4)
	bclr	#SB1_SOURCE_CHANGED,(SomeBits-DT,a4)
	bclr	#SB2_MAKEMACRO,(SomeBits2-DT,a4)
	bclr	#SB1_MOUSE_KLIK,(SomeBits-DT,a4)
	clr.b	(LastFileNaam-DT,a4)
	clr.b	(MenuFileName).l
	clr	(AssmblrStatus).l
CAE4:
	bclr	#SB1_MOUSE_KLIK,(SomeBits-DT,a4)
	move.b	(Change2Source-DT,a4),d0
	move.b	d0,(CurrentSource-DT,a4)
	add.b	#$30,d0
	move.b	d0,(SourceNrInBalk).l
	movem.l	(sp)+,d0-d7/a0-a6
	jsr	(RegTab_SETALLNOTUPD).l
	clr	(NewCursorpos-DT,a4)
	move.b	#$FF,(B2BEB8-DT,a4)
	jsr	(E_RemoveCutMarking).l
	move.l	(FirstLinePtr-DT,a4),a2
	move.l	a2,a3
	moveq.l	#0,d1
	move	(NrOfLinesInEditor-DT,a4),d1
	lsr.w	#1,d1
	jsr	(MoveupNLines).l
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
	move.b	#$1A,(a1)
	move.l	a1,(Cut_Blok_End-DT,a4)
CB6A:
	movem.l	(sp),d0-a6			; ***
	;movem.l	d0-d7/a0-a6,-(sp)	; ***
	move.l	(TempBuffer-DT,a4),a1
	move.l	(TempBufferSize-DT,a4),d0
	move.l	(4).w,a6
	jsr	(_LVOFreeMem,a6)
	clr.l	(TempBuffer-DT,a4)
	clr.l	(TempBufferSize-DT,a4)
	movem.l	(sp)+,d0-a6			; ***
CB8E:
	tst.b	(FromCmdLine-DT,a4)
	beq.b	CB96
	rts

CB96:
	bsr.w	C1382
	moveq	#0,d0
	jsr	(SENDONECHARNORMAL).l
	jsr	(RESETMENUTEXT2).l
	jmp	(PrintStatusBalk).l

CBAE:
	movem.l	(sp)+,d0-a6			; ***
	lea	(Insuficientme.MSG).l,a0
	jmp	(printTextInMenuStrip).l

;********** EINDE CHANGE SOURCE ***************

E_OpenAmiGuide:
	movem.l	d0-a6,-(sp)			; ***
	jsr	(AmigaGuideGedoe).l
	movem.l	(sp)+,d0-a6			; ***
	rts

; block comment
E_Comment:
	cmp.l	#-1,a6
	beq.b	CC52
	cmp.l	a2,a6
	bge.b	CC52			;lame not backwards..
;	cmp.l	a6,a2
;	bge.b	.ok
;	exg.l	a6,a2
;.ok:
	move.l	a2,(HelpBufPtrTop-DT,a4)
	move.l	a6,(HelpBufPtrBot-DT,a4)
	move.l	(FirstLinePtr-DT,a4),a6
	bsr.w	E_Move2BegLine
CBEC:
	bsr.w	C14CC
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
	bsr.w	C14EC
	cmp.b	#$1A,(a3)
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
;	moveq	#0,d1
	move.l	(LineFromTop-DT,a4),d1
	bsr.w	MoveupNLines
	move.l	(sp)+,(FirstLineNr-DT,a4)
	move.l	(sp)+,(LineFromTop-DT,a4)
	move.l	(sp)+,a2
	bra.w	E_RemoveCutMarking

CC46:
	bsr.w	E_Move2BegLine
	moveq	#$3B,d0
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
	bsr.w	CF5A
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
	lea	(UncommentDone.MSG).l,a0
	jsr	(printTextInMenuStrip).l
	bra.w	E_NextCharacter


; block tabulate
E_Tabulate:	cmp.l	#-1,a6
		beq.b	CC52
		cmp.l	a2,a6
		bge.b	CC52
		move.l	a2,(HelpBufPtrTop-DT,a4)
		move.l	a6,(HelpBufPtrBot-DT,a4)
		move.l	(FirstLinePtr-DT,a4),a6
		bsr.w	E_Move2BegLine
CBECTab:	bsr.w	C14CC
		cmp.l	(HelpBufPtrBot-DT,a4),a2
		bgt.b	CBECTab
		bsr.w	E_Move2BegLine
CBFATab:	cmp.b	#9,(a3)
		beq.b	DoTab
		cmp.b	#" ",(a3)
		beq.b	DoTab
		cmp.b	#$19,(a3)
		beq.b	NoDoTab
		cmp.b	#$1a,(a3)
		beq.b	NoDoTab
		tst.b	(a3)
		beq.b	NoDoTab
		cmp.b	#";",(a3)		; comments ?
		beq.b	NoDoTab
		cmp.b	#"*",(a3)
		beq.b	NoDoTab
		bsr.w	E_Jump1WordForth	; label ?
		cmp.b	#$19,-1(a3)		; empty line
		beq.b	NoDoTab
		cmp.b	#$1a,-1(a3)
		beq.b	NoDoTab
		tst.b	-1(a3)
		beq.b	NoDoTab
		bra.b	DoTab
NoDoTab:	bra.b	NoTab
DoTab:		moveq	#9,d0
		bsr.w	EDITOR_INSERTCHAR_SETNS
		addq.l	#1,(HelpBufPtrTop-DT,a4)
		cmp.l	a2,a6
		bge.b	CC0ATab
		addq.l	#1,a6
CC0ATab:
NoTab:		bsr.w	C14EC
		cmp.b	#$1A,(a3)
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
		cmp.b	#$19,(a3)
		beq.b	NoDoTabE
		cmp.b	#$1a,(a3)
		beq.b	NoDoTabE
		tst.b	(a3)
		beq.b	NoDoTabE
		cmp.b	#";",(a3)		; comments ?
		beq.b	NoDoTabE
		cmp.b	#"*",(a3)
		beq.b	NoDoTabE
		bsr.w	E_Jump1WordForth	; label ?
		cmp.b	#$19,-1(a3)
		beq.b	NoDoTabE
		cmp.b	#$1a,-1(a3)
		beq.b	NoDoTabE
		tst.b	-1(a3)
		beq.b	NoDoTabE
		bra.b	DoTabE
		bra.b	CC1ETab
DoTabE:		moveq	#9,d0
		bsr.w	EDITOR_INSERTCHAR_SETNS
NoDoTabE:	bra.b	CC1ETab

; select all
E_SelectAll:	bsr.w	E_GotoTop
		bsr.w	E_Mark_blok
		bra.w	E_GotoBottom

; ----
E_SyntCols_prefs:
	move.b  #2,(Prefs_tiepe-DT,a4)
	bra.b    E_XPrefs

; ----
E_Assembler_prefs:
	move.b	#1,(Prefs_tiepe-DT,a4)
	bra.b	E_XPrefs

; ----
E_Environment_prefs:
	move.b	#0,(Prefs_tiepe-DT,a4)
E_XPrefs:
	movem.l	d0-a6,-(sp)			; ***
	jsr	(Handle_prefs_windows).l
	movem.l	(sp)+,d0-a6			; ***

	move	(Scr_br_chars-DT,a4),(breedte_editor_in_chars-DT,a4)
	move	(AantalRegels_Editor-DT,a4),d0
	jsr	(OPED_SETNBOFFLINES).l
	jsr	(PrintStatusBalk).l
	bra.w	RegTab_SETALLNOTUPD

; ----
E_ExitEditor:
	jsr	(KEY_RETURN_LAST_KEY).l
	bra.w	EDITOR_ESCPRESSED

	IF useplugins
E_Showplugs:
	jsr	_E_Showplugs
	rts
	ENDIF

LabelFlagetjeofzo:
	dc.w	0

E_Grab_word:
	move	#0,(LabelFlagetjeofzo).l
CCF6:
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
	cmp.b	#$1A,d0
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
	moveq	#0,d0
	move.b	(a1),d0
	cmp.b	#".",d0		;'.'
	beq.b	.okay2
	cmp.b	#"$",d0		;'$'
	beq.b	.okay1
	cmp.b	#"_",d0		;'_'
	beq.b	.okay2
	cmp.b	#"0",d0		;'0'
	bcs.b	.foutje
	cmp.b	#"9",d0		;'9'
	bls.b	.okay2
	cmp.b	#"A",d0		;'A'
	bcs.b	.foutje
	cmp.b	#"Z",d0		;'Z'
	bls.b	.okay2
	cmp.b	#"a",d0		;'a'
	bcs.b	.foutje
	cmp.b	#"z",d0		;'z'
	bls.b	.okay2
.foutje:
	moveq	#0,d0
.exit:
	rts

.okay1:
	tst	(LabelFlagetjeofzo).l
	beq.b	.foutje
.okay2:
	moveq	#-1,d0
	rts

; ----
E_CreateMacro:
	bchg	#SB2_MAKEMACRO,(SomeBits2-DT,a4)
	bne.b	.CD94
	clr	(EDMACRO_BUFPTR-DT,a4)
	lea	(Createmacro.MSG).l,a0
	jmp	(printTextInMenuStrip).l

.CD94:
	subq.b	#2,(EDMACRO_BUFByte-DT,a4)
	rts

EDITOR_PUTMACRO:
	btst	#SB2_MAKEMACRO,(SomeBits2-DT,a4)
	beq.b	.CDB2
	lea	(EDMACRO_BUFFER-DT,a4),a1
	add	(EDMACRO_BUFPTR-DT,a4),a1
	move.b	d0,(a1)+
	addq.b	#1,(EDMACRO_BUFByte-DT,a4)
	beq.b	.CDB4
.CDB2:
	rts

.CDB4:
	bclr	#SB2_MAKEMACRO,(SomeBits2-DT,a4)
	subq.b	#1,(EDMACRO_BUFByte-DT,a4)
	lea	(Macrobufferfu.MSG).l,a0
	jmp	(printTextInMenuStrip).l

; ----
E_DoMacro:
	bclr	#SB2_MAKEMACRO,(SomeBits2-DT,a4)
	beq.b	.CDD6
	subq.b	#2,(EDMACRO_BUFByte-DT,a4)
.CDD6:
	lea	(EDMACRO_BUFFER-DT,a4),a1
	move	(EDMACRO_BUFPTR-DT,a4),d1
	beq.b	.CDF6
	add	d1,a1
.CDE2:
	move.b	-(a1),d0
	lea	(OwnKeyBuffer-DT,a4),a0
	subq.b	#1,(KeyboardInBufByte-DT,a4)
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
	lea	(AsmErrorTable-DT,a4),a0
.CE08:
	cmp.l	#$FFFFFFFF,(a0)
	beq.b	.CE3C
	cmp.l	(a0),d0		;error linenr
	blt.b	.CE16
	addq.w	#8,a0
	bra.b	.CE08

.CE16:
;;	moveq.l	#0,d0				; *** to be removed
	move.l	(a0),d0
	move.l	a0,-(sp)
	bsr.w	JUMPTOLINE
	lea	(Error.MSG).l,a0
	jsr	(printTextInMenuStrip).l
	move.l	(sp)+,a0
	move.l	(4,a0),a0	;error msg
	jsr	(druk_menu_txt_verder).l
	movem.l	(sp)+,a0/a1/a5/a6
	rts

.CE3C:
	lea	(Nomoreerrorsf.MSG).l,a0
	jsr	(printTextInMenuStrip).l
	movem.l	(sp)+,a0/a1/a5/a6
	rts

; ----
E_Jump2Line:
	movem.l	a0/a5/a6,-(sp)
	btst	#0,(PR_ReqLib).l
	beq.b	.noreqt
	btst	#0,(PR_ExtReq).l
	beq.b	.noreqt
	movem.l	a0-a6,-(sp)
	lea	JumpLineNr,a1
	lea	Jumptowhichli.MSG,a2
	sub.l	a3,a3
	lea	(L1E7C6).l,a0
	move.l	(ReqToolsbase-DT,a4),a6
	jsr	(_LVOrtGetLongA,a6)		; ***
	movem.l	(sp)+,a0-a6
;	moveq	#0,d0				; *** To be removed
	move.l	JumpLineNr,d0
	bra.b	.CEA2

.noreqt:
	lea	(Jumptoline.MSG).l,a0
	jsr	(GetNrFromTitle).l
	beq.b	.novalue
.CEA2:
;	swap	d0
;	tst	d0
;	sne	d1
;	ext.w	d1	;$ffff
;	swap	d0
;	or.w	d1,d0
	move.l	d0,-(sp)
	lea	(Jumping.MSG).l,a0
	jsr	(printTextInMenuStrip).l
	move.l	(sp)+,d0

	bsr.w	JUMPTOLINE
	lea	(Done.MSG).l,a0
	jsr	(druk_menu_txt_verder).l
	movem.l	(sp)+,a0/a5/a6
	rts

.novalue:
	jsr	(RESETMENUTEXT).l
	movem.l	(sp)+,a0/a5/a6
	rts

; ----
E_Mark1:
	move.l	a2,(Mark1set-DT,a4)
	rts

E_Mark2:
	move.l	a2,(Mark2set-DT,a4)
	rts

E_Mark3:
	move.l	a2,(Mark3set-DT,a4)
	rts

E_Mark4:
	move.l	a2,(Mark4set-DT,a4)
	rts

E_Mark5:
	move.l	a2,(Mark5set-DT,a4)
	rts

E_Mark6:
	move.l	a2,(Mark6set-DT,a4)
	rts

E_Mark7:
	move.l	a2,(Mark7set-DT,a4)
	rts

E_Mark8:
	move.l	a2,(Mark8set-DT,a4)
	rts

E_Mark9:
	move.l	a2,(Mark9set-DT,a4)
	rts

E_Mark10:
	move.l	a2,(Mark10set-DT,a4)
	rts

; ----
E_Jump1:
	move.l	(Mark1set-DT,a4),a1
	bra.b	CF5A

E_Jump2:
	move.l	(Mark2set-DT,a4),a1
	bra.b	CF5A

E_Jump3:
	move.l	(Mark3set-DT,a4),a1
	bra.b	CF5A

E_Jump4:
	move.l	(Mark4set-DT,a4),a1
	bra.b	CF5A

E_Jump5:
	move.l	(Mark5set-DT,a4),a1
	bra.b	CF5A

E_Jump6:
	move.l	(Mark6set-DT,a4),a1
	bra.b	CF5A

E_Jump7:
	move.l	(Mark7set-DT,a4),a1
	bra.b	CF5A

E_Jump8:
	move.l	(Mark8set-DT,a4),a1
	bra.b	CF5A

E_Jump9:
	move.l	(Mark9set-DT,a4),a1
	bra.b	CF5A

E_Jump10:
	move.l	(Mark10set-DT,a4),a1
	bra.b	CF5A

E_not_used:
	rts

CF5A:
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
	lea	(Jumping.MSG).l,a0
	jsr	(printTextInMenuStrip).l
	cmp.l	a2,a1
	bhi.b	CFAA
	bcs.b	CFBC
CF94:
	move.l	d4,(FirstLineNr-DT,a4)
	move.l	a2,(FirstLinePtr-DT,a4)
	lea	(Done.MSG).l,a0
	jsr	(druk_menu_txt_verder).l
CFA8:
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
	move.w	#-1,(Oldcursorcol-DT,a4)		; ***
	move.b	(a3),d0
	cmp.b	#$1A,d0
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
	cmp.b	#$1A,d0
	beq.b	C1006
	cmp.b	#" ",d0
	bls.b	CFEE
	cmp.b	#",",d0
	beq.b	CFEE
C1006:
	rts

; ----
E_Jump1WordBack:
	move.w	#-1,(Oldcursorcol-DT,a4)		; ***
	move.b	(-1,a2),d0
	beq.b	C102C
	cmp.b	#$19,d0
	beq.b	C1062
	cmp.b	#" ",d0
	bls.b	C1030
	cmp.b	#",",d0
	beq.b	C1030
	bsr.w	C13EA
	bra.b	E_Jump1WordBack

C102C:
	bsr.w	C154A
C1030:
	bsr.w	C13EA
	move.b	(-1,a2),d0
	beq.b	C102C
	cmp.b	#$19,d0
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
	bsr.w	C13EA
	bra.b	C104C

C1062:
	rts

; ----
E_Move2BegLine:
	move.w	#0,(Oldcursorcol-DT,a4)		; ***
	move.b	(-1,a2),d0
	beq.b	C107C
	cmp.b	#$19,d0
	beq.b	C107C
	bsr.w	C13EA
	bra.b	E_Move2BegLine

C107C:
	bsr.w	RegTab_SETALLNOTUPD
	clr	(YposScreen-DT,a4)
	rts

; ----
E_Move2EndLine:
	move.w	#-1,(Oldcursorcol-DT,a4)	; ***
	move.b	(a3),d0
	beq.b	C109C
	cmp.b	#$1A,d0
	beq.b	C109C
	bsr.w	E_NextCharacter
 	bra.b	E_Move2EndLine

C109C:
	rts

; ----
E_PageUp:
	jsr	(new2old_stuff).l
	moveq.l	#0,d1
	move	(NrOfLinesInEditor-DT,a4),d1
	subq.w	#1,d1
C10AA:
	bsr.w	MoveupNLines
	bsr.b	C110E
C10B0:
	cmp.l	#1,(FirstLineNr-DT,a4)
	bne.b	C10D8
	clr.l	(LineFromTop-DT,a4)
	tst.b	(PR_Keepxy).l
	beq.b	C10D6
	move	(Oldcursorcol-DT,a4),(NewCursorpos-DT,a4)
	move	(YposScreen-DT,a4),d0
	add	d0,(NewCursorpos-DT,a4)
	bra.w	C14CC

C10D6:
	rts

C10D8:
	move.b	(a3)+,d0
	cmp.b	#$1A,d0
	beq.b	C1106
	move.b	d0,(a2)+
	bne.b	C10D8
	move.l	#1,(LineFromTop-DT,a4)
	tst.b	(PR_Keepxy).l
	beq.b	C1104
	move	(Oldcursorcol-DT,a4),(NewCursorpos-DT,a4)
	move	(YposScreen-DT,a4),d0
	add	d0,(NewCursorpos-DT,a4)
	bra.w	C14CC

C1104:
	rts

C1106:
	clr.l	(LineFromTop-DT,a4)
	subq.w	#1,a3
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

C1120:
	move.b	-(a2),-(a3)
	move.b	-(a2),-(a3)
	move.b	-(a2),-(a3)
	move.b	-(a2),-(a3)
	move.b	-(a2),-(a3)
	move.b	-(a2),-(a3)
	move.b	-(a2),-(a3)
	move.b	-(a2),-(a3)
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

C115C:
	move.b	(a3)+,(a2)+
	move.b	(a3)+,(a2)+
	move.b	(a3)+,(a2)+
	move.b	(a3)+,(a2)+
	move.b	(a3)+,(a2)+
	move.b	(a3)+,(a2)+
	move.b	(a3)+,(a2)+
	move.b	(a3)+,(a2)+
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
	bmi.b	C11E0
	bra.w	MoveDownNLines

; ----
E_PageDown:
	jsr	(new2old_stuff).l
	moveq.l	#0,d1
	move	(NrOfLinesInEditor-DT,a4),d1
	subq.w	#2,d1
	move.l	d1,-(sp)
	bsr.w	MoveDownNLines
	bsr.b	C1146
	move.l	(sp)+,d1
	clr.l	(LineFromTop-DT,a4)
	subq.w	#1,d1
C11AE:
	move.b	(a3)+,d0
	cmp.b	#$1A,d0
	beq.b	C11DE
	move.b	d0,(a2)+
	bne.b	C11AE
	addq.l	#1,(LineFromTop-DT,a4)
	dbra	d1,C11AE

	tst.b	(PR_Keepxy).l
	beq.b	C11DC
	move	(Oldcursorcol-DT,a4),(NewCursorpos-DT,a4)
	move	(YposScreen-DT,a4),d0
	add	d0,(NewCursorpos-DT,a4)
	bra.w	C14CC

C11DC:
	rts

C11DE:
	subq.w	#1,a3
C11E0:
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
	cmp.b	#$19,d0
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
	bsr.b	C124C
	movem.l	(sp)+,a0/a1
	cmp.l	a0,a1
	bne.b	C121C
C122C:
	rts

C122E:
	bsr.w	C13EA
	bsr.w	E_Delete2bol
	bra.w	E_NextCharacter

EDITOR_INSERTCHAR_SETNS:
	bset	#SB1_SOURCE_CHANGED,(SomeBits-DT,a4)
	clr.w	(AssmblrStatus).l			; ***
	move.w	#-1,(Oldcursorcol-DT,a4)		; ***
C124C:
	moveq	#1,d1
	bsr.w	MOVEMARKS
C1252:
	bsr.w	C13F8
	move.b	d0,(a2)+
	rts

C125A:
	bsr.w	C13EA
EDITOR_UPRETURNPRESSED:
	moveq	#0,d0
	cmp.b	#$19,(-1,a2)
	beq.b	C126E
	tst.b	(-1,a2)
	bne.b	C125A
C126E:
	moveq	#1,d1
	bsr.w	MOVEMARKS
C1274:
	bsr.w	C13F8
	move.b	d0,-(a3)
	rts

EDITOR_Backspace:
	bset	#SB1_SOURCE_CHANGED,(SomeBits-DT,a4)
	moveq	#-1,d1
	bsr.w	MOVEMARKS
	move.w	#-1,(Oldcursorcol-DT,a4)		; ***
	move.b	-(a2),d0
	beq.w	C154A
	cmp.b	#$19,d0
	beq.b	C124C
	rts

Delete:
	bset	#SB1_SOURCE_CHANGED,(SomeBits-DT,a4)
	moveq	#-1,d1
	bsr.w	MOVEMARKS
	move.w	#-1,(Oldcursorcol-DT,a4)		; ***
	move.b	(a3)+,d0
	cmp.b	#$1A,d0
	beq.b	C126E
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
	bmi.b	C12F4
	beq.b	C130A
C12DE:
	move	d0,-(sp)
	bsr.w	E_ScrollDown1Line
	bsr.w	C16D8
	addq.l	#1,(LineFromTop-DT,a4)
	move	(sp)+,d0
	subq.w	#1,d0
	bne.b	C12DE
	bra.b	C130A

C12F4:
	neg.w	d0
C12F6:
	move	d0,-(sp)
	bsr.w	E_Scroll1LineUp
	bsr.w	C16D8
	subq.l	#1,(LineFromTop-DT,a4)
	move	(sp)+,d0
	subq.w	#1,d0
	bne.b	C12F6
C130A:
	move	(sp)+,d0
	btst	#0,(PR_LineNrs).l
	beq.b	C1318
	subq.w	#6,d0
C1318:
	moveq	#0,d2
C131A:
	move.b	(a3),d1
	beq.b	C1358
	cmp.b	#$1A,d1
	beq.b	C1358
	cmp.b	#9,d1
	bne.b	C1344
	move.l	d0,-(sp)
	moveq	#-1,d0
	bsr.b	C135A
	tst.b	(B30047-DT,a4)
	beq.b	C133E
	move	d0,d2
	move.l	(sp)+,d0
	bra.b	C1344

C133E:
	or.w	#7,d2
	move.l	(sp)+,d0
C1344:
	cmp	d0,d2
	bge.b	C1358
	addq.w	#1,d2
	movem.w	d0/d2/d3,-(sp)
	bsr.w	E_NextCharacter
	movem.w	(sp)+,d0/d2/d3
	bra.b	C131A

C1358:
	rts

C135A:
	movem.l	d1/a0,-(sp)
	move	d0,d1
	st	(B30047-DT,a4)
	lea	(L2EBC2-DT,a4),a0
C1368:
	move	(a0)+,d0
	beq.b	C1378
	add	d1,d0
	cmp	d2,d0
	bmi.b	C1368
	movem.l	(sp)+,d1/a0
	rts

C1378:
	sf	(B30047-DT,a4)
	movem.l	(sp)+,d1/a0
	rts

C1382:
	movem.l	d0/a0/a1,-(sp)
	lea	(L2EBC2-DT,a4),a1
	move.l	(sourcestart-DT,a4),a0
	cmp.l	#0,a0
	beq.b	C13C8
	cmp.b	#";",(a0)+	;';'
	bne.b	C13C8
	moveq	#0,d0
C139E:
	addq.w	#1,d0
	tst.b	(a0)
	beq.b	C13C8
	cmp.b	#"-",(a0)+	;'-'
	beq.b	C139E
	cmp.b	#" ",(-1,a0)	;' '
	beq.b	C139E
	cmp.b	#"T",(-1,a0)	;'T'
	bne.b	C13C8
	sf	(B30047-DT,a4)
	move	d0,(a1)+
	cmp.l	#L2EC10,a1
	bne.b	C139E
C13C8:
	clr	(a1)
	movem.l	(sp)+,d0/a0/a1
	rts

; ----
E_ArrowRight:
	move.w	#-1,(Oldcursorcol-DT,a4)		; ***
E_NextCharacter:
	move.b	(a3)+,d0
	cmp.b	#$1A,d0
	beq.w	C1274
	bra.w	C1252

; ----
E_ArrowLeft:
	move.w	#-1,(Oldcursorcol-DT,a4)		; ***
C13EA:
	move.b	-(a2),d0
	cmp.b	#$19,d0
	beq.w	C1252
	bra.w	C1274

C13F8:
	cmp.l	a3,a2
	beq.b	C13FE
	rts

C13FE:
	move.l	#$000000FA,a1
EDITOR_MAKEHOLE_A1LONG:
	bset	#SB1_SOURCE_CHANGED,(SomeBits-DT,a4)
	clr	(AssmblrStatus).l
	move.l	(Cut_Blok_End-DT,a4),a0
	move.l	a1,d1
	add.l	a0,a1
	cmp.l	(WORK_END-DT,a4),a1
	bge.b	C142C
	add.l	d1,(sourceend-DT,a4)
	move.l	a1,(Cut_Blok_End-DT,a4)
	move.b	#$1A,(a1)
	bra.b	C14A4

C142C:
	bsr.w	MakeReady2Exit
	jsr	(RESETMENUTEXT2).l
	bsr.w	C164C
	bra.w	_ERROR_WorkspaceMemoryFull

MOVEMARKS:
	cmp.l	(Mark1set-DT,a4),a2
	bgt.b	C1448
	add.l	d1,(Mark1set-DT,a4)
C1448:
	cmp.l	(Mark2set-DT,a4),a2
	bgt.b	C1452
	add.l	d1,(Mark2set-DT,a4)
C1452:
	cmp.l	(Mark3set-DT,a4),a2
	bgt.b	C145C
	add.l	d1,(Mark3set-DT,a4)
C145C:
	cmp.l	(Mark4set-DT,a4),a2
	bgt.b	C1466
	add.l	d1,(Mark4set-DT,a4)
C1466:
	cmp.l	(Mark5set-DT,a4),a2
	bgt.b	C1470
	add.l	d1,(Mark5set-DT,a4)
C1470:
	cmp.l	(Mark6set-DT,a4),a2
	bgt.b	C147A
	add.l	d1,(Mark6set-DT,a4)
C147A:
	cmp.l	(Mark7set-DT,a4),a2
	bgt.b	C1484
	add.l	d1,(Mark7set-DT,a4)
C1484:
	cmp.l	(Mark8set-DT,a4),a2
	bgt.b	C148E
	add.l	d1,(Mark8set-DT,a4)
C148E:
	cmp.l	(Mark9set-DT,a4),a2
	bgt.b	C1498
	add.l	d1,(Mark9set-DT,a4)
C1498:
	cmp.l	(Mark10set-DT,a4),a2
	bgt.b	C14A2
	add.l	d1,(Mark10set-DT,a4)
C14A2:
	rts

C14A4:
	move.l	a0,d1
	sub.l	a3,d1
	bra.b	C14BA

C14AA:
	move.b	-(a0),-(a1)
	move.b	-(a0),-(a1)
	move.b	-(a0),-(a1)
	move.b	-(a0),-(a1)
	move.b	-(a0),-(a1)
	move.b	-(a0),-(a1)
	move.b	-(a0),-(a1)
	move.b	-(a0),-(a1)
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
	rts

C14CC:
	bsr.b	C14D6
	bsr.w	C13EA
	bsr.b	C14D6
	bra.b	C14FA

C14D6:
	tst.b	(-1,a2)
	beq.b	C14EA
	cmp.b	#$19,(-1,a2)
	beq.b	C14EA
	bsr.w	C13EA
	bra.b	C14D6

C14EA:
	rts

C14EC:
	cmp.b	#$1A,(a3)
	beq.b	C14FA
	bsr.w	E_NextCharacter
	tst.b	d0			; *** Loop to the end of the line
	bne.b	C14EC
C14FA:
	move	(NewCursorpos-DT,a4),d3
	clr	d2
	bra.b	C1532

C1502:
	tst.b	(a3)
	beq.b	C1536
	cmp.b	#$1A,(a3)
	beq.b	C1536
	bsr.w	E_NextCharacter
	cmp.b	#9,d0
	bne.b	C1530
	move.l	d0,-(sp)
	moveq	#-1,d0
	bsr.w	C135A
	tst.b	(B30047-DT,a4)
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
	bsr.b	C14CC
C154A:
	bsr.w	C16D8
	cmp.b	#$19,(-1,a2)
	beq.b	C158C
	cmp.l	#1,(FirstLineNr).l
	beq.b	C158C
	cmp.l	#1,(LineFromTop-DT,a4)
	bne.b	C158C
	bsr.w	Show_Cursor
	bset	#SB3_COMMANDMODE,(SomeBits3-DT,a4)	;in commandmode
	jsr	(ScrollEditorDown).l
	bsr.w	GoBack1Line
	bsr.b	Regeltab_scrolldown
	move	#$00FF,(SCROLLOKFLAG-DT,a4)
	jsr	(new2old_stuff).l
C158C:
	rts

; ----
E_ScrollDown1Line:	; editor scroll up
	tst.b	(PR_Keepxy).l
	beq.b	C159C
	move	(Oldcursorcol-DT,a4),(NewCursorpos-DT,a4)
C159C:
	bsr.w	C14EC
	cmp.b	#$1A,(a3)
	beq.b	C15D4
	moveq	#0,d0					; ***
	move	(NrOfLinesInEditor-DT,a4),d0
	subq.w	#3,d0
	cmp.l	(LineFromTop-DT,a4),d0
	bcc.b	C15D4
	bsr.w	Show_Cursor
	bset	#SB3_COMMANDMODE,(SomeBits3-DT,a4)		;in commandmode
	jsr	(ScrollEditorUp).l
	bsr.w	BeginNextLine
	bsr.b	Regeltab_scrollup
	move	#$00FF,(SCROLLOKFLAG-DT,a4)
	jsr	(new2old_stuff).l
C15D4:
	rts

;** regel tabel bijwerken **

Regeltab_scrollup:
	lea	(RegelPtrsIn-DT,a4),a0
	move	(NrOfLinesInEditor-DT,a4),d0
	subq.w	#2,d0

	move.l	a0,a1
	addq.l	#4,a1
.lopje:
	move.l	(a1)+,(a0)+
	dbra	d0,.lopje
	move.l	#-1,(a0)
	rts

Regeltab_scrolldown:
	lea	(RegelPtrsIn-DT,a4),a0
	move	(NrOfLinesInEditor-DT,a4),d0
	subq.w	#2,d0

	move	d0,d1
	addq.w	#1,d1

;	IF MC020
;	lea	(a0,d1.w*4),a0
;	lea	4(a0),a1
;	ELSE
	
	lsl	#2,d1
	move.l	a0,a1
	addq.l	#4,a1
	add	d1,a0
	add	d1,a1

;	ENDC
.lopje:
	move.l	-(a0),-(a1)
	dbra	d0,.lopje
	move.l	#-1,(a0)
	rts

;**

EDITOR_ESCPRESSED:
	bsr.b	MakeReady2Exit
	jsr	(RESETMENUTEXT2).l
	bsr.b	C164C

	jsr	scroll_up_cmd_fix

	jmp	(CommandlineInputHandler).l

MakeReady2Exit:
	lea	(End_msg).l,a0
	jsr	(druk_status_en_end_af).l
C1634:
	move.l	(FirstLinePtr-DT,a4),a0
	move.l	(LineFromTop-DT,a4),d0
	jsr	(C144E4).l
	move.l	a0,(FirstLinePtr-DT,a4)
	move.l	(Cut_Blok_End-DT,a4),a0
	bra.b	cut_block

C164C:
	move.l	(sourceend-DT,a4),a0
	tst.b	(-1,a0)
	beq.b	C167C
	move.l	(Cut_Blok_End-DT,a4),a1
	move.l	a1,a2
	addq.w	#1,a2
	move.l	a1,d0
	sub.l	a0,d0
	subq.l	#1,d0
C1664:
	move.b	-(a1),-(a2)
	dbra	d0,C1664
	swap	d0
	subq.w	#1,d0
	swap	d0
	bpl.b	C1664
	clr.b	(a0)
	addq.l	#1,(Cut_Blok_End-DT,a4)
	addq.l	#1,(sourceend-DT,a4)
C167C:
	rts

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
	clr	(AssmblrStatus).l
	move.l	a0,d1
	sub.l	a3,d1
	bra.b	Copy_blok_in_source

C16A0:
	move.b	(a3)+,(a2)+
	move.b	(a3)+,(a2)+
	move.b	(a3)+,(a2)+
	move.b	(a3)+,(a2)+
	move.b	(a3)+,(a2)+
	move.b	(a3)+,(a2)+
	move.b	(a3)+,(a2)+
	move.b	(a3)+,(a2)+
Copy_blok_in_source:
	subq.l	#8,d1
	bpl.b	C16A0
	addq.w	#8-1,d1
	bmi.b	C16BE
C16B8:
	move.b	(a3)+,(a2)+
	dbra	d1,C16B8
C16BE:
	move.b	#$1A,(a2)
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
	asl.w	#2,d0
	add	d0,a0
	move.l	#-1,(a0)
	rts

RegTab_SETALLNOTUPD:
	move	(NrOfLinesInEditor-DT,a4),d1
	lea	(RegelPtrsIn-DT,a4),a0
	moveq	#-1,d0
.lopje:
	move.l	d0,(a0)+
	dbra	d1,.lopje
	rts

EDITSCRPRINT:
	cmp.l	(FirstLinePtr-DT,a4),a2
	bcs.b	C1718
	bsr.w	UpdateAllLines
	tst.l	(LineFromTop-DT,a4)
	bne.b	C1728
C1718:
	cmp.l	#1,(FirstLineNr-DT,a4)
	beq.b	C1738
	moveq	#1,d1
	bsr.w	MoveupNLines
	bra.b	EDITSCRPRINT

;************* REGEL IN EDITOR **********

C1728:
	move.l	(LineFromTop-DT,a4),d0
	cmp	(NrOfLinesInEditor_min1-DT,a4),d0
	bcs.b	C1738
	bsr.w	BeginNextLine
	bra.b	EDITSCRPRINT

C1738:
	bsr.b	C16DE
	tst	(SCROLLOKFLAG-DT,a4)
	bmi.w	PrintStatusInfo
	bne.b	C1750
	jsr	(messages_get).l
	bne.w	PrintStatusInfo
C1750:
	clr	(SCROLLOKFLAG-DT,a4)
	movem.l	d0-d7/a0-a3/a5/a6,-(sp)
C1764:
	move.l	(MainWindowHandle-DT,a4),a1
	btst	#7,($001A,a1)		;menustate
	bne.b	C1764
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
	cmp	(NrOfLinesInEditor-DT,a4),d4
	bne.b	C181A
	movem.l	(sp)+,d0-d7/a0-a3/a5/a6

;*************** STATUS LINE ****************
PrintStatusInfo:
	movem.l	d0-d7/a0-a3/a5/a6,-(sp)
	move.l	a2,d6
	move.l	a3,d7

	bsr.w	get_font1	;invul stuff

	bclr	#MB1_REGEL_NIET_IN_SOURCE,(MyBits-DT,a4)
	
	lea	(regel_buffer-DT,a4),a1		;status
	lea.l	(a1),a2

	addq.w	#7,a1

	move.l	(FirstLineNr-DT,a4),d0
	add.l	(LineFromTop-DT,a4),d0
	divu	#10000,d0
	move.l	d0,-(sp)
	bsr.w	TURBOPRLINENB_7DIGIT
	move.l	(sp)+,d0
	swap	d0
	bsr.w	TURBOPRLINENB_4DIGIT

	addq.w	#6,a1

	cmp.b	#MT_DEBUGGER,(menu_tiepe-DT,a4)
	beq.w	C1984
	move	(NewCursorpos-DT,a4),d0
	addq.w	#1,d0
	add	(YposScreen-DT,a4),d0
	bsr.w	TURBOPRLINENB_3DIGIT
C1890:
	add	#8,a1
	move.l	(sourceend-DT,a4),d0
	sub.l	(sourcestart-DT,a4),d0
	add.l	d6,d0
	sub.l	d7,d0
	divu	#10000,d0
	move.l	d0,-(sp)
	bsr.w	TURBOPRLINENB_7DIGIT
	move.l	(sp)+,d0
	swap	d0
	bsr.w	TURBOPRLINENB_4DIGIT

	addq	#8,a1
	movem.l	d1/d3-d7/a0-a6,-(sp)
	move.l	(4).w,a6
	move.l	#$00020002,d1
	;move.l	(4).w,a6			; ***
	jsr	(_LVOAvailMem,a6)
	move.l	d0,d2
	moveq	#0,d1
	jsr	(_LVOAvailMem,a6)		; ***
	movem.l	(sp)+,d1/d3-d7/a0-a6
	lsr.l	#8,d0
	lsr.l	#2,d0
	lsr.l	#8,d2
	lsr.l	#2,d2
	move.l	d2,-(sp)
	bsr.w	TURBOPRLINENB
	move.l	(sp)+,d0
	addq.w	#1,a1
	bsr.w	TURBOPRLINENB
	addq.w	#4,a1

	moveq	#'-',d0
	tst	(AssmblrStatus).l
	beq.b	C1908
	moveq	#'a',d0
	cmp	#1,(AssmblrStatus).l
	beq.b	C1908
	moveq	#'A',d0
C1908:
	bsr.w	FASTSENDONECHAR
	moveq	#'-',d0
	btst	#SB1_SOURCE_CHANGED,(SomeBits-DT,a4)
	beq.b	C1918
	moveq	#'*',d0
C1918:
	bsr.w	FASTSENDONECHAR
	moveq	#'-',d0
	btst	#SB2_MAKEMACRO,(SomeBits2-DT,a4)
	beq.b	C1928
	moveq	#'M',d0
C1928:
	bsr.w	FASTSENDONECHAR

	; *** Block marking or not
	moveq	#'-',d0
	cmp.l	#-1,a6
	beq.b	C1938
	moveq	#'B',d0
C1938:
	bsr.w	FASTSENDONECHAR

	jsr	(GetTheTime).l

	lea	(TimeString).l,a0
	move.w	Scr_br_chars,d7
	sub.w	#10,d7
	lea	(regel_buffer-DT,a4),a1		;status
	lea	(a1,d7.w),a1

;	lea	(7,a1),a1
	moveq	#8-1,d7
.lopje:
	moveq	#0,d0
	move.b	(a0)+,d0
	bsr.w	FASTSENDONECHAR
	dbra	d7,.lopje

	cmp	#$FFFF,(Oldcursorcol-DT,a4)
	bne.b	C197E
	move	(Cursor_col_pos-DT,a4),(Oldcursorcol-DT,a4)
	move	(YposScreen-DT,a4),d0
	add	d0,(Oldcursorcol-DT,a4)
	btst	#0,(PR_LineNrs).l
	beq.b	C197E
	subq.w	#6,(Oldcursorcol-DT,a4)
C197E:
	movem.l	(sp)+,d0-d7/a0-a3/a5/a6
	rts

C1984:
	moveq	#0,d0
	bsr.w	TURBOPRLINENB_3DIGIT
	bra.w	C1890

Show_Cursor:
	movem.l	d7/a5/a6,-(sp)
	move.l	#-1,reset_pos
	jsr	(Place_cursor_blokje).l
	movem.l	(sp)+,d7/a5/a6
	rts

;**********************************************************
;print text in the editor..

druk_wat_in_editor:
	move.l	a0,(-4,a6)
;	bne.s	.drukke
;	rts
	beq.w	clear_2_eol_edit
;.drukke:

	lea	(regel_buffer-DT,a4),a1
	move.l	a1,a2
;	move.l	a1,Edit_begin
;	move.l	a1,a5	;x-offset
	clr.l	Edit_begin
;	sub.l	a3,a3		;x-offset

	lea	(regel_buffer-DT,a4),a1
	move.l	a1,a2

	move	(YposScreen-DT,a4),-(sp)

	btst	#0,(PR_LineNrs).l		;line numbers printen..
	beq.b	Print_LineNbrs

;	bset	#MB1_REGEL_NIET_IN_SOURCE,(MyBits-DT,a4)

	movem.l	d0-a6,-(sp)

	move.l	(FirstLineNr-DT,a4),d0
	add.l	d4,d0

	lea	(regel_buffer-DT,a4),a1
	move.l	a1,a2

	moveq.l	#5-1,d7
.lopje:
	divu.w	#10,d0
	swap	d0
	tst.l	d0
	bne.s	.nietmaskeren
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

;	exg.l	d5,d6
;	moveq.l	#-1,d5
;	moveq.l	#-1,d6
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
	cmp.b	#1,(Scr_NrPlanes-DT,a4)
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
	cmp.b	#'	',d0
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
	cmp.b	#'	',-2(a0)
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
;	cmp.b	#'	',d0
;	beq.w	.verder
	cmp.b	#$1A,d0		;einde source
	beq.w	.verder

	move.w	#SC2_LABEL,(ScColor-DT,a4)
	bset	#SC1_LABEL,(ScBits-DT,a4)
	bra.w	.verder

.label:
	cmp.b	#':',-2(a0)	;d0
	beq.s	.oklabel
	cmp.b	#'	',d0
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
	cmp.b	#'	',d0
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
	cmp.b	#'	',d0
	beq.s	.okop
	cmp.b	#' ',d0
	bne.s	.verder
.okop:
	bsr.w	print_regel_in_editor
	bclr	#SC1_OPCODE,(ScBits-DT,a4)
	lea	(regel_buffer-DT,a4),a1
	move.l	a1,a2

	move.w	#SC2_NORMAAL,(ScColor-DT,a4)
	bra.w	.verder

;.anders:
;	movem.l	a0/d1,-(sp)
;	moveq.l	#0,d1
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
	beq.b	Tab_in_source	;tab gevonden
	cmp.b	#$1A,d0
	beq.w	Edit_eindesource		;einde source
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
	bsr.w	C135A
	tst.b	(B30047-DT,a4)
	beq.b	C1A48
	subq.w	#1,(sp)
	bmi.b	C1A58
	cmp	d2,d0
	bne.b	.lopje
	bra.w	Edit_txt1

C1A48:
	subq.w	#1,(sp)
	bmi.b	C1A58
	move	d2,d0
	and	#7,d0
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
	bsr.w	C135A
	tst.b	(B30047-DT,a4)
	beq.b	C1A7C
	cmp	d2,d0
	bne.b	C1A5A
	bra.w	Edit_txt1

C1A7C:
	move	d2,d0
	and	#7,d0
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
	bsr.w	C135A
	tst.b	(B30047-DT,a4)
	beq.b	C1AB0
	cmp	d2,d0
	bne.b	Tab_in_source
	bra.w	Edit_txt1

C1AB0:
	move	d2,d0
	and	#7,d0
	bne.w	Tab_in_source
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
	exg.l	d5,d6
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
	tst	(sp)+
	cmp	d1,d2
	bmi.w	clear_2_eol_edit
	rts

;********* Druk regel in editor + syntax highlighting **********
print_regel_in_editor:
	movem.l	d0-a6,-(sp)

;	move.l	a2,d0
	move.l	Edit_begin,d0		;x-offset
;	move.l	a3,d0			;x-offset

	move.l	a1,d6
	sub.l	a2,d6		;lengte string
	beq.s	.klaar

;	jsr	test_debug
;	btst	#0,PR_LineNrs
;	beq.s	.nolinenrs
;	addq.l	#6,d0
;.nolinenrs:

	add.l	d6,Edit_begin
;	add.l	d6,a3

	mulu.w	(EFontSize_x-DT,a4),d0
	
	move.w	d4,d1		;y
	mulu.w	(EFontSize_y-DT,a4),d1
	add.w	(Scr_Title_sizeTxt-DT,a4),d1	;!2

	move.l	(GfxBase-DT,a4),a6
	move.l	(Rastport-DT,a4),a1

	jsr	(_LVOMove,a6)			; ***

	moveq.l	#0,d0
	move.w	(ScColor-DT,a4),d0
	bsr.b	get_fontcolor

	lea	(regel_buffer-DT,a4),a0		;edit
	move.w	d6,d0		;count
	jsr	(_LVOText,a6)			; ***

.klaar:
	movem.l	(sp)+,d0-a6
	rts

;d0 hi=bpen low=apen
get_fontcolor:
	movem.l	d0-d2/a0-a2/a6,-(sp)

;	jsr	test_debug

	btst	#MB1_BLOCKSELECT,(MyBits-DT,a4)
	beq.b	.nomarkblok
	bset	#4,d0		;offset block mark
		
.nomarkblok:
	lea	fontcolortab(pc),a1
	move.l	(a1,d0.w),d0

	move.l	(GfxBase-DT,a4),a6
	move.l	(Rastport-DT,a4),a1

	jsr	(_LVOSetAPen,a6)	; ***
	swap	d0
	jsr	(_LVOSetBPen,a6)	; ***
	movem.l	(sp)+,d0-d2/a0-a2/a6
	rts


; 0=grijs 1=zwart 2=wit 3=rood
fontcolortab:
	dc.w	0,1	;SC2_NORMAAL
	dc.w	0,3	;SC2_COMMENTAAR
	dc.w	0,2	;SC2_LABEL
	dc.w	4,2	;SC2_OPCODE

	dc.w	1,2	;INV SC2_NORMAAL
	dc.w	1,3	;INV SC2_COMMENTAAR
	dc.w	1,2	;INV SC2_LABEL
	dc.w	1,3	;INV SC2_OPCODE


	cnop	0,4
Edit_begin:	dc.l	0

;**************************************************

clear_2_eol_edit:
	movem.l	d0-a6,-(sp)

;	sub.l	a2,a1
	move.l	Edit_begin,d6
	clr.l	Edit_begin
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
	jsr	(_LVOMove,a6)	; ***

 	jsr	(_LVOClearEOL,a6)		; ***
	movem.l	(sp)+,d0-a6

	rts


;***********************************************************
;info balk gedoe...

UpdateAllLines:
	move.l	(FirstLinePtr-DT,a4),a0
	lea	(RegelPtrsOut-DT,a4),a5
	move.l	a0,(a5)+

	clr.l	d1
	move	(NrOfLinesInEditor-DT,a4),d1
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
	bsr.w	C135A
	tst.b	(B30047-DT,a4)
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
	movem.l	d0-a6,-(sp)			; ***
	clr	(YposScreen-DT,a4)
	bsr.w	RegTab_SETALLNOTUPD
	movem.l	(sp)+,d0-a6			; ***
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
	beq.w	C1CEA

;	cmp.b	#';',(a0)
;	bne.s	.normal
;	cmp.b	#'-',1(a0)
;	bne.s	.normal
;	bsr.s	Folding
;	beq.w	C1CEA		;einde source
;	bra.b	.Reenter
;.normal:
	move.l	a0,(a5)+
.Reenter:
	dbra	d1,.loopje
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
	beq.b	C1C8E

	cmp	#14,d2
	blt.b	C1CC8
	move.l	d0,-(sp)
	moveq	#0,d0
	move	(Scr_br_chars-DT,a4),d0
	sub	#7,d0
	cmp	d0,d2
	blt.b	C1C8A
	move.l	(sp)+,d0
	bra.b	C1CA4

C1C8A:
	move.l	(sp)+,d0
	bra.b	C1CC0

C1C8E:
	cmp	#8,d2
	blt.b	C1CC8
	move.l	d0,-(sp)
	moveq	#0,d0
	move	(Scr_br_chars-DT,a4),d0
	subq.w	#1,d0
	cmp	d0,d2
	blt.b	C1C8A
	move.l	(sp)+,d0
C1CA4:
	cmp	#$00F8,(YposScreen-DT,a4)
	bge.b	C1CC0
	add	#12,(YposScreen-DT,a4)
	sub	#12,d2
	move.l	d2,(sp)
	bsr.w	RegTab_SETALLNOTUPD
	move.l	(sp)+,d2
	bra.b	C1C64

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

C1CEA:
	clr.l	(a5)+
	dbra	d1,C1CEA
	move.b	d4,-(a1)
	rts

;******** gewoon of inverse font ************

get_font1:
	movem.l	d0-d2/a0-a2/a6,-(sp)
	move.l	(GfxBase-DT,a4),a6
	move.l	(Rastport-DT,a4),a1

	moveq.l	#1,d0		;black
	jsr	(_LVOSetAPen,a6)		; ***
	moveq.l	#0,d0		;grey
	jsr	(_LVOSetBPen,a6)		; ***
	movem.l	(sp)+,d0-d2/a0-a2/a6
	rts

get_font2:
	movem.l	d0-d2/a0-a2/a6,-(sp)
	move.l	(GfxBase-DT,a4),a6
	move.l	(Rastport-DT,a4),a1

	moveq.l	#2,d0		;white
	jsr	(_LVOSetAPen,a6)		; ***
	moveq.l	#1,d0		;black
	jsr	(_LVOSetBPen,a6)		; ***
	movem.l	(sp)+,d0-d2/a0-a2/a6
	rts

get_font3:
	movem.l	d0-d2/a0-a2/a6,-(sp)
	move.l	(GfxBase-DT,a4),a6
	move.l	(Rastport-DT,a4),a1

	moveq.l	#0,d0		;grey
	jsr	(_LVOSetAPen,a6)		; ***
	moveq.l	#1,d0		;black
	jsr	(_LVOSetBPen,a6)		; ***
	movem.l	(sp)+,d0-d2/a0-a2/a6
	rts

get_font4:
	movem.l	d0-d2/a0-a2/a6,-(sp)
	move.l	(GfxBase-DT,a4),a6
	move.l	(Rastport-DT,a4),a1

	moveq.l	#3,d0		;red
	jsr	(_LVOSetAPen,a6)		; ***
	moveq.l	#0,d0		;grey
	jsr	(_LVOSetBPen,a6)		; ***
	movem.l	(sp)+,d0-d2/a0-a2/a6
	rts

get_font5:
	movem.l	d0-d2/a0-a2/a6,-(sp)
	move.l	(GfxBase-DT,a4),a6
	move.l	(Rastport-DT,a4),a1

	moveq.l	#3,d0		;red
	jsr	(_LVOSetAPen,a6)		; ***
	moveq.l	#1,d0		;black
	jsr	(_LVOSetBPen,a6)		; ***
	movem.l	(sp)+,d0-d2/a0-a2/a6
	rts


;********** print de chars in status bar (+linenrs)  **********

printable_char2:
        dc.b    "   ",0

FASTSENDONECHAR:
	movem.l	d0-a6,-(sp)
	lea	printable_char2,a0
	move.b	d0,(a0)

	sub.l	a2,a1
	move.l	a1,d6	;x
	move.w	d4,d7	;y

jump_in:
	move.l	(GfxBase-DT,a4),a6
	move.l	(Rastport-DT,a4),a1

	move.w	d6,d0		;x
	mulu.w	(EFontSize_x-DT,a4),d0

	move.w	d7,d1		;y
	btst	#MB1_REGEL_NIET_IN_SOURCE,(MyBits-DT,a4)
	bne.s	.okay
	move	(NrOfLinesInEditor-DT,a4),d1
	mulu.w	(EFontSize_y-DT,a4),d1
	addq.l	#2,d1
	bra.b	.okay2
.okay:
	mulu.w	(EFontSize_y-DT,a4),d1
.okay2:
	add.w	(Scr_Title_sizeTxt-DT,a4),d1	;!2
	jsr	(_LVOMove,a6)		; ***


	lea     printable_char2,a0
	moveq.l	#1,d0		;count
	jsr	(_LVOText,a6)		; ***

	movem.l	(sp)+,d0-a6
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
	bsr.w	FASTSENDONECHAR
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
	move.l	a0,a2
	addq.l	#1,a2
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
	lea	(Registersused.MSG).l,a0
	jsr	(printTextInMenuStrip).l
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
	lea	(NONE.MSG).l,a0
	jsr	(druk_menu_txt_verder).l
	bra.b	C1F0E

C1F2C:
	moveq	#$30,d1
C1F2E:
	lsr.w	#1,d5
	bcc.b	C1F4A
	move	d2,d0
	jsr	(C149F0).l
	move	d1,d0
	jsr	(C149F0).l
	moveq	#" ",d0
	jsr	(C149F0).l
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
	cmp.b	#$19,d0
	bne.b	C1F6C
C1F76:
	rts

C1F78:
	cmp.l	a0,a2
	beq.b	C1F92
	move.b	(a0)+,d0
	cmp.b	#$1A,d0
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
	lea	-1.l,a0
	cmp.l	a0,a6
	bne.w	E_RemoveCutMarking
	move.l	a2,a6			; *** Start address
;	bsr	C14EC
;	bsr	C14CC
;	bsr	C16D8
	bra.w	RegTab_SETALLNOTUPD

; ----
E_Cut_Block:
	moveq	#0,d1
	cmp.l	#-1,a6
	beq.b	.NOBEGIN

	cmp.l	a6,a2			; *** Empty block ?
	beq.b	.NOBEGIN
	bgt.b	.wrongway
	exg.l	a2,a6
	move.b	#1,(BlokBackwards-DT,a4)
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
	move.b	#$1A,(a0)
	move.l	a0,(Cut_Blok_End-DT,a4)
.NOBEGIN:
	clr.b	(BlokBackwards-DT,a4)
	bra.w	E_RemoveCutMarking

; ----
E_Copy_blok:
	move.l	(Mark1set-DT,a4),-(sp)
	move.l	(Mark2set-DT,a4),-(sp)
	move.l	(Mark3set-DT,a4),-(sp)
	move.l	(Mark4set-DT,a4),-(sp)
	move.l	(Mark5set-DT,a4),-(sp)
	move.l	(Mark6set-DT,a4),-(sp)
	move.l	(Mark7set-DT,a4),-(sp)
	move.l	(Mark8set-DT,a4),-(sp)
	move.l	(Mark9set-DT,a4),-(sp)
	move.l	(Mark10set-DT,a4),-(sp)
	move.l	a2,-(sp)
	bsr.w	E_Cut_Block
	bclr	#SB1_SOURCE_CHANGED,(SomeBits-DT,a4)
	move.l	(sp)+,a2
	move.l	(sp)+,(Mark10set-DT,a4)
	move.l	(sp)+,(Mark9set-DT,a4)
	move.l	(sp)+,(Mark8set-DT,a4)
	move.l	(sp)+,(Mark7set-DT,a4)
	move.l	(sp)+,(Mark6set-DT,a4)
	move.l	(sp)+,(Mark5set-DT,a4)
	move.l	(sp)+,(Mark4set-DT,a4)
	move.l	(sp)+,(Mark3set-DT,a4)
	move.l	(sp)+,(Mark2set-DT,a4)
	move.l	(sp)+,(Mark1set-DT,a4)
	rts

; ----
E_SmartPast:
	move	(NewCursorpos-DT,a4),-(sp)
	bsr.b	E_Fill
	bsr.w	E_Move2BegLine
	move	(sp)+,(NewCursorpos-DT,a4)
	bra.w	C14EC

; ----
E_ClipPast:
	IF	CLIPBOARD

	move.l	(sourceend-DT,a4),a0
;	move.l	(Cut_Blok_End-DT,a4),a1
	addq.w	#1,a0
;	sub.l	a0,a1

	movem.l	a0/a2-a6,-(sp)
	bsr	SetupClipboard
	bsr	ClipGetLength	;a1 is lengte (a1=0 -> error)
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

;	jsr	test_debug

	bsr	ClipRead2Buf
	add.l	d4,a0
	add.l	d4,a2

;	jsr	test_debug

	bset	#SB1_SOURCE_CHANGED,(SomeBits-DT,a4)
.End:
	br	RegTab_SETALLNOTUPD

ClipRead2Buf:
	movem.l	a0/a2-a6,-(sp)
	move.l	4.w,a6				; ***
	move.l	ClipIoReq,a1
	move.l	a2,io_Data(a1)
	move.l	dataheader+16,io_Length(a1)
	jsr	_LVODoIO(a6)
	movem.l	(sp)+,a0/a2-a6
	rts

ClipGetLength:
	move.l	4.w,a6				; ***
	move.l	ClipIoReq,a1
	move.l	#0,io_Offset(a1)
	move.b	#0,io_Error(a1)
	move.l	#0,io_ClipID(a1)

	move.w	#CMD_READ,io_Command(a1)
	move.l	#dataheader,io_Data(a1)
	move.l	#20,io_Length(a1)
	jsr	_LVODoIO(a6)

	;"FORMxxxxFTXTCHRSxxxx"
	cmp.l	#'FTXT',dataheader+8
	bne.s	.errorNoTxt
	cmp.l	#'CHRS',dataheader+12
	bne.s	.errorNoTxt
	move.l	dataheader+16,a1
	rts

.errorNoTxt:
;	move.l	#0,a1	;noclip
	sub.l	a1,a1
	rts

FinishClipboard:
	move.l	$4.w,a6
	;read with offset past the end of the clip to signify the end..
	move.l	ClipIoReq,a1
	move.w	#CMD_READ,io_Command(a1)
	move.l	#0,io_Data(a1)
	move.l	#1,io_Length(a1)
	jsr	_LVODoIO(a6)
	rts

CloseClipboard:
	move.l	4.w,a6				; ***
;	move.l	ClipIoReq(pc),a1
;	jsr	_LVOAbortIO(a6)
	move.l	ClipIoReq(pc),a1
	jsr	_LVOCloseDevice(a6)

	move.l	ClipIoReq,a0
	jsr	_LVODeleteIORequest(a6)

	move.l	ClipMsgport(pc),a0
	jsr	_LVODeleteMsgPort(a6)
	rts


SetupClipboard:
	move.l	4.w,a6					; ***
	jsr	_LVOCreateMsgPort(a6)
	move.l	d0,ClipMsgport

	move.l	d0,a0		;msg port
	moveq.l	#iocr_SIZEOF,d0		;size
	jsr	_LVOCreateIORequest(a6)
	move.l	d0,ClipIoReq

	moveq.l	#0,d0		;unit
	lea	clipname(pc),a0
	moveq.l	#0,d1		;flags
	move.l	ClipIoReq(pc),a1	;ioRequest
	jsr	_LVOOpenDevice(a6)
	rts


clipname:
	dc.b	"clipboard.device",0

	cnop	0,4
ClipMsgport:	dc.l	0
ClipIoReq:	dc.l	0

dataheader:	blk.b	20

;***************************************************
;	ELSE
	ENDIF

; ----
E_Fill:
	move.l	(sourceend-DT,a4),a0
	move.l	(Cut_Blok_End-DT,a4),a1
	addq.l	#1,a0				; ***
	sub.l	a0,a1
	tst.l	a1
	bgt.b	.ok				;Fixed pointer bug when pasting
	rts
.ok

	move.l	a1,d4
	move.l	a3,d0
	sub.l	a2,d0
	cmp.l	d4,d0
	bcc.b	.DontOpen
	cmp.l	#256,d0
	bcc.b	.NotExtra
	lea.l	256(a1),a1			; *** Was add.w
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
	bcs.b	.End
	sub.l	a0,a1
	move.l	a1,d0
	move.l	d0,d1
	move.l	d1,-(a7)			; ***
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
	move.l	(a7),d1				; ***
	; Check if the editor should scroll down
	; by counting the number of line(s) we have
	; in the copy block and checking it with the caret position
	move.l	d2,-(a7)
	; (At least one line without EOL)
	moveq	#1,d2
	bsr.b	MoveDownNChars
	; d1=number of lines added
	move.l	d2,d1
	move.l	(a7)+,d2
	; Restore the values
	moveq	#0,d0					; ***
	move	(NrOfLinesInEditor-DT,a4),d0
	subq.w	#1,d0
	sub.l	d1,d0
	cmp.l	(LineFromTop-DT,a4),d0
	bcc.b	.NoScrollFill
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
.lopje:
	move.b	(a0)+,d0
	subq.l	#1,d1
	beq.b	.end
	cmp.b	#$1A,d0
	beq.b	.end
	tst.b	d0
	bne.b	.lopje
	addq.l	#1,d2
	jmp	.lopje
.end:	rts

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
	bclr	#SB3_EDITORMODE,(SomeBits3-DT,a4)	;uit editor
	moveq	#7,d0
	jsr	scroll_up_cmd_fix	;;
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
	moveq	#" ",d3
	bra.b	C216E

E_UppercaseBlock:
	moveq	#"a",d1
	moveq	#"z",d2
	move.b	#-$20,d3

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
	lea	-1.l,a6
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
	move.b	(a6)+,d0
	cmp.b	d1,d0
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
	rts

E_Delete2bol:
	move.b	(-1,a2),d0
	beq.b	.end
	cmp.b	#$19,d0
	beq.b	.end
	bsr.w	EDITOR_Backspace
	bra.b	E_Delete2bol

.end:
	rts

E_Delete2eol:
	move.b	(a3),d0
	beq.b	.end
	cmp.b	#$1A,d0
	beq.b	.end
	bsr.w	Delete
	bra.b	E_Delete2eol

.end:
	rts

;**********************
;*   SEARCH REPLACE   *
;**********************

E_Search:
	move	#-1,(Oldcursorcol-DT,a4)
	move.b	#0,(LastFoundLine-DT,a4)
	move.l	(FirstLineNr-DT,a4),d0
	add.l	(LineFromTop-DT,a4),d0
	move.l	d0,(OldLinePos-DT,a4)
	clr.l	(OldCursorpos-DT,a4)
	bsr.w	EDITOR_SEARCH
	bra.b	Show_lastline

E_Search2:
	move	#-1,(Oldcursorcol-DT,a4)
	move.b	#0,(LastFoundLine-DT,a4)
	move.l	(FirstLineNr-DT,a4),d0
	add.l	(LineFromTop-DT,a4),d0
	move.l	d0,(OldLinePos-DT,a4)
	clr.l	(OldCursorpos-DT,a4)
	bsr.w	editor_gosearch2
	bra.b	Show_lastline


E_RepeatReplace:
	move	#-1,(Oldcursorcol-DT,a4)
	move.b	#0,(LastFoundLine-DT,a4)
	move.l	(FirstLineNr-DT,a4),d0
	add.l	(LineFromTop-DT,a4),d0
	move.l	d0,(OldLinePos-DT,a4)
	clr.l	(OldCursorpos-DT,a4)
	bsr.w	RepeatReplace
	bra.b	Show_lastline

E_Replace:
	move	#-1,(Oldcursorcol-DT,a4)
	move.b	#0,(LastFoundLine-DT,a4)
	move.l	(FirstLineNr-DT,a4),d0
	add.l	(LineFromTop-DT,a4),d0
	move.l	d0,(OldLinePos-DT,a4)
	clr.l	(OldCursorpos-DT,a4)
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
	bsr.w	JUMPTOLINE
.noJump:
	rts


;****************************************************************
;; Changes stuff like move.l #$534F4C4F,d0 -> move.l #"SOLO",d0

E_Hex2Ascii:
;	jsr	test_debug
Nr2Ascii:
	moveq.l	#0,d0
	moveq.l	#0,d1
	moveq.l	#0,d3

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
	sub.b	#7,d0
.hok:
	lsl.l	#4,d1
	add.l	d0,d1

	bra.b	.hex


.dec:
	rts

.klaar:
	move.l	d3,-(sp)

	moveq.l	#0,d0
	moveq.l	#0,d2
	moveq.l	#0,d3		;non ascii shift value :)
	moveq.l	#2,d4		;str length '""'

	move.l	(sourceend-DT,a4),a1
	addq.l	#1,a1
	move.b	#'"',(a1)+
	moveq.l	#4-1,d7
.hloop:
	rol.l	#8,d0
	rol.l	#8,d1

	tst.w	d3
	bne.s	.nomoreascii

	btst	#7,d1
	beq.s	.low

	bset	#7,d0
	bclr	#7,d1
.low:
	cmp.b	#" ",d1
	bhs.s	.printeable

.nomoreascii:
	btst	#31,d2		;remove trailing zero's
	beq.s	.noshiftt
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
	bhi.w	moreThan4BytesError		;error if more than 4 bytes

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
	move.b	d0,d1
	and.b	#$0f,d1
	bne.s	.notZero
	
	btst	#31,d2
	beq.s	.nextnr
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
	move.b	#0,(a1)		;end of string

	move.l	(sourceend-DT,a4),a0
	add.l	d4,a0
	addq.l	#1,a0
	move.l	a0,(Cut_Blok_End-DT,a4)


	bsr.w	E_Fill
	bsr.w	KillCopybuffer

	move.l	(sp)+,d3
	subq.w	#1,d3
.lopje2
	bsr.w	Delete
	dbf	d3,.lopje2

	bset	#SB1_SOURCE_CHANGED,(SomeBits-DT,a4)
	bsr.w	RegTab_SETALLNOTUPD
	rts


notAPrintableAsciiChar:
moreThan4BytesError:
	rts


;************************************************************8

E_SearchAndReplace:
	movem.l	d1/a0/a5/a6,-(sp)
	move.b	#0,(CaseSenceSearch).l
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
	jsr	(_LVOrtGetStringA,a6)		; ***
	cmp	#1,d0
	beq.b	C235E
	move.b	#1,(CaseSenceSearch).l
	cmp	#2,d0
	beq.b	C235E
	movem.l	(sp)+,d0/a0-a3/a6
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
	lea	(B1E909).l,a1
C2380:
	tst.b	(a0)
	beq.b	Druk_andreplace
	move.b	(a0)+,(a1)+
	bra.b	C2380

Druk_andreplace:
	lea	(andreplaceitw.MSG).l,a0
.lopje:
	move.b	(a0)+,(a1)+
	tst.b	(a0)
	bne.b	.lopje
	move.b	#0,(a1)
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
	jsr	(_LVOrtGetStringA,a6)		; ***
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
	bclr	#SB1_REPLACE_GLOB,(SomeBits-DT,a4)
	bclr	#SB1_REPLACE_ONE,(SomeBits-DT,a4)
ReplaceNoQuestionsAsked:
C2408:
	cmp.b	#0,(-1,a2)
	bne.b	C2416
	sub.l	#1,(FirstLineNr-DT,a4)
C2416:
	bsr.w	C13EA
C241A:
	bsr.w	EDITOR_SEARCH
	movem.l	d1/a0/a5/a6,-(sp)
	cmp.b	#$1A,(a2)
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
	sub.l	a4,a4
	sub.l	a3,a3
	lea	(L1E83A).l,a0
	jsr	(_LVOrtEZRequestA,a6)		; ***
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
	lea	(ReplaceYNLG.MSG).l,a0
	jsr	(printTextInMenuStrip).l
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
	bset	#SB1_SOURCE_CHANGED,(SomeBits-DT,a4)
	bset	#SB1_REPLACE_GLOB,(SomeBits-DT,a4)
	move	#$FFFF,(SCROLLOKFLAG-DT,a4)
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
	bset	#SB1_REPLACE_ONE,(SomeBits-DT,a4)
	bset	#SB1_SOURCE_CHANGED,(SomeBits-DT,a4)
	bra.b	ReplaceGedoe

C2512:
	bsr.w	C124C

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
	bclr	#SB1_REPLACE_GLOB,(SomeBits-DT,a4)
	bclr	#SB1_REPLACE_ONE,(SomeBits-DT,a4)
	clr	(SCROLLOKFLAG-DT,a4)
	movem.l	(sp)+,d1/a0/a5/a6
	rts

editor_gosearch2:
	movem.l	a0/a5/a6,-(sp)
	move.b	#0,(CaseSenceSearch).l
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
	jsr	(_LVOrtGetStringA,a6)		; ***
	cmp	#1,d0
	beq.b	SEARCHFOR
	move.b	#1,(CaseSenceSearch).l
	cmp	#2,d0
	beq.b	SEARCHFOR
	movem.l	(sp)+,d0/a0-a3/a6
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
	bsr.b	EDITOR_SEARCH
	rts

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
;	moveq	#0,d1
	move.l	(FirstLineNr-DT,a4),d1
;	and.l	#$0000FFFF,d0

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
	movem.l	d1-d3/a0/a5/a6,-(sp)
	lea	MAINDATA,a6	;search for ";;"
	bra.b	MAINJUMP

;*******************
;*  EDITOR SEARCH  *
;*******************

EDITOR_SEARCH:
	movem.l	d1-d3/a0/a5/a6,-(sp)
	lea	(SourceCode-DT,a4),a6	;search string
MAINJUMP:
	lea	(Searching.MSG).l,a0
	jsr	(printTextInMenuStrip).l
	move.l	(LineFromTop-DT,a4),d0
	add.l	d0,(FirstLineNr-DT,a4)
	cmp.b	#$1A,(a3)
	beq.w	.THEEND2
	move.b	(a3)+,(a2)+
	bne.b	.NOTNEW
	addq.l	#1,(FirstLineNr-DT,a4)
.NOTNEW:
	move.b	(a6)+,d2
	beq.b	.THEEND
	move.b	d2,d3
	cmp.b	#"A",d2
	bcs.b	.SET
	move.b	d2,d3
	add.b	#" ",d3
.SET:
	move.l	a6,a5
.LOOP0:
	move.b	(a3)+,d0
	move.b	d0,(a2)+
	bne.b	.NOTLINEEND
	addq.l	#1,(FirstLineNr-DT,a4)
	bra.b	.LOOP0

.NOTLINEEND:
	cmp.b	#$1A,d0
	beq.b	.THEENDB
	cmp.b	d3,d0
	beq.b	.SKIPA
	cmp.b	d2,d0
	bne.b	.LOOP0
.SKIPA:
	move.l	a5,a6
	move.l	a3,a0
.LOOP3:
	move.b	(a6)+,d0
	beq.b	.THEEND
	move.b	(a0)+,d1
	cmp.b	#"a",d1
	bcs.b	.SKIP2
	btst	#0,(CaseSenceSearch).l
	bne.b	.SKIP2
	sub.b	#" ",d1
.SKIP2:
	cmp.b	d0,d1
	bne.b	.LOOP0
	bra.b	.LOOP3

.THEEND:
	pea	(Found.MSG).l
	move	#-1,(Oldcursorcol-DT,a4)
	move.b	#1,(LastFoundLine-DT,a4)
	move.l	(FirstLineNr-DT,a4),(OldCursorpos-DT,a4)
	bra.b	.THEENDB2

.THEENDB:
	pea	(Not.MSG).l
	move.b	#0,(LastFoundLine-DT,a4)
.THEENDB2:
	move.b	-(a2),-(a3)
	bne.b	.THEEND2B
	subq.l	#1,(FirstLineNr-DT,a4)
	bra.b	.THEEND2B

.THEEND2:
	pea	(Not.MSG).l
	move.b	#0,(LastFoundLine-DT,a4)
.THEEND2B:
	move.l	(sp)+,a0
	jsr	(druk_menu_txt_verder).l
	movem.l	(sp)+,d1-d3/a0/a5/a6
	move.l	a2,a0
.LOOP4:
	move.b	-(a0),d0
	beq.b	.FOUND
	cmp.b	#$19,d0
	bne.b	.LOOP4
.FOUND:
	addq.l	#1,a0
	move.l	a0,(FirstLinePtr-DT,a4)
	rts

;************************
;*    BUTTOM OF TEXT    *
;************************

E_GotoBottom:
	move	#0,(Oldcursorcol-DT,a4)
	lea	(Bottomoftext.MSG).l,a0
	jsr	(printTextInMenuStrip).l
	movem.l	d1/d2,-(sp)
	move.l	(sourceend).l,a0
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
	lea	(Done.MSG).l,a0
	jmp	(druk_menu_txt_verder).l

E_GotoTop:
	move	#0,(Oldcursorcol-DT,a4)
	lea	(Topoftext.MSG).l,a0
	jsr	(printTextInMenuStrip).l
	move.l	#1,(FirstLineNr-DT,a4)
	move.l	(sourcestart-DT,a4),a0
	move.l	a0,(FirstLinePtr-DT,a4)
	cmp.l	a2,a0
	beq.b	C276E
C2768:
	move.b	-(a2),-(a3)
	cmp.l	a2,a0
	bne.b	C2768
C276E:
	lea	(Done.MSG).l,a0
	jmp	(druk_menu_txt_verder).l

E_100LinesUp:
	move	#100,d1
	bsr.w	C10AA
	jmp	(new2old_stuff).l

E_100LinesDown:
	moveq.l	#100-1,d1
	bsr.w	MoveDownNLines
	bsr.w	C1146
	bsr.w	C10B0
	jmp	(new2old_stuff).l


;;******  ASSEMBLER ROUTINE BOTH TEXT AND LINE  *********

LINE_MEMASSEM:
	clr.b	(B30040-DT,a4)
	cmp.b	#$7B,(a6)
	bne.b	.C27B0
	move.b	#1,(B30040-DT,a4)
	addq.w	#1,a6
.C27B0:
	jsr	GETNUMBERAFTEROK
	beq.b	.A_VALUE
	move.l	(MEM_DIS_DUMP_PTR-DT,a4),d0
.A_VALUE:
	tst.b	(B30040-DT,a4)
	beq.b	C27EE
	cmp.b	#1,(OpperantSize-DT,a4)
	beq.b	C27D4
	tst	(ProcessorType-DT,a4)
	bne.b	C27D4
	bclr	#0,d0
C27D4:
	move.l	a5,-(sp)
	move.l	d0,a5
	move.l	(a5),d0
	cmp.b	#1,(OpperantSize-DT,a4)
	beq.b	C27EC
	tst	(ProcessorType-DT,a4)
	bne.b	C27EC
	bclr	#0,d0
C27EC:
	move.l	(sp)+,a5
C27EE:
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
	jsr	(Druk_af_D0).l
	jsr	INPUTTEXT_NOTEXT
	cmp.b	#$1B,d0
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
	beq.b	einderegel	'eol'
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
	add	#$200,a0
	move.b	#$7E,(a0)+
	move.l	a0,(LabelStart-DT,a4)
	btst	#0,(PR_Upper_LowerCase).l
	bne.b	.upper
	
	move	#64*80*4,d2
	moveq	#'a',d0
	move	#64,(Label1Entry-DT,a4)
	move	#80,(Label2Entry-DT,a4)
	move	#2,(LabelRollValue-DT,a4)
	bra.b	C2902

.upper:
	move	#28*48*4,d2
	moveq	#'A',d0
	move	#28,(Label1Entry-DT,a4)
	move	#48,(Label2Entry-DT,a4)
	move	#1,(LabelRollValue-DT,a4)
C2902:
	lea	(ALPHA_ONE-DT,a4),a1
	lea	(ALPHA_Two,pc),a2
	moveq	#'Z'-'A',d1
C290C:
	move.b	d0,(a1)+
	move.b	d0,(a2)+
	addq.b	#1,d0
	dbra	d1,C290C
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
C2932:
	move.l	d1,(a0)+
	dbra	d2,C2932
	lea	(SPECIAL_SYMBOL_NARG-DT,a4),a0
	move	(Label2Entry-DT,a4),d0
	mulu	#14,d0
	add	#17,d0

	IF MC020
	move.l	a0,(a1,d0.w*4)
	ELSE
	lsl.w	#2,d0
	move.l	a0,(a1,d0.w)
	ENDC

	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move	#$D247,(a0)+
	move.l	d1,(a0)+
	move	d1,(a0)+
	move.l	(LabelStart-DT,a4),a0
	move.b	#$7F,-(a0)
	move	#$0050,(PageWidth-DT,a4)
	move	(ScreenHight-DT,a4),(PageHeight-DT,a4)
	rts

ASSEM_RESET_SECTIONS:
	bsr.b	C2994
	moveq	#0,d0
	lea	(SECTION_START_DEFINITION).l,a0
	move.l	a0,(SectionTreePtr-DT,a4)
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	addq.w	#4,a0
	move	#1,(a0)
	clr	(CurrentSection-DT,a4)
	clr	(NrOfSections-DT,a4)
	moveq	#0,d6
	bra.b	C29D2

C2994:
	lea	SECTION_ABS_LOCATION-DT+4(a4),a0
	lea	SECTION_ORG_ADDRESS-DT+4(a4),a1
	lea	SECTION_TYPE_TABLE-DT+1(a4),a2
	lea	SECTION_OLD_ORG_ADDRESS-DT+4(a4),a3
	moveq	#0,d3
	move	#$00FE,d4
	moveq	#6,d2
C29AC:
	btst	d2,(a2)
	beq.b	C29C4
	movem.l	a0/a1,-(sp)
	move.l	(a3),d0
	move.l	(a0),a1
	move.l	(4).w,a6
	jsr	(_LVOFreeMem,a6)
	movem.l	(sp)+,a0/a1
C29C4:
	move.l	d3,(a0)+
	move.l	d3,(a1)+
	move.b	d3,(a2)+
	move.l	d3,(a3)+
	dbra	d4,C29AC
	rts

C29D2:
	cmp	#$00FF,(NrOfSections-DT,a4)
	beq.w	_ERROR_Sectionoverflow
	add.b	#1,(NrOfSections+1-DT,a4)
	move	(NrOfSections-DT,a4),d0
	lea	(SECTION_TYPE_TABLE-DT,a4),a0
	move.b	d6,(a0,d0.w)
C29EE:
	move	d0,(LastSection-DT,a4)
C29F2:
	move	d0,(CurrentSection-DT,a4)
	lea	(SECTION_TYPE_TABLE-DT,a4),a0
	move.b	(a0,d0.w),(CURRENT_SECTION_TYPE-DT,a4)
	bpl.b	C2A12
	bset	#AF_BSS_AREA,d7
	lea	(ConditionAssembl).l,a0
	move.l	a0,(Asm_Table_Base-DT,a4)
	bra.b	C2A1E

C2A12:
	bclr	#AF_BSS_AREA,d7
	lea	(Asm_Table,pc),a0
	move.l	a0,(Asm_Table_Base-DT,a4)
C2A1E:
	lea	(SECTION_ORG_ADDRESS-DT,a4),a0

	IF MC020
	lea	(a0,d0.w*4),a0	
	ELSE
	lsl.w	#2,d0
	add	d0,a0
	ENDC
	
	move.l	(a0),(INSTRUCTION_ORG_PTR-DT,a4)
	add	#$FC00,a0
	move.l	(a0),(CURRENT_ABS_ADDRESS-DT,a4)
	rts

ASSEM_RESTORE_OLD_SECTION:
	move	(CurrentSection-DT,a4),d0
	beq.b	C2A46
	lea	(SECTION_ORG_ADDRESS-DT,a4),a0

	IF MC020
	lea	(a0,d0.w*4),a0	
	ELSE
	lsl.w	#2,d0
	add	d0,a0
	ENDC

	move.l	(INSTRUCTION_ORG_PTR-DT,a4),(a0)
C2A46:
	rts

ASSEM_INIT_SECTION_AREAS:
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
	move.b	(a2)+,d4
	and.b	#3,d4
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
	bset	#6,(-1,a2)
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
	bra.w	C29EE

C2AD4:
	moveq	#0,d7
	bset	#AF_OPTIMIZE,d7
	lea	(OptionOOptimi.MSG).l,a0
	jsr	(printthetext).l
	move.l	(sourcestart-DT,a4),(FirstLinePtr-DT,a4)
	move.l	#1,(FirstLineNr-DT,a4)
	bra.w	Asmbl_Optimize

C2AF6:
	moveq	#0,d7
	bset	#AF_DEBUG1,d7
	bra.w	Asmbl_Optimize

ASSEM_SET_PREFS:
	btst	#0,(PR_ListFile).l
	beq.b	C2B0E
	bset	#AF_LISTFILE,d7
C2B0E:
	btst	#0,(PR_AllErrors).l
	beq.b	C2B1C
	bset	#AF_ALLERRORS,d7
C2B1C:
	btst	#0,(PR_Debug).l
	beq.b	C2B2A
	bset	#AF_DEBUG1,d7
C2B2A:
	btst	#0,(PR_Label).l
	beq.b	C2B38
	bset	#AF_LABELCOL,d7
C2B38:
	btst	#0,(PR_Comment).l
	beq.b	C2B46
	bset	#AF_SEMICOMMENT,d7
C2B46:
	btst	#0,(PR_Warning).l
	beq.b	C2B54
	bset	#AF_PROCESRWARN,d7
C2B54:
	rts

com_assemble:
	move.b	(a6)+,d0
	bclr	#5,d0
	cmp.b	#"S",d0		;'S' assemble source <nr>
	beq.b	SetActiveSourcebuf
	lea	(AsmErrorTable-DT,a4),a1
	move.l	a1,(AsmErrorPos-DT,a4)
	move.l	#$FFFFFFF,(a1)
	move.b	#0,(B30176-DT,a4)
	cmp.b	#"O",d0		;'O' optimize
	beq.w	C2AD4
	cmp.b	#"C",d0		;'C' assemble check
	beq.b	C2B8E
	cmp.b	#"D",d0		;'D' debug
	bne.b	ReAssemble
	jmp	(Enter_debugger).l	;go debugging

C2B8E:
	move.b	#1,(B30176-DT,a4)
	bra.b	ReAssemble

SetActiveSourcebuf:
	move.b	(a6)+,d0
	cmp.b	#"0",d0
	blt.b	C2BDA
	cmp.b	#"9",d0
	bgt.b	C2BDA
	tst.l	(L2FCBA-DT,a4)
	beq.b	C2BD8
	sub.b	#"0",d0
C2BAE:
	move.b	#1,(FromCmdLine-DT,a4)
	move.b	d0,(Change2Source-DT,a4)
	movem.l	d0-d7/a0-a6,-(sp)
	movem.l	(EditorRegs-DT,a4),d0-d7/a0-a6
	jsr	(Go2Sourcenow).l
	movem.l	(sp)+,d0-d7/a0-a6
	move.b	#0,(FromCmdLine-DT,a4)
	jmp	(RESETMENUTEXT2).l

C2BD8:
	rts

C2BDA:
	bra.w	_ERROR_Illegalsource

ReAssemble:
	moveq	#0,d7
Asmbl_Optimize:
	bsr.w	ASSEM_SET_PREFS
	move.l	#eop_irq_routine,(pcounter_base-DT,a4)
	bclr	#SB2_INDEBUGMODE,(SomeBits2-DT,a4)
	bclr	#SB2_MATH_XN_OK,(SomeBits2-DT,a4)
	jsr	(DEBUG_CLEAR_BP_BUFFER).l

	move.b	#0,(MMUAsmBits-DT,a4)
	clr.l	(L2F118-DT,a4)

	clr.l	(JUMPPTR-DT,a4)
	clr.l	(RESCPTR-DT,a4)
	clr	(NrOfErrors-DT,a4)
	clr.l	(Asm_LastErrorPos-DT,a4)
	move	#100,(ProgressSpeed-DT,a4)
	move	#100,(ProgressCntr-DT,a4)
	lea	(ProgramName).l,a0
	move.l	($0106,a0),(a0)		;default prog name
	move	($010A,a0),(4,a0)	; ''
	lea	(HPass1.MSG).l,a0
	jsr	(beeldtextaf).l
	bsr.w	InitLabelArea
	bset	#AF_PASSONE,d7
	bsr.w	ASSEM_RESET_SECTIONS
	bsr.w	ASSEMBLERAWFILE
	btst	#AF_BRATOLONG,d7
	beq.b	C2C5C
	jmp	(C11CF8).l

C2C5C:
	tst	(NrOfErrors-DT,a4)
	bne.b	C2CAE
	cmp.b	#1,(B30176-DT,a4)
	beq.b	C2CC6
	bsr.w	ASSEM_RESTORE_OLD_SECTION
	move.l	(LabelEnd-DT,a4),(DEBUG_END-DT,a4)
	btst	#AF_DEBUG1,d7
	beq.b	.NoDebug
;	moveq	#0,d0
	move.l	(DATA_CURRENTLINE-DT,a4),d0
	lsl.l	#2,d0
	add.l	d0,(DEBUG_END-DT,a4)
.NoDebug:
	and.l	#$40000000,d7	;AF_DEBUG1
	bsr.w	ASSEM_SET_PREFS
	bsr.w	ASSEM_INIT_SECTION_AREAS
	clr.l	(CurrentLocalPtr-DT,a4)

	movem.l	d0/a0,-(sp)
	lea	(ERROR_AddressRegByte).l,a0
	move.l	#shit_deel-ERROR_AddressRegByte,d0
	lea	(a0,d0.l),a0
	jmp	(a0)

;	jmp	shit_deel

C2CAE:
	moveq	#0,d7
	move	(NrOfErrors-DT,a4),d0
	jsr	(DrukAf_LineNrPrint).l
	jsr	Druk_Clearbuffer
	lea	(HErrorsOccure.MSG).l,a0
	jmp	(printthetext).l

C2CC6:
	moveq	#0,d7
	move	(NrOfErrors-DT,a4),d0
	jsr	(DrukAf_LineNrPrint).l
	jsr	Druk_Clearbuffer
	lea	(HSourcechecke.MSG).l,a0
	jmp	(printthetext).l

shit_deel:
	movem.l	(sp)+,d0/a0
	lea	(HPass2.MSG).l,a0
	jsr	(beeldtextaf).l
	bsr.w	ASSEMBLERAWFILE
	btst	#AF_BRATOLONG,d7
	beq.b	C2CFE
	jmp	(C11CF8).l

C2CFE:
	tst	(NrOfErrors-DT,a4)
	bne.b	C2CAE
	moveq.l	#0,d3
	bsr.w	ASSEM_RESTORE_OLD_SECTION
	bsr.b	.SetCodeStart
	move.l	(RelocStart-DT,a4),a0
	move.l	#$12345678,-(a0)
	lea	(HNoErrors.MSG).l,a0
	jsr	(printthetext).l
	jsr	(PRINT_SYMBOLTABELMAYBE).l
	move	#2,(AssmblrStatus).l
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
	tst.l	(a1)+
	beq.b	.NoCode
	moveq	#"<",d2
	and.b	(a2),d2
	beq.b	.SetPtr
.NoCode:
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

ASSEMBLERAWFILE:
	moveq	#0,d0
	move.b	d0,(BASEREG_BYTE-DT,a4)
	move.l	d0,(DATA_CURRENTLINE-DT,a4)
	move.l	(sourcestart-DT,a4),a6
	move.l	sp,(TEMP_STACKPTR-DT,a4)
	lea	(.loopje,pc),a0
	move.l	a0,(TEMP_CONT_PTR-DT,a4)
	move	d0,(INCLUDE_LEVEL-DT,a4)
	move	d0,(MACRO_LEVEL-DT,a4)
	move	d0,(REPT_LEVEL-DT,a4)
	move	d0,(MACRO_LOCALNR-DT,a4)
	lea	(ParameterBlok-DT,a4),a0
	move.l	a0,(CURRENT_MACRO_ARG_PTR-DT,a4)
	move	d0,(ConditionLevel-DT,a4)
	move	d0,(PageLinesLeft-DT,a4)
	move	d0,(PageNumber-DT,a4)
	move.l	d0,(RS_BASE_OFFSET-DT,a4)
.loopje:
	addq.l	#1,(DATA_CURRENTLINE-DT,a4)
	tst.b	(DATA_CURRENTLINE+3-DT,a4)	;was +1
	bne.b	.DONTPRINT
	jsr	(messages_get).l
.DONTPRINT:
	move.l	a6,(DATA_LINE_START_PTR-DT,a4)
	cmp.b	#$1A,(a6)	;EOF
	beq.b	.ENDOFPASS
	btst	#AF_DEBUG1,d7
	beq.b	.C2DFA
	tst	d7		;AF_PASSONE
	bmi.b	.C2DFA
;	moveq	#0,d0
	move.l	(DATA_CURRENTLINE-DT,a4),d0
	subq.l	#1,d0
	lsl.l	#2,d0
	move.l	(LabelEnd-DT,a4),a0
	add.l	d0,a0
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),d0
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),d0
	move.l	d0,(a0)
.C2DFA:
	bsr.w	FAST_TRANSLATE_LINE
	btst	#AF_LISTFILE,d7
	beq.b	.C2E0E
	tst	d7		;AF_DEBUG1
	bmi.b	.C2E0E
	jsr	(PRINT_ASSEMBLING).l
.C2E0E:
	tst.b	d7		;AF_FINISHED
	bpl.b	.loopje
.ENDOFPASS:
	tst	(REPT_LEVEL-DT,a4)
	bne.w	_ERROR_UnexpectedEOF
	rts


;*   Macro found   *
; D6 = LEVEL

ASSEM_MACROFOUND:
	addq.w	#1,(MACRO_LEVEL-DT,a4)
	cmp	#MAX_MACRO_LEVEL,(MACRO_LEVEL-DT,a4)
	bhi.w	_ERROR_Macrooverflow
	move	(MACRO_ARGUMENTS-DT,a4),-(sp)
	bsr.w	FilterText
	move.l	a6,-(sp)
	move.l	d3,a5
	moveq	#0,d5
	move	(MACRO_LOCALNR-DT,a4),d5
	addq.w	#1,d5
	move	d5,(MACRO_LOCALNR-DT,a4)
.Loopje:
	bsr.w	C366E
	movem.l	d5/a2/a5,-(sp)
	bsr.w	FAST_TRANSLATE_LINE
	movem.l	(sp)+,d5/a2/a5
	btst	#AF_MACRO_END,d7
	beq.b	.Loopje
	bclr	#AF_MACRO_END,d7
	move.l	(sp)+,a6
	clr.b	(a6)
	move	(sp)+,(MACRO_ARGUMENTS-DT,a4)
	move.l	a2,(CURRENT_MACRO_ARG_PTR-DT,a4)
	subq.w	#1,(MACRO_LEVEL-DT,a4)
	cmp	(MACRO_LOCALNR-DT,a4),d5
	bne.b	.End
	tst.l	d5
	bmi.b	.End
	subq.w	#1,d5
	move	d5,(MACRO_LOCALNR-DT,a4)
.End:
	rts

ascii.MSG84:
	dc.b	' 000'
Complete.MSG:
	dc.b	'% Complete',$D,0
Line.MSG:
	dc.b	'Line       ',13,0
	even

ShowAsmProgress:
	btst	#0,(PR_Progress).l
	beq.w	No_Processindicator
	btst	#0,(PR_ProgressLine).l
	beq.b	Process_indicatorByPerc

	movem.l	d0-d7/a0-a6,-(sp)
;	moveq	#0,d0
	move.l	(DATA_CURRENTLINE-DT,a4),d0
	tst.b	d0
	bne.b	C2ED0

	lea	(Line.MSG,pc),a0
	jsr	(beeldtextaf).l

	lea	Line.MSG+10,a0
	moveq.l	#5-1,d7
.lopje:
	divu.w	#10,d0
	swap	d0
	tst.l	d0
	bne.s	.nomask
	moveq.l	#' '-'0',d0
.nomask:
	add.b	#'0',d0
	move.b	d0,-(a0)
	clr.w	d0
	swap	d0
	dbf	d7,.lopje

C2ED0:
	movem.l	(sp)+,d0-d7/a0-a6
	rts

Process_indicatorByPerc:
	subq.w	#1,(ProgressCntr-DT,a4)
	bne.w	No_Processindicator
	move	(ProgressSpeed-DT,a4),(ProgressCntr-DT,a4)

	movem.l	d0/d1/d2/a0,-(sp)
	move.l	a6,d0
	cmp.l	(sourceend-DT,a4),d0
	bhi.w	C2F6E
	cmp.l	(sourcestart-DT,a4),d0
	bcs.w	C2F6E
	sub.l	(sourcestart-DT,a4),d0
	move.l	(sourceend-DT,a4),d1
	sub.l	(sourcestart-DT,a4),d1
C2F02:
	swap	d1
	tst	d1
	beq.b	C2F10
	swap	d1
	lsr.l	#4,d0
	lsr.l	#4,d1
	bra.b	C2F02

C2F10:
	swap	d1
	addq.w	#1,d1

	lsl.l	#2,d0
	move.l	d0,d2
	lsl.l	#3,d2
	add.l	d0,d2
	lsl.l	#4,d0
	add.l	d2,d0
;	mulu	#100,d0

	tst	d1
	bne.b	C2F1E
	addq.w	#1,d1
C2F1E:
	divu	d1,d0
	and.l	#$0000007F,d0
	cmp	(W2E4CC-DT,a4),d0
	beq.b	C2F6E
	lea	(Complete.MSG,pc),a0
	move	d0,(W2E4CC-DT,a4)
	divu	#10,d0
	swap	d0
	add.b	#'0',d0
	move.b	d0,-(a0)
	clr	d0
	swap	d0
	divu	#10,d0
	swap	d0
	add.b	#'0',d0
	move.b	d0,-(a0)
	clr	d0
	swap	d0
	divu	#10,d0
	swap	d0
	add.b	#'0',d0
	move.b	d0,-(a0)
	moveq	#0,d0
	lea	(ascii.MSG84).l,a0
	jsr	(beeldtextaf).l
C2F6E:
	movem.l	(sp)+,d0/d1/d2/a0
No_Processindicator:
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
	add	(W02F98,pc,d1.w),d1
	jmp	(W02F98,pc,d1.w)

W02F98:
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
	bclr	#AF_LOCALFOUND,d7
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
	br.w	FindEndOfLine

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
	br.w	_ERROR_IllegalOperatorInBSS

.TR_Global2:
	bclr	#AF_LOCALFOUND,d7
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

;	move.l	(a3),d0
;	jsr	test_debug
;	jsr	test1

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
;		jsr	test_debug

	jmp	(ERROR_IllegalOperand).l

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
	br.w	_ERROR_NOoperandspac

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
	bne.w	_ERROR_Codemovedduring
	move	-(a1),d0
	bclr	#14,d0
	cmp	(ResponseType-DT,a4),d0
	beq.b	.pass1
	br.w	_ERROR_Codemovedduring

.pass1:
	rts

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
	
	moveq.l	#0,d1
	btst	#15,d0
	bne.s	.maarvierchars
	move.l	(a3)+,d1	;laatste 4 letters ppc instructie
	and.l	d4,d1
	btst	#31,d1
	beq.s	.achtchars
	clr.w	d1
	lea	-2(a3),a3	;dus 2 bytes terug
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
	moveq.l	#0,d0
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
	moveq.l	#0,d0
	bsr	PPC_resolveDReg
	bsr	PPC_resolveAReg
;	bsr	PPC_resolveBReg
	bsr	PPC_resolveSIMM
	rts

PPC_getregnr:
	moveq.l	#0,d1
	move.b	(a6)+,d1
	and.b	#$5F,d1
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
	moveq.l	#0,d2
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
	ENDIF


m68_ChangeCpuType:
	moveq.l	#0,d1
	move.w	(a6)+,d1
	swap	d1
	move.b	(a6)+,d1
	lsl.w	#8,d1
	and.l	#$dfdfdf00,d1

PPC_ChangeCpuType:
	move.b	#0,d1

	lea	.cpus(pc),a0

	move.l	d7,-(sp)
	moveq	#10-1,d7
.lopje:
	cmp.l	(a0)+,d1
	beq.s	.gevonden
	dbf	d7,.lopje

	move.l	(sp)+,d7
	br.w	_ERROR_IllegalOperatorInBSS
;	br	_ERROR_UnknowCPU

.gevonden:
;	jsr	test_debug

	cmp.w	#3,d7
	blo.s	.ppc
	sub.w	#3,d7

	bclr	#MB1_PPC_ASM,(MyBits-DT,a4)

	bra.w	.klaar
.ppc:
;	bset	#MB1_PPC_ASM,(MyBits-DT,a4)
.klaar:
	move.l	(sp)+,d7
	rts

.cpus:
	dc.l	('M68'&$dfdfdf)<<8	;9
	dc.l	('000'&$dfdfdf)<<8	;8
	dc.l	('010'&$dfdfdf)<<8	;7
	dc.l	('020'&$dfdfdf)<<8	;6
	dc.l	('030'&$dfdfdf)<<8	;5
	dc.l	('040'&$dfdfdf)<<8	;4
	dc.l	('060'&$dfdfdf)<<8	;3

	dc.l	('PPC'&$dfdfdf)<<8	;2
	dc.l	('603'&$dfdfdf)<<8	;1
	dc.l	('604'&$dfdfdf)<<8	;0


;************** END PPC TEST STUFF ***********

HandleMacroos:
	IFNE	useplugins
	jmp	PlugIns
HandleMacroos2:
	ENDC
	
	addq.l	#4,sp
	btst	#AF_MACROS_OFF,d7
	bne.w	_ERROR_IllegalOperatorInBSS
	tst.l	d7		;AF_IF_FALSE
	bmi.w	TR_2EOL
	bsr.w	Zoek_uit_extentie
	beq.b	C334E
	tst	d2
	bmi.b	C335A
C334E:
	btst	#AF_BSS_AREA,d7
	bne.w	_ERROR_IllegalOperator
	br.w	_ERROR_IllegalOperatorInBSS

C335A:
	swap	d2
	and.b	#"?",d2
	bne.b	C334E
	bsr.w	ASSEM_MACROFOUND
	bra.w	TR_2EOL

TR_WS:
	move.b	(a6)+,d0
	move	d0,d1
	add.b	d1,d1
	add	(W3376,pc,d1.w),d1
	jmp	(W3376,pc,d1.w)

W3376:
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
	br.w	_ERROR_IllegalOperatorInBSS

.TR_Global:
	bclr	#AF_LOCALFOUND,d7
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
	br.w	C3138

TR_EmptyChar:
	br.w	_ERROR_IllegalOperatorInBSS

FilterText:
	move.l	(CURRENT_MACRO_ARG_PTR-DT,a4),a0
	move.l	a0,a2
	lea	(FilterTable,pc),a1
	moveq	#$13,d1
	moveq	#0,d0
C34DE:
	subq.w	#1,d1
	bmi.b	C354C
C34E2:
	move.b	(a6)+,d0
	tst.b	(Variable_base-DT,a4,d0.w)
	bmi.b	C34E2
	move.b	(a1,d0.w),(a0)+
	bne.b	C3510
	cmp.b	#",",d0
	beq.b	C34DE
	tst.b	d0
	beq.b	C354A
	cmp.b	#"'",d0
	beq.b	C3536
	cmp.b	#'"',d0
	beq.b	C3536
	cmp.b	#"`",d0
	beq.b	C3536
	bra.b	C354A

C3510:
	move.b	(a6)+,d0
	move.b	(a1,d0.w),(a0)+
	bne.b	C3510
	cmp.b	#",",d0
	beq.b	C34DE
	tst.b	d0
	beq.b	C354E
	cmp.b	#"'",d0
	beq.b	C3536
	cmp.b	#'"',d0
	beq.b	C3536
	cmp.b	#"`",d0
	bne.b	C354E
C3536:
	move.b	d0,d2
	subq.w	#1,a0
C353A:
	move.b	d0,(a0)+
	move.b	(a6)+,d0
	beq.w	_ERROR_MissingQuote
	cmp.b	d0,d2
	bne.b	C353A
	move.b	d2,(a0)+
	bra.b	C3510

C354A:
	subq.w	#1,a0
C354C:
	addq.w	#1,d1
C354E:
	move	d1,d0
	bra.b	C3554

C3552:
	clr.b	(a0)+
C3554:
	dbra	d0,C3552
	moveq	#$13,d0
	sub	d1,d0
	move	d0,(MACRO_ARGUMENTS-DT,a4)
	subq.w	#1,a6
C3562:
	tst.b	(a6)+
	bne.b	C3562
	subq.w	#1,a6
	move.l	a0,(CURRENT_MACRO_ARG_PTR-DT,a4)
	rts

FilterTable:
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00210023
	dc.l	$24252600
	dc.l	$28292A2B
	dc.l	$002D2E2F
	dc.l	$30313233
	dc.l	$34353637
	dc.l	$38393A00
	dc.l	$3C3D3E3F
	dc.l	$40414243
	dc.l	$44454647
	dc.l	$48494A4B
	dc.l	$4C4D4E4F
	dc.l	$50515253
	dc.l	$54555657
	dc.l	$58595A5B
	dc.l	$5C5D5E5F
	dc.l	$00616263
	dc.l	$64656667
	dc.l	$68696A6B
	dc.l	$6C6D6E6F
	dc.l	$70717273
	dc.l	$74757677
	dc.l	$78797A7B
	dc.l	$7C7D7E7F
	dc.l	$80818283
	dc.l	$84858687
	dc.l	$88898A8B
	dc.l	$8C8D8E8F
	dc.l	$90919293
	dc.l	$94959697
	dc.l	$98999A9B
	dc.l	$9C9D9E9F
	dc.l	$A0A1A2A3
	dc.l	$A4A5A6A7
	dc.l	$A8A9AAAB
	dc.l	$ACADAEAF
	dc.l	$B0B1B2B3
	dc.l	$B4B5B6B7
	dc.l	$B8B9BABB
	dc.l	$BCBDBEBF
	dc.l	$C0C1C2C3
	dc.l	$C4C5C6C7
	dc.l	$C8C9CACB
	dc.l	$CCCDCECF
	dc.l	$D0D1D2D3
	dc.l	$D4D5D6D7
	dc.l	$D8D9DADB
	dc.l	$DCDDDEDF
	dc.l	$E0E1E2E3
	dc.l	$E4E5E6E7
	dc.l	$E8E9EAEB
	dc.l	$ECEDEEEF
	dc.l	$F0F1F2F3
	dc.l	$F4F5F6F7
	dc.l	$F8F9FAFB
	dc.l	$FCFDFEFF

C366E:
	lea	(MACRO_LINEBUFFER-DT,a4),a3
	move.l	a3,a6
	moveq	#$5C,d1
C3676:
	move.b	(a5)+,d0
	beq.b	C3676
	cmp.b	#"*",d0
	beq.w	C374C
	cmp.b	#$1A,d0
	beq.w	_ERROR_UnexpectedEOF
	cmp.b	d1,d0
	beq.b	C369A
C368E:
	move.b	d0,(a3)+
C3690:
	move.b	(a5)+,d0
	beq.w	C3750
	cmp.b	d1,d0
	bne.b	C368E
C369A:
	moveq	#0,d0
	move.b	(a5)+,d0
	cmp.b	#"0",d0
	beq.b	C36F8
	cmp.b	#"@",d0
	beq.b	C3714
	cmp.b	#".",d0
	beq.b	C36EE
	cmp.b	d1,d0
	beq.b	C368E
	sub.b	#"1",d0
	cmp.b	#9,d0
	bcc.w	_ERROR_IllegalOperand
	tst.b	d0
	bne.b	C36D8
	move.b	(a5),d3
	sub.b	#"0",d3
	cmp.b	#9,d3
	bhi.b	C36D8
	moveq	#9,d0
	add.b	d3,d0
	addq.w	#1,a5
C36D8:
	move.l	a2,a0
	subq.b	#1,d0
	bmi.b	C36E6
C36DE:
	tst.b	(a0)+
	bne.b	C36DE
	dbra	d0,C36DE
C36E6:
	move.b	(a0)+,(a3)+
	bne.b	C36E6
	subq.w	#1,a3
	bra.b	C3690

C36EE:
	move.b	#"\",(a3)+
	move.b	#".",(a3)+
	bra.b	C3690

C36F8:
	moveq	#0,d0
	move.b	(B30177-DT,a4),d0
	bpl.b	C3704
	clr.b	-(a3)
	bra.b	C3690

C3704:
	move.b	(B0370C,pc,d0.w),(a3)+
	br.b	C3690

B0370C:
	dc.b	"SBWLDXP",0

C3714:
	bset	#$1F,d5
	move.b	#$5F,(a3)+
	move	d5,d0
	lea	(ABCDEF.MSG,pc),a0
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
	moveq	#15,d2
	and.b	d0,d2
	move.b	(a0,d2.w),(a3)+
	br.w	C3690

C374C:
	move.b	(a5)+,d0
	bne.b	C374C
C3750:
	move.b	d0,(a3)+
	rts

ABCDEF.MSG:
	dc.b	'0123456789ABCDEF'

RemoveWS:
	move.b	(a6)+,d0
	cmp.b	#" ",d0
	beq.b	RemoveWS
	cmp.b	#9,d0
	beq.b	RemoveWS
	tst.b	d0
	rts

C3778:
	jsr	(Parse_GetExprValueInD3Voor).l
	btst	#AF_UNDEFVALUE,d7
	bne.b	C3798
	cmp	(CurrentSection-DT,a4),d2
	beq.b	C3792
	tst	d2
	bmi.b	C3798
	br.w	_ERROR_RelativeModeEr

C3792:
	moveq	#0,d2
	sub.l	(Binary_Offset-DT,a4),d3
C3798:
	rts

C379A:
	jsr	(Parse_GetExprValueInD3Voor).l
	btst	#AF_UNDEFVALUE,d7
	beq.b	C37AC
	jmp	(C755A).l

C37AC:
	moveq	#0,d2
	sub.l	(Binary_Offset-DT,a4),d3
	jmp	(Store_DataLongReloc).l

C37D8:
	tst	d3
	bne.b	C37E2
	jmp	(C106EC).l

C37E2:
	sub.l	(Binary_Offset-DT,a4),d3
	jmp	(Store_DataLongReloc).l

C37EC:
	rts

C37EE:
	jsr	(Parse_GetExprValueInD3Voor).l
	btst	#AF_UNDEFVALUE,d7
	bne.b	C380E
	cmp	(CurrentSection-DT,a4),d2
	beq.b	C3808
	tst	d2
	bmi.b	C380E
	br.w	_ERROR_RelativeModeEr

C3808:
	moveq	#0,d2
	sub.l	(Binary_Offset-DT,a4),d3
C380E:
	jmp	(C755A).l

C3814:
	jsr	(Parse_GetExprValueInD3Voor).l
	btst	#AF_UNDEFVALUE,d7
	bne.b	C3850
	cmp	(CurrentSection-DT,a4),d2
	beq.b	C382E
	tst	d2
	bmi.b	C3852
	br.w	_ERROR_RelativeModeEr

C382E:
	moveq	#0,d2
	sub.l	(Binary_Offset-DT,a4),d3
	move.b	d3,d0
	ext.w	d0
	ext.l	d0
	cmp.l	d0,d3
	beq.b	C3844
	jmp	(FORCE_BRAW).l

C3844:
	tst.b	d3
	bne.b	C384E
	jmp	(FORCE_BRAW).l

C384E:
	or.b	d3,d6
C3850:
	rts

C3852:
	jmp	(FORCE_BRAW).l

Parse_GetDefinedValue:
	jsr	(Parse_GetExprValueInD3Voor).l
	btst	#AF_UNDEFVALUE,d7
	bne.w	_ERROR_UndefSymbol	;error
	tst	d2
	bne.w	_ERROR_RelativeModeEr	;error
	clr	(Asm_OffsetCheck).l
	rts

Asm_OffsetCheck:
	dc.w	0

Parse_ImmediateValue:
	cmp.b	#'#',(a6)+
	bne.w	_ERROR_Immediateoper
	jsr	Parse_GetExprValueInD3Voor
	btst	#AF_UNDEFVALUE,d7
	bne.b	.eind
	tst	d2
;	beq.b	.eind
	bne.w	_ERROR_RelativeModeEr
.eind:
	rts

Parse_GetEASpecial:
	bsr.w	Get_NextChar
	cmp.b	#'#',d1
	bne.w	Get_OtherEA
	jsr	Parse_GetExprValueInD3Voor
	move	#MODE_9,d5
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

.eind:
	moveq	#0,d1
	rts

S_Value:
	jsr	(Parse_rekenen2).l
Parse_ItsAValue:
	move.b	(a6)+,d0
	cmp.b	#'(',d0
	beq.w	C39AA
	cmp.b	#'.',d0
	beq.w	Parse_SizeDetected
	subq.w	#1,a6
	br.w	C398E

Parse_OneRegFound:
	rts

C38EE:
	bsr.w	Get_NextChar
	cmp.b	#'#',d1
	beq.w	_ERROR_InvalidAddress
	cmp.b	#'(',d1
	beq.w	Parse_HaakjeOpenVoor
	cmp.b	#'-',d1
	beq.b	Parse_MinVoor
	cmp.b	#"b",d1
	bne.b	C391C
	bsr.w	Parse_CheckIfReservedWord
	bne.b	PARSE_MOVEM_REGISTERS
	jsr	(C10BBA).l
	bra.b	Parse_ItsAValue

C391C:
	jsr	(Parse_rekenen2).l
	bra.b	Parse_ItsAValue

PARSE_MOVEM_REGISTERS:
	moveq	#0,d2
C3926:
	move	d1,d3
	bset	d1,d2
	not.w	d1
	bset	d1,d2
	move.b	(a6)+,d0
	cmp.b	#"-",d0
	beq.b	C3942
	cmp.b	#"/",d0
	bne.b	C395C
	bsr.w	AdresOfDataReg
	bra.b	C3926

C3942:
	bsr.w	AdresOfDataReg
	cmp	d3,d1
	bls.w	_ERROR_IllegalOrder
C394C:
	addq.w	#1,d3
	bset	d3,d2
	not.w	d3
	bset	d3,d2
	not.w	d3
	cmp	d1,d3
	bcs.b	C394C
	bra.b	C3926

C395C:
	subq.w	#1,a6
	move.l	d2,d1
	move	#$4000,d5
	rts

Parse_MinVoor:
	cmp.b	#'(',(a6)+
	beq.w	C3A98
	subq.w	#2,a6
	jsr	(Parse_GetExprValueInD3Voor).l
	br.w	Parse_ItsAValue

Parse_SizeDetected:
	move.b	(a6)+,d0
	bclr	#5,d0
	cmp.b	#'W',d0
	beq.b	C399C
	cmp.b	#'L',d0
	bne.w	_ERROR_IllegalAddres
C398E:
	move	#$0039,d1
	move	#MODE_8,d5
	jmp	(Store_DataLongReloc).l

C399C:
	move	#$0038,d1
	move	#MODE_7,d5
	jmp	(Store_DataWordUnsigned).l

C39AA:
	clr.b	(S_MemIndActEnc-DT,a4)
	bsr.w	Parse_GetDofAReg
	beq.w	_ERROR_InvalidAddress
	bmi.b	C3A3A
	cmp	#$003A,d1
	bne.b	C39C8
	sub.l	#2,d3
	bra.b	C39D0

C39C8:
	btst	#3,d1
	bne.w	_ERROR_AddressRegExp
C39D0:
	btst	#AF_OFFSET_A4,d7
	beq.b	C3A0A
	btst	d1,(BASEREG_BYTE-DT,a4)
	beq.b	C3A0A
	tst	d7	;passone
	bpl.b	C39E4
	moveq	#0,d3
	bra.b	C3A08

C39E4:
	move	d1,d0
	add	d0,d0
	add	d0,d0
	add	d1,d0
	add	d1,d0
	lea	(BASEREG_BASE-DT,a4),a0
	add	d0,a0
	tst	d2
	bpl.b	C3A00
	addq.w	#2,a0
	moveq	#0,d3
	sub.l	(a0)+,d3
	bra.b	C3A0A

C3A00:
	cmp	(a0)+,d2
	bne.w	_ERROR_RelativeModeEr
	sub.l	(a0)+,d3
C3A08:
	moveq	#0,d2
C3A0A:
	move.w	#0,(Parse_AdrValueSize-DT,a4)
	move.l	#0,(Parse_AdrValue-DT,a4)
	move.b	(a6)+,d0
	cmp.b	#')',d0
	beq.b	C3A2E
	cmp.b	#',',d0
	beq.w	C3DC8
	br.w	_ERROR_RightParentesExpected

C3A2E:
	or.w	#$0028,d1
	moveq	#$10,d5
	jmp	(C755A).l

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
	move	#$003A,d1
	move	#$0400,d5
	jmp	(C755A).l

C3A7C:
	move.w	#0,(Parse_AdrValueSize-DT,a4)
	move.l	#0,(Parse_AdrValue-DT,a4)
	move	#$003B,d1
	move	#$0800,d5
	br.w	C3DE0

C3A98:
	bsr.w	Parse_GetDofAReg
	beq.b	C3AAE
	cmp.b	#')',(a6)+
	bne.w	_ERROR_RightParentesExpected
	or.w	#$0020,d1
	moveq	#8,d5
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
	clr.b	(S_MemIndActEnc-DT,a4)
	addq.w	#1,a6
	br.w	C39AA

Asm_ImmediateOpp:
;	cmp.b	#$80,(OpperantSize-DT,a4)
;	beq.b	.size_BWL

	cmp.b	#$44,(OpperantSize-DT,a4)
	beq.b	.size_BWL
	cmp.b	#$10,(OpperantSize-DT,a4)
	ble.b	.size_BWL
	move	d6,d0
	rol.w	#4,d0
	and	#15,d0
	cmp.b	#15,d0
	beq.b	.floatingpoint
	cmp.b	#$70,(OpperantSize-DT,a4)
	blt.b	.size_BWL
.floatingpoint:
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	Parse_GetExprValueInD3Voor	;Check for constants.
	btst	#AF_UNDEFVALUE,d7
	bne.b	.parse
	cmp.b	#'.',(a6)
	beq.b	.parse
	fmove.l	d3,fp0
	add.l	#15*4,sp

	bra.b	.label
.parse
	movem.l	(sp)+,d0-d7/a0-a6
	jsr	Asm_ImmediateOppFloat
.label
	move	#MODE_9,d5
	move	#$003C,d1
	move.b	(OpperantSize-DT,a4),d0
	and.b	#7,d0
	subq.b	#1,d0
	beq.w	Asm_FloatsizeS
	subq.b	#1,d0
	beq.w	Asm_FloatsizeX
	subq.b	#1,d0
	beq.w	Asm_FloatsizeP
	br.w	Asm_FloatsizeD

;#xxxxx

.size_BWL:
	jsr	Parse_GetExprValueInD3Voor
	move	#MODE_9,d5
	move	#$003C,d1
	tst.b	(OpperantSize-DT,a4)
	bmi.w	Store_DataLongReloc
	bne.w	Store_DataWordUnsigned
	br.w	Store_Data2BytesUnsigned

; (ax)Asm_FloatsizeX:
; (ax)+
; (ax,rx[.w|.l])
; (sp)			; is (a7)

Parse_HaakjeVoor:
	moveq	#PB_020,d0
	jsr	Processor_warning


;	btst	#SB_INDIRECT,NewSyntaxbits
;	bne	_ERROR_AdrOrPCExpected

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
	move	(Parse_AdrValueSize-DT,a4),d0
	lsr.b	#2,d0
	lsl.b	#4,d0
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
	bmi.b	C3C00
	move.l	(Binary_Offset-DT,a4),a0
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
	move	d3,(2,a0)
C3C00:
	move	#2,(Parse_AdrValueSize-DT,a4)
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
	add.l	#2,(Binary_Offset-DT,a4)
	moveq	#0,d0
	move	(Parse_AdrValueSize-DT,a4),d0
	add.l	d0,(Binary_Offset-DT,a4)
	moveq	#$30,d1
	moveq	#$20,d5
	rts

C3C5C:
	add.l	#2,(Binary_Offset-DT,a4)
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
	moveq	#$20,d5
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
	add.l	#2,(Binary_Offset-DT,a4)
	moveq	#$30,d1
	moveq	#2,d5
	rts

Parse_Indexing020:
	movem.l	d0/d3,-(sp)
	moveq	#PB_020,d0
	jsr	(Processor_warning).l
.lopje:
	move.b	(a6)+,d0
	cmp.b	#'$',d0
	beq	.lopje
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

Parse_NewAdrvalue:	dc.l	0
huidigesectie:		dc.w	0
NewSyntaxbits:		dc.w	0
ISEncoding:		dc.w	0


	cnop	0,4
	
Parse_HaakjeOpenVoor:
	move.w	#0,(ISEncoding)
	move.w	#0,(Parse_CPUType-DT,a4)
	move.w	#0,(huidigesectie)
	move.w	#0,(NewSyntaxbits)
	move.w	#0,(Parse_AdrValueSize-DT,a4)
	move.l	#0,(Parse_AdrValue-DT,a4)
	move.l	#0,(Parse_NewAdrvalue)
	move.b	#1,(S_MemIndActEnc-DT,a4)
	cmp.b	#'[',(a6)
	bne.w	Parse_OldSyntax

	bset	#SB_INDIRECT,NewSyntaxbits

	addq.w	#1,a6
	moveq	#PB_020,d0
	jsr	Processor_warning
	jsr	Parse_GetDofAReg	;was wat anders
;	beq	C3AC6
;	bmi.w	_ERROR_RelativeModeEr

	tst.w	d0
	beq.s	.noReg

;	btst	#3,d1
;	bne	_ERROR_AddressRegExp

	bset	#SB_AREGFIRST,NewSyntaxbits
	moveq.l	#0,d3

	move.w	d2,huidigesectie
	move.l	#$0,(Parse_AdrValue-DT,a4)
	move	#0,(Parse_AdrValueSize-DT,a4)
	move.b	#1,(S_MemIndActEnc-DT,a4)	;indirect pre/post-indexed

	bra.b	Parse_OldSyntax\.geenOffset

.noReg:
	move.b	#1,(S_MemIndActEnc-DT,a4)	;indirect pre/post-indexed

	move.l	d3,(Parse_AdrValue-DT,a4)

	bsr	Parse_GetTheSize
	move	d1,(Parse_AdrValueSize-DT,a4)

	move.w	d2,huidigesectie

	tst.w	d7
	bmi	.pass1


	TST.W	D2
	BEQ.S	.END
	LEA	(SECTION_ABS_LOCATION-DT,A4),A0
	ADD.W	D2,D2
	ADD.W	D2,D2
	BEQ.W	.pass1
	add.l	(A0,D2.W),D3
;	bra.b	.skip
.END:
;	add.l	(Parse_AdrValue-DT,a4),d3
;.skip
	move.l	d3,(Parse_NewAdrvalue)
.pass1:
	moveq.l	#0,d3
	moveq.l	#0,d1

	cmp.b	#']',(a6)		; ([xxx]
	bne.b	.verder

;		jsr	test_debug
;	clr.w	(Parse_AdrValueSize-DT,a4)

	move	#$00f0,d3		;wierd stuff!!
	br	noDxDirect

.verder:
	cmp.b	#',',(a6)+	;([xxx, or ([xxx],
	bne	_ERROR_Commaexpected

Parse_OldSyntax:
	moveq	#0,d3
	bsr	Parse_GetDofAReg
	beq	C3AC6
	bmi.w	_ERROR_RelativeModeEr

.geenOffset:			;	;([xxx,a0 or ([a0

	cmp.b	#$3a,d1			;pc relative?
	beq.w	noDxDirect

	move.l	(Parse_NewAdrvalue),(Parse_AdrValue-DT,a4)

	btst	#3,d1
	bne	Parse_HaakjeVoor	;([xxx,dx of ([dx

noDxDirect:

	move.b	(a6)+,d0
	cmp.b	#']',d0		;([xxx] , ([xxx,a0] ,([xxx,pc] or ([a0]
	bne.b	.geen020

	cmp.b	#$3a,d1		;PC relative?
	bne.s	.verder
	tst.w	d7
	bmi.s	.passone
	move.w	huidigesectie(pc),d2
	cmp.w	(CurrentSection-DT,a4),d2
	bne.w	_ERROR_RelativeModeEr
.passone
	bra.b	.nochange

.verder:
	tst	d2
	beq.w	.nochange
	move.l	(Parse_NewAdrvalue),(Parse_AdrValue-DT,a4)

.nochange:

	move	#PB_020,(Parse_CPUType-DT,a4)
	move.b	(a6)+,d0
.geen020:

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
	bpl.b	.BS_Suppressed

	move.l	(Binary_Offset-DT,a4),d5
	sub.l	d5,(Parse_AdrValue-DT,a4)
	or.w	#1,d1
.BS_Suppressed:
	or.w	#$0030,d1	;020++
	moveq	#$20,d5

C3DE0:
	move	d1,-(sp)
	move.l	d3,-(sp)
	move	d5,-(sp)

;	tst.w	(Parse_CPUType-DT,a4)
	btst	#SB_INDIRECT,NewSyntaxbits
	beq.s	.noExtentionStuff

	moveq.l	#0,d3
	move.l	a6,help
	bsr	Parse_GetDofAReg	;([xxx,a0],d0 or ([xxx,a0],$ffff

	bchg	#3,d1
	tst.w	d0
	bne.w	.huplakee_welIndexReg

		
	moveq.l	#0,d3
	move.l	help(pc),a6
	subq.l	#1,a6		; de komma !! (,)
	bset	#6,2+3(SP)	; SP= d5.w/d3.l/d1.w
	bra.b	.oepsGeenIndexReg

.noExtentionStuff:
	bsr	AdresOfDataReg
	lsl.w	#4,d1
	moveq.l	#0,d3
	or.b	d1,d3
;	tst.w	(Parse_AdrValueSize-DT,a4)
;	beq.s	.noDisplacement
	bra.b	.noDisplacement2
	
.huplakee_welIndexReg:	;([xxx,A6,D1 or ([A1],A3
	lsl.w	#4,d1
	moveq	#0,d3
	or.b	d1,d3

.oepsGeenIndexReg:
.noDisplacement:
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
	move	#1,(Parse_CPUType-DT,a4)
	bra.b	.noDisplacement2

.getSize:
	move.b	(a6)+,d0
	bclr	#5,d0
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
	bne	.oldsynt
	move.b	(a6)+,d0
	move.w	#1,(Parse_CPUType-DT,a4)
.oldsynt:
	cmp.b	#')',d0
	beq	Asm_HaakjeSluiten
	cmp.b	#',',d0
	bne	_ERROR_RightParentesExpected

Parse_NogEenKomma:
;	tst.l	(2,sp)	;d3 = $00/$80 ?!?!
;	bne	_ERROR_IllegalOperand		;no 8bit displacement

	or.b	#1,d3
	movem.l	d0-d7/a0-a5,-(sp)
	move	#PB_020,d0
	jsr	(Processor_warning).l
	jsr	(Parse_GetExprValueInD3Voor).l
	bra.b	Parse_EnterHere\.jumpin

help:	dc.l	0

Parse_EnterHere:
;	bset	#6,d3		;set IS bit
	bset	#6,2+3(SP)		; SP= d5.w/d3.l/d1.w

	move.l	d3,help
	moveq.l	#0,d3
	or.b	#1,d3

	movem.l	d0-d7/a0-a5,-(sp)
	move	#PB_020,d0
	jsr	(Processor_warning).l

	move.l	help(pc),d3
.jumpin:
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
	bpl.b	C3EB6
	tst	(Parse_AdrValueSize-DT,a4)
	bne.b	C3EB6
	sub	#2,d6
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
	add.l	#2,(Binary_Offset-DT,a4)
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
	tst.b	d0
	beq.b	C3F1E
	move.l	(Parse_AdrValue-DT,a4),(1,a0)
	bra.b	C3F30

C3F1E:
	cmp.l	#$0000FFFF,(Parse_AdrValue-DT,a4)
	bgt.w	_ERROR_out_of_range16bit
	move	(Parse_AdrValueSizePlus2-DT,a4),(1,a0)
C3F30:
	lsl.b	#4,d0
	or.b	#2,d0
	bset	#2,d0
	cmp	#1,(Parse_CPUType-DT,a4)
	bne.w	C3EE6
	bclr	#2,d0
	bra.w	C3EE6

C3F48:
	movem.l	(sp)+,d0-d7/a0-a5
	move	(sp)+,d5
	move.l	(sp)+,d3
	move	(sp)+,d1

	add.l	#4,(Binary_Offset-DT,a4)
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
	bpl.b	C3F86

	tst	(Parse_AdrValueSize-DT,a4)
	bne.b	C3F86
	sub.l	#2,d6
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
	add.l	#4,(Binary_Offset-DT,a4)
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
	tst.b	d0
	beq.b	C3FDC
	move.l	(Parse_AdrValue-DT,a4),(1,a0)

	bra.b	C3FEE

C3FDC:
	cmp.l	#$0000FFFF,(Parse_AdrValue-DT,a4)
	bgt.w	_ERROR_out_of_range16bit
	move	(Parse_AdrValueSizePlus2-DT,a4),(1,a0)
C3FEE:
	lsl.b	#4,d0
	or.b	#3,d0
	bset	#2,d0
	cmp	#1,(Parse_CPUType-DT,a4)
	bne.b	C3FA4
	bclr	#2,d0
	bra.b	C3FA4

C4006:
	movem.l	(sp)+,d0-d7/a0-a5
	move	(sp)+,d5
	move.l	(sp)+,d3
	move	(sp)+,d1
	add.l	#6,(Binary_Offset-DT,a4)
	moveq	#0,d0
	move	(Parse_AdrValueSize-DT,a4),d0
	add.l	d0,(Binary_Offset-DT,a4)
	rts

Parse_SyntaxAfronden020:
	movem.l	d0/d1,-(sp)
	move	#PB_020,d0
	jsr	(Processor_warning).l
Parse_SyntaxAfrondenOld:
	move.b	(a6)+,d0
	cmp.b	#'$',d0
	beq	Parse_SyntaxAfrondenOld
	cmp.b	#'@',d0
	beq.b	Parse_SyntaxAfrondenOld
	move.b	#3,d1
.lopje:
	cmp.b	#'0',d0
	bne.s	.verder
	move.b	(a6)+,d0
	bra.b	.lopje
.verder:
	cmp.b	#'8',d0
	beq.b	.validScale
	sub.b	#1,d1
	cmp.b	#'4',d0
	beq.b	.validScale
	sub.b	#1,d1
	cmp.b	#'2',d0
	beq.b	.validScale
	sub.b	#1,d1
	cmp.b	#'1',d0
	bne	_ERROR_Illegalscales
.validScale:
	lsl.b	#1,d1
	or.b	d1,d3
	movem.l	(sp)+,d0/d1
	br	C3DE0\.wordsize

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
;	btst	#SB_INDIRECT,NewSyntaxbits
	beq.s	.noExtentions
	bset	#4,d3	;null base displacement in extention word
	bset	#0,d3	;null outer displacement in extention word
.noExtentions:
	tst.b	(S_MemIndActEnc-DT,a4)
	bpl.w	Parse_IetsMetExtentionWord

.noextention:
	tst.b	d3
	bne	asmbl_send_Byte
	move.b	#$FE,d3
	br	asmbl_send_Byte

.size0andIndirect:
.sizeWL:
	or.b	#1,d3
	move	(Parse_CPUType-DT,a4),d0
	lsr.b	#1,d0
	lsl.b	#2,d0
	or.b	d0,d3
	move	(Parse_AdrValueSize-DT,a4),d0

	tst	d0
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
	move	(Parse_AdrValueSizePlus2-DT,a4),(1,a0)
.pass1:
	bsr	Parse_IetsMetExtentionWord
	add.l	#2,(Binary_Offset-DT,a4)
	rts

C4106:			;long size
	tst	d7	;passone
	bmi.b	.pass1
	move.l	(Parse_AdrValue-DT,a4),(1,a0)
.pass1:
	bsr	Parse_IetsMetExtentionWord
	add.l	#4,(Binary_Offset-DT,a4)
	rts

;Parse_JustExtWord:
;	bclr	#5,d3	;size = 0
;	bsr	Parse_IetsMetExtentionWord
;	rts


Parse_AdrValueLong:
	move.b	(a6),d0
	cmp.b	#'+',d0
	bne.b	.NoParse_PostIncr

	
	tst	(Parse_AdrValueSize-DT,a4)
	bne	_ERROR_InvalidAddress

	tst.b	(S_MemIndActEnc-DT,a4)
	bmi.w	_ERROR_IllegalOperand
	btst	#3,d1
	bne	_ERROR_IllegalOperand
	addq.w	#1,a6
	or.w	#$0018,d1
	moveq	#4,d5
	rts
	
.NoParse_PostIncr:
	tst	(Parse_AdrValueSize-DT,a4)
	bne.b	Parse_DisplacementAdrOrAreg
	btst	#SB_AREGFIRST,NewSyntaxbits
	bne.b	Parse_DisplacementAdrOrAreg

	tst.b	(S_MemIndActEnc-DT,a4)
	bpl.b	C416E
	move.l	a0,-(sp)
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),a0
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
	move	#$FFFE,(2,a0)
	add.l	#2,(Binary_Offset-DT,a4)
	move.l	(sp)+,a0
C416E:
	or.w	#$0010,d1
	moveq	#2,d5
	rts

Parse_DisplacementAdrOrAreg:

	or.w	#$0151,d3	;was $161
	move.l	(Binary_Offset-DT,a4),a0
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a0

	btst	#SB_AREGFIRST,NewSyntaxbits
	bne.s	Parse_StoreExtentionWord

	bclr	#4,d3
	bset	#5,d3
	tst.b	(S_MemIndActEnc-DT,a4)
	bpl.w	.itsPc
	or.w	#1,d1
	move.l	(Binary_Offset-DT,a4),d5
	sub.l	d5,(Parse_AdrValue-DT,a4)
.itsPc:

;	move.l	(Binary_Offset-DT,a4),a0
;	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a0

	cmp	#2,(Parse_AdrValueSize-DT,a4)	word?
	beq.b	Parse_InitExtentionWord
	bset	#4,d3
	add.l	#4,(Binary_Offset-DT,a4)
	tst	d7	;passone
	bmi.b	Parse_StoreExtentionWord


;	btst	#SB_INDIRECT,NewSyntaxbits
;	beq.s	.nochange
;	cmp.b	#$3b,d1		;PC relative?
;	beq.s	.nochange
;	tst	d2
;	beq.w	.nochange

;	tst.b	d3		;([label,Ax]) : ([label]) ?
;	bmi.s	.nochange
;	cmp.w	#$171,d3
;	bne.s	.nochange
;	jsr	test_debug
;	sub.l	#8,(Parse_AdrValue-DT,a4)
;.nochange:

	move.l	(Parse_AdrValue-DT,a4),(2,a0)
	bra.b	Parse_StoreExtentionWord

Parse_InitExtentionWord:
	add.l	#2,(Binary_Offset-DT,a4)
	tst	d7	;passone
	bmi.b	Parse_StoreExtentionWord
	cmp.l	#$0000FFFF,(Parse_AdrValue-DT,a4)
	bgt.w	_ERROR_out_of_range16bit
	move	(Parse_AdrValueSizePlus2-DT,a4),(2,a0)

Parse_StoreExtentionWord:
	tst	d7	;passone
	bmi.b	.pass1
	move	d3,(a0)
.pass1:
	add.l	#2,(Binary_Offset-DT,a4)
	or.w	#$0030,d1
	moveq	#2,d5
	rts

Parse_GetTheSize:
	cmp.b	#'.',(a6)
	bne.b	.defaultSize
	addq.w	#1,a6
	move.b	(a6)+,d0
	bclr	#5,d0
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
	move.b	(a6)+,d0
	bclr	#5,d0
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

C4240:
	cmp.b	#".",(a6)
	bne.b	C426A
	addq.w	#1,a6
	move.b	(a6)+,d0
	bclr	#5,d0
	cmp.b	#"B",d0
	beq.b	C426A
	cmp.b	#"W",d0
	beq.b	C4266
	cmp.b	#"L",d0
	bne	_ERROR_IllegalSize
	moveq	#4,d1
	rts

C4266:
	moveq	#2,d1
	rts

C426A:
	moveq	#1,d1
	rts

Parse_GetDofAReg:
	bsr	Get_NextChar
	cmp.b	#NS_ALABEL,d1
	bne	C42F6

	btst	#AF_LOCALFOUND,d7
	bne.b	C42D2
	lea	(SourceCode-DT,a4),a3
	move	(a3)+,d1
	bpl.b	C42D2		;bv. d2*2 ?
	and	#$DFDF,d1
	moveq	#-8,d0
	and	d1,d0
	sub	d0,d1
	cmp	#$C410,d0	;Dx
	beq.b	.datareg
	cmp	#$C110,d0	;Ax
	bne.b	Parse_PCorSP
	moveq	#1,d0
	rts

.datareg:
	or.w	#8,d1
	moveq	#1,d0
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
	or.b	#$80,(S_MemIndActEnc-DT,a4)
	move.b	#$3A,d1

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

C42F6:
	clr.b	(S_MemIndActEnc-DT,a4)
	jsr	(Parse_rekenen2).l
	moveq	#0,d0
	rts

C4304:
	addq.l	#6,sp
	jsr	(C10A6C).l
	moveq	#0,d0
	rts

C4310:
	addq.l	#6,sp
	jsr	(Parse_rekenen).l
	moveq	#0,d0
	rts

Parse_CheckIfReservedWord:
	lea	(SourceCode-DT,a4),a3
	move	(a3)+,d1
	and	#$DFDF,d1
	bpl.b	asm_movec_stuff1
	cmp	#"TC"+$8000,d1	;TC
	beq	C45BE
	cmp	#"AC"+$8000,d1	;AC
	beq	C4666
	moveq	#-8,d0
	and	d1,d0
	sub	d0,d1
	cmp	#$C410,d0	;Dx
	beq.b	C4350
	cmp	#$C110,d0	;Ax
	bne.b	C4356
	moveq	#1,d5
	addq.w	#8,d1
	rts

C4350:
	moveq	#0,d5
	moveq	#1,d0
	rts

C4356:
	add	d1,d0
	cmp	#"SR"+$8000,d0	;SR
	beq.b	C436C
	cmp	#"SP"+$8000,d0	;SP
	bne	C44EE
	moveq	#1,d5
	moveq	#15,d1
	rts

C436C:
	move	#$1000,d5
	move	#$007C,d1
	rts

asm_movec_stuff1:
	swap	d1
	move	(a3),d1
	and	#$DFDF,d1
	bpl.w	asm_movec_stufflang
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
	cmp.l	#"PCR"<<(1*8)+$8000,d1	;PCR
	beq	C461A
	cmp.l	#"TT"<<(2*8)+$9000,d1	;TT0
	beq	C45CE
	cmp.l	#"TT"<<(2*8)+$9100,d1	;TT1
	beq	C45D6
	cmp.l	#"AC"<<(2*8)+$9000,d1	;AC0
	beq	C45CE
	cmp.l	#"AC"<<(2*8)+$9100,d1	;AC1
	beq	C45D6

	moveq	#-8,d0
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

asm_movec_stufflang:
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
	moveq	#0,d0
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
	br	C44EE

C4502:
	move	(2,a3),d1
	and	#$DFDF,d1
	cmp	#$D200,d1
	beq	C460C
	br	C44EE

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

C4562:
	move	(2,a3),d1
	and	#$DFDF,d1
	cmp	#$D200,d1
	beq	C46B6
	moveq	#0,d0
	rts

C4576:
	move	#$1000,d5
	move	#$003C,d1
	rts

C4580:
	move	#$2000,d5
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

C45BE:
	tst.b	(MMUAsmBits-DT,a4)
	bne	C4658
	move.l	#$0003FFFF,d5
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

C4658:
	move.b	#$80,(OpperantSize-DT,a4)
	move.l	#$8000FFFF,d5
	rts

C4666:
	move.l	#$8007FFFF,d5
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

C46A2:
	moveq	#0,d0
	move.l	#$0040FFFF,d5
	rts

C46AC:
	moveq	#0,d0
	move.l	#$0080FFFF,d5
	rts

C46B6:
	moveq	#0,d0
	move.l	#$0020FFFF,d5
	rts

C46C0:
	move.b	(a3),d1
	and.b	#$DF,d1
	cmp.b	#$90,d1
	blt.b	C46E0
	cmp.b	#$97,d1
	bgt.b	C46E0
	moveq	#-8,d0
	and	d1,d0
	sub	d0,d1
	move.l	#$0010FFFF,d5
	rts

C46E0:
	moveq	#0,d0
	rts

asm_noimmediateopp:
	bsr	Get_NextChar
	cmp.b	#'#',d1
	bne.b	Get_OtherEA
	br	_ERROR_InvalidAddress

asm_get_any_opp:
	bsr	Get_NextChar
	cmp.b	#'#',d1
	beq	Asm_ImmediateOpp
Get_OtherEA:
	cmp.b	#'(',d1
	beq	Parse_HaakjeOpenVoor
	cmp.b	#'-',d1
	beq	Parse_MinVoor
	
	cmp.b	#NS_ALABEL,d1
	bne	S_Value
	bsr	Parse_CheckIfReservedWord	;ook An, Dn
	bne	Parse_OneRegFound
	clr.b	(S_MemIndActEnc-DT,a4)
	jsr	(Parse_VoorLabelValueInD3_an_dn).l
	br	Parse_ItsAValue

C472C:
	lea	(SourceCode-DT,a4),a1
	lea	(L047E4,pc),a0
	moveq	#0,d0
	move.b	(a6)+,d0
	move.b	(Variable_base-DT,a4,d0.w),d0
	cmp.b	#'@',d0
	bgt.b	C4756
	bne	_ERROR_IllegalOperand
	bset	#AF_LOCALFOUND,d7
	move.b	(a6)+,d0
	move.b	(Variable_base-DT,a4,d0.w),d0
	bgt.b	C475A
	br	_ERROR_IllegalOperand

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

AdresOfDataReg:
	bsr	C472C
	btst	#AF_LOCALFOUND,d7
	bne.b	C47B6
	lea	(SourceCode-DT,a4),a3
	move	(a3)+,d1
	bpl.b	C47B6
	and	#$DFDF,d1
	moveq	#-8,d0
	and	d1,d0
	sub	d0,d1
	cmp	#$C410,d0
	beq.b	C47A4
	cmp	#$C110,d0
	bne.b	C47A8
	moveq	#1,d5
	addq.w	#8,d1
	rts

C47A4:
	moveq	#0,d5
	rts

C47A8:
	add	d1,d0
	cmp	#$D350,d0
	bne.b	C47B6
	moveq	#1,d5
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
	dcb.l	11,0
	dc.l	$0000FF00
	dc.l	$30313233
	dc.l	$34353637
	dc.l	$38390000
	dc.l	0
	dc.l	"ABC"
	dc.l	"DEFG"
	dc.l	"HIJK"
	dc.l	"LMNO"
	dc.l	"PQRS"
	dc.l	"TUVW"
	dc.l	"XYZ"<<(1*8)
	dc.l	$0000005B
	dc.b	0
ALPHA_Two:
	dc.b	'ABCDEFGHIJKLMNOPQRSTUVWXYZ',0,0
	dcb.b	$0000003F,0
	dcb.b	$0000003F,0
	dcb.b	5,0
W048E4:
	dcb.w	$00000018,$FFFF
	dc.w	1
	dc.w	$0203
	dc.w	$0405
	dc.w	$0607
	dc.w	$0809
	dcb.w	3,$FFFF
	dc.w	$FF0A
	dc.w	$0B0C
	dc.w	$0D0E
	dc.w	$0FFF
	dcb.w	12,$FFFF
	dc.w	$FF0A
	dc.w	$0B0C
	dc.w	$0D0E
	dc.w	$0FFF
	dcb.w	12,$FFFF

NEXTSYMBOL_SPACE:
	moveq	#0,d0
C4966:
	move.b	(a6)+,d0
	tst.b	(Variable_base-DT,a4,d0.w)
	bmi.b	C4966
	move	d0,d1
	add.b	d1,d1
	add	(W0498A,pc,d1.w),d1
	jmp	(W0498A,pc,d1.w)

Get_NextChar:
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
	dr.w	_ERROR_NOoperandspac
	dr.w	C4A8A
	dr.w	C4D12
	dr.w	C4A8A
	dr.w	C4B60
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
	dr.w	C4CFA
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
	dr.w	C4AB8
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
	dr.w	C4AB8
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

C4A8A:
	move	d0,d1
	rts

C4A8E:
	moveq	#9,d1
	moveq	#$30,d2
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
	add.b	(a6)+,d0
	sub.b	d2,d0
	cmp.b	d1,d0
	bls.b	C4A9E
C4AB0:
	subq.w	#1,a6
	moveq	#0,d2
	moveq	#$61,d1
	rts

C4AB8:
	movem.l	d0/d4-d7/a0-a5,-(sp)
	move.l	a6,-(sp)
	moveq	#0,d3
	move.b	(a6)+,d3
	rol.l	#8,d3
	move.b	(a6)+,d3
	rol.l	#8,d3
	move.b	(a6)+,d3
	and.l	#$00DFDFDF,d3
	cmp.l	#$00494C45,d3	;ILE ?? (fILEsize thingy)
	bne	C4B56
	move.b	(a6)+,d3
	rol.l	#8,d3
	move.b	(a6)+,d3
	rol.l	#8,d3
	move.b	(a6)+,d3
	rol.l	#8,d3
	move.b	(a6)+,d3
	and.l	#$DFDFDFDF,d3
	cmp.l	#$53495A45,d3	;SIZE
	bne	C4B56
	cmp.b	#$28,(a6)+
	bne	C4B56
	move.l	a6,d3
C4B02:
	tst.b	(a6)
	beq	C4B56
	cmp.b	#$29,(a6)+
	bne.b	C4B02
	subq.w	#1,a6
	clr.b	(a6)
	tst.l	(sp)+
	move.l	a6,-(sp)
	move.l	d3,a6
	lea	(SourceCode-DT,a4),a1
	jsr	(incbinsub1).l
	lea	(CurrentAsmLine-DT,a4),a0
	lea	(INCLUDE_DIRECTORY-DT,a4),a1
	lea	(SourceCode-DT,a4),a3
C4B2E:
	move.b	(a1)+,(a0)+
	bne.b	C4B2E
	subq.w	#1,a0
C4B34:
	move.b	(a3)+,(a0)+
	bne.b	C4B34
	move.l	(sp),a6
	move.b	#$29,(a6)
	jsr	(GetDiskFileLengte).l
	move.l	d0,d3
	moveq	#0,d2
	moveq	#$61,d1
	moveq	#0,d0
	move.l	(sp)+,a6
	addq.w	#1,a6
	movem.l	(sp)+,d0/d4-d7/a0-a5
	rts

C4B56:
	move.l	(sp)+,a6
	movem.l	(sp)+,d0/d4-d7/a0-a5
	br	C4BE4

C4B60:
	moveq	#0,d3
	lea	(W048E4,pc),a0
	move.b	(a6)+,d0
	bmi.w	_ERROR_IllegalOperand
	move.b	(a0,d0.w),d0
	bmi.w	_ERROR_IllegalOperand
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
	moveq	#$61,d1
	rts

C4B8A:
	moveq	#0,d3
	moveq	#-$30,d0
	add.b	(a6)+,d0
	lsr.b	#1,d0
	bne	_ERROR_IllegalOperand
C4B96:
	addx.l	d3,d3
	moveq	#-$30,d0
	add.b	(a6)+,d0
	lsr.b	#1,d0
	beq.b	C4B96
	subq.w	#1,a6
	moveq	#0,d2
	moveq	#$61,d1
	rts

C4BA8:
	moveq	#0,d3
	moveq	#$30,d2
	moveq	#7,d1
	move.b	(a6)+,d0
	sub.b	d2,d0
	cmp.b	d1,d0
	bhi.w	_ERROR_IllegalOperand
C4BB8:
	lsl.l	#3,d3
	or.b	d0,d3
	move.b	(a6)+,d0
	sub.b	d2,d0
	cmp.b	d1,d0
	bls.b	C4BB8
	subq.w	#1,a6
	moveq	#0,d2
	moveq	#$61,d1
	rts

C4BCC:
	bset	#AF_LOCALFOUND,d7
	bclr	#AF_GETLOCAL,d7
	lea	(SourceCode-DT,a4),a1
	move.b	(a6)+,d0
	move.b	(Variable_base-DT,a4,d0.w),(a1)+
	bgt.b	C4BF4
	br	_ERROR_IllegalOperatorInBSS

C4BE4:
	bclr	#AF_LOCALFOUND,d7
	bclr	#AF_GETLOCAL,d7
	lea	(SourceCode-DT,a4),a1
	move.b	(Variable_base-DT,a4,d0.w),(a1)+
C4BF4:
	move.b	(a6)+,d0
	move.b	(Variable_base-DT,a4,d0.w),(a1)+
	ble.b	C4C74
	move.b	(a6)+,d0
	cmp.b	#$2A,d0
	bne.b	C4C14
	cmp.b	#$2C,(1,a6)
	beq.b	C4C68
	cmp.b	#$5D,(1,a6)
	beq.b	C4C68
C4C14:
	cmp.b	#$2E,d0
	bne.b	C4C3A
	cmp.b	#$2C,(1,a6)
	beq.b	C4C68
	cmp.b	#$2A,(1,a6)
	beq.b	C4C68
	cmp.b	#$29,(1,a6)
	beq.b	C4C68
	cmp.b	#$5D,(1,a6)
	beq.b	C4C68
C4C3A:
	move.b	(Variable_base-DT,a4,d0.w),(a1)+
	bgt.b	C4BF4
	cmp.b	#$5C,d0
	beq.b	C4CA0
	cmp.b	#$24,d0
	bne.b	C4C5C
	bset	#AF_LOCALFOUND,d7
	move.b	(a6)+,d0
	tst.b	(Variable_base-DT,a4,d0.w)
	ble.b	C4C5C
	br	_ERROR_IllegalOperatorInBSS

C4C5C:
	subq.w	#3,a1
	or.w	#$8000,(a1)
	subq.l	#1,a6
	moveq	#$62,d1
	rts

C4C68:
	subq.w	#2,a1
	or.w	#$8000,(a1)
	subq.l	#1,a6
	moveq	#$62,d1
	rts

C4C74:
	cmp.b	#$5C,d0
	beq.b	C4CA8
	cmp.b	#$24,d0
	bne.b	C4C90
	bset	#AF_LOCALFOUND,d7
	move.b	(a6)+,d0
	tst.b	(Variable_base-DT,a4,d0.w)
	ble.b	C4C90
	br	_ERROR_IllegalOperatorInBSS

C4C90:
	move	#$8000,d1
	add	-(a1),d1
	clr.b	d1
	move	d1,(a1)
	subq.l	#1,a6
	moveq	#$62,d1
	rts

C4CA0:
	subq.w	#3,a1
	or.w	#$8000,(a1)
	bra.b	C4CB2

C4CA8:
	move	#$8000,d1
	add	-(a1),d1
	clr.b	d1
	move	d1,(a1)
C4CB2:
	cmp.b	#$2E,(a6)+
	bne	C4CCC
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
	moveq	#$62,d1
	rts

C4CEE:
	subq.w	#3,a1
	or.w	#$8000,(a1)
	subq.w	#1,a6
	moveq	#$62,d1
	rts

C4CFA:
	tst.b	(a6)+
	beq.b	C4D0E
	tst.b	(a6)+
	beq.b	C4D0E
	tst.b	(a6)+
	beq.b	C4D0E
	tst.b	(a6)+
	beq.b	C4D0E
	tst.b	(a6)+
	bne.b	C4CFA
C4D0E:
	moveq	#0,d1
	rts

C4D12:
	move.b	d0,d2
	moveq	#0,d3
	btst	#AF_BYTE_STRING,d7
	bne.b	C4D42
	move.b	(a6)+,d1
	beq	_ERROR_MissingQuote
	cmp.b	d2,d1
	bne.b	C4D2A
	bra.b	C4D36

C4D28:
	asl.l	#8,d3
C4D2A:
	move.b	d1,d3
	move.b	(a6)+,d1
	beq	_ERROR_MissingQuote
	cmp.b	d2,d1
	bne.b	C4D28
C4D36:
	cmp.b	(a6)+,d2
	beq.b	C4D28
	subq.w	#1,a6
	moveq	#$61,d1
	moveq	#0,d2
	rts

C4D42:
	move.b	(a6)+,d1
	beq	_ERROR_MissingQuote
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
	beq	_ERROR_MissingQuote
	cmp.b	d2,d1
	bne.b	C4D52
	cmp.b	(a6)+,d2
	beq.b	C4D52
C4D66:
	subq.w	#1,a6
	moveq	#$61,d1
	moveq	#0,d2
	rts

MAKELABEL_NOTSET:
	tst.l	d7	;AF_IF_FALSE
	bmi.b	.end
	btst	#AF_LOCALFOUND,d7
	bne	MAKELABEL_LOCAL_NOTSET
	tst	d7	;passone
	bpl.b	.pass2
	bsr	Parse_CheckIfReservedWord
;	bne	_C00CCE2
	bne	_ERROR_ReservedWord
	bsr	FINDLABEL_GLOBAL
	beq.b	LABEL_CONTINUE_GLOBAL
	jmp	ERROR_DoubleSymbol

.pass2:
	bsr	FINDLABEL_GLOBAL
;	beq	_C00CCF6
	beq	_ERROR_UndefSymbol
	move.l	a0,(CurrentLocalPtr-DT,a4)
	move.l	a0,(LAST_LABEL_ADDRESS-DT,a4)
	bchg	#14,(-6,a0)
	bne.l	ERROR_DoubleSymbol
.end:
	rts

MAKELABEL:
	tst.l	d7	;AF_IF_FALSE
	bmi.b	LABEL_THEEND
	btst	#AF_LOCALFOUND,d7
	bne	C4ED6
	tst	d7	;passone
	bpl.b	LABEL_PASSTWO
	bsr	Parse_CheckIfReservedWord
;	bne	_C00CCE2
	bne	_ERROR_ReservedWord
	bsr	FINDLABEL_GLOBAL
	bne.b	LABEL_CHECK_IF_SET
LABEL_CONTINUE_GLOBAL:
	lea	(GeenIdee-DT,a4),a1
	addq.w	#1,(DATA_NUMOFGLABELS-DT,a4)
	move.l	(LabelEnd-DT,a4),a0
	cmp.l	(WORK_ENDTOP-DT,a4),a0
	bge.w	_ERROR_WorkspaceMemoryFull
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
	beq.b	LABEL_THEEND
	jmp	(CE258).l

LABEL_THEEND:
	rts

LABEL_PASSTWO:
	bsr	FINDLABEL_GLOBAL
	beq	_ERROR_UndefSymbol
	bchg	#14,(-6,a0)
	bne.b	LABEL_CHECK_IF_SET
	move.l	a0,(CurrentLocalPtr-DT,a4)
	move.l	a0,(LAST_LABEL_ADDRESS-DT,a4)
	btst	#AF_OFFSET,d7
	beq.b	LABEL_THEEND
	jmp	(CE258).l

LABEL_CHECK_IF_SET:
	move.l	a0,(LAST_LABEL_ADDRESS-DT,a4)
	swap	d2

;		jsr	test_debug
	and.b	#$3F,d2		; MACRO = $8000
	subq.b	#1,d2
	bne	ERROR_DoubleSymbol

	bsr	Get_NextChar
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
;GET
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
	beq.b	C4EE2
	br	ERROR_DoubleSymbol

C4EBE:
	bsr	Parse_FindlabelLocal
	beq	ERROR_UndefSymbol
	move.l	a0,(LAST_LABEL_ADDRESS-DT,a4)
	bchg	#14,(-6,a0)
	bne	ERROR_DoubleSymbol
	rts

C4ED6:
	tst	d7	;passone
	bpl.b	C4F1A
	bsr	Parse_FindlabelLocal
	bne	LABEL_CHECK_IF_SET
C4EE2:
	lea	(SourceCode-DT,a4),a1
	move.l	(LabelEnd-DT,a4),a0
	cmp.l	(WORK_ENDTOP-DT,a4),a0
	bge.w	ERROR_WorkspaceMemoryFull
	move.l	a0,(a2)
	moveq	#0,d0
	move.l	d0,(a0)+
	move.l	d0,(a0)+
C4EFA:
	move	(a1)+,(a0)+
	bpl.b	C4EFA
	move	(CurrentSection-DT,a4),(a0)+
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),(a0)+
	move.l	a0,(LAST_LABEL_ADDRESS-DT,a4)
	move.l	a0,(LabelEnd-DT,a4)
	btst	#AF_OFFSET,d7
	beq.b	C4F60
	jmp	(CE258).l

C4F1A:
	bsr	Parse_FindlabelLocal
	beq	ERROR_UndefSymbol
	bchg	#14,(-6,a0)
	bne	LABEL_CHECK_IF_SET
	move.l	a0,(LAST_LABEL_ADDRESS-DT,a4)
	btst	#AF_OFFSET,d7
	beq.b	C4F60
	jmp	(CE258).l

C4F3C:
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
C4F58:
	move	(a1)+,(a0)+
	bpl.b	C4F58
	move.l	a0,(LabelEnd-DT,a4)
C4F60:
	rts

C4F62:
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
	move	#$C200,(a0)+
	move.l	d0,(a0)+
	move.l	a0,(LabelEnd-DT,a4)
C4FAC:
	rts

SET_LAST_LABEL_TO_ORG_PTR:
	move.l	(LAST_LABEL_ADDRESS-DT,a4),d0
	beq.b	C4FD6
	clr.l	(LAST_LABEL_ADDRESS-DT,a4)
	move.l	d0,a1
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),d1
	move	(CurrentSection-DT,a4),d2
	btst	#AF_OFFSET,d7
	beq.b	C4FCE
	sub.l	(OFFSET_BASE_ADDRESS-DT,a4),d1
	moveq	#0,d2
C4FCE:
	tst	d7	;passone
	bpl.b	C4FE0
	move.l	d1,-(a1)
	move	d2,-(a1)
C4FD6:
	move.l	d1,(ResponsePtr-DT,a4)
	move	d2,(ResponseType-DT,a4)
	rts

C4FE0:
	cmp.l	-(a1),d1
	bne	ERROR_Codemovedduring
	move	-(a1),d0
	bclr	#14,d0
	cmp	d2,d0
	beq.b	C4FD6
	br	ERROR_Codemovedduring

Parse_FindlabelLocal:
	lea	(SourceCode-DT,a4),a3
	move.l	(CurrentLocalPtr-DT,a4),d0
	beq	ERROR_Notlocalarea
	move.l	d0,a2
	br	Parse_FindlabelNoSupertree

Zoek_uit_extentie:
	movem.l	d0/a3,-(sp)
	lea	(SourceCode-DT,a4),a3
C500E:
	move	(a3)+,d0
	bpl.b	C500E
	move	(-2,a3),d0
	tst.b	d0
	bne.b	C5020
	move.b	(-3,a3),d0
	ror.w	#8,d0

C5020:
	and	#$7F7F,d0
	bclr	#5,d0
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
	st	(B30177-DT,a4)
C505A:
	bsr	Parse_FindLabel
	rts

C5060:
	move.b	#0,(B30177-DT,a4)
	bra.b	C5096

C5068:
	move.b	#1,(B30177-DT,a4)
	bra.b	C5096

C5070:
	move.b	#2,(B30177-DT,a4)
	bra.b	C5096

C5078:
	move.b	#3,(B30177-DT,a4)
	bra.b	C5096

C5080:
	move.b	#4,(B30177-DT,a4)
	bra.b	C5096

C5088:
	move.b	#5,(B30177-DT,a4)
	bra.b	C5096

C5090:
	move.b	#6,(B30177-DT,a4)
C5096:
	movem.l	a1/a3,-(sp)
	bsr	Parse_FindLabel
	movem.l	(sp)+,a1/a3
	bne.b	C50BC
	or.w	#$8000,(-4,a3)
	subq.w	#2,a1
	tst.b	(-1,a3)
	bne.b	C50C6
	clr	-(a3)
	clr.b	-(a3)
	movem.l	(sp)+,d0/a3
	bra.b	C505A

C50BC:
	st	(B30177-DT,a4)
	movem.l	(sp)+,d0/a3
	rts

C50C6:
	clr	-(a3)
	movem.l	(sp)+,d0/a3
	br	C505A

Parse_FindLabel:
	btst	#AF_LOCALFOUND,d7
	bne	Parse_FindlabelLocal
FINDLABEL_GLOBAL:
	lea	(SourceCode-DT,a4),a3
	move	(a3)+,d0
	bpl.b	C50F6
	move	#$8000,d1
	sub	d1,d0
	tst.b	d0
	bne.b	C50EE
	move.b	#$3A,d0
C50EE:
	move	d0,(-2,a3)
	move	d1,(a3)
	addq.w	#2,a1
C50F6:
	move.l	(LabelStart-DT,a4),a2
	sub	#$4030,d0
	moveq	#0,d3
	move.b	d0,d3
	sub.b	d3,d0
	lsr.w	#4,d0
	move	d0,d1
	move	(LabelRollValue-DT,a4),d2
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
	move.l	d2,a3
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

	cmpm.w	(a0)+,(a3)+
	bne.b	C5146
	cmpm.w	(a0)+,(a3)+
	bne.b	C5146
	cmpm.w	(a0)+,(a3)+
	bne.b	C5146
	cmpm.w	(a0)+,(a3)+
	bne.b	C5146
	cmpm.w	(a0)+,(a3)+
	bne.b	C5146
	cmpm.w	(a0)+,(a3)+
	bne.b	C5146
	cmpm.w	(a0)+,(a3)+
	bne.b	C5146
	cmpm.w	(a0)+,(a3)+
	bne.b	C5146
	cmpm.w	(a0)+,(a3)+
	bne.b	C5146
	cmpm.w	(a0)+,(a3)+
	bne.b	C5146
	cmpm.w	(a0)+,(a3)+
	bne.b	C5146
	cmpm.w	(a0)+,(a3)+
	bne.b	C5146
	cmpm.w	(a0)+,(a3)+
	bne.b	C5146
	cmpm.w	(a0)+,(a3)+
	bne.b	C5146
	cmpm.w	(a0)+,(a3)+
	bne.b	C5146
	cmpm.w	(a0)+,(a3)+
	bne.b	C5146
	cmpm.w	(a0)+,(a3)+
	bne.b	C5146
	cmpm.w	(a0)+,(a3)+
	bne.b	C5146
	cmpm.w	(a0)+,(a3)+
	bne.b	C5146
	cmpm.w	(a0)+,(a3)+
	bne.b	C5146
	cmpm.w	(a0)+,(a3)+
	bne.b	C5146
	cmpm.w	(a0)+,(a3)+
	bne.b	C5146
	cmpm.w	(a0)+,(a3)+
	bne.b	C5146
	cmpm.w	(a0)+,(a3)+
	bne.b	C5146
	cmpm.w	(a0)+,(a3)+
	bne.b	C522C
	cmpm.w	(a0)+,(a3)+
	bne.b	C522C
	cmpm.w	(a0)+,(a3)+
	bne.b	C522C
	cmpm.w	(a0)+,(a3)+
	bne.b	C522C
	cmpm.w	(a0)+,(a3)+
	bne.b	C522C
	cmpm.w	(a0)+,(a3)+
	bne.b	C522C
	cmpm.w	(a0)+,(a3)+
	bne.b	C522C
	cmpm.w	(a0)+,(a3)+
	bne.b	C522C
	cmpm.w	(a0)+,(a3)+
	bne.b	C522C
	cmpm.w	(a0)+,(a3)+
	bne.b	C522C
	cmpm.w	(a0)+,(a3)+
	bne.b	C522C
	cmpm.w	(a0)+,(a3)+
	bne.b	C522C
	cmpm.w	(a0)+,(a3)+
	bne.b	C522C
	cmpm.w	(a0)+,(a3)+
	bne.b	C522C
	cmpm.w	(a0)+,(a3)+
	bne.b	C522C
	cmpm.w	(a0)+,(a3)+
	bne.b	C522C
	cmpm.w	(a0)+,(a3)+
	bne.b	C522C
	cmpm.w	(a0)+,(a3)+
	bne.b	C522C
	cmpm.w	(a0)+,(a3)+
	bne.b	C522C
	cmpm.w	(a0)+,(a3)+
	bne.b	C522C
	cmpm.w	(a0)+,(a3)+
	bne.b	C522C
	cmpm.w	(a0)+,(a3)+
	bne.b	C522C
	cmpm.w	(a0)+,(a3)+
	bne.b	C522C
	cmpm.w	(a0)+,(a3)+
	bne.b	C522C
	cmpm.w	(a0)+,(a3)+
	bne.b	C522C
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

C5244:
	move.b	(a0),d2
	swap	d2
	move	(a0)+,d2
	move.l	(a0)+,d3
	btst	#AF_GETLOCAL,d7
	beq.b	C5268
	bclr	#AF_GETLOCAL,d7
	move.l	(LocalBufPtr-DT,a4),a1
	move.l	a0,a2
	lea	(CurrentAsmLine-DT,a4),a3
	bsr	Parse_FindlabelNoSupertree
	tst	d1
	rts

C5268:
	moveq	#$61,d1
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
	moveq	#0,d1
	rts

C528C:
	jsr	(Parse_GetKomma).l
	bsr	Get_NextChar
	cmp.b	#$62,d1
	bne	ERROR_IllegalSectio
	lea	(L052B6,pc),a0
	lea	(SourceCode-DT,a4),a3
	bsr	C5352
	beq	ERROR_IllegalSectio
	moveq	#1,d1
	rts


L052B6:
	dc.l	2
	dc.l	$4441003E
	dc.l	$003C434F
	dc.l	$000C000A
	dc.l	$4253005E
	dc.l	$005C0000
	dc.l	$C4450018
	dc.l	$4445000E
	dc.l	$00040000
	dc.l	$DB50000C
	dc.l	$DB460014
	dc.l	$DB43000A
	dcb.l	2,0
	dc.l	$00010000
	dc.l	2
	dc.l	0
	dc.l	$D4410018
	dc.l	$5441000E
	dc.l	$00040000
	dc.l	$DB50000C
	dc.l	$DB460014
	dc.l	$DB43000A
	dc.l	4
	dc.l	0
	dc.l	$00050000
	dc.l	6
	dc.l	0
	dc.l	$D3000018
	dc.l	$535B000E
	dc.l	$00040000
	dc.l	$D000000C
	dc.l	$C6000014
	dc.l	$C300000A
L0533E:
	dc.l	$00000088
	dc.l	0
	dc.l	$00890000
	dc.l	$0000008A
	dc.l	0

C5352:
	move	#$DFDF,d4
C5356:
	move	(a3)+,d0
	and	d4,d0
	bmi.b	C536A
	add	(a0),a0
C535E:
	addq.w	#4,a0
	cmp	(a0)+,d0
	bcs.b	C535E
	beq.b	C5356
C5366:
	moveq	#0,d0
	rts
	
C536A:
	add	(2,a0),a0
C536E:
	addq.w	#2,a0
	cmp	(a0)+,d0
	bcs.b	C536E
	bne.b	C5366
	add	(a0),a0
	move	(a0)+,d6
	move	(a0)+,d5
	add	(a0),a0
	moveq	#1,d0
	rts

;**************  !!  *******************

	
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
	dc.w	HandleMacroos-Asm_Table ;Q
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
	bne	.asm_date

	move.w	(a3)+,d0
	and.w	d4,d0
	cmp	#"ME"!$8000,d0
	bne	HandleMacroos

	moveq.l	#8-1,d6
	lea	TimeString,a1
	bra.b	.useit

.asm_date:
	cmp.l	#"DA",d0
	bne	HandleMacroos
	move.w	(a3)+,d0
	and.w	d4,d0
	cmp.l	#"TE"!$8000,d0
	bne	HandleMacroos

	moveq.l	#0,d3
	tst.b	(a6)
	beq.s	.noarg
	jsr	Parse_GetExprValueInD3Voor
.noarg:
	move.b	d3,dateformat

	jsr	GetTheTime

	moveq.l	#-2,d6
	lea	DateString,a0
	lea	(a0),a1
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

C53FA:
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
	beq	InsertText6
	cmp	#'DW',d0
	beq.b	C545A
	br	HandleMacroos

W05458:
	dc.w	0

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
	bmi.b	C54B4
	tst	(W05458).l
	bne.b	C548A
	jsr	(C1A0B8).l
	jsr	(C1A11A).l
C548A:
	st	(W05458).l
	movem.l	d0-d7/a0-a5,-(sp)
	move	(DEBUG_NUMOFADDS-DT,a4),d0
	cmp	#8,d0
	beq	ERROR_Tomanywatchpoints
	move.l	a6,-(sp)
	jsr	(CD6E0).l
	move.l	(sp)+,a6
	bsr.b	C54BC
	addq.w	#1,(DEBUG_NUMOFADDS-DT,a4)
	movem.l	(sp)+,d0-d7/a0-a5
C54B4:
	tst.b	(a6)+
	bne.b	C54B4
	subq.w	#1,a6
	rts

C54BC:
	lea	(watch_table).l,a0
	lea	(L1A3CC).l,a1
	lea	(L1A3EC).l,a2
	bra.b	C54D8

C54D0:
	add	#$0010,a0
	addq.w	#8,a1
	addq.w	#1,a2
C54D8:
	tst.b	(a0)
	bne.b	C54D0
	moveq	#14,d0
C54DE:
	move.b	(a6)+,(a0)+
	cmp.b	#$2C,(a6)
	beq.b	C54F4
	dbra	d0,C54DE
	clr.b	(a0)+
C54EC:
	cmp.b	#$2C,(a6)+
	beq.b	C54EC
	bra.b	C54F8

C54F4:
	clr.b	(a0)
	addq.w	#1,a6
C54F8:
	move.l	d3,(a1)
	move.l	a1,(L1A348).l
	move.l	(MainWindowHandle-DT,a4),a1
	bset	#0,($0019,a1)		;rmbtrap
	moveq	#0,d3
C550C:
	move.b	(a6)+,d0
	and.b	#$DF,d0
	moveq	#0,d1
	cmp.b	#$41,d0		;A
	beq	C55D2
	moveq	#1,d1
	cmp.b	#$53,d0		;S
	beq	C55D2
	moveq	#2,d1
	cmp.b	#$48,d0		;H
	beq	C55D2
	moveq	#3,d1
	cmp.b	#$44,d0		;D
	beq	C55D2
	moveq	#4,d1
	cmp.b	#$42,d0		;B
	beq	C55D2
	moveq	#5,d1
	tst.b	d3
	bne	ERROR_IllegalOperand
	cmp.b	#$50,d0		;P
	bne	ERROR_IllegalOperand
	cmp.b	#$2C,(a6)+	;,
	bne	ERROR_IllegalOperand
	move.b	(a6)+,d0
	and.b	#$DF,d0
	cmp.b	#$44,d0		;D
	bne	ERROR_IllegalOperand
	move.b	(a6)+,d0
	and.b	#$DF,d0
	cmp.b	#$43,d0		;C
	beq.b	C559E
	cmp.b	#$52,d0		;R
	bne	ERROR_IllegalOperand
	cmp.b	#$2E,(a6)+	;.
	bne	ERROR_IllegalOperand
	move.b	(a6)+,d0
	and.b	#$DF,d0
	cmp.b	#$4C,d0		;L
	beq.b	C55C2
	cmp.b	#$57,d0		;W
	bne	ERROR_IllegalOperand
	moveq	#$40,d0		;@
	bra.b	C55C4

C559E:
	cmp.b	#$2E,(a6)+	;,
	bne	ERROR_IllegalOperand
	move.b	(a6)+,d0
	and.b	#$DF,d0
	cmp.b	#$4C,d0		;L
	beq.b	C55BE
	cmp.b	#$57,d0		;W
	bne	ERROR_IllegalOperand
	moveq	#$20,d0		;' '
	bra.b	C55C4

C55BE:
	moveq	#$10,d0
	bra.b	C55C4

C55C2:
	moveq	#$30,d0
C55C4:
	or.b	d0,d3
	cmp.b	#$2C,(a6)+
	bne	ERROR_IllegalOperand
	br	C550C

C55D2:
	cmp	#5,d1
	bne.b	C55F8
	cmp.b	#$2C,(a6)+
	bne	ERROR_IllegalOperand
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(CD6E0).l
	move.l	(L1A348).l,a1
	move.l	d3,(4,a1)
	movem.l	(sp)+,d0-d7/a0-a6
C55F8:
	move.l	(MainWindowHandle-DT,a4),a1
	bclr	#0,($0019,a1)		;klaar rmbtrap
	or.b	d1,d3
	bclr	#SB2_A_XN_USED,(SomeBits2-DT,a4)
	beq.b	C5610
	or.b	#$80,d3
C5610:
	move.b	d3,(a2)
	rts

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
	beq	InsertText6
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

C56CC:
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

C5700:
	move	#$D600,d6
	moveq	#0,d5
	jmp	(Asmbl_AddSubCmp).l

C570C:
	move	#$D600,d6
	moveq	#$40,d5
	jmp	(Asmbl_AddSubCmp).l

C5718:
	move	#$D600,d6
	move	#$0080,d5
	jmp	(Asmbl_AddSubCmp).l

InsertText6:
	move	#$D0C0,d6
	move	#$8040,d5
	jmp	(Asmbl_AddSubCmp).l

C5734:
	move	#$D0C0,d6
	move	#$0080,d5
	jmp	(Asmbl_AddSubCmp).l

C5742:
	move	#$5000,d6
	moveq	#0,d5
	jmp	(ASSEM_CMDADDQSUBQ).l

C574E:
	move	#$5040,d6
	moveq	#$40,d5
	jmp	(ASSEM_CMDADDQSUBQ).l

C575A:
	move	#$5080,d6
	move	#$0080,d5
	jmp	(ASSEM_CMDADDQSUBQ).l

C5768:
	move	#$D100,d6
	moveq	#0,d5
	jmp	(CEB92).l

C5774:
	move	#$D140,d6
	moveq	#$40,d5
	jmp	(CEB92).l

C5780:
	move	#$D180,d6
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

C587C:
	move	#$E1C0,d6
	moveq	#0,d5
	jmp	(C10798).l

C5888:
	move	#$E1C0,d6
	moveq	#$40,d5
	jmp	(C10798).l

C5894:
	move	#$E1C0,d6
	move	#$0080,d5
	jmp	(C10798).l

C58A2:
	move	#$E0C0,d6
	moveq	#0,d5
	jmp	(C10798).l

C58AE:
	move	#$E0C0,d6
	moveq	#$40,d5
	jmp	(C10798).l

C58BA:
	move	#$E0C0,d6
	move	#$0080,d5
	jmp	(C10798).l

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
	moveq	#0,d6
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
	jmp	(C102F2).l

C59AE:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"S"<<(1*8)+$8000,d0
	bne	HandleMacroos
	move	#$EFC0,d6
	jmp	(C1031E).l

C59C4:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"O"<<(1*8)+$8000,d0
	bne	HandleMacroos
	move	#$EDC0,d6
	jmp	(Asm_Bitfieldopp).l

Asm_BFEX:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"TS"+$8000,d0
	beq.b	C59F6
	cmp	#"TU"+$8000,d0
	bne	HandleMacroos
	move	#$E9C0,d6
	jmp	(Asm_Bitfieldopp).l

C59F6:
	move	#$EBC0,d6
	jmp	(Asm_Bitfieldopp).l

C5A00:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"T"<<(1*8)+$8000,d0
	bne	HandleMacroos
	move	#$EEC0,d6
	jmp	(C102F2).l

C5A16:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D200,d0
	bne	HandleMacroos
	move	#$ECC0,d6
	jmp	(C102F2).l

C5A2C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C700,d0
	bne	HandleMacroos
	move	#$EAC0,d6
	jmp	(C102F2).l

C5A42:
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
	beq	CD51E
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

C5ACC:
	move	#$6100,d6
	moveq	#0,d5
	jmp	(asmbl_BraB).l

C5AD8:
	move	#$6100,d6
	move	#$0080,d5
	jmp	(asmbl_BraW).l

C5AE6:
	move	#$61FF,d6
	move	#$0080,d5
	jmp	(asmbl_BraL).l

C5AF4:
	move	#$6100,d6
	move	#$0080,d5
	jmp	(asmbl_BraNorm).l

C5B02:
	move	#$08C0,d6
	moveq	#0,d5
	jmp	(ASSEM_CMDBIT).l

C5B0E:
	move	#$08C0,d6
	move	#$0080,d5
	jmp	(ASSEM_CMDBIT).l

C5B1C:
	move	#$08C0,d6
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

C5B5E:
	move	#$6700,d6
	moveq	#0,d5
	jmp	(asmbl_BraB).l

C5B6A:
	move	#$6700,d6
	move	#$0080,d5
	jmp	(asmbl_BraW).l

C5B78:
	cmp	#2,(CPU_type-DT,a4)
	blt.b	C5B6A
	move	#$67FF,d6
	move	#$0080,d5
	jmp	(asmbl_BraL).l

C5B8E:
	move	#$6700,d6
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

C5BD0:
	move	#$6600,d6
	moveq	#0,d5
	jmp	(asmbl_BraB).l

C5BDC:
	move	#$6600,d6
	move	#$0080,d5
	jmp	(asmbl_BraW).l

C5BEA:
	cmp	#2,(CPU_type-DT,a4)
	blt.b	C5BDC
	move	#$66FF,d6
	move	#$0080,d5
	jmp	(asmbl_BraL).l

C5C00:
	move	#$6600,d6
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

C5C4C:
	move	#$6500,d6
	move	#$0080,d5
	jmp	(asmbl_BraNorm).l

C5C5A:
	move	#$0880,d6
	move	#$8040,d5
	jmp	(ASSEM_CMDBIT).l

C5C68:
	move	#$0840,d6
	move	#$8040,d5
	jmp	(ASSEM_CMDBIT).l

C5C76:
	move	#$6400,d6
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

C5CA4:
	move	#$6500,d6
	moveq	#0,d5
	jmp	(asmbl_BraB).l

C5CB0:
	move	#$6500,d6
	move	#$0080,d5
	jmp	(asmbl_BraW).l

C5CBE:
	cmp	#2,(CPU_type-DT,a4)
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

C5CF4:
	move	#$6400,d6
	moveq	#0,d5
	jmp	(asmbl_BraB).l

C5D00:
	move	#$6400,d6
	move	#$0080,d5
	jmp	(asmbl_BraW).l

C5D0E:
	cmp	#2,(CPU_type-DT,a4)
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

C5D40:
	move	#$0880,d6
	moveq	#0,d5
	jmp	(ASSEM_CMDBIT).l

C5D4C:
	move	#$0880,d6
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

C5D76:
	move	#$0840,d6
	moveq	#0,d5
	jmp	(ASSEM_CMDBIT).l

C5D82:
	move	#$0840,d6
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

C5DC0:
	move	#$8800,d6
	moveq	#0,d5
	jmp	(ASSEM_CMDBIT).l

C5DCC:
	move	#$0800,d6
	move	#$0080,d5
	jmp	(ASSEM_CMDBIT).l

C5DDA:
	move	#$8800,d6
	move	#$8040,d5
	jmp	(ASSEM_CMDBIT).l

asm_BR:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C100,d0	;BRA
	beq.b	asm_BRA
	cmp	#$4140,d0	;BRA.
	beq.b	.asm_BRAcont
	cmp	#$C057,d0	;bra.w
	beq.b	.asm_BRAw
	cmp	#$C053,d0	;bra.b
	beq.b	.asm_BRAb
	cmp	#$C04C,d0	;BR.L
	beq.b	.asm_BRAl
	cmp	#$C042,d0	;bra.b
	beq.b	.asm_BRAb
	br	HandleMacroos

.asm_BRAcont:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	.asm_BRAw
	cmp	#$D300,d0
	beq.b	.asm_BRAb
	cmp	#$CC00,d0
	beq.b	.asm_BRAl
	cmp	#$C200,d0
	beq.b	.asm_BRAb
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

C5E6A:
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

C5EB8:
	move	#$6D00,d6
	move	#$0080,d5
	jmp	(asmbl_BraNorm).l

C5EC6:
	move	#$6F00,d6
	move	#$0080,d5
	jmp	(asmbl_BraNorm).l

C5ED4:
	move	#$6500,d6
	move	#$0080,d5
	jmp	(asmbl_BraNorm).l

C5EE2:
	move	#$6300,d6
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

C5F10:
	move	#$6D00,d6
	moveq	#0,d5
	jmp	(asmbl_BraB).l

C5F1C:
	move	#$6D00,d6
	move	#$0080,d5
	jmp	(asmbl_BraW).l

C5F2A:
	cmp	#2,(CPU_type-DT,a4)
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

C5F60:
	move	#$6300,d6
	moveq	#0,d5
	jmp	(asmbl_BraB).l

C5F6C:
	move	#$6300,d6
	move	#$0080,d5
	jmp	(asmbl_BraW).l

C5F7A:
	cmp	#2,(CPU_type-DT,a4)
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

C5FB0:
	move	#$6500,d6
	moveq	#0,d5
	jmp	(asmbl_BraB).l

C5FBC:
	move	#$6500,d6
	move	#$0080,d5
	jmp	(asmbl_BraW).l

C5FCA:
	cmp	#2,(CPU_type-DT,a4)
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

C6000:
	move	#$6F00,d6
	moveq	#0,d5
	jmp	(asmbl_BraB).l

C600C:
	move	#$6F00,d6
	move	#$0080,d5
	jmp	(asmbl_BraW).l

C601A:
	cmp	#2,(CPU_type-DT,a4)
	blt.b	C600C
	move	#$6FFF,d6
	move	#$0080,d5
	jmp	(asmbl_BraL).l

C6030:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq	CDB76
	cmp	#$CC00,d0
	beq.l	CDF24
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

C60D2:
	move	#$6200,d6
	moveq	#0,d5
	jmp	(asmbl_BraB).l

C60DE:
	move	#$6200,d6
	move	#$0080,d5
	jmp	(asmbl_BraW).l

C60EC:
	cmp	#2,(CPU_type-DT,a4)
	blt.b	C60DE
	move	#$62FF,d6
	move	#$0080,d5
	jmp	(asmbl_BraL).l

C6102:
	move	#$6200,d6
	move	#$0080,d5
	jmp	(asmbl_BraNorm).l

C6110:
	move	#$6400,d6
	moveq	#0,d5
	jmp	(asmbl_BraB).l

C611C:
	move	#$6400,d6
	move	#$0080,d5
	jmp	(asmbl_BraW).l

C612A:
	cmp	#2,(CPU_type-DT,a4)
	blt.b	C611C
	move	#$64FF,d6
	move	#$0080,d5
	jmp	(asmbl_BraL).l

C6140:
	move	#$6400,d6
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

C61B8:
	move	#$4AFA,d6
	moveq	#0,d5
	jmp	(Asm_InsertinstrA5).l

C61C4:
	move	#$6C00,d6
	moveq	#0,d5
	jmp	(asmbl_BraB).l

C61D0:
	move	#$6C00,d6
	move	#$0080,d5
	jmp	(asmbl_BraW).l

C61DE:
	cmp	#2,(CPU_type-DT,a4)
	blt.b	C61D0
	move	#$6CFF,d6
	move	#$0080,d5
	jmp	(asmbl_BraL).l

C61F4:
	move	#$6C00,d6
	move	#$0080,d5
	jmp	(asmbl_BraNorm).l

C6202:
	move	#$6E00,d6
	moveq	#0,d5
	jmp	(asmbl_BraB).l

C620E:
	move	#$6E00,d6
	move	#$0080,d5
	jmp	(asmbl_BraW).l

C621C:
	cmp	#2,(CPU_type-DT,a4)
	blt.b	C620E
	move	#$6EFF,d6
	move	#$0080,d5
	jmp	(asmbl_BraL).l

C6232:
	move	#$6E00,d6
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

C6274:
	move	#$6B00,d6
	moveq	#0,d5
	jmp	(asmbl_BraB).l

C6280:
	move	#$6B00,d6
	move	#$0080,d5
	jmp	(asmbl_BraW).l

C628E:
	cmp	#2,(CPU_type-DT,a4)
	blt.w	C60DE
	move	#$6BFF,d6
	move	#$0080,d5
	jmp	(asmbl_BraL).l

C62A6:
	move	#$6B00,d6
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
	beq	C6744
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
	jmp	(C10134).l

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
	cmp	#$CF50,d0
	beq	Asm_CNOP
	br	HandleMacroos

Asm_CNOP:
	jsr	(Parse_GetDefinedValue).l
	tst.l	d3
	bmi.w	ERROR_WorkspaceMemoryFull
	move.l	d3,-(sp)
	bsr	Parse_GetKomma
	jsr	(Parse_GetDefinedValue).l
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),d0
	subq.l	#1,d3
	move.l	d0,d1
	neg.l	d0
	and.l	d3,d0
	add.l	d0,d1
	add.l	(sp)+,d1
	move.l	d1,(INSTRUCTION_ORG_PTR-DT,a4)
	jmp	(SET_LAST_LABEL_TO_ORG_PTR).l

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
	beq	C6654
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
	cmp	#$C954,d0	;cmexit
	beq	CE45C
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

C663A:
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

C6670:
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

C66A4:
	move	#$BC01,d6
	moveq	#0,d5
	jmp	(Asmbl_AddSubCmp).l

Asm_Cmp:
	move	#$BC01,d6
	moveq	#$40,d5
	jmp	(Asmbl_AddSubCmp).l

C66BC:
	move	#$BC01,d6
	move	#$0080,d5
	jmp	(Asmbl_AddSubCmp).l

C66CA:
	move	#$B108,d6
	moveq	#0,d5
	jmp	(Asmbl_Cmpm).l

Asm_Cmpm:
	move	#$B148,d6
	moveq	#$40,d5
	jmp	(Asmbl_Cmpm).l

C66E2:
	move	#$B188,d6
	move	#$0080,d5
	jmp	(Asmbl_Cmpm).l

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

C6744:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$4B40,d0
	beq.b	C6768
	cmp	#$CB00,d0
	beq	C727E
	cmp	#$CB12,d0
	beq	C7298
	cmp	#$4B12,d0
	beq.b	C6788
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

C6788:
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
	beq	CD968
	cmp	#"DC"+$8000,d0
	beq	CDAE6
	br	HandleMacroos

C67E8:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"@W"+$8000,d0
	beq	CD968
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

C6856:
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

C6896:
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
	cmp	#$C044,d0
	beq	CE1DC
	cmp	#$C058,d0
	beq	CE202
	cmp	#$C050,d0
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
	bmi.b	.o
	add.w	#$8000,d0
.o
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
	beq	C6A7C
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

C6A44:
	move	#$54C8,d6
	move	#$0080,d5
	jmp	(asmbl_dbcc).l

C6A52:
	move	#$51C8,d6
	move	#$0080,d5
	jmp	(asmbl_dbcc).l

C6A60:
	move	#$50C8,d6
	move	#$0080,d5
	jmp	(asmbl_dbcc).l

C6A6E:
	move	#$55C8,d6
	move	#$0080,d5
	jmp	(asmbl_dbcc).l

C6A7C:
	move	#$52C8,d6
	move	#$0080,d5
	jmp	(asmbl_dbcc).l

C6A8A:
	move	#$54C8,d6
	move	#$0080,d5
	jmp	(asmbl_dbcc).l

C6A98:
	move	#$56C8,d6
	move	#$0080,d5
	jmp	(asmbl_dbcc).l

C6AA6:
	move	#$55C8,d6
	move	#$0080,d5
	jmp	(asmbl_dbcc).l

C6AB4:
	move	#$57C8,d6
	move	#$0080,d5
	jmp	(asmbl_dbcc).l

C6AC2:
	move	#$5BC8,d6
	move	#$0080,d5
	jmp	(asmbl_dbcc).l

C6AD0:
	move	#$5CC8,d6
	move	#$0080,d5
	jmp	(asmbl_dbcc).l

C6ADE:
	move	#$5EC8,d6
	move	#$0080,d5
	jmp	(asmbl_dbcc).l

C6AEC:
	move	#$5AC8,d6
	move	#$0080,d5
	jmp	(asmbl_dbcc).l

C6AFA:
	move	#$5FC8,d6
	move	#$0080,d5
	jmp	(asmbl_dbcc).l

C6B08:
	move	#$53C8,d6
	move	#$0080,d5
	jmp	(asmbl_dbcc).l

C6B16:
	move	#$5DC8,d6
	move	#$0080,d5
	jmp	(asmbl_dbcc).l

C6B24:
	move	#$58C8,d6
	move	#$0080,d5
	jmp	(asmbl_dbcc).l

C6B32:
	move	#$59C8,d6
	move	#$0080,d5
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
	beq	CD5EE
	cmp	#"DM"+$8000,d0
	beq	CE44E
	cmp	#"DC"+$8000,d0
	beq	CE5BC
	cmp	#"DC",d0
	beq.b	C6BCC
	cmp	#"D"<<(1*8)+$8000,d0
	beq	CE27E
	cmp	#"DB"+$8000,d0
	beq	CD55C
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
	beq	CE5BC
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
	beq	CE5BC
	br	HandleMacroos

C6BFE:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D345,d0
	beq	CE5AC
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
	moveq	#2,d0
	bsr	Processor_warning
	move	#$49C0,d6
	moveq	#0,d5
	jmp	(C1088C).l

C6CAC:
	move	#$C140,d6
	move	#$0080,d5
	br	_CEBCE

C6CB8:
	move	#$4880,d6
	moveq	#$40,d5
	jmp	(C1088C).l

C6CC4:
	move	#$48C0,d6
	move	#$0080,d5
	jmp	(C1088C).l

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
	br	_CEAB8

C6D30:
	move	#$BA00,d6
	moveq	#$40,d5
	br	_CEAB8

C6D3A:
	move	#$BA00,d6
	move	#$0080,d5
	br	_CEAB8

C6D46:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C54E,d0
	beq	CD93C
	br	HandleMacroos

C6D56:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D500,d0
	beq	Asm_EQU
	cmp	#$D552,d0
	beq	CD706
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
	beq	C6EC0
	br	ERROR_Illegalfloating

C6E6C:
	move.l	#$0011F200,d6
	moveq	#6,d5
	jmp	(CFB00).l

C6E7A:
	move.l	#$0011F200,d6
	moveq	#4,d5
	jmp	(CFB00).l

C6E88:
	move.l	#$0011F200,d6
	moveq	#0,d5
	jmp	(CFB00).l

C6E96:
	move.l	#$0011F200,d6
	moveq	#$71,d5
	jmp	(CFB00).l

C6EA4:
	move.l	#$0011F200,d6
	moveq	#$75,d5
	jmp	(CFB00).l

C6EB2:
	move.l	#$0011F200,d6
	moveq	#$72,d5
	jmp	(CFB00).l

C6EC0:
	move.l	#$0011F200,d6
	moveq	#$73,d5
	jmp	(CFB00).l

C6ECE:
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

C6F00:
	move.l	#$003AF200,d6
	moveq	#6,d5
	jmp	(CFA78).l

C6F0E:
	move.l	#$003AF200,d6
	moveq	#4,d5
	jmp	(CFA78).l

C6F1C:
	move.l	#$003AF200,d6
	moveq	#0,d5
	jmp	(CFA78).l

C6F2A:
	move.l	#$003AF200,d6
	moveq	#$71,d5
	jmp	(CFA78).l

C6F38:
	move.l	#$003AF200,d6
	moveq	#$75,d5
	jmp	(CFA78).l

C6F46:
	move.l	#$003AF200,d6
	moveq	#$72,d5
	jmp	(CFA78).l

C6F54:
	move.l	#$003AF200,d6
	moveq	#$73,d5
	jmp	(CFA78).l

C6F62:
;		jsr	test_debug
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D046,d0
	beq	C6FD6
	cmp	#$5046,d0
	beq	C6FC2
	cmp	#$5045,d0
	beq	C7032
	cmp	#$504F,d0
	beq	C707E
	cmp	#$5055,d0
	beq	C75BE
	cmp	#$504E,d0
	beq	C7770
	cmp	#$D054,d0
	beq	C700E
	cmp	#$5054,d0
	beq	C6FFA
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

C6FD6:
	move.l	#$F27C0000,d6
	jmp	(CFA44).l

C6FE2:
	move.l	#$F27A0000,d6
	jmp	(CFA44).l

C6FEE:
	move.l	#$F27B0000,d6
	jmp	(CFA44).l

C6FFA:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C701A
	cmp	#$C04C,d0
	beq.b	C7026
	br	ERROR_IllegalSize

C700E:
	move.l	#$F27C000F,d6
	jmp	(CFA44).l

C701A:
	move.l	#$F27A000F,d6
	jmp	(CFA44).l

C7026:
	move.l	#$F27B000F,d6
	jmp	(CFA44).l

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

C705A:
	move.l	#$F27C0001,d6
	jmp	(CFA44).l

C7066:
	move.l	#$F27A0001,d6
	jmp	(CFA44).l

C7072:
	move.l	#$F27B0001,d6
	jmp	(CFA44).l

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

C70F4:
	move.l	#$F27C0002,d6
	jmp	(CFA44).l

C7100:
	move.l	#$F27A0002,d6
	jmp	(CFA44).l

C710C:
	move.l	#$F27B0002,d6
	jmp	(CFA44).l

C7118:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C7138
	cmp	#$C04C,d0
	beq.b	C7144
	br	ERROR_IllegalSize

C712C:
	move.l	#$F27C0003,d6
	jmp	(CFA44).l

C7138:
	move.l	#$F27A0003,d6
	jmp	(CFA44).l

C7144:
	move.l	#$F27B0003,d6
	jmp	(CFA44).l

C7150:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C7170
	cmp	#$C04C,d0
	beq.b	C717C
	br	ERROR_IllegalSize

C7164:
	move.l	#$F27C0004,d6
	jmp	(CFA44).l

C7170:
	move.l	#$F27A0004,d6
	jmp	(CFA44).l

C717C:
	move.l	#$F27B0004,d6
	jmp	(CFA44).l

C7188:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C71A8
	cmp	#$C04C,d0
	beq.b	C71B4
	br	ERROR_IllegalSize

C719C:
	move.l	#$F27C0005,d6
	jmp	(CFA44).l

C71A8:
	move.l	#$F27A0005,d6
	jmp	(CFA44).l

C71B4:
	move.l	#$F27B0005,d6
	jmp	(CFA44).l

C71C0:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C71E0
	cmp	#$C04C,d0
	beq.b	C71EC
	br	ERROR_IllegalSize

C71D4:
	move.l	#$F27C0006,d6
	jmp	(CFA44).l

C71E0:
	move.l	#$F27A0006,d6
	jmp	(CFA44).l

C71EC:
	move.l	#$F27B0006,d6
	jmp	(CFA44).l

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
	move	#$00C0,d6
	moveq	#$0000,d5
	jmp	(asm_cmp2_long_stuff).l

cmp2_stuff_w:
	move	#$02C0,d6
	moveq	#$040,d5
	jmp	(asm_cmp2_long_stuff).l

cmp2_stuff_l:
	move	#$04C0,d6
	move	#$080,d5
	jmp	(asm_cmp2_long_stuff).l


;00F8 0000 0012		cmp2.b
;02F8 0000 1234		cmp2.w
;04F9 0000 12345678 	cmp2.l

;$00BF,$00,$00,$00,$12
;$02BF $00,$00,$12,$34
;$04F9,$00,$00 $12,$34,$56,$78

C727E:
	move	#$4180,d6
	moveq	#$40,d5
	jmp	(C1006E).l

C728A:
	move	#$4100,d6
	move	#$0080,d5
	jmp	(C1006E).l

C7298:
	move	#$02C0,d6
	move	#$0080,d5
	jmp	(asm_cmp2_long_stuff).l

C72A6:
	move	#$04C0,d6
	move	#$0080,d5
	jmp	(asm_cmp2_long_stuff).l

C72B4:
	move	#$00C0,d6
	move	#$0080,d5
	jmp	(asm_cmp2_long_stuff).l



;*********** copy table error msgs *************

;			br	ERROR_AddressRegByte
_ERROR_AddressRegExp:	br	ERROR_AddressRegExp
_ERROR_Dataregexpect:	br	ERROR_Dataregexpect
;			br	ERROR_DoubleSymbol
_ERROR_EndofFile:	br	ERROR_EndofFile
;			br	ERROR_UsermadeFAIL
;			br	ERROR_FileError
_ERROR_InvalidAddress:	br	ERROR_InvalidAddress
;			br	ERROR_IllegalDevice
;			br	ERROR_IllegalMacrod
_ERROR_IllegalOperator:	br	ERROR_IllegalOperator
_ERROR_IllegalOperatorInBSS:br	ERROR_IllegalOperatorInBSS
_ERROR_IllegalOperand:	br	ERROR_IllegalOperand
_ERROR_IllegalOrder:	br	ERROR_IllegalOrder
;			br	ERROR_IllegalSectio
_ERROR_IllegalAddres:	br	ERROR_IllegalAddres
_ERROR_Illegalregsiz:	br	ERROR_Illegalregsiz
;			br	ERROR_IllegalPath
_ERROR_IllegalSize:	br	ERROR_IllegalSize
_ERROR_IllegalComman:	br	ERROR_IllegalComman
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
;			br	ERROR_out_of_range0bit
_ERROR_out_of_range3bit:br	ERROR_out_of_range3bit
;			br	ERROR_out_of_range4bit
;			br	ERROR_out_of_range8bit
_ERROR_out_of_range16bit:br	ERROR_out_of_range16bit
_ERROR_RelativeModeEr:	br	ERROR_RelativeModeEr
_ERROR_ReservedWord:	br	ERROR_ReservedWord
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
;			br	ERROR_FPUneededforopp
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
_ERROR_ThisisnotaAsmProj:br	ERROR_ThisisnotaAsmProj
;			br	ERROR_Bitfieldoutofrange32bit
;			br	ERROR_GeneralPurpose
_ERROR_AdrOrPCExpected:	br	ERROR_AdrOrPCExpected
_ERROR_UnknowCPU:	br	ERROR_UnknowCPU


;***************************************************

_CEAB8:	bra	CEAB8

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
;	moveq.l	#0,d0
	move.b	d3,d0
	ext.w	d0
	ext.l	d0
	cmp.l	d0,d3
	beq.b	asmbl_send_Byte
	bra	ERROR_out_of_range8bit

Parse_MakeExtentionLongword 	;move.l	([kake],100.l),d2
	btst	#AF_UNDEFVALUE,d7
	bne.b	C753A
	tst	d2
	bne	Asmbl_send_XREF_dataB
	bra	asmbl_send_Byte		

C755A:
	btst	#AF_UNDEFVALUE,d7
	bne	asmbl_send_Word\.pass1
	tst	d2
	bne	Asmbl_send_XREF_dataW

;	moveq.l	#0,d0
	move	d3,d0
	ext.l	d0
	cmp.l	d0,d3
	bne	ERROR_out_of_range16bit
	br	asmbl_send_Word

C7576:
	bclr	#AF_OFFSET,d7
	move	(LastSection-DT,a4),d0
	jsr	(C29EE).l
	jsr	(Parse_GetDefinedValue).l
	cmp.l	(INSTRUCTION_ORG_PTR-DT,a4),d3
	blt.w	ERROR_RelativeModeEr
	move.l	d3,(INSTRUCTION_ORG_PTR-DT,a4)
	br	SET_LAST_LABEL_TO_ORG_PTR

C759A:
	move.l	#$F27C0007,d6
	jmp	(CFA44).l

C75A6:
	move.l	#$F27A0007,d6
	jmp	(CFA44).l

C75B2:
	move.l	#$F27B0007,d6
	jmp	(CFA44).l

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

C7634:
	move.l	#$F27C0008,d6
	jmp	(CFA44).l

C7640:
	move.l	#$F27A0008,d6
	jmp	(CFA44).l

C764C:
	move.l	#$F27B0008,d6
	jmp	(CFA44).l

C7658:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C7678
	cmp	#$C04C,d0
	beq.b	C7684
	br	ERROR_IllegalSize

C766C:
	move.l	#$F27C0009,d6
	jmp	(CFA44).l

C7678:
	move.l	#$F27A0009,d6
	jmp	(CFA44).l

C7684:
	move.l	#$F27B0009,d6
	jmp	(CFA44).l

C7690:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C76B0
	cmp	#$C04C,d0
	beq.b	C76BC
	br	ERROR_IllegalSize

C76A4:
	move.l	#$F27C000A,d6
	jmp	(CFA44).l

C76B0:
	move.l	#$F27A000A,d6
	jmp	(CFA44).l

C76BC:
	move.l	#$F27B000A,d6
	jmp	(CFA44).l

C76C8:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C76E8
	cmp	#$C04C,d0
	beq.b	C76F4
	br	ERROR_IllegalSize

C76DC:
	move.l	#$F27C000B,d6
	jmp	(CFA44).l

C76E8:
	move.l	#$F27A000B,d6
	jmp	(CFA44).l

C76F4:
	move.l	#$F27B000B,d6
	jmp	(CFA44).l

C7700:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C7720
	cmp	#$C04C,d0
	beq.b	C772C
	br	ERROR_IllegalSize

C7714:
	move.l	#$F27C000C,d6
	jmp	(CFA44).l

C7720:
	move.l	#$F27A000C,d6
	jmp	(CFA44).l

C772C:
	move.l	#$F27B000C,d6
	jmp	(CFA44).l

C7738:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C7758
	cmp	#$C04C,d0
	beq.b	C7764
	br	ERROR_IllegalSize

C774C:
	move.l	#$F27C000D,d6
	jmp	(CFA44).l

C7758:
	move.l	#$F27A000D,d6
	jmp	(CFA44).l

C7764:
	move.l	#$F27B000D,d6
	jmp	(CFA44).l

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

C780A:
	move.l	#$F27C0018,d6
	jmp	(CFA44).l

C7816:
	move.l	#$F27A0018,d6
	jmp	(CFA44).l

C7822:
	move.l	#$F27B0018,d6
	jmp	(CFA44).l

C782E:
	move.l	#$F27C0019,d6
	jmp	(CFA44).l

C7852:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C7872
	cmp	#$C04C,d0
	beq.b	C787E
	br	ERROR_IllegalSize

C7866:
	move.l	#$F27C001A,d6
	jmp	(CFA44).l

C7872:
	move.l	#$F27A001A,d6
	jmp	(CFA44).l

C787E:
	move.l	#$F27B001A,d6
	jmp	(CFA44).l

C788A:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C78AA
	cmp	#$C04C,d0
	beq.b	C78B6
	br	ERROR_IllegalSize

C789E:
	move.l	#$F27C001B,d6
	jmp	(CFA44).l

C78AA:
	move.l	#$F27A001B,d6
	jmp	(CFA44).l

C78B6:
	move.l	#$F27B001B,d6
	jmp	(CFA44).l

C78C2:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C78E2
	cmp	#$C04C,d0
	beq.b	C78EE
	br	ERROR_IllegalSize

C78D6:
	move.l	#$F27C001C,d6
	jmp	(CFA44).l

C78E2:
	move.l	#$F27A001C,d6
	jmp	(CFA44).l

C78EE:
	move.l	#$F27B001C,d6
	jmp	(CFA44).l

C78FA:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C791A
	cmp	#$C04C,d0
	beq.b	C7926
	br	ERROR_IllegalSize

C790E:
	move.l	#$F27C001D,d6
	jmp	(CFA44).l

C791A:
	move.l	#$F27A001D,d6
	jmp	(CFA44).l

C7926:
	move.l	#$F27B001D,d6
	jmp	(CFA44).l

C7932:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C7952
	cmp	#$CC00,d0
	beq.b	C795E
	br	ERROR_IllegalSize

C7946:
	move.l	#$F27C000E,d6
	jmp	(CFA44).l

C7952:
	move.l	#$F27A000E,d6
	jmp	(CFA44).l

C795E:
	move.l	#$F27B000E,d6
	jmp	(CFA44).l

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
	beq	C7A1A
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

C79BE:
	move.l	#$F27C0010,d6
	jmp	(CFA44).l

C79CA:
	move.l	#$F27A0010,d6
	jmp	(CFA44).l

C79D6:
	move.l	#$F27B0010,d6
	jmp	(CFA44).l

C79E2:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C7A02
	cmp	#$CC00,d0
	beq.b	C7A0E
	br	ERROR_IllegalSize

C79F6:
	move.l	#$F27C001F,d6
	jmp	(CFA44).l

C7A02:
	move.l	#$F27A001F,d6
	jmp	(CFA44).l

C7A0E:
	move.l	#$F27B001F,d6
	jmp	(CFA44).l

C7A1A:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C7A3A
	cmp	#$C04C,d0
	beq.b	C7A46
	br	ERROR_IllegalSize

C7A2E:
	move.l	#$F27C0011,d6
	jmp	(CFA44).l

C7A3A:
	move.l	#$F27A0011,d6
	jmp	(CFA44).l

C7A46:
	move.l	#$F27B0011,d6
	jmp	(CFA44).l

C7A52:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C7A72
	cmp	#$C04C,d0
	beq.b	C7A7E
	br	ERROR_IllegalSize

C7A66:
	move.l	#$F27C001E,d6
	jmp	(CFA44).l

C7A72:
	move.l	#$F27A001E,d6
	jmp	(CFA44).l

C7A7E:
	move.l	#$F27B001E,d6
	jmp	(CFA44).l

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

C7ADC:
	move.l	#$F27C0012,d6
	br	_C00FA44

C7AE6:
	move.l	#$F27A0012,d6
	br	_C00FA44

C7AF0:
	move.l	#$F27B0012,d6
	br	_C00FA44

C7AFA:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C7B18
	cmp	#$CC00,d0
	beq.b	C7B22
	br	ERROR_IllegalSize

C7B0E:
	move.l	#$F27C0013,d6
	br	_C00FA44

C7B18:
	move.l	#$F27A0013,d6
	br	_C00FA44

C7B22:
	move.l	#$F27B0013,d6
	br	_C00FA44

C7B2C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C7B4A
	cmp	#$CC00,d0
	beq.b	C7B54
	br	ERROR_IllegalSize

C7B40:
	move.l	#$F27C0016,d6
	br	_C00FA44

C7B4A:
	move.l	#$F27A0016,d6
	br	_C00FA44

C7B54:
	move.l	#$F27B0016,d6
	br	_C00FA44

C7B5E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C7B7C
	cmp	#$C04C,d0
	beq.b	C7B86
	br	ERROR_IllegalSize

C7B72:
	move.l	#$F27C0017,d6
	br	_C00FA44

C7B7C:
	move.l	#$F27A0017,d6
	br	_C00FA44

C7B86:
	move.l	#$F27B0017,d6
	br	_C00FA44

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

C7BC4:
	move.l	#$F27C0014,d6
	br	_C00FA44

C7BCE:
	move.l	#$F27A0014,d6
	br	_C00FA44

C7BD8:
	move.l	#$F27B0014,d6
	br	_C00FA44

C7BE2:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C7C00
	cmp	#$CC00,d0
	beq.b	C7C0A
	br	ERROR_IllegalSize

C7BF6:
	move.l	#$F27C0015,d6
	br	_C00FA44

C7C00:
	move.l	#$F27A0015,d6
	br	_C00FA44

C7C0A:
	move.l	#$F27B0015,d6
	br	_C00FA44

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
	beq	C7CB2
	br	HandleMacroos

C7C6A:
	move.l	#$0012F200,d6
	moveq	#6,d5
	br	_CFB00

C7C76:
	move.l	#$0012F200,d6
	moveq	#4,d5
	br	_CFB00

C7C82:
	move.l	#$0012F200,d6
	moveq	#0,d5
	br	_CFB00

C7C8E:
	move.l	#$0012F200,d6
	moveq	#$71,d5
	br	_CFB00

C7C9A:
	move.l	#$0012F200,d6
	moveq	#$75,d5
	br	_CFB00

C7CA6:
	move.l	#$0012F200,d6
	moveq	#$72,d5
	br	_CFB00

C7CB2:
	move.l	#$0012F200,d6
	moveq	#$73,d5
	br	_CFB00

C7CBE:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$4840,d0
	beq	C7D56
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
	beq	C7D4A
	br	HandleMacroos

C7D02:
	move.l	#$000FF200,d6
	moveq	#6,d5
	br	_CFB00

C7D0E:
	move.l	#$000FF200,d6
	moveq	#4,d5
	br	_CFB00

C7D1A:
	move.l	#$000FF200,d6
	moveq	#0,d5
	br	_CFB00

C7D26:
	move.l	#$000FF200,d6
	moveq	#$71,d5
	br	_CFB00

C7D32:
	move.l	#$000FF200,d6
	moveq	#5,d5
	br	_CFB00

C7D3E:
	move.l	#$000FF200,d6
	moveq	#$72,d5
	br	_CFB00

C7D4A:
	move.l	#$000FF200,d6
	moveq	#$73,d5
	br	_CFB00

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
	beq	C7DD2
	br	ERROR_Illegalfloating

C7D8A:
	move.l	#$0009F200,d6
	moveq	#6,d5
	br	_CFB00

C7D96:
	move.l	#$0009F200,d6
	moveq	#4,d5
	br	_CFB00

C7DA2:
	move.l	#$0009F200,d6
	moveq	#0,d5
	br	_CFB00

C7DAE:
	move.l	#$0009F200,d6
	moveq	#$71,d5
	br	_CFB00

C7DBA:
	move.l	#$0009F200,d6
	moveq	#$75,d5
	br	_CFB00

C7DC6:
	move.l	#$0009F200,d6
	moveq	#$72,d5
	br	_CFB00

C7DD2:
	move.l	#$0009F200,d6
	moveq	#$73,d5
	br	_CFB00

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
	cmp	#$5542,d0	;fsSU
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
	cmp	#$474C,d0
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
	beq	C7F52
	br	HandleMacroos

C7F0A:
	move.l	#$0028F200,d6
	moveq	#6,d5
	br	Asm_FPopperant

C7F16:
	move.l	#$0028F200,d6
	moveq	#4,d5
	br	Asm_FPopperant

C7F22:
	move.l	#$0028F200,d6
	moveq	#0,d5
	br	Asm_FPopperant

C7F2E:
	move.l	#$0028F200,d6
	moveq	#$71,d5
	br	Asm_FPopperant

C7F3A:
	move.l	#$0028F200,d6
	moveq	#$75,d5
	br	Asm_FPopperant

C7F46:
	move.l	#$0028F200,d6
	moveq	#$72,d5
	br	Asm_FPopperant

C7F52:
	move.l	#$0028F200,d6
	moveq	#$73,d5
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
	beq	C7FEE
	br	ERROR_Illegalfloating

C7FA6:
	move.l	#$0004F200,d6
	moveq	#6,d5
	br	CFB00

C7FB2:
	move.l	#$0004F200,d6
	moveq	#4,d5
	br	CFB00

C7FBE:
	move.l	#$0004F200,d6
	moveq	#0,d5
	br	CFB00

C7FCA:
	move.l	#$0004F200,d6
	moveq	#$71,d5
	br	CFB00

C7FD6:
	move.l	#$0004F200,d6
	moveq	#$75,d5
	br	CFB00

C7FE2:
	move.l	#$0004F200,d6
	moveq	#$72,d5
	br	CFB00

C7FEE:
	move.l	#$0004F200,d6
	moveq	#$73,d5
	br	CFB00

C7FFA:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$4840,d0
	beq	C8134
	cmp	#$C800,d0
	beq	C81A2
	cmp	#$434F,d0
	beq	C8098
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

C8044:
	move.l	#$000EF200,d6
	moveq	#6,d5
	br	CFB00

C8050:
	move.l	#$000EF200,d6
	moveq	#4,d5
	br	CFB00

C805C:
	move.l	#$000EF200,d6
	moveq	#0,d5
	br	CFB00

C8068:
	move.l	#$000EF200,d6
	moveq	#$71,d5
	br	CFB00

C8074:
	move.l	#$000EF200,d6
	moveq	#$75,d5
	br	CFB00

C8080:
	move.l	#$000EF200,d6
	moveq	#$72,d5
	br	CFB00

C808C:
	move.l	#$000EF200,d6
	moveq	#$73,d5
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
	beq	C8128
	br	ERROR_Illegalfloating

C80E0:
	move.l	#$0030F200,d6
	moveq	#6,d5
	br	CFC6A

C80EC:
	move.l	#$0030F200,d6
	moveq	#4,d5
	br	CFC6A

C80F8:
	move.l	#$0030F200,d6
	moveq	#0,d5
	br	CFC6A

C8104:
	move.l	#$0030F200,d6
	moveq	#$71,d5
	br	CFC6A

C8110:
	move.l	#$0030F200,d6
	moveq	#$75,d5
	br	CFC6A

C811C:
	move.l	#$0030F200,d6
	moveq	#$72,d5
	br	CFC6A

C8128:
	move.l	#$0030F200,d6
	moveq	#$73,d5
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

C8166:
	move.l	#$0002F200,d6
	moveq	#6,d5
	br	CFB00

C8172:
	move.l	#$0002F200,d6
	moveq	#4,d5
	br	CFB00

C817E:
	move.l	#$0002F200,d6
	moveq	#0,d5
	br	CFB00

C818A:
	move.l	#$0002F200,d6
	moveq	#$71,d5
	br	CFB00

C8196:
	move.l	#$0002F200,d6
	moveq	#$75,d5
	br	CFB00

C81A2:
	move.l	#$0002F200,d6
	moveq	#$72,d5
	br	CFB00

C81AE:
	move.l	#$0002F200,d6
	moveq	#$73,d5
	br	CFB00

C81BA:
	move.l	#$0015F240,d6
	br	CF48C

C81C4:
	move.l	#$0014F240,d6
	br	CF48C

C81CE:
	move.l	#$0013F240,d6
	br	CF48C

C81D8:
	move.l	#$0012F240,d6
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
	beq	C82B2
	cmp	#$4C40,d0
	beq.b	C8244
	br	HandleMacroos

C822C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D600,d0
	beq	C8338
	cmp	#$5640,d0
	beq	C82CA
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

C8276:
	move.l	#$0027F200,d6
	moveq	#6,d5
	br	Asm_FPopperant

C8282:
	move.l	#$0027F200,d6
	moveq	#4,d5
	br	Asm_FPopperant

C828E:
	move.l	#$0027F200,d6
	moveq	#0,d5
	br	Asm_FPopperant

C829A:
	move.l	#$0027F200,d6
	moveq	#$71,d5
	br	Asm_FPopperant

C82A6:
	move.l	#$0027F200,d6
	moveq	#$75,d5
	br	Asm_FPopperant

C82B2:
	move.l	#$0027F200,d6
	moveq	#$72,d5
	br	Asm_FPopperant

C82BE:
	move.l	#$0027F200,d6
	moveq	#$73,d5
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

C82FC:
	move.l	#$0024F200,d6
	moveq	#6,d5
	br	Asm_FPopperant

C8308:
	move.l	#$0024F200,d6
	moveq	#4,d5
	br	Asm_FPopperant

C8314:
	move.l	#$0024F200,d6
	moveq	#0,d5
	br	Asm_FPopperant

C8320:
	move.l	#$0024F200,d6
	moveq	#$71,d5
	br	Asm_FPopperant

C832C:
	move.l	#$0024F200,d6
	moveq	#$75,d5
	br	Asm_FPopperant

C8338:
	move.l	#$0024F200,d6
	moveq	#$72,d5
	br	Asm_FPopperant

C8344:
	move.l	#$0024F200,d6
	moveq	#$73,d5
	br	Asm_FPopperant

C8350:
	move.l	#$0016F240,d6
	br	CF48C

C835A:
	move.l	#$0017F240,d6
	br	CF48C

C8364:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CC45,d0
	beq	C839C
	cmp	#$CC00,d0
	beq	C83A6
	cmp	#$D400,d0
	beq.b	C8388
	cmp	#$C500,d0
	beq.b	C8392
	br	HandleMacroos

C8388:
	move.l	#$001DF240,d6
	br	CF48C

C8392:
	move.l	#$001CF240,d6
	br	CF48C

C839C:
	move.l	#$0018F240,d6
	br	CF48C

C83A6:
	move.l	#$0019F240,d6
	br	CF48C

C83B0:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C500,d0
	beq.b	C83C4
	cmp	#$D400,d0
	beq.b	C83CE
	br	HandleMacroos

C83C4:
	move.l	#$001AF240,d6
	br	CF48C

C83CE:
	move.l	#$001BF240,d6
	br	CF48C

C83D8:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C500,d0
	beq.b	C83E6
	br	HandleMacroos

C83E6:
	move.l	#$001EF240,d6
	br	CF48C

C83F0:
	move.l	#$001FF240,d6
	br	CF48C

C83FA:
	move.l	#$0010F240,d6
	br	CF48C

C8404:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D400,d0
	beq.b	C8422
	cmp	#$C500,d0
	beq.b	C8418
	br	HandleMacroos

C8418:
	move.l	#$000DF240,d6
	br	CF48C

C8422:
	move.l	#$000CF240,d6
	br	CF48C

C842C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D400,d0
	beq.b	C844A
	cmp	#$C500,d0
	beq.b	C8440
	br	HandleMacroos

C8440:
	move.l	#$000BF240,d6
	br	CF48C

C844A:
	move.l	#$000AF240,d6
	br	CF48C

C8454:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D100,d0
	beq.b	C8462
	br	HandleMacroos

C8462:
	move.l	#$0009F240,d6
	br	CF48C

C846C:
	move.l	#$0008F240,d6
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

C8494:
	move.l	#$0004F240,d6
	br	CF48C

C849E:
	move.l	#$0005F240,d6
	br	CF48C

C84A8:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D400,d0
	beq.b	C84C6
	cmp	#$C500,d0
	beq	C84D0
	cmp	#$CC00,d0
	beq	C84DA
	br	HandleMacroos

C84C6:
	move.l	#$0002F240,d6
	br	CF48C

C84D0:
	move.l	#$0003F240,d6
	br	CF48C

C84DA:
	move.l	#$0006F240,d6
	br	CF48C

C84E4:
	move.l	#$000EF240,d6
	br	CF48C

C84EE:
	move.l	#$0001F240,d6
	br	CF48C

C84F8:
	move.l	#$0000F240,d6
	br	CF48C

C8502:
	move.l	#$000FF240,d6
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

C8552:
	move.l	#$0026F200,d6
	moveq	#6,d5
	br	Asm_FPopperant

C855E:
	move.l	#$0026F200,d6
	moveq	#4,d5
	br	Asm_FPopperant

C856A:
	move.l	#$0026F200,d6
	moveq	#0,d5
	br	Asm_FPopperant

C8576:
	move.l	#$0026F200,d6
	moveq	#$71,d5
	br	Asm_FPopperant

C8582:
	move.l	#$0026F200,d6
	moveq	#$75,d5
	br	Asm_FPopperant

C858E:
	move.l	#$0026F200,d6
	moveq	#$72,d5
	br	Asm_FPopperant

C859A:
	move.l	#$0026F200,d6
	moveq	#$73,d5
	br	Asm_FPopperant

C85A6:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C500,d0
	beq.b	C85B4
	br	HandleMacroos

C85B4:
	move	#$F300,d6
	br	CF4C2

C85BC:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C54D,d0
	beq	C866A
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
	br	CF4C2

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

C862E:
	move.l	#$0025F200,d6
	moveq	#6,d5
	br	Asm_FPopperant

C863A:
	move.l	#$0025F200,d6
	moveq	#4,d5
	br	Asm_FPopperant

C8646:
	move.l	#$0025F200,d6
	moveq	#0,d5
	br	Asm_FPopperant

C8652:
	move.l	#$0025F200,d6
	moveq	#$71,d5
	br	Asm_FPopperant

C865E:
	move.l	#$0025F200,d6
	moveq	#$75,d5
	br	Asm_FPopperant

C866A:
	move.l	#$0025F200,d6
	moveq	#$72,d5
	br	Asm_FPopperant

C8676:
	move.l	#$0025F200,d6
	moveq	#$73,d5
	br	Asm_FPopperant

C8682:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C547,d0
	beq	C871A
	cmp	#$4547,d0
	beq.b	C86AC
	cmp	#$CF50,d0
	beq.b	C869E
	br	HandleMacroos

C869E:
	move.l	#$F2800000,d6
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

C86DE:
	move.l	#$001AF200,d6
	moveq	#6,d5
	br	CFB00

C86EA:
	move.l	#$001AF200,d6
	moveq	#4,d5
	br	CFB00

C86F6:
	move.l	#$001AF200,d6
	moveq	#0,d5
	br	CFB00

C8702:
	move.l	#$001AF200,d6
	moveq	#$71,d5
	br	CFB00

C870E:
	move.l	#$001AF200,d6
	moveq	#$75,d5
	br	CFB00

C871A:
	move.l	#$001AF200,d6
	moveq	#$72,d5
	br	CFB00

C8726:
	move.l	#$001AF200,d6
	moveq	#$73,d5
	br	CFB00

Asm_FM:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CF44,d0	fmOD
	beq	C8944
	cmp	#$4F44,d0	fmOD
	beq	C88D6
	cmp	#$4F56,d0	fmOV
	beq	Asm_FMOV
	cmp	#$D54C,d0	fmUL
	beq.b	C87CC
	cmp	#$554C,d0	fmUL
	beq.b	C875E
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

C8790:
	move.l	#$0023F200,d6
	moveq	#6,d5
	br	Asm_FPopperant

C879C:
	move.l	#$0023F200,d6
	moveq	#4,d5
	br	Asm_FPopperant

C87A8:
	move.l	#$0023F200,d6
	moveq	#0,d5
	br	Asm_FPopperant

C87B4:
	move.l	#$0023F200,d6
	moveq	#$71,d5
	br	Asm_FPopperant

C87C0:
	move.l	#$0023F200,d6
	moveq	#$75,d5
	br	Asm_FPopperant

C87CC:
	move.l	#$0023F200,d6
	moveq	#$72,d5
	br	Asm_FPopperant

C87D8:
	move.l	#$0023F200,d6
	moveq	#$73,d5
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
	beq.b	C880C
	cmp	#$C54D,d0	;fmovem
	beq.b	asm_fmoveM
	br	HandleMacroos

C880C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C058,d0
	bne	ERROR_IllegalSize
asm_fmoveM:
	move.l	#$8000F200,d6
	br	CF504

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
	br	CF9F6

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
	move.l	#$0000F200,d6
	moveq	#6,d5
	br	Asmbl_FinishFmove

asm_fmovew:
	move.l	#$0000F200,d6
	move	#$0044,d5
	br	Asmbl_FinishFmove

asm_fmovel:
	move.l	#$0000F200,d6
	move	#$0080,d5
	br	Asmbl_FinishFmove

asm_fmoves:
	move.l	#$0000F200,d6
	moveq	#$71,d5
	br	Asmbl_FinishFmove

asm_fmoved:
	move.l	#$0000F200,d6
	moveq	#$75,d5
	br	Asmbl_FinishFmove

asm_fmovex:
	move.l	#$0000F200,d6
	moveq	#$72,d5
	br	Asmbl_FinishFmove

asm_fmovep:
	move.l	#$0000F200,d6
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

C8908:
	move.l	#$0021F200,d6
	moveq	#6,d5
	br	Asm_FPopperant

C8914:
	move.l	#$0021F200,d6
	moveq	#4,d5
	br	Asm_FPopperant

C8920:
	move.l	#$0021F200,d6
	moveq	#0,d5
	br	Asm_FPopperant

C892C:
	move.l	#$0021F200,d6
	moveq	#$71,d5
	br	Asm_FPopperant

C8938:
	move.l	#$0021F200,d6
	moveq	#$75,d5
	br	Asm_FPopperant

C8944:
	move.l	#$0021F200,d6
	moveq	#$72,d5
	br	Asm_FPopperant

C8950:
	move.l	#$0021F200,d6
	moveq	#$73,d5
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
	beq	C8A42
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

C89EE:
	move.l	#$0006F200,d6
	moveq	#6,d5
	br	CFB00

C89FA:
	move.l	#$0006F200,d6
	moveq	#4,d5
	br	CFB00

C8A06:
	move.l	#$0006F200,d6
	moveq	#0,d5
	br	CFB00

C8A12:
	move.l	#$0006F200,d6
	moveq	#$71,d5
	br	CFB00

C8A1E:
	move.l	#$0006F200,d6
	moveq	#$75,d5
	br	CFB00

C8A2A:
	move.l	#$0006F200,d6
	moveq	#$72,d5
	br	CFB00

C8A36:
	move.l	#$0006F200,d6
	moveq	#$73,d5
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

C8A74:
	move.l	#$0014F200,d6
	moveq	#6,d5
	br	CFB00

C8A80:
	move.l	#$0014F200,d6
	moveq	#4,d5
	br	CFB00

C8A8C:
	move.l	#$0014F200,d6
	moveq	#0,d5
	br	CFB00

C8A98:
	move.l	#$0014F200,d6
	moveq	#$71,d5
	br	CFB00

C8AA4:
	move.l	#$0014F200,d6
	moveq	#$75,d5
	br	CFB00

C8AB0:
	move.l	#$0014F200,d6
	moveq	#$72,d5
	br	CFB00

C8ABC:
	move.l	#$0014F200,d6
	moveq	#$73,d5
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

C8AFA:
	move.l	#$0016F200,d6
	moveq	#6,d5
	br	CFB00

C8B06:
	move.l	#$0016F200,d6
	moveq	#4,d5
	br	CFB00

C8B12:
	move.l	#$0016F200,d6
	moveq	#0,d5
	br	CFB00

C8B1E:
	move.l	#$0016F200,d6
	moveq	#$71,d5
	br	CFB00

C8B2A:
	move.l	#$0016F200,d6
	moveq	#$75,d5
	br	CFB00

C8B36:
	move.l	#$0016F200,d6
	moveq	#$72,d5
	br	CFB00

C8B42:
	move.l	#$0016F200,d6
	moveq	#$73,d5
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

C8B80:
	move.l	#$0015F200,d6
	moveq	#6,d5
	br	CFB00

C8B8C:
	move.l	#$0015F200,d6
	moveq	#4,d5
	br	CFB00

C8B98:
	move.l	#$0015F200,d6
	moveq	#0,d5
	br	CFB00

C8BA4:
	move.l	#$0015F200,d6
	moveq	#$71,d5
	br	CFB00

C8BB0:
	move.l	#$0015F200,d6
	moveq	#$75,d5
	br	CFB00

C8BBC:
	move.l	#$0015F200,d6
	moveq	#$72,d5
	br	CFB00

C8BC8:
	move.l	#$0015F200,d6
	moveq	#$73,d5
	br	CFB00

C8BD4:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CE54,d0
	beq	C8C68
	cmp	#$4E54,d0
	beq.b	C8BEA
	br	HandleMacroos

C8BEA:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D25A,d0
	beq	C8CEE
	cmp	#$525A,d0
	beq	C8C80
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

C8C2C:
	move.l	#$0001F200,d6
	moveq	#6,d5
	br	CFB00

C8C38:
	move.l	#$0001F200,d6
	moveq	#4,d5
	br	CFB00

C8C44:
	move.l	#$0001F200,d6
	moveq	#0,d5
	br	CFB00

C8C50:
	move.l	#$0001F200,d6
	moveq	#$71,d5
	br	CFB00

C8C5C:
	move.l	#$0001F200,d6
	moveq	#$75,d5
	br	CFB00

C8C68:
	move.l	#$0001F200,d6
	moveq	#$72,d5
	br	CFB00

C8C74:
	move.l	#$0001F200,d6
	moveq	#$73,d5
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

C8CB2:
	move.l	#$0003F200,d6
	moveq	#6,d5
	br	CFB00

C8CBE:
	move.l	#$0003F200,d6
	moveq	#4,d5
	br	CFB00

C8CCA:
	move.l	#$0003F200,d6
	moveq	#0,d5
	br	CFB00

C8CD6:
	move.l	#$0003F200,d6
	moveq	#$71,d5
	br	CFB00

C8CE2:
	move.l	#$0003F200,d6
	moveq	#$75,d5
	br	CFB00

C8CEE:
	move.l	#$0003F200,d6
	moveq	#$72,d5
	br	CFB00

C8CFA:
	move.l	#$0003F200,d6
	moveq	#$73,d5
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
	beq	C8DC4
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

C8D70:
	move.l	#$001FF200,d6
	moveq	#6,d5
	br	Asm_FPopperant

C8D7C:
	move.l	#$001FF200,d6
	moveq	#4,d5
	br	Asm_FPopperant

C8D88:
	move.l	#$001FF200,d6
	moveq	#0,d5
	br	Asm_FPopperant

C8D94:
	move.l	#$001FF200,d6
	moveq	#$71,d5
	br	Asm_FPopperant

C8DA0:
	move.l	#$001FF200,d6
	moveq	#$75,d5
	br	Asm_FPopperant

C8DAC:
	move.l	#$001FF200,d6
	moveq	#$72,d5
	br	Asm_FPopperant

C8DB8:
	move.l	#$001FF200,d6
	moveq	#$73,d5
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

C8E0A:
	move.l	#$001EF200,d6
	moveq	#6,d5
	br	Asm_FPopperant

C8E16:
	move.l	#$001EF200,d6
	moveq	#4,d5
	br	Asm_FPopperant

C8E22:
	move.l	#$001EF200,d6
	moveq	#0,d5
	br	Asm_FPopperant

C8E2E:
	move.l	#$001EF200,d6
	moveq	#$71,d5
	br	Asm_FPopperant

C8E3A:
	move.l	#$001EF200,d6
	moveq	#$75,d5
	br	Asm_FPopperant

C8E46:
	move.l	#$001EF200,d6
	moveq	#$72,d5
	br	Asm_FPopperant

C8E52:
	move.l	#$001EF200,d6
	moveq	#$73,d5
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
	beq	C8F24
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

C8ED0:
	move.l	#$0008F200,d6
	moveq	#6,d5
	br	CFB00

C8EDC:
	move.l	#$0008F200,d6
	moveq	#4,d5
	br	CFB00

C8EE8:
	move.l	#$0008F200,d6
	moveq	#0,d5
	br	CFB00

C8EF4:
	move.l	#$0008F200,d6
	moveq	#$71,d5
	br	CFB00

C8F00:
	move.l	#$0008F200,d6
	moveq	#$75,d5
	br	CFB00

C8F0C:
	move.l	#$0008F200,d6
	moveq	#$72,d5
	br	CFB00

C8F18:
	move.l	#$0008F200,d6
	moveq	#$73,d5
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

C8F56:
	move.l	#$0010F200,d6
	moveq	#6,d5
	br	CFB00

C8F62:
	move.l	#$0010F200,d6
	moveq	#4,d5
	br	CFB00

C8F6E:
	move.l	#$0010F200,d6
	moveq	#0,d5
	br	CFB00

C8F7A:
	move.l	#$0010F200,d6
	moveq	#$71,d5
	br	CFB00

C8F86:
	move.l	#$0010F200,d6
	moveq	#$75,d5
	br	CFB00

C8F92:
	move.l	#$0010F200,d6
	moveq	#$72,d5
	br	CFB00

C8F9E:
	move.l	#$0010F200,d6
	moveq	#$73,d5
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
	beq	C9098
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
	move.l	#$0020F200,d6
	moveq	#6,d5
	br	Asm_FPopperant

Asm_FDIVW:
	move.l	#$0020F200,d6
	moveq	#4,d5
	br	Asm_FPopperant

Asm_FDIVL:
	move.l	#$0020F200,d6
	moveq	#0,d5
	br	Asm_FPopperant

C905E:
	move.l	#$0020F200,d6
	moveq	#$71,d5
	br	Asm_FPopperant

C906A:
	move.l	#$0020F200,d6
	moveq	#$75,d5
	br	Asm_FPopperant

C9076:
	move.l	#$0020F200,d6
	moveq	#$72,d5
	br	Asm_FPopperant

C9082:
	move.l	#$0020F200,d6
	moveq	#$73,d5
	br	Asm_FPopperant

C908E:
	move.l	#$0000F248,d6
	br	CFAD8

C9098:
	move.l	#$000FF248,d6
	br	CFAD8

C90A2:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D100,d0
	beq.b	C90B0
	br	HandleMacroos

C90B0:
	move.l	#$0001F248,d6
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

C90E6:
	move.l	#$0002F248,d6
	br	CFAD8

C90F0:
	move.l	#$0003F248,d6
	br	CFAD8

C90FA:
	move.l	#$0004F248,d6
	br	CFAD8

C9104:
	move.l	#$0005F248,d6
	br	CFAD8

C910E:
	move.l	#$0006F248,d6
	br	CFAD8

C9118:
	move.l	#$0007F248,d6
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

C914E:
	move.l	#$0008F248,d6
	br	CFAD8

C9158:
	move.l	#$0009F248,d6
	br	CFAD8

C9162:
	move.l	#$000AF248,d6
	br	CFAD8

C916C:
	move.l	#$000BF248,d6
	br	CFAD8

C9176:
	move.l	#$000CF248,d6
	br	CFAD8

C9180:
	move.l	#$000DF248,d6
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

C91BC:
	move.l	#$0019F248,d6
	br	CFAD8

C91C6:
	move.l	#$001AF248,d6
	br	CFAD8

C91D0:
	move.l	#$001BF248,d6
	br	CFAD8

C91DA:
	move.l	#$001CF248,d6
	br	CFAD8

C91E4:
	move.l	#$001DF248,d6
	br	CFAD8

C91EE:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C500,d0
	beq.b	C91FC
	br	HandleMacroos

C91FC:
	move.l	#$0018F248,d6
	br	CFAD8

C9206:
	move.l	#$000EF248,d6
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

C9230:
	move.l	#$0010F248,d6
	br	CFAD8

C923A:
	move.l	#$001FF248,d6
	br	CFAD8

C9244:
	move.l	#$0011F248,d6
	br	CFAD8

C924E:
	move.l	#$001EF248,d6
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
	beq	C9298
	br	HandleMacroos

C927A:
	move.l	#$0012F248,d6
	br	CFAD8

C9284:
	move.l	#$0013F248,d6
	br	CFAD8

C928E:
	move.l	#$0016F248,d6
	br	CFAD8

C9298:
	move.l	#$0017F248,d6
	br	CFAD8

C92A2:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D400,d0
	beq.b	C92B6
	cmp	#$C500,d0
	beq.b	C92C0
	br	HandleMacroos

C92B6:
	move.l	#$0014F248,d6
	br	CFAD8

C92C0:
	move.l	#$0015F248,d6
	br	CFAD8

C92CA:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CD50,d0
	beq	C947A
	cmp	#$4D50,d0
	beq	C940C
	cmp	#$CF53,d0
	beq	C936E
	cmp	#$4F53,d0
	beq.b	C92F0
	br	HandleMacroos

C92F0:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$4840,d0
	beq	C9386
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

C9332:
	move.l	#$001DF200,d6
	moveq	#6,d5
	br	CFB00

C933E:
	move.l	#$001DF200,d6
	moveq	#4,d5
	br	CFB00

C934A:
	move.l	#$001DF200,d6
	moveq	#0,d5
	br	CFB00

C9356:
	move.l	#$001DF200,d6
	moveq	#$71,d5
	br	CFB00

C9362:
	move.l	#$001DF200,d6
	moveq	#$75,d5
	br	CFB00

C936E:
	move.l	#$001DF200,d6
	moveq	#$72,d5
	br	CFB00

C937A:
	move.l	#$001DF200,d6
	moveq	#$73,d5
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

C93B8:
	move.l	#$0019F200,d6
	moveq	#6,d5
	br	CFB00

C93C4:
	move.l	#$0019F200,d6
	moveq	#4,d5
	br	CFB00

C93D0:
	move.l	#$0019F200,d6
	moveq	#0,d5
	br	CFB00

C93DC:
	move.l	#$0019F200,d6
	moveq	#$71,d5
	br	CFB00

C93E8:
	move.l	#$0019F200,d6
	moveq	#$75,d5
	br	CFB00

C93F4:
	move.l	#$0019F200,d6
	moveq	#$72,d5
	br	CFB00

C9400:
	move.l	#$0019F200,d6
	moveq	#$73,d5
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

C943E:
	move.l	#$0038F200,d6
	moveq	#6,d5
	br	Asm_FPopperant

C944A:
	move.l	#$0038F200,d6
	moveq	#4,d5
	br	Asm_FPopperant

C9456:
	move.l	#$0038F200,d6
	moveq	#0,d5
	br	Asm_FPopperant

C9462:
	move.l	#$0038F200,d6
	moveq	#$71,d5
	br	Asm_FPopperant

C946E:
	move.l	#$0038F200,d6
	moveq	#$75,d5
	br	Asm_FPopperant

C947A:
	move.l	#$0038F200,d6
	moveq	#$72,d5
	br	Asm_FPopperant

C9486:
	move.l	#$0038F200,d6
	moveq	#$73,d5
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

C95C0:
	move	#$F295,d6
	br	C10682

C95C8:
	move	#$F2D5,d6
	br	asmbl_BraL

C95D0:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C95E4
	cmp	#$C04C,d0
	beq.b	C95EC
	br	ERROR_IllegalSize

C95E4:
	move	#$F294,d6
	br	C10682

C95EC:
	move	#$F2D4,d6
	br	asmbl_BraL

C95F4:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C9608
	cmp	#$C04C,d0
	beq.b	C9610
	br	ERROR_IllegalSize

C9608:
	move	#$F293,d6
	br	C10682

C9610:
	move	#$F2D3,d6
	br	asmbl_BraL

C9618:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C962C
	cmp	#$C04C,d0
	beq.b	C9634
	br	ERROR_IllegalSize

C962C:
	move	#$F292,d6
	br	C10682

C9634:
	move	#$F2D2,d6
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

C9664:
	move	#$F291,d6
	br	C10682

C966C:
	move	#$F2D1,d6
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

C9694:
	move	#$F296,d6
	br	C10682

C969C:
	move	#$F2D6,d6
	br	asmbl_BraL

C96A4:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C96B8
	cmp	#$CC00,d0
	beq.b	C96C0
	br	ERROR_IllegalSize

C96B8:
	move	#$F297,d6
	br	C10682

C96C0:
	move	#$F2D7,d6
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

C971A:
	move	#$F29D,d6
	br	C10682

C9722:
	move	#$F2DD,d6
	br	asmbl_BraL

C972A:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C973E
	cmp	#$CC00,d0
	beq.b	C9746
	br	ERROR_IllegalSize

C973E:
	move	#$F29C,d6
	br	C10682

C9746:
	move	#$F2DC,d6
	br	asmbl_BraL

C974E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C9762
	cmp	#$C04C,d0
	beq.b	C976A
	br	ERROR_IllegalSize

C9762:
	move	#$F298,d6
	br	C10682

C976A:
	move	#$F2D8,d6
	br	asmbl_BraL

C9772:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C9786
	cmp	#$CC00,d0
	beq.b	C978E
	br	ERROR_IllegalSize

C9786:
	move	#$F299,d6
	br	C10682

C978E:
	move	#$F2D9,d6
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

C97CA:
	move	#$F29A,d6
	br	C10682

C97D2:
	move	#$F2DA,d6
	br	asmbl_BraL

C97DA:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C97EE
	cmp	#$CC00,d0
	beq.b	C97F6
	br	ERROR_IllegalSize

C97EE:
	move	#$F29B,d6
	br	C10682

C97F6:
	move	#$F2DB,d6
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

C9826:
	move	#$F29E,d6
	br	C10682

C982E:
	move	#$F2DE,d6
	br	asmbl_BraL

C9836:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C984A
	cmp	#$C04C,d0
	beq.b	C9852
	br	ERROR_IllegalSize

C984A:
	move	#$F29F,d6
	br	C10682

C9852:
	move	#$F2DF,d6
	br	asmbl_BraL

C985A:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C986E
	cmp	#$C04C,d0
	beq.b	C9876
	br	HandleMacroos

C986E:
	move	#$F290,d6
	br	C10682

C9876:
	move	#$F2D0,d6
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

C98B2:
	move	#$F28D,d6
	br	C10682

C98BA:
	move	#$F2CD,d6
	br	asmbl_BraL

C98C2:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C98D6
	cmp	#$CC00,d0
	beq.b	C98DE
	br	HandleMacroos

C98D6:
	move	#$F28C,d6
	br	C10682

C98DE:
	move	#$F2CC,d6
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

C991A:
	move	#$F28B,d6
	br	C10682

C9922:
	move	#$F2CB,d6
	br	asmbl_BraL

C992A:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C993E
	cmp	#$CC00,d0
	beq.b	C9946
	br	HandleMacroos

C993E:
	move	#$F28A,d6
	br	C10682

C9946:
	move	#$F2CA,d6
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

C9976:
	move	#$F289,d6
	br	C10682

C997E:
	move	#$F2C9,d6
	br	asmbl_BraL

C9986:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C999A
	cmp	#$C04C,d0
	beq.b	C99A2
	br	HandleMacroos

C999A:
	move	#$F288,d6
	br	C10682

C99A2:
	move	#$F2C8,d6
	br	asmbl_BraL

C99AA:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C99BE
	cmp	#$C04C,d0
	beq.b	C99C6
	br	HandleMacroos

C99BE:
	move	#$F287,d6
	br	C10682

C99C6:
	move	#$F2C7,d6
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

C9A02:
	move	#$F284,d6
	br	C10682

C9A0A:
	move	#$F2C4,d6
	br	asmbl_BraL

C9A12:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C9A26
	cmp	#$CC00,d0
	beq.b	C9A2E
	br	HandleMacroos

C9A26:
	move	#$F285,d6
	br	C10682

C9A2E:
	move	#$F2C5,d6
	br	asmbl_BraL

C9A36:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D400,d0
	beq.b	C9A7C
	cmp	#$C500,d0
	beq	C9AA0
	cmp	#$CC00,d0
	beq	C9AC4
	cmp	#$5440,d0
	beq.b	C9A68
	cmp	#$4540,d0
	beq.b	C9A8C
	cmp	#$4C40,d0
	beq	C9AB0
	br	HandleMacroos

C9A68:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C9A7C
	cmp	#$CC00,d0
	beq.b	C9A84
	br	HandleMacroos

C9A7C:
	move	#$F282,d6
	br	C10682

C9A84:
	move	#$F2C2,d6
	br	asmbl_BraL

C9A8C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C9AA0
	cmp	#$CC00,d0
	beq.b	C9AA8
	br	HandleMacroos

C9AA0:
	move	#$F283,d6
	br	C10682

C9AA8:
	move	#$F2C3,d6
	br	asmbl_BraL

C9AB0:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C9AC4
	cmp	#$CC00,d0
	beq.b	C9ACC
	br	HandleMacroos

C9AC4:
	move	#$F286,d6
	br	C10682

C9ACC:
	move	#$F2C6,d6
	br	asmbl_BraL

C9AD4:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C9AE8
	cmp	#$C04C,d0
	beq.b	C9AF0
	br	HandleMacroos

C9AE8:
	move	#$F28E,d6
	br	C10682

C9AF0:
	move	#$F2CE,d6
	br	asmbl_BraL

C9AF8:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	C9B0C
	cmp	#$C04C,d0
	beq.b	C9B14
	br	HandleMacroos

C9B0C:
	move	#$F281,d6
	br	C10682

C9B14:
	move	#$F2C1,d6
	br	asmbl_BraL

C9B1C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C9B30
	cmp	#$CC00,d0
	beq.b	C9B38
	br	HandleMacroos

C9B30:
	move	#$F280,d6
	br	C10682

C9B38:
	move	#$F2C0,d6
	br	asmbl_BraL

C9B40:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	C9B54
	cmp	#$CC00,d0
	beq.b	C9B5C
	br	HandleMacroos

C9B54:
	move	#$F28F,d6
	br	C10682

C9B5C:
	move	#$F2CF,d6
	br	asmbl_BraL

C9B64:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C94C,d0
	beq	CE616
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
	beq	C9C58
	cmp	#$CE48,d0
	beq	C9C40
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
	beq	C9C4C
	br	HandleMacroos

C9C04:
	move.l	#$000DF200,d6
	moveq	#6,d5
	br	CFB00

C9C10:
	move.l	#$000DF200,d6
	moveq	#4,d5
	br	CFB00

C9C1C:
	move.l	#$000DF200,d6
	moveq	#0,d5
	br	CFB00

C9C28:
	move.l	#$000DF200,d6
	moveq	#$71,d5
	br	CFB00

C9C34:
	move.l	#$000DF200,d6
	moveq	#$75,d5
	br	CFB00

C9C40:
	move.l	#$000DF200,d6
	moveq	#$72,d5
	br	CFB00

C9C4C:
	move.l	#$000DF200,d6
	moveq	#$73,d5
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
	beq	C9CD4
	br	ERROR_Illegalfloating

C9C8C:
	move.l	#$000AF200,d6
	moveq	#6,d5
	br	CFB00

C9C98:
	move.l	#$000AF200,d6
	moveq	#4,d5
	br	CFB00

C9CA4:
	move.l	#$000AF200,d6
	moveq	#0,d5
	br	CFB00

C9CB0:
	move.l	#$000AF200,d6
	moveq	#$71,d5
	br	CFB00

C9CBC:
	move.l	#$000AF200,d6
	moveq	#$75,d5
	br	CFB00

C9CC8:
	move.l	#$000AF200,d6
	moveq	#$72,d5
	br	CFB00

C9CD4:
	move.l	#$000AF200,d6
	moveq	#$73,d5
	br	CFB00

C9CE0:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CE00,d0
	beq	C9D66
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
	beq	C9D72
	br	ERROR_Illegalfloating

C9D2A:
	move.l	#$000CF200,d6
	moveq	#6,d5
	br	CFB00

C9D36:
	move.l	#$000CF200,d6
	moveq	#4,d5
	br	CFB00

C9D42:
	move.l	#$000CF200,d6
	moveq	#0,d5
	br	CFB00

C9D4E:
	move.l	#$000CF200,d6
	moveq	#$71,d5
	br	CFB00

C9D5A:
	move.l	#$000CF200,d6
	moveq	#$75,d5
	br	CFB00

C9D66:
	move.l	#$000CF200,d6
	moveq	#$72,d5
	br	CFB00

C9D72:
	move.l	#$000CF200,d6
	moveq	#$73,d5
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

C9DB0:
	move.l	#$0022F200,d6
	moveq	#6,d5
	br	Asm_FPopperant

C9DBC:
	move.l	#$0022F200,d6
	moveq	#4,d5
	br	Asm_FPopperant

C9DC8:
	move.l	#$0022F200,d6
	moveq	#0,d5
	br	Asm_FPopperant

C9DD4:
	move.l	#$0022F200,d6
	moveq	#$71,d5
	br	Asm_FPopperant

C9DE0:
	move.l	#$0022F200,d6
	moveq	#$75,d5
	br	Asm_FPopperant

C9DEC:
	move.l	#$0022F200,d6
	moveq	#$72,d5
	br	Asm_FPopperant

C9DF8:
	move.l	#$0022F200,d6
	moveq	#$73,d5
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

C9E4A:
	move.l	#$001CF200,d6
	moveq	#6,d5
	br	CFB00

C9E56:
	move.l	#$001CF200,d6
	moveq	#4,d5
	br	CFB00

C9E62:
	move.l	#$001CF200,d6
	moveq	#0,d5
	br	CFB00

C9E6E:
	move.l	#$001CF200,d6
	moveq	#$71,d5
	br	CFB00

C9E7A:
	move.l	#$001CF200,d6
	moveq	#$75,d5
	br	CFB00

C9E86:
	move.l	#$001CF200,d6
	moveq	#$72,d5
	br	CFB00

C9E92:
	move.l	#$001CF200,d6
	moveq	#$73,d5
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

C9ED0:
	move.l	#$0018F200,d6
	moveq	#6,d5
	br	CFB00

C9EDC:
	move.l	#$0018F200,d6
	moveq	#4,d5
	br	CFB00

C9EE8:
	move.l	#$0018F200,d6
	moveq	#0,d5
	br	CFB00

C9EF4:
	move.l	#$0018F200,d6
	moveq	#$71,d5
	br	CFB00

C9F00:
	move.l	#$0018F200,d6
	moveq	#$75,d5
	br	CFB00

C9F0C:
	move.l	#$0018F200,d6
	moveq	#$72,d5
	br	CFB00

C9F18:
	move.l	#$0018F200,d6
	moveq	#$73,d5
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
	cmp.w	#'HA',d0	;HAlt
	beq.s	asm_HAlt
	br	HandleMacroos

asm_HAlt:
	move.w	(a3)+,d0
	and	d4,d0
	cmp.w	#"LT"!$8000,d0
	beq.s	asm_HALT_done
	br	HandleMacroos

asm_HALT_done:
	moveq	#PB_060,d0		;060
	bsr	Processor_warning

	move	#$4ACC,d6	;HALT
	move	#$8040,d5	;?!?!
	br	Asm_InsertinstrA5

;************* I *************************

AsmI:
	cmp	#"IF"+$8000,d0
	beq	CE4A4
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
	beq	CD880
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
	br	CE66E

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
	cmp	#'IN',d0
	beq.b	check_INCLIN
	br	HandleMacroos

check_INCLUD:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C500,d0	;includE
	beq	Asm_Include
	br	HandleMacroos

check_INCLIN:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CB00,d0	;inclinK
	beq	Asm_IncLink
	br	HandleMacroos

CA032:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C952,d0
	beq	CE61A
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
	beq	CE4A4
	cmp	#$CE44,d0	;IFND
	beq	CE54A
	cmp	#$CE43,d0	;IFNC
	beq	CE528
	cmp	#$CE42,d0	;IFNB
	beq	CE55C
	cmp	#$CC54,d0	;IFLT
	beq	CE4D4
	cmp	#$CC45,d0	;IFLE
	beq	CE4E4
	cmp	#$C754,d0	;IFGT
	beq	CE4B4
	cmp	#$C745,d0	;IFGE
	beq	CE4C4
	cmp	#$C551,d0	;IFGQ
	beq	CE480
	cmp	#$C400,d0	;IFD
	beq	CE544
	cmp	#$C300,d0	;IFC
	beq	CE520
	cmp	#$C200,d0	;IFB
	beq	CE550
	cmp	#$9200,d0	;IF0
	beq	CE49A
	cmp	#$9100,d0	;IF1
	beq	CE490
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
	cmp.w	#'LP',d0	;LPstop
	beq.s	asm_lpstop1
	br	HandleMacroos

asm_lpstop1:
	move	(a3)+,d0
	and	d4,d0
	cmp	#'ST',d0	;lpSTop
	bne	HandleMacroos
	move	(a3)+,d0
	and	d4,d0
	cmp	#'OP'!$8000,d0	;lpstOP
	beq	asm_lpstop2
	br	HandleMacroos

asm_lpstop2:
	moveq	#PB_060,d0
	bsr	Processor_warning

	move.l	#$F80001C0,d6	;LPSTOP
	move	#$0080,d5
;	br	Asmbl_CMDLEA
	bra	asm_LPSTOP_opp

CA1A2:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C54E,d0
	beq	CD81E
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
	br	C10798

CA250:
	move	#$E3C8,d6
	moveq	#0,d5
	br	C10798

CA25A:
	move	#$E3C8,d6
	moveq	#$40,d5
	br	C10798

CA264:
	move	#$E3C8,d6
	move	#$0080,d5
	br	C10798

CA270:
	move	#$E2C8,d6
	move	#$8040,d5
	br	C10798

CA27C:
	move	#$E2C8,d6
	moveq	#0,d5
	br	C10798

CA286:
	move	#$E2C8,d6
	moveq	#$40,d5
	br	C10798

CA290:
	move	#$E2C8,d6
	move	#$0080,d5
	br	C10798

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
	beq	CD812
	br	HandleMacroos

CA2BE:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq.b	CA2FC
	cmp	#$C04C,d0
	beq	CA306
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
	br	C1084A

CA306:
	moveq	#2,d0
	bsr	Processor_warning
	move	#$4808,d6
	move	#$0080,d5
	br	C1084A

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
	beq	CD920
	br	HandleMacroos

AsmM:
;******* TRYOUT SPEED IMPROVEMENT *******
	swap	d0
	move.w	(a3)+,d0
	and	d4,d0
	cmp.l	#"MOVE",d0
	beq.b   Asm_its_MOVE_somthing
	cmp.l	#"MOVE"|$8000,d0
	beq     Asm_its_MOVE

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
	cmp	#"XI",d0	'XI
	beq.b	CA36E
	br	HandleMacroos

CA36E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"T"<<(1*8)+$8000,d0
	beq	CE44C
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
	beq	CA4E8
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
;	moveq	#PB_040,d0		;040+
;	bsr	Processor_warning
	move.l	#$8000F600,d6
	moveq	#0,d5
	br	Asm_Move16Afronden

CA416:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"L"<<(1*8)+$8000,d0
	beq.b	CA444
	cmp	#"W"<<(1*8)+$8000,d0
	beq.b	CA430
	cmp	#"B"<<(1*8)+$8000,d0
	beq.b	CA43A
	br	HandleMacroos

CA430:
	move	#$0E40,d6
	moveq	#0,d5
	br	CFDD6

CA43A:
	move	#$0E00,d6
	moveq	#0,d5
	br	CFDD6

CA444:
	move	#$0E80,d6
	moveq	#0,d5
	br	CFDD6

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
	br	CEC62

CA480:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq	CA4A0
	cmp	#$CC00,d0
	beq	CA4AA
	cmp	#$C200,d0
	beq	ERROR_IllegalSize
	br	HandleMacroos

CA4A0:
	move	#$0108,d6
	moveq	#$40,d5
	br	CEC0E

CA4AA:
	move	#$0148,d6
	move	#$0080,d5
	br	CEC0E

CA4B6:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	CA4D2
	cmp	#$CC00,d0
	beq.b	CA4DC
	cmp	#$C200,d0
	beq	ERROR_IllegalSize
	br	HandleMacroos

CA4D2:
	move	#$4880,d6
	moveq	#$40,d5
	br	CECD0

CA4DC:
	move	#$48C0,d6
	move	#$0080,d5
	br	CECD0

CA4E8:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	CA52E
	cmp	#$CC00,d0
	beq.b	CA538
	cmp	#$C200,d0
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
	move	#$7000,(W2FCDA-DT,a4)
	lea	(C1051C).l,a0
	move.l	a0,(L2FCD6-DT,a4)
	br	Asmbl_CmdMove

CA52E:
	moveq	#$40,d6
	move	#$0028,d5
	br	C103FA

CA538:
	moveq	#$40,d6
	move	#$0080,d5
	br	C103FA

CA542:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$4352,d0
	beq.b	CA566
	cmp	#$534B,d0
	beq.b	CA556
	br	HandleMacroos

CA556:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$9200,d0
	beq	CD888
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

CA5C8:
	move	#$4C00,d6
	move	#$0084,d5
	br	Asm_ImmOpperantLong

CA5D4:
	move	#$C1C0,d6
	moveq	#$40,d5
	br	Asm_ImmOpperantWord

CA5DE:
	move	#$4C00,d6
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
	beq	CD818
	br	HandleMacroos

CA632:
	move	#$4E71,d6
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
	beq	CD808
	br	HandleMacroos

CA668:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"ST"+$8000,d0
	beq	CD818
	br	HandleMacroos

CA678:
	move	#$4600,d6
	moveq	#0,d5
	br	ASSEM_CMDCLRNOTTST

CA682:
	move	#$4640,d6
	moveq	#$40,d5
	br	ASSEM_CMDCLRNOTTST

CA68C:
	move	#$4680,d6
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

CA6EC:
	move	#$4400,d6
	moveq	#0,d5
	br	ASSEM_CMDCLRNOTTST

CA6F6:
	move	#$4440,d6
	moveq	#$40,d5
	br	ASSEM_CMDCLRNOTTST

CA700:
	move	#$4480,d6
	move	#$0080,d5
	br	ASSEM_CMDCLRNOTTST

CA70C:
	move	#$4000,d6
	moveq	#0,d5
	br	ASSEM_CMDCLRNOTTST

CA716:
	move	#$4040,d6
	moveq	#$40,d5
	br	ASSEM_CMDCLRNOTTST

CA720:
	move	#$4080,d6
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

CA75E:
	move	#$4800,d6
	moveq	#0,d5
	br	C108B6

CondAsmTab2:
	dc.w	_HandleMacroos-CondAsmTab2	;@
	dc.w	_HandleMacroos-CondAsmTab2	;A
	dc.w	_HandleMacroos-CondAsmTab2	;B
	dc.w	_HandleMacroos-CondAsmTab2	;C
	dc.w	_HandleMacroos-CondAsmTab2	;D
	dc.w	CondAsmE-CondAsmTab2		;E
	dc.w	_HandleMacroos-CondAsmTab2	;F
	dc.w	_HandleMacroos-CondAsmTab2	;G
	dc.w	_HandleMacroos-CondAsmTab2	;H
	dc.w	CondAsmI-CondAsmTab2		;I
	dc.w	_HandleMacroos-CondAsmTab2	;J
	dc.w	_HandleMacroos-CondAsmTab2	;K
	dc.w	_HandleMacroos-CondAsmTab2	;L
	dc.w	CondAsmM-CondAsmTab2		;M
	dc.w	_HandleMacroos-CondAsmTab2	;N
	dc.w	_HandleMacroos-CondAsmTab2	;O
	dc.w	_HandleMacroos-CondAsmTab2	;P
	dc.w	_HandleMacroos-CondAsmTab2	;Q
	dc.w	_HandleMacroos-CondAsmTab2	;R
	dc.w	_HandleMacroos-CondAsmTab2	;S
	dc.w	_HandleMacroos-CondAsmTab2	;T
	dc.w	_HandleMacroos-CondAsmTab2	;U
	dc.w	_HandleMacroos-CondAsmTab2	;V
	dc.w	_HandleMacroos-CondAsmTab2	;W
	dc.w	_HandleMacroos-CondAsmTab2	;X
	dc.w	_HandleMacroos-CondAsmTab2	;Y
	dc.w	_HandleMacroos-CondAsmTab2	;Z
	dc.w	_HandleMacroos-CondAsmTab2	;[

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
	beq	CD952
	br	HandleMacroos

CA7CE:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"FS",d0
	beq.b	CA7E4
	cmp	#"S"<<(1*8)+$8000,d0
	beq	CE74A
	br	HandleMacroos

CA7E4:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"ET"+$8000,d0
	beq	CE74A
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
	beq	CD8FA
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

CA83C:
	move	#$8001,d6
	moveq	#0,d5
	br	CEAB8

CA846:
	move	#$8001,d6
	moveq	#$40,d5
	br	CEAB8

CA850:
	move	#$8001,d6
	move	#$0080,d5
	br	CEAB8

AsmP:
	cmp	#'PE',d0
	beq	CB784
	cmp	#'PM',d0
	beq.w	AsmP_PM
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
	beq	asm_pulse1
	br	HandleMacroos

asm_pulse1:
	move	(a3)+,d0
	and	d4,d0
	cmp	#'LS',d0	;puLSe
	beq	asm_pulse2
	br	HandleMacroos

asm_pulse2:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"E"<<(1*8)+$8000,d0	;pulsE
	beq.s	asm_pulse3
	br	HandleMacroos

asm_pulse3:
	moveq	#PB_060,d0		;060
	bsr	Processor_warning

	move	#$4AC8,d6	;PULSE
	move	#$8040,d5
	br	Asm_InsertinstrA5


AsmP_PM:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"OV",d0	;PMOV
	beq.b	AsmP_PMOV
	br	HandleMacroos


;SYNOPSIS
;	PMOVE   MMU-reg,<ea>
;	PMOVE   <ea>,MMU-reg
;	PMOVEFD <ea>,MMU-reg
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
	move.l	#$F0005000,d6	;For MMUSR register	;was $F0006000
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
	br	CEE46

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

CAC90:
	move.l	#$F07C0000,d6
	move.b	#0,(OpperantSize-DT,a4)
	br	CEE90

CACA0:
	move.l	#$F07A0000,d6
	move.b	#$40,(OpperantSize-DT,a4)
	br	CEE90

CACB0:
	move.l	#$F07B0000,d6
	move.b	#$80,(OpperantSize-DT,a4)
	br	CEE90

CACC0:
	move.l	#$F07C0001,d6
	move.b	#0,(OpperantSize-DT,a4)
	br	CEE90

CACD0:
	move.l	#$F07A0001,d6
	move.b	#$40,(OpperantSize-DT,a4)
	br	CEE90

CACE0:
	move.l	#$F07B0001,d6
	move.b	#$80,(OpperantSize-DT,a4)
	br	CEE90

CACF0:
	move.l	#$F07C0002,d6
	move.b	#0,(OpperantSize-DT,a4)
	br	CEE90

CAD00:
	move.l	#$F07A0002,d6
	move.b	#$40,(OpperantSize-DT,a4)
	br	CEE90

CAD10:
	move.l	#$F07B0002,d6
	move.b	#$80,(OpperantSize-DT,a4)
	br	CEE90

CAD20:
	move.l	#$F07C0003,d6
	move.b	#0,(OpperantSize-DT,a4)
	br	CEE90

CAD30:
	move.l	#$F07A0003,d6
	move.b	#$40,(OpperantSize-DT,a4)
	br	CEE90

CAD40:
	move.l	#$F07B0003,d6
	move.b	#$80,(OpperantSize-DT,a4)
	br	CEE90

CAD50:
	move.l	#$F07C0004,d6
	move.b	#0,(OpperantSize-DT,a4)
	br	CEE90

CAD60:
	move.l	#$F07A0004,d6
	move.b	#$40,(OpperantSize-DT,a4)
	br	CEE90

CAD70:
	move.l	#$F07B0004,d6
	move.b	#$80,(OpperantSize-DT,a4)
	br	CEE90

CAD80:
	move.l	#$F07C0005,d6
	move.b	#0,(OpperantSize-DT,a4)
	br	CEE90

CAD90:
	move.l	#$F07A0005,d6
	move.b	#$40,(OpperantSize-DT,a4)
	br	CEE90

CADA0:
	move.l	#$F07B0005,d6
	move.b	#$80,(OpperantSize-DT,a4)
	br	CEE90

CADB0:
	move.l	#$F07C0006,d6
	move.b	#0,(OpperantSize-DT,a4)
	br	CEE90

CADC0:
	move.l	#$F07A0006,d6
	move.b	#$40,(OpperantSize-DT,a4)
	br	CEE90

CADD0:
	move.l	#$F07B0006,d6
	move.b	#$80,(OpperantSize-DT,a4)
	br	CEE90

CADE0:
	move.l	#$F07C0007,d6
	move.b	#0,(OpperantSize-DT,a4)
	br	CEE90

CADF0:
	move.l	#$F07A0007,d6
	move.b	#$40,(OpperantSize-DT,a4)
	br	CEE90

CAE00:
	move.l	#$F07B0007,d6
	move.b	#$80,(OpperantSize-DT,a4)
	br	CEE90

CAE10:
	move.l	#$F07C0008,d6
	move.b	#0,(OpperantSize-DT,a4)
	br	CEE90

CAE20:
	move.l	#$F07A0008,d6
	move.b	#$40,(OpperantSize-DT,a4)
	br	CEE90

CAE30:
	move.l	#$F07B0008,d6
	move.b	#$80,(OpperantSize-DT,a4)
	br	CEE90

CAE40:
	move.l	#$F07C0009,d6
	move.b	#0,(OpperantSize-DT,a4)
	br	CEE90

CAE50:
	move.l	#$F07A0009,d6
	move.b	#$40,(OpperantSize-DT,a4)
	br	CEE90

CAE60:
	move.l	#$F07B0009,d6
	move.b	#$80,(OpperantSize-DT,a4)
	br	CEE90

CAE70:
	move.l	#$F07C000A,d6
	move.b	#0,(OpperantSize-DT,a4)
	br	CEE90

CAE80:
	move.l	#$F07A000A,d6
	move.b	#$40,(OpperantSize-DT,a4)
	br	CEE90

CAE90:
	move.l	#$F07B000A,d6
	move.b	#$80,(OpperantSize-DT,a4)
	br	CEE90

CAEA0:
	move.l	#$F07C000B,d6
	move.b	#0,(OpperantSize-DT,a4)
	br	CEE90

CAEB0:
	move.l	#$F07A000B,d6
	move.b	#$40,(OpperantSize-DT,a4)
	br	CEE90

CAEC0:
	move.l	#$F07B000B,d6
	move.b	#$80,(OpperantSize-DT,a4)
	br	CEE90

CAED0:
	move.l	#$F07C000C,d6
	move.b	#0,(OpperantSize-DT,a4)
	br	CEE90

CAEE0:
	move.l	#$F07A000C,d6
	move.b	#$40,(OpperantSize-DT,a4)
	br	CEE90

CAEF0:
	move.l	#$F07B000C,d6
	move.b	#$80,(OpperantSize-DT,a4)
	br	CEE90

CAF00:
	move.l	#$F07C000D,d6
	move.b	#0,(OpperantSize-DT,a4)
	br	CEE90

CAF10:
	move.l	#$F07A000D,d6
	move.b	#$40,(OpperantSize-DT,a4)
	br	CEE90

CAF20:
	move.l	#$F07B000D,d6
	move.b	#$80,(OpperantSize-DT,a4)
	br	CEE90

CAF30:
	move.l	#$F07C000E,d6
	move.b	#0,(OpperantSize-DT,a4)
	br	CEE90

CAF40:
	move.l	#$F07A000E,d6
	move.b	#$40,(OpperantSize-DT,a4)
	br	CEE90

CAF50:
	move.l	#$F07B000E,d6
	move.b	#$80,(OpperantSize-DT,a4)
	br	CEE90

CAF60:
	move.l	#$F07C000F,d6
	move.b	#0,(OpperantSize-DT,a4)
	br	CEE90

CAF70:
	move.l	#$F07A000F,d6
	move.b	#$40,(OpperantSize-DT,a4)
	br	CEE90

CAF80:
	move.l	#$F07B000F,d6
	move.b	#$80,(OpperantSize-DT,a4)
	br	CEE90

Asm_PTES:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D452,d0	;TR
	beq.b	CAFA4
	cmp	#$D457,d0	;TW
	beq.b	CAFAE
	br	HandleMacroos

CAFA4:
	move.l	#$F0008200,d6
	br	CEEAE

CAFAE:
	move.l	#$F0008000,d6
	br	CEEAE

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
	beq	Asm_PFLUSHA
	cmp	#$D300,d0
	beq	Asm_PFLUSHS
	cmp	#$CE00,d0
	beq	Asm_PFLUSHN
	cmp	#$D200,d0
	beq	Asm_PFLUSHR
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
	br	CF35A

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
	beq.w	CB0F2
	cmp	#$4249,d0
	beq	CB10A
	cmp	#$4247,d0
	beq	CB122
	cmp	#$4243,d0
	beq	CB13A
	jmp	HandleMacroos

CB092:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D300,d0
	beq	CB152
	cmp	#$C300,d0
	beq	CB15C
	jmp	HandleMacroos

CB0AA:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D300,d0
	beq	CB166
	cmp	#$C300,d0
	beq	CB170
	jmp	HandleMacroos

CB0C2:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D300,d0
	beq	CB18E
	cmp	#$C300,d0
	beq	CB198
	jmp	HandleMacroos

CB0DA:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D300,d0
	beq	CB17A
	cmp	#$C300,d0
	beq	CB184
	jmp	HandleMacroos

CB0F2:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D300,d0
	beq	CB1A2
	cmp	#$C300,d0
	beq	CB1AC
	jmp	HandleMacroos

CB10A:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D300,d0
	beq	CB1B6
	cmp	#$C300,d0
	beq	CB1C0
	jmp	HandleMacroos

CB122:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D300,d0
	beq	CB1CA
	cmp	#$C300,d0
	beq	CB1D4
	jmp	HandleMacroos

CB13A:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D300,d0
	beq	CB1DE
	cmp	#$C300,d0
	beq	CB1E8
	jmp	HandleMacroos

CB152:
	move.l	#$0000F048,d6
	br	CF43C

CB15C:
	move.l	#$0001F048,d6
	br	CF43C

CB166:
	move.l	#$0002F048,d6
	br	CF43C

CB170:
	move.l	#$0003F048,d6
	br	CF43C

CB17A:
	move.l	#$0004F048,d6
	br	CF43C

CB184:
	move.l	#$0005F048,d6
	br	CF43C

CB18E:
	move.l	#$0006F048,d6
	br	CF43C

CB198:
	move.l	#$0007F048,d6
	br	CF43C

CB1A2:
	move.l	#$0008F048,d6
	br	CF43C

CB1AC:
	move.l	#$0009F048,d6
	br	CF43C

CB1B6:
	move.l	#$000AF048,d6
	br	CF43C

CB1C0:
	move.l	#$000BF048,d6
	br	CF43C

CB1CA:
	move.l	#$000CF048,d6
	br	CF43C

CB1D4:
	move.l	#$000DF048,d6
	br	CF43C

CB1DE:
	move.l	#$000EF048,d6
	br	CF43C

CB1E8:
	move.l	#$000FF048,d6
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
	br	_HandleMacroos	;was HandleMacroos

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
	jmp	(HandleMacroos).l

CB35A:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq	CB4EA
	cmp	#$C04C,d0
	beq	CB4F4
	jmp	(HandleMacroos).l

CB374:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq	CB500
	cmp	#$C04C,d0
	beq	CB50A
	jmp	(HandleMacroos).l

CB38E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq	CB516
	cmp	#$C04C,d0
	beq	CB520
	jmp	(HandleMacroos).l

CB3A8:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq	CB52C
	cmp	#$C04C,d0
	beq	CB536
	jmp	(HandleMacroos).l

CB3C2:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq	CB542
	cmp	#$C04C,d0
	beq	CB54C
	jmp	(HandleMacroos).l

CB3DC:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq	CB558
	cmp	#$C04C,d0
	beq	CB562
	jmp	(HandleMacroos).l

CB3F6:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq	CB56E
	cmp	#$C04C,d0
	beq	CB578
	jmp	(HandleMacroos).l

CB410:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq	CB584
	cmp	#$C04C,d0
	beq	CB58E
	jmp	(HandleMacroos).l

CB42A:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq	CB59A
	cmp	#$C04C,d0
	beq	CB5A4
	jmp	(HandleMacroos).l

CB444:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq	CB5B0
	cmp	#$C04C,d0
	beq	CB5BA
	jmp	(HandleMacroos).l

CB45E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq	CB5C6
	cmp	#$C04C,d0
	beq	CB5D0
	jmp	(HandleMacroos).l

CB478:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq	CB5DC
	cmp	#$C04C,d0
	beq	CB5E6
	jmp	(HandleMacroos).l

CB492:
	move	#$F080,d6
	moveq	#$40,d5
	br	CF466

CB49C:
	move	#$F0C0,d6
	move	#$0080,d5
	br	CF466

CB4A8:
	move	#$F081,d6
	moveq	#$40,d5
	br	CF466

CB4B2:
	move	#$F0C1,d6
	move	#$0080,d5
	br	CF466

CB4BE:
	move	#$F082,d6
	moveq	#$40,d5
	br	CF466

CB4C8:
	move	#$F0C2,d6
	move	#$0080,d5
	br	CF466

CB4D4:
	move	#$F083,d6
	moveq	#$40,d5
	br	CF466

CB4DE:
	move	#$F0C3,d6
	move	#$0080,d5
	br	CF466

CB4EA:
	move	#$F084,d6
	moveq	#$40,d5
	br	CF466

CB4F4:
	move	#$F0C4,d6
	move	#$0080,d5
	br	CF466

CB500:
	move	#$F085,d6
	moveq	#$40,d5
	br	CF466

CB50A:
	move	#$F0C5,d6
	move	#$0080,d5
	br	CF466

CB516:
	move	#$F086,d6
	moveq	#$40,d5
	br	CF466

CB520:
	move	#$F0C6,d6
	move	#$0080,d5
	br	CF466

CB52C:
	move	#$F087,d6
	moveq	#$40,d5
	br	CF466

CB536:
	move	#$F0C7,d6
	move	#$0080,d5
	br	CF466

CB542:
	move	#$F088,d6
	moveq	#$40,d5
	br	CF466

CB54C:
	move	#$F0C8,d6
	move	#$0080,d5
	br	CF466

CB558:
	move	#$F089,d6
	moveq	#$40,d5
	br	CF466

CB562:
	move	#$F0C9,d6
	move	#$0080,d5
	br	CF466

CB56E:
	move	#$F08A,d6
	moveq	#$40,d5
	br	CF466

CB578:
	move	#$F0CA,d6
	move	#$0080,d5
	br	CF466

CB584:
	move	#$F08B,d6
	moveq	#$40,d5
	br	CF466

CB58E:
	move	#$F0CB,d6
	move	#$0080,d5
	br	CF466

CB59A:
	move	#$F08C,d6
	moveq	#$40,d5
	br	CF466

CB5A4:
	move	#$F0CC,d6
	move	#$0080,d5
	br	CF466

CB5B0:
	move	#$F08D,d6
	moveq	#$40,d5
	br	CF466

CB5BA:
	move	#$F0CD,d6
	move	#$0080,d5
	br	CF466

CB5C6:
	move	#$F08E,d6
	moveq	#$40,d5
	br	CF466

CB5D0:
	move	#$F0CE,d6
	move	#$0080,d5
	br	CF466

CB5DC:
	move	#$F08F,d6
	moveq	#$40,d5
	br	CF466

CB5E6:
	move	#$F0CF,d6
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

CB622:
	move	#$F140,d6
	br	CEFBA

Asm_PRIN:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D456,d0	;prinTV
	beq	CD4F0
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
	beq	CB6E2
	cmp	#$CC43,d0
	beq	CB6EC
	cmp	#$D353,d0
	beq	CB6F6
	cmp	#$D343,d0
	beq	CB700
	cmp	#$C153,d0
	beq	CB70A
	cmp	#$C143,d0
	beq	CB714
	cmp	#$D753,d0
	beq	CB71E
	cmp	#$D743,d0
	beq	CB728
	cmp	#$C953,d0
	beq	CB732
	cmp	#$C943,d0
	beq	CB73C
	cmp	#$C753,d0
	beq	CB746
	cmp	#$C743,d0
	beq	CB750
	cmp	#$C353,d0
	beq	CB75A
	cmp	#$C343,d0
	beq	CB764
	br	_HandleMacroos

CB6CE:
	move.l	#$F0400000,d6
	br	CEF96

CB6D8:
	move.l	#$F0400001,d6
	br	CEF96

CB6E2:
	move.l	#$F0400002,d6
	br	CEF96

CB6EC:
	move.l	#$F0400003,d6
	br	CEF96

CB6F6:
	move.l	#$F0400004,d6
	br	CEF96

CB700:
	move.l	#$F0400005,d6
	br	CEF96

CB70A:
	move.l	#$F0400006,d6
	br	CEF96

CB714:
	move.l	#$F0400007,d6
	br	CEF96

CB71E:
	move.l	#$F0400008,d6
	br	CEF96

CB728:
	move.l	#$F0400009,d6
	br	CEF96

CB732:
	move.l	#$F040000A,d6
	br	CEF96

CB73C:
	move.l	#$F040000B,d6
	br	CEF96

CB746:
	move.l	#$F040000C,d6
	br	CEF96

CB750:
	move.l	#$F040000D,d6
	br	CEF96

CB75A:
	move.l	#$F040000E,d6
	br	CEF96

CB764:
	move.l	#$F040000F,d6
	br	CEF96

CB76E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C500,d0
	beq.b	CB77C
	br	_HandleMacroos

CB77C:
	move	#$F100,d6
	br	CEFBA

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
	beq.b	CB816
	cmp	#$C200,d0
	beq	ERROR_IllegalSize
	br	_HandleMacroos

Asm_PL:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C54E,d0
	beq	CD83A
	cmp	#$4F41,d0
	beq.b	Asm_plOA
	br	_HandleMacroos

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
	beq	CD7FA
	cmp	#$C34B,d0
	beq.b	CB80C
	br	_HandleMacroos

CB80C:
	move	#$8140,d6
	moveq	#0,d5
	br	CFF0C

CB816:
	move	#$4840,d6
	move	#$0080,d5
	br	Asm_CmdJmpJsrPea

AsmR:
	cmp	#'RT',d0
	beq	CB8A6
	cmp	#'RS',d0
	beq.b	CB84C
	cmp	#'RO',d0
	beq	CB91A
	cmp	#"RS"+$8000,d0
	beq	CE702
	cmp	#'RE',d0
	beq	CBA78
	br	_HandleMacroos

CB84C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"@W"+$8000,d0
	beq	CE702
	cmp	#"@L"+$8000,d0
	beq	CE714
	cmp	#"@B"+$8000,d0
	beq	CE6F2
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
	beq	CE6E0
	br	_HandleMacroos

CB896:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D400,d0
	beq	CE6E6
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

CB8CC:
	move	#$4E74,d6
	moveq	#$40,d5
	move	#1,d0
	bsr	Processor_warning
	br	C1009E

CB8DE:
	move	#$06C0,d6
	moveq	#$40,d5
	move	#$0082,d0
	bsr	Processor_warning
	bsr	AdresOfDataReg
	or.w	d1,d6
	br	Asm_InsertInstruction

CB8F6:
	move	#$4E75,d6
	move	#$8040,d5
	br	Asm_InsertinstrA5

CB902:
	move	#$4E73,d6
	move	#$8040,d5
	br	Asm_InsertinstrA5

CB90E:
	move	#$4E77,d6
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

CB960:
	move	#$E7D8,d6
	move	#$8040,d5
	br	C10798

CB96C:
	move	#$E6D8,d6
	move	#$8040,d5
	br	C10798

CB978:
	move	#$E5D0,d6
	move	#$8040,d5
	br	C10798

CB984:
	move	#$E4D0,d6
	move	#$8040,d5
	br	C10798

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

CB9AA:
	move	#$E7D8,d6
	moveq	#0,d5
	br	C10798

CB9B4:
	move	#$E7D8,d6
	moveq	#$40,d5
	br	C10798

CB9BE:
	move	#$E7D8,d6
	move	#$0080,d5
	br	C10798

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

CB9E4:
	move	#$E6D8,d6
	moveq	#0,d5
	br	C10798

CB9EE:
	move	#$E6D8,d6
	moveq	#$40,d5
	br	C10798

CB9F8:
	move	#$E6D8,d6
	move	#$0080,d5
	br	C10798

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

CBA1E:
	move	#$E5D0,d6
	moveq	#0,d5
	br	C10798

CBA28:
	move	#$E5D0,d6
	moveq	#$40,d5
	br	C10798

CBA32:
	move	#$E5D0,d6
	move	#$0080,d5
	br	C10798

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

CBA58:
	move	#$E4D0,d6
	moveq	#0,d5
	br	C10798

CBA62:
	move	#$E4D0,d6
	moveq	#$40,d5
	br	C10798

CBA6C:
	move	#$E4D0,d6
	move	#$0080,d5
	br	C10798

CBA78:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D054,d0
	beq	CD58C
	cmp	#$C700,d0
	beq	CD730
	cmp	#$5345,d0
	beq.b	CBA9C
	cmp	#$CD00,d0
	beq.b	CBAB6
	br	_HandleMacroos

CBA9C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D400,d0
	beq.b	CBAAA
	br	_HandleMacroos

CBAAA:
	move	#$4E70,d6
	move	#$8040,d5
	br	Asm_InsertinstrA5

CBAB6:
	tst	(MACRO_LEVEL-DT,a4)
	bne.b	CBB14
	move.l	d0,-(sp)
CBABE:
	move.b	(a6)+,d0
	tst.b	d0
	bne.b	CBACC
	move.l	a6,(DATA_LINE_START_PTR-DT,a4)
	addq.l	#1,(DATA_CURRENTLINE-DT,a4)
CBACC:
	cmp.b	#$1A,d0
	beq.b	CBB08
	and.b	#$DF,d0
	cmp.b	#$45,d0
	bne.b	CBABE
	move.b	(a6),d0
	and.b	#$DF,d0
	cmp.b	#$52,d0
	bne.b	CBABE
	move.b	(1,a6),d0
	and.b	#$DF,d0
	cmp.b	#$45,d0
	bne.b	CBABE
	move.b	(2,a6),d0
	and.b	#$DF,d0
	cmp.b	#$4D,d0
	bne.b	CBABE
CBB04:
	tst.b	(a6)+
	bne.b	CBB04
CBB08:
	subq.w	#1,a6
	move.l	(sp)+,d0
	cmp.b	#$1A,(a6)
	beq	ERROR_REMwithoutEREM
CBB14:
	rts

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
	beq	CBBF8
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

CBBCA:
	move	#$8100,d6
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

CBBF8:
	move	#$50C0,d6
	moveq	#0,d5
	br	C108B6

CBC02:
	move	#$4E72,d6
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

CBC2A:
	move	#$51C0,d6
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

CBC90:
	move	#$54C0,d6
	moveq	#0,d5
	br	C108B6

CBC9A:
	move	#$55C0,d6
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

CBCC6:
	move	#'H@',d6
	moveq	#$40,d5
	br	C1089E

CBCD0:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C251,d0
	beq	CBD48
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

CBD3E:
	move	#$5100,d6
	moveq	#0,d5
	br	ASSEM_CMDADDQSUBQ

CBD48:
	move	#$5140,d6
	moveq	#$40,d5
	br	ASSEM_CMDADDQSUBQ

CBD52:
	move	#$5180,d6
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

CBD98:
	move	#$9100,d6
	moveq	#0,d5
	br	CEB92

CBDA2:
	move	#$9140,d6
	moveq	#$40,d5
	br	CEB92

CBDAC:
	move	#$9180,d6
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

CBDEC:
	move	#$9400,d6
	moveq	#0,d5
	br	Asmbl_AddSubCmp

CBDF6:
	move	#$9400,d6
	moveq	#$40,d5
	br	Asmbl_AddSubCmp

CBE00:
	move	#$9400,d6
	move	#$0080,d5
	br	Asmbl_AddSubCmp

Asm_SE:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"CT",d0	SECTion
	beq.b	CBE4C
	cmp	#$D400,d0	SET
	beq	ASSEM_CMDLABELSET
	cmp	#$D100,d0	SEQ
	beq.b	CBE6A
	cmp	#"Q@",d0	SEQ.
	beq.b	CBE2E
	cmp.w	#"TC",d0	SETCpu
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
	beq	CD88C
	br	_HandleMacroos

CBE6A:
	move	#$57C0,d6
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

CBED0:
	move	#$54C0,d6
	moveq	#0,d5
	br	C108B6

CBEDA:
	move	#$52C0,d6
	moveq	#0,d5
	br	C108B6

CBEE4:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CC00,d0
	beq.b	CBF1E
	cmp	#$C300,d0
	beq	CD860
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

CBF1E:
	move	#$5AC0,d6
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

CBF84:
	move	#$58C0,d6
	moveq	#0,d5
	br	C108B6

CBF8E:
	move	#$59C0,d6
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
	beq	CC070
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

CC052:
	move	#$55C0,d6
	moveq	#0,d5
	br	C108B6

CC05C:
	move	#$5FC0,d6
	moveq	#0,d5
	br	C108B6

CC066:
	move	#$53C0,d6
	moveq	#0,d5
	br	C108B6

CC070:
	move	#$5DC0,d6
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

CC0AC:
	move	#$56C0,d6
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

CC0E8:
	move	#$5BC0,d6
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

CC14E:
	move	#$5CC0,d6
	moveq	#0,d5
	br	C108B6

CC158:
	move	#$5EC0,d6
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
	beq.b	CC1B0
	br	_HandleMacroos

CC188:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"L"<<(1*8)+$8000,d0
	beq	CD878
	br	_HandleMacroos

Asm_TS:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"T@",d0
	beq	CC282
	cmp	#"T"<<(1*8)+$8000,d0
	beq	Asm_tsT
	br	_HandleMacroos

CC1B0:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"XT"+$8000,d0
	beq.b	CC1BE
	br	_HandleMacroos

CC1BE:
	tst	(MACRO_LEVEL-DT,a4)
	bne	CC24A
	movem.l	d0/d1/a0,-(sp)
CC1CA:
	tst.b	(a6)+
	bne.b	CC1CA
	move.l	a6,(DATA_LINE_START_PTR-DT,a4)
	addq.l	#1,(DATA_CURRENTLINE-DT,a4)
CC1D6:
	move.b	(a6)+,d0
	bne.b	CC1E2
	move.l	a6,(DATA_LINE_START_PTR-DT,a4)
	addq.l	#1,(DATA_CURRENTLINE-DT,a4)
CC1E2:
	move.b	d0,d1
	cmp.b	#$1A,d0
	beq.b	CC23C
	and.b	#$DF,d0
	cmp.b	#$45,d0
	bne.b	CC24C
	move.b	(a6),d0
	and.b	#$DF,d0
	cmp.b	#$54,d0
	bne.b	CC24C
	move.b	(1,a6),d0
	and.b	#$DF,d0
	cmp.b	#$45,d0
	bne.b	CC24C
	move.b	(2,a6),d0
	and.b	#$DF,d0
	cmp.b	#$58,d0
	bne.b	CC24C
	move.b	(3,a6),d0
	and.b	#$DF,d0
	cmp.b	#$54,d0
	bne.b	CC24C
CC22A:
	subq.l	#1,(INSTRUCTION_ORG_PTR-DT,a4)
	tst.b	-(a6)
	bne.b	CC22A
	addq.l	#2,(INSTRUCTION_ORG_PTR-DT,a4)
	addq.w	#2,a6
CC238:
	tst.b	(a6)+
	bne.b	CC238
CC23C:
	subq.w	#1,a6
	movem.l	(sp)+,d0/d1/a0
	cmp.b	#$1A,(a6)
	beq	ERROR_TEXTwithoutETEXT
CC24A:
	rts

CC24C:
	tst	d7	;passone
	bmi.b	CC278
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),a0
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
	cmp.b	#$7C,d1
	bne.b	CC268
	bchg	#0,(W0C280).l
	bra.b	CC27C

CC268:
	btst	#0,(W0C280).l
	beq.b	CC276
	sub.b	#$30,d1
CC276:
	move.b	d1,(a0)
CC278:
	addq.l	#1,(INSTRUCTION_ORG_PTR-DT,a4)
CC27C:
	br	CC1D6

W0C280:
	dc.w	0

CC282:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D700,d0
	beq.b	Asm_tsT
	cmp	#$C200,d0
	beq.b	CC29C
	cmp	#$CC00,d0
	beq.b	CC2B0
	br	_HandleMacroos

CC29C:
	move	#$4A00,d6
	moveq	#0,d5
	br	ASSEM_CMDCLRNOTTST

Asm_tsT:
	move	#$4A40,d6
	moveq	#$40,d5
	br	ASSEM_CMDCLRNOTTST

CC2B0:
	move	#$4A80,d6
	move	#$0080,d5
	br	ASSEM_CMDCLRNOTTST

CC2BC:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C150,d0
	beq	CC512
	cmp	#$4150,d0
	beq.b	CC2D2
	br	_HandleMacroos

CC2D2:
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

CC3E2:
	move	#$50FA,d6
	br	CFEE2

CC3EA:
	move	#$51FA,d6
	br	CFEE2

CC3F2:
	move	#$5BFA,d6
	br	CFEE2

CC3FA:
	move	#$5AFA,d6
	br	CFEE2

CC402:
	move	#$59FA,d6
	br	CFEE2

CC40A:
	move	#$58FA,d6
	br	CFEE2

CC412:
	move	#$55FA,d6
	br	CFEE2

CC41A:
	move	#$54FA,d6
	br	CFEE2

CC422:
	move	#$53FA,d6
	br	CFEE2

CC42A:
	move	#$52FA,d6
	br	CFEE2

CC432:
	move	#$5DFA,d6
	br	CFEE2

CC43A:
	move	#$5EFA,d6
	br	CFEE2

CC442:
	move	#$5FFA,d6
	br	CFEE2

CC44A:
	move	#$5CFA,d6
	br	CFEE2

CC452:
	move	#$57FA,d6
	br	CFEE2

CC45A:
	move	#$56FA,d6
	br	CFEE2

CC462:
	move.b	(a3),d0
	and.b	#$5F,d0
	move.b	d0,(1,a3)
	move.b	#$C0,(a3)
	move	#$50FA,d6
	bra.b	CC4E0

CC476:
	move.b	(a3),d0
	and.b	#$5F,d0
	move.b	d0,(1,a3)
	move.b	#$C0,(a3)
	move	#$51FA,d6
	bra.b	CC4E0

CC48A:
	move	#$5BFA,d6
	bra.b	CC4E0

CC490:
	move	#$5AFA,d6
	bra.b	CC4E0

CC496:
	move	#$59FA,d6
	bra.b	CC4E0

CC49C:
	move	#$58FA,d6
	bra.b	CC4E0

CC4A2:
	move	#$55FA,d6
	bra.b	CC4E0

CC4A8:
	move	#$54FA,d6
	bra.b	CC4E0

CC4AE:
	move	#$53FA,d6
	bra.b	CC4E0

CC4B4:
	move	#$52FA,d6
	bra.b	CC4E0

CC4BA:
	move	#$5DFA,d6
	bra.b	CC4E0

CC4C0:
	move	#$5EFA,d6
	bra.b	CC4E0

CC4C6:
	move	#$5FFA,d6
	bra.b	CC4E0

CC4CC:
	move	#$5CFA,d6
	bra.b	CC4E0

CC4D2:
	move	#$57FA,d6
	bra.b	CC4E0

CC4D8:
	move	#$56FA,d6
	br	CC4E0

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

CC4FE:
	move	#$0040,d5
	br	CFEE2

CC506:
	move	#$4E76,d6
	move	#$8040,d5
	br	Asm_InsertinstrA5

CC512:
	move	#$4E40,d6
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

CC550:
	move	#$4AC0,d6
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
	br	_HandleMacroos

CC578:
	move	#$4E58,d6
	moveq	#$40,d5
	br	C10878

CC582:
	move	#$8180,d6
	moveq	#0,d5
	br	CFF0C

AsmX:
	cmp	#'XR',d0
	beq.b	CC59C
	cmp	#'XD',d0
	beq.b	CC5AC
	br	_HandleMacroos

CC59C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#"EF"+$8000,d0
	beq	CD75C
	br	_HandleMacroos

CC5AC:
	move	(a3)+,d0
	and	d4,d0

	cmp	#"EF"+$8000,d0
	beq	CD778
	br	_HandleMacroos

;**********************************************

;_C00CCE2:	bra	ERROR_ReservedWord
;_ERROR_UndefSymbol:	bra	ERROR_UndefSymbol

_CFB00:	bra	CFB00
_CEBCE:	bra	CEBCE
	
;***********************************************

ConditionAssembl:
	dc.w	_HandleMacroos-ConditionAssembl
	dc.w	CC5FA-ConditionAssembl
	dc.w	CC614-ConditionAssembl
	dc.w	CC64A-ConditionAssembl
	dc.w	CC688-ConditionAssembl
	dc.w	CC6DA-ConditionAssembl
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
	dc.w	CCB9C-ConditionAssembl
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
__HandleMacroos:
	br	_HandleMacroos

CC604:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D44F,d0
	beq	Asm_AUTO
	br	_HandleMacroos

CC614:
	cmp	#'BA',d0
	beq.b	CC61E
	br	_HandleMacroos

CC61E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#'SE',d0
	beq.b	CC62C
	br	_HandleMacroos

CC62C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$5245,d0
	beq.b	CC63A
	br	_HandleMacroos

CC63A:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C700,d0
	beq	CD51E
	br	_HandleMacroos

CC64A:
	cmp	#$434E,d0
	beq.b	CC678
	cmp	#$434D,d0
	beq.b	CC65A
	br	_HandleMacroos

CC65A:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$4558,d0
	beq.b	CC668
	br	_HandleMacroos

CC668:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C954,d0
	beq	CE45C
	br	_HandleMacroos

CC678:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CF50,d0
	beq	Asm_CNOP
	br	_HandleMacroos

CC688:
	cmp	#$4453,d0
	beq.b	CC69A
	cmp	#$C453,d0
	beq	CE190
	br	_HandleMacroos

CC69A:
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
	beq	CD706
	br	_HandleMacroos

CC734:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C54E,d0
	beq	CD93C
	br	_HandleMacroos

CC744:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C452,d0
	beq	CD5EE
	cmp	#$C44D,d0
	beq	CE44E
	cmp	#$C443,d0
	beq	CE5BC
	cmp	#'DC',d0
	beq	C6BCC
	cmp	#'DI',d0
	beq.b	CC798
	cmp	#$5452,d0
	beq.b	CC788
	cmp	#$C400,d0
	beq	CE27E
	cmp	#$C442,d0
	beq	CD55C
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
	beq	CE5BC
	br	_HandleMacroos

CC7A8:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D345,d0
	beq	CE5AC
	br	_HandleMacroos

CC7B8:
	cmp	#$4641,d0
	beq.b	CC7C2
	br	_HandleMacroos

CC7C2:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C94C,d0
	beq	CE616
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
	beq	CE4A4
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
	beq	CD880
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
	beq	CE61A
	br	_HandleMacroos

CC8AE:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CE45,d0
	beq	CE4A4
	cmp	#$CE44,d0
	beq	CE54A
	cmp	#$CE43,d0
	beq	CE528
	cmp	#$CE42,d0
	beq	CE55C
	cmp	#$CC54,d0
	beq	CE4D4
	cmp	#$CC45,d0
	beq	CE4E4
	cmp	#$C754,d0
	beq	CE4B4
	cmp	#$C745,d0
	beq	CE4C4
	cmp	#$C551,d0
	beq	CE480
	cmp	#$C400,d0
	beq	CE544
	cmp	#$C300,d0
	beq	CE520
	cmp	#$C200,d0
	beq	CE550
	cmp	#$9200,d0
	beq	CE49A
	cmp	#$9100,d0
	beq	CE490
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
	beq	CD920
	br	_HandleMacroos

CC982:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D354,d0
	beq	CD812
	br	_HandleMacroos

CC992:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C54E,d0
	beq	CD81E
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
	beq	CD888
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
	beq	CE44C
	br	_HandleMacroos

CCA04:
	cmp	#$4E4F,d0
	beq.b	CCA0E
	br	_HandleMacroos

CCA0E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CC00,d0
	beq	CD818
	cmp	#'PA',d0
	beq.b	CCA2A
	cmp	#'LI',d0
	beq.b	CCA3A
	br	_HandleMacroos

CCA2A:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C745,d0
	beq	CD808
	br	_HandleMacroos

CCA3A:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D354,d0
	beq	CD818
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
	beq	CD8FA
	br	_HandleMacroos

CCA70:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C400,d0
	beq	CD952
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
	beq	CE74A
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
	beq	CD4F0
	cmp	#$D454,d0
	beq	Asm_PRINTT
	br	_HandleMacroos

CCADA:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C745,d0
	beq	CD7FA
	br	_HandleMacroos

CCAEA:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C54E,d0
	beq	CD83A
	br	_HandleMacroos

CCAFA:
	cmp	#'RS',d0
	beq.b	CCB32
	cmp	#'RE',d0
	beq.b	CCB1A
	cmp	#'RO',d0
	beq	CCB8C
	cmp	#'ÒS',d0
	beq	CE702
	br	_HandleMacroos

CCB1A:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D054,d0
	beq	CD58C
	cmp	#$C700,d0
	beq	CD730
	br	_HandleMacroos

CCB32:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C057,d0
	beq	CE702
	cmp	#$C04C,d0
	beq	CE714
	cmp	#$C042,d0
	beq	CE6F2
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
	beq	CE6E0
	br	_HandleMacroos

CCB7C:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D400,d0
	beq	CE6E6
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
	beq	CD860
	br	_HandleMacroos

CCBBC:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D400,d0
	beq	ASSEM_CMDLABELSET
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
	beq	CD88C
	br	_HandleMacroos

CCBF0:
	cmp	#'TT',d0
	beq.b	CCBFA
	br	_HandleMacroos

CCBFA:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CC00,d0
	beq	CD878
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


_C00FA44:	bra.w	CFA44

;************ ERROR MSGS *************

ERROR_AddressRegByte:	bsr	ShowErrorMsg
ERROR_AddressRegExp:	bsr	ShowErrorMsg
ERROR_Dataregexpect:	bsr	ShowErrorMsg
ERROR_DoubleSymbol:	bsr	ShowErrorMsg
ERROR_EndofFile:	bsr	ShowErrorMsg
ERROR_UsermadeFAIL:	bsr	ShowErrorMsg
ERROR_FileError:	bsr	ShowErrorMsg
ERROR_InvalidAddress:	bsr	ShowErrorMsg
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
ERROR_out_of_range0bit:	bsr	ShowErrorMsg
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
ERROR_Illegaloption:	bsr	ShowErrorMsg
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
ERROR_BccWoutofrange:	bsr	ShowErrorMsg
ERROR_Floatingpoint:	bsr	ShowErrorMsg
ERROR_OutofRange6bit:	bsr	ShowErrorMsg
ERROR_OutofRange7bit:	bsr	ShowErrorMsg
ERROR_FPUneededforopp:	bsr	ShowErrorMsg
ERROR_Tomanywatchpoints:	bsr	ShowErrorMsg
ERROR_Illegalsource:	bsr	ShowErrorMsg
ERROR_Novalidmemory:	bsr	ShowErrorMsg
ERROR_Autocommandoverflow:	bsr	ShowErrorMsg
ERROR_Endshouldbehind:	bsr	ShowErrorMsg
ERROR_Warningvalues:	bsr	ShowErrorMsg
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
ERROR_Bitfieldoutofrange32bit:	bsr	ShowErrorMsg
ERROR_GeneralPurpose:	bsr	ShowErrorMsg
ERROR_AdrOrPCExpected:	bsr	ShowErrorMsg
ERROR_UnknowCPU:	bsr	ShowErrorMsg

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
	beq	CE5BC
	cmp	#'DC',d0
	beq	C6BCC
	cmp	#$4449,d0
	beq.b	CCDEC
	cmp	#$C44D,d0
	beq	CE44E
	br	_HandleMacroos

CCDEC:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C600,d0
	beq	CE5BC
	br	_HandleMacroos

CCDFC:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$D345,d0
	beq	CE5AC
	br	_HandleMacroos

CondAsmI:
	cmp	#$C946,d0
	beq	CE596
	cmp	#'IF',d0
	beq.b	CCE1E
	br	_HandleMacroos

CCE1E:
	move	(a3)+,d0
	and	d4,d0
	cmp	#$CE45,d0
	beq	CE596
	cmp	#$CE44,d0
	beq	CE596
	cmp	#$CE43,d0
	beq	CE596
	cmp	#$CE42,d0
	beq	CE596
	cmp	#$CC54,d0
	beq	CE596
	cmp	#$CC45,d0
	beq	CE596
	cmp	#$C754,d0
	beq	CE596
	cmp	#$C745,d0
	beq	CE596
	cmp	#$C551,d0
	beq	CE596
	cmp	#$C400,d0
	beq	CE596
	cmp	#$C300,d0
	beq	CE596
	cmp	#$C200,d0
	beq	CE596
	cmp	#$9200,d0
	beq	CE596
	cmp	#$9100,d0
	beq	CE596
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
	lea	(SourceCode-DT,a4),a1
	bsr	OntfrutselNaam
	jsr	(MenNemeNaamEnPad).l
	move.b	#0,(IncIff_tiepe-DT,a4)
	move.b	#0,(IncIff_colmap_pos-DT,a4)
	cmp.b	#',',(a6)	;, ?
	bne	IncIff_nocols
	addq.w	#1,a6
	move.b	(a6)+,d0
	lsl.w	#8,d0
	move.b	(a6)+,d0
	and	#$DFDF,d0
	cmp	#'RB',d0	;RB
	beq.b	IncIff_rawblit
	cmp	#'RN',d0	;RN
	beq.b	IncIff_rawnormal
	br	ERROR_UnknownconversionMode

IncIff_rawnormal:
	move.b	#1,(IncIff_tiepe-DT,a4)
IncIff_rawblit:
	cmp.b	#',',(a6)
	bne.b	IncIff_nocols
	addq.w	#1,a6
	move.b	(a6)+,d0
	and.b	#$DF,d0
	cmp.b	#'B',d0
	beq.b	IncIff_befor
	cmp.b	#'A',d0
	beq.b	IncIff_after
	cmp.b	#'N',d0
	beq.b	IncIff_none
	br	ERROR_Unknowncmapplace

IncIff_befor:
	move.b	#1,(IncIff_colmap_pos-DT,a4)
	bra.b	IncIff_none

IncIff_after:
	move.b	#2,(IncIff_colmap_pos-DT,a4)
IncIff_none:
	cmp.b	#$2C,(a6)
	bne.b	IncIff_nocols
	addq.w	#1,a6
	moveq	#0,d0
	move.b	(a6)+,d0
	lsl.l	#8,d0
	move.b	(a6)+,d0
	lsl.l	#8,d0
	move.b	(a6)+,d0
	and.l	#$DFDFDFDF,d0
	cmp.l	#"AGA",d0
	beq.b	IncIff_AGAcols
	cmp.l	#"ECS",d0
	beq.b	IncIff_nocols
	br	ERROR_Unknowncmapmode

IncIff_AGAcols:
	or.b	#$80,(IncIff_colmap_pos-DT,a4)
IncIff_nocols:
	move.l	a6,(L0D4C8).l
	move.l	#4096,d0
	move.l	#$00010001,d1
	move.l	a6,-(sp)
	move.l	(4).w,a6
	jsr	(_LVOAllocMem,a6)
	move.l	(sp)+,a6
	move.l	d0,(buffer_ptr-DT,a4)
	beq	ERROR_WorkspaceMemoryFull
	jsr	(OpenOldFile).l
	move.l	(Bestand-DT,a4),d1
	move.l	(buffer_ptr-DT,a4),a0
	move.l	a0,d2
	moveq.l	#8,d3
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVORead,a6)
	move.l	#0,(IncIff_filepos-DT,a4)
	add.l	#8,(IncIff_filepos-DT,a4)
	move.l	(buffer_ptr-DT,a4),a0
	cmp.l	#"FORM",(a0)+
	bne	IncIff_noFORM
	move.l	(a0)+,(IncIff_sizeFORM-DT,a4)
	move.l	(Bestand-DT,a4),d1
	move.l	(buffer_ptr-DT,a4),d2
	moveq.l	#4,d3
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVORead,a6)
	move.l	(buffer_ptr-DT,a4),a0
	cmp.l	#"ILBM",(a0)
	bne	IncIff_noILBM
IncIff_Opnieuwzoeken:
	move.l	(Bestand-DT,a4),d1
	move.l	(buffer_ptr-DT,a4),d2
	add.l	#8,(IncIff_filepos-DT,a4)
	moveq.l	#8,d3
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVORead,a6)
	tst.l	d0
	beq	IncIff_readerror
	move.l	(buffer_ptr-DT,a4),a0
	move.l	(4,a0),(IncIff_hunksize-DT,a4)
	cmp.l	#"BMHD",(a0)
	beq.b	IncIff_BMHD
	cmp.l	#"CMAP",(a0)
	beq	IncIff_CMAP
	cmp.l	#"BODY",(a0)
	beq	IncIff_BODY
;	br	IncIff_skip2nexthunk

IncIff_skip2nexthunk:
	move.l	(Bestand-DT,a4),d1
	move.l	(IncIff_hunksize-DT,a4),d2
	add.l	d2,(IncIff_filepos-DT,a4)
	moveq.l	#0,d3
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOSeek,a6)
	br	IncIff_Opnieuwzoeken

IncIff_BMHD:
	move.l	(IncIff_hunksize-DT,a4),d3
	move.l	(Bestand-DT,a4),d1
	move.l	(IncIff_hunksize-DT,a4),d0
	add.l	d0,(IncIff_filepos-DT,a4)
	move.l	(buffer_ptr-DT,a4),a0
	move.l	a0,d2
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVORead,a6)

	move.l	(buffer_ptr-DT,a4),a0
	move	(a0),(IFFbreed-DT,a4)
	move	(2,a0),(IFFhoog-DT,a4)
	move	(4,a0),(IFFlinks-DT,a4)
	move	(6,a0),(IFFboven-DT,a4)
	move.b	(8,a0),(IFFnrplanes-DT,a4)
	move.b	(9,a0),(IFFmask-DT,a4)
	move.b	(10,a0),(IFFcompressed-DT,a4)
	move	($0010,a0),(IFFpbreed-DT,a4)	;16
	move	($0012,a0),(IFFphoog-DT,a4)	;18
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
	moveq	#0,d5
	move.b	(IFFnrplanes-DT,a4),d5
	lsl.w	d5,d6
	move	d6,d5
	add	d6,d6
	add	d5,d6
	subq.w	#1,d6
	move.l	(buffer_ptr-DT,a4),a0
	lea	(L2FD32-DT,a4),a1
.lopje:
	move.b	(a0)+,(a1)+
	dbra	d6,.lopje
	bsr.b	CD118
	br	IncIff_Opnieuwzoeken

CD100:
	bsr.b	CD118
	move.b	(IncIff_colmap_pos-DT,a4),d1
	and.b	#15,d1
	tst.b	d1
	beq	IncIff_skip2nexthunk
	add.l	d0,(INSTRUCTION_ORG_PTR-DT,a4)
	br	IncIff_skip2nexthunk

CD118:
	moveq	#0,d1
	move.b	(IFFnrplanes-DT,a4),d1
	moveq	#1,d0
	lsl.l	d1,d0
	add.l	d0,d0
	tst.b	(IncIff_colmap_pos-DT,a4)
	bpl.b	CD12C
	add.l	d0,d0
CD12C:
	rts

CD12E:
	bsr.b	IncIff_calcBODYsize
	add.l	d0,(INSTRUCTION_ORG_PTR-DT,a4)
	br	IncIff_skip2nexthunk

IncIff_calcBODYsize:
	moveq	#0,d0
	move.b	(IFFnrplanes-DT,a4),d0
	cmp.b	#1,(IFFmask-DT,a4)
	bne.b	CD148
	addq.w	#1,d0
CD148:
	move	(IFFbreed-DT,a4),d1
	add	#8,d1
	and	#$FFF0,d1
	lsr.w	#3,d1
	mulu	d1,d0
	move	(IFFhoog-DT,a4),d1
	mulu	d1,d0
	rts

IncIff_BODY:
	tst	(IFFhoog-DT,a4)
	beq	IncIff_geenBMHD
	tst	d7	;passone
	bmi.w	CD12E

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
	move.l	(4).w,a6
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
	moveq	#0,d1
	move	(IFFhoog-DT,a4),d1
	moveq	#0,d0
	move	(IFFbreed-DT,a4),d0
	move.l	d0,d5
	lsr.l	#3,d0
	move.l	d0,d6
	lsl.l	#3,d6
	cmp	d6,d5
	beq.b	CD1E8
	addq.w	#1,d0
CD1E8:
	move	d0,d3
	lsr.w	#1,d3
	lsl.w	#1,d3
	cmp	d0,d3
	beq.b	CD1F4
	addq.w	#1,d0
CD1F4:
	move.l	d0,(L2FD24-DT,a4)
	mulu	d1,d0
	moveq	#0,d3
	move.l	d0,(L2FD28-DT,a4)
	tst.b	(IFFcompressed-DT,a4)
	bne.b	IncIff_decompressPic

	move.l	(IncIFF_BODYbuffer2-DT,a4),a0
	move.l	(IncIFF_BODYbuffer-DT,a4),a1
	bsr	IncIff_calcBODYsize
	lea	(a1,d0.l),a2
.copylopje:
	move.b	(a0)+,(a1)+
	cmp.l	a1,a2
	bgt.b	.copylopje

	movem.l	(sp)+,d0-d7/a0-a6
	br	IncIff_Opnieuwzoeken

IncIff_decompressPic:
	move.l	(IncIFF_BODYbuffer2-DT,a4),a0
	move.l	(IncIFF_BODYbuffer-DT,a4),a1
	bsr	IncIff_calcBODYsize
	lea	(a1,d0.l),a2
.Decr_lop:
	moveq	#0,d6
	move.b	(a0)+,d6
	tst.b	d6
	bmi.b	.Same
	bpl.b	.Copy
.Check_if_klaar:
	cmp.l	a1,a2
	bgt.b	.Decr_lop
.next:
	movem.l	(sp)+,d0-d7/a0-a6
	br	IncIff_Opnieuwzoeken

.Same:
	neg.b	d6
	move.b	(a0)+,d0
.copylopje:
	move.b	d0,(a1)+
	cmp.l	a1,a2
	ble.b	.next
	dbra	d6,.copylopje
	bra.b	.Check_if_klaar

.Copy:
	move.b	(a0)+,(a1)+
	cmp.l	a1,a2
	ble.b	.next
	dbra	d6,.Copy
	bra.b	.Check_if_klaar

IncIff_readerror:
	move.l	d7,-(sp)
	moveq	#-2,d7
	jsr	(close_bestand).l
	move.l	(sp)+,d7
	tst	d7	;passone
	bmi.b	CD27A
	bsr	CD28A
CD27A:
	bsr	CD3EE
	move.l	(L0D4C8).l,a6
	movem.l	(sp)+,d0-d7/a0-a5
	rts

CD28A:
	move.b	(IncIff_colmap_pos-DT,a4),d0
	and.b	#15,d0
	cmp.b	#1,d0
	bne.b	CD29C
	bsr	CD318
CD29C:
	tst.b	(IncIff_tiepe-DT,a4)
	beq.b	CD2B4
	move.l	(IncIFF_BODYbuffer-DT,a4),a0
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),a1
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a1
	bsr	CD46E
	bra.b	CD2CE

CD2B4:
	move.l	(IncIFF_BODYbuffer-DT,a4),a0
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),a1
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a1
	bsr	IncIff_calcBODYsize
	move.l	d0,d6
CD2C6:
	move.b	(a0)+,(a1)+
	subq.l	#1,d6
	tst.l	d6
	bne.b	CD2C6
CD2CE:
	bsr	IncIff_calcBODYsize
	add.l	d0,(INSTRUCTION_ORG_PTR-DT,a4)
	move.b	(IncIff_colmap_pos-DT,a4),d0
	and.b	#15,d0
	cmp.b	#2,d0
	bne.b	CD2E8
	bsr	CD318
CD2E8:
	bsr	IncIff_calcBODYsize
	move.l	d0,d3
	tst.b	(IncIff_colmap_pos-DT,a4)
	beq.b	CD2FA
	bsr	CD118
	add.l	d3,d0
CD2FA:
	move.l	d0,(FileLength-DT,a4)
	lea	(HInciff.MSG).l,a0
	jsr	(PRINTINCLUDENAME).l
	move.l	d7,-(sp)
	moveq	#-1,d7
	jsr	(C183DC).l
	move.l	(sp)+,d7
	rts

CD318:
	lea	(L2FD32-DT,a4),a0
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),a1
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a1
	move.l	a1,d6
	btst	#0,d6
	bne	ERROR_WordatOddAddress
	moveq	#0,d6
	move	(IFFnrplanes-DT,a4),d6
	moveq	#1,d6
	lsl.w	d5,d6
	subq.w	#1,d6
	tst.b	(IncIff_colmap_pos-DT,a4)
	bmi.b	CD36E
CD340:
	moveq	#0,d0
	move.b	(a0)+,d0
	and.b	#$F0,d0
	move.b	(a0)+,d1
	and	#$00F0,d1
	lsr.w	#4,d1
	or.w	d1,d0
	lsl.w	#4,d0
	move.b	(a0)+,d1
	and	#$00F0,d1
	lsr.w	#4,d1
	or.w	d1,d0
	move	d0,(a1)+
	dbra	d6,CD340
	bsr	CD118
	add.l	d0,(INSTRUCTION_ORG_PTR-DT,a4)
	rts

CD36E:
	moveq	#0,d0
	move.b	(a0)+,d0
	move.b	d0,d1
	and	#$00F0,d0
	and	#15,d1
	lsl.w	#4,d1
	move.b	(a0)+,d2
	move.b	d2,d3
	and	#$00F0,d2
	and	#15,d3
	lsr.w	#4,d2
	or.w	d2,d0
	or.w	d3,d1
	lsl.w	#4,d0
	lsl.w	#4,d1
	move.b	(a0)+,d2
	move.b	d2,d3
	and	#$00F0,d2
	and	#15,d3
	lsr.w	#4,d2
	or.w	d2,d0
	or.w	d3,d1
	move	d0,(a1)+
	move	d1,(a1)+
	dbra	d6,CD36E
	bsr	CD118
	add.l	d0,(INSTRUCTION_ORG_PTR-DT,a4)
	rts

IncIff_noFORM:
	move.l	d7,-(sp)
	moveq	#-2,d7
	jsr	(close_bestand).l
	move.l	(sp)+,d7
	bsr.b	CD3EE
	br	ERROR_TryingtoincludenonILBM

IncIff_noILBM:
	move.l	d7,-(sp)
	moveq	#-2,d7
	jsr	(close_bestand).l
	move.l	(sp)+,d7
	bsr.b	CD3EE
	br	ERROR_IFFfileisnotaILBM

IncIff_geenBMHD:
	move.l	d7,-(sp)
	moveq	#-2,d7
	jsr	(close_bestand).l
	move.l	(sp)+,d7
	bsr.b	CD3EE
	br	ERROR_CanthandleBODYbBMHD

CD3EE:
	move.l	(buffer_ptr-DT,a4),a1
	cmp.l	#0,a1
	beq.b	CD414
	move.l	#$00001000,d0
	move.l	a6,-(sp)
	move.l	(4).w,a6
	jsr	(_LVOFreeMem,a6)
	move.l	(sp)+,a6
	move.l	#0,(buffer_ptr-DT,a4)
CD414:
	move.l	(IncIFF_BODYbuffer2-DT,a4),a1
	cmp.l	#0,a1
	beq.b	CD440
	move.l	(IncIffBuf2Size-DT,a4),d0
	move.l	a6,-(sp)
	move.l	(4).w,a6
	jsr	(_LVOFreeMem,a6)
	move.l	(sp)+,a6
	move.l	#0,(IncIFF_BODYbuffer2-DT,a4)
	move.l	#0,(IncIffBuf2Size-DT,a4)
CD440:
	move.l	(IncIFF_BODYbuffer-DT,a4),a1
	cmp.l	#0,a1
	beq.b	CD46C
	move.l	(IncIffBuf1Size-DT,a4),d0
	move.l	a6,-(sp)
	move.l	(4).w,a6
	jsr	(_LVOFreeMem,a6)
	move.l	(sp)+,a6
	move.l	#0,(IncIFF_BODYbuffer-DT,a4)
	move.l	#0,(IncIffBuf1Size-DT,a4)
CD46C:
	rts

CD46E:
	moveq	#0,d0
	move.b	(IFFnrplanes-DT,a4),d0
	cmp.b	#1,(IFFmask-DT,a4)
	bne	CD480
	addq.w	#1,d0
CD480:
	move	(IFFbreed-DT,a4),d1
	add	#8,d1
	and	#$FFF0,d1
	lsr.w	#3,d1
	move	(IFFhoog-DT,a4),d2
	move	d0,d6
	subq.w	#1,d6
CD496:
	move	d2,d5
	subq.w	#1,d5
CD49A:
	move	d1,d4
	subq.w	#1,d4
CD49E:
	move.b	(a0)+,(a1)+
	dbra	d4,CD49E
	move	d0,d3
	subq.w	#1,d3
	mulu	d1,d3
	lea	(a0,d3.l),a0
	dbra	d5,CD49A
	move	d0,d3
	mulu	d1,d3
	mulu	d2,d3
	neg.l	d3
	lea	(a0,d3.l),a0
	lea	(a0,d1.l),a0
	dbra	d6,CD496
	rts

L0D4C8:
	dc.l	0

Asm_PRINTT:
	lea	(SourceCode-DT,a4),a1
	bsr	C1098A
	tst	d7	;passone
	bmi.b	CD4E8


	lea	(SourceCode-DT,a4),a0
	jsr	(printthetext).l
	jsr	(druk_cr_nl).l
	jsr	Druk_Clearbuffer
CD4E8:
	bsr	PARSE_GET_KOMMA_IF_ANY
	bpl.b	Asm_PRINTT
	rts

CD4F0:
	bsr	Parse_GetExprValueInD3Voor
	tst	d7	;passone
	bmi.b	CD4FE
	move.l	d3,d0
	bsr	com_calculator
CD4FE:
	bsr	PARSE_GET_KOMMA_IF_ANY
	bpl.b	CD4F0
	rts

Parse_GetKomma:
	cmp.b	#',',(a6)+
	bne	ERROR_Commaexpected
	moveq	#0,d0
CD510:
	move.b	(a6)+,d0
	tst.b	(Variable_base-DT,a4,d0.w)
	bmi.w	CD510
	subq.w	#1,a6
	rts

CD51E:
	bsr	Parse_GetExprValueInD3Voor
	move.l	d3,-(sp)
	move	d2,-(sp)
	bmi.w	ERROR_Linkerlimitation
	bsr	Parse_GetKomma
	jsr	(AdresOfDataReg).l
	tst	d5
	beq	ERROR_AddressRegExp
	bset	#AF_OFFSET_A4,d7
	subq.b	#8,d1
	bset	d1,(BASEREG_BYTE-DT,a4)
	bne	ERROR_Doubledefinition
	add	d1,d1
	move	d1,d0
	add	d1,d1
	add	d0,d1
	lea	(BASEREG_BASE-DT,a4),a0
	add	d1,a0
	move	(sp)+,(a0)+
	move.l	(sp)+,(a0)+
	rts

CD55C:
	jsr	(AdresOfDataReg).l
	tst	d5
	beq	ERROR_AddressRegExp
	bset	#AF_OFFSET_A4,d7
	subq.b	#8,d1
	bclr	d1,(BASEREG_BYTE-DT,a4)
	add	d1,d1
	move	d1,d0
	add	d1,d1
	add	d0,d1
	lea	(BASEREG_BASE-DT,a4),a0
	add	d1,a0
	move	#0,(a0)+
	move.l	#0,(a0)+
	rts

CD58C:
	jsr	(Parse_GetDefinedValue).l
	cmp.l	#0,d3
	bmi.w	ERROR_Repeatoverflow
	move	(REPT_LEVEL-DT,a4),d0
	cmp	#MAX_REPT_LEVEL,d0
	bcc.w	ERROR_Repeatoverflow
	addq.w	#1,(REPT_LEVEL-DT,a4)
	mulu.w	#14,d0
	lea	(REPT_STACK-DT,a4),a0
	add	d0,a0
	move	(CurrentSection-DT,a4),d1
	tst	(MACRO_LEVEL-DT,a4)
	bne.b	CD5DE
	move.l	a6,(a0)+
CD5C8:
	tst	(INCLUDE_LEVEL-DT,a4)
	beq.b	CD5D2
	or.w	#$0100,d1
CD5D2:
	move.l	(DATA_CURRENTLINE-DT,a4),(a0)+
	move	d1,(a0)+	;section
	move.l	d3,(a0)+

; Make REPT 0 skip its contents

	bne.b	.notrept0
	move.l	(Asm_Table_Base-DT,a4),-14(a0)
	lea.l	ConditionAssembl(pc),a0
	move.l	a0,(Asm_Table_Base-DT,a4)
	bset	#AF_IF_FALSE,d7
.notrept0:
	rts

CD5DE:
	or.w	#$8000,d1
;	move	(MACRO_LEVEL-DT,a4),(W2F250-DT,a4)
	move.l	($0010,sp),(a0)+
	bra.b	CD5C8

CD5EE:
	move	(REPT_LEVEL-DT,a4),d0
	beq	ERROR_NotinRepeatar
	subq.w	#1,d0
	mulu.w	#14,d0
	lea	(REPT_STACK-DT,a4),a0
	add	d0,a0
	subq.l	#1,(10,a0)
	beq.b	CD64C

; Make REPT 0 skip its contents

	bpl.b	.notrept0
	move.l	(a0),(Asm_Table_Base-DT,a4)
	bclr	#AF_IF_FALSE,d7
	bra.b	CD64C
.notrept0:

	move	(CurrentSection-DT,a4),d1
	tst	(MACRO_LEVEL-DT,a4)
	beq.b	CD61C
	or.w	#$8000,d1
CD61C:
	tst	(INCLUDE_LEVEL-DT,a4)
	beq.b	CD626
	or.w	#$0100,d1
CD626:
	move	(8,a0),d0
	cmp	d1,d0
	bne	ERROR_NotinRepeatar
	clr.b	d0
	tst	d0
	bne.b	CD63E
	move.l	(4,a0),(DATA_CURRENTLINE-DT,a4)
CD63E:
	tst	d0
	bmi.b	CD646
	move.l	(a0),a6
	rts

CD646:
	move.l	(a0),($0010,sp)
	rts

CD64C:
	subq.w	#1,(REPT_LEVEL-DT,a4)
	rts

;*********** INCBIN ********************

IncBinStuff:
	lea	(SourceCode-DT,a4),a1
	bsr	OntfrutselNaam
	jsr	(MenNemeNaamEnPad).l
	bsr	PARSE_GET_KOMMA_IF_ANY
	bne.b	CD670
	jsr	(Parse_GetDefinedValue).l
	move.l	d3,d0
	bra.b	CD67A

CD670:
	move.l	a6,-(sp)
	jsr	(GetDiskFileLengte).l
	move.l	(sp)+,a6
CD67A:
	btst	#AF_BRATOLONG,d7
	bne.b	CD6CA
	tst	d7	;passone
	bmi.b	CD6CA
	lea	(HIncbin.MSG).l,a0
	jsr	(PRINTINCLUDENAME).l
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
	moveq.l	#-1,d7
	jsr	(close_bestand).l
	move.l	(sp)+,d7
	movem.l	(sp)+,d0/a6
CD6CA:
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

CD706:
	jsr	(AdresOfDataReg).l
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

CD730:
	jsr	(AdresOfDataReg).l
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
	jsr	(Get_NextChar).l
	cmp.b	#$62,d1
	bne	ERROR_IllegalOperand
	jsr	(C4F62).l
	bsr	PARSE_GET_KOMMA_IF_ANY
	beq.b	CD75C
	rts

CD778:
	tst	d7	;passone
	bmi.b	CD7C4
CD77C:
	jsr	(Get_NextChar).l
	cmp.b	#$62,d1
	bne	ERROR_IllegalOperand
	move.l	a1,-(sp)
	lea	(XDefTreePtr-DT,a4),a2
	lea	(SourceCode-DT,a4),a3
	jsr	(Parse_FindlabelNoSupertree).l
	beq	ERROR_UndefSymbol
	move.l	(sp)+,a1
	move.l	a0,-(sp)
	jsr	(Parse_FindLabel).l
	beq	ERROR_UndefSymbol
	tst	d2
	bmi.w	ERROR_Linkerlimitation
	move.l	(sp)+,a0
	move.l	d3,-(a0)
	bclr	#14,d2
	move	d2,-(a0)
	bsr	PARSE_GET_KOMMA_IF_ANY
	beq.b	CD77C
	rts

CD7C4:
	jsr	(Get_NextChar).l
	cmp.b	#$62,d1
	bne	ERROR_IllegalOperand
	lea	(XDefTreePtr-DT,a4),a2
	lea	(SourceCode-DT,a4),a3
	jsr	(Parse_FindlabelNoSupertree).l
	bne	ERROR_DoubleSymbol
	jsr	(C4F3C).l
	move	d0,(a0)+
	move.l	d0,(a0)+
	move.l	a0,(LabelEnd-DT,a4)
	bsr	PARSE_GET_KOMMA_IF_ANY
	beq.b	CD7C4
	rts

CD7FA:
	clr	(PageLinesLeft-DT,a4)
	bset	#0,(PR_Paging).l
	rts

CD808:
	bclr	#0,(PR_Paging).l
	rts

CD812:
	bset	#AF_LISTFILE,d7
	rts

CD818:
	bclr	#AF_LISTFILE,d7
	rts

CD81E:
	jsr	(Parse_GetDefinedValue).l
	cmp	#$003C,d3
	blt.w	ERROR_Outofrange60t
	cmp	#$0084,d3
	bgt.w	ERROR_Outofrange60t
	move	d3,(PageWidth-DT,a4)
	rts

CD83A:
	jsr	(Parse_GetDefinedValue).l
	cmp	#$0014,d3
	blt.w	ERROR_Outofrange20t
	cmp	#$0064,d3
	bgt.w	ERROR_Outofrange20t
	move	(PageHeight-DT,a4),d0
	sub	d3,d0
	move	d3,(PageHeight-DT,a4)
	sub	d0,(PageLinesLeft-DT,a4)
	rts

CD860:
	jsr	(Parse_GetDefinedValue).l
	tst.l	d3
	beq.b	CD876
	tst	d7	;passone
	bmi.b	CD876
CD86E:
	jsr	druk_cr_nl
	subq.l	#1,d3
	bne.b	CD86E
CD876:
	rts

CD878:
	lea	(TITLE_STRING-DT,a4),a1
	br	C1098A

CD880:
	lea	(IDNT_STRING-DT,a4),a1
	br	C1098A

CD888:
	move.l	a5,a6
	rts

CD88C:
	jsr	(ASSEM_RESTORE_OLD_SECTION).l
	bclr	#AF_OFFSET,d7
	bsr	C10968
	lea	(SectionTreePtr-DT,a4),a2
	lea	(SourceCode-DT,a4),a3
	jsr	(Parse_FindlabelNoSupertree).l
	bne.b	CD8D4
	tst	d7	;passone
	bpl.w	ERROR_IllegalOperand
	jsr	(C4F3C).l
	move.l	a0,-(sp)
	jsr	(C528C).l
	jsr	(C29D2).l
	move.l	(sp)+,a0
	move	(CurrentSection-DT,a4),(a0)+
	move.l	a0,(LabelEnd-DT,a4)
	jmp	(SET_LAST_LABEL_TO_ORG_PTR).l

CD8D4:
	move	d2,d0
	jsr	(C29EE).l
	jsr	(SET_LAST_LABEL_TO_ORG_PTR).l
	jsr	(C528C).l
	beq.b	CD8F8
	move.b	(CURRENT_SECTION_TYPE-DT,a4),d0
	and.b	#$BF,d0
	cmp.b	d0,d6
	bne	ERROR_DoubleSymbol
CD8F8:
	rts

CD8FA:
	jsr	(ASSEM_RESTORE_OLD_SECTION).l
	bclr	#AF_OFFSET,d7
	moveq	#0,d0
	jsr	(C29F2).l
	jsr	(Parse_GetDefinedValue).l
	clr.l	(CURRENT_ABS_ADDRESS-DT,a4)
	move.l	d3,(INSTRUCTION_ORG_PTR-DT,a4)
	jmp	(SET_LAST_LABEL_TO_ORG_PTR).l

CD920:
	tst	(CurrentSection-DT,a4)
	bne	ERROR_LOADwithoutOR
	jsr	(Parse_GetDefinedValue).l
	tst	d7	;passone
	bmi.b	CD93A
	sub.l	(INSTRUCTION_ORG_PTR-DT,a4),d3
	move.l	d3,(CURRENT_ABS_ADDRESS-DT,a4)
CD93A:
	rts

CD93C:
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),d0
	btst	#0,d0
	beq.b	CD950
	moveq	#1,d5
	moveq	#0,d3
	moveq	#0,d2
	bsr	CDBAC
CD950:
	rts

CD952:
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),d0
	btst	#0,d0
	bne.b	CD966
	moveq	#1,d5
	moveq	#0,d3
	moveq	#0,d2
	bsr	CDBAC
CD966:
	rts

CD968:
	tst.b	(PR_OddData).l
	beq.b	CD978
	cmp	#1,(ProcessorType-DT,a4)
	bgt.b	CD982
CD978:
	btst	#0,(SECTION_TREE_PTR_Byte-DT,a4)
	bne	ERROR_WordatOddAddress
CD982:
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),(Binary_Offset-DT,a4)
CD988:
	jsr	(C3778).l
	bsr	C755A
	move.l	(Binary_Offset-DT,a4),(INSTRUCTION_ORG_PTR-DT,a4)
	bsr	PARSE_GET_KOMMA_IF_ANY
	bpl.b	CD988
	rts

CD9A0:
	tst.b	(PR_OddData).l
	beq.b	CD9B0
	cmp	#1,(ProcessorType-DT,a4)
	bgt.b	CD9BA
CD9B0:
	btst	#0,(SECTION_TREE_PTR_Byte-DT,a4)
	bne	ERROR_WordatOddAddress
CD9BA:
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),(Binary_Offset-DT,a4)
CD9C0:
	jsr	(C3778).l
	bsr	Store_DataLongReloc
	move.l	(Binary_Offset-DT,a4),(INSTRUCTION_ORG_PTR-DT,a4)
	bsr	PARSE_GET_KOMMA_IF_ANY
	bpl.b	CD9C0
	rts

CD9D8:
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),(Binary_Offset-DT,a4)
CD9DE:
	jsr	(C3778).l
	bsr	Parse_IetsMetExtentionWord
	move.l	(Binary_Offset-DT,a4),(INSTRUCTION_ORG_PTR-DT,a4)
	bsr	PARSE_GET_KOMMA_IF_ANY
	bpl.b	CD9DE
	rts

CD9F6:
	tst.b	(PR_OddData).l
	beq.b	CDA06
	cmp	#1,(ProcessorType-DT,a4)
	bgt.b	CDA10
CDA06:
	btst	#0,(SECTION_TREE_PTR_Byte-DT,a4)
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
	cmp	#1,(ProcessorType-DT,a4)
	bgt.b	CDA4C
CDA42:
	btst	#0,(SECTION_TREE_PTR_Byte-DT,a4)
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
	cmp	#1,(ProcessorType-DT,a4)
	bgt.b	CDA88
CDA7E:
	btst	#0,(SECTION_TREE_PTR_Byte-DT,a4)
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
	cmp	#1,(ProcessorType-DT,a4)
	bgt.b	CDAC4
CDABA:
	btst	#0,(SECTION_TREE_PTR_Byte-DT,a4)
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
	cmp	#1,(ProcessorType-DT,a4)
	bgt.b	CDB00
CDAF6:
	btst	#0,(SECTION_TREE_PTR_Byte-DT,a4)
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
	cmp	#1,(ProcessorType-DT,a4)
	bgt.b	CDB36
CDB2C:
	btst	#0,(SECTION_TREE_PTR_Byte-DT,a4)
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

CDB52:
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
	bpl.b	CDBB6
	add.l	d5,(INSTRUCTION_ORG_PTR-DT,a4)
	rts

CDBB6:
	subq.l	#1,d5
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
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
	tst	(Asm_OffsetCheck).l
	bne.b	CDBFA
	clr	(Asm_OffsetCheck).l
CDBE2:
	move.b	d3,(a0)+
	dbra	d5,CDBE2
	sub.l	#$00010000,d5
	bpl.b	CDBE2
CDBF0:
	sub.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
	move.l	a0,(INSTRUCTION_ORG_PTR-DT,a4)
CDBF8:
	rts

CDBFA:
	add.l	d5,a0
	addq.w	#1,a0
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
	fmove.l	#0,fp0
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
	cmp	#1,(ProcessorType-DT,a4)
	bgt.b	CDC6E
CDC64:
	btst	#0,(SECTION_TREE_PTR_Byte-DT,a4)
	bne	ERROR_WordatOddAddress
CDC6E:
	add.l	d5,(INSTRUCTION_ORG_PTR-DT,a4)
	rts

CDC74:
	tst.b	(PR_OddData).l
	beq.b	CDC84
	cmp	#1,(ProcessorType-DT,a4)
	bgt.b	CDC8E
CDC84:
	btst	#0,(SECTION_TREE_PTR_Byte-DT,a4)
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
	fmove.l	#0,fp0
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
	cmp	#1,(ProcessorType-DT,a4)
	bgt.b	CDCFE
CDCF4:
	btst	#0,(SECTION_TREE_PTR_Byte-DT,a4)
	bne	ERROR_WordatOddAddress
CDCFE:
	add.l	d5,(INSTRUCTION_ORG_PTR-DT,a4)
	rts

CDD04:
	tst.b	(PR_OddData).l
	beq.b	CDD14
	cmp	#1,(ProcessorType-DT,a4)
	bgt.b	CDD1E
CDD14:
	btst	#0,(SECTION_TREE_PTR_Byte-DT,a4)
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
	fmove.l	#0,fp0
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
	cmp	#1,(ProcessorType-DT,a4)
	bgt.b	CDD94
CDD8A:
	btst	#0,(SECTION_TREE_PTR_Byte-DT,a4)
	bne	ERROR_WordatOddAddress
CDD94:
	add.l	d5,(INSTRUCTION_ORG_PTR-DT,a4)
	rts

CDD9A:
	tst.b	(PR_OddData).l
	beq.b	CDDAA
	cmp	#1,(ProcessorType-DT,a4)
	bgt.b	CDDB4
CDDAA:
	btst	#0,(SECTION_TREE_PTR_Byte-DT,a4)
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
	fmove.l	#0,fp0
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
	cmp	#1,(ProcessorType-DT,a4)
	bgt.b	CDE2A
CDE20:
	btst	#0,(SECTION_TREE_PTR_Byte-DT,a4)
	bne	ERROR_WordatOddAddress
CDE2A:
	add.l	d5,(INSTRUCTION_ORG_PTR-DT,a4)
	rts

CDE30:
	tst.b	(PR_OddData).l
	beq.b	CDE40
	cmp	#1,(ProcessorType-DT,a4)
	bgt.b	CDE4A
CDE40:
	btst	#0,(SECTION_TREE_PTR_Byte-DT,a4)
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
	cmp	#1,(ProcessorType-DT,a4)
	bgt.b	CDE9A
CDE90:
	btst	#0,(SECTION_TREE_PTR_Byte-DT,a4)
	bne	ERROR_WordatOddAddress
CDE9A:
	add.l	d5,(INSTRUCTION_ORG_PTR-DT,a4)
	rts

CDEA0:
	tst.b	(PR_OddData).l
	beq.b	CDEB0
	cmp	#1,(ProcessorType-DT,a4)
	bgt.b	CDEBA
CDEB0:
	btst	#0,(SECTION_TREE_PTR_Byte-DT,a4)
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
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
	tst	(Asm_OffsetCheck).l
	bne.b	CDEF8
CDEE0:
	move	d3,(a0)+
	dbra	d5,CDEE0
	sub.l	#$00010000,d5
	bpl.b	CDEE0
CDEEE:
	sub.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
	move.l	a0,(INSTRUCTION_ORG_PTR-DT,a4)
CDEF6:
	rts

CDEF8:
	add.l	d5,a0
	add.l	d5,a0
	addq.w	#2,a0
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

CDF24:
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
	cmp	#1,(ProcessorType-DT,a4)
	bgt.b	CDF64
CDF5A:
	btst	#0,(SECTION_TREE_PTR_Byte-DT,a4)
	bne	ERROR_WordatOddAddress
CDF64:
	add.l	d5,(INSTRUCTION_ORG_PTR-DT,a4)
	rts

CDF6A:
	tst	d7	;passone
	bpl.w	CDFC4
	asl.l	#3,d5
	tst.b	(PR_OddData).l
	beq.b	CDF82
	cmp	#1,(ProcessorType-DT,a4)
	bgt.b	CDF8C
CDF82:
	btst	#0,(SECTION_TREE_PTR_Byte-DT,a4)
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
	cmp	#1,(ProcessorType-DT,a4)
	bgt.b	CDFBE
CDFB4:
	btst	#0,(SECTION_TREE_PTR_Byte-DT,a4)
	bne	ERROR_WordatOddAddress
CDFBE:
	add.l	d5,(INSTRUCTION_ORG_PTR-DT,a4)
	rts

CDFC4:
	tst.b	(PR_OddData).l
	beq.b	CDFD4
	cmp	#1,(ProcessorType-DT,a4)
	bgt.b	CDFDE
CDFD4:
	btst	#0,(SECTION_TREE_PTR_Byte-DT,a4)
	bne	ERROR_WordatOddAddress
CDFDE:
	subq.l	#1,d5
	bmi.b	CE00E
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),a0
	tst	d2
	bne.b	CE024
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
	tst	(Asm_OffsetCheck).l
	bne.b	CE010
CDFF6:
	move.l	d3,(a0)+
	move.l	d3,(a0)+
	dbra	d5,CE122
	sub.l	#$00010000,d5
	bpl.b	CDFF6
CE006:
	sub.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
	move.l	a0,(INSTRUCTION_ORG_PTR-DT,a4)
CE00E:
	rts

CE010:
	add.l	d5,a0
	add.l	d5,a0
	add.l	d5,a0
	add.l	d5,a0
	add.l	d5,a0
	add.l	d5,a0
	add.l	d5,a0
	add.l	d5,a0
	addq.w	#8,a0
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
	cmp	#1,(ProcessorType-DT,a4)
	bgt.b	CE06A
CE060:
	btst	#0,(SECTION_TREE_PTR_Byte-DT,a4)
	bne	ERROR_WordatOddAddress
CE06A:
	subq.l	#1,d5
	bmi.b	CE09C
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),a0
	tst	d2
	bne.b	CE0BC
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
	tst	(Asm_OffsetCheck).l
	bne.b	CE09E
CE082:
	move.l	d3,(a0)+
	move.l	d3,(a0)+
	move.l	d3,(a0)+
	dbra	d5,CE082
	sub.l	#$00010000,d5
	bpl.b	CE082
CE094:
	sub.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
	move.l	a0,(INSTRUCTION_ORG_PTR-DT,a4)
CE09C:
	rts

CE09E:
	add.l	d5,a0
	add.l	d5,a0
	add.l	d5,a0
	add.l	d5,a0
	add.l	d5,a0
	add.l	d5,a0
	add.l	d5,a0
	add.l	d5,a0
	add.l	d5,a0
	add.l	d5,a0
	add.l	d5,a0
	add.l	d5,a0
	lea	(12,a0),a0
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
	cmp	#1,(ProcessorType-DT,a4)
	bgt.b	CE10A
CE100:
	btst	#0,(SECTION_TREE_PTR_Byte-DT,a4)
	bne	ERROR_WordatOddAddress
CE10A:
	subq.l	#1,d5
	bmi.b	CE138
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),a0
	tst	d2
	bne.b	CE146
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
	tst	(Asm_OffsetCheck).l
	bne.b	CE13A
CE122:
	move.l	d3,(a0)+
	dbra	d5,CE122
	sub.l	#$00010000,d5
	bpl.b	CE122
CE130:
	sub.l	(CURRENT_ABS_ADDRESS-DT,a4),a0
	move.l	a0,(INSTRUCTION_ORG_PTR-DT,a4)
CE138:
	rts

CE13A:
	add.l	d5,a0
	add.l	d5,a0
	add.l	d5,a0
	add.l	d5,a0
	addq.w	#4,a0
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

CE16A:
	jsr	(Parse_GetDefinedValue).l
	tst.l	d3
	bmi.w	ERROR_WorkspaceMemoryFull
	move.l	d3,d5
	moveq	#0,d2
	moveq	#0,d3
	tst.b	(PR_DsClear).l
	bne	CDBAC
	st	(Asm_OffsetCheck).l
	br	CDBAC

CE190:
	jsr	(Parse_GetDefinedValue).l
	tst.l	d3
	bmi.w	ERROR_WorkspaceMemoryFull
	move.l	d3,d5
	moveq	#0,d2
	moveq	#0,d3
	tst.b	(PR_DsClear).l
	bne	CDE7A
	st	(Asm_OffsetCheck).l
	br	CDE7A

CE1B6:
	jsr	(Parse_GetDefinedValue).l
	tst.l	d3
	bmi.w	ERROR_WorkspaceMemoryFull
	move.l	d3,d5
	moveq	#0,d2
	moveq	#0,d3
	tst.b	(PR_DsClear).l
	bne	CDF42
	st	(Asm_OffsetCheck).l
	br	CDF42

CE1DC:
	jsr	(Parse_GetDefinedValue).l
	tst.l	d3
	bmi.w	ERROR_WorkspaceMemoryFull
	move.l	d3,d5
	moveq	#0,d2
	moveq	#0,d3
	tst.b	(PR_DsClear).l
	bne	CDF6A
	st	Asm_OffsetCheck
	br	CDF6A

CE202:
	jsr	Parse_GetDefinedValue
	tst.l	d3
	bmi.w	ERROR_WorkspaceMemoryFull
	move.l	d3,d5
	moveq	#0,d2
	moveq	#0,d3
	tst.b	(PR_DsClear).l
	bne	CDF92
	st	Asm_OffsetCheck
	br	CDF92

Asm_EQU:
	bsr	Parse_GetExprValueInD3Voor
	btst	#AF_UNDEFVALUE,d7
	bne	ERROR_UndefSymbol
	move.l	(LAST_LABEL_ADDRESS-DT,a4),d0
	beq	ERROR_IllegalOperatorInBSS
	move.l	d0,a1
	tst	d7	;passone
	bpl.b	CE246

		;jsr	test_debug
	move.l	d3,-(a1)
	move	d2,-(a1)
CE246:
	clr.l	(LAST_LABEL_ADDRESS-DT,a4)
	move.l	d3,(ResponsePtr-DT,a4)
	or.w	#LB_SET,d2
	move	d2,(ResponseType-DT,a4)
	rts

CE258:
	moveq	#0,d2
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),d3
	sub.l	(OFFSET_BASE_ADDRESS-DT,a4),d3
	move.l	(LAST_LABEL_ADDRESS-DT,a4),d0
	beq	ERROR_IllegalOperatorInBSS
	move.l	d0,a1
	tst	d7	;passone
	bpl.b	CE274
	move.l	d3,-(a1)
	move	d2,-(a1)
CE274:
	move.l	d3,(ResponsePtr-DT,a4)
	move	d2,(ResponseType-DT,a4)
	rts

CE27E:
	tst	(MACRO_LEVEL-DT,a4)
	bne	ERROR_UnexpectedEOF
	bclr	#AF_OFFSET,d7
	bset	#AF_FINISHED,d7
	rts

GoGoMacro:
	tst	(INCLUDE_LEVEL-DT,a4)
	bne	CE3A2
	move	#$8000,(ResponseType-DT,a4)
	btst	#AF_LISTFILE,d7
	beq.b	CE2AE
	tst	d7	;passone
	bmi.b	CE2AE
	jsr	(PRINT_ASSEMBLING).l
CE2AE:
	tst.b	(a6)+
	bne.b	CE2AE
	tst	(MACRO_LEVEL-DT,a4)
	bne	ERROR_IllegalMacrod
	tst	d7	;passone
	bpl.b	CE2D4
	btst	#AF_IF_FALSE,d7
	bne.b	CE2D4
	move.l	(LAST_LABEL_ADDRESS-DT,a4),d0
	beq	ERROR_IllegalOperatorInBSS
	move.l	d0,a1
	move.l	a6,-(a1)
	move	#$8000,-(a1)
CE2D4:
	clr.l	(LAST_LABEL_ADDRESS-DT,a4)
CE2D8:
	addq.l	#1,(DATA_CURRENTLINE-DT,a4)
	tst.b	(DATA_CURRENTLINE+3-DT,a4)
	bne.b	CE2E8
	jsr	(messages_get).l
CE2E8:
	btst	#AF_DEBUG1,d7
	beq.b	CE30C
	tst	d7	;passone
	bmi.b	CE30C
;	moveq	#0,d0
	move.l	(DATA_CURRENTLINE-DT,a4),d0
	subq.l	#1,d0
	lsl.l	#2,d0
	move.l	(LabelEnd-DT,a4),a0
	add.l	d0,a0
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),d0
	add.l	(CURRENT_ABS_ADDRESS-DT,a4),d0
	move.l	d0,(a0)
CE30C:
	move.l	a6,(DATA_LINE_START_PTR-DT,a4)
	moveq	#0,d0
	move.b	(a6)+,d0
	tst.b	(Variable_base-DT,a4,d0.w)
	bmi.b	CE34E
	cmp.b	#$1A,d0
	beq	ERROR_UnexpectedEOF
	subq.w	#1,a6
	btst	#AF_LABELCOL,d7
	beq.b	CE388
	jsr	(Get_NextChar).l
	cmp.b	#$62,d1
	bne.b	CE388
	cmp.b	#$3A,d0
	beq.b	CE388
CE33C:
	move.b	(a6)+,d0
	tst.b	(Variable_base-DT,a4,d0.w)
	bmi.b	CE33C
	subq.w	#1,a6
	cmp.b	#$3D,d0
	beq.b	CE388
	bra.b	CE366

CE34E:
	jsr	(NEXTSYMBOL_SPACE).l
	cmp.b	#$62,d1
	bne.b	CE388
	cmp.b	#$3A,d0
	beq.b	CE388
	cmp.b	#$3D,d0
	beq.b	CE388
CE366:
	btst	#AF_LOCALFOUND,d7
	bne.b	CE388
	lea	(SourceCode-DT,a4),a3
	move	#$DFDF,d4
	move	(a3)+,d0
	and	d4,d0
	cmp	#$454E,d0
	bne.b	CE388
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C44D,d0
	beq.b	CE3A0
CE388:
	tst.b	(a6)+
	bne.b	CE388
	btst	#$1D,d7
	beq.b	CE39C
	tst	d7	;passone
	bmi.b	CE39C
	jsr	(PRINT_ASSEMBLING).l
CE39C:
	br	CE2D8

CE3A0:
	rts

CE3A2:
	tst.b	(a6)+
	bne.b	CE3A2
	tst	(MACRO_LEVEL-DT,a4)
	bne	ERROR_IllegalMacrod
	tst	d7	;passone
	bpl.b	CE3C8
	btst	#$1F,d7
	bne.b	CE3C8
	move.l	(LAST_LABEL_ADDRESS-DT,a4),d0
	beq	ERROR_IllegalOperatorInBSS
	move.l	d0,a1
	move.l	a6,-(a1)
	move	#$8000,-(a1)
CE3C8:
	clr.l	(LAST_LABEL_ADDRESS-DT,a4)
CE3CC:
	moveq	#0,d0
	move.b	(a6)+,d0
	tst.b	(Variable_base-DT,a4,d0.w)
	bmi.b	CE40A
	cmp.b	#$1A,d0
	beq	ERROR_UnexpectedEOF
	subq.w	#1,a6
	btst	#AF_LABELCOL,d7
	beq.b	CE444
	jsr	(Get_NextChar).l
	cmp.b	#$62,d1
	bne.b	CE444
	cmp.b	#$3A,d0
	beq.b	CE444
CE3F8:
	move.b	(a6)+,d0
	tst.b	(Variable_base-DT,a4,d0.w)
	bmi.b	CE3F8
	subq.w	#1,a6
	cmp.b	#$3D,d0
	beq.b	CE444
	bra.b	CE422

CE40A:
	jsr	(NEXTSYMBOL_SPACE).l
	cmp.b	#$62,d1
	bne.b	CE444
	cmp.b	#$3A,d0
	beq.b	CE444
	cmp.b	#$3D,d0
	beq.b	CE444
CE422:
	btst	#AF_LOCALFOUND,d7
	bne.b	CE444
	lea	(SourceCode-DT,a4),a3
	move	#$DFDF,d4
	move	(a3)+,d0
	and	d4,d0
	cmp	#$454E,d0
	bne.b	CE444
	move	(a3)+,d0
	and	d4,d0
	cmp	#$C44D,d0
	beq.b	CE44A
CE444:
	tst.b	(a6)+
	bne.b	CE444
	bra.w	CE3CC

CE44A:
	rts

CE44C:
	nop
CE44E:
	tst	(MACRO_LEVEL-DT,a4)
	beq	ERROR_Notinmacro
	bset	#6,d7
	rts

CE45C:
	jsr	(Parse_GetDefinedValue).l
	moveq	#0,d0
	not.w	d0
	and.l	d3,d0
	cmp.l	d3,d0
	bne	ERROR_out_of_range16bit
	move	(MACRO_LEVEL-DT,a4),d1
	beq	ERROR_Notinmacro
	cmp	d0,d1
	bcs.b	CE47E
	bset	#6,d7
CE47E:
	rts

CE480:
	jsr	(Parse_GetDefinedValue).l
	tst.l	d3
	bne	CE59C
	br	CE56A

CE490:
	tst	d7	;passone
	bpl.w	CE59C
	br	CE56A

CE49A:
	tst	d7	;passone
	bmi.w	CE59C
	br	CE56A

CE4A4:
	jsr	(Parse_GetDefinedValue).l
	tst.l	d3
	beq	CE59C
	br	CE56A

CE4B4:
	jsr	(Parse_GetDefinedValue).l
	tst.l	d3
	ble.w	CE59C
	br	CE56A

CE4C4:
	jsr	(Parse_GetDefinedValue).l
	tst.l	d3
	blt.w	CE59C
	br	CE56A

CE4D4:
	jsr	(Parse_GetDefinedValue).l
	tst.l	d3
	bge.w	CE59C
	br	CE56A

CE4E4:
	jsr	(Parse_GetDefinedValue).l
	tst.l	d3
	bgt.w	CE59C
	bra.b	CE56A

CE4F2:
	lea	(SourceCode-DT,a4),a1
	move.l	a1,-(sp)
	bsr	OntfrutselNaam
	bsr	Parse_GetKomma
	lea	(CurrentAsmLine-DT,a4),a1
	move.l	a1,-(sp)
	bsr	OntfrutselNaam
	movem.l	(sp)+,a0/a1
CE50E:
	move.b	(a0)+,d0
	beq.b	CE51A
	cmp.b	(a1)+,d0
	beq.b	CE50E
	sne	d0
	rts

CE51A:
	tst.b	(a1)+
	sne	d0
	rts

CE520:
	bsr.b	CE4F2
	tst.b	d0
	bne.b	CE59C
	bra.b	CE56A

CE528:
	bsr.b	CE4F2
	tst.b	d0
	beq.b	CE59C
	bra.b	CE56A

CE530:
	jsr	(Get_NextChar).l
	cmp.b	#$62,d1
	bne	ERROR_IllegalOperand
	jmp	(Parse_FindLabel).l

CE544:
	bsr.b	CE530
	bne.b	CE56A
	bra.b	CE59C

CE54A:
	bsr.b	CE530
	beq.b	CE56A
	bra.b	CE59C

CE550:
	tst.b	(a6)
	beq.b	CE56A
CE554:
	tst.b	(a6)+
	bne.b	CE554
	subq.w	#1,a6
	bra.b	CE59C

CE55C:
	tst.b	(a6)
	beq.b	CE59C
CE560:
	tst.b	(a6)+
	bne.b	CE560
	subq.w	#1,a6
	br	CE56A

CE56A:
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

CE596:
	tst.b	(a6)+
	bne.b	CE596
	subq.l	#1,a6
CE59C:
	bsr.b	CE56A
CE59E:
	lea	(CondAsmTab2,pc),a0
	move.l	a0,(Asm_Table_Base-DT,a4)
	bset	#$1F,d7
	rts

CE5AC:
	move	(ConditionLevel-DT,a4),d0
	beq	ERROR_IllegalOperatorInBSS
	subq.w	#1,d0
	tst.l	d7
	bpl.b	CE59E
	bra.b	CE5D8

CE5BC:
	move	(ConditionLevel-DT,a4),d0
	beq	ERROR_IllegalOperatorInBSS
CE5C4:
	cmp.b	#$1A,(a6)
	beq.b	CE5D2
	tst.b	(a6)
	beq.b	CE5D2
	addq.w	#1,a6
	bra.b	CE5C4

CE5D2:
	subq.w	#1,d0
	move	d0,(ConditionLevel-DT,a4)
CE5D8:
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
	beq.b	CE5F6
	bset	#$1F,d7
	rts

CE5F6:
	bclr	#$1F,d7
	rts

Asm_AUTO:
	tst	d7	;passone
	bpl.b	.pass1
	move.l	a6,a0
	jsr	(DATAFROMAUTO).l
	move.l	a0,a6
	subq.w	#1,a6
	rts

.pass1:
	tst.b	(a6)+
	bne.b	.pass1
	subq.w	#1,a6
	rts

CE616:
	br	ERROR_UsermadeFAIL

CE61A:
	lea	(INCLUDE_DIRECTORY-DT,a4),a1
	br	incbinsub1

Asm_Include:
	addq.w	#1,(INCLUDE_LEVEL-DT,a4)
	cmp	#MAX_INCLUDE_LEVEL,(INCLUDE_LEVEL-DT,a4)
	bhi.w	ERROR_Includeoverflow
	lea	(SourceCode-DT,a4),a1
	bsr	OntfrutselNaam
	move.l	a6,-(sp)
	jsr	(INCLUDE_POINTER).l
	move.l	a2,a6
	move.l	#1,(ErrorLijnInCode-DT,a4)
CE64A:
	cmp.b	#$1A,(a6)
	beq	CE666
	jsr	(FAST_TRANSLATE_LINE).l
	add.l	#1,(ErrorLijnInCode-DT,a4)
	tst.b	d7
	bpl.w	CE64A
CE666:
	move.l	(sp)+,a6
	subq.w	#1,(INCLUDE_LEVEL-DT,a4)
	rts

CE66E:
	moveq	#0,d0
	jsr	(RemoveWS).l
	beq	ERROR_IllegalsourceNr
	sub	#$0030,d0
	cmp	#0,d0
	blt.w	ERROR_IllegalsourceNr
	cmp	#9,d0
	bgt.w	ERROR_IllegalsourceNr
	cmp.b	(CurrentSource-DT,a4),d0
	beq	ERROR_IncludeSource
	lsl.l	#8,d0
	lea	(SourcePtrs-DT,a4),a0
	lea	(a0,d0.w),a0
	tst.l	(CS_start,a0)
	beq	ERROR_Includingempty
	move.l	a6,-(sp)
	move.l	(CS_start,a0),a6
	move.l	(CS_length,a0),d0
	move.b	#$1A,(a6,d0.l)
	move.l	#1,(ErrorLijnInCode-DT,a4)
CE6C0:
	cmp.b	#$1A,(a6)
	beq	CE6DC
	jsr	(FAST_TRANSLATE_LINE).l
	add.l	#1,(ErrorLijnInCode-DT,a4)
	tst.b	d7
	bpl.w	CE6C0
CE6DC:
	move.l	(sp)+,a6
	rts

CE6E0:
	clr.l	(RS_BASE_OFFSET-DT,a4)
	rts

CE6E6:
	jsr	(Parse_GetDefinedValue).l
	move.l	d3,(RS_BASE_OFFSET-DT,a4)
	rts

CE6F2:
	jsr	(Parse_GetDefinedValue).l
	move.l	(RS_BASE_OFFSET-DT,a4),d1
	add.l	d3,(RS_BASE_OFFSET-DT,a4)
	bra.b	CE72A

CE702:
	jsr	(Parse_GetDefinedValue).l
	move.l	(RS_BASE_OFFSET-DT,a4),d1
	add.l	d3,d3
	add.l	d3,(RS_BASE_OFFSET-DT,a4)
	bra.b	CE72A

CE714:
	jsr	(Parse_GetDefinedValue).l
	move.l	(RS_BASE_OFFSET-DT,a4),d1
	add.l	d3,d3
	add.l	d3,d3
	add.l	d3,(RS_BASE_OFFSET-DT,a4)
	br	CE72A

CE72A:
	move.l	(LAST_LABEL_ADDRESS-DT,a4),d0
	beq.b	CE748
	move.l	d0,a1
	tst	d7	;passone
	bpl.b	CE73A
	move.l	d1,-(a1)
	clr	-(a1)
CE73A:
	clr.l	(LAST_LABEL_ADDRESS-DT,a4)
	move.l	d1,(ResponsePtr-DT,a4)
	move	#LB_SET,(ResponseType-DT,a4)
CE748:
	rts

CE74A:
	jsr	(Parse_GetDefinedValue).l
	move.l	(INSTRUCTION_ORG_PTR-DT,a4),d1
	sub.l	d3,d1
	move.l	d1,(OFFSET_BASE_ADDRESS-DT,a4)
	bset	#$1A,d7
	rts

ASSEM_CMDLABELSET:
	bsr	Parse_GetExprValueInD3Voor
	BTST	#AF_UNDEFVALUE,d7
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
	rts

;;************** PROCESSOR WARNING **************

Processor_warning:
	movem.l	d0-d7/a0-a6,-(sp)
	tst	d7		;passone
	bpl.w	Test_NoProblems

	btst    #AF_PROCESRWARN,d7
	beq.w	Test_NoProblems

	move.l	(DATA_CURRENTLINE-DT,a4),d1
	cmp.l	(Asm_LastErrorPos-DT,a4),d1
	beq	Test_NoProblems

	cmp	#$FFFF,d0
	beq	PB_FPUWarning
	btst	#15,d0		;PB_MMU
	bne	Test_MMU
	btst	#14,d0		;PB_851
	beq.s	.goon

	tst.w	PR_MMU		;mc68851
	bne.w	Test_NoProblems

	btst	#7,d0		;PB_ONLY
	beq.s	.cpu_plus
	and.w	#%111,d0
	cmp.w	(CPU_type-DT,a4),d0	;or 0x0
	beq	Test_NoProblems
	move.w	#0,d0
	br	.in

.cpu_plus
	and.w	#%111,d0
	cmp.w	#PB_030,d0	;or 030+
	bhs.w	Test_NoProblems
	subq.w	#2,d0
.in:
	move.l	d1,(Asm_LastErrorPos-DT,a4)
	mulu	#49,d0
	lea	(Warning68851_030.MSG).l,a0
	bra.b	UpdateShowError

.goon
	btst	#6,d0		;PB_NOT
	bne.b	Test_NotThisCPU

	btst	#7,d0		;PB_ONLY
	bne.b	Test_ThisCPUOnly

;.checkcpu:
	and.w	#%111,d0
	btst	#AF_ALLERRORS,d7
	bne.b	.ShowWarning
	cmp	(CPU_type-DT,a4),d0
	ble.w	Test_NoProblems
.ShowWarning:
	move.l	d1,(Asm_LastErrorPos-DT,a4)
	lea	Warning68010c.MSG,a0
	subq.w	#1,d0
	mulu	#36,d0
	bra.b	UpdateShowError

; command is not available for this cpu
Test_NotThisCPU:
	btst	#AF_ALLERRORS,d7
	bne.b	.PB_ShowCPUWarning
	and	#%111,d0
	cmp	(CPU_type-DT,a4),d0
	bne.b	Test_NoProblems
.PB_ShowCPUWarning:
	move.l	d1,(Asm_LastErrorPos-DT,a4)
	bclr	#7,d0
	subq.w	#1,d0
	mulu	#48,d0		;strlen
	lea	WarningNoAvail.MSG,a0
	bra.b	UpdateShowError

; command is available only for this cpu
Test_ThisCPUOnly:
	btst	#AF_ALLERRORS,d7
	bne.b	.PB_ShowCPUWarning
	and	#%111,d0
	cmp	(CPU_type-DT,a4),d0
	beq.b	Test_NoProblems
.PB_ShowCPUWarning:
	move.l	d1,(Asm_LastErrorPos-DT,a4)
	bclr	#7,d0
	subq.w	#1,d0
	mulu	#43,d0
	lea	(Warning68010s.MSG).l,a0
UpdateShowError:
	lea	(a0,d0.w),a0
	move.l	(AsmErrorPos-DT,a4),a1
	cmp.l	#AsmEindeErrorTable,a1
	bhs.s	Test_NoProblems
	
	move.l	d1,(a1)+	;linenr
	move.l	a0,(a1)+	;warning msg
	move.l	#$FFFFFFFF,(a1)	;end of tabel
	move.l	a1,(AsmErrorPos-DT,a4)
	moveq	#0,d0
	bsr	printthetext
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
	bne.b	.PB_ShowFPUWarning
	tst.b	(PR_FPU_Present).l
	bne.b	Test_NoProblems
.PB_ShowFPUWarning:
	move.l	d1,(Asm_LastErrorPos-DT,a4)
	lea	(Warning688816.MSG).l,a0
	moveq	#0,d0
	bra.b	UpdateShowError

Test_MMU:
	btst	#AF_ALLERRORS,d7
	bne.b	.PB_ShowMMUWarning
	tst.b	(PR_MMU).l
	bne.b	Test_NoProblems
	btst	#14,d0			;PB_MC68851 only
	bne.b	.PB_ShowMMUWarning
	and	#%111,d0
	cmp	(CPU_type-DT,a4),d0
	beq.b	Test_NoProblems

.PB_ShowMMUWarning:
	move.l	d1,(Asm_LastErrorPos-DT,a4)
	lea	(Warning68851c.MSG).l,a0
	moveq	#0,d0
	bra.w	UpdateShowError

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
;		jsr	test_debug

	move	d1,(UsedRegs-DT,a4)
	bsr	Parse_GetKomma
	cmp	#MODE_13,d5
	bcc.w	ERROR_InvalidAddress

;	cmp.w	#$BC01,d6	; check if realy cmp.?
;	bne.s	.nocmp
;	cmp	#MODE_3,d5	;is cmpm
;	beq.w	Asmbl_CmpmViaCmp
;.nocmp:
	cmp	#MODE_9,d5
	beq.b	Asmbl_AddSubCmpImm
	cmp	#MODE_1,d5
	bne.b	CEA0C
   	cmp.w   #PB_APOLLO,(CPU_type-DT,a4)  ;Apollo support byte writes to Ax.
    	beq.b   .ok 		

	tst.b	(OpperantSize-DT,a4)
	beq	ERROR_AddressRegByte
.ok
CEA0C:
	or.b	d6,d5
	tst	d5
	beq.w	CEA84
	jsr	(AdresOfDataReg).l
	and	#7,d1
	add.b	d1,d1
	or.b	d1,(UsedRegs-DT,a4)
	tst	d5
	beq.b	CEA74
CEA26:
	moveq	#0,d0
	move.b	(OpperantSize-DT,a4),d0
    cmp.w   #PB_APOLLO,(CPU_type-DT,a4)  ;Apollo support byte writes to Ax.
    beq.b   .ok 
	tst.b	d0
	beq	ERROR_AddressRegByte
.ok
	lsl.w	#1,d0
	clr.b	d0
	or.w	#$00C0,d0
	and	#$F000,d6
	or.w	(UsedRegs-DT,a4),d6
	or.w	d0,d6

	br	ASM_STORE_INSTRUCTION_HEAD

CEA46:
	and.b	#7,d1
	lsl.b	#1,d1	
	or.b	d1,(UsedRegs-DT,a4)
	bra.b	CEA26

Asmbl_AddSubCmpImm:
	jsr	(asm_noimmediateopp).l
	cmp	#MODE_1,d5
	beq.b	CEA46

	cmp	#MODE_11,d5
	beq.s	.cmp_pc
	cmp	#MODE_9,d5
	bcc.w	ERROR_InvalidAddress
.enter:
	and	#$0F00,d6
	or.b	(OpperantSize-DT,a4),d6
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

.cmp_pc:
;	jsr	test_debug
	cmp.w	#$BC01,d6	;cmpi
	bne.w	ERROR_InvalidAddress

	moveq.l	#PB_020,d0
	bsr	Processor_warning

	bra.b	.enter
	
CEA74:
	and	#$F000,d6
	or.b	(OpperantSize-DT,a4),d6
	or.w	(UsedRegs-DT,a4),d6
	br	ASM_STORE_INSTRUCTION_HEAD

CEA84:
	jsr	(asm_noimmediateopp).l
	cmp	#1,d5
	beq.b	CEA46
	cmp	#$0100,d5
	bcc.w	ERROR_InvalidAddress
	and	#$F000,d6
	or.b	(OpperantSize-DT,a4),d6
	move	(UsedRegs-DT,a4),d0
	tst	d5
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
	tst	d5
	beq	CEB56
    cmp.w   #PB_APOLLO,(CPU_type-DT,a4)  ;Apollo support byte writes to Ax.
    beq.b   .ok 
	
	cmp	#1,d5
	beq	ERROR_AddressRegByte
.ok
	cmp	#$1000,d5
	bcc.w	ERROR_InvalidAddress
	cmp	#$0100,d5
	beq.b	CEB14
	btst	#0,d6
	beq	ERROR_InvalidAddress
	jsr	(AdresOfDataReg).l
    cmp.w   #PB_APOLLO,(CPU_type-DT,a4)  ;APOLLO support byte writes to Ax.
    beq.b   .ok2

	tst	d5
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
    cmp.w   #PB_APOLLO,(CPU_type-DT,a4)  ;APOLLO support byte writes to Ax.
    beq.b   .ok 
    
	cmp	#1,d5
	beq	ERROR_AddressRegByte
.ok
	cmp	#$0100,d5
	bcc.b	CEB36
	and	#$0F00,d6
	or.b	(OpperantSize-DT,a4),d6
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

CEB36:
	cmp	#$1000,d5
	bne	ERROR_InvalidAddress
	move.b	(OpperantSize-DT,a4),d0
	and.b	d1,d0
	cmp.b	(OpperantSize-DT,a4),d0
	bne	ERROR_IllegalSize
	and	#$0F00,d6
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

CEB56:
	jsr	(asm_noimmediateopp).l
    cmp.w   #PB_APOLLO,(CPU_type-DT,a4)  ;APOLLO support byte writes to Ax.
    beq.b   .ok 
	cmp	#1,d5
	beq	ERROR_AddressRegByte
.ok
	cmp	#$0100,d5
	bcc.w	ERROR_InvalidAddress
	move	(UsedRegs-DT,a4),d0
	and	#$F001,d6
	bclr	#0,d6
	beq.b	CEB7E
	tst	d5
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
	tst	d5
	beq.b	CEBAE

	cmp	#8,d5
	bne	ERROR_InvalidAddress
	addq.w	#8,d6
CEBAE:
	and	#7,d1
	or.w	d1,d6
	move	d5,-(sp)
	jsr	(asm_noimmediateopp).l
	cmp	(sp)+,d5
	bne	ERROR_InvalidAddress
	and	#7,d1
	ror.w	#7,d1
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

CEBCE:
	jsr	(AdresOfDataReg).l
	bsr	Parse_GetKomma
	and	#7,d1
	ror.w	#7,d1
	or.w	d1,d6
	move	d5,-(sp)
	jsr	(AdresOfDataReg).l
	or.w	d1,d6
	cmp	(sp)+,d5
	beq	Asm_InsertInstruction
	add	#$0040,d6
	tst	d5
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

CEC0E:
	bsr	Asm_SkipInstructionHead
	jsr	(asm_noimmediateopp).l
	bsr	Parse_GetKomma
	tst	d5
	beq.b	CEC42
	cmp	#$0010,d5
	bne	ERROR_InvalidAddress
	and	#15,d1
	or.w	d1,d6
	jsr	(AdresOfDataReg).l
	tst	d5
	bne	ERROR_Dataregexpect
	ror.w	#7,d1
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

CEC42:
	bset	#7,d6
	ror.w	#7,d1
	or.w	d1,d6
	jsr	(asm_noimmediateopp).l
	cmp	#$0010,d5
	bne	ERROR_InvalidAddress
	and	#15,d1
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

CEC62:
	jsr	(Parse_ImmediateValue).l
	bsr	Parse_GetKomma
	BTST	#AF_UNDEFVALUE,d7
	bne.b	CECBC
	btst	#7,d3
	beq.b	CECA2
	btst	#$1F,d3
	bne.b	CECA2
	lea	(WarningValues.MSG).l,a0
	tst	d7	;passone
	bpl.b	CECA2
	bsr	printthetext
	move.l	(DATA_CURRENTLINE-DT,a4),d0
	beq	CECA2
	move.l	d0,(FirstLineNr-DT,a4)
	move.l	(DATA_LINE_START_PTR-DT,a4),(FirstLinePtr-DT,a4)
	bsr	Drukaf_CurrentLine
CECA2:
	move.b	d3,d0
	ext.w	d0
	ext.l	d0
	cmp.l	d0,d3
	beq.b	CECBA
	move.b	d3,d0
	and.l	#$000000FF,d0
	cmp.l	d3,d0
	bne	ERROR_out_of_range8bit
CECBA:
	or.b	d3,d6
CECBC:
	jsr	(AdresOfDataReg).l
	tst	d5
	bne	ERROR_Dataregexpect
	ror.w	#7,d1
	or.w	d1,d6
	br	Asm_InsertInstruction

CECD0:
	bsr	asm_4bytes_OpperantSize
	jsr	(C38EE).l
	bsr	Parse_GetKomma
	cmp	#$4000,d5
	beq.b	CED08
	and	#$0CF6,d5
	beq	ERROR_InvalidAddress
	or.w	d1,d6
	bset	#10,d6
	jsr	(C38EE).l
	cmp	#$4000,d5
	bne	ERROR_InvalidAddress
	swap	d6
	move	d1,d6
	br	ASM_STORE_LONG

CED08:
	move.l	d1,-(sp)
	jsr	(C38EE).l
	and	#$00FA,d5
	beq	ERROR_InvalidAddress
	cmp	#$003A,d1
	bge.w	ERROR_InvalidAddress
	move.l	(sp)+,d3
	cmp	#8,d5
	bne.b	CED2A
	swap	d3
CED2A:
	or.w	d1,d6
	swap	d6
	move	d3,d6
	br	ASM_STORE_LONG

Asmbl_CMDLEA:
	bsr	Asm_SkipInstructionHead
	jsr	(asm_noimmediateopp).l
	or.w	d1,d6
	bsr	Parse_GetKomma
	and	#MODE_2!MODE_5!MODE_6!MODE_7!MODE_8!MODE_11!MODE_12,d5
	beq	ERROR_InvalidAddress
	jsr	(AdresOfDataReg).l
	tst	d5
	beq	ERROR_AddressRegExp
	subq.w	#8,d1
	ror.w	#7,d1
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

ASSEM_CMDADDQSUBQ:
	bsr	Asm_SkipInstructionHead
	jsr	Parse_ImmediateValue
	BTST	#AF_UNDEFVALUE,d7
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
	cmp	#$0080,d5
	bhi.w	ERROR_InvalidAddress
	cmp	#1,d5
	bne.b	CEDA2
    cmp.w   #PB_APOLLO,(CPU_type-DT,a4)  ;APOLLO support byte writes to Ax.
    beq.b   .ok 
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
	tst	d5
	bne.b	CEDCC
	moveq	#7,d2
	and	d2,d1
	ror.w	d2,d1
	and	#$F0FF,d6
	or.w	d1,d6
	bset	#8,d6
CEDCC:
	and	#$FEFF,d5
	bne	ERROR_InvalidAddress
	bsr	Parse_GetKomma
	jsr	(asm_get_any_opp).l
	move	(sp)+,d0
	tst	d5
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
	and	#$FEFF,d5
CEDFE:
	and	#$F3FF,d5
CEE02:
	cmp.w	#PB_APOLLO,(CPU_type-DT,a4)	;APOLLO support bit ax access
	beq.b	.APOLLO
	and	#$FF01,d5
	bne	ERROR_InvalidAddress
	bra.b	.next
.APOLLO	
	btst.l	#11,d6
	bne.b	.next
	btst.l	#0,d5
	beq.b	.next
	bne	ERROR_InvalidAddress
.next
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

Asmbl_CmpmViaCmp:
	move	#$B108,d6
	or.b	(OpperantSize-DT,a4),d6
	bra.b	Asmbl_CmpmViaCmpCont
	
Asmbl_Cmpm:
	bsr	Asm_SkipInstructionHead
	jsr	(asm_noimmediateopp).l
	bsr	Parse_GetKomma
	cmp	#MODE_3,d5
	bne	ERROR_InvalidAddress
Asmbl_CmpmViaCmpCont:
	and	#7,d1
	or.w	d1,d6
	jsr	(asm_noimmediateopp).l
	cmp	#4,d5
	bne	ERROR_InvalidAddress
	and	#7,d1
	ror.w	#7,d1
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

CEE46:
	bsr	asm_4bytes_OpperantSize
	jsr	(asm_get_any_opp).l
	cmp	#$FFFF,d5
	beq.b	CEE66
	cmp	#1,d5
	bne	ERROR_AddressRegExp
	bset	#10,d6
	or.w	d1,d6
	bra.b	CEE74

CEE66:
	swap	d5
	bclr	#15,d5
	cmp	#5,d5
	bne	ERROR_InvalidAddress
CEE74:
	bsr	Parse_GetKomma
	jsr	(asm_get_any_opp).l
	and	#$7D0D,d5
	bne	ERROR_InvalidAddress
	swap	d6
	or.w	d1,d6
	swap	d6
	br	ASM_STORE_LONG

CEE90:
	bsr	asm_4bytes_OpperantSize
	tst.b	(OpperantSize-DT,a4)
	beq	ASM_STORE_LONG
	jsr	(asm_get_any_opp).l
	cmp	#$0100,d5
	bne	ERROR_Immediateoper
	br	ASM_STORE_LONG

CEEAE:
	jsr	(asm_get_any_opp).l
	cmp	#2,d5
	beq	CEF68
	tst	d5
	beq.b	CEEEC
	cmp	#$0100,d5
	beq.b	CEEDC
	cmp	#$FFFF,d5
	bne	ERROR_InvalidAddress
	swap	d5
	cmp	#1,d5
	bgt.w	ERROR_InvalidAddress
	or.w	d5,d6
	bra.b	CEEF2

CEEDC:
	cmp	#7,d3
	bgt.w	_ERROR_out_of_range3bit
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
	tst	d5
	beq	ERROR_InvalidAddress
	and	#$7D0D,d5
	bne	ERROR_InvalidAddress
	swap	d6
	or.w	d1,d6
	swap	d6
	cmp.b	#$2C,(a6)
	bne	ASM_STORE_LONG
	bsr	Parse_GetKomma
	jsr	(asm_get_any_opp).l
	cmp	#$0100,d5
	bne	ERROR_Immediateoper
	cmp	#7,d3
	bgt.w	_ERROR_out_of_range3bit
	sub.l	#4,(Binary_Offset-DT,a4)
	ror.w	#6,d3
	or.w	d3,d6
	cmp.b	#$2C,(a6)
	bne	ASM_STORE_LONG
	bset	#8,d6
	bsr	Parse_GetKomma
	jsr	(asm_get_any_opp).l
	cmp	#1,d5
	bne	ERROR_AddressRegExp
	lsl.w	#5,d1
	or.w	d1,d6
	br	ASM_STORE_LONG

CEF68:
	move	#$0084,d0
	bsr	Processor_warning
	bsr	Asm_SkipInstructionHead
	btst	#9,d6
	beq.b	CEF88
	move	#$F568,d6
	and	#7,d1
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

CEF88:
	move	#$F548,d6
	and	#7,d1
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

CEF96:
	bsr	asm_4bytes_OpperantSize
	jsr	(asm_get_any_opp).l
    cmp.w   #PB_APOLLO,(CPU_type-DT,a4)  ;APOLLO support byte writes to Ax.
    beq.b   .ok 
	cmp	#1,d5
	beq	ERROR_AddressRegByte
.ok
	cmp	#$0100,d5
	bcc.w	ERROR_InvalidAddress
	swap	d6
	or.w	d1,d6
	swap	d6
	br	ASM_STORE_LONG

CEFBA:
	move	#$8000,d0
	bsr	Processor_warning
	bsr	Asm_SkipInstructionHead
	jsr	(asm_get_any_opp).l
	cmp	#1,d5
	ble.w	ERROR_InvalidAddress
	btst	#6,d6
	beq.b	CEFE8
	cmp	#8,d5
	beq	ERROR_InvalidAddress
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

CEFE8:
	cmp	#4,d5
	beq	ERROR_InvalidAddress
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

Pmove_CrpSrpTc:
	move	#PB_MMU|PB_ONLY,d0	;$0083
	bsr	Processor_warning
	bsr	asm_4bytes_OpperantSize
	jsr	(asm_get_any_opp).l
	cmp	#$FFFF,d5
	bne.b	.read			
	btst	#$1F,d5			;PMOVE	<ea>,MMU-reg
	beq	ERROR_IllegalOperand
	swap	d5
	bclr	#15,d5	;?
	cmp	#7,d5
	beq	ERROR_InvalidAddress
	cmp	#4,d5
	blt.w	ERROR_InvalidAddress

	ror.w	#6,d5
	or.w	d5,d6
	bset	#9,d6			;r/w bit

	bsr	Parse_GetKomma
	jsr	(asm_get_any_opp).l
	cmp	#$0100,d5
	bgt.w	ERROR_InvalidAddress
	swap	d6
	or.w	d1,d6
	swap	d6
	br	ASM_STORE_LONG

.read:					;PMOVE	MMU-reg,<ea>
	swap	d6
	or.w	d1,d6
	swap	d6
	bsr	Parse_GetKomma
	jsr	(asm_get_any_opp).l
	cmp	#$FFFF,d5
	bne	ERROR_IllegalOperand
	btst	#$1F,d5
	beq	ERROR_IllegalOperand
	swap	d5
	bclr	#15,d5
	cmp	#7,d5
	beq	ERROR_InvalidAddress
	cmp	#4,d5
	blt.w	ERROR_InvalidAddress

	ror.w	#6,d5
	or.w	d5,d6

	br	ASM_STORE_LONG

Pmove_MMUSR:
	move.b	#1,(MMUAsmBits-DT,a4)
	move	#PB_851|PB_030|PB_ONLY,d0
	bsr	Processor_warning
	bsr	asm_4bytes_OpperantSize
	jsr	(asm_get_any_opp).l
	cmp	#$FFFF,d5
	bne.b	CF110
	btst	#$1F,d5
	beq	ERROR_IllegalOperand
	swap	d5
	bclr	#15,d5
	cmp	#1,d5
	ble.b	CF0E6
	cmp	#7,d5
	beq	CF0E6
	btst	#14,d5
	beq	ERROR_IllegalOperand
	bclr	#14,d5
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
	cmp	#$0100,d5
	bgt.w	ERROR_InvalidAddress
	swap	d6
	or.w	d1,d6
	swap	d6
	move.b	#0,(MMUAsmBits-DT,a4)
	br	ASM_STORE_LONG

CF110:
	swap	d6
	or.w	d1,d6
	swap	d6
	bsr	Parse_GetKomma
	jsr	(asm_get_any_opp).l
	cmp	#$FFFF,d5
	bne	ERROR_IllegalOperand
	btst	#$1F,d5
	beq	ERROR_IllegalOperand
	swap	d5
	bclr	#15,d5
	cmp	#1,d5
	ble.b	CF162
	cmp	#7,d5
	beq	CF162
	btst	#14,d5
	beq	ERROR_IllegalOperand
	bclr	#14,d5
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
	move.b	#0,(MMUAsmBits-DT,a4)
	br	ASM_STORE_LONG

Pmove_TT0TT1:
	move.b	#1,(MMUAsmBits-DT,a4)
	move	#PB_851|PB_030|PB_ONLY,d0	;$8083
	bsr	Processor_warning
	bsr	asm_4bytes_OpperantSize
	jsr	(asm_get_any_opp).l
	bsr	Parse_GetKomma
	cmp	#$FFFF,d5
	bne.b	CF1E8
	btst	#$1F,d5
	beq	ERROR_IllegalOperand
	swap	d5
	bclr	#15,d5
	tst	d5
	beq.b	CF1B4
	cmp	#2,d5
	beq.b	CF1C2
	cmp	#3,d5
	bne	ERROR_IllegalOperand
	bra.b	CF1C2

CF1B4:
	cmp.b	#$40,(OpperantSize-DT,a4)
	beq	ERROR_IllegalOperand
	bset	#14,d6
CF1C2:
	ror.w	#6,d5
	or.w	d5,d6
	bset	#9,d6
	jsr	(asm_get_any_opp).l
	cmp	#$0100,d5
	bgt.w	ERROR_InvalidAddress
	swap	d6
	or.w	d1,d6
	swap	d6
	move.b	#0,(MMUAsmBits-DT,a4)
	br	ASM_STORE_LONG

CF1E8:
	swap	d6
	or.w	d1,d6
	swap	d6
	jsr	(asm_get_any_opp).l
	cmp	#$FFFF,d5
	bne.b	CF1E8
	btst	#$1F,d5
	beq	ERROR_IllegalOperand
	swap	d5
	bclr	#15,d5
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
	move.b	#0,(MMUAsmBits-DT,a4)
	br	ASM_STORE_LONG

Pmove_CrpSrpTcDouble:
	move.b	#1,(MMUAsmBits-DT,a4)
	move	#$8083,d0
	bsr	Processor_warning
	bsr	asm_4bytes_OpperantSize
	jsr	(asm_get_any_opp).l
	bsr	Parse_GetKomma
	cmp	#$FFFF,d5
	bne	CF29E
	btst	#$1F,d5
	beq	ERROR_IllegalOperand
	swap	d5
	bclr	#15,d5
	tst	d5
	beq	ERROR_IllegalOperand
	cmp	#3,d5
	bgt.w	ERROR_IllegalOperand
	ror.w	#6,d5
	or.w	d5,d6
	bset	#9,d6
	jsr	(asm_get_any_opp).l
	cmp	#$0100,d5
	bgt.w	ERROR_InvalidAddress
	swap	d6
	or.w	d1,d6
	swap	d6
	move.b	#0,(MMUAsmBits-DT,a4)
	br	ASM_STORE_LONG

CF29E:
	cmp	#1,d5
	ble.w	ERROR_InvalidAddress
	swap	d6
	or.w	d1,d6
	swap	d6
	jsr	(asm_get_any_opp).l
	cmp	#$FFFF,d5
	bne	ERROR_IllegalOperand
	btst	#$1F,d5
	beq	ERROR_IllegalOperand
	swap	d5
	bclr	#15,d5
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
	cmp	#$0100,d5
	beq.b	CF304
	tst	d5
	beq.b	CF32C
	cmp	#$FFFF,d5
	bne	ERROR_InvalidAddress
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
	tst	d5
	beq	ERROR_InvalidAddress
	and	#$010D,d5
	bne	ERROR_InvalidAddress
	or.w	d1,d6
	swap	d6
	br	ASM_STORE_LONG

CF35A:
	move	#PB_MMU|PB_851,d0
	bsr	Processor_warning

	bsr	asm_4bytes_OpperantSize
	jsr	(asm_get_any_opp).l
	cmp	#2,d5
	ble.w	ERROR_InvalidAddress
	or.w	d1,d6
	swap	d6
	br	ASM_STORE_LONG

;------------

Asm_HandlePflush:
	jsr	(asm_get_any_opp).l
	cmp	#2,d5
	beq	Asm_PFLUSH040
	cmp	#$0100,d5
	beq.b	.gotimm
	tst	d5
	beq.b	.datareg
	cmp	#$FFFF,d5	;DFC/SFC
	bne	ERROR_InvalidAddress
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
	cmp	#$0100,d5
	bne	ERROR_InvalidAddress

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
	cmp.w	#1,d5
	ble	ERROR_InvalidAddress
	and	#$00D2,d5
	bne	ERROR_InvalidAddress
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
;	move	#$0084,d0
;	bsr	Processor_warning
	bsr	Asm_SkipInstructionHead
	jsr	(asm_noimmediateopp).l
	cmp	#2,d5
	bne	ERROR_InvalidAddress
	bra.b	CF432

;----------

Asm_PFLUSH040:
	bsr	Asm_SkipInstructionHead
	move	#$F508,d6
CF432:
	and	#7,d1
	or.w	d1,d6
	move	#PB_040,d0
	bsr	Processor_warning
	br	ASM_STORE_INSTRUCTION_HEAD

CF43C:
	bsr	asm_4bytes_OpperantSize
	jsr	(AdresOfDataReg).l
	tst	d5
	bne	ERROR_Dataregexpect
	or.w	d1,d6
	swap	d6
	bsr	Parse_GetKomma
	jsr	(C37EE).l
	move	#PB_MMU|PB_851|PB_010,d0
	bsr	Processor_warning
	br	ASM_STORE_LONG

CF466:
	bsr	Asm_SkipInstructionHead
	cmp	#$0040,d5
	beq.b	CF482
	jsr	(C379A).l
	move	#PB_MMU|PB_851|PB_010,d0
	bsr	Processor_warning
	br	ASM_STORE_INSTRUCTION_HEAD

CF482:
	jsr	(C37EE).l
	br	ASM_STORE_INSTRUCTION_HEAD

CF48C:
	bsr	asm_4bytes_OpperantSize
	move.b	#$80,(OpperantSize-DT,a4)
	jsr	(asm_get_any_opp).l
	cmp	#$FFFF,d5
	beq	ERROR_InvalidAddress
	cmp	#1,d5
	beq	ERROR_InvalidAddress
	cmp	#$0100,d5
	bge.w	ERROR_InvalidAddress
	or.w	d1,d6
	swap	d6
	moveq	#-1,d0
	bsr	Processor_warning
	br	ASM_STORE_LONG

CF4C2:
;	moveq	#-1,d0
;	bsr	Processor_warning
	bsr	Asm_SkipInstructionHead
	move.b	#$80,(OpperantSize-DT,a4)
	jsr	(asm_get_any_opp).l
	tst	d5
	beq	ERROR_InvalidAddress
	cmp.b	#$40,d6
	beq.b	CF4F6
	cmp	#$0100,d5
	bge.w	ERROR_InvalidAddress
	and	#$0105,d5
	bne	ERROR_InvalidAddress
	bra.b	CF4FE

CF4F6:
	and	#$0109,d5
	bne	ERROR_InvalidAddress
CF4FE:
	or.w	d1,d6
	moveq	#-1,d0
	bsr	Processor_warning
	br	ASM_STORE_INSTRUCTION_HEAD

CF504:
	moveq	#-1,d0
	bsr	Processor_warning
	bsr	asm_4bytes_OpperantSize
	jsr	(asm_noimmediateopp).l
	move.l	#0,(WorkBuffer1-DT,a4)
	cmp	#$FFFF,d5
	bne	CF5C8
	btst	#$1F,d5
	bne	ERROR_InvalidAddress
	swap	d5
	cmp	#$0010,d5
	beq	CF708
	lsl.w	#5,d5
	move	d5,(WorkBuffer1-DT,a4)
CF53C:
	cmp.b	#$2F,(a6)
	bne.b	CF56C
	addq.w	#1,a6
	jsr	(asm_noimmediateopp).l
	cmp	#$FFFF,d5
	bne	ERROR_IllegalOperand
	btst	#$1F,d5
	bne	ERROR_InvalidAddress
	swap	d5
	cmp	#$0010,d5
	beq	ERROR_IllegalOperand
	lsl.w	#5,d5
	or.w	d5,(WorkBuffer1-DT,a4)
	bra.b	CF53C

CF56C:
	cmp.b	#$2C,(a6)+
	bne	ERROR_Commaexpected
	swap	d6
	or.w	#$A000,d6
	or.w	(WorkBuffer1-DT,a4),d6
	swap	d6
	jsr	(asm_get_any_opp).l
	tst	d5
	bne.b	CF5A8
	cmp	#$0400,(WorkBuffer1-DT,a4)
	beq.b	CF5B8
	cmp	#$0800,(WorkBuffer1-DT,a4)
	beq.b	CF5B8
	cmp	#$1000,(WorkBuffer1-DT,a4)
	beq	CF5B8
	br	ERROR_InvalidAddress

CF5A8:
	cmp	#1,d5
	bne.b	CF5B8
	cmp	#$0400,(WorkBuffer1-DT,a4)
	bne	ERROR_InvalidAddress
CF5B8:
	cmp	#$0039,d1
	bgt.w	ERROR_InvalidAddress
	or.w	d1,d6
	swap	d6
	br	ASM_STORE_LONG

CF5C8:
	tst	d5
	beq	ERROR_InvalidAddress
	and	#9,d5
	bne	ERROR_InvalidAddress
	bsr	Parse_GetKomma
	or.w	d1,d6
	swap	d6
	jsr	(asm_noimmediateopp).l
	cmp	#$FFFF,d5
	bne	ERROR_InvalidAddress
	btst	#$1F,d5
	bne	ERROR_InvalidAddress
	swap	d5
	cmp	#$0010,d5
	beq.b	CF63E
	lsl.w	#5,d5
	move	d5,(WorkBuffer1-DT,a4)
CF602:
	cmp.b	#$2F,(a6)
	bne.b	CF632
	addq.w	#1,a6
	jsr	(asm_noimmediateopp).l
	cmp	#$FFFF,d5
	bne	ERROR_IllegalOperand
	btst	#$1F,d5
	bne	ERROR_InvalidAddress
	swap	d5
	cmp	#$0010,d5
	beq	ERROR_IllegalOperand
	lsl.w	#5,d5
	or.w	d5,(WorkBuffer1-DT,a4)
	bra.b	CF602

CF632:
	or.w	#$8000,d6
	or.w	(WorkBuffer1-DT,a4),d6
	br	ASM_STORE_LONG

CF63E:
	bset	#14,d6
	cmp	(WorkBuffer1-DT,a4),d1
	blt.w	ERROR_IllegalOrder
	move	d1,(WorkBuffer1-DT,a4)
	cmp.b	#$2F,(a6)
	bne.b	CF658
	addq.w	#1,a6
	bra.b	CF6A8

CF658:
	cmp.b	#$2D,(a6)
	bne.b	CF6D8
	addq.w	#1,a6
	jsr	(asm_noimmediateopp).l
	cmp	#$FFFF,d5
	bne	ERROR_IllegalOperand
	btst	#$1F,d5
	bne	ERROR_InvalidAddress
	swap	d5
	cmp	#$0010,d5
	bne	ERROR_IllegalOperand
	cmp	#7,d1
	bgt.w	ERROR_IllegalOperand
	cmp	(WorkBuffer1-DT,a4),d1
	blt.w	ERROR_IllegalOrder
	move	(WorkBuffer1-DT,a4),d5
CF694:
	bset	d5,(WorkBuffer2-DT,a4)
	moveq	#7,d3
	sub	d5,d3
	bset	d3,(WorkBuffer3-DT,a4)
	cmp	d1,d5
	beq.b	CF63E
	addq.w	#1,d5
	bra.b	CF694

CF6A8:
	bset	d1,(WorkBuffer2-DT,a4)
	moveq	#7,d3
	sub	d1,d3
	bset	d3,(WorkBuffer3-DT,a4)
	jsr	(asm_noimmediateopp).l
	cmp	#$FFFF,d5
	bne	ERROR_InvalidAddress
	btst	#$1F,d5
	bne	ERROR_InvalidAddress
	swap	d5
	cmp	#$0010,d5
	bne	ERROR_InvalidAddress
	br	CF63E

CF6D8:
	bset	d1,(WorkBuffer2-DT,a4)
	moveq	#7,d3
	sub	d1,d3
	bset	d3,(WorkBuffer3-DT,a4)
	swap	d6
	move	d6,d5
	swap	d6
	and	#$0038,d5
	cmp	#$0020,d5
	beq.b	CF702
	move.b	(WorkBuffer3-DT,a4),d1
	bset	#12,d6
CF6FC:
	or.b	d1,d6
	br	ASM_STORE_LONG

CF702:
	move.b	(WorkBuffer2-DT,a4),d1
	bra.b	CF6FC

CF708:
	swap	d6
	or.w	#$E000,d6
CF70E:
	cmp	(WorkBuffer1-DT,a4),d1
	blt.w	ERROR_IllegalOrder
	move	d1,(WorkBuffer1-DT,a4)
	cmp.b	#$2F,(a6)
	bne.b	CF724
	addq.w	#1,a6
	bra.b	CF774

CF724:
	cmp.b	#$2D,(a6)
	bne.b	CF7A4
	addq.w	#1,a6
	jsr	(asm_noimmediateopp).l
	cmp	#$FFFF,d5
	bne	ERROR_IllegalOperand
	btst	#$1F,d5
	bne	ERROR_InvalidAddress
	swap	d5
	cmp	#$0010,d5
	bne	ERROR_IllegalOperand
	cmp	#7,d1
	bgt.w	ERROR_IllegalOperand
	cmp	(WorkBuffer1-DT,a4),d1
	blt.w	ERROR_IllegalOrder
	move	(WorkBuffer1-DT,a4),d5
CF760:
	bset	d5,(WorkBuffer2-DT,a4)
	moveq	#7,d3
	sub	d5,d3
	bset	d3,(WorkBuffer3-DT,a4)
	cmp	d1,d5
	beq.b	CF70E
	addq.w	#1,d5
	bra.b	CF760

CF774:
	bset	d1,(WorkBuffer2-DT,a4)
	moveq	#7,d3
	sub	d1,d3
	bset	d3,(WorkBuffer3-DT,a4)
	jsr	(asm_noimmediateopp).l
	cmp	#$FFFF,d5
	bne	ERROR_InvalidAddress
	btst	#$1F,d5
	bne	ERROR_InvalidAddress
	swap	d5
	cmp	#$0010,d5
	bne	ERROR_InvalidAddress
	br	CF70E

CF7A4:
	bset	d1,(WorkBuffer2-DT,a4)
	moveq	#7,d3
	sub	d1,d3
	bset	d3,(WorkBuffer3-DT,a4)
	cmp.b	#$2C,(a6)+
	bne	ERROR_Commaexpected
	jsr	(asm_noimmediateopp).l
	cmp	#$FFFF,d5
	beq	ERROR_InvalidAddress
	tst	d5
	beq	ERROR_InvalidAddress
	cmp	#8,d5
	beq.b	CF7EE
	and	#$0805,d5
	bne	ERROR_InvalidAddress
	swap	d6
	or.w	d1,d6
	swap	d6
	move.b	(WorkBuffer3-DT,a4),d1
	bset	#12,d6
CF7E8:
	or.b	d1,d6
	br	ASM_STORE_LONG

CF7EE:
	swap	d6
	or.w	d1,d6
	swap	d6
	move.b	(WorkBuffer2-DT,a4),d1
	bra.b	CF7E8

Asmbl_FinishFmove:
	moveq	#-1,d0
	bsr	Processor_warning
	bsr	asm_4bytes_OpperantSize
	move.b	d5,(OpperantSize-DT,a4)
	jsr	asm_get_any_opp
;	jsr	test_debug
	bsr	Parse_GetKomma
	and.b	#15,(OpperantSize-DT,a4)
	cmp	#$FFFF,d5
	bne	Asmbl_fmovenormal
	btst	#$1F,d5
	bne	ERROR_InvalidAddress
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
	beq	ERROR_InvalidAddress
	or.w	d1,d6
	swap	d6
	br	ASM_STORE_LONG

Asmbl_fmovefloat:
	move	d1,(WorkBuffer1-DT,a4)
	cmp.b	#3,(OpperantSize-DT,a4)
	bne	CF8EE
	jsr	(asm_noimmediateopp).l
	cmp	#1,d5
	beq	ERROR_InvalidAddress
	cmp	#$0800,d5
	beq	ERROR_InvalidAddress
	cmp.b	#$7B,(a6)+
	beq	CF88A
	or.w	d1,d6
	swap	d6
	move	#$6C00,d3
	subq.w	#1,a6
	bra.b	CF8BA

CF88A:
	or.w	d1,d6
	swap	d6
	move.b	(a6),d0
	bclr	#5,d0
	cmp.b	#$44,d0
	beq.b	CF8CC
	cmp.b	#3,d0
	bne.b	CF8A2
	addq.w	#1,a6
CF8A2:
	bsr	Parse_GetExprValueInD3Voor
	cmp	#$003F,d3
	bgt.w	ERROR_OutofRange6bit
	or.w	#$6C00,d3
	cmp.b	#$7D,(a6)+
	bne	ERROR_Missingbrace
CF8BA:
	or.w	d3,d6
	or.w	#$6000,d6
	move	(WorkBuffer1-DT,a4),d5
	lsl.w	#7,d5
	or.w	d5,d6
	br	ASM_STORE_LONG

CF8CC:
	addq.w	#1,a6
	moveq	#0,d3
	move.b	(a6)+,d3
	sub.b	#$30,d3
	cmp.b	#7,d3
	bgt.w	ERROR_IllegalOperand
	cmp.b	#$7D,(a6)+
	bne	ERROR_Missingbrace
	lsl.w	#4,d3
	or.w	#$7C00,d3
	bra.b	CF8BA

CF8EE:
	swap	d6
	jsr	(asm_noimmediateopp).l
	cmp	#$FFFF,d5
	bne.b	CF92E
	btst	#$1F,d5
	bne	ERROR_InvalidAddress
	swap	d5
	cmp	#$0010,d5
	bne	ERROR_InvalidAddress
	cmp.b	#2,(OpperantSize-DT,a4)
	bne	ERROR_Illegalfloating
	and.l	#$FFC0FFFF,d6
	lsl.w	#7,d1
	or.w	d1,d6
	move	(WorkBuffer1-DT,a4),d5
	ror.w	#6,d5
	or.w	d5,d6
	br	ASM_STORE_LONG

CF92E:
	cmp	#$0800,d5
	beq	ERROR_InvalidAddress
	tst	d5
	bne.b	CF956
	cmp.b	#1,(OpperantSize-DT,a4)
	ble.b	CF956
	cmp.b	#4,(OpperantSize-DT,a4)
	beq.b	CF956
	cmp.b	#6,(OpperantSize-DT,a4)
	beq.b	CF956
	br	ERROR_Illegalsizeform

CF956:
	swap	d6
	or.w	d1,d6
	swap	d6
	move.b	(OpperantSize-DT,a4),d5
	and	#7,d5
	ror.w	#6,d5
	or.w	d5,d6
	or.w	#$6000,d6
	move	(WorkBuffer1-DT,a4),d5
	lsl.w	#7,d5
	or.w	d5,d6
	br	ASM_STORE_LONG

Asmbl_fmovenormal:
	cmp	#1,d5
	beq	ERROR_InvalidAddress
	tst	d5
	bne.b	Asmbl_fmoveNormal2fpr
	cmp.b	#1,(OpperantSize-DT,a4)
	ble.b	Asmbl_fmoveNormal2fpr
	cmp.b	#4,(OpperantSize-DT,a4)
	beq.b	Asmbl_fmoveNormal2fpr
	cmp.b	#6,(OpperantSize-DT,a4)
	beq.b	Asmbl_fmoveNormal2fpr
	br	ERROR_Illegalsizeform

Asmbl_fmoveNormal2fpr:
	or.w	d1,d6
	swap	d6
	jsr	(asm_get_any_opp).l
	cmp	#$FFFF,d5
	bne	ERROR_Floatingpoint
	btst	#$1F,d5
	bne	ERROR_InvalidAddress
	swap	d5
	cmp	#$0010,d5
	bne.b	Asmbl_fmove2ctrlreg
	and	#7,d1
	lsl.w	#7,d1
	or.w	d1,d6
	move.b	(OpperantSize-DT,a4),d5
	and	#7,d5
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

CF9F6:
	moveq	#-1,d0
	bsr	Processor_warning
	bsr	asm_4bytes_OpperantSize
	cmp.b	#$23,(a6)+
	bne	ERROR_InvalidAddress
	bsr	Parse_GetExprValueInD3Voor
	bsr	Parse_GetKomma
	cmp	#$007F,d3
	bgt.w	ERROR_OutofRange7bit
	swap	d6
	or.w	d3,d6
	jsr	(asm_noimmediateopp).l
	cmp	#$FFFF,d5
	bne	ERROR_Floatingpoint
	btst	#$1F,d5
	bne	ERROR_InvalidAddress
	swap	d5
	cmp	#$0010,d5
	bne	ERROR_InvalidAddress
	lsl.w	#7,d1
	or.w	d1,d6
	br	ASM_STORE_LONG

CFA44:
	moveq	#-1,d0
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
	cmp	#$0100,d5
	bne	ERROR_InvalidAddress
CFA74:
	br	ASM_STORE_LONG

CFA78:
	moveq	#-1,d0
	bsr	Processor_warning
	move.b	d5,(OpperantSize-DT,a4)
	bsr	asm_4bytes_OpperantSize
	jsr	(asm_get_any_opp).l
	cmp	#1,d5
	beq	ERROR_InvalidAddress
	cmp	#$FFFF,d5
	beq.b	CFACE
	tst	d5
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
	moveq	#0,d1
	move.b	(OpperantSize-DT,a4),d1
	and.b	#7,d1
	bset	#$1E,d6
CFACE:
	swap	d6
	ror.w	#6,d1
	or.w	d1,d6
	br	ASM_STORE_LONG

CFAD8:
	moveq	#-1,d0
	bsr	Processor_warning
	bsr	asm_4bytes_OpperantSize
	jsr	(AdresOfDataReg).l
	tst	d5
	bne	ERROR_Dataregexpect
	or.w	d1,d6
	swap	d6
	bsr	Parse_GetKomma
	jsr	(C37EE).l
	br	ASM_STORE_LONG

CFB00:
	moveq	#-1,d0
	bsr	Processor_warning
	move.b	d5,(OpperantSize-DT,a4)
	bsr	asm_4bytes_OpperantSize
	jsr	(asm_get_any_opp).l
	cmp	#1,d5
	beq	ERROR_InvalidAddress
	cmp	#$FFFF,d5
	beq.b	CFB5E
	or.w	d1,d6
	swap	d6
	tst	d5
	bne.b	CFB4A
	moveq	#0,d5
	move.b	(OpperantSize-DT,a4),d5
	cmp	#4,d5
	beq.b	CFB50
	cmp	#6,d5
	beq.b	CFB50
	tst	d5
	beq.b	CFB50
	cmp	#$0071,d5
	beq.b	CFB50
	br	ERROR_Illegalsizeform

CFB4A:
	moveq	#0,d5
	move.b	(OpperantSize-DT,a4),d5
CFB50:
	and.b	#7,d5
	ror.w	#6,d5
	or.w	d5,d6
	bset	#14,d6
	bra.b	CFB86

CFB5E:
	cmp.b	#$72,(OpperantSize-DT,a4)
	bne	ERROR_IllegalSize
	btst	#$1F,d5
	bne	ERROR_InvalidAddress
	swap	d5
	swap	d6
	cmp	#$0010,d5
	bne	ERROR_InvalidAddress
	ror.w	#6,d1
	or.w	d1,d6
	cmp.b	#$2C,(a6)
	bne.b	CFBB2
CFB86:
	bsr	Parse_GetKomma
	jsr	(asm_get_any_opp).l
	cmp	#$FFFF,d5
	bne	ERROR_InvalidAddress
	btst	#$1F,d5
	bne	ERROR_InvalidAddress
	swap	d5
	cmp	#$0010,d5
	bne	ERROR_InvalidAddress
	lsl.w	#7,d1
CFBAC:
	or.w	d1,d6
	br	ASM_STORE_LONG

CFBB2:
	lsr.w	#3,d1
	bra.b	CFBAC

Asm_FPopperant:
	moveq	#-1,d0
	bsr	Processor_warning
	move.b	d5,(OpperantSize-DT,a4)
	bsr	asm_4bytes_OpperantSize
	jsr	(asm_get_any_opp).l
	cmp	#1,d5
	beq	ERROR_InvalidAddress
	cmp	#$FFFF,d5
	beq.b	CFC14
	or.w	d1,d6
	swap	d6
	tst	d5
	bne.b	CFC00
	moveq	#0,d5
	move.b	(OpperantSize-DT,a4),d5
	cmp.b	#4,d5
	beq.b	FPIntOpperant
	cmp.b	#6,d5
	beq.b	FPIntOpperant
	tst.b	d5
	beq.b	FPIntOpperant
	cmp.b	#$71,d5
	beq.b	FPIntOpperant
	br	ERROR_Illegalsizeform

CFC00:
	moveq	#0,d5
	move.b	(OpperantSize-DT,a4),d5
FPIntOpperant:
	and.b	#7,d5
	ror.w	#6,d5
	or.w	d5,d6
	bset	#14,d6
	bra.b	CFC3E

CFC14:
	cmp.b	#$72,(OpperantSize-DT,a4)
	bne	ERROR_IllegalSize
	swap	d6
	btst	#$1F,d5
	bne	ERROR_InvalidAddress
	swap	d5
	cmp	#$0010,d5
	bne	ERROR_InvalidAddress
	ror.w	#6,d1
	or.w	d1,d6
	cmp.b	#$2C,(a6)
	bne	ERROR_Commaexpected
CFC3E:
	bsr	Parse_GetKomma
	jsr	(asm_get_any_opp).l
	cmp	#$FFFF,d5
	bne	ERROR_InvalidAddress
	btst	#$1F,d5
	bne	ERROR_InvalidAddress
	swap	d5
	cmp	#$0010,d5
	bne	ERROR_InvalidAddress
	lsl.w	#7,d1
	or.w	d1,d6
	br	ASM_STORE_LONG

CFC6A:
	moveq	#-1,d0
	bsr	Processor_warning
	bsr	asm_4bytes_OpperantSize
	move.b	d5,(OpperantSize-DT,a4)
	jsr	(asm_get_any_opp).l
	bsr	Parse_GetKomma
	cmp	#$FFFF,d5
	beq	CFD20
	cmp	#1,d5
	beq	ERROR_InvalidAddress
	tst	d5
	bne.b	CFCB8
	tst.b	(OpperantSize-DT,a4)
	beq.b	CFCB8
	cmp.b	#$71,(OpperantSize-DT,a4)
	beq.b	CFCB8
	cmp.b	#4,(OpperantSize-DT,a4)
	beq.b	CFCB8
	cmp.b	#6,(OpperantSize-DT,a4)
	beq.b	CFCB8
	br	ERROR_Illegalsizeform

CFCB8:
	or.w	d1,d6
	swap	d6
	bset	#14,d6
	moveq	#0,d5
	move.b	(OpperantSize-DT,a4),d5
	and.b	#7,d5
	ror.w	#6,d5
	or.w	d5,d6
CFCCE:
	jsr	(asm_noimmediateopp).l
	cmp	#$FFFF,d5
	bne	ERROR_InvalidAddress
	btst	#$1F,d5
	bne	ERROR_InvalidAddress
	swap	d5
	cmp	#$0010,d5
	bne	ERROR_InvalidAddress
	or.w	d1,d6
	cmp.b	#$3A,(a6)+
	bne	ERROR_Colonexpected
	jsr	(asm_noimmediateopp).l
	cmp	#$FFFF,d5
	bne	ERROR_InvalidAddress
	btst	#$1F,d5
	bne	ERROR_InvalidAddress
	swap	d5
	cmp	#$0010,d5
	bne	ERROR_InvalidAddress
	lsl.w	#7,d1
	or.w	d1,d6
	br	ASM_STORE_LONG

CFD20:
	swap	d6
	ror.w	#6,d1
	or.w	d1,d6
	bra.b	CFCCE

Asm_Move16Afronden:
	moveq	#PB_040,d0
	bsr	Processor_warning
	bsr	Asm_SkipInstructionHead
	jsr	(asm_noimmediateopp).l
	bsr	Parse_GetKomma
	cmp	#2,d5
	beq.b	CFD80
	cmp	#4,d5
	beq.b	CFDA0
	cmp	#$0080,d5
	bne	ERROR_InvalidAddress
	bset	#3,d6
	jsr	(asm_noimmediateopp).l
	cmp	#2,d5
	beq.b	CFD72
	cmp	#4,d5
	bne	ERROR_InvalidAddress
	and	#7,d1
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

CFD72:
	bset	#4,d6
	and	#7,d1
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

CFD80:
	and	#7,d1
	move	d1,-(sp)
	jsr	(asm_get_any_opp).l
	move	(sp)+,d1
	cmp	#$0080,d5
	bne	ERROR_InvalidAddress
	bset	#4,d6
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

CFDA0:
	and	#7,d1
	or.w	d1,d6
	jsr	(asm_get_any_opp).l
	cmp	#$0080,d5
	beq	CFDD2
	cmp	#4,d5
	bne	ERROR_InvalidAddress
	and	#7,d1
	ror.w	#4,d1
	bset	#5,d6
	swap	d6
	or.w	d1,d6
	bsr	asm_4bytes_OpperantSize
	br	ASM_STORE_LONG

CFDD2:
	br	ASM_STORE_INSTRUCTION_HEAD

CFDD6:
	moveq	#1,d0
	bsr	Processor_warning
	bsr	asm_4bytes_OpperantSize
	jsr	(asm_noimmediateopp).l
	bsr	Parse_GetKomma
	cmp	#1,d5
	ble.b	CFE12
	or.b	d1,d6
	swap	d6
	move	#0,d6
	jsr	(asm_noimmediateopp).l
	cmp	#1,d5
	beq.b	CFE38
	tst	d5
	bne	ERROR_InvalidAddress
CFE0A:
	ror.w	#4,d1
	or.w	d1,d6
	br	ASM_STORE_LONG

CFE12:
	swap	d6
	move	#0,d6
	ror.w	#4,d1
	or.w	d1,d6
	bset	#11,d6
	swap	d6
	jsr	(asm_noimmediateopp).l
	cmp	#1,d5
	ble.w	ERROR_InvalidAddress
	or.b	d1,d6
	swap	d6
	br	ASM_STORE_LONG

CFE38:
	or.w	#8,d1
	bra.b	CFE0A

asm_movec_crs:
	moveq	#1,d0
	bsr	Processor_warning

	bsr	asm_4bytes_OpperantSize
	jsr	(asm_noimmediateopp).l
	bsr	Parse_GetKomma
	cmp	#$2000,d5
	beq.b	CFEAE
	cmp	#$FFFF,d5
	beq.b	CFEB4
	bset	#0,d6
	cmp	#1,d5
	bgt.w	ERROR_InvalidAddress
	move	d1,-(sp)
	jsr	(asm_noimmediateopp).l
	cmp	#$2000,d5
	bne.b	CFE7E
	move.l	#$0800FFFF,d5
CFE7E:
	cmp	#$FFFF,d5
	bne	ERROR_InvalidAddress
	btst	#$1F,d5
	bne	ERROR_InvalidAddress
	swap	d5
	move	d5,d0
	and	#$00F0,d0
	tst	d0
	bne	ERROR_InvalidAddress
	move	(sp)+,d1
	ror.w	#4,d1
	or.w	d1,d5
CFEA2:
	swap	d6
	move	#0,d6
	or.w	d5,d6
	br	ASM_STORE_LONG

CFEAE:
	move.l	#$0800FFFF,d5
CFEB4:
	btst	#$1F,d5
	bne	ERROR_InvalidAddress
	swap	d5
	move	d5,d0
	and	#$00F0,d0
	tst	d0
	bne	ERROR_InvalidAddress
	move	d5,-(sp)
	jsr	(asm_noimmediateopp).l
	cmp	#1,d5
	bgt.w	ERROR_InvalidAddress
	move	(sp)+,d5
	ror.w	#4,d1
	or.w	d1,d5
	bra.b	CFEA2

CFEE2:
	bsr	Asm_SkipInstructionHead
	move.b	d5,(OpperantSize-DT,a4)
	tst.b	(a6)
	beq.b	CFF00
	jsr	(asm_get_any_opp).l
	cmp	#$0100,d5
	bne	ERROR_InvalidAddress
	br	ASM_STORE_INSTRUCTION_HEAD

CFF00:
	and	#$FFFC,d6
	bset	#2,d6
	br	ASM_STORE_INSTRUCTION_HEAD

CFF0C:
	moveq	#2,d0
	bsr	Processor_warning
	move.b	#$40,(OpperantSize-DT,a4)
	bsr	Asm_SkipInstructionHead
	jsr	(asm_get_any_opp).l
	bsr	Parse_GetKomma
	and	#7,d1
	or.w	d1,d6
	cmp	#8,d5
	beq.b	CFF62
	tst	d5
	bne	ERROR_InvalidAddress
	jsr	(asm_get_any_opp).l
	bsr	Parse_GetKomma
	tst	d5
	bne	ERROR_InvalidAddress
CFF48:
	and	#7,d1
	ror.w	#7,d1
	or.w	d1,d6
	jsr	(asm_get_any_opp).l
	cmp	#$0100,d5
	bne	ERROR_InvalidAddress
	br	ASM_STORE_INSTRUCTION_HEAD

CFF62:
	bset	#3,d6
	jsr	(asm_get_any_opp).l
	bsr	Parse_GetKomma
	cmp	#8,d5
	bne	ERROR_InvalidAddress
	bra.b	CFF48

Asm_ImmOpperantLong:
	moveq	#2,d0
	bsr	Processor_warning
	move.b	d5,(OpperantSize-DT,a4)
	bsr	asm_4bytes_OpperantSize
	jsr	(asm_get_any_opp).l
	bsr	Parse_GetKomma
	and.b	#15,(OpperantSize-DT,a4)
	cmp	#1,d5
	beq	ERROR_InvalidAddress
	or.w	d1,d6
	jsr	(AdresOfDataReg).l
	tst	d5
	bne	ERROR_Dataregexpect
	swap	d6
	move	#0,d6
	cmp.b	#$3A,(a6)
	bne.b	CFFE4
	addq.w	#1,a6
	move	d1,-(sp)
	jsr	(asm_get_any_opp).l
	tst	d5
	bne	ERROR_Dataregexpect
	ror.w	#4,d1
	or.w	d1,d6
	move	(sp)+,d1
	or.w	d1,d6
CFFD2:
	moveq	#0,d5
	move.b	(OpperantSize-DT,a4),d5
	and.b	#$7F,d5
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
	cmp	#1,d5
	beq	ERROR_InvalidAddress
	or.w	d1,d6
	jsr	(AdresOfDataReg).l
	tst	d5
	bne	ERROR_Dataregexpect
	ror.w	#7,d1
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

asm_cmp2_long_stuff:
	moveq	#PB_020,d0
	bsr	Processor_warning
	move.b	d5,(OpperantSize-DT,a4)

	cmp.b	#$80,d5
	beq.s	.long

	bsr	asm_4bytes_OpperantSize		;was 2
	jsr	(asm_get_any_opp).l

	tst.b	(OpperantSize-DT,a4)
	bne.s	.word
	cmp.w	#$ff,d3
	bhi.w	ERROR_out_of_range8bit
	bra.b	.short
.word:
	cmp.l	#$ffff,d3
	bhi.w	ERROR_out_of_range16bit
	bra.b	.short
.long:
	bsr	asm_4bytes_OpperantSize
	jsr	(asm_get_any_opp).l
.short
	tst	d5
	beq	ERROR_InvalidAddress
	and	#$010D,d5
	bne	ERROR_InvalidAddress
	or.w	d1,d6
	bsr	Parse_GetKomma
	jsr	AdresOfDataReg
	cmp	#1,d5
	beq.b	.asm_cmp2
	tst	d5
	bne	ERROR_Dataregexpect
.asm_cmp2:
;	moveq.l	#0,d5
	move.b	(OpperantSize-DT,a4),d5

	move.w	d5,-(sp)

	lsl.w	#3,d5
	or.w	d5,d6
	swap	d6
	lsl.w	#7,d1
	lsl.w	#5,d1
	move	d1,d6

	bsr	ASM_STORE_LONG

	move.w	(sp)+,d5

	and.w	#%11000000,d5
	bne.s	.asm_cmp2abs
	rts

.asm_cmp2abs:
	lsr.w	#7,d5
	btst	#0,d5		;$xxx.w or $xxxxxxxx.l
	bne.s	.long2
	move.w	d3,d6
	br	ASM_STORE_INSTRUCTION_HEAD
.long2:
	move.l	d3,d6
	br	ASM_STORE_LONG

C1006E:
	move.b	d5,(OpperantSize-DT,a4)
	bsr	Asm_SkipInstructionHead
	jsr	(asm_get_any_opp).l
	cmp	#1,d5
	beq	ERROR_InvalidAddress
	or.w	d1,d6
	bsr	Parse_GetKomma
	jsr	(AdresOfDataReg).l
	tst	d5
	bne	ERROR_Dataregexpect
	ror.w	#7,d1
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

C1009E:
	move.b	d5,(OpperantSize-DT,a4)
	bsr	Asm_SkipInstructionHead
	jsr	(asm_get_any_opp).l
	cmp	#$0100,d5
	bne	ERROR_InvalidAddress
	br	ASM_STORE_INSTRUCTION_HEAD

C100B8:
	moveq	#4,d0
	bsr	Processor_warning
	bsr	Asm_SkipInstructionHead
	moveq	#0,d0
	moveq	#0,d1
	move.b	(a6)+,d0
	lsl.l	#8,d0
	move.b	(a6)+,d0
	and	#$DFDF,d0
	bsr	C1010E
	br	ASM_STORE_INSTRUCTION_HEAD

C100D8:
	moveq	#4,d0
	bsr	Processor_warning
	bsr	Asm_SkipInstructionHead
	moveq	#0,d0
	moveq	#0,d1
	move.b	(a6)+,d0
	lsl.l	#8,d0
	move.b	(a6)+,d0
	and	#$DFDF,d0
	bsr.b	C1010E
	bsr	Parse_GetKomma
	jsr	(asm_noimmediateopp).l
	cmp	#2,d5
	bne	ERROR_InvalidAddress
	and.b	#7,d1
	or.b	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

C1010E:
	cmp	#$4243,d0
	beq.b	C1012E
	cmp	#$4443,d0
	beq.b	C10128
	cmp	#$4943,d0
	bne	ERROR_IllegalOperand
	or.w	#$0080,d6
	rts

C10128:
	or.w	#$0040,d6
	rts

C1012E:
	or.w	#$00C0,d6
	rts

C10134:
	moveq	#2,d0
	bsr	Processor_warning
	bsr	Asm_SkipInstructionHead
	jsr	(asm_get_any_opp).l
	bsr	Parse_GetKomma
	cmp	#$0100,d5
	bne	ERROR_InvalidAddress
	bsr	asm_4bytes_OpperantSize
	jsr	(asm_get_any_opp).l
	tst	d5
	beq	ERROR_InvalidAddress
	and	#$010D,d5
	bne	ERROR_InvalidAddress
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

asm_BKPT_opp:
	move.b	d5,(OpperantSize-DT,a4)
	jsr	(asm_get_any_opp).l
	bsr	Asm_SkipInstructionHead
	cmp	#$0100,d5
	bne	ERROR_InvalidAddress
	cmp	#7,d3
	bgt.w	ERROR_out_of_range3bit
	or.w	d3,d6
	br	ASM_STORE_INSTRUCTION_HEAD

asm_LPSTOP_opp:
	move.b	d5,(OpperantSize-DT,a4)
	jsr	(asm_get_any_opp).l
	bsr	asm_4bytes_OpperantSize

	cmp	#$0100,d5
	bne	ERROR_InvalidAddress

	bsr	ASM_STORE_LONG

	cmp.l	#$ffff,d3
	bhi	ERROR_out_of_range16bit
	move.w	d3,d6

	bsr	Asm_SkipInstructionHead
	br	ASM_STORE_INSTRUCTION_HEAD

;****************************************************

C10192:
	moveq	#2,d0
	bsr	Processor_warning
	jsr	(asm_noimmediateopp).l
	tst	d5
	bne	ERROR_Dataregexpect
	move	d1,-(sp)
	move.b	(a6)+,d0
	cmp.b	#$3A,d0
	bne	ERROR_Colonexpected
	jsr	(asm_noimmediateopp).l
	tst	d5
	bne	ERROR_Dataregexpect
	move	d1,d3
	move	d3,-(sp)
	move.b	(a6)+,d0
	cmp.b	#$2C,d0
	bne	ERROR_Commaexpected
	jsr	(asm_noimmediateopp).l
	tst	d5
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
	tst	d5
	bne	ERROR_Dataregexpect
	lsl.w	#6,d1
	or.w	(sp)+,d1
	move	d1,-(sp)
	move.b	(a6)+,d0
	cmp.b	#$2C,d0
	bne	ERROR_Commaexpected
	jsr	(asm_noimmediateopp).l
	tst	d5
	beq	ERROR_InvalidAddress
	cmp	#2,d5
	bne	ERROR_InvalidAddress
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
	tst	d5
	beq	ERROR_InvalidAddress
	cmp	#2,d5
	bne	ERROR_InvalidAddress
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
	moveq	#2,d0
	bsr	Processor_warning
	bsr	asm_4bytes_OpperantSize
	jsr	(asm_noimmediateopp).l
	tst	d5
	bne	ERROR_Dataregexpect
	move	d1,-(sp)
	move.b	(a6)+,d0
	cmp.b	#$2C,d0
	bne	ERROR_Commaexpected
	jsr	(asm_noimmediateopp).l
	tst	d5
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
	tst	d5
	beq	ERROR_InvalidAddress
	and	#$8201,d5
	bne	ERROR_InvalidAddress
	or.w	d1,d6
	swap	d6
	clr	d6
	move	(sp)+,d1
	or.w	d1,d6
	br	ASM_STORE_LONG

C102F2:
	bsr	C10346
	br	ASM_STORE_LONG

Asm_Bitfieldopp:
	bsr	C10346
	move.b	(a6)+,d0
	cmp.b	#$2C,d0
	bne	ERROR_Commaexpected
	jsr	(asm_noimmediateopp).l
	tst	d5
	bne	ERROR_Dataregexpect
	lsl.w	#8,d1
	lsl.w	#4,d1
	or.w	d1,d6
	br	ASM_STORE_LONG

C1031E:
	jsr	(asm_noimmediateopp).l
	tst	d5
	bne	ERROR_Dataregexpect
	lsl.w	#8,d1
	lsl.w	#4,d1
	swap	d6
	or.w	d1,d6
	swap	d6
	move.b	(a6)+,d0
	cmp.b	#$2C,d0
	bne	ERROR_Commaexpected
	bsr	C10346
	br	ASM_STORE_LONG

C10346:
	moveq	#2,d0
	bsr	Processor_warning
	bsr	asm_4bytes_OpperantSize
	move.b	d5,(OpperantSize-DT,a4)
	jsr	(asm_noimmediateopp).l
	and	#$800D,d5
	bne	ERROR_IllegalOperand
	or.w	d1,d6
	swap	d6
	move.b	(a6)+,d0
	cmp.b	#$7B,d0
	bne	ERROR_Offsetwidthex
	move.b	(a6),d0
	bclr	#5,d0
	cmp.b	#$44,d0
	beq.b	C1038A
	bsr	Parse_GetExprValueInD3Voor
	cmp	#$001F,d3
	bgt.w	ERROR_OutofRange5bit
	bra.b	C10396

C1038A:
	addq.w	#1,a6
	move.b	(a6)+,d3
	sub.b	#$30,d3
	bset	#5,d3
C10396:
	lsl.w	#6,d3
	or.w	d3,d6
	move.b	(a6)+,d0
	cmp.b	#$3A,d0
	bne	ERROR_Offsetwidthex
	move.b	(a6),d0
	bclr	#5,d0
	cmp.b	#$44,d0
	beq.b	C103E0
	bsr	Parse_GetExprValueInD3Voor
	cmp	#$0020,d3
	bne.b	C103C4
	tst	d6
	bne	ERROR_Bitfieldoutofrange32bit
	move	#0,d3
C103C4:
	cmp	#$001F,d3
	bgt.w	ERROR_OutofRange5bit
;	move	d6,d0
;	lsr.w	#6,d0
;	and.b	#$1F,d0
;	add	d3,d0
;	cmp	#$0020,d0
;	bgt.w	ERROR_Bitfieldoutofrange32bit
	bra.b	C103EC

C103E0:
	addq.w	#1,a6
	move.b	(a6)+,d3
	sub.b	#$30,d3
	bset	#5,d3
C103EC:
	move.b	(a6)+,d0
	cmp.b	#$7D,d0
	bne	ERROR_Missingbrace
	or.w	d3,d6
	rts

C103FA:
	bsr	Asm_SkipInstructionHead
	move.b	d5,(OpperantSize-DT,a4)
	move.b	#1,(S_MemIndActEnc-DT,a4)
	jsr	(asm_get_any_opp).l
	tst.b	(S_MemIndActEnc-DT,a4)
	bpl.b	C10418
	or.w	#1,d1
C10418:
	clr.b	(S_MemIndActEnc-DT,a4)
	move	d1,d6
	bsr	Parse_GetKomma
	cmp	#$1000,d5
	bcc.w	MAY_BE_FROM_SR_USP
	cmp	#1,d5
	bne.b	C10438
    cmp.w   #PB_APOLLO,(CPU_type-DT,a4)  ;APOLLO support byte writes to Ax.
    beq.b   .ok 
	tst.b	(OpperantSize-DT,a4)
	beq	ERROR_AddressRegByte
.ok
C10438:
	jsr	(asm_noimmediateopp).l
	cmp	#1,d5
	bne	ERROR_AddressRegExp
    cmp.w   #PB_APOLLO,(CPU_type-DT,a4)  ;APOLLO support byte writes to Ax.
    beq.b   .ok 
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
	move.b	#1,(S_MemIndActEnc-DT,a4)
	jsr	(asm_get_any_opp).l
	clr.b	(S_MemIndActEnc-DT,a4)
	move	d1,d6
	bsr	Parse_GetKomma
	cmp	#MODE_13,d5
	bcc.w	MAY_BE_FROM_SR_USP
	cmp	#MODE_1,d5
	bne.b	.NotFromAn
    cmp.w   #PB_APOLLO,(CPU_type-DT,a4)  ;APOLLO support byte writes to Ax.
    beq.b   .ok 
	tst.b	(OpperantSize-DT,a4)
	beq	ERROR_AddressRegByte
.ok
.NotFromAn:
	jsr	(asm_noimmediateopp).l
	cmp	#MODE_9,d5
	bcc.w	MAY_BE_TO_SR_USP
	cmp	#MODE_1,d5
	bne.b	.NOT_TO_AN
    cmp.w   #PB_APOLLO,(CPU_type-DT,a4)  ;APOLLO support byte writes to Ax.
    beq.b   .ok2
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
	move.l	#0,(L2FCD6-DT,a4)
	or.w	d3,d6
	ror.w	#7,d1
	or.w	d1,d6
	br	Asm_InsertInstruction

MAY_BE_FROM_SR_USP:
	beq.b	C1055C
	cmp	#MODE_14,d5
	bne	ERROR_InvalidAddress
	jsr	(AdresOfDataReg).l
	tst	d5
	beq	ERROR_AddressRegExp
	subq.w	#8,d1
	move	#$4E68,d6
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

C10550:
	moveq	#PB_010,d0
	bsr	Processor_warning
	move	#$42C0,d6
	bra.b	C10574

C1055C:
	tst.b	(OpperantSize-DT,a4)
	ble.w	ERROR_IllegalSize
	cmp	#$003C,d1
	beq.b	C10550
	move	#$40C0,d6
	add.b	d1,d1
	bpl.w	ERROR_InvalidAddress
C10574:
	jsr	(asm_noimmediateopp).l
	and	#$7D01,d5
	bne	ERROR_InvalidAddress
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

MAY_BE_TO_SR_USP:
	moveq	#$38,d0
	and	d6,d0
	cmp.b	#8,d0
	bne.b	C105A4
	cmp	#$2000,d5
	bne	ERROR_InvalidAddress
	sub	d0,d6
	or.w	#$4E60,d6
	br	ASM_STORE_INSTRUCTION_HEAD

C105A4:
	cmp	#$1000,d5
	bne	ERROR_InvalidAddress
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
	
	lea	(ERROR_AddressRegExp).l,a0
	move.l	(sp)+,d0

	sub.l	a0,d0
	lsr.l	#1,d0
	lea	(Error_Msg_Table).l,a0
	add.l	d0,a0
	add	(a0),a0
C105DE:
	bclr	#SB2_INSERTINSOURCE,(SomeBits2-DT,a4)
	btst	#SB3_REPORT_ERROR,(SomeBits3-DT,a4)	;???
	beq	ErrMsgNoDebug
	move.l	(Error_Jumpback-DT,a4),a1
	jmp	(a1)

asmbl_dbcc:
	move.w	#0,.temp

	move.l	a5,a3
.loop
	move.w	(a3),d0
	and.w	#$dfdf,d0
	sub.l	#1,a3
	cmp.w	#"DB",d0
	bne.b	.loop	
	addq.l	#4,a3
	move.b	(a3),d0

	cmp.b	#'.',d0
	bne.b	.nosize

	move.w	(a3),d0
	and.w	#$dfdf,d0
	
	cmp.b	#'W',d0
	beq.b	.nosize

        cmp.w   #PB_APOLLO,(CPU_type-DT,a4)  ;Only APOLLO support dbcc.l
    	bne.w   ERROR_IllegalAddres

	cmp.b	#'L',d0
	bne.w	ERROR_IllegalAddres

	;DBCC.L
	move.w	#1,.temp

.nosize

	bsr	Asm_SkipInstructionHead

	jsr	(AdresOfDataReg).l
	tst	d5
	bne	ERROR_Dataregexpect
	or.w	d1,d6
	bsr	Parse_GetKomma
	jsr	(C37EE).l

	tst.w	d7	;passone
	bmi.b	.passone
	move.w	.temp(pc),d0
	or.w	(a0),d0
	move.w  d0,(a0)
.passone

	br	ASM_STORE_INSTRUCTION_HEAD
.temp:	dc.l	0

asmbl_BraNorm:
	bsr	Asm_SkipInstructionHead
	BTST	#AF_OPTIMIZE,d7
	bne	C10718
	jsr	(C37EE).l
	br	ASM_STORE_INSTRUCTION_HEAD

asmbl_BraL:
	move	d6,d0
	rol.w	#4,d0
	and	#15,d0
	cmp	#15,d0
	beq.b	C10664
	cmp	#PB_020,(CPU_type-DT,a4)
	bge.b	C1066A
	and	#$FF00,d6
	bset	#1,d7
	moveq	#$20,d0
	and.b	(-1,a5),d0
	or.b	#$57,d0
	move.b	d0,(-1,a5)
	bset	#SB1_SOURCE_CHANGED,(SomeBits-DT,a4)
	lea	(BranchForcedt.MSG,pc),a0
	br	Druk_Af_Regel1

C10664:
	moveq	#-1,d0
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
	moveq	#-1,d0
	bsr	Processor_warning
	bra.b	C10690

asmbl_BraW:
	BTST	#AF_OPTIMIZE,d7
	bne.b	C1069E
C10690:
	bsr	Asm_SkipInstructionHead
	jsr	(C37EE).l
	br	ASM_STORE_INSTRUCTION_HEAD

C1069E:
	tst	(MACRO_LEVEL-DT,a4)
	bne.b	C10690
	moveq	#$20,d0
	and.b	(-1,a5),d0
	or.b	#$42,d0
	move.b	d0,(-1,a5)
asmbl_BraB:
	bsr	Asm_SkipInstructionHead
	jsr	(C3814).l
	br	ASM_STORE_INSTRUCTION_HEAD

FORCE_BRAW:
	tst	(MACRO_LEVEL-DT,a4)
	bne	ERROR_BccBoutofrange
	bsr	ASM_STORE_INSTRUCTION_HEAD
	bset	#1,d7
	moveq	#$20,d0
	and.b	(-1,a5),d0
	or.b	#'W',d0
	move.b	d0,(-1,a5)
	bset	#SB1_SOURCE_CHANGED,(SomeBits-DT,a4)
	lea	(BranchForcedt.MSG,pc),a0

	br	Druk_Af_Regel1

C106EC:
	tst	(MACRO_LEVEL-DT,a4)
	bne	ERROR_BccWoutofrange
	bsr	ASM_STORE_INSTRUCTION_HEAD
	bset	#1,d7
	moveq	#$20,d0
	and.b	(-1,a5),d0
	or.b	#$4C,d0
	move.b	d0,(-1,a5)
	bset	#SB1_SOURCE_CHANGED,(SomeBits-DT,a4)
	lea	(BranchForcedt.MSG0,pc),a0
	br	Druk_Af_Regel1


C10718:
	move	(MACRO_LEVEL-DT,a4),d0
	add	(INCLUDE_LEVEL-DT,a4),d0
	bne	C10690
	move.l	(Cut_Blok_End-DT,a4),a3
	addq.l	#1,a3
	move.l	a3,a2
	addq.l	#2,a3
	addq.l	#2,(Cut_Blok_End-DT,a4)
	addq.l	#2,(sourceend-DT,a4)
	move.l	(LabelStart-DT,a4),d0
	cmp.l	(Cut_Blok_End-DT,a4),d0
	bls.b	C1076E
	move.l	a2,d0
	sub.l	a5,d0
	subq.l	#1,d0
C10746:
	move.b	-(a2),-(a3)
	dbra	d0,C10746
	sub.l	#$00010000,d0
	bpl.b	C10746
	moveq	#$20,d1
	and.b	(-1,a5),d1
	move.b	#$2E,(a5)+
	or.b	#$42,d1
	move.b	d1,(a5)+
	addq.w	#2,a6
	bsr	messages_get
	br	asmbl_BraB

C1076E:
	subq.l	#2,(Cut_Blok_End-DT,a4)
	subq.l	#2,(sourceend-DT,a4)
	bset	#7,d7
	bset	#1,d7
	rts

Asm_CmdJmpJsrPea:
	bsr	Asm_SkipInstructionHead
	jsr	(asm_noimmediateopp).l
	and	#MODE_2!MODE_5!MODE_6!MODE_7!MODE_8!MODE_11!MODE_12,d5	;$0CF2
	beq	ERROR_InvalidAddress
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

C10798:
	bsr	Asm_SkipInstructionHead
	move.b	d5,(OpperantSize-DT,a4)
	jsr	(Parse_GetEASpecial).l
	tst	d5
	beq.b	C107CE
	cmp	#$0100,d5
	beq.b	C107E4
	bhi.w	ERROR_InvalidAddress
    cmp.w   #PB_APOLLO,(CPU_type-DT,a4)  ;APOLLO support byte writes to Ax.
    beq.b   .ok 
	cmp	#1,d5
	beq	ERROR_AddressRegByte
.ok
C107BC:
	tst.b	(OpperantSize-DT,a4)
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
	tst	d5
	bne.b	C1080E
C107F4:
	and	#$F138,d6
	or.w	d1,d6
	move	(sp)+,d1
	BTST	#AF_UNDEFVALUE,d7
	bne.b	C10806
	ror.w	#7,d1
	or.w	d1,d6
C10806:
	or.b	(OpperantSize-DT,a4),d6
	br	ASM_STORE_INSTRUCTION_HEAD

C1080E:
	and	#$00FE,d5
	beq	ERROR_InvalidAddress
	btst	#5,d6
	bne	ERROR_InvalidAddress
	move	(sp)+,d0
	BTST	#AF_UNDEFVALUE,d7
	bne.b	C107BC
	cmp	#1,d0
	beq.b	C107BC
	br	ERROR_out_of_range0bit

C10830:
	jsr	(Parse_ImmediateValue).l
	BTST	#AF_UNDEFVALUE,d7
	bne.b	C10846
	moveq	#15,d0
	cmp.l	d0,d3
	bhi.w	ERROR_out_of_range4bit
	or.w	d3,d6
C10846:
	br	Asm_InsertInstruction

C1084A:
	move.b	d5,(OpperantSize-DT,a4)
	bsr	Asm_SkipInstructionHead
	jsr	(AdresOfDataReg).l
	tst	d5
	beq	ERROR_AddressRegExp
	subq.w	#8,d1
	or.w	d1,d6
	bsr	Parse_GetKomma
	jsr	(asm_get_any_opp).l
	cmp	#$0100,d5
	bne	ERROR_Immediateoper
	br	ASM_STORE_INSTRUCTION_HEAD

C10878:
	jsr	(AdresOfDataReg).l
	tst	d5
	beq	ERROR_AddressRegExp
	subq.w	#8,d1
	or.w	d1,d6
	br	Asm_InsertInstruction

C1088C:
	jsr	(AdresOfDataReg).l
	tst	d5
	bne	ERROR_Dataregexpect
	or.w	d1,d6
	br	Asm_InsertInstruction

C1089E:
	tst.b	d5
	ble.w	ERROR_IllegalSize
	jsr	(AdresOfDataReg).l
	tst	d5
	bne	ERROR_Dataregexpect
	or.w	d1,d6
	br	Asm_InsertInstruction

C108B6:
	clr.b	(OpperantSize-DT,a4)
	bsr	Asm_SkipInstructionHead
	jsr	(asm_get_any_opp).l
    cmp.w   #PB_APOLLO,(CPU_type-DT,a4)  ;APOLLO support byte writes to Ax.
    beq.b   .ok 
	cmp	#1,d5
	beq	ERROR_AddressRegByte
.ok
	cmp	#$0100,d5
	bcc.w	ERROR_InvalidAddress
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD

ASSEM_CMDCLRNOTTST:
	bsr	Asm_SkipInstructionHead
	jsr	asm_noimmediateopp

	cmp.w	#PB_APOLLO,(CPU_type-DT,a4)	;APOLLO support a1 byte access
	beq.b	C1091E

	cmp	#MODE_1,d5
	bne.b	C10904
	move	d6,d0
	ror.w	#8,d0


	cmp.b	#$4A,d0
	bne	ERROR_InvalidAddress
	tst.b	d6
	beq	ERROR_IllegalAddres
	moveq	#2,d0
	bsr	Processor_warning
	bra.b	C10926

C10904:
	cmp	#MODE_11,d5
	bne.b	C1091E
	move	d6,d0
	ror.w	#8,d0
	cmp.b	#$4A,d0
	bne	ERROR_InvalidAddress
	moveq	#2,d0
	bsr	Processor_warning
	bra.b	C10926

C1091E:
	and	#MODE_9!MODE_13!MODE_14!MODE_15,d5
	bne	ERROR_InvalidAddress
C10926:
	or.w	d1,d6
	br	ASM_STORE_INSTRUCTION_HEAD


;********************************
;*********** INCLINK ************ (code by deftronic)
;********************************
	IF	INCLINK
Asm_IncLink:
	lea	(SourceCode-DT,a4),a1
	bsr	incbinsub1
	bsr	MenNemeNaamEnPad
	move.l	a6,-(sp)
	bsr	GetDiskFileLengte
	move.l	(sp)+,a6
	movem.l	d0-d7/a0-a6,-(sp)
	moveq	#0,d1
	move.l	d0,(incFileLength-DT,a4)
	move.l	(4).w,a6
	jsr	(_LVOAllocMem,a6)
	tst.l	d0
	beq.w	.memError
	move.l	d0,(buffer_ptr-DT,a4)
	movem.l	(sp)+,d0-d7/a0-a6
	tst.w	d7
	bmi.b	.pass1
	lea	(HInclink.MSG).l,a0
	jsr	(PRINTINCLUDENAME).l
.pass1:
	movem.l	d0/a6,-(sp)
	move.l	(buffer_ptr-DT,a4),d2
	move.l	d0,d3
	movem.l	d2/d3,-(sp)
	clr.l	(FileLength-DT,a4)
	jsr	(OpenOldFile).l
	movem.l	(sp)+,d2/d3
	jsr	(read_nr_d3_bytes).l
	bclr	#2,(SomeBits-DT,a4)
	move.l	(Bestand-DT,a4),d1
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOClose,a6)
	tst.w	d7
	bmi.b	.passs1
	lea	(H.MSG,pc),a0
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
	cmp.l	#$000003F3,(a0)
	beq.w	.linkerError
	cmp.l	#$000003E7,(a0)+
	bne.w	.linkerError
	move.l	(a0)+,d0
	lsl.l	#2,d0
	add.l	d0,a0
.inclink1:
	cmp.l	#$000003E8,(a0)
	bne.b	.inclink2
	addq.w	#4,a0
	move.l	(a0)+,d0
	lsl.l	#2,d0
	add.l	d0,a0
.inclink2:
	cmp.l	#$000003E9,(a0)
	bne.b	.inclink4
	addq.w	#4,a0
	move.l	(a0)+,d0
	beq.b	.inclink4
	move.l	d0,(IncIFF_BODYbuffer2-DT,a4)
	tst.w	d7
	bpl.w	.inclink3
	lsl.l	#2,d0
	add.l	d0,a0
	bra.b	.inclink4

.inclink3:
	move.l	(a0)+,(a1)+
	subq.l	#1,d0
	bne.b	.inclink3
.inclink4:
	cmp.l	#$000003EC,(a0)
	bne.b	.inclink8
	addq.w	#4,a0
	move.l	(a0)+,d0
	beq.w	.linkerError
	tst.l	(a0)+
	bne.w	.linkerError
	tst.w	d7
	bpl.b	.inclink5
	lsl.l	#2,d0
	add.l	d0,a0
	bra.b	.inclink7

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
	bne.w	.linkerError
.inclink8:
	cmp.l	#$000003EF,(a0)
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
;	move.l	#.UndefLabel.MSG,(ErrMsg-DT,a4)
	move.l	(a3),(.inclinkData1).l
	move.l	(4,a3),(.inclinkData2).l
	move.l	(8,a3),(.inclinkData3).l
	move.l	(12,a3),(.inclinkData4).l
	move.l	(16,a3),(.inclinkData5).l
	cmp.b	#$84,d1
	beq.w	.inclink18
	cmp.b	#$83,d1
	beq.b	.inclink15
	cmp.b	#$81,d1
	bne.w	.inclink22
	tst.w	d7
	bmi.b	.inclink14
	moveq	#$18,d1
.inclink11:
	move.l	(a3),(-$0064,a3)
	addq.w	#4,a3
	dbra	d1,.inclink11
	movem.l	a0-a3/a6,-(sp)
	lea	(SourceCode-DT,a4),a6
	bsr	Parse_GetExprValueInD3Voor
	movem.l	(sp)+,a0-a3/a6
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
	bra.w	.inclink9

.inclink14:
	move.l	(a0)+,d0
	lsl.l	#2,d0
	add.l	d0,a0
	bra.w	.inclink9

.inclink15:
	tst.w	d7
	bmi.b	.inclink17a
	moveq	#$18,d1
.inclink16:
	move.l	(a3),(-$0064,a3)
	addq.w	#4,a3
	dbra	d1,.inclink16
	movem.l	a0-a3/a6,-(sp)
	lea	(SourceCode-DT,a4),a6
	bsr	Parse_GetExprValueInD3Voor
	movem.l	(sp)+,a0-a3/a6
	tst.w	d2
	bne.w	ERROR_ReservedWord
	move.l	(a0)+,d0
	beq.w	.linkerError
.inclink17:
	move.l	(a0)+,d1
	add.w	d3,(a2,d1.l)
	subq.l	#1,d0
	bne.b	.inclink17
	bra.w	.inclink9

.inclink17a:
	move.l	(a0)+,d0
	lsl.l	#2,d0
	add.l	d0,a0
	bra.w	.inclink9

.inclink18:
	tst.w	d7
	bmi.b	.inclink21
	moveq	#$18,d1
.inclink19:
	move.l	(a3),(-$0064,a3)
	addq.w	#4,a3
	dbra	d1,.inclink19
	movem.l	a0-a3/a6,-(sp)
	lea	(SourceCode-DT,a4),a6
	bsr	Parse_GetExprValueInD3Voor
	movem.l	(sp)+,a0-a3/a6
	tst.w	d2
	bne.w	ERROR_ReservedWord
	move.l	(a0)+,d0
	beq.w	.linkerError
.inclink20:
	move.l	(a0)+,d1
	add.b	d3,(a2,d1.l)
	subq.l	#1,d0
	bne.b	.inclink20
	bra.w	.inclink9

.inclink21:
	move.l	(a0)+,d0
	lsl.l	#2,d0
	add.l	d0,a0
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
	move.b	d0,d1
	and.b	#15,d1
	cmp.b	#10,d1
	bcs.b	.inclink26
	addq.b	#7,d1
.inclink26:
	add.b	#'0',d1
	move.b	d1,(a3)+
	dbra	d2,.inclink25
	clr.b	(a3)+
	move.b	#$1A,(a3)+
	move.b	#$1A,(a3)
	movem.l	d0-d7/a0-a6,(BASEREG_BASE).l
	movem.l	(sp),d0-d7/a0-a6
	lea	(CurrentAsmLine-DT,a4),a6
	jsr	(FAST_TRANSLATE_LINE).l
	movem.l	(BASEREG_BASE).l,d0-d7/a0-a6
	bra.w	.inclink9

.inclink27:
	cmp.l	#$000003F2,(a0)
	beq.w	.inclink1
.inclink28:
	move.l	(IncIFF_BODYbuffer2-DT,a4),d0
	lsl.l	#2,d0
	add.l	d0,(INSTRUCTION_ORG_PTR-DT,a4)
	bsr	.inclink30
	movem.l	(sp)+,d0-d7/a0-a6
.inclink29:
	tst.b	(a6)+
	bne.b	.inclink29
	subq.w	#1,a6
;	clr.l	(ErrMsg-DT,a4)
	rts

.inclink30:
	tst.l	(buffer_ptr-DT,a4)
	beq.b	.nofileptr
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	(buffer_ptr-DT,a4),a1
	move.l	(incFileLength-DT,a4),d0
	move.l	(4).w,a6
	jsr	(_LVOFreeMem,a6)
	clr.l	(buffer_ptr-DT,a4)
	movem.l	(sp)+,d0-d7/a0-a6
.nofileptr:
	rts

.linkerError:
	lea	(.LinkerError.MSG,pc),a0
	bra.w	Druk_Af_Regel1

.memError:
	lea	(Notenoughmemo.MSG,pc),a0
	bra.w	Druk_Af_Regel1


.LinkerError.MSG:	dc.b	'Linker Error, only 1 section allowed!!',0
.UndefLabel.MSG:
	dc.b	' Undefined Label: '
	cnop	0,4
.inclinkData1:
	dc.l	0
.inclinkData2:
	dc.l	0
.inclinkData3:
	dc.l	0
.inclinkData4:
	dc.l	0
.inclinkData5:
	dc.l	0
	dc.w	0
	ENDIF

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
	cmp.b	#$2C,d0
	bne.b	C10962
	br	ERROR_NOoperandspac

C10962:
	subq.w	#2,a6
	moveq	#-1,d1
	rts

C10968:
	lea	(SourceCode-DT,a4),a1
	bsr.b	OntfrutselNaam
	beq	ERROR_Stringexpected
	move.l	a1,d1
	bclr	#0,d1
	move.l	d1,a1
	or.w	#$8000,-(a1)
	rts

OntfrutselNaam:
	btst	#0,(PR_Upper_LowerCase).l
	bne.b	incbinsub1
C1098A:
	moveq	#0,d3
	bra.b	C10990

incbinsub1:
	moveq	#$20,d3
C10990:
	move.l	a1,-(sp)
	move.b	(a6)+,d0
	cmp.b	#$22,d0		;'"'
	beq.b	C109AE
	cmp.b	#$60,d0		;'`'
	beq.b	C109AE
	cmp.b	#$27,d0		;"'"
	beq.b	C109AE
	subq.w	#1,a6
	moveq	#$2C,d1		;','
	moveq	#$20,d2		;' '
	bra.b	C109B6

C109AE:
	moveq	#0,d2
	move.b	d0,d1
	bra.b	C109B6

C109B4:
	move.b	d0,(a1)+
C109B6:
	move.b	(a6)+,d0
	cmp.b	#$61,d0		;a
	bcs.b	C109C6
	cmp.b	#$7A,d0		;z
	bhi.b	C109C6
	sub.b	d3,d0
C109C6:
	cmp.b	d1,d0
	beq.b	C109D4
	cmp.b	d2,d0
	bhi.b	C109B4
	tst.b	d2
	beq	ERROR_MissingQuote
C109D4:
	tst.b	d2
	beq.b	C109DA
	subq.w	#1,a6
C109DA:
	cmp.l	(sp)+,a1
	beq.b	C109E4
	clr.b	(a1)+
	moveq	#$62,d1		;b
	rts

C109E4:
	clr.b	(a1)+
	moveq	#0,d1
	rts

Convert_A2I_sub:
	jsr	(RemoveWS).l	;whitespace
	beq.b	C10A3A		;einde string
	subq.w	#1,a6
	bsr	Parse_GetExprValueInD3Voor
	BTST	#AF_UNDEFVALUE,d7
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
	moveq	#$61,d1		;a
	rts

C10A12:
	jsr	(RemoveWS).l
	beq.b	C10A3A
	subq.w	#1,a6
	bsr	Asm_ImmediateOppFloat
	BTST	#AF_UNDEFVALUE,d7
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
	moveq	#$61,d1
	rts

C10A3A:
	moveq	#1,d3
	moveq	#0,d1
	rts

Convert_A2I:
	movem.l	d2-d7/a0-a3/a5/a6,-(sp)
	bsr.b	Convert_A2I_sub
	tst.b	d0
	bne	ERROR_IllegalOperand
	move.l	d3,d0
	movem.l	(sp)+,d2-d7/a0-a3/a5/a6
	tst.b	d1
	rts

C10A56:
	movem.l	d2-d7/a0-a3/a5/a6,-(sp)
	fmovem.x	fp1/fp2/fp3/fp4/fp5/fp6/fp7,-(sp)
	bsr.b	C10A12
	fmovem.x	(sp)+,fp1/fp2/fp3/fp4/fp5/fp6/fp7
	movem.l	(sp)+,d2-d7/a0-a3/a5/a6
	tst.b	d1
	rts

C10A6C:
	bclr	#2,d7
	clr	(Math_Level-DT,a4)
	pea	(Parse_GetAnyMathOpp,pc)
	br	Parse_VauleStillUnknown

Parse_rekenen:
	bclr	#2,d7
	clr	(Math_Level-DT,a4)
	pea	(Parse_GetAnyMathOpp,pc)
	br	C10C52

Parse_rekenen2:
	bclr	#2,d7
	clr	(Math_Level-DT,a4)
	pea	(Parse_GetAnyMathOpp,pc)
	bra.b	C10AAC

;*************************

_ERROR_Notdone:
	bra	ERROR_Notdone

;*************************


Parse_GetExprValueInD3Voor:
	bclr	#2,d7		;AF_UNDEFVALUE
C10A9E:	clr	(Math_Level-DT,a4)
C10AA2:	pea	(Parse_GetAnyMathOpp,pc)
C10AA6:	jsr	Get_NextChar
C10AAC:	add.b	d1,d1
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

C10BBA:
	move.l	(LabelStart-DT,a4),a0
	cmp.b	#$7F,-(a0)
	bne	ERROR_UndefSymbol
	bclr	#AF_UNDEFVALUE,d7
	clr	(Math_Level-DT,a4)
	pea	(Parse_GetAnyMathOpp,pc)
	jsr	(Parse_FindLabel).l
	beq	Parse_VauleStillUnknown
	tst	d2
	bpl.w	Parse_FirstAValue
	cmp	#LB_REG,d2
	bne.b	.MayBeMovem
	move.l	d3,d1
	move	#MODE_15,d5
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

Parse_VoorLabelValueInD3_an_dn:
	move.l	(LabelStart-DT,a4),a0
	cmp.b	#$7F,-(a0)
	bne	ERROR_UndefSymbol
	bclr	#AF_UNDEFVALUE,d7
	clr	(Math_Level-DT,a4)
	pea	(Parse_GetAnyMathOpp,pc)
	jsr	(Parse_FindLabel).l
	beq	Parse_VauleStillUnknown
	tst	d2
	bpl.w	Parse_FirstAValue
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
	bne	Parse_VauleStillUnknown
	jsr	(Parse_FindLabel).l
	beq.b	Parse_VauleStillUnknown
C10C52:
	tst	d2
	bpl.w	Parse_FirstAValue
Parse_VoorLabelSpecial:
	swap	d2
	and.b	#$3F,d2
	subq.b	#1,d2
	beq.b	C10CB4
	subq.b	#1,d2
	beq.b	C10CA4
	subq.b	#1,d2
	bne	ERROR_NOTaconstantl
	btst	#SB2_MATH_XN_OK,(SomeBits2-DT,a4)
	beq	ERROR_NOTaconstantl
	bset	#SB2_A_XN_USED,(SomeBits2-DT,a4)
	swap	d3
	cmp	#15,d3
	bne.b	C10C8E
	btst	#5,(statusreg_base-DT,a4)
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

Parse_FirstAValue:
	bclr	#14,d2
	rts

Parse_VauleStillUnknown:
	tst	d7	;passone
	bpl.b	C10CD0
	bset	#2,d7
	moveq	#0,d3
	moveq	#0,d2
	rts

C10CD0:
	btst	#SB2_MATH_XN_OK,(SomeBits2-DT,a4)
	beq	ERROR_UndefSymbol
	lea	(GeenIdee-DT,a4),a3
	move	#$8000,d0
	cmp	(a3),d0
	bne.b	C10CE8
	or.w	d0,-(a3)
C10CE8:
	bsr	C13494
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
	move	(CurrentSection).l,d2
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
	cmp.b	#$5D,(a6)+
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
	dr.w	C10FFA
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10FD0
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10E6E
	dr.w	C10F3E
	dr.w	C10EA8
	dr.w	C10E6E
	dr.w	C10E7A
	dr.w	C10E6E
	dr.w	C10F7C
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
	dr.w	C11102
	dr.w	C11062
	dr.w	C1113E
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
	dr.w	C10ED6
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
	dr.w	C11024
	dr.w	C10E6E

C10E6E:
	subq.w	#1,a6
	lea	(C10E76,pc),a3
	rts

C10E76:
	move.b	(a6),d0
	rts

C10E7A:
	cmp	#2,(Math_Level-DT,a4)
	bcc.b	C10EA2
	move	(Math_Level-DT,a4),-(sp)
	move	#2,(Math_Level-DT,a4)
	bsr	C111C4
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
	cmp	#2,(Math_Level-DT,a4)
	bcc.b	C10ED0
	move	(Math_Level-DT,a4),-(sp)
	move	#2,(Math_Level-DT,a4)
	bsr	C111C4
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
	cmp	#5,(Math_Level-DT,a4)
	bcc.b	C10EFA
	move	(Math_Level-DT,a4),-(sp)
	move	#5,(Math_Level-DT,a4)
	bsr	C111C4
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
	cmp	#3,(Math_Level-DT,a4)
	bcc.b	C10F76
	move	(Math_Level-DT,a4),-(sp)
	move	#3,(Math_Level-DT,a4)
	bsr	C111C4
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

C10F7C:
	cmp	#3,(Math_Level-DT,a4)
	bcc.b	C10FCA
	move	(Math_Level-DT,a4),-(sp)
	move	#3,(Math_Level-DT,a4)
	bsr	C111C4
	tst	d0
	bne	ERROR_RelativeModeEr
	moveq	#0,d4
	tst.l	d3
	bpl.b	C10FA2
	neg.l	d3
	addq.b	#1,d4
C10FA2:
	tst.l	d5
	bpl.b	C10FAA
	neg.l	d5
	addq.b	#1,d4
C10FAA:
	moveq	#$20,d1
	moveq	#0,d0
C10FAE:
	sub.l	d5,d0
	bcc.b	C10FB4
	add.l	d5,d0
C10FB4:
	addx.l	d3,d3
	addx.l	d0,d0
	dbra	d1,C10FAE
	not.l	d3
	lsr.w	#1,d4
	bcc.b	C10FC4
	neg.l	d3
C10FC4:
	move	(sp)+,(Math_Level-DT,a4)
	jmp	(a3)

C10FCA:
	lea	(C10F7C,pc),a3
	rts

C10FD0:
	cmp	#4,(Math_Level-DT,a4)
	bcc.b	C10FF4
	move	(Math_Level-DT,a4),-(sp)
	move	#4,(Math_Level-DT,a4)
	bsr	C111C4
	tst	d0
	bne	ERROR_RelativeModeEr
	and.l	d5,d3
	move	(sp)+,(Math_Level-DT,a4)
	jmp	(a3)

C10FF4:
	lea	(C10FD0,pc),a3
	rts

C10FFA:
	cmp	#4,(Math_Level-DT,a4)
	bcc.b	C1101E
	move	(Math_Level-DT,a4),-(sp)
	move	#4,(Math_Level-DT,a4)
	bsr	C111C4
	tst	d0
	bne	ERROR_RelativeModeEr
	or.l	d5,d3
	move	(sp)+,(Math_Level-DT,a4)
	jmp	(a3)

C1101E:
	lea	(C10FFA,pc),a3
	rts

C11024:
	cmp	#4,(Math_Level-DT,a4)
	bcc.b	C11048
	move	(Math_Level-DT,a4),-(sp)
	move	#4,(Math_Level-DT,a4)
	bsr	C111C4
	tst	d0
	bne	ERROR_RelativeModeEr
	eor.l	d5,d3
	move	(sp)+,(Math_Level-DT,a4)
	jmp	(a3)

C11048:
	lea	(C11024,pc),a3
	rts

C1104E:
	bsr	C111C4
	tst	d0
	beq.b	C1105E
	subq.w	#3,d0
	bne	ERROR_RelativeModeEr
	moveq	#0,d2
C1105E:
	cmp.l	d5,d3
	rts

C11062:
	cmp	#1,(Math_Level-DT,a4)
	bcc.b	C11082
	move	(Math_Level-DT,a4),-(sp)
	move	#1,(Math_Level-DT,a4)
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
	cmp	#1,(Math_Level-DT,a4)
	bcc.b	C110AA
	move	(Math_Level-DT,a4),-(sp)
	move	#1,(Math_Level-DT,a4)
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
	cmp	#1,(Math_Level-DT,a4)
	bcc.b	C110D2
	move	(Math_Level-DT,a4),-(sp)
	move	#1,(Math_Level-DT,a4)
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
	cmp	#1,(Math_Level-DT,a4)
	bcc.b	C110FC
	move	(Math_Level-DT,a4),-(sp)
	move	#1,(Math_Level-DT,a4)
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
	cmp.b	(a6),d0
	beq.b	C11170
	move.b	(a6),d0
	cmp.b	#$3E,d0
	beq	C11088
	cmp.b	#$3D,d0
	beq.b	C110B0
C11116:
	cmp	#1,(Math_Level-DT,a4)
	bcc.b	C11138
	move	(Math_Level-DT,a4),-(sp)
	move	#1,(Math_Level-DT,a4)
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
	cmp.b	(a6),d0
	beq.b	C1119A
	cmp.b	#$3D,(a6)
	beq.b	C110D8
C11148:
	cmp	#1,(Math_Level-DT,a4)
	bcc.b	C1116A
	move	(Math_Level-DT,a4),-(sp)
	move	#1,(Math_Level-DT,a4)
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
	cmp	#5,(Math_Level-DT,a4)
	bcc.b	C11194
	move	(Math_Level-DT,a4),-(sp)
	move	#5,(Math_Level-DT,a4)
	bsr.b	C111C4
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
	cmp	#5,(Math_Level-DT,a4)
	bcc.b	C111BE
	move	(Math_Level-DT,a4),-(sp)
	move	#5,(Math_Level-DT,a4)
	bsr.b	C111C4
	tst	d0
	bne	ERROR_RelativeModeEr
	asr.l	d5,d3
	move	(sp)+,(Math_Level-DT,a4)
	jmp	(a3)

C111BE:
	lea	(C1119C,pc),a3
	rts

C111C4:
	move	d2,-(sp)
	move.l	d3,-(sp)
	bsr	C10AA2
	BTST	#AF_UNDEFVALUE,d7
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
	dr.w	C113FA
	dr.w	C113FA
	dr.w	C113FA
	dr.w	C113FA
	dr.w	C113FA
	dr.w	C113FA
	dr.w	C113FA
	dr.w	C113FA
	dr.w	C113FA
	dr.w	C113FA
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
	sub.b	#7,d0
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
	fmove	(D02F260-DT,a4),fp0
	bra.b	C113EE

C113E8:
	fmove.b	(D02F260-DT,a4),fp0
C113EE:
	moveq	#0,d0
	move	#$0061,d1
	movem.l	(sp)+,d2/d7/a1
	rts

C113FA:
	move.l	#0,(L2F12C-DT,a4)
	move.l	#0,(L2F130-DT,a4)
	movem.l	d3/d4/a2,-(sp)
	lea	(-1,a6),a6
	bsr	C11486
	bvs.w	C1147A
	fmove.x	fp0,fp2
	cmp.b	#$2E,(a6)
	bne.b	C11462
	addq.w	#1,a6
	bsr	C11486
	tst	d2
	beq.b	C11474
	fmove.d	fp0,-(sp)
	move.l	a6,a2
	move.l	d2,d0
	ext.l	d0
	neg.l	d0
	fmove.l	d0,fp1
	ftentox.x	fp1
	bvs.w	C1147A
	fmove.x	fp1,fp0
	fmove.d	(sp)+,fp1
	fmul.x	fp1,fp0
	bvs.w	C1147A
	fmove.x	fp2,fp1
	fadd.x	fp1,fp0
	move.l	a2,a6
	bra.b	C11468

C11462:
	tst	d2
	beq	C11480
C11468:
	moveq	#0,d0
	move	#$0061,d1
	movem.l	(sp)+,d3/d4/a2
	rts

C11474:
	movem.l	(sp)+,d3/d4/a2
	rts

C1147A:
	movem.l	(sp)+,d3/d4/a2
	rts

C11480:
	movem.l	(sp)+,d3/d4/a2
	rts

C11486:
	movem.l	d3/d4/a2,-(sp)
	move.l	a6,a2
	fmove.l	#10,fp0
	fmove.d	fp0,-(sp)
	fmove.l	#0,fp0
	moveq	#0,d3
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
	ori.b	#2,ccr
	movem.l	(sp)+,d3/d4/a2
	rts

Asm_ImmediateOppFloat:
	tst	(FPU_Type-DT,a4)
	beq	ERROR_FPUneededforopp
	bclr	#2,d7
C11500:
	clr	(Math_Level-DT,a4)
C11504:
	pea	(C11666,pc)
C11508:
	jsr	(C1120A).l
	add.b	d1,d1
	add	(W11518,pc,d1.w),d1
	jmp	(W11518,pc,d1.w)

W11518:
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
	move	(CurrentSection).l,d2
	fmove.l	(INSTRUCTION_ORG_PTR-DT,a4),fp0
	rts

C1162A:
	bclr	#14,d2
	rts

C11630:
	bsr	C11508
	fneg.x	fp0
	rts

C1163A:
	move	(Math_Level-DT,a4),-(sp)
	bsr	C11500
	cmp.b	#$5D,(a6)+
	bne	ERROR_Rightparenthe
	move	(sp)+,(Math_Level-DT,a4)
	rts

C11650:
	move	(Math_Level-DT,a4),-(sp)
	bsr	C11500
	cmp.b	#$29,(a6)+
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
	cmp	#2,(Math_Level-DT,a4)
	bcc.b	C117AE
	move	(Math_Level-DT,a4),-(sp)
	move	#2,(Math_Level-DT,a4)
	bsr	C118C8
	fsub.x	fp3,fp0
	fmove.l	fpsr,(L2F26C-DT,a4)
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
	cmp	#2,(Math_Level-DT,a4)
	bcc.b	C117E0
	move	(Math_Level-DT,a4),-(sp)
	move	#2,(Math_Level-DT,a4)
	bsr	C118C8
	fadd.x	fp3,fp0
	fmove.l	fpsr,(L2F26C-DT,a4)
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
	cmp	#5,(Math_Level-DT,a4)
	bcc.b	C11824
	move	(Math_Level-DT,a4),-(sp)
	move	#5,(Math_Level-DT,a4)
	bsr	C118C8
	move.l	d0,-(sp)
	fmove.l	fp3,d0
	fmove.x	fp0,fp3
	subq.l	#1,d0

	beq.b	ExpFin
	bpl.b	ExpLoop
	fmove.s	#1,fp3
;	DC.W	$F23C,$4580,$3F80,$0000
	fdiv.x	fp0,fp3
	neg.l	d0
ExpLoop:
	fmul.x	fp3,fp0
	fmove.l	fpsr,(L2F26C-DT,a4)
	subq.l	#1,d0
	bne.b	ExpLoop
ExpFin:


	move.l	(sp)+,d0
	move	(sp)+,(Math_Level-DT,a4)
	jmp	(a3)

C11824:
	lea	(C117E6,pc),a3
	rts

C1182A:
	cmp	#3,(Math_Level-DT,a4)
	bcc.b	C11850
	move	(Math_Level-DT,a4),-(sp)
	move	#3,(Math_Level-DT,a4)
	bsr	C118C8
	fmul.x	fp3,fp0
	fmove.l	fpsr,(L2F26C-DT,a4)
	move	(sp)+,(Math_Level-DT,a4)
	jmp	(a3)

C11850:
	lea	(C1182A,pc),a3
	rts

C11856:
	cmp	#3,(Math_Level-DT,a4)
	bcc.b	C118C2
	move	(Math_Level-DT,a4),-(sp)
	move	#3,(Math_Level-DT,a4)
	bsr	C118C8
	moveq	#0,d4
	ftst.x	fp3
	fbeq	ERROR_IllegalOperand
	fcmp.x	#0.0,fp3		;fpu
;	DC.B	$F2,$3C,$49,$B8,$00,$00,$00,$00	; i've got no fpu
;	DC.B	$00,$00,$00,$00,$00,$00,$00,$00 ; so don't remove

	fbge.w	C11890
	fneg.x	fp3
	addq.b	#1,d4
C11890:
	fcmp.x	#0.0,fp0		;fpu
;	DC.B	$F2,$3C,$48,$38,$00,$00,$00,$00
;	DC.B	$00,$00,$00,$00,$00,$00,$00,$00

	fbge.w	C118AA
	fneg.x	fp0
	addq.b	#1,d4
C118AA:
	fdiv.x	fp3,fp0
	lsr.w	#1,d4
	bcc.b	C118B6
	fneg.x	fp3
C118B6:
	fmove.l	fpsr,(L2F26C-DT,a4)
	move	(sp)+,(Math_Level-DT,a4)
	jmp	(a3)

C118C2:
	lea	(C11856,pc),a3
	rts

C118C8:
	move	d2,-(sp)
	fmove.x	fp0,-(sp)
	bsr	C11504
	BTST	#AF_UNDEFVALUE,d7
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
	add	#14,sp
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
C11908:
	moveq	#0,d0
	rts

C1190C:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	#command_menus,d0
	jsr	(Init_menustructure).l
	move.l	d0,(Comm_menubase-DT,a4)
	move.l	#Editor_menus,d0
	jsr	(Init_menustructure).l
	move.l	d0,(Edit_Menubase-DT,a4)
	move.l	#monitor_menus,d0
	jsr	(Init_menustructure).l
	move.l	d0,(Monitor_MenuBase-DT,a4)
	tst	(FPU_Type-DT,a4)
	bne.b	C1194E
	move	#16,(W22FFE).l
C1194E:
	move.l	#debug_menus,d0
	jsr	(Init_menustructure).l
	move.l	d0,(Debug_MenuBase-DT,a4)
	movem.l	(sp)+,d0-d7/a0-a6
	rts

C11964:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	(Comm_menubase-DT,a4),d0
	jsr	(Breakdown_menu).l
	move.l	(Edit_Menubase-DT,a4),d0
	jsr	(Breakdown_menu).l
	move.l	(Monitor_MenuBase-DT,a4),d0
	jsr	(Breakdown_menu).l
	move.l	(Debug_MenuBase-DT,a4),d0
	jsr	(Breakdown_menu).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

CommandlineInputHandler:
	bclr	#1,(SomeBits3-DT,a4)	;???
	bclr	#SB2_INSERTINSOURCE,(SomeBits2-DT,a4)
	bclr	#SB3_EDITORMODE,(SomeBits3-DT,a4)	;uit editor
	bset	#MB1_INCOMMANDLINE,(MyBits-DT,a4)	;in commandline mode

	move.l	d0,-(sp)
	move.l	(Comm_menubase-DT,a4),d0
	move.b	#MT_COMMAND,(menu_tiepe-DT,a4)
	jsr	(Change_2menu_d0).l
	move.l	(sp)+,d0
	bset	#SB2_MATH_XN_OK,(SomeBits2-DT,a4)
	btst	#SB1_CLOSE_FILE,(SomeBits-DT,a4)
	beq.b	.FileClosed
	bsr	close_bestand
.FileClosed:
	move.l	(DATA_USERSTACKPTR-DT,a4),sp
	clr	(SST_STEPS-DT,a4)
	move.b	#$FF,(B2BEB8-DT,a4)	;NOBREAK
	clr.l	(DATA_CURRENTLINE-DT,a4)
	moveq	#0,d7

	clr.w	(Cursor_col_pos-DT,a4)	;x reset col pos
	jsr	Place_cursor_blokje

	lea	(Prompt_Char,pc),a0
	bsr	Druk_CmdMenuText
	move.b	#21,(B2BEB8-DT,a4)	;AMIGA_C
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
	moveq	#10,d0
	bsr	SENDONECHARNORMAL
	moveq	#0,d0
	bsr	SENDONECHARNORMAL
	move.b	(a6)+,d0
	cmp.b	#'!',d0
	beq.b	exit_or_extentie
	cmp.b	#'#',d0
	beq	About_req
	cmp.b	#'a',d0
	bcs.b	.Hoofdletter
	sub.b	#$20,d0
.Hoofdletter:
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
	move.l	d0,-(sp)
	move.l	(Comm_menubase-DT,a4),d0
	move.b	#MT_COMMAND,(menu_tiepe-DT,a4)
	jsr	(Change_2menu_d0).l
	move.l	(sp)+,d0
	cmp.b	#$61,d1
	jsr	(a5)
	br	CommandlineInputHandler

exit_or_extentie:
	cmp.b	#"!",(a6)
	beq.b	C11AAA		;"!!"
	cmp.b	#"R",(a6)
	beq.b	exit_restart		;"!R"
	cmp.b	#"r",(a6)
	beq.b	exit_restart		;"!R"

	tst.b	(a6)
	bne.b	C11AB2
	move.b	(CurrentSource-DT,a4),d1
	move.b	d1,(B30174-DT,a4)
	add.b	#$30,d1
	move.b	d1,(SourceNrInBalk).l
	jmp	(C1E392).l

exit_restart:
	moveq	#"R",d0
	jmp	(Restart_Entrypoint).l

C11AAA:
	moveq	#"Y",d0
	jmp	(Restart_Entrypoint).l

C11AB2:
	clr.b	(16,a6)
	bsr	change_extention
	br	CommandlineInputHandler

C11ABE:
	jsr	(C4240).l
	move.b	d1,(OpperantSize-DT,a4)
	rts

C11ACA:
	jsr	(Parse_GetFloatSize).l
	move.b	d1,(OpperantSize-DT,a4)
	rts

About_req:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	#1,(RequesterType).l
	lea	(_Ok_Ok.MSG).l,a2
	lea	(AsmPro_abouttxt.MSG).l,a1
	jsr	ShowReqtoolsRequester
	movem.l	(sp)+,d0-d7/a0-a6
	br	CommandlineInputHandler

Error_req:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	#1,(RequesterType).l	;text
	lea	(_Ok_Ok.MSG).l,a2
	jsr	ShowReqtoolsRequester
	movem.l	(sp)+,d0-d7/a0-a6
	rts

GETNUMBERAFTEROK:
	move.l	a5,-(sp)
	bsr	C11ABE
	move	(OpperantSize-DT,a4),-(sp)
	bsr	Convert_A2I
	move	(sp)+,(OpperantSize-DT,a4)
	cmp.b	#1,(OpperantSize-DT,a4)
	beq.b	C11B2E
	btst	#0,d0
	beq.b	C11B2E
	cmp	#2,(ProcessorType-DT,a4)
	bge.b	C11B2E
	cmp.b	#$61,d1
	beq	ERROR_WordatOddAddress
C11B2E:
	move.l	(sp)+,a5
	cmp.b	#$61,d1
	rts

C11B36:
	move.l	a5,-(sp)
	bsr	C11ACA
	move	(OpperantSize-DT,a4),-(sp)
	bsr	C10A56
	move	(sp)+,(OpperantSize-DT,a4)
	btst	#0,d0
	beq.b	C11B5E
	cmp	#2,(ProcessorType-DT,a4)
	bge.b	C11B2E
	cmp.b	#$61,d1
	beq	ERROR_WordatOddAddress
C11B5E:
	move.l	(sp)+,a5
	cmp.b	#$61,d1
	rts

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
	bne.b	C11BD2
	jmp	(C1B2DA).l

C11BD2:
	cmp.b	#9,d0		;TAB
	beq.b	C_AsmPrefs
	cmp.b	#12,d0		;FF
	beq.b	C_EnvPrefs
	cmp.b	#70,d0		;Amiga-Z
	beq.b	C_SyntPrefs
	cmp.b	#$65,d0		;'e'
	beq.b	C11C26
	cmp.b	#$2D,d0		;'-'
	bne.b	C11BF0
	jmp	(com_assemble).l

C11BF0:
	cmp.b	#$3B,d0		;';'
	bne.b	C11BFC
	jmp	(C2AD4).l

C11BFC:
	cmp.b	#$30,d0		;'0'
	bne.b	C11C36
	jmp	(Enter_debugger).l


C_SyntPrefs:
	move.b	#2,(Prefs_tiepe-DT,a4)
	bra.b	C_doprefs

C_EnvPrefs:
	move.b	#1,(Prefs_tiepe-DT,a4)
	bra.b	C_doprefs

C_AsmPrefs:
	move.b	#0,(Prefs_tiepe-DT,a4)
C_doprefs:
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(Handle_prefs_windows).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

C11C26:
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(AmigaGuideGedoe).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

C11C36:
	addq.w	#4,sp
	br	CommandlineInputHandler

Enter_Editor1:
	move	(AantalRegels_Editor-DT,a4),d0
	move	(Scr_br_chars-DT,a4),(breedte_editor_in_chars-DT,a4)
	bsr.b	OPED_SETNBOFFLINES
	jmp	(ACTIVATEEDITORWINDOW).l

Enter_Editor2:
	jsr	Show_Cursor
	move	(AantalRegels_HalveEditor-DT,a4),d0
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
	move	d0,(NrOfLinesInEditor-DT,a4)
	subq.w	#1,d0
	move	d0,(NrOfLinesInEditor_min1-DT,a4)

	addq.w	#1,d1
	divu	#100,d1
	add	#'0',d1
	move.b	d1,infopos1
	swap	d1
	ext.l	d1
	divu	#10,d1
	add	#'0',d1
	move.b	d1,infopos2
	swap	d1
	add	#'0',d1
	move.b	d1,infopos3
	move	(sp)+,d1
	rts

ErrMsgNoDebug:
	btst	#$1D,d7
	bne	Druk_Af_Regel1
	btst	#$1C,d7
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
	bsr	new2old_stuff
	jmp	(CommandlineInputHandler).l

C11CF0:
	lea	(Not.MSG,pc),a0
	br	C105DE

C11CF8:
	lea	(HReAssembling.MSG,pc),a0
	bsr	printthetext
	bsr	new2old_stuff
	jmp	(ReAssemble).l

;*********** show error pos in string **************

Print_DrukErrorRegel:
	move.l	(ParsePos-DT,a4),d7
	move.l	(FirstLinePtr-DT,a4),a0

	sub.l	a0,d7
	subq.l	#1,d7
	bmi.s	ErrMsgNoDeal
	cmp.l	#128,d7
	bhi.s	ErrMsgNoDeal

	lea	(regel_buffer-DT,a4),a1
	move.l	a1,-(sp)
.lopje:
	move.b	(a0)+,(a1)+
	dbf	d7,.lopje
	move.b	#0,(a1)

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
	move.b	#$9B,d0
	bsr	SENDONECHARNORMAL
	move.b	#$31,d0		;'1'
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
	
	addq.w	#8,a0
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
	cmp.l	#1,d0
	beq.s	.megaJump

.lopje:
	subq.l	#1,a0
	tst.b	(a0)
	bne.s	.lopje
.out:
	move.l	a0,(sp)		;re-set pointer

	bsr	druk_af_space
	move.l	(ErrorLijnInCode-DT,a4),d0
	subq.l	#1,d0
	bsr	Druk_D0_inCommandline
	bsr	druk_af_space

	move.l	(sp)+,a0
	bsr	.drukerrorregels
	move.l	a0,-(sp)

.megaJump:
	move.b	#$BB,d0
	bsr	SENDONECHARNORMAL

	move.l	(ErrorLijnInCode-DT,a4),d0
	bsr	Druk_D0_inCommandline
	bsr	druk_af_space
	bsr	Druk_Clearbuffer

	bset	#SB2_REVERSEMODE,(SomeBits2-DT,a4)
	move.l	(sp)+,a0
	bsr	.drukerrorregels
	move.l	a0,-(sp)

	bsr	druk_af_space
	move.l	(ErrorLijnInCode-DT,a4),d0
	addq.l	#1,d0
	bsr	Druk_D0_inCommandline
	bsr	druk_af_space

	move.l	(sp)+,a0
	bsr	.drukerrorregels
	br	druk_cr_nl

.drukerrorregels:
	subq.w	#1,a0
.C11E1C:
	cmp.b	#$19,(a0)
	beq.b	.C11E2A
	tst.b	(a0)
	beq.b	.C11E2A
	subq.w	#1,a0
	bra.b	.C11E1C

.C11E2A:
	addq.w	#1,a0
	bsr	printthetext
	bsr     Druk_Clearbuffer
	bclr    #SB2_REVERSEMODE,(SomeBits2-DT,a4)
	bsr	druk_cr_nl
	rts	

Druk_Af_Regel1:
	move.l	a1,-(sp)
	move.l	(AsmErrorPos-DT,a4),a1
	cmp.l	#AsmEindeErrorTable,a1
	beq.b	C11E54
	move.l	(DATA_CURRENTLINE-DT,a4),(a1)
	move.l	a0,(4,a1)
	addq.w	#8,a1
	move.l	#$FFFFFFFF,(a1)
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
C11E7C:
	tst.b	(a6)+
	bne.b	C11E7C
	move.l	a6,-(sp)
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
	jsr	(printthetext).l
	move.l	(pcounter_base-DT,a4),d0
	bsr	druk_af_d0
	lea	(Accessing.MSG,pc),a0
	bsr	printthetext
	move.l	(DATA_BUSPTRHI).l,d0
	bsr	druk_af_d0
	bsr	printthetext
	move	(DATA_BUSACCESS).l,d1
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
	move	d1,d0
	and	#7,d0
	add	#$0030,d0
	bsr	SENDONECHARNORMAL
	bsr	printthetext
	move	(DATA_BUSFAILINST-DT,a4),d0
	bsr	C15900
	jmp	(EXHA_JUSTRETURN).l

com_apestaartje:
	move.b	(a6)+,d0
	bclr	#5,d0
	cmp.b	#$44,d0		;'D'
	beq	C13832
	cmp.b	#$48,d0		;'H'
	beq	C1226E
	cmp.b	#$4E,d0		;'N'
	beq	C126F6
	cmp.b	#$42,d0		;'B'
	beq.b	C11FA6
	cmp.b	#$41,d0		;'A'
	bne.b	C11FA4
	jmp	(LINE_MEMASSEM).l

C11FA4:
	rts

C11FA6:
	clr.b	(B30040-DT,a4)
	cmp.b	#$7B,(a6)
	bne.b	C11FB8
	move.b	#1,(B30040-DT,a4)
	addq.w	#1,a6
C11FB8:
	bsr	GETNUMBERAFTEROK
	beq.b	C11FC2
	move.l	(MEM_DIS_DUMP_PTR-DT,a4),d0
C11FC2:
	tst.b	(B30040-DT,a4)
	beq.b	C11FF0
	cmp.b	#1,(OpperantSize-DT,a4)
	beq.b	C11FDA
	tst	(ProcessorType-DT,a4)
	bne.b	C11FDA
	bclr	#0,d0
C11FDA:
	move.l	d0,a5
	move.l	(a5),d0
	cmp.b	#1,(OpperantSize-DT,a4)
	beq.b	C11FF0
	tst	(ProcessorType-DT,a4)
	bne.b	C11FF0
	bclr	#0,d0
C11FF0:
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
	bsr	Druk_af_D0
	moveq	#$25,d0
	bsr	SENDONECHARNORMAL
C12018:
	bsr	C1202E
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
	bsr	C120AE
	dbra	d3,C12036
	br	druk_af_space

C12044:
	bsr	C11ABE
	moveq	#0,d7
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
	bsr	C120AE
	dbra	d4,C1208A
	cmp.l	a3,a2
	bls.b	C1209E
	bsr	Druk_af_eol
	bra.b	C12062

C1209E:
	bsr	Druk_af_eol
	moveq	#0,d0
	bsr	SENDONECHARNORMAL
	move.l	(sp)+,(FirstLinePtr-DT,a4)
	rts

C120AE:
	movem.l	d0-d7/a0-a6,-(sp)
	move.b	d0,d1
	moveq	#7,d7
C120B6:
	moveq	#$30,d0
	btst	d7,d1
	beq.b	C120BE
	moveq	#$31,d0
C120BE:
	bsr	SENDONECHARNORMAL
	dbra	d7,C120B6
	movem.l	(sp)+,d0-d7/a0-a6
	rts

com_printen:
	move.b	(a6),d0
	and.b	#$df,d0

	IF useplugins
	cmp.b	#'W',d0		;plugin's windowtje
	bne.s	.noplugs
	jmp	E_Showplugs
.noplugs:
	ENDIF
	
	cmp.b	#$53,(a6)	;S
	beq.b	C120DA
	cmp.b	#$73,(a6)	;s
	bne	C1210E
C120DA:
	lea	(Startupparame.MSG,pc),a0
	bsr	INPUTTEXT
	tst.b	(CurrentAsmLine-DT,a4)
	beq.b	C1210C
	lea	(CurrentAsmLine-DT,a4),a1
	lea	(Parameters-DT,a4),a0
	moveq	#0,d0
C120F2:
	move.b	(a1)+,(a0)+
	addq.w	#1,d0
	cmp	#$00FE,d0
	beq.b	C12100
	tst.b	(a1)
	bne.b	C120F2
C12100:
	move.b	#10,(a0)+
	clr.b	(a0)
	addq.w	#1,d0
	move.l	d0,(ParametersLengte-DT,a4)
C1210C:
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
	cmp.b	#$1A,(a0)
	beq	ERROR_EndofFile
	bsr	printthetext
	bsr	druk_cr_nl
	subq.l	#1,d5
	bne.b	C12122
C12146:
	rts

com_execute_dos:
	tst.b	(a6)
	beq	C121EA
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	a6,-(sp)
	move.l	(ScreenBase).l,a0
	move	#17,($0014,a0)		;screen flags
	move.l	(DosBase-DT,a4),a6
	move.l	#CON00635200Do.MSG,d1
	move.l	#$000003ED,d2
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOOpen,a6)
	move.l	d0,(L2F120-DT,a4)
	beq.b	C121EC
	move.l	(sp)+,d1
	moveq.l	#0,d2
	move.l	(L2F120-DT,a4),d3
	tst.l	(L2F120-DT,a4)
	bne.b	C12196
	moveq.l	#0,d3
C12196:
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOExecute,a6)
	move.l	(L2F120-DT,a4),d1
	move.l	#Executioncomp.MSG,d2
	moveq.l	#$00000023,d3
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOWrite,a6)
	move.l	(L2F120-DT,a4),d1
	move.l	#L1226A,d2
	moveq.l	#1,d3
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVORead,a6)
	move.l	(L2F120-DT,a4),d1
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOClose,a6)
	move.l	(ScreenBase).l,a0
	move	#31,($0014,a0)		;screen flags
	movem.l	(sp)+,d0-d7/a0-a6
C121EA:
	rts

C121EC:
	move.l	(sp)+,a6
	movem.l	(sp)+,d0-d7/a0-a6
	rts

CON00635200Do.MSG:
	dc.b	'CON:0/0/635/200/Dos command output window',0
Executioncomp.MSG:
	dc.b	'Execution complete. Press return...'
	even
L1226A:
	dc.l	0

C1226E:
	clr.b	(B30040-DT,a4)
	cmp.b	#$7B,(a6)
	bne.b	C12280
	move.b	#1,(B30040-DT,a4)
	addq.w	#1,a6
C12280:
	bsr	GETNUMBERAFTEROK
	beq.b	C1228A
	move.l	(MEM_DIS_DUMP_PTR-DT,a4),d0
C1228A:
	tst.b	(B30040-DT,a4)
	beq.b	C122B8
	cmp.b	#1,(OpperantSize-DT,a4)
	beq.b	C122A2
	tst	(ProcessorType-DT,a4)
	bne.b	C122A2
	bclr	#0,d0
C122A2:
	move.l	d0,a5
	move.l	(a5),d0
	cmp.b	#1,(OpperantSize-DT,a4)
	beq.b	C122B8
	tst	(ProcessorType-DT,a4)
	bne.b	C122B8
	bclr	#0,d0
C122B8:
	move.l	d0,d5
	move.l	d0,a5
	move.l	d0,a3
	moveq	#7,d6
C122C0:
	addq.l	#8,d5
	addq.l	#8,d5
	move.l	a5,d0
	bsr	Druk_af_D0
C122CA:
	bsr	C1381C
	cmp.l	d5,a5
	bne.b	C122CA
	moveq	#$22,d0
	bsr	SENDONECHARNORMAL
C122D8:
	move.b	(a3)+,d0
	and	#$007F,d0
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
	move.b	(a6),d0
	bclr	#5,d0
	cmp.b	#$4C,d0
	bne	C12566
	move.b	(SomeBits2-DT,a4),(SomeBits2Backup-DT,a4)
	move	#1,(ProgressCntr-DT,a4)
	move	#1,(ProgressSpeed-DT,a4)
	lea	(Extendlabelsw.MSG).l,a0
	bsr	INPUTTEXT
	move.b	#0,(B30172-DT,a4)
	lea	(PrefixYN.MSG).l,a0
	bsr	beeldtextaf
	
	bsr	GetHotKey
	bclr	#5,d0
	cmp.b	#$59,d0
	bne.b	C12356
	move.b	#1,(B30172-DT,a4)
C12356:
	lea	(HPass1.MSG).l,a0
	jsr	(beeldtextaf).l
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
	cmp.b	#9,d1		;'	'
	beq.b	C123BA
	cmp.b	#$1A,d1		;
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
	cmp.b	#$1A,(a0)
	beq.b	C123D6
	tst.b	(a0)+
	bne.b	C123CA
	bra.b	C12370

C123D6:
	movem.l	d0/a0,-(sp)
	lea	(CurrentAsmLine-DT,a4),a0
	moveq	#0,d0
C123E0:
	tst.b	(a0)+
	beq.b	C123E8
	addq.w	#1,d0
	bra.b	C123E0

C123E8:
	move.l	d0,(L2FCEA-DT,a4)
	movem.l	(sp)+,d0/a0
	move.b	#$FF,(a2)
	lea	(HPass2.MSG).l,a0
	jsr	(beeldtextaf).l
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
	cmp.b	#$1A,d0
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
	bcc.w	C12516
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
	tst.b	d0
	beq	C124DE
	cmp.b	#9,d0
	beq.b	C124DE
	cmp.b	#$19,d0
	beq.b	C124DE
	lea	(B124CE,pc),a1
C124C0:
	cmp.b	#$FF,(a1)
	beq.b	C124A8
	cmp.b	(a1),d0
	beq.b	C124DE
	addq.w	#1,a1
	bra.b	C124C0

B124CE:
	DC.B	' #+-=[,.*/<>(!'
	dc.b	$FF
	dc.b	0

C124DE:
	move.l	(sp)+,a1
	addq.w	#1,a0
C124E2:
	move.l	a0,(FirstLinePtr-DT,a4)
	movem.l	d0-d7/a0-a6,-(sp)
	moveq	#0,d0
	lea	(CurrentAsmLine-DT,a4),a0
	bsr	printthetext
	moveq	#0,d0
	bsr	SENDONECHARNORMAL
	movem.l	(sp)+,d0-d7/a0-a6
	move.l	(FirstLinePtr-DT,a4),a0
	tst.b	(B30172-DT,a4)
	beq	C12410
	move.l	(sp)+,a0
	add.l	(L2FCEA-DT,a4),a0
	addq.l	#1,a0
	br	C12410

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
	moveq	#0,d0
	bsr	SENDONECHARNORMAL
	bclr	#1,(SomeBits3-DT,a4)	;???
	bclr	#SB2_INSERTINSOURCE,(SomeBits2-DT,a4)
	bclr	#SB3_EDITORMODE,(SomeBits3-DT,a4)	;uit editor
	move.l	d0,-(sp)
	move.l	(Comm_menubase-DT,a4),d0
	move.b	#MT_COMMAND,(menu_tiepe-DT,a4)
	jsr	(Change_2menu_d0).l
	move.l	(sp)+,d0
	bset	#SB2_MATH_XN_OK,(SomeBits2-DT,a4)
	moveq	#0,d0
	br	com_top

C12566:
	bsr	GETNUMBERAFTEROK
	cmp.b	#$61,d1
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
	tst.b	(a6)+
	beq.b	C1259E
	tst.b	(a6)+
	beq.b	C1259E
	tst.b	(a6)+
	beq.b	C1259E
	tst.b	(a6)+
	bne.b	C1258E
C1259E:
	cmp.b	#$1A,(a6)
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
	cmp.b	#$3E,d0
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
	cmp	#$D24E,d0	"RN"
	bne.b	C12586
	jsr	RemoveWS
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
	bsr	incbinsub1
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

com_terughalen:
	move.b	(a6)+,d0
	bclr	#5,d0
	cmp.b	#$53,d0
	bne.b	C12676
	move.b	(a6)+,d0
C12676:
	move.l	(sourcestart-DT,a4),a0
	cmp.b	#$1A,(a0)
	bne.b	C12684
	move.b	#$3B,(a0)+
C12684:
	pea	(C13BAE,pc)
C12688:
	bclr	#SB2_INDEBUGMODE,(SomeBits2-DT,a4)
	move.l	(sourcestart-DT,a4),a0
	move.l	a0,a2
	move.l	(WORK_END-DT,a4),a1
	cmp.l	a0,a1
	beq.b	C126EA
	move.b	-(a1),d2
	move.b	#$1A,(a1)+
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
	cmp.b	#$1A,d0
	bne.b	C126AA
	move.b	d2,-(a1)
	cmp.b	-(a0),d0
	bne.b	C126EA
	tst.b	(-1,a2)
	beq.b	C126DC
	cmp.b	#$19,(-1,a2)
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
	moveq	#$1A,d0
	bra.b	C126DC

C126F6:
	clr.b	(B30040-DT,a4)
	cmp.b	#$7B,(a6)
	bne.b	C12708
	move.b	#1,(B30040-DT,a4)
	addq.w	#1,a6
C12708:
	bsr	GETNUMBERAFTEROK
	beq.b	C12712
	move.l	(MEM_DIS_DUMP_PTR-DT,a4),d0
C12712:
	tst.b	(B30040-DT,a4)
	beq.b	C12740
	cmp.b	#1,(OpperantSize-DT,a4)
	beq.b	C1272A
	tst	(ProcessorType-DT,a4)
	bne.b	C1272A
	bclr	#0,d0
C1272A:
	move.l	d0,a3
	move.l	(a3),d0
	cmp.b	#1,(OpperantSize-DT,a4)
	beq.b	C12740
	tst	(ProcessorType-DT,a4)
	bne.b	C12740
	bclr	#0,d0
C12740:
	move.l	d0,a3
	moveq	#7,d6
C12744:
	move.l	a3,d0
	bsr	Druk_af_D0
	moveq	#$22,d0
	bsr	SENDONECHARNORMAL
	move.l	a3,d5
	moveq	#$3F,d5
C12754:
	move.b	(a3)+,d0
	move.b	d0,d1
	and	#$007F,d1
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
	moveq	#0,d7
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
	moveq	#0,d7
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
	moveq	#0,d0
	bsr	SENDONECHARNORMAL
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
	cmp.b	#$53,d0
	beq.b	C12920
	cmp.b	#$20,d3
	beq	C1823E
	tst.b	d0
	bne	ERROR_IllegalComman
	br	C181DA

C12920:
	clr.l	(L2DF4C).l
	bra.b	C1293A

C12928:
	lea	(DEST.MSG,pc),a0
	bsr	Druk_MsgAf_GetNumbr
	bne	ERROR_Notdone
	move.l	d0,(L2DF4C).l
C1293A:
	lea	(BEG.MSG,pc),a0
	bsr	Druk_MsgAf_GetNumbr
	bne	ERROR_Notdone
	move.l	d0,(L2DF50).l
	lea	(END.MSG0,pc),a0
	bsr	Druk_MsgAf_GetNumbr
	bne	ERROR_Notdone
	move.l	d0,(L2DF54).l
	lea	(AMOUNT.MSG,pc),a0
	bsr	Druk_MsgAf_GetNumbr
	bne	ERROR_Notdone
	move.l	d0,(L2DF58).l
	beq	ERROR_Notdone
	lea	(AMPLITUDE.MSG,pc),a0
	bsr	Druk_MsgAf_GetNumbr
	bne	ERROR_Notdone
	move.l	d0,(L2DF5C).l
	lea	(YOFFSET.MSG,pc),a0
	bsr	Druk_MsgAf_GetNumbr
	bne	ERROR_Notdone
	move.l	d0,(L2DF60).l
	clr.l	(L2DF64).l
	lea	(SIZEBWL.MSG,pc),a0
	bsr	beeldtextaf
	bsr	GetHotKey
	bclr	#5,d0
	move.l	#1,(L2DF64).l
	cmp.b	#$42,d0
	beq.b	C129E2
	move.l	#2,(L2DF64).l
	cmp.b	#$57,d0
	beq.b	C129E2
	move.l	#3,(L2DF64).l
	cmp.b	#$4C,d0
	beq.b	C129E2
	br	ERROR_Notdone

C129E2:
	lea	(MULTIPLIER.MSG,pc),a0
	bsr	Druk_MsgAf_GetNumbr
	bne	ERROR_Notdone
	move.l	d0,(L2DF68).l
	clr.l	(B2DF6C).l
	lea	(HALFCORRECTIO.MSG,pc),a0
	bsr	beeldtextaf
	bsr	GetHotKey
	bclr	#5,d0
	cmp.b	#'N',d0
	beq.b	C12A20
	bset	#0,(B2DF6F).l
	cmp.b	#'Y',d0
	bne	ERROR_Notdone
C12A20:
	lea	(ROUNDCORRECTI.MSG,pc),a0
	bsr	beeldtextaf
	bsr	GetHotKey
	bclr	#5,d0
	cmp.b	#'N',d0
	beq.b	C12A46
	bset	#1,(B2DF6F).l
	cmp.b	#'Y',d0
	bne	ERROR_Notdone
C12A46:
	movem.l	d0-d7/a1-a6,-(sp)
	bsr.b	C12A54
	movem.l	(sp)+,d0-d7/a1-a6
	br	beeldtextaf

C12A54:
	move.l	(4).w,a6
	lea	(MathffpName,pc),a1
	jsr	(_LVOOldOpenLibrary,a6)
	move.l	d0,(MathFfpBase-DT,a4)
	bne.b	C12A6C
	lea	(Couldntopenma.MSG,pc),a0
	rts

C12A6C:
	lea	(MathtransName,pc),a1
	jsr	(_LVOOldOpenLibrary,a6)
	move.l	d0,(MathTransBase-DT,a4)
	bne.b	C12A88
	move.l	(MathFfpBase-DT,a4),a1
	jsr	(_LVOCloseLibrary,a6)		; ***
	lea	(Couldntopenma.MSG0,pc),a0
	rts

C12A88:
	move.b	(SomeBits2-DT,a4),d0
	move	d0,-(sp)
	bclr	#SB2_INDEBUGMODE,(SomeBits2-DT,a4)
	bset	#SB2_INSERTINSOURCE,(SomeBits2-DT,a4)
	move.l	(FirstLinePtr-DT,a4),-(sp)
	moveq	#0,d3
	move.l	(MathFfpBase-DT,a4),a6
	move.l	(MathTransBase-DT,a4),a5
	move.l	(L2DF54-DT,a4),d0
	sub.l	(L2DF50-DT,a4),d0
	jsr	(_LVOSPFlt,a6)		; ***
	move.l	#$8EFA353B,d1
	jsr	(_LVOSPMul,a6)		; ***
	move.l	d0,-(sp)
	move.l	(L2DF58-DT,a4),d0
	jsr	(_LVOSPFlt,a6)		; ***
	move.l	d0,d1
	move.l	(sp)+,d0
	jsr	(_LVOSPDiv,a6)		; ***
	move.l	d0,(L2DF7C-DT,a4)
	move.l	(L2DF50-DT,a4),d0
	jsr	(_LVOSPFlt,a6)		; ***
	move.l	#$8EFA353B,d1
	jsr	(_LVOSPMul,a6)		; ***
	btst	#0,(B2DF6F-DT,a4)
	beq.b	C12AF8
	move.l	(L2DF7C-DT,a4),d1
	subq.b	#1,d1
	jsr	(_LVOSPAdd,a6)		; ***
C12AF8:
	move.l	d0,(L2DF78-DT,a4)
	move.l	(L2DF5C-DT,a4),d0
	jsr	(_LVOSPFlt,a6)		; ***
	move.l	d0,(L2DF80-DT,a4)
	move.l	(L2DF58-DT,a4),d7
	move.l	(L2DF4C-DT,a4),a3
C12B10:
	move.l	(L2DF78-DT,a4),d0
	exg	a5,a6
	jsr	(_LVOSPSin,a6)		; ***
	exg	a5,a6
	move.l	(L2DF80-DT,a4),d1
	jsr	(_LVOSPMul,a6)		; ***
	btst	#1,(B2DF6F-DT,a4)
	beq.b	C12B42
	move.l	#$80000040,d1
	btst	#7,d0
	beq.b	C12B3E
	move.l	#$800000C0,d1
C12B3E:
	jsr	(_LVOSPAdd,a6)		; ***
C12B42:
	jsr	(_LVOSPFix,a6)		; ***
	add.l	(L2DF60-DT,a4),d0
	move.l	(L2DF68-DT,a4),d2
	beq.b	C12B52
	muls	d2,d0
C12B52:
	cmp.l	a3,d3
	bne	C12C46
	cmp.b	#1,(B2DF67-DT,a4)
	bne.b	C12B9C
	move	d0,-(sp)
	tst	(W2DF4E-DT,a4)
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
	move	(W2DF4E-DT,a4),d0
	addq.w	#1,d0
	and	#15,d0
	move	d0,(W2DF4E-DT,a4)
	bne.b	C12B9C
	moveq	#1,d3
	bsr	Druk_af_eol
	moveq	#0,d3
C12B9C:
	cmp.b	#2,(B2DF67-DT,a4)
	bne.b	C12BEA
	move	d0,-(sp)
	tst	(W2DF4E-DT,a4)
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
	move	(W2DF4E-DT,a4),d0
	addq.w	#1,d0
	move	d0,(W2DF4E-DT,a4)
	cmp	#10,d0
	bne.b	C12BEA
	clr	(W2DF4E-DT,a4)
	moveq	#1,d3
	bsr	Druk_af_eol
	moveq	#0,d3
C12BEA:
	cmp.b	#3,(B2DF67-DT,a4)
	bne.b	C12C64
	move.l	d0,-(sp)
	tst	(W2DF4E-DT,a4)
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
	move	(W2DF4E-DT,a4),d0
	addq.w	#1,d0
	move	d0,(W2DF4E-DT,a4)
	cmp	#6,d0
	bne.b	C12C64
	clr	(W2DF4E-DT,a4)
	moveq	#1,d3
	bsr	Druk_af_eol
	moveq	#0,d3
	bra.b	C12C64

C12C46:
	cmp.b	#1,(B2DF67-DT,a4)
	bne.b	C12C50
	move.b	d0,(a3)+
C12C50:
	cmp.b	#2,(B2DF67-DT,a4)
	bne.b	C12C5A
	move	d0,(a3)+
C12C5A:
	cmp.b	#3,(B2DF67-DT,a4)
	bne.b	C12C64
	move.l	d0,(a3)+
C12C64:
	move.l	(L2DF78-DT,a4),d0
	move.l	(L2DF7C-DT,a4),d1
	jsr	(_LVOSPAdd,a6)			; ***
	move.l	d0,(L2DF78-DT,a4)
	subq.l	#1,d7
	bne	C12B10
	move.l	(4).w,a6
	move.l	(MathFfpBase-DT,a4),a1
	jsr	(_LVOCloseLibrary,a6)
	move.l	(MathTransBase-DT,a4),a1
	jsr	(_LVOCloseLibrary,a6)		; ***
	cmp.l	a3,d3
	bne.b	C12C9E
	moveq	#1,d3
;	moveq	#0,d0
;	bsr	SENDONECHARNORMAL
	bsr	Druk_af_eol
	bsr	Druk_Clearbuffer
	bsr	Druk_af_eol

C12C9E:
	move.l	(sp)+,(FirstLinePtr-DT,a4)
	lea	(Sinuscreated.MSG,pc),a0
	move	(sp)+,d0
	move.b	d0,(SomeBits2-DT,a4)
	rts

; ID command
Insert_Disassembly:
	moveq	#0,d7
	bsr	INPUTBEGINEND
	bclr	#SB2_INDEBUGMODE,(SomeBits2-DT,a4)
	cmp	#1,(ProcessorType-DT,a4)
	bgt.b	C12CC6
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
	jsr	(C1FE7E).l
	bsr	printthetext
	bsr	Druk_af_eol
	move.l	(sp)+,a3
	cmp.l	a3,a5
	bcs.b	C12CDC

	move.l	a5,(MEM_DIS_DUMP_PTR-DT,a4)
	moveq	#0,d0
	bsr	SENDONECHARNORMAL
	bclr	#SB2_INSERTINSOURCE,(SomeBits2-DT,a4)
	lea	(Removeunusedl.MSG,pc),a0
	bsr	beeldtextaf
	bsr	GetHotKey
	move.l	(FirstLinePtr-DT,a4),a3
	move.l	(sp)+,a2
	lea.l	(a2),a5
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
	lea.l	(a5),a0				; first line
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
	lea.l	(a5),a2
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
	lea.l	(a5),a2
	cmp.l	a3,a5
	beq.b	C12DCA
	bset	#5,(a5)
C12DA6:
	cmp.l	a3,a5
	beq.b	C12DCA
	bclr	#5,(a5)
	bne.b	C12DB2
	lea.l	10(a5),a5			; pass label and replace
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
	bne	C134F4
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

	move.l	(a1),d0
	move.l	(a2),d1
	btst	#13,(statusreg_base-DT,a4)
	bne.b	C12E28
	move.l	(4,a1),d0
	move.l	(4,a2),d1
C12E28:
	bsr	C1326A
	bsr	druk_af_space
	bsr	printthetext
	bsr	convert_getal
	bsr	druk_af_space
	bsr	printthetext
	bsr	convert_getal
	bsr	druk_af_space
	bsr	printthetext
	bsr	C131BE
	bsr	druk_af_space
	bsr	C131DA
	bsr	C131E2
	bsr	druk_af_space
	bsr	C1320C
	bsr	printthetext
	move.l	(a1),a5
	bsr	debug_regs2old
	move.l	a5,d0
	cmp.l	#eop_irq_routine,d0
	beq	C1315E

	jsr	(druk_af_d0).l
	tst	(ProcessorType-DT,a4)
	beq	C12ED8
	move.l	a0,-(sp)
	moveq	#$20,d0
	bsr	SENDONECHARNORMAL
	lea	(VBR.MSG).l,a0
	bsr	printthetext
	move.l	(VBR_base_ofzo-DT,a4),d0
	move.l	(VBR_Base2-DT,a4),d1
	bsr	C1326A
	bsr	druk_af_space
	tst	(FPU_Type-DT,a4)
	beq.b	C12ED6

	tst.b	(PR_FPU_Present).l
	beq.b	C12ED6
	
	bsr.b	C12EFC
	bsr	C12F70
	bsr	C1307E
	bsr	C12FB4
	bsr	C12F9E
	bsr	C130D6
	bsr	C13012
	bsr	C130F6
C12ED6:
	move.l	(sp)+,a0
C12ED8:
	bsr	druk_cr_nl
	bsr	printthetext
	move.l	a5,d0
	bsr	druk_af_d0
	bsr	druk_af_space
	bsr	C1588E
	jsr	(Diss_zetom2ascii).l
	bsr	printthetext
	br	druk_cr_nl

C12EFC:
	bsr	druk_cr_nl
	lea	(FPCR.MSG).l,a0
	bsr	printthetext

	move.l	(fpu_1-DT,a4),d0
	move.l	(L2F16C-DT,a4),d1
	cmp.l	d0,d1
	beq	C12F48
	move.l	d0,-(sp)
	bsr	get_inverse_font		;inverse font
	move.l	(sp)+,d0
	bsr	C15900
	bsr	get_normal_font		;normal
	moveq	#4,d7
C12F2A:
	bsr	druk_af_space
	dbra	d7,C12F2A
	lea	(BSUN.MSG).l,a0
	move.l	(fpu_1-DT,a4),d2
	move.l	(L2F16C-DT,a4),d3
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
	lea	(BSUN.MSG).l,a0
	move.l	(fpu_1-DT,a4),d2
	move.l	(L2F16C-DT,a4),d3
	moveq	#15,d1
	moveq	#7,d7
	br	C13096

C12F70:
	bsr	Druk_Clearbuffer
	bsr	druk_cr_nl
	lea	(FPSR.MSG).l,a0
	bsr	printthetext
	move.l	(fpu_2-DT,a4),d0
	move.l	(fpu2_old-DT,a4),d1
	bsr	C1326A
	bsr	druk_af_space
	move.l	(fpu_2-DT,a4),d2
	move.l	(fpu2_old-DT,a4),d3
	moveq	#15,d1
	moveq	#7,d7
	br	C13096

C12F9E:
	lea	(IOP.MSG).l,a0
	move.l	(fpu_2-DT,a4),d2
	move.l	(fpu2_old-DT,a4),d3
	moveq	#7,d1
	moveq	#4,d7
	br	C13096

C12FB4:
	bsr	printthetext
	move	(fpu_2-DT,a4),d1
	move	(fpu2_old-DT,a4),d2
	cmp	d1,d2
	beq.b	C12FD0
	pea	(C12FE2,pc)
	move	d0,-(sp)
	bsr	get_inverse_font	;inverse font
	move	(sp)+,d0
C12FD0:
	move	d1,d0
	rol.w	#1,d0
	and	#1,d0
	add.b	#$30,d0
	bsr	SENDONECHARNORMAL
	bra.w	C12FE6

C12FE2:
	bsr	get_normal_font	;normal font
C12FE6:
	bsr	printthetext
	move	(fpu_2-DT,a4),d0
	move	(fpu2_old-DT,a4),d1
	and.b	#$7F,d0
	and.b	#$7F,d1
	cmp.b	d0,d1
	beq.b	C1300A
	pea	(C1300E,pc)
	move	d0,-(sp)
	bsr	get_inverse_font	;inverse font
	move	(sp)+,d0
C1300A:
	br	C15908

C1300E:
	br	get_normal_font	;normal font

C13012:
	lea	(PRECISION.MSG).l,a0
	bsr	printthetext
	move.l	(fpu_1-DT,a4),d1
	lsr.w	#4,d1
	move	d1,d2
	lsr.w	#2,d1
	and.b	#3,d1
	and.b	#3,d2
	moveq	#$58,d0
	tst.b	d1
	beq.b	C13042
	moveq	#$53,d0
	subq.b	#1,d1
	beq.b	C13042
	moveq	#$44,d0
	subq.b	#1,d1
	beq.b	C13042
	moveq	#$55,d0
C13042:
	bsr	SENDONECHARNORMAL
	bsr	printthetext
	move	#$4E52,d0
	tst.b	d2
	beq.b	C13066
	move	#$5A52,d0
	subq.b	#1,d2
	beq.b	C13066
	move	#$4D52,d0
	subq.b	#1,d2
	beq.b	C13066
	move	#$5052,d0
C13066:
	move	d0,-(sp)
	and	#$00FF,d0
	bsr	SENDONECHARNORMAL
	move	(sp)+,d0
	lsr.w	#8,d0
	and	#$00FF,d0
	bsr	SENDONECHARNORMAL
	rts

C1307E:
	lea	(N.MSG).l,a0
	move.l	(fpu_2-DT,a4),d2
	move.l	(fpu2_old-DT,a4),d3
	moveq	#$1B,d1
	moveq	#3,d7
	bsr	C13096
	rts

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
	move	d0,-(sp)
	bsr	get_inverse_font	;inverse font
	move	(sp)+,d0
	bsr	SENDONECHARNORMAL
	bsr	get_normal_font	;normal font
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
	lea	(FPIAR.MSG).l,a0
	bsr	printthetext
	move.l	(fpu_3-DT,a4),d0
	move.l	(L2F174-DT,a4),d1
	bsr	C1326A
	bsr	druk_af_space
	rts

C130F6:
	fmovem.x	fp0/fp1,-(sp)
	movem.l	d6/d7/a0-a2,-(sp)
	lea	(FP0.MSG).l,a0
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
	bsr	get_inverse_font	;inverse font
	bsr	C15B0A
	bsr	get_normal_font	;normal font
	bra.b	C13136

C13132:
	bsr	C15B0A
C13136:
	move.l	a0,-(sp)
	lea	(B30053).l,a0
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
	moveq	#$20,d0
	bsr	SENDONECHARNORMAL
	lea	(VBR.MSG).l,a0
	bsr	printthetext
	move.l	(VBR_base_ofzo-DT,a4),d0
	move.l	(VBR_Base2-DT,a4),d1
	bsr	C1326A
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

C131BE:
	move	(a1)+,d1	;new
	move	(a2)+,d2	;old
	move	d1,d0
	eor.w	d1,d2
	beq.b	C131D6
	move	d0,-(sp)
	bsr	get_inverse_font
	move	(sp)+,d0
	bsr	C131D6
	br	get_normal_font

C131D6:
	br	C15900

C131DA:
	bsr.b	C1323A
	lsl.w	#1,d1
	lsl.w	#1,d2
	bra.b	C1323A

C131E2:
	rol.w	#5,d1
	and.b	#7,d1
	rol.w	#5,d2
	and.b	#7,d2
	beq.w	C131F4
	bsr	get_inverse_font
C131F4:
	bsr	printthetext
	move.b	d1,d0
	add.b	#$30,d0
	bsr	SENDONECHARNORMAL
	tst.b	d2
	beq.w	C1320A
	bsr	get_normal_font
C1320A:
	rts

C1320C:
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
	move	d0,-(sp)
	bsr	get_inverse_font
	move	(sp)+,d0
	bsr	SENDONECHARNORMAL
	bsr	get_normal_font
	bra.b	C13234

C13230:
	bsr	SENDONECHARNORMAL
C13234:
	dbra	d3,C13212
	rts

C1323A:
	move.l	a0,-(sp)
	lsl.w	#1,d1
	bcs.b	C13242
	addq.w	#3,a0
C13242:
	lsl.w	#1,d2
	bcs.b	C13254
	bsr	printthetext
	bsr	druk_af_space
	move.l	(sp)+,a0
	addq.w	#6,a0
	rts

C13254:
	bsr	get_inverse_font
	bsr	printthetext
	bsr	get_normal_font
	bsr	druk_af_space
	move.l	(sp)+,a0
	addq.w	#6,a0
	rts

C1326A:
	cmp.l	d0,d1
	beq	C132F4
	br	C132F8

;************ conv FP regs voor debug win ************

convert_fpgetal_debug:
	fmovem.x	fp0/fp1,-(sp)
	movem.l	d0-a6,-(sp)
	fmovem	fpcr/fpsr/fpiar,-(sp)
	;dc.w	$F227
	;dc.w	$BC00

	pea	(.en_weer_terug,pc)
	fmove.x	(a1),fp0
	fmove.x	(a2),fp1
	fcmp.x	fp0,fp1
	fbgl.w	debug_changefp
	br	debug_drukfp

.en_weer_terug:
	fmovem	(sp)+,fpcr/fpsr/fpiar
	;dc.w	$F21F
	;dc.w	$9C00

	movem.l	(sp)+,d0-a6
	lea	(12,a1),a1
	lea	(12,a2),a2
	fmovem.x	(sp)+,fp0/fp1
	rts

debug_changefp:
	move.l	d0,-(sp)
	bsr	get_inverse_font
	move.l	(sp)+,d0
	bsr	debug_drukfp
	bra.w	get_normal_font
	rts

debug_drukfp:
	lea     adrtxtbuf,a5

	bsr	C15B0A
	lea	(B30053).l,a1
	moveq	#16,d1
	moveq	#0,d0
.fp_loopje:
	move.b	(a1)+,d0
	tst.b	d0
	beq.b	.is_nul
	move.b	d0,(a5)+

	dbra	d1,.fp_loopje
.is_nul:
	cmp.l	#L30062,a1
	bne.b	.nog_niet
	moveq	#' ',d0
	move.b	d0,(a5)+

.nog_niet:
	move.b	#0,(a5)+

	bsr	druk_af_now

	rts

;******** converteer getal voor de debugger ********

convert_getal_debug2:
	bsr	get_font_debug1
	moveq.l	#0,d0
	move.w	(a1)+,d0	;nieuwe waarde
	cmp.w	(a2)+,d0	;oudewaarde
	beq.s	.noinverse
	bsr	get_font_debug2
.noinverse:
	movem.l	d0-a6,-(sp)
	lea	adrtxtbuf,a5
	moveq.l	#4-1,d7
.lopje:
	divu.w	#16,d0
	swap	d0
	add.b	#'0',d0
	cmp.b	#'9',d0
	bls.s	.nosweat
	add.b	#7,d0
.nosweat:
	move.b	d0,(a5,d7.w)
	clr.w	d0
	swap	d0
	dbf	d7,.lopje
	move.b	#0,4(a5)

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
	lea	adrtxtbuf,a5
	moveq.l	#0,d1
	move.w	d0,d1
	clr.w	d0
	swap	d0
	moveq.l	#4-1,d7
.lopje:
	divu.w	#16,d0
	swap	d0
	add.b	#'0',d0
	cmp.b	#'9',d0
	bls.s	.nosweat
	add.b	#7,d0
.nosweat:
	move.b	d0,(a5,d7.w)
	clr.w	d0
	swap	d0

	divu.w	#16,d1
	swap	d1
	add.b	#'0',d1
	cmp.b	#'9',d1
	bls.s	.nosweat2
	add.b	#7,d1
.nosweat2:
	move.b	d1,4(a5,d7.w)
	clr.w	d1
	swap	d1
	dbf	d7,.lopje

	move.b	#0,8(a5)
	movem.l	(sp)+,d0-a6
	
druk_af_now:
	movem.l	d0-a6,-(sp)
	move.l	IntBase,a6

	move.w	(EFontSize_x-DT,a4),d0
	mulu.w	#5,d0

;	move.l	d5,d0		;left
	move.w	#0,d1		;top
	move.l	debug_rp,a0	;rp
	lea	Debug_adrtxt(pc),a1	;itext
	jsr	_LVOPrintIText(a6)	;printitext

	move.w	(EFontSize_y-DT,a4),d0
	add.w	d0,adryoff

	movem.l	(sp)+,d0-a6
	rts

debug_print_text:
	movem.l	d0-a6,-(sp)
	move.l	a0,adrtxtptr

	movem.l	(sp)+,d0-a6
	bra.b	druk_af_now


debug_print_xy:
	move.l	a0,srtxtptr
	move.l	IntBase,a6
	move.l	debug_rp,a0		;rp
	lea	sr_Text(pc),a1		;itext
	jsr	_LVOPrintIText(a6)	;printitext
	rts

strt1:	dc.b	"--",0
	dc.b	"T1",0
	dc.b	"--",0
	dc.b	"S1",0

bitslet:
	dc.b	"XNZVC"

	cnop	0,4
sr_Text:
srpens:	DC.B    1,0
	DC.B    1
	DC.B    0
sr_x:	DC.W    3,3
	DC.L	Editor_Font	;xhelvetica11
srtxtptr:
	DC.L    srtxtbuf
	DC.L    0

srtxtbuf:
	dc.b	"!!!!!!",0

	cnop	0,4

;T1 S1 XNZVC

debug_sr_stuff:
	movem.l	d0-a6,-(sp)

	move.w	d1,d0
	eor.w	d2,d0
	movem.w	d0-d2,-(sp)

	lsl.w	#3,d1
	lsl.w	#3,d2

	rol.w	#5,d1
	and.b	#7,d1
	rol.w	#5,d2
	and.b	#7,d2
	beq.w	.nif
	move.b	#2,srpens
	move.b	#1,srpens+1
.nif:
	add.b	#'0',d1
	lsl.w	#8,d1

	lea	adrtxtbuf,a0
	move.w	d1,(a0)

	move.w	(EFontSize_x-DT,a4),d0
	mulu.w	#12,d0
	move.w	(EFontSize_y-DT,a4),d1
	mulu.w	#19,d1

	bsr	debug_print_xy	;PL=0	interupt priority mask (priority level?)

	movem.w	(sp)+,d0-d2

	move.w	(EFontSize_x-DT,a4),d5
	mulu.w	#3,d5

	move.b	#1,srpens
	move.b	#0,srpens+1
	tst.w	d0
	bpl.s	.not2
	move.b  #2,srpens
	move.b  #1,srpens+1
.not2:
	move.w	#3,sr_x	;marge

	lea	strt1,a0
	bsr	.gop

	lsl.w	#1,d0
	lsl.w	#1,d1
	lsl.w	#1,d2

	move.b	#1,srpens
	move.b	#0,srpens+1
	tst.w	d0
	bpl.s	.not3
	move.b  #2,srpens
	move.b  #1,srpens+1
.not3:
	lea	strt1+6,a0
	add.w	d5,sr_x
	bsr	.gop

	lsl.w	#1,d0
	lsl.w	#1,d1
	lsl.w	#1,d2

; status bits -> charakter

	bsr	.stbits	

	movem.l	(sp)+,d0-a6
	rts

.stbits:
	add.w	d5,sr_x
	lea	srtxtbuf,a2
	lea	bitslet,a3
	move.b	#0,1(a2)
	move.w	#5-1,d7
.bitlopje:
	lsl.w	#1,d0
	lsl.w	#1,d1
	lsl.w	#1,d2

	addq.l	#1,a3
	move.b	#'-',(a2)
	tst.b	d1
	bpl	.notset
	move.b	-1(a3),(a2)
.notset:
	move.b	#1,srpens
	move.b	#0,srpens+1
	tst.b	d0
	bpl.s	.not4
	move.b  #2,srpens
	move.b  #1,srpens+1
.not4:
	move.l	a2,a0
	bsr	.not1

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

	move.w	(EFontSize_y-DT,a4),d1
	mulu.w	#19,d1

	bsr	debug_print_xy		;T1 S1
	movem.l	(sp)+,d0-d2
	rts
	

get_font_debug1:
	move.b	#1,db_pens
	move.b	#0,db_pens+1
	rts

get_font_debug2:
	move.b	#2,db_pens
	move.b	#1,db_pens+1
	rts


;********************************************************



convert_getal:
	move.l	(a1)+,d0	;new value
	cmp.l	(a2)+,d0	;old value
	bne.b	C132F8		;print inverse
C132F4:
	br	druk_af_d0		;print normal


C132F8:
	move.l	d0,-(sp)
	bsr.b	get_inverse_font	;inverse
	move.l	(sp)+,d0
	bsr	druk_af_d0
	br	get_normal_font		;normal?

get_inverse_font:
	moveq	#-$65,d0
	bsr	SENDONECHARNORMAL
	moveq	#$34,d0
	bsr	SENDONECHARNORMAL
	moveq	#$6D,d0
	br	SENDONECHARNORMAL

get_normal_font:
	moveq	#-$65,d0
	bsr	SENDONECHARNORMAL
	moveq	#$30,d0
	bsr	SENDONECHARNORMAL
	moveq	#$6D,d0
	br	SENDONECHARNORMAL

debug_regs2old:
	lea	(DataRegsStore-DT,a4),a1
	lea	(DataRegsStore_Old-DT,a4),a2
	moveq	#$24,d0
C13332:
	move	(a1)+,(a2)+
	dbra	d0,C13332
	tst	(FPU_Type-DT,a4)
	beq.b	C13360
	lea	(FpuRegsStore-DT,a4),a1
	lea	(FpuRegsStore_Old-DT,a4),a2
	moveq	#$17,d0
C13348:
	move.l	(a1)+,(a2)+
	dbra	d0,C13348
	move.l	(fpu_1-DT,a4),(L2F16C-DT,a4)
	move.l	(fpu_2-DT,a4),(fpu2_old-DT,a4)
	move.l	(fpu_3-DT,a4),(L2F174-DT,a4)
C13360:
	move.l	(VBR_base_ofzo-DT,a4),(VBR_Base2-DT,a4)
	rts

druk_af_debug_regs:
	tst.l	debug_winbase
	bne.s	.okay
	rts
.okay:
;	moveq	#0,d0
;	bsr	Druk_char_af2
	tst.b	(debug_FPregs-DT,a4)
	beq.b	.debug_regs_normal
	lea	(HFP0.MSG,pc),a0
	lea	(FpuRegsStore-DT,a4),a1
	lea	(FpuRegsStore_Old-DT,a4),a2
	moveq	#7,d3
.debug_FpuRegs:
;	bsr	printthetext
	bsr	convert_fpgetal_debug		;zet om fpu-regs en display...
	dbra	d3,.debug_FpuRegs
	lea	(HA0.MSG,pc),a0
	lea	(AdresRegsStore-DT,a4),a1
	lea	(AdrRegsStore_Old-DT,a4),a2
	moveq	#6,d3
	bra.b	.skip_dataregs

.debug_regs_normal:
	lea	(HD0.MSG,pc),a0
	lea	(DataRegsStore-DT,a4),a1
	lea	(DataRegsStore_Old-DT,a4),a2
	moveq	#15-1,d3
.skip_dataregs:
	bsr	convert_getal_debug
	dbra	d3,.skip_dataregs
	
C133D0:
	bsr	convert_getal_debug	;ipv C1326A a7
	lea	-4(a1),a1
	lea	-4(a2),a2
	move.w	(EFontSize_y-DT,a4),d5
	add.w	d5,adryoff
	bsr	convert_getal_debug	;for the sp

	move.w	(EFontSize_y-DT,a4),d5
	sub.w	d5,adryoff
	sub.w	d5,adryoff
	
	bsr	convert_getal_debug	;SSP
	add.w	d5,adryoff

	bsr	convert_getal_debug2	;SR

	add.w	d5,adryoff

	move.w	-2(a1),d1
	move.w	-2(a2),d2
	
	bsr	debug_sr_stuff

	bsr	get_font_debug1

	move.l	(a1),a5
	bsr	debug_regs2old
	move.l	a5,d0

	cmp.l	#eop_irq_routine,d0
	beq.b	deb_eop
	bsr	convert_getal_debug_d0	;PC
;	bsr	druk_af_d0		;PC
	bra.b	deb_no_eop
;	rts

deb_eop:
	move.l	a0,-(sp)

	lea	(EOP.MSG,pc),a0
;	bsr	printthetext	;PC eop!
	bsr	debug_print_text

	move.l	#adrtxtbuf,adrtxtptr

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
;	move.l	(fpu2_old-DT,a4),d1
;	bsr	C1326A
	bsr     convert_getal_debug_d0

;print PCR register van de 68060 af
	cmp.w	#PB_060,(ProcessorType-DT,a4)
	blo.s	.geen060Plus
	bsr	Get_PCR
	bsr     convert_getal_debug_d0
.geen060Plus:
	rts
							     ;
Get_PCR:
	movem.l	d1-a6,-(sp)
	lea	SupervisorRoutinePCR,a5
	move.l	4.w,a6
	jsr	(_LVOSupervisor,a6)
	movem.l	(sp)+,d1-a6
	rts

SupervisorRoutinePCR:
	movec	PCR,d0
	rte


;	dc.b	'Smiths kwaliteitsgarantie hamka''s rulzz !!!',0

C13494:
	lea	(SourceCode-DT,a4),a3
	move	(a3),d1
	bpl.b	C134BE
	and	#$DFDF,d1
	moveq	#-8,d0
	and	d1,d0
	sub	d0,d1
	cmp	#$C410,d0
	beq.b	C134B4
	addq.b	#8,d1
	cmp	#$C110,d0
	bne.b	C134BE
C134B4:
	lsl.w	#2,d1
	move	#$0400,d6
	or.w	d1,d6
	bra.b	C134CC

C134BE:
	lea	(strange_tabled,pc),a0
	jsr	(C5352).l
	beq	ERROR_UndefSymbol
C134CC:
	cmp	#$043C,d6
	bne.b	C134DC
	btst	#5,(statusreg_base-DT,a4)
	bne.b	C134DC
	addq.w	#4,d6
C134DC:
	move	d6,d0
	lsr.w	#8,d0
	and	#7,d0
	move.b	d0,(OpperantSize-DT,a4)
	lea	(DataRegsStore-DT,a4),a1
	ext.w	d6
	add	d6,a1
	moveq	#0,d6
	rts

C134F4:
	move.l	a6,-(sp)
	jsr	(Get_NextChar).l
	clr.b	(a6)
	bsr.b	C13494
	move.l	(sp)+,a0
	bsr	printthetext
	bsr	druk_af_space
	move.l	a1,a5
	bsr	C137CC
	br	druk_cr_nl

strange_tabled:
	dc.l	$000C0002
	dc.l	$D352002A
	dc.l	$D3500038
	dc.l	$D043001C
	dc.l	$55530012
	dc.l	$00105353
	dc.l	$00060004
	dc.l	$0000D000
	dc.l	$00160000
	dc.l	$D0000016
	dc.l	$00000446
	dc.l	0
	dc.l	$02440000
	dc.l	$0000143C
	dc.l	0
	dc.l	$04400000
	dc.l	$0000043C
	dc.l	0

com_calc_float:
	movem.l	d0-d2/a0,-(sp)
	tst	(FPU_Type-DT,a4)
	beq	ERROR_FPUneededforopp
	move.l	#0,(L2F26C-DT,a4)
	fmove.x	fp0,-(sp)
	bsr	C11B36
	bsr	C15B0A
	lea	(B30053).l,a0
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
	moveq	#$2E,d0		;.
	bsr	SENDONECHARNORMAL
	move.l	(sp)+,d0
	bsr	SENDONECHARNORMAL
	fmove.x	(sp)+,fp0
	movem.l	(sp)+,d0-d2/a0
	br	druk_cr_nl

com_calculator:
	move.l	d0,d1
	moveq	#$24,d0		;$
	bsr	SENDONECHARNORMAL
	move.l	d1,d0
	bsr	druk_af_d0
	bsr	druk_af_space
	move.l	d1,d0
	move.l	d1,-(sp)
	bsr	Druk_D0_inCommandline
	move.l	(sp)+,d1
	bsr	druk_af_space
	moveq	#$22,d0
	bsr	SENDONECHARNORMAL
	movem.l	d1/d2,-(sp)
	moveq	#3,d2
C1362E:
	rol.l	#8,d1
	move.b	d1,d0
	bclr	#7,d0
	cmp.b	#$20,d0
	bcc.b	C13640
	move.b	#$2E,d1
C13640:
	moveq	#0,d0
	move.b	d1,d0
	bsr	SENDONECHARNORMAL
	dbra	d2,C1362E
	movem.l	(sp)+,d1/d2
	moveq	#$22,d0
	bsr	SENDONECHARNORMAL
	bsr	druk_af_space
	moveq	#$25,d0
	bsr	SENDONECHARNORMAL
	bsr.b	C13666
	br	druk_cr_nl

C13666:
	rol.l	#8,d1
	bsr.b	C13684
	moveq	#$2E,d0
	bsr	SENDONECHARNORMAL
	bsr.b	C13684
	moveq	#$2E,d0
	bsr	SENDONECHARNORMAL
	bsr.b	C13684
	moveq	#$2E,d0
	bsr	SENDONECHARNORMAL
	br	C13684

C13684:
	move.l	d1,-(sp)
	moveq	#1,d0
	lsr.w	#1,d0
	roxl.b	#1,d1
C1368C:
	beq.b	C136A4
	bcs.b	C1369A
	moveq	#$30,d0
	bsr	SENDONECHARNORMAL
	lsl.b	#1,d1
	bra.b	C1368C

C1369A:
	moveq	#$31,d0
	bsr	SENDONECHARNORMAL
	lsl.b	#1,d1
	bra.b	C1368C

C136A4:
	move.l	(sp)+,d1
	rol.l	#8,d1
	rts

com_copy:
	bclr	#5,(a6)
	cmp.b	#$43,(a6)
	beq	C16EDA
	cmp.b	#$44,(a6)
	beq.b	C136F6
	cmp.b	#$53,(a6)
	beq	C12928
	moveq	#0,d7
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

C136F6:
	addq.l	#1,a6
	tst.b	(a6)
	beq.b	C1373E
	cmp.b	#$20,(a6)
	beq.b	C136F6
	cmp.b	#9,(a6)
	beq.b	C136F6
	tst.b	(a6)
	beq.b	C13734
	lea	(FileNaam-DT,a4),a0
	bsr	C180CA
C13714:
	move.l	#FileNaam,d1
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOCreateDir,a6)
	move.l	d0,d1
	beq.b	C13734
	jsr	(_LVOUnLock,a6)
	lea	(Directorycrea.MSG).l,a0
	br	beeldtextaf

C13734:
	lea	(Errorcreating.MSG).l,a0
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
	beq.b	C1375C
	bra.b	C13754

C1375C:
	clr.b	(a1)
	bra.b	C13714

com_fill:
	moveq	#0,d7
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
	addq.l	#8,d5
	addq.l	#8,d5
	move.l	a5,d0
	bsr	Druk_af_D0
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
	moveq	#$20,d0
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

C13832:
	clr.b	(B30040-DT,a4)
	cmp.b	#$7B,(a6)
	bne.b	C13844
	addq.w	#1,a6
	move.b	#1,(B30040-DT,a4)
C13844:
	bsr	GETNUMBERAFTEROK
	beq.b	C1384E
	move.l	(MEM_DIS_DUMP_PTR-DT,a4),d0
C1384E:
	tst.b	(B30040-DT,a4)
	beq.b	C1386A
	cmp.b	#1,(OpperantSize-DT,a4)
	beq.b	C13866
	tst	(ProcessorType-DT,a4)
	bne.b	C13866
	bclr	#0,d0
C13866:
	move.l	d0,a5
	move.l	(a5),d0
C1386A:
	cmp.b	#1,(OpperantSize-DT,a4)
	beq.b	C1387E
	cmp	#1,(ProcessorType-DT,a4)
	bgt.b	C1387E
	bclr	#0,d0
C1387E:
	move.l	d0,a5
	moveq	#11,d5
C13882:
	move.l	a5,d0
	bsr	Druk_af_D0
	move	d5,-(sp)
	jsr	(Diss_zetom2ascii).l
	bsr	printthetext
	bsr	druk_cr_nl
	move	(sp)+,d5
	dbra	d5,C13882
	move.l	a5,(MEM_DIS_DUMP_PTR-DT,a4)
	rts

com_search_in_mem:
	moveq	#0,d7
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
	move.b	(a6)+,d0
	and.b	#$DF,d0
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
	move.l	d0,-(sp)
	bsr	druk_cr_nl
	move.l	(sp)+,d0
C13A00:
	bsr	druk_af_d0
	bsr	druk_af_space
	moveq	#0,d0
	bsr	SENDONECHARNORMAL
	movem.l	(sp)+,d0-d5/a0-a3/a5
	addq.l	#1,d4
	bra.b	C139B2

com_compare:
	moveq	#0,d7
	bsr	INPUTBEGINEND
	cmp.b	#$61,d1
	bne	ERROR_Notdone
	lea	(DEST.MSG,pc),a0
	bsr	Druk_MsgAf_GetNumbr
	bne	ERROR_Notdone
	lea	(NOT.MSG,pc),a0
	move.l	d2,a1
	move.l	d0,a2
	subq.l	#1,d3
	tst.l	d3
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
	bsr	Druk_af_D0
	subq.l	#1,a2
	move.l	a2,d0
	bsr	druk_af_d0
	bsr	druk_cr_nl
	br	C105DE

com_workspace:			;'=?'
	bclr	#5,(a6)
	cmp.b	#$53,(a6)	;S
	beq	com_PRINT_SYMBOLTABEL
	cmp.b	#$52,(a6)	;R
	beq	C13DDC
	cmp.b	#$43,(a6)	;C
	beq	C18124
	cmp.b	#$41,(a6)	;A
	beq	C13B5A
	cmp.b	#$50,(a6)	;P
	beq.b	C13A9E
	cmp.b	#$4D,(a6)	;M
	bne	C13BAE
	jmp	(C1E5B6).l

C13A9E:
	movem.l	d0-d7/a0-a6,-(sp)
	lea	(Source0.MSG).l,a0
	lea	(ProjectName-DT,a4),a1
	tst.b	(a1)
	bne.b	C13AB6
	lea	(Noprojectstar.MSG).l,a1
C13AB6:
	moveq	#$1F,d7
C13AB8:
	move.b	(a1)+,d0
	tst.b	d0
	bne.b	C13AC0
	moveq	#$20,d0
C13AC0:
	move.b	d0,(a0)+
	dbra	d7,C13AB8
	lea	(SizeSource1Si.MSG).l,a0
	lea	(SourcePtrs-DT,a4),a1
	moveq	#9,d7
C13AD2:
	moveq	#9,d6
	sub	d7,d6
	cmp.b	(CurrentSource-DT,a4),d6
	bne.b	C13AE4
	lea	(MenuFileName).l,a2
	bra.b	C13AE8

C13AE4:
	lea	(CS_filename,a1),a2
C13AE8:
	tst.b	(a2)
	bne.b	C13AF2
	lea	(Nosource.MSG).l,a2
C13AF2:
	moveq	#$1E,d6
C13AF4:
	move.b	(a2)+,d0
	tst.b	d0
	bne.b	C13AFC
	moveq	#$20,d0
C13AFC:
	move.b	d0,(a0)+
	dbra	d6,C13AF4
	lea	(12,a0),a0
	moveq	#9,d6
	sub	d7,d6
	cmp.b	(CurrentSource-DT,a4),d6
	bne.b	C13B1A
	move.l	(sourceend-DT,a4),d0
	sub.l	(sourcestart-DT,a4),d0
	bra.b	C13B1E

C13B1A:
	move.l	(CS_length,a1),d0
C13B1E:
	lea	(ABCDEF.MSG).l,a3
	moveq	#7,d6
C13B26:
	rol.l	#4,d0
	move.b	d0,d1
	and	#15,d1
	move.b	(a3,d1.w),(a0)+
	dbra	d6,C13B26
	lea	(13,a0),a0
	lea	(CS_size,a1),a1
	dbra	d7,C13AD2
	lea	(_Ok_Ok.MSG).l,a2
	lea	(AsmProProject.MSG).l,a1
	jsr	(ShowReqtoolsRequester).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

C13B5A:
	lea	(AsmProLOCATIO.MSG,pc),a0
	move.l	#ProgStart,d1
	move.l	#realend1,d2
	bsr	C13C0C

	move.l	#setup_int_stuff,d1
	move.l	#realend4,d2
	bsr	C13C08

	move.l	#REAL,d1
	move.l	#realend2,d2
	bsr.b	C13C08

	move.l	#Error_Msg_Table,d1
	move.l	#realend3,d2
	bsr.b	C13C08

	move.l	#Variable_base,d1
	move.l	#realend5,d2
	bsr.b	C13C08
C13BA8:
	tst.b	(a0)+
	bne.b	C13BA8
	rts

C13BAE:
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
	beq.b	C13C32
	bsr	printthetext
	move.l	d2,d0
	bra.b	C13C24

C13C08:
	cmp.l	d1,d2
	bls.b	C13C32
C13C0C:
	bsr	printthetext
	move.l	d1,d0
	jsr	(Druk_af_D0).l
	move.l	d2,d0
	jsr	(Druk_af_D0).l
	move.l	d2,d0
	sub.l	d1,d0
C13C24:
	move.l	a0,a1
	jsr	(PI_druklinenr).l
	move.l	a1,a0
	br	druk_cr_nl

C13C32:
	tst.b	(a0)+
	bne.b	C13C32
	rts

W13C38:
	dc.w	0

C13C3A:
	cmp.b	#10,d0
	bne	SENDONECHARNORMAL
	bsr	SENDONECHARNORMAL
	subq.w	#1,(W13C38).l
	bne.b	C13C60
	bsr	Get_me_a_char
	move	(ScreenHight-DT,a4),(W13C38).l
	subq.w	#2,(W13C38).l	
C13C60:
	rts

C13C62:
	tst.b	(B140AA).l
	bne.b	C13C6C
	rts

C13C6C:
	move.b	#$30,(-2,a6)
	move.b	#$30,(-1,a6)
C13C78:
	tst.b	(a6)+
	bne.b	C13C78
	sub	#4,a6
	move.b	(a6)+,d0
	rol.l	#8,d0
	move.b	(a6)+,d0
	rol.l	#8,d0
	move.b	(a6)+,d0
	and.l	#$00DFDFDF,d0
	bsr	C13C98
	moveq	#10,d0
	bra.b	C13C3A

C13C98:
	or.l	#$09000000,d0
	move.l	(L2E4E2).l,a0
C13CA4:
	move.b	(a0)+,d1
	rol.l	#8,d1
	move.b	(a0)+,d1
	rol.l	#8,d1
	move.b	(a0)+,d1
	rol.l	#8,d1
	move.b	(a0)+,d1
	and.l	#$DFDFDFDF,d1
	tst.b	(a0)
	bmi.w	E_NextCharacter8
	subq.w	#3,a0
	cmp.l	d0,d1
	bne	C13CA4
	and.l	#$00DFDFDF,d0
	movem.l	d0,-(sp)
	moveq	#2,d2
	moveq	#$20,d0
	bsr	C13C3A
C13CD8:
	move.b	(a0)+,d0
	bmi.b	C13CF2
	cmp.b	#$23,d0
	beq.b	C13CF2
	cmp.b	#10,d0
	bne.b	C13CEC
	lea	(15,a0),a0
C13CEC:
	bsr	C13C3A
	bra.b	C13CD8

C13CF2:
	moveq	#$3A,d0
	bsr	C13C3A
	moveq	#10,d0
	bsr	C13C3A
	moveq	#10,d0
	bsr	C13C3A
	movem.l	(sp)+,d0
	move.l	(L2E4EA).l,a0
	moveq	#0,d2
C13D10:
	bsr	C13DCA
	cmp.l	d0,d1
	beq.b	C13D56
	cmp.b	#$2D,(a0)
	bne.b	C13D2C
	addq.w	#1,a0
	cmp.l	d0,d1
	bhi.b	C13D2C
	bsr	C13DCA
	cmp.l	d0,d1
	bcc.b	C13D56
C13D2C:
	cmp.b	#$2F,(a0)
	bne.b	C13D36
	addq.w	#1,a0
	bra.b	C13D10

C13D36:
	cmp.b	#$7E,(a0)+
	bne.b	C13D36
	addq.w	#1,a0
	cmp.b	#$FF,(a0)
	bne.b	C13D10
	move.l	(L2E4DA).l,a0
C13D4A:
	move.b	(a0)+,d0
	beq.b	C13D54
	bsr	C13C3A
	bra.b	C13D4A

C13D54:
	rts

C13D56:
	cmp.b	#10,(a0)+
	beq.b	C13D5E
	bra.b	C13D56

C13D5E:
	moveq	#0,d0
	move.b	(a0)+,d0
	cmp.b	#$7E,d0
	bne.b	E_NextCharacterA
E_NextCharacter8:
	rts

E_NextCharacterA:
	cmp.b	#$3B,d0
	bne.b	C13D80
	move.l	a0,-(sp)
	move.l	(L2E4D2).l,a0
	bsr	C13D5E
	move.l	(sp)+,a0
	bra.b	C13D5E

C13D80:
	cmp.b	#$7C,d0
	bne.b	C13D98
	bra.w	C13D98

C13D98:
	cmp.b	#10,d0
	bne.b	C13DA0
	moveq	#-1,d2
C13DA0:
	cmp.b	#9,d0
	bne.b	C13DC2
	move.l	d2,d3
	and.l	#$FFFFFFF8,d3
	addq.l	#8,d3
	sub.l	d2,d3
	subq.l	#1,d3
C13DB4:
	moveq	#$20,d0
	bsr	C13C3A
	addq.w	#1,d2
	dbra	d3,C13DB4
	bra.b	C13D5E

C13DC2:
	bsr	C13C3A
	addq.w	#1,d2
	bra.b	C13D5E

C13DCA:
	move.b	(a0)+,d1
	rol.l	#8,d1
	move.b	(a0)+,d1
	rol.l	#8,d1
	move.b	(a0)+,d1
	and.l	#$00DFDFDF,d1
	rts


PtrRegsData	dc.l	0

C13DDC:
	movem.l	d0-a6,-(sp)				; ***
	btst	#0,(PR_RegsRes).l
	beq.b	C13DF2
	tst.l	(L2E4EE-DT,a4)
	bne	C13F00
C13DF2:
	move.l	#SREGSDATA.MSG,d1
	move.l	d1,PtrRegsData			
	moveq.l	#-2,d2
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOLock,a6)
	move.l	d0,(L2F124-DT,a4)
	bne.b	OpenRegsDataFile		

	move.l	#RegsDataSDir,d1		
	move.l	d1,PtrRegsData			
	moveq.l	#-2,d2
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOLock,a6)
	move.l	d0,(L2F124-DT,a4)
	beq.w	C13F20

OpenRegsDataFile:				
	move.l	(L2F124-DT,a4),d1
	lea	(ParameterBlok-DT,a4),a0
	move.l	a0,d2
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOExamine,a6)
	tst.l	d0
	beq	C13F20
	lea	(ParameterBlok-DT,a4),a0
	move.l	($007C,a0),(L2F128-DT,a4)
	move.l	(L2F124-DT,a4),d1
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOUnLock,a6)
	clr.l	(L2F124-DT,a4)
	move.l	(L2F128-DT,a4),d0
	moveq.l	#1,d1
	move.l	(4).w,a6
	jsr	(_LVOAllocMem,a6)
	move.l	d0,(L2E4EE-DT,a4)
	beq	C13F78
	move.l	PtrRegsData(pc),d1		
	move.l	#$3ED,d2
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOOpen,a6)
	move.l	d0,(L2E4F2).l
	beq	C13F20
	move.l	d0,d1
	move.l	(L2E4EE-DT,a4),d2
	move.l	(L2F128-DT,a4),d3
	jsr	(_LVORead,a6)			; ***
	move.l	(L2E4F2).l,d1
	jsr	(_LVOClose,a6)			; ***
	clr.l	(L2E4F2).l
	move.l	(L2E4EE-DT,a4),d0
	move.l	d0,(L2E4D2).l
	move.l	d0,(L2E4D6).l
	move.l	d0,(L2E4DA).l
	move.l	d0,(L2E4DE).l
	move.l	d0,(L2E4E2).l
	move.l	d0,(L2E4E6).l
	move.l	d0,(L2E4EA).l
	add.l	#$00000045,(L2E4D6).l
	add.l	#$0000008F,(L2E4DA).l
	add.l	#$00000098,(L2E4DE).l
	add.l	#$00000880,(L2E4E2).l
	add.l	#$0000087F,(L2E4E6).l
	add.l	#$00004922,(L2E4EA).l
C13F00:
	move.l	(Error_Jumpback-DT,a4),(L2F144-DT,a4)
	lea	(C13F16,pc),a0
	move.l	a0,(Error_Jumpback-DT,a4)
	movem.l	(sp)+,d0-d7/a0-a6
	bsr	C13FB8
C13F16:
	bsr.b	C13F8A
	move.l	(L2F144-DT,a4),(Error_Jumpback-DT,a4)
	rts

C13F20:
	move.l	(L2E4EE-DT,a4),a1
	move.l	(L2F128-DT,a4),d0
	tst.l	d0
	beq	C13F36
	move.l	(4).w,a6
	jsr	(_LVOFreeMem,a6)
C13F36:
	clr.l	(L2E4EE-DT,a4)
	clr.l	(L2F128-DT,a4)
	lea	(SREGSDATAfile.MSG).l,a0
	jsr	(printthetext).l
	movem.l	(sp)+,d0-a6				; ***
	rts

__ERROR_IllegalDevice	bra	ERROR_IllegalDevice
__ERROR_EndofFile:	bra	ERROR_EndofFile
							 ;
;	dc.b	"Groatis zoep'n en vret'n !!             "

C13F78:
	lea	(Notenoughmemo.MSG).l,a0
	jsr	(printthetext).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

C13F8A:
	tst.l	(L2E4EE-DT,a4)
	beq.b	C13FB6
	btst	#0,(PR_RegsRes).l
	bne.b	C13FB6
	move.l	(L2E4EE-DT,a4),a1
	move.l	(L2F128-DT,a4),d0
	tst.l	d0
	beq.b	C13FB6
	move.l	(4).w,a6
	jsr	(_LVOFreeMem,a6)
	clr.l	(L2F128-DT,a4)
	clr.l	(L2E4EE-DT,a4)
C13FB6:
	rts

C13FB8:
	move	(ScreenHight-DT,a4),(W13C38).l
	subq.w	#2,(W13C38).l
	move.b	#$55,(B140AA).l
C13FCE:
	addq.w	#1,a6
	cmp.b	#$20,(a6)
	beq.b	C13FCE
	cmp.b	#9,(a6)
	beq.b	C13FCE
	tst.b	(a6)
	beq	C140AC
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	(L2E4E6).l,a0
	lea	(a6),a1
C13FEE:
	move.b	(a1)+,d0
	cmp.b	#$20,d0
	beq.b	C13FEE
	cmp.b	#9,d0
	beq.b	C13FEE
	subq.w	#1,a1
	sf	d3
	cmp.b	#$30,d0
	beq.b	C14064
	cmp.b	#$31,d0
	beq.b	C14064
	lea	(-15,a0),a0
C14010:
	cmp.b	#$23,(a0)
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
	tst.b	d1
	beq.b	C1405E
	cmp.b	#$3F,d0
	beq	C14064
	and.b	#$DF,d0
	and.b	#$DF,d1
	cmp.b	d0,d1
	bne.b	C14044
	bra.b	C14026

C14044:
	cmp.b	#$23,(a0)
	beq.b	C14054
	cmp.b	#$FF,(a0)
	beq.b	C14064
	addq.w	#1,a0
	bra.b	C14044

C14054:
	addq.w	#2,a0
	cmp.b	#$FF,(a0)
	beq.b	C14064
	bra.b	C14022

C1405E:
	lea	(13,a0),a0
	bra.b	C1406C

C14064:
	movem.l	(sp)+,d0-d7/a0-a6
	br	C13C62

C1406C:
	movem.l	d0-d7/a0-a6,-(sp)
C14070:
	move.b	(a0)+,d0
	cmp.b	#$30,d0
	bcs.b	C14070
	cmp.b	#$39,d0
	bhi.b	C14070
	subq.w	#1,a0
	move.b	(a0)+,d0
	rol.l	#8,d0
	move.b	(a0)+,d0
	rol.l	#8,d0
	move.b	(a0)+,d0
	and.l	#$00DFDFDF,d0
	clr.b	(B140AA).l
	bsr	C13C98
	moveq	#10,d0
	bsr	C13C3A
	movem.l	(sp)+,d0-d7/a0-a6
	st	d3
	br	C14010

B140AA:
	dcb.b	2,0

C140AC:
	movem.l	d0-d7/a0-a6,-(sp)
	move	(ScreenHight-DT,a4),(W13C38).l
	subq.w	#2,(W13C38).l
	move.l	(L2E4DE).l,a0
	moveq	#0,d0
C140C6:
	cmp.b	#$FF,(a0)
	beq	C14164
	cmp.b	#$23,(a0)
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
	moveq	#0,d0
	move.b	(a0)+,d0
	bsr	SENDONECHARNORMAL
	move.l	(sp)+,d0
	addq.l	#1,d0
	bra.b	C140C6

C140F8:
	move.l	d0,d1
	and.l	#$FFFFFFF8,d1
	addq.l	#8,d1
	move.l	d1,-(sp)
	sub.l	d0,d1
	subq.l	#1,d1
C14108:
	moveq	#$20,d0
	bsr	SENDONECHARNORMAL
	dbra	d1,C14108
	move.l	(sp)+,d0
	addq.w	#1,a0
	bra.b	C140C6

C14118:
	bsr	druk_cr_nl
	bset	#SB1_CHANGE_MODE,(SomeBits-DT,a4)
	move.b	#13,d0
	bsr	SENDONECHARNORMAL
	bclr	#SB1_CHANGE_MODE,(SomeBits-DT,a4)
	addq.w	#1,a0
	moveq	#0,d0
	subq.w	#1,(W13C38).l
	bne.b	C140C6
	bsr	GETKEYNOPRINT
	cmp.b	#$1B,d0
	beq.b	C1415A
	move	(ScreenHight-DT,a4),(W13C38).l
	subq.w	#2,(W13C38).l
	moveq	#0,d0
	br	C140C6

C1415A:
	lea	(Break.MSG).l,a0
	bsr	printthetext
C14164:
	movem.l	(sp)+,d0-d7/a0-a6
	rts

com_zap:
	move.b	(a6)+,d0
	bclr	#5,d0
	cmp.b	#$46,d0
	bne.b	C1417C
	jmp	(C1999E).l

C1417C:
	cmp.b	#$4C,d0
	beq	C1450A
	cmp.b	#$41,d0
	beq.b	C14196
	cmp.b	#$49,d0
	bne.b	C1419C
	jmp	(ZapIncludes).l

C14196:
	jmp	(C2994).l

C1419C:
	cmp.b	#$42,d0
	bne.b	C141A8
	jmp	(DEBUG_CLEAR_BP_BUFFER).l

C141A8:
	cmp.b	#$53,d0
	bne	ERROR_IllegalComman
	move.b	(CurrentSource-DT,a4),d0
	bsr	C141CE
	bsr	C142A4
	bsr.b	C14232
	clr.b	(MenuFileName).l
	bsr	RESETMENUTEXT2
C141C8:
	bsr	C142A4
	rts

C141CE:
	movem.l	d0/d1/d7/a0/a1,-(sp)
	and.l	#$000000FF,d0
	move.b	d0,d1
	add.b	#$30,d1
	move.b	d1,(B1F237).l
	cmp.b	(CurrentSource-DT,a4),d0
	bne.b	C141F2
	lea	(MenuFileName).l,a0
	bra.b	C14200

C141F2:
	lea	(SourcePtrs-DT,a4),a0
	lsl.l	#8,d0
	lea	(a0,d0.l),a0
	lea	(CS_filename,a0),a0
C14200:
	lea	(B1F23B).l,a1
	moveq	#$1D,d7
	tst.b	(a0)
	beq.b	C1422A
C1420C:
	tst.b	(a0)
	beq.b	C14218
	move.b	(a0)+,(a1)+
	dbra	d7,C1420C
	bra.b	C14220

C14218:
	move.b	#$20,(a1)+
	dbra	d7,C14218
C14220:
	move.b	#$20,(a1)+
	movem.l	(sp)+,d0/d1/d7/a0/a1
	rts

C1422A:
	lea	(Newsourcenona.MSG).l,a0
	bra.b	C14200

C14232:
	moveq	#0,d0
	move.l	d0,(Mark1set-DT,a4)
	move.l	d0,(Mark2set-DT,a4)
	move.l	d0,(Mark3set-DT,a4)
	move.l	d0,(Mark4set-DT,a4)
	move.l	d0,(Mark5set-DT,a4)
	move.l	d0,(Mark6set-DT,a4)
	move.l	d0,(Mark7set-DT,a4)
	move.l	d0,(Mark8set-DT,a4)
	move.l	d0,(Mark9set-DT,a4)
	move.l	d0,(Mark10set-DT,a4)
	bclr	#SB2_INDEBUGMODE,(SomeBits2-DT,a4)
	move.l	(WORK_START-DT,a4),a0
	addq.l	#1,a0
	move.l	a0,(sourcestart-DT,a4)
	move.l	a0,(sourceend-DT,a4)
	move.l	a0,(FirstLinePtr-DT,a4)
	addq.w	#1,a0
	move.l	a0,(Cut_Blok_End-DT,a4)
	move.b	#$1A,-(a0)
	move.b	#$19,-(a0)
	move.l	#1,(FirstLineNr-DT,a4)
	clr.b	(LastFileNaam-DT,a4)
	movem.l	d7/a1,-(sp)
	lea	(INCLUDE_DIRECTORY-DT,a4),a1
	moveq	#$1F,d7
C14296:
	move.b	#0,(a1)+
	dbra	d7,C14296
	movem.l	(sp)+,d7/a1
	rts

C142A4:
	btst	#SB1_SOURCE_CHANGED,(SomeBits-DT,a4)
	beq.b	C142B4
	bsr.b	C1430E
	bclr	#SB1_SOURCE_CHANGED,(SomeBits-DT,a4)
C142B4:
	rts

C142B6:
	btst	#0,(PR_ReqLib).l
	beq.b	C142C6
	jmp	(C1F060).l

C142C6:
	lea	(Sure.MSG,pc),a0
	bsr	beeldtextaf
	bsr	GetHotKey
	bra.b	C1434A

C142D4:
	btst	#0,(PR_ReqLib).l
	beq.b	C142E4
	jmp	(C1F030).l

C142E4:
	btst	#SB3_EDITORMODE,(SomeBits3-DT,a4)	;are whe in editor?
	beq.b	C14302
	lea	(Filealreadyex.MSG,pc),a0
	jsr	(printTextInMenuStrip).l
	jsr	(GETKEYNOPRINT).l
	and.b	#$DF,d0
	bra.b	C1434A

C14302:
	lea	(Filealreadyex.MSG,pc),a0
	bsr	beeldtextaf
	bsr.b	GetHotKey
	bra.b	C1434A

C1430E:
	btst	#0,(PR_ReqLib).l
	beq.b	C1431E
	jmp	(C1F048).l

C1431E:
	lea	(Sourcenotsave.MSG,pc),a0
	bsr	beeldtextaf
	bsr.b	GetHotKey
	bra.b	C1434A

C1432A:
	btst	#0,(PR_ReqLib).l
	beq.b	C1433A
	jmp	(C1F13A).l

C1433A:
	lea	(ExitorRestart.MSG,pc),a0
	bsr	beeldtextaf
	bsr.b	GetHotKey
	cmp.b	#$52,d0
	beq.b	C1437C
C1434A:
	cmp.b	#$59,d0
	beq.b	C14370
	jmp	ERROR_Notdone

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
	bsr	C13F8A
C1437C:
	rts

Filter_inputtext:
	tst.b	(a5)
	beq.b	Filter_einderegel
	move	#48,d0
Filter_loopje:
	move.b	(a5)+,d1
	beq.b	Filter_eindereg2
	btst	#0,(CaseSenceSearch).l
	bne.b	Filter_UpisLow
	cmp.b	#$61,d1
	bcs.w	Filter_UpisLow
	sub.b	#$20,d1		;small letters get big
Filter_UpisLow:
	move.b	d1,(a6)+
	dbra	d0,Filter_loopje
Filter_eindereg2:
	clr.b	(a6)
Filter_einderegel:
	rts

com_search:
	cmp.b	#'@',(a6)
	bne.b	NoDebug_base
	jmp	Debug_base
NoDebug_base:
	move.l	a6,a5
	lea	(SourceCode-DT,a4),a6
	bsr.b	Filter_inputtext
	lea	(SourceCode-DT,a4),a5
	move.l	(FirstLinePtr-DT,a4),a0
C143C2:
	cmp.b	#$1A,(a0)
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
	cmp.b	#$1A,d1
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
	move.l	#1,(FirstLineNr-DT,a4)
	move.l	(sourcestart-DT,a4),a0
	subq.l	#1,d0
	bsr	C144E4
	move.l	a0,(FirstLinePtr-DT,a4)
	br	C144EA

com_bottom:
	move.b	(a6)+,d0
	bclr	#5,d0
	cmp.b	#'M',d0		;M	BM binary memorydump
	bne	.nobindump
	jmp	com_BinDump
.nobindump:
	cmp.b	#'S',d0		;S	BS bootblock simulator
	beq.b	Bootblock_simulator
	moveq	#-1,d0
	move.l	(FirstLinePtr-DT,a4),a0
	subq.l	#1,d0
	bsr	C144D6
	br	C144EA

Bootblock_simulator:
	lea	(BEG.MSG,pc),a0
	bsr	Druk_MsgAf_GetNumbr
	tst.l	d0
	bne.b	DoBBSimul
	jmp	ERROR_Notdone
DoBBSimul:
	add.l	#$c,d0			; pass the DOS header
	move.l	d0,(L2FCE6-DT,a4)
	moveq	#0,d0
	bsr	Open_trackdiskdev
	tst.l	d0
	bne	__ERROR_IllegalDevice
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	(4).w,a6
	lea	(DATA_WRITEREQUEST2-DT,a4),a1

	move	($00DFF002).l,(W30032-DT,a4)
	move	($00DFF01C).l,(W30034-DT,a4)
	move	#$7FFF,($00DFF096).l
	move	#$7FFF,($00DFF09A).l
	move	#$83D0,($00DFF096).l
	move	#$E02C,($00DFF09A).l
	move.l	(L2FCE6-DT,a4),a0
	jsr	(a0)
	movem.l	(sp)+,d0-d7/a0-a6
	move	(W30032-DT,a4),d0
	or.w	#$8000,d0
	move	d0,($00DFF096).l
	move	(W30034-DT,a4),d0
	or.w	#$8000,d0
	move	d0,($00DFF09A).l
	br	C17186

C144D6:
	cmp.b	#$1A,(a0)
	beq.b	C144E8
C144DC:
	tst.b	(a0)+
	bne.b	C144DC
	addq.l	#1,(FirstLineNr-DT,a4)
C144E4:
	dbra	d0,C144D6
C144E8:
	rts

C144EA:
	move.l	a0,(FirstLinePtr-DT,a4)
Drukaf_CurrentLine:
	move.l	(FirstLineNr-DT,a4),d0
	bsr	DrukAf_LineNrPrint
	move.l	(FirstLinePtr-DT,a4),a0
	cmp.b	#$1A,(a0)
	beq	__ERROR_EndofFile
	bsr	printthetext
	br	druk_cr_nl

C1450A:
	bclr	#SB2_INDEBUGMODE,(SomeBits2-DT,a4)
	bsr	GETNUMBERAFTEROK
	move	d0,d5
	beq.b	C14528
	bsr	C142B6
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
	cmp.b	#$1A,(a0)
	beq.b	C14546
	bsr	printthetext
C14546:
	bsr	druk_cr_nl
	move.l	(sp)+,a0
C1454C:
	cmp.b	#$20,(a0)+
	bcc.b	C1454C
	cmp.b	#9,(-1,a0)
	beq.b	C1454C
	cmp.b	#$1A,(-1,a0)
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
	bmi.w	__ERROR_EndofFile
C14582:
	move.b	(a1)+,(a0)+
	subq.l	#1,d0
	bpl.b	C14582
	move.l	a0,(Cut_Blok_End-DT,a4)
	subq.l	#1,a0
	move.l	a0,(sourceend-DT,a4)
	rts

FileReqStuff:
	btst	#0,(PR_ReqLib).l
	beq.b	.NoReqLib
	jmp	(YesReqLib).l

.NoReqLib:
	lea	(REQ_TYPES,pc),a0
	add	d0,a0
	move.b	(a0),d0
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
;;
;	jsr	test1
	move.l	d0,-(sp)
	moveq.l	#0,d0
	move.b	(CurrentSource-DT,a4),d0
	lsl.l	#7,d0			;DSIZE = 128
	lea	(a1,d0.l),a1
	move.l	(sp)+,d0

	lea	(MenuFileName,pc),a0
C145CE:
	btst	#0,(PR_SourceExt).l
	beq.b	C145F8
	move.l	a0,-(sp)
C145DA:
	move.b	(a0)+,d0
	beq.b	C145E6
	cmp.b	#$2E,d0
	bne.b	C145DA
	bra.b	C145F6

C145E6:
	subq.l	#1,a0
	move.l	a1,-(sp)
	lea	(S.MSG).l,a1
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
	cmp.b	#$3A,(-1,a1)
	beq.b	C14618
	moveq	#$2F,d0
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
	cmp.b	#$2E,-(a1)
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
	beq	_ERROR_Notdone
	movem.l	(sp)+,d1/a2
C1464A:
	move.l	d1,a1
	move.l	a2,d2
C1464E:
	move.b	(a0)+,d0
	beq.b	C14664
	move.b	d0,(a1)+
	move.b	d0,(a2)+
	cmp.b	#$2F,d0
	beq.b	C1464A
	cmp.b	#$3A,d0
	beq.b	C1464A
	bra.b	C1464E

C14664:
	clr.b	(a1)+
	move.l	d2,a2
	clr.b	(a2)
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
	move	d0,-(sp)
	bsr	druk_cr_nl		;NEWLINE
	clr	d0
	bsr	Druk_char_af2
	move	(sp)+,d0
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
	bsr.b	C146A6

;	move	d0,-(sp)
;	moveq	#13,d0
;	bsr	SENDONECHARNORMAL
;	clr	d0
;	bsr	Druk_char_af2
;	move	(sp)+,d0
	rts

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
	move.b	#$80,d0
	br	CL_NormalChar

CL_ClearCommandline:
	move.l	a0,-(sp)
	lea	(CurrentAsmLine-DT,a4),a0
	cmp.l	a0,a6
	beq.b	.DontClear
	move.l	(sp)+,a0
	bsr	CL_Clear_the_line		;clear line?
	br	CL_DeleteBol

.DontClear:
	move.l	(sp)+,a0
	br	CL_NormalChar		;comm <-> editor

CL_NotEscCode:
	cmp.b	#8,d0
	beq.w	CL_BSCommandline	;BS?
	cmp.b	#$7F,d0			;127
	beq.w	CL_Delete
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

	btst	#MB1_DRUK_IN_MENUBALK,(MyBits-DT,a4)
	beq.s	.norm
	bsr	show_char_in_balk	;in balk dus
	bra.w	.klaar
.norm:
	bsr	Druk_char_af2
.klaar:
	move.b	d1,d0
	cmp.l	a3,a0
	bne.b	.copylopje

	moveq.l	#0,d0
	bsr	Druk_char_af2

cl_lastpart:
	cmp.l	a6,a0
	beq.b	KlaarCommandline
	btst	#MB1_DRUK_IN_MENUBALK,(MyBits-DT,a4)
	bne.s	.klaar4

	moveq	#8,d0
	bsr	Druk_char_af2
.klaar4:
	subq.l	#1,a0
	bra.b	cl_lastpart

;helpme:	dc.w	0

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
	moveq.l	#0,d0
	bsr	show_char_in_balk
	subq.w	#1,(menu_char_pos-DT,a4)
	bra.b	GoOnCommandline
	
CL_BSCommandline:
	cmp.l	a5,a6
	beq.b	KlaarCommandline
	move.l	a6,a0
	subq.l	#1,a6

	btst	#MB1_DRUK_IN_MENUBALK,(MyBits-DT,a4)
	bne.s	back_menub

	move.b	#8,d0
	bsr	Druk_char_af2

GoOnCommandline:
	cmp.l	a0,a3
	beq.b	C147DA
	move.b	(a0)+,d0
	move.b	d0,(-2,a0)

	btst	#MB1_DRUK_IN_MENUBALK,(MyBits-DT,a4)
	beq.s	.nomenub
	bsr	show_char_in_balk
	bra.b	.klaar5
.nomenub:
	bsr	Druk_char_af2
.klaar5:
	bra.b	GoOnCommandline

C147DA:
	btst	#MB1_DRUK_IN_MENUBALK,(MyBits-DT,a4)
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
	btst	#MB1_DRUK_IN_MENUBALK,(MyBits-DT,a4)
	bne.w	CL_DeleteBol

.clearforw:
	cmp.l	a3,a6
	beq.s	.clearback2

	move.b	#' ',d0
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
	beq.w	KlaarCommandline


	move.b	(a6)+,d0

	btst	#MB1_DRUK_IN_MENUBALK,(MyBits-DT,a4)
	beq.s	.nomenu
	bsr	show_char_in_balk
	bra.b	CL_Shift_pijl_rechts
.nomenu:
	bsr	Druk_char_af2
	bra.b	CL_Shift_pijl_rechts

CL_pijl_rechts:	;->
	cmp.l	a6,a3
	beq.w	KlaarCommandline
	
	move.b	(a6)+,d0
	btst    #MB1_DRUK_IN_MENUBALK,(MyBits-DT,a4)
	bne.w	show_char_in_balk
	br	Druk_char_af2

CL_Shift_pijl_links:	;shift '<-'
	cmp.l	a6,a5
	beq.w	KlaarCommandline

	btst	#MB1_DRUK_IN_MENUBALK,(MyBits-DT,a4)
	bne.w	CL_DeleteBol


	moveq	#8,d0
	bsr	Druk_char_af2
	subq.l	#1,a6
	bra.b	CL_Shift_pijl_links

CL_pijl_links: ;<-
	cmp.l	a6,a5
	beq.w	KlaarCommandline

	btst	#MB1_DRUK_IN_MENUBALK,(MyBits-DT,a4)
	bne.w	CL_BSCommandline

	moveq	#8,d0		;BS
	bsr	Druk_char_af2

	subq.l	#1,a6
	rts



CL_Hist_down: ;down
	movem.l	d0-d2/a0/a1,-(sp)
	moveq	#64,d2
	bra.b	History_stuff

CL_Hist_up:	;up
	movem.l	d0-d2/a0/a1,-(sp)
	moveq	#-64,d2
History_stuff:
	lea	(L2A1B6-DT,a4),a0
	move	#COMMANDLINECACHESIZE-1,d1
.hist_lopje:
	add	d2,(DAIRYOUT-DT,a4)
	move	(DAIRYOUT-DT,a4),d0
;	and	#(COMMANDLINECACHESIZE-1)*64,d0		;buffersize (cycle it)
;	and	#$3c0,d0		;buffersize (cycle it)
	tst.w	d0
	bpl.w	.o
	move.w	#0,d0
.o
	cmp.w	#(COMMANDLINECACHESIZE-1)*64,d0
	blt.b	.o2
	move.w	#(COMMANDLINECACHESIZE-1)*64,d0
.o2
	move.w	d0,(DAIRYOUT-DT,a4)

	tst.b	(a0,d0.w)
	bne.b	.Druk_hist_buf_line

	dbra	d1,.hist_lopje
	bra.w	C14898

.Druk_hist_buf_line:
	movem.l	d0/d1/a0,-(sp)

	move.l	a6,d1
	sub.l	a5,d1
	beq.b	C14872
	subq.w	#1,d1

	btst	#MB1_DRUK_IN_MENUBALK,(MyBits-DT,a4)
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

	moveq	#0,d0
	bsr	Druk_char_af2

C14872:
	bsr	C1529A
	movem.l	(sp)+,d0/d1/a0

	moveq	#64-1,d1
	move.l	a5,a1
	add	d0,a0
	moveq	#0,d0
C14882:
	move.b	(a0)+,d0
	move	d0,-(sp)

	btst	#MB1_DRUK_IN_MENUBALK,(MyBits-DT,a4)
	beq.s	.nomenub
	bsr	show_char_in_balk
	bra.b	.klaar
.nomenub:
	bsr	Druk_char_af2
.klaar:
	move	(sp)+,d0
	beq.b	C14894
	move.b	d0,(a1)+
	dbra	d1,C14882
C14894:
	btst	#MB1_DRUK_IN_MENUBALK,(MyBits-DT,a4)
	beq.s	.nomenub2
	subq.w	#1,(menu_char_pos-DT,a4)
.nomenub2:

	move.l	a1,a3
	move.l	a3,a6
C14898:
	movem.l	(sp)+,d0-d2/a0/a1
	rts

INPUT_FILLINDAIRY:
	movem.l	d0/d1/a0/a1,-(sp)
	lea	(CurrentAsmLine-DT,a4),a1
	tst.b	(a1)
	beq.b	C148CC
	move	(DAIRYIN-DT,a4),d0
;	and	#(COMMANDLINECACHESIZE-1)*64,d0			;cycle it
	tst.w	d0
	bpl.w	.o
	move.w	#0,d0
.o
	cmp.w	#(COMMANDLINECACHESIZE-1)*64,d0
	blt.b	.o2
	move.w	#(COMMANDLINECACHESIZE-1)*64,d0
.o2

	lea	(L2A1B6-DT,a4),a0
	add	d0,a0
	moveq	#$3F,d1
C148BA:
	move.b	(a1)+,(a0)+
	dbra	d1,C148BA
	add	#$0040,d0
	move	d0,(DAIRYIN-DT,a4)
	move	d0,(DAIRYOUT-DT,a4)
C148CC:
	movem.l	(sp)+,d0/d1/a0/a1
	rts

Druk_MsgAf_GetNumbr:
	bsr	INPUTTEXT		;drukaf text ? en vraag adres..
INPUTWORKSPACE_NOTEXT:
	lea	(CurrentAsmLine-DT,a4),a6
	bsr	Convert_A2I
	cmp.b	#$61,d1
	rts

INPUTBEGINEND:
	lea	(BEG.MSG,pc),a0
	bsr.b	Druk_MsgAf_GetNumbr
	beq.s	.noprobs
	moveq.l	#-1,d2
	moveq.l	#0,d3
	rts

.noprobs:
	move.l	d0,d2
	lea	(END.MSG0,pc),a0
	bsr.b	Druk_MsgAf_GetNumbr
	move.l	d0,d3
	tst.l	d7
	bne.b	C14950
	cmp.l	d2,d3
;	ble.w	ERROR_Endshouldbehind
	bhs.s	C14950
;	blo.w	ERROR_Endshouldbehind
	jmp	ERROR_Endshouldbehind
C14950:
	sub.l	d2,d3
	rts

putThetextInMenubar:
	movem.l	d1-d6/a0-a3/a5/a6,-(sp)
	move.l	(MainWindowHandle-DT,a4),a1
	bset	#0,($0019,a1)		;rmbtrap

	clr.w	(menu_char_pos-DT,a4)

	bsr	show_txt_in_balk

	move	(cursor_row_pos-DT,a4),-(sp)
	move	(Cursor_col_pos-DT,a4),-(sp)
	bset	#SB2_REVERSEMODE,(SomeBits2-DT,a4)

	bset	#MB1_DRUK_IN_MENUBALK,(MyBits-DT,a4)
	bsr	get_text_invoer_menuCmd
	bclr	#MB1_DRUK_IN_MENUBALK,(MyBits-DT,a4)

	bset	#SB1_WINTITLESHOW,(SomeBits-DT,a4)	;get old title back
	move	(Cursor_col_pos-DT,a4),(menu_char_pos-DT,a4)
	move	(sp)+,(Cursor_col_pos-DT,a4)
	move	(sp)+,(cursor_row_pos-DT,a4)
	bclr	#SB2_REVERSEMODE,(SomeBits2-DT,a4)

	move.l	(MainWindowHandle-DT,a4),a1
	bclr	#0,($0019,a1)		;klaar rmb trap
	movem.l	(sp)+,d1-d6/a0-a3/a5/a6
	cmp.b	#13,d0
	rts

GetNrFromTitle:
	bsr	putThetextInMenubar
	bne.b	C149EC
	lea	(CurrentAsmLine-DT,a4),a0
	moveq	#0,d0
	moveq	#$30,d1
	moveq	#10,d2
	moveq	#0,d3
C149DA:
	move.b	(a0)+,d3
	sub.b	d1,d3
	cmp.b	d2,d3
	bcc.b	C149E8
	mulu	d2,d0
	add.l	d3,d0
	bra.b	C149DA

C149E8:
	moveq	#$61,d1
	rts

C149EC:
	moveq	#0,d1
	rts

C149F0:
	lea	(MENUCHAR_TEXTBUFFER-DT,a4),a0
	move.b	d0,(a0)
	bra.b	druk_menu_txt_verder

printTextInMenuStrip:
	clr	(menu_char_pos-DT,a4)
	move.b	#0,titletxt
druk_menu_txt_verder:
	movem.l	d0-d6/a0-a3/a5/a6,-(sp)
	
	bsr	show_txt_in_balk
	
	bset	#SB1_WINTITLESHOW,(SomeBits-DT,a4)	;get old title back

	movem.l	(sp)+,d0-d6/a0-a3/a5/a6
	rts

titletxt:
	dcb.b	80,0
	dc.b	0
	cnop	0,4

	
show_char_in_balk:
	movem.l	d0/d1/a0-a3/a6,-(sp)
	lea	titletxt,a1
	move.l	a1,-(sp)
	add.w	(menu_char_pos-DT,a4),a1	;col pos

	cmp.b	#'	',d0
	bne.s	.noprobs
	move.b	#' ',d0

.noprobs:
	move.b	d0,(a1)+
	addq.w	#1,(menu_char_pos-DT,a4)
	move.b	#0,(a1)
	bra.b	show_title_ding
	

show_txt_in_balk:
	movem.l	d0/d1/a0-a3/a6,-(sp)

	lea	titletxt,a1
	move.l	a1,-(sp)

	add.w	(menu_char_pos-DT,a4),a1	;col pos
	moveq.l	#-1,d0
.lopje:
	addq.l	#1,d0
	move.b	(a0)+,(a1)+
	bne.s	.lopje

	add.w	d0,(menu_char_pos-DT,a4)

show_title_ding:
	move.l	(sp)+,a2
	move.l	(MainWindowHandle-DT,a4),a0
	moveq	#-1,d0
	move.l	d0,a1
	move.l	(IntBase-DT,a4),a6
	jsr	(_LVOSetWindowTitles,a6)
	bclr	#SB1_WINTITLESHOW,(SomeBits-DT,a4)

	movem.l	(sp)+,d0/d1/a0-a3/a6
	rts
	
RESETMENUTEXT:
	btst	#SB1_WINTITLESHOW,(SomeBits-DT,a4)
	beq.b	C14A84
RESETMENUTEXT2:
	movem.l	d0/d1/a0-a3/a6,-(sp)
	move.l	(MainWindowHandle-DT,a4),a0
	moveq	#-1,d0
	move.l	d0,a1
	lea	(AsmPro_titletxt.MSG,pc),a2
	move.l	(IntBase-DT,a4),a6
	jsr	(_LVOSetWindowTitles,a6)
	bclr	#SB1_WINTITLESHOW,(SomeBits-DT,a4)
	movem.l	(sp)+,d0/d1/a0-a3/a6
C14A84:
	rts

;**************** DRUK TEXT IN COMMAND SHELL *******************

Druk_regel_in_commandshell:
	movem.l	d0-d7/a0-a3/a5/a6,-(sp)
	tst.l	d3
	beq.b	C14B54
.menustate:
	move.l	(MainWindowHandle-DT,a4),a1
	btst	#7,($001A,a1)		;menustate
	bne.b	.menustate

	move.l	d2,a0
	jsr	Show_Cursor
	bsr	Print_d3_chars
	jsr	Show_Cursor
C14B54:
	movem.l	(sp)+,d0-d7/a0-a3/a5/a6
	rts


Print_d3_chars:
	subq.w	#1,d3

	bsr	get_font

	move	(Cursor_col_pos-DT,a4),d6	;x-pos
	move	(cursor_row_pos-DT,a4),d7

	movem.l	d0-a6,-(sp)
	move.l	(GfxBase-DT,a4),a6
	move.l	(Rastport-DT,a4),a1

	move.w	d6,d0		;x
	mulu.w	(EFontSize_x-DT,a4),d0
	move.w	d7,d1		;y
	lsr.w	#1,d1		;*8
	mulu.w	(EFontSize_y-DT,a4),d1

	add.w	(Scr_Title_sizeTxt-DT,a4),d1	;!2
	jsr	(_LVOMove,a6)		; ***

	movem.l	(sp)+,d0-a6

	lea	(regel_buffer-DT,a4),a1		;command
print_char_CL:
	moveq	#0,d0
	move.b	(a0)+,d0
	cmp.b	#$9B,d0
	beq	text_offset_stuff
	cmp.b	#' ',d0
	bcs.w	text_white_space

	move.b	d0,(a1)+			;stop char in buffer

	addq.w	#1,d6
	cmp	(Scr_br_chars-DT,a4),d6	;buffer is ook maar 256 bytes..
	bne.b	nog_niet_scrollen
CR_DUS_NEXT_REGEL:

	movem.l	d0-a6,-(sp)
	lea	(regel_buffer-DT,a4),a0		;command
	move.l	a1,d0
	sub.l	a0,d0		;count

	cmp.l	#255,d0
	bhi.s	.noprobs

	move.l	(GfxBase-DT,a4),a6
	move.l	(Rastport-DT,a4),a1
	jsr	(_LVOText,a6)		; ***
.noprobs:
	movem.l	(sp)+,d0-a6

	lea	(regel_buffer-DT,a4),a1		;command

	moveq	#0,d6
	addq.w	#2,d7
	cmp	(Max_Hoogte-DT,a4),d7
	bne.b	alleen_CL_movecurs
	move	(aantal_regels_min3_div2-DT,a4),d7	;buiten het scherm dus scrollen
	bsr	scroll_up_cmdmode

;2de kolom..
alleen_CL_movecurs:
	movem.l	d0-a6,-(sp)
	move.l	(GfxBase-DT,a4),a6
	move.l	(Rastport-DT,a4),a1
	
	move.w	d6,d0		;x
	mulu.w	(EFontSize_x-DT,a4),d0
	move.w	d7,d1		;y
	lsr.w	#1,d1		;*8
	mulu.w  (EFontSize_y-DT,a4),d1

	add.w	(Scr_Title_sizeTxt-DT,a4),d1	;!2
	jsr	(_LVOMove,a6)	; ***
	movem.l	(sp)+,d0-a6

nog_niet_scrollen:
	dbf	d3,print_char_CL

	movem.l	d0-a6,-(sp)
	lea	(regel_buffer-DT,a4),a0		;command
	move.l	a1,d0
	sub.l	a0,d0		;count

	cmp.l	#255,d0
	bhi.s	.probs

	move.l	(GfxBase-DT,a4),a6
	move.l	(Rastport-DT,a4),a1
	jsr	(_LVOText,a6)		; ***

.probs:
	movem.l	(sp)+,d0-a6

	lea	(regel_buffer-DT,a4),a1		;command
CL_cursorstuff:
	move	d6,(Cursor_col_pos-DT,a4)	;x
	move	d7,(cursor_row_pos-DT,a4)	;y
	rts

text_white_space:
	cmp.b	#10,d0	;LF
	beq.w	CR_DUS_NEXT_REGEL
	cmp.b	#13,d0	;CR
	beq.b	CL_CReturn
	cmp.b	#8,d0	;BS
	beq.b	CL_BackSpace
	cmp.b	#9,d0	;TAB
	beq.b	.tabulator
	cmp.b	#12,d0	;FF
	beq	clear_plane1_en2
	bra.b	nog_niet_scrollen

.tabulator:
	move.b	#" ",(a1)+
	addq.w	#1,d6

	bra.b	nog_niet_scrollen


CL_BackSpace:	;BS
	subq.w	#1,d6
	bpl.w	alleen_CL_movecurs
	moveq	#0,d6
	move	(Scr_br_chars-DT,a4),d6
	subq.w	#1,d6
	subq.w	#2,d7
	bpl.w	alleen_CL_movecurs
	moveq	#0,d7
	bra.w	alleen_CL_movecurs

CL_CReturn:	;CR
	moveq	#0,d6
	bra.w	alleen_CL_movecurs

;***************************************

text_offset_stuff:
;	addq.l	#1,a0
	subq.w	#1,d3
	bmi.w	CL_cursorstuff
C14EC0:
	moveq	#0,d1
C14EC2:
	moveq	#0,d0
	move.b	(a0)+,d0
	cmp.b	#$3A,d0		;':'  0..9
	bcc.b	C14EE4
	cmp.b	#$2F,d0		;'/'
	bls.w	nog_niet_scrollen
	sub	#$30,d0
	mulu	#10,d1
	add	d0,d1
	dbra	d3,C14EC2
	bra.w	CL_cursorstuff

C14EE4:
	cmp.b	#$3B,d0		;';'
	beq.b	C14F4C
	cmp.b	#$48,d0		;'H' ->
	beq.b	C14F32
	cmp.b	#$4B,d0		;'K'
	beq.b	C14F72
	cmp.b	#$44,d0		;'D' <-
	beq.b	pijl_terug_CL
	cmp.b	#$6D,d0		;'m' inverse
	beq.b	C14F0E
	br	nog_niet_scrollen

C14F06:
	dbra	d3,C14EC0
	br	CL_cursorstuff

C14F0E:
	bchg	#SB2_REVERSEMODE,(SomeBits2-DT,a4)	;toggle inverse font
	bsr	get_font
	br	nog_niet_scrollen

pijl_terug_CL:
	sub	d1,d6
C14F1E:
	tst	d6
	bpl.w	alleen_CL_movecurs	;niet begin regel
	add.w	(Scr_br_chars-DT,a4),d6	;!3
	subq.w	#2,d7			;niet begin y
	bpl.b	C14F1E
	moveq	#0,d7
	br	alleen_CL_movecurs

C14F32:
	subq.w	#1,d1
	bpl.b	C14F3A
	br	nog_niet_scrollen

C14F3A:
	cmp	(Scr_br_chars-DT,a4),d1
	bcs.b	C14F46
	move	(Scr_br_chars-DT,a4),d1
	subq.w	#1,d1
C14F46:
	move	d1,d6
	br	alleen_CL_movecurs

C14F4C:
	subq.w	#1,d1
	bpl.b	C14F52
	bra.b	C14F06

C14F52:
	cmp	(aantal_regels_min2-DT,a4),d1
	bcs.b	C14F60
	move	(aantal_regels_min3-DT,a4),d1
	bsr	scroll_up_cmdmode
C14F60:
	lsl.w	#1,d1		;!!! there is an enforcer hit somewhere around here..
	move	d1,d7
	move.l	a6,a1
	move	d7,-(sp)
	add	d7,d7
	add.l	(a5,d7.w),a1
	move	(sp)+,d7
	bra.b	C14F06

C14F72:
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
	mulu.w  (EFontSize_x-DT,a4),d0
	move.w	d7,d1		;y
	lsr.w	#1,d1
	mulu.w  (EFontSize_y-DT,a4),d1

	add.w	(Scr_Title_sizeTxt-DT,a4),d1	;!2
	jsr	(_LVOMove,a6)	; ***

	jsr	(_LVOClearEOL,a6)		; ***
	movem.l	(sp)+,d0-a6

	br	alleen_CL_movecurs

;*********** CURSOR STUFF ***********

Place_cursor_blokje:
	move	(cursor_row_pos-DT,a4),d7	; *** y
	bne.b	.algoed				; ***
	jsr	(C1382).l
.algoed:
	movem.l	d0-a6,-(sp)

	move.l	(GfxBase-DT,a4),a6
	move.l	(Rastport-DT,a4),a1

	moveq.l	#3,d0
	jsr	(_LVOSetAPen,a6)	; ***
	moveq.l	#2,d0			; inverse
	jsr	(_LVOSetDrMd,a6)	; ***

	move.w	(Cursor_col_pos-DT,a4),d0	; x
	mulu.w	(EFontSize_x-DT,a4),d0
	
	move.w	d7,d1
	lsr.w	#1,d1
	mulu.w	(EFontSize_y-DT,a4),d1

	add.w	(Scr_Title_size-DT,a4),d1

	movem.w	d0/d1,-(sp)		; ***
	move.w	boldx(pc),d0
	move.w	boldy(pc),d1
	bmi.b	.ok			; *** Reset caret
	cmp.w	(sp),d1			; *** Old values are differents ?
	bne.b	.print			; ***
	cmp.w	2(sp),d0
	bne.b	.print			; ***
	movem.w	(sp)+,d0/d1		; ***
	bra.b	.klaarhoor		; *** Same position: leave it as is
.print
	bsr.b	.blokje			; *** Clear it at old position
	move.l	(Rastport-DT,a4),a1
.ok:
	movem.w	(sp)+,d0/d1		; ***
	move.w	d0,boldx		; *** Save old values
	move.w	d1,boldy
	bsr	.blokje			; *** Display it at new position
.klaarhoor:
	move.l	(GfxBase-DT,a4),a6
	move.l	(Rastport-DT,a4),a1

	moveq.l	#1,d0
	jsr	(_LVOSetAPen,a6)	; ***
	moveq.l	#0,d0
	jsr	(_LVOSetBPen,a6)	; ***
	moveq.l	#1,d0			;jam2
	jsr	(_LVOSetDrMd,a6)	; ***

	movem.l	(sp)+,d0-a6
	rts

.blokje:
	move.w	d0,d2
	add.w	(EFontSize_x-DT,a4),d2
	subq.w	#1,d2
	move.w	d1,d3
	add.w	(EFontSize_y-DT,a4),d3
	subq.w	#1,d3
	jsr	(_LVORectFill,a6)	; ***
	jmp	_LVOWaitBlit(a6)

reset_pos:
boldx:	dc.w	0
boldy:	dc.w	0

get_font:
	movem.l	d0-d2/a0-a2/a6,-(sp)
	move.l	(GfxBase-DT,a4),a6
	move.l	(Rastport-DT,a4),a1

	btst	#SB2_REVERSEMODE,(SomeBits2-DT,a4)
	bne.b	.Inverse_txt

	moveq.l	#1,d0		;apen zwart
	jsr	(_LVOSetAPen,a6)	; ***
	moveq.l	#0,d0		;bpen grijs
	jsr	(_LVOSetBPen,a6)	; ***
	movem.l	(sp)+,d0-d2/a0-a2/a6
	rts

.Inverse_txt:
	moveq.l	#2,d0		;apen wit
	jsr	(_LVOSetAPen,a6)	; ***
	moveq.l	#1,d0		;bpen zwart
	jsr	(_LVOSetBPen,a6)	; ***
	movem.l	(sp)+,d0-d2/a0-a2/a6
	rts

;********* NEW SCROLL ROUTINES ***************
;They should work on a gfx board now..

scroll_up_cmdmode:
	movem.l	d0-a6,-(sp)

	move.l	(GfxBase-DT,a4),a6
;	jsr	_LVOWaitBlit(a6)
;	jsr	_LVOWaitTOF(a6)

	move.l	(Rastport-DT,a4),a1

	moveq.l	#0,d0		;dx
	moveq.l	#0,d1		;dy
	move.w	(EFontSize_y-DT,a4),d1	;dy
	moveq.l	#0,d2		;x1
	moveq.l	#0,d3		;x1
	move.w	(Scr_Title_size-DT,a4),d3

	move.w	(Scr_breedte-DT,a4),d4

	move.w	(ScreenHight-DT,a4),d5
	mulu.w	(EFontSize_y-DT,a4),d5
	add.w	#2,d5		;correctie

	jsr	_LVOScrollRaster(a6)	;scrollraster ;-396

	movem.l	(sp)+,d0-a6
	rts

scroll_up_cmd_fix:
	movem.l	d0-a6,-(sp)
	jsr	Show_Cursor

	move.l	(GfxBase-DT,a4),a6
;	jsr	_LVOWaitBlit(a6)
;	jsr	_LVOWaitTOF(a6)
	move.l	(Rastport-DT,a4),a1

	moveq.l	#0,d0		;dx
	moveq.l	#5,d1		;dy
	moveq.l	#0,d2		;x1
	moveq.l	#0,d3		;y1
	move.w	(Scr_Title_size-DT,a4),d3
	
	move.w	(Scr_breedte-DT,a4),d4

	move.w	(ScreenHight-DT,a4),d5
	mulu.w	(EFontSize_y-DT,a4),d5
	add.w	#2+4,d5		;correctie?

	jsr	_LVOScrollRaster(a6)	;scrollraster ;-396

	jsr	Show_Cursor
	movem.l	(sp)+,d0-a6
	rts

;**********************************************

clear_all:
	movem.l	d0-a6,-(sp)

	move.l	(GfxBase-DT,a4),a6
	move.l	(Rastport-DT,a4),a1

	moveq.l	#0,d0		;x
	moveq.l	#0,d1		;y
	move.w	(Scr_Title_sizeTxt-DT,a4),d1	;!2
	jsr	(_LVOMove,a6)	; ***

	jsr	(_LVOClearScreen,a6)		; ***
	movem.l	(sp)+,d0-a6
	rts

clear_plane1_en2:
	bsr	clear_all
	
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

	moveq.l	#0,d6		;turbo scroll?
	
	move.l	(Rastport-DT,a4),a1

	moveq.l	#0,d0		;dx
	moveq.l	#0,d1		;dy
	move.w	(EFontSize_y-DT,a4),d1

	tst.w	d6
	beq.s	.noturbo
	mulu.w	#2,d1
.noturbo:
	moveq.l	#0,d2		;x1
	moveq.l	#0,d3		;y1
	move.w	(Scr_Title_size-DT,a4),d3

	move.w	(Scr_breedte-DT,a4),d4

	move.w	(NrOfLinesInEditor-DT,a4),d5

	addq.w	#1,d5
	sub.w	d6,d5

	mulu.w	(EFontSize_y-DT,a4),d5

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

	lea	(a5,d2.l),a5	;
	move.l	a5,a6
	add.w	d3,a5		;2*82*13

	move.w	(Edit_nrlines-DT,a4),d7	;aantal editorbeeldlijntjes -1

;	cmp.w	#PB_030,(ProcessorType-DT,a4)
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

	moveq.l	#0,d0		;dx
	moveq.l	#0,d1		;dy
	sub.w	(EFontSize_y-DT,a4),d1
	ext.l	d1
	moveq.l	#0,d2		;x1
	moveq.l	#0,d3		;y1
	move.w	(Scr_Title_size-DT,a4),d3

	move.w	(Scr_breedte-DT,a4),d4

;	move.w	(Edit_nrlines-DT,a4),d5
	move.w	(NrOfLinesInEditor-DT,a4),d5
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
	moveq.l	#0,d3
	move.w	(EditScrollRegelSize-DT,a4),d3

	move.w  (NrOfLinesInEditor-DT,a4),d5
	cmp.w	(AantalRegels_HalveEditor-DT,a4),d5
	bne.w	.nodiv
	sub.l	d3,d2
	lsr.l	#1,d2
.nodiv
	lea	(a5,d2.l),a5
	lea	(a5,d3.w),a6

;	move.w	(NrOfLinesInEditor-DT,a4),d7
;	addq.w	#1,d7
;	mulu.w	(EFontSize_y-DT,a4),d7

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
	move	#$009B,d0
	bsr	Druk_char_af2
	moveq	#'H',d0
	br	Druk_char_af2

Debug_PrintStatusBalk2:
	moveq.l	#0,d7
	lea	(End_msg,pc),a0
	bra.b	vulin_infobar

StatusBar_monitor:
	moveq.l	#1,d7
	lea	(art.MSG,pc),a0
	bra.b	vulin_infobar

PrintStatusBalk:
	moveq.l	#2,d7
	lea	(neColBytesFre.MSG,pc),a0
vulin_infobar:
	movem.l	d0-d7/a0-a3/a5/a6,-(sp)
;	bsr	Place_cursor_blokje

;	jsr	get_font1
	jsr	get_font4

	move.l	a0,-(sp)
	
	move.l	(GfxBase-DT,a4),a6
	move.l	(Rastport-DT,a4),a1
	move.w	#0,d0	;x

	move    (NrOfLinesInEditor-DT,a4),d1
	mulu.w	(EFontSize_y-DT,a4),d1
	add.w	(Scr_Title_size-DT,a4),d1
	addq.w	#1,d1

	move.w	(Scr_breedte-DT,a4),d2	;x-max
	move.w	d1,d3
;	add.w	#FontSize_y+4,d3	;y-max
	add.w	(EFontSize_y-DT,a4),d3
	addq.w	#4,d3
	jsr	_LVOEraseRect(a6)

	move.l	(sp)+,a0

	move.l	(GfxBase-DT,a4),a6
	move.l	(Rastport-DT,a4),a1

	subq.w	#2,a0		;old not needed no more
	
	move.w	#0,d0		;x

	move	(NrOfLinesInEditor-DT,a4),d1
	mulu.w	(EFontSize_y-DT,a4),d1
	add.w	(Scr_Title_sizeTxt-DT,a4),d1	;!2
	add.w	#2,d1		;title size
	jsr	(_LVOMove,a6)	; ***

;	cmp.w	#2,7
;	bne.s	.noprobs
	moveq.l	#78-13,d0
;	bra.b	.probs
;.noprobs:	
;	moveq.l	#80,d0		;count
.probs:
	jsr	(_LVOText,a6)		; ***

	move.w	(Scr_br_chars),d2
	sub.w	#10,d2
;	mulu.w	#FontSize_x,d2
;	mulu.w	(EFontSize_x-DT,a4),d2
;	subq.w	#3,d2

	move.w	d2,time1
	move.w	d2,time2

	move.l	(GadToolsBase-DT,a4),a6
	lea.l   PW_NR,a1
	move.l	(MainVisualInfo-DT,a4),4(a1)

	move.l	(Rastport-DT,a4),a0

	move.w  #1,d0		;x
	move    (NrOfLinesInEditor-DT,a4),d1
	mulu.w	(EFontSize_y-DT,a4),d1
	add.w	(Scr_Title_size-DT,a4),d1
	move.w	d1,d6
	addq.w	#1,d6

	move.w  (Scr_breedte),d2	;br
	subq.w	#3,d2
	move.w	(EFontSize_y-DT,a4),d3
	addq.w	#4,d3
	jsr     _LVODrawBevelBoxA(a6)

	move.l	(Rastport-DT,a4),d5
	move.l	#PW_IR,d4
	move.w  (EFontSize_y-DT,a4),d3	;hoog
	addq.w	#2,d3

	lea	bc(pc),a5
	lsl.l	#2,d7
	move.l	(a5,d7),a5
;	lea	bevcoords(pc),a5

	move.w	(a5)+,d7
	bra.b	.go

.lopje:
	move.l	d4,a1
	move.l	d5,a0

	move.w	(a5)+,d0	;x
	mulu.w	(EFontSize_x-DT,a4),d0
	subq.w	#3,d0
	move.w	d6,d1		;y
	move.w  (a5)+,d2	;br
	mulu.w	(EFontSize_x-DT,a4),d2
	addq.w	#5,d2
	jsr     _LVODrawBevelBoxA(a6)
.go
	dbf	d7,.lopje

.klaar:
;	bsr	Place_cursor_blokje
	movem.l	(sp)+,d0-d7/a0-a3/a5/a6
	rts

bc:	dc.l	bevcoords1
	dc.l	bevcoords2
	dc.l	bevcoords3
	
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
	bsr	PI_druklinenr
	lea	(ascii.MSG87,pc),a0
	bsr	printthetext
	move.l	(FileLength-DT,a4),d0
	bsr	druk_af_d0
	bsr	druk_af_space
	moveq	#')',d0
	bsr	SENDONECHARNORMAL
	bsr	druk_cr_nl
	moveq	#0,d0
	br	SENDONECHARNORMAL

;****************************
;*    PRINT SYMBOL TABLE    *
;****************************

com_PRINT_SYMBOLTABEL:
	move.b	#$FF,(B30048-DT,a4)
	clr	(PageNumber-DT,a4)
	move	(aantal_regels_min2-DT,a4),(PageHeight-DT,a4)
	move	(Scr_br_chars-DT,a4),(PageWidth-DT,a4)
	clr	(PageLinesLeft-DT,a4)
	bset	#$1D,d7
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
	bne	.C15410

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
	moveq	#0,d0
	btst	#0,(PR_Upper_LowerCase).l
	beq.b	.C153D4
	bclr	#5,(B30048-DT,a4)
	bclr	#5,(B30049-DT,a4)
.C153D4:
	move.b	(B30048-DT,a4),d0
	sub	#$0040,d0
	tst	d0
	bcs.b	.C15410
	lsl.w	#2,d0
	mulu	(Label2Entry-DT,a4),d0
	add.l	d0,a2
	move.b	(B30048-DT,a4),d5
	moveq	#0,d0
	move.b	(B30049-DT,a4),d0
	move	(Label1Entry-DT,a4),d6
	add	#$0040,d6
	cmp	d6,d0
	bgt.b	.loop2
	sub	#$0030,d0
	tst	d0
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
;C1544C:
	moveq	#0,d0
	bsr	SENDONECHARNORMAL		;druk regel en leeg buffer
	rts

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
	bsr	.SPECIAL_PRINT
	move.b	(a0)+,d0
	subq.w	#1,d1
	bmi.b	.C15488
	bsr	.SPECIAL_PRINT
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
	moveq	#' ',d0
	br	SENDONECHARNORMAL

.ItsAMacro:
	lsr.w	#7,d0
	and	#$007E,d0
	cmp	#2,d0
	beq.b	.C154B8

	lea	(.symboltabje,pc),a0
	add	d0,a0
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
	moveq	#0,d0
	br	SENDONECHARNORMAL

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
	subq.b	#1,d2
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
	moveq	#$3D,d0
	bsr	SENDONECHARNORMAL
	move	(ResponseType-DT,a4),d0
	bsr	C15908
	moveq	#$2E,d0
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
	moveq	#$2E,d0
	bsr	SENDONECHARNORMAL
	move.l	a0,d0
	bsr	Druk_af_D0
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
	lsl.w	#1,d5
C155C4:
	bsr	druk_af_space
	dbra	d5,C155C4
C155CC:
	move.l	(DATA_LINE_START_PTR-DT,a4),a0
	move	(PageWidth-DT,a4),d2
	sub	#$0029,d2
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
	moveq	#$20,d0
	bsr	SENDONECHARNORMAL
	dbra	d2,C155F0
	bra.b	C155CC

C155FC:
	bsr	druk_af_space
	dbra	d1,C15606
	bra.b	C15614

C15606:
	move	d1,d0
	sub	d2,d0
	neg.w	d0
	and	#7,d0
	bne.b	C155FC
	bra.b	C155DA

C15614:
	br	druk_cr_nl

PRINT_PAGED:
	btst	#$1D,d7
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
	addq.w	#1,(PageNumber).l
	move	(PageHeight-DT,a4),d0
	subq.w	#2,d0
	move	d0,(PageLinesLeft-DT,a4)
	move	(PageNumber-DT,a4),d0
	bsr	C1596C
	tst.b	(TITLE_STRING-DT,a4)
	beq.b	C15676
	lea	(Of.MSG,pc),a0
	bsr	printthetext
	lea	(TITLE_STRING-DT,a4),a0
	bsr	printthetext
C15676:
	bsr	druk_cr_nl
	bsr	druk_cr_nl
	move.l	(sp)+,a0
	rts

C15682:
	rts

PRINTINCLUDENAME:
	movem.l	d0-d7/a0-a6,-(sp)
	bsr	printthetext		;Incbin  : "
	move.l	a0,-(sp)
	lea	(CurrentAsmLine-DT,a4),a0
	movem.l	d1/a6,-(sp)
	move.l	a0,a6
	moveq	#0,d1
C1569A:
	tst.b	(a6)
	beq.b	DA_EndFilename	;klaar
	cmp.b	#':',(a6)
	beq.b	C156A8
C156A4:
	addq.l	#1,a6
	bra.b	C1569A
C156A8:
	addq.w	#1,d1
	bra.b	C156A4


DA_EndFilename:
	cmp	#1,d1
	bgt.b	C156B8
	tst	(W2DF84-DT,a4)
	beq.b	C156BC
C156B8:
	lea	(SourceCode-DT,a4),a0
C156BC:
	bsr	strcount
	movem.l	(sp)+,d1/a6
	bsr	PrintMsgText	; dh1:asmpro_os/pics/asm-pro48x74.iff
	move.l	(sp)+,a0
	bsr	printthetext
	movem.l	(sp)+,d0-d7/a0-a6
	rts

strcount:
	move.l	a0,a6
	move.w	(Scr_br_chars-DT,a4),d1
	sub.w	#27-2+13,d1
.lopje
	tst.b	(a6)+
	beq.s	.klaar
	subq.l	#1,d1
	bra.b	.lopje
.klaar
	tst.w	d1
	bpl.s	.nothin
	neg.w	d1
	lea	(a0,d1.w),a0
.nothin:
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

	move.w	(Scr_br_chars-DT,a4),d1
	sub.w	#27-2,d1
	cmp.w	d1,d0
	bhi.s	.klaar

	move.b	(a0)+,d0
	bne.b	drukke

	move.l	(text_buf_ptr-DT,a4),d0
	sub.l	#TextPrintBuffer,d0

	move.w	(Scr_br_chars-DT,a4),d7
	sub.w	#27-2,d7
	sub.w	d0,d7
;	bra.b	.jumpin
.lopje:
	bsr	druk_af_space
;.jumpin:
	dbf	d7,.lopje
.klaar:
	rts


C156DA:
	bsr	SENDONECHARNORMAL
	moveq	#0,d0
	sub.b	(a0)+,d0
	bne.b	C156DA
	br	SENDONECHARNORMAL

C156E8:
	clr	d0
	bsr	SENDONECHARNORMAL
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
	bra.w	SENDONECHARNORMAL


update_status_bar:
	bsr.b	druk_status_en_end_af
	bra.w	SENDONECHARNORMAL

C1570A:
	bsr	SENDONECHARNORMAL
	move.b	(a0)+,d0
	bpl.b	C1570A
	and	#$007F,d0
	bra.b	SENDONECHARNORMAL

druk_cr_nl:
	move	d0,-(sp)
	move.b	#13,d0
	bsr.b	SENDONECHARNORMAL
	move.b	#10,d0
	bsr.b	SENDONECHARNORMAL
	move	(sp)+,d0
	rts

Druk_af_eol:
	move.b	#10,d0
	bra.b	SENDONECHARNORMAL

Druk_Clearbuffer:
	move.b	#0,d0
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
	beq.b	C15768
	bsr	druk_af_op_printer
C15768:
	movem.l	(sp)+,d0-d3
	move.l	(sp)+,a0
	rts

druk_eol:
	movem.l	d0-a6,-(sp)
	bclr	#SB1_CHANGE_MODE,(SomeBits-DT,a4)
	moveq.l	#0,d0
	bsr.s	SENDONECHARNORMAL
	movem.l	(sp)+,d0-a6
	rts
	
druk_af_space:
	move.b	#" ",d0
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
	btst	#SB2_OUTPUTACTIVE,(SomeBits2-DT,a4)	;output2screen2
	beq.b	.C157E4
	bsr	C17ADE
.C157E4:
	bsr	Druk_regel_in_commandshell
	bsr	messages_get
C157EC:
	movem.l	(sp)+,d0-d3
	move.l	(sp)+,a0
	rts

Druk_char_af2:
	tst.b	(SomeBits-DT,a4)	;bit 7
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
;	btst	#MB1_DRUK_IN_MENUBALK,(MyBits-DT,a4)
;	beq.s	.gewoon
;	
;;	bsr	show_txt_in_balk2
;	bra.b	.inbalk
;.gewoon:
	bsr	Druk_regel_in_commandshell
;.inbalk
	bsr	messages_get
C1584C:
	movem.l	(sp)+,d0-d3
	move.l	(sp)+,a0	;txt pointer terug.
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
	bne.b	C15876
	jsr	(OpenPrinterForOutput).l			;open file
	move.l	(PrinterBase-DT,a4),d1	;file
	beq.b	C15882
C15876:
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOWrite,a6)
	bsr	messages_get
C15882:
	movem.l	(sp)+,d0-d6/a0-a3/a5/a6
	rts

SENDCHARDELSCR:
	moveq	#12,d0
	br	Druk_char_af2

C1588E:
	move.b	#$9B,d0
	bsr	Druk_char_af2
	moveq	#$4B,d0
	br	Druk_char_af2

PRINT_CLEARSCREEN:
	move.b	#$9B,d0
	bsr	Druk_char_af2
	moveq	#$48,d0
	br	Druk_char_af2

Druk_af_D0:
	bsr.b	druk_af_d0
	br	druk_af_space


C158CA:
	move.l	(sp),d0
	cmp.l	(INSERT_START-DT,a4),d0
	bcs.b	C158EE
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
	moveq	#$24,d0
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
	add.b	#$30,d0
	cmp.b	#$39,d0
	ble.w	SENDONECHARNORMAL
	addq.b	#7,d0
	br	SENDONECHARNORMAL

DrukAf_LineNrPrint:
	bsr.b	C1596C
	br	druk_af_space

Druk_D0_inCommandline:
	tst.l	d0
	bpl.b	PI_druklinenr
	move.l	d0,-(sp)
	moveq	#$2D,d0
	bsr	SENDONECHARNORMAL
	move.l	(sp)+,d0
	neg.l	d0
	moveq	#0,d3
	bra.b	C1597C

C1596C:
	moveq	#$20,d3
	and.l	#$0000FFFF,d0
	lea	(TABEL_HEXTODEC3,pc),a0
	bra.b	C15980

PI_druklinenr:
	moveq	#$20,d3
C1597C:
	lea	(TABEL_HEXTODEC,pc),a0
C15980:
	move.l	d0,d2
C15982:
	move.l	(a0)+,d1
	beq.b	C159B4
	cmp.l	d1,d2
	bcs.b	C15994
	moveq	#$30,d3
C1598C:
	sub.l	d1,d2
	addq.b	#1,d3
	cmp.l	d1,d2
	bcc.b	C1598C
C15994:
	tst.b	d3
	beq.b	C15982
	move.b	d3,d0
	tst.b	(B3004E-DT,a4)
	beq.b	C159AA
	cmp.b	#$20,d0
	beq.b	C159AE
	move.b	d0,(a3)+
	bra.b	C159AE

C159AA:
	bsr	SENDONECHARNORMAL
C159AE:
	and.b	#$F0,d3
	bra.b	C15982

C159B4:
	move.l	d2,d0
	add.b	#$30,d0
	tst.b	(B3004E-DT,a4)
	beq.b	C159CA
	cmp.b	#$20,d0
	beq.b	C159C8
	move.b	d0,(a3)+
C159C8:
	rts

C159CA:
	br	SENDONECHARNORMAL

TABEL_HEXTODEC:
	dc.l	1000000000
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


SECTION_START_DEFINITION:
	dc.l	0,0	;ptrs
ProgramName:
	dc.w	'TE','XT'+$8000
	dc.w	$0001

	dc.w	$0000
	dcb.l	$0000003F,0
	dc.w	$0000
	dc.w	'TE','XT'+$8000
	dc.w	$0001
;	dc.l	$5445D854
;	dc.w	$0001

C15B0A:
	movem.l	d0-d7/a0-a6,-(sp)
	fmove.d	fp0,(D02F260-DT,a4)
	move	#8,(W2F254-DT,a4)
	clr.b	(B3004A-DT,a4)
	clr.b	(B3004B-DT,a4)
	clr.b	(B3004C-DT,a4)
	move.b	#$20,(E0.MSG).l

	fmove.d #10.0,fp0
;	dc.w	$F23C	
;	dc.w	$5400
;	dc.w	$4024
;	dcb.w	3,0

	fmove.d	fp0,(D02F258-DT,a4)
	move.l	(L2F26C-DT,a4),d0
	btst	#$18,d0
	bne	C15C1C
	btst	#$1A,d0
	bne	C15C00
	btst	#$19,d0
	beq.b	C15B60
	move.b	#1,(B3004B-DT,a4)
C15B60:
	btst	#9,d0
	beq.b	C15B6C
	move.b	#1,(B3004C-DT,a4)
C15B6C:
	fmove.d	(D02F260-DT,a4),fp0
	fbeq	C15C00
	fbun.w	C15C1C
	fboge.w	C15B8E
	move.b	#1,(B3004A-DT,a4)
	fneg.x	fp0
	fmove.d	fp0,(D02F260-DT,a4)
C15B8E:
	fmove.d #999999999,fp0
	;dc.w	$F23C
	;dc.w	$5400
	;dc.w	$41CD
	;dc.w	$CD64
	;dc.w	$FF80
	;dc.w	0

	fmove.d	(D02F260-DT,a4),fp1
	fcmp.x	fp0,fp1
	fbogt.w	C15BBE

	fmove.d #99999999,fp0
	;dc.w	$F23C
	;dc.w	$5400
	;dc.w	$4197
	;dc.w	$D783
	;dc.w	$FC00
	;dc.w	0

	fcmp.x	fp0,fp1
	fbolt.w	C15BDC
	bra.b	C15BF4

C15BBE:
	fmove.d #10,fp0
	;dc.w	$F23C	
	;dc.w	$5400
	;dc.w	$4024
	;dcb.w	3,0

	fdiv.x	fp0,fp1
	fmove.d	fp1,(D02F260-DT,a4)
	add	#1,(W2F254-DT,a4)
	bra.b	C15B8E

C15BDC:
	fmove.d	(D02F258-DT,a4),fp0
	fmul.x	fp0,fp1
	fmove.d	fp1,(D02F260-DT,a4)
	sub	#1,(W2F254-DT,a4)
	bra.b	C15B8E

C15BF4:
	fmove.l	fp1,d0
	bsr.b	C15C38
	movem.l	(sp)+,d0-d7/a0-a6
	rts

C15C00:
	lea	(B30053).l,a0
	lea	(ascii.MSG4).l,a1
	moveq	#$10,d0
C15C0E:
	move.b	(a1)+,(a0)+
	dbra	d0,C15C0E
	clr.b	(a0)
	movem.l	(sp)+,d0-d7/a0-a6
	rts

C15C1C:
	lea	(B30053).l,a0
	lea	(NotANumber.MSG).l,a1
	moveq	#$10,d0
C15C2A:
	move.b	(a1)+,(a0)+
	dbra	d0,C15C2A
	clr.b	(a0)
	movem.l	(sp)+,d0-d7/a0-a6
	rts

C15C38:
	lea	(L15D1C).l,a0
	lea	(B30053).l,a1
	moveq	#$20,d3
	move.b	d3,(15,a1)
	tst.b	(B3004A-DT,a4)
	beq.b	C15C52
	moveq	#$2D,d3
C15C52:
	move.b	d3,(a1)+
	moveq	#0,d3
C15C56:
	cmp.l	#1,(a0)
	beq.b	C15C7E
	move.l	(a0)+,d1
	moveq	#0,d2
C15C62:
	sub.l	d1,d0
	bmi.b	C15C6A
	addq.w	#1,d2
	bra.b	C15C62

C15C6A:
	add.l	d1,d0
	move.b	d2,(a1)
	add.b	#$30,(a1)+
	tst	d3
	bne.b	C15C7C
	move.b	#$2E,(a1)+
	moveq	#1,d3
C15C7C:
	bra.b	C15C56

C15C7E:
	move.b	d0,(a1)
	add.b	#$30,(a1)+
	moveq	#$20,d1
	tst.b	(B3004B-DT,a4)
	beq.b	C15C90
	move.b	#$BB,d1
C15C90:
	tst.b	(B3004C-DT,a4)
	beq.b	C15CA0
	cmp.b	#$20,d1
	bne.b	C15CA0
	move.b	#$B1,d1
C15CA0:
	move.b	d1,(a1)+
	move.b	#$45,(a1)+
	moveq	#$20,d1
	tst	(W2F254-DT,a4)
	bpl.b	C15CB4
	moveq	#$2D,d1
	neg.w	(W2F254-DT,a4)
C15CB4:
	move.b	d1,(a1)+
	moveq	#0,d0
	move	(W2F254-DT,a4),d0
	moveq	#0,d1
	move	d0,d1
	divu	#$0064,d1
	tst.b	d1
	beq.b	C15CD4
	move.b	d1,(a1)
	add.b	#$30,(a1)+
	mulu	#$0064,d1
	sub	d1,d0
C15CD4:
	moveq	#0,d1
	move	d0,d1
	divu	#10,d1
	tst.b	d1
	beq.b	C15CEC
	move.b	d1,(a1)
	add.b	#$30,(a1)+
	mulu	#10,d1
	sub	d1,d0
C15CEC:
	move.b	d0,(a1)
	add.b	#$30,(a1)+
	cmp	#$0063,(W2F254-DT,a4)
	ble.b	C15D02
	move.b	#$B1,(E0.MSG).l
C15D02:
	cmp	#10,(W2F254-DT,a4)
	bge.b	C15D12
	move.b	#$20,(B15D4F).l
C15D12:
	move.b	#0,(B15D50).l
	rts

L15D1C:
	dc.l	100000000
	dc.l	10000000
	dc.l	1000000
	dc.l	100000
	dc.l	10000
	dc.l	1000
	dc.l	100
	dc.l	10
	dc.l	1
ascii.MSG4:
	dc.b	' 0.00000000'
E0.MSG:
	dc.b	' E 0'
B15D4F:
	dc.b	$20
B15D50:
	dc.b	0
NotANumber.MSG:
	dc.b	'- Not a Number -',0		; ***
Erroropeningr.MSG:
	dc.b	'Error opening requested screenmode. Switching back ' ; ***
	dc.b	'to PAL 640*256',0
HChangedstand.MSG:
	dc.b	$9B
	dc.b	'13HChanged standard directory to » ',0
	dc.b	$FF
	dc.b	$9B
	dc.b	'1HLine : $  00',0,0
ascii.MSG:
	dc.b	12
	dcb.b	2,10
	dc.b	$9B
HAsmProV128MC.MSG:
	dc.b	'0'


AsmPro_titletxt.MSG:
	dc.b	'Asm-Pro OS '
	version
	IFNE	subversion-' '
	dc.b	subversion
	ENDIF
;	dc.b	'V1.01'
	dc.b	' By Genetic Source '
SourceNrInBalk:
	dc.b	'0 »'
MenuFileName:	dcb.b	31,0

HInclude.MSG:	dc.b	$9B,'1H','Include : "',0,'"',0
HIncbin.MSG:	dc.b	$9B,'1H','Incbin  : "',0,'"',0
HInciff.MSG:	dc.b	$9B,'1H','Inciff  : "',0,'"',0
HInclink.MSG:	dc.b	$9B,'1H','Inclink : "',0,'"',0

H.MSG:			dc.b	$9B
			dc.b	'52H =',0
Filelength.MSG:		dc.b	'File length = ',0
ascii.MSG87:		dc.b	' (=$',0
Filelocation.MSG:	dc.b	'File location = ',0
Name.MSG:		dc.b	'Name : ',0
BytesFree.MSG:		dc.b	' Bytes Free',0
BytesUsed.MSG:		dc.b	' Bytes Used',$A,0
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
SREGSDATAfile.MSG:	dc.b	'REGSDATA file not found, aborting',$A,0
Notenoughmemo.MSG:	dc.b	'Not enough memory to load Asmpro:REGSDATA, aborting',$A,0
			dc.b	'Could not load IFF file',$A,0
Errorcreating.MSG:	dc.b	'Error creating directory',$A,0
Directorycrea.MSG:	dc.b	'Directory created',$A,0
Sinuscreated.MSG:	dc.b	'Sinus created.',$A,0
Couldntopenma.MSG:	dc.b	'Couldn''t open mathffp.library',$A,0
Couldntopenma.MSG0:	dc.b	'Couldn''t open mathtrans.library',$A,0
MathffpName:		dc.b	'mathffp.library',0
MathtransName:		dc.b	'mathtrans.library',0
Sourcenotsave.MSG:	dc.b	'Source not saved ! Continue ?',0	; ***
Filealreadyex.MSG:	dc.b	'File already exists ! Continue ?',0	; ***
ExitorRestart.MSG:	dc.b	'Exit or Restart (Y/N or R)?',0
			dc.b	' ON',0
			dc.b	'OFF',0
			dc.b	'EOP     ',$A,0
EOP.MSG:		dc.b	'EOP     ',0
Removeunusedl.MSG:	dc.b	'Remove unused labels (Y/N) ?',0	; ***
Updating.MSG:		dc.b	'Updating .. ',0
Sourcenotchan.MSG:	dc.b	'Source not changed. No update needed !',$A,0 ; ***
Sortingreloar.MSG:	dc.b	'Sorting relo-area..',$A,0
Writinghunkda.MSG:	dc.b	'Writing hunk data..',$A,0
Writinghunkle.MSG:	dc.b	'Writing hunk length..',$A,0
			dc.b	'Memory overflow !',0			; ***
			dc.b	'NL ',0
			dc.b	'-- ',0
			dc.b	'L7 ',0
			dc.b	'-- ',0
			dc.b	'RS',0
			dc.b	'--',0
			dc.b	'Mode : ',0
Reqtoolslibra.MSG0:	dc.b	'Reqtools.library not found !',$A,0	; ***
Reqtoolslibra.MSG:	dc.b	'Reqtools.library disabled due to no free chip mem !',$A,0 ; ***
Notenoughwork.MSG:	dc.b	'Not enough workmem for source !',$A,0	; ***
Break.MSG:		dc.b	10,'** Break    ',$A,0
HPass1.MSG:		dc.b	$9B,'1HPass 1..      ',$A,0
HPass2.MSG:		dc.b	$9B,'1HPass 2..      ',$A,0
Page.MSG:		dc.b	'Page',0
Of.MSG:			dc.b	'  Of ',0
HNoErrors.MSG:		dc.b	$9B,'1HNo errors     ',$A,0	; ***
HErrorsOccure.MSG:	dc.b	$9B,'1HErrors occured !',$A,0	; ***
HSourcechecke.MSG:	dc.b	$9B,'1HSource checked',$A,0
Zap.MSG:		dc.b	'<Zap> ',0
HReAssembling.MSG:	dc.b	$9B,'1HReAssembling.. ',$A,0
OptionOOptimi.MSG:	dc.b	'Option O:  Optimizing..',$A,0
NOT.MSG:		dc.b	'NOT '
EqualAreas.MSG:		dc.b	'Equal areas',0			; ***
			dc.b	'** Warning: ',0
Not.MSG:		dc.b	'Not '
Found.MSG:		dc.b	'Found',0
BranchForcedt.MSG:	dc.b	'Branch forced to word size',0	; ***
BranchForcedt.MSG0:	dc.b	'Branch forced to long size',0	; ***
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
			dc.b	'FP0: ',0,$A
			dc.b	'FP4: ',0
D0.MSG:			dc.b	'D0: ',0,$A
			dc.b	'A0: ',0,$A
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
			dc.b	$9B
			dc.b	'21;69HPC =',0
			dc.b	$9B
			dc.b	'22;69HVBR=',0
			dc.b	$9B
			dc.b	'23;68HFPSR=',0
StartEndTotal.MSG:	dc.b	'                  Start    End           Total',$A
			dc.b	'                  -------- --------   --------',$A
			dc.b	'Workspace       : ',0
			dc.b	'Source          : ',0
			dc.b	'Label pointers  : ',0		; ***
			dc.b	'Label           : ',0
			dc.b	'Debug           : ',0
			dc.b	'Code            : ',0
			dc.b	'Reloc           : ',0
			dc.b	'IncMem          : -------- -------- ',0
AsmProLOCATIO.MSG:	dc.b	'Asm-Pro LOCATION  Start    End           Total',$A
			dc.b	'                  -------- --------   --------',$A
			dc.b	'1st Code section: ',0
			dc.b	'2nd Code section: ',0
			dc.b	'1st Data section: ',0
			dc.b	'2nd Data section: ',0
			dc.b	'BSS Data section: ',0
Memorydirecto.MSG:	dc.b	'--- Memory directory ---',$A,0
			dc.b	'-- Symbol table --',$A,0
st_macro:		dc.b	'-- Macro --',0
st_xref:		dc.b	'-- X-Ref --',0
st_equr:		dc.b	'-- Equ-R --',0
st_reg:			dc.b	'--  Reg  --',0

status_line_txt:	dc.b	$9B
infopos1:		dc.b	$30
infopos2:		dc.b	$32
infopos3:		dc.b	$33
			dc.b	$3B
			dc.b	$31
			dc.b	$48
			dc.b	0

neColBytesFre.MSG = *+2
;	dc.b	$4C
;	dc.b	$69
	dc.b	'  Line          Col      Bytes           Free           '
	dc.b	'     ----',0


TimeString:
	dc.b	'  :  :  ',0,0,0,0,0,0,0,0	;16 bytes for date2str

BytesWordsLon.MSG:
	dc.b	'Bytes     Words     Longwords '

art.MSG = *+2
	dc.b	' Start: '
xxxxxxxxEnd.MSG:
	dc.b	'$xxxxxxxx End: '
xxxxxxxxSize.MSG:
	dc.b	'$xxxxxxxx Size: '
LongwordsTime.MSG:
	dc.b	'Longwords Pos: '
Monitor_Pos:					; ***
	dc.b	'$xxxxxxxx'			; ***
	dc.b	'        ',0,0,0,0,0,0

End_msg:
	dc.b	$9B
EndPos1:
	dc.b	'0'
EndPos2:
	dc.b	'3'
EndPos3:
	dc.b	'0;1H'
	dc.b	0
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
	dc.b	' Error : ',0
Steps.MSG:
	dc.b	' Steps: ',0
Address.MSG:
	dc.b	' Address: ',0
Watch.MSG:
	dc.b	' Watch: ',0
AddConditiona.MSG:
	dc.b	' Add conditional breakpoint on : ',0		; ***
Comparesonval.MSG:
	dc.b	' Compareson value/register : ',0
Conditiontype.MSG:
	dc.b	' Condition type: (0) <  (1) <=  (2) =  (3) >  (4) >='
	dc.b	'  (5) <> : ',0
Conditionbrea.MSG:
	dc.b	' Condition breakpoint reached',0
	dc.b	' Mode NOT allowed in conditional breakpoint ',0
Addressnotfou.MSG:
	dc.b	' Address not found !!',0
Endofprogramr.MSG:
	dc.b	' End of program reached !!',0
WatchtypeAsci.MSG:
	dc.b	' Watch type (A)scii (S)tring (H)ex (D)ecimal (B)inar'
	dc.b	'y (P)ointer: ',0
PointertoAsci.MSG:
	dc.b	' Pointer to (A)scii (S)tring (H)ex (D)ecimal (B)inar'
	dc.b	'y: ',0
Pointertype1D.MSG:
	dc.b	' Pointer type (1) DC.L (2) DC.W (3) DR.L (4) DR.W : '
	dc.b	0
Register.MSG0:
	dc.b	' Register: ',0
ReplaceYNLG.MSG:
	dc.b	' Replace (Y/N/L/G)?',0
Jumping.MSG:
	dc.b	' Jumping.. ',0
BufferFull.MSG:
	dc.b	' Buffer full !',0		; ***
Done.MSG:
	dc.b	'Done',0
UncommentDone.MSG:
	dc.b	' Uncomment done',0		; ***
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
	dc.b	' Macro buffer full !!',0
	dc.b	'EXTERN'
	dc.b	$80
MAINDATA:
	dc.b	';;',0
consoledevice.MSG:
	dc.b	'console.device',0,0
trackdiskdevi.MSG:
	dc.b	'trackdisk.device',0
TimerName:
	dc.b	'timer.device',0
AsmProV128.MSG:
	dc.b	'Asm-Pro '
	version
;	dc.b	'V1.01'
	dc.b	0
ExternalLevel.MSG:
	dc.b	10
	dc.b	'** External level 7 break **',0	; ***
BusError.MSG:
	dc.b	10
	dc.b	'** Bus error **',0			; ***
AddressError.MSG:
	dc.b	10
	dc.b	'** Address error **',0			; ***
IllegalInstru.MSG:
	dc.b	10
	dc.b	'** Illegal instruction **',0		; ***
DivisionByZer.MSG:
	dc.b	10
	dc.b	'** Division by zero **',0		; ***
CHKexception.MSG:
	dc.b	10
	dc.b	'** CHK exception **',0
TRAPV.MSG:
	dc.b	10
	dc.b	'** TRAPV **',0
PrivilegeViol.MSG:
	dc.b	10
	dc.b	'** Privilege violation **',0		; ***
TraceTrap.MSG:
	dc.b	10
	dc.b	'** Trace trap **',0			; ***
LineAEmulator.MSG:
	dc.b	10
	dc.b	'** LineA emulator **',0		; ***
LineFEmulator.MSG:
	dc.b	10
	dc.b	'** LineF emulator **',0		; ***
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
	dc.b	' Instruction $',0,0

	cnop	0,4
AllocMem1Kb:
	move.l	#$00000400,d0
	moveq	#2,d1
	move.l	(4).w,a6
	jsr	(_LVOAllocMem,a6)
	move.l	d0,(C16EC6).l
	bne.b	C16EC2
	jmp	(ERROR_WorkspaceMemoryFull).l

C16EC2:
	rts

C16EC6:	dc.l	0	;equ	*-4

C16EC4:
	move.l	C16EC6(pc),a1
	move.l	#$00000400,d0
	move.l	(4).w,a6
	jmp	(_LVOFreeMem,a6)

C16EDA:
	bsr.b	C16F26
	bsr.b	AllocMem1Kb
	move.l	d0,(TRACK_BUFFER-DT,a4)
	move.l	#$00000400,(TRACK_LENGTH-DT,a4)
	clr.l	(TRACK_POINTER-DT,a4)
	move	#2,(TRACK_COMMAND-DT,a4)
	bsr	C17114
	move.l	(TRACK_BUFFER-DT,a4),a0
	move.l	a0,a1
	clr.l	(4,a0)
	moveq	#-1,d0
	move	#$00FF,d1
	moveq	#0,d2
C16F0A:
	sub.l	(a0)+,d0
	subx.l	d2,d0
	dbra	d1,C16F0A
	move.l	d0,(4,a1)
	move	#3,(TRACK_COMMAND-DT,a4)
	bsr	C17114
	bsr	C17186
	bra.b	C16EC4

W16F36:	dc.w	0

C16F26:
	addq.l	#1,a6
	bsr	Convert_A2I
	cmp.b	#$61,d1
	beq.b	Open_trackdiskdev
	moveq	#0,d0
	move	W16F36,d0
;	move	#0,d0
;W16F36:	equ	*-2		;!?!?!?@$#

Open_trackdiskdev:
	move	d0,(W16F36).l
	lea	(trackdiskdevi.MSG,pc),a0
	moveq	#0,d1
	lea	(DATA_WRITEREQUEST2-DT,a4),a1
	move.l	#DATA_REPLYPORT,(14,a1)
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
	movem.l	d0-d7/a0-a6,-(sp)

	move.l	(DosBase-DT,a4),a6
	move.l	#datestamp,d1
	jsr	(_LVODateStamp,a6)		; ***
	
	move.l	#TimeString,timestr
	move.l	#datetime,d1
	jsr	(_LVODateToStr,a6)	; ***

	movem.l	(sp)+,d0-d7/a0-a6
	rts


datetime:
datestamp:
	dc.l	0
	dc.l	0
	dc.l	0
dateformat:
	dc.b	0	;format
	dc.b	0	;flags
	dc.l	0	;day
datestr:
	dc.l	DateString	;date
timestr:
	dc.l	TimeString	;time

DateString:
	dc.b	"--/---/--",0
	dcb.b	6,0


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
	bsr	C170CA
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
	move.l	d0,d1
	lsl.l	#3,d0
	add.l	d1,d0
	add.l	d1,d0
	add.l	d1,d0
	move.l	d0,(TRACK_POINTER-DT,a4)
	move.l	(TRACK_LENGTH-DT,a4),d0
	move.l	d0,d1
	lsl.l	#3,d0
	add.l	d1,d0
	add.l	d1,d0
	add.l	d1,d0
	move.l	d0,(TRACK_LENGTH-DT,a4)
	bsr	C17114
	br	C17186

Com_ReadTrack:
	bsr	C16F26
	move	#2,(TRACK_COMMAND-DT,a4)
	bsr.b	C170CA
	move.l	(TRACK_POINTER-DT,a4),d0
	move.l	d0,d1
	lsl.l	#3,d0
	add.l	d1,d0
	add.l	d1,d0
	add.l	d1,d0
	move.l	d0,(TRACK_POINTER-DT,a4)
	move.l	(TRACK_LENGTH-DT,a4),d0
	move.l	d0,d1
	lsl.l	#3,d0
	add.l	d1,d0
	add.l	d1,d0
	add.l	d1,d0
	move.l	d0,(TRACK_LENGTH-DT,a4)
	bsr.b	C17114
	br	C17186

C170CA:
	lea	(RAMPTR.MSG,pc),a0
	bsr	Druk_MsgAf_GetNumbr
	beq.b	C170DA
	jmp	(ERROR_Notdone).l

C170DA:
	move.l	d0,(TRACK_BUFFER-DT,a4)
	move.l	d0,(MEM_DIS_DUMP_PTR-DT,a4)
	lea	(DISKPTR.MSG,pc),a0
	bsr	Druk_MsgAf_GetNumbr
	beq.b	C170F2
	jmp	(ERROR_Notdone).l

C170F2:
	lsl.l	#8,d0
	lsl.l	#1,d0
	move.l	d0,(TRACK_POINTER-DT,a4)
	lea	(LENGTH.MSG,pc),a0
	bsr	Druk_MsgAf_GetNumbr
	beq.b	C1710A
	jmp	(ERROR_Notdone).l

C1710A:
	lsl.l	#8,d0
	lsl.l	#1,d0
	move.l	d0,(TRACK_LENGTH-DT,a4)
	rts

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
	jsr	(_LVODoIO,a6)			; ***
	tst.l	($0020,a1)
	beq.b	C17152
	jmp	(ERROR_WriteProtected).l

C17152:
	move	(TRACK_COMMAND-DT,a4),($001C,a1)
	move.l	(TRACK_LENGTH-DT,a4),($0024,a1)
	move.l	(TRACK_BUFFER-DT,a4),($0028,a1)
	move.l	(TRACK_POINTER-DT,a4),($002C,a1)
	jsr	(_LVODoIO,a6)			; ***
	move	#4,($001C,a1)
	jsr	(_LVODoIO,a6)			; ***
	move	#9,($001C,a1)
	clr.l	($0024,a1)
	jmp	(_LVODoIO,a6)			; ***

C17186:
	lea	(DATA_WRITEREQUEST2-DT,a4),a1
	jmp	(_LVOCloseDevice,a6)		; ***

;****************************************************************
;*	  THIS AREA CONTAINS ALL INCLUDE FILES ROUTINES		*
;****************************************************************

INCLUDE_POINTER:
	bsr	MenNemeNaamEnPad
	lea	(FIRST_INCLUDE_PTR-DT,a4),a2
.loop1:
	move.l	(a2),d0
	beq.b	.NOT_FOUND_LOAD
	move.l	d0,a2
	move.l	d0,a1
	addq.w	#8,a1
	lea	(CurrentAsmLine-DT,a4),a0
.loop2:
	move.b	(a1)+,d0
	beq.b	.einde
	cmp.b	(a0)+,d0
	beq.b	.loop2
	bra.b	.loop1

.einde:
	tst.b	(a0)+
	bne.b	.loop1
	move.l	a2,(SOLO_CurrentIncPtr-DT,a4)
	move.l	a1,a2
	rts

.NOT_FOUND_LOAD:
	tst	d7	;passone
	bmi.b	Druk_Includefiles
	jmp	(ERROR_IncludeJam).l

Druk_Includefiles:
	lea	HInclude.MSG,a0
	jsr	PRINTINCLUDENAME		; Include : "DH1:ASMPRO/INCLUDE/devices/keymap.i       "

	bsr	GetDiskFileLengte	; =     14926 (=$00003A4E )
	bsr	IncludeAllocMem

	movem.l	d0/a2,-(sp)
	clr.l	(FileLength-DT,a4)
	bsr	OpenOldFile
	clr	(Marksinsource-DT,a4)
	bsr	SaveMarksOpnieuwIstalleren
	lea	(ParameterBlok-DT,a4),a2
	cmp.l	#$F9FAF9FA,(a2)
	bne.b	.nosavemarks
	sub.l	#44,(sp)
.nosavemarks:
	cmp.l	#";APS",(a2)
	bne.b	.nosavemarksnew
	sub.l	#85,(sp)
.nosavemarksnew:

	movem.l	(sp),d0/a2
	move.l	d0,d3
	move.l	a2,d2
	bsr	read_nr_d3_bytes
	movem.l	(sp),d0/a2
	clr.b	(a2,d0.l)
	move.b	#$1A,(1,a2,d0.l)
	cmp.l	(FileLength-DT,a4),d0
	beq.b	.noerr
	jmp	(ERROR_FileError).l

.noerr:
	moveq	#10,d1
	moveq	#$1A-13,d2
	bra.b	.loop2

.store:
	move.b	d0,(-1,a2)
.loop2:
	move.b	(a2)+,d0
	sub.b	d1,d0
	beq.b	.store
	subq.b	#3,d0
	beq.b	.store
	sub.b	d2,d0
	bne.b	.loop2
	move.l	d7,-(sp)
	moveq.l	#-1,d7
	bsr	close_bestand
	move.l	(sp)+,d7
	movem.l	(sp)+,d0/a2
	rts

;*   JOIN_INCDIR_INCNAME_TO_INPUTBUFFER    *

MenNemeNaamEnPad:
	lea	(CurrentAsmLine-DT,a4),a0
	lea	(INCLUDE_DIRECTORY-DT,a4),a1
	lea	(SourceCode-DT,a4),a3
.lopje1:
	move.b	(a1)+,(a0)+
	bne.b	.lopje1
	subq.w	#1,a0
.lopje2:
	move.b	(a3)+,(a0)+
	bne.b	.lopje2
	rts

;*   DISK_LENGTH_OF_FILE   *

GetDiskFileLengte:
	lea	(CurrentAsmLine-DT,a4),a0
	clr	(W2DF84-DT,a4)
	move.l	a0,a6
	moveq	#0,d1
C17270:
	tst.b	(a6)
	beq.b	C17282
	cmp.b	#$3A,(a6)
	beq.b	C1727E
C1727A:
	addq.l	#1,a6
	bra.b	C17270

C1727E:
	addq.w	#1,d1
	bra.b	C1727A

C17282:
	cmp	#1,d1
	bgt.b	C17298
	move.l	a0,d1
	moveq	#-2,d2
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOLock,a6)
	tst.l	d0
	bne.b	C172AE
C17298:
	move	#1,(W2DF84-DT,a4)
	lea	(SourceCode-DT,a4),a0
	move.l	a0,d1
	moveq	#-2,d2
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOLock,a6)
C172AE:
	move.l	d0,-(sp)
	bne.b	C172B8
	jmp	(ERROR_FileError).l

C172B8:
	move.l	d0,d1
	lea	(ParameterBlok-DT,a4),a0
	move.l	a0,d2
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOExamine,a6)
	tst.l	d0
	bne.b	C172D2
	jmp	(ERROR_FileError).l

C172D2:
	tst.l	(L2BFC4-DT,a4)
	bmi.w	C172E0
	jmp	(ERROR_IllegalPath).l

C172E0:
	move.l	(sp)+,d1
	jsr	(_LVOUnLock,a6)			; ***
	move.l	(incFileLength-DT,a4),d0
	rts

;*   INCLUDE_ALLOCATE_MEM   *

; D0 = Length
; A5 = Pointer
; Struct Include:
;	NextPtr
;	Length
;	Name
;	Include_File

IncludeAllocMem:
	move.l	d0,-(sp)
	lea	(CurrentAsmLine-DT,a4),a0
	moveq	#12,d1
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
	move.l	d0,a2
	clr.l	(a2)+
	move.l	d1,(a2)+

	lea	(CurrentAsmLine-DT,a4),a0
.lopje3:
	move.b	(a0)+,(a2)+
	bne.b	.lopje3
	move.l	(sp)+,d0
	rts

;*   Deallocate all includes   *

ZapIncludes:
	clr.l	(INCLUDE_CONSUMPTION-DT,a4)
	lea	(FIRST_INCLUDE_PTR-DT,a4),a2
	move.l	(a2),d2
	clr.l	(a2)
.lopje:
	tst.l	d2
	beq.b	.klaar
	move.l	d2,a2
	move.l	(4,a2),d0
	move.l	a2,a1
	move.l	(a2),d2
	move.l	(4).w,a6
	jsr	(_LVOFreeMem,a6)
	bra.b	.lopje

.klaar:
	rts


;;********** IN THIS AREA ALL KEYBOARD ROUTINES ARE PLACED ************

Get_me_a_char:
	clr	d0
	bsr	Druk_char_af2
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

	clr.b	(Safety-DT,a4)		;voor auto stuff

	movem.l	d1-d7/a0-a3/a5/a6,-(sp)
	bsr	GetAnyChar
	movem.l	(sp)+,d1-d7/a0-a3/a5/a6
	tst.b	(markblockset).l
;	beq	GetKey
	beq	.NextKeyPlease
	clr.b	(markblockset).l

	lea	($FFFFFFFF).l,a0
	cmp.l	a0,a6
	bne.b	.unmarkblock		; ***
	move.l	a2,a6
	bra.b	.NextKeyPlease

.unmarkblock:
	move.l	a0,a6
	jsr	(RegTab_SETALLNOTUPD).l
.NextKeyPlease:

	tst.w	PR_WaitTOF
	beq.s	.nowaitof
	move.l	a6,-(sp)
;	move.l	(DosBase-DT,a4),a6
;	moveq.l	#1,d1
;	jsr	_LVODelay(a6)
	move.l	(GfxBase-DT,a4),a6
	jsr	_LVOWaitBlit(a6)
	jsr	_LVOWaitTOF(a6)		;delay befor getting next key..
;	jsr	_LVOWaitTOF(a6)		;delay befor getting next key..
	move.l	(sp)+,a6
.nowaitof:

	bra.b	GetKey

GetKey_StillKeysInBuf:
	cmp	(KEYB_KILLPTR-DT,a4),d0
	bne.b	.cont
	addq.b	#1,(KEYB_KILLPTRByte-DT,a4)
.cont:
	addq.b	#1,(KeyboardInBufByte-DT,a4)
	lea	(OwnKeyBuffer-DT,a4),a0
	move.b	(a0,d0.w),d0
	rts

;*   KILL BUFFER   *

new2old_stuff:
	move	(KEYB_KILLPTR-DT,a4),(KeyboardOutBuf-DT,a4)
	rts

;*    ASK FOR CHAR    *

messages_get:
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
	move	(KeyboardInBuf-DT,a4),d0
	sub	(KeyboardOutBuf-DT,a4),d0
	movem.l	(sp)+,d1/a0/a1/a6
	tst	d0
	rts

KEY_RETURN_LAST_KEY:
	move.b	#$80,d0
	bsr.b	KEYBUFFERPUTCHAR
	move.b	(edit_EscCode-DT,a4),d0
	bra.b	KEYBUFFERPUTCHAR

C17412:
	move	d0,-(sp)
	move.b	#$80,d0
	bsr.b	KEYBUFFERPUTCHAR
	move	(sp)+,d0
	br	KEYBUFFERPUTCHAR

KEYBUFFERPUTCHAR:
	lea	(OwnKeyBuffer-DT,a4),a0
	add	(KeyboardOutBuf-DT,a4),a0
	move.b	d0,(a0)
	addq.b	#1,(KeyboardOutBufByte-DT,a4)
	rts

PlaceCursorByMouseclick:
	move.l	(MainWindowHandle-DT,a4),a5
	moveq.l	#0,d2
	move	(12,a5),d2		;mouse Y
	sub	(Scr_Title_size-DT,a4),d2	; - 11 voor de menubalk
	bpl.b	C17442
	moveq	#0,d2
C17442:
	divu.w	(EFontSize_y-DT,a4),d2

	move	(NrOfLinesInEditor-DT,a4),d1
	subq.w	#1,d1
	cmp	d1,d2
	bls.b	C1744E
	move	d1,d2
C1744E:
	moveq.l	#0,d0
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
	beq.w	.handle_debug_msgs

	move.l	d0,a3
	move.l	44(a3),a3
	cmp.l	Plugs_winbase,a3
	bne.s	.handle_debug_msgs

	jsr	Plugs_check_plugsmsg

	bra.b	NoMsgInBase
	ENDIF
	
.handle_debug_msgs:
	tst.l	debug_winbase		;handle debug win msg's
	beq.w	handle_main_msgs

	move.l	d0,a3
	move.l	44(a3),a3	;windowptr
	cmp.l	debug_winbase,a3
	bne.s	handle_main_msgs

	jsr	Debug_check_msg
	tst.l	debug_winbase		;handle debug win msg's
	beq.w	handle_main_msgs

	bra.w	nomore_mgs


handle_main_msgs:			;handle normal msg's
	move.l	d0,a3
	move.l	(20,a3),d3	;msg
	move.l	d3,d1
	and.l	#8,d1		;mouse
	bne	check_mouse
	move.l	d3,d1
	and.l	#IDCMP_MENUPICK,d1	;menu
	bne	check_menus
	move.l	d3,d1
	and.l	#$400,d1	;rawkey
	beq	nomore_mgs
;check_keys:
	move	(24,a3),d4	;code
	btst	#7,d4		;special key (alt,ctrl,shift..)
	bne	nomore_mgs
	move	($001A,a3),d5	;
	move.l	($001C,a3),a0	;
	move.l	(a0),d6
	move	d4,(IECODE-DT,a4)
	move	d5,(IEQUAL-DT,a4)
	move.l	d6,(IEADDR-DT,a4)
	move	d5,d1
	and	#8,d1
	bne	C17632
C17516:
	cmp	#$0040,d4
	bls.b	C17524
	cmp	#$004A,d4
	bne	RawKeyDecode
C17524:
	btst	#0,(PR_NumLock).l
	beq.b	key_CONV
	btst	#SB3_EDITORMODE,(SomeBits3-DT,a4)	;editor
	beq.b	key_CONV
	cmp	#$003D,d4		;key codes...
	beq	C17876
	cmp	#$003E,d4
	beq	key_UP
	cmp	#$003F,d4
	beq	key_SHIFT_UP
	cmp	#$002D,d4
	beq	key_RIGHT
	cmp	#$002E,d4
	beq	C17882
	cmp	#$002F,d4
	beq	key_LEFT
	cmp	#$001D,d4
	beq	C1787C
	cmp	#$001E,d4
	beq	key_DOWN
	cmp	#$001F,d4
	beq	key_SHIFT_DOWN
key_CONV:
	lea	(MY_EVENT-DT,a4),a0
	lea	(KEY_BUFFER-DT,a4),a1
	moveq	#$50,d1
	sub.l	a2,a2
	move.l	(CONSOLEDEVICE-DT,a4),a6
	jsr	(_LVORawKeyConvert,a6)		; ***
	subq.l	#1,d0
	tst.l	d0
	bpl.b	key_NoZero
	br	nomore_mgs

key_NoZero:
	lea	(KEY_BUFFER-DT,a4),a1
	move.b	(a1),d1
	cmp.b	#$9B,d1
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
	btst	#SB3_EDITORMODE,(SomeBits3-DT,a4)	;editor
	beq	nomore_mgs
	move	($0018,a3),d1
	cmp.b	#$68,d1
	beq.b	OokIetsMetXY
	cmp.b	#$E8,d1
	beq.b	C175E2
	br	nomore_mgs

C175E2:
	bclr	#SB1_MOUSE_KLIK,(SomeBits-DT,a4)
	br	nomore_mgs

OokIetsMetXY:
	bset	#SB1_MOUSE_KLIK,(SomeBits-DT,a4)
	movem.l	d0/d1/a5,-(sp)
	cmp.b	#MT_EDITOR,(menu_tiepe-DT,a4)
	bne.b	C17622
	move.l	(MainWindowHandle-DT,a4),a5
	move	(12,a5),d0		;mouse Y
	asr.w	#3,d0			;nr regels Y
	move	(14,a5),d1		;mouse X
	asr.w	#3,d1			;nr cols X
	cmp	(NieuwMouseX-DT,a4),d0	;X
	bne.b	C17622
	cmp	(NieuwMouseY-DT,a4),d1	;Y
	bne.b	C17622
	move.b	#1,(markblockset).l
C17622:
	move	d0,(NieuwMouseX-DT,a4)	;X
	move	d1,(NieuwMouseY-DT,a4)	;Y
	movem.l	(sp)+,d0/d1/a5
	br	nomore_mgs

C17632:
	cmp.b	#$40,d4
	bcc.w	C17516
	lea	(L1765A,pc),a0
	ext.w	d4
	and	#3,d5
	beq.b	C1764A
	add	#$0040,a0
C1764A:
	move.b	(a0,d4.w),d0
	cmp.b	(B2BEB8-DT,a4),d0
	beq	C17A62
	br	SentEscKey

L1765A:
	dc.l	$00474849
	dcb.l	3,0
	dc.l	$23291724
	dc.l	$262B271B
	dc.l	$21220000
	dc.l	0
	dc.l	$13251618
	dc.l	$191A1C1D
	dc.l	$1E000000
	dc.l	0
	dc.l	$002C2A15
	dc.l	$2814201F
	dc.l	$53000000
	dc.l	0
	dc.l	$004F5051
	dcb.l	3,0
	dc.l	$3D43313E
	dc.l	$40454135
	dc.l	$3B3C0000
	dc.l	0
	dc.l	$2D3F3032
	dc.l	$33343637
	dc.l	$38000000
	dc.l	0
	dc.l	$0046442F
	dc.l	$422E3A39
	dcb.l	2,0

SentEscKey:
	lea	(KEY_BUFFER-DT,a4),a0
	move.l	a0,a1
	move.b	#$80,(a0)+
	move.b	d0,(a0)+
	moveq	#1,d0
	br	key_GoAnyway

RawKeyDecode:
	cmp	#$005F,d4	;help key
	beq	TheHelpKey
	and	#$00FB,d5	;ANYQUALIFIER
	beq.b	key_NORMAL
	move	d5,d1
	and	#8,d1		;CTRLKEY
	bne	key_CTRL
key_NOCTRL:
	move	d5,d1
	and	#3,d1		;SHIFTKEYS
	bne.b	key_SHIFT
	move	d5,d1
	and	#$0030,d1	;ALTKEYS
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
	beq	C17876
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

C17876:
	moveq	#$26,d0
	br	SentEscKey

C1787C:
	moveq	#$40,d0
	br	SentEscKey

C17882:
	moveq	#13,d0
	br	SentEscKey

C17888:
	moveq	#$40,d0
	br	SentEscKey

TheHelpKey:
	moveq	#$65,d0		;amiguide
	br	SentEscKey
;
key_F1:
	cmp.b	#0,(CurrentSource-DT,a4)
	beq	key_NoSourceChange
	move.b	#0,(Change2Source-DT,a4)
	br	key_Change2Source

key_F2:
	cmp.b	#1,(CurrentSource-DT,a4)
	beq	key_NoSourceChange
	move.b	#1,(Change2Source-DT,a4)
	br	key_Change2Source

key_F3:
	cmp.b	#2,(CurrentSource-DT,a4)
	beq	key_NoSourceChange
	move.b	#2,(Change2Source-DT,a4)
	br	key_Change2Source

key_F4:
	cmp.b	#3,(CurrentSource-DT,a4)
	beq	key_NoSourceChange
	move.b	#3,(Change2Source-DT,a4)
	br	key_Change2Source

key_F5:
	cmp.b	#4,(CurrentSource-DT,a4)
	beq	key_NoSourceChange
	move.b	#4,(Change2Source-DT,a4)
	bra.b	key_Change2Source

key_F6:
	cmp.b	#5,(CurrentSource-DT,a4)
	beq	key_NoSourceChange
	move.b	#5,(Change2Source-DT,a4)
	bra.b	key_Change2Source

key_F7:
	cmp.b	#6,(CurrentSource-DT,a4)
	beq	key_NoSourceChange
	move.b	#6,(Change2Source-DT,a4)
	bra.b	key_Change2Source

key_F8:
	cmp.b	#7,(CurrentSource-DT,a4)
	beq	key_NoSourceChange
	move.b	#7,(Change2Source-DT,a4)
	bra.b	key_Change2Source

key_F9:
	cmp.b	#8,(CurrentSource-DT,a4)
	beq	key_NoSourceChange
	move.b	#8,(Change2Source-DT,a4)
	bra.b	key_Change2Source

key_F10:
	cmp.b	#9,(CurrentSource-DT,a4)
	beq	key_NoSourceChange
	move.b	#9,(Change2Source-DT,a4)
key_Change2Source:
	btst	#MB1_INCOMMANDLINE,(MyBits-DT,a4)
	beq.s	.ineditor


	move.l	(EditorRegs+[8+4]*4-DT,a4),d0
	cmp.l	a4,d0
	bne.s	.ineditor

	move.b	#1,(FromCmdLine-DT,a4)

	movem.l	d0-d7/a0-a6,-(sp)
	movem.l	(EditorRegs-DT,a4),d0-d7/a0-a6

;	jsr	test_debug

	jsr	(Go2Sourcenow).l
	movem.l	(sp)+,d0-d7/a0-a6

	move.b	#0,(FromCmdLine-DT,a4)
	bsr	RESETMENUTEXT2

;	bra.b	key_NoSourceChange

.ineditor
	moveq	#$66,d0
	br	SentEscKey

key_NoSourceChange:
	moveq	#0,d0
	br	SentEscKey

check_menus:
	move	($001A,a3),(IEQUAL-DT,a4)	;qualifier
	move	($0018,a3),d0			;menunr
	cmp	#$FFFF,d0
	beq	nomore_mgs
	lea	(KEY_BUFFER-DT,a4),a2
	bra.b	go_check_menu_item

C1797E:
	move	($0020,a3),d0
	cmp	#$FFFF,d0
	bne.b	go_check_menu_item
	move.l	a2,d0
	lea	(KEY_BUFFER-DT,a4),a1
	sub.l	a1,d0
	subq.l	#1,d0
	bmi.w	nomore_mgs
	br	key_GoAnyway

go_check_menu_item:
	move.l	(MenuStrip).l,a0
	move.l	(IntBase-DT,a4),a6
	jsr	(_LVOItemAddress,a6)
	move.l	d0,a3
	lea	($0022,a3),a0
	move.b	(a0)+,d0
	beq.b	NoNormalKey
	bmi.w	C17A08
	move.b	d0,(a2)+
	cmp.b	#$1B,d0		;ESC
	beq.b	C179C8
	move.b	(a0)+,d0
	beq.b	C179C4
	move.b	d0,(a2)+
C179C4:
	move.b	#13,(a2)+
C179C8:
	bra.b	C1797E

NoNormalKey:
	move	(IEQUAL-DT,a4),d5
	move	d5,d1
	move.b	(a0)+,d0
	beq.b	C1797E
	cmp.b	#$58,d0	
	beq.b	C17A10
	and	#$00C0,d1
	beq.b	C17A00
	cmp.b	#$13,d0
	bcs.b	C17A00
	cmp.b	#$2C,d0
	bls.b	C179F6
	cmp.b	#$46,d0
	bhi.b	C17A00
	sub.b	#$1A,d0
C179F6:
	and	#3,d5
	beq.b	C17A00
	add.b	#$1A,d0
C17A00:
	move.b	#$80,(a2)+
	move.b	d0,(a2)+
	bra.b	C179C8

C17A08:
	bset	#0,(SomeBits3-DT,a4)	;???
	bra.b	C17A00

C17A10:
	jsr	(closewb).l
	br	C1797E

nomore_mgs:
	move.l	(KEY_MSG-DT,a4),a1
	move.l	(4).w,a6
	jsr	(_LVOReplyMsg,a6)
	move.l	#0,(KEY_MSG-DT,a4)
	bclr	#0,(SomeBits3-DT,a4)	;???
	beq.b	C17A44
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(ChangeSource).l
	movem.l	(sp)+,d0-d7/a0-a6
C17A44:
	btst	#SB1_MOUSE_KLIK,(SomeBits-DT,a4)
	beq.b	C17A60
	btst	#SB3_EDITORMODE,(SomeBits3-DT,a4)	;editor
	beq.b	C17A60
	btst	#SB2_MAKEMACRO,(SomeBits2-DT,a4)
	bne.b	C17A60
	bsr	PlaceCursorByMouseclick
C17A60:
	rts

C17A62:
	move	(KeyboardOutBuf-DT,a4),(KeyboardInBuf-DT,a4)
	clr	d7
	moveq	#0,d0
	bsr	SENDONECHARNORMAL
	lea	(Break.MSG,pc),a0
	bsr	printthetext
	jmp	(CommandlineInputHandler).l

OpenDevice:
	move.l	(4).w,a6
	lea	(consoledevice.MSG,pc),a0
	lea	(IOREQ-DT,a4),a1
	moveq	#-1,d0
	moveq	#0,d1
	jsr	(_LVOOpenDevice,a6)
	tst.l	d0
	bne.b	C17AB8
	move.l	(IOREQ2-DT,a4),(CONSOLEDEVICE-DT,a4)
	move.l	(MainWindowHandle-DT,a4),a0
	move.l	($0056,a0),(KEY_PORT-DT,a4)
	rts

CloseDevice:
	lea	(IOREQ-DT,a4),a1
	move.l	(4).w,a6
	jsr	(_LVOCloseDevice,a6)
C17AB8:
	rts

com_RedirectCMD:
	bsr.b	C17AF0
	clr.l	(FileLength-DT,a4)
	moveq	#8,d0
	bsr	FileReqStuff
	bsr	IO_OpenFile
	bclr	#SB1_CLOSE_FILE,(SomeBits-DT,a4)
	move.l	(Bestand-DT,a4),(L2BD22-DT,a4)
	bset	#SB2_OUTPUTACTIVE,(SomeBits2-DT,a4)
	rts

C17ADE:
	movem.l	d0-d7/a1-a3/a5/a6,-(sp)
	move.l	(L2BD22-DT,a4),d1
	bsr	C18326
	movem.l	(sp)+,d0-d7/a1-a3/a5/a6
	rts

C17AF0:
	bclr	#SB2_OUTPUTACTIVE,(SomeBits2-DT,a4)
	move.l	(L2BD22-DT,a4),d1
	beq.b	C17B06
	clr.l	(L2BD22).l
	bsr	C183CA
C17B06:
	rts

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
	beq	COM_ReadNormal
	cmp.b	#' ',d3
	beq	com_readFileNoReq
	tst.b	(a6)
	beq.b	Com_ReadSourceReq
	jmp	(ERROR_IllegalComman).l

COM_ReadNormal:
	move.b	(CurrentSource-DT,a4),d0
	move.b	d0,(B30174-DT,a4)
	bsr	C141CE
	jsr	C141C8
	moveq	#16,d0		;#?
	bsr	FileReqStuff
	bra.b	C17B66
	
Com_ReadSourceReq:
	move.b	(CurrentSource-DT,a4),d0
	move.b	d0,(B30174-DT,a4)
	bsr	C141CE
	jsr	C141C8
	moveq	#0,d0		;source extention like .asm|.s etc..
	bsr	FileReqStuff
C17B66:
	bsr	C17CBE
	bsr	C14232
	bsr	C17C04
	bsr	OpenOldFile
	st	(Marksinsource-DT,a4)
	bsr	SaveMarksOpnieuwIstalleren
	lea.l	(CurrentAsmLine).l,a3		; -*-
	bsr.b	AddRecentFile			; -*-
	bsr	RESETMENUTEXT2
	bsr	C181F4
	bclr	#SB1_SOURCE_CHANGED,(SomeBits-DT,a4)
	bsr	C17B9E
	jmp	(C1382).l			; -*- <Just Removed a rts here>

; -*-
; --- Load a Recent file ---
; In: d0.b: Number of file in ASCII
; Out: -
ReadRecentSource:
	sub.b	#"0",d0				; Source number -*-
	and.l	#$f,d0				; -*-
	moveq	#0,d1				; -*-
	move.b	RecentFilesNbr,d1		; -*-
	subq.l	#1,d1
	cmp.l	d1,d0				; -*-
	ble.b	SourceAlreadyLoaded		; -*-
	rts					; -*-
SourceAlreadyLoaded:				; -*-
	bsr.b	GetRecentfile			; -*-
	move.b	(CurrentSource-DT,a4),d0	; -*-
	move.b	d0,(B30174-DT,a4)		; -*-
	bsr	C141CE				; -*-
	jsr	C141C8				; -*-
	jsr	C180E8				; Set name to title
	br	C17B66				; -*-

; -*-
; --- Pop a recent file from the list ---
; In: d0.l: Number of recent file
; Out: -
GetRecentfile:
	movem.l	d0/d7/a0/a1,-(a7)
	lea.l	Recent.MSG,a0
	lea.l	(CurrentAsmLine).l,a1
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
	lea.l	(a3),a0				; FileName
	lea.l	Recent.MSG,a1			; Search for same file in the list
	moveq	#0,d2
	moveq	#9-1,d7
	moveq	#0,d3				; Find flag
CheckEntries:
	bsr.w	CheckRecentFile
	tst.l	d1
	beq.b	FoundSameRecent
	addq.l	#1,d2				; Mark entry
	lea.l	146(a1),a1			; Next entry
	dbf	d7,CheckEntries
	moveq	#-1,d3
FoundSameRecent:
	tst.l	d2				; Already first file ?
	beq.w	DontMoveList
	move.w	d2,d6
	mulu.w	#146,d2
	lea	Recent.MSG,a1
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
	lea.l	-146(a0),a0
	lea.l	-146(a1),a1
	dbf	d6,DownAllRecents
	lea.l	(a3),a0				; Insert new entry
	lea.l	Recent.MSG,a1			; Beg of list
	move.w	#144-1,d7
CopyRecentFile:
	move.b	(a0)+,(a1)+
	dbeq	d7,CopyRecentFile
	sf	(a1)
	lea.l	MenuRecent,a0
	lea.l	RecentFilesNbr,a2
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
	lea	20(a0),a0			; Next menu struct
	dbf	d0,SetRecentvisible
	move.l	(Comm_menubase-DT,a4),d0	; Refresh menu strip
	jsr	(Breakdown_menu).l
	move.l	#command_menus,d0
	jsr	(Init_menustructure).l
	move.l	d0,(Comm_menubase-DT,a4)
	bsr.w	SaveRecentFiles
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
	cmp.b	#"a",d0				; -*-
	blt.b	NoUpper
	cmp.b	#"z",d0
	bgt.b	NoUpper
	bclr	#5,d0
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
	move.l	#RecentName,d1
	jsr	(_LVODeleteFile,a6)			; Delete file first
	move.l	#RecentName,d1
	move.l	#$3ee,d2
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOOpen,a6)
	move.l	d0,d1
	beq.w	NoSaveRecent
	lea.l	Recent.MSG,a1
	moveq	#0,d0
	moveq	#10-1,d7
CheckRecentNbr:
	tst.b	(a1)
	beq.b	NoRFileInLit
	addq.l	#1,d0
NoRFileInLit:
	lea.l	146(a1),a1
	dbf	d7,CheckRecentNbr
	movem.l	d1,-(a7)
	move.l	d0,-(a7)
	move.l	a7,d2
	move.l	(DosBase-DT,a4),a6		; Save number of filenames
	moveq	#4,d3				; 4 bytes
	jsr	(_LVOWrite,a6)
	addq.l	#4,a7
	movem.l	(a7)+,d1
	lea.l	Recent.MSG+(9*146),a1
	moveq	#10-1,d7
SaveAllRecFiles:
	movem.l	d1/d7/a1,-(a7)
	lea.l	(a1),a2				; Check for name's length
	move.l	a1,d2
	moveq	#-1,d3
CheckRFEnd:
	addq.l	#1,d3
	tst.b	(a2)+
	bne.b	CheckRFEnd
	tst.l	d3				; Skip empty files
	beq.b	NoSaveRecFile
	movem.l	d1-d3,-(a7)
	move.l	a7,d2				; Length in stack
	addq.l	#8,d2
	move.l	(DosBase-DT,a4),a6		; Save filename length
	moveq	#4,d3
	jsr	(_LVOWrite,a6)
	movem.l	(a7)+,d1-d3			; (I can't remember if dos saves this) so
	move.l	d1,-(a7)
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOWrite,a6)
	move.l	(a7)+,d1
NoSaveRecFile:
	movem.l	(a7)+,d1/d7/a1
	lea.l	-146(a1),a1			; Save all names
	dbf	d7,SaveAllRecFiles
	move.l	(DosBase-DT,a4),a6		; d1 is already loaded
	jsr	(_LVOClose,a6)
NoSaveRecent:
	movem.l	(a7)+,d0-a6
	rts

; -*-
; --- Load Recent files list (ENVARC:Asm-Pro.Rcnt) ---
; In: -
; Out: -
LoadRecentFiles:
	movem.l	d0-a6,-(a7)
	move.l	#RecentName,d1
	move.l	#$3ed,d2
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOOpen,a6)
	move.l	d0,d1
	beq.b	NoLoadRecent
	move.l	d1,-(a7)
	clr.l	-(a7)
	move.l	a7,d2
	moveq	#4,d3
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVORead,a6)			; Read nbr
	move.l	(a7)+,d7
	move.l	(a7)+,d1
	lea.l	RecentTmp.MSG,a1
	subq.w	#1,d7
	blt.b	NoLoadRecent
LoadAllRecFiles:
	move.w	d7,-(a7)
	pea.l	(a1)
	move.l	d1,-(a7)
	clr.l	-(a7)				; Make room for length in stack
	move.l	a7,d2
	moveq	#4,d3				; Read 4 bytes
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVORead,a6)			; Read length
	move.l	(a7)+,d3			; Get length
	move.l	(a7)+,d1
	move.l	(a7),a1
	move.l	a1,d2
	move.l	d1,-(a7)
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVORead,a6)			; Store filename in buffer
	move.l	(a7)+,d1
	move.l	(a7),a1
	sf.b	(a1,d0.w)			; NULL at end of buffer
	lea.l	(a1),a3
	bsr.w	AddRecentFile			; Add it to list !
	move.l	(a7)+,a1
	move.w	(a7)+,d7
	dbf	d7,LoadAllRecFiles
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOClose,a6)
NoLoadRecent:
	movem.l	(a7)+,d0-a6
	rts

; -*- end here

C17B98:
	movem.l	d0-d7/a0-a6,-(sp)
	bra.b	C17BAE

C17B9E:
	movem.l	d0-d7/a0-a6,-(sp)
	lea	(MenuFileName).l,a1
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
	moveq	#$1D,d7
C17BD2:
	move.b	(a1)+,d0
	tst.b	d0
	beq.b	C17BDE
	move.b	d0,(a0)+
	dbra	d7,C17BD2
C17BDE:
	tst	d7	;passone
	bmi.b	C17BEA
C17BE2:
	move.b	#$20,(a0)+
	dbra	d7,C17BE2
C17BEA:
	move.b	#0,(a0)
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
	cmp.b	#$3A,(-1,a1)
	beq.b	C17C34
	cmp.b	#$2F,(-1,a1)
	beq.b	C17C34
	cmp.l	#LastFileNaam,a1
	beq.b	C17C34
	move.b	#$2F,(a1)+
C17C34:
	lea	(CurrentAsmLine).l,a0
C17C3A:
	cmp.b	#$3A,(a0)
	beq.b	C17C46
	tst.b	(a0)+
	bne.b	C17C3A
	bra.b	C17C4A

C17C46:
	lea	(LastFileNaam-DT,a4),a1
C17C4A:
	lea	(CurrentAsmLine).l,a0
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
	lea	(Mark1set-DT,a4),a2
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
	lea	(Mark1set-DT,a4),a2
	moveq	#10-1,d7
.lopje:
	moveq.l	#0,d1
	moveq.l	#8-1,d4
.marklop
	move.b	(a1)+,d2
	sub.b	#'0',d2
	cmp.b	#9,d2
	bls.s	.ok
	sub.b	#7,d2
.ok:
	lsl.l	#4,d1
	or.b	d2,d1
	dbf	d4,.marklop

	add.l	d0,d1
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

C17CBE:
	movem.l	d0-d4/a0/a6,-(sp)
	move.l	(DosBase-DT,a4),a6
	move.l	#CurrentAsmLine,d1
	moveq.l	#-2,d2
	jsr	(_LVOLock,a6)
	tst.l	d0
	bne.b	C17CEE
	lea	(SourceCode-DT,a4),a0
	move.l	a0,d1
	moveq.l	#-2,d2
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
	jsr	(_LVOUnLock,a6)		; ***
	move.l	(WORK_END-DT,a4),d1
	sub.l	(WORK_START-DT,a4),d1
	lea	(ParameterBlok-DT,a4),a0
	move.l	($007C,a0),d0
	cmp.l	d1,d0
	bgt.b	C17D1C
C17D16:
	movem.l	(sp)+,d0-d4/a0/a6
	rts

C17D1C:
	movem.l	(sp)+,d0-d4/a0/a6
	lea	(Notenoughwork.MSG).l,a0
	moveq	#0,d7
	jsr	(beeldtextaf).l
	addq.l	#4,sp
	rts

COM_ReadProject:
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(C1E2F0).l
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
	moveq	#1,d3
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOSeek,a6)
	move.l	#TempDirName,d2
	moveq	#4,d3
	bsr	read_nr_d3_bytes
	lea	(TempDirName).l,a0
	cmp.l	#"APRJ",(a0)
	beq.b	C17D8E
	moveq	#-3,d7
	bsr	close_bestand
	jmp	(_ERROR_ThisisnotaAsmProj).l

C17D8E:
	movem.l	a0/a1,-(sp)
	lea	(ProjectName-DT,a4),a0
	lea	(CurrentAsmLine-DT,a4),a1
C17D9A:
	move.b	(a1)+,(a0)+
	tst.b	(-1,a1)
	bne.b	C17D9A
	movem.l	(sp)+,a0/a1
	move.l	(Bestand-DT,a4),d1
	moveq	#0,d2
	moveq	#-1,d3
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
	bsr	C14232
	lea	(LastFileNaam-DT,a4),a0
	move.l	a0,d2
	move.l	#$00000100,d3
	bsr	read_nr_d3_bytes
	moveq	#10-1,d7
	lea	(SourcePtrs-DT,a4),a0
	move.l	a0,-(sp)
C17DFC:
	move.l	d7,-(sp)
	move.l	(4,sp),a0
	lea	(CS_filename,a0),a1
	move.l	a1,d2
	moveq.l	#$0000001F,d3
	bsr	read_nr_d3_bytes
	
	move.l	(4,sp),a0
	lea	(CS_FirstLinePtr,a0),a1
	move.l	a1,d2
	moveq	#4,d3
	bsr	read_nr_d3_bytes
	
	move.l	(4,sp),a0
	lea	(CS_FirstlineNr,a0),a1 ;fake save mark stuff so project files still work.
	clr.w	(a1)
	lea	2(a1),a1
	move.l	a1,d2
	moveq	#2,d3
	bsr	read_nr_d3_bytes
	
	move.l	(4,sp),a0
	lea	(CS_FirstLineOffset,a0),a1 ;fake also
	clr.w	(a1)
	lea	2(a1),a1
	move.l	a1,d2
	moveq	#2,d3
	bsr	read_nr_d3_bytes

	move.l	(4,sp),a0
	lea	(CS_SomeBits,a0),a1
	move.l	a1,d2
	moveq	#2,d3
	bsr	read_nr_d3_bytes

	move.l	(4,sp),a0
	lea	(CS_marks,a0),a1
	move.l	a1,d2
	moveq	#$28,d3
	bsr	read_nr_d3_bytes

	move.l	(4,sp),a0
	lea	(CS_update,a0),a1
	move.l	a1,d2
	move.l	#$00000080,d3
	bsr	read_nr_d3_bytes

	move.l	(4,sp),a0
	lea	(CS_AsmStatus,a0),a1
	move.l	a1,d2
	moveq	#2,d3
	bsr	read_nr_d3_bytes
	move.l	(sp)+,d7
	move.l	(sp)+,a0
	lea	(CS_size,a0),a0
	move.l	a0,-(sp)
	dbra	d7,C17DFC
	addq.w	#4,sp
	bsr	close_bestand
	lea	(LastFileNaam-DT,a4),a0
	lea	(CurrentAsmLine-DT,a4),a1
C17EA2:
	move.b	(a0)+,(a1)+
	tst.b	(-1,a0)
	bne.b	C17EA2
	clr.l	(FileLength-DT,a4)
	bsr	C17B66
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
	tst.b	(-1,a2)
	bne.b	C17ECE
	moveq	#9,d0
	sub	d7,d0
	lea	(CurrentAsmLine-DT,a4),a1
C17EE0:
	tst.b	(a1)
	beq.b	C17EE8
	addq.w	#1,a1
	bra.b	C17EE0

C17EE8:
	cmp.b	#$3A,(-1,a1)
	beq.b	C17EFC
	cmp.b	#$2F,(-1,a1)
	beq.b	C17EFC
	subq.w	#1,a1
	bra.b	C17EE8

C17EFC:
	bsr	C17B98
	movem.l	d7/a0,-(sp)
	jsr	(C17CBE).l
	movem.l	(sp),d7/a0
	lea	(ParameterBlok-DT,a4),a3
	move.l	($007C,a3),d0
	move.l	d0,(CS_length,a0)
	jsr	(OpenOldFile).l
	movem.l	(sp),d7/a0
	move.l	(Bestand-DT,a4),d1
	move.l	(CS_start,a0),d2
	moveq.l	#4,d3
	move.l	d2,-(sp)
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVORead,a6)
	move.l	(sp)+,a1
	cmp.l	#$F9FAF9FA,(a1)
	moveq	#44,d2
	beq.b	.oldmarksfound
	cmp.l	#";APS",(a1)
	moveq	#85,d2
	bne.s	.nomarks
.oldmarksfound:
	move.l	d2,(sp)+
	move.l	(Bestand-DT,a4),d1
	moveq	#-1,d3
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOSeek,a6)
	move.l	-(sp),d2
	movem.l	(sp),d7/a0
	sub.l	d2,(CS_length,a0)
;	sub.l	#44,(4,a0)
	bra.b	.rightpos

.nomarks:
	move.l	(Bestand-DT,a4),d1
	moveq	#0,d2
	moveq	#-1,d3
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOSeek,a6)
.rightpos:
	movem.l	(sp),d7/a0
	move.l	(CS_length,a0),d0
	move.l	#$00010001,d1
	move.l	(4).w,a6
	jsr	(_LVOAllocMem,a6)
	movem.l	(sp)+,d7/a0
	move.l	d0,(CS_start,a0)
	tst.l	d0
	bne.b	C17F9C
	jmp	ERROR_WorkspaceMemoryFull

C17F9C:
	move.l	(sourcestart-DT,a4),d2
	tst.l	(CS_FirstLinePtr,a0)
	beq.b	C17FAA
	add.l	(CS_FirstLinePtr,a0),d2
C17FAA:
	move.l	d2,(CS_FirstLinePtr,a0)
	move.l	(CS_start,a0),d2
	move.l	(CS_length,a0),d3
	movem.l	d7/a0,-(sp)
	bsr	read_nr_d3_bytes
	movem.l	(sp)+,d7/a0
	move.l	(CS_start,a0),a1
	move.l	a1,a2
	add.l	(CS_length,a0),a2
C17FCC:
	cmp.b	#10,(a1)
	bne.b	C17FD6
	move.b	#0,(a1)
C17FD6:
	addq.w	#1,a1
	cmp.l	a1,a2
	bne.b	C17FCC
	move.b	#$1A,(a1)
	movem.l	d7/a0,-(sp)
	bsr	close_bestand
	movem.l	(sp)+,d7/a0
C17FEC:
	lea	(CS_size,a0),a0
	dbra	d7,C17EB8
	lea	(LastFileNaam-DT,a4),a1
C17FF8:
	tst.b	(a1)
	beq.b	C18000
	addq.w	#1,a1
	bra.b	C17FF8

C18000:
	cmp.b	#$3A,(-1,a1)
	beq.b	C18014
	cmp.b	#$2F,(-1,a1)
	beq.b	C18014
	subq.w	#1,a1
	bra.b	C18000

C18014:
	lea	(MenuFileName).l,a2
	moveq	#$1D,d7
C1801C:
	move.b	(a1)+,d0
	tst.b	d0
	beq.b	C1802A
	move.b	d0,(a2)+
	dbra	d7,C1801C
	bra.b	C18030

C1802A:
	move.b	d0,(a2)+
	dbra	d7,C1802A
C18030:
	move.b	#0,(a2)
	lea	(MenuFileName).l,a1
	moveq	#0,d0
	bsr	C17B98
	move.b	#$56,d0
	jsr	(KEYBUFFERPUTCHAR).l
	move.b	#$20,d0
	jsr	(KEYBUFFERPUTCHAR).l
	lea	(PrevDirnames-DT,a4),a0
	jsr	(DATAFROMAUTO).l
	moveq	#10,d0
	jsr	(KEYBUFFERPUTCHAR).l
	br	RESETMENUTEXT2

C1806A:
	bsr	C180C4
	br	C17D50

com_readFileNoReq:
	move.b	(CurrentSource-DT,a4),d0
	move.b	d0,(B30174-DT,a4)
	bsr	C141CE
	move.l	a6,a5
	jsr	(C141C8).l
	move.l	a5,a6
	bsr.b	C180C4
;	tst.b	(PR_SourceExt).l	;no more extention adding
;	beq.w	C18094
;	bsr.b	C1809A
;C18094:
	bsr.b	C180E8
	br	C17B66

C1809A:
	lea	(S.MSG).l,a1
	moveq	#16-1,d7
C180A2:
	move.b	(-16,a0,d7.w),d0
	move.b	(a1,d7.w),d1
	cmp.b	d0,d1
	bne.b	C180B8
	dbra	d7,C180A2

	move.b	#0,(a0)
	rts

C180B8:
;	moveq	#4-1,d7
	moveq	#16-1,d7
C180BA:
	move.b	(a1)+,(a0)+
	dbra	d7,C180BA
	clr.b	(a0)
	rts

C180C4:
	lea	(CurrentAsmLine).l,a0
C180CA:
	cmp.b	#$20,(a6)
	beq.b	C180D8
	cmp.b	#9,(a6)
	beq.b	C180D8
	bra.b	C180DC

C180D8:
	addq.l	#1,a6
	bra.b	C180CA

C180DC:
	tst.b	(a6)
	beq.b	C180E4
	move.b	(a6)+,(a0)+
	bra.b	C180DC

C180E4:
	clr.b	(a0)
	rts

C180E8:
	lea	(MenuFileName).l,a0
	lea	(CurrentAsmLine).l,a1
C180F4:
	tst.b	(a1)
	beq.b	C180FC
	addq.l	#1,a1
	bra.b	C180F4

C180FC:
	cmp.b	#$3A,(-1,a1)	;':'
	beq.b	C18118
	cmp.b	#$2F,(-1,a1)	;'/'
	beq.b	C18118
	cmp.l	#CurrentAsmLine,a1
	beq.b	C18118
	subq.l	#1,a1
	bra.b	C180FC

C18118:
	tst.b	(a1)
	beq.b	C18120
	move.b	(a1)+,(a0)+
	bra.b	C18118

C18120:
	clr.b	(a0)
	rts

C18124:
	tst.l	(ReqToolsbase-DT,a4)
	bne.b	OpenColorReq
	jsr	(openreqtoolslib).l
	tst.l	(ReqToolsbase-DT,a4)
	bne.b	OpenColorReq
	rts

OpenColorReq:
	move.l	(ReqToolsbase-DT,a4),a6
	lea	(Selectcolours.MSG).l,a2
	sub.l	a3,a3
	sub.l	a0,a0
	jsr	(_LVOrtPaletteRequestA,a6)		; ***
	cmp.l	#$FFFFFFFF,d0
	bne.b	C18154
	rts

C18154:
	bsr.b	C1815E
	move.b	#1,(B2E3CA-DT,a4)
	rts

C1815E:
	lea	(ScrColors-DT,a4),a5
	move.l	(GfxBase-DT,a4),a6
	move	#0,-(sp)
	moveq	#16-1,d7
C1816C:
	move.l	(ViewPortBase-DT,a4),a0
	move.l	(4,a0),a0
	move	(sp),d0
	jsr	(_LVOGetRGB4,a6)
	move	d0,(4,a5)
	and	#15,(4,a5)
	move	d0,d1
	lsr.w	#4,d1
	move	d1,(2,a5)
	and	#15,(2,a5)
	move	d0,d1
	lsr.w	#8,d1
	move	d1,(a5)
	and	#15,(a5)
	addq.l	#6,a5
	add	#1,(sp)
	dbra	d7,C1816C
	move	(sp)+,d0
	rts

C181AC:
	move.l	(GfxBase-DT,a4),a6
	moveq	#16-1,d7
	moveq	#0,d4
C181B4:
	move	d4,d0
	lea	(ScrColors-DT,a4),a0
	mulu	#6,d0
	lea	(a0,d0.w),a0
	moveq	#0,d0
	move	d4,d0
	movem.w	(a0)+,d1-d3
	move.l	(ViewPortBase-DT,a4),a0
	jsr	(_LVOSetRGB4,a6)		; ***
	addq.w	#1,d4
	dbra	d7,C181B4
	rts

C181DA:
	clr.l	(FileLength-DT,a4)
	moveq	#10,d0
	bsr	FileReqStuff
C181E4:
	bsr	C17CBE
	bsr	OpenOldFile
	clr	(Marksinsource-DT,a4)
	bsr	SaveMarksOpnieuwIstalleren
C181F4:
	move.l	(FirstLinePtr-DT,a4),a2
	jsr	(KillCopybuffer).l
C181FE:
	lea	(ParameterBlok-DT,a4),a5
	move.l	a5,d2
	move.l	#$00002000,d3
	movem.l	a2/a5,-(sp)
	bsr	read_nr_d3_bytes
	movem.l	(sp)+,a2/a5
	sub.l	a5,d0
	beq.b	C18260
	cmp.b	#$1A,(-1,a5,d0.l)
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
	jmp	(C12688).l

Com_ReadObject:
	addq.w	#1,a6
	move.l	a6,-(sp)
	bsr.b	C182BE
	move.l	(sp)+,a6
	cmp.b	#$20,(a6)
	beq.b	C182B8
	moveq	#4,d0
	bsr	FileReqStuff
C1827E:
	move.l	#CurrentAsmLine,d1
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOLoadSeg,a6)
	tst.l	d0
	bne.b	C18296
	jmp	(ERROR_FileError).l

C18296:
	move.l	d0,(SEGMENTADDRESS-DT,a4)
	lsl.l	#2,d0
	move.l	d0,a0
	move.l	(a0),(SEGMENTLENGTH-DT,a4)
	addq.l	#4,d0
	move.l	d0,(FileLength-DT,a4)
	move.l	d0,(MEM_DIS_DUMP_PTR-DT,a4)
	move.l	d0,(pcounter_base-DT,a4)
	lea	(Filelocation.MSG,pc),a0
	br	Writefile_afwerken

C182B8:
	bsr	C180C4
	bra.b	C1827E

C182BE:
	move.l	(SEGMENTADDRESS-DT,a4),d1
	beq.b	C182DA
	clr.l	(SEGMENTADDRESS-DT,a4)
	lsl.l	#2,d1
	move.l	d1,a0
	move.l	(SEGMENTLENGTH-DT,a4),(a0)
	lsr.l	#2,d1
	move.l	(DosBase-DT,a4),a6
	jmp	(_LVOUnLoadSeg,a6)

C182DA:
	rts

Com_ReadBin:
	addq.l	#1,a6
	cmp.b	#" ",(a6)
	beq	.nofilereq
	moveq	#2,d0
	bsr	FileReqStuff
.resume:
	bsr	OpenOldFile
	moveq	#-1,d7
	bsr	INPUTBEGINEND

	cmp.l	#-1,d2
	beq.s	.notdone

	moveq	#0,d7
	move.l	d2,(MEM_DIS_DUMP_PTR-DT,a4)
	bsr.b	read_nr_d3_bytes
	br	close_bestand

.notdone:
	bset	#SB3_EDITORMODE,(SomeBits3-DT,a4)	;editor
	bsr	close_bestand
	bclr	#SB3_EDITORMODE,(SomeBits3-DT,a4)	;editor
	rts
	
.nofilereq:
	bsr	C180C4
	bra.b	.resume

read_nr_d3_bytes:
	move.l	d2,-(sp)
	bclr	#$1F,d3
	move.l	(Bestand-DT,a4),d1
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVORead,a6)
	add.l	d0,(FileLength-DT,a4)
	add.l	(sp)+,d0
	rts

IO_WriteFile:
	move.l	(Bestand-DT,a4),d1
C18326:
	move.l	(DosBase-DT,a4),a6
	move.l	d3,-(sp)
	add.l	d3,(FileLength-DT,a4)
	jsr	(_LVOWrite,a6)
	sub.l	(sp)+,d0
	bne	C183B8
	rts

OpenOldFile:
	move.l	#$000003ED,d2
C18342:
	move.l	#CurrentAsmLine,d1
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOOpen,a6)
	tst.l	d0
	bne.b	C18368
	move.l	#$000003ED,d2
	lea	(SourceCode-DT,a4),a6
	move.l	a6,d1
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOOpen,a6)
C18368:
	move.l	d0,(Bestand-DT,a4)
	bne.b	C18374
	jmp	(ERROR_FileError).l

C18374:
	bset	#SB1_CLOSE_FILE,(SomeBits-DT,a4)
	rts

IO_OpenFile:
	move.l	(DosBase-DT,a4),a6
	move.l	#CurrentAsmLine,d1
	moveq	#-2,d2
	jsr	(_LVOLock,a6)
	tst.l	d0
	beq.b	OPENFILE_NOASK
	move.l	d0,d1
	jsr	(_LVOUnLock,a6)			; ***
	tst.b	(Safety-DT,a4)
	bne.b	OPENFILE_NOASK
	jsr	(C142D4).l
OPENFILE_NOASK:
	jsr	DeactivateMsgs
	move.l	(DosBase-DT,a4),a6
	move.l	#CurrentAsmLine,d1
	jsr	(_LVODeleteFile,a6)
	move.l	#$000003EE,d2
	bra.w	C18342

C183B8:
	bsr.b	close_bestand
	jmp	(ERROR_NoFileSpace).l

close_bestand:
	bclr	#SB1_CLOSE_FILE,(SomeBits-DT,a4)
	move.l	(Bestand-DT,a4),d1
C183CA:
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOClose,a6)

	jsr	ActivateMsgs

	btst	#SB3_EDITORMODE,(SomeBits3-DT,a4)	;editor
	beq.b	C183DC
	rts

C183DC:
	cmp.l	#-1,d7
	bne.b	C183EC
	lea	(H.MSG,pc),a0
	br	Writefile_afwerken

C183EC:
	cmp.l	#-2,d7
	bne.b	DrukFilelength
	rts

DrukFilelength:
	lea	(Filelength.MSG,pc),a0
	br	Writefile_afwerken

C183FE:
	moveq	#$4E,d1
PrintStatusInfo0:
	moveq	#$2D,d0
	bsr	SENDONECHARNORMAL
	dbra	d1,PrintStatusInfo0
	br	druk_cr_nl

PrintStatusInfoE:
	bsr.b	C183FE
	lea	(Name.MSG,pc),a0
	br	printthetext

C18418:
	move.l	(4,sp),d0
	lsl.l	#8,d0
	lsl.l	#1,d0
	bsr	PI_druklinenr
	lea	(BytesFree.MSG,pc),a0
	bsr	printthetext
	move.l	(8,sp),d0
	lsl.l	#8,d0
	lsl.l	#1,d0
	bsr	PI_druklinenr
	lea	(BytesUsed.MSG,pc),a0
	bsr	printthetext
	bsr.b	C183FE
	moveq	#0,d0
	bsr	SENDONECHARNORMAL
	move.l	(sp)+,a3
	addq.w	#8,sp
	jmp	(a3)

C1844E:
	move.l	a5,-(sp)
	move	(MEMDIR_ANTAL-DT,a4),d6
	beq.b	C184AA
	lea	(L2C06A-DT,a4),a1
	move	#$DFDF,d2
	move.l	a1,a0
	sub	#$0022,a0
	moveq	#0,d5
C18466:
	addq.w	#1,d5
	cmp	d5,d6
	beq.b	C184AA
	move.l	a1,a0
	add	#$0022,a1
C18472:
	move.l	a0,a2
	move.l	a1,a3
	moveq	#14,d3
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
	moveq	#17-1,d1
C18494:
	move	(a2),d0
	move	(a3),(a2)+
	move	d0,(a3)+
	dbra	d1,C18494
	move.l	a0,a1
	sub	#$0022,a0
	subq.w	#1,d5
	beq.b	C18466
	bra.b	C18472

C184AA:
	move.l	(sp)+,a5
	rts

ViewMemDirectory:
	lea	(Memorydirecto.MSG,pc),a0
	bsr	printthetext
	bsr	PrintStatusInfoE
	addq.w	#4,a5			 	; pass header
	moveq	#30-1,d1
C184BE:
	move.b	(a5)+,d0			; print path
	bsr	SENDONECHARNORMAL
	dbra	d1,C184BE
	tst.b	(a5)+
	bne.b	C184D4
	bsr.b	C1844E
	st.b	(-1,a5)
C184D4:
	move.l	(a5)+,-(sp)			; print used/free bytes
	move.l	(a5)+,-(sp)
	bsr	C18418
	move	(MEMDIR_ANTAL-DT,a4),d6
	moveq	#2,d5				; 2 cols
PrintFilesMemLoop:
	subq.w	#1,d6
	bmi.w	druk_cr_nl
	move.l	(a5)+,d0			; file length
	bmi.b	PrintMemDir			; it is a directory ?
	moveq	#$20,d3
	lea	(TABEL_HEXTODECFILE,pc),a0
	bsr	C15980
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
	moveq	#0,d0
	bsr	SENDONECHARNORMAL
	subq.w	#1,(W13C38).l
	bne.b	C18540
	bsr	GETKEYNOPRINT
	cmp.b	#$1B,d0
	bne.b	C18532
	br	druk_cr_nl

C18532:
	move	(ScreenHight-DT,a4),d0
	add.w	d0,d0
	subq.w	#2,d0
	move	d0,(W13C38).l
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
	moveq	#-2,d2
	jsr	(_LVOLock,a6)			; ***
	tst.l	d0
	bne.b	C1857A
	move.l	#0,(L2C05E-DT,a4)
	move.l	#0,(L2C062-DT,a4)
	move.l	#$51413121,(MEMDIR_BUFFER-DT,a4)
	jmp	(ERROR_IllegalPath).l

C1857A:
	lea	(ParameterBlok-DT,a4),a0
	move.l	a0,d2
	moveq	#$40,d7
C18582:
	move.l	#0,(a0)+
	dbra	d7,C18582
	move.l	d0,d1
	move.l	d1,-(sp)
	jsr	(_LVOExamine,a6)			; ***
	move.l	(sp)+,d0
	tst.l	(L2BF50-DT,a4)
	bpl.b	C185C0
	move.l	d0,d1
	jsr	(_LVOUnLock,a6)			; ***
	move.l	#0,(L2C05E-DT,a4)
	move.l	#0,(L2C062-DT,a4)
	move.l	#$51413121,(MEMDIR_BUFFER-DT,a4)
	jmp	(ERROR_IllegalPath).l

C185C0:
	lea	(B2A016-DT,a4),a0
	bsr.b	C185E2
	tst.b	(B2A016-DT,a4)
	beq.b	C185D2
	move.l	d0,d1
	jmp	(_LVOCurrentDir,a6)		; ***

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
	cmp.b	#$3A,d0
	beq.b	C1865C
	tst.b	d0
	bne.b	C185E8
	move.l	(sp)+,a0
	lea	(PrevDirnames-DT,a4),a1
C185FA:
	cmp.b	#$2F,(a0)
	bne.b	C1862C
	addq.w	#1,a0
C18602:
	tst.b	(a1)+
	bne.b	C18602
	subq.w	#1,a1
	cmp.l	#PrevDirnames,a1
	beq.b	C1864E
C18610:
	clr.b	-(a1)
	cmp.b	#$3A,(-1,a1)
	beq.b	C185FA
	cmp.b	#$2F,(-1,a1)
	beq.b	C185FA
	cmp.l	#PrevDirnames,a1
	beq.b	C1864E
	bra.b	C18610

C1862C:
	tst.b	(a1)+
	bne.b	C1862C
	subq.w	#1,a1
	cmp.b	#$3A,(-1,a1)
	beq.b	C1864E
	cmp.b	#$2F,(-1,a1)
	beq.b	C1864E
	cmp.l	#PrevDirnames,a1
	beq.b	C1864E
	move.b	#$2F,(a1)+
C1864E:
	move.b	(a0)+,(a1)+
	tst.b	(a0)
	bne.b	C1864E
	clr.b	(a1)
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
	move	d0,(W13C38).l
	move.l	(DosBase-DT,a4),a6
	lea	(B2A015-DT,a4),a0
	lea	(MEMDIR_BUFFER-DT,a4),a5
	tst.b	(a0)
	bne.b	C1869A
	cmp.l	#$12131415,(a5)			; go to mem directory
	beq	ViewMemDirectory
	cmp.l	#$51413121,(a5)
	bne.b	C1869A
	jmp	(ERROR_Novalidmemory).l

C1869A:
	cmp.b	#$20,(a0)			; V xxx = just set current dir
	beq	SetViewCurrentDir
	move.l	#$12131415,(a5)+
	clr	(MEMDIR_ANTAL-DT,a4)
	move.l	a0,d1
	moveq	#-2,d2
	jsr	(_LVOLock,a6)			; ***
	tst.l	d0
	bne	C186D8
	move.l	#0,(L2C05E-DT,a4)
	move.l	#0,(L2C062-DT,a4)
	move.l	#$51413121,(MEMDIR_BUFFER-DT,a4)
	jmp	(ERROR_IllegalPath).l

C186D8:
	lea	(ParameterBlok-DT,a4),a0
	move.l	a0,d2
	moveq	#60-1,d7
C186E0:
	move.l	#0,(a0)+
	dbra	d7,C186E0
	move.l	d0,d1
	move.l	d1,-(sp)
	jsr	(_LVOExamine,a6)		; ***
	move.l	(sp)+,d0
	tst.l	(L2BF50-DT,a4)
	bpl.b	C1871E
	move.l	d0,d1
	jsr	(_LVOUnLock,a6)			; ***
	move.l	#0,(L2C05E-DT,a4)
	move.l	#0,(L2C062-DT,a4)
	move.l	#$51413121,(MEMDIR_BUFFER-DT,a4)
	jmp	(ERROR_IllegalPath).l

C1871E:
	lea	(B2A015-DT,a4),a0
	bsr	C185E2
	move.l	d0,-(sp)
	tst.b	(B2A015-DT,a4)
	beq.b	C18734
	move.l	d0,d1
	jsr	(_LVOCurrentDir,a6)		; ***
C18734:
	move.l	(sp),d1
	lea	(ParameterBlok-DT,a4),a0
	move.l	a0,d2
	jsr	(_LVOInfo,a6)			; ***
	move.l	(L2BF5C-DT,a4),d1
	move.l	(L2BF58-DT,a4),d0
	sub.l	d1,d0
	movem.l	d0/d1,-(sp)
	move.l	(8,sp),d1
	lea	(ParameterBlok-DT,a4),a0
	move.l	a0,d2
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOExamine,a6)
	bsr	PrintStatusInfoE
	tst.l	(L2BFC4-DT,a4)
	bpl.w	C1878A
	move.l	#0,(L2C05E-DT,a4)
	move.l	#0,(L2C062-DT,a4)
	move.l	#$51413121,(MEMDIR_BUFFER-DT,a4)	;"QA1!" ??
	jmp	(ERROR_IllegalPath).l

C1878A:
	lea	(L2BF54-DT,a4),a0
	moveq	#30-1,d1
C18790:
	move.b	(a0)+,d0			; store path
	beq.b	C187A0
	move.b	d0,(a5)+
	bsr	SENDONECHARNORMAL
	dbra	d1,C18790
	bra.b	C187AC

C187A0:
	moveq	#$20,d0
	move.b	d0,(a5)+
	bsr	SENDONECHARNORMAL
	dbra	d1,C187A0
C187AC:
	clr.b	(a5)+
	move.l	(4,sp),(a5)+
	move.l	(sp),(a5)+
	bsr	C18418
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
	move.l	(L2BFC4-DT,a4),d0
	bpl.b	C187F2
	move.l	(incFileLength-DT,a4),d0
	move.l	d0,(a5)+
	moveq	#$20,d3
	lea	(TABEL_HEXTODECFILE,pc),a0
	bsr	C15980
	bsr	druk_af_space
	bra.b	C18800

C187F2:
	move.l	#$FFFFFFFF,(a5)+		; dir flag
	lea	(dir.MSG,pc),a0
	bsr	printthetext
C18800:
	lea	(L2BF54-DT,a4),a0
	moveq	#30-1,d1
C18806:
	move.b	(a0)+,d0
	beq.b	C18816
	move.b	d0,(a5)+
	bsr	SENDONECHARNORMAL
	dbra	d1,C18806
	bra.b	C18822

C18816:
	moveq	#$20,d0
	move.b	d0,(a5)+
	bsr	SENDONECHARNORMAL
	dbra	d1,C18816
C18822:
	addq.w	#1,(MEMDIR_ANTAL-DT,a4)
	moveq	#0,d0
	bsr	SENDONECHARNORMAL
	move.l	(DosBase-DT,a4),a6
	move.l	(2,sp),d1
	move.l	#ParameterBlok,d2
	jsr	(_LVOExNext,a6)
	tst	d0
	bne.b	C1884E
	addq.l	#6,sp
	br	druk_cr_nl

C1884E:
	subq.w	#1,(W13C38).l
	bne.b	C18874
	bsr	GETKEYNOPRINT
	cmp.b	#$1B,d0
	bne.b	C18866
	addq.l	#6,sp
	br	druk_cr_nl

C18866:
	move	(ScreenHight-DT,a4),d0
	add.w	d0,d0
	subq.w	#2,d0
	move	d0,(W13C38).l
C18874:
	subq.w	#1,(sp)
	bne	C187D6
	bsr	druk_cr_nl
	move	#2,(sp)			; 2cols
	br	C187D6

com_update:
	move.b	(a6),d0
	move.b	d0,d3
	bclr	#5,d0
	cmp.b	#'A',d0
	beq	C18904
	tst.b	d0
	beq.b	UpdateCurrBuffer
	jmp	(_ERROR_IllegalComman).l

UpdateCurrBuffer:
	btst	#0,(PR_UpdateAlways).l
	beq.b	C188B2
C188AA:
	btst	#SB1_SOURCE_CHANGED,(SomeBits-DT,a4)
	beq.w	C188FA
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

	move.b	#'.',(a0)
	move.b	#'B',1(a0)
	move.b	#'A',2(a0)
	move.b	#'C',3(a0)
	move.b	#'K',4(a0)
	move.b	#'U',5(a0)
	move.b	#'P',6(a0)
	move.b	#0,7(a0)	;filename.s.BACKUP

	movem.l	(sp)+,d1/d2	;oldfilename/newfilename

	tst.b	(PR_AutoBackup).l
	beq.s	.noBackup
	move.l	a0,-(sp)

	move.l	(DosBase-DT,a4),a6

	movem.l	d1/d2,-(sp)
	jsr	_LVODeleteFile(a6)
	movem.l	(sp)+,d1/d2
	exg.l	d1,d2
	jsr	_LVORename(a6)
	move.l	(sp)+,a0
.noBackup:
	clr.b	(a0)		;filename without .BACKUP

	lea	(Updating.MSG,pc),a0
	bsr	printthetext
	lea	(CurrentAsmLine-DT,a4),a0
	bsr	printthetext
	bsr	druk_cr_nl
	moveq	#0,d0
	bsr	SENDONECHARNORMAL

	bsr	OPENFILE_NOASK
	br	WRITE_DOIT

C188F0:
	move.b	d0,(a0)+
	move.b	(a1)+,d0
	bne.b	C188F0
	subq.w	#1,a1
	rts

C188FA:
	lea	(Sourcenotchan.MSG,pc),a0
	bsr	printthetext
	rts

C18904:
	tst.l	(L2FCBA-DT,a4)
	beq	C18988
	move.b	#1,(FromCmdLine-DT,a4)
	moveq	#0,d0
	move.b	(CurrentSource-DT,a4),d0
	move	d0,-(sp)
	moveq	#9,d7
C1891C:
	move.b	#9,(Change2Source-DT,a4)
	sub.b	d7,(Change2Source-DT,a4)
	move	d7,-(sp)
	movem.l	d0-d7/a0-a6,-(sp)
	movem.l	(EditorRegs-DT,a4),d0-d7/a0-a6
	jsr	(Go2Sourcenow).l
	movem.l	(sp)+,d0-d7/a0-a6
	bsr	C188AA
	move	(sp)+,d7
	dbra	d7,C1891C
	lea	(ProjectName-DT,a4),a0
	lea	(CurrentAsmLine-DT,a4),a1
C1894E:
	move.b	(a0)+,(a1)+
	tst.b	(-1,a1)
	bne.b	C1894E
	tst.b	(CurrentAsmLine-DT,a4)
	beq.b	C18976
	clr.l	(FileLength-DT,a4)
	move.b	(Safety-DT,a4),d0
	move	d0,-(sp)
	move.b	#1,(Safety-DT,a4)
	bsr	C18AB2
	move	(sp)+,d0
	move.b	d0,(Safety-DT,a4)
C18976:
	move	(sp)+,d0
	move.b	d0,(Change2Source-DT,a4)
	jsr	(Go2Sourcenow).l
	move.b	#0,(FromCmdLine-DT,a4)
C18988:
	rts

com_write:
	clr.l	(FileLength-DT,a4)
	move.b	(a6),d0
	move.b	d0,d3
	bclr	#5,d0
	cmp.b	#'T',d0
	beq	C1705C
	cmp.b	#'O',d0
	beq	C196F8
	cmp.b	#'S',d0
	beq	C17048
	cmp.b	#'B',d0
	beq	Com_WriteBin
	cmp.b	#'P',d0
	beq	Write_Prefs
	cmp.b	#'L',d0
	beq	C19176
	cmp.b	#'E',d0
	beq	C18A94
	cmp.b	#'N',d0
	beq	Com_WriteNormal
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
	bsr	C189E6
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
	move.l	#$00001FFF,d1
	moveq	#0,d3
C18A0A:
	move.b	(a0)+,d0
	bne.b	C18A12
	move.b	#10,d0
C18A12:
	cmp.b	#$1A,d0
	beq.w	C18A84
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
	lea	(Mark1set-DT,a4),a0
	moveq	#10-1,d7
.lopje:
	move.l	(a0)+,d0
	tst.l	d0
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
	move.b	#0,(a0)+
.noextention:
	bsr	C180E8
	br	C189E6

C18A84:
	bsr	IO_WriteFile
	bsr	close_bestand
	lea.l	(CurrentAsmLine).l,a3
	bsr.w	AddRecentFile
	bclr	#SB1_SOURCE_CHANGED,(SomeBits-DT,a4)
	rts

C18A94:
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(C1E2F0).l
	movem.l	(sp)+,d0-d7/a0-a6
	cmp.b	#$20,(1,a6)
	beq	C18C3E
	moveq	#13,d0
	bsr	FileReqStuff
C18AB2:
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
	move.b	(a0,d1.w),d0
	bclr	#5,d0
	move.b	(a1)+,d2
	bclr	#5,d2
	cmp.b	d2,d0
	bne.b	C18AEE
	addq.w	#1,d1
	tst	d1
	bne.b	C18AD4
	bra.b	C18B16

C18AEE:
	move.b	#$2E,(a0)+	;.Aprj
	move.b	#$2E,(a2)+
	move.b	#$41,(a0)+
	move.b	#$41,(a2)+
	move.b	#$70,(a0)+
	move.b	#$70,(a2)+
	move.b	#$72,(a0)+
	move.b	#$72,(a2)+
	move.b	#$6A,(a0)+
	move.b	#$6A,(a2)+
C18B16:
	clr.b	(a0)
	clr.b	(a2)
	movem.l	(sp)+,a0-a2
	movem.l	a0/a1,-(sp)
	lea	(TempDirName-DT,a4),a1
	lea	(CurrentAsmLine-DT,a4),a0
C18B2A:
	move.b	(a1)+,(a0)+
	tst.b	(a1)
	bne.b	C18B2A
	clr.b	(a0)
	movem.l	(sp)+,a0/a1
	move.l	#0,(FileLength-DT,a4)
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
	move.l	#256,d3
	bsr	IO_WriteFile



	moveq	#10-1,d7
	lea	(SourcePtrs-DT,a4),a0
	move.l	a0,-(sp)

;	move.l	#Aprj.MSG,d2
;	moveq.l	#4,d3
;	bsr	IO_WriteFile
C18B76:
	move.l	d7,-(sp)
	move.l	(4,sp),a0
	lea	(CS_filename,a0),a1
	move.l	a1,d2
	moveq.l	#31,d3
	bsr	IO_WriteFile
	move.l	(4,sp),a0
	move.l	(CS_FirstLinePtr,a0),d2
	tst.l	d2
	beq.b	C18B9C
	sub.l	(sourcestart-DT,a4),d2
C18B9C:
	move.l	d2,(TempDirName-DT,a4)
	lea	(TempDirName-DT,a4),a1
	move.l	a1,d2
	moveq	#4,d3
	bsr	IO_WriteFile

	move.l	(4,sp),a0
	lea	(CS_FirstlineNr+2,a0),a1	;fake for project file
	move.l	a1,d2
	moveq	#2,d3
	bsr	IO_WriteFile
	
	move.l	(4,sp),a0
	lea	(CS_FirstLineOffset+2,a0),a1	;fake also
	move.l	a1,d2
	moveq	#2,d3
	bsr	IO_WriteFile
	
	move.l	(4,sp),a0
	lea	(CS_SomeBits,a0),a1
	move.l	a1,d2
	moveq	#2,d3
	bsr	IO_WriteFile
	
	move.l	(4,sp),a0
	lea	(CS_marks,a0),a1
	move.l	a1,d2
	moveq	#$28,d3
	bsr	IO_WriteFile

	move.l	(4,sp),a0
	lea	(CS_update,a0),a1
	move.l	a1,d2
	move.l	#$00000080,d3
	bsr	IO_WriteFile

	move.l	(4,sp),a0
	lea	(CS_AsmStatus,a0),a1
	move.l	a1,d2
	moveq	#2,d3
	bsr	IO_WriteFile

	move.l	(sp)+,d7
	move.l	(sp)+,a0
	lea	(CS_size,a0),a0
	move.l	a0,-(sp)
	dbra	d7,C18B76
	addq.w	#4,sp
	move.l	#"APRJ",(TempDirName-DT,a4)
	lea	(TempDirName-DT,a4),a0
	move.l	a0,d2
	moveq	#4,d3
	bsr	IO_WriteFile
	bsr	close_bestand
	movem.l	(sp)+,d0-d7/a0-a6
	rts

C18C3E:
	addq.l	#1,a6
	bsr	C180C4
	br	C18AB2

	dc.b	'.'
Aprj.MSG:
	dc.b	'Aprj',0

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
	moveq	#0,d7
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
	move.l	d2,(TempDirName-DT,a4)
	move.l	d3,(L2E186-DT,a4)
	bsr	IO_OpenFile
	move.l	(TempDirName-DT,a4),d2
	move.l	(L2E186-DT,a4),d3
	bsr	IO_WriteFile
	br	close_bestand

C18CB6:
	addq.l	#1,a6
	bsr	C180C4
	bra.b	C18C5C

Write_Prefs:
	lea	(Gave_prefs_table).l,a0
	lea	(ParameterBlok-DT,a4),a1
Write_prefslopje:
	move.l	a0,a2
	move	(a0)+,d0
	beq.b	WP_Next
	add	d0,a2
	moveq	#'-',d0
	btst	#0,(a2)
	beq.b	wp_minus
	moveq	#'+',d0
wp_minus:
	move.b	d0,(a1)+	;bv. "+RD"
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	#10,(a1)+	;volgende regel
	bra.b	Write_prefslopje

WP_Next:
	move.b	#'!',(a1)+
	lea	(S.MSG).l,a0
.lopje:
	move.b	(a0)+,(a1)+
	bne.b	.lopje

	subq.l	#1,a1
	move.b	#10,(a1)+
	lea	(HomeDirectory-DT,a4),a0
	tst.b	(a0)
	beq.b	C18D10
	move.b	#'*',(a1)+
C18D06:
	move.b	(a0)+,(a1)+
	tst.b	(a0)
	bne.b	C18D06
	move.b	#10,(a1)+
C18D10:
	lea	(ScrColors-DT,a4),a0
	moveq	#16-1,d7
C18D16:
	move.b	#'|',(a1)+
	moveq	#3-1,d6
C18D1C:
	move	(a0)+,d0
	cmp.b	#10,d0
	blt.b	C18D2A
	add.b	#$37,d0
	bra.b	C18D2E

C18D2A:
	add.b	#$30,d0
C18D2E:
	move.b	d0,(a1)+
	dbra	d6,C18D1C
	dbra	d7,C18D16

	moveq	#10,d2
	move.b	#$7C,(a1)+
	move.b	d2,(a1)+
	move	(CPU_type-DT,a4),d0
	add	#'0',d0
	move.b	#$5B,(a1)+	;cpu
	move.b	#$43,(a1)+
	move.b	#$50,(a1)+
	move.b	#$55,(a1)+
	move.b	d0,(a1)+
	move.b	d2,(a1)+
	move	(W2E508-DT,a4),d0
	add	#$0030,d0
	move.b	#$5B,(a1)+	;mmu
	move.b	#$4D,(a1)+
	move.b	#$4D,(a1)+
	move.b	#$55,(a1)+
	move.b	d0,(a1)+
	move.b	d2,(a1)+

	move.b	#$5E,(a1)+	"^"
	move.l	(SchermMode).l,d0
	bsr	van_d0_2_string
	move.b	#$7C,(a1)+
	move.l	(HoogteScherm).l,d0
	bsr	van_d0_2_string
	move.b	#$7C,(a1)+
	move.l	(BreedteScherm).l,d0
	bsr	van_d0_2_string
	move.b	#$7C,(a1)+
	move.w	Scr_NrPlanes,d0
	bsr	addword2pf
	move.b	#10,(a1)+

;Memtype en size..
	move.b	#'@',(a1)+
	movem.l	d0/a0,-(sp)
	move.l	_memtype,d0
	lea	memstuff2(pc),a0
	move.b	(a0,d0.w),(a1)+
	move.l	_memamount(pc),d0
	bsr	van_d0_2_string
	movem.l	(sp)+,d0/a0
	move.b	#10,(a1)+

;Editor font..
	move.b	#'(',(a1)+
	lea	editfont_name,a0
.lopje:
	move.b	(a0)+,(a1)+
	bne.b	.lopje
	subq.l	#1,a1
	move.b	#'|',(a1)+

	move.w	EditorFontSize,d0
	bsr	addword2pf
	move.b	#10,(a1)+

;Syntax Colors...
	move.b	#')',(a1)+
	lea	fontcolortab,a0
	moveq.l	#8-1,d6
.lopje2:
	move.l	(a0)+,d0
	bsr	van_d0_2_string
;	move.l	(a0)+,d0
;	bsr	addword2pf
	move.b	#'|',(a1)+
	dbf	d6,.lopje2

	move.b	#10,(a1)+

;Window font
	lea	(BootUpString-DT,a4),a0
	tst.b	(a0)
	beq.b	C18DC2
	cmp.b	#$5C,(a0)
	beq.b	C18DB8
	move.b	#$5C,(a1)+
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
	tst.b	(B30042-DT,a4)
	bne.b	C18DD6
	bsr	C19164
C18DD6:
	movem.l	d2/d3,-(sp)
	bsr	IO_OpenFile
	movem.l	(sp)+,d2/d3
	bsr	IO_WriteFile
	br	close_bestand

van_d0_2_string:
	moveq	#8-1,d7
C18DEC:
	rol.l	#4,d0
	move.b	d0,d1
	and.l	#15,d1
	cmp.b	#9,d1
	ble.b	C18E00
	add.b	#7,d1
C18E00:
	add.b	#'0',d1
	move.b	d1,(a1)+
	dbra	d7,C18DEC
	rts

van_string_2_d1:
.lopje:
	moveq	#0,d0
	move.b	(a6)+,d0
	tst.b	d0
	beq.b	.klaarnr
	cmp.b	#10,d0
	beq.b	.klaarnr
	cmp.b	#'|',d0
	beq.b	.klaarnr
	sub.b	#'0',d0
	cmp.b	#9,d0
	ble.b	.dec
	sub.b	#7,d0
.dec:
	lsl.l	#4,d1
	add.l	d0,d1
	bra.b	.lopje
.klaarnr:
	rts

addword2pf:
	swap	d0
	clr.w	d0
	moveq.l	#4-1,d7
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
	moveq.l	#0,d0
	moveq.l	#4-1,d7
.lopje:
	moveq.l	#0,d1
	move.b	(a6)+,d1
	sub.b	#'0',d1
	cmp.b	#10,d1
	blo.s	.klaar
	sub.b	#7,d1
.klaar:
	lsl.w	#4,d0
	add.b	d1,d0
	dbf	d7,.lopje
	rts
	
;************* PREFS INLADEN **************

Read_Prefs:
	bsr	C19164
Read_Prefs2:
	move.w	#2,Scr_NrPlanes		;default= 2 planes

	move.l	#CurrentAsmLine,d1
	move.l	#$000003ED,d2
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVOOpen,a6)
	move.l	d0,(Bestand-DT,a4)
	tst.l	d0
	beq.b	C18E68
	lea	(ParameterBlok-DT,a4),a0
	move.l	a0,d2
	move.l	#$00002000,d3
	move.l	(Bestand-DT,a4),d1
	move.l	(DosBase-DT,a4),a6
	jsr	(_LVORead,a6)
	lea	(ParameterBlok-DT,a4),a0
	clr.b	(a0,d0.l)
	move.l	(Bestand-DT,a4),d1
	move.l	(DosBase-DT,a4),a6
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
	bra.w	CheckForColors

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
	moveq.l	#11-1,d1
.lopje:
	lea	(HomeDirectory-DT,a4),a0
	moveq.l	#128-1,d0
.lopje2:
	move.b	(a0)+,(a1)+
	dbf	d0,.lopje2
	dbf	d1,.lopje
	movem.l	(sp)+,d0/d1/a0/a1
	rts

C18EAE:
	clr.b	(a0)
	clr.b	(a1)
	bsr	initmydirs
	addq.w	#1,a6
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	a0,d7
	move.l	(DosBase-DT,a4),a6
	move.l	#HomeDirectory,d1
	moveq.l	#-2,d2
	jsr	(_LVOLock,a6)
	move.l	d0,d1
	beq.b	C18EE6
	jsr	(_LVOCurrentDir,a6)
	move.b	#1,(B2E17E-DT,a4)
	move.l	d7,a0
	move.b	#0,(a0)+
	move.b	#$FF,(a0)
C18EE6:
	movem.l	(sp)+,d0-d7/a0-a6

;|8AB|002|FFF|B40|000|000|000|000|000|000|000|000|000|000|000|F06|
CheckForColors:
	cmp.b	#"|",(a6)	;load colors
	bne.b	C18F4A

	lea	(ScrColors-DT,a4),a0
	addq.w	#1,a6
;	moveq	#4-1,d7
	moveq	#16-1,d7	;16 kleurtjes..
C18EF8:
	moveq	#2,d6
C18EFA:
	move.b	(a6)+,d0
	cmp.b	#'\',d0
	bne.b	C18F06
	subq.w	#1,a6
	bra.b	C18F4A

C18F06:
	cmp.b	#$30,d0
	blt.b	C18F4A
	cmp.b	#$3A,d0
	blt.b	C18F2A
	bclr	#5,d0
	cmp.b	#$41,d0
	blt.b	C18F4A
	cmp.b	#$47,d0
	blt.b	C18F24
	bra.b	C18F4A

C18F24:
	sub.b	#$37,d0
	bra.b	C18F2E

C18F2A:
	sub.b	#$30,d0
C18F2E:
	move.b	d0,(1,a0)
	addq.w	#2,a0
	dbra	d6,C18EFA
	cmp.b	#$7C,(a6)
	bne.b	C18F4A
	addq.w	#1,a6
	dbra	d7,C18EF8
	move.b	#2,(B2E3CA-DT,a4)
C18F4A:
	cmp.b	#10,(a6)
	bne.b	C18F52

	addq.w	#1,a6
C18F52:
	cmp.b	#$5B,(a6)
	bne.b	CheckForScreenmode
	moveq	#0,d0
	addq.w	#1,a6
	cmp.b	#$43,(a6)
	bne.b	C18F72
	addq.w	#3,a6
	move.b	(a6)+,d0
	sub	#$0030,d0
	move	d0,(CPU_type-DT,a4)
	addq.w	#1,a6
	bra.b	C18F4A

C18F72:
	cmp.b	#$4D,(a6)
	bne.b	CheckForScreenmode
	addq.w	#3,a6
	move.b	(a6)+,d0
	sub	#$0030,d0
	move	d0,(W2E508-DT,a4)
	addq.w	#1,a6
	bra.b	C18F4A

;^40C20032|00000200|00000280|0002
CheckForScreenmode:
;	move.l	#-1,SchermMode
	cmp.b	#'^',(a6)
	bne	checkformem

	addq.w	#1,a6
	moveq	#0,d1

	bsr	RP_Ascii2Long
	
C18FC0:
	ror.l	#4,d1
	move.l	d1,(SchermMode).l
	cmp.b	#'|',d0		;'|'
	bne	checkformem
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
	move.w	d0,Scr_NrPlanes
	addq.l	#1,a6


checkformem:
.lopje:
;	btst	#6,$bfe001		; :))
;	beq.s	.leave
	cmp.w	#4,Scr_NrPlanes
	bhi.s	.lopje
.leave:
;	jsr	test_debug

	move.l	#2,_memtype	;250 kb chipmem
	move.l	#250,_memamount
	move.l	#$60000,_absmemadr
memtypeensize:
	cmp.b	#'@',(a6)
	bne.w	.geenmem

	cmp.b	#'C',1(a6)
	bne.s	.geenchip
	move.l	#2,_memtype
.geenchip:
	cmp.b	#'F',1(a6)
	bne.s	.geenfast
	move.l	#3,_memtype
.geenfast:
	cmp.b	#'P',1(a6)
	bne.s	.geenpub
	move.l	#1,_memtype
.geenpub:
	cmp.b	#'A',1(a6)
	bne.s	.geenabs
	move.l	#0,_memtype
.geenabs:
	addq.l	#2,a6
	moveq.l	#0,d0
	moveq.l	#0,d1

.lopje:
	moveq	#0,d0
	move.b	(a6)+,d0
	tst.b	d0
	beq.b	.klaarnr
	cmp.b	#10,d0
	beq.b	.klaarnr
	cmp.b	#$7C,d0		;'|'
	beq.b	.klaarnr
	sub.b	#'0',d0
	cmp.b	#9,d0
	ble.b	.dec
	sub.b	#7,d0
.dec:
	lsl.l	#4,d1
	add.l	d0,d1
	bra.b	.lopje

.klaarnr:
	move.l	d1,_memamount
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
	move.b	#0,(a0)+
	addq.l	#1,a6
	bsr	getwordfrompf
	move.w	d0,EditorFontSize
	addq.l	#1,a6

geeneditfont:

	cmp.b	#')',(a6)
	bne.s	.geensyntcols

	addq.l	#1,a6
	lea	fontcolortab,a0
	moveq.l	#8-1,d6
.lopje3:
	bsr	van_string_2_d1
	move.l	d1,(a0)+
	dbf	d6,.lopje3
	addq.l	#1,a6

.geensyntcols:


checkforbootup:
	cmp.b	#'\',(a6)+
	bne.w	C190AA
	move.l	a6,-(sp)
	lea	(BootUpString-DT,a4),a0
	move.b	#'\',(a0)+
C19092:
	cmp.b	#10,(a6)
	beq.w	C190A0
	tst.b	(a6)
	beq.w	C190A0
	move.b	(a6)+,(a0)+
	bra.w	C19092

C190A0:
	move.l	(sp)+,a6
	move.l	a6,a0
	jsr	(DATAFROMAUTO).l


C190AA:
	tst.b	(Safety-DT,a4)
	bne.b	C190C4
	tst.b	(B2E17E-DT,a4)
	bne.b	C190C4
	move.l	(DosBase-DT,a4),a6
	move.l	(CurrentDir).l,d1
	jsr	(_LVOCurrentDir,a6)
C190C4:
	rts

RP_Ascii2Long:
	moveq	#0,d0
	move.b	(a6)+,d0
	tst.b	d0
	beq.b	.C1905C
	cmp.b	#10,d0
	beq.b	.C1905C
	cmp.b	#$7C,d0
	beq.b	.C1905C
	sub.b	#$30,d0
	cmp.b	#9,d0
	ble.b	.C19052
	sub.b	#7,d0
.C19052:
	and.b	#15,d0
	add.l	d0,d1
	rol.l	#4,d1
	bra.b	RP_Ascii2Long
.C1905C:
	rts

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
	cmp.b	#$21,d0
	beq.b	change_extention
	cmp.b	#10,d0
	beq.b	C190D2
	cmp.b	#13,d0
	beq.b	C190D2
	subq.w	#1,a6
	addq.l	#4,sp
	rts

change_extention:
	lea	(S.MSG).l,a0
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

C19164:
	lea	(CurrentAsmLine-DT,a4),a0
	lea	(ENVARCAsmProP.MSG).l,a1
C1916E:
	move.b	(a1)+,(a0)+
	bne.b	C1916E
	clr.b	(a0)
	rts

C19176:
	move.l	a6,-(sp)
	bsr	C19592
	move.l	(sp)+,a6
	cmp.b	#$20,(1,a6)
	beq.b	C191D2
	moveq	#6,d0
	bsr	FileReqStuff
C1918C:
	bsr	IO_OpenFile
	move.l	(RelocStart-DT,a4),a0
	cmp.l	#$12345678,-(a0)
	beq.b	C191A2
	jmp	(ERROR_NoObject).l

C191A2:
	clr.l	(a0)
	bsr	C19814
	bsr	C19902
	moveq	#0,d0
	move	(NrOfSections-DT,a4),d0
	bne.b	C191BA
	jmp	(ERROR_NoObject).l

C191BA:
	bsr.b	C191DA
	bsr.b	C19216
	bsr	close_bestand
	bsr	C19934
	move.l	(RelocStart-DT,a4),a0
	move.l	#$12345678,-(a0)
	rts

C191D2:
	addq.l	#1,a6
	bsr	C180C4
	bra.b	C1918C

C191DA:
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
	move.l	d3,(L19212).l
	moveq	#8,d3
	move.l	#L1920E,d2
	bsr	IO_WriteFile
	movem.l	(sp)+,d2/d3
	lsl.l	#2,d3
	br	IO_WriteFile

L1920E:
	dc.l	999
L19212:
	dc.l	0

C19216:
	lea	(Writinghunkda.MSG,pc),a0
	bsr	beeldtextaf
	lea	SECTION_ABS_LOCATION-DT+4(a4),a0
	lea	SECTION_ORG_ADDRESS-DT+4(a4),a1
	lea	SECTION_TYPE_TABLE-DT+1(a4),a2
	move.l	(RelocStart-DT,a4),a3
	move.l	(RelocEnd-DT,a4),a5
	moveq	#0,d6
C19234:
	addq.w	#1,d6
	bsr	C19428
	bsr	C194CE
	move.l	a3,-(sp)
	tst.b	(a2)
	bmi.b	C1924C
	bsr	C194FA
	bsr	C19512
C1924C:
	movem.l	a0/a1,-(sp)
	move.l	#L1978E,d2
	moveq	#4,d3
	bsr	IO_WriteFile
	movem.l	(sp)+,a0/a1
	cmp	#1,d6
	bne.b	C1926E
	moveq	#0,d6
	bsr	C19376
	moveq	#1,d6
C1926E:
	bsr	C19376
	move.l	(sp)+,a6
	bsr.b	C192AC
	movem.l	a0/a1,-(sp)
	move.l	#L19792,d2
	moveq	#4,d3
	bsr	IO_WriteFile
	movem.l	(sp)+,a0/a1
	movem.l	a0/a1,-(sp)
	move.l	#L197B2,d2
	moveq	#4,d3
	bsr	IO_WriteFile
	movem.l	(sp)+,a0/a1
	addq.l	#4,a0
	addq.l	#4,a1
	addq.l	#1,a2
	cmp	(NrOfSections-DT,a4),d6
	bne.b	C19234
	rts

C192AC:
	movem.l	a0/a1/a3,-(sp)
	move.l	a6,a3
C192B2:
	cmp.l	a3,a5
	beq	C1936C
	cmp.b	(a3),d6
	bne	C1936C
	tst.b	(1,a3)
	bne	C1936C
	moveq	#-4,d0
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
	lea	(B19372,pc),a0
	move.b	(a0,d0.w),d0
	ror.l	#8,d0
	movem.l	d2/d3,-(sp)
	or.l	d3,d0
	lea	(L193E6,pc),a0
	move.l	d0,(a0)
	move.l	a0,d2
	moveq	#4,d3
	bsr	IO_WriteFile
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

C19338:
	move.l	d0,-(sp)
	lea	(L193E6,pc),a0
	move.l	d0,(a0)
	move.l	a0,d2
	moveq	#4,d3
	bsr	IO_WriteFile
	move.l	(sp)+,d0
	move.l	(sp)+,a6
C1934C:
	addq.w	#6,a6
	lea	(L193E6,pc),a0
	move.l	(a6)+,(a0)
	movem.l	d0/a6,-(sp)
	move.l	a0,d2
	moveq	#4,d3
	bsr	IO_WriteFile
	movem.l	(sp)+,d0/a6
	subq.l	#1,d0
	bne.b	C1934C
	br	C192B2

C1936C:
	movem.l	(sp)+,a0/a1/a3
	rts

B19372:
	dc.b	$84
	dc.b	$83
	dc.b	$81
	dc.b	0

C19376:
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
	bne.b	C193B6
	move.l	#$02000000,d0
C193B6:
	or.l	d3,d0
	lea	(L193E6,pc),a0
	move.l	d0,(a0)
	move.l	a0,d2
	moveq	#4,d3
	bsr	IO_WriteFile
	movem.l	(sp)+,d2/d3
	lsl.l	#2,d3
	bsr	IO_WriteFile
	lea	(L193E6,pc),a0
	move.l	(a2),(a0)
	move.l	a0,d2
	moveq	#4,d3
	bsr	IO_WriteFile
C193DE:
	move.l	a3,a2
	bsr.b	C19386
	move.l	(sp)+,a2
C193E4:
	rts

L193E6:
	dc.l	0

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
	lea	(L1947A,pc),a0
	move.l	d3,(4,a0)
	move.l	a0,d2
	moveq	#8,d3
	bsr	IO_WriteFile
	movem.l	(sp)+,d2/d3
	lsl.l	#2,d3
	bsr	IO_WriteFile
C19472:
	move.l	a3,a2
	bsr.b	C19438
	move.l	(sp)+,a2
C19478:
	rts

L1947A:
	dc.l	1000
	dc.l	0

C19482:
	lea	(Writinghunkda.MSG,pc),a0
	bsr	beeldtextaf
	lea	SECTION_ABS_LOCATION-DT+4(a4),a0
	lea	SECTION_ORG_ADDRESS-DT+4(a4),a1
	lea	SECTION_TYPE_TABLE-DT+1(a4),a2
	move.l	(RelocStart-DT,a4),a3
	move.l	(RelocEnd-DT,a4),a5
	moveq	#0,d6
C194A0:
	addq.w	#1,d6
	bsr.b	C194CE
	tst.b	(a2)
	bmi.b	C194AC
	bsr.b	C194FA
	bsr.b	C19512
C194AC:
	movem.l	a0/a1,-(sp)
	move.l	#L197B2,d2
	moveq	#4,d3
	bsr	IO_WriteFile
	movem.l	(sp)+,a0/a1
	addq.l	#4,a0
	addq.l	#4,a1
	addq.l	#1,a2
	cmp	(NrOfSections-DT,a4),d6
	bne.b	C194A0
	rts

C194CE:
	movem.l	a0/a1,-(sp)
	lea	(L19796,pc),a0
	moveq	#0,d1
	move.b	(a2),d1
	and.b	#$3C,d1
	add	d1,d1
	add	d1,a0
	moveq	#3,d3
	add.l	(a1),d3
	lsr.l	#2,d3
	move.l	d3,(4,a0)
	move.l	a0,d2
	moveq	#8,d3
	bsr	IO_WriteFile
	movem.l	(sp)+,a0/a1
	rts

C194FA:
	movem.l	a0/a1,-(sp)
	move.l	(a0),d2
	moveq	#3,d3
	add.l	(a1),d3
	moveq	#-4,d1
	and.l	d1,d3
	bsr	IO_WriteFile
	movem.l	(sp)+,a0/a1
	rts

C19512:
	movem.l	a0/a1,-(sp)
C19516:
	cmp.l	a3,a5
	beq.b	C1958C
	cmp.b	(a3),d6
	bne.b	C1958C
	tst.b	(1,a3)
	bne.b	C1952A
	addq.w	#6,a3
	addq.w	#4,a3
	bra.b	C19516

C1952A:
	move.l	#L197AE,d2
	moveq	#4,d3
	bsr	IO_WriteFile
	lea	(L197B6,pc),a0
C1953A:
	movem.l	a0/a3,-(sp)
	moveq	#0,d5
	move	(a3),d1
C19542:
	addq.l	#1,d5
	addq.w	#6,a3
	cmp.l	a5,a3
	beq.b	C1954E
	cmp	(a3),d1
	beq.b	C19542
C1954E:
	move.l	d5,(a0)
	moveq	#0,d0
	move.b	d1,d0
	subq.l	#1,d0
	move.l	d0,(4,a0)
	move.l	a0,d2
	moveq	#8,d3
	bsr	IO_WriteFile
	movem.l	(sp)+,a0/a3
C19566:
	addq.w	#2,a3
	move.l	a3,d2
	moveq	#4,d3
	move.l	a0,-(sp)
	bsr	IO_WriteFile
	move.l	(sp)+,a0
	addq.w	#4,a3
	subq.w	#1,d5
	bne.b	C19566
	cmp.l	a5,a3
	beq.b	C19582
	cmp.b	(a3),d6
	beq.b	C1953A
C19582:
	clr.l	(a0)
	move.l	a0,d2
	moveq	#4,d3
	bsr	IO_WriteFile
C1958C:
	movem.l	(sp)+,a0/a1
	rts

C19592:
	move.l	(RelocStart-DT,a4),a0
	cmp.l	#$12345678,-(a0)
	beq.b	C195A4
	jmp	(ERROR_NoObject).l

C195A4:
	clr.l	(a0)
	lea	SECTION_ABS_LOCATION-DT+4(a4),a0
	lea	SECTION_ORG_ADDRESS-DT+4(a4),a1
	lea	SECTION_TYPE_TABLE-DT+1(a4),a2
	lea	SECTION_OLD_ORG_ADDRESS-DT+4(a4),a5
	lea	(L2A0B6-DT,a4),a3
	clr.b	(a3)+
	move	(NrOfSections-DT,a4),d0
	bne.b	C195C8
	jmp	(ERROR_NoObject).l

C195C8:
	subq.w	#1,d0
	moveq	#0,d6
	moveq	#0,d5
C195CE:
	move.l	(a1,d5.w),d1
	bne.b	C195DA
	addq.w	#4,d5
	clr.b	(a3)+
	bra.b	C19616

C195DA:
	clr.l	(a1,d5.w)
	move.l	d1,(a1,d6.w)
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
	move.b	(a2,d1.w),d3
	clr.b	(a2,d1.w)
	move.b	d3,(a2,d2.w)
	addq.w	#1,d2
	move.b	d2,(a3)+
	addq.w	#4,d5
	addq.w	#4,d6
C19616:
	dbra	d0,C195CE
	lsr.w	#2,d6
	move	d6,(NrOfSections-DT,a4)
	move.l	(RelocStart-DT,a4),a0
	move.l	(RelocEnd-DT,a4),a1
	lea	(L2A0B6-DT,a4),a2
C1962C:
	cmp.l	a0,a1
	beq.b	C1965A
	moveq	#0,d0
	move.b	(a0),d0
	move.b	(a2,d0.w),d1
	beq.b	C19654
	move.b	d1,(a0)+
	moveq	#0,d0
	move.b	(a0),d0
	beq.b	C1964E
	move.b	(a2,d0.w),d1
	beq.b	C19654
	move.b	d1,(a0)+
	addq.l	#4,a0
	bra.b	C1962C

C1964E:
	move.b	d0,(a0)+
	addq.w	#8,a0
	bra.b	C1962C

C19654:
	jmp	(ERROR_Relocationmade).l

C1965A:
	bsr.b	C196D0
	bsr.b	C1966A
	move.l	(RelocStart-DT,a4),a0
	move.l	#$12345678,-(a0)
	rts

C1966A:
	lea	(L2A0B6-DT,a4),a1
	move.l	(LabelStart-DT,a4),a2
	moveq	#$40,d5
C19674:
	moveq	#$30,d6
C19676:
	move.l	(a2)+,a3
	bsr.b	C19694
	addq.b	#1,d6
	moveq	#$30,d0
	add	(Label2Entry-DT,a4),d0
	cmp.b	d0,d6
	bne.b	C19676
	addq.b	#1,d5
	moveq	#$40,d0
	add	(Label1Entry-DT,a4),d0
	cmp.b	d0,d5
	bne.b	C19674
	rts

C19694:
	move.l	a3,-(sp)
	beq.b	C196AA
	move.l	(a3),a3
	bsr.b	C19694
	move.l	(sp),a0
	addq.l	#8,a0
	bsr.b	C196AE
	move.l	(sp),a3
	move.l	(4,a3),a3
	bsr.b	C19694
C196AA:
	move.l	(sp)+,a3
	rts

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

C196D0:
	lea	(L2A0B6-DT,a4),a1
	lea	(SectionTreePtr-DT,a4),a2
C196D8:
	move.l	(a2),d0
	beq.b	C196F6
	move.l	a2,-(sp)
	move.l	d0,a2
	bsr.b	C196D8
	addq.w	#4,a2
	bsr.b	C196D8
	addq.w	#4,a2
C196E8:
	tst	(a2)+
	bpl.b	C196E8
	move	(a2),d0
	move.b	(a1,d0.w),d0
	move	d0,(a2)+
	move.l	(sp)+,a2
C196F6:
	rts

C196F8:
	move.l	a6,-(sp)
	bsr	C19592
	move.l	(sp)+,a6
	cmp.b	#$20,(1,a6)
	beq.b	C19772
	moveq	#5,d0
	bsr	FileReqStuff
C1970E:
	bsr	IO_OpenFile
	move.l	(RelocStart-DT,a4),a0
	cmp.l	#$12345678,-(a0)
	beq.b	C19724
	jmp	(ERROR_NoObject).l

C19724:
	clr.l	(a0)
	bsr	C197BE
	bsr	C19902
	moveq	#0,d0
	move	(NrOfSections-DT,a4),d0
	bne.b	C1973C
	jmp	(ERROR_NoObject).l

C1973C:
	move.l	d0,(L19782).l
	subq.l	#1,d0
	move.l	d0,(L1978A).l
	moveq	#$14,d3
	move.l	#L1977A,d2
	bsr	IO_WriteFile
	bsr	C19966
	bsr	C19482
	bsr	close_bestand
	bsr	C19934
	move.l	(RelocStart-DT,a4),a0
	move.l	#$12345678,-(a0)
	rts

C19772:
	addq.l	#1,a6
	bsr	C180C4
	bra.b	C1970E

L1977A:
	dc.l	1011
	dc.l	0
L19782:
	dcb.l	2,0
L1978A:
	dc.l	0
L1978E:
	dc.l	$000003EF
L19792:
	dc.l	0
L19796:
	dc.l	$000003E9
	dc.l	0
	dc.l	$000003EA
	dc.l	0
	dc.l	$000003EB
	dc.l	0
L197AE:
	dc.l	$000003EC
L197B2:
	dc.l	$000003F2
L197B6:
	dcb.l	2,0

C197BE:
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
	jmp	(ERROR_NoObject).l

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
	sub	#6,a0
	sub	#6,a1
	bra.b	C197F4

C19812:
	rts

C19814:
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
	move.l	(2,a1),d3
	move.l	(6,a1),d4
	addq.w	#4,a1
	move	d1,(a0)
	move	d0,(a1)
	move	d0,d1
C1987C:
	move.l	d2,(2,a1)
	move.l	d3,(2,a0)
	move.l	d4,(6,a0)
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
	move.l	(2,a0),d3
	move.l	(6,a0),d4
	subq.w	#4,a1
	move	d1,(a0)
	move	d0,(a1)
	move	d0,d1
	move.l	d2,(2,a0)
	move.l	d3,(2,a1)
	move.l	d4,(6,a1)
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
	rts

C19902:
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
	ENDC

	moveq	#0,d0
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

C19932:
	rts

C19934:
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

C19966:
	lea	(Writinghunkle.MSG,pc),a0
	bsr	beeldtextaf
	move	(NrOfSections-DT,a4),d0
	subq.w	#1,d0
	lea	SECTION_ORG_ADDRESS-DT+4(a4),a1
	lea	SECTION_TYPE_TABLE-DT+1(a4),a2
	lea	(ParameterBlok-DT,a4),a3
	move.l	a3,d2
C19982:
	move.b	(a2)+,d3
	move.l	(a1)+,d1
	addq.l	#3,d1
	lsr.b	#1,d3
	roxr.l	#1,d1
	lsr.b	#1,d3
	roxr.l	#1,d1
	move.l	d1,(a3)+
	dbra	d0,C19982
	move.l	a3,d3
	sub.l	d2,d3
	br	IO_WriteFile

C1999E:
	cmp.b	#$20,(a6)
	beq.b	C199C4
	moveq	#9,d0
	bsr	FileReqStuff
C199AA:
	move.l	(DosBase-DT,a4),a6
	move.l	#CurrentAsmLine,d1
	jsr	(_LVODeleteFile,a6)
	tst	d0
	bne.b	C199C2
	jmp	(ERROR_FileError).l

C199C2:
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

Enter_debugger:
	lea	(B30071-DT,a4),a0
C199E8:
	move.b	(a6)+,(a0)+
	tst.b	(a6)
	bne.b	C199E8
	clr.b	(a0)
	tst	(AssmblrStatus).l
	bne.b	.C19A00
	bsr	C1A0B8
	bsr	C1A11A
.C19A00:
	lea	(L2CF4C-DT,a4),a0
	move.l	#eop_irq_routine,-(a0)
	move.l	a0,(SSP_base-DT,a4)
	lea	(L2DF4C-DT,a4),a0
	move.l	#eop_irq_routine,-(a0)
	move.l	a0,(USP_base-DT,a4)
	move.l	(sourcestart-DT,a4),(TraceLinePtr-DT,a4)
	move.l	#1,(TraceLineNr-DT,a4)
	clr	(MON_EDIT_POSITION-DT,a4)
	bsr	MON_CLEARCACH
	lea	(MON_DIS_TYPES,pc),a0
	move.l	a0,(MON_TYPE_PTR-DT,a4)
DEBUG_TYPECHANGE:
	lea	(DBTypeSource,pc),a0
	btst	#0,(PR_ShowSource).l
	bne.b	.IS_SOURCE
	lea	(DBTypeMem,pc),a0
.IS_SOURCE:
	move.l	a0,(DBTypePtr-DT,a4)

	btst	#0,(PR_ShowSource).l
	beq.b	.NO_SOURCE1
	btst	#SB2_INDEBUGMODE,(SomeBits2-DT,a4)
	bne.b	.NO_SOURCE2
	jsr	(C2AF6).l
	bset	#SB2_INDEBUGMODE,(SomeBits2-DT,a4)
	moveq	#$30,d0
	bsr	C17412
	movem.l	d0-d7/a0-a6,-(sp)
	lea	(B30071-DT,a4),a6
	tst.b	(a6)
	beq.b	.C19A86
	jsr	GETNUMBERAFTEROK
	move.l	d0,(pcounter_base-DT,a4)
.C19A86:
	movem.l	(sp)+,d0-d7/a0-a6
	jmp	(CommandlineInputHandler).l

.NO_SOURCE1:
	move.l	(MEM_DIS_DUMP_PTR-DT,a4),(pcounter_base-DT,a4)
.NO_SOURCE2:
	bset	#1,(SomeBits3-DT,a4)	;???
	lea	(DEBUG_NEXTLINE,pc),a0
	move.l	a0,(Error_Jumpback-DT,a4)
	tst.b	(debug_FPregs-DT,a4)
	beq.w	C19AB6
C19AB6:
	jsr	(Change2Debugmenu).l
	move.b	#$FF,(B2BEB8-DT,a4)
DEBUG_REDRAW:
	bset	#SB3_COMMANDMODE,(SomeBits3-DT,a4)	;in commandmode
	move	(ScreenHight-DT,a4),d0
	subq.w	#2,d0
	sub	(DEBUG_NUMOFADDS-DT,a4),d0
	sub	(W2FCEE-DT,a4),d0
	btst	#0,(PR_NoDisasm).l
	beq.b	.noDis
	subq.w	#1,d0
.noDis:
	jsr	(OPED_SETNBOFFLINES).l
	bsr	SENDCHARDELSCR
	moveq	#0,d0
	bsr	SENDONECHARNORMAL

	move.l	(DBTypePtr-DT,a4),a0
	add	(a0),a0		;DBType_Border
	jsr	(a0)

	jsr	Show_Cursor
	bsr	open_debug_win
;	bsr	open_output_win

;	bsr	INVERTCURSOR3

DEBUG_NEXTLINE:
	tst.l	(LoopPtr-DT,a4)
	beq.b	.noLoop
	move.l	(LoopPtr-DT,a4),a1
	clr.l	(LoopPtr-DT,a4)
	bsr	DEBUG_ADD_BRKPT
	br	DEBUG_NO_BREAK_PT

.noLoop:
	tst.b	(Animate-DT,a4)
	beq	noAnimate
	bsr	C1A5FE
	tst	d0
	beq.b	.run
	move.b	#0,(Animate-DT,a4)
	lea	(Conditionbrea.MSG).l,a0
	bsr	printTextInMenuStrip
	bclr	#SB1_WINTITLESHOW,(SomeBits-DT,a4)
	bra.w	noAnimate

.run:
	bsr	messages_get
	beq.b	Debug_Animate
	move.b	#0,(Animate-DT,a4)
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

;	move	(Cursor_col_pos-DT,a4),-(sp)
;	move	(cursor_row_pos-DT,a4),-(sp)
;	clr	(cursor_row_pos-DT,a4)
;	move	(Scr_br_chars-DT,a4),(Cursor_col_pos-DT,a4)
;	sub	#1,(Cursor_col_pos-DT,a4)
;	jsr	Show_Cursor

	move.w	#3,adryoff	;reset y offset voor regs
	bsr	_druk_af_debug_regs

;	jsr	Show_Cursor
;	move	(sp)+,(cursor_row_pos-DT,a4)
;	move	(sp)+,(Cursor_col_pos-DT,a4)

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
	br	.C19BE6

.C19BD8:
	bsr	messages_get
	tst	d0
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

;	move	(Cursor_col_pos-DT,a4),-(sp)
;	move	(cursor_row_pos-DT,a4),-(sp)
;	clr	(cursor_row_pos-DT,a4)
;	move	(Scr_br_chars-DT,a4),(Cursor_col_pos-DT,a4)
;	sub	#1,(Cursor_col_pos-DT,a4)
;	jsr	Show_Cursor

	move.w	#3,adryoff	;reset y offset voor regs
	bsr	_druk_af_debug_regs

;	jsr	Show_Cursor
;	move	(sp)+,(cursor_row_pos-DT,a4)
;	move	(sp)+,(Cursor_col_pos-DT,a4)

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
	bls.w	C1A0F0
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
	beq	DEBUG_ZAPWATCH
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
	beq	.DEBUG_EditMem
	cmp	#$0057,d0
	beq.b	DEBUG_SetBreakpointhere
	cmp	#$0064,d0
	beq.b	DEBUG_ANIMATE
	cmp	#$0065,d0
	beq.b	DEBUG_SkipInstruction
	cmp	#$0071,d0
	beq	DEBUG_AddCondition
	cmp	#$007A,d0
	beq	blablacursor1
	br	.GET_ANOTHER

.DEBUG_EditMem:
	movem.l	d0-a6,-(sp)
	jsr	mon_enterhexmon
	movem.l	(sp)+,d0-a6
	br	.GET_ANOTHER

DEBUG_SkipInstruction:
;	moveq	#0,d0
	move.l	(TraceLineNr-DT,a4),d0
	addq.l	#1,d0
	subq.l	#1,d0
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
	move.b	#1,(Animate-DT,a4)
	br	DEBUG_SINGLE_STEP

DEBUG_SetBreakpointhere:
	move.l	(pcounter_base-DT,a4),(LoopPtr-DT,a4)
	moveq	#1,d0
	br	com_singlestep

DEBUG_ChangefromDx2FPx:
;	bsr	SENDCHARDELSCR
;	moveq	#0,d0
;	bsr	SENDONECHARNORMAL
;	move.l	(DBTypePtr-DT,a4),a0
;	add	(a0),a0
;	jsr	(a0)
;	jsr	Show_Cursor
	tst.b	(debug_FPregs-DT,a4)
	beq.b	C19DA8

	clr.b	(debug_FPregs-DT,a4)
;	move	#68,(breedte_editor_in_chars-DT,a4)
;	bsr	resize_db_win

	bsr	resize_db_win

	rts

C19DA8:
;	move	#60,(breedte_editor_in_chars-DT,a4)
	move.b	#1,(debug_FPregs-DT,a4)
	bsr	resize_db_win

	rts

DEBUG_TYPECHANGE_MAIN:
	move.b	#$15,(B2BEB8-DT,a4)
	move.l	d0,-(sp)
	move.l	(Comm_menubase-DT,a4),d0
	move.b	#MT_COMMAND,(menu_tiepe-DT,a4)
	jsr	(Change_2menu_d0).l
	move.l	(sp)+,d0
	bclr	#1,(SomeBits3-DT,a4)	;???
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
	moveq.l	#0,d1
	move	(NrOfLinesInEditor-DT,a4),d1
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
	move.l	(pcounter_base-DT,a4),-(sp)
	move.l	(TraceLinePtr-DT,a4),-(sp)
	move.l	(TraceLineNr-DT,a4),-(sp)
	move.l	(DBTypePtr-DT,a4),a0
	add	(4,a0),a0
	jsr	(a0)
	cmp.b	#$1B,d0
	bne.b	C19E64
	move.l	(sp),(TraceLineNr-DT,a4)
	move.l	(4,sp),(TraceLinePtr-DT,a4)
	move.l	(8,sp),(pcounter_base-DT,a4)
C19E64:
	add	#12,sp
	br	DEBUG_REDRAW

DEBUG_BP_MARK:
	move.l	(pcounter_base-DT,a4),-(sp)
	move.l	(TraceLinePtr-DT,a4),-(sp)
	move.l	(TraceLineNr-DT,a4),-(sp)
	move.l	(DBTypePtr-DT,a4),a0
	add	(4,a0),a0
	jsr	(a0)
	cmp.b	#$1B,d0
	beq.b	C19E90
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
	jsr	(messages_get).l
	jsr	(GETKEYNOPRINT).l
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
	move.l	d0,(pcounter_base).l
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
	moveq.l	#0,d1
	move	(NrOfLinesInEditor-DT,a4),d1
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
	moveq	#0,d0
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
	moveq	#0,d0
	move.l	(TraceLineNr-DT,a4),d0
	addq.l	#1,d0
	br	C19F40

C19FEE:
	moveq	#0,d0
	move.l	(TraceLineNr-DT,a4),d0
	subq.l	#1,d0
	br	C19F40

C19FFA:
	moveq	#0,d0
	move.l	(TraceLineNr-DT,a4),d0
	moveq	#0,d1
	move	(NrOfLinesInEditor-DT,a4),d1
	add.l	d1,d0
	br	C19F40

C1A00C:
	moveq	#0,d0
	move.l	(TraceLineNr-DT,a4),d0
	moveq	#0,d1
	move	(NrOfLinesInEditor-DT,a4),d1
	sub.l	d1,d0
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
	jsr	(Get_NextChar).l
	move.b	#$3D,(a6)+
	move.b	#$20,(a6)+
	clr.b	(a6)
	jsr	(C13494).l
	move.l	(sp)+,a0
	move.l	a1,a5
	bsr	GetAdrFromTitle
	swap	d0
	cmp.b	#2,(OpperantSize-DT,a4)
	beq.b	C1A09E
	move	d0,(a5)+
C1A09E:
	swap	d0
	move	d0,(a5)+
	rts

blablacursor1:
	bsr.b	C1A11A
	jsr	Show_Cursor
	br	DEBUG_REDRAW

DEBUG_ZAPWATCH:
	bsr.b	C1A0B8
	jsr	Show_Cursor
	br	DEBUG_REDRAW

C1A0B8:
	lea	(watch_table,pc),a0
	moveq	#7,d0
C1A0BE:
	clr.b	(a0)
	addq.w	#8,a0
	addq.w	#8,a0
	dbra	d0,C1A0BE
	clr	(DEBUG_NUMOFADDS-DT,a4)
	rts

DEBUG_DELWATCH:
	sub.b	#$47,d0
	ext.w	d0
	lsl.w	#4,d0
	lea	(watch_table,pc),a0
	tst.b	(a0,d0.w)
	beq.b	C1A0E8
	clr.b	(a0,d0.w)
	subq.w	#1,(DEBUG_NUMOFADDS-DT,a4)
C1A0E8:
	jsr	Show_Cursor
	br	DEBUG_REDRAW

C1A0F0:
	sub.b	#$72,d0
	ext.w	d0
	lsl.w	#4,d0
	lea	(L1A3F4,pc),a0
	lea	(L1A474,pc),a1
	tst.b	(a0,d0.w)
	beq.b	C1A112
	clr.b	(a0,d0.w)
	clr.b	(a1,d0.w)
	subq.w	#1,(W2FCEE-DT,a4)
C1A112:
	jsr	Show_Cursor
	br	DEBUG_REDRAW

C1A11A:
	lea	(L1A3F4,pc),a0
	moveq	#7,d0
C1A120:
	clr.b	(a0)
	clr.b	($0080,a0)
	addq.w	#8,a0
	addq.w	#8,a0
	dbra	d0,C1A120
	clr	(W2FCEE-DT,a4)
	rts

DEBUG_AddCondition:
	move	(W2FCEE-DT,a4),d0
	cmp	#8,d0
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
	lea	(Comparesonval.MSG,pc),a0
	bclr	#SB2_A_XN_USED,(SomeBits2-DT,a4)
	bset	#SB2_MATH_XN_OK,(SomeBits2-DT,a4)
	bsr	GetAdrFromTitle
	move.l	d0,d3
	lea	(CurrentAsmLine-DT,a4),a6
	bsr.b	C1A1AC
	jsr	Show_Cursor
	add	#1,(W2FCEE-DT,a4)
	br	DEBUG_REDRAW

C1A192:
	move.l	(L2F154-DT,a4),a0
	move.b	#0,(a0)
	rts

C1A19C:
	lea	(L1A3F4,pc),a0
	lea	(L1A4F4,pc),a1
	lea	(L1A534,pc),a2
	bsr.b	C1A228
	rts

C1A1AC:
	lea	(L1A474,pc),a0
	lea	(L1A514,pc),a1
	lea	(L1A53C,pc),a2
	bsr.b	C1A228
	moveq	#0,d1
	bsr	C1A240
	rts

C1A1C2:
	move.l	(MainWindowHandle-DT,a4),a1
	bset	#0,($0019,a1)
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
	bclr	#0,($0019,a1)
	rts

C1A220:
	addq.w	#8,a0
	addq.w	#8,a0
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
	jsr	Show_Cursor
	addq.w	#1,(DEBUG_NUMOFADDS-DT,a4)
	br	DEBUG_REDRAW

C1A282:
	lea	(BufferFull.MSG,pc),a0
	bsr	printTextInMenuStrip
	rts

C1A28C:
	lea	(watch_table,pc),a0
	lea	(L1A3CC,pc),a1
	lea	(L1A3EC,pc),a2
	bra.b	C1A2A2

C1A29A:
	addq.w	#8,a0
	addq.w	#8,a0
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
	bset	#0,($0019,a1)
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
	bclr	#0,($0019,a1)
	or.b	d1,d3
	bclr	#SB2_A_XN_USED,(SomeBits2-DT,a4)
	beq.b	C1A344
	or.b	#$80,d3
C1A344:
	move.b	d3,(a2)
	rts

L1A348:
	dc.l	0
watch_table:
	dcb.l	$00000020,0
L1A3CC:
	dcb.l	8,0
L1A3EC:
	dcb.l	2,0
L1A3F4:
	dcb.l	$00000020,0
L1A474:
	dcb.l	$00000020,0
L1A4F4:
	dcb.l	8,0
L1A514:
	dcb.l	8,0
L1A534:
	dcb.l	2,0
L1A53C:
	dcb.l	2,0

;************* DEBUG WINDOOWTJE ****************

Debug_WindowTags:
dw_x:
    DC.L    WA_Left,0		;x
dw_y:
    DC.L    WA_Top,32	;y
dw_br:
    DC.L    WA_Width,32	;br
dw_hg:
    DC.L    WA_Height,32	;hg
    
    DC.L    WA_IDCMP,IDCMP_NEWSIZE|IDCMP_MOUSEBUTTONS|IDCMP_ACTIVEWINDOW	;|IDCMP_CLOSEWINDOW
    DC.L    WA_Flags,WFLG_DEPTHGADGET|WFLG_DRAGBAR|WFLG_GIMMEZEROZERO		;|WFLG_CLOSEGADGET
    DC.L    WA_Title,Debug_WTitle
Debug_SC:
    DC.L    $80000079,0
    DC.L    $00000000

Debug_WTitle:
    DC.B    'Debugging.',0
    CNOP    0,2

Debug_adrtxt:
db_pens:
	DC.B	1,0
	DC.B	1
	DC.B	0
	DC.W	3		;x
adryoff:
	dc.w	3		;y
	DC.L	Editor_Font	;xhelvetica11
adrtxtptr:
	DC.L	adrtxtbuf
	DC.L	0

adrtxtbuf:
	dc.b	"00000000",0
	dc.b	"++++++++",0

	cnop	0,4

Debug_Text:
	DC.B	1,0
	DC.B	1
	DC.B	0
	DC.W	3,3
	DC.L	Editor_Font
debtxt:
	DC.L	Debug_IText
	DC.L	0


Debug_IText:
	DC.B    ' A0: --------',0
	DC.B    ' A1: --------',0
	DC.B    ' A2: --------',0
	DC.B    ' A3: --------',0
	DC.B    ' A4: --------',0
	DC.B    ' A5: --------',0
	DC.B    ' A6: --------',0
	DC.B    ' A7: --------',0
	dc.b	'SSP= --------',0
	dc.b	'USP= --------',0
	dc.b	' SR= xxxxPL=0',0
	dc.b	'  xx xx XNZVC',0	;T1 S1 XNZVC
	dc.b	'  PC=--------',0
	dc.b	' VBR=--------',0
	dc.b	'FPSR=--------',0
	dc.b	' PCR=xxxxxxxx',0


DebugDx_IText
	DC.B    ' D0: 00000000',0
	DC.B    ' D1: 00000000',0
	DC.B    ' D2: 00000000',0
	DC.B    ' D3: 00000000',0
	DC.B    ' D4: 00000000',0
	DC.B    ' D5: 00000000',0
	DC.B    ' D6: 00000000',0
	DC.B    ' D7: 00000000',0

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

db_imagestr:
	dc.w    0		0	;offset x
	dc.w    0		2	;offset y
	dc.w    40		4	;breedte 
	dc.w    100		6	;hoogte plaatje
	dc.w    2		8	;nr planes
	dc.l    smallasmprologo	10	;bitmap ptr
	dc.b    3		14
	dc.b    0		15
	dc.l    0		16


	cnop	0,4
debug_winbase:	dc.l	0
debug_rp:	dc.l	0
debug_msg_port:	dc.l	0

db_type:	dc.w	0	;0=norm 1=fp


resize_db_win:
	movem.l	d0-a6,-(sp)
	move.l	IntBase,a6
	move.l  debug_winbase,a0
	cmp.l	#0,a0
	beq.w	.isdicht

	move.l  debug_msg_port,86(a0)

	move.w	(debug_FPregs-DT,a4),d0
	cmp.w	db_type,d0
	beq.w	.klaar
	
	move.l  debug_winbase,a0
	move.w	4(a0),d0		;x
	move.w	6(a0),d1		;y


	move.w	(EFontSize_x-DT,a4),d2
	mulu.w	#13,d2
	add.w	(Win_BorHor-DT,a4),d2
	add.w	#6,d2	;marge
	
;	move.w	#6+13*FontSize_x+8,d2		;w

	moveq	#23,d4
	cmp.w	#PB_060,(ProcessorType-DT,a4)
	blo.s	.geen060Plus
	addq	#1,d4
.geen060Plus:
	move.w	(EFontSize_y-DT,a4),d3
	mulu.w	d4,d3	;??
	add.w	(Win_BorVerT-DT,a4),d3
	add.w	#6,d3	;marge

;	move.w	#6+22*FontSize_y+titlesize,d3	;h

	move.w	(EFontSize_x-DT,a4),d4
	mulu.w	#8,d4

	move.w	(debug_FPregs-DT,a4),db_type
	tst.w	db_type
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
	move.l	debug_msg_port,a0
	jsr     _LVOGetMsg(a6)
	tst.l	d0
	bne.s	.teste

	move.l	debug_msg_port,a0
	jsr     _LVOWaitPort(a6)
	bra.b	.niet_klaar

;nog testen op newsize
.teste:
	move.l	d0,a5
	move.l	d0,a1
	jsr	_LVOReplyMsg(a6)

	move.l	20(a5),d0	;class
	and.l	#NEWSIZE,d0
	beq.s	.niet_klaar	;wachten tot newsize..	
	
	bsr	drukdata_regs

	bsr	teken_logootje_enzo

.klaar:
	move.l  debug_winbase,a0
	move.l  (KEY_PORT-DT,a4),86(a0)

.isdicht:
	movem.l	(sp)+,d0-a6
	rts


teken_logootje_enzo:
;	jsr	test2
	move.l	debug_winbase,a0

	moveq.l	#0,d2
	move.b	54(a0),d2	;br
	add.b	56(a0),d2	;bl
	
	moveq.l	#0,d3
	move.b	55(a0),d3	;bt
	add.b	57(a0),d3	;bb

	move.w	8(a0),d4	;brwin
	move.w	10(a0),d5	;hgwin
	sub.w	d2,d4
	sub.w	d3,d5

;	move.w	(Win_BorVer-DT,a4),d4

	move.l  (GfxBase-DT,a4),a6
	move.l	debug_rp,a1

	move.w	d4,d0		;xmin

	tst.w	db_type
	beq.s	.xxx

	move.w	(EFontSize_x-DT,a4),d6
	mulu.w	#8,d6

	sub.w	d6,d0
.xxx:
	sub.w	#2,d0
	move.w	#0,d1		;ymin
	move.w	d0,d2		;xmax
	add.w	#2,d2
	move.w	d5,d3		;ymax

	jsr	_LVOEraseRect(a6)


	move.l  GadToolsBase,a6
	
	
	move.l	(MainVisualInfo-DT,a4),PW_NR+4
	move.l  (MainVisualInfo-DT,a4),PW_IR+4

	move.l	debug_rp,a0
	lea.l   PW_NR,a1
	move.w  #0,d0		;x
	move.w  #0,d1		;y
	move.w	d4,d2
	move.w	d5,d3
	jsr     _LVODrawBevelBoxA(a6)

	
	tst.w	db_type
	beq.w	.nomore

	move.w	(EFontSize_x-DT,a4),d4
	mulu.w	#14,d4
	move.w	(EFontSize_y-DT,a4),d5
	mulu.w	#8,d5
	add.w	#6,d5	;marge
	

	move.l	debug_rp,a0
	lea.l   PW_NR,a1
	move.w  d4,d0		;x
	move.w  d5,d1		;y
	jsr     _LVODrawBevelBoxA(a6)

	subq.l	#1,d4
	subq.l	#1,d5

	move.l	debug_rp,a0
	lea.l   PW_IR,a1
	move.w  d4,d0		;x
	move.w  d5,d1		;y
	jsr     _LVODrawBevelBoxA(a6)

	move.l	(GfxBase-DT,A4),a6
	move.l	debug_rp,a1

	moveq.l	#2,d0
	jsr	_LVOSetAPen(a6)

	addq.l	#3,d4
	addq.l	#3,d5

	move.w  d4,d0		;x
	move.w  d5,d1		;y
	sub.w	#3,d2
	sub.w	#3,d3
	jsr     _LVORectFill(a6)


	move.w	(EFontSize_x-DT,a4),d0
	lsl.w	#3,d0	;8 letters
	move.w	(EFontSize_y-DT,a4),d1
	mulu.w	#15,d1

	sub.w	#40,d0
	bpl.s	.nix1
	moveq.l	#0,d0
.nix1
	sub.w	#100,d1
	bpl.s	.nix2
	moveq.l	#0,d1
.nix2:
	lsr.w	#1,d0
	lsr.w	#1,d1

	add.l	d0,d4	;x
	add.l	d1,d5	;y

        move.l  debug_rp,a0
	move.l	IntBase,a6
	lea	db_imagestr(pc),a1
	move.w	d4,d0	;x-offset
	move.w	d5,d1	;y-offset
	jsr     (_LVODrawImage,a6)        	; ***
.nomore:
	rts

open_debug_win:
	bsr	close_debug_win		;voor de zekerheid..

	movem.l	d0-a6,-(sp)

	move.l	dw_x+4,d0
	tst.l	d0
	bne.s	.algoed
	move.l	(BreedteScherm).l,d0

	move.w	(EFontSize_x-DT,a4),d1
	mulu.w	#13,d1
	add.w	(Win_BorHor-DT,a4),d1
	add.w	#6,d1		;marge

	sub.l	d1,d0
	sub.l	#16,d0		;16 puntjes van de linker kant
	move.l	d0,dw_x+4

	move.l	d1,dw_br+4

	moveq	#23,d4
	cmp.w	#PB_060,(ProcessorType-DT,a4)
	blo.s	.geen060Plus
	addq	#1,d4
.geen060Plus:
	move.w	(EFontSize_y-DT,a4),d1
	mulu.w	d4,d1
;	mulu.w	#24,d1
	add.w	(Win_BorVerT-DT,a4),d1
	add.w	#6,d1		;marge
	move.l	d1,dw_hg+4
	
	tst.w	(debug_FPregs-DT,a4)
	beq.s	.nono

	move.w	(EFontSize_x-DT,a4),d1
	mulu.w	#6,d1

	sub.l	d1,d0
	move.l	d0,dw_x+4
	add.l	d0,dw_br+4
	
.algoed:
.nono:
	move.l	ScreenBase,Debug_SC+4
	move.l  IntBase,a6
	sub.l	a0,a0
	lea.l	Debug_WindowTags,a1
	jsr	_LVOOpenWindowTagList(a6)
	move.l	d0,debug_winbase

	move.l	d0,a0
	move.l	($0032,a0),debug_rp

	move.l  86(a0),debug_msg_port

	bsr	teken_logootje_enzo
	

	move.l	debug_winbase,a0
	move.l  (KEY_PORT-DT,a4),86(a0)

	move.l  IntBase,a6
	move.l	(MainWindowHandle-DT,a4),a0
	jsr	(_LVOActivateWindow,a6)	; ***

;	canvaswin->UserPort = userport


	bsr	drukdata_regs
	bsr	druk_regs

	movem.l	(sp)+,d0-a6
	rts


Debug_check_msg:
	movem.l	d0-a6,-(sp)

	move.l	d0,a0		;Msg
	move.l	20(a0),d0	;class
	move.l	24(a0),d1	;code

	and.l	#IDCMP_MOUSEBUTTONS|IDCMP_ACTIVEWINDOW,d0 ;40208 |IDCMP_CLOSEWINDOW
	beq.s	.NoMsgInBase

;	move.l	d0,d3
;	and.l	#IDCMP_CLOSEWINDOW,d3
;	beq.s	.noclose
;	bsr	close_debug_win
;	bra.b	.NoMsgInBase
;.noclose:

	cmp.l	#$8000,d1	;mouse up?
	beq.s	.NoMsgInBase

	move.l  IntBase,a6
	move.l	(MainWindowHandle-DT,a4),a0
	jsr	(_LVOActivateWindow,a6)	 ; ****
.NoMsgInBase:
	movem.l	(sp)+,d0-a6
	rts


drukdata_regs:
	tst.l	debug_winbase
	bne.s	.okay
	rts
.okay:
	tst.w	(debug_FPregs-DT,a4)
	bne.s	.drfp
	bsr	drukDx_regs
	bra.b	.drnorm
.drfp:
	bsr	drukFP_regs
.drnorm:
	rts

druk_regs:
;	jsr	test1
;	tst.l	debug_winbase
;	bne.s	.okay
;	rts
;.okay:
	move.l  IntBase,a6
	move.l	debug_rp,a0	;rp

	lea	Debug_IText(pc),a5
	move.l  a5,debtxt
	moveq.l	#23-1-8,d7

	cmp.w	#PB_060,(ProcessorType-DT,a4)
	blo.s	.geen060Plus
	addq	#1,d7		;voor PCR reg
.geen060Plus:

	move.w	(EFontSize_y-DT,a4),d6
	mulu.w	#8,d6
.lopje:
	move.w	#0,d0		;left
	move.w	d6,d1		;top
	move.l	debug_rp,a0	;rp
	lea	Debug_Text,a1	;itext
	jsr	_LVOPrintIText(a6)	;printitext
	
	lea	14(a5),a5
	move.l	a5,debtxt

	add.w	(EFontSize_y-DT,a4),d6
	dbf	d7,.lopje
	rts


drukDx_regs:
	move.l  IntBase,a6
	move.l	debug_rp,a0	;rp

	lea	DebugDx_IText(pc),a5
	move.l  a5,debtxt

	moveq.l	#8-1,d7
	moveq.l	#0,d6
.lopje:
	moveq.l	#0,d0		;left
	move.w	d6,d1		;top
	move.l	debug_rp,a0	;rp
	lea	Debug_Text,a1	;itext
	jsr	_LVOPrintIText(a6)	;printitext

	lea	14(a5),a5
	move.l	a5,debtxt

	add.w	(EFontSize_y-DT,a4),d6

	dbf	d7,.lopje
	rts

drukFP_regs:
	move.l  IntBase,a6
	move.l	debug_rp,a0	;rp

	lea	DebugFP_IText(pc),a5
	move.l  a5,debtxt
	moveq.l	#8-1,d7
	moveq.l	#0,d6
.lopje:
	moveq.l	#0,d0		;left
	move.w	d6,d1		;top
	move.l	debug_rp,a0	;rp
	lea	Debug_Text,a1	;itext
	jsr	_LVOPrintIText(a6)	;printitext
	
	lea	20(a5),a5
	move.l	a5,debtxt

	add.w	(EFontSize_y-DT,a4),d6
	dbf	d7,.lopje
	rts



close_debug_win:
	movem.l	d0-a6,-(sp)

;	jsr	test1

	move.l  debug_winbase,a0
	cmp.l	#0,a0
	beq.s	.aldicht

	move.w	4(a0),dw_x+6
	move.w	6(a0),dw_y+6
	move.w	8(a0),dw_br+6
;	move.w	10(a0),dw_hg+6

	move.l  debug_msg_port,86(a0)

	move.l	IntBase,a6
	jsr	_LVOCloseWindow(a6)
	clr.l	debug_winbase
.aldicht:
	movem.l	(sp)+,d0-a6
	rts

;*********** output windowtje *****************
;
;Output_WindowTags:
;    DC.L    WA_Left,0		;x
;    DC.L    WA_Top,480-80	;y
;    DC.L    WA_Width,640	;br
;    DC.L    WA_Height,50	;hg
;    DC.L    WA_IDCMP,$00200074		;idcmp
;    DC.L    WA_Flags,$00000004|2	;flags
;    DC.L    WA_Title,Output_WTitle
;Output_SC:
;    DC.L    $80000079,0
;    DC.L    $00000000
;
;Output_WTitle:
;    DC.B    'Debug output windowtje..',0
;    CNOP    0,2
;
;
;	cnop	0,4
;output_winbase:	dc.l	0
;output_rp:	dc.l	0
;
;open_output_win:
;	movem.l	d0-a6,-(sp)
;	move.l	ScreenBase,Output_SC+4
;	move.l  IntBase,a6
;	sub.l	a0,a0
;	lea.l	Output_WindowTags,a1
;	jsr	_LVOOpenWindowTagList(a6)
;	move.l	d0,output_winbase
;
;	move.l	d0,a0
;	move.l	($0032,a0),output_rp
;
;	move.l	(MainWindowHandle-DT,a4),a0
;	jsr	-450(a6)	;activate window
;
;	movem.l	(sp)+,d0-a6
;	rts
;
;close_output_win:
;	movem.l	d0-a6,-(sp)
;	move.l	IntBase,a6
;	move.l  output_winbase,a0
;	cmp.l	#0,a0
;	beq.s	.aldicht
;	jsr	_LVOCloseWindow(a6)
;	clr.l	debug_winbase
;.aldicht:
;	movem.l	(sp)+,d0-a6
;	rts
;
;*********** druk breaks en watches ***********

show_breaks_watches:
	movem.l	a0-a3,-(sp)
	move	(Cursor_col_pos-DT,a4),-(sp)
	move	(cursor_row_pos-DT,a4),-(sp)
	clr	(Cursor_col_pos-DT,a4)
	jsr	Show_Cursor
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
	jsr	(Diss_zetom2ascii).l
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
	lea	(watch_table,pc),a0
	lea	(L1A3CC,pc),a1
	lea	(L1A3EC,pc),a2
	moveq	#7,d0
C1A5AE:
	tst.b	(a0)
	beq.b	no_watchps
	bsr	show_wps
no_watchps:
	addq.w	#8,a0
	addq.w	#8,a0
	addq.w	#4,a1
	addq.w	#1,a2
	dbra	d0,C1A5AE
	lea	(L1A3F4,pc),a0
	lea	(L1A4F4,pc),a1
	lea	(L1A534,pc),a2
	moveq	#7,d0
C1A5D0:
	tst.b	($0080,a0)
	beq.b	C1A5DA
	bsr	C1A6A4
C1A5DA:
	addq.w	#8,a0
	addq.w	#8,a0
	addq.w	#4,a1
	addq.w	#1,a2
	dbra	d0,C1A5D0
	moveq	#0,d0
	bsr	SENDONECHARNORMAL
	jsr	Show_Cursor
	move	(sp)+,(cursor_row_pos-DT,a4)
	move	(sp)+,(Cursor_col_pos-DT,a4)
exit_rn:
	movem.l	(sp)+,a0-a3
	rts

C1A5FE:
	movem.l	d1-d7/a0-a6,-(sp)
	lea	(L1A3F4,pc),a0
	lea	(L1A4F4,pc),a1
	lea	(L1A534,pc),a2
	moveq	#7,d7
C1A610:
	tst.b	($0080,a0)
	beq.b	C1A61C
	bsr.b	C1A630
	tst	d0
	bne.b	C1A62A
C1A61C:
	addq.w	#8,a0
	addq.w	#8,a0
	addq.w	#4,a1
	addq.w	#1,a2
	dbra	d7,C1A610
	moveq	#0,d0
C1A62A:
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
	add	d0,d0
	lea	(W1A66A,pc),a3
	lea	(a3,d0.w),a3
	add	(a3),a3
	jmp	(a3)

W1A66A:
	dc.w	C1A676-W1A66A
	dc.w	C1A67C-*
	dc.w	C1A682-*
	dc.w	C1A688-*
	dc.w	C1A68E-*
	dc.w	C1A694-*

C1A676:
	cmp.l	d1,d3
	blt.b	C1A6A0
	bra.b	C1A69C

C1A67C:
	cmp.l	d1,d3
	ble.b	C1A6A0
	bra.b	C1A69C

C1A682:
	cmp.l	d1,d3
	beq.b	C1A6A0
	bra.b	C1A69C

C1A688:
	cmp.l	d1,d3
	bge.b	C1A6A0
	bra.b	C1A69C

C1A68E:
	cmp.l	d1,d3
	bgt.b	C1A6A0
	bra.b	C1A69C

C1A694:
	cmp.l	d1,d3
	bne.b	C1A6A0
	br	C1A69C

C1A69C:
	moveq	#0,d0
	rts

C1A6A0:
	moveq	#-1,d0
	rts

C1A6A4:
	movem.l	d0/a0-a3,-(sp)
	bsr	druk_cr_nl
	move.b	#$43,d0
	bsr	SENDONECHARNORMAL
	move.b	#$42,d0
	bsr	SENDONECHARNORMAL
	move.b	#$50,d0
	bsr	SENDONECHARNORMAL
	move.b	#$BB,d0
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
	moveq	#$20,d0
	bsr	SENDONECHARNORMAL
	dbra	d1,C1A6DE
	tst.b	(a2)
	bpl.b	C1A6F8
	jsr	(Convert_A2I).l
	beq	C1A790
	move.l	d0,(a1)
C1A6F8:
	move.l	(a1),a1
	moveq	#$70,d0
	and.b	(a2),d0
	lsr.w	#4,d0
	add	d0,d0
	lea	(W1A80E,pc),a0
	add	d0,a0
	add	(a0),a0
	jsr	(a0)
	move.l	a1,d0
	bsr	Druk_af_D0
	moveq	#15,d0
	and.b	(a2),d0
	add	d0,d0
	lea	(ascii.MSG86,pc),a0
	lea	(a0,d0.w),a0
	move.b	(a0)+,d0
	bsr	SENDONECHARNORMAL
	move.b	(a0)+,d0
	bsr	SENDONECHARNORMAL
	move.b	#$20,d0
	bsr	SENDONECHARNORMAL
	move.b	#$20,d0
	bsr	SENDONECHARNORMAL
	movem.l	(sp),d0/a0-a3
	lea	($0080,a0),a0
	lea	($0020,a1),a1
	lea	(8,a2),a2
	move.l	a0,a6
	moveq	#11,d1
C1A750:
	move.b	(a0)+,d0
	beq.b	C1A75E
	bsr	SENDONECHARNORMAL
	dbra	d1,C1A750
	moveq	#0,d1
C1A75E:
	moveq	#$20,d0
	bsr	SENDONECHARNORMAL
	dbra	d1,C1A75E
	tst.b	(a2)
	bpl.b	C1A776
	jsr	(Convert_A2I).l
	beq.b	C1A790
	move.l	d0,(a1)
C1A776:
	move.l	(a1),a1
	moveq	#$70,d0
	and.b	(a2),d0
	lsr.w	#4,d0
	add	d0,d0
	lea	(W1A80E,pc),a0
	add	d0,a0
	add	(a0),a0
	jsr	(a0)
	move.l	a1,d0
	bsr	Druk_af_D0
C1A790:
	bsr	C1529A
	movem.l	(sp)+,d0/a0-a3
	rts

ascii.MSG86:
	dc.b	' <<= =>= ><>',0,0

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
	moveq	#$20,d0
	bsr	SENDONECHARNORMAL
	dbra	d1,C1A7C2
	tst.b	(a2)
	bpl.b	C1A7DA
	jsr	(Convert_A2I).l
	beq.b	C1A804
	move.l	d0,(a1)
C1A7DA:
	move.l	(a1),a1
	moveq	#$70,d0
	and.b	(a2),d0
	lsr.w	#4,d0
	add	d0,d0
	lea	(W1A80E,pc),a0
	add	d0,a0
	add	(a0),a0
	jsr	(a0)
	move.l	a1,d0
	bsr	Druk_af_D0
	moveq	#15,d0
	and.b	(a2),d0
	add	d0,d0
	lea	(W1A82E,pc),a0
	add	d0,a0
	add	(a0),a0
	jsr	(a0)
C1A804:
	bsr	C1529A
	movem.l	(sp)+,d0/a0-a3
	rts

W1A80E:
	dc.w	C1A820-W1A80E
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
	dc.w	C1A8A0-W1A82E
	dc.w	C1A878-*
	dc.w	C1A860-*
	dc.w	C1A84C-*
	dc.w	C1A838-*

C1A838:
	move.b	(a1)+,d1
	lsl.w	#8,d1
	move.b	(a1)+,d1
	swap	d1
	move.b	(a1)+,d1
	lsl.w	#8,d1
	move.b	(a1)+,d1
	jmp	(C13666).l

C1A84C:
	moveq	#3,d5
C1A84E:
	moveq	#0,d0
	move.b	(a1)+,d0
	lsl.w	#8,d0
	move.b	(a1)+,d0
	bsr	Druk_D0_inCommandline
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
	moveq	#$22,d0
	bsr	SENDONECHARNORMAL
	moveq	#$27,d2
C1A880:
	move.b	(a1)+,d0
	beq.b	C1A89A
	move.b	d0,d1
	and.b	#$7F,d1
	cmp.b	#$20,d1
	bcc.b	C1A892
	moveq	#$2E,d0
C1A892:
	bsr	SENDONECHARNORMAL
	dbra	d2,C1A880
C1A89A:
	moveq	#$22,d0
	br	SENDONECHARNORMAL

C1A8A0:
	moveq	#$22,d0
	bsr	SENDONECHARNORMAL
	moveq	#$27,d2
C1A8A8:
	move.b	(a1)+,d0
	move.b	d0,d1
	and.b	#$7F,d1
	cmp.b	#$20,d1
	bcc.b	.ok
	moveq	#$2E,d0
.ok:
	bsr	SENDONECHARNORMAL
	dbra	d2,C1A8A8
	moveq	#$22,d0
	br	SENDONECHARNORMAL

;********************************
;*	  Single Step		*
;********************************

DEBUG_SINGLE_STEP:
	move.l	(pcounter_base-DT,a4),a5
	jsr	(DISLENGTH_A5).l
	tst.b	d2
	bne.b	C1A8DA
C1A8D4:
	move.l	a5,a1
	br	DEBUG_ADD_AND_JUMP

C1A8DA:
	lsr.b	#1,d2
	bcs.b	DEBUG_STACK_BREAKPOINT
	lsr.b	#1,d2
	bcs.b	DEBUG_ENTER_SINGLE_STEP
	bra.b	C1A8D4

DEBUG_ENTER_SINGLE_STEP:
	moveq	#1,d0
	br	com_singlestep

DEBUG_STACK_BREAKPOINT:
	move.l	(USP_base-DT,a4),a1
	btst	#13,(statusreg_base-DT,a4)
	bne.b	.C1A8FA
	move.l	(SSP_base-DT,a4),a1
.C1A8FA:
	move.l	(a1),a1
	br	DEBUG_ADD_AND_JUMP

;********************************
;*	  Exit debugger		*
;********************************

DEBUG_KEYP_EXIT_AGAIN:
	bsr	KEY_RETURN_LAST_KEY
Debug_QuitTrace:
	bsr	close_debug_win

	btst	#0,(PR_ShowSource).l
	bne.w	C1A912
	jsr	Show_Cursor
C1A912:
	bsr.b	C1A91A
	jmp	(CommandlineInputHandler).l

C1A91A:
	bclr	#SB2_INDEBUGMODE,(SomeBits2-DT,a4)
DEBUG_OFF_2:
	move.l	d0,-(sp)
	move.l	(Comm_menubase-DT,a4),d0
	move.b	#MT_COMMAND,(menu_tiepe-DT,a4)
	jsr	(Change_2menu_d0).l
	move.l	(sp)+,d0
	moveq	#0,d0
	bsr	SENDONECHARNORMAL
	jsr	Show_Cursor
	lea	(End_msg,pc),a0
	jmp	(druk_status_en_end_af).l

_druk_af_debug_regs:
	jmp	druk_af_debug_regs

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
	move.b	#0,(Animate-DT,a4)
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
	bset	#7,(statusreg_base-DT,a4)
	move.l	(SSP_base-DT,a4),a0
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
	cmp.b	#$61,d1					
	bne.b	.NO_ADDR
	move.l	d0,(pcounter_base-DT,a4)
.NO_ADDR:
	bsr.b	DEBUG_CLEAR_BP_BUFFER
.LOOP1:
	lea	(BREAKPOINT.MSG).l,a0
	bsr	INPUTTEXT
	bsr	INPUTWORKSPACE_NOTEXT
	bne.b	DEBUG_NO_BREAK_PT2
	move.l	d0,a1
	bsr	DEBUG_ADD_BRKPT
	bra.b	.LOOP1

DEBUG_NO_BREAK_PT2:
	bsr	C1AB66
DEBUG_NO_BREAK_PT:
	move.l	(SSP_base-DT,a4),a0
DEBUG_JUMP_TO_PROGCOUNT_NO_TRACE:
	bclr	#7,(statusreg_base-DT,a4)
DEBUG_JUMP_TO_PROGCOUNT:
	bsr.b	DEBUG_SET_ALL_CURRENT_BPS
	bsr	INITRESCUE
	clr.l	(MEMDIR_BUFFER-DT,a4)
PRIVILIGE_VIOL2:
	move.l	(4).w,a6
	move	($0126,a6),(B2F270-DT,a4)
	lea	(C1AAE2).l,a5
	move.l	(4).w,a6
	jsr	(_LVOSupervisor,a6)
C1AAE0:
	rts

C1AAE2:
	move.l	a0,usp
	move.l	(4).w,a6
	jsr	(_LVOCacheClearU,a6)
	move.l	(GfxBase-DT,a4),a6
	move.l	(gb_ActiView,a6),(L2F27A-DT,a4)
	btst	#SB2_INDEBUGMODE,(SomeBits2-DT,a4)
	bne.b	.noWB2Front
	tst.b	(PR_WBFront).l
	beq.b	.noWB2Front

;	lea	(Workbench.MSG).l,a0
	move.l	(IntBase-DT,a4),a6
;	jsr	(_LVOLockPubScreen,a6)
;	move.l	d0,(WBScreen).l
;	tst.l	d0
;	beq.b	.noWB2Front
;	move.l	d0,a0
;	move.l	(IntBase-DT,a4),a6
;	jsr	(_LVOScreenToFront,a6)

	jsr	_LVOWBenchToFront(a6)

.noWB2Front:
	lea	(C1AB40).l,a5
	move.l	(4).w,a6
	jsr	(_LVOSupervisor,a6)
	movem.l	d0-d7/a0-a6,(DataRegsStore).l
	rts

C1AB40:
	tst	(FPU_Type-DT,a4)
	beq.b	.NoFpu
	fmovem	(FpuRegsStore-DT,a4),fp0/fp1/fp2/fp3/fp4/fp5/fp6/fp7
	fmovem	(fpu_1-DT,a4),fpcr/fpsr/fpiar
	;dc.w	$F22C
	;dc.w	$9C00
	;dc.w	$67B0

.NoFpu:
	movem.l	(DataRegsStore-DT,a4),d0-d7/a0-a6
	move.l	(pcounter_base).l,-(sp)
	move	(statusreg_base).l,-(sp)
	rte

C1AB66:
	btst	#0,(PR_params).l
	beq.b	C1AB86
	tst.b	(Parameters).l
	beq.b	C1AB86
	move.l	#Parameters,(AdresRegsStore-DT,a4)
	move.l	(ParametersLengte-DT,a4),(DataRegsStore-DT,a4)
C1AB86:
	rts

; Jump command
com_jump:
	movem.l	d0-a6,-(a7)			; auto update stuff
	tst.b	(PR_AutoUpdate).l
	beq.s	.noForceUpdate
	bsr.w	com_update			
.noForceUpdate:
	movem.l	(a7)+,d0-a6			
	cmp.b	#$61,d1				
	bne.b	.NO_ADDR
	move.l	d0,(pcounter_base-DT,a4)
.NO_ADDR:
	move	#1,(AssmblrStatus).l
	lea	(L2DF4C-DT,a4),a0
	move.l	#eop_irq_routine,-(a0)
	move.l	a0,(USP_base-DT,a4)
	lea	(L2CF4C-DT,a4),a0
	move.l	#eop_irq_routine,-(a0)
	bsr.b	C1AB66
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
	add	#12,a0
	move.l	(a1),(8,a0)
	move.l	a0,(a1)+
	add	#12,a0
	move	#7,d0
C1AC42:
	move.l	(a1),(6,a0)
	move.l	a0,(a1)+
	add	#10,a0
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
	lea	(C1AE72,pc),a0
	move.l	a0,($007C,a1)
C1AC7E:
	movem.l	(sp)+,d0/a0/a1/a6
	rts

C1AC84:
	movem.l	d0-d7/a0-a6,(DataRegsStore).l	;-A7
	sub.l	a1,a1
	move.l	(4).w,a6
	jsr	(_LVOFindTask,a6)
	cmp.l	(DATA_TASKPTR).l,d0
	beq.b	C1ACBA
	movem.l	(DataRegsStore).l,d0-d7/a0-a6	;-A7
	move.l	a1,-(sp)
	bsr	SYS_GetVBR
	move.l	#C1AE72,($007C,a1)		;level7 interrupt autovector
	move.l	(sp)+,a1
C1ACB8:
	rte

C1ACBA:
	movem.l	(DataRegsStore).l,d0-d7/a0-a6	;-A7
	move.b	#$7F,(DATA_EXCEPTIONNUMBER).l
	move.l	a1,-(sp)
	bsr	SYS_GetVBR
	move.l	(RESCUEPTRS_Last).l,($007C,a1)
	move.l	(sp)+,a1
	br	EXHA_GOINFROM7LEVEL

GORESCUE:
	move	#$7FFF,$DFF09A
C1ACE6:
	btst	#0,($DFF005).l
	beq.b	C1ACE6
C1ACF0:
	btst	#0,($DFF005).l
	bne.b	C1ACF0

	tst.l	(L2F118).l
	beq.b	C1AD3C
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	a1,-(sp)
	bsr	SYS_GetVBR
	move.l	#C1AE72,($007C,a1)
	move.l	(sp)+,a1
	lea	(L2F118).l,a0
	move.l	(a0),(4,a0)
	clr.l	(a0)
	move.l	(4,a0),a0
	jsr	(a0)
	move.l	a1,-(sp)
	bsr	SYS_GetVBR
	move.l	(RESCUEPTRS_Last).l,($007C,a1)
	move.l	(sp)+,a1
	movem.l	(sp)+,d0-d7/a0-a6
C1AD3C:
	move.l	(L2F11C).l,(L2F118).l
	movem.l	d0/a0/a1/a6,(RESCUE_4REGS).l

	lea	($DFF000).l,a6
	move	(GEMDMA),d0
	or.w	#$8000,d0
	not.w	d0
	move	d0,($0096,a6)
	move	#$7FFF,($009E,a6)
	move.l	(Copperlist1),($0080,a6)
	move.l	(Copperlist2),($0084,a6)

	lea	(0).l,a1
	tst	(ProcessorType).l
	beq.b	.mc68000
	movec	vbr,a1
.mc68000:
	addq.w	#8,a1
	lea	(RESCUEPTRS).l,a0
	move	#30-1,d0
C1AD98:
	move.l	(a0)+,(a1)+
	dbra	d0,C1AD98
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

SYS_GetVBR:
	movem.l	d0-d7/a0/a2-a6,-(sp)
	lea	(.GetVBR,pc),a5
	move.l	(4).w,a6
	jsr	(_LVOSupervisor,a6)
	movem.l	(sp)+,d0-d7/a0/a2-a6
	rts

.GetVBR:
	lea	(0).w,a1
	tst	(ProcessorType).l
	beq.b	.mc68000
	movec	vbr,a1
.mc68000:
	rte

C1AE72:
	move.l	a1,-(sp)
	bsr	SYS_GetVBR
	move.l	#C1ACB8,($007C,a1)
	move.l	(sp)+,a1
C1AE82:
	cmp.l	#C1AE72,(2,sp)
	bne	C1AC84
	addq.w	#6,sp
	bra.b	C1AE82

C1AE92:
	movem.l	d0/d1/a0,(L2EB04).l
	move	(8,sp),d0
	move	d0,d1
	and	#7,d1
	btst	#8,d0
	bne.b	C1AEAE
	bset	#4,d1
C1AEAE:
	btst	#13,d0
	bne.b	C1AEB8
	bset	#3,d1
C1AEB8:
	move	d1,(DATA_BUSACCESS).l
	move.l	($0036,sp),a0
	move.l	(a0),(DATA_BUSPTRHI).l
	move.l	(10,sp),a0
	move	(a0),(DATA_BUSFAILINST).l
	movem.l	(L2EB04).l,d0/d1/a0
	cmp.l	#C1AAE0,(10,sp)
	beq	RETURNINSUPERSTATE
	cmp.l	#CriticalError,(10,sp)
	beq	RETURNINSUPERSTATE
	btst	#0,(PR_Level7).l
	beq.b	C1AF0C
	move.l	a1,-(sp)
	bsr	SYS_GetVBR
	move.l	(RESCUEPTRS_Last).l,($007C,a1)
	move.l	(sp)+,a1
C1AF0C:
	btst	#0,(PR_Rescue).l
	beq.b	C1AF1A
	bsr	GORESCUE
C1AF1A:
	move	(sp),(statusreg_base).l
	move.l	(2,sp),(pcounter_base).l
	add.l	#$0000003A,sp
	br	C1B0C6

C1AF32:
	movem.l	d0/d1/a0,(L2EB04).l
	move	(10,sp),d0
	move	d0,d1
	and	#7,d1
	btst	#8,d0
	bne.b	C1AF4E
	bset	#4,d1
C1AF4E:
	btst	#13,d0
	bne.b	C1AF58
	bset	#3,d1
C1AF58:
	move	d1,(DATA_BUSACCESS).l
	move.l	($0010,sp),a0
	move	(a0),(DATA_BUSFAILINST).l
	move.b	(6,sp),d0
	and.b	#$F0,d0
	cmp.b	#$A0,d0
	beq.b	C1AFDE
	move.l	($0010,sp),(DATA_BUSPTRHI).l
	movem.l	(L2EB04).l,d0/d1/a0
	cmp.l	#C1AAE0,(2,sp)
	beq	RETURNINSUPERSTATE
	cmp.l	#CriticalError,(2,sp)
	beq	RETURNINSUPERSTATE
	btst	#0,(PR_Level7).l
	beq.b	C1AFB8
	move.l	a1,-(sp)
	bsr	SYS_GetVBR
	move.l	(RESCUEPTRS_Last).l,($007C,a1)
	move.l	(sp)+,a1
C1AFB8:
	btst	#0,(PR_Rescue).l
	beq.b	C1AFC6
	bsr	GORESCUE
C1AFC6:
	move	(sp),(statusreg_base).l
	move.l	(2,sp),(pcounter_base).l
	add.l	#$0000005C,sp
	br	C1B0C6

C1AFDE:
	move.l	($0010,sp),(DATA_BUSPTRHI).l
	movem.l	(L2EB04).l,d0/d1/a0
	cmp.l	#C1AAE0,($0010,sp)
	beq	RETURNINSUPERSTATE
	cmp.l	#CriticalError,($0010,sp)
	beq	RETURNINSUPERSTATE
	btst	#0,(PR_Level7).l
	beq.b	C1B020
	move.l	a1,-(sp)
	bsr	SYS_GetVBR
	move.l	(RESCUEPTRS_Last).l,($007C,a1)
	move.l	(sp)+,a1
C1B020:
	btst	#0,(PR_Rescue).l
	beq.b	C1B02E
	bsr	GORESCUE
C1B02E:
	move	(sp),(statusreg_base).l
	move.l	(2,sp),(pcounter_base).l
	add.l	#$00000020,sp
	br	C1B0C6

EXCEPTIONHANDLER:
	move.b	(3,sp),DATA_EXCEPTIONNUMBER
	cmp.l	#4,(sp)+
	bcc.b	.NOTBUSORADDR
	cmp	#1,(ProcessorType).l
	beq	C1AE92
	cmp	#2,(ProcessorType).l
	bge.w	C1AF32
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
C1B0C6:
	movem.l	d0-d7/a0-a6,(DataRegsStore).l	;-A7
	tst	(FPU_Type).l
	beq.b	C1B0F0
	fmovem.x	fp0/fp1/fp2/fp3/fp4/fp5/fp6/fp7,(FpuRegsStore).l
	fmovem	fpcr/fpsr/fpiar,(fpu_1).l
	;dc.w	$F239
	;dc.w	$BC00
	;dc.l	fpu_1
	
	move.l	#0,(L2F26C).l
C1B0F0:
	move.l	usp,a0
	lea	(Variable_base).l,a4
	move.l	a1,-(sp)
	bsr	SYS_GetVBR
	move.l	a1,(VBR_base_ofzo-DT,a4)
	move.l	(sp)+,a1
	move.l	a0,(SSP_base-DT,a4)
	move.l	(DATA_SUPERSTACKPTR-DT,a4),sp
	move	#0,sr
	tst.b	(PR_Enable_Permit).l
	beq.b	C1B144
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	(4).w,a6
	move.b	(B2F270-DT,a4),d0
	move.b	(B2F271-DT,a4),d1
C1B128:
	cmp.b	(IDNestCnt,a6),d0
	beq.b	C1B134
	jsr	(_LVOEnable,a6)
	bra.b	C1B128

C1B134:
	cmp.b	(TDNestCnt,a6),d1
	beq.b	C1B140
	jsr	(_LVOPermit,a6)
	bra.b	C1B134

C1B140:
	movem.l	(sp)+,d0-d7/a0-a6
C1B144:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	(Variable_base-DT,a4),a6
	move.l	(L2F27A-DT,a4),a1
	move.l	(GfxBase-DT,a4),a6
	jsr	(_LVOLoadView,a6)
	jsr	(_LVOWaitTOF,a6)
	jsr	(_LVOWaitTOF,a6)
	tst.b	(PR_WBFront).l
	beq.b	C1B18E
;	move.l	(WBScreen).l,a1
;	move.l	(IntBase-DT,a4),a6
;	jsr	(_LVOUnlockPubScreen,a6)
;	move.l	#0,WBScreen
	move.l	ScreenBase,a0
	move.l	(IntBase-DT,a4),a6
	jsr	(_LVOScreenToFront,a6)
C1B18E:
	movem.l	(sp)+,d0-d7/a0-a6
	move.l	(DATA_USERSTACKPTR-DT,a4),sp
	moveq	#0,d7
	move.l	(pcounter_base-DT,a4),d0
	move.l	d0,(MEM_DIS_DUMP_PTR-DT,a4)
	cmp.l	#eop_irq_routine,d0
	bne.b	C1B1AE
	bset	#7,(DATA_EXCEPTIONNUMBER-DT,a4)
C1B1AE:
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
	beq	C1B246
	jsr	close_debug_win
	
	and	#$D8FF,(statusreg_base).l
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
	tst	d0
	beq.b	C1B264
	lea	(Conditionbrea.MSG).l,a0
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
	dc.w	com_BinDump-BinDump_stuff
	dc.w	MonJump2-BinDump_stuff



C1B2DA:
	move.b	(MemDumpSize-DT,a4),(OpperantSize-DT,a4)
	move.l	(MON_TYPE_PTR-DT,a4),d0
	bne.b	C1B2EC
	move.l	#MON_DIS_TYPES,d0
C1B2EC:
	move.l	d0,a0
	add	(8,a0),a0
	moveq	#-1,d0
	jmp	(a0)


enter_hex_mode:
	bclr	#MB1_INCOMMANDLINE,(MyBits-DT,a4)
	bset	#SB3_EDITORMODE,(SomeBits3-DT,a4)	;in editor
	move.l	a0,(MON_TYPE_PTR-DT,a4)
	move	(AantalRegels_Editor-DT,a4),d0
	jsr	(OPED_SETNBOFFLINES).l
	jsr	(Change2Monitormenu).l
	bclr	#SB3_COMMANDMODE,(SomeBits3-DT,a4)	;uit command
	bset	#1,(SomeBits3-DT,a4)	;???
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
	moveq	#0,d0
	bsr	SENDONECHARNORMAL
	move.b	#$FF,(B2BEB8-DT,a4)
	moveq	#0,d0
	jsr	(SENDONECHARNORMAL).l

	jsr	(StatusBar_monitor).l
	move.l	#-1,reset_pos
	jsr	get_font1
	bsr.w	mon_setpos
monitor_loopje:

	move.l	(DATA_USERSTACKPTR-DT,a4),sp
	moveq	#0,d7
	move	(Scr_br_chars-DT,a4),(breedte_editor_in_chars-DT,a4)
	bsr	iets_met_monitor_output

	; *** This one is triggered after page up/down
	cmp.w	#1,Mon_Notif_Addr
	bne.b	.Refresh_Address
	bsr.w	mon_setpos
	; *** Only one time
	move.w	#0,Mon_Notif_Addr
.Refresh_Address:

	; *** Set caret coords
	move.l	(MON_TYPE_PTR-DT,a4),a0
	add	(6,a0),a0
	jsr	(a0)
	bsr	Place_cursor_blokje		; ***

	jsr	(GetTheTime).l
	lea	(TimeString).l,a0
	move.w	Scr_br_chars,d7
	sub.w	#10,d7
	bsr	drukit

;	jsr	(StatusBar_monitor).l

	bsr	RESETMENUTEXT
	jsr	(messages_get).l
	jsr	(GETKEYNOPRINT).l
	cmp.b	#$1B,d0
	beq	LeaveMonitor
	bsr	RESETMENUTEXT
	pea	(monitor_loopje,pc)
	cmp.b	#$80,d0
	bne	C1B4AA
	moveq	#0,d0
	move.b	(edit_EscCode-DT,a4),d0
	cmp.b	#$1E,d0		;ESC
	beq	C1B6FE
	cmp.b	#9,d0
	beq	mon_EnvPrefs
	cmp.b	#12,d0
	beq	mon_AsmPrefs
	cmp.b	#70,d0		;Z
	beq	mon_SyntPrefs

	cmp.b	#$65,d0		;e
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
	beq	C1B8E4
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
	beq.w	mon_setbegin
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
	
	move.b	#$80,d0
C1B4AA:
	move.l	(MON_TYPE_PTR-DT,a4),a0
	add	(a0),a0
	jsr	(a0)
	bra.w	mon_setpos			; ***

mon_SyntPrefs:
	move.b	#2,(Prefs_tiepe-DT,a4)
	bra.b	C1B4C0

mon_EnvPrefs:
	move.b	#0,(Prefs_tiepe-DT,a4)
	bra.b	C1B4C0

mon_AsmPrefs:
	move.b	#1,(Prefs_tiepe-DT,a4)
C1B4C0:
	movem.l	d0-a6,-(sp)			; ***
	jsr	(Handle_prefs_windows).l
	movem.l	(sp)+,d0-a6			; ***
	move.b	(MemDumpSize-DT,a4),(OpperantSize-DT,a4)
	bsr	mon_getCurrAdr
	move.l	(MON_TYPE_PTR-DT,a4),a0
	add	(8,a0),a0
	jmp	(a0)

; ----
mon_amiguide:
	movem.l	d0-a6,-(sp)			; ***
	jsr	(AmigaGuideGedoe).l
	movem.l	(sp)+,d0-a6			; ***
	rts

; ----
mon_setbegin:
	bsr	mon_getCurrAdr
	move.l	d0,(SaveBin_Start-DT,a4)	; ***
	lea	xxxxxxxxEnd.MSG,a3
	jsr	(ZetHex_D0_Om5_inA3).l
	lea	xxxxxxxxEnd.MSG,a0
	moveq.l	#8,d7
	bra.b	drukit				; ***

; ----
mon_setend:
	bsr	mon_getCurrAdr
	move.l	d0,(SaveBin_End-DT,a4)		; ***
	lea	(xxxxxxxxSize.MSG).l,a3
	jsr	(ZetHex_D0_Om5_inA3).l
	moveq.l	#24,d7
	lea	(xxxxxxxxSize.MSG).l,a0
	bra.b	drukit				; ***

; ---- ***
mon_setpos:
	bsr	mon_getCurrAdr
	lea	Monitor_Pos,a3
	jsr	(ZetHex_D0_Om5_inA3).l
	lea	Monitor_Pos,a0
	moveq.l	#54,d7
	bra.w	drukit				; ***

drukit:
	bclr	#MB1_REGEL_NIET_IN_SOURCE,(MyBits-DT,a4)

	lea	(regel_buffer-DT,a4),a1		;status
	move.l	a1,a2
	lea	(a1,d7.w),a1

	moveq	#8-1,d7
	cmp.l	#TimeString,a0
	beq.s	.lopje
	moveq	#9-1,d7

.lopje:
	moveq	#0,d0
	move.b	(a0)+,d0
	jsr	FASTSENDONECHAR
	dbra	d7,.lopje
	rts

	IF MEMSEARCH

mon_SearchMemForward:
	move.w	mon_SearchMem\.StartSize,d1
	bmi.s	mon_SearchMem
	move.l	mon_SearchMem\.StartValue,-(sp)	;d0
	bra.b	mon_SearchMem\.inspringen

mon_SearchMem:
	lea	(Searchfor.MSG).l,a0
	jsr	GetAdrFromTitle
	beq.w	.novalue

	move.l	d0,.StartValue
	move.l	d0,-(sp)
	lea	(SIZEBWL.MSG,pc),a0
	bsr	printTextInMenuStrip

	bsr	GETKEYNOPRINT
	and.b	#$DF,d0
	moveq	#0,d1
	cmp.b	#'B',d0
	beq.s	.klaar
	moveq.l	#4,d1
	cmp.b	#'W',d0
	beq.s	.klaar
	moveq.l	#8,d1
	cmp.b	#'L',d0
	bne.w	.errIllSize
.klaar:
	move.w	d1,.StartSize
.inspringen:
	move.l	d1,-(sp)	
	lea	(Searching.MSG).l,a0
	jsr	printTextInMenuStrip

	bsr	mon_getCurrAdr
	move.l	d0,a6
	addq.l	#1,a6		;niet steeds dezelfde finden
	move.l	d0,.StartAdr

	move.l	(sp)+,d1
	move.l	(sp)+,d0
	
	move.b	(a6)+,d6
	tst.w	d1
	beq.s	.go
	lsl.l	#8,d6
	move.b	(a6)+,d6
	cmp.w	#4,d1
	beq.s	.go
	lsl.l	#8,d6
	move.b	(a6)+,d6
	lsl.l	#8,d6
	move.b	(a6)+,d6
.go
	lea	.jumper,a5
.lopje:
	jmp	(a5,d1.w)
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
;	move.l	a6,$200000-4

	cmp.l	.StartAdr(pc),a6
	bne.s	.lopje
	bra.b	.errNotFound
	
.foundL:
	subq.l	#1,a6
	cmp.w	#0,d1
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
	lea	(.illsize.MSG).l,a0
	jsr	druk_menu_txt_verder
	rts

.errNotFound:
	lea	(Not.MSG).l,a0
	jsr	druk_menu_txt_verder
	rts

.novalue:
	jsr	(RESETMENUTEXT).l
	rts

.StartAdr:	dc.l	0

.StartValue:	dc.l	0
.StartSize:	dc.w	-1


.illsize.MSG:	dc.b	"Illegal Size should be one of B/W/L",0

	ENDIF

mon_SaveBin:
	tst.l	(SaveBin_Start-DT,a4)		; ***
	beq.b	C1B574
	tst.l	(SaveBin_End-DT,a4)		; ***
	beq.b	C1B574
	btst	#0,(PR_ReqLib).l
	bne.b	C1B556
	lea	(FILENAME.MSG).l,a0
	jsr	(putThetextInMenubar).l
	bne.b	C1B574

;	jsr	test1
	
;	lea	(CurrentAsmLine-DT,a4),a0	;;?!?!?!?! huh?!
;	lea	(CurrentAsmLine-DT,a4),a1
;C1B54C:
;	move.b	(a0)+,(a1)+
;	tst.b	(-1,a0)
;	bne.b	C1B54C

	bra.b	C1B55E

C1B556:
	moveq	#3,d0
	jsr	(YesReqLib).l
C1B55E:
	move.l	(SaveBin_Start-DT,a4),d2	; ***
	move.l	(SaveBin_End-DT,a4),d3		; ***
	cmp.l	d2,d3
	bgt.b	C1B56C
	exg	d2,d3
C1B56C:
	sub.l	d2,d3
	moveq	#-2,d7
	br	C18C9A

C1B574:
	bsr	RESETMENUTEXT
	rts

C1B57A:
	bsr	C1B57E
C1B57E:
	jmp	(GetKey).l

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
	lea	(BytesWordsLon.MSG).l,a0
	mulu	#10,d0
	lea	(a0,d0.w),a0
	lea	(LongwordsTime.MSG).l,a1
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
	lea	(B29B93-DT,a4),a3
	jsr	(ZetHex_D0_Om5_inA3).l
	clr.b	(a3)
	lea	(B29B93-DT,a4),a1
	jsr	(C14678).l
	br	mon_jump2Addr

C1B618:
	bsr	KEY_RETURN_LAST_KEY
LeaveMonitor:
	bsr.b	mon_getCurrAdr
	moveq	#0,d0
	bsr	SENDONECHARNORMAL
	bclr	#SB1_MOUSE_KLIK,(SomeBits-DT,a4)
	lea	(ErrorInLine).l,a0
	move.l	a0,(Error_Jumpback-DT,a4)
	lea	(End_msg,pc),a0
	jsr	(druk_status_en_end_af).l

	jsr     scroll_up_cmd_fix

	jmp	(CommandlineInputHandler).l

mon_getCurrAdr:
	lea	(RegelPtrsIn-DT,a4),a0
	move.l	(LineFromTop-DT,a4),d0

	IF MC020
	move.l	(a0,d0.w*4),a0
	ELSE	
	lsl.w	#2,d0
	add	d0,a0
	move.l	(a0),a0
	ENDC
	
	move.w	(MON_EDIT_POSITION-DT,a4),d0	; ***
	cmp.l	#Hexdump_stuff,(MON_TYPE_PTR-DT,a4)
	bne.b	C1B66E
	cmp.w	#32,d0				; ***
	bcs.b	MaxHex_Addr			; ***
	sub.w	#32,d0				; ***
	add.w	d0,d0				; ***
MaxHex_Addr:
	lsr.w	#1,d0
C1B66E:
	; *** Fix the current address in binary dump
	cmp.l	#BinDump_stuff,(MON_TYPE_PTR-DT,a4)	; ***
	bne.b	BinDump_Address				; ***
	cmp.w	#32,d0				; ***
	bcs.b	MaxBin_Addr			; ***
	sub.w	#32,d0				; ***
	lsl.w	#3,d0				; ***
MaxBin_Addr:					; ***
	lsr.w	#3,d0				; ***
BinDump_Address:				; ***
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

C1B6FE:
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
	btst	#7,($001A,a1)		;menustate
	bne.b	.waitmenustate

;	bclr	#SB3_COMMANDMODE,(SomeBits3-DT,a4)	;uit command
;	bne.w	druk_lines_monitor
;	jsr	(Show_Cursor).l
;druk_lines_monitor:

	jsr	get_font1

	lea	(RegelPtrsIn-DT,a4),a6
	move	(NrOfLinesInEditor-DT,a4),d1

	bset	#MB1_REGEL_NIET_IN_SOURCE,(MyBits-DT,a4)

;	sub.l	a1,a1			;reset y-pos
	moveq.l	#0,d7			;y-pos

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
	cmp.l	#-1,a5
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
	move	(NrOfLinesInEditor-DT,a4),d0
	lsr.w	#1,d0
	cmp.l	(LineFromTop-DT,a4),d0
	bcs.b	.nogniet_ophelft

	jsr	Show_Cursor
	bset	#SB3_COMMANDMODE,(SomeBits3-DT,a4)	;in commandline
	bsr	ScrollEditorDown
	jsr	Show_Cursor

	cmp.l	#0,(LineFromTop-DT,a4)			; *** Fix the sticky
	bne.b	.No_Caret2				; caret bug
	move.w	(cursor_row_pos-DT,a4),-(a7)		; when at the top
	move.w	#2,(cursor_row_pos-DT,a4)		; of the area
	bsr	Place_cursor_blokje
	move.w	(a7)+,(cursor_row_pos-DT,a4)
.No_Caret2:

	jsr	(Regeltab_scrolldown).l

	bsr	new2old_stuff			; ***
	bra.w	mon_setpos			; ***

.nogniet_ophelft:
	subq.l	#1,(LineFromTop-DT,a4)
	bra.w	mon_setpos

Mon_scrollup:
	moveq	#0,d0				; ***
	move	(NrOfLinesInEditor-DT,a4),d0
	lsr.w	#1,d0
	cmp.l	(LineFromTop-DT,a4),d0	;op de helft?
	bhi.b	.nogniet_ophelft

	jsr	Show_Cursor

	bset	#SB3_COMMANDMODE,(SomeBits3-DT,a4)	;in commandmode
	bsr	ScrollEditorUp

	jsr	Show_Cursor

	jsr	(Regeltab_scrollup).l
	bsr	new2old_stuff
	bsr.w	mon_setpos			; ***
	moveq	#1,d0				; *** returns 1 if scrolled
	rts
.nogniet_ophelft:
	addq.l	#1,(LineFromTop-DT,a4)
	bsr.w	mon_setpos			; ***
	moveq	#0,d0				; *** Return 0 if nothing
	rts

Mon_pageup:
	move.l	#-1,reset_pos
	move.l	(RegelPtrsIn-DT,a4),-(sp)
	jsr	(RegTab_SETALLNOTUPD).l

	lea	(RegelPtrsIn-DT,a4),a0
	move	(NrOfLinesInEditor-DT,a4),d0
	subq.w	#1,d0
	add	d0,d0
	add	d0,d0
	add	d0,a0
	move.l	(sp)+,(a0)
	bsr	new2old_stuff			; ***
	move.w	#1,Mon_Notif_Addr		; ***
	rts

Mon_pagedown:
	move.l	#-1,reset_pos
	lea	(RegelPtrsIn-DT,a4),a0
	move	(NrOfLinesInEditor-DT,a4),d0
	subq.w	#1,d0
	add	d0,d0
	add	d0,d0
	add	d0,a0
	move.l	(a0),-(sp)
	jsr	(RegTab_SETALLNOTUPD).l
	move.l	(sp)+,(RegelPtrsIn-DT,a4)
	bsr	new2old_stuff			; ***
	move.w	#1,Mon_Notif_Addr		; ***
	rts

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
	br	com_BinDump

;************** DISSASAMBLER OUTPUT ****************

com_dissasemble:
	bne.b	C1B8F8
	move.l	d0,(MEM_DIS_DUMP_PTR-DT,a4)	;user defined..
C1B8F8:
	bclr	#0,(MEM_DIS_DUMP_PTR+3-DT,a4)
	
	clr	(MON_EDIT_POSITION-DT,a4)
	bsr	MON_CLEARCACH
	lea	(MON_DIS_TYPES,pc),a0	;afdruk functies
	br	enter_hex_mode

Debug_base:
	move.w	realend4,d0
	add.w	#'0',d0
	move.b	d0,A4Debug.MSG+1
	lea	(A4Debug.MSG).l,a0
	jsr	(beeldtextaf).l
	lea	(ascii.MSG8).l,a0
	move.l	a4,d0
	jsr	(Druk_af_D0).l
	lea	(ascii.MSG9).l,a0
	jsr	(beeldtextaf).l
	lea	(ascii.MSG8).l,a0
	move.l	#L2DF4C,d0
	jsr	(Druk_af_D0).l
	lea	(ascii.MSG0).l,a0
	jmp	(beeldtextaf).l

DissCursor:
	;move.l	#-1,reset_pos		; *** Remove
	;jsr	(Show_Cursor).l		; ***
	move.l	(LineFromTop-DT,a4),d0
	add	d0,d0
	move	d0,(cursor_row_pos-DT,a4)
	move.w	#30,(Cursor_col_pos-DT,a4)
	rts
	
DissKeys:
	cmp.b	#$80,d0
	beq.b	C1B97C
	cmp.b	#$7F,d0			; *** (DEL) Insert NOP
	beq.b	DissInsertNOP
	jsr	(KEYBUFFERPUTCHAR).l
	bra.w	C1B9D0

C1B97C:
	move.b	(edit_EscCode-DT,a4),d0
	cmp.b	#$57,d0	'W'
	beq.b	C1B9A0
	bsr.b	C1B9A2
	lea	(B29B93-DT,a4),a1
	jsr	(C14678).l
	moveq	#6,d0
	bsr	C17412
	jsr	(KEY_RETURN_LAST_KEY).l
	bra.b	C1B9D0

C1B9A0:
	rts

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
	jmp	(C1FE7E).l

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
	tst.b	d0					; *** Scrolled ?
	bne.b	NoDiss_Scroll				; ***
	move.l	#-1,reset_pos				; ***
	rts						; ***
NoDiss_Scroll:
	move.w	(cursor_row_pos-DT,a4),-(a7)		; *** Correct caret
	addq.w	#1,(cursor_row_pos-DT,a4)
	bsr	Place_cursor_blokje
	move.w	(a7)+,(cursor_row_pos-DT,a4)
	move.l	#-1,reset_pos				; ***
	rts
C1B9D0:
	bsr	C1529A
	moveq	#0,d0
	bsr	SENDONECHARNORMAL
	lea	(RegelPtrsIn-DT,a4),a0
	move.l	(LineFromTop-DT,a4),d0

	IF MC020
	lea	(a0,d0.w*4),a0
	move.l	(a0)+,d0

	ELSE
	lsl.w	#2,d0
	add	d0,a0
	move.l	(a0)+,d0
	ENDC

	moveq	#-1,d1
	move.l	d1,(a0)
	lea	(Asm_Table).l,a0
	move.l	a0,(Asm_Table_Base-DT,a4)
	clr.l	(CURRENT_ABS_ADDRESS-DT,a4)
	move.l	d0,(INSTRUCTION_ORG_PTR-DT,a4)
	clr	(CurrentSection-DT,a4)
	bsr.l	INPUTTEXT_NOTEXT
	cmp.b	#$1B,d0
	beq.b	C1BA16
	jsr	(Assemble_cur_line).l
	bsr	Mon_scrollup
	tst.b	d0					; *** Scrolled ?
	bne.b	NoDissEnter_Scroll			; ***
	move.l	#-1,reset_pos				; ***
	rts						; ***
NoDissEnter_Scroll:
	bsr.b	NoDiss_Scroll				; ***
C1BA16:	bra.b	NoDiss_Scroll				; ***

;******** Diss druk line ********

DissDrukline:
;	move.l	a1,-(sp)
	move.l	a5,d0

	lea	(regel_buffer-DT,a4),a3
	move.l	a3,a1
	jsr	(Zet_D0_Om_inA3).l

	move.b	#" ",(a3)+

	movem.l	d3/d6/d7/a1/a3,-(sp)
	jsr	(Diss_zetom2ascii).l
	movem.l	(sp)+,d3/d6/d7/a1/a3

;	moveq	#64-1,d1
	move.w	(Scr_br_chars-DT,a4),d1
	sub.w	#10,d1
.druk_lopje:
	move.b	(a0)+,d0
	beq.b	DissDump_cl2eol
	move.b	d0,(a3)+
	dbf	d1,.druk_lopje

	move.b	#$00BB,(a3)+
	bra.b	Dissklaar

DissDump_cl2eol:
	move.b	#' ',(a3)+
	dbra	d1,DissDump_cl2eol

Dissklaar:
	move.b	#0,(a3)+
	move.w	(Scr_br_chars-DT,a4),d6
	bsr	Sol_druk_line	;aantal=d6 buff=a1
	rts
	
;************

MON_CLEARCACH:
	lea	(L29BE8-DT,a4),a0
	move	#25-1,d0
	moveq	#-1,d1
C1BA86:
	move	d1,(a0)+
	dbra	d0,C1BA86
	clr.l	(L29BE4-DT,a4)
	rts

C1BA92:
	move.l	a5,-(sp)
	sub	#$0032,a5
	move.l	(L29BE4-DT,a4),d2
	move.l	a5,(L29BE4-DT,a4)
	lea	(L29BE8-DT,a4),a0
	sub.l	a5,d2
	beq.b	C1BAE4
	bmi.b	C1BAC6
	move.l	a0,a1
	add	#$0032,a0
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
	move	#$FFFF,-(a0)
	bra.b	C1BAB4

C1BAC6:
	neg.l	d2
	move.l	a0,a1
	add	#$0032,a1
	move.l	a0,a2
	add.l	d2,a2
C1BAD2:
	cmp.l	a1,a0
	beq.b	C1BAE4
	cmp.l	a1,a2
	bcc.b	C1BADE
	move	(a2)+,(a0)+
	bra.b	C1BAD2

C1BADE:
	move	#$FFFF,(a0)+
	bra.b	C1BAD2

C1BAE4:
	move.l	(sp)+,a5
	rts

C1BAE8:
	move.l	(L29BE4-DT,a4),a0
	move.l	a0,a1
	cmp.l	a1,a5
	bcs.b	C1BB16
	add	#$0032,a1
	cmp.l	a1,a5
	bcc.b	C1BB16
	lea	(L29BE8-DT,a4),a1
	move.l	a5,d0
	sub.l	a0,d0
	add	d0,a1
	move	(a1),d1
	bpl.b	C1BB14
	move.l	a1,-(sp)
	jsr	(DISLENGTH_A5).l
	move.l	(sp)+,a1
	move	d1,(a1)
C1BB14:
	rts

C1BB16:
	jmp	(DISLENGTH_A5).l


DissBack1line:
	bsr	C1BA92
	moveq	#10,d2
C1BB22:
	moveq	#10,d3
	movem.l	d2-d6/a5,-(sp)
	sub.l	d2,a5
	bsr.b	C1BAE8
	movem.l	(sp)+,d2-d6/a5
	cmp	d2,d1
	bne.b	C1BBA6
C1BB34:
	moveq	#10,d4
	movem.l	d2-d6/a5,-(sp)
	sub.l	d2,a5
	sub.l	d3,a5
	bsr.b	C1BAE8
	movem.l	(sp)+,d2-d6/a5
	cmp	d3,d1
	bne.b	C1BBA2
C1BB48:
	moveq	#10,d5
	movem.l	d2-d6/a5,-(sp)
	sub.l	d2,a5
	sub.l	d3,a5
	sub.l	d4,a5
	bsr.b	C1BAE8
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
	bsr	C1BAE8
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
	bsr	C1BAE8
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
	move	(MON_EDIT_POSITION-DT,a4),d0
	add	#10,d0
	move	d0,(Cursor_col_pos-DT,a4)
	rts

AsciiKeys:
	cmp.b	#$80,d0
	beq.b	C1BBF6
	move.l	#-1,reset_pos		; ***
	cmp.b	#8,d0
	beq.b	C1BBF0
	bsr.b	C1BC56
	br	C1BC84

C1BBF0:
	bsr.w	C1BC70
	moveq	#$20,d0
	bra.b	C1BC56

C1BBF6:
	moveq	#0,d0
	move.b	(edit_EscCode-DT,a4),d0
	cmp.b	#2,d0
	beq.b	C1BC70
	cmp.b	#3,d0
	beq.w	C1BC84
	cmp.b	#10,d0
	beq.b	C1BC2A
	cmp.b	#11,d0
	beq.b	C1BC40
	cmp.b	#6,d0
	beq.w	C1BC96
	cmp.b	#7,d0
	beq.b	C1BC7C
	cmp.b	#$57,d0
	beq	C1B6A2
	rts

C1BC2A:
	move.l	(RegelPtrsIn-DT,a4),-(sp)
	jsr	(RegTab_SETALLNOTUPD).l
	move.l	(sp)+,d0
	subq.l	#1,d0
	move.l	d0,(RegelPtrsIn-DT,a4)
	br	new2old_stuff

C1BC40:
	move.l	(RegelPtrsIn-DT,a4),-(sp)
	jsr	(RegTab_SETALLNOTUPD).l
	move.l	(sp)+,d0
	addq.l	#1,d0
	move.l	d0,(RegelPtrsIn-DT,a4)
	br	new2old_stuff

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

C1BC70:
	subq.w	#1,(MON_EDIT_POSITION-DT,a4)
	bmi.b	C1BC78
	rts

C1BC78:
	bsr	Mon_scrolldown
C1BC7C:
	move	#$003F,(MON_EDIT_POSITION-DT,a4)
	rts

C1BC84:
	addq.w	#1,(MON_EDIT_POSITION-DT,a4)
	cmp	#$0040,(MON_EDIT_POSITION-DT,a4)
	beq.b	C1BC92
C1BC90:
	rts

C1BC92:
	bsr	Mon_scrollup
C1BC96:
	clr	(MON_EDIT_POSITION-DT,a4)
	rts

;******* ASCII druk line *********

AsciiDrukline:
	move.l	a5,d0

	lea	(regel_buffer-DT,a4),a3
	move.l	a3,a1
	jsr	(Zet_D0_Om_inA3).l

	move.b	#' ',(a3)+
	move.b	#'"',(a3)+

	moveq	#64-1,d1
	btst	#0,(PR_OnlyAscii).l
	bne.b	.ascii_only
.print_chars:
	move.b	(a5)+,(a3)+
	dbra	d1,.print_chars

	bra.b	Asciiklaar

.ascii_only:
	moveq	#0,d0
	move.b	(a5)+,d0
	bmi.s	.geenascii
	cmp.b	#' ',d0
	bhs.b	.wel_ascii
.geenascii
	moveq	#'.',d0
.wel_ascii:
	move.b	d0,(a3)+
	dbra	d1,.ascii_only

Asciiklaar:
	move.b	#'"',(a3)+

	move.w	#75,d6
	bsr	Sol_druk_line	;aantal=d6 buff=a1
	rts


AsciiBack1line:
	sub	#64,a5
	rts

;************ BIN DUMP **************

com_BinDump:
	jsr	(GETNUMBERAFTEROK).l
C1BCFE:
	bne.b	.custom
	move.l	d0,(MEM_DIS_DUMP_PTR-DT,a4)
.custom:
	move.b	(OpperantSize-DT,a4),(MemDumpSize-DT,a4)
; *** Allow long words
;	cmp.b	#4,(MemDumpSize-DT,a4)
;	bne.b	.size
;	move.b	#2,(MemDumpSize-DT,a4)
;.size:
	moveq	#0,d0
	move.b	(MemDumpSize-DT,a4),d0
	bsr	hex_2_ascii
	clr	(MON_EDIT_POSITION-DT,a4)
	lea	(BinDump_stuff,pc),a0
	bra	enter_hex_mode			; ***

;************ HEX DUMP **************

com_hexdump:
	bne.b	.custom
	move.l	d0,(MEM_DIS_DUMP_PTR-DT,a4)
.custom:
	move.b	(OpperantSize-DT,a4),(MemDumpSize-DT,a4)
	moveq	#0,d0
	move.b	(MemDumpSize-DT,a4),d0
	bsr	hex_2_ascii		;adres i guess
	clr	(MON_EDIT_POSITION-DT,a4)
	lea	(Hexdump_stuff,pc),a0
	br	enter_hex_mode

HexCursor:
	move.l	(LineFromTop-DT,a4),d0
	add	d0,d0
	move	d0,(cursor_row_pos-DT,a4)


	moveq	#0,d0
	move	(MON_EDIT_POSITION-DT,a4),d0
	cmp	#' ',d0
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
	moveq	#0,d0
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
	move	#18,d2
C1BDD8:
	mulu	d2,d0
	add	d1,d0
	bra.b	C1BDEC

C1BDDE:
	moveq	#8,d2
	cmp.b	#1,(MemDumpSize-DT,a4)
	beq.b	C1BDEA
	moveq	#4,d2
	cmp.b	#4,(MemDumpSize-DT,a4)	; ***
	bne.b	C1BDEA			; ***
	moveq	#2,d2			; ***
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
	move.l	#-1,reset_pos		; ***
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
	bcc.w	C1BE3C
	cmp.b	#8,d0
	beq	C1C008
	cmp.b	#"0",d0			; ***
	bcs.b	C1BE3A
	cmp.b	#"1",d0			; ***
	bls.w	C1BE66
C1BE3A:
	rts

C1BE3C:
	cmp.b	#8,d0
	beq	C1C030
	add	(MON_EDIT_POSITION-DT,a4),a1
	sub	#32,a1			; ***
	move.b	d0,(a1)
	addq.w	#1,(MON_EDIT_POSITION-DT,a4)
	cmp	#36,(MON_EDIT_POSITION-DT,a4)		; ***
	bcc.b	C1BE5C
	rts

C1BE5C:
	move	#32,(MON_EDIT_POSITION-DT,a4)		; ***
	br	Mon_scrollup

C1BE66:
	sub.b	#"0",d0					; ***
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
	beq	C1BEFA
	cmp.b	#11,d0
	beq	C1BF10
	cmp.b	#6,d0
	beq.b	C1BEF4
	cmp.b	#7,d0
	beq.b	C1BEDA
	cmp.b	#$57,d0
	beq	C1B6A2
	rts

C1BECC:
	subq.w	#1,(MON_EDIT_POSITION-DT,a4)
	bmi.w	C1BED6
	rts

C1BED6:
	bsr	Mon_scrolldown
C1BEDA:
	move.w	#35,(MON_EDIT_POSITION-DT,a4)		; ***
	rts

C1BEE2:
	addq.w	#1,(MON_EDIT_POSITION-DT,a4)
	cmp.w	#36,(MON_EDIT_POSITION-DT,a4)		; ***
	beq.b	C1BEF0
	rts

C1BEF0:
	bsr	Mon_scrollup
C1BEF4:
	clr	(MON_EDIT_POSITION-DT,a4)
	rts

C1BEFA:
	move.l	(RegelPtrsIn-DT,a4),-(sp)
	jsr	(RegTab_SETALLNOTUPD).l
	move.l	(sp)+,d0
	subq.l	#1,d0
	move.l	d0,(RegelPtrsIn-DT,a4)
	br	new2old_stuff

C1BF10:
	move.l	(RegelPtrsIn-DT,a4),-(sp)
	jsr	(RegTab_SETALLNOTUPD).l
	move.l	(sp)+,d0
	addq.l	#1,d0
	move.l	d0,(RegelPtrsIn-DT,a4)
	br	new2old_stuff

HexKeys:
	cmp.b	#$80,d0
	beq.w	C1BFA4
	move.l	#-1,reset_pos		; ***
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
	beq.b	C1BFDC
	cmp.b	#3,d0
	beq.b	C1BFF0
	cmp.b	#10,d0
	beq	C1BC2A
	cmp.b	#11,d0
	beq	C1BC40
	cmp.b	#6,d0
	beq.b	C1C002
	cmp.b	#7,d0
	beq.b	C1BFE8
	cmp.b	#$57,d0
	beq	C1B6A2
	rts


C1BFDC:
	subq.w	#1,(MON_EDIT_POSITION-DT,a4)
	bmi.b	C1BFE4
	rts

C1BFE4:
	bsr	Mon_scrolldown
C1BFE8:
	move	#$002F,(MON_EDIT_POSITION-DT,a4)
	rts

C1BFF0:
	addq.w	#1,(MON_EDIT_POSITION-DT,a4)
	cmp	#$0030,(MON_EDIT_POSITION-DT,a4)
	beq.b	C1BFFE
	rts

C1BFFE:
	bsr	Mon_scrollup
C1C002:
	clr	(MON_EDIT_POSITION-DT,a4)
	rts

C1C008:
	subq.w	#1,(MON_EDIT_POSITION-DT,a4)
	bmi.b	C1C010
	rts

C1C010:
	move	#$001F,(MON_EDIT_POSITION-DT,a4)
	br	Mon_scrolldown

C1C01A:
	addq.w	#1,(MON_EDIT_POSITION-DT,a4)
	cmp	#32,(MON_EDIT_POSITION-DT,a4)
C1C024:
	bcc.b	C1C028
	rts

C1C028:
	clr	(MON_EDIT_POSITION-DT,a4)
	br	Mon_scrollup

C1C030:
	subq.w	#1,(MON_EDIT_POSITION-DT,a4)
	cmp	#32,(MON_EDIT_POSITION-DT,a4)
	bcs.b	C1C03E
	rts

C1C03E:
	move	#47,(MON_EDIT_POSITION-DT,a4)
	br	Mon_scrolldown

C1C048:
	addq.w	#1,(MON_EDIT_POSITION-DT,a4)
	cmp	#48,(MON_EDIT_POSITION-DT,a4)
	bcc.b	C1C056
	rts

C1C056:
	move	#32,(MON_EDIT_POSITION-DT,a4)
	br	Mon_scrollup

;********* Bin druk line ***********

BinDrukline:
	move.l	a5,d0
;	lea	(DIS_PRINT_BUFFER_0-DT,a4),a3
	lea	(regel_buffer-DT,a4),a3
	move.l	a3,a1
	jsr	(Zet_D0_Om_inA3).l

	moveq.l	#0,d6
;	move.l	a1,d7

	move.b	#' ',(a3)+

	lea	(ABCDEF.MSG).l,a2
	moveq	#4-1,d1
	moveq	#0,d4
	move.b	(MemDumpSize-DT,a4),d4
	subq.w	#1,d4
	add.w	d4,d4
	sub.w	d4,d1				; ***
	cmp.b	#4,(MemDumpSize-DT,a4)		; ***
	bne.b	.binlopje1			; ***
	clr.w	d1				; ***
.binlopje1:
	move.b	(MemDumpSize-DT,a4),d4
	subq.w	#1,d4
	move.b	#'%',(a3)+
.binlopje2:
	moveq	#8-1,d2
.binlopje3:
	moveq	#0,d0
	move.b	(a5),d0
	asr.b	d2,d0
	and	#1,d0
	move.b	(a2,d0.w),(a3)+
	dbra	d2,.binlopje3

	addq.w	#1,a5
	tst	d4
	beq.b	.binskip
	subq.w	#1,d4
	bra.b	.binlopje2
	tst.w	d1				; ***
	ble.b	.noskip				; ***
.binskip:
	move.b	#" ",(a3)+
	dbra	d1,.binlopje1
.noskip:

	; *** Display ASCII
	move.b	#'"',(a3)+

	move	#4-1,d1
	subq	#4,a5				; ***
	btst	#0,(PR_OnlyAscii).l
	bne.b	BinAscii7
.binlopje4:
	move.b	(a5)+,(a3)+
	dbf	d1,.binlopje4
	bra.b	Binklaar

BinAscii7:
	moveq	#0,d0
	move.b	(a5)+,d0
	bmi.s	.geenascii
	cmp.b	#' ',d0
	bge.b	.wel_ascii
.geenascii
	moveq	#'.',d0		;only ascii7 char
.wel_ascii:
	move.b	d0,(a3)+
	dbf	d1,BinAscii7

Binklaar:
	move.b	#'"',(a3)+

	move.w	#55,d6
	move.b	(MemDumpSize-DT,a4),d0
	cmp.b	#1,d0
	beq.s	.bytesize
	subq.w	#4,d6					; ***
.bytesize:
	cmp.b	#4,d0
	bne.s	.longwsize
	subq.w	#2,d6					; ***
.longwsize:
	bra	Sol_druk_line	;aantal=d6 buff=a1	; ***
;	rts						; ***

BinBack1line:
	subq	#4,a5					; ***
	rts


;****** hex druk line ******

HexDrukline:
	move.l	a5,d0		;mem adres
;	lea	(DIS_PRINT_BUFFER_0-DT,a4),a3

	lea	(regel_buffer-DT,a4),a3
	move.l	a3,a1
	jsr	(Zet_D0_Om_inA3).l


	move.b	#' ',(a3)+

	lea	(ABCDEF.MSG).l,a2
	moveq	#16-1,d1
	move.b	(MemDumpSize-DT,a4),d4
.lopje:
	moveq	#0,d0
	move.b	(a5)+,d0
	moveq	#15,d2
	and	d0,d2
	lsr.w	#4,d0
	move.b	(a2,d0.w),(a3)+

	moveq	#0,d0
	move.b	(a2,d2.w),(a3)+

	subq.b	#1,d4
	bne.b	.skip
	move.b	#' ',(a3)+
	move.b	(MemDumpSize-DT,a4),d4
.skip:
	dbra	d1,.lopje

	move.b	#'"',(a3)+

HexAscii8:
	sub	#16,a5
	moveq	#15,d1
	btst	#0,(PR_OnlyAscii).l
	bne.b	HexAscii7
.lopje:
	moveq	#0,d0
	move.b	(a5)+,(a3)+

	dbra	d1,.lopje

	bra.b	Hexklaar

HexAscii7:
	moveq	#0,d0
	move.b	(a5)+,d0

	bmi.s	.geenascii
	cmp.b	#' ',d0
	bhs.b	.wel_ascii
.geenascii
	moveq	#'.',d0		;only ascii7 char
.wel_ascii:
	move.b	d0,(a3)+
	dbra	d1,HexAscii7

Hexklaar:
	move.b	#'"',(a3)+

	moveq.l	#0,d0
	move.b	(MemDumpSize-DT,a4),d0
	lea	MemOffsets(pc),a0
	move.w	#75,d6
	sub.w	(a0,d0),d6
	bra	Sol_druk_line	;aantal=d6 buff=a1	; ***

;	rts				; ***

MemOffsets
	dc.w	0
	dc.w	8
	dc.w	12
	dc.w	0

HexBack1line:
	sub	#16,a5
	rts



;*********** afdruk test version ************

Sol_druk_line:
	movem.l	d0-a6,-(sp)

	move.l	a1,a5		;textbuffer

	move.l	(GfxBase-DT,a4),a6
	move.l	(Rastport-DT,a4),a1
	
	moveq.l	#0,d0		;x
	move.w	d7,d1		;y

	mulu.w  (EFontSize_y-DT,a4),d1

	add.w	(Scr_Title_sizeTxt-DT,a4),d1	;!2
	jsr	(_LVOMove,a6)	; ***

	lea	(a5),a0
;	lea	(regel_buffer-DT,a4),a0
	move.w	d6,d0		;count
	jsr	(_LVOText,a6)		; ***

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


IFFRegsBase:	dcb.l	15,0

ColorOffset:	dc.w	0	;$180-$1be
StartBank:	dc.w	0	;0-7

palet12bit:	dc.w	0

IncIFFPal:
	lea	SourceCode-DT(A4),A1
	JSR	OntfrutselNaam
	JSR	MenNemeNaamEnPad

	clr	palet12bit
	clr	ColorOffset
	clr	StartBank

	cmp.b	#$2C,(a6)	;, geen comma ,
	bne	ColorList12bit	;dus gewoon 12 bits colorlist
	addq.w	#1,a6
	move.b	(a6)+,d0
	lsl.w	#8,d0
	move.b	(a6)+,d0
	cmp	#'12',d0	;12 bits colorlist
	beq.b	ColorList12bit
	cmp	#'24',d0	;24 bits colorlist
	beq.b	ColorList24bit

	and	#$DFDF,d0	;hoofdletters
	cmp	#'CE',d0	;CE copper ECS
	beq.b	coppercols12bit

	cmp	#'CA',d0	;CA copper AGA
	beq.b	coppercols24bit

	br	errorinsyntax

ColorList12bit:
	clr	palet12bit
	bra.b	ColorList

ColorList24bit:
	move	#1,palet12bit
	bra.b	ColorList

coppercols24bit:
	move	#1,palet12bit
	cmp.b	#',',(a6)
	bne.s	coppercols12bit		;geen bank offset
	addq.w	#1,a6
	moveq.l	#0,d0
	move.b	(a6)+,d0
	cmp.b	#'0',d0
	blo.s	nogood
	cmp.b	#'7',d0
	bhi.s	nogood
	sub.b	#'0',d0
	move	d0,StartBank		;wel bank offset
	br	coppercols12bit
nogood:
	subq.w	#2,a6			;mischien alleen color offset ?
coppercols12bit:
	move	#$180,ColorOffset	;default
	jsr	PARSE_GET_KOMMA_IF_ANY
	bne.s	ColorList
	JSR	Parse_GetDefinedValue
	cmp	#$180,d3
	blo.s	errorinsyntax
	cmp	#$180+32*2,d3
	bhs.s	errorinsyntax

	move	D3,ColorOffset
ColorList:

	MOVEM.L	d0-a6,IFFRegsBase	; ***
	MOVEM.L	D0/A6,-(SP)
	JSR	OpenOldFile
	MOVE.L	Bestand-DT(a4),D1
	LEA	ParameterBlok-DT(a4),A1
	MOVE.L	A1,D2
	MOVE.L	#$2000,D3		;8 kb
	MOVE.L	DosBase-DT(a4),A6
	JSR	(_LVORead,A6)		; ***
	MOVEM.L	(SP)+,D0/A6
	LEA	ParameterBlok-DT(a4),A1
	move	#($2000/2-1)-2,D6
SearchColMap:
	CMP.L	#"CMAP",(A1)
	BEQ.S	OntravelKleuren
	ADDQ.W	#2,A1
	DBRA	D6,SearchColMap

	BRA	ErrorOpenIFF

errorinsyntax:
	jmp	HandleMacroos

;************ INCIFF PALET **********

OntravelKleuren:
	ADDQ.W	#4,A1
	MOVE.L	(A1)+,D6		;CMAP size

	tst	palet12bit
	bne	OntravelAGAkleuren

	DIVU	#3,D6
	EXT.L	D6
	cmp	#32,d6			;added this for EHB
	bls.s	nrcolsOK
	tst	ColorOffset
	BEQ.S	nrcolsOK
	move	#32,d6
nrcolsOK:
	ADD.L	D6,D6
	tst	ColorOffset
	BEQ.S	GenereerColorlist
	ADD.L	D6,D6			;copperpallet
GenereerColorlist:
	MOVE.L	D6,FileLength-DT(a4)
	tst	ColorOffset
	BEQ.S	GeenCopperPallet
	LSR.L	#1,D6
GeenCopperPallet:
	LSR.L	#1,D6			;aantal woorden (nr colors)

	BTST	#AF_BRATOLONG,d7
	BNE	CloseIFFBestand
	tst	d7	;passone
	BMI	CloseIFFBestand

	SUBQ.L	#1,D6			;nr cols
	MOVE.L	INSTRUCTION_ORG_PTR-DT(A4),A0
	ADD.L	CURRENT_ABS_ADDRESS-DT(A4),A0
NextColor:
	tst	ColorOffset
	BEQ.S	ColorLijst
	move	ColorOffset(PC),(A0)+
	ADDQ.W	#2,ColorOffset		;hmm moet eigenlijk niet hoger worden
ColorLijst:				;dan $180+32*2-2 = $1be
	MOVEQ	#0,D0

	MOVE.B	(A1)+,D0
	AND.B	#$F0,D0
	MOVE.B	(A1)+,D1
	AND.B	#$F0,D1
	MOVE.B	(A1)+,D2
	AND.B	#$F0,D2
	LSL.W	#4,D0
	LSR.B	#4,D2
	OR.B	D2,D1
	OR.B	D1,D0
	move	D0,(A0)+
	DBRA	D6,NextColor

	BRA	CloseIFFBestand

;*********** INCIFF AGA PALET ************

OntravelAGAkleuren:
	movem.l	d4-d5,-(sp)

	move	StartBank(pc),d5
	or.w	ColorOffset(pc),d5
	tst	d5
	beq	MakeColorList24bit

	tst	ColorOffset
	bne.s	nodefaultoffset
	move	#$180,ColorOffset
nodefaultoffset:

	tst	StartBank
	bne.s	nodefaultoffset2
	move	#0,StartBank
nodefaultoffset2:

	move	ColorOffset(pc),coloffset2

	divu	#3,D6
	ext.l	D6
	move.l	d6,d5
	add.l	D6,D6
	add.l	D6,D6
	add.l	D6,D6	;24bit

	move	d6,d4
	and	#256-1,d4		;voor als dr minder dan 32 colors zijn
	lsr.w	#3,d4			;bij de helft naar de upperbits
	subq.l	#1,D4
	move	d4,nrcols

	add	#31,d5				;minstens 1 bank
	lsr.l	#5,d5				;hoeveel banken
	lsl.l	#3,d5				;4*2

	MOVE.L	D6,FileLength-DT(a4)
	add.l	d5,FileLength-DT(a4)		;bank switching ook meetellen

	LSR.L	#2,D6

	move	StartBank(pc),d5		;bij bank 0 beginnen
	lsl.w	#8,d5
	lsl.w	#5,d5

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

	move.l	a1,helpptrAGA
	
	moveq.l	#4,d4
AGAkleurloopje:
	cmp	nrcols(pc),d6
	beq.s	nextbank
	cmp	#$1be,ColorOffset
	bls.s	Bovenste4Bits
nextbank:
	move	coloffset2(pc),ColorOffset

	tst	d4
	beq.s	AGAonderste

	moveq.l	#0,d4
	
	move.l	helpptrAGA(pc),a1	;pointer weer terug zetten begin bank
	move	#$0106,(a0)+
	move	d5,(a0)
	or.w	#$0e40,(a0)+		;bovenste bits

	move	#$180,coloffset2	;reset voor de rest vand e colrbanks

	bra.b	Bovenste4Bits
AGAonderste:
	moveq.l	#4,d4

	move.l	a1,helpptrAGA
	
	add	#$2000,d5		;select next bank
	move	#$0106,(a0)+
	move	d5,(a0)
	or.w	#$0c40,(a0)+		;onderste bits eerst


Bovenste4Bits:
	move	ColorOffset(PC),(A0)+
	ADDQ.W	#2,ColorOffset

	MOVEQ	#0,D0

	MOVE.B	(A1)+,D0	;red
	lsr.b	d4,d0
	AND.B	#$F,D0
	MOVE.B	(A1)+,D1	;green
	lsr.b	d4,d1
	AND.B	#$F,D1
	MOVE.B	(A1)+,D2	;blue
	lsr.b	d4,d2
	AND.B	#$F,D2

	LSL.W	#8,D0
	LSL.B	#4,D1
	OR.B	D2,D1
	OR.B	D1,D0

	move	D0,(A0)+
	DBRA	D6,AGAkleurloopje

	bra	EindeAGAError

coloffset2:	dc.w	0
nrcols:		dc.w	0
helpptrAGA:	dc.l	0

;************ 24 bit color list *************

MakeColorList24bit:
	divu	#3,D6
	ext.l	D6

	add.l	D6,D6		;nrcols*4
	add.l	D6,D6

	move.l	D6,FileLength-DT(a4)

	lsr.l	#2,D6			;aantal woorden (nr colors)

	BTST	#AF_BRATOLONG,d7
	BNE	EindeAGAError
	tst	d7	;passone
	BMI	EindeAGAError

	subq.l	#1,D6			;nr cols
	move.l	INSTRUCTION_ORG_PTR-DT(A4),A0
	add.l	CURRENT_ABS_ADDRESS-DT(A4),A0
NextColorAGA:
	move.b	#0,(a0)+
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
	JSR	(_LVOClose,A6)		; ***

;	jsr	close_bestand

	MOVE.L	FileLength-DT(a4),D0
	ADD.L	D0,INSTRUCTION_ORG_PTR-DT(A4)
	MOVEM.L	IFFRegsBase,d0-a6		; ***
	RTS

ErrorOpenIFF:
	MOVEM.L	IFFRegsBase,D0-A6		; ***
	JMP	ERROR_EndofFile

;********** STRIP IFF STUFF ***********

IncIFFStrip:
	lea	SourceCode-DT(A4),A1
	JSR	OntfrutselNaam
	JSR	MenNemeNaamEnPad
	
	MOVEM.L	d0-a6,IFFRegsBase		; ***

	JSR	OpenOldFile
	MOVE.L	Bestand-DT(a4),D1
	beq.s	striperror_openfile

	MOVE.L	DosBase-DT(a4),A6
	move	#$2000/4,d7
.striploop:
	MOVE.L	Bestand-DT(a4),D1
	lea	strip_buffer,a5
	move.l	a5,d2
	MOVEq.L	#4,D3			;4 bytes
	JSR	(_LVORead,A6)		; ***
	cmp.l	#4,d0			;# bytes gelezen
	bne.s	striperror_openfile
	
	CMP.L	#"BODY",(A5)
	BEQ.S	stripfoundbody
	dbf	d7,.striploop

	jsr	CloseIFFBestand
	JMP     ERROR_EndofFile

striperror_openfile:
	MOVEM.L	IFFRegsBase,D0-A6	; ***
	JMP	ERROR_EndofFile

stripfoundbody:
	MOVE.L	Bestand-DT(a4),D1
	move.l	#strip_buffer,d2
	MOVEq.L	#4,D3			;4 bytes
	MOVE.L	DosBase-DT(a4),A6
	JSR	(_LVORead,A6)		; ***
	cmp.l	#4,d0			;# bytes gelezen
	bne.s	striperror

	move.l	strip_buffer(pc),d7

	clr.l	FileLength-DT(A4)

	MOVEM.L	D0-A6,-(SP)

	MOVE.L	Bestand-DT(a4),D1	;bestand
	move.l	INSTRUCTION_ORG_PTR-DT(A4),d2	;buffer
	add.l	CURRENT_ABS_ADDRESS-DT(A4),d2
	MOVE.L	d7,D3			;size
	MOVE.L	d7,D0			;size

;	jsr	read_nr_d3_bytes
;	MOVEq.L	#4,D3			;size

	MOVE.L	DosBase-DT(a4),A6
;	JSR	-$002A(A6)		;read
;	cmp.l	d7,d0
;	bne.s	striperror
	move.l	d0,FileLength-DT(A4)

	MOVEM.L (SP)+,D0-A6

	BRA     CloseIFFBestand

striperror:
	MOVEM.L (SP)+,D0-A6
	jsr	CloseIFFBestand
	JMP     ERROR_EndofFile

strip_buffer:	dc.l	0

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
	moveq.l	#2,d1
	jsr	_LVODelay(a6)

	move.l  IntBase,a6
	move.l	(MainWindowHandle-DT,a4),a0
	jsr	(_LVOActivateWindow, a6)	; ***
.NoMsgInBase:
	movem.l	(sp)+,d0-a6
	rts


Plugs_update_info:
	move.l	IntBase,a6
	move.b	#'1',PW_IText0
	move.w	#6-1,d7
	moveq.l	#0,d5
	move.w	(EFontSize_y-DT,a4),d4
	add.w	#6,d4
	ext.l	d4
.lopje:
	move.l	Plugs_rp,a0
	lea.l   Plugs_Itext,a1
	moveq.l	#0,d0
	move.l	d5,d1
	jsr	_LVOPrintIText(a6)
	add.l	d4,d5

	add.b	#1,PW_IText0
	dbf	d7,.lopje
	rts

Plugs_WindowTags:
pw_x:
	DC.L    WA_Left,0	;x
pw_y:
	DC.L    WA_Top,32+202+11	;y
pw_br:
	DC.L    WA_Width,22*8+6	;br
pw_hg:
	DC.L    WA_Height,6*(8+6)+11-1	;hg
	DC.L    WA_IDCMP,IDCMP_ACTIVEWINDOW|IDCMP_CLOSEWINDOW
	DC.L    WA_Flags,WFLG_CLOSEGADGET|WFLG_DEPTHGADGET|WFLG_DRAGBAR|WFLG_GIMMEZEROZERO
	DC.L    WA_Title,Plugs_WTitle
Plugs_SC:
	DC.L    $80000079,0
	DC.L    $00000000

Plugs_WTitle:
	DC.B    'Active Plugin''s.',0


	cnop	0,4
Plugs_winbase:	dc.l	0
Plugs_rp:	dc.l	0
Plugs_msg_port:	dc.l	0


Plugs_Itext:
    DC.B    1,0
    DC.B    $00
    DC.B    0
    DC.W    4,6
    DC.L    Editor_Font
    DC.L    PW_IText0
    DC.L    0

PW_IText0:
    DC.B    '1 < No plugin loaded >',0

	cnop	0,4

open_plugs_win:
	tst.l	Plugs_winbase
	beq.s	.okay
	bsr	close_plugs_win		;voor de zekerheid..
	rts
.okay:
	movem.l	d0-a6,-(sp)

	move.w	(EFontSize_y-DT,a4),d2
	add.w	#6,d2
	mulu.w	#6,d2
	add.w	(Win_BorBottom-DT,a4),d2
	add.w	(Scr_Title_size-DT,a4),d2
	add.w	#8,d2	;marge

	moveq.l	#0,d0
	move.w	(Scr_breedte-DT,a4),d0	;center the picture

	move.w	(EFontSize_x-DT,a4),d1
	mulu.w	#22,d1
	add.w	(Win_BorHor-DT,a4),d1
	add.w	#10,d1	;marge

	sub.l	#16,d0			;16 puntjes van de linker kant
	sub.l	d1,d0

	move.l	d0,pw_x+4
	move.l	d1,pw_br+4
	move.l	d2,pw_hg+4

	move.l	ScreenBase,Plugs_SC+4
	move.l  IntBase,a6
	sub.l	a0,a0
	lea.l	Plugs_WindowTags,a1
	jsr	_LVOOpenWindowTagList(a6)
	move.l	d0,Plugs_winbase

	move.l	d0,a0
	move.l	($0032,a0),Plugs_rp

	move.l  86(a0),Plugs_msg_port

	move.l  (KEY_PORT-DT,a4),86(a0)

	move.l  GadToolsBase,a6
	move.l	(MainVisualInfo-DT,a4),PW_NR+4
	move.l  (MainVisualInfo-DT,a4),PW_IR+4

	move.l  50(a0),a0
	lea.l   PW_NR,a1
	move.w  #0,d0		;x
	move.w  #0,d1		;y
	move.w	(EFontSize_x-DT,a4),d2
	mulu.w  #22,d2
	add.w	#8+2,d2	;marge

	move.w	(EFontSize_y-DT,a4),d3
	add.w	#6,d3
	mulu.w	#6,d3
	add.w	#7,d3	;marge
	jsr     _LVODrawBevelBoxA(a6)

	move.w	#6-1,d7

	moveq.l	#0,d6
	move.w	(EFontSize_y-DT,a4),d6
	add.w	#6,d6

	move.w	(EFontSize_x-DT,a4),d0
	add.w	d0,d0
	add.w	(Win_BorLeft-DT,a4),d0
	move.w	d0,d4
	sub.w	#2,d4
	
	move.w  #4,d5			;y

	move.w	(EFontSize_x-DT,a4),d2
	mulu.w	#20,d2
	add.w	#4,d2

	move.w	d6,d3			;hg
	subq.w	#2,d3
.lopje:
	move.l  Plugs_rp,a0
	lea.l   PW_IR,a1

	move.w	d4,d0		;x
	move.w	d5,d1		;y

	jsr     _LVODrawBevelBoxA(a6)
	add.w	d6,d5

	dbf	d7,.lopje

	bsr	Plugs_update_info

	move.l  IntBase,a6
	move.l	(MainWindowHandle-DT,a4),a0
	jsr	(_LVOActivateWindow,a6)		; ***

	movem.l	(sp)+,d0-a6
	rts



close_plugs_win:
	movem.l	d0-a6,-(sp)

	move.l	Plugs_winbase,a0
	cmp.l	#0,a0
	beq.s	.aldicht

	move.l  Plugs_msg_port,86(a0)

	move.l	IntBase,a6
	jsr	_LVOCloseWindow(a6)
	clr.l	Plugs_winbase
	clr.l	Plugs_rp

.aldicht:
	movem.l	(sp)+,d0-a6
	rts

;	ENDIF
	
;***************** PLUGS STUFF ********************


pluginlist:
	dc.l	-1
	dc.l	-1
	dc.l	-1
	dc.l	-1
	dc.l	-1
	dc.l	-1
	dc.l	-1
	dc.l	-1
	dc.l	-1
	dc.l	-1
	dc.l	-1


;	IFNE	useplugins

PlugIns:
	movem.l	d0-a6,-(sp)
	
	jsr	check_for_plugin
	tst.w	d0
	beq.w	gevonden
	movem.l	(sp)+,d0-a6
	jmp	HandleMacroos2

gevonden:
;	ADD.L	D1,INSTRUCTION_ORG_PTR-DT(A4)

	movem.l	(sp)+,d0-a6
	rts

errorstring:
	dc.b	$a,"Plugin not found!!",$a,0
pluginstring:
	dc.b	$a,"Plugin gevonden !!",$a,0
	cnop	0,4


check_for_plugin:
	lea	(SourceCode-DT,a4),a0
	lea	pluginfilename,a1
	move.w	#$5f5f,d4
.lopje:
	move.w	(a0)+,d0
	tst.w	d0
	bmi.s	.exitlopje
	and.w	d4,d0
	move.w	d0,(a1)+
	bra.b	.lopje

.exitlopje:
	and.w	d4,d0
	move.w	d0,(a1)+
	clr.b	(a1)

	lea	pluginlist,a2
.check_next:
	cmp.l	#-1,(a2)
	beq.s	.plugin_not_in_buf
	
	move.l	(a2),a1
	lea	8(a1),a1
	add.w	(a1),a1			;name
	addq.l	#4,a2			;next item

	lea	pluginfilename,a0
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

	
	moveq.l	#0,d0
	rts

	
.plugin_not_in_buf:
	lea	pluginfilename,a0
	bsr	printthetext
	lea	errorstring(pc),a0
	bsr	printthetext

	moveq.l	#1,d0
	rts


pluginpath:
	dc.b	"dh1:asmpro_os/plugins/"
pluginfilename:
;	dc.b	"SOLO",0
	blk.b	80,0

	cnop	0,4

pluginlist:
	dc.l	pi_incspace
	dc.l	-1
	dc.l	-1
	dc.l	-1
	dc.l	-1
	dc.l	-1
	dc.l	-1
	dc.l	-1
	dc.l	-1
	dc.l	-1

	dc.l	-1

	
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
	moveq.l	#0,d0	;error code
	rts
	
destructor:
	moveq.l	#0,d0	;error code
	rts
	
incspace:
	moveq.l	#0,d0	;error code
	rts



	ENDC

;******** END PLUG-IN STUFF ***********

PW_NR:
	DC.L	$80080034,$00000000	;visualinfo
	dc.l	$00000000
PW_IR:
	DC.L	$80080034,$00000000	;visual
	dc.l	$80080033,1		;
	dc.l	$00000000

;**************** LOGIN WINDOWTJE *****************


OpenLoginWindow:
	move.l	4.w,a6
	move.l	#$20001,d1
	jsr	(_LVOAvailMem,a6)	; ***
	lsr.l	#8,d0
	lsr.l	#2,d0

	cmp.l	#$7fff,d0
	blo.s	.noprobs3
	move.l	#$7fff,d0	;32mb is max (nu nog)
.noprobs3:
	move.l	d0,_pubmax

	move.l	#$20000,d1
	jsr	(_LVOAvailMem,a6)	; ***
	lsr.l	#8,d0
	lsr.l	#2,d0
	cmp.l	#$7fff,d0
	blo.s	.noprobs2
	move.l	#$7fff,d0	;32mb is max (nu nog)
.noprobs2:
	move.l	d0,_absmax

	move.l	#$20002,d1
	jsr	(_LVOAvailMem,a6)	; ***
	lsr.l	#8,d0
	lsr.l	#2,d0
	move.l	d0,_chipmax
	move.l	d0,_chipmemTags+4

	move.l	#$20004,d1
	jsr	(_LVOAvailMem,a6)	; ***
	lsr.l	#8,d0
	lsr.l	#2,d0
	cmp.l	#$7fff,d0
	blo.s	.noprobs
	move.l	#$7fff,d0	;32mb is max (nu nog)
.noprobs:
	move.l	#_memorytypeLabels,LoginGTags+4
	move.l	d0,_fastmax
	move.l	d0,_fastmemTags+4
	bne.b	.NoFastMem			; Check for fast mem
	move.l	#2,_memtype
	move.l	_chipmax,_memamount
	move.l	#_memorytypeLabelsNoFast,LoginGTags+4
.NoFastMem:
	move.l	_StackSize,d0
	lsr.l	#8,d0
	lsr.l	#2,d0
	move.l	d0,_stack_sizeTags+4

	moveq.l	#0,d0
	move.l	_memamount,d0
	move.l	d0,_curamountTags+4

	move.l	_memtype(pc),d0
	lsl.l	#2,d0
	lea	_absmax(pc),a0
	move.l	(a0,d0),_maxamountTags+4

	lsr.l	#1,d0
	lea	memstuff,a0
	move.w	(a0,d0),d0
	move.l	d0,_acticmx+4

	move.l	#1,_absolute_adrTags+4
	cmp.w	#3,d0
	bne.s	.notme
	move.l	#0,_absolute_adrTags+4
.notme:
	lea	_absolute_adrString,a1
	move.b	#'$',(a1)+
	move.l	_absmemadr,d0
	bsr	van_d0_2_string
	move.b	#0,(a1)

	move.w	EFontSize_x,d0
	mulu.w	#40,d0
	move.w	d0,LoginWidth
	move.w	Scr_breedte,d1
	sub.w	d0,d1
	lsr.w	#1,d1
	move.w	d1,LoginLeft

	move.w	EFontSize_y,d0
	addq.w	#3,d0
	mulu.w	#14,d0
	addq.l	#4,d0
	move.w	d0,LoginHeight
	move.w	Scr_hoogte,d1
	sub.w	d0,d1
	lsr.w	#1,d1
	move.w	d1,LoginTop

	bsr	position_gadgets

	bsr	SetupScreen
	bsr	OpenTheLoginWindow
	tst.w	d0
	bne.s	li_erroropenwin
li_waitbeforclose:
	move.l	DosBase,a6
	moveq.l	#4,d1		;delay
	jsr	(_LVODelay,a6)		; ***

	move.l 	GadToolsBase,a6
	move.l	LoginWnd(pc),a0
	move.l	86(a0),a0
	jsr	_LVOGT_GetIMsg(a6)	;getmsg
	move.l	d0,message
	beq.s	li_nointuiactivity
	bsr	li_checkmenu	;check if menu selected

	tst.w	d0		;leave now !!!
	bne.s	li_exit
	
li_nointuiactivity:
	btst	#7,$bfe001			; WHAT'S THAT !!!
	bne.s	li_waitbeforclose
li_exit:

	lea	(Variable_base).l,a4

	move.l	LoginGadgets+5*4(pc),a0
	move.l	34(a0),a0
	move.l	(a0),a6
	jsr	Convert_A2I_sub
;	jsr	Convert_A2I
	move.l	d3,_absmemadr

	move.l	_memtype,d0
	lsl.l	#2,d0
	lea	_absmax,a0
	move.l	_memamount,d1
	cmp.l	(a0,d0.w),d1
	bls.s	.nixmis
	move.l	(a0,d0.w),_memamount
.nixmis:	

	bsr	CloseLoginWindow
li_erroropenwin
	moveq.l	#0,d0
	rts

depth:	dc.b	0

	cnop	0,4
message:	ds.l	1
class:		dc.l	0
code:		dc.w	0
gadgetnr:	ds.l	1

_absmax:	dc.l	0
_pubmax:	dc.l	0
_chipmax:	dc.l	0
_fastmax:	dc.l	0
_StackSize	dc.l	0

_memtype:	dc.l	0
_memamount:	dc.l	99
_absmemadr:	dc.l	$12345

memstuff:
	dc.w	3
	dc.w	2
	dc.w	0
	dc.w	1

memstuff2:
	dc.b	'APCF'

;************ check the messies ***********

li_checkmenu:
	clr.l	class
	clr.l	code
	move.l	d0,a0		;msg ptr
	moveq.l	#0,d1
	moveq.l	#0,d2
	moveq.l	#0,d3
	move.l	20(a0),d1	;class
	move.w	24(a0),d2	;code
	move.l	a0,a5
	
	move.l	d1,class
	move.w	d2,code

	move.l 	GadToolsBase,a6
	move.l	message(pc),a1
	jsr	_LVOGT_ReplyIMsg(a6)	;replyImsg

	moveq.l	#0,d0
	move.l	message(pc),a1

	move.l	class,d1
	and.l	#$20!$40,d1
	beq.w	nobutton
	move.l	28(a1),a1		;IAdress (voor gadget ID)
	move.w	38(a1),gadgetnr		;gadgetID

	        cmp.w   #GD__memorytype,gadgetnr
	        bne.w	.nextbutton1
; new selection code
		move.w	90(a1),d1
		move.l	#1,_absolute_adrTags_change+4	; no abs adr.
		moveq.l	#0,d0
		move.l	_memamount,d0
		lea.l	SelectMemTable(pc),a0
		cmp.l	#_memorytypeLabelsNoFast,LoginGTags+4
		bne.b	.JumpNoFast
		lea.l	SelectMemTableNoFast(pc),a0
.JumpNoFast:	add.w	d1,d1
		add.w	d1,d1
		move.l	(a0,d1.w),a0
		jsr	(a0)

.klaar:		move.l 	GadToolsBase,a6
		move.l	LoginGadgets+1*4(pc),a0
		move.l	LoginWnd(pc),a1
		sub.l	a2,a2
		lea	_maxamountTags(pc),a3		; set slide
		jsr	_LVOGT_SetGadgetAttrsA(a6)

;		move.l 	_GadToolsBase,a6
		move.l	LoginGadgets+5*4(pc),a0
		move.l	LoginWnd(pc),a1
		sub.l	a2,a2				; set absolute
		lea	_absolute_adrTags_change(pc),a3	; textbox
		jsr	_LVOGT_SetGadgetAttrsA(a6)

.nextbutton1:
	        cmp.w   #GD__Workspace,gadgetnr
	        bne.s	.nextbutton2
	        clr.l	_memamount
		move.w	code,_memamount+2
.nextbutton2:
	        cmp.w   #GD__okay,gadgetnr
	 	bne.s	nobutton
		bra.b	wel_exit
nobutton:	move.l	class,d1
		and.l	#IDCMP_VANILLAKEY,d1
		beq.w	geenkey
		cmp.b	#'o',code+1
		bne.s	.geen_o
		bra.b	wel_exit
.geen_o:	cmp.b	#13,code+1
		bne.s	.geen_CR
		bra.b	wel_exit
.geen_CR:

geenkey:	moveq.l	#0,d0
noexit:		rts

wel_exit:	moveq.l	#1,d0			;exit please
		rts

SelectMemTable:	dc.l	SelectMemChip		
		dc.l	SelectMemFast
		dc.l	SelectMemPub
		dc.l	SelectMemAbs

SelectMemTableNoFast:
		dc.l	SelectMemChip
		dc.l	SelectMemPub
		dc.l	SelectMemAbs

SelectMemAbs:	clr.l	_memtype
		clr.l	_absolute_adrTags_change+4
		move.l  _absmax,_maxamountTags+4
		rts

SelectMemChip:	move.l	#2,_memtype
		move.l	_chipmax,_maxamountTags+4
		move.l	d0,_curamountTags+4
		rts

SelectMemFast:	move.l	#3,_memtype
		move.l  _fastmax,_maxamountTags+4
		move.l	d0,_curamountTags+4
		rts

SelectMemPub:	move.l	#1,_memtype
		move.l  _pubmax,_maxamountTags+4
		move.l	d0,_curamountTags+4
		rts

;************ INTUI STUFF **************************

GD__memorytype                         EQU    0
GD__Workspace                          EQU    1
GD__stack_size                         EQU    2
GD__fastmem                            EQU    3
GD__chipmem                            EQU    4
GD__absolute_adr                       EQU    5
GD__standard_dir                       EQU    6
GD__okay                               EQU    7
GD__border				EQU	8

SetupScreen
;	movem.l d1-d3/a0-a2/a6,-(sp)
	move.l  ScreenBase,Scr
	moveq   #0,d0
;	movem.l (sp)+,d1-d3/a0-a2/a6
	rts



Login_CNT    EQU    8
Scr:    DC.L    0

;VisualInfo:    DC.L    0

PubScreenName:
    DC.L    0
LoginWnd:
    DC.L    0
LoginGList:
    DC.L    0
LoginGadgets:
    DCB.L    Login_CNT,0
BufNewGad:
    DC.W    0,0,0,0
    DC.L    0,0
    DC.W    0
    DC.L    0,0,0
TD:
    DC.L    $00000000
NR:
    DC.L    $80080034,$00000000,$00000000
IR:
    DC.L    $80080034,$00000000,$80080033,1,$00000000

LoginLeft:
    DC.W    163
LoginTop:
    DC.W    142
LoginWidth:
    DC.W    320-6
LoginHeight:
    DC.W    180-9-2

LoginGTypes:
	DC.W    5	1
	DC.W    11	2
	DC.W    6	3
	DC.W    6	4
	DC.W    6	5
	DC.W    12	6
	DC.W    13	7
	DC.W    1	8
;	dc.w	$D	9

LoginNGads:
    DC.W    010+1,046+1,017,009
    DC.L    _memorytypeText,0
    DC.W    GD__memorytype
    DC.L    $0002,0,0

    DC.W    004+1,025+1,109,013
    DC.L    _WorkspaceText,0
    DC.W    GD__Workspace
    DC.L    $0004,0,0

    DC.W    264+1,025+1,035,018
    DC.L    _stack_sizeText,0
    DC.W    GD__stack_size
    DC.L    $0001,0,0

    DC.W    198+1,065+1,101,014
    DC.L    _fastmemText,0
    DC.W    GD__fastmem
    DC.L    $0001,0,0

    DC.W    198+1,045+1,101,017
    DC.L    _chipmemText,0
    DC.W    GD__chipmem
    DC.L    $0001,0,0

    DC.W    198+1,081+1,101,017
    DC.L    _absolute_adrText,0
    DC.W    GD__absolute_adr
    DC.L    $0001,0,0

    DC.W    004+1,142+1,295,017
    DC.L    _standard_dirText,0
    DC.W    GD__standard_dir
    DC.L    $0004,0,0

    DC.W    004+1,104+1,049,021
    DC.L    _okayText,0
    DC.W    GD__okay
    DC.L    $0010,0,0

;	dc.w	6,13+2,$018D,$005A-2
;	dc.l	0,0
;	dc.w	GD__border
;	dc.l	4,0,0

LoginGTags:
    DC.L    $80080009,_memorytypeLabels
_acticmx:
    DC.L    $80080000+10,1
    DC.L    $80080040,'_'
    DC.L    $8008003D,3
    DC.L    $00000000
_maxamountTags:
    DC.L    $80080027,1500
_curamountTags:
    DC.L    $80080028,500
    DC.L    $80080029,15
    DC.L    $8008002A,_WorkspaceFormat
    DC.L    $8008002B,$00000002
    DC.L    $80031001,$00000001
    DC.L    $80030016,1
    DC.L    $00000000
_stack_sizeTags:
    DC.L    $8008000D,0
    DC.L    $8008003A,1
    DC.L    $00000000
_fastmemTags:
    DC.L    $8008000D,0
    DC.L    $8008003A,1
    DC.L    $00000000
_chipmemTags:
    DC.L    $8008000D,0
    DC.L    $8008003A,1
    DC.L    $00000000
_absolute_adrTags:
    DC.L    $8003000E,1
    DC.L    GTST_String,_absolute_adrString
    DC.L    GTST_MaxChars,12
    DC.L    $80080040,'_'
    DC.L    $00000000
_dirstringTags:
	DC.L    $8008000B,_standard_dirString
	DC.L    GTTX_Border,1
	DC.L    $00000000

	DC.L    $80080040,'_'
	DC.L    $00000000

_absolute_adrTags_change:
	DC.L	$8003000E,1
	DC.L	GTST_String,_absolute_adrString
	dc.l	$00000000

;	dc.l	GTTX_Border,1,0,-1	 2

_WorkspaceFormat:
    DC.B    '%lu',0
    CNOP     0,2

_absolute_adrString:
    DC.B    '$60000',0,0,0,0,0,0,0
    CNOP    0,2

_standard_dirString:
    DC.B    '> not changed <',0
    CNOP    0,2

_memorytypeText:
    DC.B    '',0

_WorkspaceText:
    DC.B    'Workspace (kb)',0

_stack_sizeText:
    DC.B    'Stack (kb)',0			; ***

_fastmemText:
    DC.B    'Fast',0

_chipmemText:
    DC.B    'Chip',0

_absolute_adrText:
    DC.B    'Abs.adr',0

_standard_dirText:
    DC.B    'Changed standard directory to',0

_okayText:
    DC.B    '_OK',0

    CNOP    0,2

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

_memorytypeLab0:	dc.b	'_Chipmem',0
_memorytypeLab1:	dc.b	'_Fastmem',0
_memorytypeLab2:	dc.b	'_Publicmem',0
_memorytypeLab3:	dc.b	'_Absolute',0

    CNOP    0,2

;xhelvetica11:
;    DC.L    xhelveticaFName11
;    DC.W    11
;    DC.B    $00,$62
;
;xhelveticaFName11:
;    DC.B    'xhelvetica.font',0
;    CNOP    0,2


LoginWindowTags:
LoginL:	DC.L	WA_Left,0
LoginT:	DC.L	WA_Top,0
LoginW:	DC.L	WA_Width,0
LoginH:	DC.L	WA_Height,0
	DC.L	WA_IDCMP,$00200074
	DC.L	WA_Flags,WFLG_ACTIVATE|WFLG_BORDERLESS|WFLG_NOCAREREFRESH
LoginWG:
	DC.L	WA_Gadgets,0
	DC.L	WA_Title,0		;LoginWTitle
LoginSC:
	DC.L	$80000079,0
	DC.L	$00000000

;LoginWTitle:
;    DC.B    'Window title dingetje..',0
;    CNOP    0,2

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
	moveq.l	#Login_CNT-1,d7
pos_gadgets:
	move.w	EFontSize_x,d1
	move.w	EFontSize_y,d2
	addq.w	#3,d2
pos_gadgets2:
	move.w	(a0)+,d0
	mulu.w	d1,d0		;*x
	move.w	d0,(a1)+
	move.w	(a0)+,d0
	mulu.w	d2,d0		;*y
	addq.w	#4,d0
	move.w	d0,(a1)+
	move.w	(a0)+,d0
	mulu.w	d1,d0
	move.w	d0,(a1)+
	move.w	(a0)+,d0
	mulu.w	d2,d0
	addq.w	#4,d0
	move.w	d0,(a1)+
	lea	22(a1),a1
	dbf	d7,pos_gadgets2
	rts


LoginRender:
	movem.l d0-d5/a0-a2/a6,-(sp)
	move.l  LoginWnd,a0
	move.l  MainVisualInfo,NR+4
	move.l  MainVisualInfo,IR+4

	move.l  GadToolsBase,a6
	move.l  LoginWnd,a0
	move.l  50(a0),a2

;rond gadgets
	move.l  a2,a0
	lea.l   IR,a1
	move.w	EFontSize_x,d0
	lsl.w	#1,d0
;	addq.w	#3,d0
	move.w	EFontSize_y,d1
	addq.w	#3,d1
	mulu.w	#4,d1
;	addq.w	#5,d1
	move.w	EFontSize_x,d2
;	addq.w	#3,d2
	mulu.w	#14,d2
	addq.w	#6,d2
	move.w	EFontSize_y,d3
	addq.w	#3,d3
	mulu.w	#4,d3
	addq.w	#6,d3
	jsr     _LVODrawBevelBoxA(a6)

	move.l  a2,a0
	lea.l   NR,a1
	move.w  #2,d0
	move.w 	#2,d1
	move.w	LoginWidth(pc),d2
	subq.w	#4,d2
	move.w	LoginHeight(pc),d3
	sub.w	#4,d3
	jsr     _LVODrawBevelBoxA(a6)

	move.l  a2,a0
	lea.l   NR,a1
	move.w  #1,d0	;x
	move.w  #1,d1	;y
	move.w	LoginWidth(pc),d2
	subq.w	#2,d2
	move.w	LoginHeight(pc),d3
	subq.w	#2,d3
	jsr     _LVODrawBevelBoxA(a6)

	movem.l (sp)+,d0-d5/a0-a2/a6
	rts

OpenTheLoginWindow:
	movem.l d1-d4/a0-a4/a6,-(sp)

	move.l  Scr,a0

;	move.w	12(a0),d3	;center the login win
;	sub.w	#320,d3
;	lsr.w	#1,d3
;	move.w	d3,LoginLeft
;
;	move.w	14(a0),d3	;center the login win
;	sub.w	#170,d3
;	lsr.w	#1,d3
;	move.w	d3,LoginTop

	moveq   #0,d3
	moveq   #0,d2
	move.b  36(a0),d2	;wborderleft
	move.l  40(a0),a1	;font
	move.w  4(a1),d3
	addq.w  #1,d3
	add.b   35(a0),d0	;wbordertop
	ext.w   d0
	add.w   d0,d3
	move.l  GadToolsBase,a6
	lea.l   LoginGList,a0
	jsr     _LVOCreateContext(a6)
	move.l  d0,a3
	tst.l   d0
	beq     LoginCError
	movem.w d2-d3,-(sp)
	moveq   #0,d3
	lea.l   LoginGTags,a4	;mag eigenlijk niet he..
LoginGL:
	move.l  4.w,a6
	lea.l   LoginNGads,a0
	move.l  d3,d0
	mulu    #30,d0		;nr_gadgets *30
	add.l   d0,a0
	lea.l   BufNewGad,a1
	moveq   #30,d0
	jsr     _LVOCopyMem(a6)
	lea.l   BufNewGad,a0
	move.l  MainVisualInfo,22(a0)
	move.l  #Editor_Font,12(a0)
	move.w  (a0),d0
	add.w   (sp),d0
	move.w  d0,(a0)
	move.w  2(a0),d0
	add.w   2(sp),d0
	move.w  d0,2(a0)
	move.l  GadToolsBase,a6
	lea.l   LoginGTypes,a0
	moveq   #0,d0
	move.l  d3,d1
	asl.l   #1,d1
	add.l   d1,a0
	move.w  (a0),d0
	move.l  a3,a0
	lea.l   BufNewGad,a1
	move.l  a4,a2
	jsr     _LVOCreateGadgetA(a6)
	tst.l   d0
	bne.s    LoginCOK
	movem.w (sp)+,d2-d3
	bra     LoginGError
LoginCOK:
	move.l  d0,a3
	move.l  d3,d0
	asl.l   #2,d0
	lea.l   LoginGadgets,a0
	add.l   d0,a0
	move.l  a3,(a0)
LoginTL:
	tst.l   (a4)
	beq.s   LoginDN
	addq.w  #8,a4
	bra.b   LoginTL
LoginDN:
	addq.w  #4,a4
	addq.w  #1,d3
	cmp.w   #Login_CNT,d3
	bmi     LoginGL

	movem.w (sp)+,d2-d3
	move.l  LoginGList,LoginWG+4

	move.l  Scr,LoginSC+4
	moveq   #0,d0
	move.w  LoginLeft,d0
	move.l  d0,LoginL+4
	move.w  LoginTop,d0
	move.l  d0,LoginT+4
	move.w  LoginWidth,d0
	move.l  d0,LoginW+4
	move.w  LoginHeight,d0
	add.w   d3,d0
	move.l  d0,LoginH+4
	move.l  IntBase,a6
	suba.l  a0,a0
	lea.l   LoginWindowTags,a1
	jsr     _LVOOpenWindowTagList(a6)
	move.l  d0,LoginWnd
	tst.l   d0
	beq     LoginWError
	move.l  GadToolsBase,a6
	move.l  LoginWnd,a0
	suba.l  a1,a1
	jsr	_LVOGT_RefreshWindow(a6)
	jsr     LoginRender
	moveq   #0,d0
LoginDone:
	movem.l (sp)+,d1-d4/a0-a4/a6
	rts
LoginCError:
	moveq   #1,d0
	bra.b   LoginDone
LoginGError:
	moveq   #2,d0
	bra.b   LoginDone
LoginWError:
	moveq   #4,d0
	bra.b   LoginDone

CloseLoginWindow:
	movem.l d0-d1/a0-a2/a6,-(sp)

	tst.l	LoginWnd
	beq.s	LoginNGad

	move.l  IntBase,a6
	move.l  LoginWnd,a0
	cmpa.l  #0,a0
	beq     LoginNWnd
	jsr     _LVOCloseWindow(a6)
	move.l  #0,LoginWnd
LoginNWnd:
	move.l  GadToolsBase,a6
	move.l  LoginGList,a0
	cmpa.l  #0,a0
	beq     LoginNGad
	jsr     _LVOFreeGadgets(a6)
	move.l  #0,LoginGList
LoginNGad:
	movem.l (sp)+,d0-d1/a0-a2/a6
	rts

;************** Einde LOGIN WINDOWTJE **************

realend2:
	dc.w	$7220


;***********************************************
;**            ERROR MSGS SECTION             **
;***********************************************

	SECTION	AsmPrors01C188,DATA
Error_Msg_Table:
	dr.w	AddressRegByt.MSG
	dr.w	AddressRegExp.MSG
	dr.w	Dataregexpect.MSG
	dr.w	DoubleSymbol.MSG
	dr.w	EndofFile.MSG
	dr.w	UsermadeFAIL.MSG
	dr.w	FileError.MSG
	dr.w	InvalidAddres.MSG
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
	dr.w	OutofRange0bi.MSG
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
	dr.w	Illegaloption.MSG
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
	dr.w	BccWoutofrang.MSG
	dr.w	Floatingpoint.MSG
	dr.w	OutofRange6bi.MSG
	dr.w	OutofRange7bi.MSG
	dr.w	FPUneededforo.MSG
	dr.w	Tomanywatchpo.MSG
	dr.w	Illegalsource.MSG
	dr.w	Novalidmemory.MSG
	dr.w	Autocommandov.MSG
	dr.w	Endshouldbehi.MSG
	dr.w	Warningvalues.MSG
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
	dr.w	Bitfieldcantb.MSG
	dr.w	GeneralPurposeReg.MSG
	dr.w	AdrOrPCExpected.MSG
	dr.w	UnknowCPU.MSG
	
WorkspaceMemo.MSG:	dc.b	'Workspace Memory full',0
AddressRegByt.MSG:	dc.b	'Address Reg. Byte/Logic',0
AddressRegExp.MSG:	dc.b	'Address Reg. Expected',0
AdrOrPCExpected.MSG:	dc.b	'Address Reg. or PC Expected',0
Commaexpected.MSG:	dc.b	'Comma expected ',0
Dataregexpect.MSG:	dc.b	'Data reg. expected',0
DoubleSymbol.MSG:	dc.b	'Double Symbol',0
Unexpected.MSG:		dc.b	'Unexpected '
EndofFile.MSG:		dc.b	'End of File',0
UsermadeFAIL.MSG:	dc.b	'User made FAIL',0
IllegalComman.MSG:	dc.b	'Illegal Command',0
IllegalAddres.MSG:	dc.b	'Illegal Address size',0
IllegalOperan.MSG:	dc.b	'Illegal Operand',0
IllegalOperat.MSG:	dc.b	'Illegal Operator',0
IllegalOperat.MSG0:	dc.b	'Illegal Operator in BSS area',0
IllegalOrder.MSG:	dc.b	'Illegal Order',0
Illegalregsiz.MSG:	dc.b	'Illegal reg. size',0
IllegalSectio.MSG:	dc.b	'Illegal Section type',0
IllegalSize.MSG:	dc.b	'Illegal Size',0
Illegalmacrod.MSG:	dc.b	'Illegal macro def.',0
Immediateoper.MSG:	dc.b	'Immediate operand ex.',0
IncludeJam.MSG:		dc.b	'Include Jam',0
Macrooverflow.MSG:	dc.b	'Macro overflow',0
InvalidAddres.MSG:	dc.b	'Invalid Addressing Mode',0
LOADwithoutOR.MSG:	dc.b	'LOAD without ORG',0
MissingQuote.MSG:	dc.b	'Missing Quote',0
Conditionalov.MSG:	dc.b	'Conditional overflow',0
NOoperandspac.MSG:	dc.b	'NO operand space aLowed',0
NOTaconstantl.MSG:	dc.b	'NOT a constant/label',0
Notinmacro.MSG:		dc.b	'Not in macro ',0
OutofRange0bi.MSG:	dc.b	'Out of Range 0 bit',0
OutofRange3bi.MSG:	dc.b	'Out of Range 3 bit',0
OutofRange4bi.MSG:	dc.b	'Out of Range 4 bit',0
OutofRange5bi.MSG:	dc.b	'Out of Range 5 bit',0
OutofRange6bi.MSG:	dc.b	'Out of Range 6 bit',0
OutofRange7bi.MSG:	dc.b	'Out of Range 7 bit',0
OutofRange8bi.MSG:	dc.b	'Out of Range 8 bit',0
OutofRange16b.MSG:	dc.b	'Out of Range 16 bit',0
RelativeModeE.MSG:	dc.b	'Relative Mode Error',0
ReservedWord.MSG:	dc.b	'Reserved Word',0
Rightparenthe.MSG:	dc.b	'Right parenthes Expected',0
Sectionoverfl.MSG:	dc.b	'Section overflow',0
Stringexpecte.MSG:	dc.b	'String expected',0
UndefinedSymb.MSG:	dc.b	'Undefined Symbol',0
Registerexpec.MSG:	dc.b	'Register expected',0
WordatOddAddr.MSG:	dc.b	'Word at Odd Address',0
Notlocalarea.MSG:	dc.b	'Not local area',0
Codemovedduri.MSG:	dc.b	'Code moved during pass 2',0
BccBoutofrang.MSG:	dc.b	'Bcc.B out of range in Macro',0
Outofrange20t.MSG:	dc.b	'Out of range (20 to 100)',0
Outofrange60t.MSG:	dc.b	'Out of range (60 to 132)',0
Includeoverfl.MSG:	dc.b	'Include overflow',0
Linkerlimitat.MSG:	dc.b	'Linker limitation',0
Repeatoverflo.MSG:	dc.b	'Repeat overflow',0
NotinRepeatar.MSG:	dc.b	'Not in Repeat area',0
Doubledefinit.MSG:	dc.b	'Double definition',0
Relocationmad.MSG:	dc.b	'Relocation made to EMPTY section',0
FileError.MSG:		dc.b	'File Error ',0
NoFiles.MSG:		dc.b	'No Files   ',0
NoObject.MSG:		dc.b	'No Object  ',0
NoFileSpace.MSG:	dc.b	'No File Space',0
PrinterDevice.MSG:	dc.b	'Printer Device Missing',$A,0
Notdone.MSG:		dc.b	'Not done   ',0
IllegalPath.MSG:	dc.b	'Illegal Path ',0
IllegalDevice.MSG:	dc.b	'Illegal Device',0
WriteProtecte.MSG:	dc.b	'Write Protected',0
Nodiskindrive.MSG:	dc.b	'No disk in drive',0
Illegaloption.MSG:	dc.b	'Illegal option !!',0
REMwithoutERE.MSG:	dc.b	'REM without EREM',0
TEXTwithoutET.MSG:	dc.b	'TEXT without ETEXT',0
Illegalscales.MSG:	dc.b	'Illegal scale size',0
Offsetwidthex.MSG:	dc.b	'{Offset/width} expected',0
Missingbrace.MSG:	dc.b	'Missing brace',0
Colonexpected.MSG:	dc.b	'Colon expected',0
Missingbracke.MSG:	dc.b	'Missing bracket',0
FPUneededforo.MSG:	dc.b	'FPU needed for operation !!',0
Tomanywatchpo.MSG:	dc.b	'To many watchpoints (max 8.)',0
Illegalsource.MSG:	dc.b	'Illegal source, not activated !!',0
Novalidmemory.MSG:	dc.b	'No valid memory directory present',0
Autocommandov.MSG:	dc.b	'Auto command overflow (256 chars)',0
Endshouldbehi.MSG:	dc.b	'End should be higher than start !',0
Warningvalues.MSG:	dc.b	'Warning, value signed extended to longword',0
Illegalsource.MSG0:	dc.b	'Illegal source nr',0
Includingempt.MSG:	dc.b	'Including empty source ?',0
IncludeSource.MSG:	dc.b	'Include Source jam',0
Unknownconver.MSG:	dc.b	'Unknown conversion mode, Should be RB or RN',0
Unknowncmappl.MSG:	dc.b	'Unknown cmap place, Should be (B)EFORE,(A)FTER or (N)ONE',0
Unknowncmapmo.MSG:	dc.b	'Unknown cmap mode, Should be AGA or ECS',0
Tryingtoinclu.MSG:	dc.b	'Trying to include NON IFF file',0
IFFfileisnota.MSG:	dc.b	'IFF file is not a ILBM file',0
CanthandleaBO.MSG:	dc.b	'Can''t handle a BODY before BMHD chunk',0
WarningValues.MSG:	dc.b	'>> Warning << Value sign extended, Resulting in negative',$A,0
UnknowCPU.MSG:		dc.b	'Unknown CPU type should be 000..060',0

Warning68010c.MSG:
	dc.b	'>> Warning << 68010++ command used',$A,0
	dc.b	'>> Warning << 68020++ command used',$A,0
	dc.b	'>> Warning << 68030++ command used',$A,0
	dc.b	'>> Warning << 68040++ command used',$A,0
	dc.b	'>> Warning << 68060++ command used',$A,0
	dc.b	'>> Warning << Apollo++ command used',$A,0

Warning68010s.MSG:
	dc.b	'>> Warning << 68010 specific command used',$A,0
	dc.b	'>> Warning << 68020 specific command used',$A,0
	dc.b	'>> Warning << 68030 specific command used',$A,0
	dc.b	'>> Warning << 68040 specific command used',$A,0
	dc.b	'>> Warning << 68060 specific command used',$A,0
	dc.b	'>> Warning << Apollo specific command used',$A,0

WarningNoAvail.MSG:
	dc.b	'>> Warning << command NOT available on a 68010',$A,0
	dc.b	'>> Warning << command NOT available on a 68020',$A,0
	dc.b	'>> Warning << command NOT available on a 68030',$A,0
	dc.b	'>> Warning << command NOT available on a 68040',$A,0
	dc.b	'>> Warning << command NOT available on a 68060',$A,0
	dc.b	'>> Warning << command NOT available on a Apollo',$A,0

Warning688816.MSG:
	dc.b	'>> Warning << 68881/68882 command used',$A,0
Warning68851c.MSG:
	dc.b	'>> Warning << 68851 command used',$A,0

Warning68851_030.MSG:
	dc.b	'>> Warning << 68851/68030 specific command used',$A,0
	dc.b	'>> Warning << 68851/68030++ command used       ',$A,0
	dc.b	'>> Warning << 68851/68040++ command used       ',$A,0
	dc.b	'>> Warning << 68851/68060++ command used       ',$A,0
	dc.b	'>> Warning << 68851/Apollo++ command used      ',$A,0


Illegalfloati.MSG:	dc.b	'Illegal floating point size, should be B,W,L,S,D,Q or P',0
Illegalsizefo.MSG:	dc.b	'Illegal size for data register, should be B,W,L or S',0
BccWoutofrang.MSG:	dc.b	'Bcc.W out of range in Macro',0
Floatingpoint.MSG:	dc.b	'Floating point register expected',0
ThisisnotaAsm.MSG:	dc.b	'This is not a Asm-Pro project file',0
Bitfieldcantb.MSG:	dc.b	'Bitfield can''t be out of 32 bit range',0

GeneralPurposeReg.MSG:	dc.b	'PPC General Purpose Register expected (R0..R31)',0

Insuficientme.MSG:	dc.b	'Insuficient memory to change source',0
A4Debug.MSG:		dc.b	'A4 Debug : $',0
ascii.MSG8:		dc.b	'        '
ascii.MSG9:		dc.b	'- $',0
ascii.MSG0:		dc.b	10,0

Project.MSG:		dc.b	'Project',0
Open.MSG:		dc.b	'Open...',0
O.MSG:			dc.b	'O',0
SaveAs.MSG:		dc.b	'Save As...',0
A.MSG:			dc.b	'A',0
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
Realtimedeb.MSG:	dc.b	'Realtime deb',0
LineNumbers.MSG:	dc.b	'Line Numbers',0
AutoBackup.MSG:		dc.b	'Auto Backup',0
AutoUpdate.MSG:		dc.b	'Auto Update',0			
AutoIndent.MSG:		dc.b	'Auto Indent',0
ExtendedReqTo.MSG:	dc.b	'Ext. ReqTools',0
StartupWindow.MSG:	dc.b	'Show Startup win.',0
SyntaxColor.MSG:	dc.b	'Syntax Colors',0
CustomScroll.MSG:	dc.b	'Custom Scrollr.',0
WaitTof.MSG:		dc.b	'Scroll Sync',0
Slider.MSG:		dc.b	'Slider',0
CTRLupdown.MSG:		dc.b	'CTRL up/down',0
Keepx.MSG:		dc.b	'Keep x',0
			dc.b	'Prefs:',0
GeneralParame.MSG:	dc.b	'General Parameters',0
MonitorDebugg.MSG:	dc.b	'Monitor / Debugger',0

nulstring:		dcb.b	2,0

Editor.MSG:		dc.b	'Editor',0,0,0
Save.MSG:		dc.b	'Save',0
Use.MSG:		dc.b	'Use',0
Cancel.MSG:		dc.b	'Cancel',0,0,0
DefaultDir.MSG:		dc.b	'Default Dir:',0
BootUp.MSG:		dc.b	'BootUp',0
SourceExtensi.MSG:	dc.b	'Source Extension',0
Selectnewscre.MSG:	dc.b	'Select screen mode',0
Selecteditorfont.MSG:	dc.b	'Select editor font',0
Assembler.MSG:		dc.b	'Assembler',0
Save.MSG0:		dc.b	'Save',0
Use.MSG0:		dc.b	'Use',0
Cancel.MSG0:		dc.b	'Cancel',0
Rescue.MSG:		dc.b	'Rescue',0
Level7.MSG:		dc.b	'Level 7',0
NumLock.MSG:		dc.b	'NumLock',0
PR_AutoAlloc.MSG:	dc.b	'Auto Alloc',0
Debug.MSG:		dc.b	'Debug',0

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
Comment.MSG:		dc.b	'; Comment',0
ProcessorWarn.MSG:	dc.b	'Processor Warn',0
CPU.MSG:		dc.b	'CPU',0
FPUPresent.MSG:		dc.b	'FPU Present',0
Odddata.MSG:		dc.b	'68020++ Odd data',0
DSClear.MSG:		dc.b	'DS Clear',0
Present.MSG:		dc.b	'68851 Present',0
Notenoughmemo.MSG0:	dc.b	'Not enough memory to open preferences window',$A,$D,0
ENVARCAsmProp.MSG0:	dc.b	' ENVARC:Asm-Pro.pref saved',0
ENVARCAsmProp.MSG:	dc.b	' ENVARC:Asm-Pro.pref {re}loaded',0,0

SyntColors.MSG:		dc.b	'Syntax Colors',0
SYNTLEV.MSG		dc.b	'Level',0

	cnop	0,4

;WBScreen:	dc.l	0
ScreenTagList:
	dc.l	0
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

;************* type gadgets env ************
Pref_EnvGadgetTypes:
	dc.w	BUTTON_KIND	 0
	dc.w	BUTTON_KIND	 1
	dc.w	BUTTON_KIND	 2
	dc.w	$0002	03
	dc.w	$0002	 4
	dc.w	$0002	 5
	dc.w	$0002	 6
	dc.w	$0002	 7
	dc.w	$0002	 8
	dc.w	$0002	 9
	dc.w	$0002	10
	dc.w	$0002	 1
	dc.w	$0002	 2
	dc.w	$0002	 3
	dc.w	$0002	 4
	dc.w	$0002	 5
	dc.w	$0002	 6
	dc.w	$0002	 7
	dc.w	$0002	 8
	dc.w	$0002	 9
	dc.w	$0002	20
	dc.w	$0002	 1
	dc.w	$0002	 2
	dc.w	$0002	 3
	dc.w	$0002	 4
	dc.w	$0002	 5	;CustomScroll
	dc.w	$0002	 6	;WaitTOF
	IF SLIDER
	dc.w	$0002	 7	;Slider
	ENDIF
	dc.w	$0002	 8	;LineNrs
	dc.w	$0002	 9	;AutoBackup
	dc.w	$0002	 	;auto update

	dc.w	$000C	30
	dc.w	$000C	31
	dc.w	$000C	 2
	dc.w	BUTTON_KIND	33	;screen mode
	dc.w	BUTTON_KIND	34	;wind font
	dc.w	$000D	 5		;bevel box
	dc.w	$000D	 6
	dc.w	$000D	 7
	dc.w	$000D	 8
	

env_gadspos:
	dc.w	03,19,8,1	;save
	dc.w	34,19,8,1	;use
	dc.w	64,19,8,1	;cancel

	dc.w	03,01,1,0	;reqtools
	dc.w	03,02,1,0	;savemarks
	dc.w	03,03,1,0	;.asm
	dc.w	03,04,1,0	;update
	dc.w	03,05,1,0	;printdump

	dc.w	26,01,1,0	;wb2front
	dc.w	26,02,1,0	;res registers
	dc.w	26,03,1,0	;safety
	dc.w	26,04,1,0	;close wb
	dc.w	26,05,1,0	;parameters

	dc.w	52,01,1,0	;ascii only
	dc.w	52,02,1,0	;disassembly
	dc.w	52,03,1,0	;show source
	dc.w	52,04,1,0	;enable/permit
	dc.w	52,05,1,0	;libcalls dec
	dc.w	52,06,1,0	;realtime deb

	dc.w	52,11,1,0	;ctrl up/down
	dc.w	52,12,1,0	;keep x
	dc.w	52,13,1,0	;auto indent.
	dc.w	52,14,1,0	;ext. reqtools

	dc.w	26,06,1,0	;show startupwin

	dc.w	52,15,1,0	;syntax color
	dc.w	52,16,1,0	;custom scroll
	dc.w	52,17,1,0	;scroll sync
	IF SLIDER
	dc.w	52,09,1,0	;Slider
	ENDIF
	dc.w	52,10,1,0	;LineNrs

	dc.w	03,06,1,0	;AutoBackup
	dc.w	03,07,1,0	;auto update		

	dc.w	25,10,22,1	;default dir
	dc.w	25,12,22,1	;bootup
	dc.w	25,14,22,1	;source ext

	dc.w	25,16,22,1	;screenmode
	dc.w	03,16,21,1	;font select

; borders
	dc.w	01,01,48,7	;border params
	dc.w	50,01,23,6	;border mon/debug
	dc.w	50,09,23,9	;border editor
	dc.w	01,09,48,9	;border nix


EPG_save	=	$00
EPG_use		=	$01
EPG_cancel	=	$02

EPG_rt		=	$03
EPG_sm		=	$04
EPG_sa		=	$05
EPG_uc		=	$06
EPG_pd		=	$07
EPG_wf		=	$08
EPG_rr		=	$09
EPG_st		=	$0a
EPG_cw		=	$0b
EPG_pm		=	$0c
EPG_ao		=	$0d
EPG_da		=	$0e
EPG_ss		=	$0f
EPG_ep		=	$10
EPG_lc		=	$11
EPG_rd		=	$12
EPG_cud		=	$13
EPG_kx		=	$14
EPG_ai		=	$15
EPG_xr		=	$16
EPG_sw		=	$17
EPG_sc		=	$18
EPG_cs		=	$19
EPG_wt		=	$1a
	IF SLIDER
EPG_sl		=	EPG_wt+1	$1b
EPG_ln		=	EPG_sl+1	$1c
	ELSE
EPG_ln		=	EPG_wt+1	$1c
	ENDIF

EPG_ab		=	EPG_ln+1	$1c
EPG_au		=	EPG_ab+1	$1d

EPG_dir		=	EPG_au+1	$1e
EPG_boot	=	EPG_dir+1	$1f
EPG_ext		=	EPG_boot+1	$20

EPG_screen	=	EPG_ext+1	$21
EPG_font	=	EPG_screen+1	$22

EPG_bor1	=	EPG_font+1	$23
EPG_bor2	=	EPG_bor1+1	$24
EPG_bor3	=	EPG_bor2+1	$25
EPG_bor4	=	EPG_bor3+1	$26

envg_beg:
Env_prefs_gadstr:
	dc.w	0,0,0,0
	dc.l	Save.MSG,0
	dc.w	EPG_save
	dc.l	$0010,0,0

	dc.w	0,0,0,0
	dc.l	Use.MSG,0
	dc.w	EPG_use
	dc.l	$0010,0,0

	dc.w	0,0,0,0
	dc.l	Cancel.MSG,0
	dc.w	EPG_cancel
	dc.l	$0010,0,0
;--
	dc.w	0,0,0,0
	dc.l	ReqToolsLibra.MSG,0
	dc.w	EPG_rt
	dc.l	PLACETEXT_RIGHT,0,0

	dc.w	0,0,0,0
	dc.l	SaveMarks.MSG,0
	dc.w	EPG_sm
	dc.l	PLACETEXT_RIGHT,0,0

	dc.w	0,0,0,0
	dc.l	SourceASM.MSG,0
	dc.w	EPG_sa
	dc.l	PLACETEXT_RIGHT,0,0

	dc.w	0,0,0,0
	dc.l	UpdateCheck.MSG,0
	dc.w	EPG_uc
	dc.l	PLACETEXT_RIGHT,0,0

	dc.w	0,0,0,0
	dc.l	PrinterDump.MSG,0
	dc.w	EPG_pd
	dc.l	PLACETEXT_RIGHT,0,0

	dc.w	0,0,0,0
	dc.l	WBtofront.MSG,0
	dc.w	EPG_wf
	dc.l	PLACETEXT_RIGHT,0,0
;--
	dc.w	0,0,0,0
	dc.l	ResidentRegis.MSG,0
	dc.w	EPG_rr
	dc.l	PLACETEXT_RIGHT,0,0

	dc.w	0,0,0,0
	dc.l	Safety.MSG,0
	dc.w	EPG_st
	dc.l	PLACETEXT_RIGHT,0,0

	dc.w	0,0,0,0
	dc.l	CloseWorkbenc.MSG,0
	dc.w	EPG_cw
	dc.l	PLACETEXT_RIGHT,0,0

	dc.w	0,0,0,0
	dc.l	Parameters.MSG,0
	dc.w	EPG_pm
	dc.l	PLACETEXT_RIGHT,0,0
;--
	dc.w	0,0,0,0
	dc.l	ASCIIOnly.MSG,0
	dc.w	EPG_ao
	dc.l	PLACETEXT_RIGHT,0,1

	dc.w	0,0,0,0
	dc.l	Disassembly.MSG,0
	dc.w	EPG_da
	dc.l	PLACETEXT_RIGHT,0,1

	dc.w	0,0,0,0
	dc.l	ShowSource.MSG,0
	dc.w	EPG_ss
	dc.l	PLACETEXT_RIGHT,0,1

	dc.w	0,0,0,0
	dc.l	EnablePermit.MSG,0
	dc.w	EPG_ep
	dc.l	PLACETEXT_RIGHT,0,1

	dc.w	0,0,0,0
	dc.l	Libcallsdec.MSG,0
	dc.w	EPG_lc
	dc.l	PLACETEXT_RIGHT,0,1

	dc.w	0,0,0,0
	dc.l	Realtimedeb.MSG,0
	dc.w	EPG_rd
	dc.l	PLACETEXT_RIGHT,0,1

	dc.w	0,0,0,0
	dc.l	CTRLupdown.MSG,0
	dc.w	EPG_cud
	dc.l	PLACETEXT_RIGHT,0,1

	dc.w	0,0,0,0
	dc.l	Keepx.MSG,0
	dc.w	EPG_kx
	dc.l	PLACETEXT_RIGHT,0,1

	dc.w	0,0,0,0
	dc.l	AutoIndent.MSG,0
	dc.w	EPG_ai
	dc.l	PLACETEXT_RIGHT,0,0

	dc.w	0,0,0,0
	dc.l	ExtendedReqTo.MSG,0
	dc.w	EPG_xr
	dc.l	PLACETEXT_RIGHT,0,0

	dc.w	0,0,0,0
	dc.l	StartupWindow.MSG,0
	dc.w	EPG_sw
	dc.l	PLACETEXT_RIGHT,0,0

	dc.w	0,0,0,0
	dc.l	SyntaxColor.MSG,0
	dc.w	EPG_sc
	dc.l	PLACETEXT_RIGHT,0,0

	dc.w	0,0,0,0
	dc.l	CustomScroll.MSG,0
	dc.w	EPG_cs
	dc.l	PLACETEXT_RIGHT,0,0

	dc.w	0,0,0,0
	dc.l	WaitTof.MSG,0
	dc.w	EPG_wt
	dc.l	PLACETEXT_RIGHT,0,0

	IF SLIDER
	dc.w	0,0,0,0
	dc.l	Slider.MSG,0
	dc.w	EPG_sl
	dc.l	PLACETEXT_RIGHT,0,0
	ENDIF

	dc.w	0,0,0,0
	dc.l	LineNumbers.MSG,0
	dc.w	EPG_ln
	dc.l	PLACETEXT_RIGHT,0,0

	dc.w	0,0,0,0
	dc.l	AutoBackup.MSG,0
	dc.w	EPG_ab
	dc.l	PLACETEXT_RIGHT,0,0

	dc.w	0,0,0,0				
	dc.l	AutoUpdate.MSG,0
	dc.w	EPG_au
	dc.l	PLACETEXT_RIGHT,0,0

;--
	dc.w	0,0,0,0
	dc.l	DefaultDir.MSG,0
	dc.w	EPG_dir
	dc.l	$0001,0,0

	dc.w	0,0,0,0
	dc.l	BootUp.MSG,0
	dc.w	EPG_boot
	dc.l	1,0,0

	dc.w	0,0,0,0
	dc.l	SourceExtensi.MSG,0
	dc.w	EPG_ext
	dc.l	1,0,0

	dc.w	0,0,0,0
	dc.l	Selectnewscre.MSG,0
	dc.w	EPG_screen
	dc.l	$0010,0,0

	dc.w	0,0,0,0
	dc.l	Selecteditorfont.MSG,0
	dc.w	EPG_font
	dc.l	$0010,0,0


;-- borders
	dc.w	0,0,0,0
	dc.l	GeneralParame.MSG,0
	dc.w	EPG_bor1
	dc.l	4,0,0
	
	dc.w	0,0,0,0
	dc.l	MonitorDebugg.MSG,0
	dc.w	EPG_bor2
	dc.l	4,0,0

	dc.w	0,0,0,0
	dc.l	Editor.MSG,0
	dc.w	EPG_bor3
	dc.l	4,0,0

	dc.w	0,0,0,0
	dc.l	nulstring,0
	dc.w	EPG_bor4
	dc.l	$0000,0,0
envg_end:

env_gadcount = (envg_end-envg_beg)/30

;********* ENV PREFS GADS **************

Prefs_EnvGadTags:
	dc.l	0,-1			 0
	dc.l	0,-1			 1
	dc.l	0,-1			 2
Prefs_EnvGadgets2:
	dc.l	GTCB_Checked,0,0,-1	03
	dc.l	GTCB_Checked,0,0,-1	 4
	dc.l	GTCB_Checked,0,0,-1	 5
	dc.l	GTCB_Checked,0,0,-1	 6
	dc.l	GTCB_Checked,0,0,-1	 7
	dc.l	GTCB_Checked,0,0,-1	 8
	dc.l	GTCB_Checked,0,0,-1	 9
	dc.l	GTCB_Checked,0,0,-1	10
	dc.l	GTCB_Checked,0,0,-1	 1
	dc.l	GTCB_Checked,0,0,-1	 2
	dc.l	GTCB_Checked,0,0,-1	 3
	dc.l	GTCB_Checked,0,0,-1	 4
	dc.l	GTCB_Checked,0,0,-1	 5
	dc.l	GTCB_Checked,0,0,-1	 6
	dc.l	GTCB_Checked,0,0,-1	 7
	dc.l	GTCB_Checked,0,0,-1	 8
	dc.l	GTCB_Checked,0,0,-1	 9
	dc.l	GTCB_Checked,0,0,-1	20
	dc.l	GTCB_Checked,0,0,-1	 1
	dc.l	GTCB_Checked,0,0,-1	 2
	dc.l	GTCB_Checked,0,0,-1	 3	;Startup
	dc.l	GTCB_Checked,0,0,-1	 4	;Syntaxcolor
	dc.l	GTCB_Checked,0,0,-1	 5	;CustomScroll
	dc.l	GTCB_Checked,0,0,-1	 6	;WaitTOF
	IF SLIDER
	dc.l	GTCB_Checked,0
;	dc.l	GA_Disabled,1
	dc.l	0,-1	 7	Slider
	ENDIF
	dc.l	GTCB_Checked,0,0,-1	 8	;Linenrs
	dc.l	GTCB_Checked,0,0,-1	 9	;AutoBackup
	dc.l	GTCB_Checked,0,0,-1	 9	;AutoUpDate 

	dc.l	GTST_MaxChars,127,GTST_String,HomeDirectory,0,-1	30
	dc.l	GTST_MaxChars,253,GTST_String,BootUpString,0,-1		31
	dc.l	GTST_MaxChars,016,GTST_String,S.MSG,0,-1		 2
	dc.l	0,-1			 3	;screenmode
	dc.l	0,-1			34	;window font
	dc.l	GTTX_Border,1,0,-1	 5
	dc.l	GTTX_Border,1,0,-1	 6
	dc.l	GTTX_Border,1,0,-1	 7
	dc.l	GTTX_Border,1,0,-1	 8


;************************************
;********** ASM PREFS ****************

asm_gadcount	= 24

;************* type gadgets ASM *********
Pref_AsmGadgetTypes:
	dc.w	BUTTON_KIND	00;button
	dc.w	BUTTON_KIND	 1
	dc.w	BUTTON_KIND	 2

	dc.w	$0002	 3;checkbox
	dc.w	$0002 	 4
	dc.w	$0002	 5
	dc.w	$0002	 6
	dc.w	$0002	 7
	dc.w	$0002	 8
	dc.w	$0002	 9
	dc.w	$0002	10
	dc.w	$0002	 1
	dc.w	$0002	 2
	dc.w	$0002	 3
	dc.w	$0002	 4
	dc.w	$0002	 5
	dc.w	$0002	 6
	dc.w	$0002	 7
	dc.w	$0002	 8
	dc.w	$0002	 9
	dc.w	$0002	20
	dc.w	$0002	 1
	dc.w	CYCLE_KIND	 2;cycle
	dc.w	$000D	 3;box


asm_gadspos:
	dc.w	03,12,08,1	;save
	dc.w	34,12,08,1	;use
	dc.w	64,12,08,1	;cancel

	dc.w	4,02,1,1	;rescue
	dc.w	4,03,1,1	;level7
	dc.w	4,04,1,1	;numlock
	dc.w	4,05,1,1	;autoalloc
	dc.w	4,06,1,1	;debug

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


APG_save	=	$00
APG_use		=	$01
APG_cancel	=	$02

APG_Rescue	=	$03
APG_Level7	=	$04
APG_NumLock	=	$05
APG_AutoAlloc	=	$06
APG_Debug	=	$07
APG_ListFile	=	$08
APG_Paging	=	$09
APG_HaltPage	=	$0a
APG_AllErrors	=	$0b
APG_Progress	=	$0c
APG_ProgByLine	=	$0d
APG_DsClear	=	$0e
APG_Label	=	$0f
APG_Up_LowCase	=	$10
APG_Comment	=	$11
APG_Warning	=	$12
APG_FPU_Present	=	$13
APG_OddData	=	$14
APG_MMU		=	$15
APG_CPU		=	$16
APG_WIN		=	$17


Asm_prefs_gadstr:
	dc.w	0,0,0,0
	dc.l	Save.MSG0
	dc.l	0
	dc.w	APG_save
	dc.l	$0010,0,0

	dc.w	0,0,0,0
	dc.l	Use.MSG0
	dc.l	0
	dc.w	APG_use
	dc.l	$0010,0,0

	dc.w	0,0,0,0
	dc.l	Cancel.MSG0
	dc.l	0
	dc.w	APG_cancel
	dc.l	$0010,0,0

	dc.w	0,0,0,0
	dc.l	Rescue.MSG
	dc.l	0
	dc.w	APG_Rescue
	dc.l	PLACETEXT_RIGHT,0,0

	dc.w	0,0,0,0
	dc.l	Level7.MSG
	dc.l	0
	dc.w	APG_Level7
	dc.l	PLACETEXT_RIGHT,0,0

	dc.w	0,0,0,0
	dc.l	NumLock.MSG
	dc.l	0
	dc.w	APG_NumLock
	dc.l	PLACETEXT_RIGHT,0,0

	dc.w	0,0,0,0
	dc.l	PR_AutoAlloc.MSG
	dc.l	0
	dc.w	APG_AutoAlloc
	dc.l	PLACETEXT_RIGHT,0,0

	dc.w	0,0,0,0
	dc.l	Debug.MSG
	dc.l	0
	dc.w	APG_Debug
	dc.l	PLACETEXT_RIGHT,0,1
;--
	dc.w	0,0,0,0
	dc.l	ListFile.MSG
	dc.l	0
	dc.w	APG_ListFile
	dc.l	PLACETEXT_RIGHT,0,1

	dc.w	0,0,0,0
	dc.l	Paging.MSG
	dc.l	0
	dc.w	APG_Paging
	dc.l	PLACETEXT_RIGHT,0,0

	dc.w	0,0,0,0
	dc.l	HaltFile.MSG
	dc.l	0
	dc.w	APG_HaltPage
	dc.l	PLACETEXT_RIGHT,0,0

	dc.w	0,0,0,0
	dc.l	AllErrors.MSG
	dc.l	0
	dc.w	APG_AllErrors
	dc.l	PLACETEXT_RIGHT,0,0

	dc.w	0,0,0,0
	dc.l	ProgressIndic.MSG
	dc.l	0
	dc.w	APG_Progress
	dc.l	PLACETEXT_RIGHT,0,0

	dc.w	0,0,0,0
	dc.l	ProgressbyLin.MSG
	dc.l	0
	dc.w	APG_ProgByLine
	dc.l	PLACETEXT_RIGHT,0,0

	dc.w	0,0,0,0
	dc.l	DSClear.MSG
	dc.l	0
	dc.w	APG_DsClear
	dc.l	PLACETEXT_RIGHT,0,0
;--
	dc.w	0,0,0,0
	dc.l	Label.MSG
	dc.l	0
	dc.w	APG_Label
	dc.l	PLACETEXT_RIGHT,0,0

	dc.w	0,0,0,0
	dc.l	UCaseLCase.MSG
	dc.l	0
	dc.w	APG_Up_LowCase
	dc.l	PLACETEXT_RIGHT,0,0

	dc.w	0,0,0,0
	dc.l	Comment.MSG
	dc.l	0
	dc.w	APG_Comment
	dc.l	PLACETEXT_RIGHT,0,0

	dc.w	0,0,0,0
	dc.l	ProcessorWarn.MSG
	dc.l	0
	dc.w	APG_Warning
	dc.l	PLACETEXT_RIGHT,0,0

	dc.w	0,0,0,0
	dc.l	FPUPresent.MSG
	dc.l	0
	dc.w	APG_FPU_Present
	dc.l	PLACETEXT_RIGHT,0,0

	dc.w	0,0,0,0
	dc.l	Odddata.MSG
	dc.l	0
	dc.w	APG_OddData
	dc.l	PLACETEXT_RIGHT,0,0

	dc.w	0,0,0,0
	dc.l	Present.MSG
	dc.l	0
	dc.w	APG_MMU
	dc.l	PLACETEXT_RIGHT,0,0


	dc.w	0,0,0,0
	dc.l	CPU.MSG
	dc.l	0
	dc.w	APG_CPU
	dc.l	1,0,0

	dc.w	0,0,0,0
	dc.l	Assembler.MSG
	dc.l	0
	dc.w	APG_WIN
	dc.l	4,0,0


;************* ASM Gad tags **************

Prefs_AsmGadTags:
	dc.l	0,-1			00 save
	dc.l	0,-1			 1 use
	dc.l	0,-1			 2 cancel
Prefs_AsmGadgets2:
	dc.l	GTCB_Checked,0,0,-1	 3
	dc.l	GTCB_Checked,0,0,-1	 4
	dc.l	GTCB_Checked,0,0,-1	 5
	dc.l	GTCB_Checked,0,0,-1	 6
	dc.l	GTCB_Checked,0,0,-1	 7
	dc.l	GTCB_Checked,0,0,-1	 8
	dc.l	GTCB_Checked,0,0,-1	 9
	dc.l	GTCB_Checked,0,0,-1	10
	dc.l	GTCB_Checked,0,0,-1	 1
	dc.l	GTCB_Checked,0,0,-1	 2
	dc.l	GTCB_Checked,0,0,-1	 3
	dc.l	GTCB_Checked,0,0,-1	 4
	dc.l	GTCB_Checked,0,0,-1	 5
	dc.l	GTCB_Checked,0,0,-1	 6
	dc.l	GTCB_Checked,0,0,-1	 7
	dc.l	GTCB_Checked,0,0,-1	 8
	dc.l	GTCB_Checked,0,0,-1	 9
	dc.l	GTCB_Checked,0,0,-1	20
	dc.l	GTCB_Checked,0,0,-1	 1

	dc.l	GTCY_Labels,Prefs_CpuTable
	dc.l	GTCY_Active
	dc.w	0
Prefs_AsmCpuType:
	dc.w	0
	dc.l	0,-1

	dc.l	GTTX_Border,1,0,-1	 3


;************************************
;********** SYNTCOL PREFS ***********


Pref_SyntGadgetTypes:
	DC.W    BUTTON_KIND
	DC.W    BUTTON_KIND
	DC.W    BUTTON_KIND
	dc.w	$000D	 	;box
	DC.W    CYCLE_KIND
	DC.W    PALETTE_KIND
	DC.W    PALETTE_KIND
	DC.W    LISTVIEW_KIND

synt_gadspos:
	dc.w	03,12,08,1	;0 save
	dc.w	34,12,08,1	;1 use
	dc.w	64,12,08,1	;2 cancel

	dc.w	19,01,55,10	;3 border

	dc.w	01,01,17,01	;4 synt color level?

	dc.w	01,09,08,02	;5 front palet
	dc.w	10,09,08,02	;6 back palet

	dc.w	01,03,17,04	;7 list view


SPG_save	=	$00
SPG_use		=	$01
SPG_cancel	=	$02
SPG_WIN		=	$03

SPG_SYNT	=	$04
SPG_FRONT	=	$05
SPG_BACK	=	$06
SPG_ATTR	=	$07
synt_gadcount	=	$08


Synt_prefs_gadstr:
	dc.w	0,0,0,0
	dc.l	Save.MSG0
	dc.l	0
	dc.w	SPG_save
	dc.l	$0010,0,0

	dc.w	0,0,0,0
	dc.l	Use.MSG0
	dc.l	0
	dc.w	SPG_use
	dc.l	$0010,0,0

	dc.w	0,0,0,0
	dc.l	Cancel.MSG0
	dc.l	0
	dc.w	SPG_cancel
	dc.l	$0010,0,0

	dc.w	0,0,0,0
	dc.l	SyntColors.MSG
	dc.l	0
	dc.w	SPG_WIN
	dc.l	4,0,0

	dc.w	0,0,0,0
	dc.l	SYNTLEV.MSG
	dc.l	0
	dc.w	SPG_SYNT
	dc.l	PLACETEXT_ABOVE,0,0

	DC.W    0,0,0,0
	DC.L    syntFrontText,0
	DC.W    SPG_FRONT
	DC.L    PLACETEXT_ABOVE,0,0

	DC.W    0,0,0,0
	DC.L    syntBackText,0
	DC.W    SPG_BACK
	DC.L    PLACETEXT_ABOVE,0,0

	DC.W    0,0,0,0
	DC.L    syntAttrText,0
	DC.W    SPG_ATTR
	DC.L    0,0,0


;************* SYNT prefs *************

Prefs_SyntGadTags:
	dc.l	0,-1			00 save
	dc.l	0,-1			 1 use
	dc.l	0,-1			 2 cancel

	dc.l	GTTX_Border,1,0,-1 	03 border

;Prefs_SyntGadgets2:
	dc.l	GTCY_Labels,Prefs_SyntTable
	dc.l	GA_Disabled,1
	dc.l	GTCY_Active
	dc.w	0
Prefs_SyntType:
	dc.w	2
	dc.l	0,-1

	DC.L    GTPA_Depth
	dc.w	0
SyntNrCols1:
	dc.w	2
	dc.l	GTPA_Color
	dc.w	0
Prefs_SyntFront:
	dc.w	1
	dc.l	GTPA_ColorOffset,0
	dc.l	GTPA_IndicatorWidth,8
	dc.l	TAG_DONE,-1		 5 Front
	
	DC.L    GTPA_Depth
	dc.w	0
SyntNrCols2:
	dc.w	2
	dc.l	GTPA_Color
	dc.w	0
Prefs_SyntBack:
	dc.w	0
	dc.l	GTPA_ColorOffset,0
	dc.l	GTPA_IndicatorWidth,8
	dc.l	TAG_DONE,-1		 6 Back

	DC.L    GTLV_Labels,syntAttrList
	dc.l	GTLV_ShowSelected,0
	dc.l	GTLV_Selected,0
	dc.l	TAG_DONE,-1		 7 



syntFrontText:
	DC.B    'Front',0

syntBackText:
	DC.B    'Back',0

syntAttrText:
	DC.B    '',0
	CNOP    0,4

Prefs_SyntTable:
	dc.l    sc0_txt
	dc.l    sc1_txt
	dc.l    sc2_txt
;	dc.l    sc3_txt
	dc.l    0

sc0_txt:	dc.b	'Comments',0
sc1_txt:	dc.b	'Comm/Labels',0
sc2_txt:	dc.b	'Full',0
;sc3_txt:	dc.b	'Extended',0
	cnop	0,4

syntAttrNodes0:
	DC.L    syntAttrNodes1
	DC.L    syntAttrList
	DC.B    0,0
	DC.L    syntAttrName0

syntAttrName0:
	DC.B    'Rest o/t Source',0
	CNOP    0,2

syntAttrNodes1:
	DC.L    syntAttrNodes2
	DC.L    syntAttrNodes0
	DC.B    0,0
	DC.L    syntAttrName1

syntAttrName1:
	DC.B    'Comments',0
	CNOP    0,2

syntAttrNodes2:
	DC.L    syntAttrNodes3
	DC.L    syntAttrNodes1
	DC.B    0,0
	DC.L    syntAttrName2

syntAttrName2:
	DC.B    'Labels',0
	CNOP    0,2
	
syntAttrNodes3:
	DC.L    syntAttrList+4
	DC.L    syntAttrNodes2
	DC.B    0,0
	DC.L    syntAttrName3

syntAttrName3:
	DC.B    'Opcodes',0
	CNOP    0,2

syntAttrList:
	DC.L    syntAttrNodes0,0,syntAttrNodes3


;**************************************

Prefswin_taglist:
	dc.l	WA_Left
L1DAB2:
	dc.l	0
	dc.l	WA_Top
L1DABA:
	dc.l	0
	dc.l	WA_Width
Prefs_winbreedt:
	dc.l	0
	dc.l	WA_Height
Prefs_winhoog:
	dc.l	0
	dc.l	WA_IDCMP,$00000344
	dc.l	WA_Flags,$0020100A|WFLG_DEPTHGADGET
	dc.l	WA_Gadgets
L1DAE2:
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
	dc.l	0

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
	dc.l	0

Pleaseselectp.MSG:
	dc.b	'Please select prefered screenmode',0
AsmProEnviron.MSG:
	dc.b	'Asm-Pro - Environment Preferences',0
AsmProAsmPrefs:
	dc.b	'Asm-Pro - Assembler Preferences',0
AsmProSyntPrefs:
	dc.b	'Asm-Pro - Syntax Color Preferences',0
	cnop	0,4

Prefs_newmenustr:
	dc.w	$0100
	dc.l	Project.MSG
	dcb.w	7,0
	dc.w	$0200
	dc.l	Open.MSG
	dc.l	O.MSG
	dcb.w	5,0
	
	dc.w	$0200
	dc.l	SaveAs.MSG
	dc.l	A.MSG
	dcb.w	5,0
	
	dc.w	$0200
	dcb.w	2,$FFFF
	dcb.w	7,0
	
	dc.w	$0200
	dc.l	ExitPreferenc.MSG
	dc.l	Q.MSG
	dcb.w	5,0
	
	dc.w	$0100
	dc.l	Edit.MSG
	dcb.w	7,0
	
	dc.w	$0200
	dc.l	ResettoDefaul.MSG
	dc.l	D.MSG
	dcb.w	5,0
	
	dc.w	$0200
	dc.l	LastNormalSav.MSG
	dc.l	L.MSG
	dcb.w	15,0

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
prefs_menutags2:
	dc.l	0
prefs_menutags1:
	dc.l	GTMN_NewLookMenus,1,0

;******** ENV **********

env_prefsptrs:
	dc.l	epp_reqtools		03
	dc.l	epp_savemarks		 4
	dc.l	epp_sourcext		 5
	dc.l	epp_updatecheck		 6
	dc.l	epp_printdump		 7
	dc.l	epp_wb2front		 8
	dc.l	epp_resregs		 9
	dc.l	epp_safety		10
	dc.l	epp_closewb		 1
	dc.l	epp_parameters		 2
	dc.l	epp_asciionly		 3
	dc.l	epp_disassembly		 4
	dc.l	epp_showsource		 5
	dc.l	epp_enablepermit	 6
	dc.l	epp_libcallsdec		 7
	dc.l	epp_debugrealt		 8
	dc.l	epp_ctrlupdown		 9
	dc.l	epp_keepx		20
	dc.l	epp_autoindent		 1
	dc.l	epp_extreqtools		 2
	dc.l	epp_startup		 3
	dc.l	epp_syntaxcolor		 4
	dc.l	epp_customscroll	 5
	dc.l	epp_waittof		 6
	IF SLIDER
	dc.l	epp_slider		 7
	ENDIF
	dc.l	epp_linenrs		 8
	dc.l	epp_autobackup		 9
	dc.l	epp_autoupdate				
	
;******** ASM **********

asm_prefsptr:
	dc.l	app_rescue		03
	dc.l	app_level7		 4
	dc.l	app_numlock		 5
	dc.l	app_autoalloc		 6
	dc.l	app_debug		 7
	dc.l	app_listfile		 8
	dc.l	app_paging		 9
	dc.l	app_haltpage		10
	dc.l	app_allerrors		 1
	dc.l	app_procindic		 2
	dc.l	app_procline		 3 
	dc.l	app_dsclear		20
	dc.l	app_labelcolon		 4
	dc.l	app_upislow		 5
	dc.l	app_comment		 6
	dc.l	app_warning		 7
	dc.l	app_fpu		 	 8
	dc.l	app_oddadrs		 9
	dc.l	app_mmu			 1
	
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
			dc.w	$0000


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
	dc.w	$0000	;PR_ListFile:
	dc.w	$0100	;PR_Paging:	;
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

	dc.w	$0000	;1bitplane
realend3:


;***********************************************
;**         INTUITION STUFF SECTION           **
;***********************************************

	SECTION	Intuition_stuff,CODE

;****************************************************
;*             OPZETTEN VAN HET SYSTEEM             *
;****************************************************
setup_int_stuff:
	bsr	opengfxlib

	bsr	openintlib
	bsr	opengadtlib

	bsr	SetCorrectMarkKeys

	bsr	init_edit_font

	bsr	closewb
	bsr	openreqtoolslib

	move.b	(CurrentSource-DT,a4),d0
	add.b	#"0",d0
	move.b	d0,(SourceNrInBalk).l
	
	bsr	openscreen
	bsr	openwindow

	jsr	GetTheTime	;init tijd en datumstring's

	movem.l	d0-a6,-(sp)			; ***
	jsr	(C1190C).l
	move.l	(Comm_menubase-DT,a4),d0
	move.b	#MT_COMMAND,(menu_tiepe-DT,a4)
	bsr	Change_2menu_d0
	movem.l	(sp)+,d0-a6			; ***
	jsr	(OpenDevice).l
	rts

Breakdown_intstuff:
	move.l	(DosBase-DT,a4),a6
	move.l	#DIR_ARRAY,d1
	add.l	#DSIZE*10,d1
	moveq.l	#-2,d2
	jsr	(_LVOLock,a6)
	move.l	d0,d1
	beq.b	.nodir
	jsr	(_LVOCurrentDir,a6)
.nodir:

	jsr	(CloseDevice).l
	jsr	(C11964).l
	bsr	closewindow
	bsr	closescreen

	bsr	close_edit_font

	bsr	closeintlib
	bsr	closereqlib
	bsr	closegadtlib
	bsr	closeasllib
	bra	closegfxlib			; ***

closewb:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	(IntBase-DT,a4),a6
	move	#$FF2E,d0
	btst	#0,(PR_CloseWB).l
	beq.b	C1DE6E
	move	#$FFB2,d0
C1DE6E:
	jsr	(a6,d0.w)
	movem.l	(sp)+,d0-d7/a0-a6
	rts

ChangeSource:
	moveq	#0,d0
	jsr	(SENDONECHARNORMAL).l
	clr	(Cursor_col_pos-DT,a4)
	clr	(cursor_row_pos-DT,a4)
	jsr	(SENDONECHARNORMAL).l
	jsr	(CloseDevice).l
	jsr	(C11964).l
	bsr	closewindow
	bsr	closescreen
	move.b	(CurrentSource-DT,a4),d0
	add.b	#$30,d0
	move.b	d0,(SourceNrInBalk).l
	bsr	openscreen
	bsr	openwindow
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(C1190C).l
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
	jsr	(OpenDevice).l
	rts

ReinitStuff:
;	btst	#SB2_ONEPLANE,(SomeBits2-DT,a4)
;	sne	PR_OnePlane
;	and.b	#1,PR_OnePlane

	jsr	(CloseDevice).l
	jsr	(C11964).l
	bsr	closewindow
	bsr	closescreen

	move.b	(CurrentSource-DT,a4),d0
	add.b	#$30,d0
	move.b	d0,(SourceNrInBalk).l
	bsr	openscreen
	bsr	openwindow
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(C1190C).l
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
	jsr	(OpenDevice).l

;	clr.w	(Cursor_col_pos-DT,a4)	;x
;	jsr	Place_cursor_blokje
	rts

openintlib:
	move.l	(4).w,a6
	lea	(IntuitionName,pc),a1
	jsr	(_LVOOldOpenLibrary,a6)
	move.l	d0,(IntBase-DT,a4)
	rts

closeintlib:
	move.l	(4).w,a6
	move.l	(IntBase-DT,a4),a1
	jmp	(_LVOCloseLibrary,a6)

opengadtlib:
	move.l	(4).w,a6
	lea	(GadtoolsName,pc),a1
	jsr	(_LVOOldOpenLibrary,a6)
	move.l	d0,(GadToolsBase-DT,a4)
	rts

closegadtlib:
	move.l	(4).w,a6
	move.l	(GadToolsBase-DT,a4),a1
	cmp.l	#0,a1
	beq.b	C1DF8A
	clr.l	(GadToolsBase-DT,a4)
	jmp	(_LVOCloseLibrary,a6)

openasllib:
	move.l	(4).w,a6
	lea	AslName2,a1
	jsr	(_LVOOldOpenLibrary,a6)
	move.l	d0,(AslBase-DT,a4)
	rts

closeasllib:
	move.l	(4).w,a6
	move.l	(AslBase-DT,a4),a1
	cmp.l	#0,a1
	beq.b	C1DF8A
	clr.l	(AslBase-DT,a4)
	jmp	(_LVOCloseLibrary,a6)

C1DF8A:
	rts


OpenScreenOnePlane:
	move.w	#1,(Scr_NrPlanes-DT,a4)
;	bset	#0,(PR_OnePlane).l

openscreen:
	clr.l	DiepteScherm
	move.w	(Scr_NrPlanes-DT,a4),DiepteScherm+2

;	moveq.l	#0,d0
;	move.l	DiepteScherm(pc),d0
;	move.l	SchermMode,d1
;	jsr	test_debug

	cmp.l	#-1,SchermMode
	beq.s	.openscrreq
	
	sub.l	a0,a0
	lea	ScreenTagList1,a1
	move.l	(IntBase-DT,a4),a6
	jsr	(_LVOOpenScreenTagList,a6)

	tst.l	d0
	bne.w	.gelukt
.openscrreq:
	bsr	OpenScreenReq
	sub.l	a0,a0
	lea	ScreenTagList1,a1
	move.l	(scrmode_new-DT,a4),SchermMode

	move.l	(IntBase-DT,a4),a6
	jsr	(_LVOOpenScreenTagList,a6)

;	tst.l	d0
;	bne.w	.gelukt
	;exit(-1)

.gelukt:
	move.l	d0,ScreenBase
	move.l	d0,ScreenBase2
	bne.s	.ok
	rts
.ok:

	move.l	d0,a0
	move.l	d0,-(sp)
	moveq	#0,d0
	
;	move.b	35(a0),d0	;WBorTop
;	move.b	32(a0),d0	;BarHBorder
	move.b	30(a0),d0	;BarHeight
;	add.w	(EFontSize_y-DT,a4),d0
;	subq.w	#1,d0
	addq.w	#1,d0

	move.w	d0,(Scr_Title_size-DT,a4)
	move.w	d0,(Win_BorVerT-DT,a4)

;	move.l	40(a0),a1	;font
	move.l	(Fontbase_edit-DT,a4),a1
	add.w	tf_Baseline(a1),d0	;baseline offset
	move.w	d0,(Scr_Title_sizeTxt-DT,a4)


	move.w	12(a0),d0
	move.w	d0,(Scr_breedte-DT,a4)
	move.w	14(a0),d0
	move.w	d0,(Scr_hoogte-DT,a4)

	moveq	#0,d0
	move.b	35(a0),d0
	move.w	d0,(Win_BorTop-DT,a4)
	move.b	38(a0),d0
	move.w	d0,(Win_BorBottom-DT,a4)
	add.w	d0,(Win_BorVerT-DT,a4)

	add.w	(Win_BorTop-DT,a4),d0
	move.w	d0,Win_BorVer
	
	moveq	#0,d0
	move.b	36(a0),d0
	move.w	d0,(Win_BorLeft-DT,a4)
	move.b	37(a0),d0
	move.w	d0,(Win_BorRight-DT,a4)
	add.w	(Win_BorLeft-DT,a4),d0
	move.w	d0,Win_BorHor

	move.w	12(a0),d0
;	divu.w	#FontSize_x,d0
	divu.w	(EFontSize_x-DT,a4),d0
	move.w	d0,(Scr_br_chars-DT,a4)

	move.w	14(a0),d0
	divu.w	(EFontSize_y-DT,a4),d0
	move.w	d0,(Scr_hg_chars-DT,a4)

	move.l	(sp)+,d0

	move.l	a0,(ViewPortBase-DT,a4)
	add.l	#$2C,(ViewPortBase-DT,a4)

	movem.l	d0-a6,-(sp)

	cmp.b	#2,(B2E3CA-DT,a4)
	bne.b	C1E100
	jsr	(C181AC).l
	jsr	(C1815E).l
	move.b	#1,(B2E3CA-DT,a4)
	bra.b	C1E114

C1E100:
	cmp.b	#1,(B2E3CA-DT,a4)
	beq.b	C1E114
	jsr	(C1815E).l
	move.b	#1,(B2E3CA-DT,a4)
C1E114:
	jsr	(C181AC).l
	move.l	(ScreenBase).l,a0
	lea	(ScreenTagList).l,a1
	move.l	(GadToolsBase-DT,a4),a6
	jsr	(_LVOGetVisualInfoA,a6)		; ***
	move.l	d0,(MainVisualInfo-DT,a4)
	bsr	IetsMetScreenHight
	movem.l	(sp)+,d0-a6
	rts

closescreen:
	move.l	(MainVisualInfo-DT,a4),a0
	move.l	(GadToolsBase-DT,a4),a6
	jsr	(_LVOFreeVisualInfo,a6)		; ***
	move.l	(ScreenBase,pc),a0
	cmp.l	#0,a0
	beq.s	.noscreen2close
	clr.l	(ScreenBase).l
	move.l	(IntBase-DT,a4),a6
	jmp	(_LVOCloseScreen,a6)
	
.noscreen2close:
	rts

openwindow:
	IF 	SLIDER
	bsr	Add_Slider
	ENDIF

	move.l	(IntBase-DT,a4),a6

	tst.l	ScreenBase
	bne.s	.nietopwb
	bclr	#0,winflags+6
	bclr	#3,winflags+6
.nietopwb:
	sub.l	a0,a0
	lea	(windowtaglist,pc),a1
	moveq	#0,d0
	move.l	(IntBase-DT,a4),a6
	jsr	(_LVOOpenWindowTagList,a6)

	move.l	d0,(MainWindowHandle-DT,a4)
	beq.b	ReopenScreenOnePlane
	move.l	(DATA_TASKPTR-DT,a4),a0
	move.l	d0,($00B8,a0)
	move.l	d0,a0
	move.l	$0032(a0),(Rastport-DT,a4)


	move.l	(GadToolsBase-DT,a4),a6
	move.l	(MainWindowHandle-DT,a4),a0
	suba.l	a1,a1
	jsr	_LVOGT_RefreshWindow(a6)

;	jsr	test1
	rts

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


ReopenScreenOnePlane:
	bsr	closescreen
	bsr	OpenScreenOnePlane
	bra.w	openwindow

closewindow:
	jsr	close_debug_win

	IF useplugins
	jsr	close_plugs_win
	ENDIF

	IF SLIDER
	bsr	Remove_Slider
	ENDIF

	move.l	(IntBase-DT,a4),a6
	move.l	(MainWindowHandle-DT,a4),a0
	clr.l	(MainWindowHandle-DT,a4)
	jsr	(_LVOCloseWindow,a6)


	rts

	IF SLIDER

Add_Slider:
	movem.l	d0-a6,-(sp)

	tst.l	(GadToolsBase-DT,a4)
	beq.w	MainWindowCError

	move.l  (GadToolsBase-DT,a4),a6
	lea	MainWindowGList,a0
	jsr     _LVOCreateContext(a6)
	move.l  d0,a3
	tst.l   d0
	beq     MainWindowCError

	move.l	d0,MainWindowGList

	lea	MainWindowNGads,a0
	move.l  MainVisualInfo,22(a0)

	move.w	#SLIDER_KIND,d0		;kind
	move.l  a3,a0			;gad prev.
	lea	MainWindowNGads,a1	;newgad
;	lea	MainWindowGTags,a2	;taglist
	sub.l	a2,a2
	jsr     _LVOCreateGadgetA(a6)
	move.l	d0,MainWindowGadgets

;	jsr	test_debug

	move.l	MainWindowGList(pc),MainWindowWG+4


MainWindowCError:
	movem.l	(sp)+,d0-a6
	rts

Remove_Slider:
	move.l	MainWindowGadgets,a0
	cmp.l	#0,a0
	beq.w	.nogadget
	move.l	(GadToolsBase-DT,a4),a6
	jsr	_LVOFreeGadgets(a6)
.nogadget:	
	rts

	ENDIF

init_edit_font:
	bsr	openfontlib

	lea	Editor_Font,a0
	jsr	(_LVOOpenDiskFont,a6)		; ***

	tst.l	d0
	bne.s	.allesgoed

	lea	topazfont.MSG(pc),a0			; switch back to
	lea	editfont_name(pc),a1			; topaz 8 if wrong
.lopje:
	move.b	(a0)+,(a1)+
	bne.s	.lopje

	move.w	#8,Editor_Font+4
	move.b	#0,Editor_Font+6
	move.b	#0,Editor_Font+7

	move.l	(GfxBase-DT,a4),a6
	lea	Editor_Font,a0
	jsr	(_LVOOpenFont,a6)		; ***
.allesgoed:
	move.l	d0,(Fontbase_edit-DT,a4)

	move.l	d0,a0
	move.w	20(a0),(EFontSize_y-DT,a4)
	move.w	24(a0),(EFontSize_x-DT,a4)
	rts

close_edit_font:
	move.l	(GfxBase-DT,a4),a6
	move.l	(Fontbase_edit-DT,a4),a1
	cmp.l	#0,a1
	beq.s	.nofont
	jsr	(_LVOCloseFont,a6)		; *** Was -72 (openfont)
.nofont:
	bra	closefontlib			; ***
	;rts					; ***


OldEditor_Font:				
	dc.l	Oldeditfont_name
OldEditorFontSize:
	dc.w	8
	dc.b	0
	dc.b	0
Oldeditfont_name:
	dc.b    'topaz.font',0
	dcb.b	20,0
	even				

Editor_Font:
	dc.l	editfont_name
EditorFontSize:
	dc.w	8
	dc.b	0
	dc.b	0

editfont_name:
	dc.b    'topaz.font',0
	dcb.b	20,0
	even

Topaz_Font9:
	dc.l	topazfont.MSG
	dc.w	9
	dc.b	2	;1=line 2=bold 4=italic
	dc.b	1	;1

Topaz_Fontt:
	dc.l	topazfont.MSG
	dc.w	9
	dc.b	2	;1=line 2=bold 4=italic
	dc.b	1	;1

topazfont.MSG:
	dc.b	'topaz.font',0
	cnop	0,4

;********* Set Menu 2 correct Mark keys ***********

SetCorrectMarkKeys:
	move.l	4.w,a6
	lea	(keymapname).l,a1
	sub.l	d0,d0
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,a6

	jsr	(_LVOAskKeyMapDefault,a6)		; ***
	move.l	d0,a0

	move.l	km_LoKeyMap(a0),a0

	move.w	#4,d0
	lea	(markkeys-DT,a4),a1
	moveq.l	#10-1,d7
.lopje:
	move.b	2(a0,d0.w),(a1)+
	addq.l	#4,d0
	dbf	d7,.lopje

	move.l	4.w,a6
	move.l	a6,a1
	jsr	_LVOCloseLibrary(a6)

	lea	(markkeys-DT,a4),a0
	lea	RemapMarkKeys,a1
	moveq.l	#10-1,d7
.lopje2:
	move.b	(a0)+,(a1)
	lea	2(a1),a1
	dbf	d7,.lopje2
	rts

keymapname:	dc.b	'keymap.library',0
	cnop	0,4


;************* OPEN & CLOSE LIBS ****************

openfontlib:
	move.l	(4).w,a6
	lea	(FontName,pc),a1
	moveq	#0,d0
	jsr	(_LVOOldOpenLibrary,a6)
	move.l	d0,(DiskfontBase-DT,a4)
	move.l	(DiskfontBase-DT,a4),a6
	rts

closefontlib:
	move.l	(4).w,a6
	move.l	(DiskfontBase-DT,a4),a1
	jmp	(_LVOCloseLibrary,a6)

FontName:
	dc.b	"diskfont.library",0
	cnop	0,4

opengfxlib:
	move.l	(4).w,a6
	lea	(GfxName,pc),a1
	moveq	#0,d0
	jsr	(_LVOOldOpenLibrary,a6)
	move.l	d0,(GfxBase-DT,a4)
	move.l	(GfxBase-DT,a4),a6
	rts

closegfxlib:
	move.l	(4).w,a6
	move.l	(GfxBase-DT,a4),a1
	jmp	(_LVOCloseLibrary,a6)

opendoslib:
	move.l	(4).w,a6
	lea	(DosName,pc),a1
	moveq	#36,d0
	jsr	(_LVOOpenLibrary,a6)
	tst.l	d0
	beq.b	Open_Doslib_setup_Int
	move.b	#1,(B2E3CB-DT,a4)
	move.l	d0,(DosBase-DT,a4)
	bra.b	Setup_Intuition

Open_Doslib_setup_Int:
	lea	(DosName,pc),a1
	jsr	(_LVOOldOpenLibrary,a6)
	move.l	d0,(DosBase-DT,a4)
Setup_Intuition:
	move.l	d0,a6
	jsr	(Read_Prefs).l
	bsr	setup_int_stuff
	move.l	#TextPrintBuffer,(text_buf_ptr-DT,a4)
	lea	(DATA_REPLYPORT-DT,a4),a1
	move.l	(DATA_TASKPTR-DT,a4),($0010,a1)
	move.l	(4).w,a6
	jmp	(_LVOAddPort,a6)

OpenPrinterForOutput:
	movem.l	d1/d2/a0/a1,-(sp)
	move.l	(DosBase-DT,a4),a6
	move.l	#PRT.MSG,d1
	move.l	#1005,d2
	jsr	(_LVOOpen,a6)
	move.l	d0,(PrinterBase-DT,a4)
	bne.b	.noprinter
	bclr	#0,(PR_PrintDump).l
	lea	(PrinterDevice.MSG).l,a0
	jsr	(beeldtextaf).l
.noprinter:
	movem.l	(sp)+,d1/d2/a0/a1
	rts

C1E2F0:
	move.b	(CurrentSource-DT,a4),d0
	jsr	(C141CE).l
	jsr	(C142A4).l
	movem.l	d0-d7/a0-a6,-(sp)
	lea	(SourcePtrs-DT,a4),a0
	moveq	#9,d7
C1E30A:
	btst	#0,(CS_SomeBits,a0)	;Source Changed?
	bne.b	C1E320
	lea	(CS_size,a0),a0
	dbra	d7,C1E30A
	movem.l	(sp)+,d0-d7/a0-a6
	bra.b	C1E34E

C1E320:
	move.l	a0,d0
	lea	(SourcePtrs-DT,a4),a1
	sub.l	a1,d0
	lsr.l	#8,d0
	move.b	d0,(B30174-DT,a4)
	jsr	(C141CE).l
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(C1430E).l
	movem.l	(sp)+,d0-d7/a0-a6
	lea	(CS_size,a0),a0
	dbra	d7,C1E30A
	movem.l	(sp)+,d0-d7/a0-a6
C1E34E:
	rts

FreeSources:
	lea	(SourcePtrs-DT,a4),a0
	moveq	#9,d7
C1E356:
	tst.l	(CS_start,a0)
	beq.b	C1E388
	move.l	(CS_start,a0),a1
	move.l	(CS_length,a0),d0
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	(4).w,a6
	jsr	(_LVOFreeMem,a6)
	movem.l	(sp)+,d0-d7/a0-a6
	movem.l	d7/a0/a1,-(sp)
	moveq	#$3F,d7
C1E37A:
	move.l	#0,(a0)+
	dbra	d7,C1E37A
	movem.l	(sp)+,d7/a0/a1
C1E388:
	lea	($0100,a0),a0
	dbra	d7,C1E356
	rts

C1E392:
	bsr	C1E2F0
	jsr	(C1432A).l
Restart_Entrypoint:
	move	d0,-(sp)
	jsr	(C17AF0).l
	jsr	(C182BE).l
	bsr.b	FreeSources
	move.b	#'0',(SourceNrInBalk).l
	move.b	#'0',(B1F237).l
	move.b	#0,(MenuFileName).l
	move.b	#0,(CurrentSource-DT,a4)
	move.b	#0,(LastFileNaam-DT,a4)
	jsr	(RESETMENUTEXT2).l
	move.l	(WORK_START-DT,a4),a1
	move.l	(WORK_END-DT,a4),d0
	sub.l	a1,d0
	move.l	(4).w,a6
	jsr	(_LVOFreeMem,a6)
	jsr	(ZapIncludes).l
	jsr	(C2994).l
	move	(sp)+,d0
	cmp.b	#'R',d0
	bne.b	close_PrinterBase
	move.l	(DATA_USERSTACKPTR-DT,a4),sp
	jmp	(C40E).l

close_PrinterBase:
	bsr	Breakdown_intstuff
;	jsr	(CloseTimerDev).l
	lea	(DATA_REPLYPORT-DT,a4),a1
	move.l	(4).w,a6
	jsr	(_LVORemPort,a6)
	move.l	(DosBase-DT,a4),a6
	move.l	(PrinterBase-DT,a4),d1
	beq.b	C1E42E
	jsr	(_LVOClose,a6)
C1E42E:
	move.l	a6,a1
	move.l	(4).w,a6
	jmp	(_LVOCloseLibrary,a6)

C1E43A:
	addq.w	#4,sp

AllocMainWorkspace:
	tst.w	ShowLogin
	bne.s	AllocMainWorkspace2
	tst.w	PR_Startup
	beq.s	nologinwindow

AllocMainWorkspace2:
	movem.l	d0-a6,-(sp)
	jsr	DeactivateMsgs
	jsr	OpenLoginWindow
	jsr	ActivateMsgs
	movem.l	(sp)+,d0-a6

nologinwindow:
	st.b	ShowLogin
	jsr	Show_Cursor

	bset	#1,(SomeBits3-DT,a4)	;???
	lea	(AllocMainWorkspace2,pc),a0
	move.l	a0,(Error_Jumpback-DT,a4)

	move.l	_memtype,d0
	tst.b	d0
	beq	Absolute_mem_stuff

	moveq.l	#1,d1
	lsl.l	d0,d1
	lsr.l	#1,d1
	or.l	#$20000,d1

C1E492:
	move.l	_memamount,d0
	asl.l	#8,d0
	asl.l	#2,d0
	move.l	d0,(WORK_END-DT,a4)
	move.l	(4).w,a6
	jsr	(_LVOAllocMem,a6)
	tst.l	d0
	beq	AllocMainWorkspace2
	move.l	d0,-(sp)
	move.l	#$00020002,d1
	move.l	(4).w,a6
	jsr	(_LVOAvailMem,a6)
	cmp.l	#$00001800,d0
	ble.b	C1E508
	tst.l	(ReqToolsbase-DT,a4)
	beq.b	C1E508
	or.w	#$005B,(PR_ReqLib).l
	move.l	(sp)+,d0

	bra.b	C1E574

ShowLogin:	dc.w	0

C1E508:
	and	#$FEEF,(PR_ReqLib).l
	lea	(Reqtoolslibra.MSG).l,a0
	tst.l	(ReqToolsbase-DT,a4)
	bne.b	C1E522
	lea	(Reqtoolslibra.MSG0).l,a0
C1E522:
	moveq	#0,d7
	jsr	(beeldtextaf).l
	move.l	(sp)+,d0
	bra.b	C1E574

Absolute_mem_stuff:
	MOVE.L	_absmemadr,d0
	move.l	d0,-(sp)
	move.l	_memamount,d0
	asl.l	#8,d0
	asl.l	#2,d0
	move.l	d0,(WORK_END-DT,a4)
	move.l	(sp)+,a1
	move.l	(4).w,a6
	jsr	(_LVOAllocAbs,a6)
	tst.l	d0
	beq	AllocMainWorkspace2
C1E574:
	move.l	d0,(WORK_START-DT,a4)
	add.l	d0,(WORK_END-DT,a4)
	move.l	(WORK_END-DT,a4),a0
	sub.l	#$0064,a0			; *** was sub.w
	move.l	a0,(WORK_ENDTOP-DT,a4)
	move.l	d0,a0
	move.l	a0,(CodeStart-DT,a4)
	move.l	a0,(RelocStart-DT,a4)
	move.l	a0,(RelocEnd-DT,a4)
	move.l	a0,(LabelStart-DT,a4)
	move.l	a0,(LPtrsEnd-DT,a4)
	move.l	a0,(LabelEnd-DT,a4)


	jsr	(C141C8).l
	jsr	(C14232).l
	bsr.b	C1E5FA
	jmp	(PRIVILIGE_VIOL1).l

C1E5B6:
	lea	(ADD.MSG,pc),a0
	jsr	(printthetext).l
	moveq	#$3F,d0
	jsr	(SENDONECHARNORMAL).l
	jsr	(Druk_MsgAf_GetNumbr).l
	bne.b	C1E5F4
	asl.l	#8,d0
	asl.l	#2,d0
	beq.b	C1E5F4
	move.l	(WORK_END-DT,a4),a1
	move.l	(4).w,a6
	move.l	d0,-(sp)
	jsr	(_LVOAllocAbs,a6)
	move.l	(sp)+,d1
	tst.l	d0
	beq.b	C1E5F4
	add.l	d1,(WORK_END-DT,a4)
	add.l	d1,(WORK_ENDTOP-DT,a4)
C1E5F4:
	jmp	(com_workspace).l

C1E5FA:
	move.l	(DATA_TASKPTR-DT,a4),a0
	move.l	#EXCEPTIONHANDLER,($0032,a0)
	rts

IetsMetScreenHight:
	move.l	(ScreenBase).l,a0
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	move	(14,a0),d2	;Hight screen
	move	(12,a0),d3	;Width screen
	move.b	(30,a0),d4	;titlehoogte
	addq.l	#1,d4
;	add.w	(EFontSize_y-DT,a4),d4	;titlesize

	move.l	d2,d0
;	lsr.l	#3,d2	;hg
	divu.w	(EFontSize_y-DT,a4),d2
;	ext.l	d2
	subq.w	#3,d2
	move	d2,(AantalRegels_Editor-DT,a4)	;aantal regels hoog -3
	lsr.w	#1,d2
	move	d2,(AantalRegels_HalveEditor-DT,a4)	;en nog eens gedeeld door 2
	move	d0,d1
;	lsr.w	#3,d0
	divu.w	(EFontSize_y-DT,a4),d0
	ext.l	d0
	sub	#1,d0
	move	d0,(ScreenHight-DT,a4)	;aantal regels hoog -1

	divu	#100,d0
	add	#'0',d0
	move.b	d0,(EndPos1).l
	swap	d0
	ext.l	d0
	divu	#10,d0
	add	#'0',d0
	move.b	d0,(EndPos2).l
	swap	d0
	add	#'0',d0
	move.b	d0,(EndPos3).l

	move	d1,d0
	move	d0,Scrhoog_1+2
	move	d0,Scrhoog_2+2
;	move	d0,Scrhoog_3
	move	d0,Scrhoog_4

	ext.l	d0
	divu.w	(EFontSize_y-DT,a4),d0
	subq.w	#2,d0
	move	d0,d1
	move	d0,(aantal_regels_min2-DT,a4)	;aantal regels -2
	subq.w	#1,d0
	move	d0,(aantal_regels_min3-DT,a4)	;-3
	lsl.w	#1,d0
	move	d0,(aantal_regels_min3_div2-DT,a4)	;/2

	move.w	(aantal_regels_min2-DT,a4),d0	;aantal regels -2
	mulu.w	(EFontSize_y-DT,a4),d0
	addq.w	#2,d0
	move.w	d0,(Edit_hoogte-DT,a4)

	move.w	d1,d0		;hoog/fontsizey -2
	subq.w	#2,d0
	mulu.w	d3,d0		;breedte scherm
	lsr.l	#3,d0		;in bytes
	mulu.w	(EFontSize_y-DT,a4),d0

;	tst.w	PR_OnePlane
;	bne.s	.eenplane
;	add.l	d0,d0
	mulu.w	(Scr_NrPlanes-DT,a4),d0
;.eenplane:
	move.l	d0,(EditScrollSize-DT,a4)

	mulu.w	d3,d4			;breedte scherm

	move.l	d0,(EditScrollSizeTitleDown-DT,a4)

;	move.w	#1,d0		;4 regels?
;	mulu.w	d3,d0		;breedte scherm
;	lsr.l	#3,d0		;in bytes
;	mulu.w	(EFontSize_y-DT,a4),d0
;	tst.w	PR_OnePlane
;	bne.s	.eenplaneup
;	add.l	d0,d0
;.eenplaneup:
;	move.l	d0,(EditScrollSizeTitleUp-DT,a4)

	lsr.l	#3,d4
;	tst.w	PR_OnePlane
;	bne.s	.eenplane2
;	add.l	d4,d4
	mulu.w	(Scr_NrPlanes-DT,a4),d4
;.eenplane2:
	add.l	d4,(EditScrollSizeTitleDown-DT,a4)
	move.l	d4,(EditScrollSizeTitleUp-DT,a4)

	move.w	d3,d0
	lsr.w	#3,d0
	mulu.w	(EFontSize_y-DT,a4),d0
;	tst.w	PR_OnePlane
;	bne.s	.eenplane3
;	add.w	d0,d0		;2 planes
	mulu.w	(Scr_NrPlanes-DT,a4),d0
;.eenplane3:
	move.w	d0,(EditScrollRegelSize-DT,a4)

;	move.w	(aantal_regels_min3-DT,a4),d0
;	subq.w	#1,d0
;	tst.w	PR_OnePlane
;	bne.s	.eenplane4
;	add.w	d0,d0	;2planes
;.eenplane4:
;	mulu.w	(EFontSize_y-DT,a4),d0	;nr lines
;	subq.w	#1,d0
;	move.w	d0,(Edit_nrlines-DT,a4)

	move	d1,d0
	add.w	d0,d0				; ***
	move	d0,(Max_Hoogte-DT,a4)
	rts

;ALLOCATEFastC.MSG:
;	dc.b	'ALLOCATE Fast/Chip/Publ/Abs>',0
;ABSOLUTEMemor.MSG:
;	dc.b	'ABSOLUTE Memory Addr.>',0

ADD.MSG:
	dc.b	'ADD-WORKSPACE (Max.',0
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

WB:	DC.B    'Workbench',0
	even

JumpLineNr:
	dc.w	0
W1E7C4:
	dc.w	0

L1E7C6:
	dc.l	$8000000B,$0000005F
	dc.l	$80000003,2
	dc.l	0


ScreenTagListDefault:
;	dc.l	SA_Left,0
;	dc.l	SA_Top,0
;	dc.l	SA_Width
;BreedteScherm:
;	dc.l	640
;	dc.l	SA_Height
;HoogteScherm:
;	dc.l	256
	dc.l	SA_Depth
;DiepteScherm:
	dc.l	2
	dc.l	SA_Font,Editor_Font
	dc.l	SA_Type,CUSTOMSCREEN
	dc.l	SA_Interleaved,TRUE
;	dc.l	SA_DisplayID
;SchermMode:
;	dc.l	$00008000	;hires screen
	dc.l	SA_Title,AsmPro_titletxt.MSG
	dc.l	SA_Pens,SchermMode\.pens
	dc.l	SA_AutoScroll,TRUE
	dc.l	SA_Overscan,OSCAN_STANDARD
	dc.l	0

ScreenTagList1:
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
	dc.l	SA_Pens,.pens
	dc.l	SA_AutoScroll,TRUE
	dc.l	SA_Overscan,OSCAN_STANDARD
	dc.l	0

.pens:
	dc.l	$FFFF0000

L1E83A:
	dc.l	$8000000B
	dc.l	$0000005F
	dc.l	$80000003
	dc.l	2
	dc.l	0
L1E84E:
	dc.l	$8000000B
	dc.l	$0000005F
	dc.l	$80000026
	dc.l	Searchfromcur.MSG
	dc.l	$80000022
	dc.l	_Search_Cased.MSG
	dc.l	$80000003
	dc.l	2
	dc.l	0
SearchReqTags:
	dc.l	$8000000B
	dc.l	$0000005F
	dc.l	$80000026
	dc.l	Searchfor.MSG0
	dc.l	$80000022
	dc.l	_Replace_Abor.MSG
	dc.l	$80000003
	dc.l	2
	dc.l	0
CaseSenceSearch:
	dcb.b	2,0
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
B1E909:
	dcb.b	$0000003F,0
	dcb.b	$0000003F,0
	dcb.b	2,0
andreplaceitw.MSG:
	dc.b	''' and replace it with ',0
_Replace_Abor.MSG:
	dc.b	'_Replace|_Abort',0
Founditshould.MSG:
	dc.b	'Found it !, should it be replaced ?',0	; ***
_Yes_No_Last_.MSG:
	dc.b	'_Yes|_No|_Last|_Global|_Abort',0
Jumptowhichli.MSG:
	dc.b	'Jump to which line number',0
	dc.b	'_Jump|_Abort',0
Selectcolours.MSG:
	dc.b	'Select colours',0
	dc.b	'Asm-Pro '
	version
;	dc.b	'V1.01'
	dc.b	' Amiga guide handler',0
	dc.b	'Help amigaguide already active',0	; ***
amigaguidelib.MSG:
	dc.b	'amigaguide.library',0
sAGAGuide.MSG:
;	dc.b	's:AGA.Guide',0
	dc.b	'asmpro:asm-pro.guide',0

AsmProV128cus.MSG:
	dc.b	'Asm-Pro '
	version
;	dc.b	'V1.01'
	dc.b	' Asm-Pro help guide.',0
Unabletoopena.MSG:
	dc.b	'Unable to open amigaguide.library',0
Unabletoopent.MSG:
	dc.b	'Unable to open the Asm-Pro.Guide',0
	dc.b	'Source '

	even
S.MSG:
	DC.B	'(.s|.asm|.i)'
	dcb.b	16-12,0
;	dc.b	'.S',0,0
;	dcb.b	2,0

	dc.b	'         »» Asm-Pro '
	version
	dc.b		subversion
;	dc.b	'V1.01'
	dc.b	'««    ',0,0


;NewWindow2:	dc.w	0,0
;
;ScrBr_1:	dc.w	640
;Scrhoog_1:	dc.w	200
;		dc.w	1
;
;		dc.l	IDCMP_MENUPICK|IDCMP_MOUSEBUTTONS|IDCMP_RAWKEY
;		dc.l	WFLG_ACTIVATE|WFLG_SIZEGADGET ;|WFLG_BORDERLESS|WFLG_BACKDROP
;
;		dcb.w	4,0
;		dc.l	AsmPro_abouttxt.MSG
;
;ScreenBase:	dc.l	0
;		dc.l	0
;		dc.w	640
;Scrhoog_2:	dc.w	200
;		dc.w	640
;Scrhoog_3:	dc.w	200
;		dc.w	WBENCHSCREEN	;type
;;		dc.w	15

windowtaglist:
		DC.L    WA_Left,0
		DC.L    WA_Top,0
		DC.L    WA_Width
ScrBr_1:	dc.l	640
		DC.L    WA_Height
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

		dc.l	$80000093,1	;newlook menu's
MainWindowWG:
		dc.l	$8000006C,0	;MainWindowGList
		dc.l	0

;windowtaglist_SL:
;;	dc.l	$80000093,1		;newlook menu's
;	dc.l	$8000006C,0
;	dc.l	0


	IF SLIDER

MainWindowGTags:
	DC.L    PGA_Freedom,LORIENT_VERT
	DC.L    GA_RelVerify,1
	DC.L    $80080027,12345
	DC.L    $80080029,6
	DC.L    $8008002A,SliderFormat
	DC.L    $8008002B,$00000004
	DC.L    $80030015,1
	DC.L    TAG_DONE
	


GD_Slider		EQU    0
;MainWindow_CNT		EQU    1

MainWindowGList:	DC.L    0
MainWindowGadgets:	DC.L    0

MainWindowNGads:
	DC.W	316,20,21,229
	DC.L	labelText	;08 gadtext
	dc.l	Editor_Font	;12 font
	DC.W	GD_Slider	;14 GadID
	DC.L	PLACETEXT_LEFT	;18 Flags
	dc.l	0		;22 VisualInfo
	dc.l	0		;26 USER


labelText:
    DC.B    'tekst',0


SliderFormat:
    DC.B    '%ld',0
    CNOP     0,2

	ENDIF

;aga window
NewAmiGuide:	dc.l	0
		dc.l	sAGAGuide.MSG
ScreenBase2:	dcb.l	4,0
		dc.l	AsmProV128cus.MSG
		dc.l	3
		dcb.l	5,0



Gave_prefs_table:
	dc.w	PR_ReqLib-*,"RL"		 6
	dc.w	PR_SaveMarks-*,"SM"		 6
	dc.w	PR_SourceExt-*,".S"		 6
	dc.w	PR_UpdateAlways-*,"AU"		12
	dc.w	PR_PrintDump-*,"PD"		 4
	dc.w	PR_WBFront-*,"WF"		 4
	dc.w	PR_RegsRes-*,"RR"		 8
	dc.w	PR_Safety-*,"SO"		 6
	dc.w	PR_CloseWB-*,"CW"		60
	dc.w	PR_params-*,"PS"		 4
	dc.w	PR_OnlyAscii-*,"OA"		 4
	dc.w	PR_NoDisasm-*,"DA"		 6
	dc.w	PR_ShowSource-*,"SS"		80
	dc.w	PR_Enable_Permit-*,"EP"		40
	dc.w	PR_LibCalDec-*,"LD"		 4
	dc.w	PR_RealtimeDebug-*,"RD"		60
	dc.w	PR_CtrlUp_Down-*,"UD"		 6
	dc.w	PR_Keepxy-*,"KX"		 8
	dc.w	PR_AutoIndent-*,"AI"		 8
	dc.w	PR_ExtReq-*,"XR"		20
	dc.w	PR_Startup-*,"SW"		20
	dc.w	PR_SyntaxColor-*,"SC"		20
	dc.w	PR_CustomScroll-*,"CS"		??
	dc.w	PR_WaitTOF-*,"WT"		??
	IF SLIDER
	dc.w	PR_Slider-*,"SL"		??
	ENDIF
	dc.w	PR_LineNrs-*,"LN"		??
	dc.w	PR_AutoBackup-*,"AB"		??
	dc.w	PR_AutoUpdate-*,"AS"
	
	dc.w	PR_Rescue-*,"RS"		 0
	dc.w	PR_Level7-*,"L7"		 4
	dc.w	PR_NumLock-*,"NL"		 8
	dc.w	PR_AutoAlloc-*,"AA"		12 
	dc.w	PR_Debug-*,"DB"			 4
	dc.w	PR_ListFile-*,"LF"		 8
	dc.w	PR_Paging-*,"PG"		32
	dc.w	PR_HaltPage-*,"HP"		 6
	dc.w	PR_AllErrors-*,"AE"		40
	dc.w	PR_Progress-*,"PI"		 6
	dc.w	PR_ProgressLine-*,"PL"		00
	dc.w	PR_DsClear-*,"DC"		32
	dc.w	PR_Label-*,"L:"			72
	dc.w	PR_Upper_LowerCase-*,"UL"	 8
	dc.w	PR_Comment-*,";C"		92
	dc.w	PR_Warning-*,"FW"		20
	dc.w	PR_FPU_Present-*,"FP"		 4
	dc.w	PR_OddData-*,"OD"		 8
	dc.w	PR_MMU-*,"MP"			52

	dc.w	0

C1EC42:
	btst	#0,(PR_ReqLib).l
	beq.b	C1EC7A
openreqtoolslib:
	move.l	(4).w,a6
	lea	(reqtoolslibra.MSG,pc),a1
	moveq	#0,d0
	jsr	(_LVOOldOpenLibrary,a6)
	move.l	d0,(ReqToolsbase-DT,a4)
	bne.b	C1EC7A
	and	#$FEEF,(PR_ReqLib).l
	tst.l	(MainWindowHandle-DT,a4)
	beq.b	C1EC7A
	lea	(Reqtoolslibra.MSG0).l,a0
	jmp	(printthetext).l

C1EC7A:
	rts

reqtoolslibra.MSG:
	dc.b	'reqtools.library',0,0

closereqlib:
	move.l	(ReqToolsbase-DT,a4),d0
	beq.b	C1ECA0
	move.l	d0,a1
	move.l	(4).w,a6
	jsr	(_LVOCloseLibrary,a6)
C1ECA0:
	rts

;*********** Font requesters *************

fontreq_edit:
	movem.l	d0-a6,-(sp)

;	move.l	#RTFO_FilterFunc,fonttags
;	move.l	#0,fonttags

	bsr	fontrequester
	bne.s	.error_in_req		; choose cancel
	
	bsr	close_edit_font
	bsr	init_edit_font

	move	#2,(PrefsGedoe-DT,a4)	;refresh display...
.error_in_req:
	movem.l	(sp)+,d0-a6
	rts

fontrequester:
	move.l	AslBase,a6
	cmp.l	#0,a6
	beq.w	.noasl

;	lea	editfont_name,a0
;	move.w	EditorFontSize,d0
;	jsr	test_debug

	lea	fonttags(pc),a0
	move.l	ScreenBase,0+4(a0)
	move.w	EditorFontSize,8+6(a0)
;	move.l	editfont_name,16+4(a0)

	move.w	Scr_hoogte,d1
	divu.w	#22,d1
	move.w	d1,24+6(a0)

	move.l	#ASL_FontRequest,d0
	jsr	_LVOAllocAslRequest(a6)
	move.l	d0,fontreq
	beq.w	.noasl

	sf.b	FontChanged			
	movem.l	a0/a1,-(a7)			; save font attributes
	lea	editfont_name,a0
	lea	Oldeditfont_name,a1
.FontBack:
	move.b	(a0)+,(a1)+
	bne.s	.FontBack
	move.w	EditorFontSize,OldEditorFontSize
	move.w	EditorFontSize+2,OldEditorFontSize+2
	move.w	EditorFontSize+3,OldEditorFontSize+3

	movem.l	(a7)+,a0/a1			

	move.l	d0,a0
	sub.l	a1,a1
	jsr	_LVOAslRequest(a6)
	tst.l	d0
	beq.s	.nietgoed

	st.b	FontChanged			
	move.l	fontreq(pc),a0
	move.l	fo_Attr+ta_Name(a0),a5
	move.w	fo_Attr+ta_YSize(a0),d7
	move.b	fo_Attr+ta_Style(a0),EditorFontSize+2	
	move.b	fo_Attr+ta_Flags(a0),EditorFontSize+3	

	lea	editfont_name,a0
.lopje:
	move.b	(a5)+,(a0)+
	bne.s	.lopje
	move.w	d7,EditorFontSize

	move.l	fontreq(pc),a0
	jsr	_LVOFreeAslRequest(a6)

	moveq.l	#0,d0
	rts

.nietgoed:
	move.l	fontreq(pc),a0
	jsr	_LVOFreeAslRequest(a6)
.noasl	moveq.l	#1,d0	;error
	rts

FontChanged:				
	dc.b	0
	even

fonttags:
	dc.l	ASLFO_Screen,0		;0
	dc.l	ASLFO_InitialSize,8	;8
	dc.l	ASLFO_InitialName,editfont_name	;16
	dc.l	ASLFO_MaxHeight,0	;24
	dc.l	ASL_FuncFlags,FONF_FIXEDWIDTH
	dc.l	0

fontreq:	ds.l	1


	rem
fontrequester:
	move.l	ReqToolsbase,a6
	cmp.l	#0,a6
	beq.s	.fontreq_foutje

	moveq.l	#RT_FONTREQ,d0
	sub.l	a0,a0
	jsr	_LVOrtAllocRequestA(a6)
	move.l	d0,fontreq
	beq.s	.fontreq_foutje

	move.l	d0,a1

	move.l	#FREQF_FIXEDWIDTH,rtfo_Flags(a1)
	lea	.Fonttext(pc),a3
;	sub.l	a0,a0
	lea	fonttags,a0
	jsr	_LVOrtFontRequestA(a6)
	tst.l	d0
	beq.w	.nietgoed

	move.l	fontreq(pc),a0
	move.l	rtfo_Attr+ta_Name(a0),a5
	move.w	rtfo_Attr+ta_YSize(a0),d7

	lea	editfont_name,a0
.lopje:
	move.b	(a5)+,(a0)+
	bne.s	.lopje

	move.w	d7,EditorFontSize

	move.l	fontreq(pc),a1
	jsr	_LVOrtFreeRequest(a6)

	moveq.l	#0,d0
	rts

.nietgoed:
	move.l	fontreq(pc),a1
	jsr	_LVOrtFreeRequest(a6)
.fontreq_foutje:
	moveq.l	#1,d0
	rts

.Fonttext
	dc.b	"Select a font!",0
	even

fonttags:
	dc.l	RTFO_FilterFunc,fonthook
	dc.l	0

filterfunc:
	;A0 - (struct Hook *) your hook
	;A2 - (struct rtFontRequester *) your filereq
	;A1 - (struct TextAttr *) textattr of font

	move.l	d1,-(sp)
	moveq.l	#TRUE,d0
	moveq.l	#0,d1
	move.w	Scr_breedte,d1
	divu.w	4(a1),d1
;	cmp.w	#76,d1
	cmp.w	#45,d1
	bhs.s	.true
	moveq.l	#FALSE,d0
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

fontreq
	ds.l	1

	erem

;**********************


YesReqLib:
	tst.l	(ReqToolsbase-DT,a4)
	bne	ReqLibIsOpen
	move.l	d0,-(sp)
	bsr	C1EC42
	move.l	(sp)+,d0
	tst.l	(ReqToolsbase-DT,a4)
	bne	ReqLibIsOpen
	bclr	#0,(PR_ReqLib).l
	jmp	(FileReqStuff).l

IO_msgptrs:
	dc.w	Readsource.MSG-*	0
	dc.w	1
	dc.w	Writesource.MSG-*	1
	dc.w	1
	dc.w	Readbinary.MSG-*	2
	dc.w	2
	dc.w	Writebinary.MSG-*	3
	dc.w	2
	dc.w	Readobject.MSG-*	4
	dc.w	2
	dc.w	Writeobject.MSG-*	5
	dc.w	2
	dc.w	Writelink.MSG-*		6
	dc.w	2
	dc.w	Writeblock.MSG-*	7
	dc.w	3
	dc.w	Directoutput.MSG-*	8
	dc.w	2
	dc.w	Zapfile.MSG-*		9
	dc.w	2
	dc.w	Insertsource.MSG-*	10
	dc.w	3
	dc.w	Selectprefere.MSG-*	11
	dc.w	4
	dc.w	Selectprefere.MSG0-*	12
	dc.w	5
	dc.w	WriteProject.MSG-*	13
	dc.w	6
	dc.w	ReadProject.MSG-*	14
	dc.w	6
	dc.w	Writesource.MSG-*	15
	dc.w	2
	dc.w	Readsource.MSG-*	16
	dc.w	2

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
Selectprefere.MSG:	dc.b	'Select preference file to load',0
Selectprefere.MSG0:	dc.b	'Select preference file to save',0
WriteProject.MSG:	dc.b	'Write Project',0
ReadProject.MSG:	dc.b	'Read Project',0

	REM
AslLibIsOpen:
	move.l	d0,-(sp)
	move.l	AslBase,a6
	cmp.l	#0,a6
	bne.w	.noreq

	lea	.filetags(pc),a0
	move.l	ScreenBase,0+4(a0)
;	move.l	,8+4(a0)

	moveq.l	#ASL_FileRequest,d0
	jsr	_LVOAllocAslRequest(a6)
	move.l	d0,(FileReqBase-DT,a4)
	beq.s	.noreq

	move.l	(sp),d0
	lea	(IO_msgptrs,pc),a0
	lsl.w	#2,d0
	add	d0,a0

	cmp	#6,(2,a0)
	beq.w	GetProjExt
	cmp	#4,(2,a0)
	beq.w	GetPrefsExt
	cmp	#5,(2,a0)
	beq.w	GetPrefsExt
	btst	#0,(PR_SourceExt).l
	beq.w	C1EE60
	cmp	#1,(2,a0)
	beq.b	.C1EE2C
	cmp	#3,(2,a0)
	bne.b	C1EE60
.C1EE2C:
	lea	(S.MSG).l,a1
	lea	(req_file_extentie).l,a2

	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+


	move.l	(FileReqBase-DT,a4),a0
	sub.l	a1,a1
	jsr	_LVOAslRequest(a6)
	tst.l	d0
	beq	.noreq		;Error showing FReq

;	lea	(ReqSourceExt).l,a0
;	move.l	(FileReqBase-DT,a4),a1
;	jsr	(-$0030,a6)
	bra.b	GetTheFile

.noreq:
	jmp	FileReqStuff


.filetags:
	dc.l	ASLFO_Screen,0		;0
	dc.l	ASLFR_TitleText,0
	dc.l	ASLFR_InitialPattern,0
	dc.l	ASLFR_DoPatterns,TRUE
	dc.l	ASLFR_RejectIcons,TRUE
	dc.l	0
	EREM


*********************************
**   old reqtools filereq...   **
*********************************

ReqLibIsOpen:
	move.l	d0,-(sp)
	move.l	(ReqToolsbase-DT,a4),a6
	moveq	#0,d0
	sub.l	a0,a0
	jsr	(_LVOrtAllocRequestA,a6)		; ***
	move.l	d0,(FileReqBase-DT,a4)
	beq	C1EFD0

	move.l	(sp),d0
	lea	(IO_msgptrs,pc),a0
	lsl.w	#2,d0
	add	d0,a0

	cmp	#6,(2,a0)
	beq.b	GetProjExt
	cmp	#4,(2,a0)
	beq.b	GetPrefsExt
	cmp	#5,(2,a0)
	beq.b	GetPrefsExt
	btst	#0,(PR_SourceExt).l
	beq.b	C1EE60
	cmp	#1,(2,a0)
	beq.b	C1EE2C
	cmp	#3,(2,a0)
	bne.b	C1EE60
C1EE2C:
	lea	(S.MSG).l,a1
	lea	(req_file_extentie).l,a2

	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+

	lea	(ReqSourceExt).l,a0
	move.l	(FileReqBase-DT,a4),a1
	jsr	(_LVOrtChangeReqAttrA,a6)		; ***
	bra.b	GetTheFile


GetProjExt:
	lea	ReqProjExt,a0
	move.l	(FileReqBase-DT,a4),a1
	jsr	(_LVOrtChangeReqAttrA,a6)		; ***
	bra.b	GetTheFile

GetPrefsExt:
	lea	ReqPrefsExt,a0
	move.l	(FileReqBase-DT,a4),a1
	jsr	(_LVOrtChangeReqAttrA,a6)		; ***
	bra.b	GetTheFile

C1EE60:
	lea	(L1F012).l,a0
	move.l	(FileReqBase-DT,a4),a1
	jsr	(_LVOrtChangeReqAttrA,a6)		; ***
GetTheFile:
	move.l	(sp),d0
	lea	(IO_msgptrs,pc),a1
	lsl.w	#2,d0
	add	d0,a1
	move	(2,a1),d1
	cmp	#4,d1
	blt.b	C1EE84
	moveq	#3,d1
C1EE84:
	subq.w	#1,d1
	bne.s	.noreplace

	movem.l	a0/a1/d0,-(sp)
	lea	(DIR_ARRAY-DT,a4),a0
	moveq.l	#0,d0
	move.b	(CurrentSource-DT,a4),d0
;	mulu.w	#130+2,d0	;DSIZE+2
	lsl.l	#7,d0		;DSIZE
	lea	(a0,d0.l),a0

	lea	(PrevDirnames-DT,a4),a1
.copy:
	move.b	(a0)+,(a1)+
	bne.s	.copy
	movem.l	(sp)+,a0/a1/d0


.noreplace:
	lea	(PrevDirnames-DT,a4),a1
	lsl.w	#7,d1		;*128
	lea	(a1,d1.w),a1
	tst.b	(a1)
	beq.b	C1EEAC
	move.l	(FileReqBase-DT,a4),a2
	move.l	($0010,a2),a2
	moveq	#$7F,d7
C1EE9E:
	tst.b	(a1)
	beq.b	C1EEA8
	move.b	(a1)+,(a2)+
	dbra	d7,C1EE9E
C1EEA8:
	move.b	#0,(a2)
C1EEAC:
	move.l	(sp),d0
	lea	(IO_msgptrs,pc),a1
	lsl.w	#2,d0
	add	d0,a1
	moveq	#0,d1
	move	(2,a1),d1
	add	(a1),a1
	move.l	a1,a3
	lea	(MenuFileName).l,a1

	lea	(FileNaam-DT,a4),a2
	moveq	#30-1,d0
C1EECC:
	cmp	#4,d1
	bge.b	C1EEE4
	cmp	#2,d1
	bne.b	C1EEDE
	cmp.b	#$2E,(a1)
	beq.b	C1EEE4
C1EEDE:
	move.b	(a1)+,(a2)+
	dbra	d0,C1EECC
C1EEE4:
	clr.b	(a2)
	move.l	(FileReqBase-DT,a4),a1

	lea	(FileNaam-DT,a4),a2

	lea	(ReqTaglist).l,a0
	jsr	(_LVOrtFileRequestA,a6)		; ***
	tst	d0
	beq	C1EFD0
	move.l	(sp),d0
	lea	(IO_msgptrs,pc),a1
	lsl.w	#2,d0
	add	d0,a1
	move	(2,a1),d1
	cmp	#4,d1
	blt.b	C1EF14
	moveq	#3,d1
C1EF14:
	subq.w	#1,d1
	lea	(PrevDirnames-DT,a4),a1
	lsl.w	#7,d1
	lea	(a1,d1.w),a1
	move.l	(FileReqBase-DT,a4),a2
	move.l	($0010,a2),a2
	moveq	#$7F,d7
C1EF2A:
	tst.b	(a2)
	beq.b	C1EF34
	move.b	(a2)+,(a1)+
	dbra	d7,C1EF2A
C1EF34:
	move.b	#0,(a1)
	move.l	(sp)+,d0
	lea	(IO_msgptrs,pc),a0
	lsl.w	#2,d0
	add	d0,a0
	cmp	#1,(2,a0)
	beq.b	C1EF6E
	cmp	#2,(2,a0)
	beq.b	C1EF60
	lea	(DIR_ARRAY3).l,a0
	lea	(FILE_ARRAY3).l,a2
	bra.b	C1EF7A

C1EF60:
	lea	(DIR_ARRAY2).l,a0
	lea	(FILE_ARRAY2).l,a2
	bra.b	C1EF7A

C1EF6E:
	lea	(DIR_ARRAY).l,a0

	move.l	d0,-(sp)
	moveq.l	#0,d0
	move.b	(CurrentSource-DT,a4),d0
;	mulu.w	#130+2,d0	;DSIZE+2
	lsl.l	#7,d0
	lea	(a0,d0.l),a0
	move.l	(sp)+,d0

	lea	(MenuFileName).l,a2
C1EF7A:
	move.l	(FileReqBase-DT,a4),a1
	move.l	($0010,a1),a1
	lea	(CurrentAsmLine).l,a3
C1EF88:
	tst.b	(a1)
	beq.b	C1EF8E
	move.b	(a1),(a3)+
C1EF8E:
	move.b	(a1)+,(a0)+
;	tst.b	(a1)
	bne.b	C1EF88
	cmp.l	#CurrentAsmLine,a3
	beq.b	C1EFA8
	cmp.b	#$3A,(-1,a3)
	beq.b	C1EFA8
	move.b	#$2F,(a3)+
C1EFA8:
	lea	(FileNaam-DT,a4),a1

C1EFAC:
	move.b	(a1),(a3)+
	move.b	(a1)+,(a2)+
	tst.b	(a1)
	bne.b	C1EFAC
	clr.b	(a2)
	clr.b	(a3)
	br	C1EFBC

C1EFBC:
	tst.l	(FileReqBase-DT,a4)
	beq.b	C1EFCE
	move.l	(FileReqBase-DT,a4),a1
	jsr	(_LVOrtFreeRequest,a6)		; ***
	clr.l	(FileReqBase-DT,a4)
C1EFCE:
	rts

C1EFD0:
	bsr	C1EFBC
	move.l	(sp)+,d0
	moveq	#0,d0
	jmp	(ERROR_Notdone).l

ReqTaglist:
	dc.l	RTSC_Flags,16
	dc.l	$80000029
	dc.w	0
Scrhoog_4:
	dc.w	0

	dc.l	0
	dc.l	1
	dc.l	0

;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	0
;	dc.w	1
;	dc.w	0
;	dc.w	0

ReqSourceExt:
	dc.l	$80000033
	dc.l	SourceExt.MSG
	dc.l	0

ReqPrefsExt:
	dc.l	$80000033
	dc.l	Pref.MSG
	dc.l	0

ReqProjExt:
	dc.l	$80000033
	dc.l	ProjExt.MSG
	dc.l	0

L1F012:
	dc.l	$80000033
	dc.l	W1F01E
	dc.l	0
W1F01E:
	dc.w	0

	even
SourceExt.MSG:
	dc.b	'#?'
req_file_extentie:
;	dcb.b	6,0
	blk.b	18,0

Pref.MSG:	dc.b	'#?.Pref',0
ProjExt.MSG:	dc.b	'#?.Aprj',0

C1F030:
	lea	(Fileallreadye.MSG).l,a1
	lea	(_Overwrite_Le.MSG).l,a2
	move.l	#0,(RequesterType).l
	bra.b	ShowReqtoolsRequester

C1F048:
	lea	(Source.MSG).l,a1
	lea	(_Save_Continu.MSG).l,a2
	move.l	#2,(RequesterType).l
	bra.b	ShowReqtoolsRequester

C1F060:
	lea	(Areyousure.MSG).l,a1
	lea	(_ok_no.MSG).l,a2
	move.l	#2,(RequesterType).l
ShowReqtoolsRequester:
	move.l	(ReqToolsbase-DT,a4),a6
	movem.l	a0-a4,-(sp)
	sub.l	a4,a4
	sub.l	a3,a3
	lea	(L1F188).l,a0
	tst.b	(PR_Safety).l
	bne.b	C1F090
	lea	(L1F1A4).l,a0
C1F090:
	jsr	(_LVOrtEZRequestA,a6)			; ***
	movem.l	(sp)+,a0-a4
	cmp.l	#AsmPro_abouttxt.MSG,a1
	beq	NotInCommandline

	cmp.l	#cs_txt,a1
	beq	NotInCommandline

	cmp.l	#wt_txt,a1
	beq	NotInCommandline

	IF	Debugstuff
	cmp.l	#regstxt,a1
	beq	NotInCommandline
	ENDIF
	
	cmp.l	#_Save_Continu.MSG,a2
	beq.b	C1F0BA
	cmp.l	#1,d0
	beq	NotInCommandline
	jmp	(ERROR_Notdone).l

C1F0BA:
	cmp.l	#1,d0
	beq.b	C1F0D2
	cmp.l	#2,d0
	beq	NotInCommandline
	jmp	(ERROR_Notdone).l

C1F0D2:
	movem.l	d0-d7/a0-a6,-(sp)
	move.b	(B30174-DT,a4),d0
	jsr	(C2BAE).l
	jsr	(C188B2).l
	movem.l	(sp)+,d0-d7/a0-a6
	moveq	#"Y",d0
	rts

NotInCommandline:
	moveq	#"Y",d0
	rts

C1F13A:
	move.l	(ReqToolsbase-DT,a4),a6
	movem.l	a0-a4,-(sp)
	lea	(AbouttoexitAS.MSG).l,a1
	lea	(_Yes_Restart_.MSG).l,a2
	sub.l	a4,a4
	sub.l	a3,a3
	lea	(L1F188).l,a0
	tst.b	(PR_Safety).l
	bne.b	C1F166
	lea	(L1F1A4).l,a0
C1F166:
	jsr	(_LVOrtEZRequestA,a6)		; ***
	movem.l	(sp)+,a0-a4
	cmp.l	#1,d0
	beq	C1F99E
	cmp.l	#2,d0
	beq	C1F9A2
	jmp	(ERROR_Notdone).l

L1F188:
	dc.l	$8000000B
	dc.l	$0000005F
	dc.l	$80000014
	dc.l	AsmProV128req.MSG
	dc.l	$80000016
	dc.l	1
	dc.l	0
L1F1A4:
	dc.l	$8000000B
	dc.l	$0000005F
	dc.l	$80000014
	dc.l	AsmProV128req.MSG
	dc.l	$80000017
RequesterType:
	dc.l	2
	dc.l	0
	dc.b	0
AsmProV128req.MSG:
	dc.b	'Asm-Pro '
	version
;	dc.b	'V1.01'
	dc.b	' request',0
AbouttoexitAS.MSG:
	dc.b	'About to exit Asm-Pro !',$A		; ***
Areyousure.MSG:
	dc.b	'    Are you sure ?',0			; ***
Fileallreadye.MSG:
	dc.b	'File already exists !',$A		; ***
	dc.b	'    Are you sure ?',0			; ***
Source.MSG:
	dc.b	'Source '
B1F237: dc.b	'0 » '			; ***
B1F23B:
	dcb.b	$0000001F,0
	dc.b	10
	dc.b	'not saved yet !',$A
	dc.b	'All changes will be lost, are you sure ?',0
_Yes_Restart_.MSG:	dc.b	'_Yes|_Restart|_No',0
_Save_Continu.MSG:	dc.b	'_Save|_Continue|_Abort',0
_Overwrite_Le.MSG:	dc.b	'_Overwrite|_Leave',0
_Ok_Ok.MSG:		dc.b	'_Ok|_Ok',0
_ok_no.MSG:		dc.b	'_Yes|_No',0
AsmPro_abouttxt.MSG:
bt:	dc.b	'           Asm-Pro OpenSource Edition '
	version
;	dc.b	'V1.01'
	dc.b	subversion
	dc.b	$A,$A

	dc.b    ' MC680x0/MC6888x/MC68851 Macro Assembler (KS 2.x/3.x)',$A,$A
	dc.b    '          Coding by Solo/Genetic (1995-2000)',$a
	dc.b    '          Original code by Rune Gram-Madsen.',$a
	dc.b	'     Check the history file for some more credits!',$a
	dc.b	$a
	dc.b	'               > '
	%getdate
	dc.b	" ("
	%gettime
	dc.b	') <',$a,$a
	dc.b	'              Asm-Pro is now OpenSource.',$a
	dc.b	'     try: "http://surf.to/asmpro" for more info.',$a
	dc.b	'For questions send a message to Asmpro_dev@yahoogroups.com',$a,$a
	dc.b	'   Dutch coders drink Grolsch beer! YOU should TOO!',$a
	dc.b	0
		
Newsourcenona.MSG:
	dc.b	'New source, specify new name',0
Noprojectstar.MSG:
	dc.b	'No project started',0,0
	dcb.b	12,0
Nosource.MSG:
	dc.b	'No source',0,0
	dcb.b	$00000015,0
AsmProProject.MSG:
	dc.b	'Asm-Pro Project : '
Source0.MSG:
	dc.b	'                                ',$A,$A
	dc.b	'Source #0 : '
SizeSource1Si.MSG:
	dc.b	'                               Size      :         ',$A
	dc.b	'Source #1 :                                Size      :         ',$A
	dc.b	'Source #2 :                                Size      :         ',$A
	dc.b	'Source #3 :                                Size      :         ',$A
	dc.b	'Source #4 :                                Size      :         ',$A
	dc.b	'Source #5 :                                Size      :         ',$A
	dc.b	'Source #6 :                                Size      :         ',$A
	dc.b	'Source #7 :                                Size      :         ',$A
	dc.b	'Source #8 :                                Size      :         ',$A
	dc.b	'Source #9 :                                Size      :         ',$A,0


	CNOP	0,4	

C1F99E:
	moveq	#$59,d0
	rts

C1F9A2:
	moveq	#$52,d0
	rts


Change2Editmenu:
	move.l	d0,-(sp)
	move.l	(Edit_Menubase-DT,a4),d0
	move.b	#MT_EDITOR,(menu_tiepe-DT,a4)
	jsr	(Change_2menu_d0).l
	move.l	(sp)+,d0
	rts

Change2Debugmenu:
	move.l	d0,-(sp)
	move.l	(Debug_MenuBase-DT,a4),d0
	move.b	#MT_DEBUGGER,(menu_tiepe-DT,a4)
	bsr	Change_2menu_d0
	move.l	(sp)+,d0
	jmp	(C1AB66).l

Change2Monitormenu:
	move.l	d0,-(sp)
	move.l	(Monitor_MenuBase-DT,a4),d0
	move.b	#MT_MONITOR,(menu_tiepe-DT,a4)
	jsr	(Change_2menu_d0).l
	move.l	(sp)+,d0
	rts

Init_menustructure:
	movem.l	d1-a6,-(sp)			; ***
	move.l	d0,a0
	lea	(newmenu_taglist).l,a1
	move.l	(GadToolsBase-DT,a4),a6
	jsr	(_LVOCreateMenusA,a6)		; ***
	move.l	d0,(MenuStrip).l
	tst.l	d0
	beq	.nomenu
	move.l	d0,a0
	move.l	(MainVisualInfo-DT,a4),a1
	lea	(firstmenu_taglist).l,a2

	cmp.w	#1,(Scr_NrPlanes-DT,a4)
	bne.b	.ddd
	sub.l	a2,a2
.ddd
	move.l	(GadToolsBase-DT,a4),a6
	jsr	(_LVOLayoutMenusA,a6)		; ***
	move.l	(MenuStrip).l,d0
.nomenu:
	movem.l	(sp)+,d1-a6			; ***
	rts

Breakdown_menu:
	move.l	(MainWindowHandle).l,a0
	move.l	d0,-(sp)
	move.l	(IntBase-DT,a4),a6
	jsr	(_LVOClearMenuStrip,a6)
	move.l	(sp)+,a0
	move.l	(GadToolsBase-DT,a4),a6
	jsr	(_LVOFreeMenus,a6)		;***
	move.l	#0,(MenuStrip).l
	rts

Change_2menu_d0:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	d0,-(sp)
	move.l	(MainWindowHandle).l,a0
	move.l	(IntBase-DT,a4),a6
	jsr	(_LVOClearMenuStrip,a6)
	move.l	(MainWindowHandle).l,a0
	move.l	(sp)+,a1
	move.l	a1,(MenuStrip).l
	move.l	(IntBase-DT,a4),a6
	jsr	(_LVOSetMenuStrip,a6)
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;MainVisualInfo:	dc.l	0
MenuStrip:	dc.l	0
newmenu_taglist:
		dc.l	0
firstmenu_taglist:
		dc.l	GTMN_NewLookMenus
		dc.l	1
		dc.l	0

;********** COMMAND MENU **************

command_menus:
	dc.w	$0100
	dc.l	Project.MSG0
	dcb.w	7,0
	dc.w	$0200
	dc.l	ProjectinfoP.MSG
	dcb.w	5,0
	dc.w	$3D50
	dc.w	$FFFF
	dc.w	$0200
	dc.l	ZapSourceZS.MSG
	dcb.w	5,0
	dc.w	$5A53
	dc.w	$FFFF
	dc.w	$0200
	dc.l	OldO.MSG
	dcb.w	5,0
	dc.w	$4F00
	dc.w	$FFFF
	dc.w	$0200

	dc.l	Read.MSG
	dcb.w	7,0
	dc.w	$0300

	dc.l	EnviornmentRE.MSG
	dcb.w	5,0
	dc.w	$5245
	dc.w	$FFFF
	dc.w	$0300

	dc.l	SourceR.MSG
	dcb.w	5,0
	dc.w	$5200
	dc.w	$FFFF
	dc.w	$0300

	dc.l	SourceRN.MSG
	dcb.w	5,0
	dc.w	"RN"
	dc.w	$FFFF
	dc.w	$0300

	dc.l	BinaryRB.MSG
	dcb.w	5,0
	dc.w	$5242
	dc.w	$FFFF
	dc.w	$0300

	dc.l	ObjectRO.MSG
	dcb.w	5,0
	dc.w	$524F
	dc.w	$FFFF
	dc.w	$0200

	dc.l	Write.MSG
	dcb.w	7,0
	dc.w	$0300
	dc.l	EnviornmentWE.MSG
	dcb.w	5,0
	dc.w	$5745
	dc.w	$FFFF
	dc.w	$0300

	dc.l	SourceW.MSG
	dcb.w	5,0
	dc.w	$5700
	dc.w	$FFFF
	dc.w	$0300

	dc.l	SourceWN.MSG
	dcb.w	5,0
	dc.w	"WN"
	dc.w	$FFFF
	dc.w	$0300

	dc.l	BinaryWB.MSG
	dcb.w	5,0
	dc.w	$5742
	dc.w	$FFFF
	dc.w	$0300
	dc.l	ObjectWO.MSG
	dcb.w	5,0
	dc.w	$574F
	dc.w	$FFFF
	dc.w	$0300
	dc.l	LinkWL.MSG
	dcb.w	5,0
	dc.w	$574C
	dc.w	$FFFF
	dc.w	$0300
	dc.l	PreferencesWP.MSG
	dcb.w	5,0
	dc.w	$5750
	dc.w	$FFFF
	dc.w	$0200
	dc.l	InsertI.MSG
	dcb.w	5,0
	dc.w	$4900
	dc.w	$FFFF

	dc.w	$0200
	dc.l	Update.MSG
	dcb.w	7,0

	dc.w	$0300
	dc.l	UpdateSourceU.MSG
	dc.l	w.MSG
	dcb.w	3,0
;	dcb.w	5,0
	dc.w	$5500
	dc.w	$FFFF

	dc.w	$0300
	dc.l	UpdateProject.MSG
	dcb.w	5,0
	dc.w	"UA"
	dc.w	$FFFF
	dc.w	$0200
	dc.l	ZapFileZF.MSG
	dcb.w	5,0
	dc.w	"ZF"
	dc.w	$FFFF
	dc.w	$0200
	dc.l	ZapIncMemZI.MSG
	dcb.w	5,0
	dc.w	"ZI"
	dc.w	$FFFF

	dc.w	$0200			
	dc.l	-1			
	dcb.w	7,0			

	dc.w	$0200			
	dc.l	RecentFiles.MSG	
	dcb.w	7,0		

MenuRecent			
MENUSTRPOS	SET	0			
	REPT	10				
		dc.b	NM_IGNORE		
		dc.b	0			
		dc.l	Recent.MSG+(MENUSTRPOS*146)
		dcb.w	5,0		
		dc.b	"R"		
		dc.b	MENUSTRPOS+"0"	
		dc.w	$FFFF		
MENUSTRPOS	SET	MENUSTRPOS+1	
	ENDR

	dc.w	$0200
	dc.l	-1
	dcb.w	7,0

	dc.w	$0200
	dc.l	AddWorkMemM.MSG
	dcb.w	5,0
	dc.w	"=M"
	dc.w	$FFFF

	dc.w	$0200
	dcb.w	2,$FFFF
	dcb.w	7,0

	dc.w	$0200
	dc.l	About.MSG
	dcb.w	5,0
	dc.w	"#"<<(1*8)
	dc.w	$FFFF
	dc.w	$0200
	dcb.w	2,$FFFF
	dcb.w	7,0

	dc.w	$0200
	dc.l	Quit.MSG
	dcb.w	5,0
	dc.w	$2100
	dc.w	$FFFF

	dc.w	$0200
	dc.l	Restarting.MSG
	dcb.w	5,0
	dc.w	"!R"
	dc.w	$FFFF

	dc.w	$0200
	dc.l	QuickQuit.MSG
	dcb.w	5,0
	dc.w	"!!"
	dc.w	$FFFF

	dc.w	$0100
	dc.l	Assembler.MSG0
	dcb.w	7,0
	dc.w	$0200
	dc.l	Assemble.MSG
	dcb.w	7,0
	dc.w	$0300
	dc.l	Assemble.MSG0
	dc.l	A.MSG0
	dcb.w	3,0
	dc.w	$002D
	dc.w	$FFFF
	dc.w	$0300
	dc.l	Optimize.MSG
	dc.l	O.MSG0
	dcb.w	3,0
	dc.w	$003B
	dc.w	$FFFF
	dc.w	$0300

	dc.l	Checkonly.MSG
	dcb.w	5,0
	dc.w	$4143
	dc.w	$FFFF
	dc.w	$0300

	dc.l	Objectinfo.MSG
	dcb.w	5,0
	dc.w	$3D00
	dc.w	$FFFF
	dc.w	$0200

	dcb.w	2,$FFFF
	dcb.w	7,0
	dc.w	$0200
;;
	dc.l	Editor.MSG0
	dc.l	E.MSG
	dcb.w	3,0
	dc.w	$0031
	dc.w	$FFFF

	dc.w	$0200
	dc.l	Debugger.MSG
	dc.l	D.MSG0
	dcb.w	3,0
	dc.w	$0030
	dc.w	$FFFF
	dc.w	$0200
	dc.l	Monitor.MSG
	dc.l	M.MSG
	dcb.w	3,0
	dc.w	$0039
	dc.w	$FFFF
	dc.w	$0200
;;pw
	IF	useplugins
	dc.l	PluginWin.MSG
	dcb.w	5,0
	dc.w	"PW"
	dc.w	$FFFF
	dc.w	$0200
	ENDIF

	dc.l	Preferences.MSG
	dcb.w	7,0
	dc.w	$0300

	dc.l	Environment.MSG
	dc.l	ascii.MSG17
	dcb.w	3,0
	dc.w	9
	dc.w	$FFFF
	dc.w	$0300

	dc.l	Assembler.MSG1
	dc.l	ascii.MSG18
	dcb.w	3,0
	dc.w	12
	dc.w	$FFFF
	dc.w	$0300

	dc.l	Syntaxpr.MSG
	dc.l	SyntaxprChar.MSG
	dcb.w	3,0
	dc.w	70
	dc.w	$FFFF
	dc.w	$0300
;;=c
	dc.l	colors.MSG1
	dcb.w	5,0
	dc.w	"=C"
	dc.w	$FFFF
	dc.w	$0200

	dcb.w	2,$FFFF
	dcb.w	7,0
	dc.w	$0200

	dc.l	Agaguide.MSG
	dc.l	0	;ascii.MSG19
	dcb.w	3,0
	dc.w	$0065
	
	dc.w	$FFFF
	dc.w	$0100
	dc.l	Commands.MSG
	dcb.w	7,0
	dc.w	$0200
	dc.l	Editor.MSG1
	dcb.w	7,0
	dc.w	$0300
	dc.l	JumpTopT.MSG
	dcb.w	5,0
	dc.w	$5400
	dc.w	$FFFF
	dc.w	$0300
	dc.l	JumpBottomB.MSG
	dcb.w	5,0
	dc.w	$4200
	dc.w	$FFFF
	dc.w	$0300
	dc.l	SearchL.MSG
	dcb.w	5,0
	dc.w	$4C00
	dc.w	$FFFF
	dc.w	$0300
	dc.l	ZapLinesZL.MSG
	dcb.w	5,0
	dc.w	$5A4C
	dc.w	$FFFF
	dc.w	$0300
	dc.l	PrintLinesP.MSG
	dcb.w	5,0
	dc.w	$5000
	dc.w	$FFFF
	dc.w	$0300

	dc.l	ExtendLabelsE.MSG
	dcb.w	5,0
	dc.w	$454C
	dc.w	$FFFF
	dc.w	$0200

	dc.l	Memory.MSG
	dcb.w	7,0
	dc.w	$0300

	dc.l	EditM.MSG
	dcb.w	5,0
	dc.w	$4D00
	dc.w	$FFFF
	dc.w	$0300

	dc.l	DisassembleD.MSG
	dcb.w	5,0
	dc.w	$4400
	dc.w	$FFFF
	dc.w	$0300

	dc.l	HexDumpH.MSG
	dcb.w	5,0
	dc.w	$4800
	dc.w	$FFFF
	dc.w	$0300

	dc.l	ASCIIN.MSG
	dcb.w	5,0
	dc.w	$4E00
	dc.w	$FFFF
	dc.w	$0300

	dc.l	BINDUMP.MSG
	dcb.w	5,0
	dc.w	"BM"
	dc.w	$FFFF
	dc.w	$0300

	dcb.w	2,$FFFF
	dcb.w	7,0
	dc.w	$0300

	dc.l	DisLineD.MSG
	dcb.w	5,0
	dc.w	$4044
	dc.w	$FFFF
	dc.w	$0300
	dc.l	AssembleA.MSG
	dcb.w	5,0
	dc.w	$4041
	dc.w	$FFFF
	dc.w	$0300
	dc.l	HexLineH.MSG
	dcb.w	5,0
	dc.w	$4048
	dc.w	$FFFF
	dc.w	$0300
	dc.l	ASCIILineN.MSG
	dcb.w	5,0
	dc.w	$404E
	dc.w	$FFFF
	dc.w	$0300
	dc.l	BinLineB.MSG
	dcb.w	5,0
	dc.w	$4042
	dc.w	$FFFF
	dc.w	$0300
	dcb.w	2,$FFFF
	dcb.w	7,0
	dc.w	$0300
	dc.l	SearchMemoryS.MSG
	dcb.w	5,0
	dc.w	$5300
	dc.w	$FFFF
	dc.w	$0300
	dc.l	FillMemoryF.MSG
	dcb.w	5,0
	dc.w	$4600
	dc.w	$FFFF
	dc.w	$0300
	dc.l	CopyMemoryC.MSG
	dcb.w	5,0
	dc.w	$4300
	dc.w	$FFFF
	dc.w	$0300
	dc.l	CompareMemory.MSG
	dcb.w	5,0
	dc.w	$5100
	dc.w	$FFFF
	dc.w	$0300
	dc.l	CreateSinusCS.MSG
	dcb.w	5,0
	dc.w	$4353
	dc.w	$FFFF
	dc.w	$0200
	dc.l	Insert.MSG
	dcb.w	7,0
	dc.w	$0300
	dc.l	DisAssemblyID.MSG
	dcb.w	5,0
	dc.w	$4944
	dc.w	$FFFF
	dc.w	$0300
	dc.l	HEXDumpIH.MSG
	dcb.w	5,0
	dc.w	$4948
	dc.w	$FFFF
	dc.w	$0300
	dc.l	ASCIIDumpIN.MSG
	dcb.w	5,0
	dc.w	$494E
	dc.w	$FFFF
	dc.w	$0300
	dc.l	BinaryDumpIB.MSG
	dcb.w	5,0
	dc.w	$4942
	dc.w	$FFFF
	dc.w	$0300
	dc.l	CreateSinusIS.MSG
	dcb.w	5,0
	dc.w	$4953
	dc.w	$FFFF
	dc.w	$0200
	dc.l	Assemble.MSG1
	dcb.w	7,0
	dc.w	$0300
	dc.l	AssembleA.MSG0
	dcb.w	5,0
	dc.w	$4100
	dc.w	$FFFF
	dc.w	$0300
	dc.l	MemoryA.MSG
	dcb.w	5,0
	dc.w	$4041
	dc.w	$FFFF
	dc.w	$0300
	dc.l	OptimizeAO.MSG
	dcb.w	5,0
	dc.w	$414F
	dc.w	$FFFF
	dc.w	$0300
	dc.l	DebugAD.MSG
	dcb.w	5,0
	dc.w	$4144
	dc.w	$FFFF
	dc.w	$0300
	dc.l	SymbolsS.MSG
	dcb.w	5,0
	dc.w	$3D53
	dc.w	$FFFF
	dc.w	$0300
	dc.l	ParametersSet.MSG
	dcb.w	5,0
	dc.w	$5053
	dc.w	$FFFF
	dc.w	$0200
	dc.l	Monitor.MSG0
	dcb.w	7,0
	dc.w	$0300
	dc.l	JumpJ.MSG
	dcb.w	5,0
	dc.w	$4A00
	dc.w	$FFFF
	dc.w	$0300
	dc.l	GoG.MSG
	dcb.w	5,0
	dc.w	$4700
	dc.w	$FFFF
	dc.w	$0300
	dc.l	StepK.MSG
	dcb.w	5,0
	dc.w	$4B00
	dc.w	$FFFF
	dc.w	$0300
	dc.l	StatusX.MSG
	dcb.w	5,0
	dc.w	$5800
	dc.w	$FFFF
	dc.w	$0300
	dc.l	ZapBPSZB.MSG
	dcb.w	5,0
	dc.w	$5A42
	dc.w	$FFFF
	dc.w	$0200
	dc.l	Disk.MSG
	dcb.w	7,0
	dc.w	$0300
	dc.l	ReadSectorRS.MSG
	dcb.w	5,0
	dc.w	$5253
	dc.w	$FFFF
	dc.w	$0300
	dc.l	ReadTrackRT.MSG
	dcb.w	5,0
	dc.w	$5254
	dc.w	$FFFF
	dc.w	$0300
	dcb.w	2,$FFFF
	dcb.w	7,0
	dc.w	$0300
	dc.l	WriteSectorWS.MSG
	dcb.w	5,0
	dc.w	$5753
	dc.w	$FFFF
	dc.w	$0300
	dc.l	WriteTrackWT.MSG
	dcb.w	5,0
	dc.w	$5754
	dc.w	$FFFF
	dc.w	$0300

	dcb.w	2,$FFFF
	dcb.w	7,0
	dc.w	$0300

	dc.l	CalcCheckCC.MSG
	dcb.w	5,0
	dc.w	"CC"
	dc.w	$FFFF
	dc.w	$0300

	dc.l	BBSimul.MSG				
	dcb.w	5,0					
	dc.w	"BS"					
	dc.w	$FFFF					
	dc.w	$0200					

	dcb.w	2,$FFFF
	dcb.w	7,0
	dc.w	$0200
	dc.l	ExternE.MSG
	dcb.w	5,0
	dc.w	$4500
	dc.w	$FFFF
	dc.w	$0200
	dc.l	Output.MSG
	dcb.w	5,0
	dc.w	$3E00
	dc.w	$FFFF
	dc.w	$0200
	dc.l	Calculate.MSG
	dcb.w	5,0
	dc.w	$3F00
	dc.w	$FFFF
	dc.w	$0200
	dc.l	Calculatefloa.MSG
	dcb.w	5,0
	dc.w	$5B00
	dc.w	$FFFF
	dc.w	$0200
	dc.l	CustomRegiste.MSG
	dcb.w	5,0
	dc.w	$3D52
	dc.w	$FFFF
	dcb.w	10,0

;********* editor menu's *************8
Editor_menus:
	dc.w	$0100
	dc.l	Assembler.MSG0
	dcb.w	7,0

	dc.w	$0200
	dc.l	Assemble.MSG
	dcb.w	7,0

	dc.w	$0300
	dc.l	Assemble.MSG0
	dc.l	A.MSG0
	dcb.w	3,0
	dc.w	45
	dc.w	$FFFF
	
	dc.w	$0300
	dc.l	Optimize.MSG
	dc.l	O.MSG0
	dcb.w	3,0
	dc.w	$003B
	dc.w	$FFFF
	dc.w	$0200
	
	dcb.w	2,$FFFF
	dcb.w	7,0
	dc.w	$0200
	
	dc.l	Editor.MSG0
	dc.l	0
	dcb.w	3,0
	dc.w	$0031
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	Debugger.MSG
	dc.l	D.MSG0
	dcb.w	3,0
	dc.w	$0030
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	Monitor.MSG
	dc.l	M.MSG
	dcb.w	3,0
	dc.w	$0039
	dc.w	$FFFF
	dc.w	$0200

;;pw
	IF	useplugins
	dc.l	PluginWin.MSG
	dc.l	0		;PW.MSG
	dcb.w	3,0
	dc.w	60		;amiga-P = 60
	dc.w	$FFFF
	dc.w	$0200
	endif


	dc.l	Preferences.MSG
	dcb.w	7,0
	dc.w	$0300
	
	dc.l	Environment.MSG
	dc.l	ascii.MSG17
	dcb.w	3,0
	dc.w	9
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	Assembler.MSG1
	dc.l	ascii.MSG18
	dcb.w	3,0
	dc.w	12
	dc.w	$FFFF
	dc.w	$0300

	dc.l	Syntaxpr.MSG
	dc.l	SyntaxprChar.MSG
	dcb.w	3,0
	dc.w	70
	dc.w	$FFFF
	dc.w	$0200

;	dc.l	colors.MSG1
;	dcb.w	5,0
;	dc.w	"=C"
;	dc.w	$FFFF
;	dc.w	$0200
	
	dcb.w	2,$FFFF
	dcb.w	7,0
	dc.w	$0200

	dc.l	Agaguide.MSG
	dc.l	0		;ascii.MSG19
	dcb.w	3,0
	dc.w	$0065
	dc.w	$FFFF
	dc.w	$0100
	
	dc.l	Edit.MSG0
	dcb.w	7,0

	dc.w	$0200
	dc.l	UpdateSourceU.MSG
	dc.l	w.MSG
	dcb.w	3,0
	dc.w	41		;amiga-w
	dc.w	$FFFF

	dc.w	$0200
	dc.l	Block.MSG
	dcb.w	7,0
	dc.w	$0300
	
	dc.l	Mark.MSG
	dc.l	b.MSG
	dcb.w	3,0
	dc.w	$0014
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	Copy.MSG
	dc.l	c.MSG
	dcb.w	3,0
	dc.w	$0015
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	Cut.MSG
	dc.l	x.MSG
	dcb.w	3,0
	dc.w	$002A
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	Insert.MSG0
	dc.l	v.MSG
	dcb.w	3,0
	dc.w	40	;$1B		;Amiga-i -> Amiga-v
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	Insert.MSG
	dc.l	i.MSG			;Amiga-f -> Amiga-i
	dcb.w	3,0
;	dc.w	$0018
	dc.w	40
	dc.w	$FFFF
	dc.w	$0300

	dc.l	Fill.MSG
	dc.l	f.MSG
	dcb.w	3,0
;	dc.w	$0018
	dc.w	27
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	UnMark.MSG
	dc.l	W232AC
	dcb.w	3,0
	dc.w	$0027
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	Lowercase.MSG
	dc.l	l.MSG
	dcb.w	3,0
	dc.w	$001E
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	Uppercase.MSG
	dc.l	L.MSG0
	dcb.w	3,0
	dc.w	$0038
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	Rotate.MSG
	dc.l	y.MSG
	dcb.w	3,0
	dc.w	$002B
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	Register.MSG
	dc.l	k.MSG
	dcb.w	3,0
	dc.w	$001D		;29
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	Write.MSG0
	dc.l	W.MSG
	dcb.w	3,0
	dc.w	67		;was 41
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	VerticalFill.MSG
	dc.l	n.MSG
	dcb.w	3,0
	dc.w	$0020
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	Comment.MSG0
	dc.l	ascii.MSG20
	dcb.w	3,0
	dc.w	$0011
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	Uncomment.MSG
	dc.l	ascii.MSG21
	dcb.w	3,0
	dc.w	$0012
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	Tabulate.MSG		; tabulate block 
	dc.l	Tabulate.Shc				
	dcb.w	3,0					
	dc.w	34					
	dc.w	$FFFF					
	dc.w	$0300					

	dc.l	SelectAll.MSG		; select all	
	dc.l	SelectAll.Shc				
	dcb.w	3,0					
	dc.w	35					
	dc.w	$FFFF					
	dc.w	$0300					

	dc.l	SpaceToTab.MSG		; spaces to tabs block 
	dc.l	SpaceToTab.Shc				
	dcb.w	3,0					
	dc.w	55					
	dc.w	$FFFF					
	dc.w	$0200					
	
	dc.l	Search.MSG1
	dcb.w	7,0
	dc.w	$0300
	
	dc.l	Search.MSG1
	dc.l	S.MSG0
	dcb.w	3,0
	dc.w	$003F
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	Forward.MSG
	dc.l	W2330A
	dcb.w	3,0
	dc.w	$0025
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	Replace.MSG
	dcb.w	7,0
	dc.w	$0300
	
	dc.l	Replace.MSG0
	dc.l	R.MSG
	dcb.w	3,0
	dc.w	$003E
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	Forward.MSG0
	dc.l	C23326
	dcb.w	3,0
	dc.w	$0024
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	DeleteLine.MSG
	dc.l	d.MSG
	dcb.w	3,0
	dc.w	$0016
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	SetMarks.MSG
	dcb.w	7,0
	dc.w	$0300
	
	dc.l	Mark1.MSG
	dc.l	ascii.MSG22
	dcb.w	3,0
	dc.w	$004F
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	Mark2.MSG
	dc.l	ascii.MSG23
	dcb.w	3,0
	dc.w	$0050
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	Mark3.MSG
	dc.l	ascii.MSG24
	dcb.w	3,0
	dc.w	$0051
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	Mark4.MSG
	dc.l	ascii.MSG25
	dcb.w	3,0
	dc.w	$0056
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	Mark5.MSG
	dc.l	ascii.MSG26
	dcb.w	3,0
	dc.w	$0057
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	Mark6.MSG
	dc.l	ascii.MSG27
	dcb.w	3,0
	dc.w	$0064
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	Mark7.MSG
	dc.l	ascii.MSG28
	dcb.w	3,0
	dc.w	$0059
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	Mark8.MSG
	dc.l	ascii.MSG29
	dcb.w	3,0
	dc.w	$005A
	dc.w	$FFFF
	dc.w	$0300
	dc.l	Mark9.MSG
	dc.l	ascii.MSG30
	dcb.w	3,0
	dc.w	$005B
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	Mark10.MSG
	dc.l	ascii.MSG31
	dcb.w	3,0
	dc.w	$005C
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	JumpMarks.MSG
	dcb.w	7,0
	dc.w	$0300
	
	dc.l	Jump1.MSG
	dc.l	ascii.MSG32
	dcb.w	3,0
	dc.w	$0047
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	Jump2.MSG
	dc.l	ascii.MSG33
	dcb.w	3,0
	dc.w	$0048
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	Jump3.MSG
	dc.l	ascii.MSG34
	dcb.w	3,0
	dc.w	$0049
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	Jump4.MSG
	dc.l	ascii.MSG35
	dcb.w	3,0
	dc.w	$005D
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	Jump5.MSG
	dc.l	ascii.MSG36
	dcb.w	3,0
	dc.w	$005E
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	Jump6.MSG
	dc.l	ascii.MSG37
	dcb.w	3,0
	dc.w	$005F
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	Jump7.MSG
	dc.l	ascii.MSG38
	dcb.w	3,0
	dc.w	$0060
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	Jump8.MSG
	dc.l	ascii.MSG39
	dcb.w	3,0
	dc.w	$0061
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	Jump9.MSG
	dc.l	ascii.MSG40
	dcb.w	3,0
	dc.w	$0062
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	Jump10.MSG
	dc.l	ascii.MSG41
	dcb.w	3,0
	dc.w	$0063
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	Jump.MSG
	dc.l	J.MSG
	dcb.w	3,0
	dc.w	$0036
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	JumpLine.MSG
	dc.l	j.MSG
	dcb.w	3,0
	dc.w	$001C
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	Move.MSG
	dcb.w	7,0
	dc.w	$0300
	
	dc.l	BeginofLinesh.MSG
	dcb.w	5,0
	dc.w	6
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	EndofLinerigh.MSG
	dcb.w	5,0
	dc.w	7
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	PageUpup.MSG
	dcb.w	5,0
	dc.w	5
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	PageDowndown.MSG
	dcb.w	5,0
	dc.w	8
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	Up100.MSG
	dc.l	a.MSG
	dcb.w	3,0
	dc.w	$0013
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	Down100.MSG
	dc.l	z.MSG
	dcb.w	3,0
	dc.w	$002C
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	Top.MSG
	dc.l	W234A0
	dcb.w	3,0
	dc.w	$0026
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	Bottom.MSG
	dc.l	T.MSG
	dcb.w	3,0
	dc.w	$0040
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	LeftWordaltle.MSG
	dcb.w	5,0
	dc.w	10
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	RightWordaltr.MSG
	dcb.w	5,0
	dc.w	11
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	MakeMacro.MSG
	dc.l	ascii.MSG42
	dcb.w	3,0
	dc.w	$0053
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	DoMacro.MSG
	dc.l	m.MSG
	dcb.w	3,0
	dc.w	$001F
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	GrabWord.MSG
	dc.l	g.MSG
	dcb.w	3,0
	dc.w	$0019
	dc.w	$FFFF
	dc.w	$0200

	dc.l	Nr2Ascii.MSG
	dc.l	h.MSG
	dcb.w	3,0
	dc.w	$001a
	dc.w	$FFFF
	dc.w	$0200
;;	
	dc.l	Exitesc.MSG
	dc.l	E.MSG
	dcb.w	3,0
	dc.w	$1B00
	dc.w	$FFFF
	
	dc.w	$0100
	dc.l	Sources.MSG
	dcb.w	7,0
	dc.w	$0200
	
	dc.l	F1.MSG
	dcb.w	5,0
	dc.w	$0067
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	F2.MSG
	dcb.w	5,0
	dc.w	$0068
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	F3.MSG
	dcb.w	5,0
	dc.w	$0069
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	F4.MSG
	dcb.w	5,0
	dc.w	$006A
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	F5.MSG
	dcb.w	5,0
	dc.w	$006B
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	F6.MSG
	dcb.w	5,0
	dc.w	$006C
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	F7.MSG
	dcb.w	5,0
	dc.w	$006D
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	F8.MSG
	dcb.w	5,0
	dc.w	$006E
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	F9.MSG
	dcb.w	5,0
	dc.w	$006F
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	F10.MSG
	dcb.w	5,0
	dc.w	$0070
	dc.w	$FFFF
	dcb.w	10,0

;********** monitor menus ************

monitor_menus:
	dc.w	$0100
	dc.l	Assembler.MSG0
	dcb.w	7,0
	dc.w	$0200
	
	dc.l	Assemble.MSG
	dcb.w	7,0
	dc.w	$0300
	
	dc.l	Assemble.MSG0
	dc.l	A.MSG0
	dcb.w	3,0
	dc.w	$002D
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	Optimize.MSG
	dc.l	O.MSG0
	dcb.w	3,0
	dc.w	$003B
	dc.w	$FFFF
	dc.w	$0200
	
	dcb.w	2,$FFFF
	dcb.w	7,0
	dc.w	$0200
	
	dc.l	Editor.MSG0
	dc.l	E.MSG
	dcb.w	3,0
	dc.w	$0031
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	Debugger.MSG
	dc.l	D.MSG0
	dcb.w	3,0
	dc.w	$0030
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	Monitor.MSG
	dc.l	M.MSG
	dcb.w	3,0
	dc.w	$0039
	dc.w	$FFFF
	dc.w	$0200
	
;;pw
;	dc.l	PluginWin.MSG
;	dc.l	PW.MSG
;	dcb.w	3,0
;	dc.w	60		;amiga-P = 60
;	dc.w	$FFFF
;	dc.w	$0200
;;

	dc.l	Preferences.MSG
	dcb.w	7,0
	dc.w	$0300
	
	dc.l	Environment.MSG
	dc.l	ascii.MSG17
	dcb.w	3,0
	dc.w	9
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	Assembler.MSG1
	dc.l	ascii.MSG18
	dcb.w	3,0
	dc.w	12
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	Syntaxpr.MSG
	dc.l	SyntaxprChar.MSG
	dcb.w	3,0
	dc.w	70
	dc.w	$FFFF
	dc.w	$0200

	dc.l	Agaguide.MSG
	dc.l	0		;ascii.MSG19
	dcb.w	3,0
	dc.w	$0065
	dc.w	$FFFF
	dc.w	$0100
	
	dc.l	Monitor.MSG1
	dcb.w	7,0
	dc.w	$0200
	
	dc.l	Disassemble.MSG
	dc.l	d.MSG0
	dcb.w	3,0
	dc.w	$0016
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	HexDump.MSG
	dc.l	h.MSG
	dcb.w	3,0
	dc.w	$001A
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	ASCIIDump.MSG
	dc.l	n.MSG0
	dcb.w	3,0
	dc.w	$0020
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	BinDump.MSG
	dc.l	b.MSG0
	dcb.w	3,0
	dc.w	$0021
	dc.w	$FFFF
	dc.w	$0200
	
	dcb.w	2,$FFFF
	dcb.w	7,0
	dc.w	$0200
	
	dc.l	JumpAddress.MSG
	dc.l	j.MSG0
	dcb.w	3,0
	dc.w	$001C
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	LastAddress.MSG
	dc.l	l.MSG0
	dcb.w	3,0
	dc.w	$001E
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	QuickJump.MSG
	dc.l	W23AB4
	dcb.w	3,0
	dc.w	$0023
	dc.w	$FFFF
	dc.w	$0200
	
	dcb.w	2,$FFFF
	dcb.w	7,0
	dc.w	$0200
	
	dc.l	SetMarks.MSG0
	dcb.w	5,0
	dc.w	$FFFF
	dc.w	0
	dc.w	$0300
	
	dc.l	Mark1.MSG0
	dc.l	ascii.MSG22
	dcb.w	3,0
	dc.w	$004F
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	Mark2.MSG0
	dc.l	ascii.MSG23
	dcb.w	3,0
	dc.w	$0050
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	Mark3.MSG0
	dc.l	ascii.MSG24
	dcb.w	3,0
	dc.w	$0051
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	JumpMarks.MSG0
	dcb.w	5,0
	dc.w	$FFFF
	dc.w	0
	dc.w	$0300
	
	dc.l	Jump1.MSG0
	dc.l	ascii.MSG46
	dcb.w	3,0
	dc.w	$0047
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	Jump2.MSG0
	dc.l	ascii.MSG47
	dcb.w	3,0
	dc.w	$0048
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	Jump3.MSG0
	dc.l	ascii.MSG48
	dcb.w	3,0
	dc.w	$0049
	dc.w	$FFFF
	dc.w	$0200
	
	dcb.w	2,$FFFF
	dcb.w	7,0
	dc.w	$0200
	
	dc.l	SetStart.MSG
	dc.l	ascii.MSG49
	dcb.w	3,0
	dc.w	$0053
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	SetEnd.MSG
	dc.l	ascii.MSG50
	dcb.w	3,0
	dc.w	$0054
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	SaveBin.MSG
	dc.l	w.MSG
	dcb.w	3,0
	dc.w	$0055
	dc.w	$FFFF
	dc.w	$0200

	dcb.w	2,$FFFF
	dcb.w	7,0
	dc.w	$0200

	IF MEMSEARCH
	dc.l	Search.MSG
	dc.l	s.MSG0
	dcb.w	3,0
	dc.w	$0056
	dc.w	$FFFF
	dc.w	$0200

	dc.l	Forward.MSG
	dc.l	f.MSG
	dcb.w	3,0
	dc.w	$0057
	dc.w	$FFFF
	dc.w	$0200
	ENDIF
	
	dcb.w	2,$FFFF
	dcb.w	7,0
	
	dc.w	$0200
	dc.l	Exitesc.MSG0
	dcb.w	5,0
	dc.w	$1B00
	dc.w	$FFFF
	dcb.w	10,0

;************ debugger menus **************

debug_menus:
	dc.w	$0100
	dc.l	Assembler.MSG0
	dcb.w	7,0
	dc.w	$0200
	
	dc.l	Assemble.MSG
	dcb.w	7,0
	dc.w	$0300
	
	dc.l	Assemble.MSG0
	dc.l	A.MSG0
	dcb.w	3,0
	dc.w	$002D
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	Optimize.MSG
	dc.l	O.MSG0
	dcb.w	3,0
	dc.w	$003B
	dc.w	$FFFF
	dc.w	$0200
	
	dcb.w	2,$FFFF
	dcb.w	7,0
	dc.w	$0200
	
	dc.l	Editor.MSG0
	dc.l	E.MSG
	dcb.w	3,0
	dc.w	$0031
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	Debugger.MSG
	dc.l	D.MSG0
	dcb.w	3,0
	dc.w	$0030
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	Monitor.MSG
	dc.l	M.MSG
	dcb.w	3,0
	dc.w	$0039
	dc.w	$FFFF
	dc.w	$0200

;;pw
;	dc.l	PluginWin.MSG
;	dc.l	PW.MSG
;	dcb.w	3,0
;	dc.w	60		;amiga-P = 60
;	dc.w	$FFFF
;	dc.w	$0200
;;
	
	dc.l	Preferences.MSG
	dcb.w	2,0
	dc.w	$0010
	dcb.w	4,0
	dc.w	$0300
	
	dc.l	Environment.MSG
	dc.l	ascii.MSG17
	dcb.w	3,0
	dc.w	9
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	Assembler.MSG1
	dc.l	ascii.MSG18
	dcb.w	3,0
	dc.w	12
	dc.w	$FFFF
	dc.w	$0100
	
	dc.l	Debug.MSG0
	dcb.w	7,0
	dc.w	$0200
	
	dc.l	StepOneDown.MSG
	dcb.w	5,0
	dc.w	4
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	EnterRight.MSG
	dcb.w	5,0
	dc.w	3
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	Run.MSG
	dc.l	W2353C
	dcb.w	3,0
	dc.w	$0024
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	StepN.MSG
	dc.l	s.MSG0
	dcb.w	3,0
	dc.w	$0025
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	Skipinstructi.MSG
	dc.l	k.MSG0
	dcb.w	3,0
	dc.w	$0065
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	Rununtilhere.MSG		; ***
	dc.l	u.MSG
	dcb.w	3,0
	dc.w	$0057
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	Animate.MSG
	dc.l	i.MSG0
	dcb.w	3,0
	dc.w	$0064
	dc.w	$FFFF
	dc.w	$0200
	
	dcb.w	2,$FFFF
	dcb.w	7,0
	dc.w	$0200
	
	dc.l	EditRegs.MSG
	dc.l	x.MSG0
	dcb.w	3,0
	dc.w	$002A
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	AddWatch.MSG
	dc.l	a.MSG0
	dcb.w	3,0
	dc.w	$0013
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	DelWatch.MSG
	dcb.w	7,0
	dc.w	$0300
	
	dc.l	ascii.MSGLeeg
	dc.l	ascii.MSG52
	dcb.w	3,0
	dc.w	$0047
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	ascii.MSGLeeg
	dc.l	ascii.MSG54
	dcb.w	3,0
	dc.w	$0048
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	ascii.MSGLeeg
	dc.l	ascii.MSG56
	dcb.w	3,0
	dc.w	$0049
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	ascii.MSGLeeg
	dc.l	ascii.MSG58
	dcb.w	3,0
	dc.w	$004A
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	ascii.MSGLeeg
	dc.l	ascii.MSG60
	dcb.w	3,0
	dc.w	$004B
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	ascii.MSGLeeg
	dc.l	ascii.MSG62
	dcb.w	3,0
	dc.w	$004C
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	ascii.MSGLeeg
	dc.l	ascii.MSG64
	dcb.w	3,0
	dc.w	$004D
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	ascii.MSGLeeg
	dc.l	ascii.MSG66
	dcb.w	3,0
	dc.w	$004E
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	ZapWatchs.MSG
	dc.l	Z.MSG
	dcb.w	3,0
	dc.w	$0046
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	ZapConBPs.MSG
	dc.l	G.MSG
	dcb.w	3,0
	dc.w	$007A
	dc.w	$FFFF
	dc.w	$0200
	
	dcb.w	2,$FFFF
	dcb.w	7,0
	dc.w	$0200
	
	dc.l	JumpAddress.MSG0
	dc.l	J.MSG0
	dcb.w	3,0
	dc.w	$0036
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	JumpMark.MSG
	dc.l	j.MSG1
	dcb.w	3,0
	dc.w	$001C
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	BPCondition.MSG
	dc.l	f.MSG0
	dcb.w	3,0
	dc.w	$0071
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	DelCondition.MSG
	dcb.w	7,0
	dc.w	$0300
	
	dc.l	ascii.MSGLeeg
	dc.l	ascii.MSG22
	dcb.w	3,0
	dc.w	$0072
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	ascii.MSGLeeg
	dc.l	ascii.MSG23
	dcb.w	3,0
	dc.w	$0073
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	ascii.MSGLeeg
	dc.l	ascii.MSG24
	dcb.w	3,0
	dc.w	$0074
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	ascii.MSGLeeg
	dc.l	ascii.MSG25
	dcb.w	3,0
	dc.w	$0075
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	ascii.MSGLeeg
	dc.l	ascii.MSG26
	dcb.w	3,0
	dc.w	$0076
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	ascii.MSGLeeg
	dc.l	ascii.MSG27
	dcb.w	3,0
	dc.w	$0077
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	ascii.MSGLeeg
	dc.l	ascii.MSG28
	dcb.w	3,0
	dc.w	$0078
	dc.w	$FFFF
	dc.w	$0300
	
	dc.l	ascii.MSGLeeg
	dc.l	ascii.MSG29
	dcb.w	3,0
	dc.w	$0079
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	BPAddress.MSG
	dc.l	B.MSG
	dcb.w	3,0
	dc.w	$002E
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	BPMark.MSG
	dc.l	b.MSG1
	dcb.w	3,0
	dc.w	$0014
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	ZapAllBP.MSG
	dc.l	z.MSG0
	dcb.w	3,0
	dc.w	$002C
	dc.w	$FFFF
	dc.w	$0200
	
	dc.l	ChangeDxFPx.MSG
	dc.l	cExitesc.MSG
W22FFE:
	dcb.w	3,0
	dc.w	$002F
	dc.w	$FFFF
	dc.w	$0200
	
	dcb.w	2,$FFFF
	dcb.w	7,0
	dc.w	$0200
	
	dc.l	Exitesc.MSG1
	dcb.w	5,0
	dc.w	$1B00
	dc.w	$FFFF
	dcb.w	10,0
Project.MSG0:		dc.b	'Project',0
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
RecentTmp.MSG:		dcb.b	146,0		
Recent.MSG:		dcb.b	(146*10),0	
AddWorkMemM.MSG:	dc.b	'Add WorkMem    =M',0
About.MSG:		dc.b	'About           #',0
Quit.MSG:		dc.b	'Quit           ! ',0
QuickQuit.MSG:		dc.b	'Quick Quit     !!',0
Restarting.MSG:		dc.b	'Quick Restart  !R',0
Assembler.MSG0:		dc.b	'Assembler',0
Assemble.MSG:		dc.b	'Assemble',0
Assemble.MSG0:		dc.b	'Assemble',0
A.MSG0:			dc.b	'A',0
Optimize.MSG:		dc.b	'Optimize   ',0
O.MSG0:			dc.b	'O',0
Checkonly.MSG:		dc.b	'Check only ',0
Objectinfo.MSG:		dc.b	'Object info   =',0
Editor.MSG0:		dc.b	'Editor',0
E.MSG:			dc.b	'E',0
Debugger.MSG:		dc.b	'Debugger',0
D.MSG0:			dc.b	'D',0
Monitor.MSG:		dc.b	'Monitor',0
M.MSG:			dc.b	'M',0
PluginWin.MSG:		dc.b	'Show Plugin''s',0
PW.MSG:			dc.b	'P',0
Preferences.MSG:	dc.b	'Preferences   ',0
Environment.MSG:	dc.b	'Environment',0
ascii.MSG17:		dc.b	'[',0
Assembler.MSG1:		dc.b	'Assembler  ',0
ascii.MSG18:		dc.b	']',0
Syntaxpr.MSG:		dc.b	'Syntax Colors',0
SyntaxprChar.MSG:	dc.b	'Z',0
colors.MSG1:		dc.b	'Colors   =C',0
Agaguide.MSG:		dc.b	'Asm-Pro Help HELP',0
ascii.MSG19:		dc.b	'=',0
Edit.MSG0:		dc.b	'Edit',0
Block.MSG:		dc.b	'Block',0
Mark.MSG:		dc.b	'Mark',0
b.MSG:			dc.b	'b',0
Comment.MSG0:		dc.b	'Comment',0
ascii.MSG20:		dc.b	';',0
Uncomment.MSG:		dc.b	'Uncomment',0
ascii.MSG21:		dc.b	':',0
Tabulate.MSG:		dc.b	'Tabulate',0
Tabulate.Shc:		dc.b	'p',0
SelectAll.MSG:		dc.b	'Select all',0		
SelectAll.Shc:		dc.b	'q',0			
SpaceToTab.MSG:		dc.b	'Spaces to tabs',0	
SpaceToTab.Shc:		dc.b	'K',0			
Copy.MSG:		dc.b	'Copy',0
c.MSG:			dc.b	'c',0
Cut.MSG:		dc.b	'Cut',0
x.MSG:			dc.b	'x',0
Insert.MSG0:		dc.b	'Insert',0
i.MSG:			dc.b	'i',0
v.MSG:			dc.b	'v',0
Fill.MSG:		dc.b	'Fill',0
f.MSG:			dc.b	'f',0
UnMark.MSG:		dc.b	'UnMark',0
W232AC:			dc.b	'u',0
Lowercase.MSG:		dc.b	'Lowercase',0
l.MSG:			dc.b	'l',0
Uppercase.MSG:		dc.b	'Uppercase',0
L.MSG0:			dc.b	'L',0
Rotate.MSG:		dc.b	'Rotate',0
y.MSG:			dc.b	'y',0
Register.MSG:		dc.b	'Register',0
k.MSG:			dc.b	'k',0
Write.MSG0:		dc.b	'Write',0
W.MSG:			dc.b	"W",00		;was w
VerticalFill.MSG:	dc.b	'Vertical Fill',0
n.MSG:			dc.b	'n',0
Search.MSG1:		dc.b	'Search',0
S.MSG0:			dc.b	'S',0
Forward.MSG:		dc.b	'Forward',0
W2330A:			dc.b	's',0		;$7300
Replace.MSG:		dc.b	'Replace',0
Replace.MSG0:		dc.b	'Replace',0
R.MSG:			dc.b	'R',0
Forward.MSG0:		dc.b	'Forward',0
			cnop	0,4
C23326:			dc.b	'r',0
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
RemapMarkKeys:
ascii.MSG22:	dc.b	'!',0
ascii.MSG23:	dc.b	'@',0
ascii.MSG24:	dc.b	'#',0
ascii.MSG25:	dc.b	'$',0
ascii.MSG26:	dc.b	'%',0
ascii.MSG27:	dc.b	'^',0
ascii.MSG28:	dc.b	'&',0
ascii.MSG29:	dc.b	'*',0
ascii.MSG30:	dc.b	'(',0
ascii.MSG31:	dc.b	')',0
JumpMarks.MSG:	dc.b	'Jump Marks',0
Jump1.MSG:	dc.b	'Jump 1  ',0
Jump2.MSG:	dc.b	'Jump 2',0
Jump3.MSG:	dc.b	'Jump 3',0
Jump4.MSG:	dc.b	'Jump 4',0
Jump5.MSG:	dc.b	'Jump 5',0
Jump6.MSG:	dc.b	'Jump 6',0
Jump7.MSG:	dc.b	'Jump 7',0
Jump8.MSG:	dc.b	'Jump 8',0
Jump9.MSG:	dc.b	'Jump 9',0
Jump10.MSG:	dc.b	'Jump 10',0

ascii.MSG32:	dc.b	'1',0
ascii.MSG33:	dc.b	'2',0
ascii.MSG34:	dc.b	'3',0
ascii.MSG35:	dc.b	'4',0
ascii.MSG36:	dc.b	'5',0
ascii.MSG37:	dc.b	'6',0
ascii.MSG38:	dc.b	'7',0
ascii.MSG39:	dc.b	'8',0
ascii.MSG40:	dc.b	'9',0
ascii.MSG41:	dc.b	'0',0

Jump.MSG:	dc.b	'Jump ;;',0
J.MSG:		dc.b	'J',0
JumpLine.MSG:	dc.b	'Jump Line',0
j.MSG:		dc.b	'j',0
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
W234A0:		dc.w	$7400
Bottom.MSG:	dc.b	'Bottom',0
T.MSG:		dc.b	'T',0
LeftWordaltle.MSG:
		dc.b	'Left Word       alt  left',0
RightWordaltr.MSG:
		dc.b	'Right Word      alt right',0
MakeMacro.MSG:	dc.b	'Make Macro',0
ascii.MSG42:	dc.b	',',0
DoMacro.MSG:	dc.b	'Do Macro',0
m.MSG:		dc.b	'm',0
GrabWord.MSG:	dc.b	'Grab Word',0
g.MSG:		dc.b	'g',0
Nr2Ascii.MSG:	dc.b	"Nr 2 Ascii",0
;h2.MSG:		dc.b	'h',0
Exitesc.MSG:	dc.b	'Exit         esc',0
Debug.MSG0:	dc.b	'Debug',0
StepOneDown.MSG:dc.b	'Step One (Down)',0
EnterRight.MSG:	dc.b	'Enter (Right)',0
Run.MSG:	dc.b	'Run',0
W2353C:		dc.b	'r',0
StepN.MSG:	dc.b	'Step N',0
s.MSG0:		dc.b	's',0
Rununtilhere.MSG:					; ***
		dc.b	'Run until here',0		; ***
u.MSG:		dc.b	'u',0
Animate.MSG:	dc.b	'Animate',0
i.MSG0:		dc.b	'i',0
Skipinstructi.MSG:
		dc.b	'Skip instruction',0
k.MSG0:		dc.b	'k',0
EditRegs.MSG:	dc.b	'Edit Regs',0
x.MSG0:		dc.b	'x',0
AddWatch.MSG:	dc.b	'Add Watch',0
a.MSG0:		dc.b	'a',0
DelWatch.MSG:	dc.b	'Del Watch',0
	
ascii.MSG52:	dc.b	'1',0
ascii.MSG54:	dc.b	'2',0
ascii.MSG56:	dc.b	'3',0
ascii.MSG58:	dc.b	'4',0
ascii.MSG60:	dc.b	'5',0
ascii.MSG62:	dc.b	'6',0
ascii.MSG64:	dc.b	'7',0
ascii.MSG66:	dc.b	'8',0

ZapWatchs.MSG:	dc.b	'Zap Watch''s',0
Z.MSG:		dc.b	'Z',0
ZapConBPs.MSG:	dc.b	'Zap Con B.P''s',0
G.MSG:		dc.b	'G',0
JumpAddress.MSG0:
		dc.b	'Jump Address',0
J.MSG0:		dc.b	'J',0
JumpMark.MSG:	dc.b	'Jump Mark',0
f.MSG0:		dc.b	'f',0
BPCondition.MSG:dc.b	'B.P. Condition',0
DelCondition.MSG:
		dc.b	'Del Condition',0
j.MSG1:		dc.b	'j',0

ascii.MSGLeeg:	dc.b	' ',0

BPAddress.MSG:	dc.b	'B.P. Address',0
B.MSG:		dc.b	'B',0
BPMark.MSG:	dc.b	'B.P. Mark',0
b.MSG1:		dc.b	'b',0
ZapAllBP.MSG:	dc.b	'Zap All B.P.',0
z.MSG0:		dc.b	'z',0
ChangeDxFPx.MSG:
		dc.b	'Change Dx/FPx',0
cExitesc.MSG:	dc.b	'c'
Exitesc.MSG1:	dc.b	'Exit       esc',0
Commands.MSG:	dc.b	'Commands',0
Editor.MSG1:	dc.b	'Editor',0
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
AssembleA.MSG:	dc.b	'Assemble        @A',0
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
Assemble.MSG1:	dc.b	'Assemble',0
AssembleA.MSG0:	dc.b	'Assemble        A',0
MemoryA.MSG:	dc.b	'Memory          @A',0
OptimizeAO.MSG:	dc.b	'Optimize        AO',0
DebugAD.MSG:	dc.b	'Debug           AD',0
SymbolsS.MSG:	dc.b	'Symbols         =S',0
ParametersSet.MSG:
		dc.b	'Parameters Set  PS',0
Monitor.MSG0:	dc.b	'Monitor',0
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
BBSimul.MSG:dc.b	'BB Simulator   BS',0			
ExternE.MSG:	dc.b	'Extern            E',0
Output.MSG:	dc.b	'Output            >',0
Calculate.MSG:	dc.b	'Calculate         ?',0
Calculatefloa.MSG:
		dc.b	'Calculate float   [',0
CustomRegiste.MSG:
		dc.b	'Custom Registers  =R',0
Monitor.MSG1:	dc.b	'Monitor',0
Disassemble.MSG:dc.b	'Disassemble',0
d.MSG0:		dc.b	'd',0
HexDump.MSG:	dc.b	'Hex Dump',0
h.MSG:		dc.b	'h',0
ASCIIDump.MSG:	dc.b	'ASCII Dump',0
n.MSG0:		dc.b	'n',0
BinDump.MSG:	dc.b	'Bin Dump',0
b.MSG0:		dc.b	'b',0
JumpAddress.MSG:dc.b	'Jump Address',0
j.MSG0:		dc.b	'j',0
LastAddress.MSG:dc.b	'Last Address',0
l.MSG0:		dc.b	'l',0
SetMarks.MSG0:	dc.b	'Set Marks',0

Mark1.MSG0:	dc.b	'Mark 1  ',0
Mark2.MSG0:	dc.b	'Mark 2',0
Mark3.MSG0:	dc.b	'Mark 3',0

JumpMarks.MSG0:	dc.b	'Jump Marks',0
Jump1.MSG0:	dc.b	'Jump 1  ',0
Jump2.MSG0:	dc.b	'Jump 2',0
Jump3.MSG0:	dc.b	'Jump 3',0

ascii.MSG46:	dc.b	'1',0
ascii.MSG47:	dc.b	'2',0
ascii.MSG48:	dc.b	'3',0


SaveBin.MSG:	dc.b	'Save Bin',0
s.MSG:		dc.b	's',0
SetStart.MSG:	dc.b	'Set Start',0
ascii.MSG49:	dc.b	',',0
SetEnd.MSG:	dc.b	'Set End',0
ascii.MSG50:	dc.b	'.',0
QuickJump.MSG:	dc.b	'Quick Jump',0,0
W23AB4:		dc.b	'q',0
Exitesc.MSG0:	dc.b	'Exit      esc',0
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


	cnop	0,4

AmigaGuideGedoe:
	lea	(amigaguidelib.MSG).l,a1
	move.l	(4).w,a6
	jsr	(_LVOOldOpenLibrary,a6)
	move.l	d0,(AmigaGuideBase-DT,a4)
	beq.b	.erroropenlib

	move.l	(DosBase-DT,a4),a6
	jsr	_LVOGetProgramDir(a6)
	move.l	d0,d1
	jsr	_LVOSetProgramDir(a6)
	move.l	d0,olddirlock

	move.l	#sAGAGuide.MSG,d1	;kijk of s:aga.guide bestaat
	moveq.l	#ACCESS_READ,d2
	jsr	_LVOLock(a6)
	tst.l	d0
	beq.b	.erroropenfile
	move.l	d0,d1
	jsr	_LVOUnLock(a6)

	move.l	(AmigaGuideBase-DT,a4),a6
	lea	NewAmiGuide,a0
	sub.l	a1,a1			;tagitems
	jsr	(_LVOOpenAmigaGuideA,a6)	; ***
	move.l	d0,(NewAmiGuideBase-DT,a4)
	beq.s	.erroropenfile
	
	move.l	(NewAmiGuideBase-DT,a4),a0
	jsr	(_LVOCloseAmigaGuide,a6)	; ***
	bra.b	CloseAmigaGuideLib

.erroropenlib:
	lea	(Unabletoopena.MSG).l,a0
	jsr	(printTextInMenuStrip).l
	bra.b	CloseAmigaGuideLib

.erroropenfile:
	lea	(Unabletoopent.MSG).l,a0
	jsr	(printTextInMenuStrip).l
CloseAmigaGuideLib:
	tst.l	(AmigaGuideBase-DT,a4)
	beq.b	.aldicht
	move.l	(AmigaGuideBase-DT,a4),a1
	move.l	(4).w,a6
	jsr	(_LVOCloseLibrary,a6)
.aldicht:

	clr.w	(Cursor_col_pos-DT,a4)	;x
	jsr	Place_cursor_blokje

	moveq	#0,d0
	rts

olddirlock:	dc.l	0


W289AE:

	even
realend4:
;	cnop	0,4
	dc.w	666



;*************************************************
;**              PREFS WINDOWTJES               **
;*************************************************

;	SECTION	prefs,code
	
Handle_prefs_windows:
	sf	FontChanged
	move.l	(MainWindowHandle-DT,a4),a0
	bsr	Copy_prefs2buffer

	move.w	(EFontSize_x-DT,a4),d0
	mulu.w	#76,d0
	move.w	D0,Prefs_win_br
	move.w	D0,Prefs_win_br2
	move.w	(EFontSize_y-DT,a4),d0
	addq.w	#3,d0
	move.w	d0,d1
	mulu.w	#22,d0
	move.w	D0,Prefs_win_hg
	mulu.w	#15,d1
	move.w	D1,Prefs_win_hg2

	clr	(PrefsGedoe-DT,a4)

	tst.b	(Prefs_tiepe-DT,a4)
	bne.b	.asmprefs0
	bsr	Prefs_initenvGads
	
	move.l	(SchermMode).l,(scrmode_oud-DT,a4)
	move.l	(SchermMode).l,(scrmode_new-DT,a4)
	move.l	(HoogteScherm).l,(old_sizeY-DT,a4)
	move.l	(BreedteScherm).l,(old_sizeX-DT,a4)
	move.w	(Scr_NrPlanes-DT,a4),(old_screendepth-DT,a4)
	bra.b	.envprefs0

.asmprefs0:
	bsr	Prefs_initasmGads
.envprefs0:
	cmp.b	#0,(Prefs_tiepe-DT,a4)
	bne.b	.asmprefs
	bsr	Open_Prefswindow
	bra.b	.envprefs

.asmprefs:
	cmp.b	#1,(Prefs_tiepe-DT,a4)
	bne.b	.syntcolsprefs
	bsr	Open_Prefswindow2
	bra.b	.envprefs

.syntcolsprefs:
	bsr	Prefs_initSyntGads
	bsr	OpenSyntColsWin

.envprefs:
	tst.l	d0
	bne	ErrorPrefsWin	;error

	bsr	CreatePrefsMsgport
	tst.l	d0
	bne	ErrorPrefsWin

	move.l	#0,(PR_CloseWin).l
	bsr.b	PrefsEventloopje

	bsr	Close_Prefswindow
	bsr	RemovePrefsmsgPort
;	bsr	Prefs_endrequest

	cmp	#2,(PrefsGedoe-DT,a4)
	beq	ReinitStuff
	jsr	(RESETMENUTEXT).l

;	clr.w	(Cursor_col_pos-DT,a4)	;x
;	jsr	Place_cursor_blokje

	moveq	#0,d0
	rts

PrefsEventloopje:
	lea	(Variable_base).l,a4
	moveq	#1,d0
	move.l	(Prefs_msgport).l,a0
	moveq	#0,d1
	move.b	(15,a0),d1
	lsl.l	d1,d0
	move.l	d0,(L2F10C).l
C23D70:
	cmp.l	#1,(PR_CloseWin).l
	beq.b	C23D9C
	move.l	(L2F10C).l,d0
	move.l	(4).w,a6
	jsr	(_LVOWait,a6)
	move.l	d0,d1
	and.l	(L2F10C).l,d1
	beq.b	C23D9A
	move.l	d0,-(sp)
	bsr.b	C23D9E
	move.l	(sp)+,d0
C23D9A:
	bra.b	C23D70

C23D9C:
	rts

C23D9E:
	move.l	(Prefs_msgport).l,a0
	move.l	(GadToolsBase-DT,a4),a6
	jsr	(_LVOGT_GetIMsg,a6)
	move.l	d0,(Prefs_Msg).l
	beq.b	C23DFE
	move.l	d0,a0
	move.l	(PrefsAsmWinBase).l,d1
	cmp.l	($002C,a0),d1
	bne.b	.anderwindow

	lea	(Variable_base).l,a4
	bsr.b	Prefs_CheckoutMsg
	cmp.l	#1,(PrefsEndLoading).l
	beq.b	C23DFE
	cmp.l	#0,(PR_GTIMsg).l
	beq.b	.anderwindow
	move.l	(PR_GTIMsg).l,a1
	move.l	(GadToolsBase-DT,a4),a6
	jsr	(_LVOGT_ReplyIMsg,a6)
	move.l	#0,(PR_GTIMsg).l
.anderwindow:
	br	C23D9E

C23DFE:
	move.l	#0,(PrefsEndLoading).l
	moveq.l	#0,d0
	rts

Prefs_Msg:	dcb.l	2,0
PR_GTIMsg:	dc.l	0
PR_CloseWin:	dc.l	0
PrefsEndLoading:dc.l	0

Prefs_CheckoutMsg:
	move.l	d0,(L23EA2).l
	move.l	d0,a0
	cmp.l	#4,(20,a0)	;class
	bne.b	C23E5A
	move.l	(PrefsAsmWinBase).l,a0
	move.l	(GadToolsBase-DT,a4),a6
	jsr	(_LVOGT_BeginRefresh,a6)	; ***
	move.l	(PrefsAsmWinBase).l,a0
	moveq.l	#1,d0
	move.l	(GadToolsBase-DT,a4),a6
	jmp	(_LVOGT_EndRefresh,a6)		; ***
;	bra.b	C23EA0

C23E5A:
	cmp.l	#$00000100,($0014,a0)	;class menu
	bne.b	C23E6A
	bra	PR_menuCheck
;	bra.b	C23EA0

C23E6A:
	cmp.l	#$00000040,($0014,a0)	;class gadgets
	bne.b	C23E88
	cmp.b	#0,(Prefs_tiepe-DT,a4)
	bne.b	.geenenv
	bsr	Prefs_checkbuttons_Env
	bra.b	.verder

.geenenv:
	cmp.b	#1,(Prefs_tiepe-DT,a4)
	bne.b	.geenasm
	bsr	Prefs_checkbuttons_Asm
	bra.b	.verder
.geenasm:
	bsr	Prefs_checkbuttons_Synt
.verder:
	rts
;	bra.b	C23EA0

C23E88:
	cmp.l	#$00000200,($0014,a0)	;close button
	bne.b	.closeIt
	bsr	Copy_prefsFromBuffer
	move.l	#1,(PR_CloseWin).l
.closeIt:
	rts

L23EA2:
	dcb.l	2,0

ErrorPrefsWin:
;	bsr	Prefs_endrequest
	lea	(Notenoughmemo.MSG0).l,a0
	jmp	(printTextInMenuStrip).l

C23EBA:
	lea	(Prefs_Gadgets-DT,a4),a0
	move.l	(4*EPG_ext,a0),a1
	move.l	($0022,a1),a1
	move.l	(a1),a1
	lea	(S.MSG).l,a0
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
	clr.w	SyntItemIndex	;eerste item eerst
	
	lea	fontcolortab,a0
	lea	TheColors(pc),a1

	moveq	#4-1,d7
.lopje:
	move.l	(a0)+,d0
	move.b	d0,(a1)+
	swap	d0
	move.b	d0,(a1)+
	addq.l	#2,a1	;skip 2 dummy bytes
	dbf	d7,.lopje

	rts

Prefs_initenvGads:
	lea	(Env_begin).l,a1
	lea	(Prefs_EnvGadgets2).l,a3
	moveq	#[Env_end-Env_begin]/2-1,d7
.lopje:
	move.b	(a1),(7,a3)
	addq.w	#2,a1
	lea	(16,a3),a3
	dbra	d7,.lopje
	rts

Prefs_initasmGads:
	move	(CPU_type-DT,a4),(Prefs_AsmCpuType).l
	lea	(Asm_begin).l,a1
	lea	(Prefs_AsmGadgets2).l,a3
	moveq	#[Asm_end-Asm_begin]/2-1,d7
.lopje:
	move.b	(a1),(7,a3)
	addq.w	#2,a1
	lea	(16,a3),a3
	dbra	d7,.lopje
	rts

PR_menuCheck:
	move.l	d0,a1
	moveq	#0,d0
	move	($0018,a1),d0	;code
	move.l	d0,d1
	and.l	#$0000001F,d0
	lsr.l	#5,d1
	and.l	#$0000003F,d1
	cmp.l	#0,d0
	bne.b	.NextMenu1
	cmp.l	#0,d1
	beq.b	PR_loadPrefsFile	;open
	cmp.l	#1,d1
	beq	PR_savePrefs		;save
	cmp.l	#2,d1
	beq	PR_ExitPrefsWin		;steep
	cmp.l	#3,d1
	beq	PR_ExitPrefsWin		;exit
	bra.b	.NextMenu2		;go-on

.NextMenu1:
	cmp.l	#1,d0
	bne.b	.NextMenu2
	cmp.l	#0,d1
	beq	PR_Reset2Default	;reset
	cmp.l	#1,d1
	beq	C24108		;last saved
.NextMenu2:
	rts

PR_loadPrefsFile:
	move.l	(PrefsAsmWinBase).l,a0
	move.l	(Error_Jumpback-DT,a4),(L2F144-DT,a4)
	move.b	(SomeBits3-DT,a4),(SomeBits3_backup-DT,a4)
	bset	#1,(SomeBits3-DT,a4)	;???
	lea	(C24022,pc),a0
	move.l	a0,(Error_Jumpback-DT,a4)
	moveq	#11,d0
	jsr	(YesReqLib).l
	tst.b	(CurrentAsmLine-DT,a4)
	beq.b	C24022
	move	(Safety-DT,a4),-(sp)
	move.b	#1,(Safety-DT,a4)
	jsr	(Read_Prefs2).l
	move	(sp)+,(Safety-DT,a4)
	move.l	(L2F144-DT,a4),(Error_Jumpback-DT,a4)
	move.b	(SomeBits3_backup-DT,a4),(SomeBits3-DT,a4)
	bsr	RemovePrefsmsgPort
	bsr	Close_Prefswindow
;	bsr	Close_Prefsscreen
	br	C24134

C24022:
	move.l	(L2F144-DT,a4),(Error_Jumpback-DT,a4)
	move.b	(SomeBits3_backup-DT,a4),(SomeBits3-DT,a4)
	rts

PR_savePrefs:
	move.l	(PrefsAsmWinBase).l,a0
	move.l	(Error_Jumpback-DT,a4),(L2F144-DT,a4)
	move.b	(SomeBits3-DT,a4),(SomeBits3_backup-DT,a4)
	bset	#1,(SomeBits3-DT,a4)
	lea	(C240A8,pc),a0
	move.l	a0,(Error_Jumpback-DT,a4)
	moveq	#12,d0
	jsr	(YesReqLib).l
	tst.b	(CurrentAsmLine-DT,a4)
	beq.b	C240A8
	bsr	Copy_prefsFromBuffer
	cmp.b	#0,(Prefs_tiepe-DT,a4)
	bne.b	C2407A
	bsr	C23EBA
C2407A:
	move.b	#1,(B30042-DT,a4)
	move	(Safety-DT,a4),-(sp)
	move.b	#1,(Safety-DT,a4)
	move	(SomeBits3-DT,a4),-(sp)
	bset	#SB3_EDITORMODE,(SomeBits3-DT,a4)		;in editor
	jsr	(Write_Prefs).l
	move	(sp)+,(SomeBits3-DT,a4)
	move	(sp)+,(Safety-DT,a4)
	move.b	#0,(B30042-DT,a4)
C240A8:
	move.l	(L2F144-DT,a4),(Error_Jumpback-DT,a4)
	move.b	(SomeBits3_backup-DT,a4),(SomeBits3-DT,a4)
	rts

PR_ExitPrefsWin:
	move.l	#1,(PR_CloseWin).l
	rts

PR_Reset2Default:
	lea	(DefaultPrefs).l,a0
	lea	(PR_ReqLib).l,a1
	move.l	#[PR_end-Env_begin]/2-1,d7
.lopje:
	move	(a0)+,(a1)+
	dbra	d7,.lopje

	move.l	(SchermMode).l,(scrmode_oud-DT,a4)
	move.l	(SchermMode).l,(scrmode_new-DT,a4)
	move.l	(HoogteScherm).l,(old_sizeY-DT,a4)
	move.l	(BreedteScherm).l,(old_sizeX-DT,a4)
	bsr	RemovePrefsmsgPort
	bsr	Close_Prefswindow
	bra.b	C24134

C24108:
	move	(Safety-DT,a4),-(sp)
	move.b	#1,(Safety-DT,a4)
	jsr	(Read_Prefs).l
	move	(sp)+,(Safety-DT,a4)
	bsr	RemovePrefsmsgPort
	bsr	Close_Prefswindow
	lea	(ENVARCAsmProp.MSG).l,a0
	jsr	(printTextInMenuStrip).l
C24134:
	bsr	Prefs_initenvGads
	cmp.b	#0,(Prefs_tiepe-DT,a4)
	beq.b	C2414E
	bsr	Open_Prefswindow2
	bra.b	C24152

C2414E:
	bsr	Open_Prefswindow
C24152:
	tst.l	d0
	bne.b	C24192
	bsr	CreatePrefsMsgport
	tst.l	d0
	bne.b	C24192
	lea	(Variable_base).l,a4
	moveq	#1,d0
	move.l	(Prefs_msgport).l,a0
	moveq	#0,d1
	move.b	(15,a0),d1
	lsl.l	d1,d0
	move.l	d0,(L2F10C).l
	move.l	#1,(PrefsEndLoading).l
	move.l	#0,(PR_CloseWin).l
	bsr	Copy_prefs2buffer
C24192:
	rts


Prefs_checkbuttons_Synt:
	lea	(Variable_base).l,a4
	move.l	d0,(PR_Msg).l
	move.l	d0,a1
	move.l	($14,a1),(PR_GadClass).l
	move.l	($18,a1),(PR_GadCode).l
	move.l	($20,a1),(PR_GadMouseX).l
	move.l	($1C,a1),a0
	move.l	a0,(PR_GadgetAdr).l
	move	($26,a0),(PR_GadgetID).l

	moveq	#0,d1
	move	(PR_GadgetID).l,d1
	cmp	#SPG_save,d1
	beq	PW_envB_Save
	cmp	#SPG_use,d1
	beq	PW_envB_Use
	cmp	#SPG_cancel,d1
	beq	PW_envB_Cancel


	move	(PR_GadCode).l,d0
	lea	TheColors(pc),a0

	cmp	#SPG_ATTR,d1		;item
	bne.b	.PR_Front

	lsl.w	#2,d0
	move.w	d0,SyntItemIndex
	
	move.b	(a0,d0.w),.PalChange+7
	lea	.PalChange(pc),a3
	move.l	Prefs_Gadgets+SPG_FRONT*4,a0
	bsr	ChangeGadgetState

	move.w	SyntItemIndex(pc),d0
	lea	TheColors(pc),a0
	move.b	1(a0,d0.w),.PalChange+7
	lea	.PalChange(pc),a3
	move.l	Prefs_Gadgets+SPG_BACK*4,a0
	bsr	ChangeGadgetState
	bra.w	.PR_nomore

.PR_Front:
	cmp	#SPG_FRONT,d1		;item
	bne.b	.PR_Back

	move.w	SyntItemIndex(pc),d1
	move.b	d0,(a0,d1.w)		;front pen

	bra.w	.rewrite

.PR_Back:
	cmp	#SPG_BACK,d1		;item
	bne.b	.PR_nomore

	move.w	SyntItemIndex(pc),d1
	move.b	d0,1(a0,d1.w)		;back pen

.rewrite
	bsr	ShowPrevSource

.PR_nomore:
	rts

.PalChange:
	dc.l	GTPA_Color,0	;false !!
	dc.l	-1


Prefs_checkbuttons_Asm:
	lea	(Variable_base).l,a4
	move.l	d0,(PR_Msg).l
	move.l	d0,a1
	move.l	($14,a1),(PR_GadClass).l
	move.l	($18,a1),(PR_GadCode).l
	move.l	($20,a1),(PR_GadMouseX).l
	move.l	($1C,a1),a0
	move.l	a0,(PR_GadgetAdr).l
	move	($26,a0),(PR_GadgetID).l

	moveq	#0,d1
	move	(PR_GadgetID).l,d1
	cmp	#APG_save,d1
	beq	PW_envB_Save
	cmp	#APG_use,d1
	beq	PW_envB_Use
	cmp	#APG_cancel,d1
	beq	PW_envB_Cancel

	cmp	#APG_CPU,d1
	bne.b	.PR_Checkboxes_Asm
	move	(PR_GadCode).l,(Prefs_AsmCpuType).l
	bra.b	.PR_nomore_Asm

.PR_Checkboxes_Asm:
	move.l	($28,a0),d0
	beq.b	.doit
	cmp	(PrefsGedoe-DT,a4),d0
	ble.w	.doit
	move	d0,(PrefsGedoe-DT,a4)
.doit:
	lea	(asm_prefsptr).l,a0
	and.l	#$0000FFFF,d1
	subq.l	#3,d1
	lsl.l	#2,d1
	move.l	(a0,d1.w),a1
	eor.b	#1,(a1)
.PR_nomore_Asm:
	rts



Prefs_checkbuttons_Env:
	lea	(Variable_base).l,a4
	move.l	d0,(PR_Msg).l
	move.l	d0,a1
	move.l	($0014,a1),(PR_GadClass).l
	move.l	($0018,a1),(PR_GadCode).l
	move.l	($0020,a1),(PR_GadMouseX).l
;	move.l	($001C,a1),(PR_GadgetAdr).l
	move.l	($001C,a1),a0
	move.l	a0,(PR_GadgetAdr).l
	move	($0026,a0),(PR_GadgetID).l

	moveq	#0,d1
	move	(PR_GadgetID).l,d1
	cmp	#EPG_dir,d1		;dir
	beq.w	PW_envB_Dir
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
	beq.w	Customscrollknop

	cmp	#EPG_wt,d1
	bne.s	.noWaitTOF
;	move.l	PR_GadCode,d0
	move.w	PR_GadCode,d0
	btst	#0,d0
	beq.s	.noWaitTOF
	lea	wt_txt(pc),a1
	jsr	Error_req
.noWaitTOF:

aaaarg:
	move.l	($0028,a0),d0
	beq.b	.doit
	cmp	(PrefsGedoe-DT,a4),d0
	ble.w	.doit
	move	d0,(PrefsGedoe-DT,a4)
.doit:
	lea	(env_prefsptrs).l,a0
	and.l	#$0000FFFF,d1
	subq.l	#3,d1
	lsl.l	#2,d1
	move.l	(a0,d1.w),a1
	eor.b	#1,(a1)
PW_envB_Dir:
	rts

Customscrollknop:
	cmp.l	#640,BreedteScherm
	beq.s	aaaarg

	lea	cs_txt(pc),a1
	jsr	Error_req

	move.l	PR_GadgetAdr,a0	;gadget
	lea	gadarr,a3	;taglist

ChangeGadgetState:
	move.l	GadToolsBase,a6
	move.l	PrefsAsmWinBase,a1	;win
	sub.l	a2,a2		;req

	jsr	_LVOGT_SetGadgetAttrsA(a6)
	rts

gadarr:
	dc.l	GTCB_Checked,0	;false !!
	dc.l	-1



OpenScreenReq:
	tst.l	(ReqToolsbase-DT,a4)
	bne.b	Screenmoderequester
	jsr	(openreqtoolslib).l
	tst.l	(ReqToolsbase-DT,a4)
	bne.b	Screenmoderequester
C242CA:
	move.l	#0,(PR_CloseWin).l
	rts

Screenmoderequester:
	moveq.l	#3,d0
	sub.l	a0,a0
	move.l	(ReqToolsbase).l,a6
	jsr	(_LVOrtAllocRequestA,a6)		; ***
	move.l	d0,(screen_req-DT,a4)
	beq.b	C242CA

;	move.w	(Scr_NrPlanes-DT,a4),ScreenmodeTags\.depth+2
;	move.l	ScreenBase,ScreenmodeTags\.screen

	lea	(Pleaseselectp.MSG).l,a3
	lea	(ScreenmodeTags).l,a0
	sub.l	a2,a2
	move.l	(screen_req-DT,a4),a1
	move.l	(ReqToolsbase).l,a6
	jsr	(_LVOrtScreenModeRequestA,a6)		; ***
	tst.l	d0
	beq	.noChange

	move.l	(screen_req-DT,a4),a1
	move.l	(rtsc_DisplayID,a1),d0
	cmp.l	(scrmode_new-DT,a4),d0
	bne.b	.yesChange
	moveq.l	#0,d0
	move	(rtsc_DisplayWidth,a1),d0
	cmp.l	(old_sizeX-DT,a4),d0
	bne.b	.yesChange
	moveq.l	#0,d0
	move	(rtsc_DisplayHeight,a1),d0
	cmp.l	(old_sizeY-DT,a4),d0
	bne.b	.yesChange

	move.w	(rtsc_DisplayDepth,a1),d0
	move.w	d0,(Scr_NrPlanes-DT,a4)
	cmp.w	(old_screendepth-DT,a4),d0
	bne.s	.yesChange
	br	.noChange


.yesChange:
	moveq	#0,d0
	move	rtsc_DisplayWidth(a1),d0
	cmp.l	#640,d0
	bge.b	.CheckWidth
	move.l	#640,d0
.CheckWidth:
	and.l	#$FFFFFFF8,d0	;!!! mag wel hoor... byte alligned
	cmp.l	#640,d0
	beq.b	.verder
	clr.w	PR_CustomScroll
	clr.w	epp_customscroll
.verder:
	move.l	d0,ScrBr_1
	move.l	d0,BreedteScherm
	moveq	#0,d0
	move	rtsc_DisplayHeight(a1),d0
	move.l	d0,Scrhoog_1
	move.l	d0,HoogteScherm

	move.w	rtsc_DisplayDepth(a1),(Scr_NrPlanes-DT,a4)
	
.noOnePlane:

	move.l	rtsc_DisplayID(a1),(scrmode_new-DT,a4)

	move	#2,(PrefsGedoe-DT,a4)	;refresh display...
.noChange:
	move.l	(screen_req).l,a1
	move.l	(ReqToolsbase).l,a6
	jsr	(_LVOrtFreeRequest,a6)		; ***
	rts

PW_envB_Cancel:
	movem.l	d0-a6,-(sp)			
	tst.b	FontChanged
	beq.b	NoFntChange
	movem.l	a0/a1,-(a7)			; restore font attributes
	lea	Oldeditfont_name,a0
	lea	editfont_name,a1
.FontRestore:
	move.b	(a0)+,(a1)+
	bne.s	.FontRestore
	move.w	OldEditorFontSize,EditorFontSize
	move.w	OldEditorFontSize+2,EditorFontSize+2
	move.w	OldEditorFontSize+3,EditorFontSize+3
	movem.l	(a7)+,a0/a1

	bsr	close_edit_font
	bsr	init_edit_font
	move	#2,(PrefsGedoe-DT,a4)	;refresh display...
	move.l	#1,(PR_CloseWin).l
	movem.l	(sp)+,d0-a6
	rts
NoFntChange:
	movem.l	(sp)+,d0-a6

	clr	(PrefsGedoe-DT,a4)
	move.l	#1,(PR_CloseWin).l
	rts

PW_envB_Use:
	bsr	Copy_prefsFromBuffer
	cmp.b	#0,(Prefs_tiepe-DT,a4)
	bne.b	.asmprefs
	bsr	C23EBA
	move.l	(old_sizeX-DT,a4),d0
	cmp.l	(BreedteScherm).l,d0
	bne.b	.C243F4
	move.l	(old_sizeY-DT,a4),d0
	cmp.l	(HoogteScherm).l,d0
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

	move	(Prefs_AsmCpuType).l,(CPU_type-DT,a4)
	bra.w	.klaar

.syntprefs:
	bsr	SyntUseGedoe
.klaar:
	move.l	#1,(PR_CloseWin).l
	rts

SyntUseGedoe:

	lea	TheColors(pc),a0
	lea	fontcolortab,a1
	moveq	#4-1,d7
	moveq.l	#0,d0
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
	cmp.b	#0,(Prefs_tiepe-DT,a4)
	bne	.asmprefs
	bsr	C23EBA
	move.l	(old_sizeX-DT,a4),d0
	cmp.l	(BreedteScherm).l,d0
	bne.b	.changed
	move.l	(old_sizeY-DT,a4),d0
	cmp.l	(HoogteScherm).l,d0
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
	move	(Prefs_AsmCpuType).l,(CPU_type-DT,a4)
	bra.b	.notChanged

.syntprefs:
	bsr	SyntUseGedoe

.notChanged:
	move	(Safety-DT,a4),-(sp)
	move	(SomeBits3-DT,a4),-(sp)
	move.b	#1,(Safety-DT,a4)
	bset	#SB3_EDITORMODE,(SomeBits3-DT,a4)	;in editor
	jsr	(Write_Prefs).l
	move	(sp)+,(SomeBits3-DT,a4)
	move	(sp)+,(Safety-DT,a4)
	lea	(ENVARCAsmProp.MSG0).l,a0
	jsr	(printTextInMenuStrip).l
	move.l	#1,(PR_CloseWin).l
	rts

Copy_prefs2buffer:
	lea	(PR_ReqLib).l,a0
	lea	(epp_reqtools).l,a1
	move.l	#[PR_end-Env_begin]/2-1,d0
.lopje:
	move	(a0)+,(a1)+
	dbra	d0,.lopje
	move.l	(SchermMode).l,(scrmode_oud-DT,a4)
	rts

Copy_prefsFromBuffer:
	lea	(PR_ReqLib).l,a1
	lea	(epp_reqtools).l,a0
	move.l	#[PR_end-Env_begin]/2-1,d0
.lopje:
	move	(a0)+,(a1)+
	dbra	d0,.lopje
	rts

Open_Prefswindow:
	movem.l	d1-d4/a0-a3/a5/a6,-(sp)

	lea	env_gadspos,a0
	lea	Env_prefs_gadstr,a1
	moveq.l	#env_gadcount-1,d7
	jsr	pos_gadgets

	move.l	(ScreenBase).l,a0
	moveq	#0,d3
	moveq	#0,d2
	move.b	($0024,a0),d2	;Wborder links
	move.l	($0028,a0),a1	;ptr screen font
	move	(4,a1),d3
	addq.w	#1,d3
	add.b	($0023,a0),d3	;wbortop
	lea	(Prefs_GList).l,a0
	move.l	(GadToolsBase-DT,a4),a6
	jsr	_LVOCreateContext(a6)
	move.l	d0,a3
	tst.l	d0
	beq	Error_createcontext
	movem.w	d2/d3,-(sp)
	moveq	#0,d3
	lea	(Prefs_EnvGadTags).l,a5
C2462C:
	lea	(Env_prefs_gadstr).l,a0
	move.l	d3,d0
	mulu	#30,d0
	add.l	d0,a0
	lea	(GadgetBuffer).l,a1
	moveq	#30,d0
	move.l	(4).w,a6
	jsr	(_LVOCopyMem,a6)

	lea	(GadgetBuffer).l,a0
	move.l	(MainVisualInfo).l,($0016,a0)
	move.l	#Editor_Font,(12,a0)
	move	(a0),d0
	add	(sp),d0
	move	d0,(a0)
	move	(2,a0),d0
	add	(2,sp),d0
	move	d0,(2,a0)
	lea	(Pref_EnvGadgetTypes).l,a0
	moveq	#0,d0
	move.l	d3,d1
	asl.l	#1,d1
	add.l	d1,a0
	move	(a0),d0
	move.l	a3,a0
	lea	(GadgetBuffer).l,a1
	move.l	a5,a2
	move.l	(GadToolsBase-DT,a4),a6
	jsr	(_LVOCreateGadgetA,a6)		; ***
	tst.l	d0
	beq	C24794
	move.l	d0,a3
	move.l	d3,d0
	asl.l	#2,d0
	lea	(Prefs_Gadgets).l,a0
	add.l	d0,a0
	move.l	a3,(a0)
C246AE:
	cmp.l	#$FFFFFFFF,(a5)+
	beq.b	C246B8
	bra.b	C246AE

C246B8:
	addq.w	#1,d3
	cmp	#env_gadcount,d3	;33
	bmi.w	C2462C

	movem.w	(sp)+,d2/d3
	move.l	(Prefs_GList).l,(L1DAE2).l
	move.l	(ScreenBase).l,(ScreenBaseTemp1).l
	moveq	#0,d0
	move	(W1D006).l,d0
	move.l	d0,(L1DAB2).l
	move	(W1D008).l,d0
	move.l	d0,(L1DABA).l
	move	(Prefs_win_br).l,d0
	move.l	d0,(Prefs_winbreedt).l
	move	(Prefs_win_hg).l,d0
	add	d3,d0
	move.l	d0,(Prefs_winhoog).l
	lea	(Prefs_newmenustr).l,a0
	lea	(prefs_menutags2).l,a1
	move.l	(GadToolsBase-DT,a4),a6
	jsr	(_LVOCreateMenusA,a6)		; ***
	move.l	d0,(L2F056).l
	tst.l	d0
	beq.b	C24742
	move.l	d0,a0
	move.l	(MainVisualInfo).l,a1
	lea	(prefs_menutags1).l,a2
	move.l	(GadToolsBase-DT,a4),a6
	jsr	(_LVOLayoutMenusA,a6)		; ***
C24742:
	move.l	#AsmProEnviron.MSG,Prefs_wintitle
	sub.l	a0,a0
	lea	(Prefswin_taglist).l,a1
	move.l	(IntBase-DT,a4),a6
	jsr	(_LVOOpenWindowTagList,a6)
	move.l	d0,(PrefsAsmWinBase).l
	tst.l	d0
	beq.b	C24790
	move.l	(PrefsAsmWinBase).l,a0
	move.l	(L2F056).l,a1
	move.l	(IntBase-DT,a4),a6
	jsr	(_LVOSetMenuStrip,a6)
	move.l	(PrefsAsmWinBase).l,a0
	sub.l	a1,a1
	move.l	(GadToolsBase-DT,a4),a6
	jsr	(_LVOGT_RefreshWindow,a6)		; ***

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
	move.l	(PrefsAsmWinBase).l,a0
	cmp.l	#0,a0
	beq.b	.C247D6
	move.l	(L2F148-DT,a4),($0056,a0)
	moveq.l	#0,d0
	move.l	(PrefsAsmWinBase).l,a0
	move.l	(IntBase-DT,a4),a6
	jsr	(_LVOModifyIDCMP,a6)
	move.l	(PrefsAsmWinBase).l,a0
	move.l	(IntBase-DT,a4),a6
	jsr	(_LVOClearMenuStrip,a6)
.C247D6:
	move.l	(L2F056).l,a0
	cmp.l	#0,a0
	beq.b	.C247EC
	move.l	(GadToolsBase-DT,a4),a6
	jsr	(_LVOFreeMenus,a6)			; ***
.C247EC:
	move.l	(PrefsAsmWinBase).l,a0
	cmp.l	#0,a0
	beq.b	C24802
	move.l	(IntBase-DT,a4),a6
	jsr	(_LVOCloseWindow,a6)
C24802:
	move.l	(Prefs_GList).l,a0
	cmp.l	#0,a0
	beq.b	C24818
	move.l	(GadToolsBase-DT,a4),a6
	jsr	(_LVOFreeGadgets,a6)			; ***
C24818:
	movem.l	(sp)+,d0/d1/a0-a2/a6
	rts


Open_Prefswindow2:
	movem.l	d1-d4/a0-a3/a5/a6,-(sp)

	lea	asm_gadspos,a0
	lea	Asm_prefs_gadstr,a1
	moveq.l	#asm_gadcount-1,d7
	jsr	pos_gadgets

	move.l	(ScreenBase).l,a0
	moveq	#0,d3
	moveq	#0,d2
	move.b	($0024,a0),d2	;wborder links
	move.l	($0028,a0),a1	;font ptr
	move	(4,a1),d3
	addq.w	#1,d3
	add.b	($0023,a0),d3	;wbortop
	lea	(Prefs_GList).l,a0
	move.l	(GadToolsBase-DT,a4),a6
	jsr	(_LVOCreateContext,a6)		; ***
	move.l	d0,a3
	tst.l	d0
	beq	.ProjectPrefsCError
	movem.w	d2/d3,-(sp)
	moveq	#0,d3
	lea	(Prefs_AsmGadTags).l,a5
.C24860:
	lea	(Asm_prefs_gadstr).l,a0
	move.l	d3,d0
	mulu	#30,d0
	add.l	d0,a0
	lea	(GadgetBuffer).l,a1
	moveq	#30,d0
	move.l	(4).w,a6
	jsr	(_LVOCopyMem,a6)

	lea	(GadgetBuffer).l,a0
	move.l	(MainVisualInfo).l,($0016,a0)
	move.l	#Editor_Font,(12,a0)
	move	(a0),d0
	add	(sp),d0
	move	d0,(a0)
	move	(2,a0),d0
	add	(2,sp),d0
	move	d0,(2,a0)
	lea	(Pref_AsmGadgetTypes).l,a0
	moveq	#0,d0
	move.l	d3,d1
	asl.l	#1,d1
	add.l	d1,a0
	move	(a0),d0
	move.l	a3,a0
	lea	(GadgetBuffer).l,a1
	move.l	a5,a2
	move.l	(GadToolsBase-DT,a4),a6
	jsr	_LVOCreateGadgetA(a6)
	tst.l	d0
	beq	.C249C8
	move.l	d0,a3
	move.l	d3,d0
	asl.l	#2,d0
	lea	(Prefs_Gadgets).l,a0
	add.l	d0,a0
	move.l	a3,(a0)
.C248E2:
	cmp.l	#-1,(a5)+
	beq.b	.C248EC
	bra.b	.C248E2

.C248EC:
	addq.w	#1,d3
	cmp	#asm_gadcount,d3	;24
	bmi.w	.C24860

	movem.w	(sp)+,d2/d3

	move.l	(Prefs_GList).l,(L1DAE2).l
	move.l	(ScreenBase).l,(ScreenBaseTemp1).l
	moveq	#0,d0
	move	(W1D00E).l,d0
	move.l	d0,(L1DAB2).l
	move	(W1D010).l,d0
	move.l	d0,(L1DABA).l
	move	(Prefs_win_br2).l,d0
	move.l	d0,(Prefs_winbreedt).l
	move	(Prefs_win_hg2).l,d0
	add	d3,d0
	move.l	d0,(Prefs_winhoog).l
	lea	(Prefs_newmenustr).l,a0
	lea	(prefs_menutags2).l,a1
	move.l	(GadToolsBase-DT,a4),a6
	jsr	_LVOCreateMenusA(a6)
	move.l	d0,(L2F056).l
	tst.l	d0
	beq.b	.C24976
	move.l	d0,a0
	move.l	(MainVisualInfo).l,a1
	lea	(prefs_menutags1).l,a2
	move.l	(GadToolsBase-DT,a4),a6
	jsr	_LVOLayoutMenusA(a6)
.C24976:
	move.l	#AsmProAsmPrefs,Prefs_wintitle
	sub.l	a0,a0
	lea	(Prefswin_taglist).l,a1
	move.l	(IntBase-DT,a4),a6
	jsr	(_LVOOpenWindowTagList,a6)
	move.l	d0,(PrefsAsmWinBase).l
	tst.l	d0
	beq.b	.ProjectPrefsWError
	move.l	(PrefsAsmWinBase).l,a0
	move.l	(L2F056).l,a1
	move.l	(IntBase-DT,a4),a6
	jsr	(_LVOSetMenuStrip,a6)
	move.l	(PrefsAsmWinBase).l,a0
	sub.l	a1,a1
	move.l	(GadToolsBase-DT,a4),a6
	jsr	_LVOGT_RefreshWindow(a6)

	bsr	ProjectPrefswinRender

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
	movem.l d0-d5/a0-a2/a6,-(sp)
	move.l	(PrefsAsmWinBase).l,a0

	move.l  MainVisualInfo,NR+4
	move.l  GadToolsBase,a6
	
	move.l  (PrefsAsmWinBase).l,a0

	moveq.l	#0,d0
	move.b	54(a0),d0
	add.b	56(a0),d0
	move.w	8(a0),d2	;br
	sub.w	d0,d2

	moveq.l	#0,d0
	move.b	55(a0),d0
	add.b	57(a0),d0
	move.w	10(a0),d3	;hg
	sub.w	d0,d3

	moveq.l	#0,d0
	move.b	54(a0),d0	;x
	moveq.l	#0,d1
	move.b	55(a0),d1	;y

	move.l  50(a0),a0
	lea.l   NR,a1	;taglist

	jsr     _LVODrawBevelBoxA(a6)

	movem.l (sp)+,d0-d5/a0-a2/a6
	rts


CreatePrefsMsgport:
	move.l	(4).w,a6
	jsr	(_LVOCreateMsgPort,a6)
	lea	(Variable_base).l,a4
	move.l	d0,(Prefs_msgport).l
	tst.l	d0
	beq.b	.fail
	move.l	(PrefsAsmWinBase).l,a0
	move.l	($0056,a0),(L2F148-DT,a4)
	move.l	d0,($0056,a0)
	moveq	#0,d0
	or.l	#$00000344,d0
	move.l	(IntBase-DT,a4),a6
	jsr	(_LVOModifyIDCMP,a6)
	lea	(Variable_base).l,a4
	sub.l	a1,a1
	move.l	(PrefsAsmWinBase).l,a0
	move.l	(GadToolsBase-DT,a4),a6
	jsr	(_LVOGT_RefreshWindow,a6)		; ***
	moveq.l	#0,d0
	rts

.fail:
	moveq	#1,d0
	rts

RemovePrefsmsgPort:
	lea	(Variable_base).l,a4
	cmp.l	#0,(Prefs_msgport).l
	beq.b	.nomsgport
	move.l	(Prefs_msgport).l,a0
	move.l	(4).w,a6
	jsr	(_LVODeleteMsgPort,a6)
	lea	(Variable_base).l,a4
	move.l	(PrefsAsmWinBase).l,a0
	move.l	(L2F148-DT,a4),($0056,a0)
.nomsgport:
	rts


;*********** OPEN SYNTAX COLOR PREFS WIN ************

OpenSyntColsWin:
	movem.l	d1-d4/a0-a3/a5/a6,-(sp)

	move.w	(Scr_NrPlanes-DT,a4),SyntNrCols1
	move.w	(Scr_NrPlanes-DT,a4),SyntNrCols2
	lea	synt_gadspos,a0
	lea	Synt_prefs_gadstr,a1
	moveq.l	#synt_gadcount-1,d7
	jsr	pos_gadgets

	move.l	(ScreenBase).l,a0
	moveq	#0,d3
	moveq	#0,d2
	move.b	($0024,a0),d2	;wborder links
	move.l	($0028,a0),a1	;font ptr
	move	(4,a1),d3
	addq.w	#1,d3
	add.b	($0023,a0),d3	;wbortop
	lea	(Prefs_GList).l,a0
	move.l	(GadToolsBase-DT,a4),a6
	jsr	(_LVOCreateContext,a6)		; ***
	move.l	d0,a3
	tst.l	d0
	beq	.ProjectPrefsCError
	movem.w	d2/d3,-(sp)
	moveq	#0,d3
	lea	(Prefs_SyntGadTags).l,a5
.C24860:
	lea	(Synt_prefs_gadstr).l,a0
	move.l	d3,d0
	mulu	#30,d0
	add.l	d0,a0
	lea	(GadgetBuffer).l,a1
	moveq	#30,d0
	move.l	(4).w,a6
	jsr	(_LVOCopyMem,a6)

	lea	(GadgetBuffer).l,a0
	move.l	(MainVisualInfo).l,($0016,a0)
	move.l	#Editor_Font,(12,a0)
	move	(a0),d0
	add	(sp),d0
	move	d0,(a0)
	move	(2,a0),d0
	add	(2,sp),d0
	move	d0,(2,a0)
	lea	(Pref_SyntGadgetTypes).l,a0
	moveq	#0,d0
	move.l	d3,d1
	asl.l	#1,d1
	add.l	d1,a0
	move	(a0),d0
	move.l	a3,a0
	lea	(GadgetBuffer).l,a1
	move.l	a5,a2
	move.l	(GadToolsBase-DT,a4),a6
	jsr	_LVOCreateGadgetA(a6)
	tst.l	d0
	beq	.C249C8
	move.l	d0,a3
	move.l	d3,d0
	asl.l	#2,d0
	lea	(Prefs_Gadgets).l,a0
	add.l	d0,a0
	move.l	a3,(a0)
.C248E2:
	cmp.l	#-1,(a5)+
	beq.b	.C248EC
	bra.b	.C248E2

.C248EC:
	addq.w	#1,d3
	cmp	#synt_gadcount,d3	;5
	bmi.w	.C24860

	movem.w	(sp)+,d2/d3

	move.l	(Prefs_GList).l,(L1DAE2).l
	move.l	(ScreenBase).l,(ScreenBaseTemp1).l
	moveq	#0,d0
	move	(W1D00E).l,d0
	move.l	d0,(L1DAB2).l
	move	(W1D010).l,d0
	move.l	d0,(L1DABA).l
	move	(Prefs_win_br2).l,d0
	move.l	d0,(Prefs_winbreedt).l
	move	(Prefs_win_hg2).l,d0
	add	d3,d0
	move.l	d0,(Prefs_winhoog).l
	lea	(Prefs_newmenustr).l,a0
	lea	(prefs_menutags2).l,a1
	move.l	(GadToolsBase-DT,a4),a6
	jsr	_LVOCreateMenusA(a6)
	move.l	d0,(L2F056).l
	tst.l	d0
	beq.b	.C24976
	move.l	d0,a0
	move.l	(MainVisualInfo).l,a1
	lea	(prefs_menutags1).l,a2
	move.l	(GadToolsBase-DT,a4),a6
	jsr	_LVOLayoutMenusA(a6)
.C24976:
	move.l	#AsmProSyntPrefs,Prefs_wintitle
	sub.l	a0,a0
	lea	(Prefswin_taglist).l,a1
	move.l	(IntBase-DT,a4),a6
	jsr	(_LVOOpenWindowTagList,a6)
	move.l	d0,(PrefsAsmWinBase).l
	tst.l	d0
	beq.b	.ProjectPrefsWError

;	move.l	(PrefsAsmWinBase).l,a0
	move.l	d0,a0
	move.l	$0032(a0),PrefsRastport

	move.l	(L2F056).l,a1
	move.l	(IntBase-DT,a4),a6
	jsr	(_LVOSetMenuStrip,a6)
	move.l	(PrefsAsmWinBase).l,a0
	sub.l	a1,a1
	move.l	(GadToolsBase-DT,a4),a6
	jsr	_LVOGT_RefreshWindow(a6)

	bsr	ProjectPrefswinRender

	bsr	ShowPrevSource

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
	move.l	a4,-(sp)

	move.w	(EFontSize_x-DT,a4),d5
	move.w	(EFontSize_y-DT,a4),d6
	addq.w	#3,d6

	move.l	(IntBase-DT,a4),a6
	lea	TheColors(pc),a4
	lea	.TestSource(pc),a5
	lea	.TestISource(pc),a3

	moveq.l	#19-1,d7
.lopje:
	moveq.l	#0,d0
	move.b	(a5)+,d0
	move.b	0(a4,d0.w),0(a3)	;front
	move.b	1(a4,d0.w),1(a3)	;back
;	move.b	(a5)+,2(a3)	;drawmode

	moveq.l	#0,d0
	move.b	(a5)+,d0
	mulu.w	d5,d0		;x
	moveq.l	#0,d1
	move.b	(a5)+,d1
	mulu.w	d6,d1		;y
	add.w	Scr_Title_sizeTxt,d1

	move.l	a5,12(a3)	;drawmode


	move.l	PrefsRastport(pc),a0
	lea	(a3),a1
	jsr	_LVOPrintIText(a6)


.next:
	tst.b	(a5)+
	bne.s	.next

	dbf	d7,.lopje

	move.l	(sp)+,a4
	rts


.TestISource:
	dc.b	1,0	;front/back pen
	dc.b	1	;drawmode
	dc.b	0	;nix
	dc.w	0,0	;left/top
	dc.l	0	;font
	dc.l	0	;text
	dc.l	0	;next
	

.TestSource:
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
	dc.b	OPCODECOLR,29,07,'bsr.w',0			; *** was brs
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


	cnop	0,4
PrefsRastport:	dc.l	0

SyntItemIndex:	dc.w	0


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



;**************** EINDE SYNTCOLS WIN ****************


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
	dc.b	'+RL',$A
	dc.b	'+SM',$A
	dc.b	'+.S',$A
	dc.b	'+AU',$A
	dc.b	'-PD',$A
	dc.b	'-WF',$A
	dc.b	'+RR',$A
	dc.b	'+SO',$A
	dc.b	'-CW',$A
	dc.b	'-PS',$A
	dc.b	'-OA',$A
	dc.b	'+DA',$A
	dc.b	'+SS',$A
	dc.b	'-EP',$A
	dc.b	'+LD',$A
	dc.b	'+RD',$A
	dc.b	'+UD',$A
	dc.b	'+KX',$A
	dc.b	'+AI',$A
	dc.b	'+XR',$A
	dc.b	'+SW',$A
	dc.b	'+SC',$A
	dc.b	'-CS',$A	;CustomScroll
	dc.b	'-WT',$A	;WaitTOF
	IF SLIDER
	dc.b	'+SL',$A	;Slider
	ENDIF
	dc.b	'-LN',$A	;LineNrs
	dc.b	'+AB',$A	;AutoBackup
	dc.b	'-AS',$A	;Autoupdate		

	dc.b	'+RS',$A
	dc.b	'+L7',$A
	dc.b	'-NL',$A
	dc.b	'+AA',$A
	dc.b	'+DB',$A
	dc.b	'-LF',$A
	dc.b	'+PG',$A
	dc.b	'+HP',$A
	dc.b	'-AE',$A
	dc.b	'+PI',$A
	dc.b	'-PL',$A
	dc.b	'+DC',$A
	dc.b	'-L:',$A
	dc.b	'-UL',$A
	dc.b	'-;C',$A
	dc.b	'-FW',$A
	dc.b	'+FP',$A
	dc.b	'-OD',$A
	dc.b	'+MP',$A

	dc.b	'-IL',$A
;	dc.b	'-1B',$A

	dc.b	'!(.s|.asm|.i)',$A
	dc.b	'*asmpro:sources/',$A
	dc.b	'|9AB|111|FFF|C06|',$A
	dc.b	'[CPU2',$A
	dc.b	'[MMU0',$A
	dc.b	'^FFFFFFFF|00000100|00000280',$A
	dc.b	'@F2000',$a
	dc.b	0

cs_txt:	dc.b	"Please set the screen width to 640 first",$a
	dc.b	" this routine will NOT work without it.",0
	cnop	0,4

wt_txt:	dc.b	"Only set this option if scrolling",$a
	dc.b	"doesn't work right as it slows down",$a
	dc.b	"editor speed.",0


;****************************************************
;**              MY DEBUG SUBROUTINES              **
;****************************************************

	IF	Debugstuff

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
	jsr	(openreqtoolslib).l
.reqopen:
	tst.l	(ReqToolsbase-DT,a4)
	beq.b	.reqerror


	move.l	a0,-(sp)
	lea	.regsbase+4*16(pc),a0
	movem.l	d0-a7,-(a0)
	move.l	(sp)+,d0
	move.l	d0,.regsbase+4*8

	lea	regstxt+4(pc),a0
	lea	.regsbase,a1
	moveq.l	#16-1,d7
.lopje:
	move.l	(a1)+,d0
	bsr	decode
	lea	5(a0),a0
	dbf	d7,.lopje

	addq.l	#1,a0
	lea	.regsbase+8*4,a1
	moveq.l	#8-1,d7
.lopje2:
	move.l	(a1)+,a2
	bsr	decode2
	lea	6(a0),a0
	dbf	d7,.lopje2

	move.l	#1,(RequesterType).l
	lea	(_Ok_Ok.MSG).l,a2
	lea	regstxt,a1
	jsr	(ShowReqtoolsRequester).l
.reqerror
	movem.l	(sp)+,d0-a6
	rts


.regsbase:
	dcb.l	16,0


decode2:
	moveq.l	#20-1,d6
.lopje
	move.b	(a2)+,d0
	cmp.b	#' ',d0
	blo.s	.nietleesbaar
	cmp.b	#$7e,d0
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
	dc.b	"D0: xxxxxxxx D1: xxxxxxxx",$a
	dc.b	"D2: xxxxxxxx D3: xxxxxxxx",$a
	dc.b	"D4: xxxxxxxx D5: xxxxxxxx",$a
	dc.b	"D6: xxxxxxxx D7: xxxxxxxx",$a
	dc.b	"A0: xxxxxxxx A1: xxxxxxxx",$a
	dc.b	"A2: xxxxxxxx A3: xxxxxxxx",$a
	dc.b	"A4: xxxxxxxx A5: xxxxxxxx",$a
	dc.b	"A6: xxxxxxxx sp: xxxxxxxx",$a

	dc.b	"(A0):....................",$a
	dc.b	"(A1):....................",$a
	dc.b	"(A2):....................",$a
	dc.b	"(A3):....................",$a
	dc.b	"(A4):....................",$a
	dc.b	"(A5):....................",$a
	dc.b	"(A6):....................",$a
	dc.b	"(sp):....................",$a

	dc.b	0

	cnop	0,4
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


;;*******************************************************
;**               DISASSEMBLER SECTION                 **
;********************************************************

	Section	disassembler,code

;gedoe:	dc.l	$F6209000
;teste:	lea	gedoe,a5

DISLENGTH_A5:
;	lea	(L2EB86-DT,a4),a0	; DISSOLVE AREA
	lea	L2EB86,a0		; DISSOLVE AREA
	move	(a5)+,d0



	moveq	#7,d1
	and	d0,d1
	add	d1,d1		; source reg
	move	d1,(a0)+	; 0 - 0000000000000xxx

	lsr.w	#2,d0
	moveq	#7<<1,d1
	and	d0,d1		; source mode
	move	d1,(a0)+	; 1 - 0000000000xxx000

	lsr.w	#3,d0
	moveq	#7<<1,d1
	and	d0,d1		; dest mode
	move	d1,(a0)+	; 2 - 0000000xxx000000

	moveq	#3<<1,d1
	and	d0,d1		
	move	d1,(a0)+	; 3 - 00000000xx000000

	lsr.w	#2,d0
	moveq	#1<<1,d1
	and	d0,d1
	move	d1,(a0)+	; 4 - 0000000x00000000

	moveq	#15<<1,d1
	and	d0,d1
	move	d1,(a0)+	; 5 - 0000xxxx00000000

	lsr.w	#1,d0
	moveq	#7<<1,d1
	and	d0,d1
	move	d1,(a0)+	; 6 - 0000xxx000000000

	lsr.w	#3,d0
	moveq	#15<<1,d1
	and	d0,d1
	move	d1,(a0)+	; 7 - xxxx000000000000

	move	(a5),d0
	move	d0,(a0)+	; 8 - volgende word

	moveq	#14,d1
	lsr.w	#8,d0
	and	d1,d0
	move	d0,(a0)+
	move	(a5),d0
	move	d0,d1
	rol.w	#3,d1
	and	#6,d1
	move	d1,(a0)+
	move	d0,d1
	lsr.w	#6,d1
	and	#14,d1
	move	d1,(a0)+
	move	d0,d1
	and	#$003F,d0
	add	d0,d0
	move	d0,(a0)+
	rol.w	#7,d1
	move	d1,d0
	and	#14,d1
	move	d1,(a0)+
	lsr.w	#3,d0
	and	#2,d0
	move	d0,(a0)
	lea	(L2EB86-DT,a4),a0
	move	($0018,a0),d0
	and	#$00FE,d0
	move	d0,($001E,a0)
	lea	(DisAsmblStuff,pc),a1
.lopje:
	move	(a1)+,d0
	add	(a0,d0.w),a1
	add	(a1),a1
	tst.b	(a1)
	beq.b	.lopje

	cmp.l	#NM_UKN,a1
	beq.b	.UNKNOWN

	add	#11,a1
	move.b	(a1)+,d2
	moveq	#2,d1

	move.b	(a1)+,d0
	beq.b	.NO_OPERANDS
	bsr.b	.CALC_OPERAND
	moveq	#0,d0
	move.b	(a1)+,d0
	beq.b	.NO_OPERANDS
	bsr.b	.CALC_OPERAND
.NO_OPERANDS:
	tst	d1
	rts

.UNKNOWN:
	moveq	#0,d1
	rts

.CALC_OPERAND:
	tst.b	d0
	bmi.b	.NEGATIVE
	move	(a0),d5	;BIT_0_2	;source register
	move	(2,a0),d6	;BIT_3_5	;source mode
	bra.b	.GO_PRINT

.NEGATIVE:
	move	(12,a0),d5	;BIT_9_B	;dest reg
	move	(4,a0),d6	;BIT_6_8	;dest mode
.GO_PRINT:
	and.w	#$f,d5
	lsr.w	#1,d5
	add.b	d0,d0
	ext.w	d0
	tst	d0
	bpl.b	.pos
	and	#$00FF,d0
.pos:
	add	(.JUMP_TABEL,pc,d0.w),d0
	jmp	(.JUMP_TABEL,pc,d0.w)

.JUMP_TABEL:
	dc.w	LEN_NONE-.JUMP_TABEL
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
	dc.w	C1FBFA-*
	dc.w	C1FC22-*
	dc.w	C1FC52-*
	dc.w	C1FC56-*	;30
	dc.w	C1FC9E-*
	dc.w	LEN_NUM_B-*
	dc.w	C1FCD4-*
	dc.w	C1FD02-*
	dc.w	LEN_NUM_B-*	;35
	dc.w	LEN_NUM_B-*
	dc.w	C1FD38-*
	dc.w	LEN_NormFloatOpp-*
	dc.w	LEN_NormFloatOpp-*
	dc.w	LEN_NormFloatEA-*	;40
	dc.w	LEN_FloatOpp-*
	dc.w	LEN_NUM_L-*
	dc.w	LEN_FloatOpp-*
	dc.w	LEN_NUM_L-*
	dc.w	C1FE22-*	;45
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
	dc.w	C1FB3E-*
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




LEN_MOVE16:	addq.w	#2,a5
	addq.w	#2,d1
	btst	#3,(3,a0)
	bne	LEN_finish		;beq
	addq.w	#2,d1
	addq.w	#2,a5
	rts

C1FB3E:
	addq.w	#2,d1
	addq.w	#2,a5
	move	(a5),($0010,a0)
	cmp	#14,(2,a0)
	bne.b	LEN_NormFloatEA
	cmp	#8,(a0)
	bne.b	LEN_NormFloatEA
	move	#0,($001A,a0)
	bra.b	LEN_NormFloatEA

LEN_FloatOpp:
	addq.w	#2,d1
	addq.w	#2,a5
	move	(a5),($0010,a0)
	bra.b	LEN_NormFloatEA

LEN_NormFloatOpp:
	addq.w	#2,d1
	addq.w	#2,a5
	move	(a5),($0010,a0)
	btst	#1,($0015,a0)
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
	move	($001A,a0),d0	;WORD2 12-10
	lsr.w	#1,d0
	tst	d0
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

C1FBFA:
	addq.w	#2,d1
	addq.w	#2,a5
	move	(a5),d0
	ror.w	#8,d0
	and	#14,d0
	move	d0,($0012,a0)
	move	(a5),($0010,a0)
	cmp	#8,d6
	ble.w	LEN_NONE
	cmp	#12,d6
	blt.w	LEN_NUM_B
	br	C1FD4E

C1FC22:
	addq.w	#2,d1
	addq.w	#2,a5
	cmp	#8,d6
	ble.w	LEN_NONE
	cmp	#12,d6
	blt.w	LEN_NUM_B
	move	(a5),d0
	btst	#8,d0
	beq	LEN_NUM_B
	move	d0,($0010,a0)
	ror.w	#8,d0
	and	#14,d0
	move	d0,($0012,a0)
	br	C1FD4E

C1FC52:
	br	LEN_NUM_L

C1FC56:
	addq.w	#2,a5
	addq.w	#2,d1
	cmp	#8,d6
	ble.w	LEN_NONE
	cmp	#12,d6
	blt.w	LEN_NUM_B
	cmp	#14,d6
	blt.w	LEN_NUM_L
	cmp	#4,d5
	beq	LEN_NUM_B
	cmp	#6,d5
	beq	LEN_VALUE_B_ADDR_XREG2
	move	(a5),d0
	btst	#8,d0
	beq	LEN_NUM_B
	move	d0,($0010,a0)
	ror.w	#8,d0
	and	#14,d0
	move	d0,($0012,a0)
	br	C1FD4E

C1FC9E:
	addq.w	#2,a5
	addq.w	#2,d1
	cmp	#8,d6
	ble.w	LEN_NONE
	cmp	#12,d6
	blt.w	LEN_NUM_B
	move	(a5),d0
	cmp	#4,d5
	beq	LEN_NUM_L
	btst	#8,d0
	beq	LEN_NUM_B
	move	d0,($0010,a0)
	ror.w	#8,d0
	and	#14,d0
	move	d0,($0012,a0)
	bra.b	C1FD4E

C1FCD4:
	addq.w	#2,a5
	addq.w	#2,d1
	cmp	#8,d6
	ble.w	LEN_NONE
	cmp	#12,d6
	blt.w	LEN_NUM_B
	move	(a5),d0
	btst	#8,d0
	beq	LEN_NUM_B
	move	d0,($0010,a0)
	ror.w	#8,d0
	and	#14,d0
	move	d0,($0012,a0)
	bra.b	C1FD4E

C1FD02:
	addq.l	#2,d1
	addq.l	#2,a5
	cmp	#8,d6
	ble.w	LEN_NONE
	cmp	#12,d6
	blt.w	LEN_NUM_B
	move	(a5),d0
	cmp	#4,d5
	beq	LEN_NUM_L
	btst	#8,d0
	beq	LEN_NUM_B
	move	d0,($0010,a0)
	ror.w	#8,d0
	and	#14,d0
	move	d0,($0012,a0)
	bra.b	C1FD4E

C1FD38:
	cmp	#8,d6
	beq	LEN_NONE
	cmp	#4,d6
	beq	LEN_NUM_B
	br	LEN_NUM_L


C1FD4E:
	addq.w	#2,d1
	addq.w	#2,a5
	move	($0010,a0),d5
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
	move	($0010,a0),d5
	and	#3,d5
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

LEN_NUM_B:
LEN_NUM_W:
LEN_VALUE_W_ADDR:
LEN_VALUE_B_ADDR_XREG:
LEN_BRANCH_W:
LEN_VALUE_W:
LEN_VALUE_W_PC:
LEN_VALUE_B_PC_XREG:
	addq.w	#2,d1
	addq.w	#2,a5
	rts

LEN_VALUE_B_ADDR_XREG2:
	move	(4,a0),d5	;bits 6_8
	cmp.w	#%1100,d5
	beq.s	.ext

	move	(16,a0),d5	;2de word
	btst	#8,d5
	bne	C1FD4E
.ext:
	addq.w	#2,d1
	addq.w	#2,a5
	rts

LEN_NUM_L:
	addq.w	#4,d1
	addq.w	#4,a5
	rts

;LEN_ABS_L:
;	jsr	test_debug
;	addq.w	#6,d1
;	addq.w	#6,a5
;	rts
	
C1FE22:
	addq.w	#6,d1
	addq.w	#6,a5
	rts

LEN_BRANCH_B:
	tst.b	(-1,a5)
	beq.b	LEN_NUM_B
	cmp	#2,(ProcessorType-DT,a4)
	blt.b	.geen020plus
	cmp.b	#$FF,(-1,a5)	;32 bits displacement
	bne.b	.geen020plus

	addq.w	#4,a5	;was 6
	addq.w	#4,d1	;was 6
.geen020plus:
	rts

Diss_zetom2ascii:
	bsr.b	C1FE7E
	clr.b	(B29B92-DT,a4)
	cmp	#10,d1
	ble.b	C1FE58
	moveq	#10,d1
	move.b	#$BB,(B29B92-DT,a4)
C1FE58:
	moveq	#10,d3
	sub	d1,d3
	lea	(DIS_PRINT_BUFFER_0-DT,a4),a3
	move.l	a3,a0
C1FE62:
	move	(a1)+,d0
	bsr	Zet_D0_Om2_inA3
	subq.w	#2,d1
	bne.b	C1FE62
	add	d3,d3
.aanvullen:
	cmp.b	#$BB,(a3)
	beq.b	.klaar
	move.b	#' ',(a3)+
	dbra	d3,.aanvullen
.klaar:
	rts

C1FE7E:
	lea	(B29B93-DT,a4),a3	;Outputbuffer for complete disassembly
	lea	(L2EB86-DT,a4),a0	;Outputbuffer for temp. dissasembly

	move.l	a5,-(sp)
	move	(a5)+,d0
	moveq	#7,d1
	and	d0,d1
	add	d1,d1
	move	d1,(a0)+
	lsr.w	#2,d0
	moveq	#14,d1
	and	d0,d1
	move	d1,(a0)+
	lsr.w	#3,d0
	moveq	#14,d1
	and	d0,d1
	move	d1,(a0)+
	moveq	#6,d1
	and	d0,d1
	move	d1,(a0)+
	lsr.w	#2,d0
	moveq	#2,d1
	and	d0,d1
	move	d1,(a0)+
	moveq	#$1E,d1
	and	d0,d1
	move	d1,(a0)+
	lsr.w	#1,d0
	moveq	#14,d1
	and	d0,d1
	move	d1,(a0)+
	lsr.w	#3,d0
	moveq	#$1E,d1
	and	d0,d1
	move	d1,(a0)+
	move	(a5),d0
	move	d0,(a0)+
	moveq	#14,d1
	lsr.w	#8,d0
	and	d1,d0
	move	d0,(a0)+
	move	(a5),d0
	move	d0,d1
	rol.w	#3,d1
	and	#6,d1
	move	d1,(a0)+
	move	d0,d1
	lsr.w	#6,d1
	and	#14,d1
	move	d1,(a0)+
	move	d0,d1
	and	#$00FF,d0
	add	d0,d0
	move	d0,(a0)+
	rol.w	#7,d1
	move	d1,d0
	and	#14,d1
	move	d1,(a0)+
	lsr.w	#3,d0
	and	#2,d0
	move	d0,(a0)
	lea	(L2EB86-DT,a4),a0
	move	($0018,a0),d0
	and	#$00FE,d0
	move	d0,($001E,a0)
	lea	(DisAsmblStuff,pc),a1

C1FF18:
	move	(a1)+,d0
	add	(a0,d0.w),a1
	add	(a1),a1
	tst.b	(a1)
	beq.b	C1FF18
	moveq	#10,d1
	moveq	#$63,d2
	moveq	#$7A,d3
	moveq	#$71,d4
	moveq	#$78,d5
	
;Support for dbf.l (encoded in the low bit of the adress

	clr.w	DBCC
	move.l	(a1),d0
	cmp.l	#'DBcc',d0
	bne.b	.no
	move.w	#1,DBCC

.no
;Start disassembling
C1FF2E:
	move.b	(a1)+,d0
	cmp.b	d3,d0
	bne.b	C1FF50
	moveq	#$57,d0
	tst.b	(-1,a5)
	beq.b	C1FF50
	moveq	#$42,d0
	cmp	#2,(ProcessorType-DT,a4)
	blt.b	C1FF50
	cmp.b	#$FF,(-1,a5)
	bne.b	C1FF50
	moveq	#$4C,d0
C1FF50:
	cmp.b	d2,d0
	bne.b	C1FF66
	lea	(TFHILSCCCSNEE.MSG,pc),a2
	add	(10,a0),a2
	move.b	(a2)+,d0
	move.b	d0,(a3)+
	move.b	(a2)+,d0
	addq.w	#1,a1
	subq.w	#1,d1
C1FF66:
	cmp.b	d5,d0
	bne.b	C1FF72
	lea	(BSBCLSLCSSSCA.MSG,pc),a2
	moveq	#$1E,d6
;	jsr	test_debug

	bra.b	C1FF7E

C1FF72:
	cmp.b	d4,d0
	bne	C20008
	moveq	#$7E,d6
	lea	(FEQOGTOGEOLTO.MSG,pc),a2
;	jsr	test_debug

C1FF7E:
	cmp.b	#$42,(B29B94-DT,a4)
	bne.b	C1FF94
	move	(2,a0),d0
	lsl.w	#3,d0
	add	(a0),d0
	and	d6,d0
	bra.b	C1FF9A

C1FF94:
	move	($0018,a0),d0
	and	d6,d0
C1FF9A:
	cmp.b	#$2E,(a1)
	bne.b	C1FFA2
	moveq	#$43,d2
C1FFA2:
	add	d0,d0
	add	d0,a2
	move.b	(a2)+,d0
	move.b	d0,(a3)+
	move.b	(a2)+,d0
	cmp.b	#$20,d0
	beq.b	C1FFD4
	move.b	d0,(a3)+
	subq.w	#1,d1
	addq.w	#1,a1
	move.b	(a2)+,d0
	cmp.b	#$20,d0
	beq.b	C1FFD4
	move.b	d0,(a3)+
	subq.w	#1,d1
	addq.w	#1,a1
	move.b	(a2)+,d0
	cmp.b	#$20,d0
	beq.b	C1FFD4
	move.b	d0,(a3)+
	subq.w	#1,d1
	addq.w	#1,a1
C1FFD4:
	cmp.b	#$43,d2
	bne.b	C2000A
	moveq	#$63,d2
	sub	#2,d1
	add	#2,a1
	moveq	#$2E,d0
	move.b	d0,(a3)+
	moveq	#$57,d0
	cmp.b	#$54,(B29B94-DT,a4)
	bne.b	C1FFFE
	cmp	#6,(a0)
	bne.b	C20008
	moveq	#$4C,d0
	bra.b	C20008

C1FFFE:
	btst	#1,(7,a0)
	beq.b	C20008
	moveq	#$4C,d0
C20008:
	move.b	d0,(a3)+
C2000A:
	dbra	d1,C1FF2E

	moveq	#$20,d0
	move.b	d0,(a3)+
	move.b	(a1)+,-(sp)
	move.b	(a1)+,d0
	beq.b	C2002C
	move.b	(a1),-(sp)
	bsr	C20140		;Parse and write first op (dbf "d0",adress)
	move.b	(sp)+,d1
	beq.b	C2002C
	moveq	#',',d0
	move.b	d0,(a3)+	
	move.b	d1,d0
	bsr	C20140		;Parse and write second op (dbf d0,"adress")
	move.w	DBCC(pc),d0
	beq.b	.no
	;check for odd adress.
	move.w	-2(a3),d0

	btst.l	#0,d0
	beq.b	.no

	and.b	#$fe,d0
	move.w	d0,-2(a3)	;correct even adress
	;Here we have dbcc.l
	cmp.b	#' ',-21(a3)
	bne.b	.four
	move.w	#'.L',-21(a3)	;correct Size (dbf.l)
	bra.b	.no
.four
	move.w	#'.L',-20(a3)	;correct Size (dbcs.l)
.no

C2002C:
	clr.b	(a3)
	btst	#SB2_INSERTINSOURCE,(SomeBits2-DT,a4)
	bne.b	C20046
	tst.b	(B29BC4-DT,a4)
	beq.b	C20046
	
	move.b	#$BB,(B29BC3-DT,a4)
	clr.b	(B29BC4-DT,a4)
C20046:
	lea	(B29B93-DT,a4),a0
	move.l	a5,d1
	move.b	(sp)+,d2
	cmp.b	#2,d2
	bne.b	C2005A
	move.b	#1,(B30173-DT,a4)
C2005A:
	move.l	(sp)+,a1
	sub.l	a1,d1
	rts

DBCC:	dc.w	0

TFHILSCCCSNEE.MSG:
	dc.b	'T F HILSCCCSNEEQVCVSPLMIGELTGTLE'
FEQOGTOGEOLTO.MSG:
	dc.b	'F   EQ  OGT OGE OLT OLE OGL OR  UN  UEQ UGT UGE ULT '
	dc.b	'ULE NE  T   SF  SEQ GT  GE  LT  LE  GL  GLE NGLENGL '
	dc.b	'NLE NLT NGE NGT SNE ST  '
BSBCLSLCSSSCA.MSG:
	dc.b	'BS  BC  LS  LC  SS  SC  AS  AC  WS  WC  IS  IC  GS  '
	dc.b	'GC  CS  CC  '

C20140:
;		jsr	test_debug
	tst.b	d0
	bmi.b	C2014E
	move	(a0),d5	;WORD1 bits2-0
	move	(2,a0),d6	;WORD1 bits5-3
	bra.b	C20156

C2014E:
	move	(12,a0),d5	;WORD1 bits11-9
	move	(4,a0),d6	;WORD1 bits 8-6
C20156:
	btst	#0,d5		;test op extra extention word
;	beq.w	.nop
;.nop:

	lsr.w	#1,d5
	add.b	d0,d0
	ext.w	d0
	tst	d0
	bpl.b	C20164
	and	#$00FF,d0
C20164:

	add	(DisJumpTab,pc,d0.w),d0
	jmp	(DisJumpTab,pc,d0.w)

DisJumpTab:
	dc.w	DisNoOp-*	;0000000 0
	dc.w	C21342-*	;0000001
	dc.w	C21390-*	;0000010
	dc.w	C213DC-*	;0000011
	dc.w	C217D6-*	;0000100
	dc.w	C217E4-*	;0000101
	dc.w	C2173E-*	;0000110
	dc.w	DisDataReg-*	;0000111
	dc.w	DisAdresReg-*	;0001000
	dc.w	DisValueWAdrReg-*	;0001001
	dc.w	C21826-*	;0001010
	dc.w	C2184A-*	;0001011
	dc.w	C21800-*	;0001100
	dc.w	C2180A-*	;0001101
	dc.w	C21818-*	;0001110
	dc.w	DisMinAdrInd-*	;0001111
	dc.w	DisAdrIndPlus-*	;0010000 16
	dc.w	C21868-*	;0010001
	dc.w	C2185E-*	;0010010
	dc.w	C2187A-*	;0010011
	dc.w	C218AA-*	;0010100
	dc.w	C2188A-*	;0010101
	dc.w	C2138E-*	;0010110
	dc.w	C2189E-*	;0010111
	dc.w	C21298-*	;0011000
	dc.w	C21288-*	;0011001 25
	dc.w	C2127A-*	;0011010
	dc.w	C21220-*	;0011011
	dc.w	C211C4-*	;0011100
	dc.w	C21148-*	;0011101
	dc.w	DisCmp2-*	;0011110
	dc.w	C21094-*	;0011111
	dc.w	C20ECC-*	;0100000 32
	dc.w	C20E60-*	;0100111
	dc.w	C20DE4-*	;0101000
	dc.w	C20D6E-*	;0101001
	dc.w	C20D56-*	;0101010
	dc.w	C20D06-*	;0101011
	dc.w	C20C74-*	;0101110
	dc.w	C20C52-*	;0110001
	dc.w	C20C06-*	;0110000 40
	dc.w	C20BFA-*	;0110011
	dc.w	C21854-*	;0110010
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
	dc.w	C205FE-*	;0000101
	dc.w	C20572-*	;0000110
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
	dc.w	C20200-*	;72

	dc.w	disfix-*

DisNoOp:
	rts

C20200:
	move	(2,a0),d0
	and	#7,d0
	cmp	#4,d0
	bgt.b	C2021E
	bsr.b	C2021E
	moveq	#$2C,d0
	move.b	d0,(a3)+
	move	(a0),d5
	lsr.w	#1,d5
	br	DisAdrIndirect

C2021E:
	move	(6,a0),d0
	cmp	#2,d0
	beq.b	C20234
	cmp	#4,d0
	beq.b	C2023A
	moveq	#$42,d0
	move.b	d0,(a3)+
	bra.b	C2023E

C20234:
	moveq	#$44,d0
	move.b	d0,(a3)+
	bra.b	C2023E

C2023A:
	moveq	#$49,d0
	move.b	d0,(a3)+
C2023E:
	moveq	#$43,d0
	move.b	d0,(a3)+
	rts

DisPmoveq:
	addq.w	#2,a5
	btst	#3,($0017,a0)
	bne.b	C2026E
	bsr	C213DC
	move.b	#$2C,(a3)+
C20256:
	move	($001A,a0),d0
	cmp	#2,d0
	beq	C21014
	cmp	#4,d0
	beq	DisSRP
	br	C2101A

C2026E:
	pea	(C20274,pc)
	bra.b	C20256

C20274:
	move.b	#$2C,(a3)+
	br	C213DC

DisPmoveb:
	addq.w	#2,a5
	btst	#3,($0017,a0)	;BIT_9_7
	bne.b	C202A6
	bsr	C213DC
	move.b	#$2C,(a3)+
C2028E:
	move	($001A,a0),d0
	cmp	#8,d0
	beq	C20FA4
	cmp	#10,d0
	beq	C20FAA
	br	C20FB8

C202A6:
	pea	(C202AC,pc)
	bra.b	C2028E

C202AC:
	move.b	#$2C,(a3)+
	br	C213DC

DisPmovel:
	addq.w	#2,a5
	btst	#3,($0017,a0)
	bne.b	C202E4
	bsr	C213DC
	move.b	#$2C,(a3)+
C202C6:
	move	($001A,a0),d0
	tst	d0
	bne.b	C202D8
	moveq	#$54,d0
	move.b	d0,(a3)+
	moveq	#$43,d0
	move.b	d0,(a3)+
	rts

C202D8:
	cmp	#4,d0
	beq	C20F8A
	br	C20F78

C202E4:
	bsr.b	C202C6
	move.b	#$2C,(a3)+
	br	C213DC

DisPmovew:
	addq.w	#2,a5
	btst	#3,($0017,a0)
	bne.b	C20328
	bsr	C213DC
	move.b	#$2C,(a3)+
	move	($001A,a0),d0
	beq.b	C2031A
	cmp	#8,d0
	beq	C20FC6
	cmp	#10,d0
	beq	C20FD4
	br	C20FEE

C2031A:
	tst.b	(PR_MMU).l
	beq	DisMMUSR
	br	C20FF8

C20328:
	move	($001A,a0),d0
	beq.b	C20346
	pea	(C20358,pc)
	cmp	#8,d0
	beq	C20FC6
	cmp	#10,d0
	beq	C20FD4
	br	C20FEE

C20346:
	tst.b	(PR_MMU).l
	beq.b	C20354
	bsr	C20FF8
	bra.b	C20358

C20354:
	bsr	DisMMUSR
C20358:
	move.b	#$2C,(a3)+
	br	C213DC

C20360:
	addq.w	#2,a5
	move	($001E,a0),d0
	lsr.w	#1,d0
	and	#$001F,d0
	tst	d0
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
	move	d0,d5
	and	#7,d5
	bsr	DisDataReg
	move	(a0),d5
	lsr.w	#1,d5
	bra.b	C2039E

C2039A:
	bsr	C204DE
C2039E:
	move.b	#$2C,(a3)+
	bsr	C213DC
	tst	($001A,a0)
	beq.b	C203D8
C203AC:
	move.b	#$2C,(a3)+
	move.b	#$23,(a3)+
	move	($001A,a0),d0
	lsr.w	#1,d0
	bsr	Zet_D0_Om3_inA3
	move	($0018,a0),d5
	lsr.w	#6,d5
	btst	#2,($0017,a0)
	beq	C203D6
	move.b	#$2C,(a3)+
	br	DisAdresReg

C203D6:
	rts

C203D8:
	btst	#2,($0017,a0)
	bne.b	C203AC
	rts

C203E2:
	addq.w	#2,a5
	rts

C203E6:
	addq.w	#2,a5
	pea	(C213DC,pc)
	move	($001E,a0),d0
	lsr.w	#1,d0
	tst	d0
	bne.b	C20400
	bsr	C2105C
	move.b	#$2C,(a3)+
	rts

C20400:
	subq.w	#1,d0
	bne.b	C2040E
	bsr	C21062
	move.b	#$2C,(a3)+
	rts

C2040E:
	btst	#4,d0
	bne.b	C2042E
	move	($001E,a0),d5
	lsr.w	#1,d5
	and	#7,d5
	bsr	DisDataReg
	move	(a0),d5
	lsr.w	#1,d5
	move.b	#$2C,(a3)+
	rts

C2042E:
	move	($001E,a0),d0
	lsr.w	#1,d0
	bsr	C204D4
	move.b	#$2C,(a3)+
	rts

C2043E:
	addq.w	#2,a5
	pea	(C213DC,pc)
	move	($001A,a0),d0
	btst	#1,d0
	beq.b	C20468
	move	($001E,a0),d5
	lsr.w	#1,d5
	and	#7,d5
	bsr	DisAdresReg
	move.b	#$2C,(a3)+
	move	(a0),d5
	lsr.w	#1,d5
	rts

C20468:
	move.b	#$56,(a3)+
	move.b	#$41,(a3)+
	move.b	#$4C,(a3)+
	move.b	#$2C,(a3)+
	rts

C2047A:
	addq.w	#2,a5
	move	($0018,a0),d0
	lsr.w	#1,d0
	move	d0,d1
	and	#$001F,d1
	tst	d1
	beq.b	C204A6
	subq.w	#1,d1
	beq.b	C204AC
	cmp	#15,d1
	bgt.b	C204A2
	and	#7,d0
	move	d0,d5
	bsr	DisDataReg
	bra.b	C204B0

C204A2:
	bsr.b	C204DE
	bra.b	C204B0

C204A6:
	bsr	C2105C
	bra.b	C204B0

C204AC:
	bsr	C21062
C204B0:
	move.b	#$2C,(a3)+
	move	($0018,a0),d0
	lsr.w	#6,d0
	bsr.b	C204DE
	move	($001A,a0),d0
	cmp	#12,d0
	blt.b	C20502
	move.b	#$2C,(a3)+
	move	(a0),d5
	lsr.w	#1,d5
	br	C213DC

C204D4:
	and	#15,d0
	ror.w	#3,d0
	moveq	#3,d7
	bra.b	C204E6

C204DE:
	and	#7,d0
	ror.w	#2,d0
	moveq	#2,d7
C204E6:
	move.b	#$23,(a3)+
	move.b	#$25,(a3)+
C204EE:
	move.b	d0,d2
	and.b	#1,d2
	add.b	#$30,d2
	move.b	d2,(a3)+
	rol.w	#1,d0
	dbra	d7,C204EE
	ror.w	#1,d0
C20502:
	rts

C20504:
	br	DisAdrIndirect

C20508:
	rts

C2050A:
	br	DisAdrIndirect

DisMove16:
	move	(2,a0),d0	;WORD1 bits5-3
	lsr.w	#1,d0
	tst	d0
	beq.b	.AxPost_Long
	subq.w	#1,d0
	beq.b	.Long_AxPost
	subq.w	#1,d0
	beq.b	.Ax_Long
	subq.w	#1,d0
	beq.b	.Long_Ax
	addq.w	#2,a5
	move	(a0),d5	;WORD1 bits2-0
	lsr.w	#1,d5
	bsr	DisAdrIndPlus
	moveq	#',',d0
	move.b	d0,(a3)+
	move	($0010,a0),d5
	rol.w	#4,d5
	and	#7,d5
	br	DisAdrIndPlus

.Long_Ax:
	bsr	DisValueL
	moveq	#',',d0
	move.b	d0,(a3)+
	br	DisAdrIndirect

.Ax_Long:
	bsr	DisAdrIndirect
	moveq	#',',d0
	move.b	d0,(a3)+
	br	DisValueL

.Long_AxPost:
	bsr	DisValueL
	moveq	#',',d0
	move.b	d0,(a3)+
	br	DisAdrIndPlus

.AxPost_Long:
	bsr	DisAdrIndPlus
	moveq	#',',d0
	move.b	d0,(a3)+
	br	DisValueL

C20572:
	addq.w	#2,a5
	btst	#1,($001D,a0)
	beq.b	C20586
	bsr.b	C2059C
	moveq	#$2C,d0
	move.b	d0,(a3)+
	br	C20C06

C20586:
	move	($001A,a0),-(sp)
	move	#0,($001A,a0)
	bsr	C20C06
	move	(sp)+,($001A,a0)
	moveq	#$2C,d0
	move.b	d0,(a3)+
C2059C:
	move	($001A,a0),d1
	moveq	#0,d2
	btst	#3,d1
	beq.b	C205BA
	moveq	#$46,d0
	move.b	d0,(a3)+
	moveq	#$50,d0
	move.b	d0,(a3)+
	moveq	#$43,d0
	move.b	d0,(a3)+
	moveq	#$52,d0
	move.b	d0,(a3)+
	moveq	#1,d2
C205BA:
	btst	#2,d1
	beq.b	C205DA
	tst	d2
	beq.b	C205C8
	moveq	#$2F,d0
	move.b	d0,(a3)+
C205C8:
	moveq	#$46,d0
	move.b	d0,(a3)+
	moveq	#$50,d0
	move.b	d0,(a3)+
	moveq	#$53,d0
	move.b	d0,(a3)+
	moveq	#$52,d0
	move.b	d0,(a3)+
	moveq	#1,d2
C205DA:
	btst	#1,d1
	beq.b	C205FC
	tst	d2
	beq.b	C205E8
	moveq	#$2F,d0
	move.b	d0,(a3)+
C205E8:
	moveq	#$46,d0
	move.b	d0,(a3)+
	moveq	#$50,d0
	move.b	d0,(a3)+
	moveq	#$49,d0
	move.b	d0,(a3)+
	moveq	#$41,d0
	move.b	d0,(a3)+
	moveq	#$52,d0
	move.b	d0,(a3)+
C205FC:
	rts

C205FE:
	addq.w	#2,a5
	btst	#1,($001D,a0)
	beq.b	C20624
	move	($001A,a0),d0
	lsr.w	#2,d0
	tst	d0
	beq	C2071A
	subq.w	#1,d0
	beq	C206AA
	subq.w	#1,d0
	beq	C206C8
	br	C206FC

C20624:
	move	($001A,a0),d0
	lsr.w	#2,d0
	tst	d0
	beq.b	C20690
	subq.w	#1,d0
	beq.b	C20674
	subq.w	#1,d0
	beq.b	C20642
	bsr	C20C06
	moveq	#$2C,d0
	move.b	d0,(a3)+
	br	DisDataReg

C20642:
	move	(a0),d5
	lsr.w	#1,d5
	bsr	C20C06
	moveq	#$2C,d0
	move.b	d0,(a3)+
	move	($0010,a0),d5
	and	#$00FF,d5
	moveq	#0,d1
	moveq	#7,d2
C2065C:
	btst	#0,d5
	beq.b	C20666
	bset	#0,d1
C20666:
	lsr.w	#1,d5
	lsl.w	#1,d1
	dbra	d2,C2065C
	lsr.w	#1,d1
	br	C20736

C20674:
	move	(a0),d5
	lsr.w	#1,d5
	bsr	DisMinAdrInd
	moveq	#$2C,d0
	move.b	d0,(a3)+
	move	($0010,a0),d5
	lsr.w	#3,d5
	and	#7,d5
	br	DisDataReg

C20690:
	move	(a0),d5
	lsr.w	#1,d5
	bsr	DisMinAdrInd
	moveq	#$2C,d0
	move.b	d0,(a3)+
	move	($0010,a0),d1
	and	#$00FF,d1
	br	C20736

C206AA:
	pea	(C20C06,pc)
	move	($0010,a0),d5
	lsr.w	#3,d5
	and	#7,d5
	bsr	DisDataReg
	moveq	#$2C,d0
	move.b	d0,(a3)+
	move	(a0),d5
	lsr.w	#1,d5
	rts

C206C8:
	pea	(C20C06,pc)
	move	($0010,a0),d5
	and	#$00FF,d5
	moveq	#0,d1
	moveq	#7,d2
C206D8:
	btst	#0,d5
	beq.b	C206E2
	bset	#0,d1
C206E2:
	lsr.w	#1,d5
	lsl.w	#1,d1
	dbra	d2,C206D8
	lsr.w	#1,d1
	bsr	C20736
	moveq	#$2C,d0
	move.b	d0,(a3)+
	move	(a0),d5
	lsr.w	#1,d5
	rts

C206FC:
	pea	(DisMinAdrInd,pc)
	move	($0010,a0),d5
	lsr.w	#3,d5
	and	#7,d5
	bsr	DisDataReg
	moveq	#$2C,d0
	move.b	d0,(a3)+
	move	(a0),d5
	lsr.w	#1,d5
	rts

C2071A:
	pea	(DisMinAdrInd,pc)
	move	($0010,a0),d1
	and	#$00FF,d1
	bsr	C20736
	moveq	#$2C,d0
	move.b	d0,(a3)+
	move	(a0),d5
	lsr.w	#1,d5
	rts

C20736:
	move	#$FFFF,(W207D0).l
	moveq	#0,d2
	moveq	#7,d5
C20742:
	btst	#0,d1
	beq.b	C2075A
	cmp	#$FFFF,(W207D0).l
	beq.b	C207A8
	bgt.b	C20772
	moveq	#$2F,d0
	move.b	d0,(a3)+
	bra.b	C207A8

C2075A:
	cmp	#$FFFF,(W207D0).l
	ble.b	C207C6
	moveq	#$2F,d0
	move.b	d0,(a3)+
	move	#$FFFF,(W207D0).l
	bra.b	C207C6

C20772:
	btst	#1,d1
	bne.b	C207C6
	subq.w	#1,d2
	cmp	(W207D0).l,d2
	beq.b	C20788
	moveq	#$2D,d0
	move.b	d0,(a3)+
	bra.b	C2078C

C20788:
	moveq	#$2F,d0
	move.b	d0,(a3)+
C2078C:
	addq.w	#1,d2
	moveq	#$46,d0
	move.b	d0,(a3)+
	moveq	#$50,d0
	move.b	d0,(a3)+
	move.b	d2,d0
	add.b	#$30,d0
	move.b	d0,(a3)+
	move	#$FFFE,(W207D0).l
	bra.b	C207C6

C207A8:
	moveq	#$46,d0
	move.b	d0,(a3)+
	moveq	#$50,d0
	move.b	d0,(a3)+
	move.b	d2,d0
	add.b	#$30,d0
	move.b	d0,(a3)+
	cmp	(W207D0).l,d2
	beq.b	C207C6
	move	d2,(W207D0).l
C207C6:
	addq.w	#1,d2
	lsr.w	#1,d1
	dbra	d5,C20742
	rts

W207D0:
	dc.w	0

C207D2:
	addq.w	#2,a5
	move	($0010,a0),d5
	and	#$007F,d5
	moveq	#$23,d0
	move.b	d0,(a3)+
	moveq	#$24,d0
	move.b	d0,(a3)+
	move.b	d5,d0
	bsr	Zet_D0_Om3_inA3
	moveq	#$2C,d0
	move.b	d0,(a3)+
	moveq	#$46,d0
	move.b	d0,(a3)+
	moveq	#$50,d0
	move.b	d0,(a3)+
	move	($0016,a0),d0
	lsr.w	#1,d0
	add.b	#$30,d0
	move.b	d0,(a3)+
	lea	(PhiLog102eLog.MSG,pc),a1
	lsl.w	#3,d5
	lea	(a1,d5.w),a1
	moveq	#9,d0
	move.b	d0,(a3)+
	moveq	#$3B,d0
	move.b	d0,(a3)+
	moveq	#7,d0
C20816:
	move.b	(a1)+,(a3)+
	dbra	d0,C20816
	rts

PhiLog102eLog.MSG:
	dc.b	'Phi     ????    ????    ????    ????    ????    ????'
	dc.b	'    ????    ????    ????    ????    Log10(2)e       '
	dc.b	'Log2(e) Log10(e)0.0     ????    ????    ????    ????'
	dc.b	'    ????    ????    ????    ????    ????    ????    '
	dc.b	'????    ????    ????    ????    ????    ????    ????'
	dc.b	'    ????    ????    ????    ????    ????    ????    '
	dc.b	'????    ????    ????    ????    ????    ????    ????'
	dc.b	'    ????    ????    1n(2)   1n(10)  10^0    10^1    '
	dc.b	'10^2    10^4    10^8    10^16   10^32   10^64   10^1'
	dc.b	'28  10^256  10^512  10^1024 10^2048 10^4096 '

C20A1E:
	addq.w	#2,a5
	move	($001A,a0),-(sp)
	btst	#1,($001D,a0)
	beq.b	C20A38
	addq.w	#2,sp
	bsr.b	C20A48
	moveq	#$2C,d0
	move.b	d0,(a3)+
	br	C20B82

C20A38:
	bsr	C20B82
	moveq	#$2C,d0
	move.b	d0,(a3)+
	addq.w	#2,sp
	move	#0,($001A,a0)
C20A48:
	moveq	#$46,d0
	move.b	d0,(a3)+
	moveq	#$50,d0
	move.b	d0,(a3)+
	move	($001A,a0),d0
	lsr.w	#1,d0
	subq.w	#1,d0
	beq.b	C20A6A
	subq.w	#1,d0
	beq.b	C20A64
	moveq	#$43,d0
	move.b	d0,(a3)+
	bra.b	C20A72

C20A64:
	moveq	#$53,d0
	move.b	d0,(a3)+
	bra.b	C20A72

C20A6A:
	moveq	#$49,d0
	move.b	d0,(a3)+
	moveq	#$41,d0
	move.b	d0,(a3)+
C20A72:
	moveq	#$52,d0
	move.b	d0,(a3)+
	rts

C20A78:
	addq.w	#2,a5
	bsr	C20CF0
	moveq	#$2C,d0
	move.b	d0,(a3)+
	bsr	C20B82
	moveq	#$7B,d0
	move.b	d0,(a3)+
	move	($0010,a0),d5
	lsr.w	#4,d5
	and	#7,d5
	bsr	DisDataReg
	moveq	#$7D,d0
	move.b	d0,(a3)+
	rts

DisFloatMovekFacDestD:
	addq.w	#2,a5
	moveq	#-1,d1
	bsr	C20CF0
	moveq	#$2C,d0
	move.b	d0,(a3)+
	bsr	C20B82
	move	($0010,a0),d0
	and	#$007F,d0
	beq.b	C20AD4
	moveq	#$7B,d0
	move.b	d0,(a3)+
	moveq	#$23,d0
	move.b	d0,(a3)+
	moveq	#$24,d0
	move.b	d0,(a3)+
	move	($0010,a0),d0
	and	#$007F,d0
	bsr	Zet_D0_Om3_inA3
	moveq	#$7D,d0
	move.b	d0,(a3)+
C20AD4:
	rts

C20AD6:
	addq.w	#2,a5
	bsr	C20B82
	moveq	#$7B,d0
	move.b	d0,(a3)+
	move	($0010,a0),d5
	lsr.w	#4,d5
	and	#7,d5
	bsr	DisDataReg
	moveq	#$7D,d0
	move.b	d0,(a3)+
	moveq	#-1,d1
	br	C20CEC

C20AF8:
	addq.w	#2,a5
	bsr	C20B82
	move	($0010,a0),d1
	and	#$007F,d1
	beq.b	C20B20
	moveq	#$7B,d0
	move.b	d0,(a3)+
	moveq	#$23,d0
	move.b	d0,(a3)+
	moveq	#$24,d0
	move.b	d0,(a3)+
	move	d1,d0
	bsr	Zet_D0_Om3_inA3
	moveq	#$7D,d0
	move.b	d0,(a3)+
	moveq	#-1,d1
C20B20:
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
	pea	(C20CEC).l
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
	bclr	#1,(7,a0)
	addq.w	#2,a5
	br	C217E4

C20BE4:
	addq.w	#2,a5
	move	(a0),d5
	lsr.w	#1,d5
	bsr	DisDataReg
	moveq	#$2C,d0
	move.b	d0,(a3)+
	br	C2184A

C20BF6:
	addq.w	#2,a5
	bra.b	C20C06

C20BFA:
	addq.w	#2,a5
	btst	#1,($0015,a0)
	beq	C20CF0
C20C06:
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
	btst	#1,($0015,a0)
	bne.b	C20C7E
	moveq	#$46,d0
	move.b	d0,(a3)+
	moveq	#$50,d0
	move.b	d0,(a3)+
	move	($001A,a0),d0
	moveq	#-1,d1
	lsr.w	#1,d0
	add.b	#$30,d0
	move.b	d0,(a3)+
	bra.b	C20CEC

C20C74:
	addq.w	#2,a5
	btst	#1,($0015,a0)
	beq.b	C20CD0
C20C7E:
	pea	(C20CEC).l
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
	moveq	#$46,d0
	move.b	d0,(a3)+
	moveq	#$50,d0
	move.b	d0,(a3)+
	move	($001A,a0),d0
	move	d0,d1
	lsr.w	#1,d0
	add.b	#$30,d0
	move.b	d0,(a3)+
	cmp	($0016,a0),d1
	beq.b	C20D04
C20CEC:
	moveq	#$2C,d0
	move.b	d0,(a3)+
C20CF0:
	moveq	#$46,d0
	move.b	d0,(a3)+
	moveq	#$50,d0
	move.b	d0,(a3)+
	move	($0016,a0),d0
	lsr.w	#1,d0
	add.b	#$30,d0
	move.b	d0,(a3)+
C20D04:
	rts

C20D06:
	move	(a0),d5
	lsr.w	#1,d5
	and	#3,d5
	btst	#2,d5
	bne	DisNoOp
	move	#$FFFB,d1
	cmp.b	#$20,(a3,d1.w)
	beq.b	C20D24
	addq.w	#1,d1
C20D24:
	moveq	#$2E,d0
	move.b	d0,(a3,d1.w)
	addq.w	#1,d1
	moveq	#$57,d0
	btst	#0,d5
	beq.b	C20D48
	moveq	#$4C,d0
	move.b	d0,(a3,d1.w)
	moveq	#$23,d0
	move.b	d0,(a3)+
	moveq	#$24,d0
	move.b	d0,(a3)+
	move.l	(a5)+,d0
	br	Zet_D0_Om_inA3

C20D48:
	move.b	d0,(a3,d1.w)
	move	(a5)+,d0
	clr.b	(B2FCDE-DT,a4)
	br	Zet_D0_Om2_inA3

C20D56:
	move	(a0),d5
	lsr.w	#1,d5
	move	(2,a0),d4
	clr.b	(B2FCDE-DT,a4)
	btst	#1,d4
	beq	DisDataReg
	br	DisAdresReg

C20D6E:
	move	(2,a0),d4
	btst	#1,d4
	beq.b	C20DB0
	moveq	#$2D,d0
	move.b	d0,(a3)+
	moveq	#$28,d0
	move.b	d0,(a3)+
	move	(a0),d5
	lsr.w	#1,d5
	and	#7,d5
	bsr	DisAdresReg
	moveq	#$29,d0
	move.b	d0,(a3)+
	moveq	#$2C,d0
	move.b	d0,(a3)+
	moveq	#$2D,d0
	move.b	d0,(a3)+
	moveq	#$28,d0
	move.b	d0,(a3)+
	move	(12,a0),d5
	lsr.w	#1,d5
	and	#7,d5
	bsr	DisAdresReg
	moveq	#$29,d0
	move.b	d0,(a3)+
	bra.b	C20DCE

C20DB0:
	move	(a0),d5
	lsr.w	#1,d5
	and	#7,d5
	bsr	DisDataReg
	moveq	#$2C,d0
	move.b	d0,(a3)+
	move	(12,a0),d5
	lsr.w	#1,d5
	and	#7,d5
	bsr	DisDataReg
C20DCE:
	moveq	#$2C,d0
	move.b	d0,(a3)+
	moveq	#$23,d0
	move.b	d0,(a3)+
	moveq	#$24,d0
	move.b	d0,(a3)+
	move	(a5)+,d0
	clr.b	(B2FCDE-DT,a4)
	br	Zet_D0_Om2_inA3

C20DE4:
	pea	(C20E32).l
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
	moveq	#$2C,d0
	move.b	d0,(a3)+
	move	($0010,a0),d4
	btst	#10,d4
	beq.b	C20E4E
	move	d4,d5
	and	#7,d5
	bsr	DisDataReg
	moveq	#$3A,d0
	move.b	d0,(a3)+
C20E4E:
	move	d4,d5
	rol.w	#4,d5
	and	#7,d5
	bsr	DisDataReg
	clr.b	(B2FCDE-DT,a4)
	rts

C20E60:
	addq.w	#2,a5
	move	($0010,a0),d4
	btst	#11,d4
	beq.b	C20E7A
	rol.w	#4,d4
	and	#15,d4
	bsr	C2141C
	moveq	#$2C,d0
	move.b	d0,(a3)+
C20E7A:
	pea	(C20EAE).l
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

C20EAE:
	move	($0010,a0),d4
	btst	#11,d4
	bne	DisNoOp
	moveq	#$2C,d0
	move.b	d0,(a3)+
	rol.w	#4,d4
	and	#15,d4
	clr.b	(B2FCDE-DT,a4)
	br	C2141C

C20ECC:
	clr.b	(B2FCDE-DT,a4)
	addq.w	#2,a5
	move	(a0),d4
	btst	#1,d4
	bne.b	C20EE0
	bsr.b	C20EFC
	moveq	#$2C,d0
	move.b	d0,(a3)+
C20EE0:
	move	($0010,a0),d4
	rol.w	#4,d4
	and	#15,d4
	bsr	C2141C
	move	(a0),d4
	btst	#1,d4
	beq	DisNoOp
	moveq	#$2C,d0
	move.b	d0,(a3)+
C20EFC:
	move	($0010,a0),d4
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
	beq.w	C20F98
	subq.w	#1,d4	;$007
	beq	C20F9E
	subq.w	#1,d4	;$008
	beq	DissBUSCR

	move	($0010,a0),d4
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

	moveq	#'?',d0
	move.b	d0,(a3)+
	rts

C20F6A:
	moveq	#'T',d0
	move.b	d0,(a3)+
	moveq	#'C',d0
	move.b	d0,(a3)+
	rts

C20F74:
	moveq	#$49,d0
	move.b	d0,(a3)+
C20F78:
	moveq	#$54,d0
	move.b	d0,(a3)+
	moveq	#$54,d0
	move.b	d0,(a3)+
	moveq	#$30,d0
	move.b	d0,(a3)+
	rts

C20F86:
	moveq	#$49,d0
	move.b	d0,(a3)+
C20F8A:
	moveq	#$54,d0
	move.b	d0,(a3)+
	moveq	#$54,d0
	move.b	d0,(a3)+
	moveq	#$31,d0
	move.b	d0,(a3)+
	rts

C20F98:
	moveq	#$44,d0
	move.b	d0,(a3)+
	bra.b	C20F78

C20F9E:
	moveq	#$44,d0
	move.b	d0,(a3)+
	bra.b	C20F8A

C20FA4:
	moveq	#'C',d0
	move.b	d0,(a3)+
	bra.b	C20FAE

C20FAA:
	moveq	#$56,d0
	move.b	d0,(a3)+
C20FAE:
	moveq	#$41,d0
	move.b	d0,(a3)+
	moveq	#$4C,d0
	move.b	d0,(a3)+
	rts

C20FB8:
	moveq	#$53,d0
	move.b	d0,(a3)+
	moveq	#'C',d0
	move.b	d0,(a3)+
	moveq	#'C',d0
	move.b	d0,(a3)+
	rts

C20FC6:
	moveq	#$42,d0
	move.b	d0,(a3)+
	moveq	#$41,d0
	move.b	d0,(a3)+
	moveq	#$44,d0
	move.b	d0,(a3)+
	bra.b	C20FE0

C20FD4:
	moveq	#$42,d0
	move.b	d0,(a3)+
	moveq	#$41,d0
	move.b	d0,(a3)+
	moveq	#'C',d0
	move.b	d0,(a3)+
C20FE0:
	move	($001E,a0),d0
	lsr.w	#3,d0
	add.b	#$30,d0
	move.b	d0,(a3)+
	rts

C20FEE:
	moveq	#'P',d0
	move.b	d0,(a3)+
	moveq	#'C',d0
	move.b	d0,(a3)+
	bra.b	C21000

C20FF8:
	moveq	#'P',d0
	move.b	d0,(a3)+
C21000:
	moveq	#'S',d0
	move.b	d0,(a3)+
	moveq	#'R',d0
	move.b	d0,(a3)+
	rts

DisMMUSR:
	moveq	#'M',d0
	move.b	d0,(a3)+
;	moveq	#'M',d0
	move.b	d0,(a3)+
	moveq	#'U',d0
	move.b	d0,(a3)+
	bra.b	C21000

C21014:
	moveq	#'D',d0
	move.b	d0,(a3)+
	bra.b	C2102A

C2101A:
	moveq	#'C',d0
	move.b	d0,(a3)+
	bra.b	C2102A

DisURP:
	moveq	#$55,d0
	move.b	d0,(a3)+
	bra.b	C2102A

DisSRP:
	moveq	#$53,d0
	move.b	d0,(a3)+
C2102A:
	moveq	#$52,d0
	move.b	d0,(a3)+
	moveq	#$50,d0
	move.b	d0,(a3)+
	rts

DisISP:
	moveq	#$49,d0
	move.b	d0,(a3)+
	bra.b	C21044

DisMSP:
	moveq	#$4D,d0
	move.b	d0,(a3)+
	bra.b	C21044

DisUSP:
	moveq	#$55,d0
	move.b	d0,(a3)+
C21044:
	moveq	#$53,d0
	move.b	d0,(a3)+
	moveq	#$50,d0
	move.b	d0,(a3)+
	rts

DisVBR:
	moveq	#'V',d0
	move.b	d0,(a3)+
	moveq	#'B',d0
	move.b	d0,(a3)+
	moveq	#'R',d0
	move.b	d0,(a3)+
	rts

DisPCR:
	moveq	#'P',d0
	move.b	d0,(a3)+
	moveq	#'C',d0
	move.b	d0,(a3)+
	moveq	#'R',d0
	move.b	d0,(a3)+
	rts

DissBUSCR:
	moveq	#'B',d0
	move.b	d0,(a3)+
	moveq	#'U',d0
	move.b	d0,(a3)+
	moveq	#'S',d0
	move.b	d0,(a3)+
	moveq	#'C',d0
	move.b	d0,(a3)+
	moveq	#'R',d0
	move.b	d0,(a3)+
	rts

C2105C:
	moveq	#$53,d0
	move.b	d0,(a3)+
	bra.b	C21066

C21062:
	moveq	#$44,d0
	move.b	d0,(a3)+
C21066:
	moveq	#$46,d0
	move.b	d0,(a3)+
	moveq	#'C',d0
	move.b	d0,(a3)+
	rts

DisCAAR:
	moveq	#'C',d0
	move.b	d0,(a3)+
	moveq	#'A',d0
	move.b	d0,(a3)+
	moveq	#'A',d0
	move.b	d0,(a3)+
	moveq	#'R',d0
	move.b	d0,(a3)+
	rts

DisCACR:
	moveq	#'C',d0
	move.b	d0,(a3)+
	moveq	#'A',d0
	move.b	d0,(a3)+
	moveq	#'C',d0
	move.b	d0,(a3)+
	moveq	#'R',d0
	move.b	d0,(a3)+
	rts

C21094:
	pea	(C210E2).l
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
	moveq	#',',d0
	move.b	d0,(a3)+
	move	($0010,a0),d4
	move	d4,d5
	and	#15,d5
	bsr	DisDataReg
	moveq	#$3A,d0
	move.b	d0,(a3)+
	move	d4,d5
	rol.w	#4,d5
	and	#7,d5
	bsr	DisDataReg
	clr.b	(B2FCDE-DT,a4)
	rts

DisCmp2:
	pea	.VerdernaKomma
	addq.w	#2,a5
	subq.w	#4,d6
	beq	DisAdrIndirect
	subq.w	#6,d6
	beq	DisValueWAdrReg

	tst	d5
	beq	DisValueW
	subq.w	#1,d5
	beq	DisValueL
	subq.w	#1,d5
	beq	DisValueW_PC
	subq.w	#1,d5
	beq	DisValueB_PC_XReg
	br	DisValueBAdrReg_XReg

.VerdernaKomma:
	move	($0010,a0),d4
	moveq	#',',d0
	move.b	d0,(a3)+
	rol.w	#4,d4
	and	#15,d4
	clr.b	(B2FCDE-DT,a4)
	br	C2141C

C21148:
	move	($0010,a0),d5
	and	#7,d5
	bsr	DisDataReg
	moveq	#$3A,d0
	move.b	d0,(a3)+
	move	(2,a5),d5
	and	#7,d5
	bsr	DisDataReg
	moveq	#$2C,d0
	move.b	d0,(a3)+
	move	($0010,a0),d5
	lsr.w	#6,d5
	and	#7,d5
	bsr	DisDataReg
	moveq	#$3A,d0
	move.b	d0,(a3)+
	move	(2,a5),d5
	lsr.w	#6,d5
	and	#7,d5
	bsr	DisDataReg
	moveq	#$2C,d0
	move.b	d0,(a3)+
	moveq	#$28,d0
	move.b	d0,(a3)+
	move	($0010,a0),d4
	rol.w	#4,d4
	and	#15,d4
	bsr	C2141C
	moveq	#$29,d0
	move.b	d0,(a3)+
	moveq	#$3A,d0
	move.b	d0,(a3)+
	moveq	#$28,d0
	move.b	d0,(a3)+
	move	(2,a5),d4
	rol.w	#4,d4
	and	#15,d4
	bsr	C2141C
	moveq	#$29,d0
	move.b	d0,(a3)+
	addq.w	#4,a5
	clr.b	(B2FCDE-DT,a4)
	rts

C211C4:
	move	($0010,a0),d5
	and	#7,d5
	bsr	DisDataReg
	moveq	#$2C,d0
	move.b	d0,(a3)+
	move	($0010,a0),d5
	lsr.w	#6,d5
	and	#7,d5
	bsr	DisDataReg
	moveq	#$2C,d0
	move.b	d0,(a3)+
	pea	(C21218).l
	move	(2,a0),d6
	move	(a0),d5
	lsr.w	#1,d5
	subq.w	#4,d6
	beq	DisAdrIndirect
	subq.w	#2,d6
	beq	DisAdrIndPlus
	subq.w	#2,d6
	beq	DisMinAdrInd
	subq.w	#2,d6
	beq	DisValueWAdrReg
	addq.w	#2,a5
	subq.w	#2,d6
	bsr	DisValueBAdrReg_XReg
	subq.w	#2,a5
	rts

C21218:
	addq.w	#2,a5
	clr.b	(B2FCDE-DT,a4)
	rts

C21220:
	moveq	#$23,d0
	move.b	d0,(a3)+
	move	($0010,a0),d0
	bsr	Zet_D0_Om3_inA3
	moveq	#$2C,d0
	move.b	d0,(a3)+
	cmp	#4,d6
	bne.b	C21242
	bsr	DisAdrIndirect
	addq.w	#2,a5
	clr.b	(B2FCDE-DT,a4)
	rts

C21242:
	cmp	#10,d6
	bne.b	C2126E
	subq.l	#2,a5
	moveq	#$24,d0
	move.b	d0,(a3)+
	move	(4,a5),d0
	bsr	Zet_D0_Om2_inA3
	moveq	#$28,d0
	move.b	d0,(a3)+
	move	(a0),d5
	lsr.w	#1,d5
	bsr	DisAdresReg
	moveq	#$29,d0
	move.b	d0,(a3)+
	addq.w	#6,a5
	clr.b	(B2FCDE-DT,a4)
	rts

C2126E:
	addq.w	#2,a5
	bsr	DisValueBAdrReg_XReg
	clr.b	(B2FCDE-DT,a4)
	rts

C2127A:
	moveq	#$23,d0
	move.b	d0,(a3)+
	move	d5,d0
	clr.b	(B2FCDE-DT,a4)
	br	Zet_D0_Om3_inA3

C21288:
	move	($0010,a0),d5
	rol.w	#4,d5
	and	#7,d5
	bsr	DisDataReg
	rts

C21298:
	tst	d6
	beq.b	C212E4
	subq.w	#2,d6
	beq	C2189E
	subq.w	#2,d6
	beq.b	C212D2
	subq.w	#2,d6
	beq	C2189E
	subq.w	#2,d6
	beq	C2189E
	subq.w	#2,d6
	beq.b	C212BE
	subq.w	#2,d6
	beq.b	C212C8
	br	C2189E

C212BE:
	move	(a5)+,-(sp)
	bsr	DisValueWAdrReg
	move	(sp)+,d4
	bra.b	C212EE

C212C8:
	move	(a5)+,-(sp)
	bsr	DisValueBAdrReg_XReg
	move	(sp)+,d4
	bra.b	C212EE

C212D2:
	moveq	#$28,d0
	move.b	d0,(a3)+
	and	#7,d5
	bsr	DisAdresReg
	moveq	#$29,d0
	move.b	d0,(a3)+
	bra.b	C212EC

C212E4:
	and	#7,d5
	bsr	DisDataReg
C212EC:
	move	(a5)+,d4
C212EE:
	moveq	#$7B,d0
	move.b	d0,(a3)+
	move	d4,d5
	ror.w	#6,d5
	btst	#5,d5
	beq.b	C21306
	and.b	#7,d5
	bsr	DisDataReg
	bra.b	C21314

C21306:
	moveq	#$24,d0
	move.b	d0,(a3)+
	and	#$001F,d5
	move.b	d5,d0
	bsr	Zet_D0_Om3_inA3
C21314:
	moveq	#$3A,d0
	move.b	d0,(a3)+
	move	d4,d5
	btst	#5,d5
	beq.b	C2132A
	and.b	#7,d5
	bsr	DisDataReg
	bra.b	C21338

C2132A:
	moveq	#$24,d0
	move.b	d0,(a3)+
	and	#$001F,d5
	move.b	d5,d0
	bsr	Zet_D0_Om3_inA3
C21338:
	moveq	#$7D,d0
	move.b	d0,(a3)+
	clr.b	(B2FCDE-DT,a4)
	rts

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
	beq	C217D6
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

C2141C:
	moveq	#7,d5
	and	d4,d5
	cmp	d4,d5
	bne.b	DisAdresReg
DisDataReg:
	moveq	#$44,d0
	bra.b	C2142A

DisAdresReg:
	moveq	#$41,d0
C2142A:
	move.b	d0,(a3)+
	move.b	d5,d0
	add.b	#$30,d0
	move.b	d0,(a3)+
	rts

DisValueWAdrReg:
	bsr.b	C21452
	bra.b	DisAdrIndirect

DisMinAdrInd:
	moveq	#'-',d0
	move.b	d0,(a3)+
DisAdrIndirect:
	moveq	#'(',d0
	move.b	d0,(a3)+
	bsr.b	DisAdresReg
	moveq	#')',d0
	move.b	d0,(a3)+
	rts

DisAdrIndPlus:
	bsr.b	DisAdrIndirect
	moveq	#'+',d0
	move.b	d0,(a3)+
	rts

C21452:
	move	(a5)+,d1
	bpl.b	DisAbsAdressing
	neg.w	d1
	moveq	#'-',d0
	move.b	d0,(a3)+
	tst.b	(PR_LibCalDec).l
	beq.b	DisAbsAdressing
	cmp.b	#'J',(-13,a3)
	bne.b	DisAbsAdressing
	move.b	#1,(B3004E-DT,a4)
	move	d1,d0
	movem.l	d0-d7/a0-a2/a4-a6,-(sp)
	jsr	(C1596C).l
	movem.l	(sp)+,d0-d7/a0-a2/a4-a6
	move.b	#0,(B3004E-DT,a4)
	move	d1,d0
	rts

DisAbsAdressing:
	moveq	#'$',d0
	move.b	d0,(a3)+
	move	d1,d0
	br	Zet_D0_Om2_inA3

C21496:
	move	(a5)+,d1
	btst	#8,d1
	bne.b	Dis_NewSyntax
	tst.b	d1
	bpl.b	C214A8
	neg.b	d1
	moveq	#$2D,d0
	move.b	d0,(a3)+
C214A8:
	moveq	#$24,d0
	move.b	d0,(a3)+
	move	d1,d0
	br	Zet_D0_Om3_inA3

Dis_NewSyntax:
	move.b	d1,d4
	and.b	#15,d4
	tst.b	d4
	beq	Dis_nullOuterDisplacement
	moveq	#'(',d0
	move.b	d0,(a3)+
	moveq	#'[',d0
	move.b	d0,(a3)+
	move	d1,d4
	ror.w	#4,d4
	and	#3,d4
	moveq	#'$',d0
	move.b	d0,(a3)+
	cmp	#2,d4
	bne.b	C214E8
	move	(a5)+,d0
	bsr	Zet_D0_Om2_inA3
	moveq	#$2E,d0
	move.b	d0,(a3)+
	moveq	#$57,d0
	move.b	d0,(a3)+
	bra.b	C2150C

C214E8:
	move	(2,a0),d0	;source mode?
	and	#%1110,d0
	cmp.b	#%1110,d0
	beq.b	.pc
	move.l	(a5)+,d0
	bra.b	C21500

.pc:
	move.l	a5,d0
	add.l	(a5)+,d0
	subq.l	#2,d0
C21500:
	bsr	Zet_D0_Om_inA3
	moveq	#$2E,d0
	move.b	d0,(a3)+
	moveq	#$4C,d0
	move.b	d0,(a3)+
C2150C:
	btst	#7,d1
	bne.b	C21530

	moveq	#',',d0
	move.b	d0,(a3)+
	and	#7,d5
	cmp	#14,(2,a0)
	bne.b	C2152C
	moveq	#'P',d0
	move.b	d0,(a3)+
	moveq	#'C',d0
	move.b	d0,(a3)+
	bra.b	C21530

C2152C:
	bsr	DisAdresReg
C21530:
	btst	#2,d1
	beq.b	C2153A
	moveq	#$5D,d0
	move.b	d0,(a3)+
C2153A:
	btst	#6,d1
	beq.b	C21544
	rol.w	#4,d1
	bra.b	C21572

C21544:
	moveq	#$2C,d0
	move.b	d0,(a3)+
	rol.w	#4,d1
	move	d1,d5
	and	#7,d5
	bsr	DisDataReg
	moveq	#$2E,d0
	move.b	d0,(a3)+
	moveq	#$57,d0
	btst	#15,d1
	beq.b	C21562
	moveq	#$4C,d0
C21562:
	move.b	d0,(a3)+
	move	d1,d4
	rol.w	#3,d4
	and	#3,d4
	beq.b	C21572
	bsr	C2171A
C21572:
	ror.w	#4,d1
	btst	#2,d1
	bne.b	C2157E
	moveq	#$5D,d0
	move.b	d0,(a3)+
C2157E:
	and	#3,d1
	cmp	#1,d1
	ble.b	C215B4
	moveq	#$2C,d0
	move.b	d0,(a3)+
	moveq	#$24,d0
	move.b	d0,(a3)+
	cmp	#2,d1
	bne.b	C215A6
	move	(a5)+,d0
	bsr	Zet_D0_Om2_inA3
	moveq	#$2E,d0
	move.b	d0,(a3)+
	moveq	#$57,d0
	move.b	d0,(a3)+
	bra.b	C215B4

C215A6:
	move.l	(a5)+,d0
	bsr	Zet_D0_Om_inA3
	moveq	#$2E,d0
	move.b	d0,(a3)+
	moveq	#$4C,d0
	move.b	d0,(a3)+
C215B4:
	moveq	#$29,d0
	move.b	d0,(a3)+
	clr.b	(B2FCDE-DT,a4)
	rts

Dis_nullOuterDisplacement:
	moveq	#$28,d0
	move.b	d0,(a3)+
	move	d1,d4
	btst	#7,d4
	bne	C2165C
	move	(a0),d5
	lsr.w	#1,d5
	and	#7,d5
	cmp	#14,(2,a0)
	bne.b	C215E6
	moveq	#$50,d0
	move.b	d0,(a3)+
	moveq	#'C',d0
	move.b	d0,(a3)+
	bra.b	C215EA

C215E6:
	bsr	DisAdresReg
C215EA:
	moveq	#$2C,d0
	move.b	d0,(a3)+
	rol.w	#4,d1
	move	d1,d5
	and	#7,d5
	bsr	DisDataReg
	moveq	#$2E,d0
	move.b	d0,(a3)+
	moveq	#$57,d0
	btst	#15,d1
	beq.b	C21608
	moveq	#$4C,d0
C21608:
	move.b	d0,(a3)+
	rol.w	#3,d1
	move	d1,d4
	and	#3,d4
	beq.b	C21618
	bsr	C2171A
C21618:
	moveq	#$2C,d0
	move.b	d0,(a3)+
	rol.w	#5,d1
	and	#3,d1
	moveq	#$24,d0
	move.b	d0,(a3)+
	cmp.b	#2,d1
	bne.b	C21644
	move	(a5)+,d0
	bsr	Zet_D0_Om2_inA3
	moveq	#$2E,d0
	move.b	d0,(a3)+
	moveq	#$57,d0
	move.b	d0,(a3)+
	moveq	#$29,d0
	move.b	d0,(a3)+
	clr.b	(B2FCDE-DT,a4)
	rts

C21644:
	move.l	(a5)+,d0
	bsr	Zet_D0_Om_inA3
	moveq	#$2E,d0
	move.b	d0,(a3)+
	moveq	#$4C,d0
	move.b	d0,(a3)+
	moveq	#$29,d0
	move.b	d0,(a3)+
	clr.b	(B2FCDE-DT,a4)
	rts

C2165C:
	rol.w	#4,d4
	move	d4,-(sp)
	and	#15,d4
	bsr	C2141C
	moveq	#$2E,d0
	move.b	d0,(a3)+
	moveq	#$57,d0
	move	(sp),d4
	rol.w	#3,d4
	btst	#2,d4
	beq.b	C2167A
	moveq	#$4C,d0
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
	moveq	#$2C,d0
	move.b	d0,(a3)+
	moveq	#$24,d0
	move.b	d0,(a3)+
	subq.w	#1,d4
	beq.b	C216B0
	move.l	(a5)+,d0
	bsr	Zet_D0_Om_inA3
	moveq	#$2E,d0
	move.b	d0,(a3)+
	moveq	#$4C,d0
	move.b	d0,(a3)+
	bra.b	C216BE

C216B0:
	move	(a5)+,d0
	bsr	Zet_D0_Om2_inA3
	moveq	#$2E,d0
	move.b	d0,(a3)+
	moveq	#$57,d0
	move.b	d0,(a3)+
C216BE:
	moveq	#$29,d0
	move.b	d0,(a3)+
	clr.b	(B2FCDE-DT,a4)
	rts

DisValueBAdrReg_XReg:
	move.b	#1,(B2FCDE-DT,a4)
	bsr	C21496
	tst.b	(B2FCDE-DT,a4)
	beq	DisNoOp
	moveq	#$28,d0
	move.b	d0,(a3)+
	bsr	DisAdresReg
C216E2:
	moveq	#$2C,d0
	move.b	d0,(a3)+
	move	(-2,a5),d1
	rol.w	#4,d1
	moveq	#15,d4
	and.b	d1,d4
	bsr	C2141C
	moveq	#$2E,d0
	move.b	d0,(a3)+
	moveq	#$57,d0
	tst	d1
	bpl.b	C21700
	moveq	#$4C,d0
C21700:
	move.b	d0,(a3)+
	rol.w	#3,d1
	move	d1,d4
	and	#3,d4
	beq.b	C21714
	bsr	C2171A
	clr.b	(B2FCDE-DT,a4)
C21714:
	moveq	#$29,d0
	move.b	d0,(a3)+
	rts

C2171A:
	moveq	#$32,d0
	subq.w	#1,d4
	beq.b	C21728
	moveq	#$34,d0
	subq.w	#1,d4
	beq.b	C21728
	moveq	#$38,d0
C21728:
	moveq	#$2A,d4
	move.b	d4,(a3)+
	move.b	d0,(a3)+
	rts

DisValueW:
	bsr	C21452
	moveq	#$2E,d0
	move.b	d0,(a3)+
	moveq	#$57,d0
	move.b	d0,(a3)+
	rts

C2173E:
	moveq	#$23,d0
	move.b	d0,(a3)+
DisValueL:
	move.l	(a5)+,d0
	br	ZetHex_D0_Om_insource

DisValueW_PC:
	bsr	C2184A
	moveq	#$28,d0
	move.b	d0,(a3)+
	moveq	#$50,d0
	move.b	d0,(a3)+
	moveq	#'C',d0
	move.b	d0,(a3)+
	moveq	#$29,d0
	move.b	d0,(a3)+
	rts

DisValueB_PC_XReg:
	move	(a5),d0
	btst	#8,d0
	bne.b	C21782
	ext.w	d0
	ext.l	d0
	add.l	a5,d0
	bsr	C21850
	addq.w	#2,a5
	moveq	#$28,d0
	move.b	d0,(a3)+
	moveq	#$50,d0
	move.b	d0,(a3)+
	moveq	#'C',d0
	move.b	d0,(a3)+
	br	C216E2

C21782:
	move	(a5)+,d1
	br	Dis_NewSyntax

DisNumberW:
	move	($001A,a0),d0
	tst	d0
	beq.b	C217F2
	cmp	#12,d0
	beq.b	C217D6
	cmp	#8,d0
	beq.b	C217E4
	cmp	#2,d0
	beq.b	C217F2
	cmp	#10,d0
	beq.b	C217C2
	moveq	#$23,d0
	move.b	d0,(a3)+
	moveq	#$24,d0
	move.b	d0,(a3)+
	move.l	(a5)+,d0
	bsr	Zet_D0_Om_inA3
	move.l	(a5)+,d0
	bsr	Zet_D0_Om_inA3
	move.l	(a5)+,d0
	br	Zet_D0_Om_inA3

C217C2:
	moveq	#$23,d0
	move.b	d0,(a3)+
	moveq	#$24,d0
	move.b	d0,(a3)+
	move.l	(a5)+,d0
	bsr	Zet_D0_Om_inA3
	move.l	(a5)+,d0
	br	Zet_D0_Om_inA3


C217D6:
	moveq	#$23,d0
	move.b	d0,(a3)+
	moveq	#$24,d0
	move.b	d0,(a3)+
	move	(a5)+,d0
	br	Zet_D0_Om3_inA3

disfix:
	addq.w	#2,a5
C217E4:
	moveq	#$23,d0
	move.b	d0,(a3)+
	moveq	#$24,d0
	move.b	d0,(a3)+
	move	(a5)+,d0
	br	Zet_D0_Om2_inA3

C217F2:
	moveq	#$23,d0
	move.b	d0,(a3)+
	moveq	#$24,d0
	move.b	d0,(a3)+
	move.l	(a5)+,d0
	br	Zet_D0_Om_inA3

C21800:
	moveq	#$53,d0
	move.b	d0,(a3)+
	moveq	#$52,d0
	move.b	d0,(a3)+
	rts

C2180A:
	moveq	#'C',d0
	move.b	d0,(a3)+
	moveq	#'C',d0
	move.b	d0,(a3)+
	moveq	#$52,d0
	move.b	d0,(a3)+
	rts

C21818:
	moveq	#$55,d0
	move.b	d0,(a3)+
	moveq	#$53,d0
	move.b	d0,(a3)+
	moveq	#$50,d0
	move.b	d0,(a3)+
	rts

C21826:
	move.b	(-1,a5),d0
	beq.b	C2184A
	cmp	#2,(ProcessorType-DT,a4)
	blt.b	C21842
	cmp.b	#$FF,d0
	bne.b	C21842
	move.l	(a5),d0
	add.l	a5,d0
	addq.w	#4,a5
	bra.b	C21850

C21842:
	ext.w	d0
	ext.l	d0
	add.l	a5,d0
	bra.b	C21850

C2184A:
	move.l	a5,a2
	add	(a5)+,a2
	move.l	a2,d0
C21850:
	br	ZetHex_D0_Om_insource

C21854:
	move.l	a5,a2
	add.l	(a5)+,a2
	move.l	a2,d0
	br	ZetHex_D0_Om_insource

C2185E:
	moveq	#$23,d0
	move.b	d0,(a3)+
	subq.w	#2,a5
	br	C21496

C21868:
	moveq	#$23,d0
	move.b	d0,(a3)+
	move	d5,d0
	subq.w	#1,d0
	and	#7,d0
	addq.w	#1,d0
	br	Zet_D0_Om4_inA3

C2187A:
	moveq	#$23,d0
	move.b	d0,(a3)+
	moveq	#$24,d0
	move.b	d0,(a3)+
	move.b	(-1,a5),d0
	br	Zet_D0_Om4_inA3

C2188A:
	moveq	#$23,d0
	move.b	d0,(a3)+
	moveq	#$24,d0
	move.b	d0,(a3)+
	move	(-2,a5),d0
	and	#$0FFF,d0
	br	Zet_D0_Om2_inA3

C2189E:
	moveq	#$24,d0
	move.b	d0,(a3)+
	move	(-2,a5),d0
	br	Zet_D0_Om2_inA3

C218AA:
	move	($0010,a0),d1
	cmp	#8,(2,a0)
	bne.b	C218C2
	moveq	#15,d2
C218B8:
	roxr.w	#1,d1
	roxl.w	#1,d0
	dbra	d2,C218B8
	move	d0,d1
C218C2:
	moveq	#$11,d6
	moveq	#-1,d4
C218C6:
	addq.w	#1,d4
	cmp	d6,d4
	beq	C2191E
	lsr.w	#1,d1
	bcc.b	C218C6
C218D2:
	bsr	C2141C
	addq.w	#1,d4
	cmp	d6,d4
	beq	C2191E
	lsr.w	#1,d1
	bcc.b	C2190C
	addq.w	#1,d4
	cmp	d6,d4
	beq	C2191E
	lsr.w	#1,d1
	bcc.b	C21900
C218EE:
	addq.w	#1,d4
	cmp	d6,d4
	beq	C2191E
	lsr.w	#1,d1
	bcs.b	C218EE
	moveq	#$2D,d0
	move.b	d0,(a3)+
	bra.b	C21904

C21900:
	moveq	#$2F,d0
	move.b	d0,(a3)+
C21904:
	subq.b	#1,d4
	bsr	C2141C
	addq.b	#1,d4
C2190C:
	addq.w	#1,d4
	cmp	d6,d4
	beq	C2191E
	lsr.w	#1,d1
	bcc.b	C2190C
	moveq	#$2F,d0
	move.b	d0,(a3)+
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
	move.l	d0,-(sp)
	moveq	#'$',d0
	move.b	d0,(a3)+
	move.l	(sp)+,d0
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

DisAsmblStuff:
	include	include:Disasm.data2.s

NM_UKN:	*-10


;***********************************************
;**             VARIABLES SECTION             **
;***********************************************

	SECTION	variabelen_stuff,BSS
DT:	equ	*

Variable_base:
		DS.B	'a'
ALPHA_ONE:	ds.b	$009F

NrOfErrors:	ds.w	1

XDefTreePtr:	ds.l	1

;---  Response struct  ---

ResponseType:	ds.w	1
ResponsePtr:	ds.l	1

GadToolsBase:	ds.l	1
AslBase:	ds.l	1

WorkBuffer1:	ds.w	1
WorkBuffer2:	ds.b	1
WorkBuffer3:	ds.b	5

TraceLinePtr:	ds.l	1
TraceLineNr:	ds.l	1

ConditionLevel:	ds.w	1
ConditionBuffer:ds.b	MAX_CONDITION_LEVEL
ConditionBufPtr:ds.l	MAX_CONDITION_LEVEL

Asm_Table_Base:	ds.l	1

;***  Local label area  ***

CurrentLocalPtr:ds.l	1

;*********************************
;*    SECTION structure layout   *
;*********************************

LastSection:	ds.w	1
CurrentSection:	ds.w	1
NrOfSections:	ds.w	1

SectionTreePtr:	ds.l	1

INSTRUCTION_ORG_PTR:
		ds.w	1
		ds.b	1
SECTION_TREE_PTR_Byte:
		ds.b	1


;***  Section Block  ***

SECTION_ABS_LOCATION:	ds.l	256

SECTION_ORG_ADDRESS:	ds.l	256

SECTION_TYPE_TABLE:	ds.b	256

SECTION_OLD_ORG_ADDRESS:ds.l	256

; Types:

; CODE = 0
; DATA = 4
; BSS  = 8

; CODE_F = 0+2
; DATA_F = 4+2
; BSS_F  = 8+2

; CODE_C = 0+1
; DATA_C = 4+1
; BSS_C  = 8+1

CURRENT_ABS_ADDRESS:	ds.l	1
LabelXrefName:	ds.l	1

Binary_Offset:	ds.l	1

UsedRegs:	ds.w	1
OpperantSize:	ds.b	1
CURRENT_SECTION_TYPE:	ds.b	1

DATA_OLDREQPTR:	ds.l	1
DATA_RETURNMSG:	ds.l	1
DATA_TASKPTR:	ds.l	1

MEMDIR_ANTAL:	ds.w	1
DAIRYIN:	ds.w	1
DAIRYOUT:	ds.w	1

;***  Memory Area Pointers  ***

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

;***  Editor & Screen constants  ***

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
AantalRegels_Editor:
		ds.w	1
AantalRegels_HalveEditor:
		ds.w	1
NrOfLinesInEditor:
		ds.w	1
SCROLLOKFLAG:	ds.w	1	; $00FF - allways print, $ffff never

Cursor_col_pos:	ds.w	1
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
;	$0100

;***  Short Access Data Area  ***

		ds.b	1
Comm_Char:	ds.b	1
SomeBits:	ds.b	1
SomeBits2:	ds.b	1
SomeBits3:	ds.b	1
		even
MENUCHAR_TEXTBUFFER:	ds.w	1

;***  Libs and devices  ***

DosBase:	ds.l	1
PrinterBase:	ds.l	1
GfxBase:	ds.l	1
IntBase:	ds.l	1
SomeBits2Backup:ds.b	1
		ds.b	3

;***  DisAssemble data area  ***

DBTypePtr:	ds.l	1

MON_DATA_MARK1:	ds.l	1
MON_DATA_MARK2:	ds.l	1
MON_DATA_MARK3:	ds.l	1

MON_LAST_LONG_ADDR:	ds.l	1
MON_LAST_NUM:		ds.w	1
MON_LAST_BUFFER:	ds.l	16

MON_TYPE_PTR:	ds.l	1
MON_EDIT_POSITION:	ds.w	1

		ds.w	9
DEBUG_NUMOFADDS:ds.w	1

DIS_PRINT_BUFFER_0:	ds.b	20	;buffer voor adres in ascii
B29B92:		ds.b	1
B29B93:		ds.b	1

B29B94:		ds.b	$002F
B29BC3:		ds.b	1

B29BC4:		ds.b	$001F
MemDumpSize:	ds.b	1
L29BE4:		ds.l	1
L29BE8:		ds.l	12
		ds.w	1

;***  Debugger area  ***

SST_STEPS:	ds.w	1
RESCUE_4REGS:	ds.l	4

MEM_DIS_DUMP_PTR:ds.l	1

DATA_BUSACCESS:	ds.w	1
DATA_BUSPTRHI:	ds.w	1
DATA_BUSPTRLO:	ds.w	1
DATA_BUSFAILINST:ds.w	1

DataRegsStore:	ds.l	8
AdresRegsStore:	ds.l	7
USP_base:	ds.l	1
SSP_base:	ds.l	1
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

DATA_EXCEPTIONNUMBER:	ds.l	1
BREAKPTBUFFER:	ds.l	$0018

DATA_SUPERSTACKPTR:	ds.l	1
DATA_USERSTACKPTR:	ds.l	1

;****  LABEL DATA PTRS  ****

LabelRollValue:	ds.w	1
Label1Entry:	ds.w	1
Label2Entry:	ds.w	1
DATA_NUMOFGLABELS:	ds.w	1

;***  Macro data area  ***

SPECIAL_SYMBOL_NARG:
		ds.l	2
		ds.w	1
		ds.w	2
MACRO_ARGUMENTS:	ds.w	1

MACRO_LEVEL:		ds.w	1
MACRO_LINEBUFFER:	ds.b	200
MACRO_LOCALNR:		ds.w	1
CURRENT_MACRO_ARG_PTR:	ds.l	1

EDMACRO_BUFFER:	ds.l	$0040
EDMACRO_BUFPTR:	ds.b	1
EDMACRO_BUFByte:ds.b	1

;***  Rescue Data Area  ***

JUMPPTR:	ds.l	1
RESCPTR:	ds.l	1

Copperlist1:	ds.l	1
Copperlist2:	ds.l	1
GEMINT:		ds.w	1
GEMDMA:		ds.w	1
GEMDISK:	ds.w	1

RESCUEPTRS:	ds.l	$001D
RESCUEPTRS_Last:ds.l	1

;***  Input buffer area  ***

SourceCode:	ds.w	1
GeenIdee:	ds.l	$0018
		ds.w	1
CurrentAsmLine:	ds.b	1
B2A015:		ds.b	1

B2A016:		ds.b	$00A0
L2A0B6:		ds.l	$0040

DIR_ARRAY:	ds.b	[DSIZE]*(10+1)
		cnop	1,1
DIR_ARRAY2:	ds.b	$0083
FILE_ARRAY2:	ds.l	7
		ds.w	1
		ds.b	1
DIR_ARRAY3:	ds.b	$0083
FILE_ARRAY3:	ds.l	8

INCLUDE_DIRECTORY:	ds.l	100/4
TITLE_STRING:		ds.l	60/4
IDNT_STRING:		ds.l	60/4
TextPrintBuffer:	ds.l	1000/4
text_buf_ptr:		ds.l	1

;***  Include data  ***

FIRST_INCLUDE_PTR:	ds.l	1
INCLUDE_CONSUMPTION:	ds.l	1
INCLUDE_LEVEL:	ds.w	1

INSERT_START:		ds.l	1
INSERT_END:		ds.l	1

Math_Level:		ds.w	1
BASEREG_BYTE:		ds.b	1
			even
BASEREG_BASE:		ds.l	12
OFFSET_BASE_ADDRESS:	ds.l	1
TEMP_CONT_PTR:		ds.l	1
TEMP_STACKPTR:		ds.l	1
RS_BASE_OFFSET:		ds.l	1

REPT_LEVEL:	ds.w	1
REPT_STACK:	ds.b	MAX_REPT_LEVEL*14

;***  I/O areas ^ ptrs  ***

Error_Jumpback:	ds.l	1
FileLength:	ds.l	1

Bestand:	ds.l	1
L2BD22:		ds.l	1

TRACK_COMMAND:	ds.w	1
TRACK_LENGTH:	ds.l	1
TRACK_BUFFER:	ds.l	1
TRACK_POINTER:	ds.l	1

SEGMENTLENGTH:	ds.l	1
SEGMENTADDRESS:	ds.l	1

CONSOLEDEVICE:		ds.l	1

DATA_WRITEREQUEST2:	ds.l	$0014
DATA_REPLYPORT:		ds.l	8

;***  Keyboard data area  ***

KeyboardInBuf:	ds.b	1
KeyboardInBufByte:ds.b	1
KeyboardOutBuf:	ds.b	1
KeyboardOutBufByte:ds.b	1
KEYB_KILLPTR:	ds.b	1
KEYB_KILLPTRByte:ds.b	1

OwnKeyBuffer:	ds.l	$0040	;256 bytes
edit_EscCode:	ds.b	2
B2BEB8:		ds.b	2

IOREQ:		ds.l	5
IOREQ2:		ds.l	3
KEY_BUFFER:	ds.l	$0014
KEY_PORT:	ds.l	1
KEY_MSG:	ds.l	1

MY_EVENT:	ds.l	1
EVENT_IECLASS:	ds.b	1
		ds.b	1
IECODE:		ds.w	1
IEQUAL:		ds.w	1
IEADDR:		ds.l	3
MainWindowHandle:ds.l	1

;***  DIR DATA AREA  ***

	CNOP	0,4
ParameterBlok:	ds.l	1
L2BF50:		ds.l	1
L2BF54:		ds.l	1
L2BF58:		ds.l	1
L2BF5C:		ds.l	$001A
L2BFC4:		ds.l	1
incFileLength:	ds.l	$001D
MEMDIR_BUFFER:	ds.l	8
		ds.w	1
L2C05E:		ds.l	1
L2C062:		ds.l	2
L2C06A:		ds.l	$03B8
		ds.w	1
L2CF4C:		ds.l	$0185
B2D560:		ds.b	$09EC
L2DF4C:		ds.w	1
W2DF4E:		ds.w	1
L2DF50:		ds.l	1
L2DF54:		ds.l	1
L2DF58:		ds.l	1
L2DF5C:		ds.l	1
L2DF60:		ds.l	1
L2DF64:		ds.w	1
		ds.b	1
B2DF67:		ds.b	1
L2DF68:		ds.l	1
B2DF6C:		ds.b	3
B2DF6F:		ds.b	1
MathFfpBase:	ds.l	1
MathTransBase:	ds.l	1
L2DF78:		ds.l	1
L2DF7C:		ds.l	1
L2DF80:		ds.l	1
W2DF84:		ds.w	1
FileNaam:	ds.l	$003F
		ds.w	1
HomeDirectory:	ds.b	250
B2E17E:		ds.b	4
TempDirName:	ds.l	1
L2E186:		ds.l	$003E
		ds.w	1
BootUpString:	ds.l	$003F
		ds.w	1
ViewPortBase:	ds.l	1
Mark1set:	ds.l	1
Mark2set:	ds.l	1
Mark3set:	ds.l	1
Mark4set:	ds.l	1
Mark5set:	ds.l	1
Mark6set:	ds.l	1
Mark7set:	ds.l	1
Mark8set:	ds.l	1
Mark9set:	ds.l	1
Mark10set:	ds.l	1
ReqToolsbase:	ds.l	1
FileReqBase:	ds.l	1
ScrColors:
;		ds.l	6
		ds.l	3*16/2

B2E3CA:		ds.b	1
B2E3CB:		ds.b	1
Parameters:	ds.b	$00FE
ParametersLengte:ds.w	1
W2E4CC:		ds.w	1
ProgressCntr:	ds.w	1
ProgressSpeed:	ds.w	1
L2E4D2:		ds.l	1
L2E4D6:		ds.l	1
L2E4DA:		ds.l	1
L2E4DE:		ds.l	1
L2E4E2:		ds.l	1
L2E4E6:		ds.l	1
L2E4EA:		ds.l	1
L2E4EE:		ds.l	1
L2E4F2:		ds.l	1
LastFoundLine:	ds.b	2
OldCursorpos:	ds.l	1	;was ds.w 1
OldLinePos: 	ds.l	1	;was ds.w 2 ?!
LocalBufPtr:	ds.l	1
Marksinsource:	ds.w	1
CPU_type:	ds.w	2
W2E508:		ds.w	1
PrefsGedoe:	ds.w	1
SaveBin_Start:	ds.l	1		; ***
SaveBin_End:	ds.l	1		; ***
Mon_Notif_Addr:	ds.w	1		; *** Must refresh the address later
Parse_AdrValue:	ds.w	1
Parse_AdrValueSizePlus2:
		ds.w	1
Parse_AdrValueSize:
		ds.w	1
Parse_CPUType:	ds.w	1
AsmErrorPos:	ds.l	1
AsmErrorTable:	ds.w	4*100
AsmEindeErrorTable:
		ds.w	4
Asm_LastErrorPos:
		ds.l	1
PrevDirnames:
		ds.b	128	;normal read/write
		ds.b	128	;object/binary etc..
		ds.b	128	;insert

LastFileNaam:	ds.l	$0040
ProjectName:	ds.l	$0040

OldTime:	ds.l	1
L2EB04:		ds.l	$0010
;TimerDevStruct:
;		ds.l	$0010
;		ds.w	1
L2EB86:		ds.l	15
L2EBC2:		ds.l	$0013
		ds.w	1
L2EC10:		ds.w	1
RegelPtrsIn:	ds.l	128
RegelPtrsOut:	ds.l	128
VBR_base_ofzo:	ds.l	1
VBR_Base2:	ds.l	1
LoopPtr:	ds.l	10
Safety:		ds.b	2
PR_Msg:		ds.l	1
PR_GadClass:	ds.l	1
PR_GadCode:	ds.l	1
PR_GadMouseX:	ds.l	1
PR_GadgetID:	ds.w	1
PR_GadgetAdr:	ds.l	1

L2F056:		ds.l	1
PrefsAsmWinBase:ds.l	1
Prefs_GList:	ds.l	1
Prefs_Gadgets:	ds.l	env_gadcount	;$21
GadgetBuffer:	ds.l	7
		ds.w	1
Prefs_msgport:	ds.l	1
L2F10C:		ds.l	2
ErrorLijnInCode:
		ds.l	1
L2F118:		ds.l	1
L2F11C:		ds.l	1
L2F120:		ds.l	1
L2F124:		ds.l	1
L2F128:		ds.l	1
L2F12C:		ds.l	1
L2F130:		ds.l	1
Comm_menubase:	ds.l	1
Edit_Menubase:	ds.l	1
Monitor_MenuBase:
		ds.l	1
Debug_MenuBase:	ds.l	1
L2F144:		ds.l	1
L2F148:		ds.l	1
L2F14C:		ds.l	1
L2F150:		ds.l	1
L2F154:		ds.l	1
HelpBufPtrBot:	ds.l	1
HelpBufPtrTop:	ds.l	1

fpu_1:		ds.l	1
fpu_2:		ds.l	1
fpu_3:		ds.l	1

L2F16C:		ds.l	1
fpu2_old:	ds.l	1
L2F174:		ds.l	1

FpuRegsStore:	ds.l	$0018
FpuRegsStore_Old:
		ds.l	$0018

screen_req:	ds.l	1
old_sizeY:	ds.l	1
old_sizeX:	ds.l	1
scrmode_oud:	ds.l	1
scrmode_new:	ds.l	1
old_screendepth	ds.w	1
NieuwMouseX:	ds.w	1
NieuwMouseY:	ds.w	1
;W2F250:		ds.w	1
W2F254:		ds.w	1
AssmblrStatus:
		ds.w	1
D02F258:	ds.d	0
		ds.s	1
		ds.l	1	;ditte
D02F260:	ds.d	0
		ds.d	0
		ds.s	1
		ds.l	2	;end ditte
L2F26C:		ds.l	1
B2F270:		ds.b	1
B2F271:		ds.b	1
AmigaGuideBase:	ds.l	1
NewAmiGuideBase:ds.l	1
L2F27A:		ds.l	1
YposScreen:	ds.w	1
SourcePtrs:	ds.l	10*64
TempBuffer:	ds.l	1
TempBufferSize:	ds.l	1
EditorRegs:	ds.w	20
L2FCBA:		ds.l	6
B2FCD2:		ds.b	4
L2FCD6:		ds.l	1
W2FCDA:		ds.w	2
B2FCDE:		ds.b	1
S_MemIndActEnc:	ds.b	1
ProcessorType:	ds.w	1
FPU_Type:	ds.w	1
Oldcursorcol:	ds.w	1
L2FCE6:		ds.l	1
L2FCEA:		ds.l	1
W2FCEE:		ds.w	5
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
L2FD24:		ds.l	1
L2FD28:		ds.l	1
IFFnrplanes:	ds.b	1
IFFmask:	ds.b	1
IFFcompressed:	ds.b	1
IncIff_tiepe:	ds.b	1
IncIff_colmap_pos:
		ds.b	2

L2FD32:		ds.l	3*256/4
W30032:		ds.w	1
W30034:		ds.w	6
B30040:		ds.b	1
BlokBackwards:	ds.b	1
B30042:		ds.b	1
SomeBits3_backup:
		ds.b	1
Prefs_tiepe:	ds.b	1
menu_tiepe:	ds.b	1
markblockset:	ds.b	1
B30047:		ds.b	1
B30048:		ds.b	1
B30049:		ds.b	1
B3004A:		ds.b	1
B3004B:		ds.b	1
B3004C:		ds.b	1
debug_FPregs:	ds.b	1
B3004E:		ds.b	1
CurrentSource:	ds.b	1
Change2Source:	ds.b	1
Animate:	ds.b	1
FromCmdLine:	ds.b	1

B30053:		ds.b	15
L30062:		ds.l	3
		ds.w	1
		ds.b	1

B30071:		ds.b	$0100
MMUAsmBits:	ds.b	1
B30172:		ds.b	1
B30173:		ds.b	1
B30174:		ds.b	1
B30175:		ds.b	1
B30176:		ds.b	1
B30177:		ds.b	1
B30178:		ds.b	1

	cnop	0,4
MainVisualInfo:	ds.l	1

DiskfontBase:	ds.l	1
Fontbase_edit:	ds.l	1

Scr_NrPlanes:	ds.w	1
Scr_Title_size:		ds.w	1	;11
Scr_Title_sizeTxt	ds.w	1	;11+baseline
Scr_breedte	ds.w	1
Scr_hoogte	ds.w	1
Scr_br_chars	ds.w	1
Scr_hg_chars	ds.w	1

Win_BorTop:	ds.w	1	;2
Win_BorLeft:	ds.w	1	;4
Win_BorRight:	ds.w	1	;4
Win_BorBottom:	ds.w	1	;2
Win_BorHor:	ds.w	1	;8
Win_BorVer:	ds.w	1	;4
Win_BorVerT:	ds.w	1	;10+2=12

EFontSize_x:	ds.w	1
EFontSize_y:	ds.w	1

Edit_hoogte:	ds.w	1

ParsePos:	ds.l	1

EditScrollSize:	ds.l	1	;br*hg edit window *depth
EditScrollSizeTitleDown:	ds.l	1	;br*hg edit window +titlesize *depth
EditScrollSizeTitleUp:		ds.l	1	;br*hg edit window +titlesize *depth
EditScrollRegelSize:		ds.w	1	;br*hgfont * depth
Edit_nrlines:	ds.w	1	;aantal beeldlijntjes -1

SOLO_CurrentIncPtr:ds.l	1
Rastport:	ds.l	1
MyBits:		ds.b	1
ScBits:		ds.b	1
	even
ScColor:		ds.w	1
regel_buffer:	ds.b	256
markkeys:	ds.b	10

realend5:
	cnop	0,4
L2A1B6:		ds.l	COMMANDLINEBUFFERCACHE

EndVarBase:


	SECTION	AsmProLogo,DATA_C

asmprologo:		;480*60 2 planes
	inciff  include:pics/asm-pro480x120_new.iff,RN
endlogo:

smallasmprologo:		;48*74 2 planes
	inciff  include:pics/asm-pro40x100.iff,RN
