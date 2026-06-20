	XDEF	GetIEnv
	XDEF	CurEditBlock,HeadEditBlock,IEnvFlg,IEnvPtr
	XDEF	IAsmBuf

	XREF	SrcOrgName,SrcCurName,CurModPtr,OutName,OutSetFlg
	XREF	PrefTbl,MsgTbl,SMemFlg

	include	"comequ.s"

GetIEnv:	clr.l	IEnvPtr
	move.l	$24(a0),d0
	beq.s	.end
	move.l	d0,a0
	move.l	8(a0),a0
	addq.w	#6,a0	;bra.b + stksize
	move.l	(a0)+,d0
	cmp.l	#'AEDT',d0
	bne.s	.end
	move.l	(a0)+,d0
	andi.w	#$fff0,d0
	cmp.w	#(VERSION&$fff0),d0
	bne.s	.end
	move.l	(a0),a0
	move.l	a0,IEnvPtr
	st	IEnvFlg
	move.l	IENV_mod(a0),a0
	move.l	a0,CurModPtr
	move.l	MOD_expnam(a0),a0
	lea	SrcOrgName,a1		;nom du premier source
	PSTRCPY
	lea	SrcCurName,a1		;nom du source courant
	STRCPY
	move.w	#-1,SMemFlg		;system malloc
	tst.b	OutName
	sne	OutSetFlg
.end:	move.l	IEnvPtr,d0
	rts

	DATA
IAsmBuf:	dc.l	PrefTbl
	dc.l	MsgTbl

	BSS
HeadEditBlock:	ds.l	1
CurEditBlock:	ds.l	1
IEnvPtr:	ds.l	1
IEnvFlg:	ds.b	1
	END
