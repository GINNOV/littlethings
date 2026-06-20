

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
	


main		move.l	#str1,a0	a0--> 1st string
		move.l	#str2,a1	a1--> 2nd string
		moveq.l	#0,d0		reset flag
loop		cmpm.b	(a0)+,(a1)+	compare next chars
		bne	not_same	branch if not equal
		cmpi.b	#$0,(a0)	end of string ?
		bne	loop		if not go back
		moveq.l	#1,d0		strings the same so set flag
not_same	display_d0
		rts
		
str1		dc.b	"these strings are the same",0
		even
str2		dc.b	"these strings are the same",0
		even

