
	section	WireFrame3d,code

; rotazione con le matrici che non si capisce tanto...

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
LunghSchermo	=	200


START:
	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA
	move.l	#0,$108(a5)
	bsr.s	Main			; Do main stuff
	rts


Main:
	bsr.w	SetRotDp		; Init obs.ref.point

	bsr.w	PageUp
	bsr.w	ClWork
	bsr.w	PageDown
	bsr.w	ClWork			; Init both pages

	bsr.w	inp_chan		; Input and change parameters
	move.w	#2047,dist

mainlop1:
	bsr.w	PointRot
	bsr.w	Pers			; Do Perspective
	bsr.w	DrawN1			; Draw It
	bsr.w	PageUp			; Display It

	bsr.w	Inp_Chan		; Input new parameters
	bsr.w	ClWork
	bsr.w	PointRot		; Rotate
	bsr.w	Pers			; Perspective
	bsr.w	DrawN1			; Drawit
	bsr.w	PageDown
	bsr.w	Inp_Chan		; Input Parameters
	bsr.w	ClWork
	btst	#6,$bfe001
	bne.s	mainlop1
mainend:
	bsr.s	PageUp
	rts

inp_chan:
	addq.w	#2,yangle



	addq.w	#1,xangle
	addq.w	#3,zangle
	CMP.w	#360,yangle
	blt.s	nosuby
	sub.w	#360,yangle
nosuby:
	CMP.w	#360,xangle
	blt.s	nosubx
	sub.w	#360,xangle
nosubx:

	CMP.w	#360,zangle
	blt.s	nosubz
	sub.w	#360,zangle
nosubz:
	sub.w	#15,Dist
	CMP.w	#-990,Dist
	bgt.s	NoClr
	move.w	#-990,Dist
NoClr:
	rts

****************************
* Pass upper screen to VDC *
*  while drawing the other *
****************************

pageup:
	move.l	d0,-(a7)
	move.l	#bitplane0,DrawPlane		; Rastport structure
	move.l	#bitplane,d0			; BitMap pointer
	move.w	d0,LowBMPtr
	swap	d0
	move.w	d0,HiBMPtr		; Copper fixes the rest
	bsr	WaitBot
	move.l	(a7)+,d0
	rts

****************************
* Pass lower screen to VDC *
*  while drawing the other *
****************************

pagedown:
	move.l	d0,-(a7)
	move.l	#bitplane,DrawPlane		; Rastport structure
	move.l	#bitplane0,d0			; BitMap pointer
	move.w	d0,LowBMPtr
	swap	d0
	move.w	d0,HiBMPtr		; Copper fixes the rest
	bsr	Waitbot
	move.l	(a7)+,d0
	rts

WaitBot:
	lea	$dff000,a6
	MOVE.L	4(A6),D0
	ANDI.L	#$1FF00,D0
	CMP.L	#$12000,D0
	BNE.S	waitbot
	rts

**********************************
* Pulisci lo shermo con il 68000 *
**********************************

clwork:
	MOVEM.L	D0-D7/A0-A6,-(SP)
	MOVE.L	DrawPlane(PC),a0
	MOVE.L	SP,OLDSP
	LEA	40*200(a0),SP		; ADD lunghezza OF SCREEN
	MOVEM.L	CLREG(PC),D0-D7/A0-A6	; CLEAR REGISTERS
;	MOVEM.L	D0-D7/A0-A6,-(SP)
	dcb.l	133,$48E7FFFE	; NOW CLEAR WITH CPU WHEN A BLIT IS IN PROG.
	movem.l	d0-d3,-(SP)
	MOVE.L	OLDSP(PC),SP	; 60 bytes every instruction!
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

CLREG:
	Dcb.L	15,0

OLDSP:
	dc.l	0


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

*************************************************************
* Init the main diagonal of the risultante matrix with          *
* ones which were multiplied by 2^14. This subroutine must  *
* be called at least once before the call by rotate, or the *
* risultante matrix will only consist of zeros.                 *
*************************************************************

