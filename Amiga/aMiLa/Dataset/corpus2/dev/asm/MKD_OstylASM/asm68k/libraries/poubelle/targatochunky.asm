שתשתÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ**********************************************************************
**
**	Targa to Chunky
**
**	By:
**	Ostyl^MKD
**
**	Rev.Date:
**	17.07.02
**
**********************************************************************

	INCDIR	INCLUDES:
	INCLUDE	DOS/DOS.i
	INCLUDE	MISC/DEVPACMACROS.i
	INCLUDE	MACROS/STARTUPWOS.i
	INCLUDE	POWERPC/MEMORYPPC.i

	XDEF	TGAtoCNK12
	XDEF	TGAtoCNK15
	XDEF	SaveTGA

	XREF	_DosBase
	XREF	AllocMemPPC

;---------------------------------------
;	Targa to Chunky 12bit
;
;	TGA 		-> a0
;	CNK12dest	-> a1

TGAtoCNK12
	Bsr.W	DataType

	Tst.L	a0
	Beq.W	Fin
	Tst.L	a1
	Beq.W	Fin

	Move.L	12(a0),d0
	Moveq	#0,d1
	Rol     #8,d0
	Swap    d0
	Rol     #8,d0	
	Move	d0,d1
	Clr	d0
	Swap	d0
	Mulu.W	d0,d1		; d1 = picsize

	Lea	18(a0),a0
	Move.L	#%11110000111100001111000000000000,d2

Loop1	Move.L	(a0),d0		
	And.L	d2,d0
	Rol	#5,d0
	Swap	d0
	Rol	#8,d0
	Lsr	#4,d0
	Lsl.B	#3,d0	
	Lsl	#4,d0
	Lsr.L	#6,d0
	Move	d0,(a1)+
	Lea	3(a0),a0

	Subq.L	#1,d1
	Bne.B	Loop1

	Rts

;---------------------------------------
;	Targa to Chunky 15bit
;
;	a0 = Targa
;	a1 = CNK15 allocated destination

TGAtoCNK15
	Bsr.W	DataType
	Tst.L	a0
	Beq.B	CNK15_Err	

	;----
	
	Move.L	12(a0),d0
	Moveq	#0,d1
	Rol     #8,d0
	Swap    d0
	Rol     #8,d0	
	Move	d0,d1
	Clr	d0
	Swap	d0
	Mulu	d1,d0		; d0 = picsize

	;----

	Movem.L	d0/a0,-(sp)
	Add.L	d0,d0
	Move.L	#MEMF_FAST+MEMF_CLEAR+MEMF_CACHEON,d1
	Moveq	#0,d2
	Jsr	AllocMemPPC

	Movem.L	(sp)+,d1/a0
	Move.L	d0,a1
	Beq.B	Fin

	;----

	Lea	18(a0),a0
	Move.L	#%11111000111110001111100000000000,d2
	Move.L	a1,-(sp)

Loop15:	Move.L	(a0),d0		
	And.L	d2,d0
	Rol	#5,d0
	Swap	d0
	Rol	#5,d0
	Lsl.B	#3,d0
	Lsl	#3,d0
	Lsr.L	#6,d0
	Move	d0,(a1)+
	Lea	3(a0),a0
	Subq.L	#1,d1
	Bne.B	Loop15

Fin:	Move.L	(sp)+,d0
	Rts

	;----

CNK15_Err:
	WrtCon	#CNK15_ErrorMess
	Moveq	#0,d0
	Rts

;---------------------------------------
;	Save as targafile 
;
;	Image Width		-> d0
;	Image Height		-> d1
;	Filename		-> a0
;	15bit chunkydata	-> a1

SaveTGA	Move.L	d0,d2
	Mulu.W	d1,d2

	Movem.L	d0-d2/a1,-(sp)
	
	Move.L	_DosBase,a6
	Move.L	a0,d1
	Move.L	#MODE_NEWFILE,d2
	Jsr	_LVOOpen(a6)
	Move.L	d0,TGA_Handle
	Beq.W	SaveError

	Movem.L	(sp),d0/d1
	Lea	TGA_Header,a0
	Move.B	#2,2(a0)
	Rol	#8,d0
	Rol	#8,d1
	Move	d0,12(a0)
	Move	d1,14(a0)
	Move.B	#16,16(a0)

	Move.L	_DosBase,a6
	Move.L	TGA_Handle(pc),d1
	Move.L	a0,d2
	Move.L	#18,d3
	Jsr	_LVOWrite(a6)

	Movem.L	(sp),d0-d2/a5
	Move.L	d2,d7
	Move.L	_DosBase,a6

Loop3	Move.L	TGA_Handle(pc),d1
	Moveq	#0,d2
	Move.B	1(a5),d2
	Jsr	_LVOFPutC(a6)
	Move.L	TGA_Handle(pc),d1
	Moveq	#0,d2
	Move.B	(a5),d2
	Jsr	_LVOFPutC(a6)
	Subq.L	#1,d7
	Addq.L	#2,a5
	Bne.B	Loop3

	Move.L	_DosBase,a6
	Move.L	TGA_Handle(pc),d1
	Jsr	_LVOClose(a6)

	;WrtCon	#Save_DoneMess

	Movem.L	(sp)+,d0-d2/a1
	Rts

SaveError
	;WrtCon	#Save_ErrorMess	
	Movem.L	(sp)+,d0-d2/a1
	Rts

;---------------------------------------
;	Check for the DataType
;
;	TGA 		-> a0

DataType
	Cmp.B	#2,2(a0)
	Bne.B	Bad_DataType
	Cmp.B	#24,7(a0)
	Bne.B	Bad_DataType
	Rts

Bad_DataType
	WrtCon	#DT_ErrorMess
	Sub.L	a0,a0
	Rts

TGA_Header	Ds.B	18
TGA_Handle	Ds.L	1

Save_DoneMess
	Dc.B	10,"Targa picture succesfully saved.",10,0
	EVEN

Save_ErrorMess
	Dc.B	10,"Can't save Targa output file.",10,0
	EVEN

DT_ErrorMess
	Dc.B	10,"Targa filetype not supported.",10,0
	EVEN

CNK15_ErrorMess
	Dc.B	10,"TGAtoCNK15() has returned with error.",10,0
