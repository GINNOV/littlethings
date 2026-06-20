; mc1213.s	= vec1.s
; from disk2/vector
; explanation in letter_12.pdf / p. 15
; no explanation in MW_series
	
; SEKA>ks	; (optional)
; Sure? y
; SEKA>r
; FILENAME>mc1213.s
; SEKA>a
; OPTIONS>
; No errors
; SEKA>ri
; FILENAME>sin_vector
; BEGIN>sin
; END>
; SEKA>j	
			
	lnr=12
	pnr=8
start:
	move.w	#$4000,$dff09a
	move.w	#$01a0,$dff096

	lea.l	screen(pc),a1
	lea.l	bplcop(pc),a2
	move.l	a1,d1
	move.w	d1,6(a2)
	swap	d1
	move.w	d1,2(a2)

	lea.l	copper(pc),a1
	move.l	a1,$dff080

	move.w	#$8180,$dff096

main:
	move.l	$dff004,d0
	asr.l	#8,d0
	andi.w	#$1ff,d0
	cmp.w	#270,d0
	bne.s	main

	bsr	clear
	bsr	calc
	bsr	draw

	lea.l	xyzrot(pc),a1
	add.w	#40,(a1)+
	add.w	#-17,(a1)+
	add.w	#33,(a1)

	btst	#6,$bfe001
	bne.s	main

	move.l	4.w,a6
	move.l	156(a6),a6
	move.l	38(a6),$dff080

	move.w	#$8020,$dff096
	rts


clear:
	btst	#6,$dff002
	bne.s	clear
	lea.l	screen(pc),a1
	move.l	a1,$dff054
	clr.w	$dff066
	move.l	#$01000000,$dff040
	move.w	#$4014,$dff058
	rts

draw:
	bsr.s	initlinedraw
	moveq	#lnr-1,d7
	lea.l	lines(pc),a3
	lea.l	coords(pc),a4
drawloop:
	movem.w	(a3)+,d4-d5
	lsl.w	#2,d4
	lsl.w	#2,d5
	move.w	(a4,d4.w),d0
	move.w	2(a4,d4.w),d1
	move.w	(a4,d5.w),d2
	move.w	2(a4,d5.w),d3
	bsr.s	linedraw
	dbra	d7,drawloop
	rts

	swid=40

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

octant:
	dc.w	$0051,$0055,$0059,$005d
	dc.w	$0041,$0049,$0045,$004d
	dc.w	$0011,$0015,$0019,$001d
	dc.w	$0001,$0009,$0005,$000d

calc:
	lea.l	xyzrot(pc),a0
	move.l	(a0)+,d0
	move.w	(a0),d1
	andi.l	#$3ffe3ffe,d0
	andi.w	#$3ffe,d1
	swap	d0
	lea.l	sin(pc),a0
	lea.l	sin+4096(pc),a1
	lea.l	coords(pc),a2
	lea.l	vectors(pc),a3
	moveq	#pnr-1,d7
calcloop:
	movem.w	(a3)+,a4-a6
	move.w	a5,d3
	muls	(a1,d0.w),d3
	move.w	a4,d4
	muls	(a0,d0.w),d4
	add.l	d4,d3
	lsl.l	#1,d3
	swap	d3
	move.w	a4,d4
	muls	(a1,d0.w),d4
	move.w	a5,d5
	muls	(a0,d0.w),d5
	sub.l	d5,d4
	lsl.l	#1,d4
	swap	d4
	swap	d0
	move.w	a6,d5
	muls	(a1,d0.w),d5
	move.w	d4,d6
	muls	(a0,d0.w),d6
	add.l	d6,d5
	lsl.l	#1,d5
	swap	d5
	muls	(a1,d0.w),d4
	move.w	a6,d6
	muls	(a0,d0.w),d6
	sub.l	d6,d4
	lsl.l	#1,d4
	swap	d4
	swap	d0
	move.w	d3,d6
	muls	(a1,d1.w),d6
	move.w	d5,d2
	muls	(a0,d1.w),d2
	add.l	d2,d6
	lsl.l	#1,d6
	swap	d6
	muls	(a1,d1.w),d5
	muls	(a0,d1.w),d3
	sub.l	d3,d5
	asr.l	#3,d5
	swap	d5
	move.w	#10000,d2
	sub.w	d5,d2
	move.w	d2,d3
	muls	d6,d2
	muls	d4,d3
	asr.l	#5,d2
	asr.l	#5,d3
	swap	d2
	swap	d3
	add.w	#160,d2
	add.w	#128,d3
	move.w	d2,(a2)+
	move.w	d3,(a2)+
	dbra	d7,calcloop
	rts

xyzrot:
	dc.w	0,0,0

vectors:
	dc.w	-10000,-10000,10000
	dc.w	10000,-10000,10000
	dc.w	10000,10000,10000
	dc.w	-10000,10000,10000
	dc.w	-10000,-10000,-10000
	dc.w	10000,-10000,-10000
	dc.w	10000,10000,-10000
	dc.w	-10000,10000,-10000

lines:
	dc.w	0,1,1,2,2,3,3,0
	dc.w	4,5,5,6,6,7,7,4
	dc.w	0,4,1,5,2,6,3,7

coords:
	blk.l	pnr,0

sin:
	blk.w	10240,0
	;incbin "sin_vector"

copper:
	dc.w	$0102,$0000
	dc.w	$0104,$0000
	dc.w	$0108,$0000
	dc.w	$010a,$0000

	dc.w	$008e,$2c81
	;dc.w	$0090,$f4c1
	dc.w	$0090,$38c1
	dc.w	$0092,$0038
	dc.w	$0094,$00d0

	dc.w	$0180,$0000
	dc.w	$0182,$0ff0

	dc.w	$2c01,$fffe
	dc.w	$0100,$1200

bplcop:
	dc.w	$00e0,$0000
	dc.w	$00e2,$0000

	dc.w	$ffdf,$fffe
	dc.w	$2c01,$fffe
	dc.w	$0100,$0200
	dc.w	$ffff,$fffe

screen:
	blk.w	5120,0

	end
