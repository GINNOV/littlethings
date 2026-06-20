; mc1217.s				; initial bitplane program
; from disk2/diverse
; explanation on letter_12.pdf / p. 16
; no explanation in MW_Serie

; SEKA>ks	; (optional)
; Sure? y
; SEKA>r
; FILENAME>mc1217.s
; SEKA>a
; OPTIONS>
; No errors
; SEKA>j

start:
	move.w	#$4000,$dff09a
	move.w	#$01a0,$dff096

	lea.l	screen(pc),a1
	lea.l	bplcop+2(pc),a2
	move.l	a1,d1
	move.w	d1,4(a2)
	swap	d1
	move.w	d1,(a2)

	lea.l	copper(pc),a1
	move.l	a1,$dff080

	move.w	#$8180,$dff096

main:
	btst	#6,$bfe001
	bne.s	main

	move.l	4.w,a6
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
;	dc.w	$0090,$f4c1
	dc.w	$0090,$38c1
	dc.w	$0092,$0038
	dc.w	$0094,$00d0
	dc.w	$0180,$0000
	dc.w	$0182,$0ff0
	dc.w	$2c01,$fffe
bplcop:
	dc.w	$00e0,$0000
	dc.w	$00e2,$0000
	dc.w	$0100,$1200
	dc.w	$ffdf,$fffe
	dc.w	$2c01,$fffe
	dc.w	$0100,$0200
	dc.w	$ffff,$fffe

screen:
	blk.w	5120,$5555

	end
	
