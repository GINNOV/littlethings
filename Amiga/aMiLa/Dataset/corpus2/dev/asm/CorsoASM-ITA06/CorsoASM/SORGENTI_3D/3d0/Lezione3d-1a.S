
	section	DotCube3d,code

; Mouse destra/sinistra e su/giu': trasla X ed Y
; Tasto sinistro/destro mouse = trasla Z (avvicina/allontana)

*****************************************************************************
	include	"Assembler2:sorgenti4/startup1.s" ; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001111000000	; copper, bitplane e blitter

LarghSchermo	=	320
LunghSchermo	=	256

START:
	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA
	move.l	#0,$108(a5)

	move.b	$dff00a,mouse_y	; JOY0DAT posizione verticale mouse
	move.b	$dff00b,mouse_x	; posizione orizzontale mouse

LoopMain:
	lea	$dff000,a5
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$12c00,d2	; linea da aspettare = $12c.
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $130 (304)
	BNE.S	Waity1

	BSR.w	ScambiaEpulisci		; Scambia gli schermi in doublebuffer e
				; pulisci lo schermo vecchio

	bsr.s	Leggimouse	; Legge lo spostamento del mouse per aggiornare
				; i valori di traslazione X ed Y

; Ora con il tasto destro e sin. del mouse possiamo operare una traslazione
; rispetto all'asse Z, che avvicina o allontana l'oggetto.

	btst.b	#6,$bfe001	; tasto sinistro?
	bne.s	NonAllontana
	cmp.w	#40*50,ZADD	; Siamo vicinissimi?
	beq.s	NonAllontana	; Se si non facciamocelo venire in faccia!
	ADD.W	#40,ZADD	; traslazione di allontanamento da noi
NonAllontana:
	btst.b	#2,$dff016	; tasto destro?
	bne.s	NonAvvicina
	CMP.W	#-40,ZADD	; Siamo lontanissimi?
	beq.s	NonAvvicina	; Se si puo' bastare!
	SUB.W	#40,ZADD	; Traslazione di avvicinamento a noi
	btst.b	#6,$bfe001	; anche il tasto sinistro e' premuto?
	beq.s	ESCIMI		; Se si allora esci!
NonAvvicina:

	BSR.w	TRASLAZIONE	; TRASLAZIONE dell'oggetto secondo i valori
				; delle variabili XADD, YADD e ZADD.

	BSR.w	PROSPETTIVA	; PROIEZIONE PROSPETTICA. I punti traslati
				; sono proiettati sul "monitor".

	bsr.w	DisegnaOggetto	; Disegna l'oggetto (semplici punti X,Y)

	bra.s 	LoopMain	; Pronti per il prossimo frame

ESCIMI:
	rts

******************************************************************************
; Questa routine legge il mouse e aggiorna i valori contenuti nelle
; variabili XADD e YADD, che servono per la traslazione.
******************************************************************************

LeggiMouse:
	move.b	$dff00a,d1	; JOY0DAT posizione verticale mouse
	move.b	d1,d0		; copia in d0
	sub.b	mouse_y(PC),d0	; sottrai vecchia posizione mouse
	beq.s	no_vert		; se la differenza = 0, il mouse e` fermo
	ext.w	d0		; trasforma il byte in word
				; (vedi alla fine del listato)
	add.w	d0,YADD		; modifica posizione cubo
no_vert:
  	move.b	d1,mouse_y	; salva posizione mouse per la prossima volta

	move.b	$dff00b,d1	; posizione orizzontale mouse
	move.b	d1,d0		; copia in d0
	sub.b	mouse_x(PC),d0	; sottrai vecchia posizione
	beq.s	no_oriz		; se la differenza = 0, il mouse e` fermo
	ext.w	d0		; trasforma il byte in word
				; (vedi alla fine del listato)
	add.w	d0,XADD		; modifica pos. CUBO
no_oriz:
  	move.b	d1,mouse_x	; salva posizione mouse per la prossima volta
	RTS

MOUSE_Y:	dc.b	0	; qui viene memorizzata la Y del mouse
MOUSE_X:	dc.b	0	; qui viene memorizzata la X del mouse

