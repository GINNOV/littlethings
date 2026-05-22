	XDEF	IVarPError,VarPError,PSymTab,OutLst,OutMsg
	XDEF	UsrTxt,MsgTbl,TotErr,LstErr,TotWarn,LstWarn,CursPtr,CursW

	XREF	StrtTime,StopTime,FatalError,NoPrtEnd
	XREF	Sprintf,PrtLine,PrtNChar,GetShifts
	XREF	StartRoutines,Ligne
	XREF	FieldsPtr,maflags
	XREF	SrcCurName,IEnvFlg
	XREF	WarnFlg,CorrFlg,CorSaveA6,CoringFlg,TopStack
	XREF	LstSymFlg
	XREF	MacStuff,RetNor,RetMac
	XREF	EvalErrP
	XREF	FstModPtr,GloTbl,GloNb,EqusPtr,OptiNb
	XREF	IEnvPtr

	include	"comequ.s"

TAB_VALUE	EQU	8
_MSGWARN	equ	0
_MSGOPTI	equ	1
_MSGEVAL	equ	2
_MSGCORR	equ	3
_MSGFATL	equ	4
	section	TEXT

;  #[ OutMsg:
OutMsg:	move.w	MSG_flags(a0),d0
	btst	#_MSGCORR,d0
	seq	nocorflg
	btst	#_MSGWARN,d0
	bne.s	pwarn
	btst	#_MSGOPTI,d0
	bne.s	pwarn
	btst	#_MSGEVAL,d0
	bne	peval
	btst	#_MSGFATL,d0
	bne.s	pfatal
	bra.s	perror
;  #] OutMsg:
;  #[ pwarn:
pwarn:	tst.w	WarnFlg
	bne.s	dowarn
	clr.b	UsrTxt		;ensure clean user message
endwarn:	addq.l	#1,TotWarn
	rts
dowarn:	movem.l	d1-a4/a6,-(sp)
	move.l	a0,a4		;error struct

	lea	-256(sp),sp
	move.l	sp,a6

	IFNE	BLINDOS
	cmp.w	#MAX_WARNNO,MSG_no(a4)
	ble.s	.ok
	clr.w	MSG_no(a4)
.ok:
	ENDC	;BLINDOS
	move.w	MSG_no(a4),LstWarn

	lea	warntbl,a0
	bsr	setmsg
	lea	warn_txt,a0
	bsr	bldmsg
	bsr	PrintMsg
	bsr	PrintFrom
	lea	256(sp),sp
	movem.l	(sp)+,d1-a4/a6
	bra.s	endwarn
;  #] pwarn:
;  #[ pfatal:
pfatal:	bsr.s	perror
	jmp	FatalError
;  #] pfatal:
;  #[ perror:
perror:	movem.l	d1-a4/a6,-(sp)
	move.l	a0,a4		;error struct

	lea	-256(sp),sp
	move.l	sp,a6

	IFNE	BLINDOS
	cmp.w	#MAX_ERRNO,MSG_no(a4)
	ble.s	.ok
	clr.w	MSG_no(a4)
.ok:
	ENDC	;BLINDOS
	move.w	MSG_no(a4),LstErr

	lea	MsgTbl,a0
	bsr.s	setmsg
	lea	error_txt,a0
	bsr	bldmsg
	tst.w	CorrFlg
	beq.s	.nocor
	tst.b	nocorflg
	beq.s	.docor
.nocor:	
.pr:	bsr	PrintMsg
	bsr	PrintFrom
	lea	256(sp),sp
	movem.l	(sp)+,d1-a4/a6
	addq.l	#1,TotErr
	rts
.docor:	bra	DoCor

;  #] perror:
;  #[ bldmsg:
setmsg:	move.w	MSG_no(a4),d0
;	IFNE	_68000
	add.w	d0,d0
	add.w	d0,d0
	move.l	0(a0,d0.w),d0
;	ELSEIF
;	move.l	0(a0,d0.w*4),d0
;	ENDC	;_68000
	bne.s	.ok0
	move.l	#error_error_txt,d0
.ok0:	move.l	d0,MSG_msg1(a4)
	move.l	#UsrTxt,MSG_msg2(a4)
	rts

;In:
;a0=mod @
;a1=buf @
bldmodname:
	movem.l	a0-a2,-(sp)
	lea	modnambuf,a1
	move.l	a0,d0
	bne.s	.l1
	lea	SrcCurName,a0
	STRCPY
	bra.s	.end
.l1:	move.l	d0,a2
	move.l	MOD_orgnam(a2),a0
	STRCPY
	move.l	MOD_father(a2),d0
	beq.s	.end
	lea	.nxt_txt(pc),a0
	subq.w	#1,a1
	STRCPY
	subq.w	#1,a1
	bra.s	.l1
.end:	tst.b	modnambuf
	movem.l	(sp)+,a0-a2
	rts
.nxt_txt:	dc.b	" <- ",0
	even

bldmsg:	movem.l	d0-d2,-(sp)
	move.l	a0,a1
	tst.b	UsrTxt
	bne.s	.usr
	move.l	MSG_msg1(a4),-(sp)	;msg text
	move.l	MSG_mod(a4),a0
	bsr	bldmodname
	bne.s	.mod
	move.w	MSG_no(a4),-(sp)	;msgno
	move.l	a1,-(sp)		;msgtype
	move.l	a6,a0
	lea	msgfrst_txt,a1
	bsr	Sprintf
	lea	10(sp),sp
	bra.s	.end

.mod:	move.l	MSG_lnb(a4),-(sp)	;line nb
	pea	modnambuf		;mod name
	move.w	MSG_no(a4),-(sp)	;msgno
	move.l	a1,-(sp)		;msgtype
	move.l	a6,a0
	lea	msgfile_txt,a1
	bsr	Sprintf
	lea	18(sp),sp
.end:	movem.l	(sp)+,d0-d2
	rts

.usr:	pea	UsrTxt		;user text
	move.l	MSG_msg1(a4),-(sp)	;msg text
	move.l	MSG_lnb(a4),-(sp)	;line nb
	move.l	MSG_mod(a4),a0	;mod name
	bsr	bldmodname
	pea	modnambuf
	move.w	MSG_no(a4),-(sp)	;msgno
	move.l	a1,-(sp)		;msgtype
	move.l	a6,a0
	lea	msguser_txt,a1
	bsr	Sprintf
	lea	22(sp),sp
	bra.s	.end
;  #] bldmsg:
;  #[ PrintMsg:
PrintMsg:	tst.b	IEnvFlg
	bne.s	.ienv
	move.l	a6,a0
	tst.l	MSG_ln(a4)
	beq.s	.print
	bsr.s	.print
	move.l	MSG_ln(a4),a0
	lea	errbuf,a1
	bsr	GetLine
	lea	errbuf,a0
.print:	clr.b	UsrTxt
	jmp	PrtLine
.ienv:	move.l	a4,a0
	move.l	IEnvPtr,a1
	move.l	IENV_outmsg(a1),a1
	jsr	(a1)
	clr.b	UsrTxt
	tst.w	d0
	bne.s	.ok
	jmp	NoPrtEnd
.ok:	rts
;  #] PrintMsg:
;  #[ bldeval:
bldeval:	move.w	MSG_ev(a4),d0
	IFNE	_68000
	lea	MsgTbl,a1
	add.w	d0,d0
	add.w	d0,d0
	move.l	0(a1,d0.w),d0
	ELSEIF
	move.l	(MsgTbl,d0.w*4),d0
	ENDC	;_68000
	IFNE	BLINDOS
	beq.s	.rmsg
	ENDC
	move.l	d0,-(sp)		;ea txt
	lea	UsrTxt,a0
	lea	.fmt(pc),a1
	bsr	Sprintf
	addq.w	#4,sp
	rts
	IFNE	BLINDOS
.rmsg:	_Debugger
	ENDC
.fmt:	dc.b	"in %s",0
	even
;  #] bldeval:
;  #[ peval:
;a0=@ token end
;d0=gene errno
;d1=eval errno
;d2=offset
;+EvalErrP
peval:	movem.l	d1-a4/a6,-(sp)
	move.l	a0,a4		;error struct

	add.w	#-eval_errno,MSG_no(a4)
	move.w	MSG_no(a4),LstErr
	bsr	bldeval

	lea	-256(sp),sp
	move.l	sp,a6
	tst.w	CorrFlg
	beq.s	.nocor
	tst.b	nocorflg
	beq.s	.docor
