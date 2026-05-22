
; Lezione9c1.s	PRIMA BLITTATA CON ALTEZZA MAGGIORE DI 1 E MODULI
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

;	    /\  /\
;	.--/  \/  \---.
;	 \           /
;	._> (o)(o   <__.
;	 \  _C        /
;	 / /____,  )  \
;	'----\    /----`
;	      oooo
;	     /    \

	move.w	#$ffff,$44(a5)		; BLTAFWM lo spiegheremo dopo
	move.w	#$ffff,$46(a5)		; BLTALWM lo spiegheremo dopo
	move.w	#$09f0,$40(a5)		; BLTCON0 (usa A+D)
	move.w	#$0000,$42(a5)		; BLTCON1 lo spiegheremo dopo
	move.w	#0,$64(a5)		; BLTAMOD =0 perche` il rettangolo
					; sorgente ha le righe consecutive
					; in memoria.

	move.w	#36,$66(a5)		; BLTDMOD 40-4=36 il rettangolo
					; destinazione e` all'interno di un
					; bitplane largo 20 words, ovvero 40
					; bytes. Il rettangolo blittato
					; e` largo 2 words, cioe` 4 bytes.
					; Il valore del modulo e` dato dalla
					; differenza tra le larghezze

	move.l	#figura,$50(a5)		; BLTAPT  (fisso alla figura sorgente)
	move.l	#bitplane,$54(a5)	; BLTDPT  (linee dello schermo)
	move.w	#(64*6)+2,$58(a5)	; BLTSIZE (via al blitter !)
					; adesso, blitteremo una figura di
					; 2 word X 6 linee con una sola
					; blittata coi moduli opportunamente
					; settati per lo schermo.
mouse:
	btst	#2,$16(a5)	; tasto destro del mouse premuto?
	bne.s	mouse

	btst.b	#6,2(a5) ; dmaconr
WBlit2:
	btst.b	#6,2(a5) ; dmaconr - attendi che il blitter abbia finito
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

; Definiamo in binario la figura, che e' larga 16 bits, ossia 2 words, e alta
; 6 linee. Notate che le linee sono disposte consecutivamente in memoria.

Figura:
	dc.l	%00000000000000000000110001100000	; linea 1
	dc.l	%00000000000000000011000110000000	; linea 2
	dc.l	%00000000000000001100011000000000
	dc.l	%00000110000000110001100000000000
	dc.l	%00000001100011000110000000000000
	dc.l	%00000000011100011000000000000000	; linea 6

;*****************************************************************************

	SECTION	PLANEVUOTO,BSS_C

BITPLANE:
	ds.b	40*256		; bitplane azzerato lowres

	end

*****************************************************************************

In questo esempio vedete come effettuare la copia di un rettangolo.
Innanzitutto notate ancora una volta la formula da utilizzare per scrivere
le dimensioni del rettangolo in BLTSIZE. Prestate poi molta attenzione a come
sono calcolati i moduli. Per quanto riguarda la sorgente, che inizia alla
label "Figura", le righe del rettangolo sono disposte consecutivamente in
memoria. Pertanto, il valore del modulo per la sorgente (il canale A) vale 0.
Per quanto riguarda la destinazione invece, poiche` dobbiamo copiare il
rettangolo all'interno di un bitplane piu` largo del rettangolo in questione,
le righe non sono consecutive in memoria e si deve specificare un valore del
modulo calcolato con le formule viste nella lezione.

