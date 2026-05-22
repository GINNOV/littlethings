;"LPRINT.s"   J. Young    12th Feb 1991
;
;Print character codes to parallel device, in the same way as the BASIC command.

;Exec library offsets:
ExecBase = 4
OldOpenLibrary	= -408
CloseLibrary	= -414

;Dos library offsets:
Open	= -30
Close	= -36
Write	= -48
Output	= -60

mode_old = 1005
mode_new = 1006


*** THE PROGRAM ***
start:
	move.l	a0,CLIargad	;save address of CLI arguments
	move.l	d0,CLIargln	;save length of CLI arguments

;Open dos library
	move.l	ExecBase,a6
	lea	dosname,a1
	jsr	OldOpenLibrary(a6)
	move.l	d0,dosbase
	beq	nodoslib

;Open printing channel (par:)
	move.l	dosbase,a6
	move.l	#outname,d1	;output channel/device
	move.l	#mode_old,d2	;MODE_OLDFILE
	jsr	Open(a6)
	move.l	d0,filehd
	beq	nofile		;if cannot open file

;Prepare for printing - set-up registers:
	move.l	CLIargad,a1	;get CLI command line address..
	move.l	CLIargln,d0	;..and length,
	move.l	filehd,d1	;set file handle,
	move.l	#prnbuf,d2	;buffer address and
	move.l	#1,d3		;buffer length.
	move.w	#0,d4		;quote flag (0set=within quote, 1set=number)
	move.w	#0,d5		;number variable

;Just check if the input is "?"+LF (2 characters)
	cmp.w	#2,d0
	bne	nohelp
	cmp.b	#"?",(a1)
	beq	prhelp		;if is, then print out help

;Check to see if there are any parameters-
nohelp	cmp.w	#1,d0		;if only one character (LF),
	bne	lprnlp
	addq.w	#1,d0		;add a length of 1 to d0, which makes the
				;folling loop print a line feed.

;Now enter the loop:
;Get a character and process it...
lprnlp:
	subq.w	#1,d0
	bls	nomore		;jump if no more characters to print
	move.b	(a1)+,d7	;get the next character
	btst	#0,d4
	bne	inquote		;jump if within quotes

;check if number character
	cmp.b	#"0",d7
	blo	notnum		;jump if lower than 0
	cmp.b	#"9",d7
	bhi	notnum		;jump if higher than 9

;must be a number
	sub.b	#48,d7		;ASCII->binary
	mulu	#10,d5		;d5=d5×10
	add.b	d7,d5		;d5=d5+d7
;got number so far, so set number flag
	bset	#1,d4
	bra	lprnlp		;loop- get next char

;now process non-number
notnum:
	btst	#1,d4		;if bit 1 reset,
	beq	notnum2		;no number to print
	move.b	d7,d6
	bsr	prnum		;if set, print the number and continue
	move.b	d6,d7
notnum2	cmp.b	#34,d7		;if not quote mark,
	bne	notquote	;jump ahead

;is a quote
	bset	#0,d4		;set quote flag
	bra	lprnlp		;loop

;is another character- print it, but don't enter quote mode
notquote:
	cmp.b	#44,d7		;if comma
	beq	lprnlp		;loop back

	bsr	prnchar		;jump to part that prints the character
	bra	lprnlp


;Jumps here if the string is within a quote (pair)
inquote:
	cmp.b	#34,d7		;quote mark
	bne	noquote2	;jump if not quote
;is quote - see if next char is also a quote
	move.b	(a1),d6
	cmp.b	#34,d6
	beq	doubleq
;is single quote, so toggle flag and loop
	bclr	#0,d4		;set not in quotes
	bra	lprnlp

;jump here if double quotes
doubleq	add.l	#1,a1		;increment a1 pointer
	subq.w	#1,d0		;decrement counter
;can continue to print character (may be a single quote
noquote2
	bsr	prnchar
	bra	lprnlp


;Jump here when the end of the input string is reached
nomore:
;check to see if there is still a number to be printed.
	btst	#1,d4
	beq	nonumleft	;branch if there is not a number left to print
;print the remaining number
	bsr	prnum

;end the program - close file and dos library
nonumleft:
	jsr	Close(a6)	;close file (d1 already set)

nofile:				;jump here if cannot open output file
	move.l	ExecBase,a6	;close dos library
	move.l	dosbase,a1
	jsr	CloseLibrary(a6)

nodoslib:			;jump here if cannot open dos library
	rts


;*** SUBROUTINES ***
;this subroutine prints the number in d5 and resets flags/variables
prnum:
	move.b	d5,d7
	bclr	#1,d4
	clr.l	d5
;here's the bit that prints the charater:
prnchar:
	move.b	d7,prnbuf	;set print buffer
	movem.l	d0-d6/a1,-(a7)	;save registers
	jsr	Write(a6)	;print char - registers already set
	movem.l	(a7)+,d0-d6/a1	;restore registers
	rts			;loop

;Print help (triggered by '?',$A input)
prhelp	move.l	d1,-(a7)	;save printer handle
	jsr	Output(a6)	;get standard output channel
	move.l	d0,d1		;put it d1 ready for Write subroutine
	move.l	#helptxt,d2	;address of help text
	move.l	#htxtend-helptxt,d3	;length of help text
	jsr	Write(a6)
	move.l	(a7)+,d1	;restore printer handle
	bra	nonumleft	;end program



;*** DATA ***
dosname	dc.b	"dos.library",0
	even
outname	dc.b	"par:",0
	even
helptxt	dc.b	27,"[3m",27,"[42m",27,"[33m",10
	dc.b	"     ""LPRINT""",27,"[31m  by Jack Young.     "
	dc.b	27,"[30mBadly written on 12th Febrary 1991  (V1.0)"
	dc.b	27,"[0m",27,"[31m",27,"[40m",13,10,10
	dc.b	"    ",27,"[4mUse this program to send character data directly to the parallel port.",27,"[0m",10
	dc.b	10
	dc.b	"SYNTAX:",9,"Numbers are converted into control codes. (decimal only)",10
	dc.b	9,"Commas (,) are used to separte numbers.",10
	dc.b	9,"Quotes ("") start and terminate ASCII data to be printed.",10
	dc.b	9,"Double quotes ("""") are sent as a single quote mark.",10
	dc.b	9,"Any characters within a pair of quotes (including double quotes) are",10
	dc.b	9,"  sent as ASCII data, as you type it in.",10
	dc.b	9,"  Use this method to print numbers.",10
	dc.b	9,"Any characters outside double quotes, other than commas and single",10
	dc.b	9,"  quotes, terminate numbers and are printed after them.",10
	dc.b	10,27,"[3m"
	dc.b	"   I wrote this because I found it irritating not being able to send 'raw'",10
	dc.b	"   printer control codes straight to the printer, without the Amiga's printer",10
	dc.b	"   drivers getting in the way. Now you have complete control over your",10
	dc.b	"   parallel port!",27,"[0m",10
	dc.b	10,"e.g.  ",27,"[1mlprint 27,""C"",0,6",27,"[0m"
	dc.b	"    sets page length to 6 inches on an Epson printer",10
	dc.b	"NOTE: This is equivalent to:  ",27,"[1mlprint 27C0,6",27,"[0m and ",27,"[1m27""C""0,6",27,"[0m",10
	dc.b	10


htxtend	even

dosbase	dc.l	0

;PROGRAM VARIABLES
CLIargad dc.l	0	;address of CLI arguments (command line)
CLIargln dc.l	0	;length of CLI arguments

filehd	dc.l	0	;file handle of output

prnbuf	dc.b	0,0	;print buffer (one byte)

