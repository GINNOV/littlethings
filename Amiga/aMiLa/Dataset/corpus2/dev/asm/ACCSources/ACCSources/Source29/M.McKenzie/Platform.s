;							Martin Mckenzie
;							2 Wardie Road
;							Easterhouse
;							Glasgow
;							G33 4NP
;
; 15/11/92	Negative Modulo's not added yet.
;		Cookie-Cut routine added.
; 19/11/92	Start of a 'jump' routine added.
; 20/11/92	Jump routine modified.
;		Labels added to source.
;
;	While jumping, note that you can still move left and right.
;	When a collision occurs, the bottom PAL area of the screen
;	will flash, and the bob's y-position will be increased.
;	Therefore, if you constantly collide, then you will constantly
;	go up. I will soon fix this so that it will nullify the move
;	instead.
;
;	While moving left or right, the collision detection is very
;	dodgy. Going up or down works fine though.
;
;	If the code runs too slowly on an un-accelerated Amiga, then
;	modify any of the delay routines that I may have used.
;
 
	include	ACC29_A:Include/hardware.i	; Hardware offset
	section	hardware,code		; Public memory
	opt	o+

	lea	$dff000,a5		; Hardware offset

	move.l	4.w,a6			; Exec base
	lea	gfxname,a1
	moveq.l	#0,d0			; Any version
	jsr	-552(a6)		; Open library
	move.l	d0,gfxbase		; Save gfx base
	beq	error
	
	jsr	-132(a6)		; Forbid

logo		equ	$2b0f		; Screen Pos. for shading
ScrWidth	equ	20		; Width in words
ScrHeight	equ	256		; Height in lines
Planes		equ	5
BobWidth	equ	32		; Width in pixels
BobHeight	equ	16		; Height in lines
BobModu		equ	(ScrWidth*16)-BobWidth	; 'D' Modulo

*****************************************************************************
;			Set-Up The Bitplane Pointers
*****************************************************************************

	move.l	#Screen,d0		; Address of screen
	move.w	d0,BPL1+2		; Load bitplane pointers
	swap	d0
	move.w	d0,BPH1+2
	swap	d0
	add.l	#(ScrWidth*2)*ScrHeight,d0	; Point to next plane
	move.w	d0,BPL2+2
	swap	d0
	move.w	d0,BPH2+2
	swap	d0
	add.l	#(ScrWidth*2)*ScrHeight,d0
	move.w	d0,BPL3+2
	swap	d0
	move.w	d0,BPH3+2
	swap	d0
	add.l	#(ScrWidth*2)*ScrHeight,d0
	move.w	d0,BPL4+2
	swap	d0
	move.w	d0,BPH4+2
	swap	d0
	add.l	#(ScrWidth*2)*ScrHeight,d0
	move.w	d0,BPL5+2
	swap	d0
	move.w	d0,BPH5+2
	swap	d0

*****************************************************************************
;			  Set-Up DMA
*****************************************************************************
DMA
.Wait1	btst	#0,VPOSR(a5)		; Wait VBL
	bne.s	.Wait1
.Wait2	cmpi.b	#55,VHPOSR(a5)
	bne.s	.Wait2
	move.w	#$20,DMACON(a5)		; Disable sprites
	move.l	#Copperlist,COP1LCH(a5)	; Insert new copper list
	move.w	#$0,COPJMP1(a5)		; Run that copper list

*****************************************************************************
;			Main Branching Routine
*****************************************************************************

	move.w	#0,Jump
	move.w	#0,Falling
	move.w	#0,Rising
	move.w	#0,LeftCounter

	move.w	#%0000111111110010,d3	; ABCD blit for bob blit
	move.w	#$0,d5			; Reset bltcon1
	move.w	#1,d1			; Counter

	lea	Bob,a0
	move.l	#2280,a6		; Starting position on screen

	bsr	GetSource
	bsr	Blitter

