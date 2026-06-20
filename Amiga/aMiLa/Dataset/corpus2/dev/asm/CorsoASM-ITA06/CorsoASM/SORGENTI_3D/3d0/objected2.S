****************************************************************************
; Basato sul Vector Object Editor by BTG of PSI 1993
;
; Addictional coding by Randy of NA^CMX
****************************************************************************

	SECTION	ObjectED,CODE

ProgStart:
	MOVEA.L	4.W,A6
	JSR	-$84(A6)
	JSR	-$78(a6)
	LEA	POINTER1(PC),A0		; point planes
	MOVE.L	#Double1,D0
	MOVE.W	D0,2(A0)
	SWAP	D0
	MOVE.W	D0,(A0)
	LEA	POINTER2(PC),A0
	MOVE.L	#Double2,D0
	MOVE.W	D0,2(A0)
	SWAP	D0
	MOVE.W	D0,(A0)

	MOVEA.L	4.w,A6			; open gfxlib
	LEA	graphicslibra(PC),A1
	JSR	-$198(A6)
	MOVE.L	D0,GFXBASE

	LEA	$DFF000,A6		; save dma
	MOVE.W	#$8000,olddma
	MOVE.W	#$8000,oldintena
	MOVE.W	2(A6),D0
	OR.W	D0,olddma
	MOVE.W	#$7FFF,$96(A6)
	MOVE.W	$1C(A6),D0
	OR.W	D0,oldintena

	MOVE.W	#$87D0,$96(A6)
	BSR.W	READMOUSE
	CLR.L	MOUSEXVAR
	MOVE.L	#$DAC,D3_Zoom

pointcop2:
	BTST	#0,5(A6)
	BEQ.S	pointcop2
	MOVE.L	#copper2,$80(A6)	; point cop
	move.W	d0,$88(A6)
	MOVE.W	#$87D0,$96(A6)

FRAMELOOP:
	BTST	#0,5(A6)
;	BEQ.S	FRAMELOOP

ANIMATE:
	MOVE.L	4(a6),D0	; $DFF004
	LSR.L	#8,D0
	ANDI.W	#%111111111,D0	; Select only the VPOS bits
	CMPI.W	#$136,D0	; wait line 304 (311)
	BNE.s	ANIMATE

;	CMPI.B	#$FF,6(A6)	;wait blank
;	BNE.S	ANIMATE

	BSR.W	SWAPSCREENS
	BSR.W	CLEARSCREEN
	BSR.W	Viewer_Sphere
	BSR.W	D3_VIEW
	BSR.W	READMOUSE
	BSR.W	RotateOrZoom
	BSR.W	GETKEY
	CMPI.B	#$12,D0		; E - quit animation mode
	BNE.S	ANIMATE
Waitblitx:
	BTST	#6,2(A6)	;
	BNE.S	Waitblitx
	MOVE.W	#1,lbW00015E
	LEA	$DFF000,A6
	MOVE.W	#$87D0,$96(A6)

EXITPROG:
	BTST	#6,2(A6)	; Wait blit
	BNE.S	EXITPROG

	MOVEA.L	GFXBASE(PC),A5	; restore old cop
	MOVE.L	$26(A5),$80(A6)
	MOVE.W	d0,$88(A6)

	MOVE.W	olddma(PC),$96(A6)	; restpre dma
	MOVE.W	oldintena(PC),$9A(A6)

	MOVEA.L	4.w,A6			; CLOSEGFX
	MOVEA.L	GFXBASE(PC),A1
	JSR	-$19E(A6)

	MOVEA.L	4.W,A6
	JSR	-$8A(A6)
	JSR	-$7e(A6)
	MOVEQ	#0,D0
	RTS


olddma:
	dc.w	$8000
oldintena:
	dc.w	$8000

graphicslibra:
	dc.b	'graphics.library',0,0
GFXBASE:
	dc.l	0

lbW00015E:
	dc.w	1
lbW000160:
	dc.w	0
lbW000162:
	dc.w	0
lbW000164:
	dc.w	4
lbW000166:
	dc.w	0
XCOORD:
	dc.w	0
YCOORD:
	dc.w	0
YCOORD2:
	dc.w	0
EXITFLAG:
	dc.w	0



RotateOrZoom:
	BTST	#2,$16(A6)	; right mouse? (mouse Y + or - is zoom val!)
	BNE.S	noright
	ADDI.L	#32,D3_Zoom
	bra.s	zoomend
noright:
	btst	#6,$bfe001
	bne.s	zoomend
	SUBi.L	#32,D3_Zoom
	CMPI.L	#$C8,D3_Zoom
	BPL.s	zoomend
	MOVE.L	#$C8,D3_Zoom
zoomend:
	MOVE.W	MOUSEXVAR(PC),D0 ;no right, just rotate!
	ADD.W	D0,degr
	MOVE.W	MOUSEYVAR(PC),D0
	ADD.W	D0,degn
	ANDI.W	#$1FF,degr
	ANDI.W	#$1FF,degn
	RTS


GETKEY:
	MOVE.B	$BFEC01,D0
	bset	#6,$bfee01      ;output
	clr.b	$bfec01
	bclr	#6,$bfee01      ;input again
	NOT.B	D0
	ROR.B	#1,D0
	RTS

READMOUSE:
	MOVE.W	$A(A6),D0	; JOY0DAT - MOUSE: BITS 0-7=X, BITS 8-15=Y
	MOVE.B	MOUSEX(PC),D1
	MOVE.B	MOUSEY(PC),D2
	MOVE.B	D0,MOUSEX
	MOVE.W	D0,D3
	LSR.W	#8,D3
	MOVE.B	D3,MOUSEY
	SUB.B	D1,D0
	SUB.B	D2,D3
	EXT.W	D0
	EXT.W	D3
	MOVE.W	D0,MOUSEXVAR
	MOVE.W	D3,MOUSEYVAR
	RTS

