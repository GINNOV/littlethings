
 SECTION LOWMEM,CODE_C				Force Code To Chip RAM
 OPT C-						Case Independant

	include	source10:include/hardware.i

NUMBER	=	16-1

*****************************************************************************
* EXECUTE SEQUENCE				    			    *
*****************************************************************************

	MOVEM.L	A0-A6/D0-D7,-(A7)		Save all Registers
	MOVE.L	A7,Stackpoint		Save Pointer
	JSR	Kill_OS
	JSR	SetUp
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
	MOVE.W	#$83c0,$DFF096		Enable Copper/Bitplane DMA
	RTS 
*******************************************************************************
* SET UP ROUTINES							    *
*****************************************************************************
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
	SWAP      D0
	add.l	#256*40,D0
	MOVE.W    D0,PL4L
	SWAP      D0
	MOVE.W    D0,PL4H
	RTS
*****************************************************************************
* MAIN					    				    *
*****************************************************************************

Main	CMPI.B	#255,$DFF006		Wait For line 255
	BNE.S	Main
	bsr	colour_roll
	bsr	bar
;	bsr	bar2
	BTST   	#6,$BFE001		Test Mouse
	BNE.S  	Main
*****************************************************************************
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
bar:
	cmp.b	#1,barflag
	bne	barup

	add.w	#$0100,barcop1
	add.w	#$0100,barcop2
	add.w	#$0100,barcop3
	add.w	#$0100,barcop4
	add.w	#$0100,barcop5
	add.w	#$0100,barcop6
	add.w	#$0100,barcop7
	add.w	#$0100,barcop8
	add.w	#$0100,barcop9
	add.w	#$0100,barcop10
	add.w	#$0100,barcop11
	add.w	#$0100,barcop12
	add.w	#$0100,barcop13
	add.w	#$0100,barcop14
	add.w	#$0100,barcop15
	add.w	#$0100,barcop16
	cmp.w	#$bf01,barcop1	; bar lowerlimit line 224
	bne	upbarpos
	move.b	#0,barflag
	bra	upbarpos

barup:


	sub.w	#$0100,barcop1
	sub.w	#$0100,barcop2
	sub.w	#$0100,barcop3
	sub.w	#$0100,barcop4
	sub.w	#$0100,barcop5
	sub.w	#$0100,barcop6
	sub.w	#$0100,barcop7
	sub.w	#$0100,barcop8
	sub.w	#$0100,barcop9
	sub.w	#$0100,barcop10
	sub.w	#$0100,barcop11
	sub.w	#$0100,barcop12
	sub.w	#$0100,barcop13
	sub.w	#$0100,barcop14
	sub.w	#$0100,barcop15
	sub.w	#$0100,barcop16
	cmp.w	#$8e01,barcop1	; bar upperlimit line 41
	bne	upbarpos
	move.b	#1,barflag

upbarpos:
	rts
***********************************************************************************
Colour_Roll
	move.l	#Roll,a0
	move.w	#85,d0
Rolloop	
	move.b	7(a0),15(a0)
	sub.l	#8,a0
	dbra	d0,Rolloop
	
Rolloop1	move.l	Colourptr,a1
	move.b	(a1)+,d0
	cmp.b	#$00,d0
	bne	Colourok
	move.l	#ColourTable,Colourptr
	bra	Rolloop1
Colourok
	move.l	a1,Colourptr
	move.b	d0,15(a0)
	rts

Colourptr		dc.l	ColourTable
ColourTable	dc.b	$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$1f,$2f,$3f,$4f,$5f,$6f,$7f,$8f,$9f,$af,$bf,$cf,$df,$ef,$ff
		dc.b	$fe,$fd,$fc,$fb,$fa,$f9,$f8,$f7,$f6,$f5,$f4,$f3,$f2,$f1,$f0,$e0,$d0,$c0,$b0,$a0,$90,$80,$70,$60,$50,$40,$30
		dc.b	$41,$42,$43,$44,$45,$46,$47,$48,$49,$4a,$4b,$4c,$4d,$4e,$4f,$5f,$6f,$7f,$8f,$9f,$af,$bf,$cf,$df,$ef,$ff
		dc.b	$ee,$dd,$cc,$bb,$aa,$99,$88,$77,$66,$55,$44,$33,$22,$11,$00


 
*****************************************************************************
*			        COPPER				    	    *
*****************************************************************************

Copperlist
	dc.w	$0001,$fffe
	dc.w	diwstrt,$2c81
	dc.w	diwstop,$2cc1
	dc.w	ddfstrt,$38
	dc.w	ddfstop,$d0
		
	dc.w	bplcon0,$4200
	dc.w	$108,$0
	dc.w	$10a,$0
	dc.w	$180
