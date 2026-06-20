* DATE: 02-09-91
* TIME: 00:10
* NAME: 2 PLANE FADER-WOBBLE-MESSAGE DISPLAYER!!!
* CODE: AXAL
* NOTE: WROTE BECAUSE THERE IS NOTHING ON THE TELE

	opt c-,ow-,o+

	include	source:axal/hardware.i

	section	la_la_la_la_la_la_,data_c

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
	move.l	gfxbase(pc),a6		graphic library
	move.l	$26(a6),cop1lch(a5)	get system copper
	move.l	$4,a6			execbase
	jsr	-138(a6)		permit multitasking
	rts

*--------------------------------------

main
	bsr	setscreens
	move.w	#$83e0,dmacon(a5)	start dma
	bsr	mainloop		do the main loop
	rts

*---------------------------------------
*
*dointerupts
*	move.l	#myinterupts,$6c.w	place in my interupts
*	rts
*myinterupts
*	movem.l	d0-d7/a0-a6,-(sp)	save all registers
*	bsr	change_pic
*	movem.l	(sp)+,d0-d7/a0-a6	restore all registers
*	move.w	#$70,$dff09c		copper/vertical blank
*	rte				the end
*
*--------------------------------------

setscreens
	move.l	#fd_screen1,d0
	move.w	d0,top1l
	swap	d0
	move.w	d0,top1h

	move.l	#fd_screen2,d0
	move.w	d0,top2l
	swap	d0
	move.w	d0,top2h
	rts

*--------------------------------------

mainloop
	cmpi.b	#$ff,$006(a5)		test for vertical blank
	bne.s	mainloop
*	move.w	#$fff,$180(a5)
	bsr	fader_scroll
	bsr	wobble_fader
*	move.w	#$000,$180(a5)
	move.l	a5,-(sp)
	bsr	mt_music
	move.l	(sp)+,a5
	btst	#6,$bfe001		test for left mouse button
	bne.s	mainloop		branch if not pressed
	rts

*---------------------------------------

fader_scroll
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
	bsr.s	fd_message		change the text
	bra.s	fd_ready		repeat process
fd_notend
	move.w	(a2),(a0)		move in next white+ colour
	move.w	(a3),(a1)		move in next black+ colour
	addq.l	#2,fd_ccount		add to on to position
	rts				return to main loop

*---------------------------------------

fd_message
	moveq	#20-1,d6		many times to loop
	lea	fd_txt,a1		point to text
	lea	fd_screen1(pc),a3	point to screen 1

	bsr	testblit
	move.l	#$09f00000,bltcon0(a5)	set bltcon0 and 1
	move.w	#38,bltamod(a5)		38 modulo
	move.w	#40,bltdmod(a5)		40 modulo
	move.l	#-1,bltafwm(a5)	no masks

	cmpi.b	#0,fd_whichpic		is it screen 1
	beq.s	fd_loop1		branch if yes
	lea	(42*18)(a3),a3		point to second screen
fd_loop1
	move.l	fd_txtpos,d2		point to txt position
	bsr	get_text		find next character

	cmpi.b	#0,d0			is d0 0
	bne.s	fd_not0			branch is not 0
	clr.l	fd_txtpos		clear text counter
	bra.s	fd_message		redo from start
fd_not0
	move.l	d1,d0			save char number
	divu.w	#20,d1			divide by numbers of char per line
	move.l	d1,d2			save row to d2
	mulu.w	#640,d1			multiply by next 32 lines
	mulu.w	#20,d2			get row number again
	sub.l	d2,d0			get horizontal position
	mulu.w	#2,d0			get 32 pixecls x horz pos
	add.l	d1,d0			add on vertical pos

	move.l	#fd_font,d1		point to font
	add.l	d0,d1			add char position

