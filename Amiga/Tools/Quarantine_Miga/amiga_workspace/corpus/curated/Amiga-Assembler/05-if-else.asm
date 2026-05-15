START:
	; einfaches if / else
	move.w #1,d0
	tst.w	d0
	beq	IF_PATH
	bne	ELSE_PATH
	bra	.exit
	nop
.exit:
	rts
	
IF_PATH:
	move.l #1,d1
	rts

ELSE_PATH:
	move.l #2,d1
	rts