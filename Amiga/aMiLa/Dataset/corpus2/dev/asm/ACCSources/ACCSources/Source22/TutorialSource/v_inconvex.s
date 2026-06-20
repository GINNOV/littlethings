    OPT C-,O-,D+,L-


*-- AutoRev header do NOT edit!
*
*   Program         :   V_INCONVEX.S                                      
*   Copyright       :   P.KENT/FREEWARE                                     
*   Author          :   P.KENT                                              
*   Creation Date   :   02-Mar-92
*   Current version :   2.01
*   Translator      :   DEVPAC 3.01                                         
*
*   REVISION HISTORY
*
*   Date          Version         Comment
*   ---------     -------         ------------------------------------------
*   09-Mar-92     2.01            >>>> ONE STEP CLOSER <<<<                 
*   09-Mar-92     2.01            Position idependant object (un-init)      
*   09-Mar-92     2.00            Inconvex objects allowed for - av z coord 
*   06-Mar-92     1.12            Normalisation code improced.              
*   04-Mar-92     1.11            RMB for sizing/speed comparisons + copper 
*   03-Mar-92     1.10            Tidied windowing fill/wipe code + normals 
*   02-Mar-92     1.00            Initial version/Obj struct/Fast Convex    
*
*-- REV_END --*


    SECTION INCONVEX_VECTOR,CODE_C
    OUTPUT  V_INCONVEX

    INCLUDE source:include/HARDWARE.I
	INCLUDE	MYMACROS.I

    INCLUDE HWSTART.S

;SCREEN IS 352 ($2C WIDB), 267 HGT
PLLEN = $2E10

CUSTOM = $DFF000

;MAXIMUM NO OF PLANES!
MAXPLANES	=20	

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
	BSR	GenInit	            ; Init planes, persp tab etc
	MOVE.L	#MY_Copper,cop1lch(A6)
	MOVE.L	#MY_VBI,$6C.W
	CATCHVB	A6
	MOVE.W	#$87C0,dmacon(A6)
	MOVE.L	#$C0207FFF,intena(A6)

; Run to button
PauseLP
	BSR	Do3d
    MOUSE   PauseLP

	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS	

;Vertical blank code:
;All 3d calls here at present since the present object
;will ALWAYS be updated within one frame... 
MY_VBI
	MOVEM.L	D0-D7/A0-A6,-(SP)
	LEA	$DFF000,A6
	RMOUSE	A6,BYE
	ADDQ.W	#8,ObjZDistance
BYE
	MOVE.W	#$4020,intreq(A6)
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTE	
 
Do3D
	MOVE.L	CurObj,a5
	BSR	WipeOldPlanes			; Wipe old 3d planes....
	BSR	ClearOldPlDats			; Reset Old display window
	BSR	ChangeAngles			; Rotate...
	BSR	HandlePoints			; Rotate/Persp points
	BSR	DoPlaneList				; Depth planes
	BSR	SortList				; OK! So its a naff sort routine!
	BSR	PlotAll					; Draw sorted list
	BLITWAIT	A6
	CATCHPOS	A6,300
	BSR	DoubleBuffer
	RTS	
 
; Wipe all old plane datas
ClearOldPlDats
	LEA	OplDatA(PC),A0			; Set mins/maxs
	MOVEQ.L	#0,D0
	MOVE.W	#$7FFF,D0			; Faster than .L #$7FFF0000,D0
	SWAP	D0

	MOVE.L	D0,(A0)+			; Reset min/max for all planes
	MOVE.L	D0,(A0)+

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

;
;ANY EXTRUSION ETC MUST OCCUR HERE!
;

	MOVE.L	o.prlist(A5),A0				; Rot coords
	MOVE.L	o.p2List(A5),A1				; Dest for persp coords
	LEA	PerspTab(PC),A2
	LEA	176.w,A3						; x-centre
	LEA	134.w,A4						; y-centre
	MOVE.W	ObjZDistance,D0
	ADD.W	D0,D0
	LEA	(A2,D0.W),A2
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


