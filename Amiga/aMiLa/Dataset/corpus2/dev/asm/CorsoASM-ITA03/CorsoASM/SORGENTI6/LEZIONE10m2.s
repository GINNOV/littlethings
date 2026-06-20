
; Lezione10m2.s	Routine Universale Bob - versione INTERLEAVED
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
	MOVEQ	#2-1,D1		; numero di bitplanes
POINTBP:
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	ADD.L	#40,d0		; + lunghezza riga
	addq.w	#8,a1
	dbra	d1,POINTBP

	lea	$dff000,a5		; CUSTOM REGISTER in a5
	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

mouse:

; parametri per routine SalvaSfondo

	move.w	ogg_x(pc),d0		; posizione X
	move.w	ogg_y(pc),d1		; posizione Y
	move.w	#32,d2			; dimensione X
	move.w	#30,d3			; dimensione Y
	bsr.w	SalvaSfondo		; salva lo sfondo

; parametri per routine UniBob

	move.l	Frametab(pc),a0		; mette il puntatore al fotogramma
					; da disegnare in A0
	lea	2*4*30(a0),a1		; puntatore alla maschera in A1
	move.w	ogg_x(pc),d0		; posizione X
	move.w	ogg_y(pc),d1		; posizione Y
	move.w	#32,d2			; dimensione X
	move.w	#30,d3			; dimensione Y
	bsr.w	UniBob			; disegna il bob con la routine
					; universale

	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$13000,d2	; linea da aspettare = $130
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0
	BNE.S	Waity1

; parametri per routine RipristinaSfondo

	move.w	ogg_x(pc),d0		; posizione X
	move.w	ogg_y(pc),d1		; posizione Y
	move.w	#32,d2			; dimensione X
	move.w	#30,d3			; dimensione Y
	bsr.w	RipristinaSfondo	; ripristina lo sfondo

	bsr.s	MuoviOggetto	; sposta l'oggetto sullo schermo
	bsr.s	Animazione	; sposta i fotogrammi nella tabella

	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	mouse		; se no, torna a mouse
	rts


;****************************************************************************
; Questa routine muove il bob sullo schermo.
;****************************************************************************

MuoviOggetto:
	addq.w	#1,ogg_x	; sposta in basso il bob
	cmp.w	#320-32,ogg_x	; e` arrivato al bordo basso ?
	bls.s	EndMuovi	; se no fine
	clr.w	ogg_x		; altrimenti riparti dall'alto
EndMuovi
	rts

;****************************************************************************
; Questa routine crea l'animazione, spostando gli indirizzi dei fotogrammi
; in maniera che ogni volta il primo della tabella vada all'ultimo posto,
; mentra gli altri scorrono tutti di un posto in direzione del primo
;****************************************************************************

Animazione:
	addq.b	#1,ContaAnim    ; queste tre istruzioni fanno si' che il
	cmp.b	#4,ContaAnim    ; fotogramma venga cambiato una volta
	bne.s	NonCambiare     ; si e 3 no.
	clr.b	ContaAnim
	LEA	FRAMETAB(PC),a0 ; tabella dei fotogrammi
	MOVE.L	(a0),d0		; salva il primo indirizzo in d0
	MOVE.L	4(a0),(a0)	; sposta indietro gli altri indirizzi
	MOVE.L	4*2(a0),4(a0)	; Queste istruzioni "ruotano" gli indirizzi
	MOVE.L	4*3(a0),4*2(a0) ; della tabella.
	MOVE.L	d0,4*3(a0)	; metti l'ex primo indirizzo all'ottavo posto

NonCambiare:
	rts

ContaAnim:
	dc.w	0

