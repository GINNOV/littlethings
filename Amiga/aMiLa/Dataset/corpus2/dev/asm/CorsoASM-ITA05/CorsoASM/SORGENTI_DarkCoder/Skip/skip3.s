		************************************
		*       /\/\                       *
		*      /    \                      *
		*     / /\/\ \ O R B_I D           *
		*    / /    \ \   / /              *
		*   / /    __\ \ / /               *
		*   ¯¯     \ \¯¯/ / I S I O N S    *
		*           \ \/ /                 *
		*            \  /                  *
		*             \/                   *
		*     Feel the DEATH inside!       *
		************************************
		* Coded by:                        *
		* The Dark Coder / Morbid Visions  *
		************************************

; commenti alla fine del sorgente

	SECTION	DK,code

	incdir	"/Include/"
	include	MVstartup.s		; Codice di startup: prende il
					; controllo del sistema e chiama
					; la routine START: ponendo
					; A5=$DFF000

		;5432109876543210
DMASET	EQU	%1000001010000000	; copper,bitplane,blitter DMA


START:

	move	#DMASET,dmacon(a5)
	move.l	#COPPERLIST,cop1lc(a5)
	move	d0,copjmp1(a5)

	move.l	#copperloop,cop2lc(a5)	; carica l'indirizzo del loop
					; in COP2LC

mouse:

	bsr	CambiaCopper

	moveq	#3-1,d7
WaitFrame
; notare il doppio controllo sulla sincronia
; necessario perche` la muovicopper richiede MENO di UNA rasterline su 68030
	move.l	#$1ff00,d1	; bit per la selezione tramite AND
	move.l	#$13000,d2	; linea da aspettare = $130, ossia 304
.Waity1
	move.l	vposr(a5),d0	; vposr e vhposr
	and.l	d1,d0		; seleziona solo i bit della pos. verticale
	cmp.l	d2,d0		; aspetta la linea $130 (304)
	bne.s	.waity1

.Waity2
	move.l	vposr(a5),d0
	and.l	d1,d0
	cmp.l	d2,d0
	beq.s	.waity2

	dbra	d7,WaitFrame

	btst	#6,$bfe001		; tasto sinistro del mouse premuto?
	bne.s	mouse			; se no, torna a mouse:

	rts

****************************************************
* Questa routine muove la bandiera e cambia i colori

CambiaCopper:

	move.b	PosBandiera(pc),d0

	tst.b	PosFlag
	beq.s	Basso

	subq.b	#1,d0
	cmp.b	#$81,d0
	bra.s	Muovi		; le istruzioni Bcc non alterano i CC

Basso	addq.b	#1,d0
	cmp.b	#$bf,d0

Muovi
	shs	PosFlag		; testa limiti (entrambi! ;)
	move.b	d0,PosBandiera
	lsl	#8,d0
	move.b	#$07,d0
	move	d0,Inizio
	add	#$4000,d0
	move	d0,Fine

	tst.b	FadeFlag
	beq.s	FadeIn

FadeOut
	sub	#$010,verde+2	; aumenta luminosita`
	cmp	#$080,verde+2
	sne	FadeFlag	; se siamo al minimo passa a FadeIn

	sub	#$111,bianco+2	; aumenta luminosita`
	sub	#$100,rosso+2	; aumenta luminosita`
	rts

FadeIn
	add	#$010,verde+2	; aumenta luminosita`
	cmp	#$0f0,verde+2	; se siamo al massimo passa a FadeOut
	seq	FadeFlag

	add	#$111,bianco+2	; aumenta luminosita`
	add	#$100,rosso+2	; aumenta luminosita`

	rts

* Posizione prima riga della bandiera
; La bandiera deve rimanere tra le righe $80 e $ff, quindi essendo alta
; $40, la posizione deve variare tra le righe $80 e $bf
PosBandiera	dc.b	$a0
PosFlag		dc.b	0
FadeFlag	dc.b	0

	SECTION	MY_COPPER,CODE_C

