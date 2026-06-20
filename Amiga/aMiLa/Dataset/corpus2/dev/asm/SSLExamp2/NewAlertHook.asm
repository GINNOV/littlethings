; Enhanced Alert Hook
; (c) 1994 MJSoft System Software, Martin Mares

_LVOTimedDisplayAlert	EQU	-822

	ifnd	EXEC
	include	"ssmac.h"
	endc
	include	"values/hardware.i"

;	opt	x+
	opt	nochkimm

	ifnd	EXEC

	moveq	#-1,d0
	rts

Resident	dc.w	RTC_MATCHWORD
	dc.l	Resident
	dc.l	EndSkip
	dc.b	RTF_COLDSTART
	dc.b	40			; Version
	dc.b	0			; Type
	dc.b	7			; Priority
	dc.l	HookName
	dc.l	HookIDStr
	dc.l	Init

; Alert Hook Initialization

Init	mpush	d1-d7/a0-a6
	move.l	4.w,a6

	move.l	a6,a1
	lea	(_LVOAlert).w,a0
	lea	AlertFunc(pc),a2
	move.l	a2,d0
	call	SetFunction
	bra.s	DispAlert2

	endc

; Auxilliary routine

CopyAlertLine	move.b	(a0)+,(a3)+
	move.b	(a0)+,(a3)+
	move.b	#16,(a3)+
1$	move.b	(a0)+,(a3)+
	bne.s	1$
	st	(a3)+
	rts

	ifd	EXEC
AlertHookInit	clr.l	0.w
	endc

DispAlert	mpush	d1-d7/a0-a6
	move.l	4.w,a6
DispAlert2	movem.l	LastAlert(a6),d2-d3
	moveq	#-1,d0
	cmp.l	d0,d2
	beq	DispNoAlert
	lea	-300(sp),sp
	move.l	sp,a3
	pea	TTask(pc)
	move.l	d2,d0
	swap	d0
	lea	NotEnoughMem(pc),a0
	cmp.b	#1,d0
	beq.s	AlertHead
	lea	SoftFailure(pc),a0
	tst.w	d0
	ble.s	AlertHead
	lea	RecoverError(pc),a0
AlertHead	bsr.s	CopyAlertLine
	lea	PressLMB(pc),a0
	bsr.s	CopyAlertLine

	sub.l	a5,a5
	btst	#0,d3
	bne.s	NoTaskNameS
	move.l	d3,a1
	bsr.s	CheckMem
	beq.s	NoTaskNameS
	move.b	LN_TYPE(a1),d0
	subq.b	#NT_TASK,d0
	beq.s	NoProcess
	cmp.b	#NT_PROCESS-NT_TASK,d0
	bne.s	NoTaskName
	move.l	pr_CLI(a1),d0
	beq.s	NoProcess
	lsl.l	#2,d0
	move.l	d0,a1
	bsr.s	CheckMem
	beq.s	NoProcess
	move.l	cli_CommandName(a1),a1
	add.l	a1,a1
	add.l	a1,a1
	addq.l	#1,a1
	addq.l	#4,sp
	pea	TCommand(pc)
	bra.s	IsProcess

NoProcess	move.l	d3,a1
	move.l	LN_NAME(a1),a1
IsProcess	move.l	a1,a4
	bsr.s	CheckMem
	beq.s	NoTaskName
	lea	260(sp),a2
	lea	297(sp),a0
	move.l	a2,a1
	move.b	#'(',(a1)+
	tst.b	(a4)
	beq.s	NoTaskName
CopyTName	cmp.l	a0,a1
	beq.s	CopyTNEnd
	move.b	(a4)+,d0
	move.b	d0,(a1)+
	beq.s	CopyTNEnd
	lsl.b	#1,d0
	cmp.b	#64,d0
	bcc.s	CopyTName
NoTaskNameS	bra.s	NoTaskName

CheckMem	push	a1
	call	TypeOfMem
	pop	a1
	tst.l	d0
	bne.s	1$
2$	move.l	LN_NAME(a6),d0
	clr.w	d0
	sub.l	a1,d0
	cmp.l	#-$80000,d0
	bcc.s	1$
	moveq	#0,d0