; Questa e` la tabella degli indirizzi dei fotogrammi. Gli indirizzi
; presenti nella tabella vengono "ruotati" all'interno della tabella dalla
; routine Animazione, in modo che il primo nella lista sia la prima volta il
; fotogramma1, la volta dopo il Fotogramma2, poi il 3, il 4 e di nuovo il
; primo, ciclicamente. In questo modo basta prendere l'indirizzo che sta
; all'inizio della tabella ogni volta dopo il "rimescolamento" per avere gli
; indirizzi dei fotogrammi in sequenza.

FRAMETAB:
	DC.L	Frame1
	DC.L	Frame2
	DC.L	Frame3
	DC.L	Frame4

; variabili posizione BOB
OGG_Y:		dc.w	100	; qui viene memorizzata la Y dell'oggetto
OGG_X:		dc.w	10	; qui viene memorizzata la X dell'oggetto

;***************************************************************************
; Questa e` la routine universale per disegnare bob di forma e dimensioni
; arbitrarie. Tutti i parametri sono passati tramite registri.
; La routine funziona su schermo INTERLEAVED
;
; A0 - indirizzo figura bob
; A1 - indirizzo maschera bob
; D0 - coordinata X del vertice superiore sinistro
; D1 - coordinata Y del vertice superiore sinistro
; D2 - larghezza rettangolo in pixel
; D3 - altezza rettangolo
;****************************************************************************

;	       ___  Oo          .:/
;	      (___)o_o        ,,///;,   ,;/
;	 //====--//(_)       o:::::::;;///
;	         \\ ^       >::::::::;;\\\
;	                      ''\\\\\'" ';\

UniBob:

; calcolo indirizzo di partenza del blitter

	lea	bitplane,a2	; indirizzo bitplane
	mulu.w	#2*40,d1	; calcola indirizzo: ogni riga e` costituita da
				; 2 planes di 40 bytes ciascuno
	add.l	d1,a2		; aggiungi ad indirizzo
	move.w	d0,d6		; copia la X
	lsr.w	#3,d0		; dividi per 8 la X
	and.w	#$fffe,d0	; rendilo pari
	add.w	d0,a2		; somma all'indirizzo del bitplane, trovando
				; l'indirizzo giusto di destinazione

	and.w	#$000f,d6	; si selezionano i primi 4 bit della X perche'
				; vanno inseriti nello shifter dei canali A,B 
	lsl.w	#8,d6		; i 4 bit vengono spostati sul nibble alto
	lsl.w	#4,d6		; della word. Questo e` il valore di BLTCON1

	move.w	d6,d5		; copia per calcolare il valore di BLTCON0 
	or.w	#$0FCA,d5	; valori da mettere in BLTCON0

; calcolo modulo blitter

	lsr.w	#3,d2		; dividi per 8 la larghezza
	and.w	#$fffe,d2	; azzerro il bit 0 (rendo pari)
	addq.w	#2,d2		; la blittata e` una word piu` larga 
	move.w	#40,d4		; larghezza schermo in bytes
	sub.w	d2,d4		; modulo=larg. schermo-larg. rettangolo

; calcolo dimensione blittata

	mulu	#2,d3		; moltiplica altezza per numero di planes
				; (per schermo interleaved)
				; in questo caso poiche` abbiamo 2 planes
				; si potrebbe usare la asl, ma in generale
				; (es. 3 planes) si deve usare la mulu

	lsl.w	#6,d3		; altezza per 64
	lsr.w	#1,d2		; larghezza in pixel diviso 16
				; cioe` larghezza in words
	or	d2,d3		; metti insieme le dimensioni

; inizializza i registri
	btst	#6,2(a5)