matinit:
	moveq	#0,d1
	move.w	#16384,d2			; The initial value for
	move.w	d2,Matrix11			; the main diagonal of
	move.w	d1,Matrix12			; the risultante matrix
	move.w	d1,Matrix13			; all other elements 
	move.w	d1,Matrix21			; at zero.
	move.w	d2,Matrix22
	move.w	d1,Matrix23
	move.w	d1,Matrix31
	move.w	d1,Matrix32
	move.w	d2,Matrix33
	rts

***************************************************************
* Multiplication of the rotation matrix by the rotation       *
* matrix for rotation about the X-Axis                        *
***************************************************************

; Multiply matrix11-matrix33 with the rotation matrix for a rotation
; about the X-Axis

xrotate:
	move.w	XAngle(PC),d0		; angolo X in d0
	bsr.w	SinCos			; ricava il SENO e COSENO dell'angolo
	move.w	d1,sinx			; e salvali in SINX e COSX
	move.w	d2,cosx
	move.w	d1,d3			; copia SIN(x) in d2
	move.w	d2,d4			; copia COS(x) in d4
	move.w	Matrix11(PC),Rotx11	; The first column of the matrix
	move.w	Matrix21(PC),Rotx21	; Does not change with X rotation
	move.w	Matrix31(PC),Rotx31
	muls.w	Matrix12(PC),d2
	muls.w	Matrix13(PC),d1
	sub.l	d1,d2
	lsl.l	#2,d2
	swap	d2
	move.w	d2,Rotx12
	move.w	d3,d1
	move.w	d4,d2
	muls	Matrix22(PC),d2
	muls	Matrix23(PC),d1
	sub.l	d1,d2
	lsl.l	#2,d2
	swap	d2
	move.w	d2,rotx22
	move.w	d3,d1
	move.w	d4,d2
	muls	Matrix32(PC),d2
	muls	Matrix33(PC),d1
	sub.l	d1,d2
	lsl.l	#2,d2
	swap	d2
	move.w	d2,Rotx32
	move.w	d3,d1
	move.w	d4,d2
	muls	Matrix12(PC),d1
	muls	Matrix13(PC),d2
	add.l	d1,d2
	lsl.l	#2,d2
	swap	d2
	move.w	d2,Rotx13
	move.w	d3,d1
	move.w	d4,d2
	muls	Matrix22(PC),d1
	muls	Matrix23(PC),d2
	add.l	d1,d2
	lsl.l	#2,d2
	swap	d2
	move.w	d2,Rotx23
	muls	Matrix32(PC),d3
	muls	Matrix33(PC),d4
	add.l	d3,d4
	lsl.l	#2,d4
	swap	d4
	move.w	d4,Rotx33
	lea	Rotx11(PC),a1
	lea	Matrix11(PC),a2
	moveq	#8,d7			; Number of matrix elements

roxlop1:
	move.w	(a1)+,(a2)+		; Copy risultante matrix, which
	dbra	d7,roxlop1		; is still in ROTXnn, to MATRIXnn
	rts

***********************************************************
* Multiply the general rotation matrix by the Y-axis	  *
* rotation matrix. risultantes are stored in the general	  *
* rotation matrix					  *
***********************************************************

yrotate:
	move.w	YAngle(PC),d0		; Angle around which rotation is made
	bsr.w	SinCos			; ricava SENO e COSENO dell'angolo Y
	move.w	d1,siny			; e salvali in SINY e COSY
	move.w	d2,cosy
	move.w	d1,d3			; Sine of Y-Angle copiato in d3
	move.w	d2,d4			; Cosine of Y-angle copiato in d4

	muls	Matrix11(PC),d2
	muls	Matrix13(PC),d1
	add.l	d1,d2
	lsl.l	#2,d2
	swap	d2
	move.w	d2,Rotx11
	move.w	d3,d1
	move.w	d4,d2

	muls	Matrix21(PC),d2
	muls	Matrix23(PC),d1
	add.l	d1,d2
	lsl.l	#2,d2
	swap	d2
	move.w	d2,Rotx21
	move.w	d3,d1
	move.w	d4,d2

	muls	Matrix31(PC),d2
	muls	Matrix33(PC),d1
	add.l	d1,d2
	lsl.l	#2,d2
	swap	d2
	move.w	d2,Rotx31
	neg.w	d3
	move.w	d3,d1				; -siny in the rotation mat.
	move.w	d4,d2

	move.w	Matrix12(PC),Rotx12
	move.w	Matrix22(PC),Rotx22		; The second column
	move.w	Matrix32(PC),Rotx32		; of the starting matrix
						; does not change.
	muls	Matrix11(PC),d1
	muls	Matrix13(PC),d2
	add.l	d1,d2
	lsl.l	#2,d2
	swap	d2
	move.w	d2,Rotx13
	move.w	d3,d1
	move.w	d4,d2

	muls	Matrix21(PC),d1
	muls	Matrix23(PC),d2
	add.l	d1,d2
	lsl.l	#2,d2
	swap	d2
	move.w	d2,Rotx23

	muls	Matrix31(PC),d3
	muls	Matrix33(PC),d4
	add.l	d3,d4
	lsl.l	#2,d4
	swap	d4
	move.w	d4,Rotx33

	moveq	#8,d7
	lea	Rotx11(PC),a1	; address of risultante matrix
	lea	Matrix11(PC),a2		; address of original matrix

