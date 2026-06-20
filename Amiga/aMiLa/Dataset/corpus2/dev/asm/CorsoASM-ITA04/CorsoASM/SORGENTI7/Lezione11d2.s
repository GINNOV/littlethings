
; Lezione11d2.s - Utilizzo di interrupts COPER e VERTB dell livello 3 ($6c).
;		  Questa volta si fa ciclare la palette. Tasto destro del
;		  mouse per bloccare la routine temporaneamente.

	Section	Interrupt,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup2.s"	; salva interrupt, dma eccetera.
*****************************************************************************


; Con DMASET decidiamo quali canali DMA aprire e quali chiudere

		;5432109876543210
DMASET	EQU	%1000001110000000	; copper e bitplane DMA abilitati

WaitDisk	EQU	30	; 50-150 al salvataggio (secondo i casi)

START:

; Puntiamo la PIC

	MOVE.L	#PICTURE2,d0
	LEA	BPLPOINTERS2,A1
	MOVEQ	#5-1,D1			; num di bitplanes
POINTBT2:
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	add.l	#34*40,d0		; lunghezza del bitplane
	addq.w	#8,a1
	dbra	d1,POINTBT2	; Rifai D1 volte (D1=num do bitplanes)

; Puntiamo il nostro int di livello 3

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

	move.w	#$c030,$9a(a5)	; INTENA - abilito interrupt "VERTB" e "COPER"
				; del livello 3 ($6c)

mouse:
	btst	#6,$bfe001	; Mouse premuto? (il processore esegue questo
	bne.s	mouse		; loop in modo utente, e ogni vertical blank
				; nonche' ogni WAIT della linea raster $a0
				; lo interrompe per suonare la musica!).

	bsr.w	mt_end		; fine del replay!

	rts			; esci

*****************************************************************************
*	ROUTINE IN INTERRUPT $6c (livello 3) - usato il VERTB e COPER.
*****************************************************************************

