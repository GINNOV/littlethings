;------------------T--------T
Track:	EQU	0
Raster:	EQU	0
A1200:	EQU	1

	IFEQ	A1200-1
MatrixSize:	EQU	13
ECS:	EQU	0
	ELSE
MatrixSize:	EQU	11
ECS:	EQU	1
	ENDC


MyDmacon=%01111100000
;         abcdefghhhh
; a = Blitter nasty
; b = Enable DMA activity (always set this!)
; c = Bitplane enable
; d = Copper enable
; e = Blitter enable
; f = Sprite enable
; g = Disk enable
; h = Audio channels enable

MyIntena=%100000000100000
;         abcdeeeefghijkl
; a = Enable interrupts
; b = Lev. 6 External interrupt
; c = Lev. 5 Disk sync found
; d = Lev. 5 Serial port receive buffer full
; e = Lev. 4 Audio ch. 3-0 block finished
; f = Lev. 3 Blitter finished
; g = Lev. 3 Vertical blank
; h = Lev. 3 Copper
; i = Lev. 2 I/O Ports and timers
; j = Lev. 1 Software
; k = Lev. 1 Disk block finished
; l = Lev. 1 Serial port transmit buffer empty

*******************************************************************************
**Macros
*******************************************************************************
WaitBlt:	MACRO
.vent\@:	if	Raster=1
	move.w	#$fff,Color00+_Custom
	endif
	btst	#14,Dmaconr+_Custom
	bne.b	.vent\@
	if	Raster=1
	move.w	#0,Color00+_Custom
	endif
	ENDM

SetInt:	MACRO
	move.l	(Lev\1Base).w,OldIrq\1
	move.l	#Lev\1Irq,(Lev\1Base).w
	bra.b	jumpo\@
OldIrq\1:	dc.l	0
jumpo\@:
	ENDM

ClrInt:	MACRO
	move.l	OldIrq\1(pc),(Lev\1Base).w
	ENDM

Push.l:	MACRO
	movem.l	\1,-(sp)
	ENDM

Push.w:	MACRO
	movem.w	\1,-(sp)
	ENDM

Pull.l:	MACRO
	movem.l	(sp)+,\1
	ENDM

Pull.w:	MACRO
	movem.w	(sp)+,\1
	ENDM

StartPrg:	MACRO
	move.w	#$7fff,Intreq+_Custom
	move.w	#MyDmacon+$8000,Dmacon+_Custom
	move.w	#MyIntena+$8000,Intena+_Custom
	ENDM

StopPrg:	MACRO
	move.w	#$7fff,Intena+_Custom
	move.w	#$7fff,Dmacon+_Custom
	move.w	#$7fff,Intreq+_Custom
	ENDM

StopSystem:	MACRO
	move.w	Intenar+_Custom,OldIntena
	move.w	Dmaconr+_Custom,OldDmacon
	StopPrg
	bra.b	jumpo\@
OldIntena:	dc.w	0
OldDmacon:	dc.w	0
jumpo\@:
	ENDM

StartSystem:	MACRO
	move.w	OldDmacon(pc),d0
	or.w	#$8000,d0
	move.w	d0,Dmacon+_Custom
	move.w	OldIntena(pc),d0
	or.w	#$8000,d0
	move.w	d0,Intena+_Custom
	ENDM

ClearBss:	MACRO
	lea	_Bss1Start,a0
	move.l	#(_Bss1End-_Bss1Start)/4,d0
.clrloop\@	clr.l	(a0)+
	subq.l	#1,d0
	bne.b	.clrloop\@
	ENDM





*******************************************************************************
**
**  Initialisering
**
*******************************************************************************
	SECTION	DenFedeKode,code

	JumpPtr	Begin

Begin:	IFEQ	Track-0
	INCDIR	Work:Code/LINKS/
	INCLINK	LOADVIEW.LINK
	Push.l	d0-a6
	bsr	LW_Reset
	StopSystem
	ELSE
	move.l	#Lev3Irq,$64.w
	rts
	ENDC

**Init starter -----------------------------------
	ClearBss	1
	ClearBss	2

	bsr	InitCodeBuffer
	bsr	InitVerticalBuffer
	bsr	InitInterpolBuffer
	bsr	ComputeColors2
	bsr	InitAGACopper
	lea	ColorArray,a0
	lea	AGA_Colors,a1
	moveq	#0,d0
	IFEQ	ECS-1
	move.w	#31,d1
	ELSE
	move.w	#255,d1
	ENDC
	bsr	LoadAGACopper

	IFEQ	Track-0
	SetInt	3
**Init slutter -----------------------------------

	WaitBlt
	StartPrg




*******************************************************************************
**
**  Vent på exitsignal
**
*******************************************************************************
WaitForExit:	tst.b	VBlank
	beq.b	WaitForExit

	clr.b	VBlank
	tst.b	IWantOut
	bne.b	ExitToDos
	bra.b	WaitForExit




*******************************************************************************
**
**  Exit to AmigaDOS
**
*******************************************************************************
ExitToDos:
	StopPrg

**Exit starter -----------------------------------
	ClrInt	3
**Exit slutter -----------------------------------

	StartSystem

	bsr	LW_Set

	Pull.l	d0-a6
	moveq	#0,d0
	ENDC
	rts

_GfxBase:	dc.l	0
_OldView:	dc.l	0




*******************************************************************************
**
**  Level 3 interrupt
**
*******************************************************************************
Lev3Irq:	st	VBlank
	Push.l	d0-a6
**Lev3irq starter --------------------------------
	move.l	#Copper,Cop2lch+_Custom
	move.w	d0,Copjmp2+_Custom

	lea	Routines(pc),a0
	move.w	Status(pc),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	(a0,d0.w),a0
	jsr	(a0)

**Lev3irq slutter --------------------------------
	IFEQ	Track-0
	btst	#6,$bfe001
	bne.b	.noleft
	st	IWantOut
.noleft	ENDC
	IF	Raster=1
	move.w	#$f00,Color00+_Custom
	ENDIF
	WaitBlt
	IF	Raster=1
	move.w	#$00f,Color00+_Custom
	ENDIF
	move.b	$dff005,d0
	lsl.w	#8,d0
	move.b	$dff006,d0
	cmp.w	MaxRast,d0
	blt.b	.ud
	move.w	d0,MaxRast
.ud:
	Pull.l	d0-a6
	IFEQ	Track-0
	move.w	#$0020,Intreq+_Custom
	ELSE
	move.w	#$0004,Intreq+_Custom
	ENDC
	rte

Status:	dc.w	0
Routines:	dc.l	FadeUp,RingHandler,FadeDown

RingHandler:	bsr	SwapScr
	bsr	MakeDezign
	bsr	ClrScr
	bsr	StoryBoard
	cmp.w	#28000,ZCenter
	bge.b	.none
	bsr	Rotate
	bsr	DrawFaces
.none
	cmp.w	#30000,ZCenter
	bne.w	.out
	st	IWantOut
.out	rts

DezignPtr:	dc.w	0
DezStat:	dc.w	0
MakeDezign:	move.w	DezStat(pc),d0
	beq.b	Dez_MakeIt
	subq.w	#2,d0
	beq.b	Dez_RemoveIt
	rts
Dez_MakeIt:	cmp.w	#8*21,DezignPtr
	bne.b	.doit
	addq.w	#1,DezStat
.doit	lea	DezignJohn,a0
	cmp.w	#$38,DezignPtr
	ble.b	.ok
	subq.w	#4,a0
.ok	move.w	DezignPtr(pc),d0
	lsl.w	#4,d0
	sub.w	d0,a0
	move.w	#$403,-10(a0)
	addq.w	#1,DezignPtr
	rts
Dez_RemoveIt:	tst.w	DezignPtr
	bgt.b	.doit
	addq.w	#1,DezStat
	rts
.doit	subq.w	#1,DezignPtr
	lea	DezignJohn,a0
	cmp.w	#$38,DezignPtr
	ble.b	.ok
	subq.w	#4,a0
