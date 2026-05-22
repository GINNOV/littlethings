* * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* NoisePacker V2.03 PlayRoutine ©1991 Twins of Phenomena. *
* Used registers are d0-d7/a0-a6.     Using lev6irq.      *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

np_data=$60000

np_init:
	lea	np_data,a4
	lea	$dff000,a5
	lea	np_position(pc),a6
	moveq	#2,d0
	moveq	#0,d1
	move.l	a4,a3
np_init1:
	add	(a4)+,a3
	move.l	a3,(a6)+
	dbf	d0,np_init1
	move	(a4)+,d0
	add.l	d0,a3

	move.l	$78.w,(a6)+
	move.l	#$01060100,(a6)+
	move	#$8200,(a6)+
	move.l	d1,(a6)+
	move.l	#np_portup,(a6)+
	move.l	#np_portdown,(a6)+
	move.l	#np_port,(a6)+
	move.l	#np_vib,(a6)+
	move.l	#np_port2,(a6)+
	move.l	#np_vib2,(a6)+
	move.l	#np_volslide,(a6)+
	move.l	#np_arp,(a6)+
	move.l	#np_songjmp,(a6)+
	move.l	#np_setvol,(a6)+
	move.l	#np_pattbreak,(a6)+
	move.l	#np_filter,(a6)+
	move.l	#np_setspeed,(a6)+

	moveq	#0,d0
	move.l	a4,a6
	add	-8(a4),a6
	sub	#12,a6
np_init2:
	move.l	a3,(a4)
	move.l	a3,a2
	move	14(a4),d0
	add	d0,d0
	add.l	d0,a2
	move.l	a2,8(a4)
	move	4(a4),d0
	add	d0,d0
	add.l	d0,a3
	add	#16,a4
	cmp.l	a4,a6
	bne.s	np_init2

	bset	#1,$bfe001
	move	d1,$a8(a5)
	move	d1,$b8(a5)
	move	d1,$c8(a5)
	move	d1,$d8(a5)

	lea	$bfd000,a0
	move.b	#$7f,$d00(a0)
	move	#$2000,$9a(a5)

	move.b	#$08,$e00(a0)
	move.b	#$80,$400(a0)
	move.b	#$01,$500(a0)

	tst.b	$d00(a0)
	move	#$7fff,$9c(a5)
	move.b	#$81,$d00(a0)
	move	#$e000,$9a(a5)
	rts

np_end:	moveq	#0,d0
	lea	$dff000,a5
	move	d0,$a8(a5)
	move	d0,$b8(a5)
	move	d0,$c8(a5)
	move	d0,$d8(a5)
	bclr	#1,$bfe001
	move	#$f,$96(a5)
	move	#$2000,$9a(a5)
	move.l	np_oldirq(pc),$78.w
	rts

np_music:
	moveq	#0,d6
	lea	$dff0d0,a4
	lea	np_block(pc),a6
	subq.b	#1,(a6)
	bhi	np_nonew

	lea	np_position(pc),a3
	move.l	(a3)+,a0
	add	6(a6),a0
	move	(a0),d0
	move.l	(a3)+,a0
	add	d0,a0
	move.l	(a3)+,a1
	add	8(a6),a1
	lea	np_voidat1(pc),a2

	moveq	#8,d0
	moveq	#0,d5
np_loop1:
	moveq	#0,d1
	move	(a0)+,d1
	lea	(a1,d1.l),a3
	move.b	(a3)+,d1
	move.b	(a3)+,d3
	move.b	(a3)+,d4

	move.b	d3,d7
	lsr.b	#4,d7
	move.b	d1,d2
	and	#1,d2
	beq.s	np_loop2
	moveq	#$10,d2
np_loop2:
	lea	np_data-8,a3
	or.b	d7,d2
	bne.s	np_loop3

	move.b	1(a2),d2
	lsl	#4,d2
	add	d2,a3
	bra.s	np_loop4
np_loop3:
	move.b	d2,1(a2)
	lsl	#4,d2
	add	d2,a3
	move	6(a3),4(a2)
