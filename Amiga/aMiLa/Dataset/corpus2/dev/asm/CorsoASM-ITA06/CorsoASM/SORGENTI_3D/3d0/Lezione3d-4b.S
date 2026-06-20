
BLTCON0		EQU	$DFF040
BLTCON1		EQU	$DFF042
BLTAFWM		EQU	$DFF044
BLTALWM		EQU	$DFF046
BLTAPT		EQU	$DFF050
BLTBPT		EQU	$DFF04C
BLTCPT		EQU	$DFF048
BLTDPT		EQU	$DFF054
BLTSIZE		EQU	$DFF058
BLTAMOD		EQU	$DFF064
BLTBMOD		EQU	$DFF062
BLTCMOD		EQU	$DFF060
BLTDMOD		EQU	$DFF066
BLTADAT		EQU	$DFF074
BLTBDAT		EQU	$DFF072
DMACONR		EQU	$DFF002


	Section Boot_Menu,Code

Start:
	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVE.L	A7,InitialSP
	BSR.s	KillOS
	BSR.w	SetUp
	BSR.w	MainRoutine
	BSR.w	HelpOS
	MOVE.L	InitialSP(PC),A7
	MOVEM.L	(A7)+,D0-D7/A0-A6
	MOVE.W	Selector(PC),D5
	RTS

*************************************************************************
*	   Turn Off All Multi-Tasking & Operating System Tasks		*
*************************************************************************

KillOS:
	MOVE.L	$4.w,A6
	moveq	#0,d0
	LEA	GFXLib(PC),A1
	JSR	-552(A6)		_LVOOpenLibrary
	MOVE.L	D0,GFXBase
	JSR	-132(A6)		_LVOForbid
	JSR	-150(A6)		_LVOSuperState
	MOVE.L	D0,SYSStack
	MOVE.W	$DFF01C,IntEnSave
	MOVE.W	$DFF01E,IntRqSave
	MOVE.W	$DFF002,DMASave
	MOVE.W	$DFF010,ADKSave
	MOVE.W	#%0111111111111111,$DFF096
	MOVE.W	#%0111111111111111,$DFF09A
	MOVE.L	#CopperList,$DFF080
	move.W	#0,$DFF088
	move.w	#0,$dff1fc
	move.l	#0,$dff108
	move.w	#$c00,$dff106
	MOVE.W	#%1000001001000000,$DFF096
	RTS

************************************************************************
*             Set Up - Clear BitPlanes Used For Display                *
************************************************************************

SetUp:
	MOVE.W	#%1000011111100000,$DFF096
	RTS

*************************************************************************
*	   Restore All Multi-Tasking & Operating System Tasks		*
*************************************************************************

HelpOS:
	MOVE.W	#0,$DFF0A8
	MOVE.W	#0,$DFF0B8
	MOVE.W	#0,$DFF0C8
	MOVE.W	#0,$DFF0D8
	MOVE.W	IntEnSave,D7
	BSET	#$F,D7
	MOVE.W	D7,$DFF09A
	MOVE.W	IntRqSave,D7
	BSET	#$F,D7
	MOVE.W	D7,$DFF09C
	MOVE.W	DMASave,D7
	BSET	#$F,D7
	MOVE.W	D7,$DFF096
	MOVE.W	ADKSave,D7
	BSET	#$F,D7
	MOVE.W	D7,$DFF09E
	MOVE.L	GFXBase,A0
	MOVE.L	$26(A0),$DFF080
	MOVE.L	$4,A6
	JSR	-138(A6)		_LVOPermit
	MOVE.L	SYSStack,D0		
	JSR	-156(A6)		_LVOUserState

	RTS

*************************************************************************
*	  Main Program Routine - Selecting of Program to Load		*
*************************************************************************

MainRoutine:
	MOVE.L	$DFF004,D0		Check VPOSR For Screen Position
	AND.L	#$1FF00,D0
	CMP.L	#$11000,D0
	BNE.S	MainRoutine
	ADDQ.W	#2,Xrot
	SUBQ.W	#3,Yrot
	ADDQ.W	#4,Zrot
	AND.W	#$1FE,Xrot
	AND.W	#$1FE,Yrot
	AND.W	#$1FE,Zrot
	BSR.W	SpinLogo
	BTST	#6,$BFE001		Check Left Mouse Button
	BNE.S	MainRoutine
	RTS
		
	
*************************************************************************
*			      3D Line Routine				*
*************************************************************************

SpinLogo:
	Move.l	Current(pc),d0
	LEA	VectorPtrs,A0
	Move.W	d0,6(A0)
	Swap	d0
	Move.W	d0,2(A0)
	MOVE.W	DBuffer(pc),D1
	EOR.W	#1,D1
	CMP.W	#1,D1
	BNE.S	Screen1
