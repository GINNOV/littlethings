; Keymap Compiler
; (c) 1993 MJSoft System Software
; Martin Mares

;	opt	x+

	include	"ssmac.h"

	tbase	a4
	clistart

	writeln	<Keymap Compiler 1.0, (c) 1993 MJSoft System Software>

	get.l	from,a0			; Load source file
	geta	fromname,a1
	dtl	<kms>,a2
	moveq	#80,d0
	call	ss,AddExtension
	geta	fromname,a0
	call	LoadFile
	move.l	d0,a3			; A3 points to source file

	get.l	to,d0			; Create destination file
	bne.s	opento
	geta	fromname,a0
	move.l	a0,d1
	call	dos,FilePart
	move.l	d0,a1
	geta	work,a2
	move.l	a2,a0
copyfn1	move.b	(a1)+,(a2)+
	bne.s	copyfn1
	push	a0
	call	ss,RemExtension
	pop	d0
opento	move.l	d0,a0
	move.l	#1006,d0
	push	a0
	call	ss,TrackOpen
	move.l	d0,d7			; D7=destfh

	vpea	fromname
	dtl.l	<Compiling %s to %s.>,a0
	move.l	sp,a1
	call	Printf
	addq.l	#8,sp

; Build hash table

	move.l	#128,d0
	moveq	#0,d1
	call	ss,InitHashTree
	put.l	d0,htr
	dv.l	htr

	lea	keytab(pc),a2
	moveq	#0,d2
bhat_loop	tst.b	(a2)
	beq.s	bhat_end
	get.l	htr,a0
	move.l	a2,a1
	moveq	#2,d0
	call	AddHashItem
	move.l	d0,a0
	move.w	d2,(a0)+
	addq.w	#1,d2
bhat_next	tst.b	(a2)+
	bne.s	bhat_next
	bra.s	bhat_loop

; Create header of destination file

bhat_end	move.l	d7,d1
	geta	hh_id,a0
	move.l	a0,d2
	move.l	#hdrend-hh_id,d3
	moveq	#1,d4
	bsr	chfwrite

; Initialize some fields in the header

	lea	inittab(pc),a0
1$	move.w	(a0)+,d0
	beq.s	2$
	move.w	(a0)+,d1
	geta	hh_id,a1
	add.w	d0,a1
	move.w	d1,(a1)
	bra.s	1$
2$	dv.l	lino			; Line number
	put.w	#1,lino+2
	dv.l	chlen			; Code hunk length
	put.w	#hdrend-km_node,chlen+2

; Initialize data structures

	geta	keytypes,a0
	moveq	#103,d0
	moveq	#-128,d1
init_1	move.b	d1,(a0)+
	dbra	d0,init_1

; Start parsing of source

srcloop	bsr	getobj		; Read key header
srcentry	tst.b	d1
	beq.s	srcloop
	bmi	saveit
	subq.b	#3,d1
	bne.s	exkey
	moveq	#$20,d5
	cmp.b	#$6c,d0
	beq.s	keyex1
	moveq	#$40,d5
	cmp.b	#$6d,d0
	beq.s	keyex1
	moveq	#0,d5
	cmp.b	#$71,d0
	beq.s	keyex2
exkey	moveq	#6,d0
	bra	error

keyex1	bsr	getobj
	subq.b	#3,d1
	bne.s	exkey
	cmp.b	#$71,d0
	bne.s	exkey		; D5 now holds correct key type
keyex2	bsr	getobj		; Read key name
	subq.b	#3,d1
	bne.s	exkey1
	cmp.b	#104,d0
	bcs.s	keyex3
exkey1	moveq	#7,d0
	bra	error

keyex3	move.l	d0,d6		; D6=key code
	moveq	#0,d4		; D4.0 = nonrepeatable, .1=capsable
