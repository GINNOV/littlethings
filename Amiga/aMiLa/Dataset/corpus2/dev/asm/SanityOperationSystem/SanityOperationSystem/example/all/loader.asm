; ==========================================================================
;
;  Programm   :MainLoader
;
;  Für Projekt:SOS
;
;  Coder      :Chaos
;
;
;  History:94-Feb-09 Angefangen
;
; ==========================================================================


HARDWARE	equ	$dff002			; Ja, ich will Hardware-labels
;DEBUG		equ	1			; Debug-streifen aus
;DEBUG2		equ	1			; Debug-streifen aus
;CHIPMEM	equ	1			; nicht auf Chipmem forcen
;NORMBX		equ	1			; don't stop for nothing
;TRACKCACHE	equ	1
;NOAGA		equ	1


		INCLUDE	"include:sos/sos.i"		; Allgemeines Include
		INCLUDE	"include:sos/sosmacros.i"	; SOS Macrosprache
		INCLUDE	"include:sos/DBUG.i"	; Inyerface Include
		INCLUDE	"include:sos/agac.i"	; Inyerface Include

		SECCODE				; Section Code_Public
		INITSOS2 Main_C			; Genormter Anfang mit Clistart

; ==========================================================================
;
;  Konstanten Definition
;
; ==========================================================================

;DELTAMOD	equ	1		; Modules are deltapacked

SCRIPTSIZE	equ	1000
MAXPAR		equ	10
MAXSLOTS	equ	10

; ==========================================================================
;
;  Variablen Definition
;
; ==========================================================================

		rsreset
SOSBase		rs.l	1	; Zwischenspeicher für SOSBase
DBUGBase	rs.l	1
SINEBase	rs.l	1
AGACBase	rs.l	1
Env		rs.l	1
OldEnvDo	rs.l	1

ScriptName	rs.l	1
Comand		rs.b	1
		rs.b	1
MusicOn		rs.w	1
MusicDel	rs.w	1

TopSlot		rs.w	1

ScriptPtr	rs.l	1
SlotList	rs.l	MAXSLOTS
ParList		rs.l	MAXPAR+1
ModMem		rs.l	1
ModSize		rs.l	1
ModUSize	rs.l	1	; uncrunched Size
Buffer		rs.b	80


VARS_SIZEOF	rs.w	0

; ==========================================================================
;
;  Startup-Code
;
; ==========================================================================

SaveA7	dc.l	0

Main_C	moveq	#11,d0			; Betriebssystem-Test
	lea	0.w,a0
;	jsr	_CheckRelease(a6)

	move.l	a7,SaveA7

	IFD	NOAGA
	AGAOFF
	ENDC

	lea	Vars,a5			; a5 Variablen
	move.l	a6,SOSBase(a5)		; a6 retten

	IFD	TRACKCACHE
	move.l	#(4*1024-880)*1024,d0
	jsr	_InitDiskPrefetch(a6)
	ENDC

	OPENLIB	SINE
	OPENLIB	AGAC

	jsr	SelectScript


	ENVINIT	ENVFf_Code+ENVFf_Timer,0	; Init Environments
	move.l	Env(a5),a0			; Set music code
	move.l	#MyEnvDo,ENV_Do(a0)
	move.l	#MyEnvJob,ENV_Job(a0)


.loop	jsr	_SetDefault(a6)
	lea	CList,a0
	lea	Main_I,a1
	moveq	#$20,d0
	jsr	_SetInt(a6)

; ==========================================================================

	bsr	LoadScript
	bsr	ExecuteScript

; ==========================================================================

	jsr	_ClrDefault(a6)
;	bra.s	.loop

	lea	.load,a0
	jmp	_ReLoad(a6)

.load	dc.b	'loader',0
	even

; ==========================================================================
;
; LoadScript
;
; ==========================================================================

LoadScript	move.l	ScriptName(a5),a0
		jsr	_Open(a6)

		move.l	#SCRIPTSIZE,d0
		lea	Script,a0
		jsr	_Read(a6)

		jmp	_Close(a6)

; ==========================================================================
;
; SelectScript
;
; ==========================================================================


; This is the code that enters the hidden part.
; The hidden part is entered if the demo is started from non-aga
; I assume that you remove this :^)

SelectScript	move.l	#.ScriptNameAGA,ScriptName(a5)
		jsr	_GetPISS(A6)
		cmp.b	#3,PISS_Level(a0)
		bhs.s	.aga
		jsr	_OpenScreen(a6)
		lea	.txt_no20,a0
		jsr	_PutScreen(a6)
