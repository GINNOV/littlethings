*********************************************
*         D E C R Y P T E R !!!!!           *
*  Uses Psyko-Crypt (C) 1991 Intuition UK.  *
*   Just put the proggy in the incbin!!!    *
*********************************************

start:	lea	proggo,a0
	lea	$50000,a1	;Or where ever you want
	move.l	#$cb8947ad,d7	;The Crypt-Code!
	move.l	#$19,d6	;The Add-next val
loopyloo:	move.l	(a0),d0
	eor.l	d7,d0
	move.l	d0,(a1)+
	add.l	d6,d7
	sub.l	#1,d6
	cmpi.b	#1,d6
	bne	notem
	move.l	#$19,d6
notem:	move.l	(a0)+,d1
	cmp.l	endasc,d1
	bne 	loopyloo
	rts

proggo:	incbin	df1:encalc

endasc:	dc.l	"END!"
	








