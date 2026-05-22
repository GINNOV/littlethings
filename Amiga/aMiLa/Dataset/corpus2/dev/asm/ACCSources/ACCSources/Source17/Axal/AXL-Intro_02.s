
* DATE: 17-08-91
* TIME: 23:25
* NAME: INTRO 02
* CODE: AXAL
* NOTE: THIS INTRO IS NUMBER 2,$02,%0010,^02

	opt c-,ow-,o+

	include	source:axal/hardware.i

	section	scroller,data_c

	movem.l	d0-d7/a0-a6,-(sp)	save all registers
	move.l	sp,stack		save stack pointer
	bsr	openlibs		open up the librarys
	bsr	mt_init
	bsr	killamiga		kill the operating system
	bsr	main			do the main thing
	bsr	restoreamiga		get the operating system back
	bsr	mt_end
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
	bsr	setupscr		show the screens
	bsr	buildcopper		build the copper
	bsr	colourscroll
	move.w	#$83e0,dmacon(a5)	start dma
	bsr	mainloop		do the main loop
	rts

*--------------------------------------

setupscr
	move.l	#scrscreen,d0		point to screen
	move.l	#(56*54),d1		next plane

	move.w	d0,pl1l
	swap	d0
	move.w	d0,pl1h
	swap	d0
	add.l	d1,d0

	move.w	d0,pl2l
	swap	d0
	move.w	d0,pl2h
	swap	d0
	add.l	d1,d0

	move.w	d0,pl3l
	swap	d0
	move.w	d0,pl3h

	move.l	#infoscreen,d0
	move.l	#(40*154),d1
	move.w	d0,inf1l
	swap	d0
	move.w	d0,inf1h
	swap	d0
	add.l	d1,d0

	move.w	d0,inf2l
	swap	d0
	move.w	d0,inf2h

	move.l	#sprite,d0		star field
	move.w	d0,spr0l
	swap	d0
	move.w	d0,spr0h

	move.l	#logo,d0
	move.l	#(40*48),d1
	move.w	d0,logo1l
	swap	d0
	move.w	d0,logo1h
	swap	d0
	add.l	d1,d0

	move.w	d0,logo2l
	swap	d0
	move.w	d0,logo2h
	swap	d0
	add.l	d1,d0

	move.w	d0,logo3l
	swap	d0
	move.w	d0,logo3h
	swap	d0
	add.l	d1,d0

	move.w	d0,logo4l
	swap	d0
	move.w	d0,logo4h
	rts

*--------------------------------------

buildcopper
	lea	copstrt,a0		point tot copper list
	move.l	#$6401fffe,d0		start of list
	move.l	#$01800000,d1		colour register
	move.l	#$01000000,d2		next line
	move.w	#154-1,d5		many times to loop
coploop1
	move.l	d0,(a0)+		line number
	move.l	d1,(a0)+		end it
	add.l	d2,d0			next line please
	dbra	d5,coploop1		decrement and branch
	rts

*---------------------------------------

colourscroll
	lea	colourlist,a0		point to colour list
	lea	copstrt,a1		point to copper
	move.w	#154-1,d0
colmoveloop
	move.w	(a0),6(a1)		shift in new colour
	add.l	#8,a1			next line
	cmpi.w	#0,(a0)+		is next colour 0
	bne.s	colok			branch if its not
	lea	colourlist,a0		repoint to it
colok
	dbra	d0,colmoveloop
	rts

*--------------------------------------

mainloop
	cmpi.b	#$ff,$006(a5)		test for vertical blank
	bne.s	mainloop
	bsr	starfield
	bsr	scroller
	bsr	printchar
	move.l	a5,-(sp)
	bsr	mt_music
	move.l	(sp)+,a5
	btst	#6,$bfe001		test for left mouse button
	bne.s	mainloop		branch if not pressed
	rts

*---------------------------------------

starfield
	lea	sprite,a0		point to sprite holder
	move.l	#24,d1			next star
	moveq	#9-1,d0			many stars
starloop
	add.b	#1,1(a0)		add on next position
	add.b	#2,9(a0)		add on next position
	add.b	#3,17(a0)		add on next position
	add.l	d1,a0			next star
	dbra	d0,starloop
