; joystick test
; -------------
                  moveq	#0,d0
	move.b	joy1dat(a0),d0	;d0 bit 8-15
	move.b	joy1dat+1(a0),d5	;d5 bit 0-7

	move	d5,d2
	lsr	#1,d2	;d2 bit 1
	move	d0,d4
	lsr	#1,d4	;d4 bit 9
	btst	#0,d2
	beq	.no_right
**** right ***

	bra	.no_left
.no_right
	btst	#0,d4
	beq	.no_left
**** left ****

.no_left
	eor	d5,d2
	btst	#0,d2
	beq	.no_down
**** down ****

	bra	.no_up
.no_down
	eor	d0,d4
	btst	#0,d4
	beq	.no_up
**** up ******

.no_up

