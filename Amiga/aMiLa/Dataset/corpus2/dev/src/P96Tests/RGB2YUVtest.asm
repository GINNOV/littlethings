	MACHINE	68020
	include	inc:private/macros.i

	XREF	_Yr_0299
	XREF	_Yg_0587
	XREF	_Yb_0114
	XREF	_C_05
	XREF	_Cr_016874
	XREF	_Cg_033126
	XREF	_Cg_041869
	XREF	_Cb_008131


	move.b	#$ff,d1
	move.b	#$ff,d2
	move.b	#$ff,d3
	move.b	#42*4,d1
	move.b	#38*4,d2
	move.b	#34*4,d3
.YUV422:
; *	Y  =  0.29900 * R + 0.58700 * G + 0.11400 * B
; *	Cb = -0.16874 * R - 0.33126 * G + 0.50000 * B  + CENTERJSAMPLE
; *	Cr =  0.50000 * R - 0.41869 * G - 0.08131 * B  + CENTERJSAMPLE

	PUSH	d2-d4

	and.l	#$ff,d1
	and.l	#$ff,d2
	and.l	#$ff,d3
	
.Y:	lea	_Yr_0299,a1
	move.l	(a1,d1.w*4),d4

	lea	_Yg_0587,a1
	add.l	(a1,d2.w*4),d4

	lea	_Yb_0114,a1
	add.l	(a1,d3.w*4),d4
	
	swap	d4
	tst.w	d4
	bpl	.Y_g0
	
	moveq	#0,d4
.Y_g0:
	cmp.w	#255,d4
	ble	.Y_k255
	
	move.w	#255,d4
.Y_k255:
	move.b	d4,d0
	swap	d0
	move.b	d4,d0

.Cb:	lea	_C_05,a1
	move.l	(a1,d3.w*4),d4

	lea	_Cr_016874,a1
	sub.l	(a1,d1.w*4),d4

	lea	_Cg_033126,a1
	sub.l	(a1,d2.w*4),d4

	swap	d4
	add.w	#128,d4
	tst.w	d4
	bpl	.Cb_g0
	
	moveq	#0,d4
.Cb_g0:
	cmp.w	#255,d4
	ble	.Cb_k255
	
	move.w	#255,d4
.Cb_k255:
	lsl.l	#8,d0
	move.b	d4,d0

.Cr:	lea	_C_05,a1
	move.l	(a1,d1.w*4),d4

	lea	_Cg_041869,a1
	sub.l	(a1,d2.w*4),d4

	lea	_Cb_008131,a1
	sub.l	(a1,d3.w*4),d4

	swap	d4
	add.w	#128,d4
	tst.w	d4
	bpl	.Cr_g0
	
	moveq	#0,d4
.Cr_g0:
	cmp.w	#255,d4
	ble	.Cr_k255
	
	move.w	#255,d4
.Cr_k255:
	swap	d0
	move.b	d4,d0

	move.l	d0,$80000
	POP	d2-d4
	rts
