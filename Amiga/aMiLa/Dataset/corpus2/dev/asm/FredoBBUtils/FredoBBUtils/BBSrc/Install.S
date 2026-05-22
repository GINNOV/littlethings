; Bootblock Installer V1.0
; Coded by Frédéric BASSALER in April 1997
;
; PUBLIC DOMAIN - Do whatever you want with this source! (improve it!)
;
; Assemble with Asm-One, Trash'm-One or PhxAss ...
;
;	Frédéric BASSALER
;	La Serre
;	19500 COLLONGES
;	FRANCE
;
; fbas@club-internet.fr
;

	incdir	asm:/include/
	include	equ.s

	rsreset
argstr		rs.l	1
arglen		rs.l	1
dosbase		rs.l	1
stdio		rs.l	1
fname		rs.l	1
buf		rs.l	1
unitnumber	rs.l	1
unit		rs.l	1
showflag	rs.b	1
VARSIZE		rs.w	0

BUFSIZE=$400+20		;buffer size for bootblock data

Start:
;	lea	fakeargs(pc),a0		;for debugging purposes
;	moveq	#fakeargslen,d0

	lea	VARS(pc),a5
	move.l	a0,argstr(a5)		;save CLI/Shell args string
	move.l	d0,arglen(a5)		;save CLI/Shell args string length

	lea	dos.name(pc),a1
	moveq	#0,d0		;all kickstart versions
	move.l	4.w,a6
	jsr	OpenLibrary(a6)
	move.l	d0,dosbase(a5)
	beq.w	doserr
	move.l	d0,a6

	move.l	#outname,d1
	move.l	#1005,d2
	jsr	Open(a6)
;	jsr	OutPut(a6)
	move.l	d0,stdio(a5)
	beq	CloseAll

	clr.b	showflag(a5)

; parse CLI args (very simple parser!)
	move.l	argstr(a5),a0
	move.l	arglen(a5),d0
	clr.b	-1(a0,d0.l)	;replace LF by 0 (null-character) in ArgString
	subq.l	#1,d0
	beq	usage		;if no args given => show usage
	bsr	skip_spaces

	move.b	(a0)+,d1
	cmp.b	#'-',d1		;options given?
	bne.s	.no_opt
	move.b	(a0)+,d1
	and.b	#~$20,d1	;convert character to UPPER case
	cmp.b	#'S',d1		;option S (SHOW) given?
	seq	showflag(a5)	;set flag to -1 (true) if yes

	bsr	skip_spaces
	move.b	(a0)+,d1
.no_opt
	and.b	#~$20,d1	;convert character to UPPER case

	cmp.b	#'D',d1
	bne.w	usage
	move.b	(a0)+,d1
	and.b	#~$20,d1
	cmp.b	#'F',d1
	bne.w	usage
	moveq	#0,d1
	move.b	(a0)+,d1
	sub.b	#$30,d1
	tst.b	d1
	blt.w	usage
	cmp.b	#3,d1
	bgt.w	usage
	move.l	d1,unitnumber(a5)

	cmp.b	#':',(a0)+
	bne	usage

	bsr	skip_spaces

	tst.b	(a0)
	bne.s	.filename_given
	suba.l	a0,a0
.filename_given
	move.l	a0,fname(a5)

; alloc disk unit
	move.l	unitnumber(a5),d0
	bsr	OpenUnit
	move.l	d0,unit(a5)
	beq	CloseAll

; alloc bootblock buffer
	move.l	#BUFSIZE,d0	;1kb (2 blocks)
	move.l	#$10002,d1	;chip!clear
	move.l	4.w,a6
	jsr	AllocMem(a6)
	move.l	d0,buf(a5)
	beq.w	CloseAll

; read old bootblock
	move.l	d0,a0
	move.l	unit(a5),a1
	moveq	#0,d0
	moveq	#2,d1
	bsr	ReadSec
	move.l	unit(a5),a1
	bsr	MotorOff
	tst.l	d0
	bne	readerr

	tst.b	showflag(a5)	;show flag set ?
	bne	ShowBB		;if yes, display bootblock only

; we want to use the same filesystem on the new bootblock so we need
; to read which filesystem was used in the old bootblock
; Please note that we don't check for the first 3 bytes of the data
; to be 'DOS'. If that first 3 bytes aren't 'DOS', the disk will not boot!

	move.l	buf(a5),a0
	lea	boot(pc),a1
	move.b	3(a0),3(a1)

; clear buffer
	move.l	buf(a5),a0
	move	#($400/4)-1,d0