.ok	move.w	DezignPtr(pc),d0
	lsl.w	#4,d0
	sub.w	d0,a0
	move.w	#$103,-10(a0)
	rts


FadeUp:	move.l	#FadeCopper,Cop2lch+_Custom
	move.w	d0,Copjmp2+_Custom

	move.w	FadeCopper|.col+2,d0
	move.w	#$103,d1
	bsr	fader
	move.w	d0,FadeCopper|.col+2
	cmp.w	#$103,d0
	bne.b	.out
	addq.w	#1,Status
.out	rts
	
FadeDown:	move.l	#FadeCopper,Cop2lch+_Custom
	move.w	d0,Copjmp2+_Custom

	move.w	FadeCopper|.col+2,d0
	moveq	#0,d1
	bsr	fader
	move.w	d0,FadeCopper|.col+2
	tst.w	d0
	seq	IWantOut
	rts
	



**d0=fade from
**d1=fade to
**out: d0=newcol
fader:	move.w	d0,d2
	move.w	d1,d3
	lsr.w	#8,d2
	lsr.w	#8,d3
	cmp.w	d2,d3
	beq.b	.nored
	blt.b	.redsub
	add.w	#$100,d0
	bra.b	.nored
.redsub:	sub.w	#$100,d0
.nored:	move.w	d0,d2
	move.w	d1,d3
	lsr.w	#4,d2
	lsr.w	#4,d3
	and.w	#$f,d2
	and.w	#$f,d3
	cmp.w	d2,d3
	beq.b	.nogreen
	blt.b	.greensub
	add.w	#$10,d0
	bra.b	.nogreen
.greensub:	sub.w	#$10,d0
.nogreen:	move.w	d0,d2
	move.w	d1,d3
	and.w	#$f,d2
	and.w	#$f,d3
	cmp.w	d2,d3
	beq.b	.noblue
	blt.b	.bluesub
	addq.w	#$1,d0
	bra.b	.noblue
.bluesub:	subq.w	#$1,d0
.noblue:	rts


*******************************************************************************
**
**  Storyboard
**
*******************************************************************************
StoryBoard:	move.w	Story,d0
	beq.b	Story_00
	subq.w	#1,d0
	beq.b	Story_01
	subq.w	#1,d0
	beq.w	Story_02
	subq.w	#1,d0
	beq.w	Story_03
	subq.w	#1,d0
	beq.w	Story_04
	rts

Story_00:	sub.w	#100,XCenter
	beq.b	.out
	rts
.out	clr.w	YAdd
	addq.w	#1,Story
	move.w	#3000,StoryData3
	rts

Story_01:	lea	Story_01_Sine,a0
	move.w	StoryData1,d0
	add.w	d0,d0
	move.w	(a0,d0.w),d0
	muls	StoryData3,d0
	divs	#3000,d0
	move.w	d0,d7
	move.w	d0,d1
	sub.w	StoryData2,d0
	move.w	d1,StoryData2
	sub.w	d0,Coords+0*6
	sub.w	d0,Coords+1*6
	sub.w	d0,Coords+4*6
	sub.w	d0,Coords+5*6
	addq.w	#1,StoryData1
	and.w	#32-1,StoryData1

	asr.w	#2,d7
	neg.w	d7
	add.w	d7,d7
	move.w	d7,YAngle2
	and.w	#2048-1,YAngle2

	sub.w	#30,StoryData3
	bge.b	.out
	addq.w	#1,Story
	clr.w	StoryData1
	move.w	#256*2,StoryData2
.out	rts

Story_02:	lea	XAdd,a0
	cmp.w	#6,(a0)+
	beq.b	.xok
	addq.w	#2,-2(a0)
.xok	cmp.w	#-2,(a0)+
	beq.b	.yok
	subq.w	#2,-2(a0)
.yok	cmp.w	#6,(a0)+
	beq.b	.zok
	addq.w	#2,-2(a0)
	rts
.zok	addq.w	#1,Story
	move.w	#25*50,StoryPause
	rts

Story_03:	bsr	TransformObj
	subq.w	#1,StoryPause
	bne.b	.ok
	addq.w	#1,Story
	addq.w	#1,DezStat
.ok	rts

Story_04:	lea	SinTable,a0
	move.w	StoryData1,d1
	move.w	StoryData2,d2
	move.w	StoryData3,d3

	add.w	#100,ZCenter

	move.w	(a0,d2.w),d2
	muls	#3500,d2
	asr.l	#8,d2
	asr.l	#6,d2
	move.w	ZCenter,d3
	sub.w	#6000,d3
	muls	d3,d2
	divs	#12000,d2
	move.w	d2,YCenter

	move.w	(a0,d1.w),d1
	muls	#3500,d1
	asr.l	#8,d1
	asr.l	#6,d1
	move.w	ZCenter,d3
	sub.w	#6000,d3
	muls	d3,d1
	divs	#12000,d1
	move.w	d1,XCenter

	lea	StoryData1,a0
	add.w	#32,(a0)
	and.w	#2048-1,(a0)+
	add.w	#32,(a0)
	and.w	#2048-1,(a0)+
	addq.w	#4,(a0)
	and.w	#2048-1,(a0)+
	bsr	TransformObj
	rts

StoryData1:	dc.w	0
StoryData2:	dc.w	0
StoryData3:	dc.w	0
StoryPause:	dc.w	0

*******************************************************************************
**
**  Compute some colors
**
*******************************************************************************
ComputeColors2:	lea	.colors+4,a0
	move.l	#$00404b,d0
	move.l	#$00c8b4,d1
	moveq	#0,d6
	IFEQ	ECS-1
	moveq	#4,d7
	ELSE
	moveq	#7,d7
	ENDC
.makecols	bsr	FadeAGA
	move.l	d2,(a0)+
	addq.w	#1,d6
	IFEQ	ECS-1
	cmp.w	#5,d6
	ELSE
	cmp.w	#8,d6
	ENDC
	bne.b	.makecols
	lea	ColorArray,a0
	moveq	#0,d0
.exanext	moveq	#7,d1
	moveq	#0,d2
.testigen	btst	d1,d0
	beq.b	.a_zero
	addq.w	#1,d2
.a_zero	dbra	d1,.testigen
	add.w	d2,d2
	add.w	d2,d2
	move.l	.colors(PC,d2.w),d2
	move.l	d2,(a0)+
	addq.w	#1,d0
	IFEQ	ECS-1
	cmp.w	#32,d0
	ELSE
	cmp.w	#256,d0
	ENDC
	bne.b	.exanext
	rts
.colors	dc.l	$110033
	IFEQ	ECS-1
	blk.l	5,0
	ELSE
	blk.l	8,0
	ENDC




*******************************************************************************
**
**  Fade 24bit colors
**
**  input:
**  d0.l=source color
**  d1.l=dest color
**  d6.w=step
**  d7.w=last step
**
**  output:
**  d2.l=new color
**
**  trashed regs:
**  d0-d6
**
*******************************************************************************
FadeAGA:	move.l	d0,d2
	move.l	d1,d3
	swap	d2
	swap	d3
	sub.w	d2,d3
	muls	d6,d3
	divs	d7,d3
	add.w	d2,d3
	swap	d3
	clr.w	d3		;R
	move.l	d0,d2
	move.l	d1,d4
	and.w	#$ff00,d2
	and.w	#$ff00,d4
	sub.w	d2,d4
	lsr.w	#8,d4
	muls	d6,d4
	divs	d7,d4
	lsl.w	#8,d4
	add.w	d2,d4
	and.l	#$00ff00,d4	;G
	move.w	d0,d5
	move.w	d1,d2
	and.w	#$00ff,d5
	and.w	#$00ff,d2
	sub.w	d5,d2
	muls	d6,d2
	divs	d7,d2
	add.w	d5,d2
	and.l	#$0000ff,d2	;B
	or.l	d3,d2
	or.l	d4,d2	;color
	rts





