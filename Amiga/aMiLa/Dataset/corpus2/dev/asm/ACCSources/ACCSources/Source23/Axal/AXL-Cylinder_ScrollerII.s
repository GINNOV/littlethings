
* DATE:	17/02/92
* TIME:	11:17
* NAME:	CYLINDER SCROLLER
* CODE:	AXAL
* NOTE:	A TRICK USING SCREEN MODULOS


	opt	c-,ow+,o+

	incdir	source:include/
	include	hardware.i
	include	axal_lib.i
	incdir	source:axal/

*---------------------------------------
wk1cop	=	$26
wk2cop	=	$32
cy_width	=	320	; 320 pixels across
cy_height	=	90	; 80 pixels deep
ft_height	=	8	; height of cylinder font
ft_char		=	40	; number of characters per line

	opt	c-,ow-,o+

*---------------------------------------

	section	Chipmem,code_c

	movem.l	d0-d7/a0-a6,-(sp)	save all registers
	move.l	sp,stack		save the stack address

	opengfx				open gfx library
	move.l	d0,a1			copy base
	beq	gfxerror1		branch if error

	move.l	wk1cop(a1),syscop1	save copper list 1
	move.l	wk2cop(a1),syscop2	save copper list 2
	callexe	closelibrary		close lib
	bsr	mt_init

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
kill_loop1
	move.l	(a0)+,(a1)+		save address
	dbra	d0,kill_loop1		do all 6
	move.w	d0,d2			copy $ffff
waitmsb
	btst	#$0,vposr(a5)		test msb of vpos
	bne.s	waitmsb			branch if not 0
wait310
	cmpi.b	#$55,vhposr(a5)		wait for line 310
	bne.s	wait310			branch until reached
	move.w	#$20,beamcon0(a5)	set update to 50hz (pal)
	
	lea	$64.w,a0		point to interrupts
	move.l	#death_init,d0		rte command
	moveq	#6-1,d1			do all 6
rteset_loop1
	move.l	d0,(a0)+		kill interrupt
	dbra	d1,rteset_loop1		do all 6

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
	bsr	setupinterrupts		do interrups stuff + dma

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

	callexe	enable			enable multi-tasking
	bsr	mt_end
*---------------------------------------

gfxerror1
	move.l	stack,sp		restore stack
	movem.l	(sp)+,d0-d7/a0-a6	restore registers
	moveq	#0,d0			keep cli happy
	rts

*---------------------------------------

setupinterrupts
	move.l	#lev3_interrupt,$6c.w	insert my commands
	move.w	#$83e0,dmacon(a5)	set dma
	move.w	#$c010,intena(a5)	copper set
	rts
lev3_interrupt
	and.w	#$10,intreqr(a5)	check if copper
	beq.s	.notready		quit if not
	movem.l	d0-d7/a0-a6,-(sp)	save all registers
	bsr	cylinder_scroller
	bsr	fader_scroller
	bsr	fader_colours
	move.l	a5,-(sp)
	bsr	mt_music
	move.l	(sp)+,a5
	movem.l	(sp)+,d0-d7/a0-a6	restore registers
.notready
	move.w	#$70,intreq(a5)		clear vert/copper/blitter
death_init
	rte

*---------------------------------------

setupscreens
	lea	cy_copper_planes(pc),a0	screen in copper
	move.l	#cylinder_screen,d0	screen to save
	moveq	#1-1,d2			1 plane
	bsr	.scrcopsave		save it in copper

	lea	fd_planes(pc),a0	screen in copper
	move.l	#fd_screen1,d0		screen to save
	move.l	#(42*18),d1		next plane
	moveq	#2-1,d2			no. planes
	bsr	.scrcopsave		save it
	rts
.scrcopsave
	move.w	d0,6(a0)		save low word
	swap	d0			swap words
	move.w	d0,2(a0)		save high word
	swap	d0			swap words
	addq.l	#8,a0			next plane pointers
	add.l	d1,d0			next plane
	dbra	d2,.scrcopsave		decrement et branch
	rts

*---------------------------------------

setupcopper
	rts

*---------------------------------------
cylinder_scroller
	btst	#10,potgor(a5)		test right button
	beq.s	.quit			quit if done
	bsr	cy_move_screen_up	shift screen
	tst.b	cy_delay2		are we ready
	beq.s	cy_delayup		is zero print new line
	subq.b	#1,cy_delay2		sub one and quit