MOUSEX:
	dc.b	0
MOUSEY:
	dc.b	0
MOUSEXVAR:
	dcb.b	$2,0
MOUSEYVAR:
	dc.w	0



;*************************
;* LR by BTG on 17.03.91 *
;*************************
; bsr Viewer_Sphere to get in orbit around object
; bsr D3_View to plot calculated object in 3D-Wire
; See Obj_Data how an object is structered

;*** Viewer on orbit by degr,degn,degk

Viewer_Sphere:
	move.w	degr(pc),d0
	add.w	d0,d0
	move.w	degn(pc),d1
	add.w	d1,d1
	lea	cos(pc),a0	; costab -> a0
	lea	256(a0),a1	; sintab -> a1
	lea	xvie(pc),a2
	move.w	0(a1,d0.w),d3	; Sin degr
	move.w	0(a1,d1.w),d5	; Sin Degn
	move.w	0(a0,d0.w),d2	; Cos degr
	move.w	0(a0,d1.w),d4	; Cos degn

	move.w	d3,d6
	muls	d4,d6
	swap	D6		;equals asr.l #14,Dx
	rol.l	#2,D6		;
	ext.l	D6		;
	asr.w	#8,d6
	neg.w	d6
	move.w	d6,(a2)

	move.w	d5,d6
	asr.w	#8,d6
	move.w	d6,2(a2)

	move.w	d2,d6
	ext.l	d6
	muls	d4,d6
	swap	D6		;equals asr.l #14,Dx
	rol.l	#2,D6		;
	ext.l	D6		;
	asr.w	#8,d6
	neg.w	d6
	move.w	d6,4(a2)
	rts

D3_Zoom:
	dc.l	$7D0

D3_VIEW:
	bsr	TD_Transform	; init Matrix
	movea.l	D3_ObjData(pc),a5
	movea.l	(a5),a5		; Pnt to PointData
	LEA	d3_TransData,A4
	LEA	xpos(PC),A3
	move.l	#[4*52],d7
	move.l	#287/2,d6
D3_CalcZero:
	clr.w	(a3)
	clr.w	2(a3)
	clr.w	4(a3)
	BSR.W	td_make3dpoint
	NEG.W	x3d
	NEG.W	y3d
	MOVE.W	x3d(PC),D3_Centre
	MOVE.W	y3d(PC),D3_Centre+2
D3_LOOP:
	CMPI.W	#$FFFF,(A5)
	BEQ.S	D3_GENEND
	MOVE.W	(A5)+,(A3)
	MOVE.W	(A5)+,2(A3)
	MOVE.W	(A5)+,4(A3)
	BSR.W	td_make3dpoint

	MOVE.W	x3d(PC),D0
	ADD.W	D7,D0
	MOVE.W	D0,(A4)+
	MOVE.W	y3d(PC),D0
	ADD.W	D6,D0
	MOVE.W	D0,(A4)+

	BRA.S	D3_LOOP

D3_GENEND:
	movea.l	D3_ObjData(pc),a5	; lea if data direct
	movea.l	4(a5),a5
	lea	D3_TransData,a4
	lea	D3_Centre(pc),a3
D3_PLOTLOOP:
	move.w	#52,a1
	tst.w	Switch
	bne.s	D3_Scr2nd
	lea	Double1,a0
	bra.s	D3_Scr1st
D3_Scr2nd:
	lea	Double2,a0
D3_Scr1st:
	move.w	#$ffff,a2
	move.w	(a5)+,d4
	cmp.w	#$ffff,d4
	beq.s	D3_END
	add.w	d4,d4
	add.w	d4,d4
	move.w	(a4,d4.w),d0
	move.w	2(a4,d4.w),d1
	add.w	(a3),d0
	add.w	2(a3),d1
	move.w	(a5)+,d4
	add.w	d4,d4
	add.w	d4,d4
	move.w	(a4,d4.w),d2
	move.w	2(a4,d4.w),d3
	add.w	(a3),d2
	add.w	2(a3),d3
	bsr	Drawline
	bra.s	D3_PLOTLOOP
D3_END:
	rts

D3_Centre:
	dc.w	0,0
D3_Objdata:
	dc.l	OBJ_DATA

;*** Object Data

OBJ_DATA:
	DC.L	cmx2_POINTS
	DC.L	cmx2_LINES
	DC.L	0

