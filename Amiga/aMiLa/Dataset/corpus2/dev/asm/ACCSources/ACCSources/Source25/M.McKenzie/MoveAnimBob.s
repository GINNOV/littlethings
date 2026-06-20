;							Martin Mckenzie
;							2 Wardie Road
;							Easterhouse
;							Glasgow
;							G33 4NP
;
; This program will move a ten frame animated bob accross
; the screen. Note the speed of the legs!!!
; I know that the method I used here for barrel shifting is rather
; untidy, but it works.

; NOTE: Have added small conditional to code to slow legs down a bit. This
;can be switched on by assembling with MMS = 1. MM

MMS	equ	0			; set to 1 to slow down anim!

	section	hardware,code		; Public memory
	opt	c- d+
	include	source:include/hardware.i		; Hardware offset

	lea	$dff000,a5		; Hardware offset

	move.l	4,a6			; Exec base
	lea	gfxname,a1
	moveq.l	#0,d0			; Any version
	jsr	-552(a6)		; Open library
	move.l	d0,gfxbase		; Save gfx base
	beq	error
	
	jsr	-132(a6)		; Forbid

*****************************************************************************
;			Set-Up The Bitplane Pointers
*****************************************************************************
	move.l	#Screen,d0		; Address of screen
	move.w	d0,bpl1+2		; Load bitplane pointers
	swap	d0
	move.w	d0,bph1+2
	swap	d0
	add.l	#256*40,d0		; Get to next bitplane
	move.w	d0,bpl2+2
	swap	d0
	move.w	d0,bph2+2
	swap	d0
	add.l	#256*40,d0
	move.w	d0,bpl3+2
	swap	d0
	move.w	d0,bph3+2
	swap	d0
	add.l	#256*40,d0
	move.w	d0,bpl4+2
	swap	d0
	move.w	d0,bph4+2
	swap	d0

*****************************************************************************
;			  Set-Up DMA
*****************************************************************************
DMA
.Wait1	btst	#0,vposr(a5)		; Wait VBL
	bne	.Wait1
.Wait2	cmpi.b	#55,vhposr(a5)
	bne	.Wait2
	move.w	#$20,dmacon(a5)		; Disable sprites
	move.l	#Copperlist,cop1lch(a5)	; Insert new copper list
	move.w	#$0,copjmp1(a5)		; Run that copper list

*****************************************************************************
;			Main Branching Routine
*****************************************************************************

	ifne	MMS
	move.l	#8,MarksCounter		set a frame update rate
	endc

	move.w	#1,d1			; Anim Frame Counter
	move.w	#1,d5			; Barrel Shifter Counter
	move.w	#2544,d6		; bltcon0 value
	lea	frame1,a0		; Frame 1 address in A0
	lea	screen,a2		; Screen address in A2
WaitVBL
	cmpi.b	#255,vhposr(a5)		; Wait VBL
	bne	WaitVBL

	ifne	MMS
	subq.l	#1,MarksCounter
	bne.s	WaitVBL
	move.l	#8,MarksCounter
	endc

	bsr	joy1			; Test joystick
	bsr	tester			; Test barrel shift value
	bsr	Framer			; Check frame numbers
	bsr	blitter			; Blit the bob

	btst	#6,$bfe001		; Mouse Wait
	bne	WaitVBL

	bra	CleanUp			; Clean-up system

*****************************************************************************
;			Joystick Routine
*****************************************************************************

JOY1
	move.w	$dff00c,d7
	btst	#1,d7
	bne	RIGHT
	btst	#9,d7
	bne	LEFT
	move.w	d7,d2
	lsr.w	#1,d2
	eor.w	d7,d2
	btst	#0,d2
	bne	DOWN
	btst	#8,d2
	bne	UP
	rts
up
	sub.w	#40,a2			; Move bob up one line
	rts
down
	add.w	#40,a2			; Move bob down one line
	rts
right
	add.w	#6,a0			; Next frame
	addq.b	#1,d5
	add	#4096,d6		; Increase Barrel Shifter value
	addq.b	#1,d1			; Increase Frame counter
	rts
left
	sub.w	#6,a0			; Previous frame
	subq.b	#1,d5
	sub	#4096,d6		; Decrease Barrel Shifter value
	subq.b	#1,d1			; Increase Frame counter
	rts

*****************************************************************************
;			Tester Routine
*****************************************************************************
; This routine checks the barrel shift value for the blitter which is
; held in D5.

tester	cmp.b	#16,d5
	bgt	fix_it
	cmp.b	#1,d5
	blt	fix_it2
	rts

fix_it	add.w	#2,a2			; Move bob right by 1 word
	move.w	#2544,d6		; Reset barrel shifter
	move.w	#1,d5
	rts

fix_it2	sub.w	#2,a2			; Move bob left by 1 word
	move.w	#63984,d6		; Set barel shifter to Max.
	move.w	#16,d5
	rts

