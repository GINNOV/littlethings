; Our first pile of dung. (C) Revelation 1990.

; As the original music module was not supplied I have used the module
;Mike Cross sent in. Hope this does not offend anybody. Send the music in
;for next month Simon and I will include it on the disk if there is room.
;                                           M.Meany Aug 90

	section bobs,code_c

start:	movem.l		d0-d7/a0-a6,-(a7)
	jsr		mt_init
	bsr		initcop		;Init CopperList
	lea		gfxname,a1	;Name of graphics library
	move.l		4,a6		;Execbase
	jsr		-132(a6)	;Forbid->No Multitasking
	jsr		-408(a6)	;Open Library
	move.l		d0,gfxbase	;Rememer graphics base
	lea		intname,a1	;Name of intuition lib.
	jsr		-408(a6)	;Open Library
	move.l		d0,intbase	;Remember intuition base
	move.l		intbase,a6
	lea		osargs,a0	;Pointer to newscreen struct.
	jsr		-198(a6)	;Open Screen
	move.l		d0,screenbase	;Pointer to screen struct
	beq		quit		;Could I open it ??
	add.l		#84,d0		;Screenbase+84
	move.l		d0,rastport	;Is Rastport
	move.l		gfxbase,a6	
	move.l		rastport,a1
	clr.l		d0		;Color=0
	jsr		-234(a6)	;Setrast->Clear Screen
	move.l		screenbase,a0
	move.l		192(a0),d0	;Pointer to first bitplane
	move.w		d0,planes+6	;Low word in copperlist
	swap		d0
	move.w		d0,planes+2	;High word in copperlist
	move.l		gfxbase,a0	;gfxbase+$32=pointer to clist
	move.l		$32(a0),oldcop	;save old copperlist
	move.l		#newcop,$32(a0)	;My own copperlist
	move.l		$6c,oldirq	;Save old VBL irq pointer
	move.l		#newirq,$6c	;my VBL interrupt
wait_raster:
	cmp.b	#200,$dff006
	bne.s	wait_raster
	jsr	mt_music
	btst	#6,$bfe001
	bne.s	wait_raster

	move.l		oldirq,$6c	;Restore interrupt
	move.l		gfxbase,a0	;restore
	move.l		oldcop,$32(a1)	;old copperlist
	move.l		intbase,a6
	move.l		screenbase,a0
	jsr		-66(a6)		;Close the screen
	move.l		4,a6
	jsr		-138(a6)	;Permit->Multitasking on
quit:	movem.l		(a7)+,d0-d7/a0-a6
	jsr		mt_end
	rts

initcop:move.l		#logoplane+3,d0
	move.l		#logoplane+3,d1
	move.w		d0,pl+6		;put logoplane
	swap		d0		;pointers
	move.w		d1,pl+14	;in copperlist
	swap		d1
	move.w		d0,pl+2
	move.w		d1,pl+10
	rts

newirq:	movem.l		d0-d7/a0-a6,-(a7);Save regs
	bsr		scroll
	movem.l		(a7)+,d0-d7/a0-a6;Restore regs
	dc.w		$4ef9		;Code for 'JUMP'
oldirq:	dc.l		0		;Jump to oldirq

scroll:	move.l		gfxbase,a6
	move.l		#3,d0		;dx, 3 pixels to the left
	clr.l		d1		;dy
	move.l		#0,d2		;min x
	move.l		#0,d3		;min y
	move.l		#383,d4		;max x
	move.l		#20,d5		;max y
	move.l		rastport,a1	;rastport pointer
	jsr		-396(a6)	;ScrollRaster
	subq.w		#1,scrcount	;Counter for newtext
	beq		newtext		;is zero->new char
	rts				;else->bye ??
newtext:move.w		#5,scrcount	;newtext delay set
	move.l		gfxbase,a6
	move.l		rastport,a1
	move.l		#374,d0		;x
	move.l		#10,d1		;y
	jsr		-240(a6)	;move
	move.l		stringpointer,a0;pointer to string
	move.l		#1,d0		;1 char
	jsr		-60(a6)
	addq.l		#1,stringpointer;Next char
	cmpi.l		#endstring,stringpointer
	bne		notend		;end of string reached
	move.l		#string,stringpointer;Start al over
notend:	rts