1$	rts

CopyTNEnd	move.b	#')',-1(a1)
	sf	(a1)
CopyTNEnd1	move.l	a2,a5

NoTaskName	pop	d0
	push	a5
	push	d3
	push	d0
	push	d2
	move.l	sp,a1
	lea	NumberFormat(pc),a0
	lea	PFPutC(pc),a2
	addq.l	#2,a3
	call	RawDoFmt
	bsr.s	Center
	lea	16(sp),sp

	addq.l	#2,a3
	move.l	a3,a4
	move.b	#32,(a4)+

	ifd	YELLOW
	bclr	#31,d2
	move.l	d2,d0
	elseif
	move.l	d2,d0
	bclr	#31,d0
	endc

	swap	d0
	tst.w	d0
	beq.s	FindExcept
	lsr.w	#8,d0
	lea	SubSysTab(pc),a2
	bsr	TabulateUpper
GoColon	move.b	#':',(a4)+
	move.b	#' ',(a4)+

	tst.w	d2
	bgt.s	FindSpecific
	move.l	d2,d0
	swap	d0
	bclr	#15,d0
	ext.w	d0
	lea	GeneralErrs(pc),a2
	bsr	TabulateUpper
	move.w	d2,d0
	beq.s	ShowAlert
	bclr	#15,d0
	move.b	#' ',(a4)+
	move.b	#'(',(a4)+
	lea	SubSysTab(pc),a2
	bsr	Tabulate
	move.b	#')',(a4)+
	bra.s	ShowAlert

FindExcept	lea	TExcept(pc),a2
	moveq	#8,d0
1$	move.b	(a2)+,(a4)+
	dbf	d0,1$
	moveq	#-2,d4
	bra.s	GoColon

Center	move.l	a3,a0
1$	tst.b	(a0)+
	bne.s	1$
	move.l	a3,d0
	sub.l	a0,d0
	lsl.w	#2,d0
	add.w	#328,d0
	move.b	d0,-(a3)
	lsr.w	#8,d0
	move.b	d0,-(a3)
	move.l	a0,a3
	st	(a3)+
	rts

FindSpecific	lea	Specific(pc),a2
	add.w	0(a2,d4.w),a2
	move.w	d2,d0
	bsr.s	TabulateUpper

ShowAlert	sf	(a4)
	bsr.s	Center

	ifnd	EXEC

	lea	intuiname(pc),a1
	call	OldOpenLibrary

	elseif

	moveq	#3,d0
	bsr	TaggedOpenLibrary

	endc

	move.l	#AT_DeadEnd+AG_OpenLib+AO_Intuition,d7
	tst.l	d0
	beq	AlertFunc
	move.l	LastAlert+12(a6),a1
	move.l	d0,a6

	sf	-(a3)
	move.l	sp,a0
	move.l	d2,d0
	moveq	#61,d1

	ifnd	EXEC
	cmp.w	#39,LIB_VERSION(a6)
	bcs.s	NotTimed
	call	TimedDisplayAlert
	bra.s	AlertDone
NotTimed	call	DisplayAlert

	elseif
	call	TimedDisplayAlert
	endc

AlertDone	push	d0
	move.l	a6,a1
	call	exec,CloseLibrary

	clr.l	0.w
	moveq	#-1,d1
	move.l	d1,LastAlert(a6)
	pop	d0
	lea	300(sp),sp
DispNoAlert	movem.l	(sp)+,d1-d7/a0-a6
Ret1	rts

TabulateUpper	bsr.s	Tabulate
	bclr	#5,(a0)
	rts

StrXpy0	move.b	(a2)+,(a4)+
	bpl.s	StrXpy1
	move.b	-(a4),d0
StrXpyX	mpush	d5/a2
	lea	Strings(pc),a2
1$	move.b	(a2)+,d5
	add.l	d5,a2
	addq.b	#1,d0
	bne.s	1$
	move.b	(a2)+,d5
	bsr.s	StrXpy1
	mpop	d5/a2
StrXpy1	dbf	d5,StrXpy0
	rts

