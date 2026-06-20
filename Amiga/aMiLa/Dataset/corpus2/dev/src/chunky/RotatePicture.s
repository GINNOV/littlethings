
; Chunky copper rotation example. (c) 1994 Ranulf Doswell.
; This demo produces a 107*86 resolution 4096 colour chunky display, running
; at 25 fps on an unexpanded 1200. I would like to see it on a fast ram amiga...

; Or 75*72 resolution at 50fps!!!

; The demo needs a 256*256*12 bit picture file called pic to assemble.
; This is basically an $xRGB quad for each pixel, stored in sequential
; (planar) format

; Write me at: Ranulf Doswell,
;		1 Ayr Street, Lancaster, Lancashire, LA1 3DT, England

; My chunky copper display code. Idea based on COPASM.A by Patrick van Logchem

HPIXELS			equ	75	107
VPIXELS			equ	72	86
OFFSET_NEXT_LINE	equ	4*(2+HPIXELS+((HPIXELS/32)+1))
LINES			equ	3	must be 3 else looks distorted
ANGLE_SPEED		equ	27
ZOOM_SPEED		equ	11

;at 50fps, can run at up to 75*72

;max for 2 lines - HPIXELS=89
;maximum for _smooth_ scrolling is 118x86,128x79,89x114 (for old scrolling stuff)

		include	exec/exec_lib.i
		include	libraries/mathffp_lib.i
		include	libraries/mathtrans_lib.i
		include	hardware/custom.i

		bsr	MakeSinTable
		incbin	source:startup.bin	based on howtocode 7
		incbin	GetControl		since 1.3 days... erm.

;someday I'll mix my two startup things to make a coherent single interface
;that does everything ;-)
;
; source:startup.bin handles loadview() etc to ensure that works with multisyncs
; getcontrol restores system copper, dma and int masks to defualt settings

		lea	$dff000,a6
		move.w	#$7fff,intena(a6)	disable all interrupts...

		bsr	InitCopper

		move.l	PixelTable+8,cop1lc(a6)
		move.w	#0,copjmp1(a6)

wait		btst	#50,$dff016
		beq.s	wait

		move.w	angle,d0
		move.w	size,d1
		bsr	TranslateBuffer

		add.w	#ANGLE_SPEED,angle
		add.w	#ZOOM_SPEED,size

		bsr	SwapBuffers

		btst	#6,$bfe001
		bne.s	wait
		rts
		
angle		dc.w	0
size		dc.w	3192
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
		move.l	#$01dc0020,(a0)+	; beamcon0= $0020 PAL settings

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

TranslateBuffer		;d0=angle,d1=zoom factor

		movem.l	d2/d4-d7/a2-a5,-(a7)

		lea	SinBuffer,a1
		and.w	#4095,d0
		move.w	(a1,d0.w*2),d5	D5=16384 sin ø
		add.w	#1024,d0
		move.w	(a1,d0.w*2),d4	D4=16384 cos ø

		and.w	#4095,d1
		move.w	(a1,d1.w*2),d1	D1=16384 sin zoom

	;	asr.w	#6,d1		choice of lines-determines how far
	;	add.w	#256+32,d1	out the zoom can go.
		asr.w	#4,d1
		add.w	#1030,d1

		muls	d1,d4
		muls	d1,d5		multiply by scale factor (zoom)

		asr.l	#8,d4
		asr.l	#6,d4
		asr.l	#8,d5
		asr.l	#6,d5		get to range. 1.0->256 at zoom 1:1

