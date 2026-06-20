

example:	lea	HexASCII(pc),a0		; parameter (ASCII HEX)
		bsr	Ascii2Hex		; convert ASCII HEX to HEX

		move.l	d0,HexNumber		; save hex number

wait		btst	#6,$bfe001
		bne.s	wait
 
		moveq.l	#0,d0
		rts	

*************************************************************************************
*
* ASCII HEX (INPUT) to HEX longword
* ---------------------------------
*
* Note-: Only converts lowercase hex, ie $3f will convert but $3F will not convert.
*
*************************************************************************************
 
Ascii2Hex	moveq.l	#0,d7
		moveq.l	#0,d0
ASCIIloop	move.b	(a0)+,d0
		cmp.b	#'0',d0
		blt.s	NotLegal
 	
		cmp.b	#'f',d0
		bgt.s	NotLegal
 
		bsr.s	HexNum
		lsl.l	#4,d7
		or.l	d0,d7
		bra.s	ASCIIloop
 
NotLegal	move.l	d7,d0
		rts	
 
HexNum		cmp.b	#'9',d0
		bgt.s	HexLet
 
		sub.b	#48,d0
		rts	
 
HexLet		sub.b	#87,d0
		rts	

*************************************************************************************

HexASCII	dc.b	'2222a',0	; example ASCII hex number
		even
HexNumber	dc.l	0		; this will contain the number in HEX
		even