DoPlaneList
	MOVE.L	o.p2list(a5),a0
	MOVE.L	o.pdList(a5),a1
	LEA	SceneList,A2					;Dest list for ptrs,depths
	MOVE.L	o.prlist(a5),a3
	MOVE.W	#0,NumSort
Planelp
	TST.W	(A1)
	BNE.S	PlaneNQuit
	CLR.L	(A2)						;End of scene
	RTS
PlaneNQuit
	MOVE.W	4(A1),D4
	MOVE.W	8(A1),D5
	MOVE.W	12(A1),D6
	MOVEM.W	(A0,D4.W),D0/D1
	MOVEM.W	(A0,D5.W),D2/D3
	MOVEM.W	(A0,D6.W),D4/D5
	SUB.W	D1,D3
	SUB.W	D0,D4
	MULS	D4,D3
	SUB.W	D5,D1
	SUB.W	D2,D0
	MULS	D1,D0
	SUB.L	D0,D3
	BMI.S	DP_Visible

DP_NextPlane
	MOVE.W	(A1),D6					; Skip plane data
	ADD.W	D6,D6					; No pairs coords
	ADDQ.W	#2,D6					; +numpts+col
	ADD.W	D6,D6					;>words
	LEA	(A1,D6.W),A1				; offset
	BRA	Planelp
 
DP_Visible
	MOVE.L	A1,(A2)+
	ADDQ.W	#1,NumSort
;calc & put depth
;Average out point z distances of all points in plane
;SLOW!! Could also just pick a point in centre, or average over
;just a few typical coords.

	MOVEQ	#0,D0

	MOVE.W	(A1),D6					; Num lines
	ADDQ.L	#4,A1
	
	MOVE.W	D6,D7					; Save for divide
	SUBQ.W	#1,D6
Averagelp
	MOVE.W	(A1),D3					; no.*4 - need no *6...
	ADDQ.W	#4,A1
	MOVE.W	D3,D4
	LSR.W	#1,D4
	ADD.W	D4,D3					; D1=no*6
	MOVE.W	4(A3,D3.W),D3			; Average Z coord
	ADD.W	D3,D0
	DBRA	D6,Averagelp
    EXT.L   D0
	DIVS	D7,D0
	MOVE.W	D0,(A2)+
	BRA	Planelp


SortList
; Sort routine....
	MOVE.W	NumSort,D6
	LEA	SceneList+4,A1
Sort
	MOVE.W	#0,D7	; Clear swap flag
	MOVE.W	D6,D0
	SUBQ.W	#1,D0
	BEQ.S	Sort_DOne
	MOVE.L	A1,A0
Sort_Chunklp
	MOVE.W	(A0),D1
	MOVE.W	6(A0),D2
	CMP.W	D1,D2
	BLE.S	Sort_NSwap
	MOVE.W	D0,D7	; Have swapped - D0 MUST BE non zero...

	MOVE.W	D1,6(A0)
	MOVE.W	D2,(A0)

	MOVE.L	-4(A0),D1
	MOVE.L	2(A0),-4(A0)
	MOVE.L	D1,2(A0)

Sort_NSwap
	ADDQ.L	#6,A0
	SUBQ.W	#1,D0
	BNE.S	Sort_Chunklp
	TST.W	D7					;No swaps! Quit!
	BNE		Sort
Sort_DOne
	RTS

PlotAll
	MOVE.L	o.p2list(a5),a0
	LEA	SceneList,a1
	LEA	ColourCodes(PC),A4				;BLTCONs for COLOURS
	LEA	TEMPPLANE,A2
Plotlp
	TST.L	(A1)						;0 Terminates list...
	BEQ.S	QuitPlot
	MOVE.L	A1,-(SP)
	MOVE.L	(A1),A1						;Recover ptr
;Has to be a plane! nothing else in this routine yet!
	BSR.S	DoPlane
	MOVE.L	(SP)+,A1
	ADDQ.L	#6,A1						;Skip ptr,depth
	BRA.S	Plotlp