Screen2:
	MOVE.L	#VectorPlane1,D0
	BRA.S	SkipScr
Screen1:
	MOVE.L	#VectorPlane2,D0
SkipScr:
	MOVE.L	D0,Current
	MOVE.W	D1,DBuffer
	move.l	Current(pc),a0
	Move.l	#$1f00000,BLTCON0
	MOVE.L	A0,A4
;	ADD.w	#1408,A4
	Move.l	a4,BLTDPT
	move.w	#0,BLTADAT
	move.w	#0,BLTDMOD
	Move.W	#250*64+22,BLTSIZE

	Move.W	#No_points-1,d7
	Lea	Points(pc),a4	
	Lea	Sintable+$40(pc),a1
	Lea	Rotated_coords(pc),a2
	Lea	Perspective(pc),a3

TD_loop:
	Move.w	(a4)+,d0
	Move.w	d0,d2
	Move.w	(a4)+,d1
	Move.w	d1,d3

	Move.w	Zrot(pc),d6
	Move.w	$40(a1,d6),d4
	Move.w	-$40(a1,d6),d5
	Muls.w	d4,d0
	Muls.w	d5,d1
	Sub.l	d1,d0
	Add.l	d0,d0
	Swap	d0		;d0 holds intermediate x coord
	Muls.w	d5,d2
	Muls.w	d4,d3
	Add.l	d3,d2
	Add.l	d2,d2
	Swap	d2		;d2 holds intermediate y coord
	Move.w	d2,d4

	Move.w	(a4)+,d1	;z coord
	Move.w	d1,d3
	Move.w	Xrot(pc),d6
	Move.w	$40(a1,d6),d5
	Move.w	-$40(a1,d6),d6
	Muls.w	d5,d2
	Muls.w	d6,d1
	Sub.l	d1,d2
	Add.l	d2,d2
	Swap	d2		;d2 holds the final y coord
	Muls.w	d5,d3
	Muls.w	d6,d4
	Add.l	d4,d3
	Add.l	d3,d3
	Swap	d3		;d3 holds intermediate z coord

	Move.w	d0,d1
	Move.w	d3,d4
	Move.w	Yrot(pc),d6
	Move.w	$40(a1,d6),d5
	Move.w	-$40(a1,d6),d6
	Muls.w	d5,d3
	Muls.w	d6,d0
	Sub.l	d0,d3
	Add.l	d3,d3
	Swap	d3		;d3 holds the final z coord
	Muls.w	d6,d4
	Muls.w	d5,d1
	Add.l	d4,d1
	Add.l	d1,d1
	Swap	d1		;d1 holds the final x coord

	Add.w	Depth(pc),d3
	Add.w	d3,d3
	Move.w	(a3,d3),d5
	Muls.w	d5,d1
	Muls.w	d5,d2
	Add.l	d1,d1
	Swap	d1
	Add.w	#160,d1	; centro schermo X
	Add.l	d2,d2
	Swap	d2
	Add.w	#128,d2	; centro schermo Y
	
	Move.w	d1,(a2)+
	Move.w	d2,(a2)+
	Dbra	d7,TD_loop

	Move.w	#No_connects-1,d7
	Lea	$dff000,a5
	Lea	Connect(pc),a3
	Lea	Rotated_coords(pc),a4
	Moveq	#44,d0
	Lea	Mul40(pc),a1
	Lea	Bits(pc),a2
B_wait2:
	Btst.b	#14,DMACONR
	Bne.s	B_wait2

	Move.w	#$ffff,BLTAFWM
	Move.w	d0,BLTCMOD	;Bltcmod
	Move.w	d0,BLTDMOD	;Bltdmod
	Move.w	#$ffff,BLTBDAT	;Bltbdat
Draw_loop:
	Move.w	(a3)+,d6
	Move.w	(a4,d6),d0
	Move.w	2(a4,d6),d1
	Move.w	(a3)+,d6
	Move.w	(a4,d6),d2
	Move.w	2(a4,d6),d3
	Cmp.w	d0,d2
	Bne.s	Draw
	Cmp.w	d1,d3
	Beq.s	Nodraw	
Draw:
	Bsr.w	Line
Nodraw:
	Dbra	d7,Draw_loop
Bwit:
	Btst.b	#14,DMACONR
	Bne.s	Bwit
	Rts

Sintable:
	INCBIN	"Sin"
	INCBIN	"Sin"
Perspective:
	INCBIN	"Perspective"
Octant_table:
	Dc.b	1,17,9,21,5,25,13,29

;----------- Line Draw ------------
Line:
	Moveq	#0,d4
	Move.w	d1,d4
	Add.w	d4,d4
	Move.w	(a1,d4),d4
	Moveq	#-$10,d5
	And.w	d0,d5
	Lsr.w	#3,d5
	Add.w	d5,d4
	Add.l	a0,d4

	Moveq	#0,d5
	Sub.w	d1,d3
	Roxl.b	d5
	Tst.w	d3
	Bge.s	Y2gy1
	Neg.w	d3
