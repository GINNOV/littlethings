; this is the same source as 3, but without the info...
; looks better eh ?  now try to explain it yourself !!


top:	movem.l	d0-d7/a0-a6,-(a7)

	lea.l	row1,a0
	lea.l	row2,a1

loop:	cmp.l	#endrow1,a0
	beq.s	endloop

	move.b	(a0)+,d0
	sub.b	#$10,d0
	move.b	d0,(a1)+
	bra.s	loop

endloop:movem.l	(a7)+,d0-d7/a0-a6
	rts


row1:	dc.b	$20,$40,$5a,$a4,$ff,$03,$10,$40
	dc.b	$64,$29,$65,$77,$b0,$ac,$00,$e2
endrow1:

length=	endrow1-row1

row2:	blk.b	length,0


