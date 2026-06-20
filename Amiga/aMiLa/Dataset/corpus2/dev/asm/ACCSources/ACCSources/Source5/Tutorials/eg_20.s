
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
	
; eg_20.s

main	move.l	#price_list,a0		a0--> the price list
	moveq.l	#0,d2			clear total
	moveq.l	#5,d0			d0=number of items in the list
loop	move.w	(a0)+,d1		d1=price of next item
	mulu.w	#15,d1			calculate VAT of item
	divu.w	#100,d1
	add.w	d1,d2 			add VAT to total
	subi.b	#1,d0			decrease counter
	bne	loop			branch if counter not equal to zero
	display_d2			display total VAT (to nearest £)
	rts				finish

price_list      dc.w            23
                dc.w            15
                dc.w            145
                dc.w            73
                dc.w            45
		
	
	
	
