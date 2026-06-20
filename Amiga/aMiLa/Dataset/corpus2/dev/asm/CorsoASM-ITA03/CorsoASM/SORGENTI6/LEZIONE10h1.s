
; Lezione10h1.s	Collisione tra BOB e sfondo mediante il flag ZERO del blitter.
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
	MOVEQ	#3-1,D1		; numero di bitplanes (qua sono 3)
POINTBP:
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	ADD.L	#40*256,d0		; + LUNGHEZZA DI UNA PLANE !!!!!
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

	bsr.s	MuoviOggetto		; sposta il bob
	bsr.w	ControllaCollisione	; controlla e segnala eventuali
					; collisioni tra bob e sfondo
					
	bsr.w	SalvaSfondo		; salva lo sfondo
	bsr.w	DisegnaOggetto		; disegna il bob

	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$13000,d2	; linea da aspettare = $130, ossia 304
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $130 (304)
	BNE.S	Waity1

	bsr.w	RipristinaSfondo	; ripristina lo sfondo

	btst	#6,$bfe001		; tasto sinistro del mouse premuto?
	bne.s	mouse			; se no, torna a mouse:

	rts


;****************************************************************************
; Questa routine muove il bob sullo schermo.
;****************************************************************************

MuoviOggetto
	addq.w	#1,ogg_y	; sposta in basso il bob
	cmp.w	#256-11,ogg_y	; e` arrivato al bordo basso ?
	bls.s	EndMuovi	; se no fine
	clr.w	ogg_y		; altrimenti riparti dall'alto
EndMuovi
	rts

;***************************************************************************
; Questa routine disegna il BOB alle coordinate specificate nelle variabili
; X_OGG e Y_OGG.
;****************************************************************************

