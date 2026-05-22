
obj_Ox		equ		0		origin x of rot center
obj_Oy		equ		2		origin y of rot center
obj_ZDist	equ		4
obj_Count	equ		6		number of surfaces
obj_Surface	equ		8		pointer to surfaces
obj_Points	equ		12		pointer to points table
obj_RotPoints	equ		16		pointer to rotated points
obj_XY		equ		20		pointer to plotable x,y coords
obj_Ext		equ		24		user extension

_pX		equ		0		offsets from a0 to X,Y,Z
_pY		equ		2
_pZ		equ		4
_pNext		equ		6

razSin		equ		0		offsets to stored trig values
razCos		equ		2	
raySin		equ		4
rayCos		equ		6
raxSin		equ		8
raxCos		equ		10

;		*************************************************
;		*		Bump Rotation Angles		*
;		*************************************************

; Entry		a0->Angles in order X,Y,Z
;		a1->Angle increments in same order

; Exit		same

; Corrupt	None

RBumpAngle	movem.l		d0-d1/a0-a1,-(sp)
		moveq.l		#2,d1			counter
_RBALoop	move.w		(a0)+,d0
		add.w		(a1)+,d0
		cmp.w		#360,d0
		ble.s		_RBAOk
		sub.w		#360,d0
_RBAOk		move.w		d0,-2(a0)		save new value
		dbra		d1,_RBALoop
		movem.l		(sp)+,d0-d1/a0-a1
		rts


;		*************************************************
;		*		Draw A Rotated Object		*
;		*************************************************

; Entry		a0->bitplane
;		a1->Object
;		d0=bitplane width in bytes

DrawObject	PUSHALL

		move.l		d0,d4			safe register

		move.l		obj_Surface(a1),a2	a2->Surfaces
		
		moveq.l		#0,d7
		move.w		obj_Count(a1),d7
		subq.w		#1,d7			surface counter

; deal with next surface, should test normal at this point

_ConnectLoop	bsr		DrawSurface
		dbra		d7,_ConnectLoop

		PULLALL
		rts

;		*************************************************
;		*		Draw A Single Surface		*
;		*************************************************


; Entry		a0->BitPlane
;		a1->Object
;		a2->Object Surface
;		d0=bitplane width

; Exit		a2->Next Surface

; Corrupt	a2

DrawSurface	movem.l		d0-d5/a0-a1/a3-a5,-(sp)

		move.l		d0,d4

		move.l		obj_XY(a1),a3		a3->Point list
		moveq.l		#0,d5			clear counter
		move.w		(a2)+,d5		get value
		subq.l		#2,d5			dbra adjust

; Check if surface should be drawn

		bsr		CheckSurface
		tst.l		d0
		bmi.s		_DrawSurface

	; Surface is hidden, bump a2 and exit
	
		addq.l		#2,d5
		asl.w		#1,d5			x2
		adda.l		d5,a2
		bra.s		_DSDone
		
; Clear all required registers

_DrawSurface	moveq.l		#0,d0
		moveq.l		#0,d1
		moveq.l		#0,d2
		moveq.l		#0,d3

		move.w		(a2)+,d1		point number
		asl.w		#2,d1			x4=offset
		move.w		0(a3,d1.w),d0		x1
		move.w		2(a3,d1.w),d1		y1

_DSLoop		move.w		(a2)+,d3
		asl.w		#2,d3
		move.w		0(a3,d3.w),d2		x2
		move.w		2(a3,d3.w),d3		y2
		bsr		BlitLine		draw the line
		move.w		d2,d0
		move.w		d3,d1
		dbra		d5,_DSLoop

_DSDone		movem.l		(sp)+,d0-d5/a0-a1/a3-a5
		rts

;		*************************************************
;		*	    Check if surface is visible		*
;		*************************************************

; calculates dot product of two edges of surface. If result is +ve, it is
;facing away from the viewer and need not be drawn.

; Entry		a2->surface
;		a3->Points

; Exit		d0=+ve if surface is visible

; Corrupt	d0