.clr	clr.l	(a0)+
	dbf	d0,.clr

	bsr.w	Getfile
	beq.s	.nofile

	bra.s	CheckSum

; no filename was given => we'll install the disk with the built-in bootblock
.nofile
	lea	boot(pc),a0
	move.l	buf(a5),a1
	moveq	#(end-boot)-1,d0
.copy	move.b	(a0)+,(a1)+	;copy bb data to buffer
	dbf	d0,.copy

; calculate the new bootblock's checksum
; if the checksum isn't correct, the disk won't boot!
CheckSum:
	move.l	buf(a5),a0
	clr.l	4(a0)		;clear old checksum
	move.l	a0,a1
	moveq	#0,d0
	move	#$ff,d1		;256-1 longwords
.bcl
	add.l	(a0)+,d0
	bcc.b	.Calc
	addq.l	#1,d0
.Calc	dbf	d1,.bcl
	not.l	d0
	move.l	d0,4(a1)	;put new checksum

; write new bootblock on disk
writebb:
	move.l	buf(a5),a0
	move.l	unit(a5),a1
	moveq	#0,d0
	moveq	#2,d1
	bsr	WriteSec
	move.l	unit(a5),a1
	bsr	MotorOff
	tst.l	d0
	bne	writeerr

	lea	installok.txt(pc),a0
	bsr	Print

; show new bootblock (ASCII dump)
ShowBB:
	lea	viewbb.txt(pc),a0
	bsr	Print
	move.l	buf(a5),a0
	move.l	#$400,d0
	bsr	ConvertChars
	move.b	#$a,0(a0,d0.w)	;linefeed
	clr.b	1(a0,d0.w)	;null-terminated string
	bsr	Print

*** Close & free all
CloseAll:
	move.l	stdio(a5),d1
	beq.s	.a
	move.l	dosbase(a5),d0
	beq.s	.a
	move.l	d0,a6
	jsr	Close(a6)
.a
	move.l	buf(a5),d0
	beq.b	.b
	move.l	d0,a1
	move.l	#BUFSIZE,d0
	move.l	4.w,a6
	jsr	FreeMem(a6)
.b
	move.l	unit(a5),d0
	beq.s	.c
	move.l	d0,a0
	bsr	CloseUnit
.c
	move.l	dosbase(a5),d0
	beq.b	.d
	move.l	d0,a1
	move.l	4.w,a6
	jsr	CloseLibrary(a6)
.d
	moveq	#0,d0
	rts
err
	moveq	#20,d0		;Error flag in d0
	rts

skip_spaces:
	cmp.b	#$20,(a0)+
	beq.s	skip_spaces
	subq.l	#1,a0
	rts

* open & read a bootblock file if specified
Getfile:
	move.l	fname(a5),d1
	beq.s	.nofile
	move.l	#1005,d2	;mode old
	move.l	dosbase(a5),a6
	jsr	Open(a6)
	move.l	d0,d4
	beq.s	.openerr
	move.l	d4,d1
	move.l	buf(a5),d2
	move.l	#$400,d3
	jsr	Read(a6)
	move.l	d4,d1
	jsr	Close(a6)
	moveq	#1,d0		;return code: file loaded
	rts
.nofile
	moveq	#0,d0		;return code: no file or file error
	rts

.openerr
	lea	openerr.txt(pc),a0
	suba.l	a1,a1
	bsr.s	Print
	bra.s	.nofile

doserr
	lea	doserr.txt(pc),a0
	bra.s	pr0
usage
	lea	usage.txt(pc),a0
pr0	suba.l	a1,a1		;no args for rawprint
	bra.b	pr
deverr
	lea	deverr.txt(pc),a0
	move.l	unitnumber(a5),a1
	bra.b	pr
readerr
	lea	readerr.txt(pc),a0
	move.l	d0,-(sp)
	move.l	sp,a1
	bsr.b	RawPrint
	move.l	(sp)+,d0
	moveq	#29,d1		;29 = no disk in drive
	cmp.l	d0,d1
	bne	CloseAll
	lea	nodisk.txt(pc),a0
	bra.s	pr

writeerr
	lea	writeerr.txt(pc),a0
	move.l	d0,-(sp)
	move.l	sp,a1
	bsr.b	RawPrint
	move.l	(sp)+,d0
	moveq	#28,d1		;28 = disk is write-protected
	cmp.l	d0,d1
	bne.w	CloseAll
	lea	protected.txt(pc),a0

pr	bsr.b	RawPrint
	bra.w	CloseAll

