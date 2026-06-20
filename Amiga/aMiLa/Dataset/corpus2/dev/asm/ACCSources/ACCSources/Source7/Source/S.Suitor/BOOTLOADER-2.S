	dc.b	"DOS",0
	dc.l	0,$370
 	move.w	#2,28(a1)
 	move.l	#$30000,40(a1)
 	move.l	#11*512*2,44(a1)
 	move.l	#11*512*11,36(a1)
	move.l	$4.w,a6
	jsr	-456(a6)
go	lea	doss(pc),a1
	jsr	-96(a6)
	tst.l	d0
	beq.s	go
	move.l	d0,a0
	move.l	$16(a0),a0
	jsr	$30000
	moveq	#$0,d0
	rts
















doss:	dc.b	"dos.library",0