;	     ,,,,;;;;;;;;;;;;;;;;;;;;;,
;	  ,;;;;;;;;;;'''''''';;;;;;;;;;;;,
;	  ;|                     \   ';;'
;	  ;|   _______  ______,   )
;	  _| _________   ________/
;	 / T ¬/   ¬©) \ /  ¬©) \¯¡
;	( C|  \_______/ \______/ |
;	 \_j ______      \  ____ |
;	  `|     /        \  \   l
;	   |    /     (, _/   \  /
;	   |  _   __________    /
;	   |  '\   --------¬   /
;	   |    \_____________/
;	   |          __,   T
;	   l________________! xCz

MioInt6c:
	btst.b	#5,$dff01f	; INTREQR - il bit 5, VERTB, e' azzerato?
	beq.s	NointVERTB		; Se si, non e' un "vero" int VERTB!
	movem.l	d0-d7/a0-a6,-(SP)	; salvo i registri nello stack
	bsr.w	mt_music		; suono la musica
	movem.l	(SP)+,d0-d7/a0-a6	; riprendo i reg. dallo stack
	move.w	#$20,$dff09c	; INTREQ - int eseguito, cancello la richiesta
				; dato che il 680x0 non la cancella da solo!!!
	rte	; Uscita dall'int VERTB

nointVERTB:
	btst.b	#4,$dff01f	; INTREQR - COPER azzerato?
	beq.s	NointCOPER	; se si, non e' un int COPER!
	movem.l	d0-d7/a0-a6,-(SP)	; salvo i registri nello stack
	bsr.w	ColorCicla		; Cicla i colori della pic
	movem.l	(SP)+,d0-d7/a0-a6	; riprendo i reg. dallo stack

NointCOPER:
		 ;6543210
	move.w	#%1010000,$dff09c ; INTREQ - cancello richiesta BLIT e COPER
	rte	; uscita dall'int COPER/BLIT


*****************************************************************************
*	Routine che "cicla" i colori di tutta la palette.		    *
*	Questa routine cicla i primi 15 colori separatamente dal secondo    *
*	secondo blocco di colori. Funziona come i "RANGE" del Dpaint.       *
*****************************************************************************

;	Il contatore "cont" serve a far aspettare 3 fotogrammi prima di
;	eseguire la routine cont. In pratica a "rallentare" l'esecuzione

cont:
	dc.w	0

ColorCicla:
	btst.b	#2,$dff016	; Tasto destro del mouse premuto?
	beq.s	NonAncora	; Se si, esci
	addq.b	#1,cont
	cmp.b	#3,cont		; Agisci 1 volta ogni 3 fotogrammi solamente
	bne.s	NonAncora	; Non siamo ancora al terzo? Esci!
	clr.b	cont		; Siamo al terzo, azzera il contatore

; Roteazione all'indietro dei primi 15 colori

	lea	cols+2,a0	; Indirizzo primo colore del primo gruppo
	move.w	(a0),d0		; Salva il primo colore in d0
	moveq	#15-1,d7	; 15 colori da "roteare" nel primo gruppo
cloop1:
	move.w	4(a0),(a0)	; Copia il colore avanti in quello prima
	addq.w	#4,a0		; salta alla prossimo col. da "indietreggiare"
	dbra	d7,cloop1	; ripeti d7 volte
	move.w	d0,(a0)		; Sistema il primo colore salvato come ultimo.

; Roteazione in avanti dei secondi 15 colori

	lea	cole-2,a0	; Indirizzo ultimo colore del secondo gruppo
	move.w	(a0),d0		; Salva l'ultimo colore in d0
	moveq	#15-1,d7	; Altri 15 colori da "roteare" separatamente
cloop2:	
	move.w	-4(a0),(a0)	; Copia il colore indietro in quello dopo
	subq.w	#4,a0		; salta al precedente col. da "avanzare"
	dbra	d7,cloop2	; ripeti d7 volte
	move.w	d0,(a0)		; Sistema l'ultimo colore salvato come primo
NonAncora:
	rts


*****************************************************************************
;	Routine di replay del protracker/soundtracker/noisetracker
;
	include	"assembler2:sorgenti4/music.s"
*****************************************************************************

	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$8E,$2c81	; DiwStrt
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$0038	; DdfStart
	dc.w	$94,$00d0	; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

	dc.w	$100,$200	; BPLCON0 - no bitplanes
	dc.w	$180,$00e	; color0 BLU

	dc.w	$b807,$fffe	; WAIT - attendi la linea $b8
	dc.w	$9c,$8010	; INTREQ - Richiedo un interrupt COPER, il
				; quale fa agire sui 32 colori della palette.

	dc.w	$b907,$fffe	; WAIT - attendi linea $b9
BPLPOINTERS2:
	dc.w $e0,0,$e2,0		;primo 	 bitplane
	dc.w $e4,0,$e6,0		;secondo    "
	dc.w $e8,0,$ea,0		;terzo	    "
	dc.w $ec,0,$ee,0		;quarto	    "
	dc.w $f0,0,$f2,0		;quinto	    "

	dc.w	$100,%0101001000000000	; BPLCON0 - 5 bitplanes LOWRES

; La palette, che sara' "ruotata" in 2 gruppi di 16 colori.

cols:
	dc.w $180,$040,$182,$050,$184,$060,$186,$080	; tono verde
	dc.w $188,$090,$18a,$0b0,$18c,$0c0,$18e,$0e0
	dc.w $190,$0f0,$192,$0d0,$194,$0c0,$196,$0a0
	dc.w $198,$090,$19a,$070,$19c,$060,$19e,$040

	dc.w $1a0,$029,$1a2,$02a,$1a4,$13b,$1a6,$24b	; tono blu
	dc.w $1a8,$35c,$1aa,$36d,$1ac,$57e,$1ae,$68f
	dc.w $1b0,$79f,$1b2,$68f,$1b4,$58e,$1b6,$37e
	dc.w $1b8,$26d,$1ba,$15d,$1bc,$04c,$1be,$04c
cole:

	dc.w	$da07,$fffe	; WAIT - attendi la linea $da
	dc.w	$100,$200	; BPLCON0 - disabilita i bitplanes
	dc.w	$180,$00e	; color0 BLU

	dc.w	$FFFF,$FFFE	; Fine della copperlist


*****************************************************************************
; 		DISEGNO 320*34 a 5 bitplanes (32 colori)
*****************************************************************************

PICTURE2:
	INCBIN	"pic320*34*5.raw"

*****************************************************************************
;				MUSICA
*****************************************************************************

mt_data:
	dc.l	mt_data1

mt_data1:
	incbin	"assembler2:sorgenti4/mod.fuck the bass"

	end

In questo esempio cambiato la palette proprio una linea prima del disegno.
Infatti basta cambiarlo una linea prima!
Nel frattempo col processore si possono svolgere compiti vari, ma saremo
sicuri che alla linea $b9 i colori sono cambiati ogni volta.
Altra cosa da notare e' che nonostante l'interrupt avvenga ogni fotogramma,
tramite un "contatore" e' possibile far eseguire la routine una volta ogni
3 fotogrammi. Dunque abbiamo visto che e' possibile mettere piu' routines
e piu' interrupt nella stessa copperlist, a linee diverse, in Lezione11d.s,
basta fare in modo che ogni volta sia eseguita la routine per quella linea.
Ora vediamo che si puo' far eseguire qualcuna di queste routine una volta
ogni X frames, per cui si puo' fare ogni cosa!
Ricordatevi pero' che ogni interrupt porta via un poco di tempo per i salti
che devono essere fatti.

Una nota: i 2 numeri sono della bbs Fidonet AmigaLink di Grosseto, infatti
questo e' un "pezzo" della piccola demo che ho fatto al sysop di questa bbs.
Sono segnato come "Fabio Ciucci", ma raramente chiamo, per motivi tutti
di bolletta galattica. Fino a che non ci sara' l'accesso gratuito in tutte le
citta' ad Internet per i coder sara' dura scambiare via modem. Meglio la posta!