.nocor:	lea	MsgTbl,a0
	bsr	setmsg
	lea	error_txt,a0
	bsr	bldmsg
	bsr	PrintMsg
	bsr.s	PrintFrom
.end:	addq.l	#1,TotErr
	lea	256(sp),sp
	movem.l	(sp)+,d1-a4/a6
	rts

.docor:	lea	MsgTbl,a0
	bsr	setmsg
	lea	error_txt,a0
	bsr	bldmsg
	bsr	AskMsg		;affichage en trap 13 (ecran)
;	jsr	StopTime		;stop timer
	lea	errbuf,a0
	bsr	AskLine
	movem.l	(sp)+,d0-d2
	bne.s	.changed
	lea	MsgTbl,a0
	bsr	setmsg
	lea	error_txt,a0
	bsr	bldmsg
	bsr	PrintMsg
	addq.l	#1,TotErr
	bra.s	.end
.changed:	bsr	loopit
;	jsr	StrtTime
	bra.s	.end
;  #] peval:
;  #[ PrintFrom:
PrintFrom:
	movem.l	a4-a5,-(sp)
	lea	MacStuff,a5
	tst.w	MacNestCnt(a5)
	beq.s	.end
	move.l	MacStackPtr(a5),d0
	beq.s	.end
.nxmac:	move.l	d0,a4
	move.l	MACCTXT_lnb(a4),-(sp)
	move.l	MACCTXT_mod(a4),a0
	bsr	bldmodname
;	bne.s	.mod

;	beq.s	.nomod
;	move.l	d0,a1
;	move.l	MOD_orgnam(a1),d0
;	beq.s	.nomod
;	move.l	d0,a1
;	bra.s	.mod
;.nomod:	lea	SrcCurName,a1
;.mod:	move.l	a1,-(sp)

	pea	modnambuf		;mod name
	lea	msgfrom_txt,a1
	move.l	a6,a0
	bsr	Sprintf
	addq.w	#8,sp
	move.l	a6,a0
	jsr	PrtLine
	move.l	MACCTXT_lptr(a4),a0
	move.l	a6,a1
	bsr	GetLine
	move.l	a6,a0
	jsr	PrtLine
	move.l	MACCTXT_prev(a4),d0
	bne.s	.nxmac
.end:	movem.l	(sp)+,a4-a5
	rts
;  #] PrintFrom:
;  #[ VarPError:
;In:
;a0=@ var
;d0=#
IVarPError:
	movem.l	d1-a4/a6,-(sp)
	move.l	a0,a3

	lea	-256(sp),sp		;ascii buffer
	move.l	sp,a4

	move.w	VAR_len(a3),-(sp)		;*
	move.l	sp,d2

	move.l	d0,-(sp)			;mdef #
	move.l	VAR_start(a3),-(sp)		;var name @

	move.l	d2,d1
	move.l	a4,a0
	lea	varmdef_txt,a1
	bsr	Sprintf
	lea	10(sp),sp
	move.l	a4,a0
	jsr	PrtLine
	lea	256(sp),sp
	movem.l	(sp)+,d1-a4/a6

;In:
;a0=@ var
VarPError:
	movem.l	d1-d7/a1-a4/a6,-(sp)
	move.l	a0,a3
	move.l	a3,a0
	bsr.s	gettypename
	lea	UsrTxt,a1
	STRCPY

	lea	-MSG_SIZEOF(sp),sp
	clr.w	MSG_flags(sp)
	move.w	#-mdefany_errno,MSG_no(sp)
	clr.w	MSG_len(sp)		;no offset
	move.w	VAR_mod(a3),d0		;mod #
	bsr.s	getmodptr
	move.l	a0,MSG_mod(sp)		;mod @
	move.l	VAR_lnb(a3),MSG_lnb(sp)	;line #
	clr.l	MSG_ln(sp)		;line @
	move.l	sp,a0
	bsr	OutMsg
	lea	MSG_SIZEOF(sp),sp
	movem.l	(sp)+,d1-d7/a1-a4/a6
	rts

;In:
;d0=module #
;Out:
;a0=module @
getmodptr:
	move.l	FstModPtr,a0
	subq.w	#2,d0
	bmi.s	.this
.l1:	move.l	MOD_next(a0),a0
	dbf	d0,.l1
.this:	rts

;In:
;a0 = var struct
;Out:
;d0 = var type
;a0 = type name
gettypename:
	move.b	VAR_type(a0),d0
	andi.w	#%1111,d0
	IFNE	_68000
	move.w	d0,d1
	add.w	d1,d1
	add.w	d1,d1
	move.l	.t(pc,d1.w),a0
	ELSEIF
	move.l	.t(pc,d0.w*4),a0
	ENDC
	rts
.t:	dc.l	equ_txt,set_txt,equr_txt,reg_txt
	dc.l	glo_txt,xref_txt,xdef_txt,loc_txt
	dc.l	fequ_txt,fset_txt,fequr_txt,freg_txt
	dc.l	macro_txt
;  #] VarPError:
;  #[ PSymTab:
;In:
;a0 = var struct
;Out:
;a0 = sec text
getsecname:
	moveq	#0,d0
	move.b	VAR_sec(a0),d0
	bmi.s	.off
	move.l	.tab(pc,d0.w),a0
	rts
.off:	lea	offset_txt,a0
	rts
.tab:	dc.l	text_txt,data_txt,bss_txt,org_txt

psym:	move.w	VAR_len(a2),-(sp)	;*
	move.l	sp,d2

	move.l	a2,a0		;sec name
	bsr	getsecname
	move.l	a0,-(sp)

	move.l	a2,a0
	bsr	gettypename	;type name
	move.l	a0,-(sp)

	move.l	VAR_value(a2),-(sp)	;value
	move.l	VAR_start(a2),-(sp)	;name

	move.l	d2,d1
	move.l	a4,a0
	lea	.fmt(pc),a1
	bsr	Sprintf
	lea	18(sp),sp

	move.l	a4,a0
	jmp	PrtLine
.fmt:	dc.b	"%*s	$%=lx	%s	%s",13,10,0
	even

PSymTab:	tst.b	LstSymFlg
	bne.s	.dolst
	rts
.dolst:	movem.l	d3-d7/a2-a4/a6,-(sp)
	lea	-256(sp),sp
	move.l	sp,a4

	move.l	GloTbl,a6
	move.l	GloNb,d7
	beq.s	.noglo

.l0:	move.l	(a6)+,a2
	bsr	psym
	subq.l	#1,d7
	bgt.s	.l0

.noglo:	move.l	EqusPtr,d0
	beq.s	.end
.l1:	move.l	d0,a6
	move.w	EQUL_nb(a6),d7
	subq.w	#1,d7
	bmi.s	.nxt
	move.l	EQUL_block(a6),a3

.l2:	move.l	(a3)+,a2
	bsr	psym
	dbf	d7,.l2

.nxt:	move.l	EQUL_next(a6),d0
	bne.s	.l1

.end:	lea	256(sp),sp
	movem.l	(sp)+,d3-d7/a2-a4/a6
	rts
;  #] PSymTab:
;  #[ OutLst:	print a listing line
;In: a0=curline
OutLst:	move.l	a0,a1
	lea	-256(sp),sp
	move.l	sp,a0
	moveq	#13,d1
	moveq	#10,d2
.l1:	move.b	(a1)+,d0
	beq.s	.l2
	move.b	d0,(a0)+
	cmp.b	d2,d0
	beq.s	.l2
	cmp.b	d1,d0
	bne.s	.l1
.l2:	IFNE	ATARI
	move.b	d1,-1(a0)	;cr
	move.b	d2,(a0)+	;lf
	ENDC	;ATARI
	IFNE	AMIGA
	move.b	d2,-1(a0)	;lf
	ENDC	;AMIGA
	clr.b	(a0)
	move.l	sp,a0
	jsr	PrtLine
	lea	256(sp),sp
	rts
;  #] OutLst:

;  #[ DoCor:
DoCor:	bsr	AskMsg		;affichage en trap 13 (ecran)
;	jsr	StopTime		;stop timer
	lea	errbuf,a0
	bsr	AskLine
	bne.s	.changed
	lea	MsgTbl,a0
	bsr	setmsg
	lea	error_txt,a0
	bsr	bldmsg
	bsr	PrintMsg
	addq.l	#1,TotErr
	bra.s	.end
.changed:	move.l	a6,CorSaveA6
	st	CoringFlg
	bsr.s	loopit
.end:	;jsr	StrtTime
	lea	256(sp),sp
	movem.l	(sp)+,d1-a4/a6
	rts