keyflg	bsr	getobj		; Parse key flags
	tst.b	d1
	beq.s	keybody
	bmi.s	keyincl
	subq.b	#3,d1
	bne.s	exkey
	moveq	#0,d1
	cmp.b	#$68,d0	; SHIFT
	beq.s	keyfl1
	moveq	#1,d1
	cmp.b	#$69,d0	; ALT
	beq.s	keyfl1
	moveq	#2,d1
	cmp.b	#$70,d0	; CTRL
	beq.s	keyfl1
	moveq	#0,d1
	cmp.b	#$6a,d0	; CAPS
	beq.s	keyfl2
	moveq	#1,d1
	cmp.b	#$6b,d0	; NOREP
	beq.s	keyfl2
keyincl	moveq	#8,d0
keyincle	bra	error

keyfl1	bset	d1,d5
keyfl	beq.s	keyflg
	moveq	#9,d0
	bra.s	keyincle
keyfl2	bset	d1,d4
	bra.s	keyfl

keytwice	moveq	#12,d0
	bra	error

keybody	geta	keytypes,a0	; Key header done, store the flags
	add.l	d6,a0
	cmp.b	#$80,(a0)
	bne.s	keytwice
	move.b	d5,(a0)
	move.l	d6,d0
	lsr.w	#3,d0
	geta	capsable,a0
	btst	#1,d4	; NoRep
	bne.s	1$
	bset	d6,(repeatable-capsable)(a0,d0.w)
1$	btst	#0,d4	; Caps
	beq.s	2$
	bset	d6,0(a0,d0.w)
2$	add.l	d6,d6
	add.l	d6,d6
	geta	keydata,a2
	add.l	d6,a2
	dv.b	usedmean
	clrv.b	usedmean
	dv.l	alloccount
	moveq	#0,d0
	moveq	#0,d2
	not.b	d5
3$	move.b	d0,d1
	and.b	d5,d1
	bne.s	31$
	addq.l	#2,d2
31$	addq.b	#1,d0
	cmp.b	#8,d0
	bcs.s	3$
	not.b	d5
	put.l	d2,alloccount

	btst	#5,d5
	bne.s	bodydead
	btst	#6,d5
	bne.s	bodystrg

bodynorm	moveq	#0,d6		; Body of normal key
	moveq	#0,d2
normloop	moveq	#4,d3
	move.b	d5,d0
	addq.b	#1,d0
	and.b	#7,d0
	beq.s	1$
	moveq	#0,d3
1$	bsr	getflags
	cmp.b	#1,d1
	bne.s	normend
	lsl.l	#3,d4
	lsl.l	d4,d0
	or.l	d0,d6
	bsr	checkeol
	bra.s	normloop

normend	move.l	d6,(a2)
	bra	srcentry

bodystrg	bsr	clrwork
strgloop	moveq	#0,d3
	bsr	getflags
	cmp.b	#2,d1
	bne.s	strgend
	add.l	d4,d4
	move.l	d0,d2
	move.l	d0,a0
	bsr	strlen
	geta	work,a0
	move.b	d0,0(a0,d4.l)
	bsr	allocate
	move.b	d0,1(a0,d4.l)
	move.l	d2,a0
	geta	work,a1
	add.l	d0,a1
1$	move.b	(a0)+,(a1)+
	bne.s	1$
	bsr	checkeol
	bra.s	strgloop
strgend	bsr	shipout
	bra	srcentry

bodydead	bsr	clrwork
	push	a2
deadloop	moveq	#0,d3
	bsr	getflags
	add.l	d4,d4
	geta	work,a2
	add.l	d4,a2
	cmp.b	#1,d1
	beq.s	deadnorm
	cmp.b	#3,d1
	bne.s	deadend
	cmp.w	#$6f,d0	; MOD
	beq.s	deadmod
	cmp.w	#$6e,d0	; PREFIX
	bne.s	deadend
	move.b	#$08,(a2)+
	bsr	getobj
	subq.b	#1,d1
	bne.s	pxexp
	move.b	d0,(a2)
	cmp.b	#16,d0
	bcc.s	pxexp5
	bsr	getobj
	tst.b	d1
	beq.s	deadloop
	bmi.s	deadloop
	subq.b	#5,d1
	bne.s	pxexp2
	bsr	getobj
	subq.b	#1,d1
	bne.s	pxexp4
	cmp.b	#16,d0
	bcc.s	pxexp5
	lsl.b	#4,d0
	or.b	d0,(a2)
	bsr	checkeol
	bra.s	deadloop