WBlit_u1:
	btst	#6,2(a5)		 ; attendi che il blitter abbia finito
	bne.s	wblit_u1

	move.l	#$ffff0000,$44(a5)	; BLTAFWM = $ffff fa passare tutto
					; BLTALWM = $0000 azzera l'ultima word

	move.w	d6,$42(a5)		; BLTCON1 - valore di shift
					; nessun modo speciale

	move.w	d5,$40(a5)		; BLTCON0 - valore di shift
					; cookie-cut

	move.l	#$fffefffe,$62(a5)	; BLTBMOD e BLTAMOD=$fffe=-2 torna
					; indietro all'inizio della riga.

	move.w	d4,$60(a5)		; BLTCMOD valore calcolato
	move.w	d4,$66(a5)		; BLTDMOD valore calcolato

	move.l	a1,$50(a5)		; BLTAPT  (maschera)
	move.l	a2,$54(a5)		; BLTDPT  (linee di schermo)
	move.l	a2,$48(a5)		; BLTCPT  (linee di schermo)
	move.l	a0,$4c(a5)		; BLTBPT  (figura bob)
	move.w	d3,$58(a5)		; BLTSIZE (via al blitter !)

	rts

;****************************************************************************
; Questa routine copia il rettangolo di sfondo che verra` sovrascritto dal
; BOB in un buffer. La routine gestisce un bob di dimensioni arbitrarie.
; Se usate questa routine per bob di dimensioni diverse, fate attenzione
; che il buffer possa contenere il bob di dimensione massima!
; La posizione e la dimensione del rettangolo sono dei parametri
;
; D0 - coordinata X del vertice superiore sinistro
; D1 - coordinata Y del vertice superiore sinistro
; D2 - larghezza rettangolo in pixel
; D3 - altezza rettangolo
;****************************************************************************

SalvaSfondo:
; calcolo indirizzo di partenza del blitter

	lea	bitplane,a1	; indirizzo bitplane
	mulu.w	#2*40,d1	; calcola indirizzo: ogni riga e` costituita da
				; 2 planes di 40 bytes ciascuno
	add.l	d1,a1		; aggiungi ad indirizzo
	lsr.w	#3,d0		; dividi per 8 la X
	and.w	#$fffe,d0	; rendilo pari
	add.w	d0,a1		; somma all'indirizzo del bitplane, trovando
				; l'indirizzo giusto di destinazione

; calcolo modulo blitter
	lsr.w	#3,d2		; dividi per 8 la larghezza
	and.w	#$fffe,d2	; azzerro il bit 0 (rendo pari)
	addq.w	#2,d2		; la blittata e` larga 1 word in piu`
	move.w	#40,d4		; larghezza schermo in bytes
	sub.w	d2,d4		; modulo=larg. schermo-larg. rettangolo

; calcolo dimensione blittata
	mulu	#2,d3		; moltiplica altezza per numero di planes
				; (per schermo interleaved)
				; in questo caso poiche` abbiamo 2 planes
				; si potrebbe usare la asl, ma in generale
				; (es. 3 planes) si deve usare la mulu
	lsl.w	#6,d3		; altezza per 64
	lsr.w	#1,d2		; larghezza in pixel diviso 16
				; cioe` larghezza in words
	or	d2,d3		; metti insieme le dimensioni

	lea	Buffer,a2	; indirizzo destinazione

	btst	#6,2(a5) ; dmaconr
WBlit3:
	btst	#6,2(a5) ; dmaconr - attendi che il blitter abbia finito
	bne.s	wblit3

	move.l	#$ffffffff,$44(a5)	; BLTAFWM = $ffff fa passare tutto
					; BLTALWM = $ffff fa passare tutto

	move.l	#$09f00000,$40(a5)	; BLTCON0 e BLTCON1 copia da A a D
	move.w	d4,$64(a5)		; BLTAMOD valore calcolato
	move.w	#$0000,$66(a5)		; BLTDMOD=0 nel buffer
	move.l	a1,$50(a5)		; BLTAPT - ind. sorgente
	move.l	a2,$54(a5)		; BLTDPT - buffer
	move.w	d3,$58(a5)		; BLTSIZE (via al blitter !)

	rts

;****************************************************************************
; Questa routine copia il contenuto del buffer nel rettangolo di schermo
; che lo conteneva prima del disegno del BOB. In questo modo viene anche
; cancellato il BOB dalla vecchia posizione. La routine gestisce un bob di
; dimensioni arbitrarie.
; Se usate questa routine per bob di dimensioni diverse, fate attenzione
; che il buffer possa contenere il bob di dimensione massima!
; La posizione e la dimensione del rettangolo sono dei parametri
;
; D0 - coordinata X del vertice superiore sinistro
; D1 - coordinata Y del vertice superiore sinistro
; D2 - larghezza rettangolo in pixel
; D3 - altezza rettangolo
;****************************************************************************