*****************************************************************************
;			Frame Routine
*****************************************************************************
; This routine makes sure that only frames 1 > 10 get displayed
; ( because frames <0 or >10 do not exist!)
Framer	cmp.b	#10,d1			; Is it > frame 10
	bgt	last			; Yes, fix it
	cmp.b	#1,d1			; Is it < frame 1
	blt	first			; Yes,fix it
	rts

last	move.w	#1,d1			; Reset frame to first
	move.l	#frame1,a0		; Get address of frame 1
	rts

first	move.w	#10,d1			; Reset frame to last
	move.l	#frame1,a0		; Get address of last
	add.w	#54,a0
	rts

*****************************************************************************
;			Blitter Routine
*****************************************************************************
; On entry, A0=Address of source data
;           A2=Address of destination area (screen)

blitter	move.l	#3,d3			; No. of bpl's -1
	move.l	a0,a3			; Save A0
	move.l	a2,a4			; Save A2
blt_loop
	bsr	bltbusy			; Test blitter busy
	bsr	blit_chars		; Blit the character
	add.l	#256*40,a2		; Get next screen plane
	add.w	#3240,a0		; Get next BOB plane
	dbra	d3,blt_loop		; 
	move.l	a3,a0			; Restore A0
	move.l	a4,a2			; Restore A2
	rts

bltbusy	btst	#14,dmaconr(a5)		; Is blitter working?
	bne	bltbusy
	rts

blit_chars
	move.l	a0,d0			; Address of source data
	move.w	d0,bltaptl(a5)		; Load source pointers
	swap	d0
	move.w	d0,bltapth(a5)

	move.l	a2,d0			; Address of screen
	move.w	d0,bltdptl(a5)		; Load destination pointers
	swap	d0
	move.w	d0,bltdpth(a5)

	move.w	#54,bltamod(a5)		; Source modulo
	move.w	#34,bltdmod(a5)		; Destination modulo
	move.w	#$ffff,bltafwm(a5)	; No mask
	move.w	#$ffff,bltalwm(a5)	; No mask
	move.w	d6,bltcon0(a5)		;straight A>D blit
	clr.w	bltcon1(a5)
	move.w	#%0000110110000011,bltsize(a5)	; A 54*48 pixel blit

	rts

*****************************************************************************
;			       Clean Up
*****************************************************************************
CleanUp
Wait1	btst	#0,vposr(a5)		; Wait VBL
	bne	Wait1
Wait2	cmpi.b	#55,vhposr(a5)
	bne	Wait2
	move.w	#$83e0,dmacon(a5)	; Enable sprite dma
	move.l	gfxbase,a1		; A1=Address of gfx lib
	move.l	38(a1),cop1lch(a5)	; Load sys copper list
	move.w	#$0,copjmp1(a5)		; Run sys copper list
	move.l	4,a6			; Exec base
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
	dc.w	diwstrt,$2c81		; window start	
	dc.w	diwstop,$2cc1		; window stop
	dc.w	ddfstrt,$38		; data fetch start
	dc.w	ddfstop,$d0		; data fect stop
	dc.w	bplcon0,%0100001000000000 ; 4 bitplanes
	dc.w	bplcon1,$0		; Clear scroll register
	dc.w	bplcon2,$0		; Clear priority register
	dc.w	bpl1mod,$0		; No modulo (odd)
	dc.w	bpl2mod,$0		; No modulo (even)

bph1	dc.w	bpl1pth,$0		; Bitplane pointers
bpl1	dc.w	bpl1ptl,$0
bph2	dc.w	bpl2pth,$0
bpl2	dc.w	bpl2ptl,$0
bph3	dc.w	bpl3pth,$0
bpl3	dc.w	bpl3ptl,$0
bph4	dc.w	bpl4pth,$0
bpl4	dc.w	bpl4ptl,$0
; Colours
	dc.w	$0180,$0000,$0182,$0BAF,$0184,$072C,$0186,$0306
	dc.w	$0188,$0EBA,$018A,$0D64,$018C,$0622,$018E,$00A0
	dc.w	$0190,$0FFF,$0192,$0306,$0194,$0EBA,$0196,$0D64
	dc.w	$0198,$0622,$019A,$0BAF,$019C,$072C,$019E,$000A

	dc.w	$ffff,$fffe		; Wait

*****************************************************************************
;			     Variables
*****************************************************************************
	section	variables,data		; Public
gfxname	dc.b	'graphics.library',0
	even
gfxbase	dc.l	0			; Space for gfx base address

MarksCounter	dc.l	0

*************************
* Chip Data & Variables *
*************************
	section	gfxstuff,data_c
screen	dcb.b	256*40*4,0		; Screen data
frame1	incbin	Source:M.McKenzie/bitmaps/steps2.raw		; Animation frames

