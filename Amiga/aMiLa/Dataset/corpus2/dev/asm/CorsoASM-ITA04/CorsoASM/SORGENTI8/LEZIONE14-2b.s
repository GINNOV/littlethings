
; Lezione14-2b.s	** SUONARE UN'ARMONICA A VARIE NOTE 2 **


	SECTION	Armonica2b,CODE

Start:
	move.l	4.w,a6
	jsr	-$78(A6)		; _LVODisable
	bset	#1,$bfe001		; Spegne il filtro passa-basso
	lea	$dff000,a6
	move.w	$2(a6),d7		; dmaconr - Salva DMA dell'OS

	move.l	#armonica,$a0(a6)	; AUD0LCH.w+AUD0LCL.w=AUD0LC.l
	move.w	#16/2,$a4(a6)		; 16 bytes/2=8 word di dati (AUD0LEN)

	move.l	#1<<16!2,d0		; suona un RE3
	moveq	#16,d1			; lunghezza=16 byte
	bsr.s	note2per
	move.w	d0,$a6(a6)		; AUD0PER col risultato

	move.w	#64,$a8(a6)		; AUD0VOL al massimo (0 dB)
	move.w	#$8201,$96(a6)		; accende AUD0 DMA in DMACONW

WLMB:	btst	#6,$bfe001		; aspetta il tasto sinistro del mouse
	bne.s	WLMB

	or.w	#$8000,d7		; accende il bit 15 (SET/CLR)
	move.w	#$0001,$96(a6)		; dmacon - spegne aud0
	move.w	d7,$96(a6)		; dmacon - reimposta DMA dell'OS
	move.l	4.w,a6
	jsr	-$7e(a6)		; _LVOEnable
	rts

******************************************************************************
;			« Note To Period »
;
; Calcola il periodo da inserire in AUDxPER data la nota e l'ottava
;
; d0hi.w  = nota (0[DO]..6[SI])
; d0lo.w  = ottava (0[1]..3[4])
; d1.w	  = lunghezza armonica (in byte)
******************************************************************************

Clock	equ	3546895
DO1	equ	131			; frequenza [Hz] del DO 1a ottava

