
Rage
	move.l	(a0),RG_Picture
	addq.l	#MAGIC_NUMBER,RG_Picture

	move.w	#0,$dff106

	bsr.w	RG_MakePal

	move.l	RG_Picture,d0
	move.w	d0,RGp11l
	swap	d0
	move.w	d0,RGp11h

	swap	d0
	add.l	#80*512,d0
	move.w	d0,RGp12l
	swap	d0
	move.w	d0,RGp12h

	move.l	RG_Picture,d0
	add.l	#80,d0
	move.w	d0,RGp21l
	swap	d0
	move.w	d0,RGp21h

	swap	d0
	add.l	#80*512,d0
	move.w	d0,RGp22l
	swap	d0
	move.w	d0,RGp22h

	move.l	#RG_Copper1,d0
	move.w	d0,RGcop2l
	swap	d0
	move.w	d0,RGcop2h

	move.l	#RG_Copper2,d0
	move.w	d0,RGcop1l
	swap	d0
	move.w	d0,RGcop1h

		move.w	dmaconr+CUSTOM,RG_OldDMACon
		move.w	#$01f0,dmacon+CUSTOM

		move.w	#$83c0,dmacon+CUSTOM

	move.l	#RG_Copper1,$dff080
	move.w	#0,$dff088

	move.w	#$2981,$dff08e	
	move.w	#$29c1,$dff090	
	move.w	#$003c,$dff092	
	move.w	#$00d4,$dff094	
	move.w	#0,$dff102
	move.w	#0,$dff104
	move.w	#80,$dff108
	move.w	#80,$dff10a
	move.w	#$a204,$dff100

	bsr.w	RG_FadeBlack

	move.w	#70,d0
	jsr	Wait
	
	bsr.w	RG_FadeWhite

	move.w	#150,d0
	jsr	Wait
	
	bsr.w	RG_FadeOut

		bset.b	#7,RG_OldDMACon
		move.w	RG_OldDMACon(pc),dmacon+CUSTOM

	clr.l	d0
	rts

RG_MakePal
	movem.l	d0-a6,-(sp)
	lea	RG_Pal,a0
	lea	$dff180,a1
	moveq.l	#1,d0
RG_PalLoop
	move.l	(a0)+,(a1)+
	dbf	d0,RG_PalLoop
	movem.l	(sp)+,d0-a6
	rts
;-----------------------------------------------------
RG_FadeBlack
	lea	RG_Pal,a0
	sub.w	d1,d1
	sub.w	d2,d2
RG_Loop
	lea	RG_Pal,a0
	move.w	#0,RG_Flag
	cmp.w	#$0006,d1
	beq.b	RG_noadd2
	addq.w	#1,d1
	addq.w	#1,RG_Flag
RG_noadd2
	cmp.w	#$0008,d2
	beq.b	RG_noadd
	addq.w	#1,RG_Flag
	addq.w	#1,d2
RG_noadd
	move.w	d1,(a0)+
	move.w	d2,(a0)+
	move.w	d1,(a0)+
	move.w	d2,(a0)+
	move.w	#4,d0
	jsr	Wait

	bsr.w	RG_MakePal

	tst.w	RG_Flag
	bne.w	RG_Loop
	rts
RG_Flag
	dc.w	0
;-----------------------------------------------------------------
RG_FadeWhite
	lea	RG_Pal,a0
	move.w	#15,d4
	sub.w	d2,d2
RG_LoopWhite
	move.w	d2,4(a0)
	move.w	d2,6(a0)
	add.w	#$0111,d2
	moveq.w	#2,d0
	jsr	Wait
	bsr.w	RG_MakePal
	dbra	d4,RG_LoopWhite
	rts

;----------------------------------------------------------------
RG_FadeOut
		move.w	#6,d4

RG_LoopOut	lea	RG_Pal,a0

		move.w	(a0),d0
		lsr.w	#1,d0
		andi.w	#$0777,d0
		move.w	d0,(a0)+

		move.w	(a0),d0
		lsr.w	#1,d0
		andi.w	#$0777,d0
		move.w	d0,(a0)+

		move.w	(a0),d0
		lsr.w	#1,d0
		andi.w	#$0777,d0
		move.w	d0,(a0)+

		move.w	(a0),d0
		lsr.w	#1,d0
		andi.w	#$0777,d0
		move.w	d0,(a0)+

		moveq.w	#6,d0
		jsr	Wait
		bsr.w	RG_MakePal

		dbra	d4,RG_LoopOut

		rts

;----------------------------------------------------------------

RG_Pal
	dc.w	$0,$0,$0,$0
RG_OldDMACon	dc.w	0

	section	Rage_1,data_c

RG_Copper1
	dc.l	$01fc0000
	dc.w	$00e0
RGp11h	dc.w	0
	dc.w	$00e2
RGp11l	dc.w	0
	dc.w	$00e4
RGp12h	dc.w	0
	dc.w	$00e6
RGp12l	dc.w	0
	dc.w	$0080
RGcop1h	dc.w	0
	dc.w	$0082
RGcop1l	dc.w	0
	dc.l	$fffffffe
	
RG_Copper2
	dc.l	$01fc0000
	dc.w	$00e0
RGp21h	dc.w	0
	dc.w	$00e2
RGp21l	dc.w	0
	dc.w	$00e4
RGp22h	dc.w	0
	dc.w	$00e6
RGp22l	dc.w	0
	dc.w	$0080
RGcop2h	dc.w	0
	dc.w	$0082
RGcop2l	dc.w	0
	dc.l	$fffffffe
	
RG_Picture	dc.l	0

