
; Test memory allocation routines. The shut-down code in hw_start.i will
;ensure all memory allocated by a call to GetMem is released.

		include		hardware.i
		include		macros.i
		include		hw_start.i

Main		btst		#6,CIAAPRA
		bne.s		Main

		move.l		#20*1024,d0
		move.l		#CHIPMEM,d1
		BSR		GetMem
		tst.l		d0
		bne		.one
		lea		ErrorMsg1,a0
		bsr		SetError

.one		move.l		#60*1024,d0
		move.l		#FASTMEM,d1
		BSR		GetMem
		tst.l		d0
		bne		.two
		lea		ErrorMsg2,a0
		bsr		SetError


.two		move.l		#30*1024,d0
		move.l		#ANYMEM,d1
		BSR		GetMem
		tst.l		d0
		bne		.three
		lea		ErrorMsg3,a0
		bsr		SetError

.three		bsr		FreMem

		lea		ErrorMsg,a0
		bsr		SetError
		
		rts
		
ErrorMsg	dc.b		'Got all memory!',0
		even
ErrorMsg1	dc.b		"Could not get memory: 20K CHIP.",0
		even
ErrorMsg2	dc.b		"Could not get memory: 60K FAST.",0
		even
ErrorMsg3	dc.b		"Could not get memory: 30K ANY.",0
		even
