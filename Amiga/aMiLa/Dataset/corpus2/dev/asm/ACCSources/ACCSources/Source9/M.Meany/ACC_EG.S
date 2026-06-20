
; A very short routine to assemble using ACC and A68K. M.Meany 1991.

; Open the Intuition library

start	lea	intname,a1
	moveq.l	#0,d0
	move.l	$4,a6
	jsr	-552(a6)
	move.l	d0,_IntBase
	beq	error

; Flash the screen

	sub.l	a0,a0
	move.l	d0,a6
	jsr	-96(a6)

; Close Intuition library

	move.l	_IntBase,a1
	move.l	$4,a6
	jsr	-414(a6)

error	rts

intname	dc.b	'intuition.library',0
	even
_IntBase dc.l	0

	end



