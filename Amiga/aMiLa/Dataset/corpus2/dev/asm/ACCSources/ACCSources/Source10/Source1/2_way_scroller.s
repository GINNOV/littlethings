
 SECTION LOWMEM,CODE_C				Force Code To Chip RAM
 OPT C-						Case Independant

	include	source10:include/hardware.i

NUMBER	=	8-1

*****************************************************************************
* EXECUTE SEQUENCE				    			    *
*****************************************************************************

	MOVEM.L	A0-A6/D0-D7,-(A7)		Save all Registers
	MOVE.L	A7,Stackpoint		Save Pointer
	JSR	Kill_OS
	JSR	SetUp
	JSR	SETUP_2
	JSR	Main
	JSR	Help_OS
	MOVE.L	Stackpoint,A7		Restore Pointer
	MOVEM.L	(A7)+,A0-A6/D0-D7		Restore Registers
	RTS

*****************************************************************************
* KILL OS				            			    *
*****************************************************************************

Kill_OS	MOVE.L	$4,A6
	CLR.L	D0
	LEA	GFXlib(PC),A1
	JSR	-552(A6)		     	Open GFX Lib
	MOVE.L	D0,GFXBase    
	JSR	-132(A6)		     	LVO_Forbid
	MOVE.W	$DFF002,DMAsave		Save DMA
	MOVE.W	$DFF01C,INTensave		Save Interupt Enable
	MOVE.W	$DFF01E,INTrqsave		Save Interupt Request
	MOVE.W	#$7FFF,$DFF09A   	     	Disable	Interupts
	MOVE.W	#$7FFF,$DFF096   		Disable DMA
	MOVE.L	#Copperlist,$DFF080		Replace Copper 
	MOVE.W	$DFF088,D0		Strobe Copper
	MOVE.W	#$8380,$DFF096		Enable Copper/Bitplane DMA
	RTS 
*******************************************************************************
* SET UP ROUTINES							    *
**********************************************************************************
SetUp

	lea  	LOGO,a0
	lea	col,a1
	move.l	#Number,d4
loop:	move.w	(a0)+,(a1)+
	add.w	#2,a1
	dbra	d4,loop
	move.l	a0,d0
	  
	MOVE.W    D0,PL1L
	SWAP      D0
	MOVE.W    D0,PL1H
	SWAP      D0
	add.l	#256*40,D0
	MOVE.W    D0,PL2L
	SWAP      D0
	MOVE.W    D0,PL2H
	SWAP      D0
	add.l	#256*40,D0
	MOVE.W    D0,PL3L
	SWAP      D0
	MOVE.W    D0,PL3H
	RTS
**********************************************************************************
SetUp_2:
	move.w	#$0,Smoothy
	move.w	#$0020,$dff096	
	clr.w	LogoCount1
	clr.w	LogoCount2
	clr.w	LogoCount3
	

	lea  	LOGO2,a0
	lea	col2,a1
	move.l	#Number,d4
loop_2:	move.w	(a0)+,(a1)+
	add.w	#2,a1
	dbra	d4,loop_2
	move.l	a0,d0
	  
	MOVE.W    D0,CL1L
	SWAP      D0
	MOVE.W    D0,CL1H
	SWAP      D0
	add.l	#256*40,D0
	MOVE.W    D0,CL2L
	SWAP      D0
	MOVE.W    D0,CL2H
	SWAP      D0
	add.l	#256*40,D0
	MOVE.W    D0,CL3L
	SWAP      D0
	MOVE.W    D0,CL3H
	RTS

*****************************************************************************
* MAIN					    				    *
*****************************************************************************

Main	
	CMPI.B	#255,$DFF006		Wait For line 255
	BNE.S	Main
	JSR	MOVE_IT
	JSR	MOVE_IT_2
	btst	#6,$bfe001
	bne	main
	
*****************************************************************************
MOVE_IT:

	CMPI	#60,SCFLAG_1
	BNE	UP
	CMPI	#60,SCFLAG_2
	BNE	DOWN
	bsr	pause
	CLR.W	SCFLAG_1
	CLR.W	SCFLAG_2
	RTS
	
UP	
	ADD.W	#40,PL1L
	bsr	pause
	ADD.W	#40,PL2L
	bsr	pause
	ADD.W	#40,PL3L
	bsr	pause
	ADDQ	#1,SCFLAG_1
	RTS
	
DOWN
	SUB.W	#40,PL1L
	bsr	pause
	SUB.W	#40,PL2L
	bsr	pause
	SUB.W	#40,PL3L
	bsr	pause
	ADDQ	#1,SCFLAG_2
	RTS
	

SCFLAG_1:	
	DC.W	20

SCFLAG_2:
	DC.W	20

