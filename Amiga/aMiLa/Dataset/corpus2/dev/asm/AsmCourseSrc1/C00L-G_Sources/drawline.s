
main:	movem.l	a0-a6/d0-d7,-(a7)
	move.l	$4,a6
	lea	libname(pc),a1
	jsr	-408(a6)		
	move.l	d0,a5

	bsr	fillcopper

	move.l	#copperlist,$dff080	;cop1lcH/cop1lcL
	clr.w	$dff088

	movem.l	a0-a6/d0-d7,-(a7)

	move.l	#$dff000,a5

loop:	cmp.l	#0,x2
	beq	wait
	move.l	x1,d0		; calculate some nice coords
	clr.l	d1
	move.l	x2,d2	
	move.l	#200,d3
	move.l	#pic,a0
	move.l	#40,a1
	move.l	#$ffffffff,a2
	bsr	drawline		; the routine
	addq.l	#2,x1
	subq.l	#2,x2

	bra.s	loop

wait: 	btst	#6,$bfe001		
	bne.s	wait

	movem.l	(a7)+,a0-a6/d0-d7

	move.l	$26(a5),$dff080		
	clr.w	$dff088

	move.l	a5,a1
	jsr	-414(a6)		
	movem.l	(a7)+,a0-a6/d0-d7
	rts				
;---------------------------------------------------------------
fillcopper:
	move.l	#pic,d0
	lea.l	planept,a0
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	rts
;---------------------------------------------------------------
pic:	blk.b	[40*256],0

x1:	dc.l	0
x2:	dc.l	320
;---------------------------------------------------------------

libname:
	dc.b	"graphics.library",0
	even				;even, because all data must

copperlist:
planept:	dc.l	$00e00000,$00e20000	;bpl1pth/bpl1ptl

		dc.l	$008e406f,$009000cf	;diwstrt/diwstop
		dc.l	$00920038,$009400d0	;ddfstrt/ddfstop
		dc.w	$0100			;bplcon0
		dc.w	%0001000000000000	;data for bplcon0 (4 planes,lores)

		dc.l	$fe0ffffe,$009c8790	;wait bottom/change intreq
		dc.l	$fffffffe		;end of copperlist



********* drawline / the incredible routine **********

;	d0 = x1 (x-coord of start)
;	d1 = y1 (y-coord of start)
;	d2 = x2 (x-coord of end)
;	d3 = y2 (y-coord of end)
;	a0 = start of bitplane (pic:)
;	a1 = width of bitplane (#bytes)
;	a2 = mask (set=displayed notset=notdisplayed)

drawline:
	move.l	a1,d4
	mulu	d1,d4
	moveq	#-$10,d5
	and.w	d0,d5
	lsr.w	#3,d5
	add.w	d5,d4
	add.l	a0,d4

	clr.l	d5
	sub.w	d1,d3
	roxl.b	#1,d5
	tst.w	d3
	bge.s	y2gy1
	neg.w	d3
y2gy1:	sub.w	d0,d2
	roxl.b	#1,d5
	tst.w	d2
	bge.s	x2gx1
	neg.w	d2
x2gx1:	move.w	d3,d1
	sub.w	d2,d1
	bge.s	dygdx
	exg	d2,d3
dygdx:	roxl.b	#1,d5

	move.b	octtabel(pc,d5),d5
	add.w	d2,d2

wblit:	btst	#14,$2(a5)
	bne	wblit

	move.w	d2,$62(a5)
	sub.w	d3,d2
	bge.s	signnl
	or.b	#$40,d5
signnl:	move.w	d2,$52(a5)
	sub.w	d3,d2
	move.w	d2,$64(a5)

	move.w	#$8000,$74(a5)
	move.w	a2,$72(a5)
	move.w	#$ffff,$44(a5)
	and.w	#$000f,d0
	ror.w	#4,d0
	or.w	#$0bca,d0
	move.w	d0,$40(a5)
	move.w	d5,$42(a5)
	move.l	d4,$48(a5)
	move.l	d4,$54(a5)
	move.w	a1,$60(a5)
	move.w	a1,$66(a5)

	lsl.w	#6,d3
	addq.w	#2,d3
	move.w	d3,$58(a5)
	rts

octtabel:
dc.b	1,17,9,21,5,25,13,29

