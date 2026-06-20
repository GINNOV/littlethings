	xref	fst68knode,map68knode,nxt68knode,ins68ksize
;
; Nolist attend dans D4 la valeur de sortie
;
ISearch_nosize:
	lea	fst68knode,a1
	lea	map68knode,a2
	lea	nxt68knode,a3
	move.w	(a0)+,d1
	add.w	(a1),d1
	tst.w	0(a2,d1.w)
	bne.s	.nf
	move.w	0(a3,d1.w),d2
;	ble.s	.dosize			;len>=2
.l1:
	REPT	3
	move.w	(a0)+,d1
	add.w	0(a1,d2.w),d1
	cmp.w	0(a2,d1.w),d2
	bne.s	.nf
	move.w	0(a3,d1.w),d2
	ble.s	.dosize
	ENDR

	move.w	(a0)+,d1
	add.w	0(a1,d2.w),d1
	cmp.w	0(a2,d1.w),d2
	bne.s	.nf
	move.w	0(a3,d1.w),d2
	bgt.s	.l1

.dosize:	move.w	#-1,OpSize
	neg.w	d2
	move	d2,d4
	rts
.nf:	moveq	#-1,d2
	rts

ISearch:
	lea	fst68knode,a1
	lea	map68knode,a2
	lea	nxt68knode,a3
	move.w	(a0)+,d1
	add.w	(a1),d1
	tst.w	0(a2,d1.w)
	bne.s	.nf
	move.w	0(a3,d1.w),d2
;	ble.s	.dosize			;len>=2
.l1:
	REPT	3
	move.w	(a0)+,d1
	add.w	0(a1,d2.w),d1
	cmp.w	0(a2,d1.w),d2
	bne.s	.nf
	move.w	0(a3,d1.w),d2
	ble.s	.dosize
	ENDR

	move.w	(a0)+,d1
	add.w	0(a1,d2.w),d1
	cmp.w	0(a2,d1.w),d2
	bne.s	.nf
	move.w	0(a3,d1.w),d2
	bgt.s	.l1

.dosize:	move.b	tab_car(pc,d0.w),d3
	lea	ins68ksize,a0
	neg.w	d2
	move	d2,d1
	asr.w	#4,d1
	and.b	(a0,d1.w),d3
	beq.s	.badsize
	lea	tab_res(pc),a3
	clr.w	d3
	move.b	(a3,d0.w),d3
	move.w	d3,OpSize
.end:	move	d2,d4
	rts
.nf:	moveq	#-1,d2
	rts
.badsize:	moveq	#-2,d2
	bra.s	.end

tab_car:	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,128,0,64,0,0,0,0,0,0,0,32,0,0,0
	dc.b	16,8,0,4,0,0,0,2,1,0,0,0,0,0,0,0
	dc.b	0,0,128,0,64,0,0,0,0,0,0,0,32,0,0,0
	dc.b	16,8,0,4,0,0,0,2,1,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

tab_res:	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,4,0,0,0,0,0,0,0,2,0,0,0
	dc.b	6,4,0,3,0,0,0,1,5,0,0,0,0,0,0,0
	dc.b	0,0,0,0,4,0,0,0,0,0,0,0,2,0,0,0
	dc.b	6,4,0,3,0,0,0,1,5,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