loopit:	move.l	a6,-(sp)
	lea	tmperrbuf,a6
	move.l	TopStack,sp
	tst.w	MacStuff+MacNestCnt
	bne.s	.mac
	jsr	RetNor
	move.l	(sp)+,a6
	rts
.mac:	jsr	RetMac
	move.l	(sp)+,a6
	rts

	jsr	Ligne
	move.w	d6,d3
	bmi.s	.end		;pas d'opcode
	beq.s	.nooper
	move.l	FieldsPtr,FIELDPTR	;@ debut de l'operande
	lea	maflags,EAPTR	;@ modes d'adressage
.nooper:
	move.w	REF_opcode(REFPTR),d4	;opcode
	lea	StartRoutines,a1
	add.w	REF_rout(REFPTR),a1
	jsr	(a1)		;jsr ([REF_rout,REFPTR],StartRoutines)
.end:	rts
;  #] DoCor:
;  #[ AskMsg:
AskMsg:	move.l	a6,a0
	bsr.s	.prtline

	move.l	MSG_ln(a4),a0
	lea	errbuf,a1
	bsr.s	GetLine
	lea	errbuf,a0

.prtline:	movem.l	d0-d2/a0-a2,-(sp)
.loop:	move.b	(a0)+,d0
	beq.s	.end
	bsr.s	.putc
	bra.s	.loop
.end:	movem.l	(sp)+,d0-d2/a0-a2
	rts

.putc:	movem.l	d3/a0,-(sp)
	cmp.b	#9,d0
	bne.s	.noexp
	moveq	#TAB_VALUE,d3
	moveq	#0,d1
	move.l	CursPtr,a0
	move.w	(a0),d1
	divu	d3,d1
	swap	d1
	sub	d1,d3
	subq	#1,d3
.expand:	moveq	#' ',d0
	bsr	PrtNChar
	dbf	d3,.expand
	movem.l	(sp)+,d3/a0
	rts
.noexp:	bsr	PrtNChar
	movem.l	(sp)+,d3/a0
	rts
;  #] AskMsg:
;  #[ GetLine:
;In:
;a0=from
;a1=to
GetLine:	movem.l	d0-d3/a0-a1,-(sp)
	moveq	#10,d1
	moveq	#13,d2
	move.l	a0,d0
	beq.s	.end2
	move.w	#256-2,d3
	move.b	(a0)+,d0
	beq.s	.end2
	bra.s	.nxt
.l1:	move.b	(a0)+,d0		;et stocker
.nxt:	move.b	d0,(a1)+
	beq.s	.end2
	cmp.b	d1,d0
	beq.s	.end
	cmp.b	d2,d0
	dbeq	d3,.l1
.end:	subq.w	#1,a1
.end2:	move.b	d1,(a1)+
	IFNE	ATARI
	move.b	d2,(a1)+
	ENDC
	clr.b	(a1)
	movem.l	(sp)+,d0-d3/a0-a1
	rts
;  #] GetLine:
;  #[ AskLine:
AskLine:	movem.l	d3-d7/a3-a4,-(sp)
	move.l	a0,a3
	moveq	#0,d3
	move.b	MSG_off(a4),d3
	lea	.newline(pc),a0
	bsr	.prtline

	lea	.newline(pc),a0
	bsr	.prtline
	lea	.newline(pc),a0
	bsr	.prtline
	lea	.newline(pc),a0
	bsr	.prtline
	lea	.newline(pc),a0
	bsr	.prtline
	lea	.newline(pc),a0
	bsr	.prtline
	lea	.newline(pc),a0
	bsr	.prtline

	lea	.toup(pc),a0
	bsr	.prtline
	lea	.toup(pc),a0
	bsr	.prtline
	lea	.toup(pc),a0
	bsr	.prtline
	lea	.toup(pc),a0
	bsr	.prtline
	lea	.toup(pc),a0
	bsr	.prtline
	lea	.toup(pc),a0
	bsr	.prtline		;pour eviter de scroller en saisie.

	bsr.s	.init_saisie
	bmi.s	.abort			;ligne >255 chars
	bsr	.saisie
	beq.s	.abort
	bsr	.exit_saisie
	beq.s	.abort
	moveq	#-1,d0
.end:	movem.l	(sp)+,d3-d7/a3-a4
	rts
.abort:	moveq	#0,d0
	bra.s	.end

.init_saisie:
	moveq	#0,d5			;taille de la chaine
	moveq	#0,d6			;offset physique
	moveq	#0,d7			;offset logique
	move.l	a3,a0
	move.l	a3,a4			;pour future comparaison
	lea	tmperrbuf,a3
.size:
	move.b	(a0)+,d0
	beq.s	.found_size
	cmp.b	#13,d0
	beq.s	.found_size
	cmp.b	#10,d0
	beq.s	.found_size
	addq.b	#1,d5
	bcs.s	.size_error
	move.b	d0,(a3)+
	bra.s	.size
.found_size:
	sf	(a3)
	lea	tmperrbuf,a3
	move	d5,d7
	cmp.l	d5,d3
	bhi.s	.pas_offset
	move	d3,d7
.pas_offset:
	bsr	.find_offset
	move	d0,d6
	lea	.cursoff(pc),a0
	bsr	.prtline
	move.l	a3,a0
	bsr	.prtline
	bsr	.home
	move	d6,d3
	moveq	#0,d6
	subq	#1,d3
	bmi.s	.no_offset
.skip:
	bsr	.go_to_right
	addq	#1,d6
	dbf	d3,.skip
.no_offset:
	lea	.curson(pc),a0
	bsr	.prtline
	moveq	#0,d0
	rts
.size_error:
	moveq	#-1,d0
	rts

.exit_saisie:
;
; Effacer tout l'affichage depuis l'affichage de l'erreur
;
	bsr	.home
	moveq	#0,d7
	bsr	.couper

	lea	.toup(pc),a0
	bsr.s	.prtline
	lea	.ctrld(pc),a0
	bsr.s	.prtline
	lea	.toup(pc),a0
	bsr.s	.prtline
	lea	.ctrld(pc),a0
	bsr.s	.prtline
	lea	.toup(pc),a0
	bsr.s	.prtline	;3 ligne d'erreurs affichees
	lea	.ctrld(pc),a0
	bsr.s	.prtline
;
	move.l	a4,a0
	moveq	#0,d4
.org_size:
	move.b	(a0)+,d0
	beq.s	._size
	cmp.b	#13,d0
	beq.s	._size
	cmp.b	#10,d0
	beq.s	._size
	addq.b	#1,d4
	bra.s	.org_size
._size:
	cmp	d4,d5
	bne.s	.changed_line
	subq	#1,d4
.compare:
	cmp.b	(a4)+,(a3)+
	dbne	d4,.compare
	bne.s	.changed_line
.nochge:	moveq	#0,d0
	rts

.changed_line:
	moveq	#-1,d0
	rts

.find_offset:
	moveq	#0,d0
	move	d7,d4
	beq.s	.first
	subq	#1,d4
	moveq	#0,d1
.loop_offset:
	cmp.b	#9,0(a3,d1)
	bne.s	.not_tab
	moveq	#TAB_VALUE,d3
	move.l	d0,d2
	divu	d3,d2
	swap	d2
	sub	d2,d3
	subq	#1,d3
	add	d3,d0
.not_tab:
	addq	#1,d0
	addq	#1,d1
	dbf	d4,.loop_offset
.first:	bra.s	.nochge


.prtline:	movem.l	d0-d2/a0-a2,-(sp)
.lline:	move.b	(a0)+,d0
	beq.s	.endline
	bsr.s	.putchar
	bra.s	.lline
.endline:	movem.l	(sp)+,d0-d2/a0-a2
	rts


.putchar:	movem.l	d3/a0,-(sp)
	cmp.b	#9,d0
	bne.s	.noexp
	moveq	#TAB_VALUE,d3
	moveq	#0,d1
	move.l	CursPtr,a0
	move.w	(a0),d1
	divu	d3,d1
	swap	d1
	sub	d1,d3
	subq	#1,d3
.expand:	moveq	#' ',d0
	bsr	PrtNChar
	dbf	d3,.expand
	movem.l	(sp)+,d3/a0
	rts
.noexp:	bsr	PrtNChar
	movem.l	(sp)+,d3/a0
	rts

.insert_char:
	lea	0(a3,d7),a0
	moveq	#-1,d1
.count0:
	tst.b	(a0)+
	dbeq	d1,.count0
	not	d1
