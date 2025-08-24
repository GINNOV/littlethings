	SECTION	"Frantic - Unity Intro 2",CODE_C

;--------------------------------------;

WaitBlt	MACRO
	tst.b	2(a5)
.WB\@	btst	#6,2(a5)
	bne.b	.WB\@
	ENDM

;--------------------------------------;

Start	bsr.w	WrteTxt
	move.l	4.w,a6
	moveq	#0,d0
	lea	GfxBase(pc),a1
	jsr	-552(a6)
	move.l	d0,GfxBase
	move.l	d0,a6
	move.l	34(a6),OldView
	sub.l	a1,a1
	jsr	-222(a6)
	jsr	-270(a6)
	jsr	-270(a6)
	jsr	-456(a6)
	lea	$dff000,a5
	WaitBlt
	move.l	4.w,a6
	jsr	-132(a6)

	move.w	$1c(a5),d0
	or.w	#$c000,d0
	move.w	d0,IntEna

	move.w	2(a5),d0
	or.w	#$8000,d0
	move.w	d0,DMACon

	bsr.w	mt_init
	move.l	#Picture,d0
	lea	BPL1(pc),a0
	moveq	#2-1,d7
.1	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#25*(320/8),d0
	addq.l	#8,a0
	dbf	d7,.1

	move.l	#Screen1,d0
	lea	BPL2(pc),a0
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)

	move.l	#TxtScrn,d0
	lea	BPL3(pc),a0
	moveq	#2-1,d7
.2	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#200*(368/8),d0
	addq.l	#8,a0
	dbf	d7,.2

	move.l	#Frantic,d0
	lea	BPL4(pc),a0
	moveq	#2-1,d7
.3	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#7*(640/8),d0
	addq.l	#8,a0
	dbf	d7,.3

	move.w	$7c(a5),d0
	cmp.b	#$f8,d0
	bne.b	.NonAGA
	move.w	#0,$106(a5)
	move.w	#0,$1fc(a5)

.NonAGA	bsr.w	.GetVBR
	lea	$dff000,a5
	move.w	#$7fff,$9a(a5)
	move.w	#$7fff,$9c(a5)
	move.l	$6c(a4),OldIRQ
	move.l	#NewIRQ,$6c(a4)
	move.w	#$c020,$9a(a5)

	move.w	#$7fff,$96(a5)
	move.l  #CList,$80(a5)
	move.w	#$0000,$88(a5)
	move.w	#$83d0,$96(a5)
	move.l	#0,$144(a5)

.Mouse	btst	#6,$bfe001
	bne.b	.Mouse

	bsr.w	mt_end
	lea	$dff000,a5
	move.w	#$7fff,$9a(a5)
	move.w	#$7fff,$9c(a5)
	move.l	OldIRQ(pc),$6c(a4)
	move.w	IntEna(pc),$9a(a5)

	WaitBlt
	move.l	GfxBase(pc),a6
	move.l	OldView(pc),a1
	jsr	-222(a6)
	move.w	#$7fff,$96(a5)
	move.l	38(a6),$80(a5)
	move.w	#$0000,$88(a5)
	move.w	DMACon(pc),$96(a5)
	move.l	a6,a1
	jsr	-462(a6)
	move.l	4.w,a6
	jsr	-414(a6)
	jsr	-138(a6)
	moveq	#0,d0
	rts

.GetVBR	sub.l	a4,a4
	move.l	4.w,a6
	btst	#0,297(a6)
	beq.b	.VBR1
	lea	.VBR2(pc),a5
	jsr	-30(a6)
.VBR1	rts

.VBR2	movec	vbr,a4
	rte

;--------------------------------------;

NewIRQ	movem.l	d0-a6,-(a7)
;	btst	#2,$dff016
;	beq	Pause
	bsr.b	SwpScrn
	bsr.b	PltDots
	bsr.w	VrtFill
	bsr.w	mt_music
Pause	movem.l	(a7)+,d0-a6
;	move.w	#$00f0,$180(a5)
	move.w	#$0020,$9c(a5)
	rte

;--------------------------------------;

SwpScrn	movem.l	CurScrn,d0-d2
	move.l	d0,d3
	movem.l	d1-d3,CurScrn

	lea	BPL2(pc),a0
	move.w	d1,6(a0)
	swap	d1
	move.w	d1,2(a0)

	WaitBlt
	move.l	#$01000000,$40(a5)
	move.w	#$0000,$66(a5)
	move.l	ClrScrn(pc),$54(a5)
	move.w	#102<<6+(368/16),$58(a5)
	rts

;--------------------------------------;

PltDots	lea	YOffset(pc),a0
	lea	YOffsts(pc),a1
	move.l	WrkScrn(pc),a2
	moveq	#0,d0
	moveq	#0,d5
	moveq	#0,d6
	move.w	#368-1,d7
	move.b	(a0),d5
	move.b	1(a0),d6

