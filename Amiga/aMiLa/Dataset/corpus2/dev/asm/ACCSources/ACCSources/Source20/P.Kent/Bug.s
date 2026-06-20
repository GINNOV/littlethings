
	OPT	C-,D+
	INCLUDE	source:include/HARDWARE.I
	INCLUDE	MYMACROS.I

DEBUG	=	1	;FOR DEBUGABLE!,0 FOR PROPER TEST...

	SECTION YUBBA_DUBBA,CODE_C

custom	equ	$dff000

	IFND	DEBUG

	Bsr	Bug_init			;Put up those traffic cones...
	moveq	#4,d6
lpme2	moveq	#-1,d7
lpme
	move.l	d7,$dff180
	dbra	d7,lpme
	dbra	d6,lpme2
	lea	1.w,a0
	jsr (a0)				;POW!!!!!!!!!!!!!!! Addr error
	rts


buserr	=	8
endvec	=	$40

BUG_INIT					;Copy through list of ptrs...
	MOVEM.L	A0-A1,-(A7)
	LEA	(buserr).w,a0
	lea	bsrtab(pc),a1
BUGINIT_LP
	MOVE.L	A1,(A0)+
	ADDQ.L	#2,A1
	CMP.L	#endvec,A0
	BLO.S	BUGINIT_LP
	MOVEM.L	(A7)+,A0-A1
	rts
	ENDC

	IFD	DEBUG				;If debugging, just hop into the bsr table...
	LEA	MYENT(PC),A0
	MOVE.L	A0,$80.W
	TRAP	#0
	RTS
	ENDC

bsrtab						;List of bsrs so can identify exception type...
	BSR.S	EXCEPT	;bus error
	BSR.S	EXCEPT	;address error
	BSR.S	EXCEPT	;illegal
	BSR.S	EXCEPT	;zero divide
	BSR.S	EXCEPT	;chk
	BSR.S	EXCEPT	;trapv
	BSR.S	EXCEPT	;priv.
	BSR.S	EXCEPT	;trace
MYENT
	BSR.S	EXCEPT	;1010
	BSR.S	EXCEPT	;1111
	BSR.S	EXCEPT	;unassigned (reserved)
	BSR.S	EXCEPT	;unassigned (reserved)
	BSR.S	EXCEPT	;unassigned (reerved)
	BSR.S	EXCEPT	;uninit
	DC.B	'PKENT!'			
EXCEPT
	MOVE.L	(A7)+,index			;Jump address
	MOVEM.L	D0-D7/A0-A7,regs

	move.l	index,d7			;Calculate except type
	sub.l	#bsrtab+2,d7		;now d7 = offset from start of list
	lsl.l	#1,d7

	Lea	strtab(pc),a0			;Print type
	MOVE.L	(A0,D7),A0
	LEA		ExTypetxt,A1
	BSR		CopyStr

	lea	regs(pc),a1				;Dump registers
	lea	DBlocktxt,a0
	BSR	PRegs

	lea	regs+32(pc),a1
	lea	ABlocktxt,a0
	BSR	PRegs

	cmp.l	#8,d7
	bgt	prtpc

	move.w	(a7)+,d0			;Dump extra stack information if
								;ADDRESS ERROR / BUS ERROR
	lea	Fntxt,a0
	BSR	BinHexW
	move.l	(a7)+,d0
	lea	Aadtxt,a0
	BSR	BinHexL
	move.w	(a7)+,d0
	lea	irtxt,a0
	BSR	BinHexW
prtpc
	move.w	(a7),d0				;Dump sr,return PC,usp
	LEA	SrTxt,a0	
	BSR	BinHexW
	move.l	2(a7),d0
	lea	Pctxt,a0
	BSR	BinHexL
	move.l	usp,a0
	move.l	a0,d0
	lea	Usptxt,a0
	BSR	BinHexL
			
	LEA	custom,a5
	BSR	Initialise	
	BRA.S InitialPrt
Mainlp
	CATCHVB	A5

	BSR	DoCopperColScroll
	
	MOUSE	MAINLP2
InitialPrt
	Move.w	Memcnt,d1
	Addq.w	#1,d1
	Cmp.w	#16,d1
	Bne.s	ChkSP
	Move.l	2(a7),d0				;get return PC
	Bra.s	gotMem
