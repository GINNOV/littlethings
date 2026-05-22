
; Lezione8h.s - Un Utilizzo della routine UniMuoviSprite per fare un pannello
;		di controllo con gadgets

	SECTION	CiriCop,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup1.s"	; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001110100000	; solo copper,bitplane,sprite DMA
;		 -----a-bcdefghij

;	a: Blitter Nasty
;	b: Bitplane DMA
;	c: Copper DMA
;	d: Blitter DMA
;	e: Sprite DMA
;	f: Disk DMA
;	g-j: Audio 3-0 DMA

START:
	bsr.w	PuntaFig1	; Puntiamo la Fig.1
	bsr.w	PuntaFigBase	; Puntiamo la Fig.base

	move.l	#BufferVuoto,d0	; punta uno spazio azzerato dove sara'
	LEA	BPLPOINTER2,A1	; stampato il testo
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

	move.b	$dff00a,mouse_y		; Diamo alle variabili mouse_y-x il
	move.b	$dff00b,mouse_x		; valore attuale in lettura del mouse

;*****************************************************************************
; 				LOOP PRINCIPALE
;*****************************************************************************

Clear:
	clr.b	Azione		; Riazzera le variabili
	clr.b	TastoAzionato
	clr.b	EsciVar

Programma:
	****1
	btst	#6,$bfe001	; Tasto Sinistro del mouse premuto? Se no
	bne.s	Contprog	; continua il programma, altrimenti:
	bsr.w	CheckAzione	; Controlla quale tasto abbiamo premuto
	cmpi.b	#1,TastoAzionato; Se abbiamo premuto uno dei "tasti" la
	beq.s	Comando		; variante "TastoAzionato" e'=1; andiamo
				; a controllare quale tasto abbiamo cliccato!
Contprog:
	bsr.w	MuoviFreccia	; routine che legge/muove il mouse
	bra.s	Programma	; Fine del programma: ritorniamo da capo!

;*****************************************************************************
;	Routine "Comando" di interpretazione del tasto premuto
;*****************************************************************************

; Nella variabile "AZIONE" troviamo un valore, il quale è stato immesso
; precedentemente dalla routine "CheckAzione". Controllando il suo valore
; possiamo sapere quale tasto abbiamo "clicckato", ed andare ad eseguire il
; suo corrispettivo programmino.

Comando:
	cmpi.b	#$f,Azione	; Se azione e' "f", abbiamo cliccato sul tasto
	beq.s	Verde		; VERDE
	cmpi.b	#$e,Azione	; Se azione e' "e", abbiamo cliccato sul tasto
	beq.w	Rosso		; VERDE
	cmpi.b	#$d,Azione	; Se azione e' "d", abbiamo cliccato sul tasto
	beq.w	Giallo		; GIALLO
	cmpi.b	#7,Azione	; Se azione e' "7", abbiamo cliccato sul tasto
	beq.w	Music_On	; Music_On
	cmpi.b	#6,Azione	; Se azione e' "6", abbiamo cliccato sul tasto
	beq.w	Music_Off	; Music_Off
	cmpi.b	#5,Azione	; Se azione e' "5", abbiamo cliccato sul tasto
	beq.w	Esci		; Quit
	cmpi.b	#4,Azione	; Se azione e' "4", abbiamo cliccato sul tasto
	beq.w	PalNtsc		; PalNtsc
	cmpi.b	#3,Azione	; Se azione e' "3", abbiamo cliccato sul tasto
	beq.w	Piu		; Piu
	cmpi.b	#$2,Azione	; Se azione e' "2", abbiamo cliccato sul tasto
	beq.w	Meno		; Meno