CheckSurface	PUSH		d1-d5/a2

		move.w		(a2)+,d1
		move.w		(a2)+,d3
		move.w		(a2)+,d5
		asl.w		#2,d1
		asl.w		#2,d3
		asl.w		#2,d5
		
		move.w		0(a3,d1.w),d0		x1
		move.w		2(a3,d1.w),d1		y1
		move.w		0(a3,d3.w),d2		x2
		move.w		2(a3,d3.w),d3		y2
		move.w		0(a3,d5.w),d4		x3
		move.w		2(a3,d5.w),d5		y3

		sub.w		d2,d4			d4=v2.x: x3-x2
		sub.w		d0,d2			d2=v1.x: x2-x1
		sub.w		d3,d5			d5=v2.y: y3-y2
		sub.w		d1,d3			d3=v1.y: y2-y1
		muls		d2,d5			d5=v1.x*v2.y
		muls		d3,d4			d4=v2.x*v1.y
		sub.l		d4,d5

		move.l		d5,d0			direction (+ or -)

		PULL		d1-d5/a2
		rts

;		*************************************************
;		*	    Produce Plottable Points		*
;		*************************************************

; Do perspective and clipping on an object, creating a list of plottable x,y
;coordinates.

; Entry		a0->Object

; Exit		None

; Corrupt	d0

;ClipObject	PUSHALL

		move.w		obj_Ox(a0),d5
		move.w		obj_Oy(a0),d6

		move.l		obj_XY(a0),a1		store clip points
		move.l		obj_RotPoints(a0),a0	rotated points
		moveq.l		#0,d7			point counter
		move.w		(a0)+,d7
		subq.w		#1,d7

; at present simply copy x,y coords from rotated points list into plottable
;points list, adding the center of rotation as we go.

;_COLoop		move.w		(a0)+,d0		get x coord
		add.w		d5,d0			map to screen
		move.w		d0,(a1)+		and save
		
		move.w		(a0)+,d1		get y coord
		move.w		d6,d0			center
		sub.w		d1,d0			map to screen
		move.w		d0,(a1)+		and save
		
		addq.l		#2,a0			skip z coord
		
		dbra		d7,_COLoop		for all coords

		PULLALL
		rts


;		*************************************************
;		*	    Produce Plottable Points		*
;		*************************************************

; Do perspective and clipping on an object, creating a list of plottable x,y
;coordinates.

; Entry		a0->Object

; Exit		None

; Corrupt	d0

ClipObject	PUSHALL

		move.w		obj_Ox(a0),d3
		move.w		obj_Oy(a0),d4
		move.w		obj_ZDist(a0),d0	distance from screen

		move.l		obj_XY(a0),a1		store clip points
		move.l		obj_RotPoints(a0),a0	rotated points
		move.w		(a0)+,d7
		subq.w		#1,d7

		lea		PerspTable,a2
		add.w		d0,d0
		lea		0(a2,d0.w),a2		perspective offset

; at present simply copy x,y coords from rotated points list into plottable
;points list, adding the center of rotation as we go.

_COLoop		move.w		(a0)+,d0
		move.w		(a0)+,d1
		move.w		(a0)+,d2
		neg.w		d2
		and.b		#$fe,d2
		
; Get scaling factor for this point based on its z coordinate

		move.w		0(a2,d2.w),d5		scale value for point

; Apply to the x co-ordinate and add objects x offset

		muls		d5,d0
		swap		d0
		add.w		d3,d0
		
; Apply to the y co-ordinate and add objects y offset

		muls		d5,d1
		swap		d1
		move.w		d4,d2
		sub.w		d1,d2

; Save results

		move.w		d0,(a1)+
		move.w		d2,(a1)+
		
		dbra		d7,_COLoop

		PULLALL
		rts

;		*************************************************
;		*	  Rotate All Points In Object		*
;		*************************************************
 
; Entry		a0->Object

; Exit		none

; corrupt	d0

RotateObject	PUSHALL

		move.l		obj_RotPoints(a0),a1	a1->space for rotate
		move.l		obj_Points(a0),a0	a0->original points
		bsr		RotatePoints		rotate it

		PULLALL
		rts
		
;		*************************************************
;		*	Routine to rotate points about X,Y,Z 	*
;		*************************************************

; Subroutine to rotate an object in three D. Routine adapted from original by
;Shadow.