ChkSP	
	Cmp.w	#17,d1
	Bne.s	CheckMem
	Move.l	usp,a0
	Move.l	a0,d0
	Bra.s	GotMem
CheckMem	
	Cmp.w	#18,d1
	Bne.s	MemCntOk
	Clr.w	d1
MemCntOk
	Move.w	d1,d0
	lsl.w	#2,d0					;*4 for offset
	Lea	regs(pc),a0
	Move.l	(a0,d0.w),d0			;Now reg I want...
GotMem
	Move.w	d1,Memcnt
	Sub.l	#16,d0					;Ptr to start mem...
	Bclr	#0,d0					;EVEN it!
	Bsr	DoMemD0

	NOMOUSE					
MAINLP2	RMOUSE	A5,MAINLP			;RMB quits!
 
Main_Quit							;RECOVER DMA/INTS

	MOVE.W	#$7FFF,intena(A5)
	MOVE.W	#$7FFF,dmacon(A5)
	Catchvb	a5
	MOVE.W	OldInts(PC),D0
	OR.W	#$8000,D0
	MOVE.W	OldDMA(PC),D1
	OR.W	#$8000,D1
	MOVE.W	D0,intena(A5)
	MOVE.W	D1,dmacon(A5)
	MOVE.W	D0,copjmp1(A5)			; RECOVER COPPER...
	MOVEM.L	REGS,D0-D7/A0-A7
	RTE	
 
Initialise
	BLITWAIT	A5					; FOR SAFETY! 
	MOVE.W	intenar(A5),OldInts		; SAVE DMA/INTS
	MOVE.W	dmaconr(A5),OldDMA
	MOVE.W	#$7FFF,intena(A5)		; DISABLE...
	MOVE.W	#$7FFF,dmacon(A5)

	LEA	TextCop(PC),A1				; PUT COPPER IN PLANES
	MOVE.L	#TxtPlane,D0
	MOVE.W	D0,6(A1)
	SWAP	D0
	MOVE.W	D0,2(A1)
	MOVE.L	#MyCopper,cop2lch(A5)
	MOVE.W	D0,copjmp2(A5)
	MOVE.W	#SETIT!DMAEN!BPLEN!COPEN!BLTEN,dmacon(A5)
	RTS	
 
OldInts	dc.w	0
OldDMA	dc.w	0
MemCnt	dc.w	-1 

BlitClear							; A0=PTR D0=BLTSIZE. WIPE SOME CHIP MEM
	BLITWAIT	A5
	MOVE.L	A0,bltdpth(A5)
	CLR.W	bltcon1(A5)
	MOVE.W	#USED,bltcon0(A5)
	CLR.L	bltafwm(A5)
	MOVE.L	#-1,bltamod(A5)
	MOVE.W	D0,bltsize(A5)
	RTS	
 
; Scroll all colours in copper bars...
DoCopperColScroll
	CMP.W	#62,ScrollColsOffset		;Check for overflow...
	BNE	DCCS_NReset
	CLR.W	ScrollColsOffset
DCCS_NReset
	LEA	CopUpperBar+2(PC),A0			;Copt through values
	LEA	CopperLowerBar+2(PC),A2
	LEA	ScrollCols(PC),A1
	MOVE.W	ScrollColsOffset(PC),D0
	LEA	(A1,D0.W),A1
	MOVE.W	#51,D7						;52 bits of colour
DCCS_lp
	MOVE.W	(A1),(A0)
	MOVE.W	(A1)+,(A2)
	ADDQ.L	#4,A0
	ADDQ.L	#4,A2
	DBRA	D7,DCCS_lp
	ADDQ.W	#2,ScrollColsOffset			;Add to offset
	RTS	
 
ScrollColsOffset
	dc.w	0							;Offset
ScrollCols
	rept	3
	dc.w	$010,$020,$030,$040,$050,$060,$070,$080
	dc.w	$090,$0A0,$0B0,$0C0,$0D0,$0E0,$0F0
	dc.w	$0F0,$0E0,$0D0,$0C0,$0B0,$0A0,$090,$080
	dc.w	$070,$060,$050,$040,$030,$020,$010
	endr	

PrintMessage

;IF TXTPLANE is low memory need to run this!
;	LEA	TxtPlane(PC),A0		; wipe plane on entry...
;	MOVE.W	#$2814,D0		; blitsize...
;	BSR	BlitClear

	LEA	Message(PC),A0
	LEA	TxtPlane(PC),A1
	MOVE.L	A1,A3
	MOVEQ	#0,D3
