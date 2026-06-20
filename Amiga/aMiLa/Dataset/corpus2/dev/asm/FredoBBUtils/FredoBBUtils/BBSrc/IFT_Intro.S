*** INFECT - BootBlock Intro! - with sound, gfx & text
* by Ernie/INFECT
* Great bootintro, totally system friendly.

	dc.b	'DOS',0
	dc.l	0,880
Start:
;	move.l	4.w,a6		;not needed unless you want
				;to execute directly under AsmOne
	movem.l	d2-d7/a2-a6,-(a7)
	move.l	#$140fa,d0
	move.l	#$10002,d1
	jsr	-$00c6(a6)	;allocmem()
	move.l	d0,a5
	lea	lb_024a(pc),a3
	add.l	#$a0fa,d0
	move.l	d0,8(a3)
	lea	coplist(pc),a0
	move.l	d0,d1
	move.l	d0,d2
	moveq	#$50,d3
	add.l	d3,d1
	add.l	#$5000,d2
	move	d0,$26(a0)
	move	d1,$2e(a0)
	move	d2,$36(a0)
	swap	d0
	swap	d1
	swap	d2
	move	d0,$22(a0)
	move	d1,$2a(a0)
	move	d2,$32(a0)
	lea	$6c(a5),a1
	moveq	#33,d7
.copy_coplist
	move.l	(a0)+,(a1)+
	dbf	d7,.copy_coplist
	move.l	$9c(a6),a6	;execbase->gfxbase
	move.l	a5,a1		;rastport
	jsr	-$00c6(a6)	;initrastport()
	move.l	a3,4(a5)
	lea	$0064(a5),a4
	move.l	a4,$c(a5)
	lea	$0096(a4),a3
	move.l	a3,(a4)
	move.l	#$a000,4(a4)
	moveq	#5,d7
	move.l	#$0f200a0d,d4
lb_009a	bsr.b	lb_011a
	move.l	a5,a1
	jsr	-$00b4(a6)	;drawellipse()
	bsr.b	lb_011a
	moveq	#0,d2		;modus
	move.l	a5,a1
	jsr	-$014a(a6)	;flood()
	addi.l	#$1a000000,d4
	dbf	d7,lb_009a
	moveq	#0,d0
	bsr.b	lb_0130
	lea	intro.txt(pc),a3
	moveq	#12,d7
lb_00c0	bsr.b	lb_0118
	move.l	a5,a1
	jsr	-$0132(a6)	;rectfill()
	dbf	d7,lb_00c0
	moveq	#1,d0
	bsr.b	lb_0130
	lea	$dff000,a4
	move	2(a4),$00f6(a5)	;olddma
	move	#$7fff,$0096(a4)
	bsr.b	lb_0152
	lea	$006c(a5),a0
	move.l	a0,$0080(a4)
	moveq	#4,d2
	move	#$0137,d3
lb_00f2	move.b	(a3)+,d1
	bpl.b	lb_0136
	and	#$007f,d1
	move	d1,d0
	move.b	(a3)+,d1
	swap	d1
	move	d0,d1
lb_0102	swap	d1
	move.l	d1,$00f2(a5)
	moveq	#2,d0
	bsr.b	lb_016a
	move.l	$00f2(a5),d1
	swap	d1
	dbf	d1,lb_0102
	bra.b	lb_00f2
lb_0118	move.l	(a3)+,d4
lb_011a	moveq	#3,d6
lb_011c	moveq	#0,d5
	move.b	d4,d5
	lsl	#2,d5
	move.l	d5,-(a7)
	ror.l	#8,d4
	dbf	d6,lb_011c
	movem.l	(a7)+,d0-d3
	rts	
lb_0130	move.l	a5,a1		;rastport
	jmp	-$0156(a6)	;setapen()
lb_0136	beq.b	lb_0184
	cmp.b	#$0d,d1
	bne.b	lb_014c
	moveq	#$20,d1
	moveq	#1,d0
	bsr.b	lb_016a
	moveq	#4,d2
	addq	#8,d3
	bra.b	lb_00f2
lb_014c	moveq	#2,d0
	bsr.b	lb_016a
	bra.b	lb_00f2
