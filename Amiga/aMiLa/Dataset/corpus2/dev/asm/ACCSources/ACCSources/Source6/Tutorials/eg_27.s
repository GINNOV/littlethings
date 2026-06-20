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
	
main		movea.l	#string,a0	a0-->start of string
		moveq.l	#$0a,d0		d0 = code of carriage return
		moveq.l	#15-1,d1	d1 = max string length - 1
		move.l	d1,d2		copy max length
loop		cmp.b	(a0)+,d0	check if next char is a CR
		dbeq	d1,loop		if not CR and d1 > -1 branch to loop
		sub.w	d1,d2		calculate string length
		display_d2		print string length
		rts			finished so return
		
string		dc.b	'Some string',$0a
		even