* Convert strings with RawDoFmt() and print to screen
* <-- a0: format string
*	a1: addr of data to be converted
*	a3: addr of target string
RawPrint:
	movem.l	d0-a6,-(sp)
	lea	.pchr(pc),a2
	lea	usage.txt(pc),a3
	move.l	a3,-(sp)
	move.l	4.w,a6
	jsr	-522(a6)	;RawDoFmt()
	move.l	(sp)+,a0

	bra.b	Print0

.pchr	move.b	d0,(a3)+
	rts

* print a null-terminated string
* <-- a0: string addr
Print:
	movem.l	d0-a6,-(sp)
Print0	move.l	a0,d2
	moveq	#-1,d3
.len	addq.l	#1,d3		;calculate string length
	tst.b	(a0)+		;result in d3
	bne.b	.len
	move.l	stdio(a5),d1
	move.l	dosbase(a5),a6
	jsr	Write(a6)
	movem.l	(sp)+,d0-a6
	rts

* Convert non-displayable ASCII chars (into displayable ones)
* <-- a0: addr of buffer
* <-- d0: buffer size
ConvertChars:
.CHR="·"
	movem.l	a0/d0-d2,-(sp)
	subq	#1,d0
.t	move.b	#.CHR,d1	;replacement char.
	move.b	(a0)+,d2
	bclr	#7,d2
	cmp.b	#$20,d2		;char value < $20(=space)?
	bcs.b	.no		;if yes, replace
	move.b	d2,d1
	btst	#7,-1(a0)
	beq.b	.no
	bset	#7,d1
.no	move.b	d1,-1(a0)
	dbf	d0,.t
	movem.l	(sp)+,a0/d0-d2
	rts

*********************** Trackdisk Support Routines ***************************
* (routines used to access disk tracks)

*** Open a trackdisk unit
* <-- d0: unit number (0,..,4)
* --> d0: custom 'Unit' structure returned, or 0 if failed
OpenUnit:
	move.l	d0,d7
* allocate our custom 'Unit' structure
* which contains an IORequest an a MsgPort
	moveq	#34+56,d0	;size=MP_SIZE+IOStdReq_SIZE
	move.l	#$10001,d1
	move.l	4.w,a6
	jsr	AllocMem(a6)
	move.l	d0,d6
	beq.b	.err
* init MsgPort
	move.l	d6,a1
	lea	56(a1),a1	;MsgPort address in A1
	move.l	a1,-(sp)
	move.l	276(a6),$10(a1)	;execbase->thistask in mp_SigTask
	jsr	AddPort(a6)	;trackdisk message port
	tst.l	d0
	beq.b	.free
* open device
	move.l	d6,a1
	move.l	(sp)+,14(a1)	;msgport
	move.l	d7,d0		;unit #
	moveq	#1,d1		;flags: ALLOW_NON_3_5
	lea	trackname(pc),a0
	jsr	OpenDevice(a6)
	tst.l	d0		;0=no err
	bne.b	.remport
	move.l	d6,d0		;return address of our struct. (0=fail)
	rts
.remport
	move.l	d6,a1
	lea	56(a1),a1
	jsr	RemPort(a6)
.free
	move.l	d6,a1
	moveq	#34+56,d0
	jsr	FreeMem(a6)
.err	moveq	#0,d0
	rts

*** Close a trackdisk unit, previously opened by OpenUnit
* <-- a0: custom Unit struct of the unit to be closed
CloseUnit:
	move.l	a0,d6
	beq.b	.f
	move.l	a0,-(sp)
	move.l	14(a0),a1
	jsr	RemPort(a6)	;kill msgport
	move.l	(sp)+,a1
	jsr	CloseDevice(a6)
	move.l	d6,a1
	moveq	#34+56,d0
	jmp	FreeMem(a6)	;free struct 'unit'
.f	rts


*** Read disk Sectors
* <--	a0: target address for the data to be read
* 	a1: unit
* 	d0: disk offset
*	d1: number of sectors to read
* -->	d0: 0 if ok, else fail
ReadSec:
	move.l	d2,-(sp)
	move	#2,28(a1)	;TD_READ
	move.l	a0,40(a1)	;io_data
	moveq	#9,d2
	lsl.l	d2,d0		;d0=d0*512
	lsl.l	d2,d1		;d1=d1*512
	move.l	d1,36(a1)	;io_length
	move.l	d0,44(a1)	;io_offset
	clr.l	52(a1)		;io_seclabel (not used)
	move.l	(sp)+,d2
	bra.b	do_io

