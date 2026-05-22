	XREF	BinBuffer,EndBinBuffer,OpSize
	XREF	CurLPtr,CurLNb,CurModPtr,MPUType
	XREF	OptiLAbs2WFlg,OptiZD16Flg,OptiBdFlg,OptiOdFlg,OptiSz,OptiNb
	XREF	WOptLAbs2WFlg,WOptZD16Flg,WOptBdFlg,WOptOdFlg
	XREF	UpdateBinBuffer,Evaluate,WPokeBin,LPokeBin,StoreEXP
	XREF	BinAlloc,GetEqur,GetEqur3,OutMsg

	XDEF	EaSp
	XDEF	BuildEa,GetEa

	include	"comequ.s"

	include	"bldea68k.s"
	include	"getea68k.s"

Errb_gt:	moveq	#sz_ge_b_errno,d0
	bra.s	eaperret
Errw_gt:	moveq	#sz_ge_w_errno,d0
;	bra.s	eaperret
eaperret:	neg.w	d0
	move.l	a0,-(sp)
;	sub.l	FIELDPTR,a0
;	add.l	LINE_srcstart(FIELDPTR),a0
;	sub.l	CurLPtr,a0
;	move.l	a0,d1			;offset
	lea	eamsg,a0
	move.w	#MSG_CORR,MSG_flags(a0)
	move.w	d0,MSG_no(a0)
	clr.w	MSG_len(a0)
;	move.w	d1,MSG_len(a0)
	move.l	CurModPtr,MSG_mod(a0)
	move.l	CurLNb,MSG_lnb(a0)
	move.l	CurLPtr,MSG_ln(a0)
	jsr	OutMsg
	move.l	(sp)+,a0
	rts

Errd8_ge:	moveq	#d8_ge_errno,d0
	bra.s	eaperror
Errd16_ge:	moveq	#d16_ge_errno,d0
	bra.s	eaperror
Erropsz_forb:	moveq	#opsz_forb_errno,d0
	bra.s	eaperror
Errb_forb:	moveq	#b_forb_errno,d0
	bra.s	eaperror
Errdn_forb:	moveq	#dn_forb_errno,d0
	bra.s	eaperror
Erran_forb:	moveq	#an_forb_errno,d0
	bra.s	eaperror
Erranindir_forb:	moveq	#anindir_forb_errno,d0
	bra.s	eaperror
Erranpre_forb:	moveq	#anpre_forb_errno,d0
	bra.s	eaperror
Erranpost_forb:	moveq	#anpost_forb_errno,d0
	bra.s	eaperror
Errd16An_forb:	moveq	#d16An_forb_errno,d0
	bra.s	eaperror
Errd8An_forb:	moveq	#d8An_forb_errno,d0
	bra.s	eaperror
Errimm_forb:	moveq	#imm_forb_errno,d0
	bra.s	eaperror
Errfull_forb:	moveq	#full_forb_errno,d0
	bra.s	eaperror
Errd16PC_forb:	moveq	#d16pc_forb_errno,d0
	bra.s	eaperror
Errd8PC_forb:	moveq	#d8pc_forb_errno,d0
	bra.s	eaperror
Errabsw_forb:	moveq	#absw_forb_errno,d0
	bra.s	eaperror
Errabsl_forb:	moveq	#absl_forb_errno,d0
	bra.s	eaperror
Errea20_forb:	move	#ea20_forb_errno,d0
	bra.s	eaperror
Erropar_exp:
	moveq	#opar_exp_errno,d0
	bra.s	eaperror
Errcpar_exp:
	moveq	#cpar_exp_errno,d0
	bra.s	eaperror
Erran_exp:
	moveq	#an_exp_errno,d0
	bra.s	eaperror
Errpn_exp:
	moveq	#pn_exp_errno,d0
	bra.s	eaperror
Errxn_exp:	moveq	#xn_exp_errno,d0
	bra.s	eaperror
Errxnorsz_exp:	moveq	#sz_exp_errno,d0
	bra.s	eaperror
Errcomma_exp:	moveq	#comma_exp_errno,d0
	bra.s	eaperror
Errea_exp:	moveq	#cant_input_errno,d0
	bra.s	eaperror
Erreoo_exp:	moveq	#eoo_exp_errno,d0
	bra.s	eaperror
Errcant_input:	moveq	#cant_input_errno,d0
	bra.s	eaperror