.copy0:
	move.b	-1(a0),(a0)
	subq	#1,a0
	dbf	d1,.copy0
	move.b	d0,(a0)
	rts	

.supress_char:
	lea	0(a3,d7),a0
.delete:
	move.b	1(a0),(a0)+
	bne.s	.delete
	rts	

;D7=position du curseur ds la ligne

.saisie:	move	#7,-(sp)
	trap	#1
	addq	#2,sp
	move.l	d0,-(sp)
	bsr	GetShifts
	and.w	#3,d0
	movem.l	(sp)+,d0
	bne.s	.shift
	move.b	d0,d1
	and	#$ff,d1
	add	d1,d1
	move	.jmp_table(pc,d1),d1
	jmp	.jmp_table(pc,d1)

.shift:	cmp.l	#$480038,d0
	beq.s	.saisie
	cmp.l	#$500032,d0
	beq.s	.saisie
	cmp.l	#$4b0034,d0
	beq	.s_left
	cmp.l	#$4d0036,d0
	beq	.s_right
	move.b	d0,d1
	and	#$ff,d1
	add	d1,d1
	move	.jmp_table(pc,d1),d1
	jmp	.jmp_table(pc,d1)

;  #[ Jump table:
.jmp_table:
	dc.w	.special-.jmp_table,.saisie-.jmp_table,.saisie-.jmp_table,.end-.jmp_table,.cut-.jmp_table,.saisie-.jmp_table,.saisie-.jmp_table,.saisie-.jmp_table
	dc.w	.backspace-.jmp_table,.char-.jmp_table,.saisie-.jmp_table,.saisie-.jmp_table,.saisie-.jmp_table,.cr-.jmp_table,.saisie-.jmp_table,.saisie-.jmp_table
	dc.w	.saisie-.jmp_table,.saisie-.jmp_table,.saisie-.jmp_table,.saisie-.jmp_table,.inverse-.jmp_table,.saisie-.jmp_table,.saisie-.jmp_table,.saisie-.jmp_table
	dc.w	.saisie-.jmp_table,.saisie-.jmp_table,.saisie-.jmp_table,.escape-.jmp_table,.saisie-.jmp_table,.saisie-.jmp_table,.saisie-.jmp_table,.saisie-.jmp_table
	dc.w	.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table
	dc.w	.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table
	dc.w	.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table
	dc.w	.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table
	dc.w	.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table
	dc.w	.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table
	dc.w	.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table
	dc.w	.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table
	dc.w	.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table
	dc.w	.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table
	dc.w	.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table
	dc.w	.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.del-.jmp_table
	dc.w	.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table
	dc.w	.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table
	dc.w	.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table
	dc.w	.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table
	dc.w	.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table
	dc.w	.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table
	dc.w	.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table
	dc.w	.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table
	dc.w	.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table
	dc.w	.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table
	dc.w	.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table
	dc.w	.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table
	dc.w	.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table
	dc.w	.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table
	dc.w	.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table
	dc.w	.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table,.char-.jmp_table
;  #] Jump table:

.cr:	cmp.l	#$72000d,d0
	beq.s	.enter
	bsr	.couper
	lea	0(a3,d7),a0
	moveq	#-1,d0
.find_size3:
	tst.b	(a0)+
	dbeq	d0,.find_size3
	add	d0,d5
	addq	#1,d5
	sf	0(a3,d7)
.enter:	moveq	#-1,d0
	rts
.escape:	moveq	#0,d0
	rts

.backspace:
	tst.b	d5
	beq	.saisie
	tst	d7
	beq	.saisie
	lea	.cursoff(pc),a0
	bsr	.prtline
	bsr	.one_to_left
	bsr	.couper
	bsr	.supress_char
	lea	.savecur(pc),a0
	bsr	.prtline
	subq	#1,d5
	lea	0(a3,d7),a0
	bsr	.prtline
	lea	.restcur(pc),a0
	bsr	.prtline
	lea	.curson(pc),a0
	bsr	.prtline
	bra	.saisie


.del:	tst.b	d5
	beq	.saisie
	tst.b	0(a3,d7)
	beq	.saisie
	lea	.cursoff(pc),a0
	bsr	.prtline
	bsr	.couper
	bsr	.supress_char
	lea	.savecur(pc),a0
	bsr	.prtline
	subq	#1,d5
	lea	0(a3,d7),a0
	bsr	.prtline
	lea	.restcur(pc),a0
	bsr	.prtline
	lea	.curson(pc),a0
	bsr	.prtline
	bra	.saisie

.special:
;d0.b=0 => touche de fonction
	swap	d0
	cmp.b	#$4b,d0
	beq.s	.left
	cmp.b	#$4d,d0
	bne	.saisie
.right:	bsr	.one_to_right
	bra	.saisie

.left:	bsr	.one_to_left
	bra	.saisie

.char:	cmp	#$ff,d5
	beq	.saisie
	addq	#1,d5
	move	d0,d2
	bsr	.insert_char
	lea	.savecur(pc),a0
	bsr	.prtline
	lea	.cursoff(pc),a0
	bsr	.prtline
	lea	.ctrld(pc),a0
	bsr	.prtline
	lea	0(a3,d7),a0
	bsr	.prtline
	lea	.restcur(pc),a0
	bsr	.prtline
	bsr	.one_to_right
	lea	.curson(pc),a0
	bsr	.prtline
	bra	.saisie

.go_to_right:
	move.w	CursW,d0
	addq	#1,d0
	move.l	d6,d1
	beq.s	.zero
	addq	#1,d1
	divu	d0,d1
	swap	d1
	tst	d1
	beq.s	.stop
.zero:	lea	.toright(pc),a0
	bsr	.prtline
	rts
.stop:	lea	.newline(pc),a0
	bsr	.prtline
	lea	.toright(pc),a0
	rts

.home:	move.w	CursW,d0
	addq	#1,d0
	move.l	d6,d1
	divu	d0,d1
	tst	d1
	beq.s	.one_line
	subq	#1,d1
.next_line:
	lea	.toup(pc),a0
	bsr	.prtline
	dbf	d1,.next_line
.one_line:
	moveq	#13,d0
	bsr	.putchar
	rts

.s_left:	lea	.cursoff(pc),a0
	bsr	.prtline
	bsr	.home
	lea	.curson(pc),a0
	bsr	.prtline
	moveq	#0,d7
	moveq	#0,d6
	bra	.saisie

.s_right:	lea	.cursoff(pc),a0
	bsr	.prtline
.sright_loop
	tst.b	0(a3,d7)
	beq.s	.theend
	bsr	.one_to_right
	bra.s	.sright_loop
.theend:	lea	.curson(pc),a0
	bsr	.prtline
	bra	.saisie

.cut:	bsr.s	.couper
	lea	0(a3,d7),a0
	moveq	#-1,d0
.find_size2:
	tst.b	(a0)+
	dbeq	d0,.find_size2
	add	d0,d5
	addq	#1,d5
	sf	0(a3,d7)
	bra	.saisie

.couper:	movem.l	d6-d7,-(sp)
	move	d5,d7
	bsr	.find_offset
	move.l	d0,d4
	movem.l	(sp)+,d6-d7
	lea	.cursoff(pc),a0
	bsr	.prtline
	lea	.ctrld(pc),a0
	bsr	.prtline
	move.w	CursW,d0
	addq	#1,d0
	move.l	d4,d1
	divu	d0,d1
	tst	d1
	beq.s	.one_line2
	subq	#1,d1
	lea	.savecur(pc),a0
	bsr	.prtline
.next_line2:
	lea	.newline(pc),a0
	bsr	.prtline
	lea	.ctrld(pc),a0
	bsr	.prtline
	dbf	d1,.next_line2
	lea	.restcur(pc),a0
	bsr	.prtline
.one_line2:
	lea	.curson(pc),a0
	bsr	.prtline
	rts

.one_to_left:
	tst	d7
	beq.s	.debut
	subq	#1,d7
	bsr	.find_offset
	move	d0,d3
	lea	.cursoff(pc),a0
	bsr	.prtline
	bsr	.home
	moveq	#0,d6
	subq	#1,d3
	bmi.s	.nomore
.skip1:	bsr	.go_to_right
	addq	#1,d6
	dbf	d3,.skip1
.nomore:	lea	.curson(pc),a0
	bsr	.prtline
.debut:	rts

.one_to_right:
	tst.b	0(a3,d7)
	beq.s	.fin
	addq	#1,d7
	bsr	.find_offset
	move	d0,d3
	lea	.cursoff(pc),a0
	bsr	.prtline
	bsr	.home
	moveq	#0,d6
