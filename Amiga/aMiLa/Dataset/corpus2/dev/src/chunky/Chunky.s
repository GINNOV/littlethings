
; My chunky copper display code. Idea based on COPASM.A by Patrick van Logchem

; This will probably cause many enforcer hits, as it reads the test graphics
; from the whole 2Mb chip range. But then I don't have enforcer ;-]

HPIXELS			equ	89
VPIXELS			equ	114
OFFSET_NEXT_LINE	equ	4*(2+HPIXELS+((HPIXELS/32)+1))
LINES			equ	2

;max for 2 lines - HPIXELS=89
;maximum for _smooth_ scrolling is 118x86,128x79,89x114

		include	hardware/custom.i
		incbin	GetControl

		lea	$dff000,a6
		move.w	#$7fff,intena(a6)

		bsr	InitCopper

		move.l	PixelTable+8,cop1lc(a6)
		move.w	#0,copjmp1(a6)

wait		btst	#10,$dff016
		beq.s	wait

		move.l	bptr,a0
		bsr	TranslateBuffer

		add.l	#2*VPIXELS,bptr

		and.l	#$1fffff,bptr
		bsr	SwapBuffers

		btst	#6,$bfe001
		bne.s	wait
		rts
		
bptr		dc.l	0
colour		dc.w	0

InitCopper	lea	CopperBuffer,a0
		lea	PixelTable,a3

		lea	16(a3),a2
		bsr	.docopper
.docopper
		move.l	a0,8(a3)
		move.l	a2,(a3)+

		move.l	#$2001fffe,(a0)+

	;	move.l	#$01800000,(a0)+	; color0  = $0000
	;	move.l	#$010c0011,(a0)+	; bplcon4 = $0011
		move.l	#$008e277b,(a0)+	; diwstrt = $2c81
		move.l	#$01007201,(a0)+	; bplcon0 = $0211
		move.l	#$01040224,(a0)+	; bplcon2 = $0224
		move.l	#$009029bb,(a0)+	; diwstop = $2cc1
		move.l	#$00920018,(a0)+	; ddfstrt = $0038
		move.l	#$009400b8,(a0)+	; ddfstop = $00d8
		move.l	#$0102ccaa,(a0)+	; bplcon1 = $0000
		move.l	#$0108ffd0,(a0)+	; bpl1mod = $ffd0 (-48)
		move.l	#$010affd0,(a0)+	; bpl2mod = $ffd0 (-48)
		move.l	#$01e42100,(a0)+	; diwhigh = $2100
		move.l	#$01fc0003,(a0)+	; fmode   = $0003

		move.l	#SpritesNull,d0
		move.w	#$120,d1
		moveq	#8-1,d2
.wipesprites	move.w	d1,(a0)+
		swap	d0
		move.w	d0,(a0)+
		swap	d0
		addq.w	#2,d1
		move.w	d1,(a0)+
		addq.w	#2,d1
		move.w	d0,(a0)+
		dbf	d2,.wipesprites		store 8 copies of blank sprite

		move.l	#Bitplanes,d0
		move.w	#$e0,d1
		moveq	#7-1,d2			7 bitplanes
		moveq	#40,d3			length of a plane...

		moveq	#-1,d4			flag=save colour pointer

.bploop		move.w	d1,(a0)+
		swap	d0
		move.w	d0,(a0)+
		swap	d0
		addq.w	#2,d1
		move.w	d1,(a0)+
		addq.w	#2,d1
		move.w	d0,(a0)+
		add.l	d3,d0
		dbf	d2,.bploop		store the bitplane pointers

		move.l	#$01068c60,d0		select bank instruc
		move.l	#$2407fffe,d1		wait line instruction
		move.l	#$010c0011,d2		magic the change line bit
		move.w	#$0180,d3		change colour reg
		
		move.w	#VPIXELS-1,d7		number of lines
