
	section	DotCube3d,code


; TRASLAZIONE+ROTAZIONE: attenzione che la rotazione avviene sempre rispetto
; al centro, per cui se si trasla l'oggetto poi fa dei "giri" intorno al
; centro, quasi follemente.

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

	ADDQ.W	#1,ZANGLE	; rotazione attorno ad asse che ci viene
				; incontro, lo vedremmo come un punto .,
				; dunque l'oggetto ruota come le lancette di
				; un'orologio se SUBBATO, o in senso
				; antiorario se ADDATO.
	ADDQ.W	#2,YANGLE	; rotazione attorno ad asse VERTICALE |
	ADDQ.W	#1,XANGLE	; rotazione attorno ad asse ORIZZONTALE --

	bsr.s	Leggimouse	; Legge lo spostamento del mouse per aggiornare
				; i valori di traslazione X ed Y

; Ora con il tasto destro e sin. del mouse possiamo operare una traslazione
; rispetto all'asse Z, che avvicina o allontana l'oggetto.

	btst.b	#6,$bfe001	; tasto sinistro?
	bne.s	NonAllontana
	cmp.w	#40*20,ZADD	; Siamo vicinissimi?
	beq.s	NonAllontana	; Se si non facciamocelo venire in faccia!
	ADDQ.W	#2,ZADD	; traslazione di allontanamento da noi
NonAllontana:
	btst.b	#2,$dff016	; tasto destro?
	bne.s	NonAvvicina
	CMP.W	#0,ZADD	; Siamo lontanissimi?
	beq.s	NonAvvicina	; Se si puo' bastare!
	SUBQ.W	#2,ZADD	; Traslazione di avvicinamento a noi
	btst.b	#6,$bfe001	; anche il tasto sinistro e' premuto?
	beq.s	ESCIMI		; Se si allora esci!
NonAvvicina:

	BSR.w	TRASLAZIONE	; TRASLAZIONE dell'oggetto secondo i valori
				; delle variabili XADD, YADD e ZADD.

	BSR.w	ROTATE		;Rotate 3d Image

	BSR.w	PROSPETTIVA	; PROIEZIONE PROSPETTICA. I punti traslati
				; sono proiettati sul "monitor".

	bsr.w	DisegnaOggetto	; Disegna l'oggetto (semplici punti X,Y)

	bra.w 	LoopMain	; Pronti per il prossimo frame

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


****************************************************************************
* ROUTINE CHE ESEGUE LA PROIEZIONE PROSPETTICA.				   *
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
	ADD.W	#255,d2	   ; Zogg-DistZossSchermo
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

*************************************************************************
*	ROTAZIONE DELL'IMMAGINE PER GLI ANGOLI X,Y e Z			*
*									*
* 1) Innanzitutto vengono trovati i SENI e i COSENI degli angoli X,Y,Z	*
*    usando la subroutine SINCOS, la quale a sua volta li ricava da una *
*    tabella (SINTAB) la quale e' composta da 360 valori, ossia 1 valore*
*    per ogni grado possibile (da 0 a 360). Da notare che si usa un     *
*    trucco per evitare i numeri con la virgola: i valori della sintab, *
*    che dovrebbero essere compresi tra -1 e +1, sono moltiplicati per  *
*    16384, che corrisponde ad uno shift di 14 bit a sinitra. Con questi*
*    valori "interi", possiamo fare le moltiplicazioni senza virgole di *
*    mezzo, ed una volta fatte le operazioni possiamo dividere il numero*
*    ottenuto con degli LSR, che shiftano a destra di 14 bit.		*
*									*
* 2) Ottenuti i SENI e i COSENI di dei 3 angoli, vengono eseguiti i	*
*    calcoli necesari per la rotazione:					*
*						*
*	X rotation X1,Y1 Becomes		*
*						*
*	X2 = X1 COS(THETA) - Y1 SIN(THETA)	*
*	Y2 = Y1 COS(THETA) + X1 SIN(THETA)	*
*						*
*	Y rotation X2,Y2 Becomes		*
*						*
*	X3 = X2 COS(THETA) - Y2 SIN(THETA)	*
*	Y3 = Y2 COS(THETA) + X2 SIN(THETA)	*
*						*
*	Z rotation X3,Y3 Becomes		*
*						*
*	X4 = X3 COS(THETA) - Y3 SIN(THETA)	*
*	Y4 = Y3 COS(THETA) + X3 SIN(THETA)	*
*						*
*	Where THETA is angle to rotate by.	*
*************************************************

