; mc1203.s	= lace.s
; from disk2/interlace
; explanation in letter_12.pdf / p. 05
; no explanation in MW_series	
	
; SEKA>ks	; (optional)
; Sure? y
; SEKA>r
; FILENAME>mc1203.s
; SEKA>a
; OPTIONS>
; No errors
; SEKA>ri
; FILENAME>screen_lace
; BEGIN>screen
; END>
; SEKA>j

start:	
	move.w	#$4000,$dff09a
	move.w	#$01a0,$dff096

	lea.l	screen(pc),a1
	lea.l	bplcop1(pc),a2
	lea.l	bplcop2(pc),a3
	move.l	a1,d1
	add.w	#80,a1
	move.l	a1,d2
	move.w	d1,6(a2)
	move.w	d2,6(a3)
	swap	d1
	swap	d2
	move.w	d1,2(a2)
	move.w	d2,2(a3)

	lea.l	copper2(pc),a1
	lea.l	coppt1(pc),a2
	move.l	a1,d1
	move.w	d1,6(a2)
	swap	d1
	move.w	d1,2(a2)

	lea.l	copper1(pc),a1
	lea.l	coppt2(pc),a2
	move.l	a1,d1
	move.w	d1,6(a2)
	swap	d1
	move.w	d1,2(a2)

	move.w	#$8204,$dff100

wait:
	move.l	$dff004,d0
	andi.l	#$8001ff00,d0
	cmp.l	#$80006400,d0
	bne.s	wait

	move.l	a1,$dff080
	move.w	#$0000,$dff088

	move.w	#$8180,$dff096

main:
	btst	#6,$bfe001
	bne.s	main

	move.w	#$0080,$dff096

	move.l	4.w,a6
	move.l	156(a6),a6
	move.l	38(a6),$dff080
	move.w	#$0000,$dff088

	move.w	#$80a0,$dff096
	rts

copper1:
	dc.w	$2001,$fffe
	dc.w	$0102,$0000
	dc.w	$0104,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050
	dc.w	$008e,$2c81
	dc.w	$0090,$2cc1
	dc.w	$0092,$003c
	dc.w	$0094,$00d4
	dc.w	$0180,$0000
	dc.w	$0182,$0f70

	dc.w	$2c01,$fffe
	dc.w	$0100,$9204

bplcop1:
	dc.w	$00e0,$0000
	dc.w	$00e2,$0000

	dc.w	$ffdf,$fffe
	dc.w	$2c01,$fffe
	dc.w	$0100,$8204

coppt1:
	dc.w	$0080,$0000
	dc.w	$0082,$0000

	dc.w	$0088,$0000

copper2:
	dc.w	$2001,$fffe
	dc.w	$0102,$0000
	dc.w	$0104,$0000
	dc.w	$0108,$0050
	dc.w	$010a,$0050
	dc.w	$008e,$2c81
	dc.w	$0090,$2cc1
	dc.w	$0092,$003c
	dc.w	$0094,$00d4
	dc.w	$0180,$0000
	dc.w	$0182,$0f70

	dc.w	$2c01,$fffe
	dc.w	$0100,$9204

bplcop2:
	dc.w	$00e0,$0000
	dc.w	$00e2,$0000

	dc.w	$ffdf,$fffe
	dc.w	$2c01,$fffe
	dc.w	$0100,$8204

coppt2:
	dc.w	$0080,$0000
	dc.w	$0082,$0000

	dc.w	$0088,$0000

screen:
	blk.w	20480,0
	;incbin "screen_lace"

	end
