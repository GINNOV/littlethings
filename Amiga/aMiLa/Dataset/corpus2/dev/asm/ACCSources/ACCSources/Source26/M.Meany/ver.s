
; Exploring how to implement $VER:


Start		moveq.l		#0,d0
		rts
		
		dc.b		'$VER: v1.00/©_M.Meany/July_1992/Hi_There'
		even