Tabulate	moveq	#-2,d4
	moveq	#0,d5
	move.l	a4,a0
1$	addq.w	#2,d4
	move.b	(a2)+,d5
	bpl.s	3$
	addq.w	#1,d1
	neg.b	d5
	bra.s	2$
3$	moveq	#0,d1
	move.b	(a2)+,d1
	bmi.s	StrXpy1
	bne.s	2$
	move.b	(a2)+,d1
	lsl.w	#8,d1
	move.b	(a2)+,d1
2$	cmp.w	d1,d0
	beq.s	StrXpy1
	add.w	d5,a2
	bra.s	1$

PFPutC	move.b	d0,(a3)+
	rts

; Replacement of exec/Alert()

	ifnd	EXEC

AlertFunc
	ifnd	DEBUG
	move.w	#INTF_INTEN,$dff000+intena
	endc

	movem.l	d0-d1/a0-a1/a5-a6,-(sp)
	move.l	#'HELP',d0
	sub.l	a0,a0

	ifnd	DEBUG
	cmp.l	(a0),d0
	beq.s	BlinkAlert
	move.l	d0,(a0)
	endc

	lea	$100.w,a1
	move.l	d7,(a1)+
	move.l	a5,(a1)
	move.l	4.w,d0
	btst	#0,d0
	bne.s	BlinkAlert
	move.l	d0,a6
	add.l	ChkBase(a6),d0
	addq.l	#1,d0
	bne.s	BlinkAlert
	move.l	ThisTask(a6),a5
	move.l	a5,(a1)
	move.l	#$F376C7C9,d0
	push	d0
	cmp.l	(sp)+,d0
	bne.s	BlinkAlertSP
	tst.l	d7
	bmi.s	BlinkAlert
	lea	LastAlert(a6),a0
	move.l	d7,(a0)+
	move.l	a5,(a0)
	bsr	DispAlert
	tst.l	IDNestCnt(a6)
	bge.s	YetDisabled
	move.w	#INTF_SETCLR+INTF_INTEN,$dff000+intena
YetDisabled	moveq	#1,d0
	moveq	#5,d1
	ifnd	DEBUG
WaitDiskDMA	tst.w	$dff000+dskbytr
	dbf	d0,WaitDiskDMA
	dbf	d1,WaitDiskDMA
	endc
	movem.l	(sp)+,d0-d1/a0-a1/a5-a6
	rts

BlinkAlertSP	lea	$400.w,sp
	clr.l	-(sp)
	clr.l	-(sp)
BlinkAlert	movem.l	d0-d1/a0-a1/a5-a6,-(sp)
	sub.l	a0,a0
	tst.l	$C.w	; Obey SinSoft's rules of VBR remapping
	bne.s	1$
	move.l	8.w,a0
1$	lea	MyStart(pc),a1
	move.l	a1,$20(a0)
MyStart	move.w	#$2700,sr

	moveq	#5,d1	; Start blinking (6 times)
;;	lea	$dff000,a0
;;	move.w	#$174,serper(a0)
Blink1	moveq	#-1,d0
1$	bset	#1,$bfe001
	dbf	d0,1$
2$	bclr	#1,$bfe001
	dbf	d0,2$
;;	move.w	serdatr(a0),d0
;;	move.w	#INTF_RBF,intreq(a0)
;;	and.b	#$7F,d0
;;	addq.b	#1,d0
;;	dbmi	d1,Blink1
	dbra	d1,Blink1

;;	movem.l	(sp)+,d0-d1/a0-a1/a5-a6
;; Debugging not supported ... Reboot always

RestartSystem	lea	$1000000,a0	; Supervisor mode expected
	sub.l	-$14(a0),a0
	move.l	4(a0),a0
	jmp	-2(a0)

	endc

	dc.w	Spec_cpu-Specific