.quit
	rts
cy_delayup
	moveq	#0,d6			clear d6
	move.w	#40-1,d7		characters per line
	move.l	cy_textpos,d5		get position of text
	lea	cy_text(pc),a4		point to ascii text
.loop1
	moveq	#0,d0			clear d0
	move.b	(a4,d5),d0		get next char
	bgt.s	.findchar		branch if not 0
	clr.l	cy_textpos		clear text position
	bra.s	cy_delayup
.findchar
	sub.b	#$20,d0			start from space
	mulu.w	#8,d0			get number of bytes
	lea	cylinder_font(pc),a0	point to font
	add.l	d0,a0			add on char position
	
	lea	cylinder_screen+(40*82)(pc),a1	point to screen
	add.l	d6,a1			add on vertical position
	moveq	#8-1,d0			many lines to do
.loop3
	move.b	(a0)+,(a1)		copy char to screen
	add.l	#40,a1			next line of screen
	dbra	d0,.loop3		do 8 lines

	addq.l	#1,d5			add 1 to text position
	addq.l	#1,d6			add 1 to screen counter
	dbra	d7,.loop1		do all 40 chars

	move.b	#8,cy_delay2		reset delay
	move.l	d5,cy_textpos		save text position
	rts
*---------------------------------------
cy_move_screen_up
	lea	cylinder_screen(pc),a0	point to destination
	lea	40(a0),a1		get source address
.btest1
	btst	#14,dmaconr(a5)		test blitter ready
	bne.s	.btest1

	move.l	a1,bltapth(a5)		source
	move.l	a0,bltdpth(a5)		destination
	move.l	#$09f00000,bltcon0(a5)	normal blitter mode
	move.l	#-1,bltafwm(a5)		no masks
	clr.l	bltamod(a5)		no a or d modulos
	move.w	#(90*64)+20,bltsize(a5)	start blitter
.btest2
	btst	#14,dmaconr(a5)		test blitter ready
	bne.s	.btest2
	rts
*---------------------------------------

fader_scroller
	tst.b	fd_pause1		test for pause
	beq.s	.nopause		branch if no pause
	subq.b	#1,fd_pause1		sub 1 from pause
	bra	.do_2			try second scroller
.nopause
	lea	fd_screen1(pc),a1	screen pointer
	move.l	#$c0000000,d0		barrel shift
	bsr	fd_scrollscreen		scroll the screen

	subq.b	#1,fd_delay1		sub 1 from delay
	bne	.do_2			branch if not yet ready	
.fd_loop1	
	lea	fd_text1(pc),a1		point to text
	move.l	fd_txt1pos(pc),d2	point to text position
	bsr	get_text		get new character
	tst.b	d0			are we at end
	bne.s	.ok1			branch if not
	clr.l	fd_txt1pos		clear text
	bra.s	.fd_loop1		get new character
.ok1
	cmpi.b	#$ff,d0			is a pause needed
	bne.s	.notpause		brach if not pause
	move.b	#$60,fd_pause1		set wait for pause
	add.l	#1,fd_txt1pos		point to new char
	bra.s	.fd_loop1		get new character
.notpause
	move.b	#4,fd_delay1		set delay
	bsr	.calculate		get font position
	lea	fd_screen1(pc),a1	point to screen
	bsr	.print_font		print the font
	add.l	#1,fd_txt1pos		point to new char
.do_2
	tst.b	fd_pause2		test for pause
	beq.s	.nopause2		branch if no pause
	subq.b	#1,fd_pause2		sub 1 from pause
	rts
.nopause2
	lea	fd_screen2(pc),a1	screen pointer
	move.l	#$e0000000,d0		barrel shift
	bsr	fd_scrollscreen		scroll the screen

	subq.b	#1,fd_delay2		sub 1 from delay
	beq.s	.fd_loop2		branch if ready
	rts
.fd_loop2
	lea	fd_text2(pc),a1		point to text
	move.l	fd_txt2pos(pc),d2	point to text position
	bsr	get_text		get new character
	tst.b	d0			are we at end
	bne.s	.ok2			branch if not
	clr.l	fd_txt2pos		clear text
	bra.s	.fd_loop2		get new character