.loop		jsr	_GetKey(A6)
		cmp.b	#' ',d0
		bne.s	.loop

		lea	.file1,a0
		jsr	_LoadSeg(a6)
		move.l	d0,a0
		jsr	6(a0)
		move.l	(a7)+,d0
		moveq	#0,d0
		rts

.aga		rts

.txt_no20	dc.b	10,'no AGA found, entering hidden part...'
		dc.b	10,'if you have AGA, then you should try running'
		dc.b	10,'SETPATCH which is essential for a system'
		dc.b	10,'friendly AGA-detection to work!',10
		dc.b	10,'P.S. the following realtime PSG-simulation is not'
		dc.b	10,'perfect, so please try to listen to a real'
		dc.b	10,'PSG before you dislike the music. Some musics'
		dc.b	10,'need a bit time to listen',0
.ScriptNameAGA	dc.b	'sosscript',0
.file1		dc.b	'hidden.scr',0
		even

; ==========================================================================
;
; ExecuteScript
;
; ==========================================================================

ExecuteScript:
		move.l	#Script,ScriptPtr(a5)

.loop		bsr	ParseLine
		tst.w	d0
		beq.s	.rts
		bsr	ExecuteLine
		tst.w	d0
		bne.s	.loop
.rts		rts

; ==========================================================================
;
; ParseLine
;
; ==========================================================================

ParseLine:
		move.l	ScriptPtr(a5),a0	; a0 = Script
		lea	Buffer(a5),a1		; a1 = Buffer
		lea	ParList(a5),a2		; a2 = Zeigerliste auf Buffer

		move.b	(a0)+,d0			; Lese Command
		move.b	d0,Comand(a5)
		beq.s	.err
		cmp.b	#';',d0
		beq.s	.readcom
		move.b	(a0)+,d0
		cmp.b	#10,d0
		beq.s	.ok
		cmp.b	#' ',d0			; Lese Space
		bne.s	.err

		moveq	#MAXPAR-1,d1		; d1 = outer loop counter
.loop		move.l	a1,(a2)+			; Trage Zeiger ein
.loop1		move.b	(a0)+,d0
		move.b	d0,(a1)+
		beq.s	.err			; -> End of File
		cmp.b	#10,d0
		beq.s	.endline			; -> End of Line
		cmp.b	#' ',d0
		bne.s	.loop1
		clr.b	-1(a1)			; End of Parameter
		bra.s	.loop
.endline	clr.b	-1(a1)			; End of Line
.ok		clr.l	(a2)
		moveq	#1,d0
		move.l	a0,ScriptPtr(a5)
		rts

.readcom	move.b	(a0)+,d0
		beq.s	.err
		cmp.b	#10,d0
		bne.s	.readcom
		bra.s	.ok

.err		moveq	#0,d0
		illegal
		rts

; ==========================================================================
;
; ExecuteLine
;
; ==========================================================================

ExecuteLine
		lea	ParList(a5),a2		; a2 = Parameterlist
		move.b	Comand(a5),d0		; d0 = Comando
		cmp.b	#'S',d0			; start effect alternate	
		beq	StartAlt
		cmp.b	#'A',d0			; enamble alternate
		beq	AltEnable
		cmp.b	#'e',d0			; execute effect
		beq	Execute
		cmp.b	#'E',d0			; execute effect alt
		beq	ExecuteAlt
		cmp.b	#'p',d0			; push memory
		beq	Push
		cmp.b	#'r',d0			; pop (restore) memory
		beq	Restore
		cmp.b	#'l',d0			; load effect
		beq	Load
		cmp.b	#'s',d0			; start effect
		beq	Start
		cmp.b	#'x',d0			; end demo
		beq	Exit
		cmp.b	#'m',d0			; memory for module
		beq	MemModule
		cmp.b	#'M',d0			; load module
		beq	LoadModule
		cmp.b	#';',d0			; full line comment
		beq	Comment
		cmp.b	#'t',d0			; start timer
		beq	Timer
		cmp.b	#'y',d0			; preload module
		beq	PreloadMod
		cmp.b	#'Y',d0			; start preloaded module
		beq	CopyMod
		cmp.b	#'T',d0			; Switch off Sound
		beq	SoundOff
		cmp.b	#'W',d0			; Wait AltMemory
		beq	Wait
		cmp.b	#'d',d0			; Decrunch module Y
		beq	DecrunchMod
		moveq	#0,d0
		illegal
		rts

Load		bsr	GetNumber
		move.w	d0,TopSlot(a5)
		add.w	d0,d0
		add.w	d0,d0
		move.w	d0,d2
		move.l	(a2)+,a0
		jsr	_LoadSeg(a6)
		move.l	a0,SlotList(a5,d2.w)
		moveq	#1,d0
		rts