Specific	dc.w	Spec_exec-Specific
	dc.w	Spec_graphics-Specific
	dc.w	Spec_layers-Specific
	dc.w	Spec_intuition-Specific
	dc.w	Spec_math-Specific
	dc.w	Spec_dos-Specific
	dc.w	Spec_ram-Specific
	dc.w	Spec_icon-Specific
	dc.w	Spec_expansion-Specific
	dc.w	Spec_diskfont-Specific
	dc.w	Spec_utility-Specific
	dc.w	Spec_keymap-Specific
	dc.w	Spec_audio-Specific
	dc.w	Spec_console-Specific
	dc.w	Spec_gameport-Specific
	dc.w	Spec_keyboard-Specific
	dc.w	Spec_trackdisk-Specific
	dc.w	Spec_timer-Specific
	dc.w	Spec_cia-Specific
	dc.w	Spec_disk-Specific
	dc.w	Spec_misc-Specific
	dc.w	Spec_bootstrap-Specific
	dc.w	Spec_workbench-Specific
	dc.w	Spec_diskcopy-Specific
	dc.w	Spec_gadtools-Specific
	dc.w	Spec_utility-Specific
	dc.w	Spec_unknown-Specific

STRCNT	set	$FF
str	macro
K\1	equ	STRCNT
STRCNT	set	STRCNT-1
	dc.b	\@a-*-1,\2
\@a
	endm

Strings	dc.b	0
	str	Library,<'library'>
	str	Device,<'device'>
	str	Resource,<'resource'>
	str	Lib,<'.',KLibrary>
	str	Dev,<'.',KDevice>
	str	Res,<'.',KResource>
	str	Unable,<'Unable to '>
	str	Open,<'open '>
	str	Close,<'Close'>
	str	Failed,<' failed'>
	str	Unkn0,<'unknown'>
	str	Unkn,<KUnkn0,KErr>
	str	Err,<' ',KErr2>
	str	Err2,<'error'>
	str	Mem,<' ',KMemS>
	str	MemS,<KMem0,' '>
	str	Mem0,<'memory'>
	str	Free,<'free'>
	str	Bad,<'Bad '>
	str	FFP,<'FFP '>
	str	MMU,<'MMU '>
	str	Instr,<' instruction'>
	str	Disk,<'disk'>
	str	NoMF,<'No',KMem,'for '>
	str	Viol,<' violation'>
	str	Erflow,<'erflow'>
	str	Illegal,<'illegal'>
	str	Interr,<'interrupt'>
	str	Attempt,<'attempt'>
	str	Util,<'utility'>
	str	To,<'to'>
	str	Frame,<' frame'>
	str	Scr,<'screen'>
	str	Intui,<'intuition'>
	str	Messg,<'message'>
	str	Init,<'init'>
	str	Line,<'line '>
	str	DivZ,<'division by zero'>
	str	Timer,<'timer'>
	str	Already,<' already '>
	str	MemList,<KMem,'list'>
	str	Item,<'item'>
	str	Type,<' type'>
	str	Rece,<' received'>
	str	Checksum,<'checksum'>
	str	Obtain,<' obtain'>
	str	Key,<'key'>
	str	Return,<' return'>
	str	Region,<'region'>
	str	Failure,<' failure'>
	str	Uninit,<'un',KInit,'ialized '>
	str	Font,<'font'>

NotEnoughMem	dc.b	0,24
	dc.b	'Not enough memory.',0
SoftFailure	dc.b	0,24
	dc.b	'Software failure.',0
RecoverError	dc.b	0,24
	dc.b	'Recoverable alert.',0
PressLMB	dc.b	1,72
	dc.b	'Press left mouse button to continue.',0
TCommand	dc.b	'Command',0
TTask	dc.b	'Task',0
TExcept	dc.b	'Exception'
NumberFormat	dc.b	48,'Error: %08lx    %s: %08lx %s',0
	ifnd	EXEC
intuiname	dc.b	'intuition.library',0
	endc
HookName	dc.b	'alert.hook'
	ifd	EXEC
	dc.b	$0D,$0A,0
	elseif
	dc.b	0
Verstr	dc.b	'$VER: '
	endc
HookIDStr	dc.b	'Enhanced Alert Hook 40.3 © 1994 MJSoft System Software',0

subs	macro
	dc.b	\@a-\@b,\1
\@b	dc.b	\2
\@a
	endm

subc	macro
	dc.b	\@b-\@a
