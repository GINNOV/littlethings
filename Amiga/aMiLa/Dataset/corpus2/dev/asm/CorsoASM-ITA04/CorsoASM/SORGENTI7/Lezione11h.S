
; Lezione11h.s	Uso del COP2LC ($dff084) per fare una copperlist dinamica,
;		ossia una copperlist che ogni frame si alternano 2 copperlist
;		fatte in modo che "aumenti" la credibilita' di una sfumatura.
;		Tasto destro per vedere la differenza!

	SECTION	DynaCop,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup2.s" ; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001110000000	; solo copper e bitplane DMA

WaitDisk	EQU	30	; 50-150 al salvataggio (secondo i casi)

START:
;	 PUNTIAMO IL NOSTRO BITPLANE

	MOVE.L	#BITPLANE,d0
	LEA	BPLPOINTERS,A1
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

;	Puntiamo tutti gli sprite allo sprite nullo

	MOVE.L	#SpriteNullo,d0		; indirizzo dello sprite in d0
	LEA	SpritePointers,a1	; Puntatori in copperlist
	MOVEQ	#8-1,d1			; tutti gli 8 sprite
NulLoop:
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	addq.w	#8,a1
	dbra	d1,NulLoop

	bsr.w	InitCops	; Crea le 2 copperlist da "scambiare"

	lea	$dff000,a6
	MOVE.W	#DMASET,$96(a6)		; DMACON - abilita bitplane, copper
					; e sprites.

	move.l	#COPPERLIST,$80(a6)	; Puntiamo la nostra COP
	move.w	d0,$88(a6)		; Facciamo partire la COP
	move.w	#0,$1fc(a6)		; Disattiva l'AGA
	move.w	#$c00,$106(a6)		; Disattiva l'AGA
	move.w	#$11,$10c(a6)		; Disattiva l'AGA

mouse:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$13000,d2	; linea da aspettare = $130, ossia 304
Waity1:
	MOVE.L	4(A6),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $130 (304)
	BNE.S	Waity1

	btst	#2,$16(a6)	; tasto destro del mouse premuto?
	beq.s	NonSwappare	; Se si non scambiare (bello schifo!)

	movem.l	CoppPointer1(PC),d0-d1	; Metti con un solo MOVEM gli indirizzi
					; delle 2 copperlist in d0 e in a1
	move.l	d0,CoppPointer2		; Scambiane l'ordine...
	move.l	d1,CoppPointer1		; ...
	move.w	d1,Cop2lcl		; E punta l'altra copperlist2 come
	swap	d1			; prossima a cui saltare con
	move.w	d1,Cop2lch		; il COPJMP2 ($dff08a)
nonSwappare:

	bsr.w	PrintCarattere	; Stampa un carattere alla volta

	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$13000,d2	; linea da aspettare = $130, ossia 304
Aspetta:
	MOVE.L	4(A6),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $130 (304)
	BEQ.S	Aspetta

	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse
	rts			; esci


CoppPointer1:
		dc.l	ColInt1
CoppPointer2:
		dc.l	ColInt2

*****************************************************************************
* Routine che crea le 2 copperslist che dovranno essere visualizzate	    *
* alternativamente puntandole nel COP2LC e facendole partire con COPJMP2    *
*****************************************************************************