*---------------------------------------

	bsr	testblit		test the blitter
	move.l	d1,bltapth(a5)		point to source
	move.l	a3,bltdpth(a5)		destination
	move.w	#(16*64)+1,bltsize(a5)	start blitter

	addq.l	#1,fd_txtpos		get next char
	add.l	#2,a3			add on to screen
	dbra	d6,fd_loop1
	rts

*---------------------------------------

* INPUT:-
* A1 CONTAINS POINTER TO TEXT - D2 CONTAINS TEXT POS.

get_text
	lea	checker(pc),a0		point to legal chars
	moveq.l	#0,d0			clear d0
	moveq.l	#0,d1			clear d1

	move.b	(a1,d2),d0		get next char
	bgt.s	gt_findchar		branch if not 0
	rts
gt_findchar
	cmp.b	(a0)+,d0		is it legal
	beq.s	gt_gottxt		branch if there
	addq.b	#1,d1			add 1 to counter
	cmpi.b	#54,d1			have all chars been checked
	bne.s	gt_findchar		branch if they havn't
	move.b	#36,d1			make if space
gt_gottxt
	rts

* OUTPUT:-
* D0 EQUALS TEXT END - D1 EQUALS CHAR NUMBER

*---------------------------------------

testblit
	btst	#14,dmaconr(a5)		test for blitter ready
	bne.s	testblit		branch it not
	rts

*---------------------------------------

wobble_fader
	lea	wobstrt(pc),a0		point to list in copper
	lea	wobblelist(pc),a1	point to table holding numbers
	move.w	wobpos,d0		get position of wobble list
	move.w	#woblines-1,d7		get number of lines to wobble
wobloop
	moveq.w	#0,d2			clear d2
	move.b	(a1,d0.w),d1		get next number
	move.w	d1,6(a0)		place it in bplcon1
	add.l	#8,a0			add on to next bplcon1
	add.w	#1,d0			add 1 to d0
	cmp.w	#wobend,d0		is it end of the list
	bne.s	wobnoend		branch if not equal
	move.w	#0,d0			clear d0
wobnoend
	dbra	d7,wobloop		decrement no of lines
	add.w	#1,wobpos		add on 1 to position
	cmp.w	#wobend,wobpos		is it end of list
	bne.s	wobquit			branch if not equal
	move.w	#0,wobpos			restart list
wobquit
	rts

*---------------------------------------

	include	source:axal/pt-playabn.s

*---------------------------------------

gfxname		dc.b	'graphics.library',0
		even
gfxbase		dc.l	0
oldcopper	dc.l	0
stack		dc.l	0
fd_ccount	dc.l	0
fd_txtpos	dc.l	0
sysine		dc.w	0
sysinr		dc.w	0
sysdma		dc.w	0
wobpos		dc.w	0
fd_whichpic	dc.b	0
fd_counter	dc.b	10
		even
checker		dc.b	"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
		dc.b	"0123456789 ?.,[]':;-+/%*()!^",0
		dc.b	"Fuck You Lamer!!!"
		even
;		dc.b	"12345678901234567890"
fd_txt		dc.b	"  AXAL OF ARMALYTE  "
		dc.b	"  PRESENTS TO YOU   "
		dc.b	"   ON THE 1-9-91    "
		dc.b	"AT THE TIME OF 20:14"
		dc.b	" A NEW WAY TO GREET "
		dc.b	"                    "
		dc.b	"ARMALYTE FLIP-FLOPS:"
		dc.b	"MAGNUM/ABNORMAL DATA"
		dc.b	"ROY + TREV/WASTELAND"
		dc.b	"    ROY/CATCH 22    "
		dc.b	"     KEN/DIGITAL    "
		dc.b	"      ABN/FOFT      "
		dc.b	"     SUBLIMINAL     "
		dc.b	"      DEADMAN       "
		dc.b	"     MARK MEANY     "
		dc.b	"      RAISTLIN      "
		dc.b	"    DAVE EDWARDS    "
		dc.b	"    BLAINE EVANS    "
		dc.b	"   STEVE MARSHALL   "
		dc.b	"     D. BARNARD     "
		dc.b	"     MIKE CROSS     "
		dc.b	"                    "
		dc.b	" ALL OTHER CONTACTS "
		dc.b	"--------------------"
		dc.b	"   CONTACT US AT:   "
		dc.b	"  AXAL OF ARMALYTE  "
		dc.b	"    12 DUNDAS WAY   "
		dc.b	"      GATESHEAD     "
		dc.b	"    TYNE AND WEAR   "
		dc.b	"--------------------"
		dc.b	" MAVRICK OF ARMALYTE"
		dc.b	" 12 KING EDWARD ST. "
		dc.b	"      GATESHEAD     "
		dc.b	"    TYNE AND WEAR   "
		dc.b	"--------------------"
		dc.b	"OR COME AND TALK TO "
		dc.b	"    US AT THE:-     "
		dc.b	" TUESDAY NIGHT CLUB "
		dc.b	"   IN WASHINGTON    "
		dc.b	"                    ",0
		even


