* Program to scan EXEC memory, and report memory ranges in decimal to STDOUT,
* for all areas in the MemList. Author: SNG, 24th April 1996. Shell/CLI only.
* Suits any Workbench but needs a 68020 or better for the DIVU.L instruction.
* Returns ERROR if not 68020 or above and FAIL if unable to open DOS.LIBRARY.

Start	movea.l	4.w,a6
	btst.b  	#1,$129(a6)     	Test for a 68020 or higher
        	beq.s   	TooOld 	    	That was easy!         
	move.l	a6,ExecLib
	lea.l	DosName,a1
	jsr	-552(a6)		EXEC OpenLibrary
	move.l	d0,DosLib
	beq.s	Failure		We really need DOS

* Stick up a heading in the output window

	move.l	#Heading,-(a7)	Stack string address
	bsr.w	PrintString
	addq.l	#4,a7
	
	movea.l	ExecLib,a6
	movea.l	$142(a6),a4		Start of Mem List
.RAMpage	movea.l	24(a4),a3		Extract end address+1
	subq.l	#1,a3		
	movea.l	20(a4),a2		Find the actual beginning

	bsr.s	Report

* The above sequence finds the top-priority contiguous RAM area, first in
* the memory list. To scan subsequent RAM areas, append this routine:

 	move.l	(a4),a4		Advance down list
	tst.l	(a4)
	bne.s	.RAMpage

* Close dos.library - versions up to 33.2 forgot to do this!

	move.l	DosLib,a1		It *must* be open
	move.l	ExecLib,a6
	jsr	-414(a6)		EXEC CloseLibrary

.Done	moveq	#0,d0		OK: it worked
	rts

TooOld	moveq	#10,d0	     	ERROR: not 68020+
	rts
	
Failure	moveq	#20,d0           	FAIL: no DOS.LIBRARY!
	rts

* Write range <Start> to <End> is <Name> <LF> to STDOUT

Report	move.l	20(a4),-(a7)	First byte address
	bsr.s	PrintNumber
	move.l	#Separator1,(a7)	' to '
	bsr.s	PrintString
	move.l	24(a4),d0
	subq.l	#1,d0		Last byte, inclusive
	move.l	d0,(a7)
	bsr.s	PrintNumber	
	move.l	#Separator2,(a7)	' is '
	bsr.s	PrintString
	move.l	10(a4),(a7)		Memory name
	bsr.s	PrintString
	move.l	#NewLine,(a7)	End of line
	bsr.s	PrintString
	addq.l	#4,a7		Tidy SP
	rts

**************************************************************************

* AmigaDOS string and long integer output support routines.
* These expect a stacked parameter, C-style.

* PrintNumber expects an unsigned value and writes a fixed-length field;
* pass 32 bits to get ten digits, right justified, space filled on left.

PrintNumber	lea.l	Buffer+Digits,a0
	moveq	#'0',d4
	
	move.l	4(a7),d1		Fetch parameter
	bne.s	Compute

	move.l	#ZeroPad,4(a7)	Zero is easy
	bra.s	PrintString
	
* Work out all the digits by sucessive division in a 68060-friendly way
		
Compute	moveq	#Digits-1,d2
	
Digit	move.l	d1,d0
	divu.l	#10,d1		Compute next quotient
	move.l	d1,d3
	mulu.l	#10,d3		D3 := INT(D0 / 10) * 10
	sub.l	d3,d0		D0 := D0 MOD 10
	add.b	d4,d0           	Convert binary to ASCII
	move.b	d0,-(a0)		Move from right to left
	dbra	d2,Digit

	move.l	a0,4(a7)		Stack pointer to text

	moveq	#Space,d2		Space
Tidy0s	cmp.b	(a0),d4		Suppress leading zeroes
	bne.s	PrintString
	move.b	d2,(a0)+
	bra.s	Tidy0s
	
* Write C formatted string to StdOut
	
PrintString move.l	#Format,d1		D1 -> format string
	lea.l	4(a7),a0		A0 -> address of string
	move.l	a0,d2		Dos expects D2
	move.l	DosLib,a6
	jmp	-954(a6)		Exit via VPrintf

**************************************************************************

* Constants

Heading	dc.b	10,"    Start            End          Name",10
NewLine	dc.b	10,0

Format	dc.b	"%s",0

Version	dc.b	"$VER: MemList 33.3 (24.4.96)",10,0

DosName	dc.b	"dos.library",0

Separator1	dc.b	'  to ',0

Separator2	dc.b	' is ',0

**************************************************************************

* Variables

	cnop	0,4		Long alignment
	
DosLib	dc.l	0
ExecLib	dc.l	0

Space	equ	32		ASCII code
Digits	equ	10
ZeroPad	dcb.b	Digits-1,Space
	dc.b	'0',0
Buffer	ds.b	Digits		Space for a 32 bit decimal number
	dc.b	0		Terminator
	
	end			Terminator
	