; / addtopx	addx	\ _ / cos ø	-sin ø	\ _ / Ix Jx \
; \ addtopy	addy	/ - \ sin ø	cos ø	/ - \ Iy Jy /

		move.w	#-VPIXELS/2,d6
		muls	d4,d6
		move.w	#-HPIXELS/2,d7
		muls	d5,d7
		add.l	d7,d6
		move.w	d6,a3

		move.w	#-VPIXELS/2,d6
		muls	d5,d6
		move.w	#HPIXELS/2,d7
		muls	d4,d7
		add.l	d7,d6			do rotated offset to centre of
		move.w	d6,a4			the screen

		add.w	#XOFFSET*256+128,a3	x coord of centre
		add.w	#YOFFSET*256+128,a4	y coord

		lea	PictureBuffer,a0
		move.l	PixelTable,a1		a0=buffer to read

		move.w	#OFFSET_NEXT_LINE,d3	offset between copper lines
		moveq.w	#HPIXELS-1,d0		width (# copper pixels)

		moveq	#0,d2			so we can use unisgned addressing

;this is the important loop of the demo. It (easily) fits in the cache as it
;is only about 38 bytes long. Note that we now only use integer addition and
;subtraction, as multiplications take _ages_

.horizloop	moveq.w	#VPIXELS-1,d1
		move.l	(a1)+,a2		get next horizontal address

		move.w	a3,d6
		move.w	a4,d7			get topx,topy
		add.w	d5,a3
		sub.w	d4,a4			change topx,topy for next horiz

.vertloop		;	store pixel (d6>>8,d7>>8) to (a2)
		move.w	d6,d2
		ror.w	#8,d7
		move.b	d7,d2
		rol.w	#8,d7			D2=offset of this pixel

		add.w	d4,d6
		add.w	d5,d7			next pixel vertically
		
		move.w	(a0,d2.l*2),(a2)	copy the colour
		add.w	d3,a2			next vertical copper pixel
		dbf	d1,.vertloop
		dbf	d0,.horizloop

		movem.l	(a7)+,d2/d4-d7/a2-a5
		rts

ANGLE_CONSTANT	equ	$C90FDB37	2*pi/32768/512=3.7450703e-7
SIN_CONSTANT	equ	$8000004F	16384

MakeSinTable	move.l	4.w,a6
		lea	MathTrans(pc),a1
		moveq	#0,d0
		jsr	_LVOOpenLibrary(a6)
		move.l	d0,a5
		move.l	a5,d0
		beq.s	.notrans

		lea	MathFFP(pc),a1
		moveq	#0,d0
		jsr	_LVOOpenLibrary(a6)
		move.l	d0,a6
		move.l	a6,d0
		beq.s	.noffp
		
		lea	SinBuffer,a2
		moveq	#0,d2
		move.w	#4095+1024,d3

.loop		move.l	d2,d0
		jsr	_LVOSPFlt(a6)
		move.l	#ANGLE_CONSTANT,d1
		jsr	_LVOSPMul(a6)
		exg	a6,a5
		jsr	_LVOSPSin(a6)
		exg	a5,a6
		move.l	#SIN_CONSTANT,d1
		jsr	_LVOSPMul(a6)
		jsr	_LVOSPFix(a6)
		move.w	d0,(a2)+
		
		addq.w	#1,d2
		dbf	d3,.loop

		move.l	a6,a1
		move.l	4.w,a6
		jsr	_LVOCloseLibrary(a6)
.noffp		move.l	a5,a1
		jsr	_LVOCloseLibrary(a6)
.notrans	moveq	#0,d0
		rts

MathTrans	dc.b	"mathtrans.library",0
MathFFP		dc.b	"mathffp.library",0
		even
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

		section	sourcedata,data

PictureBuffer	incbin pic

XOFFSET		equ	127	31			;127
YOFFSET		equ	127	145			;127

		section	copper,bss_c

;PixelTable	dc.l	pixels_for_copper_1,pixels_for_copper_2
;		dc.l	copper_1,copper_2

PixelTable	ds.l	4
		ds.l	2*HPIXELS
CopperBuffer	ds.l	2*(VPIXELS*OFFSET_NEXT_LINE+100)

		bss
SinBuffer	ds.w	4096+1024
