; DUPLICATE - SK 14th Sep 1990

; Dead simple this one: opens a file, reads it into memory, then
; writes a new file. Purely an exersize in using the dos.library.

ExecBase	= 4
OpenLib		= -408
CloseLib	= -414

; DOS offsets and variables
Open		= -30
Close		= -36
Read		= -42
Write		= -48
mode_old	= 1005
mode_new	= 1006

	move.l	ExecBase,a6
	lea	dosname(pc),a1
	moveq	#0,d0
	jsr	OpenLib(a6)
	move.l	d0,dosbase
	tst.l	d0
	beq error

	move.l	#mode_old,d2
	move.l	#infilename,d1
	bsr	openfile
	move.l	d0,infilehd
	tst.l	d0
	beq	error

	move.l	#mode_new,d2	open a new file
	move.l	#outfilename,d1
	bsr	openfile
	move.l	d0,outfilehd
	tst.l	d0
	beq	error

	move.l	#text,d2	area for read file
	bsr	readdata
	move.l	d0,d6		length of file in d6
	move.l	infilehd,d1
	bsr	closefile

	move.l	#text,d2
	move.l	d6,d3
	bsr	writedata	write the text
	move.l	outfilehd,d1
	bsr	closefile	close file
error:
	move.l	ExecBase,a6
	move.l	dosbase,a1
	jsr	CloseLib(a6)
qu:
	rts

openfile:
	move.l	dosbase,a6
	jsr	Open(a6)
	rts
closefile:
	move.l	dosbase,a6
	jsr	Close(a6)
	rts
readdata:
	move.l	dosbase,a6
	move.l	infilehd,d1
	move.l	#1000,d3
	jsr	Read(a6)
	rts
writedata:
	move.l	dosbase,a6
	move.l	outfilehd,d1
	jsr	Write(a6)
	rts

infilehd:	dc.l	0
infilename:	dc.b "Source5:source/duplicate.s",0
	even
outfilehd	dc.l	0
outfilename:	dc.b "ram:CopyOfduplicate.s",0
	even
dosbase:	dc.l	0
dosname:	dc.b "dos.library",0
	even
text:		ds.b	1000		1000 bytes of zeros as buffer
textend:

