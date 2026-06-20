;************************
;*   A little example   *
;************************

; Enter the debugger and AddWatch on the BUFFER of String type.
; Press Arrow Down to single step the program. To enter the
; subroutine press Arrow Left.
; The hexvalue $1231 in D0 will slowly be converted into the
; binary number %1001000110001

J:	MOVE.L	#$1231,D0
	LEA.L	BUFFER(PC),A0

.AGAIN:	MOVE.L	D0,-(A7)
	LSR.L	#1,D0
	BEQ.S	.FINI
	BSR.S	.AGAIN
.FINI:	MOVE.L	(A7)+,D0
	AND.W	#1,D0
	MOVEQ	#'0',D1
	ADD.W	D0,D1
	MOVE.B	D1,(A0)+
	RTS

BUFFER:	DCB.B	100,0
