
* DATE:	3 June 1992
* TIME:	22:32
* NAME:	Multi-Sprite
* CODE:	Axal (Hey, thats me!)
* NOTE:	Here it is!  The latest copper trick on the Amiga.
*	I don't know what other people call it so I give
*	it the name multi-sprite.  Heres a small description
*	of what it is and how it's done.
*	You can enter sprite data to be displayed on screen
*	straight into custom chip register SPRxDATA and SPRxDATB.
*	without the need to turn on the dma.  So what we do
*	at each screen line in the copper list is enter the
*	sprite data we want to see on that line and set the
*	position we want to see it at.  We set the horizontral
*	20 times (20 * 16 = 320) and the sprites are displayed
*	tens times each.  The reason for this is that since
*	you are controlling sprite input, the computer thinks
*	it's already displayed it and will display it again.
*	Alas, there is one draw back.  You need to enable all
*	6 bitplanes.  Start at line $xx25 and subtract 4 for
*	any other copper commands you put before it.  Anyway
*	take a look at the source to see how it's done.  

*	All data you see on screen in this source  are 2 sprites!
*	Sorry about the graphics being so crap but it's only
*	an example.

*---------------------------------------
	opt	c-,ow+,o-,D+
*---------------------------------------
	incdir	source:include/
	include	hardware.i
	include	axal_lib.i
*---------------------------------------
wk1cop	=	$26
wk2cop	=	$32
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

	lea	$64.w,a0		point to interrupts
	lea	sysintlev(pc),a1	address holders
	moveq	#6-1,d0			save 6 levels
.kill_loop1
	move.l	(a0)+,(a1)+		save address
	dbra	d0,.kill_loop1		do all 6
.waitmsb
	btst	#$0,vposr(a5)		test msb of vpos
	bne.s	.waitmsb			branch if not 0
.wait310
	cmpi.b	#$55,vhposr(a5)		wait for line 310
	bne.s	.wait310		branch until reached
	move.w	#$20,beamcon0(a5)	set update to 50hz (pal)
	
	lea	$64.w,a0		point to interrupts
	move.l	#death_init,d0		rte command
	moveq	#6-1,d1			do all 6
.rteset_loop1
	move.l	d0,(a0)+		kill interrupt
	dbra	d1,.rteset_loop1	do all 6

	move.w	#$7fff,d0		set to clear
	move.w	d0,intena(a5)		clear enable
	move.w	d0,intreq(a5)		clear request
	move.w	d0,dmacon(a5)		clear dma

	lea	axalcopper(pc),a0	point to my copper
	move.l	a0,d1			copy pointer
	move.l	d1,cop1lch(a5)		show normal copper
	clr.w	copjmp1(a5)		strode it
*---------------------------------------
	bsr	setupscreens		do the screen stuff
	bsr	setupcopper
	bsr	calculate_screen	get ddfstart etc..
	bsr	setupinterrupts		do interrups stuff + dma
	move.w	#$83e0,dmacon(a5)	set dma
	move.w	#$c010,intena(a5)	copper set
*---------------------------------------
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

	lea	$64.w,a0		point to interrupts
	lea	sysintlev(pc),a1	address holders
	moveq	#6-1,d0			save 6 levels
.restore_loop1
	move.l	(a1)+,(a0)+		restore address
	dbra	d0,.restore_loop1	do all 6

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
setupinterrupts
	move.l	#lev3_interrupt,$6c.w	insert my commands
	rts
lev3_interrupt
	movem.l	d0-d7/a0-a6,-(sp)	save all registers
	lea	$dff000,a5		custom chips
	move.w	intreqr(a5),d0		get interrupt requests
	and.w	#$10,d0			check for copper
	beq.s	.no0			branch if not
	bsr	update_sprites
.no0
	movem.l	(sp)+,d0-d7/a0-a6	restore registers
	move.w	#$70,intreq(a5)		clear vert/copper/blitter
death_init
	rte
*---------------------------------------
setupscreens
	lea	copper_planes(pc),a0
	move.l	#screen,d0
	moveq	#0,d1
	moveq	#6-1,d2
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
	lea	hillspr_copper(pc),a0	where to save
	lea	hillsprite1(pc),a1	sprite 1
	lea	hillsprite2(pc),a2	sprite 2
	move.l	#$01ba0fff,d1		first colour
	move.l	#$01bc0aaa,d2		second colour
	move.l	#$01be0753,d3		third colour
	move.l	#$5019fffe,d0		start line
	moveq	#14-1,d7		number of lines
	bsr	.savetocopper		store in copper list

	lea	wallsprite1(pc),a1	sprite 1
	lea	wallsprite2(pc),a2	sprite 2
	move.w	#$0334,d1		first colour
	move.w	#$0679,d2		second colour
	move.w	#$089b,d3		third colour
	moveq	#21-1,d7		number of lines
	bsr	.savetocopper		store in copper list

	lea	grass_sprite1(pc),a1	sprite 1
	lea	grass_sprite2(pc),a2	sprite 2
	move.w	#$334,d1		first colour
	move.w	#$050,d2		second colour
	move.w	#$0a0,d3		third colour

	moveq	#6-1,d7			number of lines
	bsr	.savetocopper		store in copper list

	move.w	#$643,d1		first colour
	moveq	#10-1,d7		number of lines
	bsr	.savetocopper		store in copper list

	moveq	#4-1,d4			many to save
	lea	sea_colours(pc),a3	colour list
