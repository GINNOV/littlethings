;---------------T-------T---------------T------------------------------------T
;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»
;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»
; This source is © Copyright 1992-1995, Jesper Skov.
; Read "GhostRiderSource.ReadMe" for a description of what you may do with
; this source!
;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»
; Please do not abuse! Thanks. Jesper
;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»
;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»

	rem
;-----------------------------------------------------------------------------;
;-	 	      GhostRider Overall History	-;
;-----------------------------------------------------------------------------;
190894.0926a	Show task calc PC based on kick ver (pre/post 3.0)
290894.0926b	Added (!) marker for sysdisplay reset in mon list display.
           c	Added PREF+HARDWARE to internal dump.
           d	Added internal trace offset in header.
           e	Added Generic entry.
310894.0926f	Fixed ECS mon command freeze-up. Also entry freeze from
           	dblNTSC.
060994.0926g	Added disk verify and cmd verify (toggles verify).
           h	Again fixed display start time (waitvert(4) now dead).
           i	Changed exit-custom programming. (now executes program)
           j	Changed pal/ntsc cmds to new cmd xcon <p><n><0>.
080994.0927	Added pref_revision to version cmd.

	erem

;w; marks bra.w tables

	incdir	gri:
	include	keyboard_base.i

Call	MACRO
	jsr	_LVO\1(a6)
	ENDM

Push            macro                           ;push all or selected regs
                ifc     all,\1                  ;on the stack
                movem.l d0-a6,-(a7)
                else
                movem.l \1,-(a7)
                endc
                endm

Pull            macro                           ;pull all or selected regs
                ifc     all,\1                  ;from the stack
                movem.l (a7)+,d0-a6
                else
                movem.l (a7)+,\1
                endc
                endm

grcall	MACRO
	jsr	_LVO\1(b)
	ENDM

grgo	MACRO
	jmp	_LVO\1(b)
	ENDM

SourceText	macro
	dc.b	'#0927'
	endm
DateText	macro
	dc.b	'08.09.94'
	endm
VersionText	macro
	dc.b	'1.9'
	endm

UserAssembly	set	1

KillHardGrab	set	0
HardDebug	set	0
InternalDebug	set	0
DOSExecutable	set	1


ABSAddress	set	$500000
DeadData=$570000	;location for debug data
		;:regs/32 longs from stack


	if	UserAssembly
HardDebug	set	0
KillHardGrab	set	0
DOSExecutable	set	1
InternalDebug	set	0
	endc

;UseHard=1
;UseExec=0
	incdir	include:
	include	libraryOffsets/exec_lib.i
	include	hardware/custom.i
	include	hardware/intbits.i
	include	hardware/dmabits.i

_LVOWaitTOF=	-270
_LVOLoadView=	-222


b	equr	a5
h	equr	a6
	BASEREG	B,b


	include	gri:GRConstants.0003.s
	include	gri:GRStructures.0001.s


IPEntry	macro
	dc.w	\1
	dc.l	\2
	endm


	section	code,code
StartOfGR

;---------------T-------T---------------T------------------------------------T
;- Name	: StartUp Code
;- Description	: Monitor entry code. System backup etc.
;-----------------------------------------------------------------------------;
mon
SystemEntryCLI	bra.b	CLIStart
GenericEntry	bra.b	GenericEntryz
	bra.b	NonCLIStart	;called by GRDR! (if not offset 4, change GRDR!)

GenericEntryz	move.b	#em_GenericEntry,EntryMode
	bra.w	GhostRiderStart

CLIStart	move.l	#GhostRiderCHIP,ChipMem

NonCLIStart	moveq	#0,d0	;disable org stack+pc option at
	moveq	#0,d1	;CLI entry

SystemEntryAdd	lea	B,b
	move.l	$4.w,a6

	move.l	d0,SysOrgPC(b)
	move.l	d1,SysOrgStack(b)

	Call	Disable

	lea	GFXName(b),a1
	Call	OldOpenLibrary
	move.l	d0,a6

	move.l	38(a6),SysEntryCopper0(b)
	move.l	50(a6),SysEntryCopper1(b)

	move.l	gb_actiview(a6),SystemView(b)

	move.l	a6,a4

	move.l	$4.w,a6
	move.b	#em_SystemEntry,EntryMode(b);set entrymode
	lea	GhostRiderStart(pc),a5
	jsr	-30(a6)	;enter in supervisor-mode

	move.l	a4,a6
	lea	B,b

	moveq	#0,d0
	move.b	ScreenMode(b),d0;This will be 0 at first entry
	mulu	#mon_SizeOf,d0
	lea	pr_Monitors(b),a0
	add.w	d0,a0
	tst.b	mon_SysView(a0)	;reset system view at entry?
	beq.b	.NoViewReset

	sub.l	a1,a1
	Call	LoadView
	Call	WaitTOF
	Call	WaitTOF

.NoViewReset	move.l	SystemView(b),a1
	Call	LoadView
	Call	WaitTOF
	Call	WaitTOF

	lea	$dff000,a4
	move.l	gb_copinit(a6),cop1lc(a4)
	move.w	#0,copjmp1(a4)

	move.l	a6,a1
	move.l	$4.w,a6
	Call	CloseLibrary

	tst.b	pr_FixKeyboard(b);clear matrix?
	beq.b	.NoMatrixFix

	lea	.keyboardname(pc),a1
	lea	DeviceList(a6),a0
	Call	FindName
	tst.l	d0
	beq.b	.NoMatrixFix
	move.l	d0,a0
	lea	kb_QualifierFlags(a0),a0;get to Qualifier Flags
	and.b	#$4,(a0)+	;kill all but CapsLock
	moveq	#$C-1,d1
.ClearMatrix	clr.b	(a0)+
	dbra	d1,.ClearMatrix
	and.b	#$04,(a0)	;again the qualifier

	move.l	d0,a0
	move.w	kb_RAWKEYBufferCurrent(a0),d0
	move.w	d0,d1
	addq.w	#4,d1
	and.w	#$7f,d1
	move.w	d1,kb_RAWKEYBufferCurrent(a0)

	move.w	d0,d1
	subq.w	#4,d1	;get to previous
	and.w	#$7f,d1
	move.l	kb_RAWKEYBuffer(a0,d1.w),d1
	or.l	#$00800000,d1	;or RELEASE bit
	move.l	d1,kb_RAWKEYBuffer(a0,d0.w);and set in current

.NoMatrixFix	Call	Enable

	moveq	#0,d0
	rts

.keyboardname	dc.b	'keyboard.device',0
	even

	dc.b	'$VER:'
VersionString	dc.b	'GhostRider '
	VersionText
	dc.b	' ('
	DateText
	dc.b	') © 1992-1994 Jesper Skov.',10
	dc.b	'Assembled from source '
	SourceText
	dc.b	'.',0
	even

	dc.l	'GRIP'
GRInternalPtr	IPEntry	ip_SysEntry,SystemEntryAdd
	IPEntry	ip_RSTEntry,ResetEntry
	IPEntry	ip_NMIEntry,GhostRider
	IPEntry	ip_PrefsBase,LoadedPrefs
	IPEntry	ip_SetPort,SetMessagePort
	IPEntry	ip_RemPort,RemMessagePort
	IPEntry	ip_SetBRKPT,SetBreakPointFunktion
	IPEntry	ip_ClrBRKPT,ClrBreakPointFunktion
	dc.w	ip_END

	dc.l	'RST!'
ResetEntry	move.b	#em_ResetEntry,EntryMode;set init stuff
	clr.b	EntryCount
	move.w	SR,StatusReg;put SR
	move.l	a7,ResetStack;put stack

	st.b	GURUEntry	;signal GURU
	cmp.l	#'HELP',0.w
	beq.w	GhostRiderStart

	clr.b	GURUEntry
	move.b	pr_ResetEntry,d0
	bmi.b	.noentry
	beq.w	GhostRiderStart
	move.b	$bfe001,d1
	and.b	#1<<6,d1	;left-mouse flag
	move.b	$dff016,d2
	and.b	#1<<2,d2	;right-mouse flag

	cmp.b	#re_RightMouse,d0
	bne.b	.checkright
	tst.b	d1	;re_right: right+, left-
	beq.b	.noentry
	tst.b	d2
	beq.w	GhostRiderStart
	bra.b	.noentry

.checkright	cmp.b	#re_LeftMouse,d0
	bne.b	.checkleft
	tst.b	d2	;re_left: right-, left+
	beq.b	.noentry
	tst.b	d1
	beq.w	GhostRiderStart
	bra.b	.noentry

.checkleft	cmp.b	#re_Joystick,d0
	bne.b	.noentry
	btst	#7,$bfe001	;re_joystick: joystick+
	beq.w	GhostRiderStart

.noentry	clr.b	EntryMode;clear entrymode(if rst in freeze)
	jmp	(a5)

BreakPointEntry	tst.b	EntryMode;Already running!
	beq.b	.enter
	rte

.BPOK	Pull	d0/d1/a0
	move.b	#em_BreakPoint,EntryMode;set entry mode
	bra.w	GhostRiderStart	;and start the monitor

.enter	Push	d0/d1/a0
	moveq	#0,d0
	move.b	BreakPointCount,d0
	subq.w	#1,d0
	move.l	3*4+2(a7),d1
	subq.l	#2,d1	;calc where the exception hit
	lea	BreakPointTable,a0
.checkforbps	cmp.l	(a0),d1
	beq.b	.BPOK
	addq.l	#6,a0
	dbra	d0,.checkforbps
	Pull	d0/d1/a0	;if not found in list
BPContinue	jmp	0	;execute original command
BPFoolProof	rte

TempA0Storage	dc.l	0

EntryCount	dc.b	0
	dc.b	0
	dc.l	'NMI!'
GhostRider	addq.b	#1,EntryCount

;	move.l	#'GRI!',-(a7)
;.GRCheck2	cmp.l	#'GRI!',4+2+4+2(a7);check '010+ stackformat
;.GRCheck3	beq.b	.DontEnter
;	cmp.l	#'GRI!',4+2+4(a7);check '000 stackformat
;	bne.b	.oktoenter
	cmp.b	#1,EntryCount
	beq.b	.oktoenter
.DontEnter;	addq.l	#4,a7	;return if double entry/already running
	subq.b	#1,EntryCount
	rte

.DontEnterA0	move.l	TempA0Storage(pc),a0
	bra.b	.DontEnter

.oktoenter;	move.l	a0,TempA0Storage
;	lea	GhostRider(pc),a0
;	cmp.l	4+2(a7),a0	;check '020+ didn't re-NMI at entry
;	beq.b	.DontEnterA0	;if so, fast exit
;	lea	.GRCheck2(pc),a0
;	cmp.l	4+2(a7),a0	;check '020+ didn't re-NMI at entry
;	beq.b	.DontEnterA0	;if so, fast exit
;	lea	.GRCheck2(pc),a0
;	cmp.l	4+2(a7),a0	;check '020+ didn't re-NMI at entry
;	beq.b	.DontEnterA0	;if so, fast exit
;	move.l	TempA0Storage(pc),a0

	cmp.l	#GhostRider,2(a7)
	beq.b	.DontEnter

	tst.b	EntryMode;Already running
	bne.b	.DontEnter

	cmp.b	#1,EntryCount
	bne.b	.DontEnter

	move.b	#em_NMIEntry,EntryMode;set entry mode



;	addq.l	#4,a7	;remove safety guard

	clr.b	EntryCount

	move.l	d0,-(a7)

	tst.b	pr_NMIROMCheck;enter if in ROM?
	bne.b	.notinROM	;it is "NMI entry from ROM y/n"
	move.w	2+4(a7),d0
	and.w	#$fff8,d0
	cmp.w	#$00f8,d0	;in the area $f80000-$ffffff?
	bne.b	.notinROM

.quitentry	move.l	(a7)+,d0
	clr.b	EntryMode
	rte		;return

.notinROM	move.l	(a7)+,d0

.noROMCheck	clr.b	DoBruteCopSearch
	btst	#2,$DFF016	;override prefs if requested
	bne.b	.BruteCopSearch	;and do brute-search
	st.b	DoBruteCopSearch
.BruteCopSearch

GhostRiderStart	movem.l	d0-a7,Regs

	move.w	#$2700,SR	;set SR

	move.b	#$03,$bfe200	;init hard-pointers
	move.b	#$02,$bfe000

	lea	B,b	;get bases
	lea	$dff000,a6

	move.l	usp,a0
	move.l	a0,UserStack(b)	;set USP

	move.l	a7,EntrySuperStack(b)

	move.b	EntryMode(b),d1
	cmp.b	#em_ResetEntry,d1;reset entry?
	bne.b	.checkother
	move.l	AddressRegs+5*4(b),PCReg(b);set PC
	move.w	#$2000,d0	;set SSP in A7
	bra.b	.setrest

.checkother	cmp.b	#em_SystemEntry,d1	;system entry?
	bne.b	.Default	;if system, check OrgSysVectors
	move.l	SysOrgStack(b),d0
	beq.b	.Default
	move.l	SysOrgPC(b),d1
	beq.b	.Default
	move.l	d0,UserStack(b)	;fake user stack! (may cause trouble later!!)
	move.l	d1,PCReg(b)	;fake PC
	moveq	#0,d0	;"set" SR = $0000 - assume user-entry
	addq.w	#6,a7	;"correct" SV stack
	bra.b	.setrest

.Default	move.w	(a7)+,d0	;get SR;executed on nmi/bp and system
	move.l	(a7)+,PCReg(b)	;get PC and put
.setrest	move.w	d0,StatusReg(b)	;put SR
	move.l	a7,SuperStack(b);put _incorrect_ SSP

;!!!!!!!!!!!!!!!!!!!!!!!no stack usage before this point!!!!!!!!!!!!!!!!!!!!!!!
	lea	GhostRiderStackEnd,a7;set new stackpointer

	lea	$de0000,a0
	move.w	(a0),WatchDogTimeout(b)
	and.w	#$7f7f,(a0)	;enable timeout!

	move.l	#GhostRiderCHIPSize,ChipSize(b);set needed chip size

	bsr.w	CheckCPU

	bsr.w	IDChips

	move.l	UserStack(b),a0

	tst.w	CPUType(b)	;if run on '010+
	beq.b	.MC68000
	cmp.b	#em_ResetEntry,EntryMode(b)
	beq.b	.MC68000	;skip if resetentry
	addq.l	#2,SuperStack(b);remember to remove 'stackformat'-word
			;!assume! short format!
.MC68000	move.l	SuperStack(b),a1
	move.w	StatusReg(b),d0
	btst	#13,d0
	beq.b	.userentry
	exg	a0,a1
.userentry	move.l	a0,Regs+15*4(b)	;put correct A7

;	bsr.w	EntryCACR	;Trashed! CACR stored in CheckCPU
	bsr.w	CacheOff

	tst.b	FirstEntry(b)	;Call this routine 1 time only
	bne.b	.NotFirstEntry
	bsr.w	HandleFirstEntry
	st.b	FirstEntry(b)
.NotFirstEntry

;---- Find max chip address
	sub.l	a2,a2	;find max chip
	move.l	#'Zest',d3
	move.l	#'Skov',d4
	lea	$200000,a0	;2mb chip?
	lea	$100000,a1
	move.l	(a1),d0	;get old vals
	move.l	(a2),d1
	move.l	d3,(a2)	;store new
	move.l	d4,(a1)
	move.l	(a1),d6	;get new
	move.l	(a2),d7
	move.l	d0,(a1)	;store old
	move.l	d1,(a2)
	cmp.l	d7,d6	;check (xxxx)<>0
	bne.b	.GotChip	;if <> 2MB chip
	lea	$100000,a0	;else check 1mb chip
	lea	$80000,a1
	move.l	(a1),d0
	move.l	(a2),d1
	move.l	d3,(a2)
	move.l	d4,(a1)
	move.l	(a1),d6
	move.l	(a2),d7
	move.l	d0,(a1)
	move.l	d1,(a2)
	cmp.l	d7,d6
	bne.b	.GotChip	;if <> 1MB chip
	lea	$80000,a0	;else only 512kb chip
.GotChip	move.l	a0,MaxChip(b)

	move.l	a6,a0	;get hardware reads
	lea	HardBuffer,a1
	moveq	#$20/4-1,d0
.takereads	move.l	(a0)+,(a1)+
	dbra	d0,.takereads

	lea	$f3f000,a0
	lea	$f7f000,a1
	moveq	#gr_NoGrabbing,d5
	move.w	(a0),d0
	move.w	(a1),d1
	clr.w	(a0)
	clr.w	(a1)
	move.w	#$3532,d4
	move.w	d4,(a6)
	move.w	(a0),d2
	move.w	(a1),d3
	move.w	d0,(a0)
	move.w	d1,(a1)
	sub.w	d4,d2	;check 256k grabbing
	bne.b	.not256grab
	moveq	#gr_Grabbing256k,d5
	bra.b	.GrabbingIDed

.not256grab	sub.w	d4,d3
	bne.b	.GrabbingIDed
	moveq	#gr_Grabbing512k,d5

.GrabbingIDed
	if	KillHardGrab=1
	moveq	#0,d5
	endc

	move.b	d5,GrabbingSupport(b)

	move.b	GrabbingSupport(b),d0
	beq.b	.nograb
	lea	$f3f020,a0	;get grabbed hardware writes
	cmp.b	#gr_Grabbing512k,d0
	bne.b	.grabs256k
	lea	$f7f020,a0
.grabs256k	moveq	#[$200-$20]/4-1,d0
	lea	HardBuffer+$20,a1
.takegrab	move.l	(a0)+,(a1)+
	dbra	d0,.takegrab
.nograb
	move.w	#$7fff,d6
	cmp.b	#em_ResetEntry,EntryMode(b)
	bne.b	.resetkiller
	move.w	d6,intena(h)	;disable system (no fuz when
	move.w	d6,intreq(h)	;reset entry)
	move.w	d6,dmacon(h)
	bra.b	ResetOn

.resetkiller	move.w	d6,intena(h)	;kill irqs
	move.w	dmaconr(h),d7
	move.w	#(~$8600)&$ffff,dmacon(h);kill all but blitterDMA
	moveq	#$40,d0	;wait two frames
	grcall	WaitVertical	;so any copper programming of
	moveq	#$40,d0	;blitter is finished
	grcall	WaitVertical

	btst	#14,dmaconr(h)	;then wait for blitter to finish
.WBLoop	btst	#14,dmaconr(h)
	bne.b	.WBLoop

	move.w	intreqr(h),intreqr+HardBuffer;get correct irqreq
	move.w	d6,intreq(h)
	or.w	dmaconr(h),d7	;get last two bits if not disabled
	move.w	d7,dmaconr+HardBuffer;put correct dmacon
	move.w	d6,dmacon(h)	;kill DMA

ResetOn	bsr.w	LocateCopper

	lea	$bfd100,a0	;init disk regs
	st.b	$0200(a0)
	st.b	(a0)
	move.b	#%10000111,(a0)
	st.b	(a0)

	lea	$bfd000,a0 ;goof from beer
	move.b	#3,$1201(a0)
	st.b	$1301(a0)
	st.b	$0300(a0)
	st.b	$1c01(a0)
	move.b	#$80,$1e01(a0)
	move.b	#$88,$1d01(a0)
	tst.b	$1d01(a0)
	sf.b	$0e00(a0)
	move.b	#$7f,$0d00(a0)
	tst.b	$0d00(a0)


	bsr	AllocateWorkMem

	bsr.w	GetVBR	;get backup of exception vectors
	lea	VectorBuffer,a1
	move.w	#$c0/4-1,d0
.copyvectors	move.l	(a0)+,(a1)+
	dbra	d0,.copyvectors

	bsr.w	GetVBR	;set irq vectors
	lea	$7ffe.w,a2
	lea	KeyIRQ-$7ffe(pc),a1
	add.w	a2,a1
	move.l	a1,$68(a0)	;set lvl 3
	move.l	a1,$78(a0)	;set lvl 6
	lea	VBlankIRQ-$7ffe(pc),a1
	add.w	a2,a1
	move.l	a1,$6c(a0)	;set lvl 5
	lea	Exception1(pc),a1
	tst.w	CPUType(b)	;set vectors for internal debugging
	beq.b	.MC68000
	lea	BusErrHandler(pc),a1;if 010+ point to RTE
.MC68000	move.l	a1,8(a0)
	lea	Exception2(pc),a1
	move.l	a1,$c(a0)
	lea	Exception3(pc),a1
	move.l	a1,$10(a0)
	lea	Exception4(pc),a1
	move.l	a1,$14(a0)
	lea	Exception5(pc),a1
	move.l	a1,$18(a0)
	lea	Exception6(pc),a1
	move.l	a1,$1c(a0)
	lea	Exception7(pc),a1
	move.l	a1,$20(a0)
	lea	Exception8(pc),a1
	move.l	a1,$24(a0)
	lea	Exception9(pc),a1
	move.l	a1,$28(a0)
	lea	Exception10(pc),a1
	move.l	a1,$2c(a0)

	move.w	#$2000,SR

	bsr.w	StartScreen
	bsr.w	InitStructures

	move.w	#$8080,dmacon(h)
	move.w	#$8380,dmacon(h)
	move.w	#GhostDMA,dmacon(h)

	move.w	#$e028,intena(h);allow irq lvl 3,5 & 6!

	grcall	READMOUSE

	bsr.w	CacheOn

ReGO	move.l	a7,ExceptionStack(b);for easy exit on exception

	IF	InternalDebug
	bsr.w	GetVBR
	move.l	#NMIException,$7c(a0)
	ENDC

GO	bsr.w	GhostRiderMon

ExceptionExit	grcall	ExitDisk	;set drives in entry-pos

	move.w	#$2700,sr	;don't let irqs start before time

	move.w	#$7fff,d0
	move.w	d0,intena(h)
	move.w	d0,intreq(h)
	move.w	d0,dmacon(h)
	move.b	#$7f,CIAB_ICR

	bsr.w	GetVBR	;restore exception vectors
	lea	VectorBuffer,a1
	move.w	#$c0/4-1,d0
.copyvectors	move.l	(a1)+,(a0)+
	dbra	d0,.copyvectors

	bsr	FreeWorkMem

	bsr.w	FlushCache
	bsr.w	ExitCACR

	move.w	WatchDogTimeout(b),$de0000;reset watchdog time

	move.b	EntryMode(b),d0
	cmp.b	#em_ResetEntry,d0
	beq.w	ResetExit

	cmp.b	#em_SystemEntry,d0
	bne.b	.getcopperfixed
; If SystemEntry leave to caller to re-setup display
;	move.l	SysEntryCopper0(b),cop1lc(h)
;	move.w	#0,copjmp1(h)
	bra.b	.fixedSystem

.getcopperfixed	lea	ExitCopper1+4(b),a0;first set Cop2
	move.l	-(a0),d0
	bmi.b	.noforcecop2	;skip if no force
	move.l	d0,cop2lc(h)

.noforcecop2	move.l	-(a0),d0	;check force on cop1
	bmi.b	.noforcecop1	;give up!

.copperset	move.l	d0,cop1lc(h)	;set copper1
.noforcecop1
	move.b	ActiveCopper(b),d0
	bne.b	.docopper1
	move.w	d0,copjmp1(h)
	bra.b	.coppersdone

.docopper1	move.w	d0,copjmp2(h)
.coppersdone

;restore all blitter regs, screen modulos etc
.fixedSystem	move.w	#$8000,d0	;restart dma+IRQ
	move.w	dmaconr+HardBuffer,d1
	or.w	d0,d1
	move.w	d1,dmacon(h)
	move.w	intreqr+HardBuffer,d1
	or.w	d0,d1
	move.w	d1,intreq(h)
	move.w	intenar+HardBuffer,d1
	or.w	d0,d1
	move.w	d1,intena(h)

;---- set to whatever the user had in mind :-)
	bsr.w	ProgramCustom

	move.l	EntrySuperStack(b),a7
			;go command will change the
			;return address at ExitSP+2

	tst.b	SubCallMode(b)
	bne.b	.SubCall

	movem.l	Regs,d0-a6;get regs and return
	clr.b	EntryMode
	rte

.SubCall	bsr.w	FlushCache
	move.b	EntryMode(b),EntryModeSC(b)
	clr.b	EntryMode(b)
	clr.b	SubCallMode(b)
	movem.l	Regs,d0-a6;get regs and return
;set SR
	jsr	$0.l
SubCallAddress=*-4

	cmp.b	#et_Call,SubCallMode
	bne.b	.ReEnterMonitor
	rte		;presume em_CallExit

.ReEnterMonitor	move.b	EntryModeSC,EntryMode
	bra.w	GhostRiderStart


ResetExit	moveq	#0,d0	;set beamcon0 according to CHIP ID
	tst.b	PALMachine(b)
	beq.b	.NTSCMachine
	moveq	#$20,d0
.NTSCMachine	move.w	d0,beamcon0(h)

	movem.l	Regs,d0-a7
	move.l	ResetStack,a7
	clr.b	EntryMode
	jmp	(a5)


;---- Call this for emergency exit!
BreakOut	move.l	ExceptionStack(b),a7;then try exit
	bra.w	ExceptionExit

;----------------------------------------------------
;- Name	: CPU ID Routines
;- Description	: Identifies CPU + Cache control routines
;- Notes	:
;----------------------------------------------------
;- 270893.0000	Included in routine index.
;----------------------------------------------------

;---- Call at exit to restore entry CACR
ExitCACR	move.w	CPUType(b),d0
	btst	#1,d0
	beq.b	.nocache
	move.l	CPUCACR(b),d0
	movec	d0,CACR
.nocache	rts


;---- Disable all caches
CacheOff	moveq	#0,d0
	move.l	#$0101,d1	;mask for cache enable bits
	bra.b	CacheControl


;---- Enable all caches
CacheOn	move.l	#$0101,d0
	move.l	d0,d1
	bra.w	CacheControl

;Alignment in this routine is important!
	CNOP	0,4

CacheControl	Push	d2-d4
	move.w	CPUType(b),d4
	btst	#1,d4
	beq.b	.nocache

	and.l	d1,d0
	or.w	#$0808,d0
	not.l	d1

	MOVEC	CACR,D2
	BTST	#$03,D4
	BEQ.B	.LB_0CD0

	SWAP	D2	;make '040 cacr look like '030
	ROR.W	#8,D2
	ROL.L	#1,D2
	MOVE.L	D2,D3
	ROL.L	#4,D3
	OR.L	D3,D2

.LB_0CD0	MOVE.L	D2,D3
	AND.L	D1,D2
	OR.L	D0,D2

	BTST	#$03,D4	;make '030 cacr look like '040
	BEQ.B	.LB_0CEC

	ROR.L	#1,D2
	ROL.W	#8,D2
	SWAP	D2
	AND.L	#$80008000,D2
	NOP	
	CPUSHA	BC
.LB_0CEC	NOP	
	MOVEC	D2,CACR
	NOP	
.nocache	Pull	d2-d4
	rts


;---- flush cache if any
FlushCache	move.w	CPUType(b),d0
	btst	#1,d0
	beq.b	.nocache	;only flush 020+
	btst	#3,d0
	bne.b	.cic_040
	movec	cacr,d0
	ori.w	#$0808,d0	;flush I+D
	movec	d0,cacr
.nocache	rts

.cic_040	cpusha	bc
	rts

;---- Get VBR to A0 if CPU>'000
GetVBR	sub.l	a0,a0
	tst.w	CPUType(b)
	beq.b	.m68k
	move.l	CPUVBR(b),a0	;if '010+ get VBR
.m68k	rts

;---- Get CACR if CPU>'010
;-- Output: d0 - CACR
;----
GetCACR	moveq	#0,d0
	move.w	CPUType(b),d0
	btst	#1,d0
	beq.b	.noCACR	;only if '020+
	movec	cacr,d0
	rts

.noCACR	moveq	#0,d0
	rts

;---- Put data to CACR if CPU>'010
;-- Input: d0 - data
;----
PutCACR	move.w	CPUType(b),d1
	btst	#1,d1
	beq.b	.noCACR
	movec	d0,cacr
.noCACR	rts	


;---- Identify the chips
IDChips	move.b	vposr(h),d0
	move.b	d0,BltChip(b)
	btst	#8,d0	;PAL/NTSC machine?
	seq.b	PALMachine(b)

	move.b	deniseid+1(h),d1
	cmp.b	d1,d0	;if equal, 0th revision
	bne.b	.PlusRev
	moveq	#0,d1
.PlusRev	move.b	d1,GFXChip(b)
	btst	#2,d1
	seq.b	AGAMachine(b)
	
	rts

;---- Check CPU/FPU type. Call from SV. Return types in D0 (exec-format :-)
;- ZVersion: Takes care of VBR-value. Stores reg-values BEFORE trashing.
CheckCPU	MOVEM.L	A0-a4,-(A7)
	lea	$10.w,a4	;illegal cmd
	MOVE.L	(a4),A0
	LEA	.CPUCheckExit00(PC),A3
	MOVE.L	A3,(a4)
	MOVE.L	A7,A1
	MOVEQ	#$00,D0	;set 000
	MOVEC	VBR,a2
	move.l	a2,CPUVBR(b)
	add.w	a4,a2
	move.l	a0,(a4)
	lea	.CPUCheckExit10(pc),a3
	move.l	(a2),a0
	move.l	a3,(a2)	;set correct IllCmd

	moveq	#1,d0	;set 010
	movec	cacr,d1
	move.l	d1,CPUCACR(b)	;store

	or.w	#$0101,D1	;only OR, so 040 settings will not die
	MOVEC	D1,CACR
	MOVEC	CACR,D1

	moveq	#%111,D0	;set 030 if Data cache enabled
	BTST	#$08,D1
	Bne.b	.CPUCheckExit10
	moveq	#%11,D0	;set 020 if not data, but instr cache enabled
	BTST	#$00,D1
	Bne.b	.CPUCheckExit10
	moveq	#%1111,D0	;set 040 if none of the '030 type cache
			;settings was set.
.CPUCheckExit10	move.l	a0,(a2)
	bra.b	.CPUCheckExit

.CPUCheckExit00	MOVE.L	A0,(a4)

.CPUCheckExit	MOVE.L	A1,A7
	MOVEM.L	(A7)+,A0-A4
	move.w	d0,CPUType(b)	;only ID MC680x0 family members. No FPU
	RTS

;----------------------------------------------------
;- Name	: ProgramCustom
;- Description	: Program custom registers at exit
;----------------------------------------------------
;- 070994	Implemented
;----------------------------------------------------
ProgramCustom	move.w	ExitBeamcon(b),d0
	bmi.b	.NoBeamcon
	move.w	d0,beamcon0(h)	;set beamcon if required
.NoBeamcon
	move.l	CustomProgram(b),d0
	beq.b	.NoProgram
	move.l	d0,a0
.ProgramLoop	move.w	(a0)+,d0
	btst	#0,d0
	bne.b	.NoProgram
	cmp.w	#-1,d0	;end code with -1
	beq.b	.NoProgram
	move.w	(a0)+,(h,d0.w)
	bra.b	.ProgramLoop

.NoProgram	rts

;----------------------------------------------------
;- Name	: Exception routines
;- Description	: Handles exceptions
;----------------------------------------------------
;- 270893	Included in routine index.
;----------------------------------------------------

;Exception1	moveq	#0*2,d6	;Bus Error (MC68000)
;	bra.w	ExceptionHandlePC
;
;BusErrHandler	bclr	#0,10(a7)	;Tell CPU to get on with it.
;	move.w	#$0f0,$dff180	;Show user that we're runnin at half steam
;.exit	rte


BusErrHandler	move.w	#$2700,sr
	lea	$dff000,h
	lea	B,b

	move.l	BusErrorStack(b),a7
	move.w	#$0008,-(a7)

.MC68000Entry	move.l	BusErrorRoutine(b),-(a7)
	move.w	#$2000,-(a7)

	clr.b	CurKey(b)
	clr.b	LastKey(b)

	rte

Exception1	move.w	#$2700,sr	;Bus Error MC68000
	lea	$dff000,h
	lea	B,b

	move.l	BusErrorStack(b),a7
	bra.b	BusErrHandler\.MC68000Entry


	rem
	move.l	a0,-(a7)
	lea	4(a7),a0
setoff	set	0
	rept	15
	move.l	(a0)+,$1c0000+setoff
setoff	set	setoff+4
	endr
	move.w	#$3532,-(a0)
	move.l	(a7)+,a0
	rte
	erem

Exception2	moveq	#1*2,d6	;Address Error
	bra.b	ExceptionHandlePC

Exception3	moveq	#2*2,d6	;Illegal Instruction
	bra.b	ExceptionHandlePC

Exception4	moveq	#3*2,d6	;Zero Divide
	bra.b	ExceptionHandlePC

Exception5	moveq	#4*2,d6	;CHK
	bra.b	ExceptionHandlePC

Exception6	moveq	#5*2,d6	;TRAPV
	bra.b	ExceptionHandlePC

Exception7	moveq	#6*2,d6	;Privelege Instruction
	bra.b	ExceptionHandlePC

Exception8	moveq	#7*2,d6	;Trace
	bra.b	ExceptionHandlePC

Exception9	moveq	#8*2,d6	;Line 1010
	bra.b	ExceptionHandlePC

	IF	InternalDebug
EasyNMI	rte
NMIException	cmp.b	#$23,(a7)	;any irqs running?
	beq.b	EasyNMI	;if so, quit

	bsr.w	GetVBR
	move.l	#EasyNMI,$7c(a0)
	moveq	#10*2,d6
	bra.b	ExceptionHandlePC
	ENDC

Exception10	moveq	#9*2,d6	;Line 1111

ExceptionHandlePC
	move.l	2(a7),d7

ExceptionHandle	move.w	#$4000,$dff09a	;disable IRQs
	if	HardDebug=1	;get precise debug data-
	lea	DeadData,a6
	movem.l	d0-a7,(a6)
	lea	16*4(a6),a6
	move.l	a7,a0
	moveq	#31,d0
.copystack	move.l	(a0)+,(a6)+
	dbra	d0,.copystack
	endc

	lea	B,b
	lea	$dff000,h

	grcall	ClearScreen
	lea	ExceptionInfo(b),a0
	grcall	Print

	lea	TextLineBuffer(b),a0;print exception-type
	lea	ExceptionTxtTab(b),a1
	move.w	(a1,d6.w),d0
	lea	ExceptionTexts(b),a1
	lea	(a1,d0.w),a1
.movetxt	move.b	(a1)+,(a0)+
	bne.b	.movetxt

	move.b	#' ',-1(a0)
	move.l	#mon,d0
	move.l	d0,d7
	grcall	PrintHex8	;mon start
	move.b	#',',(a0)+
	move.b	#' ',(a0)+
	move.l	2(a7),d0
	grcall	PrintHex8	;PC
	move.b	#',',(a0)+
	move.b	#' ',(a0)+
	sub.l	d7,d0
	grcall	PrintHex8	;Offset
	move.b	#',',(a0)+
	move.b	#' ',(a0)+
	move.l	a7,d0
	grcall	PrintHex8	;and stack
	clr.b	(a0)
	lea	TextLineBuffer(b),a0
	grcall	Print
.waitexit	btst	#6,$bfe001	;wait for lmouse
	bne.b	.waitexit

	bra.w	BreakOut	;try to return to system


;----------------------------------------------------
;- Name	: AllocateWorkMem
;- Description	: Swap chipmem with screen, then copy remaining chip to disk
;- 	  buffer and at last copy copper(etc) to chip.
;----------------------------------------------------
FreeWorkMem
AllocateWorkMem	Push	d0/d1/a0/a1
	move.l	ChipBackup(b),d0	;If this var is NULL, the chip mem is
	beq.b	.StaticChip	;a static (allocated) area. No backup
			;and no restore. This is the default
			;CLI startup procedure. Only GRDR can
			;allocate swap buffer.

	move.l	ChipMem(b),a0
	move.l	d0,a1

	move.w	#GRChipHunkLen/4-1,d0
.DoSwap	move.l	(a0),d1
	move.l	(a1),(a0)+
	move.l	d1,(a1)+
	dbra	d0,.DoSwap

.StaticChip	Pull	d0/d1/a0/a1
	rts

;----------------------------------------------------
;- Name	: Locate Copper Lists
;- Description	: Scan Chip-mem twice in two blocks for the copperlists.
;- Notes	: Must be run in chipmem with disabled caches.
;----------------------------------------------------
;- 071193.0000	First version... Still needs to be checked on an '040!
;- 281293	Checked on '040/AGA. Working!
;----------------------------------------------------
LocateCopper	move.w	#$7fff,intena(h)
	move.w	#$7fff,intreq(h)
	move.w	#$7fff,dmacon(h)

	moveq	#%11,d7
	moveq	#-1,d0
	moveq	#-1,d1

	tst.b	DoBruteCopSearch(b)
	bne.w	.BruteSearch	;and do brute-search

	cmp.b	#em_SystemEntry,EntryMode(b)
	bne.b	.systementry
	move.l	SysEntryCopper0(b),d0;from gfx base
	move.l	SysEntryCopper1(b),d1;from gfx base
	bra.w	.foundcoppers

.systementry
.checkallreq	tst.l	CopSearchOffset(b)
	bne.b	.disabled
	tst.b	GrabbingSupport(b);no grab ->brute
	beq.w	.BruteSearch
	move.l	HardBuffer+cop1lc,d0
	move.l	HardBuffer+cop2lc,d1
	bra.w	.foundcoppers
	
.disabled	move.l	ExitCopper0(b),d0;a 0-offset=disabled. Rely on grabbing
	bpl.b	.Search0
	tst.b	GrabbingSupport(b)
	beq.b	.SkipSearch0	;skip if no grabber
	move.l	HardBuffer+cop1lc,d0;else get grabbed copper
.Search0	bclr	#0,d0
	move.l	CopSearchOffset(b),d2
	move.l	d0,a0
	lea	(a0,d2),a1
	sub.l	d2,a0
	move.l	a0,d1
	bpl.b	.ok01
	lea	$80.w,a0	;searchroutine at 0-$80
.ok01	cmp.l	MaxChip(b),a1
	blt.b	.ok02
	move.l	MaxChip(b),a1
	subq.l	#2,a1
.ok02	subq.l	#6,a1
	cmp.l	#$82,a1
	blt.b	.SkipSearch0	;skip if no space
	bsr.w	SearchCopper
	tst.w	d7
	beq.b	.foundcoppers

.SkipSearch0	move.l	ExitCopper1(b),d1
	bpl.b	.Search1
	tst.b	GrabbingSupport(b)
	beq.b	.SkipSearch1	;skip if no grabber
	move.l	HardBuffer+cop2lc,d1;else get grabbed copper
.Search1	move.l	CopSearchOffset(b),d2
	bclr	#0,d1
	move.l	d1,a0
	lea	(a0,d2),a1
	sub.l	d2,a0
	move.l	a0,d1
	bpl.b	.ok11
	lea	$80.w,a0
.ok11	cmp.l	MaxChip(b),a1
	blt.b	.ok12
	move.l	MaxChip(b),a1
	subq.l	#2,a1
.ok12	subq.l	#6,a1
	cmp.l	#$82,a1
	blt.b	.SkipSearch1	;skip if no space
	bsr.b	SearchCopper
	tst.w	d7
	beq.b	.foundcoppers

.SkipSearch1	btst	#0,d7
	beq.b	.cop0ok
	moveq	#-1,d0
.cop0ok	btst	#1,d7
	beq.b	.cop1ok
	moveq	#-1,d1
.cop1ok
.BruteSearch	lea	$80.w,a0	;scan start
	move.l	MaxChip(b),a1	;scan end
	subq.l	#2+4,a1	;don't overwrite
	bsr.b	SearchCopper	;if this search fails, CPx=-1

.foundcoppers	move.l	d0,C0Reg(b)
	move.l	d1,C1Reg(b)
	move.l	d0,ExitCopper0(b)
	move.l	d1,ExitCopper1(b)
	rts

SearchCopper	lea	CopSearchAlgo(pc),a3
	sub.l	a2,a2
	lea	CopAlgoBuffer,a4
	moveq	#CopSearchAlgoLen/4-1,d2
.SwapAreas	move.l	(a2),(a4)+
	move.l	(a3)+,(a2)+
	dbra	d2,.SwapAreas

	move.w	CPUType(b),d2
	btst	#0,d2
	beq.b	.novbr
	sub.l	a2,a2
	movec	a2,vbr
.novbr
	move.l	#$009c8001,d5
	moveq	#$fffffffe,d6

	move.w	#$8280,d2
	move.w	#$0280,a3
	lea	dmacon(h),a2

	jsr	$0002.w

	move.w	CPUType(b),d2
	btst	#0,d2
	beq.b	.novbr2
	move.l	CPUVBR(b),a0
	movec	a0,VBR
.novbr2
	lea	CopAlgoBuffer,a4
	sub.l	a2,a2
	moveq	#CopSearchAlgoLen/4-1,d2
.ReplaceArea	move.l	(a4)+,(a2)+
	dbra	d2,.ReplaceArea
	rts

;routine to be placed in chipmem and run without cache!
CopSearchAlgo	rte
.loop	move.l	(a0)+,d3
	move.l	(a0),d4
	move.l	d6,(a0)
	move.l	d5,-(a0)
	move.w	vhposr(h),color(h)
	btst	#0,d7	;scan copper 0?
	beq.b	.CheckCop1
	move.w	#0,copjmp1(h)
	move.w	d2,(a2)
	bra.w	.Scan0PipeFlush	;flush instructionpipe

.Scan0PipeFlush	move.w	a3,(a2)
	btst	#0,intreqr+1(h)
	beq.b	.CheckCop1
	move.l	a0,d0
	bclr	#0,d7	;flag copper0 found
	move.w	#$7fff,intreq(h)

.CheckCop1	btst	#1,d7
	beq.b	.notcopper1
	move.w	#0,copjmp2(h)
	move.w	d2,(a2)
	bra.w	.Scan1PipeFlush	;flush instructionpipe

.Scan1PipeFlush	move.w	a3,(a2)
	btst	#0,intreqr+1(h)
	beq.b	.notcopper1
	move.l	a0,d1
	bclr	#1,d7	;flag copper1 found
	move.w	#$7fff,intreq(h)

.notcopper1	move.l	d3,(a0)+
	move.l	d4,(a0)
	tst.w	d7
	beq.b	.BothFound
	subq.l	#2,a0
	cmp.l	a0,a1
	bne.b	.loop

.BothFound	move.w	#$7fff,intreq(h)
	rts
	dc.w	0
	dc.l	0
	dc.l	0	;must be at offset $7c
CopSearchAlgoLen=*-CopSearchAlgo
	if	CopSearchAlgoLen<>$80
	fail	;"Coper searchroutine has wrong length!"
	endc

;----------------------------------------------------
;- Name	: Initial Code.
;- Description	: All initial routines like OpenScreen.
;- Notes	:
;----------------------------------------------------

;---- SetupHWDisplay
;- Setup display and sprites accoring to selected screenmode
;----
SetupHWDisplay
;	moveq	#$4,d0
;	bsr.w	WaitVertical

	move.l	ChipMem(b),a4

	moveq	#0,d0
	move.b	ScreenMode(b),d0
	mulu	#mon_SizeOf,d0
	lea	pr_Monitors(b),a3
	add.w	d0,a3

	moveq	#0,d0	;modulo in NonLace mode

	btst	#2,mon_bplcon0+1(a3)
	beq.b	.NoLace

	moveq	#80,d0

.NoLace	move.w	d0,bpl1mod(h)
	beq.b	.LongFrame

	btst	#7,vposr(h)
	bne.b	.LongFrame
	moveq	#-80,d0

.LongFrame	move.b	d0,LaceMode(b)

	tst.w	mon_bplcon0(a3)	;hires/shres?
	smi.b	WidePalWait(b)	;if hires wider pal wait that shres

	lea	mon_diwstrt(a3),a2
	move.w	(a2)+,d0	;diwstart
	and.w	#$fcff,d0
	sub.w	#$0100,d0
	move.w	d0,diwstrt(h)
	and.w	#$ff00,d0
	lsr.w	#8,d0
	move.w	d0,d1
	move.b	d1,DisplayStart(b)
	moveq	#0,d1	;calculate diwstop - y
	move.b	mon_textlines(a3),d1
	move.w	d1,TextLines(b)
	asl.w	#3,d1
	move.w	d1,Lines(b)
	moveq	#11,d2
	tst.b	LaceMode(b)
	beq.b	.NoLace5
	lsr.w	#1,d1
	moveq	#6,d2
.NoLace5	add.w	d1,d0
	add.w	d2,d0

	asl.w	#8,d0

	move.w	(a2)+,d1	;diwstop
	move.b	d1,d0
	move.w	d0,diwstop(h)

	lea	.CustomTable(pc),a0

.SetCustom1	move.w	(a0)+,d0
	beq.b	.CheckCustom
	move.w	(a2)+,(h,d0.w)
	bra.b	.SetCustom1

.CheckCustom	move.b	mon_custom(a3),CustomScreen(b)
	beq.b	.NoCustom

.SetCustom2	move.w	(a0)+,d0
	beq.b	.NoCustom
	move.w	(a2)+,(h,d0.w)
	bra.b	.SetCustom2

.CustomTable	dc.w	ddfstrt,ddfstop,beamcon0,bplcon0
	dc.w	0
	dc.w	hbstrt,hbstop,hsstrt,hsstop,htotal,hcenter
	dc.w	vbstrt,vbstop,vsstrt,vsstop,vtotal,diwhigh
	dc.w	0

.NoCustom	lea	.StaticTable(pc),a0
.SetStatic	move.w	(a0)+,d0
	beq.b	.StaticEnd
	move.w	(a0)+,(h,d0.w)
	bra.b	.SetStatic

.StaticTable	dc.w	bplcon1,$0000
	dc.w	bplcon2,%0001000
	dc.w	bplcon3,$0c01
	dc.w	bplcon4,$0011
	dc.w	fmode,$0000
	dc.w	0

.StaticEnd	moveq	#0,d0
	move.b	DisplayStart(b),d0
	addq.w	#5,d0
	tst.b	LaceMode(b)
	bne.b	.Lace4
	addq.w	#5,d0	;size of header
.Lace4	move.b	d0,BlackLine(a4)
	addq.w	#1,d0	;it's that black line again :-)
	move.w	d0,StartLine(b)	;save this as startline (first txtline)
	move.b	d0,LineFix1(a4)

	move.w	Lines(b),d1
	move.w	d1,d2
	tst.b	LaceMode(b)
	beq.b	.NoLace6
	lsr.w	#1,d2
.NoLace6	add.w	d2,d0
	move.w	d0,InitLine(b)	;start line of split

	mulu	#80,d1	;calc and store the bplsize
	move.w	d1,BplSize(b)

	lea	SPRNULL(a4),a1	;set NULLSPR pointers
	move.l	a1,d0
	lea	SpriteNULL+2(a4),a1
	moveq	#5,d1
.setNULLSPR	move.w	d0,4(a1)
	swap	d0
	move.w	d0,(a1)
	swap	d0
	addq.w	#8,a1
	dbra	d1,.setNULLSPR

	lea	SPRCursor(a4),a1;set sprite cursor
	move.l	a1,d0
	move.w	d0,6+SpriteCursor(a4)
	swap	d0
	move.w	d0,2+SpriteCursor(a4)

	lea	SPRPointer(a4),a1;set sprite pointer
	move.l	a1,d0
	move.w	d0,6+SpritePointer(a4)
	swap	d0
	move.w	d0,2+SpritePointer(a4)

;---- Color settings below should be changed according to mutilsync/ESC vars
	move.w	pr_CursorColor(b),d0
	move.w	d0,color+$22(h)	;set cursor color
	move.w	d0,CursorFlashColor0(b)

	move.w	pr_ColorP1(b),color+$24(h);set pointer colors
	move.w	pr_ColorP2(b),color+$26(h)

	lea	ScreenColors+2(a4),a1;set colors according to prefs
	move.w	pr_ScreenColor0(b),d0
	move.w	d0,(a1)
	move.w	d0,CursorFlashColor1(b)
	move.w	pr_ScreenColor1(b),4(a1)

	lea	HeaderColors+2(a4),a1
	move.w	pr_HeaderColor0(b),(a1)
	move.w	pr_HeaderColor1(b),4(a1)

	tst.b	CustomScreen(b)
	beq.b	.NoMultiscan
	tst.b	AGAMachine(b)	;special color coding needed?
	bne.b	.NoMultiscan

	move.w	pr_ScreenColor0(b),d0
	move.w	pr_ScreenColor1(b),d2
	moveq	#0,d1
	moveq	#0,d3

	bsr.b	BuildECSColors

	lea	color(h),a1
	moveq	#8-1,d7
.CopyBplCols	move.w	(a0)+,(a1)+
	move.w	(a0)+,$e(a1)
	dbra	d7,.CopyBplCols

	move.w	ColorBuildTable(pc),d0

	move.w	d0,CursorFlashColor1(b);cursor flash color

	lea	ScreenColors+2(a4),a0;set correct copper cols
	lea	HeaderColors+2(a4),a1
	move.w	d0,(a0)
	move.w	d0,(a1)
	move.w	ColorBuildTable+4(pc),d0
	move.w	d0,4(a0)
	move.w	d0,4(a1)

	moveq	#0,d0
	move.w	pr_CursorColor(b),d1
	move.w	pr_ColorP1(b),d2
	move.w	pr_ColorP2(b),d3
	bsr.b	BuildECSColors

	move.w	10(a0),CursorFlashColor0(b);cursor flash color

	lea	color+$20(h),a1
	moveq	#16-1,d7
.CopySprCols	move.w	(a0)+,(a1)+
	dbra	d7,.CopySprCols

.NoMultiscan	rts


;---- Build ESC mulisync colors (SHRES)
;-- INPUT:	d0-d3	- colors
;--	a1	- HW color address
;----
BuildECSColors	lea	ColorBuildTable(pc),a0

	move.w	d0,d7
	and.w	#%110011001100,d7;ab-- cd-- ef--
	move.w	d7,(a0)
	move.w	d7,$4*2(a0)
	move.w	d7,$8*2(a0)
	move.w	d7,$c*2(a0)
	lsr.w	#2,d7	;--ab --cd --ef
	or.w	d7,(a0)
	move.w	d7,$1*2(a0)
	move.w	d7,$2*2(a0)
	move.w	d7,$3*2(a0)

	move.w	d1,d7
	and.w	#%110011001100,d7;gh-- ij-- kl--
	or.w	d7,$1*2(a0)
	move.w	d7,$5*2(a0)
	move.w	d7,$9*2(a0)
	move.w	d7,$d*2(a0)
	lsr.w	#2,d7	;--gh --ij --kl
	or.w	d7,$4*2(a0)
	or.w	d7,$5*2(a0)
	move.w	d7,$6*2(a0)
	move.w	d7,$7*2(a0)

	move.w	d2,d7
	and.w	#%110011001100,d7;mn-- op-- qr--
	or.w	d7,$2*2(a0)
	or.w	d7,$6*2(a0)
	move.w	d7,$a*2(a0)
	move.w	d7,$e*2(a0)
	lsr.w	#2,d7	;--mn --op --qr
	or.w	d7,$8*2(a0)
	or.w	d7,$9*2(a0)
	or.w	d7,$a*2(a0)
	move.w	d7,$b*2(a0)

	move.w	d3,d7
	and.w	#%110011001100,d7;st-- uv-- wx--
	or.w	d7,$3*2(a0)
	or.w	d7,$7*2(a0)
	or.w	d7,$b*2(a0)
	move.w	d7,$f*2(a0)
	lsr.w	#2,d7	;--st --uv --wx
	or.w	d7,$c*2(a0)
	or.w	d7,$d*2(a0)
	or.w	d7,$e*2(a0)
	or.w	d7,$f*2(a0)

	rts



ColorBuildTable	dcb.w	16,0


;---- Start screen
; Sets up all screen data according to prefs
;----
StartScreen	lea	CharBuffer,a0;set 1st charbuffer
	move.l	a0,CharPointer(b)

	move.l	ChipMem(b),a4
	lea	ScreenMemory(a4),a0
	move.l	a0,ScreenMem(b)

	lea	ScreenHeader(a4),a0;set header pointer
	move.l	a0,d0
	add.w	#83,a0
	move.l	a0,HeaderAddress(b);short access to header gfx

	bsr.w	SetupHWDisplay

	grcall	InitScreenPts

	grcall	INITMOUSE

;-- Peeker stuff
	move.b	#39,PeekerWidth(b)
	clr.w	PeekerModulo(b)
	move.w	pr_PeekerLines(b),d0
	cmp.w	Lines(b),d0
	blt.b	.PeekerHeightOK
	move.w	Lines(b),d0
.PeekerHeightOK	move.w	d0,PeekerLines(b)

;-- Editor y position
	move.w	TextLines(b),d1
	lsr.w	#1,d1
	move.b	d1,HexEditYPos(b);set ypos to middle of screen
	asl.w	#4,d1	;calc address of middle disaddress
	lea	DisEditorTable(b),a1
	add.w	d1,a1
	move.l	a1,DisTableAddress(b)

	moveq	#CursorX,d0
	tst.b	CustomScreen(b)
	beq.b	.FunnySprite
	moveq	#CursorXCustom,d0
.FunnySprite	move.w	d0,CursorXOffset(b)


	move.l	ChipMem(b),cop1lc(h);set copper
	move.w	#0,copjmp1(h)

	bra.w	PrintFlags	;and print flags

;---- Special initcode only executed at first entry
HandleFirstEntry:
	moveq	#ONEmsDelayPAL,d0
	tst.b	PALMachine(b)
	bne.b	.PALMachine
	moveq	#ONEmsDelayNTSC,d0
.PALMachine	move.w	d0,Delay0.1ms(b)

	move.b	pr_ScreenMode(b),ScreenMode(b)
	move.w	#-1,ExitBeamcon(b)


	st.b	DiskDMADirection(b)

	moveq	#-1,d0	;disable forced coppers
	move.l	d0,ExitCopper0(b)
	move.l	d0,ExitCopper1(b)

	move.b	pr_ClearScreen(b),ClearScreenEntry(b)

	tst.l	ChipMem(b)
	bne.b	.ChipOverride
	move.l	pr_WorkArea(b),ChipMem(b);set workmem
.ChipOverride
	move.l	pr_CopSearchOff(b),CopSearchOffset(b)

	lea	CursorSpeedTable,a1
	moveq	#0,d0
	move.b	pr_CursorRate(b),d0
	add.w	d0,d0
	move.w	(a1,d0.w),pr_CursorOff(b);copy both cursor times

	move.b	pr_DiskVerify(b),DiskVerify(b)

	lea	DiskSyncTab(b),a1
	move.w	pr_DiskSync(b),d0
	move.w	d0,d1
	swap	d0
	move.w	d1,d0
	move.l	d0,DiskSyncs(b)
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	move.l	d0,(a1)+

;pr_DDTrackLen			;set tracklength table
			;should really only be set at
			;first entry!
	lea	TrackLenTab(b),a1
	move.w	pr_DDTrackLen(b),d0
	move.w	d0,(a1)+
	move.w	d0,(a1)+
	move.w	d0,(a1)+
	move.w	d0,(a1)+
	move.w	d0,TrackLen(b)
;pr_HDTrackLen
	lea	TrackLenHTab(b),a1
	move.w	pr_HDTrackLen(b),d0
	move.w	d0,(a1)+
	move.w	d0,(a1)+
	move.w	d0,(a1)+
	move.w	d0,(a1)+

;;disEditor
	moveq	#80-8,d0	;find length
	move.b	pr_ShortAddress(b),d2
	beq.b	.notshort
	moveq	#80-6,d0
.notshort	move.b	pr_ShowCPU(b),d2
	beq.b	.noCPU
	subq.w	#2,d0	;2 chars for cpu-info
.noCPU	move.b	pr_Indirect(b),d2
	beq.b	.nosd
	sub.w	#8+8+2,d0	;space for 2*8 chars+2 spaces

;two line dis will have more space (only one address in end?)?????

.nosd	move.b	d0,DisWidth(b)

;misc
	bsr.w	ClearHistory
	rts

;---- Initialize structures ;init;
InitStructures	move.l	PCReg(b),MemoryAddress(b)
	st.b	NestedJumps(b)

	move.b	pr_CursorOn(b),CursorBlinkTime(b);set cursor timer

	move.b	pr_InsertOW(b),InsertOverwrite(b)
	clr.b	LastKey(b)
	clr.b	Control(b)

	clr.w	LastErrorNumber(b)
	clr.b	LastCMDError(b)

	st.b	ResumeCommand(b);no command to resume
	clr.b	GotHalfCmd(b)

;---- disk
	move.b	pr_SelectedDrive(b),SelectedDrive(b)
	clr.l	FirstAccess(b)	;clear first access flags
	moveq	#-1,d0
	move.l	d0,SystemTracks(b);zap system tracks
	move.l	d0,SystemTracks+4(b)
	move.w	d0,CurrentTrack(b)
	clr.b	TrackInBuffer(b)
	clr.b	TrackModified(b)
	move.w	#-1,WriteTrackNo(b)

	moveq	#11,d0
	lea	DiskSectorsTab(b),a1
	move.b	d0,(a1)+
	move.b	d0,(a1)+
	move.b	d0,(a1)+
	move.b	d0,(a1)+	;initial all disks=DD
	move.b	d0,DiskSectors(b)

	clr.b	DiskInfoFlag(b)	;set if requesting diskinfo

	rts


;----------------------------------------------------
;- Name	: EntryModeHandler
;- Description	: Handle different things according to entrymode
;----------------------------------------------------
;- 311093.0000	Controls BreakPoints
;----------------------------------------------------
EntryModeHandler
	cmp.b	#em_BreakPoint,EntryMode(b)
	bne.b	.HandlingBP
	move.l	PCReg(b),a0
	subq.l	#2,a0	;get to original address
	bsr.w	ClrBPFunction	;free BP
	tst.b	d0
	bmi.b	.HandlingBP
	move.l	a0,PCReg(b)	;and fix PC if restore OK
	move.l	a0,d0
	bsr.w	AlterExitAddress;also change exit address
;	bra.b	.HandlingBP

.HandlingBP	rts


;----------------------------------------------------
;- Name	: Screen Editor
;- Description	: Editor control routines.
;- Notes	:
;----------------------------------------------------
;- 270893.0000	Included in routine index.
;- 010993.0001	Next/Prev word now also specify beg/end word with shift.
;----------------------------------------------------

MainLoopBERR	lea	.BERRText(pc),a0
	grcall	Print
	bra.w	NoPromptNoLF

.BERRText	dc.b	pc_CLRLine,10
	dc.b	'*** Operation aborted due to a Bus Error! ***'
	dc.b	pc_CLRRest,10,pc_CLRLine,0

	even

GhostRiderMon	bsr.b	EntryModeHandler;fix BP addresses etc.

	bsr.w	PrintEntryText
	clr.b	ExitFlag(b)

	bsr.w	BackupDiskCDs

	if	HardDebug=1
	bra.w	EnableTrace
	else
	bra.w	NoPrompt	;set initial prompt
	endc

MainLoop:	lea	MainLoopBERR(pc),a0
	move.l	a0,BusErrorRoutine(b)
	move.l	a7,BusErrorStack(b)

	bsr.w	RestoreDiskCDs

	clr.b	MouseClickPos(b)

	bsr.w	PrintFlags

	tst.b	ReprintHeader(b)
	beq.b	.reprintheader
	lea	HeaderText(b),a0
	grcall	PrintHeader
	clr.b	ReprintHeader(b)

.reprintheader	moveq	#0,d0
MainLoopKeyWait	tst.b	DisplayHelp(b)
	beq.b	.nohelp
.dohelp	lea	MainHelpText(b),a0;print mainloop help
	moveq	#0,d6	;no masking
	grcall	PrintHelp
	bra.b	MainLoop

.HELPRegs	bsr.w	DisplayRegs
	bra.b	MainLoop

.nohelp	tst.b	ExitFlag(b)
	beq.b	.noexit
	rts		;icon-exit

.noexit	grcall	PasteText	;if any
;	move.b	CurKey(b),d0
	beq.b	MainLoopKeyWait
	clr.b	CurKey(b)

	move.b	Control(b),d7
	and.b	#kq_shiftmask,d7

	cmp.b	#key_up,d0
	beq.w	MCursorUp
	cmp.b	#key_down,d0
	beq.w	MCursorDown
	cmp.b	#key_right,d0
	beq.w	MCursorRight
	cmp.b	#key_left,d0
	beq.w	MCursorLeft
	cmp.b	#key_bs,d0
	beq.w	MBackSpace
	cmp.b	#key_ret,d0
	beq.w	MReturn

	cmp.b	#key_PointerPos,d0
	beq.w	MSetCur

	cmp.b	#key_tab,d0
	beq.b	MTab

	cmp.b	#key_del,d0
	beq.w	MDelete

	cmp.b	#key_help,d0	;help about errors
	bne.b	.checkhelp

	move.b	Control(b),d0
	btst	#kq_ctrl,d0	;+ctrl show registers in top two lines
	bne.b	.HELPRegs
	and.b	#kq_altmask,d0
	beq.b	SetErrorPointer
	bra.w	.dohelp	;if +alt show commands

.checkhelp	cmp.b	#' ',d0
	blt.w	MainLoop
	beq.b	.InsertLetter
	cmp.w	#$7f,d0
	bge.w	MainLoop

.Normal	tst.b	InsertOverwrite(b)
	beq.b	.goon

	bsr.w	Insert	;move other letters before printing

.goon	grgo	PrintLetter	;it gets to mainloop by itself!

.InsertLetter	tst.b	d7	;shifted space?
	beq.b	.Normal
	bsr.w	Insert
	grcall	PrintLetterN
	bra.w	MainLoop

;- Do tabular indent (just 4 spaces)
MTab	moveq	#3,d7
.InsertLoop	bsr.w	Insert
	moveq	#' ',d0
	grcall	PrintLetterR
	dbra	d7,.InsertLoop
	bra.w	MainLoop


;set new cursor position
MSetCur	pea	MainLoop(pc)
SetCursorPos	move.b	PointerXPos(b),CurXPos(b)
	move.b	PointerYPos(b),CurYPos(b)
	rts

SetErrorPointer	grcall	SetPointer	;help
	bsr.w	PrintLEInHeader
	moveq	#0,d0
	bra.w	MainLoopKeyWait

MCursorLeft	pea	MainLoop(pc)
	move.b	Control(b),d0
	and.b	#kq_altmask,d0	;check alt=prev word
	beq.b	.checkshift
	moveq	#0,d0	;get address of line
	move.b	CurYPos(b),d0
	mulu	#80,d0
	move.l	CharPointer(b),a0
	add.w	d0,a0
	moveq	#0,d0
	move.b	CurXPos(b),d0
	beq.b	.skip
	add.w	d0,a0	;get to current pos

	cmp.b	#' ',-1(a0)	;in start of word?
	beq.b	.prevspace	;if yes, search for next

	tst.b	d7
	beq.b	.findspace
.findspace2	subq.w	#1,d0	;if shifted, find space
	beq.b	.skip
	cmp.b	#' ',-(a0)
	bne.b	.findspace2
.prevspace2	subq.b	#1,d0	;and then end of prev word
	beq.b	.skip
	cmp.b	#' ',-(a0)
	beq.b	.prevspace2
	bra.b	.cheaper

.findspace	subq.w	#1,d0	;find first space on the left
	beq.b	.cheapcheck
	cmp.b	#' ',-(a0)
	bne.b	.findspace
.cheaper	addq.b	#1,d0
	move.b	d0,CurXPos(b)
.skip	rts

.cheapcheck	cmp.b	#' ',-(a0)	;little handler for alt+left on pos 1
	bne.b	.killxpos	;if first letter (pos 0)=space
	bra.b	.cheaper	;don't clear, but move to pos1

.prevspace	subq.b	#1,d0	;find end of prev word
	beq.b	.skip
	cmp.b	#' ',-(a0)
	beq.b	.prevspace
	tst.b	d7	;and if front of word
	beq.b	.findspace	;then seek space
	bra.b	.cheaper	;else accept this pos

.checkshift	tst.b	d7	;cursor to BOL
	beq.b	MCursorLeftDO
.killxpos	clr.b	CurXPos(b)
	rts

MCursorLeftDO	tst.b	CurXPos(b)	;if in column 0
	beq.b	.checkup	;check up
	subq.b	#1,CurXPos(b)	;else dec xpos
	rts

.checkup	tst.b	CurYPos(b)	;if not on pos 0,0
	beq.b	.ok
	subq.b	#1,CurYPos(b)	;go to previous line
	move.b	#79,CurXPos(b)
.ok	rts

MCursorRight	pea	MainLoop(pc)
	moveq	#0,d0	;get address of line
	move.b	CurYPos(b),d0
	mulu	#80,d0
	move.l	CharPointer(b),a0
	add.w	d0,a0
	move.b	Control(b),d0
	and.b	#kq_altmask,d0	;check alt
	beq.b	.checkshift

	moveq	#0,d0	;find start of next word
	move.b	CurXPos(b),d0
	add.w	d0,a0	;get to current pos
	moveq	#79,d1
	sub.w	d0,d1	;find seek length
	beq.b	.skip
	tst.b	d7	;shifted?
	beq.b	.findspace
.findspace2	cmp.b	#' ',(a0)+	;if so, first skip spaces
	bne.b	.findspace	;then find spaces again
	addq.w	#1,d0
	dbra	d1,.findspace2
	rts

.findspace	cmp.b	#' ',(a0)+	;first search for space
	beq.b	.checkout
	addq.w	#1,d0
	dbra	d1,.findspace
	rts

.checkout	subq.w	#1,d1	;and then make sure that there are more
	bmi.b	.skip	;words on the line
	tst.b	d7	;if shifted stay there
	bne.b	.setxpos

.findnonsp	cmp.b	#' ',(a0)+
	bne.b	.setxpos
	addq.w	#1,d0	;also skip spacesequences
	dbra	d1,.findnonsp
	rts

.checkshift	tst.b	d7	;shifted?
	beq.b	MCursorRightDO
	add.w	#80,a0	;find first non-space from right to left
	moveq	#79,d0
.findlast	cmp.b	#' ',-(a0)
	bne.b	.setxpos
	dbra	d0,.findlast
	bra.b	.skip

.setxpos	addq.w	#1,d0
	cmp.w	#80,d0
	bne.b	.subone
	subq.w	#1,d0
.subone	move.b	d0,CurXPos(b)
.skip	rts

MCursorRightDO	addq.b	#1,CurXPos(b)	;inc xpos
	cmp.b	#80,CurXPos(b)	;on new line?
	bne.b	.ok
	clr.b	CurXPos(b)	;yes, set xpos=0,and goto cursor down
	bra.b	MCursorDownDO
.ok	rts

MCursorDown	pea	MainLoop(pc)

MoveCursorDown	tst.b	d7
	bne.b	CursorToBOS
	move.b	Control(b),d0
	and.b	#kq_altmask,d0
	beq.b	MCursorDownDO	;alted=history?
	moveq	#-1,d0
	bra.b	MDoTheHistory

CursorToBOS	move.w	TextLines(b),d0
	subq.w	#1,d0	;get bottom line
	move.b	d0,CurYPos(b)	;cursor to bottom line
	rts

MCursorDownDO	move.w	TextLines(b),d0
	subq.w	#1,d0	;get bottom line
	cmp.b	CurYPos(b),d0	;cur ypos=bottom?
	beq.b	ScrollAndDelete	;yes, scroll and delete
	addq.b	#1,CurYPos(b)	;no, inc ypos
	rts

ScrollAndDelete	moveq	#1,d0	;scroll screen one up
	bsr.w	ScrollScreen
	moveq	#0,d0	;and clear the new line
	move.w	TextLines(b),d0
	subq.w	#1,d0
	grgo	ClearLine

MCursorUp	pea	MainLoop(pc)
	tst.b	d7
	bne.b	MCursorUpS	;shifted?
	move.b	Control(b),d7
	and.b	#kq_altmask,d7	;alted=scroll history
	beq.b	MCursorUpDO
	moveq	#1,d0
MDoTheHistory	bsr.w	GetHistory
	bne.b	.nohist
	lea	TextLineBuffer(b),a0
	clr.b	CurXPos(b)
	move.b	pr_Prompt(b),(a0)+
.gettxtloop	move.b	(a1)+,(a0)+
	bne.b	.gettxtloop
	move.b	#pc_CLRRest,-1(a0)
	clr.b	(a0)
	lea	TextLineBuffer(b),a0
	grcall	Print
.nohist	rts

MCursorUpS	clr.b	CurYPos(b)	;cursor to row 0 (shifted)
	rts

MCursorUpDO	tst.b	CurYPos(b)	;if not on row 0
	beq.b	.done
	subq.b	#1,CurYPos(b)	;work upwards
.done	rts

MBackSpace	moveq	#0,d0	;delete to column 0 allowed
	move.b	Control(b),d0
	and.b	#kq_altmask,d0	;check for clear screen
	bne.w	ClearScreenCMD
	pea	MainLoop(pc)
	bra.w	BackSpace

MDelete	pea	MainLoop(pc)

	move.b	Control(b),d0
	and.b	#kq_altmask,d0	;check for insert/overwrite shift
	beq.w	Delete

	not.b	InsertOverwrite(b);change mode

	bra.w	PrintFlags

;---- Insert function
;saving d0 when calling before printing letter
Insert	moveq	#0,d1
	move.b	CurXPos(b),d1
	moveq	#78,d2
	sub.w	d1,d2	;find loop-counter
	bmi.b	.InsertExit
	moveq	#0,d3
	move.b	CurYPos(b),d3
	mulu	#80,d3
	move.w	d3,-(a7)
	asl.w	#3,d3
	add.w	LineBase(b),d3
	moveq	#0,d4
	move.w	BplSize(b),d4
	cmp.l	d4,d3
	bmi.b	.fix
	sub.l	d4,d3
.fix	add.w	#79,d3
	add.l	ScreenBase(b),d3
	move.l	d3,a0
	move.w	d2,d3
.copygfxloop	move.b	-(a0),1(a0)	;move gfx letters
	move.b	1*80(a0),1+1*80(a0)
	move.b	2*80(a0),1+2*80(a0)
	move.b	3*80(a0),1+3*80(a0)
	move.b	4*80(a0),1+4*80(a0)
	move.b	5*80(a0),1+5*80(a0)
	move.b	6*80(a0),1+6*80(a0)
	move.b	7*80(a0),1+7*80(a0)
	dbra	d3,.copygfxloop

	moveq	#0,d3	;move chars
	move.w	(a7)+,d3
	add.l	CharPointer(b),d3
	add.w	#79,d3
	move.l	d3,a0
.copycharloop	move.b	-(a0),1(a0)
	dbra	d2,.copycharloop
.InsertExit	rts


;---- Backspace function
;-- d0 -	delete to column
;-- d7 -	qualifier bits
;----
BackSpace	moveq	#0,d1
	move.b	CurXPos(b),d1	;check not column 0
	bne.b	.cont
.exit	rts
.cont	cmp.w	d1,d0	;check not left of leftmost column
	bpl.b	.exit
	move.w	d1,d6	;delete to current pos
	subq.w	#1,d6
	moveq	#1,d3	;delete one char
	tst.b	d7	;check for shift
	beq.b	BackSpaceMain
	move.w	d1,d3	;if shift delete to begining of line
	sub.w	d0,d3	;calck chars to be deleted
	move.w	d0,d6	;delete to leftmost

BackSpaceMain	sub.b	d3,CurXPos(b)	;and correct cursor port

BackSpaceDO	moveq	#0,d4
	move.b	CurYPos(b),d4
	mulu	#80,d4
	move.w	d4,-(a7)
	asl.w	#3,d4	;find gfx-mem address
	add.w	LineBase(b),d4
	moveq	#0,d5
	move.w	BplSize(b),d5
	cmp.l	d5,d4
	bmi.b	.fix
	sub.l	d5,d4
.fix	add.w	d6,d4
	add.l	ScreenBase(b),d4
	move.l	d4,a0

	cmp.w	#79,d6
	beq.b	.NoCopy

	moveq	#79,d5	;how many letters to copy
	sub.w	d3,d5
	sub.w	d6,d5
	move.w	d5,d4
	lea	(a0,d3.w),a1
.copyletter	move.b	(a1)+,(a0)+	;do the copy
	move.b	1*80-1(a1),1*80-1(a0)
	move.b	2*80-1(a1),2*80-1(a0)
	move.b	3*80-1(a1),3*80-1(a0)
	move.b	4*80-1(a1),4*80-1(a0)
	move.b	5*80-1(a1),5*80-1(a0)
	move.b	6*80-1(a1),6*80-1(a0)
	move.b	7*80-1(a1),7*80-1(a0)
	dbra	d4,.copyletter

.NoCopy	move.w	d3,d4	;and zap rest
	subq.w	#1,d4
	moveq	#0,d0
.deleteletters	move.b	d0,(a0)+
	move.b	d0,1*80-1(a0)
	move.b	d0,2*80-1(a0)
	move.b	d0,3*80-1(a0)
	move.b	d0,4*80-1(a0)
	move.b	d0,5*80-1(a0)
	move.b	d0,6*80-1(a0)
	move.b	d0,7*80-1(a0)
	dbra	d4,.deleteletters

	move.w	(a7)+,d4	;move chars in chartable
	add.w	d6,d4	;find leftmost column
	move.l	CharPointer(b),a0
	add.w	d4,a0	;in chartable
	cmp.w	#79,d6	;if last column skip the copy
	beq.b	.deleterest
.copychars	move.b	(a0,d3.w),(a0)+	;copy chars
	dbra	d5,.copychars
.deleterest	move.b	#' ',(a0)+	;and zap remaining chars
	subq.w	#1,d3
	bne.b	.deleterest

.BackSpaceExit	rts

; d7 - qualifier
Delete	moveq	#0,d1	;delete one char/to EOL
	move.b	CurXPos(b),d1
	tst.b	d7
	bne.b	DeleteToEOL
	move.w	d1,d6
	moveq	#1,d3
	bra.w	BackSpaceDO

DeleteToEOL	moveq	#79,d0
	sub.w	d1,d0
	moveq	#0,d4
	move.b	CurYPos(b),d4
	mulu	#80,d4
	move.w	d4,-(a7)
	asl.w	#3,d4	;find gfx-mem address
	add.w	LineBase(b),d4
	moveq	#0,d5
	move.w	BplSize(b),d5
	cmp.l	d5,d4
	bmi.b	.fix
	sub.l	d5,d4
.fix	add.w	d1,d4
	add.l	ScreenBase(b),d4
	move.l	d4,a0

	move.w	d0,d4
	moveq	#0,d2
.cleargfx	move.b	d2,(a0)+
	move.b	d2,1*80-1(a0)
	move.b	d2,2*80-1(a0)
	move.b	d2,3*80-1(a0)
	move.b	d2,4*80-1(a0)
	move.b	d2,5*80-1(a0)
	move.b	d2,6*80-1(a0)
	move.b	d2,7*80-1(a0)
	dbra	d4,.cleargfx

	move.w	(a7)+,d4
	add.w	d1,d4
	move.l	CharPointer(b),a0
	add.w	d4,a0
	moveq	#' ',d1
.clearchars	move.b	d1,(a0)+
	dbra	d0,.clearchars

	rts

PrintStack	sub.l	a0,a0
	move.l	#$10000/4,d1
	moveq	#0,d0
.checksum	add.l	(a0)+,d0
	subq.l	#1,d1
	bne.b	.checksum
	lea	CheckSumTxt(b),a1
	lea	TextLineBuffer(b),a0
.coptxt	move.b	(a1)+,(a0)+
	bne.b	.coptxt
	subq.w	#1,a0
	bsr.w	PrintHex8
	lea	StackTxt(b),a1
.coptext	move.b	(a1)+,(a0)+
	bne.b	.coptext
	subq.w	#1,a0
	move.l	a7,d0	;for debugging
	bsr.w	PrintHex8

	move.b	#'/',(a0)+
	moveq	#0,d0
	move.b	Control(b),d0
	bsr.w	PrintHexS

	move.b	#$0a,(a0)+
	move.b	#'>',(a0)+
	clr.b	(a0)+

	lea	TextLineBuffer(b),a0
	pea	MainLoop(pc)
	grgo	Print

;---- Compare with known commands and call
MReturn	tst.b	d7	;test for inactive return
	bne.w	NoPrompt

	clr.b	LastCMDError(b)	;clear error flag

	moveq	#0,d0	;find line
	move.b	CurYPos(b),d0

	move.b	Control(b),d7
	and.b	#kq_altmask,d7
	beq.b	.normalreturn

	clr.b	CurXPos(b)
	pea	NoPromptNoLF(pc);alt+return=clearline
	bra.w	ClearLine

.normalreturn	moveq	#0,d0	;find line
	move.b	CurYPos(b),d0
	mulu	#80,d0
	add.l	CharPointer(b),d0
	move.l	d0,a0
	lea	InputLine(b),a1
	moveq	#80/4-1,d0	;and copy to inputlinebuffer
.copyline	move.l	(a0)+,(a1)+
	dbra	d0,.copyline
	clr.b	(a1)	;make sure to have a NULL terminating text

	lea	InputLine(b),a0
	move.b	pr_Prompt(b),d0
	cmp.b	(a0)+,d0	;check first line equ prompt
	bne.b	NoPrompt	;if <> skip line

	moveq	#80-1-1,d0
.checkline	cmp.b	#' ',(a0)+	;only if command on line
	bne.b	.linenotfree
	dbra	d0,.checkline
	bra.w	RepeatCmd	;else check for repeat of last command

.linenotfree	subq.w	#1,a0
	moveq	#0,d0
	clr.w	LastCommand(b)	;stop repeat

	move.l	a0,a1
	bsr.w	AddToHistory

	lea	Commands,a2	;get table address
	moveq	#0,d7	;start with command number 0

	move.l	a7,PreCMDStack(b);for nested skip on error

.ScanCommands	move.l	a0,a1	;get poi to first letter in cmd-name
.scancmd	move.b	(a2)+,d0	;then compare until NULL in table
	beq.b	.CommandFound	;-> command is found
	cmp.b	(a1)+,d0
	beq.b	.scancmd
.findnext	tst.b	(a2)+	;find NULL
	bne.b	.findnext
	addq.w	#4,d7	;inc command number with entry-size
	tst.b	(a2)	;NULL ends list
	bne.b	.ScanCommands

	moveq	#EV_UNKNOWNCOMMAND,d1;no command matched -> error
	bra.w	PrintError

.CommandFound	move.l	a1,a0	;pointer to arg-list
	clr.b	UserBreak(b)	;clear user-break signal before start
	jmp	CMDJMPTab(pc,d7.w)

NoPromptKillKey	clr.b	CurKey(b)	;clear last pressed key
NoPrompt:	clr.b	CurXPos(b)	;xpos=0
	bsr.w	MCursorDownDO;line down
NoPromptNoLF	moveq	#0,d0	;and print prompt
	move.b	pr_Prompt(b),d0
	st.b	ReprintHeader(b);make sure header is OK
	bra.w	PrintLetter

;---- Command Jump Table -----------------------------------------------------;
;w;
CMDJMPTab	bra.w	VerifyControl
	bra.w	FormatDisk
	bra.w	MonitorControl
	bra.w	SaveData
	bra.w	DiskBitMap
	bra.w	DeleteFile
	bra.w	MFMDecode
	bra.w	SetBeamcon
	bra.w	SetupSystemReset
	bra.w	ChangeNMIROM
	bra.w	FindNOT
	bra.w	DisplayVersion
	bra.w	DisplayDate
	bra.w	InternalDump
	bra.w	ChangeExitCus
	bra.w	CopperActive
	bra.w	CopperOffset
	bra.w	SetNMI
	bra.w	SetExitCoppers
	bra.w	ChangeCurrentDirectory
	bra.w	ListBreakPoints
	bra.w	SetBreakPoint
	bra.w	ZapAllBreakPoints
	bra.w	ZapBreakPoint
	bra.w	ChangeBPReg
	bra.w	EnableTrace
	bra.w	DisableTrace
	bra.w	ShowHelp
	bra.w	DePower
	bra.w	DeImplode
	bra.w	XORMemory
	bra.w	FillNOPs
	bra.w	WorkAreaCtrl
	bra.w	InterruptCmd
	bra.w	KickTagInfo
	bra.w	KickMemInfo
	bra.w	ResidentInfo
	bra.w	ResourceInfo
	bra.w	Resume
	bra.w	Directory
	bra.w	TaskInfo
	bra.w	LibraryInfo
	bra.w	DeviceInfo
	bra.w	PortInfo
	bra.w	ChangeSync
	bra.w	ChangeTrackLenH
	bra.w	ChangeTrackLen
	bra.w	DiskInfo
	bra.w	DumpAddresses	;address buffer dump
	bra.w	ReadBlocks
	bra.w	ReadRawTracks
	bra.w	ReadTracks
	bra.w	WriteRawTracks
	bra.w	WriteTracks
	bra.w	WriteBlocks
	bra.w	MonitorExit
	bra.w	DumpRegisters
	bra.w	AssembleLineStart
	bra.w	AssembleLine
	bra.w	DisassemLines
	bra.w	EntryClear
	bra.w	HexDumpLines
	bra.w	ASCIIDumpLines
	bra.w	ReturnValue
	bra.w	HexEntry
	bra.w	KillExit
	bra.w	ZapSymbol
	bra.w	MakeSymbol
	bra.w	PrintSymbols
	bra.w	ASCIIEntry
	bra.w	HuntPCRelative
	bra.w	HuntBranch
	bra.w	FindText
	bra.w	Find
	bra.w	FillMemory
	bra.w	TransferMemory
	bra.w	ExchangeMemory
	bra.w	MemoryEditorD	;disassembler
	bra.w	MemoryEditorH	;hex dump
	bra.w	MemoryEditorA	;ascii dump
	bra.w	SubCall
	bra.w	SubCallExit
	bra.w	LoadData
	bra.w	CompareMemory
	bra.w	MemoryEditorP	;peeker

;----- Start of "Command Code Objects" ---------------------------------------;


;----------------------------------------------------
;- Name	: 
;- Description	: 
;- SYNTAX	: 
;----------------------------------------------------
;- 	First version.
;----------------------------------------------------

;----------------------------------------------------
;- Name	: Verify Control
;- Description	: Toggle/show disk verify state
;- SYNTAX	: verify
;----------------------------------------------------
;- 	First version.
;----------------------------------------------------
VerifyControl	lea	VerifyText(b),a1
	lea	DiskVerify(b),a2
	not.b	(a2)
	bra.w	PrintState

;----------------------------------------------------
;- Name	: EntryClear
;- Description	: Alter & display entry_clear status
;- SYNTAX	: cls
;----------------------------------------------------
EntryClear	lea	EntryClearText(b),a1
	lea	ClearScreenEntry(b),a2
	not.b	(a2)
	bra.w	PrintState

;----------------------------------------------------
;- Name	: FormatDisk
;- Description	: Format the disk to specified DOS type
;- SYNTAX	: Format [name] <c><f><i><q> <=formatlong>
;----------------------------------------------------
FormatDisk	bsr.w	ParseDFxName
	lea	BlockBufferIII,a4
	move.l	a4,a1
	lea	BlockBuffer,a3
	moveq	#$200/4-1,d0
.ZapROOT	clr.l	(a1)+
	clr.l	(a3)+
	dbra	d0,.ZapROOT

	moveq	#0,d0
	lea	FH_NAME+1(a4),a1
.CopyDiskName
	move.b	(a2)+,(a1)+
	beq.b	.NameDone
	addq.w	#1,d0
	cmp.w	#30,d0
	bne.b	.CopyDiskName
	clr.b	(a1)

.NameDone	move.b	d0,FH_NAME(a4)

	bsr.w	SkipSpaces
	beq.b	.NoMorePars
	subq.w	#1,a0

	moveq	#0,d7	;keeps format parameters

.CheckFormatPar	move.b	(a0)+,d0	;check for the other format parameters
	beq.b	.NoMorePars
	cmp.b	#' ',d0
	beq.b	.CheckFormatPar
	cmp.b	#'=',d0
	beq.b	.CheckFormatVal

	or.b	#$20,d0
	moveq	#3,d1	;check 4 pars
.CompareParms	cmp.b	.FormatTable(pc,d1.w),d0
	bne.b	.NotEqual
	or.b	.FormatTable+4(pc,d1.w),d7
.NotEqual	dbra	d1,.CompareParms
	bra.b	.CheckFormatPar

.FormatTable	dc.b	'ficq'
	dc.b	1,2,4,8 ;(0,1,2,3)

.CheckFormatVal	bsr.w	GetValueCall
	cmp.w	#EV_NOVALUE,d1
	beq.b	.NoMorePars
	tst.l	d1
	bmi.w	PrintError
	move.l	d0,FormatLong(b)

.NoMorePars	grcall	InitDriveW

	btst	#3,d7	;Full format?
	bne.b	.QuickFormat

	lea	WriteBuffer,a0	;clear buffer
	move.w	#22*512/4-1,d0
	move.l	FormatLong(b),d1
.ClrBuffer	move.l	d1,(a0)+
	dbra	d0,.ClrBuffer

	lea	FormattingText(b),a0
	grcall	Print

	move.w	CurXPos(b),FileUpdatePos(b)

	move.w	#160-1,d5	;do 160 tracks
.FullFormatLoop	move.w	d5,d0
	grcall	SaveTrack

	tst.b	UserBreak(b)
	bne.w	.UserBroken

	sub.w	#160-1,d0
	neg.w	d0
	mulu	#100,d0
	divu	#160,d0

	lea	TextLineBuffer(b),a0
	move.l	a0,a1
	move.b	#pc_Pos,(a0)+
	move.b	FileUpdatePos(b),(a0)+
	move.b	1+FileUpdatePos(b),(a0)+

	swap	d0
	clr.w	d0
	swap	d0

	move.b	#'(',(a0)+
	bsr.w	PrintDec
	move.b	#'%',(a0)+
	move.b	#')',(a0)+

	move.b	#pc_CLRRest,(a0)+
	clr.b	(a0)

	move.l	a1,a0
	grcall	Print

	dbra	d5,.FullFormatLoop

.QuickFormat	lea	WritingROOTText(b),a0
	grcall	Print

	moveq	#1,d0	;first write BOOT's 2nd block
	grcall	SaveBlock

	lea	BlockBuffer,a3	;then add DOS info
	move.l	a3,a0
	move.l	#'DOS'<<8,(a0)+
	move.b	d7,d0
	and.w	#%111,d0	;only 3 DOS bits
	btst	#2,d0	;if cache
	beq.b	.NoCache
	bclr	#1,d0	;make sure no international
.NoCache	move.b	d0,-(a0)

	moveq	#0,d0
	grcall	SaveBlock	;and write BOOT's 1st block

	moveq	#0,d6
	move.w	ROOTBlock(b),d6
	addq.w	#1,d6

	btst	#2,d7	;Add cache ptr if needed
	beq.b	.NoCache2

	move.l	a3,a1
	moveq	#T_CACHE,d0
	move.l	d0,(a1)+
	move.l	d6,(a1)+
	move.l	d6,(a1)
	subq.l	#1,(a1)+	;ROOT
	clr.l	(a1)+
	clr.l	(a1)+

	move.l	a3,a0
	bsr.w	ChecksumBlock
	move.l	d0,(a1)	;checksum

	move.l	d6,d0
	grcall	SaveBlock

	addq.w	#1,d6

.NoCache2	moveq	#T_SHORT,d0	;build ROOT
	move.l	d0,(a4)
	moveq	#$48,d0
	move.l	d0,FH_HASHSIZE(a4)
	moveq	#-1,d0
	move.l	d0,FH_BMFLAG(a4)
	move.l	d6,FH_BMPAGES(a4)

	grcall	ReadBatClock
	move.l	Time00(b),FH_CREATEDAYS(a4)
	move.l	Time01(b),FH_CREATEMINS(a4)
	move.l	Time02(b),FH_CREATETICKS(a4)

	moveq	#ST_ROOT,d0
	move.l	d0,FH_SECTYPE(a4)

	move.l	d6,FH_CACHEBLOCK(a4);set cache ptr
	subq.l	#1,FH_CACHEBLOCK(a4);(Done this way by the ROM!)

	move.l	a4,a0
	bsr.w	ChecksumBlock
	move.l	d0,FH_CHECKSUM(a4)

	move.w	ROOTBlock(b),d0
	move.l	a4,a0
	grcall	SaveBlockAdd

	move.l	a3,a0	;build BM
	moveq	#1760*2/32-1,d0	;do this the lazy way!
	clr.l	(a0)+	;checksum
	moveq	#-1,d1
.FillBM	move.l	d1,(a0)+
	dbra	d0,.FillBM

	move.w	d6,d0
	bsr.w	SetBMFlag
	subq.w	#1,d0
	bsr.w	SetBMFlag
	btst	#2,d7	;Cache block?
	beq.b	.NoCache3
	subq.w	#1,d0
	bsr.w	SetBMFlag
.NoCache3	bsr.w	ChecksumBMPage
	move.l	d0,(a3)

	move.w	d6,d0
	grcall	SaveBlock	;save BM


	grcall	UpdateDisk


.UserBroken	grcall	MotorOff
	bra	NoPrompt



;---- SkipSpaces
;-- INPUT:	a0 -	string
;-- OUTPUT:	d0 -	char if string not empty (then Z)
;----
SkipSpaces	moveq	#0,d0
.loop	move.b	(a0)+,d0
	beq.b	.End
	cmp.b	#' ',d0
	beq.b	.loop
.End	rts


;----------------------------------------------------
;- Name	: HandleVerifyE
;- Description	: Ask user: Retry/Abort
;----------------------------------------------------
;- 060994	First version.
;----------------------------------------------------
;- INPUT:	d0 -	Track number
;-	a0 -	Data
;--
;- Preserve all registers!
;----
HandleVerifyE	Push	all
	move.b	HeaderDiskInfo(b),d7;stop header info printing
	clr.b	HeaderDiskInfo(b)
	lea	VerifyRetryText(b),a0
	moveq	#34,d0
	bsr.w	PrintHeaderD

.VerifyInputLop	grcall	PasteText
	beq.b	.VerifyInputLop
	clr.b	CurKey(b)

	cmp.b	#$1b,d0	;ESC = Abort
	beq.b	.VerifyAbort

	or.b	#$20,d0
	cmp.b	#'a',d0	;a - Abort
	beq.b	.VerifyAbort

	cmp.b	#'r',d0	;r - Retry
	bne.b	.VerifyInputLop

	move.b	d7,HeaderDiskInfo(b)

	Pull	all
	grgo	SaveTrackAdd

.VerifyAbort	Pull	all
	moveq	#EV_DISKVERIFYERROR,d1;return error signal to caller
	bra	PrintErrorMO

;	rts


;----------------------------------------------------
;- Name	: MonitorControl
;- Description	: Show/change active monitor type
;- SYNTAX	: mon <0-4>
;----------------------------------------------------
;- 200794	First version.
;----------------------------------------------------
MonitorControl	bsr.b	SkipSpaces
	beq.b	.JustDisplay

	moveq	#EV_SYNTAXERROR,d1
	sub.b	#'0',d0
	bmi.w	PrintError
	cmp.b	#5,d0
	bge.w	PrintError

	move.b	d0,ScreenMode(b)
	bsr	StartScreen
	bsr	ClearScreen

.JustDisplay	moveq	#0,d7	;print 5 monitors, starting with '0'
	lea	pr_Monitors(b),a2
.PrintLoop	lea	TextLineBuffer(b),a0
	move.l	a0,a1
	move.b	#10,(a1)+
	moveq	#' ',d0
	move.w	d0,d1
	cmp.b	ScreenMode(b),d7
	bne.b	.NotActive
	moveq	#'*',d0
.NotActive	move.b	d0,(a1)+
	move.b	d1,(a1)+

	move.w	d1,d0
	tst.b	mon_SysView(a2)
	beq.b	.NoReset
	moveq	#'R',d0
.NoReset	move.b	d0,(a1)+
	move.b	d1,(a1)+

	moveq	#'0',d0
	add.b	d7,d0
	move.b	d0,(a1)+	;mon #
	move.b	d1,(a1)+

	move.l	a2,a3
.copyname	move.b	(a3)+,(a1)+
	bne.b	.copyname
	subq.w	#1,a1

	add.w	#mon_SizeOf,a2

	move.b	#pc_CLRRest,(a1)+
	clr.b	(a1)
	grcall	Print
	addq.w	#1,d7
	cmp.w	#5,d7
	bne.b	.PrintLoop
	bra.w	NoPrompt




;----------------------------------------------------
;- Name	: DiskBitMap
;- Description	: Display disk's bitmap
;- SYNTAX	: BM
;----------------------------------------------------
;- 100494	First version.
;----------------------------------------------------
DiskBitMap	grcall	InitDriveDOS

	lea	BitMapHeader(b),a0
	grcall	Print

	move.w	ROOTBlock(b),d0
	grcall	GetBlock

	lea	BlockBuffer,a3

	move.l	FH_BMPAGES(a3),d0
	grcall	GetBlock

	moveq	#0,d7
	move.b	DiskSectors(b),d7
	add.w	d7,d7
	moveq	#0,d2
	move.b	pr_BitMapRes(b),d6
	move.b	pr_BitMapFree(b),d5
	move.b	pr_BitMapUsed(b),d4
.BMMainLoop	lea	TextLineBuffer(b),a0
	move.b	#10,(a0)+
	move.w	d2,d0
	moveq	#79,d3
.BMSubLoop	cmp.w	#1,d0	;two first are reserved
	bgt.b	.checkstat
	move.b	d6,d1
	bra.b	.set

.checkstat	move.b	d5,d1
	bsr.w	TestBMFlag
	bne.b	.set
	move.b	d4,d1
.set	move.b	d1,(a0)+
	add.w	d7,d0
	dbra	d3,.BMSubLoop
	clr.b	(a0)
	lea	TextLineBuffer(b),a0
	Push	d2-d4
	bsr	Print
	Pull	d2-d4
	addq.w	#1,d2
	cmp.w	d2,d7
	bne.b	.BMMainLoop

	grcall	MotorOff
	bra	NoPrompt

;----------------------------------------------------
;- Name	: DumpRegisters
;- Description	: Show/change register contents
;- SYNTAX	: r <reg><new contents>
;----------------------------------------------------
;- 090494	First version.
;----------------------------------------------------
;---- Dump registers command (r)
DumpRegisters	
	move.b	(a0)+,d0	;scan for args
	beq.b	.DumpAll
	cmp.b	#' ',d0
	beq.b	DumpRegisters

	asl.w	#8,d0
	move.b	(a0),d1
	move.b	d1,d0
	or.w	#$2020,d0

	lea	StatusReg(b),a1
	moveq	#0,d7	;word

	cmp.w	#'sr',d0	;sr
	beq.b	.getvalue

	lea	DataRegs(b),a1
	moveq	#1,d7	;longword
	and.w	#$ff00,d0
	cmp.w	#'d'<<8,d0
	beq.b	.checknumber
	lea	AddressRegs(b),a1
	cmp.w	#'a'<<8,d0
	bne.b	.DumpAll	;if not An/Dn just print all

.checknumber	sub.b	#'0',d1
	bmi.b	.DumpAll
	cmp.b	#7,d1
	bgt.b	.DumpAll

	asl.w	#2,d1
	add.w	d1,a1

.getvalue	addq.w	#1,a0
	bsr.w	GetValueSkip	;get value 

	tst.w	d7
	beq.b	.wordonly
	move.l	d0,(a1)
	bra.b	.DumpAll

.wordonly	move.w	d0,(a1)

.DumpAll	pea	NoPrompt(pc)	;show all registers
	bra.w	PrintRegs

;----------------------------------------------------
;- Name	: DecodeMFM
;- Description	: Decodes MFM data in memory
;- SYNTAX	: mfm [start] [len(longs)] <dest>
;----------------------------------------------------
;- 080294	First version.
;----------------------------------------------------
MFMDecode	bsr.w	GetValueSkip
	move.l	d0,DepackStart(b)
	bsr.w	CheckSeparator
	bsr.w	GetValue
	move.l	d0,DepackEnd(b)	;length in longs!

	bsr.w	GetOptValue
	beq.b	.dest
	move.l	DepackStart(b),d0;if none, let dest=datastart
.dest	move.l	d0,DepackDest(b)

	move.l	DepackStart(b),a0
	move.l	DepackDest(b),a1
	move.l	DepackEnd(b),d6	;this is lenght! Not end!!!!!!
	move.l	#$55555555,d7
.DecodeLoop	move.l	(a0)+,d0
	move.l	(a0)+,d1
	and.l	d7,d0
	and.l	d7,d1
	add.l	d0,d0
	or.l	d1,d0
	move.l	d0,(a1)+
	subq.l	#1,d6
	bne.b	.DecodeLoop

	lea	TextLineBuffer(b),a0
	lea	MFMDecodeText(b),a1
.cp1	move.b	(a1)+,(a0)+
	bne.b	.cp1
	subq.w	#1,a0
	move.l	DepackEnd(b),d0	;length
	bsr.w	PrintHexL
.cp2	move.b	(a1)+,(a0)+
	bne.b	.cp2
	subq.w	#1,a0
	move.l	DepackDest(b),d0
	bsr.w	PrintHexS
.cp3	move.b	(a1)+,(a0)+
	bne.b	.cp3
	subq.w	#1,a0
	move.l	DepackStart(b),d0
	bsr.w	PrintHexS
	move.b	(a1)+,(a0)+
	clr.b	(a0)

	lea	TextLineBuffer(b),a0
	pea	NoPrompt(pc)
	bra.w	Print

;----------------------------------------------------
;- Name	: SetPAL/NTSC
;- Description	: Set exitmode to PAL/NTSC (cus 1dc =$0020/$0000)
;- SYNTAX	: pal/ntsc
;----------------------------------------------------
;- 010294	First version.
;----------------------------------------------------
SetBeamcon	bsr.w	SkipSpaces
	beq.b	.DisplayStatus

	moveq	#-1,d1	;DISABLED
	cmp.b	#'0',d0
	beq.b	.Reset

	or.b	#$20,d0
	moveq	#0,d1	;ntsc
	cmp.b	#'n',d0
	beq.b	.Reset

	moveq	#$20,d1	;pal
	cmp.b	#'p',d0
	bne.b	.DisplayStatus

.Reset	move.w	d1,ExitBeamcon(b)

.DisplayStatus	lea	TextLineBuffer(b),a1
	lea	BeamconTextc(b),a0
	move.w	ExitBeamcon(b),d0
	bmi.b	.LastString

	lea	BeamconText(b),a0

.cp1	move.b	(a0)+,(a1)+
	bne.b	.cp1
	subq.w	#1,a1

	tst.w	d0	;NTSC
	beq.b	.LastString	;(ptr is ok)
	lea	BeamconTextb(b),a0

.LastString
.cp2	move.b	(a0)+,(a1)+
	bne.b	.cp2

	lea	TextLineBuffer(b),a0
	grcall	Print
	bra.w	NoPrompt

;----------------------------------------------------
;- Name	: SetupSystemReset
;- Description	: Set the ColdCapture vector and recalculate Exec checksum
;-	  Copy of this routine in resetentry-handling code.
;----------------------------------------------------
;- 310194	First version
;----------------------------------------------------
SetupSystemReset
	bsr.w	SumExecBase
	bne.w	PrintError
	bsr.b	.ChangeColdCapture
	lea	ColdCaptureText(b),a1
	lea	ColdResetEntry(b),a2
	bra.w	PrintState

.ChangeColdCapture
	move.l	$4.w,a6
	lea	ResetEntry(pc),a0
	lea	SysResetHandler(pc),a1
	moveq	#~0,d0
	cmp.l	ColdCapture(a6),a0
	bne.b	CSRSetit
ClearSystemReset
	sub.l	a0,a0
	sub.l	a1,a1
	moveq	#0,d0
SetSystemReset	move.l	$4.w,a6	;Called at KillExit
CSRSetit	move.l	a0,ColdCapture(a6)
	move.l	a1,CoolCapture(a6)
	move.b	d0,ColdResetEntry(b)
	lea	34(a6),a0
	moveq	#$16,d0
	moveq	#0,d1
.sumloop	add.w	(a0)+,d1
	dbra	d0,.sumloop
	not.w	d1
	move.w	d1,82(a6)
	lea	$dff000,a6
	rts

;---- Handle Memalloc and reset setup when using system reset entry
SysResetHandler	lea	B,b
	moveq	#$00f,d2
	tst.b	ColdResetEntry(b)
	beq.b	.badalloc
	lea	ResetEntry(pc),a0;ZUP pointers for next entry
	lea	SysResetHandler(pc),a1
	moveq	#~0,d0
	bsr.b	SetSystemReset

	sub.l	a0,a0
	move.l	$4.w,a6
	btst	#0,AttnFlags+1(a6);running '000?
	beq.b	.kidbrother
	lea	.GetVBR(pc),a5
	Call	Supervisor
.kidbrother	lea	B,b
	move.l	$7c(a0),OrgNMIVector(b);get old NMI vector
	st.b	NMIPatched(b)
	lea	GhostRider(pc),a1
	move.l	a1,$7c(a0)	;and set new vector

	moveq	#$070,d2

	lea	SystemEntryCLI(pc),a1;try to alloc GRmain memory
	move.l	#GRMainHunkLen,d0
	Call	AllocAbs	;I really don't care wheather this
	tst.l	d0	;allocation is successful or not!
	bne.b	.badmem
	moveq	#$040,d2

.badmem	move.l	ChipBackup(b),d0;try to alloc GR work mem
	bne.b	.BackupDefined	;if no swap defined
	move.l	ChipMem(b),d0	;get chip location
.BackupDefined	move.l	d0,a0
	move.l	#GRChipHunkLen,d0
	Call	AllocAbs
	tst.l	d0	;see if allocation is successful or not!
	bne.b	.badmem2
	moveq	#$040,d2
.badmem2
.badalloc	move.w	d2,$dff180
	bsr.b	SetMessagePort
	rts		;Return to Reset routine

.GetVBR	movec	VBR,a0
	rte

;---- Called by DeckRunner to setup Cold/Cool
	dc.b	'CLD!'	;ID Cold init routine
ColdInit	lea	ResetEntry(pc),a0;force Cold/Cool vectors
	lea	SysResetHandler(pc),a1
	moveq	#~0,d0
	lea	B,a5
	bra.w	SetSystemReset

;----------------------------------------------------
;- Name	: Setup MessagePort
;- Description	: Place a msg_port in the system for GR system interface
;----------------------------------------------------
;- 160494	First version
;----------------------------------------------------
SetMessagePort	Push	d0/d1/a1/a6
	move.l	$4.w,a6
	moveq	#mp_sizeof+4,d0
	move.l	#1<<16,d1
	jsr	_LVOAllocMem(a6)
	tst.l	d0
	beq.b	.nomemavail
	move.l	d0,a1

	move.l	#GRInternalPtr,mp_sizeof(a1)
	move.b	#NT_MSGPORT,LN_TYPE(a1)
	move.l	#GhostRiderPName,LN_NAME(a1)
	jsr	_LVOAddPort(a6)

.nomemavail	Pull	d0/d1/a1/a6
	rts

RemMessagePort	Push	d0/d7/a1/a6
	move.l	$4.w,a6
	lea	GhostRiderPName(pc),a1
	jsr	_LVOFindPort(a6)
	move.l	d0,d7
	beq.b	.noport
	move.l	d0,a1

	jsr	_LVORemPort(a6)

	move.l	d7,a1
	moveq	#mp_sizeof+4,d0
	jsr	_LVOFreeMem(a6)
.noport	Pull	d0/d7/a1/a6
	rts

GhostRiderPName	dc.b	'GhostRider.Port',0


;----------------------------------------------------
;- Name	: DisplayRegs
;- Description	: Display registers (d0-a7) in top of screen
;- SYNTAX	: Control+HELP (no entry from HelpPages! Uses HelpBackup)
;----------------------------------------------------
;- 280194	First version.
;----------------------------------------------------
DisplayRegs	move.w	CurXPos(b),HelpPosBack(b)
	move.l	CharPointer(b),a0
	lea	HelpCharBack,a1
	moveq	#80*2/4-1,d0	;backup two lines
.backup	move.l	(a0)+,(a1)+
	dbra	d0,.backup
	clr.b	(a1)

	st.b	HideCursor(b)

	lea	DisplayRegsText(b),a3
	lea	Regs(b),a4
	moveq	#0,d6
.loop	lea	TextLineBuffer(b),a0
	move.w	d6,CurXPos(b)
.copy1	move.b	(a3)+,(a0)+
	bne.b	.copy1
	subq.w	#1,a0
	moveq	#7,d2
.subloop	move.l	(a4)+,d0
	bsr.w	PrintHex8
	move.b	#' ',(a0)+
	dbra	d2,.subloop
;	move.b	#pc_CLRRest,(a0)+
	clr.b	(a0)
	move.l	d6,d0
	lea	TextLineBuffer(b),a0
	bsr.w	PrintLine
	addq.w	#1,d6
	cmp.w	#2,d6
	bne.b	.loop

.wait	move.b	Control(b),d0
	and.b	#1<<kq_ctrl!1<<kq_lamiga,d0
	bne.b	.wait
	tst.b	MarkingText(b)
	bne.b	.wait	;wait for end of snapping

	lea	HelpCharBack,a0
	move.b	80(a0),d7
	clr.b	80(a0)
	moveq	#0,d0
	move.w	d0,CurXPos(b)
	bsr.w	PrintLine
	lea	HelpCharBack+80,a0
	move.b	d7,(a0)
	moveq	#1,d0
	move.w	d0,CurXPos(b)
	bsr.w	PrintLine

	move.w	HelpPosBack(b),CurXPos(b)
	clr.b	HideCursor(b)
	rts

;----------------------------------------------------
;- Name	: ChangeNMIROM
;- Description	: Change NMIROM entry flag
;- SYNTAX	: nmirom
;----------------------------------------------------
;- 280194	First version.
;----------------------------------------------------
ChangeNMIROM	lea	pr_NMIROMCheck(b),a2
	not.b	(a2)
	lea	NMIROMEntryText(b),a1

;---- Print disabled/enabled text.
;-- input:	a1 -	Text
;-	a2 -	Flag-pointer
;----
PrintState:	lea	TextLineBuffer(b),a0
.copy	move.b	(a1)+,(a0)+
	bne.b	.copy
	subq.w	#1,a0
	lea	DisabledText(b),a1
	tst.b	(a2)
	beq.b	.state
	lea	EnabledText(b),a1
.state	move.b	(a1)+,(a0)+
	bne.b	.state
	lea	TextLineBuffer(b),a0
	pea	NoPrompt(pc)
	bra.w	Print

;----------------------------------------------------
;- Name	: BitmapPeeker
;- Description	: Peek chip/fast mem az a bitplane
;- SYNTAX	: p <addr>
;----------------------------------------------------
;- 190194	First version.
;----------------------------------------------------
PeekerEdit	st.b	HideCursor(b)
	clr.b	LastCMDError(b)
	bsr.w	InitScreenPts	;init pointers

PeekerLoopZUC	bsr.w	ClearScreen
	move.l	MemoryAddress(b),d0
	bra.w	PDECheckAddress

PeekerLoopZU	bsr.w	PeekPage

BDELoopYPos	moveq	#-1,d2
	bsr.w	PrintCANJLA	;print CA NJ LA

	lea	PeekerText(b),a1;add screen width
.cpt1	move.b	(a1)+,(a0)+
	bne.b	.cpt1

	subq.w	#1,a0
	moveq	#1,d1
	moveq	#0,d0
	move.b	PeekerWidth(b),d0
	addq.w	#1,d0
	add.w	d0,d0
	grcall	PrintHex

.cpt2	move.b	(a1)+,(a0)+	;add memory modulo
	bne.b	.cpt2

	subq.w	#1,a0
	moveq	#3,d1
	move.w	PeekerModulo(b),d0
	grcall	PrintHex

	clr.b	(a0)
	lea	TextLineBuffer(b),a0
	bsr.w	PrintHeader

PeekerLoopE	bsr.w	PrintFlags

	clr.b	CurKey(b)

PeekerLoop	tst.b	ExitFlag(b)
	bne.w	PeekerExit

	tst.b	DisplayHelp(b)	;HELP requested?
	beq.b	.nohelp
.dohelp	lea	EditorHelp,a0;yeah... well, then help away!
	pea	PeekerEdit(pc)
	moveq	#eh_PeekerEdit,d6;set peeker-mask
	bra.w	PrintHelpNoRZUP

.HELPRegs	bsr.w	DisplayRegs
	bra.w	PeekerEdit

.nohelp	moveq	#0,d0	;fool touch anything?
	move.b	CurKey(b),d0
	beq.b	PeekerLoop	;nah, check if it's coz he dunno how
	clr.b	CurKey(b)

	move.b	d0,d5

	cmp.b	#key_esc,d0	;time to leave?
	beq.w	PeekerExit

	cmp.b	#key_help,d0	;help=display error
	bne.b	.help
	move.b	Control(b),d0
	btst	#kq_ctrl,d0	;if ctrl, show registers
	bne.b	.HELPRegs
	and.b	#kq_altmask,d0	;if alt, show help
	bne.w	.dohelp
	bsr.w	PrintLEInHeader	;else show last error
	bra.b	PeekerLoopE

.help	move.b	Control(b),d1

.ChangeInsert	moveq	#0,d2
	move.b	PeekerWidth(b),d2
	addq.w	#1,d2
	add.w	d2,d2
	add.w	PeekerModulo(b),d2;may be negative
	ext.l	d2
;should this always be positive?

	moveq	#2,d3

	move.b	d1,d4
	and.b	#kq_shiftmask,d4
	beq.b	.singlestep

	moveq	#16,d3	;horiz speed = 128 bits/press

	asl.l	#4,d2	;scroll 16 lines each time
	bra.b	.noalt	;to prevent confuzion

.singlestep	btst	#kq_ralt,d1
	beq.b	.noalt

	moveq	#1,d3
	add.w	PeekerLines(b),d3
	asl.w	#2,d2	;peekerlines in 4-line steps
	muls.w	d3,d2
	move.l	d2,d3	;alt+vert = 1 screen
	add.l	d3,d3	;alt+horiz = 2 screens

.noalt	cmp.b	#key_down,d0	;down
	beq.w	PDEOffset

	cmp.b	#key_up,d0	;up
	beq.w	PDEOffsetNeg

	move.l	d3,d2
	cmp.b	#key_right,d0	;right
	beq.w	PDEOffset

	cmp.b	#key_left,d0	;left
	beq.w	PDEOffsetNeg

.checkshorts	move.b	d5,d3
	move.b	d1,d2
	and.b	#kq_shiftmask,d2;shifted?
	bne.w	.shifted

	cmp.b	#'0',d3	;jump marks?
	blt.b	.checkon
	cmp.b	#'9',d3
	bgt.b	.checkon
	bsr.w	GetMarkAddress
	bra.w	PDECheckAddress

.checkon	cmp.b	#'-',d5
	beq.w	PeekDecWidth

	cmp.b	#'=',d5
	beq.w	PeekIncWidth

	cmp.b	#',',d5
	beq.w	PeekDecModulo

	cmp.b	#'.',d5
	beq.w	PeekIncModulo

	cmp.b	#'[',d5
	beq.w	PeekDecHeight

	cmp.b	#']',d5
	beq.w	PeekIncHeight

	cmp.b	#'a',d0	;a - Assign symbol
	beq.w	PeekEditAssign

	cmp.b	#'d',d0	;d - Dis Edit
	beq.w	DisDumpEdit

	cmp.b	#'j',d0	;j - Jump To Address
	beq.w	PeekEditJump

	cmp.b	#'h',d0	;h - Hex Edit
	beq.w	HexDumpEdit

	cmp.b	#'l',d0	;l - Quick Jump To Last Address
	beq.w	PeekLast

	cmp.b	#'m',d0	;m -Modulo
	beq.w	PeekModulo

	cmp.b	#'n',d0	;n - ASCII Edit
	beq.w	ASCIIDumpEdit

	cmp.b	#'o',d0	;o - add offset to address
	beq.w	PeekAddOffset

	cmp.b	#'w',d0	;w - Width
	beq.w	PeekWidth

	cmp.b	#'x',d0	;x - Exit
	beq.w	PeekerExit

	cmp.b	#'z',d0	;z - zap jump table
	bne.b	.nocmd
	st.b	NestedJumps(b)

.nocmd	bra.w	BDELoopYPos

;---- check shifted commands
.shifted	moveq	#9,d1	;first check 0-9 = set mark
	lea	KeyTabShift+1(pc),a0
.checkstoremark	cmp.b	(a0)+,d3
	beq.b	.store
	dbra	d1,.checkstoremark
	bra.b	.checkonshift

.store	tst.b	d1	;roll numbers to get 0 first
	bne.b	.swapd
	moveq	#10,d1

.swapd	moveq	#'0'+9+1,d0
	sub.b	d1,d0
	pea	PeekerLoop(pc)
	bra.w	PutMarkAddress

.checkonshift	cmp.b	#'X',d3
	beq.w	PeekerExit

	bra.b	.nocmd

;---- increase Height
PeekIncHeight	move.w	TextLines(b),d0
	add.w	d0,d0
	subq.w	#1,d0
	cmp.w	PeekerLines(b),d0
	beq.w	PeekerLoop	;already full display
	addq.w	#1,PeekerLines(b)
	bra.w	PeekerLoopZU

;---- decrease Height
PeekDecHeight	cmp.w	#$8-1,PeekerLines(b);min 32 lines
	beq.w	PeekerLoop	;already minimum display
	subq.w	#1,PeekerLines(b)
	bra.w	PeekerLoopZUC

;---- increase width
PeekIncWidth	cmp.b	#39,PeekerWidth(b)
	beq.w	PeekerLoop
	addq.b	#1,PeekerWidth(b)
	bra.w	PeekerLoopZU

;---- decrease width
PeekDecWidth	tst.b	PeekerWidth(b)
	beq.w	PeekerLoop
	subq.b	#1,PeekerWidth(b)
	bra.w	PeekerLoopZUC	;also clear screen

;---- increase Modulo
PeekIncModulo	addq.w	#2,PeekerModulo(b)
	bra.w	PeekerLoopZU

;---- decrease Modulo
PeekDecModulo	subq.w	#2,PeekerModulo(b)
	bra.w	PeekerLoopZU

;---- change width
PeekWidth	lea	PeekerWidthTxt(b),a0
	bsr.w	GetHeaderInput
	bne.w	PeekerLoopZU	;skip if fail
	lea	InputLine(b),a0
	bsr.w	GetValueCall
	bmi.w	PeekEditError
	moveq	#EV_PEEKERWIDTH,d1
	lsr.w	#1,d0
	beq.w	PeekEditError
	cmp.l	#40,d0
	bgt.w	PeekEditError
	subq.w	#1,d0
	move.b	d0,PeekerWidth(b)
	bra.w	PeekerLoopZUC

;---- change modulo
PeekModulo	lea	PeekerModuloTxt(b),a0
	bsr.w	GetHeaderInput
	bne.w	PeekerLoopZU	;skip if fail
	lea	InputLine(b),a0
	bsr.w	GetValueCall
	bmi.b	PeekEditError
	and.w	#$fffe,d0
	move.w	d0,PeekerModulo(b)
	bra.w	PeekerLoopZU

;---- exit from peeker
PeekerExit	clr.b	HideCursor(b)
	bra.w	DumpEditExit

;---- Assign label
PeekEditAssign	pea	PeekerLoopZU(pc)
	bra.w	AssignSymbol

;---- Jump address
PeekEditJump	lea	EditorJumpText(b),a0
	bsr.w	GetHeaderInput
	bne.w	PeekerLoopZU	;skip if fail
	lea	InputLine(b),a0
	bsr.w	GetValueCall
	bmi.b	PeekEditError
	bra.w	PeekEditNestAdd

;---- Jump to last address
PeekLast	moveq	#EV_NONESTEDADDS,d1
	move.b	NestedJumps(b),d0;any last?
	bmi.b	PeekEditError
	subq.b	#1,NestedJumps(b);yes, kill it
	asl.w	#2,d0
	lea	NestedJMPTable(b),a2
	move.l	(a2,d0.w),d0	;and jump
	bra.w	PDECheckAddress

;---- Ask for offset and jump to MemAdd+Offset
PeekAddOffset	lea	EditorOffsText(b),a0;ask offset
	bsr.w	GetHeaderInput
	bmi.w	PeekerLoop
	lea	InputLine(b),a0
	bsr.w	GetValueCall
	bmi.w	PeekEditError
	add.l	MemoryAddress(b),d0;and add to current pos
	bra.b	PeekEditNestAdd

;---- handle errors in peeker
PeekEditError	pea	PeekerLoopE(pc)
PeekEditErrorC	move.w	d1,LastErrorNumber(b);store error number
	st.b	LastCMDError(b)	;and flag error
	bra.w	PrintLEInHeader

;---- Add offset to memoryaddress and check for border violation
;- Input:	d2 -	Offset
;----
PDEOffsetNeg	neg.l	d2
PDEOffset	move.l	MemoryAddress(b),d0
	add.l	d2,d0	;calculate new address
	cmp.l	RAMBankStart(b),d0
	bpl.b	.checkupper
	sub.l	RAMBankStart(b),d0
	add.l	RAMBankEnd(b),d0
	addq.l	#1,d0	;correct end-address usage
	bra.b	.addressok

.checkupper	cmp.l	RAMBankEnd(b),d0
	beq.b	.addressok
	bmi.b	.addressok
	sub.l	RAMBankEnd(b),d0
	subq.l	#1,d0	;correct end-address usage
	add.l	RAMBankStart(b),d0

.addressok	move.l	d0,MemoryAddress(b)
	bra.w	PeekerLoopZU

;---- Nest address
PeekEditNestAdd	moveq	#EV_JUMPTABLEFULL,d1;check for full table
	cmp.b	#MaxNested-1,NestedJumps(b)
	beq.b	PeekEditError
	addq.b	#1,NestedJumps(b);nest address in list
	moveq	#0,d1
	move.b	NestedJumps(b),d1
	asl.w	#2,d1
	move.l	MemoryAddress(b),a0
	lea	NestedJMPTable(b),a1
	move.l	a0,(a1,d1.w)

;---- Figure out what memorybank to use
;- default to chip if not in any bank
;- Input:	d0 -	Address
;- Output:	d1 -	0=ok/-1=fool
;----
PDECheckAddress	moveq	#0,d1
	move.b	pr_BankEntries(b),d1
	lea	pr_RAMBank(b),a0
	move.l	a0,a1
.checkarea	cmp.l	(a0)+,d0
	blt.b	.NotValidRAM
	cmp.l	(a0)+,d0
	blt.b	.ValidRAM
	dbra	d1,.checkarea
.NotValidRAM	move.l	(a1)+,d0	;goto (address 0)
	move.l	d0,RAMBankStart(b)
	move.l	(a1),RAMBankEnd(b)
	moveq	#-1,d1	;signal error
	move.w	#$f00,$dff180
	bra.b	.exit

.ValidRAM	move.l	-(a0),RAMBankEnd(b)
	move.l	-(a0),RAMBankStart(b)
	moveq	#0,d1

.exit	move.l	d0,MemoryAddress(b)
	bra.w	PeekerLoopZU


;---- Setup one bitmap page
PeekPage	move.w	PeekerLines(b),d7
	move.l	MemoryAddress(b),a0
	move.l	ScreenBase(b),a1

	moveq	#0,d3
	move.b	PeekerWidth(b),d3

	moveq	#39,d6	;calc center
	sub.w	d3,d6
	move.w	d6,d5
	moveq	#0,d4
	lsr.w	#1,d5
	addx.w	d4,d5
	add.w	d5,d5
	add.w	d5,a1

	lsr.w	#1,d6
	mulu	#20,d6	;each cylcle is 20bytes

	move.w	PeekerModulo(b),d0
	addq.w	#1,d3
	add.w	d3,d3	
	add.w	d3,d0	;add screenwidth to modulo

	move.w	d0,d1
	add.w	d0,d1	;modulo*2
	move.w	d1,d2
	add.w	d0,d2	;modulo*3

	moveq	#80,d3
	move.w	d3,d4	;scrmod
	add.w	d3,d4	;scrmod*2
	move.w	d4,d5
	add.w	d3,d5	;scrmod*3

	btst	#0,PeekerWidth(b)
	beq.w	.setuplinew

.setupline	move.l	a1,a3
	add.w	#80*4,a1

	move.l	a0,a2
	add.w	d2,a0
	add.w	d0,a0

;!gotta do some border violation checking!

	jmp	.copyline(pc,d6.w)

.copyline	rept	20
	move.l	(a2,d0.w),(a3,d3.w)
	move.l	(a2,d1.w),(a3,d4.w)
	move.l	(a2,d2.w),(a3,d5.w)
	move.l	(a2)+,(a3)+
	endr

	dbra	d7,.setupline
	rts


.setuplinew	move.l	a1,a3
	add.w	#80*4,a1

	move.l	a0,a2
	add.w	d2,a0
	add.w	d0,a0

	move.w	(a2,d0.w),(a3,d3.w);copy first word
	move.w	(a2,d1.w),(a3,d4.w)
	move.w	(a2,d2.w),(a3,d5.w)
	move.w	(a2)+,(a3)+

	jmp	.copyline2(pc,d6.w)

.copyline2	rept	19
	move.l	(a2,d0.w),(a3,d3.w)
	move.l	(a2,d1.w),(a3,d4.w)
	move.l	(a2,d2.w),(a3,d5.w)
	move.l	(a2)+,(a3)+
	endr

	dbra	d7,.setuplinew
	rts

;----------------------------------------------------
;- Name	: DisplayVersion
;- Description	: Show GR version string
;- SYNTAX	: ver
;----------------------------------------------------
;- 170194	First version.
;----------------------------------------------------
DisplayVersion	lea	VersionString(pc),a0
	lea	DumpBuffer(b),a1
	move.b	#10,(a1)+
.copy	move.b	(a0)+,(a1)+
	bpl.b	.copy
	move.b	#'(',-1(a1)
	move.b	#'c',(a1)+
	move.b	#')',(a1)+

.copy2	move.b	(a0)+,(a1)+
	bne.b	.copy2

	subq.w	#1,a1
	lea	PrefRevText(b),a0
.cp3	move.b	(a0)+,(a1)+
	bne.b	.cp3

	lea	-1(a1),a0
	moveq	#pref_Revision,d0
	bsr.w	PrintDec
	move.b	#'.',(a0)+
	clr.b	(a0)

	pea	NoPrompt(pc)
	lea	DumpBuffer(b),a0
	bra.w	Print

;----------------------------------------------------
;- Name	: LoadData
;- Description	: Load filedata from disk
;- SYNTAX	: l [<path>file] [addr] <len>
;----------------------------------------------------
;- 201193	First version.
;- 241293	Added evaluation-assembly
;- 270494	Added path parsing.
;----------------------------------------------------
LoadData:	moveq	#1,d0
	bsr.w	ParsePath


;	bsr.w	GetFileName
	bsr.w	GetValueSkip
	move.l	d0,AbsLoadAddr(b)
	bsr.w	GetValueCall
	cmp.w	#EV_NOVALUE,d1
	beq.b	.nolen
	tst.w	d1
	bne.w	PrintErrorMO
	moveq	#EV_ILLEGALLEN,d1
	tst.l	d0
	bmi.w	PrintErrorMO
	moveq	#EV_PRETTYFAST,d1
	tst.l	d0
	beq.w	PrintErrorMO
	bra.b	.lenvalid

.nolen	moveq	#-1,d0
.lenvalid	move.l	d0,AbsLoadLen(b)

	lea	TextLineBuffer(b),a0
	lea	LoadingFileText(b),a1
	lea	FileNameBuffer+1(b),a2
.cp1	move.b	(a1)+,(a0)+
	bne.b	.cp1
	subq.w	#1,a0
.cp2	move.b	(a2)+,(a0)+
	bne.b	.cp2
	subq.w	#1,a0
.cp3	move.b	(a1)+,(a0)+
	bne.b	.cp3
	subq.w	#1,a0
	move.l	AbsLoadAddr(b),d0
	bsr.w	PrintHexL
	move.b	#'-',(a0)+
	move.b	#pc_CLRRest,(a0)+
	clr.b	(a0)
	lea	TextLineBuffer(b),a0
	grcall	Print

	move.l	BlockBuffer+FH_BYTELEN,d0;check if max loadlength
	move.l	AbsLoadLen(b),d1;is bigger than filelength. If so
	bmi.b	.SetFileLength	;set length to that of file.
	cmp.l	d0,d1
	bpl.b	.SetFileLength
	move.l	d1,d0
.SetFileLength	move.l	d0,AbsLoadLen(b)

	move.l	AbsLoadAddr(b),a4
	move.l	AbsLoadLen(b),d7
	move.w	CurXPos(b),FileUpdatePos(b)

.AbsLoadLoop	lea	DirectoryCache,a1
	move.l	a1,a2
	lea	BlockBuffer,a0
	move.l	FH_EXTENSION(a0),NextFileBlock(b)
	move.l	FH_BLOCKCOUNT(a0),d0
;	moveq	#EV_EMPTYBLOCKTABLE,d1;shouldn't occur on a valid disk
	subq.w	#1,d0
;	bmi.b	PrintError
	add.w	#FH_DATABLOCKSE,a0
	move.w	d0,d6	;# of valid blockptrs
.copyblockptrs	move.l	-(a0),(a1)+	;correct order
	dbra	d0,.copyblockptrs;stop copy if zero

.LoadBlock	tst.b	UserBreak(b)	;test for user-break
	bne.b	.LoadBroken

	move.l	a4,d0
	move.w	d5,d1
	bsr.w	PrintDiskLength

	move.l	(a2)+,d0
	grcall	GetBlock

	lea	BlockBuffer,a0
	move.w	#$200-1,d0	;byte counter (FFS)
	tst.b	FastFileSystem(b)
	bne.b	.FFS
	move.l	3*4(a0),d0	;correct to OFS's $1E8 data bytes
	subq.w	#1,d0
	lea	$18(a0),a0	;fix pointer
.FFS	move.b	(a0)+,(a4)+
	subq.l	#1,d7
	beq.b	.FileLoaded
	dbra	d0,.FFS

	dbra	d6,.LoadBlock

	move.l	NextFileBlock(b),d0
	beq.b	.FileLoaded
	grcall	GetBlock
	bra.b	.AbsLoadLoop

.FileLoaded
.LoadBroken	move.l	a4,d0
	move.w	d5,d1
	bsr.b	PrintDiskLength

	grcall	MotorOff
	bra.w	NoPrompt


;---- Print actual pos and endpos ($xxxx/$xxxx)
;-- INPUT:	d0.l -	Current address
;--	FileUpdatePos - CurX/YPos
;--	AbsLoadLen & AbsLoadAddr must be valid
;----
PrintDiskLength	lea	TextLineBuffer(b),a0
	move.l	a0,a1
	move.b	#pc_Pos,(a0)+	;set pos
	move.b	FileUpdatePos(b),(a0)+
	move.b	FileUpdatePos+1(b),(a0)+
	bsr.w	PrintHexL
	move.b	#'/',(a0)+
	move.l	AbsLoadLen(b),d0
	add.l	AbsLoadAddr(b),d0
	bsr.w	PrintHexL
	move.b	#pc_CLRRest,(a0)+
	clr.b	(a0)
	move.l	a1,a0
	bra.w	Print


;---- Find a file on disk
;- INPUT:	Name in FileNameBuffer
;- OUTPUT:	d0 -	Block# of fileheader
;-	d1 -	Error/OK
;-	d2 -	Previous hash
;----
FindFileHeaderInBlock		;d0 = start block
	Push	d6-a2
	bra.b	FindFileHeader\.Entry

FindFileHeader	Push	d6-a2
	moveq	#0,d0
	move.b	SelectedDrive(b),d0
	add.w	d0,d0
	lea	CDTable(b),a0
	move.w	(a0,d0.w),d0	;get the root block
.Entry	move.w	d0,d7	;previous hash link
	grcall	GetBlock

	bsr.w	CalcNameHash

	lea	BlockBuffer,a2
	move.w	d0,FileNameHash(b)
	move.l	(a2,d0.w),d6	;get hash-link

.SeekLoop	move.l	d6,d0
	beq.b	.FileNotFound
	grcall	GetBlock

	lea	FH_NAME(a2),a0;check that filenames are equ
	lea	FileNameBuffer(b),a1
	moveq	#0,d0
	move.b	(a0)+,d0
	cmp.b	(a1)+,d0
	bne.b	.CheckNextHash
	subq.w	#1,d0
.compareloop	move.b	(a0)+,d2
	bsr.w	UpperCase
	move.b	d2,d1
	move.b	(a1)+,d2
	bsr.w	UpperCase
	cmp.b	d1,d2
	bne.b	.CheckNextHash
	dbra	d0,.compareloop

	move.l	d6,d0	;fileheader
	move.l	d7,d2	;previous hash block
	moveq	#0,d1
	Pull	d6-a2
	rts

.CheckNextHash	move.l	d6,d7	;prev:=current
	move.l	FH_HASHCHAIN(a2),d6
	bra.b	.SeekLoop

.FileNotFound	moveq	#EV_FILENOTFOUND,d1
	Pull	d6-a2
	rts

;---- Get filename
;Later versions should set flag if other files match, so a re-do loop can be made
;Name must be parsed like "name" or 'name'
GetFileName	move.b	(a0)+,d0
	beq.b	.noname
	cmp.b	#' ',d0
	beq.b	GetFileName
	cmp.b	#'"',d0
	beq.b	.NameStart
	cmp.b	#"'",d0
	beq.b	.NameStart
	moveq	#' ',d0
	subq.w	#1,a0
.NameStart	lea	FileNameBuffer(b),a1
	moveq	#0,d2
	clr.b	(a1)+	;name at error is set to NULL
.CopyName	move.b	(a0)+,d1
	beq.b	.corruptname
	cmp.b	d1,d0
	beq.b	.NameEnd
	move.b	d1,(a1)+
	addq.w	#1,d2
	cmp.w	#31,d2	;name of max 30 chars
	bne.b	.CopyName

.corruptname	moveq	#EV_CORRUPTFILENAME,d1
	bra.w	PrintError

.NameEnd	clr.b	(a1)	;mark end with a null
	move.l	a0,-(a7)
	lea	FileNameBuffer(b),a0
	move.b	d2,(a0)	;set length
	bsr.b	CalcNameHash
	move.w	d0,FileNameHash(b)
	move.l	(a7)+,a0
	rts

.noname	moveq	#EV_NOFILENAME,d1
	bra.w	PrintError

;---- Calculate namehash from BCPL string
;- input:	a0 -	BCPL string
;- output:	d0.w -	hash (6-77)*4
;----
CalcNameHash	Push	d1/d2
	lea	FileNameBuffer(b),a0
	moveq	#0,d0
	move.b	(a0)+,d0
	move.w	d0,d1
	subq.w	#1,d1
	bmi.b	.noname
.hashloop	mulu	#13,d0
	moveq	#0,d2
	move.b	(a0)+,d2
	bsr.b	UpperCase
	add.w	d2,d0
	and.w	#$7ff,d0
	dbra	d1,.hashloop
	divu	#72,d0
	swap	d0
.noname	addq.w	#6,d0
	asl.w	#2,d0
	Pull	d1/d2
	rts

;---- Convert a-z to A-Z
;-- input:	d2 - char to be upped
;----
UpperCase	cmp.b	#'a',d2
	blt.b	.noupper
	cmp.b	#'z',d2
	bgt.b	.noupper
	and.w	#~$20,d2	;conver a-z to A-Z
.noupper	rts

;---- Save data to disk file
SaveData:	moveq	#pp_NEWFILE,d0
	bsr.w	ParsePathWrite
	move.l	d1,-(a7)	;keep DIR
	move.l	d2,-(a7)	;flag file/no file
	move.l	d0,-(a7)	;file block

	bsr.w	GetStartEnd	;get start and end
	move.l	d7,AbsSaveStart(b)
	move.l	d7,AbsLoadAddr(b);for progress calculation and FH update if broken
	move.l	d6,AbsSaveEnd(b)

	sub.l	d7,d6	;figure out how many datablocks are needed
	move.l	d6,AbsSaveLen(b)
	move.l	#$200,d0	;blocksize (FFS)
	tst.b	FastFileSystem(b)
	bne.b	.FFS
	sub.w	#7*4,d0	;sub OFS data header
.FFS	divu	d0,d6
	moveq	#0,d7
	move.w	d6,d7
	swap	d6
	tst.w	d6
	beq.b	.CleanFit
	addq.w	#1,d7	;add extra block if needed

.CleanFit	move.l	d7,d1
	divu	#72,d1	;calc how many fileheaders are needed
	move.w	d1,d2
	swap	d1
	tst.w	d1
	beq.b	.CleanFitII
	addq.w	#1,d2	;add extra block if needed
.CleanFitII	add.w	d2,d7	;number of needed data+header blocks

	move.l	(a7)+,d0	;did we have a file with same name?
	tst.l	(a7)+
	beq.b	.nofile
	move.l	(a7),d1	;del also needs parent!
	Push	all
	bsr.w	DeleteBlockList	;if so, may it RIP
	Pull	all

.nofile	move.w	ROOTBlock(b),d0
	grcall	GetBlock
	lea	BlockBuffer,a4
	move.l	FH_BMPAGES(a4),d0
	move.w	d0,BMPageBlock(b)
	lea	BlockBufferII,a3
	move.l	a3,a0
	grcall	GetBlockToAdd	;get bitmap

	moveq	#0,d0	;sum free blocks
	move.b	DiskSectors(b),d0
	mulu	#160,d0
	subq.w	#1,d0
	moveq	#0,d6
.findfree	bsr.w	TestBMFlag
	beq.b	.used
	addq.w	#1,d6
.used	subq.w	#1,d0
	cmp.w	#1,d0
	bne.b	.findfree	

	moveq	#EV_NOTENOUGHSPACE,d1
	move.w	d6,d5
	sub.w	d7,d5	;keep count in D5 for usage in cache checker
	bmi.w	PrintErrorMO	;error if not enough disk space

	Push	all
	lea	SavingFileText(b),a1
	lea	TextLineBuffer(b),a0
.cp1	move.b	(a1)+,(a0)+
	bne.b	.cp1
	subq.w	#1,a0
	lea	FileNameBuffer+1(b),a2
.cp2	move.b	(a2)+,(a0)+
	bne.b	.cp2
	subq.w	#1,a0
.cp3	move.b	(a1)+,(a0)+
	bne.b	.cp3
	subq.w	#1,a0
	move.l	AbsSaveStart(b),d0
	bsr.w	PrintHexL
	move.b	#'-',(a0)+
	move.b	#pc_CLRRest,(a0)+
	clr.b	(a0)
	lea	TextLineBuffer(b),a0
	bsr.w	Print
	Pull	all

	move.w	ROOTBlock(b),d7	;start putting data from this block up

	bsr.w	FindFreeBlock
	move.l	d7,d0
	bsr.w	SetBMFlag

	grcall	ReadBatClock	;read time at save start

	move.w	#-1,CacheBlock(b)

	btst	#2,DOSFormat(b)
	beq.w	.NoCache

	moveq	#0,d4	;calc what's needed in cache
	move.b	FileNameBuffer(b),d4
	add.w	#1+24,d4	;space for null & struct
;0123456789012345678901234567890
;-----------------------xNN0
	btst	#0,d4
	beq.b	.align
	addq.w	#1,d4	;add 1 byte for alignment
.align
	move.l	(a7),d0
	move.l	d0,d3
	grcall	GetBlock	;get parent DIR

	move.l	FH_CACHEBLOCK(a4),d0
	beq.b	.AddExtraCache
.ScanFreeCache	grcall	GetBlock

	lea	FH_CACHEOFFSET(a4),a0
	move.l	FH_CACHECOUNT(a4),d0
	beq.w	.EmptyCache
	subq.w	#1,d0
.ScanCacheEntry	add.w	#23,a0	;get to name bstr
	moveq	#0,d1
	move.b	(a0)+,d1	;get size of name
	add.w	d1,a0	;get to end of name
	move.b	(a0),d1	;any comment?
	bne.b	.comment
	moveq	#1,d1	;if no comment, 2 bytes reserved
.comment	add.w	d1,a0	;if so, add size
	move.w	a0,d1	;test alignment
	btst	#0,d1
	beq.b	.alignOK
	addq.w	#1,a0
.alignOK	dbra	d0,.ScanCacheEntry

	move.l	a0,d0
	sub.l	a4,d0	;calc free length
	cmp.l	d0,d4
	bmi.b	.CacheFit	;enough space

	move.l	FH_SELFPOINTER(a4),d3
	move.l	FH_NEXTCACHE(a4),d0
	bne.b	.ScanFreeCache

;ptr to parent in d3 (can be both DIR and CACHE!)
.AddExtraCache	moveq	#EV_NOTENOUGHSPACE,d1
	tst.w	d5	;any free blocks?
	beq.w	PrintErrorMO	;nah, stop process

	move.l	d7,FH_NEXTCACHE(a4);set free block as next in chain
	move.l	a4,a0
	bsr.w	ChecksumBlock	;redo checksum
	move.l	d0,FH_CHECKSUM(a4);store
	move.l	d3,d0
	move.l	FH_DIRECTORY(a4),d5
	grcall	SaveBlock	;and save block to disk

	move.l	a4,a0	;init new cache block
	move.l	#T_CACHE,(a0)+
	move.l	d7,(a0)+	;self ptr
	move.l	d5,(a0)+	;dir ptr
	clr.l	(a0)+	;no data in this cache
	clr.l	(a0)+	;no next block
	clr.l	(a0)+	;no checksum (yet)
	move.l	a0,a1	;clear rest, but keep ptr to next in a0
	moveq	#($200-FH_CACHEOFFSET)/4-1,d0
.zaprest	clr.l	(a1)+
	dbra	d0,.zaprest

	Push	a0
	bsr.w	FindFreeBlock	;find next free block if prev d7 was used for new cacheblock
	move.l	d7,d0
	bsr.w	SetBMFlag
	Pull	a0

.CacheFit
.EmptyCache	move.l	d7,(a0)+	;ptr to fileheader
	move.l	a0,d0	;calc ptr if changing is needed.
	sub.l	a4,d0
	move.w	d0,LenOffCacheBreak(b)
	move.l	AbsSaveLen(b),(a0)+;length
	clr.l	(a0)+	;protectionbits
	clr.l	(a0)+
	lea	Time00+2(b),a1
	move.w	(a1),(a0)+	;hours
	move.w	4(a1),(a0)+	;mins
	move.w	8(a1),(a0)+	;ticks
	move.b	#ST_FILE,(a0)+
	lea	FileNameBuffer(b),a1
.copyname	move.b	(a1)+,(a0)+
	bne.b	.copyname
	move.w	a0,d0	;align (is this needed?)
	btst	#0,d0
	beq.b	.aligned
;	addq.w	#1,a0
	clr.b	(a0)+
.aligned
	addq.l	#1,FH_CACHECOUNT(a4);inc counter
	move.l	a4,a0
	bsr.w	ChecksumBlock
	move.l	d0,FH_CHECKSUM(a4)

	move.l	FH_SELFPOINTER(a4),d0
	move.w	d0,CacheBlock(b);for length changing if needed
	grcall	SaveBlock

.NoCache	move.l	(a7),d0	;parent DIR

	grcall	GetBlock
	grcall	CalcNameHash
	move.l	(a4,d0.w),d5	;get old hash
	move.l	d7,(a4,d0.w)
	move.l	a4,a0
	bsr.w	ChecksumBlock
	move.l	d0,FH_CHECKSUM(a4)

	move.l	(a7),d0
	grcall	SaveBlock	;save updated host DIR

	lea	BlockBufferIII,a2
	move.l	a2,a0	;prepare file header
	moveq	#$200/4-1,d0
.clr	clr.l	(a0)+
	dbra	d0,.clr

	move.l	d5,FH_HASHCHAIN(a2)
	move.l	(a7)+,FH_PARENTDIR(a2);remove parent dir hash from stack
	moveq	#T_SHORT,d0
	move.l	d0,(a2)
	move.l	d7,FH_SELFPOINTER(a2)
	move.l	d7,FileHeaderBlock(b)
	move.l	AbsSaveLen(b),FH_BYTELEN(a2)
	move.l	Time00(b),FH_TIMEDAYS(a2)
	move.l	Time01(b),FH_TIMEMINS(a2)
	move.l	Time02(b),FH_TIMETICKS(a2)
	moveq	#ST_FILE,d0
	move.l	d0,FH_SECTYPE(a2)
	moveq	#0,d0
	move.l	d0,FH_PROTECTION(a2)

	lea	FileNameBuffer(b),a0
	lea	FH_NAME(a2),a1
.copyname2	move.b	(a0)+,(a1)+
	bne.w	.copyname2

	moveq	#0,d6	;running datablock # for OFS
	move.l	AbsSaveEnd(b),d5

	bsr.w	FindFreeBlock	;find free block for data
	move.l	d7,d0
	bsr.w	SetBMFlag

	move.w	CurXPos(b),FileUpdatePos(b)

.StoreDataLoop	move.l	a2,-(a7)	;BEWARE! stack is used!

	move.l	d7,FH_FIRSTDATA(a2)

	lea	FH_DATABLOCKSE(a2),a2;work downwards in table

	moveq	#72-1,d4	;Total blocks per file header

.BlockLoop	Push	all	;just playing it safe!
	move.l	AbsSaveStart(b),d0
	bsr.w	PrintDiskLength
	Pull	all	;just playing it safe!

	move.l	d7,-(a2)	;store current block in fileheader

	move.l	(a7),a0
	addq.l	#1,FH_BLOCKCOUNT(a0)

	move.l	a4,a0

	move.l	#$200,d1	;free bytes in this block

	move.l	AbsSaveStart(b),a1

	move.l	d5,d2
	sub.l	a1,d2	;calc remaining data

	tst.b	FastFileSystem(b)
	bne.b	.FFS4
	sub.w	#6*4,d1	;6*4 bytes fewer

.FFS4	cmp.l	d2,d1	;if > blocksize valid = $1e8
	bge.b	.LastBlock
	move.l	d1,d2
.LastBlock
	tst.b	FastFileSystem(b)
	bne.b	.FFS2

	moveq	#T_DATA,d0	;build data header if OFS
	move.l	d0,(a0)+
	move.l	FileHeaderBlock(b),(a0)+
	move.l	d6,(a0)+
	addq.l	#1,d6

	move.l	d2,(a0)+	;valid databytes in block
	clr.l	(a0)+	;next datablock (insert)
	clr.l	(a0)+	;checksum (insert)

.FFS2	subq.w	#1,d2
.CopyBytes	move.b	(a1)+,(a0)+	;get a byte
	dbra	d2,.CopyBytes

	move.l	a1,AbsSaveStart(b)

	move.l	d7,d3

	tst.b	UserBreak(b)	;test for user-break
	bne.w	.SaveBroken

	moveq	#0,d2	;signal no more data
	cmp.l	a1,d5	;end?
	beq.b	.NoMoreBlocks

	moveq	#1,d2	;signal more data
	bsr.w	FindFreeBlock	;if not end, find next datablock

	move.l	d7,d0
	bsr.w	SetBMFlag

.NoMoreBlocks	tst.b	FastFileSystem(b);only checksum if OFS!
	bne.b	.FFS3

	tst.w	d2	;store next datablock
	beq.b	.NoNext
	move.l	d7,FH_NEXTDATA(a4);and put in current

.NoNext	move.l	a4,a0	;checksum block
	bsr.w	ChecksumBlock
	move.l	d0,FH_CHECKSUM(a4)

.FFS3	move.l	d3,d0
	grcall	SaveBlock	;and save to disk

	tst.w	d2	;end?
	beq.b	.Done

	dbra	d4,.BlockLoop

.Done	move.l	(a7)+,a2

	clr.l	FH_EXTENSION(a2)

	tst.w	d2	;need new fileheader?
	beq.b	.NoNewHeader

	move.l	d7,d3	;this is next datablocks address!

	bsr.w	FindFreeBlock	;find new fileheaderblock
	move.l	d7,d0
	bsr.w	SetBMFlag
	move.l	d7,FH_EXTENSION(a2)

.NoNewHeader	move.l	a2,a0
	bsr.w	ChecksumBlock
	move.l	d0,FH_CHECKSUM(a2)

	move.l	a2,a0
	move.l	FH_SELFPOINTER(a2),d0
	grcall	SaveBlockAdd

	tst.w	d2
	beq.b	.EndAtLast

	move.l	FileHeaderBlock(b),FH_PARENTDIR(a2)
	clr.l	FH_HASHCHAIN(a2)
	moveq	#T_LIST,d0
	move.l	d0,(a2)
	move.l	d7,FH_SELFPOINTER(a2)
	move.l	d3,d7	;correct data block!

	lea	FH_BLOCKCOUNT(a2),a0
	moveq	#72+4-1,d0
.ZapTable	clr.l	(a0)+	;datasize & blkcnt included!
	dbra	d0,.ZapTable

	bra.w	.StoreDataLoop

.EndAtLast	bsr.w	ChecksumBMPage
	move.l	d0,(a3)
	move.l	a3,a0
	move.w	BMPageBlock(b),d0
	grcall	SaveBlockAdd

	tst.l	d2	;Update length in fileheader?
	bpl.b	.NoUpdate

	move.l	FileHeaderBlock(b),d0
	grcall	GetBlock

	move.l	AbsSaveStart(b),d0;current address
	sub.l	AbsLoadAddr(b),d0; - start address
	move.l	d0,FH_BYTELEN(a4); = length
	move.l	d0,-(a7)	;save for use in cache

	move.l	a4,a0	;redo checksum
	bsr.w	ChecksumBlock
	move.l	d0,FH_CHECKSUM(a4)

	move.l	FileHeaderBlock(b),d0
	grcall	SaveBlock	;and save block to disk

	move.w	CacheBlock(b),d0;also update cacheblock if enabled
	bmi.b	.NoCacheFix
	grcall	GetBlock

	move.w	LenOffCacheBreak(b),d0
	move.l	(a7),(a4,d0.w)	;set correct length

	move.l	a4,a0
	bsr.w	ChecksumBlock
	move.l	d0,FH_CHECKSUM(a4)

	move.w	CacheBlock(b),d0
	grcall	SaveBlock

.NoCacheFix	addq.l	#4,a7


.NoUpdate	move.l	AbsSaveStart(b),d0
	bsr.w	PrintDiskLength

	grcall	UpdateDisk
	grcall	MotorOff

	bra.w	NoPrompt

.SaveBroken	moveq	#-1,d2	;signal fileheader length wrong
	clr.w	d2
	bra.w	.NoMoreBlocks


;---- Delete file from disk
DeleteFile:	moveq	#pp_FILE,d0
	bsr.w	ParsePathWrite

	bsr.b	DeleteBlockList

	grcall	MotorOff
	bra.w	NoPrompt

;-INPUT:	d0 -	Current disk block
;-	d1 -	Parent (DIR) disk block (= File's Parent)
;-	Name in FileNameBuffer
;-	Drive must be initialized
DeleteBlockList	move.l	d0,-(a7)
	move.l	d1,-(a7)	;store host DIR
	move.l	d1,d0
	bsr.w	FindFileHeaderInBlock;find immediate parent header (d2)
	bmi.w	PrintErrorMO

	lea	BlockBuffer,a4
	move.l	FH_HASHCHAIN(a4),d7;get HASHCHAIN
	move.w	d2,d0	;get immediate parent (returned from FFHIB)
	grcall	GetBlock

	move.w	#FH_HASHCHAIN,d0
	tst.l	FH_SECTYPE(a4)	;DIR or FILE?
	bmi.b	.file
	bsr.w	CalcNameHash

.file	move.l	d7,(a4,d0.w)	;store HASHCHAIN in parent

	move.l	a4,a0	;put new checksum
	bsr.w	ChecksumBlock
	move.l	d0,FH_CHECKSUM(a4)

	move.w	d2,d0	;and save block
	grcall	SaveBlock

	move.w	ROOTBlock(b),d0
	grcall	GetBlock

	move.l	FH_BMPAGES(a4),d0
	move.l	d0,d7	;keep BM block for saving
	lea	BlockBufferII,a3
	move.l	a3,a0
	grcall	GetBlockToAdd

;; Check for linked file!
; Check for (empty) dir!

	btst	#2,DOSFormat(b)
	beq.w	.DoNormalDir

	move.l	(a7),d0
	move.l	d0,d5
	grcall	GetBlock

	move.l	FH_CACHEBLOCK(a4),d0
	move.l	4(a7),d4	;ptr to actual file
.DelCacheLoop	tst.l	d0	;keep parent ptr
	beq.w	.DoNormalDir	;ERROR!
	grcall	GetBlock

	move.l	FH_CACHECOUNT(a4),d0
	beq.b	.EmptyCache
	subq.w	#1,d0
	lea	FH_CACHEOFFSET(a4),a0
.ScanCacheEntry	move.l	a0,a1	;keep for updating cache (moving data)
	move.l	(a0),d2	;get current blockptr for later cmp
	add.w	#23,a0	;get to name bstr
	moveq	#0,d1
	move.b	(a0)+,d1	;get size of name
	add.w	d1,a0	;get to end of name
	move.b	(a0),d1	;any comment?
	bne.b	.comment
	moveq	#1,d1	;if no comment, 2 bytes reserved
.comment	add.w	d1,a0	;if so, add size
	move.w	a0,d1	;test alignment
	btst	#0,d1
	beq.b	.alignOK
	addq.w	#1,a0
.alignOK	cmp.l	d2,d4	;key match file?
	beq.b	.CacheHit
	dbra	d0,.ScanCacheEntry

.EmptyCache	move.l	FH_NEXTCACHE(a4),d0
	move.l	FH_SELFPOINTER(a4),d5
	bra.b	.DelCacheLoop

.CacheHit	subq.l	#1,FH_CACHECOUNT(a4);decrease cache count
	bne.b	.UpdateCache	;update if still containing data

	lea	FH_CACHEOFFSET(a4),a0
	moveq	#($200-FH_CACHEOFFSET)/4-1,d0
.clrcache	clr.l	(a0)+
	dbra	d0,.clrcache

	move.l	a4,a0
	grcall	ChecksumBlock
	move.l	d0,FH_CHECKSUM(a4);update checksum

	move.l	FH_SELFPOINTER(a4),d0
	grcall	SaveBlock	;and get block back to disk

	move.l	FH_NEXTCACHE(a4),d3
	move.l	FH_SELFPOINTER(a4),d2

	move.l	d5,d0
	grcall	GetBlock	;get parent cache/DIR

	moveq	#T_CACHE,d0
	cmp.l	(a4),d0	;Is parent a cache
	bne.b	.Directory
	move.l	d3,FH_NEXTCACHE(a4);remove from list
	move.w	d2,d0
	bsr.w	ClrBMFlag

	bra.b	.CacheReady

.Directory	tst.l	d3	;Only delete cache in DIR if there
	beq.b	.NoCacheDel	;follow a cache
	move.l	d3,FH_CACHEBLOCK(a4)

	move.w	d2,d0
	bsr.w	ClrBMFlag
	bra.b	.CacheReady

.UpdateCache	move.l	a0,d0
	sub.l	a1,d0	;size of block to be deleted

	move.l	#$200-1,d1	;calc how much need moving
	add.l	a4,d1
	sub.l	a0,d1
	bmi.b	.nocopy
.copydata	move.b	(a0)+,(a1)+
	dbra	d1,.copydata

.nocopy	clr.b	(a1)+
	subq.w	#1,d0
	bne.b	.nocopy
	move.l	FH_SELFPOINTER(a4),d5;fix so .CacheReady can be used

.CacheReady	move.l	a4,a0
	grcall	ChecksumBlock
	move.l	d0,FH_CHECKSUM(a4);update checksum
	move.l	d5,d0

	grcall	SaveBlock	;and get block back to disk

.NoCacheDel
.DoNormalDir	addq.w	#4,a7	;remove host DIR
	move.l	(a7)+,d0

.DeleteMainLoop	bsr.w	ClrBMFlag	;free fileheader
	grcall	GetBlock	;get file's blocklist

	move.l	FH_BLOCKCOUNT(a4),d6
	subq.w	#1,d6
	bmi.b	.OutOfBlocks

	lea	FH_DATABLOCKSE(a4),a0

.DoBlocks	move.l	-(a0),d0
	bsr.b	ClrBMFlag

	dbra	d6,.DoBlocks

	move.l	FH_EXTENSION(a4),d0
	bne.b	.DeleteMainLoop

.OutOfBlocks	bsr.b	ChecksumBMPage
	move.l	d0,(a3)

	move.l	a3,a0
	move.l	d7,d0
	grcall	SaveBlockAdd

	grcall	UpdateDisk

	rts


;---- Checksum BM page
;- INPUT:	a3 -	BMPage
;- OUTPUT:	d0 -	Checksum
;----
ChecksumBMPage	Push	d1/a0
	lea	4(a3),a0
	moveq	#$80-2,d1
	moveq	#0,d0
.sumtable	sub.l	(a0)+,d0
	dbra	d1,.sumtable
	Pull	d1/a0
	rts


;----- Set/Clr/Test Bitmap flag
;- INPUT:	d0 -	block#
;-	a3 -	BitmapTable
;- OUTPUT:	<T/F if Test> (0 = Block used)
;-----
SetBMFlag	Push	d0/d1/d2
	subq.w	#2,d0
	move.w	d0,d1
	and.w	#~%11111,d1
	lsr.w	#3,d1
	move.l	4(a3,d1.w),d2
	and.w	#%11111,d0
	bclr	d0,d2
	move.l	d2,4(a3,d1.w)
	Pull	d0/d1/d2
	rts

ClrBMFlag	Push	d0/d1/d2
	subq.w	#2,d0
	move.w	d0,d1
	and.w	#~%11111,d1
	lsr.w	#3,d1
	and.w	#%11111,d0
	move.l	4(a3,d1.w),d2
	bset	d0,d2
	move.l	d2,4(a3,d1.w)
	Pull	d0/d1/d2
	rts

TestBMFlag	Push	d0/d1
	subq.w	#2,d0
	move.w	d0,d1
	and.w	#~%11111,d1
	lsr.w	#3,d1
	move.l	4(a3,d1.w),d1
	and.w	#%11111,d0
	btst	d0,d1
	Pull	d0/d1
	rts

;---- Scan BM for a free block
;- INPUT:	d7 -	start block (will wrap at max_block)
;-	a3 -	BM table
;- OUTPUT:	d7 -	next free block
;-		-1 if no free block
;----
FindFreeBlock	Push	d0/d3-d6
	move.w	d7,d3
	move.w	d7,d6
	subq.w	#2,d6
	move.w	d6,d5
	and.w	#%11111,d6	;actual bit
	and.w	#~%11111,d5
	lsr.w	#3,d5	;address

	move.w	#11*160,d0	;max address
	cmp.b	#11,DiskSectors(b)
	beq.b	.DDDisk
	add.w	d0,d0
.DDDisk

.ScanLoop	move.l	4(a3,d5.w),d4
.ScanBitLoop	btst	d6,d4	;is block used?
	bne.b	.FreeBlock	;if not, break loop

	addq.w	#1,d7
	cmp.w	d7,d3
	beq.b	.NoFree

	cmp.w	d7,d0
	bne.b	.WrapDisk
	moveq	#0,d6
	moveq	#0,d5
	moveq	#2,d7
	bra.b	.ScanLoop

.WrapDisk	addq.w	#1,d6
	cmp.w	#$20,d6
	bne.b	.ScanBitLoop
	moveq	#0,d6
	addq.w	#4,d5
	bra.w	.ScanLoop

.NoFree	moveq	#-1,d7

.FreeBlock	Pull	d0/d3-d6
	swap	d7
	clr.w	d7
	swap	d7
	tst.w	d7
	rts


;----------------------------------------------------
;- Name	: Display date
;- Description	: Get date from batteryclock, then display it.
;- SYNTAX	: date
;----------------------------------------------------
;- 141193	First version.
;----------------------------------------------------
DisplayDate	grcall	ReadBatClock

	lea	TextLineBuffer(b),a0
	move.b	#10,(a0)+
	lea	Time00+2(b),a3
	moveq	#0,d0
	move.w	(a3),d0
	move.l	#24*60*60,d1
	bsr.w	UMult32

	move.w	4(a3),d1
	mulu	#60,d1
	add.l	d1,d0
	moveq	#0,d1
	move.w	8(a3),d1
	divu	#50,d1
	swap	d1
	clr.w	d1
	swap	d1
	add.l	d1,d0
	move.l	a0,a1
	lea	DateBuffer(b),a0
	grcall	Amiga2Date
	exg	a0,a1
	moveq	#0,d0
	move.w	mday(a1),d0
	bsr.w	PrintDec
	move.b	#'-',(a0)+
	moveq	#0,d0
	move.w	month(a1),d0
	subq.w	#1,d0
	move.w	d0,d1
	add.w	d1,d1
	add.w	d1,d0
	lea	MonthNamesText(b),a2
	add.w	d0,a2
	move.b	(a2)+,(a0)+	;copy name of month
	move.b	(a2)+,(a0)+
	move.b	(a2)+,(a0)+
	move.b	#'-',(a0)+
	moveq	#0,d0
	move.w	year(a1),d0
	bsr.w	PrintDec
	move.b	#' ',(a0)+

	moveq	#0,d0
	move.w	hour(a1),d0
	cmp.w	#10,d0
	bge.b	.one0
	move.b	#'0',(a0)+
.one0	bsr.w	PrintDec
	move.b	#':',(a0)+
	moveq	#0,d0
	move.w	min(a1),d0
	cmp.w	#10,d0
	bge.b	.one1
	move.b	#'0',(a0)+
.one1	bsr.w	PrintDec
	move.b	#':',(a0)+
	moveq	#0,d0
	move.w	sec(a1),d0
	cmp.w	#10,d0
	bge.b	.one2
	move.b	#'0',(a0)+
.one2	bsr.w	PrintDec

	clr.b	(a0)
	lea	TextLineBuffer(b),a0
	pea	NoPrompt(pc)
	bra.w	Print


;----------------------------------------------------
;- Name	: Internal dump
;- Description	: Show internal buffers and other data.
;- SYNTAX	: int
;----------------------------------------------------
;- 131193	First version.
;----------------------------------------------------
InternalDump	lea	InternalText(b),a3
	lea	InternalPoints,a2
	move.l	ChipMem(b),d7
.dumploop	tst.b	(a3)
	beq.b	.exit
	bpl.w	.ok
	move.l	(a2)+,d7	;get new offset (0=abs/b=B)
	addq.w	#1,a3
	bra.b	.dumploop

.ok	lea	TextLineBuffer(b),a0
	move.b	#10,(a0)+
.cp1	move.b	(a3)+,(a0)+
	bne.b	.cp1
	move.b	#':',-1(a0)
	move.b	#' ',(a0)+
	move.l	(a2)+,d0
	add.l	d7,d0
	bsr.w	PrintHexL
	move.b	#pc_CLRRest,(a0)+
	clr.b	(a0)
	lea	TextLineBuffer(b),a0
	grcall	Print
	bra.b	.dumploop

.exit	bra.w	NoPrompt

;----------------------------------------------------
;- Name	: ChangeExitCus
;- Description	: Show/change ptr to custom program
;- SYNTAX	: cus <program>
;----------------------------------------------------
;- 071193	First version.
;- 070994	Now changes address of program to be executed at exit
;----------------------------------------------------
ChangeExitCus	bsr.w	GetValueCall
	cmp.w	#EV_NOVALUE,d1
	beq.b	.CUSDisplay	;if no input -> display address
	tst.w	d1
	bmi.w	PrintError

	move.l	d0,CustomProgram(b)

.CUSDisplay	lea	TextLineBuffer(b),a0
	lea	CustomCodeText(b),a1
.cp1	move.b	(a1)+,(a0)+
	bne.b	.cp1
	subq.w	#1,a0

	move.l	CustomProgram(b),d0
	beq.b	.NotDefined

.cp3	move.b	(a1)+,(a0)+
	bne.b	.cp3
	subq.w	#1,a0
	bsr	PrintHexL
	clr.b	(a0)
	bra.b	.StringDone

.NotDefined	lea	CustomCodeTextb(b),a1;not defined
.cp2	move.b	(a1)+,(a0)+
	bne.b	.cp2

.StringDone	lea	TextLineBuffer(b),a0
	grcall	Print
	bra.w	NoPrompt

;----------------------------------------------------
;- Name	: CopperActive
;- Description	: Show/change active exitcopper
;- SYNTAX	: copact <0/1>
;----------------------------------------------------
;- 071193	First version.
;----------------------------------------------------
CopperActive	bsr.w	GetValueCall
	cmp.w	#EV_NOVALUE,d1
	beq.b	.display
	tst.w	d1
	bne.w	PrintError
	moveq	#EV_ILLEGALCOPPER,d1
	cmp.l	#1,d0
	beq.b	.ok
	tst.l	d0
	bne.w	PrintError
.ok	move.b	d0,ActiveCopper(b)
.display	lea	CopActiveText(b),a1
	lea	TextLineBuffer(b),a0
.cp1	move.b	(a1)+,(a0)+
	bne.b	.cp1
	move.b	ActiveCopper(b),d0
	add.b	#'0',d0
	move.b	d0,-1(a0)
.cp2	move.b	(a1)+,(a0)+
	bne.b	.cp2
	lea	TextLineBuffer(b),a0
	pea	NoPrompt(pc)
	bra.w	Print

;----------------------------------------------------
;- Name	: CopperOffset
;- Description	: Show/change entry copper-search offset
;- SYNTAX	: copoffset <New offset>
;----------------------------------------------------
;- 071193	First version.
;----------------------------------------------------
CopperOffset	bsr.w	GetValueCall
	cmp.w	#EV_NOVALUE,d1
	beq.b	.display
	tst.w	d1
	bne.w	PrintError
	moveq	#EV_ILLEGALCOPOFFSET,d1
	tst.l	d0
	bmi.w	PrintError
	cmp.l	MaxChip(b),d0
	bgt.w	PrintError
	btst	#0,d0
	bne.w	PrintError
	move.l	d0,CopSearchOffset(b)
.display	lea	CopOffsetText(b),a1
	lea	TextLineBuffer(b),a0
.cp1	move.b	(a1)+,(a0)+
	bne.b	.cp1
	subq.w	#1,a0
	move.l	CopSearchOffset(b),d0
	bsr.w	PrintHexL
	clr.b	(a0)
	lea	TextLineBuffer(b),a0
	pea	NoPrompt(pc)
	bra.w	Print

;----------------------------------------------------
;- Name	: Handle NMI On/Off
;- Description	: Set/release NMI vector
;- SYNTAX	: NMIOn/NMIOff
;----------------------------------------------------
;- 051193	First version.
;----------------------------------------------------
SetNMI	not.b	NMIPatched(b)
	beq.b	.freeNMI
	move.l	VectorBuffer+$7c,OrgNMIVector(b);get original vector
	move.l	#GhostRider,VectorBuffer+$7c
	bra.b	.done	

.freeNMI	move.l	OrgNMIVector(b),VectorBuffer+$7c;set old vector

.done	lea	NMIPatchedText(b),a1
	lea	NMIPatched(b),a2
	bra.w	PrintState

;----------------------------------------------------
;- Name	: SetExitCoppers
;- Description	: show/change copperptrs stored at exit
;- SYNTAX	: CP <[0/1] [address]> (address=-1 to skip)
;----------------------------------------------------
;- 051193	First version.
;----------------------------------------------------
SetExitCoppers	bsr.w	GetValueCall
	cmp.w	#EV_NOVALUE,d1
	beq.b	.display
	tst.l	d1
	bne.w	PrintError

	moveq	#EV_ILLEGALCOPPER,d1
	moveq	#0,d7
	tst.l	d0
	beq.b	.ok
	cmp.l	#1,d0
	bne.w	PrintError
	moveq	#4,d7	;offset
.ok	bsr.w	GetValueSkipS
	cmp.l	#-1,d0	;OK, disables function
	beq.b	.addressOK
	moveq	#EV_NOTCHIPADDRESS,d1
	tst.l	d0
	bmi.w	PrintError
	cmp.l	MaxChip(b),d0	;else check CHIPMEM
	bgt.w	PrintError
	bclr	#0,d0	;and clear ODD-bit
.addressOK	lea	ExitCopper0(b),a0
	move.l	d0,(a0,d7.w)

.display	moveq	#1,d7
	moveq	#'0',d6
	lea	ExitCopper0(b),a2
.DisplayLoop	lea	TextLineBuffer(b),a0
	lea	CopperText(b),a1
.cp1	move.b	(a1)+,(a0)+
	bne.b	.cp1
	move.b	d6,-1(a0)	;set copper-number
	move.b	#' ',(a0)+
	move.l	(a2)+,d0	;get address
	bpl.b	.printaddress
.cp2	move.b	(a1)+,(a0)+	;print 'not defined'
	bne.b	.cp2
	subq.w	#1,a0
	bra.b	.textready

.printaddress	bsr.w	PrintHexS
.textready	clr.b	(a0)
	lea	TextLineBuffer(b),a0
	grcall	Print
	addq.w	#1,d6
	dbra	d7,.DisplayLoop
	bra.w	NoPrompt

;----------------------------------------------------
;- Name	: ChangeSelectedDrive
;- Description	: Change active drive
;- SYNTAX	: cd <0/1/2/3>
;----------------------------------------------------
;- 051193	First version.
;----------------------------------------------------
ChangeCurrentDirectory
	moveq	#0,d0
	bsr.w	ParsePath
	bsr.w	BackupDiskCDs	;this will activate the new settings

	lea	DumpBuffer(b),a3;temp string storage
	moveq	#0,d0
	move.b	SelectedDrive(b),d0
	add.w	d0,d0
	lea	CDTable(b),a0
	move.w	(a0,d0.w),d0

.pathloop	grcall	GetBlock

	lea	BlockBuffer,a2
	tst.l	FH_PARENTDIR(a2)
	bne.b	.UserDir
	move.b	#':',(a3)+
	moveq	#'0',d0
	add.b	SelectedDrive(b),d0
	move.b	d0,(a3)+
	move.b	#'F',(a3)+
	move.b	#'D',(a3)+
	bra.b	.LevelDone

.UserDir	move.b	#'/',(a3)+	;user dir
	lea	FH_NAME(a2),a1
	moveq	#0,d0
	move.b	(a1),d0
	lea	1(a1,d0.w),a1
.CopyName	move.b	-(a1),(a3)+
	subq.w	#1,d0
	bne.b	.CopyName

.LevelDone	move.l	FH_PARENTDIR(a2),d0
	bne.b	.pathloop

	lea	DumpBuffer(b),a2
	cmp.b	#':',(a2)+
	beq.b	.SkipFirst
	addq.w	#1,a2
.SkipFirst	move.l	a3,d0
	sub.l	a2,d0

	lea	TextLineBuffer(b),a0
	move.b	#10,(a0)+
.FlipStringLoop	move.b	-(a3),(a0)+
	dbra	d0,.FlipStringLoop

	move.b	#pc_CLRRest,(a0)+
	clr.b	(a0)

	grcall	MotorOff

	pea	NoPrompt(pc)
	lea	TextLineBuffer(b),a0
	bra.w	Print

;---- Get <DFx:>[Name] parsed
;-- INPUT:	a0 -	input line
;-- OUTPUT:	a0 -	end of name (input)
;--	a2 -	Name
;----
;- DFx, if specified, will be activated.
;- TextLineBuffer is used to hold the name!
;----
ParseDFxName	lea	TextLineBuffer(b),a1;make sure line is 0-terminated

.findpath	move.b	(a0)+,d0
	beq.b	.nopath
	cmp.b	#' ',d0
	beq.b	.findpath

	subq.w	#1,a0

	move.b	(a0)+,d4
	cmp.b	#'"',d4
	beq.b	.endmarker
	cmp.b	#"'",d4
	beq.b	.endmarker
	moveq	#' ',d4	;set endmarker = space
	subq.w	#1,a0
.endmarker	move.b	(a0)+,d0
	beq.b	.stringcopied
	cmp.b	d4,d0
	beq.b	.stringcopied
	move.b	d0,(a1)+
	bra.b	.endmarker

.stringcopied	clr.b	(a1)+
	addq.w	#1,a0
.nopath	subq.w	#1,a0
	clr.b	(a1)	;two endmarkers!
	lea	TextLineBuffer(b),a2

	moveq	#0,d3	;signal DFx usage
	moveq	#0,d0	;check if drive-change is wanted
	move.b	(a2),d0
	beq.b	.NoNewDrive
	asl.w	#8,d0
	move.b	1(a2),d0
	swap	d0
	move.b	3(a2),d0
	or.l	#$20202020,d0
	cmp.l	#'df :',d0
	bne.b	.NoNewDrive
	moveq	#EV_NOTAVALIDDRIVENO,d1
	move.b	2(a2),d0
	sub.b	#'0',d0
	bmi.w	PrintError
	cmp.b	#3,d0
	bgt.w	PrintError
	move.b	d0,SelectedDrive(b)
	addq.w	#4,a2
	moveq	#1,d3

.NoNewDrive	rts

;---- Set current path to what is specified in the textstring
;- INPUT:	d0 -	pp_DIR/pp_FILE/pp_NEWFILE
;-	a0 -	<path>file string
;- OUTPUT:	d0 -	Current disk block
;-	d1 -	Parent disk block
;-	d2 -	If pp_NEWFILE: 0->NO FILE, -1->FILE EXIST
;----
ParsePathWrite	moveq	#-1,d7	;signal write
	bra.b	ParsePath\.entry

ParsePath	moveq	#0,d7
.entry
	move.w	d0,d6
	lea	BlockBuffer,a3

	bsr.w	ParseDFxName
	Push	a0

	tst.w	d7
	bmi.b	.Write
	grcall	InitDriveDOS
	bra.b	.Inited

.Write	grcall	InitDriveDOSW
.Inited
	moveq	#0,d0
	move.b	SelectedDrive(b),d0
	add.w	d0,d0
	lea	CDTable(b),a1
	move.w	(a1,d0.w),d7	;start from previous CD

	move.b	(a2),d0
	beq.w	.Exit	;check simple drive shift ("cd DFx: ")

	tst.w	d3	;start from root if DFx:path
	bne.b	.goRoot
	cmp.b	#'/',d0	;start from root
	bne.b	.CDScanLoop
	addq.w	#1,a2
.goRoot	move.w	ROOTBlock(b),d7

.CDScanLoop	move.w	d7,d0
	grcall	GetBlock

	tst.w	FH_SECTYPE(a3)
	bpl.b	.Directory

	moveq	#EV_NOTADIRECTORY,d1
	tst.w	d6
	beq.b	.Error
	tst.b	(a2)
	bne.b	.Error
	cmp.w	#pp_NEWFILE,d6	;NEWFILE wanted?
	bne.w	.ExitFile	;if not, clean exit
	moveq	#-1,d6	;signal existens of file
	bra.w	.ExitFile

.Directory	move.b	(a2)+,d0
	beq.b	.Exit
	cmp.b	#'.',d0	;check . and ..
	bne.b	.CurrentParent
	move.b	(a2),d1
	beq.b	.CurrentDir
	cmp.b	#'/',d1	;"./" & ". " -> current
	bne.b	.CheckParentDir
.CurrentDir	addq.w	#1,a2
	bra.b	.CDScanLoop

.CheckParentDir	cmp.b	#'.',d1	;"../" -> parent
	bne.b	.CurrentParent
	move.b	1(a2),d1
	beq.b	.ParentDir
	cmp.b	#'/',d1
	bne.b	.CurrentParent
.ParentDir	addq.w	#2,a2
	move.l	FH_PARENTDIR(a3),d7
	bne.b	.CDScanLoop
	moveq	#EV_NOPARENTDIR,d1
	bra.b	.Error

.CurrentParent	lea	FileNameBuffer(b),a1;Create BCPL string with name
	clr.b	(a1)+
.CopySingleName	move.b	d0,(a1)+
	addq.b	#1,FileNameBuffer(b)
	move.b	(a2)+,d0
	beq.b	.NameExtracted
	cmp.b	#'/',d0
	bne.b	.CopySingleName

.NameExtracted	clr.b	(a1)

	move.w	d7,d0
	bsr.w	FindFileHeaderInBlock
	beq.b	.Found

	moveq	#EV_FILENOTFOUND,d1
	cmp.w	#pp_NEWFILE,d6	;If NOT doing NEWFILE
	bne.b	.Error	;->fail
	move.w	d7,d5
	moveq	#0,d6	;Signal NEWFILE does not exist
	tst.b	(a2)	;else check this is last name in chain
	beq.b	.ExitFile

.Error	bra.w	PrintErrorMO

.Found	move.w	d7,d5	;save parent
	move.w	d0,d7
	bra.w	.CDScanLoop

.Exit	moveq	#EV_NOTAFILE,d1
	tst.w	d6	;fail if FILE wanted
	bne.b	.Error

.ExitFile	moveq	#0,d0
	move.b	SelectedDrive(b),d0
	add.w	d0,d0
	lea	CDTable(b),a1
	move.w	d7,(a1,d0.w)	;set new CD ptr
	move.w	d7,CurrentDir(b);this should NOT be done with pp_FILEx!

	move.w	d6,d2	;return state of NEWFILE
			;0=NOT EXIST, -1=EXITST (call delete)
	moveq	#0,d0
	moveq	#0,d1
	move.w	d5,d1	;return previous diskblock in chain (parent)
	move.w	d7,d0
	Pull	a0
	rts

GetCurrentDir	moveq	#0,d0
	move.b	SelectedDrive(b),d0
	add.w	d0,d0
	lea	CDTable(b),a1
	move.w	(a1,d0.w),d0	;get actual CD
	move.w	d0,CurrentDir(b)
	rts

;---- Copy CD-blocks and SD to buffer
BackupDiskCDs	Push	a0/a1
	lea	CDTable(b),a0
	lea	CDTableBackup(b),a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.b	SelectedDrive(b),SelectedDriveB(b)
	Pull	a0/a1
	rts

;---- Copy CD-blocks and SD to buffer
RestoreDiskCDs	Push	a0/a1
	lea	CDTable(b),a1
	lea	CDTableBackup(b),a0
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.b	SelectedDriveB(b),SelectedDrive(b)
	Pull	a0/a1
	rts

;----------------------------------------------------
;- Name	: ChangeBPReg
;- Description	: Show/Change TRAP# used for BPs.
;- SYNTAX	: BReg <TRAP#>
;----------------------------------------------------
;- 011193	First version.
;----------------------------------------------------
ChangeBPReg	bsr.w	GetValueCall
	cmp.w	#EV_NOVALUE,d1
	beq.b	.DisplayBPReg
	tst.w	d1
	bne.w	PrintError
	moveq	#EV_INVALIDTRAPNO,d1
	tst.l	d0
	bmi.w	PrintError
	cmp.l	#15,d0
	bgt.w	PrintError

	moveq	#0,d1
	move.b	BPRegister(b),d1;also change vector
	asl.w	#2,d1
	lea	VectorBuffer+$80,a1
	move.l	OrgBPVector(b),(a1,d1.w);restore BP vector

	move.b	d0,BPRegister(b)
	asl.w	#2,d0
	move.l	(a1,d0.w),d1
	move.l	d1,OrgBPVector(b);first get original
	move.l	d1,BPContinue+2	;(also set for continuing prg-trap)

	move.w	#$4E40,d1	;last nibble contain trapnumber
	or.b	BPRegister(b),d1;calc trap command

	lea	BreakPointTable,a0
	moveq	#0,d0
	move.b	BreakPointCount(b),d0
	subq.w	#1,d0
	bmi.b	.emptytable
.correctBPs	move.l	(a0),a1
	move.w	d1,(a1)
	addq.l	#6,a0
	dbra	d0,.correctBPs

.emptytable
.DisplayBPReg	lea	BPRegNumberText(b),a1
	lea	TextLineBuffer(b),a0
.cp1	move.b	(a1)+,(a0)+
	bne.b	.cp1
	subq.w	#1,a0
	moveq	#0,d0
	move.b	BPRegister(b),d0
	bsr.w	PrintDec
.cp2	move.b	(a1)+,(a0)+
	bne.b	.cp2
	lea	TextLineBuffer(b),a0
	pea	NoPrompt(pc)
	bra.w	Print

;----------------------------------------------------
;- Name	: ListBreakPoints
;- Description	: Dump list of set BreakPoints
;- SYNTAX	: bl
;----------------------------------------------------
;- 011193	First version.
;----------------------------------------------------
ListBreakPoints	moveq	#0,d7
	moveq	#EV_BPBUFFEREMPTY,d1
	move.b	BreakPointCount(b),d7
	beq.w	PrintError
	subq.w	#1,d7
	lea	BreakPointTable,a3
.DumpLoop	lea	TextLineBuffer(b),a0
	lea	BreakPointSetTxt(b),a1
.cp1	move.b	(a1)+,(a0)+
	bne.b	.cp1
	subq.w	#1,a0
	move.l	(a3)+,d0
	tst.w	(a3)+	;skip data
	bsr.w	PrintHexS
	clr.b	(a0)
	lea	TextLineBuffer(b),a0
	grcall	Print
	dbra	d7,.DumpLoop
	bra.w	NoPrompt

;----------------------------------------------------
;- Name	: SetBreakPoint
;- Description	: Set breakpoint to address if not already set/BP-tab not full
;- SYNTAX	: bs <address>
;----------------------------------------------------
;- 311093	First version. Simple Trap #1 BP
;- 011193	Support all traps, auto-set vector at first call
;----------------------------------------------------
SetBreakPoint	bsr.w	GetValueSkip
	move.l	d0,a0

	bsr.b	SetBPFunction

	moveq	#EV_COULDNOTSETBP,d1
	tst.b	d0
	beq.b	.BPSet
	bmi.b	.fail

	moveq	#EV_BPBUFFERFULL,d1
	cmp.b	#1,d0
	beq.b	.fail
	moveq	#EV_BPALREADYSET,d1
.fail	bra.w	PrintError
	
.BPSet	move.l	a0,d0	;new BP address

	lea	BreakPointSetTxt(b),a1
	lea	TextLineBuffer(b),a0
.cp1	move.b	(a1)+,(a0)+
	bne.b	.cp1
	subq.w	#1,a0
	bsr.w	PrintHexS
	clr.b	(a0)

	bsr.w	FlushCache

	lea	TextLineBuffer(b),a0
	pea	NoPrompt(pc)
	bra.w	Print

;---- Actual set-breakpoint routine. ID'able for extern library usage.
;- Input:	a0 -	Address
;-	a1 -	VBR
;- Output:	d0 -	0=OK/error
;----
;- Disable IRQ before call. Clear cache at return.
;----
;sbp_full=	1
;sbp_isset=	2
;sbp_fail=	-1

SetBPFunction	Push	d1-d2/d7/a0-a3
	moveq	#-1,d7	;signal GR call
	bra.b	SetBreakPointFunktionE

	dc.b	'SBP!'	;ID marker
SetBreakPointFunktion
	Push	d1-d2/d7/a0-a3
	moveq	#0,d7	;signal entry from outside GR
SetBreakPointFunktionE
	lea	B,b

	moveq	#gr_sbp_fail,d0	;fail if odd address
	move.l	a0,d1
	btst	#0,d1
	bne.b	.exit

	moveq	#gr_sbp_full,d0	;full-error
	moveq	#0,d1
	move.b	BreakPointCount(b),d1
	cmp.b	#MaxBreakPoints,d1;error if table is full
	beq.b	.exit

	lea	BreakPointTable,a3;check if address is in table
	move.l	a3,a2
	move.w	d1,d2
	subq.w	#1,d2
	bmi.b	.none
	moveq	#gr_sbp_isset,d0
.checkforprev	cmp.l	(a2)+,a0
	beq.b	.exit
	addq.w	#2,a2	;skip data
	dbra	d2,.checkforprev

.none	mulu	#6,d1
	move.w	(a0),4(a3,d1.w)	;and original data

	move.w	#$4E40,d2	;last nibble contain trapnumber
	or.b	BPRegister(b),d2;calc trap command
	move.w	d2,(a0)	;set Trap

	moveq	#gr_sbp_fail,d0
	cmp.w	(a0),d2	;was it stored?
	bne.b	.exit	;else fail

	move.l	a0,(a3,d1.w)	;if OK, store address
	addq.b	#1,BreakPointCount(b)
	tst.w	d1
	bne.b	.FirstBP	;if first breakpoint
	moveq	#0,d0
	move.b	BPRegister(b),d0;also change vector
	asl.w	#2,d0
	add.w	#$80,d0	;TRAP base
	tst.w	d7	;system/GR call?
	beq.b	.syscall
	lea	VectorBuffer,a1;if GR call change in vector buffer

.syscall	move.l	(a1,d0.w),d1	;get old vector
	move.l	d1,OrgBPVector(b);and save
	move.l	d1,BPContinue+2	;(also set for continuing prg-trap)
	move.l	#BreakPointEntry,(a1,d0.w);then set GR BP-handler
.FirstBP
	moveq	#0,d0
.exit	Pull	d1-d2/d7/a0-a3
	rts

;----------------------------------------------------
;- Name	: ZapBreakPoint
;- Description	: Zap breakpoint to address if set
;- SYNTAX	: bz <address>
;----------------------------------------------------
;- 011193	
;----------------------------------------------------
ZapBreakPoint	moveq	#EV_BPBUFFEREMPTY,d1;check for empty table
	moveq	#0,d7
	move.b	BreakPointCount(b),d7
	beq.w	PrintError

	bsr.w	GetValueSkip
	move.l	d0,a0

	bsr.b	ClrBPFunction

	moveq	#EV_NOBREAKPOINT,d1
	tst.b	d0
	bne.w	PrintError

	bsr.w	FlushCache

	lea	BPZappedText(b),a0
	grcall	Print
	bra.w	ListBreakPoints

;---- Zap all breakpoints
ZapAllBreakPoints
	lea	-1.w,a0
	bsr.b	ClrBPFunction
	bsr.w	FlushCache
	bra.w	ListBreakPoints

;---- Actual clr-breakpoint routine. ID'able for extern library usage.
;- Input:	a0 -	Address / -1 for all
;-	a1 -	VBR (only extern calls)
;- Output:	d0 -	0=OK/error
;-	d1 -	# of remaining BPs if OK
;----
;- Disable IRQ before call. Clear cache at return.
;----
;cbp_notset=	-1
ClrBPFunction	Push	d5-d7/a0-a3
	moveq	#-1,d7	;signal GR call
	bra.b	ClrBreakPointFunktionE

	dc.b	'CBP!'	;ID marker
ClrBreakPointFunktion
	Push	d5-d7/a0-a3
	moveq	#0,d7	;signal entry from outside GR
ClrBreakPointFunktionE
	lea	B,b

	moveq	#gr_cbp_notset,d0

	moveq	#0,d5
	move.b	BreakPointCount(b),d5
	beq.b	.exit

	moveq	#-1,d0
	cmp.l	d0,a0
	beq.b	.ZapAll

	lea	BreakPointTable,a2
	move.l	a2,a3
	subq.w	#1,d5
	move.w	d5,d6
.checkadd	cmp.l	(a3),a0
	beq.b	.RemoveBP
	addq.w	#6,a3
	dbra	d6,.checkadd
	bra.b	.exit

.RemoveBP	move.w	4(a3),(a0)	;restore original data

	subq.w	#1,d6
	bmi.b	.nomove
.moveloop	move.l	6(a3),(a3)+	;move the remaining breakpoints up
	move.w	6(a3),(a3)+
	dbra	d6,.moveloop

.nomove	moveq	#0,d0
	subq.b	#1,BreakPointCount(b)
	bne.b	.exit	;free if last BP zapped

;---- Called directly by 'bzall'
.ZapAll	moveq	#0,d0
	move.b	BPRegister(b),d0;also change vector
	asl.w	#2,d0
	add.w	#$80,d0	;TRAP base
	tst.w	d7
	beq.b	.syscall
	lea	VectorBuffer,a1

.syscall	move.l	OrgBPVector(b),(a1,d0.w);restore BP vector
	subq.w	#1,d5
	bmi.b	.norestore
	lea	BreakPointTable,a0;restore org data
.restoreloop	move.l	(a0)+,a1
	move.w	(a0)+,(a1)
	dbra	d5,.restoreloop

.norestore	clr.b	BreakPointCount(b)
	move.l	#BPFoolProof,BPContinue+2;just make sure nothing blows up
	moveq	#0,d0

.exit	moveq	#0,d1
	move.b	BreakPointCount(b),d1

	Pull	d5-d7/a0-a3
	rts

;----------------------------------------------------
;- Name	: EnableTrace
;- Description	: Enable internal command tracer
;- SYNTAX	: TraceOn
;----------------------------------------------------
;- 311093	First version. Checks StackWall
;----------------------------------------------------
EnableTrace	moveq	#16,d0
	move.l	d0,IntTraceCounter(b)
	move.l	d0,IntTraceCount(b)

	bsr.w	GetVBR
	move.l	#TraceHandler,$24(a0)
	ori.w	#$8000,sr
	bra.w	NoPrompt

;----------------------------------------------------
;- Name	: TraceHandler
;- Description	: Performs trace-operation when active.
;----------------------------------------------------
;- 311093	First version. Checks StackWall
;----------------------------------------------------
TraceHandler	subq.l	#1,IntTraceCounter
	beq.b	.TraceCheck
	rte

.TraceCheck	Push	all
	lea	B,b
	lea	$dff000,h
	move.l	IntTraceCount(b),IntTraceCounter(b)
	move.l	15*4+2(a7),d0	;get PC
	lea	mon(pc),a0
	sub.l	a0,d0
	lea	TraceTxtBuffer(pc),a1
	lea	2(a1),a0
	moveq	#4,d1
	bsr.w	PrintHex
	move.l	a1,a0
	moveq	#61,d0
	bsr	PrintHeaderD
	Pull	all

	tst.l	StackWall
	bne.b	.HandleException;Get'im!
	rte

.HandleException
	bra.w	Exception8

TraceTxtBuffer	dc.b	'O:xxxxx',0

;----------------------------------------------------
;- Name	: DisableTrace
;- Description	: Disable internal command tracer
;- SYNTAX	: TraceOn
;----------------------------------------------------
;- 311093	First version. Checks StackWall
;----------------------------------------------------
DisableTrace	andi.w	#$7fff,sr
	bsr.w	GetVBR
	move.l	Exception8,$24(a0)
	bra.w	NoPrompt

;----------------------------------------------------
;- Name	: HuntBranch
;- Description	: Search for branch-access to address (only 8/16 bit)
;- SYNTAX	: hb [addr]
;----------------------------------------------------
;- 191093	First version. Checks most opcodes, but sum like CMP2 remain
;-	(get list of non-working from users :-)
;----------------------------------------------------
HuntPCRelative	st.b	ResumeCommand(b);clear resume
	bsr.w	GetValueSkip

	move.l	d0,DestAddress(b)

	move.l	d0,a0
	lea	-$8000(a0),a1
	move.l	a1,StartAddress(b)
	lea	$7ffe(a0),a1
	move.l	a1,EndAddress(b)

HuntPCResume	move.l	StartAddress(b),d7
	move.l	EndAddress(b),d6
	move.l	d6,d0
	sub.l	d7,d0
	beq.b	.error
	bpl.b	.ok
.error	moveq	#EV_ILLEGALAREA,d1
	bra.w	PrintError

.ok	lsr.l	#1,d0
	bsr.w	CalculateBar

	lea	ScanningText(b),a1
	lea	TextLineBuffer(b),a0
.copy1	move.b	(a1)+,(a0)+
	bne.b	.copy1
	subq.w	#1,a0
	move.l	d7,d0
	bsr.w	PrintHexS
	move.b	#'-',(a0)+
	move.l	d6,d0
	bsr.w	PrintHexS
.copy2	move.b	(a1)+,(a0)+
	bne.b	.copy2
	subq.w	#2,a0

	lea	BranchText(b),a1
.copy3	move.b	(a1)+,(a0)+
	bne.b	.copy3
	subq.w	#1,a0
	move.l	DestAddress(b),d0
	bsr.w	PrintHexS

	move.b	#pc_CLRRest,(a0)+
	tst.l	UpdateTime(b)
	beq.b	.noLF
	move.b	#$a,(a0)+
.noLF	clr.b	(a0)
	lea	TextLineBuffer(b),a0
	grcall	Print

	move.l	d7,a0

	clr.b	AddressCount(b)	;set # of addresses in buffer to 0
	st.b	ABPointer(b)
	clr.b	FindFound(b)

	lea	AddressBuffer1(b),a4
	move.w	#MaxAddresses,LoopCounter(b)
	move.l	UpdateTime(b),d7;init progress timer

.HuntBranchLoop	move.w	(a0)+,d0
	move.w	d0,d1
	and.w	#%111111,d1
	cmp.w	#%111010,d1
	bne.b	.16bitoffset
	move.w	(a0),d1
	bra.w	.wordoffset

.16bitoffset	cmp.w	#%111011,d1
	bne.w	.trynext
	move.w	(a0),d1
	btst	#8,d1
	bne.b	.check020
	ext.w	d1
	bra.w	.wordoffset

.check020	bra.w	.trynext	;implement 020+ later

.wordoffset	move.w	d0,d3
	move.w	d0,d2
	and.w	#$f000,d2
	beq.w	.trynext	;bitman/movep/imm not allowed
	rol.w	#4,d2
	cmp.w	#%0100,d2
	blt.b	.checkaddress
	bne.b	.checkingdiv
	move.w	d3,d4
	and.w	#%000000111000000,d4
	cmp.w	#%000000111000000,d4;lea
	beq.b	.checkaddress
	and.w	#%1111111111000000,d3
	cmp.w	#%0100100001000000,d3;pea
	beq.b	.checkaddress
	move.w	2(a0),d1	;get offset past extra word
	cmp.w	#%0100110001000000,d3;divu/s.l
	beq.b	.checkaddress
	cmp.w	#%0100110000000000,d3;mulu.l
	beq.b	.checkaddress

.checkingdiv	cmp.w	#%1000,d2
	blt.b	.trynext	;misc/xxq/bcc not allowed
	bne.b	.checkingor
	and.w	#%0000000111000000,d3
	cmp.w	#%0000000011000000,d3
	beq.b	.trynext
	and.w	#%0000000100000000,d3;or ok
	beq.b	.checkaddress
	bra.b	.trynext

.checkingor	cmp.w	#%1001,d2
	bne.b	.checkingsub
.checkingcmp	and.w	#%0000000111000000,d3
	cmp.w	#%0000000111000000,d3;suba.l ok
	beq.b	.checkaddress
	and.w	#%0000000100000000,d3;sub ea,dx ok
	beq.b	.checkaddress
	bra.b	.trynext

.checkingsub	cmp.w	#%1010,d2	;$Axxx
	beq.b	.trynext
	cmp.w	#%1101,d2
	blt.b	.checkingcmp	;+(and, or)
	bra.b	.trynext

.checkaddress	lea	(a0,d1.w),a1	;calculate effective address
	cmp.l	DestAddress(b),a1;is it the correct one?
	bne.b	.trynext

.AddToBuffer	move.l	a0,d2
	subq.l	#2,d2
	move.l	d2,(a4)+	;put address in buffer
	st.b	FindFound(b)	;mark found
	subq.w	#1,LoopCounter(b)
	bne.w	.HuntBranchLoop	;continue till buffer is full

.FullBuffer	Push	a0
	lea	AddBufFullTxt(b),a0
	bra.b	.dotheprint

.trynext
.ContinueScan	subq.l	#1,d7
	bne.b	.noprint

	tst.b	UserBreak(b)	;test for break
	bne.b	.Broken
	move.l	UpdateTime(b),d7
	beq.b	.noprint	;if 0 the function is disabled
	Push	d0-a4
	moveq	#'-',d0
	tst.b	FindFound(b)
	beq.b	.nothing
	moveq	#'+',d0
.nothing	clr.b	FindFound(b)
	bsr.w	PrintLetterR
	Pull	d0-a4

.noprint	cmp.l	d6,a0
	bne.w	.HuntBranchLoop
	cmp.w	#MaxAddresses,LoopCounter(b);any found?
	bne.w	.ScanComplete

.NoAddresses	lea	ScanCompletText(b),a0
	grcall	Print
	moveq	#EV_NOTFOUND,d1	;no!
	bra.w	PrintError

.Broken	addq.w	#4,a7	;skip caller address
	Push	a0
	lea	UserBreakText(b),a0
.dotheprint	grcall	Print
	Pull	a0
	move.l	a0,d0
	move.l	a0,StartAddress(b)
	move.b	#res_HuntPCRel,ResumeCommand(b)
	lea	TextLineBuffer(b),a0
	bsr.w	PrintHexL	;print last processed address to buf
	clr.b	(a0)
	lea	LastAddressText(b),a0
	grcall	Print
	lea	TextLineBuffer(b),a0
	grcall	Print	;print it!
	bra.b	.fixlast

.ScanComplete	lea	ScanCompletText(b),a0
	grcall	Print
	st.b	ResumeCommand(b);discontinue resuming

.fixlast	move.w	#MaxAddresses,d0
	sub.w	LoopCounter(b),d0
	move.b	d0,AddressCount(b)

	bra.w	DumpAddresses


;----------------------------------------------------
;- Name	: HuntBranch
;- Description	: Search for branch-access to address (only 8/16 bit)
;- SYNTAX	: hb [addr]
;----------------------------------------------------
;- 181093	First version
;----------------------------------------------------
HuntBranch	st.b	ResumeCommand(b);clear resume
	bsr.w	GetValueSkip

	move.l	d0,DestAddress(b)

	move.l	d0,a0
	lea	-$8000(a0),a1
	move.l	a1,StartAddress(b)
	lea	$7ffe(a0),a1
	move.l	a1,EndAddress(b)

HuntBranResume	move.l	StartAddress(b),d7
	move.l	EndAddress(b),d6
	move.l	d6,d0
	sub.l	d7,d0
	beq.b	.error
	bpl.b	.ok
.error	moveq	#EV_ILLEGALAREA,d1
	bra.w	PrintError

.ok	lsr.l	#1,d0
	bsr.w	CalculateBar

	lea	ScanningText(b),a1
	lea	TextLineBuffer(b),a0
.copy1	move.b	(a1)+,(a0)+
	bne.b	.copy1
	subq.w	#1,a0
	move.l	d7,d0
	bsr.w	PrintHexS
	move.b	#'-',(a0)+
	move.l	d6,d0
	bsr.w	PrintHexS
.copy2	move.b	(a1)+,(a0)+
	bne.b	.copy2
	subq.w	#2,a0

	lea	BranchText(b),a1
.copy3	move.b	(a1)+,(a0)+
	bne.b	.copy3
	subq.w	#1,a0
	move.l	DestAddress(b),d0
	bsr.w	PrintHexS

	move.b	#pc_CLRRest,(a0)+
	tst.l	UpdateTime(b)
	beq.b	.noLF
	move.b	#$a,(a0)+
.noLF	clr.b	(a0)
	lea	TextLineBuffer(b),a0
	grcall	Print

	move.l	d7,a0

	clr.b	AddressCount(b)	;set # of addresses in buffer to 0
	st.b	ABPointer(b)
	clr.b	FindFound(b)

	lea	AddressBuffer1(b),a4
	move.w	#MaxAddresses,LoopCounter(b)
	move.l	UpdateTime(b),d7;init progress timer

.HuntBranchLoop	move.w	(a0)+,d0
	btst	#0,d0	;must be aligned offset
	bne.b	.trydbcc
	move.w	d0,d1
	and.w	#$f000,d1	;mask off
	cmp.w	#$6000,d1	;match Bcc?
	bne.b	.trydbcc
	move.b	d0,d1	;get offset
	ext.w	d1
	bne.b	.wordoffset
.get16bit	move.w	(a0),d1	;get 16bit displacement
.wordoffset	lea	(a0,d1.w),a1	;calculate effective address
	cmp.l	DestAddress(b),a1;is it the correct one?
	bne.b	.trynext
.AddToBuffer	move.l	a0,d2
	subq.l	#2,d2
	move.l	d2,(a4)+	;put address in buffer
	st.b	FindFound(b)	;mark found
	subq.w	#1,LoopCounter(b)
	bne.b	.HuntBranchLoop	;continue till buffer is full

.FullBuffer	Push	a0
	lea	AddBufFullTxt(b),a0
	bra.b	.dotheprint

.trydbcc	move.w	d0,d1	;try to match DBcc
	and.w	#%1111000011111000,d1
	cmp.w	#%0101000011001000,d1
	beq.b	.get16bit

.trynext
.ContinueScan	subq.l	#1,d7
	bne.b	.noprint

	tst.b	UserBreak(b)	;test for break
	bne.b	.Broken
	move.l	UpdateTime(b),d7
	beq.b	.noprint	;if 0 the function is disabled
	Push	d0-a4
	moveq	#'-',d0
	tst.b	FindFound(b)
	beq.b	.nothing
	moveq	#'+',d0
.nothing	clr.b	FindFound(b)
	bsr.w	PrintLetterR
	Pull	d0-a4

.noprint	cmp.l	d6,a0
	bne.b	.HuntBranchLoop
	cmp.w	#MaxAddresses,LoopCounter(b);any found?
	bne.w	.ScanComplete

.NoAddresses	lea	ScanCompletText(b),a0
	grcall	Print
	moveq	#EV_NOTFOUND,d1	;no!
	bra.w	PrintError

.Broken	addq.w	#4,a7	;skip caller address
	Push	a0
	lea	UserBreakText(b),a0
.dotheprint	grcall	Print
	Pull	a0
	move.l	a0,d0
	move.l	a0,StartAddress(b)
	move.b	#res_HuntBranch,ResumeCommand(b)
	lea	TextLineBuffer(b),a0
	bsr.w	PrintHexL	;print last processed address to buf
	clr.b	(a0)
	lea	LastAddressText(b),a0
	grcall	Print
	lea	TextLineBuffer(b),a0
	grcall	Print	;print it!
	bra.b	.fixlast

.ScanComplete	lea	ScanCompletText(b),a0
	grcall	Print
	st.b	ResumeCommand(b);discontinue resuming

.fixlast	move.w	#MaxAddresses,d0
	sub.w	LoopCounter(b),d0
	move.b	d0,AddressCount(b)

	bra.w	DumpAddresses

;----------------------------------------------------
;- Name	: DePower
;- Description	: DeImplode packed data at address
;- SYNTAX	: Depack [data] [dataend] [dest]
;----------------------------------------------------
;- 181093	First version
;----------------------------------------------------
DePower	bsr.w	GetStartEnd
	move.l	d7,DepackStart(b)
	move.l	d6,DepackEnd(b)
	bsr.w	GetValueSkipS	;get dest pointer
	move.l	d0,DepackDest(b)

	moveq	#EV_MISSINGID,d1
	move.l	DepackStart(b),a0;check format
	cmp.l	#'PP20',(a0)
	bne.w	PrintError

	lea	TextLineBuffer(b),a0
	lea	DepackInfoText(b),a1
.copytxt	move.b	(a1)+,(a0)+
	bne.b	.copytxt
	subq.w	#1,a0

	move.l	DepackDest(b),d0
	bsr.w	PrintHexS
	move.b	#'-',(a0)+

	moveq #3,d6	;get length
	move.l	DepackEnd(b),a2
	move.l -(a2),d1
	lsr.l	#8,d1
	move.l	DepackDest(b),d0
	add.l	d1,d0
	bsr.w	PrintHexS
	move.b	#'?',(a0)+
	move.b	#pc_CLRRest,(a0)+
	clr.b	(a0)

	lea	TextLineBuffer(b),a0
	grcall	Print

.waitforkey	move.b	CurKey(b),d0	;check ok with user
	beq.b	.waitforkey
	or.b	#$20,d0
	cmp.b	#'y',d0
	beq.b	.oktodepack
	bra.w	NoPromptKillKey

.oktodepack	lea	DepackingText(b),a0
	grcall	Print

	Push	a5/a6
	move.l	DepackEnd(b),a0
	move.l	DepackDest(b),a3
	move.l	DepackStart(b),a5
	addq.w	#4,a5
	bsr.b	Decrunch
	Pull	a5/a6

	lea	DepackOKText(b),a0
;	bne.b	.ok	;looks like there is no errorchekcer
;	lea	DepackErrText(b),a0
.ok	grcall	Print
	bra.w	NoPromptKillKey

; a3 -> file, a0 -> longword after crunched, a5 -> ptr to eff., a6 -> decr.col
; destroys a0-a6 and d0-d7
Decrunch:	moveq #3,d6
	moveq #7,d7
	moveq #1,d5
	move.l a3,a2	; remember start of file
	move.l -(a0),d1	; get file length and empty bits
	tst.b d1
	beq.s NoEmptyBits
	bsr.s ReadBit	; this will always get the next long (D5 = 1)
	subq.b #1,d1
	lsr.l d1,d5	; get rid of empty bits
NoEmptyBits:
	lsr.l #8,d1
	add.l d1,a3	; a3 = endfile
LoopCheckCrunch:
	bsr.s ReadBit	; check if crunch or normal
	bcs.s CrunchedBytes
NormalBytes:
	moveq #0,d2
Read2BitsRow:
	moveq #1,d0
	bsr.s ReadD1
	add.w d1,d2
	cmp.w d6,d1
	beq.s Read2BitsRow
ReadNormalByte:
	moveq #7,d0
	bsr.s ReadD1
	move.b d1,-(a3)
	dbf d2,ReadNormalByte
	cmp.l a3,a2
	bcs.s CrunchedBytes
;	moveq	#0,d0
	rts
ReadBit:
	lsr.l #1,d5	; this will also set X if d5 becomes zero
	beq.s GetNextLong
	rts
GetNextLong:
	move.l -(a0),d5
	roxr.l #1,d5	; X-bit set by lsr above
	rts
ReadD1sub:
	subq.w #1,d0
ReadD1:
	moveq #0,d1
ReadBits:
	lsr.l #1,d5	; this will also set X if d5 becomes zero
	beq.s GetNext
RotX:
	roxl.l #1,d1
	dbf d0,ReadBits
	rts
GetNext:
	move.l -(a0),d5
	roxr.l #1,d5	; X-bit set by lsr above
	bra.s RotX

CrunchedBytes:	moveq #1,d0
	bsr.s ReadD1	; read code
	moveq #0,d0
	move.b (a5,d1.w),d0	; get number of bits of offset
	move.w d1,d2	; d2 = code = length-2
	cmp.w d6,d2	; if d2 = 3 check offset bit and read length
	bne.s ReadOffset
	bsr.s ReadBit	; read offset bit (long/short)
	bcs.s LongBlockOffset
	moveq #7,d0
LongBlockOffset:
	bsr.s ReadD1sub
	move.w d1,d3	; d3 = offset
Read3BitsRow:
	moveq #2,d0
	bsr.s ReadD1
	add.w d1,d2	; d2 = length-1
	cmp.w d7,d1	; cmp with #7
	beq.s Read3BitsRow
	bra.s DecrunchBlock
ReadOffset:
	bsr.s ReadD1sub	; read offset
	move.w d1,d3	; d3 = offset
DecrunchBlock:
	addq.w #1,d2
DecrunchBlockLoop:
	move.b 0(a3,d3.w),-(a3)
	dbf d2,DecrunchBlockLoop
EndOfLoop:
;	move.w a3,(a6)
	cmp.l a3,a2
	bcs LoopCheckCrunch
;	moveq	#0,d0
	rts


;----------------------------------------------------
;- Name	: DeImplode
;- Description	: DeImplode packed data at address
;- SYNTAX	: Deplode [data] <dest>
;----------------------------------------------------
;- 181093	First version
;----------------------------------------------------
DeImplode	bsr.w	GetValueSkip	;get data pointer
	move.l	d0,DepackStart(b)
	bsr.w	GetOptValue
	beq.b	.dest
	move.l	DepackStart(b),d0;if none, let dest=datastart
.dest	move.l	d0,DepackDest(b)

	moveq	#EV_MISSINGID,d1
	move.l	DepackStart(b),a0;check format
	cmp.l	#'IMP!',(a0)
	bne.w	PrintError

	move.l	4(a0),d7
	lea	TextLineBuffer(b),a0
	lea	DepackInfoText(b),a1
.copytxt	move.b	(a1)+,(a0)+
	bne.b	.copytxt
	subq.w	#1,a0

	move.l	DepackDest(b),d0
	bsr.w	PrintHexS
	move.b	#'-',(a0)+
	add.l	d7,d0
	bsr.w	PrintHexS
.copytxt2	move.b	(a1)+,(a0)+
	bne.b	.copytxt2

	lea	TextLineBuffer(b),a0
	grcall	Print

.waitforkey	move.b	CurKey(b),d0	;check ok with user
	beq.b	.waitforkey
	or.b	#$20,d0
	cmp.b	#'y',d0
	beq.b	.oktodepack
	bra.w	NoPromptKillKey

.oktodepack	lea	DepackingText(b),a0
	grcall	Print

	move.l	DepackStart(b),a0
	move.l	DepackDest(b),a4
	bsr.b	DeImplodeCall

	lea	DepackOKText(b),a0
	bne.b	.ok
	lea	DepackErrText(b),a0
.ok	grcall	Print
	bra.w	NoPromptKillKey


;----------------------------------------------------
;-- depacking to same area (load packed data to depack address)
;input:	a0	-	pointer to data
;output:	true - depack ok
;	false - depack fail
;----------------------------------------------------
DeImplodeCall
;	CMP.L	#$494D5021,(A0)
;	BNE.b	lbC0008D0
	MOVEM.L	D2-D5/A2-A4,-(SP)
;	LEA	len(PC),A4	;depacked len
;	MOVE.L	4(A0),(A4)
	MOVE.L	A0,A3
;	MOVE.L	A0,A4
	move.l	a4,d6	;endaddress
	TST.L	(A0)+
	ADD.L	(A0)+,A4
	ADD.L	(A0)+,A3
	MOVE.L	A3,A2
	MOVE.L	(A2)+,-(A0)
	MOVE.L	(A2)+,-(A0)
	MOVE.L	(A2)+,-(A0)
	MOVE.L	(A2)+,D2
	MOVE.W	(A2)+,D3
	BMI.b	lbC0008BE
	SUBQ.L	#1,A3
lbC0008BE	LEA	-$001C(SP),SP
	MOVE.L	SP,A1
	MOVEQ	#6,D0
lbC0008C6	MOVE.L	(A2)+,(A1)+
	DBRA	D0,lbC0008C6

	MOVE.L	SP,A1
	BRA.b	lbC0008D4

lbC0008D0	MOVEQ	#0,D0
	RTS

lbC0008D4	TST.L	D2
	BEQ.b	lbC0008DE
lbC0008D8	MOVE.B	-(A3),-(A4)
	SUBQ.L	#1,D2
	BNE.b	lbC0008D8
lbC0008DE	CMP.L	A4,d6	;reached end?
	BCS.b	lbC0008F6
	LEA	$001C(SP),SP
	MOVEQ	#-$01,D0
	CMP.L	A3,A0
	BEQ.b	lbC0008EE
	MOVEQ	#0,D0
lbC0008EE	MOVEM.L	(SP)+,D2-D5/A2-A4
	TST.L	D0
	RTS

lbC0008F6	ADD.B	D3,D3
	BNE.b	lbC0008FE
	MOVE.B	-(A3),D3
	ADDX.B	D3,D3
lbC0008FE	BCC.w	lbC000968
	ADD.B	D3,D3
	BNE.b	lbC000908
	MOVE.B	-(A3),D3
	ADDX.B	D3,D3
lbC000908	BCC.w	lbC000962
	ADD.B	D3,D3
	BNE.b	lbC000912
	MOVE.B	-(A3),D3
	ADDX.B	D3,D3
lbC000912	BCC.b	lbC00095C
	ADD.B	D3,D3
	BNE.b	lbC00091C
	MOVE.B	-(A3),D3
	ADDX.B	D3,D3
lbC00091C	BCC.b	lbC000956
	MOVEQ	#0,D4
	ADD.B	D3,D3
	BNE.b	lbC000928
	MOVE.B	-(A3),D3
	ADDX.B	D3,D3
lbC000928	BCC.b	lbC000932
	MOVE.B	-(A3),D4
	MOVEQ	#3,D0
	SUBQ.B	#1,D4
	BRA.b	lbC00096C

lbC000932	ADD.B	D3,D3
	BNE.b	lbC00093A
	MOVE.B	-(A3),D3
	ADDX.B	D3,D3
lbC00093A	ADDX.B	D4,D4
	ADD.B	D3,D3
	BNE.b	lbC000944
	MOVE.B	-(A3),D3
	ADDX.B	D3,D3
lbC000944	ADDX.B	D4,D4
	ADD.B	D3,D3
	BNE.b	lbC00094E
	MOVE.B	-(A3),D3
	ADDX.B	D3,D3
lbC00094E	ADDX.B	D4,D4
	ADDQ.B	#5,D4
	MOVEQ	#3,D0
	BRA.b	lbC00096C

lbC000956	MOVEQ	#4,D4
	MOVEQ	#3,D0
	BRA.b	lbC00096C

lbC00095C	MOVEQ	#3,D4
	MOVEQ	#2,D0
	BRA.b	lbC00096C

lbC000962	MOVEQ	#2,D4
	MOVEQ	#1,D0
	BRA.b	lbC00096C

lbC000968	MOVEQ	#1,D4
	MOVEQ	#0,D0
lbC00096C	MOVEQ	#0,D5
	MOVE.W	D0,D1
	ADD.B	D3,D3
	BNE.b	lbC000978
	MOVE.B	-(A3),D3
	ADDX.B	D3,D3
lbC000978	BCC.b	lbC000990
	ADD.B	D3,D3
	BNE.b	lbC000982
	MOVE.B	-(A3),D3
	ADDX.B	D3,D3
lbC000982	BCC.b	lbC00098C
	MOVE.B	lbB0009F0(PC,D0.W),D5
	ADDQ.B	#8,D0
	BRA.b	lbC000990

lbC00098C	MOVEQ	#2,D5
	ADDQ.B	#4,D0
lbC000990	MOVE.B	lbB0009F4(PC,D0.W),D0
lbC000994	ADD.B	D3,D3
	BNE.b	lbC00099C
	MOVE.B	-(A3),D3
	ADDX.B	D3,D3
lbC00099C	ADDX.W	D2,D2
	SUBQ.B	#1,D0
	BNE.b	lbC000994
	ADD.W	D5,D2
	MOVEQ	#0,D5
	MOVE.L	D5,A2
	MOVE.W	D1,D0
	ADD.B	D3,D3
	BNE.b	lbC0009B2
	MOVE.B	-(A3),D3
	ADDX.B	D3,D3
lbC0009B2	BCC.b	lbC0009CE
	ADD.W	D1,D1
	ADD.B	D3,D3
	BNE.b	lbC0009BE
	MOVE.B	-(A3),D3
	ADDX.B	D3,D3
lbC0009BE	BCC.b	lbC0009C8
	MOVE.W	8(A1,D1.W),A2
	ADDQ.B	#8,D0
	BRA.b	lbC0009CE

lbC0009C8	MOVE.W	0(A1,D1.W),A2
	ADDQ.B	#4,D0
lbC0009CE	MOVE.B	$0010(A1,D0.W),D0
lbC0009D2	ADD.B	D3,D3
	BNE.b	lbC0009DA
	MOVE.B	-(A3),D3
	ADDX.B	D3,D3
lbC0009DA	ADDX.L	D5,D5
	SUBQ.B	#1,D0
	BNE.b	lbC0009D2
	ADDQ.W	#1,A2
	ADD.L	D5,A2
	ADD.L	A4,A2
lbC0009E6	MOVE.B	-(A2),-(A4)
	DBRA	D4,lbC0009E6

	BRA.W	lbC0008D4

lbB0009F0	dc.b	6
	dc.b	10
	dc.b	10
	dc.b	$12
lbB0009F4	dc.b	1
	dc.b	1
	dc.b	1
	dc.b	1
	dc.b	2
	dc.b	3
	dc.b	3
	dc.b	4
	dc.b	4
	dc.b	5
	dc.b	7
	dc.b	14

;----------------------------------------------------
;- Name	: FillNOPs
;- Description	: Fill atrea with NOPs
;- SYNTAX	: Nop [beg][end]
;----------------------------------------------------
;- 181093	First version
;----------------------------------------------------
FillNOPs	st.b	ResumeCommand(b);clear resume
	bsr.w	GetStartEnd	;get start & end

	move.l	d7,StartAddress(b)
	move.l	d6,EndAddress(b)

	bclr	#0,d7	;kill bit 0
	bclr	#0,d6

	moveq	#EV_ILLEGALAREA,d1
	move.l	d6,d0
	sub.l	d7,d0
	beq.w	PrintError
	lsr.l	#1,d0	;doin' 2 bytes'atime

	bsr.w	CalculateBar

	lea	FillingText(b),a1
	lea	TextLineBuffer(b),a0
.copy1	move.b	(a1)+,(a0)+
	bne.b	.copy1
	subq.w	#1,a0
	move.l	d7,d0
	bsr.w	PrintHexS
	move.b	#'-',(a0)+
	move.l	d6,d0
	bsr.w	PrintHexS
.copy2	move.b	(a1)+,(a0)+
	bne.b	.copy2
	subq.w	#1,a0
	move.b	#'N',(a0)+
	move.b	#'O',(a0)+
	move.b	#'P',(a0)+
	move.b	#'s',(a0)+
	move.b	#pc_CLRRest,(a0)+
	tst.l	UpdateTime(b)
	beq.b	.NoLF
	move.b	#$a,(a0)+
.NoLF	clr.b	(a0)
	lea	TextLineBuffer(b),a0
	grcall	Print

	move.l	d7,a0
	move.l	UpdateTime(b),d7;init progress timer

.FillInner	move.w	#$4e71,(a0)+
	subq.l	#1,d7
	bne.b	.noprint
	tst.b	UserBreak(b)	;test for break
	bne.w	MCUserBreak
	move.l	UpdateTime(b),d7
	beq.b	.noprint	;if 0 the function is disabled
	Push	d0-a4
	moveq	#'-',d0
	bsr.w	PrintLetterR
	Pull	d0-a4
.noprint	cmp.l	d6,a0
	bne.b	.FillInner

.FillCompleted	lea	FillCompletText(b),a0
	grcall	Print
	bra.w	NoPrompt

;----------------------------------------------------
;- Name	: WorkAreaControl
;- Description	: Display/change workarea
;- SYNTAX	: work <chip> <backup>
;----------------------------------------------------
;- 171093	Checks InChip,Overlap,VBR. Reprints screen.
;----------------------------------------------------

WorkAreaCtrl	bsr.w	GetValueCall
	beq.w	.evaladdress
	cmp.w	#EV_NOVALUE,d1
	bne.w	PrintError
	clr.b	LastCMDError(b)
.PrintWorkData
	lea	TextLineBuffer(b),a0
	lea	MemoryAreaText(b),a1
.cp1	move.b	(a1)+,(a0)+	;print GR memoryarea
	bne.b	.cp1
	subq.w	#1,a0
	lea	StartOfGR(pc),a2
	move.l	a2,d0
	bsr.w	PrintHexS
	move.b	#'-',(a0)+
	add.l	#GRMainHunkLen,d0
	bsr.w	PrintHexS

.cp2	move.b	(a1)+,(a0)+	;chipmem
	bne.b	.cp2
	subq.w	#1,a0

	move.l	ChipMem(b),d0
	bsr.w	PrintHexS
	move.b	#'-',(a0)+
	add.l	ChipSize(b),d0
	bsr.w	PrintHexS

.copytxt2	move.b	(a1)+,(a0)+
	bne.b	.copytxt2
	subq.w	#1,a0

	move.l	ChipBackup(b),d0
	bne.b	.BackupDefined
.cp3	move.b	(a1)+,(a0)+	;if no backup defined
	bne.b	.cp3
	bra.b	.TextDone

.BackupDefined	bsr.w	PrintHexS
	move.b	#'-',(a0)+
	add.l	ChipSize(b),d0
	bsr.w	PrintHexS
	clr.b	(a0)

.TextDone	lea	TextLineBuffer(b),a0
	grcall	Print

	bra.w	NoPrompt

.evaladdress	moveq	#EV_NOTCHIPADDRESS,d1
	and.l	#$fffffff8,d0	;align to 8 bytes!
	move.l	d0,d2	;d0=new lower
	add.l	ChipSize(b),d2	;d2=new upper

	cmp.l	MaxChip(b),d2	;check in chipmem
	bgt.w	PrintError

	bsr.w	.CheckOthers

	move.l	d0,-(a7)	;this is the new CHIP address

	bsr.w	GetOptValue
	bne.b	.NoNewBackup
	and.l	#$fffffff8,d0	;align to 8 bytes!
	move.l	d0,d2
	beq.b	.KillBackup

	add.l	ChipSize(b),d2

	bsr.w	.CheckOthers

	bra.b	.ok

.NoNewBackup	move.l	ChipBackup(b),d0;get old

.KillBackup
.ok	move.l	(a7)+,d1
;		d1	;this is the new CHIP address
;		d0	;this is the new BACKUP address

	move.w	dmaconr(h),d7	;kill DMA before transfer
	or.w	#$8000,d7
	move.w	#$7fff,dmacon(h)

	tst.l	ChipBackup(b)	;backup previously defined?
	beq.b	.NoChipBackup

	bsr	FreeWorkMem

	tst.l	d0	;still do backup?
	beq.b	.NoFutureBackup

	move.l	ChipBackup(b),a0
	move.l	d0,a1
	cmp.l	a0,a1	;no copy if equal
	beq.b	.NoCopy

	move.l	ChipSize(b),d2
	lsr.w	#2,d2
	subq.w	#1,d2
.CopyBackup	move.l	(a0)+,(a1)+
	dbra	d2,.CopyBackup

.NoCopy	pea	.WorkDone(pc)
	move.l	d0,ChipBackup(b)
.DoBackup	move.l	d1,ChipMem(b)

	bra	AllocateWorkMem


.NoFutureBackup	bsr.b	.DoBackup
	clr.l	ChipBackup(b)
	bra.b	.WorkDone



.NoChipBackup	tst.l	d0	;future backup?
	bne.b	.BuildBackup

	move.l	d1,a1
	pea	.WorkDone(pc)

.CopyChipData	move.l	ChipMem(b),a0	;simply copy chip mem data

	move.l	ChipSize(b),d2
	lsr.w	#2,d2
	subq.w	#1,d2
.CopyLoop	move.l	(a0)+,(a1)+
	dbra	d2,.CopyLoop
	move.l	d1,ChipMem(b)
	rts

.BuildBackup	move.l	d0,a1	;copy chip data to backup area
	bsr.b	.CopyChipData
	move.l	d0,ChipBackup(b)
	bsr	AllocateWorkMem

.WorkDone	bsr.w	StartScreen

	move.w	d7,dmacon(h)

	lea	HelpCharBack,a2
	move.l	CharPointer(b),a1
	move.w	#CharBSize/4-1,d0
.getbackup	move.l	(a1)+,(a2)+
	dbra	d0,.getbackup

	move.w	CurXPos(b),d7
	lea	HelpCharBack,a0
	bsr.w	PrintScreen

	bra.w	.PrintWorkData

;----- Check for VBR, GR and overlap
;-- Input	d0/d2	new area start/stop
;----
.CheckOthers	move.l	a0,-(a7)
	move.l	ChipMem(b),d3	;check overlap with old
	cmp.l	d3,d2
	bge.b	.OverlapOK
	add.l	ChipSize(b),d3
	moveq	#EV_AREASOVERLAP,d1
	cmp.l	d3,d0
	bge.w	PrintError

.OverlapOK	bsr.w	GetVBR	;check VBR conflict
	move.l	a0,d3
	cmp.l	d2,d3
	bpl.b	.CheckGR
	moveq	#EV_VBRCONFLICT,d1
	add.l	#$400,d3
	cmp.l	d3,d0
	bmi.w	PrintError

.CheckGR	move.l	#StartOfGR,d3
	cmp.l	d2,d3
	bpl.b	.memok
	moveq	#EV_GRCONFLICT,d1
	add.l	#GRMainHunkLen,d3
	cmp.l	d3,d0
	bmi.w	PrintError
	
.memok	move.l	(a7)+,a0
	rts

;----------------------------------------------------
;- Name	: InterruptInfo
;- Description	: Display/change interrupt vectors
;- SYNTAX	: irq<l> <[offset] [address]>
;----------------------------------------------------
;- 171093	First version
;- 230394	Now only handles the first 48 vectors
;----------------------------------------------------
InterruptCmd	move.w	#$c0,d5

.all	lea	VectorBuffer,a4
	bsr.w	GetValueCall
	beq.b	.changeirq
	cmp.w	#EV_NOVALUE,d1
	bne.w	PrintError
	bra.w	.displayvectors

.changeirq	moveq	#EV_NOTAVALIDVECTOR,d1
	tst.l	d0	;negative?
	bmi.w	PrintError
	cmp.l	#$c0-4,d0	;>$3fc?
	bgt.w	PrintError
	move.l	d0,d6
	and.w	#%11,d0
	bne.w	PrintError	;low 2bit =0?

	bsr.w	GetValueSkipS	;get new address
	move.l	d0,(a4,d6.w)	;and store in table

.displayvectors	bsr.w	MCursorDownDO	;line down
	bsr.w	MoreLineReset

	lea	TextLineBuffer(b),a0
	moveq	#9,d2	;step with 32bits
	move.b	pr_ShortAddress(b),d1
	beq.b	.long
	moveq	#7,d2
.long	moveq	#7,d3
	moveq	#6,d4
	moveq	#0,d0
.prepareloop	move.b	#pc_XPos,(a0)+
	move.b	d4,(a0)+
	move.b	#'$',(a0)+
	moveq	#2,d1
	bsr.w	PrintHex
	addq.w	#4,d0
	add.w	d2,d4
	dbra	d3,.prepareloop
	clr.b	(a0)
	lea	TextLineBuffer(b),a0
	moveq	#0,d7
	bra.b	.entry

.vectorloop	lea	TextLineBuffer(b),a0
	move.b	#'$',(a0)+
	move.w	d7,d0
	moveq	#2,d1
	grcall	PrintHex
	move.b	#':',(a0)+

	moveq	#7,d6
.printrow	move.b	#' ',(a0)+
	move.l	(a4)+,d0
	bsr.w	PrintHexS2
	dbra	d6,.printrow

	move.b	#pc_CLRRest,(a0)+
	clr.b	(a0)
	lea	TextLineBuffer(b),a0

	add.w	#8*4,d7
	cmp.w	d5,d7
	beq.b	.lastline

.entry	Push	d5/d7/a4
	bsr.w	MoreLine
	Pull	d5/d7/a4
	bra.b	.vectorloop

.lastline	grcall	Print

	bra.w	NoPromptKillKey

;----------------------------------------------------
;- Name	: KickMemInfo
;- Description	: Give information about kick memory allocations
;- SYNTAX	: kickmem
;----------------------------------------------------
;- 171093	First version
;----------------------------------------------------
KickMemInfo	move.l	$4.w,a4
	lea	KickMemPtr(a4),a4

	bsr.w	SumExecBase
	bne.w	PrintError

	bsr.w	MCursorDownDO	;line down
	bsr.w	MoreLineReset
	lea	KickMemInfoText(b),a0
	bsr.w	MoreLine

	moveq	#0,d7
.libinfoloop	move.l	(a4),a4	;this is not correct node-style
			;fuck SKick!
	move.l	a4,d0
	bne.b	.dolib
.broken	clr.b	CurKey(b)
	bra.w	NoPromptNoLF

.dolib	lea	TextLineBuffer(b),a0
	move.w	d7,d0
	moveq	#1,d1
	move.b	#'$',(a0)+	;mem number
	bsr.w	PrintHex
	move.b	#' ',(a0)+
	move.b	#' ',(a0)+

	move.l	LN_NAME(a4),a1	;name
	moveq	#22,d0
	moveq	#0,d1
.copyname	move.b	(a1)+,d1
	move.w	d1,d2
	sub.w	#' ',d2
	bmi.b	.notok
	move.b	d1,(a0)+
	dbra	d0,.copyname
.notok
	moveq	#0,d6
	move.w	ml_NumEntries(a4),d6
	beq.b	.skipit
	subq.w	#1,d6
	lea	ml_ME(a4),a3

.mementryloop	move.b	#pc_XPos,(a0)+
	move.b	#30,(a0)+

	move.l	(a3)+,d0	;address
	bsr.w	PrintHex82
	move.b	#' ',(a0)+
	move.b	#' ',(a0)+

	move.l	(a3)+,d0	;size
	bsr.w	PrintHex82

.skipit	clr.b	(a0)

	lea	TextLineBuffer(b),a0
	Push	d6/d7/a0/a3/a4
	bsr.w	MoreLine
	Pull	d6/d7/a0/a3/a4
	bne.w	.broken
	dbra	d6,.mementryloop;do all hunks in list

	addq.w	#1,d7	;inc process number
	bra.w	.libinfoloop

;----------------------------------------------------
;- Name	: ResidentInfo
;- Description	: Give information about residents in system
;- SYNTAX	: resi
;----------------------------------------------------
;- 171093	First version
;----------------------------------------------------
KickTagInfo	move.l	$4.w,a3
	move.l	KickTagPtr(a3),a3
	bra.b	ResidentInfoM

ResidentInfo	move.l	$4.w,a3
	move.l	ResModules(a3),a3

ResidentInfoM	bsr.w	SumExecBase
	bne.w	PrintError

	bsr.w	MCursorDownDO	;line down
	bsr.w	MoreLineReset
	lea	ResInfoText(b),a0
	bsr.w	MoreLine

	moveq	#0,d7

.ResInfoLoop	move.l	(a3)+,a4
	move.l	a4,d0
	bne.b	.dolib
.broken	clr.b	CurKey(b)
	bra.w	NoPromptNoLF

.dolib	lea	TextLineBuffer(b),a0
	move.w	d7,d0
	moveq	#1,d1
	move.b	#'$',(a0)+	;res number
	grcall	PrintHex
	move.b	#' ',(a0)+
	move.b	#' ',(a0)+

	move.l	rt_Name(a4),a1	;name
	moveq	#22,d0
	moveq	#0,d1
.copyname	move.b	(a1)+,d1
	move.w	d1,d2
	sub.w	#' ',d2
	bmi.b	.notok
	move.b	d1,(a0)+
	dbra	d0,.copyname
.notok	move.b	#pc_XPos,(a0)+
	move.b	#30,(a0)+

	move.l	a4,d0	;address
	bsr.w	PrintHex82
	move.b	#' ',(a0)+
	move.b	#' ',(a0)+

	move.l	rt_Init(a4),d0	;init
	bsr.w	PrintHex82
	move.b	#' ',(a0)+
	move.b	#' ',(a0)+

	moveq	#0,d0
	move.b	rt_Type(a4),d0
	asl.w	#3,d0
	lea	NodeTypesTxt(b),a1
	add.w	d0,a1
	moveq	#7,d0
.copytype	move.b	(a1)+,(a0)+
	dbra	d0,.copytype
	move.b	#pc_XPos,(a0)+
	move.l	a0,a1
	move.b	#66,(a0)+

	move.b	rt_Pri(a4),d0	;priority
	ext.w	d0
	ext.l	d0
	bsr.w	PrintDec
	move.l	a0,d0
	sub.l	a1,d0
	sub.b	d0,(a1)	;align
	move.b	#pc_XPos,(a0)+
	move.l	a0,a1
	move.b	#71,(a0)+

	moveq	#0,d0
	move.b	rt_Version(a4),d0;version
	bsr.w	PrintDec
	move.l	a0,d0
	sub.l	a1,d0
	sub.b	d0,(a1)	;align

	move.b	#pc_XPos,(a0)+
	move.b	#-3,(a0)+

	moveq	#0,d0
	move.b	rt_Flags(a4),d0	;flags
	moveq	#1,d1
	move.b	#'$',(a0)+
	bsr.w	PrintHex

	clr.b	(a0)

	Push	d6/d7/a3
	lea	TextLineBuffer(b),a0
	bsr.w	MoreLine
	Pull	d6/d7/a3
	bne.w	.broken

	addq.w	#1,d7	;inc process number
	bra.w	.ResInfoLoop

;----------------------------------------------------
;- Name	: PortInfo
;- Description	: Give information about ports in system
;- SYNTAX	: ports
;----------------------------------------------------
;- 171093	First version
;----------------------------------------------------
PortInfo	move.l	$4.w,a4
	lea	PortList(a4),a4

	bsr.w	SumExecBase
	bne.w	PrintError

	bsr.w	MCursorDownDO	;line down
	bsr.w	MoreLineReset
	lea	PortInfoText(b),a0
	bsr.w	MoreLine

	moveq	#0,d7
.libinfoloop	move.l	(a4),a4
	tst.l	(a4)
	bne.b	.dolib
.broken	clr.b	CurKey(b)
	bra.w	NoPromptNoLF

.dolib	lea	TextLineBuffer(b),a0
	move.w	d7,d0
	moveq	#1,d1
	move.b	#'$',(a0)+	;lib number
	bsr.w	PrintHex
	move.b	#' ',(a0)+
	move.b	#' ',(a0)+

	move.l	10(a4),a1	;name
	move.l	a1,d0
	beq.b	.NoName
	moveq	#22,d0
.copyname	move.b	(a1)+,(a0)+
	dbeq	d0,.copyname
	subq.w	#1,a0

.NoName	move.b	#pc_XPos,(a0)+
	move.b	#29,(a0)+

	move.l	mp_SigTask(a4),a1
	move.l	a1,d0
	beq.b	.NoTask
	move.l	10(a1),a1
	moveq	#22,d0
.copyname2	move.b	(a1)+,(a0)+
	dbeq	d0,.copyname2
	subq.w	#1,a0

.NoTask	move.b	#pc_XPos,(a0)+
	move.b	#53,(a0)+

	move.l	a4,d0	;address
	bsr.w	PrintHex82
	move.b	#' ',(a0)+
	move.b	#' ',(a0)+

	moveq	#0,d0
	move.b	mp_SigBit(a4),d0;sig bit
	moveq	#1,d1
	move.b	#'$',(a0)+
	bsr.w	PrintHex
	move.b	#pc_XPos,(a0)+
	move.b	#-5,(a0)+

	lea	MsgPortFlags,a1
	moveq	#0,d0
	move.b	mp_Flags(a4),d0
	asl.w	#3,d0
	add.w	d0,a1
	moveq	#7,d0
.copyflagtxt	move.b	(a1)+,(a0)+
	dbra	d0,.copyflagtxt	

	clr.b	(a0)

	Push	d7/a4
	lea	TextLineBuffer(b),a0
	bsr.w	MoreLine
	Pull	d7/a4
	bne.w	.broken

	addq.w	#1,d7	;inc process number
	bra.w	.libinfoloop

;----------------------------------------------------
;- Name	: Resource/Device/LibraryInfo
;- Description	: Give information about library in system
;- SYNTAX	: resc/devs/libs
;----------------------------------------------------
;- 161093	First version
;----------------------------------------------------
ResourceInfo	move.l	$4.w,a4
	lea	ResourceList(a4),a4
	bra.b	LibListMain

DeviceInfo	move.l	$4.w,a4
	lea	DeviceList(a4),a4
	bra.b	LibListMain

LibraryInfo	move.l	$4.w,a4
	lea	LibList(a4),a4

LibListMain	bsr.w	SumExecBase
	bne.w	PrintError

	bsr.w	MCursorDownDO	;line down
	bsr.w	MoreLineReset
	lea	LibsInfoText(b),a0
	bsr.w	MoreLine

	moveq	#0,d7
.libinfoloop	move.l	(a4),a4
	tst.l	(a4)
	bne.b	.dolib
.broken	clr.b	CurKey(b)
	bra.w	NoPromptNoLF

.dolib	lea	TextLineBuffer(b),a0
	move.w	d7,d0
	moveq	#1,d1
	move.b	#'$',(a0)+	;lib number
	bsr.w	PrintHex
	move.b	#' ',(a0)+
	move.b	#' ',(a0)+

	move.l	10(a4),a1	;name
	moveq	#23,d0
.copyname	move.b	(a1)+,(a0)+
	dbeq	d0,.copyname
	move.b	#pc_XPos,-1(a0)
	move.b	#30,(a0)+

	move.l	a4,d0	;address
	bsr.w	PrintHex82
	move.b	#pc_XPos,(a0)+
	move.l	a0,a1
	move.b	#45,(a0)+

	moveq	#0,d0	;version
	move.w	lib_Version(a4),d0
	and.w	#512-1,d0	;sorry bro!
	bsr.w	PrintDec
	move.l	a0,d1
	sub.l	a1,d1
	sub.b	d1,(a1)	;align
	move.b	#'.',(a0)+	;revision
	moveq	#0,d0
	move.w	lib_Revision(a4),d0
	bsr.w	PrintDec
	move.b	#pc_XPos,(a0)+
	move.b	#52,(a0)+

	moveq	#0,d0	;neg size
	moveq	#' ',d6
	move.w	lib_NegSize(a4),d0
	moveq	#3,d1
	move.b	#'$',(a0)+
	bsr.w	PrintHex
	move.b	d6,(a0)+
	move.b	d6,(a0)+

	moveq	#0,d0	;pos size
	move.w	lib_PosSize(a4),d0
	moveq	#3,d1
	move.b	#'$',(a0)+
	bsr.w	PrintHex
	move.b	d6,(a0)+
	move.b	d6,(a0)+

	moveq	#0,d0	;open count
	move.w	lib_OpenCnt(a4),d0
	moveq	#3,d1
	move.b	#'$',(a0)+
	bsr.w	PrintHex

	clr.b	(a0)

	Push	d7/a4
	lea	TextLineBuffer(b),a0
	bsr.w	MoreLine
	Pull	d7/a4
	bne.w	.broken

	addq.w	#1,d7	;inc process number
	bra.w	.libinfoloop


;----------------------------------------------------
;- Name	: TaskInfo
;- Description	: Give information about tasks in system
;----------------------------------------------------
;- 161093	First version
;----------------------------------------------------
TaskInfo	bsr.w	SumExecBase
	bne.w	PrintError

	bsr.w	MCursorDownDO	;line down
	bsr.w	MoreLineReset
	lea	TaskInfoText(b),a0
	bsr.w	MoreLine

	moveq	#0,d7	;process number
	move.l	$4.w,a4
	lea	276(a4),a4	;running task
	bsr.b	.TaskInfoLoop

	move.l	$4.w,a4
	lea	406(a4),a4	;taskready
	bsr.b	.TaskInfoLoop

	move.l	$4.w,a4
	lea	420(a4),a4	;taskwait
	bsr.b	.TaskInfoLoop
	subq.w	#4,a7

.broken	addq.w	#4,a7	;skip caller
	clr.b	CurKey(b)
	bra.w	NoPromptNoLF

.TaskInfoLoop	move.l	(a4),a4	;goto next process
	tst.l	(a4)
	bne.b	.printit
	rts

.printit	lea	TextLineBuffer(b),a0
	move.w	d7,d0
	moveq	#1,d1
	move.b	#'$',(a0)+	;process number
	bsr.w	PrintHex
	move.b	#' ',(a0)+

	move.l	10(a4),a1	;name
	moveq	#23,d0
.copyname	move.b	(a1)+,(a0)+
	dbeq	d0,.copyname
	move.b	#pc_XPos,-1(a0)
	move.b	#29,(a0)+

	move.b	LN_PRI(a4),d0	;priority
	ext.w	d0
	ext.l	d0
	bsr.w	PrintDec
	move.b	#pc_XPos,(a0)+
	move.b	#34,(a0)+

	moveq	#0,d0
	move.b	LN_TYPE(a4),d0	;type
	asl.w	#3,d0
	lea	NodeTypesTxt(b),a1
	add.w	d0,a1
	moveq	#7,d0
.printlong	move.b	(a1)+,(a0)+
	dbra	d0,.printlong
	move.b	#' ',(a0)+

	moveq	#0,d0	;state
	move.b	TC_STATE(a4),d0
	asl.w	#3,d0
	lea	TaskStatesTxt(b),a1
	add.w	d0,a1
	moveq	#7,d0
.copystate	move.b	(a1)+,(a0)+
	dbra	d0,.copystate

	move.l	a4,d0	;task address
	bsr.w	PrintHex82
	move.b	#' ',(a0)+

	move.l	TC_SPREG(a4),d0	;stackpointer
	bsr.w	PrintHex82
	move.b	#' ',(a0)+

	move.l	TC_SPREG(a4),a1	;PC
	move.l	10+15*4(a1),d0
	cmp.w	#39,KickVersion(b)
	bge.b	.HighKick
	move.l	14+15*4(a1),d0	;Kick 2 have an extra long on the stack
.HighKick
	cmp.b	#TS_RUN,TC_STATE(a4)
	bne.b	.running
	move.l	PCReg(b),d0
.running	bsr.w	PrintHex82
	clr.b	(a0)

	Push	d7/a4
	lea	TextLineBuffer(b),a0
	bsr.w	MoreLine
	Pull	d7/a4
	bne.w	.broken

	addq.w	#1,d7	;inc process number
	bra.w	.TaskInfoLoop

;----------------------------------------------------
;- Name	: DiskInfo
;- Description	: Give information about disks in system
;- SYNTAX	: info
;----------------------------------------------------
;- 081093	Made layout
;----------------------------------------------------
DiskInfo:	lea	DiskInfoText(b),a0
	bsr.w	Print

	move.b	SelectedDrive(b),d0
	or.b	#$f0,d0
	move.b	d0,DiskInfoFlag(b)
	clr.b	SelectedDrive(b)
	moveq	#3,d7
	moveq	#'0',d6
.DiskInfoLoop;	move.w	#-1,CurrentTrack(b)
	grcall	InitDriveDOS
	move.l	d1,d5

	cmp.w	#EV_NOTAVALIDDRIVENO,d5
	beq.w	.nextdrive

	lea	TextLineBuffer(b),a0
	move.b	#10,(a0)+
	move.b	#'D',(a0)+
	move.b	#'F',(a0)+
	move.b	d6,(a0)+
	move.b	#':',(a0)+
	moveq	#' ',d0
	move.b	d0,(a0)+
	move.b	d0,(a0)+
	move.b	d0,(a0)+
	cmp.w	#EV_UNKNOWNDRIVETYPE,d5
	bne.b	.unknown
	moveq	#'?',d0
	move.b	d0,(a0)+
	move.b	d0,(a0)+
	moveq	#pc_XPos,d0
	moveq	#'*',d1
	move.b	d0,(a0)+
	move.b	#-4,(a0)+
	move.b	d1,(a0)+	;format
	move.b	d0,(a0)+
	move.b	#-8,(a0)+
	move.b	d1,(a0)+	;name
	move.b	d0,(a0)+
	move.b	#-31,(a0)+
	move.b	d1,(a0)+	;free
	bra.w	.textready

.unknown	moveq	#'D',d0
	move.b	d0,1(a0)
	cmp.b	#22,DiskSectors(b)
	bne.b	.hddisk
	moveq	#'H',d0
.hddisk	move.b	d0,(a0)
	addq.w	#2,a0

	move.b	#pc_XPos,(a0)+
	move.b	#-4,(a0)+

	cmp.w	#EV_NODISK,d5
	bne.b	.dodisk
	lea	NoDiskTxt(b),a1
.copytxt	move.b	(a1)+,(a0)+
	bne.b	.copytxt
	subq.w	#1,a0
	bra.w	.textready

.dodisk	cmp.w	#EV_BADSECID,d5
	beq.b	.notamigados

	moveq	#0,d0
	move.l	a0,-(a7)
	grcall	GetBlock
	move.l	(a7)+,a0

	move.l	BlockBuffer,d0
	move.l	d0,d1
	and.l	#$ffffff00,d1
	cmp.l	#'DOS'<<8,d1
	bne.b	.ados
	and.w	#$ff,d0
	asl.w	#2,d0
	lea	DOSTypesTxt(b),a1
	move.l	(a1,d0.w),d0
	bra.b	.typeok

.ados	cmp.l	#'KICK',d0
	beq.b	.typeok
.notamigados	move.l	#'????',d0

.typeok	moveq	#3,d1
.settype	rol.l	#8,d0
	move.b	d0,(a0)+
	dbra	d1,.settype
.done
	move.b	#pc_XPos,(a0)+
	move.b	#22,(a0)+

	move.w	ROOTBlock(b),d0
	move.l	a0,-(a7)
	grcall	GetBlock
	move.l	(a7)+,a0

	lea	BlockBuffer,a1
	move.l	FH_BMPAGES(a1),d0
	moveq	#T_SHORT,d1
	cmp.l	(a1),d1
	bne.w	.textready
	moveq	#ST_ROOT,d1
	cmp.l	FH_SECTYPE(a1),d1
	bne.w	.textready

	lea	FH_NAME(a1),a1
	moveq	#0,d1
	move.b	(a1)+,d1
	subq.w	#1,d1
	bmi.w	.textready
.copyname	move.b	(a1)+,(a0)+
	dbra	d1,.copyname

	move.b	#pc_XPos,(a0)+
	move.b	#54,(a0)+

	move.l	a0,-(a7)
	grcall	GetBlock	;get BM
	move.l	(a7)+,a0
;fix

	lea	BlockBuffer+4,a1
	moveq	#0,d1
	move.b	DiskSectors(b),d1
	mulu	#5,d1
	subq.w	#1,d1
	moveq	#0,d0
	moveq	#-1,d3
.sumblocks	move.l	(a1)+,d2
	beq.b	.full
	cmp.l	d3,d2
	beq.b	.free
	moveq	#31,d4
.sum	add.l	d2,d2
	bcs.b	.notused
	addq.w	#1,d0
.notused	dbra	d4,.sum
.free	dbra	d1,.sumblocks
	bra.b	.onwithit

.full	add.w	#32,d0
	dbra	d1,.sumblocks

.onwithit	mulu	#100*2,d0	;*100% *2 to get round off
	moveq	#0,d1
	move.w	MaxBlock(b),d1
	divu	d1,d0
	moveq	#0,d1
	lsr.w	#1,d0
	addx.w	d1,d0	;round off
	move.w	d0,d1

	moveq	#100,d0
	sub.w	d1,d0

	bsr.w	PrintDec
	move.b	#'%',(a0)+

.textready	move.b	#pc_XPos,(a0)+
	move.b	#60,(a0)+

	moveq	#0,d2	;print TrackLengths
	move.b	SelectedDrive(b),d2
	add.w	d2,d2
	moveq	#0,d0
	lea	TrackLenTab(b),a1
	move.w	(a1,d2.w),d0
	moveq	#3,d1
	move.b	#'$',(a0)+
	bsr.w	PrintHex
	move.b	#'/',(a0)+
	moveq	#0,d0
	lea	TrackLenHTab(b),a1
	move.w	(a1,d2.w),d0
	moveq	#3,d1
	move.b	#'$',(a0)+
	bsr.w	PrintHex

	move.b	#' ',(a0)+	;Print sync
	move.b	#' ',(a0)+
	lea	DiskSyncTab(b),a1
	move.w	(a1,d2.w),d0
	moveq	#3,d1
	move.b	#'$',(a0)+
	bsr.w	PrintHex

	clr.b	(a0)
	lea	TextLineBuffer(b),a0
	bsr.w	Print

.nextdrive	grcall	MotorOff
	addq.b	#1,SelectedDrive(b)
	addq.b	#1,d6
	dbra	d7,.DiskInfoLoop

	move.b	DiskInfoFlag(b),d0
	and.b	#$f,d0
	move.b	d0,SelectedDrive(b)
	clr.b	DiskInfoFlag(b)
	bra.w	NoPrompt

;----------------------------------------------------
;- Name	: Memory Editors
;- Description	: Edit memory in Hex or ASCII
;- Notes	:
;----------------------------------------------------
;- 290893.0000	Included in routine index.
;----------------------------------------------------

;----- Start of "Memory Editor" ----------------------------------------------;
;-- This command will start a new input/output interface ala ASM-One including
;-- dis/assembler, hex/ascii-dump'n'edit. Exit with Escape
;-- SYNTAX: d/m/n <address>
MemoryEditorD	move.b	#em_Disassemble,EditMode(b)
	bra.b	MemoryEditor

MemoryEditorH	move.b	#em_HexDump,EditMode(b)
	move.b	(a0)+,d0	;check for forced size
	or.b	#$20,d0
	moveq	#0,d1
	cmp.b	#'b',d0
	beq.b	.forced
	moveq	#1,d1
	cmp.b	#'w',d0
	beq.b	.forced
	moveq	#2,d1
	cmp.b	#'l',d0
	beq.b	.forced
	subq.w	#1,a0
	move.b	HexDumpSize(b),d1;use prev type
.forced	move.b	d1,HexDumpSize(b)
	bra.b	MemoryEditor

;peeker editor
MemoryEditorP	move.b	#em_PeekerDump,EditMode(b)
	bra.b	MemoryEditor	

MemoryEditorA	move.b	#em_ASCIIDump,EditMode(b)

MemoryEditor	move.b	(a0)+,d0	;check for address
	beq.b	.noaddress
	cmp.b	#' ',d0
	beq.b	MemoryEditor
	subq.w	#1,a0
	bsr.w	GetValue
	move.l	d0,MemoryAddress(b)
.noaddress

.EditSelector	lea	EditCharBack,a1
	move.l	CharPointer(b),a0
	move.w	#CharBSize/4-1,d0;make backup of active charbuffer
.makebackup	move.l	(a0)+,(a1)+
	dbra	d0,.makebackup
	move.w	CurXPos(b),EditPosBack(b);store xpos

	moveq	#0,d0
	move.b	EditMode(b),d0
	jmp	.EditTable(pc,d0)
;w;
.EditTable	bra.w	DisDumpEdit
	bra.w	HexDumpEdit
	bra.w	ASCIIDumpEdit
	bra.w	PeekerEdit
;----- End of "Memory Editor" ------------------------------------------------*

;----- Start of "Hex Dump Editor" --------------------------------------------;
HexDumpEdit	clr.b	HideCursor(b)
	clr.b	LastCMDError(b)
	bsr.w	ClearScreen
	bsr.w	PrintFlags
	moveq	#0,d1	;dump first page (called when size chgs)
	move.b	HexEditYPos(b),d1;set ypos to middle of screen
	asl.w	#4,d1	;1/2 screen * $10
	move.l	MemoryAddress(b),d0
	move.l	d0,CurrentAddress(b)
	sub.l	d1,d0	;get top-address
	bsr.w	HexEditDumpPage	;print page
	clr.b	HexEditNPos(b)	;++1 for each nibble
	moveq	#9,d0
	move.b	pr_ShortAddress(b),d1
	bne.b	.shortaddress
	moveq	#11,d0
.shortaddress	move.b	d0,HexEditHexO(b);xpos offset
	move.b	d0,CurXPos(b)
	add.w	#$22+16,d0	;add offset for digits+" '"+spaces
	move.b	HexDumpSize(b),d1
	subq.w	#1,d1
	bmi.b	.bytes
	moveq	#8,d2
	tst.w	d1
	beq.b	.words
	moveq	#12,d2
.words	sub.w	d2,d0	;fix to w/l size
.bytes	move.b	d0,HexEditASCIIO(b)
	clr.b	HexEditColumn(b);0=in hex column. 1=ascii column

HDELoopYPos	move.b	HexEditYPos(b),CurYPos(b)

	moveq	#0,d0
	move.b	HexEditNPos(b),d0
	lsr.w	#1,d0
	add.l	CurrentAddress(b),d0
	move.l	d0,MemoryAddress(b)
	bsr.w	PrintHeaderInfo
HexEditLoopE	bsr.w	PrintFlags

HexDumpEditLoop	tst.b	DisplayHelp(b)
	beq.b	.checkhelp
.dohelp	lea	EditorHelp,a0
	pea	HDELoopYPos(pc)
	moveq	#eh_HexEdit,d6;set Hex-mask
	bra.w	PrintHelp

.HELPRegs	bsr.w	DisplayRegs
	bra.b	HDELoopYPos

.checkhelp	tst.b	ExitFlag(b)
	bne.w	DumpEditExit

	bsr.w	PasteText	;if any

;	moveq	#0,d0
;	move.b	CurKey(b),d0
	beq.b	HexDumpEditLoop
	clr.b	CurKey(b)

	move.b	Control(b),d1

	cmp.b	#key_esc,d0	;ESC to exit
	beq.w	DumpEditExit

	cmp.b	#key_del,d0	;check for insert/overwrite shift
	bne.b	.ChangeInsert
	and.b	#kq_altmask,d1
	beq.b	HexDumpEditLoop
	not.b	InsertOverwrite(b);change mode
	bsr.w	PrintFlags
	bra.b	HexDumpEditLoop

.ChangeInsert	cmp.b	#key_PointerPos,d0
	beq.b	HexDumpEditLoop

	cmp.b	#key_tab,d0	;shift between hex/ascii
	beq.w	HDEShift

	cmp.b	#key_up,d0	;up
	beq.w	HDEUp

	cmp.b	#key_down,d0	;down
	beq.w	HDEDown

	cmp.b	#key_right,d0	;right
	beq.w	HDERight

	cmp.b	#key_left,d0	;left
	beq.w	HDELeft

	cmp.b	#key_bs,d0	;bs=left
	beq.w	HDELeft

	cmp.b	#key_help,d0	;help=display error
	bne.b	.help
	move.b	Control(b),d0
	btst	#kq_ctrl,d0	;if ctrl, show regs
	bne.b	.HELPRegs
	and.b	#kq_altmask,d0	;if alt, show help
	bne.w	.dohelp
	bsr.w	PrintLEInHeader	;else show last error
	bra.w	HexDumpEditLoop

.help	move.b	d0,d3	;for store-mark check
	or.b	#$20,d0	;force lowercase

	move.b	d1,d2	;check CTRL - shortcuts
	and.b	#1<<kq_ctrl,d2
	beq.b	.checkamiga

	cmp.b	#'d',d0	;CTRL+d - Disassemble
	beq.w	HexEditDisassem

	cmp.b	#'a',d0	;CTRL+a - ASCII dump
	beq.w	HexEditASCII

	cmp.b	#'h',d0	;CTRL+h - Hex dump
	beq.w	HexEditHex

	cmp.b	#'l',d0	;CTRL+l - Long Edit
	beq.w	HexEditLong

	cmp.b	#'w',d0	;CTRL+w - Word Edit
	beq.w	HexEditWord

	cmp.b	#'b',d0	;CTRL+b - Byte Edit
	beq.w	HexEditByte

.checkamiga	clr.b	LastCMDError(b)
	move.b	d1,d2	;check AMIGA - shortcuts
	and.b	#kq_funcmask,d2
	bne.b	Hcheckshorts
	tst.b	HexEditColumn(b);in what column
	bne.b	Hasciicolumn
	cmp.b	#'0',d0	;hex column. Only 0-9/a-f
	blt.b	Hnotvalid
	cmp.b	#'9',d0
	ble.b	.ciffer
	cmp.b	#'a',d0
	blt.b	Hnotvalid
	cmp.b	#'f',d0
	bgt.b	Hnotvalid
	sub.b	#39,d0
.ciffer	sub.b	#'0',d0
	move.b	#$f0,d1
	btst	#0,HexEditNPos(b);alter nibblewize
	bne.b	Haltermem
	asl.w	#4,d0
	lsr.b	#4,d1
Haltermem	move.l	MemoryAddress(b),a0;alter mem
	and.b	d1,(a0)
	or.b	d0,(a0)

	pea	HDERight(pc)

HexUpdateLine	move.b	CurXPos(b),d7
	clr.b	CurXPos(b)
	move.l	CurrentAddress(b),d0
	bsr.w	HexEditDumpLine	;and print new line
	move.b	d7,CurXPos(b)
	moveq	#0,d1
	rts

Hnotvalid	bra.w	HexDumpEditLoop

Hasciicolumn	cmp.b	#' ',d3	;in ASCII column. Check ' '-'z'
	blt.b	Hnotvalid
	cmp.b	#'z',d3
	bgt.b	Hnotvalid
	moveq	#0,d1
	move.b	d3,d0
	bra.b	Haltermem

Hcheckshorts	move.b	d1,d2
	and.b	#kq_shiftmask,d2;shifted?
	bne.w	.shifted

	cmp.b	#'0',d3	;jump marks?
	blt.b	.checkon
	cmp.b	#'9',d3
	bgt.b	.checkon
	bsr.w	GetMarkAddress
	bra.w	HexEditCheckAdd

.checkon	cmp.b	#',',d3	;, - previous find address
	beq.w	HexPrevAdd

	cmp.b	#'.',d3	;. - next find address
	beq.w	HexNextAdd

	cmp.b	#'a',d0	;a - Assign symbol
	beq.w	HexEditAssign

	cmp.b	#'b',d0	;b - mark area
	beq.w	HexMarkArea

	cmp.b	#'d',d0	;d - Disassemble Edit
	beq.w	DisDumpEdit

	cmp.b	#'e',d0	;e - Edit with expression (size)
	beq.w	HexEditEDef

	cmp.b	#'j',d0	;j - Jump
	beq.w	HexEditJump

	cmp.b	#'l',d0	;l - Quick Jump To Last Address
	beq.w	HexEditLast

	cmp.b	#'n',d0	;n - ASCII Edit
	beq.w	ASCIIDumpEdit

	cmp.b	#'o',d0	;o - add offset
	beq.w	HexAddOffset

	cmp.b	#'p',d0	;p - Peeker Editor
	beq.w	PeekerEdit

	cmp.b	#'q',d0	;q - Quick Jump
	beq.w	HexEditQJump

	cmp.b	#'r',d0	;r - reposition
	beq.w	HexDumpEdit

	cmp.b	#'u',d0	;u - add BCPL
	beq.w	HexEditBOJump

	cmp.b	#'x',d0	;x - Exit
	beq.w	DumpEditExit

	cmp.b	#'z',d0	;z - zap jump table
	bne.b	.nocmd
	st.b	NestedJumps(b)

.nocmd	bra.w	HDELoopYPos

;---- check shifted commands
.shifted	moveq	#9,d1	;first check 0-9 = set mark
	lea	KeyTabShift+1(pc),a0
.checkstoremark	cmp.b	(a0)+,d3
	beq.b	.store
	dbra	d1,.checkstoremark
	bra.b	.goon

.store	tst.b	d1	;roll numbers to get 0 first
	bne.b	.swapd
	moveq	#10,d1

.swapd	moveq	#'0'+9+1,d0
	sub.b	d1,d0
	pea	HDELoopYPos(pc)
	bra.w	PutMarkAddress

.goon	and.b	#~$20,d0	;makes it easier do distinguiz!

	cmp.b	#'<',d3	;< - First find address
	beq.b	HexFirstAdd

	cmp.b	#'>',d3	;> - Last find address
	beq.b	HexLastAdd

	cmp.b	#'B',d0	;B - Keep marked area for search
	beq.b	HexMarkAreaHide

	cmp.b	#'C',d0	;C - Copy area
	beq.b	HexCopyArea

	cmp.b	#'E',d0	;E - Edit with expression (ask b/w/l)
	beq.w	HexEditESize

	cmp.b	#'F',d0	;F - Fill area
	beq.b	HexFillArea

	cmp.b	#'Q',d0	;Q - Quick jump + offset
	beq.w	HexEditJumpOff

	cmp.b	#'U',d0	;U - jump BCPL
	beq.w	HexEditBJump

	cmp.b	#'X',d0
	beq.w	DumpEditExit

	bra.w	HDELoopYPos

;---- Copy marked area
HexCopyArea	bsr.w	EditCopyArea
	bra.b	HexUpdateScreen

;---- Fill marked area
HexFillArea	bsr.w	EditFillArea

HexUpdateScreen	bne.w	HexDumpEditLoop	;only update if operation performed
	moveq	#0,d0
	bra.w	HDEJumpOffset

;---- Start mark
HexMarkArea	pea	HDELoopYPos(pc)
	bra.w	EditMarkBlock

;---- Keep marked area for search
HexMarkAreaHide	pea	HDELoopYPos(pc)
	bra.w	EditMarkHide

;---- Get previous hunt address
HexPrevAdd	moveq	#-1,d0
HexAddMain	bsr.w	GetHuntAddress
	bmi.w	HDELoopYPos
	bra.w	HexDumpEdit

;---- Get previous hunt address
HexNextAdd	moveq	#1,d0
	bra.b	HexAddMain

;---- Get first hunt address
HexFirstAdd	clr.b	ABPointer(b)
	moveq	#0,d0
	bra.b	HexAddMain

;---- Get last hunt address
HexLastAdd	move.b	AddressCount(b),d0
	beq.w	HDELoopYPos
	subq.b	#1,d0
	move.b	d0,ABPointer(b)
	moveq	#0,d0
	bra.b	HexAddMain

;---- Disassemble at distant address
HexEditDisassem	pea	HexEditLoopE(pc)
	pea	HeaderDisassem(pc)
HexEditDistant	move.l	MemoryAddress(b),a0
	move.b	(a0)+,d0
	asl.w	#8,d0
	move.b	(a0)+,d0
	swap	d0
	move.b	(a0)+,d0
	asl.w	#8,d0
	move.b	(a0),d0
	move.l	d0,a0
	rts

;---- ASCII dump at distant address
HexEditASCII	pea	HexEditLoopE(pc)
	pea	HeaderASCIIDump(pc)
	bra.b	HexEditDistant

;---- HEX dump at distant address
HexEditHex	pea	HexEditLoopE(pc)
	pea	HeaderHexDump(pc)
	bra.b	HexEditDistant

;---- Get calculated value with default size
HexEditEDef	move.b	HexDumpSize(b),d7;use hexdump-size
	bra.b	HexEditExpress

HexEditESize	bsr.w	EditGetSize
	tst.w	d7
	bmi.w	HDELoopYPos

;---- get calculated value
;-- Input : d7 - size 0-2 (b-l)
;----
HexEditExpress	lea	EditorExprText(b),a0
	bsr.w	GetHeaderInput	;get input
	bmi.w	HDELoopYPos
	lea	InputLine(b),a0
	bsr.w	GetValueCall	;read value
	bmi.w	HexEditError
	move.l	MemoryAddress(b),a0
	addq.w	#1,a0
	tst.b	d7
	beq.b	.byte
	addq.w	#1,a0
	cmp.b	#1,d7
	beq.b	.word
	addq.w	#2,a0
	move.b	d0,-(a0)	;store data bytewize to allow
	lsr.w	#8,d0	;odd access
	move.b	d0,-(a0)
	swap	d0
.word	move.b	d0,-(a0)
	lsr.w	#8,d0
.byte	move.b	d0,-(a0)
	pea	HDELoopYPos(pc)
	bra.w	HexUpdateLine

;---- Ask for offset and jump to MemAdd+Offset
HexAddOffset	lea	EditorOffsText(b),a0;ask offset
	bsr.w	GetHeaderInput
	bmi.w	HDELoopYPos
	lea	InputLine(b),a0
	bsr.w	GetValueCall
	bmi.w	HexEditError
	add.l	MemoryAddress(b),d0;and add to current pos
	bra.b	HexEditNestAdd

;---- Assign symbol to address
HexEditAssign	pea	HexEditLoopE(pc)
	bra.w	AssignSymbol

;---- Jump BCPL offset +4 (+4)
HexEditBOJump	move.l	MemoryAddress(b),d2
	addq.l	#4,d2	;skip the BCPL address
	and.b	#kq_altmask,d1
	beq.b	HexEditBMain
	addq.l	#4,d2	;if alted add extra 4 bytes (reloc)
	bra.b	HexEditBMain

HexEditBJump	moveq	#0,d2
HexEditBMain	bsr.b	HexEditGetAdd	;get BCPL address
	asl.l	#2,d0	;convert to CPU
	add.l	d2,d0	;add offset
	bra.b	HexEditNestAdd	;and jump

;---- Jump to last nested address
HexEditLast	moveq	#EV_NONESTEDADDS,d1
	move.b	NestedJumps(b),d0;any last?
	bmi.b	HexEditError
	subq.b	#1,NestedJumps(b);yes, kill it
	asl.w	#2,d0
	lea	NestedJMPTable(b),a2
	move.l	(a2,d0.w),d0	;and jump
	bra.b	HexEditCheckAdd

;---- Quick jump
HexEditQJump	pea	HexEditNestAdd(pc)

HexEditGetAdd	move.l	MemoryAddress(b),a0
	moveq	#3,d1	;get address from current address
.getlongloop	asl.l	#8,d0
	move.b	(a0)+,d0
	dbra	d1,.getlongloop
	rts

;---- Nest MemoryAddress in table and jump to D0
HexEditNestAdd	moveq	#EV_JUMPTABLEFULL,d1;check for full table
	cmp.b	#MaxNested-1,NestedJumps(b)
	beq.b	HexEditError
	addq.b	#1,NestedJumps(b);nest address in list
	moveq	#0,d1
	move.b	NestedJumps(b),d1
	asl.w	#2,d1
	move.l	MemoryAddress(b),a0
	lea	NestedJMPTable(b),a1
	move.l	a0,(a1,d1.w)

HexEditCheckAdd	tst.b	pr_ShortAddress(b);check it's ok
	beq.b	.noshort
	and.l	#$ffffff,d0	;fix to 24 bit
.noshort	move.l	d0,MemoryAddress(b)
	bra.w	HexDumpEdit	;and jump


HexEditError	pea	HexEditLoopE(pc);HDELoopYPos(pc)
HexEditErrorC	move.w	d1,LastErrorNumber(b);store error number
	st.b	LastCMDError(b)	;and flag error
	bra.w	PrintLEInHeader

;---- Jump with current data as base
HexEditJumpOff	bsr.b	HexEditGetAdd
	lea	TextLineBuffer(b),a0
	move.l	a0,a2
	bsr.w	PrintHexS
	clr.b	(a0)
	lea	EditorOffsText(b),a0
	bra.b	HexEditJumpMain

;---- Get address and jump
HexEditJump	lea	EditorJumpText(b),a0
	sub.l	a2,a2
HexEditJumpMain	bsr.w	GetHeaderInputP
	bne.w	HDELoopYPos	;skip if fail
	lea	InputLine(b),a0
	bsr.w	GetValueCall
	bmi.b	HexEditError
	bra.b	HexEditNestAdd

HexEditLong	moveq	#2,d0
HEDCheckSize	cmp.b	HexDumpSize(b),d0
	beq.w	HexDumpEditLoop
	move.b	d0,HexDumpSize(b)
	bra.w	HexDumpEdit

HexEditWord	moveq	#1,d0
	bra.b	HEDCheckSize

HexEditByte	moveq	#0,d0
	bra.b	HEDCheckSize

;---- cursor up - ROOT
HDEUp	move.w	d1,d0	;check for
	and.w	#kq_shiftmask,d0;page
	bne.b	HDEPageUp
	and.w	#kq_altmask,d1	;$1000
	bne.b	HDEPagesUp
;---- one up
HDEOneUp	pea	HDELoopYPos(pc)
HDEOneUpCall	move.b	CurXPos(b),d7	;keep current X
	clr.b	CurXPos(b)	;goto top of screen
	clr.b	CurYPos(b)
	moveq	#-$10,d0	;add offset to pointers
	bsr.w	EditAddOffset
	moveq	#-1,d0
	bsr.w	ScrollScreen	;scroll screen
	move.l	TopAddress(b),d0
	bsr.w	HexEditDumpLine	;and print new line
	move.b	d7,CurXPos(b)
	rts

;---- one page up
HDEPageUp	moveq	#0,d0	;Jump one page up
	move.w	TextLines(b),d0
	subq.w	#1,d0
	asl.w	#4,d0
	neg.l	d0
HDEJumpOffset	bsr.w	EditAddOffset
	move.l	TopAddress(b),d0
	move.b	CurXPos(b),d7	;keep current X
	bsr.w	HexEditDumpPage
	move.b	d7,CurXPos(b)	;restore X
	bra.w	HDELoopYPos

;---- $1000 bytes up
HDEPagesUp	move.l	#-$1000,d0	;Jump $1000 bytes up
	bra.b	HDEJumpOffset

;---- cursor down - ROOT
HDEDown	move.w	d1,d0	;check for
	and.w	#kq_shiftmask,d0;page
	bne.b	HDEPageDown
	and.w	#kq_altmask,d1	;$1000
	bne.b	HDEPagesDown
;---- one down
HDEOneDown	move.b	CurXPos(b),d7	;keep current X
	clr.b	CurXPos(b)	;goto bottom of screen
	move.w	TextLines(b),d0
	subq.w	#1,d0
	move.b	d0,CurYPos(b)
	moveq	#$10,d0	;add offset to pointers
	bsr.w	EditAddOffset
	moveq	#1,d0
	bsr.w	ScrollScreen	;scroll screen
	move.l	BottomAddress(b),d0
	bsr.w	HexEditDumpLine	;and print new line
	move.b	d7,CurXPos(b)
	bra.w	HDELoopYPos

;---- one page down
HDEPageDown	moveq	#0,d0	;Jump one page down
	move.w	TextLines(b),d0
	subq.w	#1,d0
	asl.w	#4,d0
	bra.b	HDEJumpOffset

;---- $1000 bytes down
HDEPagesDown	move.l	#$1000,d0	;Jump $1000 bytes down
	bra.b	HDEJumpOffset

;---- cursor right - ROOT
HDERight	tst.b	HexEditColumn(b);in what column
	bne.b	HDEASCIIRight
	move.b	d1,d0	;far right?
	and.b	#kq_shiftmask,d1
	bne.b	.shifted	;next b/w/l
	and.b	#kq_altmask,d0
	bne.b	.alted
	addq.b	#1,HexEditNPos(b);advance one nibble
.CheckForScroll	cmp.b	#$20,HexEditNPos(b);check for scroll
	bne.w	CalcXPosFromN	;if still on same line, calk xpos
	clr.b	HexEditNPos(b)	;else clear xpos
	move.b	HexEditHexO(b),CurXPos(b);and scroll one line
	bra.b	HDEOneDown

;---- cursor to start of next b/w/l
.alted	move.b	HexEditNPos(b),d1
	moveq	#2,d3
	move.b	HexDumpSize(b),d0
	asl.b	d0,d3
	move.w	d3,d2
	subq.w	#1,d2
	and.b	d2,d1
	sub.b	d1,d3
	add.b	d3,HexEditNPos(b)
	bra.b	.CheckForScroll

.shifted	move.b	HexEditASCIIO(b),d0
	subq.b	#4,d0
	move.b	d0,CurXPos(b)
	move.b	#$1f,HexEditNPos(b)
	bra.w	HDELoopYPos

;---- move right in ASCII window
HDEASCIIRight	and.b	#kq_shiftmask,d1
	bne.b	.shifted
	addq.b	#1,CurXPos(b)	;one right
	addq.b	#2,HexEditNPos(b)
	cmp.b	#$20,HexEditNPos(b);over "'"?
	blt.w	HDELoopYPos
	clr.b	HexEditNPos(b)	;if so, get to next line
	sub.b	#$10,CurXPos(b)
	bra.w	HDEOneDown

.shifted	move.b	HexEditASCIIO(b),d0
	add.b	#$0f,d0
	move.b	d0,CurXPos(b)
	move.b	#$1e,HexEditNPos(b)
	bra.w	HDELoopYPos

;---- cursor left - ROOT
HDELeft	tst.b	HexEditColumn(b);in what column
	bne.b	HDEASCIILeft
	move.b	d1,d0	;far left
	and.b	#kq_shiftmask,d1
	bne.b	.shifted	;prev b/w/l
	and.b	#kq_altmask,d0
	bne.b	.alted
	subq.b	#1,HexEditNPos(b);one nibble back
.CheckForScroll	tst.b	HexEditNPos(b)	;check for scroll
	bpl.w	CalcXPosFromN	;if still on same line, calk xpos
	bsr.w	HDEOneUpCall	;else scroll
	and.b	#$1f,HexEditNPos(b);and set xpos=far right (see below)
	bra.w	CalcXPosFromN

;---- cursor to start of prev b/w/l
.alted	move.b	HexEditNPos(b),d1
	sub.b	#1,d1
	moveq	#2,d3
	move.b	HexDumpSize(b),d0
	asl.b	d0,d3
	subq.w	#1,d3

	cmp.b	d3,d1	;if in leftmost b/w/l
	bge.b	.special	;jump to end -b/w/l
	moveq	#-1,d1
.special	not.w	d3
	and.b	d3,d1
	move.b	d1,HexEditNPos(b)
	bra.b	.CheckForScroll

.shifted	move.b	HexEditHexO(b),CurXPos(b)
	clr.b	HexEditNPos(b)
	bra.w	HDELoopYPos

;---- move left in ASCII window
HDEASCIILeft	and.b	#kq_shiftmask,d1
	bne.b	.shifted
	subq.b	#1,CurXPos(b)	;one right
	subq.b	#2,HexEditNPos(b)
	bpl.w	HDELoopYPos	;over border?
	move.b	#$1e,HexEditNPos(b);if so, get to prev line
	add.b	#$10,CurXPos(b)
	bra.w	HDEOneUp

.shifted	move.b	HexEditASCIIO(b),CurXPos(b)
	clr.b	HexEditNPos(b)
	bra.w	HDELoopYPos


;---- Add ofset (d0) to pointers used in the editors (hex/ascii anyway)
;-- Input: d0 - offset
;----
EditAddOffset	add.l	d0,TopAddress(b)
	add.l	d0,BottomAddress(b)
	add.l	d0,CurrentAddress(b)
	move.b	pr_ShortAddress(b),d0
	beq.b	.nofix
	move.l	#$ffffff,d0
	tst.l	TopAddress(b)
	bpl.b	.topfix
	and.l	d0,TopAddress(b)
.topfix	tst.l	BottomAddress(b)
	bpl.b	.botfix
	and.l	d0,BottomAddress(b)
.botfix	tst.l	CurrentAddress(b)
	bpl.b	.nofix
	and.l	d0,CurrentAddress(b)
.nofix	rts

;---- shift between hex and ASCII columns
HDEShift	moveq	#0,d0
	move.b	HexEditNPos(b),d0
	lsr.w	#1,d0
	tst.b	HexEditColumn(b);in what column
	bne.b	CalcXPosFromN
	add.b	HexEditASCIIO(b),d0
	move.b	d0,CurXPos(b)
	st.b	HexEditColumn(b)
	bclr.b	#0,HexEditNPos(b);reset nibble pos
	bra.w	HexDumpEditLoop

;---- Calculate CurXPos from HexEditNPos
CalcXPosFromN	moveq	#0,d0	;also called to set CurXPos
	move.b	HexEditNPos(b),d0
	lsr.w	#1,d0
	move.b	HexDumpSize(b),d1;find pos in hex column
	bne.b	.byte
	move.w	d0,d1	;bytes
	add.w	d1,d1
	add.w	d1,d0	;pos*3
	bra.b	.fixed

.byte	subq.b	#1,d1
	bne.b	.word
	move.w	d0,d1	;words
	and.w	#1,d1
	add.w	d1,d1
	lsr.w	#1,d0
	move.w	d0,d2
	asl.w	#2,d0
	add.w	d2,d0
	add.w	d1,d0
	bra.b	.fixed

.word	move.w	d0,d1	;long
	and.w	#%11,d1
	add.w	d1,d1
	lsr.w	#2,d0
	move.w	d0,d2
	asl.w	#3,d0
	add.w	d2,d0
	add.w	d1,d0

.fixed	moveq	#0,d1	;add offset
	move.b	HexEditNPos(b),d1
	and.w	#1,d1	;add nibble position
	add.b	HexEditHexO(b),d1
	add.w	d0,d1
	move.b	d1,CurXPos(b)	;and set xpos
	clr.b	HexEditColumn(b)
	bra.w	HDELoopYPos

;---- Print one hex-dump page
;-- Input : d0	- Top-line address
HexEditDumpPage	move.l	d0,TopAddress(b)
;	bsr.w	ClearScreen	;only clear screen at entry
	clr.b	CurXPos(b)
	clr.b	CurYPos(b)
	moveq	#0,d3
	move.w	TextLines(b),d3
	subq.w	#2,d3
	move.l	d0,d6
.DumpPageLoop	move.l	d6,d0
	moveq	#$0a,d2	;put return after line
	bsr.b	HEDLineCustom
	add.l	#$10,d6
	dbra	d3,.DumpPageLoop
	move.l	d6,BottomAddress(b)
	moveq	#0,d2	;no return after last line
	move.l	d6,d0
	bra.b	HEDLineCustom

;---- Dump one hex line (Edit layout)
;-- input:	d0 - address
;--	d2 - 0/$0a -/+ return after printed line
;----
HexEditDumpLine	moveq	#0,d2	;force no return
HEDLineCustom	lea	TextLineBuffer(b),a0;get buffer
	bsr.w	PrintHexS	;print address
	move.b	#' ',(a0)+
	move.b	#' ',(a0)+
	exg	d0,a0
	bsr.w	HexDump
	exg.l	d0,a0
	lea	DumpBuffer(b),a1
.copybuffer	move.b	(a1)+,(a0)+	;copy dumped text to print-buffer
	bne.b	.copybuffer
	move.b	d2,-1(a0)
	clr.b	(a0)
	lea	TextLineBuffer(b),a0
	bra.w	Print

;----- Start of "ASCII Dump Editor" ------------------------------------------;
ASCIIDumpEdit	clr.b	HideCursor(b)
	clr.b	LastCMDError(b)
	bsr.w	ClearScreen
	bsr.w	PrintFlags
	moveq	#0,d1	;dump first page (called when size chgs)
	move.b	HexEditYPos(b),d1
	asl.w	#6,d1	;* $40
	move.l	MemoryAddress(b),d0
	move.l	d0,CurrentAddress(b)
	sub.l	d1,d0	;get top-address
	bsr.w	ASCIIEditDP	;print page
	clr.b	ASCIIEditBPos(b);++1 for each letter
	moveq	#9,d0
	move.b	pr_ShortAddress(b),d1
	bne.b	.shortaddress
	moveq	#11,d0
.shortaddress	move.b	d0,ASCIIEditO(b);xpos offset
	move.b	d0,CurXPos(b)

ADELoopYPos	move.b	HexEditYPos(b),CurYPos(b)

	moveq	#0,d0
	move.b	ASCIIEditBPos(b),d0
	add.l	CurrentAddress(b),d0
	move.l	d0,MemoryAddress(b)
	bsr.w	PrintHeaderInfo
ASCIIEditLoopE	bsr.w	PrintFlags

ASCIIEditLoop	tst.b	ExitFlag(b)
	bne.w	DumpEditExit
	tst.b	DisplayHelp(b)
	beq.b	.nohelp
.dohelp	lea	EditorHelp,a0
	pea	ADELoopYPos(pc)
	moveq	#eh_ASCIIEdit,d6;set ASCII-mask
	bra.w	PrintHelp

.HELPRegs	bsr.w	DisplayRegs
	bra.b	ADELoopYPos

.nohelp	bsr.w	PasteText	;if any

;	moveq	#0,d0
;	move.b	CurKey(b),d0
	beq.b	ASCIIEditLoop
	clr.b	CurKey(b)

	move.b	Control(b),d1

	cmp.b	#key_esc,d0	;ESC to exit
	beq.w	DumpEditExit

	cmp.b	#key_del,d0	;check for insert/overwrite shift
	bne.b	.ChangeInsert
	and.b	#kq_altmask,d1
	beq.b	ASCIIEditLoop
	not.b	InsertOverwrite(b);change mode
	bsr.w	PrintFlags
	bra.b	ASCIIEditLoop

.ChangeInsert	cmp.b	#key_up,d0	;up
	beq.w	ADEUp

	cmp.b	#key_down,d0	;down
	beq.w	ADEDown

	cmp.b	#key_right,d0	;right
	beq.w	ADERight

	cmp.b	#key_left,d0	;left
	beq.w	ADELeft

	cmp.b	#key_bs,d0	;bs=left
	beq.w	ADELeft

	cmp.b	#key_help,d0	;help=display error
	bne.b	.help
	move.b	Control(b),d0
	btst	#kq_ctrl,d0	;if ctrl, show regs
	bne.b	.HELPRegs
	and.b	#kq_altmask,d0
	bne.w	.dohelp
	bsr.w	PrintLEInHeader
	bra.w	ASCIIEditLoop

.help	move.b	d0,d3	;for store-mark check
	or.b	#$20,d0	;force lowercase

	clr.b	LastCMDError(b)
	move.b	d1,d2	;check AMIGA - shortcuts
	and.b	#kq_funcmask,d2
	bne.b	.checkshorts

	cmp.b	#' ',d3	;Check ' '-'z'
	blt.b	.notvalid
	cmp.b	#'z',d3
	bgt.b	.notvalid

.altermem	move.l	MemoryAddress(b),a0;alter mem
	move.b	d3,(a0)

	move.b	CurXPos(b),d7
	clr.b	CurXPos(b)
	move.l	CurrentAddress(b),d0
	bsr.w	ASCIIEditDL	;and print new line
	move.b	d7,CurXPos(b)
	moveq	#0,d1
	bra.w	ADERight

.notvalid	bra.w	ASCIIEditLoop


.checkshorts	move.b	d1,d2
	and.b	#kq_shiftmask,d2;shifted?
	bne.w	.shifted

	cmp.b	#'0',d3	;jump marks?
	blt.b	.checkon
	cmp.b	#'9',d3
	bgt.b	.checkon
	bsr.w	GetMarkAddress
	bra.w	ASCIICheckAdd

.checkon	cmp.b	#'.',d3
	beq.w	ASCIINextAdd

	cmp.b	#',',d3
	beq.w	ASCIIPrevAdd

	cmp.b	#'a',d0	;a - Assign symbol
	beq.w	ASCIIAssign

	cmp.b	#'b',d0	;b - start/end mark
	beq.w	ASCIIStartMark

	cmp.b	#'d',d0	;d - Disassemble Edit
	beq.w	DisDumpEdit

	cmp.b	#'e',d0	;e - Edit with expression (byte)
	beq.w	ASCIIExpr

	cmp.b	#'j',d0	;j - Jump To Address
	beq.w	ASCIIEditJump

	cmp.b	#'l',d0	;l - Quick Jump To Last Address
	beq.w	ASCIILast

	cmp.b	#'h',d0	;h - Hex Edit
	beq.w	HexDumpEdit

	cmp.b	#'o',d0
	beq.b	ASCIIAddOffset	;o - add offset to address

	cmp.b	#'p',d0	;p - Peeker Editor
	beq.w	PeekerEdit

	cmp.b	#'r',d0	;r - reposition
	beq.w	ASCIIDumpEdit

	cmp.b	#'x',d0	;x - Exit
	beq.w	DumpEditExit

	cmp.b	#'z',d0	;z - zap jump table
	bne.b	.nocmd
	st.b	NestedJumps(b)

.nocmd	bra.w	ASCIIEditLoop

;---- check shifted commands
.shifted	moveq	#9,d1	;first check 0-9 = set mark
	lea	KeyTabShift+1(pc),a0
.checkstoremark	cmp.b	(a0)+,d3
	beq.b	.store
	dbra	d1,.checkstoremark
	bra.b	.checkonshift

.store	tst.b	d1	;roll numbers to get 0 first
	bne.b	.swapd
	moveq	#10,d1

.swapd	moveq	#'0'+9+1,d0
	sub.b	d1,d0
	pea	ADELoopYPos(pc)
	bra.w	PutMarkAddress

.checkonshift	cmp.b	#'<',d3
	beq.b	ASCIIFirstAdd

	cmp.b	#'>',d3
	beq.b	ASCIILastAdd

	cmp.b	#'B',d3	;B - hide marked area
	beq.b	ASCIIMarkAreaHide

	cmp.b	#'C',d0	;C - Copy area
	beq.b	ASCIICopyArea

	cmp.b	#'F',d0	;F - Fill area
	beq.b	ASCIIFillArea

	cmp.b	#'X',d3
	beq.w	DumpEditExit

	bra.b	.nocmd

;---- Ask for offset and jump to MemAdd+Offset
ASCIIAddOffset	lea	EditorOffsText(b),a0;ask offset
	bsr.w	GetHeaderInput
	bmi.w	ADELoopYPos
	lea	InputLine(b),a0
	bsr.w	GetValueCall
	bmi.w	ASCIIEditError
	add.l	MemoryAddress(b),d0;and add to current pos
	bra.w	ASCIINestAdd

;---- Copy marked area
ASCIICopyArea	bsr.w	EditCopyArea
	bra.b	ASCIIUpdate

;---- Fill marked area
ASCIIFillArea	bsr.w	EditFillArea

ASCIIUpdate	bne.w	ASCIIEditLoop;only update if operation performed
	moveq	#0,d0
	bra.w	ADEJumpOffset

;---- Start mark
ASCIIStartMark	pea	ADELoopYPos(pc)
	bra.w	EditMarkBlock

;---- Keep marked area for search
ASCIIMarkAreaHide
	pea	ADELoopYPos(pc)
	bra.w	EditMarkHide

;---- Get previous hunt address
ASCIIPrevAdd	moveq	#-1,d0
ASCIIAddMain	bsr.w	GetHuntAddress
	bmi.w	ADELoopYPos
	bra.w	ASCIIDumpEdit

;---- Get previous hunt address
ASCIINextAdd	moveq	#1,d0
	bra.b	ASCIIAddMain

;---- Get first hunt address
ASCIIFirstAdd	clr.b	ABPointer(b)
	moveq	#0,d0
	bra.b	ASCIIAddMain

;---- Get last hunt address
ASCIILastAdd	move.b	AddressCount(b),d0
	beq.w	ADELoopYPos
	subq.b	#1,d0
	move.b	d0,ABPointer(b)
	moveq	#0,d0
	bra.b	ASCIIAddMain

;---- Assign symbol to address
ASCIIAssign	pea	ASCIIEditLoopE(pc);use global routine
	bra.w	AssignSymbol

;---- get calculated value
ASCIIExpr	lea	EditorExprText(b),a0
	bsr.w	GetHeaderInput	;get input
	bmi.w	ADELoopYPos
	lea	InputLine(b),a0
	bsr.w	GetValueCall	;read value
	bmi.b	ASCIIEditError
	move.l	MemoryAddress(b),a0
	move.b	d0,(a0)
	bra.w	ASCIIDumpEdit

;---- Get address and jump
ASCIIEditJump	lea	EditorJumpText(b),a0
	bsr.w	GetHeaderInput
	bne.w	ADELoopYPos	;skip if fail
	lea	InputLine(b),a0
	bsr.w	GetValueCall
	bmi.b	ASCIIEditError

;---- Nest MemoryAddress in table and jump to D0
ASCIINestAdd	moveq	#EV_JUMPTABLEFULL,d1;check for full table
	cmp.b	#MaxNested-1,NestedJumps(b)
	beq.b	ASCIIEditError
	addq.b	#1,NestedJumps(b);nest address in list
	moveq	#0,d1
	move.b	NestedJumps(b),d1
	asl.w	#2,d1
	move.l	MemoryAddress(b),a0
	lea	NestedJMPTable(b),a1
	move.l	a0,(a1,d1.w)

ASCIICheckAdd	tst.b	pr_ShortAddress(b)
	beq.b	.noshort
	and.l	#$ffffff,d0	;fix to 24 bit
.noshort	move.l	d0,MemoryAddress(b)
	bra.w	ASCIIDumpEdit

;---- Jump to last nested address
ASCIILast	moveq	#EV_NONESTEDADDS,d1
	move.b	NestedJumps(b),d0;any last?
	bmi.b	ASCIIEditError
	subq.b	#1,NestedJumps(b);yes, kill it
	asl.w	#2,d0
	lea	NestedJMPTable(b),a2
	move.l	(a2,d0.w),d0	;and jump
	bra.b	ASCIICheckAdd

ASCIIEditError	pea	ASCIIEditLoopE(pc)
ASCIIEditErrorC	move.w	d1,LastErrorNumber(b);store error number
	st.b	LastCMDError(b)	;and flag error
	bra.w	PrintLEInHeader


;---- cursor up - ROOT
ADEUp	move.w	d1,d0	;check for
	and.w	#kq_shiftmask,d0;page
	bne.b	ADEPageUp
	and.w	#kq_altmask,d1	;$1000
	bne.b	ADEPagesUp
;---- one up
ADEOneUp	pea	ADELoopYPos(pc)
ADEOneUpCall	move.b	CurXPos(b),d7	;keep current X
	clr.b	CurXPos(b)	;goto top of screen
	clr.b	CurYPos(b)
	moveq	#-$40,d0	;add offset to pointers
	bsr.w	EditAddOffset
	moveq	#-1,d0
	bsr.w	ScrollScreen	;scroll screen
	move.l	TopAddress(b),d0
	bsr.w	ASCIIEditDL	;and print new line
	move.b	d7,CurXPos(b)
	rts

;---- one page up
ADEPageUp	moveq	#0,d0	;Jump one page up
	move.w	TextLines(b),d0
	subq.w	#1,d0
	asl.w	#6,d0
	neg.l	d0
ADEJumpOffset	bsr.w	EditAddOffset
	move.l	TopAddress(b),d0
	move.b	CurXPos(b),d7	;keep current X
	bsr.w	ASCIIEditDP
	move.b	d7,CurXPos(b)	;restore X
	bra.w	ADELoopYPos

;---- $1000 bytes up
ADEPagesUp	move.l	#-$1000,d0	;Jump $1000 bytes up
	bra.b	ADEJumpOffset

;---- cursor down - ROOT
ADEDown	move.w	d1,d0	;check for
	and.w	#kq_shiftmask,d0;page
	bne.b	ADEPageDown
	and.w	#kq_altmask,d1	;$1000
	bne.b	ADEPagesDown
;---- one down
ADEOneDown	move.b	CurXPos(b),d7	;keep current X
	clr.b	CurXPos(b)	;goto bottom of screen
	move.w	TextLines(b),d0
	subq.w	#1,d0
	move.b	d0,CurYPos(b)
	moveq	#$40,d0	;add offset to pointers
	bsr.w	EditAddOffset
	moveq	#1,d0
	bsr.w	ScrollScreen	;scroll screen
	move.l	BottomAddress(b),d0
	bsr.w	ASCIIEditDL	;and print new line
	move.b	d7,CurXPos(b)
	bra.w	ADELoopYPos

;---- one page down
ADEPageDown	moveq	#0,d0	;Jump one page down
	move.w	TextLines(b),d0
	subq.w	#1,d0
	asl.w	#6,d0
	bra.b	ADEJumpOffset

;---- $1000 bytes down
ADEPagesDown	move.l	#$1000,d0	;Jump $1000 bytes down
	bra.b	ADEJumpOffset

;---- cursor right - ROOT
ADERight	move.b	d1,d0	;far right?
	and.b	#kq_shiftmask,d1
	bne.b	ADEFRight
	addq.b	#1,ASCIIEditBPos(b);advance one letter
	addq.b	#1,CurXPos(b)
.CheckForScroll	cmp.b	#$40,ASCIIEditBPos(b);check for scroll
	bne.w	ADELoopYPos	;if still on same line, calk xpos
	clr.b	ASCIIEditBPos(b);else clear xpos
	move.b	ASCIIEditO(b),CurXPos(b);and scroll one line
	bra.b	ADEOneDown

ADEFRight	move.b	ASCIIEditO(b),d0;go far right
	moveq	#$3f,d1
	add.b	d1,d0
	move.b	d0,CurXPos(b)
	move.b	d1,ASCIIEditBPos(b)
	bra.w	ADELoopYPos

;---- cursor left - ROOT
ADELeft	move.b	d1,d0	;far left
	and.b	#kq_shiftmask,d1
	bne.b	.shifted	;prev b/w/l
	subq.b	#1,CurXPos(b)
	subq.b	#1,ASCIIEditBPos(b);one letter back
.CheckForScroll	bpl.b	.back	;if still on same line, return
	bsr.w	ADEOneUpCall	;else scroll
	bra.b	ADEFRight

.shifted	move.b	ASCIIEditO(b),CurXPos(b)
	clr.b	ASCIIEditBPos(b)
.back	bra.w	ADELoopYPos

;---- Print one ASCII-dump page
;-- Input : d0	- Top-line address
ASCIIEditDP	move.l	d0,TopAddress(b)
	clr.b	CurXPos(b)
	clr.b	CurYPos(b)
	moveq	#0,d3
	move.w	TextLines(b),d3
	subq.w	#2,d3
	move.l	d0,d6
.DumpPageLoop	move.l	d6,d0
	moveq	#$0a,d2	;put return after line
	bsr.b	AEDLineCustom
	add.l	#$40,d6
	dbra	d3,.DumpPageLoop
	move.l	d6,BottomAddress(b)
	moveq	#0,d2	;no return after last line
	move.l	d6,d0
	bra.b	AEDLineCustom

;---- Dump one ASCII line (Edit layout)
;-- input:	d0 - address
;--	d2 - 0/$0a -/+ return after printed line
;----
ASCIIEditDL	moveq	#0,d2	;force no return
AEDLineCustom	lea	TextLineBuffer(b),a0;get buffer
	bsr.w	PrintHexS	;print address
	move.b	#' ',(a0)+
	exg	d0,a0
	bsr.w	ASCIIDump
	exg.l	d0,a0
	lea	DumpBuffer(b),a1
.copybuffer	move.b	(a1)+,(a0)+	;copy dumped text to print-buffer
	bne.b	.copybuffer
	move.b	d2,-1(a0)
	clr.b	(a0)
	lea	TextLineBuffer(b),a0
	bra.w	Print

;----- Start of "Disassembler Dump Editor" -----------------------------------;
;diseditor;
DisDumpEdit:	clr.b	HideCursor(b)
	move.b	pr_BreakLineEd(b),DisBreaks(b)
	clr.b	LastCMDError(b)
	bsr.w	ClearScreen
	bsr.w	PrintFlags

	move.l	MemoryAddress(b),a0
	move.l	a0,-(a7)
	bsr.w	DisZUPScreenMid
	move.l	(a7)+,MemoryAddress(b)

DDELoopYPos	moveq	#9,d0
	move.b	pr_ShortAddress(b),d1
	beq.b	.notshort
	moveq	#7,d0
.notshort	move.b	pr_ShowCPU(b),d1
	beq.b	.nocpu
	addq.w	#2,d0
.nocpu	move.b	d0,DisEditO(b)
	move.b	d0,CurXPos(b)

	move.b	HexEditYPos(b),CurYPos(b)
	move.b	DisEditO(b),CurXPos(b)

	move.l	DisTableAddress(b),a0
	move.l	de_address(a0),MemoryAddress(b)

	moveq	#-1,d2
	bsr.w	PrintHeaderINCB	;print info WITHOUT CB
DisEditLoopE	bsr.w	PrintFlags

	tst.b	DiseditOneDown(b);assembled cmd -> scroll down
	beq.b	DisEditLoop
	clr.b	DiseditOneDown(b)
	bra.w	DDEOneDown

DisEditLoop	tst.b	ExitFlag(b)
	bne.w	DumpEditExit
	tst.b	DisplayHelp(b)
	beq.b	.nohelp
.dohelp	lea	EditorHelp,a0
	pea	DDELoopYPos(pc)
	moveq	#eh_Disassemble,d6;set Dis-mask
	bra.w	PrintHelp

.HELPRegs	bsr.w	DisplayRegs
	bra.b	DDELoopYPos

.nohelp	bsr.w	PasteText	;if any

;	moveq	#0,d0
;	move.b	CurKey(b),d0
	beq.b	DisEditLoop
	clr.b	CurKey(b)

	move.b	Control(b),d1

	cmp.b	#key_esc,d0	;ESC to exit
	beq.w	DumpEditExit

	cmp.b	#key_del,d0	;check for insert/overwrite shift
	bne.b	.ChangeInsert
	and.b	#kq_altmask,d1
	beq.w	DisEditorEdit	;start edit if normal delete
	not.b	InsertOverwrite(b);change mode
	bsr.w	PrintFlags
	bra.b	DisEditLoop

.ChangeInsert	cmp.b	#key_up,d0	;up
	beq.w	DDEUp

	cmp.b	#key_down,d0	;down
	beq.w	DDEDown

	cmp.b	#key_ret,d0	;return -> down
	beq.w	DDEDown

	cmp.b	#key_right,d0	;right
	beq.w	DisEditorEdit

	cmp.b	#key_help,d0	;help=display error
	bne.b	.help
	move.b	Control(b),d0
	btst	#kq_ctrl,d0	;if ctrl, show regs
	bne.b	.HELPRegs
	and.b	#kq_altmask,d0
	bne.b	.dohelp
	bsr.w	PrintLEInHeader
	bra.w	DisEditLoop

.help	clr.b	LastCMDError(b)
	move.b	d1,d2	;check AMIGA - shortcuts
	and.b	#kq_funcmask,d2
	bne.b	.checkshorts

	cmp.b	#' ',d0	;Check ' '-'z'
	blt.b	.notvalid
	cmp.b	#'z',d0
	ble.w	DisEditorEdit

.notvalid	bra.w	DisEditLoop


.checkshorts	move.b	d0,d3	;for store-mark check
	or.b	#$20,d0	;force lowercase

	move.b	d1,d2
	and.b	#kq_shiftmask,d2;shifted?
	bne.w	.shifted

	cmp.b	#'0',d3	;jump marks?
	blt.b	.checkon
	cmp.b	#'9',d3
	bgt.b	.checkon
	bsr.w	GetMarkAddress
	bra.w	DisCheckAdd

.checkon	cmp.b	#'.',d3
	beq.w	DisNextAdd

	cmp.b	#',',d3
	beq.w	DisPrevAdd

	cmp.b	#'a',d0	;a - Assign symbol
	beq.w	DisAssign

	cmp.b	#'b',d0	;b - start/end mark
	beq.w	DisStartMark

	cmp.b	#'j',d0	;j - Jump To Address
	beq.w	DisEditJump

	cmp.b	#'h',d0	;h - Hex Edit
	beq.w	HexDumpEdit

	cmp.b	#'l',d0	;l - Quick Jump To Last Address
	beq.w	DisLast

	cmp.b	#'n',d0	;n - ASCII Edit
	beq.w	ASCIIDumpEdit

	cmp.b	#'o',d0	;o - add offset to address
	beq.w	DisAddOffset

	cmp.b	#'p',d0	;p - Peeker Editor
	beq.w	PeekerEdit

	cmp.b	#'q',d0	;q - Quick jump
	beq.w	DisQuickJump

	cmp.b	#'x',d0	;x - Exit
	beq.w	DumpEditExit

	cmp.b	#'z',d0	;z - zap jump table
	bne.b	.nocmd
	st.b	NestedJumps(b)

.nocmd	bra.w	DisEditLoop

;---- check shifted commands
.shifted	moveq	#9,d1	;first check 0-9 = set mark
	lea	KeyTabShift+1(pc),a0
.checkstoremark	cmp.b	(a0)+,d3
	beq.b	.store
	dbra	d1,.checkstoremark
	bra.b	.checkonshift

.store	tst.b	d1	;roll numbers to get 0 first
	bne.b	.swapd
	moveq	#10,d1

.swapd	moveq	#'0'+9+1,d0
	sub.b	d1,d0
	pea	DDELoopYPos(pc)
	bra.w	PutMarkAddress

.checkonshift	cmp.b	#'<',d3
	beq.w	DisFirstAdd

	cmp.b	#'>',d3
	beq.w	DisLastAdd

	cmp.b	#'B',d3	;B - hide marked area
	beq.w	DisMarkAreaHide

	cmp.b	#'C',d3	;C - Copy area
	beq.w	DisCopyArea

	cmp.b	#'F',d3	;F - Fill NOPs
	beq.b	DisFillNOPs

	cmp.b	#'J',d3	;J - Jump contents
	beq.w	DisJumpContents

	cmp.b	#'Q',d3	;Q - Quick jump dest
	beq.w	DisQuickJumpDest

	cmp.b	#'X',d3
	beq.w	DumpEditExit

	bra.b	.nocmd


;---- Ask for offset and jump to MemAdd+Offset
DisAddOffset	lea	EditorOffsText(b),a0;ask offset
	bsr.w	GetHeaderInput
	bmi.w	DDELoopYPos
	lea	InputLine(b),a0
	bsr.w	GetValueCall
	bmi.w	DisEditError
	add.l	MemoryAddress(b),d0;and add to current pos
	bra.w	DisEditNestAdd

;---- Fill area with NOPs
DisFillNOPs	tst.b	MarkArea(b)
	bne.b	.OK
.noarea	moveq	#EV_NOAREASELECTED,d1
	bsr.w	HexEditErrorC
	bra.w	DisEditLoop

.OK	move.l	MarkAddress(b),d1;get area-limits
	move.l	MemoryAddress(b),d2
	tst.b	MarkArea(b)
	bmi.b	.static
	move.l	MarkAddressEnd(b),d2
.static	cmp.l	d1,d2	;check for order
	beq.w	EditHeaderOK	;skip if equal
	bgt.b	.swapem
	exg	d1,d2	;swap if needed
.swapem	move.l	d2,d3
	sub.l	d1,d3	;get fill size
	lsr.l	#1,d3
	beq.b	.zilch
	move.l	d1,a0
.fill	move.w	#$4e71,(a0)+
	subq.l	#1,d3
	bne.b	.fill
.zilch	bra.w	DisDumpEdit

;---- Copy marked area
DisCopyArea	bsr.w	EditCopyArea
	bra.b	DisUpdate

;---- Fill marked area
DisFillArea	bsr.w	EditFillArea

DisUpdate	bne.w	DisEditLoop;only update if operation performed
	bra.w	DisDumpEdit

;---- Start mark
DisStartMark	pea	DDELoopYPos(pc)
	bra.w	EditMarkBlock

;---- Keep marked area for search
DisMarkAreaHide	pea	DDELoopYPos(pc)
	bra.w	EditMarkHide

;---- Assign symbol to address
DisAssign	pea	DisEditLoopE(pc);use global routine
	bra.w	AssignSymbol

;---- Get previous hunt address
DisPrevAdd	moveq	#-1,d0
DisAddMain	bsr.w	GetHuntAddress
	bmi.w	DDELoopYPos
	bra.w	DisDumpEdit

;---- Get previous hunt address
DisNextAdd	moveq	#1,d0
	bra.w	DisAddMain

;---- Get first hunt address
DisFirstAdd	clr.b	ABPointer(b)
	moveq	#0,d0
	bra.b	DisAddMain

;---- Get last hunt address
DisLastAdd	move.b	AddressCount(b),d0
	beq.w	DDELoopYPos
	subq.b	#1,d0
	move.b	d0,ABPointer(b)
	moveq	#0,d0
	bra.b	DisAddMain

;---- Cursor one command up
DDEUp	move.w	d1,d0	;check for
	and.w	#kq_shiftmask,d0;page
	bne.w	DDEPageUp
	and.w	#kq_altmask,d1	;$1000
	bne.w	DDEPagesUp

DDEOneUp	move.l	DisTableAddress(b),a0
	moveq	#16,d0
	sub.w	d0,a0	;get prev command
	move.w	(a0),d0	;get #lines to move
	bpl.b	.correct
	add.w	d0,a0
	move.w	(a0),d0
.correct
DDEUpMain	move.l	de_address(a0),MemoryAddress(b);get new address
	move.w	d0,d7
	neg.l	d0
	bsr.w	ScrollScreen	;scroll screen down

	move.w	TextLines(b),d0	;scroll blockbuffer
	addq.w	#2,d0
	move.w	d0,d1
	asl.w	#4,d1
	lea	DisEditorTable(b),a0
	add.w	d1,a0	;bottom (dest)
	move.w	d7,d1
	asl.w	#4,d1
	move.l	a0,a1
	sub.w	d1,a1	;above bottom (source)
	sub.w	d7,d0	;now find len (in blocks)
	subq.w	#1,d0	;220394 shortcut method
.copyloop	move.l	-(a1),-(a0)	;copy 4 longs for each block
	move.l	-(a1),-(a0)
	move.l	-(a1),-(a0)
	move.l	-(a1),-(a0)
	dbra	d0,.copyloop

	move.w	d7,d0
.scancmdstart	tst.w	(a0)	;this line a command start?
	bpl.b	.commandstart
	add.w	#de_SizeOf,a0
	addq.w	#1,d7	;inc line counter
	bra.b	.scancmdstart

.commandstart	move.l	de_address(a0),a0;get actual address
	bsr.w	DisUpwards

	bra.w	DDELoopYPos

;---- page up
DDEPageUp	lea	DisEditorTable+de_SizeOf(b),a0;scan first unbroken command
.scancmdstart	tst.w	(a0)
	bpl.b	.commandstart
	add.w	#de_SizeOf,a0
	bra.b	.scancmdstart

.commandstart	move.l	de_address(a0),a0;and disassemble upwards from that add
	moveq	#0,d7
	move.w	TextLines(b),d7
	bsr.w	DisUpwards

	move.l	DisTableAddress(b),a0;then dis downwards until correct place
	move.l	de_address(a0),MemoryAddress(b);get new address
	tst.w	(a0)	;get #lines to move
	bpl.w	DDELoopYPos
	add.w	#de_SizeOf,a0
	moveq	#1,d0	;scroll one line
	tst.w	(a0)
	bpl.b	.ok
	moveq	#2,d0	;scroll two lines
	add.w	#de_SizeOf,a0

.ok	bra.w	DDEDownMain

;---- pages up
DDEPagesUp	move.l	MemoryAddress(b),a0
	sub.w	#$100,a0
DDEPageMain	pea	DDELoopYPos(pc)
	bra.w	DisZUPScreenMid

;---- page down
DDEPageDown	moveq	#0,d7
	move.w	TextLines(b),d7
	move.w	d7,d0	;find bottom most command(unbroken)
	subq.w	#1,d0
	asl.w	#4,d0
	lea	DisEditorTable(b),a0
	add.w	d0,a0
	move.w	(a0),d0
	bpl.b	.commandstart
	add.w	d0,a0
.commandstart	move.l	de_address(a0),a0
	moveq	#0,d1
	bsr.w	DisDownwards

	move.l	DisTableAddress(b),a0
	move.l	de_address(a0),MemoryAddress(b);get new address
	move.w	(a0),d0	;get #lines to move
	bpl.w	DDELoopYPos

	add.w	d0,a0	;find correct entry
	neg.w	d0
	lsr.w	#4,d0	;and how many lines to move
	bra.w	DDEUpMain


;---- pages down
DDEPagesDown	move.l	MemoryAddress(b),a0
	add.w	#$100,a0
	bra.b	DDEPageMain

;---- Move down
DDEDown	move.w	d1,d0	;check for
	and.w	#kq_shiftmask,d0;page
	bne.b	DDEPageDown
	and.w	#kq_altmask,d1	;$100
	bne.b	DDEPagesDown

;---- Cursor one command down
DDEOneDown	move.l	DisTableAddress(b),a0
	move.w	(a0),d0	;get #lines to move
	move.w	d0,d1
	asl.w	#4,d1
	add.w	d1,a0
DDEDownMain	move.l	de_address(a0),MemoryAddress(b);get new address
	move.w	d0,d7
	bsr.w	ScrollScreen	;scroll screen up

	lea	DisEditorTable(b),a0;top (dest)
	move.w	d7,d1
	asl.w	#4,d1
	lea	(a0,d1.w),a1	;below top (source)
	move.w	TextLines(b),d0	;find loop count
	subq.w	#1,d0
	sub.w	d7,d0
.copyloop	move.l	(a1)+,(a0)+	;copy 4 longs for each block
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbra	d0,.copyloop

	addq.w	#1,d7

	moveq	#0,d6
	move.w	TextLines(b),d6
	sub.w	d7,d6

	sub.w	#de_SizeOf,a0	;find first unbroken command
.scancmdstart	tst.w	(a0)
	bpl.b	.ok
	sub.w	#de_SizeOf,a0
	subq.w	#1,d6
	addq.w	#1,d7
	bra.b	.scancmdstart

.ok	move.l	de_address(a0),a0
	move.l	d6,d1
	bsr.w	DisDownwards

	bra.w	DDELoopYPos

;---- Jump to contents of current address
DisJumpContents	move.l	MemoryAddress(b),a0
	move.l	(a0),d0	;get current data
	bra.b	DisEditNestAdd	;and jump

;---- Quickjump to destination EA
DisQuickJumpDest
	move.l	DisTableAddress(b),a0

	move.w	de_flags(a0),d0
	btst	#de_DValid,d0
	beq.b	DisQuickJump	;if no dest, check for source

	move.l	de_dest(a0),d0	;else get address and jump
	bra.b	DisEditNestAdd


;---- Quickjump to EA
DisQuickJump	move.l	DisTableAddress(b),a0
	move.w	de_flags(a0),d0
	btst	#de_SValid,d0
	beq.w	DDELoopYPos	;no fail text, just return

	move.l	de_source(a0),d0;get address and jump
	bra.b	DisEditNestAdd

;---- Get address and jump
DisEditJump	lea	EditorJumpText(b),a0
	bsr.w	GetHeaderInput
	bne.w	DDELoopYPos	;skip if fail
	lea	InputLine(b),a0
	bsr.w	GetValueCall
	bmi.b	DisEditError

;---- Nest MemoryAddress in table and jump to D0
DisEditNestAdd	moveq	#EV_JUMPTABLEFULL,d1;check for full table
	cmp.b	#MaxNested-1,NestedJumps(b)
	beq.w	DisEditError
	addq.b	#1,NestedJumps(b);nest address in list
	moveq	#0,d1
	move.b	NestedJumps(b),d1
	asl.w	#2,d1
	move.l	MemoryAddress(b),a0
	lea	NestedJMPTable(b),a1
	move.l	a0,(a1,d1.w)

DisCheckAdd	tst.b	pr_ShortAddress(b)
	beq.b	.noshort
	and.l	#$ffffff,d0	;fix to 24 bit
.noshort	move.l	d0,MemoryAddress(b)
	bra.w	DisDumpEdit

;---- Jump to last nested address
DisLast	moveq	#EV_NONESTEDADDS,d1
	move.b	NestedJumps(b),d0;any last?
	bmi.b	DisEditError
	subq.b	#1,NestedJumps(b);yes, kill it
	asl.w	#2,d0
	lea	NestedJMPTable(b),a2
	move.l	(a2,d0.w),d0	;and jump
	bra.b	DisCheckAdd

DisEditError	pea	DisEditLoopE(pc)
DisEditErrorC	move.w	d1,LastErrorNumber(b);store error number
	st.b	LastCMDError(b)	;and flag error
	bra.w	PrintLEInHeader


;---- Dump 1 screen from middle
;-- input:	a0 -	Address of middle command
;----
DisZUPScreenMid	move.l	a0,-(a7)
	moveq	#0,d7
	move.b	HexEditYPos(b),d7
	bsr.b	DisUpwards
	move.l	(a7)+,a0

DisZUPScreenDown		;a0 - address 
	moveq	#0,d7
	move.w	TextLines(b),d7;find #lines to print
	moveq	#0,d1
	move.b	HexEditYPos(b),d1
	sub.w	d1,d7	;d7 = lines below

	bra.w	DisDownwards

;---- Disassemble upwards
;-- Input:	d7 -	Start line (and length)
;--	a0 -	Address of next command (!)
;----
DisUpwards	move.l	a0,DisassemBase(b)
	move.b	d7,CurYPos(b)
	lea	DisEditorTable(b),a2
	move.w	d7,d0
	asl.w	#4,d0
	add.w	d0,a2

DisUpLoop	moveq	#30,d6	;disassemble extra for better result

	move.b	pr_LongUpDis(b),d0
	beq.b	.nolongcmds

	moveq	#50,d6	;long disassembly. Start from 22
			;only go 22 back. Chance of seeing
			;long cmds are very little

.nolongcmds	move.l	DisassemBase(b),a0;get baseaddress
	sub.w	d6,a0	;reposition
	move.b	pr_ShortAddress(b),d0
	beq.b	.trynextoffset
	move.l	a0,d0
	and.l	#$ffffff,d0	;only 24bit operation
	move.l	d0,a0

.trynextoffset	moveq	#0,d0	;don't produce output
	moveq	#0,d1

	move.b	DisWidth(b),d1
	grcall	DisAssemble

	move.l	a0,d2	;last disassembled address

	move.l	MemoryAddress(b),a0
	cmp.l	DisassemBase(b),a0
	beq.b	.goon	;if match accept disassembly
	bgt.b	.decreasedist

	move.l	a0,d0
	sub.l	d2,d0
	cmp.w	#2,d0	;if only 1 word get to next
	beq.b	.decreasedist

.trynextoffsetl	moveq	#0,d0	;don't produce output
	moveq	#0,d1

	move.b	DisWidth(b),d1
	grcall	DisAssemble

	move.l	a0,d2	;last disassembled address

	move.l	MemoryAddress(b),a0

	cmp.l	DisassemBase(b),a0
	beq.b	.gooncheck	;if match accept disassembly

	blt.b	.trynextoffsetl	;continue if base not exceeded

.decreasedist	subq.w	#2,d6	;if no luck try shorter command
	bne.b	.nolongcmds	;if len=0 accept last disassembly
	bra.w	.goon

.gooncheck	tst.b	NotValidMnem(b)
	bne.b	.decreasedist	;don't accept disassembly fail
			;unless it is the last option

.goon	move.l	d2,a0
	moveq	#-1,d0	;produce output
	moveq	#0,d1
	move.b	DisWidth(b),d1

	grcall	DisAssemble

	move.l	a0,DisassemBase(b)

	move.w	d1,d2
	asl.w	#4,d2
	sub.w	d2,a2	;get back in table
	move.w	d1,de_lines(a2)
	move.l	a0,de_address(a2)

	bsr.w	GetSDEAs

	move.w	d0,de_flags(a2)

	moveq	#0,d3
	move.b	CurYPos(b),d3
	sub.w	d1,d3
	move.b	d3,NextYPos(b)

	move.w	d0,d6	;flags in d6
	lea	de_SizeOf(a2),a1
	move.w	d1,d5	;count now in d5
	move.w	d5,d4	;and d4
	subq.w	#1,d1
	beq.b	.noneed	;put backtrack offsets if needed
	move.w	#-de_SizeOf,de_lines(a1)
	move.l	a0,de_address(a1);to ease understanding when reading buffer
	subq.w	#1,d1
	beq.b	.noneed
	move.w	#-2*de_SizeOf,de_lines+de_SizeOf(a1)
	move.l	a0,de_address+de_SizeOf(a1)

.noneed
	move.l	a0,d0	;print address
	lea	TextLineBuffer(b),a0
	bsr.w	PrintHexS2
	move.b	#' ',(a0)+

	move.b	pr_ShowCPU(b),d0
	beq.b	.noCPUInfo
			;Check CPU and print letter
	move.b	#' ',(a0)+	;plus space

.noCPUInfo	move.l	a0,BreakOffset(b)
	move.l	a0,a1
	lea	DumpBuffer(b),a0
	btst	#de_Double,d6;check two lines command
	bne.w	DUTwoLines

DUGettextloop	move.b	(a0)+,(a1)+
	bne.b	DUGettextloop
	subq.w	#1,a1

;	move.b	pr_Indirect(b),d0
;	beq.b	DUResume
;fill s/d addresses on here (use pc_xpos)


DUResume	move.b	#pc_CLRRest,(a1)+
	clr.b	(a1)
	lea	TextLineBuffer(b),a0
	cmp.w	d4,d7	;#lines needed>space on screen
	bpl.b	.printok	;if not, print
	subq.w	#1,d4	;dec needed lines
.findnextline	tst.b	(a0)+	;else put in buffer
	bne.b	.findnextline
	bra.b	DUPutBreak

.printok	move.l	d3,d0
	move.b	d3,CurYPos(b)
	clr.b	CurXPos(b)
	bsr.w	PrintLine

DUPutBreak	addq.w	#1,d3
	btst	#de_Break,d6	;print breakline? (will always have space)
	beq.b	.nobreak
	move.l	BreakOffset(b),a1;put breakline
	moveq	#BreakLineLen-1,d0
.copybreak	move.b	#'=',(a1)+
	dbra	d0,.copybreak
	move.b	#pc_CLRRest,(a1)+
	clr.b	(a1)
	lea	TextLineBuffer(b),a0
	move.l	d3,d0
	move.b	d3,CurYPos(b)
	clr.b	CurXPos(b)
	bsr.w	PrintLine

.nobreak	move.b	NextYPos(b),CurYPos(b)
	sub.w	d5,d7	;more space?
	beq.b	.exit
	bpl.w	DisUpLoop

.exit	clr.b	CurYPos(b)
	clr.b	CurXPos(b)	;put cursor in top
	rts

;disassembly takes two lines
DUTwoLines	
.Gettextloop	move.b	(a0)+,(a1)+	;copy 1st line to buffer
	bpl.b	.Gettextloop
	move.l	a0,-(a7)
	subq.w	#1,a1

;	move.b	pr_Indirect(b),d0;set s if wanted
;	beq.b	.nosd
;fill s address on here (use pc_xpos)
;	nop

.nosd	move.b	#pc_CLRRest,(a1)+;add codes
	clr.b	(a1)
	lea	TextLineBuffer(b),a0
	cmp.w	d4,d7	;print or put in buffer?
	bpl.b	.doprint
.findnextline	tst.b	(a0)+
	bne.b	.findnextline
	subq.w	#1,d4	;dec needed lines
	bra.b	.next

.doprint	move.l	d3,d0
	move.b	d3,CurYPos(b)
	clr.b	CurXPos(b)
	bsr.w	PrintLine

.next	addq.w	#1,d3
	move.l	BreakOffset(b),a1;put next line
	moveq	#DisColTab-1,d0
.clearcmd	move.b	#' ',(a1)+
	dbra	d0,.clearcmd

	move.l	(a7)+,a0
.getrest	move.b	(a0)+,(a1)+
	bne.b	.getrest
	subq.w	#1,a1

	bra.w	DUResume

;---- Get EA fields from disassembled cmd. Set flags in d0
GetSDEAs	lea	de_source(a2),a3;get S/D EAs copied
	moveq	#de_SValid,d6
	tst.b	EADataS+EAD_eavalid(b)
	beq.b	.nosource
	bset	d6,d0	;set source flag
	move.l	EADataS+EAD_ea(b),(a3)+
	moveq	#de_DValid,d6
.nosource	tst.b	EADataD+EAD_eavalid(b)
	beq.b	.nodest
	bset	d6,d0
	move.l	EADataD+EAD_ea(b),(a3)
.nodest	rts

;---- Disassemble downwards
;-- Input:	d1	- Start YPos
;--	d7	- #text lines
;--	a0	- Address (will be returned)
;----
DisDownwards	move.l	a0,-(a7)
	move.w	d1,d0
	asl.w	#4,d0
	lea	DisEditorTable(b),a2
	add.w	d0,a2	;get to correct place in table
	move.b	d1,CurYPos(b)
DisDownLoop	moveq	#-1,d0	;output
	moveq	#0,d1
	move.b	DisWidth(b),d1
	grcall	DisAssemble
	move.w	d1,de_lines(a2)
	move.l	a0,de_address(a2)

	bsr.b	GetSDEAs

	move.w	d0,de_flags(a2)

	move.w	d0,d6	;save flags in d6

	add.w	#de_SizeOf,a2	;get to next block
	subq.w	#1,d1	;check if should be fixed
	beq.b	.noneed
	move.w	#-(de_SizeOf),de_lines(a2)
	move.l	a0,de_address(a2)
	add.w	#de_SizeOf,a2	;get to next block
	subq.w	#1,d1
	beq.b	.noneed	;check for triple line
	move.w	#-2*de_SizeOf,de_lines(a2)
	move.l	a0,de_address(a2)
	add.w	#de_SizeOf,a2	;get to next block
.noneed
	move.l	a0,d0	;print address
	lea	TextLineBuffer(b),a0
	bsr.w	PrintHexS2
	move.b	#' ',(a0)+

	move.b	pr_ShowCPU(b),d0
	beq.b	.noCPUInfo
			;Check CPU and print letter
	move.b	#' ',(a0)+	;plus space

.noCPUInfo	move.l	a0,BreakOffset(b)
	move.l	a0,a1
	lea	DumpBuffer(b),a0
	btst	#de_Double,d6;check two lines command
	bne.w	DETwoLines

DEGettextloop	move.b	(a0)+,(a1)+
	bne.b	DEGettextloop
	subq.w	#1,a1

	move.b	pr_Indirect(b),d0
	beq.b	.doo
;fill s/d addresses on here (use pc_xpos)
	nop

.doo	move.b	#pc_CLRRest,(a1)+
	clr.b	(a1)
DEResume	lea	TextLineBuffer(b),a0
	moveq	#0,d0
	move.b	CurYPos(b),d0
	clr.b	CurXPos(b)
	bsr.w	PrintLine
	addq.b	#1,CurYPos(b)

DEPutBreak	btst	#de_Break,d6	;print breakline?
	beq.b	.nobreak
	move.l	BreakOffset(b),a1;put breakline
	moveq	#BreakLineLen-1,d0
.copybreak	move.b	#'=',(a1)+
	dbra	d0,.copybreak
	move.b	#pc_CLRRest,(a1)+
	clr.b	(a1)

	lea	TextLineBuffer(b),a0

	subq.w	#1,d7	;check for more lines on screen
	beq.b	.BreakInBuf

	moveq	#0,d0
	move.b	CurYPos(b),d0
	clr.b	CurXPos(b)
	bsr.w	PrintLine
	addq.b	#1,CurYPos(b)
.nobreak	subq.w	#1,d7
	beq.b	.exit	;nothing in buffer

	move.l	MemoryAddress(b),a0;goto next command
	bra.w	DisDownLoop

.BreakInBuf

.exit	move.l	(a7)+,a0
	clr.b	CurYPos(b)
	clr.b	CurXPos(b)	;put cursor in top
	rts

DETwoLines	
.Gettextloop	move.b	(a0)+,(a1)+
	bpl.b	.Gettextloop
	move.l	a0,-(a7)
	subq.w	#1,a1

	move.b	pr_Indirect(b),d0
	beq.b	.nosd
	nop
;fill s addresses on here (use pc_xpos)

.nosd	move.b	#pc_CLRRest,(a1)+
	clr.b	(a1)
	lea	TextLineBuffer(b),a0
	moveq	#0,d0
	move.b	CurYPos(b),d0
	clr.b	CurXPos(b)
	bsr.w	PrintLine
	addq.b	#1,CurYPos(b)

	move.l	BreakOffset(b),a1;put next line
	moveq	#DisColTab-1,d0
.clearcmd	move.b	#' ',(a1)+
	dbra	d0,.clearcmd

	move.l	(a7)+,a0
.getrest	move.b	(a0)+,(a1)+
	bne.b	.getrest
	move.b	#pc_CLRRest,-1(a1)
	clr.b	(a1)

	lea	TextLineBuffer(b),a0

	subq.w	#1,d7	;check for space on screen
	bne.w	DEResume

.findnewline	tst.b	(a0)+
	bne.b	.findnewline	;put line in buffer
	moveq	#1,d7	;fake prepare breakline
	bra.w	DEPutBreak



;---- Editing in the DisEdit is handled in the routines below.
DisEditorEdit	move.b	d0,d6	;keep entry keypress

	moveq	#0,d0
	move.b	HexEditYPos(b),d0
	mulu	#80,d0
	moveq	#0,d1
	move.b	DisEditO(b),d1
	add.w	d1,d0

	move.l	DisTableAddress(b),a4

	lea	CharBuffer,a1
	add.w	d0,a1	;get char address of opcode start


	lea	InputLine(b),a0
	move.l	de_address(a4),d0;print address for assembler
	bsr.w	PrintHex8

	moveq	#' ',d0
	move.b	d0,(a0)+	;space from address
	moveq	#MaxMnemonicLen+3,d1
.copymnemonic	move.b	(a1)+,(a0)+	;copy mnemonic _space_
	dbra	d1,.copymnemonic

.findend	cmp.b	-(a0),d0
	beq.b	.findend

	addq.w	#2,a0
	cmp.b	(a1),d0	;is this a mnmemonic without s/d?
	bne.b	.getsourcedest	;nah, get source and dest text

	clr.b	-(a0)	;set endmark
	bra.b	.Line1Ready

.getsourcedest	moveq	#80-MaxMnemonicLen-7-1-4,d2;max copy length (4=safe)
	move.w	de_flags(a4),d1	;two line command?
	btst	#de_Double,d1
	beq.b	.NoXtraLine
	move.l	a1,a2
	add.w	#80+3,a1	;prepare for next line copier
			;skip "..,"

.copy1line	move.b	(a2)+,d1
	subq.w	#1,d2
	beq.b	.confused
	move.b	d1,(a0)+
	cmp.b	#',',d1	;We're looking for ",.."
	bne.b	.copy1line
	cmp.b	#'.',(a2)
	bne.b	.copy1line
	cmp.b	#'.',1(a2)
	bne.b	.copy1line

.confused
	moveq	#80-MaxMnemonicLen-7-1-4,d2;max copy length (4=safe)
.NoXtraLine	move.b	(a1)+,(a0)+
	subq.w	#1,d2
	beq.b	.ACEFAL	;another confuzing exit from a loop
	cmp.b	(a1),d0	;continue until we hit a space
	bne.b	.NoXtraLine
	bra.w	.EndOfInput
.ACEFAL
.EndOfInput	clr.b	(a0)

.Line1Ready	lea	InputLine+9(b),a0

	cmp.b	#3,d6	;was edit started with "right"?
	beq.b	.doedit
	cmp.b	#$7f,d6	;or delete
	beq.b	.doedit
	clr.b	(a0)	;else clear string

.doedit	moveq	#-1,d0
.countchars	addq.w	#1,d0
	tst.b	(a0)+
	bne.b	.countchars
	move.w	d0,DisEditMaxXPos(b)
	clr.w	DisEditCurXPos(b)

	move.b	d6,CurKey(b)	;set initial key

DEELPrint	moveq	#0,d0
	move.w	DisEditCurXPos(b),d0
	bsr.w	DisEditPrint

DisEditEditLoop	tst.b	ExitFlag(b)
	bne.w	DisEditEditExit

	bsr.w	PasteText	;if any
	beq.b	DisEditEditLoop
	clr.b	CurKey(b)

	move.b	Control(b),d1

	lea	InputLine+9(b),a4
	moveq	#0,d7
	move.w	DisEditCurXPos(b),d7

	cmp.b	#key_esc,d0	;ESC to exit
	beq.w	DisEditEditExit

	cmp.b	#key_help,d0	;help=display error
	bne.b	.help
	move.b	Control(b),d0
	btst	#kq_ctrl,d0	;if ctrl, show regs
	beq.b	DisEditEditLoop
.HELPRegs	bsr.w	DisplayRegs
	bra.b	DisEditEditLoop

.help	cmp.b	#key_del,d0	;check for insert/overwrite shift
	bne.b	.ChangeInsert
	move.b	d1,d0
	and.b	#kq_altmask,d0
	beq.w	DEEDelete
	not.b	InsertOverwrite(b);change mode
	bsr.w	PrintFlags
	bra.b	DisEditEditLoop

.ChangeInsert	cmp.b	#key_up,d0	;up
	beq.w	DEEHistoryUp

	cmp.b	#key_down,d0	;down
	beq.w	DEEHistoryDown

	cmp.b	#key_right,d0	;right
	beq.b	DEERight

	cmp.b	#key_left,d0	;left
	beq.w	DEELeft

	cmp.b	#key_bs,d0	;bs
	beq.w	DEEBackSpace

	cmp.b	#key_tab,d0	;tab
	bne.b	DEETabulator
	moveq	#' ',d0	;set tab=1 space

DEETabulator	cmp.b	#key_ret,d0	;return
	beq.w	DEEInput

	cmp.b	#' ',d0
	blt.w	DisEditEditLoop

	tst.b	InsertOverwrite(b);insert or overwrite?
	bne.b	.InsertChar

	move.b	d0,(a4,d7.w)	;overwrite
	addq.w	#1,DisEditCurXPos(b)
	bra.w	DEELPrint

.InsertChar	cmp.w	#160-10-4,DisEditMaxXPos(b);4 is for safety only!?!
	beq.w	DisEditEditLoop

	move.w	DisEditMaxXPos(b),d1
	lea	2(a4,d1.w),a1
	lea	1(a4,d1.w),a0
	sub.w	d7,d1	;get movecounter
.moveend	move.b	-(a0),-(a1)
	dbra	d1,.moveend

	move.b	d0,(a4,d7.w)

	addq.w	#1,DisEditMaxXPos(b)
	addq.w	#1,DisEditCurXPos(b)
	bra.w	DEELPrint

;---- Move right
DEERight	move.b	d1,d0
	and.b	#kq_shiftmask,d0
	beq.b	.OneStepRight
;also check alt
	move.w	DisEditMaxXPos(b),DisEditCurXPos(b);move far right
	bra.w	DEELPrint

.OneStepRight	cmp.w	DisEditMaxXPos(b),d7;OK to move right?
	beq.w	DisEditEditLoop
	addq.w	#1,DisEditCurXPos(b)
	bra.w	DEELPrint

;---- Move left
DEELeft	move.b	d1,d0
	and.b	#kq_shiftmask,d0
	beq.b	.OneStepLeft
;also check alt
	clr.w	DisEditCurXPos(b);move far right
	bra.w	DEELPrint

.OneStepLeft	tst.w	d7
	beq.w	DisEditEditLoop
	subq.w	#1,DisEditCurXPos(b)
	bra.w	DEELPrint

;---- backspace
DEEBackSpace	tst.w	d7
	beq.w	DisEditEditLoop

	and.b	#kq_shiftmask,d1
	beq.b	.OneStepLeft
;also check alt
	lea	(a4,d7.w),a0
	move.l	a4,a1
	clr.w	DisEditCurXPos(b)
	clr.w	DisEditMaxXPos(b)
	bra.b	DEELStringBack

.OneStepLeft	subq.w	#1,DisEditCurXPos(b)
DeleteStepLeft	lea	(a4,d7.w),a0
	lea	-1(a4,d7.w),a1
	subq.w	#1,d7
	move.w	d7,DisEditMaxXPos(b)

;----
DEELStringBack	moveq	#-1,d0
.movestringback	addq.w	#1,d0
	move.b	(a0)+,(a1)+
	bne.b	.movestringback
	add.w	d0,DisEditMaxXPos(b)

	bra.w	DEELPrint

DEEDelete	cmp.w	DisEditMaxXPos(b),d7
	beq.w	DisEditEditLoop
	and.b	#kq_shiftmask,d1
	beq.b	.DeleteOneChar

	move.w	d7,DisEditMaxXPos(b);delete to EOL
	clr.b	(a4,d7.w)	;set new EOL mark
	bra.w	DEELPrint

.DeleteOneChar	addq.w	#1,d7
	bra.b	DeleteStepLeft

;---- History
DEEHistoryUp	moveq	#1,d0
	bra.b	DEEHistoryMain

DEEHistoryDown	moveq	#-1,d0
DEEHistoryMain	and.w	#kq_altmask,d1
	beq.w	DisEditEditLoop
	bsr.w	GetHistory
	bmi.w	DisEditEditLoop	;if fail, pretend nothing happend :)

	lea	InputLine+9(b),a0
	moveq	#0,d0
.copyline	addq.w	#1,d0
	move.b	(a1)+,(a0)+
	bne.b	.copyline
	subq.w	#1,d0
	move.w	d0,DisEditMaxXPos(b)
	move.w	d0,DisEditCurXPos(b)

	bra.w	DEELPrint	;later cursor should be set to last line

;---- New command assembled
DisEditEditXNew	st.b	DiseditOneDown(b);fake a cursor down
	lea	InputLine+9(b),a1;It's only 80 chars but better than nil
	bsr.w	AddToHistory

;---- Return to diseditor
DisEditEditExit	move.l	DisTableAddress(b),a4
	move.l	de_address(a4),a0;get address
	bsr.w	DisZUPScreenDown
	bra.w	DDELoopYPos

;---- Get input processed at return
DEEInput	and.b	#kq_altmask!kq_shiftmask!kq_amigamask!1<<kq_ctrl,d1
	bne.b	DisEditEditExit	;skip
	lea	InputLine(b),a0
	grcall	Assemble
	cmp.w	#NoAssembly,d1	;nothing assembled
	beq.b	DisEditEditExit
	tst.w	d1
	beq.b	DisEditEditXNew	;exit if OK

	move.w	d1,LastErrorNumber(b)
	st.b	LastCMDError(b)	;flag error in last command
	bsr.w	PrintLEInHeader
	clr.b	ReprintHeader(b);don't reprint header
	bra.w	DisEditEditLoop

;---- Print text from InputLine to edit-line. Take care of too long text aot.
;-- Input:	d0 -	Cursor position in text (-9)
;----
;- Textstring must be NULL-terminated
;----
DisEditPrint	Push	d0-a4
	lea	InputLine(b),a4
	lea	TextLineBuffer(b),a0
	moveq	#0,d7
	move.b	DisEditO(b),d7
	move.w	d7,d4	;d7 will be new curxpos

	moveq	#9,d5	;offset in buffer
	moveq	#50,d6	;max xpos
	cmp.w	d6,d0
	bgt.b	.center
	add.w	d0,d7
	subq.w	#1,d4
	subq.w	#1,d5	;fix CLRRest problem if no text
	bra.b	.posset

.center	add.w	d6,d7	;center
	sub.w	d6,d0
	add.w	d0,d5	;move into buffer

.posset	add.w	d5,a4
	move.b	#pc_Pos,(a0)+;set position
	move.b	d4,(a0)+
	move.b	HexEditYPos(b),(a0)+

	moveq	#80-1-1,d6	;DBra-fix and space for >>-char
	sub.w	d4,d6	;get max chars+1
.copychars	move.b	(a4)+,(a0)+
	beq.b	.stringend
	dbra	d6,.copychars
	tst.b	(a4)	;is >> marker needed?
	beq.b	.stringend2
	move.b	#'>',(a0)+
	bra.b	.printstring

.stringend2	addq.w	#1,a0
.stringend	move.b	#pc_CLRRest,-1(a0)
.printstring	clr.b	(a0)

	lea	TextLineBuffer(b),a0
	bsr.w	Print

	move.b	d7,CurXPos(b)

	Pull	d0-a4
	rts

;----- Start of "Global Dump Editor Routines" --------------------------------;

;---- Get size (b/w/l = 0-2 / -1=break)
EditGetSize	lea	EditorSizeText(b),a0;get size from user
	bsr.w	PrintHeader
	clr.b	CurKey(b)
.waitforsize	tst.b	ExitFlag(b)	;make fast exit!
	bne.b	.break
	move.b	CurKey(b),d1
	beq.b	.waitforsize
	clr.b	CurKey(b)
	cmp.b	#key_esc,d1
	beq.b	.break
	moveq	#0,d7
	or.b	#$20,d1
	cmp.b	#'b',d1
	beq.b	.found
	moveq	#1,d7
	cmp.b	#'w',d1
	beq.b	.found
	moveq	#2,d7
	cmp.b	#'l',d1
	bne.b	.waitforsize
.found	rts

.break	moveq	#-1,d7	;flag error for fast exit
	rts

;---- Copy function (simple)
;-- Input:	;d1 - start	 (beware!)
;--	;d2 - end
;--	d0 - dest
;----
EditCopyArea	tst.b	MarkArea(b)
	bne.b	ECAOK
EditNoArea	moveq	#EV_NOAREASELECTED,d1
	bsr.w	HexEditErrorC
	moveq	#-1,d0
	rts

ECAOK	lea	DestAddText(b),a0
	bsr.w	GetHeaderInput
	bmi.b	EditHeaderBreak
	lea	InputLine(b),a0
	bsr.w	GetValueCall
	bmi.w	HexEditError
	move.l	MarkAddress(b),d1;get area-limits
	move.l	MemoryAddress(b),d2
	tst.b	MarkArea(b)
	bmi.b	.static
	move.l	MarkAddressEnd(b),d2
.static	cmp.l	d1,d2	;check for order
	beq.b	EditHeaderOK	;skip if equal
	bgt.b	.swapem
	exg	d1,d2	;swap if needed
.swapem	move.l	d2,d3
	sub.l	d1,d3	;get copy size
	cmp.l	d0,d1	;check inc/dec copy
	beq.b	EditHeaderOK
	bpl.b	.orderok
	cmp.l	d0,d2
	bmi.b	.orderok
	move.l	d2,a0
	add.l	d3,d0
	move.l	d0,a1
.copyreverse	move.b	-(a0),-(a1)	;copy from top
	subq.l	#1,d3
	bne.b	.copyreverse
	bra.b	EditHeaderOK

.orderok	move.l	d0,a1	;copy from bottom
	move.l	d1,a0
.copynormal	move.b	(a0)+,(a1)+
	subq.l	#1,d3
	bne.b	.copynormal

EditHeaderOK	moveq	#0,d0
	clr.b	MarkArea(b)	;clear when operation is performed
	rts


;---- Exit for aborted funcs
EditHeaderBreak	lea	UserBreakTextH(b),a0
	bsr.w	PrintHeader	
	moveq	#-1,d0
	rts

;---- Fill Area
EditFillArea	tst.b	MarkArea(b)
	beq.b	EditNoArea

	bsr.w	EditGetSize
	tst.w	d7
	bmi.b	EditHeaderBreak

	lea	FillValueText(b),a0
	bsr.w	GetHeaderInput
	bmi.b	EditHeaderBreak
	lea	InputLine(b),a0
	bsr.w	GetValueCall
	bmi.b	EditHeaderBreak

	move.l	MarkAddress(b),d1;get area-limits
	move.l	MemoryAddress(b),d2
	tst.b	MarkArea(b)
	bmi.b	.static
	move.l	MarkAddressEnd(b),d2
.static	cmp.l	d1,d2	;check for order
	beq.b	EditHeaderOK	;skip if equal
	bgt.b	.swapem
	exg	d1,d2	;swap if needed
.swapem	sub.l	d1,d2	;get fill size
	move.l	d1,a0	;get fill address
	tst.b	d7
	bne.b	.bytes
.fillbytes	move.b	d0,(a0)+
	subq.l	#1,d2
	bne.b	.fillbytes
	bra.b	EditHeaderOK

.bytes	cmp.w	#1,d7	;word?
	bne.b	.dolongs
	move.b	d0,d1
	lsr.w	#8,d0
.dowords	move.b	d0,(a0)+
	subq.l	#1,d2
	beq.b	.done
	move.b	d1,(a0)+
	subq.l	#1,d2
	bne.b	.dowords
.done	bra.b	EditHeaderOK

.dolongs	move.b	d0,d4
	lsr.l	#8,d0
	move.b	d0,d3
	lsr.l	#8,d0
	move.b	d0,d1
	lsr.w	#8,d0
.longloop	move.b	d0,(a0)+
	subq.l	#1,d2
	beq.b	.done
	move.b	d1,(a0)+
	subq.l	#1,d2
	beq.b	.done
	move.b	d3,(a0)+
	subq.l	#1,d2
	beq.b	.done
	move.b	d4,(a0)+
	subq.l	#1,d2
	bne.b	.longloop
	bra.b	.done


;---- Start/End area marking - may be called by search/fill routines
EditMarkBlock	tst.b	MarkArea(b)	;if on -> off
	bmi.b	.endmark
	move.l	MemoryAddress(b),MarkAddress(b);else flag...
	move.b	#-1,MarkArea(b)	;starting mark
	clr.b	MarkAreaValid(b)
	rts

.endmark	move.l	MemoryAddress(b),MarkAddressEnd(b)
	move.b	#1,MarkArea(b)	;flag searcharea OK
	st.b	MarkAreaValid(b)
	rts

;---- Show/Hide marked block
EditMarkHide	move.b	MarkArea(b),d0
	beq.b	.useold	;use old if NULL
	clr.b	MarkArea(b)
	rts

.useold	tst.b	MarkAreaValid(b)
	beq.b	.notvalid
	move.b	#1,MarkArea(b)	;flag searcharea OK
.notvalid	rts

;---- Call to get area printed (for header)
;-- Input:	a0	- Text buffer
;----
EditPrintArea	tst.b	MarkArea(b)
	beq.b	.noarea
	move.b	#' ',d0	;put spaces
	move.b	d0,(a0)+
	move.b	d0,(a0)+
	move.b	d0,(a0)+
	move.b	d0,(a0)+
	move.l	MarkAddress(b),d0;get area-limits
	moveq	#1,d3	;used to figure out which is dynamic
	swap	d3
	move.l	MemoryAddress(b),d2
	tst.b	MarkArea(b)	;only use MA if defining. Not when static
	bmi.b	.static
	move.l	MarkAddressEnd(b),d2
	move.w	#1,d3	;2nd address is also static
.static	cmp.l	d0,d2	;check for order
	bge.b	.swapem
	exg	d0,d2	;swap if needed
	swap	d3
.swapem	swap	d3
	tst.w	d3
	bne.b	.print1
	move.b	#'>',(a0)+	;mark dynamic number with >x<
.print1	bsr.w	PrintHexS
	tst.w	d3
	bne.b	.print2
	move.b	#'<',(a0)+
.print2
	move.b	#' ',(a0)+
	move.b	#'-',(a0)+
	move.b	#' ',(a0)+
	move.l	d2,d0
	swap	d3
	tst.w	d3
	bne.b	.print3
	move.b	#'>',(a0)+
.print3	bsr.w	PrintHexS
	tst.w	d3
	bne.b	.print4
	move.b	#'<',(a0)+
.print4
.noarea	rts

;---- ASCII Dump one line in header (only 32 bytes)
HeaderASCIIDump	bsr.w	ASCIIDump
	lea	DumpBuffer(b),a1
	move.b	#"'",49(a1)	;only 32 bytes
	clr.b	50(a1)
	bra.b	HeaderDumpMain

;---- Hex Dump one line in header
HeaderHexDump	bsr.w	HexDump	;get hexdump to buffer
	lea	DumpBuffer(b),a1
.findascii	cmp.b	#"'",(a1)+
	bne.b	.findascii
	clr.b	-1(a1)
	bra.b	HeaderDumpMain

;---- Disassemble one line in header
HeaderDisassem	bclr	#0,d0	;fix add to even
	move.l	d0,a0
	moveq	#-1,d0	;get output
	moveq	#40,d1	;not correct header size!
	move.l	MemoryAddress(b),-(a7)
	grcall	DisAssemble
	move.l	(a7)+,MemoryAddress(b)
HeaderDumpMain	move.l	a0,d0
	lea	TextLineBuffer(b),a0;print address
	bsr.w	PrintHexS
	move.b	#' ',(a0)+
	move.b	#' ',(a0)+
	lea	DumpBuffer(b),a1;add disassembly
.loop	move.b	(a1)+,(a0)+
	bne.w	.loop
	lea	TextLineBuffer(b),a0
	clr.b	MaxHeadChars(a0);skip border violating letters
	bra.w	PrintHeader	;and print

;---- Exit call for dump editors
DumpEditExit:	lea	HeaderText(b),a0;print standard header
	bsr.w	PrintHeader
	pea	NoPrompt(pc)
	move.b	Control(b),d0
	and.b	#kq_shiftmask,d0;if shifted no restore
	beq.b	.restorescreen
	bra.w	CursorToBOS

.restorescreen	lea	EditCharBack,a0;restore screen to pre-entry state
	move.w	EditPosBack(b),d7
	bra.w	PrintScreen	;get backup printed

;---- Find next/prev address in find buffer
;-- Input :	d0	-	1/-1 = next/prev
GetHuntAddress	Push	d2/a0
	moveq	#-1,d1
	move.b	AddressCount(b),d2
	beq.b	.exit	;no addresses
	add.b	d0,ABPointer(b)
	bpl.b	.checkmax
	subq.b	#1,d2
	move.b	d2,ABPointer(b)
	bra.b	.checked

.checkmax	cmp.b	ABPointer(b),d2
	bne.b	.checked
	clr.b	ABPointer(b)

.checked	moveq	#0,d0
	move.b	ABPointer(b),d0
	asl.w	#2,d0
	lea	AddressBuffer1(b),a0
	move.l	(a0,d0.w),MemoryAddress(b)
	moveq	#0,d1
.exit	Pull	d2/a0
	tst.w	d1
	rts

;---- Assign symbol
AssignSymbol	lea	TextLineBuffer(b),a0;print initial text
	lea	AssignText(b),a1
.copytxt	move.b	(a1)+,(a0)+
	bne.b	.copytxt
	subq.w	#1,a0
	move.l	MemoryAddress(b),d0
	bsr.w	PrintHexS	;and address
.copyrest	move.b	(a1)+,(a0)+
	bne.b	.copyrest
	lea	TextLineBuffer(b),a0;then get input
	bsr.w	GetHeaderInput
	bne.b	.skip
	lea	InputLine(b),a0
	bsr.w	GetSymbolName	;extract name
	bmi.w	HexEditErrorC
	move.l	MemoryAddress(b),d0
	bsr.w	MakeNewSymbol	;and add to table
	bmi.w	HexEditErrorC
	lea	TextLineBuffer+1(b),a0;+1 to skip return
	bra.w	PrintHeader	;print added to table
.skip	lea	AssignSkipText(b),a0
	bra.w	PrintHeader

;---- Get Mark (0-9) address
;-- input : d0 - '0'-'9'
;-- output: d0 - address
;----
GetMarkAddress	sub.b	#'0',d0	;get number
	and.w	#$f,d0
	asl.w	#2,d0	;calc offset
	lea	MarkTable(b),a0
	move.l	(a0,d0.w),d0	;get address
	rts

;---- Put MemoryAddress to Mark (0-9)
;-- input : d0 - '0'-'9'
;----
PutMarkAddress	sub.b	#'0',d0	;get number
	and.w	#$f,d0
	asl.w	#2,d0	;calc offset
	lea	MarkTable(b),a0
	move.l	MemoryAddress(b),(a0,d0.w);store memoryaddress
	rts

;----------------------------------------------------
;- Name	: Repeat Command
;- Description	: Controls repeat of last command (dump)
;- Notes	:
;----------------------------------------------------
;- 270893.0000	Included in routine index.
;----------------------------------------------------

;---- table for repeat of commands
	rsreset
RC_NoCommand	rs.l	1
RC_Disassemble	rs.l	1
RC_HexDump	rs.l	1
RC_ASCIIDump	rs.l	1

RepeatCmd	move.w	LastCommand(b),d0;jump to last executed command
	jmp	.RepeatTab(pc,d0)
;w;
.RepeatTab	bra.w	NoPrompt
	bra.w	DisassemLinesR
	bra.w	HexDumpLinesR
	bra.w	ASCIIDumpLinesR

;----------------------------------------------------
;- Name	: Interfaces
;- Description	: Routines calling other routines for the user
;- Notes	:
;----------------------------------------------------
;- 270893.0000	Included in routine index.
;- 021093.0001	Added Jump and Exit To
;----------------------------------------------------

;---- Clear the screen
ClearScreenCMD	pea	NoPromptNoLF(pc)
	bra.w	ClearScreen

;---- Call subroutine
SubCall	moveq	#et_Call,d2
SubCallMain	bsr.w	GetValueSkip
	move.l	d0,SubCallAddress;FlushCache will be called before
			;the command is reached.
	move.b	d2,SubCallMode(b)
	rts

SubCallExit	moveq	#et_CallExit,d2
	bra.b	SubCallMain

;---- Exit code
KillExit	move.l	#'RIP!',$f00000	;prevent reentry
	bsr.w	ClearSystemReset
MonitorExit	move.w	LastErrorNumber(b),d7;debug;
	bsr.w	GetValueCall
	bne.b	.checkerrors
	bsr.b	AlterExitAddress

.exit	move.w	d7,LastErrorNumber(b);debug;
	rts

.checkerrors	cmp.w	#EV_NOVALUE,d1
	beq.b	.exit	;print if not 'novalue'
	bra.w	PrintError

;---- Alter the exit address (don't do this local!)
AlterExitAddress
	move.l	EntrySuperStack(b),a0;set new return address
	move.l	d0,2(a0)	;check for other stack-formats!
	rts

;----- Start of "CLI invoced Help " ------------------------------------------;
ShowHelp	lea	WhereIsHelpTxt(b),a0
	pea	NoPrompt(pc)
	bra.w	Print

;----------------------------------------------------
;- Name	: Resume
;- Description	: Resume broken command.
;- Notes	:
;----------------------------------------------------
;- 270893.0000	Included in routine index.
;- 310893.0000	Added FindResume
;- 181093.732	Added HuntBranchResume
;----------------------------------------------------
Resume	moveq	#EV_NOTHINGTORESUME,d1
	moveq	#0,d0
	move.b	ResumeCommand(b),d0;any command to resume?
	bmi.w	PrintError
	asl.w	#2,d0
	jmp	.ResumeTable(pc,d0.w)
;w;
.ResumeTable	bra.w	FindTextResume
	bra.w	FindResume
	bra.w	HuntBranResume
	bra.w	HuntPCResume
	bra.w	CompareResume
	bra.w	NOTFindResume

;----------------------------------------------------
;- Name	: History Control.
;- Description	: Controls line-history.
;- Notes	:
;----------------------------------------------------
;- 270893.0000	Included in routine index.
;----------------------------------------------------

;---- Add line to history
;-- Input: a1 - line
;----
AddToHistory	Push	a0/a2
	lea	HistoryBufferEnd(pc),a2;scroll historybuffer
	lea	-80(a2),a0
	move.w	#(MaxHistory-1)*80/4-1,d0
.scrollhistory	move.l	-(a0),-(a2)
	dbra	d0,.scrollhistory

	lea	HistoryBuffer(pc),a0;clear line
	moveq	#80/4-1,d0
.clearline	move.l	#'    ',(a0)+
	dbra	d0,.clearline

	moveq	#78,d0	;max 79 letters (prompt not included)
	lea	HistoryBuffer(pc),a0
.copyline	move.b	(a1)+,(a0)+
	dbeq	d0,.copyline
	move.b	#' ',-1(a0)	;set space where 0 is
.full	lea	HistoryBuffer+79(pc),a0;put 0 in end
.findend	cmp.b	#' ',-(a0)
	beq.b	.findend
	clr.b	1(a0)
	move.b	#MaxHistory-1,HistoryPointer(b)
	st.b	HistoryCount(b)	;maybe perform count later on
	Pull	a0/a2
	rts

;---- Get Pointer to history line
;-- Input:	d0 - offset
;-- Output:	a1 - pointer to 0 terminated string
;----
GetHistory	tst.b	HistoryCount(b)
	bne.b	.Lines
	moveq	#-1,d1	;flag no lines
	rts

.Lines	add.b	d0,HistoryPointer(b);add offset
	moveq	#0,d1	;check position
	move.b	HistoryPointer(b),d1
	bpl.b	.checkupper
	moveq	#MaxHistory-1,d1;too low
.checkupper	cmp.b	#MaxHistory,d1
	bne.b	.checked
	moveq	#0,d1	;too high
.checked	move.b	d1,HistoryPointer(b);find actual pos
	mulu	#80,d1
	lea	HistoryBuffer(pc),a1
	add.w	d1,a1
	moveq	#0,d1
	tst.b	(a1)	;check for valid entry
	beq.b	GetHistory	;and exit if ok
	moveq	#0,d1
	rts

;---- Clear history
ClearHistory	clr.b	HistoryCount(b)	;flag no lines in buffer
	moveq	#MaxHistory-1,d0;clear all 1st letters to flag invalid
	lea	HistoryBuffer(pc),a0;lines
.clearloop	clr.b	(a0)
	add.w	#80,a0
	dbra	d0,.clearloop
	rts

HistoryBuffer	dcb.b	80*MaxHistory,0
HistoryBufferEnd		;(just to get size)



;----------------------------------------------------
;- Name	: FindText
;- Description	: Finds textstring in memory.
;- Notes	:
;----------------------------------------------------
;- 270893.0000	Included in routine index.
;- 041093	Fixed stackbug in (bufferfull) handler
;-	Implemented the "missing link" in the resume handling (enabling)
;----------------------------------------------------

;---- Find text in mem
;-- SYNTAX: ft [start] [end] <-[joker]> <c> [<'"text"'><"'text'">]
FindText	st.b	ResumeCommand(b);clear resume
	bsr.w	GetStartEnd	;get start & end

	move.l	d7,StartAddress(b)
	move.l	d6,EndAddress(b)

	moveq	#$20-1,d5
	move.b	pr_TextJoker(b),d4
	lea	FindTextBuffer(b),a1

	moveq	#0,d3
	moveq	#0,d2	;flag first letter in searchstring
	bsr.b	.SkipSpaces
	cmp.b	#'-',d0
	bne.b	.checkcase
	move.b	(a0)+,d4	;new joker

	bsr.b	.SkipSpaces
.checkcase	cmp.b	#'c',d0
	bne.b	.NoCase
	moveq	#1,d3
;	bra.w	.FindNext

.FindNext	bsr.b	.SkipSpaces
.NoCase	cmp.b	#'"',d0	;check string start
	beq.b	.TextStart
	cmp.b	#"'",d0
	bne.b	.StringEnd
.TextStart	move.b	(a0)+,d1	;get string
	beq.b	.FindIt
	cmp.b	d0,d1
	beq.b	.FindNext	;when end reached, check for new str
	tst.b	d2	;check for joker if first letter
	beq.b	.CheckJoker
.notjoker	move.b	d1,(a1)+
	dbra	d5,.TextStart	;until buffer's full
	bra.b	.FindIt

.SkipSpaces	cmp.b	#' ',(a0)+
	beq.b	.SkipSpaces
	move.b	-1(a0),d0
	rts

.CheckJoker	moveq	#1,d2
	cmp.b	d4,d1	;first letter = joker?
	beq.b	.TextStart	;if so, skip
	bra.b	.notjoker	;else store

.StringEnd	moveq	#EV_NOFINDDATA,d1;syntax error if not '/"
	cmp.w	#$20-1,d5
	beq.w	PrintError

.FindIt	moveq	#$20-2,d0
	sub.w	d5,d0	;calc len-1
	move.b	d0,FindLength(b)
	lea	FindTextBuffer(b),a1

	move.b	d3,FindCase(b)
	move.b	d4,FindJoker(b)

	move.l	a1,a2	;set null on joker-places
	lea	32(a2),a3	;;;;;DIRTY CODE!!!!!!!!!!!
.killjokers	cmp.b	(a2),d4
	bne.b	.Notjoker
	clr.b	(a2)	;zap it
.Notjoker	move.b	(a2)+,d2
	tst.b	d3
	beq.b	.casecheck2
	cmp.b	#'A',d2
	blt.b	.casecheck2
	cmp.b	#'Z',d2
	ble.b	.nocasecheck2
	cmp.b	#'a',d2
	blt.b	.casecheck2
	cmp.b	#'z',d2
	bgt.b	.casecheck2
.nocasecheck2	eor.b	#$20,d2	;change case
.casecheck2	move.b	d2,(a3)+
	dbra	d0,.killjokers

FindTextResume	move.l	StartAddress(b),d7
	move.l	EndAddress(b),d6
	move.l	d6,d0
	sub.l	d7,d0
	beq.b	.error
	bpl.b	.ok
.error	moveq	#EV_ILLEGALAREA,d1
	bra.w	PrintError

.ok	bsr.w	CalculateBar
	lea	ScanningText(b),a1
	lea	TextLineBuffer(b),a0
.copy1	move.b	(a1)+,(a0)+
	bne.b	.copy1
	subq.w	#1,a0
	move.l	d7,d0
	bsr.w	PrintHexS
	move.b	#'-',(a0)+
	move.l	d6,d0
	bsr.w	PrintHexS
.copy2	move.b	(a1)+,(a0)+
	bne.b	.copy2
	subq.w	#1,a0
	moveq	#0,d1
	move.b	FindLength(b),d1
	move.b	FindJoker(b),d2
	lea	FindTextBuffer(b),a1
.copytxt	move.b	(a1)+,(a0)+
	bne.b	.joker
	move.b	d2,-1(a0)
.joker	dbra	d1,.copytxt
	move.b	#'"',(a0)+
	move.b	#' ',(a0)+
	tst.b	FindCase(b)
	beq.b	.casein
	move.b	#'-',(a0)+	;set '-' if case in-sensitive
.casein	tst.l	UpdateTime(b)
	beq.b	.noLF
	move.b	#$0a,(a0)+
.noLF	clr.b	(a0)
	lea	TextLineBuffer(b),a0
	bsr.w	Print

	move.l	d7,a0
	moveq	#0,d0
	move.b	FindLength(b),d0

	lea	FindTextBuffer(b),a1
	move.b	32(a1),d5
	move.b	(a1)+,d1

	clr.b	AddressCount(b)	;set # of addresses in buffer to 0
	st.b	ABPointer(b)
	clr.b	FindFound(b)

	lea	AddressBuffer1(b),a4
	move.w	#MaxAddresses,LoopCounter(b)
	move.l	UpdateTime(b),d7;init progress timer

	subq.w	#1,d0	;check for single letter hunt
	bmi.w	.SingleLetter

.FindTextLoop	cmp.b	(a0),d1	;scan for first letter
	beq.b	.FoundFirstA
	cmp.b	(a0)+,d5
	beq.b	.FoundFirst
.ContinueScan	subq.l	#1,d7
	beq.b	.Progress1
.update1	cmp.l	d6,a0
	bne.b	.FindTextLoop
	cmp.w	#MaxAddresses,LoopCounter(b);any found?
	bne.w	.ScanComplete

.NoAddresses	lea	ScanCompletText(b),a0
	bsr.w	Print
	moveq	#EV_NOTFOUND,d1	;no!
	bra.w	PrintError

.Progress1	pea	.update1(pc)
.Progress	tst.b	UserBreak(b)	;test for break
	bne.b	.Broken
	move.l	UpdateTime(b),d7
	beq.b	.noprint	;if 0 the function is disabled
	Push	d0-a4
	moveq	#'-',d0
	tst.b	FindFound(b)
	beq.b	.nothing
	moveq	#'+',d0
.nothing	clr.b	FindFound(b)
	bsr.w	PrintLetterR
	Pull	d0-a4
.noprint	rts

.FoundFirstA	addq.w	#1,a0
.FoundFirst	move.l	a0,a2
	move.l	a1,a3
	move.w	d0,d2	;#loops
.ScanRestLoop	move.b	(a2)+,d3
	move.b	(a3)+,d4
	beq.b	.skipjoker
 	cmp.b	d4,d3	;cmp
	beq.b	.skipjoker
	cmp.b	31(a3),d3	;check with possibly re-cased! (DIRTY)
	bne.b	.ContinueScan	;continue scan if not ok

.skipjoker	dbra	d2,.ScanRestLoop;check all letters

	bsr.w	.AddToBuffer
	subq.w	#1,LoopCounter(b)
	bne.b	.FindTextLoop	;continue till buffer is full

.FullBuffer	Push	a0
	lea	AddBufFullTxt(b),a0
	bra.b	.dotheprint

.Broken	addq.w	#4,a7	;skip caller address
	Push	a0
	lea	UserBreakText(b),a0
.dotheprint	bsr.w	Print
	Pull	a0
	move.l	a0,d0
	move.l	a0,StartAddress(b)
	move.b	#res_FindText,ResumeCommand(b)
	lea	TextLineBuffer(b),a0
	bsr.w	PrintHexL	;print last processed address to buf
	clr.b	(a0)
	lea	LastAddressText(b),a0
	bsr.w	Print
	lea	TextLineBuffer(b),a0
	bsr.w	Print	;print it!
	bra.b	.fixlast

.Progress2	pea	.update2(pc)
	bra.w	.Progress

;-search single letter
.SingleLetter	cmp.b	(a0),d1
	beq.b	.FoundLetterA
	cmp.b	(a0)+,d5
	beq.b	.FoundLetter
	subq.l	#1,d7
	beq.b	.Progress2
.update2	cmp.l	d6,a0	;check till end-address
	bne.b	.SingleLetter
	cmp.w	#MaxAddresses,LoopCounter(b);any found
	beq.w	.NoAddresses

.ScanComplete	st.b	ResumeCommand(b);discontinue resuming
	lea	ScanCompletText(b),a0
	bsr.w	Print

.fixlast	move.w	#MaxAddresses,d0
	sub.w	LoopCounter(b),d0
	move.b	d0,AddressCount(b)

	bra.w	DumpAddresses

.FoundLetterA	addq.w	#1,a0
.FoundLetter	bsr.b	.AddToBuffer
	subq.w	#1,LoopCounter(b)
	bne.b	.SingleLetter
	bra.w	.FullBuffer

;-- add address to buffer (seq found)
.AddToBuffer	move.l	a0,d2
	subq.l	#1,d2
	move.l	d2,(a4)+	;put address in buffer
	st.b	FindFound(b)	;mark found
	rts

;----------------------------------------------------
;- Name	: Find data
;- Description	: Finds textstring in memory.
;- SYNTAX	: h [start] [end] [data]
;----------------------------------------------------
;- 310893.0000	Included in routine index.
;----------------------------------------------------
FindResume	clr.b	NOTHunting(b)
	bra.w	FindResumeEntry

NOTFindResume	st.b	NOTHunting(b)
	bra.w	FindResumeEntry

FindNOT	st.b	NOTHunting(b)
	bra.b	FindEntry

Find:	clr.b	NOTHunting(b)
FindEntry	st.b	ResumeCommand(b);clear resume
	bsr.w	GetStartEnd	;get start & end

	move.l	d7,StartAddress(b)
	move.l	d6,EndAddress(b)

	moveq	#$20-1,d5	;max search 32 bytes
	lea	FindTextBuffer(b),a1
	moveq	#0,d4
.GetHuntString	move.b	(a0)+,d2
	beq.b	.EvalString	;end of string
	cmp.b	#' ',d2
	beq.b	.GetHuntString
	moveq	#$f,d3	;set mask
	cmp.b	pr_TextJoker(b),d2;joker?
	bne.b	.joker
	moveq	#0,d3	;kill mask
	moveq	#0,d2
	bra.b	.gotnibble

.joker	cmp.b	#'0',d2
	blt.b	.EvalString
	cmp.b	#'9',d2
	ble.b	.gotnibble
	cmp.b	#'A',d2
	blt.b	.EvalString	;check but skip space
	cmp.b	#'F',d2
	ble.b	.hexnib
	cmp.b	#'a',d2
	blt.b	.EvalString	;check but skip space
	cmp.b	#'f',d2
	bgt.b	.EvalString
.hexnib	or.b	#$20,d2
	sub.b	#'a'-'0'-10,d2
.gotnibble	sub.b	#'0',d2	;sub to get nibble value
	and.w	#$f,d2
	asl.w	#4,d0
	asl.w	#4,d1
	or.w	d2,d0	;or to byte value
	or.w	d3,d1	;or to mask
	not.w	d4	;first pass?
	bmi.b	.GetHuntString
	move.b	d1,32(a1)	;store mask
	bne.b	.maskok	;no store if no mask
	cmp.w	#32-1,d5	;if first byte and no mask
	beq.b	.GetHuntString	;SKIP!
.maskok	move.b	d0,(a1)+	;then byte
	dbra	d5,.GetHuntString

.EvalString	move.w	d1,d3
	moveq	#EV_NOFINDDATA,d1
	moveq	#32-1,d2
	sub.w	d5,d2	;find len
	bmi.w	PrintError
	bne.b	.OnlyFirstNib
	tst.w	d4	;if no bytecount, check for 1 nibble
	bpl.w	PrintError
	moveq	#$f,d4
	and.w	d4,d3
	beq.w	PrintError
	and.w	d4,d0
	st.b	32(a1)	;store mask (always ~0)
	move.b	d0,(a1)	;then byte
	addq.w	#1,d2

.OnlyFirstNib	subq.w	#1,d2
	move.b	d2,FindLength(b)

FindResumeEntry	move.l	StartAddress(b),d7
	move.l	EndAddress(b),d6
	move.l	d6,d0
	sub.l	d7,d0
	beq.b	.error
	bpl.b	.ok
.error	moveq	#EV_ILLEGALAREA,d1
	bra.w	PrintError

.ok	bsr.w	CalculateBar

	lea	ScanningText(b),a1
	lea	TextLineBuffer(b),a0
.copy1	move.b	(a1)+,(a0)+
	bne.w	.copy1
	subq.w	#1,a0
	move.l	d7,d0
	bsr.w	PrintHexS
	move.b	#'-',(a0)+
	move.l	d6,d0
	bsr.w	PrintHexS
.copy2	move.b	(a1)+,(a0)+
	bne.w	.copy2
	subq.w	#2,a0
	tst.b	NOTHunting(b)
	beq.b	.noNOT
	lea	ScanNOTText(b),a1
.copy3	move.b	(a1)+,(a0)+
	bne.w	.copy3
	subq.w	#1,a0
.noNOT	move.b	#'$',(a0)
	moveq	#0,d0
	move.b	FindLength(b),d0
	lea	FindTextBuffer(b),a1
.printstring	move.b	32(a1),d2
	move.b	(a1)+,d1
	move.b	d1,d4
	lsr.b	#4,d4
	add.b	#'0',d4
	cmp.b	#'0'+10,d4
	blt.b	.ok3
	addq.w	#7,d4	;get to A-F
.ok3	move.b	d2,d3
	and.b	#$f0,d3
	bne.b	.joker
	moveq	#'?',d4
.joker	move.b	d4,(a0)+
	and.b	#$f,d1
	add.b	#'0',d1
	cmp.b	#'0'+10,d1
	blt.b	.ok2
	addq.w	#7,d1	;get to A-F
.ok2	and.b	#$0f,d2
	bne.b	.joker2
	moveq	#'?',d1
.joker2	move.b	d1,(a0)+
	dbra	d0,.printstring
	move.b	#pc_CLRRest,(a0)+
	tst.l	UpdateTime(b)
	beq.b	.noLF
	move.b	#$a,(a0)+
.noLF	clr.b	(a0)
	lea	TextLineBuffer(b),a0
	bsr.w	Print

	move.l	d7,a0
	moveq	#0,d0
	move.b	FindLength(b),d0

	lea	FindTextBuffer(b),a1
	move.b	32(a1),d5
	move.b	(a1)+,d1

	clr.b	AddressCount(b)	;set # of addresses in buffer to 0
	st.b	ABPointer(b)
	clr.b	FindFound(b)

	lea	AddressBuffer1(b),a4
	move.w	#MaxAddresses,LoopCounter(b)
	move.l	UpdateTime(b),d7;init progress timer

	tst.b	NOTHunting(b)	;wanna find NOT?
	bne.b	.FindNOT
	subq.w	#1,d0	;check for single letter hunt
	bmi.w	.SingleByte
	bra.b	.FindByteLoop

;---------- The routine below is used for NOT hunt!
.FindNOT	subq.w	#1,a1	;correct preread
	move.l	d0,-(a7)	;calc so bar is only updated
	moveq	#1,d1	;for each block!
	add.w	d0,d1	;must be .w!
	move.l	d1,d0
	move.l	EndAddress(b),d1
	sub.l	StartAddress(b),d1
	bsr.w	Divu32
	move.l	d1,d0
	bsr.w	CalculateBar	;get new bar timing.
	move.l	(a7)+,d0
	move.l	UpdateTime(b),d7;init progress timer

.FindNOTBlkLoop	move.l	a0,a2
	move.l	a1,a3
	move.w	d0,d1
.FindNOTLoop	move.b	(a2)+,d2	;get byte
	and.b	32(a3),d2	;use mask
	cmp.b	(a3)+,d2
	bne.b	.NOTOK	;bytes are equal - OK
	cmp.l	d6,a2
	beq.b	.FindNOTEnd
	dbra	d1,.FindNOTLoop
.FindNOTCont	subq.l	#1,d7	;make bar for each block!
	beq.b	.ProgressNOT
.updateNOT	lea	1(a0,d0.w),a0	;get to next block (not placed bfore progress)
	bra.b	.FindNOTBlkLoop

.FindNOTEnd	cmp.w	#MaxAddresses,LoopCounter(b);any found?
	bne.w	.ScanComplete
	bra.b	.NoAddresses

;---- sequence not equal! Add address to buffer
.NOTOK	exg	a0,a2	;store correct address
	bsr.w	.AddToBuffer
	exg	a0,a2
	subq.w	#1,LoopCounter(b)
	beq.w	.FullBuffer
	cmp.l	d6,a0	;next block beyond scan area?
	bmi.b	.FindNOTCont
	bra.b	.FindNOTEnd	;if yes, then end.

;-------- The routine below is used for normal byte hunt
.FindByteLoop	move.b	(a0)+,d2	;scan for first byte
	and.b	d5,d2	;use mask
	cmp.b	d1,d2
	beq.b	.FoundFirst
.ContinueScan	subq.l	#1,d7
	beq.b	.Progress1
.update1	cmp.l	d6,a0
	bne.b	.FindByteLoop
	cmp.w	#MaxAddresses,LoopCounter(b);any found?
	bne.w	.ScanComplete

.NoAddresses	lea	ScanCompletText(b),a0
	bsr.w	Print
	moveq	#EV_NOTFOUND,d1	;no!
	bra.w	PrintError

.ProgressNOT	pea	.updateNOT(pc)
	bra.b	.Progress
.Progress1	pea	.update1(pc)
.Progress	tst.b	UserBreak(b)	;test for break
	bne.b	.Broken
	move.l	UpdateTime(b),d7
	beq.b	.noprint	;if 0 the function is disabled
	Push	d0-a4
	moveq	#'-',d0
	tst.b	FindFound(b)
	beq.b	.nothing
	moveq	#'+',d0
.nothing	clr.b	FindFound(b)
	bsr.w	PrintLetterR
	Pull	d0-a4
.noprint	rts

.FoundFirst	move.l	a0,a2
	move.l	a1,a3
	move.w	d0,d2	;#loops
.ScanRestLoop	move.b	(a2)+,d3
	and.b	32(a3),d3	;mask
	cmp.b	(a3)+,d3	;cmp
	bne.b	.ContinueScan
	dbra	d2,.ScanRestLoop;check all letters

	bsr.w	.AddToBuffer
	subq.w	#1,LoopCounter(b)
	bne.b	.FindByteLoop	;continue till buffer is full

.FullBuffer	Push	a0
	lea	AddBufFullTxt(b),a0
	bra.b	.dotheprint

.Broken	addq.w	#4,a7	;skip caller address
	Push	a0
	lea	UserBreakText(b),a0
.dotheprint	bsr.w	Print
	moveq	#res_Find,d0
	tst.b	NOTHunting(b)
	beq.b	.setresume
	moveq	#res_NOTFind,d0
.setresume	move.b	d0,ResumeCommand(b)
	Pull	a0
	move.l	a0,d0
	move.l	a0,StartAddress(b)
	lea	TextLineBuffer(b),a0
	bsr.w	PrintHexL	;print last processed address to buf
	clr.b	(a0)
	lea	LastAddressText(b),a0
	bsr.w	Print
	lea	TextLineBuffer(b),a0
	bsr.w	Print	;print it!
	bra.b	.fixlast

.Progress2	pea	.update2(pc)
	bra.w	.Progress

;-search single letter
.SingleByte	move.b	(a0)+,d2
	and.b	d5,d2
	cmp.b	d2,d1
	beq.b	.FoundByte
	subq.l	#1,d7
	beq.b	.Progress2
.update2	cmp.l	d6,a0	;check till end-address
	bne.b	.SingleByte
	cmp.w	#MaxAddresses,LoopCounter(b);any found
	beq.w	.NoAddresses

.ScanComplete	lea	ScanCompletText(b),a0
	bsr.w	Print
	st.b	ResumeCommand(b);discontinue resuming

.fixlast	move.w	#MaxAddresses,d0
	sub.w	LoopCounter(b),d0
	move.b	d0,AddressCount(b)

	bra.b	DumpAddresses

.FoundByte	bsr.b	.AddToBuffer
	subq.w	#1,LoopCounter(b)
	bne.b	.SingleByte
	bra.w	.FullBuffer

;-- add address to buffer (seq found)
.AddToBuffer	move.l	a0,d2
	subq.l	#1,d2
	move.l	d2,(a4)+	;put address in buffer
	st.b	FindFound(b)	;mark found
	rts

;----------------------------------------------------
;- Name	: Miscellaneous memory routines.
;- Description	: Shared routines used by memory routines like find & cmpare
;- Notes	:
;----------------------------------------------------
;- 270893.0000	Included in routine index.
;----------------------------------------------------

;---- Dump hunt/cmp buffer
DumpAddresses	moveq	#0,d7
	move.b	AddressCount(b),d7
	bne.b	.dumpentries
	lea	NoAddressesText(b),a0
	pea	NoPrompt(pc)
	bra.w	Print

.dumpentries	moveq	#0,d0
	move.w	d7,d0
	lea	TextLineBuffer(b),a0
	move.b	#$0a,(a0)+
	bsr.w	PrintDec
	lea	AddEntriesText(b),a1
.copytxt	move.b	(a1)+,(a0)+
	bne.b	.copytxt
	subq.w	#1,a0
	cmp.w	#1,d7
	bne.b	.cutES
	addq.w	#2,a1
.cutES	move.b	(a1)+,(a0)+
	bne.b	.cutES
	lea	TextLineBuffer(b),a0
	bsr.w	Print
	lea	AddressBuffer1(b),a2
.dumploop	moveq	#7,d6
	lea	TextLineBuffer(b),a0
.dumpinnerloop	move.l	(a2)+,d0
	bsr.w	PrintHexS
	move.b	#' ',(a0)+
	subq.w	#1,d7
	beq.b	.last
	dbra	d6,.dumpinnerloop
	move.b	#$0a,(a0)+
.last	clr.b	(a0)
	lea	TextLineBuffer(b),a0
	bsr.w	Print
	tst.w	d7
	bne.b	.dumploop
	bra.w	NoPrompt

;---- Get start and end address, + check for size<>0 and not reverse
; return start/end in d7/d6
GetStartEnd:	bsr.w	GetValueSkip
	move.l	d0,d7
	bsr.w	GetValueSkipS
	move.l	d0,d6
	moveq	#EV_ILLEGALAREA,d1
	sub.l	d7,d0
	bmi.w	PrintError	;fail if s=>e
	beq.w	PrintError

;	move.l	d7,StartAddress(b);save so cmd can be resumed
;	move.l	d6,EndAddress(b)
	rts

;---- Get optional value
;- Check if the is an optional value (and get it). 0=val (d0=val), -1=no val
GetOptValue	cmp.b	#' ',1(a0)	;any optional value?
	bne.b	.getit
	moveq	#-1,d1
	rts

.getit	bsr.b	CheckSeparator
	bsr.w	GetValue	;get value
	moveq	#0,d1
	rts

;---- Check for correct separator
CheckSeparator	move.b	(a0)+,d1
	cmp.b	#' ',d1
	beq.b	.typok
	cmp.b	#',',d1
	bne.b	.PrintError
.typok	rts
.PrintError	moveq	#EV_ILLEGALSEPARATOR,d1
	bra.w	PrintError

;---- Calculate displaybar delay.
;- d0 - length
CalculateBar	moveq	#0,d1	;setup timing for display-bar
	cmp.l	#$1234,d0	;skip displaybar if less than 1234 bytes
	blt.b	.nodiv
	move.b	pr_ProgressBar(b),d1
	beq.b	.nodiv
	move.l	d0,d1
	moveq	#79,d0
	bsr.w	Divu32
.nodiv	move.l	d1,UpdateTime(b)
	rts

;---- Print data if user breaks command
MCUserBreak	pea	NoPrompt(pc)
MCUserBreakRT	Push	a0
	lea	UserBreakText(b),a0
	bsr.w	Print
	Pull	a0
	move.l	a0,d0
	lea	TextLineBuffer(b),a0
	bsr.w	PrintHexL	;print last processed address to buf
	clr.b	(a0)
	lea	LastAddressText(b),a0
	bsr.w	Print
	lea	TextLineBuffer(b),a0
	bra.w	Print	;print it!

;---------------T-------T---------------T------------------------------------T
;- Name	: FillMemory
;- Description	: Fill memory with data.
;- SYNTAX	: F [start] [end] [data]
;-----------------------------------------------------------------------------;
;- 310893.0000	Included in routine index.
;-----------------------------------------------------------------------------;

;---- Fill mem
FillMemory:	st.b	ResumeCommand(b);clear resume
	bsr.w	GetStartEnd	;get start & end

	move.l	d7,StartAddress(b)
	move.l	d6,EndAddress(b)

	moveq	#$20-1,d5	;max fill 32 bytes
	lea	FindTextBuffer(b),a1
	moveq	#0,d4
.GetHuntString	move.b	(a0)+,d2
	beq.b	.EvalString	;end of string
	cmp.b	#' ',d2
	beq.b	.GetHuntString
	moveq	#$f,d3	;set mask
	cmp.b	pr_TextJoker(b),d2;joker?
	bne.b	.joker3
	moveq	#0,d3	;kill mask
	moveq	#'0',d2
	bra.b	.gotnibble

.joker3	cmp.b	#'0',d2
	blt.b	.EvalString
	cmp.b	#'9',d2
	ble.b	.gotnibble
	cmp.b	#'A',d2
	blt.b	.EvalString	;check but skip space
	cmp.b	#'F',d2
	ble.b	.hexnib
	cmp.b	#'a',d2
	blt.b	.EvalString	;check but skip space
	cmp.b	#'f',d2
	bgt.b	.EvalString
.hexnib	or.b	#$20,d2
	sub.b	#'a'-'0'-10,d2
.gotnibble	sub.b	#'0',d2	;sub to get nibble value
	and.w	#$f,d2
	asl.w	#4,d0
	asl.w	#4,d1
	or.w	d2,d0	;or to byte value
	or.w	d3,d1	;or to mask
	not.w	d4	;first pass?
	bmi.b	.GetHuntString
	tst.b	d1
	bne.b	.maskok	;no store if no mask
	cmp.w	#32-1,d5	;if first byte and no mask
	beq.b	.GetHuntString	;SKIP!
.maskok	not.b	d1
	move.b	d1,32(a1)	;store mask
	move.b	d0,(a1)+	;then byte
	dbra	d5,.GetHuntString

.EvalString	move.w	d1,d3
	moveq	#EV_NOFILLDATA,d1
	moveq	#32-1,d2
	sub.w	d5,d2	;find len
	bmi.w	PrintError
	bne.b	.OnlyFirstNib
	tst.w	d4	;if no bytecount, check for 1 nibble
	bpl.w	PrintError
	moveq	#$f,d4
	and.w	d4,d3
	beq.w	PrintError
	and.w	d4,d0
	clr.b	32(a1)	;store mask (always 0)
	move.b	d0,(a1)	;then byte
	addq.w	#1,d2

.OnlyFirstNib	subq.w	#1,d2
	move.b	d2,FindLength(b)

	move.l	StartAddress(b),d7
	move.l	EndAddress(b),d6
	move.l	d6,d0
	sub.l	d7,d0
	beq.b	.error
	bpl.b	.ok
.error	moveq	#EV_ILLEGALAREA,d1
	bra.w	PrintError

.ok	bsr.w	CalculateBar

	lea	FillingText(b),a1
	lea	TextLineBuffer(b),a0
.copy1	move.b	(a1)+,(a0)+
	bne.b	.copy1
	subq.w	#1,a0
	move.l	d7,d0
	bsr.w	PrintHexS
	move.b	#'-',(a0)+
	move.l	d6,d0
	bsr.w	PrintHexS
.copy2	move.b	(a1)+,(a0)+
	bne.b	.copy2

	subq.w	#1,a0
	move.b	#'$',(a0)+
	moveq	#0,d0
	move.b	FindLength(b),d0
	lea	FindTextBuffer(b),a1
.printstring	move.b	32(a1),d2
	move.b	(a1)+,d1
	move.b	d1,d4
	lsr.b	#4,d4
	add.b	#'0',d4
	cmp.b	#'0'+10,d4
	blt.b	.ok3
	addq.w	#7,d4	;get to A-F
.ok3	move.b	d2,d3
	and.b	#$f0,d3
	beq.b	.joker
	moveq	#'?',d4
.joker	move.b	d4,(a0)+
	and.b	#$f,d1
	add.b	#'0',d1
	cmp.b	#'0'+10,d1
	blt.b	.ok2
	addq.w	#7,d1	;get to A-F
.ok2	and.b	#$0f,d2
	beq.b	.joker2
	moveq	#'?',d1
.joker2	move.b	d1,(a0)+
	dbra	d0,.printstring
	move.b	#pc_CLRRest,(a0)+
	tst.l	UpdateTime(b)
	beq.b	.NoLF
	move.b	#$a,(a0)+
.NoLF	clr.b	(a0)
	lea	TextLineBuffer(b),a0
	bsr.w	Print

	move.l	d7,a0
	moveq	#0,d0
	move.b	FindLength(b),d0

	lea	FindTextBuffer(b),a1
	move.l	UpdateTime(b),d7;init progress timer

.FillLoop	move.l	a1,a2
	move.w	d0,d1
.FillInner	move.b	(a0),d2
	and.b	32(a2),d2
	or.b	(a2)+,d2
	move.b	d2,(a0)+
	subq.l	#1,d7
	bne.b	.noprint
	tst.b	UserBreak(b)	;test for break
	bne.w	MCUserBreak
	move.l	UpdateTime(b),d7
	beq.b	.noprint	;if 0 the function is disabled
	Push	d0-a4
	moveq	#'-',d0
	bsr.w	PrintLetterR
	Pull	d0-a4
.noprint	cmp.l	d6,a0
	beq.b	.FillCompleted
	dbra	d1,.FillInner
	bra.b	.FillLoop

.FillCompleted	lea	FillCompletText(b),a0
	bsr.w	Print
	bra.w	NoPrompt


;---------------T-------T---------------T------------------------------------T
;- Name	: XORMemory
;- Description	: EOR memory with data.
;- SYNTAX	: xor [start] [end] [data]
;-----------------------------------------------------------------------------;
;- 181093	First Version
;-----------------------------------------------------------------------------;
XORMemory	st.b	ResumeCommand(b);clear resume
	bsr.w	GetStartEnd	;get start & end

	move.l	d7,StartAddress(b)
	move.l	d6,EndAddress(b)

	moveq	#$20-1,d5	;max fill 32 bytes
	lea	FindTextBuffer(b),a1
	moveq	#0,d4
.GetHuntString	move.b	(a0)+,d2
	beq.b	.EvalString	;end of string
	cmp.b	#' ',d2
	beq.b	.GetHuntString
	cmp.b	#'0',d2
	blt.b	.EvalString
	cmp.b	#'9',d2
	ble.b	.gotnibble
	cmp.b	#'A',d2
	blt.b	.EvalString	;check but skip space
	cmp.b	#'F',d2
	ble.b	.hexnib
	cmp.b	#'a',d2
	blt.b	.EvalString	;check but skip space
	cmp.b	#'f',d2
	bgt.b	.EvalString
.hexnib	or.b	#$20,d2
	sub.b	#'a'-'0'-10,d2
.gotnibble	sub.b	#'0',d2	;sub to get nibble value
	and.w	#$f,d2
	asl.w	#4,d0
	or.w	d2,d0	;or to byte value
	not.w	d4	;first pass?
	bmi.b	.GetHuntString
	tst.b	d0
	bne.b	.valok	;no store if val=0
	cmp.w	#32-1,d5	;if first byte and no value
	beq.b	.GetHuntString	;SKIP!
.valok	move.b	d0,(a1)+	;then byte
	dbra	d5,.GetHuntString

.EvalString	moveq	#EV_NOFILLDATA,d1
	moveq	#32-2,d0
	sub.w	d5,d0	;find len
	bmi.w	PrintError
	move.b	d0,FindLength(b)

	move.l	StartAddress(b),d7
	move.l	EndAddress(b),d6
	move.l	d6,d0
	sub.l	d7,d0
	beq.b	.error
	bpl.b	.ok
.error	moveq	#EV_ILLEGALAREA,d1
	bra.w	PrintError

.ok	bsr.w	CalculateBar

	lea	XORingText(b),a1
	lea	TextLineBuffer(b),a0
.copy1	move.b	(a1)+,(a0)+
	bne.b	.copy1
	subq.w	#1,a0
	move.l	d7,d0
	bsr.w	PrintHexS
	move.b	#'-',(a0)+
	move.l	d6,d0
	bsr.w	PrintHexS
.copy2	move.b	(a1)+,(a0)+
	bne.b	.copy2

	subq.w	#1,a0
	move.b	#'$',(a0)+
	moveq	#0,d0
	move.b	FindLength(b),d0
	lea	FindTextBuffer(b),a1
.printstring	move.b	(a1)+,d1
	move.b	d1,d4
	lsr.b	#4,d4
	add.b	#'0',d4
	cmp.b	#'0'+10,d4
	blt.b	.ok3
	addq.w	#7,d4	;get to A-F
.ok3	move.b	d4,(a0)+
	and.b	#$f,d1
	add.b	#'0',d1
	cmp.b	#'0'+10,d1
	blt.b	.ok2
	addq.w	#7,d1	;get to A-F
.ok2	move.b	d1,(a0)+
	dbra	d0,.printstring
	move.b	#pc_CLRRest,(a0)+
	tst.l	UpdateTime(b)
	beq.b	.NoLF
	move.b	#$a,(a0)+
.NoLF	clr.b	(a0)
	lea	TextLineBuffer(b),a0
	bsr.w	Print

	move.l	d7,a0
	moveq	#0,d0
	move.b	FindLength(b),d0

	lea	FindTextBuffer(b),a1
	move.l	UpdateTime(b),d7;init progress timer

.FillLoop	move.l	a1,a2
	move.w	d0,d1
.FillInner	move.b	(a2)+,d2
	eor.b	d2,(a0)+
	subq.l	#1,d7
	bne.b	.noprint
	tst.b	UserBreak(b)	;test for break
	bne.w	MCUserBreak
	move.l	UpdateTime(b),d7
	beq.b	.noprint	;if 0 the function is disabled
	Push	d0-a4
	moveq	#'-',d0
	bsr.w	PrintLetterR
	Pull	d0-a4
.noprint	cmp.l	d6,a0
	beq.b	.FillCompleted
	dbra	d1,.FillInner
	bra.b	.FillLoop

.FillCompleted	lea	XORCompletText(b),a0
	bsr.w	Print
	bra.w	NoPrompt

;----------------------------------------------------
;- Name	: Compare Memory
;- Description	: Compare block with another memoryarea.
;- SYNTAX	: c [start] [end] [dest]
;----------------------------------------------------
;- 160194	First version
;----------------------------------------------------
CompareMemory	st.b	ResumeCommand(b);clear resume
	bsr.w	GetStartEnd	;get start & end

	move.l	d7,StartAddress(b)
	move.l	d6,EndAddress(b)

	bsr.w	GetValueSkipS
	move.l	d0,DestAddress(b)

CompareResume	move.l	StartAddress(b),d7
	move.l	EndAddress(b),d6
	move.l	DestAddress(b),d5
	move.l	d6,d0
	sub.l	d7,d0
	beq.b	.error
	bpl.b	.ok
.error	moveq	#EV_ILLEGALAREA,d1
	bra.w	PrintError

.ok	bsr.w	CalculateBar

	lea	ComparingText(b),a1
	lea	TextLineBuffer(b),a0
.copy1	move.b	(a1)+,(a0)+
	bne.b	.copy1
	subq.w	#1,a0
	move.l	d7,d0
	bsr.w	PrintHexS
	move.b	#'-',(a0)+
	move.l	d6,d0
	bsr.w	PrintHexS
.copy2	move.b	(a1)+,(a0)+
	bne.b	.copy2
	subq.w	#1,a0
	move.l	d5,d0
	bsr.w	PrintHexS
	move.b	#'-',(a0)+
	move.l	d6,d0
	sub.l	d7,d0
	add.l	d5,d0
	bsr.w	PrintHexS
	move.b	#pc_CLRRest,(a0)+
	tst.l	UpdateTime(b)
	beq.b	.NoLF
	cmp.l	d7,d5
	beq.b	.NoLF
	move.b	#$a,(a0)+
.NoLF	clr.b	(a0)
	lea	TextLineBuffer(b),a0
	bsr.w	Print

;cmp
	move.l	d7,a0
	move.l	d5,a1

	cmp.l	d5,d7
	bne.b	.equalareas
	lea	AreasAreEquText(b),a0
	bsr.w	Print
	moveq	#EV_PRETTYFAST,d1
	bra.w	PrintError

.equalareas	clr.b	AddressCount(b)	;set # of addresses in buffer to 0
	st.b	ABPointer(b)
	clr.b	FindFound(b)

	lea	AddressBuffer1(b),a4
	move.w	#MaxAddresses,LoopCounter(b)
	move.l	UpdateTime(b),d7;init progress timer

.CompareLoop	cmpm.b	(a0)+,(a1)+
	beq.b	.Equal

	move.l	a0,d2
	subq.l	#1,d2
	move.l	d2,(a4)+	;put address in buffer
	st.b	FindFound(b)	;mark found

	subq.w	#1,LoopCounter(b)
	beq.b	.FullBuffer

.Equal	subq.l	#1,d7
	bne.b	.update2

	tst.b	UserBreak(b)	;test for break
	bne.b	.Broken
	move.l	UpdateTime(b),d7
	beq.b	.noprint	;if 0 the function is disabled
	Push	d0-a4
	moveq	#'-',d0
	tst.b	FindFound(b)
	beq.b	.nothing
	moveq	#'+',d0
.nothing	clr.b	FindFound(b)
	bsr.w	PrintLetterR
	Pull	d0-a4
.noprint

.update2	cmp.l	d6,a0	;check till end-address
	bne.b	.CompareLoop
	cmp.w	#MaxAddresses,LoopCounter(b);any found
	beq.w	.NoAddresses

.ScanComplete	lea	CompCompletText(b),a0
	bsr.w	Print
	st.b	ResumeCommand(b);discontinue resuming

.fixlast	move.w	#MaxAddresses,d0
	sub.w	LoopCounter(b),d0
	move.b	d0,AddressCount(b)

	bra.w	DumpAddresses

.NoAddresses	lea	CompCompletText(b),a0
	bsr.w	Print
	lea	AreasAreEquText(b),a0
	pea	NoPrompt(pc)
	bra.w	Print

.FullBuffer	Push	a0/a1
	lea	AddBufFullTxt(b),a0
	bra.b	.dotheprint

.Broken	Push	a0/a1
	lea	UserBreakText(b),a0
.dotheprint	bsr.w	Print
	Pull	a0/a1
	move.l	a0,d0
	move.l	a0,StartAddress(b)
	move.l	a1,DestAddress(b)
	move.b	#res_Compare,ResumeCommand(b)
	lea	TextLineBuffer(b),a0
	bsr.w	PrintHexL	;print last processed address to buf
	clr.b	(a0)
	lea	LastAddressText(b),a0
	bsr.w	Print
	lea	TextLineBuffer(b),a0
	bsr.w	Print	;print it!
	bra.b	.fixlast


;----------------------------------------------------
;- Name	: Transfer Memory
;- Description	: Copy block to another memoryarea.
;- SYNTAX	: T [start] [end] [dest]
;----------------------------------------------------
;- 310893.0000	Included in routine index.
;----------------------------------------------------
TransferMemory	bsr.w	GetStartEnd	;get start & end

	bsr.w	GetValueSkipS
	move.l	d0,d5	;dest

	move.l	d6,d0
	sub.l	d7,d0
	bsr.w	CalculateBar

	lea	CopyingText(b),a1
	lea	TextLineBuffer(b),a0
.copy1	move.b	(a1)+,(a0)+
	bne.b	.copy1
	subq.w	#1,a0
	move.l	d7,d0
	bsr.w	PrintHexS
	move.b	#'-',(a0)+
	move.l	d6,d0
	bsr.w	PrintHexS
.copy2	move.b	(a1)+,(a0)+
	bne.b	.copy2
	subq.w	#1,a0
	move.l	d5,d0
	bsr.w	PrintHexS
	move.b	#'-',(a0)+
	move.l	d6,d0
	sub.l	d7,d0
	add.l	d5,d0
	bsr.w	PrintHexS
	move.b	#pc_CLRRest,(a0)+
	tst.l	UpdateTime(b)
	beq.b	.NoLF
	cmp.l	d7,d5
	beq.b	.NoLF
	move.b	#$a,(a0)+
.NoLF	clr.b	(a0)
	lea	TextLineBuffer(b),a0
	bsr.w	Print

	cmp.l	d5,d7	;source=dest
	beq.b	.NoTransfer
	bgt.b	.SimpleCopy
 	move.l	d6,a0	;ReverseCopy
	sub.l	d7,d6
	add.l	d6,d5
	move.l	d5,a1
	moveq	#-1,d4
	subq.l	#1,a0
	subq.l	#1,a1
	bra.b	.Joined

.SimpleCopy	move.l	d5,a1
	move.l	d7,a0
	sub.l	d7,d6
	moveq	#1,d4
.Joined
	move.l	UpdateTime(b),d7;init progress timer

.copyloop	move.b	(a0),(a1)
	add.l	d4,a0
	add.l	d4,a1

	subq.l	#1,d7
	bne.b	.noprint
	tst.b	UserBreak(b)	;test for break
	bne.w	MCUserBreak
	move.l	UpdateTime(b),d7
	beq.b	.noprint	;if 0 the function is disabled
	Push	d0-a4
	moveq	#'-',d0
	bsr.w	PrintLetterR
	Pull	d0-a4

.noprint	subq.l	#1,d6
	bne.b	.copyloop

	lea	TranCompletText(b),a0
	bsr.w	Print
	bra.w	NoPrompt

.NoTransfer	moveq	#EV_PRETTYFAST,d1
	bra.w	PrintError

;---------------T-------T---------------T------------------------------------T
;- Name	: Swap Memory
;- Description	: Exchange memoryarea with another memoryarea.
;- SYNTAX	: E [start] [end] [dest]
;-----------------------------------------------------------------------------;
;- 010993.0000	Included in routine index.
;-----------------------------------------------------------------------------;
ExchangeMemory	bsr.w	GetStartEnd	;get start & end

	bsr.w	GetValueSkipS
	move.l	d0,d5	;dest

	move.l	d6,d0
	sub.l	d7,d0

	move.l	d0,d4
	add.l	d5,d4

	moveq	#EV_AREASOVERLAP,d1
	cmp.l	d4,d7
	bge.b	.nooverlap
	cmp.l	d6,d5
	blt.w	PrintError

.nooverlap	bsr.w	CalculateBar

	lea	ExchangingText(b),a1
	lea	TextLineBuffer(b),a0
.copy1	move.b	(a1)+,(a0)+
	bne.b	.copy1
	subq.w	#1,a0
	move.l	d7,d0
	bsr.w	PrintHexS
	move.b	#'-',(a0)+
	move.l	d6,d0
	bsr.w	PrintHexS
.copy2	move.b	(a1)+,(a0)+
	bne.b	.copy2
	subq.w	#1,a0
	move.l	d5,d0
	bsr.w	PrintHexS
	move.b	#'-',(a0)+
	move.l	d6,d0
	sub.l	d7,d0
	add.l	d5,d0
	bsr.w	PrintHexS
	move.b	#pc_CLRRest,(a0)+
	tst.l	UpdateTime(b)
	beq.b	.NoLF
	cmp.l	d7,d5
	beq.b	.NoLF
	move.b	#$a,(a0)+
.NoLF	clr.b	(a0)
	lea	TextLineBuffer(b),a0
	bsr.w	Print

	move.l	d5,a1
	move.l	d7,a0
	sub.l	d7,d6
	moveq	#1,d4

	move.l	UpdateTime(b),d7;init progress timer

.copyloop	move.b	(a0),d0
	move.b	(a1),(a0)+
	move.b	d0,(a1)+

	subq.l	#1,d7
	bne.b	.noprint
	tst.b	UserBreak(b)	;test for break
	bne.w	MCUserBreak
	move.l	UpdateTime(b),d7
	beq.b	.noprint	;if 0 the function is disabled
	Push	d0-a4
	moveq	#'-',d0
	bsr.w	PrintLetterR
	Pull	d0-a4

.noprint	subq.l	#1,d6
	bne.b	.copyloop

	lea	ExcgCompletText(b),a0
	bsr.w	Print
	bra.w	NoPrompt

;---------------T-------T---------------T------------------------------------T
;- Name	: DiskRoutines
;- Description	: Handles lowlevel diskaccess for user.
;- Notes	: Needs to support DOS1+.
;-----------------------------------------------------------------------------;
;- 270893.0002	Included in routine index.
;- 300893.0003	Added track/block savers.
;-       .0004	Added Raw read/write track.
;-	Changed info text to show area.
;-	Added break test.
;-       .0005	Added sync and tracklen changers.
;- 241293	Added Evaluation-assembly.
;-----------------------------------------------------------------------------;

;---- Read disk tracks
;SYNTAX: rt [addr] [track] <num>
ReadTracks	grcall	InitDrive	;get drive ready

	bsr.w	GetReadArgs

	moveq	#EV_ILLEGALTRACK,d1
	move.w	#160,d0
	cmp.w	d0,d5
	bge.w	PrintErrorMO
	cmp.w	d0,d6
	bge.w	PrintErrorMO
	sub.w	d5,d0
	sub.w	d6,d0
	bmi.w	PrintErrorMO

	bsr.w	MCursorDownDO	;cursor one down
	moveq	#0,d3
	move.b	DiskSectors(b),d3
	asl.w	#8,d3
	add.w	d3,d3
.LoadTracksLoop	lea	TextLineBuffer(b),a0;print current sector/loadaddress
	lea	LoadingTrkText(b),a1
.copy1	move.b	(a1)+,(a0)+
	bpl.b	.copy1
	subq.w	#1,a0
	move.l	d6,d0
	bsr.w	PrintDec
	lea	ToMemText(b),a1
.copy2	move.b	(a1)+,(a0)+
	bne.b	.copy2
	subq.w	#1,a0
	move.l	d7,d0
	bsr.w	PrintHexL
	move.b	#'-',(a0)+
	move.l	d7,d0
	add.l	d3,d0
	bsr.w	PrintHexL
	move.b	#pc_CLRRest,(a0)+
	clr.b	(a0)
	lea	TextLineBuffer(b),a0
	bsr.w	Print

	move.l	d6,d0	;read the block
	grcall	LoadTrack

	move.l	d7,a1	;don't kill this with DMA
	lea	TrackBuffer,a0	;is needed for valid buffer
	move.w	d3,d0
	subq.w	#1,d0
.copytomem	move.b	(a0)+,(a1)+
	dbra	d0,.copytomem

	add.l	d3,d7	;get to next block
	addq.w	#1,d6
	tst.b	UserBreak(b)
	bne.b	.exit
	dbra	d5,.LoadTracksLoop

.exit	grcall	MotorOff
	bra.w	NoPrompt

;---- Read disk tracks
;SYNTAX: rtr [addr] [track] <num>
ReadRawTracks	grcall	InitDrive	;get drive ready

	bsr.w	GetReadArgs

	moveq	#EV_ILLEGALTRACK,d1
	move.w	#160,d0
	cmp.w	d0,d5
	bge.w	PrintErrorMO
	cmp.w	d0,d6
	bge.w	PrintErrorMO
	sub.w	d5,d0
	sub.w	d6,d0
	bmi.w	PrintErrorMO

	bsr.w	MCursorDownDO	;cursor one down
.LoadTracksLoop	lea	TextLineBuffer(b),a0;print current sector/loadaddress
	lea	LoadingTrkText(b),a1
.copy1	move.b	(a1)+,(a0)+
	bpl.b	.copy1
	subq.w	#1,a0
	move.l	d6,d0
	bsr.w	PrintDec
	lea	ToMemText(b),a1
.copy2	move.b	(a1)+,(a0)+
	bne.b	.copy2
	subq.w	#1,a0
	move.l	d7,d0
	bsr.w	PrintHexL
	move.b	#'-',(a0)+
	moveq	#0,d0
	move.w	TrackLen(b),d0
	add.l	d7,d0
	bsr.w	PrintHexL
	move.b	#pc_CLRRest,(a0)+
	clr.b	(a0)
	lea	TextLineBuffer(b),a0
	bsr.w	Print

	move.l	d6,d0	;read the block
	moveq	#-1,d1
	grcall	LoadTrackNDec

	move.l	d7,a1	;don't kill this with DMA
	move.l	ChipMem(b),a0
	add.l	#DiskBuffer,a0
;	lea	TrackBuffer,a0	;is needed for valid buffer
;	move.w	#11*512-1,d0
	moveq	#0,d0
	move.w	TrackLen(b),d0
	add.l	d0,d7
.copytomem	move.b	(a0)+,(a1)+
	subq.w	#1,d0
	bne.b	.copytomem

	addq.w	#1,d6
	tst.b	UserBreak(b)
	bne.b	.exit
	dbra	d5,.LoadTracksLoop
.exit	grcall	MotorOff
	bra.w	NoPrompt

;---- Read disk blocks
;SYNTAX : rb [addr] [block] <num>
ReadBlocks	grcall	InitDrive	;get drive ready

	bsr.w	GetReadArgs

	moveq	#EV_ILLEGALBLOCK,d1
	moveq	#0,d0
	move.w	MaxBlock(b),d0
	cmp.l	d0,d5	;check sizes
	bgt.w	PrintErrorMO
	cmp.l	d0,d6
	bgt.w	PrintErrorMO
	sub.w	d5,d0
	sub.w	d6,d0
	bmi.w	PrintErrorMO

	bsr.w	MCursorDownDO	;cursor one down
.LoadBlksLoop	lea	TextLineBuffer(b),a0;print current sector/loadaddress
	lea	LoadingBlkText(b),a1
.copy1	move.b	(a1)+,(a0)+
	bpl.b	.copy1
	subq.w	#1,a0
	move.l	d6,d0
	bsr.w	PrintDec
	lea	ToMemText(b),a1
.copy2	move.b	(a1)+,(a0)+
	bne.b	.copy2
	subq.w	#1,a0
	move.l	d7,d0
	bsr.w	PrintHexL
	move.b	#'-',(a0)+
	move.l	d7,d0
	add.l	#512,d0
	bsr.w	PrintHexL
	move.b	#pc_CLRRest,(a0)+
	clr.b	(a0)
	lea	TextLineBuffer(b),a0
	bsr.w	Print

	move.l	d6,d0	;read the block
	move.l	d7,a0
	grcall	GetBlockToAdd

	add.l	#512,d7	;get to next block
	addq.w	#1,d6
	tst.b	UserBreak(b)
	bne.b	.exit
	dbra	d5,.LoadBlksLoop
.exit	grcall	MotorOff
	bra.w	NoPrompt


;---- Write disk tracks
;SYNTAX: wt [addr] [track] <num>
WriteTracks	grcall	InitDriveW	;get drive ready

	bsr.w	GetReadArgs

	moveq	#EV_ILLEGALTRACK,d1
	move.w	#160,d0
	cmp.w	d0,d5
	bge.w	PrintErrorMO
	cmp.w	d0,d6
	bge.w	PrintErrorMO
	sub.w	d5,d0
	sub.w	d6,d0
	bmi.w	PrintErrorMO

	bsr.w	MCursorDownDO	;cursor one down
	moveq	#0,d3
	move.b	DiskSectors(b),d3
	asl.w	#8,d3
	add.w	d3,d3
.SaveTracksLoop	lea	TextLineBuffer(b),a0;print current sector/loadaddress
	lea	SavingText(b),a1
.copy1	move.b	(a1)+,(a0)+
	bpl.b	.copy1
	subq.w	#1,a0
	move.l	d7,d0
	bsr.w	PrintHexL
	move.b	#'-',(a0)+
	move.l	d7,d0
	add.l	d3,d0
	bsr.w	PrintHexL
	lea	ToTrackText(b),a1
.copy2	move.b	(a1)+,(a0)+
	bne.b	.copy2
	subq.w	#1,a0
	move.l	d6,d0
	bsr.w	PrintDec
	move.b	#pc_CLRRest,(a0)+
	clr.b	(a0)
	lea	TextLineBuffer(b),a0
	bsr.w	Print

	move.l	d7,a0
	move.l	d6,d0	;write the track
	grcall	SaveTrackAdd

	add.l	d3,d7	;get to next block
	addq.w	#1,d6
	tst.b	UserBreak(b)
	bne.b	.exit
	dbra	d5,.SaveTracksLoop
.exit	grcall	MotorOff
	bra.w	NoPrompt

;---- Write RAW disk tracks
;SYNTAX: wtr [addr] [track] <num>
WriteRawTracks	grcall	InitDriveW	;get drive ready

	bsr.w	GetReadArgs

	moveq	#EV_ILLEGALTRACK,d1
	move.w	#160,d0
	cmp.w	d0,d5
	bge.w	PrintErrorMO
	cmp.w	d0,d6
	bge.w	PrintErrorMO
	sub.w	d5,d0
	sub.w	d6,d0
	bmi.w	PrintErrorMO

	bsr.w	MCursorDownDO	;cursor one down
.SaveTracksLoop	lea	TextLineBuffer(b),a0;print current sector/loadaddress
	lea	SavingText(b),a1
.copy1	move.b	(a1)+,(a0)+
	bpl.b	.copy1
	subq.w	#1,a0
	move.l	d7,d0
	bsr.w	PrintHexL
	move.b	#'-',(a0)+
	moveq	#0,d0
	move.w	TrackLen(b),d0
	add.l	d7,d0
	bsr.w	PrintHexL
	lea	ToTrackText(b),a1
.copy2	move.b	(a1)+,(a0)+
	bne.b	.copy2
	subq.w	#1,a0
	move.l	d6,d0
	bsr.w	PrintDec
	move.b	#pc_CLRRest,(a0)+
	clr.b	(a0)
	lea	TextLineBuffer(b),a0
	bsr.w	Print

	move.l	d7,a0	;copy raw track to diskbuffer
	moveq	#0,d0
	move.w	TrackLen(b),d0
	add.l	d0,d7	;new pointer
	move.l	ChipMem(b),a1
	add.l	#DiskBuffer,a1
	move.l	#$aaaaaaaa,(a1)+;init with one zero word
	subq.w	#5,d0
.copyRAW	move.b	(a0)+,(a1)+
	dbra	d0,.copyRAW

	move.l	d6,d0	;and write the track
	grcall	SaveRawTrack

	addq.w	#1,d6
	tst.b	UserBreak(b)
	bne.b	.exit
	dbra	d5,.SaveTracksLoop
.exit	grcall	MotorOff
	bra.w	NoPrompt


;---- Write disk blocks
;SYNTAX : wb [addr] [block] <num>
WriteBlocks	grcall	InitDriveW	;get drive ready

	bsr.w	GetReadArgs

	moveq	#EV_ILLEGALBLOCK,d1
	moveq	#0,d0
	move.w	MaxBlock(b),d0
	cmp.l	d0,d5	;check sizes
	bgt.w	PrintErrorMO
	cmp.l	d0,d6
	bgt.w	PrintErrorMO
	sub.w	d5,d0
	sub.w	d6,d0
	bmi.w	PrintErrorMO

	bsr.w	MCursorDownDO	;cursor one down
.LoadBlksLoop	lea	TextLineBuffer(b),a0;print current sector/loadaddress
	lea	SavingText(b),a1
.copy1	move.b	(a1)+,(a0)+
	bpl.b	.copy1
	subq.w	#1,a0
	move.l	d7,d0
	bsr.w	PrintHexL
	move.b	#'-',(a0)+
	move.l	d7,d0
	add.l	#512,d0
	bsr.w	PrintHexL
	lea	ToBlockText(b),a1
.copy2	move.b	(a1)+,(a0)+
	bne.b	.copy2
	subq.w	#1,a0
	move.l	d6,d0

	bsr.w	PrintDec
	move.b	#pc_CLRRest,(a0)+
	clr.b	(a0)
	lea	TextLineBuffer(b),a0
	bsr.w	Print

	move.l	d6,d0	;read the block
	move.l	d7,a0
	grcall	SaveBlockAdd

	add.l	#512,d7	;get to next block
	addq.w	#1,d6
	tst.b	UserBreak(b)
	bne.b	.exit
	dbra	d5,.LoadBlksLoop
.exit	grcall	UpdateDisk
	grcall	MotorOff
	bra.w	NoPrompt

;---- Read args needed for disk block/track load
GetReadArgs	bsr.w	GetValueSkip	;get memory address
	move.l	d0,d7
	bsr.w	GetValueSkipS	;get (start) sector
	move.l	d0,d6
	moveq	#1,d5	;set def 1 sector
	bsr.w	GetOptValue
	bmi.b	.nolen
	move.l	d0,d5
.nolen	moveq	#EV_ILLEGALLEN,d1
	subq.w	#1,d5	;check that len is ok
	bmi.w	PrintError
	rts

;---- Calc DataBlock checksum
;-- Input :	A0 -	Pointer to block
;-- Output :	d0 -	New Checksum
;--	d1 -	Old Checksum
;----
ChecksumBlock	move.l	FH_CHECKSUM(a0),-(a7);save old checksum
	moveq	#0,d0
	moveq	#$7f,d1
	move.l	d0,FH_CHECKSUM(a0)
.sum	sub.l	(a0)+,d0
	dbra	d1,.sum
	move.l	(a7)+,d1
	rts

;---- Change disk sync
; ARG 'Sync <SYNC>'
;- a0 - args
;----
ChangeSync	bsr.w	GetValueCall
	cmp.w	#EV_NOVALUE,d1
	beq.b	.ShowSync
	tst.w	d1	;test for no arg
	bmi.w	PrintError
	move.w	d0,d1
	swap	d0
	move.w	d1,d0
	move.l	d0,DiskSyncs(b)	;change actual
	moveq	#0,d1	;and put in table
	move.b	SelectedDrive(b),d1
	asl.w	#2,d1
	lea	DiskSyncTab(b),a0
	move.l	d0,(a0,d1.w)

.ShowSync	move.l	DiskSyncs(b),d0
	lea	TextLineBuffer(b),a0
	lea	SyncText(b),a1
.copytxt	move.b	(a1)+,(a0)+
	bne.b	.copytxt
	subq.w	#1,a0
	moveq	#3,d1
	bsr.w	PrintHex
DiskInfoExit	move.b	#pc_CLRRest,(a0)+
	clr.b	(a0)
	lea	TextLineBuffer(b),a0
	bsr.w	Print
	clr.b	LastCMDError(b)
	bra.w	NoPrompt

;---- Change Track length (HD)
; ARG 'TrackLenH <length>'
;; problem: will display data from last diskusage/info

ChangeTrackLenH	bsr.w	GetValueCall
	cmp.w	#EV_NOVALUE,d1	;test for no arg
	beq.b	ShowTrackLen
	tst.w	d1
	bmi.w	PrintError
	cmp.l	#DBSize*2+$100,d0;HD maxTL=BufferSize
	ble.b	.defsize
	move.w	#DBSize*2+$100,d0
.defsize	moveq	#0,d2
	move.b	SelectedDrive(b),d2
	add.w	d2,d2
	lea	TrackLenHTab(b),a1
	move.w	d0,(a1,d2.w)
	cmp.b	#22,DiskSectors(b)
	bne.b	ShowTrackLen	;only change actual if DD disk
	move.w	d0,TrackLen(b)
	bra.b	ShowTrackLen

;---- Change Track length (DD)
; ARG 'TrackLen <length>'
ChangeTrackLen	bsr.w	GetValueCall
	cmp.w	#EV_NOVALUE,d1	;test for no arg
	beq.b	ShowTrackLen
	tst.w	d1
	bmi.w	PrintError
	cmp.l	#DBSize*2+$100,d0;DD maxTL=BufferSize
	ble.b	.defsize
	move.w	#DBSize*2+$100,d0
.defsize	moveq	#0,d2
	move.b	SelectedDrive(b),d2
	add.w	d2,d2
	lea	TrackLenTab(b),a1
	move.w	d0,(a1,d2.w)
	cmp.b	#11,DiskSectors(b)
	bne.b	ShowTrackLen	;only change actual if DD disk
	move.w	d0,TrackLen(b)

ShowTrackLen	moveq	#0,d0
	move.w	TrackLen(b),d0	;print actual
	lea	TrackLenText(b),a1
	lea	TextLineBuffer(b),a0
.copytxt	move.b	(a1)+,(a0)+
	bne.b	.copytxt
	moveq	#3,d1
	move.b	#'$',-1(a0)
	bsr.w	PrintHex

	moveq	#0,d2	;then "(DD/HD)"
	move.b	SelectedDrive(b),d2
	add.w	d2,d2
	move.b	#' ',(a0)+
	move.b	#'(',(a0)+
	moveq	#0,d0
	lea	TrackLenTab(b),a1
	move.w	(a1,d2.w),d0
	moveq	#3,d1
	move.b	#'$',(a0)+
	bsr.w	PrintHex
	move.b	#'/',(a0)+
	moveq	#0,d0
	lea	TrackLenHTab(b),a1
	move.w	(a1,d2.w),d0
	moveq	#3,d1
	move.b	#'$',(a0)+
	bsr.w	PrintHex
	move.b	#')',(a0)+
	clr.b	LastCMDError(b)
	bra.w	DiskInfoExit

;----------------------------------------------------
;- Name	: Symbol Control
;- Description	: Control Symbols
;- Notes	:
;----------------------------------------------------
;- 270893.0000	Included in routine index.
;----------------------------------------------------

;---- Print defined symbols
PrintSymbols	moveq	#MaxSymbols-1,d7
	lea	SymbolTable(b),a3
.PrintSymbolLoop
	tst.b	(a3)
	beq.b	.nextplease
	lea	TextLineBuffer(b),a0
	move.b	#$0a,(a0)+
	move.l	a3,a2
	moveq	#7,d0
.getname	move.b	(a2)+,(a0)+
	beq.b	.null
	dbra	d0,.getname
	bra.b	.printval

.null	subq.w	#1,a0
.spaze	move.b	#' ',(a0)+
	dbra	d0,.spaze

.printval	move.b	#'=',(a0)+
	move.l	8(a3),d0
	bsr.w	PrintHexL
	clr.b	(a0)
	lea	TextLineBuffer(b),a0
	bsr.w	Print
.nextplease	add.w	#12,a3
	dbra	d7,.PrintSymbolLoop
	bra.w	NoPrompt

;---- Make symbol CLI to MakeNewSymbol
MakeSymbol	bsr.w	GetSymbolName	;get name
	bmi.w	PrintError
	moveq	#EV_SYNTAXERROR,d1
	cmp.b	#'=',-1(a0)	;check for correct usage (.name=value)
	bne.w	PrintError
	bsr.w	GetValue
	bsr.b	MakeNewSymbol
	bmi.w	PrintError
	lea	TextLineBuffer(b),a0
	pea	NoPrompt(pc)
	bra.w	Print

;---- Make new Symbol
;-- Input:	d0 - Value
;--	SymbolBuffer - Name
;----
MakeNewSymbol	move.l	d0,NewSymbol(b)
	lea	SymbolBuffer(b),a0
	bsr.w	FindSymbol	;already exists?
	beq.b	.EntryFound
	lea	SymbolTable(b),a0
	moveq	#MaxSymbols-1,d0
.seekfreeloop	tst.b	(a0)	;else seek a free entry
	beq.b	.EntryFound
	add.w	#12,a0
	dbra	d0,.seekfreeloop
	moveq	#EV_SYMBOLTABLEFULL,d1;fail if full
	rts

.EntryFound	move.l	NewSymbol(b),8(a0);set value
	lea	SymbolBuffer(b),a1;and copy name
	moveq	#7,d0
.copynameloop	move.b	(a1)+,(a0)+
	dbra	d0,.copynameloop
	lea	NewSymbolText(b),a0;make 'newsymbol'-txt ready
	lea	TextLineBuffer(b),a1;in TextLineBuffer
.copy1	move.b	(a0)+,(a1)+	;first ini text (..")
	bne.b	.copy1
	subq.w	#1,a1
	Push	a0
	lea	SymbolBuffer(b),a0;then the name
	moveq	#7,d0
.copy2	move.b	(a0)+,(a1)+
	dbeq	d0,.copy2
	subq.w	#1,a1
	Pull	a0
.copy3	move.b	(a0)+,(a1)+	;and finally the rest ("...)
	bne.b	.copy3
	moveq	#0,d1
	rts

;---- Zap symbol if exizting
ZapSymbol	cmp.b	#'.',(a0)+	;check for correct mark
	beq.b	.syntaxok
	moveq	#EV_SYNTAXERROR,d1
	bra.w	PrintError

.syntaxok	cmp.b	#'.',(a0)	;check for zap all (zc..)
	bne.b	.zapall
	moveq	#MaxSymbols-1,d0;zap all constants
	lea	SymbolTable(b),a0
.zapem	clr.b	(a0)
	add.w	#12,a0
	dbra	d0,.zapem
	lea	AllZappedText(b),a0
	pea	NoPrompt(pc)	;and print text
	bra.w	Print

.zapall	bsr.b	GetSymbolName
	bmi.w	PrintError

	lea	SymbolBuffer(b),a0
	bsr.b	FindSymbol
	bmi.w	PrintError

	clr.b	(a0)	;equ->clear the entry
	lea	ZappedText(b),a0;and notify user
	pea	NoPrompt(pc)
	bra.w	Print

;---- Find symbol name in table (0=ok+a0=poi/error) (a0=pointer to symbol name)
FindSymbol	move.l	a0,a1
	moveq	#MaxSymbols-1,d0;seek symbol in table
	lea	SymbolTable(b),a0
.checkloop	moveq	#7,d1
	move.l	a1,a3
	move.l	a0,a2
.checki	move.b	(a2)+,d3	;check if equ to entry
	cmp.b	(a3)+,d3
	bne.b	.trynext
	dbra	d1,.checki
	moveq	#0,d1
	rts

.trynext	add.w	#12,a0	;goto next entry
	dbra	d0,.checkloop
	moveq	#EV_UNDEFINEDSYMBOL,d1;fail coz...
	rts

;---- get symbol name. Return len in d0 (-1=8)
GetSymbolName	moveq	#7,d0	;get constant name
	moveq	#0,d1
	lea	SymbolBuffer(b),a1
.getsymbol	move.b	(a0)+,d1	;get until <> 0-9/A-Z/a-z
	cmp.w	#'0',d1
	blt.b	.notvalid
	cmp.w	#'9',d1
	ble.b	.valid
	cmp.w	#'A',d1
	blt.b	.notvalid
	cmp.w	#'Z',d1
	ble.b	.valid
	cmp.w	#'a',d1
	blt.b	.notvalid
	cmp.w	#'z',d1
	bgt.b	.notvalid
.valid	move.b	d1,(a1)+
	dbra	d0,.getsymbol
.nameok	moveq	#0,d1
	rts

.notvalid	cmp.w	#7,d0	;no letters?
	beq.b	.illname
	subq.w	#1,d0
	bmi.b	.nameok
.killrest	clr.b	(a1)+	;zap remaining letters
	dbra	d0,.killrest
	moveq	#0,d1
	rts

.illname	moveq	#EV_ILLEGALSYMBOLNAME,d1;if no letters ok
	rts

;----------------------------------------------------
;- Name	: Line Assembler
;- Description	: Assembles one line to MC68k family code.
;----------------------------------------------------
;- 270893.0000	Included in routine index.
;- 040993.0001	Now disassembles with breaklines.
;----------------------------------------------------
;- At long input with oneline disassembly, the prepare routine leaves goof
;-   from the long line.


;----- Start of "Assembler Commands" -----------------------------------------;
AssembleLineStart
	move.l	MemoryAddress(b),d0
.skipspaces	move.b	(a0)+,d1
	beq.b	.sameaddress
	cmp.b	#' ',d1
	beq.b	.skipspaces
	subq.w	#1,a0
	bsr.w	GetValue
.sameaddress	move.l	d0,MemoryAddress(b)
	bra.w	AssembleLineM

;---- Assemble one line
AssembleLine	tst.b	GotHalfCmd(b)
	bne.b	.gotfirsthalf

.nodesthalf	move.l	a0,a1	;check for long commands
	lea	AssHalfBuf(b),a2
	moveq	#'.',d1
.findlong	move.b	(a1)+,d0
	move.b	d0,(a2)+
	beq.b	.dotheassemble	;not found
	cmp.b	#',',d0
	bne.b	.findlong
	cmp.b	(a1),d1
	bne.b	.findlong
	cmp.b	1(a1),d1
	bne.b	.findlong
	clr.b	(a2)
	bsr.w	GetValue	;get value, so next line can be printed
	move.l	d0,HalfAddress(b)
	st.b	GotHalfCmd(b)
	bra.w	AssemblePrepare

.gotfirsthalf	clr.b	GotHalfCmd(b)
	move.l	a0,a1	;check if address match that of the other half
	bsr.w	GetValue
	cmp.l	HalfAddress(b),d0
	bne.b	.dotheassemble
	moveq	#EV_COULDNOTFINDHALF,d1
	lea	AssHalfBuf(b),a1
.findend	tst.b	(a1)+
	bne.b	.findend
	subq.w	#1,a1

	moveq	#'.',d2
.findstart	move.b	(a0)+,d0	;search for dest
	beq.w	PrintError
	cmp.b	d2,d0
	bne.b	.findstart
	cmp.b	(a0)+,d2
	bne.b	.findstart
	cmp.b	#',',(a0)+
	bne.b	.findstart

.copyrest	move.b	(a0)+,(a1)+	;and merge with start
	bne.b	.copyrest

	tst.b	CurYPos(b)
	beq.b	.intop
	subq.b	#1,CurYPos(b)	;get one up if possible
.intop
	lea	AssHalfBuf(b),a0

.dotheassemble	grcall	Assemble
	move.l	AssembleStart(b),MemoryAddress(b);set new address
	cmp.w	#1,d1
	beq.w	NoPrompt	;if nothing was assembled
	cmp.w	#2,d1
	beq.w	AssembleLineM
	tst.w	d1
	bmi.w	AssembleError	;print error if any
	st.b	ReprintHeader(b);ensure that header is clear after
			;correct assembly

	move.l	MemoryAddress(b),a0
	moveq	#70,d1
	move.b	pr_ShortAddress(b),d0
	beq.b	.long
	moveq	#72,d1
.long	moveq	#-1,d0
	grcall	DisAssemble
	move.l	d0,d7	;get flags
	move.l	a0,d0	;print address
	lea	TextLineBuffer(b),a0
	move.b	pr_Prompt(b),(a0)+
	move.b	#',',(a0)+

	bsr.w	PrintHexS
	move.b	#' ',(a0)+	;copy generated text to buffer
	lea	DumpBuffer(b),a1
.movedis	move.b	(a1)+,(a0)+
	bmi.b	.extradisline
	bne.b	.movedis
	bra.b	.onwithit

.extradisline	clr.b	(a0)
	move.b	#pc_CLRRest,-(a0);code prints extra line

	move.l	a1,-(a7)

	moveq	#0,d0
	move.b	CurYPos(b),d0
	lea	TextLineBuffer(b),a0
	bsr.w	PrintLine	;and print!

;	clr.b	CurXPos(b)	;get to next line
	bsr.w	MCursorDownDO	;do nice cursor down

.preparenextline
	lea	TextLineBuffer(b),a0
.findspace	cmp.b	#' ',(a0)+
	bne.b	.findspace
	moveq	#MaxMnemonicLen+4-1,d0
.fillspaces	move.b	#' ',(a0)+
	dbra	d0,.fillspaces

	move.l	(a7)+,a1
	bra.b	.movedis

.onwithit	clr.b	(a0)
	move.b	#pc_CLRRest,-(a0)
	moveq	#0,d0
	move.b	CurYPos(b),d0
	clr.b	CurXPos(b)
	lea	TextLineBuffer(b),a0
	bsr.w	PrintLine	;and print!

	btst	#de_Break,d7
	beq.b	AssembleLineM

	bsr.w	MCursorDownDO	;do nice cursor down

	lea	TextLineBuffer(b),a0
.findspace2	cmp.b	#' ',(a0)+
	bne.b	.findspace2
	moveq	#BreakLineLen-1,d1
.fillbreak	move.b	#'=',(a0)+
	dbra	d1,.fillbreak	
	move.b	#pc_CLRRest,(a0)+
	clr.b	(a0)

	moveq	#0,d0
	move.b	CurYPos(b),d0
	clr.b	CurXPos(b)
	lea	TextLineBuffer(b),a0
	bsr.w	PrintLine	;and print!

AssembleLineM	move.l	MemoryAddress(b),d0
AssemblePrepare	lea	TextLineBuffer(b),a0
	move.b	#$0a,(a0)+
	move.b	pr_Prompt(b),(a0)+
	move.w	#',$',(a0)+
	moveq	#7,d1
	tst.b	pr_ShortAddress(b)
	beq.b	.fixsize
	moveq	#5,d1
.fixsize	bsr.w	PrintHex	;print next address
	move.b	#' ',(a0)+
	move.b	pr_DisassemNext(b),d1
	bne.b	.disassemnextline
	move.b	#pc_CLRRest,(a0)+;change to disassem later
.disassemnextline		;if wanted, disassemble next line
	clr.b	(a0)
	pea	MainLoop(pc)
	lea	TextLineBuffer(b),a0
	bra.w	Print

AssembleError	move.w	d1,LastErrorNumber(b)
	st.b	LastCMDError(b)	;flag error in last command
	bsr.w	PrintLEInHeader
	clr.b	ReprintHeader(b);don't reprint header
	bra.w	MainLoop

;----------------------------------------------------
;- Name	: HAModifiers.
;- Description	: Alter memory in Hex/ASCII form.
;- Notes	: Problems with determining end of ASCII string ('/")
;----------------------------------------------------
;- 270893.0000	Included in routine index.
;----------------------------------------------------

;----- Start of "Hex Memory Modifier" ----------------------------------------;
HexEntry	moveq	#0,d7
	move.b	CurXPos(b),d7
	move.l	a0,d6
	bsr.w	GetValue	;get address
	neg.w	d1
	bmi.w	PrintError
	move.l	d0,MemoryAddress(b)
	sub.l	a0,d6
	add.w	d6,d7
	bmi.w	NoPrompt

	move.l	d0,a1	;get values
	moveq	#0,d1
	moveq	#1,d2
	moveq	#0,d6
	moveq	#16-1,d3
.gethexloop	move.b	(a0)+,d0
	subq.w	#1,d7
	bmi.w	.nohexentry
	cmp.b	#' ',d0
	beq.b	.gethexloop
	cmp.b	#'0',d0
	blt.b	.checkascii
	cmp.b	#'9',d0
	ble.b	.gotnibble
	cmp.b	#'A',d0
	blt.b	.endofloopsp	;check but skip space
	cmp.b	#'F',d0
	ble.b	.hexnib
	cmp.b	#'a',d0
	blt.b	.endofloopsp	;check but skip space
	cmp.b	#'f',d0
	bgt.b	.endofloopsp
.hexnib	or.b	#$20,d0
	sub.b	#'a'-'0'-10,d0
.gotnibble	sub.b	#'0',d0	;sub to get nibble value
	and.w	#$f,d0
	asl.w	#4,d1
	or.w	d0,d1	;or to byte value
	neg.w	d2	;first pass?
	bmi.b	.gethexloop
	move.b	d1,(a1)+	;if not, byte is ready
	moveq	#1,d6
	dbra	d3,.gethexloop

.checkonloop	move.b	(a0)+,d0	;skip spaces
	subq.w	#1,d7
	bmi.b	.nohexentry
	cmp.b	#' ',d0
	beq.b	.checkonloop

.checkascii	cmp.b	#"'",d0	;check for ascii input
	beq.b	.getascii
	cmp.b	#'"',d0
	bne.b	.endofloopsp

.getascii	move.b	pr_NonASCII(b),d1
	move.l	MemoryAddress(b),a1
	moveq	#16-1,d3
	moveq	#0,d2
.getascii2	move.b	(a0)+,d2
	subq.w	#1,d7
	bmi.b	.nohexentry
	cmp.b	d0,d2	;check end of ascii
	beq.b	.endofloopsp
	cmp.b	d1,d2	;nonascii - don't write this byte
	bne.b	.skipbyte
	addq.w	#1,a1
	bra.b	.skipped
.skipbyte	cmp.w	#' ',d2
	blt.b	.endofloopsp
	cmp.w	#$7e,d2
	bgt.b	.endofloopsp
	move.b	d2,(a1)+
	moveq	#1,d6
.skipped	dbra	d3,.getascii2

.endofloopsp	pea	DumpLine(pc)	;if changed mem-> print update
	bra.w	DOHex

.nohexentry	tst.w	d6	;was mem chenged?
	bne.b	.endofloopsp	;yes, update
	bra.w	NoPrompt

;----- Start of "ASCII Memory Modifier" --------------------------------------;
ASCIIEntry	bsr.w	GetValue	;get address
	move.l	d0,MemoryAddress(b)
	move.l	d0,a1
	moveq	#0,d6
.findstart	move.b	(a0)+,d0	;find text start
	beq.b	.asciiend
	cmp.b	#'"',d0
	beq.b	.found
	cmp.b	#"'",d0
	bne.b	.findstart
.found	move.b	pr_NonASCII(b),d1
.gettomem	move.b	(a0)+,d2
	cmp.b	d2,d0
	beq.b	.asciiend	;problem here! '/" in text will end
	cmp.b	d1,d0
	bne.b	.skip
	addq.w	#1,a1
	bra.b	.skipped

.skip	cmp.b	#' ',d2	;check that code is legal
	blt.b	.asciiend
	cmp.b	#$7e,d2
	bge.b	.asciiend
	move.b	d2,(a1)+
	moveq	#1,d6
.skipped	bra.b	.gettomem

.asciiend	tst.w	d6	;update line if changed
	beq.w	NoPrompt
	pea	DumpLine(pc)
	bra.w	DOASCII

;----------------------------------------------------
;- Name	: Disassembly/Hex/ASCII Dumpers
;- Description	: Decodes memory according to format.
;- Notes	:
;----------------------------------------------------
;- 280693	Inserted disassembler breaklineflags fetch, prior to entry
;- 270893	Included in routine index.
;- 040993	New breakline for improved lineassembly syntax.
;----------------------------------------------------

;----- Start of "Dump Lines Code" --------------------------------------------;
;---- Dump x lines/area from current or forced address
;----
DumpLines:	move.b	(a0)+,d0	;check for normal dump
	beq.b	DumpLinesF
	cmp.b	#' ',d0
	beq.b	DumpLines

	move.l	#-2,MemoryAddressAE(b);run to address -2
	moveq	#1,d6	;flag area operation (with no end)

	cmp.b	#'\',d0	;check for area with start=actual
	bne.b	.checkareastart

.searcharg	move.b	(a0)+,d0	;check for endaddress
	beq.b	DumpLinesG
	cmp.b	#' ',d0
	beq.b	.searcharg
	bra.b	.getendaddress

.checkareastart	subq.w	#1,a0
	bsr.w	GetValue
	move.l	d0,MemoryAddress(b)

.checkend	move.b	(a0)+,d0	;check for normal dump
	beq.b	DumpLinesF
	cmp.b	#' ',d0
	beq.b	.checkend

	cmp.b	#'\',d0
	beq.b	DumpLinesG

.getendaddress	subq.w	#1,a0
	bsr.w	GetValue
	moveq	#-1,d6	;flag area operation
	move.l	d0,MemoryAddressAE(b)
	sub.l	MemoryAddress(b),d0
	bpl.b	DumpLinesG

DumpLinesF	move.l	#-1,MemoryAddressAE(b);invalidate area end
	moveq	#0,d6
DumpLinesG	moveq	#0,d7
	move.b	pr_DumpLines(b),d7

DOLines
.DOLinesLoop	clr.b	CurXPos(b)
	bsr.w	MCursorDownDO	;do nice cursor down

	move.l	MemoryAddress(b),a0
	moveq	#70,d1	;max len of >disassembled< cmd
	move.b	pr_ShortAddress(b),d2
	beq.b	.notshort
	moveq	#72,d1	;max txt length (disassembler)
.notshort	moveq	#1,d0	;produce output (disassembler)
	jsr	(a2)	;get dump
	move.w	d0,-(a7)	;put disassembler flags on stack
	move.l	a0,d0	;print address
	lea	TextLineBuffer(b),a0
	move.b	pr_Prompt(b),(a0)+
	move.b	LinesType(b),(a0)+
	move.b	#'$',(a0)+
	moveq	#7,d1	;adjust address len to prefs
	move.b	pr_ShortAddress(b),d2
	beq.b	.fixsize
	moveq	#5,d1
.fixsize	bsr.w	PrintHex
	move.b	#' ',(a0)+	;copy generated text to buffer
	lea	DumpBuffer(b),a1
.movedis	move.b	(a1)+,(a0)+
	bmi.b	.extradisline
	bne.b	.movedis

	move.b	#pc_CLRRest,-1(a0)
	moveq	#0,d0
	move.b	CurYPos(b),d0
	lea	TextLineBuffer(b),a0
	bsr.w	PrintLine	;and print!

	move.w	(a7)+,d0	;get flags from disassembler

	cmp.b	#',',LinesType(b);check for disassemble action
	bne.b	.notdisassem

	btst	#de_Break,d0
	beq.b	.notdisassem

;	tst.w	d7	;extra scroll needed?
;	beq.w	NoPrompt

	clr.b	CurXPos(b)	;get to next line
	bsr.w	MCursorDownDO	;do nice cursor down
	bra.b	.printbreak

.extradisline	clr.b	(a0)
	move.b	#pc_CLRRest,-(a0);code prints extra line
	move.l	a1,-(a7)

	moveq	#0,d0
	move.b	CurYPos(b),d0
	lea	TextLineBuffer(b),a0
	bsr.w	PrintLine	;and print!

	clr.b	CurXPos(b)	;get to next line
	bsr.w	MCursorDownDO	;do nice cursor down

.preparenextline
	lea	TextLineBuffer(b),a0
.findspace	cmp.b	#' ',(a0)+
	bne.b	.findspace
	moveq	#MaxMnemonicLen+4-1,d0
.fillspaces	move.b	#' ',(a0)+
	dbra	d0,.fillspaces

	move.l	(a7)+,a1
	subq.w	#1,d7	;dec one for the printed line
	bra.b	.movedis

.printbreak	lea	TextLineBuffer(b),a0
.findspace2	cmp.b	#' ',(a0)+
	bne.b	.findspace2
	moveq	#BreakLineLen-1,d1
.fillbreak	move.b	#'=',(a0)+
	dbra	d1,.fillbreak	
	move.b	#pc_CLRRest,(a0)+
	clr.b	(a0)

	moveq	#0,d0
	move.b	CurYPos(b),d0
	lea	TextLineBuffer(b),a0
	bsr.w	PrintLine	;and print break line

	subq.w	#1,d7	;dec one for the printed break line
	bmi.w	NoPrompt

.notdisassem	tst.w	d6
	bne.b	.DumpArea
	dbra	d7,.DOLinesLoop
	bra.w	NoPrompt

.DumpArea	bpl.b	.noendcheck
	move.l	MemoryAddressAE(b),d0
	sub.l	MemoryAddress(b),d0
	bmi.w	NoPrompt	;end if areaend reached
.noendcheck	move.b	CurKey(b),d0
	cmp.b	#$20,d0	;stop/start scroll with space
	bne.b	.halting
	clr.b	CurKey(b)
.halt	move.b	CurKey(b),d0
	clr.b	CurKey(b)
	cmp.b	#$20,d0
	beq.b	.halting
	cmp.b	#$1b,d0
	beq.w	NoPrompt
	bra.b	.halt

.halting	cmp.b	#$1b,d0	;break with ESC
	beq.w	NoPrompt
.waitforshift	move.b	Control(b),d0	;pause with shift
	and.b	#kq_shiftmask,d0
	bne.b	.waitforshift
	moveq	#8,d7	;fake NOT END!
	bra.w	.DOLinesLoop

;---- Called by the mem altering commands to print result (only one line)
DumpLine	subq.b	#1,CurYPos(b)
	moveq	#0,d7
	moveq	#0,d6	;flag not areamode
	bra.w	DOLines


;----- Start of "Disassembly Dump Command" -----------------------------------;
DisassemLinesR	pea	DumpLinesF(pc)	;start repeat
	tst.b	CurYPos(b)
	beq.b	DODis
	subq.b	#1,CurYPos(b)
	bra.b	DODis

DisassemLines	pea	DumpLines(pc)	;start dump
DODis	lea	_LVODisAssemble(b),a2
	move.b	#',',LinesType(b)
	move.w	#RC_Disassemble,LastCommand(b);repeat if wanted
	move.b	pr_BreakLine(b),DisBreaks(b)
	rts

;----- Start of "Hex Dump Commands" ------------------------------------------;
;---- Go one up, and print hex lines
HexDumpLinesR	pea	DumpLinesF(pc)	;start repeat
	tst.b	CurYPos(b)
	beq.b	DOHex
	subq.b	#1,CurYPos(b)
	bra.b	DOHex

;---- Dump hex lines
HexDumpLines	pea	DumpLines(pc)	;start dump
	move.b	(a0)+,d0	;check for forced size
	or.b	#$20,d0
	moveq	#0,d1
	cmp.b	#'b',d0
	beq.b	.forced
	moveq	#1,d1
	cmp.b	#'w',d0
	beq.b	.forced
	moveq	#2,d1
	cmp.b	#'l',d0
	beq.b	.forced
	subq.w	#1,a0
	move.b	HexDumpSize(b),d1;use prev type
.forced	move.b	d1,HexDumpSize(b)

DOHex	move.b	#':',LinesType(b)
	move.w	#RC_HexDump,LastCommand(b)
	lea	HexDumpAdd(pc),a2
	rts		;jump to the pea address

;---- Dump hex according to prefs
;-- Input: a0 - Dump address
;-- Output:	DumpBuffer
HexDumpAdd	move.l	a0,MemoryAddress(b);set address-ptr to next address
	add.l	#$10,MemoryAddress(b)

HexDump	Push	d0-d7/a0/a2
	exg	a0,a1
	lea	DumpBuffer(b),a0
	moveq	#$f,d4
	moveq	#'0',d5
	moveq	#'9',d6
	moveq	#' ',d7
	move.b	HexDumpSize(b),d3
	bne.b	.printbytes
	moveq	#16-1,d2	;dump 16 hex-values (byte)
.printbloop	move.b	(a1)+,d0	;FAST printing of bytes
	move.b	d0,d1
	lsr.w	#4,d1
	and.w	d4,d1
	and.w	d4,d0
	add.w	d5,d0
	add.w	d5,d1
	cmp.b	d6,d0
	ble.b	.toaf00
	addq.w	#7,d0
.toaf00	cmp.b	d6,d1
	ble.b	.toaf01
	addq.w	#7,d1
.toaf01	move.b	d1,(a0)+
	move.b	d0,(a0)+
	move.b	d7,(a0)+	;put space
	dbra	d2,.printbloop
	bra.b	.printed

.printbytes	cmp.b	#1,d3
	bne.b	.printwords
	moveq	#8-1,d2	;dump 8 hex values (word)
.printwloop	move.b	(a1)+,d0
	asl.w	#8,d0
	move.b	(a1)+,d0
	moveq	#3,d1
	bsr.w	PrintHex
	move.b	d7,(a0)+
	dbra	d2,.printwloop
	bra.b	.printed

.printwords	moveq	#4-1,d2	;dump 3 hex values (long)
.printlloop	move.b	(a1)+,d0
	asl.w	#8,d0
	move.b	(a1)+,d0
	swap	d0
	move.b	(a1)+,d0
	asl.w	#8,d0
	move.b	(a1)+,d0
	bsr.w	PrintHex8
	move.b	d7,(a0)+
	dbra	d2,.printlloop

.printed	move.b	d7,(a0)+	;extra space after hex-values
	exg	a0,a1
	sub.w	#$10,a0
	move.b	#"'",(a1)+
	moveq	#16-1,d2
.printASCII	move.b	(a0)+,d0	;and then 16 ASCII values
	cmp.b	d7,d0
	blt.b	.forcespace
	cmp.b	#$7f,d0
	blt.b	.goon
.forcespace	move.b	pr_NonASCII(b),d0
.goon	move.b	d0,(a1)+
	dbra	d2,.printASCII
	move.b	#"'",(a1)+
	clr.b	(a1)
	Pull	d0-d7/a0/a2
	rts

;----- Start of "ASCII Dump Commands" ----------------------------------------;
;---- Go one up and dump ascii lines
ASCIIDumpLinesR	pea	DumpLinesF(pc)	;start repeat
	tst.b	CurYPos(b)
	beq.b	DOASCII
	subq.b	#1,CurYPos(b)
	bra.b	DOASCII

;---- dump ascii lines
ASCIIDumpLines	pea	DumpLines(pc)	;start dump

DOASCII	move.b	#';',LinesType(b)
	move.w	#RC_ASCIIDump,LastCommand(b)
	lea	ASCIIDumpAdd(pc),a2
	rts

ASCIIDumpAdd	move.l	a0,MemoryAddress(b);set address-ptr to next address
	add.l	#$40,MemoryAddress(b)

ASCIIDump	Push	d0/d1/a0/a1
	lea	DumpBuffer(b),a1
	move.b	#"'",(a1)+
	moveq	#64-1,d1

.printASCII	move.b	(a0)+,d0	;and then 64 ASCII values
	cmp.b	#' ',d0
	blt.b	.forcespace
	cmp.b	#$7f,d0
	blt.b	.goon
.forcespace	move.b	pr_NonASCII(b),d0
.goon	move.b	d0,(a1)+
	dbra	d1,.printASCII
	move.b	#"'",(a1)+
	clr.b	(a1)
	Pull	d0/d1/a0/a1
	rts

;----------------------------------------------------
;- Name	: Calculator
;- Description	: Return result of calculation to user.
;- Notes	: Needs new design.
;----------------------------------------------------
;- 270893.0000	Included in routine index.
;----------------------------------------------------

ReturnValue	bsr.w	GetValue	;get value
	lea	TextLineBuffer(b),a0
	move.b	#$0a,(a0)+
	tst.l	d0
	bpl.b	.printneghex
	move.b	#'-',(a0)+	;print neg hex (if neg)
	neg.l	d0
	bsr.w	PrintHexL
	neg.l	d0

	move.b	#' ',(a0)+
	move.b	#'(',(a0)+
	bsr.w	PrintHexL	;print hex
	move.b	#')',(a0)+

	bra.b	.printed

.printneghex	bsr.w	PrintHexL
.printed
	move.b	#' ',(a0)+
	move.b	#'|',(a0)+
	move.b	#' ',(a0)+
	bsr.w	PrintDec
	move.b	#' ',(a0)+
	tst.l	d0
	bpl.b	.printnegdec
	move.b	#'(',(a0)+
	bsr.w	PrintPosDec
	move.b	#')',(a0)+
.printnegdec	move.b	#$a,(a0)+

	move.l	d0,-(a7)
	move.b	#"'",(a0)+
	move.b	pr_NonASCII(b),d1
	moveq	#3,d2
.printascii	rol.l	#8,d0
	cmp.b	#' ',d0
	blt.b	.fixascii
	cmp.b	#$7e,d0
	ble.b	.ok
.fixascii	move.b	d1,d0
.ok	move.b	d0,(a0)+
	dbra	d2,.printascii

	move.l	(a7)+,d0
	move.b	#"'",(a0)+
	move.b	#' ',(a0)+
	move.b	#'|',(a0)+
	move.b	#' ',(a0)+
	bsr.w	PrintBin
;print ....
	clr.b	(a0)
	lea	TextLineBuffer(b),a0
	pea	NoPrompt(pc)
	bra.w	Print

;---------------T-------T---------------T------------------------------------T
;- Name	: Disk Directory.
;- Description	: Displays disk contents.
;-----------------------------------------------------------------------------;
;- 270893.0000	Included in routine index.
;- 280893.0001	Cleaned up to match the new diskhandler behaviour.
;-	Added extra DIR marker, and %free diskspace.
;- 240494	Added path-parsing.
;-----------------------------------------------------------------------------;
Directory:	moveq	#0,d0
	bsr.w	ParsePath

;	bsr.w	InitDriveDOS	;get drive status

	move.w	CurrentDir(b),d0
	grcall	GetBlock

	moveq	#EV_NOTAMIGADOSFORMAT,d1
	lea	BlockBuffer,a0
	cmp.l	#T_SHORT,(a0)
	bne.w	PrintErrorMO

	bsr.w	ChecksumBlock
	sub.l	d1,d0
	moveq	#EV_CHECKSUMERROR,d1
	tst.l	d0
	bne.w	PrintErrorMO

	lea	BlockBuffer+24,a0;poi to hash
	lea	DirectoryCache,a1;copy hash to cache
	moveq	#72-1,d0
.copycache	move.l	(a0)+,(a1)+
	dbra	d0,.copycache

	move.l	BlockBuffer+FH_CACHEBLOCK,DirCacheBlk(b);get dc-block

	lea	TextLineBuffer(b),a0
	move.l	a0,a1
	move.b	#$0a,(a1)+	;get to next line
	clr.b	(a1)
	grcall	Print

	btst	#2,DOSFormat(b)
	beq.w	.DoNormalDir

	move.l	DirCacheBlk(b),d0
	beq.w	.DirNoFiles

	grcall	GetBlock	;get first cache block
	lea	BlockBuffer,a4
	tst.l	FH_CACHECOUNT(a4)
	bne.b	.DirCacheLoop
	tst.l	FH_NEXTCACHE(a4)
	beq.w	.DirNoFiles	;no files if first is empty

.DirCacheLoop	moveq	#EV_CORRUPTDIRCACHE,d1
	cmp.l	#T_CACHE,(a4)
	bne.w	PrintErrorMO
	cmp.l	4(a4),d0	;selfptr valid?
	bne.w	PrintErrorMO
	move.l	FH_CACHECOUNT(a4),d7;get # of items in block
	subq.w	#1,d7
	bmi.b	.cacheblkempty
;confirm checksum!
	lea	6*4(a4),a3

.ProcessCache	lea	TextLineBuffer(b),a0
	tst.l	(a3)+	;skip filehdrptr
	move.l	(a3)+,d1	;get size
	move.l	(a3)+,d0	;and protectionbits
	swap	d0
	move.b	22-12(a3),d0	;+type
	moveq	#0,d2
	moveq	#0,d3
	move.b	23-12(a3),d3	;namelen
	tst.b	24-12(a3,d3.w)	;check comment
	beq.b	.nocomment4
	moveq	#1,d2
.nocomment4	bsr.w	.DirRoutine00	;and add to string
	tst.l	(a3)+
	bsr.w	.DirRoutine01	;add date to string
	addq.w	#6+1,a3
	bsr.w	.DirRoutine02	;add name and get printed

	tst.b	UserBreak(b)	;check for user-break
	bne.w	.DirExit

	dbra	d7,.ProcessCache

.cacheblkempty	move.l	FH_NEXTCACHE(a4),d0
	beq.w	.DirExit
	grcall	GetBlock
	bra.w	.DirCacheLoop

;---- Normal handler
.DoNormalDir	moveq	#1,d6
.DirSorter	moveq	#72-1,d7
	lea	DirectoryCache,a1
.DirLoop	move.l	(a1)+,d0	;get pointer
	beq.w	.noentry	;branch if no entry
	tst.w	d6
	beq.b	.GetName

	move.w	#-1,d6
	move.l	d0,d1	;check if in current track
	moveq	#0,d2
	move.b	DiskSectors(b),d2
	divu	d2,d1
	sub.w	CurrentTrack(b),d1
	beq.b	.GetName
	bpl.b	.checknear
	neg.w	d1
.checknear	cmp.w	#1,d1	;within two tracks?
	bgt.b	.noentry
	move.w	d0,d6
	swap	d6
	move.w	#2,d6

.GetName	grcall	GetBlock

	move.w	#-1,d6	;flag changed=do rerun

	lea	BlockBuffer,a4

	cmp.l	#2,(a4)	;check overall type
	bne.w	.wrongtype
;check selfptr

	lea	TextLineBuffer(b),a0

	Push	d6/d7/a1
	move.l	FH_PROTECTION(a4),d0
	swap	d0
	move.b	FH_SECTYPE+3(a4),d0
	move.l	FH_BYTELEN(a4),d1
	tst.b	FH_COMMENT(a4)	;any comment?
	sne.b	d2
	bsr.w	.DirRoutine00

	lea	FH_TIMEDAYS+2(a4),a3;convert long-data to word-data
	move.w	4(a3),2(a3)
	move.w	8(a3),4(a3)
	bsr.w	.DirRoutine01

	lea	FH_NAME(a4),a3
	bsr.w	.DirRoutine02
	Pull	d6/d7/a1

	tst.b	UserBreak(b)	;check for user-break
	bne.b	.DirExit

	move.l	FH_HASHCHAIN(a4),-(a1);check for linked hash
	bra.w	.DirLoop
.noentry
.wrongtype	dbra	d7,.DirLoop
	cmp.w	#1,d6
	beq.b	.DirNoFiles
	cmp.w	#2,d6	;flagin' next track
	bne.b	.nonext
	moveq	#0,d0
	swap	d6
	move.w	d6,d0
	grcall	LoadTrack	;get next track loaded
	bmi.w	PrintErrorMO
	bra.w	.DirSorter

.nonext	move.w	d6,d0
	moveq	#0,d6
	tst.w	d0
	bmi.w	.DirSorter

.DirExit	grcall	MotorOff
	bra.w	NoPromptNoLF

.DirNoFiles	lea	NoFilesTxt(b),a0
	bsr.w	Print
	bra.w	.DirExit

;---- Prints protection bits(d0) and length(d1)
.DirRoutine00	swap	d0
	and.w	#%1111111,d0
	swap	d0
	tst.b	d0
	bmi.b	.setdir
	cmp.b	#ST_SOFTLINK,d0
	beq.b	.link
	bset	#16+9,d0
	neg.b	d0

.setdir	cmp.b	#ST_LINKFILE,d0	;link?
	bne.b	.setlink
.link	bset	#16+7,d0
.setlink	swap	d0
	eor.w	#%1111,d0	;change the low 4 bits

	tst.b	d2
	beq.b	.nocomment
	bset	#8,d0	;flag comment
.nocomment
	lea	ProtectionChars(b),a2
	move.w	d0,-(a7)

	moveq	#9,d5	;and set 9 protection flags
.setprotect	btst	d5,d0
	beq.b	.notallowed
	move.b	(a2),(a0)+
	bra.b	.protset

.notallowed	move.b	#'-',(a0)+
.protset	addq.w	#1,a2
	dbra	d5,.setprotect

	move.b	#pc_XPos,(a0)+

	move.w	(a7)+,d0
	btst	#9,d0
	beq.b	.DIR
	lea	DirText(b),a1
	moveq	#-4,d0
	bra.b	.TextLen

.DIR	btst	#7,d0
	beq.b	.LINK
	lea	LinkText(b),a1
	moveq	#-3,d0
.TextLen	move.b	d0,(a0)+
.cp1	move.b	(a1)+,(a0)+
	bne.b	.cp1
	subq.w	#1,a0
	bra.b	.exit

.LINK	move.l	a0,a1
	clr.b	(a0)+

	move.l	d1,d0	;get length
	and.l	#$fffffff,d0	;cut top-nibble
	bsr.w	PrintHexL

	move.l	a0,d0
	sub.l	a1,d0	;calc length of printed
	moveq	#10,d1
	sub.w	d0,d1
	neg.b	d1
	move.b	d1,(a1)	;set negative length
.exit	rts

;---- add date to string
.DirRoutine01	move.l	a2,-(a7)
	move.b	#pc_XPos,(a0)+
	move.l	a0,-(a7)
	clr.b	(a0)+

	moveq	#0,d0
	move.w	(a3),d0
	move.l	#24*60*60,d1
	bsr.w	UMult32
	move.w	2(a3),d1
	mulu	#60,d1
	add.l	d1,d0
	moveq	#0,d1
	move.w	4(a3),d1
	divu	#50,d1
	swap	d1
	clr.w	d1
	swap	d1
	add.l	d1,d0
	move.l	a0,a1
	lea	DateBuffer(b),a0
	grcall	Amiga2Date
	exg	a0,a1
	moveq	#0,d0
	move.w	mday(a1),d0
	grcall	PrintDec
	move.b	#'-',(a0)+
	moveq	#0,d0
	move.w	month(a1),d0
	subq.w	#1,d0
	move.w	d0,d1
	add.w	d1,d1
	add.w	d1,d0
	lea	MonthNamesText(b),a2
	add.w	d0,a2
	move.b	(a2)+,(a0)+	;copy name of month
	move.b	(a2)+,(a0)+
	move.b	(a2)+,(a0)+
	move.b	#'-',(a0)+
	moveq	#0,d0
	move.w	year(a1),d0
	bsr.w	PrintDec
	move.b	#' ',(a0)+

	moveq	#0,d0
	move.w	hour(a1),d0
	cmp.w	#10,d0
	bge.b	.one0
	move.b	#'0',(a0)+
.one0	grcall	PrintDec
	move.b	#':',(a0)+
	moveq	#0,d0
	move.w	min(a1),d0
	cmp.w	#10,d0
	bge.b	.one1
	move.b	#'0',(a0)+
.one1	grcall	PrintDec
	move.b	#':',(a0)+
	moveq	#0,d0
	move.w	sec(a1),d0
	cmp.w	#10,d0
	bge.b	.one2
	move.b	#'0',(a0)+
.one2	grcall	PrintDec

	move.l	(a7)+,a2
	move.l	a0,d0
	sub.l	a2,d0
	moveq	#22,d1
	sub.w	d0,d1
	neg.w	d1
	move.b	d1,(a2)

	move.b	#' ',(a0)+
	move.l	(a7)+,a2
	rts


;---- add name to string and print
.DirRoutine02	moveq	#0,d0
	move.b	(a3)+,d0
	subq.w	#1,d0
	bmi.b	.nameerror	;should print error message!
	cmp.w	#35,d0
	ble.b	.lenok
	moveq	#35,d0	;max namelength = 35 chars!
.lenok	move.b	#'"',(a0)+
.copyname	move.b	(a3)+,(a0)+
	dbra	d0,.copyname
	tst.b	(a3)+
	beq.w	.nocomment3

.skipcomment	tst.b	(a3)+
	bne.b	.skipcomment
	subq.w	#1,a3
.nocomment3
.nameerror	move.b	#'"',(a0)+
	move.b	#$0a,(a0)+
	clr.b	(a0)

	move.w	a3,d0
	btst	#0,d0	;correct aligned?
	beq.b	.even
	addq.l	#1,a3
.even
	lea	TextLineBuffer(b),a0
	bra.w	Print

;----------------------------------------------------
;- Name	: Small Routines
;- Description	: Miscellaneous little routines.
;- Notes	:
;----------------------------------------------------
;- 270893.0000	Included in routine index.
;----------------------------------------------------

;---- Wait for vertical position of raster beam
;-- Input : d0 - line
;----
WaitVertical	bsr.b	.DoTheWait
	addq.w	#1,d0
.DoTheWait	move.l	vposr(h),d1
	lsr.l	#8,d1

	and.w	#$1ff,d1
	cmp.w	d0,d1
	bne.b	.DoTheWait
	rts

;---- Sum Execbase
;-- Output:	d0 - new sum
;--	d1 - old sum (will be compared at exit)
;----
;should also sum the functiontable to be more certain of a OK system!
SumExecBase	move.l	$4.w,d1
	move.l	d1,a0
	lsr.w	d1
	bcs.b	.fail	;odd address will fail
	lea	34(a0),a0
	moveq	#$16,d1
	moveq	#0,d0
.sum	add.w	(a0)+,d0
	dbra	d1,.sum
	not.w	d0
	move.w	2(a0),d1	;get old sum
	cmp.w	d0,d1
	beq.b	.ok
.fail	moveq	#EV_CORRUPTEXECBASE,d1
.ok	rts

;---- Divide two 32 bit values (D1/D0)
Divu32	Push	d2/d3
	moveq	#32,d3
	moveq	#0,d2
.divloop	sub.l	d0,d2
	bcc.b	.divskip
	add.l	d0,d2
.divskip	addx.l	d1,d1
	addx.l	d2,d2
	dbra	d3,.divloop
	not.l	d1
	Pull	d2/d3
	rts

;Kernal's UMult32
UMult32	move.l	d2,-(sp)
	move.l	d3,-(sp)
	move.l	d0,d2
	move.l	d1,d3
	swap	d2
	swap	d3
	mulu.w	d1,d2
	mulu.w	d0,d3
	mulu.w	d1,d0
	add.w	d3,d2
	swap	d2
	clr.w	d2
	add.l	d2,d0
	move.l	(sp)+,d3
	move.l	(sp)+,d2
	rts

;Kernal's UDivMod32
UDivMod32	move.l	d3,-(sp)
	swap	d1
	tst.w	d1
	bne.b	.algoNeeded
	swap	d1
	move.l	d1,d3
	swap	d0
	move.w	d0,d3
	beq.b	.label1
	divu.w	d1,d3
	move.w	d3,d0
.label1	swap	d0
	move.w	d0,d3
	divu.w	d1,d3
	move.w	d3,d0
	swap	d3
	move.w	d3,d1
	move.l	(sp)+,d3
	rts

.algoNeeded	swap	d1
	move.w	d2,-(sp)
	moveq	#15,d3
	move.w	d3,d2
	move.l	d1,d3
	move.l	d0,d1
	clr.w	d1
	swap	d1
	swap	d0
	clr.w	d0
.algoLoop	add.l	d0,d0
	addx.l	d1,d1
	cmp.l	d1,d3
	bhi.b	.skip
	sub.l	d3,d1
	addq.w	#1,d0
.skip	dbra	d2,.algoLoop
	move.w	(sp)+,d2
	move.l	(sp)+,d3
	rts


*----- End of "Command Code Objects" -----------------------------------------*

;----- Start of "Cammand Code" -----------------------------------------------;
*----- End of "Command Code" -------------------------------------------------*

;----------------------------------------------------
;- Name	: High Level Screen Library
;- Description	:
;- Notes	:
;----------------------------------------------------
;- 270893.0002	Included in routine index.
;----------------------------------------------------

;---- Print EntryText according to entry mode etc
PrintEntryText	tst.b	FirstGfxEntry(b)
	beq.b	.ShowGRPic

	tst.b	ClearScreenEntry(b)
	bne.b	.Clear

	move.b	CurYPos(b),d0
	move.w	d0,-(a7)

	lea	CharBuffer,a0
	bsr	PrintScreen

	move.w	(a7)+,d0

	bra.b	.NoGfx

.ShowGRPic	moveq	#13,d0	;adjust startline if first entry (pic)
	st.b	FirstGfxEntry(b)
	bra.b	.NoGfx

.Clear	bsr.w	ClearScreen
	moveq	#0,d0

.NoGfx	lea	OwnerText(b),a0
	move.b	d0,1(a0)
	bsr.w	Print

	Push	d2/d7
	move.w	CPUType(b),d0
	lea	CPUText(b),a0
	lea	TextLineBuffer(b),a1
.CopyCPUText	move.b	(a0)+,(a1)+
	bne.b	.CopyCPUText
	subq.w	#1,a1
	move.w	d0,d1
	and.w	#%1111,d1
	moveq	#'0'-1,d2
.FindCPUType	addq.b	#1,d2	;inc until 0 in type-list
	lsr.w	#1,d1
	bcs.b	.FindCPUType
	cmp.b	#'0',d2
	bne.b	.setO
	moveq	#'o',d2
.setO	move.b	d2,(a1)+
	move.b	(a0)+,(a1)+	;copy '0'

	REM
	moveq	#'1',d2	;check FPU
	btst	#4,d0	;start with 68881
	beq.b	.NoFPU
	btst	#5,d0
	beq.b	.SetFPU
	moveq	#'2',d2	;set 68882
.SetFPU	move.l	a0,d0
	lea	FPUText(b),a0
.CopyFPUText	move.b	(a0)+,(a1)+
	bne.b	.CopyFPUText
	move.l	d0,a0
	move.b	d2,-1(a1)	;set type (1/2)
	EREM

.NoFPU	move.b	#',',(a1)+
	move.b	#' ',(a1)+
	move.l	MaxChip(b),d1
	move.l	#'K215',d0
	swap	d1
	cmp.w	#8,d1	;512KB?
	beq.b	.ChipSize
	move.l	#'BM1',d0
	cmp.w	#$10,d1	;1MB?
	beq.b	.ChipSize
	move.l	#'BM2',d0
.ChipSize	move.b	d0,(a1)+	;copy mem-text
	lsr.l	#8,d0
	tst.b	d0
	bne.b	.ChipSize

.CopyAgnusText	move.b	(a0)+,(a1)+
	bne.b	.CopyAgnusText
	subq.w	#1,a1

	moveq	#0,d1
	lea	$1000000,a2	;now find kick-version
	sub.l	-20(a2),a2	;first find rom-size
	add.w	#$000c,a2	;jump to kick-ver number
	moveq	#0,d0	;get version
	move.w	(a2)+,d0
	move.w	d0,KickVersion(b)
.PrintVersion	divu	#10,d0	;div by 10
	swap	d0	;find rest
	add.b	#'0',d0	;and add num-base
	move.b	d0,d1	;put in buffer
	asl.l	#8,d1	;and scroll buffer
	clr.w	d0	;zap rest
	swap	d0
	tst.w	d0	;and test for more numbers
	bne.b	.PrintVersion

.DumpVersion	lsr.l	#8,d1
	move.b	d1,d0
	beq.b	.VersionPrinted
	move.b	d0,(a1)+
	bra.b	.DumpVersion

.VersionPrinted	move.b	#'.',(a1)+
	moveq	#0,d0	;get revision
	move.w	(a2)+,d0
	move.w	d0,KickRevision(b)
.PrintRevision	divu	#10,d0	;div by 10
	swap	d0	;find rest
	add.b	#'0',d0	;and add num-base
	move.b	d0,d1	;put in buffer
	asl.l	#8,d1	;and scroll buffer
	clr.w	d0	;zap rest
	swap	d0
	tst.w	d0	;and test for more numbers
	bne.b	.PrintRevision

.DumpRevision	lsr.l	#8,d1
	move.b	d1,d0
	beq.b	.RevPrinted
	move.b	d0,(a1)+
	bra.b	.DumpRevision

.RevPrinted	move.b	GrabbingSupport(b),d0;then print grabbing-status
	bne.b	.grabtxt
.skipgrab	tst.b	(a0)+
	bne.b	.skipgrab
.copynograb	move.b	(a0)+,(a1)+
	bne.b	.copynograb
	bra.b	.grabtxtready

.grabtxt	move.b	(a0)+,(a1)+	;address=$f3
	bne.b	.grabtxt
	cmp.b	#gr_Grabbing512k,d0
	bne.b	.grabtxtready
	move.b	#7,-2(a1)	;set to $f7

.grabtxtready	lea	TextLineBuffer(b),a0
	move.l	a0,a1
	moveq	#80+2,d0	;add 2 for control codes
.countcenter	subq.w	#1,d0
	tst.b	(a1)+
	bne.b	.countcenter
	lsr.w	#1,d0
	move.b	d0,1(a0)
	bsr.w	Print

	lea	HeaderText(b),a0
	bsr.w	PrintHeader

	lea	EntryText(b),a1
	lea	TextLineBuffer(b),a0
.cp1	move.b	(a1)+,(a0)+
	bne.b	.cp1
	subq.w	#1,a0
	moveq	#0,d0	;print entrymode
	move.b	EntryMode(b),d0
	subq.w	#1,d0	;first mode is 1=NMI
	lea	EntryModesText(b),a3
.findmodetext	tst.b	(a3)+
	bne.b	.findmodetext
	dbra	d0,.findmodetext
	tst.b	(a3)+	;skip the position byte
.cp2	move.b	(a3)+,(a0)+
	bne.b	.cp2
	subq.w	#1,a0
.cp3	move.b	(a1)+,(a0)+
	bne.b	.cp3
	subq.w	#1,a0

	move.l	ChipMem(b),d0	;print chip buffer
	moveq	#5,d1
	bsr.w	PrintHex
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	add.l	ChipSize(b),d0
	moveq	#5,d1
	bsr.w	PrintHex

.cp4	move.b	(a1)+,(a0)+	;"  Using "
	bne.b	.cp4

	move.b	(a3),d2	;indention

	subq.w	#1,a0
	lea	PrefStatusDef(b),a2
	cmp.l	#'USER',LoadedPrefs
	bne.b	.defaultprefs
	lea	PrefStatusMod(b),a2
	subq.b	#1,d2	;modify indention
.defaultprefs	move.b	(a2)+,(a0)+
	bne.b	.defaultprefs
	subq.w	#1,a0

.cp5	move.b	(a1)+,(a0)+
	bne.b	.cp5

	lea	TextLineBuffer(b),a0
	move.b	d2,2(a0)	;set xpos
	bsr.w	Print

	bsr.b	PrintRegs

	cmp.b	#em_ResetEntry,EntryMode(b);if Reset
	bne.b	.NotResetEntry

	tst.b	GURUEntry(b)	;check for GURU
	beq.b	.NotResetEntry
	lea	GURUText(b),a1
	lea	TextLineBuffer(b),a2
	move.l	a2,a0
.cpG1	move.b	(a1)+,(a0)+
	bne.b	.cpG1
	subq.w	#1,a0
	move.l	$100.w,d0
	bsr.w	PrintHex8

.cpG2	move.b	(a1)+,(a0)+
	bne.b	.cpG2
	subq.w	#1,a0

	move.l	$104.w,d0
	bsr.w	PrintHexL
	move.b	#'.',(a0)+
	clr.b	(a0)

	move.l	a2,a0
	bsr.w	Print

.NotResetEntry	Pull	d2/d7
	rts

;---- kill motor and print error
PrintErrorMO	grcall	MotorOff
;---- print error
PrintError:	move.w	d1,LastErrorNumber(b)
	st.b	LastCMDError(b)	;flag error in last command
	move.l	PreCMDStack(b),a7;get old SP
	tst.w	d1
	beq.b	.NoErrorToPrint
	neg.w	d1
	add.w	d1,d1
	lea	ErrorMessagesTab(b),a0
	move.w	-2(a0,d1.w),d1
	lea	ErrorMessages(b),a0
	add.w	d1,a0
;	pea	NoPrompt(pc)	;and print error
	bsr.w	Print

.NoErrorToPrint	bra.w	NoPrompt

;---- Print register values
PrintRegs	Push	d2
	lea	DataRegsText(b),a0
	lea	Regs(b),a1
	moveq	#7,d2	;print data regs
.printdataregs	move.l	(a1)+,d0
	bsr.w	PrintHex8
	addq.w	#1,a0
	dbra	d2,.printdataregs
	lea	AddressRegsText(b),a0
	moveq	#7,d2	;print data regs
.printaddregs	move.l	(a1)+,d0
	bsr.w	PrintHex8
	addq.w	#1,a0
	dbra	d2,.printaddregs

	move.l	SuperStack(b),d0;print ssp
	lea	SSPRegText(b),a0
	bsr.w	PrintHex8

	move.l	UserStack(b),d0;print usp
	lea	USPRegText(b),a0
	bsr.w	PrintHex8

	move.l	C0Reg(b),d0	;print C1
	lea	C0RegText(b),a0
	bsr.w	PrintHex8

	move.l	C1Reg(b),d0	;print C2
	lea	C1RegText(b),a0
	bsr.w	PrintHex8

	move.l	CPUVBR(b),d0	;print VBR
	lea	VBRRegText(b),a0
	bsr.w	PrintHex8

	move.l	PCReg(b),d0	;print PC
	lea	PCRegText(b),a0
	bsr.w	PrintHex8

	move.w	StatusReg(b),d0	;print SR
	moveq	#3,d1
	lea	SRRegText(b),a0
	bsr.w	PrintHex

	lea	FlagsRegText(b),a0
	moveq	#'0',d1
	moveq	#'1',d2
	move.b	d1,(a0)	;set Trace
	btst	#15,d0
	beq.b	.SetFlags00
	move.b	d2,(a0)
.SetFlags00	addq.w	#4,a0
	move.b	d1,(a0)	;set Supervisor
	btst	#13,d0
	beq.b	.SetFlags10
	move.b	d2,(a0)
.SetFlags10	addq.w	#5,a0
	move.w	d0,d2	;set IRQ Mask (0-7)
	lsr.w	#8,d2
	and.w	#%111,d2
	add.w	d1,d2
	move.b	d2,(a0)
	moveq	#'1',d2
	addq.w	#4,a0
	move.b	d1,(a0)	;set X
	btst	#4,d0
	beq.b	.SetFlags20
	move.b	d2,(a0)
.SetFlags20	addq.w	#4,a0
	move.b	d1,(a0)	;set N
	btst	#3,d0
	beq.b	.SetFlags30
	move.b	d2,(a0)
.SetFlags30	addq.w	#4,a0
	move.b	d1,(a0)	;set Z
	btst	#2,d0
	beq.b	.SetFlags40
	move.b	d2,(a0)
.SetFlags40	addq.w	#4,a0
	move.b	d1,(a0)	;set V
	btst	#1,d0
	beq.b	.SetFlags50
	move.b	d2,(a0)
.SetFlags50	addq.w	#4,a0
	move.b	d1,(a0)	;set C
	btst	#0,d0
	beq.b	.SetFlags60
	move.b	d2,(a0)
.SetFlags60
	Pull	d2
	lea	RegisterText(b),a0
	bsr.w	Print

	move.l	PCReg(b),a0
	moveq	#-1,d0	;get disassembled
	moveq	#70,d1
	grcall	DisAssemble
	move.l	a0,MemoryAddress(b)
	move.l	a0,d0
	lea	TextLineBuffer(b),a0;print address
	move.b	#10,(a0)+
	move.b	pr_Prompt(b),(a0)+
	move.b	#',',(a0)+
	bsr.w	PrintHexS
	move.b	#' ',(a0)+
	lea	DumpBuffer(b),a1;add disassembly
.loop	move.b	(a1)+,(a0)+
	bne.w	.loop
	lea	TextLineBuffer(b),a0
	bra.w	Print	;and print


;---- Print binary value
PrintBin	Push	d0/d1
	move.b	#'%',(a0)+
	moveq	#31,d1
	tst.b	pr_LeadingZeros(b)
	beq.b	.printloop
.findfirst	tst.l	d0
	bmi.b	.printloop
	add.l	d0,d0
	dbra	d1,.findfirst
	moveq	#0,d1	;only on zero

.printloop	add.l	d0,d0
	bcc.b	.nullbit
.foundbit	move.b	#'1',(a0)+
	bra.b	.geton
.nullbit	move.b	#'0',(a0)+
.geton	dbra	d1,.printloop

	Pull	d0/d1
	rts

;---- Call PrintDec but skip sign check
PrintPosDec	Push	d0-d4/a1
	bra.b	PrintDecPos

;---- Print decimal value d0 to (a0)+
PrintDec:	Push	d0-d4/a1
	tst.l	d0
	bpl.b	PrintDecPos
	neg.l	d0
	move.b	#'-',(a0)+
PrintDecPos	sub.w	#12,a7	;use stack to be reentrant
	move.l	a7,a1
;	lea	DecConvertBuf(b),a1
	moveq	#9,d4
	clr.b	(a1)+
	move.l	d0,d1
	moveq	#10,d0
.convloop	move.l	d1,d2
	bsr.w	Divu32
	move.l	d1,d3
	add.l	d3,d3
	sub.l	d3,d2
	asl.l	#2,d3
	sub.l	d3,d2
	add.b	#'0',d2
	move.b	d2,(a1)+
	tst.l	d1
	beq.b	.print
	dbra	d4,.convloop
.print	move.b	-(a1),(a0)+
	bne.w	.print
	subq.w	#1,a0

	add.w	#12,a7

	Pull	d0-d4/a1
	rts

;---- print '$' and hex according to leadingzeroes-flag
PrintHexL:	move.b	#'$',(a0)+
	tst.b	pr_LeadingZeros(b)
	beq.b	PrintHexS
	Push	d0/d2-d5/a1
	moveq	#-1,d1
	move.l	d0,d2
.countloop	lsr.l	#4,d2
	addq.w	#1,d1
	tst.l	d2
	bne.w	.countloop
	bra.b	PrintHexSS

;---- print '$' and hex according to shortaddress-flag
PrintHexS	move.b	#'$',(a0)+
PrintHexS2	moveq	#7,d1	;adjust address len to prefs
	tst.b	pr_ShortAddress(b)
	beq.b	.fixsizee
	moveq	#5,d1
.fixsizee	bra.b	PrintHex

PrintHex82	move.b	#'$',(a0)+
PrintHex8	moveq	#7,d1	;print 8 letters
;---- Print hex value D0 to (A0)+ (D1 letters)
PrintHex:	Push	d0/d2-d5/a1
PrintHexSS	lea	1(a0,d1.w),a0
	move.l	a0,a1
	moveq	#$f,d3
	moveq	#'0',d4
	moveq	#'9',d5
.PrintHexLoop	move.w	d0,d2
	lsr.l	#4,d0
	and.w	d3,d2
	add.b	d4,d2
	cmp.b	d5,d2
	ble.b	.dig
	addq.w	#7,d2
.dig	move.b	d2,-(a1)
	dbra	d1,.PrintHexLoop
	Pull	d0/d2-d5/a1
	rts

;--------------------------------------- Header Printers
;---- Print flags in header
;-- E/-	Error in last command
;-- Empty
;-- 0-3	Selected Drive
;-- Empty
;-- i/o	Insert/Overwrite mode
;----
PrintFlags	Push	d0/d2/a0/a1/a4
	lea	TextLineBuffer(b),a0
	moveq	#'-',d0	;check error in last command
	tst.b	LastCMDError(b)
	beq.b	.noerror
	moveq	#'E',d0
.noerror	move.b	d0,(a0)+

	moveq	#' ',d0
	move.b	d0,(a0)+	;empty

	moveq	#'0',d0	;selected drive
	add.b	SelectedDrive(b),d0
	move.b	d0,(a0)+

	moveq	#' ',d0
	move.b	d0,(a0)+	;empty

	moveq	#'o',d0	;insert/overwrite mode
	tst.b	InsertOverwrite(b)
	beq.b	.ow
	moveq	#'i',d0
.ow	move.b	d0,(a0)+
	clr.b	(a0)
	lea	TextLineBuffer(b),a0
	move.l	HeaderAddress(b),a1;get pointer to header
	add.w	#69,a1	;call the printroutine
	move.l	a0,a4	;write back to textbuffer
	move.b	CurXPos(b),d2
	bsr.w	DoThePrintGfx
	move.b	d2,CurXPos(b)
	Pull	d0/d2/a0/a1/a4
	rts

;---- Print last error in header
PrintLEInHeader	tst.b	LastCMDError(b)
	beq.b	.noerror
	lea	ErrorMessagesTab(b),a0
	move.w	LastErrorNumber(b),d0;any error?
	beq.b	.noerror
	st.b	ReprintHeader(b);flag header is not normal
	neg.w	d0
	add.w	d0,d0
	move.w	-2(a0,d0.w),d0	;find offset
	lea	ErrorMessages(b),a0
	lea	1(a0,d0.w),a0	;then text
	bra.w	PrintHeader	;and print it
.noerror	rts

;---- Print CA, CB, NJ and LA in header
PrintHeaderInfo	moveq	#0,d2
PrintHeaderINCB	bsr.b	PrintCANJLA
	bsr.w	EditPrintArea
	clr.b	(a0)
	lea	TextLineBuffer(b),a0
	bra.w	PrintHeader

;d2 0=current byte/1=no current byte
PrintCANJLA	lea	TextLineBuffer(b),a0
	lea	HeaderInfo(pc),a1
.copytxt1	move.b	(a1)+,(a0)+
	bne.b	.copytxt1
	subq.w	#1,a0
	move.l	MemoryAddress(b),d0;print current address
	bsr.w	PrintHexS
	tst.w	d2
	beq.b	.copytxt2	;print cb if d2=0
.skipcb	tst.b	(a1)+
	bne.b	.skipcb
	bra.b	.nocb

.copytxt2	move.b	(a1)+,(a0)+
	bne.b	.copytxt2
	subq.w	#1,a0
	moveq	#1,d1
	move.l	d0,a2
	move.b	(a2),d0
	bsr.w	PrintHex	;print current byte
.nocb

.copytxt4	move.b	(a1)+,(a0)+	;get NJ txt
	bne.b	.copytxt4
	subq.w	#1,a0
	moveq	#0,d0
	move.b	NestedJumps(b),d0
	addq.b	#1,d0
	bsr.w	PrintDec

.copytxt5	move.b	(a1)+,(a0)+	;get LA txt
	bne.b	.copytxt5
	subq.w	#1,a0
	move.b	NestedJumps(b),d0
	bmi.b	.noaddress
	asl.w	#2,d0
	lea	NestedJMPTable(b),a2
	move.l	(a2,d0.w),d0
	bsr.w	PrintHexS
	bra.b	.NJDone

.noaddress	moveq	#7,d0
	move.b	pr_ShortAddress(b),d1
	beq.b	.bit32
	moveq	#5,d0
.bit32	move.b	#'-',(a0)+
	dbra	d0,.bit32

.NJDone	rts


;----- Start of "Get Header Input" -------------------------------------------;
;---- Get input in header
;- Input:	a0 - Initial Text
;-	(a2 - initial input)
;- Output:	d0 - 0/1 = ok / user break
;-	Zero terminated input string in InputLine.
;----
GetHeaderInput	sub.l	a2,a2	;no pretext
GetHeaderInputP	Push	d2-d7/a3-a4
	move.l	a0,a1	;save initial text for reprint (help)
	move.l	a0,HeadIniText(b)
	moveq	#68,d7	;max input len
.findlen	subq.w	#1,d7	;find actual input len
	tst.b	(a1)+
	bne.b	.findlen
	move.b	d7,HMaxXPos(b)	;set max xpos
	move.l	a2,-(a7)
	bsr.w	PrintHeader	;print initial text
	move.l	(a7)+,a2
	move.l	a1,a3	;^ will return gfxpos in a1
	addq.w	#1,a3	;leave space between
	moveq	#68,d6
	sub.b	d7,d6
	move.b	d6,HXPosOffset(b);set xpos offset
	clr.b	HCurXPos(b)	;clear xpos
	clr.b	HLastLetter(b)	;clear last letterpos
	lea	InputLine(b),a4

	move.l	a2,d0	;any pre-input?
	beq.b	.noinput
.copyinput	addq.b	#1,HLastLetter(b)
	addq.b	#1,HCurXPos(b)
	move.b	(a2)+,(a4)+
	bne.w	.copyinput

	subq.b	#1,HLastLetter(b)
	subq.b	#1,HCurXPos(b)

	bra.w	.MovedBack

.noinput	clr.b	(a4)	;clear last char

.GHLoop	bsr.w	HeaderCursor	;set cursor

.GetHeaderILoop	bsr.w	PasteText	;if needed

;	moveq	#0,d0	;wait for key-press
;	move.b	CurKey(b),d0
	beq.b	.GetHeaderILoop
	clr.b	CurKey(b)

	cmp.b	#$1b,d0	;escape forces exit
	beq.b	.ReturnFail

	cmp.b	#$0a,d0	;return
	bne.b	.Enter
	move.b	Control(b),d1
	move.b	d1,d0
	and.b	#kq_shiftmask,d0;skip line?
	bne.b	.ReturnFail
	lea	InputLine(b),a0	;return ok
	and.b	#kq_altmask,d1	;if not clear
	beq.b	.Exit
	clr.b	(a0)	;clear first letter
	move.l	a0,a1
	bra.b	.UpdateLoop	;and update line

.Exit	tst.b	HLastLetter(b)
	beq.b	.ReturnFail
	lea	InputLine(b),a1
	bsr.w	AddToHistory	;add line to history
	moveq	#0,d0
	bra.b	.ReturnOK
	
.ReturnFail	moveq	#-1,d0	;return fail
.ReturnOK	Pull	d2-d7/a3-a4
	tst.w	d0	;test fail
	rts

.Enter	bsr.w	HeaderCursor	;disable cursor
	move.b	Control(b),d1
	cmp.b	#1,d0	;cursor up?
	bne.b	.CursorUP
	moveq	#1,d0	;scroll history up
.DoTheHistory;	and.b	#kq_altmask,d1	;check alt
;	beq.b	.GHLoop	;SKIP THE ALT-PART!
	bsr.w	GetHistory
.UpdateLoop	pea	.GHLoop(pc)
.UpdateLine	Push	d0/d1/a0/a1	;reprint buffer
	clr.b	HCurXPos(b)
	bsr.w	ClearHeader	;clear old input string
	lea	InputLine(b),a4	;get to start of input-buffer
	moveq	#0,d0
	move.b	HMaxXPos(b),d0
	move.w	d0,d1
.copy	move.b	(a1)+,(a4)+	;copy max chars or untill null
	dbeq	d1,.copy
	subq.w	#1,a4	;must point to NULL-terminator
	sub.w	d1,d0	;find last letter
	move.b	d0,HCurXPos(b)	;set xpos
	move.b	d0,HLastLetter(b)
	lea	InputLine(b),a0
	moveq	#0,d0
	move.b	HXPosOffset(b),d0
	bsr.w	PrintHeaderD	;print new line
	move.l	a1,a3
	Pull	d0/d1/a0/a1
	rts

.CursorUP	cmp.b	#2,d0	;check for down
	bne.b	.CursorDOWN
	moveq	#-1,d0	;scroll history down
	bra.b	.DoTheHistory

.CursorDOWN	cmp.b	#3,d0	;check for right
	bne.b	.CursorRIGHT
	move.b	HLastLetter(b),d0
	and.b	#kq_shiftmask,d1;single/far
	bne.b	.SetXPos
	cmp.b	HCurXPos(b),d0	;check for need to go right
	beq.w	.GHLoop
	addq.b	#1,HCurXPos(b)
	addq.w	#1,a3
	bra.w	.GHLoop

.SetXPos	move.b	d0,HCurXPos(b)	;set xpos
	add.b	HXPosOffset(b),d0;and calc new cursor pos
	and.w	#$ff,d0
	move.l	HeaderAddress(b),a3
	add.w	d0,a3
	bra.w	.GHLoop

.CursorRIGHT	cmp.b	#4,d0	;check for left
	bne.b	.CursorLEFT
	moveq	#0,d0
	and.b	#kq_shiftmask,d1;single/far?
	bne.b	.SetXPos	;clear xpos if far left
	tst.b	HCurXPos(b)
	beq.w	.GHLoop	;left not valid
	subq.b	#1,HCurXPos(b)
	subq.w	#1,a3
	bra.w	.GHLoop

.CursorLEFT	cmp.b	#$08,d0	;check for backspace
	bne.b	.BackSpace
	tst.b	HCurXPos(b)
	beq.w	.GHLoop	;already on far left?
	and.b	#kq_shiftmask,d1
	bne.b	.DelToBOL	;delete to beginning of line?
	subq.b	#1,HCurXPos(b)	;no, only kill one letter (xpos-1)
.DelMain	subq.b	#1,HLastLetter(b);kill letter on xpos ; -1 letter
	moveq	#0,d0
	move.b	HCurXPos(b),d0
	lea	InputLine(b),a0
	add.w	d0,a0
	lea	1(a0),a1
	bra.b	.MoveBack	;will copy form a1 to a0

.DelToBOL	moveq	#0,d0	;del to BOL ; get xpos
	move.b	HCurXPos(b),d0
	clr.b	HCurXPos(b)
	sub.b	d0,HLastLetter(b);sub from len-count

	lea	InputLine(b),a0	;delete prev text
	lea	(a0,d0.w),a1
.MoveBack	move.b	(a1)+,(a0)+	;copy until NULL
	bne.b	.MoveBack
.MovedBack	lea	InputLine(b),a1	;(called by reprint)
	moveq	#0,d0
	move.b	HCurXPos(b),d0
	pea	.SetXPos(pc)	;set old xpos after print
	bra.w	.UpdateLine	;update line

.BackSpace	cmp.b	#$7f,d0	;check delete
	bne.b	.Delete
	move.b	d1,d0
	and.b	#kq_altmask,d0	;change insert/overwrite mode?
	beq.b	.nochange
	not.b	InsertOverwrite(b);change mode
	pea	.GHLoop(pc)
	bra.w	PrintFlags	;print flags

.nochange	moveq	#0,d0	;on max pos?
	move.b	HCurXPos(b),d0
	cmp.b	HLastLetter(b),d0;if so, no delete
	beq.w	.GHLoop
	and.b	#kq_shiftmask,d1;to end of line
	beq.b	.DelMain	;no, delete one letter

.DelToEOL	lea	InputLine(b),a0	;clear current letter
	clr.b	(a0,d0.w)	;(mark rest as dead)
	bra.b	.MovedBack

.Delete	cmp.b	#138,d0	;check for help
	bne.b	.PrintLetter
	tst.w	LastErrorNumber(b);any last error?
	beq.w	.GHLoop
	bsr.w	PrintLEInHeader	;yeah, print
.wait	tst.b	CurKey(b)	;wait for keypress
	beq.b	.wait
	clr.b	CurKey(b)
	move.l	HeadIniText(b),a0;and reprint
	bsr.w	PrintHeader
	bra.b	.MovedBack

.PrintLetter	cmp.b	#' ',d0	;check for characters
	blt.w	.GHLoop
	cmp.b	#'z',d0
	bgt.w	.GHLoop
	moveq	#0,d2
	move.b	HLastLetter(b),d2
	cmp.b	HMaxXPos(b),d2
	beq.w	.GHLoop	;skip if buffer full
	moveq	#0,d3
	move.b	HCurXPos(b),d3
	lea	InputLine(b),a0
	tst.b	InsertOverwrite(b);check insert/ow
	beq.b	.overwrite
.insertspace	lea	1(a0,d2.w),a0	;if insert
	sub.b	d3,d2	;copy ?
.insertletter	move.b	-(a0),1(a0)	;chars backwards
	dbra	d2,.insertletter
	move.b	d0,(a0)	;then insert the new letter
	cmp.b	#' ',d0
	bne.b	.insertend
	tst.b	InsertOverwrite(b);inserted space? (no xpos move)
	beq.b	.insertedspace
.insertend	addq.b	#1,HLastLetter(b)
.insertmiddle	addq.b	#1,HCurXPos(b)
	bra.w	.MovedBack

.insertedspace	addq.b	#1,HLastLetter(b);different behavior cmp with std input
	bra.w	.MovedBack

.overwrite	and.b	#kq_shiftmask,d1;shifted=insert space?
	bne.b	.insertspace
	lea	(a0,d3.w),a0	;just put on xpos
	move.b	d0,(a0)+
	sub.b	d2,d3	;check for last letter
	bne.b	.insertmiddle
	clr.b	(a0)	;if so, make sure to put NULL
	bra.b	.insertend

;---- Clear Header from HXPosOffset
ClearHeader	moveq	#0,d0
	move.b	HXPosOffset(b),d0
ClearHeaderE	move.l	HeaderAddress(b),a0;get pointer to header
	add.w	d0,a0
	moveq	#72-4,d1
	sub.w	d0,d1
	moveq	#0,d0
.clearloop	move.b	d0,$50(a0)
	move.b	d0,$a0(a0)
	move.b	d0,$f0(a0)
	move.b	d0,$140(a0)
	move.b	d0,$190(a0)
	move.b	d0,$1e0(a0)
	move.b	d0,$230(a0)
	move.b	d0,(a0)+
	dbra	d1,.clearloop
	rts

;---- Invert char on current pos (a3)
HeaderCursor	moveq	#-1,d4	;eor character to display cursor
	eor.b	d4,(a3)
	eor.b	d4,$50(a3)
	eor.b	d4,$a0(a3)
	eor.b	d4,$f0(a3)
	eor.b	d4,$140(a3)
	eor.b	d4,$190(a3)
	eor.b	d4,$1e0(a3)
	eor.b	d4,$230(a3)
	rts

;----------------------------------------------------
;- Name	: LowLevel Screen Library.
;- Description	:
;- Notes	:
;----------------------------------------------------
;- 270893.0001	Included in routine index.
;----------------------------------------------------

;---- Scroll screen
;-- Input:	D0	- #lines and direction
;----
ScrollScreen	Push	d1/d2/d6/d7/a0-a3
	move.w	d0,d7
	move.l	CharPointer(b),a0
	muls	#80,d0
	bpl.b	.ScrollUP
	moveq	#-80,d6	;scroll buffer down
	move.w	TextLines(b),d1
	subq.w	#2,d1
	mulu	#80,d1
	lea	(a0,d1.w),a1	;dest = last line
	lea	(a1,d0.w),a0	;source=lastline-lines*80
	bra.b	.DoTheCharScroll

.ScrollUP	move.l	a0,a1	;dest=topline
	add.w	d0,a0	;source=topline+lines*80
	moveq	#80,d6	;scroll buffer up

.DoTheCharScroll	
	move.w	d7,d1
	bpl.b	.fix
	neg.w	d1
	addq.w	#1,d1	;fixes bug when scrolling text down!?!
.fix	move.w	TextLines(b),d2
	sub.w	d1,d2
	subq.w	#1,d2
.charscroll	move.l	a0,a2
	move.l	a1,a3
	add.w	d6,a0
	add.w	d6,a1
	rept	80/4
	move.l	(a2)+,(a3)+
	endr
	dbra	d2,.charscroll

	move.w	BplSize(b),d1	;fix pointer
	asl.w	#3,d0	;multiply with line size
	add.w	LineBase(b),d0	;and add to current pos
	bpl.b	.fixoffset
	add.l	d1,d0	;correct if neg value
.fixoffset	cmp.w	d1,d0	;correct if too big
	bmi.b	.fixoffset2
	sub.w	d1,d0
.fixoffset2	move.w	d0,LineBase(b)
	neg.w	d7
	asl.w	#2,d7	;fix split line
	tst.b	LaceMode(b)
	bne.b	.NoLace8
	asl.w	#1,d7
.NoLace8	move.w	SplitLine(b),d0
	add.w	d7,d0

	move.w	Lines(b),d1
	tst.b	LaceMode(b)
	beq.b	.NoLace7
	lsr.w	#1,d1
.NoLace7
	cmp.w	StartLine(b),d0	;check top pos
	bgt.b	.fixsplit
	add.w	d1,d0
	bra.b	.splitfixed

.fixsplit	cmp.w	InitLine(b),d0;check bottom pos
	blt.b	.splitfixed
	sub.w	d1,d0

.splitfixed	move.w	d0,SplitLine(b)
	Pull	d1/d2/d6/d7/a0-a3;nothing between this line and zscrpts

;---- Set screen pointers
SetScreenPts	Push	d1/a0
	move.w	#$4000,intena(h)
	moveq	#0,d0	;set bpl pointer
	move.w	LineBase(b),d0
	add.l	ScreenBase(b),d0
	move.l	d0,NFBplPoi(b)

	move.l	#$01fe01fe,d1	;set splitline raster pos
	move.w	SplitLine(b),d0
	cmp.w	#$100,d0
	blt.b	.inpal
	move.l	#$ffe1fffe,d1	;if in pal set WAITPAL
	tst.b	WidePalWait(b)
	bne.b	.inpal
	move.l	#$ff71fffe,d1	;if in pal set WAITPAL
.inpal	move.l	d1,NFPalFix(b)
	move.b	d0,NFLineFix2(b)
	move.w	#$c000,intena(h)
	Pull	d1/a0
	rts

;---- Call to set screen pointers to default
InitScreenPts	move.l	ScreenMem(b),ScreenBase(b)
	clr.w	LineBase(b)
	move.w	InitLine(b),SplitLine(b)
	bra.b	SetScreenPts

;---- Print line to screen
;-- A0=text (zero terminated)
;-- D0=line number
PrintLineStack	reg	d0/a2/a3/a4
PrintLine:	Push	PrintLineStack
	move.w	LineBase(b),d1	;get line base (offset of current line)
	mulu	#80*8,d0	;get line offset
	add.w	d0,d1	;and add
	moveq	#0,d0
	move.w	BplSize(b),d0
	cmp.l	d0,d1	;if violating size
	blt.b	.fix
	sub.l	d0,d1	;then cut off
.fix	move.l	ScreenBase(b),a1
	add.w	d1,a1	;then get actual address
DoThePrintStart	moveq	#0,d0	;call this address if destpoi is calced
	moveq	#0,d1	;find charbuffer address
	move.b	CurYPos(b),d0
	mulu	#80,d0
	move.b	CurXPos(b),d1
	add.w	d1,d0
	add.l	CharPointer(b),d0
	move.l	d0,a4
DoTPSGFX	lea	Font,a2	;call if destpoi is calced and no chars
.ZLetter	moveq	#0,d0
	move.b	(a0)+,d0	;print until char<' '
	bmi.b	.fixletter
.fixed	move.w	d0,d1
	sub.w	#' ',d0	;else sub charbase
	bmi.b	.PrintLineExit
	move.b	d1,(a4)+
	addq.b	#1,CurXPos(b)	;inc cursor xpos
	asl.w	#3,d0
	lea	(a2,d0.w),a3	;get real char address
	move.b	(a3)+,(a1)+	;copy letter
	move.b	(a3)+,1*80-1(a1)
	move.b	(a3)+,2*80-1(a1)
	move.b	(a3)+,3*80-1(a1)
	move.b	(a3)+,4*80-1(a1)
	move.b	(a3)+,5*80-1(a1)
	move.b	(a3)+,6*80-1(a1)
	move.b	(a3),7*80-1(a1)
	bra.b	.ZLetter

.fixletter	move.b	pr_NonASCII(b),d0;for letters not supported by charset
	bra.b	.fixed

.PrintLineExit	cmp.b	#pc_CLRRest,d1;flag to clear remaining letters?
	bne.b	.doexit
	moveq	#79,d0	;find len
	sub.b	CurXPos(b),d0
	move.l	a4,a3	;also clear charbuffer
	moveq	#0,d1
.clearloop	move.b	d1,(a1)+	;and clear remaining letters
	move.b	d1,1*80-1(a1)
	move.b	d1,2*80-1(a1)
	move.b	d1,3*80-1(a1)
	move.b	d1,4*80-1(a1)
	move.b	d1,5*80-1(a1)
	move.b	d1,6*80-1(a1)
	move.b	d1,7*80-1(a1)
	move.b	#' ',(a3)+
	dbra	d0,.clearloop
	moveq	#pc_CLRRest,d1

.doexit	Pull	PrintLineStack	;must match the push of code calling
	rts		;DoThePrint direct

DoThePrint	Push	PrintLineStack
	bra.w	DoThePrintStart

DoThePrintGfx	Push	PrintLineStack
	bra.w	DoTPSGFX

;---- Print one letter (called by the key-board handlers)
; d0 -	ascii value
;----
PrintLetter	pea	MainLoop
PrintLetterR	pea	MCursorRightDO
PrintLetterN	moveq	#0,d1
	move.b	CurYPos(b),d1
	moveq	#0,d3
	move.b	CurXPos(b),d3
	mulu	#80,d1
	move.w	d1,d2
	asl.w	#3,d1	;find gfx pos
	add.w	d3,d1
	add.w	LineBase(b),d1
	moveq	#0,d4
	move.w	BplSize(b),d4
	cmp.l	d4,d1
	bmi.b	.fix
	sub.l	d4,d1
.fix	add.l	ScreenBase(b),d1
	move.l	d1,a1
	lea	Font,a0
	move.w	d0,d1
	sub.w	#' ',d1
	asl.w	#3,d1
	lea	(a0,d1.w),a0
	move.b	(a0)+,(a1)	;set letter
	move.b	(a0)+,1*80(a1)
	move.b	(a0)+,2*80(a1)
	move.b	(a0)+,3*80(a1)
	move.b	(a0)+,4*80(a1)
	move.b	(a0)+,5*80(a1)
	move.b	(a0)+,6*80(a1)
	move.b	(a0)+,7*80(a1)

	add.w	d2,d3
	add.l	CharPointer(b),d3
	move.l	d3,a0
	move.b	d0,(a0)	;set char
	rts

;---- Print text line
PrintLines	bsr.b	ClearLine
	bsr.w	PrintLine	;print first line
	addq.b	#1,CurYPos(b)	;inc cursor ypos
	clr.b	CurXPos(b)	;reset cursor xpos
	addq.w	#1,d0
	cmp.w	TextLines(b),d0
	bne.b	.scroll
	cmp.b	#$0a,d1
	bne.b	.scroll
	subq.b	#1,CurYPos(b)	;dec cursor ypos
	subq.w	#1,d0	;fix line #
	Push	d0
	moveq	#1,d0	;scroll screen one up
	bsr.w	ScrollScreen
	Pull	d0
.scroll	cmp.b	#$0a,d1	;was last char 10?
	beq.b	PrintLines	;if it was print next line
	rts

;---- Clear line
ClearLine	Push	d0/d1/d2/a1
	moveq	#0,d2
	mulu	#80,d0	;get line offset
	move.w	d0,d2
	asl.w	#3,d0	;*8 to get bitmap address
	move.l	CharPointer(b),a1;clear line in charbuffer
	add.w	d2,a1
	move.l	#'    ',d2
	moveq	#80/4-1,d1	;zap 80 chars
.clearchar	move.l	d2,(a1)+
	dbra	d1,.clearchar
	moveq	#0,d1
	move.w	LineBase(b),d1	;get line base (offset of current line)
	add.w	d0,d1	;and add
	moveq	#0,d0
	move.w	BplSize(b),d0
	cmp.l	d0,d1	;if violating size
	bmi.b	.fix
	sub.l	d0,d1	;then cut off
.fix	add.l	ScreenBase(b),d1
	move.l	d1,a1
	moveq	#0,d1
	moveq	#7,d0	;clear 8 lines
.clearline	rept	80/4
	move.l	d1,(a1)+
	endr
	dbra	d0,.clearline
	Pull	d0/d1/d2/a1
	rts

;---- Print lines until screen is full (1 by 1)
;-- Call to print line by line... (a0=textstring, no ret!)
MoreLine	bsr.w	Print
	lea	FeedLineText(b),a0
	bsr.w	Print
	subq.b	#1,MoreLines(b)
	beq.b	.askformore
	moveq	#0,d0	;continue=ok
	rts

.askformore	lea	MoreText(b),a0
	bsr.w	Print

	clr.b	CurKey(b)
.waitforkey	tst.b	ExitFlag(b)
	bne.b	.MoreEnded	;user forces exit with icon!
	move.b	CurKey(b),d7
	beq.w	.waitforkey

	subq.b	#1,CurYPos(b)	;clear req-lines
	moveq	#0,d0
	clr.b	CurXPos(b)
	move.b	CurYPos(b),d0
	bsr.w	ClearLine
	addq.w	#1,d0
	bsr.w	ClearLine

	cmp.b	#$1b,d7	;and check for more
	beq.b	.MoreEnded
	or.b	#$20,d7
	cmp.b	#'q',d7
	bne.b	MoreLineReset

.MoreEnded	moveq	#-1,d0	;flag "skip rest"
	rts

;-- Call to init more-printing
MoreLineReset	move.w	TextLines(b),d0
	subq.w	#2,d0
	move.b	d0,MoreLines(b)
	clr.b	CurXPos(b)	;since moreline don't do it
	rts

;---- Print list of available Commands (HELP)
;- Input:	D6 -	Line mask (Editor-help share lines)
;-	A0 -	Help Text
;---
PrintHelp:	pea	RestoreHelp(pc)
PrintHelpNoRZUP	st.b	HideCursor(b)
	Push	d6
	lea	HelpCharBack,a2
	move.l	CharPointer(b),a1
	move.w	#CharBSize/4-1,d0
.getbackup	move.l	(a1)+,(a2)+
	dbra	d0,.getbackup
	move.w	CurXPos(b),HelpPosBack(b)

	bsr.w	ClearScreen

	Push	a0
	lea	HeaderHelpText(b),a0
	bsr.w	PrintHeader
	Pull	a0
	Pull	d6

;--- more!
	move.w	TextLines(b),d7
	subq.w	#2,d7	;leave 2 lines for 'continue' text
.PrintMoreLoop	move.w	d7,d5

.moreloop	tst.b	(a0)
	beq.b	.Continue	;end if last line
	tst.w	d6	;Check mask flags?
	beq.b	.nomask
	move.b	(a0)+,d0
	and.w	d6,d0	;should this line be printed?
	bne.b	.nomask	;if value&mask = !0 then yes!
.searchnewline	cmp.b	#10,(a0)+	;if not print, search next line
	bne.b	.searchnewline
	bra.b	.moreloop

.nomask	moveq	#1,d4	;print text linewize!
	bsr.w	PrintMore
	subq.w	#1,d5
	bne.b	.moreloop
	Push	a0
	lea	MoreText(b),a0
	bsr.w	Print
	Pull	a0

	clr.b	CurKey(b)
.waitforkey	tst.b	ExitFlag(b)
	bne.b	.HelpEnded	;user forces exit with icon!
	move.b	CurKey(b),d0
	beq.w	.waitforkey
	cmp.b	#$1b,d0
	beq.b	.HelpEnded
	or.b	#$20,d0
	cmp.b	#'q',d0
	beq.b	.HelpEnded

	subq.b	#1,CurYPos(b)
	moveq	#0,d0
	clr.b	CurXPos(b)
	move.b	CurYPos(b),d0
	bsr.w	ClearLine
	addq.w	#1,d0
	bsr.w	ClearLine
	bra.b	.PrintMoreLoop

.Continue	lea	HelpContText(b),a0
	bsr.w	Print

	clr.b	CurKey(b)
.waitforkey2	tst.b	ExitFlag(b)
	bne.b	.HelpEnded	;user forces exit with icon!
	tst.b	CurKey(b)
	beq.w	.waitforkey2

.HelpEnded	clr.b	CurKey(b)
	st.b	ReprintHeader(b);flag header is not normal
	clr.b	DisplayHelp(b)
	clr.b	HideCursor(b)
	rts

RestoreHelp	lea	HelpCharBack,a0
	move.w	HelpPosBack(b),d7

;---- Print Screen from (backup)buffer
;- INPUT:	a0	- screen buffer
;----
PrintScreen;	bsr.w	ClearScreen
	bsr.w	InitScreenPts	;init pointers
	move.l	ScreenBase(b),a1
	move.l	CharPointer(b),a4
	lea	Font,a2
	move.w	TextLines(b),d1
	subq.w	#1,d1
.FastPrintLoop1	moveq	#79,d2
.FastPrintLoop2	moveq	#0,d0
	move.b	(a0)+,d0	;print until char<' '
	move.b	d0,(a4)+
	sub.b	#' ',d0	;else sub charbase
	asl.w	#3,d0
	lea	(a2,d0.w),a3	;get real char address
	move.b	(a3)+,(a1)+	;copy letter
	move.b	(a3)+,1*80-1(a1)
	move.b	(a3)+,2*80-1(a1)
	move.b	(a3)+,3*80-1(a1)
	move.b	(a3)+,4*80-1(a1)
	move.b	(a3)+,5*80-1(a1)
	move.b	(a3)+,6*80-1(a1)
	move.b	(a3),7*80-1(a1)

	dbra	d2,.FastPrintLoop2
	add.w	#80*7,a1
	dbra	d1,.FastPrintLoop1
	move.w	d7,CurXPos(b)
	rts

;---- Print Control Codes (171192)
pc_END	=	0
pc_Pos	=	1	;set pos (x,y)
pc_XPos	=	2	;set xpos (x) (+ static, - dynamic)
pc_YPos	=	3	;set ypos (y) (^)
pc_CLR	=	4	;clear screen
pc_CLRLine	=	5	;clear current line
pc_CLRRest	=	6	;faster clear line
pc_LF	=	$0a	;Line Feed+CR

;---- Print text with control codes
Print:	moveq	#0,d4	;many lines!
			;(but also counter!)
PrintMore	Push	d5-d7

.PrintLoop	move.b	(a0)+,d0	;get char/code
	beq.w	.PrintExit	;and check for exit
.PrintContinue	cmp.b	#pc_LF,d0	;Check Return
	bne.b	.TPCReturn
	clr.b	CurXPos(b)
	grcall	MCursorDownDO
	subq.w	#1,d4	;only print x lines
	beq.w	.PrintExit
	bra.b	.PrintLoop

.TPCReturn	cmp.b	#pc_Pos,d0	;Check Position
	bne.b	.TPCPos
	move.b	(a0)+,CurXPos(b);set Pos
.PCYPos	move.b	(a0)+,CurYPos(b)
	bra.b	.PrintLoop

.TPCPos	cmp.b	#pc_YPos,d0	;Check YPos
	beq.w	.PCYPos	;set ypos
	cmp.b	#pc_XPos,d0	;Check XPos
	bne.b	.TPCXPos
	move.b	(a0)+,d0
	bpl.b	.simple	;static if >0
	neg.b	d0
	add.b	CurXPos(b),d0	;dynamic
.simple	move.b	d0,CurXPos(b);set xpos
	bra.b	.PrintLoop

.TPCXPos	cmp.b	#pc_CLR,d0	;check Clear
	bne.b	.TPCClear
	bsr.b	ClearScreen	;clear screen
	bra.b	.PrintLoop

.TPCClear	cmp.b	#pc_CLRLine,d0	;check clear line
	bne.b	.TPCClearLine
	moveq	#0,d0	;clear current line
	move.b	CurYPos(b),d0
	bsr.w	ClearLine
	bra.b	.PrintLoop

.TPCClearLine	cmp.b	#pc_CLRRest,d0
	beq.b	.PrintLoop	;if clrrest, go on...

	subq.w	#1,a0	;no controlcode->set pointer back
	moveq	#0,d7	;calculate print position
	moveq	#0,d6
	move.b	CurYPos(b),d7
	mulu	#80*8,d7
	move.b	CurXPos(b),d6
	add.w	d6,d7
	add.w	LineBase(b),d7
	move.w	BplSize(b),d6
	cmp.l	d6,d7
	blt.b	.fix
	sub.l	d6,d7
.fix	add.l	ScreenBase(b),d7
	move.l	d7,a1
	move.l	d4,-(a7)
	bsr.w	DoThePrint	;and call line print routine
	move.l	(a7)+,d4
	move.b	d1,d0	;check return value
	bne.w	.PrintContinue	;if not exit check again...
.PrintExit	Pull	d5-d7
	rts


;---- Clear the screen bitmap and chartable
ClearScreen	Push	d0/d1/a1
                btst	#14,dmaconr(h)	;make blitter do the hard work
.WBLoopS	btst	#14,dmaconr(h)
	bne.b	.WBLoopS

	move.l	ScreenMem(b),bltdpt(h)
	move.l	#$01000000,bltcon0(h)
	clr.w	bltdmod(h)
	move.w	Lines(b),d0
	asl.w	#6,d0
	add.w	#640/16,d0
	move.w	d0,bltsize(h)

	move.l	CharPointer(b),a1;clear char table
	move.l	#'    ',d0	;while blitter is working in chip
	move.w	TextLines(b),d1
	mulu	#80/16,d1
	subq.w	#1,d1
.clearchar	move.l	d0,(a1)+
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	dbra	d1,.clearchar

	clr.w	CurXPos(b)
;	clr.b	CurYPos(b)

                btst	#14,dmaconr(h)
.WBLoopS2	btst	#14,dmaconr(h)
	bne.b	.WBLoopS2

	Pull	d0/d1/a1
	rts

;---- Print line to header
PrintHeader:	moveq	#0,d0
	move.l	HeaderAddress(b),a2;get pointer to header

	move.b	d0,$50(a2)	;clear first to get on even address
	move.b	d0,$a0(a2)
	move.b	d0,$f0(a2)
	move.b	d0,$140(a2)
	move.b	d0,$190(a2)
	move.b	d0,$1e0(a2)
	move.b	d0,$230(a2)
	move.b	d0,(a2)+

	moveq	#17-1,d1	;-1 for status-flags
.clear	move.l	d0,$50(a2)	;clear rest
	move.l	d0,$a0(a2)
	move.l	d0,$f0(a2)
	move.l	d0,$140(a2)
	move.l	d0,$190(a2)
	move.l	d0,$1e0(a2)
	move.l	d0,$230(a2)
	move.l	d0,(a2)+
	dbra	d1,.clear

PrintHeaderD	move.l	HeaderAddress(b),a1;get pointer to header
	add.w	d0,a1	;add offset

	move.l	a0,a4	;write back to textbuffer
	move.b	CurXPos(b),d2
	move.w	#$4000,intena(h)
	bsr.w	DoThePrintGfx
	move.w	#$c000,intena(h)
	move.b	d2,CurXPos(b)
	rts

;----------------------------------------------------
;- Name	: GetValue
;- Description	: Read numbers and constants from input and calculate result.
;- Notes	: Power (^) not implemented.
;----------------------------------------------------
;- 270893.0001	Included in routine index & and made local labels.
;----------------------------------------------------

;----- Start of "Get Value" --------------------------------------------------;
;-- Input :	D0	- Start Xpos
;--	A0	- Text pointer
;-- Output:	D0	- Value
;--	D1	- Error value
;--	A0	- Next letter in text
;----
getvalstack	reg	d2-d7/a1-a4

opr	equr	a4
num	equr	a3
last	equr	d7	;last type. 0=oper, 1=number
curr	equr	d6	;current operator
curx	equr	d5

AssemGetValueC	st.b	GetValueReturn(b)
	st.b	GetValueAssem(b)
.getskip	addq.w	#1,d0
	cmp.b	#' ',(a0)+	;skip initial spaces
	beq.b	.getskip
	subq.w	#1,d0
	subq.w	#1,a0
	bra.b	GetValueE1

GetValueCall	st.b	GetValueReturn(b)
.getskip	addq.w	#1,d0
	cmp.b	#' ',(a0)+	;skip initial spaces
	beq.b	.getskip
	subq.w	#1,d0
	subq.w	#1,a0
	bra.b	GetValueE0

;-- skip spaces
GetValueSkipS	bsr.w	CheckSeparator
GetValueSkip
.getskip	addq.w	#1,d0
	cmp.b	#' ',(a0)+	;skip initial spaces
	beq.b	.getskip
	subq.w	#1,d0
	subq.w	#1,a0

GetValue:	clr.b	GetValueReturn(b)
GetValueE0	clr.b	GetValueAssem(b)
GetValueE1	Push	getvalstack
	move.w	d0,curx
	lea	Operators(pc),opr
	lea	Numbers(pc),num
	clr.w	(opr)+	;set end-mark
	moveq	#0,last

.GetValueLoop	bsr.w	.GetNext	;get value/operator
;d1= 0 : value
;    1 : operator
;   -1 : error

	tst.w	d1
	bmi.w	.GetValueCExit
	bne.b	.setoperator
	not.b	last	;if number, check prev not number
	beq.b	.GatValueError
	move.l	d0,(num)+	;and then put on stack

	cmp.b	#'.',(a0)	;check forced size!
	bne.b	.GetValueLoop
	moveq	#0,d0	;set end mark

.setoperator	move.w	d0,d1
	and.w	#%1111111,d1	;current operator
	tst.b	last	;last also operator?
	bne.b	.CheckOperator
	tst.w	d1	;check for no value
	bne.b	.dd
	moveq	#EV_NOVALUE,d1
	bra.b	.GetValueCExit

.dd	cmp.w	#8,d1	;negate?
	bne.b	.checknot
	eor.w	#%0100000000000000,-2(opr)
	bra.b	.GetValueLoop

.checknot	cmp.w	#13,d1	;invert?
	bne.b	.checkpars
	eor.w	#%1000000000000000,-2(opr)
	bra.b	.GetValueLoop

.checkpars	cmp.b	#17,d1
	beq.b	.CheckOperator
	cmp.b	#19,d1
	bne.b	.GatValueError	;else error

.CheckOperator	move.w	-2(opr),d2
	and.w	#%1111111,d2	;prev operator

	tst.w	d1	;check end
	bne.b	.CheckPar
	tst.w	d2	;prev = end?
	bne.b	.others
	move.l	-(num),d0	;get return value
	move.w	-(opr),d2	;check for ~-flag
	bpl.b	.invert
	not.l	d0
.invert	btst	#14,d2	;check for --flag
	beq.b	.negate
	neg.l	d0
.negate	moveq	#0,d1	;return ok
	bra.b	.GetValueCExit

.others	cmp.w	#17,d2	;if not (/[ calc backwards
	blt.b	.PerformOper
	moveq	#EV_UNBALANCEDPARANTHES,d1
	bra.b	.GetValueCExit

.GatValueError	moveq	#EV_SYNTAXERROR,D1

.GetValueCExit	Pull	getvalstack
	tst.w	d1
	bmi.b	.PrintError
.DoReturn	clr.b	GetValueReturn(b)
	tst.w	d1
	rts

.DoReturnSE	move.w	d1,LastErrorNumber(b)
	bsr.w	PrintFlags	;just make sure flag is printed
	move.w	LastErrorNumber(b),d1
	bra.b	.DoReturn

.PrintError	st.b	LastCMDError(b)	;flag error
	tst.b	GetValueReturn(b);Force normal return?
	bne.b	.DoReturnSE
	addq.w	#4,a7
	bra.w	PrintError

.CheckPar	cmp.w	#17,d1	;check paranthes
	blt.b	.CheckCMP
	btst	#0,d1	;check (/[
	bne.b	.StoreOper
	tst.w	d2
	beq.b	.GatValueError	;if prev=end -> FAIL!
	cmp.w	#17,d2
	blt.b	.PerformOper
	addq.w	#1,d2	;add one :-)
	cmp.w	d2,d1
	bne.b	.GatValueError	;[ to ] and ( to ), else fail
	subq.w	#2,opr	;pull (/[ off stack
	bra.w	.GetValueLoop	;and continue

.StoreOper	and.w	#%1111111,d1
;	move.w	curx,d0
;	asl.w	#7,d0
;	or.w	d1,d0
	move.w	d1,(opr)+
	moveq	#0,last
	bra.w	.GetValueLoop

.CheckCMP	cmp.w	#17,d2	;last (/[
	bge.b	.StoreOper	;if so store
	cmp.w	d1,d2
	bmi.b	.StoreOper

.PerformOper	Push	d1
	move.l	-(num),d0
	move.w	-(opr),d1
	bpl.b	.invert2
	not.l	d0
.invert2	btst	#14,d1	;check for --flag
	beq.b	.negate2
	neg.l	d0
.negate2	move.l	-(num),d1
	subq.w	#1,d2
	asl.w	#2,d2
	jmp	.OperTab(pc,d2.w)
;w;
;Operators etc: add.l	d0,d1. d1=result

.OperTab	bra.w	.Operator00
	bra.w	.Operator01
	bra.w	.Operator02
	bra.w	.Operator03
	bra.w	.Operator04
	bra.w	.Operator05
	bra.w	.Operator06
	bra.w	.Operator07
	bra.w	.Operator08
	bra.w	.Operator09
	bra.w	.Operator10
	bra.w	.Operator11
	bra.w	.Operator12
	bra.w	.Operator13
	bra.w	.Operator14
	bra.w	.Operator15

.Operator00	cmp.l	d0,d1	;>
	bgt.b	.OperatorTrue
.OperatorFalse	moveq	#0,d1
.OperatorCont	move.l	d1,(num)+
	Pull	d1
	bra.w	.CheckOperator

.Operator01	cmp.l	d0,d1	;>=
	blt.b	.OperatorFalse

.OperatorTrue	moveq	#-1,d1
	bra.b	.OperatorCont

.Operator02	cmp.l	d0,d1	;=
	beq.b	.OperatorTrue
	bra.b	.OperatorFalse

.Operator03	cmp.l	d0,d1	;<=
	ble.b	.OperatorTrue
	bra.b	.OperatorFalse

.Operator04	cmp.l	d0,d1	;<
	blt.b	.OperatorTrue
	bra.b	.OperatorFalse

.Operator05	cmp.l	d0,d1	;<>
	bne.b	.OperatorTrue
	bra.b	.OperatorFalse

.Operator06	add.l	d0,d1	;+
	bra.b	.OperatorCont

.Operator07	sub.l	d0,d1	;-
	bra.b	.OperatorCont

.Operator08	move.l	d0,d2	;*
	move.l	d1,d3
	mulu	d0,d1
	swap	d0
	muls	d3,d0
	swap	d0
	clr.w	d0
	add.l	d0,d1
	swap	d3
	mulu	d3,d2
	swap	d2
	clr.w	d2
	add.l	d2,d1
	bra.b	.OperatorCont

.Operator09	pea	.OperatorCont(pc);/
	bra.w	Divu32

.Operator10	and.l	d0,d1	;&
	bra.b	.OperatorCont

.Operator11	or.l	d0,d1	;!
	bra.b	.OperatorCont

.Operator12	eor.l	d0,d1	;~
	bra.b	.OperatorCont

.Operator13	asl.l	d0,d1	;<<
	bra.b	.OperatorCont

.Operator14	lsr.l	d0,d1	;>>
	bra.b	.OperatorCont

.Operator15	muls	d1,d1	;^ (not working)
	bra.b	.OperatorCont

;---- Get next operator/number
.GetNext	moveq	#0,d2
	move.b	(a0)+,d2
	beq.w	.GetValueEnd

	moveq	#1,d1
	move.w	d2,d3
	asl.w	#8,d3
	move.b	(a0),d3
	moveq	#2,d0
	cmp.w	#'>=',d3
	bne.b	.checkop010
.longoper	addq.w	#1,a0
.operator	rts

.poperator	tst.b	last	;if paranthes AND prev was number, end
	bne.w	.GetValueEnd
.poperok	rts

.checkop010	cmp.w	#'=>',d3
	beq.b	.longoper
	moveq	#4,d0
	cmp.w	#'<=',d3
	beq.b	.longoper
	cmp.w	#'=<',d3
	beq.b	.longoper
	moveq	#6,d0
	cmp.w	#'<>',d3
	beq.b	.longoper
	moveq	#14,d0
	cmp.w	#'<<',d3
	beq.b	.longoper
	moveq	#15,d0
	cmp.w	#'>>',d3
	beq.b	.longoper

	moveq	#16,d0
	cmp.b	#'^',d2
	beq.b	.operator
	moveq	#13,d0
	cmp.b	#'~',d2
	beq.b	.operator
	moveq	#12,d0
	cmp.b	#'!',d2
	beq.b	.operator
	moveq	#11,d0
	cmp.b	#'&',d2
	beq.b	.operator
	moveq	#10,d0
	cmp.b	#'/',d2
	beq.b	.operator

	moveq	#9,d0	;* can be multiply AND current address
	cmp.b	#'*',d2
	bne.b	.checkCA
	tst.b	last	;was last a number?
	bne.b	.operator	;yes, then *==multiply
	move.l	MemoryAddress(b),d0;if no previous value, then
	bra.w	.GotValueExit	;get the CA and exit

.checkCA	moveq	#8,d0
	cmp.b	#'-',d2
	beq.b	.operator
	moveq	#7,d0
	cmp.b	#'+',d2
	beq.w	.operator
	moveq	#1,d0
	cmp.b	#'>',d2
	beq.w	.operator
	moveq	#3,d0
	cmp.b	#'=',d2
	beq.w	.operator
	moveq	#5,d0
	cmp.b	#'<',d2
	beq.w	.operator
	moveq	#17,d0
	cmp.b	#'(',d2
	beq.w	.poperator
	moveq	#18,d0
	cmp.b	#')',d2
	bne.b	.specialACheck
	tst.b	GetValueAssem(b)
	bne.w	.poperator	;if assembler call, allow ) without (
	bra.w	.poperok	;don't need prev-num check...

.specialACheck	moveq	#19,d0
	cmp.b	#'{',d2
	beq.w	.poperator
	moveq	#20,d0
	cmp.b	#'}',d2	;since it's ok!
	beq.w	.poperok	;keep } to ok since it will not be
			;used for mnemnonic args.
;;^
; 22.06.93 poperok/poperator problem! )/} 1st had ator, but for some reason
; changed to ok. WHY? Now ator again, coz 'd0],1)' would fail.
;			       ^^
;16.01.94 Changed back to poperok, else (a+b) will give unbal. par!


	moveq	#EV_SYNTAXERROR,d1;for no value
	moveq	#0,d0
	cmp.b	#'$',d2	;hex
	beq.w	.GetHex
	cmp.b	#'%',d2	;bin
	beq.w	.GetBin
	cmp.b	#'@',d2	;oct
	beq.w	.GetOct
	cmp.b	#'"',d2	;ascii
	beq.w	.GetASCII
	cmp.b	#"'",d2	;ascii
	beq.w	.GetASCII
	cmp.b	#'.',d2	;symbol
	beq.w	.GetSymbol
	cmp.b	#'#',d2	;dec
	beq.w	.GetDec

	cmp.b	#'0',d2	;hex 0-9
	blt.w	.GetValueEnd
	cmp.b	#'9',d2
	ble.w	.GetHexPre

	or.b	#$20,d2
	cmp.b	#'a',d2
	blt.w	.GetValueEnd
	bne.b	.checkan
	lea	AddressRegs(b),a1;get addressreg base
.checkhex	move.b	(a0),d0
	sub.b	#'0',d0
	bmi.b	.gethex
	cmp.b	#7,d0
	bgt.b	.gethex
	move.b	1(a0),d2
	cmp.b	#'0',d2
	blt.b	.okay
	cmp.b	#'9',d2
	ble.b	.gethex
	or.b	#$20,d2
	cmp.b	#'a',d2
	blt.b	.okay
	cmp.b	#'f',d2
	bgt.b	.okay
.gethex	moveq	#0,d0	;if reg num too big, next let=hexnible
	bra.w	.GetHexPre

.okay	addq.w	#1,a0
	asl.w	#2,d0
	move.l	(a1,d0.w),d0
	bra.w	.GotValueExit

.checkan	cmp.b	#'d',d2	;check d0-d7
	bne.b	.checkdata
	lea	DataRegs(b),a1
	bra.b	.checkhex

.checkdata	cmp.b	#'c',d2	;check cp1/cp2 - copperaddresses
	bne.b	.checkincop
	move.b	(a0),d0
	or.b	#$20,d0
	cmp.b	#'p',d0
	bne.b	.checkincopx
	addq.w	#1,a0
	move.b	(a0)+,d0
	sub.b	#'0',d0
	bmi.w	.GetValueError
	cmp.b	#1,d0
	bgt.w	.GetValueError
	asl.w	#2,d0
	lea	C0Reg(b),a1
	move.l	(a1,d0.w),d0
	bra.b	.GotValueExit

.checkincopx	moveq	#0,d0
.checkincop	cmp.b	#'f',d2
	ble.w	.GetHexPre

.checkpurelets	asl.w	#8,d2
	move.b	(a0)+,d2
	or.w	#$20,d2
	cmp.w	#'pc',d2
	bne.b	.checkpc	;check pc
	move.l	PCReg(b),d0
	bra.b	.GotValueExit

.checkpc	cmp.w	#'sp',d2	;sp
	bne.b	.entrysp
	move.l	Regs+15*4(b),d0	;add offset to find a7=sp
	bra.b	.GotValueExit

.entrysp	lea	UserStack(b),a1	
	cmp.w	#'us',d2	;usp
	bne.b	.usersp
.checksp	move.b	(a0)+,d2	;check P in ssp/usp
	or.b	#$20,d2
	cmp.b	#'p',d2
	bne.b	.GetValueError
	move.l	(a1),d0	;and get value from preset a1
	bra.b	.GotValueExit

.usersp	lea	SuperStack(b),a1
	cmp.w	#'ss',d2	;ssp
	beq.b	.checksp

	cmp.w	#'vb',d2
	bne.b	.GetValueError	;was .checkinvbr, 171093
	move.b	(a0)+,d0
	or.b	#$20,d0
	cmp.b	#'r',d0
	bne.b	.GetValueError
	move.l	CPUVBR(b),d0
;	bra.b	.GotValueExit
.checkinvbr


.GotValueExit	moveq	#0,d1	;value from register - OK
	rts

.GetValueEnd	moveq	#1,d1	;flag operator
	moveq	#0,d0	;set end mark
	subq.w	#1,a0
	rts

.GetValueError	moveq	#EV_SYNTAXERROR,d1;wrong syntax (eg ssk for ssp)
	rts

.GetValueExit	subq.w	#1,a0
	rts

;---- Get register value. offset (a0), base=(a1)
.GetRegValue	move.b	(a0)+,d2
	sub.b	#'0',d2
	bmi.b	.GetValueError
	cmp.b	#8,d2
	bge.b	.GetValueError
	asl.w	#2,d2
	move.l	(a1,d2.w),d0
	bra.b	.GotValueExit

;---- Get Hex value.
.GetHexPre	subq.w	#1,a0
.GetHex	move.b	(a0)+,d2
	cmp.b	#'0',d2	;check 0-9
	blt.b	.GetValueExit
	cmp.b	#'9',d2
	ble.b	.GetHexNibble
	or.b	#$20,d2
	cmp.b	#'a',d2	;check a-f
	blt.b	.GetValueExit
	cmp.b	#'f',d2
	bgt.b	.GetValueExit
	sub.w	#['a'-'0']-10,d2;scale 'a' to '0'

.GetHexNibble	sub.w	#'0',d2	;find nibblevalue
	asl.l	#4,d0
	and.w	#$f,d2	;and add to value
	or.b	d2,d0
	moveq	#0,d1
	bra.b	.GetHex

;---- Get Bin Value
.GotBin	moveq	#0,d1	;mark data read!
.GetBin	move.b	(a0)+,d2
	cmp.b	#'0',d2	;check 0
	bne.b	.checkon
	asl.l	#1,d0
	bra.b	.GotBin

.checkon	cmp.b	#'1',d2	;check 1
	bne.b	.GetValueExit
	asl.l	#1,d0
	or.b	#1,d0
	bra.b	.GotBin

;---- Get Octal value
.GetOct	move.b	(a0)+,d2	;check 0-7
	sub.b	#'0',d2
	bmi.b	.GetValueExit
	cmp.b	#8,d2
	bge.b	.GetValueExit
	asl.l	#3,d0
	and.l	#7,d2
	add.l	d2,d0
	moveq	#0,d1
	bra.b	.GetOct

;---- GetAscii
.GetASCII	move.b	d2,d3
.GetASCIILoop	move.b	(a0)+,d2
	beq.w	.GetValueError	;if not closed before end of line
	cmp.b	d2,d3
	beq.w	.GotValueExit
	asl.l	#8,d0
	move.b	d2,d0
	bra.b	.GetASCIILoop

;---- Get Symbol
.GetSymbol	lea	SymbolBuffer(b),a1;make mirror of symbol name
	moveq	#7,d3	;copy max 8 letters
.mirrorsymbol	move.b	(a0)+,d2	;check 0-9/a-z/A-Z
	cmp.b	#'0',d2
	blt.b	.gotmirror
	cmp.b	#'9',d2
	ble.b	.setletter
	cmp.b	#'A',d2
	blt.b	.gotmirror
	cmp.b	#'Z',d2
	ble.b	.setletter
	cmp.b	#'a',d2
	blt.b	.gotmirror
	cmp.b	#'z',d2
	bgt.b	.gotmirror
.setletter	move.b	d2,(a1)+
	dbra	d3,.mirrorsymbol
	bra.b	.nonullend

.gotmirror	cmp.w	#7,d3
	beq.w	.GetValueError	;error if no symbol name

.clearrest	clr.b	(a1)+
	dbra	d3,.clearrest	;clear rest

;now the symbol buffer must match symbolentry to be valid
.nonullend	moveq	#MaxSymbols-1,d3
	move.l	a2,-(a7)
	lea	SymbolTable(b),a2
	lea	SymbolBuffer(b),a1

.GetSymbolLoop	moveq	#7,d4
.CheckSymbol	move.b	(a2,d4.w),d2	;check 8 letters
	cmp.b	(a1,d4.w),d2
	bne.b	.CheckNextSymbol
	dbra	d4,.CheckSymbol
	move.l	8(a2),d0
	moveq	#0,d1
	bra.b	.GetSymbolExit

.CheckNextSymbol
	add.w	#12,a2
	dbra	d3,.CheckSymbol

	moveq	#EV_UNDEFINEDSYMBOL,d1;will get negated

.GetSymbolExit	move.l	(a7)+,a2
	bra.w	.GetValueExit

;---- Get Decimal value
.GetDec	move.b	(a0)+,d2
	moveq	#0,d1
	sub.b	#'0',d2	;check 0-9
	bmi.w	.GetValueExit
	cmp.b	#9,d2
	bgt.w	.GetValueExit
	add.l	d0,d0
	move.l	d0,d1	;gvv*10
	asl.l	#2,d1
	add.l	d1,d0
	add.l	d2,d0
	bra.b	.GetDec

Operators	dcb.w	40,0
Numbers	dcb.l	40,0


;----------------------------------------------------
;- Name	: Interrupt handlers.
;- Description	: Routines that take care of mousemovement, keyinput etc.
;- Notes	: MouseReader is OLD!
;----------------------------------------------------
;- 270893.0000	Included in routine index + changed to local labels
;----------------------------------------------------

;---- Keyboard Interrupt Handler ---------------------------------------------;
KeyIRQ	move.w	#$2008,$dff09a	;disallow new irqs (for chickendance)
	movem.l	d0-d1/a0/a5/a6,-(a7)

	lea	B,b;get bss base
	lea	$dff000,h

	move.w	intreqr(h),d0	;kill this flag
	and.w	#$2008,d0
	move.w	d0,intreq(h)

	btst	#3,CIAA_ICR
	bne.b	.NewKey

	btst	#0,CIAB_ICR
	bne.w	.KeyR60	;No new input. Goto keyrepeat

	bra	.Exit

.NewKey	move.b	pr_KeyDelay(b),KeyDelay(b);reset repeat values
	clr.b	KeyRepeat(b)

	moveq	#0,d0
	move.b	CIAA_SDR,d0	;get keyval
	not.b	d0
	ror.b	#1,d0
	move.w	d0,d1
	and.w	#$007f,d0
	cmp.w	#$60,d0
	blt.b	.KeyR00	;normal keys
	sub.w	#$0060,d0
	bclr	d0,Control(b)
	tst.b	d1
	bmi.b	.KeyHand
	bset	d0,Control(b)
	bra.b	.KeyHand

.KeyR00	btst	#7,d1	;norm key released?
	beq.b	.KeyR00a
	clr.b	LastKey(b)	;yes, stop repeating!
	clr.b	CurKey(b)
	bra.b	.KeyHand	;and go to exit

.KeyR00a	lea	KeyTabNorm(pc),a0;no, get keyvalue. normal?
	btst	#kq_lshift,Control(b);no...
	bne.b	.GetShifted
	btst	#kq_rshift,Control(b)
	beq.b	.KeyR01

.GetShifted	lea	KeyTabShift(pc),a0;...shifted

.KeyR01	move.b	(a0,d0.w),d0	;get ascii keycode

	btst	#kq_capslock,Control(b);caps lockd?
	beq.b	.KeyR20	;no, dont change
	cmp.w	#'a',d0	;caps lockd. uppercaze a-z.
	blt.b	.KeyR20
	cmp.b	#'z',d0
	bgt.b	.KeyR20
	and.w	#$df,d0	;a=>A

.KeyR20	move.b	d0,CurKey(b)	;put keycode in cur+repeat register
	move.b	d0,LastKey(b)

	bsr.w	ClearPointer

.KeyHand	bset	#6,$bfee01	;timing handshake with the horz-blank
	clr.b	$bfec01	;(old: #160,dbra)

	grcall	TimerWait0.1ms	;wait 100 us, compatibility time is 85 us

;	moveq	#3,d0
;	add.b	vhposr(h),d0
;.l2	cmp.b	vhposr(h),d0
;	bne.b	.l2

	bclr	#6,$bfee01	;end handshake

.KeyExit	cmp.b	#$1b,CurKey(b)	;check for esc
	bne.b	.nobreak
	st.b	UserBreak(b)	;break-signal
	clr.b	LastKey(b)	;no break repeat

;---- check for fast exit ESC+ralt
	move.b	Control(b),d0
	btst	#kq_ralt,d0
	beq.b	.nobreak
	btst	#kq_rshift,d0
	beq.b	.nobreak
	st.b	ExitFlag(b)
.nobreak

;--- start timer and let it hit (oneshot - could be condt but re-setup is
;---  needed anywayz) every 1/100th second, which is twice the old hit
;---  generated by the vblank (not good at 72Hz! speedup = ~50%)

	move.b	#$7f,CIAB_ICR	;clr irq requests
	and.b	#~(5<<1),CIAB_CRA;count full cycles (2pi <> 1pi)
	or.b	#1<<3!1<<1,CIAB_CRA;oneshot ! CPU output
	move.b	#$81,CIAB_ICR

	move.w	Delay0.1ms(b),d0
	mulu	#10*10,d0
	move.b	d0,CIAB_TALO
	lsr.w	#8,d0
	move.b	d0,CIAB_TAHI

.Exit	movem.l	(a7)+,d0-d1/a0/a5/a6;exit
	move.w	#$a008,$dff09a
	rte

.KeyR60	tst.b	KeyDelay(b)	;key not released! delay time elapzd?
	beq.b	.KeyR70	;oui, start repeating
	subq.b	#1,KeyDelay(b)	;countdown to repeat
	bra.b	.KeyExit

.KeyR70	tst.b	KeyRepeat(b)	;repeat now?
	beq.b	.KeyR75	;oui
	subq.b	#1,KeyRepeat(b)	;no, wait
	bra.w	.KeyExit

.KeyR75	move.b	pr_KeyRepeat(b),KeyRepeat(b);repeat the last keycode sent
	move.b	LastKey(b),CurKey(b)
	bra.w	.KeyExit

	dc.l	'KMP!'

;$b - signals new cursor pos from pointer

KeyTabNorm	DC.B	'`1234567890-=\',$0E,'0'
	DC.B	'qwertyuiop[]',$1C,'123'
	DC.B	"asdfghjkl;''",$2C,'456'
	DC.B	'<zxcvbnm,./',$3B,'.','789'
	DC.B	' ',$08,$09,$0a,$0A,$1B,$7F;bs,tab,ret,ret,esc,del
	DC.B	$47,$48,$49,'-',$4B,1,2,3,4;up,down,right,left
	DC.B	128,129,130,131,132,133,134,135,136,137 ;F1-10
	DC.B	'()/*+',138	;keypad,help

KeyTabShift	DC.B	'~!@#$%^&*()_+|',$0E,'0'
	DC.B	'QWERTYUIOP{}',$1C,'123'
	DC.B	'ASDFGHJKL:"*',$2C,'456'
	DC.B	'>ZXCVBNM<>?',$3B,'.','789'
	DC.B	' ',$08,$09,$0a,$0A,$1B,$7F;bs,tab,ret,ret,esc,del
	DC.B	$47,$48,$49,'-',$4B,1,2,3,4;up,down,right,left
	DC.B	148,149,150,151,152,153,154,155,156,157 ;F1-10
	DC.B	'()/*+',158	;keypad,help

	even

;---- Paste next letter to CurKey if pasting is started.
;-- Also initiate pasting if lamiga+InsertKey is hit.
;----
PasteText	moveq	#0,d0
	move.b	CurKey(b),d0
	btst	#kq_lamiga,Control(b);qualifier correct?
	beq.b	.nostart
	cmp.b	pr_PasteKey(b),d0;paste key?
	bne.b	.nostart
	clr.b	CurKey(b)	;kill key
	moveq	#0,d0

.marked	tst.b	PastingText(b)
	bne.b	.nostart	;don't start while pasting
	move.b	PasteTextReady(b),PastingText(b);d1;init pasting
	move.l	#SnapBuffer,PastPointer(b)
	st.b	TextPasted(b)

.nostart	tst.b	PastingText(b)
	beq.b	.nopasting

	move.l	PastPointer(b),a0
	move.b	(a0)+,d0
	move.b	d0,CurKey(b)
	move.l	a0,PastPointer(b)
	subq.b	#1,PastingText(b)
.Exit	tst.b	d0
	rts

.nopasting	tst.b	MouseClickPos(b)
	beq.b	.Exit
	clr.b	MouseClickPos(b)

	moveq	#key_PointerPos,d0
	rts

;---- Clear pointer - if ok with prefs
ClearPointer	Push	d0/a0
	move.l	ChipMem(b),a0
	add.w	#SPRPointer,a0
	move.l	#$00000800,d0
	tst.b	pr_ClearPointer(b)
	bne.b	.noclear
	move.l	(a0),OldPointerPos(b)
	bra.b	.cleared

.noclear	cmp.l	(a0),d0
	beq.b	.cleared
	move.l	(a0),OldPointerPos(b);save old pos
	move.l	d0,(a0)	;clear sprpointer
.cleared	Pull	d0/a0
	rts

;---- Set pointer to pre-clear pos
SetPointer	move.l	ChipMem(b),a0
	add.w	#SPRPointer,a0
	cmp.l	#$00000800,(a0)
	bne.b	.notcleared
	move.l	OldPointerPos(b),(a0);only set if previously cleared
.notcleared	rts

;---- VBlank Interrupt Handler -----------------------------------------------;
VBlankIRQ:	move.w	#$0020,$dff09a
	Push	all
	lea	B,b
	lea	$dff000,h

	IF	InternalDebug
	move.w	#$0f0,d0
	tst.b	DebugCounter(b)
	beq.b	.noproblem
	move.w	#$f00,d0
.noproblem	move.l	ChipMem(b),a0
	move.w	d0,HeaderColors+2(a0)
	addq.w	#$1,HeaderColors+6(a0)
	ENDC

	move.l	ChipMem(b),a0
	lea	ScreenHeader(a0),a1;set header pointer
	move.l	a1,d2

	move.l	ScreenMem(b),d4

	move.l	NFBplPoi(b),d0
	tst.b	LaceMode(b)
	beq.b	.NotLace

	not.b	LaceMode(b)
	bpl.b	.LongFrame
	moveq	#80,d1
	add.l	d1,d0
	add.l	d1,d2
	add.l	d1,d4

.LongFrame
.NotLace	move.w	d0,BplPoi+6(a0)
	swap	d0
	move.w	d0,BplPoi+2(a0)

	move.w	d4,BplPoi2+6(a0)
	swap	d4
	move.w	d4,BplPoi2+2(a0)

	move.w	d2,HeaderPoi+6(a0)
	swap	d2
	move.w	d2,HeaderPoi+2(a0)

	move.l	NFPalFix(b),PalFix(a0)
	move.b	NFLineFix2(b),LineFix2(a0)

	tst.b	HeaderDiskInfo(b)
	beq.w	.NoDiskData

	bsr.w	DoDiskHeader

.NoDiskData
	bsr.w	READMOUSE

;---- Initialize pasting if needed
	move.b	Control(b),d0	;init pasting with lamiga+right
	btst	#kq_lamiga,d0
	beq.b	.pastesnap
	btst	#2,$dff016
	bne.b	.pastesnap
	tst.b	TextPasted(b)	;has text been pasted with this Mpress?
	bne.b	.pastesnap2

	tst.b	MarkingText(b)	;currently marking text?
	beq.b	.marked
	clr.b	MarkingText(b)	;if so, unmark text
	bsr.w	NegTextArea

	bsr.w	CopyText	;and copy to snap-buffer

.marked	move.b	PasteTextReady(b),d0;init pasting
	move.b	d0,PastingText(b)
	move.l	#SnapBuffer,PastPointer(b)
	st.b	TextPasted(b)
	bra.b	.pastesnap2

.pastesnap	clr.b	TextPasted(b)
.pastesnap2

;---- Copy marked text if needed
	tst.b	MarkingText(b)	;is text marked?
	beq.b	.checksnapend

	move.b	Control(b),d0	;user release lamiga?
	btst	#kq_lamiga,d0
	bne.b	.checksnapend

	clr.b	MarkingText(b)	;if so, unmark text
	bsr.w	NegTextArea

	bsr.w	CopyText	;and copy to snap-buffer

;---- Count frames in click
.checksnapend	btst	#6,$bfe001	;check exit/help icon
	bne.w	.noleftbutton

;---- Mark text if not already marked/pasting
	tst.b	LMBNotPressed(b)
	beq.w	.StillPressed	;also pressed last frame

	tst.b	MarkingText(b)
	bne.b	.NoSnapping

	move.b	Control(b),d0	;lamiga pressed at first frame?
	btst	#kq_lamiga,d0
	beq.b	.NewCursorPos

	move.w	MY(b),d0	;only start snap if in textarea
	cmp.w	StartLine(b),d0
	blt.b	.NoSnapping

	st.b	MarkingText(b)	;start text snapping
	bsr.w	InitTextMark
	bra.b	.NoSnapping

.NewCursorPos	move.w	MY(b),d0
	sub.w	StartLine(b),d0
	bmi.b	.NoSnapping
	lsr.w	#2,d0	;new cursor ypos
	tst.b	LaceMode(b)
	bne.b	.LaceMode
	lsr.w	#1,d0
.LaceMode	move.b	d0,PointerYPos(b)

	move.w	MX(b),d0
	sub.w	MinXPos(b),d0
	lsr.w	#2,d0
	move.b	d0,PointerXPos(b);new cursor xpos
	st.b	MouseClickPos(b);signal user set new pos with mouse

;---- handle double click
.NoSnapping	cmp.b	#3,LMBClicked(b);only allow 3 clicks
	beq.b	.StillPressed
	addq.b	#1,LMBClicked(b)
	tst.b	MarkingText(b)
	beq.b	.StillPressed	;don't mark, if no lamiga
	tst.b	SnapDoubleOff(b);ok to double/tripple click?
	bne.b	.StillPressed
	cmp.b	#2,LMBClicked(b)
	bne.b	.markword
	bsr.w	MarkWord	;2*click = mark word
.markword	cmp.b	#3,LMBClicked(b)
	bne.b	.StillPressed
	bsr.w	MarkLine	;3*click = mark line

.StillPressed	clr.b	LMBNotPressed(b)

	tst.b	MarkingText(b)	;should marking be updated?
	beq.b	.noMarking
	bsr.w	MarkTextArea

.noMarking	move.w	MinYPos(b),d0
	moveq	#8,d1
	tst.b	LaceMode(b)
	beq.b	.NoLace2
	moveq	#4,d1
.NoLace2	add.w	d1,d0
	cmp.w	MY(b),d0
	ble.b	.checkicons

	tst.b	MarkingText(b)	;no icons if marking text
	bne.b	.checkicons

	cmp.w	#$87,MX(b)
	bge.b	.checkhelp
	st.b	ExitFlag(b)	;flag exit-request
	btst	#2,$16(h)	;check for extra force
	bne.b	.checkicons

	Pull	all	;Do the funky chickendance!
	move.l	2(a7),BreakOutAddress;get pointer to troubled code
	move.l	#$DEADBEEF,ExitStat
	lea	BreakOut,a0	;return to BreakOut code!
	move.l	a0,2(a7)	;!THIS CODE HAS A SERIOUS
	move.w	#$0028,$dff09c	;ATTITUDE PROBLEM!
	rte

.checkhelp	cmp.w	#$1b9,MX(b)
	blt.b	.checkicons

	st.b	DisplayHelp(b)	;flag help-request
	bra.b	.checkicons

.noleftbutton	st.b	LMBNotPressed(b);flag that LMB is NOT pressed

.checkicons	moveq	#0,d2
	moveq	#0,d0
	move.b	CurYPos(b),d0
	tst.b	LaceMode(b)
	beq.b	.NoLace3
	asl.w	#2,d0
	addq.w	#5+1,d0
	move.w	#$400,d3	;spr heigth (4 lines)
	moveq	#0,d4	;sprite's 5th line
	bra.b	.Lace3

.NoLace3	asl.w	#3,d0
	add.w	#11,d0
	move.w	#$800,d3	;spr is 8 lines
	move.l	#$f0000000,d4	;sprite's 5th line

.Lace3	add.w	MinYPos(b),d0
	cmp.w	#$100,d0
	blt.b	.noy8
	moveq	#6,d2
	sub.w	#$100,d0
.noy8	asl.w	#8,d0
	move.w	d0,d1
	swap	d1
	add.w	d3,d0
	bcc.b	.noy82
	or.w	#2,d2
.noy82	move.w	d0,d1
	swap	d1

	moveq	#0,d0
	move.b	CurXPos(b),d0
	tst.b	CustomScreen(b)
	bne.b	.FunnySprite
	add.w	d0,d0	;multisync do double sprite steps!
.FunnySprite	add.w	CursorXOffset(b),d0
	move.b	d0,d1
;	or.w	#1,d2
	swap	d1
	or.w	d2,d1
	move.l	ChipMem(b),a0
	move.l	d1,SPRCursor(a0)
	move.l	d4,SPRCursor+5*4(a0)

;---- Blink cursor (with configurable on/off periodes)
	move.w	CursorFlashColor0(b),d0
	move.w	CursorFlashColor1(b),d1

	tst.b	HideCursor(b)	;hide cursor?
	beq.b	.displaycursor
	exg	d0,d1
	bra.b	.setcurcolor

.displaycursor	tst.b	CursorBlinkTime(b);if neg = not selected
	bmi.b	.setcurcolor	;always set
	subq.b	#1,CursorBlinkTime(b);count one clock
	bne.b	.BlankExit
	move.b	pr_CursorOn(b),d2
	move.b	pr_CursorOff(b),d3
	cmp.w	CursorColor(b),d0;check current state
	bne.b	.exchange
	exg	d0,d1
	exg	d2,d3
.exchange	move.b	d2,CursorBlinkTime(b);and time
.setcurcolor	move.w	d0,CursorColor(b);set new color (on/off)
	move.w	d0,color+$2a(h)

.BlankExit	clr.b	BlankFlag(b)
	move.w	#$0020,$09c(h)

	Pull	all

	move.w	#$8020,$dff09a
	rte


;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;
;: ReadMouse V2.0 coded on the 26th of June 1991 by Zest/Triangle 3532 :;
;: ------------------------------------------------------------------- :;
;: Call RMOUSE(A5=BSS,A6=HARDWARE) every frame. The mouse co-ordinates :;
;: can then be found in MX(A5) and MY(A5). If CHECKBORDER -> Borders   :;
;: will be checked and the mouse held between the borders MMAX/MIN/X/Y :;
;: If SETSPRITE -> The SPRITECON will be calculated for the mouse.     :;
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;
INITMOUSE	moveq	#0,d0
	move.b	DisplayStart(b),d0
	move.w	d0,MinYPos(b)
	MOVE.W	d0,MY(b)

	addq.w	#2,d0
	move.w	Lines(b),d1
	addq.w	#8,d1
	tst.b	LaceMode(b)
	beq.b	.NoLace7
	lsr.w	#1,d1
	subq.w	#1,d1
.NoLace7	add.w	d1,d0
	move.w	d0,MaxYPos(b)

	move.w	#MMINX,d0
	move.w	#MMAXX,d1
	move.w	d0,MinXPos(b)
	move.w	d1,MaxXPos(b)
	add.w	#12,d0	;avoid exit at mouseclick entry
	move.w	d0,MX(b)

	MOVE.W	joy0dat(h),D0
	MOVE.B	D0,OLDX(b)
	ASR.W	#8,D0
	MOVE.B	D0,OLDY(b)
	RTS

READMOUSE	MOVE.W	joy0dat(A6),D0	;FIND DELTAX
	MOVE.W	D0,D1
	MOVE.W	#$00FF,D2
	AND.W	D2,D1
	MOVEQ	#0,D3
	MOVE.B	OLDX(A5),D3
	MOVE.B	D1,OLDX(A5)
	EXG	D1,D3
	SUB.B	D1,D3
	EXT.W	D3
	move.w	d3,d4
	swap	d4	;for movement check
	ADD.W	MX(A5),D3	;NEW MX

	ASR.W	#8,D0	;FIND DELTAY
	AND.W	D2,D0
	MOVEQ	#0,D1
	MOVE.B	OLDY(A5),D1
	MOVE.B	D0,OLDY(A5)
	EXG	D0,D1
	SUB.B	D0,D1
	EXT.W	D1
	move.w	d1,d4
	tst.l	d4
	beq.w	.NoMovement
	ADD.W	MY(A5),D1	;NEW MY

	MOVE.w	MinXPos(b),D0	;CHECK BORDER+FIX VAL IF NEG
	CMP.W	D0,D3
	BGT.b	.RMOU00
	MOVE.W	D0,D3
	BRA.b	.RMOU01

.RMOU00	MOVE.w	MaxXPos(b),D0
	CMP.W	D0,D3
	BLT.b	.RMOU01
	MOVE.W	D0,D3

.RMOU01	MOVE.w	MinYPos(b),D0
	CMP.W	D0,D1
	BGT.b	.RMOU02
	MOVE.W	D0,D1
	BRA.b	.RMOU03

.RMOU02	MOVE.w	MaxYPos(b),D0
	CMP.W	D0,D1
	BLT.b	.RMOU03
	MOVE.W	D0,D1

.RMOU03	MOVE.W	D3,MX(A5)
	MOVE.W	D1,MY(A5)

	tst.b	CustomScreen(b)
	beq.b	.FunnySprite
	asr.w	#1,d3
	addq.w	#4,d3
.FunnySprite
	move.l	ChipMem(b),a0
	add.w	#SPRPointer,a0
	CLR.L	(A0)
	ASR.W	#1,D3
	BCC.b	.RMOU10
	BSET	#0,3(a0)	;HSTART BIT 0
.RMOU10	MOVE.B	D3,1(A0)
	MOVE.B	D1,(A0)
	BTST	#8,D1
	BEQ.b	.RMOU11
	BSET	#2,3(A0)	;VSTART BIT 8
.RMOU11	ADD.w	#SPRHEI,D1
	MOVE.B	D1,2(A0)
	BTST	#8,D1
	BEQ.b	.RMOU12
	BSET	#1,3(A0)	;VSTOP BIT 8
.RMOU12

.NoMovement	rts

;---- Text Snap controllers. Called from interrupts
InitTextMark	move.w	MY(b),d0
	sub.w	StartLine(b),d0
	lsr.w	#2,d0	;line number
	tst.b	LaceMode(b)
	bne.b	.LaceMode
	lsr.w	#1,d0
.LaceMode	move.b	d0,SSnapLine(b)	;start snap line
	move.b	d0,SnapLine(b)

	move.w	MX(b),d0
	sub.w	MinXPos(b),d0
	lsr.w	#2,d0
	move.b	d0,SSnapColumn(b)
	move.b	d0,SnapColumn(b)
	clr.b	SnapDoubleOff(b)
	clr.b	SnapClicked(b)
	clr.b	LMBClicked(b)
	bra.b	NegTextArea

;---- Mark text area
MarkTextArea	tst.b	SnapClicked(b)
	beq.b	.oktoremark
	rts

.oktoremark	bsr.b	NegTextArea	;unmark prev area before remarking

;- only support single-line snap
;	move.w	MY(b),d0
;	sub.w	#11,d0
;	sub.w	MinYPos(b),d0
;	lsr.w	#3,d0	;line number
;	move.b	d0,SnapLine(b)

	move.w	MX(b),d0
	sub.w	#MMINX,d0
	lsr.w	#2,d0
	move.b	d0,SnapColumn(b)
	cmp.b	SSnapColumn(b),d0;disallow 2/3-click if cursor moved
	beq.b	NegTextArea
	st.b	SnapDoubleOff(b)

NegTextArea	moveq	#0,d0
	moveq	#0,d1
	move.b	SnapColumn(b),d0
	move.b	SSnapColumn(b),d1
	cmp.b	d0,d1
	bpl.b	.swapdir
	exg	d0,d1
.swapdir	sub.b	d0,d1	;len in d1, start in d0.

;calculate gfx-position. Code from PrintLetter!!!!!!!!!!!!!!!! Caution!

	moveq	#0,d2
	move.b	SSnapLine(b),d2
	mulu	#80*8,d2
	add.w	d2,d0	;add xpos
	add.w	LineBase(b),d0
	moveq	#0,d2
	move.w	BplSize(b),d2
	cmp.l	d2,d0
	bmi.b	.fix
	sub.l	d2,d0
.fix	add.l	ScreenBase(b),d0
	move.l	d0,a0

.negloop	not.b	$50(a0)	;negate text
	not.b	$a0(a0)
	not.b	$f0(a0)
	not.b	$140(a0)
	not.b	$190(a0)
	not.b	$1e0(a0)
	not.b	$230(a0)
	not.b	(a0)+
	dbra	d1,.negloop
	rts

;---- Copy snapped area to snapbuffer
CopyText	moveq	#0,d0
	move.b	SSnapLine(b),d0
	mulu	#80,d0
	move.l	CharPointer(b),a0
	add.w	d0,a0
	moveq	#0,d0
	moveq	#0,d1
	move.b	SnapColumn(b),d0
	move.b	SSnapColumn(b),d1
	cmp.b	d0,d1
	bpl.b	.swapdir
	exg	d0,d1
.swapdir	sub.b	d0,d1	;len in d1, start in d0.
	add.w	d0,a0
	lea	SnapBuffer,a1
	move.b	d1,PasteTextReady(b)
	addq.b	#1,PasteTextReady(b)
.copysnap	move.b	(a0)+,(a1)+
	dbra	d1,.copysnap
	rts

;---- Mark word under pointer
MarkWord	bsr.w	NegTextArea
	moveq	#0,d0
	move.b	SSnapLine(b),d0
	mulu	#80,d0
	move.l	CharPointer(b),a0
	add.w	d0,a0

	move.w	MX(b),d0
	sub.w	#MMINX,d0
	lsr.w	#2,d0
	add.w	d0,a0
	move.w	d0,d1

	cmp.b	#' ',(a0)
	beq.b	.empty

	move.l	a0,a1
.findstart	subq.w	#1,d0
	beq.b	.startfound
	cmp.b	#' ',-(a0)
	bne.b	.findstart
	addq.w	#1,d0

.startfound
.findend	addq.w	#1,d1
	cmp.b	#79,d1
	beq.b	.endfound
	cmp.b	#' ',(a1)+
	bne.b	.findend
	subq.w	#2,d1
.endfound
.empty
MarkMain	move.b	d0,SSnapColumn(b)
	move.b	d1,SnapColumn(b)
	bsr.w	NegTextArea
	st.b	SnapClicked(b)
	rts

;---- Mark current line
MarkLine	bsr.w	NegTextArea
	moveq	#0,d0
	moveq	#79,d1
	bra.b	MarkMain

;---- Reprint header with disk data
DoDiskHeader	lea	HeaderDiskText(b),a0

	move.l	a0,a2

	moveq	#'-',d2	;DMA direction
	moveq	#' ',d3

	moveq	#'R',d1

;	move.b	IRQSecPos(b),d0	;if doing eye cream, set read!
;	not.b	d0
;	bpl.b	.DirDefined

	move.b	DiskDMADirection(b),d1
	bpl.b	.DirDefined
	moveq	#'-',d1	;write

.DirDefined	move.b	d1,(a0)
	addq.w	#7,a0

	move.b	d3,(a0)
	move.b	d3,-(a0)

	moveq	#0,d0
	move.w	CurrentTrack(b),d0
	bmi.b	.UndefinedTrack

	moveq	#'0',d1
	lsr.w	#1,d0
	bcc.b	.UpperSide
	moveq	#'1',d1
.UpperSide	move.b	d1,15(a2)

	bsr.w	PrintDec
	move.b	d3,(a0)
	bra.b	.TrackDone

.UndefinedTrack	move.b	d2,(a0)+
	move.b	d2,(a0)

	move.b	d2,15(a2)

.TrackDone	lea	18(a2),a0
	move.l	a0,a1
	moveq	#22-1,d0
	moveq	#'-',d1
.ClrLoop	move.b	d1,(a1)+
	cmp.b	DiskSectors(b),d0
	bne.b	.NewVal
	moveq	#' ',d1
.NewVal	dbra	d0,.ClrLoop

	moveq	#0,d0
	move.b	IRQSecPos(b),d0
	subq.b	#1,d0
	bmi.b	.Empty
	lea	EyeSectorTable(b),a1
	moveq	#'+',d1
	moveq	#0,d4
.SetLoop	move.b	(a1)+,d4
	move.b	d1,18(a2,d4.w)
	dbra	d0,.SetLoop

.Empty	move.b	IRQSecPos(b),d0
	bmi.b	.NoAdd
	cmp.b	DiskSectors(b),d0
	bne.b	.Add
	st.b	IRQSecPos(b)
	bra.b	.NoAdd

.Add	addq.b	#1,IRQSecPos(b)
	cmp.b	#22,DiskSectors(b)
	bne.b	.NoAdd
	addq.b	#1,IRQSecPos(b)


.NoAdd	move.l	a2,a0	
	bsr.w	PrintHeader
	rts

;-----------------------------------------------------------------------------;
;-		      External Libraries	-;
;-----------------------------------------------------------------------------;
DisAsmBinary	INCBIN	gri:disassembler.bin
DiskBinary	INCBIN	gri:disklibrary.bin

;-----------------------------------------------------------------------------;
;		       FASTMemory Data Area	-;
;-----------------------------------------------------------------------------;
	IncDir	gr:gfx/
Font	incbin	GRFont


;-----------------------------------------------------------------------------;
;		           Text Area	-;
;-----------------------------------------------------------------------------;


GFXName	dc.b	'graphics.library',0

;		 0         1         2         3
;		 0123456789012345678901234567890123456789
HeaderDiskText	dc.b	'- Cyl --  Side -  ----------------------',0

VerifyRetryText	dc.b	'Verify Error! (R)etry/(A)bort?',0

HeaderText	dc.b	'GhostRider V'
	VersionText
	dc.b	' Copyright (c) 1992-1994 by Jesper Skov.',0

OwnerText	dc.b	pc_YPos,0,10
	dc.b	pc_XPos,21,'GhostRider is now a shareware program.',10
	dc.b	pc_XPos,9,'If you use it please register and support further development!',10
;	dc.b	pc_XPos,26,'Beta release - do NOT spread!',10
	dc.b	10,0


HeaderInfo	dc.b	'CA=',0,'  CB=$',0 ; SKIPPED. See PrintInfoH,'  CS=',0
	dc.b	'    NJ=',0,'  LA=',0

CPUText	dc.b	pc_XPos,14,'68o',0,'o'
	dc.b	' CHIP, KICK ',0
	dc.b	', HardwareMap at $F3',0
	dc.b	', No HardwareMap',0
EntryText	dc.b	10,pc_XPos,1,'EntryMode: ',0,'  Chip Memory: $',0
	dc.b	'-$'
	dc.b	'  Using ',0
	dc.b	' Preferences',0

PrefStatusDef	dc.b	'Default',0
PrefStatusMod	dc.b	'Modified',0

EntryModesText	dc.b	0,3	;not used! (extra byte:indention)
	dc.b	'NMI',0,5
  	dc.b	'Reset',0,4
	dc.b	'BPoint',0,3
	dc.b	'System',0,3
	dc.b	'Generic',0,2

RegisterText	dc.b	10,'D0-7 : '
DataRegsText	dc.b	'00000000 00000000 00000000 00000000 '
	dc.b	'00000000 00000000 00000000 00000000',10,'A0-7 : '
AddressRegsText	dc.b	'00000000 00000000 00000000 00000000 '
	dc.b	'00000000 00000000 00000000 00000000',10
	dc.b	'PC='
PCRegText	dc.b	'00000000 SSP='
SSPRegText	dc.b	'00000000 USP='
USPRegText	dc.b	'00000000 CP0='
C0RegText	dc.b	'00000000 CP1='
C1RegText	dc.b	'00000000 VBR='
VBRRegText	dc.b	'00000000',10
	dc.b	'SR='
SRRegText	dc.b	'0000 T='
FlagsRegText	dc.b	'0 S=0 IM=0 X=0 N=0 Z=0 V=0 C=0',0

DirText	dc.b	'<Dir>',0
LinkText	dc.b	'<Link>',0
VolumeTxt	dc.b	'Volume : "',0
NoFilesTxt	dc.b	'<No files>',10,0
UsedBlkTxt	dc.b	'Used blocks: ',0
FreeBlkTxt	dc.b	', Free blocks: ',0

DOSTypesTxt	dc.b	'OFS '
	dc.b	'FFS '
	dc.b	'IOFS'
	dc.b	'IFFS'
	dc.b	'COFS'
	dc.b	'CFFS'

CheckSumTxt	dc.b	'Debug Info : ZP Checksum=$',0
StackTxt	dc.b	' / StackPointer=$',0

ZappedText	dc.b	10,'Symbol zapped!',0
AllZappedText	dc.b	10,'Symbol table zapped!',0
NewSymbolText	dc.b	10,'Symbol "',0,'" added to table.',0
AssignSkipText	dc.b	'Symbol assignment skipped.',0

LoadingBlkText	dc.b	pc_XPos,0,'Loading block ',-1
LoadingTrkText	dc.b	pc_XPos,0,'Loading track ',-1
SavingText	dc.b	pc_XPos,0,'Saving ',-1
ToTrackText	dc.b	' to track ',0
ToBlockText	dc.b	' to block ',0
ToMemText	dc.b	' to ',0
SyncText	dc.b	10,'Disk Sync : $',0
TrackLenText	dc.b	10,'Track Length : ',0
LoadingFileText	dc.b	10,'Loading "',0,'" to ',0

ScanningText	dc.b	10,'Searching ',0,' for "',0
ScanNOTText	dc.b	'NOT ',0
ScanCompletText	dc.b	10,'Full area scanned.',0
XORingText	dc.b	10,"XOR'ing ",0,' with ',0
FillingText	dc.b	10,'Filling ',0,' with ',0
CopyingText	dc.b	10,'Copying ',0,' to ',0
ComparingText	dc.b	10,'Comparing ',0,' with ',0
ExchangingText	dc.b	10,'Exchanging ',0,' with ',0
XORCompletText	dc.b	10,"Area XOR'ed.",pc_CLRRest,0
FillCompletText	dc.b	10,'Area filled.',pc_CLRRest,0
TranCompletText	dc.b	10,'Area copied.',pc_CLRRest,0
CompCompletText	dc.b	10,'Areas compared.',pc_CLRRest,0
AreasAreEquText	dc.b	10,'Areas are equal.',0
ExcgCompletText	dc.b	10,'Areas exchanged.',pc_CLRRest,0
AddBufFullTxt	dc.b	10,'Address table full.',pc_CLRRest,0
LastAddressText	dc.b	' Stopped at address ',0
NoAddressesText	dc.b	10,'Address table empty!',pc_CLRRest,0
AddEntriesText	dc.b	' Address',0,'es in table:',10,0
UserBreakText	dc.b	10
UserBreakTextH	dc.b	'Process stopped by user.',0
FunctionOKTextH	dc.b	'Operation finished.',0
BranchText	dc.b	'branches to address ',0

DestAddText	dc.b	'Destination '	;no end here!
EditorJumpText	dc.b	'Address:',0
EditorOffsText	dc.b	'Offset:',0

FillValueText	dc.b	'Fill value:',0

AssignText	dc.b	'Assign ',0,' to:',0
EditorSizeText	dc.b	'Size (Byte/Word/Long) ?',0
EditorExprText	dc.b	'Expression:',0
PeekerModuloTxt	dc.b	'Modulo:',0
PeekerWidthTxt	dc.b	'Width:',0

SavingFileText	dc.b	10,'Saving "',0,'" from ',0

FormattingText	dc.b	10,'Please wait, formatting disk... ',pc_CLRRest,0
WritingROOTText	dc.b	10,'Writing system blocks.',pc_CLRRest,0

MFMDecodeText	dc.b	10,'MFM decoded ',0,' longwords to ',0,' from ',0,'.'

EntryClearText	dc.b	10,'CLS at entry',0

VerifyText	dc.b	10,'Disk verify',0

DisplayRegsText	dc.b	' D0-7 : ',0,' A0-7 : ',0

GURUText	dc.b	10,'Entry because of a GURU #',0,' in process at ',0

CustomCodeText	dc.b	10,'Custom program ',0
CustomCodeTexta	dc.b	'located at ',0
CustomCodeTextb	dc.b	'not defined!',0

BeamconText	dc.b	10,'Beamcon0 set to ',0
BeamconTexta	dc.b	'$0000 (NTSC).',0
BeamconTextb	dc.b	'$0020 (PAL).',0
BeamconTextc	dc.b	10,'Beamcon0 not set.',0

PrefRevText	dc.b	10,'GR Preferences Revision ',0


;---- Command Names
Commands	dc.b	'verify',0	;Toggle disk verify
	dc.b	'format',0	;Format disk
	dc.b	'mon',0	;Monitor Control
	dc.b	'S',0	;Save data
	dc.b	'BM',0	;Show Disk's bitmap
	dc.b	'del',0	;Delete file
	dc.b	'mfm',0	;Decode MFM data
	dc.b	'xcon',0	;set beamcon0 exit-mode to PAL/NTSC/DISABLED
	dc.b	'cold',0	;dis/enable cold reset entry
	dc.b	'nmirom',0	;Change NMIROM entry-flag
	dc.b	'hn',0	;hunt NOT
	dc.b	'ver',0	;show GR version
	dc.b	'date',0	;show date
	dc.b	'int',0;ernal	;show internal bufferlocations
	dc.b	'cus',0	;show/change exit custom registers
	dc.b	'copact',0	;show/change active exitcopper
	dc.b	'copoffset',0	;Show/Change copper-search offset
	dc.b	'nmi',0	;Set/restore NMI vector
	dc.b	'cp',0	;Set exit-copper
	dc.b	'cd',0	;Change selected drive
	dc.b	'bl',0	;breakpoint list
	dc.b	'bs',0	;breakpoint set
	dc.b	'bzall',0	;zap all breakpoints
	dc.b	'bz',0	;breakpoint zap
	dc.b	'BReg',0	;BreakPoint register show/change
	dc.b	'traceon',0	;enable internal tracing
	dc.b	'traceoff',0	;diable internal tracing
	dc.b	'help',0	;show where to get help
	dc.b	'depack',0	;depack powerpacked data
	dc.b	'deplode',0	;depack imploded data
	dc.b	'xor',0	;Eor memory
	dc.b	'nop',0	;filll area with nops
	dc.b	'work',0	;display/change workarea
	dc.b	'irq',0	;show/change interrupt vectors
	dc.b	'kicktag',0	;show kicktag list
	dc.b	'kickmem',0	;show kickmem list
	dc.b	'resi',0	;show resident list
	dc.b	'resc',0	;-------- resource list
	dc.b	'res',0	;resume stopped command
	dc.b	'dir',0
	dc.b	'tasks',0	;display task info
	dc.b	'libs',0	;display library list
	dc.b	'devs',0	;-------- devs list
	dc.b	'ports',0	;-------- port list
	dc.b	'sync',0	;change/show sync
	dc.b	'tracklenh',0	;change/show track length (HD)
	dc.b	'tracklen',0	;change/show track length (DD)
	dc.b	'info',0	;disk info
	dc.b	'at',0	;dump addresses
	dc.b	'rb',0	;read blocks
	dc.b	'rtr',0	;read raw tracks
	dc.b	'rt',0	;read tracks
	dc.b	'wtr',0	;write raw tracks
	dc.b	'wt',0	;write tracks
	dc.b	'wb',0	;write blocks
	dc.b	'x',0	;exit
	dc.b	'r',0	;dump regs
	dc.b	'a',0	;assemble line
	dc.b	',',0	;---"---
	dc.b	'D',0	;disassemble X lines
	dc.b	'cls',0	;change entry clear screen setting
	dc.b	'M',0	;hex dump
	dc.b	'N',0	;ascii dump
	dc.b	'?',0	;calculate value (when getvalue works)
	dc.b	':',0	;hex entry
	dc.b	'kill',0	;kill exit
	dc.b	'zs',0	;zap symbol
	dc.b	'.',0	;define symbol
	dc.b	'ls',0	;list symbols
	dc.b	';',0	;ascii entry
	dc.b	'hp',0	;hunt pc-rel
	dc.b	'hb',0	;hunt branch
	dc.b	'ht',0	;hunt text
	dc.b	'h',0	;hunt data
	dc.b	'F',0	;fill data
	dc.b	'T',0	;transfer data
	dc.b	'E',0	;exchange areas
	dc.b	'd',0	;start disassemble-medit
	dc.b	'm',0	;start hexdump-medit
	dc.b	'n',0	;start asciidump-medit
	dc.b	'J',0	;call subroutine
	dc.b	'X',0	;call subroutine, then exit
	dc.b	'l',0	;load data-file
	dc.b	'c',0	;compare memory
	dc.b	'p',0	;memory peeker
	dc.b	0

	include	gri:ExceptionMessages.0000.s

;---------------T-------T---------------T------------------------------------T
;---- Start of "Help Texts" --------------------------------------------------;
HelpC1	macro
	dc.b	\1,pc_XPos,28,\2,10
	endm

	rem
         1	   2	     3         4         5         6         7
12345678901234567890123456789012345678901234567890123456789012345678901234567890
'--------------------------------- + Control ------------------------------------',10

	dc.b	10,10,
	erem


MainHelpText	dc.b	10,'-------------------------------- Memory Editors --------------------------------',10,10
	HelpC1	'a [addr]','Start MC68k family line-assembler.'
	HelpC1	'D <start><\><stop>','Disassemble MC68k family block/area.'
	HelpC1	'M <start><\><stop>','Hex-dump memory block/area.'
	HelpC1	'N <start><\><stop>','ASCII-dump memory block/area.'
	HelpC1	'p <addr>','Enter memory peeker.'
	HelpC1	'd <addr>','Enter disassemble-editor.'
	HelpC1	'm <addr>','Enter hex-editor.'
	HelpC1	'n <addr>','Enter ASCII-editor.'

	dc.b	10,10,'------------------------------- Memory Routines --------------------------------',10,10
	HelpC1	'F [start] [stop] [data]','Fill memory.'
	HelpC1	'xor [start] [stop] [data]','XOR memory.'
	HelpC1	'nop [start] [stop]','Fill memory with NOPs.'
	dc.b	10
	HelpC1	'T [start] [stop] [dest]','Transfer memory.'
	HelpC1	'E [start] [stop] [dest]','Exchange memory.'
	HelpC1	'c [start] [stop] [dest]','Compare memory.'
	dc.b	10
	HelpC1	'h [start] [stop] [data]','Hunt data.'
	HelpC1	'hn [start] [stop] [data]','Hunt NOT data.'
	HelpC1	'hb [addr]','Hunt for branches to address.'
	HelpC1	'hp [addr]','Hunt for pc-relative access to address.'
	dc.b	'ht [s] [e] <-[joker]> <c> [<"txt"><'
	dc.b	"'txt'>(?)]"
	dc.b	pc_XPos,48,'Hunt textstring.',10

	dc.b	10,10,'------------------------------ Breakpoint Control ------------------------------',10,10
	HelpC1	'bs [addr]','Set BreakPoint at address.'
	HelpC1	'bl','List table of BreakPoints.'
	HelpC1	'bz [addr]','Zap BP at address if set.'
	HelpC1	'bzall','Zap all breakpoints.'
	HelpC1	'breg <trap#>','Show/change TRAP# used for BPs.'

	dc.b	10,10,'---------------------------------- System Info ---------------------------------',10,10
	HelpC1	'libs',"Display Exec's librarylist."
	HelpC1	'devs',"Display Exec's devicelist."
	HelpC1	'resc',"Display Exec's resourcelist."
	HelpC1	'resi',"Display Exec's residentlist."
	HelpC1	'tasks',"Display Exec's tasklist."
	HelpC1	'ports',"Display Exec's portlist."
	HelpC1	'kickmem',"Display Exec's kickmemlist."
	HelpC1	'kicktag',"Display Exec's kicktaglist."

	HelpC1	'irq <[vct] [addr]>','Display/change interrupt vectors.'

	dc.b	10,10,'-------------------------------- Symbol Control --------------------------------',10,10
	HelpC1	'.symbol_name=value','Define symbol (max 8 letters).'
	HelpC1	'ls','List symbols.'
	HelpC1	'zs.symbol_name','Zap symbol.'
	HelpC1	'zs..','Zap symbol table.'

	dc.b	10,10,'-------------------------------- Disk Routines ---------------------------------',10,10
	HelpC1	'cd <path>','Display/Change path.'
	HelpC1	'info','Display disk/drive information.'
	HelpC1	'BM','Display bitmap of active drive.'
	HelpC1	'dir <path>','Display directory.'
	HelpC1	'del [<path>file]','Delete file.'
	HelpC1	'l [<path>file] [addr] <len>','Load file from disk.'
	HelpC1	'S [<path>file] [start] [end]','Save file to disk.'
	dc.b	'format <DFx:>[name] <q><f><i><c> <=formatval>'
	dc.b	pc_XPos,48,'Format disk.',10
	dc.b	10
	HelpC1	'rb [addr] [blk] <n>','Read block(s).'
	HelpC1	'wb [addr] [blk] <n>','Write block(s).'
	HelpC1	'rt [addr] [trk] <n>','Read track(s).'
	HelpC1	'wt [addr] [trk] <n>','Write track(s).'
	HelpC1	'rtr [addr] [trk] <n>','Read Raw track(s).'
	HelpC1	'wtr [addr] [trk] <n>','Write Raw track(s).'
	HelpC1	'sync <SYNC>','Show/Change disk sync.'
	HelpC1	'tracklen <Length>','Show/Change DD track length.'
	HelpC1	'tracklenh <Length>','Show/Change HD track length.'
	dc.b	10
	HelpC1	'verify','Toggle disk verify.'
	dc.b	10
	HelpC1	'mfm [start] [#longs.d] <dest>','Decode MFM data.'

	dc.b	10,10,'-------------------------------- Miscellaneous ---------------------------------',10,10
	HelpC1	'? [expr]','Evaluate expression.'
	dc.b	10
	HelpC1	'r <[d0-a7/sr] [new value]>','Dump/change CPU registers.'
	dc.b	10
	HelpC1	'cls','Toggle entry CLS setting.'
	HelpC1	'mon <0-4>','Show/change monitor.'
	dc.b	10
	HelpC1	'at','Dump address table.'
	HelpC1	'res','Resume command.'
	dc.b	10
	HelpC1	'work <chip><backup/0>','Display/move chip/backup memory.'
	dc.b	10
	HelpC1	'cp <[Copper#] [Addr]>','Display/set CopperExit registers.'
	HelpC1	'copoffset <new offset>','Display/set copper-search offset.'
	HelpC1	'copact <Copper#>','Display/set copper activated at exit.'
	dc.b	10
	HelpC1	'cus <program>/<0>','Display/set custom register program.'
	HelpC1	'xcon <p>/<n>/<0>','Set beamcon0 default exit value.'

	dc.b	10
	HelpC1	'deplode [data] <dest>','Depack imploded data.'
	HelpC1	'depack [data] [end] [dest]',"Depack PowerPacked data."
	dc.b	10
	HelpC1	'traceon','Enable internal tracing (Debug).'
	HelpC1	'traceoff','Disable internal tracing (Debug).'
	dc.b	10
	HelpC1	'ver','Display GR version string.'
	dc.b	10

	HelpC1	'nmi','Set/free NMI-vector.'
	HelpC1	'nmirom','Dis/enable NMI entry from ROM.'
	HelpC1	'cold','Dis/enable ColdCapture reset entry'

	dc.b	10
	HelpC1	'J [addr]','Call routine at addr.'
	HelpC1	'x <addr>','Exit <to addr>.'
	HelpC1	'X [addr]','Call routine at addr,then exit.'
	HelpC1	'kill <addr>','Kill and exit <to addr>.'

	dc.b	10,10,'--------------------------------- + Control ------------------------------------',10,10
	HelpC1	'HELP','Display registers'
	dc.b	0

;Editor HELP mask
;%0001 - Disassemble
;%0010 - Hex
;%0100 - ASCII
;%1000 - Peeker
EditorHelp	dc.b	%1111,10
	dc.b	%1111,'-------------------------------- No Qualifier --------------------------------',10
	dc.b	%1111,10
	dc.b	%1111,'ESC',pc_XPos,16,"Exit (+shift: Don't restore display)",10
	dc.b	%0010,'TAB',pc_XPos,16,'Shift Hex/ASCII column.',10
	dc.b	%1111,10
	dc.b	%1111,10
	dc.b	%1111,'---------------------------------- + Amiga -----------------------------------',10
	dc.b	%1111,10
	dc.b	%0111,',',pc_XPos,16,'Jump to previous address in hunt/compare-buffer.',10
	dc.b	%0111,'.',pc_XPos,16,'Jump to next address in hunt/compare-buffer.',10
	dc.b	%1000,'-',pc_XPos,16,'Decrease screen width.',10
	dc.b	%1000,'=',pc_XPos,16,'Increase screen width.',10
	dc.b	%1000,',',pc_XPos,16,'Decrease modulo.',10
	dc.b	%1000,'.',pc_XPos,16,'Increase modulo.',10
	dc.b	%1000,'[',pc_XPos,16,'Decrease height.',10
	dc.b	%1000,']',pc_XPos,16,'Increase height.',10
	dc.b	%1111,'0-9',pc_XPos,16,'Jump to mark.',10
	dc.b	%1111,'a',pc_XPos,16,'Assign symbol to address.',10
	dc.b	%0111,'b',pc_XPos,16,'Block start/stop.',10
	dc.b	%1110,'d',pc_XPos,16,'Go to disassemble editor.',10
	dc.b	%0010,'e',pc_XPos,16,'Enter expression (default size).',10
	dc.b	%1101,'h',pc_XPos,16,'Go to hex dump editor.',10
	dc.b	%1111,'j',pc_XPos,16,'Jump to address.',10
	dc.b	%1111,'l',pc_XPos,16,'Quick-Jump to last address.',10
	dc.b	%1000,'m',pc_XPos,16,'Change modulo.',10
	dc.b	%1011,'n',pc_XPos,16,'Go to ASCII editor.',10
	dc.b	%1111,'o',pc_XPos,16,'Jump to current address+offset.',10
	dc.b	%0111,'p',pc_XPos,16,'Go to peek editor.',10
	dc.b	%0010,'q',pc_XPos,16,'Quick-Jump.',10
	dc.b	%0001,'q',pc_XPos,16,'Quick-Jump to source (/dest).',10
	dc.b	%0110,'r',pc_XPos,16,'Re-position cursor.',10
	dc.b	%0010,'u',pc_XPos,16,'Quick-Jump to current address+BCPL offset.',10
	dc.b	%0010,    pc_XPos,16,'+alt to skip one extra BCPL word.',10
	dc.b	%1000,'w',pc_XPos,16,'Change screen width.',10
	dc.b	%1111,'x',pc_XPos,16,'Exit.',10
	dc.b	%1111,'z',pc_XPos,16,'Zap table of nested jumps.',10
	dc.b	%1111,10
	dc.b	%0111,'<',pc_XPos,16,'Jump to first address in hunt/compare-buffer.',10
	dc.b	%0111,'>',pc_XPos,16,'Jump to last address in hunt/compare-buffer.',10
	dc.b	%1111,'0-9 (shifted)',pc_XPos,16,'Mark address.',10
	dc.b	%0111,'B',pc_XPos,16,'Hide/show block.',10
	dc.b	%0111,'C',pc_XPos,16,'Copy area.',10
	dc.b	%0010,'E',pc_XPos,16,'Enter expression with size.',10
	dc.b	%0110,'F',pc_XPos,16,'Fill with custom size.',10
	dc.b	%0001,'F',pc_XPos,16,'Fill with NOPs.',10
	dc.b	%0001,'J',pc_XPos,16,'Quick-Jump to data address.',10
	dc.b	%0010,'U',pc_XPos,16,'Quick-Jump to BCPL address.',10
	dc.b	%0010,'Q',pc_XPos,16,'Quick-Jump + offset.',10
	dc.b	%0001,'Q',pc_XPos,16,'Quick-Jump to dest (/source).',10
	dc.b	%1111,'X',pc_XPos,16,'Exit without restoring display.',10
	dc.b	%0010,10
	dc.b	%0010,10
	dc.b	%0010,'--------------------------------- + Control ------------------------------------',10
	dc.b	%0010,10
	dc.b	%1111,'HELP',pc_XPos,16,'Display registers',10
	dc.b	%0010,'a',pc_XPos,16,'Dump ASCII at distant address.',10
	dc.b	%0010,'b',pc_XPos,16,'Dump hex in bytes.',10
	dc.b	%0010,'d',pc_XPos,16,'Disassemble at distant address.',10
	dc.b	%0010,'h',pc_XPos,16,'Dump Hex at distant address.',10
	dc.b	%0010,'l',pc_XPos,16,'Dump hex in longwords.',10
	dc.b	%0010,'w',pc_XPos,16,'Dump hex in words.',10
	dc.b	0

MoreText	dc.b	10,pc_XPos,19
	dc.b	'Press any key for more or q/esc to stop..',0
HelpContText	dc.b	10,pc_XPos,26,'Press any key to continue..',0
HeaderHelpText	dc.b	'                            Available Commands',0
FeedLineText	dc.b	pc_CLRRest,10,0
WhereIsHelpTxt	dc.b	10,'Press Alt+HELP to see the list of available'
	dc.b	' commands! (also in editors)',0
;-----------------------------------------------------------------------------;


;-- Error messages
ErrorMessages	offset	0
SyntaxErrorText	dc.b	10,'Syntax error!',0
UndefSymbolText	dc.b	10,'Undefined symbol!',0
IllAddModeText	dc.b	10,'Illegal addressing mode!',0
IllegalSizeText	dc.b	10,'Illegal size!',0
IllMnemonicText	dc.b	10,'Unknown mnemonic!',0
UnexpectEOLText	dc.b	10,'Unexpected end of line!',0
UnknownCmdText	dc.b	10,'Unknown command!',0
NoDiskText	dc.b	10,'No disk in selected drive (TDERR 29)!',0
NotAllSecsText	dc.b	10,'Not all sectors found (TDERR 26)!',0
InvalidSecIDTxt dc.b	10,'Invalid sector ID (TDERR 23)!',0

IllegalSecText	dc.b	10,'Illegal sector number (TDERR 32)!',0
CheckSumErrText	dc.b	10,'Data CheckSum error!',0
IllegalBlkText	dc.b	10,'Illegal block number!',0
SymbolFullText	dc.b	10,'Symboltable is full!',0
IllSymNameText	dc.b	10,'Illegal symbolname!',0
IllSeparatText	dc.b	10,'Illegal separator!',0
IllTrackText	dc.b	10,'Illegal track number!',0
IllLengthText	dc.b	10,'Illegal length!',0
IllegalAreaText	dc.b	10,'Illegal area!',0
NoFindDataText	dc.b	10,'No hunt data!',0

NotFoundText	dc.b	10,'Not found!',0
FullTableText	dc.b	10,'Jump table full!',0
EmptyTableText	dc.b	10,'Jump table empty!',0
NoResumeText	dc.b	10,'No command to resume!',0
UnbalanceText	dc.b	10,'Unbalanced parantheses!',0
NoValueText	dc.b	10,'No value!',0
UnknownDTText	dc.b	10,'Unknown datatype!',0
IllRegNumText	dc.b	10,'Illegal register number!',0
IllegaIndexText	dc.b	10,'Illegal Index Register!',0
InvalidScaleTxt	dc.b	10,'Invalid index scale!',0

DataTooLargeTxt	dc.b	10,'Data too large!',0; for requested size!',0
OnlyOneBDText	dc.b	10,'Only one base displacement allowed!',0
OnlyOneODText	dc.b	10,'Only one outer displacement allowed!',0
OnlyOneIndexTxt	dc.b	10,'Only one index register allowed!',0
WrongRegOrdText	dc.b	10,'Wrong register order!',0
DestinationText	dc.b	10,'Destination expected!',0
IllegalFieldTxt	dc.b	10,'Illegal bitfield!',0
IllegalCondText	dc.b	10,'Illegal condition code!',0
FirstHalfText	dc.b	10,'Address must match that of first half!',0
NoHalfText	dc.b	10,'Could not find other half!',0

SelectAreaText	dc.b	10,'Select area first!',0
DiskWPText	dc.b	10,'Disk is write protected (TDERR 28)!',0
NoFillDataText	dc.b	10,'No fill data!',0
AreasOverlapTxt	dc.b	10,'Areas overlap!',0
UnknownDriveTxt	dc.b	10,'Unknown drivetype (TDERR 33)!',0
InvalidDriveTxt	dc.b	10,'That drive is not in your system!',0
CorruptExecText	dc.b	10,'ExecBase Corrupt. Command not allowed!',0
NotValidVectTxt	dc.b	10,'Not a valid interrupt vector ($000-$3fc)!',0
NotChipAddTxt	dc.b	10,'Not a valid address! Must be in chip!',0
VBRConflictTxt	dc.b	10,'Location conflicts with VBR!',0

GRConflictTxt	dc.b	10,'Location conflicts with GR!',0
MissingIDText	dc.b	10,'Missing compression ID!',0
BPBufferFullTxt	dc.b	10,'All BreakPoints used!',0
BPBufferEmptTxt	dc.b	10,'No BreakPoints set!',0
BPAlreadySetTxt	dc.b	10,'Address already have BreakPoint!',0
NoBreakPointTxt	dc.b	10,'No BreakPoint at this address!',0
WrongBPNoText	dc.b	10,'Not a valid TRAP number (0-15)!',0
IllegalDriveTxt	dc.b	10,'Illegal drive. Must be 0-3!',0
IllegalCopTxt	dc.b	10,'Illegal Copper. Must be 0/1!',0
IllCopOffsetTxt	dc.b	10,'Illegal search-offset (0<x<MaxChip,even)!',0

IllCusOffsetTxt	dc.b	10,'Illegal custom-offset (0<x<$200,even)!',0
IllDCBlockText	dc.b	10,'Corrupt DirCache block!',0
NoFileNameText	dc.b	10,'You must specify a filename!',0
IllFileNameText	dc.b	10,'Filename is corrupt!',0
PrettyFastText	dc.b	10,'WHAM BANG! Pretty fast, eh?',0
FileNotFoundTxt	dc.b	10,'File not found, error!',0
PeekerWidthText	dc.b	10,'Width must be $02-$50!',0
NoSecHdrTxt	dc.b	10,'No sector header present (TDERR 21)!',0
BPNotSetText	dc.b	10,'Could not set breakpoint!',0
NotDirectoryTxt	dc.b	10,'Not a directory!',0

NoParentDirTxt	dc.b	10,'No parent directory!',0
NotFileText	dc.b	10,'Not a file!',0
NoDiskSpaceTxt	dc.b	10,'Not enough disk space!',0
SeekErrorTxt	dc.b	10,'Track not found (TDERR 30)!',0
NotDOSDiskText	dc.b	10,'Not a DOS disk!',0
BadHdrSumText	dc.b	10,'Incorrect header checksum (TDERR 24)!',0
BadSecSumText	dc.b	10,'Incorrect sector checksum (TDERR 25)!',0
DiskVerifyText	dc.b	10,'Verify error!',0
	endoff

	even

;---- Table for fast access to the error messages (order shoul follow error#)
ErrorMessagesTab
	dc.w	SyntaxErrorText
	dc.w	UndefSymbolText
	dc.w	IllAddModeText
	dc.w	IllegalSizeText
	dc.w	IllMnemonicText
	dc.w	UnexpectEOLText
	dc.w	UnknownCmdText
	dc.w	NoDiskText
	dc.w	NotAllSecsText
	dc.w	InvalidSecIDTxt

	dc.w	IllegalSecText
	dc.w	CheckSumErrText	
	dc.w	IllegalBlkText
	dc.w	SymbolFullText
	dc.w	IllSymNameText
	dc.w	IllSeparatText
	dc.w	IllTrackText
	dc.w	IllLengthText
	dc.w	IllegalAreaText
	dc.w	NoFindDataText

	dc.w	NotFoundText
	dc.w	FullTableText
	dc.w	EmptyTableText
	dc.w	NoResumeText
	dc.w	UnbalanceText
	dc.w	NoValueText
	dc.w	UnknownDTText
	dc.w	IllRegNumText
	dc.w	IllegaIndexText
	dc.w	InvalidScaleTxt

	dc.w	DataTooLargeTxt
	dc.w	OnlyOneBDText
	dc.w	OnlyOneODText
	dc.w	OnlyOneIndexTxt
	dc.w	WrongRegOrdText
	dc.w	DestinationText
	dc.w	IllegalFieldTxt
	dc.w	IllegalCondText
	dc.w	FirstHalfText
	dc.w	NoHalfText

	dc.w	SelectAreaText
	dc.w	DiskWPText
	dc.w	NoFillDataText
	dc.w	AreasOverlapTxt
	dc.w	UnknownDriveTxt
	dc.w	InvalidDriveTxt
	dc.w	CorruptExecText
	dc.w	NotValidVectTxt
	dc.w	NotChipAddTxt
	dc.w	VBRConflictTxt

	dc.w	GRConflictTxt
	dc.w	MissingIDText
	dc.w	BPBufferFullTxt
	dc.w	BPBufferEmptTxt
	dc.w	BPAlreadySetTxt
	dc.w	NoBreakPointTxt
	dc.w	WrongBPNoText
	dc.w	IllegalDriveTxt
	dc.w	IllegalCopTxt
	dc.w	IllCopOffsetTxt

	dc.w	IllCusOffsetTxt
	dc.w	IllDCBlockText
	dc.w	NoFileNameText
	dc.w	IllFileNameText
	dc.w	PrettyFastText
	dc.w	FileNotFoundTxt
	dc.w	PeekerWidthText
	dc.w	NoSecHdrTxt
	dc.w	BPNotSetText
	dc.w	NotDirectoryTxt

	dc.w	NoParentDirTxt
	dc.w	NotFileText
	dc.w	NoDiskSpaceTxt
	dc.w	SeekErrorTxt
	dc.w	NotDOSDiskText
	dc.w	BadHdrSumText
	dc.w	BadSecSumText
	dc.w	DiskVerifyText

DiskInfoText	dc.b	10,'Drive',pc_XPos,-2
	dc.b	'Type',pc_XPos,-2
	dc.b	'Format',pc_XPos,-3
	dc.b	'Name',pc_XPos,-28
	dc.b	'Free',pc_XPos,-2
	dc.b	'TrackLen',pc_XPos,-5
	dc.b	'Sync',0

NoDiskTxt	dc.b	'No disk in drive.',0

TaskInfoText	dc.b	'#   Name                     Pri  Type     '
	dc.b	'Status  Address   Stack     PC',0

TaskStatesTxt	dc.b	'Invalid '
	dc.b	'Added   '
	dc.b	'Running '
	dc.b	'Ready   '
	dc.b	'Waiting '
	dc.b	'Except  '
	dc.b	'Removed '

MsgPortFlags	dc.b	'Signal  '
	dc.b	'SoftInt '
	dc.b	'Ignore  '
	dc.b	'Action  '

NodeTypesTxt	dc.b	'Unknown '
	dc.b	'Task    '
	dc.b	'Interrup'
	dc.b	'Device  '
	dc.b	'MsgPort '
	dc.b	'Message '
	dc.b	'FreeMsg '
	dc.b	'ReplyMsg'
	dc.b	'Resouce '
	dc.b	'Library '
	dc.b	'Memory  '
	dc.b	'SoftInt '
	dc.b	'Font    '
	dc.b	'Process '
	dc.b	'Semaphor'
	dc.b	'SigSemap'
	dc.b	'BootNode'
	dc.b	'KickMem '
	dc.b	'Graphics'
	dc.b	'DeathMsg'

LibsInfoText	dc.b	'#    Name                     Address    Version'
	dc.b	'    Neg    Pos    OpenC',0

PortInfoText	dc.b	'#    PortName                TaskName'
	dc.b	'                Address    SigBit  Flags',0

ResInfoText	dc.b	'#    Name                     Address    '
	dc.b	'Init       Type      Pri   Ver  Flags',0

KickMemInfoText	dc.b	'#    Name                     Address    '
	dc.b	'Size',0

KickTagInfoText	dc.b	'#    Name                     Address    '
	dc.b	'Size',0

MemoryAreaText	dc.b	10,'GRMem   : ',0 
	dc.b	10,'ChipMem : ',0
	dc.b	10,'Backup  : ',0
	dc.b	'Not defined.',0

BPZappedText	dc.b	10,'BreakPoint zapped!',0


BreakPointSetTxt
	dc.b	10,'BreakPoint at address ',0

BPRegNumberText	dc.b	10,'Using TRAP #',0,' for BreakPoints.',0

DepackInfoText	dc.b	10,'Depack data to ',0,' and destroy packed data?'
	dc.b	pc_CLRRest,0
DepackingText	dc.b	10,'Depacking data, please wait.',pc_CLRRest,0
DepackOKText	dc.b	10,'Decompression successfull!',pc_CLRRest,0
DepackErrText	dc.b	10,'Decompression failed!',pc_CLRRest,0

CopperText	dc.b	10,'Copper',0,'not defined.',0

NMIPatchedText	dc.b	10,'NMI-vector patching',0

CopOffsetText	dc.b	10,'Copper-search offset set to ',0
CopActiveText	dc.b	10,'Copper',0,' activated at exit.',0

ProtectionChars	dc.b	'DCHSPARWED'

MonthNamesText	dc.b	'JanFebMarAprMayJunJulAugSepOctNovDec'

PeekerText	dc.b	'   Width: $',0,'  Modulo: $',0

NMIROMEntryText	dc.b	10,'NMI entry from ROM',0
DisabledText	dc.b	' disabled.',0
EnabledText	dc.b	' enabled.',0

ColdCaptureText	dc.b	10,'Entry by ColdCapture',0

BitMapHeader	dc.b	10
	dc.b	'00000000001111111111222222222233333333334444444444555555555566666666667777777777',10
	dc.b	'01234567890123456789012345678901234567890123456789012345678901234567890123456789'
	dc.b	0

InternalText	dc.b	'Copper',0
	dc.b	'DiskDMA',0
	dc.b	'Screen',0
	dc.b	-1
	dc.b	'WriteBuffer',0
	dc.b	'TrackBuffer',0
	dc.b	'BlockBuffer',0
	dc.b	'DirectoryCache',0
	dc.b	'Current Track',0
	dc.b	'Preferences',0
	dc.b	'Hardware Map',0
	dc.b	0
	even

InternalPoints	dc.l	GhostCopper	;the first half is GhostChip-offsets
	dc.l	DiskBuffer
	dc.l	ScreenMemory
	dc.l	0	;following are abs offsets
	dc.l	WriteBuffer
	dc.l	TrackBuffer
	dc.l	BlockBuffer
	dc.l	DirectoryCache
	dc.l	CurrentTrack
	dc.l	DefaultPrefs
	dc.l	HardBuffer

CursorSpeedTable
;		off,on times(frames)
	dc.b	-1,-1	;alway on
	dc.b	20,5
	dc.b	10,5
	dc.b	10,10
	dc.b	2,2

;-----------------------------------------------------------------------------;
;		           Data area	-;
;-----------------------------------------------------------------------------;

	cnop	0,4

	include	gri:GRData.0016.s

WriteBuffer	dcb.l	22*512/4,0	;used for write operations
TrackBuffer	dcb.l	22*512/4,0	;decoded track
BlockBuffer	dcb.l	512/4,0	;requested block (getblock)
BlockBufferII	dcb.l	512/4,0
BlockBufferIII	dcb.l	512/4,0
HardBuffer	dcb.l	$200/4,0	;space for entry backup of hard
VectorBuffer	dcb.l	$30,0	;space for entry backup of vectors
CharBuffer	dcb.l	CharBSize/4,'    '
EditCharBack	dcb.l	CharBSize/4,'    ';editor backup
HelpCharBack	dcb.l	CharBSize/4,'    ';help screen backup
DirectoryCache	dcb.l	72,0	;also used for file datablocks
BreakPointTable	dcb.w	6*MaxBreakPoints/2;,0space for 16 breakpoints
CopAlgoBuffer	dcb.w	CopSearchAlgoLen/2,0
SnapBuffer	dcb.l	80/4,0

	cnop	0,4

StackWall	dc.l	0
GhostRiderStack		dcb.l	$200,0
GhostRiderStackEnd	dc.l	0
	dcb.l	16,0

GRMainHunkLen=*-StartOfGR

;-----------------------------------------------------------------------------;
;		        ChipMemory Data	-;
;-----------------------------------------------------------------------------;
	section	ChipData,Data_c
H
GhostRiderCHIP
	offset	0

ChipDataStart
GhostCopper

SpritePointer	dc.w	sprpt+$00,0,sprpt+$02,0;pointer sprite
SpriteCursor	dc.w	sprpt+$08,0,sprpt+$0a,0;cursor sprite
SpriteNULL	dc.w	sprpt+$04,0,sprpt+$06,0;NULL sprites
	dc.w	sprpt+$0c,0,sprpt+$0e,0
	dc.w	sprpt+$10,0,sprpt+$12,0
	dc.w	sprpt+$14,0,sprpt+$16,0
	dc.w	sprpt+$18,0,sprpt+$1a,0
	dc.w	sprpt+$1c,0,sprpt+$1e,0

HeaderColors	dc.w	color+$00,0,color+$02,0

	dc.w	$0807,$fffe	;don't set bplpois b4 8 lines down

HeaderPoi	dc.w	bplpt+$00,0,bplpt+$02,0

BlackLine	dc.w	$0007,$fffe,color,$0000,color+$02,$0000
LineFix1	dc.w	$0007,$fffe	;start pos for 1st txt line

ScreenColors	dc.w	color,$000,color+$02,$000

BplPoi	dc.w	bplpt+$00,0,bplpt+$02,0

PalFix	dc.l	$ffe1fffe
;	dc.w	$180,$008
LineFix2	dc.w	$0007,$fffe	;split line
BplPoi2	dc.w	bplpt+$00,0,bplpt+$02,0
;	dc.w	$0180,$00f

	dc.l	$fffffffe

SPRCursor	dc.l	$26402e00
	dcb.l	8,$f0000000
	dc.l	0

SPRPointer	dc.l	0
	dc.w	%1111111100000000,%1111111100000000
	dc.w	%1000001000000000,%1111111000000000
	dc.w	%1000010000000000,%1111110000000000
	dc.w	%1000100000000000,%1111100000000000
	dc.w	%1001000000000000,%1111000000000000
	dc.w	%1010000000000000,%1110000000000000
	dc.w	%1100000000000000,%1100000000000000
	dc.w	%1000000000000000,%1000000000000000
SPRNULL	dc.l	0
	dc.l	0

	IncDir	gr:gfx/
ScreenHeader	Incbin	Headerr
ChipDataEnd
ChipDataSize=ChipDataEnd-ChipDataStart


ScreenMemory	dcb.b	80,0
	incbin	GRPic3r	;Load GRPicture to screenmemory
PicEnd
PictureSize=PicEnd-ScreenMemory

	dcb.b	80*MaxLines*8-PictureSize,0
ScreenEnd
ScreenMemSize=ScreenEnd-ScreenMemory

	dcb.b	80,0	;just a safety margin


DiskBuffer	dcb.w	DBSize+$100,0;space for raw track data
		;also correct chip-backup below
	endoff

GhostRiderCHIPSize=*-GhostRiderCHIP

GRChipHunkLen=*-H
