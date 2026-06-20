; Moves a bob (being lazy it's just the same as the Reflection one) left
; and right

; To prevent the wrapping around of the bob at high shift values, 2 is
; added to the length of the bob for the blit operations, a last word mask
; of 0 used to stop the first word of the next line of the bob being displayed
; and a modulo for A of -2 to bring it back to the start of the next line
; of the bob.  This means that before shifting, the last 16 bits of what is
; blitted is always 0, so it does not matter what the shift value is.
	saection	c,code_c
	opt	c-
	include ram:hardware.i

speed	=2	Make speed either 1 (slowest), 2, 4 or 8
speed1	=speed<<12	Shift speed number so its in top 4 bits of word (for bltcon0)
speed2	=(16-speed)<<12
	
; Usual stuff :
	move.l	4,a6
	lea	library,a1	Open gfx lib
	jsr	-408(a6)
	move.l	d0,base
	move.l	#40*256*3,d0	Set-up bitplanes
	move.l	#2,d1
	jsr	-198(a6)
	move.l	d0,b1
	move.w	d0,b1l
	swap	d0
	move.w	d0,b1h
	swap	d0
	add.l	#40*256,d0
	move.l	d0,b2
	move.w	d0,b2l
	swap	d0
	move.w	d0,b2h
	swap	d0
	add.l	#40*256,d0
	move.l	d0,b3
	move.w	d0,b3l
	swap	d0
	move.w	d0,b3h
	lea	$dff000,a5
	move.l	#copper,cop1lch(a5)
	move.w	#0,copjmp1(a5)
	move.l	b1,a1
	move.l	#30*256-1,d0
clear	clr.l	(a1)+	Clear screen
	dbra	d0,clear

; From here on, a2=address of bob on first bitplane, d1 is the direction
; (1=left, 0=right) and d2 is the count.  The count is decremented every
; time something is added/subtracted to a2.  d0=the shift count used in
; bltcon0.

	clr.w	d0		Shift=0
	move.l	b1,a2
	add.l	#40*40,a2	a2=place of bob (40th line)
	clr.l	d1		direction = left
	move.l	#8,d2		count
wait	bsr	move		move it
	btst	#6,$bfe001	Wait for LMB
	bne.s	wait

; Clean up

	move.l	base,a2
	move.l	38(a2),cop1lch(a5)
	move.l	#40*256*3,d0
	move.l	b1,a1
	jmp	-210(a6)

move	cmp.b	#255,$dff006	Wait for vertical blanking
	bne.s	move
	tst.b	d1		Which direction?
	bne.s	back		if it =1, go left
	add.w	#speed1,d0	add the speed
	tst	d0		Do we need to update a2 aswell?
	bne.s	doblit1		nope, put bob in new place
	bsr	clearb		wipe the bob (otherwise a thin line is left)
	addq.l	#2,a2		add a word to place of bob
	dbra	d2,doblit1	decrease count and if not -1 put bob
	move.l	#9,d2		count=9
	moveq.b	#1,d1		direction=left

; Move left
back	sub.w	#speed1,d0	Take speed from shift value
	cmp.w	#speed2,d0	should a2 be updated?
	bne.s	doblit1		no, put bob
	subq.l	#2,a2		take 2 from place of bob
	dbra	d2,doblit1	decrease count and if not -1 put bob
	move.l	#9,d2		cout=9
	clr.l	d1		direction=right

; blits the bob in required place

doblit1	move.w	#%100111110000,d5	What goes in low 12 bits of bltcon0
	move.l	a2,a1		copy place of bob into a1 so it can be added to
doblit	moveq.l	#2,d7		3 bitplanes
	move.l	#bob,a0		A=bob plane
bwait	btst	#14,dmaconr(a5)	Wait for blitter
	bne.s	bwait
	move.l	a0,bltapth(a5)	A=bob
	move.l	a1,bltdpth(a5)	D=place on screen
	move.w	#-2,bltamod(a5)	Modulo of -2 for A
	move.w	#18,bltdmod(a5)	and 18 for D
	move.w	#$ffff,bltafwm(a5)
	move.w	#0,bltalwm(a5)	Last 16 bits before shifting=0
	move.l	d0,d6		shift value into d6
	or.w	d5,d6		or it with the low 12 bits needed for bltcon0
	move.w	d6,bltcon0(a5)	and put it in
	move.w	#0,bltcon1(a5)
	move.w	#%100000001011,bltsize(a5)	Bob size = 176x32
	add.l	#640,a0		Move source onto next plane
	add.l	#256*40,a1	Ditto destination
	dbra	d7,bwait	Do the other bitplanes
	rts

clearb	move.w	#%000100000000,d5	Wipe area of bob
	move.l	a2,a1		and do it as though you were doing a normal bob
	bra	doblit

	even
copper	dc.w	bplcon0,%11001000000000
	dc.w	bplcon1,0
	dc.w	bplcon2,0
	dc.w	bpl1mod,0
	dc.w	bpl2mod,0
	dc.w	diwstrt,$2981
	dc.w	diwstop,$29c1
	dc.w	ddfstrt,$38
	dc.w	ddfstop,$d0
	dc.w	bpl1ptl
b1l	dc.w	0,bpl1pth
b1h	dc.w	0,bpl2ptl
b2l	dc.w	0,bpl2pth
b2h	dc.w	0,bpl3ptl
b3l	dc.w	0,bpl3pth
b3h	dc.w	0
	dc.w	color00,0
	dc.w	color01,$070
	dc.w	color02,$050
	dc.w	color03,$030
	dc.w	color04,$db0
	dc.w	color05,$a70
	dc.w	color06,$600
	dc.w	$ffff,$fffe
b1	dc.l	0
b2	dc.l	0
b3	dc.l	0
base	dc.l	0
library	dc.b	'graphics.library',0,0

bob	incbin	source:bitmaps1/reflect_bob