.lineloop	move.l	d0,d5
		add.w	#$8000,d0
		move.l	d1,(a0)+		put in wait line
		add.l	#LINES<<24,d1
		move.l	d2,(a0)+		change line colour
		add.w	#$8000,d2

		move.w	#HPIXELS,d6		number of colours to do
		bra.s	.selbank
.pixelloop	move.w	d3,(a0)+		store change colour instruc

		tst.l	d4
		beq.s	.nostoretable
		move.l	a0,(a2)+		store address if on first line

.nostoretable	clr.w	(a0)+

		addq.w	#$0002,d3		next colour reg
		cmp.w	#$01c0,d3		end of bank?
		bne.s	.nextpix
.selbank	move.w	#$0180,d3		restart colours with new bank
		move.l	d5,(a0)+		select new bank
		add.w	#$2000,d5		set next bank after this
.nextpix	dbf	d6,.pixelloop

		moveq	#0,d4			so x pointers only on 1st line

		dbf	d7,.lineloop

		move.l	d1,(a0)+
		move.l	d2,(a0)+		for the last line

		move.l	#$fffffffe,(a0)+	end copper list

		rts

SwapBuffers	lea	PixelTable,a0
		movem.l	(a0),d0-d3
		exg	d0,d1
		exg	d2,d3
		movem.l	d0-d3,(a0)
		move.l	d3,cop1lc(a6)

.wait		move.l	vposr(a6),d0
		lsr.l	#8,d0
		and.w	#$1ff,d0
		cmp.w	#$1f,d0
		bne.s	.wait

		move.l	d3,cop1lc(a6)
		move.w	d3,copjmp1(a6)

		rts

TranslateBuffer	move.l	PixelTable,a1		a0=buffer to read

		move.w	#OFFSET_NEXT_LINE,d2
		move.w	#HPIXELS-1,d0		width
.horizloop	move.w	#VPIXELS-1,d1
		move.l	(a1)+,a2
.vertloop	move.w	(a0)+,(a2)
		add.w	d2,a2
		dbf	d1,.vertloop
		dbf	d0,.horizloop
		rts

		section	ChipGfx,data_c

SpritesNull	dc.l	0,0,0,0

Bitplanes	dc.l	$1c71c71c,$71c71c71,$c71c71c7
		dc.l	$1c71c71c,$71c71c71,$c71c71c7
		dc.l	$1c71c71c,$71c71c71,$c71c71c7
		dc.l	$1c71c71c

		dc.l	$03f03f03,$f03f03f0,$3f03f03f
		dc.l	$03f03f03,$f03f03f0,$3f03f03f
		dc.l	$03f03f03,$f03f03f0,$3f03f03f
		dc.l	$03f03f03

		dc.l	$000fff00,$0fff000f,$ff000fff
		dc.l	$000fff00,$0fff000f,$ff000fff
		dc.l	$000fff00,$0fff000f,$ff000fff
		dc.l	$000fff00

		dc.l	$000000ff,$ffff0000,$00ffffff
		dc.l	$000000ff,$ffff0000,$00ffffff
		dc.l	$000000ff,$ffff0000,$00ffffff
		dc.l	$000000ff

		dc.l	$00000000,$0000ffff,$ffffffff
		dc.l	$00000000,$0000ffff,$ffffffff
		dc.l	$00000000,$0000ffff,$ffffffff
		dc.l	$00000000

		dc.l	$00000000,$00000000,$00000000
		dc.l	$ffffffff,$ffffffff,$ffffffff
		dc.l	$00000000,$00000000,$00000000
		dc.l	$ffffffff

		dc.l	$00000000,$00000000,$00000000
		dc.l	$00000000,$00000000,$00000000
		dc.l	$ffffffff,$ffffffff,$ffffffff
		dc.l	$ffffffff

		section	copper,bss_c

;PixelTable	dc.l	pixels_for_copper_1,pixels_for_copper_2
;		dc.l	copper_1,copper_2

PixelTable	ds.l	4
		ds.l	2*HPIXELS
CopperBuffer	ds.l	2*(VPIXELS*OFFSET_NEXT_LINE+100)
