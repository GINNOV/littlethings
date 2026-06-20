
; Check string routines, use monam to see results.

		incdir		source:include/
		include		marks/mm_macros.i

Start		lea		myname,a0

b1		STRCPY		a0,#temp
		
b2		TOUPPER		#temp
		
b3		STRCMP		a0,#temp
		
b4		TOLOWER		#temp
		
b5		STRCMP		a0,#temp
		
b6		rts

		include		marks/mm_subs.i

myname		dc.b		'Mark Victor Meany',0
		even
temp		dc.b		'                 ',0,0
		even
