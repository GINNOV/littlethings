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
	
main		movea.l	#string1,a0
		bsr	str_len
		display_d0
		movea.l	#string2,a0
		bsr	str_len
		display_d0
		movea.l	#string3,a0
		bsr	str_len
		display_d0
		rts
		

; This subroutine calculates the length of a 0 terminated string of characters.

; Entry :  a0 must hold the address of the string

; Exit  :  d0 holds the length of the string
;          a0 holds address of 0 byte + 1

str_len		moveq.l	#-1,d0		initialise counter
loop		addq.l	#1,d0		bump counter
		tst.b	(a0)+		end of string ?
		bne	loop		if not loop back
		rts			all done so return


string1		dc.b	'My name is :',0
		even
string2		dc.b	'Mark ',0
		even
string3		dc.b	'Meany.',0
		even