Errnot_imp:	moveq	#not_imp_errno,d0
	bra.s	eaperror
Errcomma_2many:	moveq	#comma_2many_errno,d0
;	bra.s	eaperror
eaperror:	neg.w	d0
	move.l	a0,-(sp)
;	sub.l	FIELDPTR,a0
;	add.l	LINE_srcstart(FIELDPTR),a0
;	sub.l	CurLPtr,a0
;	move.l	a0,d1			;offset
	lea	eamsg,a0
	move.w	#MSG_CORR,MSG_flags(a0)
	move.w	d0,MSG_no(a0)
	clr.w	MSG_len(a0)
;	move.w	d1,MSG_len(a0)
	move.l	CurModPtr,MSG_mod(a0)
	move.l	CurLNb,MSG_lnb(a0)
	move.l	CurLPtr,MSG_ln(a0)
	jsr	OutMsg
	move.l	(sp)+,a0
	move.l	EaSp,sp
	rts

ErrEv_immed:
	moveq	#eval_immed_errno,d0
	bra.s	EaPEvErr
ErrEv_abs:
	moveq	#eval_abs_errno,d0
	bra.s	EaPEvErr
ErrEv_d16:
	moveq	#eval_d16_errno,d0
	bra.s	EaPEvErr
ErrEv_d8:	moveq	#eval_d8_errno,d0
	bra.s	EaPEvErr
ErrEv_bd:	moveq	#eval_bd_errno,d0
	bra.s	EaPEvErr
ErrEv_od:	moveq	#eval_od_errno,d0
;	bra.s	EaPEvErr
EaPEvErr:	neg.w	d0
	neg.w	d1
	move.l	a0,-(sp)
;	sub.l	FIELDPTR,a0
;	add.l	a0,d2
;	add.l	LINE_srcstart(FIELDPTR),d2
;	sub.l	CurLPtr,d2		;offset
	lea	eamsg,a0
	move.w	#MSG_EVAL|MSG_CORR,MSG_flags(a0)
	move.w	d1,MSG_no(a0)
	move.w	d0,MSG_ev(a0)
	clr.w	MSG_len(a0)
;	move.w	d2,MSG_len(a0)
	move.l	CurModPtr,MSG_mod(a0)
	move.l	CurLNb,MSG_lnb(a0)
	move.l	CurLPtr,MSG_ln(a0)
	jsr	OutMsg
	move.l	(sp)+,a0
	move.l	EaSp,sp
	rts

Opti_zd16:
	moveq	#zd162indir_warnno,d0
	moveq	#2,d1
	move.w	WOptZD16Flg,d2
	bra.s	EaPOpti
Opti_bd2d8:
	moveq	#bd2d8_warnno,d0
	moveq	#6,d1
	move.w	WOptBdFlg,d2
	bra.s	EaPOpti
Opti_bd2w:
	moveq	#bd2w_warnno,d0
	moveq	#2,d1
	move.w	WOptBdFlg,d2
	bra.s	EaPOpti
Opti_bd2z:
	moveq	#bd2z_warnno,d0
	moveq	#4,d1
	move.w	WOptBdFlg,d2
	bra.s	EaPOpti
Opti_od2w:
	moveq	#od2w_warnno,d0
	moveq	#4,d1
	move.w	WOptOdFlg,d2
	bra.s	EaPOpti
Opti_od2z:
	moveq	#od2z_warnno,d0
	moveq	#4,d1
	move.w	WOptOdFlg,d2
	bra.s	EaPOpti
Opti_labs2w:
	moveq	#labs2w_warnno,d0
	moveq	#2,d1
	move.w	WOptLAbs2WFlg,d2
;	bra.s	EaPOpti
EaPOpti:	add.l	d1,OptiSz
	addq.l	#1,OptiNb
	tst.w	d2
	bne.s	.msg
	rts
.msg:	neg.w	d0
	lea	eamsg,a0
	move.w	#MSG_OPTI,MSG_flags(a0)
	move.w	d0,MSG_no(a0)
	clr.w	MSG_len(a0)		;no offset
	move.l	CurLNb,MSG_lnb(a0)
	move.l	CurModPtr,MSG_mod(a0)
	move.l	CurLPtr,MSG_ln(a0)
	jmp	OutMsg

	BSS
EaSp:	ds.l	1
eamsg:	ds.b	MSG_SIZEOF
	END