*---------------------------------------

axlcopper
	dc.w	bplcon1,0,bplcon2,0
	dc.w	bpl1mod,0,bpl2mod,0
	dc.w	diwstrt,$2c71,diwstop,$2cc1
	dc.w	ddfstrt,$0030,ddfstop,$00d0
	dc.w	beamcon0,$20
	dc.w	bplcon0,$2200
	dc.w	bpl1pth
top1h	dc.w	0,bpl1ptl
top1l	dc.w	0,bpl2pth
top2h	dc.w	0,bpl2ptl
top2l	dc.w	0
	dc.w	$180,$000,$182
fd_col	dc.w	$000,$184,$fff,$186,$fff
	dc.w	spr0pth,0,spr0ptl,0,spr1pth,0,spr1ptl,0
	dc.w	spr2pth,0,spr2ptl,0,spr3pth,0,spr3ptl,0
	dc.w	spr4pth,0,spr4ptl,0,spr5pth,0,spr5ptl,0
	dc.w	spr6pth,0,spr6ptl,0,spr7pth,0,spr7ptl,0
wobstrt
	dc.w	$2c01,$fffe,bplcon1,$0,$2d01,$fffe,bplcon1,$0
	dc.w	$2e01,$fffe,bplcon1,$0,$2f01,$fffe,bplcon1,$0
	dc.w	$3001,$fffe,bplcon1,$0,$3101,$fffe,bplcon1,$0
	dc.w	$3201,$fffe,bplcon1,$0,$3301,$fffe,bplcon1,$0
	dc.w	$3401,$fffe,bplcon1,$0,$3501,$fffe,bplcon1,$0
	dc.w	$3601,$fffe,bplcon1,$0,$3701,$fffe,bplcon1,$0
	dc.w	$3801,$fffe,bplcon1,$0,$3901,$fffe,bplcon1,$0
	dc.w	$3a01,$fffe,bplcon1,$0,$3b01,$fffe,bplcon1,$0
	dc.w	$3e01,$fffe,bplcon0,$200
	dc.w	$ffff,$fffe

woblines	equ	16

*---------------------------------------

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
	dc.b	$f0,$f0,$e1,$e1,$d2,$d2,$c3,$c3,$b4,$b4,$a5,$a5,$96,$96
	dc.b	$87,$87,$78,$78,$69,$69,$5a,$5a,$4b,$4b,$3c,$3c,$2d,$2d
	dc.b	$1e,$1e,$0f,$0f,$1e,$1e,$2d,$2d,$3c,$3c,$4b,$4b,$5a,$5a
	dc.b	$69,$69,$78,$78,$87,$87,$96,$96,$a5,$a5,$b4,$b4,$c3,$c3
	dc.b	$d2,$d2,$e1,$e1
	dc.b	$f0,$f0,$e1,$e1,$d2,$d2,$c3,$c3,$b4,$b4,$a5,$a5,$96,$96
	dc.b	$87,$87,$78,$78,$69,$69,$5a,$5a,$4b,$4b,$3c,$3c,$2d,$2d
	dc.b	$1e,$1e,$0f,$0f,$1e,$1e,$2d,$2d,$3c,$3c,$4b,$4b,$5a,$5a
	dc.b	$69,$69,$78,$78,$87,$87,$96,$96,$a5,$a5,$b4,$b4,$c3,$c3
	dc.b	$d2,$d2,$e1,$e1
	dc.b	$f0,$f0,$e1,$e1,$d2,$d2,$c3,$c3,$b4,$b4,$a5,$a5,$96,$96
	dc.b	$87,$87,$78,$78,$69,$69,$5a,$5a,$4b,$4b,$3c,$3c,$2d,$2d
	dc.b	$1e,$1e,$0f,$0f,$1e,$1e,$2d,$2d,$3c,$3c,$4b,$4b,$5a,$5a
	dc.b	$69,$69,$78,$78,$87,$87,$96,$96,$a5,$a5,$b4,$b4,$c3,$c3
	dc.b	$d2,$d2,$e1,$e1
	dc.b	$f0,$f0,$e1,$e1,$d2,$d2,$c3,$c3,$b4,$b4,$a5,$a5,$96,$96
	dc.b	$87,$87,$78,$78,$69,$69,$5a,$5a,$4b,$4b,$3c,$3c,$2d,$2d
	dc.b	$1e,$1e,$0f,$0f,$1e,$1e,$2d,$2d,$3c,$3c,$4b,$4b,$5a,$5a
	dc.b	$69,$69,$78,$78,$87,$87,$96,$96,$a5,$a5,$b4,$b4,$c3,$c3
	dc.b	$d2,$d2,$e1,$e1
	dc.b	$f0,$f0,$e1,$e1,$d2,$d2,$c3,$c3,$b4,$b4,$a5,$a5,$96,$96
	dc.b	$87,$87,$78,$78,$69,$69,$5a,$5a,$4b,$4b,$3c,$3c,$2d,$2d
	dc.b	$1e,$1e,$0f,$0f,$1e,$1e,$2d,$2d,$3c,$3c,$4b,$4b,$5a,$5a
	dc.b	$69,$69,$78,$78,$87,$87,$96,$96,$a5,$a5,$b4,$b4,$c3,$c3
	dc.b	$d2,$d2,$e1,$e1
	dc.b	$f0,$f0,$f0,$e1,$f0,$d2,$f0,$c3,$f0,$b4,$f0,$a5,$f0,$96
	dc.b	$f0,$87,$f0,$78,$f0,$69,$f0,$5a,$f0,$4b,$f0,$3c,$f0,$2d
	dc.b	$f0,$1e
	dc.b	$f0,$0f,$e1,$1e,$d2,$2d,$c3,$3c,$b4,$4b,$a5,$5a,$96,$69
	dc.b	$87,$78,$78,$87,$69,$96,$5a,$a5,$4b,$b4,$3c,$c3,$2d,$d2
	dc.b	$1e,$e1,$0f,$f0,$1e,$e1,$2d,$d2,$3c,$c3,$4b,$b4,$5a,$a5
	dc.b	$69,$96,$78,$87,$87,$78,$96,$69,$a5,$5a,$b4,$4b,$c3,$3c
	dc.b	$d2,$2d,$e1,$1e,$f0,$1e,$f0,$2d
	dc.b	$f0,$3c,$f0,$4b,$f0,$5a,$f0,$69,$f0,$78,$f0,$87,$f0,$96
	dc.b	$f0,$a5,$f0,$b4,$f0,$c3,$f0,$d2,$f0,$e1,$f0
wobend	equ	*-wobblelist
	even

*---------------------------------------

		incdir	source:bitmaps/
fd_screen1	dcb.b	(42*18)
fd_screen2	dcb.b	(42*18)
		even
fd_font		incbin	armfont16x16x1
module		incbin	source:modules/mod.music