newcop:	dc.w	$0092,$0038,$0094,$00d0	;DFFSTART,DFFSTOP->Normal
	dc.w	$008e,$296a,$0090,$29fa	;DIWSTART,DIWSTOP
	dc.w	$0096,$0020,$0100,$0000	;Sprites off,planes off
	dc.w	$0108,$0028,$010a,$0028	;BPL1MOD,BPL2MOD
	dc.w	$0180,$0000,$0182,$0f00
	dc.w	$0184,$0f00,$0186,$0f00 ;Colors
pl:	dc.w	$00e0,$0000,$00e2,$0000	;Bitplane 1 pointers
	dc.w	$00e4,$0000,$00e6,$0000	;Bitplane 2 pointers
	dc.w	$3001,$fffe		;wait till line 48 = $30
	dc.w	$0100,$2000		;2 bitplanes on
	dc.w	$ff01,$fffe		;wait till line 255= $ff
	dc.w	$0100,$0000		;all bitplanes of
	dc.w	$ffdf,$fffe		;wait till last NTSC line

	dc.w	$0092,$0028,$0094,$00d8	;DFFSTART,DFFSTOP->OverScan
	dc.w	$0108,$0002,$010a,$0002	;BPL1MOD,BPL2MOD
	dc.w	$0180,$0006,$0182,$0f00	;Colors
planes:	dc.w	$00e0,$0000,$00e2,$0000	;Plane1 low,high word
	dc.w	$0001,$fffe		;Wait till line 80 reached
	dc.w	$0100,$1000		;Bitplane 1 on
	dc.w	$0107,$fffe,$0182,$000f
	dc.w	$0207,$fffe,$0182,$020f
	dc.w	$0307,$fffe,$0182,$040f
	dc.w	$0407,$fffe,$0182,$060f
	dc.w	$0507,$fffe,$0182,$070f
	dc.w	$0607,$fffe,$0182,$090f
	dc.w	$0707,$fffe,$0182,$0b0f
	dc.w	$0807,$fffe,$0182,$0d0f
	dc.w	$0907,$fffe,$0182,$0f0f
	dc.w	$0a07,$fffe,$0182,$0f0c
	dc.w	$0b07,$fffe,$0182,$0f0a
	dc.w	$0c07,$fffe,$0182,$0f08
	dc.w	$0d07,$fffe,$0182,$0f07
	dc.w	$0e07,$fffe,$0182,$0f05
	dc.w	$0f07,$fffe,$0182,$0f03	;Color changes in scroll
	dc.w	$1001,$fffe		;Wait till line 208 reached
	dc.w	$0100,$0000		;Bitplanes off
	dc.w	$0180,$0000		;background=black
	dc.w	$ffff,$fffe		;Wait till end

logoplane:
	incbin	"source_1:bitmaps/test.bm"
	ds.b	10240			;memory for the bob bitplane

osargs:	dc.w	0,0,384,16		;x-min,y-min,width,height
	dc.w	1			;depth 1 bitplane
	dc.b	0,1			;detailpen,blockpen
	dc.w	0,15			;viewmodes,type=customscreen
	dc.l	textattr,0		;textattr,title=none
	dc.l	0,0			;gadgets,bitmap
textattr:
	dc.l	fontname		;Fontname
	dc.w	9			;fontsize
	dc.b	6			;Style=bold italic
	dc.b	1			;flags=romfont

