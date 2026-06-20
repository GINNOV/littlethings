
; Lezione9e3.s	Spostamento orizzontale completo con shift + cambiamento di
;		posizione della destinazione (scatti di 2 bytes = 16 pixel)

	SECTION	CiriCop,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup1.s"	; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001111000000	; copper,bitplane,blitter DMA


START:
;	Puntiamo la PIC "vuota"

	MOVE.L	#BITPLANE,d0	; dove puntare
	LEA	BPLPOINTERS,A1	; puntatori COP
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

	lea	$dff000,a5		; CUSTOM REGISTER in a5
	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

	moveq	#0,d1			; Coordinata orizzontale a 0
	move.w	#(320-32)-1,d7		; Muove per 320 pixel MENO la larghezza
					; reale del BOB, per fare in modo che
					; il suo primo pixel a sinistra si
					; fermi quando quello a destra arriva
					; alla fine dello schermo.
Loop:
	cmp.b	#$ff,$6(a5)	; VHPOSR - aspetta la linea $ff
	bne.s	loop
Aspetta:
	cmp.b	#$ff,$6(a5)	; ancora linea $ff?
	beq.s	Aspetta

;	  \\ ,\\  /, ,,//
;	   \\\\\X///////
;	    \¬¯___  __/
;	   _;=(  ©)(®_)
;	  (, _ ¯T¯  \¬\
;	   T /\ '   ,)/
;	   |('/\_____/__
;	   l_¯         ¬\
;	    _T¯¯¯T¯¯¯¯¯¯¯
;	 /¯¯¬l___¦¯¯¬\
;	/___,  °  ,___\
;	¯/¯/¯  °__T\¬\¯
;	(  \___/ '\ \ \
;	 \_________) \ \
;	    l_____ \  \ \
;	    / ___¬T¯   \ \
;	   / _/ \ l_    ) \
;	   \ ¬\  \  \  ())))
;	  __\__\  \  )  ¯¯¯
;	 (______)  \/\ xCz
;	           / /
;	          (_/

	lea	bitplane,a0	; destinazione in a0
	move.w	d1,d0
	and.w	#$000f,d0	; Si selezionano i primi 4 bit perche' vanno
				; inseriti nello shifter del canale A 
	lsl.w	#8,d0		; I 4 bit vengono spostati sul nibble alto
	lsl.w	#4,d0		; della word... (8+4= shift di 12 bit)
	or.w	#$09f0,d0	; ...giusti per inserirsi nel registro BLTCON0
				; Qua mettiamo $f0 nei minterm per copia da
				; sorgente A a destinazione D e abilitiamo
				; ovviamente i canali A+D con $0900 (bit 8
				; per D e 11 per A). Ossia $09f0 + shift.
	move.w	d1,d2
	lsr.w	#3,d2		; (equivalente ad una divisione per 8)
				; arrotonda ai multipli di 8 per il puntatore
				; allo schermo, ovvero agli indirizzi dispari
				; (anche ai byte, quindi)
				; x es.: un 16 come coordinata diventa il
				; byte 2
	and.w	#$fffe,d2	; escludo il bit 0
	add.w	d2,a0		; Somma all'indirizzo del bitplane, trovando
				; l'indirizzo giusto di destinazione
	addq.w	#1,d1		; Aggiungi 1 alla coordinata orizzontale

	btst	#6,2(a5) ; dmaconr
WBlit1:
	btst	#6,2(a5) ; dmaconr - attendi che il blitter abbia finito
	bne.s	wblit1

; ora, come spiegato nella teoria, cogliamo l' occasione per apportare una
; modifica: scriviamo i valori in registri ADIACENTI con un singolo 'move.l'

	move.l	#$01000000,$40(a5)	; BLTCON0 + BLTCON1
	move.w	#$0000,$66(a5)
	move.l	#bitplane,$54(a5)
	move.w	#(64*256)+20,$58(a5)	; provate a togliere questa linea
					; e lo schermo non verra' pulito,
					; dunque il pesce lascera' la "scia"

	btst	#6,2(a5) ; dmaconr
WBlit2:
	btst	#6,2(a5) ; dmaconr - attendi che il blitter abbia finito
	bne.s	wblit2

	move.l	#$ffffffff,$44(a5)	; BLTAFWM e BLTALWM li spieghiamo dopo
	move.w	d0,$40(a5)		; BLTCON0 (usa A+D)
	move.w	#$0000,$42(a5)		; BLTCON1 (nessun modo speciale)
	move.l	#$00000024,$64(a5)	; BLTAMOD (=0) + BLTDMOD (=40-4=36=$24)
	move.l	#figura,$50(a5)		; BLTAPT  (fisso alla figura sorgente)
	move.l	a0,$54(a5)		; BLTDPT  (linee di schermo)
	move.w	#(64*6)+2,$58(a5)	; BLTSIZE (via al blitter !)
					; blittiamo 2 word, la seconda delle
					; quali e' nulla per permettere
					; lo shift

	btst	#6,$bfe001		; mouse premuto?
	beq.s	quit

	dbra	d7,loop

Quit:
	rts

;****************************************************************************

	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$8E,$2c81	; DiwStrt
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$38		; DdfStart
	dc.w	$94,$d0		; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

	dc.w	$100,$1200	; BplCon0 - 1 bitplane LowRes

BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane

	dc.w	$0180,$000	; color0
	dc.w	$0182,$eee	; color1
	dc.w	$FFFF,$FFFE	; Fine della copperlist

;****************************************************************************

; Il pesciolino:

Figura:
	dc.w	%1000001111100000,0
	dc.w	%1100111111111000,0
	dc.w	%1111111111101100,0
	dc.w	%1111111111111110,0
	dc.w	%1100111111111000,0
	dc.w	%1000001111100000,0

;****************************************************************************

	SECTION	PLANEVUOTO,BSS_C	

BITPLANE:
	ds.b	40*256		; bitplane azzerato lowres

	end

;****************************************************************************

In questo esempio spostiamo la nostra figura di un numero arbitrario di pixel.
La coordinata orizzontale della figura e` memorizzata in D1. Tale coordinata
viene divisa per 8 in modo da calcolare l'indirizzo di memoria della word
a cui essa appartiene. I 4 bit meno significativi della coordianta, invece,
sono il valore di shift, come spiegato nella lezione.

