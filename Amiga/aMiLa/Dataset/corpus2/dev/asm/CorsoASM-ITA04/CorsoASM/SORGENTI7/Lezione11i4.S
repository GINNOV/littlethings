
;  Lezione11i4.s - Effetto originale di shadow/ELECTRON modificato.

; PREMERE IL TASTO DESTRO PER CAMBIARE TONALITA' ALLE SFUMATURE...

	SECTION	Barrex,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup2.s" ; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001010000000	; solo copper DMA

WaitDisk	EQU	30	; 50-150 al salvataggio (secondo i casi)

range		equ	20
NumeroLinee	equ	257

START:

	bsr.w	initcopbuf	; Prepara la copperlist

	lea	$dff000,a6
	MOVE.W	#DMASET,$96(a6)		; DMACON - abilita bitplane, copper
					; e sprites.

	move.l	#COP,$80(a6)		; Puntiamo la nostra COP
	move.w	d0,$88(a6)		; Facciamo partire la COP
	move.w	#0,$1fc(a6)		; Disattiva l'AGA
	move.w	#$c00,$106(a6)		; Disattiva l'AGA
	move.w	#$11,$10c(a6)		; Disattiva l'AGA

mouse:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$12c00,d2	; linea da aspettare = $12c
Waity1:
	MOVE.L	4(A6),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $12c
	BNE.S	Waity1
Aspetta:
	MOVE.L	4(A6),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $12c
	BEQ.S	Aspetta

	bsr.w	copmove		; effetto main - sfumatura colori
	bsr.w	cycle		; fa scorrere (cicare) i colori

	btst.b	#2,$dff016		; tasto destro del mouse premuto?
	bne.s	NonCambiarMaschera
	move.w	6(a6),MascheraColori	; VHPOSR - metti un valore a caso
	move.b	7(a6),d0		; HPOSR
	and.w	#%011001110011,MascheraColori

NonCambiarMaschera:
	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse

	rts


*****************************************************************
; Questa routine fa "scorrere" i colori dal centro verso i bordi
*****************************************************************

;	       ####
;	       :00:
;	       |--|
;	    ___¯||¯___
;	  _/  _¯\/¯_  \_
;	  \___|    |___/
;	 __/ _|    |  \_/_
;	  /\ |______\   \
;	     "|     \
;	      |  V  |
;	      |  |  |
;	      |  |  |
;	     :/__|__|
;	      __| |__
;	*******************

Chiarostep:
	dc.w	10

cycle:
	lea	copbuf+6+8,a0		; primo colore in alto
	lea	copbuf+6-8+[256*8],a1	; ultimo colore in fondo

	moveq 	#128-1,d0	; numero di cicli
cycleloop:
	subq.w	#01,count	; ogni "chiarostep" schiarisci il colore.
	bne.s	gocycle
	add.w	#$101,(a0)	; schiariamo il colore 1 ogni 10
	move.w	ChiaroStep(PC),count
gocycle:
	move.w 	(a0),-8(a0)	; scroll verso l'alto della parte superiore
	move.w 	(a0),8(a1)	; scroll verso il basso della parte inferiore
	addq.w	#8,a0
	subq.w	#8,a1
	dbra	d0,cycleloop
	rts

count:
	dc.w	10

***************************************************************
; Questa routine sfuma i colori
***************************************************************

copmove:
	lea	copbuf+6+[128*8],a1	; meta' schermo
smooth:
	move.w 	ColoreOld(pc),d0
	move.w 	ColoreNewCaso(pc),d1
	cmp.w	d0,d1			; colore vecchio uguale al nuovo?
	beq.s	newcol		; allora prendi un nuovo colore "a caso"

	subq.w	#01,counter	; counter = 0?
	beq.s	gosmooth	; se si "sfuma"...
	bra.s	draw		; altrimenti metti semplicemente.

; "sfumatura" dei colori - adda e subba semplicemente le componenti, nulla di
; eccezionale.

gosmooth:
	move.w	#range,counter 

	move.w 	d0,d2
	move.w 	d1,d3
	and.w	#$000f,d2	; solo componente bli
	and.w	#$000f,d3
	cmp.w	d2,d3
	beq.s	blueready
	bgt.s	addblue
subblue:
	sub.w	#$0001,d0	; - blu
	bra.s	blueready
addblue:
	add.w	#$0001,d0	; + blu
blueready:	
	move.w 	d0,d2
	move.w 	d1,d3
	and.w	#$00f0,d2	; solo componente verde
	and.w	#$00f0,d3
	cmp.w	d2,d3
	beq.s	greenready
	bgt.s	addgreen
subgreen:
	sub.w	#$0010,d0	; - verde
	bra.s	greenready
addgreen:
	add.w	#$0010,d0	; + verde
greenready:	
	move.w 	d0,d2
	move.w 	d1,d3
	and.w	#$0f00,d2	; solo componente rossa
	and.w	#$0f00,d3
	cmp.w	d2,d3
	beq.s	redready
	bgt.s	addred
subred:
	sub.w	#$0100,d0	; - rosso
	bra.s	redready
addred:
	add.w	#$0100,d0	; + rosso
redready:
	move.w 	d0,ColoreOld
draw:
	move.w 	d0,(a1)
	rts

;-----------------------------------------------------------------------------
; Prende un colore a caso facendo casino con la posizione orizzontale del
; pennello elettronico. Non e' una gran routine ma funzionicchia per
; avere valori "pseudocasuali".
;----------------------------------------------------------------------------

newcol:
	move.w 	ColoreNewCaso(pc),ColoreOld		

	move.b 	$05(a6),d1	; $dff006 - per colore RANDOM...
	muls.w	#$71,d1
	eor.w	#$ed,d1
	muls.w	$06(a6),d1	; $dff006 - per colore RANDOM
	and.w	MascheraColori(PC),d1	; seleziona solo i bit mascheracolori
	move.w 	d1,ColoreNewCaso

	cmp.w 	ColoreOld(pc),d1
	bne.w	smooth
	add.b	#$08,ColoreNewCaso
	bra.w	smooth


MascheraColori:
		dc.w	$012

ColoreOld:		dc.w	0
ColoreNewCaso:	dc.w	0
counter:	dc.w	range

************************************************************* initcopbuf
;	crea la copperlist
************************************************************* initcopbuf

initcopbuf:
	lea	copbuf,a0
	move.l 	#$29e1fffe,d0	; prima linea wait

	move.w 	#NumeroLinee-1,d1
coploop:
	move.l 	d0,(a0)+		; metti il wait
	move.l 	#$01800000,(a0)+	; color0
	add.l	#$01000000,d0		; fai waitare una linea sotto
	dbra	d1,coploop
	rts

*************************************************************** coplist
;				COPPERLIST
*************************************************************** coplist

	section	gfx,data_C

cop:
		dc.w	$100,$200	; bplcon0 - no bitplanes
copbuf:
		ds.b	NumeroLinee*8	; spazio per l'effetto copper

		dc.w	$ffff,$fffe	; Fine della copperlist
	end

