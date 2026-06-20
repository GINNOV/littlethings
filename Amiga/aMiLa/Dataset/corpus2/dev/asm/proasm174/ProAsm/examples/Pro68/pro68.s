;-------------------------------------------------------------------------------
*                                                                              *
* Pro68 - small CLI2ASX user interface                                         *
*                                                                              *
*                                                                              *
*       Filename        pro68.s                                                *
*       Author          Daniel Weber                                           *
*       Version         1.00                                                   *
*       Start           05.07.93                                               *
*                                                                              *
*       Last Revision   12.07.93                                               *
*                                                                              *
;-------------------------------------------------------------------------------

	output	'ram:pro68'

;	opt	o+,q+,ow-,qw-
	verbose
	base	progbase

	filenote	'Pro68, written 1993 by Daniel Weber'

;-------------------------------------------------------------------------------

	incdir	'include:'
	incdir	'routines:'

	incequ	'LVO.s'

	include	'proasm/asx.i'

;-------------------------------------------------------------------------------

version		equr	"1.00"
gea_progname	equr	"Pro68"

;-- startup control  --
cws_CLIONLY	set	1			;for CLI usage only
cws_EASYLIB	set	1


;-- user definitions --
AbsExecBase	equ	4
DOS.LIB		equ	1


;-- asx.i --------------

_LVOasx_Assemble	equ	-30	;library vector


;-------------------------------------------------------------------------------
progbase:
	jmp	AutoDetach(pc)
	dc.b	0,"$VER: ",gea_progname," ",version," (",__date2,")",0
	even

;----------------------------
clistartup:
	lea	progbase(pc),a5

	clr.b	-1(a0,d0.l)			;last char must be zero
	move.l	a0,argstring(a5)
	move.l	a0,a1

	lea	TitleText(pc),a0		;print title
	bsr	printtext

	move.b	(a1),d0				;small command line parameter
	beq.s	.usage				;handling
	cmp.b	#"?",d0
	bne.s	1$
	move.b	1(a1),d0
	beq.s	.usage
	cmp.b	#" ",d0	
	bne.s	1$
.usage:	lea	UsageText(pc),a0		;print 'usage' message
	bsr	printtext
	bra.s	exit


1$:	bsr	main

exit:	moveq	#0,d0				;quit
	bra	ReplyWBMsg





;-------------------------------------------------------------------------------
*
* main
*
;-------------------------------------------------------------------------------

main:	move.l	4.w,a6
	lea	asxname(pc),a1
	jsr	_LVOOldOpenLibrary(a6)		;open asx.library
	tst.l	d0
	beq	noasxlibrary			;no library found...
	move.l	d0,a4				;store asxbase

	move.l	DosBase(pc),a6
	jsr	_LVOOutput(a6)			;get StdOut

	move.l	argstring(pc),a0
	lea	speciallist(pc),a1
	move.l	d0,ax_StdOut(a1)		;StdOut
	move.l	a4,a6
	jsr	_LVOasx_Assemble(a6)
	move.l	d0,d7				;store return value

	move.l	a1,a4				;store special list
	move.l	a6,a1
	move.l	4.w,a6
	jsr	_LVOCloseLibrary(a6)		;close asx.library

	tst.l	d7				;test return value
	beq	assemblyfailed
	rts



;
; no asx.library found
;
noasxlibrary:
	lea	asxtaskname(pc),a1
	move.l	4.w,a6
	jsr	_LVOFindTask(a6)
	lea	nolibText(pc),a0		;asx.library not enabled
	tst.l	d0
	bne.s	1$
	lea	noASXText(pc),a0		;no ASX master task found
1$:	bra	printtext


;
; assembly failed (probably corrupt 'speciallist')
;
assemblyfailed:
	lea	failedText(pc),a0
	bra	printtext


;-------------------------------------------------------------------------------
*
* sub routines
*
;-------------------------------------------------------------------------------

;------------------------------------------------
*
* printraw	- print raw text
*
* a0: format string
* a1: rawlist
*
printraw:
	move.l	a3,-(a7)
	lea	workbuffer(pc),a3
	bsr.s	DoRawFmt
	move.l	a3,a0
	bsr	printtext
	movem.l	(a7)+,a3
	rts


;------------------------------------------------
*
* DoRawFmt	- Format a string
*
* a0: format
* a1: data stream
* a3: dest. buffer
*
DoRawFmt:
	movem.l	d0-a6,-(a7)
	lea	.setin(pc),a2
	move.l	4.w,a6
	jsr	_LVORawDoFmt(a6)
	movem.l	(a7)+,d0-a6
	rts

.setin:	move.b	d0,(a3)+
	rts


;------------------------------------------------
*
* printext	- print a given text to StdOut
*
* a0: pointer to text to be written
*
printtext:
	movem.l d0-a6,-(a7)		;a0: textpointer
	move.l  a0,d2
.loop:	tst.b   (a0)+			;search end of string
	bne.s   .loop
	move.l  a0,d3
	subq.l  #1,d3
	sub.l   d2,d3			;length
	beq.s   .nothingtowrite

	move.l  DosBase(pc),a6
	jsr	_LVOOutput(a6)		;get StdOut handle
	move.l	d0,d1
	beq.s	.nothingtowrite
	jsr     _LVOWrite(a6)		;write text to StdOut

.nothingtowrite:
	movem.l (a7)+,d0-a6
	rts



;-------------------------------------------------------------------------------
*
* external routines
*
;-------------------------------------------------------------------------------
	include	startup4.r


;-------------------------------------------------------------------------------
*
* data
*

* texts, messages etc.
asxname:	dc.b	"asx.library",0
asxtaskname:	dc.b	"ASX Master",0


TitleText:	dc.b	$9b,"1m",gea_progname,$9b,"0m - "
		dc.b	"Shell-ASX Interface v",version,$a
		dc.b	"Written 1993 by Daniel Weber",$a,$a,0

UsageText:	dc.b	"Usage: ",$9b,"3mPro68 <ProAsm command line>",$9b,"0m"
		dc.b	$a,0

failedText:	dc.b	"failed, job aborted.",$a,0
nolibText:	dc.b	"Couldn't open 'asx.library'.",$a,0
noASXText:	dc.b	"No ASX user interface installed.",$a,0

		even

* CLI
argstring:	dc.l	0		;stored pointer to argument string

* ASX
speciallist:	dc.l	Pro68Magic
		ds.b	ax_SIZEOF-4
* Exec
rawlist:	ds.l	6		;Data stream for the RawDoFmt routine

* workbuffer
workbuffer:	dx.b	200		;workbuffer


;-------------------------------------------------------------------------------
	end

