;;; JOYSTICK INCLUDE FILE v1.3 by TM0312881546


; sortentry.comments added -> v1.3  04.03.1989

*T
*T	JOYLIB.I * Metacc Include File
*T		Version 1.3
*T	      Date 04.03.1989
*T
*B

;  stick	(read joystick direction)
;  in:		d0=port_number;
;  call:	joylib stick;
;  out:		d0=x_direction; /left=-1,0,1=right/
;		d1=y_direction; /up=-1,0,1=down/
;		d2=fire_button; /0,1=pressed/

;  rangerand	(generate random numbers)
;  in:		d0=range;
;  call:	joylib	rangerand;
;  out:		d0=random_number;
;  notes:	/Needs GFX/
;		/'range' should be between 0 and 256/
;		/'random_number' is chosen between [0..]range/
;		/thus including '0' but excluding 'range'/

*E



joylib	macro
	ifnc	'','\1'
_JOYF\1	set	1
	bsr	_JOY\1
	mexit
	endc

	ifd	_JOYFstick

_JOYstick	push	a0/d3-d5
		moveq	#6,d3
		lea	$dff00a,a0
		btst	#0,d0
		beq	_stick0
		lea	2(a0),a0
		moveq	#7,d3
_stick0		moveq	#0,d2		;fireb status
		moveq	#0,d4		;dx
		moveq	#0,d5		;dy
		move.b	$bfe001,d1
		btst	d3,d1
		bne	_stick1
		bset	#0,d2		;fire
_stick1		move.w	(a0),d1
		btst	#9,d1
		bne	_stick2
		addq.l	#1,d4
_stick2		btst	#1,d1
		bne	_stick3
		subq.l	#1,d4
_stick3		move.w	d1,d0
		lsr.w	#1,d0
		eor.w	d0,d1
		btst	#0,d1
		bne	_stick4
		subq.l	#1,d5
_stick4		btst	#8,d1
		bne	_stick5
		addq.l	#1,d5
_stick5		move.l	d4,d0
		move.l	d5,d1
		pull	a0/d3-d5
		rts

	endc

	ifd	_JOYFrangerand
_JOYrangerand	push	d1
		move.l	d0,d1
		push	d1/a0-a1
		lib	Gfx,VBeamPos
		and.l	#$ff,d0
		lea.l	_JOYrangerands(pc),a0
		move.b	(a0),d1
		eor.b	d1,d0
		move.b	d0,d1
		add.b	#$39,d1
		move.b	d1,(a0)
		pull	d1/a0-a1
		mulu.w	d1,d0
		lsr.l	#8,d0
		pull	d1
		rts
_JOYrangerands	dc.w	0
	endc

	endm