*** Write disk Sectors
* <--	a0: source address of the data to be written
* 	a1: unit
* 	d0: disk offset
*	d1: number of sectors to write
* -->	d0: 0 if ok, else fail
WriteSec:
	move.l	d2,-(sp)
	move	#3,28(a1)	;TD_WRITE
	move.l	a0,40(a1)	;io_data
	moveq	#9,d2
	lsl.l	d2,d0		;d0=d0*512
	lsl.l	d2,d1		;d1=d1*512
	move.l	d1,36(a1)	;io_length
	move.l	d0,44(a1)	;io_offset
	clr.l	52(a1)		;io_seclabel (not used)
	move.l	(sp)+,d2
	bsr.b	do_io
UpdateSec:
	move	#4,28(a1)	;TD_UPDATE
	bra.b	do_io

*** Test if drive empty
* <-- a1: unit
* --> d0: 0 if there's a disk in the drive unit 
TestUnit:
	move	#14,28(a1)	;TD_CHANGESTATE
td_	clr.l	36(a1)
	bsr.b	do_io
	move.l	32(a1),d0	;0=no disk
	rts

*** Get the protection status
* <-- a1: unit
* --> d0: 0 if NOT write-protected, any other value if write-protected
TestProt:
	move	#15,28(a1)	;TD_PROTSTATUS
	bra.b	td_

*** Get the number of tracks
* <-- a1: unit
* --> d0: number of tracks
GetNumTracks:
	move	#19,28(a1)	;TD_GETNUMTRACKS
	bra.b	td_

*** Turn motor off
* <-- a1: unit
MotorOff:
	move.l	d0,-(sp)
	move	#9,28(a1)	;TD_MOTOR
	clr.l	36(a1)		;0 = off ; 1 = on
	bsr.s	do_io
	move.l	(sp)+,d0
	rts
;send command to trackdisk device
do_io:
	move.l	a1,-(sp)
	move.l	4.w,a6
	jsr	DoIO(a6)
	move.l	(sp)+,a1
	tst.l	d0
	rts


******** Variables
VARS:	dcb.b	VARSIZE,0

*** texte
;fakeargs	dc.b	'-s df0:',0
;fakeargslen=*-fakeargs

outname		dc.b	'*',0
trackname	dc.b	'trackdisk.device',0

	even
ver	dc.b	"$VER: BootInstall 1.0 (10 April 1997)",$a,0

usage.txt
 dc.b	$1b,"[1;42mBootInstall V1.0"
 dc.b	$1b,"[0m, Another Custom (CLI only!) Bootblock Installer !",$a
 dc.b	$1b,"[3mCoded by Frédéric BASSALER.",$1b,"[0m",$a,$a
 dc.b	"Usage:    BootInstall [-s] DRIVE [filename]",$a
 dc.b	"Examples:",$a,$a
 dc.b	" BootInstall DF1: ram:mybootblock",$a
 dc.b	"  (Will install the file 'ram:mybootblock' on drive DF1:)",$a
 dc.b	" BootInstall -s DF0:",$a
 dc.b	"  (Will show the bootblock of the disk in DF0: - won't write anything! -)",$a,$a
 dc.b	"By default, Standard OS 2.0+ bootblock is installed.",$a
 dc.b	0
installok.txt	dc.b	"Installation ok.",$a,0
doserr.txt	dc.b	"Couldn't open dos.library!",$a,0
viewbb.txt	dc.b	"ASCII dump of Bootblock...",$a,$a,0
openerr.txt	dc.b	"Unable to open file!",$a,0
deverr.txt	dc.b	"Unable to open disk unit number %ld!",$a,0
readerr.txt	dc.b	"Read error n° %ld",$a,0
writeerr.txt	dc.b	"Write error n° %ld",$a,0
nodisk.txt	dc.b	"No disk in drive!",$a,0
protected.txt	dc.b	"Disk is write protected!",$a,0
	even

*** Start of built-in bootblock
boot:
	dc.b	'DOS',0
	dc.l	0
	dc.l	$370
*** Standard OS 2.0+ bootcode (works with OS 1.3 too)
	lea	expansion.name(pc),a1
	moveq	#37,d0
	jsr	OpenLibrary(a6)
	tst.l	d0
	beq.b	.err
	move.l	d0,a1
	bset	#6,34(a1)
	jsr	CloseLibrary(a6)
.err	lea	dos.name(pc),a1
	jsr	FindResident(a6)
	tst.l	d0
	beq.b	.nodos
	move.l	d0,a0
	move.l	22(a0),a0
	moveq	#0,d0
	rts	
.nodos	moveq	#-1,d0
	rts

dos.name	dc.b	'dos.library',0
expansion.name	dc.b	'expansion.library',0

end:
