
; Lezione9i3.s	BOB con ripristino dello sfondo.
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

	bsr.w	LeggiMouse		; leggi coordinate
	bsr.s	ControllaCoordinate	; evita che il bob esca dallo schermo
	bsr.w	SalvaSfondo		; salva lo sfondo
	bsr.s	DisegnaOggetto		; disegna il bob

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
; Questa routine fa in modo che le coordinate del bob rimangano sempre
; all'interno dello schermo.
;****************************************************************************

ControllaCoordinate:
	tst.w	ogg_x		; controlla X
	bpl.s	NoMinX		; controlla bordo sinistro
	clr.w	ogg_x		; se X e` negativa, pone X=0
	bra.s	controllaY	; va a controllare la Y

NoMinX:
	cmp.w	#319-32,ogg_x	; controlla il bordo destro. In X_OGG
				; e` memorizzata la coordinata del bordo
				; sinistro del bob. Se esso ha raggiunto
				; 319-32, allora il bordo destro ha raggiunto
				; la coordinata 319
	bls.s	controllaY	; se e` minore tutto bene, controlla la Y
	move.w	#319-32,ogg_x	; altrimenti fissa la coordinata sul bordo.

controllaY:
	tst.w	ogg_y		; controlla bordo in alto
	bpl.s	NoMinY		; se e` positiva controlla in basso
	clr.w	ogg_y		; altrimenti poni Y=0
	bra.s	EndControlla	; ed esci

NoMinY:
	cmp.w	#255-11,ogg_y	; controlla il bordo basso. In Y_OGG
				; e` memorizzata la coordinata del bordo
				; alto del bob. Se esso ha raggiunto
				; Y=255-11, allora il bordo basso ha raggiunto
				; la coordinata Y=255
	bls.s	EndControlla	; se e` minore tutto bene, controlla la Y
	move.w	#255-11,ogg_y	; altrimenti fissa la coordinata sul bordo.
EndControlla:
	rts

;***************************************************************************
; Questa routine disegna il BOB alle coordinate specificate nelle variabili
; X_OGG e Y_OGG. Il BOB e lo schermo sono in formato normale, e pertanto
; sono utilizzate le formule relative a questo formato nel calcolo dei
; valori da scrivere nei registri del blitter. Inoltre viene impiegata la
; tecnica di mascherare l'ultima word del BOB vista nella lezione
;****************************************************************************

;	     _, ,. ,_
;	     ////;\\\
;	    /'__  __`\
;	  _/  ______  \_
;	 (_   `°'`°'   _)
;	  /  _ (__) _  \ xCz
;	 / _ l______| _ \
;	/  (  `----'  )  \
;	\_____      _____/
;	    `--------'

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
	or.w	#$09f0,d0	; ...giusti per inserirsi nel registro BLTCON0
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
	move.w	#$0000,$42(a5)		; BLTCON1 (nessun modo speciale)
	move.l	#$fffe0022,$64(a5)	; BLTAMOD=$fffe=-2 torna indietro
					; all'inizio della riga.
					; BLTDMOD=40-6=34=$22 come al solito
	move.l	a1,$50(a5)		; BLTAPT  (fisso alla figura sorgente)
	move.l	a0,$54(a5)		; BLTDPT  (linee di schermo)
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

;****************************************************************************
; Questa routine legge il mouse e aggiorna i valori contenuti nelle
; variabili OGG_X e OGG_Y
;****************************************************************************

LeggiMouse:
	move.b	$dff00a,d1	; JOY0DAT posizione verticale mouse
	move.b	d1,d0		; copia in d0
	sub.b	mouse_y(PC),d0	; sottrai vecchia posizione mouse
	beq.s	no_vert		; se la differenza = 0, il mouse e` fermo
	ext.w	d0		; trasforma il byte in word
				; (vedi alla fine del listato)
	add.w	d0,ogg_y	; modifica posizione oggetto

no_vert:
  	move.b	d1,mouse_y	; salva posizione mouse per la prossima volta

	move.b	$dff00b,d1	; posizione orizzontale mouse
	move.b	d1,d0		; copia in d0
	sub.b	mouse_x(PC),d0	; sottrai vecchia posizione
	beq.s	no_oriz		; se la differenza = 0, il mouse e` fermo
	ext.w	d0		; trasforma il byte in word
				; (vedi alla fine del listato)
	add.w	d0,ogg_x	; modifica pos. oggetto
no_oriz
  	move.b	d1,mouse_x	; salva posizione mouse per la prossima volta
	RTS

OGG_Y:		dc.w	0	; qui viene memorizzata la Y dell'oggetto
OGG_X:		dc.w	0	; qui viene memorizzata la X dell'oggetto
MOUSE_Y:	dc.b	0	; qui viene memorizzata la Y del mouse
MOUSE_X:	dc.b	0	; qui viene memorizzata la X del mouse

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

	dc.w	$0180,$000	; color0
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

;****************************************************************************

BITPLANE:
	incbin	"assembler2:sorgenti6/amiga.raw"
					; qua carichiamo la figura in
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

In questo esempio affrontiamo il problema dello sfondo con i BOB.
Non forniremo ancora la soluzione definitiva che richiede la comprensione di
caratteristiche del blitter ancora non spiegate nel corso. Comunque faremo
un primo passo. L'idea e` la seguente: prima di disegnare il BOB sullo schermo
copiamo la parte di sfondo che verrebbe sovrascritta dal BOB in un buffer.
Poi disegnamo normalmente il BOB. Dopo il vertical blank dobbiamo cancellare
il BOB prima di ridisegnarlo nella nuova posizione. Invece di cancellare
semplicemente (cosa che lascerebbe il pezzo di schermo vuoto) ci ricopiamo
sopra lo sfondo che c'era prima. In questo modo cancelliamo la vecchia copia
del BOB e rimettiamo lo sfondo che c'era prima del suo passaggio.
Il problema di questa tecnica, come potete vedere, e` che non si vede lo sfondo
nelle zone nel rettangolo che racchiude il BOB. Questo e` dovuto al fatto
che le parti del BOB colorate con il colore 0 non sono trasparenti come
accadeva per gli sprite, ma rappresentano il colore di sfondo.
Vedremo successivamente la soluzione a questo problema.

