	XDEF	Eval1,ForEval1,LocEval1,GloEval1,OptEval1

	XREF	GlobPatchFlag,LocPatchFlag,GetGloVar,GetLocVar
	XREF	ForceGloVar,ForceLocVar
	XREF	LValAlloc,GetREquate,CurSection,SecSize,TextSize
	XREF	DataSize,FindEqu,GetXref

	include	"comequ.s"
;  #[ A faire:
;local en force eval
;recuperer la size des vars ds les exprs en patch
;espace -> erreur
;  #] A faire:
POPEVAL1	MACRO
	ENDM

;macro pour Eval1 et OptiEval1 (meme retour)
;Inside: d2.B=sign
GEN_EVAL1	MACRO
.loop:	moveq	#0,d1
	move.b	(a0)+,d1
	add.w	d1,d1
	move.w	.tab(pc,d1.w),d1
	jmp	.tab(pc,d1.w)
.space:	tst.b	(a0)
	bgt.s	.loop
	bra	errempt1
.parent:	moveq	#')',d0
	move.l	a0,d1
.l1:	cmp.b	(a0)+,d0
	bne.s	.l1
	st	-(a0)			;virer parenthese
	move.l	a2,-(sp)
	move.l	a0,-(sp)
	move.l	d1,a0
	bsr.s	.loop
	move.l	(sp)+,a2
	move.b	#')',(a2)		;remettre parenthese
	move.l	(sp)+,a2		;a2 initial
	add.l	#$20000,d1	;+2 chars
	tst.b	d1
	rts

.minus:	tst.b	(a0)		;TOKENEOL
	bmi.s	.rsyn
	bsr.s	.loop
	bmi.s	.out
	tst.w	d1
	bne.s	.add1
	neg.l	d0
	not.b	d2
	tst.b	d1
	rts
.add1:	add.l	#$10000,d1	;+1 char
	tst.b	d1
.out:	rts
.rsyn:	bra	errsyn1

.tilde:	tst.b	(a0)
	bmi.s	.rsyn
	bsr.s	.loop
	bmi.s	.out
	tst.b	d1
	bne.s	.add1
	not.l	d0
	smi	d2
	tst.b	d1
	rts
	ENDM	;GEN_EVAL1

;  #[ Eval1:
;>a0
;<d0,d1
;Evalue un operande.
;if (!backpatch)
;locale:	<0+LOC
;equ:	<valeur+NOERR
;equr:	<valeur+EQUR
;default: <0+GLOB
;else if (backpatch==GLOBALPATCH)
;locale:	(impossible)
;equ:	<valeur+NOERR (forward equate)
;equr:	<error (forward equr)
;default: check globale, <valeur
Eval1:
	GEN_EVAL1