scrcount:	dc.w	1
oldcop:		dc.l	0
gfxbase:	dc.l	0
intbase:	dc.l	0
rastport:	dc.l	0
screenbase:	dc.l	0
stringpointer:	dc.l	string
intname:	dc.b	"intuition.library",0
gfxname:	dc.b	"graphics.library",0
fontname:	dc.b	"topaz.font",0
string:
 DC.B   " 5         4         3           2          1        "
 DC.B	" YAAAAAAAAAAAHOOOOOOOOOOOO!!!!   THE FIRST, AND AT THE SPEED WE'RE"
 dc.b	" GOING, PROBABLY THE ONLY SCROLLER FROM  >THE REVELATION CREW!!< "
 DC.B 	"      FIRST, HOW ABOUT A FEW CREDITS?...    STUNNING (?) CODING"
 dc.b	" BY  >THE NIPPER<  AND  >WIG<  OF  >REVELAION<.  THE AWESOME SOUNDTRACK"
 dc.b	" BY OUR HIP MUSICIAN  >PROFESSOR BASS<, CALLED  D E L T A B E A T  (HE"
 DC.B	" ASKED ME TO SPACE IT OUT LIKE THAT!!!).        NOW, IT'S GREETS TIME!!!...."
 dc.b	"       SOGGY DISCS FLYING TO  .. MIKE AND ANDY OF PHANTASM - THANKS"
 dc.b	" FOR ALL THE HIP DISCS AND THE OFFER OF CODING HELP!!   ..  PAUL / NBS -"
 dc.b	" YOU'RE A GREAT CONTACT AND FRIEND, KEEP UP THE GOOD WORK.  ..  "
 dc.b	"BEATMASTER - MANY HIP REGARDS BM, ONE IN A MILLION.  ..  ALL AT"
 dc.b	" SOFTVILLE - THANKS FOR YOUR UNDYING SUPPORT OF MY MAGAZINE, I WILL"
 dc.b	" REPAY YOU SOMEDAY (EITHER IN CASH OR KINDNESS. JUST WAIT UNTIL I'M"
 dc.b	" CHANCELLOR OF THE EXCHEQUER!!).  ..  MARK / CODERS CLUB - DISC 3"
 dc.b	" INSPIRED WIG AND I TO ATTEMPT THIS LITTLE INTRO/DEMO, KEEP UP THE"
 dc.b	" GOOD WORK, AND I'VE GOT SOME CODE YOU CAN HAVE NOW!!  ..  THAT JUST ABOUT"
 dc.b	" WRAPS UP THE PERSONAL GREETS FROM ME (NIPPER) FOR KNOW, SO HERE"
 dc.b	" ARE MESSAGES TO PEOPLE WE DON'T ACTUALLY KNOW BUT WANT TO GREET ANYWAY.....  "
 DC.B	"    DR AWESOME - COOL GUY!  ..  MAHONEY & KAKTUS - LOVE NOISETRACKER!"
 DC.B	"  ..  NICO FRANCOIS - POWERPACKER IS THE BEST!  ..  SHARE AND ENJOY - "
 DC.B	" THE BEST UK CREW AROUND, WE ADMIRE YOU!!      ..AND THAT'S IT! "
 DC.B	"THE MUSIC IS ABOUT TO LOOP BACK SO ALL THAT REMAINS IS IF YOU"
 DC.B	" ARE VERY BRAVE THEN WRITE:  140 MAIN ROAD,  MOULTON,  NORTHWICH,  CHESHIRE,  "
 DC.B	"CW9 9PL,  ENGLAND.       NIP OFF...       "
endstring:
even


**************************************
*   NoisetrackerV1.0 replayroutine   *
* Mahoney & Kaktus - HALLONSOFT 1989 *
**************************************


mt_init:lea	mt_data,a0
	bset	#1,$bfe001
	move.l	a0,a1
	add.l	#$3b8,a1
	moveq	#$7f,d0
	moveq	#0,d1
mt_loop:move.l	d1,d2
	subq.w	#1,d0
