**
** Fast Blitter Line Draw
**
** Coded by Raistlin 18/01/92
**
** This routine takes under 2 raster lines
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

WaitVBL
	cmpi.b	#255,vhposr(a5)		; Wait VBL
	bne	WaitVBL
	
;	move.w	#$fff,$180(a5)		; Raster measure

	lea	Vectors,a0		; A0=Address of vectors
	moveq.l	#0,d0			; D0=Number of lines-1
	bsr	DrawLine		; Draw the line

;	move.w	#$000,$180(a5)		; Raster measure

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
;	    This Routine Draws A Line Using The Blitter
*****************************************************************************
; On entry   A0=ptr to vectors
;            A5=ptr to hardware
;            D0=Number of lines to blit-1
; Cords must be set out as:-  X1,Y1,X2,Y2  Alter offsets if different
DrawLine
	moveq.l	#0,d7			; Clear octant counter
	move.w	(a0),d1			; D1=X1
	move.w	4(a0),d2		; D1=X1
	cmp.w	d1,d2			; X1 X2 same?
	bne	.diff
	move.w	2(a0),d1		; D1=Y1
	move.w	6(a0),d2		; D1=Y2
	cmp.w	d1,d2			; X1 X2 same?
	bne	.diff			; 
	rts				; No line to draw!
; This section works out DX, DY, DS, DL & works out octant to use
.diff	move.w	(a0),d1			; D1=X1
	move.w	4(a0),d2		; D2=X2
	sub.w	d1,d2			; D2=X2-X1
	bpl	.DY			; If result is +ve branch
	neg.w	d2			; Make DX +ve
	addq.w	#4,d7			; Set bit 2
.DY	move.w	d2,d3			; D3=DX
	move.w	2(a0),d1		; D1=Y1
	move.w	6(a0),d2		; D2=Y2
	sub.w	d1,d2			; D2=Y2-Y1
	bpl	.MinMax			; Branch if result is +ve
	neg.w	d2			; Make DY +ve
	addq.w	#2,d7			; Set bit 1
.MinMax	move.w	d2,d4			; D4=DY
	cmp.w	d3,d4			; DY-DX (compare)
	bmi	.DXbig			; Branch if DX is greater
	addq.w	#1,d7			; Set bit 0
	move.w	d4,d5			; D5=DY (DL=DY)
	move.w	d3,d6			; D6=DX (DS=DX)
	bra	.Octant
.DXbig	move.w	d3,d5			; D5=DX (DL=DX)
	move.w	d4,d6			; D6=DY (DS=DY)
; This section decides wether SIGN bit of bltcon1 must be set & then inserts
; Required value into Bltcon1
.Octant	
	btst	#14,dmaconr(a5)		; Make sure blitter aint busy
	bne	.Octant
	add.w	d7,d7			; D7=D7*2 (Octant table in words!)
	lea	Octants1,a3		; A1=Address of octant table (no sign)
	move.w	d6,d1			; D1=DS
	add.w	d1,d1			; D1=2DS
	sub.w	d5,d1			; D1=2DS-DL
	bpl	.NoS			; Branch if result is +ve
	lea	Octants2,a3		; A1=Address of Signed octant table
.NoS	add.l	d7,a3			; Add offset to octant table
	move.w	(a3),bltcon1(a5)	; Insert bltcon1 value
; Now calculate bltcon0
	move.w	(a0),d1			; D1=X1
	and.w	#%1111,d1		; Keep 4LSB of X1
	ror.w	#4,d1			; Put in 4MSB of word (shift bit)
	or.w	#$BCA,d1		; OR in miniterm + channels to use
	move.w	d1,bltcon0(a5)		; Insert bltcon0 value
; Now we calculate the remaining blitter registers & draw the line
	move.w	#40,bltcmod(a5)		; Cmod=with of screen in bytes
	move.w	#40,bltdmod(a5)		; Dmod=width of screen in bytes
	moveq.l	#0,d1			; Clear D1
	move.w	(a0),d1			; D1=X1
	move.w	2(a0),d2		; D2=Y1
	divu	#8,d1			; Turn X1 into bytes
	bclr	#0,d1
	mulu	#40,d2			; Turn Y1 into bytes
	add.w	d1,d2			; Add X1 to Y1
	add.l	#Screen,d2		; Add address of screen to XY1
	move.l	d2,bltcpth(a5)		; Cpth/l=Start address of 1st pt.
	move.l	d2,bltdpth(a5)		; Dpth/l=Start address of 1st pt.
	move.w	d6,d1			; D1=DS
	add.w	d1,d1			; D1=DS*2
	move.w	d1,bltbmod(a5)		; Bmod=DS*2
	sub.w	d5,d1			; D1=DS*2-DL
	move.w	d1,bltaptl(a5)		; Aptl=DS*2-DL
	sub.w	d5,d1			; D1=DS*2-DL*2
	move.w	d1,bltamod(a5)		; Amod=DS*2-DL*2
	move.w	#$8000,bltadat(a5)	; Adat=$8000 (constant)
	move.w	#$ffff,bltbdat(a5)	; Bdat=Patter ($ffff=Solid)
	move.w	#$ffff,bltafwm(a5)	; No mask
	move.w	#$ffff,bltalwm(a5)	; No mask
	move.w	d5,d1			; D1=DL
	mulu	#64,d1			; D1=DL*64
	addq.w	#2,d1			; Width=2
	move.w	d1,bltsize(a5)		; Draw Line

;	addq.l	#8,a0			; Get to next set of cords
;	dbra	d0,DrawLine		; Draw next line
	rts				; Exit



*****************************************************************************
;			Copper List
*****************************************************************************
	section	copper,data_c		; Chip data
Copperlist
	dc.w	diwstrt,$2c81		; window start	
	dc.w	diwstop,$2cc1		; window stop
	dc.w	ddfstrt,$38		; data fetch start
	dc.w	ddfstop,$d0		; data fect stop
	dc.w	bplcon0,%0001001000000000 ; 1 bitplanes
	dc.w	bplcon1,$0		; Clear scroll register
	dc.w	bplcon2,$0		; Clear priority register
	dc.w	bpl1mod,0		; No modulo (odd)
	dc.w	bpl2mod,0		; No modulo (even)
; Bitplane pointers
bph1	dc.w	bpl1pth,$0	
bpl1	dc.w	bpl1ptl,$0
; Colours
	dc.w	$180,$000,$182,$fff
	
	dc.w	$ffff,$fffe		; Wait for lufc to win something!


*****************************************************************************
;			     Variables
*****************************************************************************
	section	variables,data		; Public
gfxname	dc.b	'graphics.library',0
	even
gfxbase	dc.l	0			; Space for gfx base address


;		X1,Y1,X2,Y2
Vectors	
	dc.w	100,100,40,160

Octants1
	dc.w	%1111000000010001	; Octants without sign bit set
	dc.w	%1111000000000001
	dc.w	%1111000000011001
	dc.w	%1111000000000101
	dc.w	%1111000000010101
	dc.w	%1111000000001001
	dc.w	%1111000000011101
	dc.w	%1111000000001101

Octants2
	dc.w	%1111000001010001	; Octants with sign bit set
	dc.w	%1111000001000001
	dc.w	%1111000001011001
	dc.w	%1111000001000101
	dc.w	%1111000001010101
	dc.w	%1111000001001001
	dc.w	%1111000001011101
	dc.w	%1111000001001101




*************************
* Chip Data & Variables *
*************************
	section	gfxstuff,data_c
Screen	dcb.b	256*40,0
