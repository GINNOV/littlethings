

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
	

main		move.l	#char_string,a0		a0 holds addr of text string
		moveq.l	#0,d1			clear counter
loop 		move.b	(a0)+,d0		get next char
		cmp.b	#" ",d0		is char a space ?
		bne	not_a_space		branch if not a space
		addi.w	#1,d1			bump counter
not_a_space	cmpa.l	#str_end,a0		end of string ?
		bne.s	loop			if not loop back
		display_d1			print number of spaces
		rts				and return
		
char_string	dc.b	'How long is this text ? ',$0a
str_end		even
string_len	dc.l	0