QuitPlot
	RTS



DoPlane					;Plane definition in a1
;MUSTNT SCRUNGE a0/a1/a2/a4/a5/a6!!!

	MOVE.L	A1,-(SP)
	MOVE.W	#$015F,D0
	MOVEQ.L	#0,D1
	MOVE.W	D0,D2
	MOVE.W	D1,D3

	MOVE.W	(A1),D7
	SUBQ.W	#1,D7
	ADDQ.L	#4,A1
MINMAXLP
	MOVE.W	(A1),D6
	ADDQ.L	#4,A1
	MOVEM.W	(A0,D6.W),D4/D5
	CMP.W	D0,D4
	BPL.S	lbC00309E
	MOVE.W	D4,D0
lbC00309E	CMP.W	D1,D4
	BLE.S	lbC0030A4
	MOVE.W	D4,D1
lbC0030A4	CMP.W	D2,D5
	BPL.S	lbC0030AA
	MOVE.W	D5,D2
lbC0030AA	CMP.W	D3,D5
	BLE.S	lbC0030B0
	MOVE.W	D5,D3
lbC0030B0
	DBRA	D7,MINMAXLP
	MOVEM.W	D0-D3,WMINX
;Check if polygon window fits in object screen window...
	LEA	OPLDATA(PC),A1
	MOVEM.W	(A1),D4-D7

	CMP.W	D0,D4
	BLE.S	NNMINX
	MOVE.W	D0,D4
NNMINX
	CMP.W	D1,D5
	BGE.S	NNMAXX
	MOVE.W	D1,D5
NNMAXX
	CMP.W	D2,D6
	BLE.S	NNMINY
	MOVE.W	D2,D6
NNMINY
	CMP.W	D3,D7
	BGE.S	NNMAXY
	MOVE.W	D3,D7
NNMAXY
	MOVEM.W	D4-D7,(A1)

	MOVE.L	(SP)+,A1

	BLITWAIT	A6

	MOVEQ.L	#-1,D1				;Set masks+cmod for wipe + line rt
	MOVE.L	D1,bltafwm(A6)
	MOVE.W	#$002C,bltcmod(A6)

	MOVE.W	#BLTPRI,dmacon(A6)

	MOVE.L	(A1)+,D6					; Num lines
	SWAP	D6							; Upper.w=colour Lower.w=Count
	SUBQ.W	#1,D6
PlaneLines
	MOVE.W	(A1)+,D4
	MOVE.W	(A1)+,D5
	MOVEM.W	(A0,D4.W),D0/D1
	MOVEM.W	(A0,D5.W),D2/D3
	CMP.W	D1,D3
	BEQ	lbC003236
	BPL.S	lbC0031A4
	EXG	D2,D0
	EXG	D3,D1
lbC0031A4	SUBQ.W	#1,D3
	SUB.W	D1,D3
	SUB.W	D0,D2
	BPL.S	lbC0031BA
	NEG.W	D2
	MOVEQ.L	#$17,D4
	CMP.W	D3,D2
	BPL.S	lbC0031C4
	MOVEQ.L	#11,D4
	EXG	D3,D2
	BRA.S	lbC0031C4
 
lbC0031BA	MOVEQ.L	#$13,D4
	CMP.W	D3,D2
	BPL.S	lbC0031C4
	MOVEQ.L	#3,D4
	EXG	D3,D2
lbC0031C4	ADD.W	D1,D1
	ADD.W	D1,D1
	MOVE.W	D1,A5
	ADD.W	D1,D1
	MOVE.W	D1,D5
	ADD.W	D1,D1
	ADD.W	D1,D1
	ADD.W	D5,D1
	ADD.W	A5,D1
	LEA	(A2,D1.W),A3
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
	BPL.S	lbC0031F6
	OR.W	#$0040,D4
