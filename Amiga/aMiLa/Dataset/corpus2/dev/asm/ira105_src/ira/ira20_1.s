;*******************************************************************
;Assembler-Routinen fuer IRA (c)1991,92,93 Tim Ruehsen
;Stand       : 13.07.1993
;Compiler    : SAS/C V5.1
;Generierung : asm -s ira20_1.s
;*******************************************************************

	CSECT	text,0,,1,2

;*******************************************************************
;Ein :A0 = Quellbereich (from)
;     A1 = Zielbereich  (to)
;     D0 = Anzahl zu kopierender Langworte

	XDEF	_lmovmem
_lmovmem:
	tst.l	d0
	ble.s	lmm_ende
	cmpa.l	A0,A1
	bcs.s	lmm_l2
	move.l	d0,d1
	lsl.l	#2,D1
	add.l	D1,A0
	add.l	D1,A1
lmm_l1:
	move.l	-(A0),-(A1)
	subq.l	#1,d0
	bne.s	lmm_l1
lmm_ende:
	rts
lmm_l2:
	move.l	(A0)+,(A1)+
	subq.l	#1,d0
	bne.s	lmm_l2
	rts

;*******************************************************************
;Ein :D0 = Integer (32Bit)
;Aus :D0 = Adresse der Zeichenkette
;
	XDEF	_itoa
_itoa:
	lea	_itoabuf+11(a4),a0
	tst.l	d0
	bne	.0_9

	; Bei Null nur '0' schreiben und zurueck
	move.b	#48,(a0)
	move.l	a0,d0
	rts

	; Bei negativem Wert negieren
.0_9
	movem.l	d2/d3,-(a7)
	move.l	d0,a1
	bge	.0_11
	neg.l	d0

.0_11
	move.l	#10,d1
.0_12
	MOVE	D0,D2
	CLR	D0
	SWAP	D0
	DIVU	D1,D0
	MOVE.L	D0,D3
	MOVE	D2,D3
	DIVU	D1,D3
	SWAP	D0
	MOVE	D3,D0  ;long/10
	SWAP	D3     ;long%10

	add.b	#48,d3
	move.b	d3,(a0)
	sub.l	#1,a0
	tst.l	d0
	bne	.0_12

	movem.l	(a7)+,d2/d3
	move.l	a0,d0
	move.l	a1,d1
	bge	.0_14
	move.b	#45,(a0)
	rts
.0_14
	add.l	#1,d0
	rts


;*******************************************************************
;EIN: D0.32 = Integerwert
;     D1.32 = Laenge der auszugebenden Zeichen
;AUS: D0    = Zeiger auf Zeichenkette

	XDEF	_itohex
_itohex:
	move.l	d2,-(a7)
	move.l	d1,d2
	move.l	d0,d1
	lea	_itoxbuf(a4),a0
	move.b	#0,0(a0,d2)
	subq.l	#1,d2
.1_1	
	move.b	d1,d0
	and.b	#$0f,d0
	add.b	#48,d0
	cmp.b	#57,d0
	bls.s	.1_2
	add.b	#7,d0
.1_2
	move.b	d0,0(a0,d2)
	asr.l	#4,d1
	dbra	d2,.1_1
	move.l	a0,d0
	move.l	(a7)+,d2
	rts


;*******************************************************************
;EIN: A0 = Zeiger auf Zeichenkette
;
	XDEF	_mnecat
_mnecat:
	lea	_mnebuf(a4),a1
	moveq	#0,d0
	tst.b	(a1)
	beq	.2_1
	move.w	_mnecnt(a4),d0
.2_1
	move.l	a1,d1
	add.l	d0,a1
.2_2
	move.b	(a0)+,(a1)+
	bne	.2_2

	sub.l	d1,a1
	subq.l	#1,a1
	move.l	a1,d0
	move.w	d0,_mnecnt(a4)
	rts


;*******************************************************************
;EIN: A0 = Zeiger auf Zeichenkette

	XDEF	_adrcat
_adrcat:
	lea	_adrbuf(a4),a1
	moveq	#0,d0
	tst.b	(a1)
	beq	.3_1
	move.w	_adrcnt(a4),d0
.3_1
	move.l	a1,d1
	add.l	d0,a1
.3_2
	move.b	(a0)+,(a1)+
	bne	.3_2

	sub.l	d1,a1
	subq.l	#1,a1
	move.l	a1,d0
	move.w	d0,_adrcnt(a4)
	rts

;*******************************************************************
;EIN: A0 = Zeiger auf Zeichenkette

	XDEF	_dtacat
_dtacat:
	lea	_dtabuf(a4),a1
	moveq	#0,d0
	tst.b	(a1)
	beq	.4_1
	move.w	_dtacnt(a4),d0
.4_1
	move.l	a1,d1
	add.l	d0,a1
.4_2
	move.b	(a0)+,(a1)+
	bne	.4_2

	sub.l	d1,a1
	subq.l	#1,a1
	move.l	a1,d0
	move.w	d0,_dtacnt(a4)
	rts


;*******************************************************************


	CSECT	__MERGED,1,,2,2
	XDEF	_mnebuf
	XDEF	_adrbuf
	XDEF	_dtabuf

	CNOP	0,2
_mnebuf:
	ds.b	32
_dtabuf:
	ds.b	96	;bei MOVEM 30,47 = 78 + 1x 0-Byte + 1xLaenge
_adrbuf:
	ds.b	64	;50 Bytes + 1x 0-Byte + 1xLaenge
_adrcnt:
	dc.w	0
_mnecnt:
	dc.w	0
_dtacnt:
	dc.w	0
_itoxbuf:
	ds.b	9
_itoabuf:
	ds.b	12

	end
