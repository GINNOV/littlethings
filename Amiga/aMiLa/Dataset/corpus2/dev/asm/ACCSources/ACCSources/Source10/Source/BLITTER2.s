** CODE    :BLITTER2
** AUTHOR  :HEARWIG
** COMMS BY HEARWIG

	SECTION	HEARWIG,CODE_C

	opt	c-
	include	source10:include/hardware.i

	lea	library,a1	Need I say more?
	clr.l	d0
	move.l	4,a6
	jsr	-408(a6)
	move.l	d0,base
reserve	move.l	#40*256*2,d0	Reserve memory (at last I can do it¹)
	move.l	#2,d1
	jsr	-198(a6)
	move.l	d0,b1		Set up the bitplane addresses for copper
	move.w	d0,bpl1
	swap	d0
	move.w	d0,bpl1h
	swap	d0
	add.l	#40*256,d0	
	move.l	d0,b2
	move.w	d0,bpl2
	swap	d0
	move.w	d0,bpl2h
	move.l	b1,a1		Clear the screen
	move.l	#10*256*2,d0
clear	move.l	#0,(a1)+
	dbra	d0,clear
	lea	$dff000,a5
	move.w	#$20,dmacon(a5)	Switch off sprites
	move.l	#list,cop1lch(a5)	Give new copper list
	move.w	#0,copjmp1(a5)	And strobe it
	bsr	Blitter		Now the new bit, see below
button	btst	#6,$bfe001	Wait for LMB
	bne	button
	move.w	#$8020,dmacon(a5)	Let those sprites come back
	move.l	base,a4
	move.l	38(a4),cop1lch(a5)	And clean up ready for exit
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
	dc.w	DDFSTRT,$3d
	dc.w	DDFSTOP,$d0
	dc.w	COLOR00,0
	dc.w	COLOR01,$ff0	Yellow
	dc.w	COLOR02,$f00	Red
	dc.w	COLOR03,$ff0	Yellow, so that of blits for shadowed writing does not show (change it if you don't know what I mean, it'll show you) overlap does not show
	dc.w	$ffff,$fffe	
Blitter				*See routine doblit first
	move.l	b1,d0		d0 should contain destination address. Get address of first bitplane	
	add.l	#$120,d0	and add some to it so it is somewhere other than top left corner (trying not to be too boring)
	move.w	#%100111110000,BLTCON0(a5)	No shift distance for A.  A and D are used
	bsr	doblit		call my routine
	move.l	b2,d0		Same offset but from 2nd plane
	add.l	#$120,d0
	move.w	#%110100111110000,BLTCON0(a5) 	Shift distance of 2 bits for A.  A and D are used (this gets shadow effect)
doblit		
	move.l	#myblit,BLTAPTh(a5)	This is the address of my bob, and it is put into Register A
	move.l	d0,BLTDPTh(a5)		When this routine is called, d0 should be the destination.  It is put into Register D (Destination)
	clr.w	BLTAMOD(a5)		Modulo for A=0 ; there are no unwanted bytes between each line of data
	move.w	#36,BLTDMOD(a5)		Modulo for D=0 ; there are 36 bytes more on each screen line to jump after each line is blitted so that the data stays in line (again, experiment with it if you don't understand why; eg. 35 and 37)
	move.w	#$ffff,BLTAFWM(a5)	No mask for first word - all bits in it should be displayed
	move.w	#$ffff,BLTALWM(a5)	No mask for last word either - same reason
	clr.w	BLTCON1(a5)		No extra info 
	move.w	#%10011000010,BLTSIZE(a5)	Get the blitter to do some hard work.  
waitb	btst	#14,$dff002	These two instructions test if blitter is busy - cannot use it until it isn't
	bne.s	waitb		This is at the end because before routine is called, a blitter register (BLTCON0) is called.  If blitter is active when a register, strange things happen
	rts
myblit	dc.b	%11111100,%00011111,%11000011,%11110000	
	dc.b	%11111110,%00011111,%11000111,%11111000
	dc.b	%11100111,%00001111,%10001110,%00011100
	dc.b	%11100111,%00000111,%00001110,%00011100
	dc.b	%11100011,%10000111,%00011100,%00000000
	dc.b	%11100011,%10000111,%00011100,%00000000
	dc.b	%11100011,%10000111,%00011100,%00000000
	dc.b	%11100111,%00000111,%00111000,%00000000
	dc.b	%11100111,%00000111,%00111000,%00000000
	dc.b	%11111110,%00000111,%00111000,%00000000
	dc.b	%11111000,%00000111,%00111000,%00000000
	dc.b	%11111100,%00000111,%00111000,%00000000
	dc.b	%11111100,%00000111,%00011100,%00000000
	dc.b	%11101110,%00000111,%00011100,%00000000
	dc.b	%11101110,%00000111,%00011100,%00000000
	dc.b	%11100111,%00000111,%00001110,%00011100
	dc.b	%11100111,%00001111,%10001110,%00011100
	dc.b	%11100011,%10011111,%11000111,%11111000
	dc.b	%11100011,%10011111,%11000011,%11110000