;	cmpi.b	#1,Azione	; Se azione e' "1", abbiamo cliccato sul tasto
	bra.w	GiuSu		; GiuSu (In verita', e' rimasto solo questa
				; possibilita',dunque ci saltiamo direttamente

;*****************************************************************************

Verde:
	bsr.w	MuoviFreccia	; routine che legge/muove il mouse
	lea	Barra+6,a6	; Per far tornare la moltiplicazione
	move.b	#$1,ColorB	; Memoriziamo quale colore stiamo visualizzando
	move.w	#$0030,(a6)	; Cambiamo i COLORI della barra (la distanza
	move.w	#$0060,8(a6)	; tra un wait e l'altro e' di 8 bytes)
	move.w	#$0090,8*2(a6)
	move.w	#$00c0,8*3(a6)
	move.w	#$00f0,8*4(a6)
	move.w	#$00c0,8*5(a6)
	move.w	#$0090,8*6(a6)
	move.w	#$0060,8*7(a6)
	move.w	#$0030,8*8(a6)
	bra.w	Clear		; Ritorniamo da capo!

;*****************************************************************************

Rosso:
	bsr.w	MuoviFreccia	; routine che legge/muove il mouse
	lea	Barra+6,a6	; Per far tornare la moltiplicazione
	move.b	#$2,ColorB	; Memoriziamo quale colore stiamo visualizzando
	move.w	#$0300,(a6)	; Cambiamo i wait della barra (la distanza
	move.w	#$0600,8(a6)	; tra un wait e l'altro e' di 8 bytes)
	move.w	#$0900,8*2(a6)
	move.w	#$0c00,8*3(a6)
	move.w	#$0f00,8*4(a6)
	move.w	#$0c00,8*5(a6)
	move.w	#$0900,8*6(a6)
	move.w	#$0600,8*7(a6)
	move.w	#$0300,8*8(a6)
	bra.w	Clear		; Ritorniamo da capo!

;*****************************************************************************

Giallo:
	bsr.w	MuoviFreccia	; routine che legge/muove il mouse
	lea	Barra+6,a6	; Per far tornare la moltiplicazione
	clr.b	ColorB		; Memoriziamo quale colore stiamo visualizzando
	move.w	#$0310,(a6)	; Cambiamo i wait della barra (la distanza
	move.w	#$0640,8(a6)	; tra un wait e l'altro e' di 8 bytes)
	move.w	#$0970,8*2(a6)
	move.w	#$0ca0,8*3(a6)
	move.w	#$0fd0,8*4(a6)
	move.w	#$0ca0,8*5(a6)
	move.w	#$0970,8*6(a6)
	move.w	#$0640,8*7(a6)
	move.w	#$0310,8*8(a6)
	bra.w	Clear		; Ritorniamo da capo!

;*****************************************************************************

PaNtFlag:
	dc.w	0

PalNtsc:
	bchg.b	#1,PaNtflag
	btst.b	#1,PaNtflag
	beq.s	VaiPal
	move.w	#0,$1dc(a5)	; BEAMCON0 (ECS+) Risuluzione video NTSC
	bra.w	Clear		; Ritorniamo da capo!
VaiPal
	move.w	#$20,$1dc(a5)	; BEAMCON0 (ECS+) Risoluzione video PAL
	bra.w	Clear


;*****************************************************************************

; Ricordiamoci di mettere SEMPRE la routine "MuoviFreccia" nei punti, ad
; esempio come il seguente, che non ritorna ad eseguire il programma principale
; fino a che non è premuto il tasto sinistro del mouse. Se fosse ommesso,
; il mouse non si muoverebbe fino a che non rilasciamo il tasto del mouse!

Piu:
	bsr.w	MuoviFreccia	; routine che legge/muove il mouse
	lea	barra,a6	; Mettiamo in a5, l'indirizzo di "BARRA", così
				; evitando di riscriverla ogni volta, ed
				; inoltre risulta più veloce l'esecuzione!
	cmpi.b	#$84,8*9(a6)	; Siamo arrivati alla linea $84?
	beq.s	FinePiu		; Se si, siamo in cima, e fermiamoci.
	addq.b	#1,(a6)		; Muoviamo la posizione della barra di un pixel
	addq.b	#1,8(a6)	; alla volta
	addq.b	#1,8*2(a6)
	addq.b	#1,8*3(a6)
	addq.b	#1,8*4(a6)
	addq.b	#1,8*5(a6)
	addq.b	#1,8*6(a6)
	addq.b	#1,8*7(a6)
	addq.b	#1,8*8(a6)
	addq.b	#1,8*9(a6)

**2
	btst.b	#6,$bfe001	; Finchè il tasto sinistro non è rilasciato
	beq.s	Piu		; la barra continua a muoversi, nonstante il
				; mouse non sia più sopra il tasto "+":
				; Provate ad aggiundere sotto la prima linea
				; "bsr.w Muovifreccia" la label "PIU2", e
				; cambiare anche la linea sotto ***2 in 
				; "beq.s Piu2". Nonostante che muoviate il 
				; mouse, la freccia non si muoverà!

	bra.w	Clear		; Torniamo da capo!!

; siamo arrivati in fondo? Allora barra BLU

FinePiu:
	bsr.w	MuoviFreccia	; routine che legge/muove il mouse
	lea	Barra+6,a6	; Barra in coplist
	move.w	#$0003,(a6)	; Cambiamo i COLORI della barra in BLU
	move.w	#$0006,8(a6)
	move.w	#$0009,8*2(a6)
	move.w	#$000c,8*3(a6)
	move.w	#$000f,8*4(a6)
	move.w	#$000c,8*5(a6)
	move.w	#$0009,8*6(a6)
	move.w	#$0006,8*7(a6)
	move.w	#$0003,8*8(a6)
	btst.b	#6,$bfe001	; Finchè il tasto sinistro non è rilasciato
	beq.s	FinePiu		; la barra continua a muoversi, nonstante il
				; mouse non sia più sopra il tasto "+"
	cmp.b	#1,ColorB	; Controlliamo di quale colore era prima
				; la barra tramite la variabile ColorB:
				; Se risulta di valore "1", allora la barra è
				; di colore verde:
	beq.w	Verde		; Andiamo alla label VERDE, riporatando così la
				; barra al suo colore originario
	cmp.b	#2,ColorB	; Anche qui, se la variabile risulta di valore
	beq.w	Rosso		; "2", andiamo alla label ROSSO
	bra.w	Giallo		; Se non si è verificata nessuna condizione
				; precedente, INEVITABILMENTE la barra è
				; GIALLA, perchè i colori possibili appunto
				; sono  tre: rosso, verde o giallo!

;*****************************************************************************

Meno:
	bsr.w	Muovifreccia	; Vale il solito discorso sopra, solo che 
	lea	barra,a6	; aggiungere il valore "1" a "barra",
	cmpi.b	#$36,8*9(a6)	; Siamo arrivati in fondo?
	beq.s	FineMeno	; se si ferma tutto e colora la barra di BLU
	subq.b	#1,(a6)		; sottraiamo, facendola muovere in direzione
	subq.b	#1,8(a6)	; opposta (verso l'alto)
	subq.b	#1,8*2(a6)
	subq.b	#1,8*3(a6)
	subq.b	#1,8*4(a6)
	subq.b	#1,8*5(a6)
	subq.b	#1,8*6(a6)
	subq.b	#1,8*7(a6)
	subq.b	#1,8*8(a6)
	subq.b	#1,8*9(a6)
	**3
	btst.b	#6,$bfe001
	beq.s	Meno
	bra.w	Clear		; Torniamo da capo!!

; siamo arrivati in cima? Allora barra blu!

FineMeno:
	bsr.w	MuoviFreccia	; routine che legge/muove il mouse
	lea	Barra+6,a6
	move.w	#$0003,(a6)	; colora di BLU
	move.w	#$0006,8(a6)
	move.w	#$0009,8*2(a6)
	move.w	#$000c,8*3(a6)
	move.w	#$000f,8*4(a6)
	move.w	#$000c,8*5(a6)
	move.w	#$0009,8*6(a6)
	move.w	#$0006,8*7(a6)
	move.w	#$0003,8*8(a6)
	btst.b	#6,$bfe001
	beq.s	FineMeno
	cmpi.b	#$1,ColorB	; Controlla di quale colore era la barra
	beq.w	Verde
	cmpi.b	#$2,ColorB
	beq.w	Rosso
	bra.w	Giallo

;*****************************************************************************

Music_On:
	move.b	#1,MusicFlag	; Dando il valore "1" alla variabile MusicFlag,
				; ogni qualvolta che la testeremo, sapremo 
				; quando la musica è stata attivata.
	move.l	a5,-(SP)	; salva a5 nello stack
	bsr.w	mt_init		; Saltiamo alla routine che suona la musica
	move.l	(SP)+,a5	; riprendi a5 dallo stack

	**4
;	bsr.w	MuoviFreccia	; routine che legge/muove il mouse
	bra.w	Clear		; Ritorniamo da capo!

;*****************************************************************************

Music_Off:
	clr.b	MusicFlag	; Dando il valore "0" alla variabile MusicFlag,
				; ogni qualvolta che la testeremo, sapremo 
				; quando la musica è stata disattivata.
	move.l	a5,-(SP)	; salva a5 nello stack
	bsr.w	mt_end		; Saltiamo alla routine che ferma la musica
	move.l	(SP)+,a5	; riprendi a5 dallo stack
	**5
;	bsr.w	MuoviFreccia	; routine che legge/muove il mouse
	bra.w	Clear		; Ritorniamo da capo!

;*****************************************************************************
;			Rirtono alla OldCop
;*****************************************************************************

Esci:				; Usciamo dal programma!!!
	move.l	a5,-(SP)	; salva a5 nello stack
	bsr.w	mt_end		; Spegniamo la musica!!!: Se abbiamo premuto
				; il tasto "ESCI", mentre la musica stava
				; suonando, succede del casino
	move.l	(SP)+,a5	; riprendi a5 dallo stack
	rts


*******************************************************************************
*				Vari BSR				      *
*******************************************************************************

PuntaFig1:
	MOVE.L	#picture1,d0
	moveq	#4-1,d1		; 4 bitplane!
	LEA	BPLPOINTERS,A1
POINTBPa:
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	ADD.L	#40*84,d0	; La figura e' alta 84 linee, non 256!!
	addq.w	#8,a1
	dbra	d1,POINTBPa

;	Puntiamo tutti gli sprite allo sprite nullo, per essere sicuri che
;	non ci siano problemi.

	MOVE.L	#SpriteNullo,d0		; indirizzo dello sprite in d0
	LEA	SpritePointers,a1	; Puntatori in copperlist
	MOVEQ	#8-1,d1			; tutti gli 8 sprite
NulLoop:
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	addq.w	#8,a1
	dbra	d1,NulLoop

; Puntiamo il primo sprite

	MOVE.L	#MIOSPRITE0,d0
	LEA	SpritePointers,a1
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	rts			; Ritorno al BSR

PuntaFigBase:	
	MOVE.L	#picturebase,d0
	LEA	BPLPOINTERSbase,A1
	moveq	#0,d1		; 1 bitplane!
POINTBPbasenew:
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	ADD.L	#40*105,d0	; La figura e' alta 105 linee, non 256!!
	addq.w	#8,a1
	dbra	d1,POINTBPbasenew
	rts			; Ritorno

******************************************************************************
; Questa routine controlla se abbiamo premuto in un "bottone"/"gadget" o
; dove non ci sono comandi. Nel caso si sia premuto un "bottone", assegna
; il valore corrispondente al "bottone" premuto alla variabile Azione.
******************************************************************************


;                 _,'|             _.-''``-...___..--';)
;                /_ \'.      __..-' ,      ,--...--'''
;               ¶     .`--'''       `     /'
;                `-';'               ;   ; ;
;          __...--''     ___...--_..'  .;.'
;         (,__....----'''       (,..--''
;||||||||///|||||||||||||||||||||||||||||||||||||||||||||||||||||

CheckAzione:

; Prima controllo le posizioni Y

	move.b	#$1,TastoAzionato	; Ipotiziamo anticipatamente che
					; abbiamo premuto dentro uno dei tasti
					; dando alla variabile "TastoAzionato"
					; il valore "1"
	cmpi.w	#$00fc,Sprite_y		; La freccia e' sotto la posizione dei
					; tasti?, cioe'
					; Sprite_y e' > di 00fc, Se si:
	bhi.s	rtnCheck		; Siamo fuori!
	cmpi.w	#$00f1,Sprite_y		; La freccia e' allineata alla linea
					; del "Cambia colore VERDE"?
;
	bhi.w	Effetto_Verde		; Se si: vai ad Azione verde
;
	cmpi.w	#$00fe,Sprite_y		; Siamo tra 00f1 e 00fe? Se si:
	bhi.s	rtnCheck		; Siamo fuori!
	cmpi.w	#$00e4,Sprite_y		; La freccia e' allineata alla linea
					; del "Cambia colore ROSSO"?
;
	bhi.w	Effetto_Rosso		; Se si: vai ad Azione rosso
;
	cmpi.w	#$00e1,Sprite_y		; Siamo tra 00e1 e 00d7? Se si:
	bhi.s	rtnCheck		; Siamo fuori!
	cmpi.w	#$00d7,Sprite_y		; La freccia e' allineata alla linea
					; del "Cambia colore GIALLO"?
;
	bhi.w	Effetto_Giallo		; Se si: vai ad Azione giallo
;
	cmpi.w	#$00d0,Sprite_y		; Siamo tra 00d7 e 00d0? Se si:
	bhi.s	rtnCheck		; Siamo fuori!

	cmpi.w	#$00b0,Sprite_y		; La freccia e' tra i tasti "+","-",
;					; "Pal-Ntsc","Esci"...
	bhi.s	Azione_Tasti		; Se si: vai ad Azione_Tasti
;
rtnCheck:
	clr.b	TastoAzionato		; Non avendo premuto nessun tasto,
	rts				; evitiamo al programma di perdere
					; tempo facendo subito rileggere 
					; la posizione del mouse, tramite la
					; variabile "TastoAzionato"

;*****************************************************************************
; Ora che sappiamo che la Y e' quella di qualche "bottone", controlliamo
; anche se la X e' quella giusta!
;*****************************************************************************

Azione_Tasti:
	cmpi.w	#$0111,Sprite_x		; La freccia e' oltre il tasto
					; "Musica Off"? Se si:
	bhi.s	rtnCheck		; Siamo fuori!
	cmpi.w	#$00ea,Sprite_x		; La freccia e' tra il tasto
					; "Musica Off"? Se si:
	bhi.w	Effetto_Off_Music	; Vai a Effetto_Off_Music

	cmpi.w	#$00dc,Sprite_x		; La freccia e' tra 00ea e 00dc? Se si:
	bhi.s	rtnCheck		; Siamo fuori!
	cmpi.w	#$00b3,Sprite_x		; La freccia e' sopra il tasto
					; "Musica_On"? Se si:
	bhi.w	Effetto_On_Music	; Vai a Effetto_On_Music
	cmpi.w	#$00ab,Sprite_x		; La freccia e' oltre i  tasti
					; "Pal/Ntsc" e "Quit"
	bhi.s	rtnCheck		; Siamo fuori!
	cmpi.w	#$0077,Sprite_x		; La freccia e' tra i  tasti
					; "Pal/Ntsc,Quit"?
	bhi.s	Quale_Due2		; Vediamo quale dei "Pal/Ntsc" o "Quit"
	cmpi.w	#$006c,Sprite_x		; La freccia e' tra 77 e 6c?
	bhi.s	rtnCheck		; Siamo fuori!
	cmpi.w	#$005d,Sprite_x		; La freccia e' tra i tasti
					; "+" e "-"?
	bhi.s	Quale_Due1		; Vediamo quale dei "+" o "-"
	cmpi.w	#$004f,Sprite_x		; La freccia e' tra 77 e 6c?
	bhi.s	rtnCheck		; Siamo fuori!
	cmpi.w	#$003e,Sprite_x		; La freccia e' sul tasto merda:-><-!!
	bhi.s	Effetto_GiuSu		; Andiamo ad Effetto_GiuSu
	bra.s	rtnCheck		; Se non si è verificata nessuna azione
					; allora andiamo a rtnCheck

Quale_Due2:
	cmpi.w	#$00c3,Sprite_y		; La freccia si trova sopra il tasto
	bhi.w	Effetto_Quit		; "Quit"? Se si vai a Effetto_Quit
	cmpi.w	#$00bc,Sprite_y		; La freccia e' tra 00c3 e 00bc?
	bhi.w	rtnCheck		; Siamo in mezzo ai due tasti!
	cmpi.w	#$00b0,Sprite_y		; La freccia e' tra 00bc e 00b0?
	bhi.w	Effetto_Pal		; Andiamo a Effetto_Pal
	
Quale_Due1:
	cmpi.w	#$00c3,Sprite_y		; La freccia si trova sopra il tasto
	bhi.s	Effetto_Piu		; "Piu"? Se si, vai a Effetto_Piu
	cmpi.w	#$00bc,Sprite_y 	; La freccia e' tra 00bc e 00c3?
	bhi.w	rtnCheck		; Siamo in mezzo ai due tasti!
	cmpi.w	#$00b0,Sprite_y		; La freccia e' tra 00b0 e 00bc?
	bhi.w	Effetto_Meno		; Andiamo a Effetto_Meno


;*****************************************************************************
; Ora diamo alla Variabile Azione il valore del tasto che e' premuto
;*****************************************************************************

Effetto_Verde:				; Se si e' verificata questa condizione
	move.b	#$d,Azione		; vuol dire che ci troviamo sopra la 
	rts				; barra VERDE! Allora informiamo il 
					; programma che e' stato premuto
					; questo "tasto" tramite la variabile
					; Azione, dandole il valore "d".
Effetto_Rosso:
	move.b	#$e,Azione		; Uguale a sopra, solo che per il tasto
	rts				; -Rosso- diamo il valore "e".

Effetto_Giallo:
	move.b	#$f,Azione		; Uguale a sopra, solo che per il tasto
	rts				; -Giallo- diamo il valore  "f".

Effetto_GiuSu:
	move.b	#$1,Azione		; Uguale a sopra, solo che per il tasto
	rts				; -GiuSu- diamo il valore di "1".

Effetto_Piu:
	move.b	#$2,Azione		; Uguale a sopra, solo che per il tasto
	rts				; -Piu- diamo il valore di "2".

Effetto_Meno:
	move.b	#$3,Azione		; Uguale a sopra, solo che per il tasto
	rts				; -Meno- diamo il valore di "3".

Effetto_Pal:
	move.b	#$4,Azione		; Uguale a sopra, solo che per il tasto
	rts				; -Pal- diamo il valore di "4".

Effetto_Quit:
	move.b	#$5,Azione		; Uguale a sopra, solo che per il tasto
	rts				; -Quit- diamo il valore di "5".

Effetto_Off_Music
	move.b	#$6,Azione		; Uguale a sopra, solo che per il tasto
	rts				; -Off_Misic- diamo il valore di "6".

Effetto_On_Music
	move.b	#$7,Azione		; Uguale a sopra, solo che per il tasto
	rts				; -On_Music- diamo il valore di "7".
	
*************************************************************************
* Routine che legge la posizione del mouse				*
* immettendo le coordinate in Mouse_x/Mouse_y - Sprite_x/Sprite_Y	*
*************************************************************************

LeggiMouse:
	move.b	$a(a5),d1	; $dff00a - JOY0DAT byte alto
	move.b	d1,d0
	sub.b	mouse_y(PC),d0
	beq.s	no_vert
	ext.w	d0
	add.w	d0,sprite_y
no_vert:
  	move.b	d1,mouse_y
	move.b	$b(a5),d1	; $dff00a - JOY0DAT - byte basso
	move.b	d1,d0
	sub.b	mouse_x(PC),d0
	beq.s	no_oriz
	ext.w	d0
	add.w	d0,sprite_x
no_oriz:
	move.b	d1,mouse_x
	cmpi.w	#$0021,sprite_x		; Posizione x minima? (bordo sinistro)
	bpl.b	s1			; se non ancora, non occorre bloccare.
	move.w	#$0021,sprite_x		; Altrimenti, blocchiamolo alla
					; posizione $21.. NON OLTRE!!
s1:
	cmpi.w	#$0004,sprite_y		; Posizione y minima? (inizio schermo)
	bpl.b	s2			; se non ancora, non bloccare
	move.w	#$0004,sprite_y		; altrimenti inchioda lo sprite al
					; bordo superiore sinistro
s2:
	cmpi.w	#$011d,sprite_x		; Posizione x massima? (bordo destro)
	ble.b	s3			; se non ancora, non occorre bloccare
	move.w	#$011d,sprite_x		; Altrimenti blocchiamolo a $11d
s3:
	cmpi.w	#$00ff,sprite_y		; Posizione y massuma? (fondo schermo)
	ble.b	s4			; se non ancora, non bloccare
	move.w	#$00ff,sprite_y		; Altrinenti bloccare a $ff
s4:
	rts

*********************************************************
*		Routine che muove lo sprite0		*
*********************************************************
;	a1 = Indirizzo dello sprite
;	d0 = posizione verticale Y dello sprite sullo schermo (0-255)
;	d1 = posizione orizzontale X dello sprite sullo schermo (0-320)
;	d2 = altezza dello sprite

UniMuoviSprite:
	ADD.W	#$2c,d0
	MOVE.b	d0,(a1)
	btst.l	#8,d0
	beq.s	NonVSTARTSET
	bset.b	#2,3(a1)
	bra.s	ToVSTOP
NonVSTARTSET:
	bclr.b	#2,3(a1)
ToVSTOP:
	ADD.w	D2,D0
	move.b	d0,2(a1)
	btst.l	#8,d0
	beq.s	NonVSTOPSET
	bset.b	#1,3(a1)
	bra.b	VstopFIN
NonVSTOPSET:
	bclr.b	#1,3(a1)
VstopFIN:
	add.w	#128,D1
	btst	#0,D1
	beq.s	BitBassoZERO
	bset	#0,3(a1)
	bra.s	PlaceCoords
BitBassoZERO:
	bclr	#0,3(a1)
PlaceCoords:
	lsr.w	#1,D1
	move.b	D1,1(a1)
	rts

*******************************************************************************
*		LOOP di temporizzazione e aggiornamento sprite		      *
*******************************************************************************

MuoviFreccia:

; Questa è una routine di temporizzazione perchè viene usato come riferimento
; il pennello elettronico, a 50Hz (a meno che non si stia usando il sistema
; NTSC! (60Hz!) ). Appunto, il pennello in tutti i computer ha la stessa
; velocità, sia nei vecchi A500 che negli A4000.

	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$0fe00,d2	; linea da aspettare = $fe, ossia 254
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $fe (254)
	BNE.S	Waity1


	tst.b	MusicFlag	; Se MusicFlag è "0", allora la musica non è
	beq.w	NoMusic2		; stata accesa, per cui saltiamo la linea 
				; seguente
	move.l	a5,-(SP)	; salva a5 nello stack
	bsr.w	mt_music	; Suona la musica se è stato premuto il tasto
				; "On_Music"
	move.l	(SP)+,a5	; riprendi a5 dallo stack

NoMusic2:
	bsr.w	LeggiMouse	; Salta alla routine che legge la posizione del
				; mouse
	move.w	sprite_y(pc),d0	; Prepara le coordinate di y
	move.w	sprite_x(pc),d1	; Prepara le coordinate di x
	lea	miosprite0,a1	; seleziona lo sprite da muovere
	moveq	#13,d2		; Prepara la lunghezza dello sprite
	bsr.w	UniMuoviSprite	; Saltiamo alla routine che muove lo sprite
	bsr.w	PrintCarattere	; Scrivi il testo

	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$0fe00,d2	; linea da aspettare = $0fe, ossia 254
Aspetta:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $0fe (254)
	BEQ.S	Aspetta

	rts

;***************************************************************************
; Effetto "speciale" della chiusura e apertura col DIWSTART/STOP
;***************************************************************************

	
GiuSu:
	bsr.w	SchermoChiudi	; Saltiamo alla routine che chiude lo schermo
	bsr.w	SchermoApri	; Saltiamo alla routine che apre lo schermo
	bra.w	Clear		; Ritorniamo da capo!

;*****************************************************************************

SchermoChiudi:
	bsr.w	MuoviFreccia	; aspetta che sia passato 1 ciclo FRAME!!
	ADDQ.B	#1,DiwYStart	; Caliamo di un pixel lo schermo superiore
	SUBQ.B	#1,DIWySTOP	; Aumentiamo di un pixel lo schermo inferiore
	CMPI.b	#$ad,DiwYStart	; Se abbiamo raggiunto la posizione desiderata,
	beq.s	Finito3		; allora usciamo, altrimenti azzeriamo la
	bra.s	SchermoChiudi	; pixel
Finito3:
	rts

SchermoApri:
	bsr.w	MuoviFreccia	; invece si farlo aumentare, lo facciamo
				; diminuire, cioe' invertiamo:
				; addq #1,DiwyStart
	SUBQ.B	#5,DiwYStart	; subq #1,DiwyStop
	ADDQ.B	#5,DIWySTOP	; rispettivamente con
	CMPI.B	#$2c,DiwYStop	; subq #5,DiwyStart
	beq.w	Finito4		; addq #5,DiwyStop
	bra.s	SchermoApri
Finito4:
	rts


*******************************************************************************
*				Dati					      *
*******************************************************************************
Azione:
	dc.l	0
TastoAzionato:
	dc.l	0
EsciVar
	dc.l	0
ColorB:
	dc.b	2
	even

MusicFlag:
	dc.w	0
		
SPRITE_Y:	dc.w	$a0	; qui viene memorizzata la Y dello sprite
				; Cambiando questo valore possiamo cambiare Y
				; la posizione iniziale del muose 
SPRITE_X:	dc.w	0	; qui viene memorizzata la X dello sprite
				; Cambiando questo valore possiamo cambiare X
				; la posizione iniziale del muose
MOUSE_Y:	dc.b	0	; qui viene memorizzata la Y del mouse
MOUSE_X:	dc.b	0	; qui viene memorizzata la X del mouse

*****************************************************************************
;			Routine di Print
*****************************************************************************

PRINTcarattere:
	MOVE.L	PuntaTESTO(PC),A0 ; Indirizzo del testo da stampare in a0
	MOVEQ	#0,D2		; Pulisci d2
	MOVE.B	(A0)+,D2	; Prossimo carattere in d2
	CMP.B	#$ff,d2		; Segnale di fine testo? ($FF)
	beq.s	FineTesto	; Se si, esci senza stampare
	TST.B	d2		; Segnale di fine riga? ($00)
	bne.s	NonFineRiga	; Se no, non andare a capo

	ADD.L	#40*7,PuntaBITPLANE	; ANDIAMO A CAPO
	ADDQ.L	#1,PuntaTesto		; primo carattere riga dopo
					; (saltiamo lo ZERO)
	move.b	(a0)+,d2		; primo carattere della riga dopo
					; (saltiamo lo ZERO)

NonFineRiga:
	SUB.B	#$20,D2		; TOGLI 32 AL VALORE ASCII DEL CARATTERE, IN
				; MODO DA TRASFORMARE, AD ESEMPIO, QUELLO
				; DELLO SPAZIO (che e' $20), in $00, quello
				; DELL'ASTERISCO ($21), in $01...
	LSL.W	#3,D2		; MOLTIPLICA PER 8 IL NUMERO PRECEDENTE,
				; essendo i caratteri alti 8 pixel
	MOVE.L	D2,A2
	ADD.L	#FONT,A2	; TROVA IL CARATTERE DESIDERATO NEL FONT...

	MOVE.L	PuntaBITPLANE(PC),A3 ; Indir. del bitplane destinazione in a3

				; STAMPIAMO IL CARATTERE LINEA PER LINEA
	MOVE.B	(A2)+,(A3)	; stampa LA LINEA 1 del carattere
	MOVE.B	(A2)+,40(A3)	; stampa LA LINEA 2  " "
	MOVE.B	(A2)+,40*2(A3)	; stampa LA LINEA 3  " "
	MOVE.B	(A2)+,40*3(A3)	; stampa LA LINEA 4  " "
	MOVE.B	(A2)+,40*4(A3)	; stampa LA LINEA 5  " "
	MOVE.B	(A2)+,40*5(A3)	; stampa LA LINEA 6  " "
	MOVE.B	(A2)+,40*6(A3)	; stampa LA LINEA 7  " "
	MOVE.B	(A2)+,40*7(A3)	; stampa LA LINEA 8  " "

	ADDQ.L	#1,PuntaBitplane ; avanziamo di 8 bit (PROSSIMO CARATTERE)
	ADDQ.L	#1,PuntaTesto	; prossimo carattere da stampare

FineTesto:
	RTS


PuntaTesto:
	dc.l	TESTO

PuntaBitplane:
	dc.l	BufferVuoto+40*3

;	$00 per "fine linea" - $FF per "fine testo"

		; numero caratteri per linea: 40
TESTO:	     ;		  1111111111222222222233333333334
             ;   1234567890123456789012345678901234567890
	dc.b	'                                        ',0 ; 1
	dc.b	'    Usa il mouse per spostare la        ',0 ; 2
	dc.b	'                                        ',0 ; 3
	dc.b	'    barra, cambiarla di colore,         ',0 ; 4
	dc.b	'                                        ',0 ; 5
	dc.b	'    suonare la musica o "chiudere"      ',0 ; 6
	dc.b	'                                        ',0 ; 7
	dc.b	'    lo schermo con il DIWSTART/STOP     ',$FF ; 12

	EVEN

;	Il FONT caratteri 8x8 copiato in CHIP dalla CPU e non dal blitter,
;	per cui puo' stare anche in fast ram. Anzi sarebbe meglio!

FONT:
	incbin	"assembler2:sorgenti4/nice.fnt"

*******************************************************************************
*			ROUTINE MUSICALE
*******************************************************************************

	include	"music.s"

*******************************************************************************
;			MEGACOPPERLISTONA GALATTICA (quasi...)
*******************************************************************************


	SECTION	GRAPHIC,DATA_C


COPPERLIST:
SpritePointers:
	dc.w	$120,0,$122,0,$124,0,$126,0,$128,0 ; SPRITE
	dc.w	$12a,0,$12c,0,$12e,0,$130,0,$132,0
	dc.w	$134,0,$136,0,$138,0,$13a,0,$13c,0
	dc.w	$13e,0

	dc.w	$8E	; DiwStrt
DiwYStart:
	dc.b	$30
DIWXSTART:
	dc.b	$81
	dc.w	$90	; DiwStop
DIWYSTOP:
	dc.b	$2c
DIWXSTOP:
	dc.b	$c1
	dc.w	$92,$38		; DdfStart
	dc.w	$94,$d0		; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,$24		; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

		    ; 5432109876543210
	dc.w	$100,%0100001000000000	; BPLCON0 - 4 planes lowres (16 colori)

; Bitplane pointers

BPLPOINTERS:
	dc.w $e0,0,$e2,0	;primo	 bitplane
	dc.w $e4,0,$e6,0	;secondo bitplane
	dc.w $e8,0,$ea,0	;terzo	 bitplane
	dc.w $ec,0,$ee,0	;quarto	 bitplane

; i primi 16 colori sono per il LOGO

	dc.w $180,$000,$182,$fff,$184,$200,$186,$310
	dc.w $188,$410,$18a,$620,$18c,$841,$18e,$a73
	dc.w $190,$b95,$192,$db6,$194,$dc7,$196,$111
	dc.w $198,$222,$19a,$334,$19c,$99b,$19e,$446


	dc.w	$1A2,$fff	; color17   Colore
	dc.w	$1A4,$fa6	; color18   del
	dc.w	$1A6,$000	; color19   mouse

BARRA:
	dc.w	$5c07,$FFFE	; aspetto la linea $50
	dc.w	$180,$300	; inizio la barra rossa: rosso a 3
	dc.w	$5d07,$FFFE	; linea seguente
	dc.w	$180,$600	; rosso a 6
	dc.w	$5e07,$FFFE
	dc.w	$180,$900	; rosso a 9
	dc.w	$5f07,$FFFE
	dc.w	$180,$c00	; rosso a 12
	dc.w	$6007,$FFFE
	dc.w	$180,$f00	; rosso a 15 (al massimo)
	dc.w	$6107,$FFFE
	dc.w	$180,$c00	; rosso a 12
	dc.w	$6207,$FFFE
	dc.w	$180,$900	; rosso a 9
	dc.w	$6307,$FFFE
	dc.w	$180,$600	; rosso a 6
	dc.w	$6407,$FFFE
	dc.w	$180,$300	; rosso a 3
	dc.w	$6507,$FFFE
	dc.w	$180,$000	; colore NERO


; barra rossa sotto il logo

	dc.w	$8407,$fffe	; fine del logo

BPLPOINTER2:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane

	dc.w	$100,$1200	; 1 bitplane (azzerato)

	dc.w	$8507,$FFFE	; linea seguente
	dc.w	$180,$606	; viola
	dc.w	$8607,$FFFE
	dc.w	$180,$909	; viola
	dc.w	$8707,$FFFE
	dc.w	$180,$c0c	; viola
	dc.w	$8807,$FFFE
	dc.w	$180,$f0f	; viola (al massimo)
	dc.w	$8907,$FFFE
	dc.w	$180,$c0c	; viola
	dc.w	$8a07,$FFFE
	dc.w	$180,$909	; viola
	dc.w	$8b07,$FFFE
	dc.w	$180,$606	; viola
	dc.w	$8c07,$FFFE
	dc.w	$180,$303	; viola
	dc.w	$8d07,$FFFE
	dc.w	$180,$000	; colore NERO

	dc.w	$182,$fe3	; Colore testo

; barrettone centrale

	dc.w	$9007,$FFFE	; linea seguente

	dc.w	$180,$011	; celestino a 11
	dc.w	$9507,$FFFE
	dc.w	$180,$022	; celestino a 22
	dc.w	$9a07,$FFFE
	dc.w	$180,$033	; celestino a 33
	dc.w	$9f07,$FFFE
	dc.w	$180,$055	; celestino a 55
	dc.w	$a407,$FFFE
	dc.w	$180,$077	; celestino a 77
	dc.w	$a907,$FFFE
	dc.w	$180,$099	; celestino a 99
	dc.w	$ae07,$FFFE
	dc.w	$180,$077	; celestino a 77
	dc.w	$b307,$FFFE
	dc.w	$180,$055	; celestino a 55
	dc.w	$b807,$FFFE
	dc.w	$180,$033	; celestino a 33
	dc.w	$bd07,$FFFE
	dc.w	$180,$022	; celestino a 22
	dc.w	$c207,$FFFE
	dc.w	$180,$011	; celestino a 11

*****Figura di base:

	dc.w	$c607,$FFFE	; Aspettiamo la linea c6
	dc.w	$180,$000	; colore NERO

		    ; 5432109876543210
	dc.w	$100,%0001001000000000	; 1 bitplane sempre LoRes

BPLPOINTERSbase:
	dc.w $e0,$0000,$e2,$0000
CopBase:	
	dc.w $0180,$0000,$0182,$0877

; barra rossa sopra il pannello

	dc.w	$ca07,$FFFE	; linea seguente
	dc.w	$180,$606	; rosso
	dc.w	$cb07,$FFFE
	dc.w	$180,$909	; rosso
	dc.w	$cc07,$FFFE
	dc.w	$180,$c0c	; rosso
	dc.w	$cd07,$FFFE
	dc.w	$180,$f0f	; rosso (al massimo)
	dc.w	$ce07,$FFFE
	dc.w	$180,$c0c	; rosso
	dc.w	$cf07,$FFFE
	dc.w	$180,$909	; rosso
	dc.w	$d007,$FFFE
	dc.w	$180,$606	; rosso
	dc.w	$d107,$FFFE
	dc.w	$180,$303	; rosso
	dc.w	$d207,$FFFE
	dc.w	$180,$000	; colore NERO

	dc.w	$ca07,$FFFE	; WAIT - Aspetto la linea $ca
	dc.w	$180,$001	; COLOR0 - blu scurissimo
	dc.w	$cc07,$FFFE	; WAIT - linea 74 ($4a)
	dc.w	$180,$002	; blu un po' piu' intenso
	dc.w	$ce07,$FFFE	; linea 75 ($4b)
	dc.w	$180,$003	; blu a 3
	dc.w	$d007,$FFFE	; prossima linea
	dc.w	$180,$004	; blu a 4
	dc.w	$d207,$FFFE	; prossima linea
	dc.w	$180,$005	; blu a 5
	dc.w	$d407,$FFFE	; prossima linea
	dc.w	$180,$006	; blu a 6
	dc.w	$d607,$FFFE	; salto 2 linee: da $4e a $50, ossia da 78 a 80
	dc.w	$180,$007	; blu a 7
	dc.w	$d807,$FFFE	; sato 2 linee
	dc.w	$180,$008	; blu a 8
	dc.w	$da07,$FFFE	; salto 3 linee
	dc.w	$180,$009	; blu a 9
	dc.w	$e007,$FFFE	; salto 3 linee
	dc.w	$180,$00a	; blu a 10
	dc.w	$e507,$FFFE	; salto 3 linee
	dc.w	$180,$00b	; blu a 11
	dc.w	$ea07,$FFFE	; salto 3 linee
	dc.w	$180,$00c	; blu a 12
	dc.w	$f007,$FFFE	; salto 4 linee
	dc.w	$180,$00d	; blu a 13
	dc.w	$f507,$FFFE	; salto 5 linee
	dc.w	$180,$00e	; blu a 14
	dc.w	$fa07,$FFFE	; salto 6 linee
	dc.w	$180,$00f	; blu a 15

	dc.w	$ffdf,$FFFE	; aspetta linea $ff

	dc.w	$0207,$FFFE	; aspetto
	dc.w	$182,$0f0	; colore 1 verde

	dc.w	$0f07,$FFFE	; aspetto
	dc.w	$182,$f22	; colore 1 rosso

	dc.w	$1c07,$FFFE	; aspetto
	dc.w	$182,$ff0	; colore 1 giallo

	dc.w	$2907,$FFFE	; aspetto
	dc.w	$182,$877	; colore 1 grigio

	dc.w	$FFFF,$FFFE	; Fine della copperlist

*******************************************************************************
*				Sprite					      *
*******************************************************************************
; Come sempre, la grafica va SOLO caricata in CHIP come la Copperlist!!

MIOSPRITE0:
VSTART0:
	dc.b $50
HSTART0:
	dc.b $45
VSTOP0:
	dc.b $5d
VHBITS0:
	dc.b $00
 dc.w	%0110000000000000,%1000000000000000
 dc.w	%0001100000000000,%1110000000000000
 dc.w	%1000011000000000,%1111100000000000
 dc.w	%1000000110000000,%1111111000000000
 dc.w	%0100000000000000,%0111111110000000
 dc.w	%0100000000000000,%0111111000000000
 dc.w	%0010000100000000,%0011111000000000
 dc.w	%0010010010000000,%0011111100000000
 dc.w	%0001001001000000,%0001101110000000
 dc.w	%0001000100100000,%0001100111000000
 dc.w	%0000000010000000,%0000000011100000
 dc.w	%0000000000000000,%0000000000000000
 dc.w	%0000000000000000,%0000000000000000
 dc.w	0,0


SpriteNullo:			; Sprite nullo da puntare in copperlist
	dc.l	0,0,0,0		; negli eventuali puntatori inutilizzati

PICTUREbase:
	incbin	"base320*105*1.raw"

; Disegno largo 320 pixel, alto 84, a 4 bitplanes (16 colori).

PICTURE1:
	incbin	"logo320*84*16c.raw"


; Musica. Attenzione: la routine "music.s" del disco 2 non e' la stessa di
; quella del disco 1. Le 2 modifiche sono la rimossione di un BUG che alle
; volte causava una guru all'uscita del programma, e il fatto che in mt_data
; e' un puntatore alla musica, e non LA musica. Questo permette di cambiare
; la musica piu' facilmente.

mt_data:
	dc.l	mt_data1

mt_data1:
	incbin	"mod.JamInExcess"

	Section	MiniBitplane,bss_c

;	In questo buffer viene stampato il testo

BufferVuoto:
	ds.b	40*68

	end			; Il Computer non legge oltre l' END!
				; Adesso possiamo scrivere qualsiasi cosa senza
				; i PUNTI e VIRGOLA o ASTERISCHI


Volendo un effetto video diverso ad ogni "tasto premuto", dovremo sapere
se il tasto sinistro e' premuto e, in tal caso, sapere la posizione dello
sprite del mouse. In poche parole dovremo sapere quale tasto è stato premuto 
per eseguire un diverso effetto-video:

Appena partiamo col programma troviamo un controllo: 'Tasto sinistro premuto?',
se il tasto non e' stato premuto continueremo col programma aggiornando
la posizione del mouse, muovendo la freccia per lo schermo, se invece e' stato
premuto, saltiamo ad una routine che compara la posizione di:
 - Sprite_x
 - Sprite_y
con le coordinate dove si trovano i nostri tasti!

**************************** Trucchetto del mestiere *************************

Ma come si fa a sapere le coordinate X ed Y dei nostri "bottoni"? tranquilli,
non dovete fare miliardi di prove o calcoli ad occhio! Dato che ASMONE ha
un monitor L.M. incorporato, possiamo fare in questo modo: disegnatevi il
pannello di controllo che volete, con i vostri bottoncini; una volta puntato
e visualizzato il tutto, con la routine del mouse, e' giusto il momento di
sapere a quali coordinate corrispondono i bottoni.

Se volete verificare la posizione di ogni tasto basta mettere all'inizio del
programma (al posto di ****1), questo semplice loop:

Aspetta:
	bsr.w	LeggiMouse
	move.w	sprite_y(pc),d0
	move.w	sprite_x(pc),d1
	lea	miosprite0,a1
	moveq	#13,d2
	bsr.w	UniMuoviSprite
	btst	#2,$dff016
	bne.w	Aspetta
	bra.w	esci	

il quale aggiorna la posizione del mouse, lo muove e, quando viene premuto il
tasto sinistro del mouse, usciamo semplicemente dal programma!!
Posizionatevi alla coordinata che volete sapere, ad esempio un angolo di un
bottone, e uscite col tasto sinistro rimanendo in quel punto.
Ora bastera' solamente vedere le ultime posizioni assunte dal mouse con il
mitico comando "M" (dopo aver premuto il tasto ESC):

	m Sprite_x   (premere RETURN)
	m Sprite_y   (premere RETURN)

il comando "M" e' utilissimo. Viene usato molto per verificare a che "punto"
o con quale "valore" si e' arrivati. Per esempio se voleste far fermare uno
sprite o una barra ad un certo punto, basta fare un loop che lo fa avanzare
fino a che non si preme il mouse. Lanciate il programma, premete il mouse
quando e' arrivato al punto che volete, e fare "M variabile". Semplice!!!

***************************************************************************

Come prova, provate a far apparire lo sprite in posti diversi dello schermo al
momento dell'avviamento del programma, inoltre provate a far restare il
puntatore del mouse nel rettangolo della figura inferiore.

Una cosa che avrete senz'altro notato, è il fatto che se premiamo il tasto "+"
o "-", e non rilasciamo il tasto sinistro del mouse, la barra continua
imperterrita a muoversi anche se spostiamo la freccia fuori dal bottone:
questo perchè, come spiegato nel punto **2, fino a che non abbiamo rilasciato
il tasto del mouse, il programma non riverifica la posizione del mouse!
Per modificare questo fatto, basta aggiungere al punto **2:

	bsr.s	MuoviFreccia

ommettendo ovviamente il 

	btst.b	#6,$bfe001
	beq.s	Piu

Provate anche a cambiare il punto **3

Adesso aggiungete solo :

	brs.s	MuoviFreccia 

Ai punti **4, **5, e guardate cosa succede:
basta entrare o uscire dal tasto che parte il suo effetto!

A differenza degli altri tasti, per quelli "cambia colore a barra", basta
solamente passarci sopra col mouse premuto per avere l'effeto desiderato!
Adesso dovreste essere capaci di sapere il perche'!

Infine, I tasti che attivano e disattivano la musica "bloccano" anche la
freccia.... a voi l'arduo problema di capire perche'.

