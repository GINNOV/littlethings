
	*********************************************************
	* 		Paste bob XY by Khul on 15/2/93		*
	* This will paste several bitplanes with the Cookie Cut *
	* NOTE: Barrel shifting is used to paste at x,y but the *
	* bob uses an extra 1 word wide black gap...		*
	*********************************************************

WIDTH		=	40
HEIGHT		=	200
PLANESIZE	=	WIDTH*HEIGHT
NO_PLANES	=	3
BOBHEIGHT	=	32
BOBWIDTH	=	6		(bytes)
BOBSIZE		=	BOBWIDTH*BOBHEIGHT

		opt c-

BlitWait:	MACRO
.\@	btst	#14,$dff002
	bne.s	.\@
		ENDM

	section program,code_c
	include	"source:include/hardware.i"

	bsr.b	KillSys
	bsr.b	Initialize
	bsr.w	Main
	bsr.b	RestoreSys
	rts

*************************************************************************
* "Quick Trash" routine by Khul, Feb 93					*
*************************************************************************
KillSys:lea	$dff000,a5
	move.w	#$4000,intena(a5)	Disable all interrupts
	move.w	#$01a0,dmacon(a5)	Disable DMACON
	rts
RestoreSys:
	lea	$dff000,a5
	move.l	4,a6
	move.l	156(a6),a6
	move.l	38(a6),$dff080		Get system copper
	move.w	#$8020,$96(a5)		Activate
	moveq	#0,d0
	rts
*****************************************************************************
INITIALIZE:
	move.l	#screen,d0		Set copper plane addresses
	lea	planes,a0
	moveq	#NO_PLANES-1,d1		no.of bitplanes-1
set_planes:
	move.w	d0,6(a0)		get lower
	swap 	d0
	move.w	d0,2(a0)		get higher
	swap	d0			revert the screen ad to normal
	add.l	#PLANESIZE,D0		size of screen bitplane
	add.l	#8,a0
	dbra	D1,Set_planes

	lea	$dff000,a5		New Copperlist on
        move.l 	#new,$80(a5)
	move.l	#new+1,$84(a5)
	move.w 	$88(a5),d0
	move.w	#$87f0,$96(a5)
	rts
*****************************************************************************
MAIN:
	move.w	#24,d0
	move.w	#50,d1
	bsr	PasteBob
	move.w	#0,d0
	move.w	#50,d1
	bsr	PasteBob

loop:	move.l	$dff004,d0		VBlank routine
	asr.l	#8,d0
	andi.w	#$1ff,d0
	cmp.w	#257,d0
	bne.s	loop
**^--- This is the proper way isn't it!!?  But what line SHOULD i wait for,
**257,255,256,250,272, etc... HELP!!!

	
	btst	#6,$bfe001
	bne.s	loop
	rts
*****************************************************************************
**** PasteBob x,y routine - d0=x, d1=y
PasteBob:
	lea	Ball,a0			Source
	lea	Screen,a1		Start of Dest screen address
	lea	Ball.MASK,a2		Mask

	ror.w	#4,d0			shift barrel value to correct pos
	move.w	d0,d2			d2=d0
	andi.w	#$f000,d0		keep barrel data
	andi.w	#$00ff,d2		keep data of how many words
	lsl.w	#1,d2			across and then convert to bytes
	add.w	d2,a1			X values sorted out
	muls	#40,d1			d1*screen width in bytes
	add.w	d1,a1			final dest address
	moveq	#3-1,d7			Number of bob planes

pb.loop:BlitWait	
	move.l	a2,$dff050		A ptr (Mask)
	move.l	a0,$dff04c		B ptr (source)
	move.l	a1,$dff048		C ptr (Bitmap)
	move.l	a1,$dff054		D ptr (Bitmap)
	move.l	#-1,$dff044		Mask
	move.w	#0,$dff064		A mod
	move.w	#0,$dff062		B mod
	move.w	#40-BOBWIDTH,$dff060	C mod
	move.w	#40-BOBWIDTH,$dff066	D mod (width-width of bob)
	andi.w	#$f000,d0
	move.w	d0,$dff042		BltCon1 - Store barrel value
	or.w	#%0000111111001010,d0
	move.w	d0,$dff040		Set Cookie cut in D0 which holds shift
	move.w	#3+64*BOBHEIGHT,$dff058		COPY BOB ONTO DEST
* Cookie Cut is D=AB+(A)C, where A=Mask, B=Source, C=Dest
	add.l	#BOBSIZE,a0		Inc source
	add.l	#PLANESIZE,a1		Inc bitmap

	dbra	d7,pb.loop
	rts
*****************************************************************************

		*****************************************
		*		New Copper List		*
		*****************************************

cw = $fffe
new:	dc.w	bplcon0,$3200,bplcon1,$0000
	dc.w	bpl1mod,$0000,bpl2mod,$0000
	dc.w	ddfstrt,$0038,ddfstop,$00d0
	dc.w	diwstrt,$2c81,diwstop,$f4c1
planes:	dc.w	bpl1pth,0,bpl1ptl,0
	dc.w	bpl2pth,0,bpl2ptl,0
	dc.w	bpl3pth,0,bpl3ptl,0
	dc.w	bpl4pth,0,bpl4ptl,0
	dc.w	bpl5pth,0,bpl5ptl,0
