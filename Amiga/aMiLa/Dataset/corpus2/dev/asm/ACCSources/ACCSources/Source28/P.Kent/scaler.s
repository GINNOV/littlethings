	OPT	C-,L-,D+

****************************************************************************
*                            PICTURE SCALER                                *
*                                                                          *
*                  Zooms a 200 hgt picture onto screen                     *
*              Make of this what you will, but please note                 *
*                     > I DID NOT WRITE THIS CODE <                        *
*               I have adjusted & legalized it a bit, but                  *
*               the bulk of the code is not by me - I do                   *
*            not know who the original author(s) is/are but                *
*               take no credit for the DoScale subroutine                  *
*                                                                          *
*                               P.Kent '92                                 *
****************************************************************************

;My variable block:
	rsreset
SysDMA  rs.w	1					; old system dma
SysINT  rs.w	1					; -/-        int
SysCop	rs.l	1					; -/-        copper
SysCPI  rs.l	1					; -/-        $6c interrupt vector
;
Showpl	rs.l	1					; Ptr to planes on show
Drawpl  rs.l	1					; ptr to draw planes
ImgSize rs.w	1					; Size of image (0>160)
CPISig	rs.w	1					; Set non-zero every CopperInterrupt
;
VarLen	rs.w	1					; Dummy to get length of block

	incdir	source:P.Kent/
	INCLUDE	INCLUDES/HARDWARE.I
	SECTION	SQUEEGEE,CODE_C

	MOVEM.L	D1-D7/A0-A6,-(A7)
	LEA	MyVars,A5
	BSR.s	Setup
	MOVE.L	#Main,$80.W
	TRAP #0
	BSR.s	FreeHW
	MOVEM.L (A7)+,D1-D7/A0-A6
	MOVEQ	#0,D0
	RTS	

Setup
	MOVE.L	4.W,A6
	LEA	GfxLib(PC),A1
	MOVEQ	#0,D0
	JSR	-$228(A6)
	MOVE.L	D0,A1
	MOVE.L	$26(A1),SysCop(A5)			; Save OS copper list
	JSR	-$19E(A6)
	LEA	CUSTOM,A6
	MOVE.W	intenar(A6),SysINT(A5)
	MOVE.W	dmaconr(A6),SysDMA(A5)
	MOVE.L	$6C.W,SysCPI(A5)
	MOVE.W	#$7FFF,D0				; Zap INTS/DMA
	MOVE.W	D0,intena(A6)
	MOVE.W	D0,intreq(A6)
	MOVE.W	D0,dmacon(A6)
	BSR Init						; Initialization
	MOVE.L	#MyVBI,$6C.W
	MOVE.L	#ScaleCopper,cop1lch(A6)
	MOVE.W	d0,copjmp1(A6)
	MOVE.W	#SETIT!INTEN!COPER,intena(A6)
	MOVE.W	#SETIT!DMAEN!BPLEN!BLTEN!COPEN!BLTPRI,dmacon(A6)
	RTS	
 
FreeHW
	MOVE.L	SysCPI(A5),$6C.W
	MOVE.L	SysCop(A5),cop1lch(A6)
	MOVE.W	SysINT(A5),D0
	OR.W	#$C000,D0
	MOVE.W	D0,intena(A6)
	MOVE.W	SysDMA(A5),D0
	OR.W	#$8100,D0
	MOVE.W	D0,dmacon(A6)
	RTS	
 
GfxLib	dc.b	'graphics.library',0
	even

MyVBI	MOVEM.L	D0-D7/A0-A6,-(SP)
	AND.W	#COPER,CUSTOM+INTREQR
	BEQ.S	MyVBI_No
	MOVE.W	#COPER,CUSTOM+INTREQ
	MOVE.W	#1,CPISig+MyVars
MyVBI_No	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTE	
 
 
Main
	CLR.W	ImgSize(A5)
	BSR.S	RunScale

Mlp	BTST	#6,$bfe001
	Bne.S	Mlp