WaitVBL
	cmpi.b	#255,VHPOSR(a5)		; Wait VBL
	bne.s	WaitVBL

	bsr	Joy1
	bsr	CheckBgrnd
	bsr	Blitter

	btst	#7,$bfe001		; Fire button pressed ?
	bne.s	Next

	move.w	#1,Jump			; Player is jumping

Next	bsr.s	ChkJmp
	bsr.s	ChkRise
	bsr	ChkFall
	bsr	GoingDwn
	bsr.s	ChkCoord
	btst	#6,$bfe001		; Mouse Wait
	bne.s	WaitVBL

	bra	CleanUp			; Clean-up system

*****************************************************************************
;			Check jump Routine
*****************************************************************************

ChkCoord
	cmp.w	#40,a6
	bgt.s	.ok

	jsr	ClearSource
	add.w	#(ScrWidth*2),a6
	jsr	GetSource
	jsr	Blitter

.ok	rts


*****************************************************************************
;			Check jump Routine
*****************************************************************************

ChkJmp
	cmp.w	#1,Jump
	bne.s	.ok

	cmp.w	#0,Falling
	bne.s	.ok

	move.w	#0,Jump
	move.w	#(ScrWidth*2)*20,Rising	; Jump height = 20 lines

.ok	rts

*****************************************************************************
;			Check Rise Routine
*****************************************************************************

ChkRise
	cmp.w	#0,Rising
	beq.s	.ok

	sub.w	#(ScrWidth*2),Rising

.MyLoop	jsr	ClearSource
	sub.w	#(ScrWidth*2),a6	; Jump up a line
	addq.w	#1,LeftCounter
	jsr	GetSource
	jsr	Blitter

.ok	rts

*****************************************************************************
;			Check for Down Routine
*****************************************************************************

GoingDwn
	cmp.w	#19,LeftCounter
	bne.s	.ok

	move.w	#19,Falling
	move.w	#0,LeftCounter
	move.w	#0,Rising
	move.w	#0,Jump

.ok	rts

*****************************************************************************
;			Check Fall Routine
*****************************************************************************

ChkFall
	cmp.w	#0,Falling
	beq.s	.ok

	subq.w	#1,Falling

.MyLoop	jsr	ClearSource
	add.w	#(ScrWidth*2),a6
	jsr	GetSource
	jsr	Blitter

.ok	rts

*****************************************************************************
;			Joystick Routine
*****************************************************************************

Joy1
	move.b	$dff00c,d7		; Get left/up movement for joystick
	beq.s	nolu			; No l/u movement if it =0, so skip all l/u routine

	btst	#1,d7			; Bit 1 is set if it is going left or left and up
	beq.s	up			; So if its clear, test for up

	move.w	d3,d4			; Bltcon values	
	and.w	#%1111000000000000,d4	; Get rid of lower 12bits
	cmpi.w	#%0000000000000000,d4	; End of barrel shift
	beq.s	.IncDest
	sub.w	#%0001000000000000,d3	; Increment A & B shift values
	sub.w	#%0001000000000000,d5	
	bra.s	up
.IncDest
	or.w	#%1111000000000000,d3	; Insert all shift values
	or.w	#%1111000000000000,d5	; Leave the rest alone
	bsr	ClearSource		; Replace background
	subq.l	#2,a6		; Add 2 to the offset
	bsr	GetSource		; Get the background data

up	subq.b	#1,d7			; take 1 from joystick position
	btst	#1,d7			; now bit 1 is 0 if it is going up or up and left
	bne.s	nolu			; if it ain't, go to right/down movement
	bsr	ClearSource		; Replace background
	sub.l	#(ScrWidth*2),a6		; Add 2 to the offset
	bsr	GetSource		; Get the background data

nolu	move.b	$dff00d,d7		; Get right/down position
	beq.s	over			; if its 0, there's no movement so go away
	btst	#1,d7			; bit 1 is set if joystick going right or right and down
	beq.s	down			; so if its clear, test for down

	move.w	d3,d4			; Bltcon values	
	and.w	#%1111000000000000,d4	; Get rid of lower 12bits
	cmpi.w	#%1111000000000000,d4	; End of barrel shift
	beq.s	.IncDest
	add.w	#%0001000000000000,d3	; Increment A & B shift values
	add.w	#%0001000000000000,d5	
	bra.s	down
