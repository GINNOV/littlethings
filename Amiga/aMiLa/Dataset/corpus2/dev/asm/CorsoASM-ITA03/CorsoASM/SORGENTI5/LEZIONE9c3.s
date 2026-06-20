
; Lezione9c3.s	BLITTATA con modulo negativo.
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

	btst	#6,2(a5) ; dmaconr
WBlit:
	btst	#6,2(a5) ; dmaconr - attendi che il blitter abbia finito
	bne.s	wblit
;	      __
;	     /\ \
;	    /  \ \
;	   / /\ \ \
;	  / / /\ \ \
;	 / / /__\_\ \
;	/ / /________\
;	\/___________/		; i 2 registri seguenti li spiegheremo in
				; seguito:

	move.w	#$ffff,$44(a5)	; bltafwm - maschera canale A, prima word
	move.w	#$ffff,$46(a5)	; bltalwm - mask canale A, seconda word

	move.w	#$09f0,$40(a5)	; bltcon0 - canali A e D abilitati, 
				; MINTERMS=$f0, ossia copia da A a D

	move.w	#$0000,$42(a5)		; bltcon1 - lo spiegheremo in seguito

	move.w	#2*(20-8),$66(a5)	; BLTDMOD - come al solito.

	move.w	#-16,$64(a5)		; BLTAMOD - la figura e` larga 8 words
					; (16 bytes): per tornare all'inizio
					; mettiamo il modulo negativo.

	move.l	#figura_a_caso,$50(a5)	; bltapt - indirizzo figura sorgente

; L'indirizzo della destinazione dipende dalla posizione X,Y in cui vogliamo
; disegnare il primo pixel della figura. Si applicano le regole della lezione
; In questo caso X=32 e Y=4.

	move.l	#bitplane+(4*20+32/16)*2,$54(a5)	; bltdpt - ind. dest.
	move.w	#64*10+8,$58(a5)		; bltsize - altezza 10 linee,
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

;*****************************************************************************

; Questa e' la "figura" che viene copiata nel BITPLANE con una blittata:

Figura_a_caso:	
	dc.w	$1111,$1010,$2044,$235a
	dc.w	$18f0,$97ff,$ca54,$90a2


	SECTION	PLANEVUOTO,BSS_C

BITPLANE:
	ds.b	40*256		; bitplane azzerato lowres

	end

;*****************************************************************************

In questo esempio abbiamo una figura alta una sola linea che dobbiamo copiare
a partire da una certa riga dello schermo, 10 volte, ogni volta scendendo
di una riga. Naturalmente potremmo semplicemente fare un loop di 10 blittate,
modificando ogni volta l'indirizzo destinazione. E` possibile pero` farlo con
una sola blittata, mettendo un valore negativo al modulo della sorgente.
Come sapete, il valore del modulo viene aggiunto all'indirizzo contenuto
nel registro puntatore, ogni volta che il blitter finisce di blittare una riga.
Normalmente nel modulo si mette un valore positivo che permette al blitter
di "saltare" le word che non appartengono al rettangolo, andando alla riga
successiva. Se pero` il modulo ha un valore negativo, fara` "tornare indietro"
l'indirizzo contenuto nel registro puntatore. In particolare se la blittata
e` larga L words, blittando una riga il valore contenuto nel puntatore
aumentera` di 2*L (perche` il puntatore conta i bytes, e 1 word = 2 bytes).
Se mettiamo nel modulo il valore -2*L, faremo ritornare il puntatore
esattamente all'inizio della riga. In questo esempio facciamo proprio questo
con la sorgente, rileggendo ogni volta la stessa linea. Per la destinazione
invece, ci comportiamo normalmente, e quindi le 10 linee vengono scritte
una sotto l'altra.
Se vi ricordate abbiamo fatto un effetto simile con i moduli dei bitplanes,
mettendoli a -40, ottenendo un "allungamento" infinito della prima linea,
ma solo a livello di visualizzazione. In questo caso col blitter invece e'
proprio in MEMORIA che riscriviamo la stessa linea varie volte.