SquishOut
	BSR WaitCPI
	Bsr VertSquash
	SUBQ.W #1,ImgSize(A5)
	TST	ImgSize(A5)
	BNE.S	SquishOut

	RTE	

RunScale
	MOVE.W	ImgSize(A5),D0
	MOVE.L	Showpl(A5),A0
	LEA	4*$28(A0),A0
	MOVE.L	Drawpl(A5),A1
	LEA	4*$28(A1),A1
	LEA	ScaleLogo.gfx,A4
	BSR	DoScale
	BSR	HandleFrame

	ADDQ.W	#1,ImgSize(A5)
	CMP.W	#160,ImgSize(A5)
	BLT.S	RunScale
	RTS	
 
Init
	BSR	ScalePreCalc				; Calc all tables for scaling
	MOVE.L	#Screen1,Showpl(A5)		; Put in dbuffer ptrs
	MOVE.L	#Screen2,Drawpl(A5)

; Make copper list
; Consists of Wait,bpl1mod,x,bpl2mod,x

	MOVE.L	#$2C07FFFE,D1			; Start wait
	MOVE.L	#BPL1MOD<<16+$78,D2
	MOVE.L	#BPL2MOD<<16+$78,D3
	MOVE.L	#$01000000,D4			; Add factor - one line
	MOVE.L	#$F507FFFE,D5			; End wait : inclusive
	LEA	ScaleCopBase(PC),A0
MakeCop_lp	MOVE.L	D1,(A0)+
	MOVE.L	D2,(A0)+
	MOVE.L	D3,(A0)+
	ADD.L	D4,D1					; Next line
	CMP.L	D5,D1
	BCS.S	MakeCop_lp

	MOVE.L	Showpl(A5),D0			; Setup planes
	BSR.S	PutPlanes

	LEA	ScaleCols,A0				; Load colours into copper
	LEA	ScaleCopCols(PC),A1
	MOVE.W	#15,D0
CopyCols_lp	MOVE.W	(A0)+,(A1)
	ADDQ.L	#4,A1
	DBRA	D0,CopyCols_lp

	RTS	
 
WaitCPI
	MOVE.W	#0,CPISig(A5)			; Wait for copper int
WaitCPI_lp
	TST.W	CPISig(A5)
	BEQ.S	WaitCPI_lp
	RTS

PutPlanes
	MOVEQ	#40,D1
	Lea	ScalePl(PC),A0
	MOVE.W	D0,(A0)			; Insert new planes
	SWAP	D0
	MOVE.W	D0,4(A0)
	SWAP	D0
	ADD.L	D1,D0
	MOVE.W	D0,8(A0)
	SWAP	D0
	MOVE.W	D0,12(A0)
	SWAP	D0
	ADD.L	D1,D0
	MOVE.W	D0,16(A0)
	SWAP	D0
	MOVE.W	D0,20(A0)
	SWAP	D0
	ADD.L	D1,D0
	MOVE.W	D0,24(A0)
	SWAP	D0
	MOVE.W	D0,28(A0)
	RTS

HandleFrame
	MOVE.L	Showpl(A5),D1			; Double buffer
	MOVE.L	Drawpl(A5),D0
	MOVE.L	D0,Showpl(A5)
	MOVE.L	D1,Drawpl(A5)
	BSR.S WaitCPI
	BSR.S PutPlanes
	BSR.S VertSquash
	RTS

VertSquash
;Do vertical squashing of image...

	MOVE.L	#ScaleCop_Mods,D0		; initially set all modulos to -$28