.IncDest
	and.w	#%0000111111111111,d3
	and.w	#%0000111111111111,d5	; Scrub shift values (keep rest)
	bsr	ClearSource		; Replace background
	addq.l	#2,a6			; Add 2 to the offset
	bsr	GetSource		; Get the background data

down	subq.b	#1,d7			; take 1 from r/d position
	btst	#1,d7			; is bit 1 clear
	bne.s	over			; No, then not going down, so quit
	bsr	ClearSource		; Replace background
	add.l	#(ScrWidth*2),a6	; Add 2 to the offset
	bsr	GetSource		; Get the background data

over	rts

*****************************************************************************
;			Blitter Busy Routine
*****************************************************************************

BlitterBusy
	btst		#14,DMACONR(a5)
	bne.s		BlitterBusy
	rts

*****************************************************************************
;			Blitter Routine
*****************************************************************************
; On entry, A0=Address of bob data
;           A1=Address of bob mask data
;           A2=Address of Background area
;           A3=Address of destination area (screen)

Blitter
	lea	Bob,a0			; A0=Address of bob
	lea	PlayerM,a1		; A1=Mask
	lea	Backgr,a2		; A2=Saved background data
	lea	Screen,a3		; A3=Address of screen + offset
	add.l	a6,a3
	
	moveq.l	#(Planes-1),d0		; D0=Number of bitplanes-1
.BlitLoop
	bsr.s	BlitterBusy		; Check the blitter status
	bsr.s	.BlitBob		; blit the bob	
	add.l	#((BobWidth/16)*2)*BobHeight,a0	; Get to next bob plane
	add.l	#((BobWidth/16)*2)*BobHeight,a2	; Get to next saved data plane
	add.l	#(ScrWidth*2)*ScrHeight,a3	; Get to next screen plane
	dbra	d0,.BlitLoop		; Keep blitting them planes!
	rts				; And return

.BlitBob
	move.l	a0,BLTAPTH(a5)		; A=bob data
	move.l	a1,BLTBPTH(a5)		; B=Mask data
	move.l	a2,BLTCPTH(a5)		; C=Saved background data
	move.l	a3,BLTDPTH(a5)		; D=Screen
	move.w	#$0,BLTAMOD(a5)		; Clear A's modulo
	move.w	#$0,BLTBMOD(a5)		; Clear B's modulo
	move.w	#$0,BLTCMOD(a5)		; clear C's modulo
	move.w	#BobModu/8,BLTDMOD(a5)	; D modulo=36
	move.w	#$ffff,BLTAFWM(a5)	; no mask
	move.w	#$ffff,BLTALWM(a5)	; no mask
	move.w	d3,BLTCON0(a5) 		; A shift & minterm
	move.w	d5,BLTCON1(a5) 		; B shift
	move.w	#%0000010000000010,BLTSIZE(a5)	; A 16*32 pixel blit
	rts				; Else return

*****************************************************************************
;			Save Background
*****************************************************************************
; Copy the destination area into a safe place

GetSource
	lea	Screen,a0		; A0=Address of screen + offset
	add.l	a6,a0			; Offset
	lea	Backgr,a1		; Address of destination

	moveq.l	#(Planes-1),d0		; D0=number of bitplanes -1
.BlitLoop
	bsr	BlitterBusy		; Check blitter status
	bsr.s	.BlitBob		; Blit the bob
	add.l	#(ScrWidth*2)*ScrHeight,a0	; Get to next screen plane
	add.l	#((BobWidth/16)*2)*BobHeight,a1
	dbra	d0,.BlitLoop		; Keep blitting them planes!	
	rts				; And return

