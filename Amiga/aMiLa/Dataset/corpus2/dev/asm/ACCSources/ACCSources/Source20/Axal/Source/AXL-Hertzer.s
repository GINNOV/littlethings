* Date:	05-10-91
* Time:	15:32
* Name:	Hertzer
* Code:	Axal
* Note:	Assemble to ram: and run from CLI!!!
*	29-12-91 Have added a rest routine and improved
*	the code a bit!

	opt	c-,ow-,o+

	move.l	a0,parameters		save address of parameters
	lea	$dff000,a5		custom chips

*---------------------------------------

	move.l	$4.w,a6			execbase
	moveq.l	#0,d0			any version
	lea	dosname(pc),a1		point to lib
	jsr	-552(a6)		open lib
	move.l	d0,dosbase		save base
	beq.s	error0			branch if error

*---------------------------------------

	move.l	dosbase(pc),a6		point to dosbase
	jsr	-60(a6)			get output handle
	move.l	d0,cliout		and store it
	beq.s	error2			quit if not opened

	jsr	-54(a6)			get input handle
	move.l	d0,cliin		and store it
	beq.s	error2			quit if failure

*---------------------------------------

* PRINT NAME OF PROGRAM, CODER ETC.....

	move.l	#craptxt,d2		address of text
	move.l	#crapend,d3		length of text
	bsr	printcon		print the text

*---------------------------------------

* SEE IF USER WANTS TO RUN PROGRAM

	move.l	parameters(pc),a0	get parameters
	cmpi.b	#"-",(a0)		check "-" for request
	bne.s	error3			quit if not
	cmpi.b	#"r",1(a0)		check "r" for reset
	beq.s	do_reset		branch if we do
	cmpi.b	#"o",1(a0)		check "o" for on/off
	bne.s	error3			quit if not
	cmpi.b	#"n",2(a0)		check "n" for on
	beq.s	do_60on			branch if we do
	cmpi.b	#"f",2(a0)		check "n" for on
	bne.s	error3			quit if not
	cmpi.b	#"f",3(a0)		check "n" for on
	beq.s	do_60off		branch if we do

*---------------------------------------

* PRINT INSTRUCTIONS FOR USER
error3
	move.l	#infotxt,d2		address of text
	move.l	#infoend,d3		length of text
quit
	bsr.s	printcon		print text

*---------------------------------------

error2	move.l	dosbase(pc),a1		point to dos base
	move.l	$4.w,a6			execbase
	jsr	-414(a6)		close lib
error0	rts

*---------------------------------------

* WHICH HERTZ TO CHANGE TO

do_60on
	move.w	#$40,$1dc(a5)		make 60hz display
	move.l	#sixtxt,d2		address of text
	move.l	#sixend,d3		end of text
	bra.s	quit
do_60off
	move.w	#$20,$1dc(a5)		make 50hz display
	move.l	#fiftxt,d2		address of text
	move.l	#fifend,d3		end of text
	bra.s	quit			quit

* THIS PIECE OF CODE OF TAKEN FROM DEAN LAST MONTH
* SINCE THE COMMODORE RESET CODE RESETS $DFF1DC BACK TO
* $0000 (BACK TO 50HZ)

do_reset
	move.w	#$40,$1dc(a5)		make 60hz display
	lea	$fc0004,a0		point to kickstart
	move.l	(a0),a0			get address of pc init
	move.l	a0,$80.w		set trap #0 vector
	trap	#0			reset
	
*---------------------------------------

* Text to print in d2 - Length of text in d3

printcon
	move.l	cliout(pc),d1		file handle
	move.l	dosbase(pc),a6		point to dosbase
	jsr	-48(a6)			write message
	rts

*---------------------------------------

dosname		dc.b	"dos.library",0
		even
dosbase		dc.l	0
cliout		dc.l	0
cliin		dc.l	0
parameters	dc.l	0

craptxt		dc.b	$9b,$30,$70,$0c,$9b,'0;33;42',$6d
		dc.b	"Hertzer V1.1:",$9b,'3;32;40',$6d
		dc.b	"  Written by AXAL of ARMALYTE.",10
		dc.b	$9b,'0;33;40',$6d
		dc.b	"NOTE:"
		dc.b	$9b,'0;31;40',$6d
		dc.b	" Will only work on machines with ECS!!!",10,10
		dc.b	$9b,'0;31;40',$6d
crapend		equ	*-craptxt
		even
infotxt		dc.b	"Hertzer, a utility to turn on/off 60 hertz mode",10
		dc.b	"Please note: You need a machine with the new ECS",10
		dc.b	"Running the program will not effect your machine",10
		dc.b	"if you haven't got the ECS.",10,10
		dc.b	"From the CLI:",10
		dc.b	"                     Hertzer -on",10
		dc.b	$9b,'0;33;40',$6d
		dc.b	"Will enable 60 hertz.",10
		dc.b	$9b,'0;31;40',$6d
		dc.b	"                     Hertzer -off",10
		dc.b	$9b,'0;33;40',$6d
		dc.b	"Will enable 50 hertz.",10
		dc.b	$9b,'0;31;40',$6d
		dc.b	"                     Hertzer -r",10
		dc.b	$9b,'0;33;40',$6d
		dc.b	"Will reset computer in 60 hertz mode.",10
		dc.b	$9b,'0;31;40',$6d
		dc.b	"                     Hertzer",10
		dc.b	$9b,'0;33;40',$6d
		dc.b	"Will display these instructions",10
		dc.b	$9b,'0;31;40',$6d
infoend		equ	*-infotxt
		even
fiftxt		dc.b	$9b,'0;31;40',$6d
		dc.b	"50 hertz now installed!",10,10
fifend		equ	*-fiftxt
sixtxt		dc.b	$9b,'0;31;40',$6d
		dc.b	"60 hertz now installed!",10,10
sixend		equ	*-sixtxt
	