ROTATE:

; Trova il SENO (ZSIN) e il COSENO (ZCOS) per l'angolo Z (ZANGLE)

	CMP.w 	#360,ZANGLE	; l'angolo Z e' >360 gradi?
	BLT.s	ZOK		; meno di 360? se si ZOK
	CLR.w	ZANGLE		; se siamo a piu' di 360, azzera ZANGLE
ZOK:
	CMP.w	#-360,ZANGLE	; siamo arrivati a -360 gradi?
	BGT.s	Z1OK		; se non ancora, Z1OK
	CLR.w	ZANGLE		; se siamo a meno di -360, azzera ZANGLE
Z1OK:
	MOVE.w	ZANGLE(PC),D0
	BSR.w	SINCOS		; trova il valore SINCOS per l'angolo in d0
				; in uscita: d1 = SIN, d2 = COS
	MOVE.w	D1,ZSIN		; metti i valori nelle variabili
	MOVE.w	D2,ZCOS

; Trova il SIN e COS dell'angolo Y

	CMP.w	#360,YANGLE	; l'angolo Y e' >360?
	BLT.s	YOK		; se <360°, va bene
	CLR.w	YANGLE		; altrimenti, azzeralo
YOK:
	CMP.w	#-360,YANGLE	; siamo a -360°?
	BGT.s	Y1OK		; se >360° va bene
	CLR.w	YANGLE		; altrimenti azzera
Y1OK:
	MOVE.w	YANGLE(PC),D0
	BSR.w	SINCOS		; Trova SIN e COS dell'Angolo con la TABELLA
	MOVE.w	D1,YSIN		; e mettili nelle variabili
	MOVE.w	D2,YCOS

; Trova il SIN e COS dell'angolo Z

	CMP.w	#360,XANGLE	; l'angolo X e' > di 360°?
	BLT.s	XOK		; se minore, va bene
	CLR.w	XANGLE		; altrimenti azzeralo
XOK:
	CMP.w	#-360,XANGLE	; l'angolo X e' < di -360°
	BGT.s	X1OK		; se si, va bene
	CLR.w	XANGLE		; altrimenti azzeralo
X1OK:
	MOVE.w	XANGLE(PC),D0
	BSR.w	SINCOS		; Trova il SENO e il COSENO dell'angolo
	MOVE.w	D1,XSIN		; dalla tabella e mettili in XSIN e XCOS
	MOVE.w	D2,XCOS


; cordinate sorgente:


	LEA	PuntiXYZtraslati(PC),A0	; indirizzo tab. delle X,Y,Z da
					; proiettare dopo la traslazione e
					; rotazione - coord X

	LEA	PuntiXYZtraslati+2(PC),A1 ; Coords Y
	LEA	PuntiXYZtraslati+4(PC),A2 ; Coords Z

; come destinazione sovrascriviamo il buffer dei punti traslati

	MOVE.w	#NPuntiOggetto-1,D0	; numero di punti da proiettare
RLOOP1:
ZROTATE:
	MOVE.w	ZSIN(PC),D1
	MOVE.w	ZCOS(PC),D2
	MOVE.w	(A0),D3		; CoordXOggettoSpaz - prossima cordinata X
				; dalla tabella punti dell'oggetto
	MULS.w	D3,D2		; moltiplica CoordXOggettoSpaz*ZCOS
	MOVE.w	(A1),D3		; CoordYOggettoSpaz - prossima coordinata Y
	MULS.w	D3,D1	; moltiplica CoordYOggettoSpaz*ZSIN
	SUB.L 	D1,D2	; (CoordXOggettoSpaz*ZCOS)-(CoordYOggettoSpaz*ZSIN)

	LSR.L 	#8,D2	; shitfta di 14 bit a destra, dividendo per 16384,
	LSR.L 	#6,D2	; di conseguenza trovando il valore reale

	MOVE.w	D2,D5	; salva il valore ottenuto in d5

