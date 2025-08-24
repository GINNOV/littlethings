
***************************************
*  Power Packer 2.3b decrunch routine
*  Unreal version
***************************************

	opt	o+,o3-,d+,c-,w-

	;a0 source end
	;a1 destination start
	;a2 source start
decrunch
	move.l	a2,a3
	addq	#8,a3
	cmp.l	a1,a3	;2 start egau
	beq	begin_decrunch
	move.l	a2,a3	;a3 source start
	move.l	a1,a4	;a4 dest start
	sub	#$8,a4
	move.l	a0,d0
	sub.l	a2,d0	;d0 source len (byte)
	move.l	a4,a2	;source start = dest start
	move.l	a2,a0
	add.l	d0,a0	;a0 = source start + len
	addq.l	#4,d0
copy_loop
	move.l	(a3)+,(a4)+
	subq.l	#4,d0
	bpl	copy_loop
begin_decrunch
	movea.l	a1,a2
	lea	data(pc),a5
	move.l	-(a0),d5
	moveq	#0,d1
	move.b	d5,d1
	lsr.l	#8,d5
	adda.l	d5,a1
	move.l	-(a0),d5
	lsr.l	d1,d5
	move.b	#$20,d7
	sub.b	d1,d7
lc3cf06	bsr	lc3cf78
	tst.b	d1
	bne.s	lc3cf2c
	moveq	#0,d2
lc3cf0e	moveq	#2,d0
	bsr.s	lc3cf7a
	add.w	d1,d2
	cmp.w	#3,d1
	beq.s	lc3cf0e
lc3cf1a	move.w	#8,d0
	bsr.s	lc3cf7a
	move.b	d1,-(a1)
	dbra	d2,lc3cf1a
	cmpa.l	a1,a2
	bcs.s	lc3cf2c
	bset	#1,$bfe001	;***
	rts
lc3cf2c	moveq	#2,d0
	bsr.s	lc3cf7a
	moveq	#0,d0
	move.b	0(a5,d1.w),d0
	move.l	d0,d4
	move.w	d1,d2
	addq.w	#1,d2
	cmp.w	#4,d2
	bne.s	lc3cf5e
	bsr.s	lc3cf78
	move.l	d4,d0
	tst.b	d1
	bne.s	lc3cf4c
	moveq	#7,d0
lc3cf4c	bsr.s	lc3cf7a
	move.w	d1,d3
lc3cf50	moveq	#3,d0
	bsr.s	lc3cf7a
	add.w	d1,d2
	cmp.w	#7,d1
	beq.s	lc3cf50
	bra.s	lc3cf62
lc3cf5e	bsr.s	lc3cf7a
	move.w	d1,d3
lc3cf62	move.b	0(a1,d3.w),d0
	move.b	d0,-(a1)
	bchg	#1,$bfe001	;***
	dbra	d2,lc3cf62
	cmpa.l	a1,a2
	bcs.s	lc3cf06
	bset	#1,$bfe001	;***
	rts
lc3cf78	moveq	#1,d0
lc3cf7a	moveq	#0,d1
	subq.w	#1,d0
lc3cf7e	lsr.l	#1,d5
	roxl.l	#1,d1
	subq.b	#1,d7
	bne.s	lc3cf8c
	move.b	#$20,d7
	move.l	-(a0),d5
lc3cf8c	dbra	d0,lc3cf7e
	bset	#1,$bfe001	;***
	rts
	dc.w	0
data	dc.w	$90a	;".."
	dc.w	$b0b	;".."
	dc.w	$4880	;"h€"
	dc.w	$8216	;"‚."
decrunch_end