cmx2_POINTS:
	DC.W	-1210,540,0,-790,540,0,-870,410,0,-1110,410,0
	DC.W	-1210,260,0,-1210,40,0,-1080,-70,0,-870,-70,0
	DC.W	-790,-200,0,-1230,-200,0,-1390,-60,0,-1390,430,0
	DC.W	-790,40,0,-690,-70,0,-500,-70,0,-430,40,0
	DC.W	-430,280,0,-510,370,0,-1220,540,0,-700,370,0
	DC.W	-390,690,0,-390,-300,0,-160,100,0,70,-270,0
	DC.W	70,700,0,-30,570,0,-40,120,0,-160,340,0
	DC.W	-270,130,0,-280,570,0,180,540,0,410,-250,0
	DC.W	620,540,0,480,470,0,430,270,0,360,270,0
	DC.W	290,470,0,180,530,0,360,170,0,420,170,0
	DC.W	400,70,0,750,570,0,910,570,0,1050,250,0
	DC.W	1170,580,0,1340,580,0,1170,200,0,1340,-220,0
	DC.W	1180,-220,0,1050,90,0,900,-210,0,750,-220,0
	DC.W	920,190,0,750,560,0,-790,280,0,-470,730,460
	DC.W	-470,650,750,-470,880,750,-470,720,460,-980,-870,-690
	DC.W	-980,-970,-490,-980,-690,-460,850,950,-750,850,1160,-950
	DC.W	850,1250,-700,1120,-730,850,1000,-730,1100,1280,-730,1100
	DC.W	-450,-370,-750,-590,-370,-530,-310,-370,-530,-460,-370,-760
	DC.W	-1330,870,520,-1130,870,260,-1050,870,630,-1340,870,520
	DC.W	-50,80,800,100,80,1040,160,80,760,-130,1060,-720
	DC.W	-20,1060,-940,-300,1060,-910,-1010,-1010,550,-1010,-870,380
	DC.W	-1010,-790,670,980,-880,-240,1130,-880,-490,1250,-880,-120
	DC.W	-1
cmx2_LINES:
	DC.W	0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8
	dc.w	8,9,9,10,10,11,12,13,13,14,14,15,15,16,16,17
	DC.W	11,18,20,21,21,22,22,23,23,24,24,25,25,26,26,27
	DC.W	27,28,28,29,29,20,30,31,31,32,32,33,33,34,34,35
	DC.W	35,36,36,37,38,39,39,40,40,38,41,42,42,43,43,44
	DC.W	44,45,45,46,46,47,47,48,48,49,49,50,50,51,51,52
	DC.W	52,53,19,54,54,12,17,19,55,56,56,57,57,58,59,60
	DC.W	60,61,61,59,62,63,63,64,64,62,65,66,66,67,67,65
	DC.W	68,69,69,70,70,71,72,73,73,74,74,75,76,77,77,78
	DC.W	79,80,80,81,81,79,78,76,82,83,83,84,84,82,85,86,86,87,87,85
	DC.W	-1


; 1. td_transform     |  result in x3d,y3d,z3d
; 2. td_make3dpoint   |  viewer in xvie,yvie,zvie
;    td_turnpoint     |  viedeg in degn,degr,degk 
;    td_perspective   |  point  in xpos,ypos,zpos
;    td_movepoint


TD_Transform:
	move.w	degn(pc),d0
	move.w	degr(pc),d1
	move.w	degk(pc),d2
	add.w	d0,d0
	add.w	d1,d1
	add.w	d2,d2
	lea	cos(pc),a1 	
	lea	256(a1),a0	; sin=cos+90
	movea.w	0(a0,d0.w),a2
	movea.w	0(a0,d1.w),a3
	movea.w	0(a0,d2.w),a4
	lea	sinn(pc),a5
	move.w	a2,(a5)		; sinn
	move.w	a3,2(a5)	; sinr
	move.w	a4,4(a5)	; sink
	movea.w	0(a1,d0.w),a2
	movea.w	0(a1,d1.w),a3
	movea.w	0(a1,d2.w),a4
	move.w	a2,6(a5)	; cosn
	move.w	a3,8(a5)	; cosr
	move.w	a4,10(a5)	; cosk
	lea	TM+00(pc),a5	; base for transformation
	moveq	#0,d0
	moveq	#0,d1
	move.w	sinn(pc),d0		; TM (0,0)
	muls.w	sinr(pc),d0
	swap	D0		;equals asr.l #14,Dx
	rol.l	#2,D0		;
	ext.l	D0		;
	muls	sink(pc),d0
	swap	D0		;equals asr.l #14,Dx
	rol.l	#2,D0		;
	ext.l	D0		;
	move.w	cosk(pc),d1
	muls	cosr(pc),d1
	swap	D1		;equals asr.l #14,Dx
	rol.l	#2,D1		;
	ext.l	D1		;
	add.w	d1,d0
	move.w	d0,(a5)
	moveq	#0,d0
	moveq	#0,d1
	move.w	sinn(pc),d0		; TM (0,1)
	muls	cosk(pc),d0
	swap	D0		;equals asr.l #14,Dx
	rol.l	#2,D0		;
	ext.l	D0		;
	muls	sinr(pc),d0
	swap	D0		;equals asr.l #14,Dx
	rol.l	#2,D0		;
	ext.l	D0		;
	move.w	sink(pc),d1
	muls	cosr(pc),d1
	swap	D1		;equals asr.l #14,Dx
	rol.l	#2,D1		;
	ext.l	D1		;
	sub.w	d1,d0
	move.w	d0,2(a5)
	moveq	#0,d0
	move.w	sinr(pc),d0		;TM (0,2)
	muls	cosn(pc),d0
	swap	D0		;equals asr.l #14,Dx
	rol.l	#2,D0		;
	ext.l	D0		;
	move.w	d0,4(a5)
	moveq	#0,d0
	move.w	sink(pc),d0		;TM (1,0)
	muls	cosn(pc),d0
	swap	D0		;equals asr.l #14,Dx
	rol.l	#2,D0		;
	ext.l	D0		;
	move.w	d0,6(a5)
	moveq	#0,d0
	move.w	cosk(pc),d0		;TM (1,1)
	muls	cosn(pc),d0
	swap	D0		;equals asr.l #14,Dx
	rol.l	#2,D0		;
	ext.l	D0		;
	move.w	d0,8(a5)
	moveq	#0,d0
	move.w	sinn(pc),d0		;TM (1,2)
	neg.w	d0
	move.w	d0,10(a5)
	moveq	#0,d0
	moveq	#0,d1
	move.w	sinn(pc),d0		;TM (2,0)
	muls	sink(pc),d0
	rol.l	#2,D0		;
	ext.l	D0		;
	muls	cosr(pc),d0
	swap	D0		;equals asr.l #14,Dx
	rol.l	#2,D0		;
	ext.l	D0		;
	move.w	sinr(pc),d1
	muls	cosk(pc),d1
	swap	D1		;equals asr.l #14,Dx
	rol.l	#2,D1		;
	ext.l	D1		;
	sub.w	d1,d0
	move.w	d0,12(a5)
	moveq	#0,d0
	moveq	#0,d1
	move.w	sinn(pc),d0		;TM (2,1)
	muls	cosk(pc),d0
	swap	D0		;equals asr.l #14,Dx
	rol.l	#2,D0		;
	ext.l	D0		;
	muls	cosr(pc),d0
	swap	D0		;equals asr.l #14,Dx
	rol.l	#2,D0		;
	ext.l	D0		;
	move.w	sink(pc),d1
	muls	sinr(pc),d1
	swap	D1		;equals asr.l #14,Dx
	rol.l	#2,D1		;
	ext.l	D1		;
	add.w	d1,d0
	move.w	d0,14(a5)
	moveq	#0,d0
	move.w	cosn(pc),d0		;TM (2,2)
	muls	cosr(pc),d0
	swap	D0		;equals asr.l #14,Dx
	rol.l	#2,D0		;
	ext.l	D0		;
	move.w	d0,16(a5)
	rts

td_make3dpoint:				; move point
	lea	x3d(pc),a0
	lea	y3d(pc),a1
	lea	z3d(pc),a2
	lea	xpos(pc),a3
	move.w	xvie(pc),d0
	sub.w	d0,(a3)			; xpos
	move.w	yvie(pc),d0
	sub.w	d0,2(a3)		; ypos
	move.w	zvie(pc),d0
	sub.w	d0,4(a3)		; zpos
td_turnpoint:				; turn point
	move.w	xpos(pc),d0
	move.w	TM+00(pc),d1
	muls	d0,d1
	swap	D1		;equals asr.l #14,Dx
	rol.l	#2,D1		;
	ext.l	D1		;
	move.w	d1,(a0)
	move.w	ypos(pc),d2
	move.w	TM+06(pc),d1
	muls	d2,d1
	swap	D1		;equals asr.l #14,Dx
	rol.l	#2,D1		;
	ext.l	D1		;
	add.w	d1,(a0)
	move.w	zpos(pc),d3
	move.w	TM+12(pc),d1
	muls	d3,d1
	swap	D1		;equals asr.l #14,Dx
	rol.l	#2,D1		;
	ext.l	D1		;
	add.w	d1,(a0)
	move.w	TM+02(pc),d1
	muls	d0,d1
	swap	D1		;equals asr.l #14,Dx
	rol.l	#2,D1		;
	ext.l	D1		;
	move.w	d1,(a1)
	move.w	TM+08(pc),d1
	muls	d2,d1
	swap	D1		;equals asr.l #14,Dx
	rol.l	#2,D1		;
	ext.l	D1		;
	add.w	d1,(a1)
	move.w	TM+14(pc),d1
	muls	d3,d1
	swap	D1		;equals asr.l #14,Dx
	rol.l	#2,D1		;
	ext.l	D1		;
	add.w	d1,(a1)
	move.w	TM+04(pc),d1
	muls	d0,d1
	swap	D1		;equals asr.l #14,Dx
	rol.l	#2,D1		;
	ext.l	D1		;
	move.w	d1,(a2)
	move.w	TM+10(pc),d1
	muls	d2,d1
	swap	D1		;equals asr.l #14,Dx
	rol.l	#2,D1		;
	ext.l	D1		;
	add.w	d1,(a2)
	move.w	TM+16(pc),d1
	muls	d3,d1
	swap	D1		;equals asr.l #14,Dx
	rol.l	#2,D1		;
	ext.l	D1		;
	add.w	d1,(a2)
td_perspective:				; put in perspective
	move.w	z3d(pc),d1
	ext.l	d1
	add.l	D3_Zoom(pc),d1
	bne.s	td_nozero
	moveq	#1,d1
td_nozero:
	move.w	x3d(pc),d0
	ext.l	d0
	asl.l	#8,d0
	divs	d1,d0
	move.w	d0,(a0)
	move.w	y3d(pc),d0
	ext.l	d0
	asl.l	#8,d0
	divs	d1,d0
	move.w	d0,2(a0)	
	move.w	d1,4(a0)
	rts

x3d:
	dc.w	0
y3d:
	dc.w	0
z3d:
	dc.w	0
xvie:
	dc.w	0
yvie:
	dc.w	0
zvie:
	dc.w	0
xpos:
	dc.w	0
ypos:
	dc.w	0
zpos:
	dc.w	0
degn:
	dc.w	0
degr:
	dc.w	0
degk:
	dc.w	0
sinn:
	dc.w	0
sinr:
	dc.w	0
sink:
	dc.w	0
cosn:
	dc.w	0
cosr:
	dc.w	0
cosk:
	dc.w	0
TM:
	dcb.w	9,0

DrawLine:
	MOVEM.L	D4-D7/A0-A6,-(SP)
	BSR.W	lbC001D52
	MOVEM.L	(SP)+,D4-D7/A0-A6
	CMP.W	D0,D2
	BNE.S	lbC001CBA
	CMP.W	D1,D3
	BNE.S	lbC001CBA
	RTS

