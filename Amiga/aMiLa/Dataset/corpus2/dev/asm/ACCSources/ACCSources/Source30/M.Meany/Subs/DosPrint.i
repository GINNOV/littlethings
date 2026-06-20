
; Subroutine to print a message into std_out! If std_out is NULL, a temporary
;console is opened and program will not return until user acknowledges text
;displayed.

; Entry		a0->NULL terminated message
;		std_out to be defined somewhere in calling program

; Exit		nothing in particular

; corrupt	none

DOSPrint	movem.l		d0-d4/a0-a4/a6,-(sp)

; Determine length of string

		move.l		a0,a4			copy pointer
		moveq.l		#-1,d3			clear counter

.LenLoop	addq.l		#1,d3			bump counter
		tst.b		(a0)+			check for EOL
		bne.s		.LenLoop		loop if not!

; Print the text

		move.l		std_out,d1		CLI handle
		beq.s		.done			exit if no console
		move.l		a4,d2			buffer
		CALLDOS		Write			write the text

.done		movem.l		(sp)+,d0-d4/a0-a4/a6
		rts