*******************************************************************************
**
**  Load AGA copper with colors
**
**  input:
**  a0.l=24bit color array (00000000RRRRRRRRGGGGGGGGBBBBBBBB per color)
**  a1.l=initialized aga copper array
**  d0.w=start color
**  d1.w=end color
**
*******************************************************************************
LoadAGACopper:
	IFEQ	ECS-0
	moveq	#0,d2	;color index to current bank
	sub.w	d0,d1	;number of colors to load
	move.w	d1,d7	;color countdown
	move.w	d0,d6
	beq.b	.noskip
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,a0	;skip first colors
	move.w	d6,d0
	lsr.w	#5,d0
	mulu	#33*2*4,d0
	add.w	d0,a1	;skip first banks
	and.w	#$1f,d6
.noskip	addq.w	#4,a1
	clr.w	-(sp)
	lea	33*4(a1),a2	;lower nibbles
.next	move.l	(a0)+,d0
	move.l	d0,d3
	move.w	d0,d1
	move.l	d0,d2
	and.w	#$000f,d0
	and.w	#$0f00,d1
	lsr.w	#4,d1
	swap	d2
	and.w	#$f,d2
	lsl.w	#8,d2
	or.w	d2,d1
	or.w	d1,d0
	move.w	d0,2(a2)
	move.l	d3,d0
	move.w	d0,d1
	move.l	d0,d2
	and.w	#$f0,d0
	lsr.w	#4,d0
	move.w	d1,(sp)
	move.b	(sp),d1
	and.w	#$00f0,d1
	swap	d2
	and.w	#$00f0,d2
	lsl.w	#4,d2
	or.w	d2,d1
	or.w	d1,d0
	move.w	d0,2(a1)
	addq.w	#4,a1
	addq.w	#4,a2
	subq.w	#1,d7
	blt.b	.out
	addq.w	#1,d6
	cmp.w	#$20,d6
	bne.b	.next
	lea	34*4(a1),a1
	lea	34*4(a2),a2
	moveq	#0,d6
	bra.b	.next
.out	clr.w	(sp)+
	rts
	ELSE
	sub.w	d0,d1
	add.w	d0,d0
	add.w	d0,d0
	lea	2(a1,d0.w),a1
.loop	move.l	(a0)+,d2
	move.l	d2,d3
	move.l	d2,d4
	swap	d4
	lsl.w	#4,d4
	and.w	#$f00,d4
	lsr.w	#8,d3
	and.w	#$0f0,d3
	lsr.w	#4,d2
	and.w	#$00f,d2
	or.w	d2,d3
	or.w	d3,d4
	move.w	d4,(a1)
	addq.w	#4,a1
	dbra	d1,.loop
	rts
	ENDC




*******************************************************************************
**
**  Init AGA copper-array
**
*******************************************************************************
InitAGACopper:	lea	AGA_Colors,a0
	IFEQ	ECS-0
	move.l	#Bplcon3<<16!$0c40,d0
	move.l	#Bplcon3<<16!$0e40,d1
	moveq	#8-1,d7
.loop	move.l	d0,(a0)+
	bsr	.fillit
	move.l	d1,(a0)+
	bsr	.fillit
	add.w	#$2000,d0
	add.w	#$2000,d1
	dbra	d7,.loop
	rts
	ENDC
.fillit	move.w	#Color00,d2
	moveq	#32-1,d6
.fillloop	move.w	d2,(a0)+
	clr.w	(a0)+
	addq.w	#2,d2
	dbra	d6,.fillloop
	rts

*******************************************************************************
**
**  Draw a dotted line
**
**  input:
**    d0-d3: coords
**
*******************************************************************************
DrawLine:	MACRO
	cmp.w	d0,d2
	bge.b	.ok\@
	exg	d0,d2
	exg	d1,d3
.ok\@	move.w	d0,d5
	move.w	d1,d6

	lea	VerticalMulsTab,a1
	sub.w	d1,d3
	add.w	#256,d3
	add.w	d3,d3
	add.w	d3,d3
	move.l	(a1,d3.w),a1

	lea	CodeMulsTab,a2
	sub.w	d0,d2
	lsl.w	#3,d2
	and.w	#$7,d0
	add.w	d0,d2
	add.w	d2,d2
	add.w	d2,d2
	move.l	(a2,d2.w),a2

	lsl.w	#4,d6
	move.w	d6,d7
	lsl.w	#2,d7
	add.w	d7,d6
	asr.w	#3,d5
	add.w	d5,d6
	move.l	Screen_Draw,a0
	lea	(a0,d6.w),a0
	moveq	#0,d0
	moveq	#1,d1
	moveq	#2,d2
	moveq	#3,d3
	moveq	#4,d4
	moveq	#5,d5
	moveq	#6,d6
	moveq	#7,d7
	jsr	(a2)
	ENDM




*******************************************************************************
**
**  Prøv lidt rotation
**
*******************************************************************************
Rotate:	lea	Coords,a0
	lea	PerspCoords,a1
	lea	CosTable,a2
	lea	SinTable,a3
	lea	Angles,a4
	lea	XCenter,a5
	sub.w	a6,a6

.nextkoord	cmp.w	#$8000,(a0)
	beq.w	.out

	move.w	(a0)+,d0
.RotXY:	move.w	(a0)+,d1	;d0=Xp , d1=Yp & d2=Vinkel
	move	(a4),d2
	move	(a2,d2.w),d3
	move	(a3,d2.w),d4
	move	d0,d7
	move	d1,d6
	muls	d3,d0
	muls	d4,d1
	muls	d4,d7
	muls	d3,d6
	sub.l	d1,d0
	add.l	d6,d7
	lsl.l	#2,d0
	lsl.l	#2,d7
	swap	d0		;X
	swap	d7		;Y
.RotXZ:	move	(a0)+,d1	;d0=Xp , d1=Zp & d2=Vinkel
	move	2(a4),d2
	move.w	a6,d3
	btst	#1,d3
	bne.b	.nope
	move.w	YAngle2,d2
.nope	move	(a2,d2.w),d3
	move	(a3,d2.w),d4
	move	d0,d5
	move	d1,d6
	muls	d3,d0
	muls	d4,d1
	muls	d4,d5
	muls	d3,d6
	sub.l	d1,d0
	add.l	d6,d5
	lsl.l	#2,d0
	lsl.l	#2,d5
	swap	d0		;X
	swap	d5		;Z
.RotYZ:	move	4(a4),d2	;d7=Yp , d5=Zp & d2=Vinkel
	move	(a2,d2.w),d3
	move	(a3,d2.w),d4
	move	d7,d1
	move	d5,d6
	muls	d3,d7
	muls	d4,d5
	muls	d4,d1
	muls	d3,d6
	sub.l	d5,d7
	add.l	d6,d1
	lsl.l	#2,d7
	lsl.l	#2,d1
	swap	d7		;Y
	swap	d1		;Z
.MakePer:	add.w	4(a5),d1	;Z
	add.w	(a5),d0
	add.w	2(a5),d7
	ext.l	d0
	ext.l	d7
	lsl.l	#8,d0
	lsl.l	#8,d7
	divs	d1,d0
	divs	d1,d7
	add	#320/2,d0
	add	#256/2,d7
.GemCor:	move	d0,(a1)+
	move	d7,(a1)+
	addq.w	#1,a6
	bra.w	.nextkoord
.out:	lea	XAdd,a1
	lea	Angles,a0
	move.w	(a1)+,d0
	add.w	d0,(a0)
	and.w	#2048-1,(a0)+
	move.w	(a1)+,d0
	add.w	d0,(a0)
	and.w	#2048-1,(a0)+
	move.w	(a1)+,d0
	add.w	d0,(a0)
	and.w	#2048-1,(a0)+
	cmp.w	#1,Story
	beq.b	.heltiskoven
	move.w	Angles+2,YAngle2
.heltiskoven	rts




*******************************************************************************
**
**  Clear screen using blitter
**
*******************************************************************************
ClrScr:	lea	_Custom,a6
	WaitBlt
	move.l	Screen_Clear,Bltdpth(a6)
	move.l	#$01000000,Bltcon0(a6)
	move.w	#40,Bltdmod(a6)
	move.w	#20,Bltsizh(a6)
	move.w	#256,Bltsizv(a6)
