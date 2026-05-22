; Plot.I version 2.00 (30/7/93)
;
; © Copyright 1993 Stuart McDonald
;

; on entry:	d0 =	x
;          	d1 =	y

x		EQUR	d0
y		EQUR	d1
byte		EQUR	d2
temp		EQUR	d3
bitinbyte	EQUR	d4

pointer	    	EQUR	a0

;----------------------------------------------------------------------------

PLOT
	move.l		x,byte
	lsr.l		#3,byte

	move.l		byte,temp
	lsl.l		#3,temp
	move.l		x,bitinbyte
	sub.l		temp,bitinbyte

	move.l		#SCREEN_BASE_ADDRESS,pointer
	
	move.l		y,temp
	lsl.l		#2,temp
	add.l	   	y,temp
	lsl.l		#3,temp
		
	add.l		temp,pointer
	add.l		byte,pointer
	neg.l		bitinbyte
	addq.l		#7,bitinbyte

	bset.b		bitinbyte,(pointer)
	rts