.BlitBob
	move.l	a0,BLTAPTH(a5) 		; A=Screen
	move.l	a1,BLTDPTH(a5)		; D=Memory to hold data
	move.w	#BobModu/8,BLTAMOD(a5)		; A's modulo=20
	move.w	#$0,BLTDMOD(a5)		; D's modulo=0
	move.w	#$ffff,BLTAFWM(a5)	; no mask
	move.w	#$ffff,BLTALWM(a5)	; no mask
	move.w	#%0000100111110000,BLTCON0(a5) ; A-D blit
	move.w	$0.w,BLTCON1(a5)		; B's barrel shift
	move.w	#%0000010000000010,BLTSIZE(a5)	; A 16*32 pixel blit
	rts

*****************************************************************************
;			Restore Background
*****************************************************************************
; Clear the bob from screen by replacing background

ClearSource
	lea	Backgr,a0		; Address of Source
	lea	Screen,a1		; A1=Address of screen + offset
	add.l	a6,a1

	moveq.l	#(Planes-1),d0		; D0=number of bitplanes -1
.BlitLoop
	bsr	BlitterBusy		; Check blitter status
	bsr.s	.BlitBob		; Blit the bob
	add.l	#(ScrWidth*2)*ScrHeight,a1	; Get to next screen plane
	add.l	#((BobWidth/16)*2)*BobHeight,a0
	dbra	d0,.BlitLoop		; Keep blitting them planes!	
	rts				; And return

.BlitBob
	move.l	a0,BLTAPTH(a5) 		; A=Source
	move.l	a1,BLTDPTH(a5)		; D=screen
	move.w	#0,BLTAMOD(a5)		; A's modulo=20
	move.w	#BobModu/8,BLTDMOD(a5)		; D's modulo=0
	move.w	#$ffff,BLTAFWM(a5)	; no mask
	move.w	#$ffff,BLTALWM(a5)	; no mask
	move.w	#%0000100111110000,BLTCON0(a5) ;A-D blit
	move.w	#$0,BLTCON1(a5)
	move.w	#%0000010000000010,BLTSIZE(a5)	; A 16*32 pixel blit
	rts

*********************************************************
;	Check for background collision			;
*********************************************************
; To check move, Bob mask will be blitted into collision plane

CheckBgrnd
	move.l		#ColScr,a4		; Address of collision screen
	add.l		a6,a4			; Add bob offset to it.

	bsr		BlitterBusy

	move.l		#PlayerM,BLTAPTH(a5)	; Bob mask
	move.l		a4,BLTCPTH(a5)		; Collision plane
	move.w		#0,BLTAMOD(a5)
	move.w		#BobModu/8,BLTCMOD(a5)
	move.l		#$ffffffff,BLTAFWM(a5)	; Blitter mask

	move.l		#$0aa00000,d6		; No scroll, Use A+C
	add.l		d5,d6			; Add scroll value
	move.l		d6,BLTCON0(a5)

	move.w		#%0000010000000010,BLTSIZE(a5)	; A 16*32 pixel blit

; We must wait for blitter to finish before testing BZERO flag in DMACONR.

	bsr		BlitterBusy

; Now see if result of operation was zero, if not a collision must have
;occurred. Since this is a background test, the move will be nullified.

	btst		#13,DMACONR(a5)		blit zero?
	bne.s		ok			yep, ignore it

	move.w	#255,d0
cloop	move.w	d0,$180(a5)
Waitv	cmpi.b	#255,VHPOSR(a5)		; Wait VBL
	bne.s	Waitv
	dbra	d0,cloop

	bsr	ClearSource		; Replace background
	sub.l	#(ScrWidth*2),a6	; Add 1 line to offset
	bsr	GetSource		; Get the background data

ok	rts

*****************************************************************************
;			       Clean Up
*****************************************************************************

CleanUp
	move.w	#$83e0,DMACON(a5)	; Enable sprite dma
	move.l	gfxbase,a1		; A1=Address of gfx lib
	move.l	38(a1),COP1LCH(a5)	; Load sys copper list
	move.w	#$0,COPJMP1(a5)		; Run sys copper list
	move.l	4.w,a6			; Exec base
	move.l	gfxbase,a1
	jsr	-408(a6)		; Close library
	jsr	-138(a6)		; Permit
	moveq.l	#0,d0			; Keep CLI happy
