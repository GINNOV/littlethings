

	section	WireFrame3d,code

; sistema 3 tabelle per punti X,Y,Z e tabella lines
; sintab STANDARD OLD1 come MINI-INTRO 3d

*****************************************************************************
	include	"Assembler2:sorgenti4/startup1.s" ; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001111000000	; copper, bitplane e blitter
;		 -----a-bcdefghij

;	a: Blitter Nasty
;	b: Bitplane DMA	   (Se non e' settato, spariscono anche gli sprite)
;	c: Copper DMA
;	d: Blitter DMA
;	e: Sprite DMA
;	f: Disk DMA
;	g-j: Audio 3-0 DMA


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

	
*************************************************
*	Main Loop				*
*************************************************

WAIT:	
	BSR.w	SWAP		;Swap Screen
	ADDQ.W	#1,ZANGLE	; rotazione attorno ad asse che ci viene
				; incontro, lo vedremmo come un punto .,
				; dunque l'oggetto ruota come le lancette di
				; un'orologio se SUBBATO, o in senso
				; antiorario se ADDATO.
;	ADDQ.W	#2,YANGLE	; rotazione attorno ad asse VERTICALE |
;	ADDQ.W	#1,XANGLE	; rotazione attorno ad asse ORIZZONTALE --
	BSR.w	ROTATE		;Rotate 3d Image
	BSR.w	PERS		;Calculate Perspective
	bsr.w	drawn1

WAITPOS:
	CMP.B 	#$FF,$DFF006	;Wait for beam
	BNE.s	WAITPOS

	btst	#2,$dff016
	bne.s	NoZoom
	sub.w	#10,DIST		; allontana il solido
NoZoom:

	ANDI.B 	#$40,$BFE001	;Wait for Mouse Button
	BNE.s 	WAIT

	rts


SCREEN:
	DC.L Bitplane0
SCREEN1:
	DC.L Bitplane



*************************************************
*	Clear routine				*
*	A1	=	Address to clear	*
*************************************************
**********************************
* Pulisci lo shermo con il 68000 *
**********************************

clwork:
	MOVEM.L	D0-D7/A0-A6,-(SP)
	MOVE.L	SP,OLDSP
	LEA	40*LunghSchermo(a1),SP	; ADD lunghezza OF SCREEN
	MOVEM.L	CLREG(PC),D0-D7/A0-A6	; CLEAR REGISTERS
;	MOVEM.L	D0-D7/A0-A6,-(SP)
	dcb.l	170,$48E7FFFE	; NOW CLEAR WITH CPU WHEN A BLIT IS IN PROG.
	movem.l	d0-d7/a0-a1,-(SP)
	MOVE.L	OLDSP(PC),SP	; 60 bytes every instruction!
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

CLREG:
	Dcb.L	15,0

OLDSP:
	dc.l	0


DrawPlane:
	dc.l	Bitplane

	
*************************************************
*	Swap Logical and Physical Screens	*
*************************************************

SWAP:
	MOVE.L 	SCREEN(PC),D0
	CMP.L 	DrawPlane(PC),D0		;Is current screen=screen1
	BNE.s	SWAPIT			;No then branch
	MOVE.L 	SCREEN(PC),D0		;Display Screen1
	BSR.s	INSSCRN			;Insert it Into Copper
	MOVE.L 	SCREEN1(PC),DrawPlane	;Screen2 = Logical 
	MOVE.L 	SCREEN1(PC),A1		;Address to Clear
	BSR.w	CLWork			;Do it !!!
  	RTS
  	
SWAPIT:
	MOVE.L 	SCREEN1(PC),D0		;Use screen2
	BSR.s	INSSCRN			;Insert screen
	MOVE.L 	SCREEN(PC),DrawPlane	;screen1=logical
	MOVE.L 	SCREEN(PC),A1		;address to clear
	BSR.w	CLWork
	RTS
	
INSSCRN:
	LEA	BOT,A0		;Insert Screen into Copper
	MOVE 	D0,6(A0)
	SWAP 	D0
	MOVE 	D0,2(A0)
	RTS

*********************************************************************
* Perspective, calculated from the transformed points in the arrays *
* pointxROT, pointyROT and pointzROT the screen coordinates, which  *
* are then stored in the arrays pointxROTprimo and pointyROTprimo.  *
*********************************************************************

PERS:

;	indirizzi delle tabelle contenenti i punti ruotati nello spazio

	LEA	pointxROT(PC),A1	; indirizzo tabella delle X ruotate
	LEA	pointyROT(PC),A2	; tabella delle Y ruotate
	LEA	pointzROT(PC),A3	; tabella delle Z ruotate

;	indirizzi delle tabelle dove mettere le coordinate X ed Y dei
;	punti proiettati prospetticamente sul piano.

	LEA	pointxROTprimo(PC),A4	; tabella coordinate X proiettate
	LEA	pointyROTprimo(PC),A5	; tab. coord. Y proiettate

	MOVE.w	NumeroPunti(PC),D0	; numero di punti da proiettare
	EXT.L 	D0
PERLOP:
	MOVE.w	(A3)+,D5	; coordinata Z dell'oggetto
	MOVE.w	D5,D6
	MOVE.w	DIST(PC),D4	; distanza dell'oggetto, fattore di
				; ingrandimento
	SUB.w	D5,D4		; (distanza)-(coordinata Z dell'oggetto)
	EXT.L 	D4
	LSL.L 	#8,D4		; moltiplica *256
	MOVE.w	ZOBS(PC),D3	; coordinata Z del centro di proiezione
	EXT.L	D3

	SUB.L	D6,D3		; meno la coordinata Z dell'oggetto
	BNE.s	PERS1

	MOVEQ	#0,D1		; Catch division by zero
	ADDQ.w	#2,A1
	ADDQ.w	#2,A2
	MOVE.w	D1,(A4)+	; val X interm.
	MOVE.w	D1,(A5)+	; val Y interm.
	BRA.s	PEREND1

PERS1:
	DIVS.w	D3,D4
	MOVE.w	D4,D3
	MOVE.w	(A1)+,D1	; Coordinata X dell'oggetto
	MOVE.w	D1,D2
	NEG.w	D1
	MULS.w	D1,D3		; Moltiplica per il fattore di prospettiva
	LSR.L	#8,D3		; dividi per 256

	ADD.w	D3,D2		; aggiungi alla coordinata X

	ADD.w	XOrigine(PC),D2	; +posizione X dell'origine degli assi, ossia
				; il centro dello schermo: 320/2= 160
				; infatti [X0,Y0] = [160,100]
	MOVE.w	D2,(A4)+	; val X interm

	MOVE.w	(A2)+,D1	; Coordinata Y dell'oggetto
	MOVE.w	D1,D2
	NEG.w	D1
	MULS.W	D1,D4
	LSR.L	#8,D4		; dividi per 256

	ADD.w	D4,D2
	neg.w	d2			; Display offset, mirror of Y-Axis
	ADD.W 	YOrigine(PC),D2	; +posizione Y dell'origine degli assi, ossia
				; il centro dello schermo: 200/2 = 100
				; infatti [X0,Y0] = [160,100]
	MOVE	D2,(A5)+	; val Y interm
PEREND1:
	DBRA 	D0,PERLOP	; ripeti NumeroPunti volte per tutti i punti.
	RTS			; fino a che non li hai proiettati tutti

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
	LEA	CoordXOggettoSpaz(PC),A0	; tabella punti coordinate X
	LEA	CoordYOggettoSpaz(PC),A1	; tabella punti coordinate Y
	LEA	CoordZOggettoSpaz(PC),A2	; tabella punti coordinate Z

; cordinate destinazione:
	LEA	pointxROT(PC),A3	; tabella per i punti ruotati X
	LEA	pointyROT(PC),A4	; tabella per i punti ruotati Y
	LEA	pointzROT(PC),A5	; tabella per i punti ruotati Z

	MOVE.w	NumeroPunti(PC),D0
RLOOP:
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
	MOVE.w	(A0)+,D3	; CoordXOggettoSpaz - prossima cordinata X
	MULS.w	D3,D1		; moltiplica CoordXOggettoSpaz*ZSIN
	MOVE.w	(A1)+,D3	; CoordYOggettoSpaz - prossima coordinata Y
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
	MOVE.w	(A2)+,D3	; CoordZOggettoSpaz - prossima coordinata Z
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

	MOVE 	D5,(A3)+	; salva in pointxROT
	MOVE 	D6,(A4)+	; salva in pointyROT
	MOVE 	D7,(A5)+	; salva in pointzROT

	DBRA 	D0,RLOOP	; esegui NumeroPunti volte, per ruotare tutti
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
******************************************************************************
**									    **
**		ROUTINES DI DISEGNO DELL'OGGETTO SUL BITPLANE		    **
**									    **
******************************************************************************
******************************************************************************

**************************************************************
* Draw number of lines from array from lines in LineeOggetto *
**************************************************************

drawn1:
	lea	pointxROTprimo(PC),a4	; Display X-Coordinate
	lea	pointyROTprimo(PC),a5	; Display Y-Coordinate

	move.w	NUMLineeOggetto(PC),d0	; Numero di linee che congiungono
					; punti del solido
	ext.l	d0
	lea	LineeOggetto(PC),a6	; address of line array

drlop:
	move.l	(a6)+,d1	; First line (P1,P2)
	subq.w	#1,d1		; Fit to list structure
	lsl.w	#1,d1		; Times list element length (2)
	move.w	(a4,d1.w),d2	; X-Coordinate of 2nd point
	move.w	(a5,d1.w),d3	; Y-Coordinate of second point
	swap	d1
	subq.w	#1,d1
	lsl.w	#1,d1
	move.w	(a4,d1.w),a2	; X-Coordinate of first point
	move.w	(a5,d1.w),a3	; Y-Coordinate of first point
	bsr.w	Drawl		; Draw line from P1 to P2
	dbra	d0,drlop	; Until all lines drawn
	rts

;


*******************************************************************
* Draw-line routine, The points are passed in D2,D3 (start point) *
* and A2, A3 (end point)                                          *
*******************************************************************

Drawl:
	movem.l	d0-d3/a0-a1,-(a7)
	move.l	d2,d0
	move.l	d3,d1				; X,y start
	move.l	a2,d2
	move.l	a3,d3				; X,y end
	bsr.s	BlitDraw
	movem.l	(a7)+,d0-d3/a0-a1
	rts

****************
* Blitter Line *
****************

BlitDraw:
	movem.l	d2-d7/a2-a3,-(a7)
	moveq	#$f,d4
	and.w	d2,d4				; low 4 bits
	sub.w	d3,d1				; Height
	mulu	#LarghSchermo/8,d3		; Start address
	sub.w	d2,d0				; Width
	blt.s	No1
	tst.w	d1
	blt.s	No2
	CMP.w	d0,d1
	bge.s	No3
	moveq	#$11,d7
	bra.s	OctSel				; Octant #
No3:
	moveq	#1,d7
	exg	d1,d0
OctSel:
	bra.s	No4
No2:
	neg.w	d1
	CMP.w	d0,d1
	bge.s	Skip
	moveq	#$19,d7
	bra.s	No4
Skip:
	moveq	#5,d7
	exg	d1,d0
No4:
	bra.s	OctsSel
No1:
	neg.w	d0
	tst.w	d1
	blt.s	No11

	CMP.w	d0,d1
	bge.s	No12
	moveq	#$15,d7
	bra.s	OctSel2

No12:
	moveq	#9,d7
	exg	d1,d0
OctSel2:
	bra.s	OctsSel
No11:
	neg.w	d1
	CMP.w	d0,d1
	bge.s	No13
	moveq	#$1d,d7
	bra.s	OctsSel
No13:
	moveq	#$d,d7
	exg	d1,d0
OctsSel:
	add.w	d1,d1
	asr.w	#3,d2
	ext.l	d2
	add.l	d2,d3			; Total offset
	move.w	d1,d2
	sub.w	d0,d2
	bge.s	NoMinus
	ori.w	#$40,d7			; Sign = -
NoMinus:
	lea	$dff000,a0
	move.w	d2,a3
	move.w	#$ffff,d6		; LinePtrn
WaitBl:
	btst	#6,2(a0)
	bne.s	WaitBl
	move.w	d1,$62(a0)		; 4Y
	move.w	d2,d1
	sub.w	d0,d1
	move.w	d1,$64(a0)		; 4Y-4X
	moveq	#-1,d1
	move.l	d1,$44(a0)		; AFWM+ALWM
	move.w	#LarghSchermo/8,$60(a0)	; BitMap Width in bytes
	move.w	d7,d5
	addq.w	#1,d0
	asl.w	#6,d0
	addq.w	#2,d0			; Blitsize
	move.w	d4,d2
	swap	d4
	asr.l	#4,d4			; First pixelpos
	ori.w	#$b00,d4		; Use ABD
	move.w	#$8000,$74(a0)		; Index
	clr.w	d1
NoSpesh:
	move.l	DrawPlane(PC),d7		; Pointer
	swap	d5
	move.w	d4,d5
	move.b	#$ca,d5			; MinTerms
	swap	d5
	add.l	d3,d7
WtBl2:
	btst	#6,2(a0)
	bne.s	WtBl2
	move.l	d5,$40(a0)			; 	bltCon0 & 1
	move.w	a3,$52(a0)			; 2Y-X
	move.l	d7,$48(a0)
	move.l	d7,$54(a0)		; Start address of line
	move.w	d6,$72(a0)			; Pattern
	move.w	d0,$58(a0)			; Size
	movem.l	(a7)+,d2-d7/a2-a3
	rts


******************************************************************************
;	definizione del solido 3d wireframe
******************************************************************************


CoordXOggettoSpaz:
	dc.w	0,40,0,-40,-15,0,15,0,-15,15
	dc.w	0,35,0,-35

CoordYOggettoSpaz:
	dc.w	40,0,-40,0,15,15,15,-25,10,10
	dc.w	35,0,-35,0

CoordZOggettoSpaz:
	dc.w	0,0,0,0,10,10,10,10,10,10
	dc.w	20,20,20,20

***** What points should be connected with lines? ****

; connessioni:

LineeOggetto:
	dc.w	1,2, 2,3, 3,4, 4,1, 5,7, 6,8, 5,9, 7,10
	dc.w	11,12, 12,13, 13,14, 14,11, 1,11, 2,12
	dc.w	3,13,4,14

NPuntiOggetto	= 14
NLineeOggetto	= 16


******************************************************************************
;		    dati e variabili della routine			     *
******************************************************************************


NumeroPunti:
	DC.W NPuntiOggetto-1
NUMLineeOggetto:
	DC.W NLineeOggetto-1


zobs:	dc.w	1500	; coordinata Z del centro di proiezione (osservatore)

dist:	dc.w	3000

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
; caso li posizioniamo al centro dello schemo.

Xorigine:	dc.w	LarghSchermo/2	; 320/2 = 160, centro X dello schermo
Yorigine:	dc.w	LunghSchermo/2	; 200/2 = 100, centro Y

; buffer per i punti ruotati nello spazio

pointxROT:
	DS.W	NPuntiOggetto
pointyROT:
	DS.W	NPuntiOggetto
pointzROT:
	DS.W	NPuntiOggetto


;	Coordinate X ed Y proiettate, ossia in prospettiva, pronte per
;	essere disegnate

pointxROTprimo:
	DS.W	NPuntiOggetto
pointyROTprimo:
	DS.W	NPuntiOggetto


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
BOT:
	DC.W $E0,0,$E2,0
	DC.W $FFFF,$FFFE

	section	planes,bss_C

bitplane0:
	ds.b	40*LunghSchermo

bitplane:
	ds.b	40*LunghSchermo

	end

