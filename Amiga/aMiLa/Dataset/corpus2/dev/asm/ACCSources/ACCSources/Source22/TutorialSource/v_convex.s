    OPT C-,O-,D+,L-


*-- AutoRev header do NOT edit!
*
*   Program         :   V_CONVEX.S                                      
*   Copyright       :   P.KENT/FREEWARE                                     
*   Author          :   P.KENT                                              
*   Creation Date   :   02-Mar-92
*   Current version :   1.12
*   Translator      :   DEVPAC 3.01                                         
*
*   REVISION HISTORY
*
*   Date          Version         Comment
*   ---------     -------         ------------------------------------------
*   06-Mar-92     1.12            Normalisation code improved.              
*   04-Mar-92     1.11            RMB for sizing/speed comparisons + copper 
*   03-Mar-92     1.10            Tidied windowing fill/wipe code + normals 
*   02-Mar-92     1.00            Initial version/Obj struct/Fast Convex    
*
*-- REV_END --*


    SECTION CONVEX_VECTOR,CODE_C
    OUTPUT  V_CONVEX

    INCLUDE source:include/HARDWARE.I
	INCLUDE	MYMACROS.I

    INCLUDE HWSTART.S

;SCREEN IS 352 ($2C WIDB), 267 HGT
PLLEN = $2E10

CUSTOM = $dff000

RASTERCHECK =   0   ;1 FOR TIMING!
RCOL	MACRO		;CHANGES BAACKGROUND COL TO \1 IF TIMING...
	IFNE	RASTERCHECK
	MOVE.W	\1,COLOR00(A6)
	ENDC
	ENDM

_BOOT
	MOVEM.L	D0-D7/A0-A6,-(SP)
;CODE TO PUT IN EXTERNAL-SYNCING IF GENLOCK PRESENT : NEEDED HERE!
	LEA	$DFF000,A6
	CATCHVB	A6
	MOVE.W	#$87C0,dmacon(A6)
	BSR	GenInit	            ; Init planes, persp tab etc
	MOVE.L	#MY_Copper,cop1lch(A6)
	MOVE.L	#MY_VBI,$6C.W
	MOVE.L	#$C0207FFF,intena(A6)

; Run to button
PauseLP	Btst    #6,$bfe001
    bne.s   PauseLP

	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS	

;Vertical blank code:
;All 3d calls here at present since the present object
;will ALWAYS be updated within one frame... 
MY_VBI
	MOVEM.L	D0-D7/A0-A6,-(SP)
	LEA	$DFF000,A6
	BSR	WipeOldPlanes	; Wipe old 3d planes....
	BSR	Do3D	        ; DO next frame
	RMOUSE	A6,BYE
	ADDQ.W	#8,PERSPFACTOR3D
BYE
	MOVE.W	#$4020,intreq(A6)
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTE	
 
Do3D
	RCOL	#$100
	MOVE.L	CurObj,a5
	BSR	ClearOldPlDats			; Reset Old display window
	BSR	ChangeAngles			; Rotate...
	BSR	HandlePoints			; Rotate/Persp points
	RCOL	#$010
	BSR	DrawPlanes				; Draw plane edges + find window
	RCOL	#$110
	BSR	FillPlanes				; Fill Planes...
	RCOL	#$011
	BSR	DoubleBuffer
	RCOL	#0
	RTS	
 
; Wipe all old plane datas
ClearOldPlDats
	LEA	Opl1DatA(PC),A0			; Set mins/maxs
	MOVEQ.L	#0,D0
	MOVE.W	#$7FFF,D0			; Faster than .L #$7FFF0000,D0
	SWAP	D0

	MOVE.L	D0,(A0)+			; Reset min/max for each plane
	MOVE.L	D0,(A0)+

	MOVE.L	D0,(A0)+
	MOVE.L	D0,(A0)+

	MOVE.L	D0,(A0)+
	MOVE.L	D0,(A0)+
	RTS	
 