lb_0152	move	#$83d3,$0096(a4)
lb_0158	lea	$00ca(a5),a2
	move.l	a2,$00a0(a4)
	move.l	a2,$00b0(a4)
	lea	$00d0(a5),a2
	bra.b	lb_018c
lb_016a	move	d2,$0024(a5)
	move	d3,$0026(a5)
	lea	$00c8(a5),a0
	move.b	d1,(a0)
	move.l	a5,a1
	jsr	-60(a6)		;text()
	addq	#8,d2
	bra.b	lb_0188
lb_0184	bsr.b	lb_0188
	bra.b	lb_0184
lb_0188	dbf	d7,lb_01a8
lb_018c	moveq	#6,d7
	moveq	#3,d4
	moveq	#63,d6
	moveq	#0,d5
	move.b	(a2)+,d5
	beq.b	lb_0158
	lsl	#4,d5
	movem	d4-d6,$00a4(a4)
	addq	#8,d5
	movem	d4-d6,$00b4(a4)
lb_01a8	lea	$bfe001,a0
	bset	#1,(a0)
	btst	#6,(a0)		;leftmouse?
	beq.b	lb_01bc
	jmp	-270(a6)	;waittof()
lb_01bc
	addq.l	#4,sp
	move.l	38(a6),$0080(a4);restore sys coplist
	move	#$7fff,$0096(a4)
	move	$00f6(a5),d0
	bset	#$0f,d0
	move	d0,$0096(a4)
	move.l	#$140fa,d0
	move.l	a5,a1
	movem.l	(a7)+,d2-d7/a2-a6
	jsr	-$00d2(a6)	;freemem()
	lea	dosname(pc),a1
	jsr	-96(a6)
	move.l	d0,a0
	move.l	22(a0),a0
	moveq	#0,d0
	rts	
coplist:
	dc.w	$008e,$2c79,$0090,$2cb9
	dc.w	$0092,$0038,$0094,$00d0
	dc.w	$0102,$0000,$0100,$b600
	dc.w	$0108,$0000,$010a,$0000
	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$00e8,$0000,$00ea,$0000
	dc.w	$0180,$0777,$0182,$0666
	dc.w	$0192,$0bbb,$0184,$0dd8
	dc.w	$0186,$0fd8,$ffff,$fffe
lb_024a
	dc.b	$00,$50,$02,$00,$00,$01,$00,$00
	dc.b	$00,$04,$be,$3a,$00,$5f,$69,$4e
	dc.b	$66,$45,$63,$54,$6b,$5a,$47,$35
	dc.b	$6b,$5a,$47,$35,$78,$5f,$50,$3c
	dc.b	$78,$5f,$50,$3c,$86,$6b,$5a,$43
	dc.b	$86,$6b,$5a,$43,$8e,$6b,$5f,$47
	dc.b	$8e,$71,$5f,$47,$00,$00
intro.txt:
 DC.B $05,$1B,$19,$1C,'(',$1B,'*0B',$18,'F',$1E,'B"M0F',$1A
 DC.B 'M0\',$18,'`',$1E,'\"`(`',$1A,'g&v',$18,'z(v',$1A,$81,'&',$90
 DC.B $10,$9B,$1A,$90,$1E,$94,'(',$94,$10,$9B,'&',$85
 DC.B ' ',$B9,'-',$0D,$99,' -=> This  is a <=-',$0D,$9A,' B'
 DC.B 'ootBlock Intro',$0D,$94,' done by Ernie of INFEC'
 DC.B 'T for',$0D,$0D,$94,' The SCOOPEX'' CeBIT''93 Party'
 DC.B $0D,$0D,$0D,$0D,$8B,' This ain''t a fake -> it'
 DC.B ' ''s just real cool coding',$0D,$8E,' There is sti'
 DC.B 'll some memory left for ASCII',$0D,$92,' But who '
 DC.B 'reads much bootblock text?',$0D,$0D,$0D,$0D,$98
 DC.B ' ',$82,". and don't forget:",$0D,$0D,$8D,' <! INFE'
 DC.B 'CT  there''s NO medicine AGAINST !>',$0D,$0D,$0D
 DC.B $85,' ',$B9,'-',$0D,0

dosname	dc.b	"dos.library",0
End:
	blk.b	512*2,0
