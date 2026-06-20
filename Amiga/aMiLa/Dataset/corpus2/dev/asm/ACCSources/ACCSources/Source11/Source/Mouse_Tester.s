	section	pardon?,code_c
	include source:include/hardware.i
	move.l	4,a6
	lea	library,a1
	jsr	-408(a6)
	move.l	d0,base
	move.l	#40*256*3,d0
	move.l	#2,d1
	jsr	-198(a6)
	move.l	d0,b1
	move.w	d0,b1l
	swap	d0
	move.w	d0,b1h
	swap	d0
	add.l	#40*256,d0
	move.l	d0,b2
	move.w	d0,b2l
	swap	d0
	move.w	d0,b2h
	swap	d0
	add.l	#40*256,d0
	move.l	d0,b3
	move.w	d0,b3l
	swap	d0
	move.w	d0,b3h
	lea	$dff000,a5
	move.l	#copper,COP1LCH(a5)
	move.w	#0,COPJMP1(a5)
	move.l	b1,a1
	move.l	#30*256,d0
clear	move.l	#0,(a1)+
	dbra	d0,clear
wait	move.l	b1,a0
	add.l	#160,a0
	move.b	$dff00a,d1
	bsr	bignum
	move.l	b1,a0
	add.l	#480,a0
	move.b	$dff00b,d1
	bsr	bignum
	btst	#6,$bfe001
	bne.s	wait
	move.l	base,a2
	move.l	38(a2),COP1LCH(a5)
	move.l	#40*256*3,d0
	move.l	b1,a1
	jmp	-210(a6)
	even
copper	dc.w	BPLCON0,%11001000000000
	dc.w	BPLCON1,0
	dc.w	BPLCON2,0
	dc.w	BPL1MOD,0
	dc.w	BPL2MOD,0
	dc.w	DIWSTRT,$2981
	dc.w	DIWSTOP,$29c1
	dc.w	DDFSTRT,$3d
	dc.w	DDFSTOP,$d0
	dc.w	BPL1PTL
b1l	dc.w	0,BPL1PTH
b1h	dc.w	0,BPL2PTL
b2l	dc.w	0,BPL2PTH
b2h	dc.w	0,BPL3PTL
b3l	dc.w	0,BPL3PTH
b3h	dc.w	0
	dc.w	$ffff,$fffe
b1	dc.l	0
b2	dc.l	0
b3	dc.l	0
base	dc.l	0
library	dc.b	'graphics.library',0,0

bignum	move.b	d1,d0
	and.l	#$f0,d0
	lsr.l	#4,d0
	bsr	letters
	move.b	d1,d0
	sub.l	#279,a0
	and.l	#15,d0

; a0=address, d0=number

letters	mulu	#7,d0
	add.l	#mine,d0
	move.l	d0,a1
	moveq.l	#6,d0
number	move.b	(a1)+,(a0)
	add.l	#40,a0
	dbra	d0,number
	rts
mine	dc.b	$1c,$22,$22,$22,$22,$22,$1c
	dc.b	$08,$18,$08,$08,$08,$08,$3e
	dc.b	$1c,$22,$02,$04,$08,$10,$3c
	dc.b	$1c,$22,$02,$0c,$02,$22,$1c
	dc.b	$22,$22,$22,$3e,$02,$02,$02
	dc.b	$3e,$22,$20,$1c,$02,$22,$1c
	dc.b	$1c,$22,$20,$3c,$22,$22,$1c
	dc.b	$3e,$04,$08,$10,$20,$20,$20
	dc.b	$1c,$22,$22,$1c,$22,$22,$1c
	dc.b	$1c,$22,$22,$1e,$02,$22,$1c
	dc.b	$1c,$22,$22,$3e,$22,$22,$22
	dc.b	$3c,$22,$22,$3c,$22,$22,$3c
	dc.b	$1c,$22,$20,$20,$20,$22,$1c
	dc.b	$3c,$22,$22,$22,$22,$22,$3c
	dc.b	$3e,$20,$20,$38,$20,$20,$3e
	dc.b	$3e,$20,$20,$3e,$20,$20,$20

