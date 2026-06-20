;This example doesn't make any sense and is only
;useful to show some features in the RegWindow
;and the terminating by a Break-Signal.


hal0=0
hallo1:
	moveq	#hal0,d0
	moveq	#1,d1
teosjdfkjdsfdjssfsdf:
	moveq	#2,d2
	moveq	#3,d3
	moveq	#4,d4
luf:
	moveq	#5,d5
	moveq	#6,d6
	moveq	#7,d7
pe:
	lea.l	$dff05b,a0
	lea.l	$dff096,a1
	lea.l	$dff1be,a2
	lea.l	$dff1c2,a3
	lea.l	$dff1e4,a4
	lea.l	$dff1f0,a5
loop:
	move.l	4.w,a6
	sub.l	a1,a1
	jsr	-294(a6)
	move.l	d0,a1
	move.l	26(a1),d0
	btst	#12,d0
	bne.s	ende
	add.l	d0,d1
	add.l	d1,d2
	add.l	d2,d3
	add.l	d3,d4
	add.l	d4,d5
	add.l	d5,d6
	bsr.s	test
	swap	d0
	bra.s	loop

test:
	moveq	#0,d0
	moveq	#1,d1
loop_0:
	dbra	d1,loop_0
	rts
ende:
	moveq	#1,d0
	rts

 