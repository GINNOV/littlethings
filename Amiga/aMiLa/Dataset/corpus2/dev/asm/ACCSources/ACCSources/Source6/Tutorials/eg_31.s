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
	
main		movea.l		#string,a0	a0 holds address of string
		bsr		print		print the string
		bsr		ucase		convert string to upper case
		movea.l		#string,a0	get address of string in a0
		bsr		print		print the converted string
		bsr		mouse_press	wait for left button
		rts				all done so return

; This subroutine will convert all lower case letters in a 0 terminated text 
;string to upper case.

; Entry  :  a0 must hold the address of the text

; Exit   :  a0 holds address of byte following 0 terminator
;           d0.b holds 0

ucase		move.b		(a0),d0		d0 = next character
		cmpi.b		#'a',d0		is char < 'a'
		blt		not_lower_case	if so dont convert it
		cmpi.b		#'z',d0		is char > 'z'
		bgt		not_lower_case	if so dont convert it
		subi.b		#$20,d0		convert to upper case
not_lower_case	move.b		d0,(a0)+	replace character
		tst.b		d0		are we at end of string
		bne		ucase		if not check next character
		rts				otherwise return

		
string		dc.b		'convert THIS to UppEr CaSe .',$0a,$0a,0
