;-------------------------------------------------------------------------------
*                                                                              *
* CxChange                                                                     *
*                                                                              *
* Written 1994 by Daniel Weber                                                 *
* Written using the ProAsm assembler                                           *
*                                                                              *
*                                                                              *
*       Filename        cxchange.s                                             *
*       Author          Daniel Weber                                           *
*       Version         1.02                                                   *
*       Start           16.01.94                                               *
*                                                                              *
*       Last Revision   22.02.94                                               *
*                                                                              *
;-------------------------------------------------------------------------------
*                                                                              *
*	command line options                                                   *
*                                                                              *
*	-a = -e     activate/enable commodity                                  *
*	-i = -d     inactivate/disable commodity                               *
*	-h          show interface                                             *
*	-r = -k     remove/kill interface (default)                            *
*	-s          hide interface                                             *
*                                                                              *
;-------------------------------------------------------------------------------

	output	'ram:cxchange'

	opt	o+,q+,ow-,qw-
	verbose
	base	progbase

	filenote	'CxChange, Written 1994 by Daniel Weber'

;-------------------------------------------------------------------------------

	incdir	'include:'
	incdir	'routines:'

	include	'exec/types.i'
	include	'exec/lists.i'
	include	'exec/nodes.i'
	include	'libraries/commodities.i'
	incequ	'LVO.s'
	include	'basicmac.r'
	include	'support.mac'

;-------------------------------------------------------------------------------

version		equr	"1.02"
gea_progname	equr	"CxChange"

;-- startup control  --
cws_V37PLUSONLY	set	1			;only OS2.x or higher
cws_CLIONLY	set	1			;for CLI usage only
cws_EASYLIB	set	1

;-- user definitions --
AbsExecBase	equ	4
DOS.LIB		equ	1
COMMODITIES.LIB	equ	37


workspace	equ	256			;workbuffer

;-- PRIVAT commodities.library functions --
*_LVOFindBroker		EQU	-108	;(char*)(a0)
_LVOCopyBrokerList	EQU	-186	;(struct List*)(a0)
_LVOFreeBrokerList	EQU	-192	;(struct List*)(a0)
_LVOBrokerCommand	EQU	-198	;(char */LONG id)(a0/d0)

;-- PRIVAT structure
;struct BrokerCopy {
;	STRUCT Node	bc_Node;
;	char	bc_Name[CBD_NAMELEN];
;	char	bc_Title[CBD_TITLELEN];
;	char	bc_Descr[CBD_DESCRLEN];
;	LONG	bc_Task;
;	LONG	bc_Dummy1;
;	LONG	bc_Dummy2;
;	UWORD	bc_Flags; }

		RSRESET	0
bc_Node		RS.B	LN_SIZE
bc_Name		RS.B	CBD_NAMELEN
*bc_Title	RS.B	CBD_TITLELEN
*bc_Descr	RS.B	CBD_DESCRLEN
*bc_Task	RS.L	1
*bc_Dummy1	RS.L	1
*bc_Dummy2	RS.L	1
*bc_Flags	RS.W	1


;-------------------------------------------------------------------------------
progbase:
	jmp	AutoDetach(pc)
	dc.b	0,"$VER: ",gea_progname," ",version," (",__date2,")",0
	even

;----------------------------
clistartup:
	lea	progbase(pc),a5
	lea	dxstart(pc),a1			;clear DX area
	move.w	#(dxend-dxstart)/2-1,d7
.clr:	clr.w	(a1)+
	dbra	d7,.clr

	move.l	a7,InitialSP(a5)
	move.l	a0,ArgStr(a5)
	move.l	d0,ArgLen(a5)

	lea	TitleText(pc),a0
	printtext_

	bsr	ReadParameters
	bne	exit
loop
.loop:	bsr	DoCommodity
	bsr	NextName
	beq.s	.loop

exit:	move.l	InitialSP(pc),a7
.quit:	moveq	#0,d0
	bra	ReplyWBMsg


;----------------------------------------------------------
*
* ReadParameters	- small command line parser
*
* a5: progbase
*
* => a0: pointer to zero ended string
* => CCR:  Z ok,  N failed usage, printed
*
ReadParameters:
	move.l	ArgStr(pc),a0
	move.l	ArgLen(pc),d7
	clr.b	-1(a0,d7.l)
	bsr	arg_spacekiller

	cmp.b	#"?",(a0)			;force usage?
	bne.s	.options
	tst.b	1(a0)
	beq	.usage
	cmp.b	#" ",1(a0)
	beq	.usage

.options:
	clr.w	docx(a5)		;[docx=0] 
	tst.b	(a0)
	beq.s	.src
	cmp.b	#"-",(a0)
	bne.s	.usage
	addq.l	#1,a0
	move.b	(a0)+,d0		;get option
	beq.s	.usage
	and.b	#$df,d0
	addq.w	#2,docx(a5)
	cmp.b	#"A",d0			;activate [docx=2] 
	beq.s	.endopts
	cmp.b	#"E",d0			;enable (=activate) [docx=2] 
	beq.s	.endopts
	addq.w	#2,docx(a5)
	cmp.b	#"I",d0			;inactivate [docx=4] 
	beq.s	.endopts
	cmp.b	#"D",d0			;disable (=inactivate) [docx=4] 
	beq.s	.endopts
	addq.w	#2,docx(a5)
	cmp.b	#"S",d0			;show interface [docx=6] 
	beq.s	.endopts
	addq.w	#2,docx(a5)
	cmp.b	#"H",d0			;hide interface [docx=8] 
	beq.s	.endopts
	addq.w	#2,docx(a5)
	cmp.b	#"U",d0			;unique [docx=10] 
	beq.s	.endopts
	addq.w	#2,docx(a5)
	cmp.b	#"K",d0			;kill (=remove) [docx=0]
	beq.s	.endopts
	cmp.b	#"R",d0			;remove [docx=0] 
	bne.s	.usage
