; mc0304.s			; cmp
; not on disk
; from Mark Wrobel course letter 11

first:
	move.l  #2,d0		; put 2 into d0
	cmp.l   #0,d0		; does 0 compare with the value in d0?
	cmp.l   #2,d0		; does 2 compare with the value in d0?
	cmp.l   #4,d0		; does 4 compare with the value in d0?
	rts					; return from subroutine