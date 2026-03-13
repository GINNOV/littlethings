
E592	movem.l	d7/a2-a3/a6,-(a7)
	move.l	d0,d7
	tst.w	-$253c(a4)
	bne.l	E594
	tst.l	$0200(a4)
	beq.l	E594
	tst.w	-$252a(a4)
	beq.l	E594
	clr.w	-$252a(a4)
	moveq	#$44,d0
	move.l	#$00010001,d1
	dc.b	$2c,$78,$00,$04
	;	movea.l  ($0004).w,a6
	jsr	-$00c6(a6)
	movea.l	d0,a3
	tst.l	d0
	beq.s	E594
	moveq	#$00,d0
	suba.l	a0,a0
	jsr	E1544(pc)
	movea.l	d0,a2
	tst.l	d0
	bne.s	E593
	movea.l	a3,a1
	moveq	#$44,d0
	dc.b	$2c,$78,$00,$04
	;	movea.l  ($0004).w,a6
	jsr	-$00d2(a6)
	bra.s	E594

E593	lea	$0014(a3),a0
	move.l	a0,$000a(a3)
	move.l	a3,$0014(a3)
	move.l	a2,$0018(a3)
	moveq	#$1f,d0
	move.l	d0,$001c(a3)
	move.l	d7,d0
	ext.l	d0
	move.l	d0,$0028(a3)
	movea.l	$0200(a4),a0
	movea.l	a3,a1
	dc.b	$2c,$78,$00,$04
	;	movea.l  ($0004).w,a6
	jsr	-$016e(a6)
	movea.l	a2,a0
	jsr	-$0180(a6)
	movea.l	a2,a0
	jsr	-$0174(a6)
	movea.l	a2,a0
	jsr	E1515(pc)
	movea.l	a3,a1
	moveq	#$44,d0
	dc.b	$2c,$78,$00,$04
	;	movea.l  ($0004).w,a6
	jsr	-$00d2(a6)
	move.w	#$0001,-$252a(a4)
E594	movem.l	(a7)+,d7/a2-a3/a6
	rts	