.1	moveq	#0,d1
	moveq	#0,d2
	move.b	(a1,d5),d1
	move.b	(a1,d6),d2
	add.w	d2,d1
	lsr.w	#1,d1

	move.l	d1,d2
	lsl.l	#6,d1
	lsl.l	#1,d2
	sub.l	d2,d1
	lsl.l	#3,d2
	sub.l	d2,d1
;	mulu	#(368/8),d1
	lea	(a2,d1),a3

	move.l	d0,d1
	move.w	d1,d2
	not.b	d1
	lsr.w	#3,d2
	lea	(a3,d2),a3
	bset	d1,(a3)
	addq.w	#1,d0
	addq.b	#1,d5
	addq.b	#2,d6
	dbf	d7,.1
	addq.b	#2,(a0)
	addq.b	#1,1(a0)
	rts

;--------------------------------------;

VrtFill	move.l	WrkScrn(pc),a0
	lea	(368/8)(a0),a1
	move.l	#$0d3c0000,d0
	moveq	#0,d1
	moveq	#-1,d2
	move.w	#100<<6+(368/16),d3
	WaitBlt
	move.l	d0,$40(a5)
	move.l	d2,$44(a5)
	move.l	a0,$50(a5)
	move.l	a1,$4c(a5)
	move.l	a1,$54(a5)
	move.w	d1,$64(a5)
	move.w	d1,$62(a5)
	move.w	d1,$66(a5)
	move.w	d3,$58(a5)
	rts

;--------------------------------------;

WrteTxt	lea	Text(pc),a0
	lea	Font(pc),a1
	lea	TxtScrn+(4*(368/8))(pc),a2

.1	lea	TxtOffs(pc),a5
	moveq	#9-1,d6
.2	move.w	(a5)+,d4
	move.w	(a5)+,d5
	bsr.b	.4
	bmi.w	.7
	dbf	d6,.2
	addq.w	#8,TxtHorz
	addq.w	#1,TxtPntr
	bra.b	.1

.4	move.w	TxtPntr(pc),d0
	moveq	#0,d1
	move.b	(a0,d0),d1
	bne.b	.5
	move.w	#4*8,TxtHorz
	add.w	#10,TxtVert
	addq.w	#1,TxtPntr
	bra.b	.4
.5	sub.b	#32,d1
	bmi.b	.7
	lsl.w	#3,d1
	lea	(a1,d1),a3

	moveq	#0,d0
	move.w	TxtVert(pc),d0
	add.w	d5,d0
	mulu	#(368/8),d0
	lea	(a2,d0),a4

	moveq	#0,d0
	move.w	TxtHorz(pc),d0
	add.w	d4,d0
	move.l	d0,d1
	lsr.w	#3,d0
	bclr	#0,d0
	and.w	#$f,d1
	lea	(a4,d0),a4

	moveq	#8-1,d7
.6	moveq	#0,d0
	move.b	(a3)+,d0
	ror.l	#8,d0
	lsr.l	d1,d0
	or.l	d0,(a4)
	lea	(368/8)(a4),a4
	dbf	d7,.6
	moveq	#0,d0
.7	rts

;--------------------------------------;

Music	include	"DH2:UnityIntro2/ProTracker2.3A.i"

;--------------------------------------;

DMACon	dc.w	0
IntEna	dc.w	0
OldIRQ	dc.l	0
OldView	dc.l	0
GfxBase	dc.b	"graphics.library",0,0
YOffset	dc.b	0,10
CurScrn	dc.l	Screen1
WrkScrn	dc.l	Screen2
ClrScrn	dc.l	Screen3
TxtHorz	dc.w	4*8
TxtVert	dc.w	0
TxtPntr	dc.w	0
TxtOffs	dc.w	-1,200-1
	dc.w	 0,200-1
	dc.w	 1,200-1
	dc.w	-1,200
	dc.w	 0,0
	dc.w	 1,200
	dc.w	-1,200+1
	dc.w	 0,200+1
	dc.w	 1,200+1

;--------------------------------------;

CList	dc.w	$008e,$2c81,$0090,$2cc1
	dc.w	$0092,$0038,$0094,$00d0
	dc.w	$0102,$0000,$0104,$003f
	dc.w	$0108,$0000,$010a,$0000

	dc.w	$0180,$0448,$0182,$0000
	dc.w	$0184,$066a,$0186,$088c

	dc.w	$2c07,$fffe,$0100,$2200
BPL1	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$4507,$fffe,$0100,$0200

	dc.w	$5707,$fffe
	dc.w	$0180,$0448,$0182,$0448
	dc.w	$0188,$0000,$018a,$0000
	dc.w	$018c,$088c,$018e,$088c

	dc.w	$008e,$2479,$0090,$34c9
	dc.w	$0092,$0028,$0094,$00d8
	dc.w	$5807,$fffe,$0100,$3200
