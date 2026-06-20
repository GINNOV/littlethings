
; Lezione10i1.s	Sine-scroller da 2 pixel
;		Tasto sinistro per uscire.

	SECTION	CiriCop,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup1.s"	; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001111000000	; copper,bitplane,blitter DMA


START:

	MOVE.L	#BITPLANE,d0	; dove puntare
	LEA	BPLPOINTERS,A1	; puntatori COP

	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0

	lea	$dff000,a5		; CUSTOM REGISTER in a5
	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

	lea	testo(pc),a0		; punta al testo dello scrolltext

mouse:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$10800,d2	; linea da aspettare = $108
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $108
	BNE.S	Waity1
Waity2:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $108
	Beq.S	Waity2

	bsr.s	printchar	; routine che stampa i nuovi chars
	bsr.s	Scorri		; esegui la routine di scorrimento

	bsr.w	CancellaSchermo	; pulisci lo schermo
	bsr.w	Sine		; esegui il sine-scroll

	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	mouse		; se no, torna a mouse2:
	rts

;****************************************************************************
; Questa routine stampa un carattere. Il carattere viene stampato in una
; parte di schermo invisibile.
; A0 punta al testo da stampare.
;****************************************************************************

PRINTCHAR:
	subq.w	#1,contatore	; diminuisci il contatore di 1
	bne.s	NoPrint		; se e` diverso da 0, non stampiamo,
	move.w	#16,contatore	; altrimenti si; reinizializza il contatore

	MOVEQ	#0,D2		; Pulisci d2
	MOVE.B	(A0)+,D2	; Prossimo carattere in d2
	bne.s	noreset		; Se e` diverso da 0 stampalo,
	lea	testo(pc),a0	; altrimenti ricomincia il testo daccapo
	MOVE.B	(A0)+,D2	; Primo carattere in d2
