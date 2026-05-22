**
** A simple routine to rotate an object in 2D.
**
** Should be easy to understand as there is nothing fancy (not even a
** clear routine!!!!)
**
** Raistlin 1992
**
	include	Source:Include/hardware.i		; Hardware offset
	section	hardware,code		; Public memory
	opt	c- d+

	lea	$dff000,a5		; Hardware offset

	move.l	4,a6			; Exec base
	lea	gfxname,a1
	moveq.l	#0,d0			; Any version
	jsr	-552(a6)		; Open library
	move.l	d0,gfxbase		; Save gfx base
	beq	error
	
	jsr	-132(a6)		; Permit

*****************************************************************************
;			Set-Up The Bitplane Pointers
*****************************************************************************
	move.l	#Screen,d0		; Address of screen
	move.w	d0,bpl1+2		; Load bitplane pointers
	swap	d0
	move.w	d0,bph1+2
	swap	d0
	add.l	#256*40,d0			; Get to next bitplane
	move.w	d0,bpl2+2
	swap	d0
	move.w	d0,bph2+2
	swap	d0
	add.l	#256*40,d0
	move.w	d0,bpl3+2
	swap	d0
	move.w	d0,bph3+2

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
	moveq.l	#0,d2			; Angle
WaitVBL
	cmpi.b	#255,vhposr(a5)		; Wait VBL
	bne	WaitVBL

	move.l	#50,d0			; D0=X cord
	move.l	#50,d1			; D1=Y cord
	move.l	#50,d3
	move.l	#50,d4

;	illegal
	bsr	Rotate
;	illegal
	bsr	blitter

	btst	#6,$bfe001		; Mouse Wait
	bne	WaitVBL
	bra	CleanUp			; Clean-up system


*****************************************************************************
;			       Clean Up
*****************************************************************************
CleanUp
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
;		This routine rotates the ball in 2D
*****************************************************************************
Rotate
	add.l	#1,d2			; Increment angle
	cmpi.l	#360,d2			; Angle too big?
	blt	.Nope1
	move.l	#0,d2			; Clear d2
.nope1	lea	SineTable,a0		; A0=Address of sine table
	move.l	d2,d6			; D6=Angle
	move.l	d2,d7			; D7=Angle
	add.l	#90,d7			; Increment Anlge by 90 for cos
	cmpi.l	#360,d7			; Angle greater than 359?
	blt	.Nope2
	sub.l	#360,d7
.Nope2	lsl.l	d6
	lsl.l	d7
	move.w	(a0,d6),d6		; D6=Sine value
	move.w	(a0,d7),d7		; D7=Cos value

; D0 & D3=X
; D1 & D4=Y
	muls	d7,d0			; X.Cos(0)
	muls	d6,d1			; Y.Sin(0)
	sub.l	d1,d0			; X.Cos(0) - Y.Sin(0)
	asr.l	#7,d0
	asr.l	#7,d0
	muls	d7,d4			; Y.Cos(0)
	muls	d6,d3			; X.Sin(0)
	add.l	d4,d3			; Y.Cos(0) + X.Sin(0)
	asr.l	#7,d3
	asr.l	#7,d3
; Now blit the bob
; D0=X   D3=Y
	add.l	#160,d0			; Add 160-8 for width
	add.l	#128,d3			; Add 128-8 for height
	divu	#16,d0			; Divide X by 16
	lsl.w	d0			
	mulu	#40,d3			; Y * 40
	add.w	d0,d3
	add.l	#Screen,d3		; Add address of screen to d3
	swap	d0
	lsl.w	#8,d0
	lsl.w	#4,d0			; D0=Bltcon0 value
	move.w	d0,d1			; D1=Blcton1 value
	or.w	#%100111110000,d0	; ABCD value
	rts


blitter
	cmpi.l	#Screen,d3
	blt	Exit
	cmpi.l	#ScreenE,d3
	blt	OK
Exit	rts

OK	moveq.l	#2,d7
	move.l	#Bob,bltapth(a5)	; Source=Bob
.loop	btst	#14,dmaconr(a5)
	bne	.loop
	move.l	d3,bltdpth(a5)		; Add address of screen
	move.w	#-2,bltamod(a5)		; Bob is only 1 word
	move.w	#36,bltdmod(a5)		; 40-4
	move.w	#$ffff,bltafwm(a5)	; No mask
	move.w	#$0000,bltalwm(a5)	; Full last mask
	move.w	d0,bltcon0(a5)		
	move.w	d1,bltcon1(a5)
	move.w	#(15*64)+2,bltsize(a5)

	add.l	#256*40,d3
	dbra	d7,.loop

	rts

*****************************************************************************
;			Copper List
*****************************************************************************
	section	copper,data_c		; Chip data
Copperlist
	dc.w	diwstrt,$2c81		; window start	
	dc.w	diwstop,$2cc1		; window stop
	dc.w	ddfstrt,$38		; data fetch start
	dc.w	ddfstop,$d0		; data fect stop
	dc.w	bplcon0,%0011001000000000 ; 3 bitplanes
	dc.w	bplcon1,$0		; Clear scroll register
	dc.w	bplcon2,$0		; Clear priority register
	dc.w	bpl1mod,0		; No modulo (odd)
	dc.w	bpl2mod,0		; No modulo (even)
