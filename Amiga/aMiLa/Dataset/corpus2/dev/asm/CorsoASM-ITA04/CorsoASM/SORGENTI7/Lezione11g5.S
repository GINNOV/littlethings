
; Lezione11g5.s -  Uso della caratteristica del copper di richiedere 8 pixel
;		   orizzontali per eseguire un suo "MOVE".
;		   Tasto destro per far scendere la "corda".

	SECTION	Spago,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup2.s" ; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001010000000	; solo copper DMA

WaitDisk	EQU	30	; 50-150 al salvataggio (secondo i casi)

START:
	bsr.w	FaiCopper	; Crea la copperlist...

	lea	$dff000,a6
	MOVE.W	#DMASET,$96(a6)		; DMACON - abilita bitplane, copper
					; e sprites.

	move.l	#COPLIST,$80(a6)	; Puntiamo la nostra COP
	move.w	d0,$88(a6)		; Facciamo partire la COP
	move.w	#0,$1fc(a6)		; Disattiva l'AGA
	move.w	#$c00,$106(a6)		; Disattiva l'AGA
	move.w	#$11,$10c(a6)		; Disattiva l'AGA

mouse:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$13000,d2	; linea da aspettare = $130, ossia 304
Waity1:
	MOVE.L	4(A6),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $130 (304)
	BNE.S	Waity1

	btst	#2,$16(a6)	; tasto destro del mouse premuto?
	bne.s	NonScendere
	addq.b	#1,WaitLine	; Se si, fai scendere il tutto!
NonScendere:

	bsr.w	MuoviCopper	; rolla lo spago...

	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$13000,d2	; linea da aspettare = $130, ossia 304
Aspetta:
	MOVE.L	4(A6),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $130 (304)
	BEQ.S	Aspetta

	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse
	rts			; esci


******************************************************************************
;	Routine che crea la copperlist. Per fare una linea orizzontale
;	completa occorrono 52 MOVE del copper. In questo caso prendiamo
;	alternativamente 32 MOVE per colore, per cui non terminano una
;	linea esatta, ma i 2 colori si "incrociano" in punti orizzontali
;	diversi. Questo crea una senzazione di "intreccio".
******************************************************************************
;	               ______________
;	              /              \
;	  ..::;::..  /  HaI CaPiTo?!  \
;	 ¡ ________) \_ ______________/
;	 l_`--°'\°¬)  / /
;	 /______·)¯\  \/
;	( \±±±±±)  /
;	 \________/
;	   T____T xCz

NumeroIntrecci	EQU	8
IngombroCopEf	EQU	NumeroIntrecci*(32*2)


FaiCopper:
	LEA	CopBuf,A0		; Indirizzo buffer in CopList
	MOVEQ	#NumeroIntrecci-1,D6	; numero intrecci
MAIN0:
	LEA	COLORS1(PC),A1	; tab COLORS1
	MOVEQ	#32-1,D7	; 32 color0 per colori da COLORS1
COP0:
	MOVE.W	#$0180,(A0)+	; registro COLOR0
	MOVE.W	(A1)+,(A0)+	; valore del color dalla tabella COLORS1
	DBRA	d7,COP0		; fai tutta la "linea" (non 1 intera...)
	LEA	COLORS2(PC),A1	; tab COLORS2
	MOVEQ	#32-1,D7	; 32 color0 per colori da COLORS2
COP1:
	MOVE.W	#$0180,(A0)+	; registro COLOR0
	MOVE.W	(A1)+,(A0)+	; valore del color0 dalla tabella COLORS2
	DBRA	d7,COP1		; fai tutta la "linea" (non 1 intera...)
	DBRA	d6,MAIN0	; Fai tutti gli "intrecci".
	RTS


COLORS1:
 DC.W	$003,$001,$002,$003,$004,$005,$006,$007
 DC.W	$008,$009,$00A,$00B,$00C,$00D,$00E,$10F
 DC.W	$10F,$00E,$00D,$00C,$00B,$00A,$009,$008
 DC.W	$007,$006,$005,$004,$003,$002,$001,$003

COLORS2:
 DC.W	$010,$010,$020,$030,$040,$050,$060,$070
 DC.W	$080,$090,$0A0,$0B0,$0C0,$0D0,$0E0,$0F0
 DC.W	$0F0,$0E0,$0D0,$0C0,$0B0,$0A0,$090,$080
 DC.W	$070,$060,$050,$040,$030,$020,$010,$010


******************************************************************************
; Routine che "rotea" i colori...
******************************************************************************

;	   _
;	 _( )_
;	(_-O-_)
;	  (_)

MuoviCopper:
	LEA	CopBuf,A0	; Buffer in copperlist
	MOVE.w	#IngombroCopEf-1,D7
	move.w	#(IngombroCopEf*4)-2,d6	; offset per trovare l'ultimo colore
	MOVE.W	0(A0,D6.W),D0	; ultimo colore in d0 (a0+offset!)
	MOVE.W	D6,D5
	SUBQ.W	#4,D5		; offset colore precedente in d5
SYNC0:
	MOVE.W	0(A0,D5.W),0(A0,D6.W)	; colore precedente in quello "dopo"
	SUBQ.W	#4,D6			; calcola offset prossimo colore
	SUBQ.W	#4,D5			; calcola offset prossimo colore
	dbra	d7,SYNC0		; Esegui per tutto il "nodo"
	MOVE.W	D0,2(A0) ; metti l'ultimo colore, che avevamo salvato, come
			 ; primo colore, per non interrompere il ciclo.
	RTS

******************************************************************************

	section	coop,data_C

COPLIST:
	DC.W	$100,$200	; BplCon0 - no bitplanes
	DC.W	$180,$003	; Color0 - blu scuro
WaitLine:
	DC.W	$4001,$FFFE	; Wait linea $40.
CopBuf:
	DCB.L	IngombroCopEf,0 ; Spazio per l'effetto cop
	DC.W	$180,3		; Color0 - blu scuro
	DC.w	$ffff,$fffe	: Fine della Copperlist

	END

Un'altro utilizzo della peculiarita' dei move del copper per cui ognuno fa
"scattare" in avanti di 8 pixel. Si puo' notare che tutto l'effetto e'
composto solamente da decine di COLOR0 messi di seguito, per cui basta
cambiare il wait che li precede per far spostare "tutto" in basso.