error	rts				; Bye Bye

*****************************************************************************
;			Copper List
*****************************************************************************

	section	copper,data_c		; Chip data
Copperlist
	dc.w	DIWSTRT,$2c81		; window start	
	dc.w	DIWSTOP,$2cc1		; window stop
	dc.w	DDFSTRT,$38		; data fetch start
	dc.w	DDFSTOP,$d0		; data fetch stop
	dc.w	BPLCON0,%0101001000000000 ; 5 bitplanes
	dc.w	BPLCON1,$0		; Clear scroll register
	dc.w	BPLCON2,$0		; Clear priority register
	dc.w	BPL1MOD,$0		; No modulo (odd)
	dc.w	BPL2MOD,$0		; No modulo (even)
; Bitplane pointers
BPH1	dc.w	BPL1PTH,$0	
BPL1	dc.w	BPL1PTL,$0
BPH2	dc.w	BPL2PTH,$0	
BPL2	dc.w	BPL2PTL,$0
BPH3	dc.w	BPL3PTH,$0	
BPL3	dc.w	BPL3PTL,$0
BPH4	dc.w	BPL4PTH,$0	
BPL4	dc.w	BPL4PTL,$0
BPH5	dc.w	BPL5PTH,$0	
BPL5	dc.w	BPL5PTL,$0
; Colours
	dc.w $0180,$0000,$0182,$0AAA
	dc.w $0184,$0E00,$0186,$0A00
	dc.w $0188,$0D60,$018A,$0FE5
	dc.w $018C,$08F0,$018E,$0080
	dc.w $0190,$00B6,$0192,$00DD
	dc.w $0194,$00AF,$0196,$007C
	dc.w $0198,$000F,$019A,$070F
	dc.w $019C,$0C0E,$019E,$0C08
	dc.w $01A0,$0620,$01A2,$0E52
	dc.w $01A4,$0A52,$01A6,$0FCA
	dc.w $01A8,$0333,$01AA,$0444
	dc.w $01AC,$0555,$01AE,$0666
	dc.w $01B0,$0777,$01B2,$0888
	dc.w $01B4,$0999,$01B6,$0AAA
	dc.w $01B8,$0CCC,$01BA,$0DDD
	dc.w $01BC,$0EEE,$01BE,$0FFF
	

bars0	dc.w	(logo),$FFFE
	dc.w	$0180,$0001
	dc.w	(logo+$0400),$FFFE
	dc.w	$0180,$0003
	dc.w	(logo+$0800),$FFFE
	dc.w	$0180,$0005
	dc.w	(logo+$0c00),$FFFE
	dc.w	$0180,$0007
	dc.w	(logo+$1000),$FFFE
	dc.w	$0180,$0009
	dc.w	(logo+$1400),$FFFE
	dc.w	$0180,$000b
	dc.w	(logo+$1800),$FFFE
	dc.w	$0180,$000d
	dc.w	(logo+$1c00),$FFFE		
	dc.w	$0180,$000f
	dc.w	$0180,$0

	dc.w	$ffff,$fffe		; Wait

*****************************************************************************
;			     Variables
*****************************************************************************

	section	variables,data		; Public
gfxname	dc.b	'graphics.library',0
	even
gfxbase	dc.l	0			; Space for gfx base address

;PlayerX		dc.w		1
;PlayerY		dc.w		1
;PlayerOff	dc.w		1
;NewX		dc.w		1
;NewY		dc.w		1
Backgr		dc.w		(BobWidth/2)*BobHeight*Planes
Jump		dc.w		1
Falling		dc.w		1
Rising		dc.w		1
LeftCounter	dc.w		1

*************************
* Chip Data & Variables *
*************************

	section	gfxstuff,data_c
Screen	incbin	GFX/BackScreen2.raw	; You see this Screen data
ColScr	incbin	Gfx/BackMask2.raw	; Amiga see's this Screen data

Bob	incbin	Gfx/Bob32*16*5.raw	; 32 wide by 16 high!
PlayerM	incbin	Gfx/Bob32*16.mask	; Player Mask

