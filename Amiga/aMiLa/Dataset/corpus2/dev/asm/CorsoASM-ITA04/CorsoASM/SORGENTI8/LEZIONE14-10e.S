
;  Lezione14-10e.s - Uso della routine player6.1a per un modulo non compresso

; Routine P61_Music chiamata da interrupt VERTB ($6c) livello3

; Inoltre e' abilitato il controllo del master volume: opzione fade=1

	SECTION	Usoplay61a,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup2.s" ; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001111000000	; solo copper DMA

WaitDisk	EQU	30	; 50-150 al salvataggio (secondo i casi)

START:

;нннннннннннннннннннннннннннннннннннннннннннннннн
;н Call P61_Init to initialize the playroutine	н
;н D0 --> Timer detection (for CIA-version)	н
;н A0 --> Address to the module			н
;н A1 --> Address to samples/0			н
;н A2 --> Address to sample buffer		н
;н D0 <-- 0 if succeeded			н
;н A6 <-- $DFF000				н
;нннннннннннннннннннннннннннннннннннннннннннннннн

	movem.l	d0-d7/a0-a6,-(SP)
	lea	P61_data,a0	; Indirizzo del modulo in a0
	lea	$dff000,a6	; Ricordiamoci il $dff000 in a6!
	sub.l	a1,a1		; I samples non sono a parte, mettiamo zero
	sub.l	a2,a2		; no samples -> modulo non compattato
	bsr.w	P61_Init
	movem.l	(SP)+,d0-d7/a0-a6

	lea	$dff000,a5
	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
					; e sprites.

	move.l	BaseVBR(PC),a0
	move.l	#Myint6c,$6c(a0)	; metto la mia routine interrupt

	move.w	#$e020,$9a(a5)		; INTENA - Abilito Master and lev6
					; e VERTB (lev3).

	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

	clr.w	P61_Master	; volume=0

mouse:
	bsr.s	SpettaBlank
	bsr.s	AlzaVolume
	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse

mouse2:
	bsr.s	SpettaBlank
	bsr.s	AbbassaVolume
	btst	#2,$dff016	; mouse premuto?
	bne.s	mouse2

;нннннннннннннннннннннннннннннннннннннннннннннннн
;н Call P61_End to stop the music		н
;н   A6 --> Customchip baseaddress ($DFF000)	н
;н		Uses D0/D1/A0/A1/A3		н
;нннннннннннннннннннннннннннннннннннннннннннннннн

	lea	$dff000,a6	; Ricordiamoci il $dff000 in a6!
	bsr.w	P61_End

	rts

*****************************************************************************
; Routine che aspetta il Vblank
*****************************************************************************


SpettaBlank:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$10000,d2	; linea da aspettare = $100
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $100
	BNE.S	Waity1
Aspetta:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $12c
	BEQ.S	Aspetta
	rts

*****************************************************************************
; Semplici routines che controllano la label P61_Master			    *
*****************************************************************************

AbbassaVolume:
	tst.w	P61_Master	; Minimo volume raggiunto?
	beq.s	NonAbbassare
	subq.w	#1,P61_Master
NonAbbassare:
	rts

AlzaVolume:
	cmp.w	#64,P61_Master	; Massimo volume raggiunto?
	beq.s	NonAlzare
	addq.w	#1,P61_Master
NonAlzare:
	rts

*****************************************************************************
*		Routine in interrupt livello 3 ($6c)			    *
*****************************************************************************

MyInt6c:
	btst	#5,$dff01f	; INTREQR - int VERTB?
	beq.s	noint		; se no, esci!

	movem.l	d0-d7/a0-a6,-(SP)
	lea	$dff000,a6	; Ricordiamoci il $dff000 in a6!
	bsr.w	P61_Music
	movem.l	(SP)+,d0-d7/a0-a6

noint:	
	move.w	#$70,$dff09c	; INTENAR
	rte

*****************************************************************************
*		 The Player 6.1A for Asm-One 1.09 and later 		    *
*****************************************************************************

fade  = 1	;0 = Normal, NO master volume control possible
		;1 = Use master volume (P61_Master)

jump = 0	;0 = do NOT include position jump code (P61_SetPosition)
		;1 = Include

system = 0	;0 = killer
		;1 = friendly

CIA = 0		;0 = CIA disabled
		;1 = CIA enabled

exec = 1	;0 = ExecBase destroyed
		;1 = ExecBase valid

opt020 = 0	;0 = MC680x0 code
		;1 = MC68020+ or better

use = $2009559	; Usecode (mettete il valore dato dal p61con al salvataggio
		; diverso per ogni modulo!)

*****************************************************************************
	include	"play.s"	; La routine vera e propria!
*****************************************************************************


*****************************************************************************
;	Copperlist
*****************************************************************************

	SECTION	COP,DATA_C

COPPERLIST:
	dc.w	$100,$200	; bplcon0 - no bitplanes
	DC.W	$180,$003	; color0 nero
	dc.W	$FFFF,$FFFE	; fine della copperlist

*****************************************************************************
;	Modulo musicale convertito in formato P61, non compresso
*****************************************************************************

	Section	modulozzo,data_C

; Il modulo e' di DreamFish. Originale 42684, convertito 31628 (non packed!)

P61_data:
	incbin	"P61.technochild"	; non compresso, solo convertito.

	end

L'utilita' del "fade" audio e' evidente... alla fine di un livello del vostro
gioco, o all'uscita della demo, eccetera.
Basta attivare l'equate "fade", e agire sulla label "P61_Master".
Giusto per variare, qua la routine viene eseguita in interrupt VERTB ($6c).

