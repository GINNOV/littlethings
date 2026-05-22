		lea	berry,a0
		lea	colors,a1
		lea	alpha,a2
		move.l	#512-1,d7
laber

		move.l	#640-1,d6		
next
		movem.l	d6/d7,-(a7)
		move.l	(a0),d5
		move.l	(a1)+,d6
		moveq	#0,d7
		move.b	(a2)+,d7
		moveq	#0,d4
		move.b	d5,d0
		move.b	d6,d1

		move.l	#255,d2
		sub.l	d7,d2		;Prozentwert vom originalwert
		mulu	d2,d0
		divu	#255,d0
		mulu	d7,d1
		divu	#266,d1
		add.b	d1,d0
		or.b	d0,d4		;Blauwert

		move.l	d5,d0
		move.l	d6,d1
		and.l	#$0000ff00,d0
		and.l	#$0000ff00,d1
		lsr.w	#8,d0
		lsr.w	#8,d1

		mulu	d2,d0
		divu	#255,d0
		mulu	d7,d1
		divu	#266,d1
		add.b	d1,d0
		and.l	#$000000ff,d0
		lsl.w	#8,d0
		or.w	d0,d4		;grünwert
		
		move.l	d5,d0
		move.l	d6,d1
		and.l	#$00ff0000,d0
		and.l	#$00ff0000,d1
		swap	d0
		swap	d1
		
		mulu	d2,d0
		divu	#255,d0
		mulu	d7,d1
		divu	#266,d1
		add.b	d1,d0
		and.l	#$000000ff,d0
		swap	d0
		or.l	d0,d4		;grünwert
	
		move.l	d4,(a0)+

		movem.l	(a7)+,d6/d7

		dbra	d6,next
		dbra	d7,laber

		illegal

berry
		incbin	sources:converter/alphatest/_berry
colors
		incbin	sources:converter/alphatest/_colors
alpha:		
		incbin	sources:converter/alphatest/alpha.chunk