nostar	rts

*---------------------------------------

scroller
	cmpi.b	#0,pausewait		is there a pause present
	beq.s	nopause			if not branch
	subq.b	#1,pausewait		if yes sub 1 and quit
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
	move.l	d0,d1			clear d1
	move.b	(a1,d2),d0		get next char

	cmpi.b	#0,d0			is d0 0
	bne.s	nowrap			branch if not
	move.l	#$0,textpos		reset pointer to text
	bra.s	neednew
nowrap
	cmpi.b	#$ff,d0			is a pause needed
	bne.s	notapause		brach if not pause
	move.b	#$60,pausewait		set wait for pause
	addq.l	#1,textpos		add 1 to this font text pos
	bra	neednew
notapause
	cmpi.b	#$10,d0			is d0 less than 16
	bls	chgtxt			change the text
notfound
	cmp.b	(a0)+,d0		is it legal
	beq.s	gotit			branch if there
	addq.b	#1,d1			add 1 to counter
	cmpi.b	#54,d1			have all chars been checked
	bne.s	notfound		branch if they havn't
	move.b	#36,d1			make if space
gotit
	move.b	#15,delay		reset delay time
	move.l	d1,d0			save char number
	divu.w	#5,d1			divide by numbers of char per line
	move.l	d1,d2			save row to d2
	mulu.w	#2080,d1		multiply by next 52 lines
	mulu.w	#5,d2			get row number again
	sub.l	d2,d0			get horizontal position
	mulu	#8,d0			get 52 pixecls x horz pos
	add.l	d1,d0			add on vertical pos

	move.l	#font,d1		point to font
	add.l	d0,d1			add char position
	move.l	#scrscreen,d0		point to screen
	add.l	#48,d0			add on display pos.

*---------------------------------------

blitfont
	bsr	testblit		test the blitter
	move.l	#$09f00000,bltcon0(a5)	normal stuff
	move.l	#$fffffffe,bltafwm(a5)	no masks
	move.w	#32,bltamod(a5)		38 modulo
	move.w	#48,bltdmod(a5)		44 modulo
	move.l	#(56*54),d2		next screen plane
	move.l	#(40*520),d3		next font plane
	moveq	#3-1,d5			many planes
fontloop1
	move.l	d1,bltapth(a5)		point to source
	move.l	d0,bltdpth(a5)		destination
	move.w	#(52*64)+4,bltsize(a5)	start blitter

	add.l	d2,d0			add on next screen plane
	add.l	d3,d1			add on next font plane
	bsr	testblit
	dbra	d5,fontloop1		decrement and branch

	add.l	#1,textpos		get next char

	rts

*---------------------------------------

scrollscr
	bsr	testblit		test the blitter

	move.l	#scrscreen,d0		point to screen
	move.l	#$c9f00000,bltcon0(a5)	12 shift bits
	move.l	#$ffffffff,bltafwm(a5)	mo masks
	clr.w	bltamod(a5)		no modulo
	clr.w	bltdmod(a5)		no modulo
	move.l	#(56*54)+1,d1		next plane
	moveq	#3-1,d5
scrollloop1
	move.l	d0,bltapth(a5)		source
	subq.l	#1,d0			minus 16 pixels
	move.l	d0,bltdpth(a5)		destination
	move.w	#(54*64)+28,bltsize(a5)	start the blitter

	add.l	d1,d0			next plane
	bsr	testblit		is blitter ready
	dbra	d5,scrollloop1
	rts

*---------------------------------------

printchar
	subq.b	#1,infodelay
	beq.s	ready			branch if 0
	rts
ready
	move.b	#$2,infodelay		reset delay
	move.l	txtpoint(pc),a1		point to text
	move.l	infotxtpos,d2		point to position

	bsr	findchar		get charactor

	cmpi.b	#0,d0			is d0 0
	bne.s	notend			branch if not
	clr.l	count			reset counter
	move.l	#40,extra		reset extra
	rts