lbC0031F6	MOVE.W	D1,D0
	SUB.W	D2,D0
	ADDQ.W	#1,D2
	LSL.W	#6,D2
	ADDQ.W	#2,D2
	SWAP	D5
	MOVE.W	D4,D5
	SWAP	D3
	MOVE.W	D0,D3

	BLITWAIT	A6
	MOVE.L	D5,bltcon0(A6)
	MOVE.L	A3,bltcpth(A6)
	MOVE.W	D1,bltaptl(A6)
	MOVE.L	A3,bltdpth(A6)
	MOVE.L	D3,bltbmod(A6)
	MOVE.L	#$FFFF8000,bltbdat(A6)
	MOVE.W	#$002C,bltdmod(A6)
	MOVE.W	D2,bltsize(A6)
lbC003236
	DBRA	D6,PlaneLines

	MOVE.L	CUROBJ,A5				;Recover A5 scrunged by line rt

	MOVE.W	WMAXY,D0
	MOVEQ.L	#$2C,D4
	MULU	D4,D0
	MOVE.W	WMAXX,D1
	LSR.W	#3,D1
	ADD.W	D1,D0

	MOVE.L	D0,D5
	ADD.L	A2,D0
	ADD.L	DrawPtr1,D5
	MOVE.W	WMINX,D2
	LSR.W	#3,D2
	MOVEQ.L	#-2,D3
	AND.B	D3,D1
	AND.B	D3,D2
	SUB.W	D2,D1
	ADDQ.W	#2,D1
	SUB.W	D1,D4
	MOVE.W	WMAXY,D3
	SUB.W	WMINY,D3
	ADDQ.W	#1,D3
	LSL.W	#6,D3
	LSR.W	#1,D1
	ADD.W	D1,D3

;D0=TEMPLPTR,D3=BSIZE,D4=MODULO,D5=DESTPLPOS

	MOVE.W	#SETIT!BLTPRI,dmacon(A6)
; FIll the plane
	BLITWAIT	A6
	MOVE.L	#$09F00012,bltcon0(A6)
	MOVE.L	D0,bltapth(A6)
	MOVE.L	D0,bltdpth(A6)
	MOVE.W	D4,D1
	MOVEM.W	D1/D4,bltamod(A6)
	MOVE.W	D3,bltsize(A6)

	MOVE.L	A4,-(A7)
	SWAP	D6						;Get colour...
	LEA	(A4,D6.W),A4
	BLITWAIT	A6
	MOVE.L	(A4)+,bltcon0(A6)
	MOVE.L	D5,bltbpth(A6)
	MOVEM.L	D0/D5,bltapth(A6)
	MOVE.W	D1,D6
	MOVEM.W	D1/D4/D6,bltbmod(A6)
	MOVE.W	D3,bltsize(A6)

	BLITWAIT	A6
	MOVE.L	(A4)+,bltcon0(A6)
	MOVE.L	#PLLEN,D6
	ADD.L	D6,D5
	MOVE.L	D5,bltbpth(A6)
	MOVEM.L	D0/D5,bltapth(A6)
	MOVE.W	D3,bltsize(A6)

	BLITWAIT	A6
	MOVE.L	(A4)+,bltcon0(A6)
	ADD.L	D6,D5
	MOVE.L	D5,bltbpth(A6)
	MOVEM.L	D0/D5,bltapth(A6)
	MOVE.W	D3,bltsize(A6)
	MOVE.L	(SP)+,A4				;Recover colour list ptr...

;WIPE TEMPORARY PLANE...
	BLITWAIT	A6
	MOVE.L	#(USED*65536)+DESC,bltcon0(A6)
	MOVE.L	D0,bltdpth(A6)
	MOVE.W	D4,bltdmod(A6)
	MOVE.W	D3,bltsize(A6)

	RTS

;MIN/MAX X, M/M Y. 
WMINX	dc.w	0
WMAXX	dc.w	0
WMINY	dc.w	0
WMAXY	dc.w	0


PON	MACRO
	DC.L	$DFC0002
	ENDM
POFF	MACRO
	DC.L	$D0C0002
	ENDM

ColourCODES	;BLTCONs fro each colour of plane...
;COL0
	POFF
	POFF
	POFF