;	move.w	#256<<6!20,Bltsize(a6)
	rts




*******************************************************************************
**
**  Swap screen for doublebuffering!
**
*******************************************************************************
SwapScr:	IFEQ	ECS-1
	lea	Screen_Clear+7*4,a0
	ELSE
	lea	Screen_Clear+10*4,a0
	ENDC
	lea	-4(a0),a1
	move.l	(a1),d7
	IFEQ	ECS-1
	moveq	#6-1,d6
	ELSE
	moveq	#9-1,d6
	ENDC
.cloop	move.l	-(a1),-(a0)
	dbra	d6,.cloop
	move.l	d7,(a1)

	lea	Copper_PlanePtr+2,a3
	lea	Screen_Show,a0
	IFEQ	ECS-1
	moveq	#5-1,d7
	ELSE
	moveq	#8-1,d7
	ENDC
.loop	move.l	(a0)+,d0
	move.w	d0,4(a3)
	swap	d0
	move.w	d0,(a3)
	addq.w	#8,a3
	dbra	d7,.loop
	rts




*******************************************************************************
**
**  Initialiser InterpolBuffer
**
*******************************************************************************
InitInterpolBuffer:
	lea	InterpolBuffer,a6
	move.w	#-320,d0	;size
.nextsize	moveq	#MatrixSize-1,d1	;trinnummer
.loop	move.w	d0,d2
	muls	d1,d2
	divs	#MatrixSize-1,d2	;linjenummer
	move.w	d2,(a6)+
	IFEQ	Track-0
	move.w	a6,$dff180
	ENDC
	dbra	d1,.loop
	addq.w	#1,d0
	cmp.w	#319,d0
	ble.b	.nextsize
	rts




*******************************************************************************
**
**  Initialiser VerticalBuffer
**
*******************************************************************************
InitVerticalBuffer:
	lea	VerticalBuffer,a6
	lea	VerticalMulsTab,a5
	move.w	#-256,d0	;size
.nextsize	moveq	#MatrixSize-1,d1	;trinnummer
	move.l	a6,(a5)+
.loop	move.w	d0,d2
	muls	d1,d2
	divs	#MatrixSize-1,d2	;linjenummer
	muls	#80,d2
	move.w	d2,(a6)+
	IFEQ	Track-0
	move.w	a6,$dff180
	ENDC
	dbra	d1,.loop
	addq.w	#1,d0
	cmp.w	#255,d0
	ble.b	.nextsize
	rts




*******************************************************************************
**
**  Initialiser CodeBuffer
**
*******************************************************************************
InitCodeBuffer:	lea	DotInstructions(pc),a0
	lea	CodeBuffer,a6
	lea	CodeMulsTab,a5
	moveq	#0,d0	;startpixel
	moveq	#0,d1	;stoppixel
.nextsize	moveq	#8-1,d5	;bits per byte
.nextbit	move.l	a6,(a5)+
	moveq	#MatrixSize-1,d2	;trinnummer
.loop	move.w	d1,d3
	sub.w	d0,d3
	mulu	d2,d3
	divu	#MatrixSize-1,d3
	add.w	d0,d3	;pixelnummer
	move.w	d3,d4
	lsr.w	#3,d3
	and.w	#$7,d4
	add.w	d4,d4
	add.w	d4,d4
	move.w	(a0),(a6)+
	move.w	2(a0,d4.w),(a6)+
	move.b	4(a0,d4.w),(a6)+
	move.b	d3,(a6)+
	dbra	d2,.loop
	move.w	RtsCode(pc),(a6)+
	IFEQ	Track-0
	move.w	a6,$dff180
	ENDC
	addq.w	#1,d0
	addq.w	#1,d1
	dbra	d5,.nextbit
	subq.w	#8,d0
	subq.w	#7,d1
	cmp.w	#319,d1
	ble.b	.nextsize
	rts

DotInstructions:	move.w	(a1)+,a2		;8
	bset	d7,$0(a0,a2.w)	;18
BytesPerDot:	EQU	*-DotInstructions
	bset	d6,$0(a0,a2.w)
	bset	d5,$0(a0,a2.w)
	bset	d4,$0(a0,a2.w)
	bset	d3,$0(a0,a2.w)
	bset	d2,$0(a0,a2.w)
	bset	d1,$0(a0,a2.w)
	bset	d0,$0(a0,a2.w)
RtsCode:	rts




DrawFaces:	lea	PerspCoords,a0
	lea	Faces,a1

	moveq	#0,d6
	moveq	#0,d7
	move.b	(a1)+,d6
	add.w	d6,d6
	add.w	d6,d6
	move.b	(a1)+,d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	(a0,d6.w),d0
	move.w	2(a0,d6.w),d1
	move.w	(a0,d7.w),d2
	move.w	2(a0,d7.w),d3
	lea	SideBuffer1,a2
	bsr	.interpol

	moveq	#0,d6
	moveq	#0,d7
	move.b	(a1)+,d6
	add.w	d6,d6
	add.w	d6,d6
	move.b	(a1)+,d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	(a0,d6.w),d0
	move.w	2(a0,d6.w),d1
	move.w	(a0,d7.w),d2
	move.w	2(a0,d7.w),d3
	lea	SideBuffer2,a2
	bsr	.interpol

	lea	FaceBuffer1,a2
	lea	SideBuffer1,a3
	lea	SideBuffer2,a4
	REPT	MatrixSize
	move.w	(a3)+,d0
	move.w	(a3)+,d1
	move.w	(a4)+,d2
	move.w	(a4)+,d3
	Push.l	a3/a4
	bsr	.interpol
	Pull.l	a3/a4
	ENDR


	moveq	#0,d6
	moveq	#0,d7
	move.b	(a1)+,d6
	add.w	d6,d6
	add.w	d6,d6
	move.b	(a1)+,d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	(a0,d6.w),d0
	move.w	2(a0,d6.w),d1
	move.w	(a0,d7.w),d2
	move.w	2(a0,d7.w),d3
	lea	SideBuffer1,a2
	bsr	.interpol

	moveq	#0,d6
	moveq	#0,d7
	move.b	(a1)+,d6
	add.w	d6,d6
	add.w	d6,d6
	move.b	(a1)+,d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	(a0,d6.w),d0
	move.w	2(a0,d6.w),d1
	move.w	(a0,d7.w),d2
	move.w	2(a0,d7.w),d3
	lea	SideBuffer2,a2
	bsr	.interpol

	lea	FaceBuffer2,a2
	lea	SideBuffer1,a3
	lea	SideBuffer2,a4
	REPT	MatrixSize
	move.w	(a3)+,d0
	move.w	(a3)+,d1
	move.w	(a4)+,d2
	move.w	(a4)+,d3
	Push.l	a3/a4
	bsr	.interpol
	Pull.l	a3/a4
	ENDR



	lea	FaceBuffer1,a5
	lea	FaceBuffer2,a6
	REPT	MatrixSize*MatrixSize
	move.w	(a5)+,d0
	move.w	(a5)+,d1
	move.w	(a6)+,d2
	move.w	(a6)+,d3
	DrawLine
	ENDR

	rts

.interpol	lea	InterpolBuffer,a3
	sub.w	d0,d2
	sub.w	d1,d3
	add.w	#320,d2
	add.w	#320,d3
	muls	#MatrixSize*2,d2
	muls	#MatrixSize*2,d3
	lea	(a3,d2.w),a4
	lea	(a3,d3.w),a5
	REPT	MatrixSize
	move.w	(a4)+,d5
	add.w	d0,d5
	move.w	d5,(a2)+
	move.w	(a5)+,d5
	add.w	d1,d5
	move.w	d5,(a2)+
	ENDR
	rts



TransformObj:	tst.w	TransPause
	bne.b	.pause
	move.l	TransPointer,a0
	lea	Coords,a1
	moveq	#0,d6
	moveq	#3*8-1,d7
.loop	move.w	(a0)+,d0
	sub.w	(a1),d0
	beq.b	.nothing
	bpl.b	.plus
	sub.w	#50,(a1)+
	bra.b	.donext
.plus	add.w	#50,(a1)+
	bra.b	.donext