PM_lp
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0		; Get chr
	CMP.B	#1,D0			; 1 quits
	BEQ.S	PM_End
	TST.B	D0				; 0 is new line
	BNE.S	PM_PrChr
	LEA		8*40(A3),A3
	MOVE.L	A3,A1
	BRA.S	PM_lp
 
PM_PrChr
	LEA	MyFont(PC),A2		; Raw font
	SUB.W	#" ",D0
	LSL.W	#3,D0			; 8 bytes per char
	LEA	(A2,D0.W),A2		; Position
	BSR	PlotChr				; Print it
	ADDQ.L	#1,A1			; Advance cursor 
	BRA.S	PM_lp
 
PM_End	RTS	
 
PlotChr
	MOVE.B	(A2)+,(A1)
	MOVE.B	(A2)+,40(A1)
	MOVE.B	(A2)+,80(A1)
	MOVE.B	(A2)+,120(A1)
	MOVE.B	(A2)+,160(A1)
	MOVE.B	(A2)+,200(A1)
	MOVE.B	(A2)+,240(A1)
	MOVE.B	(A2)+,280(A1)
	RTS	

DoMemD0						; Update display, d0 is ptr

	Move.l	d0,-(a7)
	Lea	Memptr(pc),a0
	Moveq	#4,d7			; Print ptrs first...
Memlp1
	Bsr	BinHexL
	Addq.l	#8,d0
	Lea	40(a0),a0
	Dbra	d7,memlp1

	Move.l	(a7),a2			; Do ascii display
	Lea	Memptr2(pc),a0
	Moveq	#4,d6
Memlp3
	Move.l	a0,a1
	Moveq	#7,d7
Memlp2	Move.b	(a2)+,d1
	Cmp.b	#' ',d1			; Print anything above a space.
	Bpl.s	Memok2
	Move.b	#' ',d1
Memok2	
	move.b	d1,(a1)+			
	Dbra	d7,Memlp2	
	Lea	40(a0),a0
	Dbra	d6,Memlp3

	Move.l	(a7)+,a2		; Get initial ptr off stack...
							; Now do hex display
	Lea	Memptr3(pc),a1		; Ptr to hex start
	Moveq	#4,d7			; 5 lines
memlp4
	Move.l	a1,a0
	Move.l	(a2)+,d0
	BSR	BinHexL
	Lea	9(a0),a0			; Update + space.
	Move.l	(a2)+,d0						
	BSR	BinHexL
	Lea	40(a1),a1
	Dbra	d7,Memlp4	

	BSR	PrintMessage
	rts
		
;Print register buffer(8.l) at a1 to base at a0
PRegs
	movem.l	d0-d1/a0-a2,-(a7)
	move.l	a0,a2			; save base
	addq.l	#4,a0			; start of regs
	moveq	#3,d1			; 4 reg pairs
Pregs_lp
	move.l	a0,a2	
	move.l	(a1)+,d0
	bsr.s	BinHexL
	lea		13(a0),a0
	move.l	(a1)+,d0
	bsr.s	BinHexL
	lea	40(a2),a0
	dbra	d1,PRegs_lp
	movem.l	(a7)+,d0-d1/a0-a2
	rts

	
			
;BINW->ASCIIHEXW ROUTINE: D0.W = WORD TO BE ASCIId A0=4 bytes text dest
BinHexW
	movem.l	d0-d2/a1,-(a7)
	moveq	#3,d1			; count
	addq.l	#4,a0			; end dest str
	bra.s	BinHexMain 
;BINL->ASCIIHEXL ROUTINE: D0.L = LWORD TO BE ASCIId A0=8 bytes text dest
BinHexL
	movem.l	d0-d2/a1,-(a7)
	moveq	#7,d1			; count
	addq.l	#8,a0 			; end dest string
BinHexMain
	lea	hextab(pc),a1		; chr tab
BinHexlp
	move.l	d0,d2
	and.l	#15,d2			; get 4 bits
	move.b	(a1,d2),-(a0)
	lsr.l	#4,d0
	dbra	d1,BinHexlp
	movem.l	(a7)+,d0-d2/a1
	rts
hextab	dc.b	"0123456789ABCDEF"
	even