;	  _________________
;	 /                 \
;	 \   ___     ___   /
;	__\  (__)   (__)  /__
;	\__\___  ` '  ___/__/
;	     \ \...../ /
;	      \_______/g®m


COLSTART	EQU	$660	; Colore di partenza = giallo
COLTENDENZA	EQU	$001	; Tendenza (valore aggiunto ogni waitata)

InitCops:
	move.l	#$4407fffe,d0	; Wait - inizia dalla linea orizzontale $44
	move.l	#$1800000,d1	; Color0
	move.w	#COLSTART,d2	; Colore di partenza
	move.w	#COLTENDENZA,d3	; tendenza destinazione ($001/$010/$100)
	moveq	#2-1,d5		; 2 Copperlist da fare
	lea	ColInt1,a1	; Prima Copperlist
makecop:
	move.w	d2,d1		; Copia colstart in d1 (nel $180xxxx!)
	move.l	d0,(a1)+	; Metti il WAIT in coplist
	move.l	d1,(a1)+	; Metti il $180xxxx (color0) in coplist
	add.l	#$05000000,d0	; wait 5 linee piu' in basso la volta dopo
	move.l	d0,(a1)+	; metti wait
	move.l	d1,(a1)+	; metti il $180xxxx (color0)
	add.l	#$05000000,d0	; wait 5 linee piu' in basso
	move.w	d2,d4		; copia il colstart in d4
	and.w	#$00f,d4	; Seleziona solo la componente BLU
	cmp.w	#$00f,d4	; e' al massimo?
	beq.S	endcop		; Se si, endcop!
	move.w	d2,d4		; Altrimenti, vediamo il verde:
	and.w	#$0f0,d4	; seleziona solo la componente verde.
	cmp.w	#$0f0,d4	; E' al massimo?
	beq.S	endcop		; Se si, endcop!
	move.w	d2,d4
	and.w	#$f00,d4	; Seleziona solo la componente ROSSA
	cmp.w	#$f00,d4	; e' al massimo?
	beq.S	endcop		; Se si ENDCOP!
	add.w	d3,d2		; Aggiungi COLTENDENZA al COLORSTART
	bra.S	makecop		; E continua...
endcop:
	move.l	#$fffffffe,d0	; Fine copperlist in d0
	move.w	d2,d1		; copia COLORSTART in d1
	move.l	d0,(a1)+	; fine copperlist
	move.l	#$4907fffe,d0
	move.l	#$1800000,d1
	move.w	#COLSTART,d2
	move.w	#COLTENDENZA,d3
	lea	ColInt2,a1
	dbf	d5,makecop
	rts


*****************************************************************************
;			Routine di Print
*****************************************************************************

PRINTcarattere:
	movem.l	d2/a0/a2-a3,-(SP)
	MOVE.L	PuntaTESTO(PC),A0 ; Indirizzo del testo da stampare in a0
	MOVEQ	#0,D2		; Pulisci d2
	MOVE.B	(A0)+,D2	; Prossimo carattere in d2
	CMP.B	#$ff,d2		; Segnale di fine testo? ($FF)
	beq.s	FineTesto	; Se si, esci senza stampare
	TST.B	d2		; Segnale di fine riga? ($00)
	bne.s	NonFineRiga	; Se no, non andare a capo

	ADD.L	#40*7,PuntaBITPLANE	; ANDIAMO A CAPO
	ADDQ.L	#1,PuntaTesto		; primo carattere riga dopo
					; (saltiamo lo ZERO)
	move.b	(a0)+,d2		; primo carattere della riga dopo
					; (saltiamo lo ZERO)

NonFineRiga:
	SUB.B	#$20,D2		; TOGLI 32 AL VALORE ASCII DEL CARATTERE, IN
				; MODO DA TRASFORMARE, AD ESEMPIO, QUELLO
				; DELLO SPAZIO (che e' $20), in $00, quello
				; DELL'ASTERISCO ($21), in $01...
	LSL.W	#3,D2		; MOLTIPLICA PER 8 IL NUMERO PRECEDENTE,
				; essendo i caratteri alti 8 pixel
	MOVE.L	D2,A2
	ADD.L	#FONT,A2	; TROVA IL CARATTERE DESIDERATO NEL FONT...

	MOVE.L	PuntaBITPLANE(PC),A3 ; Indir. del bitplane destinazione in a3

				; STAMPIAMO IL CARATTERE LINEA PER LINEA
	MOVE.B	(A2)+,(A3)	; stampa LA LINEA 1 del carattere
	MOVE.B	(A2)+,40(A3)	; stampa LA LINEA 2  " "
	MOVE.B	(A2)+,40*2(A3)	; stampa LA LINEA 3  " "
	MOVE.B	(A2)+,40*3(A3)	; stampa LA LINEA 4  " "
	MOVE.B	(A2)+,40*4(A3)	; stampa LA LINEA 5  " "
	MOVE.B	(A2)+,40*5(A3)	; stampa LA LINEA 6  " "
	MOVE.B	(A2)+,40*6(A3)	; stampa LA LINEA 7  " "
	MOVE.B	(A2)+,40*7(A3)	; stampa LA LINEA 8  " "

	ADDQ.L	#1,PuntaBitplane ; avanziamo di 8 bit (PROSSIMO CARATTERE)
	ADDQ.L	#1,PuntaTesto	; prossimo carattere da stampare

FineTesto:
	movem.l	(SP)+,d2/a0/a2-a3
	RTS


PuntaTesto:
	dc.l	TESTO

PuntaBitplane:
	dc.l	BITPLANE

;	$00 per "fine linea" - $FF per "fine testo"

		; numero caratteri per linea: 40
TESTO:	     ;		  1111111111222222222233333333334
             ;   1234567890123456789012345678901234567890
	dc.b	'                                        ',0 ; 1
	dc.b	'    Questo listato utilizza il COP2LC   ',0 ; 2
	dc.b	'                                        ',0 ; 3
	dc.b	'    ($dff084) per far saltare, ad una   ',0 ; 4
	dc.b	'                                        ',0 ; 5
	dc.b	'    certa linea video, ad un altra      ',0 ; 6
	dc.b	'                                        ',0 ; 7
	dc.b	'    copperlist. Al termine di questa    ',0 ; 8
	dc.b	'                                        ',0 ; 9
	dc.b	'    riparte sempre e comunque la        ',0 ; 10
	dc.b	'                                        ',0 ; 11
	dc.b	'    copperlist 1 (in $dff180). Dunque   ',0 ; 12
	dc.b	'                                        ',0 ; 13
	dc.b	'    basta cambiare solo la cop2 a cui   ',0 ; 14
	dc.b	'                                        ',0 ; 15
	dc.b	'    puntare ogni frame, per DynamiCop!  ',0 ; 16
	dc.b	'                                        ',0 ; 17
	dc.b	'    Il tasto destro ferma lo scambio.   ',$FF ; 18

	EVEN

;	Il FONT caratteri 8x8 (copiato in CHIP dalla CPU e non dal blitter,
;	per cui puo' stare anche in fast ram. Anzi sarebbe meglio!

FONT:
	incbin	"assembler2:sorgenti4/nice.fnt"

****************************************************************************

	Section	copperDynamic,data_C

copperlist:
SpritePointers:
	dc.w	$120,0,$122,0,$124,0,$126,0,$128,0 ; SPRITE
	dc.w	$12a,0,$12c,0,$12e,0,$130,0,$132,0
	dc.w	$134,0,$136,0,$138,0,$13a,0,$13c,0
	dc.w	$13e,0

	dc.w	$8E,$2c81	; DiwStrt
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$0038	; DdfStart
	dc.w	$94,$00d0	; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod
		    ; 5432109876543210
	dc.w	$100,%0001001000000000	; 1 bitplane LOWRES 320x256

BPLPOINTERS:
	dc.w $e0,0,$e2,0	;primo	 bitplane

	dc.w	$180,COLSTART	; COLOR0 - colore di "partenza"
	dc.w	$182,$FF0	; color1 - SCRITTE

;	dc.w	$2ce1,$fffe	; Waitiamo almeno Y=$2c X=$d7

	dc.w	$84		; registro COP2LCH (indirizzo copper 2!)
COP2LCH:
	dc.w	0
	dc.w	$86		; registro COP2LCL
COP2LCL:
	dc.w	0

	dc.w	$8a,$000	; COPJMP2 - fai partire la copperlist 2

****************************************************************************

; spazio per la copperlist 1

ColInt1:
	dcb.l	2*60,0

****************************************************************************

; spazio per la copperlist 2

ColInt2:
	dcb.l	2*60,0


*****************************************************************************

	SECTION	MIOPLANE,BSS_C

BITPLANE:
	ds.b	40*256	; un bitplane lowres 320x256

SpriteNullo:			; Sprite nullo da puntare in copperlist
	ds.l	4		; negli eventuali puntatori inutilizzati

	END