notend
	move.l	d1,d0			save char number
	divu.w	#40,d1			divide by numbers of char per line
	move.l	d1,d2			save row to d2
	mulu.w	#280,d1			multiply by next 6 lines
	mulu.w	#40,d2			get row number again
	sub.l	d2,d0			get horizontal position
	add.l	d1,d0			add on vertical pos

	lea	infofont,a0		point to font
	add.l	d0,a0			add on font pos
	lea	infoscreen,a1		point to screen

	cmpi.l	#40,count		is counter 20
	bne.s	not20			branch if not
	clr.l	count			reset counter
	add.l	#(40*8),extra		an on next line
not20
	add.l	count,a1		add on counter
	add.l	extra,a1		add on extra lines

	moveq.l	#0,d0			clear d0
	move.b	#6,d0			many times to loop
loop
	move.b	(a0),(a1)		copy font
	add.l	#40,a0			next line
	add.l	#40,a1			next line
	dbra	d0,loop			decrement and loop
	bsr	blitinfo		blit second plane
	addq.l	#1,infotxtpos		add 1 to text pos
	addq.l	#1,count		add 1 to counter
	rts

*---------------------------------------

blitinfo
	bsr	testblit
	move.l	#infoscreen,d0		point to screen
	move.l	#$29f00000,bltcon0(a5)
	move.l	#$fffffffc,bltafwm(a5)	kill last 2 pixels
	clr.w	bltamod(a5)		no modulo
	clr.w	bltdmod(a5)		no modulo

	move.l	d0,bltapth(a5)		point to source
	add.l	#(40*154)+40,d0		next plane+two lines
	move.l	d0,bltdpth(a5)		destination
	move.w	#(150*64)+20,bltsize(a5)	start blitter
	rts

*---------------------------------------

* INPUT:-
* A1 CONTAINS POINTER TO TEXT - D2 CONTAINS TEXT POS.

findchar
	move.l	#checker,a0		point to legal chars
	moveq.l	#0,d0			clear d0
	moveq.l	#0,d1			clear d1

	move.b	(a1,d2),d0		get next char
	bgt.s	getchar2		branch if not 0
	rts
getchar2
	cmp.b	(a0)+,d0		is it legal
	beq.s	gotit2			branch if there
	addq.b	#1,d1			add 1 to counter
	cmpi.b	#54,d1			have all chars been checked
	bne.s	getchar2		branch if they havn't
	move.b	#36,d1			make if space
gotit2
	rts

* OUTPUT:-
* D0 EQUALS 0 IS TEXT END - D1 EQUALS CHAR NUMBER

*---------------------------------------

testblit
	btst	#14,dmaconr(a5)		test for blitter ready
	bne.s	testblit		branch it not
	rts

*----------------------------------------

chgtxt
	lea	infonames,a0		point to text names
	lsl	#2,d0			multiply by 2
	move.l	(a0,d0),a1		get address of text
	move.l	a1,txtpoint		pointer to text
	moveq.l	#0,d0			clear d0
	move.l	d0,infotxtpos		clear
	move.l	d0,count		  "
	move.l	#40,extra		next line
	move.b	#2,infodelay		delay time
	addq.l	#1,textpos		next char
	bra	neednew
infonames
	dc.l	text,infotext1,infotext2,infotext3,infotext4

*---------------------------------------

	include	source:axal/pt-playabn.s

*---------------------------------------

gfxname		dc.b	'graphics.library',0
		even
gfxbase		dc.l	0
oldint		dc.l	0
stack		dc.l	0
textpos		dc.l	0
infotxtpos	dc.l	0
count		dc.l	0
extra		dc.l	40
colpos		dc.l	0
txtpoint	dc.l	0
sysine		dc.w	0
sysinr		dc.w	0
sysdma		dc.w	0
infodelay	dc.b	0
delay		dc.b	16
pausewait	dc.b	0
checker		dc.b	"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
		dc.b	"0123456789 ?.,[]':;-()!*/",0,0
