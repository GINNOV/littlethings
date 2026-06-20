** AUTHOR: HEARWIG
* This progran displays a map made out of blocks.  At the moment there is
* only one type of block, but just add more if you like.  The map is laid
* out in bytes, each byte containing the number of the block which goes
* there.

* The blocks are 2 bytes long and 16 pixels high.  Therefore, the map is
* 20 (40/2) by 16 (256/16) and are 3 bitplanes.

* LAYOUT:
* map bit     1  2  3  4  5  .....
*            21 22 23 24 25  .....
*            41 42 43 44 45  .....

* The block number can be from 0 to (number of blocks designed-1).  This
* `map' or, as I prefer to call it, `block graphics' way of defining
* many screens or levels is very common, and ideal for the blitter.
* Eg. a platform/ladder game (a very simple one) might have screens made
* out of 3 types of ladder, 1 type of brick, 3 types of `killer blocks'
* and 2 trampolines (well, I did say simple).  If all the levels are made
* out of these blocks, it is possible to save tonnes of memory.
	opt	c-
	section	Blit,code_c
	include	ram:hardware.i	Just sets up copper list+3 bitplanes
	lea	library,a1
	clr.l	d0
	move.l	4,a6
	jsr	-408(a6)
	move.l	d0,base
reserve	move.l	#40*256*3,d0
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
	swap	d0
	add.l	#40*256,d0
	move.l	d0,b3
	move.w	d0,bpl3
	swap	d0
	move.w	d0,bpl3h
	move.l	b1,a1
	move.l	#20*256,d0
clear	move.l	#0,(a1)+
	dbra	d0,clear
	lea	$dff000,a5
	move.w	#$20,dmacon(a5)
	move.l	#list,COP1LCH(a5)
	move.w	#0,COPJMP1(a5)
	bsr	blitmap		blit the map
button	btst	#6,$bfe001
	bne	button
	move.l	base,a4
	move.l	38(a4),COP1LCH(a5)
	move.l	b1,a1
	move.l	#40*256*3,d0
	jsr	-210(a6)
	move.l	base,a1
	jmp	-414(a6)
	even
library	dc.b	'graphics.library',0,0
	even
b1	dc.l	0
b2	dc.l	0
b3	dc.l	0
base	dc.l	0
list	dc.w	BPL1PTL
bpl1	dc.w	0,BPL1PTH
bpl1h	dc.w	0,BPL2PTL
bpl2	dc.w	0,BPL2PTH
bpl2h	dc.w	0,BPL3PTL
bpl3	dc.w	0,BPL3PTH
bpl3h	dc.w	0
	dc.w	BPLCON0,%11001000000000
	dc.w	BPLCON1,0
	dc.w	BPLCON2,0
	dc.w	DIWSTRT,$2981
	dc.w	DIWSTOP,$29c1
	dc.w	DDFSTRT,$3d
	dc.w	DDFSTOP,$d0
	dc.w	COLOR00,0
	dc.w	COLOR01,$f00
	dc.w	COLOR02,$f0
	dc.w	COLOR03,$f
	dc.w	COLOR04,$ff0
	dc.w	COLOR05,$ff
	dc.w	COLOR06,$fff
	dc.w	COLOR07,$f0f
	dc.w	$ffff,$fffe
blitmap	lea	mapdata,a1	Address of the map data
	move.l	#15,d0		16 rows
	clr.l	addona		offset from start of bitplanes=0
blitlin	move.l	#19,d1		20 columns
blitone	clr.l	d2		clear d2 so no rubbish stays in other bytes of register
	move.b	(a1)+,d2	get block byte into d2 then point a1 to next block byte
	mulu	#96,d2		times d2 by 96 (each block takes up 32 bytes - 2*16)
	add.l	#bobdata,d2	add on the start of the block data
	move.l	b1,d3		move start of bitplane 1 into d3
	bsr	blitbit		and blit block
	move.l	b2,d3		ditto for bitplane 2
	bsr	blitbit
	move.l	b3,d3		And for bitplane 3
	bsr	blitbit
	addq.l	#2,addona	add on 2 to offset from start of bitplane so it points to where next block should be
	dbra	d1,blitone	finish of row
	add.l	#15*40,addona	then get offset from start of bitplane onto next line (jumps 15 lines)
	dbra	d0,blitlin	and continue until done
	rts			Bye !!
blitbit	btst	#14,DMACONR(a5)	wait for blitter to be ready
	bne	blitbit
	move.l	d2,BLTAPTH(a5)	move d2 (which is address of block to be blitted) into Reg A
	add.l	addona,d3	add on the offset from start of bitplane to start of bitplane (which is in d3) so that actual address is in d3
	move.l	d3,BLTDPTH(a5)	and put this address into Destination Register
	move.w	#38,BLTDMOD(a5)	38 bytes to skip on screen, block is only 2 bytes wide and screen is 40 bytes wide
	clr.w	BLTAMOD(a5)	no modulo for A though, because data follows without a gap
	clr.w	BLTCON1(a5)	clear control register 1
	move.w	#$ffff,BLTAFWM(a5)	no first word mask, because all bits should be blitted
	move.w	#$ffff,BLTALWM(a5)	no last word mask, for same reason
	move.w	#%100111110000,BLTCON0(a5)	Use Reg A and Reg D (Destination) only
	move.w	#%10000000001,BLTSIZE(a5)	Size of bob=1 word x 16 pixels
	add.l	#32,d2		Now that blitter is running, add 32 to d2 so that d2 points to block data for next bitplane
	rts			Job is done
	even
addona	dc.l	0		offset from start of screen
mapdata	ds.l	320		320 nul bytes 'cos only got 1 block.  If you designed another (or more), you could fill this area with different bytes for a more interesting map

* Block data.  Each block is 1 word long and 16 pixels high.  Do the 16
* words for blitplane 1 first, then the 16 words for bitplane 2, then the
* 16 for bitplane 3.  After the 48 (16x3) words, the next block can begin

bobdata	dc.w	$c003,$e006,$f00c,$f818,$fc30,$fe60,$fcc0,$f980,$ff00
	dc.w	$fe00,$fc00,$f800,$f000,$e000,$c000,$8000
	dc.w	$fff0,$ffe0,$ffc0,$ff80,$ff00,$fe00,$fc00,$f800,$f000
	dc.w	$e000,$c000,$8000,0,0,0,0
	dc.w	$ffff,$fffe,$7ffc,$3ff8,$1ff0,$0fe0,$07c0,$0380,0
	dc.w	0,0,0,0,0,0,0
