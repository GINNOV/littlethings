;-----------------------------------------------------
.jloop
                  move	joy1dat+custom,d2
	btst	#1,d2
	beq	.no_r
	addq.b	#2,data+3
	bra	.jcont
.no_r
	btst	#9,d2
	beq	.jloop
	subq.b	#2,data+3
.jcont
                  move.l	#-1,d0
.tloop
	dbra	d0,.tloop
	move.l	data,ddfstrt(a0)
	bra	.jloop
data
	dc.l    $005800b8
jcont2
;-----------------------------------------------------

