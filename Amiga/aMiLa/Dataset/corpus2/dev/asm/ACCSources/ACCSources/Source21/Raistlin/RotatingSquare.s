**
** Unfilled rotating square
**
** Coded by Raistlin 21/01/92
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

	bsr	Wipe			; Clear old impage

	lea	RotXYZ,a0		; A0=ptr to origional cords
	lea	RealXYZ,a1		; A1=ptr to hold rotated XYZ
	lea	Angles,a2		; A2=ptr to X,Y,Z angles
	moveq.l	#3,d0			; D0=Number of cords to rotate-1
	bsr	Rotate			; Rotate the X,Y,Z

	lea	Vectors,a0		; A0=Address of vectors
	moveq.l	#3,d0			; D0=Number of lines-1
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
;		This Routine Rotates X,Y,Z
*****************************************************************************
; On entry   A0=Pointer to origional XYZ
;            A1=Pointer to memory area to put new XYZ
;	     A2=Ptr to angles
;            D0=Number of cords to rotate-1
Rotate	
	lea	Sinetable,a3		; A3=Address of sine table
RotLoop
	move.w	(a0),d1			; D1=X
	move.w	2(a0),d2		; D2=Y
	move.w	d1,d3			; D3=X
	move.w	d2,d4			; D4=Y
	move.w	(a2),d6			; D6=Z angle
	move.w	d6,d7			; D7=Z angle
	add.w	#90,d7			; Add 90 for cos
	cmpi.w	#360,d7			; Still in 360 range?
	blt	.ok1	
	sub.w	#360,d7			; Bring back intro 360 range
.ok1	add.w	d6,d6			; D6=D6*2 (sine table in words)
	add.w	d7,d7			; D7=D7*2 
	move.w	(a3,d6),d6		; D6=Sine value of angle
	move.w	(a3,d7),d7		; D7=Cos value of angle

	muls	d7,d1			; D1=X.cos(0)
	muls	d6,d2			; D2=Y.sin(0)
	sub.l	d2,d1			; D1=X.cos(0) - Y.sin(0)
	asr.l	#7,d1			
	asr.l	#7,d1			; D1=X1

	muls	d7,d4			; D4=Y.cos(0)
	muls	d6,d3			; D3=X.sin(0)
	add.l	d4,d3			; D3=Y.cos(0) + X.sin(0)
	asr.l	#7,d3
	asr.l	#7,d3			; D1=Y1

	move.w	d3,2(a1)		; Save Y1

	move.w	d1,d3			; D3=X1 (D1=X1)
	move.w	4(a0),d2		; D2=Z
	move.w	d2,d4			; D4=Z
	move.w	2(a2),d6		; D6=Y angle
	move.w	d6,d7			; D7=Y angle
	add.w	#90,d7			; Add 90 for cos
	cmpi.w	#360,d7			; Still in 360 range?
	blt	.ok2
	sub.w	#360,d7			; Bring back into 360 range
.ok2	add.w	d6,d6			; D6=D6*2 (sine table in words)
	add.w	d7,d7			; D7=D7*2
	move.w	(a3,d6),d6		; D6=Sine value of angle
	move.w	(a3,d7),d7		; D7=Cos value of angle
	
	muls	d7,d1			; D1=X1.cos(0)
	muls	d6,d2			; D2=Z.sin(0)
	sub.l	d2,d1			; D2=X1.cos(0) - Z.sin(0)
	asr.l	#7,d1
	asr.l	#7,d1			; D1=X2 (final X cord)

	muls	d7,d4			; D4=Z.cos(0)
	muls	d6,d3			; D3=X1.sin(0)
	add.l	d4,d3			; D3=Z.cos(0) + X1.sin(0)
	asr.l	#7,d3
	asr.l	#7,d3			; D3=Z1

	move.w	d1,(a1)			; Save X2

	move.w	d3,d1			; D1=Z1 (D3=Z1)
	move.w	2(a1),d2		; D2=Y1
	move.w	d2,d4			; D4=Y1
	move.w	4(a2),d6		; D6=X angle
	move.w	d6,d7			; D7=X angle
	add.w	#90,d7			; Add 90 for cos
	cmpi.w	#360,d7			; Still in 360 range?
	blt	.ok3
	sub.w	#360,d7			; Brin back intro 360 range
