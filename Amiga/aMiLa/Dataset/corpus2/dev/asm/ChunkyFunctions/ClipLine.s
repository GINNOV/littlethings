;APSFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
******************************************************************************
* Originally written by Holger 'Lynxx' Hippenstiel somewhere around 1994-95, *
* tuned a bit for speed & high-resolution compability in May 2023.           *
******************************************************************************

;Functions:
;ClipLine
;in d0=x0, d1=y0, d2=x1, d3=y1, d5=pixelwidth, d6=pixelheight
;out d0-d3
;zero-flag if line should be drawn i.e:
;	bsr	ClipLine
;	bne.b	SkipThisLine
;...
ClipLine:
	movem.l	d4-d7/a4-a6,-(a7)
	move.l	d6,a6	;pixelheight
	move.l	d5,a5	;pixelwidth
	subq.l	#1,a6
	lea	.ChkY(pc),a4
	cmp	d1,d3
	bge.b	.ChkY

	exg	d0,d2
	exg	d1,d3
.ChkY:	moveq	#0,d6
	tst	d1
	bmi.b	.Cty11

	tst	d3
	bmi.b	.Cty12

	move	a5,d6
	cmp	d6,d0
	bgt.w	.Ctx21

	cmp	d6,d2
	bgt.w	.Ctx22

	move	a6,d6
	cmp	d6,d1
	bgt.b	.Cty21

	cmp	d6,d3
	bgt.b	.Cty22

	moveq	#0,d6
	tst	d0
	bmi.w	.Ctx11

	tst	d2
	bpl.b	.DrawTheLine

.Ctx12:	move	d1,d4
	move	d2,d5
	move	d2,d7
	sub	d3,d4
	sub	d6,d7
	muls	d7,d4
	sub	d0,d5
	divs	d5,d4
	moveq	#0,d2
	add	d4,d3
	bra.b	.ChkY

.ClpEnd:
	moveq	#-1,d7
.RegsBack:
	movem.l	(a7)+,d4-d7/a4-a6
	rts

.DrawTheLine:
	moveq	#0,d7
	bra.b	.RegsBack

.Cty11:	move	d3,d7
	bmi.b	.ClpEnd

	sub	d2,d0
	sub	d6,d7
	move	d3,d5
	muls	d7,d0
	sub	d1,d5
	divs	d5,d0
	moveq	#0,d1
	add	d2,d0
	bra.b	.ChkY

.Cty12:	move	d0,d4
	move	d3,d7
	move	d3,d5
	sub	d2,d4
	sub	d6,d7
	muls	d7,d4
	sub	d1,d5
	moveq	#0,d3
	divs	d5,d4
	add	d4,d2
	bra.b	.ChkY
	
.Cty21:	cmp	d6,d3
	bgt.b	.ClpEnd

	sub	d2,d0
	move	d3,d7
	move	d3,d5
	sub	d6,d7
	muls	d7,d0
	sub	d1,d5
	divs	d5,d0
	move	d6,d1
	add	d2,d0
	jmp	(a4)

.Cty22:	move	d0,d4
	move	d3,d7
	sub	d2,d4
	move	d3,d5
	sub	d6,d7
	muls	d7,d4
	sub	d1,d5
	divs	d5,d4
	move	d6,d3
	add	d4,d2
	jmp	(a4)

.Ctx11:	move	d2,d7
	bmi.b	.ClpEnd

	sub	d3,d1
	sub	d6,d7
	move	d2,d5
	muls	d7,d1
	sub	d0,d5
	divs	d5,d1
	moveq	#0,d0
	add	d3,d1
	jmp	(a4)

.Ctx21:	cmp	d6,d2
	bgt.b	.ClpEnd

	move	d2,d7
	sub	d3,d1
	sub	d6,d7
	move	d2,d5
	muls	d7,d1
	sub	d0,d5
	divs	d5,d1
	move	d6,d0
	add	d3,d1
	jmp	(a4)

.Ctx22:	move	d1,d4
	move	d2,d7
	sub	d3,d4
	sub	d6,d7
	move	d2,d5
	muls	d7,d4
	sub	d0,d5
	divs	d5,d4
	move	d6,d2
	add	d4,d3
	jmp	(a4)
