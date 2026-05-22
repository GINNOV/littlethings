; startup code. Sprites disables ( cheers Raistlin ! ).
;Blitter allocated to task. Copper, BitPlane and Blitter DMA enabled.

; A 320x256x1 bitplane is set up with black and white colours.

; M.Meany, Aug 1991.


		incdir		source:include/
		include		hardware.i

Start		bsr.s		SysOff		disable system, set a5
		tst.l		d0		error ?
		beq.s		.error		if so quit now !
		bsr		Main		do da
		bsr		SysOn		enable system
.error		rts

*****************************************************************************

;-------------- Disable the operating system.

; On exit d0=0 if no gfx library.

SysOff		lea		$DFF000,a5	a5->hardware

		move.w		DMACONR(a5),sysDMA	save DMA settings

		lea		grafname,a1	a1->lib name
		moveq.l		#0,d0		any version
		move.l		$4.w,a6		a6->SysBase
		jsr		-$0228(a6)	OpenLibrary
		move.l		d0,grafbase	open ok?
		beq		.error		quit if not
		move.l		d0,a6		a6->GfxBase
		move.l		38(a6),syscop	save addr of sys list

		jsr		-$01c8(a6)	OwnBlitter

		move.l		$4,a6		a6->sysbase
		jsr		-$0084(a6)	Forbid

; Wait for vertical blank and disable unwanted DMA ( eg. Sprites ).

.BeamWait	move.l		VPOSR(a5),d0	d0=VPOSR+VHPOSR
		and.l		#$1ff00,d0	mask off vert position
		cmp.w		#$1000,d0	is this line 16?
		bne.s		.BeamWait	if not loop back

		move.w		#$01e0,DMACON(a5) kill all dma
		move.w		#SETIT!COPEN!BPLEN!BLTEN,DMACON(a5) enable copper

; Write bitplane addresses into Copper List.

		move.l		#BitPlane,d0
		lea		CopPlanes,a0
		move.w		d0,4(a0)
		swap		d0
		move.w		d0,(a0)

; Strobe our list

		move.l		#CopList,COP1LCH(a5)
		clr.w		COPJMP1(a5)


		moveq.l		#1,d0
.error		rts

*****************************************************************************

;--------------	Bring back the operating system

SysOn		move.l		syscop,COP1LCH(a5)
		clr.w		COPJMP1		restart system list

		move.w		#$8000,d0	set bit 15 of d0
		or.w		sysDMA,d0	add DMA flags
		move.w		d0,DMACON(a5)	enable systems DMA

		move.l		$4.w,a6		a6->SysBase
		jsr		-$008A(a6)	Permit

		move.l		grafbase,a6
		jsr		-$01ce(a6)	DisownBlitter

		move.l		$4.w,a6		a6->SysBase
		move.l		grafbase,a1	a1->Graphics base
		jsr		-$019e(a6)	CloseLibrary

		rts

*****************************************************************************
*****************************************************************************
*****************************************************************************

Main		bsr		Init	

; wait for beam to reach line 16

VBL		move.l		VPOSR(a5),d0	d0=VPOSR+VHPOSR
		and.l		#$1ff00,d0	mask off vert position
		cmp.w		#$1000,d0	is this line 16?
		bne.s		VBL		if not loop back

*****************************************************************************

		move.l		#160,d0		x orogin
		move.l		#113,d1		y orogin
		add.w		X_Rot,d0
		add.w		Y_Rot,d1
		lea		BitPlane,a1
		bsr		UnPlot


		move.l		a5,-(sp)

		bsr		RotateBalls

		move.l		(sp)+,a5

		move.l		#160,d0		x orogin
		move.l		#113,d1		y orogin
		add.w		X_Rot,d0
		add.w		Y_Rot,d1
		lea		BitPlane,a1
		bsr		Plot

*****************************************************************************

Wait		btst		#6,CIAAPRA	lefty ?
		bne.s		VBL		if not loop back

; program should shut down here....

		bsr		DeInit

		rts

