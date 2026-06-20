
* DATE:	20 June 1992
* TIME:	18:15:33
* NAME:	Blit map on to screen test
* CODE:	Axal
* NOTE:	We love ABBA!

* This is just an example of blitting a map onto the screen
* from a map file and using a block file.  Both the map and
* block files were made using my mapper.  I hope it will be
* finished soon and as so as it is I'll seen the source for
* it in!

*---------------------------------------
	opt	c-,ow+,o+,D+
*---------------------------------------
	incdir	source:include/
	include	hardware.i
	include	axal_lib.i
*---------------------------------------
wk1cop	=	$26
wk2cop	=	$32
bf_data	=	76
bf_palette	=	12
screen_width	=	320
*---------------------------------------


	section	Chipmem,data_c

start	movem.l	d0-d7/a0-a6,-(sp)	save all registers
	move.l	sp,stack		save the stack address

	opengfx				open gfx library
	move.l	d0,a1			copy base
	beq	gfxerror1		branch if error

	move.l	wk1cop(a1),syscop1	save copper list 1
	move.l	wk2cop(a1),syscop2	save copper list 2
	callexe	closelibrary		close lib
*---------------------------------------
	callexe	forbid			forbid multi-tasking

	lea	$dff000,a5		pointer to custom chips
	move.w	dmaconr(a5),d0		get system dma
	or.w	#$8000,d0		set enable
	move.w	d0,sysdma		save it
	move.w	intenar(a5),d0		get system interrup enable
	or.w	#$c000,d0		set enable bit
	move.w	d0,systen		save it
	move.w	intreqr(a5),d0		get system interrup request
	or.w	#$8000,d0		set enable
	move.w	d0,systrq		save it
.waitmsb
	btst	#$0,vposr(a5)		test msb of vpos
	bne.s	.waitmsb			branch if not 0
.wait310
	cmpi.b	#$55,vhposr(a5)		wait for line 310
	bne.s	.wait310		branch until reached
	move.w	#$20,beamcon0(a5)	set update to 50hz (pal)

	move.w	#$7fff,d0		set to clear
	move.w	d0,intena(a5)		clear enable
	move.w	d0,intreq(a5)		clear request
	move.w	d0,dmacon(a5)		clear dma

	lea	axalcopper(pc),a0	point to my copper
	move.l	a0,cop1lch(a5)		show normal copper
	clr.w	copjmp1(a5)		strode it
*---------------------------------------
	bsr.s	setupscreens		do the screen stuff
	bsr	setupcopper
	bsr	calculate_screen	get ddfstart etc..
	move.w	#$83e0,dmacon(a5)	set dma
*---------------------------------------
	bsr	rt_draw_map
vertloop
	cmpi.b	#$ff,vhposr(a5)		vertical blank
	bne.s	vertloop
	btst	#6,$bfe001		left mouse button
	bne.s	vertloop
*---------------------------------------
quit_program
	move.w	#$7fff,d0		set to clear
	move.w	d0,intena(a5)		clear enable
	move.w	d0,intreq(a5)		clear request
	move.w	d0,dmacon(a5)		clear dma

	move.l	syscop1(pc),cop1lch(a5)	restore system copper 1
	move.l	syscop2(pc),cop2lch(a5)	restore system copper 2
	clr.w	copjmp1(a5)		strode it

	move.w	sysdma(pc),dmacon(a5)	restore system dma
	move.w	systen(pc),intena(a5)	restore system interrup enable
	move.w	systrq(pc),intreq(a5)	restore system interrup request

	callexe	enable			enable multi-tasking
*---------------------------------------
gfxerror1
	move.l	stack,sp		restore stack
	movem.l	(sp)+,d0-d7/a0-a6	restore registers
	moveq	#0,d0			keep cli happy
	rts
*---------------------------------------
setupscreens
	lea	copper_planes(pc),a0
	move.l	#screen,d0
	moveq	#40,d1
	moveq	#4-1,d2
.copsave
	move.w	d0,6(a0)		save low word
	swap	d0			swap words
	move.w	d0,2(a0)		save high word
	swap	d0			swap words
	addq.l	#8,a0			next plane pointers
	add.l	d1,d0			next plane
	dbra	d2,.copsave		decrement et branch
	rts
*---------------------------------------
setupcopper
	lea	blocks(pc),a0		point to blocks
	lea	bf_palette(a0),a0	point to colours
	lea	copper_colours(pc),a1	copper list
	moveq	#32-1,d0		many to copy
.loop0
	move.w	(a0)+,2(a1)		copy colour
	addq.l	#4,a1			next register
	dbra	d0,.loop0
	rts
*---------------------------------------
* RIPPED FROM MY MAP CREATOR - BY AXAL!

* I MADE THIS LITTLE ROUTINE UP BECAUSE I COULDN'T
* BE BOTHERED TO GET A CALCULATOR OUT AND WORK IT
* OUT ON PAPER.  ANYWAY WHEN I FIRST STARTED PROGRAMMING
* THE AMIGA, THIS PART BUGGERED ME UP!

* CALCULATE DIWSTRT & STOP