Col	dc.w	$0,$182,$0,$184,$0,$186,$0,$188,$0
	dc.w	$18a,$0,$18c,$0,$18e,$0,$190,$0
	dc.w	$192,$0,$194,$0,$196,$0,$198,$0
	dc.w	$19a,$0,$19c,$0,$19e,$0,$1a0,$0
	dc.w	$1a2,$0,$1a4,$0,$1a6,$0,$1a8,$0
	dc.w	$1aa,$0,$1ac,$0,$1ae,$0,$1b0,$0
	dc.w	$1b2,$0,$1b4,$0,$1b6,$0,$1b8,$0
	dc.w	$1ba,$0,$1bb,$0,$1be,$0

	dc.w	$e0
Pl1h	dc.w	0,$e2				
Pl1l	dc.w	0,$e4	
Pl2h	dc.w	0,$e6				
Pl2l	dc.w	0,$e8
Pl3h	dc.w	0,$ea
Pl3l	dc.w	0,$ec
Pl4h	dc.w	0,$ee
Pl4l	dc.w	0,$f0
Pl5h	dc.w	0,$f2
Pl5l	dc.w	0
	

	dc.l	$4201fffe,$1840fb2,$4301fffe,$1840fa3,$4401fffe,$1840f94
	dc.w	$4501,$fffe,$184,$0f85
	dc.w	$4601,$fffe,$184,$0f76
	dc.w	$4701,$fffe,$184,$0f67
	dc.w	$4801,$fffe,$184,$0f58
	dc.w	$4901,$fffe,$184,$0f49
	dc.w	$4a01,$fffe,$184,$0f3a
	dc.w	$4b01,$fffe,$184,$0f2f
	dc.w	$4c01,$fffe,$184,$0f3e
	dc.w	$4d01,$fffe,$184,$0f4d
	dc.w	$4e01,$fffe,$184,$0f5c
	dc.w	$4f01,$fffe,$184,$0f6b
	dc.w	$5001,$fffe,$184,$0f7a
	dc.w	$5101,$fffe,$184,$0f89
	dc.w	$5201,$fffe,$184,$0f98
	dc.w	$5301,$fffe,$184,$0fa7
	dc.w	$5401,$fffe,$184,$0fb5
	dc.w	$5501,$fffe,$184,$0fc4
	dc.w	$5601,$fffe,$184,$0fd3
	dc.w	$5701,$fffe,$184,$0fe2
	dc.w	$5801,$fffe,$184,$0ff3
	dc.w	$5a01,$fffe,$184,$0fe4
	dc.w	$5b01,$fffe,$184,$0fd5
	dc.w	$5c01,$fffe,$184,$0fc6
	dc.w	$5d01,$fffe,$184,$0fb7
	dc.w	$5e01,$fffe,$184,$0fa8
	dc.w	$5f01,$fffe,$184,$0f99
	dc.w	$6001,$fffe,$184,$0f8a
	dc.w	$6101,$fffe,$184,$0f7b
	dc.w	$6201,$fffe,$184,$0f6a
	dc.w	$6301,$fffe,$184,$0f59
	dc.w	$6401,$fffe,$184,$0f48
	dc.w	$6501,$fffe,$184,$0f37
	dc.w	$6601,$fffe,$184,$0f26
	dc.w	$6701,$fffe,$184,$0f35
	dc.w	$6801,$fffe,$184,$0f44
	dc.w	$6901,$fffe,$184,$0f53
	dc.w	$6a01,$fffe,$184,$0f62
	dc.w	$6b01,$fffe,$184,$0f73
	dc.w	$6c01,$fffe,$184,$0f84
	dc.w	$6d01,$fffe,$184,$0fa5
	dc.w	$6e01,$fffe,$184,$0fb6
	dc.w	$6f01,$fffe,$184,$0fc7
	dc.w	$7001,$fffe,$184,$0fd8
	dc.w	$7101,$fffe,$184,$0fe9
	dc.w	$7201,$fffe,$184,$0ffa
	dc.w	$7301,$fffe,$184,$0feb
	dc.w	$7401,$fffe,$184,$0fdc
	dc.w	$7501,$fffe,$184,$0fcd
	dc.w	$7601,$fffe,$184,$0fbe
	dc.w	$7701,$fffe,$184,$0faf
	dc.w	$7801,$fffe,$184,$0f9e
	dc.w	$7901,$fffe,$184,$0f8d
	dc.w	$7a01,$fffe,$184,$0f7c
	dc.w	$7b01,$fffe,$184,$0f6b
	dc.w	$7c01,$fffe,$184,$0f5a
	dc.w	$7d01,$fffe,$184,$0f49
	dc.w	$7e01,$fffe,$184,$0f38
	dc.w	$7f01,$fffe,$184,$0f27
	dc.w	$8001,$fffe,$184,$0f36
	dc.w	$8101,$fffe,$184,$0f45
	dc.w	$8201,$fffe,$184,$0f54
	dc.w	$8301,$fffe,$184,$0f63
	dc.w	$8401,$fffe,$184,$0f72
	dc.w	$8501,$fffe,$184,$0f83
	dc.w	$8601,$fffe,$184,$0f94
	dc.w	$8701,$fffe,$184,$0fa5
	dc.w	$8801,$fffe,$184,$0fb6
	dc.w	$8901,$fffe,$184,$0fc7
	dc.w	$8a01,$fffe,$184,$0fd8
	dc.w	$8b01,$fffe,$184,$0fe9
	dc.w	$8c01,$fffe,$184,$0ffa
	dc.w	$8d01,$fffe,$184,$0feb
	dc.w	$8e01,$fffe,$184,$0fdc
	dc.w	$8f01,$fffe,$184,$0fcd
	dc.w	$9001,$fffe,$184,$0fbe
	dc.w	$9101,$fffe,$184,$0faf
	dc.w	$9201,$fffe,$184,$0f9e
	dc.w	$9301,$fffe,$184,$0f8d
	dc.w	$9401,$fffe,$184,$0f7c
	dc.w	$9501,$fffe,$184,$0f6b
	dc.w	$9601,$fffe,$184,$0f5a
	dc.w	$9701,$fffe,$184,$0f49
	dc.w	$9801,$fffe,$184,$0f38
	dc.w	$9901,$fffe,$184,$0f27
	dc.w	$9a01,$fffe,$184,$0f36
	dc.w	$9b01,$fffe,$184,$0f45