.loop0
	lea	seasprite1(pc),a1	sprite 1
	lea	seasprite2(pc),a2	sprite 2
	move.w	(a3)+,d1		first colour
	move.w	(a3)+,d2		first colour
	move.w	(a3)+,d3		first colour
	moveq	#20-1,d7		number of lines
	bsr	.savetocopper		store in copper list
	dbra	d4,.loop0		do all

	move.l	d0,(a0)+		next line
	move.w	#spr6ctl,(a0)+		spr6ctl
	move.w	#0,(a0)+		 + stopper
	move.w	#spr7ctl,(a0)+		spr7ctl
	move.w	#0,(a0)+		 + stopper
	rts
.savetocopper
	move.l	d0,(a0)+		line number
	move.l	d1,(a0)+		first colour
	move.l	d2,(a0)+		second colour
	move.l	d3,(a0)+		third colour
	move.w	#spr6data,(a0)+		custom chip
	move.w	(a1)+,(a0)+		1st plane data
	move.w	#spr6datb,(a0)+		custom chip
	move.w	(a1)+,(a0)+		2nd plane data
	move.w	#spr7data,(a0)+		custom chip
	move.w	(a2)+,(a0)+		1st plane data
	move.w	#spr7datb,(a0)+		custom chip
	move.w	(a2)+,(a0)+		2nd plane data
	moveq	#$40,d5			where to start
	moveq	#(20/2)-1,d6		number of times to do
.loop2
	move.w	#spr6pos,(a0)+		spr6pos
	move.w	d5,(a0)+		start position
	addq	#8,d5			next position
	move.w	#spr7pos,(a0)+		spr7pos
	move.w	d5,(a0)+		start position
	addq	#8,d5			next position
	dbra	d6,.loop2		do all
	add.l	#$01000000,d0		add on to next line
	bcc.s	.ok0			branch if not carried
	move.l	#$ffe1fffe,(a0)+	enable pal
.ok0
	dbra	d7,.savetocopper	do all
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
update_sprites
	lea	wallspr_copper(pc),a0	copper list
	moveq	#21-1,d7		many lines
	moveq	#1,d2			speed to scroll
	bsr	.scroll_em		move 'em

	lea	grassspr_copper(pc),a0	copper list
	moveq	#16-1,d7		many lines
	moveq	#2,d2			speed to scroll
	bsr	.scroll_em		move 'em

	lea	seaspr_copper(pc),a0	copper list
	moveq	#4-1,d6			many to do
	moveq	#3,d2			speed to scroll
.loop0
	moveq	#20-1,d7		many lines
	bsr	.scroll_em		move 'em
	addq	#1,d2			next speed
	dbra	d6,.loop0
	rts
.scroll_em
	move.w	6+12(a0),d0		get spr6data
	move.w	10+12(a0),d1		get spr6datb
	swap	d0
	swap	d1
	move.w	14+12(a0),d0		get spr7data
	move.w	18+12(a0),d1		get spr7datb

	rol.l	d2,d0			rotate x bits
	rol.l	d2,d1			rotate x bits

	move.w	d0,14+12(a0)		save spr7data
	move.w	d1,18+12(a0)		save spr7datb
	swap	d0
	swap	d1
	move.w	d0,6+12(a0)		save spr6data
	move.w	d1,10+12(a0)		save spr6data
	lea	56*2(a0),a0		next line
	cmp.l	#$ffe1fffe,(a0)		are we at pal
	bne.s	.ok0			branch if not
	lea	4(a0),a0		skip it please
.ok0
	dbra	d7,.scroll_em		do x lines
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
	dc.w	diwstrt,$2c81,diwstop,$2cc1
	dc.w	ddfstrt,$0038,ddfstop,$00d0
	dc.w	bplcon1,$0000,bplcon2,$0000
	dc.w	bpl1mod,$0000,bpl2mod,$0000
	dc.w	beamcon0,$0020,bplcon0,$6200
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
	dc.w	bpl5pth,0,bpl5ptl,0,bpl6pth,0,bpl6ptl,0

