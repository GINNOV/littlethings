*    This program is free software; you can redistribute it and/or modify
*    it under the terms of the GNU General Public License as published by
*    the Free Software Foundation; either version 2 of the License, or
*    (at your option) any later version.
*
*    This program is distributed in the hope that it will be useful,
*    but WITHOUT ANY WARRANTY; without even the implied warranty of
*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*    GNU General Public License for more details.
*
*    You should have received a copy of the GNU General Public License
*    along with this program; if not, write to the Free Software
*    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
*
*************************************************************************

*************************************************************************
* 4 Bp Concave Multicoloured Lightsource-shaded Filled Animated Vectors *
* ©1989-1991 Steinar Midtskogen  Last updated: 13:30:31 9th August 1991 *
*************************************************************************

	Include	df0:Include/Hardware/FastBlit.i
	Auto	e\j

	>Extern	"RAM:8bitSine",sinetab
	>Extern	"RAM:NewComb",colcomb

******************************** CONSTANTS ******************************
Height=	240				; X=[2..280], even numbers only.
Width=	22*16				; X=[16..352], X/16=N.

********************************* MACROS ********************************
Clip:	Macro
	move.w	(a0)+,d4		; * This macro is used to clip
	cmp.w	\1,d4			;   lines.
	b\6.s	skip\@			;
	sub.w	\2,d4			;
	b\3	return			;
	sub.w	\2,\1			;
	sub.w	\4,\5			;
	muls	d4,\5			;
	divs	\1,\5			;
	move.w	-2(a0),\1		;
	add.w	\4,\5			;
\7	move.w	d3,(a1)+
skip\@:
	EndM

GetXYZ:	Macro
fake\@:	move.w	(a3)+,d5		; * Read value from the connect-
	add.w	d5,d5			;   array and multiply by two.
	bpl.s	real\@			; * Is it an invisible point? 
	neg.w	d5			;
	cmp.w	0(a2,d5.w),a6		; * Is the Z-value of this point
	ble.s	fake\@			;   less than the other Z-values.
	move.w	0(a2,d5.w),a6		;   If yes, store Z-value.
	cmp.w	#0,a6			; * Avoid removing surface
	bpl.s	fake\@			;   because of invisible point.
	lea	1.w,a6			;
	bra.s	fake\@			; * It's invisible, jump back.
real\@:	cmp.w	0(a2,d5.w),a6		; * Is the Z-value of this point
	ble.s	stay\@			;   less than the other Z-values.
	move.w	0(a2,d5.w),a6		;   If yes, store Z-value.
stay\@:	add.w	d5,d5			; * Copy X,Y-values to \1 & \2.
	move.w	0(a4,d5.w),\1		;
	move.w	2(a4,d5.w),\2		;  
	EndM

MatRot:	Macro
\7	move.w	\1,\4			;
\7	move.w	\2,\5			;
\7	move.w	\3,\6			;
	muls	(a1)+,\1		; * Multiply X, Y & Z by values
	muls	(a1)+,\2		;   in the matrix.
	muls	(a1)+,\3		;
	add.l	\2,\1			; * Add all results.
	add.l	\3,\1			;
	swap	\1			; * Correct size.
	EndM

WaitBlt:Macro
wbl\@:	btst	#6,DmaConr(a6)		; * Wait for blitter to finish.
	bne.s	wbl\@			;
	EndM

	jmp	start			; * Start vector.

	SECTION	data,DATA_C
copper1:dc.w $008e,$aa00-[Height/2*$100]+$71
	dc.w $0090,[$aa00+[Height/2*$100]+$d1]&$ffff
	dc.l $00920030,$009400d8,$008a0000
copper2:dc.l $00e00007,$00e20000,$00e40007,$00e6002c
	dc.l $00e80007,$00ea0058,$00ec0007,$00ee0084
	dc.w $0180,$0000,$a909-[Height/2*$100],$fffe,$0180,$0555
	dc.l $01820112,$01840334,$01860557,$01880779,$018a099c
	dc.l $018c0010,$018e0130,$01900250,$01920471,$019406b2,$01960200
	dc.l $01980400,$019a0600,$019c0901,$019e0c02
	dc.l $01080084,$010a0084,$01020000,$01004200,$009c8010
	dc.w $aa09-[Height/2*$100],$fffe,$0180,$0004
	IF Height>171 THEN
	 dc.l $ffe1fffe
	EndIf
	dc.w [$aa09+[Height/2*$100]]&$ffff,$fffe,$0180,$0555
	IF Height=170 THEN
	 dc.l $ffe1fffe
	EndIf
	dc.w [$ab09+[Height/2*$100]]&$ffff,$fffe,$0180,$0003
	dc.l $01800000,$01000204,$fffffffe

	SECTION graphics,BSS_C