.tab:	dc.w	errempt1-.tab	;0
	REPT	$19		;1-19
	dc.w	errsyn1-.tab	;1
	ENDR
	dc.w	quote1-.tab	;1a TOKENQUOTE
	dc.w	errsyn1-.tab	;1b
	dc.w	errsyn1-.tab	;1c
	dc.w	errsyn1-.tab	;1d
	dc.w	errsyn1-.tab	;1e
	dc.w	errsyn1-.tab	;1f
	dc.w	.space-.tab	;20 ' '
	dc.w	errsyn1-.tab	;21 !
	dc.w	quote1-.tab	;22 "
	dc.w	errsyn1-.tab	;23 #
	dc.w	hexa1-.tab	;24 $
	dc.w	bin1-.tab 	;25 %
	dc.w	errsyn1-.tab	;26 &
	dc.w	quote1-.tab	;27 '
	dc.w	.parent-.tab	;28 (
	dc.w	errsyn1-.tab	;29 )
	dc.w	star1-.tab	;2a *
	dc.w	.space-.tab	;2b +
	dc.w	errsyn1-.tab	;2c ,
	dc.w	.minus-.tab	;2d -
	dc.w	eval1_loc1-.tab	;2e .
	dc.w	errsyn1-.tab	;2f /
	REPT	10		;0-9
	dc.w	dec1-.tab
	ENDR
	dc.w	errsyn1-.tab	;3a :
	dc.w	errsyn1-.tab	;3b ;
	dc.w	errsyn1-.tab	;3c <
	dc.w	errsyn1-.tab	;3d =
	dc.w	errsyn1-.tab	;3e >
	dc.w	errsyn1-.tab	;3f ?
	dc.w	octal1-.tab	;40 @
	REPT	26	;A-Z
	dc.w	eval1_var1-.tab
	ENDR
	dc.w	errsyn1-.tab	;5b [
	dc.w	dec1-.tab		;5c \
	dc.w	errsyn1-.tab	;5d ]
	dc.w	errsyn1-.tab	;5e ^
	dc.w	eval1_var1-.tab 	;5f _
	dc.w	errsyn1-.tab	;60 `
	REPT	26	;a-z
	dc.w	eval1_var1-.tab
	ENDR
	dc.w	errsyn1-.tab	;7b {
	dc.w	errsyn1-.tab	;7c |
	dc.w	errsyn1-.tab	;7d }
	dc.w	.tilde-.tab	;7e ~
	dc.w	errsyn1-.tab	;7f 
	REPT	$80
	dc.w	errempt1-.tab	;80-ff
	ENDR
;  #] Eval1:
;  #[ ForEval1:
;>a0
;<d0,d1
;Evalue un operande.
;if (!backpatch)
;locale:	<0+LOC
;equ:	<valeur+NOERR
;equr:	<valeur+EQUR
;default: <0+GLOB
;else if (backpatch==GLOBALPATCH)
;locale:	(impossible)
;equ:	<valeur+NOERR (forward equate)
;equr:	<error (forward equr)
;default: check globale, <valeur
ForEval1:
.loop:	moveq	#0,d1
	move.b	(a0)+,d1
	add.w	d1,d1
	move.w	.tab(pc,d1.w),d1
	jmp	.tab(pc,d1.w)
.space:	tst.b	(a0)
	bgt.s	.loop
	bra	errempt1
.parent:	moveq	#')',d0
	move.l	a0,d1
.l1:	cmp.b	(a0)+,d0
	bne.s	.l1
	st	-(a0)			;virer parenthese
	move.l	a2,-(sp)
	move.l	a0,-(sp)
	move.l	d1,a0
	bsr.s	.loop
	move.l	(sp)+,a2
	move.b	#')',(a2)	;remettre parenthese
	move.l	(sp)+,a2	;a2 initial
	tst.b	d1
	rts
.minus:	tst.b	(a0)		;TOKENEOL
	bmi.s	.rsyn
	bsr.s	.loop
	bmi.s	.end
	tst.w	d1
	bne.s	.erroper
	eor.l	#$ff0000,d1	;inv SIGN
	tst.w	d1
.end:	rts
.rsyn:	bra	errsyn1
.tilde:	tst.b	(a0)		;TOKENEOL
	bmi.s	.rsyn
	bsr.s	.loop
	bmi.s	.end
	tst.w	d1
	bne.s	.erroper
	not.l	d0
	smi	d2
	swap	d1
	move.b	d2,d1
	swap	d1
;	and.l	#$00ffff,d1	;clr SIGN
	tst.w	d1
	rts
.erroper:	moveq	#0,d0
	moveq	#EVAL_OPERR,d1
	rts
.errmust:	moveq	#0,d0
	moveq	#EVAL_MUSTEVAL,d1
	rts
.tab:	dc.w	errempt1-.tab	;0
	REPT	$19
	dc.w	errsyn1-.tab	;1-19
	ENDR
	dc.w	quote1-.tab	;1a TOKENQUOTE
	dc.w	errsyn1-.tab	;1b
	dc.w	errsyn1-.tab	;1c
	dc.w	errsyn1-.tab	;1d
	dc.w	errsyn1-.tab	;1e
	dc.w	errsyn1-.tab	;1f
	dc.w	.space-.tab	;20 ' '
	dc.w	errsyn1-.tab	;21 !
	dc.w	quote1-.tab	;22 "
	dc.w	errsyn1-.tab	;23 #
	dc.w	hexa1-.tab	;24 $
	dc.w	bin1-.tab 	;25 %
	dc.w	errsyn1-.tab	;26 &
	dc.w	quote1-.tab	;27 '
	dc.w	.parent-.tab	;28 (
	dc.w	errsyn1-.tab	;29 )
	dc.w	for_star1-.tab	;2a *
	dc.w	.space-.tab	;2b +
	dc.w	errsyn1-.tab	;2c ,
	dc.w	.minus-.tab	;2d -
	dc.w	for_loc1-.tab	;2e .
	dc.w	errsyn1-.tab	;2f /
	REPT	10		;0-9
	dc.w	dec1-.tab
	ENDR
	dc.w	errsyn1-.tab	;3a :
	dc.w	errsyn1-.tab	;3b ;
	dc.w	errsyn1-.tab	;3c <
	dc.w	errsyn1-.tab	;3d =
	dc.w	errsyn1-.tab	;3e >
	dc.w	errsyn1-.tab	;3f ?
	dc.w	octal1-.tab	;40 @
	REPT	26		;A-Z
	dc.w	for_var1-.tab
	ENDR
	dc.w	errsyn1-.tab	;5b [
	dc.w	dec1-.tab		;5c \
	dc.w	errsyn1-.tab	;5d ]
	dc.w	errsyn1-.tab	;5e ^
	dc.w	for_var1-.tab	;5f _
	dc.w	errsyn1-.tab	;60 `
	REPT	26		;a-z
	dc.w	for_var1-.tab
	ENDR
	dc.w	errsyn1-.tab	;7b {
	dc.w	errsyn1-.tab	;7c |
	dc.w	errsyn1-.tab	;7d }
	dc.w	.tilde-.tab	;7e ~
	dc.w	errsyn1-.tab	;7f 
	REPT	$80
	dc.w	errempt1-.tab	;80-ff
	ENDR
;  #] ForEval1:
;  #[ OptiEval1:
OptEval1:
	GEN_EVAL1