.endopts:
	bsr	arg_spacekiller
.src:	move.l	a0,ArgStr(a5)
	bsr.s	arg_skip
	add.l	d4,ArgStr(a5)
	sub.l	d4,a0
	clr.b	(a0)+
	move.l	ArgStr(pc),a1
	move.l	a0,ArgStr(a5)
	move.l	a1,a0
	moveq	#0,d0
	rts


;
; print usage
;
.usage:	lea	UsageText(pc),a0
	printtext_
	moveq	#-1,d0
	rts


;----------------------------------------------------------
*
* <command line parse routines>
*
* skip text
*
* => d4: correction
*
arg_skip:				;skip an argument
	moveq	#0,d4
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


*
* skip spaces
*
arg_spacekiller:			;kill spaces...
	cmp.b	#" ",(a0)+
	beq.s	arg_spacekiller
	subq.l	#1,a0
	rts

;----------------------------------------------------------
*
* get next name from argument string
*
* => a0: pointer to zero ended string
* => CCR:  Z ok,  zN failed usage, printed
*
NextName:
	move.l	ArgStr(pc),a0
	bsr	arg_spacekiller
	tst.b	(a0)			;source file
	beq.s	.nnext
	move.l	a0,ArgStr(a5)
	bsr.s	arg_skip
	add.l	d4,ArgStr(a5)
	sub.l	d4,a0
	clr.b	(a0)+
	move.l	ArgStr(pc),a1
	move.l	a0,ArgStr(a5)
	move.l	a1,a0
	moveq	#0,d0
	rts
.nnext:	moveq	#-1,d0
	rts


;----------------------------------------------------------
*
* DoRawFmt
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


;-------------------------------------------------------------------------------
*
* DoCommodity	- sent a message to the specified commodity
*
;-------------------------------------------------------------------------------

;
; a0: name of commodity or pointer to zero byte
;
DoCommodity:
	move.l	CommoditiesBase(pc),a6
	tst.b	(a0)
	beq.s	.sendtoall
	moveq	#0,d0
	move.w	docx(pc),d0
	beq	.out
	move.w	.cx_ID-2(pc,d0.w),d0	;get id
	jmp	_LVOBrokerCommand(a6)

;
; ID list for idnumber to id conversion
;
.cx_ID:	dc.w	CXCMD_ENABLE	;enable
	dc.w	CXCMD_DISABLE	;disable
	dc.w	CXCMD_APPEAR	;show interface
	dc.w	CXCMD_DISAPPEAR	;hide interface
	dc.w	CXCMD_UNIQUE	;unique
	dc.w	CXCMD_KILL	;kill

;
; send commodity id to all system commodities
;
.sendtoall:
	lea	cxlist(pc),a0
	NEWLIST	a0				;macro from exec/lists.i
	move.l	a0,a2
	jsr	_LVOCopyBrokerList(a6)		;copy broker list


	move.l	LH_HEAD(a2),d0
	beq.s	.out
	move.l	d0,a2

.cxloop:
	tst.l	(a2)
	beq.s	.out
	lea	bc_Name(a2),a0
	lea	rawlist(pc),a1
	move.l	a0,(a1)
	lea	processtext(pc),a0
	lea	workbuffer(pc),a3
	bsr	DoRawFmt
	lea	workbuffer(pc),a0
	printtext_
	moveq	#0,d0
	move.w	docx(pc),d0
	beq.s	.next
	move.w	.cx_ID-2(pc,d0.w),d0		;get ID
	lea	bc_Name(a2),a0
	jsr	_LVOBrokerCommand(a6)
.next:	move.l	(a2),a2
	bra.s	.cxloop

.endcx:	lea	cxlist(pc),a0
	jsr	_LVOFreeBrokerList(a6)
.out:	rts


;-------------------------------------------------------------------------------
*
* external routines
*
;-------------------------------------------------------------------------------
	include	startup4.r


;-------------------------------------------------------------------------------
*
* data area
*
;-------------------------------------------------------------------------------

TitleText:	dc.b	$9b,"1m",gea_progname,$9b,"0m v",version
		dc.b    " - controls system commodities",$a
		dc.b	"Written 1994 by Daniel Weber",$a,0

UsageText:	dc.b	$a
		dc.b	"Usage: ",$9b,"3m",gea_progname
		dc.b	" [-options name [names]]"
		dc.b	$9b,"0m",$a,0

processtext:	dc.b	"""%s""",$a,0
		even

dxstart:
;-------------------------------------------------------------------------------
InitialSP:	dx.l	1
ArgStr:		dx.l	1		;parameter line
ArgLen:		dx.l	1		;parameter line length

;--- commoditiy -------------------------------------------
docx:		dx.w	1		;broker command number
cxlist:		dx.b	LH_SIZE		;space for broker list


;--- workbuffer -------------------------------------------
rawlist:	dx.l	1		;buffer for rawlist
workbuffer:	dx.b	workspace	;workbuffer

;-------------------------------------------------------------------------------
	aligndx.w
dxend:
	end