noreset
	SUB.B	#$20,D2		; TOGLI 32 AL VALORE ASCII DEL CARATTERE, IN
				; MODO DA TRASFORMARE, AD ESEMPIO, QUELLO
				; DELLO SPAZIO (che e' $20), in $00, quello
				; DELL'ASTERISCO ($21), in $01...
	ADD.L	D2,D2		; MOLTIPLICA PER 2 IL NUMERO PRECEDENTE,
				; perche` ogni carattere e` largo 16 pixel
	MOVE.L	D2,A2

	ADD.L	#FONT,A2	; TROVA IL CARATTERE DESIDERATO NEL FONT...

	btst	#6,$02(a5)	; dmaconr - aspetta che il blitter finisca
waitblit:
	btst	#6,$02(a5)
	bne.s	waitblit

	move.l	#$09f00000,$40(a5)	; BLTCON0: copia da A a D
	move.l	#$ffffffff,$44(a5)	; BLTAFWM e BLTALWM li spieghiamo dopo

	move.l	a2,$50(a5)			; BLTAPT: indirizzo font
	move.l	#buffer+40,$54(a5)		; BLTDPT: indirizzo bitplane
						; fisso, fuori dalla parte
						; visibile dello schermo.
	move	#120-2,$64(a5)			; BLTAMOD: modulo font
	move	#42-2,$66(a5)			; BLTDMOD: modulo bit planes
	move	#(20<<6)+1,$58(a5) 		; BLTSIZE: font 16*20
NoPrint:
	rts

contatore
	dc.w	16

;****************************************************************************
; Questa routine fa scorrere il testo verso sinistra
;****************************************************************************

Scorri:

; Gli indirizzi sorgente e destinazione sono uguali.
; Shiftiamo verso sinistra, quindi usiamo il modo discendente.

	move.l	#buffer+((21*20)-1)*2,d0	; ind. sorgente e
						; destinazione
ScorriLoop:
	btst	#6,2(a5)		; aspetta che il blitter finisca
waitblit2:
	btst	#6,2(a5)
	bne.s	waitblit2

	move.l	#$19f00002,$40(a5)	; BLTCON0 e BLTCON1 - copia da A a D
					; con shift di un pixel

	move.l	#$ffff7fff,$44(a5)	; BLTAFWM e BLTALWM
					; BLTAFWM = $ffff - passa tutto
					; BLTALWM = $7fff = %0111111111111111
					;   cancella il bit piu` a sinistra
; carica i puntatori

	move.l	d0,$50(a5)			; bltapt - sorgente
	move.l	d0,$54(a5)			; bltdpt - destinazione

; facciamo scorrere un immagine larga tutto lo schermo, quindi
; il modulo e` azzerato.

	move.l	#$00000000,$64(a5)		; bltamod e bltdmod 
	move.w	#(20*64)+21,$58(a5)		; bltsize
						; altezza 20 linee, largo 21
	rts					; words (tutto lo schermo)


;****************************************************************************
; Questa routine realizza l'effetto sine-scroll. Attenzione a BLTALWM, perche'
; e' il registro dove ogni volta selezioniamo la "fettina" o "striscina"
; verticale su cui operare.
;****************************************************************************

;	  ,-~~-.___.
;	 / |  '     \
;	(  )         0
;	 \_/-, ,----'
;	    ====           //
;	   /  \-'~;    /~~~(O)
;	  /  __/~|   /       |
;	=(  _____| (_________|   W<

Sine:
	lea	buffer,a2		; puntatore al buffer contenente
					; lo scrolltext
	lea	bitplane,a1		; puntatore alla destinazione

	lea	Sinustab(pc),a3		; indirizzo tabella seno, con valori
					; gia' moltiplicati * 42, per poterli
					; addizionare direttamente all'address
					; del bitplane.

	move.w	#$C000,d5		; valore iniziale maschera
	moveq	#20-1,d6		; ripeti per tutte le word dello schero
FaiUnaWord:
	moveq	#8-1,d7			; routine da 2 pixel. Per ogni word
					; ci sono 8 "fettine" da 2 pixel
FaiUnaColonna:
	move.w	(a3)+,d0		; legge un valore dalla tabella
	cmp.l	#EndSinustab,a3		; se siamo alla fine della tabella
	blo.s	nostartsine		; ricomincia da capo
	lea	sinustab(pc),a3
nostartsine:
	move.l	a1,a4			; copia indirizzo bitplane
	add.w	d0,a4			; aggiunge la coordinata Y, offset
					; preso dalla sintab...

	btst	#6,2(a5)		; aspetta che il blitter finisca
waitblit_sine:
	btst	#6,2(a5)
	bne.s	waitblit_sine

	move.w	#$ffff,$44(a5)		; BLTAFWM
	move.w	d5,$46(a5)		; BLTALWM - contiene la maschera che
					; seleziona le "fettine" di scrolltext

	move.l	#$0bfa0000,$40(a5)	; BLTCON0/BLTCON1 - attiva A,C,D
					; D=A OR C

	move.w	#$0028,$60(a5)		; BLTCMOD=42-2=$28
	move.l	#$00280028,$64(a5)	; BLTAMOD=42-2=$28
					; BLTDMOD=42-2=$28

	move.l	a2,$50(a5)		; BLTAPT  (al buffer)
	move.l	a4,$48(a5)		; BLTCPT  (allo schermo)
	move.l	a4,$54(a5)		; BLTDPT  (allo schermo)
	move.w	#(64*20)+1,$58(a5)	; BLTSIZE (blitta un rettangolo
					; alto 20 righe e largo 1 word)

	ror.w	#2,d5			; spostati alla "fettina" successiva
					; va a destra e dopo l'ultima "fettina"
					; di una word ricomincia dalla prima
					; della word seguente.
					; per lo scroll da 2 pixel ogni
					; "fettina" e` larga 2 pixel

	dbra	d7,FaiUnaColonna

	addq.w	#2,a2			; punta alla word seguente
	addq.w	#2,a1			; punta alla word seguente
	dbra	d6,FaiUnaWord
	rts

; Questo e` il testo. con lo 0 si termina. Il font usato ha solo i caratteri
; maiuscoli, attenzione!

testo:
	dc.b	" ECCO COME SINUSCROLLARE... IL FONT E' DI 16*20 PIXEL!..."
	dc.b	" LO SCROLL AVVIENE CON TRANQUILLITA'...",0
	even

;****************************************************************************
; Questa routine cancella lo schermo mediante il blitter.
; Viene cancellata solo la parte di schermo sulla quale scorre il testo:
; dalla riga 130 alla riga 193
;****************************************************************************

CancellaSchermo:
	btst	#6,2(a5)
WBlit3:
	btst	#6,2(a5)		 ; attendi che il blitter abbia finito
	bne.s	wblit3

	move.l	#$01000000,$40(a5)	; BLTCON0 e BLTCON1: Cancella
	move	#$0000,$66(a5)		; BLTDMOD=0
	move.l	#bitplane+42*130,$54(a5)	; BLTDPT
	move.w	#(64*63)+20,$58(a5)	; BLTSIZE (via al blitter !)
					; cancella dalla riga 130
					; fino alla riga 193
	rts

;***************************************************************************
; Questa e` la tabella che contiene i valori delle posizioni verticali
; dello scrolltext. Le posizioni sono gia` moltiplicate per 42, quindi
; possono essere addizionate direttamente all'indirizzo del BITPLANE
;***************************************************************************

Sinustab:
	DC.W	$18C6,$191A,$1944,$1998,$19EC,$1A16,$1A6A,$1A94,$1AE8,$1B12
	DC.W	$1B3C,$1B66,$1B90,$1BBA,$1BBA,$1BE4,$1BE4,$1BE4,$1BE4,$1BE4
	DC.W	$1BBA,$1BBA,$1B90,$1B66,$1B3C,$1B12,$1AE8,$1A94,$1A6A,$1A16
	DC.W	$19EC,$1998,$1944,$191A,$18C6,$1872,$181E,$17F4,$17A0,$174C
	DC.W	$1722,$16CE,$16A4,$1650,$1626,$15FC,$15D2,$15A8,$157E,$157E
	DC.W	$1554,$1554,$1554,$1554,$1554,$157E,$157E,$15A8,$15D2,$15FC
	DC.W	$1626,$1650,$16A4,$16CE,$1722,$174C,$17A0,$17F4,$181E,$1872
EndSinustab:

;****************************************************************************

	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$8E,$2c81	; DiwStrt
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$38		; DdfStart
	dc.w	$94,$d0		; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2

	dc.w	$108,2		; Il bitplane e` largo 42 bytes, ma solo 40
				; bytes sono visibili, quindi il modulo
				; vale 42-40=2
;	dc.w	$10a,2		; Usiamo un solo bitplane, quindi BPLMOD2
				; non e` necessario

	dc.w	$100,$1200	; bplcon0 - 1 bitplanes lowres

BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane

	dc.w	$0180,$000	; color0
	dc.w	$0182,$f50	; color1

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;****************************************************************************

; Qui e` memorizzato il FONT di caratteri 16x20

FONT:
	incbin	"font16x20.raw"

;****************************************************************************

	SECTION	PLANEVUOTO,BSS_C

BITPLANE:
	ds.b	42*256		; bitplane azzerato lowres

Buffer:
	ds.b	42*20		; buffer invisibile dove viene scrollato
				; il testo 
	end

;****************************************************************************

In questo esempio vediamo un sine-scroll da 2 pixel. Le routine che stampano
i caratteri e che scrollano il testo sono le stesse della lezione9n1.s,
solo che disegnano in un buffer invisibile invece che sullo schermo.
La routine "Sine" realizza l'effetto. Essa blitta tutto il contenuto del buffer
sullo schermo, a "fettine" di 2 pixel. Per questo deve eseguire blittate larghe
1 word. Ogni colonna word contiene 8 "fettine" larghe 2 pixel. Quindi la
routine ha 2 cicli annidati: quello piu` interno effettua 8 bittate per copiare
tutta la colonna di word, mentre quello piu` esterno ripete quello interno per
tutte le colonne di word dello schermo. Per selezionare le "fettine"
all'interno della word si usa una maschera contenuta in D5. Dopo ogni blittata
la maschera viene fatta ruotare in modo da selezionare ogni volta una diversa
"fettina". Poiche` con la rotazione i bit che escono da un lato del registro
rientrano dall'altro, non c'e` bisogno di settare D5 ogni volta che i bit
ad 1 escono da destra.
Ogni fettina viene copiata ad una posizione y differente, letta da una tabella
sinusiodale.
La routine di cancellazione dello schermo cancella solo la parte interessata
dal disegno. Per calcolare quale sia la parte interessata, si devono
considerare la minima e la massima coordinata Y delle "fettine", e inoltre
che le "fettine" sono alte 20 pixel. Quindi la prima riga da cancellare e` 
la minima Y delle "fettine", mentre l'ultima riga e` data dalla somma della
massima Y e dell'altezza delle "fettine".

