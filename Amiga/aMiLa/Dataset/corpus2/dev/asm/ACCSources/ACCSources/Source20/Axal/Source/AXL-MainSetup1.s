
* DATE:	
* TIME:	
* NAME:	
* CODE:	
* NOTE:	

	opt	c-,ow-,o+

	incdir	source:include/
	include	hardware.i

	section	Chipmem,data_c

	movem.l	d0-d7/a0-a6,-(sp)	save all registers
	move.l	sp,stack		save the stack address

	move.l	$4.w,a6			execbase
	lea	gfxname(pc),a1		lib to open
	moveq.l	#0,d0			any version
	jsr	-552(a6)		open lib
	move.l	d0,gfxbase		save base
	beq	gfxerror1		branch if error

*---------------------------------------

	move.l	$4.w,a6			execbase
	jsr	-132(a6)		forbid multi-tasking

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

	lea	$64.w,a0		point to interrupts
	lea	sysintlev(pc),a1	address holders
	moveq	#6-1,d0			save 6 levels
kill_loop1
	move.l	(a0)+,(a1)+		save address
	dbra	d0,kill_loop1		do all 6
waitmsb
	btst	#$0,vposr(a5)		test msb of vpos
	bne.s	waitmsb			branch if not 0
wait310
	cmpi.b	#$55,vhposr(a5)		wait for line 310
	bne.s	wait310			branch until reached
	move.w	#$20,beamcon0(a5)	set update to 50hz (pal)
	
	move.l	$4.w,a6			execbase
	move.l	gfxbase(pc),a1		place graphics in a1
	move.l	$26(a1),syscopper	save system copper
	jsr	-414(a6)		close gfx lib

	lea	$64.w,a0		point to interrupts
	move.l	#death_init,d0		rte command
	moveq	#6-1,d1			do all 6
.rteset_loop1
	move.l	d0,(a0)+		kill interrupt
	dbra	d1,.rteset_loop1	do all 6

	move.w	#$7fff,intena(a5)	clear enable
	move.w	#$7fff,intreq(a5)	clear request
	move.w	#$7fff,dmacon(a5)	clear dma

	move.l	#axalcopper,cop1lch(a5)	insert my copper
	move.w	copjmp1(a5),d0		strode it

*---------------------------------------

	bsr	setupscreens		do the screen stuff
	bsr	setupcopper
	bsr	setupinterrupts		do interrups stuff
	move.w	#$83f0,dmacon(a5)	dma needed
	move.w	#$c010,intena(a5)	copper set

*---------------------------------------

vertloop
	cmpi.b	#$ff,vhposr(a5)		vertical blank?
	bne.s	vertloop
	btst	#6,$bfe001		left mouse button
	bne.s	vertloop

*---------------------------------------

quit_program
	move.l	syscopper(pc),cop1lch(a5)	restore system copper
	move.w	copjmp1(a5),d0		strode it

	lea	$64.w,a0		point to interrupts
	lea	sysintlev(pc),a1	address holders
	moveq	#6-1,d0			save 6 levels
.restore_loop1
	move.l	(a1)+,(a0)+		restore address
	dbra	d0,.restore_loop1	do all 6

	move.w	sysdma(pc),dmacon(a5)	restore system dma
	move.w	systen(pc),intena(a5)	restore system interrup enable
	move.w	systrq(pc),intreq(a5)	restore system interrup request

	move.l	$4.w,a6			execbase
	jsr	-138(a6)		enable multi-tasking

*---------------------------------------

gfxerror1
	move.l	stack,sp		restore stack
	movem.l	(sp)+,d0-d7/a0-a6	restore registers
	rts

*---------------------------------------

setupinterrupts
	move.l	#my_interrupt,$6c.w	insert my commands
	rts
	and.w	#$10,intreqr(a5)	copper interrupt!
	beq.s	death_init		branch if not
my_interrupt
	movem.l	d0-d7/a0-a6,-(sp)	save all registers
	movem.l	(sp)+,d0-d7/a0-a6	restore registers
	move.w	#$70,intreq(a5)		clear vert/copper/blitter
death_init
	rte

*---------------------------------------

setupscreens
	rts
scrcopsave
	move.w	d0,6(a0)		save low word
	swap	d0			swap words
	move.w	d0,2(a0)		save high word
	swap	d0			swap words
	addq.l	#8,a0			next plane pointers
	add.l	d1,d0			next plane
	dbra	d2,scrcopsave		decrement et branch
	rts

*---------------------------------------

setupcopper
	rts

*---------------------------------------

gfxname
	dc.b	"graphics.library",0
	even
gfxbase		dc.l	0
stack		dc.l	0
syscopper	dc.l	0
sysintlev	ds.l	6
sysdma		dc.w	0
systen		dc.w	0
systrq		dc.w	0

*---------------------------------------

axalcopper
	dc.w	intreq,$8010
	dc.w	diwstrt,$2881,diwstop,$2cc1
	dc.w	ddfstrt,$0038,ddfstop,$00d0
	dc.w	bplcon1,$0000,bplcon2,$0000
	dc.w	bpl1mod,$0000,bpl2mod,$0000
	dc.w	beamcon0,$0020,bplcon0,$200
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
	dc.w	bpl5pth,0,bpl5ptl,0,bpl6pth,0,bpl6ptl,0
	dc.w	$ffff,$fffe


