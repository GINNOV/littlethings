
	*********************************************************
	* 		Paste bob XY by Khul on 15/2/93		*
	* This will paste several bitplanes with the Cookie Cut *
	* NOTE: Barrel shifting is used to paste at x,y but the *
	* bob DOES NOT NEED AN extra 1 word wide black gap :-)	*
	*********************************************************


**--------------
** MARK, see in the clear section for a prob I have... thanks
**--------------------
		opt c-


WIDTH		=	40
HEIGHT		=	256
PLANESIZE	=	WIDTH*HEIGHT
NO_PLANES	=	3
BOBHEIGHT	=	16
BOBWIDTH	=	2		(bytes)
BOBSIZE		=	BOBWIDTH*BOBHEIGHT



BlitWait:	MACRO
.\@	btst	#14,$dff002
	bne.s	.\@
		ENDM

; Simon, there is no need to force this program into CHIP memory. Only the
;data needs to be in CHIP, not the whole program. Commented out your section
;directive and added one to the data section. This may allow proggy to run
;that little bit faster on machines fitted with FAST memory MM.

	section program,code_c
	include	"hardware.i"

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
loop:	move.l	$dff004,d0		VBlank routine
	asr.l	#8,d0
	andi.w	#$1ff,d0
	cmp.w	#257,d0
	bne.s	loop

	move.w	#$f00,$dff180
;	bsr	Clear
	move.w	#24,d0
	move.w	#50,d1
	bsr	PasteBob
	move.w	#200,d0
	move.w	#150,d1
	bsr	PasteBob
	move.w	#0,$dff180
	
	btst	#6,$bfe001
	bne.s	loop
	rts
*****************************************************************************

; Fast clear routine ???!!!
; MARK, can you help.  Surely this is the fastest way of cleaning an area
; area of memory....  if not, what is the best way??
; One method I've seen but I dislike is to clear half the screen with blitter,
; and without "BLITWAIT" it simultaeneously clears the other half by
; "MOVEM.L D0-D7/A0-A5,Screen" where the regs hold 0.
; Help me find the fastest way as I'm going to need it in some of my future
; plans!!!!!   Thanks again!

; As you are probably aware from the delay in releasing the ACC disks, I am
;very short of time at present. However, I do remember reading an article by
;Steve Marshall some time ago that said MOVEM.L to anything other than -(sp)
;was not an official Montorola instruction, so don't use it if you want your
;routines to work on ALL machines!!

; Next point to consider is the faster processors being fitted to new Amigas.
; I'm sure the 68020 is just a gap-filler and will soon be replaced by one of
;it's big brothers :-) With these processors, it would be faster to clear an
;area of memory using long word moves.

; A passing thought only: for clearing small areas of the screen, Blitter
;initialisation negates it's fast operation. Use two routines, one that uses
;68000 to clear small screen areas and a blitter clear routine running under
;interrupt. While 68000 clears small areas, blitter will clear large ones.
; Anyone else got any comments??? MM.

Clear:	moveq	#NO_PLANES-1,d7
	lea	Screen,a0
	BlitWait
	move.l	#-1,$dff044			No mask
	move.w	#0,$dff066			D mod
ClearLp:BlitWait
	move.l	a0,$dff054			D ptr
	move.w	#%0000000100000000,$dff040	BltCon0
	move.w	#(WIDTH/2)+(HEIGHT*64),$dff058	BltSize
	add.l	#PLANESIZE,a0
	dbra	d7,ClearLp
	rts
*****************************************************************************

; PasteBob x,y routine - d0=x, d1=y

PasteBob:
	lea	Ball2,a0		Source
	lea	Screen,a1		Start of Dest screen address
	lea	Ball2.MASK,a2		Mask

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
	move.l	#$ffff0000,$dff044	Mask
	move.w	#-2,$dff064		A mod
	move.w	#-2,$dff062		B mod
	move.w	#40-BOBWIDTH-2,$dff060	C mod
	move.w	#40-BOBWIDTH-2,$dff066	D mod (width-width of bob)
	andi.w	#$f000,d0
	move.w	d0,$dff042		BltCon1 - Store barrel value
	or.w	#%0000111111001010,d0
	move.w	d0,$dff040		Set Cookie cut in D0 which holds shift
	move.w	#(BOBWIDTH/2)+(64*BOBHEIGHT)+1,$dff058
*** COPY BOB ONTO DEST- Cookie Cut is D=AB+(A)C, where A=Mask, B=Source, C=Dest
	add.l	#BOBSIZE,a0		Inc source
	add.l	#PLANESIZE,a1		Inc bitmap

	dbra	d7,pb.loop
	rts
*****************************************************************************

		section		fish,data_c

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
ball2
 DC.W $0670,$0118,$068C,$095A,$1686,$2F44,$6F44,$1E85
 DC.W $4149,$16A9,$202B,$152B,$0D46,$000E,$003C,$03F0

 DC.W $0670,$0118,$000C,$061A,$4F0E,$1E07,$DE17,$8F0E
 DC.W $DE1E,$C02E,$E03C,$F57C,$3FF8,$3FF0,$1FC0,$0400

 DC.W $0180,$06E0,$1FF0,$3FE4,$3FF0,$FFF8,$3FE8,$7FF0
 DC.W $3FE0,$3FD0,$1FC0,$0A80,$0000,$0000,$0000,$0000

ball2.MASK
 DC.W $07F0,$07F8,$1FFC,$3FFE,$7FFE,$FFFF,$FFFF,$FFFF
 DC.W $FFFF,$FFFF,$FFFF,$FFFF,$3FFE,$3FFE,$1FFC,$07F0
*****************************************************************************
screen:	ds.b	PLANESIZE*NO_PLANES