frame1:	ds.b	Height*44*4
frame2:	ds.b	Height*44*4
workscr:ds.b	Height*44
stencil:ds.b	[Height+2]*44

	SECTION	code,CODE
******* MASK & PERSPECTIVE GENERATION AND COPPER & INTERRUPT SETUP ******
start:	movem.l	d0-d7/a0-a6,-(SP)	; * Store all registers.
	lea	prspect,a0		; * This loop makes a $1fd8 words
	move.w	#320,d0			;   long array with $a00000/X,
	move.w	#$1fd7,d3		;   X = [320,328,336 ...]
psploop:move.l	#$a00000,d1		;
	divu	d0,d1			;
	move.w	d1,(a0)+		;
	addq.w	#8,d0			;
	dbf	d3,psploop		;
	lea	stencil,a0		; * This 2-dimensional loop makes
	move.w	#Height/2,d1		;   the mask needed for colour-
msklop1:moveq	#10,d0			;   mixing.
msklop2:move.l	#$55555555,(a0)+	;
	move.l	#$aaaaaaaa,40(a0)	;
	dbf	d0,msklop2		;
	lea	44(a0),a0		;
	dbf	d1,msklop1		;
	move.w	$dff01c,-(SP)		; * Start copper and interrupt.
	bset	#15,(SP)		;
	move.w	#$7fff,$dff096		;
	clr.l	$dff144			;
	move.w	#$87c0,$dff096		;
	move.w	#$3fff,$dff09a		;
	move.l	$6c.w,-(SP)		;
	move.l	#interpt,$6c.w		;
	move.w	#$8010,$dff09a		;
	move.l	#copper1,$dff080	;
	move.l	#copper2,$dff084	;
	clr.w	$dff088			;
notquit:bsr	program			; * Bsr to the main program.
	Waitblt				; * Waitblit.
waitrst:cmp.w	#$ae00,VhPosr(a6)	; * Wait for safe point.
	blo.s	waitrst			;
	move.w	copper2+2,BltDpth(a6)	; * Start the blitter to clear
	move.w	copper2+6,BltDptl(a6)	;   the screen.
	move.l	#$1000000,BltCon0(a6)	;
	clr.w	BltDmod(a6)		;
	move.w	#Height*128+44,(a6)	;
	btst	#6,$bfe001		; * Jump back to raster if left
	bne.s	notquit			;   mousebutton is not pressed.
	move.l	$4.w,a0			; * Restore copperlist 1.
	move.l	156(a0),a0		;
	move.l	38(a0),$dff080		;
	move.l	(SP)+,$6c.w		; * Reset copper and interrupt-
	move.w	#$7fff,IntEna(a6)	;   vectors.
	move.w	(SP)+,IntEna(a6)	;
	movem.l	(SP)+,d0-d7/a0-a6	; * Reset registers.
	rts
sinetab:blk.b	2560,0
colcomb:blk.b	3072,0

******************************** INTERRUPT ******************************
interpt:btst	#10,$dff058+PotGor	; * Rotation halted? 
	beq.s	rothalt			;
	add.w	#3*2,regist1+2		; * Add to angles.
	add.w	#2*2,regist1+6		;
	add.w	#2*2,regist1+10		;
	and.w	#$7fe,regist1+2		;
	and.w	#$7fe,regist1+6		;
	and.w	#$7fe,regist1+10	;
rothalt:bsr.s	animate			; * Animation.
	move.w	#16,$dff058+IntReq	;
	rte

******************************** ANIMATION ******************************
animate:movem.l	d0-d1/a0-a2,-(SP)	; * Store used registers.
	lea	anim(PC),a0		; * Start-address of the