.ok2
	cmpi.b	#$ff,d0			is a pause needed
	bne.s	.notpause2		brach if not pause
	move.b	#$60,fd_pause2		set wait for pause
	add.l	#1,fd_txt2pos		point to new char
	bra.s	.fd_loop2		get new character
.notpause2
	move.b	#8,fd_delay2		set delay
	bsr	.calculate		get font position
	lea	fd_screen2(pc),a1	point to screen
	bsr	.print_font		print the font
	add.l	#1,fd_txt2pos		point to new char
	rts
*---------------------------------------
.calculate
	move.l	d1,d0			copy character
	divu.w	#20,d1			divide by numbers of char per line
	move.l	d1,d2			save row to d2
	mulu.w	#(640),d1		multiply by next 16 lines
	mulu.w	#20,d2			get row number again
	sub.l	d2,d0			get horizontal position
	mulu	#2,d0			get 52 pixecls x horz pos
	add.l	d1,d0			add on vertical pos
	rts
*---------------------------------------
.print_font
	lea	40(a1),a1		get screen position
	lea	fader_font(pc),a0	point to screen
	add.l	d0,a0			add on position	

.btest	btst	#14,dmaconr(a5)		test blitter
	bne.s	.btest			loop until done

	move.l	#$09f00000,bltcon0(a5)	normal blitter
	move.w	#38,bltamod(a5)		38 modulo
	move.w	#40,bltdmod(a5)		40 modulo
	move.l	#-1,bltafwm(a5)		no masks

	move.l	a0,bltapth(a5)		point to source
	move.l	a1,bltdpth(a5)		destination
	move.w	#(16*64)+1,bltsize(a5)	start blitter
	rts
*---------------------------------------
fd_scrollscreen
.btest	btst	#14,dmaconr(a5)		test blitter
	bne.s	.btest			loop until done
	or.l	#$09f00000,d0		get bltcon 0 and 1

	move.l	d0,bltcon0(a5)		x shift bits
	move.l	#$ffffffff,bltafwm(a5)
	move.l	#$0,bltamod(a5)		no modulo

	move.l	a1,bltapth(a5)		source
	subq.l	#1,a1			minus 16 pixels
	move.l	a1,bltdpth(a5)		destination

	move.w	#(17*64)+22,bltsize(a5)	start the blitter
	rts
*---------------------------------------
* INPUT:-
* A1 CONTAINS POINTER TO TEXT - D2 CONTAINS TEXT POS.

get_text
	lea	checker(pc),a0		point to legal chars
	moveq	#0,d0			clear d0
	move.l	d0,d1			clear d1

	move.b	(a1,d2.w),d0		get next char
	beq.s	.gottxt			branch if not 0
.findchar
	cmp.b	(a0)+,d0		is it legal
	beq.s	.gottxt			branch if there
	addq.b	#1,d1			add 1 to counter
	cmpi.b	#54,d1			have all chars been checked
	bne.s	.findchar		branch if they havn't
	move.b	#36,d1			make if space
.gottxt
	rts

* OUTPUT:-
* D0 EQUALS TEXT END - D1 EQUALS CHAR NUMBER
*---------------------------------------
fader_colours
	subq.b	#1,fd_counter		sub 1 from delay
	beq.s	fd_ready		branch if 0
	rts				else quit
fd_ready
	lea	fd_col(pc),a0		point to fisrt colour list
	lea	4(a0),a1		point to second colour list
	lea	white(pc),a2		point to white fade-to cols
	lea	black(pc),a3		point to black fade-to cols
	add.l	fd_ccount,a2		add on position
	add.l	fd_ccount,a3		add on position
	move.b	#2,fd_counter		reset counter

	and.b	#1,fd_whichpic		which pic to display
	beq.s	fd_changecols		branch if copyright
	exg	a0,a1			swap colour pointers
fd_changecols
	cmpi.w	#$ffff,(a2)		are we at the end
	bne.s	fd_notend		no so branch
	eor.b	#1,fd_whichpic		swap pictures
	clr.l	fd_ccount		clear counter
	bra.s	fd_ready		repeat process
fd_notend
	move.w	(a2),(a0)		move in next white+ colour
	move.w	(a3),(a1)		move in next black+ colour
	addq.l	#2,fd_ccount		add to on to position
	rts				return to main loop