\@b	dc.b	\1
\@a
	endm

subsx	macro
	dc.b	\@a-\@b,0,\1,\2
\@b	dc.b	\3
\@a
	endm

SubSysTab	subs	$01,<'exec',KLib>
	subc	<'graphics',KLib>
	subc	<'layers',KLib>
	subc	<KIntui,KLib>
	subc	<'math',KLib>
	subs	$07,<'dos',KLib>
	subc	<'ram',KLib>
	subc	<'icon',KLib>
	subc	<'expansion',KLib>
	subc	<KDisk,KFont,KLib>
	subc	<KUtil,KLib>
	subc	<KKey,'map',KLib>
	subs	$10,<'audio',KDev>
	subc	<'console',KDev>
	subc	<'gameport',KDev>
	subc	<KKey,'board',KDev>
	subc	<'track',KDisk,KDev>
	subc	<KTimer,KDev>
	subs	$20,<'cia',KRes>
	subc	<KDisk,KRes>
	subc	<'misc',KRes>
	subs	$30,<'bootstrap'>
	subc	<'workbench',KLib>
	subc	<KDisk,'copy'>
	subc	<'gad',KTo,'ols',KLib>
	subc	<KUtil,KLib>
	subs	$FF,<KUnkn0>

GeneralErrs	subs	$01,<'Out of ',KMem0>
	subc	<KUnable,'make ',KLibrary>
	subc	<KUnable,KOpen,KLibrary>
	subc	<KUnable,KOpen,KDevice>
	subc	<KUnable,KOpen,KResource>
	subc	<'I/O',KErr>
	subc	<KUnable,'get signal'>
	subc	<KBad,'parameters'>
	subc	<KClose,'Device',KFailed>
	subc	<KClose,'Library',KFailed>
	subc	<'CreateProc',KFailed>
	subs	$FF,<KUnkn>

Spec_exec	subs	$03,<KLibrary,' ',KChecksum,KFailure>
	subs	$05,<'Corrupted',KMemList>
	subc	<KNoMF,KInterr,' servers'>
	subs	$08,<'Semaphore in ',KIllegal,' state'>
	subc	<KFree,'ing',KMem,'that is',KAlready,KFree>
	subs	$0B,<KAttempt,' ',KTo,' reuse active IORq'>
	subc	<'Sanity check on',KMemList,KFailed>
	subc	<'IO ',KAttempt,'ed on closed IORq'>
	subc	<'Stack appears ',KTo,' be out of range'>
	subc	<KMemS,'header not located'>
	subc	<'Old ',KMessg,' semaphore used'>
	subsx	$00,$FF,<'QuickInt to ',KUninit,'vector'>
	subs	$FF,<KUnkn>

Spec_graphics	subs	$01,<KNoMF,'Moni',KTo,'rSpec'>
	subs	$06,<KNoMF,'long',KFrame>
	subc	<KNoMF,'short',KFrame>
	subs	$09,<KNoMF,'Text TmpRas'>
	subc	<KNoMF,'BltBitMap'>
	subc	<KNoMF,KRegion,'s'>
	subc	<'GfxNew',KErr>
	subc	<'GfxFree',KErr>
	subs	$30,<KNoMF,'MakeVPort'>
	subsx	$12,$34,<'Emergency',KMem,'not available'>
	subsx	$04,$01,<'Unsupported ',KFont,' description used'>
	subs	$FF,<KUnkn>

Spec_intuition	subs	$01,<KUnkn0,' gadget',KType>
	subc	<KNoMF,'port'>
	subc	<KNoMF,KItem,' plane'>
	subc	<KNoMF,'sub',KItem>
	subc	<KNoMF,'plane'>
	subc	<KItem,' box ',KTo,'p < RelZero'>
	subc	<KNoMF,KScr>
	subc	<KNoMF,KScr,' raster'>
	subc	<KBad,KScr,KType>
	subc	<KNoMF,'SW gadgets'>
	subc	<KNoMF,'window'>
	subc	<KBad,'state',KReturn,' entering ',KIntui>
	subc	<KBad,KMessg,KRece,' by IDCMP'>
	subc	<'Weird echo causing incomprehesion'>
	subc	<KUnable,KOpen,'console',KDev>
	subc	<KIntui,' skipped',KObtain,'ing a sem'>
	subc	<KIntui,KObtain,'ed a sem in bad order'>
	subs	$FF,<KUnkn>

