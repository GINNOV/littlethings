* DATE:	23/02/92
* TIME:	15:12
* NAME:	Hertz Switch
* CODE:	AXAL
* NOTE:	WILL CHECK SCREEN UPDATE AND SWITCH TO THE OTHER

*---------------------------------------

	move.l	$4.w,a6			execbase
	lea	dosname(pc),a1		lib to open
	jsr	-552(a6)		open it
	move.l	d0,dosbase		save it
	beq	dos_error1		quit if fail to open

	move.l	d0,a6			copy pointer
	jsr	-60(a6)			get cliout put
	move.l	d0,cliout		and store it
	beq	dos_error2		quit if not opened

	move.l	#prgheadtxt,d2		address of text
	move.l	#prgheadend,d3		length of text
	bsr	print_con		print the text

	lea	$dff000,a5		custom chips
	move.w	4(a5),d0		get info on agnus
	and.w	#$2000,d0		find which agnus
	bne.s	ok1			branch if ok

	move.l	#notworktxt,d2		point to text
	move.l	#notworkend,d3		get length
	bra.s	the_end			quit
ok1
	move.l	$4.w,a6			execbase
	cmpi.b	#50,530(a6)		test for pal screen
	beq	in_pal			if 50 then quit

	move.b	#50,530(a6)		make pal
	move.w	#$20,$dff1dc		50hz
	move.l	#paltxt,d2		text to print
	move.l	#palend,d3		length of text
	bra.s	the_end			print and quit
in_pal
	move.b	#60,530(a6)		make ntsc
	move.w	#$40,$dff1dc		set 60hz

	move.l	#ntsctxt,d2		text to print
	move.l	#ntscend,d3		length of text
the_end
	bsr	print_con		print it
dos_error2
	move.l	$4.w,a6			execbase
	move.l	dosbase,a1		point to lib
	jsr	-414(a6)		close lib
dos_error1
	moveq	#0,d0			no errors
	rts

*---------------------------------------
* Text to print in d2 - Length of text in d3

print_con
	move.l	cliout,d1		cli handler
	move.l	dosbase,a6		dos library
	jsr	-48(a6)			print text
	rts

*---------------------------------------

dosname		dc.b	"dos.library",0
		even
dosbase		dc.l	0
cliout		dc.l	0
prgheadtxt	dc.b	10,$9b,$20,$70,$9b,'0;33;42',$6d
		dc.b	"Switcher V1.1:",$9b,'3;32;40',$6d
		dc.b	"  Written by AXAL of ARMALYTE.",10,10
		dc.b	$9b,'0;31;40',$6d,$9b,$20,$70,0
prgheadend	equ	*-prgheadtxt
		even
paltxt		dc.b	$9b,$20,$70,$9b,'0;33;40',$6d
		dc.b	"Switching to PAL screen."
		dc.b	$9b,'0;31;40',$6d,$9b,$20,$70,10,10,0
palend		equ	*-paltxt
		even
ntsctxt		dc.b	$9b,$20,$70,$9b,'0;33;40',$6d
		dc.b	"Switching to NTSC screen."
		dc.b	$9b,'0;31;40',$6d,$9b,$20,$70,10,10,0
ntscend		equ	*-ntsctxt
		even
notworktxt	dc.b	$9b,$20,$70,$9b,'0;31;40',$6d
		dc.b	"A non-ECS Agnus has been found.",10,10
		dc.b	"Problem  : You cannot switch hertz.",10
		dc.b	"Solution : Buy a new Amiga!"
		dc.b	$9b,'0;31;40',$6d,$9b,$20,$70,10,10,0
notworkend	equ	*-notworktxt
		even
