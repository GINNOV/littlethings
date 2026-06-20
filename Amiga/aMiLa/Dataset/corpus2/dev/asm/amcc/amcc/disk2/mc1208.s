; mc1208.s	= demo3.s
; from disk2/demo
; explanation in letter_12.pdf / p. 07
; no explanation in MW_series			
	
; SEKA>ks	; (optional)
; Sure? y
; SEKA>r
; FILENAME>mc1208.s
; SEKA>a
; OPTIONS>
; No errors
; SEKA>ri
; FILENAME>screen_demo
; BEGIN>screen
; END>
; SEKA>ri
; FILENAME>font_demo
; BEGIN>font
; END>
; SEKA>j		
	
	move.w	#$4000,$dff09a
	move.w	#$01a0,$dff096

	lea.l	screen(pc),a1
	lea.l	colcop+2(pc),a2
	moveq	#15,d0
colloop:
	move.w	(a1)+,(a2)
	addq.l	#4,a2
	dbra	d0,colloop

	lea.l	bplcop+2(pc),a2
	add.w	#96,a1
	move.l	a1,d1
	moveq	#5,d0
bplloop:
	swap	d1
	move.w	d1,(a2)
	swap	d1
	move.w	d1,4(a2)
	addq.l	#8,a2
	add.l	#9200,d1
	dbra	d0,bplloop

	lea.l	screen2(pc),a1
	lea.l	bplcop2(pc),a2
	move.l	a1,d1
	move.w	d1,6(a2)
	swap	d1
	move.w	d1,2(a2)

	lea.l	copper(pc),a1
	move.l	a1,$dff080

	move.w	#$8180,$dff096

wait:
	move.l	$dff004,d0
	asr.l	#8,d0
	andi.w	#$1ff,d0
	cmp.w	#100,d0
	bne.s	wait

	bsr	scroll

	btst	#6,$bfe001
	bne.s	wait

	move.l	$04.w,a6
	move.l	156(a6),a6
	move.l	38(a6),$dff080

	move.w	#$8020,$dff096
	rts

scrollcnt:
	dc.w	0,0

scroll:
	lea.l	scrollcnt(pc),a1
	move.w	(a1),d1
	addq.w	#1,(a1)
	andi.w	#7,d1

	bne.s	nochar

	lea.l	text,a2
	add.w	2(a1),a2
	addq.w	#1,2(a1)

	moveq	#0,d1
	move.b	(a2),d1

	cmp.b	#255,d1
	bne.s	noendtext
	clr.w	2(a1)
	moveq	#32,d1
noendtext:

	sub.w	#32,d1
	lsl.w	#1,d1

	lea.l	contab(pc),a2
	moveq	#0,d2
	moveq	#0,d3
	move.b	(a2,d1.w),d2
	move.b	1(a2,d1.w),d3

	mulu	#1280,d2
	mulu	#3,d3

	add.w	d3,d2

	lea.l	font(pc),a1
	lea.l	screen2+40(pc),a2

	add.w	d2,a1

	moveq	#31,d0
putcharloop:
	move.b	(a1),(a2)
	move.b	1(a1),1(a2)
	move.b	2(a1),2(a2)
	add.w	#40,a1
	add.w	#44,a2
	dbra	d0,putcharloop

nochar:
	btst	#6,$dff002
	bne.s	nochar

	lea.l	screen2+1406(pc),a1

	move.l	a1,$dff054
	move.l	a1,$dff050
	clr.w	$dff066
	clr.w	$dff064
	move.l	#-1,$dff044
	move.w	#$39f0,$dff040
	move.w	#$0002,$dff042
	move.w	#$0816,$dff058
	rts

copper:
	dc.w	$2001,$fffe
	dc.w	$0102,$0000
	dc.w	$0104,$0000
	dc.w	$0108,$0000
	dc.w	$010a,$0000
	dc.w	$008e,$2881
	dc.w	$0090,$f4c1
	dc.w	$0090,$3bc1
	dc.w	$0092,$0038
	dc.w	$0094,$00d0

colcop:
	dc.w	$0180,$0000
	dc.w	$0182,$0000
	dc.w	$0184,$0000
	dc.w	$0186,$0000
	dc.w	$0188,$0000
	dc.w	$018a,$0000
	dc.w	$018c,$0000
	dc.w	$018e,$0000
	dc.w	$0190,$0000
	dc.w	$0192,$0000
	dc.w	$0194,$0000
	dc.w	$0196,$0000
	dc.w	$0198,$0000
	dc.w	$019a,$0000
	dc.w	$019c,$0000
	dc.w	$019e,$0000

	dc.w	$2801,$fffe
	dc.w	$0100,$6a00

bplcop:
	dc.w	$00e0,$0000
	dc.w	$00e2,$0000
	dc.w	$00e4,$0000
	dc.w	$00e6,$0000
	dc.w	$00e8,$0000
	dc.w	$00ea,$0000
	dc.w	$00ec,$0000
	dc.w	$00ee,$0000
	dc.w	$00f0,$0000
	dc.w	$00f2,$0000
	dc.w	$00f4,$0000
	dc.w	$00f6,$0000

	dc.w	$ffdf,$fffe
	dc.w	$0e01,$fffe
	dc.w	$0100,$0200

	dc.w	$0108,$0004
	dc.w	$010a,$0004
	dc.w	$0182,$0ff0

	dc.w	$0f01,$fffe
	dc.w	$0100,$1200

bplcop2:
	dc.w	$00e0,$0000
	dc.w	$00e2,$0000

	dc.w	$2f01,$fffe
	dc.w	$0100,$0200

	dc.w	$ffff,$fffe

contab:
	dc.w	$030c
	dc.w	$020a
	dc.w	$0000
	dc.w	$0000
	dc.w	$0000
	dc.w	$0000
	dc.w	$0000
	dc.w	$030b
	dc.w	$020b
	dc.w	$020c
	dc.w	$0308
	dc.w	$0305
	dc.w	$0301
	dc.w	$0307
	dc.w	$0300
	dc.w	$0306
	dc.w	$0200
	dc.w	$0201
	dc.w	$0202
	dc.w	$0203
	dc.w	$0204
	dc.w	$0205
	dc.w	$0206
	dc.w	$0207
	dc.w	$0208
	dc.w	$0209
	dc.w	$0302
	dc.w	$0303
	dc.w	$0309
	dc.w	$0304
	dc.w	$030a
	dc.w	$0000
	dc.w	$0000
	dc.w	$0000
	dc.w	$0001
	dc.w	$0002
	dc.w	$0003
	dc.w	$0004
	dc.w	$0005
	dc.w	$0006
	dc.w	$0007
	dc.w	$0008
	dc.w	$0009
	dc.w	$000a
	dc.w	$000b
	dc.w	$000c
	dc.w	$0100
	dc.w	$0101
	dc.w	$0102
	dc.w	$0103
	dc.w	$0104
	dc.w	$0105
	dc.w	$0106
	dc.w	$0107
	dc.w	$0108
	dc.w	$0109
	dc.w	$010a
	dc.w	$010b
	dc.w	$010c

font:
	blk.w	5120/2,0
	;incbin "FONT_demo"
screen2:
	blk.w	1408/2,0	
screen:
	blk.w	55328/2,0
	;incbin "screen_demo"

text:
	dc.b	"AMIGA MC BREV 12 ** DEMO **   ",255

	end