*****************************************************************************
*****************************************************************************
**************************** Subroutines ************************************
*****************************************************************************
*****************************************************************************

*****************************************************************************

Init		rts

*****************************************************************************

DeInit		rts

*****************************************************************************

; plot routine

; entry		d0= x
;		d1= y
;		a1-> start of bitplane

Plot		move.l 		d1,d3 
		mulu.w 		#40,d3  
		add.l 		d3,a1
		move.l 		d0,d2
		divu.w 		#8,d2
		add.w 		d2,a1
		swap		d2
		sub.w		#7,d2
		neg.w 		d2
		bset		d2,(a1)
		rts


*****************************************************************************

; unplot routine

; entry		d0= x
;		d1= y
;		a1-> start of bitplane

UnPlot		move.l 		d1,d3 
		mulu.w 		#40,d3  
		add.l 		d3,a1
		move.l 		d0,d2
		divu.w 		#8,d2
		add.w 		d2,a1
		swap		d2
		sub.w		#7,d2
		neg.w 		d2
		bclr		d2,(a1)
		rts


; Subroutine to rotate an object formed of balls in three D. Routine adapted
;from Mini-Intro.s by Marcus Glynn ( Shadow ), found on Dec 89 Amiga
;Computing coverdisc. Cheers again Marcus!


RotateBalls	move.w		Z_Angle,d0	angle of rotation about Z
		jsr		Trig		get the Sine & CoSine
		move.w		d1,Z_Sin	store these
		move.w		d2,Z_Cos
		move.w		Y_Angle,d0	do same for Y angle
		jsr		Trig
		move.w		d1,Y_Sin
		move.w		d2,Y_Cos
		move.w		X_Angle,d0	and x angle
		jsr		Trig
		move.w		d1,X_Sin
		move.w		d2,X_Cos

		lea		wx,a0		a0->start of x ord list
		lea		wy,a1		a1->start of y ord list
		lea		wz,a2		a2->start of z ord list
		lea		X_Rot,a3	a3->start of x rotated list
		lea		Y_Rot,a4	a4->start of y rotated list
		lea		Z_Rot,a5	a5->start of z rotated list
		move.w		numpoints,d0	d0=num of points to rotate
rloop		move.w		Z_Sin,d1	d1=
		move.w		Z_Cos,d2
		move.w		(a0),d3
		muls.w		d3,d2
		move.w		(a1),d3
		muls.w		d3,d1
		sub.l		d1,d2
		lsr.l		#8,d2
		lsr.l		#6,d2
		move.w		d2,d5
		move.w		Z_Sin,d1
		move.w		Z_Cos,d2
		move.w		(a0)+,d3
		muls.w		d3,d1
		move.w		(a1)+,d3
		muls.w		d3,d2
		add.l		d1,d2
		lsr.l		#8,d2
		lsr.l		#6,d2
		move.w		d2,d6
		move.w		Y_Sin,d1
		move.w		Y_Cos,d2
		move.w		(a2),d3
		muls.w		d3,d2
		move.w		d5,d3
		muls.w		d3,d1
		sub.l		d1,d2
		lsr.l		#8,d2
		lsr.l		#6,d2
		move.w		d2,d7
		move.w		Y_Sin,d1
		move.w		Y_Cos,d2
		move.w		(a2)+,d3
		muls.w		d3,d1
		move.w		d5,d3
		muls.w		d3,d2
		add.l		d1,d2
		lsr.l		#8,d2
		lsr.l		#6,d2
		move.w		d2,d5
		move.w		X_Sin,d1
		move.w		X_Cos,d2
		move.w		d6,d4		
		move.w		d6,d3
		muls.w		d3,d2
		move.w		d7,d3
		muls.w		d3,d1
		sub.l		d1,d2
		lsr.l		#8,d2
		lsr.l		#6,d2
		move.w		d2,d6
		move.w		X_Sin,d1
		move.w		X_Cos,d2
		move.w		d4,d3
		muls.w		d3,d1
		move.w		d7,d3
		muls.w		d3,d2
		add.l		d1,d2
		lsr.l		#8,d2
		lsr.l		#6,d2
		move.w		d2,d7
		move.w		d5,(a3)+
		move.w		d6,(a4)+
		move.w		d7,(a5)+
		dbra		d0,rloop

