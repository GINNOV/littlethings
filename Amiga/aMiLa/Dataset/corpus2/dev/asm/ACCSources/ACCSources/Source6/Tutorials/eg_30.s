; The next four lines bring in the startup code which handles the CLI
;or Workbench correctly and then opens a console window for I/O.
;macros.i includes the macro routines explained in the text.
;subroutines.i includes the routines required for the macros.

	incdir	'source6:include/'
	include	'startup.i'
	include	'macros.i'
	include	'subroutines.i'
	
; Your program should start at the label main and should end with an
;rts instruction.  M.Meany  June 1990 
	
main		move.l		#string1,a0		a0 = addr of text
		bsr		lprint			print text
		move.l		#string2,a0		a0 = addr of text
		bsr		lprint			print text
		move.l		#string3,a0		a0 = addr of text
		bsr		lprint			print text
		bsr		mouse_press		wait for left button
		rts					finished.
	
; This subroutine will print a 0 terminated text string in the current
;output con: window. The DOS library MUST be open.

; Entry : a0 must hold the address of the start of the text string
;         window.ptr must hold the handle of the current con: window.

; Exit  : All registers are unalterd by this subroutine.
	
lprint		movem.l		d0-d7/a0-a7,-(sp)	save registers
		move.l		window.ptr,d1		d1 = window handle
		move.l		a0,d2			d2 = addr of string
		moveq.l		#-1,d3			initialise counter
.lp		addq.l		#1,d3			bump counter
		tst.b		(a0)+			end of string ?
		bne		.lp			if not loop back
		CALLDOS		Write			display the string
		movem.l		(sp)+,d0-d7/a0-a7	restore registers
		rts					all done so return
		
; Here are the three text strings. Note that each is 0 terminated. Each text
;string uses the byte $0a to force a line feed ( carriage return ) after it
;has been printed.
		
string1		dc.b		'An example of using the subroutine "print" '
		dc.b		'to display text.',$0a,$0a,0
		even
string2		dc.b		'Note how $0a ( a carriage return ) can be used.'
		dc.b		$0a,$0a,$0a,0
		even
string3		dc.b		'Press the left mouse button. M.Meany, Nov 90.',$0a,$0a,0