*---------------------------------------
	include	pt11b-play.s
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
cy_textpos	ds.l	1
fd_txt1pos	ds.l	1
fd_txt2pos	ds.l	1
fd_ccount	ds.l	1
cy_delay2	dc.b	8
fd_pause1	ds.b	1
fd_pause2	ds.b	1
fd_delay1	dc.b	8
fd_delay2	dc.b	8
fd_whichpic	dc.b	0
fd_counter	dc.b	10
		even
checker		dc.b	"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
		dc.b	"0123456789 ?.,[]':;-+/%*()!^",0
		even
fd_text1	dc.b	" THIS SCROLLER WAS PUT IN HERE FOR FUN AND JUST TO"
		dc.b	" TEST THIS FADER TYPE THINGY......ANY GREETINGS TO"
		dc.b	" ONE AND ALL..................         ",0
		even
fd_text2	dc.b	" THIS MUSIC WAS WRITTEN BY TROOPER AND THE CODE BY"
		dc.b	" ME (A-X-A-L)....... HOPE TO SEE YA ALL SOON!!!!  ",0
		even
cy_text
*	dc.b	"0123456789012345678901234567890123456789"
	dc.b	"                                        "
	dc.b	"            AXAL OF ARMALYTE            "
	dc.b	"            ^^^^^^^^^^^^^^^^            "
	dc.b	"                                        "
	dc.b	"GREETINGS FLY OUT TO:-                  "
	dc.b	"                                        "
	dc.b	"Abnormal Data                           "
	dc.b	"                                        "
	dc.b	"Wastelands - Hi Trev and Roy!!          "
	dc.b	"                                        "
	dc.b	"Golden Dragon - How about contact me!   "
	dc.b	"                                        "
	dc.b	"Catch 22                                "
	dc.b	"                                        "
	dc.b	"Digital - Hello Ken!!                   "
	dc.b	"                                        "
	dc.b	"ABN - Thanks for the A.R info!          "
	dc.b	"                                        "
	dc.b	"Chris - Will write soon!!               "
	dc.b	"                                        "
	dc.b	"Hunter - Did you like that music?       "
	dc.b	"                                        "
	dc.b	"All at A.C.C -                          "
	dc.b	"          Mark Meany                    "
	dc.b	"          Others                        "
	dc.b	"          etc, etc......                "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"If you want to contact us then write to "
	dc.b	"                                        "
	dc.b	" Axal/Armalyte,                         "
	dc.b	"    12 Dundas Way,                      "
	dc.b	"        Felling,                        "
	dc.b	"            Gateshead,                  "
	dc.b	"               Tyne & Wear,             "
	dc.b	"                   NE10 9JR             "
	dc.b	"                                        "
	dc.b	" As you can see this message displayer  "
	dc.b	"can handle LARGE as well as small char- "
	dc.b	"acters............                      "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	even
black
	dc.w	$fff,$eff,$dff,$cff,$bff,$aff,$9ff,$8ff
	dc.w	$7ff,$6ff,$5ff,$4ff,$3ff,$2ff,$1ff,$0ff
	dc.w	$0ef,$0df,$0cf,$0bf,$0af,$09f,$08f,$07f
	dc.w	$06f,$05f,$04f,$03f,$02f,$01f,$00f,$00e
	dc.w	$00d,$00c,$00b,$00a,$009,$008,$007,$006
	dc.w	$005,$004,$003,$002,$001,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$ffff
white
	dc.w	$000,$100,$200,$300,$400,$500,$600,$700
	dc.w	$800,$900,$a00,$b00,$c00,$d00,$e00,$f00
	dc.w	$f10,$f20,$f30,$f40,$f50,$f60,$f70,$f80
	dc.w	$f90,$fa0,$fb0,$fc0,$fd0,$fe0,$ff0,$ff1
	dc.w	$ff2,$ff3,$ff4,$ff5,$ff6,$ff7,$ff8,$ff9
	dc.w	$ffa,$ffb,$ffc,$ffd,$ffe,$fff,$fff,$fff
	dc.w	$fff,$fff,$fff,$fff,$fff,$fff,$fff,$fff
	dc.w	$fff,$fff,$fff,$ffff
wobblelist

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
bounce_copper
	dc.w	$8001,$fffe,$182,$0100,$180,$001