;

	MOVE.w	ZSIN(PC),D1
	MOVE.w	ZCOS(PC),D2
	MOVE.w	(A0),D3		; CoordXOggettoSpaz - prossima cordinata X
	MULS.w	D3,D1		; moltiplica CoordXOggettoSpaz*ZSIN
	MOVE.w	(A1),D3	; CoordYOggettoSpaz - prossima coordinata Y
	MULS.w	D3,D2	; moltiplica CoordYOggettoSpaz*ZCOS
	ADD.L	D1,D2	; (CoordXOggettoSpaz*ZSIN)+(CoordYOggettoSpaz*ZCOS)

	LSR.L 	#8,D2	; shitfta di 14 bit a destra, dividendo per 16384,
	LSR.L 	#6,D2	; di conseguenza trovando il valore reale

	MOVE 	D2,D6	; salva il valore ottenuto in d6

YROTATE:
	MOVE.w	YSIN(PC),D1
	MOVE.w	YCOS(PC),D2
	MOVE.w	(A2),D3		; CoordZOggettoSpaz - prossima coordinata Z
	MULS.w	D3,D2		; moltiplica CoordZOggettoSpaz*YCOS
	MOVE.w	D5,D3		; metti (CoordXOggettoSpaz*ZCOS) MENO
				; (CoordYOggettoSpaz*ZSIN) in d3
	MULS.w	D3,D1		; moltiplicalo per YSIN
	SUB.L 	D1,D2		; sottrai il valore trovato a YCOS

	LSR.L 	#8,D2	; shitfta di 14 bit a destra, dividendo per 16384,
	LSR.L 	#6,D2	; di conseguenza trovando il valore reale

	MOVE.w	D2,D7	; salva il valore ottenuto in d7

;

	MOVE.w	YSIN(PC),D1
	MOVE.w	YCOS(PC),D2
	MOVE.w	(A2),D3	; CoordZOggettoSpaz - prossima coordinata Z
	MULS.w	D3,D1		; moltiplica CoordZOggettoSpaz*YSIN
	MOVE.w	D5,D3		; metti (CoordXOggettoSpaz*ZCOS) MENO
				; (CoordYOggettoSpaz*ZSIN) in d3
	MULS.w	D3,D2		; moltiplicalo per YCOS
	ADD.L 	D1,D2	; somma il valore ottenuto a (CoordZOggettoSpaz*YSIN)

	LSR.L 	#8,D2	; shitfta di 14 bit a destra, dividendo per 16384,
	LSR.L 	#6,D2	; di conseguenza trovando il valore reale

****\
	MOVE.w	D2,D5	; COORD X RUOTATA OK - salva il valore ottenuto in d5
****/

XROTATE:
	MOVE.w	XSIN(PC),D1
	MOVE.w	XCOS(PC),D2
	MOVE.w	D6,D4    ; d4=(CoordXOggettoSpaz*ZSIN)+(CoordYOggettoSpaz*ZCOS)
	MOVE.w	D6,D3	 ; idem d3
	MULS.w	D3,D2	 ; moltiplica per XCOS
	MOVE.w	D7,D3
	MULS.w	D3,D1
	SUB.L 	D1,D2

	LSR.L 	#8,D2	; shitfta di 14 bit a destra, dividendo per 16384,
	LSR.L 	#6,D2	; di conseguenza trovando il valore reale

****\
	MOVE 	D2,D6	; COORD Y RUOTATA OK - salva il valore ottenuto in d6
****/

	MOVE 	XSIN(PC),D1
	MOVE 	XCOS(PC),D2
	MOVE 	D4,D3
	MULS 	D3,D1
	MOVE 	D7,D3
	MULS 	D3,D2
	ADD.L 	D1,D2

	LSR.L 	#8,D2	; shitfta di 14 bit a destra, dividendo per 16384,
	LSR.L 	#6,D2	; di conseguenza trovando il valore reale

****\
	MOVE 	D2,D7	; COORD Z RUOTATO OK - salva il valore ottenuto in d7
****/

	MOVE.w	D5,(A0)		; salva in pointxROT
	MOVE.w	D6,(A1)		; salva in pointyROT
	MOVE.w	D7,(A2)		; salva in pointzROT
	addq.w	#2*3,a0
	addq.w	#2*3,a1
	addq.w	#2*3,a2

	DBRA 	D0,RLOOP1	; esegui NumeroPunti volte, per ruotare tutti
				; i punti.
	RTS