BP1		lea		X_Angle,a0
		lea		X_AngleAdd,a1
		move.l		#360,d1

		move.w		(a1)+,d0		bump x angle
		add.w		d0,(a0)+
		cmp.w		-2(a0),d1		> 360 ?
		bgt.s		.ok1
		sub.w		d1,-2(a0)

.ok1		move.w		(a1)+,d0		bump y angle
		add.w		d0,(a0)+
		cmp.w		-2(a0),d1		> 360 ?
		bgt.s		.ok2
		sub.w		d1,-2(a0)
		

.ok2		move.w		(a1)+,d0		bump z angle
		add.w		d0,(a0)+
		cmp.w		-2(a0),d1		> 360 ?
		bgt.s		.done
		sub.w		d1,-2(a0)

.done		rts

*************************************************
*		data points for disk		*
*************************************************

wx		dc.w -50
number		equ		*-wx

wy		dc.w 3

wz		dc.w 5


NumBalls	equ		number/2     number of balls forming object

X_Angle		dc.w		0
Y_Angle		dc.w		0
Z_Angle		dc.w		0

X_AngleAdd	dc.w		1
Y_AngleAdd	dc.w		5
Z_AngleAdd	dc.w		6
		
Z_Sin		dc.w		0
Z_Cos		dc.w		0
Y_Sin		dc.w		0
Y_Cos		dc.w		0
X_Sin		dc.w		0
X_Cos		dc.w		0

numpoints	dc.w NumBalls-1

X_Rot		ds.w NumBalls		
Y_Rot		ds.w NumBalls		
Z_Rot		ds.w NumBalls		

**************************************************
*		get sin/cos value for angle in d0*
**************************************************

Trig		tst		d0
		bpl.s		.noadd
		add		#360,d0
.noadd		lea		sintab,a1
		move.l		d0,d2
		lsl		#1,d0
		move		0(a1,d0),d1
		cmp		#270,d2
		blt.s		.plus9
		sub		#270,d2
		bra.s		.sendsin
.plus9		add		#90,d2
.sendsin	lsl		#1,d2
		move		0(a1,d2),d2
		rts
		
*************************************************
*		data for sintable				*
*************************************************

sintab		dc.w 0,286,572,857,1143,1428,1713,1997,2280
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



*****************************************************************************

*****************************************************************************

*****************************************************************************

*****************************************************************************

*****************************************************************************

*****************************************************************************



*****************************************************************************
*****************************************************************************
***************************** Data ******************************************
*****************************************************************************
*****************************************************************************


grafname	dc.b		'graphics.library',0
		even
grafbase	ds.l		1
sysDMA		ds.l		1
syscop		ds.l		1

*****************************************************************************
*****************************************************************************
***************************** CHIP Data *************************************
*****************************************************************************
*****************************************************************************

		section		cop,data_c

CopList		dc.w DIWSTRT,$2c81		Top left of screen
		dc.w DIWSTOP,$2cc1		Bottom right of screen (PAL)
		dc.w DDFSTRT,$38		Data fetch start
		dc.w DDFSTOP,$d0		Data fetch stop
		dc.w BPLCON0,$1200		Select lo-res 2 colours
		dc.w BPLCON1,0			No horizontal offset
		dc.w BPL1MOD,0			No modulo

		dc.w COLOR00,$0000		black background
		dc.w COLOR01,$0fff		white foreground
 
		dc.w BPL1PTH			Plane pointers for 1 plane
CopPlanes	dc.w 0,BPL1PTL          
		dc.w 0

		dc.w		$ffff,$fffe		end of list


BitPlane	ds.b		(320/8)*256
