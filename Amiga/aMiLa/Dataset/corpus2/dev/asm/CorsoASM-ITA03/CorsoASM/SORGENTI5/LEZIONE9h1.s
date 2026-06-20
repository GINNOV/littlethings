
; Lezione9h1.s		Esempio di uso delle Mask

; Premete alternativamente i tasti destro e sinistro del mouse per vedere
; varie blittate con maschere diverse.


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

; prepara i parametri

	move.w	#$ffff,d0		; maschera prima word
					; fa passare tutti i bit
	move.w	#$ffff,d1		; maschera ultima word
					; fa passare tutti i bit
	lea	bitplane+2,a0		; indirizzo destinazione
	bsr.w	Copia

mouse2:
	btst	#2,$dff016		; tasto destro del mouse premuto?
	bne.s	mouse2

; prepara i parametri

	moveq	#$0000,d0		; maschera prima word
					; cancella tutto
	move.w	#$ffff,d1		; maschera ultima word
					; fa passare tutti i bit
	move.l	#bitplane+30*40+2,a0	; indirizzo destinazione
	bsr.s	Copia
mouse3:
	btst	#6,$bfe001		; mouse premuto?
	bne.s	mouse3

; prepara i parametri

	move.w	#%1010101010101010,d0	; maschera prima word
					; un bit si e uno no
	move.w	#%0000000000000001,d1	; maschera ultima word
					; solo bit piu` a destra
	lea	bitplane+60*40+2,a0	; indirizzo destinazione
	bsr.s	Copia

mouse4:
	btst	#2,$dff016		; tasto destro del mouse premuto?
	bne.s	mouse4

; prepara i parametri

	moveq	#$0000,d0		; maschera prima word
					; cancella tutto
	moveq	#$0000,d1		; maschera ultima word
					; cancella tutto
	lea	bitplane+90*40+2,a0	; indirizzo destinazione
	bsr.s	Copia

mouse5:
	btst	#6,$bfe001		; mouse premuto?
	bne.s	mouse5

; prepara i parametri
	move.w	#%1111000011110000,d0	; maschera prima word
					; 4 bit si e 4 no
	move.w	#%0000011010011100,d1	; maschera ultima word
					; fa passare solo i bit 2,3,4,7,9 e 10
	lea	bitplane+120*40+2,a0	; indirizzo destinazione
	bsr.s	Copia

mouse6:
	btst	#2,$dff016		; tasto destro del mouse premuto?
	bne.s	mouse6

; prepara i parametri
	move.w	#%0000000001111111,d0	; maschera prima word
					; cancella i 9 bit piu` a sinistra
	move.w	#%1111111000000000,d1	; maschera ultima word
					; cancella i 9 bit piu` a destra
	lea	bitplane+150*40+2,a0	; indirizzo destinazione
	bsr.s	Copia

mouse:
	btst	#6,$bfe001
	bne.s	mouse

	rts

;****************************************************************************
; Questa routine copia la figura sullo schermo.
;
; A0   - indirizzo destinazione
; D0.w - maschera prima word
; D1.w - maschera ultima word
;****************************************************************************

;	    .....        ___
;	 .:::::::::.  /\////
;	:¦::·_  _·:¦. \  _/
;	:|   ¤,¸¤  l: / /
;	:\ \/\___T /:/ /
;	::\_______/:: /
;	· __|  l__/ :/
;	 /_,       _/
;	/ (__°_X_°__)
;	\  j      |
;	 \ \   .  |
;	  \ \_____|
;	   \ \__" \
;	   (_,_,)  \
;	   | ¯ ¯T   \
;	   |    l_  _)
;	   |    |   /
;	  _l____l__/
;	 (_____)\  \
;	         \__)

Copia:
	btst	#6,2(a5) ; dmaconr
WBlit1:
	btst	#6,2(a5) ; dmaconr - attendi che il blitter abbia finito
	bne.s	wblit1

	move.w	d0,$44(a5)		; BLTAFWM carica il parametro
	move.w	d1,$46(a5)		; BLTALWM carica il parametro
	move.w	#$09f0,$40(a5)		; BLTCON0 (usa A+D)
	move.w	#$0000,$42(a5)		; BLTCON1 lo spieghiamo dopo
	move.w	#0,$64(a5)		; BLTAMOD (=0)
	move.w	#34,$66(a5)		; BLTDMOD (40-6=34)
	move.l	#figura,$50(a5)		; BLTAPT  (fisso alla figura sorgente)
	move.l	a0,$54(a5)		; BLTDPT  carica il parametro
	move.w	#(64*7)+3,$58(a5)	; BLTSIZE (via al blitter !)
					; larghezza 3 word
	rts				; altezza 7 linee (1 plane)

;****************************************************************************

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
	dc.w	$100,$1200	; bplcon0 - 1 bitplane Lowres

BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane

	dc.w	$0180,$000	; color0
	dc.w	$0182,$eee	; color1

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;****************************************************************************

; Definiamo in binario la figura, che e' larga 3 words, e alta 7 linee

Figura:
;		 0123456789012345  0123456789012345  0123456789012345
	dc.w	%1111111111000000,%0000001111000000,%0000001111111111
	dc.w	%1111111111000000,%0000111111110000,%0000001111111111
	dc.w	%1111111111000000,%0011111111111100,%0000001111111111
	dc.w	%1111111111111111,%1111111111111111,%1111111111111111
	dc.w	%1111111111000000,%0011111111111100,%0000001111111111
	dc.w	%1111111111000000,%0000111111110000,%0000001111111111
	dc.w	%1111111111000000,%0000001111000000,%0000001111111111

;****************************************************************************

	SECTION	PLANEVUOTO,BSS_C	

BITPLANE:
	ds.b	40*256		; bitplane azzerato lowres

	end

;****************************************************************************

In questo esempio mostriamo come le maschere influiscano sulla blittata.
Abbiamo una figura (ad un solo plane) che viene copiata piu` volte sullo
schermo in posizioni diverse.
Ogni copia, pero` viene eseguita con delle maschere diverse, producendo gli
effetti che vedete.
Abbiamo utilizzato una routine che prende come parametri i valori delle
maschere e l'indirizzo destinazioine della blittata.
In tal modo eseguiamo tutte le copie con una sola routine, cambiando solo il
valore dei parametri.
I parametri vengono passati alla routine attraverso dei registri del 68000.
Per capire l'effetto che hanno i diversi valori delle maschere, leggete i
commenti nel listato.

