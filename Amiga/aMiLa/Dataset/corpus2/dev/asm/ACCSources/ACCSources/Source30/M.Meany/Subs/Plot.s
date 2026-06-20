
; For bitplane of width 320 pixels

; plot routine

; entry		d0= x
;		d1= y
;		a1-> start of bitplane

Plot		move.l 		d1,d3 
		mulu.w 		#40,d3  
		add.l 		d3,a1
		move.l 		d0,d2
		divu.w 		#8,d2
		add.w 		d2,a1
		swap		d2
		sub.w		#7,d2
		neg.w 		d2
		bset		d2,(a1)
		rts

;unplot routine

; entry		d0= x
;		d1= y
;		a1-> start of bitplane

UnPlot		move.l 		d1,d3 
		mulu.w 		#40,d3  
		add.l 		d3,a1
		move.l 		d0,d2
		divu.w 		#8,d2
		add.w 		d2,a1
		swap		d2
		sub.w		#7,d2
		neg.w 		d2
		bclr		d2,(a1)
		rts


