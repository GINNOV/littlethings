
* Date: 15-8-91 (Exam Results Soon)
* Time: 21:45
* Name: Cruncher Intro
* Code: Axal
* Note: This will be version 2.0 of the cruncher disk

*  IF YOU WANT TO GET A COPY OF THE CRUNCHERS DISK SEND A DISK TO ME
*  SEE LETTER FOR MY ADDRESS - IT CONTAINS ABOUT 50 OF THE BEST CRUNCHERS
*  INCLUDING - TURBO IMPLODER V4.0 + ALL EXTRA LIBS
*              STONECRACKER V2.71	(QUITE FUNCKY)
*              DOUBLE ACTION V1.0	(THE BEST!!!!)
*              AND MANY MORE.........

	opt c-,ow-,o+

	include	source:axal/hardware.i

	section	Crunch_&_Munch,data_c

	movem.l	d0-d7/a0-a6,-(sp)	save all registers
	move.l	sp,stack		save stack pointer
	bsr	openlibs		open up the librarys
	bsr	mt_init			get the music going
	bsr	killamiga		kill the operating system
	bsr	main			do the main thing
	bsr	restoreamiga		get the operating system back
	bsr	mt_end			kill the music
	bsr	closelibs		close the librarys
error1	move.l	stack,sp		restore the stack
	movem.l	(sp)+,d0-d7/a0-a6	restore all registers
	rts				quit

*---------------------------------------

openlibs
	move.l	$4,a6			execbase
	moveq.l	#0,d0			any version
	lea	gfxname(pc),a1		point to library
	jsr	-552(a6)		open lib
	move.l	d0,gfxbase		save base
	beq	error1			branch if error
	rts

*---------------------------------------

closelibs
	move.l	$4,a6			execbase
	move.l	gfxbase(pc),a1		point to lib
	jsr	-414(a6)		close lib
	rts

*---------------------------------------

killamiga
	move.l	$4,a6			execbase
	jsr	-132(a6)		forbid multitaksking
	lea	$dff000,a5		point to custom chips
	move.w	dmaconr(a5),sysdma	save system dma
	move.w	intenar(a5),sysine	save interupt enable
	move.w	intreqr(a5),sysinr	save interupt request
	move.l	$6c.w,oldint		save vbl interupt
msb
	btst	#$0,$004(a5)		test msb of vpos
	bne.s	msb			branch if not 0
l310
	cmpi.b	#$55,$006(a5)		wait for line 310
	bne.s	l310			(stops spurious sprite data)
	move.w	#$7fff,intena(a5)	disable interupts
	move.w	#$7fff,dmacon(a5)	disable dma

	move.l	#axlcopper,cop1lch(a5)	insert my copper
	move.w	copjmp1(a5),d0		strode it
	rts				return

*---------------------------------------

restoreamiga
	move.w	sysine(pc),d1		get system int. enable
	bset	#$f,d1			set write bit
	move.w	d1,intena(a5)		restore int. enable
	move.w	sysinr(pc),d1		get system int. request
	bset	#$f,d1			set write bit
	move.w	d1,intreq(a5)		restore int. request
	move.w	sysdma(pc),d1		get system dma
	bset	#$f,d1			set write bit
	move.w	d1,dmacon(a5)		restore system dma
	move.l	oldint(pc),$6c.w	restore vbl interupt
	move.l	gfxbase(pc),a6		graphic library
	move.l	$26(a6),cop1lch(a5)	get system copper
	move.l	$4,a6			execbase
	jsr	-138(a6)		permit multitasking
	rts

*--------------------------------------

main
	bset	#1,$bfe001		filter off
	bsr.s	setupscr		show the pics
	bsr	makecoplist		make the copper list
	bsr	mainloop		do the main loop
	rts

*--------------------------------------

