;-------------------------------------------------------------------------------
*                                                                              *
* Crypt                                                                        *
*                                                                              *
* Written 1992,1993,1994 by Daniel Weber                                       *
*                                                                              *
* IMPORTANT NOTE                                                               *
* --------------                                                               *
* This is a naive encryption algorithm and elementary cryptanalytic techniques *
* may easily crack it.  Stronger and more complex algorithms are recommended   *
* for higher data security (f.e.: PGP (Pretty Good Privacy), ...).             *
*                                                                              *
*                                                                              *
*       Filename        crypt.s                                                *
*       Author          Daniel Weber                                           *
*       Version         1.02                                                   *
*       Start           1992                                                   *
*                                                                              *
*       Last Revision   11.10.93                                               *
*                                                                              *
;-------------------------------------------------------------------------------

	output	'ram:crypt'

	opt	o+,q+,ow-,qw-,sw-
	verbose
	base	progbase

	filenote	'Crypt, Written 1992,1993,1994 by Daniel Weber'

;-------------------------------------------------------------------------------

	incdir	'include:'
	incdir	'routines:'

	include	'basicmac.r'
	include	'support.mac'
	incequ	'LVO.s'

;-------------------------------------------------------------------------------

version		equr	"1.02"
gea_progname	equr	"Crypt"

;-- startup control  --
cws_CLIONLY	set	1			;for CLI usage only
cws_EASYLIB	set	1


;-- user definitions --
AbsExecBase	equ	4
DOS.LIB		equ	1		;startup code should open dos.library


* cryptoffset is a user specified value to make 'crypt' a bit more individual.
cryptoffset	equ	11


workspace	equ	400


;-------------------------------------------------------------------------------
progbase:
	jmp	AutoDetach(pc)
	dc.b	0,"$VER: ",gea_progname," ",version," (",__date2,")",0
	even

;----------------------------
clistartup:
	lea	progbase(pc),a5

	lea	dxstart(pc),a1
	move.w	#(dxend-dxstart)/2-1,d7
.clr:	clr.w	(a1)+
	dbra	d7,.clr

	move.l	a0,ArgStr(a5)
	move.l	d0,ArgLen(a5)

	lea	Title(pc),a0			;print title
	printtext_

	bsr	ReadParameters			;read parameter line
	bne.s	.exit				;invalid

	move.l	Sourcefile(pc),d0		;load source file
	move.l	d0,d3
	moveq	#0,d1
	moveq	#0,d2
	CALL_	LoadFile
	move.l	d0,Buffer(a5)
	beq.s	.fileerror
	move.l	d1,Sourcelen(a5)
	move.l	d2,BufferSize(a5)

	bsr	DoCrypt				;encrypt buffer

	move.l	Destfile(pc),d0			;save file
	move.l	d0,d3
	move.l	Buffer(pc),d1
	move.l	Sourcelen(pc),d2
	CALL_	WriteToFile
	bne.s	.fileerror

.quit:	move.l	Buffer(pc),d0			;free buffer
	beq.s	.exit
	move.l	d0,a1
	move.l	BufferSize(pc),d0
	move.l	4.w,a6
	jsr	_LVOFreeMem(a6)

.exit:	moveq	#0,d0
	bra	ReplyWBMsg



;
; error handler
;
.fileerror:					;couldn't open file '%s'
	move.l	d3,rawlist(a5)
	lea	FileError1(pc),a0
	lea	rawlist(pc),a1	
	lea	workbuffer(pc),a3
	bsr	DoRawFmt
	move.l	a3,a0
	printtext_
	bra	.quit



;-------------------------------------------------------------------------------
*
* subroutines
*
;-------------------------------------------------------------------------------

;----------------------------------------------------------
;
; ReadParameters	- small command line parser
;
; a5: progbase
;
; => CCR:  Z ok,  zN failed usage, printed
;
ReadParameters:
	move.l	ArgStr(pc),a0
	move.l	ArgLen(pc),d7
	clr.b	-1(a0,d7.l)
	bsr	.spacekiller

	cmp.b	#"?",(a0)			;force usage?
	bne.s	.pw
	tst.b	1(a0)
	beq.s	.usage
	cmp.b	#" ",1(a0)
	beq.s	.usage

