
; Lezione10f2.s	Tanti BOB con sfondo "finto" e "double buffering"
;		Tasto sinistro per uscire.

	SECTION	bau,code

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup1.s"	; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001111000000	; copper,bitplane,blitter DMA


; costanti bordi.

Lowest_Floor	equ	200	; bordo in basso
Right_Side	equ	287	; bordo a destra	


START:
; i primi 3 planes vengono puntati dalla routine ScambiaBuffer

;	Puntiamo il quarto bitplane (lo sfondo)

	LEA	BPLPOINTERS,A0		; puntatori COP
	move.l	#SfondoFinto,d0		; indirizzo sfondo
	move.w	d0,30(a0)		; lo sfondo e` il bitplane 4
	swap	d0	
	move.w	d0,26(a0)		; scrivi word alta

	lea	$dff000,a5		; CUSTOM REGISTER in a5
	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

mouse:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$13000,d2	; linea da aspettare = $130, ossia 304
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $130 (304)
	BNE.S	Waity1

	bsr.w	ScambiaBuffer		; questa routine scambia i 2 buffer

	bsr.w	CancellaSchermo		; cancella lo schermo

	lea	Oggetto_1,a4		; indirizzo primo oggetto
	moveq	#6-1,d6			; 6 oggetti

Ogg_loop:
	bsr.s	MuoviOggetto		; muove il bob
	bsr.w	DisegnaOggetto		; disegna il bob

	addq.l	#8,a4			; punta al prossimo oggetto

	dbra	d6,Ogg_loop

	btst	#6,2(a5)
WBlit_coppermonitor:
	btst	#6,2(a5)
	bne.s	WBlit_coppermonitor

	move.w	#$aaa,$180(a5)		; copper monitor: colore grigio

	btst	#6,$bfe001		; tasto sinistro del mouse premuto?
	bne.s	mouse			; se no, torna a mouse:

	rts

;****************************************************************************
; Questa routine scambia i 2 buffer scambiando gli indirizzi nelle
; variabili VIEW_BUFFER e  DRAW_BUFFER.
; Inoltre aggiorna nella copperlist le istruzioni che caricano i registri
; BPLxPT, in modo che puntino al nuovo buffer da visualizzare.
;****************************************************************************

;	        |\__/,|   (`\
;	      _.|o o  |_   ) )
;	  ---(((---(((---------

ScambiaBuffer:
	move.l	draw_buffer(pc),d0		; scambia il contenuto
	move.l	view_buffer(pc),draw_buffer	; delle variabili
	move.l	d0,view_buffer			; in d0 c'e` l'indirizzo
						; del nuovo buffer
						; da visualizzare

; aggiorna la copperlist puntando i bitplanes del nuovo buffer da visualizzare

	LEA	BPLPOINTERS,A1	; puntatori COP
	MOVEQ	#3-1,D1		; numero di bitplanes
POINTBP:
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	ADD.L	#40*256,d0	; + lunghezza bitplane (qua e' alto 256 linee)
	addq.w	#8,a1
	dbra	d1,POINTBP

	rts

;****************************************************************************
; Questa routine muove un bob controllando che non superi i bordi
; A4 - punta alla struttura dati che contiene la posizione e la velocita`
;      del bob
;****************************************************************************

MuoviOggetto:
	move.w	(a4),d0			; posizione X
	move.w	2(a4),d1		; posizione Y
	move.w	4(a4),d2		; dx (velocita` X)
	move.w	6(a4),d3		; dy (velocita` Y)
	add.w	d2,d0			; x = x + dx
	add.w	d3,d1			; y = y + dy

	btst	#15,d1			; controlla bordo alto (Y=0)
	beq.s	UO_NoBounce4		; se la Y e` negativa...
	neg.w	d1			; .. fa il rimbalzo
	neg.w	d3			; inverti direzione del moto
UO_NoBounce4:

	cmp.w	#Lowest_Floor,d1	; controlla bordo in basso
	blt.s	UO_NoBounce1

	neg.w	d3			; cambia il segno della velocita` dy
					; invertendo la direzione del moto
	move.w	#Lowest_Floor,d1	; riparti dal bordo
UO_NoBounce1:

	cmp.w	#Right_Side,d0		; controlla bordo destro
	blt.s	UO_NoBounce2		; se supera il bordo destro..
	sub.w	#Right_Side,d0		; distanza dal bordo
	neg.w	d0			; inverti la distanza
	add.w	#Right_Side,d0		; aggiungi coordinata bordo
	neg.w	d2			; inverti direzione del moto
UO_NoBounce2:
	btst	#15,d0			; controlla bordo sinistro (X=0)
	beq.s	UO_NoBounce3		; se la X e` negativa...
	neg.w	d0			; .. fa il rimbalzo
	neg.w	d2			; inverti direzione del moto
UO_NoBounce3:
	move.w	d0,(a4)			; aggiorna posizione e velocita`
	move.w	d1,2(a4)
	move.w	d2,4(a4)
	move.w	d3,6(a4)

	rts


;****************************************************************************
; Questa routine disegna un BOB.
; A4 - punta alla struttura dati che contiene la posizione e la velocita`
;      del bob
;****************************************************************************

DisegnaOggetto:
	move.l	draw_buffer(pc),a0	; indirizzo buffer disegno
	move.w	2(a4),d0	; coordinata Y
	mulu.w	#40,d0		; calcola indirizzo: ogni riga occupa 40 bytes

	add.l	d0,a0		; aggiungi offset Y

	move.w	(a4),d0		; coordinata X
	move.w	d0,d1		; copia
	and.w	#$000f,d0	; si selezionano i primi 4 bit perche' vanno
				; inseriti nello shifter del canale A 
	lsl.w	#8,d0		; i 4 bit vengono spostati sul nibble alto
	lsl.w	#4,d0		; della word...
	or.w	#$0FCA,d0	; ...giusti per inserirsi nel registro BLTCON0
	lsr.w	#3,d1		; (equivalente ad una divisione per 8)
				; arrotonda ai multipli di 8 per il puntatore
				; allo schermo, ovvero agli indirizzi dispari
				; (anche ai byte, quindi)
				; x es.: un 16 come coordinata diventa il
				; byte 2 
	and.l	#$0000fffe,d1	; escludo il bit 0 del
	add.l	d1,a0		; aggiungi l'offset X, trovando l'indirizzo
				; della destinazione

	lea	Ball_Bob,a1		; puntatore alla figura
	lea	Ball_Mask,a2		; puntatore alla maschera
	moveq	#3-1,d7			; bitplane counter

DrawLoop:
	btst	#6,2(a5)
WBlit2:
	btst	#6,2(a5)
	bne.s	WBlit2

	move.w	d0,$40(a5)		; BLTCON0 - scrivi valore di shift
	move.w	d0,d1			; copia valore di BLTCON0,
	and.w	#$f000,d1		; seleziona valore di shift..
	move.w	d1,$42(a5)		; e scrivilo in BLTCON1 (per canale B)

	move.l	#$ffff0000,$44(a5)	; BLTAFWM e BLTLWM

	move.w	#$FFFE,$64(a5)		; BLTAMOD
	move.w	#$FFFE,$62(a5)		; BLTBMOD

	move.w	#40-6,$66(a5)		; BLTDMOD
	move.w	#40-6,$60(a5)		; BLTCMOD

	move.l	a2,$50(a5)		; BLTAPT - puntatore maschera
	move.l	a1,$4c(a5)		; BLTBPT - puntatore figura
	move.l	a0,$48(a5)		; BLTCPT - puntatore sfondo
	move.l	a0,$54(a5)		; BLTDPT - puntatore bitplanes

	move.w	#(31*64)+3,$58(a5)	; BLTSIZE - altezza 31 linee
				 	; largh. 3 word (48 pixel).

	add.l	#4*31,a1		; indirizzo prossimo plane immagine
	add.l	#40*256,a0		; indirizzo prossimo plane destinazione
	dbra	d7,DrawLoop



	rts


;****************************************************************************
; Questa routine cancella lo schermo mediante il blitter.
;****************************************************************************

CancellaSchermo:
	moveq	#3-1,d7			; 3 bitplanes
	move.l	draw_buffer(pc),a0	; indirizzo buffer disegno

canc_loop:
	btst	#6,2(a5)
WBlit3:
	btst	#6,2(a5)		 ; attendi che il blitter abbia finito
	bne.s	wblit3

	move.l	#$01000000,$40(a5)	; BLTCON0 e BLTCON1: Cancella
	move	#$0000,$66(a5)		; BLTDMOD=0
	move.l	a0,$54(a5)		; BLTDPT
	move.w	#(64*256)+20,$58(a5)	; BLTSIZE (via al blitter !)
					; cancella tutto lo schermo

	add.l	#40*256,a0		; indirizzo prossimo plane destinazione
	dbra	d7,canc_loop
	rts

; puntatori ai 2 buffer
view_buffer	dc.l	BITPLANE1	; buffer visualizzato
draw_buffer	dc.l	BITPLANE1b	; buffer di disegno


; dati oggetti
; queste sono le strutture dati che contengono velocita` e posizione dei bobs.
; ogni struttra dati si compone di 4 words che contengono nell'ordine:
; POSIZIONE X, POSIZIONE Y, VELOCITA` X, VELOCITA` Y

Oggetto_1:
	dc.w	32,53		;  x / y   - posizione
	dc.w	-3,1		; dx / dy  - velocita`

Oggetto_2:
	dc.w	132,65		;  x / y   - posizione
	dc.w	2,-1		; dx / dy  - velocita`

Oggetto_3:
	dc.w	232,42		;  x / y   - posizione
	dc.w	3,1		; dx / dy  - velocita`

Oggetto_4:
	dc.w	2,20		;  x / y   - posizione
	dc.w	-5,1		; dx / dy  - velocita`

Oggetto_5:
	dc.w	60,80		;  x / y   - posizione
	dc.w	6,1		; dx / dy  - velocita`

Oggetto_6:
	dc.w	50,75		;  x / y   - posizione
	dc.w	-5,1		; dx / dy  - velocita`

;****************************************************************************

	SECTION	MY_COPPER,CODE_C

COPPERLIST:
	dc.w	$8E,$2c81	; DiwStrt
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$38		; DdfStart
	dc.w	$94,$d0		; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2

	dc.w	$108,0		; MODULO
	dc.w	$10a,0

BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane
	dc.w $e4,$0000,$e6,$0000
	dc.w $e8,$0000,$ea,$0000
	dc.w $ec,$0000,$ee,$0000

	dc.w	$180,$000	; color0 - sfondo
	dc.w	$190,$000

 	dc.w	$182,$0A0			; colori da 1 a 7
 	dc.w	$184,$040
 	dc.w	$186,$050
 	dc.w	$188,$061
 	dc.w	$18A,$081
 	dc.w	$18C,$020
 	dc.w	$18E,$6F8

	dc.w	$192,$0A0			; colori da 9 a 15
	dc.w	$194,$040			; sono gli stessi valori
	dc.w	$196,$050			; caricati nei registri da 1 a 7
	dc.w	$198,$061
	dc.w	$19a,$081
	dc.w	$19c,$020
	dc.w	$19e,$6F8

	dc.w	$190,$345	; colore 8 - pixel ad 1 dello sfondo

	dc.w	$100,$3200	; bplcon0 - 3 bitplanes lowres

	dc.w	$8007,$fffe	; aspetta riga $80
	dc.w	$100,$4200	; bplcon0 - 4 bitplanes lowres
				; attiva il bitplane 4 (sfondo)

; in questo spazio e' visualizzata la parte dello sfondo

	dc.w	$e007,$fffe	; aspetta riga $e0
	dc.w	$100,$3200	; bplcon0 - 3 bitplanes lowres

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;****************************************************************************

; Figura Bob
Ball_Bob:
 DC.W $0000,$0000,$0000,$0000,$0000,$0000,$003F,$8000	; plane 1
 DC.W $00C1,$E000,$017C,$E000,$02FE,$3000,$05FF,$5400
 DC.W $07FF,$1800,$0BFE,$AC00,$03FF,$1A00,$0BFE,$AC00
 DC.W $11FF,$1A00,$197D,$2C00,$0EAA,$1A00,$1454,$DC00
 DC.W $0E81,$3800,$0154,$F400,$02EB,$F000,$015F,$D000
 DC.W $00B5,$A000,$002A,$8000,$0000,$0000,$0000,$0000
 DC.W $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
 DC.W $0000,$0000,$0000,$0000,$0000,$0000

 DC.W $000F,$E000,$007F,$FC00,$01FF,$FF00,$03FF,$FF80	; plane 2
 DC.W $07C1,$FFC0,$0F00,$FFE0,$1E00,$3FF0,$3C40,$5FF8
 DC.W $3CE0,$1FF8,$7840,$2FFC,$7800,$1FFC,$7800,$2FFC
 DC.W $F800,$1FFE,$F800,$2FFE,$FE00,$1FFE,$FC00,$DFFE
 DC.W $FE81,$3FFE,$FF54,$FFFE,$FFEB,$FFFE,$7FFF,$FFFC
 DC.W $7FFF,$FFFC,$7FFF,$FFFC,$3FFF,$FFF8,$3FFF,$FFF8
 DC.W $1FFF,$FFF0,$0FFF,$FFE0,$07FF,$FFC0,$03FF,$FF80
 DC.W $01FF,$FF00,$007F,$FC00,$000F,$E000

 DC.W $000F,$E000,$007F,$FC00,$01E0,$7F00,$0380,$0F80	; plane 3
 DC.W $073E,$0AC0,$0CFF,$0560,$198F,$C2F0,$3347,$A0B8
 DC.W $32EB,$E158,$6647,$D0AC,$660B,$E05C,$4757,$D0AC
 DC.W $C7AF,$E05E,$A7FF,$D02E,$C1FF,$E05E,$A3FF,$202E
 DC.W $D17E,$C05E,$E0AB,$002E,$D014,$005E,$6800,$00AC
 DC.W $7000,$02DC,$7400,$057C,$2800,$0AF8,$3680,$55F8
 DC.W $1D54,$AAF0,$0EAB,$55E0,$0754,$ABC0,$03EB,$FF80
 DC.W $01FE,$FF00,$007F,$FC00,$000F,$E000

; Maschera Bob
Ball_MASK:
 DC.W $000F,$E000,$007F,$FC00,$01FF,$FF00,$03FF,$FF80
 DC.W $07FF,$FFC0,$0FFF,$FFE0,$1FFF,$FFF0,$3FFF,$FFF8
 DC.W $3FFF,$FFF8,$7FFF,$FFFC,$7FFF,$FFFC,$7FFF,$FFFC
 DC.W $FFFF,$FFFE,$FFFF,$FFFE,$FFFF,$FFFE,$FFFF,$FFFE
 DC.W $FFFF,$FFFE,$FFFF,$FFFE,$FFFF,$FFFE,$7FFF,$FFFC
 DC.W $7FFF,$FFFC,$7FFF,$FFFC,$3FFF,$FFF8,$3FFF,$FFF8
 DC.W $1FFF,$FFF0,$0FFF,$FFE0,$07FF,$FFC0,$03FF,$FF80
 DC.W $01FF,$FF00,$007F,$FC00,$000F,$E000


;****************************************************************************

; Sfondo 320 * 100 1 Bitplane, raw normale.

SfondoFinto:
	incbin	"sfondo320*100.raw"

;****************************************************************************

	SECTION	bitplane,BSS_C
; Questi sono i bitplanes del primo buffer
BITPLANE1:
	ds.b	40*256
BITPLANE2:
	ds.b	40*256
BITPLANE3:
	ds.b	40*256

; Questi sono i bitplanes del secondo buffer
BITPLANE1b:
	ds.b	40*256
BITPLANE2b:
	ds.b	40*256
BITPLANE3b:
	ds.b	40*256

	end

;****************************************************************************

In questo esempio risolviamo il problema dell'esempio lezione10f1.s mediante
la tecnica del double buffering. Questa tecnica consiste nell'uso di 2
buffer separati, uno che viene visualizzato e uno sul quale si disegna
che vengono scambiati ad ogni Vertical Blank.
Gli indirizzi dei 2 buffer sono contenuti in 2 variabili. La variabile
draw_buffer contiene l'indirizzo del buffer usato per disegnare nel
fotogramma corrente. Le routine che modificano lo schermo (CancellaSchermo
e DisegnaOggetto) leggono da draw_buffer l'indirizzo del buffer di disegno
e su di esso effettuano le loro operazioni.
La variabile view_buffer contiene l'indirizzo del buffer attualmente
visualizzato. 
La routine ScambiaBuffer provvede a scambiare ad ogni fotogramma il contenuto
delle 2 variabili. Inoltre essa fa in modo che venga visualizzato il giusto
buffer (quello il cui indirizzo e` memorizzato in view_buffer). Infatti,
per visualizzare alternativamente i 2 buffer, e` necessario che ad ogni
fotogramma la copper list faccia puntare i registri BPLxPT ai bitplane del
buffer di visualizzazione. Questo significa che la copper list deve essere
modificata ad ogni vertical blank, cosa che viene fatta dalla routine
ScambiaBuffer.

