
	opt	o+,ow-	tell Devpac to optomise

; The next four lines bring in the startup code which handles the CLI
;or Workbench correctly and then opens a console window for I/O.
;macros.i includes the macro routines explained in the text.
;subroutines.i includes the routines required for the macros.

	incdir	'Source5:include/'
	include	'startup.i'
	include	'macros.i'
	include	'subroutines.i'
	
; Your program should start at the label main and should end with an
;rts instruction.  M.Meany  June 1990 
	
; eg_16.s

main            moveq.l         #17,d0
                divu.w          #7,d0
                display_d0
                rts
		
	
	
	
