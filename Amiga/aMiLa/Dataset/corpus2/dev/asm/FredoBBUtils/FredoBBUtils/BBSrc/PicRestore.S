*** PicRestore V1.0	(CLI only!)
* For use with the IFF-ILBM Ripper V1.0 bootblock!
* The program will tell you what to do!
*
* Coded by Frédéric Bassaler (April 1996)

Start:
	lea	cline(pc),a0
	moveq	#clen,d0

; parse command line args
	clr.b	-1(a0,d0.w)
	subq.l	#1,d0
	move.l	d0,d5
.spc	cmp.b	#$20,(a0)+
	beq.s	.spc
	subq.l	#1,a0
	move.l	a0,args

	lea	dosname(pc),a1
	moveq	#0,d0
	move.l	4.w,a6
	jsr	-552(a6)
	move.l	d0,dosbase
	beq.w	nodos
	move.l	d0,a6

	move.l	#win,d1
	move.l	#1005,d2
	jsr	-30(a6)
	move.l	d0,output
	beq.w	nooutput

	tst.l	d5	;no args?
	beq.w	usage
	move.l	args(pc),a0
	cmp.b	#'?',(a0)
	beq.w	usage

	lea	hello.txt(pc),a0
	bsr.w	print
.w
	btst	#10,$dff016	;test right mouse button
	beq.w	nooutput
	btst	#6,$bfe001	;test left mouse button
	bne.s	.w

	move.l	args(pc),d1	;dest path
	bsr.w	lock
	move.l	d0,dirlock
	beq.w	nooutdir
	move.l	d0,d1
	bsr.w	changedir
	move.l	d0,olddir
;	beq.w	baddir
* open trackdisk unit 0
	lea	tdport(pc),a1
	move.l	a1,-(sp)
	move.l	4.w,a6
	move.l	276(a6),$10(a1)		;execbase->thistask
	jsr	-354(a6)		;AddPort()
	lea	ioreq(pc),a1
	move.l	(sp)+,14(a1)
	lea	trackname(pc),a0
	moveq	#0,d0		;unit=0
	moveq	#1,d1		;flags
	jsr	-444(a6)		;OpenDevice
	tst.l	d0
	bne.w	remport
* read 'hash' block (block number 2)
	moveq	#1,d6		;len: 1 block
	moveq	#2,d7		;offset: block 2
	lea	hashbuf,a4
	bsr.w	ReadBlk2
	tst.l	d0
	bne.s	readerr
	bsr.w	MotOff
; test header
	move.l	a4,a3
	cmp.l	#'PICS',(a3)+
	bne.s	baddisk
	move	(a3)+,d5
	subq	#1,d5	;nbre d'images à sauver
	clr	picnum
* read disk blocks & save picture data into files
.bcl
	move.l	(a3)+,d7	;offset
	move.l	(a3)+,d0	;len (en octets)
	move.l	d0,readlen
	move.l	d0,d6
	lsr.l	#8,d6
	lsr.l	#1,d6
	addq.l	#1,d6		;len en blocs
	move.l	d6,nblocks

	bsr.w	SaveFile

	addq	#1,picnum
	dbf	d5,.bcl
.fini
	lea	finished.txt(pc),a0
	bsr.s	print
	bra.s	CloseAll
usage:
	lea	usage.txt(pc),a0
	bsr.s	print
	bra.s	nooutput
nooutdir:
	lea	lockerr.txt(pc),a0
	bsr.b	print
	bra.s	nooutput
baddir:
	lea	baddir.txt(pc),a0
	bsr.b	print
	bra.s	nooutput
readerr:
	lea	readerr.txt(pc),a0
	bsr.b	print
cloff	bsr.w	MotOff
	bra.s	closedev
baddisk:
	lea	baddisk.txt(pc),a0
	bsr.b	print
	bra.b	cloff

CloseAll:
;	move.l	olddir(pc),d1
;	bsr.b	changedir
closedev
	lea	ioreq(pc),a1
	move.l	4.w,a6
	jsr	-450(a6)
remport
	lea	tdport(pc),a1
	move.l	4.w,a6
	jsr	-360(a6)
nooutput
	move.l	dirlock(pc),d1
	bsr.b	unlock
	move.l	output(pc),d1
	bsr.s	close
.nolock
	move.l	dosbase(pc),a1
	move.l	4.w,a6
	jsr	-414(a6)
nodos
	moveq	#0,d0
	rts

print:
	movem.l	d0-a6,-(sp)
	move.l	a0,d2
	moveq	#-1,d3
.len	addq.l	#1,d3
	tst.b	(a0)+
	bne.s	.len
	move.l	output(pc),d1
	move.l	dosbase(pc),a6
	jsr	-48(a6)
	movem.l	(sp)+,d0-a6
	rts

lock:	moveq	#-2,d2
	move.l	dosbase(pc),a6
	jmp	-84(a6)
unlock:
	tst.l	d1
	beq.s	.f
	move.l	dosbase(pc),a6
	jmp	-90(a6)
.f	rts
close:
	tst.l	d1
	beq.s	.f
	move.l	dosbase(pc),a6
	jmp	-36(a6)
