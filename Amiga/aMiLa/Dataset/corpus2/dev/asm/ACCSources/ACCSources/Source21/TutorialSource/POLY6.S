
    OPT C-,O+

****************************
*	   1 PLANE STARTUP	   *
*	  OVERSCANNED + VBI    *
*       SET TABS TO 4      *
* P.KENT 10.1.92           *
****************************
*  POLYGON CLIPPING DEMO!  *
*30.1.92  CRASHES SOMETIMES*
*         UNABLE TO TRACK  *
*         DOWN BUG!        *
*3.2.92   RECODED. OK NOW? *         
****************************

;NB. THIS CODE IS VERY SLOW IN THE POLYGON FILLING
;DEPARTMENTS. FOR HIGHER SPEEDS, ONLY AREA OCCUPIED BY POLYGON
;MUST BE FILLED/WIPED!
;-DETERMINE MIN/MAX X,Y COORDS FOR ALL POLYS
;-FILL THAT BOX ONLY (MODULO OVER REST OF BITPLANE)
;-WIPE THAT BOX ONLY -//-
;-COULD ALSO KEEP MIN/MAX VALUES FOR EACH BITPLANE! HENCE IF ALL
;DRAW GFX ARE 1 COLOUR, WILL NOT WASTE TIME WIPING/FILLING 'EMPTY' SPACE!
;SEE THE FILE 'FILLWINDOW.S' FOR MOST OF THE ABOVE CODE!

    SECTION DIFFERENTIAL_EQUATIONS,CODE_C
	INCLUDE	Source:include/HARDWARE.I
	INCLUDE	Source:p.kent/MYMACROS.I
	INCLUDE	Source:p.kent/HWSTART.S
	INCLUDE	Source:p.kent/LOADPOINTERS.S
		
RASTERCHECK =   0   ;1 FOR TIMING BACKGROUND, 0 BLACK, VBI ONLY

****************************
*     SCREEN SIZES         *
****************************
;SCREEN IS 352 ($2C WIDB), 268 HGT
NPL = 2
PLWIDW = 22
PLWIDB = PLWIDW*2
PLHGT  = 268
PLLEN = PLWIDB*PLHGT

ENDSIG  = $8000						; End sigs for polys/lists
POLYEND = $8001


_BOOT
	LEA	CUSTOM,A6
	CATCHVB	A6	        			; Wait for VBL
	MOVE.W	#SETIT!DMAEN!BPLEN!BLTEN!COPEN!BLTPRI,dmacon(A6)

	BSR.S	SetCopper				; Put in ptrs.
;Other inits...
	
	MOVE.L	#MY_Copper,cop1lch(A6)	; Just set dma/ints and wait!
	MOVE.W	D0,COPJMP1(A6)
	MOVE.L	#MY_VBI,$6C.W
	MOVE.L	#(SETIT!INTEN!VERTB)*65536+$7FFF,intena(A6)
									; My ints + zap intreq!

MLP
	BSR	DBuffer						; Switch views
	BSR	DoAnim						; Scale/Recentre coords
	BSR	PlotPolys					; Draw polygon lines
	BSR FillVPlane					; Fill plane
	CMP.W	#2,AnimPos
	BEQ.S	QUIT
	MOUSE	MLP
QUIT
	RTS	
 
 
MY_VBI
	MOVEM.L	D0-D7/A0-A6,-(SP)
	LEA	CUSTOM,A6

    IFNE    RASTERCHECK
    MOVE.W  #$300,$180(A6)
    ENDC
;Int code here...

;
    IFNE    RASTERCHECK
    MOVE.W  #0,$180(A6)
    ENDC

	MOVE.W	#INTEN!VERTB,intreq(A6)
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTE	

SetCopper
	Lea	Screen,a0
	Lea	Plptr1(pc),a1
	moveq	#npl,d1
	move.w	#plwidb,d2
	BSR	LoadPointers
	rts

MY_Copper
	dc.w	diwstrt,$2A71,diwstop,$36D1
	dc.w	ddfstrt,$30,ddfstop,$D8
	dc.w	bplcon0,BPU1!COLOR
	dc.w	bplcon1,0,bplcon2,0
	dc.w	bpl1mod,PLWIDB*(NPL-1),bpl2mod,PLWIDB*(NPL-1)

    IFEQ    RASTERCHECK
	dc.w	COLOR00
    ENDC
	IFNE	RASTERCHECK
	dc.w	COLOR01
	ENDC
ColPtr1	dc.w	0,COLOR01,$855
	dc.w	COLOR02,$585,COLOR03,$558
	dc.w	bpl1pth
