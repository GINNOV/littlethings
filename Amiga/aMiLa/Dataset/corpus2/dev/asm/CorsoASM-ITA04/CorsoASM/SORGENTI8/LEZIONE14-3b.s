
; Lezione14-3b.s	** ACCORDI MAGGIORI DI ARMONICHE A 4 VOCI **


	section	arm4,code	

Start:
	move.l	4.w,a6
	jsr	-$78(A6)		; _LVODisable
	bset	#1,$bfe001		; Spegne il filtro passa-basso
	lea	$dff000,a6
	move.w	$2(a6),d7		; dmaconr - Salva DMA dell'OS

	move.l	#armonica,$a0(a6)	; AUD0LCH.w+AUD0LCL.w=AUD0LC.l
	move.l	#armonica,$b0(a6)	; AUD1LCH.w+AUD1LCL.w=AUD1LC.l
	move.l	#armonica,$c0(a6)	; AUD2LCH.w+AUD2LCL.w=AUD2LC.l
	move.l	#armonica,$d0(a6)	; AUD3LCH.w+AUD2LCL.w=AUD3LC.l
	move.w	#16/2,$a4(a6)		; 16 bytes/2=8 word di dati (AUD0LEN)
	move.w	#16/2,$b4(a6)		; 16 bytes/2=8 word di dati (AUD1LEN)
	move.w	#16/2,$c4(a6)		; 16 bytes/2=8 word di dati (AUD2LEN)
	move.w	#16/2,$d4(a6)		; 16 bytes/2=8 word di dati (AUD3LEN)

	moveq	#16,d1
	moveq	#12*1+0,d2		;DO2 (accordo di DO)

	move.l	d2,d0
	bsr.s	halftone2per
	move.w	d0,$a6(a6)		; AUD0PER
	addq.w	#2*2,d2			; + 2 toni = MI
	move.l	d2,d0
	bsr.s	halftone2per
	move.w	d0,$b6(a6)		; AUD1PER
	addq.w	#2+1,d2			; + 1 tono + 1 semitono = SOL
	move.l	d2,d0
	bsr.s	halftone2per
	move.w	d0,$c6(a6)		; AUD2PER
	addq.w	#2+1,d2			; + 1 tono + 1 semitono = LA#
	move.l	d2,d0
	bsr.s	halftone2per
	move.w	d0,$d6(a6)		; AUD3PER

	move.w	#64,$a8(a6)		; AUD0VOL al massimo (0 dB)
	move.w	#64,$b8(a6)		; AUD1VOL al massimo (0 dB)
	move.w	#64,$c8(a6)		; AUD2VOL al massimo (0 dB)
	move.w	#64,$d8(a6)		; AUD3VOL al massimo (0 dB)
	move.w	#$800f,$96(a6)		; Accende AUD0-AUD3 DMA in DMACONW

WLMB:
	btst	#6,$bfe001		;aspetta il tasto sinistro del mouse
	bne.s	WLMB
	or.w	#$8000,d7		; accende il bit 15 (SET/CLR)
	move.w	#$000f,$96(a6)		; spegne i DMA
	move.w	d7,$96(a6)		; reimposta DMA dell'OS
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
	move.l	d2,-(SP)
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
	divu.w	d1,d0		; DIVISION BY ZERO!!!
	move.l	(SP)+,d2
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

Questo sorgente non differisce per nulla rispetto a quello precedente.
L'unica novita' introdotta e' stata l'uso di tutte le voci hardware del chip
sonoro dell'Amiga...niente di complicato, in realta': per suonare lo stesso
sample a frequenza diversa e' sufficiente impostare tutti i registri
AUDxLC, AUDxLEN ed AUDxVOL con il medesimo valore per tutti i canali, e
variare solo i periodi per gli AUDxPER.

In musica, per creare un ACCORDO MAGGIORE a 3 o piu' note (noi lo abbiamo
fatto a 4, tanto per non lasciar oziare l'ultima voce...), bisogna suonare
CONTEMPORANEAMENTE 3 tutte le note giuste che formano l'accordo.
Ecco lo schema generale:

                               ************ ACCORDI MAGGIORI ***********
                               +------+--------------------------------+
                               | NOTA |       TONALITA'                |
                               +------+--------------------------------+
                               |  1a  |  nota di base dell'accordo     |
                               |  2a  |  + 2 toni = 4 semitoni         |
                               |  3a  |  + 1 tono e mezzo = 3 semitoni |
                               |  4a  |  + 1 tono e mezzo = 3 semitoni |
                               +------+--------------------------------+

Per esempio, per l'accordo di MI a 3 voci: MI + SOL# + SI; per l'accordo di
LA a 4 voci: LA + DO# + MI + SOL.