.nothing	addq.w	#1,d6
	addq.w	#2,a1
.donext	dbra	d7,.loop
	cmp.w	#3*8,d6
	bne.b	.out
	cmp.w	#$8000,(a0)
	bne.b	.noend
	lea	TransObjects,a0
.noend	move.l	a0,TransPointer
	move.w	#50*3,TransPause
.out	rts
.pause	subq.w	#1,TransPause
	rts



*******************************************************************************
**
**  Variable
**
*******************************************************************************
	SECTION	SjovData,data

Faces:	dc.b	0,1,3,2
	dc.b	4,5,7,6

Coords:	dc.w	-1500,-1500,-1500	;0
	dc.w	1500,-1500,-1500	;1
	dc.w	1500,1500,-1500	;2
	dc.w	-1500,1500,-1500	;3
	dc.w	-1500,-1500,1500	;4
	dc.w	1500,-1500,1500	;5
	dc.w	1500,1500,1500	;6
	dc.w	-1500,1500,1500	;7
	dc.w	$8000

TransObjects:	dc.w	-1500,-1500,-1500	;0
	dc.w	1500,-1500,-1500	;1
	dc.w	1500,1500,-1500	;2
	dc.w	-1500,1500,-1500	;3
	dc.w	-1500,-1500,1500	;4
	dc.w	1500,-1500,1500	;5
	dc.w	1500,1500,1500	;6
	dc.w	-1500,1500,1500	;7

	dc.w	1500,-1500,-1500	;1
	dc.w	1500,1500,-1500	;2
	dc.w	-1500,1500,-1500	;3
	dc.w	-1500,-1500,-1500	;0
	dc.w	-1500,-1500,1500	;4
	dc.w	1500,-1500,1500	;5
	dc.w	1500,1500,1500	;6
	dc.w	-1500,1500,1500	;7

	dc.w	-0,-1500,-1500	;0
	dc.w	1500,-1500,1500	;1
	dc.w	0,1500,-1500	;2
	dc.w	-1500,1500,1500	;3
	dc.w	-0,-1500,1500	;4
	dc.w	1500,-1500,-1500	;5
	dc.w	0,1500,1500	;6
	dc.w	-1500,1500,-1500	;7

	dc.w	1500,1500,-1500	;2
	dc.w	-1500,1500,-1500	;3
	dc.w	-1500,-1500,-1500	;0
	dc.w	1500,-1500,-1500	;1
	dc.w	-1500,-1500,1500	;4
	dc.w	1500,-1500,1500	;5
	dc.w	1500,1500,1500	;6
	dc.w	-1500,1500,1500	;7

	dc.w	0,0,0		;0
	dc.w	1500,-1500,-1500	;1
	dc.w	1500,1500,-1500	;2
	dc.w	-1500,1500,-1500	;3
	dc.w	-1500,-1500,1500	;4
	dc.w	1500,-1500,1500	;5
	dc.w	0,0,0	;6
	dc.w	-1500,1500,1500	;7

	dc.w	1500,1500,1500	;6
	dc.w	1500,-1500,-1500	;1
	dc.w	1500,1500,-1500	;2
	dc.w	-1500,1500,-1500	;3
	dc.w	-1500,-1500,1500	;4
	dc.w	1500,-1500,1500	;5
	dc.w	-1500,-1500,-1500	;0
	dc.w	-1500,1500,1500	;7

	dc.w	$8000

TransPointer:	dc.l	TransObjects

Screen_Clear:	dc.l	Screen1
Screen_Draw:	dc.l	Screen2
Screen_Show:	dc.l	Screen3
	dc.l	Screen4
	dc.l	Screen5
	dc.l	Screen6
	dc.l	Screen7
	IFEQ	ECS-0
	dc.l	Screen8
	dc.l	Screen9
	dc.l	Screen10
	ENDC

XCenter:	dc.w	6300
YCenter:	dc.w	0
ZCenter:	dc.w	6000

XAdd:	dc.w	0
YAdd:	dc.w	-20
ZAdd:	dc.w	0

Angles:	dc.w	0
	dc.w	(62*20)&2047
	dc.w	0
YAngle2:	dc.w	0

Story_01_Sine:	;	0,360,32,1300,0,w,1,y,n
	DC.W	$007F,$0179,$0264,$0338,$03EC,$047A,$04DC,$050D,$050D,$04DC
	DC.W	$047A,$03EC,$0338,$0264,$0179,$007F,$FF81,$FE87,$FD9C,$FCC8
	DC.W	$FC14,$FB86,$FB24,$FAF3,$FAF3,$FB24,$FB86,$FC14,$FCC8,$FD9C
	DC.W	$FE87,$FF81





;Option nº  = 1
;Min. y-val = -1.63840E+04
;Max. y-val =  1.63840E+04
;Startvalue = min
;Length     = 1024
SinTable:	dc.w	0,101,201,302,402,503,603,704,804,904,1005,1105,1205,1306,1406,1506
	dc.w	1606,1706,1806,1906,2006,2105,2205,2305,2404,2503,2603,2702,2801,2900,2999,3098
	dc.w	3196,3295,3393,3492,3590,3688,3786,3883,3981,4078,4176,4273,4370,4467,4563,4660
	dc.w	4756,4852,4948,5044,5139,5235,5330,5425,5520,5614,5708,5803,5897,5990,6084,6177
	dc.w	6270,6363,6455,6547,6639,6731,6823,6914,7005,7096,7186,7276,7366,7456,7545,7635
	dc.w	7723,7812,7900,7988,8076,8163,8250,8337,8423,8509,8595,8680,8765,8850,8935,9019
	dc.w	9102,9186,9269,9352,9434,9516,9598,9679,9760,9841,9921,10001,10080,10159,10238,10316
	dc.w	10394,10471,10549,10625,10702,10778,10853,10928,11003,11077,11151,11224,11297,11370,11442,11514
	dc.w	11585,11656,11727,11797,11866,11935,12004,12072,12140,12207,12274,12340,12406,12472,12537,12601
	dc.w	12665,12729,12792,12854,12916,12978,13039,13100,13160,13219,13279,13337,13395,13453,13510,13567
	dc.w	13623,13678,13733,13788,13842,13896,13949,14001,14053,14104,14155,14206,14256,14305,14354,14402
	dc.w	14449,14497,14543,14589,14635,14680,14724,14768,14811,14854,14896,14937,14978,15019,15059,15098
	dc.w	15137,15175,15213,15250,15286,15322,15357,15392,15426,15460,15493,15525,15557,15588,15619,15649
	dc.w	15679,15707,15736,15763,15791,15817,15843,15868,15893,15917,15941,15964,15986,16008,16029,16049
	dc.w	16069,16088,16107,16125,16143,16160,16176,16192,16207,16221,16235,16248,16261,16273,16284,16295
	dc.w	16305,16315,16324,16332,16340,16347,16353,16359,16364,16369,16373,16376,16379,16381,16383,16384