Start		bsr	GetNumber
		move.w	d0,TopSlot(a5)
Start_		bsr	GetNumber

		move.w	TopSlot(a5),d1
		add.w	d1,d1
		add.w	d1,d1
		move.l	SlotList(a5,d1.w),a3

		move.l	Env(a5),a1
		move.w	ENV_FirstTick(a1),d1
		add.w	d0,d1
		move.w	d1,ENV_LastTick(a1)
		move.w	d0,ENV_TotalTicks(a1)

		movem.l	d0/a1/a5/a6,-(a7)
		jsr	6(a3)
		movem.l	(a7)+,d0/a1/a5/a6
		add.w	d0,ENV_FirstTick(a1)

		moveq	#1,d0
		rts

StartAlt	bsr	GetNumber
		move.w	d0,TopSlot(a5)
StartAlt_	bsr	GetNumber

		move.w	TopSlot(a5),d1
		add.w	d1,d1
		add.w	d1,d1
		move.l	SlotList(a5,d1.w),a3

		move.l	Env(a5),a1
		move.w	ENV_FirstTick(a1),d1
		add.w	#4,d1			; Safety
		move.w	d1,ENV_LastTick(a1)
		move.w	d0,ENV_TotalTicks(a1)

		movem.l	d0/a1/a5/a6,-(a7)
		moveq	#0,d0
		move.l	d0,a0
		jsr	6(a3)
		movem.l	(a7)+,d0/a1/a5/a6
		add.w	d0,ENV_FirstTick(a1)

		jsr	_AltMemory(a6)
		moveq	#1,d0
		rts

Exit		moveq	#0,d0
		rts

Comment		moveq	#1,d0
		rts

Timer		movem.l	a2/a5/a6,-(a7)
		move.l	ModMem(a5),a0
		jsr	mt_init
		movem.l	(a7)+,a2/a5/a6

		jsr	GetNumber
		moveq	#0,d1
		move.l	Env(a5),a0
		move.w	d0,ENV_LastTick(a0)
		move.w	d1,ENV_Tick(a0)
		move.w	d0,ENV_FirstTick(a0)
		move.w	d0,MusicDel(a5)

		moveq	#1,d0
		move.w	d0,MusicOn(a5)
		rts

Push		jsr	_SetDefault(a6)
		moveq	#1,d0
		rts

Restore		jsr	_ClrDefault(a6)
		moveq	#1,d0
		rts

ExecuteAlt	jsr	Load
		bra	StartAlt_

Execute		jsr	_SetDefault(a6)
		jsr	Load
		jsr	Start_
		jsr	_ClrDefault(a6)
		moveq	#1,d0
		rts

MemModule	moveq	#0,d0
		move.w	d0,MusicOn(a5)
		move.w	#$000f,HARDWARE+DMACON

		bsr	GetNumber
		moveq	#MAT_CHIP,d1
		move.l	d0,ModSize(a5)
		jsr	_AllocMem(a6)
		move.l	d0,ModMem(a5)
		moveq	#1,d0
		rts

LoadModule	move.l	(a2)+,a0
		move.l	ModMem(a5),a1
		move.l	ModSize(a5),d0
		jsr	_LoadDecrunch(a6)
		jsr	UnDelta

;		movem.l	a5/a6,-(a7)
;		move.l	ModMem(a5),a0
;		jsr	mt_init
;		movem.l	(a7)+,a5/a6
		moveq	#1,d0
		rts

AltEnable	moveq	#0,d0
		jsr	_InitAltMemory(a6)
		moveq	#1,d0
		rts

PreloadMod	bsr	GetNumber
		moveq	#0,d1
		move.l	d0,ModSize(a5)
		jsr	_AllocMem(a6)
		move.l	d0,ModMem(a5)

		move.l	(a2),a0
		jsr	_FileLength(a6)
		move.l	d0,ModUSize(a5)

		move.l	(a2)+,a0
		move.l	ModMem(a5),a1
		move.l	ModSize(a5),d0
		jsr	_Load(a6)
		moveq	#1,d0
		rts

CopyMod		moveq	#0,d0
		move.w	d0,MusicOn(a5)
		move.w	#$000f,HARDWARE+DMACON

		move.l	ModSize(a5),d0
		moveq	#MAT_CHIP,d1
		jsr	_AllocMem(a6)

		move.l	d0,a0
		move.l	ModSize(a5),d1
		move.l	ModMem(a5),a1
.loop		move.b	(a1)+,(a0)+
		subq.l	#1,d1
		bne.b	.loop
		move.l	d0,ModMem(a5)