Plptr1	dc.w	0,bpl1ptl,0
	dc.w	bpl2pth,0,bpl2ptl,0
	dc.w	$FFFF,$FFFE

;DOUBLE BUFFERING ROUTINE...
;Puts screen,screen2 alternately in copper
;VectPlptr is DRAW screen.

DBuffer
	BLITWAIT	A6					; Wait for any drawing to finish
	CATCHPOS	A6,312				; Wait for bottom of frame

	CMP.L	#SCREEN,VectPlPtr		; Exchange ptrs...
	BEQ.S	DBuffScrn2
	MOVE.L	#SCREEN2,A0
	MOVE.L	#SCREEN,VectPlPtr
	BRA.S	DBuffPutIt
DBuffScrn2	MOVE.L	#SCREEN2,VectPlPtr
	MOVE.L	#SCREEN,A0
DBuffPutIt
	Lea	Plptr1(pc),a1				; Poke in copper list, A0 bitmap
	moveq	#npl,d1
	move.w	#plwidb,d2
	BSR	LoadPointers
	MOVE.L	VectPlPtr,A0
	WIPE	A6,A0,#PLHGT*64+PLWIDW	;NEEDS REPTING IF 2+ PLANES
	LEA	PLHGT*PLWIDB(A0),A0		;INTENTIONALLY SKIPBOTTOM DISPLAY LINE
	WIPE	A6,A0,#(PLHGT-1)*64+PLWIDW
	RTS	

FillVPlane	
	BLITWAIT	A6
	MOVE.L	#$09F00012,BLTCON0(A6)	;CON0/1
	MOVE.L	#-1,BLTAFWM(A6)			;F/L WORD MASKS
	MOVE.L	#0,BLTAMOD(A6)			;A/D MODS
	MOVE.L	VectPlPtr,D0
	ADD.L	#(NPL*PLLEN)-2,D0
	MOVE.L	D0,BLTAPTH(A6)			;PTRS
	MOVE.L	D0,BLTDPTH(A6)
	MOVE.W	#NPL*PLHGT*64+PLWIDW,BLTSIZE(A6)
	RTS	

DoAnim
	LEA		SRCCOORDS(PC),A0
	LEA		POINTLIST(PC),A1

DoAnimlp
	MOVEM.W	(A0)+,D1/D2					; Get coords
	CMP.W	#ENDSIG,D1
	BEQ.S	DoAnim_Fin
	MULS	#$400,D1					; Scale coords up...
	MULS	#$400,D2
	MOVE.W	VectSize,D4
	DIVS	D4,D1
	DIVS	D4,D2
	ADD.W	XCENTRE,D1
	ADD.W	YCENTRE,D2					; YCentre
	MOVE.W	D1,(A1)+
	MOVE.W	D2,(A1)+
	BRA.S	DoAnimlp
DoAnim_Fin
	TST.W	AnimPos
	BNE.S	NMode0
	CMP.W	#$400,VectSize				; Finished zooming ?
	BGE.S	NMode0
	ADDQ.W	#8,VectSize					; Zoom in at start
	RTS 
NMode0
	MOVE.W	#1,AnimPos
	SUBQ.W	#1,AnimPauseCnt
	BNE.S	.Ret
	MOVE.W	#1,AnimPauseCnt
	CMP.W	#PLHGT+50,YCENTRE			; Finished overall ?
	BNE.S	AnimVOut
	MOVE.W	#2,AnimPos
.RET	RTS	 
AnimVOut
	ADDQ.W	#1,YCENTRE					; Slide down at end
	RTS	


;Polys are (eg) a,b,b,c,c,a,polyend WORDS (a,b,c = coord no.s)

PlotPolys
	BLITWAIT	A6
	MOVE.L	#-1,bltafwm(A6)		;HW regs same for all lines!
	MOVE.L	#$FFFF8000,bltbdat(A6)
	MOVE.W	#PLWIDB*NPL,bltcmod(A6)

	LEA	PointList(PC),A4		;x,y coord pairs
	LEA	PolyPtrList(PC),A5		;connect ptrs
	LEA	EdgedList(PC),A2		;outlist for right hand edges
PolyChk
	MOVE.L	(A5)+,A1			;Get ptr
	CMP.L	#ENDSIG,A1
	BNE.S	IsAPoly
	RTS	
 
IsAPoly
	BSR	ProcPolyIn				;Process poly
	MOVE.L	(A5)+,A1			;Repeat for any more...
	CMP.L	#ENDSIG,A1
	BNE.S	IsAPoly

PolyPrintFIn
	MOVE.W	#ENDSIG,(A2)		;Terminate RH edge list
	LEA	EdgedList(PC),A2