HF_Bchk	BTST	#6,dmaconr(A6)
	BNE.S	HF_Bchk
	MOVE.L	D0,bltdpth(A6)
	MOVE.W	#-$28,bltadat(A6)
	MOVE.W	#10,bltdmod(A6)
	MOVE.L	#-1,bltafwm(A6)
	MOVE.L	#$01F00000,bltcon0(A6)	; D 'copy' only
	MOVE.W	#201*64+1,bltsize(A6)	; 201 lines of copper list

	MOVE.W	ImgSize(A5),D1			; Get size => LW offset
	ADD.W	D1,D1
	ADD.W	D1,D1
	LEA	VScaleTabLookup,A0
	MOVE.L	(A0,D1.W),A0			; Get ptr to VScaleTab entry

	MOVE.W	(A0)+,D1				; Get Offset in copper
	MOVE.W	(A0)+,D2				; Get no. to place
	BEQ.S	HF_BChk3
	LSL.W	#6,D2					; *64 = Blit height
	ADDQ.W	#1,D2
	EXT.L	D1						; Extend and add offset
	ADD.L	D0,D1

HF_BChk2	BTST	#6,dmaconr(A6)
	BNE.S	HF_BChk2

	MOVE.L	A0,bltapth(A6)			; A>D copy...
	MOVE.L	D1,bltdpth(A6)
	MOVE.W	#$09F0,bltcon0(A6)
	MOVE.W	#0,bltamod(A6)			; NO source modulo, dmod already set
	MOVE.W	D2,bltsize(A6)

; Now copy all bpl1mods to bpl2mods!
; 0    2  4       6 8       10
; wait,-2,bpl1mod,x,bpl2mod,x

HF_BChk3	BTST	#6,dmaconr(A6)
	BNE.S	HF_BChk3
	MOVE.L	D0,bltapth(A6)
	ADDQ.L	#4,D0
	MOVE.L	D0,bltdpth(A6)
									
	MOVE.W	#10,bltamod(A6)			; 10 bytes per copper line as per table
									; above
	MOVE.W	#$09F0,bltcon0(A6)
	MOVE.W	#201*64+1,bltsize(A6)	; 201 lines of copper, 1 word entries

HF_BChk4
	BTST	#6,dmaconr(A6)
	BNE.S	HF_BChk4
	RTS	
 
ScalePreCalc
	LEA	ScaleNewPixelTab,A0
	LEA	ScalePixelDat,A1
	MOVEQ	#16-1,D0
MakeSNPT_lp
	LEA	ScaleWordDat,A2			; Word offset list
	MOVE.W	(A1)+,D1				; Get pix (0>15) number
	MOVEQ	#10-1,D2
MakeSNPT_ilp
	MOVE.W	(A2)+,D3				; Get word num
	ASL.W	#4,D3					; *16
	ADD.W	D1,D3
	MOVE.W	D3,(A0)+				; Save pixel no.
	DBRA	D2,MakeSNPT_ilp
	DBRA	D0,MakeSNPT_lp

	LEA	RefTab2,A0
	MOVE.W	#160-1,D0
	MOVE.W	#$07D0,D1
MakeRT2_lp
	MOVE.W	D1,(A0)+
	DBRA	D0,MakeRT2_lp

	LEA	ScaleNewPixelTab,A0
	LEA	RefTab1,A1
	LEA	RefTab2,A2
	CLR.W	D0
MakeMain_lp
	MOVE.W	0(A0,D0.W),D1
	MOVEQ.L	#-2,D2
MakeMain_Cmplp	ADDQ.W	#2,D2
	CMP.W	0(A2,D2.W),D1
	BGT.S	MakeMain_Cmplp
	LEA	159*2(A2),A3
	LEA	0(A2,D2.W),A4
MakeMain_Coplp
	MOVE.W	-(A3),2(A3)
	CMP.L	A4,A3
	BHI.S	MakeMain_Coplp

	MOVE.W	D1,(A4)
	LSR.W	#1,D2
	MOVE.W	D2,(A1)+
	ADDQ.W	#2,D0
	CMP.W	#160*2,D0
	BCS.S	MakeMain_lp

;Make vertical scale tables....

;Build up a modulo table : modulo required to skip n lines
;Eg. 2 lines = 2*4*$28+3*$28 to skip next two lines, and have correct
;modulo for interleaved planes

	LEA	VScaleTabRef,A2
	CLR.W	(A2)+
	MOVE.W	#3*$28,D0
	MOVE.W	#4*$28,D1
	MOVE.W	#100,D2