np_loop4:
	and	#$f,d3
	move.b	d3,2(a2)
	move.b	d4,3(a2)

	and	#$fe,d1
	beq.s	np_loop5

	move	np_periods-2(pc,d1.w),d7

	subq	#3,d3
	beq	np_setport
	subq	#2,d3
	beq	np_setport

	or	d0,d5
	move.b	d1,(a2)
	move.b	d6,49(a2)
	move	d7,24(a2)

	move.l	(a3)+,(a4)
	move	(a3)+,4(a4)
	addq	#2,a3
	move.l	(a3)+,72(a2)
	move	(a3)+,76(a2)

	subq	#6,d3
	bmi.s	np_loop6
	add	d3,d3
	add	d3,d3
	move.l	42(a6,d3.w),a3
	jmp	(a3)

np_loop5:
	sub	#11,d3
	bmi.s	np_loop6
	add	d3,d3
	add	d3,d3
	move.l	42(a6,d3.w),a3
	jmp	(a3)

np_periods:
	dc.w	$0358,$0328,$02fa,$02d0,$02a6,$0280,$025c,$023a,$021a
	dc.w	$01fc,$01e0,$01c5,$01ac,$0194,$017d,$0168,$0153,$0140
	dc.w	$012e,$011d,$010d,$00fe,$00f0,$00e2,$00d6,$00ca,$00be
	dc.w	$00b4,$00aa,$00a0,$0097,$008f,$0087,$007f,$0078,$0071

np_loop6:
	move	24(a2),6(a4)
np_loop7:
	move	4(a2),8(a4)
	addq	#6,a2
	sub	#$10,a4
	lsr	#1,d0
	bne	np_loop1

	move	d5,$dff096
	move.b	d5,5(a6)
	move.b	1(a6),(a6)
	move.l	#np_irq1,$78.w
	move.b	#$19,$bfde00

	move.l	np_position(pc),a0
	bset	#0,2(a6)
	beq.s	np_break
	addq	#3,8(a6)
	cmp	#192,8(a6)
	bne.s	np_next
np_break:
	move	d6,8(a6)
	addq	#2,6(a6)
	move	6(a6),d0
	cmp	-4(a0),d0
	bne.s	np_next
	move	-2(a0),6(a6)
np_next:rts

np_setvol:
	move.b	d4,5(a2)
	bra.s	np_loop6

np_pattbreak:
	move	d6,2(a6)
	bra.s	np_loop6

np_songjmp:
	move	d6,2(a6)
	move.b	d4,7(a6)
	bra.s	np_loop6

np_setspeed:
	move.b	d4,1(a6)
	bra	np_loop6

np_filter:
	and.b	#$fd,$bfe001
	or.b	d4,$bfe001
	bra	np_loop6

np_setport:
	move.b	d6,50(a2)
	move	d7,26(a2)
	cmp	24(a2),d7
	beq.s	np_clrport
	bge	np_loop7
	move.b	#1,50(a2)
	bra	np_loop7
np_clrport:
	move	d6,26(a2)
	bra	np_loop7

np_nonew:
	lea	np_voidat1(pc),a0
	moveq	#3,d0
np_lop1:moveq	#0,d1
	move.b	2(a0),d1
	beq.s	np_lop2
	subq	#8,d1
	bhi.s	np_lop2
	addq	#7,d1
	add	d1,d1
	add	d1,d1
	move.l	10(a6,d1.w),a3
	jmp	(a3)
np_lop2:addq	#6,a0
	sub	#$10,a4
	dbf	d0,np_lop1
	rts

np_portup:
	moveq	#0,d2
	move.b	3(a0),d2
	sub	d2,24(a0)
	cmp	#$71,24(a0)
	bpl.s	np_portup2
	move	#$71,24(a0)
np_portup2:
	move	24(a0),6(a4)
	bra.s	np_lop2

np_portdown:
	moveq	#0,d2
	move.b	3(a0),d2
	add	d2,24(a0)
	cmp	#$358,24(a0)
	bmi.s	np_portdown2
	move	#$358,24(a0)
np_portdown2:
	move	24(a0),6(a4)
	bra.s	np_lop2

np_arp:	moveq	#0,d2
	move.b	(a6),d2
	sub.b	1(a6),d2
	neg.b	d2
	move.b	np_arplist(pc,d2.w),d2
	beq.s	np_arp0
	subq.b	#2,d2
	beq.s	np_arp2