pxexp	moveq	#17,d0
pxexp3	bra	error
pxexp2	moveq	#20,d0
	bra.s	pxexp3
pxexp4	moveq	#21,d0
	bra.s	pxexp3
pxexp5	moveq	#22,d0
	bra.s	pxexp3

deadend	pop	a2
	bsr.s	shipout
	bra	srcentry

deadnorm	sf	(a2)+
	move.b	d0,(a2)+
	bsr	checkeol
	bra	deadloop

deadmod	moveq	#0,d0
	bsr.s	allocate
	move.b	#1,(a2)+
	move.b	d0,(a2)+
	geta	work,a2
	add.l	d0,a2
modloop	bsr	getobj
	subq.b	#1,d1
	bne.s	deadmoder
	addqv.l	#1,alloccount
	move.b	d0,(a2)+
	bsr	getobj
	tst.b	d1
	beq	deadloop
	bmi	deadloop
	subq.b	#5,d1
	beq.s	modloop
comexer	moveq	#19,d0
	bra.s	deadmoder2
deadmoder	moveq	#18,d0
deadmoder2	bra	error

; String operations

strlen	move.l	a0,d0
1$	tst.b	(a1)+
	bne.s	1$
	sub.l	a1,d0
	neg.l	d0
	subq.l	#1,d0
	rts

; Allocation of dynamic key data

allocate	get.l	alloccount,d1
	cmp.w	#256,d1
	bcc.s	allocerr
	exg.l	d0,d1
	add.l	d0,d1
	put.l	d1,alloccount
	rts

allocerr	moveq	#16,d0
	bra	error

shipout	mpush	d0-d4
	get.l	chlen,(a2)
	move.l	d7,d1
	geta	work,a0
	move.l	a0,d2
	get.l	alloccount,d3
	moveq	#1,d4
	bsr	chfwrite
	mpop	d0-d4
	rts

clrwork	geta	work,a0
	moveq	#31,d0
1$	clr.l	(a0)+
	dbra	d0,1$
	rts

; Check EOL condition

checkeol	bsr	getobj
	tst.b	d1
	bmi.s	1$
	bne.s	2$
1$	rts
2$	moveq	#15,d0
	bra	error

; Get meaning flags (D3=disabled flags)

getflags	moveq	#0,d4		; D4 holds the flags
	move.b	d5,d0
	not.b	d0
	and.b	#$07,d0
	or.b	d0,d3
flagloop	bsr	getobj
	tst.b	d1
	beq.s	flageol
	bmi.s	flageof
	cmp.b	#3,d1
	bne.s	flagend
	moveq	#0,d2
	cmp.b	#$68,d0
	beq.s	flagflag
	moveq	#1,d2
	cmp.b	#$69,d0
	beq.s	flagflag
	moveq	#2,d2
	cmp.b	#$70,d0
	bne.s	flagend
flagflag	btst	d2,d3
	bne.s	flagbad
	bset	d2,d4
	beq.s	flagloop
	moveq	#14,d0
	bra.s	flagfler

flagbad	moveq	#10,d0
flagfler	bra	error

flageol	tst.b	d4
	beq.s	flagloop
flagerr	moveq	#11,d0
	bra.s	flagfler

flagend	cmp.b	#3,d1
	bne.s	flagend1
	cmp.w	#$6c,d0
	beq.s	flageof
	cmp.w	#$6d,d0
	beq.s	flageof
	cmp.w	#$71,d0
	beq.s	flageof
flagend1	bsetv	d4,usedmean
	bne.s	flagtwic
	moveq	#1,d2		; Normalize flags
	moveq	#0,d3
	not.b	d5
	push	d0
1$	move.b	d2,d0
	and.b	d5,d0
	bne.s	2$
	addq.b	#1,d3
	cmp.b	d2,d4
	bne.s	2$
	move.b	d3,d4
	bra.s	3$
