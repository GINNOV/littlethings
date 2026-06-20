ùúùúÿì§‡ÿì§‡ÿì§‡ÿì§‡ÿì§‡ÿì§‡ÿì§‡ÿì§‡ÿì§‡;------------------T--------T
*******************************************************************************
**
**  Picture-preprocessor
**
**  output:
**  a0=save start
**  a1=save end
**
*******************************************************************************

Begin:	lea	RawPicture(pc),a0
	lea	DotPicture(pc),a1
	bsr	PicPreprocess
	lea	DotPicture(pc),a0
	lea	CodePicture,a1
	lea	CodePointers,a2
	bsr	GenerateCode
	lea	CodePointers,a0
	rts

GenerateCode:	moveq	#128-1,d3
	move.l	a1,a4
.nextsojle	move.l	a1,a3
	sub.l	a4,a3
	move.l	a3,(a2)+
	moveq	#0,d2	;gammel farve
.sojleloop	moveq	#0,d0
	move.b	(a0)+,d0	;pos
	cmp.b	#$ff,d0
	bne.b	.ok
	move.w	#$4E75,(a1)+
	dbra	d3,.nextsojle
	rts
.ok	move.w	Instr1(pc),(a1)+
	add.w	d0,d0
	move.w	d0,(a1)+
	move.b	(a0)+,d1	;farve

	eor.b	d1,d2
	btst	#0,d2
	beq.b	.plan0ok
	move.w	Instr2(pc),(a1)+
	clr.w	(a1)+
.plan0ok	btst	#1,d2
	beq.b	.plan1ok
	move.w	Instr2(pc),(a1)+
	move.w	#32,(a1)+
.plan1ok	btst	#2,d2
	beq.b	.plan2ok
	move.w	Instr2(pc),(a1)+
	move.w	#32*2,(a1)+
.plan2ok	btst	#3,d2
	beq.b	.plan3ok
	move.w	Instr2(pc),(a1)+
	move.w	#32*3,(a1)+
.plan3ok
	move.b	d1,d2
	bra.b	.sojleloop

Instr1:	move.w	0(a0),d0		;0=ypos
Instr2:	bchg	d1,(a1,d0.w)



PicWidth:	EQU	16

PicPreprocess:	moveq	#16-1,d3	;bytesøjler
.byteloop	moveq	#7,d2	;bitnummer
.bitloop	moveq	#128-1,d6
	moveq	#0,d5	;gammel farve
	moveq	#0,d0

.sojleloop	moveq	#0,d4	;farve
	btst	d2,(a0)
	beq.b	.plan1ok
	bset	#0,d4
.plan1ok	btst	d2,PicWidth(a0)
	beq.b	.plan2ok
	bset	#1,d4
.plan2ok	btst	d2,PicWidth*2(a0)
	beq.b	.plan3ok
	bset	#2,d4
.plan3ok	btst	d2,Picwidth*3(a0)
	beq.b	.plan4ok
	bset	#3,d4
.plan4ok
	cmp.b	d4,d5
	beq.b	.nextline

	move.b	d4,d5
	move.b	d0,(a1)+
	move.b	d5,(a1)+
.nextline	lea	PicWidth*4(a0),a0
	addq.w	#1,d0
	dbra	d6,.sojleloop
	tst.b	d5
	beq.b	.zero
	move.b	d0,(a1)+
	clr.b	(a1)+
.zero	st	(a1)+
	lea	-128*PicWidth*4(a0),a0
	dbra	d2,.bitloop
	addq.w	#1,a0
	dbra	d3,.byteloop
	rts





	INCDIR	"Work:Code/Sources/HTSAC/FractalCube/"
RawPicture:	INCIFF	"Ant.iff"

DotPicture:	blk.b	100000,0

CodePointers:	blk.l	128,0
CodePicture:	blk.b	100000,0