np_arp1:move.b	3(a0),d2
	lsr	#3,d2
	and	#$e,d2
	bra.s	np_arp3
np_arp2:move.b	3(a0),d2
	and	#$f,d2
	add	d2,d2
np_arp3:add.b	(a0),d2
	cmp	#$48,d2
	bls.s	np_arp4
	moveq	#$48,d2
np_arp4:lea	np_periods-2(pc),a3
	move	(a3,d2.w),6(a4)
	bra	np_lop2
np_arp0:move	24(a0),6(a4)
	bra	np_lop2

np_arplist:
	dc.b 0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1

np_sin:
	dc.b $00,$18,$31,$4a,$61,$78,$8d,$a1,$b4,$c5,$d4,$e0,$eb,$f4,$fa,$fd
	dc.b $ff,$fd,$fa,$f4,$eb,$e0,$d4,$c5,$b4,$a1,$8d,$78,$61,$4a,$31,$18

np_vib:	move.b	3(a0),d3
	beq.s	np_vib2
	move.b	d3,48(a0)
np_vib2:	
	move.b	49(a0),d3
	lsr.b	#2,d3
	and	#$1f,d3
	moveq	#0,d2
	move.b	np_sin(pc,d3.w),d2
	move.b	48(a0),d3
	and	#$f,d3
	mulu	d3,d2
	lsr	#7,d2
	move	24(a0),d3
	tst.b	49(a0)
	bmi.s	np_vibsub
	add	d2,d3
	bra.s	np_vib3
np_vibsub:
	sub	d2,d3
np_vib3:move	d3,6(a4)
	move.b	48(a0),d3
	lsr.b	#2,d3
	and	#$3c,d3
	add.b	d3,49(a0)
	cmp.b	#20,d1
	bne	np_lop2

np_volslide:
	move.b	3(a0),d2
	add.b	d2,5(a0)
	bmi.s	np_vol3
	cmp.b	#$40,5(a0)
	bmi.s	np_vol2
	move	#$40,4(a0)
np_vol2:move	4(a0),8(a4)
	bra	np_lop2

np_vol3:move	d6,4(a0)
	move	4(a0),8(a4)
	bra	np_lop2

np_port:move.b	3(a0),d2
	beq.s	np_port2
	move.b	d2,29(a0)

np_port2:
	move	26(a0),d2
	beq.s	np_rts
	move	28(a0),d3
	tst.b	50(a0)
	bne.s	np_sub
	add	d3,24(a0)
	cmp	24(a0),d2
	bgt.s	np_portok
	move	d2,24(a0)
	move	d6,26(a0)
np_portok:
	move	24(a0),6(a4)
np_rts:	cmp.b	#16,d1
	beq.s	np_volslide
	bra	np_lop2

np_sub:	sub	d3,24(a0)
	cmp	24(a0),d2
	blt.s	np_portok
	move	d2,24(a0)
	move	d6,26(a0)
	move	24(a0),6(a4)
	cmp.b	#16,d1
	beq	np_volslide
	bra	np_lop2

np_irq1:
	tst.b	$bfdd00
	move.b	#$19,$bfde00
	move.l	#np_irq2,$78.w
	move	np_block+4(pc),$dff096
	move	#$2000,$dff09c
	rte

np_irq2:
	tst.b	$bfdd00
	move.l	a6,-(sp)
	lea	np_voidat2(pc),a6
	move.l	(a6)+,$dff0d0
	move	(a6)+,$dff0d4
	move.l	(a6)+,$dff0c0
	move	(a6)+,$dff0c4
	move.l	(a6)+,$dff0b0
	move	(a6)+,$dff0b4
	move.l	(a6)+,$dff0a0
	move	(a6)+,$dff0a4
	move	#$2000,$dff09c
	move.l	np_oldirq(pc),$78.w
	move.l	(sp)+,a6
	rte

np_position:	dc.l	0
np_pattern:	dc.l	0
np_voice:	dc.l	0
np_oldirq:	dc.l	0
np_block:	blk.w	31,0
np_voidat1:	blk.l	18,0
np_voidat2:	blk.l	6,0