2$	addq.b	#1,d2
	cmp.b	#8,d2
	bcs.s	1$
3$	pop	d0
	not.b	d5
flageof	rts

flagtwic	moveq	#13,d0
	bra.s	flagfler

; Save the rest of keymap

saveit	vmovev.l	chlen,km_name
	geta	fromname,a0
	move.l	a0,d1
	call	dos,FilePart
	move.l	d0,a0
	move.l	d0,d2
	call	ss,RemExtension
	move.l	d2,a0
	move.l	d2,a1
1$	tst.b	(a1)+
	bne.s	1$
	sub.l	a0,a1
	move.l	a1,d3
	moveq	#1,d4
	move.l	d7,d1
	bsr	chfwrite

	move.l	d7,d1			; Pad to longword boundary
	lea	huend+4(pc),a0
	move.l	a0,d2
	get.l	chlen,d3
	neg.l	d3
	moveq	#3,d0
	and.l	d0,d3
	beq.s	save1
	sub.l	d3,d2
	moveq	#1,d4
	bsr	chfwrite

save1	get.l	chlen,d0		; Adjust hunk length
	addq.l	#3,d0
	lsr.l	#2,d0
	put.l	d0,hh_size
	put.l	d0,hc_size

	move.l	#$3ec,d0		; Put HUNK_RELOC
	bsr	putl
	moveq	#9,d0			; Count relocations
	geta	keytypes,a0
	moveq	#103,d1
countrel	move.b	(a0)+,d2
	and.b	#$60,d2
	beq.s	1$
	addq.l	#1,d0
1$	dbra	d1,countrel
	bsr	putl
	moveq	#0,d0
	bsr	putl
	lea	reloxs(pc),a0		; Write basic relocations
	move.l	d7,d1
	move.l	a0,d2
	moveq	#36,d3
	moveq	#1,d4
	bsr	chfwrite
	geta	keytypes,a2		; Relocs for string & dead keys
	move.l	#keydata-km_node,d2
2$	move.b	(a2)+,d0
	and.b	#$60,d0
	beq.s	3$
	move.l	d2,d0
	bsr.s	putl
3$	addq.l	#4,d2
	cmp.l	#keydata-km_node+104*4,d2
	bcs.s	2$

	moveq	#0,d0			; End of relocs
	bsr.s	putl

	move.l	#$3f2,d0		; Write HUNK_END
	bsr.s	putl
	move.l	d7,d1			; ... and rewrite the header
	call	Flush
	move.l	d7,d1
	moveq	#0,d2
	moveq	#-1,d3
	call	Seek
	move.l	d7,d1
	geta	hh_id,a0
	move.l	a0,d2
	move.l	#hdrend-hh_id,d3
	bsr.s	chwrite

	writeln	<Done.>

	rts

; Relocation table

reloxs	dc.l	km_name-km_node
	dc.l	lo_types-km_node
	dc.l	lo_data-km_node
	dc.l	lo_caps-km_node
	dc.l	lo_rept-km_node
	dc.l	hi_types-km_node
	dc.l	hi_data-km_node
	dc.l	hi_caps-km_node
	dc.l	hi_rept-km_node

; Output routines

putl	mpush	d0-d4			; Put one longword
	move.l	d7,d1
	move.l	sp,d2
	moveq	#4,d3
	moveq	#1,d4
	bsr.s	chfwrite
	mpop	d0-d4
	rts

chwrite	call	dos,Write
	cmp.l	d0,d3
	bra.s	chfwr1

chfwrite	call	dos,FWrite
	addv.l	d3,chlen
	moveq	#1,d1
	cmp.l	d0,d1
chfwr1	bne.s	writerr
	rts
writerr	err	<Error writing destination file!>

; Data for generating of hunk longword pad

huend	dc.l	0

; Get object from source file
; A3=SrcPtr => D1=ObjType,D0=ObjValue

