*** Bootblock Intro: REBELS megademo

Start:
	dc.b	"DOS",0
	dc.l	0,$370
Main:
	bsr.b	lb_0034
	lea	dosname(pc),a1
	move.l	4.w,a6
	jsr	-96(a6)
	move.l	d0,a0
	move.l	22(a0),a0
	moveq	#0,d0
	rts	
dosname	dc.b	"dos.library",0
	even
lb_0034
	movem.l	d0-a6,-(a7)
	lea	$60000,a0
	move	#($280/4)-1,d0
.clr	clr.l	(a0)+
	dbf	d0,.clr
	move.l	4.w,a6
	move.l	$9c(a6),a0
	move.w	#$8180,$00dff096
	move.l	50(a0),lb_0186
	move.l	#coplist,50(a0)
	jsr	-$0084(a6)
lb_009e	btst	#6,$bfe001
	beq.w	lb_0168
	btst	#$a,$dff016
	beq.w	lb_0168
	cmpi.b	#$20,$dff006
	bne.b	lb_009e
	btst	#0,$dff005
	bne.b	lb_009e
	cmp.b	#1,lb_0310
	beq.b	lb_013c
	move.l	lb_0182,a1
	lea	$60004,a2
	moveq	#6,d3
lb_00ea	moveq	#1,d4
lb_00ee	move.b	(a1)+,d0
	moveq	#7,d1
lb_00f4	btst	d1,d0
	beq.b	lb_0136
	moveq	#-1,d2
lb_00fe	move	d2,(a2)+
	dbf	d1,lb_00f4
	dbf	d4,lb_00ee
	addq.l	#8,a2
	dbf	d3,lb_00ea
	cmpa.l	#lb_0400+$e,a1
	beq.b	lb_0168
	move.l	a1,lb_0182
	move.b	#1,lb_0310
	move	#$0fff,lb_0208
	bra.b	lb_009e
lb_0136	clr	d2
	bra.b	lb_00fe
lb_013c	subq.b	#1,lb_030f
	bne.w	lb_009e
	move.b	#5,lb_030f
	sub	#$0111,lb_0208
	bne.w	lb_009e
	clr.b	lb_0310
	bra.w	lb_009e
lb_0168	move.l	lb_0186,50(a0)
	move	#$8020,$dff096
	jsr	-$008a(a6)
	movem.l	(a7)+,d0-a6
	rts	
lb_0182	dc.l	lb_0312
lb_0186	dc.l	0
coplist:
 dc.w $008e,$2c81,$0090,$2cc1
 dc.w $0092,$0078,$0094,$0088
 dc.w $0102,$8889,$0120,$0000
 dc.w $0122,$0000,$0180,$0000
 dc.w $0100,$0200,$0182,$0000
 dc.w $0184,$0f46,$0186,$0f46
 dc.w $0108,$0000,$010a,$0000
 dc.w $00e0,$0004,$00e2,$0298
 dc.w $00e4,$0004,$00e6,$029e
 dc.w $4c09,$fffe,$0100,$2200
 dc.w $4d09,$fffe,$0182,$0824
 dc.w $5409,$fffe,$0100,$0200
 dc.w $0092,$0038,$0094,$00d0
 dc.w $00e0,$0006,$00e2,$0000
 dc.w $0102,$0000,$0108,$ffd8
 dc.w $010a,$ffd8,$0182
lb_0208	dc.w	$0fff
 dc.w $6c09,$fffe,$0100,$1200
 dc.w $7c09,$fffe,$00e2,$0028
 dc.w $8c09,$fffe,$00e2,$0050
 dc.w $9c09,$fffe,$00e2,$0078
 dc.w $ac09,$fffe,$00e2,$00a0
 dc.w $bc09,$fffe,$00e2,$00c8
 dc.w $cc09,$fffe,$00e2,$00f0
 dc.w $dc09,$fffe,$00e2,$0118
 dc.w $de09,$fffe,$0100,$0200
 dc.w $0092,$0078,$0094,$0090
 dc.w $0182,$0000,$0184,$0fb4
 dc.w $0186,$0fb4,$0102,$0001
 dc.w $0108,$0000,$010a,$0000
 dc.w $00e0,$0004,$00e2,$02c6
 dc.w $00e4,$0004,$00e6,$02ce
 dc.w $f609,$fffe,$0100,$2200
 dc.w $f709,$fffe,$0182,$0752
 dc.w $fe09,$fffe,$0100,$0200
 dc.w $ffff,$fffe,$fcfe,$fcfe
 dc.w $c07e,$c6c0,$c6c0,$c0c0
 dc.w $c6c0,$c6c0,$c0c0,$fcfc
 dc.w $fcfc,$c07c,$c6c0,$c6c0
 dc.w $c006,$c6c0,$c6c0,$c006
 dc.w $c6fe,$fcfe,$fefc,$0000
 dc.w $0000,$0000,$c6fe,$7c7c
 dc.w $fcfe,$c67c,$eec0,$c6c6
 dc.w $c6c0,$eec6,$fec0,$c0c6
 dc.w $c6c0,$fec6,$d6fc,$defe
 dc.w $c6fc,$d6c6,$c6c0,$c6c6
 dc.w $c6c0,$c6c6,$c6c0,$c6c6
 dc.w $c6c0,$c6c6,$c6fe,$7ec6
 dc.w $fcfe,$c67c,$0000,$0000
 dc.w $0000,$0000
 	dc.b	0
lb_030f	dc.b	5
lb_0310	dc.b	0,0
lb_0312
 dc.w $02ff,$0281,$0281,$0281
 dc.w $0281,$0281,$02ff,$00ff
 dc.w $0081,$0081,$00ff,$0001
 dc.w $0001,$00ff,$00ff,$0081
 dc.w $0081,$00ff,$0081,$0081
 dc.w $00ff,$00ff,$0001,$0001
 dc.w $0001,$0001,$0001,$0001
 dc.w $00ff,$0080,$0080,$00ff
 dc.w $0081,$0081,$00ff,$00ff
 dc.w $0080,$0080,$00ff,$0001
 dc.w $0001,$00ff,$0081,$0081
 dc.w $0081,$00ff,$0001,$0001
 dc.w $0001,$00ff,$0001,$0001
 dc.w $00ff,$0001,$0001,$00ff
 dc.w $00ff,$0001,$0001,$00ff
 dc.w $0080,$0080,$00ff,$0001
 dc.w $0001,$0001,$0001,$0001
 dc.w $0001,$0001,$00ff,$0081
 dc.w $0081,$0081,$0081,$0081
 dc.w $00ff,$0001,$0001,$0001
 dc.w $fe01,$0001,$0001,$0001
 dc.w $00ff,$0001,$0001,$feff
 dc.w $0080,$0080,$00ff,$00ff
 dc.w $0001,$0001,$feff,$0001
 dc.w $0001,$00ff,$0081,$0081
 dc.w $0081,$feff,$0001,$0001
 dc.w $0001,$00ff,$0080,$0080
 dc.w $feff,$0001,$0001,$00ff
 dc.w $f5cf,$8528,$8528,$e5ce
 dc.w $8528,$8528,$852f
lb_0400
end:
	dcb.b	512*2,0