*****************************************************************************
*	Trova il valore Sin/Cos per l'Angolo X in d0			    *
*	usando la tabella SINTAB.w, con 360 valori pronti per i 360 gradi   *
*	possibili in entrata						    *
*	in uscita: d1 = SIN(x), d2 = COS(x)				    *
*****************************************************************************

SINCOS:
	TST.w	D0	; angolo = ZERO?
	BPL.s	NOADDI	; se >0, vai a NOADDI
	ADD.w	#360,D0	; altrimenti aggiungo 360 ( il SIN di ZERO e' uguale
			; al SIN di 360)
NOADDI:
	LEA	SINTAB(PC),A1	; Indirizzo tabella con seni precalcolati
	MOVE.L 	D0,D2		; copia l'angolo in d2, dato che si deve
				; trovare sia il seno che il coseno

; trovo il seno

	add.w	d0,D0		; moltiplico *2 d0, ossia l'angolo, dato
				; che la tabella e' fatta di words (2 bytes)
	MOVE.w	0(A1,D0.w),D1	; per trovare il valore giusto del SENO
				; dell'angolo nella SINTAB
; trovo il coseno

	CMP.w	#270,D2		; l'angolo e' >270 gradi? (270+90=360!)
	BLT.s	PLUS90		; se no, vai a PLUS90, che aggiunge 90 gradi
				; ricavando l'angolo del coseno
	SUB.w	#270,D2		; se >270, togli 270, altrimenti aggiungendo
				; 90 per ricavare il coseno supereremmo il
				; 360; dato che il coseno e' uguale ogni
				; k*360 gradi (o 2kPiGreco), sottraiamo
				; 270, poi aggiungiamo 90 (270+90=360),
				; trovando il coseno del 2kPiGreco prima.
	BRA.s	SENDSIN

PLUS90:
	ADD.w	#90,D2		; aggiungo 90 gradi, dato che il COSENO e'
				; uguale al seno + 90 gradi
SENDSIN:
	add.w	d2,D2		; moltiplico *2 l'angolo, dato che la
				; tabella e' fatta di words (2 bytes)
	MOVE.w	(A1,D2),D2	; per trovare il valore giusto del COSENO
	RTS			; dalla tabella sommando d2 all'indirizzo
				; inizio della tabella.


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

XANGLE:	DC.W	0
YANGLE:	DC.W	0
ZANGLE:	DC.W	0

XSIN:	DC.W 0
XCOS:	DC.W 0

YSIN:	DC.W 0
YCOS:	DC.W 0

ZSIN:	DC.W 0
ZCOS:	DC.W 0

; Coordinate X ed Y dell'ORIGINE degli assi rispetto allo schermo, in questo
; caso li posizioniamo al centro.

; --------------------------------------------------------------------------

; Buffer per i punti modificati (ruotati e/o Traslati nello spazio 3d).

PuntiXYZtraslati:
	DS.W	NPuntiOggetto*3

; --------------------------------------------------------------------------

;	Coordinate X¹ ed Y¹ proiettate, ossia in prospettiva, pronte per
;	essere disegnate. Nel buffer sono salvate le coordinate a coppie
;	X¹ ed Y¹ consecutive: XY,XY,XY,XY,XY..., una word ogni coordinata.

PuntiXYproiettati:
	DS.W	NPuntiOggetto*2

*************************************************************************
*		Dati per la Tabella di Seni/Coseni:			*
*									*
* Usare numeri in virgola mobile (Floating Point) rende i calcoli troppo*
* lenti per poter fare un 3d in tempo reale.				*
* Per esempio il SIN di 1 grado e' 0,01745, il SIN(2°) e' 0,03489 ecc.	*
* In questo caso abbiamo usato uno "statagemma", infatti tutti i valori *
* sono prima moltiplicati per 16384.					*
* Infatti 0,01745*16384 fa 286, 0,3489*16384 fa 572, e cosi' per gli	*
* altri valori della SINTAB.						*
* Il trucco della velocita' sta nel fatto che moltiplicare per 16384	*
* significa SHIFTARE di 14 bit a sinistra, per cui per ritrovare il	*
* valore basta SHITFARE a destra di 14 bit con queste 2 istruzioni:	*
*									*
*	LSR.L 	#8,D2	; shitfta di 14 bit a destra			*
*	LSR.L 	#6,D2	; dividendo per 16384				*
*									*
* In questo modo ci sbarazziamo della virgola, moltiplicando e dividendo*
* il valore "ingigantito", poi dividendo il risultato per 16384 con i	*
* due LSR visti prima.							*
* Questa tabella e' in formato decimale per far capire meglio il suo	*
* contenuto; se volete rifarla con "IS" i parametri, ovviamente, sono:	*
*									*
* BEG>0									*
* END>360								*
* AMOUNT>360								*
* AMPLITUDE>16384							*
* YOFFSET>0								*
* SIZE (B/W/L)>W							*
* MULTIPLIER>1								*
*									*
*************************************************************************

