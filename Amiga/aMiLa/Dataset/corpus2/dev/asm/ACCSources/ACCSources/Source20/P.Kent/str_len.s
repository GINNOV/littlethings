
; This subroutine calculates the length of a 0 terminated string of characters.

; Entry :  a0 must hold the address of the string

; Exit  :  d0 holds the length of the string
;          a0 saved

str_len
		move.l	a0,-(a7)
		moveq.l	#-1,d0		initialise counter
.loop
		addq.l	#1,d0		bump counter
		tst.b	(a0)+		end of string ?
		bne.s	.loop		if not loop back
		move.l	(a7)+,a0
		rts					all done so return
