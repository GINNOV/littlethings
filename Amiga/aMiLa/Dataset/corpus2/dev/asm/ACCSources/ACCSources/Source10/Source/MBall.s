** AUTHOR: HEARWIG
* A VERY simple bat+ball part-game.  It is pathetic to play, though, you
* have been warned!  Sets up a joystick controlled bat and a ball which
* bounces amazingly unrealistically and the sound is absolutely stunning
* (cough, cough).  Again interrupts used for smooth graphics + good time
	section	Raists,Code_c
	include	source10:include/hardware.i	This section is the same as Move_Sprite
	lea	library,a1
	clr.l	d0
	move.l	4,a6
	jsr	-408(a6)
	move.l	d0,base
reserve	move.l	#40*256*2,d0
	move.l	#2,d1
	jsr	-198(a6)
	move.l	d0,b1
	move.w	d0,bpl1
	swap	d0
	move.w	d0,bpl1h
	swap	d0
	add.l	#40*256,d0
	move.l	d0,b2
	move.w	d0,bpl2
	swap	d0
	move.w	d0,bpl2h
	move.l	#sprite,d0
	move.w	d0,spritec+2
	swap	d0
	move.w	d0,spritec+6
	move.l	#bat,d0		But a bat is added
	move.w	d0,spritec+10
	swap	d0
	move.w	d0,spritec+14
	move.l	b1,a1
	move.l	#10*256*2-1,d0	And the whole screen is clear this time
clear2	clr.l	(a1)+
	dbra	d0,clear2
	lea	$dff000,a5
	move.l	#list,COP1LCH(a5)
	move.w	#0,COPJMP1(a5)
	move.l	$6c,inter+2
	move.l	#myinter,$6c
waitb	btst	#6,$bfe001	The mouse button quits prog because fire button needed down below
	bne	waitb
	move.l	inter+2,$6c
	move.l	base,a4
	move.l	38(a4),COP1LCH(a5)
	move.l	b1,a1
	move.l	#40*256*2,d0
	jsr	-210(a6)
	move.l	base,a1
	jmp	-414(a6)
	even
library	dc.b	'graphics.library',0,0
	even
b1	dc.l	0
b2	dc.l	0
base	dc.l	0
list	dc.w	BPL1PTL
bpl1	dc.w	0,BPL1PTH
bpl1h	dc.w	0,BPL2PTL
bpl2	dc.w	0,BPL2PTH
bpl2h	dc.w	0
	dc.w	BPLCON0,%10001000000000
	dc.w	BPLCON1,0
	dc.w	BPLCON2,0
	dc.w	DIWSTRT,$2981
	dc.w	DIWSTOP,$29c1
	dc.w	DDFSTRT,$35
	dc.w	DDFSTOP,$c8
	dc.w	COLOR00,0
	dc.w	COLOR17,$a00
	dc.w	COLOR18,$ff0
	dc.w	COLOR19,$f0f
spritec	dc.w	SPR0PTL,0
	dc.w	SPR0PTH,0
	dc.w	SPR1PTL,0
	dc.w	SPR1PTH,0
	dc.w	SPR2PTL,0
	dc.w	SPR2PTH,0
	dc.w	SPR3PTL,0
	dc.w	SPR3PTH,0
	dc.w	SPR4PTL,0
	dc.w	SPR4PTH,0
	dc.w	SPR5PTL,0
	dc.w	SPR5PTH,0
	dc.w	SPR6PTL,0
	dc.w	SPR6PTH,0
	dc.w	SPR7PTL,0
	dc.w	SPR7PTH,0
	dc.w	COLOR01,$c00
	dc.w	$ffff,$fffe
bat	dc.w	$f770,$ff00	the bat
	dc.w	$7ffe,$0000
	dc.w	$f00f,$3ffc
	dc.w	$cff3,$3ffc
	dc.w	$cc33,$3ffc
	dc.w	$cc33,$3ffc
	dc.w	$cff3,$3ffc
	dc.w	$f00f,$3ffc
	dc.w	$7ffe,$0000
	dc.w	0,0
