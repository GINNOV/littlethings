	; ByteKiller V3.0 DeCrunch-Routine
	; --------------------------------
	; © 1991 SECTION 9 - ASM-One Assembler  

Source = $30000
Dest   = $50000
JumpIn = $50000

	; bei Verwendung von "INCBIN" (siehe unten)
	; "lea Source,a0" durch "lea DeCrDt(pc),a0"
	; ersetzen um dann ggf. mit "wo" zu speichern.
	
	; Die mit '**' gekennzeichneten Zeilen können je
	; nach Verwendung des Source auch weggelassen werden.

	SECTION	ByteKillerV3.0_DeCrunch,CODE
	
DeCr00:	movem.l	d0-a6,-(a7)		**
	lea	Source,a0
	;;lea	DeCrDt(pc),a0		siehe oben
	lea	Dest,a1
	lea	$dff180,a6		**
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	add.l	d0,a0
	move.l	(a0),d0
	move.l	a1,a2
	add.l	d1,a2
	moveq	#3,d5
	moveq	#2,d6
	moveq	#$10,d7
DeCr01:	lsr.l	#1,d0
	bne.b	DeCr02
	bsr.b	DeCr14
DeCr02:	bcs.b	DeCr09
	moveq	#8,d1
	moveq	#1,d3
	lsr.l	#1,d0
	bne.b	DeCr03
	bsr.b	DeCr14
DeCr03:	bcs.b	DeCr11
	moveq	#3,d1
	moveq	#0,d4
DeCr04:	bsr.b	DeCr15
	move.w	d2,d3
	add.w	d4,d3
DeCr05:	moveq	#7,d1
DeCr06:	lsr.l	#1,d0
	bne.b	DeCr07
	bsr.b	DeCr14
DeCr07:	roxl.l	#1,d2
	dbf	d1,DeCr06
	move.b	d2,-(a2)
	dbf	d3,DeCr05
	bra.b	DeCr13
DeCr08:	moveq	#8,d1
	moveq	#8,d4
	bra.b	DeCr04
DeCr09:	moveq	#2,d1
	bsr.b	DeCr15
	cmp.b	d6,d2
	blt.b	DeCr10
	cmp.b	d5,d2
	beq.b	DeCr08
	moveq	#8,d1
	bsr.b	DeCr15
	move.w	d2,d3
	moveq	#$c,d1
	bra.b	DeCr11
DeCr10:	moveq	#9,d1
	add.w	d2,d1
	addq.w	#2,d2
	move.w	d2,d3
	move.b	d3,(a6)			**
DeCr11:	bsr.b	DeCr15
DeCr12:	subq.w	#1,a2
	move.b	0(a2,d2.w),(a2)
	dbf	d3,DeCr12
DeCr13:	cmpa.l	a2,a1
	blt.b	DeCr01
	movem.l	(a7)+,d0-a6		**
	jmp	JumpIn			**
	moveq	#-1,d0			**
	rts	
DeCr14:	move.l	-(a0),d0
	move.w	d7,ccr
	roxr.l	#1,d0
	rts	
DeCr15:	subq.w	#1,d1
	moveq	#0,d2
DeCr16:	lsr.l	#1,d0
	bne.b	DeCr17
	move.l	-(a0),d0
	move.w	d7,ccr
	roxr.l	#1,d0
DeCr17:	roxl.l	#1,d2
	dbf	d1,DeCr16
	rts	
DeCrDt:	;;INCBIN	"ByteKillerV3.0_DataFile"	siehe oben