roll	dc.w	$9c01,$fffe,$184,$0f54
	dc.w	$9d01,$fffe,$184,$0f63
	dc.w	$9e01,$fffe,$184,$0000


barcop1:	
	dc.w $9e01,$fffe,$184,$0001
barcop2:
	dc.w $9f01,$fffe,$184,$0003
barcop3:
	dc.w $a001,$fffe,$184,$0005
barcop4:
	dc.w $a101,$fffe,$184,$0007	
barcop5:
	dc.w $a201,$fffe,$184,$0009
barcop6:
	dc.w $a301,$fffe,$184,$000b
barcop7:
	dc.w $a401,$fffe,$184,$000d
barcop8:
	dc.w $a501,$fffe,$184,$000f
barcop9:
	dc.w $a601,$fffe,$184,$000d
barcop10:
	dc.w $a701,$fffe,$184,$000b
barcop11:
	dc.w $a801,$fffe,$184,$0009
barcop12:
	dc.w $a901,$fffe,$184,$0007
barcop13:
	dc.w $aa01,$fffe,$184,$0005
barcop14:
	dc.w $ab01,$fffe,$184,$0003
barcop15:
	dc.w $ac01,$fffe,$184,$0001
barcop16:
	dc.w $ad01,$fffe,$184,$0000

barcop1a:	
	dc.w $c901,$fffe,$186,$0001
	dc.w $ca01,$fffe,$186,$0003
	dc.w $cb01,$fffe,$186,$0005
	dc.w $cc01,$fffe,$186,$0007	
	dc.w $cd01,$fffe,$186,$0009
	dc.w $ce01,$fffe,$186,$000b
	dc.w $cf01,$fffe,$186,$000d
	dc.w $d001,$fffe,$186,$000f
	dc.w $d101,$fffe,$186,$000d
	dc.w $d201,$fffe,$186,$000b
	dc.w $d301,$fffe,$186,$0009
	dc.w $d401,$fffe,$186,$0007
	dc.w $d501,$fffe,$186,$0005
	dc.w $d601,$fffe,$186,$0003
	dc.w $d701,$fffe,$186,$0001
	dc.w $d801,$fffe,$186,$0000

	dc.w	$ffff,$fffe		


*****************************************************************************
* LABELS,INCLUDES							    *
*****************************************************************************

GFXlib			DC.B "graphics.library"
Stackpoint		DC.L 0
GFXbase			DC.L 0
screen:		dcb.l	0
INTrqsave		DC.W 0
INTensave		DC.W 0
DMAsave			DC.W 0

	even

barflag:		dc.b	1
	even

 SECTION  LOWMEM,DATA_C

LOGO		incbin	source10:bitmaps1/monitor3.raw