calculate_screen
	lea	axalcopper,a0		point to screen info

	move.w	#384/16,d1		words per line
	sub.w	#screen_width/16,d1	subtract screen width from width
	mulu.w	#8,d1			multiply by bytes
	add.w	#$61,d1			add on screen starter
	move.w	d1,d6			copy start
	move.b	d1,3(a0)		save start position

	add.w	#screen_width,d1	add on width
	move.b	d1,7(a0)		save stop position

* CALCULATE DDFSTRT & STOP

	lsr.w	#1,d6			half it please
	subq	#8,d6			low-res only 
	and.w	#$ff,d6			first byte only
	move.w	d6,10(a0)		place in ddfstrt

	move.w	#screen_width/16,d0	number of blocks per line
	subq	#1,d0			sub 1 for calculation
	mulu.w	#8,d0			multiply for low-res
	add.w	d6,d0			add on ddfstrt
	move.w	d0,14(a0)		place in ddfstop
	rts
*---------------------------------------
rt_draw_map

* THIS WAS RIPPED FROM MY MAPPER AND CHANGED A BIT

	move.w	width(pc),d4		get map width

	lea	mapdata(pc),a0		point to map
	lea	blocks(pc),a1		point to blocks
	lea	screen,a2		point to screen
	lea	bf_data(a1),a1		point to block data

	move.w	height(pc),d7		get height of map
	subq	#1,d7			sub 1 for right cal
	moveq	#20-1,d2		blocks per line
.loop0
	move.w	d2,d6			blocks per line
	pea	(a2)			save screen position
	pea	(a0)			save map position
.loop1
	moveq	#0,d0			clear it
	move.b	(a0)+,d0		get new map number
	mulu.w	#128,d0			block num by block size = offset

	lea	(a1,d0.w),a3		block data address

	bsr.s	rt_map_blitblock	blit the block on screen

	addq.l	#2,a2			next block on screen
	dbra	d6,.loop1		do line

	move.l	(sp)+,a0		get map position
	move.l	(sp)+,a2		get screen address
	add.l	d4,a0			next map line
	lea	(40*4)*16(a2),a2	next screen position

	dbra	d7,.loop0		d0 all
	rts
*---------------------------------------
rt_map_blitblock
	
* A3 - SOURCE   A2 - DESTINATION

	btst	#14,dmaconr(a5)
.bwait1
	btst	#14,dmaconr(a5)		blitter ready?
	bne.s	.bwait1			wait until ready

	move.l	#$09f00000,bltcon0(a5)	normal blitter mode
	move.l	#-1,bltafwm(a5)		no masks
	move.w	#0,bltamod(a5)		no modulo for blocks
	move.w	#38,bltdmod(a5)		set screen modulo
	move.l	a3,bltapth(a5)		set source
	move.l	a2,bltdpth(a5)		set destination
	move.w	#(16*4*64)+1,bltsize(a5) start blitter
	rts
*---------------------------------------
gfxname		dc.b	"graphics.library",0
		even
gfxbase		ds.l	1
stack		ds.l	1
syscop1		ds.l	1
syscop2		ds.l	1
sysintlev	ds.l	6
sysdma		ds.w	1
systen		ds.w	1
systrq		ds.w	1
*---------------------------------------
axalcopper
	dc.w	diwstrt,$4c81,diwstop,$2cc1
	dc.w	ddfstrt,$0038,ddfstop,$00d0
	dc.w	bplcon1,$0000,bplcon2,$0000
	dc.w	bpl1mod,120,bpl2mod,120
	dc.w	beamcon0,$0020,bplcon0,$4200
	dc.w	intreq,$8010
copper_sprites
	dc.w	spr0pth,0,spr0ptl,0,spr1pth,0,spr1ptl,0
	dc.w	spr2pth,0,spr2ptl,0,spr3pth,0,spr3ptl,0
	dc.w	spr4pth,0,spr4ptl,0,spr5pth,0,spr5ptl,0
	dc.w	spr6pth,0,spr6ptl,0,spr7pth,0,spr7ptl,0
copper_colours
	dc.w	$180,$000,$182,$000,$184,$000,$186,$000
	dc.w	$188,$000,$18a,$000,$18c,$000,$18e,$000
	dc.w	$190,$000,$192,$000,$194,$000,$196,$000
	dc.w	$198,$000,$19a,$000,$19c,$000,$19e,$000
	dc.w	$1a0,$000,$1a2,$000,$1a4,$000,$1a6,$000
	dc.w	$1a8,$000,$1aa,$000,$1ac,$000,$1ae,$000
	dc.w	$1b0,$000,$1b2,$000,$1b4,$000,$1b6,$000
	dc.w	$1b8,$000,$1ba,$000,$1bc,$000,$1be,$000
copper_planes
	dc.w	bpl1pth,0,bpl1ptl,0,bpl2pth,0,bpl2ptl,0
	dc.w	bpl3pth,0,bpl3ptl,0,bpl4pth,0,bpl4ptl,0
	dc.w	$ffff,$fffe
*---------------------------------------
	incdir	source:axal/

width	=	*+10
height	=	width+2
mapdata	=	height+8
	incbin	data/level0.map
	even
blocks
	incbin	data/level0.blk
	even
screen	ds.b	40*256*4