yrotlop1:
	move.w	(a1)+,(a2)+		; Copy risultante matrix
	dbra	d7,yrotlop1			; to original matrix
	rts

********************************************
* Z-axis - Rotation matrix multiplications *
********************************************

zrotate:
	move.w	ZAngle(PC),d0
	bsr.w	SinCos		; ricava il SENO e il COSENO dell'angolo Z
	move.w	d1,SinZ		; e salvali in SINZ e COSZ
	move.w	d2,CosZ
	move.w	d1,d3		; copia il SIN(z) in d3
	move.w	d2,d4		; copia il COS(z) in d4

	muls.w	Matrix11(PC),d2
	muls.w	Matrix12(PC),d1
	sub.l	d1,d2
	lsl.l	#2,d2
	swap	d2
	move.w	d2,Rotx11
	move.w	d3,d1
	move.w	d4,d2

	muls	Matrix21(PC),d2
	muls	Matrix22(PC),d1
	sub.l	d1,d2
	lsl.l	#2,d2
	swap	d2
	move.w	d2,Rotx21
	move.w	d3,d1
	move.w	d4,d2

	muls	Matrix31(PC),d2
	muls	Matrix32(PC),d1
	sub.l	d1,d2
	lsl.l	#2,d2
	swap	d2
	move.w	d2,Rotx31
	move.w	d3,d1
	move.w	d4,d2

	muls	Matrix11(PC),d1
	muls	Matrix12(PC),d2
	add.l	d1,d2
	lsl.l	#2,d2
	swap	d2
	move.w	d2,Rotx12
	move.w	d3,d1
	move.w	d4,d2

	muls	Matrix21(PC),d1
	muls	Matrix22(PC),d2
	add.l	d1,d2
	lsl.l	#2,d2
	swap	d2
	move.w	d2,Rotx22

	muls	Matrix31(PC),d3
	muls	Matrix32(PC),d4
	add.l	d3,d4
	lsl.l	#2,d4
	swap	d4
	move.w	d4,Rotx32

	move.w	Matrix13(PC),Rotx13	; The third column remains
	move.w	Matrix23(PC),Rotx23	; Unchanged
	move.w	Matrix33(PC),Rotx33

	moveq	#8,d7
	lea	Rotx11(PC),a1
	lea	Matrix11(PC),a2

zrotlop1:
	move.w	(a1)+,(a2)+			; Copy to general
	dbra	d7,zrotlop1			; rotation matrix
	rts

**************************************************************
* Multiply every point whose Array address is in CoordZOggettoSpaz etc.   *
* by previous translation of the coordinate source to        *
* point [offx,offy,offz], with the general rotation matrix.  *
* The coordinate source of the risultante coordinates is then    *
* moved to point [xoffs,yoffs,zoffs]                         *
**************************************************************

rotate:
	move.w	NumeroPunti(PC),d0		; Number of points to be

	lea	Oggetto1(PC),a1		; coord X
	lea	Oggetto1+2(PC),a1	; coord Y
	lea	Oggetto1+4(PC),a1	; coord Z

	lea	pointxROT(PC),a4	; buffer dove mettere le coordinate
	lea	pointyROT(PC),a5	; ruotate
	lea	pointzROT(PC),a6

