;This example should show the odd stack checking
;ATTENTION..this example can lead to a crash on
;a <68020 system.
;NEVER USE AN ODD STACK!!!!!
	move.l	a7,d1
        bset	#0,d1
	move.l	d1,a7
	bclr	#0,d1
	move.l	d1,a7
	rts