*****************************************************************************
MOVE_IT_2:

	cmpi.w	#20,LogoCount2
	bne.s	BackAgain
	cmpi.w	#20,LogoCount1
	bne.s	There
	jsr	ClearCounts
	rts
	
There	cmpi.w	#$ff,Smoothy
	beq.s	Step2
	addi.w	#$11,Smoothy
	rts
Step2	
	subi.w	#2,cl1l
	subi.w	#2,cl2l
	subi.w	#2,cl3l
	move.w	#$0,Smoothy
	addi.w	#1,LogoCount1
	addi.w	#1,LogoCount3
	rts
BackAgain
	cmpi.w	#$0,Smoothy
	beq.s	Step3
	subi.w	#$11,Smoothy
	rts
Step3
	addi.w	#2,cl1l
	addi.w	#2,cl2l
	addi.w	#2,cl3l
	move.w	#$ff,Smoothy
	addi.w	#1,LogoCount2
	rts
ClearCounts
	clr.w	LogoCount1
	clr.w	LogoCount2
	rts
	

LogoCount1	dc.w	0
LogoCount2	dc.w	0
LogoCount3	dc.w	0
	
************************************************************************
pause:
	move.l	#$ff,d7
ploop:
	subq	#1,d7
	cmp	0,d7
	bne	ploop
	rts
*********************************************************************************
* RESTORE OS				    				    *
*****************************************************************************

Help_OS	MOVE.W	INTensave,D7
	BSET	#$F,D7			Set Write Bit
	MOVE.W	D7,$DFF09A		Restore INTen
	MOVE.W	INTrqsave,D7
	BSET	#$F,D7
	MOVE.W	D7,$DFF09C		Restore INTrq
	MOVE.W	DMAsave,D7
	BSET	#$F,D7
	MOVE.W	D7,$DFF096	  	Restore DMA
	MOVE.L	GFXbase,A0
	MOVE.L	$26(A0),$DFF080		Find/Replace System Copper
	MOVE.L	$4,A6
	JSR	-138(A6)			LVO_Permit
	RTS 
***********************************************************************************
*			        COPPER				    	    *
*****************************************************************************

Copperlist
	dc.w	$0001,$fffe
	dc.w	diwstrt,$2010
	dc.w	diwstop,$2cc9
	dc.w	ddfstrt,$38
	dc.w	ddfstop,$d0
		
	dc.w	bplcon0,$3200
	dc.w	$108,$0
	dc.w	$10a,$0
	dc.w	$180
Col	dc.w	$0,$182,$0,$184,$0,$186,$0,$188,$0
	dc.w	$18a,$0,$18c,$0,$18e,$0

	dc.w	$e0
Pl1h	dc.w	0,$e2				
Pl1l	dc.w	0,$e4	
Pl2h	dc.w	0,$e6				
Pl2l	dc.w	0,$e8
Pl3h	dc.w	0,$ea
Pl3l	dc.w	0
	dc.w	$8701,$fffe
	dc.w	$0100,$0200


	dc.w	bplcon1		;Bitplane Horizontal Scroll
smoothy	dc.w	$0000
	dc.w	bplcon2,$0000	;Bitplane Scroll Registers
	dc.w	bpl1mod,0000	;Bitplane Modulo 1 
	dc.w	bpl2mod,0000 	;Bitplane Modulo 2

	DC.W	$8801,$FFFE
;	dc.w	diwstrt,$8000
;	dc.w	diwstop,$2cc9
	dc.w	ddfstrt,$38
	dc.w	ddfstop,$d0

	dc.w	$e0
CL1h	dc.w	0,$e2				
CL1l	dc.w	0,$e4	
CL2h	dc.w	0,$e6				
CL2l	dc.w	0,$e8
CL3h	dc.w	0,$ea
CL3l	dc.w	0

	dc.w	$180
Col2	dc.w	$0,$182,$0,$184,$0,$186,$0,$188,$0
	dc.w	$18a,$0,$18c,$0,$18e,$0
	dc.w	bplcon0,$3200

	dc.w	$e201,$fffe,$100,$0000	

	dc.w	$ffff,$fffe		


*****************************************************************************
* LABELS,INCLUDES							    *
*****************************************************************************

GFXlib			DC.B "graphics.library"
Stackpoint		DC.L 0
GFXbase			DC.L 0
INTrqsave		DC.W 0
INTensave		DC.W 0
DMAsave			DC.W 0

	even

barflag:		dc.b	1
barflag2:		dc.b	1
	even

 SECTION  LOWMEM,DATA_C					Section Data

LOGO		incbin	source10:bitmaps1/disorganized.raw
	EVEN
LOGO2		incbin	source10:bitmaps1/crime_2.raw