cy_copper_planes
	dc.w	bpl1pth,0,bpl1ptl,0,bplcon0,$1200
	dc.w	bpl1mod,120
	dc.w	$8101,$fffe,$182,$020,$180,$002
	dc.w	$8201,$fffe,$182,$030,$180,$002
	dc.w	$8301,$fffe,$182,$040,$180,$003
	dc.w	bpl1mod,80
	dc.w	$8401,$fffe,$182,$050,$180,$004
	dc.w	$8501,$fffe,$182,$060,$180,$004
	dc.w	$8601,$fffe,$182,$071,$180,$005
	dc.w	$8701,$fffe,$182,$072,$180,$006
	dc.w	$8801,$fffe,$182,$082,$180,$006
	dc.w	bpl1mod,40
	dc.w	$8901,$fffe,$182,$083,$180,$007
	dc.w	$8a01,$fffe,$182,$093,$180,$008
	dc.w	$8b01,$fffe,$182,$094,$180,$008
	dc.w	$8c01,$fffe,$182,$0a4,$180,$009
	dc.w	$8d01,$fffe,$182,$0a5,$180,$00a
	dc.w	$8e01,$fffe,$182,$0b5,$180,$00a
	dc.w	bpl1mod,0
	dc.w	$8f01,$fffe,$182,$1b6,$180,$00b
	dc.w	$9001,$fffe,$182,$2c6,$180,$00c
	dc.w	$9101,$fffe,$182,$3c7,$180,$00c
	dc.w	$9201,$fffe,$182,$4d7,$180,$00d
	dc.w	$9301,$fffe,$182,$5d8,$180,$00e
	dc.w	$9401,$fffe,$182,$6e8,$180,$00e
	dc.w	$9501,$fffe,$182,$7e9,$180,$00f
	dc.w	$9601,$fffe,$182,$7f9,$180,$00e
	dc.w	$9701,$fffe,$182,$7e9,$180,$00e
	dc.w	$9801,$fffe,$182,$6e8,$180,$00d
	dc.w	$9901,$fffe,$182,$5d8,$180,$00c
	dc.w	$9a01,$fffe,$182,$4d7,$180,$00c
	dc.w	$9b01,$fffe,$182,$3c7,$180,$00b
	dc.w	$9c01,$fffe,$182,$2c6,$180,$00a
	dc.w	bpl1mod,40
	dc.w	$9d01,$fffe,$182,$1b6,$180,$00a
	dc.w	$9e01,$fffe,$182,$0b5,$180,$009
	dc.w	$9f01,$fffe,$182,$0a5,$180,$008
	dc.w	$a001,$fffe,$182,$0a4,$180,$008
	dc.w	$a101,$fffe,$182,$094,$180,$007
	dc.w	$a201,$fffe,$182,$093,$180,$006
	dc.w	bpl1mod,80
	dc.w	$a301,$fffe,$182,$083,$180,$006
	dc.w	$a401,$fffe,$182,$072,$180,$005
	dc.w	$a501,$fffe,$182,$062,$180,$004
	dc.w	$a601,$fffe,$182,$051,$180,$004
	dc.w	$a701,$fffe,$182,$041,$180,$003
	dc.w	bpl1mod,120
	dc.w	$a801,$fffe,$182,$030,$180,$002
	dc.w	$a901,$fffe,$182,$020,$180,$002
	dc.w	$aa01,$fffe,$182,$010,$180,$001
	dc.w	$ab01,$fffe,$182,$000,$180,$000
	dc.w	bplcon0,$200

	dc.w	$c001,$fffe
fd_planes
	dc.w	bpl1pth,0,bpl1ptl,0,bpl2pth,0,bpl2ptl,0
	dc.w	bplcon0,$2200
	dc.w	bpl1mod,$0002,bpl2mod,$0002
	dc.w	$180,$000,$182
fd_col	dc.w	$000,$184,$fff,$186,$fff

	dc.w	$d201,$fffe,bplcon0,$200
	dc.w	$ffff,$fffe

*---------------------------------------
cylinder_font
	include	data/metallion.fnt10.txp
	even
*---------------------------------------

	incdir	sys:bitmaps 
fader_font
	incbin	armfont16x16x1
	dcb.b	40*2
cylinder_screen
	dcb.b	((cy_width/8)*cy_height)+(40*6)
	even
fd_screen1
	dcb.b	42*18
fd_screen2
	dcb.b	42*18
mt_data	incbin	source:modules/mod.summer_fun_part2