lbC001CBA:
	MOVE.L	A1,D4
	MULU.W	D1,D4
	MOVEQ	#-$10,D5
	AND.W	D0,D5
	LSR.W	#3,D5
	ADD.W	D5,D4
	ADD.L	A0,D4
	MOVEQ	#0,D5
	SUB.W	D1,D3
	ROXL.B	#1,D5
	TST.W	D3
	BGE.S	lbC001CD4
	NEG.W	D3
lbC001CD4:
	SUB.W	D0,D2
	ROXL.B	#1,D5
	TST.W	D2
	BGE.S	lbC001CDE
	NEG.W	D2
lbC001CDE:
	MOVE.W	D3,D1
	SUB.W	D2,D1
	BGE.S	lbC001CE6
	EXG	D2,D3
lbC001CE6:
	ROXL.B	#1,D5
	MOVE.B	lbB001D48(PC,D5.L),D5
	ADD.W	D2,D2
lbC001CEE:
	BTST	#6,2(A6)
	BNE.S	lbC001CEE
	MOVE.W	D2,$62(A6)
	SUB.W	D3,D2
	BGE.S	lbC001D02
	ORI.B	#$40,D5
lbC001D02:
	MOVE.W	D2,$52(A6)
	SUB.W	D3,D2
	MOVE.W	D2,$64(A6)
	MOVE.W	#$8000,$74(A6)
	MOVE.W	A2,$72(A6)
	MOVE.W	#$FFFF,$44(A6)
	ANDI.W	#15,D0
	ROR.W	#4,D0
	OR.W	lbW001D50(PC),D0
	MOVE.W	D0,$40(A6)
	MOVE.W	D5,$42(A6)
	MOVE.L	D4,$48(A6)
	MOVE.L	D4,$54(A6)
	MOVE.W	A1,$60(A6)
	MOVE.W	A1,$66(A6)
	LSL.W	#6,D3
	ADDQ.W	#2,D3
	MOVE.W	D3,$58(A6)
	RTS

lbB001D48:
	dc.b	1
	dc.b	$11
	dc.b	9
	dc.b	$15
	dc.b	5
	dc.b	$19
	dc.b	13
	dc.b	$1D
lbW001D50:
	dc.w	$BCA

lbC001D52:
	MOVEQ	#0,D7
	MOVEQ	#0,D4
	CMPI.W	#0,D0
	BLT.S	lbC001D70
	CMPI.W	#$1A0,D0
	BGT.S	lbC001D70
	CMPI.W	#0,D1
	BLT.S	lbC001D70
	CMPI.W	#$11F,D1
	BGT.S	lbC001D70
	BRA.S	lbC001D74

lbC001D70:
	ADDQ.W	#1,D7
	MOVEQ	#1,D4
lbC001D74:
	MOVEQ	#0,D5
	CMPI.W	#0,D2
	BLT.S	lbC001D90
	CMPI.W	#$1A0,D2
	BGT.S	lbC001D90
	CMPI.W	#0,D3
	BLT.S	lbC001D90
	CMPI.W	#$11F,D3
	BGT.S	lbC001D90
	BRA.S	lbC001D94

lbC001D90:
	ADDQ.W	#1,D7
	MOVEQ	#1,D5
lbC001D94:
	TST.W	D7
	BEQ.S	lbC001DDA
	MOVE.L	#$FFFFFFFF,lbL00202A
	MOVE.L	#$201,lbL00202E
	CMPI.W	#1,D7
	BEQ.S	lbC001DE6
	MOVEQ	#0,D4
	BSR.S	lbC001DE6
	CMPI.W	#1,lbW00201A
	BGT.S	lbC001DCA
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	BRA.S	lbC001DDA

lbC001DCA:
	MOVE.W	lbW002026(PC),D0
	MOVE.W	lbW002028(PC),D1
	MOVE.W	lbW002022(PC),D2
	MOVE.W	lbW002024(PC),D3
lbC001DDA:
	CMPI.W	#4,lbW00201A
	NOP
	RTS

lbC001DE6:
	CLR.W	lbW00201A
	TST.W	D4
	BEQ.S	lbC001DF4
	EXG	D0,D2
	EXG	D1,D3
lbC001DF4:
	CLR.W	lbW00201C
	MOVE.W	D2,D6
	SUB.W	D0,D6
	MOVE.W	D6,lbW00201E
	MOVE.W	D3,D7
	SUB.W	D1,D7
	MOVE.W	D7,lbW002020
	TST.W	D7
	BEQ.W	lbC001F08
	MOVE.L	#0,D4
	SUB.L	D1,D4
	EXT.L	D4
	ASL.L	#8,D4
	ASL.L	#1,D4
	DIVS.W	D7,D4
	EXT.L	D4
	MOVE.W	D4,D5
	MULS.W	D6,D5
	ASR.L	#8,D5
	ASR.L	#1,D5
	ADD.L	D0,D5
	EXT.L	D5
	TST.L	D4
	BLT.S	lbC001E8E
	CMPI.L	#$1FF,D4
	BGT.S	lbC001E8E
	CMPI.L	#0,D5
	BLT.S	lbC001E8E
	CMPI.L	#$1A0,D5
	BGT.S	lbC001E8E
	MOVE.W	D5,D2
	MOVE.W	#0,D3
	CMP.L	lbL00202A,D4
	BLE.S	lbC001E6E
	MOVE.W	D2,lbW002036
	MOVE.W	D3,lbW002038
	MOVE.L	D4,lbL00202A