.tab:	dc.w	errempt1-.tab	;0
	REPT	$19		;1-19
	dc.w	errsyn1-.tab	;1
	ENDR
	dc.w	quote1-.tab	;1a TOKENQUOTE
	dc.w	errsyn1-.tab	;1b
	dc.w	errsyn1-.tab	;1c
	dc.w	errsyn1-.tab	;1d
	dc.w	errsyn1-.tab	;1e
	dc.w	errsyn1-.tab	;1f
	dc.w	.space-.tab	;20 ' '
	dc.w	errsyn1-.tab	;21 !
	dc.w	quote1-.tab	;22 "
	dc.w	errsyn1-.tab	;23 #
	dc.w	hexa1-.tab	;24 $
	dc.w	bin1-.tab 	;25 %
	dc.w	errsyn1-.tab	;26 &
	dc.w	quote1-.tab	;27 '
	dc.w	.parent-.tab	;28 (
	dc.w	errsyn1-.tab	;29 )
	dc.w	if_star1-.tab	;2a *
	dc.w	.space-.tab	;2b +
	dc.w	errsyn1-.tab	;2c ,
	dc.w	.minus-.tab	;2d -
	dc.w	if_loc1-.tab	;2e .
	dc.w	errsyn1-.tab	;2f /
	REPT	10		;0-9
	dc.w	if_dec1-.tab
	ENDR
	dc.w	errsyn1-.tab	;3a :
	dc.w	errsyn1-.tab	;3b ;
	dc.w	errsyn1-.tab	;3c <
	dc.w	errsyn1-.tab	;3d =
	dc.w	errsyn1-.tab	;3e >
	dc.w	errsyn1-.tab	;3f ?
	dc.w	octal1-.tab	;40 @
	REPT	26	;A-Z
	dc.w	if_var1-.tab
	ENDR
	dc.w	errsyn1-.tab	;5b [
	dc.w	dec1-.tab		;5c \
	dc.w	errsyn1-.tab	;5d ]
	dc.w	errsyn1-.tab	;5e ^
	dc.w	if_var1-.tab 	;5f _
	dc.w	errsyn1-.tab	;60 `
	REPT	26	;a-z
	dc.w	if_var1-.tab
	ENDR
	dc.w	errsyn1-.tab	;7b {
	dc.w	errsyn1-.tab	;7c |
	dc.w	errsyn1-.tab	;7d }
	dc.w	.tilde-.tab	;7e ~
	dc.w	errsyn1-.tab	;7f 
	REPT	$80
	dc.w	errempt1-.tab	;80-ff
	ENDR
;  #] OptiEval1:
;  #[ LocEval1:
;>a0
;<d0,d1
;Evalue un operande.
;if (!backpatch)
;locale:	<0+LOC
;equ:	<valeur+NOERR
;equr:	<valeur+EQUR
;default: <0+GLOB
;else if (backpatch==GLOBALPATCH)
;locale:	(impossible)
;equ:	<valeur+NOERR (forward equate)
;equr:	<error (forward equr)
;default: check globale, <valeur
LocEval1:
.loop:	moveq	#0,d1
	move.b	(a0)+,d1
	add.w	d1,d1
	move.w	.tab(pc,d1.w),d1
	jmp	.tab(pc,d1.w)
.space:	tst.b	(a0)
	bgt.s	.loop
	bra	errempt1
.parent:	moveq	#')',d0
	move.l	a0,d1
.l1:	cmp.b	(a0)+,d0
	bne.s	.l1
	st	-(a0)			;virer parenthese
	move.l	a2,-(sp)
	move.l	a0,-(sp)
	move.l	d1,a0
	bsr.s	.loop
	move.l	(sp)+,a2
	move.b	#')',(a2)	;remettre parenthese
	move.l	(sp)+,a2	;a2 initial
	tst.b	d1
	rts
.minus:	tst.b	(a0)
	bmi.s	.rsyn
	bsr.s	.loop
	bmi.s	.end
	tst.w	d1
	bne.s	.erroper
	neg.l	d0
	bchg	#16,d1
	tst.w	d1
.end:	rts
.rsyn:	bra	errsyn1
.tilde:	tst.b	(a0)
	bmi.s	.rsyn
	bsr.s	.loop
	bmi.s	.end
	tst.w	d1
	bne.s	.erroper
	not.l	d0
	bpl.s	.plus
	bset	#16,d1
	tst.w	d1
	rts
.plus:	bclr	#16,d1
	tst.w	d1
	rts
.erroper: moveq	#0,d0
	moveq	#EVAL_OPERR,d1
	rts
.tab:	dc.w	errempt1-.tab	;0
	REPT	$19		;1-19
	dc.w	errsyn1-.tab
	ENDR
	dc.w	quote1-.tab	;1a  TOKENQUOTE
	dc.w	errsyn1-.tab	;1b
	dc.w	errsyn1-.tab	;1c
	dc.w	errsyn1-.tab	;1d
	dc.w	errsyn1-.tab	;1e
	dc.w	errsyn1-.tab	;1f
	dc.w	.space-.tab	;20 ' '
	dc.w	errsyn1-.tab	;21 !
	dc.w	quote1-.tab	;22 "
	dc.w	errsyn1-.tab	;23 #
	dc.w	hexa1-.tab	;24 $
	dc.w	bin1-.tab		;25 %
	dc.w	errsyn1-.tab	;26 &
	dc.w	quote1-.tab	;27 '
	dc.w	.parent-.tab	;28 (
	dc.w	errsyn1-.tab	;29 )
	dc.w	cannot-.tab	;2a *
	dc.w	.space-.tab	;2b +
	dc.w	errsyn1-.tab	;2c ,
	dc.w	.minus-.tab	;2d -
	dc.w	loc_loc1-.tab	;2e .
	dc.w	errsyn1-.tab	;2f /
	REPT	10		;0-9
	dc.w	loc_dec1-.tab
	ENDR
	dc.w	errsyn1-.tab	;3a :
	dc.w	errsyn1-.tab	;3b ;
	dc.w	errsyn1-.tab	;3c <
	dc.w	errsyn1-.tab	;3d =
	dc.w	errsyn1-.tab	;3e >
	dc.w	errsyn1-.tab	;3f ?
	dc.w	octal1-.tab	;40 @
	REPT	26		;A-Z
	dc.w	cannot-.tab
	ENDR
	dc.w	errsyn1-.tab	;5b [
	dc.w	dec1-.tab		;5c \
	dc.w	errsyn1-.tab	;5d ]
	dc.w	errsyn1-.tab	;5e ^
	dc.w	cannot-.tab	;5f _
	dc.w	errsyn1-.tab	;60 `
	REPT	26		;a-z
	dc.w	cannot-.tab
	ENDR
	dc.w	errsyn1-.tab	;7b {
	dc.w	errsyn1-.tab	;7c |
	dc.w	errsyn1-.tab	;7d }
	dc.w	.tilde-.tab	;7e ~
	dc.w	errsyn1-.tab	;7f 
	REPT	$80
	dc.w	errempt1-.tab	;80-ff
	ENDR
