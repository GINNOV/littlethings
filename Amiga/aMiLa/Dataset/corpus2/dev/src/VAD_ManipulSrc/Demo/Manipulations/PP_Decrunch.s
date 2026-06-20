; Procedure:	PP_Decrunch
; Destination:	decrunch PowerPacker file
; In:
;	a0.l	address of the crunched data
;	a1.l	address of the buffer for decrunched
;	d0.l	length of the crunched data
; Out:	none
		
PP_Decrunch	move.l	a1,a3
		lea	4(a0),a5
		add.l	d0,a0
		moveq	#3,d6
		moveq	#7,d7
		moveq	#1,d5
		move.l	a3,a2
		move.l	-(a0),d1
		tst.b	d1
		beq.s	NoEmptyBits
ReadBit00	lsr.l	#1,d5
		bne.s	ReadBitEnd00
GetNextLong00	move.l	-(a0),d5
		roxr.l	#1,d5
ReadBitEnd00	subq.b	#1,d1
		lsr.l	d1,d5
NoEmptyBits	lsr.l	#8,d1
		add.l	d1,a3
LoopCheckCrunch	lsr.l	#1,d5
		bne.s	ReadBitEnd01
GetNextLong01	move.l	-(a0),d5
		roxr.l	#1,d5
ReadBitEnd01	bcs.s	CrunchedBytes
NormalBytes	moveq	#0,d2
Read2BitsRow	moveq	#1,d0
ReadD1_00	moveq	#0,d1
ReadBits_00	lsr.l	#1,d5
		bne.s	RotX_00
GetNext_00	move.l	-(a0),d5
		roxr.l	#1,d5
RotX_00		addx.l	d1,d1
		dbf	d0,ReadBits_00
		add.w	d1,d2
		cmp.w	d6,d1
		beq.s	Read2BitsRow
ReadNormalByte	moveq	#7,d0
ReadD1_01	moveq	#0,d1
ReadBits_01	lsr.l	#1,d5
		bne.s	RotX_01
GetNext_01	move.l	-(a0),d5
		roxr.l	#1,d5
RotX_01		addx.l	d1,d1
		dbf	d0,ReadBits_01
		move.b	d1,-(a3)
		dbf	d2,ReadNormalByte
		cmp.l	a3,a2
		bcs.s	CrunchedBytes
		rts

CrunchedBytes	moveq	#1,d0
ReadD1_03	moveq	#0,d1
ReadBits_03	lsr.l	#1,d5
		bne.s	RotX_03
GetNext_03	move.l	-(a0),d5
		roxr.l	#1,d5
RotX_03		addx.l	d1,d1
		dbf	d0,ReadBits_03
		moveq	#0,d0
		move.b	0(a5,d1.w),d0
		move.w	d1,d2
		cmp.w	d6,d2
		bne.s	ReadOffset
ReadBit02	lsr.l	#1,d5
		bne.s	ReadBitEnd02
GetNextLong02	move.l	-(a0),d5
		roxr.l	#1,d5
ReadBitEnd02	bcs.s	LongBlockOffset
		moveq	#7,d0
LongBlockOffset
ReadD1sub_05	subq.w	#1,d0
ReadD1_05	moveq	#0,d1
ReadBits_05	lsr.l	#1,d5
		bne.s	RotX_05
GetNext_05	move.l	-(a0),d5
		roxr.l	#1,d5
RotX_05		addx.l	d1,d1
		dbf	d0,ReadBits_05
		move.w	d1,d3
Read3BitsRow	moveq	#2,d0
ReadD1_04	moveq	#0,d1
ReadBits_04	lsr.l	#1,d5
		bne.s	RotX_04
GetNext_04	move.l	-(a0),d5
		roxr.l	#1,d5
RotX_04		addx.l	d1,d1
		dbf	d0,ReadBits_04
		add.w	d1,d2
		cmp.w	d7,d1
		beq.s	Read3BitsRow
		bra.s	DecrunchBlock
ReadOffset	subq.w	#1,d0
ReadD1_06	moveq	#0,d1
ReadBits_06	lsr.l	#1,d5
		bne.s	RotX_06
GetNext_06	move.l	-(a0),d5
		roxr.l	#1,d5
RotX_06		addx.l	d1,d1
		dbf	d0,ReadBits_06
		move.w	d1,d3
DecrunchBlock	lea	1(a3,d3.w),a1
		addq.w	#1,d2
DecrunBlockLoop	move.b	-(a1),-(a3)
		dbf	d2,DecrunBlockLoop
EndOfloop	cmp.l	a3,a2
		bcs.w	LoopCheckCrunch
		rts