.skip3:	bsr	.go_to_right
	addq	#1,d6
	subq.w	#1,d3
	bgt.s	.skip3
.on:	lea	.curson(pc),a0
	bsr	.prtline
.fin:	rts

.inverse:	cmp.b	#32,-1(a3,d7)
	bmi.s	.non
	cmp.b	#32,-2(a3,d7)
	bmi.s	.non
	lea	.cursoff(pc),a0
	bsr	.prtline
	lea	.savecur(pc),a0
	bsr	.prtline
	bsr	.one_to_left
	bsr	.one_to_left
	move.b	0(a3,d7),d0
	move.b	1(a3,d7),0(a3,d7)
	move.b	d0,1(a3,d7)
	lea	0(a3,d7),a0
	bsr	.prtline
	bsr	.one_to_right
	bsr	.one_to_right
	lea	.restcur(pc),a0
	bsr	.prtline
	lea	.curson(pc),a0
	bsr	.prtline
.non:	bra	.saisie

.newline:	dc.b	$1b,'v',$d,$a,0
.toright:	dc.b	$1b,'C',0
.toup:	dc.b	$1b,'A',0
.curson:	dc.b	$1b,'e',0
.cursoff:	dc.b	$1b,'f',0
.ctrld:	dc.b	$1b,'K',0
.savecur:	dc.b	$1b,'j',0
.restcur:	dc.b	$1b,'k',0
;  #] AskLine:

	DATA
ASCIZ	MACRO
	dc.b	\1,0
	ENDM	

;  #[ Messages:
;	 #[ General:
error_txt:	dc.b	"E",0
warn_txt:		dc.b	"W",0
msgfrst_txt:	ASCINLZ	<"%s%03d (%s)">
msgfile_txt:	ASCINLZ	<"%s%03d File %s Line %=ld (%s)">
msguser_txt:	ASCINLZ	<"%s%03d File %s Line %=ld (%s: %s)">
msgfrom_txt:	ASCINLZ	<"FROM macro call File %s Line %=ld">
varmdef_txt:	ASCINLZ	<"Label '%*s' is defined %=ld times in:">
varmdef2_txt:	ASCINLZ	<"File %s Line %=ld (defined as: %s)">
;	 #] General:
;	 #[ Analyse Line:
illchar_lt32_txt:		dc.b	"Illegal character: (<32)",0
illchar_gt127_txt:		dc.b	"Illegal character: (>127)",0
illchar_opcode_txt:		dc.b	"Illegal character: in opcode",0
illchar_label_txt:		dc.b	"Illegal character: in label",0
unbal_quote_txt:		dc.b	"Unbalanced: '""'",0
unbal_parent_txt:		dc.b	"Unbalanced: '(' or ')'",0
unbal_bracket_txt:		dc.b	"Unbalanced: '[' or ']'",0
unexp_eos_txt:		dc.b	"Unexpected end of source",0
;	 #] Analyse Line:
;	 #[ Search opcode:
opnf_txt: 		dc.b	"Opcode not found",0
opsz_forb_txt:		dc.b	"Opcode size forbidden",0
;	 #] Search opcode:
;	 #[ Match operandes:
oper_exp_txt:		dc.b	"Expecting: Operand",0
too_many_oper_txt:		dc.b	"Too many operands",0
startq_exp_txt:		dc.b	"Expecting: Starting "" or '",0
endq_exp_txt:		dc.b	"Expecting: Ending "" or '",0
;	 #] Match operandes:
;	 #[ EA:
size_exp_txt:		dc.b	"Expecting: Size (.W or .L)",0
scale_exp_txt:		dc.b	"Expecting: Scale",0
scale_size_exp_txt:		dc.b	"Expecting: Scale or size",0
cant_input_txt:		dc.b	"Can't understand operand",0
an_exp_txt:		dc.b	"Expecting: An",0
pn_exp_txt:		dc.b	"Expecting: An or PC",0
dn_forb_txt:		dc.b	"Forbidden ea: Dn",0
b_forb_txt:		dc.b	"Forbidden size: Byte",0
opar_exp_txt: 		dc.b	"Expecting: '('",0
cpar_exp_txt: 		dc.b	"Expecting: ')'",0
comma_2many_txt:		dc.b	"Too many commas in parenthesis",0
xn_exp_txt:		dc.b	"Expecting: Xn",0
op_ge_b_txt: 		dc.b	"Operand value is gt than byte",0
op_ge_w_txt: 		dc.b	"Operand value is gt than word",0
d16_ge_w_txt:		dc.b	"D16 is gt than word",0
d8_ge_b_txt: 		dc.b	"D8 is gt than byte",0
scale_forb_txt:		dc.b	"Forbidden ea: Scale",0
too_many_xn_txt:		dc.b	"Too many Xn's",0
dn_or_pre_exp_txt:		dc.b	"Expecting: Dn or -(An)",0
dn_exp_txt:		dc.b	"Expecting: Dn",0
eoo_exp_txt:		dc.b	"Expecting: End of operand",0
minus_exp_txt:		dc.b	"Expecting: '-'",0
size_forb_txt:		dc.b	"Forbidden size",0

an_forb_txt:		dc.b	"Forbidden ea: An",0
anindir_forb_txt:		dc.b	"Forbidden ea: (An)",0
anpost_forb_txt:		dc.b	"Forbidden ea: (An)+",0
anpre_forb_txt:		dc.b	"Forbidden ea: -(An)",0
d16An_forb_txt:		dc.b	"Forbidden ea: d16(An)",0
d8An_forb_txt:		dc.b	"Forbidden ea: d8(An)",0
d16PC_forb_txt:		dc.b	"Forbidden ea: d16(PC)",0
d8PC_forb_txt:		dc.b	"Forbidden ea: d8(PC)",0
full_forb_txt:		dc.b	"Forbidden ea: Memory indirection",0
absw_forb_txt:		dc.b	"Forbidden ea: Abs.w",0
absl_forb_txt:		dc.b	"Forbidden ea: Abs.l",0
immed_forb_txt:		dc.b	"Forbidden ea: #i",0

ea_forb_txt:		dc.b	"Forbidden ea",0
i_exp_txt:		dc.b	"Expecting: '#'",0
q_exp_txt:		dc.b	"Quick value must be >=1 and <=8",0
shift_ge_8_txt:		dc.b	"Shift value must be >=1 and <=8",0
w_exp_txt:		dc.b	"Expecting: Word size instruction with this ea",0
bitge64_txt:		dc.b	"Bit number must be >=0 and <=63",0
bkptge8_txt:		dc.b	"BKPT # must be >=0 and <=7",0
semi_exp_txt:		dc.b	"Expecting: ':'",0
brace_exp_txt:		dc.b	"Expecting: '{' or '}'",0
offset_ge_32_txt:		dc.b	"Bitfield offset must be >=0 and <=31",0
width_ge_32_txt:		dc.b	"Bitfield width must be >=1 and <=32",0
plus_exp_txt:		dc.b	"Expecting: '+'",0
trap_ge_15_txt:		dc.b	"TRAP # must be >=0 and <=15",0
cr_exp_txt:		dc.b	"Expecting: Control register",0
reglist_exp_txt:		dc.b	"Expecting: Register list",0
d16_exp_txt:		dc.b	"Expecting: d16(An)",0
p_exp_txt:		dc.b	"Expecting: Packed ('.p') size",0
x_exp_txt:		dc.b	"Expecting: Extended ('.x') size",0
fp_exp_txt:		dc.b	"Expecting: Fpu register",0
reg_twice_txt:		dc.b	"In register list: Multi-defined register",0
dn_or_sep_exp_txt:		dc.b	"Expecting: Register or separator ('/' or '-')",0
bad_reglist_txt:		dc.b	"Bad register list",0
fpu_dn_size_forb_txt:	dc.b	"Forbidden size with Dn ea",0
fpcr_exp_txt:		dc.b	"Expecting: FPcr (FPCR,FPSR,FPIAR)",0
fpu_fp_size_forb_txt:	dc.b	"Forbidden size with fpn ea",0
kfactor_ge_128_txt:		dc.b	"K-factor must be >=0 and <=128",0
pfc_exp_txt:		dc.b	"Expecting: PMMU function code",0
pfc_ge_7_txt:		dc.b	"PMMU function code must be >=0 and <=7",0
mmusr_forb_txt:		dc.b	"MMUSR forbidden with PMOVEFD",0
cline_exp_txt:		dc.b	"Expecting: Cache line",0
shift_ea_1_txt:		dc.b	"Ea can only be shifted by 1",0
comma_exp_txt:		dc.b	"Expecting: ','",0
quote_exp_txt:		dc.b	'Expecting: "'," or ","'",0
pcb_unreach_txt:		dc.b	"Displacement greater than byte",0
pcw_unreach_txt:		dc.b	"Displacement greater than word",0
zbccb_forb_txt:		dc.b	"Null Bcc.b is forbidden",0
;	 #] EA:
;	 #[ Eval:
badmpu_txt:		dc.b	"This version of ASM will not run on current MPU",0
notimp_txt:		dc.b	"Not yet implemented",0	;internal
error_error_txt:		dc.b	"Illegal error number",0	;internal

