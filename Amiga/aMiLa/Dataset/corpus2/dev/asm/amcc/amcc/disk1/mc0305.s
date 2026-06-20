; mc0305.s			; cmp and branch
; not on disk
; from Mark Wrobel course letter 11

first:
	move.l	#16,d0			; use d0 as a counter
	move.l	#$00,a0			; let a0 point to a source address
	lea.l	buffer,a1		; allocate a destination buffer
loop:
	move.b	(a0),d1			; copy the source into d1
	add.l	#1,a0			; increment source address
	move.b	d1,(a1)			; move data from source into destination bufffer
	add.l	#1,a1			; increment destination address
	sub.l	#1,d0			; subtract one from the counter
	cmp.l	#0,d0			; have the counter reached zero?
	bne	loop				; if not continue to loop.
	rts

buffer:
	blk.b	16,0			; allocate 16 bytes and intialize them to zero
