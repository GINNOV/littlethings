; blaze.asm by Kyzer/CSG
; generates a blaze of fire
	include	cados.asm

cop_x	set	4*11
cop_y	set	75
cop_l	set	55
cop_t	set	303-cop_y

bytsrow	set	cop_x*4+8
copsize	set	20+bytsrow*cop_y
matsize	set	cop_x*cop_y*2
	move.l	#1000,d0	;timing

Fire	move.w	d0,-(sp)
	move.l	#copsize*2,d0
	moveq	#CHIP,d1
	jsr	_AllocMem
	move.l	d0,.mem
	beq	.nocop
	move.l	d0,.logcop
	add.l	#copsize,d0
	move.l	d0,.phycop

	move.l	#matsize,d0
	moveq	#FAST,d1
	jsr	_AllocMem
	move.l	d0,.matrix
	beq	.nomat

; gen copperlist
	get.l	.logcop,a0
	get.l	.phycop,a1
	move.w	#cop_y-4,d7
	move.w	#cop_t*$100+cop_l,d0
	moveq.w	#2,d1
.ycop	move.w	d0,d2
	move.l	#$1800000,(a0)+
	move.l	#$1800000,(a1)+
	move.w	d0,(a0)+
	add.w	d1,d0
	move.w	d0,(a1)+
	neg.w	d1
	move.w	#$fffe,(a0)+
	move.w	#$fffe,(a1)+
	moveq.w	#cop_x-1,d6
.xcop	move.l	#$1800000,(a0)+
	move.l	#$1800000,(a1)+
	dbf	d6,.xcop
	add.w	#$0100,d0
	dbf	d7,.ycop
	move.l	#$fffffffe,(a0)+
	move.l	#$fffffffe,(a1)+

	get.l	.matrix,a6
	lea	.seed(pc),a5
	move.l	#$3f3f3f3f,(a5)
	move.w	(sp)+,d7
	sub.w	#40+1,d7

	lea	.phycop(pc),a0
	setcop	(a0)
	dmaon	COPPER
.loop	bsr.s	.spark
	dbra	d7,.loop
	move.w	#40-1,d7
.out	bsr.s	.extinguish
	dbra	d7,.out
.done	dmaoff	COPPER

	move.l	.matrix,d0
	jsr	_FreeMem
.nomat	move.l	.mem,d0
	jsr	_FreeMem
.nocop	rts

.mem	dc.l	0
.logcop	dc.l	0
.phycop	dc.l	0
.matrix	dc.l	0
.seed	dc.l	0


.extinguish
	lea	matsize-(cop_x*4)(a6),a0
	move.w	#cop_x-1,d2
.waa	move.l	#0,(a0)+
	dbra	d2,.waa
	bra.s	.fire

.spark	lea	matsize-(cop_x*2)(a6),a0
	move.w	#(cop_x/2)-1,d2
	moveq	#0,d1
	move.l	(a5),d0
.rnd	add.l	d1,d0
	swap	d0
	add.l	d0,d1
	move.l	d0,(a0)+
	dbra	d2,.rnd
	move.l	d0,(a5)
;
;	|	| fall thru
;	V	V

.fire	vsync
	lea	.logcop(pc),a0
	lea	.phycop(pc),a1
	setcop	(a1)
	move.l	(a0),a4
	move.l	(a1),(a0)
	move.l	a4,(a1)
;a2=.cols a3=matrix_(width-1)x1y a4=copperlist_(width-1)x(-1)y
;d0=y d1=x d2=countup d3=#4 d4=#16 d5=#63 d6=#3
	move.l	a6,a3
	subq.l	#2,a3
	subq.l	#2,a4
	lea	.cols(pc),a2
	moveq	#4,d3
	moveq	#16,d4
	moveq	#63,d5
	moveq	#3,d6
	move.w	#cop_y-1,d0
.y	add.l	d3,a3
	add.l	d4,a4
	moveq	#cop_x-3,d1
.x	move.w	(cop_x*0)-2(a3),d2
	add.w	(cop_x*0)+2(a3),d2
	add.w	(cop_x*2)-2(a3),d2
	add.w	(cop_x*2)+0(a3),d2
	add.w	(cop_x*2)+2(a3),d2
	add.w	(cop_x*4)-2(a3),d2
	add.w	(cop_x*4)+0(a3),d2
	add.w	(cop_x*4)+2(a3),d2
	asr.w	d6,d2	; divide by 8
	and.w	d5,d2
	move.w	d2,(a3)+
	move.w	(a2,d2.w*2),(a4)
	add.l	d3,a4
	dbra	d1,.x
	dbra	d0,.y
	rts

.cols	dc.w	$000,$100,$200,$300,$400,$500,$600,$700,$800,$900,$a00,$b00,$c00,$d00,$e00,$f00
	dc.w	$f00,$f10,$f20,$f30,$f40,$f50,$f60,$f70,$f80,$f90,$fa0,$fb0,$fC0,$fd0,$fe0,$ff0
	dc.w	$ff0,$ff1,$ff2,$ff3,$ff4,$ff5,$ff6,$ff7,$ff8,$ff9,$ffa,$ffb,$ffc,$ffd,$ffe,$fff
	dc.w	$fff,$fff,$fff,$fff,$fff,$fff,$fff,$fff,$fff,$fff,$fff,$fff,$fff,$fff,$fff,$fff