;COL1,etc....
	PON
	POFF
	POFF
	
	POFF
	PON
	POFF

	PON
	PON
	POFF

	POFF
	POFF
	PON

	PON
	POFF
	PON
	
	POFF
	PON
	PON

	PON
	PON
	PON

; Dbuff rt... swap window defs over, swap copper planes
DoubleBuffer

	LEA	OplDatA(PC),A0
	LEA	OplDatOld(PC),A1
	MOVEM.W	(A0),D0-D3
	MOVEM.W	(A1),D4-D7
	MOVEM.W	D4-D7,(A0)
	MOVEM.W	D0-D3,(A1)

DoubleBuffer_Insert
	MOVE.L	DrawPtr1,D0
	MOVE.L	DrawPtr2,DrawPtr1
	MOVE.L	D0,DrawPtr2
	LEA	CopPLptr(PC),A0
	MOVE.L	#PLLEN,D1	; Plane offsets
	MOVEQ.L	#2,D7
DBuffpl_lp	MOVE.W	D0,4(A0)
	SWAP	D0
	MOVE.W	D0,(A0)
	SWAP	D0
	ADD.L	D1,D0
	ADDQ.L	#8,A0
	DBRA	D7,DBuffpl_lp
	RTS	
 
WipeOldPlanes				;DOES  !NOT! BLITWAIT for last plane
	LEA	OPlData(PC),A0
	MOVE.L	DRAWPTR1,D5

	MOVE.W	6(A0),D0
	BEQ	WipeW_nopl

	MOVE.W	#$2C,D4
;
	MULU	D4,D0
;
	MOVE.W	2(A0),D1
	BEQ	WipeW_nopl
	LSR.W	#3,D1
	EXT.L	D1
	ADD.L	D1,D0
	ADD.L	D5,D0		;OFFSET+DEST ADDR
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
	MOVE.L	#USED*65536+DESC,bltcon0(A6)
	MOVEQ.L	#-1,D1
	MOVE.L	D1,bltafwm(A6)
	MOVE.L	D0,bltdpth(A6)
	MOVE.W	D4,bltdmod(A6)
	MOVE.W	D3,bltsize(A6)

	MOVE.L	#PLLEN,D1

