; this source will take numbers from a row, subtract #$10 from them,
; and put them in another row. Note that you must reserve a room in
; memory to put the new values in. This is done with BLK.x:
;   BLK.B 10,0   reserves a room of 10 bytes in memory and fills
;		 them with 0's



top:	movem.l	d0-d7/a0-a6,-(a7)	; save registers

	lea.l	row1,a0		; put the address of 'row1' in a0
				; same as: MOVE.L #row1,a0
	lea.l	row2,a1		; idem... row2 is the empty row

loop:	cmp.l	#endrow1,a0	; check if we reached the end...
				; note that we compare addresses,
				; so we must compare all 32 bits
				; (=longword : CMP.L)
	beq.s	endloop		; if so, branch (short) to 'end'

	move.b	(a0)+,d0	; move contents of (a0) to d0 and
				; increase a0
	sub.b	#$10,d0		; subtract hexadecimal value #$10
				; from d0
	move.b	d0,(a1)+	; move contents of d0 to the other
				; row and increase a1
	bra.s	loop		; do it again !! (branch short)

endloop:

	movem.l	(a7)+,d0-d7/a0-a6	; don't forget to reload
					; the registers after you
	rts      ; return !		; saved them. In fact you 
					; should save registers at
					; the start of each source,
					; but if you didn't, you can
					; ofcourse not reload them !

; after you've assembled the source, have a look at the 2 rows: type
; '@hrow1' and '@hrow2': you'll see row1 filled with the values in the
; next list:

row1:	dc.b	$20,$40,$5a,$a4,$ff,$03,$10,$40
	dc.b	$64,$29,$65,$77,$b0,$ac,$00,$e2
endrow1:

; before executing, row2 will still be filled with zeros, but after
; executing, row2 will contain the values from row1, minus #$10

length=	endrow1-row1

row2:	blk.b	length,0

; in these last lines you see a very powerful feature of Asmone. You
; can do calculations. Here we calculated the size of the
; first row. Row1 starts at label 'row1' and ends at label 'endrow1'
; By subtracting addres 'row1' (let's say it is $10000) from 
; 'endrow1' (let's say $10010), we get the length of the row (#$10)
; This value is automatically calculated by Seka when you assemble
; the source. The line 'length= endrow1-row1'  is NOT an assembler-
; command, this line is not included in the assembled program.

; note: this documentation could be very nice, but it could also
;	make the program look unoverviewable, so maybe you should
;	remove all the info-lines from it, and again have a look.
;	This could make it all a bit more understandable !

