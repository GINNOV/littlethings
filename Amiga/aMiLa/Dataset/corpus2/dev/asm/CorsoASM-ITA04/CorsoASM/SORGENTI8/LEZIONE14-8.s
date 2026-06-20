
; Corso Asm - LEZIONE xx:  * MIXARE 2 SAMPLE *

	section	bau,code

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
	bsr.s	mixsamples
	move.l	#sample0,$a0(a6)	;verrà playato alla fine dei sample 1
	move.l	#sample0,$b0(a6)	;e 2: vi ricordate perchè ?
	move.w	#(sample0_end-sample0)/2,$a4(a6)
	move.w	#(sample0_end-sample0)/2,$b4(a6)

WRMB:	btst	#10,$dff016
	bne.s	wrmb

	move.w	#$0003,$96(a6)		;spegne i DMA
	or.w	#$8000,d7		;accende il bit 15 (SET/CLR)
	move.w	d7,$96(a6)		;reimposta DMA dell'OS
	move.l	4.w,a6
	jsr	_LVOEnable(a6)
	rts


MixSamples:	;[a0=dst sample, a1=src sample 1, a2=soruce sample 2]
		;[d0.l=dst length.b, d1.l=src1 length.b, d2.l=src2 length.b]
	movem.l	d0-d3/a0-a4,-(sp)
	lea	(a1,d1.l),a3		;a3=fine del sample 1
	lea	(a2,d2.l),a4		;a4=fine de sample 2
	moveq	#0,d3			;d3.b=0 per ADDX
.Lp:	move.w	#$f00,$dff180
	move.b	(a1)+,d1		;d1.b=campione del sample 1
	ext.w	d1			;d1.w=d1.b esteso di segno a word
	move.b	(a2)+,d2		;d2.b=campione del sample 2
	ext.w	d2			;d2.w=d2.b esteso si segno a word
	add.w	d1,d2			;d2.w=somma CON SEGNO i campioni 1 e 2
	asr.w	#1,d2			;d2.w=media dei campioni (somma/2)
	addx.b	d3,d2			;d2.w=campione mixato ARROTONDATO per
					;eccesso o per difetto in base al bit
					;uscito con l'ASR
	move.b	d2,(a0)+		;salva il campione mixato
	cmp.l	a3,a1			;è finito il sample 1 ?
	bhs.s	.quit			;se SI: esci
	cmp.l	a4,a2			;è finito il sample 2 ?
	bhs.s	.quit			;se SI: esci
	subq.l	#1,d0			;decrementa lungh0.b fino a 0...senza
					;DBRA perchè funziona solo a word...
	bhi.s	.lp
.Quit:	movem.l	(sp)+,d0-d3/a0-a4
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


Cosa abbiamo combinato questa volta ? Siamo riusciti a suonare 2 sample diversi
sulla stessa voce ! Come ? Mixandoli via software con la CPU !
Conoscete bene la struttura della forma d'onda id una sample, e sapete che
ogni campione di 1 byte può variare da -128 a 127, pertanto sono BYTE CON SEGNO
con i quali è possibile lavorare trattandoli secndo la loro natura di numeri
ad 8 bit, il più significativo dei quali agisce da segno.
Quale miglior metodo per fare in modo che date due serie di numeri se ne
ottenga una che ricalchi l'andamento di entrambe ?
Fare la MEDIA ARITMETICA tra ogni coppia di singoli byte/campioni: prendendo
2 campioni corrispondenti dell'uno e dell'altro sample, è sufficiente
sommarli algebricamente (* TENENDO QUINDI CONTO DEL SEGNO *) e dividere il
risultato per 2: MIX = (SAMP1 + SAMP2) / 2.

Quando si sommano algebricamente due byte, è possibile che il risultato sia
maggiore di 127 (ad esempio, se entrambi sono 127, la somma sarà 254), e,
pertanto, non esprimibile con un numero ad 8 bit con segno, per cui è
necessario lavorare a word, per calcolare la media, e le word devono anch'esse
rispecchiare il segno dei byte originali: per questo motivo abbiamo esteso
il segno del byte alla word per fare la somma algebrica con ADD.W.
Nella ruotine "MixSamples" abbiamo adottato un ulteriore particolare per
incrementare la qualità e la precisione di mixing: l'ARROTONDAMENTO.
Una volta fatta la somma, è necessario dividere per 2, affinchè i valori
ritornino nel range di 8 bit con segno (* bisogna dividere tutti i valori per
2, non omettere quelli che sono compresi tra -128 e 127 anche solo dopo aver
fatto l'ADD: i campioni NON SAREBBERO PIU' PROPORZIONALI ! *); tale divisione
viene eseguita velocemente dall'ASR, che shifta a destra (di 1, in questo caso)
* MANTENENDO il segno a sinistra *: l'ultimo bit che esce da destra dal
registro shiftato è contenuto nel flag X (eXtend) della CPU; ora quel bit
è come una sorta di "valore oltre la virgola" che sprime l'approssimazione
dell'"intero" contenuto nel registro: aggiungento il contenuto del flag X
all'intero si arrotondano tutti i numeri originariamente dispari al numero
succesivo. Per sempio: 17 + 6 = 23, 23 / 2 = 11.5 (=%x.1) = 12 (arrotondato);
od ancora: 11 + 23 = 34, 34 / 2 = 17 (%x.0) = 17 (arrotondato).

N.B.:	avete notato che il volume (inteso come livello medio dei campioni)
	del sample mixato è inferiore alla resa dei 2 sample letti
	contemporaneamente ? Come mai ? La risposta alla prossima puntata...