Y2gy1:
	Sub.w	d0,d2
	Roxl.b	d5
	Tst.w	d2
	Bge.s	X2gx1
	Neg.w	d2
X2gx1:

	Move.w	d3,d1
	Sub.w	d2,d1
	Bge.s	Dygdx
	Exg	d2,d3
Dygdx:
	Roxl.b	d5
	Move.b	Octant_table(pc,d5),d5
	Add.w	d2,d2
Wblit:
	Btst.b	#14,DMACONR
	Bne.s	Wblit

	Move.w	d2,BLTBMOD	;Bltbmod
	Sub.w	d3,d2
	Bge.s	Signn1
	Or.b	#$40,d5
Signn1:
	Move.w	d2,BLTAPT+2	;Bltaptl
	Sub.w	d3,d2
	Move.w	d2,BLTAMOD	;Bltamod

	Move.w	#$8000,BLTADAT	;Bltadat
	Add.w	d0,d0
	Move.w	(a2,d0),BLTCON0	;Bltcon0
	Move.w	d5,BLTCON1	;Bltcon1
	Move.l	d4,BLTCPT	;Bltcpth
	Move.l	d4,BLTDPT	;Bltdpth
	Lsl.w	#6,d3
	Addq.w	#2,d3
	Move.w	d3,BLTSIZE	;Bltsize
	Rts


*************************************************************************
*	 Variables and Data Tables used throughout the program		*
*************************************************************************

SYSStack	DC.L	0
GFXBase		DC.L	0
InitialSP	DC.L	0
IntEnSave	DC.W	0	
IntRqSave	DC.W	0
DMASave		DC.W	0
ADKSave		DC.W	0
GFXLib		DC.B	"graphics.library",0,0
 even

Xrot		DC.W	$100
Yrot		DC.W	0
Zrot		DC.W	0
Depth		DC.W	200
Current:
		DC.L	VectorPlane0
Depthpt	DC.W	0
DBuffer	DC.W	1

LastYPos	DC.W	0
Selector	DC.W	0

Mul40
A set 0
	Rept	320
	Dc.w	A*44
A set A+1
	Endr

A set 0
Bits
	Rept	320
	Dc.w	((A&$f)*$1000)+$bca
A set A+1
	Endr

Size
A set 0
	Rept	320
	Dc.w	(A*64)+2
A set A+1
	Endr

No_points	=  8  
No_connects	=  12

Points:
	dc.w	-100,+100,-100	; P0 (X,Y,Z)
	dc.w	+100,+100,-100	; P1 (X,Y,Z)
	dc.w	+100,-100,-100	; P2 (X,Y,Z)
	dc.w	-100,-100,-100	; P3 (X,Y,Z)
	dc.w	-100,+100,+100	; P4 (X,Y,Z)
	dc.w	+100,+100,+100	; P5 (X,Y,Z)
	dc.w	+100,-100,+100	; P6 (X,Y,Z)
	dc.w	-100,-100,+100	; P7 (X,Y,Z)


Connect:		; (moltiplicati *4 per routine che salta...)
	dc.w	0*4,1*4	; faccia davanti
	dc.w	1*4,2*4
	dc.w	2*4,3*4
	dc.w	3*4,0*4

	dc.w	4*4,5*4	; faccia dietro
	dc.w	5*4,6*4
	dc.w	6*4,7*4
	dc.w	7*4,4*4

	dc.w	0*4,4*4	; spigoli laterali
	dc.w	1*4,5*4
	dc.w	2*4,6*4
	dc.w	3*4,7*4

; -------------------

Rotated_coords:
	Dcb.w	No_points*2,0


	Section	grafic,data_C

*************************************************************************
*	  New Copper-List to Replace old WorkBench Copper-List		*
*************************************************************************

CopperList:
		DC.L	$008E2c81
		DC.L	$00902CC1
		DC.L	$00920030
		DC.L	$009400D8
		DC.L	$01001200
		DC.L	$01040000
		dc.l	$01020001
		dc.w	$108,0
		dc.w	$10a,0
SpritePtrs:
		DC.L	$01200000,$01220000,$01240000,$01260000
		DC.L	$01280000,$012A0000,$012C0000,$012E0000
		DC.L	$01300000,$01320000,$01340000,$01360000
		DC.L	$01380000,$013A0000,$013C0000,$013E0000
		DC.L	$01800002,$018200fa
VectorPtrs:
		DC.L	$00E00000,$00E20000
		DC.L	$FFFFFFFE   

	section	buffs,bss_C

VectorPlane0:
	ds.b	$8000
VectorPlane1:
	ds.b	$4000
VectorPlane2:
	ds.b	$4000

	end