nxtanim:tst.w	(a0)			;   animation data.
	bmi.s	animfin			; * No more points to animate?
	subq.w	#1,(a0)+		; * Decrement counter.
	bmi.s	movepnt			; * Time for movement?
	addq.l	#8,a0			; * Not yet, skip to next point.
	move.w	-2(a0),d0		;
	mulu	#6,d0			;
	add.l	d0,a0			;
	bra.s	nxtanim			;
movepnt:move.w	(a0)+,-4(a0)		; * It's time for movement; which
	lea	data_3d(PC),a1		;   point?
	move.w	(a0)+,d0		;
	mulu	#6,d0			;
	add.l	d0,a1			;
	addq.w	#1,(a0)			; * Increase counter.
	move.w	(a0)+,d1		; * Counter>max value?
	cmp.w	(a0),d1			;
	bne.s	notexhd			;
	moveq	#0,d1			;
	clr.w	-2(a0)			;
notexhd:move.w	(a0)+,d0		; * Move point to next position.
	mulu	#6,d0			;
	move.l	a0,a2			;
	add.l	d0,a2			;
	mulu	#6,d1			;
	add.l	d1,a0			;
	move.w	(a0)+,(a1)+		;
	move.w	(a0)+,(a1)+		;
	move.w	(a0),(a1)		;
	move.l	a2,a0			;
	bra.s	nxtanim			; * Move next points if any.
animfin:movem.l	(SP)+,d0-d1/a0-a2	; * Restore used registers.
	rts				;

************************ SWAP SCREENS, READ MOUSE ***********************
program:lea	frame2,a0		; * Address of first frame.
	lea	copper2+2,a1		;
	moveq	#3,d1			;
	move.l	#frame1+44*4*[Height/2-1]-2,regist4+16
	eor.w	#1,regist4+20		; * 0->1, 1->0.
	beq.s	firstf			;
	move.l	#frame2+44*4*[Height/2-1]-2,regist4+16
	lea	frame1,a0		; * Address of second frame.
firstf:	move.l	a0,d0			; * Move address to copperlist.
	swap	d0			;
	move.w	d0,(a1)			;
	move.w	a0,4(a1)		;
	lea	44(a0),a0		;
	addq.l	#8,a1			;
	dbf	d1,firstf		;
bug:	movem.l	regist1(PC),d6-d7/a0-a6	; * Copy regist1.
	move.w	Joy0dat(a6),d0		; * Read XY-value of mouse, 
	not.w	d0			;   reverse it,
	lsr.w	#2,d0			;   Y=Y/4,
	sub.w	#512,d0			;   subract 512 &
	move.w	d0,regist2+26		;   store it.

*********************** COMPUTE THE ROTATION-MATRIX *********************
	move.w	0(a1,d7.w),d1		; * X1=CosY*CosZ.
	move.w	0(a2,d7.w),d3		;   Y1=SinZ*CosY.
	move.w	0(a1,a0.w),d4		;   Z1=-SinY.
	move.w	0(a2,a0.w),d5		;
	move.w	d4,d2			;
	move.w	d3,d0			;
	muls	d3,d2			;
	muls	d5,d0			;
	move.w	d2,6(a4)		;
	move.w	d1,d2			;
	asl.w	#4,d2			;
	neg.w	d2			;
	move.w	d2,12(a4)		;
	move.w	d0,(a4)+		;
	move.w	0(a1,d6.w),d0		; * X2=SinX*SinY*CosZ-CosX*SinZ.
	muls	d0,d1			;   Y2=SinX*SinY*SinZ+CosX*CosZ.
	muls	d3,d0			;   Z2=SinX*CosY.
	asr.l	#7,d1			;
	move.w	d1,d2			;
	muls	0(a2,a0.w),d1		;
	muls	0(a2,d6.w),d4		;
	sub.w	d4,d1			;
	muls	0(a1,a0.w),d2		;
	muls	0(a2,d6.w),d5		;
	add.w	d5,d2			;
	asr.w	#3,d0			;
	move.w	d0,12(a4)		;
	move.w	d2,6(a4)		;
	move.w	d1,(a4)+		;
	move.w	0(a1,d7.w),d0		; * X3=SinY*CosX*CosZ+SinX*SinZ.
	muls	0(a2,d6.w),d0		;   Y3=SinY*CosX*SinZ-SINX*CosZ.
	move.w	0(a2,d7.w),d3		;   Z3=CosX*CosY.
	muls	0(a2,d6.w),d3		;
	asr.l	#7,d0			;
	move.w	d0,d2			;
	muls	0(a2,a0.w),d2		;
	muls	0(a1,a0.w),d0		;
	move.w	0(a1,d6.w),d1		;
	move.w	d1,d4			;
	muls	0(a1,a0.w),d1		;
	add.w	d1,d2			;
	muls	0(a2,a0.w),d4		;
	sub.w	d4,d0			;
	asr.w	#3,d3			;
	move.w	d3,12(a4)		;
	move.w	d0,6(a4)		;
	move.w	d2,(a4)			;

