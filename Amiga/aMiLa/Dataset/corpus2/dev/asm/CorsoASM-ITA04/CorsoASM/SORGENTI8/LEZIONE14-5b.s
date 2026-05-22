
; Corso Asm - LEZIONE xx:  ** SUONA SAMPLE MOLTO LUNGHI SOTTO OS **


	SECTION	PlayLongSamples_OS,CODE

Start:
	bset	#1,$bfe001

	lea	sample,a0
	move.l	#sample_end-sample,d0
	move.w	#17897,d1
	moveq	#64,d2
	bsr.s	playlongsample_init

WLMB:	btst	#6,$bfe001
	bne.s	wlmb
	btst	#10,$dff016
	bne.s	wlmb

	bsr.w	playlongsample_restore
	rts


***************************************
*****  Play Long Sample Routines  *****
***************************************

PlayLongSample_init:
		;[a0=sample adr]
		;[d0.l=lunghezza.b sample, d1.w=frequenza, d2.w=volume]

Clock		equ	3546895
NT_Interrupt	equ	2
LN_Type		equ	8
LN_Pri		equ	9
LN_Name		equ	10
IS_Data		equ	14
IS_Code		equ	18
IS_SIZE		equ	22
_LVOSetIntVector	equ	-162

	movem.l	d0/d2/a1/a6,-(sp)
	movem.l	d0/a0,plsregs
	movem.l	d0/a0,plsregs+4*2
	movem.l	d1-d2,-(sp)
	move.l	4.w,a6				;base di exec in a6
	lea	aud1int_node(pc),a1		;struttura/nodo dell'interrupt
	move.b	#nt_interrupt,ln_type(a1)	;tipo di nodo: interrrupt
	move.l	#aud1int_name,ln_name(a1)	;nome del nodo public
	move.l	#aud1int_data,is_data(a1)	;punta ai dati (a1-scratch)
	move.l	#aud1int_code,is_code(a1)	;punta al codice (a5-scratch)
	moveq	#8,d0				;bit di INTENA/INTREQ (AUD1)
	jsr	_LVOSetIntVector(a6)
	move.l	d0,oldaud1int_node		;d0.l=nodo precedente
	movem.l	(sp)+,d1-d2
	lea	$dff000,a6
	move.w	d2,$a8(a6)
	move.w	d2,$b8(a6)
	move.w	d2,$c8(a6)
	move.w	d2,$d8(a6)
	move.l	#clock,d2
	divu.w	d1,d2
	move.w	d2,$a6(a6)
	move.w	d2,$b6(a6)
	move.w	d2,$c6(a6)
	move.w	d2,$d6(a6)
	move.w	$2(a6),olddma
	move.w	$1c(a6),oldint
	move.w	#$8100,$9a(a6)
	move.w	#$8100,$9c(a6)
	movem.l	(sp)+,d0/d2/a1/a6
	rts
;--------------------------------------
PlayLongSample_restore:
	movem.l	d0/a1/a6,-(sp)
	move.l	4.w,a6
	move.l	oldaud1int_node(pc),a1		;reimposta nodo precedente
	moveq 	#8,d0				;bit di INTENA/INTREQ (AUD1)
	jsr	_LVOSetIntVector(a6)
	lea	$dff000,a6
	move.w	#$0780,$9c(a6)			;spegne tutte le richieste IRQ
	move.w	#$0100,$9a(a6)
	move.w	oldint(pc),d0
	or.w	#$8000,d0
	move.w	d0,$9a(a6)
	move.w	#$000f,$96(a6)
	move.w	olddma(pc),d0
	or.w	#$8000,d0
	move.w	d0,$96(a6)
	movem.l	(sp)+,d0/a1/a6
	rts
;--------------------------------------
PlayLongSample_IRQ:			;<<< questa routine e' identica
	movem.l	d0-d1/a0-a1/a6,-(sp)
	lea	$dff000,a6
	movem.l	plsregs+4*2(pc),d0/a0
	move.l	a0,$a0(a6)
	move.l	a0,$b0(a6)
	move.l	a0,$c0(a6)
	move.l	a0,$d0(a6)
	move.l	d0,d1
	and.l	#~(128*1024-1),d1
	bne.s	.long
	move.l	d0,d1
.Long:	lsr.l	#1,d1
	move.w	d1,$a4(a6)
	move.w	d1,$b4(a6)
	move.w	d1,$c4(a6)
	move.w	d1,$d4(a6)
	add.l	#128*1024,a0
	sub.l	#128*1024,d0
	bhi.s	.noloop
	movem.l	plsregs(pc),d0/a0
.NoLoop:movem.l	d0/a0,plsregs+4*2
	move.w	#$820f,$96(a6)
	movem.l	(sp)+,d0-d1/a0-a1/a6
	rts
;--------------------------------------
OldDMA:	dc.w	0
OldInt:	dc.w	0
OldAud1Int_Node:dc.l	0
Aud1Int_Node:
	blk.b	is_size		;lunghezza InterruptStructure
	even
Aud1Int_Name:
	dc.b	"PlayLongSampleIRQ",0
	even
Aud1Int_Data:
PLSRegs:dc.l	0,0	;lunghezza,puntatore - fissi
	dc.l	0,0	;lunghezza,puntatore - variabili

	cnop   0,8
Aud1Int_Code:
	move.w	#$0100,$dff09c
	bsr.w	playlongsample_irq
	rts



	SECTION	Sample,DATA_C

	; MammaGamma by Alan Parsons Project (©1981)
Sample:
	incbin	"assembler2:sorgenti8/Mammagamma.17897"
Sample_end:

	END


Questa volta non e' cambiato quasi nulla rispetto al sorgente precedente:
abbiamo solo allocato l'handler di interrupt con l'exec library, in modo
da rendere tutto un po' piu' "friendly" nei confronti del sistema operativo.

N.B.:	e' stato utilizzato l'interrupt del canale 1, poiche', per le pseudo
	priorita' software dell'exec, e' il primo a essere rilevato nello
	handler interno in ROM di livello 4.

P.S.:	una precisazione per quanto riguarda la differenza tra Server Chain
	ed Handler di interrupt per l'exec: certi interrupt (VERTB, COPER,
	PORTS, EXTER e NMI) sono piu' utili di altri e vengono usati spesso
	sia dall'OS che dai task utente; l'exec deve pertanto dare la
	possibilita' a tutti di avere delle proprie routine in interrupt, e
	forma quindi delle "catene" di routine aventi diversa e specificabile
	priorita' di esecuzione gestite da un unico handler.
	Tutti gli altri interrupt del Paula (TBE, DSKBLK, SOFT, BLIT, AUD0-3,
	RBF e DSKSYNC) non sono visti come server chain ma come handler: ognuno
	puo' impossessarsi del dato interrupt completamente, senza linkarsi
	o dividerselo con nessun altro task.
	Nel nostro caso, abbiamo alloccato l'interrupt del canale 1, quello a
	priorita' software maggiore, per l'exec (...e non chiedetemi perche'),
	con _LVOSetIntVector perche' richiede un handler, non un server;
	inoltre, nel caso degli handler, la priorita' del nodo della struturra
	dell'interrupt non necessita di essere impostata poiche' non
	vi sono altri server nella chain, si e' soli.

P.P.S.:	tutte le note del sorgente precedente - a parte quelle variate -
	valgono anche per questo.

	N.B.:	gli EQU provengono dagli include "exec/interrupt.i" ed
		"LVO1.3/exec_lib.i".
