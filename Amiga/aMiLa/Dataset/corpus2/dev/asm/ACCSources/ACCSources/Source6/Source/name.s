; NAME - the shorter way of renaming files
; SK 11th Oct 1990
; Tabs to 16 to read properly!

execbase	=	4	I would use the lib.i file,
oldopenlibrary	=	-408	but here you can see the
closelibrary	=	-414	values quickly.
rename	=	-78

	move.l	a0,fname1	save start adr of name1
	add.l	d0,a0	get offset of linefeed
	sub.l	#1,a0	and correct value
	move.b	#0,(a0)	turn lf into nul

	move.l	fname1,a1	reload adr of start
checkforspace	add.l	#1,a1	increment for test
	cmpi.b	#32,(a1)	check for space
	bne.s	checkforspace	no - then loop

	move.b	#0,(a1)	turn space into nul
	add.l	#1,a1	start of name2
	move.l	a1,fname2	save it!

	move.l	execbase,a6	exec
	lea	dosname,a1	pointer to dos.lib text
	moveq	#0,d0	no version
	jsr	oldopenlibrary(a6)
	beq	fast_exit	if not opened then exit
	move.l	d0,dosbase	save address of dos

	move.l	dosbase,a6	load dos address
	move.l	fname1,d1	load adr of filename
	move.l	fname2,d2	load adr of filename 2
	jsr	rename(a6)	rename the file

	move.l	execbase,a6	exec
	move.l	dosbase,a1	adr of dos
	jsr	closelibrary(a6)
fast_exit	rts

dosname	dc.b	"dos.library",0
dosbase	dc.l	0
fname1	dc.l	0
fname2	dc.l	0

