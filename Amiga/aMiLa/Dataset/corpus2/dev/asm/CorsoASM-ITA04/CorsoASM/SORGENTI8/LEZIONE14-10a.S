
;  Lezione14-10a.s - Uso della routine player6.1a per un modulo non compresso

; Routine P61_Music chiamata ogni vertical blank

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

	move.w	#$e000,$9a(a5)		; INTENA - Abilito Master and lev6
	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

mouse:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$08000,d2	; linea da aspettare = $80
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

;нннннннннннннннннннннннннннннннннннннннннннннннн
;н Call P61_Music every frame to play the music	н
;н	  _NOT_ if CIA-version is used!		н
;н A6 --> Customchip baseaddress ($DFF000)	н
;нннннннннннннннннннннннннннннннннннннннннннннннн

	move.w	#$f00,$180(a5)	; color0 rosso -> per fare il copper monitor

	movem.l	d0-d7/a0-a6,-(SP)
	lea	$dff000,a6	; Ricordiamoci il $dff000 in a6!
	bsr.w	P61_Music
	movem.l	(SP)+,d0-d7/a0-a6

	move.w	#$003,$180(a5)	; color0 nero

	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse

;нннннннннннннннннннннннннннннннннннннннннннннннн
;н Call P61_End to stop the music		н
;н   A6 --> Customchip baseaddress ($DFF000)	н
;н		Uses D0/D1/A0/A1/A3		н
;нннннннннннннннннннннннннннннннннннннннннннннннн

	lea	$dff000,a6	; Ricordiamoci il $dff000 in a6!
	bsr.w	P61_End

	rts


*****************************************************************************
*		 The Player 6.1A for Asm-One 1.09 and later 		    *
*****************************************************************************

fade  = 0	;0 = Normal, NO master volume control possible
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

Vi ricordo i passaggi per suonare un modulo con questa replayroutine: come
prima cosa dovete convertire il modulo in formato P61 con l'apposita utility
P61CON, lasciando nelle preferences del programma le varie opzioni "delta",
"pack samples", ... tutte azzerate, eccetto "tempo".
In questo modo otterrete il modulo convertito adatto per essere risuonato
da questa routine. Normalmente nella conversione si risparmia anche spazio,
ma non si tratta di una "compressione", bensi' di una ottimizzazione.
Annotatevi l'usecode, perche' lo dovete mettere nel listato all'equate "use".
Questo serve per risparmiare spazio: infatti indica quali effetti sono usati
dal modulo, in modo da non assemblare quelli non usati.
A questo punto, basta includere in chip ram il modulo, e chiamare le
routines al momento giusto: P61_Init prima di suonare, come facevamo con
mt_init, P61_Music una volta ogni vertical blank (aspettando con $dff004/6 o
mettendolo in interrupt $6c), e prima di uscire P61_End.
NON DIMENTICATEVI DI ABILITARE L'INTERRUPT DI LIVELLO 6!!!! E' CON QUELLO CHE
VENGONO FATTE ALCUNE TEMPORIZZAZIONI, usando l'interrupt del timer A del CIAB.
Quindi, non potete usare il timer A del CIAB mentre si usa questa routine...
A dire il vero, anche usare il timer B del CIAB potrebbe portare problemi...
Quindi, attenti! Settate i bit 15,14,13 del $dff09a (intena), oltre agli
eventuali bit 5 o 4 (VERTB e COPER), e non usate il timer A/CIAB.
Naturalmente ci sono altri particolari, come il ricordarsi di mettere i
valori giusti nei registri ($dff000 in a6, eccetera), e settare gli equate
"fade", "jump", "system", "cia", "exec", "opt020", "use" nel modo giusto.
A questo proposito, ci sono vari esempi con gli equate settati a secondo
delle varie esigenze. In particolare, in questo esempio abbiamo CIA = 0,
perche' chiamiamo ogni volta P61_music, come sempre.

