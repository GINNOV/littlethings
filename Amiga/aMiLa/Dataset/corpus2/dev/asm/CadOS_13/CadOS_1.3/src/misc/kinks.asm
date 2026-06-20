; Kinks 1.0 by Kyzer/CSG
; I called it "kinks" because that's what the image looks like.
; It was previously called "fractal" but then I looked up my definition
; of "fractal" and saw it wasn't ;-P

; 640 x 512 x 256 colours : 320k ram for the screen alone!
; on my 020-14 it manages it in 299 frames = 5.98 seconds
; and it makes no difference if DMA is on or off during calculation
; size of screen and number of planes would make a huge difference.

	include	cados.asm

width	set	640
height	set	512
planes	set	8

Kinks	move	#width,d0
	move	#height,d1
	move	#planes,d2
	move	#128,d3
	move	#44,d4
	move	#0,d5
	move	#MSF_NOBORDER,d6
	jsr	_MakeScreen
	tst.l	a0
	beq	.exit
	setcop	a0
	lea	.copper(pc),a2
	move.l	a0,(a2)
	lea	.screen(pc),a2
	move.l	a1,(a2)


	dmaon	RASTER,COPPER

	lea	.colors(pc),a0
	moveq	#0,d0
	move	#256,d1
	jsr	_SetColoursRGB

	get.l	.screen,a0
;=============================	;bytes	total
	moveq	#7,d7		;2	2
	moveq	#0,d0		;2	4
.cloop	moveq	#0,d1		;2	6
.yloop	moveq	#0,d2		;2	8
	moveq	#0,d6		;2	10
.xloop	moveq	#31,d3		;2	12
	moveq	#0,d5		;2	14
.inxlop	move	d6,d4		;2	16
	asr	d7,d4		;2	18
	btst	d0,d4		;2	20
	beq.s	.nopix		;2	22
	bset	d3,d5		;2	24
.nopix	add	d1,d6		;2	26
	addq	#1,d2		;2	28
	subq	#1,d3		;2	30
	bge.s	.inxlop		;2	32
	move.l	d5,(a0)+	;2	34
	cmp.w	#width,d2	;4	38
	blt.s	.xloop		;2	40
	addq	#1,d1		;2	42
	cmp.w	#height,d1	;4	46
	blt.s	.yloop		;2	48
	addq	#1,d0		;2	50
	cmp.b	#planes-1,d0	;2	52
	ble.s	.cloop		;2	54
;=============================
; 54 bytes! quite tiny for such a cool picture, eh?
; I once did a little bootblock with this effect

;	get.l	.copper,a1
;	lea	.name(pc),a0		; yes, you CAN do this!
;	moveq	#0,d0			; great debugging technique!
;	jsr	_SaveFile		; dump RAM to disk _inside_ demos!
;	bra.s	.cont
;.name	dc.b	"ram:copperlist.bin",0
;	cnop	0,4
;.cont

.wait	btst.b	#6,$bfe001
	bne.s	.wait

	moveq	#0,d0
	move.w	#256,d1
	moveq	#3,d2
	moveq	#127,d3
	move.l	#$000000,a1
	lea	.colors(pc),a0
	lea	.vs(pc),a2
	jsr	_FadeColoursRGB

	lea	.copper(pc),a0
	move.l	(a0),d0
	jsr	_FreeMem
	lea	.screen(pc),a0
	move.l	(a0),d0
	jsr	_FreeMem

.exit	rts

.vs	vsync
	rts

.copper	dc.l	0
.screen	dc.l	0

.colors	colfade	255,255,0,0,0,255,(1<<planes)/2,1
	colfade	0,0,255,255,255,0,(1<<planes)/2,1

	dc.b	"$VER: Kinks effect by Kyzer/CSG (1.1.97)",0

