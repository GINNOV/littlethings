; mc1202.s	= hires.s
; from disk2/hires
; explanation in letter_12.pdf / p. 04
; no explanation in MW_series	
	
; SEKA>ks	; (optional)
; Sure? y
; SEKA>r
; FILENAME>mc1202.s
; SEKA>a
; OPTIONS>
; No errors
; SEKA>ri
; FILENAME>screen_hires
; BEGIN>screen
; END>
; SEKA>j

start:	
	move.w	#$4000,$dff09a
	move.w	#$01a0,$dff096

	lea.l	screen(pc),a1
	move.l	#$dff180,a2
	moveq	#15,d0
colloop:
	move.w	(a1)+,(a2)+
	dbra	d0,colloop

	move.l	a1,d1
	lea.l	bplcop+2(pc),a2
	moveq	#3,d0
bplloop:
	swap	d1
	move.w	d1,(a2)
	swap	d1
	move.w	d1,4(a2)
	addq.l	#8,a2
	add.l	#20480,d1
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
	dc.w	$008e,$2c81
	;dc.w	$0090,$f4c1
	dc.w	$0090,$38c1
	dc.w	$0092,$003c
	dc.w	$0094,$00d4

	dc.w	$2c01,$fffe
	dc.w	$0100,$c200

bplcop:
	dc.w	$00e0,$0000
	dc.w	$00e2,$0000
	dc.w	$00e4,$0000
	dc.w	$00e6,$0000
	dc.w	$00e8,$0000
	dc.w	$00ea,$0000
	dc.w	$00ec,$0000
	dc.w	$00ee,$0000

	dc.w	$ffdf,$fffe
	dc.w	$2c01,$fffe
	dc.w	$0100,$8200
	dc.w	$ffff,$fffe

screen:
	blk.w	81952/2,0
	;incbin "screen_hires"

	end