*********** ROTATE POINTS AND CONVERT TO 2D AND STORE X, Y & Z **********
	move.w	#$0010,$dff09a		; * No interrupt while computing.
	move.w	points(PC),d7		; * Number of points to rotate.
	movem.l	regist2(PC),a0-a6	; * Copy regist2.
compute:movem.w	(a5)+,d0/d2/d3		; * Read point(X,Y,Z) to rotate.
	MatRot	d0,d2,d3,d1,d4,d5	; * Rotate point.
	MatRot	d1,d4,d5,d2,d3,d6	;
	MatRot	d2,d3,d6,*,*,*,*	;
	lea	-18(a1),a1		;
	add.w	xpos(PC),d0		; * Move object to a position.
	add.w	a3,d1			;
	movem.w	d0-d2,(a2)		; * Store XYZ before 3d->2d.
	addq.l	#8,a2			;
	add.w	a6,d2			;
	and.w	#-2,d2			; * 3 dimensions -> 2 dimensions.
	move.w	prspect(PC,d2.w),d3	;
	muls	d3,d0			;
	muls	d3,d1			;
	swap	d1			;
	move.w	d1,d0			;
	move.l	d0,(a4)+		; * Store X,Y in data_2d.
	move.w	d2,(a0)+		; * Store Z in surfcz1.
	dbf	d7,compute		; * Repeat until finished.
	move.w	#$8010,$dff09a		; * Enable interrupt.
	bra	findvis			;
prspect:blk.w	$2100,0
xpos:	dc.w	0

************ FIND VISIBLE SURFACES AND THEIR START-ADDRESSES ************
findvis:move.l	#sizes-2,adds		;
	movem.l	regist3(PC),a0-a5	; * Copy regist3.
	move.w	#-1,-(SP)		; * Surfaces=-1.
addsurf:addq.w	#1,(SP)			; * Surfaces=surfaces+1.
newsurf:addq.l	#2,adds			;
	move.w	#$fe,d7			;
	move.l	a0,adds+4		;
	move.b	(a3)+,(a0)		; * Move colour to lines.
	bmi	drawsur			; * No more surfaces?
	add.b	(a3)+,d7		; * Read command from connect.
	lea	$7fff.w,a6		; * Move max-value to a6.
	GetXYZ	d0,d1			; * Get 3 Xs & Ys and test Zs.
	GetXYZ	d2,d3			;
	GetXYZ	d4,d5			;
	movem.w	d0-d5,2(a0)		; * Copy three points.
	sub.w	d0,d2			; * Is surface is visible?
	sub.w	d1,d3			;
	sub.w	d0,d4			;
	sub.w	d1,d5			;
	muls	d3,d4			;
	muls	d2,d5			;
	sub.l	d5,d4			;
	blt.s	visible			; * Branch if visible.
	add.w	d7,d7			;
	add.w	d7,a3			; * Not visible, new surface.
	bra	newsurf			;
visible:movem.w	-6(a3),d0-d2		; * Get the first three points.
	move.l	a0,(a1)+		; * Surface is visible;
	lea	14(a0),a0		;   store address of surface.
	dbf	d7,cpyrest		; * Three points already copied.
	bra.s	endofsf			;   Was that all?
cpyrest:GetXYZ	(a0)+,(a0)+		;   If no, copy the rest.
	dbf	d7,cpyrest		;