eval_bd_txt: 		dc.b	"Bd",0
eval_od_txt: 		dc.b	"Od",0
eval_d16_txt:		dc.b	"D16",0
eval_d8_txt: 		dc.b	"D8",0
eval_immed_txt:		dc.b	"Immediate",0
eval_abs_txt:		dc.b	"Absolute",0
eval_pc_txt:		dc.b	"PC relative",0

eval_rel_req_txt:		dc.b	"Relative required",0
eval_equr_txt:		dc.b	"EQUR not allowed",0
eval_syntax_txt:		dc.b	"Syntax error",0
eval_div0_txt:		dc.b	"Zero divide",0
eval_lstr_txt:		dc.b	"ASCII too long",0
eval_lnb_txt:		dc.b	"Number too big",0
eval_nfvar_txt:		dc.b	"Unknown label",0
eval_operr_txt:		dc.b	"Illegal type combination",0
eval_mem_txt:		dc.b	"Can't record any more expression",0
eval_bopexp_txt:		dc.b	"Expecting binary operator",0
eval_bopunexp_txt:		dc.b	"Forbidden binary operator",0
eval_eoe_txt:		dc.b	"Unexpected end of expression",0
eval_match_txt:		dc.b	"Unexpected open parenthesis",0
eval_parunexp_txt:		dc.b	"Unexpected close parenthesis",0
eval_musteval_txt:		dc.b	"Expression must evaluate",0
eval_fwset_txt:		dc.b	"Forward reference to SET variable",0
eval_overf_txt:		dc.b	"Overflow",0
eval_negsft_txt:		dc.b	"Negative shift value",0
eval_compequr_txt:		dc.b	"Can't compute EQUR",0
eval_errrel_txt:		dc.b	"Forbidden relative expression",0

eval_illradix_txt:		dc.b	"Illegal character for radix",0
eval_type_txt:		dc.b	"Illegal variable type",0
eval_illop_txt:		dc.b	"Illegal operator",0
eval_illcr_txt:		dc.b	"Illegal fpurom operand",0
eval_nffunc_txt:		dc.b	"Unknown function",0
eval_nbargs_txt:		dc.b	"Bad number of operands",0
;	 #] Eval:
;	 #[ Prep:
;	Macros
mac_endm_exp_txt:		dc.b	"No ENDM matching with MACRO",0
mac_endm_unexp_txt:		dc.b	"ENDM outside MACRO",0
mac_exitm_unexp_txt:	dc.b	"EXITM outside MACRO",0
mac_shiftm_unexp_txt:	dc.b	"SHIFTM outside MACRO",0
mac_2many_decl_txt:		dc.b	"Nested MACRO declarations",0
mac_2many_calls_txt:	dc.b	"Too many nested MACRO calls",0
mac_inv_par_txt:		dc.b	"Invalid MACRO parameter",0
mac_enclos_txt:		dc.b	"Incompletely enclosed MACRO parameter",0
mac_sup_unbal_txt:		dc.b	"Expecting: '>' after equate in MACRO",0
mac_eqnf_txt:		dc.b	"Equate not found in MACRO",0
mac_name_txt:		dc.b	"MACRO name matches opcode name",0
;	Rept
rept_endr_exp_txt:		dc.b	"No ENDR matching with REPT",0
rept_endr_unexp_txt:	dc.b	"ENDR outside REPT",0
rept_min_txt:		dc.b	"REPT counter must be >0",0
;Ifcc
ifcc_endif_exp_txt:		dc.b	"No ENDIF matching with IFcc",0
ifcc_else_unexp_txt:	dc.b	"ELSEcc outside IFcc",0
ifcc_endif_unexp_txt:	dc.b	"ENDIF outside IFcc",0
ifcc_garbage_str_txt:	dc.b	"Garbage following string in IFC or IFNC",0
strc_end_unexp_txt:		dc.b	"RSEND outside STRUCT or UNION",0
;	Misc
min_forb_txt:		dc.b	"Argument value must be >=0",0
loc_forb_txt:		dc.b	"Local name forbidden",0
label_exp_txt:		dc.b	"Expecting: Label",0
equr_reg_txt:		dc.b	"EQUR must equate to explicit register",0
fpiar_exp_txt:		dc.b	"Expecting: FPIAR with An",0
fpu_req_txt:		dc.b	"FPU coprocessor required",0
foff_2big_txt:		dc.b	"In INCBIN: size + offset > file size",0
file_exp_txt:		dc.b	"Expecting: Filename",0
load_include_txt:		dc.b	"Couldn't load include file",0
fail_txt:			dc.b	"User error",0
;mmu_req_txt:		dc.b	"Must have indicate MMU",0
var_2many_txt:		dc.b	"Too many globals (>65535) for object output",0
super_forb_txt:		dc.b	"Privileged instruction",0
org_forb_txt:		dc.b	"Org forbidden in BSS or OFFSET section",0
link_misp_txt:		dc.b	"Output type must be set before any code generation/XDEF/XREF",0
link_rest_txt:		dc.b	"Forbidden reference for object output",0
data_in_bss_txt:		dc.b	"Data forbidden in BSS or OFFSET section",0
force_even_txt:		dc.b	"Padding byte inserted for even alignment",0
;	 #] Prep:
;	 #[ Doubly defined:
glo_txt:			ASCIZ	"GLOBAL"
loc_txt:			ASCIZ	"LOCAL"
xref_txt:			ASCIZ	"XREF"
xdef_txt:			ASCIZ	"XDEF"
equ_txt:			ASCIZ	"EQU"
set_txt:			ASCIZ	"SET"
equr_txt:			ASCIZ	"EQUR"
reg_txt:			ASCIZ	"REG"
fequ_txt:			ASCIZ	"FEQU"
fset_txt:			ASCIZ	"FSET"
fequr_txt:		ASCIZ	"FEQUR"
freg_txt:			ASCIZ	"FREG"
macro_txt:		ASCIZ	"MACRO"
text_txt:			ASCIZ	"TEXT"
data_txt:			ASCIZ	"DATA"
bss_txt:			ASCIZ	"BSS"
org_txt:			ASCIZ	"ORG"
offset_txt:		ASCIZ	"OFFSET"
anymdef_txt:		dc.b	"Defined as",0
equmdef_txt:		dc.b	"Redefining: EQU",0
setmdef_txt:		dc.b	"Redefining: SET",0
macmdef_txt:		dc.b	"Redefining: MACRO",0
xdefundef_txt:		dc.b	"XDEFed symbol not found",0

