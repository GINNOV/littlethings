
; Lezione9b2.s	LOOP DI BLITTATE DI UNA SOLA LINEA

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

; in A0 viene memorizzato l'indirizzo della destinazione che varia di volta in
; volta. L'indirizzo iniziale e` calcolato per visualizzare la figura alla
; riga Y=3 a partire dal pixel con X=0

	lea	bitplane+(3*20+0/16)*2,a0	; indirizzo destinazione
	move.w	#200-1,d7			; numero di loop = 200

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

	btst.b	#6,2(a5) ; dmaconr
WBlit:
	btst.b	#6,2(a5) ; dmaconr - attendi che il blitter abbia finito
	bne.s	wblit

;	          (####)
;	        (#######)
;	      (#########)
;	     (#########)
;	    (#########)
;	   (#########)
;	  (#########)
;	   (o)(o)(##)
;	 ,_c     (##)
;	/____,   (##)
;	  \     (#)
;	   |    |
;	   oooooo
;	  /      \

	move.w	#$ffff,$44(a5)		; BLTAFWM lo spiegheremo in seguito
	move.w	#$ffff,$46(a5)		; BLTALWM lo spiegheremo in seguito
	move.w	#$05CC,$40(a5)		; BLTCON0 (fa una copia da B a D)
	move.w	#$0000,$42(a5)		; BLTCON1 lo spiegheremo in seguito
	move.w	#$0000,$62(a5)		; BLTBMOD lo spiegheremo in seguito
	move.w	#$0000,$66(a5)		; BLTDMOD lo spiegheremo in seguito
	move.l	#figura,$4c(a5)		; BLTBPT  (fisso alla figura sorgente)
	move.l	a0,$54(a5)		; BLTDPT  (destinazione variabile a0)
	move.w	#64*1+10,$58(a5)	; BLTSIZE (via al blitter !)
					; ora, invece di 8 word, come nell
					; esempio precedente, blittiamo 10 word

	add.w	#40,a0			; andiamo a blittare alla prossima
					; linea nel prossimo loop.
	dbra	d7,blitloop

mouse:
	btst	#6,$bfe001	; mouse premuto?
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

*****************************************************************************

	SECTION	Figura_da_blittare,DATA_C

Figura:
	dc.w	$8888,$aaaa,$cccc,$f0f0
	dc.w	$ffff,$6666,$eeee,$5555
	dc.w	$2222,$dddd

*****************************************************************************

	SECTION	PLANEVUOTO,BSS_C	

BITPLANE:
	ds.b	40*256		; bitplane azzerato lowres

	end

*****************************************************************************

Questo esempio e` una variazione dell'esempio lezione9b1.s
Notate come variando l'indirizzo di destinazione i dati vengano copiati
in zone distinte dello schermo. Ogni blittata viene fatta una riga piu` in
basso della precedente. Cio` viene ottenuto aggiungendo sempre 40 (=numero
di bytes per ogni riga) all'indirizzo destinazione.

Notate una cosa molto importante: prima di OGNI blittata si aspetta SEMPRE che
il blitter abbia finito la blittata precedente, mediante il loop Wblit.

In questo esempio abbiamo usato il canale B come canale sorgente.
Conseguentemente, usiamo i registri BLTBPT e BLTBMOD al posto di BLTAPT e
BLTAMOD; inoltre il valore scritto in BLTCON0 e` diverso, perche` dobbiamo
attivare il canale B invece del canale A (quindi il bit 11 vale 0 e il bit 10
vale 1) e perche` dobbiamo porre i MINTERMS al valore $CC che definisce appunto
una copia dal canale B al canale D

