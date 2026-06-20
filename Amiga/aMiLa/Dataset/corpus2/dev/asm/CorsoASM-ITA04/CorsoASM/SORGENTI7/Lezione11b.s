
; Lezione11b.s - Primo utilizzo della nuova startup2.s e di un interrupt.

	Section	PrimoInterrupt,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup2.s"	; salva interrupt, dma eccetera.
*****************************************************************************


; Con DMASET decidiamo quali canali DMA aprire e quali chiudere

		;5432109876543210
DMASET	EQU	%1000001010000000	; copper DMA abilitato

WaitDisk	EQU	30	; 50-150 al salvataggio (secondo i casi)

START:
	move.l	BaseVBR(PC),a0	     ; In a0 il valore del VBR
	move.l	#MioInt6c,$6c(a0)	; metto la mia rout. int. livello 3.

	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
					; e sprites.
	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

	movem.l	d0-d7/a0-a6,-(SP)
	bsr.w	mt_init		; inizializza la routine musicale
	movem.l	(SP)+,d0-d7/a0-a6

	move.w	#$c020,$9a(a5)	; INTENA - abilito interrupt "VERTB" del
				; livello 3 ($6c), quello che viene generato
				; una volta al fotogramma (alla linea $00).

mouse:
	btst	#6,$bfe001	; Mouse premuto? (il processore esegue questo
	bne.s	mouse		; loop in modo utente, e ogni vertical blank
				; lo interrompe per suonare la musica!).

	bsr.w	mt_end		; fine del replay!

	rts			; esci

*****************************************************************************
*	ROUTINE IN INTERRUPT $6c (livello 3) - usato il VERTB solamente.
*****************************************************************************
;	     ..,..,.,
;	   /~""~""~""~\
;	  /_____ ¸_____)
;	 _) ¬(_° \°_)¬\
;	( __   (__)    \
;	 \ \___ _____, /
;	  \__  Y  ____/xCz
;	    `-----'

MioInt6c:
	btst.b	#5,$dff01f	; INTREQR - il bit 5, VERTB, e' azzerato?
	beq.s	NointVERTB		; Se si, non e' un "vero" int VERTB!
	movem.l	d0-d7/a0-a6,-(SP)	; salvo i registri nello stack
	bsr.w	mt_music		; suono la musica
	movem.l	(SP)+,d0-d7/a0-a6	; riprendo i reg. dallo stack
nointVERTB:	 ;6543210
	move.w	#%1110000,$dff09c ; INTREQ - cancello rich. BLIT,COPER,VERTB
				; dato che il 680x0 non la cancella da solo!!!
	rte	; uscita dall'int COPER/BLIT/VERTB

*****************************************************************************
;	Routine di replay del protracker/soundtracker/noisetracker
;
	include	"assembler2:sorgenti4/music.s"
*****************************************************************************

	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$100,$200	; BPLCON0 - no bitplanes
	dc.w	$180,$00e	; color0 BLU
	dc.w	$FFFF,$FFFE	; Fine della copperlist

*****************************************************************************
;				MUSICA
*****************************************************************************

mt_data:
	dc.l	mt_data1

mt_data1:
	incbin	"assembler2:sorgenti4/mod.yellowcandy"

	end

Se non settassimo l'interrupt VERTB del livello 3 ($6c), questo listato
si concluderebbe in un solo loop:

mouse:
	btst	#6,$bfe001	; Mouse premuto? (il processore esegue questo
	bne.s	mouse		; loop in modo utente, e ogni vertical blank
				; lo interrompe per suonare la musica!).

Invece il processore lavora in "multitasking" bloccando il loop ogni volta che
il pennello elettronico raggiunge la linea $00, eseguendo MT_MUSIC e ritornando
ad eseguire lo sterile loop.
Anziche' questo vile loop di attesa del mouse, avremmo potuto mettere una
routine di calcolo di un frattale, che poteva richiedere diversi secondi,
durante i quali la musica avrebbe suonato in "contemporanea" e sincronizzata,
senza disturbare il calcolo del frattale, rallentandolo solo il poco che serve
a suonare la musica ogni fotogramma.

Da notare i 2 EQUATE all'inizio del programma, uno per l'accensione dei DMA,
che ormai conosciamo, e quello nuovo:

WaitDisk	EQU	30	; 50-150 al salvataggio (secondo i casi)

Che "aspetta" un poco prima di prendere il controllo dell'hardware.
Per fare un calcolo del tempo atteso condiderate 50 come 1 secondo, essendo
usato il Vblank, che va al "conquantesimo". Per cui 150 sono 3 secondi.
Se comunque il vostro programma e' un file abbastanza grosso e compattato,
a scompattare ci mettera' quel seconduccio o due che basta, per cui si puo'
lasciare a un valore basso. Se invece salvaste il file non compresso, e lo
faceste partire da dischetto, l'esecuzione partirebbe prima che la spia del
drive si sia spenta, e una volta su 5 succede che all'uscita il dos e' andato
in coma totale. Per evitare cio', calcolate sempre che tra scompattazione e
tempo perso con il loop "waitdisk" il programma parta dopo 3 secondi almeno
dalla fine del caricamento.

