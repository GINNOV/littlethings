;APS00006B4E00006B4E00006B4E0000082D00006B4E00006B4E00006B4E00006B4E00006B4E00006B4E
******************************************************************************
* Originally written by Holger 'Lynxx' Hippenstiel somewhere around 1994-95, *
* tuned a bit for speed & high-resolution compability in May 2023.           *
******************************************************************************

;Maximum height for multab
MAXHEIGHT SET 3840

;d0 pixelwidth
MakeChunkyMultab:
	movem.l	d0-d3/a0-a1,-(a7)
	lea	CircleMultab+MAXHEIGHT*4(pc),a0
	move.l	(a0),d1		;Last Multab-Width
	cmp	d1,d0		;Multab-Width = ScreenWidth ?
	beq.b	.MulTabOk

	ext.l	d0
	move.l	a0,a1
	moveq	#0,d1
	moveq	#0,d2
	move	#MAXHEIGHT-1,d3	;Max CircleHeight
.MakeMul:
	sub.l	d0,d2
	move.l	d1,(a1)+
	add.l	d0,d1
	move.l	d2,-(a0)
	move.l	d1,(a1)+
	add.l	d0,d1
	dbf	d3,.MakeMul

.MulTabOk:
	movem.l	(a7)+,d0-d3/a0-a1
	rts

CircleMultab:
	ds.l MAXHEIGHT*3