rotate1:
	move.w	(a1)+,d1		; X-Coordinate
	add.w	Offx(PC),d1
	move.w	d1,d4

	move.w	(a1)+,d2		; Y-Coordinate
	add.w	Offy(PC),d2		; Translation to point[offx,offy,offz]
	move.w	d2,d5

	move.w	(a1)+,d3		; Z-Coordinate
	add.w	offz,d3
	move.w	d3,d6

	muls	Matrix11(PC),d1
	muls	Matrix21(PC),d2
	muls	Matrix31(PC),d3

	add.l	d1,d2
	add.l	d2,d3
	lsl.l	#2,d3
	swap	d3
	add.w	xoffs,d3
	move.w	d3,(a4)+		; Rotated X-Coordinate

	move.w	d4,d1
	move.w	d5,d2
	move.w	d6,d3

	muls	Matrix12(PC),d1
	muls	Matrix22(PC),d2
	muls	Matrix32(PC),d3
	add.l	d1,d2
	add.l	d2,d3
	lsl.l	#2,d3
	swap	d3
	add.w	yoffs(PC),d3
	move.w	d3,(a5)+		; Rotated Y-Coordinate

	muls	Matrix13(PC),d4
	muls	Matrix23(PC),d5
	muls	Matrix33(PC),d6
	add.l	d4,d5
	add.l	d5,d6
	lsl.l	#2,d6
	swap	d6
	add.w	Zoffs(PC),d6
	move.w	d6,(a6)+		; Rotated Z-Coordinate

	dbra	d0,rotate1
	rts

*********************************************************************
* Perspective, calculated from the transformed points in the arrays *
* pointxROT, pointyROT and pointzROT the screen coordinates, which  *
* are then stored in the arrays pointxROTprimo and pointyROTprimo.  *
*********************************************************************

pers:
	lea	pointxROT(PC),a1 ; Beginning address of point arrays
	lea	pointyROT(PC),a2
	lea	pointzROT(PC),a3

	lea	pointxROTprimo(PC),a4	; Start address of display coordinate
	lea	pointyROTprimo(PC),a5	; array.

	move.w	NumeroPunti(PC),d0	; Number of points to be transformed
perlop:
	MOVE.w	(A3)+,D5	; coordinata Z dell'oggetto
	move.w	d5,d6
	MOVE.w	DIST(PC),D4	; distanza dell'oggetto, fattore di
				; ingrandimento
	sub.w	d5,d4			; Dist minus Z-coordinate of obj.coord
	ext.l	d4
	lsl.l	#8,d4			; Times 256 for value fitting
	move.w	Zobs(PC),d3		; Projection center Z-coordinates
	ext.l	d3

	sub.l	d6,d3			; Minus z-coordinate of object
	bne.s	pers1

	moveq	#0,d1			; Catch division by zero
	addq.w	#2,a1
	addq.w	#2,a2
	move.w	d1,(a4)+	; val X interm.
	move.w	d1,(a5)+	; val Y interm.
	bra.s	perend1

pers1:
	divs.w	d3,d4
	move.w	d4,d3
	move.w	(a1)+,d1		; X-Coordinate of object
	move.w	d1,d2
	neg.w	d1
	muls	d1,d3			; Multiplied by perspective factor
	lsr.l	#8,d3			; /256 save value fitting

	add.w	d3,d2			; add to x-coordinate
	add.w	Xorigine(PC),d2		; add screen offset (center point)
	move.w	d2,(a4)+		; Display X-coordinate

	move.w	(a2)+,d1		; Y-Coordinate of object
	move.w	d1,d2
	neg.w	d1
	muls.w	d1,d4
	lsr.l	#8,d4			; /256

	add.w	d4,d2
	neg.w	d2			; Display offset, mirror of Y-Axis
	add.w	Yorigine(PC),d2		; Source at [X0,Y0]
	move.w	d2,(a5)+		; Display Y-Coordinate
perend1:
	dbra	d0,perlop		; Until all points transformed

	rts


************************************************
* Init the rotation reference point to [0,0,0] *
************************************************

