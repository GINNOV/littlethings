; PAUSE, the alternative Wait command - SK 22nd September 1990.
; Special thanks to Mark M for letting me in on how to get parameters
; from the CLI.
; (Yes, very untidy code. Sorry about this).

	clr.l	d2		for number of seconds to pause
	clr.l	d1		for time-lapse
	move.b	(a0),d2		save number: a0 points to adr of string
	cmpi.b	#"0",d2		check input
	bgt	next1		if greater than 0 (acsii 48) then jump
	move.b	#"1",d2		else alter d2. This also sets default 1 if no
;				parameter is given. Neat huh?

next1	cmpi.b	#":",d2		char after ascii 9
	blt	next2		if less than then carry on
	move.b	#"1",d2		else change to 1.
;				** Remove above line to enable waits of
;				** up to 78 seconds (Using tide mark ~ top
;				** left of keyboard - ascii 126)

next2	move.w	#500,d1		length of wait for one second
	sub.w	#48,d2		change ascii to numerical value
	mulu	d1,d2		multiply 500 x number of secs, result in d2

pause	cmp.b	#200,$dff006	wait for scanline 200
	bne	pause		not there? back to pause
	dbra	d2,pause
	rts