ot_eof	equ	-1	; End of file
ot_eol	equ	0	; End of line
ot_number	equ	1	; Number
ot_string	equ	2	; Quoted string, Value=&string contents
ot_keyword	equ	3	; Keyword, Value=Keyword#
ot_unknown	equ	4	; Unknown non-quoted string, Value=&string
ot_comma	equ	5	; A comma

getobj	move.b	(a3)+,d0		; Main loop
	beq.s	gob_eof
	cmp.b	#' ',d0
	beq.s	getobj
	cmp.b	#9,d0
	beq.s	getobj
	cmp.b	#10,d0
	beq	gob_eol
	cmp.b	#'0',d0
	bcs.s	gob_1
	cmp.b	#'9'+1,d0
	bcs	gob_num
gob_1	cmp.b	#'"',d0
	beq	gob_str
	cmp.b	#',',d0
	beq.s	gob_comma
	cmp.b	#';',d0
	beq.s	gob_semic
	cmp.b	#'\',d0
	beq.s	gob_baksl
	cmp.b	#'''',d0
	beq.s	gob_char
	cmp.b	#'_',d0
	beq	gob_unq
	cmp.b	#'?',d0
	beq	gob_unq
	cmp.b	#'A',d0
	bcs.s	gob_bad
	cmp.b	#'Z'+1,d0
	bcs	gob_unq
	cmp.b	#'a',d0
	bcs.s	gob_bad
	cmp.b	#'z'+1,d0
	bcs	gob_unq
gob_bad	moveq	#0,d0
	bra	error

gob_eof	subq.l	#1,a3			; End of file
	moveq	#-1,d1
	rts

gob_baksl	cmp.b	#10,(a3)+		; Ignored end of line
	bne.s	gob_bad
	addq.l	#1,a3
	addqv.l	#1,lino
	bra	getobj

gob_semic	move.b	(a3)+,d0		; Comment
	beq.s	gob_eof
	cmp.b	#10,d0
	bne.s	gob_semic
gob_eol	addqv.l	#1,lino			; End of line
	moveq	#0,d1
	rts

gob_comma	moveq	#5,d1			; Comma
	rts

gob_char	moveq	#0,d0			; Quoted character
	move.b	(a3)+,d0
	beq.s	1$
	cmp.b	#10,d0
	beq.s	1$
	cmp.b	#'''',d0
	bne.s	2$
	cmp.b	(a3)+,d0
	bne.s	1$
2$	cmp.b	#'''',(a3)+
	bne.s	1$
	bra.s	num_end

1$	moveq	#1,d0
	bra	error

gob_num	subq.l	#1,a3			; Decimal number
	moveq	#0,d0
	moveq	#0,d1
1$	move.b	(a3)+,d1
	sub.b	#'0',d1
	bcs.s	2$
	cmp.b	#10,d1
	bcc.s	2$
	mulu	#10,d0
	add.l	d1,d0
	cmp.w	#256,d0
	bcs.s	1$
	moveq	#2,d0
	bra	error
2$	subq.l	#1,a3
num_end	moveq	#1,d1
	rts

gob_str	move.l	a3,a0			; Quoted string
	subq.l	#1,a0
	move.l	a0,a1
1$	move.b	(a3)+,d0
	beq.s	str_bad
	cmp.b	#10,d0
	beq.s	str_bad
	cmp.b	#'"',d0
	beq.s	2$
	cmp.b	#'\',d0
	beq.s	3$
10$	move.b	d0,(a0)+
	bra.s	1$

3$	move.b	(a3)+,d0
	cmp.b	#'\',d0
	beq.s	10$
	cmp.b	#'"',d0
	beq.s	10$
	bsr.s	getnib
	move.b	d0,d1
	lsl.b	#4,d1
	move.b	(a3)+,d0
	bsr.s	getnib
	or.b	d1,d0
	bra.s	10$

2$	cmp.b	(a3)+,d0
	beq.s	10$
	subq.l	#1,a3
	sf	(a0)+
	move.l	a1,d0
	moveq	#2,d1
	rts

str_bad	moveq	#3,d0
	bra	error

