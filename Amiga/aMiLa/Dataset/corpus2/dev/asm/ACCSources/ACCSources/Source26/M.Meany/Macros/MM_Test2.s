
; Checking more routines, again you'll have to use monam!

		incdir		source:include/
		include		marks/mm_macros.i

Start		lea		myname,a0		string
		lea		temp,a1			buffer
		
		STRLEN		a1
		move.l		d0,d1
		
		STRLEN		a0
		
		FINDS		a0,d0,a1,d1
.b1		tst.l		d0

		rts

		include		marks/mm_subs.i

myname		dc.b		'Mark Victor Meany',0
		even
		
temp		dc.b		'Fin me, Mark Victor Meany. ditto',0
		even