lbC001E6E:
	CMP.L	lbL00202E,D4
	BGE.S	lbC001E88
	MOVE.W	D2,lbW002032
	MOVE.W	D3,lbW002034
	MOVE.L	D4,lbL00202E
lbC001E88:
	ADDQ.W	#1,lbW00201A
lbC001E8E:
	MOVE.L	#$11F,D4
	SUB.L	D1,D4
	EXT.L	D4
	ASL.L	#8,D4
	ASL.L	#1,D4
	DIVS.W	D7,D4
	EXT.L	D4
	MOVE.W	D4,D5
	MULS.W	D6,D5
	ASR.L	#8,D5
	ASR.L	#1,D5
	ADD.L	D0,D5
	EXT.L	D5
	TST.L	D4
	BLT.S	lbC001F08
	CMPI.L	#$1FF,D4
	BGT.S	lbC001F08
	CMPI.L	#0,D5
	BLT.S	lbC001F08
	CMPI.L	#$1A0,D5
	BGT.S	lbC001F08
	MOVE.W	D5,D2
	MOVE.W	#$11F,D3
	CMP.L	lbL00202A,D4
	BLE.S	lbC001EE8
	MOVE.W	D2,lbW002036
	MOVE.W	D3,lbW002038
	MOVE.L	D4,lbL00202A
lbC001EE8:
	CMP.L	lbL00202E,D4
	BGE.S	lbC001F02
	MOVE.W	D2,lbW002032
	MOVE.W	D3,lbW002034
	MOVE.L	D4,lbL00202E
lbC001F02:
	ADDQ.W	#1,lbW00201A
lbC001F08:
	TST.W	D6
	BEQ.W	lbC002002
	MOVE.L	#0,D4
	SUB.L	D0,D4
	EXT.L	D4
	ASL.L	#8,D4
	ASL.L	#1,D4
	DIVS.W	D6,D4
	EXT.L	D4
	MOVE.W	D4,D5
	MULS.W	D7,D5
	ASR.L	#8,D5
	ASR.L	#1,D5
	ADD.L	D1,D5
	EXT.L	D5
	TST.L	D4
	BLT.S	lbC001F88
	CMPI.L	#$1FF,D4
	BGT.S	lbC001F88
	CMPI.L	#0,D5
	BLT.S	lbC001F88
	CMPI.L	#$11F,D5
	BGT.S	lbC001F88
	MOVE.W	#0,D2
	MOVE.W	D5,D3
	CMP.L	lbL00202A,D4
	BLE.S	lbC001F68
	MOVE.W	D2,lbW002036
	MOVE.W	D3,lbW002038
	MOVE.L	D4,lbL00202A
lbC001F68:
	CMP.L	lbL00202E,D4
	BGE.S	lbC001F82
	MOVE.W	D2,lbW002032
	MOVE.W	D3,lbW002034
	MOVE.L	D4,lbL00202E
lbC001F82:
	ADDQ.W	#1,lbW00201A
lbC001F88:
	MOVE.L	#$1A0,D4
	SUB.L	D0,D4
	EXT.L	D4
	ASL.L	#8,D4
	ASL.L	#1,D4
	DIVS.W	D6,D4
	EXT.L	D4
	MOVE.W	D4,D5
	MULS.W	D7,D5
	ASR.L	#8,D5
	ASR.L	#1,D5
	ADD.L	D1,D5
	EXT.L	D5
	TST.L	D4
	BLT.S	lbC002002
	CMPI.L	#$1FF,D4
	BGT.S	lbC002002
	CMPI.L	#0,D5
	BLT.S	lbC002002
	CMPI.L	#$11F,D5
	BGT.S	lbC002002
	MOVE.W	#$1A0,D2
	MOVE.W	D5,D3
	CMP.L	lbL00202A,D4
	BLE.S	lbC001FE2
	MOVE.W	D2,lbW002036
	MOVE.W	D3,lbW002038
	MOVE.L	D4,lbL00202A
lbC001FE2:
	CMP.L	lbL00202E,D4
	BGE.S	lbC001FFC
	MOVE.W	D2,lbW002032
	MOVE.W	D3,lbW002034
	MOVE.L	D4,lbL00202E
lbC001FFC:
	ADDQ.W	#1,lbW00201A
lbC002002:
	LEA	lbW002032(PC),A0
	LEA	lbW002022(PC),A1
	BSR.S	lbC002010
	BSR.S	lbC002010
	RTS

lbC002010:
	MOVE.W	(A0)+,D2
	MOVE.W	D2,(A1)+
	MOVE.W	(A0)+,D3
	MOVE.W	D3,(A1)+
	RTS

lbW00201A:
	dc.w	0
lbW00201C:
	dc.w	0
lbW00201E:
	dc.w	0
lbW002020:
	dc.w	0
lbW002022:
	dc.w	0
lbW002024:
	dc.w	0
lbW002026:
	dc.w	0
lbW002028:
	dc.w	0
lbL00202A:
	dc.l	$FFFFFFFF
lbL00202E:
	dc.l	$1FF
lbW002032:
	dc.w	0
lbW002034:
	dc.w	0
lbW002036:
	dc.w	0
lbW002038:
	dc.w	0




SWAPSCREENS:
	BTST	#6,2(A6)	; wait blit
	BNE.S	SWAPSCREENS
	EORI.W	#$FFFF,switch
	LEA	PLANEPOINTCOP2,A0
	TST.W	switch
	BEQ.S	lbC002248
	LEA	POINTER1(PC),A1
	MOVE.W	(A1),(A0)
	MOVE.W	2(A1),4(A0)
	BRA.S	lbC002254

