*AUTHOR: HEARWIG
	section	l,code_c 
* Sets up a yellow grid on blitplane and ball can be moved round it
* by joystick
* Have used interrupts for 2 reasons: 1/50th of a second is a good time
* between movements, not too fast, and not too slow.  Also because the
* interrupt is called within the vertical blanking period, ie. when
* screen is being updated, and so the movement is super-smooth. If not
* used, would be a bit of flicker.
	include	source10:include/hardware.i	* There we are - a better include for y'
	lea	library,a1	* You know all this:
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

	move.l	b1,a1
	move.l	#2559,d0
clear2	clr.l	(a1)+		Clear 1st bitplane
	dbra	d0,clear2
	move.l	#15,d0		Number of rows of grids-1
line	move.l	#149,d1		draw a block 1's (vertical lines)
clear	move.l	#1,(a1)+
	dbra	d1,clear

bline	move.l	#9,d1		And then a line
blined	move.l	#-1,(a1)+
	dbra	d1,blined
	dbra	d0,line		keep on doing it until grid finished

	lea	$dff000,a5
	move.l	#list,COP1LCH(a5)
	move.w	#0,COPJMP1(a5)
	move.l	$6c,inter+2	save old interrupt in jmp instruction (this is Mike Cross's way.  For some reason, it is supposed to be a naughty way, but it always works)
	move.l	#myinter,$6c	and put my interrupt in
waitb	btst	#7,$bfe001	wait for fire button
	bne	waitb
	move.l	inter+2,$6c	and put back old interrupt
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
	dc.w	COLOR01,$f00
	dc.w	COLOR02,$ff0
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
	dc.w	COLOR01,$f00
	dc.w	$ffff,$fffe
sprite	dc.w	$7070,$7c00	The ball
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

myinter	movem.l	d0-d7/a0-a6,-(sp)	Save registers (might aswell save all if you save one)
	move.b	$dff00c,d0	get up/left joystick position
	and.l	#3,d0		mask out all but the 2 bits we need
	beq	right		if no u/l movement go on to right
	btst	#1,d0		bit 1 set if going left
	beq	up		so if it ain't, go to see if up
	cmp.b	#$40,sprite+1	is it too far left to move
	bcs	up		if so, dont do owt
	subq.b	#1,sprite+1	move sprite left

up	subq.b	#1,d0		take 1 away from joy position.  If you do this, bit 1 will be clear if going up.  If you use this method, have a check for no movement first, else it will always go up
	btst	#1,d0		so is it going up
	bne	right		no, then check next movement
	cmp.b	#$2c,sprite	is it too far up to move
	bcs	right		if so, next movement
	subq.b	#1,sprite	move up
	subq.b	#1,sprite+2

right	move.b	$dff00d,d0	get right/down movement
	and.l	#3,d0		mask out stupid bits
	beq	out		and if result zero (no r/d movement) go to out
	btst	#1,d0		bit 1 set if going right
	beq	down		and so if its 0, go to down
	cmp.b	#$d8,sprite+1	is it too far right
	bcc	down		next movement if so
	addq.b	#1,sprite+1	move right

down	subq.b	#1,d0		take 1 away, like for $dff00c
	btst	#1,d0		if no down movement (ie. bit 1=1)
	bne	out		go out
	cmp.b	#$f0,sprite	too far down?  (it can go futher down, but if would mean faffing around with second command word, not worth the bother)
	bcc	out		if so, go out
	addq.b	#1,sprite	move down
	addq.b	#1,sprite+2
out	movem.l	(sp)+,d0-d7/a0-a6	restore all registers
inter	jmp	$0000000	and call old interrupt routine (should be done)