; Entry		a0->Initial Object
;		a1->rotated object
;		d0=number of points

RotatePoints	PUSHALL

; Start by pre-calculating sine & cosine of rotation angles

		lea		rtpreTrig,a3
		move.w		Z_Angle,d0
		bsr		Trig
		move.w		d1,razSin(a3)
		move.w		d2,razCos(a3)
		move.w		Y_Angle,d0
		bsr		Trig
		move.w		d1,raySin(a3)
		move.w		d2,rayCos(a3)
		move.w		X_Angle,d0
		bsr		Trig
		move.w		d1,raxSin(a3)
		move.w		d2,raxCos(a3)

; Second entry point to rotate an object through same angles as previous one
;with less processor overhead.

RotateAgain	lea		rtpreTrig,a3
		moveq.l		#0,d0
		move.w		(a0)+,d0
		move.w		d0,(a1)+
		subq.w		#1,d0			dbcc adjust
rloop		move.w		razSin(a3),d1
		move.w		razCos(a3),d5
		move.w		_pX(a0),d3
		muls.w		d3,d5		5 Xcz
		move.w		_pY(a0),d3
		muls.w		d3,d1		1 Ysz
		sub.l		d1,d5		5 Xcz-Ysz
		lsr.l		#8,d5
		lsr.l		#6,d5
		move.w		razSin(a3),d1
		move.w		razCos(a3),d6
		move.w		_pX(a0),d3
		muls.w		d3,d1		1 Xsz
		move.w		_pY(a0),d3
		muls.w		d3,d6		6 Ycz
		add.l		d1,d6		6 Xsz+Ycz
		lsr.l		#8,d6
		lsr.l		#6,d6
		move.w		raySin(a3),d1
		move.w		rayCos(a3),d7
		move.w		_pZ(a0),d3
		neg.w		d3
		muls.w		d3,d7		7 -Zcy
		muls.w		d5,d1		1 sy(Xcz-Ysz)
		sub.l		d1,d7		7 -Zcy-sy(Xcz-Ysz)
		lsr.l		#8,d7
		lsr.l		#6,d7
		move.w		raySin(a3),d1
		move.w		rayCos(a3),d2
		move.w		_pZ(a0),d3
		muls.w		d3,d1		1 Zsy
		muls.w		d5,d2		2 cy(Xcz-Ysz)
		sub.l		d1,d2		2 cy(Xcz-Ysz)-Zsy
		lsr.l		#8,d2
		lsr.l		#6,d2
		move.w		d2,d5		5 cy(Xcz-Ysz)-Zsy
		move.w		raxSin(a3),d1
		move.w		raxCos(a3),d2
		move.w		d6,d4		4 Xsz+Ycz
		muls.w		d6,d2		2 cx(Xsz+Ycz)
		muls.w		d7,d1		1 sx(-Zcy-sy(Xcz-Ysz))
		sub.l		d1,d2		2 cx(Xsz+Ycz)-sx(-Zcy-sy(Xcz-Ysz))
		lsr.l		#8,d2
		lsr.l		#6,d2
		move.w		d2,d6		6 cx(Xsz+Ycz)-sx(-Zcy-sy(Xcz-Ysz))
		move.w		raxSin(a3),d1
		move.w		raxCos(a3),d2
		muls.w		d4,d1		1 sx(Xsz+Ycz)
		muls.w		d7,d2		2 cx(-Zcy-sy(Xcz-Ysz))
		add.l		d1,d2		2 cx(-Zcy-sy(Xcz-Ysz))+sx(Xsz+Ycz)
		neg.w		d2
		lsr.l		#8,d2
		lsr.l		#6,d2
		move.w		d2,d7		7 cx(-Zcy-sy(Xcz-Ysz))+sx(Xsz+Ycz)
		move.w		d5,(a1)+
		move.w		d6,(a1)+
		move.w		d7,(a1)+

		addq.l		#_pNext,a0		a0->next set of points

		dbra		d0,rloop

		PULLALL
		rts

rtpreTrig	ds.w		6

**************************************************
*	get sin/cos value for angle in d0	 *
**************************************************

