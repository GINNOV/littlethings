
		SECTION	TerazPolska_0,code

TerazPolska

	move.l	(a0),TP_Picture
	addq.l	#MAGIC_NUMBER,TP_Picture

	bsr.w	TP_MakePal

	move.l	TP_Picture,d0
	move.w	d0,p1l
	swap	d0
	move.w	d0,p1h

	swap	d0
	add.l	#40*97,d0
	move.w	d0,p2l
	swap	d0
	move.w	d0,p2h

	swap	d0
	add.l	#40*97,d0
	move.w	d0,p3l
	swap	d0
	move.w	d0,p3h

	swap	d0
	add.l	#40*97,d0
	move.w	d0,p4l
	swap	d0
	move.w	d0,p4h

	swap	d0
	add.l	#40*97,d0
	move.w	d0,p5l
	swap	d0
	move.w	d0,p5h


	move.l	#TP_Copper,$dff080
	clr.l	$dff088

	move.w	#$2981,$dff08e	
	move.w	#$29c1,$dff090	
	move.w	#$0038,$dff092	
	move.w	#$00d0,$dff094	
	move.w	#$0088,$dff102
	clr.w	$dff104
	move.w	#-8,$dff108
	move.w	#-8,$dff10a

	move.w	#70,d0
	jsr	Wait
	
	bsr.w	TP_FadeOut

	move.w	#$7fff,$dff09c
	clr.l	d0
	rts
TP_MakePal
	lea	TP_Palette,a0
	lea	$dff180,a1
	moveq.l	#31,d0
TP_PalLoop
	move.w	(a0)+,(a1)
	adda.w	#2,a1
	dbf	d0,TP_PalLoop
	rts
;-----------------------------------------------------
TP_FadeOut
	lea	TP_Palette,a0
	moveq.l	#31,d4
TP_FLoop
	move.w	#0,TP_Flag
	move.w	(a0),d1
	move.w	d1,d2
	move.w	d2,d3

	and.w	#%0000111100000000,d1
	beq.b	TP_nored
	sub.w	#1<<8,d1
TP_nored
	and.w	#%0000000011110000,d2
	beq.b	TP_nogreen
	sub.w	#1<<4,d2

TP_nogreen
	and.w	#%0000000000001111,d3
	beq.b	TP_noblue
	subq.w	#1,d3
TP_noblue
	or.w	d1,d2
	or.w	d2,d3
	move.w	d3,(a0)+
	beq.b	TP_zero
	addq.w	#1,TP_Flag
TP_zero
	dbf	d4,TP_FLoop
	move.w	#4,d0
	jsr	Wait
	bsr.w	TP_MakePal

	tst.w	TP_Flag
	bne.w	TP_FadeOut
	rts
TP_Flag
	dc.w	0

TP_Palette
	dc.w	$0000,$0a00,$0f55,$0fff,$0e00,$0e00,$0d00,$0c00,$0900,$0800
	dc.w	$0700,$0600,$0500,$0400,$0fdd,$0fbb,$0f99,$0f77,$0f55,$0fed
	dc.w	$0200,$0200,$0fff,$0fff,$0fff,$0fff,$0fff,$0fff,$0fff,$0fff
	dc.w	$0fff,$0fff

	section	TerazPolska_2,data_c
TP_Copper
	dc.l	$00960020
	dc.l	$01fc0003
	dc.l	$01000000
	dc.l	$6f01fffe
	dc.l	$01005200
	dc.w	$00e0
p1h	dc.w	0
	dc.w	$00e2
p1l	dc.w	0
	dc.w	$00e4
p2h	dc.w	0
	dc.w	$00e6
p2l	dc.w	0
	dc.w	$00e8
p3h	dc.w	0
	dc.w	$00ea
p3l	dc.w	0
	dc.w	$00ec
p4h	dc.w	0
	dc.w	$00ee
p4l	dc.w	0
	dc.w	$00f0
p5h	dc.w	0
	dc.w	$00f2
p5l	dc.w	0

	dc.l	$d001fffe
	dc.l	$01000000
	dc.l	$fffffffe
	
TP_Picture	dc.l	0