****************************************************************************
* ROUTINE CHE ESEGUE LA ROTAZIONE PROSPETTICA.				   *
*									   *
* Sorgente: tabella "PuntiXYZtraslati", con 3 coordinate XYZ per punto	   *
*									   *
* Destinazione: tabella "PuntiXYproiettati", con 2 coordinate X¹,Y¹	   *
*									   *
* L'unica altra variabile e' la distanza Z dell'osservatore dallo schermo, *
* che in questo caso e' 255, in modo da poter fare un "ASL #8" anziche'    *
* una dispendiosa moltiplicazione.					   *
****************************************************************************

PROSPETTIVA:
	LEA	PuntiXYZtraslati(PC),A0	 ; Indirizzo tab. delle X,Y,Z da
					 ; proiettare (gia' traslate)
	LEA	PuntiXYproiettati(PC),A1 ; Tabella dove mettere le coordinate
					 ; X¹,Y¹ proiettate.
	MOVE.w	#LarghSchermo/2,D3 ; X centro dello schermo (per centrare)
	MOVE.W 	#LunghSchermo/2,D4 ; Y centro dello schermo (per centrare)

	MOVE.w	#NPuntiOggetto-1,D7	; numero di punti da proiettare
Proiez:
	MOVEM.W	(a0)+,d0-d2 ; coord. X in d0, Y in d1, Z in d2
	ASL.L	#8,d0	   ; (MULS #255) DistZossSchermo*Xogg
	ASL.L	#8,d1	   ; (MULS #255) DistZossSchermo*Yogg
	ADD.W	#255,d2	   ; Zogg+DistZossSchermo
	DIVS.w	D2,D0	   ; (DistZoss_Schermo*Xogg)/(Zogg-DistZossSchermo)
	DIVS.w	D2,D1	   ; (DistZoss_Schermo*Yogg)/(Zogg-DistZossSchermo)
	ADD.W	d3,D0	   ; + coord X centro dello schermo (per centrare)
	ADD.W 	d4,D1	   ; + coord Y centro dello schermo (per centrare)
	MOVEM.W	D0-D1,(A1) ; Salva i val X¹ e Y¹ Proiettati e traslati
	ADDQ.W	#2+2,A1	   ; Saltiamo ai prossimi 2 val.
	DBRA 	D7,Proiez  ; Ripeti NumeroPunti volte per tutti i punti.
	RTS		   ; fino a che non li hai proiettati tutti

****************************************************************************
* Routine di traslazione, che semplicemente aggiunge il valore delle       *
* variabili XADD,YADD,ZADD alle coordinate dell'oggetto, causandone lo     *
* "spostamento" nello spazio.						   * 
****************************************************************************

TRASLAZIONE:
	lea	Oggetto1(PC),a0		; Coord x,y,z dell'oggetto (sorgente)
	LEA	PuntiXYZtraslati(PC),A1	; Tabella per i punti ruotati X,
					; ossia la destinazione!
	MOVE.w	#NPuntiOggetto-1,D7	; numero di punti da traslare
TRLOOP:
	movem.w	(a0)+,d0/d1/d2	; X in d0, Y in d1, Z in d2
	add.w	XADD(PC),d0	; X traslato (+ = destra, - = sinistra)
	add.w	YADD(PC),d1	; Y traslato (+ = basso, - = alto)
	add.w	ZADD(PC),d2	; Z traslato (+ = indietro, - = avanti)
	move.w	D0,(A1)+	; Salva la X in PuntiXYZtraslati
	move.w	D1,(A1)+	; Salva la Y in PuntiXYZtraslati
	move.w	D2,(A1)+	; Salva la Z in PuntiXYZtraslati
	DBRA 	D7,TRLOOP	; Esegui NumeroPunti volte, per ruotare tutti
	RTS			; i punti.

XADD:
	dc.w	0
YADD:
	dc.w	0
ZADD:
	dc.w	0

******************************************************************************
**	ROUTINES DI DISEGNO DELL'OGGETTO 3d SUL BITPLANE (con i punti!)	    **
******************************************************************************

DisegnaOggetto:
	lea	PuntiXYproiettati(PC),a4 ; buffer Coordinate X¹ ed X¹
	moveq	#NPuntiOggetto-1,d7	; numero punti da plottare
	move.l	DrawPlane(pc),a0	; Indirizzo schermo attuale in a0
PlottaLoop:
	movem.w	(a4)+,d0-d1	; Coord X¹ in d0 e Coord Y¹ in d1
	bsr.s	plotPIX		; Stampa il punto alla coord. X=d0, Y=d1
	dbra	d7,PlottaLoop	; Stampa tutti i punti
	rts

*****************************************************************************
;			Routine di plot dei punti (dots)
*****************************************************************************

;	Parametri in entrata di PlotPIX:
;
;	a0 = Indirizzo bitplane destinazione
;	d0.w = Coordinata X (0-319)
;	d1.w = Coordinata Y (0-255)

LargSchermo	equ	40	; Larghezza dello schermo in bytes.

PlotPIX:
	cmp.w	#320,d0	; Siamo fuori?
	blo.s	Ok1
	rts
Ok1:
	cmp.w	#256,d1	; Siamo fuori?
	blo.s	Ok2
	rts
Ok2:
	move.w	d0,d2		; Copia la coordinata X in d2
	lsr.w	#3,d0		; Intanto trova l'offset orizzontale,
				; dividendo per 8 la coordinata X.
	mulu.w	#largschermo,d1
	add.w	d1,d0		; Somma scost. verticale a quello orizzontale

	and.w	#%111,d2	; Seleziona solo i primi 3 bit di X
				; (in realta' sarebbe il resto della divisione
				;  per 8, fatta in precedenza)
	not.w	d2

	bset.b	d2,(a0,d0.w)	; Setta il bit d2 del byte distante d0 bytes
				; dall'inizio dello schermo.
	rts

*************************************************
*	Swap Logical and Physical Screens	*
*************************************************

ScambiaEpulisci:
	MOVE.L 	SCREEN(PC),D0
	CMP.L 	DrawPlane(PC),D0	; Is current screen=screen1
	BNE.s	SWAPIT			; No then branch
	MOVE.L 	SCREEN(PC),D0		; Display Screen1
	BSR.s	PuntaPlaneInCop		; Insert it Into Copper
	MOVE.L 	SCREEN1(PC),DrawPlane	; Screen2 = Logical 
	MOVE.L 	SCREEN1(PC),A1		; Address to Clear
	BSR.w	CpuClearScreen		; Do it !!!
  	RTS
  	
SWAPIT:
	MOVE.L 	SCREEN1(PC),D0		;Use screen2
	BSR.s	PuntaPlaneInCop		;Insert screen
	MOVE.L 	SCREEN(PC),DrawPlane	;screen1=logical
	MOVE.L 	SCREEN(PC),A1		;address to clear
	BSR.w	CpuClearScreen
	RTS
	
PuntaPlaneInCop:
	LEA	BplPointer,A0	; Puntatori in copperlist
	MOVE 	D0,6(A0)	; punta il plane
	SWAP 	D0
	MOVE 	D0,2(A0)
	RTS


DrawPlane:
	dc.l	Bitplane

; Puntatori ai 2 schermi per il Double Buffering

SCREEN:
	dc.l Bitplane0
SCREEN1:
	dc.l Bitplane

******************************************************************************
*	Routine di CLEAR dello schermo tramite il processore
*
*	A1 = Indirizzo dello schermo da pulire
******************************************************************************

CpuClearScreen:
	MOVEM.L	D0-D7/A0-A6,-(SP)	; Salva tutti i registri
	MOVE.L	SP,OLDSP		; Salva lo STACK POINTER per usarlo
	LEA	40*LunghSchermo(a1),SP	; Carica in SP l'indirizzo della
					; fine dello schermo, dato che con
					; i movem si pulira' "all'indietro".
	MOVEM.L	CLREG(PC),D0-D7/A0-A6	; Azzeriamo tutti i registri con
					; un solo movem da un buffer di zeri.

; Ora azzeriamo la memoria con molti "MOVEM.L D0-D7/A0-A6,-(SP)" eseguiti
; consecutivamente. Ogni istruzione azzera 60 bytes (15 registri da una long
; fanno 15*4=60 bytes), scrivendo in -(SP). Attenzione che si parte dalla
; fine dello schermo (in basso) e si "sale", indietreggiando nella memoria.
; In esadecimale il movem e' assemblato come "$48E7FFFE", per cui basta
; mettere un "dcb.l numero_istruzioni,$48e7fffe".

	dcb.l	170,$48E7FFFE		; 60*170=10200 bytes azzerati.

	movem.l	d0-d7/a0-a1,-(SP)	; Gli ultimi 40 bytes... (tot. 10240)

	MOVE.L	OLDSP(PC),SP		; Rimetti il vecchio SP
	MOVEM.L	(SP)+,D0-D7/A0-A6	; E ripristina il valore dei registri
	RTS

; 15 longs azzerate da caricare nei registri per azzerarli

CLREG:
	dcb.l	15,0

OLDSP:
	dc.l	0

******************************************************************************
* definizione del solido 3d tramite le coordinate X,Y,Z dei suoi punti.      *
******************************************************************************

;	MENO< X >PIU'		MENO			PIU'
;				 ^			/|
;				 Y		       Z
;				 v		     |/
;				PIU'		   MENO

;	      (P4) -50,-50,+50______________+50,-50,+50 (P5)
;			     /|		   /|
;			    / |		  / |
;			   /  |		 /  |
;			  /   |		/   |
;	 (P0) -50,-50,-50/____|________/+50,-50,-50 (P1)
;			|     |       |     |
;			|     |_______|_____|+50,+50,+50 (P6)
;			|    /-50,+50,+50 (P7)
;			|   /	      |   /
;			|  /	      |  /
;			| /	      | /
;			|/____________|/+50,+50,-50 (P2)
;	 (P3) -50,+50,-50

Oggetto1:			; Ecco gli 8 punti definiti dalle coord. X,Y,Z
	dc.w	-50,-50,-50	; P0 (X,Y,Z)
	dc.w	+50,-50,-50	; P1 (X,Y,Z)
	dc.w	+50,+50,-50	; P2 (X,Y,Z)
	dc.w	-50,+50,-50	; P3 (X,Y,Z)
	dc.w	-50,-50,+50	; P4 (X,Y,Z)
	dc.w	+50,-50,+50	; P5 (X,Y,Z)
	dc.w	+50,+50,+50	; P6 (X,Y,Z)
	dc.w	-50,+50,+50	; P7 (X,Y,Z)

NPuntiOggetto	= 8

******************************************************************************
;		    dati e variabili della routine			     *
******************************************************************************

; Buffer per i punti modificati (ruotati e/o Traslati nello spazio 3d).

PuntiXYZtraslati:
	DS.W	NPuntiOggetto*3

; --------------------------------------------------------------------------

;	Coordinate X¹ ed Y¹ proiettate, ossia in prospettiva, pronte per
;	essere disegnate. Nel buffer sono salvate le coordinate a coppie
;	X¹ ed Y¹ consecutive: XY,XY,XY,XY,XY..., una word ogni coordinata.

PuntiXYproiettati:
	DS.W	NPuntiOggetto*2

; --------------------------------------------------------------------------

	Section	Copperlist,data_C

COPPERLIST:
	DC.W $120,0
	DC.W $122,0
	DC.W $008e,$2C81
	DC.W $0090,$20C1
	DC.W $0092,$0038
	DC.W $0094,$00d0
	DC.W $0108,0
	DC.W $010a,0
	DC.W $0102,0
	DC.W $100,%0001001000000000
	DC.W $180,0,$182,$FFFF,$184,$ffff
Bplpointer:
	DC.W $E0,0,$E2,0
	DC.W $FFFF,$FFFE

	section	planes,bss_C

bitplane0:
	ds.b	40*LunghSchermo

bitplane:
	ds.b	40*LunghSchermo

	end