endofsf:move.w	#$8000,(a0)+		; * Set end-mark.
	move.w	a6,(a5)+		; * Store the lowest Z-value.
	bgt	shading			;   Was it <=0? If no, jump.
	subq.w	#4,a1			; * Negative Z-values, delete
	subq.w	#2,a5			;   surface.
	bra	newsurf			; * Jump back.

****************************** SHADE SURFACE ****************************
shading:lsl.w	#3,d0			; * Get X, Y & Z-values of the
	lsl.w	#3,d1			;   three first points.
	lsl.w	#3,d2			;
	movem.w	rot_3d(PC,d0.w),d6-d7/a6;
	movem.w	rot_3d(PC,d2.w),d3-d5	;
	movem.w	rot_3d(PC,d1.w),d0-d2	;
	sub.w	d6,d0			; d0=X2-X1
	sub.w	d7,d1			; d1=Y2-Y1
	sub.w	a6,d2			; d2=Z2-Z1
	sub.w	d6,d3			; d3=X3-X1
	sub.w	d7,d4			; d4=Y3-Y1
	sub.w	a6,d5			; d5=Z3-Y1
	move.w	d5,d7			; * (Z3-Z1)(Y2-Y1)-(Y3-Y1)(Z2-Z1)
	muls	d1,d7			;
	move.w	d4,d6			;
	muls	d2,d6			;
	sub.l	d6,d7			;
	move.w	d3,d6			; * (X3-X1)(Z2-Z1)-(Z3-Z1)(X2-X1)
	muls	d2,d6			;
	muls	d0,d5			;
	sub.l	d5,d6			;
	muls	d0,d4			; * (Y3-Y1)(X2-X1)-(X3-X1)(Y2-Y1)
	muls	d1,d3			;
	sub.l	d3,d4			;
	asr.l	#8,d7			; * Correct sizes.
	asr.l	#8,d6			;
	swap	d4			;
	rol.l	#6,d4			;
	movem.w	ezvec(PC),d0-d2		;
	muls	d0,d7			; * Multiply results by light-
	muls	d1,d6			;   vector.
	muls	d2,d4			;
	add.l	d6,d7			; * Average values.
	add.l	d4,d7			;
	asr.l	#3,d7			; * Correct size.
	move.l	adds(PC),a6		;
	divs	(a6),d7			;
	bpl.s	notdark			; * Get correct colour.
	moveq	#0,d7			;
notdark:move.l	adds+4(PC),a6		;
	move.w	(a6),d4			;
	and.w	#$700,d4		;
	add.w	d4,d4			;
	lsl.w	#5,d7			;
	add.w	d7,d4			;
	move.w	d4,(a6)			;
	bra	addsurf			;
rot_3d:	blk.w	1024,0

*********** DRAW THE MOST DISTANT SURFACE ON THE WORKSCREEN *************
drawsur:move.w	(SP),d7			; * Number of surfaces to draw.
	movem.l	regist4(PC),a1/a3-a4/a6	; * Copy regist4.
nxtsurf:moveq	#0,d6			; * Set d6 to min-value.
	move.w	(SP),d3			; * Number of surfaces.
	lea	surfcz2(PC),a0		; * Load some registers.
	lea	colcomb-512(PC),a5	;
	dbf	d7,drawlns		; * Surfaces=surfaces-1.
	addq.l	#2,SP			; * Restore stackpointer.
	rts				; * Finished.
drawlns:move.w	d3,d4			;
fndmdst:cmp.w	(a0)+,d6		; * Z-value lower than d6?
	bge.s	zlower			; * If yes, branch to zlower.
	move.w	-2(a0),d6		; * If no, copy Z-value to d6
	move.w	d3,d5			; * Move counter to d5.
zlower:	dbf	d3,fndmdst		; * Continue searching.
	sub.w	d5,d4			; * Find address of the address
	add.w	d4,d4			;   of the surface to draw, and
	clr.w	0(a4,d4.w)		;   delete the Z-value from
	add.w	d4,d4			;   surfcz2.
	move.l	0(a3,d4.w),a2		;
	pea	$80008000		; * Set the area to max.
	pea	$7fff7fff		;
	move.w	#44,BltCmod(a6)		; * Set some constant blitter-
	move.l	#-$8000,BltBdat(a6)	;   values.
	move.w	#7,BltCpth(a6)		;
	add.w	(a2)+,a5		; * Get the colour-combination.