setrotdp:
	moveq	#0,d1
	move.w	d1,rotdpx
	move.w	d1,rotdpy
	move.w	d1,rotdpz
	move.w	d1,yangle		; Start rotation angle
	move.w	d1,xangle
	move.w	d1,zangle
	rts

***********************************************************
* Rotation around one point, the rotation reference point *
***********************************************************

pointrot:
	move.w	rotdpx(PC),d0	; Rotation reference point
	move.w	rotdpy(PC),d1
	move.w	rotdpz(PC),d2
	move.w	d0,xoffs
	move.w	d1,yoffs
	move.w	d2,zoffs	; 	add for back transformation
	neg.w	d0
	neg.w	d1
	neg.w	d2
	move.w	d0,offx		; 	subtract for transformation
	move.w	d1,offy
	move.w	d2,offz
	bsr.w	Matinit
	bsr.w	zrotate
	bsr.w	yrotate
	bsr.w	xrotate
	bsr.w	rotate
	rts


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
	lea	LineeOggetto(PC),a6	; address of line array

drlop:
	move.l	(a6)+,d1	; First line (P1,P2)
	lsl.w	#1,d1		; Times list element length (2)
	move.w	(a4,d1.w),d2	; X-Coordinate of 2nd point
	move.w	(a5,d1.w),d3	; Y-Coordinate of second point
	swap	d1		; ora altro punto
	lsl.w	#1,d1		; *2 (words)
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
	bsr.s	Draw
	movem.l	(a7)+,d0-d3/a0-a1
	rts

****************
* Blitter Line *
****************

Draw:
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
	add.l	d2,d3				; Total offset
	move.w	d1,d2
	sub.w	d0,d2
	bge.s	NoMinus
	ori.w	#$40,d7				; Sign = -
NoMinus:
	lea	$dff000,a0
	move.w	d2,a3
	move.w	#$ffff,d6			; LinePtrn
WaitBl:
		btst	#6,2(a0)
	bne.s	WaitBl
	move.w	d1,$62(a0)			; 4Y
	move.w	d2,d1
	sub.w	d0,d1
	move.w	d1,$64(a0)			; 4Y-4X
	moveq	#-1,d1
	move.l	d1,$44(a0)			; AFWM+ALWM
	move.w	#LarghSchermo/8,$60(a0)		; BitMap Width in bytes
	move.w	d7,d5
	addq.w	#1,d0
	asl.w	#6,d0
	addq.w	#2,d0				; Blitsize
	move.w	d4,d2
	swap	d4
	asr.l	#4,d4				; First pixelpos
	ori.w	#$b00,d4			; Use ABD
	move.w	#$8000,$74(a0)			; Index
	clr.w	d1
NoSpesh:
	move.l	DrawPlane,d7			; Pointer
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


;	      (P4) -50,+50,+50______________+50,+50,+50 (P5)
;			     /|		   /|
;			    / |		  / |
;			   /  |		 /  |
;			  /   |		/   |
;	 (P0) -50,+50,-50/____|________/+50,+50,-50 (P1)
;			|     |       |     |
;			|     |_______|_____|+50,-50,+50 (P6)
;			|    /-50,-50,+50 (P7)
;			|   /	      |   /
;			|  /	      |  /
;			| /	      | /
;			|/____________|/+50,-50,-50 (P2)
;	 (P3) -50,-50,-50

Oggetto1:			; Ecco gli 8 punti definiti dalle coord. X,Y,Z
	dc.w	-20,+20,-20	; P0 (X,Y,Z)
	dc.w	+20,+20,-20	; P1 (X,Y,Z)
	dc.w	+20,-20,-20	; P2 (X,Y,Z)
	dc.w	-20,-20,-20	; P3 (X,Y,Z)
	dc.w	-20,+20,+20	; P4 (X,Y,Z)
	dc.w	+20,+20,+20	; P5 (X,Y,Z)
	dc.w	+20,-20,+20	; P6 (X,Y,Z)
	dc.w	-20,-20,+20	; P7 (X,Y,Z)

NPuntiOggetto	= 8

***** What points should be connected with lines? ****

; connessioni:

; connessioni tra i punti: l'ordine e' a piacere, ma vedete di non tracciare
; la stessa linea 2 volte! Un cubo ha 12 spigoli, infatti ecco 12 connessioni

