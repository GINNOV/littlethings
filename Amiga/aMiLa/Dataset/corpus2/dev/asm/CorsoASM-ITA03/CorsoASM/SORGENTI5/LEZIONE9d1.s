
; Lezione9d1.s	LOOP DI UNA BLITTATA CON ALTEZZA 6 LINEE E MODULI


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

	lea	bitplane,a0	; indirizzo bitplane destinazione
	move.w	#(150-6)-1,d7	; -6 perche' la figura e' alta 6 linee,
				; percui "arriva" 6 linee piu' in basso di
				; dove si blitta.
BlitLoop:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$10800,d2	; linea da aspettare = $108
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $108
	BNE.S	Waity1
Waity2:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $108
	Beq.S	Waity2

	btst	#6,2(a5) ; dmaconr
WBlit:
	btst	#6,2(a5) ; dmaconr - attendi che il blitter abbia finito
	bne.s	wblit

;	/\ ___
;	\ (_ _)
;	 \ \ª/ )
;	  \ , /
;	  / \/\
;	 /__I__\

	move.w	#$ffff,$44(a5)		; BLTAFWM lo spieghiamo in seguito
	move.w	#$ffff,$46(a5)		; BLTALWM lo spieghiamo in seguito
	move.w	#$09f0,$40(a5)		; BLTCON0 (usa A+D)
	move.w	#$0000,$42(a5)		; BLTCON1 lo spieghiamo in seguito
	move.w	#0,$64(a5)		; BLTAMOD (=0)
	move.w	#36,$66(a5)		; BLTDMOD (40-4=36)
	move.l	#figura,$50(a5)		; BLTAPT  (fisso alla figura sorgente)
	move.l	a0,$54(a5)		; BLTDPT  (dest: linee di schermo)
	move.w	#(64*6)+2,$58(a5)	; BLTSIZE (via al blitter !)
					; adesso, blitteremo una figura di
					; 2 word X 6 linee con una sola
					; blittata dai moduli opportunamente
					; settati correttamente per lo schermo.

	add.w	#40,a0			; andiamo a blittare alla prossima
					; linea nel prossimo loop.
					; 40 e` il numero di bytes in una riga.
					; aggiungendo tale numero, ci spostiamo
					; in basso di una riga.

	dbra	d7,blitloop

mouse:

	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse

	btst	#6,2(a5) ; dmaconr
WBlit3:
	btst	#6,2(a5) ; dmaconr - attendi che il blitter abbia finito
	bne.s	wblit3

	rts

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

	dc.w	$100,$1200	; Bplcon0 - 1 bitplane lowres

BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane

	dc.w	$0180,$000	; color0
	dc.w	$0182,$eee	; color1
	dc.w	$FFFF,$FFFE	; Fine della copperlist

;****************************************************************************

; Definiamo in binario la figura, che e' larga 16 bits, ossia 2 words, e alta
; 6 linee

Figura:
	dc.l	%00000000000000000000110001100000
	dc.l	%00000000000000000011000110000000
	dc.l	%00000000000000001100011000000000
	dc.l	%00000110000000110001100000000000
	dc.l	%00000001100011000110000000000000
	dc.l	%00000000011100011000000000000000

;****************************************************************************

	SECTION	PLANEVUOTO,BSS_C	

BITPLANE:
	ds.b	40*256		; bitplane azzerato lowres

	end

;****************************************************************************

In questo esempio vediamo un esempio di animazione con il blitter.
Molto semplicemente  si disegna con il blitter la figura in una posizione
sempre piu' bassa ad ogni vertical blank.
La posizione della figura viene determinata dall'indirizzo che viene scritto
nel registro BLTDPT, notate infatti che il valore scritto in questo registro
viene cambiato ad ogni frame:

	add.w	#40,a0			; andiamo a blittare alla prossima
					; linea nel prossimo loop.
					; 40 e` il numero di bytes in una riga.
					; aggiungendo tale numero, ci spostiamo
					; in basso di una riga.

La figura "lascia la scia", perche' non cancelliamo ogni volta la figura che
abbiamo blittato prima. E' come un brush (pennello) del DPaint.