CosTable:	dc.w	16384,16384,16383,16381,16379,16376,16373,16369,16364,16359,16353,16347,16340,16332,16324,16315
	dc.w	16305,16295,16284,16273,16261,16248,16235,16221,16207,16192,16176,16160,16143,16125,16107,16088
	dc.w	16069,16049,16029,16008,15986,15964,15941,15917,15893,15868,15843,15817,15791,15763,15736,15707
	dc.w	15679,15649,15619,15588,15557,15525,15493,15460,15426,15392,15357,15322,15286,15250,15213,15175
	dc.w	15137,15098,15059,15019,14978,14937,14896,14854,14811,14768,14724,14680,14635,14589,14543,14497
	dc.w	14449,14402,14354,14305,14256,14206,14155,14104,14053,14001,13949,13896,13842,13788,13733,13678
	dc.w	13623,13567,13510,13453,13395,13337,13279,13219,13160,13100,13039,12978,12916,12854,12792,12729
	dc.w	12665,12601,12537,12472,12406,12340,12274,12207,12140,12072,12004,11935,11866,11797,11727,11656
	dc.w	11585,11514,11442,11370,11297,11224,11151,11077,11003,10928,10853,10778,10702,10625,10549,10471
	dc.w	10394,10316,10238,10159,10080,10001,9921,9841,9760,9679,9598,9516,9434,9352,9269,9186
	dc.w	9102,9019,8935,8850,8765,8680,8595,8509,8423,8337,8250,8163,8076,7988,7900,7812
	dc.w	7723,7635,7545,7456,7366,7276,7186,7096,7005,6914,6823,6731,6639,6547,6455,6363
	dc.w	6270,6177,6084,5990,5897,5803,5708,5614,5520,5425,5330,5235,5139,5044,4948,4852
	dc.w	4756,4660,4563,4467,4370,4273,4176,4078,3981,3883,3786,3688,3590,3492,3393,3295
	dc.w	3196,3098,2999,2900,2801,2702,2603,2503,2404,2305,2205,2105,2006,1906,1806,1706
	dc.w	1606,1506,1406,1306,1205,1105,1005,904,804,704,603,503,402,302,201,101
	dc.w	0,-101,-201,-302,-402,-503,-603,-703,-804,-904,-1005,-1105,-1205,-1306,-1406,-1506
	dc.w	-1606,-1706,-1806,-1906,-2006,-2105,-2205,-2305,-2404,-2503,-2603,-2702,-2801,-2900,-2999,-3098
	dc.w	-3196,-3295,-3393,-3492,-3590,-3688,-3786,-3883,-3981,-4078,-4176,-4273,-4370,-4467,-4563,-4660
	dc.w	-4756,-4852,-4948,-5044,-5139,-5235,-5330,-5425,-5520,-5614,-5708,-5803,-5897,-5990,-6084,-6177
	dc.w	-6270,-6363,-6455,-6547,-6639,-6731,-6823,-6914,-7005,-7096,-7186,-7276,-7366,-7456,-7545,-7635
	dc.w	-7723,-7812,-7900,-7988,-8076,-8163,-8250,-8337,-8423,-8509,-8595,-8680,-8765,-8850,-8935,-9019
	dc.w	-9102,-9186,-9269,-9352,-9434,-9516,-9598,-9679,-9760,-9840,-9921,-10001,-10080,-10159,-10238,-10316
	dc.w	-10394,-10471,-10549,-10625,-10702,-10778,-10853,-10928,-11003,-11077,-11151,-11224,-11297,-11370,-11442,-11514
	dc.w	-11585,-11656,-11727,-11797,-11866,-11935,-12004,-12072,-12140,-12207,-12274,-12340,-12406,-12472,-12537,-12601
	dc.w	-12665,-12729,-12792,-12854,-12916,-12978,-13039,-13100,-13160,-13219,-13279,-13337,-13395,-13453,-13510,-13567
	dc.w	-13623,-13678,-13733,-13788,-13842,-13896,-13949,-14001,-14053,-14104,-14155,-14206,-14256,-14305,-14354,-14402
	dc.w	-14449,-14497,-14543,-14589,-14635,-14680,-14724,-14768,-14811,-14854,-14896,-14937,-14978,-15019,-15059,-15098
	dc.w	-15137,-15175,-15213,-15250,-15286,-15322,-15357,-15392,-15426,-15460,-15493,-15525,-15557,-15588,-15619,-15649
	dc.w	-15679,-15707,-15736,-15763,-15791,-15817,-15843,-15868,-15893,-15917,-15941,-15964,-15986,-16008,-16029,-16049
	dc.w	-16069,-16088,-16107,-16125,-16143,-16160,-16176,-16192,-16207,-16221,-16235,-16248,-16261,-16273,-16284,-16295
	dc.w	-16305,-16315,-16324,-16332,-16340,-16347,-16353,-16359,-16364,-16369,-16373,-16376,-16379,-16381,-16383,-16384
	dc.w	-16384,-16384,-16383,-16381,-16379,-16376,-16373,-16369,-16364,-16359,-16353,-16347,-16340,-16332,-16324,-16315
	dc.w	-16305,-16295,-16284,-16273,-16261,-16248,-16235,-16221,-16207,-16192,-16176,-16160,-16143,-16125,-16107,-16088
	dc.w	-16069,-16049,-16029,-16008,-15986,-15964,-15941,-15917,-15893,-15868,-15843,-15817,-15791,-15763,-15736,-15707
	dc.w	-15679,-15649,-15619,-15588,-15557,-15525,-15493,-15460,-15426,-15392,-15357,-15322,-15286,-15250,-15213,-15175
	dc.w	-15137,-15098,-15059,-15019,-14978,-14937,-14896,-14854,-14811,-14768,-14724,-14680,-14635,-14589,-14543,-14497
	dc.w	-14449,-14402,-14354,-14305,-14256,-14206,-14155,-14104,-14053,-14001,-13949,-13896,-13842,-13788,-13733,-13678
	dc.w	-13623,-13567,-13510,-13453,-13395,-13337,-13279,-13219,-13160,-13100,-13039,-12978,-12916,-12854,-12792,-12729
	dc.w	-12665,-12601,-12537,-12472,-12406,-12340,-12274,-12207,-12140,-12072,-12004,-11935,-11866,-11797,-11727,-11656
	dc.w	-11585,-11514,-11442,-11370,-11297,-11224,-11151,-11077,-11003,-10928,-10853,-10778,-10702,-10625,-10549,-10471
	dc.w	-10394,-10316,-10238,-10159,-10080,-10001,-9921,-9841,-9760,-9679,-9598,-9516,-9434,-9352,-9269,-9186
	dc.w	-9102,-9019,-8935,-8850,-8765,-8680,-8595,-8509,-8423,-8337,-8250,-8163,-8076,-7988,-7900,-7812
	dc.w	-7723,-7635,-7545,-7456,-7366,-7277,-7186,-7096,-7005,-6914,-6823,-6731,-6639,-6547,-6455,-6363
	dc.w	-6270,-6177,-6084,-5990,-5897,-5803,-5708,-5614,-5520,-5425,-5330,-5235,-5139,-5044,-4948,-4852
	dc.w	-4756,-4660,-4563,-4467,-4370,-4273,-4176,-4078,-3981,-3883,-3786,-3688,-3590,-3492,-3393,-3295
	dc.w	-3196,-3098,-2999,-2900,-2801,-2702,-2603,-2503,-2404,-2305,-2205,-2105,-2006,-1906,-1806,-1706
	dc.w	-1606,-1506,-1406,-1306,-1205,-1105,-1005,-904,-804,-704,-603,-503,-402,-302,-201,-101
	dc.w	0,101,201,302,402,503,603,704,804,904,1005,1105,1205,1306,1406,1506
	dc.w	1606,1706,1806,1906,2006,2105,2205,2305,2404,2503,2603,2702,2801,2900,2999,3098
	dc.w	3196,3295,3393,3492,3590,3688,3786,3883,3981,4078,4176,4273,4370,4467,4563,4660
	dc.w	4756,4852,4948,5044,5139,5235,5330,5425,5520,5614,5708,5803,5897,5990,6084,6177
	dc.w	6270,6363,6455,6547,6639,6731,6823,6914,7005,7096,7186,7276,7366,7456,7545,7635
	dc.w	7723,7812,7900,7988,8076,8163,8250,8337,8423,8509,8595,8680,8765,8850,8935,9019
	dc.w	9102,9186,9269,9352,9434,9516,9598,9679,9760,9841,9921,10001,10080,10159,10238,10316
	dc.w	10394,10471,10549,10625,10702,10778,10853,10928,11003,11077,11151,11224,11297,11370,11442,11514
	dc.w	11585,11656,11727,11797,11866,11935,12004,12072,12140,12207,12274,12340,12406,12472,12537,12601
	dc.w	12665,12729,12792,12854,12916,12978,13039,13100,13160,13219,13279,13337,13395,13453,13510,13567
	dc.w	13623,13678,13733,13788,13842,13896,13949,14001,14053,14104,14155,14206,14256,14305,14354,14402
	dc.w	14449,14497,14543,14589,14635,14680,14724,14768,14811,14854,14896,14937,14978,15019,15059,15098
	dc.w	15137,15175,15213,15250,15286,15322,15357,15392,15426,15460,15493,15525,15557,15588,15619,15649
	dc.w	15679,15707,15736,15763,15791,15817,15843,15868,15893,15917,15941,15964,15986,16008,16029,16049
	dc.w	16069,16088,16107,16125,16143,16160,16176,16192,16207,16221,16235,16248,16261,16273,16284,16295
	dc.w	16305,16315,16324,16332,16340,16347,16353,16359,16364,16369,16373,16376,16379,16381,16383,16384




	SECTION	VariableTing,bss

	CNOP	0,4