text
		dc.b	1," AXAL ",-1,"OF ARMALYTE PRESENTS ANOTHER COMPACT!!!!"
		dc.b	" PLEASE ENJOY........GREETINGS TO EVERYONE THAT HAS A TELEPHONE",2
		dc.b	" NUMBER LIKE THIS......... 478 7404--------- NEXT SCREEN PLEASE"
		dc.b	" I JUST DONT KNOW WHAT TO TALK ABOUT IN SCROLLERS... DO YOU? ",3
		dc.b	" I HATE 'EM SO I'M JUST GOING TO LEAVE THIS ONE TO LFEE AND "
		dc.b	" MAVRICK-------BY THE WAY YOU CAN CONTACT US AT MINE (AXAL)"
		dc.b	" OR MAVRICKS HOUSE --- SEE BELOW FOR PHONE NUMBERS AND ADDRESSES"
		dc.b	" BYE.................          ",0
		even
;		dc.b	"1234567890123456789012345678901234567890"
infotext1	dc.b	"            A R M A L Y T E             "
		dc.b	"                                        "
		dc.b	"        PRESENT ANOTHER COMPACT         "
		dc.b	"                                        "
		dc.b	" THIS TIME THE VERY BEST VIRUS KILLERS  "
		dc.b	"                                        "
		dc.b	"           ZERO VIRUS V3.0              "
		dc.b	"             VIRUS-X V4.1               "
		dc.b	"        ULTIMATE VIRUS KILLER           "
		dc.b	"       AND MANY MORE..........          "
		dc.b	"                                        "
		dc.b	"                                        "
		dc.b	" **  ***  *   *  **  *  *   * ***** ****"
		dc.b	"*  * *  * ** ** *  * *  *   *   *   *   "
		dc.b	"*  * *  * * * * *  * *   * *    *   ****"
		dc.b	"**** ***  *   * **** *    *     *   ****"
		dc.b	"*  * *  * *   * *  * *    *     *   *   "
		dc.b	"*  * *  * *   * *  * **** *     *   ****",0
infotext2
		dc.b	"         ARMALYTE SHOUTS OUT TO         "
		dc.b	"           THE FOLLOWING GUYZ           "
		dc.b	"                                        "
		dc.b	"             ABNORMAL DATA              "
		dc.b	"               CATCH  22                "
		dc.b	"                DIGITAL                 "
		dc.b	"               WASTELAND                "
		dc.b	"   EVERYONE AT THE TUESDAY NIGHT CLUB   "
		dc.b	"                                        "
		dc.b	"PRESS LEFT MOUSE BUTTON TO START........"
		dc.b	"                                        ",0
*		dc.b	"
*		dc.b	"
*		dc.b	"
*		dc.b	"
*		dc.b	"
*		dc.b	"
*		dc.b	"
infotext3
		dc.b    "*******   ***  *   *  ***  *     *******"
		dc.b    " ******  *   *  * *  *   * *     ****** "
	 	dc.b    "  *****  *****   *   ***** *     *****  "
	 	dc.b    "   ****  *   *  * *  *   * *     ****   "
		dc.b    "    ***  *   * *   * *   * ****  ***    "
		dc.b	"               CODER-GFX                "
		dc.b    "*******  *     ***** ****  ****  *******"
		dc.b    " ******  *     *     *     *     ****** "
		dc.b    "  *****  *     ****  ****  ****  *****  "
		dc.b    "   ****  *     *     *     *     ****   "
		dc.b    "    ***  ***** *     ****  ****  ***    "
		dc.b	"             MUSIC COMPOSER             "
		dc.b	"*   *  ****  *   *  ****   *  ****  *  *"
		dc.b	"** **  *  *  *   *  *   *  *  *     * * "
		dc.b	"* * *  ****  *   *  ****   *  *     **  "
		dc.b	"*   *  *  *   * *   *   *  *  *     * * "
		dc.b	"*   *  *  *    *    *   *  *  ****  *  *"
		dc.b	"                SWAPPER                 ",0
infotext4	even

*---------------------------------------

axlcopper
	dc.w	diwstrt,$2860,diwstop,$30d0
	dc.w	ddfstrt,$0028,ddfstop,$00d4
	dc.w	bpl1mod,10,bpl2mod,10
	dc.w	bplcon1,0,bplcon2,0
	dc.w	beamcon0,$20
	dc.w	bplcon0,$3200
	dc.w	bpl1pth
