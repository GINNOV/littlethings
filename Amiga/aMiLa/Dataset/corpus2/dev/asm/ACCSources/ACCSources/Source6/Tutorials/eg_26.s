

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
	
main		move.w	num,d1	get the number
		subq.w	#1,d1	adjust for dbra
		moveq.l	#1,d0	start at 1 and work up to the number
		move.l	d0,d2	initialise factorial
loop		mulu.w	d0,d2	multiply by next integer
		addq.w	#1,d0	bump to next integer
		dbra	d1,loop	loop until all done
		display_d2	print the factorial
		rts		return
		
num		dc.w	8

