START:
	; dreiteilige Abfrage
	clr d0
	sub.w #1,d0
	tst.w d0
	beq	IF_PATH1
	bmi	IF_PATH2
	; ELSE PATH
	bra	.exit
	nop
.exit:
	rts
	
IF_PATH1:
	move.l #1,d1
	rts

IF_PATH2:
	move.l #2,d1
	rts