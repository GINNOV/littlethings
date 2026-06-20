
; Lezione14-3a.s	** TONI E SEMITONI DI PRECISIONE **


	SECTION	Toni,CODE

Start:
	move.l	4.w,a6
	jsr	-$78(A6)		; _LVODisable
	bset	#1,$bfe001		; Spegne il filtro passa-basso
	lea	$dff000,a6
	move.w	$2(a6),d7		; dmaconr - Salva DMA dell'OS

	move.l	#armonica,$a0(a6)	; AUD0LCH.w+AUD0LCL.w=AUD0LC.l
	move.w	#16/2,$a4(a6)		; 16 bytes/2=8 word di dati (AUD0LEN)

	move.l	#12*2+2,d0		; RE3
	moveq	#16,d1
	bsr.s	halftone2per
	move.w	d0,$a6(a6)		; AUD0PER

	move.w	#64,$a8(a6)		; AUD0VOL al massimo (0 dB)
	move.w	#$8001,$96(a6)		; accende AUD0 DMA in DMACONW

WLMB:
	btst	#6,$bfe001		;aspetta il tasto sinistro del mouse
	bne.s	WLMB

	or.w	#$8000,d7		; accende il bit 15 (SET/CLR)
	move.w	#$0001,$96(a6)		; spegne il DMA
	move.w	d7,$96(a6)		; dmacon - reimposta DMA dell'OS
	move.l	4.w,a6
	jsr	-$7e(a6)		; _LVOEnable
	rts

******************************************************************************
;			« HalfTone To Period »
;
; Calcola il periodo da inserire in AUDxPER data il semitono a partire dal DO1
;
; d0.w   = semitono (a partire dal DO1=0)
; d1.w   = lunghezza armonica (in byte)
******************************************************************************

Clock	equ	3546895
DO1	equ	131			; Frequenza [Hz] del DO 1a ottava

HalfTone2Per:
	divu.w	#12,d0
	move.w	#do1,d2
	lsl.w	d0,d2
	swap	d0
	add.w	d0,d0
	add.w	d0,d0
	mulu.w	halftones(pc,d0.w),d2
	divu.w	halftones+2(pc,d0.w),d2
	move.l	#clock,d0
	mulu.w	d2,d1
	divu.w	d1,d0
	rts			; [d0.w=periodo di campionamento]

HalfTones:
	dc.w	10000,10000	;DO=1.0
	dc.w	10595,10000	;DO#=1.0595
	dc.w	11225,10000	;RE=1.1225
	dc.w	11892,10000	;RE#=1.1892
	dc.w	12599,10000	;MI=1.2599
	dc.w	13348,10000	;FA=1.3348
	dc.w	14142,10000	;FA#=1.4142
	dc.w	14983,10000	;SOL=1.4983
	dc.w	15874,10000	;SOL#=1.5874
	dc.w	16818,10000	;LA=1.6818
	dc.w	17818,10000	;LA#=1.7818
	dc.w	18877,10000	;SI=1.8877

******************************************************************************

	SECTION	Sample,DATA_C	;venendo letta dal DMA deve essere in CHIP

	; Armonica di 16 valori creata col'IS del trash'm-one

Armonica:
	DC.B	$19,$46,$69,$7C,$7D,$6A,$47,$1A,$E8,$BB,$97,$84,$83,$95,$B8,$E5

	END

******************************************************************************