BPL3	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$00e8,$0000,$00ea,$0000
	dc.w	$7a07,$fffe
BPL2	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$0180,$0448,$0182,$0c26
	dc.w	$0188,$0000,$018a,$0000
	dc.w	$018c,$088c,$018e,$0f6a

	dc.w	$df07,$fffe
	dc.w	$0180,$0c26,$0182,$0c26
	dc.w	$0188,$0000,$018a,$0000
	dc.w	$018c,$0f6a,$018e,$0f6a

	dc.w	$ffe1,$fffe
	dc.w	$2007,$fffe,$0100,$0200
	dc.w	$008e,$2c81,$0090,$2cc1
	dc.w	$0092,$003c,$0094,$00d4
	dc.w	$0180,$0c26,$0182,$0000
	dc.w	$0184,$0000,$0186,$0f8c
	dc.w	$2507,$fffe,$0100,$a200
BPL4	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
	
	dc.w	$ffff,$fffe,$ffff,$fffe

;--------------------------------------;

YOffsts	dc.b	$33,$34,$35,$36,$38,$39,$3a,$3b,$3c,$3e,$3f,$40,$41,$42,$43,$45
	dc.b	$46,$47,$48,$49,$4a,$4b,$4c,$4d,$4e,$4f,$50,$51,$52,$53,$54,$55
	dc.b	$56,$57,$57,$58,$59,$5a,$5b,$5b,$5c,$5d,$5d,$5e,$5e,$5f,$5f,$60
	dc.b	$60,$61,$61,$62,$62,$62,$63,$63,$63,$63,$64,$64,$64,$64,$64,$64
	dc.b	$64,$64,$64,$64,$64,$64,$63,$63,$63,$63,$62,$62,$62,$61,$61,$60
	dc.b	$60,$5f,$5f,$5e,$5e,$5d,$5d,$5c,$5b,$5b,$5a,$59,$58,$57,$57,$56
	dc.b	$55,$54,$53,$52,$51,$50,$4f,$4e,$4d,$4c,$4b,$4a,$49,$48,$47,$46
	dc.b	$45,$43,$42,$41,$40,$3f,$3e,$3c,$3b,$3a,$39,$38,$36,$35,$34,$33
	dc.b	$31,$30,$2f,$2e,$2c,$2b,$2a,$29,$28,$26,$25,$24,$23,$22,$21,$1f
	dc.b	$1e,$1d,$1c,$1b,$1a,$19,$18,$17,$16,$15,$14,$13,$12,$11,$10,$0f
	dc.b	$0e,$0d,$0d,$0c,$0b,$0a,$09,$09,$08,$07,$07,$06,$06,$05,$05,$04
	dc.b	$04,$03,$03,$02,$02,$02,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$02,$02,$02,$03,$03,$04
	dc.b	$04,$05,$05,$06,$06,$07,$07,$08,$09,$09,$0a,$0b,$0c,$0d,$0d,$0e
	dc.b	$0f,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1a,$1b,$1c,$1d,$1e
	dc.b	$1f,$21,$22,$23,$24,$25,$26,$28,$29,$2a,$2b,$2c,$2e,$2f,$30,$31

;--------------------------------------;

Text	dc.b	"                PRESENTS",0
	dc.b	"                ||||||||",0
	dc.b	"         SHADOW OF THE BEAST VI",0
	dc.b	0
	dc.b	"       Slimy fields of green jelly",0
	dc.b	"    Little elves bouncing on my belly",0
	dc.b	"       Fire me rapidly into a wall",0
	dc.b	"  The green drops me so I can free fall",0
	dc.b	"         Don't hear me breathing",0
	dc.b	"          I'm breathing too loud",0
	dc.b	"       I can see through your eyes",0
	dc.b	"        and my soul I have found",0
	dc.b	"       Jesus is burning in my bed",0
	dc.b	"    The sky is pink, the room is red",0
	dc.b	"      Chasing the purple dotted cat",0
	dc.b	"          In my mind cause I am",0
	dc.b	"            STONED IMMACULATE",0
	dc.b	"              +649 8188230",0
	dc.b	1
	even

;--------------------------------------;

Frantic	incbin	"DH2:UnityIntro2/Frantic.raw"
Font	include	"DH2:UnityIntro2/Font.i"
	even
Picture	incbin	"DH2:UnityIntro2/Unity.raw"
Screen1	dcb.b	102*(368/8),0
Screen2	dcb.b	102*(368/8),0
Screen3	dcb.b	102*(368/8),0
TxtScrn	dcb.b	2*200*(368/8),0
mt_data	incbin	"DH2:UnityIntro2/mod.TopGlad"
	END