_Bss2Start:
MaxRast:	ds.w	1
VBlank:	ds.b	1
	IFEQ	Track-0
IWantOut:	ds.b	1
	ELSE
	ds.b	1
IWantOut:	EQU	$80
	ENDC
CodeBuffer:	ds.b	320*8*(MatrixSize*BytesPerDot+2)
CodeMulsTab:	ds.l	320*8
_CodeBufferEnd:
VerticalBuffer:	ds.w	256*2*MatrixSize
VerticalMulsTab:	ds.l	256*2
_VerticalBufferEnd:
InterpolBuffer:	ds.w	320*MatrixSize*2
_InterpolBufferEnd:
PerspCoords:	ds.w	2*8
SideBuffer1:	ds.w	MatrixSize*2
SideBuffer2:	ds.w	MatrixSize*2
FaceBuffer1:	ds.w	MatrixSize*MatrixSize*2
FaceBuffer2:	ds.w	MatrixSize*MatrixSize*2
ColorArray:	ds.l	256
TransTrin:	ds.w	1
TransPause:	ds.w	1
Story:	ds.w	1
	CNOP	0,4
_Bss2End:




*******************************************************************************
**
**  Og den vildeste copperliste...
**
*******************************************************************************
	SECTION	MyCopper,data_c

FadeCopper:	dc.w	Bplcon0,$0201
	dc.w	$1001,$fffe
.col	dc.w	Color00,0
	dc.l	-2

Copper:	dc.w	$1001,$fffe
	dc.w	Bplcon0,$0201
	dc.w	Bplcon1,$0000
	dc.w	Bplcon2,$0024
	IFEQ	ECS-0
	dc.w	Bplcon3,$0c40
	dc.w	$01e4,$0000
	dc.w	$01fc,$0003
	ENDC

	dc.w	Spr0pth,0,Spr0ptl,0
	dc.w	Spr1pth,0,Spr1ptl,0
	dc.w	Spr2pth,0,Spr2ptl,0
	dc.w	Spr3pth,0,Spr3ptl,0
	dc.w	Spr4pth,0,Spr4ptl,0
	dc.w	Spr5pth,0,Spr5ptl,0
	dc.w	Spr6pth,0,Spr6ptl,0
	dc.w	Spr7pth,0,Spr7ptl,0

AGA_Colors:	IFEQ	ECS-1
	blk.l	32,0
	ELSE
	blk.l	33*8*2,0
	ENDC

	dc.w	$1801,$fffe
Copper_PlanePtr:	dc.w	Bpl1pth,0,Bpl1ptl,0
	dc.w	Bpl2pth,0,Bpl2ptl,0
	dc.w	Bpl3pth,0,Bpl3ptl,0
	dc.w	Bpl4pth,0,Bpl4ptl,0
	dc.w	Bpl5pth,0,Bpl5ptl,0
	IFEQ	ECS-0
	dc.w	Bpl6pth,0,Bpl6ptl,0
	dc.w	Bpl7pth,0,Bpl7ptl,0
	dc.w	Bpl8pth,0,Bpl8ptl,0
	ENDC

	IFEQ	ECS-0
	dc.w	$010c,$0011
	dc.w	Bplcon3,$0c40
	ENDC
	dc.w	Bplcon2,$0224
	dc.w	Ddfstrt,$0038
	dc.w	Ddfstop,$00d0
	dc.w	Diwstrt,$3081
	dc.w	Diwstop,$30c1
	dc.w	Bplcon1,$0000
	IFEQ	ECS-1
	dc.w	Bpl1mod,40
	dc.w	Bpl2mod,40
	ELSE
	dc.w	Bpl1mod,40-8
	dc.w	Bpl2mod,40-8
	ENDC

	dc.w	$2f01,$fffe
	IFEQ	ECS-1
	dc.w	Bplcon0,$5200
	ELSE
	dc.w	Bplcon0,$0210
	ENDC

	dc.w	$106,$c40

CirkelLine:	EQU	$91

Cirkel1:	MACRO
	IFEQ	(CirkelLine+\1)-$100
	IFEQ	ECS-0
	dc.w	$ffd9,$fffe
	ELSE
	dc.w	$ffe1,$fffe
	ENDC
	ENDC
	IF	((CirkelLine+\1)>$12f)&(ECS-1)
	dc.w	((CirkelLine+\1)&$ff)<<8!$91,$fffe
	dc.w	Color00,$103
	dc.w	((CirkelLine+\1)&$ff)<<8!$c9,$fffe
	ELSE
	dc.w	((CirkelLine+\1)&$ff)<<8!$93,$fffe
	dc.w	Color00,$103
	dc.w	((CirkelLine+\1)&$ff)<<8!$cb,$fffe
	ENDC
	dc.w	Color00,$103
	ENDM

CirkelTing:	MACRO
	Cirkel1	\1+0
	Cirkel1	\1+1
	Cirkel1	\1+2
	Cirkel1	\1+3
	Cirkel1	\1+4
	Cirkel1	\1+5
	Cirkel1	\1+6
	Cirkel1	\1+7
	ENDM

	CirkelTing	0
	CirkelTing	8
	CirkelTing	8*2
	CirkelTing	8*3
	CirkelTing	8*4
	CirkelTing	8*5
	CirkelTing	8*6
	CirkelTing	8*7
	CirkelTing	8*8
	CirkelTing	8*9
	CirkelTing	8*10
	CirkelTing	8*11
	CirkelTing	8*12
	CirkelTing	8*13
	CirkelTing	8*14
	CirkelTing	8*15
	CirkelTing	8*16
	CirkelTing	8*17
	CirkelTing	8*18
	CirkelTing	8*19
	CirkelTing	8*20
DezignJohn:


	dc.l	-2
	dc.l	-2




*******************************************************************************
**
**  Screens+Gfx
**
*******************************************************************************
	SECTION	Screens,bss_c

	CNOP	0,8
_Bss1Start:
Screen1:	ds.b	256*80
Screen2:	ds.b	256*80
Screen3:	ds.b	256*80
Screen4:	ds.b	256*80
Screen5:	ds.b	256*80
Screen6:	ds.b	256*80
Screen7:	ds.b	256*80
	IFEQ	ECS-0
Screen8:	ds.b	256*80
Screen9:	ds.b	256*80
Screen10:	ds.b	256*80
	ENDC
	CNOP	0,4
_Bss1End:




*******************************************************************************
**
**  Print info on program
**
*******************************************************************************

	PRINTT	'          '
	PRINTT	'Code buffer size:'
	PRINTV	_CodeBufferEnd-CodeBuffer
	PRINTT	'Vertical buffer size:'
	PRINTV	_VerticalBufferEnd-VerticalBuffer
	PRINTT	'Interpol buffer size:'
	PRINTV	_InterpolBufferEnd-InterpolBuffer
	PRINTT	'Buffers ialt'
	PRINTV	_InterpolBufferEnd-InterpolBuffer+_CodeBufferEnd-CodeBuffer+_VerticalBufferEnd-VerticalBuffer
	PRINTT
	PRINTT	'Bitplaner:'
	PRINTV	_Bss1End-_Bss1Start
	PRINTT
	PRINTT	'MatrixSize:'
	PRINTV	MatrixSize
	PRINTT	'Dots ialt:'
	PRINTV	MatrixSize*MatrixSize*MatrixSize


