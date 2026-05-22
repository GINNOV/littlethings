
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
	
; eg_13.s

main            move.w          #2,d0
                muls.w          #-3,d0
                add.w           #8,d0
                display_d0
                rts
		
	
	
	