DoPolyEdgelp					;CLose Rh poly gon edges
	MOVEM.W	(A2)+,D0/D1
	CMP.W	#ENDSIG,D0
	BEQ.S	PolyEdgesDone
	MOVE.W	(A2)+,PolyShade
	MOVEM.W	(A2)+,D2/D3
	ADDQ.L	#2,A2
	BSR	FLine
	CMP.W	#ENDSIG,(A2)
	BNE.S	DoPolyEdgelp
PolyEdgesDone
	RTS							;FIN
 
PolyShade	dc.w	0

ProcPolyIn						;enter with a1=polygon:
								;colour.w,coord pairs .2w,POLYEND
	MOVE.W	(A1)+,PolyShade		;Get colour
;Main line scanner loop for a polygon
ProcPoly
	MOVEM.W	(A1)+,D1/D3			;Point nos
	CMP.W	#POLYEND,D1
	BNE.S	PP_GetPts
	RTS	
 
PP_GetPts
	ADD.W	D1,D1				;Multiply nos by 4
	ADD.W	D1,D1

	ADD.W	D3,D3
	ADD.W	D3,D3
	MOVEM.W	(A4,D1.W),D0/D1		;Get coords NB sign extended to .L
	MOVEM.W	(A4,D3.W),D2/D3

	CMP.L	D0,D2				;Set line direction LEFT>RIGHT
	BGT.S	PP_DirnOK
	EXG	D2,D0
	EXG	D3,D1
PP_DirnOK
	CMP.L	#PLWIDB*8,D2		;Futhest right edge on screen ?
	BLT.S	Clip_ROK
	CMP.L	#PLWIDB*8-1,D0		;Line off right of screen ?
	BGT.S	ProcPoly

	MOVE.L	D1,D7
	SUB.L	D3,D7				;y1-y2
	MOVE.L	#PLWIDB*8,D6
	SUB.L	D0,D6
	MULS	D6,D7				;(RH-X1)(Y1-Y2)
	MOVE.L	D2,D6
	SUB.L	D0,D6				;D6=X2-X1
	BEQ.S	ProcPoly			;HORIZONTAL. NOT INTERESTED.
	DIVS	D6,D7				;(RH-X1)(Y1-Y2)/(X2-X1)
	EXT.L	D7
	MOVE.L	D1,D3
	SUB.L	D7,D3				;Y2=Y1- ABOVE
	MOVE.L	#PLWIDB*8-1,D2
	MOVE.W	D2,(A2)+			;SAVE EDGE COORDS
	MOVE.W	D3,(A2)+
	MOVE.W	PolyShade,(A2)+		;SAVE COLOUR
Clip_ROK
	CMP.L	#0,D0				;Check left edge
	BGT.S	Clip_LOK
	CMP.L	#0,D2				;Line off left...
	BLT.S	ProcPoly

	MOVE.L	D3,D7
	SUB.L	D1,D7				;d7=y2-y1
	MOVE.L	D2,D6
	SUB.L	D0,D6				;d6=x2-x1
	BEQ.S	ProcPoly			;No horizontals!

	MULS	D2,D7				;x2(y2-y1)
	DIVS	D6,D7				;x2(y2-y1)/(x2-x1)
	EXT.L	D7
	MOVE.L	D3,D1
	SUB.L	D7,D1				;y1=y2-ABOVE
	MOVEQ.L	#0,D0				;x1=0
Clip_LOK

	CMP.L	D1,D3				;Want line top>bottom
	BGT.S	DirnOK2
	EXG	D2,D0
	EXG	D3,D1
DirnOK2
	CMP.L	#0,D1
	BGT.S	Clip_TOK
	CMP.L	#0,D3
	BLT	ProcPoly

	MOVE.L	D2,D7				;Top clip
	SUB.L	D0,D7
	MOVE.L	D3,D6
	SUB.L	D1,D6
	BEQ	ProcPoly
	MULS	D3,D7
	DIVS	D6,D7
	EXT.L	D7
	MOVE.L	D2,D0
	SUB.L	D7,D0
	MOVEQ.L	#0,D1
Clip_TOK	

	CMP.L	#PLHGT-1,D3			;Bottom clip ?
	BLS.S	Clip_BOK
	CMP.L	#PLHGT-1,D1
	BGT	ProcPoly

	MOVE.L	D0,D7				;Bottom clip
	SUB.L	D2,D7
	MOVE.L	#PLHGT-1,D6
	SUB.L	D1,D6
	MULS	D6,D7
	MOVE.L	D3,D6
	SUB.L	D1,D6
	BEQ	ProcPoly				;No horizontals
	DIVS	D6,D7
	EXT.L	D7
	MOVE.L	D0,D2
	SUB.L	D7,D2
	MOVE.L	#PLHGT-1,D3
	