nxtline:movem.w	(a2),d0-d3		; * Get (X1,Y1) & (X2,Y2).
	addq.l	#4,a2			;
	pea	drawfin(PC)		;
draw:	lea	screen(PC),a0		;
	cmp.w	d0,d2			; * X1<X2.
	bgt.s	exchg1			;
	exg	d0,d2			;
	exg	d1,d3			;
exchg1:	Clip	d0,d2,pl,d3,d1,lt,*	; * Clip lines (left edge).
	Clip	d2,d0,mi,d1,d3,ge	; * Clip lines (right edge).
	add.w	#176,d0			; * Move origo.
	add.w	#176,d2			;
	cmp.w	4(SP),d0		; * Find smallest X (area).
	bge.s	area1			;
	move.w	d0,4(SP)		;
area1:	cmp.w	8(SP),d2		; * Find largest X (area).
	ble.s	area2			;
	move.w	d2,8(SP)		;
area2:	cmp.w	d1,d3			; * Y1<Y2.
	beq	return			; * DeltaY=0?
	bgt.s	exchg2			;
	exg	d0,d2			;
	exg	d1,d3			;
exchg2:	Clip	d1,d3,pl,d2,d0,lt,*	; * Clip lines (upper edge).
	Clip	d3,d1,le,d0,d2,ge,*	; * Clip lines (lower edge).
	cmp.w	6(SP),d1		; * Find smallest Y (area).
	bge.s	area3			;
	move.w	d1,6(SP)		;
area3:	cmp.w	10(SP),d3		; * Find largest Y (area).
	ble.s	area4			;
	move.w	d3,10(SP)		;
area4:	move.w	d1,d4			; * Find octant.
	muls	#44,d4			;
	move.w	d0,d5			;
	asr.w	#3,d5			;
	ext.l	d5			;
	add.l	#workscr+44*[Height/2],d4
	add.l	d5,d4			;
	moveq	#0,d5			;
	sub.w	d1,d3			;
	sub.w	d0,d2			;
	bpl.s	fnddx			;
	moveq	#1,d5			;
	neg.w	d2			;
fnddx:	move.w	d3,d1			;   Fix corner.
	add.w	d1,d1			;
	cmp.w	d2,d1			;
	dbhi	d3,fixcrn		;
fixcrn:	move.w	d3,d1			;
	sub.w	d2,d1			;
	bpl.s	dygdx			;
	exg	d2,d3			;
dygdx:	addx.w	d5,d5			;
	add.w	d2,d2			;
	move.w	d2,d1			;
	sub.w	d3,d2			;
	addx.w	d5,d5			;
	and.w	#$f,d0			;
	ror.w	#4,d0			;
	or.w	#$a4a,d0		;
	Waitblt				; * Waitblit.
	move.w	d2,BltAptl(a6)		; * Start to feed the blitter.
	sub.w	d3,d2			;
	lsl.w	#6,d3			;
	addq.w	#2,d3			;
	move.w	d0,BltCon0(a6)		;
	move.b	oct(PC,d5.w),BltCon1+1(a6)
	move.l	d4,BltCpth(a6)		;
	move.l	d4,BltDpth(a6)		;
	movem.w	d1/d2,BltBmod(a6)	;
	move.w	d3,(a6)			; * Draw line.
return:	rts				;
drawfin:cmp.w	#$8000,4(a2)		; * Finished?
	bne	nxtline			; * If not, jump back.
drawrgt:cmp.l	#out,a1			; * Draw lines between right
	beq.s	fillsur			;   edge-clipped lines.
	move.w	-(a1),d1		;
	move.w	-(a1),d3		;
	move.w	screen+2(PC),d0		;
	move.w	d0,d2			;
	pea	drawrgt(PC)		;
	bra	draw			; * Draw line.
oct:	dc.l	$3431353,$b4b1757	; * Octant-codes.

