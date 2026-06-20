;   "comm4.3.s"      Jack Young  14th October 1990
;
;   Receives pictures to be transfered from Spectrum through RS232
;   The Spectrum must send raw screen data (6.75K)
;   This program receives a Spectrum screen,
;      exactly as it is laid out in Spectrum memory.
;   Updates the picture as the data comes in.
;   Interprets ink, paper and bright - no flash
;
;   Uses hardware to receive data through RS232
;   Disables multitasking.
;   Sets up a standard intuition screen though operating system. 256 x 192 *4
;   Screens can be saved/printed with ScreenX
;   All libraries used are internal
;   break: right mouse button
;   exit: close gadget on top-left of screen
;   Default baud: 9600
;
;   Can be run from Workbench or CLI.

;   From CLI:
;   A parameter string may be passed after the command name,
;      to set the baud rate.
;      These must be ASCII digits from 0 to 9
;      If a non-digit character (including LF) is found,
;         it terminates the number.
;      If no number is given, the default baud is used.
;      The number passed is the desired baud divided by 100
;         e.g for 9600 baud, enter "96"
;   N.B. This version crashes if the command line does not start with a digit
;        However, if there are no characters in the command line, the default
;        baud rate is used.


;Hardware registers:
POTGOR	= $016
SERPER	= $032
SERDAT	= $030
SERDATR	= $018
ADKCON	= $09E
ADKCONR	= $010
INTREQ	= $09C


;Exec library:
ExecBase = 4

Disable	= -120
Enable	= -126
Forbid	= -132
Permit	= -138
FindTask= -294
WaitPort= -384
GetMsg	= -372
CloseLibrary 	= -414
OpenLib 	= -408

;intuition library:
CloseScreen 	= -66
CloseWindow	= -72
OpenScreen 	= -198
OpenWindow	= -204

ViewPort = $2c
RastPort = $54
Plane0	= $c0
Plane1	= $c4
Plane2	= $c8
Plane3	= $cc

;graphics library:
SetRGB4	= -288

;dos library:
Open	= -30
Close	= -36
Read	= -42
Write	= -48
Input	= -54
Output	= -60
Seek	= -66
WaitForChar = -204

mode_rw	= 1004
mode_old = 1005
mode_new = 1006

offset_beginning = -1
offset_current = 0
offset_end = 1

start:
	cmp.w	#1,d0		;if d0<=1
	bhi	d0gt1
	lea	command,a0	;create a false CLI input
	move.l	#3,d0
d0gt1
	move.l	a0,starta0	
	move.l	d0,startd0

	move.l	ExecBase,a6
	sub.l	a1,a1		;clear A1
	jsr	FindTask(a6)	;get pointer to process structure
	move.l	d0,a4		;copy pointer to A4
	tst.l	$ac(a4)		;pr_CLI: CLI or Workbench?
	bne	fromCLI		;it was CLI!
fromWB:
	lea	$5c(a4),a0	;pr_MsgPort: MessagePort in A0
	jsr	WaitPort(a6)	;wait for message
	jsr	GetMsg(a6)
	bra	WBcont

fromCLI:
	bsr	setbaud		;set the baud rate from the CLI command line

WBcont:
	bsr	printbaud	;print the baud rat eon the title bar

;delay to allow the drive to switch off
	move.w	#25,d6
delayl2	move.w	#-1,d7
delayl	dbra	d7,delayl
	dbra	d6,delayl2

	bsr	openint
	cmp.l	#0,intbase
	beq	stop

	bsr	opengfx
	cmp.l	#0,gfxbase
	beq	cint

	bsr	opendos
	cmp.l	#0,dosbase
	beq	cgfx

	bsr	scropen
	bsr	main
	bsr	scrclose

	bsr	closedos
cgfx	bsr	closegfx
cint	bsr	closeint
stop	rts

openint:
	move.l	ExecBase,a6
	lea	IntName,a1
	jsr	OpenLib(a6)
	move.l	d0,intbase
	rts
IntName	dc.b	"intuition.library",0
	even
intbase	dc.l	0

closeint:
	move.l	ExecBase,a6
	move.l	intbase,a1
	jsr	CloseLibrary(a6)
	rts

opengfx:
	move.l	ExecBase,a6
	lea	GfxName,a1
	jsr	OpenLib(a6)
	move.l	d0,gfxbase
	rts
GfxName	dc.b	"graphics.library",0
	even
gfxbase	dc.l	0

closegfx:
	move.l	ExecBase,a6
	move.l	gfxbase,a1
	jsr	CloseLibrary(a6)
	rts

opendos:
	move.l	ExecBase,a6
	lea	DosName,a1
	jsr	OpenLib(a6)
	move.l	d0,dosbase
	rts
DosName	dc.b	"dos.library",0
	even
dosbase	dc.l	0

closedos:
	move.l	ExecBase,a6
	move.l	dosbase,a1
	jsr	CloseLibrary(a6)
	rts

scropen:
	move.l	intbase,a6

	lea	screen_info,a0
	jsr	OpenScreen(a6)
	move.l	d0,screenhd
	rts