*******************************************************************************
**
**  Hardware registers
**
*******************************************************************************
Bltddat:	EQU	$000
Dmaconr:	EQU	$002
Vposr:	EQU	$004
Vhposr:	EQU	$006
Dskdatr:	EQU	$008
Joy0dat:	EQU	$00a
Joy1dat:	EQU	$00c
Clxdat:	EQU	$00e
Adkconr:	EQU	$010
Pot0dat:	EQU	$012
Pot1dat:	EQU	$014
Potgor:	EQU	$016
Serdatr:	EQU	$018
Dskbytr:	EQU	$01a
Intenar:	EQU	$01c
Intreqr:	EQU	$01e
Dskpth:	EQU	$020
Dskptl:	EQU	$022
Dsklen:	EQU	$024
Dskdat:	EQU	$026
Refptr:	EQU	$028
Vposw:	EQU	$02a
Vhposw:	EQU	$02c
Copcon:	EQU	$02e
Serdat:	EQU	$030
Serper:	EQU	$032
Potgo:	EQU	$034
Joytest:	EQU	$036
Strequ:	EQU	$038
Strvbl:	EQU	$03a
Strhor:	EQU	$03c
Strlong:	EQU	$03e
Bltcon0:	EQU	$040
Bltcon1:	EQU	$042
Bltafwm:	EQU	$044
Bltalwm:	EQU	$046
Bltcpth:	EQU	$048
Bltcptl:	EQU	$04a
Bltbpth:	EQU	$04c
Bltbptl:	EQU	$04e
Bltapth:	EQU	$050
Bltaptl:	EQU	$052
Bltdpth:	EQU	$054
Bltdptl:	EQU	$056
Bltsize:	EQU	$058
Bltsizv:	EQU	$05c
Bltsizh:	EQU	$05e
Bltcmod:	EQU	$060
Bltbmod:	EQU	$062
Bltamod:	EQU	$064
Bltdmod:	EQU	$066
Bltcdat:	EQU	$070
Bltbdat:	EQU	$072
Bltadat:	EQU	$074
Dsksync:	EQU	$07e
Cop1lch:	EQU	$080
Cop1lcl:	EQU	$082
Cop2lch:	EQU	$084
Cop2lcl:	EQU	$086
Copjmp1:	EQU	$088
Copjmp2:	EQU	$08a
Copins:	EQU	$08c
Diwstrt:	EQU	$08e
Diwstop:	EQU	$090
Ddfstrt:	EQU	$092
Ddfstop:	EQU	$094
Dmacon:	EQU	$096
Clxcon:	EQU	$98
Intena:	EQU	$09a
Intreq:	EQU	$09c
Adkcon:	EQU	$09e
Aud0dat:	EQU	$0aa
Aud1dat:	EQU	$0ba
Aud2dat:	EQU	$0ca
Aud3dat:	EQU	$0da
Aud0lch:	EQU	$0a0
Aud1lch:	EQU	$0b0
Aud2lch:	EQU	$0c0
Aud3lch:	EQU	$0d0
Aud0len:	EQU	$0a4
Aud1len:	EQU	$0b4
Aud2len:	EQU	$0c4
Aud3len:	EQU	$0d4
Aud0per:	EQU	$0a6
Aud1per:	EQU	$0b6
Aud2per:	EQU	$0c6
Aud3per:	EQU	$0d6
Aud0vol:	EQU	$0a8
Aud1vol:	EQU	$0b8
Aud2vol:	EQU	$0c8
Aud3vol:	EQU	$0d8
Aud0lcl:	EQU	$0a2
Aud1lcl:	EQU	$0b2
Aud2lcl:	EQU	$0c2
Aud3lcl:	EQU	$0d2
Bpl1pth:	EQU	$0e0
Bpl1ptl:	EQU	$0e2
Bpl2pth:	EQU	$0e4
Bpl2ptl:	EQU	$0e6
Bpl3pth:	EQU	$0e8
Bpl3ptl:	EQU	$0ea
Bpl4pth:	EQU	$0ec
Bpl4ptl:	EQU	$0ee
Bpl5pth:	EQU	$0f0
Bpl5ptl:	EQU	$0f2
Bpl6pth:	EQU	$0f4
Bpl6ptl:	EQU	$0f6
Bpl7pth:	EQU	$0f8
Bpl7ptl:	EQU	$0fa
Bpl8pth:	EQU	$0fc
Bpl8ptl:	EQU	$0fe
Bplcon0:	EQU	$100
Bplcon1:	EQU	$102
Bplcon2:	EQU	$104
Bplcon3:	EQU	$106
Bpl1mod:	EQU	$108
Bpl2mod:	EQU	$10a
Bpl1dat:	EQU	$110
Bpl2dat:	EQU	$112
Bpl3dat:	EQU	$114
Bpl4dat:	EQU	$116
Bpl5dat:	EQU	$118
Bpl6dat:	EQU	$11a
Spr0pth:	EQU	$120
Spr0ptl:	EQU	$122
Spr1pth:	EQU	$124
Spr1ptl:	EQU	$126
Spr2pth:	EQU	$128
Spr2ptl:	EQU	$12a
Spr3pth:	EQU	$12c
Spr3ptl:	EQU	$12e
Spr4pth:	EQU	$130
Spr4ptl:	EQU	$132
Spr5pth:	EQU	$134
Spr5ptl:	EQU	$136
Spr6pth:	EQU	$138
Spr6ptl:	EQU	$13a
Spr7pth:	EQU	$13c
Spr7ptl:	EQU	$13e
Spr0pos:	EQU	$140
Spr0ctl:	EQU	$142
Spr0data:	EQU	$144
Spr0datb:	EQU	$146
Spr1pos:	EQU	$148
Spr1ctl:	EQU	$14a
Spr1data:	EQU	$14c
Spr1datb:	EQU	$14e
Spr2pos:	EQU	$150
Spr2ctl:	EQU	$152
Spr2data:	EQU	$154
Spr2datb:	EQU	$156
Spr3pos:	EQU	$158
Spr3ctl:	EQU	$15a
Spr3data:	EQU	$15c
Spr3datb:	EQU	$15e
Spr4pos:	EQU	$160
Spr4ctl:	EQU	$162
Spr4data:	EQU	$164
Spr4datb:	EQU	$166
Spr5pos:	EQU	$168
Spr5ctl:	EQU	$16a
Spr5data:	EQU	$16c
Spr5datb:	EQU	$16e
Spr6pos:	EQU	$170
Spr6ctl:	EQU	$172
Spr6data:	EQU	$174
Spr6datb:	EQU	$176
Spr7pos:	EQU	$178
Spr7ctl:	EQU	$17a
Spr7data:	EQU	$17c
Spr7datb:	EQU	$17e
Color00:	EQU	$180
Color01:	EQU	$182
Color02:	EQU	$184
Color03:	EQU	$186
Color04:	EQU	$188
Color05:	EQU	$18a
Color06:	EQU	$18c
Color07:	EQU	$18e
Color08:	EQU	$190
Color09:	EQU	$192
Color10:	EQU	$194
Color11:	EQU	$196
Color12:	EQU	$198
Color13:	EQU	$19a
Color14:	EQU	$19c
Color15:	EQU	$19e
Color16:	EQU	$1a0
Color17:	EQU	$1a2
Color18:	EQU	$1a4
Color19:	EQU	$1a6
Color20:	EQU	$1a8
Color21:	EQU	$1aa
Color22:	EQU	$1ac
Color23:	EQU	$1ae
Color24:	EQU	$1b0
Color25:	EQU	$1b2
Color26:	EQU	$1b4
Color27:	EQU	$1b6
Color28:	EQU	$1b8
Color29:	EQU	$1ba
Color30:	EQU	$1bc
Color31:	EQU	$1be
_Custom:	EQU	$dff000




*******************************************************************************
**
**  Interrupt addresses
**
*******************************************************************************
Lev1Base:	EQU	$64
Lev2Base:	EQU	$68
Lev3Base:	EQU	$6c
Lev4Base:	EQU	$70
Lev5Base:	EQU	$74
Lev6Base:	EQU	$78
Lev7Base:	EQU	$7c
Trap0:	EQU	$80