LineeOggetto:
lines:
	dc.w	0,1	; faccia davanti
	dc.w	1,2
	dc.w	2,3
	dc.w	3,0

	dc.w	4,5	; faccia dietro
	dc.w	5,6
	dc.w	6,7
	dc.w	7,4

	dc.w	0,4	; spigoli laterali
	dc.w	1,5
	dc.w	2,6
	dc.w	3,7

NLineeOggetto	= 12


******************************************************************************
******************************************************************************
**									    **
**			TABELLA DEI SENI E VARIABILI			    **
**									    **
******************************************************************************
******************************************************************************

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

sintab:
	dc.w	0,286,572,857,1143,1428,1713,1997,2280
	dc.w	2563,2845,3126,3406,3686,3964,4240,4516
	dc.w	4790,5063,5334,5604,5872,6138,6402,6664
	dc.w	6924,7182,7438,7692,7943,8192,8438,8682
	dc.w	8923,9162,9397,9630,9860,10087,10311,10531
	dc.w	10749,10963,11174,11381,11585,11786,11982,12176
	dc.w	12365,12551,12733,12911,13085,13255,13421,13583
	dc.w	13741,13894,14044,14189,14330,14466,14598,14726
	dc.w	14849,14962,15082,15191,15296,15396,15491,15582
	dc.w	15668,15749,15826,15897,15964,16026,16083,16135
	dc.w	16182,16225,16262,16294,16322,16344,16362,16374
	dc.w	16382,16383

	dc.w	16382,16374,16362,16344,16322,16294,16262,16225
	dc.w	16182
	dc.w	16135,16083,16026,15964,15897,15826,15749,15668
	dc.w	15582,15491,15396,15296,15191,15082,14962,14849
	dc.w	14726,14598,14466,14330,14189,14044,13894,13741
	dc.w	13583,13421,13255,13085,12911,12733,12551,12365
	dc.w	12176,11982,11786,11585,11381,11174,10963,10749
	dc.w	10531,10311,10087,9860,9630,9397,9162,8923
	dc.w	8682,8438,8192,7943,7692,7438,7182,6924
	dc.w	6664,6402,6138,5872,5604,5334,5063,4790
	dc.w	4516,4240,3964,3686,3406,3126,2845,2563
	dc.w	2280,1997,1713,1428,1143,857,572,286,0

	dc.w	-286,-572,-857,-1143,-1428,-1713,-1997,-2280
	dc.w	-2563,-2845,-3126,-3406,-3686,-3964,-4240,-4516
	dc.w	-4790,-5063,-5334,-5604,-5872,-6138,-6402,-6664
	dc.w	-6924,-7182,-7438,-7692,-7943,-8192,-8438,-8682
	dc.w	-8923,-9162,-9397,-9630,-9860,-10087,-10311,-10531
	dc.w	-10749,-10963,-11174,-11381,-11585,-11786,-11982,-12176
	dc.w	-12365,-12551,-12733,-12911,-13085,-13255,-13421,-13583
	dc.w	-13741,-13894,-14044,-14189,-14330,-14466,-14598,-14726
	dc.w	-14849,-14962,-15082,-15191,-15296,-15396,-15491,-15582
	dc.w	-15668,-15749,-15826,-15897,-15964,-16026,-16083,-16135
	dc.w	-16182,-16225,-16262,-16294,-16322,-16344,-16362,-16374
	dc.w	-16382,-16383

	dc.w	-16382,-16374,-16362,-16344,-16322,-16294,-16262,-16225
	dc.w	-16182
	dc.w	-16135,-16083,-16026,-15964,-15897,-15826,-15749,-15668
	dc.w	-15582,-15491,-15396,-15296,-15191,-15082,-14962,-14849
	dc.w	-14726,-14598,-14466,-14330,-14189,-14044,-13894,-13741
	dc.w	-13583,-13421,-13255,-13085,-12911,-12733,-12551,-12365
	dc.w	-12176,-11982,-11786,-11585,-11381,-11174,-10963,-10749
	dc.w	-10531,-10311,-10087,-9860,-9630,-9397,-9162,-8923
	dc.w	-8682,-8438,-8192,-7943,-7692,-7438,-7182,-6924
	dc.w	-6664,-6402,-6138,-5872,-5604,-5334,-5063,-4790
	dc.w	-4516,-4240,-3964,-3686,-3406,-3126,-2845,-2563
	dc.w	-2280,-1997,-1713,-1428,-1143,-857,-572,-286,0


