; mc1212_routine.s	= linedraw.s			; only linedraw-routine
; from disk2/linedraw
; no explanation in MW_series
	
	swid=40

linedraw:
	cmp.w	d0,d2
	bne.s	ld_not1pix
	cmp.w	d1,d3
	bne.s	ld_not1pix
	rts
ld_not1pix:
	movem.l	d4/d7/a3-a4,-(a7)
	moveq	#0,d7
	sub.w	d0,d2
	bge.s	ld_xok
	neg.w	d2
	addq.w	#2,d7
	ld_xok:
	sub.w	d1,d3
	bge.s	ld_yok
	neg.w	d3
	addq.w	#4,d7
ld_yok:
	cmp.w	d3,d2
	bgt.s	ld_xyok
	bne.s	ld_not45
	add.w	#16,d7
ld_not45:
	exg	d2,d3
	addq.w	#8,d7
ld_xyok:
	add.w	d3,d3
	move.w	d3,d4
	sub.w	d2,d4
	add.w	d3,d3
	move.w	d3,a3
	add.w	d2,d2
	add.w	d2,d2
	sub.w	d2,d3
	mulu	#swid,d1
	move.l	a0,a4
	add.w	d1,a4
	move.w	d0,d1
	lsr.w	#3,d1
	add.w	d1,a4
	andi.w	#$f,d0
	ror.w	#4,d0
	add.w	#$bc8,d0
	swap	d0
	move.w	(a1,d7.w),d0
	lsl.w	#4,d2
	addq.w	#2,d2
ld_wldraw:
	btst	#6,$2(a2)
	bne.s	ld_wldraw
	move.l	d0,$40(a2)
	move.w	d3,$64(a2)
	move.w	a3,$62(a2)
	move.w	d4,$52(a2)
	move.l	a4,$48(a2)
	move.l	a4,$54(a2)
	move.w	d2,$58(a2)
	movem.l	(a7)+,d4/d7/a3-a4
	rts

initlinedraw:
	lea.l	screen(pc),a0
	lea.l	octant(pc),a1
	move.l	#$dff000,a2
waitinit:
	btst	#6,$2(a2)
	bne.s	waitinit
	move.l	#-1,$44(a2)
	move.l	#$ffff8000,$72(a2)
	move.w	#swid,$60(a2)
	move.w	#swid,$66(a2)
	rts

octant:
	dc.w	$0051,$0055,$0059,$005d
	dc.w	$0041,$0049,$0045,$004d
	dc.w	$0011,$0015,$0019,$001d
	dc.w	$0001,$0009,$0005,$000d