RipristinaSfondo:
; calcolo indirizzo di partenza del blitter

	lea	bitplane,a1	; indirizzo bitplane
	mulu.w	#2*40,d1	; calcola indirizzo: ogni riga e` costituita da
				; 2 planes di 40 bytes ciascuno
	add.l	d1,a1		; aggiungi ad indirizzo
	lsr.w	#3,d0		; dividi per 8 la X
	and.w	#$fffe,d0	; rendilo pari
	add.w	d0,a1		; somma all'indirizzo del bitplane, trovando
				; l'indirizzo giusto di destinazione

; calcolo modulo blitter
	lsr.w	#3,d2		; dividi per 8 la larghezza
	and.w	#$fffe,d2	; azzerro il bit 0 (rendo pari)
	addq.w	#2,d2		; la blittata e` larga 1 word in piu`
	move.w	#40,d4		; larghezza schermo in bytes
	sub.w	d2,d4		; modulo=larg. schermo-larg. rettangolo

; calcolo dimensione blittata
	mulu	#2,d3		; moltiplica altezza per numero di planes
				; (per schermo interleaved)
				; in questo caso poiche` abbiamo 2 planes
				; si potrebbe usare la asl, ma in generale
				; (es. 3 planes) si deve usare la mulu
	lsl.w	#6,d3		; altezza per 64
	lsr.w	#1,d2		; larghezza in pixel diviso 16
				; cioe` larghezza in words
	or	d2,d3		; metti insieme le dimensioni

	lea	Buffer,a2	; indirizzo destinazione

	btst	#6,2(a5) ; dmaconr
WBlit4:
	btst	#6,2(a5) ; dmaconr - attendi che il blitter abbia finito
	bne.s	wblit4

	move.l	#$ffffffff,$44(a5)	; BLTAFWM = $ffff fa passare tutto
					; BLTALWM = $ffff fa passare tutto

	move.l	#$09f00000,$40(a5)	; BLTCON0 e BLTCON1 copia da A a D
	move.w	d4,$66(a5)		; BLTDMOD valore calcolato
	move.w	#$0000,$64(a5)		; BLTAMOD=0 nel buffer
	move.l	a2,$50(a5)		; BLTAPT - buffer
	move.l	a1,$54(a5)		; BLTDPT - schermo
	move.w	d3,$58(a5)		; BLTSIZE (via al blitter !)

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
	dc.w	$108,40		; Bpl1Mod
	dc.w	$10a,40		; Bpl2Mod

	dc.w	$100,$2200	; bplcon0

BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane
	dc.w $e4,$0000,$e6,$0000

	dc.w	$180,$000	; color0
	dc.w	$182,$00b	; color1
	dc.w	$184,$cc0	; color2
	dc.w	$186,$b00	; color3

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;****************************************************************************
; Questi sono i frames che compongono l'animazione

Frame1:

	dc.l	$00000000,$00020000
	dc.l	$00000000,$00070000
	dc.l	$00000000,$000f8000
	dc.l	$00000000,$001fc000
	dc.l	$00000000,$003fe000
	dc.l	$00000000,$007ff000
	dc.l	$00000000,$00fff800
	dc.l	$00000000,$01fffc00
	dc.l	$00000000,$03fffe00
	dc.l	$00000000,$07ffff00
	dc.l	$07ffff00,$07ffff00
	dc.l	$07ffff00,$07ffff00
	dc.l	$07ffff00,$07ffff00
	dc.l	$07ffff00,$07ffff00
	dc.l	$07ffff00,$07ffff00
	dc.l	$07ffff00,$07ffff00
	dc.l	$07ffff00,$07ffff00
	dc.l	$07ffff00,$07ffff00
	dc.l	$07ffff00,$07ffff00
	dc.l	$07ffff00,$07ffff00
	dc.l	$00000000,$07ffff00
	dc.l	$00000000,$03fffe00
	dc.l	$00000000,$01fffc00
	dc.l	$00000000,$00fff800
	dc.l	$00000000,$007ff000
	dc.l	$00000000,$003fe000
	dc.l	$00000000,$001fc000
	dc.l	$00000000,$000f8000
	dc.l	$00000000,$00070000
	dc.l	$00000000,$00020000

