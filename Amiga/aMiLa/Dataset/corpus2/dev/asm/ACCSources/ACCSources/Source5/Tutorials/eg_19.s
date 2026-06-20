
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
	
; eg_19.s

main            move.l          #price_list,a0   a0-->the price list
                moveq.l         #0,d1           clear the total
                move.w          (a0)+,d0        get price of article
                mulu.w          #15,d0          calculate VAT
                divu.w          #100,d0
                add.w           d0,d1           add to total
                move.w          (a0)+,d0        get price of article
                mulu.w          #15,d0          calculate VAT
                divu.w          #100,d0
                add.w           d0,d1           add to total
                move.w          (a0)+,d0        get price of article
                mulu.w          #15,d0          calculate VAT
                divu.w          #100,d0
                add.w           d0,d1           add to total
                move.w          (a0)+,d0        get price of article
                mulu.w          #15,d0          calculate VAT
                divu.w          #100,d0
                add.w           d0,d1           add to total
                move.w          (a0)+,d0        get price of article
                mulu.w          #15,d0          calculate VAT
                divu.w          #100,d0
                add.w           d0,d1           add to total
                display_d1
                rts

	        even
price_list      dc.w            23
                dc.w            15
                dc.w            145
                dc.w            73
                dc.w            45
		
	
	
	