Note2Per:
	move.w	#do1,d2			; d2.w=DO1
	lsl.w	d0,d2			; d2.w=DOx (secondo l'ottava in d0lo.w)
	swap	d0			; d0lo.w=d0hi.w
	add.w	d0,d0			; d0.w=d0.w*4
	add.w	d0,d0			; per offset di longword da NOTES
	mulu.w	notes(pc,d0.w),d2	; d2.l=DOx*num
	divu.w	notes+2(pc,d0.w),d2	; d2.l=DOx*num/den=frequenza nota
	mulu.w	d1,d2			; d2.l=freq. nota*lunghezza=freq. camp.
	move.l	#clock,d0		; d0.l=costante di clock
	divu.w	d2,d0			; d0.w=clock/freq. camp.
	rts				; [d0.w=periodo di campionamento]

Notes:
DO:	dc.w	1,1
RE:	dc.w	9,8
MI:	dc.w	5,4
FA:	dc.w	4,3
SOL:	dc.w	3,2
LA:	dc.w	5,3
SI:	dc.w	15,8


******************************************************************************

	SECTION	Sample,DATA_C	;venendo letta dal DMA deve essere in CHIP

	; Armonica di 16 valori creata col'IS del trash'm-one

Armonica:
	DC.B	$19,$46,$69,$7C,$7D,$6A,$47,$1A,$E8,$BB,$97,$84,$83,$95,$B8,$E5

	END

******************************************************************************

Come spiegato nel testo della lezione, ad ogni ottava c'e' un RADDOPPIAMENTO
di frequenza, quindi, se il DO della prima ottava ha 131 Hz, il DO2 ha 262 Hz,
il DO3 524 Hz, ecc; all'interno della scala ci sono dei rapporti ben precisi
tra le frequenze delle 7 note: DO=1, RE=9/8, MI=5/4, FA=4/3, SOL=3/2, LA=5/3,
SI=15/8 (ed il DO successivo =2); avendo questa tabella e' assai semplice
calcolarsi la frequenza di una nota qualsiasi di un'ottava qualsiasi partendo
da una data nota di una data ottava.

La subroutine "Note2Per" vuole, come parametri in entrata: d0 con la nota (da 0
per il DO al 6 per il SI) sulla word alta, e l'ottava (da 0 per la prima a 3
per la quarta) sulla bassa, e d1, con la lunghezza in byte del sample.
Essa calcola il periodo di campionamento da inserire nei registri AUDxPER
solamente sapendo la frequenza di un DO1 e la nota desiderata.
Come funziona ? Semplice: innanzitutto, notate che i rapporti tra le note
rispetto al DO di ogni scala sono stati inseriti come dati di word, con
la prima che indica il numeratore della frazione e la seconda che ne indica il
denominatore; la routine, per prima cosa, raddoppia la frequenza del DO1 di
partenza tante volte quante sono le ottave espresse nella word bassa del
parametro d0, semplicemente shiftando a sinistra (moltiplicando *2 ad ogni
singolo shift) il valore 132 (frequenza del DO1) di tanti bit quanto il
valore in d0lo.w; poi, in base alla nota specificata in d0hi.w, preleva da
Notes+d0hi.w*4 un longword avente nella word alta il numeratore ed in quella
bassa il denominatore della frazione che indica il rapporto della nota
desiderata all'interno della scala dal DO relativo (DO=1/1); in seguito,
calcola la frequenza della nota dell'ottava voluta moltiplicando la frazione
per la frequenza del DO dell'ottava stessa, e, quindi, moltiplicando questa
per il numeratore della frazione (word alta) e dividendo poi il tutto per
il denominatore (word bassa); infine, ottenuta la frequenza esatta, viene
calcolato il periodo di campionamento affinche' il sample di lunghezza d1.w
venga letto INTERAMENTE alla frequenza della nota (come si diceva negli esempi
precedenti, non calcoliamo il periodo di campionamento in lettura derivato
dal numero di byte al secondo che devono essere letti, ma il periodo di
campionamento derivato dal numero di volte che TUTTA l'armonica deve venir
letta in 1 secondo, pari al prodotto tra la frequenza e la lunghezza in byte
dell'onda: un valore ASSAI maggiore !), dividendo la costante di clock per
il prodotto tra la lunghezza del sample e la frequenza della nota.

Se, per esempio, vogliamo suonare un SOL2, dobbiamo fornire il valore 4 (5a
nota) nella word alta di d0 ed 1 (2a ottava) in quella bassa.
La frequenza della nota sara':
			       ((132 * 2^ottava) * 3)/2
				  |		   /  \
				 DO1             num  den
				 \____________/
					|
				       DOx

** In sostanza, la ruotine prima calcola il DO dell'ottava giusta, poi ne
calcola i 3/2 ("tre mezzi") **.
 
N.B.:	cosi' come'e', la routine "Note2Per" ha una limitazione: come dovreste
	sapere il 68000 effettua moltiplicazioni 16bit*16bit=32bit e divisioni
	32bit/16bit=16bit (il resto sulla word alta del risultato), percio'
	non e' possibile suonare sample troppo lunghi ad una frequenza troppo
	alta, semplicemente perche' il prodotto tra lunghezza e frequenza deve
	essere diviso per la costante di clock, e quindi, il divisore del
	DIVU deve stare in una word (senza segno, per fortuna).
	** In pratica, pero', questa limitazione non danneggia nessuno, infatti
	la velocita' di lettura = freq della nota * lunghezza del sample non
	puo' superare i 28836 Hz, valore che sta' comodamente dentro un word:
	NON USATE DUNQUE FREQUENZE TROPPO ALTE PER SAMPLE TROPPO LUNGHI **