.f	rts
changedir:
	tst.l	d1
	beq.s	.f
	move.l	dosbase(pc),a6
	jmp	-126(a6)
.f	rts

MotOff:
	movem.l	d0-a6,-(sp)
	lea	ioreq(pc),a1
	move	#9,28(a1)
	clr.l	36(a1)
	move.l	4.w,a6
	jsr	-456(a6)
	movem.l	(sp)+,d0-a6
	rts

ReadBlk:
	move.l	readbuf(pc),a4
ReadBlk2
	movem.l	d1-a6,-(sp)
	lea	ioreq(pc),a1
	move	#2,28(a1)
	move.l	a4,40(a1)	;io_data
	move.l	d6,d1
	moveq	#9,d0
	lsl.l	d0,d1
	move.l	d1,36(a1)	;io_length
	move.l	d7,d1
	lsl.l	d0,d1
	move.l	d1,44(a1)	;io_offset
	clr.l	52(a1)
	move.l	4.w,a6
	jsr	-456(a6)
	movem.l	(sp)+,d1-a6
	rts

SaveFile:
	movem.l	d5/a3,-(sp)
	move.l	readlen(pc),d0
	move.l	#$10002,d1
	move.l	4.w,a6
	jsr	-198(a6)
	move.l	d0,readbuf
	beq.w	.f

	moveq	#0,d0
	move	picnum(pc),d0
	lea	pic.num(pc),a0
	moveq	#$30,d1
	divu	#10,d0
	add.b	d1,d0
	move.b	d0,(a0)+
	clr	d0
	swap	d0
	add.b	d1,d0
	move.b	d0,(a0)+
* read blocks & write file
	lea	read.txt(pc),a0
	bsr.w	print

	move.l	nblocks(pc),d6
	bsr.w	ReadBlk
	bsr.w	MotOff

	lea	pic.name(pc),a0
	lea	write2.txt(pc),a1
.cop	move.b	(a0)+,d0
	beq.s	.zero
	move.b	d0,(a1)+
	bne.s	.cop
.zero	move.b	#$a,(a1)+
	clr.b	(a1)

	lea	write.txt(pc),a0
	bsr.w	print

	lea	pic.name(pc),a0
	move.l	a0,d1
	move.l	#1006,d2
	move.l	dosbase(pc),a6
	jsr	-30(a6)
	move.l	d0,fhandle
	beq.s	.openerr
	move.l	d0,d1
	move.l	a4,d2
	move.l	readlen(pc),d3
	jsr	-48(a6)
* close file
	move.l	fhandle(pc),d1
	jsr	-36(a6)
* free buffer
.openerr
	movem.l	readlen(pc),d0/a1
	move.l	4.w,a6
	jsr	-210(a6)	:FreeMem()
.f	movem.l	(sp)+,d5/a3
	rts

*****************
args	dc.l	0
dosbase	dc.l	0
output	dc.l	0
dirlock	dc.l	0
olddir	dc.l	0
nblocks	dc.l	0
fhandle	dc.l	0
readlen	dc.l	0
readbuf	dc.l	0
picnum	dc.w	0

dosname:dc.b	"dos.library",0
trackname:dc.b	"trackdisk.device",0

pic.name:dc.b "PIC"
pic.num:dc.b "xx.IFF",0

usage.txt:
 dc.b $9b,"1;33m"
 dc.b "PicRestore V1.0, by Frédéric Bassaler (April 1996)",$a,$a
 dc.b $9b,"m"
 dc.b "This little tool works in combination with 'IFF-ILBM Ripper V1.0',",$a
 dc.b "a bootblock which allows you to scan your memory for IFF-ILBM pictures,",$a
 dc.b "and to write them on disk. Since the pictures are directly",$a
 dc.b "written to the disk tracks, you must use this program",$a
 dc.b "to read them back from your disk and save them as FILES.",$a,$a
 dc.b "Please refer to PicRestore.doc for more details.",$a
 dc.b $a,"Usage: PicRestore <destination path>",$a
 dc.b "ex: PicRestore ram:",$a
 dc.b 0
hello.txt:
 dc.b $9b,"1;32m"
 dc.b "PicRestore V1.0, by Frédéric Bassaler (April 1996)",$a,$a
 dc.b $9b,"m"
 dc.b "Please insert your PICS disk in drive DF0:",$a
 dc.b " and press LeftMouse to continue (RightMouse to Abort)",$a
 dc.b 0
read.txt:
 dc.b "Reading blocks... ",$a,0
write.txt:
 dc.b "Writing file "
write2.txt:
 dcb.b 20,0
finished.txt:
 dc.b "All pics on disk have been restored successfully!",$a,0
lockerr.txt:
 dc.b "Couldn't lock directory!",$a,0
baddir.txt:
 dc.b "Error! I need an output directory!",$a,0
readerr.txt:
 dc.b "Read error! - Aborting..",$a,0
baddisk.txt:
 dc.b "This is NOT an IFF-ILBM Ripper V1.0 PICS disk!!",$a,0

win	dc.b "*",0

;debug
cline	dc.b "ram:",0
clen=*-cline

	cnop 0,4
ioreq:dcb.b 56,0
tdport:dcb.b 34,0

	SECTION	buf,BSS_C
hashbuf	ds.b	512