setupscr
	move.l	#screen,d0		logo screen
	move.l	#(40*48),d1
	move.w	d0,top1l
	swap	d0
	move.w	d0,top1h
	swap	d0
	add.l	d1,d0

	move.w	d0,top2l
	swap	d0
	move.w	d0,top2h

	move.l	#sprite,d0		star field
	move.w	d0,spr0l
	swap	d0
	move.w	d0,spr0h

	move.l	#scrscreen,d0		scroll screen
	move.w	d0,scr1l
	swap	d0
	move.w	d0,scr1h

	move.l	#rabbit,d0		rabbit picture
	move.l	#(40*182),d1
	move.w	d0,pic1l
	swap	d0
	move.w	d0,pic1h
	swap	d0
	add.l	d1,d0

	move.w	d0,pic2l
	swap	d0
	move.w	d0,pic2h
	swap	d0
	add.l	d1,d0

	move.w	d0,pic3l
	swap	d0
	move.w	d0,pic3h
	swap	d0
	add.l	d1,d0

	move.w	d0,pic4l
	swap	d0
	move.w	d0,pic4h
	move.w	#$83e0,dmacon(a5)	start dma
	rts

*--------------------------------------

makecoplist
	move.w	#146-1,d0		many times to loop

	move.w	#$6c01,d1		where to start
	move.w	#$fffe,d2		close it
	move.w	#bplcon1,d3		bplcon 1
	move.w	#$0000,d4		clear d4
	move.w	#$0100,d5		next line

	lea	wobstrt,a0		point to wobble start
	bsr	coploop			do ntsc area

	move.w	#36-1,d0		many times to loop
	move.w	#0001,d1		where to start
	lea	wobstrt2,a0		poin to strat and do pal
coploop
	move.w	d1,(a0)+		point to line
	move.w	d2,(a0)+		close it off
	move.w	d3,(a0)+		place in bplcon1
	move.w	d4,(a0)+		blank it
	add.l	d5,d1			add on next line
	dbra	d0,coploop		decrement and loop
	rts

*--------------------------------------

mainloop
vert	cmpi.b	#$ff,$006(a5)		test for vertical blank
	bne.s	vert
	bsr	starfield		move the star field
	bsr	wobblelogo		move the logo
	bsr	scroller		do the scroller
	move.l	a5,-(sp)		save register
	bsr	mt_music		play the music
	move.l	(sp)+,a5		restore it
	btst	#6,$bfe001		test for left mouse button
	bne.s	vert			branch if not pressed
	rts

*---------------------------------------

starfield
	lea	sprite,a0		point to sprite holder
	moveq	#11-1,d0		many stars
starloop
	add.b	#1,1(a0)		add on next position
	add.b	#2,9(a0)		add on next position
	add.b	#3,17(a0)		add on next position
	add.l	#24,a0			next star
	dbra	d0,starloop
nostar	rts

*---------------------------------------

wobblelogo
	lea	wobstrt(pc),a0		point to ntsc area in copper
	lea	wobblelist(pc),a1	point to table holding numbers
	move.w	wobpos,d0		get position of wobble list
	move.w	#146-1,d7		get number of lines to wobble
	bsr	wobloop			wobble ntsc area

	lea	wobstrt2(pc),a0		point to pal area in copper
	move.w	#36-1,d7		many lines
	bsr	wobloop			wobble pal area

	add.w	#1,wobpos		add on 1 to position
	cmp.w	#wend,wobpos		is it end of list
	bne.s	wobquit			branch if not equal
	move.w	#0,wobpos		restart list
wobquit
	rts
wobloop
	moveq.w	#0,d2			clear d2
	move.b	(a1,d0.w),d1		get next number
	move.w	d1,6(a0)		place it in bplcon1
	add.l	#8,a0			add on to next bplcon1
	add.w	#1,d0			add 1 to d0
	cmp.w	#wend,d0		is it end of the list
	bne.s	wobnoend		branch if not equal
	move.w	#0,d0			clear d0
wobnoend
	dbra	d7,wobloop		decrement no of lines
	rts

*---------------------------------------

scroller
	cmpi.b	#0,pausewait		is there a pause present
	beq.s	nopause			if not branch
	sub.b	#1,pausewait		if yes sub 1 and quit
	rts
nopause
	bsr	scrollscr		scroll the screen
	subq.b	#1,delay		sub 1 from the delay
	beq.s	neednew			branch if 0
	rts				main loop if not
neednew
	move.l	#checker,a0		point to legal chars
	move.l	#text,a1		point to text
	move.l	textpos,d2		point to txt position
	moveq.l	#0,d0			clear d0
	moveq.l	#0,d1			clear d1
	move.b	(a1,d2),d0		get next char

	cmpi.b	#0,d0			is d0 0
	bne.s	nowrap			branch if not
	move.l	#$0,textpos		reset pointer to text
	bra.s	neednew
nowrap
	cmpi.b	#$ff,d0			is a pause needed
	bne.s	notapause		brach if not pause
	move.b	#$60,pausewait		set wait for pause
	add.l	#1,textpos		add 1 to this font text pos
	move.b	#1,delay		no delay
	bra	neednew
notapause
	cmp.b	(a0)+,d0		is it legal
	beq.s	gotit			branch if there
	addq.b	#1,d1			add 1 to counter
	cmpi.b	#54,d1			have all chars been checked
	bne.s	nowrap			branch if they havn't
	move.b	#36,d1			make if space
gotit
	move.b	#4,delay		reset delay time
	move.l	d1,d0			save char number
	divu.w	#20,d1			divide by numbers of char per line
	move.l	d1,d2			save row to d2
	mulu.w	#640,d1			multiply by next 16 lines
	mulu.w	#20,d2			get row number again
	sub.l	d2,d0			get horizontal position
	mulu	#2,d0			get 16 pixecls x horz pos
	add.l	d1,d0			add on vertical pos
	move.l	d0,d1			copy position
	move.l	d0,d2			copy position

	move.l	#font,d1		point to font
	add.l	d0,d1			add char position
	move.l	#scrscreen,d0		point to screen
	add.l	#40,d0			add on display pos.


*---------------------------------------

blitfont
	bsr	testblit		test the blitter

	move.l	d1,bltapth(a5)		point to source
	move.l	d0,bltdpth(a5)		destination

	move.w	#$09f0,bltcon0(a5)
	move.w	#$0,bltcon1(a5)
	move.w	#38,bltamod(a5)		38 modulo
	move.w	#48,bltdmod(a5)		44 modulo
	move.w	#$ffff,bltafwm(a5)
	move.w	#$ffff,bltalwm(a5)
	move.w	#(16*64)+1,bltsize(a5)	start blitter

	add.l	#1,textpos		get next char

	rts

*---------------------------------------

scrollscr
	bsr	testblit		test the blitter

	move.l	#scrscreen,d0		point to screen
	move.l	d0,bltapth(a5)		source
	subq.l	#1,d0			minus 16 pixels
	move.l	d0,bltdpth(a5)		destination

	move.w	#$c9f0,bltcon0(a5)	12 shift bits
	move.w	#$0,bltcon1(a5)
	move.w	#0,bltamod(a5)		no modulo
	move.w	#0,bltdmod(a5)		no modulo
	move.w	#$ffff,bltafwm(a5)
	move.w	#$ffff,bltalwm(a5)
	move.w	#(18*64)+25,bltsize(a5)	start the blitter

*---------------------------------------

testblit
	btst	#14,dmaconr(a5)		test for blitter ready
	bne.s	testblit		branch it not
	rts

*---------------------------------------

	include	source:axal/pumatracker.s

*---------------------------------------

gfxname		dc.b	'graphics.library',0
		even
gfxbase		dc.l	0
oldint		dc.l	0
stack		dc.l	0
textpos		dc.l	0
sysine		dc.w	0
sysinr		dc.w	0
sysdma		dc.w	0
wobpos		dc.w	0
delay		dc.b	8
pausewait	dc.b	0
checker		dc.b	"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
		dc.b	"0123456789 ?.,[]':;-+/%*()!^",0,0