*************************************************************************
* Copper Macros by The Dark Coder / Morbid Visions
* vers. 3 SE / 16-07-96 / per ASM One 1.29
* questa e` una versione ridotta delle copper macros usate dai Morbid Visions
* realizzata appositamente per i sorgenti pubblicati su Infamia.
* La versione completa (integrata con le altre macros standard MV) ha
* controlli aggiuntivi sugli errori e permette di utilizzare il Blitter
* Finished Disable bit. Chi e` interessato puo` contattare The Dark Coder.

* formato
* CMOVE valore immediato, registro hardware destinazione
* WAIT  Hpos,Vpos[,Hena,Vena]
* SKIP  Hpos,Vpos[,Hena,Vena]
* CSTOP

* Nota: Hpos,Vpos coordinate copper, Hena, Vena sono i valori di maschera
* della posizione copper, opzionali (se non specificati viene assunto
* Hena=$fe e Vena=$7f)

cmove:	macro
	dc.w	 [\2&$1fe]
	dc.w	\1
	endm

wait:	macro
	dc.w	[\2<<8]+[\1&$fe]+1
	ifeq	narg-2
		dc.w	$fffe
	endc	
	ifeq	narg-4
		dc.w	$8000+[[\4&$7f]<<8]+[\3&$fe]
	endc
	endm

skip:	macro
	dc.w	[\2<<8]+[\1&$fe]+1
	ifeq	narg-2
		dc.w	$fffe
	endc	
	ifeq	narg-4
		dc.w	$8000+[[\4&$7f]<<8]+[\3&$fe]+1
	endc
	endm


cstop:	macro
	dc.w	$ffff
	dc.w	$fffe
	endm
 

* inizia la copperlist
COPPERLIST:

; barra 1
	cmove	$111,color00
	wait	$7,$29
	cmove	$a0a,color00
	wait	$7,$2a
	cmove	$11f,color00
	wait	$7,$2b
	cmove	$000,color00

Inizio:
	wait	$7,$80

copperloop:			; da qui inizia il loop

verde:	cmove	$080,color00	; colore verde. Il valore RGB da caricare nel
				; registro si trova all'indirizzo "verde+2"
				; perche` e` la seconda word dell'istruzione
				; copper

	wait	$6b,$80,$fe,0	; aspetta primo terzo di schermo
				; (le y sono mascherate)

bianco:	cmove	$888,color00	; bianco. Modificare a "bianco+2"
	wait	$a5,$80,$fe,0	; aspetta secondo terzo di schermo

rosso:	cmove	$800,color00	; rosso. Modificare a "rosso+2"
	wait	$e0,$80,$fe,0	; aspetta la fine della riga

Fine:
	skip	0,$c0,0,$7f	; SKIP alla linea $c0
				; (le x sono mascherate)

	cmove	0,copjmp2	; scrive in COPJMP2 - salta ad inizio loop

	cmove	$000,color00
	wait	220,255

; barra 2
	wait	$7,$14
	cmove	$11f,color00
	wait	$7,$15
	cmove	$a0a,color00
	wait	$7,$16
	cmove	$111,color00

	cstop			; Fine della copperlist

	end

Questo esempio mostra una notevole ottimizzazione ottenuta mediante l'uso
dei copperloop.
Abbiamo una bandiera che cambia colore e che si sposta in alto e in basso.
Per disegnare la bandiera si deve cambiare COLOR00 3 volte all'interno di una
riga di raster e ripetere gli stessi colori ad ogni riga. E` molto comodo usare
un copperloop. Le wait all'interno del loop hanno le posizioni verticali
mascherate, in modo da funzionare ad ogni riga di raster senza essere
modificate.
Per cambiare i colori, e` necessario modificare 3 sole istruzioni copper.
Inoltre per spostare verticalmente la bandiera basta modificare ogni volta la
posizione di attesa della WAIT che precede il loop e della SKIP che termina il
loop. In totale quindi abbiamo 5 sole modifiche da effettuare in memoria.

Se non usasassimo ne` il copperloop ne` le WAIT mascherate dovremmo modificare
ad ogni riga di raster, le 3 CMOVE (copper move) e le 3 WAIT per attendere le
varie posizioni. Poiche` la bandiera e` alta 64 righe, avremmo in totale
64*6=384 locazioni di memoria da modificare.

Come potete inoltre notare, e come anticipato nell'articolo su Infamia,
in questo sorgente vengono definite e utilizzate delle macro per definire le
istruzioni copper. In questo modo si ottengono (a mio avviso) dei sorgenti
piu` puliti e si riduce la probabilita` di commettere errori nella scrittura
delle copper list. Ad esempio confrontate la parte di copperlist che genera
la barretta colorata in alto in questo sorgente, con l'identico pezzo generato
con le DC.W negli esempi skip1.s e skip2.s. La versione in questo sorgente e`
immediatamente comprensibile anche ad una rapida occhiata ed e` molto piu`
elegante ed ordinata.