MakeVScaleTabRef_lp
	MOVE.W	D0,(A2)+
	ADD.W	D1,D0
	DBRA	D2,MakevScaletabRef_lp

	LEA	VScaleTab,A0
	LEA	VScaleTabLookup,A1
	LEA	VScaleTabRef,A2
	MOVEQ.L	#1,D7					; Start height
	MOVE.L	A0,(A1)+				; Ptr, info dummy for zero hgt
	MOVE.L	#0,(A0)+
MakeVScaleTab_lp
	MOVE.L	A0,(A1)+				; Save ptr
	MOVEQ.L	#0,D6
	MOVE.W	D7,D0
	MOVE.W	D7,D2
	MULU	#$A000,D0				; Hgt*40960
	MOVE.L	#$640000,D1				; 160*40960
	SUB.L	D0,D1					; 40960*(160-hgt)
	SWAP	D1						; (160-hgt)*40960/65536

;D1 = Copper start line : calc offset in copper...

;Copper has 12 bytes per line

	ADD.W	D1,D1
	ADD.W	D1,D1
	ADD.W	D1,D6					; D6=calc*4
	ADD.W	D1,D1
	ADD.W	D1,D6					; D6=calc*12

	ADD.L	D0,D0
	SWAP	D0						; D0=Hgt*81920/65536
									; D0='Perspectived' height of image
	MOVE.L	#$A000,D1
	DIVU	D2,D1					; D1= 40960/Hgt
	SWAP	D1						; D1= 40960/(65536*hgt)
	CLR.W	D1
	LSR.L	#8,D1					; /256
									; Now D1 = Step factor for lines across
									; image (NB *65536 or a SWAP)
	MOVEQ.L	#0,D2
	MOVEQ.L	#0,D4
	MOVE.W	D6,(A0)+				; Save offset
	MOVE.W	D0,(A0)+				; Save img hgt/num lines
	ADDQ.W	#1,-2(A0)
	BRA.S	MakeVScaleTab_ilpSkip
 
MakeVScaleTab_ilp
	ADD.L	D1,D2					; Add step factor
	SWAP	D2
	MOVE.W	D2,D3					; D3 = target line
	SUB.W	D4,D3					; Find line offset/skip count
									; Actual line - Target line
	ADD.W	D3,D3					; Make offset
	MOVE.W	(A2,D3.W),(A0)+			; Lookup required modulo
	MOVE.W	D2,D4					; Target Line > Actual line
	SWAP	D2
MakeVScaleTab_ilpSkip
	DBRA	D0,MakeVScaleTab_ilp

	MOVE.W	#201,D3					; Target line - END
	SUB.W	D4,D3
	ADD.W	D3,D3
	MOVE.W	(A2,D3.W),(A0)+			; Reqd value to -> last line

	ADDQ.W	#1,D7
	CMP.W	#160,D7
	BLS.S	MakeVScaleTab_lp

	RTS	


;DoScale(Prev Dest Src Size) (A0 A1 A4 D0)
;Draw new frame based on previous datas
;
;A0 = Previous frame
;A1 = Dest for this frame
;A4 = Original source data
;D0 = New size
;A6 = CUSTOM

DoScale
	LEA	RefTab1,A2
	ADD.W	D0,D0
	MOVE.W	D0,-(SP)

	MOVE.W	#159,D6
	SUB.W	(A2,D0.W),D6			; D6 = Pix posn on LHSide
	MOVE.L	A0,A2
	MOVE.L	A1,A3
	MOVE.W	D6,D7
	AND.W	#15,D7					; D7 = Bit
	LSR.W	#4,D6					; D6 = Word
	MOVE.W	D6,D5
	ADD.W	D5,D5					; D5 = Byte offset
	LEA	$28-2(A0),A0				; Set a0/a1 = Src/dst
	LEA	$28-2(A1),A1
	SUB.W	D5,A0
	SUB.W	D5,A1

	MOVEQ.L	#$28-2,D0
	SUB.W	D5,D0					; Modulo = Plwidb-2-ByteOff

	MOVE.W	D6,D1					; Additional words in bsize
	ADD.W	#200*4<<6+1,D1