text
		dc.b	"        AXAL        ",-1,"(ONCE HITLER) OF"
		dc.b	"      ARMALYTE      ",-1,"PRESENTS TO YOU........."
		dc.b	"   CRUNCHERS V2.0   ",-1
		dc.b	"A DISK FILLED TO THE BRIM WITH THE BEST CRUNCHERS AROUND"
		dc.b	"........CREDITS....... CODE, LOGO AND FONT BY"
		dc.b	"        AXAL        ",-1,"MUSIC TAKEN FROM"
		dc.b	"        TOKI        ",-1,"RIPPED BY AGILE....FLAPPINGS FLY TO"
		dc.b	"    ABNORMAL DATA   ",-1
		dc.b	"      CATCH 22      ",-1
		dc.b	"   KEN OF DIGITAL   ",-1
		dc.b	"     WASTELAND      ",-1
		dc.b	"     SUBLIMINAL     ",-1
		dc.b	"   GOLDEN DRAGON    ",-1
		dc.b	"      PD RAY        ",-1
		dc.b	"        ABN         ",-1
		dc.b	"    MARK MEANY      ",-1,"ALL THOSE WHO SEND STUFF TO"
		dc.b	"       A.C.C        ",-1
		dc.b	"       SMILA        ",-1,"EVERYONE AT THE"
		dc.b	" TUESDAY NIGHT CLUB ",-1
		dc.b	"      DEADMAN       ",-1,"WHERE THE HELL ARE YOU???  "
		dc.b	"CONTACTS AND FRIENDS",-1,"     "
		dc.b	"TO CONTACT US WRITE TO THE FOLLOWING ADDRESSES-----"
		dc.b	"   12 DUNDAS WAY    ",-1
		dc.b	"     GATESHEAD      ",-1
		dc.b	"   TYNE AND WEAR    ",-1," OR "
		dc.b	" 12 KIND EDWARD ST  ",-1
		dc.b	"      GATESHEAD     ",-1
		dc.b	"    TYNE AND WEAR   ",-1," WATCH OUT FOR MORE COMPS SOON....BYE!!!!"
		dc.b	"                    ",00
		even

*---------------------------------------

axlcopper
	dc.w	bplcon1,0,bplcon2,0
	dc.w	bpl1mod,0,bpl2mod,0
	dc.w	diwstrt,$2681,diwstop,$36c1
	dc.w	ddfstrt,$0038,ddfstop,$00d0
	dc.w	beamcon0,$20

	dc.w	bplcon0,$2200
	dc.w	bpl1pth
top1h	dc.w	0
	dc.w	bpl1ptl
top1l	dc.w	0
	dc.w	bpl2pth
top2h	dc.w	0
	dc.w	bpl2ptl
top2l	dc.w	0

	dc.w	$180,$000,$182,$888,$184,$bbb,$186,$444
	dc.w	$1a2,$fff,$1aa,$fff

	dc.w	spr0pth
spr0h	dc.w	0
	dc.w	spr0ptl
spr0l	dc.w	0
	dc.w	spr1pth
spr1h	dc.w	0
	dc.w	spr1ptl
spr1l	dc.w	0
	dc.w	spr2pth
spr2h	dc.w	0
	dc.w	spr2ptl
spr2l	dc.w	0
	dc.w	spr3pth,0,spr3ptl,0,spr4pth,0,spr4ptl,0
	dc.w	spr5pth,0,spr5ptl,0,spr6pth,0,spr6ptl,0
	dc.w	spr7pth,0,spr7ptl,0
	dc.w	$5601,$fffe,bplcon0,$200
	dc.w	$5801,$fffe,bplcon0,$1200
	dc.w	bpl1mod,10,$182,$909
	dc.w	bpl1pth
scr1h	dc.w	0
	dc.w	bpl1ptl
scr1l	dc.w	0

	dc.w	$6a01,$fffe,bplcon0,$200
	dc.w	$6b01,$fffe,$180,$fff
	dc.w	$6c01,$fffe,$180,$000
	dc.w	$6d01,$fffe,bplcon0,$4200
	dc.w	bpl1mod,0

	dc.w	bpl1pth