Spec_dos	subs	$01,<KNoMF,'DOS startup'>
	subc	<'EndTask didn''t'>
	subc	<'QPkt',KFailure>
	subc	<'Unexpected packet',KRece>
	subc	<KFree,'Vec',KFailed>
	subc	<KDisk,' block sequence',KErr>
	subc	<'Bitmap corrupt'>
	subc	<KKey,KAlready,KFree>
	subc	<KBad,KChecksum>
	subc	<KDisk,KErr>
	subc	<KKey,' out of range'>
	subc	<KBad,'overlay'>
	subc	<KBad,KInit,' packet for CLI/Shell'>
	subc	<'File handle closed twice'>
	subs	$FF,<KUnkn>

Spec_ram	subs	$01,<'Overlayed ',KLibrary,' segment'>
	subs	$FF,<KUnkn>

Spec_expansion	subs	$01,<KFree,'d ',KFree,' ',KRegion,' of exp space'>
	subs	$FF,<KUnkn>

Spec_console	subs	$01,<KUnable,KOpen,KInit,'ial window'>
	subs	$FF,<KUnkn>

Spec_trackdisk	subs	$01,<'Seek',KErr,' during calibration'>
	subc	<KErr2,' on ',KTimer,' wait'>
	subs	$FF,<KUnkn>

Spec_timer	subs	$01,<KBad,'request'>
	subc	<'No 50/60 Hz ticks from power supply'>
	subs	$FF,<KUnkn>

Spec_disk	subs	$01,<'GetUnit:',KAlready,'has ',KDisk>
	subc	<KInterr,' with no active unit'>
	subs	$FF,<KUnkn>

Spec_bootstrap	subs	$01,<'Boot code',KReturn,'ed an',KErr>
	subs	$FF,<KUnkn>

Spec_workbench	subs	$01,<'No ',KFont,'s'>
	subc	<KBad,'startup ',KMessg>
	subc	<KBad,'I/O ',KMessg>
	subs	$09,<'ReLayoutToolMenu',KFailed>
	subs	$FF,<KUnkn>

Spec_cpu	subs	$02,<'Bus',KErr>
	subc	<'Address',KErr>
	subc	<KIllegal,KInstr>
 	subc	<KDivZ>
	subc	<'CHK',KInstr>
	subc	<'TRAPV',KInstr>
	subc	<'Privilege',KViol>
	subc	<'Trace'>
	subc	<KLine,'A',KInstr>
	subc	<KLine,'F',KInstr>
	subs	$0D,<'Coprocessor pro',KTo,'col',KViol>
	subc	<'Stack',KFrame,' format',KErr>
	subc	<KUninit,KInterr>
	subs	$18,<'Spurious ',KInterr>
	subs	$30,<KFFP,'branch on set or unordered contition'>
	subc	<KFFP,'inexact result'>
	subc	<KFFP,KDivZ>
	subc	<KFFP,'und',KErflow>
	subc	<KFFP,'operand',KErr>
	subc	<KFFP,'ov',KErflow>
	subc	<KFFP,'signaling NAN'>
	subs	$38,<KMMU,'configuration',KErr>
	subc	<KMMU,KIllegal,' operation'>
	subc	<KMMU,'invalid access level'>
Spec_layers
Spec_math
Spec_icon
Spec_diskfont
Spec_audio
Spec_utility
Spec_keymap
Spec_gameport
Spec_keyboard
Spec_cia
Spec_misc
Spec_diskcopy
Spec_gadtools
Spec_unknown	subs	$FF,<KUnkn>

	even

	ifd	DEBUGGING
DBPrint	mpush	a0-a6/d0-d7
	call	exec,RawIOInit
	lea	_LVORawPutChar(a6),a2
	call	RawDoFmt
	mpop	a0-a6/d0-d7
	rts
	endc

EndSkip