Questo sorgente non differisce di molto rispetto al precedente, in quanto
include una piccola routine che calcola il periodo di campionamento in base
ad una nota data; l'unica differenza e' che ora potrete generare non solo le 7
note di una scala di varie ottave, ma anche le note dei "tasti neri" del
pianoforte, ovvero i DIESIS(#)/BEMOLLE(b): in poche parole, non siete limitali
ai soli toni, ma avete la possibilita' di suonare anche i SEMITONI.
Innanzitutto, una differenza salta all'occhio: i valori della tabella
"HalfTones" sono assai piu' grandi di quelli della tabella "Notes" dell'esempio
precedente, e questo per garantire una maggiore precisione: infatti, le due
word indicano rispettivamente NUMERATORE e DENOMINATORE della frazione che
indica il rapporto tra una nota ed il DO in una scala, ed il rapporto, appunto,
NON cambia. Prendiamo, a esempio, il SOL: in "Notes" il rapporto e' 3/2 = 1.5,
in "HalfTones" e' pari a 14983/10000 = 1.4983; come vedete il rapporto
e' quasi uguale (lo scarto e' TRASCURABILE).
In "Notes" ho riportato le frazioni "classiche" che si trovano su molti
libri di fisica acustica e che hanno il vantaggio di avere numeratori e
denominatori piccoli e di facile memorizzazione; i valori di "HalfTones",
invece, oltre a riportare i rapporti di tutte le note della scala di semitono
in semitono, hanno una precisione di 4 cifre decimali oltre la "virgola" (che
e' simulata moltiplicando per numeri molto grandi e poi dividento per
10^numero di cifre decimali), ovvero fino ai decimillesimi.
La subroutine "HalfTone2Per" funzione grossomodo come quella "Note2Per";
l'unica differenza sta' nell'esprimere il parametro in ingresso: questa
volta e' necessario indicare il semitono desiderato a partire dal DO1.
Per cui, se vogliamo suonare un FA1 dovremo impostare d0.w=5, poiche'
tra il DO1 ed il FA1 ci sono 5 semitoni di differenza.

In musica, 1 tono = 2 semitoni, ed ogni scala ha 6 toni = 12 semitoni;
tra una nota e l'altra c'e' 1 tono, esclusi gli intervalli di frequenza
tra MI e FA, e tra SI e DO dell'ottava dopo che sono pari ad 1 solo semitono.

Visto che ad ogni ottava e' necessario raddoppiare la frequenza, l'incremento
di frequenza delle note - all'interno di una scala ed oltre - NON e' costante,
ma ESPONENZIALE in base 2.
Per cui, il calcolo dei rapporti delle note all'interno di una scala non e'
poi tanto semplice come potrebbe sembrare: sapendo che l'intervallo dei
rapporti in una scala di 12 semitoni e' pari a 1 (da 1 del primo DO a 2 del
DO dell'ottava successiva), ogni semitono dista dall'altro 1/12 nell'asse
delle ascisse di un grafico cartesiano (x,y) che presenta la funzione
esponenziale: Y = 2^X; consideriamo l'intervallo 0<=X<=1 abbiamo nelle
ordinate un ramo di curva 2^0<=Y<=2^1 = 1<=Y<=2; ora, ad ogni 12esimo
da X=0 calcoliamo il relativo valore in Y, per 12 volte: Y = 2^(1/12),
Y = 2^(2/12), Y = 2^(3/12), e cosi' via fino a Y=2^(12/12) = 2, che
corrisponde al rapporto del 12esimo semitono, ovvero del DO dell'ottava
successiva; ognuno dei valori decimali ottenuti corrisponde al valore
da moltiplicare alla frequenza del DO dell'ottava desiderata per ottenere
la frequenza della nota richiesta nell'ottava medesima, ed e' riconducibile
ad una frazione (anzi, DEVE essere ricondotto ad una frazione con numeri
non decimali perche' il 68000 possa calcolare a numeri interi "simulando"
la virgola).
Per esempio, per sapere il rapporto tra la frequenza di un LA# ed in DO (=1/1):
Y = 2^(10/12) = 2^0.8333 (...periodico...) = 1.7818 (arrotondando); tale numero
decimale e' facilmente riconducibile alla frazione 17818/10000 (si tratta
effettivamente di 17818 decimillesimi)
Ora, se, per esempio, desideriamo un LA3#: DO3 = 131 * 2^(3-1) = 131 * 2 * 2 =
= 131 * 4 = 524 Hz; LA3# = (524 * 17818)/10000 = 933 Hz.