;Wipe next plane (#1)
	ADD.L	D1,D0
	BLITWAIT	A6
	MOVE.L	D0,bltdpth(A6)
	MOVE.W	D3,bltsize(A6)

;Wipe next plane (#2)
	ADD.L	D1,D0
	BLITWAIT	A6
	MOVE.L	D0,bltdpth(A6)
	MOVE.W	D3,bltsize(A6)

WipeW_nopl	RTS
 
GenInit
	BSR DoubleBuffer_Insert
	BSR	InitPTab						; Perspective
	BSR InitWipe
	Move.l	CurObj,A0
	BSR	InitObj							; Initialise vector obj...
	RTS	
 

; Set up perspective table...
InitPTab
	LEA	PerspTab(PC),A0
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
	MOVE.L	A0,D0
    ADD.L   D0,o.ppList(A0) ; Relocate it!
    ADD.L   D0,o.prlist(A0)
    ADD.L   D0,o.p2List(A0)
    ADD.L   D0,o.pDList(A0)

	Move.l	o.pDList(A0),A0
; INit planes...
InitP_olp
	MOVE.W	(A0)+,D6	; Get no. edges
	BEQ.S	InitPFin	; 0 : endsig
	ADD.W	D6,D6		; 2*as many point nos
;Process colour...
	MOVE.W	(A0),D0
	MULU	#3*4,D0		; Colour table is 12 bytes per colour
	MOVE.W	D0,(A0)+

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

InitWipe					; Wipe all starting planes
	MOVE.L	DrawPtr1,A0
	MOVE.L	DrawPtr2,A1
	MOVE.L	#PLLEN*3/4,D0
Iwipe1
	CLR.L	(A0)+
	CLR.L	(A1)+
	SUBQ.L	#1,D0
	BNE.S	Iwipe1

	LEA	TempPlane,A0
	MOVE.L	#PLLEN/4,D0
Iwipe2	CLR.L	(A0)+
	SUBQ.L	#1,D0
	BNE.S	Iwipe2

	RTS
		
AngAct	ds.w	3			; Actual x,y,z angles
AngMod	dc.w	10,2,4		; Angle x,y,z additions
NumSort	dc.w	0			; No planes to be sorted
ObjZDistance	dc.w	$600 ; SMALLER> BIGGER OBJ! NO CLIPPING!!!
                          
OplData		dc.w	0,0,0,0	;MAX/MIN X,Y FOR ALL PLANES!

OplDatOld	dc.w	0,0,0,0

CurObj		dc.l	Object

DrawPtr1	dc.l	SCREEN1
DrawPtr2	dc.l	SCREEN2

MY_Copper
	dc.w	diwstrt,$2A71,diwstop,$36D1
	dc.w	ddfstrt,$30,ddfstop,$D8
	dc.w	bplcon0,$3200
	dc.w	bplcon1,0,bplcon2,0
	dc.w	bpl1mod,0,bpl2mod,0

    IFEQ    RASTERCHECK
	dc.w	$180,0
    ENDC
	dc.w	$182,$f00,$184,$d00,$186,$b00,$188,$900
	dc.w	$18A,$700,$18C,$500,$18E,$411
	dc.w	bpl1pth
CopPLptr	dc.w	0,bpl1ptl,0
	dc.w	bpl2pth,0,bpl2ptl,0
	dc.w	bpl3pth,0,bpl3ptl,0

	dc.w	$FFFF,$FFFE

PerspTab	    ds.w    8000

SinTab      incbin  MYVECT.SINTAB


;=========================================================================
	rsreset
o.wInit		rs.w	1		;NZERO once init
o.wMxPts	rs.w	1		;max points
o.pPList	rs.l	1		;Points to rot
o.pRList	rs.l	1		;Rotated/treated list
o.p2List	rs.l	1		;Persped list
o.pDList	rs.l	1		;Draw item list

Object
	dc.w	0				        ;Set to NZERO once initialised!
	dc.w	9				        ;TOTAL no points
	dc.l	ObjPointList-Object	    ;Ptr to point list
	dc.l	ObjRotList-Object		;`Treated` 3d list
	dc.l	ObjXYList-Object		;2d list of persp points
	dc.l	ObjDrawList-Object		;List of components (planes only at mo!)
	
ObjRotList	ds.w	9*3
ObjXYList	ds.w	9*2
ObjPointList
	dc.w	9				;no points to rotate

	dc.w	0,0,0

	dc.w	-300,300,600
	dc.w	-300,-300,600
	dc.w	300,-300,600
	dc.w	300,300,600

	dc.w	-300,300,-600
	dc.w	-300,-300,-600
	dc.w	300,-300,-600
	dc.w	300,300,-600



ObjDrawList				   ;PLANES ONLY: no edges,colour,point pairs

	dc.w	3,1
	dc.w	0,2,2,3,3,0

	dc.w	3,2
	dc.w	0,3,3,4,4,0

	dc.w	3,3
	dc.w	0,4,4,1,1,0

	dc.w	3,4
	dc.w	0,1,1,2,2,0

	dc.w	4,6
	dc.w	4,3,3,2,2,1,1,4


	dc.w	3,2
	dc.w	0,7,7,6,6,0
	dc.w	3,3
	dc.w	0,8,8,7,7,0
	dc.w	3,4
	dc.w	0,5,5,8,8,0
	dc.w	3,5
	dc.w	0,6,6,5,5,0
	dc.w	4,6
	dc.w	8,5,5,6,6,7,7,8

	dc.w	0	;ENDSIG!

	SECTION	ABBA,BSS_C

SCREEN1 DS.B PLLEN*3

SCREEN2 DS.B PLLEN*3

TEMPPLANE	DS.B	PLLEN

SCENELIST	DS.W	3*MAXPLANES

	END
