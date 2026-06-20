; mc0307.s 				; dbra
; not on disk
; from Mark Wrobel course letter 11

first:
	move.l	#15,d0
	move.l	#$00,a0		; could also written as: clr.l a0
	lea.l	buffer,a1
loop:
	move.b	(a0)+,(a1)+
	dbra	d0,loop
	rts

buffer:
	blk.b	16,0
