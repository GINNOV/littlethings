; quick test for double params
; sk 11th oct 90

	move.l	#testdata,a0
	move.l	#testdataend-testdata,d0

	move.l	a0,fname1	save start adr of name1
	add.l	d0,a0	get offset of linefeed
	sub.l	#2,a0	and correct value
	move.b	#0,(a0)	turn lf into nul

	move.l	fname1,a1	reload adr of start
checkforspace	add.l	#1,a1	increment for test
	cmpi.b	#32,(a1)	check for space
	bne.s	checkforspace	no - then loop

	move.b	#0,(a1)	turn space into nul
	add.l	#1,a1	start of name2
	move.l	a1,fname2	save it!
	rts

fname1	dc.l	0
fname2	dc.l	0
testdata	dc.b	"Hello Copycommnand",10,0
testdataend