;  #] LocEval1:
;  #[ GloEval1:
;>a0,a3=@struct EXP
;<d0,d1,d2
;Evalue un operande.
;if (!backpatch)
;locale:	<0+LOC
;equ:	<valeur+NOERR
;equr:	<valeur+EQUR
;default: <0+GLOB
;else if (backpatch==GLOBALPATCH)
;locale:	(impossible)
;equ:	<valeur+NOERR (forward equate)
;equr:	<error (forward equr)
;default: check globale, <valeur
GloEval1:
.loop:	moveq	#0,d1
	move.b	(a0)+,d1
	add.w	d1,d1
	move.w	.tab(pc,d1.w),d1
	jmp	.tab(pc,d1.w)
.space:	tst.b	(a0)
	bgt.s	.loop
	bra	errempt1
.parent:	moveq	#')',d0
	move.l	a0,d1
.l1:	cmp.b	(a0)+,d0
	bne.s	.l1
	st	-(a0)			;virer parenthese
	move.l	a2,-(sp)
	move.l	a0,-(sp)
	move.l	d1,a0
	bsr.s	.loop
	move.l	(sp)+,a2
	move.b	#')',(a2)	;remettre parenthese
	move.l	(sp)+,a2	;a2 initial
	tst.b	d1
	rts

.minus:	tst.b	(a0)
	bmi.s	.rsyn
	bsr.s	.loop
	bmi.s	.end
	tst.w	d1
	bne.s	.roper
	neg.l	d0
	not.b	d2
	tst.w	d1
.end:	rts
.rsyn:	bra	errsyn1
.tilde:	tst.b	(a0)
	bmi.s	.rsyn
	bsr.s	.loop
	bmi.s	.end
	tst.w	d1
	bne.s	.roper
	not.l	d0
	smi	d2
	tst.w	d1
	rts

.roper:	moveq	#0,d0
	moveq	#EVAL_OPERR,d1
	rts