lbC002248:
	LEA	POINTER2(PC),A1
	MOVE.W	(A1),(A0)
	MOVE.W	2(A1),4(A0)
lbC002254:
	RTS

CLEARSCREEN:
	MOVEM.L	D0-D7/A0-A6,-(SP)
	TST.W	switch
	BNE.S	lbC002270
	MOVE.L	#Double1,a0
	BRA.S	lbC002278
lbC002270:
	MOVE.L	#Double2,a0
lbC002278:
	MOVE.L	SP,OLDSP
	LEA	40*373(a0),SP		; ADDRESS OF SCREEN
	MOVEM.L	CLREG(PC),D0-D7/A0-A6	; CLEAR REGISTERS
;	MOVEM.L	D0-D7/A0-A6,-(SP)
	dcb.l	249,$48E7FFFE	; NOW CLEAR WITH CPU WHEN A BLIT IS IN PROG.
	MOVEA.L	OLDSP(PC),SP	; 60 bytes every instruction!
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS


CLREG:
	DS.L	15

OLDSP:
	dc.l	0
switch:
	dc.w	0



POINTER1:
	dc.l	0
POINTER2:
	dc.l	0

cos:			;640 valori, SIN16384|512
	dc.w	$4000,$3FFE,$3FFB,$3FF4,$3FEC,$3FE1,$3FD3,$3FC3
	dc.w	$3FB1,$3F9C,$3F84,$3F6A,$3F4E,$3F2F,$3F0E,$3EEB
	dc.w	$3EC5,$3E9C,$3E71,$3E44,$3E15,$3DE2,$3DAE,$3D77
	dc.w	$3D3E,$3D02,$3CC5,$3C84,$3C42,$3BFD,$3BB6,$3B6C
	dc.w	$3B20,$3AD2,$3A82,$3A2F,$39DB,$3983,$392A,$38CF
	dc.w	$3871,$3811,$37AF,$374B,$36E5,$367C,$3612,$35A5
	dc.w	$3536,$34C6,$3453,$33DE,$3367,$32EF,$3274,$31F7
	dc.w	$3179,$30F8,$3076,$2FF2,$2F6B,$2EE3,$2E5A,$2DCE
	dc.w	$2D41,$2CB2,$2C21,$2B8F,$2AFB,$2A65,$29CD,$2934
	dc.w	$289A,$27FD,$2760,$26C0,$2620,$257D,$24DA,$2435
	dc.w	$238E,$22E6,$223D,$2193,$20E7,$203A,$1F8B,$1EDC
	dc.w	$1E2B,$1D79,$1CC6,$1C12,$1B5D,$1AA7,$19EF,$1937
	dc.w	$187E,$17C4,$1708,$164C,$158F,$14D2,$1413,$1354
	dc.w	$1294,$11D3,$1112,$1050,$F8D,$ECA,$E06,$D41
	dc.w	$C7C,$BB7,$AF1,$A2B,$964,$89D,$7D6,$70E
	dc.w	$646,$57E,$4B5,$3ED,$324,$25B,$192,$C9
	dc.w	0,$FF37,$FE6E,$FDA5,$FCDC,$FC13,$FB4B,$FA82
	dc.w	$F9BA,$F8F2,$F82A,$F763,$F69C,$F5D5,$F50F,$F449
	dc.w	$F384,$F2BF,$F1FA,$F136,$F073,$EFB0,$EEEE,$EE2D
	dc.w	$ED6C,$ECAC,$EBED,$EB2E,$EA70,$E9B4,$E8F8,$E83C
	dc.w	$E782,$E6C9,$E611,$E559,$E4A3,$E3EE,$E33A,$E287
	dc.w	$E1D5,$E124,$E074,$DFC6,$DF19,$DE6D,$DDC3,$DD19
	dc.w	$DC72,$DBCB,$DB26,$DA82,$D9E0,$D93F,$D8A0,$D802
	dc.w	$D766,$D6CC,$D632,$D59B,$D505,$D471,$D3DF,$D34E
	dc.w	$D2BF,$D232,$D1A6,$D11C,$D094,$D00E,$CF8A,$CF08
	dc.w	$CE87,$CE08,$CD8C,$CD11,$CC98,$CC21,$CBAD,$CB3A
	dc.w	$CAC9,$CA5A,$C9EE,$C983,$C91B,$C8B5,$C850,$C7EE
	dc.w	$C78F,$C731,$C6D5,$C67C,$C625,$C5D0,$C57D,$C52D
	dc.w	$C4DF,$C493,$C44A,$C402,$C3BE,$C37B,$C33B,$C2FD
	dc.w	$C2C1,$C288,$C251,$C21D,$C1EB,$C1BB,$C18E,$C163
	dc.w	$C13B,$C114,$C0F1,$C0D0,$C0B1,$C095,$C07B,$C063
	dc.w	$C04E,$C03C,$C02C,$C01E,$C013,$C00B,$C004,$C001
	dc.w	$C000,$C001,$C004,$C00B,$C013,$C01E,$C02C,$C03C
	dc.w	$C04E,$C063,$C07B,$C094,$C0B1,$C0CF,$C0F1,$C114
	dc.w	$C13A,$C163,$C18D,$C1BB,$C1EA,$C21C,$C251,$C287
	dc.w	$C2C1,$C2FC,$C33A,$C37A,$C3BD,$C402,$C449,$C492
	dc.w	$C4DE,$C52C,$C57D,$C5CF,$C624,$C67B,$C6D4,$C730
	dc.w	$C78E,$C7ED,$C84F,$C8B4,$C91A,$C982,$C9ED,$CA59
	dc.w	$CAC8,$CB39,$CBAB,$CC20,$CC97,$CD10,$CD8A,$CE07
	dc.w	$CE86,$CF06,$CF89,$D00D,$D093,$D11B,$D1A5,$D230
	dc.w	$D2BD,$D34C,$D3DD,$D470,$D504,$D599,$D631,$D6CA
	dc.w	$D765,$D801,$D89E,$D93E,$D9DE,$DA81,$DB24,$DBC9
	dc.w	$DC70,$DD18,$DDC1,$DE6B,$DF17,$DFC4,$E073,$E122
	dc.w	$E1D3,$E285,$E338,$E3EC,$E4A1,$E557,$E60F,$E6C7
	dc.w	$E780,$E83B,$E8F6,$E9B2,$EA6F,$EB2C,$EBEB,$ECAA
	dc.w	$ED6A,$EE2B,$EEEC,$EFAE,$F071,$F134,$F1F8,$F2BD
	dc.w	$F382,$F447,$F50D,$F5D3,$F69A,$F761,$F828,$F8F0
	dc.w	$F9B8,$FA80,$FB49,$FC11,$FCDA,$FDA3,$FE6C,$FF35
	dc.w	$FFFE,$C7,$190,$259,$322,$3EB,$4B3,$57C
	dc.w	$644,$70C,$7D3,$89B,$962,$A29,$AEF,$BB5
	dc.w	$C7A,$D3F,$E04,$EC8,$F8B,$104E,$1110,$11D1
	dc.w	$1292,$1352,$1411,$14D0,$158E,$164A,$1706,$17C2
	dc.w	$187C,$1935,$19ED,$1AA5,$1B5B,$1C10,$1CC4,$1D77
	dc.w	$1E29,$1EDA,$1F8A,$2038,$20E5,$2191,$223B,$22E5
	dc.w	$238D,$2433,$24D8,$257C,$261E,$26BF,$275E,$27FC
	dc.w	$2898,$2933,$29CC,$2A63,$2AF9,$2B8D,$2C20,$2CB0
	dc.w	$2D3F,$2DCD,$2E58,$2EE2,$2F6A,$2FF0,$3074,$30F7
	dc.w	$3177,$31F6,$3273,$32ED,$3366,$33DD,$3452,$34C5
	dc.w	$3535,$35A4,$3611,$367B,$36E4,$374A,$37AE,$3810
	dc.w	$3870,$38CE,$3929,$3983,$39DA,$3A2F,$3A81,$3AD1
	dc.w	$3B20,$3B6B,$3BB5,$3BFC,$3C41,$3C84,$3CC4,$3D02
	dc.w	$3D3D,$3D77,$3DAD,$3DE2,$3E14,$3E44,$3E71,$3E9C
	dc.w	$3EC4,$3EEA,$3F0E,$3F2F,$3F4E,$3F6A,$3F84,$3F9B
	dc.w	$3FB0,$3FC3,$3FD3,$3FE1,$3FEC,$3FF4,$3FFB,$3FFE
	dc.w	$4000,$3FFE,$3FFB,$3FF4,$3FEC,$3FE1,$3FD3,$3FC3
	dc.w	$3FB1,$3F9C,$3F85,$3F6B,$3F4E,$3F30,$3F0F,$3EEB
	dc.w	$3EC5,$3E9D,$3E72,$3E45,$3E15,$3DE3,$3DAF,$3D78
	dc.w	$3D3F,$3D03,$3CC5,$3C85,$3C42,$3BFE,$3BB6,$3B6D
	dc.w	$3B21,$3AD3,$3A83,$3A30,$39DB,$3984,$392B,$38D0
	dc.w	$3872,$3812,$37B0,$374C,$36E6,$367D,$3613,$35A6
	dc.w	$3538,$34C7,$3454,$33DF,$3369,$32F0,$3275,$31F9
	dc.w	$317A,$30F9,$3077,$2FF3,$2F6D,$2EE5,$2E5B,$2DD0
	dc.w	$2D42,$2CB3,$2C23,$2B90,$2AFC,$2A66,$29CF,$2936
	dc.w	$289B,$27FF,$2761,$26C2,$2621,$257F,$24DC,$2436
	dc.w	$2390,$22E8,$223F,$2194,$20E9,$203C,$1F8D,$1EDE
	dc.w	$1E2D,$1D7B,$1CC8,$1C14,$1B5F,$1AA9,$19F1,$1939
	dc.w	$1880,$17C5,$170A,$164E,$1591,$14D4,$1415,$1356
	dc.w	$1296,$11D5,$1114,$1052,$F8F,$ECC,$E08,$D43
	dc.w	$C7E,$BB9,$AF3,$A2D,$966,$89F,$7D8,$710
	dc.w	$648,$580,$4B7,$3EF,$326,$25D,$194,$CB


	SECTION	GRAPH,DATA_C


copper2:
	dc.l	$1001200
	dc.l	$1020000
	dc.l	$1040000
	dc.l	$1060000
	dc.l	$1FC0000
	dc.l	$1080004
	dc.l	$10A0004
	dc.l	$8E1A64
	dc.l	$9039D1
	dc.l	$920020
	dc.l	$9400D8
	dc.l	$960020
	dc.w	$E0
PLANEPOINTCOP2:
	dc.w	0
	dc.l	$E20000
	dc.l	$1800000
	dc.l	$1820FFF
	dc.l	$FFFFFFFE

	SECTION	ObjectED002B70,BSS_C

d3_TransData:
	ds.b	24000


	ds.b	60
Double1:
	ds.b	40*373
Double2:
	ds.b	40*373

	end