spr_ptrs:
	dc.l	$01200000,$01220000		SPR0PTH/L
	dc.l	$01240000,$01260000		SPR1PTH/L
	dc.l	$01280000,$012a0000		SPR2PTH/L
	dc.l	$012c0000,$012e0000		SPR3PTH/L
	dc.l	$01300000,$01320000		SPR4PTH/L
	dc.l	$01340000,$01360000		SPR5PTH/L
	dc.l	$01380000,$013a0000		SPR6PTH/L
	dc.l	$013c0000,$013e0000		SPR7PTH/L
	dc.w	color17,$88d,color18,$568,color19,$335

	dc.w	color00,$0
	dc.w	color01,$300
	dc.w	color02,$511
	dc.w	color03,$722
	dc.w	color04,$944
	dc.w	color05,$b66
	dc.w	color06,$d88
	dc.w	color07,$faa

NTSC:	dc.w	$ffe1,cw
	dc.w 	$ffff,cw
*****************************************************************************
ball
 DC.W $000F,$E000,0,$007F,$FC00,0,$01FF,$DF00,0,$033E,$5F80,0
 DC.W $05ED,$F880,0,$04F4,$CA00,0,$02AC,$00C0,0,$0D26,$0200,0
 DC.W $1C0E,$0010,0,$2F18,$FE64,0,$5F7B,$B6F4,0,$7F5F,$DBFC,0
 DC.W $7E79,$EFEE,0,$F6CA,$54F6,0,$E380,$801A,0,$8450,$0408,0
 DC.W $0100,$061A,0,$183D,$01E6,0,$1710,$73E4,0,$57BA,$EDB4,0
 DC.W $6EEF,$D7FC,0,$1FBF,$EFA4,0,$2F67,$30D8,0,$1114,$3810,0
 DC.W $00B8,$A040,0,$0106,$B420,0,$012D,$3600,0,$0356,$5700,0
 DC.W $01F8,$F700,0,$007F,$FC00,0,$000F,$E000,0,$0000,$0000,0

 DC.W $0000,$0000,0,$0000,$0000,0,$0000,$2000,0,$00C1,$A000,0
 DC.W $0212,$0740,0,$0B0B,$35E0,0,$1D53,$FF30,0,$3FFF,$FDF8,0
 DC.W $3FFF,$FFF8,0,$7FFF,$FFFC,0,$7FFF,$FFFC,0,$7F7F,$FFFC,0
 DC.W $7E79,$EFEE,0,$F6CA,$54F6,0,$E380,$801A,0,$0410,$0408,0
 DC.W $0000,$0000,0,$0000,$0000,0,$0000,$0000,0,$0000,$0000,0
 DC.W $1100,$0800,0,$6040,$1058,0,$1098,$CF20,0,$2EEB,$C7E8,0
 DC.W $1F67,$5FB0,0,$0FFF,$FFE0,0,$07FF,$FFC0,0,$03FF,$FF80,0
 DC.W $01FF,$FF00,0,$007F,$FC00,0,$000F,$E000,0,$0000,$0000,0

 DC.W $0000,$0000,0,$0000,$0000,0,$0000,$0000,0,$0000,$0000,0
 DC.W $0000,$0000,0,$0000,$0000,0,$0000,$0000,0,$0000,$0000,0
 DC.W $0000,$0000,0,$0000,$0000,0,$0000,$0000,0,$0080,$0000,0
 DC.W $8186,$1010,0,$0935,$AB08,0,$1C7F,$7FE4,0,$FBEF,$FBF6,0
 DC.W $FFFF,$FFFE,0,$FFFF,$FFFE,0,$FFFF,$FFFE,0,$7FFF,$FFFC,0
 DC.W $7FFF,$FFFC,0,$7FFF,$FFFC,0,$3FFF,$FFF8,0,$3FFF,$FFF8,0
 DC.W $1FFF,$FFF0,0,$0FFF,$FFE0,0,$07FF,$FFC0,0,$03FF,$FF80,0
 DC.W $01FF,$FF00,0,$007F,$FC00,0,$000F,$E000,0,$0000,$0000,0

ball.MASK
 DC.W $000F,$E000,0,$007F,$FC00,0,$01FF,$FF00,0,$03FF,$FF80,0
 DC.W $07FF,$FFC0,0,$0FFF,$FFE0,0,$1FFF,$FFF0,0,$3FFF,$FFF8,0
 DC.W $3FFF,$FFF8,0,$7FFF,$FFFC,0,$7FFF,$FFFC,0,$7FFF,$FFFC,0
 DC.W $FFFF,$FFFE,0,$FFFF,$FFFE,0,$FFFF,$FFFE,0,$FFFF,$FFFE,0
 DC.W $FFFF,$FFFE,0,$FFFF,$FFFE,0,$FFFF,$FFFE,0,$7FFF,$FFFC,0
 DC.W $7FFF,$FFFC,0,$7FFF,$FFFC,0,$3FFF,$FFF8,0,$3FFF,$FFF8,0
 DC.W $1FFF,$FFF0,0,$0FFF,$FFE0,0,$07FF,$FFC0,0,$03FF,$FF80,0
 DC.W $01FF,$FF00,0,$007F,$FC00,0,$000F,$E000,0,$0000,$0000,0
*****************************************************************************
screen:	ds.b	PLANESIZE*NO_PLANES