getnib	sub.b	#'0',d0
	bcs.s	1$
	cmp.b	#10,d0
	bcs.s	2$
	and.b	#$DF,d0
	cmp.b	#17,d0
	bcs.s	1$
	subq.b	#7,d0
	cmp.b	#16,d0
	bcc.s	1$
2$	rts

1$	moveq	#4,d0
	bra.s	error

gob_unq	subq.l	#1,a3			; Unquoted string
	geta	strbuf,a0
	move.l	a0,a1
	moveq	#63,d1
1$	move.b	(a3)+,d0
	cmp.b	#'_',d0
	beq.s	3$
	cmp.b	#'?',d0
	beq.s	3$
	cmp.b	#'0',d0
	bcs.s	2$
	cmp.b	#'9'+1,d0
	bcs.s	3$
	and.b	#$DF,d0
	cmp.b	#'A',d0
	bcs.s	2$
	cmp.b	#'Z'+1,d0
	bcc.s	2$
3$	move.b	d0,(a0)+
	dbra	d1,1$
	bra.s	snerr

2$	subq.l	#1,a3
	sf	(a0)
	push	a1
	get.l	htr,a0
	call	ss,FindHashItem
	tst.l	d0
	beq.s	4$
	move.l	d0,a0
	addq.l	#4,sp
	moveq	#0,d0
	move.w	(a0),d0
	moveq	#3,d1
	rts

4$	pop	d0
	moveq	#4,d1
	rts

snerr	moveq	#5,d0

; Errors

error	dtl.l	<Error in line %ld in file %s: %s !>,a0
	add.w	d0,d0
	move.w	errptrs(pc,d0.w),d0
	pea	errptrs(pc,d0.w)
	vpea	fromname
	vpush	lino
	move.l	sp,a1
	call	ss,Printf
	put.w	#10,sv_rc+2
	jump	ExitCleanup

ert	macro
	dc.w	err\1-errptrs
	endm

errptrs	ert	0
	ert	1
	ert	2
	ert	3
	ert	4
	ert	5
	ert	6
	ert	7
	ert	8
	ert	9
	ert	10
	ert	11
	ert	12
	ert	13
	ert	14
	ert	15
	ert	16
	ert	17
	ert	18
	ert	19
	ert	20
	ert	21
	ert	22

err0	dc.b	'Illegal character',0
err1	dc.b	'Malformed character constant',0
err2	dc.b	'Number out of range',0
err3	dc.b	'String constant exceeds line',0
err4	dc.b	'Bad character code',0
err5	dc.b	'Syntax error',0
err6	dc.b	'Incorrect key definition',0
err7	dc.b	'Key name expected',0
err8	dc.b	'Unexpected end of file',0
err9	dc.b	'Key attribute already set',0
err10	dc.b	'Unexpected attribute',0
err11	dc.b	'Key meaning expected',0
err12	dc.b	'Key defined twice',0
err13	dc.b	'Key meaning defined twice',0
err14	dc.b	'Attribute defined twice',0
err15	dc.b	'End of line expected',0
err16	dc.b	'Dynamic part of key data too long',0
err17	dc.b	'Prefix number expected',0
err18	dc.b	'Character/number expected',0
err19	dc.b	'Comma expected',0
err20	dc.b	'Comma or end of line expected',0
err21	dc.b	'Secondary prefix number expected',0
err22	dc.b	'Prefix number out of range (must be 0-15)',0

	even

; Init table

iten	macro
	dc.w	\1-hh_id+2,\2
	endm

itoff	macro
	iten	\1,\2-km_node
	endm

inittab	iten	hh_id,$03f3
	iten	hh_num,1
	iten	hc_id,$03e9
	itoff	lo_types,keytypes
	itoff	lo_data,keydata
	itoff	lo_caps,capsable
	itoff	lo_rept,repeatable
	itoff	hi_types,keytypes+64
	itoff	hi_data,keydata+256
	itoff	hi_caps,capsable+8
	itoff	hi_rept,repeatable+8
	dc.w	0

