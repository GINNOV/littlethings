	include	"Error.i"

test	macro
	test1
	endm

	moveq.p	#10,d9
	lea.l	a0,a0
	move.b	#0,a0
	rte