pl1h	dc.w	0,bpl1ptl
pl1l	dc.w	0,bpl2pth
pl2h	dc.w	0,bpl2ptl
pl2l	dc.w	0,bpl3pth
pl3h	dc.w	0,bpl3ptl
pl3l	dc.w	0
	dc.w	$180,$000,$182,$eca,$184,$ea8,$186,$e86
	dc.w	$188,$c64,$18a,$a42,$18c,$820,$18e,$004
	dc.w	$1a2,$fff,$1a4,$888,$1a6,$444
	dc.w	spr0pth
spr0h	dc.w	0,spr0ptl
spr0l	dc.w	0
	dc.w	spr1pth,0,spr1ptl,0,spr2pth,0,spr2ptl,0
	dc.w	spr3pth,0,spr3ptl,0,spr4pth,0,spr4ptl,0
	dc.w	spr5pth,0,spr5ptl,0,spr6pth,0,spr6ptl,0
	dc.w	spr7pth,0,spr7ptl,0
	dc.w	$2b01,$fffe,$18e,$0ff
	dc.w	$2c01,$fffe,$18e,$0ef
	dc.w	$2d01,$fffe,$18e,$0df
	dc.w	$2e01,$fffe,$18e,$0cf
	dc.w	$2f01,$fffe,$18e,$0bf
	dc.w	$3001,$fffe,$18e,$0af
	dc.w	$3101,$fffe,$18e,$09f
	dc.w	$3201,$fffe,$18e,$08f
	dc.w	$3301,$fffe,$18e,$07f
	dc.w	$3401,$fffe,$18e,$06f
	dc.w	$3501,$fffe,$18e,$05f
	dc.w	$3601,$fffe,$18e,$04f
	dc.w	$3701,$fffe,$18e,$03f
	dc.w	$3801,$fffe,$18e,$02f
	dc.w	$3901,$fffe,$18e,$01f
	dc.w	$3a01,$fffe,$18e,$00f
	dc.w	$3b01,$fffe,$18e,$00e
	dc.w	$3c01,$fffe,$18e,$00d
	dc.w	$3d01,$fffe,$18e,$00c
	dc.w	$3e01,$fffe,$18e,$00b
	dc.w	$3f01,$fffe,$18e,$00a
	dc.w	$4001,$fffe,$18e,$009
	dc.w	$4101,$fffe,$18e,$008
	dc.w	$4201,$fffe,$18e,$107
	dc.w	$4301,$fffe,$18e,$206
	dc.w	$4401,$fffe,$18e,$305
	dc.w	$4501,$fffe,$18e,$404
	dc.w	$4601,$fffe,$18e,$503
	dc.w	$4701,$fffe,$18e,$602
	dc.w	$4801,$fffe,$18e,$701
	dc.w	$4901,$fffe,$18e,$800
	dc.w	$4a01,$fffe,$18e,$900
	dc.w	$4b01,$fffe,$18e,$a00
	dc.w	$4c01,$fffe,$18e,$b00
	dc.w	$4d01,$fffe,$18e,$c00
	dc.w	$4e01,$fffe,$18e,$d00
	dc.w	$4f01,$fffe,$18e,$e00
	dc.w	$5001,$fffe,$18e,$f00
	dc.w	$5101,$fffe,$18e,$f10
	dc.w	$5201,$fffe,$18e,$f20
	dc.w	$5301,$fffe,$18e,$f30
	dc.w	$5401,$fffe,$18e,$f40
	dc.w	$5501,$fffe,$18e,$f50
	dc.w	$5601,$fffe,$18e,$f60
	dc.w	$5701,$fffe,$18e,$f70
	dc.w	$5801,$fffe,$18e,$f80
	dc.w	$5901,$fffe,$18e,$f90
	dc.w	$5a01,$fffe,$18e,$fa0

	dc.w	$5c01,$fffe,bplcon0,$200
	dc.w	$6101,$fffe,$180,$fff
	dc.w	$6201,$fffe,$180,$000
	dc.w	$6301,$fffe,bplcon0,$2200
	dc.w	diwstrt,$2c81
	dc.w	diwstop,$30c1
	dc.w	ddfstrt,$0038
	dc.w	ddfstop,$00d0
	dc.w	bpl1mod,0
	dc.w	bpl2mod,0
	dc.w	bpl1pth
inf1h	dc.w	0
	dc.w	bpl1ptl
inf1l	dc.w	0
	dc.w	bpl2pth
inf2h	dc.w	0
	dc.w	bpl2ptl
inf2l	dc.w	0
	dc.w	$182,$fff,$184,$333,$186,$fff
copstrt
	ds.w	154*4
	dc.w	bplcon0,$200
	dc.w	$fe01,$fffe,$180,$fff
	dc.w	$ff01,$fffe,$180,$000
	dc.w	$ffe1,$fffe,$0001,$fffe
	dc.w	bplcon0,$4200
	dc.w	bpl1pth
logo1h	dc.w	0
	dc.w	bpl1ptl
logo1l	dc.w	0
	dc.w	bpl2pth
logo2h	dc.w	0
	dc.w	bpl2ptl
logo2l	dc.w	0
	dc.w	bpl3pth
logo3h	dc.w	0
	dc.w	bpl3ptl
logo3l	dc.w	0
	dc.w	bpl4pth
logo4h	dc.w	0
	dc.w	bpl4ptl
logo4l	dc.w	0
	dc.w	$180,$000,$182,$400,$184,$600,$186,$700
	dc.w	$188,$900,$18a,$a00,$18c,$c00,$18e,$d00
	dc.w	$190,$f00,$192,$f20,$194,$f40,$196,$f60
	dc.w	$198,$f80,$19a,$fb0,$19c,$fd0,$19e,$ff0
	dc.w	$ffff,$fffe

*---------------------------------------

colourlist
	dc.w	$001,$002,$013,$024,$035,$046,$057,$168
	dc.w	$279,$38a,$49b,$5ac,$6bd,$7ce,$8df
	dc.w	$fd8,$ec7,$db6,$ca5,$b94,$a83,$972,$861
	dc.w	$750,$640,$530,$420,$310,$200,$100,$000
sprite
*	%0000000000000111,%0000000000001100

	dc.w    $2810,$2900,$0007,$000c
	dc.w    $2a6a,$2b00,$0007,$000c
	dc.w    $2cc0,$2d00,$0007,$000c

	dc.w    $2e86,$2f00,$0007,$000c
	dc.w    $30bf,$3100,$0007,$000c
	dc.w    $3234,$3300,$0007,$000c

	dc.w    $342a,$3500,$0007,$000c
	dc.w    $3614,$3700,$0007,$000c
	dc.w    $387d,$3900,$0007,$000c

	dc.w    $3ac4,$3b00,$0007,$000c
	dc.w    $3c40,$3D00,$0007,$000c
	dc.w    $3e21,$3f00,$0007,$000c

	dc.w    $4053,$4100,$0007,$000c
	dc.w    $428d,$4300,$0007,$000c
	dc.w    $448e,$4500,$0007,$000c

	dc.w    $461f,$4700,$0007,$000c
	dc.w    $4820,$4900,$0007,$000c
	dc.w    $4a00,$4b00,$0007,$000c

	dc.w    $4c6a,$4d00,$0007,$000c
	dc.w    $4eb3,$4f00,$0007,$000c
	dc.w    $50b1,$5100,$0007,$000c

	dc.w    $529d,$5300,$0007,$000c
	dc.w    $54f0,$5500,$0007,$000c
	dc.w    $5616,$5700,$0007,$000c

	dc.w    $58ef,$5900,$0007,$000c
	dc.w    $5a34,$5b00,$0007,$000c
	dc.w    $5c44,$5d00,$0007,$000c

	dc.w 	$0000,$0000

*---------------------------------------

		incdir	source:bitmaps/
font		incbin	onyx_1.bit   	;(320*520) 64*52
infofont	incbin	font8x8x1
logo		incbin	armalyte320x48x4
module		incbin	source:modules/mod.music
		even
scrscreen	dcb.b	(56*54)*3
		even
infoscreen	dcb.b	(40*154)*2
		even
