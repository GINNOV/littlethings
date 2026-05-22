; mc1209.s	= demo1.s
; from disk2/demo
; explanation in letter_12.pdf / p. 07
; no explanation in MW_series			
	
; SEKA>ks	; (optional)
; Sure? y
; SEKA>r
; FILENAME>mc1206.s
; SEKA>a
; OPTIONS>
; No errors
; SEKA>ri
; FILENAME>screen_demo
; BEGIN>screen
; END>
; SEKA>j	
	
start:
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

	lea.l	copper(pc),a1
	move.l	a1,$dff080

	move.w	#$8180,$dff096

wait:
	btst	#6,$bfe001
	bne.s	wait

	move.l	$04.w,a6
	move.l	156(a6),a6
	move.l	38(a6),$dff080

	move.w	#$8020,$dff096
	rts

copper:
	dc.w	$2001,$fffe
	dc.w	$0102,$0000
	dc.w	$0104,$0000
	dc.w	$0108,$0000
	dc.w	$010a,$0000
	dc.w	$008e,$2881
	;dc.w	$0090,$f4c1
	dc.w	$0090,$1ac1
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
	dc.w	$ffff,$fffe

screen:
	blk.w	55328/2,0
	;incbin "screen_demo"
	end
