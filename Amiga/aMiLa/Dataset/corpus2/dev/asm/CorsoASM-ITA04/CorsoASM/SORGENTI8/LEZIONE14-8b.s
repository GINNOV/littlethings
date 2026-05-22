
; Corso Asm - LEZIONE xx:  * MIXARE 2 SAMPLE E BOOSTARE IL VOLUME *

Start:

_LVODisable	EQU	-120
_LVOEnable	EQU	-126

	move.l	4.w,a6
	jsr	_LVODisable(a6)
	bset	#1,$bfe001		;spegne il filtro passa-basso
	lea	$dff000,a6
	move.w	$2(a6),d7		;salva DMA dell'OS


	move.l	#sample1,$a0(a6)
	move.l	#sample2,$b0(a6)
	move.w	#(sample1_end-sample1)/2,$a4(a6)
	move.w	#(sample2_end-sample2)/2,$b4(a6)
Clock	equ	3546895
	move.w	#clock/21056,$a6(a6)
	move.w	#clock/21056,$b6(a6)
	move.w	#64,$a8(a6)
	move.w	#64,$b8(a6)
	move.w	#$8003,$96(a6)		;accende AUD0-AUD1 DMA in DMACONW

WLMB:	btst	#6,$bfe001
	bne.s	wlmb

	lea	sample0,a0
	move.l	#sample0_end-sample0,d0
	lea	sample1,a1
	move.l	#sample1_end-sample1,d1
	lea	sample2,a2
	move.l	#sample2_end-sample2,d2
	bsr.s	boost_mixsamples

	lea	$dff000,a6
	move.l	#sample0,$a0(a6)
	move.l	#sample0,$b0(a6)
	move.w	#(sample0_end-sample0)/2,$a4(a6)
	move.w	#(sample0_end-sample0)/2,$b4(a6)
	move.w	#$8003,$96(a6)

WRMB:	btst	#10,$dff016
	bne.s	wrmb

	move.w	#$0003,$96(a6)		;spegne i DMA
	or.w	#$8000,d7		;accende il bit 15 (SET/CLR)
	move.w	d7,$96(a6)		;reimposta DMA dell'OS
	move.l	4.w,a6
	jsr	_LVOEnable(a6)
	rts


Boost_MixSamples:
		;[a0=dst sample, a1=src sample 1, a2=soruce sample 2]
		;[d0.l=dst length.b, d1.l=src1 length.b, d2.l=src2 length.b]
	movem.l	d0-d3/a0-a4,-(sp)
	lea	(a1,d1.l),a3		;a3=fine del sample 1
	lea	(a2,d2.l),a4		;a4=fine de sample 2
	moveq	#0,d3			;d3.w=0=MAX campione di partenza
.Lp1:	move.w	#$f00,$dff180
	move.b	(a1)+,d1		;d1.b=campione del sample 1
	ext.w	d1			;d1.w=d1.b esteso di segno a word
	move.b	(a2)+,d2		;d2.b=campione del sample 2
	ext.w	d2			;d2.w=d2.b esteso si segno a word
	add.w	d1,d2			;d2.w=somma CON SEGNO i campioni 1 e 2
	bpl.s	.noabs
	neg.w	d2
.NoAbs:	cmp.w	d3,d2			;d2.w=valore assoluto di d2
	bls.s	.nomax
	move.w	d2,d3			;se d2>d3: d3(MAX)=d2
.NoMax:	cmp.l	a3,a1			;è finito il sample 1 ?
	bhs.s	.quit1			;se SI: esci
	cmp.l	a4,a2			;è finito il sample 2 ?
	bhs.s	.quit1			;se SI: esci
	subq.l	#1,d0
	bhi.s	.lp1
.Quit1:	move.l	(sp),d0			;ripristina d0
	movem.l	5*4(sp),a1-a2		;ripristina a1 ed a2
	move.w	d3,$7ff0000
					;d3.w=MAX raggiunto dalle somme
