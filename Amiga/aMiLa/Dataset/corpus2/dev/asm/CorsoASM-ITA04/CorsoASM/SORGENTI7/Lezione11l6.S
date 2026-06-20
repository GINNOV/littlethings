
; Lezione11l6.s		Routine di gestione del modo interlacciato (640x512)
;			che legge il bit 15 (LOF) del VPOSR ($dff004).
;			Premendo il tasto destro non si esegue tale routine,
;			e si nota come rimangano alle volte le linee pari o
;			le dispari in "pseudo-non lace".

	SECTION	Interlace,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup2.s"	; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001110000000	; solo copper e bitplane DMA

WaitDisk	EQU	30

scr_bytes	= 80	; Numero di bytes per ogni linea orizzontale.
			; Da questa si calcola la larghezza dello schermo,
			; moltiplicando i bytes per 8: schermo norm. 320/8=40
			; Es. per uno schermo largo 336 pixel, 336/8=42
			; larghezze esempio:
			; 264 pixel = 33 / 272 pixel = 34 / 280 pixel = 35
			; 360 pixel = 45 / 368 pixel = 46 / 376 pixel = 47
			; ... 640 pixel = 80 / 648 pixel = 81 ...

scr_h		= 256	; Altezza dello schermo in linee
scr_x		= $81	; Inizio schermo, posizione XX (normale $xx81) (129)
scr_y		= $2c	; Inizio schermo, posizione YY (normale $2cxx) (44)
scr_res		= 2	; 2 = HighRes (640*xxx) / 1 = LowRes (320*xxx)
scr_lace	= 1	; 0 = non interlace (xxx*256) / 1 = interlace (xxx*512)
ham		= 0	; 0 = non ham / 1 = ham
scr_bpl		= 1	; Numero Bitplanes

; parametri calcolati automaticamente

scr_w		= scr_bytes*8		; larghezza dello schermo
scr_size	= scr_bytes*scr_h	; dimensione in bytes dello schermo
BPLC0	= ((scr_res&2)<<14)+(scr_bpl<<12)+$200+(scr_lace<<2)+(ham<<11)
DIWS	= (scr_y<<8)+scr_x
DIWSt	= ((scr_y+scr_h/(scr_lace+1))&255)<<8+(scr_x+scr_w/scr_res)&255
DDFS	= (scr_x-(16/scr_res+1))/2
DDFSt	= DDFS+(8/scr_res)*(scr_bytes/2-scr_res)


START:

;	Puntiamo i bitplanes in copperlist

	MOVE.L	#BITPLANE,d0	; in d0 mettiamo l'indirizzo del bitplane
	LEA	BPLPOINTERS,A1	; puntatori nella COPPERLIST
	move.w	d0,6(a1)	; copia la word BASSA dell'indirizzo del plane
	swap	d0		; scambia le 2 word di d0 (es: 1234 > 3412)
	move.w	d0,2(a1)	; copia la word ALTA dell'indirizzo del plane


	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
					; e sprites.

	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

mouse:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$01000,d2	; linea da aspettare = $010
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $010
	BNE.S	Waity1
Waity2:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $010
	Beq.S	Waity2

	btst	#2,$16(A5)	; Tasto destro premuto?
	beq.s	NonLaceint

	bsr.s	laceint		; Routine che punta linee pari o dispari
				; ogni frame a seconda del bit LOF per
				; l'interlace
NonLaceint:
	bsr.w	PrintCarattere	; Stampa un carattere alla volta

	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse

	rts

******************************************************************************
; INTERLACE ROUTINE - Testa il bit LOF (Long Frame) per sapere se si devono
; visualizzare le linee pari o quelle dispari, e punta di conseguenza.
******************************************************************************

LACEINT:
	MOVE.L	#BITPLANE,D0	; Indirizzo bitplane
	btst.b	#15-8,4(A5)	; VPOSR LOF bit?
	Beq.S	Faidispari	; Se si, tocca alle linee dispari
	ADD.L	#scr_bytes,D0		; Oppure aggiungi la lunghezza di una linea,
				; facendo partire la visualizzazione dalla
				; seconda: visualizzate linee pari!
FaiDispari:
	LEA	BPLPOINTERS,A1	; PLANE POINTERS IN COPLIST
	MOVE.W	D0,6(A1)	; Punta la figura
	SWAP	D0
	MOVE.W	D0,2(A1)
	RTS

