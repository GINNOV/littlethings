; mc0303.s
; only on letter_03 p. 13

start:
	move.l  #15,d0			; Line 1:  Moves the constant number of 15 into D0. Here, D0 is used again as a counter. 
	move.l  #$00,a0			; Line 2:  Moves the constant number of $00 into A0 (A0 points to address $000000)
	lea.l   buffer,a1		; Line 3:  loads the effective address of our buffer into A1. 
loop:						; Line 4:  The label "loop".
	move.b  (a0)+,(al)+		; Line 5:  Replacing lines 5,6,7 and 8 in the second example. 
	dbra   d0,loop			; Line 6:  Replace lines 9, 10 and 11 in the second example, Again, this instruction will be explained below.
	RTS						; Line 7:  Exits the program. 

buffer:						; Line 9:  The label to our buffer. 
	blk.b   16,0			; Line 10:  Reserves 16 bytes and set them to "0". 

	end
	 