Clip_BOK
	BSR.S	FLine				;Do line,loop again!
	BRA	ProcPoly
	
FLine
	MOVE.W	#PLWIDB*NPL,D5
	MOVE.L	VectPlPtr,A0
	CMP.W	D1,D3
	BGT.S	Fline_Dirn
	EXG	D2,D0
	EXG	D3,D1
	BEQ	SkipLine
FLine_Dirn
	MOVE.W	D1,D4
	MULS	D5,D4
	MOVE.W	D0,D5
	ADD.L	A0,D4
	ASR.W	#3,D5
	ADD.W	D5,D4
	MOVEQ.L	#0,D5
	SUB.W	D1,D3
	SUB.W	D0,D2
	BPL.S	FL_1
	MOVEQ.L	#1,D5
	NEG.W	D2
FL_1
	MOVE.W	D3,D1
	ADD.W	D1,D1
	CMP.W	D2,D1
	DBHI	D3,Fl_Fix
FL_Fix
	MOVE.W	D3,D1
	SUB.W	D2,D1
	BPL.S	FL_2
	EXG	D3,D2
FL_2
	ADDX.W	D5,D5
	ADD.W	D2,D2
	MOVE.W	D2,D1
	SUB.W	D3,D2
	ADDX.W	D5,D5
	AND.W	#15,D0
	ROR.W	#4,D0
	OR.W	#$0A6A,D0			;Mode word
	MOVE.W	PolyShade,D7
	BLITWAIT	A6	
	MOVE.W	D2,bltaptl(A6)
	SUB.W	D3,D2
	LSL.W	#6,D3
	ADDQ.W	#2,D3
	MOVE.W	D0,bltcon0(A6)
	MOVE.B	FLine_Codes(PC,D5.W),bltcon1+1(A6)
	MOVE.L	D4,bltcpth(A6)
	MOVE.L	D4,bltdpth(A6)
	MOVEM.W	D1/D2,bltbmod(A6)

;Once hardware values have been set, only need to reset
;changing values...

	BTST	#0,D7				;Repeat this section for multiple planes!
	BEQ.S	FLINE_NOPL1
	MOVE.W	D3,bltsize(A6)	
FLINE_NOPL1

	ADD.W	#PLWIDB,D4			;2nd plane
	BTST	#1,D7
	BEQ.S	FLINE_NOPL2
	BLITWAIT	A6
	MOVE.W	D0,bltcon0(A6)
	MOVE.L	D4,bltcpth(A6)
	MOVE.L	D4,bltdpth(A6)
	MOVE.W	D3,bltsize(A6)

FLINE_NOPL2
SkipLine
	RTS
	


 
FLine_Codes	dc.b	3,$43,$13,$53,11,$4B,$17,$57	;Filled octant codes


AnimPauseCnt	dc.w	25		; Time for pause when zoomed
AnimPos			dc.w	0		; Sig for anim position
VectSize		dc.w	$100	; Scale factor (bigger=smaller graphic!)

XCentre			dc.w	plwidb*4	; Polygon centres
YCentre			dc.w	plhgt/2


PolyPtrList		dc.l	Poly1,ENDSIG		; List of polys in order to print

;Test 'X'
Poly1	; Colour,coord pairs,end
	dc.w	2								; colour = 3 (1-3 in this setup)
	dc.w	0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8
	dc.w	8,9,9,10,10,11,11,12,12,13,13,14,14,15
	dc.w	15,0,POLYEND
SrcCoords	;NB 0,0 is top left corner! Greater Y = lower down!

			dc.w	-20,0	;0
			dc.w	-40,20	
			dc.w	-40,40	;2
			dc.w	-20,40
			dc.w	0,20	;4
			dc.w	20,40
			dc.w	40,40	;6
			dc.w	40,20
			dc.w	20,0	;8
			dc.w	40,-20
			dc.w	40,-40	;10
			dc.w	20,-40
			dc.w	0,-20	;12
			dc.w	-20,-40
			dc.w	-40,-40	;14
			dc.w	-40,-20
		
			dc.w	ENDSIG


PointList	ds.l	100
EdgedList	ds.l	3*100					; Up to 100 rh edges

VectPlPtr	dc.l	SCREEN

    SECTION	VIEWME,BSS_C
	DS.B	PLWIDB*NPL						; 1 extra line either side due to
											; paranoia while debugging!
SCREEN      DS.B	NPL*PLLEN				; View planes
SCREEN2		DS.B	NPL*PLLEN
	DS.B	PLWIDB*NPL
	