.tab:	dc.w	errempt1-.tab	;0
	REPT	$19		;1-19
	dc.w	errsyn1-.tab
	ENDR
	dc.w	quote1-.tab	;1a TOKENQUOTE
	dc.w	errsyn1-.tab	;1b
	dc.w	errsyn1-.tab	;1c
	dc.w	errsyn1-.tab	;1d
	dc.w	errsyn1-.tab	;1e
	dc.w	errsyn1-.tab	;1f
	dc.w	.space-.tab	;20 ' '
	dc.w	errsyn1-.tab	;21 !
	dc.w	quote1-.tab	;22 "
	dc.w	errsyn1-.tab	;23 #
	dc.w	hexa1-.tab	;24 $
	dc.w	bin1-.tab 	;25 %
	dc.w	errsyn1-.tab	;26 &
	dc.w	quote1-.tab	;27 '
	dc.w	.parent-.tab	;28 (
	dc.w	errsyn1-.tab	;29 )
	dc.w	glo_star1-.tab	;2a *
	dc.w	.space-.tab	;2b +
	dc.w	errsyn1-.tab	;2c ,
	dc.w	.minus-.tab	;2d -
	IFNE	ATARI
	dc.w	glo_loc1-.tab	;2e .
	ENDC
	IFNE	AMIGA
	dc.w	cannot-.tab
	ENDC
	dc.w	errsyn1-.tab	;2f /
	IFNE	ATARI
	REPT	10		;0-9
	dc.w	glo_loc1-.tab
	ENDR
	ENDC
	IFNE	AMIGA
	REPT	10
	dc.w	cannot-.tab
	ENDR
	ENDC
	dc.w	errsyn1-.tab	;3a :
	dc.w	errsyn1-.tab	;3b ;
	dc.w	errsyn1-.tab	;3c <
	dc.w	errsyn1-.tab	;3d =
	dc.w	errsyn1-.tab	;3e >
	dc.w	errsyn1-.tab	;3f ?
	dc.w	octal1-.tab	;40 @
	REPT	26		;A-Z
	dc.w	glo_var1-.tab
	ENDR
	dc.w	errsyn1-.tab	;5b [
	dc.w	dec1-.tab		;5c \
	dc.w	errsyn1-.tab	;5d ]
	dc.w	errsyn1-.tab	;5e ^
	dc.w	glo_var1-.tab	;5f _
	dc.w	errsyn1-.tab	;60 `
	REPT	26		;a-z
	dc.w	glo_var1-.tab	;61 a
	ENDR
	dc.w	errsyn1-.tab	;7b {
	dc.w	errsyn1-.tab	;7c |
	dc.w	errsyn1-.tab	;7d }
	dc.w	.tilde-.tab	;7e ~
	dc.w	errsyn1-.tab	;7f 
	REPT	$80
	dc.w	errempt1-.tab	;80-ff
	ENDR
;  #] GloEval1:

;  #[ Eval1 routines:
VAR1_REGLIST	reg	a1	;-a2
eval1_var1:
	move.l	a1,-(sp)
	move.l	a0,a1
	subq.w	#1,a0
	moveq	#-1,d2
.gl1:	tst.b	(a1)+
	dble	d2,.gl1
	neg.w	d2
	move.w	d2,d0
	jsr	FindEqu	;garb d1/a1
	add.w	d2,a0
	beq.s	.patch
	move.l	d0,a1
	move.b	VAR_sec(a1),d1
	bpl.s	.relequ
	move.l	VAR_value(a1),d0
	move.b	VAR_type(a1),d1
	beq.s	.plus	;EQU_EQU et >0
	lsl.b	#1,d1	;>0?
	bcs.s	.moins
.plus:	subq.b	#EQU_EQUR*2,d1
	bpl.s	.equr	;ni EQU_EQU,ni EQU_SET
	move.l	(sp)+,a1
	POPEVAL1
	sf	d2
	moveq	#EVAL_NOERR,d1
	rts
.moins:	neg.l	d0	;si negatif seulement EQU ou SET -> pas de verif
	move.l	(sp)+,a1
	POPEVAL1
	st	d2
	moveq	#EVAL_NOERR,d1
	rts
.patch:	move.l	d2,d1	;d2=ffff:expr_size
	swap	d1
	move.l	(sp)+,a1
	POPEVAL1
	addq.b	#EVAL_GLO+1,d1
	rts
;si c'est 1 set relogeable ,stocker sa valeur
.relequ:	move.b	VAR_type(a1),d1
	beq.s	.patch
	subq.b	#EQU_SET,d1
	bne.s	.equr
	moveq	#6,d0
	jsr	LValAlloc
	beq.s	.rmem
	move.l	a0,-(sp)
	move.l	d0,a0
	move.l	VAR_value(a1),(a0)+
	lsl.b	#1,d1
	scs	(a0)+
	move.b	VAR_sec(a1),d1
	addq.b	#1,d1
	move.b	d1,(a0)+
	move.l	(sp)+,a0
	bra.s	.patch		;d0=@table
.equr:	;aussi EQU_REG,EQU_MACRO
	move.l	(sp)+,a1
	POPEVAL1
	moveq	#EVAL_EQUR,d1
	rts
.rmem:	move.l	(sp)+,a1
	POPEVAL1
	moveq	#EVAL_MEM,d1
	rts

eval1_loc1:
	moveq	#-1,d2
.l1:	move.b	(a0)+,d0
	dble	d2,.l1
	neg.w	d2	;+ le point
	move.l	d2,d1
	swap	d1
	POPEVAL1
	moveq	#0,d0
	addq.b	#EVAL_LOC+1,d1
	rts

star1:	moveq	#6,d0
	jsr	LValAlloc
	beq.s	.errmem
	move.l	a1,-(sp)
	move.l	d0,a1
	move.l	SecSize,(a1)+
	move.w	CurSection,d1
	addq.w	#1,d1
	move.w	d1,(a1)	;SIGN+section
	move.l	(sp)+,a1
	POPEVAL1
	move.l	#$1ff00+EVAL_GLO,d1
	rts
.errmem:	POPEVAL1
	moveq	#EVAL_MEM,d1
	rts
;  #] Eval1 routines:
;  #[ ForEval1 routines:
for_var1:
	move.l	a1,-(sp)
	move.l	a0,a1
	subq.w	#1,a0
	moveq	#-1,d2
.l1:	tst.b	(a1)+
	dble	d2,.l1
	neg.w	d2
	move.w	d2,d0
	jsr	FindEqu	;garb d1/a1
	beq.s	.equnf
	add.w	d2,a0
	move.l	d0,a1
	moveq	#0,d1
	move.b	VAR_type(a1),d0
	lsl.b	#1,d0
	scs	d1	;SIGN
	subq.b	#EQU_EQUR*2,d0
	beq.s	.errequr
	swap	d1	;d1=00:SIGN:00:00
	move.b	VAR_sec(a1),d1
	move.l	VAR_value(a1),d0
	move.l	(sp)+,a1
	POPEVAL1
	addq.b	#1,d1
	rts
.equnf:	move.w	d2,d0
	jsr	ForceGloVar
	add.w	d2,a0
	beq.s	.glonf
	moveq	#1,d1
	add.b	VAR_sec(a1),d1
	move.l	VAR_value(a1),d0
.end:	move.l	(sp)+,a1
	POPEVAL1
	tst.l	d1
	rts
.errequr:	moveq	#EVAL_COMPEQUR,d1
	bra.s	.end
.glonf:	moveq	#EVAL_MUSTEVAL,d1
	bra.s	.end

for_star1:
	POPEVAL1
	move.l	SecSize,d0
	move.w	CurSection,d1
	addq.b	#1,d1
	rts

for_loc1:	move.l	a1,-(sp)
	move.l	a0,a1
	moveq	#-1,d2
.l1:	tst.b	(a1)+
	dble	d2,.l1
	not.w	d2
	move.w	d2,d0
	jsr	ForceLocVar
	add.w	d2,a0
	beq.s	.nf
	moveq	#1,d1
	add.b	VAR_sec(a1),d1
	move.l	VAR_value(a1),d0
.end:	POPEVAL1
	move.l	(sp)+,a1
	tst.l	d1
	rts
.nf:	moveq	#EVAL_MUSTEVAL,d1
	bra.s	.end
;  #] ForEval1 routines:
;  #[ IfEval1 routines:
if_var1:	movem.l	VAR1_REGLIST,-(sp)
	move.l	a0,a1
	subq.w	#1,a0
	moveq	#-1,d2
.gl1:	tst.b	(a1)+
	dble	d2,.gl1
	neg.w	d2
	move.w	d2,d0
	jsr	FindEqu	;garb d1/a1
	beq.s	.notequ
	add.w	d2,a0
	move.l	d0,a1
	move.b	VAR_sec(a1),d1
	bpl.s	.relequ
	move.l	VAR_value(a1),d0
	move.b	VAR_type(a1),d1
	beq.s	.plus	;EQU_EQU et >0
	lsl.b	#1,d1	;>0?
	bcs.s	.moins
.plus:	subq.b	#EQU_EQUR*2,d1
	bpl.s	.equr	;ni EQU_EQU,ni EQU_SET
	POPEVAL1
	movem.l	(sp)+,VAR1_REGLIST
	sf	d2
	moveq	#EVAL_NOERR,d1
	rts
.moins:	neg.l	d0	;si negatif seulement EQU ou SET -> pas de verif
	POPEVAL1
	movem.l	(sp)+,VAR1_REGLIST
	st	d2
	moveq	#EVAL_NOERR,d1
	rts
.notequ:	move.w	d2,d0
	jsr	ForceGloVar
	beq.s	.nf
	add.w	d2,a0
.rel:	moveq	#0,d1
	move.b	VAR_sec(a1),d1
	addq.b	#1,d1
	swap	d1
	POPEVAL1
	movem.l	(sp)+,VAR1_REGLIST
	addq.b	#EVAL_OPTI,d1
	rts
;c'est 1 equ relogeable (sign=0)
.relequ:  move.l	VAR_value(a1),d0
	cmp.b	#EQU_EQUR,VAR_type(a1)
	bne.s	.rel
.equr:	;aussi EQU_REG,EQU_MACRO
	POPEVAL1
	movem.l	(sp)+,VAR1_REGLIST
	moveq	#EVAL_EQUR,d1
	rts
.nf:	move.l	d2,d1	;d2=ffff:expr_size
	swap	d1
	POPEVAL1
	movem.l	(sp)+,VAR1_REGLIST
	addq.b	#EVAL_GLO+1,d1
	rts

if_loc1:	move.l	a1,-(sp)
	move.l	a0,a1
	moveq	#-1,d2
.l1:	tst.b	(a1)+
	dble	d2,.l1
	not.w	d2
if_force:	move.w	d2,d0
	jsr	ForceLocVar
	bne.s	.found
	addq.w	#1,d2
	add.w	d2,a0
	move.l	d2,d1	;d2=ffff:expr_size
	swap	d1
	POPEVAL1
	move.l	(sp)+,a1
	addq.b	#EVAL_LOC+1,d1
	rts
.found:	moveq	#0,d1
	move.b	VAR_sec(a1),d1
	addq.b	#1,d1
	swap	d1
	move.l	(sp)+,a1
	POPEVAL1
	addq.b	#EVAL_OPTI,d1
	rts

if_star1:	move.l	SecSize,d0
	moveq	#EVAL_OPTI,d1
	rts

if_dec1:	subq.w	#1,a0
	moveq	#0,d1
	moveq	#0,d0
	move.l	a1,-(sp)
	move.l	a0,a1
.l1:
	REPT	4
	move.b	(a0)+,d1
	ble.s	.decend
	sub.b	#'0',d1
	bmi.s	.pardec
	cmp.b	#9,d1
	bgt.s	.syndec
	move.l	d0,d2
	lsl.l	#3,d0
	add.l	d2,d2
	add.l	d2,d0
	bcs.s	.lgdec
	add.l	d1,d0
	ENDR
	bra.s	.l1
.decend:	move.l	(sp)+,a1
	POPEVAL1
	sf	d2
	moveq	#EVAL_NOERR,d1
	rts
.pardec:	cmp.b	#')'-'0',d1
	beq.s	.decend
	cmp.b	#'$'-'0',d1
	beq.s	.local
.syndec:	move.l	(sp)+,a1
	bra	errsyn1
.lgdec:	move.l	(sp)+,a1
	bra	errlnum1
.local:	;a1 start,a0 end
	move.l	a0,d2
	sub.l	a1,d2
	move.l	a1,a0
	or.l	#$ffff0000,d2
	bra	if_force
;  #] IfEval1 routines:
;  #[ LocEval1 routines:
loc_dec1:	subq.w	#1,a0
loc_loc1:	move.l	a1,-(sp)
	move.l	a0,a1
	moveq	#-1,d0
.l1:	tst.b	(a1)+
	dble	d0,.l1
	not.w	d0
	jsr	GetLocVar
	beq.s	.nf
	IFNE	ATARI
	tst.b	d1
	beq.s	.end
;local en data/bss resolu en GlobalPatch
	move.l	d0,d2			;a2->d2???
	moveq	#6,d0
	jsr	LValAlloc
	beq.s	.errmem
	move.l	d0,a1
	move.l	d2,(a1)+
	move.w	d1,(a1)+		;BUG move.l!
	POPEVAL1
	moveq	#EVAL_LOCGLO+EVAL_RELOC,d1
	move.l	(sp)+,a1
	rts
	ENDC	;ATARI
.end:	POPEVAL1
	moveq	#EVAL_RELOC,d1
	move.l	(sp)+,a1
	rts
.errmem:	POPEVAL1
	moveq	#0,d0
	moveq	#EVAL_MEM,d1
	move.l	(sp)+,a1
	rts
.nf:	POPEVAL1
	moveq	#EVAL_NFVAR,d1
	move.l	(sp)+,a1
	rts
;  #] LocEval1 routines:
;  #[ GloEval1 routines:
glo_var1: movem.l	d3/a1,-(sp)
	moveq	#-1,d3
	move.l	a0,a1
.l1:	tst.b	(a1)+
	dble	d3,.l1
	neg.w	d3
	move.w	d3,d0
	subq.w	#1,a0
	jsr	GetGloVar 	;pas touche a0
	beq.s	.xref
	move.b	VAR_sec(a1),d1
	addq.b	#1,d1
	move.b	VAR_type(a1),d3
	smi	d2
	bpl.s	.plus
	neg.l	d0
	and.b	#$7f,d3
.plus:	bne.s	.check
.out:	POPEVAL1
	movem.l	(sp)+,d3/a1
	rts
.check:	subq.b	#EQU_GLOB,d3
	beq.s	.out
	addq.b	#EQU_GLOB-EQU_SET,d3
	bne.s	.errtype		;ni EQU_EQU, ni EQU_SET
.set:	move.l	EXP_backval(a3),d0
	beq.s	.fwset
	move.l	d0,a1
	move.l	(a1)+,d0
	move.b	(a1)+,d2
	beq.s	.pl
	neg.l	d0
.pl:	POPEVAL1
	move.b	(a1)+,d1
	ble.s	.out2
	move.b	d1,d3
	subq.b	#SEC_data+1,d3
	beq.s	.plustxt
	add.l	DataSize,d0
.plustxt:	add.l	TextSize,d0
.out2:	movem.l	(sp)+,d3/a1
	rts

.errtype:	POPEVAL1
	moveq	#EVAL_TYPE,d1
	bra.s	.out

.xref:	move.w	d3,d0
	jsr	GetXref
	beq.s	.errvar
	swap	d0		;#<<16
	move.l	d0,d1
	st	d1		;undef
	POPEVAL1
	moveq	#0,d0		;pour le ccr
	movem.l	(sp)+,d3/a1
	rts
.errvar:	moveq	#EVAL_NFVAR,d1
	bra.s	.out

.fwset:	moveq	#EVAL_FW_SET,d1
	bra.s	.out

glo_star1:
	move.l	a1,-(sp)
	IFNE	BLINDOS	
	move.l	EXP_backval(a3),d0
	beq.s	.bug
	move.l	d0,a1
	ELSEIF
	move.l	EXP_backval(a3),a1
	ENDC	;BLINDOS
	move.l	(a1)+,d0	;val
	move.w	(a1)+,d1	;section+1
	IFNE	ATARI
	cmp.b	#SEC_data+1,d1
	bne.s	.nodata
	add.l	TextSize,d0
	ENDC	;ATARI
.nodata:	POPEVAL1
	sf	d2
	tst.l	d1
.end:	move.l	(sp)+,a1
	rts
	IFNE	BLINDOS
.bug:	_Debugger
	bra.s	.end
	ENDC	;BLINDOS

	IFNE	ATARI
;pour local en section DATA
glo_loc1:
	move.l	a1,-(sp)
	move.l	EXP_backval(a3),d0
	IFNE	BLINDOS
	beq.s	.bug
	ENDC	;BLINDOS
	sf	d2
	move.l	d0,a1
	movem.l	(a1)+,d0-d1
	add.l	TextSize,d0
	POPEVAL1
.end:	move.l	(sp)+,a1
	rts
	IFNE	BLINDOS
.bug:	_Debugger
	bra.s	.end
	ENDC	;BLINDOS
	ENDC	;ATARI
;  #] GloEval1 routines:
;  #[ Commun:
dec1:	;Eval1 et ForEval uniquement
	subq.w	#1,a0
	moveq	#0,d1
	moveq	#0,d0
	move.l	a1,-(sp)
	move.l	a0,a1
.l1:
	REPT	4
	move.b	(a0)+,d1
	ble.s	.decend
	sub.b	#'0',d1
	bmi.s	.pardec
	cmp.b	#9,d1
	bgt.s	.syndec
	move.l	d0,d2
	lsl.l	#3,d0
	add.l	d2,d2
	add.l	d2,d0
	bcs.s	.lgdec
	add.l	d1,d0
	ENDR
	bra.s	.l1
.decend:	move.l	(sp)+,a1
	POPEVAL1
	sf	d2
	moveq	#EVAL_NOERR,d1
	rts
.pardec:	cmp.b	#')'-'0',d1
	beq.s	.decend
	cmp.b	#'$'-'0',d1
	beq.s	.local
.syndec:	move.l	(sp)+,a1
	bra	errsyn1
.lgdec:	move.l	(sp)+,a1
	bra	errlnum1
.local:	;a1 start,a0 end
	move.l	a0,d1
	sub.l	a1,d1
	swap	d1
	move.l	(sp)+,a1
	POPEVAL1
	add.w	#$ff00+EVAL_LOC,d1
	tst.l	d1
	rts

quote1:	moveq	#0,d0
	moveq	#TOKENQUOTE,d2
	REPT	5
	move.b	(a0)+,d1
	cmp.b	d1,d2
	beq.s	.endq
	lsl.l	#8,d0
	or.b	d1,d0
	ENDR
.errlstr:	POPEVAL1
	moveq	#0,d0
	moveq	#EVAL_LSTR,d1
	rts
.endq:	POPEVAL1
	sf	d2
	moveq	#EVAL_NOERR,d1
	rts

octal1:	moveq	#0,d0
.o1:	move.b	(a0)+,d1
	ble.s	.endoct
	sub.b	#'0',d1
	bmi.s	.paroct
	cmp.b	#7,d1
	bgt.s	.erroct
	lsl.l	#3,d0
	bcs.s	errlnum1
	or.b	d1,d0
	bra.s	.o1
.paroct:	addq.b	#'0'-')',d1
	bne.s	.erroct
.endoct:	POPEVAL1
	sf	d2
	moveq	#EVAL_NOERR,d1
	rts
.erroct:	bra	errsyn1

bin1:	moveq	#0,d0
.b0:	move.b	(a0)+,d1
	ble.s	.endbin
	sub.b	#'0',d1
	bmi.s	.parbin
	cmp.b	#1,d1
	bgt.s	.errbin
	add.l	d0,d0			;lsl #1,d0
	bcs.s	errlnum1
	or.b	d1,d0
	bra.s	.b0
.parbin:	addq.b	#'0'-')',d1
	bne.s	.errbin
.endbin:	POPEVAL1
	sf	d2
	moveq	#EVAL_NOERR,d1
	rts
.errbin:	bra	errsyn1

errlnum1:	POPEVAL1
	moveq	#0,d0
	moveq	#EVAL_LNUM,d1
	rts

hexa1:	moveq	#0,d0
	moveq	#0,d1
.h0:	move.b	(a0)+,d1
	ble.s	.endhex
	move.b	.hextab(pc,d1.w),d1
	bmi.s	.parhex
	lsl.l	#4,d0
	bcs.s	errlnum1
	or.b	d1,d0
	bra.s	.h0
.parhex:	cmp.b	#')',-1(a0)
	bne.s	.errhex
.endhex:	POPEVAL1
	sf	d2
	moveq	#EVAL_NOERR,d1
	rts
.errhex:	bra	errsyn1
.hextab:	dc.b	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	+0,+1,+2,+3,+4,+5,+6,+7,+8,+9,-1,-1,-1,-1,-1,-1
	dc.b	-1,10,11,12,13,14,15,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	-1,10,11,12,13,14,15,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1

;  #] Commun:

errempt1:	POPEVAL1
	moveq	#0,d0
	moveq	#EVAL_EOE,d1
	rts

errsyn1:	POPEVAL1
	moveq	#0,d0
	moveq	#EVAL_SYNTAX,d1
	rts

;tout ce qui ne devrait pas arriver:
;* ou global en LocEval
;local en GloEval sur Amiga
cannot:	POPEVAL1
	moveq	#0,d0
	IFNE	BLINDOS
	_Debugger
	ENDC
	moveq	#0,d1
	rts

