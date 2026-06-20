; flames.asm by Kyzer/CSG
; generates a row of flames
	include	cados.asm

cop_x	set	11*4
cop_y	set	60
cop_l	set	55
cop_t	set	303-(cop_y*2)
bytsrow	set	cop_x*4+8
copsize	set	20+bytsrow*cop_y
matsize	set	(cop_x+2)*cop_y

	move.l	#1000,d0
Fire	move.w	d0,-(sp)
	move.l	#copsize*2,d0
	moveq	#1,d1
	jsr	_AllocMem
	tst.l	d0
	beq	.nocop
	lea	.mem(pc),a0
	move.l	d0,(a0)
	move.l	d0,4(a0)
	add.l	#copsize,d0
	move.l	d0,8(a0)
	move.l	#matsize,d0
	moveq	#0,d1
	jsr	_AllocMem
	tst.l	d0
	beq	.nomat
	lea	.matrix(pc),a0
	move.l	d0,(a0)

; gen copperlist
	get.l	.logcop,a0
	get.l	.phycop,a1
	move.w	#cop_y-1,d7
	move.w	#cop_t*$100+cop_l,d0
	moveq.w	#2,d1
.ycop	move.w	d0,d2
.noskip	move.l	#$1800000,(a0)+
	move.l	#$1800000,(a1)+
.go	move.w	d0,(a0)+
	add.w	d1,d0
	move.w	d0,(a1)+
	neg.w	d1
	move.w	#$fffe,(a0)+
	move.w	#$fffe,(a1)+
	moveq.w	#cop_x-1,d6
.xcop	move.l	#$1800000,(a0)+
	move.l	#$1800000,(a1)+
	dbf	d6,.xcop
	add.w	#$0200,d0	; 2 lines instead of 1
	dbf	d7,.ycop
	move.l	#$fffffffe,(a0)+
	move.l	#$fffffffe,(a1)+

	lea	.matrix(pc),a6
	move.l	(a6),a6
	lea	cop_x(a6),a6
	lea	.seed(pc),a5
	move.l	#$f0f0f0f0,(a5)
	move.w	(sp)+,d0
	sub.w	#100+1,d0

	lea	.logcop(pc),a0
	setcop	(a0)
	dmaon	COPPER

.loop	move.w	d0,-(sp)
	bsr.s	.spark
	move.w	(sp)+,d0
	dbra	d0,.loop
	move.w	#100-1,d0
.out	move.w	d0,-(sp)
	bsr.s	.extinguish
	move.w	(sp)+,d0
	dbra	d0,.out
.done	dmaoff	COPPER

	lea	.matrix(pc),a0
	move.l	(a0),d0
	jsr	_FreeMem
.nomat	lea	.mem(pc),a0
	move.l	(a0),d0
	jsr	_FreeMem
.nocop	rts

.mem	dc.l	0
.logcop	dc.l	0
.phycop	dc.l	0
.matrix	dc.l	0
.seed	dc.l	0

.extinguish
	lea	(cop_y-1)*cop_x(a6),a0
	move.w	#(cop_x/4)-1,d2
.waa	move.l	#0,(a0)+
	dbra	d2,.waa
	bra.s	.fire

.spark	lea	(cop_y-1)*cop_x(a6),a0
	move.w	#(cop_x/4)-1,d2
	moveq	#0,d1
	move.l	(a5),d0
.rnd	add.l	d1,d0
	swap	d0
	add.l	d0,d1
	move.l	d0,(a0)+
	dbra	d2,.rnd
	move.l	d0,(a5)
.fire	lea	.logcop(pc),a0
	move.l	(a0),d1
	movem.l	(a0),d0/d1
	exg.l	d0,d1
	movem.l	d0/d1,(a0)
	vsync
	setcop	d0
	move.l	d1,a2
	move.l	a6,a0
	lea	.cols(pc),a3
	lea	cop_x(a6),a1
	move.w	#cop_y-2,d2
	moveq	#0,d0
	moveq	#2,d4
	moveq	#1,d7
	moveq	#(cop_x/4)-1,d6
	move.w	d0,d5
	move.b	d5,d3
; d0=calc d1=x d2=y d3=#0 d4=#2 d5=ander d6=x width d7=#1
.y	move.w	d6,d1
	addq.l	#8,a2
.x	move.b	(a1)+,d0
	add.b	(a0),d0
	roxr.b	d7,d0
	sub.b	d7,d0
	bcc.s	1$
	move.b	d3,d0
1$	move.b	d0,(a0)+
	addq.l	#2,a2
	move.b	d0,d5
	lsr.w	d4,d5
	move.w	(a3,d5.w*2),d0
	move.w	d0,(a2)+

	move.b	(a1)+,d0
	add.b	(a0),d0
	roxr.b	d7,d0
	sub.b	d7,d0
	bcc.s	2$
	move.b	d3,d0
2$	move.b	d0,(a0)+
	addq.l	#2,a2
	move.b	d0,d5
	lsr.w	d4,d5
	move.w	(a3,d5.w*2),d0
	move.w	d0,(a2)+

	move.b	(a1)+,d0
	add.b	(a0),d0
	roxr.b	d7,d0
	sub.b	d7,d0
	bcc.s	3$
	move.b	d3,d0
3$	move.b	d0,(a0)+
	addq.l	#2,a2
	move.b	d0,d5
	lsr.w	d4,d5
	move.w	(a3,d5.w*2),d0
	move.w	d0,(a2)+

	move.b	(a1)+,d0
	add.b	(a0),d0
	roxr.b	d7,d0
	sub.b	d7,d0
	bcc.s	4$
	move.b	d3,d0
4$	move.b	d0,(a0)+
	addq.l	#2,a2
	move.b	d0,d5
	lsr.w	d4,d5
	move.w	(a3,d5.w*2),d0
	move.w	d0,(a2)+

	dbra	d1,.x
	dbra	d2,.y
	rts

.cols	dc.w	$000,$100,$200,$300,$400,$500,$600,$700,$800,$900,$a00,$b00,$c00,$d00,$e00,$f00
	dc.w	$f00,$f10,$f20,$f30,$f40,$f50,$f60,$f70,$f80,$f90,$fa0,$fb0,$fC0,$fd0,$fe0,$ff0
	dc.w	$ff0,$ff1,$ff2,$ff3,$ff4,$ff5,$ff6,$ff7,$ff8,$ff9,$ffa,$ffb,$ffc,$ffd,$ffe,$fff
	dc.w	$fff,$fff,$fff,$fff,$fff,$fff,$fff,$fff,$fff,$fff,$fff,$fff,$fff,$fff,$fff,$fff