.pw:	cmp.b	#"-",(a0)			;password
	seq	cryptflag(a5)
	bne.s	1$
	addq.l	#1,a0
1$:	move.l	a0,PassWdStart(a5)
	move.l	a0,d1
	bsr.s	.skip
	move.l	a0,d0
	sub.l	d1,d0
	move.l	d0,PassWdLength(a5)
	beq.s	.usage
	clr.b	(a0)+

.src:	bsr.s	.spacekiller			;source file
	tst.b	(a0)
	beq.s	.usage
	move.l	a0,Sourcefile(a5)
	bsr.s	.skip
	add.l	d4,Sourcefile(a5)
	sub.l	d4,a0
	clr.b	(a0)+

.out:	bsr.s	.spacekiller			;output file
	tst.b	(a0)
	beq.s	.usage
	move.l	a0,Destfile(a5)
	bsr.s	.skip
	add.l	d4,Destfile(a5)
	sub.l	d4,a0
	clr.b	(a0)+

	bsr.s	.spacekiller
	tst.b	(a0)
	bne.s	.usage
	rts

;
; print usage
;
.usage:	lea	Usage(pc),a0
	printtext_
	moveq	#-1,d0
	rts

;
; skip text
;
; => d4: correction
;
.skip:	moveq	#0,d4
	moveq	#0,d5
	cmp.b	#$22,(a0)
	bne.s	\do
\strt:	move.b	(a0)+,d5
	moveq	#1,d4
\do:	move.b	(a0)+,d0
	beq.s	\ends
	cmp.b	d0,d5
	bne.s	.d2
	cmp.b	(a0)+,d5
	bne.s	\ends

.d2:	cmp.b	#" ",d0
	bne.s	\do
	tst.b	d5
	bne.s	\do
\ends:	subq.l	#1,a0
	rts


;
; skip spaces
;
.spacekiller:
	cmp.b	#" ",(a0)+
	beq.s	.spacekiller
	subq.l	#1,a0
	rts


;----------------------------------------------------------
;
; DoRawFmt
;
; a0: format
; a1: data stream
; a3: dest. buffer
;
DoRawFmt:
	movem.l	d0-a6,-(a7)
	lea	.setin(pc),a2
	move.l	4.w,a6
	jsr	_LVORawDoFmt(a6)
	movem.l	(a7)+,d0-a6
	rts

.setin:	move.b	d0,(a3)+
	rts



;----------------------------------------------------------
;
; DoCrypt	- encrypt buffer
;
; simple encryption algorithm
;
; crypt:   pass1-pass2-pass3
; decrypt:             pass3-pass4-pass5
;
DoCrypt:
	move.l	Sourcefile(pc),rawlist(a5)	;print action text
	move.l	Destfile(pc),rawlist+4(a5)
	lea	CryptTxt(pc),a0
	tst.b	cryptflag(a5)
	beq.s	.crypt
	lea	DeCryptTxt(pc),a0
.crypt:	lea	rawlist(pc),a1
	lea	workbuffer(pc),a3
	bsr	DoRawFmt
	move.l	a3,a0
	printtext_


;------------------
	tst.b	cryptflag(a5)
	bne.s	.pass3
.pass1:	move.l	Buffer(pc),a0			;pass1 for encryption only
	move.l	Sourcelen(pc),d7
	beq	.out
	lsr.l	#1,d7
	bne.s	.in1
	bra.s	.pass2
.loop1:	move.w	(a0)+,d0
	eor.w	d0,(a0)
.in1:	subq.l	#1,d7
	bne.s	.loop1


.pass2:	move.l	Sourcelen(pc),d7		;pass2 for encryption only
	move.l	Buffer(pc),a0
	lea	(a0,d7.l),a1
	moveq	#cryptoffset,d3			;user specified value
	lea	(a0,d3.l),a2
	bra.s	.chk2
