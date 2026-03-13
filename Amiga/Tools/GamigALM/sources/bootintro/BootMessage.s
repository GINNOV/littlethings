;	AUTO	ws\BBStart\0\2\cc\

OpenOldLib	= -408
Forbid		= -132
Permit		= -138
InitBitmap	= -390
InitRastPort	= -198
SetAPen		= -342
Move		= -240
Text		= -60
ScrollRaster	= -396
FindResident	= -96

	move.l	4.w,a6
	move.l	$9c(a6),a3
	move.l	$32(a3),OldCopp
	bsr	Start
	move.w	#"ic",DosName
	move.l	OldCopp(pc),$32(a3)
	rts

OldCopp	dc.l	0

;---------------------------------------;
;	      BootBlock Code		;
;---------------------------------------;

BBStart	dc.b	'DOS',0
	dc.l	0,880

Start	movem.l	d0-a6,-(a7)
	jsr	Forbid(a6)
	lea	$dff000,a5

	moveq	#0,d0
	moveq	#-1,d0
	lea	$70000,a0
	move.l	a0,a3
	move.l	a0,a4
	add.l	#$400,a4
ClrMem	move.b	#0,(a0)+
	dbf	d0,ClrMem

	lea	SinTble(pc),a0
	lea	SinePnt(pc),a1
	move.l	a0,(a1)

	lea	GfxName(pc),a1
	jsr	OpenOldLib(a6)
	move.l	d0,a6

	lea	CList(pc),a1
	move.l	a1,$32(a6)
	move.w	#$8300,$96(a5)

	move.l	a3,a0
	moveq	#1,d0
	move.l	#652,d1
	moveq	#10,d2
	jsr	InitBitmap(a6)

	move.l	a4,8(a3)
	move.l	a3,a1
	add.l	#$100,a1
	jsr	InitRastPort(a6)

	move.l	a3,a1
	add.l	#$104,a1
	move.l	a3,(a1)
	add.l	#$100,a3

	moveq	#1,d0
	move.l	a3,a1
	jsr	SetAPen(a6)

NewLine	lea	ScrlTxt(pc),a1
	lea	ScrlPnt(pc),a2
	move.l	a1,(a2)

GetPos	move.l	a3,a1
	move.l	#640,d0
	moveq	#8,d1
	jsr	Move(a6)

	lea	ScrlPnt(pc),a2
	move.l	(a2),a0
	addq.l	#1,(a2)
	moveq	#1,d0
	cmp.b	#0,(a0)
	beq.b	NewLine

ScrllIt	move.l	a3,a1
	jsr	Text(a6)
	moveq	#8,d7
DoScrl	cmp.b	#$ff,6(a5)
	bne.b	DoScrl

	lea	SinePnt(pc),a0
	lea	ScrlPos(pc),a1
	move.l	(a0),a0
	move.b	(a0)+,(a1)
	cmp.b	#$ff,(a0)
	bne.b	MoveSin
	sub.l	#SineEnd-SinTble,a0
MoveSin	lea	SinePnt(pc),a1
	move.l	a0,(a1)

	move.l	a3,a1
	moveq	#1,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	move.l	#656,d4
	moveq	#10,d5
	jsr	ScrollRaster(a6)
	btst	#6,$bfe001
	beq.b	Mouse
	dbf	d7,DoScrl
	bra.b	GetPos

Mouse	lea	CList2(pc),a0
	move.l	a0,$32(a6)
	movem.l	(a7)+,d0-a6
	jsr	Permit(a6)

	lea	DosName(pc),a1
	move.w	#"do",(a1)
	jsr	FindResident(a6)
	move.l	d0,a0
	move.l	$16(a0),a0
	moveq	#0,d0
	rts

;--------------------------------------;

ScrlPnt	dc.l	0
SinePnt	dc.l	0

;--------------------------------------;

SinTble	dc.b	$90,$90,$90,$90,$90,$91,$91,$91,$92,$92
	dc.b	$93,$93,$94,$94,$95,$96,$96,$97,$98,$99
	dc.b	$9a,$9b,$9c,$9d,$9e,$9f,$a0,$a1,$a2,$a4
	dc.b	$a5,$a6,$a7,$a9,$aa,$ab,$ad,$ae,$b0,$b1
	dc.b	$b3,$b4,$b6,$b7,$b9,$ba,$bc,$bd,$bf,$c0
	dc.b	$c0,$bf,$bd,$bc,$ba,$b9,$b7,$b6,$b4,$b3
	dc.b	$b1,$b0,$ae,$ad,$ab,$aa,$a9,$a7,$a6,$a5
	dc.b	$a4,$a2,$a1,$a0,$9f,$9e,$9d,$9c,$9b,$9a
	dc.b	$99,$98,$97,$96,$96,$95,$94,$94,$93,$93
	dc.b	$92,$92,$91,$91,$91,$90,$90,$90,$90,$90
SineEnd	dc.b	$ff,$00

;--------------------------------------;

CList	dc.w	$008e,$2981,$0090,$29c1
	dc.w	$0092,$003c,$0094,$00d4
	dc.w	$0108,$0002,$010a,$0002

	dc.w	$0180,$0000,$0182,$0000
	dc.w	$0184,$0fff,$0186,$0fff

	dc.w	$8d09,$fffe,$0180,$0f22
	dc.w	$8e09,$fffe,$0180,$0422
	dc.w	$8f09,$fffe,$0180,$0622

ScrlPos	dc.w	$9009,$fffe
	dc.w	$0100,$a200,$0102,$0001
	dc.w	$00e0,$0007,$00e2,$0400
	dc.w	$00e4,$0007,$00e6,$0452

	dc.w	$cb09,$fffe,$0180,$0422
	dc.w	$cc09,$fffe,$0180,$0f22
	dc.w	$cd09,$fffe
CList2	dc.w	$0100,$0200
	dc.w	$0102,$0000,$0180,$0000
	dc.w	$ffff,$fffe

;--------------------------------------;

Idntify	dc.b	"u"
GfxName	dc.b	"graph"
DosName	dc.b	"ics.library",0
ScrlTxt	dc.b	32
SclText	dc.b	"Robster presents the Boot-Intro Designer...                  "
	dcb.b	400,0
BBEnd
