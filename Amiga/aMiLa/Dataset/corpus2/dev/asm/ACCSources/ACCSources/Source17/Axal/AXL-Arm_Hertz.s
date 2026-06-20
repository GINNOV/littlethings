* Date:	05-10-91
* Time:	15:32
* Name:	Switch Hertz
* Code:	Axal
* Note:	Assemble to ram: and run from CLI!!!

**** ONLY RUN ON MACHINES WITH ECS !!!

	opt	c-,ow-,o+

	move.b	#0,-1(a0,d0)		terminate parameters
	move.l	a0,parameters		save address of parameters

*---------------------------------------

	move.l	$4,a6			execbase
	moveq.l	#0,d0			any version
	lea	dosname,a1		point to lib
	jsr	-552(a6)		open lib
	move.l	d0,dosbase		save base
	beq	error0			branch if error

*---------------------------------------

	move.l	dosbase,a6		point to dosbase
	jsr	-60(a6)			get output handle
	move.l	d0,cliout		and store it
	beq	error2			quit if not opened

	jsr	-54(a6)			get input handle
	move.l	d0,cliin		and store it
	beq	error2			quit if failure

*---------------------------------------

* PRINT NAME OF PROGRAM, CODER ETC.....

	move.l	#craptxt,d2		address of text
	move.l	#crapend,d3		length of text
	bsr	printcon		print the text

*---------------------------------------

* SEE IF USER WANTS TO RUN PROGRAM

	move.l	parameters,a0		get parameters
	cmpi.w	#"-o",(a0)+		do we continue running
	beq.s	do_change		run the program!!

*---------------------------------------

* PRINT INSTRUCTIONS FOR USER
error3
	move.l	#infotxt,d2		address of text
	move.l	#infoend,d3		length of text
quit
	bsr	printcon		print text

*---------------------------------------

error2	move.l	dosbase,a1		point to dos base
	move.l	$4,a6			execbase
	jsr	-414(a6)		close lib
error0	rts

*---------------------------------------

* WHICH HERTZ TO CHANGE TO

do_change
	cmp.w	#"ff",(a0)		do we install 50hz
	bne.s	not_50hz		if not then check
	move.w	#$20,$dff1dc		make 50hz display
	move.l	#fiftxt,d2		address of text
	move.l	#fifend,d3		end of text
	bra.s	quit			quit
not_50hz
	cmp.b	#"n",(a0)		do we install 60hz
	bne.s	error3			if not print infomation
	move.w	#$40,$dff1dc		make 60hz display
	move.l	#sixtxt,d2		address of text
	move.l	#sixend,d3		end of text
	bra.s	quit

*---------------------------------------

* Text to print in d2 - Length of text in d3

printcon
	move.l	cliout,d1		file handle
	move.l	dosbase,a6		point to dosbase
	jsr	-48(a6)			write message
	rts

*---------------------------------------

dosname		dc.b	"dos.library",0
		even
dosbase		dc.l	0
cliout		dc.l	0
cliin		dc.l	0
parameters	dc.l	0

craptxt		dc.b	$9b,$30,$20,$70,$0c,$9b,'0;33;42',$6d
		dc.b	"60 Hertz V1.0:",$9b,'3;32;40',$6d
		dc.b	"  Written by AXAL of ARMALYTE.",10
		dc.b	$9b,'0;33;40',$6d
		dc.b	"NOTE:"
		dc.b	$9b,'0;31;40',$6d
		dc.b	" Will only work on machines with ECS!!!",10,10
		dc.b	$9b,'0;31;40',$6d,0			normal
crapend		equ	*-craptxt
		even
infotxt		dc.b	"60 Hertz, a utility to turn on/off 60 hertz mode",10
		dc.b	"Please note: You need a machine with the new ECS",10
		dc.b	"Running the program will not effect your machine",10
		dc.b	"if you haven't got the ECS.",10,10
		dc.b	"From the CLI:",10
		dc.b	"                     60Hz -on",10,10
		dc.b	$9b,'0;33;42',$6d
		dc.b	"Will enable 60 hertz.",10,10
		dc.b	$9b,'0;31;40',$6d
		dc.b	"                     60Hz -off",10,10
		dc.b	$9b,'0;33;42',$6d
		dc.b	"Will enable 50 hertz.",10,10
		dc.b	$9b,'0;31;40',$6d
		dc.b	"                     60Hz",10,10
		dc.b	$9b,'0;33;42',$6d
		dc.b	"Will display these instructions",10,10
		dc.b	$9b,'0;31;40',$6d
infoend		equ	*-infotxt
		even
fiftxt		dc.b	$9b,'0;31;40',$6d
		dc.b	"50 hertz now installed!",10,10
fifend		equ	*-fiftxt
sixtxt		dc.b	$9b,'0;31;40',$6d
		dc.b	"60 hertz now installed!",10,10
sixend		equ	*-sixtxt
