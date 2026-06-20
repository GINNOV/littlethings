
; Lezione8a.s - La startup universale, per studiare i canali DMA

; Con DMASET decidiamo quali canali DMA aprire e quali chiudere

		;5432109876543210
DMASET	EQU	%1000001110000000	; copper e bitplane DMA abilitati
;		 -----a-bcdefghij

;	a: Blitter Nasty   (Per ora non ci interessa, lasciamolo a zero)
;	b: Bitplane DMA	   (Se non e' settato, spariscono anche gli sprite)
;	c: Copper DMA	   (Azzerandolo non e' eseguita nemmeno la copperlist)
;	d: Blitter DMA	   (Per ora non ci interessa, azzeriamolo)
;	e: Sprite DMA	   (Azzerandolo spariscono solo gli 8 sprite)
;	f: Disk DMA	   (Per ora non ci interessa, azzeriamolo)
;	g-j: Audio 3-0 DMA (Azzeriamo lasciando muto l'Amiga)

******************************************************************************
;    680X0 & AGA STARTUP BY FABIO CIUCCI - Livello di complessita' 1
******************************************************************************

MAINCODE:
	movem.l	d0-d7/a0-a6,-(SP)	; Salva i registri nello stack
	move.l	4.w,a6			; ExecBase in a6
	LEA	GfxName(PC),A1		; Nome libreria da aprire
	JSR	-$198(A6)		; OldOpenLibrary - apri la lib
	MOVE.L	d0,GFXBASE		; Salva il GfxBase in una label
	BEQ.w	EXIT2			; Se si, esci senza eseguire il codice
	LEA	IntuiName(PC),A1	; Intuition.lib
	JSR	-$198(A6)		; Openlib
	MOVE.L	D0,IntuiBase
	BEQ.w	EXIT1			; Se zero, esci! Errore!

	MOVE.L	IntuiBase(PC),A0
	CMP.W	#39,$14(A0)	; versione 39 o maggiore? (kick3.0+)
	BLT.s	VecchiaIntui
	BSR.w	ResettaSpritesV39
VecchiaIntui:

	MOVE.L	GfxBase(PC),A6
	MOVE.L	$22(A6),WBVIEW	; Salva il WBView attuale di sistema

	SUBA.L	A1,A1		; View nullo per azzerare il modo video
	JSR	-$DE(A6)	; LoadView nullo - modo video azzerato
	SUBA.L	A1,A1		; View nullo
	JSR	-$DE(A6)	; LoadView (due volte per sicurezza...)
	JSR	-$10E(A6)	; WaitOf ( Queste due chiamate a WaitOf    )
	JSR	-$10E(A6)	; WaitOf ( servono a resettare l'interlace )
	JSR	-$10E(A6)	; Altre due, vah!
	JSR	-$10E(A6)

	MOVEA.L	4.w,A6
	SUBA.L	A1,A1		; NULL task - trova questo task
	JSR	-$126(A6)	; findtask (d0=task, FindTask(name) in a1)
	MOVEA.L	D0,A1		; Task in a1
	MOVEQ	#127,D0		; Priorita' in d0 (-128, +127) - MASSIMA!
	JSR	-$12C(A6)	;_LVOSetTaskPri (d0=priorita', a1=task)

	MOVE.L	GfxBase(PC),A6
	jsr	-$1c8(a6)	; OwnBlitter, che ci da l'esclusiva sul blitter
				; impedendone l'uso al sistema operativo.
	jsr	-$E4(A6)	; WaitBlit - Attende la fine di ogni blittata
	JSR	-$E4(A6)	; WaitBlit

	move.l	4.w,a6		; ExecBase in A6
	JSR	-$84(a6)	; FORBID - Disabilita il Multitasking
	JSR	-$78(A6)	; DISABLE - Disabilita anche gli interrupt
				;	    del sistema operativo

	bsr.w	HEAVYINIT	; Ora puoi eseguire la parte che opera
				; sui registri hardware

	move.l	4.w,a6		; ExecBase in A6
	JSR	-$7E(A6)	; ENABLE - Abilita System Interrupts
	JSR	-$8A(A6)	; PERMIT - Abilita il multitasking

	SUBA.L	A1,A1		; NULL task - trova questo task
	JSR	-$126(A6)	; findtask (d0=task, FindTask(name) in a1)
	MOVEA.L	D0,A1		; Task in a1
	MOVEQ	#0,D0		; Priorita' in d0 (-128, +127) - NORMALE
	JSR	-$12C(A6)	;_LVOSetTaskPri (d0=priorita', a1=task)

	MOVE.W	#$8040,$DFF096	; abilita blit
	BTST.b	#6,$dff002	; WaitBlit...
Wblittez:
	BTST.b	#6,$dff002
	BNE.S	Wblittez

	MOVE.L	GFXBASE(PC),A6	; GFXBASE in A6
	jsr	-$E4(A6)	; Aspetta la fine di eventuali blittate
	JSR	-$E4(A6)	; WaitBlit
	jsr	-$1ce(a6)	; DisOwnBlitter, il sistema operativo ora
				; puo' nuovamente usare il blitter
	MOVE.L	IntuiBase(PC),A0
	CMP.W	#39,$14(A0)	; V39+?
	BLT.s	Vecchissima
	BSR.w	RimettiSprites
Vecchissima:

	MOVE.L	GFXBASE(PC),A6	; GFXBASE in A6
	MOVE.L	$26(a6),$dff080	; COP1LC - Punta la vecchia copper1 di sistema
	MOVE.L	$32(a6),$dff084	; COP2LC - Punta la vecchia copper2 di sistema
	JSR	-$10E(A6)	; WaitOf ( Risistema l'eventuale interlace)
	JSR	-$10E(A6)	; WaitOf
	MOVE.L	WBVIEW(PC),A1	; Vecchio WBVIEW in A1
	JSR	-$DE(A6)	; loadview - rimetti il vecchio View
	JSR	-$10E(A6)	; WaitOf ( Risistema l'eventuale interlace)
	JSR	-$10E(A6)	; WaitOf
	MOVE.W	#$11,$DFF10C	; Questo non lo ripristina da solo..!
	MOVE.L	$26(a6),$dff080	; COP1LC - Punta la vecchia copper1 di sistema
	MOVE.L	$32(a6),$dff084	; COP2LC - Punta la vecchia copper2 di sistema
	moveq	#100,d7
RipuntLoop:
	MOVE.L	$26(a6),$dff080	; COP1LC - Punta la vecchia copper1 di sistema
	move.w	d0,$dff088
	dbra	d7,RipuntLoop	; Per sicurezza...

	MOVEA.L	IntuiBase(PC),A6
	JSR	-$186(A6)	; _LVORethinkDisplay - Ridisegna tutto il
				; display, comprese ViewPorts e eventuali
				; modi interlace o multisync.
	MOVE.L	a6,A1		; IntuiBase in a1 per chiudere la libreria
	move.l	4.w,a6		; ExecBase in A6
	jsr	-$19E(a6)	; CloseLibrary - intuition.library CHIUSA
Exit1:
	MOVE.L	GfxBase(PC),A1	; GfxBase in a1 per chiudere la libreria
	jsr	-$19E(a6)	; CloseLibrary - graphics.library CHIUSA
Exit2:
	movem.l	(SP)+,d0-d7/a0-a6 ; Riprendi i vecchi valori dei registri
	RTS			  ; Torna all'ASMONE o al Dos/WorkBench

*******************************************************************************
;	Resetta la risoluzione degli sprite "legalmente"
*******************************************************************************

ResettaSpritesV39:
	LEA	Workbench(PC),A0 ; Nome schermo del Workbench in a0
	MOVE.L	IntuiBase(PC),A6
	JSR	-$1FE(A6)	; _LVOLockPubScreen - "blocchiamo" lo schermo
				; (il cui nome e' in a0).
	MOVE.L	D0,SchermoWBLocckato
	BEQ.s	ErroreSchermo
	MOVE.L	D0,A0		; Struttura Screen in a0
	MOVE.L	$30(A0),A0	; sc_ViewPort+vp_ColorMap: in a0 ora abbiamo
				; la struttura ColorMap dell schermo, che ci
				; serve (in a0) per eseguire un "video_control"
				; della graphics.library.
	LEA	GETVidCtrlTags(PC),A1	; In a1 la TagList per la routine
					; "Video_control" - la richiesta che
					; facciamo a questa routine e' di
					; VTAG_SPRITERESN_GET, ossia di sapere
					; la risoluzione attuale degli sprite.
	MOVE.L	GfxBase(PC),A6
	JSR	-$2C4(A6)	; Video_Control (in a0 la cm e in a1 i tags)
				; riporta nella taglist, nella long
				; "risoluzione", la risoluzione attuale degli
				; sprite in quello schermo.

; Ora chiediamo alla routine VideoControl di settare la risoluzione.
; SPRITERESN_140NS -> ossia lowres!

	MOVE.L	SchermoWBLocckato(PC),A0
	MOVE.L	$30(A0),A0	; struttura sc_ViewPort+vp_ColorMap in a0
	LEA	SETVidCtrlTags(PC),A1	; TagList che resetta gli sprite.
	MOVE.L	GfxBase(PC),A6
	JSR	-$2C4(A6)	; video_control... resetta gli sprite!

; Ora resettiamo anche l'eventuale schermo "in primo piano", ad esempio la
; schermata dell'assemblatore:

	MOVE.L	IntuiBase(PC),A6
	move.l	$3c(a6),a0	; Ib_FirstScreen (Schermo in "primo piano!")
	MOVE.L	$30(A0),A0	; struttura sc_ViewPort+vp_ColorMap in a0
	LEA	GETVidCtrlTags2(PC),A1	; In a1 la TagList GET
	MOVE.L	GfxBase(PC),A6
	JSR	-$2C4(A6)	; Video_Control (in a0 la cm e in a1 i tags)

	MOVEA.L	IntuiBase(PC),A6
	move.l	$3c(a6),a0	; Ib_FirstScreen - "pesca" lo schermo in
				; primo piano (ad es. ASMONE)
	MOVEA.L	$30(A0),A0	; struttura sc_ViewPort+vp_ColorMap in a0
	LEA	SETVidCtrlTags(PC),A1	; TagList che resetta gli sprite.
	MOVEA.L	GfxBase(PC),A6
	JSR	-$2C4(A6)	; video_control... resetta gli sprite!

	MOVEA.L	SchermoWBLocckato(PC),A0
	MOVEA.L	IntuiBase(PC),A6
	JSR	-$17A(A6)	; _LVOMakeScreen - occorre rifare lo schermo
	move.l	$3c(a6),a0	; Ib_FirstScreen - "pesca" lo schermo in
				; primo piano (ad es. ASMONE)
	JSR	-$17A(A6)	; _LVOMakeScreen - occorre rifare lo schermo
				; per essere sicuri del reset: ossia occorre
				; chiamare MakeScreen, seguito da...
	JSR	-$186(A6)	; _LVORethinkDisplay - che ridisegna tutto il
				; display, comprese ViewPorts e eventuali
ErroreSchermo:			; modi interlace o multisync.
	RTS

; Ora dobbiamo risettare gli sprites alla risoluzione di partenza.

RimettiSprites:
	MOVE.L	SchermoWBLocckato(PC),D0 ; Indirizzo strutt. Screen
	BEQ.S	NonAvevaFunzionato	 ; Se = 0, allora peccato...
	MOVE.L	D0,A0
	MOVE.L	OldRisoluzione(PC),OldRisoluzione2 ; Rimetti vecchia risoluz.
	LEA	SETOldVidCtrlTags(PC),A1
	MOVE.L	$30(A0),A0	; Struttura ColorMap dello screen
	MOVE.L	GfxBase(PC),A6
	JSR	-$2C4(A6)	; _LVOVideoControl - Risetta la risoluzione

; Ora dello schermo in primo piano (eventuale)...

	MOVE.L	IntuiBase(PC),A6
	move.l	$3c(a6),a0	; Ib_FirstScreen - "pesca" lo schermo in
				; primo piano (ad es. ASMONE)
	MOVE.L	OldRisoluzioneP(PC),OldRisoluzione2 ; Rimetti vecchia risoluz.
	LEA	SETOldVidCtrlTags(PC),A1
	MOVE.L	$30(A0),A0	; Struttura ColorMap dello screen
	MOVE.L	GfxBase(PC),A6
	JSR	-$2C4(A6)	; _LVOVideoControl - Risetta la risoluzione

	MOVEA.L	SchermoWBLocckato(PC),A0
	MOVEA.L	IntuiBase(PC),A6
	JSR	-$17A(A6)	; RethinkDisplay - "ripensiamo" il display
	move.l	$3c(a6),a0	; Ib_FirstScreen - schermo in primo piano
	JSR	-$17A(A6)	; RethinkDisplay - "ripensiamo" il display
	MOVE.L	SchermoWBLocckato(PC),A1
	SUB.L	A0,A0		; null
	MOVEA.L	IntuiBase(PC),A6
	JSR	-$204(A6)	; _LVOUnlockPubScreen - e "sblocchiamo" lo
NonAvevaFunzionato:		; screen del workbench.
	RTS

SchermoWBLocckato:
	dc.l	0

; Questa e' la struttura per usare Video_Control. La prima long serve per
; CAMBIARE (SET) la risoluzione degli sprite o per sapere (GET) quella vecchia.

GETVidCtrlTags:
	dc.l	$80000032	; GET
OldRisoluzione:
	dc.l	0	; Risoluzione sprite: 0=ECS, 1=lowres, 2=hires, 3=shres
	dc.l	0,0,0	; 3 zeri per TAG_DONE (terminare la TagList)

GETVidCtrlTags2:
	dc.l	$80000032	; GET
OldRisoluzioneP:
	dc.l	0	; Risoluzione sprite: 0=ECS, 1=lowres, 2=hires, 3=shres
	dc.l	0,0,0	; 3 zeri per TAG_DONE (terminare la TagList)

SETVidCtrlTags:
	dc.l	$80000031	; SET
	dc.l	1	; Risoluzione sprite: 0=ECS, 1=lowres, 2=hires, 3=shres
	dc.l	0,0,0	; 3 zeri per TAG_DONE (terminare la TagList)

SETOldVidCtrlTags:
	dc.l	$80000031	; SET
OldRisoluzione2:
	dc.l	0	; Risoluzione sprite: 0=ECS, 1=lowres, 2=hires, 3=shres
	dc.l	0,0,0	; 3 zeri per TAG_DONE (terminare la TagList)

; Nome schermo del WorkBench

Workbench:
	dc.b	'Workbench',0

******************************************************************************
;	Da qua in avanti si puo' operare sull'hardware in modo diretto
******************************************************************************

HEAVYINIT:
	LEA	$DFF000,A5		; Base dei registri CUSTOM per Offsets
	MOVE.W	$2(A5),OLDDMA		; Salva il vecchio status di DMACON
	MOVE.W	$1C(A5),OLDINTENA	; Salva il vecchio status di INTENA
	MOVE.W	$10(A5),OLDADKCON	; Salva il vecchio status di ADKCON
	MOVE.W	$1E(A5),OLDINTREQ	; Salva il vecchio status di INTREQ
	MOVE.L	#$80008000,d0		; Prepara la maschera dei bit alti
					; da settare nelle word dove sono
					; stati salvati i registri
	OR.L	d0,OLDDMA	; Setta il bit 15 di tutti i valori salvati
	OR.L	d0,OLDADKCON	; dei registri hardware, indispensabile per
				; rimettere tali valori nei registri.

	MOVE.L	#$7FFF7FFF,$9A(a5)	; DISABILITA GLI INTERRUPTS & INTREQS
	MOVE.L	#0,$144(A5)		; SPR0DAT - ammazza il puntatore!
	MOVE.W	#$7FFF,$96(a5)		; DISABILITA I DMA

	bsr.s	START			; Esegui il programma.

	LEA	$dff000,a5		; Custom base per offsets
	MOVE.W	#$7FFF,$96(A5)		; DISABILITA TUTTI I DMA
	MOVE.L	#$7FFF7FFF,$9A(A5)	; DISABILITA GLI INTERRUPTS & INTREQS
	MOVE.W	#$7fff,$9E(a5)		; Disabilita i bit di ADKCON
	MOVE.W	OLDADKCON(PC),$9E(A5)	; ADKCON 
	MOVE.W	OLDDMA(PC),$96(A5)	; Rimetti il vecchio status DMA
	MOVE.W	OLDINTENA(PC),$9A(A5)	; INTENA STATUS
	MOVE.W	OLDINTREQ(PC),$9C(A5)	; INTREQ
	RTS

;	Dati salvati dalla startup

WBVIEW:			; Indirizzo del View del WorkBench
	DC.L	0
GfxName:
	dc.b	'graphics.library',0,0
IntuiName:
	dc.b	'intuition.library',0

GfxBase:		; Puntatore alla Base della Graphics Library
	dc.l	0
IntuiBase:		; Puntatore alla Base della Intuition Library
	dc.l	0
OLDDMA:			; Vecchio status DMACON
	dc.w	0
OLDINTENA:		; Vecchio status INTENA
	dc.w	0
OLDADKCON:		; Vecchio status ADKCON
	DC.W	0
OLDINTREQ:		; Vecchio status INTREQ
	DC.W	0

START:
;	 PUNTIAMO IL NOSTRO BITPLANE

	MOVE.L	#BITPLANE,d0
	LEA	BPLPOINTERS,A1
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane e copper

	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

mouse:
	btst	#6,$bfe001
	bne.s	mouse
	rts


	Section	CopProva,data_C

COPPERLIST:
	dc.w	$8E,$2c81	; DiwStrt
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$0038	; DdfStart
	dc.w	$94,$00d0	; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod
		    ; 5432109876543210
	dc.w	$100,%0001001000000000	; 1 bitplane LOWRES 320x256

BPLPOINTERS:
	dc.w $e0,0,$e2,0	;primo	 bitplane

	dc.w	$0180,$000	; color0 - SFONDO
	dc.w	$0182,$19a	; color1 - SCRITTE

;	Sfumatura copperlist

	dc.w	$5007,$fffe	; WAIT linea $50
	dc.w	$180,$001	; color0
	dc.w	$5207,$fffe	; WAIT linea $52
	dc.w	$180,$002	; color0
	dc.w	$5407,$fffe	; WAIT linea $54
	dc.w	$180,$003	; color0
	dc.w	$5607,$fffe	; WAIT linea $56
	dc.w	$180,$004	; color0
	dc.w	$5807,$fffe	; WAIT linea $58
	dc.w	$180,$005	; color0
	dc.w	$5a07,$fffe	; WAIT linea $5a
	dc.w	$180,$006	; color0
	dc.w	$5c07,$fffe	; WAIT linea $5c
	dc.w	$180,$007	; color0
	dc.w	$5e07,$fffe	; WAIT linea $5e
	dc.w	$180,$008	; color0
	dc.w	$6007,$fffe	; WAIT linea $60
	dc.w	$180,$009	; color0
	dc.w	$6207,$fffe	; WAIT linea $62
	dc.w	$180,$00a	; color0

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;	Con il comando dcb facciamo un disegno a caso per il bitplane

BITPLANE:
	dcb.l	10240/4,$FF00FF00

	end

Ci sono due particolari che non figurano nella lezione: il primo e' che c'e'
una routine che resetta il modo video degli sprite, in caso il kickstart sia
il 3.0 o superiore.
Il secondo particolare e' che e' stata aggiunta una istruzione a quelle
presenti per disabilitare l'AGA:

	move.w	#$11,$10c(a5)		; Disattiva l'AGA

In realta' anche questa istruzione e' quasi superflua, perche' quasi mai e'
fuori posto, ma anche qua la sicurezza non deve essere trascurata.

Provate a spegnere i canali dma dei bitplane e del copper, uno ad uno.
Noterete che spegnendo solo il canale dei bitplane sparisce il disegno
a barre, disabilitando il copper sparisce pure la sfumatura.
Provate anche a disattivare solo il bit 9, l'interruttore generale, e vedrete
che anche se gli atri bit sono attivati si spegne tutto.
Inutile provare ad azzerare il bit 15!

