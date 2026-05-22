
;You'llhave to use MONAM2 to see this progy in action

;Taken from Abicus Systems Programers Guide (which isn't as good as its 
;said to be (my opinion of course))

	opt	d+		; First time I've used this option
;Code to test the condition of the joystick
middle
	move.w	$dff00c,d0	; Move JOY1DAT into D0
	btst	#1,d0		; Test bit no. 1
	bne	right		; Set? If so, joystick right
	btst	#9,d0		; Test bit no. 9
	bne	left		; Set? If so, joystick left

	move.w	d0,d1		; copy D0 to D1
	lsr.w	#1,d1		; Move Y1 & X1 to pos of Y0 & X0
	eor.w	d0,d1		; Exclusive OR: Y1 EOR X1 & Y0 EOR X0
	btst	#0,d1		; Test result of X1 EOR X0
	bne	back		; Equal 1? If so, joystick backward
	btst	#8,d1		; Test result of Y1 EOR Y0
	bne	forward		; Equal 1? If so, joystick forward
	bra	middle		; Joystick not moved


right	rts
left	rts
back	rts
forward	rts