; Bitplane pointers
bph1	dc.w	bpl1pth,$0	
bpl1	dc.w	bpl1ptl,$0
bph2	dc.w	bpl2pth,$0
bpl2	dc.w	bpl2ptl,$0
bph3	dc.w	bpl3pth,$0
bpl3	dc.w	bpl3ptl,$0

; Colours

	dc.w	$0180,$0eca,$0182,$0000,$0184,$0039,$0186,$005b
	dc.w	$0188,$0eb0,$018a,$0ed5,$018c,$0080,$018e,$0496

	
	dc.w	$ffff,$fffe		; Wait for lufc to win something!


*****************************************************************************
;			     Variables
*****************************************************************************
	section	variables,data		; Public
gfxname	dc.b	'graphics.library',0
	even
gfxbase	dc.l	0			; Space for gfx base address

******* Sine table (Mark's)

SineTable:
	dc.w 0,286,572,857,1143,1428,1713,1997,2280
	dc.w 2563,2845,3126,3406,3686,3964,4240,4516
	dc.w 4790,5063,5334,5604,5872,6138,6402,6664
	dc.w 6924,7182,7438,7692,7943,8192,8438,8682		
	dc.w 8923,9162,9397,9630,9860,10087,10311,10531
	dc.w 10749,10963,11174,11381,11585,11786,11982,12176
	dc.w 12365,12551,12733,12911,13085,13255,13421,13583
	dc.w 13741,13894,14044,14189,14330,14466,14598,14726
	dc.w 14849,14968,15082,15191,15296,15396,15491,15582
	dc.w 15668,15749,15826,15897,15964,16026,16083,16135
	dc.w 16182,16225,16262,16294,16322,16344,16362,16374
	dc.w 16382,16384
	dc.w 16382
	dc.w 16374,16362,16344,16322,16294,16262,16225,16182
	dc.w 16135,16083,16026,15964,15897,15826,15749,15668		
	dc.w 15582,15491,15396,15296,15191,15082,14967,14849
	dc.w 14726,14598,14466,14330,14189,14044,13894,13741		
	dc.w 13583,13421,13255,13085,12911,12733,12551,12365
	dc.w 12176,11982,11786,11585,11381,11174,10963,10749
	dc.w 10531,10311,10087,9860,9630,9397,9162,8923
	dc.w 8682,8438,8192,7943,7692,7438,7182,6924
	dc.w 6664,6402,6138,5872,5604,5334,5063,4790
	dc.w 4516,4240,3964,3686,3406,3126,2845,2563
	dc.w 2280,1997,1713,1428,1143,857,572,286,0
	dc.w -286,-572,-857,-1143,-1428,-1713,-1997,-2280
	dc.w -2563,-2845,-3126,-3406,-3686,-3964,-4240,-4516
	dc.w -4790,-5063,-5334,-5604,-5872,-6138,-6402,-6664
	dc.w -6924,-7182,-7438,-7692,-7943,-8192,-8438,-8682		
	dc.w -8923,-9162,-9397,-9630,-9860,-10087,-10311,-10531
	dc.w -10749,-10963,-11174,-11381,-11585,-11786,-11982,-12176
	dc.w -12365,-12551,-12733,-12911,-13085,-13255,-13421,-13583
	dc.w -13741,-13894,-14044,-14189,-14330,-14466,-14598,-14726
	dc.w -14849,-14968,-15082,-15191,-15296,-15396,-15491,-15582
	dc.w -15668,-15749,-15826,-15897,-15964,-16026,-16083,-16135
	dc.w -16182,-16225,-16262,-16294,-16322,-16344,-16362,-16374
	dc.w -16382,-16384
	dc.w -16382
	dc.w -16374,-16362,-16344,-16322,-16294,-16262,-16225,-16182
	dc.w -16135,-16083,-16026,-15964,-15897,-15826,-15749,-15668		
	dc.w -15582,-15491,-15396,-15296,-15191,-15082,-14967,-14849
	dc.w -14726,-14598,-14466,-14330,-14189,-14044,-13894,-13741		
	dc.w -13583,-13421,-13255,-13085,-12911,-12733,-12551,-12365
	dc.w -12176,-11982,-11786,-11585,-11381,-11174,-10963,-10749
	dc.w -10531,-10311,-10087,-9860,-9630,-9397,-9162,-8923
	dc.w -8682,-8438,-8192,-7943,-7692,-7438,-7182,-6924
	dc.w -6664,-6402,-6138,-5872,-5604,-5334,-5063,-4790
	dc.w -4516,-4240,-3964,-3686,-3406,-3126,-2845,-2563
	dc.w -2280,-1997,-1713,-1428,-1143,-857,-572,-286,0


*************************
* Chip Data & Variables *
*************************
	section	gfxstuff,data_c
Screen	dcb.b	256*40*3,0
ScreenE	dcb.b	256
Bob	incbin	'Source:Raistlin/Vectorball.gfx'
