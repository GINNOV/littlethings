; Text 2 Scrolltext
; SK 15th September 1990

; Well Ok, so it simply strips the carrage returns from ordinary text
; files. I find it useful for keeping code short: no more reams of
; DC.B (use INCBIN instead) and a damn sight easier to spell-check.

ExecBase	= 4
OpenLib		= -408
CloseLib	= -414
Open		= -30
Close		= -36
Read		= -42
Write		= -48
mode_old	= 1005
mode_new	= 1006

	move.l	ExecBase,a6
	lea	dosname(pc),a1	get dos address
	moveq	#0,d0
	jsr	OpenLib(a6)	and open it
	move.l	d0,dosbase	save address in memory
	tst.l	d0
	beq error

	move.l	#mode_old,d2
	move.l	#infilename,d1	pointer to filename in memory
	bsr	openfile
	move.l	d0,infilehd	save file handle for later
	tst.l	d0
	beq	error

	move.l	#mode_new,d2	open a new file
	move.l	#outfilename,d1
	bsr	openfile
	move.l	d0,outfilehd	save file handle in memory
	tst.l	d0
	beq	error

	move.l	#text,d2	area for read file
	bsr	readdata
	move.l	d0,d6		length of file in d6
	move.l	infilehd,d1
	bsr	closefile

;*********************************************
; Text2Scrolltext Filter program
; SK 15th September 1990

	movem.l	d0-d1/a0,-(sp)	save the used regs
	move.l	d6,d1		file length
	lea	text,a0		address of text to filter
process:
	moveq	#0,d0
	move.b	(a0),d0		next byte in d0
	cmp.b	#10,d0		is it $a / line feed
	bne.s	update		no - go to update
	move.b	#32,d0		change to $20 / space
update:
	move.b	d0,(a0)+	put byte back whether changed or not
	dbra	d1,process	jump until end of text
	movem.l	(sp)+,d0-d1/a0	restore regs for writedata
;*******************************************

	move.l	#text,d2	address of text
	move.l	d6,d3		length of text to write
	bsr	writedata	write the text

	move.l	outfilehd,d1
	bsr	closefile	close output file
error:
	move.l	ExecBase,a6
	move.l	dosbase,a1
	jsr	CloseLib(a6)	close the dos library ..
qu:
	rts			.. then exit pronto!

openfile:
	move.l	dosbase,a6
	jsr	Open(a6)	standard call from dos
	rts
closefile:
	move.l	dosbase,a6
	jsr	Close(a6)	ditto
	rts
readdata:
	move.l	dosbase,a6
	move.l	infilehd,d1
	move.l	#1000,d3	** fill buffer with file - will read
;				** as many as possible. This number MUST
;				** be changed with buffer size!
	jsr	Read(a6)
	rts
writedata:
	move.l	dosbase,a6
	move.l	outfilehd,d1
	jsr	Write(a6)
	rts

infilehd:	dc.l	0
infilename:	dc.b "source5:test.txt",0		my test file
	even
outfilehd	dc.l	0
outfilename:	dc.b "source5:test.txt.mod",0		example output name
	even
dosbase:	dc.l	0
dosname:	dc.b "dos.library",0
	even
text:		dcb.b	1000,0			buffer for input file
textend:
	even