.ok3	add.w	d6,d6			; D6=D6*2 (sine table in words)
	add.w	d7,d7			; D7=D7*2
	move.w	(a3,d6),d6		; D6=Sine value of angle
	move.w	(a3,d7),d7		; D7=Cos value of angle
	
	muls	d7,d1			; D1=Z1.cos(0)
	muls	d6,d2			; D2=Y1.sin(0)
	sub.l	d2,d1			; D1=Z1.cos(0) - Y1.sin(0)
	asr.l	#7,d1
	asr.l	#7,d1			; D1=Z2 (final Z)
	
	muls	d7,d4			; D4=Y.cos(0)
	muls	d6,d3			; D3=Z.sin(0)
	add.l	d4,d3			; D3=Y.cos(0) + Z.sin(0)
	asr.l	#7,d3
	asr.l	#7,d3			; D3=Y2

	move.w	d1,4(a1)		; Insert Z2
	move.w	d3,2(a1)		; Insert Y2
	add.w	#160,(a1)		; Centre X cord to mid of screen
	add.w	#128,2(a1)		; Centre Y cord to mid of sceen

	add.w	#8,a0
	add.w	#8,a1
	dbra	d0,RotLoop	

	add.w	#1,(a2)			; Incrment Z angle by 1
	cmpi.w	#360,(a2)		; Still in 360 range?
	blt	.DoY
	sub.w	#360,(a2)		; Bring back into 360 range
.DoY	add.w	#3,2(a2)		; Increment Y angle by 3
	cmpi.w	#360,2(a2)		; Still in 360 range?
	blt	.DoX
	sub.w	#360,2(a2)		; Bring back into 360 range
.DoX	add.w	#2,4(a2)		; Increment X angle by 2
	cmpi.w	#360,4(a2)		; Still in 360 range?
	blt	.Exit
	sub.w	#360,4(a2)		; Bring back into 360 range
.Exit	rts



*****************************************************************************
;		This Routine Wipes The Old Cube
*****************************************************************************
Wipe	btst	#14,dmaconr(a5)
	bne	Wipe
	move.l	#Screen+1120,bltdpth(a5); Destination=Screen
	move.w	#0,bltdmod(a5)		; 40-40
	move.w	#$ffff,bltafwm(a5)	; No mask
	move.w	#$ffff,bltalwm(a5)	; No mask
	move.w	#%100000000,bltcon0(a5)	; Wipe blit
	move.w	#$0,bltcon1(a5)		; Clear
	move.w	#(200*64)+20,bltsize(a5)
	rts


*****************************************************************************
;	    This Routine Draws A Line Using The Blitter
*****************************************************************************
; On entry   A0=ptr to vectors
;            A5=ptr to hardware
;            D0=Number of lines to blit-1
; Cords must be set out as:-  X1,Y1,X2,Y2  Alter offsets if different
DrawLine
	moveq.l	#0,d7			; Clear octant counter
	move.l	(a0),a1			; A1=X1,Y1
	move.l	4(a0),a2		; A2=X2,Y2

	move.w	(a1),d1			; D1=X1
	move.w	(a2),d2			; D1=X1
	cmp.w	d1,d2			; X1 X2 same?
	bne	.diff
	move.w	2(a1),d1		; D1=Y1
	move.w	2(a2),d2		; D1=Y2
	cmp.w	d1,d2			; X1 X2 same?
	bne	.diff			; 
	rts				; No line to draw!
; This section works out DX, DY, DS, DL & works out octant to use
.diff	move.w	(a1),d1			; D1=X1
	move.w	(a2),d2			; D2=X2
	sub.w	d1,d2			; D2=X2-X1
	bpl	.DY			; If result is +ve branch
	neg.w	d2			; Make DX +ve
	addq.w	#4,d7			; Set bit 2
.DY	move.w	d2,d3			; D3=DX
	move.w	2(a1),d1		; D1=Y1
	move.w	2(a2),d2		; D2=Y2
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
	move.w	(a1),d1			; D1=X1
	and.w	#%1111,d1		; Keep 4LSB of X1
	ror.w	#4,d1			; Put in 4MSB of word (shift bit)
	or.w	#$BCA,d1		; OR in miniterm + channels to use
	move.w	d1,bltcon0(a5)		; Insert bltcon0 value
; Now we calculate the remaining blitter registers & draw the line
	move.w	#40,bltcmod(a5)		; Cmod=with of screen in bytes
	move.w	#40,bltdmod(a5)		; Dmod=width of screen in bytes
	moveq.l	#0,d1			; Clear D1
	move.w	(a1),d1			; D1=X1
	move.w	2(a1),d2		; D2=Y1
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

	add.w	#8,a0			; Get to next vector
	dbra	d0,DrawLine		; Draw next line
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


; THESE VALUES ARE FOR THE LINE DRAW ROUTINE

; Format of  X, Y, Z, Nill word
RealXYZ					; Following table holds current XYZ values
A	dc.w	-50,-50,050,0		; Front face cords
B	dc.w	050,-50,050,0
C	dc.w	-50,050,050,0
D	dc.w	050,050,050,0


Vectors	
	dc.l	a,b
	dc.l	a,c
	dc.l	b,d
	dc.l	c,d


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


; THESE VALUES ARE FOR THE ROTATION ROUTINE
; Format of  X, Y, Z, Nill word
RotXYZ					; This table stays static
	dc.w	-50,-50,050,0		; Front face cords
	dc.w	050,-50,050,0
	dc.w	-50,050,050,0
	dc.w	050,050,050,0


Angles					; The angles to rotate around
Z	dc.w	0
Y	dc.w	0
X	dc.w	0


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
Screen	dcb.b	256*40,0
