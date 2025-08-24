
E673	movem.l	d2-d7/a2-a3/a5,-(a7)
	lea	$00(a1,d1.l),a3
	movea.l	-$2544(a4),a2
	move.w	#$00ff,d7
	tst.w	-$0652(a4)
	bne.s	E675
	move.w	#$0001,-$0652(a4)
	move.w	#$00fb,d5
	movea.l	a2,a5
	move.w	#$003e,d0
	moveq	#$00,d1
E674	move.l	d1,(a5)+
	dbf	d0,E674
	bra.s	E677

E675	move.w	-$1788(a4),d5
	moveq	#$04,d0
E676	addq.w	#$1,d5
	and.w	d7,d5
	dbf	d0,E676
E677	movea.l	a1,a5
	moveq	#$00,d6
E678	cmpa.l	a3,a1
	bge.l	E688
	moveq	#$00,d1
	lsl.w	#$1,d6
	bne.s	E679
	move.w	(a0)+,d6
	move	#$0010,ccr
	roxl.w	#$1,d6
E679	roxl.w	#$1,d1
	tst.b	d1
	beq.s	E682
	moveq	#$00,d1
	moveq	#$07,d0
E680	lsl.w	#$1,d6
	bne.s	E681
	move.w	(a0)+,d6
	move	#$0010,ccr
	roxl.w	#$1,d6
E681	roxl.w	#$1,d1
	dbf	d0,E680
	move.b	d1,(a1)+
	move.b	d1,$00(a2,d5.w)
	addq.w	#$1,d5
	and.w	d7,d5
	bra.s	E678

E682	moveq	#$00,d3
	moveq	#$01,d0
E683	lsl.w	#$1,d6
	bne.s	E684
	move.w	(a0)+,d6
	move	#$0010,ccr
	roxl.w	#$1,d6
E684	roxl.w	#$1,d3
	dbf	d0,E683
	moveq	#$00,d2
	moveq	#$07,d0
E685	lsl.w	#$1,d6
	bne.s	E686
	move.w	(a0)+,d6
	move	#$0010,ccr
	roxl.w	#$1,d6
E686	roxl.w	#$1,d2
	dbf	d0,E685
	neg.w	d2
	add.w	d5,d2
	subq.w	#$1,d2
	and.w	d7,d2
	addq.w	#$1,d3
	moveq	#$00,d0
E687	cmp.w	d0,d3
	blt.s	E678
	move.w	d2,d1
	add.w	d0,d1
	and.w	d7,d1
	move.b	$00(a2,d1.w),d1
	move.b	d1,(a1)+
	move.b	d1,$00(a2,d5.w)
	addq.w	#$1,d5
	and.w	d7,d5
	addq.w	#$1,d0
	bra.s	E687

E688	move.w	d5,-$1788(a4)
	suba.l	a5,a1
	move.l	a1,d0
	movem.l	(a7)+,d2-d7/a2-a3/a5
	rts	