; maschera
	dc.l	$00020000
	dc.l	$00020000
	dc.l	$00070000
	dc.l	$00070000
	dc.l	$000f8000
	dc.l	$000f8000
	dc.l	$001fc000
	dc.l	$001fc000
	dc.l	$003fe000
	dc.l	$003fe000
	dc.l	$007ff000
	dc.l	$007ff000
	dc.l	$00fff800
	dc.l	$00fff800
	dc.l	$01fffc00
	dc.l	$01fffc00
	dc.l	$03fffe00
	dc.l	$03fffe00
	dc.l	$07ffff00
	dc.l	$07ffff00
	dc.l	$07ffff00
	dc.l	$07ffff00
	dc.l	$07ffff00
	dc.l	$07ffff00
	dc.l	$07ffff00
	dc.l	$07ffff00
	dc.l	$07ffff00
	dc.l	$07ffff00
	dc.l	$07ffff00
	dc.l	$07ffff00
	dc.l	$07ffff00
	dc.l	$07ffff00
	dc.l	$07ffff00
	dc.l	$07ffff00
	dc.l	$07ffff00
	dc.l	$07ffff00
	dc.l	$07ffff00
	dc.l	$07ffff00
	dc.l	$07ffff00
	dc.l	$07ffff00
	dc.l	$07ffff00
	dc.l	$07ffff00
	dc.l	$03fffe00
	dc.l	$03fffe00
	dc.l	$01fffc00
	dc.l	$01fffc00
	dc.l	$00fff800
	dc.l	$00fff800
	dc.l	$007ff000
	dc.l	$007ff000
	dc.l	$003fe000
	dc.l	$003fe000
	dc.l	$001fc000
	dc.l	$001fc000
	dc.l	$000f8000
	dc.l	$000f8000
	dc.l	$00070000
	dc.l	$00070000
	dc.l	$00020000
	dc.l	$00020000

Frame2:
	dc.l	$00000000,$00000000
	dc.l	$00000000,$00000000
	dc.l	$00000000,$00000000
	dc.l	$00000000,$00000000
	dc.l	$00000000,$001fffc0
	dc.l	$00300000,$003fffc0
	dc.l	$00780000,$007fffc0
	dc.l	$00fc0000,$00ffffc0
	dc.l	$01fe0000,$01ffffc0
	dc.l	$03ff0000,$03ffffc0
	dc.l	$07ff8000,$07ffffc0
	dc.l	$0fffc000,$0fffffc0
	dc.l	$07ffe000,$0fffffc0
	dc.l	$03fff000,$0fffffc0
	dc.l	$01fff800,$0fffffc0
	dc.l	$00fffc00,$0fffffc0
	dc.l	$007ffe00,$0fffffc0
	dc.l	$003fff00,$0fffffc0
	dc.l	$001fff80,$0fffff80
	dc.l	$000fff00,$0fffff00
	dc.l	$0007fe00,$0ffffe00
	dc.l	$0003fc00,$0ffffc00
	dc.l	$0001f800,$0ffff800
	dc.l	$0000f000,$0ffff000
	dc.l	$00006000,$0fffe000
	dc.l	$00000000,$00000000
	dc.l	$00000000,$00000000
	dc.l	$00000000,$00000000
	dc.l	$00000000,$00000000
	dc.l	$00000000,$00000000

	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$001fffc0
	dc.l	$001fffc0
	dc.l	$003fffc0
	dc.l	$003fffc0
	dc.l	$007fffc0
	dc.l	$007fffc0
	dc.l	$00ffffc0
	dc.l	$00ffffc0
	dc.l	$01ffffc0
	dc.l	$01ffffc0
	dc.l	$03ffffc0
	dc.l	$03ffffc0
	dc.l	$07ffffc0
	dc.l	$07ffffc0
	dc.l	$0fffffc0
	dc.l	$0fffffc0
	dc.l	$0fffffc0
	dc.l	$0fffffc0
	dc.l	$0fffffc0
	dc.l	$0fffffc0
	dc.l	$0fffffc0
	dc.l	$0fffffc0
	dc.l	$0fffffc0
	dc.l	$0fffffc0
	dc.l	$0fffffc0
	dc.l	$0fffffc0
	dc.l	$0fffffc0
	dc.l	$0fffffc0
	dc.l	$0fffff80
	dc.l	$0fffff80
	dc.l	$0fffff00
	dc.l	$0fffff00
	dc.l	$0ffffe00
	dc.l	$0ffffe00
	dc.l	$0ffffc00
	dc.l	$0ffffc00
	dc.l	$0ffff800
	dc.l	$0ffff800
	dc.l	$0ffff000
	dc.l	$0ffff000
	dc.l	$0fffe000
	dc.l	$0fffe000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000