;	 #] Doubly defined:
;	 #[ Disk:
create_txt:		dc.b	"Can't create file",0
open_txt:			dc.b	"Can't open file",0
read_txt:			dc.b	"Can't read file",0
write_txt:		dc.b	"Can't write file",0
seek_txt:			dc.b	"Can't seek in file",0
close_txt:		dc.b	"Can't close file",0
setpath_txt:		dc.b	"Can't set path",0
setdrive_txt:		dc.b	"Can't set drive",0
getpath_txt:		dc.b	"Can't get path",0
getdrive_txt:		dc.b	"Can't get drive",0
;	 #] Disk:
;	 #[ Mem:
varram_txt:		dc.b	"Can't allocate: Label",0
fileram_txt:		dc.b	"Can't allocate: File",0
expram_txt:		dc.b	"Can't allocate: Expression",0
macram_txt:		dc.b	"Can't allocate: MACRO expansion",0
ifccram_txt:		dc.b	"Can't allocate: IFcc",0
reptram_txt:		dc.b	"Can't allocate: REPT",0
memram_txt:		dc.b	"Can't allocate: Memory block",0
modram_txt:		dc.b	"Can't allocate: Module",0
dbgram_txt:		dc.b	"Can't allocate: Debug",0
binram_txt:		dc.b	"Can't allocate: Binary block",0
;	 #] Mem:
;	 #[ MCUs:
mc10_forb_txt:		dc.b	"Forbidden mnemonic: 68010",0
mc20_forb_txt:		dc.b	"Forbidden mnemonic: 68020",0
mc30_forb_txt:		dc.b	"Forbidden mnemonic: 68030",0
mc40_forb_txt:		dc.b	"Forbidden mnemonic: 68040",0
mc60_forb_txt:		dc.b	"Forbidden mnemonic: 68060",0
mc32_forb_txt:		dc.b	"Forbidden mnemonic: CPU32",0
mmu_forb_txt:		dc.b	"Forbidden mnemonic: MMU",0
fpu_forb_txt:		dc.b	"Forbidden mnemonic: FPU",0
ea20_forb_txt:		dc.b	"Forbidden ea: 68020",0
mccr_forb_txt:		dc.b	"Forbidden control register",0
;	 #] MCUs:
;	 #[ Amiga:
sec_name_txt:		dc.b	"Invalid section name",0
sec_start_forb_txt:		dc.b	"Executable starting with a BSS or empty section",0
sec_2many_txt:		dc.b	"Too many sections (127 allowed)",0
sec_difftypes_txt:		dc.b	"Redeclaration of section type",0
rel_oos_txt:		dc.b	"PC relative out of section",0
;	 #] Amiga:
;	 #[ Warnings:
;Optis:
zd162indir_txt:		dc.b	"0(An) turned to (An)",0
labs2w_txt:		dc.b	"Abs.l turned to Abs.w",0
bd2d8_txt:		dc.b	"Bd turned to d8",0
bd2w_txt:			dc.b	"Bd turned to Bd.w",0
bd2z_txt:			dc.b	"Bd suppressed",0
od2w_txt:			dc.b	"Od turned to Od.w",0
od2z_txt:			dc.b	"Od suppressed",0
ld162lbd_txt:		dc.b	"Long d16 turned to Bd.l",0

zbcc2nop_txt:		dc.b	"Null Bcc.B turned to NOP",0
bwbcc2b_txt:		dc.b	"Backward Bcc turned to byte",0
bwbcc2l_txt:		dc.b	"Backward Bcc turned to long",0
fwbcc2b_txt:		dc.b	"Forward Bcc could be byte",0
fwbcc2w_txt:		dc.b	"Forward Bcc could be word",0

move2q_txt:		dc.b	"MOVE.L #i,Dn turned to MOVEQ",0
move2clr_txt:		dc.b	"MOVE.W #0,Dn turned to CLR Dn",0
moveal2w_txt:		dc.b	"MOVEA.L #i turned to MOVEA.W",0
movea2sub_txt:		dc.b	"MOVEA #0 turned to SUBA",0
ari2q_txt:		dc.b	"ADD/SUB #i turned to ADDQ/SUBQ",0
add2lea_txt:		dc.b	"ADDA/SUBA #i turned to LEA",0
lea2q_txt:		dc.b	"LEA turned to ADDQ/SUBQ",0
cmp2tst_txt:		dc.b	"CMPI #0 turned to TST",0
lsl2add_txt:		dc.b	"LSL #1,Dn turned to ADD Dn,Dn",0
roxl2addx_txt:		dc.b	"ROXL #1,Dn turned to ADDX Dn,Dn",0

;Warns:
comment_spur_txt:		dc.b	"Implicit comment",0
regempty_txt:		dc.b	"Empty register list",0
oddsp_txt:		dc.b	"Stack pointer will be odd",0
bitmod8_txt:		dc.b	"Bit number will be modulo 8",0
bitmod32_txt:		dc.b	"Bit number will be modulo 32",0
mq_ext_txt:		dc.b	"MOVEQ value will be sign extended (>=-128 && <0)",0
fpu_soft_txt:		dc.b	"Software emulated FPU mnemonic",0
fpusz_soft_txt:		dc.b	"Software emulated FPU size",0
ec_forb_txt:		dc.b	"Unrecommended mnemonic for EC MPU",0
xref_spur_txt:		dc.b	"Spurious XREF",0
xdef_spur_txt:		dc.b	"Spurious XDEF",0
xref_unused_txt:		dc.b	"Unused XREF",0
odd_branch_txt:		dc.b	"Odd branch address",0
odd_addr_txt:		dc.b	"Even access to odd address",0
mpu_decl_txt:		dc.b	"MPU hasn't been declared",0
mmu_decl_txt:		dc.b	"MMU hasn't been declared",0
fpu_decl_txt:		dc.b	"FPU hasn't been declared",0
;	 #] Warnings:
;	 #[ Msg table:
	even
