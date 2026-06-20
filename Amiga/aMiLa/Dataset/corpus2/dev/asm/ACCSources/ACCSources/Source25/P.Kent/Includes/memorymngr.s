
*****
* ALLOCCHIP(LENGTH)( D1 )
* RETURN: D0 = ADDR if OK : calls _error if fail!
* Try to allocate chip memory...
*****
AllocChip
	move.l	a0,-(a7)
	move.l Memptr(pc),a0
	move.l 4(a0),a0				; CHIP *must* be 1st in list!
	bsr GetBlk
	beq.s AC_NoneErr
	bmi.s AC_CCorruptErr
	bsr	WipeMem
	move.l (a7)+,a0
	rts	

AC_NoneErr
	LEA AC.None.txt(pc),a0
	Bra _Error
Ac.None.txt
	dc.b	'MEMORY FATAL : INSUFFICENT CHIP-MEM!',0
	even
Ac_CCorruptErr
	lea Ac.CCorrupt.txt(pc),a0
	Bra _Error
Ac.CCorrupt.txt
	dc.b	'MEMORY FATAL : CHIP-MEM BLOCK CORRUPT!',0
	even

*****
* ALLOCPUBLIC(Length) (d1)
* RETURN: d0 = Ptr else calls _error if total fail!
* - Try to allocate from FAST ram...
* - If that fails try for SLOW FAST
* - If desperate go for CHIP ram :-(
*****
AllocPublic
	move.l a0,-(a7)
	move.l Memptr(pc),a0
;Scan for FAST...
AP_Fastlp
	tst.l (a0)
	beq.s AP_FastFail
;Save ptr : could be looping though several entries...
	move.l a0,-(sp)
;
	cmp.l #'RAMF',(a0)
	bne.s AP_fastlp2
	move.l 4(a0),a0	
	bsr GetBlk
	beq.s AP_Fastlp2
	bmi.s AP_FCorruptErr
	bra.s AP_GotIT
AP_Fastlp2
;
	move.l (sp)+,a0
;
	lea	12(a0),a0
	bra.s AP_Fastlp

AP_GotIT
	bsr	WipeMem
	move.l (a7)+,a0
	rts

Ap_FastFail
	move.l Memptr(pc),a0
;Scan for SLOWFAST...
AP_SFastlp
	tst.l (a0)
	beq.s AP_SFastFail
	cmp.l #'RAMS',(a0)
	beq.s AP_Sfast1
	lea	12(a0),a0
	bra.s AP_SFastlp
AP_Sfast1
	move.l 4(a0),a0	
	bsr GetBlk
	beq.s AP_Sfastfail			; We can only have one lot of slow fast...
	bmi.s AP_SFCorruptErr
	bra.s AP_GotIT
AP_SfastFail
;Try for chip!!!
	move.l Memptr(pc),a0
	move.l 4(a0),a0				; CHIP *must* be 1st in list!
	bsr GetBlk
	beq.s AP_NoneErr
	bmi AC_CCorruptErr
	bsr	WipeMem
	move.l (a7)+,a0
	rts

AP_NoneErr
	LEA AP.None.txt(pc),a0
	Bra _Error
AP.None.txt
	dc.b	'MEMORY FATAL : INSUFFICENT MEM! (S&F)',0
	even
AP_FCorruptErr
	lea AP.FCorrupt.txt(pc),a0
	Bra _Error
AP.FCorrupt.txt
	dc.b	'MEMORY FATAL : FAST-MEM BLOCK CORRUPT!',0
	even
AP_SFCorruptErr
	lea AP.SFCorrupt.txt(pc),a0
	Bra _Error
AP.SFCorrupt.txt
	dc.b	'MEMORY FATAL : ''SLOW''-FAST BLOCK CORRUPT!',0
	even

WipeMem ;d0=ptr,length d1
	move.l d0,a0
	move.l d1,-(a7)
	subq.l #1,d1
wm_lp
	clr.b (a0)+
	dbra d1,wm_lp
	move.l d1,(a7)+
	rts
	

;Store allocation routines from  'Programming the 68000'
;Various mods... (only GETBLK,FREEBLK from book)
*****
* GETBLK (MemList Bytes) (a0 d1)
* RETURN:	d0 = Ptr ; 0 = INSUFFICIENT MEM! ; -1 = CORRUPT !
*****
GetBlk
	MOVEM.L A0/A1/D1-D3,-(A7)
	ADDQ.L	#3,D1
	AND.B	#$FE,D1
	ADDQ.L	#4,D1					; ROUNT LENGTH + 4
	BLE.S	GBC7					; -VE ERROR

GBC1 MOVE.L (A0),D2
	BLE.S GBC6						; END OFLIST OR ERROR
	BCLR.L #0,D2					; TEST+CLEAR MARKER
	BNE.S	GBC2					; FREE BLOCK?
	ADD.L	D2,A0					; A0 = NEXT BLOCK
	BRA.S GBC1

* Have a free block....
GBC2	MOVE.L	A0,D3				; D3 = FREE BLOCK
GBC3	ADD.L	D2,A0				; NEXT BLOCK
	MOVE.L	(A0),D2					; GET SIZE + MARKER
	BMI.S	ERRSTORE				; JUMP IF LOOP!
	BCLR.L	#0,D2					; TEST + CLEAR
	BNE.S	GBC3					; JMP IF FREE
* D1 = SIZE ; D3 = START OF FREE AREA ; A0 END OF AREA
GBC4
	MOVE.L	A0,D2					; COPY END ADDRESS
	SUB.L	D3,D2					; AMALGAMATED BLOCK
	BSET	#0,D2					; SET FREE
	MOVE.L	D3,A1					; GET START
	MOVE.L	D2,(A1)					; AMAL FREE BLOCKS
	BCLR	#0,D2					; DEL MARKER...
	SUB.L	D1,D2					; SPLIT BLOCK
	BLT.S	GBC1					; CANT BE DONE!
	BEQ.S	GBC5					; EXACT FIT!
*MAKE NEW BLOCK...
	SUB.L	D2,A0					; A0 = ADDRESS OF UPPER PART
	BSET	#0,D2					; SIZE + MARKER
	MOVE.L	D2,(A0)					; PLANT IN UPPER BLOCK
GBC5	MOVE.L	D1,(A1)				; PUT SOUND
	ADDQ.L	#4,D3					; ADDR OF ALLOC SPACE
	MOVE.L	D3,D0					; SUCCESSFUL RESULT...
	BRA.S	GBEXIT
*ERROR!
GBC6 BMI.S ERRSTORE	* LOOP IN LIST?
;	 BEQ.S ERRSTORE * NULL ENTRY ?
*NOT ENOUGH FREE...
GBC7	MOVEQ	#0,D0				; INSUFF FREE...
GBERREX
GBEXIT	MOVEM.L	(SP)+,A0/A1/D1-D3
	TST.L	D0
	RTS
ERRSTORE	MOVEQ	#-1,D0			; SCRAMBLED!
	BRA.S	GBERREX

*****
* FREEMEM
* FREEBLK (ADDRESS)(D0)
* RETURNS: D0 = 0 OK ; = -1 NOT AN ALLOCED BLOCK!
*****
FREEMEM
FREEBLK
	MOVEM.L	D1/D2/A0,-(SP)
	MOVEQ	#0,D1					;RTN CODE
	TST.L	D0
	BEQ.S	FBEXIT
	SUBQ.L	#4,D0					; GET HEADER START
	MOVE.L	D0,D2
	AND.L	#1,D2					; MUST BE AN EVEN ADDRESS
	BNE.S	FBERR
	MOVE.L	D0,A0
	MOVE.L	(A0),D2
	AND.L	#1,D0					; MUST BE AN ALLOCED BLOCK
	BNE.S	FBERR
	BSET	#0,3(A0)				; SET FREE BLOCK...
FBEXIT
	MOVE.L	D1,D0					; RETURN CODE IN D0
	MOVEM.L	(SP)+,D1/D2/A0
	TST.L	D0
	RTS
FBERR	MOVEQ	#-1,D1
	BRA.S FBEXIT

*****
* MINITIALISE(MEMINFO)(a1) 
* Initialise all 3 memory chains,
* based on MEMINFO listing...
*****
Minitialise
	MOVEM.L	A0/A1/D1,-(A7)
	LEA 	MEMPTR(PC),a0
	MOVE.L A1,(A0)
Minit_lp	TST.L (A1)				; Step thro list initialising as we go..
	beq.s Minit_end
	MOVE.L 4(A1),A0
	MOVE.L 8(A1),D1
	BSR.S	INITBLK
	LEA	12(A1),A1
	BRA.S	Minit_lp
Minit_end
	MOVEM.L (A7)+,A0/A1/D1
	RTS

*****
* INITBLK (Mem Length) (a0 d1)
* INITIALISE A MEM HEADER...
*****
INITBLK
	MOVE.L D0,-(A7)
	MOVE.L D1,D0
	SUBQ.L #8-1,D0					; LW HEADER + NULL TERM +1
	MOVE.L D0,(A0)
	CLR.L -4(A0,D1.L)
	MOVE.L (A7)+,D0
	RTS

MEMPTR DC.L 0						; PTR to meminfo struct...
