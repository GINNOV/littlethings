;	Tests to see if mouse has been held down or not...

Start	bsr	MousTst
	btst	#2,$dff016
	bne	Start
	rts

MousTst	btst	#6,$bfe001
	beq	MsePrsd
	move.w	#$0f00,$dff180
	move.b	#0,MseStat
	rts

MsePrsd	tst.b	MseStat
	beq	MseNone
	move.b	#1,MseStat
	move.w	#$00f0,$dff180
	rts

MseNone	move.b	#1,MseStat
	move.w	#-1,d0
Loop	move.w	#$000f,$dff180
	dbf	d0,Loop
	rts

MseStat	dc.b	0
	even