DS_Chk1	BTST	#6,dmaconr(A6)
	BNE.S	DS_Chk1
	MOVE.L	#-1,bltafwm(A6)
	MOVEM.L	A0/A1,bltapth(A6)
	MOVE.W	D0,bltamod(A6)
	MOVE.W	D0,bltdmod(A6)
	MOVE.L	#$19F00000,bltcon0(A6)	; Scroll 1 pixel, A>D
	MOVE.W	D1,bltsize(A6)

	LEA	32000-4(A2),A0
	LEA	32000-2(A3),A1
	SUB.W	D5,A0
	SUB.W	D5,A1
	CLR.W	D4
	ADDQ.W	#1,D7
	BSET	D7,D4
	SUBQ.W	#1,D7
	SUBQ.W	#1,D4
	NOT.W	D4						; NOT for mask
	MOVEQ.L	#$28-2,D2
DS_Chk2	BTST	#6,dmaconr(A6)
	BNE.S	DS_Chk2
	MOVE.L	A1,bltbpth(A6)
	MOVE.L	A1,bltapth(A6)
	MOVE.L	A1,bltdpth(A6)
	MOVE.W	D2,bltbmod(A6)
	MOVE.W	D2,bltamod(A6)
	MOVE.W	D2,bltdmod(A6)
	MOVE.W	D4,bltcdat(A6)			; C mask
	MOVE.L	#$1DE40002,bltcon0(A6)	; scroll = 1, DESC
	MOVE.W	#200*4<<6+1,bltsize(A6)

	SUBQ.W	#2,A1
	MOVEQ.L	#$12,D2
	SUB.W	D5,D2
	BEQ.S	DS_Chk4
	MOVEQ.L	#$28,D3
	SUB.W	D2,D3
	SUB.W	D2,D3
DS_Chk3	BTST	#6,dmaconr(A6)
	BNE.S	DS_Chk3
	MOVEM.L	A0/A1,bltapth(A6)
	MOVE.W	D3,bltamod(A6)
	MOVE.W	D3,bltdmod(A6)
	MOVE.W	D2,D3
	ADD.W	#200*4<<6,D2
	MOVE.W	#$09F0,bltcon0(A6)		; Direct A>D copy, DESC still set
	MOVE.W	D2,bltsize(A6)

	ADD.W	D3,D3
	SUB.W	D3,A0
	SUB.W	D3,A1
DS_Chk4	BTST	#6,dmaconr(A6)
	BNE.S	DS_Chk4
	MOVEM.L	A0/A1,bltapth(A6)
	MOVE.W	D0,bltamod(A6)
	MOVE.W	D0,bltdmod(A6)
	MOVE.W	#$19F0,bltcon0(A6)
	MOVE.W	D1,bltsize(A6)

	LEA	0(A3,D5.W),A1
	MOVEQ.L	#$28-2,D2
	CLR.W	D4
	EOR.W	#15,D7
	BSET	D7,D4
	SUBQ.W	#1,D4
DS_Chk5	BTST	#6,dmaconr(A6)
	BNE.S	DS_Chk5
	MOVE.L	A1,bltbpth(A6)
	MOVE.L	A1,bltapth(A6)
	MOVE.L	A1,bltdpth(A6)
	MOVE.W	D2,bltbmod(A6)
	MOVE.W	D2,bltamod(A6)
	MOVE.W	D2,bltdmod(A6)
	MOVE.W	D4,bltcdat(A6)
	MOVE.L	#$1DE40000,bltcon0(A6)	; Scroll 1 pix, no DESC
	MOVE.W	#200*4<<6+1,bltsize(A6)

	MOVE.W	(SP)+,D0