Frame3:

	dc.l	$00000000,$00000000
	dc.l	$00000000,$00000000
	dc.l	$00000000,$00000000
	dc.l	$00000000,$00000000
	dc.l	$00000000,$00000000
	dc.l	$003ff000,$007ff800
	dc.l	$003ff000,$00fffc00
	dc.l	$003ff000,$01fffe00
	dc.l	$003ff000,$03ffff00
	dc.l	$003ff000,$07ffff80
	dc.l	$003ff000,$0fffffc0
	dc.l	$003ff000,$1fffffe0
	dc.l	$003ff000,$3ffffff0
	dc.l	$003ff000,$7ffffff8
	dc.l	$003ff000,$fffffffc
	dc.l	$003ff000,$7ffffff8
	dc.l	$003ff000,$3ffffff0
	dc.l	$003ff000,$1fffffe0
	dc.l	$003ff000,$0fffffc0
	dc.l	$003ff000,$07ffff80
	dc.l	$003ff000,$03ffff00
	dc.l	$003ff000,$01fffe00
	dc.l	$003ff000,$00fffc00
	dc.l	$003ff000,$007ff800
	dc.l	$00000000,$00000000
	dc.l	$00000000,$00000000
	dc.l	$00000000,$00000000
	dc.l	$00000000,$00000000
	dc.l	$00000000,$00000000
	dc.l	$00000000,$00000000

	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$007ff800
	dc.l	$007ff800
	dc.l	$00fffc00
	dc.l	$00fffc00
	dc.l	$01fffe00
	dc.l	$01fffe00
	dc.l	$03ffff00
	dc.l	$03ffff00
	dc.l	$07ffff80
	dc.l	$07ffff80
	dc.l	$0fffffc0
	dc.l	$0fffffc0
	dc.l	$1fffffe0
	dc.l	$1fffffe0
	dc.l	$3ffffff0
	dc.l	$3ffffff0
	dc.l	$7ffffff8
	dc.l	$7ffffff8
	dc.l	$fffffffc
	dc.l	$fffffffc
	dc.l	$7ffffff8
	dc.l	$7ffffff8
	dc.l	$3ffffff0
	dc.l	$3ffffff0
	dc.l	$1fffffe0
	dc.l	$1fffffe0
	dc.l	$0fffffc0
	dc.l	$0fffffc0
	dc.l	$07ffff80
	dc.l	$07ffff80
	dc.l	$03ffff00
	dc.l	$03ffff00
	dc.l	$01fffe00
	dc.l	$01fffe00
	dc.l	$00fffc00
	dc.l	$00fffc00
	dc.l	$007ff800
	dc.l	$007ff800
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000

