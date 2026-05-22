;««««««««««««««««««««««««««««««««««»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»
;		align the register d0 by eight
;««««««««««««««««««««««««««««««««««»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»

align_d0:	move.l	d0,d1				;align the memory.
		and.l	#%111,d1
		beq.s	align_done
		eor.b	#%111,d1
		add.l	d1,d0
		addq.l	#1,d0				;aligned by eight.
align_done:	rts					;return.