**************************** FILL THE SURFACE ***************************
fillsur:lea	workscr+44*[Height/2-1]-2,a0; * Get workscreen address.
	movem.w	(SP)+,d0-d3		; * Get area to be filled.
	cmp.w	#$8000,-2(SP)		; * Surface in screen?
	beq	nxtsurf			;
	move.w	d3,d4			; * Find the address of the
	muls	#44,d4			;   lower-right corner.
	add.l	d4,a0			;
	lsr.w	#4,d0			;
	lsr.w	#4,d2			;
	addq.w	#1,d2			;
	add.w	d2,a0			;
	add.w	d2,a0			;
       	sub.w	d1,d3			;
	move.l	d2,d1			; * Save for later use.
	lsl.w	#6,d3			; * Find the blitsize.
	sub.w	d0,d2			;
	or.w	d2,d3			;
	add.w	d2,d2			; * Find the modulo.
	moveq	#44,d6			;
	sub.w	d2,d6			;
	move.w	d6,BltDmod(a6)		;
	move.l	a0,d5			;
	Waitblt				; * Waitblit
	move.l	#$9f00012,BltCon0(a6)	; * Feed blitter.
	move.w	d6,BltAmod(a6)		;
	move.l	d5,BltApth(a6)		;
	move.l	a0,BltDpth(a6)		;
	move.w	d3,(a6)			; * Start filling.

****************** COPY THE SURFACE FROM THE WORKSCREEN *****************
	move.w	d6,BltCmod(a6)		; * Set modulo for source B & C.
	add.w	#132,d6			;
	move.w	d6,BltBmod(a6)		;
	move.l	d5,d0			; * Find start-address for
	add.l	#stencil-workscr+44,d0	;   source C (mask).
	add.w	d1,d1			;
	asl.l	#2,d4			; * Find start-address for
	add.l	regist4+16(PC),d1	;   destination D.
	add.l	d4,d1			;
	moveq	#3,d2			; * Counter=3.
	Waitblt				; * Waitblit.
	move.w	#2,BltCon1(a6)		; * Blitter-registers which may
	move.w	d6,BltDmod(a6)		;   be set only once.
colloop:sub.l	2(a5),d0		;
	move.l	d1,a0			;
	Waitblt				; * Waitblit.
	move.w	(a5)+,BltCon0(a6)	; * Set correct bltcon0.
	movem.l	d0/d1/d5/a0,BltCpth(a6)	; * Feed blitter.
	move.w	d3,(a6)			; * Start copying to plane 1.
	add.l	#44,d1			; * Next plane.
	add.l	(a5)+,d0		;
	dbf	d2,colloop		; * Finished? If not, jump back.
	sub.w	#132,d6			;
	Waitblt				; * Waitblit.
	move.w	#$100,BltCon0(a6)	; * Feed the blitter.
	move.w	d6,BltDmod(a6)		;
	move.l	d5,BltDpth(a6)		;
	move.w	d3,(a6)			; * Start clearing workscreen.
	bra	nxtsurf			; * Jump to draw next surface.

************************** REGISTERS & ARRAYS ***************************
regist1:dc.l 0,0,0,sinetab,sinetab+512,copper2,matrix+18,matrix,$dff058
regist2:dc.l surfcz1,matrix+18,rot_3d,0,data_2d,data_3d,0
regist3:dc.l lines,surface,surfcz1,connect,data_2d,surfcz2
regist4:dc.l out,surface,surfcz2,$dff058,0,0
matrix:	dc.w 30000,0,0,0,30000,0,0,0,30000,0,0,0,0,0,0,0,0,0
screen:	dc.w -Width/2,Width/2-1,-Height/2,Height/2 ; * (X1,X2,Y1,Y2).
adds:	dc.l sizes,data_3d
ezvec:	dc.w 30,50,50

out:	blk.w	32,0
data_2D:blk.w	1024,0
lines:	blk.w	1024,0
surfcz1:blk.w	512,0
surfcz2:blk.w	256,0
surface:blk.w	256,0

*********************  V E C T O R - O B J E C T S  *********************
* First word of each surface:						*
*		BIT	0- 7: Number of visible points in the surface.	*
*		BIT	8-10: Colour of the surface. (1-6)		*
*		BIT	  15: 1 = End of object				*
*									*
* First 5 words of each animation:					*
* 		1:Speed-counter  2:Speed  3:Point  4:Position  5:Frames	*
*									*
*   Negative connect-values (must be set first) give invisible points.	*
*************************************************************************

	Include	"df0:Vector/Objects/4bp Objects/Robot.4bp"
