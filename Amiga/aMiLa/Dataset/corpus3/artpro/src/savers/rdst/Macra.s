;TOSPJPKPJPKAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAGAFAGAG
;
;start 96-Styczeï-01
;$VER: macra v1.0d DATE 10-VIII-97
;name		info				example		more info
;
;push		zrzutka rejestrów na stos 	d0-d4/a0
;pop		zbiórka rejestrów ze stosu	d0-d4/a0
;call		skok do procedórki sys _XXX	OpenLibrary	jsr _xxx(a6)
;callexec	skok od execu			OpenLibrary	4.w>a6 call xx
;exec		wrzuca do a6 baze execu		-		move.l 4.w,a6
;rmb		pauza na prawâ mysz		-
;vertical	czeka na dany wertical		$101
;waitblitter	czeka aû blit. zkoïczy dziaîaê	-
;open
;movel		wrzuca baze biblioteki do a6	Dos		move.l b_xx,a6
;lib		to samo
;jump		jak call tylko jmp		OpenLibrary
;ml		zamiast move.l			jak move.l
;mw		move.w
;mb
;q 1
;q0 d0

qa0:	MACRO
	sub.l	\1,\1
	ENDM
ml:	MACRO
	move.l	\1,\2
	ENDM
mw:	MACRO
	move.w	\1,\2
	ENDM
mb:	MACRO
	move.b	\1,\2
	ENDM
q:	MACRO
	moveq	#\1,\2
	ENDM
q0:	MACRO
	moveq	#0,\1
	ENDM

push:	MACRO
	movem.l	\1,-(sp)
	ENDM
pop:	MACRO
	movem.l	(sp)+,\1
	ENDM
pusha:	MACRO
	movem.l	d0-a6,-(sp)
	ENDM
popa:	MACRO
	movem.l	(sp)+,d0-a6
	ENDM
EXEC:	MACRO
	move.l	4.w,a6
	ENDM
RMB:	MACRO
	btst	#2,$dff016
	beq.s	*-8
	ENDM
VERTICAL:	MACRO
	move.l	4(a5),d0
	and.l	#$0001ff00,d0
	cmp.l	#\1*2^8,d0
	bne.s	*-16
	ENDM
WAITBLITTER:	MACRO
.\@w	btst	#14,2(a5)
	bne.s	.\@w
	ENDM
movel:	MACRO
	move.l	b_\1(pc),a6
	ENDM
lib:	MACRO
	move.l	b_\1(pc),a6
	ENDM
JUMP:	MACRO
	jmp	_\1(a6)
	ENDM
CALL:	MACRO
	jsr	_\1(a6)
	ENDM
;CALLEXEC:	MACRO
;	EXEC
;	jsr	_\1(a6)
;	ENDM
CALLB:	MACRO
	move.l	b_\2(pc),a6
	jsr	_\1(a6)
	ENDM