; Rotate points into RotPointArray
; Persp points into persp array
HandlePoints
	MOVE.L	O.PPLIST(A5),A4				; Source coords
	MOVE.L	O.PRLIST(A5),A0				; Destination of rotate routine

	LEA	SinTab(pc),A1					;\
	LEA	$400(a1),A2						;/\ Sin/Cos table
	LEA	AngAct(PC),A3					; Current angles

	MOVE.W	(A4)+,D7					; No of coords to rotate
	SUBQ.W	#1,D7
RotatePoint_lp
	MOVEM.W	(A4)+,D0-D2					; x,y,z
	MOVE.W	(A3),D6						; xang
	MOVE.W	(A1,D6.W),D5
	MOVE.W	(A2,D6.W),D6
	MOVE.W	D1,D4	
	MULS	D5,D4						; xsin*y
	MULS	D6,D1						; xcos*y
	MULS	D2,D5						; xsin*z
	SUB.L	D5,D1						; xcos*y-xsin*z
	SWAP	D1							; Scale down...
	ADD.W	D1,D1

	MULS	D6,D2						; xcos*z
	ADD.L	D4,D2						; xsin*y+xcos*z
	SWAP	D2
	ADD.W	D2,D2

	MOVE.W	2(A3),D6
	MOVE.W	(A1,D6.W),D5				; ysin
	MOVE.W	(A2,D6.W),D6				; ycos
	MOVE.W	D0,D4
	MULS	D5,D4						; ysin*x
	MULS	D6,D0						; ycos*x
	MULS	D2,D5						; ysin*(xsin*y+xcos*z)
	SUB.L	D5,D0						; ycos*x-ysin*(xsin+xcos*z)
	SWAP	D0
	ADD.W	D0,D0

	MULS	D6,D2						; ycos*(xsin*y+xcos*z)
	ADD.L	D4,D2						; ysin*x+ycos*(xsin*y+xcos*z)
	SWAP	D2
	ADD.W	D2,D2

	MOVE.W	4(A3),D6
	MOVE.W	(A1,D6.W),D5				; zsin
	MOVE.W	(A2,D6.W),D6				; zcos
	MOVE.W	D0,D4
	MULS	D5,D4						; zsin*(ycos*x-ysin*(xsin+xcos*z))
	MULS	D6,D0						; zcos*(above)     (1)
	MULS	D2,D5						; zsin*(ysin*x+ycos*(xsin*y+xcos*z)
	SUB.L	D5,D0						; above - above prev line
	SWAP	D0
	ADD.W	D0,D0
	MULS	D6,D2
	ADD.L	D4,D2						; round down...
	SWAP	D2
	ADD.W	D2,D2

	MOVE.W	D0,(A0)+
	MOVE.W	D1,(A0)+
	MOVE.W	D2,(A0)+
	DBRA	D7,RotatePoint_lp

	MOVE.L	o.prlist(A5),A0				; Rot coords
	MOVE.L	o.p2List(A5),A1				; Dest for persp coords
	LEA	PerspTab(PC),A2
	MOVE.W	Perspfactor3d,D0			; ZDist of object
	ADD.W	D0,D0
	LEA	(A2,D0.W),A2

	LEA	176.w,A3						; x-centre
	LEA	134.w,A4						; y-centre

	MOVE.W	O.WMXPTS(A5),D7				; Perspective all points
	SUBQ.W	#1,D7
PerspPoint_lp
	MOVEM.W	(A0)+,D0-D2

	MOVE.W	(A2,D2.W),D2
	MULS	D2,D0						; f(z)*x
	SWAP	D0
	ADD.W	A3,D0   					; f(z)*x+xcentre
	MULS	D2,D1   					; f(z)*y
	SWAP	D1
	ADD.W	A4,D1   					; f(z)*y+ycentre
	MOVE.W	D0,(A1)+
	MOVE.W	D1,(A1)+
	DBRA	D7,PerspPoint_lp
	RTS


DrawPlanes
	MOVE.L	O.P2LIST(A5),A0
	MOVE.L	O.PDLIST(A5),A1
	MOVE.L	DrawPtr1,A2

	BLITWAIT	A6
	MOVEQ.L	#-1,D0
	MOVE.L	D0,bltafwm(A6)
	MOVE.W	#$2C,bltcmod(A6)
	MOVE.L	#$FFFF8000,bltbdat(A6)
	MOVE.W	#$2C,bltdmod(A6)
DrawPlane_planelp
	TST.W	(A1)
	BEQ	DP_QUIT
	MOVE.W	4(A1),D6				; Get first point numbers,skip col.
	MOVE.W	8(A1),D5
	MOVE.W	12(A1),D4
	MOVE.W	(A0,D6.W),D0       		; Check orientation with specified points
	SUB.W	(A0,D5.W),D0
	MOVE.W	2(A0,D6.W),D1
	SUB.W	2(A0,D5.W),D1
	MOVE.W	(A0,D4.W),D2
	SUB.W	(A0,D5.W),D2
	MOVE.W	2(A0,D4.W),D3
	SUB.W	2(A0,D5.W),D3
	MULS	D0,D3
	MULS	D1,D2
	SUB.W	D2,D3
	BLE.S	DrawPlane_NotNormal     ; -ve nornal : towards us


	MOVE.W	(A1),D6					; Skip plane data
	ADD.W	D6,D6
	ADDQ.W	#2,D6
	ADD.W	D6,D6
	LEA	(A1,D6.W),A1
	BRA	DrawPlane_skipplane

DrawPlane_NotNormal
	MOVE.W	(A1)+,D6					; No lines
	MOVE.W	(A1)+,D7					; Save colour
	SUBQ.W	#1,D6
;Put in min/max checks here instead of sepearate routine
;to save calculating polygon orientation of polygon twice.

	MOVEM.L	D6/A1,-(SP)					; d6 num lines,a1 poly ptr
FMM_Pointlp
	MOVE.W	(A1),D4
	ADDQ.L	#4,A1
	MOVEM.W	(A0,D4.W),D4/D5
; CHeck coords against window bounds
	BTST	#0,D7
	BEQ.S	FMM_Nopl1
	LEA	Opl1DatA(PC),A3
	MOVEM.W	(A3),D0-D3
	CMP.W	D0,D4
	BPL.S	Opl1_ok1
	MOVE.W	D4,D0
Opl1_ok1	CMP.W	D1,D4
	BLE.S	Opl1_ok2
	MOVE.W	D4,D1
Opl1_ok2	CMP.W	D2,D5
	BPL.S	Opl1_ok3
	MOVE.W	D5,D2
Opl1_ok3	CMP.W	D3,D5
	BLE.S	Opl1_ok4
	MOVE.W	D5,D3
Opl1_ok4
	MOVEM.W	D0-D3,(A3)
FMM_Nopl1

	BTST	#1,D7
	BEQ.S	FMM_pl2
	LEA	Opl2DatA(PC),A3
	MOVEM.W	(A3),D0-D3
	CMP.W	D0,D4
	BPL.S	Opl2_ok1
	MOVE.W	D4,D0
Opl2_ok1	CMP.W	D1,D4
	BLE.S	opl2_ok2
	MOVE.W	D4,D1
opl2_ok2	CMP.W	D2,D5
	BPL.S	Opl2_ok3
	MOVE.W	D5,D2
Opl2_ok3	CMP.W	D3,D5
	BLE.S	OPl2_ok4
	MOVE.W	D5,D3
OPl2_ok4
	MOVEM.W	D0-D3,(A3)
FMM_pl2
	BTST	#2,D7
	BEQ.S	FMM_nopl3
	LEA	Opl3DatA(PC),A3
	MOVEM.W	(A3),D0-D3
	CMP.W	D0,D4
	BPL.S	Opl3_ok1
	MOVE.W	D4,D0
Opl3_ok1	CMP.W	D1,D4
	BLE.S	op3_ok2
	MOVE.W	D4,D1
op3_ok2	CMP.W	D2,D5
	BPL.S	opl3_ok3
	MOVE.W	D5,D2
opl3_ok3	CMP.W	D3,D5
	BLE.S	opl3_ok4
	MOVE.W	D5,D3
opl3_ok4
	MOVEM.W	D0-D3,(A3)
FMM_nopl3

	DBRA	D6,FMM_Pointlp
	MOVEM.L	(SP)+,A1/D6


DrawPlane_linelp	;d6:numpts-1;a1:plane descriptor

	MOVE.W	(A1)+,D4
	MOVE.W	(A1)+,D5
	MOVEM.W	(A0,D4.W),D0/D1
	MOVEM.W	(A0,D5.W),D2/D3
	CMP.W	D1,D3
	BEQ	Drawplane_nopl3
	BPL.S	DrawPlane_GradOK
	EXG	D2,D0
	EXG	D3,D1
DrawPlane_GradOK	SUBQ.W	#1,D3
	SUB.W	D1,D3
	SUB.W	D0,D2
	BPL.S	DrawPlane_PLGrad
	NEG.W	D2
	MOVEQ.L	#$17,D4
	CMP.W	D3,D2
	BPL.S	DrawPlane_LineCont
	MOVEQ.L	#11,D4
	EXG	D3,D2
	BRA.S	DrawPlane_LineCont
 
DrawPlane_PLGrad	MOVEQ.L	#$13,D4
	CMP.W	D3,D2
	BPL.S	DrawPlane_LineCont
	MOVEQ.L	#3,D4
	EXG	D3,D2
DrawPlane_LineCont
;
	MULU	#$2C,D1
;
	LEA	(A2,D1.L),A3
	MOVE.W	D0,D1
	LSR.W	#3,D1
	ADD.W	D1,A3
	MOVEQ.L	#15,D5
	AND.W	D0,D5
	ROR.W	#4,D5
	OR.W	#$0B6A,D5
	ADD.W	D3,D3
	MOVE.W	D3,D1
	SUB.W	D2,D1
	BPL.S	Drawplane_sgnnl
	OR.W	#$0040,D4
Drawplane_sgnnl	MOVE.W	D1,D0
	SUB.W	D2,D0
	ADDQ.W	#1,D2
	LSL.W	#6,D2
	ADDQ.W	#2,D2
	SWAP	D5
	MOVE.W	D4,D5
	SWAP	D3
	MOVE.W	D0,D3
	BTST	#0,D7
	BEQ.S	Drawplane_nopl1

	BLITWAIT	A6

	MOVE.L	D5,bltcon0(A6)
	MOVE.L	A3,bltcpth(A6)
	MOVE.W	D1,bltaptl(A6)
	MOVE.L	A3,bltdpth(A6)
	MOVE.L	D3,bltbmod(A6)
	MOVE.W	D2,bltsize(A6)
Drawplane_nopl1
	BTST	#1,D7
	BEQ.S	Drawplane_nopl2

	BLITWAIT	A6
	MOVE.L	D5,bltcon0(A6)
	LEA	PLLEN(A3),A4
	MOVE.L	A4,bltcpth(A6)
	MOVE.W	D1,bltaptl(A6)
	MOVE.L	A4,bltdpth(A6)
	MOVE.L	D3,bltbmod(A6)
	MOVE.W	D2,bltsize(A6)
Drawplane_nopl2
	BTST	#2,D7
	BEQ.S	Drawplane_nopl3

	BLITWAIT	A6
	MOVE.L	D5,bltcon0(A6)
	LEA	PLLEN*2(A3),A4
	MOVE.L	A4,bltcpth(A6)
	MOVE.W	D1,bltaptl(A6)
	MOVE.L	A4,bltdpth(A6)
	MOVE.L	D3,bltbmod(A6)
	MOVE.W	D2,bltsize(A6)
Drawplane_nopl3
	DBRA	D6,DrawPlane_linelp
DrawPlane_skipplane		BRA	DrawPlane_planelp
DP_QUIT
	RTS	
 
FillPlanes
	LEA	OPl1Data(PC),A0
	MOVEQ.L	#0,D2
	BSR.S	FillWin
	LEA	OPl2Data(PC),A0
	MOVE.L	#PLLEN,D2
	BSR.S	FillWin
	LEA	OPl3Data(PC),A0
	MOVE.L	#PLLEN*2,D2
	BSR.S	FillWin
	RTS
FillWin					;A0B2C4D6
	MOVE.W	6(A0),D0
	BEQ.S	FillW_nopl

	MOVE.W	#$2C,D4
;
	MULU	D4,D0
;
	MOVE.W	2(A0),D1
	BEQ.S	FillW_nopl
	LSR.W	#3,D1
	EXT.L	D1
	ADD.L	D1,D0
	ADD.L	DrawPtr1,D0
	ADD.L	D2,D0		;OFFSET
	MOVE.W	(A0),D2
	LSR.W	#3,D2
	MOVEQ.L	#-2,D3
	AND.B	D3,D1
	AND.B	D3,D2
	SUB.W	D2,D1
	ADDQ.W	#2,D1
	SUB.W	D1,D4
	MOVE.W	6(A0),D3
	SUB.W	4(A0),D3
	ADDQ.W	#1,D3
	LSL.W	#6,D3
	LSR.W	#1,D1
	ADD.W	D1,D3

	BLITWAIT	A6
	MOVE.L	#$09F00012,bltcon0(A6)
	MOVEQ.L	#-1,D1
	MOVE.L	D1,bltafwm(A6)
	MOVE.L	D0,bltapth(A6)
	MOVE.L	D0,bltdpth(A6)
	MOVE.W	D4,bltamod(A6)
	MOVE.W	D4,bltdmod(A6)
	MOVE.W	D3,bltsize(A6)
FillW_nopl	RTS
 
; Dbuff rt... swap window defs over, swap copper planes
DoubleBuffer

	LEA	Opl1DatA(PC),A0
	LEA	Opl1DatOld(PC),A1
	MOVEM.W	(A0),D0-D3
	MOVEM.W	(A1),D4-D7
	MOVEM.W	D4-D7,(A0)
	MOVEM.W	D0-D3,(A1)
	LEA	Opl2DatA(PC),A0
	LEA	Opl2DatOld(PC),A1
	MOVEM.W	(A0),D0-D3
	MOVEM.W	(A1),D4-D7
	MOVEM.W	D4-D7,(A0)
	MOVEM.W	D0-D3,(A1)
	LEA	Opl3DatA(PC),A0
	LEA	Opl3datold(PC),A1
	MOVEM.W	(A0),D0-D3
	MOVEM.W	(A1),D4-D7
	MOVEM.W	D4-D7,(A0)
	MOVEM.W	D0-D3,(A1)

DoubleBuffer_Insert
	MOVE.L	DrawPtr1,D0
	MOVE.L	DrawPtr2,DrawPtr1
	MOVE.L	D0,DrawPtr2
	LEA	CopPLptr(PC),A0
	MOVE.L	#PLLEN,D1	; Plane offset
	MOVEQ.L	#2,D7
DBuffpl_lp	MOVE.W	D0,4(A0)
	SWAP	D0
	MOVE.W	D0,(A0)
	SWAP	D0
	ADD.L	D1,D0
	ADDQ.L	#8,A0
	DBRA	D7,DBuffpl_lp
	RTS	
 
WipeOldPlanes
	LEA	OPl1Data(PC),A0
	MOVEQ.L	#0,D2
	BSR.S	WipeWin
	LEA	OPl2Data(PC),A0
	MOVE.L	#PLLEN,D2
	BSR.S	WipeWin
	LEA	OPl3Data(PC),A0
	MOVE.L	#PLLEN*2,D2
	BSR.S	WipeWin
	RTS
WipeWin					;A0B2C4D6
	MOVE.W	6(A0),D0
	BEQ.S	WipeW_nopl

	MOVE.W	#$2C,D4
;
	MULU	D4,D0
;
	MOVE.W	2(A0),D1
	BEQ.S	WipeW_nopl
	LSR.W	#3,D1
	EXT.L	D1
	ADD.L	D1,D0
	ADD.L	DrawPtr1,D0
	ADD.L	D2,D0		;OFFSET
	MOVE.W	(A0),D2
	LSR.W	#3,D2
	MOVEQ.L	#-2,D3
	AND.B	D3,D1
	AND.B	D3,D2
	SUB.W	D2,D1
	ADDQ.W	#2,D1
	SUB.W	D1,D4
	MOVE.W	6(A0),D3
	SUB.W	4(A0),D3
	ADDQ.W	#1,D3
	LSL.W	#6,D3
	LSR.W	#1,D1
	ADD.W	D1,D3

	BLITWAIT	A6
	MOVE.L	#$01000002,bltcon0(A6)
;	MOVEQ.L	#-1,D1
;	MOVE.L	D1,bltafwm(A6)
	MOVE.L	D0,bltdpth(A6)
	MOVE.W	D4,bltdmod(A6)
	MOVE.W	D3,bltsize(A6)
WipeW_nopl	RTS

 
GenInit
	BSR	InitPTab						; Perspective
	BSR InitWipe
	BSR DoubleBuffer_Insert
	Move.l	CurObj,A0
	BSR	InitObj							; Initialise vector obj...
	RTS	
 

; Set up perspective table...
InitPTab	LEA	PerspTab(PC),A0
	MOVE.W	#470,D0
	MOVE.W	D0,D1
	MOVE.W	#7999,D7
InitPTab_lp	MOVE.W	#$7FFF,D3
	MULU	D0,D3
	DIVU	D1,D3
	MOVE.W	D3,(A0)+
	ADDQ.W	#1,D1
	DBRA	D7,InitPTab_lp
	RTS	
 


InitObj	;OBJ in a0

	Tst.w	o.winit(a0)	; Already init ?
	bne	InitPfin
	Move.w	#1,o.winit(a0)	; Set initialised....
	Move.l	o.pDList(A0),A0
; INit planes...
InitP_olp
	MOVE.W	(A0)+,D6	; Get no. edges
	BEQ.S	InitPFin	; 0 : endsig
	ADD.W	D6,D6		; 2*as many point nos
	ADDQ.L	#2,A0		; skip colour
	SUBQ.W	#1,D6		; Sub for Dbra
; Init point nums
InitP_ilp
	MOVE.W	(A0),D0		; Get pnum * 4
	ADD.W	D0,D0
	ADD.W	D0,D0
	MOVE.W	D0,(A0)+	; save
	DBRA	D6,InitP_ilp

	BRA.S	InitP_olp

InitPFin
	RTS		

InitWipe
	MOVE.L	DrawPtr1,A0
	MOVE.L	DrawPtr2,A1
	MOVE.L	#PLLEN*3/4,D0
Iwipe1	CLR.L	(A0)+
	CLR.L	(A1)+
	SUBQ.L	#1,D0
	BNE.S	Iwipe1
	RTS
		
; Change angles and mod to size!
ChangeAngles	LEA	AngAct(PC),A0
	LEA	AngMod(PC),A1
	MOVE.W	#$03FE,D3
	MOVEM.W	(A0)+,D0-D2
	ADD.W	(A1)+,D0
	ADD.W	(A1)+,D1
	ADD.W	(A1)+,D2
	AND.W	D3,D0
	AND.W	D3,D1
	AND.W	D3,D2
	MOVEM.W	D0-D2,-6(A0)
	RTS	
 
 
AngAct	ds.w	3			; Actual x,y,z angles
AngMod	dc.w	10,0,4		; Angle x,y,z additions

Perspfactor3d	dc.w	$3A0 ; WAS $C80 SMALLER> BIGGER OBJ! NO CLIPPING!!!

Opl1Data	dc.w	0,351,0,267
Opl2Data	dc.w	0,351,0,267
Opl3Data	dc.w	0,351,0,267

Opl1DatOld	dc.w	0,351,0,267
Opl2DatOld	dc.w	0,351,0,267
Opl3datold	dc.w	0,351,0,267

DrawPtr1	dc.l	SCREEN1
DrawPtr2	dc.l	SCREEN2

MY_Copper
	dc.w	diwstrt,$2A71,diwstop,$36D1
	dc.w	ddfstrt,$30,ddfstop,$D8
	dc.w	bplcon0
CopDMA	dc.w	$3200
	dc.w	bplcon1,0,bplcon2,0
	dc.w	bpl1mod,0,bpl2mod,0

    IFEQ    RASTERCHECK
	dc.w	$0180,0
    ENDC
	dc.w	$0182,15,$0184,8,$0186,10,$0188,12,$018A,10,$018C,8,$018E,$400
	dc.w	bpl1pth
CopPLptr	dc.w	0,bpl1ptl,0
	dc.w	bpl2pth,0,bpl2ptl,0
	dc.w	bpl3pth,0,bpl3ptl,0

	dc.w	$FFFF,$FFFE

PerspTab	    ds.w    8000

CurObj	dc.l	Object

	rsreset
o.wInit		rs.w	1	;NZERO once init
o.wMxPts	rs.w	1	;max points
o.pPList	rs.l	1	;Points to rot
o.pRList	rs.l	1	;Rotated/treated list
o.p2List	rs.l	1	;Persped list
o.pDList	rs.l	1	;Draw item list

Object
	dc.w	0				;Set to NZERO once treated!
	dc.w	12				;TOTAL no points
	dc.l	ObjPointList	;Ptr to point list
	dc.l	ObjRotList		;`Treated` 3d list
	dc.l	ObjXYList		;2d list of persp points
	dc.l	ObjDrawList		;List of components (planes only at mo!)
	
ObjRotList	ds.w	12*3
ObjXYList	ds.w	12*2
ObjPointList
	dc.w	12				;no points to rotate
	dc.w	$FF06,$FDA8,0
	dc.w	$00FA,$FDA8,0
	dc.w	$01F4,$FF06,0
	dc.w	$01F4,$01C2,0
	dc.w	$00C8,$01C2,$FF38
	dc.w	$FF38,$01C2,$FF38
	dc.w	$FE0C,$01C2,0
	dc.w	$FE0C,$FF06,0
	dc.w	$FF9C,$FED4,$FF38
	dc.w	$0064,$FED4,$FF38
	dc.w	$00C8,$FF9C,$FF38
	dc.w	$FF38,$FF9C,$FF38

ObjDrawList				   ;PLANES ONLY: no edges,colour,point pairs
	
	dc.w	6,1
	dc.w	8,9,9,10,10,4,4,5,5,11,11,8

	dc.w	4,2
	dc.w	7,11,11,5,5,6,6,7

	dc.w	4,3
	dc.w	0,8,8,11,11,7,7,0

	dc.w	4,4
	dc.w	0,1,1,9,9,8,8,0

	dc.w	4,5
	dc.w	1,2,2,10,10,9,9,1

	dc.w	4,6
	dc.w	10,2,2,3,3,4,4,10

	dc.w	4,7
	dc.w	6,5,5,4,4,3,3,6

	dc.w	6,6
	dc.w	0,7,7,6,6,3,3,2,2,1,1,0

	dc.w	0	;ENDSIG!

SinTab      incbin  MYVECT.SINTAB ;Precalculated sintable

	SECTION	ABBA,BSS_C
SCREEN1 DS.B PLLEN*3

SCREEN2 DS.B PLLEN*3

