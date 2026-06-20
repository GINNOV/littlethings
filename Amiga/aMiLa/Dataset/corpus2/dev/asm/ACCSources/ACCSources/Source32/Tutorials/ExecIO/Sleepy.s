
; Suitable for WB1.2/3		

		incdir		sys:include/
		include		exec/exec_lib.i

Sleeping	move.l		#$1000,d0		only bit 12 is set
		CALLEXEC	Wait			go to sleep

		move.l		#$1000,d1		set bit 12
		and.l		d0,d1
		beq.s		Sleeping		not Ctrl-C

		moveq.l		#0,d0			no errors
		rts					return