*****************************************************************************
;			Routine di Print
*****************************************************************************

PRINTcarattere:
	MOVE.L	PuntaTESTO(PC),A0 ; Indirizzo del testo da stampare in a0
	MOVEQ	#0,D2		; Pulisci d2
	MOVE.B	(A0)+,D2	; Prossimo carattere in d2
	CMP.B	#$ff,d2		; Segnale di fine testo? ($FF)
	beq.s	FineTesto	; Se si, esci senza stampare
	TST.B	d2		; Segnale di fine riga? ($00)
	bne.s	NonFineRiga	; Se no, non andare a capo

	ADD.L	#scr_bytes*7,PuntaBITPLANE	; ANDIAMO A CAPO
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
	MOVE.B	(A2)+,scr_bytes(A3)	; stampa LA LINEA 2  " "
	MOVE.B	(A2)+,scr_bytes*2(A3)	; stampa LA LINEA 3  " "
	MOVE.B	(A2)+,scr_bytes*3(A3)	; stampa LA LINEA 4  " "
	MOVE.B	(A2)+,scr_bytes*4(A3)	; stampa LA LINEA 5  " "
	MOVE.B	(A2)+,scr_bytes*5(A3)	; stampa LA LINEA 6  " "
	MOVE.B	(A2)+,scr_bytes*6(A3)	; stampa LA LINEA 7  " "
	MOVE.B	(A2)+,scr_bytes*7(A3)	; stampa LA LINEA 8  " "

	ADDQ.L	#1,PuntaBitplane ; avanziamo di 8 bit (PROSSIMO CARATTERE)
	ADDQ.L	#1,PuntaTesto	; prossimo carattere da stampare

FineTesto:
	RTS

PuntaTesto:
	dc.l	TESTO

PuntaBitplane:
	dc.l	BITPLANE

;	$00 per "fine linea" - $FF per "fine testo"

		; numero caratteri per linea: 40
TESTO:	     ;		  1111111111222222222233333333334
             ;   1234567890123456789012345678901234567890
	dc.b	' Che scritte piccole! Non si leggono nem'   ; 1
	dc.b	'meno... ma sono in 640x512!             ',0 ; 1b
;
	dc.b	'Provate a premere il tasto destro e potr'   ; 2
	dc.b	'ete verificare cosa vedono i coder che  ',0 ; 2b
;
	dc.b	"non sanno come funziona l'interlace, hah"   ; 3
	dc.b	"aha! In fondo e' semplice, no?          ",0 ; 3b
;
	dc.b	'Programmate, fate qualche demo o qualche'   ; 4
	dc.b	" gioco, e' la cosa piu' creativa che si ",0 ; 4b
;
	dc.b	'possa fare nel mondo contemporaneo.     '   ; 5
	dc.b	'                                        ',$FF ; 5b - FINE

	EVEN


;	Il FONT caratteri 8x8.

FONT:
	incbin	"assembler2:sorgenti4/nice.fnt"

******************************************************************************

	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$8e,DIWS	; DiwStrt
	dc.w	$90,DIWSt	; DiwStop
	dc.w	$92,DDFS	; DdfStart
	dc.w	$94,DDFSt	; DdfStop

	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,80		; Bpl1Mod \ INTERLACE: modulo = lungh. linea!
	dc.w	$10a,80		; Bpl2Mod / per saltarle (le pari o le disp.)

		    ; 5432109876543210
;	dc.w	$100,%1001001000000100	; 1 bitplan, HIRES LACE 640x512
;					; notare il bit 2 settato per LACE!!

	dc.w	$100,BPLC0	; BplCon0 -> facciamo calcolare automatico!


BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane

	dc.w	$180,$226	; color0 - SFONDO
	dc.w	$182,$0b0	; color1 - plane 1 posizione normale, e'
				; la parte che "sporge" in alto.

	dc.w	$FFFF,$FFFE	; Fine della copperlist

******************************************************************************

	SECTION	MIOPLANE,BSS_C

BITPLANE:
	ds.b	scr_bytes*scr_h	; 80*512 un bitplane Hires int. 640x512

	end

Da notare che e' stato utilizzato il sistema del calcolo automatico dei
diwstart/stop eccetera. Comunque per l'interlace occorre ricordarsi di
mettere il modulo a "scr_bytes", in questo caso 80.