MsgTbl:	dc.l	error_error_txt		;0

	;Analyse de ligne
	dc.l	illchar_lt32_txt		;1
	dc.l	illchar_gt127_txt		;2
	dc.l	illchar_opcode_txt		;3
	dc.l	illchar_label_txt		;4
	dc.l	unbal_quote_txt		;5
	dc.l	unbal_parent_txt		;6
	dc.l	unbal_bracket_txt		;7
	dc.l	unexp_eos_txt		;8
	dc.l	0			;9

	;Recherche de l'opcode
	dc.l	opnf_txt			;10
	dc.l	opsz_forb_txt		;11
	dc.l	0			;12
	dc.l	0			;13
	dc.l	0			;14
	dc.l	oper_exp_txt		;15
	dc.l	too_many_oper_txt		;16
	dc.l	startq_exp_txt		;17
	dc.l	endq_exp_txt		;18
	dc.l	0			;19

	;Assemblage
	dc.l	size_exp_txt		;20
	dc.l	scale_exp_txt		;21
	dc.l	scale_size_exp_txt		;22
	dc.l	cant_input_txt		;23
	dc.l	an_exp_txt		;24
	dc.l	dn_forb_txt		;25
	dc.l	b_forb_txt		;26
	dc.l	opar_exp_txt		;27
	dc.l	comma_2many_txt		;28
	dc.l	xn_exp_txt		;29

	dc.l	op_ge_b_txt		;30
	dc.l	op_ge_w_txt		;31
	dc.l	d16_ge_w_txt 		;32
	dc.l	d8_ge_b_txt		;33
	dc.l	scale_forb_txt		;34
	dc.l	too_many_xn_txt		;35
	dc.l	dn_or_pre_exp_txt		;36
	dc.l	dn_exp_txt		;37
	dc.l	eoo_exp_txt		;38
	dc.l	minus_exp_txt		;39

	dc.l	size_forb_txt		;40
	dc.l	an_forb_txt		;41
	dc.l	anindir_forb_txt		;42
	dc.l	anpost_forb_txt		;43
	dc.l	anpre_forb_txt		;44
	dc.l	d16An_forb_txt		;45
	dc.l	d8An_forb_txt		;46
	dc.l	full_forb_txt		;47
	dc.l	d16PC_forb_txt		;48
	dc.l	d8PC_forb_txt		;49

	dc.l	absw_forb_txt		;50
	dc.l	absl_forb_txt		;51
	dc.l	immed_forb_txt		;52
	dc.l	ea_forb_txt		;53
	dc.l	i_exp_txt			;54
	dc.l	q_exp_txt			;55
	dc.l	shift_ge_8_txt		;56
	dc.l	w_exp_txt			;57
	dc.l	bitge64_txt		;58
	dc.l	bkptge8_txt		;59

	dc.l	semi_exp_txt		;60
	dc.l	brace_exp_txt		;61
	dc.l	offset_ge_32_txt		;62
	dc.l	width_ge_32_txt		;63
	dc.l	plus_exp_txt		;64
	dc.l	trap_ge_15_txt		;65
	dc.l	cr_exp_txt		;66
	dc.l	reglist_exp_txt		;67
	dc.l	d16_exp_txt		;68
	dc.l	x_exp_txt			;69

	dc.l	fp_exp_txt		;70
	dc.l	reg_twice_txt		;71
	dc.l	dn_or_sep_exp_txt		;72
	dc.l	bad_reglist_txt		;73
	dc.l	fpu_dn_size_forb_txt	;74
	dc.l	fpcr_exp_txt		;75
	dc.l	fpu_fp_size_forb_txt	;76
	dc.l	kfactor_ge_128_txt		;77
	dc.l	pfc_exp_txt		;78
	dc.l	pfc_ge_7_txt		;79

	dc.l	mmusr_forb_txt		;80
	dc.l	cline_exp_txt		;81
	dc.l	shift_ea_1_txt		;82
	dc.l	comma_exp_txt		;83
	dc.l	cpar_exp_txt		;84
	dc.l	pn_exp_txt		;85
	dc.l	quote_exp_txt		;86
	dc.l	pcb_unreach_txt		;87
	dc.l	pcw_unreach_txt		;88
	dc.l	zbccb_forb_txt		;89

	;internal
	dc.l	badmpu_txt		;90
	dc.l	notimp_txt		;91
	dc.l	0			;92
	dc.l	eval_d16_txt		;93
	dc.l	eval_d8_txt		;94
	dc.l	eval_abs_txt		;95
	dc.l	eval_immed_txt		;96
	dc.l	eval_pc_txt		;97
	dc.l	eval_bd_txt		;98
	dc.l	eval_od_txt		;99

	;Evaluation
	dc.l	eval_rel_req_txt		;100
	dc.l	eval_equr_txt		;101
	dc.l	eval_syntax_txt		;102
	dc.l	eval_div0_txt		;103
	dc.l	eval_lstr_txt		;104
	dc.l	eval_lnb_txt		;105
	dc.l	eval_errrel_txt		;106
	dc.l	eval_nfvar_txt		;107
	dc.l	eval_operr_txt		;108
	dc.l	eval_mem_txt		;109
	dc.l	eval_bopexp_txt		;110
	dc.l	eval_bopunexp_txt		;111
	dc.l	eval_eoe_txt		;112
	dc.l	eval_match_txt		;113
	dc.l	eval_parunexp_txt		;114
	dc.l	eval_musteval_txt		;115
	dc.l	eval_fwset_txt		;116
	dc.l	eval_overf_txt		;117
	dc.l	eval_negsft_txt		;118
	dc.l	eval_compequr_txt		;119

	dc.l	eval_illradix_txt		;120
	dc.l	eval_type_txt		;121
	dc.l	eval_illop_txt		;122
	dc.l	eval_illcr_txt		;123
	dc.l	eval_nffunc_txt		;124
	dc.l	eval_nbargs_txt		;125
	dc.l	0			;126
	dc.l	0			;127
	dc.l	0			;128
	dc.l	0			;129

	;Prep
	dc.l	mac_endm_exp_txt		;130
	dc.l	mac_endm_unexp_txt		;131
	dc.l	mac_exitm_unexp_txt		;132
	dc.l	mac_shiftm_unexp_txt	;133
	dc.l	mac_2many_decl_txt		;134
	dc.l	mac_2many_calls_txt		;135
	dc.l	mac_inv_par_txt		;136
	dc.l	mac_enclos_txt		;137
	dc.l	mac_sup_unbal_txt		;138
	dc.l	mac_eqnf_txt		;139
	dc.l	mac_name_txt		;140

	dc.l	rept_endr_exp_txt		;141
	dc.l	rept_endr_unexp_txt		;142
	dc.l	rept_min_txt		;143
	dc.l	force_even_txt		;144
	dc.l	ifcc_endif_exp_txt		;145
	dc.l	ifcc_else_unexp_txt		;146
	dc.l	ifcc_endif_unexp_txt	;147
	dc.l	ifcc_garbage_str_txt	;148
	dc.l	strc_end_unexp_txt		;149

	dc.l	min_forb_txt		;150
	dc.l	loc_forb_txt		;151
	dc.l	label_exp_txt		;152
	dc.l	equr_reg_txt		;153
	dc.l	fpiar_exp_txt		;154
	dc.l	fpu_req_txt		;155
	dc.l	p_exp_txt			;156
	dc.l	foff_2big_txt		;157
	dc.l	0			;158
	dc.l	0			;159

	dc.l	file_exp_txt		;160
	dc.l	load_include_txt		;161
	dc.l	fail_txt			;162
	dc.l	var_2many_txt		;163
	dc.l	super_forb_txt		;164
	dc.l	rel_oos_txt		;165 AMIGA
	dc.l	org_forb_txt		;166
	dc.l	link_misp_txt		;167
	dc.l	link_rest_txt		;168
	dc.l	data_in_bss_txt		;169

	;MPUs
	dc.l	mc10_forb_txt		;170
	dc.l	mc20_forb_txt		;171
	dc.l	mc30_forb_txt		;172
	dc.l	mc40_forb_txt		;173
	dc.l	mc60_forb_txt		;174
	dc.l	mc32_forb_txt		;175
	dc.l	mmu_forb_txt		;176
	dc.l	fpu_forb_txt		;177
	dc.l	ea20_forb_txt		;178
	dc.l	mccr_forb_txt		;179

	;MDEFs
	dc.l	anymdef_txt		;180
	dc.l	equmdef_txt		;181
	dc.l	setmdef_txt		;182
	dc.l	macmdef_txt		;183
	dc.l	xdefundef_txt		;184

	;SECTIONS
	dc.l	sec_name_txt		;185
	dc.l	sec_start_forb_txt		;186
	dc.l	sec_2many_txt		;187
	dc.l	sec_difftypes_txt		;188
	dc.l	0			;189

	;File
	dc.l	create_txt		;190
	dc.l	open_txt			;191
	dc.l	read_txt			;192
	dc.l	write_txt			;193
	dc.l	seek_txt			;194
	dc.l	close_txt			;195
	dc.l	setpath_txt		;196
	dc.l	setdrive_txt		;197
	dc.l	getpath_txt		;198
	dc.l	setpath_txt		;199

	;RAM
	dc.l	varram_txt		;200
	dc.l	fileram_txt		;201
	dc.l	expram_txt		;202
	dc.l	macram_txt		;203
	dc.l	ifccram_txt		;204
	dc.l	reptram_txt		;205
	dc.l	memram_txt		;206
	dc.l	modram_txt		;207
	dc.l	dbgram_txt		;208
	dc.l	binram_txt		;209

	ds.b	256*4-(*-MsgTbl)

warntbl:	dc.l	error_error_txt	;0

	dc.l	zd162indir_txt	;1
	dc.l	labs2w_txt	;2
	dc.l	bd2d8_txt		;3
	dc.l	bd2w_txt		;4
	dc.l	bd2z_txt		;5
	dc.l	od2w_txt		;6
	dc.l	od2z_txt		;7
	dc.l	ld162lbd_txt	;8
	dc.l	0		;9

	dc.l	zbcc2nop_txt	;10
	dc.l	bwbcc2b_txt	;11
	dc.l	bwbcc2l_txt	;12
	dc.l	fwbcc2b_txt	;13
	dc.l	fwbcc2w_txt	;14
	dc.l	move2q_txt	;15
	dc.l	move2clr_txt	;16
	dc.l	moveal2w_txt	;17
	dc.l	movea2sub_txt	;18
	dc.l	ari2q_txt		;19
	dc.l	add2lea_txt	;20
	dc.l	lea2q_txt		;21
	dc.l	cmp2tst_txt	;22
	dc.l	lsl2add_txt	;23
	dc.l	roxl2addx_txt	;24
	dc.l	0		;25
	dc.l	0		;26
	dc.l	0		;27
	dc.l	0		;28
	dc.l	0		;29

	dc.l	comment_spur_txt	;30
	dc.l	regempty_txt	;31
	dc.l	oddsp_txt		;32
	dc.l	bitmod8_txt	;33
	dc.l	bitmod32_txt	;34
	dc.l	mq_ext_txt	;35
	dc.l	fpu_soft_txt	;36
	dc.l	fpusz_soft_txt	;37
	dc.l	ec_forb_txt	;38
	dc.l	xref_spur_txt	;39
	dc.l	xdef_spur_txt	;40
	dc.l	xref_unused_txt	;41
	dc.l	odd_branch_txt	;42
	dc.l	odd_addr_txt	;43
	dc.l	mpu_decl_txt	;44
	dc.l	mmu_decl_txt	;45
	dc.l	fpu_decl_txt	;46

;	 #] Msg table:
;  #] Messages:
	BSS
;  #[ BSS:
LstErr:	ds.w	1	;numero de la derniere erreur
LstWarn: 	ds.w	1	;numero du dernier warning
TotErr:	ds.l	1	;nombre d'erreurs total
TotWarn: 	ds.l	1	;nombre de warnings total
CursW:	ds.w	1
CursPtr:	ds.l	1
editbuf:	ds.w	1
errbuf:	ds.b	256
tmpline:	ds.b	256
modnambuf:	ds.b	512
tmperrbuf:	ds.b	256
UsrTxt:	ds.b	256	;Usr text to print
nocorflg:	ds.b	1
;  #] BSS:
	END