;		movem.l	a5/a6,-(a7)
;		move.l	ModMem(a5),a0
;		jsr	mt_init
;		movem.l	(a7)+,a5/a6
		moveq	#1,d0
		rts

SoundOff	moveq	#0,d0
		move.w	d0,MusicOn(a5)
		moveq	#1,d0
		rts

Wait		ENVWAIT
		moveq	#1,d0
		rts

DecrunchMod	move.l	ModMem(a5),a0
		move.l	a0,a1
		move.l	ModUSize(a5),d0
		jsr	_PPDecrunch(a6)

		jsr	UnDelta

		moveq	#1,d0
		rts

; ==========================================================================
;
; GetNumber
;
; ==========================================================================

GetNumber	move.l	(a2)+,a0
		moveq	#0,d0
		moveq	#0,d1
.loop		move.b	(a0)+,d1
		beq.s	.end
		mulu.w	#10,d0
		and.w	#$f,d1
		add.w	d1,d0
		bra.s	.loop
.end		rts

; ==========================================================================
;
;  Delta unscramble
;
; ==========================================================================

		IFD	DELTAMOD
UnDelta		move.l	ModSize(a5),d0
		move.l	ModMem(a5),a0

		moveq	#0,d1
.loop		add.b	(a0),d1
		move.b	d1,(a0)+
		subq.l	#1,d0
		bne.s	.loop
		rts
		ENDC

		IFND	DELTAMOD
UnDelta		rts
		ENDC


; ==========================================================================
;
; ExecuteScript
;
; ==========================================================================

MyEnvDo		tst.w	MusicOn+Vars
		beq.s	.nomus
		subq.w	#1,MusicDel+Vars
		bpl.s	.nomus
		addq.w	#1,MusicDel+Vars
		movem.l	d2-d7/a2-a6,-(a7)
		bsr	mt_music
		movem.l	(a7)+,d2-d7/a2-a6
		bra.s	.mus
.nomus		lea	Zeros,a0
		move.w	#$000f,HARDWARE+DMACON
		move.l	a0,$dff0a0
		move.l	a0,$dff0b0
		move.l	a0,$dff0c0
		move.l	a0,$dff0d0
		move.w	#$0001,d0
		move.w	d0,$dff0a4
		move.w	d0,$dff0b4
		move.w	d0,$dff0c4
		move.w	d0,$dff0d4
		move.w	#$80,d0
		move.w	d0,$dff0a6
		move.w	d0,$dff0b6
		move.w	d0,$dff0c6
		move.w	d0,$dff0d6
		move.w	#0,d0
		move.w	d0,$dff0a8
		move.w	d0,$dff0b8
		move.w	d0,$dff0c8
		move.w	d0,$dff0d8

.mus		move.l	Vars+Env,a0

;		move.w	ENV_Tick(a0),d0		; timeout?
;		cmp.w	ENV_LastTick(a0),d0
;		bls.s	.ok
;		addq.w	#1,ENV_Tick(a0)		; force timeout!
;		lea	CList,a0
;		lea	Main_I,a1
;		moveq	#$20,d0
;		jmp	_SetIntFast(a6)

.ok
		IFND	NORMBX
		btst	#2,$dff016
		bne.s	.2
		move.w	ENV_LastTick(a0),ENV_Tick(a0)
		rts
		ENDC
.2		addq.w	#1,ENV_Tick(a0)
		rts

MyEnvJob	move.l	a5,-(a7)
		lea	Vars,a5
		DEBJOB
		move.l	(a7)+,a5
		IFD	DEBUG2
		move.w	#$0c00,$dff106
		move.w	$dff006,$dff180
		ENDC
		IFD	TRACKCACHE
		jsr	_PrefetchDisk(a6)
		ENDC
		IFD	NOAGA
		move.w	#0,$dff1fc
		ENDC
		btst	#2,$dff016
		bne.s	.rts
		move.l	SaveA7,a7
.rts		rts

Main_I		movem.l	d0-d7/a0-a6,-(a7)		; Rette Register

		bsr	MyEnvDo

		move.w	#$0070,$dff09c
		movem.l	(a7)+,d0-d7/a0-a6
		nop
		rte

; ==========================================================================

		include	'replay.asm'


; ==========================================================================

		SECBSS

Vars		ds.b	VARS_SIZEOF	; Effekt Variablen
Script		ds.b	SCRIPTSIZE

; ==========================================================================

		SECCODE_C

CList		dc.w	$1f0f,$fffe
		dc.w	$0096,$800f
genlock1	dc.w	$0100,$0000		; Bitplanes aus
		dc.w	$01fc,$0000
		dc.w	$ffff,$fffe
Zeros		dc.w	0,0
		END