* ONE OF THE COPPER LINES LOOK LIKE THIS
*	dc.w	$3019,$fffe,color29,$00,color30,$00,color31,$00
*	dc.w	spr6data,$0,spr6datb,$0,spr7data,$0,spr7datb,$0
*	dc.w	spr6pos,$40,spr7pos,$48,spr6pos,$50,spr7pos,$58
*	dc.w	spr6pos,$60,spr7pos,$68,spr6pos,$70,spr7pos,$78
*	dc.w	spr6pos,$80,spr7pos,$88,spr6pos,$90,spr7pos,$98
*	dc.w	spr6pos,$a0,spr7pos,$a8,spr6pos,$b0,spr7pos,$b8
*	dc.w	spr6pos,$c0,spr7pos,$c8,spr6pos,$d0,spr7pos,$d8

hillspr_copper
	ds.w	56*14
wallspr_copper
	ds.w	56*21		words per line X lines down
grassspr_copper
	ds.w	56*16
seaspr_copper
	ds.w	56*(20*4)
*	ds.w	2		for pal
	ds.w	6		for stopper
	dc.w	$ffff,$fffe
*---------------------------------------
hillsprite1				* 14 lines
	dc.w	$0000,$0000,$0001,$0000,$0003,$0000,$0002,$0001
	dc.w	$0007,$0000,$001c,$0003,$803e,$0001,$c079,$0006
	dc.w	$c07f,$0048,$e06f,$0096,$61ed,$9013,$db9f,$72ed
	dc.w	$ffff,$cfbf,$ffff,$ffff
hillsprite2
	dc.w	$f000,$0000,$b800,$4000,$bc00,$4000,$ec00,$1200
	dc.w	$2b00,$d400,$e780,$1800,$9ac1,$6500,$b6e7,$4910
	dc.w	$fff6,$2009,$7eaf,$a150,$dfff,$6cab,$ffff,$dbee
	dc.w	$ffff,$ff3f,$ffff,$feff
wallsprite1				* 21 lines
	dc.w	$ffff,$0000,$b484,$cbfb,$eaf7,$ddf9,$ef4e,$dcf1
	dc.w	$6a7d,$9d86,$5596,$abef,$abde,$77ef,$6627,$fbd8
	dc.w	$74f4,$fb1b,$9bba,$64e7,$e4eb,$1bf7,$4d9d,$bbe3
	dc.w	$7462,$bb9d,$5b8b,$bc7c,$5d3e,$beff,$ed7c,$1eff
	dc.w	$b58f,$4e70,$1a70,$e58f,$f7a7,$f9df,$66af,$f9df
	dc.w	$ffff,$0000
wallsprite2
	dc.w	$ffff,$0000,$2187,$de78,$755a,$8fbd,$c8fe,$371d
	dc.w	$3726,$f9d9,$f5b5,$7bcb,$99df,$77e3,$d657,$29e8
	dc.w	$2995,$de6b,$acfa,$df0d,$59db,$be3c,$6f22,$90dd
	dc.w	$d4bd,$2bcb,$b5ad,$7bd3,$95aa,$7bdd,$e733,$79fc
	dc.w	$aada,$753d,$452f,$bed8,$3dad,$c7db,$92a9,$efd7
	dc.w	$ffff,$0000
grass_sprite1				* 16 lines
	dc.w	$ffdf,$0020,$fd8f,$0270,$f927,$06f8,$bb26,$c6f9
	dc.w	$3224,$cffb,$0125,$fffb,$c811,$ffff,$4915,$ffff
	dc.w	$2915,$ffff,$0414,$ffff,$0104,$ffff,$a9c1,$573f
	dc.w	$9ddb,$5234,$de6d,$711a,$bdbf,$0040,$ffff,$0000
grass_sprite2
	dc.w	$ffff,$0000,$fdbf,$0240,$ed9f,$1260,$4cbf,$b360
	dc.w	$4a56,$ffe9,$2b54,$ffff,$2b16,$ffff,$8391,$ffff
	dc.w	$1053,$ffff,$8150,$ffff,$4009,$fff6,$cc51,$f7ee
	dc.w	$7ca9,$837e,$79c7,$8238,$bddf,$0220,$ffff,$0000
seasprite1			* 20 lines
	dc.w	$ffff,$ffff,$ffff,$9006,$c803,$ffff,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$071d,$038e,$ffff,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$8870,$c438,$ffff,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$7c2e,$3e17,$ffff,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$03e8,$01f4,$ffff,$ffff,$ffff
seasprite2
	dc.w	$ffff,$ffff,$ffff,$8a03,$4501,$ffff,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$e00a,$f005,$ffff,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$0e0d,$0706,$ffff,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$00c4,$0062,$ffff,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$078a,$03c5,$ffff,$ffff,$ffff
sea_colours
	dc.w	$0cc,$06f,$03f,$0bb,$05e,$02e
	dc.w	$0aa,$04d,$01d,$099,$03c,$00c
*---------------------------------------
screen	ds.b	40*256
