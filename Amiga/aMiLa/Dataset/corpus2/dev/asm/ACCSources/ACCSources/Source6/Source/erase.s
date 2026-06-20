; ERASE - A quick delete program
; SK 5th Oct 90

execbase	=	4
oldopenlibrary	=	-408
closelibrary	=	-414
deletefile	=	-72

	move.l	a0,fname	save address of filename
	sub.l	#1,d0	point to linefeed
	add.l	d0,a0	correct a0
	move.l	#0,(a0)	change linefeed to null

	move.l	execbase,a6	exec
	lea	dosname,a1	pointer to dos.lib text
	moveq	#0,d0	no version
	jsr	oldopenlibrary(a6)	open dos
	beq	fast_exit	if not opened then exit
	move.l	d0,dosbase	save address of dos

	move.l	dosbase,a6	load dos address
	move.l	fname,d1	load adr of filename
	jsr	deletefile(a6)	delete the file

	move.l	execbase,a6	exec
	move.l	dosbase,a1	adr of dos
	jsr	closelibrary(a6)
fast_exit	rts

dosname	dc.b	"dos.library",0
dosbase	dc.l	0
fname	dc.l	0

