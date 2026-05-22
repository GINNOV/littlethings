;-------------------------------------------------------------------------------
*                                                                              *
* Fortune       - small fortune teller                                         *
*                                                                              *
* Written 1992 by Daniel Weber                                                 *
* Written using the ProAsm assembler                                           *
*                                                                              *
*                                                                              *
*       Filename        fortune.s                                              *
*       Author          Daniel Weber                                           *
*       Version         0.94                                                   *
*       Start           22.11.1992                                             *
*                                                                              *
*       Last Revision   08.08.1993                                             *
*                                                                              *
;-------------------------------------------------------------------------------
*                                                                              *
* Notes:                                                                       *
*       - '##' indicates the start/end of a text                               *
*       - max. 65535 texts per file allowed (limited by the 'randomizer')      *
*	- '#*' indicates the end of such a fortune file                        *
*                                                                              *
;-------------------------------------------------------------------------------

	output	'ram:fortune'

	opt	o+,q+,ow-,sw-
	verbose
	base	progbase

	filenote "Fortune, written 1992 by Daniel Weber"

;-------------------------------------------------------------------------------

	incdir	'include:'
	incdir	'routines:'

	include	'basicmac.r'
	include	'support.mac'		;some of the support routines
	incequ	'LVO.s'

;-------------------------------------------------------------------------------

version		equr	"0.94"
gea_progname	equr	"Fortune"


cws_CLIONLY	equ	1
cws_EASYLIB	equ	1


AbsExecBase	equ	4
DOS.LIB		equ	1


;-------------------------------------------------------------------------------
progbase:
	jmp	AutoDetach(pc)
	dc.b	0,"$VER: ",gea_progname," ",version," (",__date2,")",0
	even

;----------------------------
clistartup:
	lea	progbase(pc),a5
	move.l	a0,cmdline(a5)
	move.l	d0,cmdlen(a5)

	move.l	cmdline(a5),a0
	lea	filename(pc),a1
	move.l	#160,d0			;maximal file length
	CALL_	ParseName

	lea	filename(pc),a0
	tst.w	(a0)
	beq	usage
	cmp.w	#"?"<<8,(a0)
	beq	usage
	move.l	a0,d0
	moveq	#0,d1
	moveq	#0,d2
	CALL_	LoadFile
	move.l	d0,TextAdr(a5)
	beq	fileerror
	move.l	d2,TextLength(a5)

	bsr	main

	move.l	TextAdr(pc),a1
	move.l	TextLength(pc),d0
	move.l	4.w,a6
	jsr	_LVOFreeMem(a6)

exit:	moveq	#0,d0
	bra	ReplyWBMsg



usage:	lea	UsageText(pc),a0
	bsr	PrintTexts
	bra.s	exit


UsageText:
	dc.b	$9b,"1mFortune v",version,$9b,"0m - "
	dc.b	"Written 1992 by Daniel Weber",$a
	dc.b	"Usage: fortune <text file>",$a,0
	even
;
; fortune file not found
;
fileerror:
	bsr	wrongfile
	bra	exit


;----------------------------------------------------------
*
* a0: text to print
*
PrintTexts:
	movem.l	d0-a6,-(a7)
	move.l	a0,d2
	move.l  d2,a3
.loop:	tst.b   (a3)+			;search end of string
	bne.s   .loop
	move.l  a3,d3
	subq.l  #1,d3
	sub.l   d2,d3			;length
	beq.s   .nothingtowrite
	move.l  DosBase(pc),a6
	jsr	_LVOOutput(a6)
	move.l	d0,d1
	beq.s	.nothingtowrite
	jsr     _LVOWrite(a6)
.nothingtowrite:
	movem.l	(a7)+,d0-a6
	rts


;---------------------------------------------------------------------
*
* main()
*
* d0: text addr
* d1: filelength
* d2: block length
*
main:	moveq	#0,d5
	moveq	#"#",d6			;text start indicator
	move.l	d1,d7
	move.l	d0,a0

\count:	cmp.b	(a0)+,d6		;"##" indicates a start of a text...
	beq.s	\found
\db0:	subq.l	#1,d7
	bne.s	\count
1111$:	tst.l	d5
	bne.s	\random
	bra	wrongfile

\found:	cmp.b	#"*",(a0)
	beq.s	1111$
	cmp.b	(a0),d6
	bne.s	\count
	addq.l	#1,a0
	addq.l	#1,d5			;one text more
	bra.s	\db0

;------------------
\random:
	cmp.l	#$ffff,d5		;maximal #of texts per file
	bgt	wrongfile

	movem.l	d0-d2/d5,-(a7)
	mea	date(pc),d1
	move.l	DosBase(pc),a6
	jsr	_LVODateStamp(a6)

	move.l	date+8(pc),d3		;get
	add.l	d3,d3
	add.l	date+4(pc),d3
	add.l	d3,d3
	add.l	date(pc),d3
	eor.l	#$eb2d367a,d3
	move.l	d3,-(a7)

	lea	gfxname(pc),a1
	move.l	4.w,a6
	jsr	_LVOOldOpenLibrary(a6)
	beq.s	12$
	move.l	d0,a6
	jsr	_LVOVBeamPos(a6)
	move.l	d0,d7
	lsl.l	#3,d7
	jsr	_LVOVBeamPos(a6)
	add	d0,d7
	move.l	d7,-(a7)
	move.l	a6,a1
	move.l	4.w,a6
	jsr	_LVOCloseLibrary(a6)

	movem.l	(a7),d0/d3
	mulu	d0,d3

12$:	addq.l	#8,a7
	movem.l	(a7)+,d0-d2/d5
	move.l	d5,d4
	mulu	d3,d5
	swap	d5
	and.l	#$ffff,d5		;text number
	cmp.l	d5,d4
	bgt.s	1$
	exg	d5,d4


;------------------
;
; d5: text number
;
1$:	moveq	#"#",d6			;text start indicator
	move.l	d1,d7
	move.l	d0,a0
	addq.l	#1,d5			;for first text

\count2:
	cmp.b	(a0)+,d6		;"##" indicates a start of a text...
	beq.s	\found2
\db2:	subq.l	#1,d7
	bne.s	\count2
	moveq	#1,d5			;well, take the first text
	bra.s	1$

\found2:
	cmp.b	#"*",(a0)
	beq.s	11$
	cmp.b	(a0),d6
	bne.s	\count2
	addq.l	#1,a0
	subq.l	#1,d5			;one text more
	bne.s	\db2

11$:	move.b	(a0)+,d0		;search to the end of the '##' line
	beq.s	2$
	cmp.b	#$a,d0
	dbeq	d7,11$

;------------------
;
;a0: text to print...
;
2$:	move.l	a0,a1
	tst.l	d7
	ble.s	\gottext
\count3:
	cmp.b	(a0)+,d6		;"##" indicates a start of a text...
	beq.s	\found3
	subq.l	#1,d7
	bne.s	\count3
	bra.s	\gottext

\found3:
	cmp.b	#"*",(a0)
	beq.s	222$
	cmp.b	(a0),d6
	bne.s	\count3
222$:	subq.l	#1,a0

;------------------
\gottext:
	move.l  a1,d2			;take text pointer
	move.l  a0,d3
	sub.l   a1,d3			;length
	ble.s   .nothingtowrite
	move.l  DosBase(pc),a6
	jsr	_LVOOutput(a6)
	move.l	d0,d1
	beq.s	.nothingtowrite
	jsr     _LVOWrite(a6)
.nothingtowrite:
	rts


;------------------
wrongfile:
	print_	<"Fortune: file error (or not a valid fortune file)!",$a>
	rts


;------------------------------------------------------------------------------
*
* routines
*
	include	startup4.r
	include	dosfile.r


;--------------------------------------------------------------------
*
* Datas
*
gfxname:	dc.b	"graphics.library",0	;for VBeamPos()
		even

;--------------------------------------------------------------------
*
* DX section
*
dosbase:	dx.l	1

date:		dx.l	3		;for date stamp

cmdline:	dx.l	1		;command line
cmdlen:		dx.l	1		;command line length

TextAdr:	dx.l	1		;memory block addr
TextLength:	dx.l	1		;length of the block

filename:	dx.b	162

	end