mt_lop2:move.b	(a1)+,d1
	cmp.b	d2,d1
	bgt.s	mt_loop
	dbf	d0,mt_lop2
	addq.b	#1,d2

	lea	mt_samplestarts(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2
	add.l	#$43c,d2
	add.l	a0,d2
	move.l	d2,a2
	moveq	#$1e,d0
mt_lop3:clr.l	(a2)
	move.l	a2,(a1)+
	moveq	#0,d1
	move.w	42(a0),d1
	asl.l	#1,d1
	add.l	d1,a2
	add.l	#$1e,a0
	dbf	d0,mt_lop3

	or.b	#$2,$bfe001
	move.b	#$6,mt_speed
	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	clr.b	mt_songpos
	clr.b	mt_counter
	clr.w	mt_pattpos
	rts

mt_end:	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	move.w	#$f,$dff096
	rts

mt_music:
	movem.l	d0-d4/a0-a3/a5-a6,-(a7)
	lea	mt_data,a0
	addq.b	#$1,mt_counter
	move.b	mt_counter,D0
	cmp.b	mt_speed,D0
	blt.s	mt_nonew
	clr.b	mt_counter
	bra	mt_getnew

mt_nonew:
	lea	mt_voice1(pc),a6
	lea	$dff0a0,a5
	bsr	mt_checkcom
	lea	mt_voice2(pc),a6
	lea	$dff0b0,a5
	bsr	mt_checkcom
	lea	mt_voice3(pc),a6
	lea	$dff0c0,a5
	bsr	mt_checkcom
	lea	mt_voice4(pc),a6
	lea	$dff0d0,a5
	bsr	mt_checkcom
	bra	mt_endr

mt_arpeggio:
	moveq	#0,d0
	move.b	mt_counter,d0
	divs	#$3,d0
	swap	d0
	cmp.w	#$0,d0
	beq.s	mt_arp2
	cmp.w	#$2,d0
	beq.s	mt_arp1

	moveq	#0,d0
	move.b	$3(a6),d0
	lsr.b	#4,d0
	bra.s	mt_arp3
mt_arp1:moveq	#0,d0
	move.b	$3(a6),d0
	and.b	#$f,d0
	bra.s	mt_arp3
mt_arp2:move.w	$10(a6),d2
	bra.s	mt_arp4
mt_arp3:asl.w	#1,d0
	moveq	#0,d1
	move.w	$10(a6),d1
	lea	mt_periods(pc),a0
	moveq	#$24,d7
mt_arploop:
	move.w	(a0,d0.w),d2
	cmp.w	(a0),d1
	bge.s	mt_arp4
	addq.l	#2,a0
	dbf	d7,mt_arploop
	rts
mt_arp4:move.w	d2,$6(a5)
	rts

mt_getnew:
	lea	mt_data,a0
	move.l	a0,a3
	move.l	a0,a2
	add.l	#$c,a3
	add.l	#$3b8,a2
	add.l	#$43c,a0

	moveq	#0,d0
	move.l	d0,d1
	move.b	mt_songpos,d0
	move.b	(a2,d0.w),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.w	mt_pattpos,d1
	clr.w	mt_dmacon

	lea	$dff0a0,a5
	lea	mt_voice1(pc),a6
	bsr.s	mt_playvoice
	lea	$dff0b0,a5
	lea	mt_voice2(pc),a6
	bsr.s	mt_playvoice
	lea	$dff0c0,a5
	lea	mt_voice3(pc),a6
	bsr.s	mt_playvoice
	lea	$dff0d0,a5
	lea	mt_voice4(pc),a6
	bsr.s	mt_playvoice
	bra	mt_setdma

mt_playvoice:
	move.l	(a0,d1.l),(a6)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	$2(a6),d2
	and.b	#$f0,d2
	lsr.b	#4,d2
	move.b	(a6),d0
	and.b	#$f0,d0
	or.b	d0,d2
	tst.b	d2
	beq.s	mt_setregs
	moveq	#0,d3
	lea	mt_samplestarts(pc),a1
	move.l	d2,d4
	subq.l	#$1,d2
	asl.l	#2,d2
	mulu	#$1e,d4
	move.l	(a1,d2.l),$4(a6)
	move.w	(a3,d4.l),$8(a6)
	move.w	$2(a3,d4.l),$12(a6)
	move.w	$4(a3,d4.l),d3
	tst.w	d3
	beq.s	mt_noloop
	move.l	$4(a6),d2
	asl.w	#1,d3
	add.l	d3,d2
	move.l	d2,$a(a6)
	move.w	$4(a3,d4.l),d0
	add.w	$6(a3,d4.l),d0
	move.w	d0,8(a6)
	move.w	$6(a3,d4.l),$e(a6)
	move.w	$12(a6),$8(a5)
	bra.s	mt_setregs
mt_noloop:
	move.l	$4(a6),d2
	add.l	d3,d2
	move.l	d2,$a(a6)
	move.w	$6(a3,d4.l),$e(a6)
	move.w	$12(a6),$8(a5)
mt_setregs:
	move.w	(a6),d0
	and.w	#$fff,d0
	beq	mt_checkcom2
	move.b	$2(a6),d0
	and.b	#$F,d0
	cmp.b	#$3,d0
	bne.s	mt_setperiod
	bsr	mt_setmyport
	bra	mt_checkcom2
mt_setperiod:
	move.w	(a6),$10(a6)
	and.w	#$fff,$10(a6)
	move.w	$14(a6),d0
	move.w	d0,$dff096
	clr.b	$1b(a6)

	move.l	$4(a6),(a5)
	move.w	$8(a6),$4(a5)
	move.w	$10(a6),d0
	and.w	#$fff,d0
	move.w	d0,$6(a5)
	move.w	$14(a6),d0
	or.w	d0,mt_dmacon
	bra	mt_checkcom2

mt_setdma:
	move.w	#$12c,d0
mt_wait:dbf	d0,mt_wait
	move.w	mt_dmacon,d0
	or.w	#$8000,d0
	move.w	d0,$dff096
	move.w	#$12c,d0
mt_wai2:dbf	d0,mt_wai2
	lea	$dff000,a5
	lea	mt_voice4(pc),a6
	move.l	$a(a6),$d0(a5)
	move.w	$e(a6),$d4(a5)
	lea	mt_voice3(pc),a6
	move.l	$a(a6),$c0(a5)
	move.w	$e(a6),$c4(a5)
	lea	mt_voice2(pc),a6
	move.l	$a(a6),$b0(a5)
	move.w	$e(a6),$b4(a5)
	lea	mt_voice1(pc),a6
	move.l	$a(a6),$a0(a5)
	move.w	$e(a6),$a4(a5)

	add.w	#$10,mt_pattpos
	cmp.w	#$400,mt_pattpos
	bne.s	mt_endr
mt_nex:	clr.w	mt_pattpos
	clr.b	mt_break
	addq.b	#1,mt_songpos
	and.b	#$7f,mt_songpos
	move.b	mt_songpos,d1
	cmp.b	mt_data+$3b6,d1
	bne.s	mt_endr
	clr.b	mt_songpos
mt_endr:tst.b	mt_break
	bne.s	mt_nex
	movem.l	(a7)+,d0-d4/a0-a3/a5-a6
	rts

mt_setmyport:
	move.w	(a6),d2
	and.w	#$fff,d2
	move.w	d2,$18(a6)
	move.w	$10(a6),d0
	clr.b	$16(a6)
	cmp.w	d0,d2
	beq.s	mt_clrport
	bge.s	mt_rt
	move.b	#$1,$16(a6)
	rts
mt_clrport:
	clr.w	$18(a6)
mt_rt:	rts

mt_myport:
	move.b	$3(a6),d0
	beq.s	mt_myslide
	move.b	d0,$17(a6)
	clr.b	$3(a6)
mt_myslide:
	tst.w	$18(a6)
	beq.s	mt_rt
	moveq	#0,d0
	move.b	$17(a6),d0
	tst.b	$16(a6)
	bne.s	mt_mysub
	add.w	d0,$10(a6)
	move.w	$18(a6),d0
	cmp.w	$10(a6),d0
	bgt.s	mt_myok
	move.w	$18(a6),$10(a6)
	clr.w	$18(a6)
mt_myok:move.w	$10(a6),$6(a5)
	rts
mt_mysub:
	sub.w	d0,$10(a6)
	move.w	$18(a6),d0
	cmp.w	$10(a6),d0
	blt.s	mt_myok
	move.w	$18(a6),$10(a6)
	clr.w	$18(a6)
	move.w	$10(a6),$6(a5)
	rts

mt_vib:	move.b	$3(a6),d0
	beq.s	mt_vi
	move.b	d0,$1a(a6)

mt_vi:	move.b	$1b(a6),d0
	lea	mt_sin(pc),a4
	lsr.w	#$2,d0
	and.w	#$1f,d0
	moveq	#0,d2
	move.b	(a4,d0.w),d2
	move.b	$1a(a6),d0
	and.w	#$f,d0
	mulu	d0,d2
	lsr.w	#$6,d2
	move.w	$10(a6),d0
	tst.b	$1b(a6)
	bmi.s	mt_vibmin
	add.w	d2,d0
	bra.s	mt_vib2
mt_vibmin:
	sub.w	d2,d0
mt_vib2:move.w	d0,$6(a5)
	move.b	$1a(a6),d0
	lsr.w	#$2,d0
	and.w	#$3c,d0
	add.b	d0,$1b(a6)
	rts

mt_nop:	move.w	$10(a6),$6(a5)
	rts

mt_checkcom:
	move.w	$2(a6),d0
	and.w	#$fff,d0
	beq.s	mt_nop
	move.b	$2(a6),d0
	and.b	#$f,d0
	tst.b	d0
	beq	mt_arpeggio
	cmp.b	#$1,d0
	beq.s	mt_portup
	cmp.b	#$2,d0
	beq	mt_portdown
	cmp.b	#$3,d0
	beq	mt_myport
	cmp.b	#$4,d0
	beq	mt_vib
	move.w	$10(a6),$6(a5)
	cmp.b	#$a,d0
	beq.s	mt_volslide
	rts

mt_volslide:
	moveq	#0,d0
	move.b	$3(a6),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	mt_voldown
	add.w	d0,$12(a6)
	cmp.w	#$40,$12(a6)
	bmi.s	mt_vol2
	move.w	#$40,$12(a6)
mt_vol2:move.w	$12(a6),$8(a5)
	rts

mt_voldown:
	moveq	#0,d0
	move.b	$3(a6),d0
	and.b	#$f,d0
	sub.w	d0,$12(a6)
	bpl.s	mt_vol3
	clr.w	$12(a6)
mt_vol3:move.w	$12(a6),$8(a5)
	rts

mt_portup:
	moveq	#0,d0
	move.b	$3(a6),d0
	sub.w	d0,$10(a6)
	move.w	$10(a6),d0
	and.w	#$fff,d0
	cmp.w	#$71,d0
	bpl.s	mt_por2
	and.w	#$f000,$10(a6)
	or.w	#$71,$10(a6)
mt_por2:move.w	$10(a6),d0
	and.w	#$fff,d0
	move.w	d0,$6(a5)
	rts

mt_portdown:
	clr.w	d0
	move.b	$3(a6),d0
	add.w	d0,$10(a6)
	move.w	$10(a6),d0
	and.w	#$fff,d0
	cmp.w	#$358,d0
	bmi.s	mt_por3
	and.w	#$f000,$10(a6)
	or.w	#$358,$10(a6)
mt_por3:move.w	$10(a6),d0
	and.w	#$fff,d0
	move.w	d0,$6(a5)
	rts

mt_checkcom2:
	move.b	$2(a6),d0
	and.b	#$f,d0
	cmp.b	#$e,d0
	beq.s	mt_setfilt
	cmp.b	#$d,d0
	beq.s	mt_pattbreak
	cmp.b	#$b,d0
	beq.s	mt_posjmp
	cmp.b	#$c,d0
	beq.s	mt_setvol
	cmp.b	#$f,d0
	beq.s	mt_setspeed
	rts

mt_setfilt:
	rts
mt_pattbreak:
	not.b	mt_break
	rts
mt_posjmp:
	move.b	$3(a6),d0
	subq.b	#$1,d0
	move.b	d0,mt_songpos
	not.b	mt_break
	rts
mt_setvol:
	cmp.b	#$40,$3(a6)
	ble.s	mt_vol4
	move.b	#$40,$3(a6)
mt_vol4:move.b	$3(a6),$8(a5)
	rts
mt_setspeed:
	move.b	$3(a6),d0
	and.w	#$1f,d0
	beq.s	mt_rts2
	clr.b	mt_counter
	move.b	d0,mt_speed
mt_rts2:rts




mt_sin:
 dc.b $00,$18,$31,$4a,$61,$78,$8d,$a1,$b4,$c5,$d4,$e0,$eb,$f4,$fa,$fd
 dc.b $ff,$fd,$fa,$f4,$eb,$e0,$d4,$c5,$b4,$a1,$8d,$78,$61,$4a,$31,$18

mt_periods:
 dc.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c,$023a,$021a,$01fc,$01e0
 dc.w $01c5,$01ac,$0194,$017d,$0168,$0153,$0140,$012e,$011d,$010d,$00fe
 dc.w $00f0,$00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097,$008f,$0087
 dc.w $007f,$0078,$0071,$0000,$0000

mt_speed:	dc.b	$6
mt_songpos:	dc.b	$0
mt_pattpos:	dc.w	$0
mt_counter:	dc.b	$0

mt_break:	dc.b	$0
mt_dmacon:	dc.w	$0
mt_samplestarts:dcb.l	$1f,0
mt_voice1:	dcb.w	10,0
		dc.w	$1
		dcb.w	3,0
mt_voice2:	dcb.w	10,0
		dc.w	$2
		dcb.w	3,0
mt_voice3:	dcb.w	10,0
		dc.w	$4
		dcb.w	3,0
mt_voice4:	dcb.w	10,0
		dc.w	$8
		dcb.w	3,0

mt_data: incbin "source_1:modules/mod.music"