CopyStr
	movem.l	d0/a0-a1,-(a7)
CopyStrlp
	move.b	(a0)+,d0
	beq.s	CopyStr_fin
	move.b	d0,(a1)+
	bra.s	CopyStrlp
CopyStr_fin
	movem.l	(a7)+,d0/a0-a1
	rts			

strtab
	dc.l	busstr,addstr,illstr,zerstr,chkstr,trvstr,prvstr,trcstr,lnastr
	dc.l	lnfstr,rsvstr,rsvstr,rsvstr,unistr
busstr	dc.b	'buserr',0
addstr	dc.b	'address error',0
illstr	dc.b	'illegal instruction',0
zerstr	dc.b	'zero divide',0
chkstr	dc.b	'chk instruction',0
trvstr	dc.b	'trapv instruction',0
prvstr	dc.b	'privelege violation',0
trcstr	dc.b	'trace',0
lnastr	dc.b	'line 1010 emulation',0
lnfstr	dc.b	'line 1111 emulation',0
rsvstr	dc.b	'unassigned (reserved)',0
unistr	dc.b	'uninitialised vector',0	

Message

;WARNING!!! PREGS/DOMEMD0 ROUTINES HAVE HARD CODED OFFSETS FOR HEX NOS!
;**********************************************************************
;LOOK BEFORE YOU LEAP!

	dc.b	'  <<< DeBug v0.01/Paul Kent 1992 >>>   ',0
	dc.b	'EXCEPTION TYPE:   '
ExTypetxt	dc.b	'                     ',0
DBlocktxt
	dc.b	' D0=00000000  D1=00000000   PC='
Pctxt		dc.b	'00000000',0
	dc.b	' D2=00000000  D3=00000000   SR='
Srtxt		dc.b	'0000    ',0
	dc.b	' D4=00000000  D5=00000000  USP='
Usptxt		dc.b	'00000000',0
	dc.b	' D6=00000000  D7=00000000  REG='
irtxt		dc.b	'0000    ',0
ABlocktxt
	dc.b	' A0=00000000  A1=00000000  WRD='
Fntxt		dc.b	'0000    ',0
	dc.b	' A2=00000000  A3=00000000  AAD='
Aadtxt		dc.b	'00000000',0
	dc.b	' A4=00000000  A5=00000000              ',0
	dc.b	' A6=00000000  A7=00000000              ',0
	dc.b	'MEMORY DUMP:',0
MemPtr
	dc.b	'00000000=  '
MemPtr3	dc.b	'00000000 00000000 >'
MemPtr2	dc.b	'abcdefgh<',0
	dc.b	'00000000=  00000000 00000000 >ijklmnop<',0
	dc.b	'00000000=  00000000 00000000 >qrstuvwx<',0
	dc.b	'00000000=  00000000 00000000 >ijklmnop<',0
	dc.b	'00000000=  00000000 00000000 >qrstuvwx<',0
	dc.b	'         (test version: rmb quits)     ',0
	dc.b	'   use lmb to select memory location   ',0
	dc.b	1
	even

MyCopper

	dc.w	$008E,$2061
	dc.w	$0090,$30C8
	dc.w	$0092,$0038
	dc.w	$0094,$00D0
	dc.w	color00,0
	dc.w	bpl1mod,0,bpl2mod,0
	dc.w	bplcon0,$0200,bplcon1,0
	dc.w	$5E0F,$FFFE
TextCop
	dc.w	bpl1pth,0,bpl1ptl,0
	dc.w	color01,$0CCC
	dc.w	$5F2F,$FFFE

CopUpperBar
	REPT	53
	dc.w	color00,$0100
	ENDR

	dc.w	$610F,$FFFE
	dc.w	bplcon0,$1200
	dc.w	$710F,$FFFE
	dc.w	color01,$0CCC	
	
	dc.w	$F30F,$FFFE
	dc.w	bplcon0,$0200
	dc.w	$F42F,$FFFE
CopperLowerBar
	REPT	53
	dc.w	color00,0
	ENDR
	dc.w	$FFFF,$FFFE

Regs	ds.l	16
Index	dc.l	0
	
TxtPlane	ds.b	20*8*40	;20 lines,8 hgt,40 bytes width

MyFont	incbin	"source:p.kent/FONTS/PEARL.8"	;Standard 8*8 font
	EVEN