; Data

	dbuf	keyflags,$68	; Standard key flags (see keymap.i)
	dbuf	auxflags,$68	; b0=NOREP,b1=CAPS
	dbuf	keys,$68	; Key data
	dbuf	relocs,104*4	; Relocation offsets of keys

	dbuf	fromname,80	; Source name

; Output file:

	dv.l	hh_id		; HUNK_HEADER
	dv.l	hh_null
	dv.l	hh_num		; Number of hunks = 1
	dv.l	hh_first
	dv.l	hh_last
	dv.l	hh_size		; Size of code hunk
	dv.l	hc_id		; HUNK_CODE
	dv.l	hc_size		; Size of code hunk

	dbuf	km_node,10	; Keymap node
	dv.l	km_name		; R32#0 Pointer to name
	dv.l	lo_types	; R32#1
	dv.l	lo_data		; R32#2
	dv.l	lo_caps		; R32#3
	dv.l	lo_rept		; R32#4
	dv.l	hi_types	; R32#5
	dv.l	hi_data		; R32#6
	dv.l	hi_caps		; R32#7
	dv.l	hi_rept		; R32#8

	dbuf	keytypes,104	; KeyType array
	dbuf	keydata,104*4	; KeyData array
	dbuf	capsable,14	; Key capsability
	dbuf	repeatable,14	; Key repeatability
	dbuf	hdrend,0	; End of file header

	dbuf	work,512	; Used when building key blocks
	dbuf	strbuf,64	; Buffer for non-quoted strings

; Key names and keywords

keytab	dc.b	'TILDE',0,'ONE',0,'TWO',0,'THREE',0,'FOUR',0,'FIVE',0,'SIX',0,'SEVEN',0,'EIGHT',0	;0
	dc.b	'NINE',0,'ZERO',0,'MINUS',0,'EQUAL',0,'BACKSLASH',0,'???1',0,'K0',0		;9
	dc.b	'Q',0,'W',0,'E',0,'R',0,'T',0,'Y',0,'U',0,'I',0		;10
	dc.b	'O',0,'P',0,'LBRACK',0,'RBRACK',0,'???2',0,'K1',0,'K2',0,'K3',0	;18
	dc.b	'A',0,'S',0,'D',0,'F',0,'G',0,'H',0,'J',0,'K',0		;20
	dc.b	'L',0,'SEMICOLON',0,'APOSTROPHE',0,'HASH',0,'???3',0,'K4',0,'K5',0,'K6',0 ; 28
	dc.b	'LESS',0,'Z',0,'X',0,'C',0,'V',0,'B',0,'N',0,'M',0	;30
	dc.b	'COMMA',0,'DOT',0,'SLASH',0,'???4',0,'KDOT',0,'K7',0,'K8',0,'K9',0	;38
	dc.b	'SPACE',0,'BACKSPACE',0,'TAB',0,'KENTER',0,'ENTER',0,'ESC',0,'DEL',0,'???5',0	;40
	dc.b	'???6',0,'???7',0,'KMINUS',0,'???8',0,'UP',0,'DOWN',0,'RIGHT',0,'LEFT',0		;48
	dc.b	'F1',0,'F2',0,'F3',0,'F4',0,'F5',0,'F6',0,'F7',0,'F8',0				;50
	dc.b	'F9',0,'F10',0,'KLBRACK',0,'KRBRACK',0,'KSLASH',0,'KASTERISK',0,'KPLUS',0,'HELP',0		;58
	dc.b	'LSHIFT',0,'RSHIFT',0,'CAPSLOCK',0,'CONTROL',0,'LALT',0,'RALT',0,'LAMIGA',0,'RAMIGA',0 ;60
	dc.b	'SHIFT',0,'ALT',0,'CAPS',0,'NOREP',0,'DEAD',0,'STRING',0,'PREFIX',0,'MOD',0 ; Keywords: 68
	dc.b	'CTRL',0,'KEY',0	; 70
	dc.b	0

	tags

	template	<FROM/A,TO>
	dv.l	from
	dv.l	to

	finish

	end
