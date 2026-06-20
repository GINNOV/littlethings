; Text2Scrolltext Filter program
; SK 15th September 1990

	move.l	#stringend-string,d1
	lea	string,a0
process:
	moveq	#0,d0
	move.b	(a0),d0
	cmp.b	#10,d0
	bne.s	update
	move.b	#32,d0
update:
	move.b	d0,(a0)+
	dbra	d1,process
	rts

string:	incbin	"source5:test.txt"
stringend:
	even

