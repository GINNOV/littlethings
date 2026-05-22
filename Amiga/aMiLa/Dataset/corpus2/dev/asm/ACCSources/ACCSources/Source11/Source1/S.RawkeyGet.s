; Very quick key check using hardware regs
; The Knipe, 4 Mar 91.

start		move.b		$bfec01,d0	;get the value
		not.b		d0		;and manipulate it
		ror.b		d0		;to get rawkey code

check		cmp.b		#$44,d0		;rawkey value for RETURN
		bne.s		start
		moveq		#0,d0		;remove CLI returncode
		rts