.Lp2:	move.w	#$00f,$dff180
	move.b	(a1)+,d1		;d1.b=campione del sample 1
	ext.w	d1			;d1.w=d1.b esteso di segno a word
	move.b	(a2)+,d2		;d2.b=campione del sample 2
	ext.w	d2			;d2.w=d2.b esteso si segno a word
	add.w	d1,d2			;d2.w=somma CON SEGNO i campioni 1 e 2

	muls.w	#127,d2			;PROPORZIONE: d3(MAX)/127=d2/x
	divs.w	d3,d2
	move.b	d2,(a0)+

	cmp.l	a3,a1			;è finito il sample 1 ?
	bhs.s	.quit2			;se SI: esci
	cmp.l	a4,a2			;è finito il sample 2 ?
	bhs.s	.quit2			;se SI: esci
	subq.l	#1,d0			;decrementa lungh0.b fino a 0...senza
	bhi.s	.lp2
.Quit2:	movem.l	(sp)+,d0-d3/a0-a4
	rts


	SECTION	Sample,DATA_C

Sample1:
	incbin	"assembler2:sorgenti8/carrasco.21056"
Sample1_end:

Sample2:
	incbin	"assembler2:sorgenti8/lee3.21056"
Sample2_end:

Sample0:blk.b	sample1_end-sample1
Sample0_end:
	END


In teoria, il vero mixing si dovrebbe fare solo sommando algebricamente i
campioni, tuttavia, per ovvi omtivi, spesso si fuoriesce dal range di 8 bit con
segno, e, per deamplificare direttamente la forma d'onda in maniera equa, si
divide sempre per 2. Risultato: la resa d'intensità finale è minore di
quella dei 2 sample suonati indipendentemente su due canali diversi.
Per poter utilizzare il normale algoritmo di mixing, sarebbe necessario che
la somma non sorpassi mai 127 o -128, che non esca mai dai limiti del range.
Visto che non conviene campionare sample bassi perchè l'audio ad 8 bit non
possiede una grande precisione, siamo costretti a boostare il volume del
sample mixato fino al limite: si considera il più alto volume raggiunto dalle
somme, e lo si usa come range massimo proporzionale a 127 (valore assoluto
massimo raggiungibile: NON 128, poichè solo la parte negativa arriva a -128,
ed amplificando troppo la positiva - oltre 127 - saremmo al punto di prima).
Le proporzioni - che, personalmente, sono solito definire « gli "zoom" della
matematica » - sono utili, in questo caso, per restringere il campo/range
entro i limiti in modo appunto proporzionale ed equo per tutti i sample.
*** In sostanza, abbiamo deamplificato fino a che il valore più alto delle
somme non fosse pari a 127 (o -127), e tutto il resto proporzionalmente ***.


N.B.:	anche se sarebbe forse stato opportuno, non è stato applicato alcun
	arrotondamento: si sarebbe dovuto usare un sorta di approssimazione
	oltre la virgola di più bit, che, pur incrementando - anche se non
	effettivamente percepibilmente - la qualità del mixing, avrebbe
	causato non pochi problemi di comprensione del sorgente e, soprattutto,
	di velocità: dopo la moltiplicazione per 127 avremmo potuto shiftare
	il tutto a destra di 16 bit (moltiplicando il numero di molto per 
	simulare la virgola con numeri molto grandi da dividere, poi),
	ottenendo così un valore a 32 bit; valore che doveva essere diviso
	per MAX e poi risfhiftato a sinistra di 16 bit ed arrotondato con
	il bit più significativo della parte shiftata per essere riportato alla
	grandezza originale. Tutto ciò, però, comporterebbe un problema dovuto
	ad una limitazione del 68000: dividendo il valore a 32 bit per MAX,
	il risultato - se MAX è vicino al valore somma corrente - potrebbe
	essere ancora a 32, e l'istruzione DIVS - purtroppo - restituisce il
	risultato a 16 bit nella parte bassa del registro ed il resto nella
	parte alta, cancellando la word a noi tanto utile. Il problema si
	sarebbe potuto presentare per qualsiasi altra approssimazione...
