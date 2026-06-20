; mc0306.s			; cmp and branch (compact)
; not on disk
; from Mark Wrobel course letter 11

first:
	move.l	#16,d0
	move.l	#$00,a0
	lea.l	buffer,a1
loop:
	move.b	(a0)+,(a1)+
	sub.l	#1,d0
	bne	loop
	rts

buffer:
	blk.b	16,0