;Add new left hand side pieces
	LEA	ScaleNewPixelTab,A2
	MOVE.W	(A2,D0.W),D6
	MOVE.W	#159,D1
	SUB.W	D6,D1					; New  = 159-pix since oofset from centre
	MOVE.W	D1,D2
	NOT.W	D2
	AND.W	#15,D2
	LSR.W	#4,D1
	ADD.W	D1,D1

	LEA	0(A4,D1.W),A0
	LEA	0(A3,D5.W),A1
	BSR.S	SplatBlit

;Repeat for right hand side peices
	NEG.W	D1
	LEA	$28-2(A4,D1.W),A0
	NEG.W	D5
	LEA	$28-2(A3,D5.W),A1
	MOVEQ	#15,D1
	EOR.W	D1,D7
	EOR.W	D1,D2
	BSR.S	SplatBlit
	RTS	
 
;d7 = Bit number
SplatBlit
	CLR.W	D4
	BSET	D7,D4
	MOVE.W	D2,D3
	SUB.W	D7,D3
	BMI.S	SB_Back
	ROR.W	#4,D3
	OR.W	#$0DE4,D3
SB_Chk1	BTST	#6,dmaconr(A6)
	BNE.S	SB_Chk1
	MOVEM.L	A0/A1,bltapth(A6)
	MOVE.L	A1,bltbpth(A6)
	MOVE.W	D3,bltcon0(A6)
	MOVE.W	#0,bltcon1(A6)
	MOVE.W	D4,bltcdat(A6)
	MOVE.W	#200*4<<6+1,bltsize(A6)
	RTS	
 
SB_Back
	NEG.W	D3						; Other dirn
	ROR.W	#4,D3
	OR.W	#$0DE4,D3				; Set scroll/con
	LEA	32000-40(A0),A0
	LEA	32000-40(A1),A1
SB_Chk2	BTST	#6,dmaconr(A6)
	BNE.S	SB_Chk2
	MOVEM.L	A0/A1,bltapth(A6)
	MOVE.L	A1,bltbpth(A6)
	MOVE.W	D3,bltcon0(A6)
	MOVE.W	#2,bltcon1(A6)			; DESC
	MOVE.W	D4,bltcdat(A6)
	MOVE.W	#200*4<<6+1,bltsize(A6)
	RTS	
 
;New pixel/word no.s evenly spread
ScaleWordDat	dc.w	0,5,7,3,9,1,6,4,8,2
ScalePixelDat	dc.w	8,12,4,14,2,10,6,15,0,3,13,5,11,9,7,1

ScaleCopper
	dc.w	$008E,$2C81,$0090,$F5C1
	dc.w	$0092,$0038,$0094,$00D0
	dc.w	$0100,$4200,$0102,0
	dc.w	COLOR00
ScaleCopCols
	dc.w	0,COLOR01,0,COLOR02,0,COLOR03,0
	dc.w	COLOR04,0,COLOR05,0,COLOR06,0,COLOR07,0
	dc.w	COLOR08,0,COLOR09,0,COLOR10,0,COLOR11,0
	dc.w	COLOR12,0,COLOR13,0,COLOR14,0,COLOR15,0

	dc.w	BPL1PTL
ScalePl	dc.w	0,BPL1PTH,0
	dc.w	BPL2PTL,0,BPL2PTH,0
	dc.w	BPL3PTL,0,BPL3PTH,0
	dc.w	BPL4PTL,0,BPL4PTH,0
ScaleCopBase
ScaleCop_Mods = *+6
	ds.w	201*6
	dc.w	$0100,$0200
	dc.w	$009C,$8010
	dc.w	$FFFF,$FFFE

ScaleLogo.gfx	INCBIN ScalerPic.IrawC
ScaleCols	=	*-2*32	; Aagh! iffcoverter always saves 32 colours out!

	Section	Dummy,BSS_C
ScaleNewPixelTab	ds.w	160
RefTab1				ds.w	160
RefTab2				ds.w	160

VScaleTabRef		ds.w	102
VScaleTabLookup		ds.l	161

VScaleTab			ds.w	16522

MyVars				ds.b	VarLen

Screen1	ds.b	202*40*4
Screen2 ds.b	202*40*4

