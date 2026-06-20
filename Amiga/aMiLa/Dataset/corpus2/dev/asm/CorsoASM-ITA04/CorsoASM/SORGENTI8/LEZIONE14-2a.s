
; Lezione14-2a.s	** SUONARE UN'ARMONICA A VARIE NOTE **


	SECTION	Armonica2,CODE

Start:
	move.l	4.w,a6
	jsr	-$78(A6)		; _LVODisable

	bset	#1,$bfe001		; Spegne il filtro passa-basso

	lea	$dff000,a6
	move.w	$2(a6),d7		; dmaconr - Salva DMA dell'OS

Clock	equ	3546895

	move.l	#armonica,$a0(a6)	; AUD0LCH.w+AUD0LCL.w=AUD0LC.l
	move.w	#16/2,$a4(a6)		; 16 bytes/2=8 word di dati (AUD0LEN)
	move.l	#clock/16,d1		; 1/16 = un 16esimo del clock
	divu.w	do3(pc),d1		; <<< CAMBIATE IL PRIMO OPERANDO DI
					;  QUESTO MOVE PER GENERARE ALTRE
					; NOTE >>>
	move.w	d1,$a6(a6)		; AUD0PER col periodo calcolato
	move.w	#64,$a8(a6)		; AUD0VOL al massimo (0 dB)
	move.w	#$8001,$96(a6)		; Accende AUD0 DMA in DMACONW

WLMB:	btst	#6,$bfe001		; Aspetta il tasto sinistro del mouse
	bne.s	WLMB

	or.w	#$8000,d7		; accende il bit 15 (SET/CLR)
	move.w	#$0001,$96(a6)		; dmacon - spegne aud0
	move.w	d7,$96(a6)		; dmacon - reimposta DMA dell'OS
	move.l	4.w,a6
	jsr	-$7e(a6)		; _LVOEnable
	rts


DO3:	dc.w	528		;frequenze delle note
RE3:	dc.w	528*9/8
MI3:	dc.w	528*5/4
FA3:	dc.w	528*4/3
SOL3:	dc.w	528*3/2
LA3:	dc.w	528*5/3
SI3:	dc.w	528*15/8
DO4:	dc.w	528*2


******************************************************************************

	SECTION	Sample,DATA_C	;venendo letta dal DMA deve essere in CHIP

	; Armonica di 16 valori creata col'IS del trash'm-one

Armonica:
	DC.B	$19,$46,$69,$7C,$7D,$6A,$47,$1A,$E8,$BB,$97,$84,$83,$95,$B8,$E5

	END

******************************************************************************

Al periodo 1/16 del clock (= 35468095/16) si leggerebbe l'armonica ad 1 Hz,
poiche' e' lunga 16 byte, e - come dicevamo nel primo sorgente -, leggendone
16 al secondo, si legge tutta l'armonica 1 volta al secondo (= 1 Hz, appunto);
dividendo il periodo 1/16 per la frequenza della nota da suonare contenuta
in RAM alla relativa label, si moltiplica la frequenza di lettura di 1 Hz
per la frequenza della nota, appunto, facendo leggere all'hardware l'intera
armonica piu' volte al secondo.

Sarebbe stato possibile raggiungere il medesimo risultato da imserire in 
AUD0PER anche con il seguende codice:

	[...]
	move.l	#clock,d1		; costante di clock
	move.w	do3(pc),d2		; ...o qualsiasi altra frequenza...
	mulu.w	#16,d2			; d2.l = 16*frequenza della nota
	divu.w	d2,d1			; d1.w = clock/(16*freq)
	move.w	d1,$a6(a6)		; imposta AUD0PER
	[...]