SINTAB:
	DC.W 0,286,572,857,1143,1428,1713,1997,2280
	DC.W 2563,2845,3126,3406,3686,3964,4240,4516
	DC.W 4790,5063,5334,5604,5872,6138,6402,6664
	DC.W 6924,7182,7438,7692,7943,8192,8438,8682	
	DC.W 8923,9162,9397,9630,9860,10087,10311,10531
	DC.W 10749,10963,11174,11381,11585,11786,11982,12176
	DC.W 12365,12551,12733,12911,13085,13255,13421,13583
	DC.W 13741,13894,14044,14189,14330,14466,14598,14726
	DC.W 14849,14968,15082,15191,15296,15396,15491,15582
	DC.W 15668,15749,15826,15897,15964,16026,16083,16135
	DC.W 16182,16225,16262,16294,16322,16344,16362,16374
	DC.W 16382,16384
	DC.W 16382
	DC.W 16374,16362,16344,16322,16294,16262,16225,16182
	DC.W 16135,16083,16026,15964,15897,15826,15749,15668	
	DC.W 15582,15491,15396,15296,15191,15082,14967,14849
	DC.W 14726,14598,14466,14330,14189,14044,13894,13741	
	DC.W 13583,13421,13255,13085,12911,12733,12551,12365
	DC.W 12176,11982,11786,11585,11381,11174,10963,10749
	DC.W 10531,10311,10087,9860,9630,9397,9162,8923
	DC.W 8682,8438,8192,7943,7692,7438,7182,6924
	DC.W 6664,6402,6138,5872,5604,5334,5063,4790
	DC.W 4516,4240,3964,3686,3406,3126,2845,2563
	DC.W 2280,1997,1713,1428,1143,857,572,286,0
	DC.W -286,-572,-857,-1143,-1428,-1713,-1997,-2280
	DC.W -2563,-2845,-3126,-3406,-3686,-3964,-4240,-4516
	DC.W -4790,-5063,-5334,-5604,-5872,-6138,-6402,-6664
	DC.W -6924,-7182,-7438,-7692,-7943,-8192,-8438,-8682	
	DC.W -8923,-9162,-9397,-9630,-9860,-10087,-10311,-10531
	DC.W -10749,-10963,-11174,-11381,-11585,-11786,-11982,-12176
	DC.W -12365,-12551,-12733,-12911,-13085,-13255,-13421,-13583
	DC.W -13741,-13894,-14044,-14189,-14330,-14466,-14598,-14726
	DC.W -14849,-14968,-15082,-15191,-15296,-15396,-15491,-15582
	DC.W -15668,-15749,-15826,-15897,-15964,-16026,-16083,-16135
	DC.W -16182,-16225,-16262,-16294,-16322,-16344,-16362,-16374
	DC.W -16382,-16384
	DC.W -16382
	DC.W -16374,-16362,-16344,-16322,-16294,-16262,-16225,-16182
	DC.W -16135,-16083,-16026,-15964,-15897,-15826,-15749,-15668	
	DC.W -15582,-15491,-15396,-15296,-15191,-15082,-14967,-14849
	DC.W -14726,-14598,-14466,-14330,-14189,-14044,-13894,-13741	
	DC.W -13583,-13421,-13255,-13085,-12911,-12733,-12551,-12365
	DC.W -12176,-11982,-11786,-11585,-11381,-11174,-10963,-10749
	DC.W -10531,-10311,-10087,-9860,-9630,-9397,-9162,-8923
	DC.W -8682,-8438,-8192,-7943,-7692,-7438,-7182,-6924
	DC.W -6664,-6402,-6138,-5872,-5604,-5334,-5063,-4790
	DC.W -4516,-4240,-3964,-3686,-3406,-3126,-2845,-2563
	DC.W -2280,-1997,-1713,-1428,-1143,-857,-572,-286
	dc.w 0

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

