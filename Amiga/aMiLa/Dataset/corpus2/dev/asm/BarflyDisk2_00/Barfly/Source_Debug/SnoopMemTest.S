;This example can be used to see the SnoopMemory window 
;reporting the memory actions
	move.l	4.w,a6
	move.l	#$10,d0
	move.l	#$10001,d1
	jsr	-198(a6)
	move.l	d0,a1
	move.l	#$10,d0
	jsr	-210(a6)
	rts