sprite	dc.w	$7070,$7c00	the ball
	dc.w	$0180,0
	dc.w	$07e0,0
	dc.w	$0ff0,0
	dc.w	$1ff8,0
	dc.w	$1ff8,0
	dc.w	$3ffc,0
	dc.w	$3ffc,0
	dc.w	$1ff8,0
	dc.w	$1ff8,0
	dc.w	$0ff0,0
	dc.w	$07e0,0
	dc.w	$0180,0
	dc.w	0,0
myinter	movem.l	d0-d7/a0-a6,-(sp)	The interrupt
left	btst.b	#1,$dff00c	Similar idea for movement, but only left/right
	beq	right		if bit 1 not set(not going left), go to right
	cmp.b	#$40,bat+1	if too far left
	bcs	right		go to right
	subq.b	#2,bat+1	move bat left
right	btst.b	#1,$dff00d	if bit 1 not set(not going right),
	beq	out		go to out
	cmp.b	#$d8,bat+1	if too far right
	bcc	out		go to out
	addq.b	#2,bat+1	move bat right
out	move.b	xinc,d0		get x movement
	add.b	d0,sprite+1	and move ball horizontally
	move.b	yinc,d0		get y movement
	add.b	d0,sprite	and move ball vertically
	add.b	d0,sprite+2
	btst	#7,d0		COLLISION DETECTION (VERY CRUDE ONE.  IF IT WERE A GAME, I WOULD CHANGE IT TO A BETTER ONE):if ball is moving up
	bne	notd		it can't hit the bat, so go to next bit
	cmp.b	#$eb,sprite	right height to hit ball
	bcs	notd		if higher than this, go to next bit
	move.b	bat+1,d0	get bat x pos
	sub.b	#6,d0		take 6 away
	cmp.b	sprite+1,d0	if ball futher left than d0, won't hit bat (well, in theory)
	bcc	notd		so now we know
	add.b	#22,d0		add 22 to d0
	cmp.b	sprite+1,d0	if ball futher right than d0, won't hit bat (cough)
	bcs	notd		what a suprise!
	subq.b	#8,d0		Get middle of bat
	sub.b	sprite+1,d0	and take away ball pos from bat middle
	asr.b	#2,d0		divide it by 4 (not used div because could crash if dividing by zero)
	move.b	d0,xinc		and this is the new x movement
	move.b	#-4,yinc	x movement+y movement should be around 5, so alter y movement
	add.b	d0,yinc
notd	cmp.b	#$f3,sprite	has ball fallen too far?
	bcs	note		no, go on then
	move.b	#$30,sprite	put ball back at top
	move.b	#$3c,sprite+2
	move.b	sprite+1,d1	this routine is supposed to get a fairly random number.  Is not worth using elsewhere
	eor.b	d1,d0
	and.b	#3,d0		only want a number from 0 to 3
	move.b	d0,xinc		and make this x movement
	move.b	#-4,yinc	again, x movement+y movement should be around 5
	add.b	d0,yinc
waitf	btst	#7,$bfe001	wait for fire button before going on
	bne.s	waitf
note	cmp.b	#$30,sprite	and now the bouncing stuff.  Top boundary?
	bcc	nub		no, then go on
	neg.b	yinc		make y movement positive, so ball goes down
nub	cmp.b	#$40,sprite+1	left boundary?
	bcc	nlb		no, then go on
	neg.b	xinc		make x inc positive, so going right
nlb	cmp.b	#$d8,sprite+1	right boundary?
	bcs	nrb		then go on
	neg.b	xinc		make x negative, so ball goes left
nrb
	movem.l	(sp)+,d0-d7/a0-a6	restore pointers
inter	jmp	$0000000	and old routine
xinc	dc.b	2		(starting) x movement.  If xinc is negative, since we are dealing with ball x pos of 0-255 (not altering 2nd command word), adding a negative makes it go left
yinc	dc.b	2		(starting) y movement.  "  "  "  "
