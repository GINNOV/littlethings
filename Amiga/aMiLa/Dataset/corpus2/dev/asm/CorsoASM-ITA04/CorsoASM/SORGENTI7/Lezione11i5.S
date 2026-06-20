
;  Lezione11i5.s - Una modifica alla solita barra....

; Tasto destro per abbassare la barra; si potrebbe fare una tabella per
; farla rimbalzare in alto e in basso

	SECTION	Coppex,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup2.s" ; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001010000000	; solo copper DMA

WaitDisk	EQU	30	; 50-150 al salvataggio (secondo i casi)

START:
	lea	$dff000,a5
	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
					; e sprites.

	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

mouse:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$12c00,d2	; linea da aspettare = $12c
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $12c
	BNE.S	Waity1
Aspetta:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $12c
	BEQ.S	Aspetta

	btst	#2,$dff016	; tasto destro del mouse?
	bne.s	NonAbbassare
	cmp.b	#$c0,OrizzCoord	; barra gia' abbastanza bassa?
	bhi.s	NonAbbassare
	addq.b	#1,OrizzCoord

NonAbbassare:
	bsr.s	CoolRaster

	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse
	rts

*****************************************************************************
;	routine principale
*****************************************************************************

CoolRaster:
	ADDQ.W	#2,OrizzCoord
	BSR.S	CoolEffetto
	BSR.S	ScorriColori	; fai scorrere i colori della tab
	rts


*****************************************************************************
;	Routine di scorrimento dei colori della parte rossa dell'effetto
;	i colori sono fatti scorrere direttamente nella ColorTab1
*****************************************************************************

ScorriColori:
	LEA	ColorTab1(PC),A0
	MOVE.W	(A0),30*2(A0)		; salva il primo colore in fondo
	LEA	ColorTab1+2(PC),A1	; indirizzo secondo colore
	MOVEQ	#31-1,D1		; 30 colori da "spostare"
ScorriTAB:
	MOVE.W	(A1)+,(A0)+		; colore 2 in colore 1, colore 3 in
	DBRA	D1,ScorriTAB		; colore 2 eccetera.
	RTS

*****************************************************************************

;	       _ ____   ____ _
;	             \ /
;	   .:::::::::: ::::::::::.
;	( :::        + +        ::: )
;	   `:::::::::: ::::::::::'
;	       /__  /  \\  __\
;	       \_\ (_____) /_/ 
;	    _/    \_ ___ _/    \_
;	    |       V   V       |
;	   /|\                 /|\
;	   |||                 |||
;

CoolEffetto:
	LEA	CopperBuffer1,A0
	LEA	ColorTab1(PC),A1	; tabella colori 1
	LEA	ColorTab2(PC),A2	; tabella colori 2

	MOVEQ	#29-1,D0	; 29 linee per l'effetto
	MOVE.W	OrizzCoord(PC),D1	; attuale wait orizzontale e vert.in d1
WRITEBOTHLINES:
	MOVE.W	D1,(A0)+	; mettila in copperlist
	MOVE.W	#$FFFE,(A0)+	; seguito dal $FFFE
	MOVE.W	#$0180,(A0)+	; Color0
	MOVE.W	(A1)+,(A0)+	; metti il colore dalla tab1
	ADD.W	#$0020,D1	; sposta il wait 20 passi piu' avanti
	MOVE.W	D1,(A0)+	; e mettilo in copperlist
	MOVE.W	#$FFFE,(A0)+	; seguito dal $FFFE
	MOVE.W	#$0180,(A0)+	; color0
	MOVE.W	(A2)+,(A0)+	; metti il colore dalla tab2
	ADD.W	#$0020,D1	; sposta il wait 20 passi piu' avanti
	DBRA	D0,WRITEBOTHLINES
	RTS


;	Tabella della sfumatura rossa

ColorTab1:	; 30 valori.w RGB per il color0 in copperlist

	dc.W	$100,$200,$300
	dc.W	$400,$500,$600,$700,$800,$900,$A00,$B00,$C00,$D00,$E00,$F00
	dc.W 	$E00,$D00,$C00,$B00,$A00,$900,$800,$700,$600,$500,$400,$300
	dc.W	$200,$100,$101



;	Tabella della sfumatura grigia

ColorTab2:	; 30 valori.w RGB per il color0 in copperlist

	dc.W	$000
	dc.W	$111,$222,$333,$444,$555,$666,$777,$888,$999,$AAA,$BBB,$CCC
	dc.W	$DDD,$EEE,$DDD,$CCC,$BBB
	dc.W	$AAA,$999,$888,$777,$666,$555,$444,$333,$222,$111,$000
	dc.w	$000

;	Questo e' il wait iniziale

OrizzCoord:
 	dc.W $3A07


*****************************************************************************
;	Copperlist
*****************************************************************************

	SECTION	COP,DATA_C

COPPERLIST:
	dc.w	$100,$200	; bplcon0 - no bitplanes
	DC.W	$0180,$0000	; color0 nero
	DC.W	$2B07,$FFFE	; wait linea $2b
CopperBuffer1:
 	dcb.W	29*8,0

	dc.W	$0180,$000	; color0 nero


	dc.w	$d007,$fffe	; Wait linea $d0
	dc.w	$180,$035
	dc.w	$d207,$fffe	; Wait linea $d0
	dc.w	$180,$047
	dc.w	$d607,$fffe	; Wait linea $d0
	dc.w	$180,$059

	dc.W	$FFFF,$FFFE	; fine della copperlist

	end

