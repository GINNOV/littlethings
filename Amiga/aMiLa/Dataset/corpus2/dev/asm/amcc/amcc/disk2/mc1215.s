; mc1215.s	= readmouse.s
; from disk2/diverse
; explanation in letter_12.pdf / p. 16
; no explanation in MW_series

rm_xmin=0
rm_xmax=639
rm_ymin=0
rm_ymax=511

readmouse:
	movem.l	d0-d3/a0,-(a7)
	lea.l	rm_oldpos(pc),a0
	move.w	$dff00a,d0
	move.w	d0,d1
	andi.w	#$ff,d0
	lsr.w	#8,d1
	movem.w	(a0)+,d2-d3
	movem.w	d0-d1,-(a0)
	sub.w	d2,d0
	sub.w	d3,d1
	cmp.w	#-128,d0
	bge.s	rm_xnotadd
	add.w	#256,d0
rm_xnotadd:
	cmp.w	#127,d0
	ble.s	rm_xnotsub
	sub.w	#256,d0
rm_xnotsub:
	cmp.w	#-128,d1
	bge.s	rm_ynotadd
	add.w	#256,d1
rm_ynotadd:
	cmp.w	#127,d1
	ble.s	rm_ynotsub
	sub.w	#256,d1
rm_ynotsub:
	add.w	d0,4(a0)
	add.w	d1,6(a0)
	cmp.w	#rm_xmin,4(a0)
	bge.s	rm_xnotsmall
	move.w	#rm_xmin,4(a0)
rm_xnotsmall:
	cmp.w	#rm_xmax,4(a0)
	ble.s	rm_xnotbig
	move.w	#rm_xmax,4(a0)
rm_xnotbig:
	cmp.w	#rm_ymin,6(a0)
	bge.s	rm_ynotsmall
	move.w	#rm_ymin,6(a0)
rm_ynotsmall:
	cmp.w	#rm_ymax,6(a0)
	ble.s	rm_ynotbig
	move.w	#rm_ymax,6(a0)
rm_ynotbig:
	movem.l	(a7)+,d0-d3/a0
	rts
initmouse:
	movem.l	d0-d1/a0,-(a7)
	move.w	$dff00a,d0
	move.w	d0,d1
	andi.w	#$ff,d0
	lsr.w	#8,d1
	lea.l	rm_oldpos+4(pc),a0
	move.w	#rm_xmin,(a0)
	move.w	#rm_ymin,2(a0)
	movem.w	d0-d1,-(a0)
	movem.l	(a7)+,d0-d1/a0
	rts
rm_oldpos:
	dc.w	0,0
mousexy:
	dc.w	0,0

	end
	