Trig		move.l		a1,-(sp)
		tst.w		d0
		bpl.s		_trig1
		add.w		#360,d0
_trig1		lea		_sintab,a1
		move.l		d0,d2
		lsl.w		#1,d0
		move.w		0(a1,d0),d1
		cmp.w		#270,d2
		ble.s		_trig2
		sub.w		#270,d2
		bra.s		_trig3
_trig2		add.w		#90,d2
_trig3		lsl.w		#1,d2
		move.w		0(a1,d2),d2
		move.l		(sp)+,a1
		rts

;		***************************
;		*        Blit Line	  *
;		***************************

; Line drawing routine as recommended in HRM. Alterations are as follows:

; corrected address being formed by adding word to long word address.
; allowed for pattern drawing
; can vary drawing mode

DMODE_SET	equ		$fa
DMODE_EOR	equ		$4a
DMODE_OR	equ		$ca

; Entry		d0=x1
;		d1=y1
;		d2=x2
;		d3=y2
;		d4=width of bitplane in bytes
;		a0->start of bitplane

; Exit		same

; Corrupt	none

BlitLine	PUSHALL

		sub.w		d0,d2			dx
		bmi.s		_xneg
		sub.w		d1,d3
		bmi.s		_yneg
		cmp.w		d3,d2
		bmi.s		_ygtx
		moveq.l		#OCTANT1!1,d5		in octant 1
		bra.s		_again

_ygtx		exg		d2,d3
		moveq.l		#OCTANT2!1,d5		in Octant 2
		bra.s		_again

_yneg		neg.w		d3
		cmp.w		d3,d2
		bmi.s		_ynygtx
		moveq.l		#OCTANT8!1,d5		in Octant 8
		bra.s		_again

_ynygtx		exg		d2,d3
		moveq.l		#OCTANT7!1,d5		in Octant 7
		bra.s		_again

_xneg		neg.w		d2
		sub.w		d1,d3
		bmi.s		_xyneg
		cmp.w		d3,d2
		bmi.s		_xnygtx
		moveq.l		#OCTANT4!1,d5		in Octant 4
		bra.s		_again

_xnygtx		exg		d2,d3
		moveq.l		#OCTANT3!1,d5		in Octant 3
		bra.s		_again

_xyneg		neg.w		d3
		cmp.w		d3,d2
		bmi.s		_xynygtx
		moveq.l		#OCTANT5!1,d5		in Octant 5
		bra.s		_again

_xynygtx	exg		d2,d3
		moveq.l		#OCTANT6!1,d5		in Octant 2

_again		mulu.w		d4,d1
		ror.l		#4,d0
		add.w		d0,d0
		add.l		d1,a0
		moveq.l		#0,d6
		move.w		d0,d6
		add.l		d6,a0
		swap		d0
		or.w		#$b00,d0
		move.b		_DMode,d0		get draw mode
		lsl.w		#2,d3
		add.w		d2,d2
		move.w		d2,d1
		lsl.w		#5,d1
		add.w		#$42,d1
		btst		#14,DMACONR(a5)
_lw		btst		#14,DMACONR(a5)
		bne.s		_lw

		move.w		d3,BLTBMOD(a5)
		sub.w		d2,d3
		ext.l		d3
		move.l		d3,BLTAPTH(a5)
		bpl.s		_okl
		or.w		#$40,d5			set sign bit

_okl		move.w		d0,BLTCON0(a5)
		move.w		d5,BLTCON1(a5)
		move.w		d4,BLTCMOD(a5)
		move.w		d4,BLTDMOD(a5)
		sub.w		d2,d3
		move.w		d3,BLTAMOD(a5)
		move.w		#$8000,BLTADAT(a5)
		move.w		#$ffff,BLTBDAT(a5)	line pattern
		move.l		#-1,BLTAFWM(a5)
		move.l		a0,BLTCPTH(a5)
		move.l		a0,BLTDPTH(a5)
		move.w		d1,BLTSIZE(a5)

		PULLALL
		rts

_DMode		dc.b		DMODE_OR
		even

*************************************************
*		data for sintable		*
*************************************************

_sintab		dc.w 0,286,572,857,1143,1428,1713,1997,2280
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

PerspTable	incbin		perspective.bm