scrclose:
	move.l	intbase,a6

	move.l	screenhd,a0
	jsr	CloseScreen(a6)
	rts

	even
d0sto	dc.l	0

openwin:
	move.l	intbase,a6
	lea	windowdef,a0
	jsr	OpenWindow(a6)
	move.l	d0,windowhd
	rts
closewin:
	move.l	intbase,a6
	move.l	windowhd,a0
	jsr	CloseWindow(a6)
	rts
windowhd dc.l	0

screen_info:
x_pos		dc.w	0
y_pos		dc.w	20
width		dc.w	256
height		dc.w	192
depth		dc.w	4
detail_pen	dc.b	7	;Colour of text, etc...
block_pen	dc.b	1	;Background colour
view_modes	dc.w	$002	;Representation mode
screen_type	dc.w	15	;Custom screen
font		dc.l	0	;Standard font
title		dc.l	sname	;Pointer to title text
gadgets		dc.l	0	;No gadgets
bitmap		dc.l	0	;No bitmap
sname		dc.b	"  Spectrum screen "
titlebaud	dc.b	"xxxxxbaud"
		dc.b	0
	even

windowdef:
	dc.w	0,0	;X & Y position
	dc.w	13,10	;width & height
	dc.b	0,15	;colours
	dc.l	$200	;IDCMP flags: CLOSEWINDOW
	dc.l	$8	;CLOSE gadget
	dc.l	0	;no other gadgets
	dc.l	0	;standard CheckMark
	dc.l	myname	;window name
screenhd dc.l	0	;screen pointer	
	dc.l	0	;not my bitmap
	dc.w	12,10	;Min width & height
	dc.w	12,10	;Max width & height
	dc.w	15	;screen type (custom)

main:
	bsr	setcols		;set up screen palette
	bsr	openwin

	move.l	ExecBase,a6	;library base
	move.l	#$dff000,a5	;hardware register base
	jsr	Forbid(a6)	;disable multitasking

	move.l	#35469,d0	;calculate baud rate
	move.w	baudrate,d1	;by dividing 35469 (PAL clock speed/100)
	divu	d1,d0		;by the buad rate/100 (9600=>96)
	subq.w	#1,d0		;and subtracting 1

	move.w	d0,SERPER(a5)	;set baud rate (9600 baud)

;*** PART1 ***	Get ink/paper data.
	move.l	screenhd,a0	;get
	move.l	Plane0(a0),a0	;address of screen (BPL3)
	move.w	#0,d0		;number of bytes 'loaded'

	move.b	#0,d5
loop1:
	bsr	getbyte		;get a byte
	move.w	d0,d1		;copy to d1
	rol.b	#3,d1		;turn d1 into actual
	rol.w	#5,d1		;screen offset
	rol.b	#3,d1
	rol.w	#8,d1

	move.b	d5,(a0,d1.w)	;'poke' byte

	btst.b	#2,POTGOR(a5)	;break check (right mouse button)
	beq	break2

	addq.w	#1,d0
	cmp.w	#6144,d0	;loop until counter = 6144
	bne	loop1

;*** PART2 ***	Set attributes
	move.w	#0,d0		;set counter/screen position
	move.l	screenhd,a0
	move.l	Plane3(a0),a3	;get bit-plane addresses
	move.l	Plane2(a0),a2	;get bit-plane addresses
	move.l	Plane1(a0),a1	;get bit-plane addresses
	move.l	Plane0(a0),a0	;get bit-plane addresses
loop2:
	bsr	getbyte
	move.b	d5,d6		;d5=ink
	lsr.b	#3,d6		;d6=paper and bright
	swap	d6
	move.b	d5,d6		;xopy to upper part of d6

	move.w	d0,d7
	lsl.w	#3,d7
	ror.b	#3,d7		;d7 is now offset for current top attr line

	move.w	#7,d1		;line-loop
attrlp1	move.b	(a0,d7.w),d5	;d5 is now original ink/paper data

	move.b	d6,d3
	ror.b	#1,d3
	asr.b	#7,d3		;d3=ink
	ror.b	#1,d6
	swap	d6
	move.b	d6,d4
	ror.b	#1,d4
	asr.b	#7,d4		;d4=paper
	ror.b	#1,d6
	swap	d6
	and.b	d5,d3
	not.b	d5
	and.b	d5,d4
	not.b	d5
	or.b	d3,d4		;byte to put onto bitplane
	move.b	d4,(a0,d7.w)

	move.b	d6,d3
	ror.b	#1,d3
	asr.b	#7,d3		;d3=ink
	ror.b	#1,d6
	swap	d6
	move.b	d6,d4
	ror.b	#1,d4
	asr.b	#7,d4		;d4=paper
	ror.b	#1,d6
	swap	d6
	and.b	d5,d3
	not.b	d5
	and.b	d5,d4
	not.b	d5
	or.b	d3,d4		;byte to put onto bitplane
	move.b	d4,(a1,d7.w)

	move.b	d6,d3
	ror.b	#1,d3
	asr.b	#7,d3		;d3=ink
	ror.b	#1,d6
	swap	d6
	move.b	d6,d4
	ror.b	#1,d4
	asr.b	#7,d4		;d4=paper
	ror.b	#1,d6