.loop2: eor.b	d7,(a2)
	add.l	d3,a2
.chk2:	move.l	a2,d2
	sub.l	a1,d2
	bmi.s	.in2
	lea	(a0,d2.l),a2
	bra.s	.chk2
.in2:	subq.l	#1,d7
	bne.s	.loop2


.pass3:	move.l	PassWdStart(pc),a1		;pass3 for de/encryption
	move.l	a1,a2
	moveq	#cryptoffset/3,d4		;user specified value
.prep:	move.b	(a2)+,d0
	beq.s	0$
	add.b	d0,d4
	bra.s	.prep

0$:	move.l	Buffer(pc),a0
	moveq	#cryptoffset*2,d2		;user specified start value
	move.l	Sourcelen(pc),d7
.loop3:	move.b	(a1)+,d0
	bne.s	1$
	move.l	PassWdStart(pc),a1
	move.b	(a1)+,d0
	subq.b	#cryptoffset/2,d2
1$:	add.b	d2,d0
	add.b	#cryptoffset,d2
	add.b	d4,d0
	eor.b	d0,(a0)+
	and.b	#cryptoffset,d0			;user specified value
	beq.s	2$
	move.b	(a1),d0
	eor.b	d0,d2
2$:	subq.l	#1,d7
	bne.s	.loop3


	tst.b	cryptflag(a5)
	beq.s	.out
.pass4:	move.l	Sourcelen(pc),d7		;pass4 for decryption only
	move.l	Buffer(pc),a0
	lea	(a0,d7.l),a1
	moveq	#cryptoffset,d3			;user specified value
	lea	(a0,d3.l),a2
	bra.s	.chk4
.loop4: eor.b	d7,(a2)
	add.l	d3,a2
.chk4:	move.l	a2,d2
	sub.l	a1,d2
	bmi.s	.in4
	lea	(a0,d2.l),a2
	bra.s	.chk4
.in4:	subq.l	#1,d7
	bne.s	.loop4


.pass5:	move.l	Buffer(pc),a0			;pass5 for decryption only
	move.l	Sourcelen(pc),d7
	beq.s	.out
	lsr.l	#1,d7
	beq.s	.out
	add.l	d7,a0
	add.l	d7,a0
	bra.s	.in5
.loop5:	move.w	-4(a0),d0
	eor.w	d0,-(a0)
.in5:	subq.l	#1,d7
	bne.s	.loop5


.out:	rts




;-------------------------------------------------------------------------------
*
* external routines
*
;-------------------------------------------------------------------------------
	include	startup4.r
	include	dosfile.r


;-------------------------------------------------------------------------------
*
* data area
*
;-------------------------------------------------------------------------------

Title:		dc.b	$9b,"1mCrypt",$9b,"0m - small encryption program v"
		dc.b	version,$a
		dc.b	"Written 1992 by Daniel Weber",$a,$a,0
Usage:		dc.b	"Usage: ",$9b,"3mCrypt <password> <source file> "
		dc.b	"<output file>",$9b,"0m",$a,0
FileError1:	dc.b	"Couldn't open file '%s'.",$a,0

DeCryptTxt:	dc.b	"de"
CryptTxt:	dc.b	"crypting file '%s' to '%s'.",$a,0
		even

dxstart
;-------------------------------------------------------------------------------
ArgStr:		dx.l	1		;parameter line
ArgLen:		dx.l	1		;parameter line length

cryptflag:	dx.b	1		;0: crypt   -: decrypt
		aligndx.w

PassWdStart:	dx.l	1		;pointer to password
PassWdLength:	dx.l	1		;length of password

Buffer:		dx.l	1		;buffer address
BufferSize:	dx.l	1		;buffer size

Sourcefile:	dx.l	1		;pointer to source file
Sourcelen:	dx.l	1		;length of source file
Destfile:	dx.l	1		;pointer to destination file


rawlist:	dx.l	2		;rawlist for RawDoFmt
workbuffer:	dx.b	workspace	;some workspace

;-------------------------------------------------------------------------------
		aligndx.w
dxend:
	end

