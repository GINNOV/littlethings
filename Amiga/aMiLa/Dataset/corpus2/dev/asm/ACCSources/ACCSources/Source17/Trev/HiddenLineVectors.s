****************************************************************************
* Hidden Line Vectors Version 1      (C) Thomas Szirtes 1991 ( GOLDFIRE )  *
* Credit goes to Garion/Mental Image for SineTables and Sine Macros        *
****************************************************************************

	Section Mycode,CODE_C
 	OPT C-,w-

Openlib	equ -552
Closelib equ -414			;...Equates for OS calls...
Oslist equ 38
Forbid  equ -132
Permit  equ -138

	bra	begin

	even
	Include df1:trev/hw.s		; hardware equates 
	even
	include	df1:trev/trig.s		; trig macros & sines
	even

begin:

;-- Close Down the System Set up Bitplanes etc..
;-- This is the Standard Goldfire Setup Routine (C) Goldfire 1990-1991
	lea custom,a5
	move.l 4.w,a6
	bset #1,ciaa+pra		;Led Off
	jsr forbid(a6)
	blitwait			;Multitask down so let any Blits end
	lea gfxname,a1
	moveq #0,d0
	jsr openlib(a6)			;open gfxlib
	move.l d0,a1			;Put gfx base addr in a1
	move.l oslist(a1),storelist	;store OS copper addr
	jsr closelib(a6)		;close gfxlib		
	catchVB
	move #$0020,dmacon(a5)		;sprite DMA off
	move #$8640,dmacon(a5)
	move.l	#screen1,d0
	move.w	d0,pl0l
	swap	d0
	move.w	d0,pl0h
	move #$8100,dmacon(a5)
	move #$4020,intena(a5)		;Master & VB off
	move #$c010,intena(a5)		;Master & Copper On
	catchVB
	move.l #Copperlist,cop1lc(a5)
	move #$0080,dmacon(a5)
	move #0,copjmp1(a5)
	move #$8080,dmacon(a5)

;-- Main Mouse Waiting Loop

mouse:	cmpi.b	#255,$dff006
	bne.s	mouse

	bsr	vector_routine

	btst #6,ciaa+pra
	bne.s mouse	

;-- Tidy up afterwards and quit

	bclr #1,ciaa+pra		;Led On
	move #$7e0,dmacon(a5)		;Dma (incl nasty blit) off
	move.l storelist(pc),cop1lc(a5)
	move #0,copjmp1(a5)
	move #$83e0,dmacon(a5)
	move #$c020,intena(a5)
	jsr permit(a6)
	moveq #0,d0
	rts				;Go Home.....

Blanksprite dc.w 0,0

;-- Copper List... PAL and 1 bitplanes
Copperlist:
	dc.w diwstrt,$2a81		
	dc.w diwstop,$2ac1
	dc.w ddfstrt,$38
	dc.w ddfstop,$d0		;Normal screen
	dc.w bpl1mod,0
	dc.w bpl2mod,0
	dc.w bplcon1,0
cols	dc.w col0,0,col1,$FF,col2,$8,col3,$FF
	dc.w bpl1ptl
pl0l	dc.w 0,bpl1pth
pl0h	dc.w 0,bpl2ptl	
pl1l	dc.w 0,bpl2pth
pl1h	dc.w 0
	dc.w bplcon0,$1200		;One planes
	dc.w bplcon2,0			;sprites behind
	dc.w $ffe1,$fffe		;wait for end of NTSC
	dc.w $ffff,$fffe		;endless wait

*****************************************************************************
; Okay lets start with nice user-friendly assembler constants for readabilty
*****************************************************************************

OriginDist	=	640
ScreenDist	=	640
SNext_Ob	=	0		;These are offsets in data structure
SXpos		=	4		;these should always be used
SYpos		=	6		;incase of change of structure
SZpos		=	8
SXangle		=	10
SYangle		=	12
SZangle		=	14
SNum_Pts	=	16
SCorner_Pt	=	20	
SFace_Pt	=	24	

*****************************************************************************
;-- Main Loop...
*****************************************************************************

VECTOR_ROUTINE:
	bsr	DoubleBuffer
	bsr	Blitclear
	bsr	Animate
	bsr	Vector_Calculate
	bsr	Animate	; animate -> remove this call to slow down anim
	bsr	DrawObjects
	rts
	
*****************************************************************************
; 3D Vector Calculatation Routine by Prophet of Goldfire (C) T.Szirtes 1991
; Features realtime Rotation, Translation, Transformation, HiddenLine Vectors
*****************************************************************************

Vector_Calculate:

;-- Load up our pointers and get relevant data

	move.l	ObjectPointer,a0	;Pointer to Object Data in a0
	move.l	SCorner_Pt(a0),a2	;Pointer to Points in a2
	lea	Screen_Points,a1	;Pointer to Screen POints,a1
	lea	sinetab,a4		;SineTable in a4
	move.l  SNum_Pts(a0),d6
VecLoop

;-- Tidy Up

	moveq.l	#0,d0
	moveq.l	#0,d1
	moveq.l	#0,d2

;-- Rotation about Z Axis :- X2 = X1 COS a - Y1 SIN a, Y2 = Y1 COS a - X1 SIN a

	move SZangle(a0),d5	
	move d5,d4
	sin d4			
	cos d5			
	move (a2),d0		;X pos
	move 2(a2),d1		;Y Pos
	muls d5,d0		;X * cos a
	muls d4,d1		;Y * sin a
	sub.l d1,d0		;subtract to get...
	trigdiv d0		;FINAL X
	
	move (a2),d1		;X pos
	move 2(a2),d2		;Y pos
	muls d4,d1		;X * sin a
	muls d5,d2		;Y * cos a
	add.l d2,d1		;add...
	trigdiv d1		;FINAL Y

;-- Rotation about X Axis :- Y2 = Y1 COS a - Z1 SIN a, Z2 = Z1 COS a + Y1 SIN a

	move SXangle(a0),d5	
	move d5,d4
	sin d4			
	cos d5			

	move 4(a2),d2		;Find Z
	move d1,d7		;X in d0, Y in d7, Z in d2

	muls d5,d1		;Y * cos a
	muls d4,d2		;Z * sin a
	sub.l d2,d1		;subtract to get...
	trigdiv d1		;FINAL Y
	
	move 4(a2),d2		;Find Z
	muls d4,d7		;Y * sin a
	muls d5,d2		;Z * cos a
	add.l d7,d2		;add...
	trigdiv d2		;FINAL Z

;-- Rotation about Y Axis :- Z2 = Z1 COS a - X1 SIN a, X2 = X1 COS a + Z1 SIN a

	move SYangle(a0),d5	
	move d5,d4
	sin d4			
	cos d5			

	move d2,d7
	move d0,d3		;X in d3, Y in d1, Z in d7

	muls d5,d2		;Z * cos a
	muls d4,d3		;X * sin a
	sub.l d2,d3		;subtract to get...
	trigdiv d3		;FINAL Z
	move d3,d2

	muls d4,d7		;Z * sin a
	muls d5,d0		;X * cos a
	add.l d7,d0		;add...
	trigdiv d0		;FINAL Z

;-- Okay lets calculate perspective

	add SZpos(a0),d2	;Add its Zposition

	add #origindist,d2	;Calculate Perspective
	muls #screendist,d0
	muls #screendist,d1
	divs d2,d0
	divs d2,d1

;-- Then lets move it to the right position (Translate)

	add.w	SXpos(a0),d0	;Add Xpos
	add.w	SYpos(a0),d1	;Add Ypos

;- and put it into the list

	move.w	d0,(a1)+
	move.w	d1,(a1)+

;- loop

	add.l	#6,a2		;Next load of points
	dbra	d6,VecLoop

Finished_Points
	rts

*****************************************************************************
; Draw Objects -- This Incorporates the Hidden Line Routine 
*****************************************************************************

DrawObjects:
	move.l	objectpointer,a0
	move.l	SFace_pt(a0),a1		;Pointer to Face Structure
	lea	Screen_Points,a2	;Pointer to Points

HiddenLineLoop
	move	(a1)+,d7		;d7 = number of points
	bmi	NomoreFaces		;if -1 then no more faces

	move.w	(a1),d0			;d0 = Offset to Point 1
	move.w	(a2,d0),d1		;d1 = X1
	move.w	2(a2,d0),d2		;d2 = Y1
	move.w	2(a1),d0		;d0 = Offset to Point 2
	move.w	(a2,d0),d3		;d3 = X2
	move.w	2(a2,d0),d4		;d4 = Y2
	sub.w	d1,d3			;d3 = X21 = X2-X1
	sub.w	d2,d4			;d4 = Y21 = Y2-Y1

	move.w	4(a1),d0		;d0 = Offset to Point 3
	move.w	(a2,d0),d5		;d5 = X3
	move.w	2(a2,d0),d6		;d6 = Y3
	sub.w	d1,d5			;d5 = X31 = X3-X1
	sub.w	d2,d6			;d6 = Y31 = Y3-Y1
					;Phew just enough registers!
					;try doing that on an 8bit!
	muls	d3,d6			;X21*Y31
	muls	d5,d4			;X31*Y21
	sub.l	d4,d6			;subtracted
	bmi	Face_seen		;If its positive we can see it
	add.w	#2,d7
	lsl.w	#1,d7
	lea	(a1,d7.w),a1		;Find next face
	bra.s	HiddenLineLoop		;otherwise Loop
	rts
Face_Seen
;-- We now have to load up the registers ready for line drawing
;-- a1 face structure, a2 - points
Face_Seen_Loop
	moveq.l	#0,d0
	moveq.l	#0,d1
	moveq.l	#0,d2
	moveq.l	#0,d3
	move.w	(a1)+,d4		;pointer to Point 1
	move.w	(a1),d5			;pointer to Point 2

	move.w	(a2,d4),d0		;
	move.w	2(a2,d4),d1

	move.w	(a2,d5),d2
	move.w	2(a2,d5),d3
	bsr	linedraw
	dbra	d7,Face_Seen_Loop
	add.w	#2,a1
	jmp	HiddenLineLoop
Nomorefaces
;	move.w	#$FFF,$DFF180
	rts

*****************************************************************************
;-- Animate Routine... Basically add velocities to variables
*****************************************************************************

Animate:
	move.l	ObjectPointer,a0
	move.w ANGLEVX,d0
	add.w d0,SXangle(a0)
	move.w ANGLEVY,d0
	add.w d0,SYangle(a0)
	move.w ANGLEVZ,d0
	add.w d0,SZangle(a0)
	move.w ZVel,d0
	add.w d0,SZpos(a0)
	rts


;-- Data for 3D routine... 

ANGLEVX	dc.w	1
ANGLEVZ	dc.w	4
ANGLEVY dc.w 	2
ZVel	dc.w	0
ObjectPointer dc.l	Object1
screen_Points	dcb.w	90*2
NulObject	dc.l	Object1,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0

*****************************************************************************
;-- 3D Data Structure
;-- Format	dc.l Pointer to nextobject (0 if no more)	0
;		dc.w XPos,YPos,Zpos,Xangle,YAngle,ZAngle	4,6,8,10,12,14
;		dc.l Pointer to Corners				16
;		dc.l Pointer to Faces				20
*****************************************************************************
;Boring Cube
OBJECT2 dc.l 0				;Next Object
	dc.w 160,128,0,0,0,0		;Xpos,Ypos,Zpos,Xa,ya,za
	dc.l 7				;number of pts-1
	dc.l PTS2,FAC2			;Pointer to points/faces
pts2:	dc.w -50,-50,-50
	dc.w 50,-50,-50
	dc.w 50,50,-50
	dc.w -50,50,-50
	dc.w -50,-50,50
	dc.w 50,-50,50
	dc.w 50,50,50
	dc.w -50,50,50 
fac2: 	dc.w 3,0*4,1*4,2*4,3*4,0*4	;Numberofpoints then points
	dc.w 3,1*4,5*4,6*4,2*4,1*4	;dont forget to repeat first
	dc.w 3,4*4,7*4,6*4,5*4,4*4	;Points are entered clockwise
	dc.w 3,0*4,3*4,7*4,4*4,0*4	;and bloody confusing it is
	dc.w 3,2*4,6*4,7*4,3*4,2*4
	dc.w 3,0*4,4*4,5*4,1*4,0*4
	dc.w -1
;Cool Ship
OBJECT1 dc.l 0				;Next Object
	dc.w 160,128,0,0,0,0		;Xpos,Ypos,Zpos,Xa,ya,za
	dc.l 4 				;number of pts-1
	dc.l PTS1,FAC1			;Pointer to points/faces
pts1:	
	dc.w 0,0,-50
	dc.w 70,0,50
	dc.w 0,30,50
	dc.w -70,0,50
	dc.w 0,-30,50
	
fac1: 	dc.w 2,0*4,1*4,2*4,0*4
	dc.w 2,0*4,2*4,3*4,0*4
	dc.w 2,0*4,4*4,1*4,0*4
	dc.w 2,0*4,3*4,4*4,0*4
	dc.w 3,1*4,4*4,3*4,2*4,1*4
	dc.w -1

*****************************************************************************
;-- Toggle Screen Routine
*****************************************************************************

DoubleBuffer:
	move.l	Scrpt1,a0
	move.l	Scrpt2,a1
	move.l	a0,Scrpt2
	move.l	a1,Scrpt1
	move.l	a1,d0
	move.w	d0,pl0l
	swap	d0
	move.w	d0,pl0h
	rts
Scrpt1	dc.l	Screen1
Scrpt2	dc.l	Screen2

*****************************************************************************
;-- Blit Simple Lines with boundary checking
;-- Input d0,d1,d2,d3 for X1,Y1,X2,Y2    Uses d4+d5 for working
*****************************************************************************
	
linedraw:
	cmp.l	#320,d0
	bgt	BoundFound
	cmp.l	#0,d0
	blt	BoundFound

	cmp.l	#320,d2
	bgt	BoundFound
	cmp.l	#0,d2
	blt	BoundFound

	cmp.l	#256,d1
	bgt	BoundFound
	cmp.l	#0,d1
	blt	BoundFound

	cmp.l	#256,d3
	bgt	BoundFound
	cmp.l	#0,d3
	blt	BoundFound

	move.l	#40,d4
	move.l	scrpt2,a0
	sub	d0,d2
	bmi	xneg
	sub	d1,d3
	bmi	yneg
	cmp	d3,d2
	bmi	ygtx
	moveq.l	#(4*4)!1,d5
	bra	lineagain
ygtx:	exg	d2,d3
	moveq.l	#(0*4)!1,d5
	bra	lineagain
yneg	neg	d3
	cmp.w	d3,d2
	bmi	ynygtx
	moveq.l	#(6*4)!1,d5
	bra	lineagain
ynygtx	exg	d2,d3
	moveq.l	#(1*4)!1,d5
	bra	lineagain
xneg	neg	d2
	sub	d1,d3
	bmi	xyneg
	cmp	d3,d2
	bmi	xnygtx
	moveq.l	#(5*4)!1,d5
	bra	lineagain
xnygtx	exg	d2,d3
	moveq.l	#(2*4)!1,d5
	bra	lineagain
xyneg	neg	d3
	cmp	d3,d2
	bmi	xynygtx
	moveq.l	#(7*4)!1,d5
	bra	lineagain
xynygtx	exg	d2,d3
	moveq.l	#(3*4)!1,d5
lineagain:
	mulu	d4,d1
	ror.l	#4,d0	
	add	d0,d0
	add.l	d1,a0
	add	d0,a0
	swap	d0
	or.w	#$BFA,d0
	lsl.w	#2,d3
	add	d2,d2
	move	d2,d1
	lsl	#5,d1
	add	#$42,d1
	blitwait
	move	d3,Bltbmod(A5)
	sub	d2,d3
	ext.l	d3
	move.l	d3,Bltapth(a5)
	bpl	lineover
	or	#$40,d5
lineover:
	move.w	d0,Bltcon0(a5)
	move.w	d5,Bltcon1(a5)
	move.w	d4,Bltcmod(a5)
	move	d4,Bltdmod(a5)
	sub	d2,d3
	move	d3,BltAmod(A5)
	move	#$8000,BltAdat(A5)
	moveq.l	#-1,d5
	move.l	d5,BltAfwm(a5)
	move.l	a0,BltCpth(a5)
	move.l	a0,BltDpth(a5)
	move	d1,Bltsize(a5)
	rts
BoundFound	
	move.w	#$F,$DFF180	
	rts

*****************************************************************************
; Blitter Clear Routine... one bitplane
*****************************************************************************

Blitclear:
	move.w	#$0100,bltcon0(a5)
	move.w	#0,bltcon1(a5)
	move.w	#0,bltdmod(a5)
	move.l	scrpt2,bltdpth(a5)
	move.w	#(256<<6)!20,bltsize(a5)
	blitwait
	rts

gfxname	dc.b	"graphics.library",0
	even
storelist dc.l  0
	even

*****************************************************************************
; Screens...
*****************************************************************************
screen1: ds.b	40*260*1
screen2: ds.b	40*260*1


