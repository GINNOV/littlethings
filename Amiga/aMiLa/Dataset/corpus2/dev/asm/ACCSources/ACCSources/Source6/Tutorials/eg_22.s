

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
len_loop	move.b	(a0)+,d0		d0 holds next char
		addi.b	#1,d1			bump counter
		cmp.b	#$0a,d0			is char a carriage return ?
		bne	len_loop		if not branch back
		subi.b	#1,d1			correct counter
		move.l	d1,string_len		save strings length
		display_d1			print strings length
		rts
		
char_string	dc.b	'How long is this text ? ',$0a
		even
string_len	dc.l	0