pic1h	dc.w	0
	dc.w	bpl1ptl
pic1l	dc.w	0
	dc.w	bpl2pth
pic2h	dc.w	0
	dc.w	bpl2ptl
pic2l	dc.w	0
	dc.w	bpl3pth
pic3h	dc.w	0
	dc.w	bpl3ptl
pic3l	dc.w	0
	dc.w	bpl4pth
pic4h	dc.w	0
	dc.w	bpl4ptl
pic4l	dc.w	0
	dc.w	$180,$000,$182,$433,$184,$222,$186,$666
	dc.w	$188,$832,$18a,$b00,$18c,$fbb,$18e,$cef
	dc.w	$190,$08e,$192,$f00,$194,$fd4,$196,$fff
	dc.w	$198,$ddd,$19a,$bbb,$19c,$999,$19e,$b93
wobstrt
	ds.w	146*4

	dc.w	$ffe1,$fffe		enable pal
wobstrt2
	ds.w	36*4

	dc.w	$2301,$fffe
	dc.w	bplcon0,$200
	dc.w	$2501,$fffe,$180,$001
	dc.w	$2601,$fffe,$180,$002
	dc.w	$2701,$fffe,$180,$003
	dc.w	$2801,$fffe,$180,$004
	dc.w	$2901,$fffe,$180,$005
	dc.w	$2a01,$fffe,$180,$006
	dc.w	$2b01,$fffe,$180,$007
	dc.w	$2c01,$fffe,$180,$008
	dc.w	$2d01,$fffe,$180,$009
	dc.w	$2e01,$fffe,$180,$00a
	dc.w	$2f01,$fffe,$180,$00b
	dc.w	$ffff,$fffe

*---------------------------------------

sprite
	dc.w    $2615,$2700,$1000,$0000
	dc.w    $2845,$2900,$1000,$0000
	dc.w    $2a68,$2b00,$1000,$0000

	dc.w    $2cb8,$2d00,$1000,$0000
	dc.w    $2eb4,$2f00,$1000,$0000
	dc.w    $307a,$3100,$1000,$0000

	dc.w    $3220,$3300,$1000,$0000
	dc.w    $34c0,$3500,$1000,$0000
	dc.w    $3650,$3700,$1000,$0000

	dc.w    $3842,$3900,$1000,$0000
	dc.w    $3a6d,$3b00,$1000,$0000
	dc.w    $3ca2,$3D00,$1000,$0000

	dc.w    $3e9c,$3f00,$1000,$0000
	dc.w    $40da,$4100,$1000,$0000
	dc.w    $4203,$4300,$1000,$0000

	dc.w    $445a,$4500,$1000,$0000
	dc.w    $4615,$4700,$1000,$0000
	dc.w    $4845,$4900,$1000,$0000

	dc.w    $4a68,$4b00,$1000,$0000
	dc.w    $4cb8,$4d00,$1000,$0000
	dc.w    $4e14,$4f00,$1000,$0000

	dc.w    $5057,$5100,$1000,$0000
	dc.w    $524c,$5300,$1000,$0000
	dc.w    $54c0,$5500,$1000,$0000

	dc.w    $5650,$5700,$1000,$0000
	dc.w    $5842,$5900,$1000,$0000
	dc.w    $5a2d,$5b00,$1000,$0000

	dc.w    $5ca2,$5D00,$1000,$0000
	dc.w    $5e9c,$5f00,$1000,$0000
	dc.w    $60da,$6100,$1000,$0000

	dc.w    $6273,$6300,$1000,$0000
	dc.w    $645a,$6500,$1000,$0000
	dc.w	$6658,$6700,$1000,$0000
	dc.w 	$0000,$0000

wobblelist
	include	source:axal/wobble_list.dat

		incdir	source:bitmaps/
screen		incbin	armalyte320x68x2
rabbit		incbin	rabbit320x182x4
		even
font		incbin	armfont16x16x1
mt_data		incbin	source:modules/toki9
		even
scrscreen	dcb.b	(56*60)
		even
