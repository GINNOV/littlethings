
; Lezione9b1.s	BLITTATA, in cui copiamo 8 word in un bitplane azzerato.
;		Tasto sinistro per eseguire la blittata, destro per uscire.

	SECTION	CiriCop,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup1.s"	; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001111000000	; copper,bitplane,blitter DMA


START:
;	Puntiamo la PIC "vuota"

	MOVE.L	#BITPLANE,d0	; dove puntare
	LEA	BPLPOINTERS,A1	; puntatori COP
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

	lea	$dff000,a5		; CUSTOM REGISTER in a5
	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

Aspettasin:
	btst	#6,$bfe001	; aspetta la pressione del tasto sin. mouse
	bne.s	Aspettasin

	btst.b	#6,2(a5) ; dmaconr
WBlit:
	btst.b	#6,2(a5) ; dmaconr - attendi che il blitter abbia finito
	bne.s	wblit

;	 |\/\/\/|
;	 |      |
;	 |      |
;	 | (o)(o)
;	 c      _)
;	  | ,___|
;	  |   /
;	 /____\
;	/      \		; i 2 registri seguenti li spiegheremo in
				; seguito:

	move.w	#$ffff,$44(a5)	; bltafwm - maschera canale A, prima word
	move.w	#$ffff,$46(a5)	; bltalwm - mask canale A, seconda word

	move.w	#$09f0,$40(a5)	; bltcon0 - canali A e D abilitati, 
				; MINTERMS=$f0, ossia copia da A a D
	move.w	#$0000,$42(a5)		; bltcon1 - lo spiegheremo in seguito
	move.l	#figura_a_caso,$50(a5)	; bltapt - indirizzo figura sorgente

; l'indirizzo della destinazione dipende dalla posizione X,Y in cui vogliamo
; disegnare il primo pixel della figura. Si applicano le regole della lezione
; In questo caso X=32 e Y=4.

	move.l	#bitplane+(4*20+32/16)*2,$54(a5)	; bltdpt - ind. dest.
	move.w	#64*1+8,$58(a5)			; bltsize - altezza 1 linea,
						; larghezza 8 words.

mouse:
	btst	#2,$dff016	; tasto destro del mouse premuto?
	bne.s	mouse

	btst	#6,2(a5) ; dmaconr
WBlit2:
	btst	#6,2(a5) ; dmaconr - attendi che il blitter abbia finito
	bne.s	wblit2

	rts

;*****************************************************************************

	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$8E,$2c81	; DiwStrt
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$38		; DdfStart
	dc.w	$94,$d0		; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

	dc.w	$100,$1200	; bplcon0 - 1 bitplane lowres

BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane

	dc.w	$0180,$000	; color0
	dc.w	$0182,$eee	; color1

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;****************************************************************************

; Questa e' la "figura" che viene copiata nel BITPLANE con una blittata:

Figura_a_caso:	
	dc.w	$1111,$1010,$2044,$235a
	dc.w	$18f0,$97ff,$ca54,$90a2

;****************************************************************************

	SECTION	PLANEVUOTO,BSS_C

BITPLANE:
	ds.b	40*256		; bitplane azzerato lowres

	end

;***************************************************************************

In questo esempio copiamo una zona di memoria con il blitter.
Piu` precisamente leggiamo 8 words (considerandole come un rettangolo largo
8 words e alto una sola linea) a partire dall'indirizzo identificato
dalla label "Figura_a_caso:" e le riscriamo a partire dall'indirizzo
identificato dalla label "BITPLANE:", che, come si capisce dal nome della
label e` l'indirizzo di una zona di memoria che contiene un bitplane.
In realta' li copiamo in BITPLANE+offset, ossia scostati dall'angolo d'inizio.
Pertanto i dati che copieremo vengono visualizzati sullo schermo.
Per eseguire un operazione di copia e` necessario utilizzare 2 canali
DMA, uno per leggere e uno per scrivere. In questo caso usiamo il canale
A per leggere, e ovviamente il D per scrivere. Pertanto solo questi 2 canali
sono abilitati settando a 1 i relativi bit nel registro BLTCON0.
Per indicare al blitter che deve eseguire una copia dal canale A al canale
D e` necessario porre il byte che contiene i MINTERMS al valore $f0.
Provate a variare la posizione nella quale viene disegnata la figura variando
l'indirizzo destinazione della blittata. Applicate le regole viste nella
lezione.