;	 ||||||||
;	 | =  = |
;	@| O  O |@
;	 |  ()  |
;	 ((\__/))
;	  ((()))
;	   ))((
;	    ()

DisegnaOggetto:
	lea	bitplane,a0	; destinazione in a0
	move.w	ogg_y(pc),d0	; coordinata Y
	mulu.w	#40,d0		; calcola indirizzo: ogni riga e` costituita da
				; 40 bytes
	add.w	d0,a0		; aggiungi all'indirizzo di partenza

	move.w	ogg_x(pc),d0	; coordinata X
	move.w	d0,d1		; copia
	and.w	#$000f,d0	; si selezionano i primi 4 bit perche' vanno
				; inseriti nello shifter del canale A 
	lsl.w	#8,d0		; i 4 bit vengono spostati sul nibble alto
	lsl.w	#4,d0		; della word...
	move.w	d0,d2

	or.w	#$0FCA,d0	; ...giusti per inserirsi nel registro BLTCON0
	lsr.w	#3,d1		; (equivalente ad una divisione per 8)
				; arrotonda ai multipli di 8 per il puntatore
				; allo schermo, ovvero agli indirizzi dispari
				; (anche ai byte, quindi)
				; x es.: un 16 come coordinata diventa il
				; byte 2 
	and.w	#$fffe,d1	; escludo il bit 0 del
	add.w	d1,a0		; somma all'indirizzo del bitplane, trovando
				; l'indirizzo giusto di destinazione

	lea	figura,a1	; puntatore sorgente
	moveq	#3-1,d7		; ripeti per ogni plane
PlaneLoop:
	btst	#6,2(a5)
WBlit2:
	btst	#6,2(a5)		 ; attendi che il blitter abbia finito
	bne.s	wblit2

	move.l	#$ffff0000,$44(a5)	; BLTAFWM = $ffff fa passare tutto
					; BLTALWM = $0000 azzera l'ultima word


	move.w	d0,$40(a5)		; BLTCON0 (usa A+D)
	move.w	d2,$42(a5)		; BLTCON1 (nessun modo speciale)
	move.l	#$0022fffe,$60(a5)
	move.l	#$fffe0022,$64(a5)	; BLTAMOD=$fffe=-2 torna indietro
					; all'inizio della riga.
					; BLTDMOD=40-6=34=$22 come al solito
	move.l	#Maschera,$50(a5)	; BLTAPT  (fisso alla figura sorgente)
	move.l	a0,$54(a5)		; BLTDPT  (linee di schermo)
	move.l	a0,$48(a5)		; BLTCPT  (linee di schermo)
	move.l	a1,$4c(a5)
	move.w	#(64*11)+3,$58(a5)	; BLTSIZE (via al blitter !)

	lea	4*11(a1),a1		; punta al prossimo plane sorgente
					; ogni plane e` largo 2 words e alto
					; 11 righe

	lea	40*256(a0),a0		; punta al prossimo plane destinazione
	dbra	d7,PlaneLoop

	rts

;****************************************************************************
; Questa routine copia il rettangolo di sfondo che verra` sovrascritto dal
; BOB in un buffer
;****************************************************************************

SalvaSfondo:
	lea	bitplane,a0	; destinazione in a0
	move.w	ogg_y(pc),d0	; coordinata Y
	mulu.w	#40,d0		; calcola indirizzo: ogni riga e` costituita da
				; 40 bytes
	add.w	d0,a0		; aggiungi all'indirizzo di partenza

	move.w	ogg_x(pc),d1	; coordinata X
	lsr.w	#3,d1		; (equivalente ad una divisione per 8)
				; arrotonda ai multipli di 8 per il puntatore
				; allo schermo, ovvero agli indirizzi dispari
				; (anche ai byte, quindi)
				; x es.: un 16 come coordinata diventa il
				; byte 2 
	and.w	#$fffe,d1	; escludo il bit 0 del
	add.w	d1,a0		; somma all'indirizzo del bitplane, trovando
				; l'indirizzo giusto di destinazione

	lea	Buffer,a1	; indirizzo destinazione
	moveq	#3-1,d7		; ripeti per ogni plane
PlaneLoop2:
	btst	#6,2(a5) ; dmaconr
WBlit3:
	btst	#6,2(a5) ; dmaconr - attendi che il blitter abbia finito
	bne.s	wblit3

	move.l	#$ffffffff,$44(a5)	; BLTAFWM = $ffff fa passare tutto
					; BLTALWM = $ffff fa passare tutto


	move.l	#$09f00000,$40(a5)	; BLTCON0 e BLTCON1 copia da A a D
	move.l	#$00220000,$64(a5)	; BLTAMOD=40-4=36=$24
					; BLTDMOD=0 nel buffer
	move.l	a0,$50(a5)		; BLTAPT - ind. sorgente
	move.l	a1,$54(a5)		; BLTDPT - buffer
	move.w	#(64*11)+3,$58(a5)	; BLTSIZE (via al blitter !)

	lea	40*256(a0),a0		; punta al prossimo plane sorgente
	lea	6*11(a1),a1		; punta al prossimo plane destinazione
					; ogni blittata e` larga 3 words e alto
					; 11 righe
	dbra	d7,PlaneLoop2

	rts

;****************************************************************************
; Questa routine copia il contenuto del buffer nel rettangolo di schermo
; che lo conteneva prima del disegno del BOB. In questo modo viene anche
; cancellato il BOB dalla vecchia posizione.
;****************************************************************************

RipristinaSfondo:
	lea	bitplane,a0	; destinazione in a0
	move.w	ogg_y(pc),d0	; coordinata Y
	mulu.w	#40,d0		; calcola indirizzo: ogni riga e` costituita da
				; 40 bytes
	add.w	d0,a0		; aggiungi all'indirizzo di partenza

	move.w	ogg_x(pc),d1	; coordinata X
	lsr.w	#3,d1		; (equivalente ad una divisione per 8)
				; arrotonda ai multipli di 8 per il puntatore
				; allo schermo, ovvero agli indirizzi dispari
				; (anche ai byte, quindi)
				; x es.: un 16 come coordinata diventa il
				; byte 2 
	and.w	#$fffe,d1	; escludo il bit 0 del
	add.w	d1,a0		; somma all'indirizzo del bitplane, trovando
				; l'indirizzo giusto di destinazione

	lea	Buffer,a1	; indirizzo sorgente
	moveq	#3-1,d7		; ripeti per ogni plane
PlaneLoop3:
	btst	#6,2(a5)	 ; dmaconr
WBlit4:
	btst	#6,2(a5)	 ; attendi che il blitter abbia finito
	bne.s	wblit4

	move.l	#$ffffffff,$44(a5)	; BLTAFWM = $ffff fa passare tutto
					; BLTALWM = $ffff fa passare tutto


	move.l	#$09f00000,$40(a5)	; BLTCON0 e BLTCON1 copia da A a D
	move.l	#$00000022,$64(a5)	; BLTAMOD=0 (buffer)
					; BLTDMOD=40-6=34=$22
	move.l	a1,$50(a5)		; BLTAPT (buffer)
	move.l	a0,$54(a5)		; BLTDPT (schermo)
	move.w	#(64*11)+3,$58(a5)	; BLTSIZE (via al blitter !)

	lea	40*256(a0),a0		; punta al prossimo plane destinazione
	lea	6*11(a1),a1		; punta al prossimo plane sorgente
					; ogni blittata e` larga 3 words e alto
					; 11 righe
	dbra	d7,PlaneLoop3
	rts

OGG_Y:		dc.w	0	; qui viene memorizzata la Y dell'oggetto
OGG_X:		dc.w	100	; qui viene memorizzata la X dell'oggetto


;****************************************************************************
; Questa routine controlla il verificarsi di una collisione
;****************************************************************************

ControllaCollisione

	lea	bitplane,a0	; indirizzo bitplane a0
	move.w	ogg_y(pc),d0	; coordinata Y
	mulu.w	#40,d0		; calcola indirizzo: ogni riga e` costituita da
				; 40 bytes
	add.w	d0,a0		; aggiungi all'indirizzo di partenza

	move.w	ogg_x(pc),d0	; coordinata X
	move.w	d0,d1		; copia
	and.w	#$000f,d0	; si selezionano i primi 4 bit perche' vanno
				; inseriti nello shifter del canale A 
	lsl.w	#8,d0		; i 4 bit vengono spostati sul nibble alto
	lsl.w	#4,d0		; della word...
	move.w	d0,d2

	or.w	#$0AA0,d0	; ...giusti per inserirsi nel registro BLTCON0
				; sono attivi solo i canali A e C (no D)
				; esegue un AND tra A e C

	lsr.w	#3,d1		; (equivalente ad una divisione per 8)
				; arrotonda ai multipli di 8 per il puntatore
				; allo schermo, ovvero agli indirizzi dispari
				; (anche ai byte, quindi)
				; x es.: un 16 come coordinata diventa il
				; byte 2 
	and.w	#$fffe,d1	; escludo il bit 0 del
	add.w	d1,a0		; somma all'indirizzo del bitplane, trovando
				; l'indirizzo giusto di destinazione

; attende che il blitter abbia finito prima di modificare i registri
	btst	#6,2(a5)
WBlit_coll:
	btst	#6,2(a5)
	bne.s	wblit_coll

	lea	Maschera,a1	; puntatore maschera collisione
	moveq	#3-1,d7		; ripeti per ogni plane
CollLoop:

	move.l	#$ffff0000,$44(a5)	; BLTAFWM = $ffff fa passare tutto
					; BLTALWM = $0000 azzera l'ultima word


	move.w	d0,$40(a5)		; BLTCON0 
					; sono attivi solo i canali A e C
					; (non D). Esegue un AND tra A e C
	move.w	#$0000,$42(a5)		; BLTCON1 (nessun modo speciale)
	move.w	#$0022,$60(a5)		; BLTCMOD=40-6=34=$22
	move.w	#$fffe,$64(a5)		; BLTAMOD=$fffe=-2 torna indietro
					; all'inizio della riga.
	move.l	a1,$50(a5)		; BLTAPT  (fisso alla figura sorgente)
	move.l	a0,$48(a5)		; BLTCPT  (posizione sullo schermo)
	move.w	#(64*11)+3,$58(a5)	; BLTSIZE (via al blitter !)

	lea	40*256(a0),a0		; punta al prossimo plane sullo schermo

	btst	#6,2(a5)
WBlit_coll2:
	btst	#6,2(a5)		; attendi che il blitter abbia finito
	bne.s	wblit_coll2		; prima di testare il flag ZERO

	btst	#5,2(a5)		; testa il flag ZERO.
	beq.s	SiColl			; Se il flag e` diverso da zero c'e`
					; stata una collisione, segnala.
					; Altrimenti controlla prossimo plane

	dbra	d7,CollLoop		; se per nessun plane si verifica la
					; collisione, esci dal loop

NoColl
	move.w	#$000,$180(a5)	; non si sono verificate collisioni:
				; schermo nero
	bra.s	EndColl		; salta alla fine della routine

SiColl	move	#$F00,$180(a5)	; e` stata rilevata una collisione:
				; schermo rosso

EndColl
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
	dc.w	$108,0		; VALORE MODULO = 0
	dc.w	$10a,0		; ENTRAMBI I MODULI ALLO STESSO VALORE.

	dc.w	$100,$3200	; bplcon0 - 3 bitplanes lowres

BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane
	dc.w $e4,$0000,$e6,$0000
	dc.w $e8,$0000,$ea,$0000

	dc.w	$0182,$475	; color1
	dc.w	$0184,$fff	; color2
	dc.w	$0186,$ccc	; color3
	dc.w	$0188,$999	; color4
	dc.w	$018a,$232	; color5
	dc.w	$018c,$777	; color6
	dc.w	$018e,$444	; color7

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;****************************************************************************

; Questi sono i dati che compongono la figura del bob.
; Il bob e` in formato normale, largo 32 pixel (2 words)
; alto 11 righe e formato da 3 bitplanes

Figura:	dc.l	$007fc000	; plane 1
	dc.l	$03fff800
	dc.l	$07fffc00
	dc.l	$0ffffe00
	dc.l	$1fe07f00
	dc.l	$1fe07f00
	dc.l	$1fe07f00
	dc.l	$0ffffe00
	dc.l	$07fffc00
	dc.l	$03fff800
	dc.l	$007fc000

	dc.l	$00000000	; plane 2
	dc.l	$007fc000
	dc.l	$03fff800
	dc.l	$07fffc00
	dc.l	$0fe07e00
	dc.l	$0fe07e00
	dc.l	$0fe07e00
	dc.l	$07fffc00
	dc.l	$03fff800
	dc.l	$007fc000
	dc.l	$00000000

	dc.l	$007fc000	; plane 3
	dc.l	$03803800
	dc.l	$04000400
	dc.l	$081f8200
	dc.l	$10204100
	dc.l	$10204100
	dc.l	$10204100
	dc.l	$081f8200
	dc.l	$04000400
	dc.l	$03803800
	dc.l	$007fc000

Maschera:
	dc.l	$007fc000
	dc.l	$03fff800
	dc.l	$07fffc00
	dc.l	$0ffffe00
	dc.l	$1fe07f00
	dc.l	$1fe07f00
	dc.l	$1fe07f00
	dc.l	$0ffffe00
	dc.l	$07fffc00
	dc.l	$03fff800
	dc.l	$007fc000

;****************************************************************************

BITPLANE:
	incbin	"amiga.raw"		; qua carichiamo la figura in
					; formato RAWBLIT (o interleaved),
					; convertita col KEFCON.

;****************************************************************************

	SECTION	BUFFER,BSS_C

; Questo e` il buffer nel quale salviamo di volta in volta lo sfondo.
; ha le stesse dimensioni di una blittata: altezza 11, larghezza 3 words
; 3 bitplanes

Buffer:
	ds.w	11*3*3

	end

;****************************************************************************

In questo esempio mostriamo come rilevare le collisioni tra il bob e lo sfondo.
Per rilevare la collisione si usa il flag Zero del blitter. La tecnica e` la
seguente: si esegue una blittata che fa un AND tra la maschera del bob e lo
sfondo, senza pero` scrivere il risultato in uscita. Se l'operazione di AND
fornisce un risultato di zero per tutti i bit della blittata, il flag Zero
assume valore 1. Il fatto che l'operazione di AND abbia fornito risultato 0,
vuol dire che in nessun caso un bit della maschera coincide con uno dello
sfondo, quindi non c'e` collisione.
Se invece almeno un bit della maschera coincide con uno dello sfondo, vuol dire
che si verifica una collisione. In questo caso, siccome facendo l'AND tra
questi 2 bit il risultato e` 1, il Flag ZERO assumera` valore 0, e da questo
fatto possiamo capire che c'e` stata una collisione.
Notate che mentre per il bob abbiamo la maschera, non e` cosi` per lo sfondo.
Questo fatto ci costringe a controllare la collisione tra la maschera del bob
e tutti i planes della figura. Disponendo della maschera dello sfondo, si
potrebbe testare la collisione mediante una sola blittata tra le maschere.
Fatelo per esercizio.
Notate anche che prima di testare il flag Zero, e` necessario attendere la
fine della blittata.