sinx:	dc.w	0		; Temporary storage for sin & cos
siny:	dc.w	0		; values
sinz:	dc.w	0

cosx:	dc.w	0
cosy:	dc.w	0
cosz:	dc.w	0


xangle:	dc.w	0		; Variables for passing angles
yangle:	dc.w	0		; to the rotation subroutine
zangle:	dc.w	0


zobs:	dc.w	2000	; coordinata Z del centro di proiezione (osservatore)

dist:	dc.w	-990

rotx11:	dc.w	16384		; Space here for the risultante matrix
rotx12:	dc.w	0		; of matrix multiplication
rotx13:	dc.w	0
rotx21:	dc.w	0
rotx22:	dc.w	16384
rotx23:	dc.w	0
rotx31:	dc.w	0
rotx32:	dc.w	0
rotx33:	dc.w	16384

matrix11:	dc.w	0		; Space here for the general rotation
matrix12:	dc.w	0		; matrix
matrix13:	dc.w	0
matrix21:	dc.w	0
matrix22:	dc.w	0
matrix23:	dc.w	0
matrix31:	dc.w	0
matrix32:	dc.w	0
matrix33:	dc.w	0

DrawPlane:
	dc.l	0


******************************************************************************
;		    dati e variabili della routine			     *
******************************************************************************

NumeroPunti:
	dc.w	NPuntiOggetto-1	; Number of corner points of the object
NUMLineeOggetto:
	dc.w	NLineeOggetto-1	; Number of lines in the object


; Coordinate X ed Y dell'ORIGINE degli assi rispetto allo schermo, in questo
; caso li posizioniamo al centro dello schemo.

Xorigine:	dc.w	LarghSchermo/2	; 320/2 = 160, centro X dello schermo
Yorigine:	dc.w	LunghSchermo/2	; 200/2 = 100, centro Y




rotdpx:	dc.w	0
rotdpy:	dc.w	0
rotdpz:	dc.w	0	; Rotation datum point


; buffer per i punti ruotati nello spazio

pointxROT:
	DS.W NPuntiOggetto
pointyROT:
	DS.W NPuntiOggetto
pointzROT:
	DS.W NPuntiOggetto


;	Coordinate X ed Y proiettate, ossia in prospettiva, pronte per
;	essere disegnate

pointxROTprimo:
	DS.W NPuntiOggetto
pointyROTprimo:
	DS.W NPuntiOggetto


prox:	dc.w	0	; Coordinates of the projection center
proy:	dc.w	0	; on the positive Z-axis

offx:	dc.w	0
offy:	dc.w	0
offz:	dc.w	0
xoffs:	dc.w	0
yoffs:	dc.w	0
zoffs:	dc.w	0

loopc:	dc.l	0

******************************************************************************
******************************************************************************
**									    **
**			COPPERLIST E BITPLANES				    **
**									    **
******************************************************************************
******************************************************************************


		section	copper,data_C

CopperList:
	dc.w	$0180,$0000,$0182,$fff
	dc.w	$0100,$1200,$00e0
hibmptr:
	dc.w	$0000,$00e2
lowbmptr:
	dc.w	$0000,$0092,$0038,$0094,$00d0
	dc.w	$008e,$2c81,$0090,$f4c1
	dc.w	$108,0
	dc.w	$10a,0	
	dc.w	$0120
sp1h:	dc.w 0,$0122
sp1l:	dc.w 0,$0124
sp2h:	dc.w 0,$0126
sp2l:	dc.w 0,$0128
sp3h:	dc.w 0,$012a
sp3l:	dc.w 0,$012c,0,$012e,0,$0130,0,$0132,0,$0134,0
	dc.w $0136,0,$0138,0,$013a,0,$013c,0,$013e,0

	dc.w	$ffff,$fffe	; fine copperlist

;

	section	planes,bss_C

bitplane0:
	ds.b	40*LunghSchermo
bitplane:
	ds.b	40*LunghSchermo

	end