Frame4:

	dc.l	$00000000,$00000000
	dc.l	$00000000,$00000000
	dc.l	$00000000,$00000000
	dc.l	$00000000,$00000000
	dc.l	$00006000,$0fffe000
	dc.l	$0000f000,$0ffff000
	dc.l	$0001f800,$0ffff800
	dc.l	$0003fc00,$0ffffc00
	dc.l	$0007fe00,$0ffffe00
	dc.l	$000fff00,$0fffff00
	dc.l	$001fff80,$0fffff80
	dc.l	$003fff00,$0fffffc0
	dc.l	$007ffe00,$0fffffc0
	dc.l	$00fffc00,$0fffffc0
	dc.l	$01fff800,$0fffffc0
	dc.l	$03fff000,$0fffffc0
	dc.l	$07ffe000,$0fffffc0
	dc.l	$0fffc000,$0fffffc0
	dc.l	$07ff8000,$07ffffc0
	dc.l	$03ff0000,$03ffffc0
	dc.l	$01fe0000,$01ffffc0
	dc.l	$00fc0000,$00ffffc0
	dc.l	$00780000,$007fffc0
	dc.l	$00300000,$003fffc0
	dc.l	$00000000,$001fffc0
	dc.l	$00000000,$00000000
	dc.l	$00000000,$00000000
	dc.l	$00000000,$00000000
	dc.l	$00000000,$00000000
	dc.l	$00000000,$00000000

	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$0fffe000
	dc.l	$0fffe000
	dc.l	$0ffff000
	dc.l	$0ffff000
	dc.l	$0ffff800
	dc.l	$0ffff800
	dc.l	$0ffffc00
	dc.l	$0ffffc00
	dc.l	$0ffffe00
	dc.l	$0ffffe00
	dc.l	$0fffff00
	dc.l	$0fffff00
	dc.l	$0fffff80
	dc.l	$0fffff80
	dc.l	$0fffffc0
	dc.l	$0fffffc0
	dc.l	$0fffffc0
	dc.l	$0fffffc0
	dc.l	$0fffffc0
	dc.l	$0fffffc0
	dc.l	$0fffffc0
	dc.l	$0fffffc0
	dc.l	$0fffffc0
	dc.l	$0fffffc0
	dc.l	$0fffffc0
	dc.l	$0fffffc0
	dc.l	$0fffffc0
	dc.l	$0fffffc0
	dc.l	$07ffffc0
	dc.l	$07ffffc0
	dc.l	$03ffffc0
	dc.l	$03ffffc0
	dc.l	$01ffffc0
	dc.l	$01ffffc0
	dc.l	$00ffffc0
	dc.l	$00ffffc0
	dc.l	$007fffc0
	dc.l	$007fffc0
	dc.l	$003fffc0
	dc.l	$003fffc0
	dc.l	$001fffc0
	dc.l	$001fffc0
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000

;****************************************************************************

	SECTION	bitplane,BSS_C

; Questo e` il buffer nel quale salviamo di volta in volta lo sfondo.
; ha le stesse dimensioni di una blittata: altezza 30, larghezza 3 words
; 2 bitplanes

Buffer:
	ds.w	30*3*2

BITPLANE:

; 2 planes 
	ds.b	40*256
	ds.b	40*256

;****************************************************************************

	end

In questo esempio mostriamo la versione rawblit della routine universale
per disegnare i bob. Il programma e` identico a lezione10m1.s solo
che viene impiegato uno schermo rawblit e di conseguenza, come sapete, cambiano
un po' le formule per il calcolo di valori che vanno scritti nei registri.
Anche se in questo caso non utilizziamo un'immagine di sfondo, le routine
effettuano comunque il salvataggio e il ripristino. Potete disegnare
voi un'immagine di sfondo (in versione rawblit) e mettercela senza modificare
il sorgente!

