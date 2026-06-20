*************************************************************************************
*
* Hex -> Ascii Decimal
* --------------------
*
* After supplying the required parameters, the routine will convert the Hexdecimal
* longword into an ASCII text result. Note-: Leading Zeros will be replaced with
* spaces (ASCII CHARACTER $20)
*
*************************************************************************************

ExampleParams	lea	ASCIIout,a0		;ASCII text output
		move.l	#$0f000000,d0		;example hex number
		bsr.s	getdecimal		;convert it !
		rts

*************************************************************************************
* Converts a Hexdecimal longword into ASCII decimal text
* ------------------------------------------------------
*
* a0 = ASCII Output buffer ( After conversion will hold decimal number in ASCII )
* d0 = Hex Longword to Convert
*
*************************************************************************************
 
getdecimal	move.b	#" ",d5			; replace leading zero's with spaces
		lea	hextable(pc),a1

		move.w	#8,d4

ccloop		move.l	(a1)+,d1
		cmp.l	d1,d0
		bcs.s	get3
 
		move.w	#32-1,d3
		moveq.l	#0,d2
get1		asl.l	#1,d0
		roxl.l	#1,d2
		cmp.l	d1,d2
		bcs.s	get2
 
		sub.l	d1,d2
		addq.l	#1,d0
get2		dbra	d3,get1
	 
		add.b	#48,d0
		move.b	d0,(a0)+
		move.l	d2,d0
		move.b	#48,d5
		bra.s	get4
 
get3		move.b	d5,(a0)+
get4		dbra	d4,ccloop
 
		add.b	#48,d0
		move.b	d0,(a0)+
		rts

hextable	dc.l	1000000000
		dc.l	100000000
		dc.l	10000000
		dc.l	1000000
		dc.l	100000
		dc.l	10000
		dc.l	1000
		dc.l	100
		dc.l	10
		even
ASCIIout	dc.b	'0000000000',$a