;	swap	d6
	and.b	d5,d3
	not.b	d5
	and.b	d5,d4
	not.b	d5
	or.b	d3,d4		;byte to put onto bitplane
	move.b	d4,(a2,d7.w)

	move.b	d6,d4
	ror.b	#1,d4
	asr.b	#7,d4		;d4=bright
	move.b	d4,(a3,d7.w)

	rol.b	#3,d6
	swap	d6
	rol.b	#3,d6

	btst.b	#2,POTGOR(a5)	;break check (right mouse button)
	beq	break2

	add.w	#32,d7
	dbra	d1,attrlp1

	addq.w	#1,d0
	cmp.w	#768,d0
	bne	loop2

				;FINISHED / break
break2	jsr	Permit(a6)	;enable multitasking

wait	bclr.b	#1,$bfe001	;LED on

	move.l	windowhd,a0
	move.l	86(a0),a0
	move.l	ExecBase,a6
	jsr	GetMsg(a6)
	move.l	d0,a0
	move.l	20(a0),d6
	cmp.l	#$200,d6
	beq	end
	bra	wait
end
	bsr	closewin
	bclr.b	#1,$bfe001
	rts			;end - close screen, libraries


setcols:			;set screen palette - use intuition library
	move.l	gfxbase,a6
	move.l	screenhd,a0	;screen handle
	add.l	#ViewPort,a0	;point to viewport structure
	lea	colours,a1	;colour table
	move.w	#15,d0		;16 entries
setcolp	move.w	(a1)+,d1	;red,  load colour
	move.w	(a1)+,d2	;grn,  valuses into
	move.w	(a1)+,d3	;blue, processor registers
	move.w	d0,-(a7)	;save d0
	movem.l	a0/a1,-(a7)	;and memory pointers
	jsr	SetRGB4(a6)	;and call library routine to set colours
	movem.l	(a7)+,a0/a1	;recall
	move.w	(a7)+,d0	;registers
	dbra	d0,setcolp	;loop
	rts

colours	dc.w	$f,$f,$f
	dc.w	$f,$f,$0
	dc.w	$0,$f,$f
	dc.w	$0,$f,$0
	dc.w	$f,$0,$f
	dc.w	$f,$0,$0
	dc.w	$0,$0,$f
	dc.w	$0,$0,$0
	dc.w	$b,$b,$b
	dc.w	$b,$b,$0
	dc.w	$0,$b,$b
	dc.w	$0,$b,$0
	dc.w	$b,$0,$b
	dc.w	$b,$0,$0
	dc.w	$0,$0,$b
	dc.w	$0,$0,$0


getbyte:		;Get byte from RS232
				;I/P: a5=$dff000  O/P: d5=byte received
	bset.b	#1,$bfe001	;LED off
	bclr.b	#6,$bfd000	;DTR=1 - handshake so Spectrum sends data
	move.w	#$0800,INTREQ(a5)	;reset RBF bit (Receive Buffer Full)
waitfc	btst.b	#6,SERDATR(a5)	;RBF - if 1 then whole byte received
	bne	readch
	btst.b	#2,POTGOR(a5)	;break check - right mouse button
	beq	break1
	bra	waitfc		;wait to receive byte
readch
	bclr.b	#1,$bfe001		;LED on
	move.b	SERDATR+1(a5),d5	;read the byte received (in hardware)
	move.w	#$0800,INTREQ(a5)	;reset RBF bit
	rts
break1	move.l	#break2,(a7)
	rts

setbaud:
	move.l	starta0,a0
	move.l	startd0,d0
	cmp.w	#1,d0
	bhi	chkargs
	rts			;no arguments
chkargs	clr.w	d1
	clr.w	d2		;clear d2
numlp	move.b	(a0)+,d2	;get character from CLI argument
	sub.b	#48,d2
	cmp.b	#9,d2
	bhi	gotnum
	mulu	#10,d1		;mutiply register by 10
	add.w	d2,d1
	bra	numlp
gotnum	tst.w	d1		;if d1 is zero
	beq	prnhelp		;then a mistake been made by user
	move.w	d1,baudrate
	rts
prnhelp:		;A help message to print could be put here.
	rts		;but here it uses the default baud.

printbaud:
	lea	titlebaud,a0
	clr.l	d0
	move.w	#10000,d1
	move.w	baudrate,d0
	mulu	#100,d0
	clr.w	d7		;starting-zero flag
prnumlp	divu	d1,d0
	tst.w	d0
	beq	zerojp1
	add.w	#1,d7	;set flag
zerojp1	tst.w	d7
	bne	zerojp2
	move.w	#-16,d0
zerojp2	add.w	#48,d0	;if first zero, then make it a space
	move.b	d0,(a0)+
	lsr.l	#8,d0
	lsr.l	#8,d0
	divu	#10,d1	;divide divisor(d1) by 10
	tst.w	d1
	bne	prnumlp
	rts


starta0	dc.l	0
startd0	dc.l	0
baudrate: dc.w	96
myname	dc.b	"© Jack Young 1990",0
	even
command	dc.b	"96",10
	even
